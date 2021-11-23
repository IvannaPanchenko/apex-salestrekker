/*************************************************************************************************************
 * @name			LiabilityServices
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			5 November 2021
 * @description		To control DML method on the liability object
 * @testClass       AssetServicesTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-11-05      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
public without sharing class LiabilityServices {
    
    
    public static List<LiabilityInput> getSalestrekkerLiabilityInputByAccountId(Id accountId, String stContactId){
    
        List<LiabilityInput> liabiltiyInputToReturn = new List<LiabilityInput>();
        // Retrieve the liability mapping to get with the right for each liability
        List<Salestrekker_Liability_Mapping__mdt> liabilityTypeMappingList = [SELECT Id, SF_Type__c, ST_Type__c
                                                                                 FROM Salestrekker_Liability_Mapping__mdt
                                                                             ];
        // Create a map to search then with the the right key we avoid to do another loop.
        Map<String, Salestrekker_Liability_Mapping__mdt> liabilityBySFTypMap = new Map<String, Salestrekker_Liability_Mapping__mdt> ();

        for(Salestrekker_Liability_Mapping__mdt mapping : liabilityTypeMappingList){
            if(!liabilityBySFTypMap.containsKey(mapping.SF_Type__c)){
                liabilityBySFTypMap.put(mapping.SF_Type__c,mapping );
            }
        }

        List<Liability_Role__c > liabilityRoles = LiabilityServices.getExistingLiabilitiesInformationByAccountId(accountId);
        if(liabilityRoles?.size() > 0){

            for(Liability_Role__c  theLiabilityRole: liabilityRoles){

                LiabilityInput LiabilityInput = new LiabilityInput();

                LiabilityInput.isActive = true;
                LiabilityInput.lenderOtherName = theLiabilityRole.Liability__c;
                LiabilityInput.name = theLiabilityRole.Liability__r.Name;
                LiabilityInput.balance = Integer.valueOf(theLiabilityRole.Liability__r.Current_Balance__c);
                
                // create and add the ownership input to the LiabilityInput
                OwnershipInput ownership = new OwnershipInput();
                ownership.isActive = true;
                ownership.percent = 100;
                ownership.idContact = stContactId;
                LiabilityInput.ownership = ownership;
              
                // create and add types and subtypes
                if(liabilityBySFTypMap.containsKey(theLiabilityRole.Liability__r.Type__c)){  
                    // we create and add the type to the LiabilityInput
                    Salestrekker_Liability_Mapping__mdt liabilityMapping = liabilityBySFTypMap.get(theLiabilityRole.Liability__r.Type__c);
                    LiabilityInput.liabilityType = new LiabilityTypeInput();
                    LiabilityInput.liabilityType.name =  LiabilityServices.getLiabilityTypeEnumByName(liabilityMapping.ST_Type__c);

                    // if this is an investment we need to set the mortgage type in true other cases false
                    LiabilityInput.mortgageType = ApexAkina_Constants.MORTGAGE_LOAN_INVESTMENT.equalsIgnoreCase(liabilityMapping.ST_Type__c); 

                    //set dates only for loan if the dates in SF are not null
                    if ( ApexAkina_Constants.MORTGAGE_LOAN_INVESTMENT.equalsIgnoreCase(liabilityMapping.ST_Type__c) || 
                        ApexAkina_Constants.MORTGAGE_LOAN_PRIMARY_RESIDENCE.equalsIgnoreCase(liabilityMapping.ST_Type__c) ) {
                        
                        if( theLiabilityRole.Liability__r.Expiry_Date__c != null){
                            LiabilityInput.fixedExpiryDate = DateUtils.getEpochFromDate(theLiabilityRole.Liability__r.Expiry_Date__c);
                        }

                        if( theLiabilityRole.Liability__r.End_Date__c != null ){
                            LiabilityInput.endDate = DateUtils.getEpochFromDate(theLiabilityRole.Liability__r.End_Date__c); 
        
                        }
                    }
                 
                }
                System.debug('########### LiabilityInput '+ LiabilityInput);
                liabiltiyInputToReturn.add(LiabilityInput);
            }

        }
        return liabiltiyInputToReturn;

    }


    // Return liability that have liability in status existing by Id
    public static List<Liability__c > getExistingLiabiltiesByIds( Set<Id> liabilityId){
        List<Liability__c > liabilitiesToReturn = new List<Liability__c >();

        // If liabilities id is not empty
        if(liabilityId?.size()> 0 ) {

            //retrieve the liability bu liabilityId 
            liabilitiesToReturn = [ SELECT   Id, Name, Current_Balance__c, 
                                            Salestrekker_Contact_Id__c, SalestrekkerLiability_Id__c
                                    FROM Liability__c  
                                    WHERE Id IN : liabilityId
                                    AND Current_Balance__c > 0];

        }
        return liabilitiesToReturn;
    }


      // Return liability roles that have liability in status existing by the account Id
      public static List<Liability_Role__c > getExistingLiabilitiesInformationByAccountId( Id accountId){
        List<Liability_Role__c > liabilitiesRoleToReturn = new List<Liability_Role__c >();

        // If the account Id is not null we retrieve the liabilities roles for that account and retrieves the liability from them
        if(accountId != null) {

            //retrieve the Application role for that opportunity
           liabilitiesRoleToReturn = [SELECT Id, Liability__c, Liability__r.Name,
                                             Liability__r.Type__c, 
                                             Liability__r.Current_Balance__c,
                                             Liability__r.Expiry_Date__c,  Liability__r.End_Date__c

                                        FROM Liability_Role__c  
                                        WHERE Account__c =: accountId
                                        AND Liability__r.Current_Balance__c  > 0 
                                        AND Liability__c != null
                                        ];

        }
        return liabilitiesRoleToReturn;
    }


    // We discused that only one contact would be the owner of the liability.
    // We update existing liabilities from salesforce with the salestrekkerAssetId
    // We create liability in salesforce if it doesn't exist
    public static void processLiabilitiesFromSalestrekker (LiabilitySalestrekker[] liablitiesST, String dealId, String contactId){
        if(liablitiesST?.size() >0){
            List<Liability__c > liabiltiesToBeUpdate = new List<Liability__c >();
            List<Liability__c > liabiltiesToBeCreated = new List<Liability__c >();
            // retrieve all the contact, so we can look for the liabilities throught the roles
            List<Account> accounts = [ SELECT Id, Salestrekker_Contact_Id__c 
                                       FROM Account 
                                       WHERE Salestrekker_Contact_Id__c!= null 
                                       AND      
                                        Salestrekker_Contact_Id__c =: contactId ];
                         
            // if there is account we update those liabilities retrieve them
            if( accounts?.size() > 0){
                 
                // retrieve all the liabilities role  related with that account
                List<Liability_Role__c > liabilityRoles = LiabilityServices.getExistingLiabilitiesInformationByAccountId(accounts.get(0).Id);
 
                if(liabilityRoles?.size() > 0){
                   //Add the liabilities to a set to be updated
                   Set<Id> liabilityId = new Set <Id>();

                   // Map Liability - Liability role
                   Map<Id, Liability_Role__c> liabilityRoleMap = new Map<Id, Liability_Role__c>();

                   for(Liability_Role__c  theRole: liabilityRoles){
                        liabilityId.add(theRole.Liability__c);

                        if(!liabilityRoleMap.containsKey(theRole.Liability__c)){
                            liabilityRoleMap.put( theRole.Liability__c, theRole);
                        }
                   }

                   //retrieve liabilities from the SF database to be updated

                   List<Liability__c > existingLiabilties = LiabilityServices.getExistingLiabiltiesByIds(liabilityRoleMap.keySet());
                   // create a map to easy to work with
                   // key name so would be easy to compare witht the liability that is comming from ST
                   Map<String, Liability__c > existingLiabiltiesMap = new Map<String, Liability__c >();

                   for(Liability__c  liability: existingLiabilties){
                        String key = String.isNotBlank(liability.SalestrekkerLiability_Id__c)? liability.SalestrekkerLiability_Id__c : liability.Id;
                        if(!existingLiabiltiesMap.containsKey(key)){
                            existingLiabiltiesMap.put( key, liability);
                        }
                   }

                   // Retrieve all the liability metadata for the mappin in Salesforce
                   List<Salestrekker_Liability_Mapping__mdt> liabilitiesMapping = [SELECT SF_Type__c, ST_Type__c
                                                                                   FROM  Salestrekker_Liability_Mapping__mdt];

                   //Create a map to easy to get values in the comparisson
                   Map <String, Salestrekker_Liability_Mapping__mdt> liabiltySFSTmaps = new Map <String, Salestrekker_Liability_Mapping__mdt> ();

                   //add the assetCustom metadad in a map so we don't query in the for
                   for(Salestrekker_Liability_Mapping__mdt theLiabilityMapping: liabilitiesMapping){

                        if(!liabiltySFSTmaps.containsKey(theLiabilityMapping.ST_Type__c)){
                            liabiltySFSTmaps.put(theLiabilityMapping.ST_Type__c, theLiabilityMapping );
                        }

                   }

                   // Look if the map has existing liability that we retrieve from the DB match with the ticket name
                   // in which case we will update then
                   // if the ticket name is not in the map retrieved we need to create that liability and the liability role
                   for(LiabilitySalestrekker theLiabiltyST: liablitiesST){

                        if( theLiabiltyST.isActive ){
                            String key = String.isNotBlank(theLiabiltyST.lenderOtherName) && existingLiabiltiesMap.containsKey(theLiabiltyST.lenderOtherName)
                                         ? theLiabiltyST.lenderOtherName: theLiabiltyST.id;
                            System.debug('@@@@@@@@@@@@ theLiabiltySt theLiabiltyST.idReference '+ theLiabiltyST.lenderOtherName);
                            System.debug('@@@@@@@@@@@@ theLiabiltySt theLiabiltyST.id '+ theLiabiltyST.id);
                            System.debug('@@@@@@@@@@@@ theLiabiltySt key '+ key);
                            System.debug('@@@@@@@@@ existingLiabiltiesMap KEYS '+ existingLiabiltiesMap.keySet());
                            // If that liabilit from ST has bsb is and the name exist on SF database them we are going to update it
                            if(String.isNotBlank(key) && (existingLiabiltiesMap.containsKey(key))){
                                Liability__c  liabilityToUpdate = existingLiabiltiesMap.get(key);

                                liabilityToUpdate.Current_Balance__c =  theLiabiltyST.balance;
                                liabilityToUpdate.SalestrekkerLiability_Id__c = theLiabiltyST.id;
                                liabilityToUpdate.Salestrekker_Contact_Id__c = contactId;
                                liabiltiesToBeUpdate.add(liabilityToUpdate);
                            // we need to create that liability in SF    
                            } else if (! existingLiabiltiesMap.containsKey(key)) {
                                Liability__c  newLiability = new Liability__c ();
                                newLiability.Name = theLiabiltyST.name;
                                newLiability.Current_Balance__c = theLiabiltyST.balance;
                                newLiability.SalestrekkerLiability_Id__c = theLiabiltyST.id;
                                newLiability.Salestrekker_Contact_Id__c = contactId;

                                if( ! liabiltySFSTmaps.isEmpty() )   {
                                     // as we have 2 type of morgatge we use in the mapping the morgantype value to discriminate one of the other
                                     // so when the morgantype is true we know that is investment otherwise it is a primary residence
                                    String typeKeyName =  ApexAkina_Constants.MORTGAGE_LOAN.equalsIgnoreCase(theLiabiltyST?.liabilityType?.name.name()) 
                                                          && theLiabiltyST.mortgageType ?  ApexAkina_Constants.MORTGAGE_LOAN_INVESTMENT
                                                          : ApexAkina_Constants.MORTGAGE_LOAN.equalsIgnoreCase(theLiabiltyST?.liabilityType?.name.name()) 
                                                          && !theLiabiltyST.mortgageType ? ApexAkina_Constants.MORTGAGE_LOAN_PRIMARY_RESIDENCE 
                                                          : theLiabiltyST?.liabilityType?.name.name();
                                    // just in case it is blank we set as default primary residence
                                    String type = String.isNotBlank(typeKeyName) &&  liabiltySFSTmaps.containsKey(typeKeyName) ? liabiltySFSTmaps.get(typeKeyName).SF_Type__c: 
                                                  liabiltySFSTmaps.get( ApexAkina_Constants.OTHER_LOANS).SF_Type__c;
                                    
                                    newLiability.Type__c = type;
                                }  

                                liabiltiesToBeCreated.add(newLiability);
                                
                            }
                        }

                   }
           
                   List<Exception_Process_Event__c> errors = new List<Exception_Process_Event__c> ();

                   //update only if there is to update
                   if(liabiltiesToBeUpdate?.size()>0){
                        List<Database.SaveResult> resultsUpdate =  Database.update(liabiltiesToBeUpdate,false);
                        
                        for (Database.SaveResult result : resultsUpdate) {

                            if (!result.success) {
                                for( Database.Error errUpdate : result.getErrors()) {
                                    String description = 'Error while trying to update a liabilities in Salesforce: '+ errUpdate.getFields();
                                    errors.add(LiabilityServices.createExceptionErrors(
                                        ApexAkina_Constants.DEAL_UPDATED,
                                        'liability Sync Update fails',
                                        ApexAkina_Constants.SEV_HIGH,
                                       'liability Sync Update fails',
                                       'Error while trying to update a liabilities in Salesforce: '+ errUpdate.getFields(),
                                        accounts.get(0).Id,
                                        null
                                    ));
                                }                
                          
                                
                            }
                            
                        }

                   }

                   // we need to create the liability roles ones they
                   if(liabiltiesToBeCreated?.size() > 0){

                        List<Database.SaveResult> resultsCreated =  Database.insert(liabiltiesToBeCreated,false);
                         for(Database.SaveResult result: resultsCreated){

                            if(!result.success){
                                
                                for( Database.Error err : result.getErrors()) {
                                    String description = 'Error while trying to create a liabilities in Salesforce: '+ err.getFields();
                                    errors.add(LiabilityServices.createExceptionErrors(
                                               ApexAkina_Constants.DEAL_UPDATED,
                                               'liability Sync Creation fails',
                                               ApexAkina_Constants.SEV_HIGH,
                                               'liability Sync Creation fails',
                                               'Error while trying to create a liabilities in Salesforce: '+ err.getFields(),
                                               accounts.get(0).Id,
                                               null
                                    ));
                                }                
                            }
                        }

                        if( errors?.size()> 0 ){
                            Database.insert(errors);
                        }
                   }
         
                }
            // do we need to create that account?     
            } else {

            }


        }

    }


    public static Exception_Process_Event__c createExceptionErrors (String type, String name, 
                                                            String severity, String message, 
                                                            String description, 
                                                            String sfObjId, String stObjId ){

        Exception_Process_Event__c myException = new Exception_Process_Event__c();  
        myException.Event_Type__c = type;
        myException.Name = name;
        myException.Message__c = message ;
        myException.Severity__c = severity;
        myException.SFObjecId__c = sfObjId;
        myException.SalestrekkerObjecId__c = stObjId;
        myException.Description__c = description;
        return myException;
    }


       // The following methods return the right enum by the name from the custom mapping
       public static LiabilityTypeEnumerator getLiabilityTypeEnumByName ( String name ){
        LiabilityTypeEnumerator liabilityTypeEnum;

        // as mortgage_loan could match with 2 in Salesforce we need to set the right name
        // otherwise we keep the other name; 
        name = ApexAkina_Constants.MORTGAGE_LOAN_INVESTMENT.equalsIgnoreCase(name) 
               || ApexAkina_Constants.MORTGAGE_LOAN_PRIMARY_RESIDENCE.equalsIgnoreCase(name)
               ? ApexAkina_Constants.MORTGAGE_LOAN : name;

        for (LiabilityTypeEnumerator liabilityEnum: LiabilityTypeEnumerator.values()) {
            if (liabilityEnum.name() == name) {
                liabilityTypeEnum = liabilityEnum;
                break;
            }
        }
        // by default we are sending other
        return liabilityTypeEnum != null? liabilityTypeEnum : LiabilityTypeEnumerator.other;
    }



}
