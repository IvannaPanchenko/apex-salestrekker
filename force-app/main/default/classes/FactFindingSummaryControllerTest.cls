/**
* @author Pablo Martinez (pablomartinez@cdeloitte.co.nz)
* @date 12/08/2019
* @description
*
**/

@IsTest
public class FactFindingSummaryControllerTest {
//Setup method
    @TestSetup
    static void setup(){

        Test.startTest();
        // insert person account
        Account newAcc = TestData.createPersonAccount(true, 'Catindoy');

        // insert related accounts
        Account newRelatedAcc = TestData.createBeneficiary(true, 'Dependant');
        Account newRelatedAcc2 = TestData.createBeneficiary(true, 'NotDependant');

        // insert partner account
        Account partnerAccount = TestData.createPartnerAccount(true, newAcc.Id);

        // Insert legal entity
        Account legalEntity = TestData.createLegalEntityAccount(true);

        // Insert Provider account
        Account providerAccount = TestData.createBusinessAccountWithProviderId(true, 'Test Provider', 'test');

        // insert another person account
        Account newAcc2 = TestData.createPersonAccount(true, 'TestName');

        // insert new relationship
        Relationship__c relationship = TestData.createRelationship(true, newAcc.Id, newRelatedAcc.Id, 'Child', 'Yes');
        Relationship__c relationshipNotDependant = TestData.createRelationship(true, newAcc.Id, newRelatedAcc2.Id, 'Child', 'No');

        // insert new Employment
        Employment_Detail__c employmentDetail = TestData.createEmploymentDetail(true, newAcc.Id);

        // insert new Asset
        Client_Asset__c clientAsset = TestData.createAsset(true);
        Asset_Role__c assetRole = TestData.createAssetRole(true, clientAsset.Id, newAcc.Id);

        // insert new Liability
        Liability__c liability = TestData.createLiability(true, false);
        Liability_Role__c liabilityRole = TestData.createLiabilityRole(true, liability.Id, newAcc.Id);

        // insert new liability for policy
        Liability__c liability2 = TestData.createLiabilityForPolicy(true);
        Liability_Role__c liabilityRole2 = TestData.createLiabilityRole(true, liability2.Id, newAcc.Id);

        // insert new income
        Income_and_Expense__c income = TestData.createIncome(true, newAcc.Id);

        // insert new other entity relationship
        Relationship__c otherEntity = TestData.createRelationship(true, newAcc.Id, legalEntity.Id, 'Trustee', 'No');

        // insert policy
        Policy__c policy = TestData.createPolicyWithProviderAndStatus(true, providerAccount.Id, 'Existing');
        Policy__c policy2 = TestData.createPolicyWithProviderAndStatus(true, providerAccount.Id, 'Existing');

        // insert policy role
        Policy_Role__c policyRole = TestData.createPolicyRole(true, newAcc.Id, policy.Id);
        Policy_Role__c policyRole2 = TestData.createPolicyRole(true, newAcc2.Id, policy2.Id);

        // insert policy benefit
        Policy_Benefit__c policyBenefit = TestData.createPolicyBenefit(true, newAcc.Id, policy.Id);
        Policy_Benefit__c policyBenefit2 = TestData.createPolicyBenefit(true, partnerAccount.Id, policy.Id);
        Policy_Benefit__c policyBenefit3 = TestData.createPolicyBenefit(true, newAcc2.Id, policy.Id);

        // insert policy benefit for another account and another policy and same account other policy
        Policy_Benefit__c policyBenefit4 = TestData.createPolicyBenefit(true, newAcc.Id, policy2.Id);
        

        Test.stopTest();
    }

    @IsTest
    static void testGetData() {
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Account partnerAccount = [SELECT Id, Name FROM Account WHERE Partner__c = :client1Account.Id LIMIT 1];
        Relationship__c relationship = [SELECT Id, Related_Account__c, Relationship_Type__c, Account__c  FROM Relationship__c WHERE Account__c = :client1Account.Id AND Relationship_Type__c = 'Child' AND Dependant__c = 'Yes' LIMIT 1];
        Relationship__c relationshipNotDependant = [SELECT Id, Related_Account__c, Relationship_Type__c, Account__c  FROM Relationship__c WHERE Account__c = :client1Account.Id AND Relationship_Type__c = 'Child' AND Dependant__c = 'No' LIMIT 1];
        Account accountRelated = [SELECT Id, Name FROM Account WHERE Id = :relationship.Related_Account__c LIMIT 1];
        Account accountRelatedNotDependant = [SELECT Id, Name FROM Account WHERE Id = :relationshipNotDependant.Related_Account__c LIMIT 1];
        Account legalEntity = [SELECT Id, Name FROM Account WHERE Business_Email__c = 'testLegalEntity@testDomain.co.nz' LIMIT 1];
        Client_Asset__c asset = [SELECT Id, Name  FROM Client_Asset__c WHERE Id IN (SELECT Asset__c FROM Asset_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];
        Liability__c liability = [SELECT Id, Name  FROM Liability__c WHERE Personal_Guarantees__c = NULL AND Type__c = 'Investments' AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];
        Liability__c liabilityForPolicy = [SELECT Id, Name  FROM Liability__c WHERE Type__c = 'Mortgage Bond' AND Id IN (SELECT Liability__c FROM Liability_Role__c WHERE Account__c = :client1Account.Id) LIMIT 1];
        Income_and_Expense__c income = [SELECT Id, Type__c, Amount__c  FROM Income_and_Expense__c WHERE Primary_Owner__c = :client1Account.Id LIMIT 1];

        FactFindingSummaryController controller = new FactFindingSummaryController();

        Test.startTest();

        controller.mainAccountId = client1Account.Id;
        controller.partnerAccountId = partnerAccount.Id;
        controller.accountsAttr = new List<Account>{client1Account, partnerAccount};
        List<Non_Apex_Cover__c> nonApexCover = new FactFindingSummaryController().theNonApexCover;
        boolean mainAccountWaiverofPremium = new FactFindingSummaryController().mainAccountWaiverofPremium;
        boolean partnerAccountWaiverofPremium = new FactFindingSummaryController().partnerAccountWaiverofPremium;
        Map<Id, Account> mapAccountsByIds = new FactFindingSummaryController().mapAccountsByIds;

        System.assertEquals(new Fact_Find__c(), controller.theFactFind);
        System.assertEquals(2, controller.theAccounts.size());
        System.assertEquals(accountRelated.Name, controller.theDependants[0].account.Name);
        System.assertEquals(accountRelatedNotDependant.Name, controller.theOtherFamily[0].account.Name);
        System.assertEquals(legalEntity.Name, controller.theLegalEntities.get(legalEntity.Id).Name);
        System.assertEquals(0, controller.theGoals.size());
        System.assertEquals(1, controller.theAssets.size());
        System.assertEquals(asset.Name, controller.theAssets[0].asset.Name);
        System.assertEquals(1, controller.totalAssets);
        System.assertEquals(2, controller.theLiabilities.size());
        System.assertEquals(liability.Name, controller.theLiabilities[0].liability.Name);
        System.assertEquals(1, controller.totalLiabilities[0]);
        System.assertNotEquals(0, controller.theIncomesAndExpenses.get('Income').size());
        System.assertEquals(0, controller.netWorth);
        System.assertNotEquals(0 - income.Amount__c * 12, controller.disposableIncome);
        System.assertEquals(1, controller.listPolicyTypes.size());
        System.assertEquals(asset.Name, controller.listAssetsPolicies[0].Name);
        System.assertEquals(liabilityForPolicy.Name, controller.listLiabilitiesPolicies[0].Name);

        Test.stopTest();
    }

    @IsTest
    static void testIsEmpty() {
        Account client1Account = [SELECT Id, Name FROM Account WHERE LastName = 'Catindoy' LIMIT 1];
        Account partnerAccount = [SELECT Id, Name FROM Account WHERE Partner__c = :client1Account.Id LIMIT 1];

        FactFindingSummaryController controller = new FactFindingSummaryController();

        Test.startTest();

        controller.mainAccountId = client1Account.Id;
        controller.partnerAccountId = partnerAccount.Id;

        System.assertEquals(false, controller.getIsDependantEmpty());
        System.assertEquals(false, controller.getIsOtherFamilyEmpty());
        System.assertEquals(false, controller.getIsLegalEntitiesEmpty());
        System.assertNotEquals(true, controller.getIsIncomesEmpty());
        System.assertNotEquals(false, controller.getIsExpensesEmpty());
        System.assertEquals(false, controller.getIsAssetsEmpty());
        System.assertEquals(false, controller.getIsLiabilitiesEmpty());

        Test.stopTest();
    }
}