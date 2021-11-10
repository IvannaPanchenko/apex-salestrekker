/******************************************************************************************
        * Create By    :     Alvin Aquino
        * Create Date  :    January 30, 2020
        * Description  :    Apex controller for complianceDocument LWC
        *   Modification Log:
        *    -----------------------------------------------------------------------------
        *    * Developer                          Date               Description
        *    * ----------------------------------------------------------------------------                 
        *    * Alvin Aquino                  January 30, 2020       Initial version.
        *****************************************************************************************/


public with sharing class complianceDocumentCtr {

        /*******************************************************************************************
                * Method         :    getComplianceDocument
                * Description    :    query all document Type base on Metadata Name
                * Parameter      :    string sCMName, Id ParentObjectId     
                * Return Type    :    Wrapper
        ******************************************************************************************/
        @AuraEnabled(cacheable=true)
        public static List<wrapCompDoc> getComplianceDocument (string sDocTypeGroup, Id ParentObjectId){
               List<wrapCompDoc> lstcompdocwrapper = new List<wrapCompDoc>();

               SObjectType objType = Schema.getGlobalDescribe().get('Compliance_Document_Type__mdt');
               Map<String,Schema.SObjectField> cmfields = objType.getDescribe().fields.getMap();

               Set<String> fieldNames = cmfields.keySet();
               Set<string> uniqueIds = new set<string>();
               Map<string, Compliance_Doc__c> mapMetadataIdRec = new Map<string, Compliance_Doc__c>();
               set<Id> setdocId = new set <Id>();
               List<ContentDocument> lstFiles = new List<ContentDocument>();
               Map<Id, ContentDocument> mapCD = new Map<Id, ContentDocument>();
               String profileName= [Select Id, Name from Profile where Id=: userinfo.getProfileId()].Name;

               List<Compliance_Doc__c> lstCompDoc = [Select id, Metadata_Id__c, Content_Document_Id__c, Parent_Object_Id__c FROM Compliance_Doc__c WHERE Parent_Object_Id__c =: ParentObjectId 
                ORDER BY LastModifiedDate DESC];
               if(!lstCompDoc.isEmpty()){
                       for(Compliance_Doc__c relDoc: lstCompDoc){
                             if(!mapMetadataIdRec.containsKey(relDoc.Metadata_Id__c)){
                                     mapMetadataIdRec.put(relDoc.Metadata_Id__c, relDoc);
                             }
                             if(relDoc.Content_Document_Id__c != null){
                                     setdocId.add(relDoc.Content_Document_Id__c);
                             }
                       }

                       if(!setdocId.isEmpty()){
                               lstFiles = [SELECT Id, Title, CreatedDate, ContentSize, FileExtension, FileType FROM ContentDocument WHERE Id in: setdocId];
                               mapCD = new Map<Id, ContentDocument>(lstFiles);

                       }
                       
               }
               
               List<Compliance_Document_Type__mdt> cmtypes = Database.query('Select ' + string.join(new List<String>(fieldNames), ',')
                                                                + ' from Compliance_Document_Type__mdt WHERE document_type_group__c = \'' + sDocTypeGroup + '\''
                                                                + ' AND (Exclude_On_Profiles__c != \'{'+profileName+'}\')'
                                                                + ' AND (NOT Exclude_On_Profiles__c LIKE \'%{'+profileName+'}%\')'
                                                                + ' ORDER BY Order__c ASC, DeveloperName ASC'
               );
               if(!cmtypes.isEmpty()){
                  for(Compliance_Document_Type__mdt type: cmtypes){
                        if(mapMetadataIdRec.containsKey(type.Id)){
                                decimal fsize = mapCD.get(mapMetadataIdRec.get(type.Id).Content_Document_Id__c).ContentSize;
                                string cdsize = '';
                                if(fsize >= 1024){
                                       decimal size = fsize/1024;
                                       size = size.setscale(0);
                                       cdsize = string.valueof(size);
                                       cdsize = cdsize + 'KB';
                                }else{
                                        cdsize = string.valueof(fsize);
                                        cdsize = cdsize + 'B';
                                }

                                String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + mapMetadataIdRec.get(type.Id).Content_Document_Id__c;

                                
                                lstcompdocwrapper.add(new wrapCompDoc(mapMetadataIdRec.get(type.Id).Id, fullFileURL, cdsize, mapMetadataIdRec.get(type.Id).Content_Document_Id__c, type.MasterLabel, mapMetadataIdRec.get(type.Id).id, type.Id, mapCD.get(mapMetadataIdRec.get(type.Id).Content_Document_Id__c)));
                                
                        }else{
                                lstcompdocwrapper.add(new wrapCompDoc(null, null, null, null, type.MasterLabel, null, type.id, null));
                        }
                  }
                  
                  return lstcompdocwrapper;
               }else{
                  return lstcompdocwrapper;
               }

               
               
        }


        /*******************************************************************************************
                * Method         :    wrapCompDoc
                * Description    :    Wrapper definition for Compliance Document
        ******************************************************************************************/
        
        public class wrapCompDoc {
                @AuraEnabled
                public Boolean bExisting {get; set;}
                @AuraEnabled
                public string sUploadLabel {get; set;}
                @AuraEnabled
                public string type {get; set;}
                @AuraEnabled
                public string cdocid {get;set;}
                @AuraEnabled
                public ContentDocument cdocrec {get;set;}
                @AuraEnabled
                public id CustomCD {get;set;}
                @AuraEnabled
                public id MetadataId {get;set;}
                @AuraEnabled
                public string cdsize {get;set;}
                @AuraEnabled
                public string fileurl{get; set;}
                @AuraEnabled
                public string compdocid {get;set;}
        
                //This is the contructor method. When we create a new wrapAccount object we pass a Account that is set to the acc property. We also set the selected value to false
                public wrapCompDoc(string cdid, string fullFileURL, string cdtsize, string docid, string stype, id cCD, id cmid, ContentDocument cdoc) {
                        
                        if(docid == null){
                                bExisting = false;
                                sUploadLabel = 'Add File';
                                type = stype;
                                cdocid = null;
                                CustomCD = cCD;
                                MetadataId = cmid;
                                cdsize = cdtsize;
                                fileurl = fullFileURL;
                                compdocid = cdid;
                        }else{
                                bExisting = true;
                                sUploadLabel = 'Replace File';
                                type = stype;
                                cdocid = docid;
                                cdocrec = cdoc;
                                CustomCD = cCD;
                                MetadataId = cmid;
                                cdsize = cdtsize;
                                fileurl = fullFileURL;
                                compdocid = cdid;
                        }
                        


                }
        }

        /*******************************************************************************************
                * Method         :    getRelatedFiles
                * Description    :    query all Files Related to the Record
                * Parameter      :    Id ParentObjectId     
                * Return Type    :    Wrapper
        ******************************************************************************************/
        @AuraEnabled(cacheable=true)
        public static List<ContentDocumentLink > getRelatedFiles (Id ParentObjectId){
                system.debug('files');
                List<ContentDocumentLink > lstFiles = [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.ContentSize,
                         ContentDocument.FileType, ContentDocument.FileExtension FROM ContentDocumentLink  WHERE LinkedEntityId  =: ParentObjectId];
                if(!lstFiles.isEmpty()){
                        return lstFiles;

                }else{
                        return lstFiles;
                }

        }


        /*******************************************************************************************
                * Method         :    CheckFileName
                * Description    :    Check the newly uploaded file if it corresponds to a naming convention
                * Parameter      :    Id MetadataId, Id DocumentID    
                * Return Type    :    String
        ******************************************************************************************/
        @AuraEnabled
        Public static string CheckFileName(Id MetadataId, Id DocumentId, Id ParentId, string filestatus){
                SObjectType objType = Schema.getGlobalDescribe().get('Compliance_Document_Type__mdt');
                Map<String,Schema.SObjectField> cmfields = objType.getDescribe().fields.getMap();

                Set<String> fieldNames = cmfields.keySet();
                id rightMetadataid;
                List<Compliance_Doc__c> rightComDoc = new List<Compliance_Doc__c>();
                


                
                string resultmessage = 'Pass';

                List<Compliance_Doc__c> currentCompDoc = [SELECT Id, Metadata_Id__c, Content_Document_Id__c,  Parent_Object_Id__c FROM Compliance_Doc__c 
                                WHERE Parent_Object_Id__c =: ParentId and Metadata_Id__c =: MetadataId limit 1 ];

                system.debug(filestatus);

                

                List<Compliance_Document_Type__mdt> cmtypes = Database.query('Select ' + string.join(new List<String>(fieldNames), ',') + ' from Compliance_Document_Type__mdt');
                ContentDocument cdrec = [Select Id, Title FROM ContentDocument WHERE Id =: DocumentId];
                

                if(!cmtypes.isEmpty()){
                       for(Compliance_Document_Type__mdt cdt: cmtypes){
                               if(cdrec.Title.contains(cdt.Document_Name_Suffix__c)){
                                       if(cdt.Id != MetadataId){
                                             resultmessage = 'File has been checked and has been routed to a different type.  The file has been submitted as ' + cdt.MasterLabel; 
                                             rightMetadataid = cdt.Id;
                                             system.debug('1');

                                       }
                               }
                       }
                }

                
                if(resultmessage != 'Pass'){
                        system.debug('2');
                        rightComDoc = [SELECT Id, Metadata_Id__c, Content_Document_Id__c,  Parent_Object_Id__c FROM Compliance_Doc__c 
                                WHERE Parent_Object_Id__c =: ParentId and Metadata_Id__c =: rightMetadataid limit 1 ];
                        
                        if(!rightComDoc.isEmpty()){
                                system.debug('2.1');
                                //update compliance document
                                if(rightComDoc[0].Content_Document_Id__c != DocumentId){
                                        system.debug('2.1.1');
                                        rightComDoc[0].Content_Document_Id__c = DocumentId;
                                        Update rightComDoc;

                                }
                                
                                system.debug('2.1.2');
                                //delete the document chosen to be replaced
                                delete currentCompDoc;  
                                
                                

                                
                        }else{
                                //create new compliance document if there is no existing compliance document
                                if(filestatus == 'existing'){
                                        system.debug('2.2');
                                        Compliance_Doc__c cdoc = new Compliance_Doc__c();
                                        cdoc.Metadata_Id__c = rightMetadataid;
                                        cdoc.Content_Document_Id__c = DocumentId;
                                        cdoc.Parent_Object_Id__c = ParentId;

                                        insert cdoc;
                                        //delete the document chosen to be replaced
                                        system.debug(currentCompDoc);
                                        delete currentCompDoc;
                                }

                                

                                

                                
                        }
                }else{
                        system.debug('3.0');
                        if(!currentCompDoc.isEmpty()){
                                currentCompDoc[0].Content_Document_Id__c = DocumentId;
                                update currentCompDoc;
                        }else{
                                Compliance_Doc__c cdoc = new Compliance_Doc__c();
                                cdoc.Metadata_Id__c = Metadataid;
                                cdoc.Content_Document_Id__c = DocumentId;
                                cdoc.Parent_Object_Id__c = ParentId;

                                insert cdoc;
                        }
                }
                


                return resultmessage;

        }
        





}