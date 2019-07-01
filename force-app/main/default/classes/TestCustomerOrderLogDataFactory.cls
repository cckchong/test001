@isTest
/*
    Data factory for the unit tests of Customer Order Log.
    
    The logs returned by the "prepareLog*" methods are not inserted (i.e. no log.Id). It is because
    at different stage the log should be updated by different users with different permission sets.
*/
public class TestCustomerOrderLogDataFactory {
    private static String SYSTEM_ADMIN = 'test system admin';
    private static String APP_OWNER = 'test app owner';
    private static String TGA_USER = 'test tga user';
    private static String TGA_MANAGER_USER = 'test tga manager user';
    private static String TGA_VP_USER = 'test tga VP user';
    private static String TGA_PIM_ADMIN = 'test tga PIM admin';
    private static String PPC_USER = 'test ppc user';
    
    private static Map<String, User> USER_MAP;  // don't get it directly, call getUserNameMap() instead
    private static String SYS_ADMIN_PROFILE_NAME = 'System Administrator';
    private static String STD_USER_PROFILE_NAME = 'Standard User';
    
    private static String TGA_PERM_SET_NAME = 'Customer_Order_Log_TGA';
    private static String PIM_ADMIN_PERM_SET_NAME = 'Customer_Order_Log_PIM_Admin';
    private static String PPC_PERM_SET_NAME = 'Customer_Order_Log_PPC';
    private static String SUPER_ADMIN_PERM_SET_NAME = 'Customer_Order_Log_Super_Admin';
    
    public static User getSystemAdmin() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(SYSTEM_ADMIN);
    }
    
    public static User getAppOwner() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(APP_OWNER);
    }
    
    public static User getTGAUser() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(TGA_USER);
    }
    
    public static User getTGAManagerUser() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(TGA_MANAGER_USER);
    }
    
    public static User getTGAVPUser() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(TGA_VP_USER);
    }
    
    public static User getTGAPIMAdmin() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(TGA_PIM_ADMIN);
    }
    
    public static User getPPCUser() {
        Map<String, User> userMap = getUserNameMap();
        
        return userMap.get(PPC_USER);
    }
    
    public static Customer_Order_Log__c prepareLogTGAInitialize() {
        Customer_Order_Log__c log = new Customer_Order_Log__c();
        log.Customer__c = 'BROOKS BROTHERS INC.';
        log.Brand__c = 'BBR';
        log.Product__c = 'SH';
        log.Dipping_Flag__c = 'Dip';
        log.Plant__c = 'TAV';
        log.Requested_Qty__c = 100;
        log.Requested_Delivery__c = Date.today().addDays(20);
        log.Reserved_Qty__c = 20;
        log.From_Customer_to_TGA__c = Date.today().addDays(-30);
        log.Fabric_dely_ETA_Fty__c = Date.today();
        log.SMV__c = '50(estimate)';
        log.Washing_Finishing__c = 'non wash';
        log.PE_item__c = '12345';
        log.Others_1__c = 'test1';
        log.Others_2__c = 'test2';
        log.Version__c = 1;
            
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log. 
    */
    public static Customer_Order_Log__c prepareLogPPCConfirmPositive(Customer_Order_Log__c log) {
        if (log == null) {
            log = prepareLogTGAInitialize();
        }
        
        log.Meet_Customer_Requirement__c = 'YES';
        log.Remark_2__c = 'Meet, but need will impact others';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log. 
    */
    public static Customer_Order_Log__c prepareLogPPCConfirmNegative(Customer_Order_Log__c log) {
        if (log == null) {
            log = prepareLogTGAInitialize();
        }
        
        log.Meet_Customer_Requirement__c = 'NO';
        log.Remarks__c = 'Capacity';
        log.Remark_2__c = 'Cannot meet';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log (with PPC Confirm positive). 
    */
    public static Customer_Order_Log__c prepareLogPPCImpactPositive(Customer_Order_Log__c log) {
        if (log == null) {
            log = prepareLogPPCConfirmPositive(null);
        }
        
        log.Impacted_Customer__c = '5.11 TACTICAL INC.;BURBERRY LTD';
        log.Impacted_Volume__c = 1000;
        log.Factory_transfer_if_any__c = 'YES';
        log.Remark_3__c = 'Transfer to TAA';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log (with PPC Confirm negative). 
    */
    public static Customer_Order_Log__c prepareLogPPCImpactNegative(Customer_Order_Log__c log) {
        if (log == null) {
            log = prepareLogPPCConfirmNegative(null);
        }
        
        log.From_SVP_If_need_prioritization__c = 'Sorry';
        log.Confirmed_Delivery__c = Date.today().addDays(99);
        log.Impacted_Customer__c = '5.11 TACTICAL INC.;BURBERRY LTD';
        log.Impacted_Volume__c = 10000;
        log.Factory_transfer_if_any__c = 'YES';
        log.Remark_3__c = 'Transfer to KAT';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log (with PPC Impact Negative). 
    */
    public static Customer_Order_Log__c prepareLogTGAFeedbackAccept(Customer_Order_Log__c log) {
        if (log == null) {
            log = prepareLogPPCConfirmNegative(null);
        }
        
        log.From_TGA_to_Customer_Checkbox__c = true;
        log.Customer_Confirmation__c = 'Accept';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log (with PPC Impact positive). 
    */
    public static Customer_Order_Log__c prepareLogTGAFeedbackReturnResubmit(Customer_Order_Log__c log) {
        log = prepareLogTGAFeedbackAccept(log);
        log.Customer_Confirmation__c = 'Return Re-submit';
        
        return log;
    }
    
    /*
        If log is given, the method appends the information on top of the log.
        If log is null, it creates a new log (with PPC Impact positive). 
    */
    public static Customer_Order_Log__c prepareLogTGAFeedbackReject(Customer_Order_Log__c log) {
        log = prepareLogTGAFeedbackAccept(log);
        log.Customer_Confirmation__c = 'Reject';
        
        return log;
    }
    
    /*
        Create user with userName and profileId
    */
    private static User createUser(String userName, Id profileId) {
        User testUser = new User(LastName = userName, 
                 Username = userName.replace(' ', '.') + '@example.com', 
                 Email = userName.replace(' ', '.') + '@example.com', 
                 Alias = 'testing', 
                 TimeZoneSidKey = 'GMT', 
                 LocaleSidKey = 'en_GB', 
                 EmailEncodingKey = 'ISO-8859-1', 
                 ProfileId = profileId, 
                 LanguageLocaleKey = 'en_US');
        
        return testUser;
    }

    /*
        Create user with specified roleId and title
    */
    private static User createUser(String userName, Id profileId, Id roleId, String title) {
        User u = createUser(userName, profileId);
        u.UserRoleId = roleId;
        u.Title = title; 
        return u;
        
    }
    
    private static Map<String, User> getUserNameMap() {
        if (USER_MAP == null) {
            /* create users */
            // find the profile Ids for the profiles
            Id adminProfileId = null;
            Id stdUserProfileId = null;
            for (Profile p : [SELECT Id, Name FROM Profile WHERE Name IN (:SYS_ADMIN_PROFILE_NAME, :STD_USER_PROFILE_NAME)]) {
                if (p.Name == SYS_ADMIN_PROFILE_NAME) {
                    adminProfileId = p.Id;
                } else if (p.Name == STD_USER_PROFILE_NAME) {
                    stdUserProfileId = p.Id;
                }
                
            }
            
            // create a new role (for testing VP in same team)
            UserRole r = new UserRole(name = 'TGA CEL System Testing Team');
            insert r;
            
            User systemAdminUser = createUser(SYSTEM_ADMIN, adminProfileId);
            User appOwnerUser = createUser(APP_OWNER, stdUserProfileId);
            User tgaUser = createUser(TGA_USER, stdUserProfileId, r.Id, 'Small Potato');
            User tgaManagerUser = createUser(TGA_MANAGER_USER, stdUserProfileId, r.Id, 'Small Potato Manager');
            // VP of tgaUser, should be in the same team but with title 'Vice President'
            User tgaVPUser = createUser(TGA_VP_USER, stdUserProfileId, r.Id, Label.TGATeamVPSearchKeyword.replace('%', ''));
            User tgaPIMAdminUser = createUser(TGA_PIM_ADMIN, stdUserProfileId);
            User ppcUser = createUser(PPC_USER, stdUserProfileId);
            
            List<User> users = new List<User>();
            users.add(systemAdminUser);
            users.add(appOwnerUser);
            users.add(tgaUser);
            users.add(tgaManagerUser);
            users.add(tgaVPUser);
            users.add(tgaPIMAdminUser);
            users.add(ppcUser);
            
            insert users;
    
            // set tgaUser's manager to tgaManagerUser      
            tgaUser.ManagerId = tgaManagerUser.Id;
            update tgaUser;
            
            
            /* assign permission set */
            List<PermissionSetAssignment> psas = new List<PermissionSetAssignment>();
            
            for (PermissionSet ps : [SELECT Id, Name From PermissionSet
                    WHERE Name in (:TGA_PERM_SET_NAME, :PIM_ADMIN_PERM_SET_NAME, :PPC_PERM_SET_NAME, :SUPER_ADMIN_PERM_SET_NAME)]) {

                PermissionSetAssignment psa = new PermissionSetAssignment();    
                psa.PermissionSetId = ps.Id;    
                
                if (ps.Name == TGA_PERM_SET_NAME) {
                    psa.AssigneeId = tgaUser.Id;
                    
                } else if (ps.Name == PIM_ADMIN_PERM_SET_NAME) {
                    psa.AssigneeId = tgaPIMAdminUser.Id;
                    
                } else if (ps.Name == PPC_PERM_SET_NAME) {
                    psa.AssigneeId = ppcUser.Id;
                    
                } else if (ps.Name == SUPER_ADMIN_PERM_SET_NAME) {
                    psa.AssigneeId = appOwnerUser.Id;
                    
                }
                psas.add(psa);
                
            }
            
            insert psas;
            
            /* create new USER_MAP */
            Map<String, User> m = new Map<String, User>();
            m.put(SYSTEM_ADMIN, systemAdminUser);
            m.put(APP_OWNER, appOwnerUser);
            m.put(TGA_USER, tgaUser);
            m.put(TGA_MANAGER_USER, tgaManagerUser);
            m.put(TGA_VP_USER, tgaVPUser);
            m.put(TGA_PIM_ADMIN, tgaPIMAdminUser);
            m.put(PPC_USER, ppcUser);
            
            USER_MAP = m;
            
        }
        
        return USER_MAP;
        
    } 

}