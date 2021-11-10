@isTest
public class AccountTeamMemberTriggerHandlerTest {


    //setup method
    //@TestSetup
    //static void setup(){
       
       
    //}

	@IsTest static void testAccountTeamMemberDelete() {
        Test.startTest();
        Account newAcc = TestData.createPersonAccount(true, 'Smithington');
        Account partner = TestData.createPartnerAccount(true, newAcc.Id);
        User testUser = TestData.createUser();
        Relationship__c relationship = TestData.createRelationship(true, newAcc.Id, partner.Id, 'Partner', 'No');
        AccountTeamMember partnerAcctTeamMember = TestData.createAccountTeamMember(true, testUser.Id, partner.Id);
        
        AccountTeamMember acctTeamMember = TestData.createAccountTeamMember(true, testUser.Id, newAcc.Id);

       // acctTeamMember = [SELECT Id FROM AccountTeamMember];

         if(acctTeamMember != null){
            delete acctTeamMember;
        }
      
         

	        
        Test.stopTest();
       
    }
}