/*************************************************************************************************************
 * @name      AssetServices
 * @author      Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created      5 November 2021
 * @description    To control DML method on the asset object
 * @testClass       AssetServicesTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *         No.    Date      Author          Description
 *         ----  ------------  --------------------  ----------------------------------------------
 * @version    1.0    2021-11-05      Ivanna Panchenko      Creation of the class
 *
**************************************************************************************************************/
public without sharing class AssetServices {
  

    public static List<AssetInput> getSalestrekkerAssetInputByAccountId(Id accountId, String stContactId){
    
        List<AssetInput> assetInputToReturn = new List<AssetInput>();
        // Retrieve the asset mapping to get with the right for each asset
        List<Salestrekker_Asset_Mapping__mdt> assetTypeMappingList = [SELECT Id, SF_Type__c, ST_Type__c, ST_SubType_Value__c , ST_SubType_Name__c
                                                                      FROM Salestrekker_Asset_Mapping__mdt
                                                                     ];
        // Create a map to search then with the the right key we avoid to do another loop.
        Map<String, Salestrekker_Asset_Mapping__mdt> assetBySFTypMap = new Map<String, Salestrekker_Asset_Mapping__mdt> ();

        for(Salestrekker_Asset_Mapping__mdt mapping : assetTypeMappingList){
            if(!assetBySFTypMap.containsKey(mapping.SF_Type__c)){
                assetBySFTypMap.put(mapping.SF_Type__c,mapping );
            }
        }

        List<Asset_Role__c> assetRoles = AssetServices.getExistingAssetsInformationByAccountId(accountId);
        System.debug('##### ASSET FOUND BY ACCOUNTID '+ assetRoles?.size());
        if(assetRoles?.size() > 0){

            for(Asset_Role__c theAssetRole: assetRoles){

                AssetInput assetInput = new AssetInput();

                assetInput.isActive = true;
                assetInput.name = theAssetRole.Asset__r.Name;
                assetInput.value = Integer.valueOf(theAssetRole.Asset__r.Value__c);
                
                // create and add the ownership input to the assetInput
                OwnershipInput ownership = new OwnershipInput();
                ownership.isActive = true;
                ownership.percent = 100;
                ownership.idContact = stContactId;
                assetInput.ownership = ownership;
              
                // create and add types and subtypes
                if(assetBySFTypMap.containsKey(theAssetRole.Asset__r.Type__c)){  
                    // we create and add the type to the assetInput
                    Salestrekker_Asset_Mapping__mdt assetMapping = assetBySFTypMap.get(theAssetRole.Asset__r.Type__c);
                    assetInput.assetType = new AssetTypeInput();
                    assetInput.assetType.name =  AssetServices.getAssetTypeEnumByName(assetMapping.ST_Type__c);

                    // we create and add type and subtype in the asset Input depend of the subtype of the mapping
                    if(ApexAkina_Constants.PROPERTY_TYPE.equalsIgnoreCase(assetMapping.ST_SubType_Name__c)){
                        assetInput.propertyType = new PropertyTypeInput();
                        assetInput.propertyType.name = AssetServices.getPropertyTypeEnumeratorByName(assetMapping.ST_SubType_Value__c);
                    }

                    if(ApexAkina_Constants.BANK_ACCOUNT_TYPE.equalsIgnoreCase(assetMapping.ST_SubType_Name__c)){
                        assetInput.bankAccountType = new BankAccountTypeInput();
                        assetInput.bankAccountType.name = AssetServices.getBankAccountTypeEnumeratorByName(assetMapping.ST_SubType_Value__c);
                    }
                }
                assetInputToReturn.add(assetInput);
            }

        }

        return assetInputToReturn;

    }


    // Return Asset that have asset in status existing by Id
    public static List<Client_Asset__c> getExistingAssetsByNamesAndIds( Set<Id> assetsId, Set<String> assetNames){
        List<Client_Asset__c> assetsToReturn = new List<Client_Asset__c>();

        // If assets id is not empty
        if(assetsId?.size()> 0 ) {

            //retrieve the asset bu assetsId and assetsNames
            assetsToReturn = [SELECT Id, Name, Value__c, Salestrekker_Contact_Id__c, Asset_Name__c, Salestrekker_Asset_Id__c, Status__c
                                 FROM Client_Asset__c 
                                 WHERE Id IN : assetsId
                                 AND Salestrekker_Contact_Id__c = ''
                                 AND Asset_Name__c IN: assetNames
                                 AND Status__c =: ApexAkina_Constants.EXISTING
                              ];

        }
        return assetsToReturn;
    }


      // Return Asset roles that have asset in status existing by the account Id
      public static List<Asset_Role__c> getExistingAssetsInformationByAccountId( Id accountId){
        List<Asset_Role__c> assetsRoleToReturn = new List<Asset_Role__c>();

        // If the account Id is not null we retrieve the assets roles for that account and retrieves the asset from them
        if(accountId != null) {

            //retrieve the Application role for that opportunity
           assetsRoleToReturn = [SELECT Id, Asset__c, Asset__r.Name, Asset__r.Type__c, Asset__r.Value__c, Asset__r.Status__c  
                                 FROM Asset_Role__c 
                                 WHERE Account__c =: accountId
                                 AND Asset_Status__c =: ApexAkina_Constants.EXISTING
                                 AND Asset__c != null
                                 ];

        }
        return assetsRoleToReturn;
    }


    // We discused that only one contact would be the owner of the asset.
    // We update existing assets from salesforce with the salestrekkerAssetId
    // We create asset in salesforce if it doesn't exist
    public static void processAssetFromSalestrekker (AssetSalestrekker[] assetsST, String dealId, String contactId){
        if(assetsST?.size() >0){
            List<Client_Asset__c> assetsToBeUpdate = new List<Client_Asset__c>();
            List<Client_Asset__c> assetsToBeCreated = new List<Client_Asset__c>();
            // retrieve all the contact, so we can look for the assets throught the roles
            List<Account> accounts = [ SELECT Id, Salestrekker_Contact_Id__c 
                                       FROM Account 
                                       WHERE Salestrekker_Contact_Id__c!= null 
                                       AND      
                                        Salestrekker_Contact_Id__c =: contactId ];
            // if there is account we update those assets retrieve them
            if( accounts?.size() > 0){
                // retrieve all the assets role  related with that account
                List<Asset_Role__c> assetRoles = AssetServices.getExistingAssetsInformationByAccountId(accounts.get(0).Id);
                if(assetRoles?.size() > 0){
                   //Add the assets to a set to be updated
                   Set<Id> assetsId = new Set <Id>();
                   Map<String, Id> assetNamesMap = new Map<String, Id>();

                   for(Asset_Role__c theRole: assetRoles){
                        assetsId.add(theRole.Asset__c);

                        if(!assetNamesMap.containsKey(theRole.Asset__r.Name)){

                            assetNamesMap.put( theRole.Asset__r.Name, theRole.Asset__c);
                        }
                   }

                   //retrieve assets from the SF database to be updated
                   List<Client_Asset__c> existingAssets = AssetServices.getExistingAssetsByNamesAndIds(assetsId, assetNamesMap.keySet());
                   // create a map to easy to work with
                   // key name so would be easy to compare witht the asset that is comming from ST
                   Map<String, Client_Asset__c> existingAssetsMap = new Map<String, Client_Asset__c>();

                   for(Client_Asset__c asset: existingAssets){

                        if(!existingAssetsMap.containsKey(asset.Name)){

                            existingAssetsMap.put( asset.Name, asset);
                        }
                   }

                   // Retrieve all the asset metadata for the mappin in Salesforce

                   List<Salestrekker_Asset_Mapping__mdt> assetsMapping = [SELECT SF_Type__c, ST_Type__c, 	ST_SubType_Name__c,  ST_SubType_Value__c
                                                                         FROM  Salestrekker_Asset_Mapping__mdt];

                   //Create a map to easy to get values in the comparisson
                   Map <String, Salestrekker_Asset_Mapping__mdt> assetSFSTmaps = new Map <String, Salestrekker_Asset_Mapping__mdt> ();

                   //add the assetCustom metadad in a map so we don't query in the for
                   for(Salestrekker_Asset_Mapping__mdt theAssetMapping: assetsMapping){

                        // TODO @Rod here there is a map other from Salestrekker that how we know which is the rigth mapping in Salesforce
                        if(!assetSFSTmaps.containsKey(theAssetMapping.ST_Type__c)){
                            assetSFSTmaps.put(theAssetMapping.ST_Type__c,theAssetMapping );
                        }

                   }

                   // Look if the map has existing asset that we retrieve from the DB match with the ticket name
                   // in which case we will update then
                   // if the ticket name is not in the map retrieved we need to create that asset and the asset role
                   for(AssetSalestrekker theAssetST: assetsST){
                        
                        // If that asset name exist on SF database them we are going to update it
                        if(existingAssetsMap.containsKey(theAssetST.name)){
                            Client_Asset__c assetToUpdate = existingAssetsMap.get(theAssetST.name);
                            
                            assetToUpdate.Value__c =  theAssetST.value;
                            assetToUpdate.Salestrekker_Asset_Id__c = theAssetST.id;
                            assetToUpdate.Salestrekker_Contact_Id__c = contactId;
                            // if the asset in ST was inactive we set it as a void status in Salesforce
                            if(!theAssetST.isActive){
                                assetToUpdate.Status__c = ApexAkina_Constants.ASSET_VOID;
                            }

                            assetsToBeUpdate.add(assetToUpdate);
                        // we need to create that asset in SF    
                        } else {

                            Client_Asset__c newAsset = new Client_Asset__c();
                            newAsset.Name = theAssetST.name;
                            newAsset.Value__c = theAssetST.value;
                            
                            if( ! assetSFSTmaps.isEmpty() )   {
                                String type = theAssetST?.assetType?.name.name() != null  ? assetSFSTmaps.get(theAssetST?.assetType?.name.name()).SF_Type__c:
                                              theAssetST?.bankAccountType?.name.name() != null ?  assetSFSTmaps.get(theAssetST?.assetType?.name.name()).SF_Type__c:
                                              theAssetST?.propertyType?.name.name() != null ?  assetSFSTmaps.get(theAssetST?.propertyType?.name.name()).SF_Type__c :'None';

                                newAsset.Type__c = type;
                            }
                            newAsset.Status__c = theAssetST.isActive? ApexAkina_Constants.EXISTING : ApexAkina_Constants.ASSET_VOID;
                            newAsset.Salestrekker_Asset_Id__c = theAssetST.id;
                            newAsset.Salestrekker_Contact_Id__c = contactId;

                            assetsToBeCreated.add(newAsset);
                            
                        }

                   }
           
                   List<Exception_Process_Event__c> errors = new List<Exception_Process_Event__c> ();
                  
                   //update only if there is to update
                   if(assetsToBeUpdate?.size()>0){
                        List<Database.SaveResult> resultsUpdate =  Database.update(assetsToBeUpdate,false);
                        
                        for (Database.SaveResult result : resultsUpdate) {

                            if (!result.success) {
                                for( Database.Error errUpdate : result.getErrors()) {
                                    String description = 'Error while trying to update a Assets in Salesforce: '+ errUpdate.getFields();
                                    errors.add(AssetServices.createExceptionErrors(
                                        ApexAkina_Constants.DEAL_UPDATED,
                                        'Asset Sync Update fails',
                                        ApexAkina_Constants.SEV_HIGH,
                                       'Asset Sync Update fails',
                                       'Error while trying to update a Assets in Salesforce: '+ errUpdate.getFields(),
                                        accounts.get(0).Id,
                                        null
                                    ));
                                }                
                          
                                
                            }
                            
                        }

                   }

                   // we need to create the asset roles ones they
                   if(assetsToBeCreated?.size() > 0){

                        List<Database.SaveResult> resultsCreated =  Database.insert(assetsToBeCreated,false);
                         for(Database.SaveResult result: resultsCreated){

                            if(!result.success){
                                
                                for( Database.Error err : result.getErrors()) {
                                    String description = 'Error while trying to create a Assets in Salesforce: '+ err.getFields();
                                    errors.add(AssetServices.createExceptionErrors(
                                               ApexAkina_Constants.DEAL_UPDATED,
                                               'Asset Sync Creation fails',
                                               ApexAkina_Constants.SEV_HIGH,
                                               'Asset Sync Creation fails',
                                               'Error while trying to create a Assets in Salesforce: '+ err.getFields(),
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
    public static AssetTypeEnumerator getAssetTypeEnumByName ( String name ){

        switch on name {
            when 'owner_occupier_property_address' {
                return AssetTypeEnumerator.owner_occupier_property_address;
            }
            when 'investment_property_address' {
                return AssetTypeEnumerator.investment_property_address;
            }
            when 'vehicle_make_and_model' {
                return AssetTypeEnumerator.vehicle_make_and_model;
            }
            when 'bank_accounts' {
                return AssetTypeEnumerator.bank_accounts;
            }
            when 'kiwisaver' {
                return AssetTypeEnumerator.kiwisaver;
            }
            when 'home_contents' {
                return AssetTypeEnumerator.home_contents;
            }
            when 'superfund_institution' {
                return AssetTypeEnumerator.superfund_institution;
            }
            when 'shares' {
                return AssetTypeEnumerator.shares;
            }
            when 'other' {
                return AssetTypeEnumerator.other;
            }
            when 'balance_sheet' {
                return AssetTypeEnumerator.balance_sheet;
            }
            when else {
                // default asset Type
                return AssetTypeEnumerator.kiwisaver;
            }
        }
    }


    // The following methods return the right enum by the name from the custom mapping
    public static BankAccountTypeEnumerator getBankAccountTypeEnumeratorByName ( String name ){
        switch on name {
            when 'none' {
                return BankAccountTypeEnumerator.none;
            }
            when 'savings_account' {
                return BankAccountTypeEnumerator.savings_account;
            }
            when 'transaction_account' {
                return BankAccountTypeEnumerator.transaction_account;
            }
            when 'cheque_account' {
                return BankAccountTypeEnumerator.cheque_account;
            }
            when 'other_account' {
                return BankAccountTypeEnumerator.other_account;
            }
            when else {
                // default asset Type
                return BankAccountTypeEnumerator.none;
            }
        }
    }


     // The following methods return the right enum by the name from the custom mapping
     public static PropertyTypeEnumerator getPropertyTypeEnumeratorByName ( String name ){
        switch on name {
            when 'none' {
                return PropertyTypeEnumerator.none;
            }
            when 'apartment_unit_flat' {
                return PropertyTypeEnumerator.apartment_unit_flat;
            }
            when 'company_title_unit' {
                return PropertyTypeEnumerator.company_title_unit;
            }
            when 'duplex' {
                return PropertyTypeEnumerator.duplex;
            }
            when 'fully_detached_house' {
                return PropertyTypeEnumerator.fully_detached_house;
            }
            when 'holiday_home' {
                return PropertyTypeEnumerator.holiday_home;
            }
            when 'holiday_rental' {
                return PropertyTypeEnumerator.holiday_rental;
            }
            when 'house_and_land' {
                return PropertyTypeEnumerator.house_and_land;
            }
            when 'licensed_builder_construction' {
                return PropertyTypeEnumerator.licensed_builder_construction;
            }
            when 'owner_builder_construction' {
                return PropertyTypeEnumerator.owner_builder_construction;
            }
            when 'semi_detached_house' {
                return PropertyTypeEnumerator.semi_detached_house;
            }
            when 'serviced_apartment' {
                return PropertyTypeEnumerator.serviced_apartment;
            }
            when 'strata_title_unit' {
                return PropertyTypeEnumerator.strata_title_unit;
            }
            when 'single_bedroom_less_than_fifty_sqm' {
                return PropertyTypeEnumerator.single_bedroom_less_than_fifty_sqm;
            }
            when 'townhouse' {
                return PropertyTypeEnumerator.townhouse;
            }
            when 'vacant_land' {
                return PropertyTypeEnumerator.vacant_land;
            }
            when 'villa' {
                return PropertyTypeEnumerator.villa;
            }
            when else {
                // default asset Type
                return PropertyTypeEnumerator.none;
            }
        }
    }


}