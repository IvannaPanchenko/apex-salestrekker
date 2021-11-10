/**
 * Created by jameswinter on 17/09/21.
 */

public with sharing class SalestrekkerCreateContact {

    public static String createContact(String idOwner, Account myAccount) {
        //Todo - find usages
        String stContactId;

        SalestrekkerContact.CreateContact createContact = new SalestrekkerContact.CreateContact();
        createContact.contact = new SalestrekkerContact.ContactInput();
        createContact.contact.idOwner = idOwner;
        createContact.contact.isActive = true;
        createContact.contact.person = new SalestrekkerContact.Person();
        createContact.contact.person.information = new SalestrekkerContact.ContactPersonInformationInput();
        createContact.contact.person.information.firstName = myAccount.FirstName != null ?  myAccount.FirstName: myAccount.LastName ;
        createContact.contact.person.information.familyName = myAccount.LastName;
        Salestrekker_Label__mdt labelClient = [SELECT Label_Id__c FROM Salestrekker_Label__mdt WHERE Label_Name__c =: ApexAkina_Constants.CLIENT];
        createContact.contact.idLabels = new List<String>();
        createContact.contact.idLabels.add(labelClient.Label_Id__c);

        String requestBody = SalestrekkerContact.createContactPayload(createContact);

        HttpResponse httpResponse = SalestrekkerService.salestrekkerSend(requestBody);
        if(ApexAkina_Constants.HTTP_SUCCESS == httpResponse.getStatusCode()) {
            //prepare response
            Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
            Map<String, Object> dataMap = (Map<String, Object>)bodyMap.get('data');
            stContactId = (String)dataMap.get('contactCreate');
        } else {
            
            Exception_Process_Event__c myException = new Exception_Process_Event__c();
            myException.Event_Type__c = ApexAkina_Constants.CONTACT_CREATED;
            myException.Name = 'SalestrekkerCreateContact';
            myException.Message__c = 'Received an unexpected response from Salestrekker ' +httpResponse.getStatusCode()  ;
            myException.Severity__c = ApexAkina_Constants.SEV_HIGH;
            myException.SFObjecId__c = myAccount.Id;
            myException.Description__c = 'Error while trying to create a new contact in Salestrekker ' + httpResponse.getBody();

            Database.insert(myException);
        }
        return stContactId;
    }

}