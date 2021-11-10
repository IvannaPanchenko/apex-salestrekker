/**
 * Description
 * This class initiates the run time of the deletion of Sovereign policy roles before the weekly import
 *
 * @author Jacob Taljaard
 * @date December 2018
 * @test SovFeed_PolicyRoles_Schedule_Test
 */
public without sharing class SovFeed_PolicyRoles_Schedule implements Schedulable {

    public void execute (SchedulableContext sc) {
        Database.executebatch(new SovFeed_PolicyRoles_Delete_Batch(), 200);
    }
}