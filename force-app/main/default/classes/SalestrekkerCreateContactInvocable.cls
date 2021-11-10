/*************************************************************************************************************
 * @name			SalestrekkerCreateContact
 * @author			Rod Schmid <RodS@apexgroup.co.nz>
 * @created			10th September 2021
 * @description		Invocable Class to create contact in Salestrekker
 * @testClass       SalestrekkerCreateContactTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-10      Rod Schmid			    Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerCreateContactInvocable {

    @InvocableMethod
    public static void createContacts(List<AccountInput> inputs){
        for(AccountInput aI : inputs){
            SalestrekkerAsyncCreateContact sACC = new SalestrekkerAsyncCreateContact(aI.idOwner, aI.acc);
            Id jobId = System.enqueueJob(sACC);
        }
    }

    public class AccountInput{
        @InvocableVariable(Required=true Label='Salestrekker Owner Id' Description='Id of the Owner in Salestrekker')
        public String idOwner;

        @InvocableVariable(Required=true Label='Account' Description='Person Account to link to Salestrekker')
        public Account acc;
    }
}