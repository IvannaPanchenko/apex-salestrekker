/**
 * Description
 * This class initiates the run time of the deletion of Sovereign policy that are void or has not been updated in the last x days
 *
 * @author Jacob Taljaard
 * @date December 2018
 * @test SovFeed_Policy_Schedule_Test
 */
public without sharing class SovFeed_Policy_Schedule implements Schedulable {

    public void execute (SchedulableContext sc) {
        Database.executebatch(new SovFeed_Policy_Delete_Batch(), 200);
    }
}