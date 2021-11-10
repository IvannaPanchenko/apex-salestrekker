/*************************************************************************************************************
 * @name			SFToSalestrekkerUpdateDeal
 * @author			Panchenko Ivanna
 * @created			26th October 2021
 * @description		Invocable Class to update ticket in Salestrekker
 * @testClass       SFToSalestrekkerUpdateDealTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-26      Panchenko Ivanna	    Creation of the class
 *
**************************************************************************************************************/
public with sharing class SFToSalestrekkerUpdateDeal{

    @InvocableMethod
    public static void updateDealInSalestrekker(List<DealInput> dealInputs){
        for(DealInput deal : dealInputs) {
            RetrieveTicketFromSalestrekker retrieveTicketInformation = new RetrieveTicketFromSalestrekker(deal.myOpportunity);
            Id jobId = System.enqueueJob(retrieveTicketInformation);
        }
    }


    public class DealInput{

        @InvocableVariable(Required=true Label='Opportunity Record' Description='Opportunity Record')
        public Opportunity myOpportunity;

    }
}