/**
 * Created by jameswinter on 17/09/21.
 */

public without sharing class SalestrekkerAsyncCreateContact implements Queueable, Database.AllowsCallouts {

    @TestVisible private static List<Exception_Event__e> eventList = new List<Exception_Event__e>();
    private String idOwner;
    private Account myAccount;

    public SalestrekkerAsyncCreateContact(String idOwner, Account myAccount) {
        this.idOwner = idOwner;
        this.myAccount = myAccount;
    }

    public void execute(QueueableContext context) {

        String stContactId = SalestrekkerCreateContact.createContact(idOwner, myAccount);
        myAccount.Salestrekker_Contact_Id__c = stContactId;
        Database.update(myAccount);

    }
}