/**
 * Description
 * Retreives all Sovereign policy benefits and deletes them
 *
* @author Jacob Taljaard
* @date December 2018
* @test SovFeed_Benefits_Schedule_Test
*
* Version      Author                  Date                Description
* 1.0          Jacob Taljaard          Dec 2018            Initial Draft
* 2.0          Siddharth (Deloitte)    17 April 2019       JIRA AP2-23 Addition of Invocable Method
*/
global without sharing class SovFeed_Benefits_Delete_Batch implements Database.Batchable<sObject> {

    private Apex_Admin_Settings__c adminsettings = Apex_Admin_Settings__c.getInstance();
    private List<String> ProviderIds = new List<String>();
    

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String benefitsQueryString = adminsettings.Sov_Policy_Benefit_Delete_Script__c;
        return Database.getQueryLocator(benefitsQueryString);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        try {
            database.delete(scope);
        } catch (DMLException e) {
            System.debug('SovFeed_Benefits_Delete_Batch error ' + e);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }

    //Sid 2.0
    //Method to be invoked from the process builder which would invoke the Batch Class
    @InvocableMethod
    public static void invokeBenefitsDeleteBatch(){
        Database.executeBatch(new SovFeed_Benefits_Delete_Batch());
    }
}