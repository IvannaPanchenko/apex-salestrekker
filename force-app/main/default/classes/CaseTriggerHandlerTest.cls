/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         16/10/19
 * @description  CaseTriggerHandlerTest
 * 
 * CHANGE LOG
 * 16/10/19 - Initial Setup of CaseTriggerHandlerTest
 **/
@IsTest
private class CaseTriggerHandlerTest {

    @IsTest
    static void testBehavior() {

        // Trigger setup
        Trigger_Manager__c triggerManager = Trigger_Manager__c.getOrgDefaults();
        triggerManager.Case__c = true;
        insert triggerManager;

        // Admin setup
        Apex_Admin_Settings__c adminSettings = Apex_Admin_Settings__c.getOrgDefaults();
        insert adminSettings;

        // Get the EB RecordTypeId
        Id existingBusinessRecordTypeId = Case.getSObjectType()
                .getDescribe().getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId();

        // Account Setup
        Account theAccount = new Account(Name='Test Account');
        insert theAccount;

        // Case Setup
        Case theCase = new Case(AccountId=theAccount.Id, RecordTypeId=existingBusinessRecordTypeId);
        insert theCase;

        // Follow the Case
        EntitySubscription theEntitySubscription = new EntitySubscription(ParentId=theCase.Id, SubscriberId=UserInfo.getUserId());
        insert theEntitySubscription;

        Test.startTest();

        // Close the case
        theCase.Status = 'Closed';
        theCase.Sub_Status__c = 'No response';
        update theCase;

        Test.stopTest();

    }
}