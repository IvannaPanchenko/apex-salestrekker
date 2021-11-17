/**
 * Created by jameswinter on 17/09/21.
 */

public without sharing class SalestrekkerAsyncCreateTicket implements Queueable, Database.AllowsCallouts {

    private String idOwner;
    private String idWorkflow; //Move to custom settings?
    private String idStage;    //Move to custom settings?
    private Account myAccount;
    private Opportunity myOpportunity;

    public SalestrekkerAsyncCreateTicket(String idOwner, String idWorkflow, String idStage, Account myAccount, Opportunity myOpportunity) {
        this.idOwner = idOwner;
        this.idWorkflow = idWorkflow;
        this.idStage = idStage;
        this.myAccount = myAccount;
        this.myOpportunity = myOpportunity;
    }

    public void execute(QueueableContext context) {
        List<SObject> updateList = new List<SObject>();

        System.debug('################ salestrekker contact id '+ myAccount.Salestrekker_Contact_Id__c);
        if(String.isBlank(myAccount.Salestrekker_Contact_Id__c)) {
            String stContactId = SalestrekkerCreateContact.createContact(idOwner, myAccount);
            myAccount.Salestrekker_Contact_Id__c = stContactId;
            updateList.add(myAccount);
        }

        SalestrekkerTicket.CreateTicket createTicket = new SalestrekkerTicket.CreateTicket();
        createTicket.ticket = new SalestrekkerTicket.InputTicket();
        createTicket.ticket.idOwner = idOwner;
        createTicket.ticket.isActive = true;
        createTicket.ticket.idWorkflow = idWorkflow;
        createTicket.ticket.idStage = idStage;
        createTicket.ticket.idClients = new List<String>{myAccount.Salestrekker_Contact_Id__c};
        SalestrekkerTicket.TicketClientTypes ticketClientType = new SalestrekkerTicket.TicketClientTypes();
        ticketClientType.idContact =  myAccount.Salestrekker_Contact_Id__c;
        createTicket.ticket.ticketClientTypes = new List<SalestrekkerTicket.TicketClientTypes>{ticketClientType};
        createTicket.ticket.name = myOpportunity.Name;
        createTicket.ticket.description = myOpportunity.Description;
        createTicket.ticket.values = new SalestrekkerTicket.Values();
        createTicket.ticket.values.onceOff = myOpportunity.Amount != null ? myOpportunity.Amount : 0;
        createTicket.ticket.assets = AssetServices.getSalestrekkerAssetInputByAccountId(myAccount.Id, myAccount.Salestrekker_Contact_Id__c);

        String ticketRequestBody = SalestrekkerTicket.createTicketPayload(createTicket);

        HttpResponse httpResponse = SalestrekkerService.salestrekkerSend(ticketRequestBody);
        if(ApexAkina_Constants.HTTP_SUCCESS == httpResponse.getStatusCode()) {
            //prepare response
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
            Map<String, Object> data = (Map<String, Object>) body.get('data');

            String stDealId = (String) data.get('ticketCreate');
            myOpportunity.Salestrekker_Deal_Id__c = stDealId;
            myOpportunity.Salestrekker_Contact_Id__c = myOpportunity.Salestrekker_Contact_Id__c ==  null ? myAccount.Salestrekker_Contact_Id__c : myOpportunity.Salestrekker_Contact_Id__c;
            updateList.add(myOpportunity);

            // create note in salestrekker
            SalestrekkerNote.CreateNote noteDetails = new SalestrekkerNote.CreateNote();
            noteDetails.note.idOwner = idOwner;
            noteDetails.note.idTicket = stDealId;
            noteDetails.note.idWorkflow = idWorkflow; // ask if it is necesary
            noteDetails.note.isActive = true;
            noteDetails.note.content = myOpportunity.Description;
            noteDetails.note.type = new NoteTypeEnumerator();

            String noteRequestBody = SalestrekkerNote.createNotePayload(noteDetails);

            httpResponse = SalestrekkerService.salestrekkerSend(noteRequestBody);

            if(ApexAkina_Constants.HTTP_SUCCESS == httpResponse.getStatusCode()) {
                System.debug('###### success note creation'+httpResponse.getBody());


            }else{
                Exception_Process_Event__c myException = new Exception_Process_Event__c();  
                myException.Event_Type__c = ApexAkina_Constants.DEAL_CREATED;
                myException.Name = 'SalestrekkerAsyncCreateNote';
                myException.Message__c = 'Received an unexpected response from Salestrekker ' ;
                myException.Severity__c = ApexAkina_Constants.SEV_LOW;
                myException.SFObjecId__c = myOpportunity.Id;
                myException.Description__c = 'Error while trying to create a note in Salestrekker: '+ httpResponse.getBody();
    
                Database.insert(myException);

            }    




        } else {
            System.debug('###### Error '+httpResponse.getBody());
          
            Exception_Process_Event__c myException = new Exception_Process_Event__c();  
            myException.Event_Type__c = ApexAkina_Constants.DEAL_CREATED;
            myException.Name = 'SalestrekkerAsyncCreateTicket';
            myException.Message__c = 'Received an unexpected response from Salestrekker ' ;
            myException.Severity__c = ApexAkina_Constants.SEV_HIGH;
            myException.SFObjecId__c = myOpportunity.Id;
            myException.Description__c = 'Error while trying to create a deal in Salestrekker: '+ httpResponse.getBody();

            Database.insert(myException);
        }
        Database.update(updateList);
    }

}