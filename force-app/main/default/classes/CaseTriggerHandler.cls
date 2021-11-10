/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         16/10/19
 * @description  CaseTriggerHandler
 * 
 * CHANGE LOG
 * 16/10/19 - Initial Setup of CaseTriggerHandler
 **/
public class CaseTriggerHandler extends TriggerHandler {

    private List <Case> newCases {
        get {
            return (List <Case>) Trigger.new;
        }
        set;
    }

    private Map <Id, Case> oldCaseMap {
        get {
            return (Map <Id, Case>) Trigger.oldMap;
        }
        set;
    }

    public override void afterUpdate() {
        notifyFollowersOfClosedCases();
    }

    private void notifyFollowersOfClosedCases() {

        // Get the EB RecordTypeId
        Id existingBusinessRecordTypeId = Case.getSObjectType()
                .getDescribe().getRecordTypeInfosByDeveloperName().get('Existing_Business').getRecordTypeId();

        // Get a list of closed EB cases
        Map<Id, Case> closedCaseMapByIds = new Map<Id, Case>();
        for (Case newCase : newCases) {
            Case oldCase = oldCaseMap.get(newCase.Id);
            if (newCase.IsClosed && !oldCase.IsClosed && newCase.RecordTypeId == existingBusinessRecordTypeId) {
                closedCaseMapByIds.put(newCase.Id, newCase);
            }
        }

        // If we have closed cases to process
        if (!closedCaseMapByIds.isEmpty()) {

            // Build a map of the followers to the closed cases
            Map<Id, Set<Id>> followerIdsByClosedCaseIds = new Map<Id, Set<Id>>();
            for (EntitySubscription follower : [SELECT ParentId, SubscriberId
                                                FROM EntitySubscription
                                                WHERE ParentId IN: closedCaseMapByIds.keySet()]) {
                if (!followerIdsByClosedCaseIds.containsKey(follower.ParentId)) {
                    followerIdsByClosedCaseIds.put(follower.ParentId, new Set<Id>());
                }
                followerIdsByClosedCaseIds.get(follower.ParentId).add(follower.SubscriberId);
            }

            // If we have followers to notify
            if (!followerIdsByClosedCaseIds.isEmpty()) {

                // For each closed case, send a custom notification
                for (Id closedCaseId : followerIdsByClosedCaseIds.keySet()) {
                    CaseTriggerHandler.sendCustomNotifications(
                        followerIdsByClosedCaseIds.get(closedCaseId),
                        closedCaseId
                    );
                }
            }
        }

    }

    @Future
    public static void sendCustomNotifications(Set<Id> recipientIds, Id targetId) {

        // Get the Admin settings
        Apex_Admin_Settings__c adminSettings = Apex_Admin_Settings__c.getInstance();

        new CustomNotification()
            .type('Flow_Custom_Notification')
            .title(adminSettings.Closed_Case_Notification_Title_Template__c)
            .body(adminSettings.Closed_Case_Notification_Body_Template__c)
            .recipients(recipientIds)
            .target(targetId)
            .send();
    }

}