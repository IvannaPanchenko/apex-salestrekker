/**
* @author David Catindoy (david@cloudinit.nz)
* @date May 14, 2019
* @description Test class for AssetRoleTriggerHandler
*
* CHANGE LOG
**/
@isTest
private class AssetRoleTriggerHandlerTest {

    @TestSetup
    static void makeData() {

        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();

        Account newAcc = new Account(
            FirstName = 'David',
            LastName = 'Catindoy',
            RecordTypeId = clientRecType,
            PersonEmail = 'david@cloudinit.nz'
        );
        // Create new person account
        Database.insert(newAcc);

        Customer_Provider_Code__c code = new Customer_Provider_Code__c(
            Customer__c = newAcc.Id,
            Name = 'SOVNZ4509652',
            Ext_Id__c = 'SOVNZ4509652',
            isMaster__c = true
        );
        // Create customer provider code
        Database.insert(code);

        Client_Asset__c asset = new Client_Asset__c(
            Name = 'CompleteInv. Variable Comm I/L',
            Status__c = 'Existing',
            Type__c = 'Investments',
            Value__c = 22437.48,
            External_Id__c = '570170-02I'
        );

        Database.insert(asset);
        
    }
    
    @isTest
    static void testAssetRoleAssignment() {

        Test.startTest();

        Asset_Role__c role = new Asset_Role__c(
            Customer_Number__c = 'SOVNZ4509652',
            Asset__r = new Client_Asset__c(External_Id__c = '570170-02I')
        );

        Database.insert(role);

        role = [SELECT Id, Account__c, Customer_Number__c
                FROM Asset_Role__c WHERE Id =: role.Id];

        // Assert values
        System.assertNotEquals(null, role.Account__c);
        System.assertEquals(null, role.Customer_Number__c);

        Test.stopTest();
    }
}