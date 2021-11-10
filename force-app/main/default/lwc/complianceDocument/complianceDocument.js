/* eslint-disable eqeqeq */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, api, wire, track } from 'lwc';
import getComplianceDoc from '@salesforce/apex/complianceDocumentCtr.getComplianceDocument';
import getRelatedFiles from '@salesforce/apex/complianceDocumentCtr.getRelatedFiles';
import checkFileName from '@salesforce/apex/complianceDocumentCtr.CheckFileName';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';




export default class ComplianceDocument extends NavigationMixin(LightningElement) {
    @api isLoadedFull = false;
    @api customMetaData;
    @api recordId;
    @track lstcompdoc = [];
    @track ComDoclst;
    @track error;
    //@track columns = columns;
    @track openmodel = false;
    @track metadataid;
    @track cdrec;

    //get the compliance document
    @wire(getComplianceDoc, {sDocTypeGroup: '$customMetaData', ParentObjectId: '$recordId'})
    getComDoclst;

  
    

    //get the relatedfiles
    @wire(getRelatedFiles, {ParentObjectId: '$recordId'})
    getRelFilelst;

    //modal
    
    openmodalreplacefile(event) {
        
        this.openmodel = true;
        if(event.target.value != null){
            var wrapper = event.target.value;
            this.cdrec = wrapper.CustomCD;
            this.metadataid = wrapper.MetadataId;
        }
        
        
    }


    previewfile(event){
        var documentId = event.target.value;
        console.log(documentId);
        this[NavigationMixin.Navigate]({
            
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: documentId,
                selectedRecordId: documentId
            }
          })
    }
    openmodaladdfile(event) {
        this.openmodel = true;
        refreshApex(this.getRelFilelst);
        if(event.target.value != null){
            this.metadataid = event.target.value;
            console.log('populate metadata');
        }
    }
    closeModal() {
        this.openmodel = false
    }
    //upload new file
    savenewfile(event){
        var newfile = event.detail.files[0].documentId;
        var fstatus = 'new';


        //call function to check if the file has corresponding naming convention
        checkFileName({
            MetadataId: this.metadataid,
            DocumentId: newfile,
            ParentId: this.recordId,
            filestatus: fstatus 
        }).then(result =>{   
            if(result != 'Pass'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message:  result,
                        variant: 'sucess',
                    }), 
                );
                this.openmodel = false;
                refreshApex(this.getComDoclst);
                refreshApex(this.getRelFilelst);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message:  'Record Successfuly Created',
                        variant: 'sucess',
                    }), 
                );
                refreshApex(this.getRelFilelst);
                this.openmodel = false;
                refreshApex(this.getComDoclst);
                
            }

        })
        .catch(error =>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error,
                        variant: 'error',
                    }),
                );
        })

        
    }

    //existing file
    saveCompDoc(event){
        //loading
        this.isLoadedFull = !this.isLoadedFull;

        var selectedfiletoadd = event.target.value;
        var fstatus= 'existing';
        
        checkFileName({
            MetadataId: this.metadataid,
            DocumentId: selectedfiletoadd.ContentDocumentId,
            ParentId: this.recordId,
            filestatus: fstatus
        }).then(result =>{ 
            if(result != 'Pass'){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                    }),
                );
                refreshApex(this.getRelFilelst);
                this.openmodel = false;
                refreshApex(this.getComDoclst);
                
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'File Successfully Replaced',
                        variant: 'success',
                    }),
                );
                refreshApex(this.getRelFilelst);
                this.openmodel = false;
                refreshApex(this.getComDoclst);
                
            }
            
        })
            .catch(error =>
                {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error,
                            variant: 'error',
                        }),
                    );
                }
            )   
        this.isLoadedFull = !this.isLoadedFull;
    }

    removeComDoc(event){
        this.isLoadedFull = !this.isLoadedFull;
        
        deleteRecord(event.target.value)
        .then(() => {
            refreshApex(this.getComDoclst);
            this.isLoadedFull = !this.isLoadedFull;
        })
        // eslint-disable-next-line no-unused-vars
        .catch(error => {
            this.isLoadedFull = !this.isLoadedFull;
            this.dispatchEvent(
                
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error Encountered While Deleting record',
                    variant: 'error',
                }),
            );
        });
        
    }




}