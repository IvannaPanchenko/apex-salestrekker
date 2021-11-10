/**
 * @author Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date 24/09/2019
 *
 * CHANGE LOG
 */
global without sharing class AccountDCategory_NCDEMailBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Apex_Admin_Settings__c settings = Apex_Admin_Settings__c.getOrgDefaults();

        Date dateToCompare = System.today().addDays((Integer)settings.Category_D_Email_Day_Limit__c * -1);

        System.debug('Date To Compare >>>> ' + dateToCompare);

        // Return the Query Locator
        return Database.getQueryLocator([
            SELECT 
                Id
                , Call_Frequency__pc
                , Category_D_Email_Sent_Date__c
                , Company_Ownership_Call_Frequency_Formula__c
                , Last_Contact_Date_Time__pc
                , PersonContactId
            FROM 
                Account
            WHERE 
                IsPersonAccount = true
            AND 
                Next_Contact_Date__pc <= TODAY
            AND 
                RecordType.DeveloperName = 'Client_Account'
            AND 
                PersonEmail != null
            AND 
                PersonHasOptedOutOfEmail = false
            AND 
                Category__pc = 'D'
            AND 
                Number_of_Open_Opportunities__c < 1
            AND 
                Client_Type__pc = 'Existing'
            AND          
                (Category_D_Email_Sent_Date__c < :dateToCompare OR Category_D_Email_Sent_Date__c = NULL)
            AND 
                (
                    (Owner.Name = 'Apex Advice' AND Company_Ownership__c IN ('AAG', 'SOV/AIA'))
                OR 
                    (Owner.Name != 'Apex Advice' AND Company_Ownership__c IN ('Apex Christchurch', 'Apex Tauranga', 'Apex Hawkes Bay','AAG/AT','APECT/AAG', 'Apex Waikato'))
                )
            AND 
                (
                    (AccountSource = 'Book Buy' AND book_buy_completed__pc = TRUE) 
                OR 
                    AccountSource != 'Book Buy'
                )
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> accounts) {
        List < Messaging.SingleEmailMessage > emails = new List < Messaging.SingleEmailMessage > ();
        System.debug('### accounts.size() >>> ' + accounts.size());

        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Unallocated_Clients_Overseas_Out_Of_Auckland_2017' LIMIT 1].Id;
        Id OrgWideEmailId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'eb@apexgroup.co.nz' LIMIT 1].Id;

        // create the emails and update the date on the account
        for (Account acc : accounts) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setWhatId(acc.Id);
            email.setTemplateId(emailTemplateId);
            email.setTargetObjectId(acc.PersonContactId);
            email.setUseSignature(false);
            email.setOrgWideEmailAddressId(OrgWideEmailId);
            email.setSaveAsActivity(true);

            // add the email to the collection
            emails.add(email);

            acc.Category_D_Email_Sent_Date__c = System.today();
            acc.Call_Frequency__pc = acc.Company_Ownership_Call_Frequency_Formula__c;
            acc.Last_Contact_Date_Time__pc = System.now();
        }

        // update the accounts
        if (accounts.size() > 0) {
            update accounts;
        }

        // Make sure there are emails to send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public void finish(Database.BatchableContext BC) { 
    	AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
   // Send an email to the Apex job's submitter notifying of job completion.
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   String[] toAddresses = new String[] {a.CreatedBy.Email};
   mail.setToAddresses(toAddresses);
   mail.setSubject('Apex Sharing Recalculation ' + a.Status);
   mail.setPlainTextBody
   ('The batch Apex job processed ' + a.TotalJobItems +
   ' batches with '+ a.NumberOfErrors + ' failures.');
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}