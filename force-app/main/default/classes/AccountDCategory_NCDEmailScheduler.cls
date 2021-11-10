/**
 * @author Pablo Martinez (pablomartinez@deloitte.co.nz)
 * @date 24/09/2019
 */
global without sharing class AccountDCategory_NCDEmailScheduler implements Schedulable {

    global void execute (SchedulableContext sc) {
        Database.executeBatch(
            new AccountDCategory_NCDEMailBatch(), 5
        );
    }
}