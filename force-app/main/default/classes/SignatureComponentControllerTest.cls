/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 14, 2017
* @description Test class for SignatureComponentController
*
* CHANGE LOG
**/
@isTest
private class SignatureComponentControllerTest {
    
    //Setup method
    @testSetup
    static void setup(){
        Id clientRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client Account').getRecordTypeId();
        Account newAcc = new Account(FirstName = 'David', LastName = 'Catindoy', RecordTypeId = clientRecType);
        Database.insert(newAcc); //Create new person account
        
        Fact_Find__c factFind = new Fact_Find__c(Name = 'David Catindoy - Fact Find', Primary_Owner__c = newAcc.Id);
        Database.insert(factFind); //Insert a new fact find.
        
        Database.insert(new Attachment(Name = 'Client 1 Signature.png', Body = Blob.valueOf('Client 1 Signature'), ParentId = factFind.Id));
    }
    
    //Test upload signature method
	@isTest
	static void testUploadSignature() {
	    
	    // Get person account id
	    Id accountId = [SELECT Id FROM Account WHERE FirstName = 'David' LIMIT 1].Id;
	    
	    Opportunity oppty = new Opportunity(Name = 'Sample Oppty', StageName = 'New', CloseDate = System.today().addMonths(1), AccountId = accountId);
	    Database.insert(oppty);
        SignatureComponentController controller = new SignatureComponentController();
        controller.canvasName = 'Client1Sig';
        controller.signature_Name = 'Client 1 Signature';
        
        Id parentId = [SELECT Id FROM Fact_Find__c LIMIT 1].Id;
        
        //Upload client 1 signature
        String response = SignatureComponentController.uploadSignature(EncodingUtil.base64Encode(Blob.valueOf('Client 1 Signature')), oppty.Id, 'Client 1 Signature');
        System.assert(response.containsIgnoreCase('Client 1 Signature uploaded successfully'));
        
        //Upload client 2 signature
        response = SignatureComponentController.uploadSignature(EncodingUtil.base64Encode(Blob.valueOf('Client 2 Signature')), oppty.Id, 'Client 2 Signature');
        System.assert(response.containsIgnoreCase('Client 2 Signature uploaded successfully'));
        
        //Upload signature with no parentId
        response = SignatureComponentController.uploadSignature(EncodingUtil.base64Encode(Blob.valueOf('Client Signature')), '', 'Client Signature');
        System.assert(response.containsIgnoreCase('Invalid id'));
        
        //Upload client 1 signature again
        response = SignatureComponentController.uploadSignature(EncodingUtil.base64Encode(Blob.valueOf('Client 1 Signature')), oppty.Id, 'Client 1 Signature');
        System.assert(response.containsIgnoreCase('Client 1 Signature uploaded successfully'));
        
	}

}