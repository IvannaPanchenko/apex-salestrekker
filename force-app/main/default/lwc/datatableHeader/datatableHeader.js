import { LightningElement, api, track } from 'lwc';

export default class DatatableHeader extends LightningElement {
    @api field;
    @api order;

    sortTable() {
        const event = new CustomEvent('sort', {
            detail: {
                field: this.field.fieldName,
                dir: this.order && this.order.dir === 'ASC' ? 'DESC' : 'ASC'
            }
        });
        this.dispatchEvent(event);
    }

    get ordered () {
        return this.order && this.order.field === this.field.fieldName;
    }

    get orderIcon () {
        return this.order && this.order.dir === 'ASC' ? 'utility:arrowup' : 'utility:arrowdown';
    }
}