import { LightningElement, wire, api, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { COUNTRIES, getAddresses, getAddressDetails } from 'c/nzPostAPIHelpers';
import getTokenAndData from '@salesforce/apex/NZPostAPIService.getTokenAndData';

export default class NZPostAddress extends LightningElement {
    @api recordId;
    @api objectApiName;

    @api showMap;

    @api qtyRecordsToShow;
    @api editEnabled;
    @api editAlwaysEnabled;
    @api showButtons;
    @api internationalSearch;
    @api showAustraliaAsOption;

    @api labelToShow;
    @api streetField;
    @api suburbField;
    @api cityField;
    @api countryField;
    @api postalCodeField;

    // from visualforce page
    @api setValueToFields;
    @api streetValue;
    @api suburbValue;
    @api cityValue;
    @api countryValue;
    @api postalCodeValue;

    @track token;
    @track apiURL;

    @track streetToShow;
    @track cityToShow;
    @track countryToShow;
    @track suburbToShow;
    @track postalCodeToShow;

    @track searchedResults = [];
    @track loadingAddresses = false;
    @track noRecordsFound = false;

    @track searchType = COUNTRIES.NEW_ZEALAND.CODE;

    @track finishLoaded = false;
    @track gettingToken = false;
    @track isSaving = false;
    @track isNotChanged = true;
    @track editing = false;
    @track searchText = '';
    @track error;

    connectedCallback () {
        window.addEventListener("click", () => {
            this.searchedResults = [];
        });

        // if it's always editing then get the token at the beginning
        if (this.editAlwaysEnabled) {
            this.getTokenData();
        }
    }

    disconnectedCallback () {
        window.removeEventListener("click", () => {
            this.searchedResults = [];
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields' })
    getMainRecordData(result) {
        this.wiredResult = result;
        if (result.data) {
            this.streetToShow = this.streetValue || result.data.fields[this.streetField].value;
            this.cityToShow = this.cityValue || result.data.fields[this.cityField].value;
            this.countryToShow = this.countryValue || result.data.fields[this.countryField].value;
            this.suburbToShow = this.suburbValue || result.data.fields[this.suburbField].value;
            this.postalCodeToShow = this.postalCodeValue || result.data.fields[this.postalCodeField].value;

            this.error = undefined;
        } else if (result.error) {
            this.error = `Error getting main record data - ${
                result.error.body.message
                    ? result.error.body.message
                    : 'Unknown error'
            }`;
        }
    }

    get fields() {
        return [
            `${this.objectApiName}.${this.streetField}`,
            `${this.objectApiName}.${this.cityField}`,
            `${this.objectApiName}.${this.countryField}`,
            `${this.objectApiName}.${this.suburbField}`,
            `${this.objectApiName}.${this.postalCodeField}`
        ];
    }

    get isEditing() {
        return this.editAlwaysEnabled || this.editing;
    }

    get dropdownClasses() {
        let dropdownClasses =
            'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        if ((this.searchedResults.length > 0 || this.loadingAddresses || this.noRecordsFound) && this.searchText.trim().length > 3) {
            dropdownClasses += ' slds-is-open';
        }

        return dropdownClasses;
    }

    get inputSearchClasses () {
        if (this.internationalSearch) {
            return 'slds-size--5-of-7';
        }

        return 'slds-size--1-of-1';
    }

    get searchTypeOptions () {
        // add New Zealand as first option
        let options = [{ label: COUNTRIES.NEW_ZEALAND.NAME, value: COUNTRIES.NEW_ZEALAND.CODE }];

        // if the international search is enabled
        if (this.internationalSearch) {
            // if Australia is enabled
            if (this.showAustraliaAsOption) {
                options.push({ label: COUNTRIES.AUSTRALIA.NAME, value: COUNTRIES.AUSTRALIA.CODE });
            }

            // add the other countries to the search
            options.push({ label: COUNTRIES.OTHER.NAME, value: COUNTRIES.OTHER.CODE });
        }

        return options;
    }

    getTokenData () {
        this.gettingToken = true;
        getTokenAndData()
            .then(res => {
                if (res.tokenResponse.errors) {
                    this.error = `Error getting main record data - ${res.tokenResponse.errors.message}`;
                    this.token = undefined;
                } else {
                    this.gettingToken = false;
                    this.editing = !this.editing;
                    this.token = res.tokenResponse.access_token;
                    this.apiURL = res.apiURL;

                    this.error = undefined;
                }
            })
            .catch(error => {
                this.token = undefined;
                this.error = `Error getting main record data - ${
                    error.body.message
                        ? error.body.message
                        : 'Unknown error'
                }`;
            });
    }

    get addressFinderType () {
        if (this.searchType === 'NZ') {
            return 'domestic';
        }

        return 'international';
    }

    handleSearch(event) {
        this.searchText = event.target.value;

        if (this.searchText.trim().length > 3) {
            this.loadingAddresses = true;
            this.searchedResults = [];
            this.noRecordsFound = false;
            getAddresses(
                this.token,
                `${this.apiURL}/${this.addressFinderType}`,
                this.qtyRecordsToShow,
                this.searchText,
                this.internationalSearch ? this.searchType : undefined
            )
                .then(res => {
                    this.loadingAddresses = false;
                    if (res.length === 0) {
                        this.noRecordsFound = true;
                    } else {
                        this.noRecordsFound = false;
                        this.searchedResults = res;
                    }
                })
                .catch(error => {
                    this.error = `Error requesting the address from NZ Post - ${
                        error.errors.message
                            ? error.errors.message
                            : 'Unknown error'
                    }`;
                });
        } else {
            this.searchedResults = [];
        }
    }

    handleSelectAddress(event) {
        const selectedId = event.currentTarget.dataset.id;

        if (selectedId) {
            this.isSaving = true;
            getAddressDetails(
                this.token,
                `${this.apiURL}/${this.addressFinderType}`,
                selectedId,
                this.internationalSearch ? this.searchType : undefined
            )
                .then(res => {
                    this.isSaving = false;
                    this.searchedResults = [];

                    // build the street field
                    const unit = res.unit_type
                        ? `${res.unit_type} ${res.unit_value}`
                        : '';
                    const floor = res.floor ? `Floor ${res.floor}` : '';
                    const streetFullNumber = res.street_number
                        ? `${res.street_number}${res.street_alpha || ''}`
                        : '';
                    this.streetToShow = res.street
                        ? `${streetFullNumber} ${res.street}` +
                          (res.street_type ? ` ${res.street_type}` : '') +
                          (res.rural_delivery_number ? ` ${res.rural_delivery_number}` : '') +
                          (unit ? `. ${unit}` : '') +
                          (floor ? `. ${floor}` : '')
                        : '';
                    this.suburbToShow = res.suburb;
                    this.cityToShow = res.city || res.state;
                    this.postalCodeToShow = res.postcode;
                    this.countryToShow = res.country;
                    this.isNotChanged = false;
                    this.searchText = '';

                    // if we have a function to call, then call it with the new values
                    if (this.setValueToFields) {
                        const newValues = {
                            City: this.cityToShow,
                            Suburb: this.suburbToShow,
                            Country: this.countryToShow,
                            PostalCode: this.postalCodeToShow,
                            Street: this.streetToShow
                        };

                        this.setValueToFields(newValues);
                    }
                })
                .catch(error => {
                    this.error = `Error requesting the address from NZ Post - ${
                        error.errors.message
                            ? error.errors.message
                            : 'Unknown error'
                    }`;
                });
        }
    }

    handleChangeInput(event) {
        this.isNotChanged = false;

        if (this.setValueToFields) {
            const newValue = {
                [event.currentTarget.dataset.name]: event.target.value
            };

            this.setValueToFields(newValue);
        }
    }

    handleSave(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        this.isSaving = true;
        this.template
            .querySelector('lightning-record-edit-form')
            .submit(fields);
    }

    handleSaveSuccess() {
        this.isSaving = false;
        if (!this.editAlwaysEnabled) this.handleToggleEdit();
        this.isNotChanged = true;
    }

    handleCancel() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
                // reset the fields to show
                this[`${field.dataset.name.charAt(0).toLowerCase() + field.dataset.name.slice(1)}ToShow`] = field.value;
            });
        }
        this.isNotChanged = true;
        if (!this.editAlwaysEnabled) this.handleToggleEdit();
    }

    handleToggleEdit() {
        if (!this.editing) {
            this.getTokenData();
        } else {
            this.editing = !this.editing;
            this.searchType = COUNTRIES.NEW_ZEALAND.CODE;
            this.searchText = '';
        }
    }

    handleOnLoad() {
        this.finishLoaded = true;
    }

    handleSelectSearchType(event) {
        this.searchType = event.detail.value;
    }
}