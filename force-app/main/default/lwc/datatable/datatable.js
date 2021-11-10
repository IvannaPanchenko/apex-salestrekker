import { LightningElement, api, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/EnhancedRelatedListController.getRecords';
import rollupCalculation from "@salesforce/apex/LookupRollupCalculator.calculateRollupOfParentRecord";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';



export default class Datatable extends LightningElement {
    @api parentId;
    @api objectData;
    @api customTitle;
    @api iconName;
    @api iconFullUrl;
    @api allowCreate;
    @api allowEdit;
    @api showEditButton;
    @api allowDelete;
    @api showIconButtons;
    @api allowSearch;
    @api editableFields;
    @api recordsPerPage;
    @api showPaginationPicker;
    @api isAggregate;
    @api chartType;
    @api customChartTitle;
    @api showChart;
    @api allowShowChart;
    @api hideRecordsShowChart;
    @api chartColour;
    @api chartLabelField;
    @api chartDataPointField;
    @api editFieldSetName;

    @track records;
    @track pagedRecordList = [];
    @track isEditable = false;
    @track isLoading = true;
    @track isSaving = false;
    @track formNotChanged = true;
    @track selectedRows = [];
    @track orderClient;
    @track error;
    @track showDeleteModal = false;
    @track queryTerm;
    @track currentPageNumber = 1;
    @track isEditRowModalVisible;
    @track cellError;

    connectedCallback () {  
        this.isEditable = !this.showEditButton;
        this.recordsPerPage = this.recordsPerPage ? this.recordsPerPage : 5;
        this.originalRecordsPerPage = this.recordsPerPage;
        this.getTheRecords();
        this.cellError = [];
    }

    get title() {
        return this.customTitle ? this.customTitle : this.objectData.pluralLabel;
    }

    get showRecords() {
        return !this.hideRecordsShowChart || !this.showChart;
    }

    get stringColumns() {
        return this.objectData.fields.map((cl) => { 
            let fn = cl.fieldName;
            // If we have aggregate functions
            if (cl.aggregateFunctions) {
                // Apply each function in reverse
                cl.aggregateFunctions.split(',').reverse().forEach((fx) => { fn = `${fx}(${fn})`; });
                // Set the alias as the field name
                fn = `${fn} ${cl.fieldName}`;
            }
            return fn;
        }).join(',');
    }

    get hasRecords () {
        return this.records.length > 0;
    }

    get disableDeletion() {
        return this.selectedRows.length === 0;
    }

    get disableEditRow() {
        
        return this.selectedRows.length !== 1;
    }

    get showEditRow(){

        return this.editFieldSetName && JSON.stringify(this.objectData).toLowerCase().includes("recordtype.developername");
    }

    get selectedRow(){
      
        let recordId = this.selectedRows[0];
        let selectedRecord;

        for(var rec in this.records){
           
            if(this.records[rec].Id == recordId){
                selectedRecord = this.records[rec];
                break;
            }
        }
        
        return selectedRecord;
    }

    get objectName(){
        return this.objectData.objectName;
    }

    get canCreate () {
        return this.allowCreate && this.objectData.isCreateable && !this.hideRecordsShowChart;
    }

    get canEdit () {
        return this.allowEdit && this.objectData.isUpdateable && this.isEditable && !this.hideRecordsShowChart;
    }

    get showEdit () {
        return this.records.length > 0 && this.allowEdit && this.showEditButton && !this.hideRecordsShowChart;
    }

    get editableLabel () {
        return this.isEditable ? 'Cancel Edit' : ' Edit';
    }

    get editableVariant () {
        return this.isEditable ? 'brand' : 'base';
    }

    get showChartVariant () {
        return this.showChart ? 'brand' : 'base';
    }

    get canDelete () {
        return this.allowDelete && this.objectData.isDeletable && !this.hideRecordsShowChart;
    }

    get canCreateOrEdit () {
        return this.canCreate || this.canEdit;
    }

    get allSelected () {
        return this.pagedRecordList.length === this.selectedRows.length;
    }

    get clientOrder () {
        if (!this.orderClient && !!this.objectData.orderBy) {
            const splitByComma = this.objectData.orderBy.split(',');
            const splitBySpace = splitByComma[0].split(' ');
            return { field: splitBySpace[0], dir: splitBySpace[1] || 'ASC' };
        }
        return this.orderClient;
    }

    get queryTotals () {
        return !!this.queryTerm ? `Showing ${this.records.length} of ${this.recordsOriginal.length} ${this.title}` : '';
    }

    get maxPageNumber () {
        return Math.ceil(this.records.length / this.recordsPerPage);
    }

    get showPagination () {
        return this.maxPageNumber > 1;
    }

    get currentPageLabel () {
        return this.currentPageNumber + ' / ' + this.maxPageNumber;
    }

    get canGoPrevPage () {
        return !(this.currentPageNumber > 1);
    }

    get canGoNextPage () {
        return !(this.currentPageNumber < this.maxPageNumber);
    }

    get recordsPerPageOptions () {
        let recordsPerPageOptions = [5, 10, 25, 50, 100, 200];
        if (!recordsPerPageOptions.includes(this.originalRecordsPerPage)) {
            recordsPerPageOptions.push(this.originalRecordsPerPage);
            recordsPerPageOptions.sort((a, b) => a - b);
        }
        let finalOptions = [];
        for (let index in recordsPerPageOptions) {
            let val = recordsPerPageOptions[index];
            finalOptions.push({ label: val, value: val });
        }
        return finalOptions;
    }

    @api
    getTheRecords () {

        this.recordsOriginal = [];
        this.records = [];
        this.pagedRecordList = [];
        this.isSaving = true;
        this.formNotChanged = true;

        const tmpShowChart = this.showChart;
        this.showChart = false;
      
        getRecords({
            parentId: this.parentId,
            objectName: this.objectData.objectName,
            relatedField: this.objectData.relatedField,
            columns: this.stringColumns,
            nonColumns: this.objectData.nonColumnSelectedFields,
            whereCondition: this.objectData.whereCondition,
            groupBy: this.objectData.groupBy,
            order: this.objectData.orderBy,
            recordLimit: this.objectData.recordLimit,
        }).then((result) => {

            this.isLoading = false;
            let index = 0;
            this.recordsOriginal = result.map(rc => {
                const newRec = {...rc};
                newRec.id = 'row-' + index;
                index++;
                return newRec;
            });
            this.records = this.recordsOriginal.slice();
            this.error = undefined;
            this.doSearch();
            this.showChart = tmpShowChart;

        }).catch((error) => {

            this.isLoading = false;
            this.isSaving = false;
            this.records = [];
            this.error = 'Error getting Records - ' + (error.body.message ? error.body.message : 'Unknown error');
            console.error('Error', error);

        });
    }

    toggleEditable () {
        this.isEditable = !this.isEditable;
      
        const toggleedit = new CustomEvent('toggleedit', {
            detail: {
            isEditable: this.isEditable
            }
        });

        this.dispatchEvent(toggleedit);
    }

    toggleChartDisplay () {
        this.showChart = !this.showChart;
    }

    toggleDeleteModal () {
        this.showDeleteModal = !this.showDeleteModal;
    }

    handleChangeInput () {
        this.formNotChanged = false;
    }

    handleSave() {
        this.isSaving = true;
        let promises = [];
        this.template.querySelectorAll('c-datatable-row').forEach(
            dr => promises = promises.concat(dr.handleSubmit()));

        Promise.all(promises).then(() => { 
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            window.setTimeout(() => this.handleAfterSubmit({ type: 'save', }), 50 * promises.length);
            //window.setTimeout(() => stimulateRollupCalculation({recordId:sampleRecordId}), 350 * promises.length);
        }). catch((e) => {
            this.handleAfterSubmit({ error: e.message });
        })
    }

    handleCancel() {
        this.formNotChanged = true;

        // Select any rows that have no Id
        this.selectedRows = this.records.filter(sl => !sl.Id).map(sl => sl.id);

        // delete rows not saved
        this.handleDeleteRows();

        // reset fields
        this.template.querySelectorAll('c-datatable-row').forEach(dr => dr.handleCancel());
    }

    handleAfterSubmit (params) {
       
        this.formNotChanged = true;
        this.isLoading = false;
        this.isEditable = !this.showEditButton;

        rollupCalculation({ parentRecordId: this.parentId })
        .then((result) =>{

            let resultStrValue = JSON.stringify(result).replaceAll('"','');
    
            if(resultStrValue.length > 0){
                console.log('rollup update');
                updateRecord({fields:{Id: this.parentId}});
            }
        
        });

        if(this.cellError.length > 0){
           this.cellError = this.cellError.filter(this.uniqueValues);
           params.error = 'Error(s) in one or more of the rows: ' + this.cellError;
           this.cellError = [];
        }

        if (!params.error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `${this.title} saved succesfully!`,
                variant: 'success'
            }));
            return this.getTheRecords();
        }

        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: `Error saving/deleting ${this.title} - ${params.error}`,
            variant: 'error',
            mode: 'dismissable'
        }));
        return this.getTheRecords();
    }

    handleDeleteRows() {
        this.showDeleteModal = false;

        const selectedDBRows = this.selectedRows.filter(sl => sl.indexOf('row-') === -1);
        const selectedNonDBRows = this.selectedRows.filter(sl => sl.indexOf('row-') !== -1);

        // remove the DB Rows
        if (selectedDBRows.length > 0) {
            const promises = selectedDBRows.map(sr => deleteRecord(sr));

            this.isSaving = true;
            Promise.all(promises).then(() => {
                this.handleAfterSubmit({ type: 'delete' });
            }).catch(error => {
                console.error('Error:', error.body);
                let errorMsg = 'Unknown error';
                if (Array.isArray(error.body)) {
                    errorMsg = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    errorMsg = error.body.message;
                }
                if (error.body.output.errors) {
                    errorMsg += ' ' + error.body.output.errors.map(e => e.message).join(', ');
                }
                console.error('Error Msg:', errorMsg);
                this.handleAfterSubmit({ error: errorMsg });
            });
        }

        // remove the local rows
        if (selectedNonDBRows.length > 0) {
            this.records = [...this.records.filter(rc => selectedNonDBRows.indexOf(rc.id) === -1)];
            this.goToFirstPage();
        }

        // remove selected rows
        this.selectedRows = [];
        this.formNotChanged = this.records.filter(rc => !rc.Id).length === 0;
    }

    handleSort (event) {
        this.isSaving = true;

        this.orderClient = event.detail;

        const newRecords = [...this.records];

        newRecords.sort((a, b) => {
            let aVal = a[this.orderClient.field] ? a[this.orderClient.field].toString() : '';
            let bVal = b[this.orderClient.field] ? b[this.orderClient.field].toString() : '';
            return this.orderClient.dir === "ASC" ?
              aVal.toString().localeCompare(bVal.toString())
              : -(aVal.toString().localeCompare( bVal.toString()));
        });

        this.records = [...newRecords];

        this.isSaving = false;
        this.goToFirstPage();
    }

    handleAddNewRow() {
        const newRow = {};
        this.objectData.fields.forEach(fl => {
            newRow[fl.fieldName] = fl.defaultValue || '';
        });

        newRow.id = 'row-' + this.records.length;

        this.records = [newRow, ...this.records];
        this.formNotChanged = false;

        this.goToFirstPage();
    }

    handleSelectRow(event) {
        // if it not exists add the id, else remove it
        const id = event.detail.id; 
       
        const index = this.selectedRows.indexOf(id); 
        if (index === -1) this.selectedRows.push(id);
        else this.selectedRows.splice(index, 1);
    }

    handleSelectAllRows(event) {
        this.selectedRows = [];
        this.pagedRecordList.forEach(rec => {
            if (event.target.checked) this.selectedRows.push(rec.Id ? rec.Id : rec.id);
        });
    }

    handleSearchInput(evt) {
        if (this.queryTerm !== evt.target.value) {
            this.queryTerm = evt.target.value;
            this.doSearch();
        }
    }

    doSearch() {
        if (this.queryTerm || (this.records.length !== this.recordsOriginal.length)) {
            // If we have this search already, clear it (debounce)
            if (this.delayTimeout) window.clearTimeout(this.delayTimeout);
            // Do the search
            this.delayTimeout = setTimeout(() => {
                this.isSaving = true;
                // Reset the records filter
                this.records = this.recordsOriginal.slice();
                // Filter the records
                this.records = this.records.filter((record) => {
                    // For each record field check if it contains the search term
                    return this.objectData.fields.some((field) => {
                        return (field.fieldName.split('.').reduce((obj, fieldName) => obj[fieldName] ? obj[fieldName] : '', record)).toString().includes(this.queryTerm);
                    });
                });
                this.goToFirstPage();
                this.isSaving = false;
            }, 500);
        } else {
            this.goToFirstPage();
        }
    }

    pageRecordList(event) {
        if (event) this.recordsPerPage = parseInt(event.detail.value);
        this.isSaving = true;
        this.pagedRecordList = this.records
          .slice(this.recordsPerPage * (this.currentPageNumber - 1), this.recordsPerPage * this.currentPageNumber);
        this.isSaving = false;
    }

    goToFirstPage() {
        this.currentPageNumber = 1;
        this.clearSelected();
        this.pageRecordList();
    }

    goToPrevPage() {
        this.currentPageNumber -= 1;
        this.clearSelected();
        this.pageRecordList();
    }

    goToNextPage() {
        this.currentPageNumber += 1;
        this.clearSelected();
        this.pageRecordList();
    }

    goToLastPage() {
        this.currentPageNumber = this.maxPageNumber;
        this.clearSelected();
        this.pageRecordList();
    }

    clearSelected() {
        this.handleSelectAllRows({ target: { checked: false } });
    }

    handleEditRow (){
       this.isEditRowModalVisible = true;
    }

    closeModal() {
        this.isEditRowModalVisible = false;
    }
    
    handleFinishEdit(event){

        this.closeModal();
        this.getTheRecords();
    }

    handleError(event){
         let errMsg = event.detail.error;
         this.cellError.push(errMsg);
    }

    uniqueValues(value, index, self) {
        return self.indexOf(value) === index;
    }

}