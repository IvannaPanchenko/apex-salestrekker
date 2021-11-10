@IsTest
public class AccountCategorizationInvocableTest {
    @TestSetup
    static void setup() {
        // partner account
        Account partnerAccount = TestData.createPersonAccount(false, 'Partner');
        partnerAccount.Category__pc = 'B';
        partnerAccount.Category_Individual__c = 'B';

        insert partnerAccount;

        // main account
        Account mainAccount = TestData.createPersonAccount(false, 'Main');
        mainAccount.Client_Type__pc = 'Prospect';
        mainAccount.Category__pc = 'C';
        mainAccount.Category_Individual__c = 'C';
        mainAccount.Partner_Status__pc = 'Primary Partner';

        insert mainAccount;

        // relationship
        Relationship__c rel = TestData.createRelationship(true, mainAccount.Id, partnerAccount.Id, 'Partner', null);

        // main account with no partner
        Account mainAccountNoPartner = TestData.createPersonAccount(false, 'Main Alone');
        mainAccountNoPartner.Client_Type__pc = 'Prospect';
        mainAccountNoPartner.Category__pc = 'C';
        mainAccountNoPartner.Category_Individual__c = 'C';

        insert mainAccountNoPartner;

        // income for main account
        Income_and_Expense__c income = TestData.createIncome(false, mainAccount.Id);
        income.Amount__c = 150001;

        insert income;

        // income for main account without partner
        Income_and_Expense__c income2 = TestData.createIncome(false, mainAccountNoPartner.Id);
        income2.Amount__c = 150001;

        insert income2;
    }

    @IsTest
    static void testWithPartnerCategoryESuccess () {
        Account account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('E', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryDSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Occupation_Status__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        account.Occupation_Status__pc = 'Unemployed';
        update account;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('D', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryASuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('A', account.Category__pc);
        System.assertEquals('A', account.Category_Individual__c);
        System.assertEquals('A', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryBSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 100001;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('B', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryCSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 60001;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryDLowIncomeSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 10000;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('D', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testWithPartnerCategoryENotOtherCriteriaSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = -10;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('E', account.Category_Individual__c);
        System.assertEquals('B', account.Partner__r.Category__pc);
        System.assertEquals('B', account.Partner__r.Category_Individual__c);
    }

    @IsTest
    static void testCategoryESuccess () {
        Account account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('E', account.Category__pc);
        System.assertEquals('E', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryDSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Occupation_Status__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        account.Occupation_Status__pc = 'Unemployed';
        update account;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('D', account.Category__pc);
        System.assertEquals('D', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryASuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('A', account.Category__pc);
        System.assertEquals('A', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryBSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 100001;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('B', account.Category__pc);
        System.assertEquals('B', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryCSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 60001;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryDLowIncomeSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = 10000;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('D', account.Category__pc);
        System.assertEquals('D', account.Category_Individual__c);
    }

    @IsTest
    static void testCategoryENotOtherCriteriaSuccess () {
        Account account = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        account.Client_Type__pc = 'Existing';
        update account;

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :account.Id LIMIT 1];
        income.Amount__c = -10;
        update income;

        System.assertEquals('C', account.Category__pc);
        System.assertEquals('C', account.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.accountId = account.Id;

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });

        Test.stopTest();

        account = [SELECT Id, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        System.assertEquals('E', account.Category__pc);
        System.assertEquals('E', account.Category_Individual__c);
    }

    @IsTest
    static void testCategorizationByDatesSuccess () {
        Apex_Admin_Settings__c settings = new Apex_Admin_Settings__c();
        settings.Account_Categorization_Last_Run_Datetime__c = System.now().addMinutes(-30);
        settings.Person_Account_Custom_Age__c = 65;
        insert settings;

        Account accountAlone = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        Account accountWithPartner = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];
        Account partner = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Partner' LIMIT 1];
        partner.Client_Type__pc = 'Existing';
        update partner;
        

        Income_and_Expense__c income = [SELECT Id, Amount__c FROM Income_and_Expense__c WHERE Primary_Owner__c = :accountWithPartner.Id LIMIT 1];
        income.Amount__c = 100001;
        update income;

        System.assertEquals('C', accountWithPartner.Category__pc);
        System.assertEquals('C', accountWithPartner.Category_Individual__c);
        System.assertEquals('B', accountWithPartner.Partner__r.Category__pc);
        System.assertEquals('B', accountWithPartner.Partner__r.Category_Individual__c);
        System.assertEquals('C', accountAlone.Category__pc);
        System.assertEquals('C', accountAlone.Category_Individual__c);

        Test.startTest();

        AccountCategorizationInvocable.Input input = new AccountCategorizationInvocable.Input();
        input.dateToCheck = System.now().addMinutes(5);

        AccountCategorizationInvocable.categorizeAccounts(new List<AccountCategorizationInvocable.Input>{ input });
        
        Test.stopTest();

        accountAlone = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c FROM Account WHERE LastName = 'Main Alone' LIMIT 1];
        accountWithPartner = [SELECT Id, Client_Type__pc, Category__pc, Category_Individual__c, Partner__r.Category__pc, Partner__r.Category_Individual__c FROM Account WHERE LastName = 'Main' LIMIT 1];

        Apex_Admin_Settings__c newSettings = Apex_Admin_Settings__c.getOrgDefaults();

        System.assertEquals('B', accountWithPartner.Category__pc);
        System.assertEquals('E', accountWithPartner.Category_Individual__c);
        System.assertEquals('B', accountWithPartner.Partner__r.Category__pc);
        System.assertEquals('B', accountWithPartner.Partner__r.Category_Individual__c);
        System.assertEquals('E', accountAlone.Category__pc);
        System.assertEquals('E', accountAlone.Category_Individual__c);
        System.assert(settings.Account_Categorization_Last_Run_Datetime__c < newSettings.Account_Categorization_Last_Run_Datetime__c);
    }
}