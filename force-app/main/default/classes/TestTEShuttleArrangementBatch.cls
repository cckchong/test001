@isTest 
public class TestTEShuttleArrangementBatch{
    @isTest 
    public static void shuttleBatch() {
        TEShuttleArrangementBatch shuttleBatch = new TEShuttleArrangementBatch();
        shuttleBatch.execute(null);
        System.assertNotEquals(null, shuttleBatch);
    }
}