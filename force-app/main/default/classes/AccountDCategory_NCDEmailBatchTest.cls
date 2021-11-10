/**
 * @author Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date 24/09/2019
 */
@IsTest
public with sharing class AccountDCategory_NCDEmailBatchTest {

    @IsTest static void runBatchTest() {

        insert new Apex_Admin_Settings__c(
            Category_D_Email_Day_Limit__c = 7
        );

        User user = TestData.createUser();

        user.FirstName = 'Apex';
        user.LastName = 'Advice';
        update user;

        Account acc = TestData.createPersonAccount(false, 'Test');
        acc.Next_Contact_Date__pc = System.today().addDays(-2);
        acc.OwnerId = user.Id;
        acc.NCD_Send_Validated__c = true;
        acc.RecordTypeId = ApexAkina_Constants.ACC_CLIENTRECTYPE;
        acc.PersonHasOptedOutOfEmail = false;
        acc.Category__pc = 'D';
        acc.Client_Type__pc = 'Existing';
        acc.Annual_Email_Letter__pc = 'Client opt in';
        acc.Company_Ownership__c = 'AAG';
        acc.AccountSource = 'Book Buy';
        acc.book_buy_completed__pc = true;

        insert acc;

        Test.startTest();
        //new AccountDCategory_NCDEmailScheduler().execute(null);
        Test.stopTest();

        Account account = [SELECT Category_D_Email_Sent_Date__c, Call_Frequency__pc, Company_Ownership_Call_Frequency_Formula__c, Last_Contact_Date_Time__pc FROM Account WHERE Id = :acc.Id];

        //System.assertEquals(account.Category_D_Email_Sent_Date__c, System.today(), 'Category D Email Sent Date not get updated');
        //System.assertEquals(account.Call_Frequency__pc, account.Company_Ownership_Call_Frequency_Formula__c, 'Call Frequency not get updated');
        //System.assertEquals(account.Last_Contact_Date_Time__pc.format('yyyy-MM-dd'), System.now().format('yyyy-MM-dd'), 'Last Contact Date Time not get updated');
    }
}