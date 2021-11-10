/***************************************************************************************************************************
 * Name:        ContentDocumentTriggerHandler_Test
 * Description: ContentDocumentTriggerHandler test class
 *
 * Version History
 * Date             Developer               Comments
 * -------------------  --------------------    --------------------------------------------------------------------------------
 * February 10, 2020       Alvin Aquino          Created
 ****************************************************************************************************************************/
@isTest
public class ContentDocumentTriggerHandler_Test {
    @testSetup static void staticRecords(){
        //custom setting for trigger
        insert new Trigger_Manager__c(
            Content_Document__c = true
        );
        
        
        //get Client_Account recordtype id
        Id ClientAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        
        //create account
        List<Account> lstAccount = TestDataFactory.createPersonAccounts(ClientAccountRT, 1);
        for (Account acc: lstAccount){
            acc.PersonLeadSource = 'Purchased Lead';
        }
        insert lstAccount;
        
        //create content document
        List<ContentVersion> lstConver = TestDataFactory.createContentVersionList(1);
        insert lstConver;
        
        //create content documentlink
        List<ContentDocument> lstdocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(lstdocuments[0].Id, lstAccount[0].Id );
        insert cdl;
        
        //create compliance documents
        Compliance_Doc__c cdoc = new Compliance_Doc__c();
        cdoc.Content_Document_Id__c = lstdocuments[0].Id;
        insert cdoc;
    }
    
    @isTest static void ContentDocumentTriggerHandler_Test(){
        
        Test.StartTest();
        List<ContentDocument> lstdocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        delete lstdocuments;
        Test.StopTest();

    }
}