/**
 * Description
 * This class initiates the run time of the deletion of Sovereign benefits before the weekly import
 *
 * @author Jacob Taljaard
 * @date December 2018
 * @test SovFeed_Benefits_Schedule_Test
 */
public without sharing class SovFeed_Benefits_Schedule implements Schedulable {

    public void execute (SchedulableContext sc) {
        Database.executebatch(new SovFeed_Benefits_Delete_Batch(), 200);
    }
}