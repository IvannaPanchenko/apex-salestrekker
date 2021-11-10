@isTest(seeAllData=true)
public with sharing class MessageQueueMassDeletionBatchTest {

    @isTest static void testBatch(){

        DateTime startDT = System.today().addMonths(-13);
        DateTime endDT = System.today().addMonths(-10);

        Database.executeBatch(new MessageQueueMassDeletionBatch('Done',startDT,endDT),200);
    }
   
}