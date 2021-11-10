/**
 * @author       Tiaan Swart (tswart@deloitte.co.nz)
 * @date         16/10/19
 * @description  CustomNotification
 *
 * CHANGE LOG
 * 16/10/19 - Initial Setup of CustomNotification
 **/
/**
 * Custom Apex Custom Notification API
 *
    new CustomNotification()
        .type('XXXXXXXXXXXXXXX')                            - required
        .title('Test Title')                                - required
        .body('Test Body [Target Record Name: {{ Name }}]') - required
        .recipients(new Set<Id> {UserInfo.getUserId()})     - required
        .target(new Set<Id> {UserInfo.getUserId()})         - required
        .sender(UserInfo.getUserId())                       - optional
        .send();
 */
public inherited sharing class CustomNotification {

    private String notificationTypeId;
    private String notificationBody;
    private String notificationTitle;
    private List<Id> recipientIds;
    private Id targetId;
    private Id senderId; 

    public CustomNotification() {
        this.senderId = UserInfo.getUserId();
    }

    public CustomNotification type(String typeName) {
        this.notificationTypeId = [SELECT Id FROM CustomNotificationType WHERE DeveloperName =: typeName].Id;
        return this;
    }

    public CustomNotification title(String title) {
        this.notificationTitle = title;
        return this;
    }

    public CustomNotification body(String body) {
        this.notificationBody = body;
        return this;
    }

    public CustomNotification recipients(Set<Id> recipientIds) {
        if (recipientIds != null && !recipientIds.isEmpty()) this.recipientIds = new List<Id>(recipientIds);
        return this;
    }

    public CustomNotification target(Id targetId) {
        this.targetId = targetId;
        return this;
    }

    public CustomNotification sender(Id senderId) {
        if (String.isNotBlank(senderId)) this.senderId = senderId;
        return this;
    }

    public CustomNotification send() {

        // Check required attributes
        if (String.isBlank(this.notificationTypeId)) throw new CustomNotificationException('Custom Notification Type Id required!');
        if (String.isBlank(this.notificationBody)) throw new CustomNotificationException('Notification Body required!');
        if (String.isBlank(this.notificationTitle)) throw new CustomNotificationException('Notification Title required!');
        if (this.recipientIds == null || this.recipientIds.isEmpty()) throw new CustomNotificationException('Recipient Ids required!');
        if (String.isBlank(this.targetId)) throw new CustomNotificationException('Target Id required!');

        // Resolve merge fields on Notification Title
        if (this.notificationTitle.contains('{{')) {
            this.notificationTitle = MergeFieldUtility.replaceMergeFieldsWithValues (this.notificationTitle, this.targetId);
        }

        // Resolve merge fields on Notification Body
        if (this.notificationBody.contains('{{')) {
            this.notificationBody = MergeFieldUtility.replaceMergeFieldsWithValues (this.notificationBody, this.targetId);
        }

        // Run the flow with the input
        new FlowProcess()
            .named('SendCustomNotification')
            .with('CustomNotificationTypeId', this.notificationTypeId)
            .with('NotificationTitle', this.notificationTitle)
            .with('NotificationBody', this.notificationBody)
            .with('RecipientIds', this.recipientIds)
            .with('TargetId', this.targetId)
            .with('SenderId', this.senderId)
            .run();

        return this;       
    }

    public class CustomNotificationException extends Exception {}
}