/**
* @author Ben Edwards (ben@cloudinit.nz)
* @date 14th December 2017
* @description Utility class for generating test data for test classes
*
* CHANGE LOG
**/
@isTest
public class TestData {
    public static final Id ACC_CLIENT_PERSON_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
    public static final Id ACC_BUSINESS_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Provider Account').getRecordTypeId();
    public static final Id ACC_BENEFICIARY_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Beneficiary').getRecordTypeId();
    public static final Id ACC_LEGALENTITY_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Legal Entity').getRecordTypeId();
    public static final Id FINANCIAL_RECTYPE = Schema.SObjectType.Goal__c.getRecordTypeInfosByName().get('Financial and Lifestyle').getRecordTypeId();

    // Instantiate a new user
    public static User newUser () {

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;

        return new User(
            ProfileId = profileID,
            Username = (math.random() + '@apextest.com'),
            FirstName = 'Snoop',
            LastName = 'Dogg',
            Email = (math.random() + '@apextest.com'),
            Alias = String.valueOf(math.random()).right(6),
            CommunityNickname = ('testComName' + math.random()),
            TimeZoneSidKey = 'Pacific/Auckland',
            LocaleSidKey = 'en_GB',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Signature_Image__c = '<img src="https://testimage.com/myimage.png" />'
        );
    }

    // Insert and return the new user
    public static User createUser () {

        User testUser = newUser();

        insert testUser;

        return testUser;
    }

    public static Lead newLead () {

        return new Lead(
            FirstName = 'Snoop',
            LastName = 'Dogg',
            Email = 'snoop@dogg.com',
            Status = 'Open',
            Type__c = 'Insurance',
            LeadSource = 'Admin'
        );
    }

    public static Lead createLead () {

        Lead testLead = newLead();

        insert testLead;

        return testLead;
    }

    public static Account newAccount () {

        return new Account(
            Name = 'Dogg Pound'
        );
    }

    public static Account createAccount () {

        Account testAccount = newAccount();

        insert testAccount;

        return testAccount;
    }

    public static Contact newContact () {

        return new Contact(
            FirstName = 'Snoop',
            LastName = 'Dogg',
            Email = 'snoop@dogg.com'
        );
    }

    public static Contact createContact (Id accountId) {

        Contact testContact = newContact();
        testContact.AccountId = accountId;

        insert testContact;

        return testContact;
    }

    // Enable the trigger custom settings
    public static void enableTriggers() {

        insert new Trigger_Manager__c(
            SetupOwnerId = System.UserInfo.getOrganizationId(),
            User__c = true
        );
    }

    public static Policy__c createPolicy(Boolean doInsert) {
        Policy__c policy = new Policy__c(
            Name = 'Policy Test',
            Plan_Name__c = 'Plan Name',
            Policy_Status__c = 'Not Proceeded',
            Policy_Comments__c = 'Comments',
            Type__c = 'Medical',
            Total_Premium__c = 1000
        );
        if (doInsert) {
            insert policy;
        }
        return policy;
    }

    public static Policy__c createPolicyWithProvider(Boolean doInsert, Id ProviderAccountId) {
        Policy__c policy = new Policy__c(
            Name = 'Policy Test',
            Plan_Name__c = 'Plan Name',
            Policy_Status__c = 'Not Proceeded',
            Policy_Comments__c = 'Comments',
            Type__c = 'Medical',
            Total_Premium__c = 1000,
            Provider__c = ProviderAccountId
        );
        if (doInsert) {
            insert policy;
        }
        return policy;
    }

    public static Policy__c createPolicyWithProviderAndStatus(Boolean doInsert,Id ProviderAccountId,String Status) {
        Policy__c policy = new Policy__c(
            Name = 'Policy Test',
            Plan_Name__c = 'Plan Name',
            Policy_Comments__c = 'Comments',
            Type__c = 'Medical',
            Total_Premium__c = 1000,
            Provider__c = ProviderAccountId,
            Policy_Status__c = Status
        );
        if (doInsert) {
            insert policy;
        }
        return policy;
    }

    public static Policy_Benefit__c createPolicyBenefit(Boolean doInsert, Id accountId, Id policyId) {
        Policy_Benefit__c benefit = new Policy_Benefit__c(
            Name = 'Test Benefit',
            Policy__c = policyId,
            Account__c = accountId,
            Status__c = 'Existing',
            Type__c = 'Trauma'
        );
        if (doInsert) {
            insert benefit;
        }
        return benefit;
    }

    public static Policy_Role__c createPolicyRole(Boolean doInsert, Id accountId, Id policyId) {
        Policy_Role__c role = new Policy_Role__c(
            Account__c = accountId,
            Policy__c = policyId,
            Policy_Type__c = 'Fire and General',
            Policy_Status__c = 'Existing',
            Policy_Total_Premium__c = 2000,
            Role__c = 'Owner'
        );
        if (doInsert) {
            insert role;
        }
        return role;
    }

    public static Account createPersonAccount(Boolean doInsert, String lastName) {
        Account account = new Account(
            RecordTypeId = ACC_CLIENT_PERSON_RT,
            FirstName = 'firstName',
            LastName = lastName,
            PersonEmail = 'test@testdata.co.nz',
            Partner_Status__pc = 'Primary Partner'
        );
        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Account createBusinessAccountWithProviderId(Boolean doInsert, String name, String ProviderId) {
        Account account = new Account(
            RecordTypeId = ACC_BUSINESS_RT,
            Name = name,
            Provider_Id__c = ProviderId
        );
        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Account createBusinessAccount(Boolean doInsert, String name) {
        Account account = new Account(
            RecordTypeId = ACC_BUSINESS_RT,
            Name = name
        );
        if (doInsert) {
            insert account;
        }
        return account;
    }


    public static Customer_Provider_Code__c createClientProviderCode(Boolean doInsert, Id accountId, String extId) {
        Customer_Provider_Code__c provider = new Customer_Provider_Code__c(
            Customer__c  = accountId,
            Ext_Id__c = extId,
            IsMaster__c = true
        );
        if (doInsert) {
            insert provider;
        }
        return provider;
    }

    public static Customer_Provider_Code__c createBusinessProviderCode(Boolean doInsert, Id accountId, String extId) {
        Customer_Provider_Code__c provider = new Customer_Provider_Code__c(
            //Provider__c = accountId
            Customer__c  = accountId,
            Ext_Id__c = extId,
            IsMaster__c = true
        );
        if (doInsert) {
            insert provider;
        }
        return provider;
    }

    public static Client_Asset__c createAsset (Boolean doInsert) {
        Client_Asset__c asset = new Client_Asset__c(
            Name = 'Test Asset',
            Type__c = 'Investments',
            Value__c = 1,
            Status__c = 'Existing',
            Serviced_by_Apex__c = true
        );
        if (doInsert) {
            insert asset;
        }
        return asset;
    }

    public static Asset_Role__c createAssetRole(Boolean doInsert, Id assetId, Id accountId) {
        Asset_Role__c assetRole = new Asset_Role__c(
            Asset__c = assetId,
            Account__c = accountId
        );
        if (doInsert) {
            insert assetRole;
        }
        return assetRole;
    }

    public static Liability__c createLiability(Boolean doInsert, Boolean contingent) {
        Liability__c liability = new Liability__c(
                Name = 'Test Liability' + (contingent ? ' - Contingent' : ''),
                Type__c = 'Investments',
                Current_Balance__c = 1,
                Status__c = 'Approved'
        );

        if (contingent) {
            liability.Personal_Guarantees__c = 'Yes';
        }

        if (doInsert) {
            insert liability;
        }
        return liability;
    }

    public static Liability__c createLiabilityForPolicy(Boolean doInsert) {
        Liability__c liability = new Liability__c(
                Name = 'Test Liability For Policy',
                Type__c = 'Mortgage Bond',
                Serviced_by_Apex__c = true,
                Status__c = 'Current'
        );

        if (doInsert) {
            insert liability;
        }
        return liability;
    }

    public static Liability_Role__c createLiabilityRole(Boolean doInsert, Id liabilityId, Id accountId) {
        Liability_Role__c liabilityRole = new Liability_Role__c(
                Liability__c = liabilityId,
                Account__c = accountId
        );
        if (doInsert) {
            insert liabilityRole;
        }
        return liabilityRole;
    }

    public static Income_and_Expense__c createIncome(Boolean doInsert, Id accountId) {

        Id incRTID = Schema.SObjectType.Income_and_Expense__c.getRecordTypeInfosByName().get('Income').getRecordTypeId();
        
        Income_and_Expense__c income = new Income_and_Expense__c(
                Amount__c = 99,
                Type__c = 'Annual Earnings(Self Employed)',
                Primary_Owner__c = accountId,
                RecordTypeId = incRTID
        );
        if (doInsert) {
            insert income;
        }
        return income;
    }

    public static Income_and_Expense__c createExpense(Boolean doInsert, Id accountId) {

        Id expRTID = Schema.SObjectType.Income_and_Expense__c.getRecordTypeInfosByName().get('Expenses').getRecordTypeId();

        Income_and_Expense__c expense = new Income_and_Expense__c(
                Amount__c = 99,
                Type__c = 'Other Expenses',
                Primary_Owner__c = accountId,
                RecordTypeId = expRTID
        );
        if (doInsert) {
            insert expense;
        }
        return expense;
    }

    public static Account createPartnerAccount(Boolean doInsert, Id accId) {
        Account account = new Account(
                FirstName = 'PartnerFirstName',
                LastName = 'PartnerLastName',
                RecordTypeId = ACC_CLIENT_PERSON_RT,
                PersonEmail = 'testPartner@testDomain.co.nz',
                Partner__c = accId,
                Partner_Status__pc = 'Secondary Partner'
        );

        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Account createLegalEntityAccount(Boolean doInsert) {
        Account account = new Account(
                Name = 'MyFirstName',
                RecordTypeId = ACC_LEGALENTITY_RT,
                Business_Email__c = 'testLegalEntity@testDomain.co.nz'
        );

        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Account createBeneficiary(Boolean doInsert, String lastName) {
        Account account = new Account (
                FirstName = 'John',
                LastName = lastName,
                RecordTypeId = ACC_BENEFICIARY_RT,
                PersonEmail = 'john@' + lastName + '.co.nz'
        );

        if (doInsert) {
            insert account;
        }
        return account;
    }

    public static Opportunity createOpportunity(Boolean doInsert, Id accId) {
        Opportunity opportunity = new Opportunity(
                Name = 'Test - Insurance',
                StageName = 'New',
                CloseDate = System.today()+30,
                AccountId = accId,
                Type = 'Insurance',
                Benefits__c = 'Health Insurance',
                Services__c = 'Health Insurance',
                Risk_Providers__c = 'AIA',
                Kiwisaver_Providers__c = 'AON',
                Investment_Providers__c = 'Synergy',
                Mortgage_Providers__c = 'ANZ',
                Letter_of_Authority_Scope__c = 'Existing application'
        );

        if (doInsert) {
            insert opportunity;
        }
        return opportunity;
    }

    public static Application_Role__c createApplicationRole(Boolean doInsert, Id accId, Id oppId) {
        Application_Role__c applicationRole = new Application_Role__c(
                Account__c = accId,
                Opportunity__c = oppId,
                Role__c = 'Primary Owner'
        );

        if (doInsert) {
            insert applicationRole;
        }
        return applicationRole;
    }

    public static Relationship__c createRelationship(Boolean doInsert, Id accId, Id relatedAccId, String type, String dependant) {
        Relationship__c relationship = new Relationship__c(
                Account__c = accId,
                Related_Account__c = relatedAccId,
                Relationship_Type__c = type,
                Dependant__c = dependant
        );

        if (doInsert) {
            insert relationship;
        }
        return relationship;
    }

    public static Employment_Detail__c createEmploymentDetail(Boolean doInsert, Id accId) {
        Employment_Detail__c employmentDetail = new Employment_Detail__c(
                Account__c = accId,
                Employer__c = 'Test Employer',
                Job_Title__c = 'Test Job Title',
                Current_Occupation__c = true
        );

        if (doInsert) {
            insert employmentDetail;
        }
        return employmentDetail;
    }

    public static Goal__c createGoal(Boolean doInsert, Id accId) {
        Goal__c goal = new Goal__c(
                Account__c = accId,
                RecordTypeId = FINANCIAL_RECTYPE,
                Section__c = 'Life Style Goals',
                Name = 'Retire',
                Comments__c = 'test'
        );

        if (doInsert) {
            insert goal;
        }
        return goal;
    }

    public static Referral__c createReferral(Boolean doInsert, Id accId) {
        Referral__c referral = new Referral__c(
                Name = 'Investment Adviser',
                Type__c = 'Investment Adviser',
                Notes__c = 'Test notes',
                Account__c = accId
        );

        if (doInsert) {
            insert referral;
        }
        return referral;
    }

    public static Customer_Adviser_Relationship__c createCustomerAdviserRelationship(Boolean doInsert) {
        Customer_Adviser_Relationship__c customerAdviserRelationship = new Customer_Adviser_Relationship__c(
                Adviser_Agency_Code__c = 'TEST123',
                Provider_Customer_Number__c = 'TEST123',
                Ext_Id__c = 'TEST123'
        );

        if (doInsert) {
            insert customerAdviserRelationship;
        }
        return customerAdviserRelationship;
    }


    public static AccountTeamMember createAccountTeamMember(Boolean doInsert, Id newuser, Id accountId) {
        AccountTeamMember acctTeamMember = new AccountTeamMember(
            UserId = newuser,
            AccountId = accountId,
            TeamMemberRole = 'Support',
            ContactAccessLevel = 'Edit',
            CaseAccessLevel = 'Edit',
            AccountAccessLevel = 'All'

        );
        if (doInsert) {
            insert acctTeamMember;
        }
        return acctTeamMember;
    }

    public static Fact_Find__c createFactFind(Boolean doInsert, Id acctId, String name) {

        Fact_Find__c factFind = new Fact_Find__c(
            Primary_Owner__c = acctId,
            Name = name
        );

        if (doInsert) {
            insert factFind;
        }
        return factFind;
    }

    public static Advice__c createAdvice(Boolean doInsert, Id oppId) {

        Advice__c advice = new Advice__c(
            Opportunity__c = oppId,
            Status__c = 'New'
        );

        if (doInsert) {
            insert advice;
        }
        return advice;
    }

    public static Non_Apex_Cover__c createNonApexCover(Boolean doInsert, Id acctId) {

        Non_Apex_Cover__c nac = new Non_Apex_Cover__c(
            Person_Insured__c = acctId,
            Benefit_Type__c = 'Life',
            Policy_Number__c = '123',
            Provider__c = 'AA',
            Value__c = 10

        );

        if (doInsert) {
            insert nac;
        }

        return nac;
    }

    public static dsfs__DocuSign_Status__c createDSStatus(Boolean doInsert, Id oppId, Id acctId){

        dsfs__DocuSign_Status__c  dsfs = new dsfs__DocuSign_Status__c();

		dsfs.dsfs__Company__c = acctId;
		dsfs.dsfs__Opportunity__c = oppId;
		dsfs.dsfs__Envelope_Status__c = 'Completed';
		dsfs.dsfs__DocuSign_Envelope_ID__c = '1000A23-1234-5678-1X84-X2Y12345Z678';
		dsfs.dsfs__Subject__c = 'Ready to sign Statement of Advice';

        if (doInsert) {
            insert dsfs;
        }

        return dsfs;
    }


}