trigger OpportunityTrigger on Opportunity ( before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after undelete) {



    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Opportunity__c) {

        new OpportunityTriggerHandler().execute(Trigger_Manager__c.getInstance().Opportunity__c);
        
    }

}