trigger CaseTrigger on Case (before insert,
							 before update,
							 before delete,
							 after insert,
							 after update,
							 after undelete) {

	
	/**
     * Run CaseTriggerHandler
     */
	if (Trigger_Manager__c.getInstance() != null && Trigger_Manager__c.getInstance().Case__c) {
		new CaseTriggerHandler().execute(Trigger_Manager__c.getInstance().Case__c);
	}

}