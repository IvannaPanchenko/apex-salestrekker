trigger FactFindTrigger on Fact_Find__c ( before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after undelete) {


                                        /**
     * Run AccountTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Fact_Find__c) {

        new FactFindTriggerHandler().execute(Trigger_Manager__c.getInstance().Fact_Find__c);
        
    }

}