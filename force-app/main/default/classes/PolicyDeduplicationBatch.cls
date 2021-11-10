/******************************************************************************************
* Create By     :    Alvin Aquino
* Create Date  :     February 13, 2020
* Description   :    Batch class for deduplication of Policy Record
*   Modification Log:
*    -----------------------------------------------------------------------------
*    * Developer                          Date               Description
*    * ----------------------------------------------------------------------------                 
*    * Alvin Aquino                      Feb-13-2020         Initial version.
*****************************************************************************************/

global class PolicyDeduplicationBatch implements Database.Batchable<sObject>{


    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Build Query to select all fields
        string strObjectName = 'Policy__c';
        String strQuery = 'SELECT ';
        list<Schema.DescribeSObjectResult> objDiscribe = Schema.describeSObjects(new List<String>{strObjectName});
        map<String, Schema.SObjectField> objFileds = objDiscribe[0].fields.getMap();
        list<String> lstOfFieldNames = new list<String>(objFileds.keySet());
        strQuery = strQuery + String.join(lstOfFieldNames, ', ') + ' FROM ' +strObjectName;
        strQuery = strQuery + ' WHERE Type__c = \'Medical\' AND CreatedDate = LAST_N_Days:3';

        return Database.getQueryLocator(strQuery);

    }

    global void execute(Database.BatchableContext bc, List<Policy__c> scope){
        // process each batch of records

        set<string> setProviderExternalIds = new set<string>();
        for(Policy__c mpolicy: scope){
            if(mpolicy.Provider_External_ID__c != null && mpolicy.Provider_External_ID__c.contains('M')){
                string mpei = mpolicy.Provider_External_ID__c.left(mpolicy.Provider_External_ID__c.indexOf('M'));
                mpei = mpei + 'R';
                setProviderExternalIds.add(mpei);
            }

        }

        
        Map<id, List<Policy__c>> maprisklstmed = new Map<id, List<Policy__c>>();

        List<Policy__c> lstRiskPolicy = [Select Id, Name, Provider_External_ID__c, Total_Premium__c FROM Policy__c WHERE Type__c = 'Risk' AND Provider_External_ID__c in: setProviderExternalIds];
        system.debug('m '+ lstRiskPolicy.size() + ' r' + scope.size() );
        List<Policy__c> lstPolicyToBeDeleted = new List<Policy__c>();
        List<Policy__c> lstPolicyToBeUpdated = new List<Policy__c>();
        List<Policy_Benefit__c> lstPBenToBeUpdated = new List<Policy_Benefit__c>();
        List<Policy_Role__c> lstPRoleToBeUpdated = new List<Policy_Role__c>();


        

        //basis of duplicate: provider external Id, total premium and Policy Number

        for(Policy__c rrec: lstRiskPolicy){
            if(rrec.Provider_External_ID__c != null && rrec.Provider_External_ID__c.contains('R')){
                string rpei = rrec.Provider_External_ID__c.left(rrec.Provider_External_ID__c.indexOf('R'));
                for(Policy__c mrec: scope){
                    if(mrec.Provider_External_ID__c != null && mrec.Provider_External_ID__c.contains('M')){
                        string mpei = mrec.Provider_External_ID__c.left(mrec.Provider_External_ID__c.indexOf('M'));
                        if(rpei == mpei && rrec.Total_Premium__c == mrec.Total_Premium__c ){
                            List<Policy__c> lstMed = new List<Policy__c>();
                            lstMed.add(mrec);

                            if(maprisklstmed.containsKey(rrec.Id)){
                                maprisklstmed.get(rrec.Id).add(mrec);
                            }else{
                                maprisklstmed.put(rrec.Id, lstMed);
                            }
                        }
                    }
                }
            }   
        }

        //iterate on maprisklstmed
        for(id riskId: maprisklstmed.keyset()){
            if(maprisklstmed.get(riskId).size() == 1){
                lstPolicyToBeDeleted.addAll(maprisklstmed.get(riskId));
            }
            if(maprisklstmed.get(riskId).size() > 1){
                lstPolicyToBeUpdated.addAll(maprisklstmed.get(riskId));
            }
        }


        //get all child Policy Role and Policy Benefit
        if(!lstPolicyToBeDeleted.isEmpty()){
            Map<id, Policy__c> mapPTD = new Map<id, Policy__c>(lstPolicyToBeDeleted);
            //get all policy Benefit
            List<Policy_Benefit__c> lstPBen = [SELECT Id, Policy__c, Policy__r.Name, Policy__r.Total_Premium__c, Policy__r.Provider_External_ID__c
                 FROM Policy_Benefit__c WHERE Policy__c in: mapPTD.keyset()];
            if(!lstPBen.isEmpty()){
                for(Policy__c rrec: lstRiskPolicy){
                    if(rrec.Provider_External_ID__c != null && rrec.Provider_External_ID__c.contains('R')){
                        string rpei = rrec.Provider_External_ID__c.left(rrec.Provider_External_ID__c.indexOf('R'));
                        for(Policy_Benefit__c pbrec: lstPBen){
                            if(pbrec.Policy__r.Provider_External_ID__c != null && pbrec.Policy__r.Provider_External_ID__c.contains('M')){
                                string mpei = pbrec.Policy__r.Provider_External_ID__c.left(pbrec.Policy__r.Provider_External_ID__c.indexOf('M'));
                                if(rpei == mpei && rrec.Total_Premium__c == pbrec.Policy__r.Total_Premium__c){
                                    pbrec.Policy__c = rrec.Id;
                                    lstPBenToBeUpdated.add(pbrec);
                                }
                            }
                        }
                    }
                }
            }

            //get all policy role
          //  List<Policy_Role__c> lstPRole = [SELECT Id, Policy__c, Policy__r.Name, Policy__r.Total_Premium__c, Policy__r.Provider_External_ID__c
             //    FROM Policy_Role__c WHERE Policy__c in: mapPTD.keyset()];
          //  if(!lstPRole.isEmpty()){
             //   for(Policy__c rrec: lstRiskPolicy){
                 //   if(rrec.Provider_External_ID__c != null && rrec.Provider_External_ID__c.contains('R')){
                 //       string rpei = rrec.Provider_External_ID__c.left(rrec.Provider_External_ID__c.indexOf('R'));
                   //     for(Policy_Role__c prrec: lstPRole){
                     //       if(prrec.Policy__r.Provider_External_ID__c != null && prrec.Policy__r.Provider_External_ID__c.contains('M')){
                      //          string mpei = prrec.Policy__r.Provider_External_ID__c.left(prrec.Policy__r.Provider_External_ID__c.indexOf('M'));
                        //        if(rpei == mpei && rrec.Total_Premium__c == prrec.Policy__r.Total_Premium__c){
                       //             prrec.Policy__c = rrec.Id;
                         //           lstPRoleToBeUpdated.add(prrec);
                         //       }
                        //    }
                     //   }
                   // }
             //   }

          //  }
        }

        if(!lstPolicyToBeUpdated.isEmpty()){
            for (Policy__c prec: lstPolicyToBeUpdated){
                prec.Duplication_Issue__c = true;
            }

            update lstPolicyToBeUpdated;
        }

        if(!lstPBenToBeUpdated.isEmpty()){
            update lstPBenToBeUpdated;
        }

    //    if(!lstPRoleToBeUpdated.isEmpty()){
     //       update lstPRoleToBeUpdated;
     //   }

        if(!lstPolicyToBeDeleted.isEmpty()){
            delete lstPolicyToBeDeleted;
        }

        

        
    }

    global void finish(Database.BatchableContext bc){
        //no finish       
    }    
   

}