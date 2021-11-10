import { LightningElement, api, track } from 'lwc';
import getObjectMetadata from '@salesforce/apex/EnhancedRelatedListFieldsUtility.getObjectMetadata';

export default class enhancedRelatedList extends LightningElement {

    @api recordId;
    @api objectName;
    @api customTitle;
    @api iconName;
    @api iconFullURL;
    @api relatedField;
    @api fieldSetName;
    @api selectedFields;
    @api nonColumnSelectedFields;
    @api editableFields;
    @api whereCondition;
    @api groupBy;
    @api orderBy;
    @api recordLimit;
    @api allowCreate;
    @api allowEdit;
    @api showEditButton;
    @api allowDelete;
    @api showIconButtons;
    @api allowSearch;
    @api recordsPerPage;
    @api showPaginationPicker;
    @api chartType;
    @api customChartTitle;
    @api showChart;
    @api allowShowCharts;
    @api hideRecordsShowChart;
    @api chartColour;
    @api chartLabelField;
    @api chartDataPointField;
    @api editFieldSetName;

    @track objectData;
    @track gettingMetadata = true;
    @track error;

    connectedCallback () {

        // Fieldsets don't have aggregates
        if (this.fieldSetName) {
            this.selectedFields = undefined;
            this.groupBy = undefined;
        }

        // Only allow creating, editing and deleting if we actually specified allow and this is not an aggregate query
        this.allowCreate = this.allowCreate && !this.isAggregate;
        this.allowEdit = this.allowEdit && !this.isAggregate;
        this.showEditButton = this.showEditButton && !this.isAggregate;
        this.allowDelete = this.allowDelete && !this.isAggregate;

        getObjectMetadata ({
            objectName: this.objectName,
            recordId: this.recordId,
            fieldSetName: this.fieldSetName,
            selectedFields: this.selectedFields,
            allowCreate: this.allowCreate,
            isAggregate: this.isAggregate,
        }).then((result) => {

            this.gettingMetadata = false;

            // make a copy of the result data to be able to add more properties
            this.objectData = JSON.parse(JSON.stringify(result));
            this.objectData.relatedField = this.relatedField || this.objectData.relatedField;
            this.objectData.whereCondition = this.whereCondition;
            this.objectData.groupBy = this.groupBy;
            this.objectData.orderBy = this.orderBy;
            this.objectData.recordLimit = this.recordLimit;
            this.objectData.nonColumnSelectedFields = this.nonColumnSelectedFields;
            // Clear the error
            this.error = undefined;

        }).catch((error) => {

            this.objectData = undefined;
            this.gettingMetadata = false;
            this.error = 'Error getting Metadata - ' + (error.body.message ? error.body.message : 'Unknown error');
            console.error('Error', error);
        });
    }

    get isAggregate() {
        return this.objectName.includes('__b') || this.groupBy || (this.selectedFields &&
          ['avg(','count(','count_distinct(','max(','min(','sum('].some((v) => { return this.selectedFields.toLowerCase().indexOf(v) >= 0; }));
    }

    @api
    forceRefresh() {
        this.template.querySelector('c-datatable').getTheRecords();
    }

    handleSelectRow(event){

        let selectRowSize = event.detail.selectRowSize;
         
        const selectrowrl = new CustomEvent('selectrowrl', {
            detail: { selectRowSize },
        });

        this.dispatchEvent(selectrowrl);
    }
}