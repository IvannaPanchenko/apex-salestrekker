/**
* @author David (david@cloudinit.nz)
* @date Sept 14, 2018
* @description Trigger handler for content version trigger.
*
* CHANGE LOG
* Sept 14, 2018 - Initial setup (david@cloudinit.nz)
**/
public class ContentVersionTriggerHandler {
    
    public static Boolean allowCallout = Boolean.valueOf(Label.Enable_Sharepoint_Callout);
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to process files and chunk it.
    **/
    public static void processFiles(List<ContentVersion> files){
        
        Map<String, List<Id>> filesMap = new Map<String, List<Id>>();
        Integer i = 0;
        filesMap.put(String.valueOf(i), new List<Id>());
        
        for(ContentVersion file : files){
            String index = String.valueOf(i);
            if(filesMap.get(index).size() < 20){
                filesMap.get(index).add(file.Id);
            } else {
                i++;
                filesMap.put(String.valueOf(i), new List<Id>{file.Id});
            }
        }
        
        for(String key : filesMap.keySet()){
            if(allowCallout && !System.isBatch() && !System.isFuture()){
                pushFilesToSharepoint(filesMap.get(key));
            }
        }
        
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to map files to its parent and send a post request to create the files in Sharepoint.
    **/
    @future(callout=true)
    public static void pushFilesToSharepoint(List<Id> fileIds){
        
        List<ContentVersion> files = new List<ContentVersion>([SELECT Id, VersionData, ContentDocumentId, Title, FileExtension, FileType, PathOnClient FROM ContentVersion WHERE Id IN :fileIds]);
        
        Set<Id> documentIds = new Set<Id>();
        Set<Id> entityIds = new Set<Id>();
        Map<Id, Set<Id>> documentLinks = new Map<Id, Set<Id>>();
        Map<String, SObject> parentRecords = new Map<String, SObject>();
        
        Messaging.SingleEmailMessage [] emails = new Messaging.SingleEmailMessage[]{};
        
        for(ContentVersion contentVer : files){
            documentIds.add(contentVer.ContentDocumentId);
        }
        
        System.debug('documentIds: ' + documentIds);
        
        for(ContentDocumentLink link : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :documentIds]){
            
            String entityId = String.valueOf(link.LinkedEntityId);
            if(entityId.startsWith('001') || entityId.startsWith('006') || entityId.startsWith('500')){
                
                if(documentLinks.containsKey(link.ContentDocumentId)) {
                    documentLinks.get(link.ContentDocumentId).add(link.LinkedEntityId);
                } else {
                    documentLinks.put(link.ContentDocumentId, new Set<Id>{link.LinkedEntityId});
                }
                
                entityIds.add(link.LinkedEntityId);
            
            }
        }
        
        System.debug('documentLinks: ' + documentLinks);
        
        for(Account acct : [SELECT Id, Name, Akina_Id__c, Sharepoint_Folder_Name__c FROM Account WHERE Id IN :entityIds]){
            parentRecords.put(acct.Id, acct);
        }
        
        for(Opportunity oppty : [SELECT Id, Name, Opportunity_Id__c, AccountId, Account.Name, Account.Akina_Id__c, Account.Sharepoint_Folder_Name__c FROM Opportunity WHERE AccountId != null AND Id IN :entityIds]){
            parentRecords.put(oppty.Id, oppty);
        }
        
        for(Case caseRecord : [SELECT Id, AccountId, Account.Name, Account.Akina_Id__c, Account.Sharepoint_Folder_Name__c FROM Case WHERE AccountId != null AND Id IN :entityIds]){
            parentRecords.put(caseRecord.Id, caseRecord);
        }
        
        for(ContentVersion file : files){
            
            if(documentLinks.containsKey(file.ContentDocumentId)){
                for(Id entityId : documentLinks.get(file.ContentDocumentId)){
                    
                    String parentId = String.valueOf(entityId);
                    
                    if(parentRecords.containsKey(parentId)){
                        
                        try {
                        
                            SObject parentRecord = parentRecords.get(parentId);
                            String parentExtId = String.valueOf(parentId.startsWith('500') ? parentRecord.getSObject('Account').get('Akina_Id__c') : (parentId.startsWith('006') ? parentRecord.get('Opportunity_Id__c') : parentRecord.get('Akina_Id__c')));
                            String folderName = String.valueOf(parentId.startsWith('500') ? parentRecord.getSObject('Account').get('Sharepoint_Folder_Name__c') : (parentId.startsWith('006') ? (parentRecord.getSObject('Account').get('Sharepoint_Folder_Name__c') + '/' + parentRecord.get('Opportunity_Id__c')) :
                                                                                            (parentRecord.get('Sharepoint_Folder_Name__c')))).replaceAll(' ', '%20').replaceAll('\'', '\'\'');
                            System.debug(folderName);
                            String endpointURL = 'callout:SharePoint' + '/_api/web/GetFolderByServerRelativeUrl(\'Shared%20Documents/' + folderName + '\')/Files/add(url=\'' + formatName(file.Title, file.FileExtension) + '\',overwrite=true)';
                            String metadataEndpoint = 'callout:SharePoint' + '/_api/web/GetFolderByServerRelativeUrl(\'Shared%20Documents/' + folderName + '\')/Files(\'' + formatName(file.Title, file.FileExtension) + '\')/ListItemAllFields';
                            String requestBody = '{ \'__metadata\': { \'type\':\'SP.ListItem\' }, \'' + (parentId.startsWith('006') ? Label.Sharepoint_Oppty_Field : Label.Sharepoint_Account_Field) + '\': \'' + parentExtId + '\' }';
                        
                            executeCallout(endpointURL, file.versionData);
                            updateFileMetadata(metadataEndpoint, requestBody);
                            
                        } catch (Exception e) {
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            email.setSubject('Error pushing file to Sharepoint');
                            email.setToAddresses(new List<String> {Label.Sharepoint_Email});
                            email.setPlainTextBody(String.escapeSingleQuotes(e.getMessage()) + ' ParentId: ' + parentId + ' File: ' + file.Title + ' - ' + file.Id);
                            emails.add(email);
                        }
                    }
                
                }
            }
            
        }
        
        // Make sure there are emails to send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
        
    }
    
    public static String formatName (String fileName, String extension) {
        
        fileName = fileName.replaceAll('%', 'percent');
        fileName = fileName.replaceAll('\\{', '%7B');
        fileName = fileName.replaceAll('\\}', '%7D');
        fileName = fileName.replaceAll('&', '%26');
        fileName = fileName.replaceAll('#', '%23');
        fileName = fileName.replaceAll('\\^', '%5E');
        fileName = fileName.replaceAll('\\[', '%5B');
        fileName = fileName.replaceAll('\\]', '%5D');
        fileName = fileName.replaceAll('`', '%60');
        fileName = fileName.replaceAll(' ', '%20');
        fileName = fileName.replaceAll('.' + extension, '');
        fileName = fileName.replaceAll('\'', '\'\'') + '.' + extension;
        
        //file.Title.replaceAll('%', 'percent').replaceAll(' ', '%20').replaceAll('.' + file.FileExtension, '').replaceAll('\'', '\'\'') + '.' + file.FileExtension
        return fileName;
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description The actual post callout method
    **/
    public static void executeCallout(String endpoint, Blob versionData) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBodyAsBlob(versionData);
        req.setHeader('Accept','application/json; odata=verbose');
        req.setHeader('Content-Type', 'application/json;odata=verbose');
        Http newHttp = new Http();
        HTTPResponse res;
        
        if (!Test.isRunningTest()) {
            res = newHttp.send(req);
        }
        
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to update file metadata
    **/
    public static void updateFileMetadata(String endpoint, String body) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody(body);
        req.setHeader('Accept','application/json; odata=verbose');
        req.setHeader('Content-Type', 'application/json;odata=verbose');
        req.setHeader('If-Match','*');
        req.setHeader('X-HTTP-Method','PATCH');
        Http newHttp = new Http();
        HTTPResponse res;
        
        if (!Test.isRunningTest()) {
            res = newHttp.send(req);
        }
        
    }

}