import { LightningElement, api, track, wire } from 'lwc';
import { getFieldValue } from 'lightning/uiRecordApi';
import getFieldSetFieldsByFieldSetName from '@salesforce/apex/HelperClass.getFieldSetFieldsByFieldSetName';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class DatatableEditModal extends LightningElement {

    @api record;
    @api objectname;
    @api editFieldSetName;
    @api editMenuFields

    @wire(getFieldSetFieldsByFieldSetName, {objectApiName: '$objectname', fieldSetName: '$editFieldSetName'})
    wiredFields({error, data}){
        if(data){
            this.editMenuFields = data;
        }
    }


    get formId () {
        return this.objectname + this.recordid + 'form';
    }

    get recordid(){
        return this.record.Id;
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    handleSuccess(){
      
        this.dispatchEvent(new CustomEvent('success'));
    }

    handleError(event){

        let err = event.detail;
      
        event = new ShowToastEvent({
            variant: 'error',
            title: 'Error!',
            message: 'Unable to update record: '+ JSON.stringify(err.detail),
        });

        this.dispatchEvent(event);

    }

    connectedCallback () {  
        //this.editFieldSetName = 'KAR_Edit_Form_{RecordType}';
       
        if(this.editFieldSetName.toLowerCase().includes('{recordtype}')){
          this.editFieldSetName = this.editFieldSetName.toLowerCase().replaceAll('{recordtype}', this.record.RecordType.DeveloperName.toLowerCase());
        }

    }


}