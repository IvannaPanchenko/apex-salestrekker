/*************************************************************************************************************
 * @name			SalestrekkerCreateTicketInvocable
 * @author			James Winter
 * @created			16th September 2021
 * @description		Invocable Class to create ticket in Salestrekker
 * @testClass       SalestrekkerCreateTicketInvocableTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-16      James Winter			    Creation of the class
 *
**************************************************************************************************************/
public with sharing class SalestrekkerCreateTicketInvocable {

    @InvocableMethod
    public static void createTickets(List<DealInput> dealInputs){
        for(DealInput deal : dealInputs) {
            SalestrekkerAsyncCreateTicket sACT = new SalestrekkerAsyncCreateTicket(deal.idOwner, deal.idWorkflow, deal.idStage, deal.acc, deal.opp);
            Id jobId = System.enqueueJob(sACT);
        }
    }

    public class DealInput{

        @InvocableVariable(Required=true Label='Salestrekker Owner Id' Description='Id of the Owner in Salestrekker')
        public String idOwner;

        @InvocableVariable(Required=true Label='Salestrekker Workflow Id' Description='Id of the Workflow in Salestrekker')
        public String idWorkflow;

        @InvocableVariable(Required=true Label='Salestrekker Stage Id' Description='Id of the Stage in Salestrekker')
        public String idStage;

        @InvocableVariable(Required=true Label='Account' Description='Person Account to link to Salestrekker')
        public Account acc;

        @InvocableVariable(Required=true Label='Opportunity' Description='Opportunity to link to Salestrekker Deal')
        public Opportunity opp;

    }
}