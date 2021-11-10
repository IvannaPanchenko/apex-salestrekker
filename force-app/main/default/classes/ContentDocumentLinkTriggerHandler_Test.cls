/***************************************************************************************************************************
 * Name:        ContentDocumentLinkTriggerHandler_Test
 * Description: ContentDocumentLinkTriggerHandler test class
 *
 * Version History
 * Date             Developer               Comments
 * -------------------  --------------------    --------------------------------------------------------------------------------
 * February 28, 2020       Alvin Aquino          Created
 ****************************************************************************************************************************/
@isTest
public class ContentDocumentLinkTriggerHandler_Test {
    
    @testSetup static void staticRecords(){
        //custom setting for trigger
        insert new Trigger_Manager__c(
            Content_Document_Link__c = true
        );
        
        //get custom metadata
        List<Compliance_Document_Type__mdt> lstcdt = [Select Id, MasterLabel, DeveloperName, Document_Name_Suffix__c, Document_Type_Group__c 
                                                      FROM Compliance_Document_Type__mdt];
        
        //get Client_Account recordtype id
        Id ClientAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        
        //create account
        List<Account> lstAccount = TestDataFactory.createPersonAccounts(ClientAccountRT, 1);
        for (Account acc: lstAccount){
            acc.PersonLeadSource = 'Purchased Lead';
        }
        insert lstAccount;
        
        //create content document
        List<ContentVersion> lstConver = TestDataFactory.createContentVersionList(2);
        lstConver[0].title = lstConver[0].title + lstcdt[0].Document_Name_Suffix__c;
        lstConver[1].title = lstConver[1].title + lstcdt[1].Document_Name_Suffix__c;
        insert lstConver;
        
        //create content documentlink
        List<ContentDocument> lstdocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create compliance documents
        Compliance_Doc__c cdoc = new Compliance_Doc__c();
        cdoc.Content_Document_Id__c = lstdocuments[0].Id;
        cdoc.Metadata_Id__c = lstcdt[0].Id;
        cdoc.Parent_Object_Id__c = lstAccount[0].Id;
        insert cdoc;

    }
    
    @isTest static void ContentDocumentLinkTriggerHandler_Test(){
        List<Account> lstAccount = [Select Id, Name FROM Account];
        List<ContentDocument> lstdocuments = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        Test.StartTest();
        ContentDocumentLink cdl = TestDataFactory.createContentDocumentLink(lstdocuments[0].Id, lstAccount[0].Id );
        insert cdl;
        ContentDocumentLink cdl2 = TestDataFactory.createContentDocumentLink(lstdocuments[1].Id, lstAccount[0].Id );
        insert cdl2;
        Test.StopTest();

    }

}