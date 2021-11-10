/*************************************************************************************************************
 * @name			RetrieveTicketFromSalestrekker
 * @author			Panchenko Ivanna
 * @created			26th October 2021
 * @description		Class to retrieve ticket information from Salestrekker  
 * @testClass       RetrieveTicketFromSalestrekkerTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-26      Panchenko Ivanna	    Creation of the class
 *
**************************************************************************************************************/
public with sharing class RetrieveTicketFromSalestrekker implements Queueable, Database.AllowsCallouts {
    private Opportunity myOpportunity;
    private SalestrekkerTicket.UpdateTicket updateTicket;
  
    public RetrieveTicketFromSalestrekker( Opportunity myOpportunity) {
        this.myOpportunity = myOpportunity;
    }

    public void execute(QueueableContext context) {
        System.debug('#### RetrieveTicketFromSalestrekker');
        if(myOpportunity != null && (!String.isBlank(myOpportunity.Salestrekker_Deal_Id__c))){
            String ticketRequestBody = SalestrekkerTicket.queryTicketPayload(myOpportunity.Salestrekker_Deal_Id__c);
            System.debug(ticketRequestBody);
            HttpResponse httpTicketResponse = SalestrekkerService.salestrekkerSend(ticketRequestBody);
            // Only if it is was response we are going to update the deal
            if(ApexAkina_Constants.HTTP_SUCCESS == httpTicketResponse.getStatusCode()){
                System.debug('#### RetrieveTicketFromSalestrekker' + ApexAkina_Constants.HTTP_SUCCESS);
           
                SalestrekkerTicket.TopTicket tTicket = (SalestrekkerTicket.TopTicket)JSON.deserialize(httpTicketResponse.getBody(), SalestrekkerTicket.TopTicket.class);
                
                updateTicket = new SalestrekkerTicket.UpdateTicket();
                updateTicket.id = tTicket.data.ticket.id;
                updateTicket.ticket = new SalestrekkerTicket.InputTicket();
                updateTicket.ticket.idOwner =  tTicket.data.ticket.idOwner;
                updateTicket.ticket.idWorkflow = tTicket.data.ticket.idWorkflow;
                updateTicket.ticket.idStage = tTicket.data.ticket.idStage;
                updateTicket.ticket.idClients = tTicket.data.ticket.idClients;
                SalestrekkerTicket.TicketClientTypes ticketClientType = new SalestrekkerTicket.TicketClientTypes();
                ticketClientType.idContact = myOpportunity.Salestrekker_Contact_Id__c;
                updateTicket.ticket.ticketClientTypes = new List<SalestrekkerTicket.TicketClientTypes>{ticketClientType};
                updateTicket.ticket.name = tTicket.data.ticket.name;
                updateTicket.ticket.values = new SalestrekkerTicket.Values();
                updateTicket.ticket.values.onceOff = tTicket.data.ticket.values.onceOff;
                updateTicket.ticket.isInProgress =  false;
                updateTicket.ticket.isActive =  true;
                System.debug('######### opp stage '+ myOpportunity.StageName);
                if(ApexAkina_Constants.STAGE_BUSINESS_SETTLED.endsWithIgnoreCase(myOpportunity.StageName)){
                    System.debug('######### opp stage '+ ApexAkina_Constants.STAGE_BUSINESS_SETTLED);
                    updateTicket.ticket.isWon = true;
                    updateTicket.ticket.isSettled = true;
                    updateTicket.ticket.wonTimeStamp  = Datetime.now().getTime();
                   

                }

                if(ApexAkina_Constants.STAGE_NO_OPPORTUNITY.endsWithIgnoreCase(myOpportunity.StageName)){   
                    System.debug('######### opp stage '+ApexAkina_Constants.STAGE_NO_OPPORTUNITY);
                    updateTicket.ticket.lostTimeStamp  = Datetime.now().getTime();
                    updateTicket.ticket.isLost = true;
                    updateTicket.ticket.isSettled = false;

                }

             
                System.debug('@@@@@@ ticket'+updateTicket.ticket);

               UpdateTicketInSalestrekker updateTicket = new UpdateTicketInSalestrekker(updateTicket);
               Id jobId = System.enqueueJob(updateTicket);

              } else {
                Exception_Process_Event__c myException = new Exception_Process_Event__c();
                myException.Event_Type__c = ApexAkina_Constants.DEAL_RETRIEVED;
                myException.Name = 'RetrieveTicketFromSalestrekker';
                myException.Message__c = 'Received an unexpected response from Salestrekker ' +httpTicketResponse.getStatusCode()  ;
                myException.Severity__c = ApexAkina_Constants.SEV_LOW;
                myException.SFObjecId__c = myOpportunity.Id;
                myException.Description__c = 'Error when retrieve Deal information';

                Database.insert(myException);
            }

        }
    }

}