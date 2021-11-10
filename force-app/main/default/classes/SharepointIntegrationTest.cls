@isTest
public class SharepointIntegrationTest {

    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Test method to create account folder into Sharepoint.
    **/
	@isTest
	static void testAccountFolderCreation() {
	    
	    AccountTriggerHandler.allowCallout = true;
	    // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new SharepointServicesMock());
        
        Test.startTest();
	    
        Account personAccount = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId());
        Database.insert(personAccount);
        
        AccountTriggerHandler.createAccountFolders(new List<Id>{personAccount.Id});
        
        Test.stopTest();
	}
	
	 /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Test method to create oppty subfolder into Sharepoint.
    **/
	@isTest
	static void testOpptyFolderCreation() {
	    
	    AccountTriggerHandler.allowCallout = true;
	    OpportunityTriggerHandler.allowCallout = true;
	    
	    // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new SharepointServicesMock());
        
        Test.startTest();
	    
        Account personAccount = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId());
        Database.insert(personAccount);
        
        AccountTriggerHandler.createAccountFolders(new List<Id>{personAccount.Id});
        
        Opportunity oppty = new Opportunity(Name = 'Sample Oppty', CloseDate = System.today().addDays(10), StageName = 'New', AccountId = personAccount.Id);
        Database.insert(oppty);
        
        OpportunityTriggerHandler.createOpptyFolders(new List<Id>{oppty.Id});
        
        Test.stopTest();

	}
	
	/**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Test method to push files into Sharepoint
    **/
	@isTest
	static void testFileCreation() {
	    
	    AccountTriggerHandler.allowCallout = true;
	    ContentVersionTriggerHandler.allowCallout = true;
	    // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new SharepointServicesMock());
        
        Test.startTest();
	    
        Account personAccount = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId());
        Database.insert(personAccount);
        
        ContentVersion newFile = new ContentVersion(Title = 'Apex Akina Document', PathOnClient = 'Apex Akina Document.pdf', VersionData = Blob.valueOf('Sample Apex Akina Document '), Origin = 'H');
                                                              
        Database.insert(newFile);
            
        newFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: newFile.Id];
            
        Database.insert(new ContentDocumentLink(ContentDocumentId = newFile.ContentDocumentId, LinkedEntityId = personAccount.Id, Visibility = 'AllUsers', ShareType = 'I'));
        
        Test.stopTest();

	}
	
    public class SharepointServicesMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"d":{"results":[{"__metadata":{"id":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared Documents/Kriti Argawal (A-00123)/O-00181\')",'+
                        '"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')","type":"SP.Folder"},' + 
                        '"Files":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/Files"}},' + 
                        '"ListItemAllFields":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/ListItemAllFields"}},' + 
                        '"ParentFolder":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/ParentFolder"}},' + 
                        '"Properties":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/Properties"}},' + 
                        '"StorageMetrics":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/StorageMetrics"}},' +
                        '"Folders":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00181\')/Folders"}},"Exists":true,"IsWOPIEnabled":false,' + 
                        '"ItemCount":0,"Name":"O-00181","ProgID":null,"ServerRelativeUrl":"/sites/CloudinIT/Shared Documents/Kriti Argawal (A-00123)/O-00181","TimeCreated":"2018-09-21T02:38:47Z","TimeLastModified":"2018-09-21T02:38:47Z","UniqueId":"72d4fd8e-d293-4fb6-8e17-ad24843ea18a","WelcomePage":""},' +
                        '{"__metadata":{"id":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared Documents/Kriti Argawal (A-00123)/O-00180\')",' +
                        '"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')","type":"SP.Folder"},' +
                        '"Files":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/Files"}},' +
                        '"ListItemAllFields":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/ListItemAllFields"}},' +
                        '"ParentFolder":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/ParentFolder"}},' +
                        '"Properties":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/Properties"}},' +
                        '"StorageMetrics":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/StorageMetrics"}},' +
                        '"Folders":{"__deferred":{"uri":"https://catindoy.sharepoint.com/sites/CloudinIT/_api/Web/GetFolderByServerRelativePath(decodedurl=\'/sites/CloudinIT/Shared%20Documents/Kriti%20Argawal%20(A-00123)/O-00180\')/Folders"}},"Exists":true,' +
                        '"IsWOPIEnabled":false,"ItemCount":2,"Name":"O-00180","ProgID":null,"ServerRelativeUrl":"/sites/CloudinIT/Shared Documents/Kriti Argawal (A-00123)/O-00180","TimeCreated":"2018-09-21T00:36:31Z","TimeLastModified":"2018-09-21T02:37:17Z","UniqueId":"77e49990-0d49-4e0b-989a-d74da28b4833","WelcomePage":""}]}}');
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }

}