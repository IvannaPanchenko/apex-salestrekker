trigger EmailMessageTrigger on EmailMessage (after insert) {
     
     if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().EmailMessage__c) {
          new EmailMessageTriggerHandler().execute(Trigger_Manager__c.getInstance().EmailMessage__c);
     }
}