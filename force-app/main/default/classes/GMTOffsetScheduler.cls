/**
* @author Tiaan Swart (tiaan@cloudinit.nz)
* @date 2018-04-21
* @description Class to update a Custom  Setting with Time Zone offset
*
* CHANGE LOG
* 2018-04-21 - Initial setup
**/
global class GMTOffsetScheduler implements Schedulable {

    // This is used to runs a scheduled job at 2AM every day
    // System.schedule('GMT Offset Scheduled Job', GMTOffsetScheduler.CRON_EXP, new GMTOffsetScheduler());
    public static String CRON_EXP = '0 0 2 * * ?';

    /**
    *   @author Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Executes logic to update the Custom Setting with Time Zone offset
    **/
    global void execute(SchedulableContext ctx) {

        updateUserOffset();

    }

    /**
    *   @author Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Logic to update the User Custom Setting Rec with Time Zone offset
    **/
    public static void updateUserOffset() {

        // Get the Users GMT Offset record
        GMT_Offset__c GMTUserOffset = GMT_Offset__c.getInstance();

        // Update the record
        GMTUserOffset = updateFromTimeZone(GMTUserOffset);

        // Get the Org GMT Offset record
        GMT_Offset__c GMTOrgOffset = GMT_Offset__c.getOrgDefaults();

        // If the Org Offset Value is blank
        if (GMTOrgOffset.Value__c == null) {
            // Use this record to update the Org Default
            GMTUserOffset.Update_Org_Defaults__c = true;
        }

        // Update the record
        upsert GMTUserOffset;

        // If this record should update the org defaults
        if (GMTUserOffset.Update_Org_Defaults__c) {
            updateOrgOffset();
        }

    }

    /**
    *   @author Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Logic to update the Org Default Custom Setting Rec with Time Zone offset
    **/
    private static void updateOrgOffset() {

        // Get the Org GMT Offset record
        GMT_Offset__c GMTOrgOffset = GMT_Offset__c.getOrgDefaults();

        // Update the record
        GMTOrgOffset = updateFromTimeZone(GMTOrgOffset);

        // Org Default cannot update itself
        GMTOrgOffset.Update_Org_Defaults__c = false;

        // Update the record
        upsert GMTOrgOffset;

    }

    /**
    *   @author Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Logic to update the Org Default Custom Setting Rec with Time Zone offset
    **/
    private static GMT_Offset__c updateFromTimeZone(GMT_Offset__c GMTOffset) {

        // Get the TimeZone
        TimeZone tz = UserInfo.getTimeZone();

        // Set the Offset Value
        GMTOffset.Value__c = tz.getOffset(DateTime.now());

        // Set the Offset Value in SEC
        GMTOffset.Value_SEC__c = GMTOffset.Value__c / 1000;

        // Set the Offset Value in MIN
        GMTOffset.Value_MIN__c = GMTOffset.Value_SEC__c / 60;

        // Set the Offset Value in HR
        GMTOffset.Value_HR__c = GMTOffset.Value_MIN__c / 60;

        // Set the Time Zone Identifiers
        GMTOffset.Time_Zone_Id__c = tz.getID();
        GMTOffset.Time_Zone_Display_Name__c = tz.getDisplayName();

        return GMTOffset;

    }

}