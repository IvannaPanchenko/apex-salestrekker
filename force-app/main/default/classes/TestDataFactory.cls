/***************************************************************************************************************************
 * Name:        TestDataFactory
 * Description: reusable methods for test data setup for FXA
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2020-Feb-10        Alvin Aquino			Initial Version
 ****************************************************************************************************************************/

@isTest
public with sharing class TestDataFactory {
	//Create Policies
    public static List<Policy__c> createRiskPolicies(Integer numberOfPolicies){
        List<Policy__c> lstPolicy = new List<Policy__c>();
        for (Integer i = 0 ; i < numberOfPolicies ; i++ ) {
            Policy__c prec = new Policy__c(Name = 'Test Policy' + i, Type__c = 'Risk' );
            lstPolicy.add(prec);
        }
        return lstPolicy;  
    }
    
    //Create Policy Benefit
    public static List<Policy_Benefit__c> createRiskPolicies(Integer numberOfPBenefit, Id PersonInsured, Id PolicyId){
        List<Policy_Benefit__c> lstPBenefit = new List<Policy_Benefit__c>();
        for (Integer i = 0 ; i < numberOfPBenefit ; i++ ) {
            Policy_Benefit__c prec = new Policy_Benefit__c(Name = 'Test Policy Benefit' + i, Type__c = 'Life', Account__c = PersonInsured, Policy__c = PolicyId);
            lstPBenefit.add(prec);
        }
        return lstPBenefit;  
    }
    
    //create account
	public static List<Account> createPersonAccounts(Id recordTypeId, Integer numberOfAccounts) {
        List<Account> accountList = new List<Account>();
        for (Integer i = 0 ; i < numberOfAccounts ; i++ ) {
            Account a = new Account(recordTypeId = recordTypeId, firstname = 'Test Account' + i, lastname = 'Test Account' + i );
            accountList.add(a);
        }
        return accountList;
    }
    
    //create content version
    public static List<ContentVersion> createContentVersionList (Integer intContDocRecordCount) {
        List<ContentVersion> lstConVer = new List<ContentVersion>();
        for(Integer intI=0; intI<intContDocRecordCount; intI++){

            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
            lstConVer.add(new ContentVersion(
                ContentLocation = 'S',
                PathOnClient = 'sample' + intI + '.pdf',
                title='sample'+intI,
                VersionData = bodyBlob
                )
            );
            
        }
        return lstConVer;
    }
    
    //create content documentlink
    public static ContentDocumentLink createContentDocumentLink (Id DocumentId, Id LinkedEntityId) {
        List<ContentVersion> lstConVer = new List<ContentVersion>();
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId= LinkedEntityId;
        contentlink.ShareType= 'I'; 
        contentlink.ContentDocumentId=DocumentId;
        contentlink.Visibility = 'AllUsers'; 
        return contentlink;
    }




}