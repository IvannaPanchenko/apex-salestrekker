import { LightningElement, api } from 'lwc';

export default class DatatableRow extends LightningElement {
    @api record;
    @api columns;
    @api parentId;
    @api objectName;
    @api objectNameField;
    @api relatedField;
    @api selectedRows;
    @api allowEdit;
    @api allowDelete;
    @api isAggregate;
    @api editableFields;
    @api isSaving;

    @api 
    handleSubmit () {
        let promises = [];
        this.template.querySelectorAll('c-datatable-cell').forEach(dr => promises.push(dr.handleSubmit())); 
        return promises;
    }

    @api
    handleCancel () {
        this.template.querySelectorAll('c-datatable-cell').forEach(dr => dr.handleCancel());
    }

    get canEdit () {
        return this.allowEdit || this.record.Id === undefined;
    }

    get cellClasses () {
        let classes = 'slds-col display-table-cell';

        if (this.rowSelected) classes += ' cell-selected';

        return classes;
    }

    get recordId () {
        return this.record.Id ? this.record.Id : this.record.id;
    }

    get rowSelected () {
        return this.selectedRows.indexOf(this.recordId) !== -1;
    }

    handleChangeInput () {
        const event = new CustomEvent('changefield');
        this.dispatchEvent(event);
    }

    handleSelectRow() {
        const event = new CustomEvent('selectrow', {
            detail: {
                id: this.recordId
            }
        });
        this.dispatchEvent(event);
    }

    handleError(event){

        let errMsg = event.detail.error;

        const error = new CustomEvent('error', {
        detail: {
          error: errMsg
        }
      });

        this.dispatchEvent(error);
    }
}