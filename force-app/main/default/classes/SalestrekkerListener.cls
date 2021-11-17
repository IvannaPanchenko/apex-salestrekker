/*************************************************************************************************************
 * @name			SalestrekkerListener2
 * @author			James Winter <james@beintelligent.nz>
 * @created			21st September 2021
 * @description		Class to listen to webhook requests from Salestrekker
 * @testClass       SalestrekkerListenerTest todo
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-21      James Winter			Creation of the class
 *
**************************************************************************************************************/

@RestResource(UrlMapping='/STListener/*')
global with sharing class SalestrekkerListener {
    @TestVisible private static List<Salestrekker_Event2__e> eventList = new List<Salestrekker_Event2__e>();

    @HttpPost
    global static void doPost(){
        System.debug('####### SalestrekkerListener');
        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String, Object> body = new Map<String, Object>();
        String id;
        String event;
        String orgId;

        Map<String, String> headers = req.headers;

        //Get the Salestrekker event
        if(headers.containsKey('Content-Type') && headers.get('Content-Type').equals('application/json')) {
            body = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        }

        if(body.containsKey('id') && body.containsKey('event')) {
            id = (String)body.get('id');
            event = (String)body.get('event');
            response.statusCode = ApexAkina_Constants.HTTP_SUCCESS;

              // Deal Creation or update from ST - New Opportunity 
           if( ApexAkina_Constants.DEAL_CREATED.equalsIgnoreCase(event) || 
              ApexAkina_Constants.DEAL_CHANGE_STAGE.equalsIgnoreCase(event) ) {
              getSalestrekkerTicketDetails(id, event);
            }

        } else {
            response.statusCode = ApexAkina_Constants.HTTP_ERROR;
            response.addHeader('Content-Type', 'application/json');
            response.responseBody = Blob.valueOf('This request was not able to be processed.');
        }

    }

    @Future(Callout=true)
    public static void getSalestrekkerTicketDetails(String ticketId, String eventType) {
        
        String ticketRequestBody = SalestrekkerTicket.queryTicketPayload(ticketId);
        HttpResponse httpTicketResponse = SalestrekkerService.salestrekkerSend(ticketRequestBody);
        SalestrekkerTicket.TopTicket tTicket = (SalestrekkerTicket.TopTicket)JSON.deserialize(httpTicketResponse.getBody(), SalestrekkerTicket.TopTicket.class);
        Salestrekker_Event2__e st2Event = new Salestrekker_Event2__e(Ticket_Id__c=ticketId, Event_Type__c=eventType,
                Ticket_Id_Owner__c=tTicket.data.ticket.idOwner, Ticket_Id_WorkFlow__c=tTicket.data.ticket.idWorkflow,
                Ticket_Id_Stage__c=tTicket.data.ticket.idStage, Ticket_Id_Client__c=tTicket.data.ticket.idClients[0],
                Ticket_Name__c=tTicket.data.ticket.name, Ticket_Description__c=tTicket.data.ticket.description, AmountDeal__c = tTicket.data.ticket.values.onceOff );
        
        // add labels if it has 
        if(!tTicket.data.ticket.idLabels?.isEmpty()){
            String ids = string.join(tTicket.data.ticket.idLabels,',');
            st2Event.IdLabels__c = ids;     
        }

        if(String.isNotBlank(tTicket.data?.ticket?.idClients[0])) {
            String contactRequestBody = SalestrekkerContact.queryContactPayload(tTicket.data.ticket.idClients[0]);
            HttpResponse httpContactResponse = SalestrekkerService.salestrekkerSend(contactRequestBody);
            SalestrekkerContact.TopContact tContact = (SalestrekkerContact.TopContact)JSON.deserialize(httpContactResponse.getBody(), SalestrekkerContact.TopContact.class);
            st2Event.Contact_Id__c=tTicket.data.ticket.idClients[0];
            st2Event.Contact_Id_Owner__c=tContact.data.contact.idOwner;
            st2Event.Contact_First_Name__c=tContact.data.contact.person.information.firstName;
            st2Event.Contact_Family_Name__c=tContact.data.contact.person.information.familyName;

        }

        eventList.add(st2Event);

        List<Database.SaveResult> results = EventBus.publish(eventList);
        Boolean success= true;
        for(Database.SaveResult result: results){

            
            if(!result.success){
                success = false;
                System.debug('########### error '+ result.getErrors().get(0));
            }
        }

        if (success) {
            // Update Assets, Liabilities etc in Salesforce
            // If it is update deal from salestrekker we update the assets on Salesforce with they salestrakker id and contact Id 
            if( ApexAkina_Constants.DEAL_CHANGE_STAGE.equalsIgnoreCase(eventType))
            {
                // Only update the asset if the ticket are in the following stages 1. Initial Enquiry, 2. Invite to Client Portal/Client Data Upload, 3. Appointment/Meeting
                List<Salestrekker_Stage_Information__mdt> stagesInformation = [SELECT 	Salestrekker_Stage_Name__c, Salestrekker_Stage_Id__c, MasterLabel
                                                                               FROM  Salestrekker_Stage_Information__mdt 
                                                                               WHERE  Salestrekker_Stage_Id__c =: tTicket.data.ticket.idStage];

                if (stagesInformation?.size() >0) {
                    
                    String label = stagesInformation.get(0).MasterLabel;

                    if (ApexAkina_Constants.INITIAL_ENQUIRY.equalsIgnoreCase(label) ||
                        ApexAkina_Constants.INVITE_TO_CLIENT_PORTAL_CLIENT_DATA_UPLOAD.equalsIgnoreCase(label) ||
                        ApexAkina_Constants.APPOINTMENT_MEETING.equalsIgnoreCase(label)) {
                        // Update Assets 
                        if  ( tTicket.data?.ticket?.assets?.size()> 0 ) {  
                            String clientId = String.valueOf(tTicket.data.ticket.idClients[0]);
                            AssetServices.processAssetFromSalestrekker(tTicket.data.ticket.assets, ticketId, clientId );
                        }
                        
                    }

                }    
             }     
        }
       
    }

}