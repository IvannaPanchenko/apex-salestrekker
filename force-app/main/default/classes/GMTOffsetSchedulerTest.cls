/**
* @author Tiaan Swart (tiaan@cloudinit.nz)
* @date 2018-04-21
* @description Test Class for GMTOffsetScheduler
*
* CHANGE LOG
* 2018-04-21 - Initial setup
**/
@IsTest
private class GMTOffsetSchedulerTest {

    /**
    *   @author Tiaan Swart (tiaan@cloudinit.nz)
    *   @description Test the GMTOffsetScheduler
    **/
    @IsTest
    static void testScheduler() {

        Test.startTest();

        // Schedule now
        System.schedule('GMT Offset Scheduled Job', GMTOffsetScheduler.CRON_EXP, new GMTOffsetScheduler());

        Test.stopTest();

        // Get the TimeZone
        TimeZone tz = UserInfo.getTimeZone();

        // Get the Users GMT Offset record
        GMT_Offset__c GMTUserOffset = GMT_Offset__c.getInstance();

        // Check the Offset Value
       System.assertEquals(GMTUserOffset.Value__c, tz.getOffset(DateTime.now()), 'Expected the Offset Value to be the same as the Users');
        System.assertEquals(GMTUserOffset.Value_SEC__c, tz.getOffset(DateTime.now())/1000, 'Expected the Offset Value in Sec to be the same as the Users');
        System.assertEquals(GMTUserOffset.Value_MIN__c, tz.getOffset(DateTime.now())/60000, 'Expected the Offset Value in Min to be the same as the Users');
        System.assertEquals(GMTUserOffset.Value_HR__c, tz.getOffset(DateTime.now())/3600000, 'Expected the Offset Value in Hr to be the same as the Users');

        // Check the Time Zone Identifiers
        System.assertEquals(GMTUserOffset.Time_Zone_Id__c, tz.getID(), 'Expected the Time Zone Id to the same as the Users');
        System.assertEquals(GMTUserOffset.Time_Zone_Display_Name__c, tz.getDisplayName(), 'Expected the Time Zone Display Name to the same as the Users');

        // Check the flag to update org defaults
        System.assertEquals(GMTUserOffset.Update_Org_Defaults__c, true, 'Expected the update org defaults flag to be set');

    }

}