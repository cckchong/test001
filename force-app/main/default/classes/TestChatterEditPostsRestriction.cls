/**
 * @description Testing for the Chatter Edit Posts Restriction functionality
 */
@isTest
public class TestChatterEditPostsRestriction {

    @IsTest
    public static void testBlockPost() {
        User u = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        User u2 = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        User u3 = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        
        FeedItem fi;
       
        System.runAs(u) {
            CollaborationGroup cg = TestClassUtil.getChatterGroup();
            cg.Name = 'Happy Chatter Group';
            insert cg;

            fi = new FeedItem(Body='Hello Friends', ParentId = cg.Id, Type='TextPost');
            insert fi;
            
            fi.Body = 'Hello Enemies';
            update fi;
            
            System.assertEquals('Hello Enemies', fi.Body);
        }
        
        System.runAs(u2) {
            fi.Body = 'Blah';
            
            boolean updated = false;
            
            try {
            	update fi;
                updated = true;
            } catch (Exception e) {}
                
            System.assertEquals(false, updated);
        }
    }
    
    @IsTest
    public static void testBlockComment() {
        User u = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        User u2 = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        User u3 = TestChatterEditPostsRestriction.getChatterSecurityTestUser();
        
        FeedItem fi;
        FeedComment fc;
        System.runAs(u) {
            CollaborationGroup cg = TestClassUtil.getChatterGroup();
            cg.Name = 'Happy Chatter Group';
            insert cg;

            fi = new FeedItem(Body='Hello Friends', ParentId = cg.Id, Type='TextPost');
            insert fi;
            
            fc = new FeedComment(CommentBody='jello is great', FeedItemId = fi.Id);
            insert fc;
            
            fc.CommentBody = 'jello is yummy';
            update fc;
            
            System.assertEquals('jello is yummy', fc.CommentBody);
        }
        
        System.runAs(u2) {
            fc.CommentBody = 'Blah';
            
            boolean updated = false;
            
            try {
            	update fc;
                updated = true;
            } catch (Exception e) {}
                
            System.assertEquals(false, updated);
        }
    }
    
    public static User getChatterSecurityTestUser() {
        // Create the user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 15) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            randStr += chars.substring(idx, idx+1);
        }
        
        String testEmail = 'test' + randStr + '@hk.talgroup.com'; // We must use this email domain!
        User u = new User(  Alias = 'standt', Email=testEmail, 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName= testEmail
                            );
        
        insert u;
        
        return u;
    }
}