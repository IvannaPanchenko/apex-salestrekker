/**
* @author Alvin (aaquino@deloitte.com)
* @date Feb 4, 2020
* @description Trigger handler for Content Document trigger.
*
* CHANGE LOG
* Feb 4, 2020 - Initial setup (aaquino@deloitte.com)
**/
public with sharing class ContentDocumentTriggerHandler extends TriggerHandler{

    /**
     * TriggerHandler Extension
     *
     * @author Alvin Aquino
     * @date February 4 2020
     */

    public List <ContentDocument> lstOldContentDocument {
        get {
            return (List <ContentDocument> ) Trigger.old;
        }
        private set;
    }

    


    public override void beforeDelete() {
        removecompliancedocument(lstOldContentDocument);
    }

    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Method to delete Compliance Document (Compliance_Doc__c) whose Content_Document_Id__c 
    *                value equal to the deleted Content Document
    **/
    public void removecompliancedocument(List<ContentDocument> lstContentDocument) {
        set<Id> setContentDocIds = new set<Id>();
        List<Compliance_Doc__c> lstComDocToDelete = new List<Compliance_Doc__c>();
        
        // Loop through list of accounts and get the list of content document to be deleted
        if(!lstContentDocument.isEmpty()){
            for(ContentDocument cdoc : lstContentDocument) {
                setContentDocIds.add(cdoc.Id);
            }
        }

        
        if(!setContentDocIds.isEmpty()){
            //query all Compliance Document
            lstComDocToDelete = [SELECT Id, Name, Content_Document_Id__c FROM Compliance_Doc__c WHERE Content_Document_Id__c in: setContentDocIds];

            //delete the records
            if(!lstComDocToDelete.isEmpty()){
                delete lstComDocToDelete;
            }
        }
    }

    

}