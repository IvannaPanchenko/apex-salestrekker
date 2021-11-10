/**
* @author David Catindoy (david@cloudinit.nz)
* @date Dec 11, 2017
* @description Controller for Signature component
*
* CHANGE LOG
**/
public class SignatureComponentController {
    
    //Public variables
    public String canvasName{get;
        set{
            if(canvasName != value){
                canvasName = value;
            }
        }
    }
    
    public String signature_Name{get;
        set{
            if(signature_Name != value){
                signature_Name = value;
            }
        }
    }
    
    /**
    *   @author David Catindoy (david@cloudinit.nz)
    *   @description Method to upload signature captured in HTML Canvas
    **/
    @RemoteAction
    public static String uploadSignature(String b64SignData, String opptyId, String signatureName){
        ReturnData ret = new ReturnData();
        ret.success = true;
        ret.message = signatureName + ' uploaded successfully';
        
        SavePoint sp = Database.setSavepoint();
        
        try{
            
            ContentVersion opptyAtt =  new ContentVersion(Title = signatureName, PathOnClient = signatureName + Datetime.now().getTime() + '.png',
                                                              VersionData = EncodingUtil.base64Decode(b64SignData), Origin = 'H');
            opptyAtt.ContentDocumentId = null;
            
            // New content document version for opportunity
            Database.insert(opptyAtt);
            
            Opportunity oppty = new Opportunity(Id = opptyId);
            
            //Check if the signature captured is for Client 1 or Client 2
            if(signatureName.containsIgnoreCase('Client 1')){
                oppty.Client_1_Signature__c = opptyAtt.Id;
            } else {
                oppty.Client_2_Signature__c = opptyAtt.Id;
            }
            
            // Update fact find and oppty to save the signature attachment id.
            Database.update(oppty);
            
            // Insert new content document link for the opportunity
            Database.insert(new ContentDocumentLink(ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: opptyAtt.Id].ContentDocumentId, LinkedEntityId = opptyId, Visibility = 'AllUsers', ShareType = 'I'));
        } catch(Exception e){
            ret.success = false;
            ret.message = e.getMessage();
            
            Database.rollback(sp);
        }    
        
        return JSON.serialize(ret);
    }
    
    //Wrapper class
     private class ReturnData{
        Boolean success {get;set;}
        String message {get;set;}
    }

}