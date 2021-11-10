import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getApiURL from '@salesforce/apex/CongaButtonController.getApiURL';
import callMethod from '@salesforce/apex/CongaButtonController.callMethod';
import CONGA_URL_SCHEMA from '@salesforce/label/c.CONGA_URL_SCHEMA';

export default class CongaButton extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    @api buttonLabel;
    @api buttonVariant;
    @api buttonDisabled = false;
    @api congaTemplates;
    @api congaQueries;
    @api congaAttributes;
    @api validationMethod;

    @track showAlert = false;
    @track textAlert;

    @wire(getApiURL)
    salesforceURL;

    @wire(getRecord, { recordId: '$recordId', fields: '$columns' })
    objectData;

    get allFields () {
        let fields = [];
        let templateFields = this.congaTemplates ? this.congaTemplates.match(/(?<={{)(.*?)(?=}})/g) : [];
        let queryFields = this.congaQueries ? this.congaQueries.match(/(?<={{)(.*?)(?=}})/g) : [];
        let attributeFields = this.congaAttributes ? this.congaAttributes.match(/(?<={{)(.*?)(?=}})/g) : [];
       
        if (templateFields) fields = fields.concat(templateFields);
        if (queryFields) fields = fields.concat(queryFields);
        if (attributeFields) fields = fields.concat(attributeFields);

        return fields;
    }

    get columns () {
        let result = [];
        
        this.allFields.filter(fl => fl && fl.indexOf(this.objectApiName) !== -1).forEach(fl => {
            result.push(fl);
        });

        if (result.length === 0) {
            result.push(`${this.objectApiName}.Id`);
        }

        return result;
    }

    validateBeforeCall() {
        return new Promise((resolve) => {
            if (this.validationMethod) {
                let className = this.validationMethod.split('.')[0];
                let methodName = this.validationMethod.split('.')[1];
                callMethod({ className: className, methodName: methodName, recordId: this.recordId }).then((res) => {
                    resolve(res);
                })
            } else {
                resolve();
            }
        })
    }

    handleClick () {
        this.validateBeforeCall().then((res) => {
            if (res) {
                this.showAlert = true;
                this.textAlert = res;
            }
            else {
                let newTemplates = this.congaTemplates || '', newQueries = this.congaQueries || '', newAttributes = this.congaAttributes || '';
                let result;
                let regex;
                let promises = [];
                let indexMethod = 0;
                
                result = CONGA_URL_SCHEMA.replace('SALESFORCE_URL',this.salesforceURL.data).replace('RECORD_ID',this.recordId);
                
                // replace field in template and query
                this.allFields.forEach(fl => {
                    let type = fl.split('.')[0];
                    let name = fl.split('.')[1];

                    regex = new RegExp('{{' + fl + '}}', 'g');

                    if (type === this.objectApiName) {
                        newTemplates = newTemplates.replace(regex, this.objectData.data.fields[name].value);
                        newQueries = newQueries.replace(regex, this.objectData.data.fields[name].value);
                        newAttributes = newAttributes.replace(regex, this.objectData.data.fields[name].value);
                    }
                    else {
                        if (type.indexOf('CM_') !== -1) {
                            promises.push(callMethod({ className: type.replace('CM_', ''), methodName: name, recordId: this.recordId }));
                            newTemplates = newTemplates.replace(regex, `##${indexMethod}##`);
                            newQueries = newQueries.replace(regex, `##${indexMethod}##`);
                            newAttributes = newAttributes.replace(regex, `##${indexMethod}##`);

                            indexMethod ++;
                        }
                    }
                });

                // Replace everything
                result = result.replace('CONGA_TEMPLATES', newTemplates).replace('CONGA_QUERIES', newQueries).replace('CONGA_ATTRIBUTES', newAttributes);

                // if we have classes
                if (promises.length > 0) {
                    Promise.all(promises).then((res) => {
                        res.forEach((data, index) => {
                            regex = new RegExp('(##)(' + index + ')(##)', 'g');
                            result = result.replace(regex, data);
                        })

                        // open conga
                        window.open(result, '_blank');
                    })
                } else {
                    // open conga
                    window.open(result, '_blank');
                }
            }
        })
    }

    closeAlert () {
        this.showAlert = false;
    }
}