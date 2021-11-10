/**
* @author Pablo Martinez (pablomartinex@deloitte.co.nz)
* @date 05/07/2019
* @description Trigger on Liability Role.
*
* CHANGE LOG
**/
@IsTest
private class LiabilityRoleTriggerHandlerTest {

    @TestSetup
    static void makeData() {

        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();

        // Create new person account
        Account newAcc = new Account(
            FirstName = 'David',
            LastName = 'Catindoy',
            RecordTypeId = clientRecType,
            PersonEmail = 'david@cloudinit.nz'
        );
        insert newAcc;

        // create the customer provider code
        Customer_Provider_Code__c code = new Customer_Provider_Code__c(
            Customer__c = newAcc.Id,
            Name = 'SOVNZ4509652',
            Ext_Id__c = 'SOVNZ4509652',
            isMaster__c = true
        );
        // Create customer provider code
        insert code;

        // create liability
        Liability__c liability = new Liability__c(
            Name = 'CompleteInv. Variable Comm I/L',
            Status__c = 'Approved',
            Type__c = 'Investments',
            Current_Balance__c = 22437.48,
            External_Id__c = '570170-02I'
        );

        insert liability;

        // create role
        Liability_Role__c role = new Liability_Role__c(
                Customer_Number__c = 'SOVNZ4509652',
                Liability__r = new Liability__c(External_Id__c = '570170-02I')
        );

        insert role;
        
    }
    
    @IsTest
    static void testAssetRoleAssignment() {

        Test.startTest();

        Liability_Role__c role = [SELECT Id, Account__c, Customer_Number__c FROM Liability_Role__c LIMIT 1];

        // Assert values
        System.assertNotEquals(null, role.Account__c);
        System.assertEquals(null, role.Customer_Number__c);

        Test.stopTest();
    }
}