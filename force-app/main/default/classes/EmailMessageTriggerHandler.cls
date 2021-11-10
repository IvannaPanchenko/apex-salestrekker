/**
* @author Patrick Lorilla (plorilla@deloitte.co.nz)
* @date Feb 3, 2021
* @description Trigger handler class for Email Message Trigger
*
* CHANGE LOG

*/
public with sharing class EmailMessageTriggerHandler extends TriggerHandler {

    public List <EmailMessage> newEmailMessages {
        get {
            return (List <EmailMessage> ) Trigger.new;
        }
        private set;
    }

    public override void afterInsert() {
        findFirstAppointmentEmails(newEmailMessages);
    }

     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method to prepare email message records to create email files
    **/
    private static void findFirstAppointmentEmails(List <EmailMessage> newEmailMessages){

        List<EmailMessage> appointmentEmails = new List<EmailMessage>();

        for(EmailMessage eml : newEmailMessages){
            //find appointment email
            if(eml.Subject.containsIgnoreCase('Apex Advice Appointment Confirmation') &&
               eml.RelatedToId.getSObjectType() == Schema.Opportunity.getSObjectType()){
                appointmentEmails.add(eml);
            }
        }

        if(!appointmentEmails.isEmpty())
            createAndUploadOppEmailFiles(appointmentEmails);

    }

     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method to create and upload 1st appointment email files 
    **/
    private static void createAndUploadOppEmailFiles(List<EmailMessage> appointmentEmails){
        Set<Id> opportunitiesWithEmailFiles = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,ContentVersion> newFilesByOppId = new Map<Id,ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinks = new  List<ContentDocumentLink>(); 
        //get custom metadata
        List<Compliance_Document_Type__mdt> ampEmails = [SELECT Id FROM Compliance_Document_Type__mdt WHERE document_type_group__c = 'Opportunity' AND  DeveloperName = 'Appointment_Email'];

        Compliance_Document_Type__mdt ampEmail;

        if(ampEmails.isEmpty()) return;
        else{
            ampEmail = ampEmails[0];
        }

        for(EmailMessage eml : appointmentEmails){
            oppIds.add(eml.RelatedToId);
        }
        //find opp with email files
        for(Compliance_Doc__c cdoc : [SELECT Id, Parent_Object_Id__c FROM Compliance_Doc__c WHERE Content_Document_Id__c != null AND Metadata_Id__c =: ampEmail.Id AND Parent_Object_Id__c IN: oppIds]){
            opportunitiesWithEmailFiles.add(cdoc.Parent_Object_Id__c);
        }

        for(EmailMessage eml : appointmentEmails){
            //ensure that no email file exists in the opp compliance doc list
            if(!opportunitiesWithEmailFiles.contains(eml.RelatedToId)){
                //prepare eml file body and content version record
                String fileBody = 'To: <'+eml.ToAddress+'> \n'
                                +'Subject: ' +eml.Subject + ' \n'
                                +'X-Unsent: 0 \n' 
                                +'Content-Type: text/html \n\n'
                                + eml.HtmlBody;

                ContentVersion newFile = new ContentVersion(
                    Title = '1st Appointment Email',
                    PathOnClient = '1st Appointment Email.eml',
                    VersionData = Blob.valueOf(fileBody)
                );

                newFilesByOppId.put(eml.RelatedToId,newFile);

            }
        }

        insert newFilesByOppId.values();

        Set<Id> cvIds = new Set<Id>();

        for(ContentVersion cv : newFilesByOppId.values()){
            cvIds.add(cv.Id);
        }

        if(cvIds.isEmpty()) return;

        Map<Id,ContentVersion> cvMap = new Map<Id,ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: cvIds]);
        //upload eml file into the compliance doc checklist and link file to opportunity record
        for(Id key : newFilesByOppId.keySet()){

            Id docId = cvMap.get(newFilesByOppId.get(key).Id).ContentDocumentId;
            uploadOppEmailFiles(ampEmail.Id, docId, key,'');
            contentDocumentLinks.add(new ContentDocumentLink(ContentDocumentId = docId, LinkedEntityId = key));
        }

        insert contentDocumentLinks;

    }
     /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Future method to upload file into the compliance doc checklist
    **/
    @future
    private static void uploadOppEmailFiles(Id MetadataId, Id DocumentId, Id ParentId, string filestatus){
        complianceDocumentCtr.CheckFileName(MetadataId, DocumentId, ParentId, filestatus);
    }

}