public with sharing class MessageQueueMassDeletionBatch implements Database.Batchable<SObject> {

    String query, status;

    DateTime fromDate, toDate;

    public MessageQueueMassDeletionBatch(String status, DateTime fromDate, DateTime toDate){

        this.status = status;
        this.fromDate = fromDate;
        this.toDate = toDate;

        this.query = 'SELECT Id FROM Intgr8inIT__Message_Queue__c WHERE LastModifiedDate <=:toDate AND LastModifiedDate >=: fromDate AND Intgr8inIT__Status__c =:status';

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<Intgr8inIT__Message_Queue__c> scope) {

        delete scope;

    }

    public void finish(Database.BatchableContext BC) {

    
    }
    
    
}