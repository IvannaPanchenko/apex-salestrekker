@isTest
public with sharing class OpportunityTriggerHandlerTest {
    @TestSetup
    static void setup(){
        Account acc = TestData.createPersonAccount(true, 'Test');

        Opportunity opp = TestData.createOpportunity(true, acc.Id);

        dsfs__DocuSign_Status__c dsStatus =  TestData.createDSStatus(true,opp.Id, acc.Id);

        ContentVersion contentVersion = new ContentVersion(
          Title          = 'SOA Test',
          PathOnClient   = 'SOA Test.pdf',
          VersionData    = Blob.valueOf('Test PDF'),
          IsMajorVersion = true);

        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = dsStatus.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.visibility = 'AllUsers';

        insert cdl;

        insert new Trigger_Manager__c(Opportunity__c = true);
    }

    @isTest
    static void testSOASigned() {
 
        Opportunity opp = [SELECT Id, Docusign_Status__c FROM Opportunity];
        //set to SOA Signed
        opp.Docusign_Status__c = 'SOA Signed';

        Test.startTest();

        update opp;

        Test.stopTest();

    }
}