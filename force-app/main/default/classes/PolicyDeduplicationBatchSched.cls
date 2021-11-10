/******************************************************************************************
* Create By     :    Alvin Aquino
* Create Date  :     February 13, 2020
* Description   :    Schedulable class that will run PolicyDeduplicationBatch
*   Modification Log:
*    -----------------------------------------------------------------------------
*    * Developer                          Date               Description
*    * ----------------------------------------------------------------------------                 
*    * Alvin Aquino                      Feb-13-2020         Initial version.
*****************************************************************************************/
global class PolicyDeduplicationBatchSched implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        PolicyDeduplicationBatch PDB = new PolicyDeduplicationBatch ();
        database.executebatch(PDB,50);
    }
   


}