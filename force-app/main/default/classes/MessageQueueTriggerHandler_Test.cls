/***************************************************************************************************************************
 * Name:        MessageQueueTriggerHandler_Test
 * Description: MessageQueueTriggerHandler test class
 *
 * Version History
 * Date             Developer               Comments
 * -------------------  --------------------    --------------------------------------------------------------------------------
 * February 28, 2020       Alvin Aquino          Created
 ****************************************************************************************************************************/
@isTest
public class MessageQueueTriggerHandler_Test {
    
    @testSetup static void staticRecords(){
        //custom setting for trigger
        insert new Trigger_Manager__c(
            Message_Queue__c = true
        );
        
        insert new Apex_Admin_Settings__c(
            Sov_Policy_Delete_Script__c = 'SELECT Id, Name FROM Policy__c WHERE (Provider_External_ID__c like ' + '\''  + '%' + 'I'  + '%\''
            	+ ' AND Plan_Name__c = NULL) OR (Provider_External_ID__c like ' + '\''  + '%' + 'L'  + '%\'' + ' AND Plan_Name__c = NULL)'
        );
        
    }
    
    @isTest static void MessageQueueTriggerHandler_Test(){
        Test.StartTest();
        Intgr8inIT__Message_Queue__c mq = new Intgr8inIT__Message_Queue__c();
        mq.Intgr8inIT__Type__c = 'Event_Import_Completed';
        insert mq;
        Test.StopTest();
    }

}