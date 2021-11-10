@IsTest
public with sharing class PicklistsAsOptionsControllerTest {
    @TestSetup
    static void setup(){
        Account acc = TestData.createPersonAccount(true, 'Test');

        Opportunity opp = TestData.createOpportunity(true, acc.Id);
    }

    @IsTest
     static void testGetPicklistConfiguration() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Services__c = 'Health Insurance' LIMIT 1];
        Test.startTest();
        PicklistsAsOptionsController.PicklistConfiguration result = PicklistsAsOptionsController.getPicklistsConfiguration(opp.Id, 'Services__c',true);
        List<Opportunity> record = (List<Opportunity>) result.data;
        Test.stopTest();

        System.assertEquals('Health Insurance', record[0].Services__c, 'Must return Health Insurance as Services.');
        System.assertEquals(opp.Id, record[0].Id, 'Must return the same Id.');
        System.assertEquals('Services__c', result.picklists[0].fieldName, 'Must return the Services__c field in the picklists.');
        System.assertEquals(true, result.picklists[0].multipleSelection, 'Must return false in multipleSelection.');
        System.assertNotEquals(0, result.picklists[0].values.size(), 'Must return values for the picklist.');
     }

    @IsTest
    static void testGetPicklistConfigurationWrongFieldNameFailure() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Services__c = 'Health Insurance' LIMIT 1];

        try {
            PicklistsAsOptionsController.PicklistConfiguration result = PicklistsAsOptionsController.getPicklistsConfiguration(opp.Id, 'Services__cTest',false);
            System.assert(false, 'Expected the get PicklistsConfiguration request to fail');
        } catch (AuraHandledException ex) {
            System.assert(true, 'Expected the PicklistsConfiguration request to fail');
        }
    }

    @IsTest
    static void testGetPicklistConfigurationWrongFieldTypeFailure() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Services__c = 'Health Insurance' LIMIT 1];

        try {
            PicklistsAsOptionsController.PicklistConfiguration result = PicklistsAsOptionsController.getPicklistsConfiguration(opp.Id, 'Name', false);
            System.assert(false, 'Expected the get PicklistsConfiguration request to fail');
        } catch (AuraHandledException ex) {
            System.assert(true, 'Expected the PicklistsConfiguration request to fail');
        }
    }

    @IsTest
    static void testGetPicklistConfigurationNoFieldFailure() {
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Services__c = 'Health Insurance' LIMIT 1];

        try {
            PicklistsAsOptionsController.PicklistConfiguration result = PicklistsAsOptionsController.getPicklistsConfiguration(opp.Id, '',false);
            System.assert(false, 'Expected the get PicklistsConfiguration request to fail');
        } catch (AuraHandledException ex) {
            System.assert(true, 'Expected the PicklistsConfiguration request to fail');
        }
    }
}