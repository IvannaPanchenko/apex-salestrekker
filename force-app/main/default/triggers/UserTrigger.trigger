trigger UserTrigger on User (
    before insert, before update, before delete, 
    after insert, after update, after delete, after undelete
) {
    // Pass immediately to the Handler class for processing
    new UserTriggerHandler().execute(Trigger_Manager__c.getInstance().User__c);
}