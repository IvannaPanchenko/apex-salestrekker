trigger KARTrigger on KAR__c ( before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after undelete,
                                    after delete) {


                                        /**
     * Run KARTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().KAR__c) {

        System.debug('\n\n\n kar trigger');
        new KARTriggerHandler().execute(Trigger_Manager__c.getInstance().KAR__c);
        
    }

}