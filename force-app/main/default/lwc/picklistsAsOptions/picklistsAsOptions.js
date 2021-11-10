import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord, getRecord } from 'lightning/uiRecordApi';
import getPicklistsConfiguration from '@salesforce/apex/PicklistsAsOptionsController.getPicklistsConfiguration';

export default class PicklistsAsOptions extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api enforcePicklistDependencies = false;

  // api exposed in the component properties
  @api fieldNames;
  @api sectionLabels;
  @api saveEnabled;
  @api saveButtonLabel;
  @api saveButtonVariant;
  @api resetEnabled;
  @api allowSelectAll;
  @api selectAllLabel;
  @api validateLastModifiedDate;
  @api defaultChecked;

  // flow variables
  @api showFlowButton;
  @api flowButtonLabel;
  @api flowButtonVariant;

  // this field is rendered next to the buttons to add an extra option (e.g. I agree .... )
  @api extraFieldName;
  @api extraFieldLabel;

  // api not exposed to the component properties - used inside here and from the visualforce component
  @api selectValueFnc;
  @api resetValues;

  // api for the extra conga button
  @api showCongaButton;
  @api congaButtonLabel;
  @api congaButtonVariant;
  @api congaTemplates;
  @api congaQueries;
  @api congaAttributes;

  @track isSaving = false;
  @track errorSaving = false;
  @track gettingData = true;
  @track errorGetting;
  @track reloadButton = false;
  @track options = [];
  @track changed = false;

  @track pickListConfiguration = {};
  @track mainRecord = {};

  @track extraFieldChecked = false;

  @track checkedValues = {};

  @wire(getRecord, { recordId: '$recordId', fields: '$mainRecordFields' })
  getMainRecord({ error, data }) {
    if (data) {
      this.mainRecord.data = data;
      if (this.extraFieldName && data.fields[this.extraFieldName]) {
        this.extraFieldChecked = data.fields[this.extraFieldName].value || false;
      }
    } else if (error) {
      this.errorGetting =
        'Error getting data - ' + (error && error.body && error.body.message ? error.body.message : 'Unknown error');
      console.error('Error', error);
    }
  }

  connectedCallback() {
    // get the data
    this.getData();
  }

  get notChanged() {
    return !this.changed;
  }

  get mainRecordFields() {
    let fields = [`${this.objectApiName}.Id`];

    if (this.extraFieldName) fields.push(`${this.objectApiName}.${this.extraFieldName}`);

    if (this.extraFieldLabel && this.extraFieldLabel.indexOf('{{') !== -1) {
      let labelFields = this.extraFieldLabel.match(/(?<={{)(.*?)(?=}})/g);
      fields = fields.concat(labelFields);
    }
    return fields;
  }

  get labelExtraField() {
    if (this.extraFieldLabel) {
      let label = this.extraFieldLabel;
      if (label.indexOf('{{') !== -1 && this.mainRecord.data) {
        this.mainRecordFields.forEach((fl) => {
          let regex = new RegExp('{{' + fl + '}}', 'g');

          // get the field name
          let fieldName = fl.replace(`${this.objectApiName}.`, '');

          // if it is a related field
          if (fieldName.indexOf('.') !== -1) {
            let relatedFieldName = fieldName.substring(0, fieldName.indexOf('.'));
            label = label.replace(regex, this.mainRecord.data.fields[relatedFieldName].displayValue);
          } else {
            label = label.replace(regex, this.mainRecord.data.fields[fieldName].value);
          }
        });
      }
      return label;
    }

    return this.mainRecord.data.fields[this.extraFieldName].label;
  }

  getData() {
    console.log('epd' + this.enforcePicklistDependencies);
    this.gettingData = true;
    getPicklistsConfiguration({
      recordId: this.recordId,
      fieldNames: this.fieldNames,
      enforcePicklistDependencies: this.enforcePicklistDependencies,
    })
      .then((result) => {
        this.reloadButton = false;
        this.gettingData = false;
        this.isSaving = false;
        this.errorSaving = false;

        // make a copy of the result data to be able to add more properties
        this.pickListConfiguration = JSON.parse(JSON.stringify(result));
        this.pickListConfiguration.data = this.pickListConfiguration.data[0];

        // build the default checked object
        if (this.defaultChecked) {
          this.buildCheckedValues();
        }

        // initialize the options
        this.setOptionsVariable();

        // Clear the error
        this.errorGetting = undefined;
      })
      .catch((error) => {
        this.pickListConfiguration = {};
        this.gettingData = false;
        this.errorGetting =
          'Error getting data - ' + (error && error.body && error.body.message ? error.body.message : 'Unknown error');
        console.error('Error', error);
      });
  }

  buildCheckedValues() {
    // get a defauls by field
    this.defaultChecked.split(',').forEach((el) => {
      let defaultValues = el.split(':');
      this.checkedValues[defaultValues[0]] = defaultValues.slice(1);
    });
  }

  getChecked(fieldName, value) {
    // if the flag for resetting values is true, always return false
    if (this.resetValues) {
      return false;
    }

    // create an array of values selected
    let arrayChecked = [];

    // get the values from the data
    if (this.pickListConfiguration.data && this.pickListConfiguration.data[fieldName]) {
      arrayChecked = this.pickListConfiguration.data[fieldName].split(';');
    }

    // set the changed to true if the field is empty but we have default value
    if (arrayChecked.length === 0 && this.checkedValues[fieldName] && this.checkedValues[fieldName].length > 0) {
      this.changed = true;
    }

    return (
      arrayChecked.indexOf(value) !== -1 ||
      (arrayChecked.length === 0 &&
        this.checkedValues[fieldName] &&
        (this.checkedValues[fieldName].indexOf(value) !== -1 || this.checkedValues[fieldName].indexOf('all') !== -1))
    );
  }

  setOptionsVariable() {
    // empty the options
    this.options = [];

    // add the labels to an array
    let arrayLabels = this.sectionLabels ? this.sectionLabels.split(',') : [];

    this.pickListConfiguration.picklists.forEach((pickList, index) => {
      // create the picklist field object
      let thePickListField = {
        fieldName: pickList.fieldName,
        label: arrayLabels[index] || pickList.label,
        multipleSelection: pickList.multipleSelection,
        allSelected: false,
        allowSelectAll: pickList.multipleSelection && this.allowSelectAll,
        values: [],
      };

      // add the values
      for (let key in pickList.values) {
        if (pickList.values.hasOwnProperty(key)) {
          thePickListField.values.push({
            id: `${pickList.fieldName}-${key}`,
            label: pickList.values[key],
            value: key,
            checked: this.getChecked(pickList.fieldName, key) || false,
          });
        }
      }

      // selected all flag
      thePickListField.allSelected = thePickListField.values.filter((el) => !el.checked).length === 0;

      // add to the array
      this.options.push(thePickListField);
    });
  }

  handleChange(event) {
    const theOption = this.options.find((fl) => fl.fieldName === event.target.dataset.fieldname);
    // if it is not multiple selection then unselect everything
    if (!theOption.multipleSelection) {
      theOption.values.map((el) => (el.checked = false));
    }

    // select the option
    theOption.values.find((el) => el.value === event.target.value).checked = event.target.checked;
    this.changed = true;
    // set the all selected flag
    theOption.allSelected = theOption.values.filter((el) => !el.checked).length === 0;

    // this is used only in the visual force component for now
    if (this.selectValueFnc) {
      // set the variable with the new data
      let newValues = {
        [theOption.fieldName]: theOption.values
          .filter((e) => e.checked)
          .map((e) => e.value)
          .join(';'),
      };
      this.selectValueFnc(newValues);
    }
  }

  handleExtraFieldChange(event) {
    this.extraFieldChecked = event.target.checked;
    this.changed = true;
  }

  handleSave() {
    let params = {};
    const fields = { Id: this.recordId };

    this.options.forEach((value) => {
      fields[value.fieldName] =
        value.values
          .filter((j) => j.checked)
          .map((f) => f.value)
          .join(';') || '';
    });

    // check default values before save
    for (let field in fields) {
      if (fields.hasOwnProperty(field)) {
        if (
          field !== 'Id' &&
          (fields[field] === '' || fields[field] === undefined || fields[field] === null) &&
          this.checkedValues[field]
        ) {
          fields[field] = this.checkedValues[field].join(';');
        }
      }
    }

    if (this.validateLastModifiedDate) {
      params = { ifUnmodifiedSince: this.pickListConfiguration.data.LastModifiedDate };
    }

    // add the extra field
    if (this.extraFieldName) {
      fields[this.extraFieldName] = this.extraFieldChecked;
    }

    this.isSaving = true;

    console.log('fieds >>>> ' + fields);

    // update the record if it was not changed after the last modified date
    updateRecord({ fields }, params)
      .then(() => {
        this.changed = false;
        this.isSaving = false;
        this.errorSaving = false;
        this.resetValues = false;
        this.pickListConfiguration.data = Object.assign({}, this.pickListConfiguration.data, fields);

        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: `Records saved successfully`,
            variant: 'success',
          })
        );
      })
      .catch((error) => {
        this.reloadButton = true;
        this.changed = false;
        this.isSaving = false;

        let errorMessage = '';

        if (error.body && error.body.output && error.body.output.errors) {
          error.body.output.errors.forEach((err) => {
            errorMessage += err.message;
          });
        } else errorMessage = error.body.message;

        this.errorSaving = errorMessage;
        console.error('Error', errorMessage);
      });
  }

  handleCallFlow() {
    const fireEvent = new CustomEvent('ButtonPressed');

    //Fire Event
    this.dispatchEvent(fireEvent);
  }

  handleReset(e) {
    this.changed = true;
    this.resetValues = true;
    // initialize the options
    this.setOptionsVariable();
  }

  handleCancel(e) {
    this.changed = false;
    this.resetValues = false;
    // initialize the options
    this.setOptionsVariable();
  }

  handleSelectAll(event) {
    const theOption = this.options.find((fl) => fl.fieldName === event.target.dataset.fieldname);
    theOption.allSelected = event.target.checked;

    theOption.values.forEach((val) => {
      event.target.value = val.value;
      this.handleChange(event);
    });
  }
}