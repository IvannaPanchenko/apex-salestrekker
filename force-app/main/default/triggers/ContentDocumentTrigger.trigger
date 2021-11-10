/**
 * CHANGE LOG
 * February 2020 - Add TriggerHandler extension (aaquino@deloitte.com)
 *
 */

trigger ContentDocumentTrigger on ContentDocument (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    /**
     * Run ContentDocumentTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Content_Document__c) {

        new ContentDocumentTriggerHandler().execute(Trigger_Manager__c.getInstance().Content_Document__c);
        
    }
    
}