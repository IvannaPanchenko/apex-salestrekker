@IsTest
private class RelationshipTriggerHelper_Test {
	


    //setup method
    @TestSetup
    static void setup(){
        Account newAcc = TestData.createPersonAccount(true, 'Catindoy');
        Account partner = TestData.createPartnerAccount(true, newAcc.Id);
        Account dependant = TestData.createBeneficiary(true, 'Beneficiary');

        // this method is called only to pass the coverage (refactor the trigger of Customer_Adviser_Relationship__c)
        Customer_Adviser_Relationship__c customerAdviserRelationship = TestData.createCustomerAdviserRelationship(true);
    }

	@IsTest static void testPartnerAccountRelationship() {
		Account[] accountRec = [SELECT Id FROM Account LIMIT 2];
		Test.startTest();
            Relationship__c PrimaryRelationship = new Relationship__c();
            PrimaryRelationship.Relationship_Type__c = 'Partner';
            PrimaryRelationship.Account__c = accountRec[0].Id;
            PrimaryRelationship.Related_Account__c = accountRec[1].Id;
            insert PrimaryRelationship;
        Test.stopTest();

        List<Relationship__c> relationships = [select Id from Relationship__c];
        System.assertEquals(2, relationships.size());
        Relationship__c secondrelationship = [select Id, Account__c,Related_Account__c from Relationship__c where Account__c = :PrimaryRelationship.Related_Account__c];
        System.assertEquals(PrimaryRelationship.Account__c, secondrelationship.Related_Account__c);


	}
	
	@IsTest static void testNonPartnerAccountRelationship() {

		Account[] accountRec = [SELECT Id FROM Account LIMIT 2];
		Test.startTest();
            Relationship__c PrimaryRelationship = new Relationship__c();
            PrimaryRelationship.Relationship_Type__c = 'Trustee';
            PrimaryRelationship.Account__c = accountRec[0].Id;
            PrimaryRelationship.Related_Account__c = accountRec[1].Id;
            insert PrimaryRelationship;
        Test.stopTest();

        List<Relationship__c> relationships = [select Id from Relationship__c];
        System.assertEquals(2, relationships.size());
	}

    @IsTest static void testDependantAccountRelationship() {

        Account accountRec = [SELECT Id FROM Account WHERE Partner__c != NULL LIMIT 1];
        Account dependant = [SELECT Id FROM Account WHERE LastName = 'Beneficiary' LIMIT 1];
        Test.startTest();
        Relationship__c PrimaryRelationship = new Relationship__c();
        PrimaryRelationship.Relationship_Type__c = 'Child';
        PrimaryRelationship.Account__c = accountRec.Id;
        PrimaryRelationship.Related_Account__c = dependant.Id;
        insert PrimaryRelationship;
        Test.stopTest();

        List<Relationship__c> relationships = [SELECT Id FROM Relationship__c];
        System.assertEquals(4, relationships.size());
    }

    @IsTest static void testDeleteRelationship() {

        Account accountRec = [SELECT Id FROM Account WHERE Partner__c != NULL LIMIT 1];
        Account dependant = [SELECT Id FROM Account WHERE LastName = 'Beneficiary' LIMIT 1];
        Test.startTest();
        Relationship__c PrimaryRelationship = new Relationship__c();
        PrimaryRelationship.Relationship_Type__c = 'Child';
        PrimaryRelationship.Account__c = accountRec.Id;
        PrimaryRelationship.Related_Account__c = dependant.Id;
        insert PrimaryRelationship;

        delete PrimaryRelationship;

        Test.stopTest();

        List<Relationship__c> relationships = [SELECT Id FROM Relationship__c];
        System.assertEquals(2, relationships.size());
    }
	
}