/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 14, 2017
* @description Test class for ChangeCategory apex class
*
* CHANGE LOG
* October 2018 - add deleteActionPlanTest (jayson@cloudinit.nz)
**/
@isTest
private class ChangeCategoryTest {

    //setup method
    @testSetup
    static void setup(){
        insert new Trigger_Manager__c(
            Account__c = true
        );

        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        Account newAcc = new Account(FirstName = 'Ivanna', LastName = 'Catindoy', RecordTypeId = clientRecType, Category__pc = 'D');
        Database.insert(newAcc);
    }

    //Category = 'E'
    @isTest
    static void testCategoryChange1() {
        Account accountRec = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
            accountRec.Category__pc = 'E';
            update accountRec;
        Test.stopTest();

        accountRec = [SELECT Id, ApexQuarterly_Newsletter__pc, Sale_Completed_Follow_up_Call__pc, End_of_the_Year_Email__pc, Annual_Phone_Call__pc, Apex_Desktop_Calendar__pc, Annual_Email_Letter__pc FROM Account WHERE Id =: accountRec.Id];

        System.assertEquals('N/A', accountRec.ApexQuarterly_Newsletter__pc);
    }

    //Category = 'A'
    @isTest
    static void testCategoryChange2() {
        Account accountRec = [SELECT Id FROM Account LIMIT 1];
        Database.insert(new Income_and_Expense__c(RecordTypeId = Schema.SObjectType.Income_and_Expense__c.getRecordTypeInfosByName().get('Income').getRecordTypeId(), Primary_Owner__c = accountRec.Id, Amount__c = 160000));

        Test.startTest();
            accountRec.Category__pc = 'A';
            update accountRec;
        Test.stopTest();

        accountRec = [SELECT Id, ApexQuarterly_Newsletter__pc, Sale_Completed_Follow_up_Call__pc, End_of_the_Year_Email__pc, Annual_Phone_Call__pc, Apex_Desktop_Calendar__pc, Annual_Email_Letter__pc FROM Account WHERE Id =: accountRec.Id];

        System.assertEquals(Label.Service_Schedule_Value, accountRec.ApexQuarterly_Newsletter__pc);
    }


}