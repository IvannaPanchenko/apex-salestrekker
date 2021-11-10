import { LightningElement, api, wire, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getPicklistOptions from '@salesforce/apex/AssetLiabilityPicklistController.getPicklistOptions';

export default class AssetLiabilityPicklist extends LightningElement {

    @api objectName;
    @api accountId;
    @api partnerId;
    @api label;
    @api required;
    @api value; 

    @track options;

    @track error;

    @wire(getPicklistOptions, {
        accountId: '$accountId', 
        partnerId: '$partnerId', 
        objectName: '$objectName'
    })
    wiredResult(result) { 
        if (result.data) {
            this.options = result.data;
        }
        else if (result.error) {
            this.error = error;
        }
    }

    handleChange(event) { 
        this.value = event.detail.value;
        // Now need to add the change event to inform the Flow that the event has changed
        const attributeChangeEvent = new FlowAttributeChangeEvent('value', this.value);
        this.dispatchEvent(attributeChangeEvent);
    } 

    // Validate that a value is selected
    @api
    validate() {
        // If required field and has no value
        if (this.required && !this.value) { 
            return { 
                isValid: false, 
                errorMessage: 'Field is required.' 
            }; 
        } 
        else { 
            return { 
                isValid: true 
            }; 
        }
    }
}