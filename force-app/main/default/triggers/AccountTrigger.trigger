/**
 * CHANGE LOG
 * October 2018 - Add TriggerHandler extension (jayson@cloudinit.nz)
 *
 * @test AccountTriggerHandlerTest 
 */
trigger AccountTrigger on Account ( before insert,
                                    before update,
                                    before delete,
                                    after insert,
                                    after update,
                                    after undelete) {


    /**
     * Run AccountTriggerHandler
     */
    if (Trigger_Manager__c.getInstance() != null &&
        Trigger_Manager__c.getInstance().Account__c) {

        new AccountTriggerHandler().execute(Trigger_Manager__c.getInstance().Account__c);
        
    }
}