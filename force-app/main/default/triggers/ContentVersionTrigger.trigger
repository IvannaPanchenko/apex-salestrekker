/********************************************************************************************
* Create By     :   David Catindoy (david@cloudinit.nz)
* Create Date   :   14-Sept-2018
* Description   :   ContentVersion trigger. 
* Modification Log:
*   ------------------------------------------------------------------------------------------
*   * Developer         Date            Description
*   * ----------------------------------------------------------------------------------------
*   * DC                14-Sept-2018        Initial version.                                
**********************************************************************************************/
trigger ContentVersionTrigger on ContentVersion (after insert) {
    
    if(ContentVersionTriggerHandler.allowCallout){
        // Call method to process files
        ContentVersionTriggerHandler.processFiles(Trigger.new);
    }

}