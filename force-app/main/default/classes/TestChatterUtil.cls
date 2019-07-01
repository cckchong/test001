@IsTest(SeeAllData=true)
public class TestChatterUtil {
    
    @IsTest
    public static void testChatterUtil() {
        ChatterUtil.simpleLinkPost(UserInfo.getUserId(), 'Hello', 'www.google.com', 'Google');
        
        List<FeedItem> fi = [Select Id FROM FeedItem LIMIT 1];
        System.assertNotEquals(0, fi.size());
    }
}