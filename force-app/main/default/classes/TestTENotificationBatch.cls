@isTest 
public class TestTENotificationBatch{
    @isTest 
    public static void batch() {
        TENotificationBatch batch = new TENotificationBatch();
        batch.execute(null);
        System.assertNotEquals(null, batch);
    }
}