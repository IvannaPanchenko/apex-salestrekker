/*************************************************************************************************************
 * @name			AccountCategorizationInvocable
 * @author			Pablo Martinez <pablo@beintelligent.nz>
 * @created			28 / 05 / 2021
 * @description		Class with an Invocable method to categorize one or more accounts
 * @testClass		AccountCategorizationInvocableTest
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-05-28		Pablo Martinez			Creation of the class
 *
**************************************************************************************************************/
public without sharing class AccountCategorizationInvocable {
    
    // get the custom setting to use during the process
    public static Apex_Admin_Settings__c settings = Apex_Admin_Settings__c.getOrgDefaults();

    /*********************************************************************************************************
     * @name			categorizeAccounts
     * @author			Pablo Martinez <pablo@beintelligent.nz>
     * @created			28 / 05 / 2021
     * @description		Method that categorize accounts given certain criteria. 
     *                  SCENARIOS:
     *                      1) This method is used by scheduled flows to categorize all the accounts that were changed
     *                        since the last run up to the sent datetime or Current Datetime minus 1 minute
     *                      2) It's also called by a flow in account to categorize only that account.
     * @param			List<Input> input : List of inputs with following properties
     *                                          - Id accountId: Id of the account to categorize (SCENARIO 1)
     *                                          - Datetime dateToCheck: End change Datetime to check (SCENARIO 2)
     * @return			void
    **********************************************************************************************************/
    @InvocableMethod(label = 'Categorization of the Accounts')
    public static void categorizeAccounts(List<Input> input) {
        Datetime startProcessDatetime = System.now();
        Datetime theDateTime = input[0].dateToCheck != null ? input[0].dateToCheck : startProcessDatetime.addMinutes(-1);
        Datetime lastRunDateTime = settings.Account_Categorization_Last_Run_Datetime__c;
        Id theId = input[0].accountId;

        // if it's a schedule run, do first the primary partners and then the secondary, otherwise process the id
        if (theId == null) {
            // run the renew in batches of 200 and return
            Id batchInstanceId = Database.executeBatch(new AccountCategorizationBatch(null, lastRunDateTime, theDateTime, 'Primary Partner', true), 200);
        } else {
            Id batchInstanceId = Database.executeBatch(new AccountCategorizationBatch(theId, null, null, null, false), 1);
        }
    }

    // public wrapper class for input variables
    public class Input {
        @InvocableVariable(label = 'Account Id' description = 'Id of the account to process. Optional. Used when user wants to categorize only one account.')
        public Id accountId;

        @InvocableVariable(label = 'End Changed date' description = 'End datetime to check for the last modified date. Optional. By default is 1 minute before current datetime.')
        public Datetime dateToCheck;
    }
}