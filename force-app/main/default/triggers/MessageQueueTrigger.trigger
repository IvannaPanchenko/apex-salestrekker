/**
 * CHANGE LOG
 * February 2020 - Add TriggerHandler extension (aaquino@deloitte.com)
 *
 */
trigger MessageQueueTrigger on Intgr8inIT__Message_Queue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /**
     * Run ContentDocumentTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Message_Queue__c) {

        new MessageQueueTriggerHandler().execute(Trigger_Manager__c.getInstance().Message_Queue__c);
        
    }
}