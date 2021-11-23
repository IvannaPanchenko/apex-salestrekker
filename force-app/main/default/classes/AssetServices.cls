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
                assetInput.bankBsb = theAssetRole.Asset__c;
                
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
    public static List<Client_Asset__c> getExistingAssetsByIds( Set<Id> assetsId){
        List<Client_Asset__c> assetsToReturn = new List<Client_Asset__c>();

        // If assets id is not empty
        if(assetsId?.size()> 0 ) {

            //retrieve the asset bu assetsId and assetsNames
            assetsToReturn = [SELECT Id, Name, Value__c, Salestrekker_Contact_Id__c, Asset_Name__c, Salestrekker_Asset_Id__c, Status__c
                                 FROM Client_Asset__c 
                                 WHERE Id IN : assetsId
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
                   Map<Id, Asset_Role__c> assetNamesMap = new Map<Id, Asset_Role__c>();

                   for(Asset_Role__c theRole: assetRoles){
                        if(!assetNamesMap.containsKey(theRole.Asset__c)){

                            assetNamesMap.put( theRole.Asset__c, theRole);
                        }
                   }

                   //retrieve assets from the SF database to be updated
                   List<Client_Asset__c> existingAssets = AssetServices.getExistingAssetsByIds(assetNamesMap.keySet());
                   // create a map to easy to work with
                   // key name so would be easy to compare witht the asset that is comming from ST
                   Map<String, Client_Asset__c> existingAssetsMap = new Map<String, Client_Asset__c>();

                   for(Client_Asset__c asset: existingAssets){
                        // put either the salestrekker Id if it is not null or the asset Id
                        String key = String.isNotBlank(asset.Salestrekker_Asset_Id__c)? asset.Salestrekker_Asset_Id__c : asset.Id;

                        if(!existingAssetsMap.containsKey(key)){ 
                            existingAssetsMap.put( key, asset);
                        }
                   }

                   // Retrieve all the asset metadata for the mappin in Salesforce

                   List<Salestrekker_Asset_Mapping__mdt> assetsMapping = [SELECT SF_Type__c, ST_Type__c, 	ST_SubType_Name__c,  ST_SubType_Value__c
                                                                         FROM  Salestrekker_Asset_Mapping__mdt];

                   //Create a map to easy to get values in the comparisson
                   Map <String, Salestrekker_Asset_Mapping__mdt> assetSFSTmaps = new Map <String, Salestrekker_Asset_Mapping__mdt> ();

                   //add the assetCustom metadad in a map so we don't query in the for
                   for(Salestrekker_Asset_Mapping__mdt theAssetMapping: assetsMapping){

                        if(!assetSFSTmaps.containsKey(theAssetMapping.ST_Type__c)){
                            assetSFSTmaps.put(theAssetMapping.ST_Type__c,theAssetMapping );
                        }
                   }

                   // Look if the map has existing asset that we retrieve from the DB match with the ticket name
                   // in which case we will update then
                   // if the ticket name is not in the map retrieved we need to create that asset and the asset role
                   for(AssetSalestrekker theAssetST: assetsST){
                        String key = String.isNotBlank(theAssetST.bankBsb) && existingAssetsMap.containsKey(theAssetST.bankBsb)
                                     ? theAssetST.bankBsb: theAssetST.id;
                        System.debug('@@@@@@@@@@@@ theAssetST theAssetST.bankBsb '+ theAssetST.bankBsb);
                        System.debug('@@@@@@@@@@@@ theAssetST theAssetST.id '+ theAssetST.id);
                        System.debug('@@@@@@@@@@@@ theAssetST key '+ key);
                        System.debug('@@@@@@@@@ existingAssetsMap KEYS '+ existingAssetsMap.keySet());
                        // If that asset  bsbbank name exist on SF database them we are going to update it
                        if( String.isNotBlank(key) && existingAssetsMap.containsKey(key)){
                           
                            Client_Asset__c assetToUpdate = existingAssetsMap.get(key);
                            
                            assetToUpdate.Value__c =  theAssetST.value;
                            assetToUpdate.Salestrekker_Asset_Id__c = theAssetST.id;
                            assetToUpdate.Salestrekker_Contact_Id__c = contactId;
                            // if the asset in ST was inactive we set it as a void status in Salesforce
                            if(!theAssetST.isActive){
                                assetToUpdate.Status__c = ApexAkina_Constants.ASSET_VOID;
                            }

                            assetsToBeUpdate.add(assetToUpdate);
                        // we need to create that asset in SF    // or has asset id 
                        } else if (! existingAssetsMap.containsKey(key)) {

                            Client_Asset__c newAsset = new Client_Asset__c();
                            newAsset.Name = theAssetST.name;
                            newAsset.Value__c = theAssetST.value;
                            newAsset.Status__c = theAssetST.isActive? ApexAkina_Constants.EXISTING : ApexAkina_Constants.ASSET_VOID;
                            newAsset.Salestrekker_Asset_Id__c = theAssetST.id;
                            newAsset.Salestrekker_Contact_Id__c = contactId;
                            
                            if( ! assetSFSTmaps.isEmpty() )   {
                                String type = theAssetST?.assetType?.name.name() != null  ? assetSFSTmaps.get(theAssetST?.assetType?.name.name()).SF_Type__c:
                                              theAssetST?.bankAccountType?.name.name() != null ?  assetSFSTmaps.get(theAssetST?.assetType?.name.name()).SF_Type__c:
                                              theAssetST?.propertyType?.name.name() != null ?  assetSFSTmaps.get(theAssetST?.propertyType?.name.name()).SF_Type__c :'None';

                                newAsset.Type__c = type;
                            }
                       

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
        AssetTypeEnumerator assetTypeEnum;
        for (AssetTypeEnumerator assetEnum: AssetTypeEnumerator.values()) {
            if (assetEnum.name() == name) {
                assetTypeEnum = assetEnum;
                break;
            }
        }
        return assetTypeEnum != null? assetTypeEnum : AssetTypeEnumerator.other;
    }


    // The following methods return the right enum by the name from the custom mapping
    public static BankAccountTypeEnumerator getBankAccountTypeEnumeratorByName ( String name ){
        BankAccountTypeEnumerator bankAccountTypeEnum;
        for (BankAccountTypeEnumerator banckEnum: BankAccountTypeEnumerator.values()) {
            if (banckEnum.name() == name) {
                bankAccountTypeEnum = banckEnum;
                break;
            }
        }
        return bankAccountTypeEnum != null? bankAccountTypeEnum : BankAccountTypeEnumerator.none;
    }


     // The following methods return the right enum by the name from the custom mapping
     public static PropertyTypeEnumerator getPropertyTypeEnumeratorByName ( String name ){
        PropertyTypeEnumerator propertyTypeEnum;
        for (PropertyTypeEnumerator propertyEnum: PropertyTypeEnumerator.values()) {
            if (propertyEnum.name() == name) {
                propertyTypeEnum = propertyEnum;
                break;
            }
        }
        return propertyTypeEnum != null? propertyTypeEnum : PropertyTypeEnumerator.none;
    
    }


}