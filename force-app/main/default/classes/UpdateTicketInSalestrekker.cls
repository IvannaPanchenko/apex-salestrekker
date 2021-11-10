/*************************************************************************************************************
 * @name			UpdateTicketInSalestrekker
 * @author			Panchenko Ivanna
 * @created			26th October 2021
 * @description		Class to update the ticket deal in Salestrekker
 * @testClass       UpdateTicketInSalestrekkerTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-26      Panchenko Ivanna	    Creation of the class
 *
**************************************************************************************************************/
public with sharing class UpdateTicketInSalestrekker implements Queueable, Database.AllowsCallouts{

    private SalestrekkerTicket.UpdateTicket updateTicket;
    
    public UpdateTicketInSalestrekker(SalestrekkerTicket.UpdateTicket updateTicket) {

        this.updateTicket = updateTicket;

    }


    public void execute(QueueableContext context) {
        System.debug('######### UpdateTicketInSalestrekker ');
        if(updateTicket.id != null){
            String ticketRequestBody = SalestrekkerTicket.updateTicketPayload(updateTicket);

            HttpResponse httpResponse = SalestrekkerService.salestrekkerSend(ticketRequestBody);
            
            if(ApexAkina_Constants.HTTP_SUCCESS == httpResponse.getStatusCode()) {
                System.debug('######### '+ApexAkina_Constants.HTTP_SUCCESS);  
                System.debug(httpResponse.getBody());
                //prepare response
                Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                Map<String, Object> data = (Map<String, Object>) body.get('data');
    
                String stDealId = (String) data.get('ticketUpdate');
                // myOpportunity.Salestrekker_Deal_Id__c = stDealId;
                // updateList.add(myOpportunity);
    
            } else {
                Exception_Process_Event__c myException = new Exception_Process_Event__c();
                myException.Event_Type__c = ApexAkina_Constants.DEAL_UPDATED;
                myException.Name = 'UpdateTicketInSalestrekker';
                myException.Message__c = 'Received an unexpected response from Salestrekker: ';
                myException.Severity__c = ApexAkina_Constants.SEV_HIGH;
                myException.SalestrekkerObjecId__c = updateTicket.id;
                myException.Description__c = 'Error while updating a Deal information '+ httpResponse.getBody() ;
                System.debug('######### httpResponse: '+httpResponse.getBody());  
                Database.insert(myException);
            }
        }
    }
}