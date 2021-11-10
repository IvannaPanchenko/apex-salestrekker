/*************************************************************************************************************
 * @name			AccountCategorizationBatch
 * @author			Pablo Martinez <pablo@beintelligent.nz>
 * @created			06 / 10 / 2021
 * @TestClass       AccountCategorizationInvocableTest
 * @description		Batch Class to Categorize accounts
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-06		Pablo Martinez			Creation of the Class
 *
 **************************************************************************************************************/
public with sharing class AccountCategorizationBatch implements Database.Batchable<sObject>, Database.Stateful {
    // get the custom setting to use during the process
    private static Apex_Admin_Settings__c settings = Apex_Admin_Settings__c.getOrgDefaults();

    private final Id accountId;
    private final Datetime lastRunDate;
    private final Datetime endDate;
    private final String partnerStatus;
    private final Boolean continueProcessing;

    /*********************************************************************************************************
     * @name			Constructor
     * @author		    Pablo Martinez <pablo@beintelligent.nz>
     * @created			06 / 10 / 2021
     * @description	    Constructor of the class, initialize variables
     * @param			Id accountId: Id of the account to categorize
     * @param			Datetime lastRunDate : Datetime of the Last Scheduled Run
     * @param			Datetime endDate : End Datetime to filter the accounts that changed
     * @param			String partnerStatus : The type of the partner to filter
     * @param			Boolean continueProcessing : Flag to know if we still need to process data (Secondary Partners) or update the custom setting
     **********************************************************************************************************/
    public AccountCategorizationBatch(Id accountId, Datetime lastRunDate, Datetime endDate, String partnerStatus, Boolean continueProcessing) {
        this.accountId = accountId;
        this.lastRunDate = lastRunDate;
        this.endDate = endDate;
        this.partnerStatus = partnerStatus;
        this.continueProcessing = continueProcessing;
    }    
    
    /*********************************************************************************************************
     * @name			start
     * @author		    Pablo Martinez <pablo@beintelligent.nz>
     * @created			06 / 10 / 2021
     * @description	    Method that executes at the beginning of the batch process
     **********************************************************************************************************/
    public Database.querylocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, PersonMailingCountry, PersonOtherCountry, PersonMailingCity, PersonMailingPostalCode,' +
                                'PersonMailingState, PersonMailingStreet, PersonOtherCity, PersonOtherPostalCode,' +
                                'PersonOtherStreet, PersonOtherState, PersonMobilePhone, Phone, PersonOtherPhone,' +
                                'PersonHomePhone, PersonEmail, Other_Email__pc, Business_Email__c, Client_Type__pc,' +
                                'GNA__c, Total_Client_Assets__c, Total_Joint_Policy_Monthly_Premium__c, Partner__c,' +
                                'Total_Income__c, Occupation_Status__pc, Age__pc, Total_Premiums__c, Blank_Contact_Details__c,' +
                                'Blank_Financial_Details__c, Total_Combined_Partner_Assets__c, Category_Individual_Comparison_Value__c,' +
                                'Total_Household_Income__c, Total_Client_Liabilities__c, Total_Combined_Partner_Liabilities__c, ' +
                                'Category_Individual__c, Category__pc, Partner_Status__pc, ' +
                                'Partner__r.Category_Individual_Comparison_Value__c, Partner__r.Category_Individual__c, ' +
                                'Partner__r.Category__pc' +
                        ' FROM Account';                            

        // if we have an id use it, if not use the dates
        if (accountId != null) {
            query += ' WHERE Id = :accountId';
        } else {
            query += ' WHERE Partner_Status__pc = :partnerStatus AND LastModifiedDate >= :lastRunDate AND LastModifiedDate <= :endDate';
        }
  
        return Database.getQueryLocator(query);
    }
  
    /*********************************************************************************************************
     * @name			execute
     * @author		    Pablo Martinez <pablo@beintelligent.nz>
     * @created			06 / 10 / 2021
     * @description	    Method to execute with every batch
     **********************************************************************************************************/
    public void execute(Database.BatchableContext BC, List<Account> listAccounts) {
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();

        Savepoint sp = Database.setSavepoint();

        try {
            Map<String, Decimal> mapCategoryValue = new Map<String, Decimal>{ 'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5, 'Needs Review' => 6 };

            // for each account start the process
            for (Account account : listAccounts) {
                Account theAccountToUpdate = new Account( Id = account.Id );
                
                // =================================================================================================
                // Start categorization of the account
                // =================================================================================================
                // Category E
                if (account.Client_Type__pc == 'Non Serviced' || account.Client_Type__pc == 'Prospect' ||
                    account.Client_Type__pc == 'Deceased' || account.Client_Type__pc == 'Former' ||
                    account.Client_Type__pc == 'Archived' || account.Client_Type__pc == 'Inactive' || account.Client_Type__pc == null) {
                        theAccountToUpdate.Category_Individual__c = 'E';
                }
                // category D
                else if ((account.Age__pc > settings.Person_Account_Custom_Age__c && account.Total_Combined_Partner_Assets__c <= 0) || 
                        account.Occupation_Status__pc == 'Unemployed' ||
                        (account.PersonMailingCountry != 'New Zealand' && account.PersonMailingCountry != null) ||
                        (account.PersonOtherCountry != 'New Zealand' && account.PersonOtherCountry != null) ||
                        account.Blank_Financial_Details__c == true || 
                        account.Blank_Contact_Details__c == true) {
                        theAccountToUpdate.Category_Individual__c = 'D';
                }
                // Category A
                else if (account.Total_Joint_Policy_Monthly_Premium__c > 833.33 ||
                        account.Total_Combined_Partner_Assets__c >= 100000 ||
                        account.Total_Household_Income__c >= 150000 ||
                        account.Total_Combined_Partner_Liabilities__c > 750000) {
                        theAccountToUpdate.Category_Individual__c = 'A';
                }
                // Category B
                else if ((account.Total_Household_Income__c < 150000 && account.Total_Household_Income__c >= 100000) || 
                        (account.Total_Combined_Partner_Assets__c >= 20000 && account.Total_Combined_Partner_Assets__c < 100000) ||
                        (account.Total_Joint_Policy_Monthly_Premium__c < 833.33 && account.Total_Joint_Policy_Monthly_Premium__c > 416.67) ||
                        (account.Total_Combined_Partner_Liabilities__c >= 500000 && account.Total_Combined_Partner_Liabilities__c <= 750000)) {
                        theAccountToUpdate.Category_Individual__c = 'B';
                }
                // Category C
                else if ((account.Total_Household_Income__c < 100000 && account.Total_Household_Income__c >= 60000) || 
                        (account.Total_Combined_Partner_Assets__c < 20000 && account.Total_Combined_Partner_Assets__c > 0) ||
                        (account.Total_Joint_Policy_Monthly_Premium__c < 416.67 && account.Total_Joint_Policy_Monthly_Premium__c > 83.33) ||
                        (account.Total_Combined_Partner_Liabilities__c > 200000 && account.Total_Combined_Partner_Liabilities__c < 500000)) {
                        theAccountToUpdate.Category_Individual__c = 'C';
                }
                // Category D - Low Income
                else if ((account.Total_Household_Income__c > 0 && account.Total_Household_Income__c < 60000) || 
                        (account.Total_Joint_Policy_Monthly_Premium__c < 83.33 && account.Total_Joint_Policy_Monthly_Premium__c > 0) ||
                        (account.Total_Combined_Partner_Liabilities__c != 0 && account.Total_Combined_Partner_Liabilities__c <= 200000)) {
                        theAccountToUpdate.Category_Individual__c = 'D';
                }
                // Category E if no other matching criteria
                else {
                    theAccountToUpdate.Category_Individual__c = 'E';
                }
                // =================================================================================================
                // End categorization of the account
                // =================================================================================================

                // if we have a partner
                if (account.Partner__c != null) {
                    Account thePartnerToUpdate = new Account( Id = account.Partner__c );
                    // =================================================================================================
                    // Start categorization of the parent account and do the logic to set the right category to both
                    // =================================================================================================
                    Decimal valueToCompare = mapCategoryValue.containsKey(theAccountToUpdate.Category_Individual__c) ? mapCategoryValue.get(theAccountToUpdate.Category_Individual__c) : 7;
                    // Partner has lower category
                    if (account.Partner__r.Category_Individual_Comparison_Value__c >= valueToCompare) {
                        // Update Partner Category
                        thePartnerToUpdate.Category__pc = theAccountToUpdate.Category_Individual__c;

                        // Update Category of Account
                        theAccountToUpdate.Category__pc = theAccountToUpdate.Category_Individual__c;
                    } else {
                        // Partner has higher category - Skip Updating Partner.
                        // Update Account with Partner's Category
                        theAccountToUpdate.Category__pc = account.Partner__r.Category_Individual__c;
                        // Update Partner With Own Category
                        thePartnerToUpdate.Category__pc = account.Partner__r.Category_Individual__c;
                    }

                    // add the partner to the list for update
                    if (!accountsToUpdate.containsKey(account.Partner__c)) {
                        accountsToUpdate.put(account.Partner__c, thePartnerToUpdate);
                    }
                
                    // =================================================================================================
                    // End categorization of the parent account and do the logic to set the right category to both
                    // =================================================================================================
                } else {
                    // set the other category field with the same individual category
                    theAccountToUpdate.Category__pc = theAccountToUpdate.Category_Individual__c;
                }

                // add the main account to the map for update
                if (!accountsToUpdate.containsKey(account.Id)) {
                    accountsToUpdate.put(account.Id, theAccountToUpdate);
                }
            }

            // perform the update
            if (!accountsToUpdate.isEmpty()) {
                List<Database.SaveResult> sr = Database.update(accountsToUpdate.values(), false);
            }
        } catch (Exception e) {
            Database.rollback(sp);
        }
    }
  
    /*********************************************************************************************************
     * @name			finish
     * @author		    Pablo Martinez <pablo@beintelligent.nz>
     * @created			06 / 10 / 2021
     * @description	    Method to run after all the batches are processed
     **********************************************************************************************************/
    public void finish(Database.BatchableContext BC) {
        // if the account Id is null, process the secondary partner and 
        if (this.accountId == null) {
            if (this.continueProcessing) {
                Id batchInstanceId = Database.executeBatch(new AccountCategorizationBatch(null, this.lastRunDate, this.endDate, 'Secondary Partner', false), 200);
            } else {
                // update the custom setting and finish
                settings.Account_Categorization_Last_Run_Datetime__c = System.now();
                update settings;
            }
        }
    }
}