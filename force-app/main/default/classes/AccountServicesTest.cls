/*************************************************************************************************************
 * @name			AccountServicesTest
 * @author			Ivanna Panchenko <ivanna@beIntelligent.nz>
 * @created			14th October 2021
 * @description	    Test class for AccountServices

 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-14      Ivanna Panchenko	    Creation of the class
 *
**************************************************************************************************************/
@IsTest
public with sharing class AccountServicesTest {
  //setup method
  @TestSetup
  static void setup(){
      Account newAcc = TestData.createPersonAccount(true, 'Homer');
      Opportunity opp = TestData.createOpportunity(true, newAcc.Id); 
  }

  @IsTest static void testCreateAccount() {
      Account acc = TestData.createPersonAccount(false, 'Loki');
      FlowOutput flow;
      Test.startTest();

        flow = AccountServices.upsertAccountFromSalestrekker(acc);
       
      Test.stopTest();

      System.assert(flow != null);
      System.assert(flow.success);
      

  }


}