import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getFieldValue } from 'lightning/uiRecordApi';


export default class DatatableCell extends LightningElement {
    @api record;
    @api field;
    @api canEdit;
    @api relatedField;
    @api parentId;
    @api objectName;
    @api isAggregate;
    @api editableFields;
    @api isSaving;

    @track hasChanged = false;
    @track hasLoaded = false;

    @api recordTypeId;
    @track options;
    @track cbtaValue;

    characterLimit = 45;

    get displayForm () {
      return !this.isAggregate && !this.field.fieldName.includes('.');
    }

    get formId () {
        return this.objectName + this.field.fieldName + this.record.id + 'form';
    }

    get data () {
      let data; 
      this.field.fieldName.split('.').forEach((fN) => {
        data = data ? data[fN] : this.record[fN];
      });
      if ((this.field.type === 'date' || this.field.type === 'datetime') && !!data) {
        data = new Date(data).toLocaleString();
      }
      return data;
    }

    get formClasses () {
      return this.hasLoaded ? '' : 'slds-hidden';
    }

    get valueFieldToShow () {
        if (this.field.fieldName.includes('.')) {
            let relatedFieldName = this.field.fieldName.split('.')[0];
            return this.record[relatedFieldName][this.field.fieldName.split('.')[1]];
        }

        if (this.field.type === 'percent') return this.record[this.field.fieldName] / 100;

        return this.record[this.field.fieldName];
    }

    
    get isLongValue(){
      //text with actually long values regardless if its textarea or not
      let val = this.valueFieldToShow;
     
      return val && val.length > this.characterLimit;
    }

    get isTextarea(){
      return this.field.type === 'textarea';
    }

    get isNumberField () {
        return this.field.type === 'percent' || this.field.type === 'currency' || this.field.type === 'number';
    }

    get isDateField () {
        return this.field.type === 'date' || this.field.type === 'datetime';
    }

    get isReferenceField () {
        return this.field.type === 'reference' || this.field.fieldName.indexOf('.Name') !== -1 || this.field.fieldName.indexOf('.CaseNumber') !== -1;
    }

    get isHyperLink(){
      let val = this.valueFieldToShow;
      
      return val && isNaN(val) && val.substring(0, 8) == '<a href=';
    }

    get isPickList(){

      return this.field.type === 'picklist';
    }

    get referenceIdField () {
        if (this.isReferenceField) {
            let relatedFieldName = this.field.fieldName.split('.')[0];
            if (relatedFieldName.indexOf('__r') !== -1) {
                relatedFieldName = relatedFieldName.replace('__r', '__c');
            }

            return this.record[relatedFieldName];
        }

        return null;
    }

    get fieldApiName(){
        return this.objectName + '.' + this.field.fieldName;
    }

    @api
    handleSubmit () {
      if (!this.hasChanged) return;
      return new Promise((resolve) => resolve(this.template.querySelector('lightning-record-edit-form').submit()));
    }

    @api
    handleCancel () {
      this.template.querySelectorAll('lightning-input-field').forEach(field => {
        field.reset();
      });
    }
    
  get isEditableField() {
     
      if (this.canEdit && this.editableFields) {
       
        return this.editableFields.split(',').includes(this.field.fieldName);
      }
      return this.canEdit && !this.isHyperLink && this.field.isUpdateable;  
    }

    handleChangeInput () {
    
      this.hasChanged = true;
      const event = new CustomEvent('changefield');
      this.dispatchEvent(event);
    }

    handleChangeInputCBTA(event){
      
      if(event.detail !== undefined)
        this.cbtaValue = event.detail.value;
      else if (event.target !== undefined) {
        this.cbtaValue =event.target.value;
      }

      this.handleChangeInput();
    
    }

    handleOnLoad () {
      this.hasLoaded = true;
      this.cbtaValue = this.record[this.field.fieldName];
    }

    customTextWrap(str, maxLength) {
        if (str.length <= maxLength)
          return str;
        var reg = new RegExp(".{1," + maxLength + "}", "g");
        var parts = str.match(reg);

        if(parts)
          return parts.join('\n');
        else
          return str;
    }



    @wire(getObjectInfo, { objectApiName: '$objectName' })
    getObjectData({ error, data }) { 
        if (data && this.isPickList) { 
            if (this.recordTypeId == null){
                this.recordTypeId = data.defaultRecordTypeId;
            }       
        } else if (error) {
            console.log(error);
        }
    }
   
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$fieldApiName'})
    getPicklistValues({ error, data }) {
        if (data && this.isPickList) {
          
            //console.log('pldata '+ JSON.stringify(data.values));

            this.options  = [];

            for(var dataVal in data.values){

              var plValue = this.getActualPicklistValue(data.values[dataVal].value); 

              if(!plValue.startsWith('{!') && !plValue.endsWith('}')){

                this.options.push({label:plValue, value:plValue});

              }
            }

        } else if (error) {

            console.log(error);
        }
    }
    

    getActualPicklistValue(plValue){
     
      if(plValue.startsWith('{!') && plValue.endsWith('}')){
       
        var fieldName = plValue.replace('{!','').replace('}','');

        var actualPLValue = this.record[fieldName];

        return actualPLValue ? actualPLValue : plValue;
      }
      else{
        return plValue;
      }
    }

    handleError(event){
      let errMsg = event.detail.detail;
      console.log('cell error '+JSON.stringify(errMsg));

      const err = new CustomEvent('err', {
        detail: {
          error: errMsg
        }
      });

      this.dispatchEvent(err);
    }


}