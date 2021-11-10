/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 14, 2017
* @description Test class for ScopeofEngagementController
*
* CHANGE LOG
**/
@isTest
private class ScopeofEngagementControllerTest {
    
    //Setup method
    @testSetup
    static void setup(){
        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        Account newAcc = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = clientRecType);
        Database.insert(newAcc); //Create new person account
        
        //Insert new opportunity.
        Database.insert(new Opportunity(Name = 'David - Insurance', StageName = 'New', CloseDate = System.today()+30, AccountId = newAcc.Id, Benefits__c = 'Health Insurance',
                        Services__c = 'Health Insurance', Risk_Providers__c = 'AIA', Kiwisaver_Providers__c = 'AON', Investment_Providers__c = 'Synergy', Mortgage_Providers__c = 'ANZ'));
    }
    
    @isTest
	static void testScope() {
	    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ScopeofEngagementController controller = new ScopeofEngagementController(new ApexPages.StandardController(opp));
        controller.service.businessInsurance = true;
        controller.service.investmentPlanning = true;
        controller.saveRecord();
        
        opp = [SELECT Id, Services__c FROM Opportunity WHERE Id =: opp.Id];
        System.assertEquals('Business Insurance;Investment Planning;Health Insurance', opp.Services__c);
        
        controller.untickAll();
	}

}