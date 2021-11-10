/***************************************************************************************************************************
 * Name:        PolicyDeduplicationBatch_Test
 * Description: PolicyDeduplicationBatch test class
 *
 * Version History
 * Date             Developer               Comments
 * -------------------  --------------------    --------------------------------------------------------------------------------
 * February 28, 2020       Alvin Aquino          Created
 ****************************************************************************************************************************/
@isTest

public class PolicyDeduplicationBatch_Test {
    @testSetup static void staticRecords(){
        //create Policies
        List<Policy__c> lstPolicy = TestDataFactory.createRiskPolicies(2);
        //First Record is Medical
        lstPolicy[0].type__c = 'Medical';
        lstPolicy[0].Provider_External_ID__c = '1234M';
        lstPolicy[0].Total_Premium__c =1000;
        lstPolicy[0].Policy_Number__c = '1234';
        
        //second Record is duplicate risk type
        lstPolicy[1].Provider_External_ID__c = '1234R';
        lstPolicy[1].Total_Premium__c =1000;
        lstPolicy[1].Policy_Number__c = '1234';
        
        insert lstPolicy;
        
        //get Client_Account recordtype id
        Id ClientAccountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client_Account').getRecordTypeId();
        
        //create account
        List<Account> lstAccount = TestDataFactory.createPersonAccounts(ClientAccountRT, 1);
        for (Account acc: lstAccount){
            acc.PersonLeadSource = 'Purchased Lead';
        }
        insert lstAccount;
        
        //create Policy Benefit
        List<Policy_Benefit__c> lstPBen  = TestDataFactory.createRiskPolicies(3, lstAccount[0].Id, lstPolicy[0].Id );
        insert lstPBen;
         
        
    }
     @isTest static void PolicyDeduplicationBatch_Test(){
    	PolicyDeduplicationBatch PDB = new PolicyDeduplicationBatch ();
        database.executebatch(PDB,50);
     }
}