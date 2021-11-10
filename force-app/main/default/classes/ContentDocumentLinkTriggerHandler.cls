/**
* @author Alvin (aaquino@deloitte.com)
* @date Feb 5, 2020
* @description Trigger handler for Content Document Link trigger.
*
* CHANGE LOG
* Feb 5, 2020 - Initial setup (aaquino@deloitte.com)
**/
public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler{
    /**
     * TriggerHandler Extension
     *
     * @author Alvin Aquino
     * @date February 5, 2020
     */

    public List <ContentDocumentLink> lstNewContentDocumentLink {
        get {
            return (List <ContentDocumentLink> ) Trigger.new;
        }
        private set;
    }

    /*public Map <Id, ContentDocumentLink> MapoldContentDocumentLink {
        get {
            return (Map <Id, ContentDocumentLink> ) Trigger.oldMap;
        }
        private set;
    }*/

    public override void afterInsert() {
        createComplianceDocument(lstNewContentDocumentLink);
    }

    /**
    *   @author Alvin Aquino (aaquino@deloitte.com)
    *   @description Method to insert Compliance Document (Compliance_Doc__c) with corresponding 
    *                Content Document Type
    **/
    public void createComplianceDocument(List<ContentDocumentLink> lstContentDocumentLink) {


        //custom metadata details
        SObjectType cmobjType = Schema.getGlobalDescribe().get('Compliance_Document_Type__mdt');
        Map<String,Schema.SObjectField> cmfields = cmobjType.getDescribe().fields.getMap();
        Set<String> cmfieldNames = cmfields.keySet();

        
        set<Id> relrecord = new set<Id>();
        List<Compliance_Doc__c> lstrelcd = new List<Compliance_Doc__c>();
        List<ContentDocument> lstCD = new List<ContentDocument>();
        List<Compliance_Doc__c> lstComDocToCreate = new List<Compliance_Doc__c>();
        List<Compliance_Doc__c> lstComDocToUpdate = new List<Compliance_Doc__c>();

        //key is a concatenation of Metadata_Id__c and Parent Object(LinkedEntityId)
        map<string, Compliance_Doc__c> mapComDoc = new map<string, Compliance_Doc__c>();
        map<Id, ContentDocument> mapContentDocument = new map<Id, ContentDocument>();

        //get all custom metadata type
        List<Compliance_Document_Type__mdt> cmtypes = Database.query('Select ' + string.join(new List<String>(cmfieldNames), ',') 
            + ' from Compliance_Document_Type__mdt');


        //check for related compliance document
        for(ContentDocumentLink cdl: lstContentDocumentLink){
            relrecord.add(cdl.ContentDocumentId);
        }

        if(!relrecord.isEmpty()){
            system.debug('1');
            lstrelcd = [SELECT id, Metadata_Id__c, Content_Document_Id__c, Parent_Object_Id__c FROM Compliance_Doc__c WHERE Content_Document_Id__c in: relrecord];
            lstCD = [SELECT Id, Title FROM ContentDocument WHERE Id in: relrecord ];

            if(!lstCd.isEmpty()){
                system.debug('2');
                for(ContentDocument cd: lstCD){
                    mapContentDocument.put(cd.Id, cd);
                    system.debug('2.1');
                }
                
            }

        }

        if(!lstrelcd.isEmpty()){
            for(Compliance_Doc__c domdoc: lstrelcd){
                string key = domdoc.Metadata_Id__c + domdoc.Parent_Object_Id__c;
                mapComDoc.put(key,domdoc);
                
            }
        }       
            
            
        

        for(ContentDocumentLink cdl: lstContentDocumentLink){
            if(!cmtypes.isEmpty()){
                for(Compliance_Document_Type__mdt cdt: cmtypes){
                    if(mapContentDocument.containsKey(cdl.ContentDocumentId)){
                        if(mapContentDocument.get(cdl.ContentDocumentId).Title.contains(cdt.Document_Name_Suffix__c)){
                            if(!string.valueOf(cdl.LinkedEntityId).StartsWith('005')){
                                string key= cdt.Id + string.valueOf(cdl.LinkedEntityId);
                                if(mapComDoc.containskey(key)){
                                    //update
                                    Compliance_Doc__c comdoc = mapComDoc.get(key);
                                    comdoc.Content_Document_Id__c = cdl.ContentDocumentId;
                                    lstComDocToUpdate.add(comdoc);
                                }else {
                                    Compliance_Doc__c comdoc = new Compliance_Doc__c();
                                    comdoc.Metadata_Id__c = cdt.Id;
                                    comdoc.Parent_Object_Id__c = cdl.LinkedEntityId;
                                    comdoc.Content_Document_Id__c = cdl.ContentDocumentId;
                                    lstComDocToCreate.add(comdoc);
                                }
                            }
                            

                        }
                    }
                }
            }
            
        }

        if(!lstComDocToCreate.isEmpty()){
            insert lstComDocToCreate;
            system.debug(lstComDocToCreate);
            system.debug('create ' + lstComDocToCreate.size());
        }

        if(!lstComDocToUpdate.isEmpty()){
            Update lstComDocToUpdate;
            system.debug('update ' + lstComDocToUpdate.size());
        }
    }

    

}