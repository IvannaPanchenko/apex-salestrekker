/**
* @author David (david@cloudinit.nz)
* @date Sept 21, 2018
* @description Trigger handler for opportunity trigger.
*
* CHANGE LOG
* Sept 21, 2018 - Initial setup (david@cloudinit.nz)
**/
public class OpportunityTriggerHandler extends TriggerHandler {
    
    public static Boolean allowCallout = Boolean.valueOf(Label.Enable_Sharepoint_Callout);
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method that can be called in the process builder.
    **/
    @InvocableMethod(label = 'Create Opportunity Folder')
    public static void createOpptyFolders(List<Id> opptyIds){
        
        Map<Id, Opportunity> validOppty = new Map<Id, Opportunity>([SELECT Id, AccountId, Sharepoint_Folder_Created__c FROM Opportunity WHERE Id IN :opptyIds AND Sharepoint_Folder_Created__c = false AND AccountId != null]);
        Set<Id> acctIds = new Set<Id>();
        // Call sharepoint method if callout is allowed.
        if(allowCallout && !System.isBatch() && !System.isFuture() && !validOppty.isEmpty()){
            
            for(Opportunity opp : validOppty.values()){
                acctIds.add(opp.AccountId);
            }
            
            // If there are account ids
            if(!acctIds.isEmpty()){
                // Call method to create account folders.
                AccountTriggerHandler.createAccountFolders(new List<Id>(acctIds));
            }
            
            createSharePointFolders(new List<Id>(validOppty.keySet()));
        }
    }
    
     /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to map the oppty to the right parent account folder.
    **/
    @future(callout=true)
    public static void createSharePointFolders(List<Id> opptyIds){
        // Initialize variables
        //Set<String> rootFolders = AccountTriggerHandler.getExistingFolders();//Comment this out to avoid apex heap size error
        Map<String, String> newFolders = new Map<String, String>();
        List<Opportunity> opptyToUpdate = new List<Opportunity>();
        
        // Loop through list of opportunities.
        for(Opportunity oppty : [SELECT Id, Name, Opportunity_Id__c, Account.Sharepoint_Folder_Name__c, Account.Name, Account.Akina_Id__c, AccountId FROM Opportunity WHERE Id IN :opptyIds]){
            
            String accFolderName = String.isNotBlank(oppty.Account.Sharepoint_Folder_Name__c) ? oppty.Account.Sharepoint_Folder_Name__c : String.escapeSingleQuotes(oppty.Account.Name) + ' (' + oppty.Account.Akina_Id__c + ')';
            
            newFolders.put(oppty.Opportunity_Id__c, String.escapeSingleQuotes(accFolderName));
            opptyToUpdate.add(new Opportunity(Id = oppty.Id, Sharepoint_Folder_Created__c = true));
        }
        
        if(!newFolders.isEmpty()){
            // Call method to create oppty sub folders.
            createSharePointFolders(newFolders);
            
            Database.update(opptyToUpdate);
        }
        
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to send post callout to create folders in Sharepoint.
    **/
    public static void createSharePointFolders(Map<String, String> folderNames){
        
        String batchId = 'batch_' + AccountTriggerHandler.generateRandomString(8) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(12);
        String changesetId = 'changeset_' + AccountTriggerHandler.generateRandomString(8) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(4) + '-' + AccountTriggerHandler.generateRandomString(12);
        
        String requestBody = '--' + batchId + '\nContent-Type: multipart/mixed; boundary=' + changesetId;
        
        for(String folderName : folderNames.keySet()){
            requestBody += '\n\n--' + changesetId;
            requestBody += '\nContent-Type: application/http\nContent-Transfer-Encoding: binary';
            requestBody += '\n\nPOST ' + Label.Sharepoint_Site + '/_api/web/GetFolderByServerRelativeUrl(\'Shared%20Documents\')/Folders HTTP/1.1';
            requestBody += '\nContent-Type: application/json; odata=verbose';
            requestBody += '\n\n{ \'__metadata\': { \'type\':\'SP.Folder\' }, \'ServerRelativeUrl\': \'Shared Documents/' + folderNames.get(folderName) + '/' + folderName + '\' }';
        }
        
        requestBody += '\n--' + changesetId + '--';
        requestBody += '\n\n--' + batchId + '--';
        
        String endpointURL = 'callout:SharePoint' + '/_api/$batch';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointURL);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody(requestBody);
        req.setHeader('Accept','application/json; odata=verbose');
        req.setHeader('Content-Type', 'multipart/mixed; boundary=' + batchId);
        Http newHttp = new Http();
        HTTPResponse res;
        
        if(!Test.isRunningTest()){
            res = newHttp.send(req);
        }

    }

    public List <Opportunity> newOpps {
        get {
            return (List <Opportunity> ) Trigger.new;
        }
        private set;
    }

    public Map <Id, Opportunity> oldOppsMap {
        get {
            return (Map <Id, Opportunity> ) Trigger.oldMap;
        }
        private set;
    }

    public override void afterUpdate() {
        
        checkServicesUpdate(newOpps, oldOppsMap);
        signedSOAComplianceDoc(newOpps, oldOppsMap);
    }

      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description Method that processes the renaming and uploading (to the compliance list) of the signed SOA
    **/
    private static void signedSOAComplianceDoc(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){

        Set<Id> oppIds = new Set<Id>();

        for(Opportunity opps : newOpps){
            //find opportunites with changed docusign status
            if(opps.Docusign_Status__c != oldOppsMap.get(opps.Id).Docusign_Status__c && opps.Docusign_Status__c == 'SOA Signed'){
                oppIds.add(opps.Id);
            }
        }
        System.debug('\n\n\n opps'+oppIds);
        if(oppIds.isEmpty()) return;

        Map<Id,dsfs__DocuSign_Status__c> dstMap = new Map<Id,dsfs__DocuSign_Status__c>();

        for(Opportunity opp : [SELECT Id, (SELECT Id, dsfs__Opportunity__c FROM R00N80000002fD9vEAE__r WHERE dsfs__Subject__c = 'Ready to sign Statement of Advice' AND dsfs__Envelope_Status__c = 'Completed' ORDER BY CreatedDate DESC LIMIT 1) FROM Opportunity WHERE Id IN: oppIds]){

            if(!opp.R00N80000002fD9vEAE__r.isEmpty()){
                //prepare dst map
                dsfs__DocuSign_Status__c dst = opp.R00N80000002fD9vEAE__r[0];

                dstMap.put(dst.Id, dst);
            }

        }
        system.debug('\n\n\n dstMap'+dstMap);
        if(dstMap.isEmpty()) return;

        List<ContentDocumentLink> newCDLList = new List<ContentDocumentLink>();
        List<ContentDocument> cdUpdateList = new List<ContentDocument>();
        
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, ContentDocument.Title, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: dstMap.keySet()]){
            //prepare link towards opportunity
            Id oppId = dstMap.get(cdl.LinkedEntityId).dsfs__Opportunity__c;

            newCDLList.add(new ContentDocumentLink( ContentDocumentId = cdl.ContentDocumentId, ShareType = cdl.ShareType,LinkedEntityId = oppId));
            //prepare renaming
            String title = cdl.ContentDocument.Title;

            title = title.split('.pdf')[0];

            title = title + '_Complete.pdf';

            cdUpdateList.add(new ContentDocument(Id = cdl.ContentDocumentId, Title = title));

        }
        
        Database.update(cdUpdateList,false);

  
        Database.insert(newCDLList,false);

    }

      /**
    *   @author Patrick Lorilla (plorilla@deloitte.co.nz)
    *   @description method to populate advice areas of advice not covered field based on the services value
    **/
    private static void checkServicesUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){

        Set<Id> oppIds = new Set<Id>();

        for(Opportunity opps : newOpps){
            //find opportunites with changed services
            if(opps.Services__c != oldOppsMap.get(opps.Id).Services__c){
                oppIds.add(opps.Id);
            }
        }
        
        if(!oppIds.isEmpty()){

            List<Advice__c> adviceList = [SELECT Id, Opportunity__c, Areas_of_Advice_Not_Covered__c FROM Advice__c WHERE Opportunity__c IN: oppIds];
            
            adviceList = AdviceTriggerHandler.getUnselectedServiceFromFactFind(adviceList);

        
            update adviceList;
        }
    }

    

}