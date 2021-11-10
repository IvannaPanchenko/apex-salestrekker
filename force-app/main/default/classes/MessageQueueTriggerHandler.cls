/**
* @author Alvin (aaquino@deloitte.com)
* @date Feb 13 2020
* @description Trigger handler for account trigger.
*
**/
public with sharing class MessageQueueTriggerHandler extends TriggerHandler{

    /**
     * TriggerHandler Extension
     *
     * @author Alvin Aquino
     * @date February 13, 2020
     */

    public List <Intgr8inIT__Message_Queue__c> lstMessageQueue{
        get {
            return (List <Intgr8inIT__Message_Queue__c> ) Trigger.New;
        }
        private set;
    }

    


    public override void beforeInsert() {
        schedulededupbatch(lstMessageQueue);
    }

    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Method to delete Compliance Document (Compliance_Doc__c) whose Content_Document_Id__c 
    *                value equal to the deleted Content Document
    **/
    public void schedulededupbatch(List<Intgr8inIT__Message_Queue__c> lstMessageQueue) {
        
        for(Intgr8inIT__Message_Queue__c mq: lstMessageQueue){
            if(mq.Intgr8inIT__Type__c == 'Event_Import_Started'){
                DateTime schedtime = system.now().addHours(8);

                String day = string.valueOf(schedtime.day());
                String month = string.valueOf(schedtime.month());
                String hour = string.valueOf(schedtime.hour());
                String minute = string.valueOf(schedtime.minute() + 1);
                String second = string.valueOf(schedtime.second());
                String year = string.valueOf(schedtime.year());
                String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

                PolicyDeduplicationBatchSched pdbs = new PolicyDeduplicationBatchSched();
                
                system.schedule('Policy Deduplication', strSchedule, pdbs);
            }
        }
    }
}