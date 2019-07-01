@IsTest
public class TestChatterSecurityUtils {

    @IsTest
    public static void testChatterPostWithSecurityAllowed() {
        User u = TestChatterSecurityUtils.getChatterSecurityTestUser(true);
        User u2 = TestChatterSecurityUtils.getChatterSecurityTestUser(true);
        User u3 = TestChatterSecurityUtils.getChatterSecurityTestUser(false);
        System.runAs(u2) {
        	CollaborationGroup cg = new CollaborationGroup(CollaborationType='Public', Description='Hello Description', Name=u.Email, OwnerId = u2.Id);
			insert cg;
            List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
            cgmList.add(new CollaborationGroupMember(CollaborationGroupId = cg.Id, CollaborationRole='Standard', MemberId = u3.Id, NotificationFrequency = 'N'));
            insert cgmList;
            
            cgmList[0].CollaborationRole = 'Admin';
            update cgmList;
        }
        
        System.runAs(u) {
                        
        	List<CollaborationGroup> cgList = [SELECT Id, Name FROM CollaborationGroup WHERE Name = :u.Email];
			CollaborationGroup cg = cgList[0];
            
            List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
            cgmList.add(new CollaborationGroupMember(CollaborationGroupId = cg.Id, CollaborationRole='Standard', MemberId = u.Id, NotificationFrequency = 'N'));
            
            boolean cgmInsertFailed = false;
            try {
            	insert cgmList;
            } catch(Exception e) {
                cgmInsertFailed = true;
            }
            
            System.assertEquals(true, cgmInsertFailed);
            
            
            FeedItem fi = new FeedItem(
                    ParentId = cg.Id,
                	Body = 'Hello Body',
                    Type = 'TextPost'
            );
            
            insert fi;
            System.assertNotEquals(fi.Id, null);
            
            FeedComment fc = new FeedComment(
                	FeedItemId = fi.Id,
                	CommentBody = 'Hello Body',
                    CommentType = 'TextComment'
            );
            
            insert fc;
            System.assertNotEquals(fc.Id, null);
            
            cg.Description = 'Changed Description';
            update cg;
            System.assertEquals(cg.Description, 'Changed Description');
            
            
        }
    }
    
    @IsTest
    public static void testChatterPostWithSecurityNotAllowed() {
        User u = TestChatterSecurityUtils.getChatterSecurityTestUser(true);
        User u2 = TestChatterSecurityUtils.getChatterSecurityTestUser(false);
        User u3 = TestChatterSecurityUtils.getChatterSecurityTestUser(false);

        System.runAs(u2) {
            CollaborationGroup cg = new CollaborationGroup(CollaborationType='Public', Description='Hello Description', Name=u.Email, OwnerId = u2.Id);
            insert cg;
            
            List<CollaborationGroupMember> cgmList = new List<CollaborationGroupMember>();
            cgmList.add(new CollaborationGroupMember(CollaborationGroupId = cg.Id, CollaborationRole='Admin', MemberId = u.Id, NotificationFrequency = 'N'));
            cgmList.add(new CollaborationGroupMember(CollaborationGroupId = cg.Id, CollaborationRole='Admin', MemberId = u3.Id, NotificationFrequency = 'N'));
            insert cgmList;
            
            FeedItem fi = new FeedItem(
                    ParentId = cg.Id,
                	Body = 'Successful Post',
                    Type = 'TextPost'
            );
          	insert fi;
        }
        
        System.runAs(u) {
            List<CollaborationGroup> cgList = [SELECT Id FROM CollaborationGroup WHERE Name = :u.Email];
            System.assertNotEquals(null, cgList);
            System.assertNotEquals(0, cgList.size());
            CollaborationGroup cg = cgList[0];
            
            FeedItem fi = new FeedItem(
                    ParentId = cg.Id,
                	Body = 'Hello Body',
                    Type = 'TextPost'
            );
            
            boolean feedItemFailed = false;
            try {
            	insert fi;
            } catch (Exception e) {
                feedItemFailed = true;
            }
            
            //System.assertEquals(feedItemFailed, true);
            
            List<FeedItem> fiPosted = [SELECT Id FROM FeedItem WHERE ParentId = :cg.Id];
            //System.assertNotEquals(null, fiPosted);
            //System.assertNotEquals(0, fiPosted.size());
            
            FeedComment fc = new FeedComment(
                	FeedItemId = fiPosted[0].Id,
                	CommentBody = 'Hello Body',
                    CommentType = 'TextComment'
            );
            
            boolean feedCommentFailed = false;
            try {
            	insert fc;
            } catch (Exception e) {
                feedCommentFailed = true;
            }
            
            //System.assertEquals(feedCommentFailed, true);
            
            cg.Description = 'Changed Description';
            boolean updateGroupFailed = false;
            try {
            	update cg;
            } catch (Exception e) {
                updateGroupFailed = true;
            }
            
           // System.assertEquals(updateGroupFailed, true);
        }
    }

    
    @IsTest
    public static void testGetUsersWithChatterSecurity() {
        
        User u = TestChatterSecurityUtils.getChatterSecurityTestUser(true);
        System.runAs(u) {
            Map<Id, ChatterSecurityUtils.ChatterSecurityUser> userIdWithChatterSecurity = ChatterSecurityUtils.getUsersWithChatterSecurity();
            
            ChatterSecurityUtils.ChatterSecurityUser csu = userIdWithChatterSecurity.get(u.Id);
            
            System.assertEquals(csu.applySecurity, true);
            System.assertEquals(csu.canComment, true);
            System.assertEquals(csu.canOtherActions, true);
            System.assertEquals(csu.canPost, true);
            System.assertEquals(csu.canPostFile, true);
            System.assertEquals(csu.managerCanComment, true);
            System.assertEquals(csu.managerCanOtherActions, true);
            System.assertEquals(csu.managerCanPost, true);
            System.assertEquals(csu.managerCanPostFile, true);
            System.assertEquals(csu.managerCanUpdateGroup, true);
            
            boolean result = ChatterSecurityUtils.canCurrentUserUpdateGroup();
            System.assertEquals(result, false);
        }
    }
    
    public static User getChatterSecurityTestUser(boolean applyAllSecurity) {
        // Create the user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
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
        // Create the Permission Set
        String psName = 'PS' + String.valueOf(Datetime.Now().getTime());
        PermissionSet myPs = new PermissionSet(Label=psName, Name=psName);
        insert myPs;
        
        List<SetupEntityAccess> seaList = new List<SetupEntityAccess>();
        
        List<String> customPermissionList = new List<String>();
        customPermissionList.add('Chatter_Group_Apply_Security');
        
        if(applyAllSecurity) {
            customPermissionList.add('Chatter_Group_Owner_Allow_Post');
            customPermissionList.add('Chatter_Group_Owner_Allow_Comment');
            customPermissionList.add('Chatter_Group_Owner_Allow_File_Post');
            customPermissionList.add('Chatter_Group_Owner_Allow_All_Other_Actions');
            customPermissionList.add('Chatter_Group_Owner_Allow_Post_Manager');
            customPermissionList.add('Chatter_Group_Owner_Allow_Comment_Manager');
            customPermissionList.add('Chatter_Group_Owner_Allow_File_Post_Manager');
            customPermissionList.add('Chatter_Group_Owner_Allow_All_Other_Actions_Manager');
            customPermissionList.add('Chatter_Group_Allow_Managers_Update_All_Group_Attributes');
            customPermissionList.add('Chatter_Group_Allow_Managers_Update_Group_Description');
            customPermissionList.add('Chatter_Group_Allow_Managers_Update_Group_Membership');
        }
        
        for(CustomPermission cp : 
            [
                SELECT Id, DeveloperName FROM CustomPermission 
                WHERE DeveloperName IN: customPermissionList
            ]) {
                
        	seaList.add(new SetupEntityAccess(
            	ParentId = myPs.Id,
                SetupEntityId = cp.Id
            ));
        }
        
        PermissionSetAssignment psa = new PermissionSetAssignment(
        	AssigneeId = u.Id,
            PermissionSetId = myPs.Id
        );
            
        insert psa;
        insert seaList;
        return u;        
    }
}