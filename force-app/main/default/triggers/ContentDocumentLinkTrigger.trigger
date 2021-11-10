/**
 * CHANGE LOG
 * February 5, 2020 - Add TriggerHandler extension (aaquino@deloitte.com)
 *
 */
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    /**
     * Run ContentDocumentTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Content_Document_Link__c) {

        new ContentDocumentLinkTriggerHandler().execute(Trigger_Manager__c.getInstance().Content_Document_Link__c);
        
    }
    
}