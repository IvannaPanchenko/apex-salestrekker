/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         2019-07-22
 * @description  DetailQueryAbstract
 * 
 * CHANGE LOG
 * 2019-07-22 - Initial Setup of DetailQueryAbstract
 **/
global abstract class EnhancedRelatedListQueryAbstract {

    /**
     * @author       Tiaan Swart (tswart@deloitte.co.nz)
     * @date         2019-07-22
     * @description  Abstract property to get recordId
    **/
    private Id recordId;
    global virtual Id getRecordId() {
        return recordId;
    }
    global virtual void setRecordId(Id recordId) {
        this.recordId = recordId;
    }

    /**
     * @author       Tiaan Swart (tswart@deloitte.co.nz)
     * @date         2019-07-22
     * @description  Abstract method to get object values for a query call
     **/
    global abstract List<Object> getObjects();

}