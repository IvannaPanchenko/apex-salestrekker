trigger AdviceTrigger on Advice__c ( before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after undelete) {


    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Advice__c) {

        new AdviceTriggerHandler().execute(Trigger_Manager__c.getInstance().Advice__c);
        
    }

}