/**
* @author David (david@cloudinit.nz)
* @date Sept 14, 2018
* @description Trigger handler for account trigger.
*
* CHANGE LOG
* Sept 14, 2018 - Initial setup (david@cloudinit.nz)
* October 2018 - Add TriggerHandler extension (jayson@cloudinit.nz)
**/
public class AccountTriggerHandler extends TriggerHandler {
    
    public static Boolean allowCallout = Boolean.valueOf(Label.Enable_Sharepoint_Callout);
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method that can be called in the process builder.
    **/
    @InvocableMethod(label = 'Create Account Folder')
    public static void createAccountFolders(List<Id> accountIds){
        Map<Id, Account> validAcct = new Map<Id, Account>([SELECT Id, Sharepoint_Folder_Created__c, Sharepoint_Folder_Name__c FROM Account WHERE Id IN :accountIds AND Sharepoint_Folder_Created__c = false]);
        // Call sharepoint method if callout is allowed.
        if(allowCallout && !System.isBatch() && !System.isFuture() && !validAcct.isEmpty()){
            createSharePointFolders(new List<Id>(validAcct.keySet()));
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to get all existing folders in Sharepoint and validate whether folder name exist or not.
    **/
    @future(callout=true)
    public static void createSharePointFolders(List<Id> accountIds){
        //Set<String> folderNames = getExistingFolders(); //Comment this out to avoid apex heap size error
        Set<String> newFolders = new Set<String>();
        List<Account> accountsToUpdate = new List<Account>();
        
        for(Account acc : [SELECT Id, Name, Akina_Id__c, Sharepoint_Folder_Name__c FROM Account WHERE Id IN :accountIds]){
            String folderName = acc.Name + ' (' + acc.Akina_Id__c + ')';
            //if(!folderNames.contains(folderName)){
            newFolders.add(String.escapeSingleQuotes(folderName));
            accountsToUpdate.add(new Account(Id = acc.Id, Sharepoint_Folder_Created__c = true,
                                    Sharepoint_Folder_Name__c = String.isNotBlank(acc.Sharepoint_Folder_Name__c) ? acc.Sharepoint_Folder_Name__c : folderName));
            //}
        }
        
        if(!newFolders.isEmpty()){
            System.debug(newFolders);
            createSharePointFolders(newFolders);
            Database.update(accountsToUpdate);
        }
        
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to send post callout to create folders in Sharepoint.
    **/
    public static void createSharePointFolders(Set<String> folderNames){
        
        String batchId = 'batch_' + generateRandomString(8) + '-' + generateRandomString(4) + '-' + generateRandomString(4) + '-' + generateRandomString(4) + '-' + generateRandomString(12);
        String changesetId = 'changeset_' + generateRandomString(8) + '-' + generateRandomString(4) + '-' + generateRandomString(4) + '-' + generateRandomString(4) + '-' + generateRandomString(12);
        
        String requestBody = '--' + batchId + '\nContent-Type: multipart/mixed; boundary=' + changesetId;
        
        for(String folderName : folderNames){
            requestBody += '\n\n--' + changesetId;
            requestBody += '\nContent-Type: application/http\nContent-Transfer-Encoding: binary';
            requestBody += '\n\nPOST ' + Label.Sharepoint_Site + '/_api/web/GetFolderByServerRelativeUrl(\'Shared%20Documents\')/Folders HTTP/1.1';
            requestBody += '\nContent-Type: application/json; odata=verbose';
            requestBody += '\n\n{ \'__metadata\': { \'type\':\'SP.Folder\' }, \'ServerRelativeUrl\': \'Shared Documents/' + folderName + '\' }';
        }
        
        requestBody += '\n--' + changesetId + '--';
        requestBody += '\n\n--' + batchId + '--';
        
        String endpointURL = 'callout:SharePoint' + '/_api/$batch';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointURL);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody(requestBody);
        req.setHeader('Accept','application/json; odata=verbose');
        req.setHeader('Content-Type', 'multipart/mixed; boundary=' + batchId);
        Http newHttp = new Http();
        HttpResponse res;

        if(!Test.isRunningTest()){
            res = newHttp.send(req);
        }

    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to generate random string.
    **/
    public static String generateRandomString(Integer length) {
        // Return random generated string
        return EncodingUtil.convertToHex(Crypto.generateAesKey(256)).substring(0, length);
        
    }

    /**
     * TriggerHandler Extension
     * Account Duplicate Handler 
     *
     * @author Jayson Faderanga
     * @date November 2018
     */
    public List <Account> newAccounts {
        get {
            return (List <Account> ) Trigger.new;
        }
        private set;
    }

    public Map <Id, Account> oldAccountMap {
        get {
            return (Map <Id, Account> ) Trigger.oldMap;
        }
        private set;
    }

    public override void beforeInsert() {
        populateLastName(newAccounts);
        updateServiceFields();
    }

    public override void beforeUpdate() {
        updateServiceFields();
    }

    public override void afterInsert() {
        // Call method to check duplicate records
        checkForDuplicates(newAccounts);
    }

    public override void afterUpdate() {
        // Call method to check duplicate records
        checkForDuplicates(newAccounts);
        //Check total monetary values
        checkTotalMonetaryValuesUpdate(newAccounts);
    }
    /**
     *  @author Patrick Lorilla (plorilla@deloitte.co.nz)
     *  @desription Method to check if there are any updates towards the total monetary values and if there are any then update related advice records total monetary values.
     */
    private void checkTotalMonetaryValuesUpdate(List<Account> newAccounts){
        Set<Id> changedAccountIds = new Set<Id>();
      
        for(Account acct: newAccounts){
            //get changed accounts
            if(acct.Total_Client_Liabilities__c != oldAccountMap.get(acct.Id).Total_Client_Liabilities__c ||
               acct.Total_Client_Expenses__c != oldAccountMap.get(acct.Id).Total_Client_Expenses__c ||
               acct.Total_Client_Assets__c != oldAccountMap.get(acct.Id).Total_Client_Assets__c ||
               acct.Total_Income__c != oldAccountMap.get(acct.Id).Total_Income__c ||
               acct.Total_Net_Worth__c != oldAccountMap.get(acct.Id).Total_Net_Worth__c){

               changedAccountIds.add(acct.Id);

            }
        }   
        //update related advice records
        System.debug('\n\n\n checkTotalMonetaryValuesUpdate '+changedAccountIds); if(changedAccountIds.isEmpty()) return;
        List<Advice__c> advicesToUpdate = [SELECT Id, Total_Expenses__c, Total_Assets__c, Total_Liabilities__c, Total_Income__c, Total_Net_Worth__c, Disposable_Income__c, Opportunity__r.Account.Disposable_Income__c,
        Opportunity__r.Account.Total_Client_Expenses__c, Opportunity__r.Account.Total_Client_Assets__c, Opportunity__r.Account.Total_Income__c, Opportunity__r.Account.Total_Client_Liabilities__c,
        Opportunity__r.Account.Total_Net_Worth__c, Opportunity__r.AccountId FROM Advice__c WHERE Opportunity__r.AccountId IN: changedAccountIds];

        for(Advice__c advice : advicesToUpdate){

           advice.Total_Expenses__c =   advice.Opportunity__r.Account.Total_Client_Expenses__c;
           advice.Total_Assets__c = advice.Opportunity__r.Account.Total_Client_Assets__c;
           advice.Total_Liabilities__c = advice.Opportunity__r.Account.Total_Client_Liabilities__c;
           advice.Total_Income__c = advice.Opportunity__r.Account.Total_Income__c;
           advice.Total_Net_Worth__c =  advice.Opportunity__r.Account.Total_Net_Worth__c;
           advice.Disposable_Income__c =  advice.Opportunity__r.Account.Disposable_Income__c;
        }

        if(!advicesToUpdate.isEmpty()) update advicesToUpdate;

    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to populate lastname when it's empty. Lastname is required in order to be saved.
    *                We remove lastname field in the mapping so we need to have this piece of code
    **/
    public void populateLastName(List<Account> newAccounts) {
        // Loop through list of accounts
        for(Account acc : newAccounts) {
            if (String.isBlank(acc.LastName) && String.isNotBlank(acc.Integration_Last_Name__pc)) {
                acc.LastName = acc.Integration_Last_Name__pc;
            }
            if (String.isBlank(acc.Name) && String.isNotBlank(acc.Integration_Account_Name__c)) {
                acc.Name = acc.Integration_Account_Name__c;
            }
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to check and delete duplicate records
    **/
    public void checkForDuplicates(List<Account> newAccounts) {
        
        Id unknownClientId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Client').getRecordTypeId();
        Id unknownBusinessId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Unknown Business').getRecordTypeId();
        
        // Initialize variables
        Set<String> providerNumbers = new Set<String>();
        Map<String, Customer_Provider_Code__c> existingProviderNumbers = new Map<String, Customer_Provider_Code__c>();
        
        Map<Id, Account> forDeletion = new Map<Id, Account>();
        List<Customer_Provider_Code__c> accountProviders = new List<Customer_Provider_Code__c>();
        
        Map<String, Account> existingClients = findExistingPersonAccounts(newAccounts);
        Map<String, Account> existingBusinessAccs = findExistingBusinessAccounts(newAccounts);
        
        // Loop through list of accounts
        for(Account acc : newAccounts) {
            // Need to check that record is created by integration user
            if (String.isNotBlank(acc.Provider_Customer_Number__c) && acc.Created_By_Integration__c) {
                // Add provider number to the list
                providerNumbers.add(acc.Provider_Customer_Number__c);
            }
        }
        
        if (!providerNumbers.isEmpty()) {
            // Query list of customer provider codes
            for(Customer_Provider_Code__c providerCode : [SELECT Id, Customer__c, Name, Ext_Id__c, isMaster__c FROM Customer_Provider_Code__c WHERE Name IN :providerNumbers LIMIT 50000]) {
                existingProviderNumbers.put(providerCode.Name, providerCode);
            }
        }
        
        for(Account acc : newAccounts) {
            
            // This will make sure that only unknown records will be deleted
            if (acc.RecordTypeId == unknownClientId || acc.RecordTypeId == unknownBusinessId) {
                // Generate key
                String key = acc.isPersonAccount ? (acc.Integration_First_Name__pc + acc.Integration_Last_Name__pc + acc.Integration_Birthdate__pc) : acc.Name;
                
                if(existingProviderNumbers.containsKey(acc.Provider_Customer_Number__c) && acc.Id != existingProviderNumbers.get(acc.Provider_Customer_Number__c).Customer__c){
                    // Add the record for deletion and break the loop to proceed to the next record
                    forDeletion.put(acc.Id, new Account(Id = acc.Id));
                } 
                
                // Check whether record key matches with the set of keys in the map
                if (existingClients.containsKey(key) || existingBusinessAccs.containsKey(key)) {
                    // Add record for deletion
                    forDeletion.put(acc.Id, new Account(Id = acc.Id));
                    // Create provider code and set master to false given that existing account might have at least one customer provider code
                    accountProviders.add(new Customer_Provider_Code__c(Customer__c = existingClients.containsKey(key) ? existingClients.get(key).Id : existingBusinessAccs.get(key).Id,
                                                                        Name = acc.Provider_Customer_Number__c, Ext_Id__c = acc.Provider_Customer_Number__c, isMaster__c = false));
                } else {
                    // Create provider code and set master to true as this is a new account
                    accountProviders.add(new Customer_Provider_Code__c(Customer__c = acc.Id, Name = acc.Provider_Customer_Number__c, Ext_Id__c = acc.Provider_Customer_Number__c, isMaster__c = true));
                }
            }
        }
        
        if (!forDeletion.isEmpty()) {
            // Delete records
            Database.delete(forDeletion.values(), false);
        }
        
        if (!accountProviders.isEmpty()) {
            // Insert records
            Database.upsert(accountProviders, Customer_Provider_Code__c.Fields.Ext_Id__c, false);
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @date Dec 18, 2018
    *   @description Check for existing person accounts based on certain criteria.
    **/
    public static Map<String, Account> findExistingPersonAccounts(List<Account> newList){
        
        // Initialize variables
        Set<Id> newIds = new Set<Id>();
        Set<String> firstName = new Set<String>();
        Set<String> lastName = new Set<String>();
        Set<Date> DOB = new Set<Date>();
        Map<String, Account> existingAccounts = new Map<String, Account>();
        
        for(Account accRec : newList){
             if (accRec.isPersonAccount) {
                // Validate if lastname is not blank
                if(String.isNotBlank(accRec.Integration_Last_Name__pc)) {
                    lastName.add(accRec.Integration_Last_Name__pc);
                }
                
                // Validate if firstname is not blank
                if(String.isNotBlank(accRec.Integration_First_Name__pc)) {
                    firstName.add(accRec.Integration_First_Name__pc);
                }
                
                // Validate if date of birth is not null
                if(accRec.Integration_Birthdate__pc != null) {
                    DOB.add(accRec.Integration_Birthdate__pc);
                }
                
                newIds.add(accRec.Id);
            }
            
        }
        
        if (!(firstName.isEmpty() || lastName.isEmpty() || DOB.isEmpty())) {
            // Query existing person accounts that match the criteria.
            for(Account personAcc : [SELECT Id, Name, FirstName, LastName, PersonBirthdate FROM Account
                                    WHERE Id NOT IN :newIds AND isPersonAccount = true AND
                                    (FirstName IN :firstName AND LastName IN :lastName AND PersonBirthdate IN :DOB) LIMIT 50000]) {
                // Create a key
                String key = personAcc.FirstName + personAcc.LastName + personAcc.PersonBirthdate;
                
                existingAccounts.put(key, personAcc);
            }
        }
        
        return existingAccounts;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @date Dec 18, 2018
    *   @description Check for existing business accounts based on certain criteria.
    **/
    public static Map<String, Account> findExistingBusinessAccounts(List<Account> newList){
        
        // Initialize variables
        Set<Id> newIds = new Set<Id>();
        Set<String> names = new Set<String>();
        Map<String, Account> existingAccounts = new Map<String, Account>();
        
        for(Account accRec : newList){
            
            if(!accRec.isPersonAccount) {
                // Validate if name is not blank
                if(String.isNotBlank(accRec.Name)) {
                    names.add(accRec.Name);
                }
                
                newIds.add(accRec.Id);
            }
            
        }
        
        if (!names.isEmpty()) {
            // Query existing business accounts that match the criteria.
            for(Account acc : [SELECT Id, Name FROM Account
                                WHERE Id NOT IN :newIds AND isPersonAccount = false AND Name IN :names LIMIT 50000]) {
                
                existingAccounts.put(acc.Name, acc);
            }
        }
        
        return existingAccounts;
    }

    /**
     * Update Service Fields when Category Fields are changed
     */
    private void updateServiceFields() {
        ChangeCategory.updateServiceStandardFields(newAccounts);
    }

}