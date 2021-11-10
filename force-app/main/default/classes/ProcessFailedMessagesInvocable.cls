/**
* @author       David Catindoy (david@cloudinit.nz)
* @date         April 18, 2018
* @description  Invocable method that will invoke the process to process failed MQs.
* 
* CHANGE LOG
**/
public with sharing class ProcessFailedMessagesInvocable {
    
    @InvocableMethod(label='Invoke Process Failed Messages')
    public static void invokeProcess() {

        // Execute class that processes MQs
        Intgr8inIT.ProcessFailedMessagesController cont = new Intgr8inIT.ProcessFailedMessagesController();
        cont.processMessages();

    }
}