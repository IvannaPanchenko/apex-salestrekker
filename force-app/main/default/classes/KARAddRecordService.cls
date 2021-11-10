/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Nov 3, 2020
* @description Class for ADD KAR Records invocable method
*
* CHANGE LOG
**/
public with sharing class KARAddRecordService {
        
      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description invocable method to add KAR records
    **/
   
    @InvocableMethod(label = 'Add KAR Records')
    public static void addKARs(List<Id> recIds){
        addKARsBackground(recIds);
    }
    
      
      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description future method to add KAR records
    **/
   @future
    public static void addKARsBackground(List<Id> recIds){

        String objectName = String.valueOf(recIds[0].getSObjectType());

        Map<String,KAR__c> karMap = new Map<String,KAR__c>();
        Set<Id> oppFilterIds = new Set<Id>();

        String query = 'SELECT Id, Account__c FROM '+objectName+' WHERE Id IN: recIds';

        for(SObject obj : Database.query(query)){
            oppFilterIds.add(String.valueOf(obj.get('Account__c')));
        }

        System.debug('\n\n\n oppFilterIds '+oppFilterIds);
        //get opp recs
        query = 'SELECT Id, AccountId, Account.Partner__c FROM Opportunity WHERE AccountId IN: oppFilterIds OR Account.Partner__c IN: oppFilterIds';

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>((List<Opportunity>)Database.query(query));

        System.debug('\n\n\n oppMap '+oppMap);

        List<Advice__c> adviceList = [SELECT Id FROM Advice__c WHERE Opportunity__c IN: oppMap.keySet()];
        System.debug('\n\n\n adviceList '+adviceList);
       
        Id nonApexRTID = Schema.SObjectType.KAR__c.getRecordTypeInfosByName().get('Non Apex Cover').getRecordTypeId();
        Id policyRTID = Schema.SObjectType.KAR__c.getRecordTypeInfosByName().get('Policy').getRecordTypeId();

        for(Id recId : recIds){

            for(Advice__c advice : adviceList){

                KAR__c kar;
                boolean isPrimary;
                String lookupId;

                //create KAR recs based on retrieved items
      
                if(objectName == 'Non_Apex_Cover__c' && String.isNotBlank(recId)){
                    kar = new KAR__c(Advice__c = advice.Id, Non_Apex_Cover__c = recId, RecordTypeId = nonApexRTID);
                    lookupId = kar.Non_Apex_Cover__c;
                }
                else if(objectName == 'Policy_Benefit__c'){
                    kar = new KAR__c(Advice__c = advice.Id, Policy_Benefit__c = recId, RecordTypeId = policyRTID);
                    lookupId = kar.Policy_Benefit__c;
                }

                if(kar != null) {
                    kar.put('Who_pays_for__c', 'Product Provider');
                    kar.put('Frequency__c', 'Monthly');
                    karMap.put(advice.Id+'-'+lookupId, kar);
                }
                
            }
        }  System.debug('\n\n\n karMap '+karMap);
       
        insert karMap.values();
    }
}