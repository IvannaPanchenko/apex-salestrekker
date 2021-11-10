/**
 * Description
 * TestClass for PolicyCreateBenefitsController
 *
 * @author David Catindoy
 * @date Feb 25, 2019
 */
@isTest
private class PolicyCreateBenefitsControllerTest {
    
    // Setup
    @testSetup
    static void setup() {
        
        Id trauma = Schema.SObjectType.Policy_Benefit__c.getRecordTypeInfosByName().get('Trauma').getRecordTypeId();
	    
	    // Create person account
	    Account personAcc = TestData.createPersonAccount(true, 'Catindoy');
	    
	    // Create policy record
	    Policy__c policy = TestData.createPolicy(true);
	    
	    // Create policy benefits
	    Database.insert(
	        new List<Policy_Benefit__c>{
	            new Policy_Benefit__c(Name = 'Sample Trauma 1', RecordTypeId = trauma, Account__c = personAcc.Id, Policy__c = policy.Id),
	            new Policy_Benefit__c(Name = 'Sample Trauma 2', RecordTypeId = trauma, Account__c = personAcc.Id, Policy__c = policy.Id)
	        }
	    );
        
    }

    // Test benefits creation
    @isTest
	static void testBenefitCreation() {
	    
	    Id trauma = Schema.SObjectType.Policy_Benefit__c.getRecordTypeInfosByName().get('Trauma').getRecordTypeId();
	    
	    // Insert custom setting
	    Database.insert(new Policy_Benefits_Setting__c(Name = 'Trauma', Recordtype__c = trauma, Field_Sets_Name__c = 'Trauma', Order__c = 1));
	    
	    Test.startTest();
	    
	    // Initialize controller
	    PolicyCreateBenefitsController cont = new PolicyCreateBenefitsController(new ApexPages.StandardController([SELECT Id FROM Policy__c LIMIT 1]));
	    
	    System.assert(!cont.benefitsTypeFlag.isEmpty());
	    
	    cont.benefitType = new List<String>(cont.policyBenefits.keySet())[0]; 
	    
	    // Assert that there are 2 existing policy benefits
	    System.assertEquals(2, cont.policyBenefits.get(cont.benefitType).size());
	    cont.selectedId = new List<String>(cont.policyBenefits.get(cont.benefitType).keySet())[0];
	    
	    // Clone existing record
	    cont.cloneRecord();
	    
	    // Remove the first existing record
	    cont.removeRecord();
	    
	    cont.selectedId = new List<String>(cont.policyBenefits.get(cont.benefitType).keySet())[1];
	    
	    // Remove the clone
	    cont.removeRecord();
	    
	    // Create an empty record
	    cont.newRecord();
	    
	    // Save all records in the list
	    cont.saveRecords();
	    
	    // Assert that an error is encountered
	    System.assert(cont.getAllPageMessagesMap().size() > 0);
	    
	    Test.stopTest();

	}
	
	// Test no custom setting created
    @isTest
	static void testNoCustomSetting() {
	    
	    Test.startTest();
	    
	    // Initialize controller
	    PolicyCreateBenefitsController cont = new PolicyCreateBenefitsController(new ApexPages.StandardController([SELECT Id FROM Policy__c LIMIT 1]));
	    
	    // Assert that an error is encountered
	    System.assert(cont.getAllPageMessagesMap().size() > 0);
	    
	    Test.stopTest();

	}

}