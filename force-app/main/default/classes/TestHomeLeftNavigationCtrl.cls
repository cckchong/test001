@isTest 
public class TestHomeLeftNavigationCtrl{
    Public Static TestTEPreparation TEPreparation; 
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEPreparation = new TestTEPreparation (isSeeAllData);
        TEPreparation.Preparation(isSeeAllData);
    }
    
    @isTest 
    public static void test() {
        Map<String, User> UserMap = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        System.runAs(UserMap.get(userName)){     
            Test.setCurrentPage(Page.HomeLeftNavigationVFPage);
            HomeLeftNavigationCtrl ctrl = new HomeLeftNavigationCtrl();
            system.assertNotEquals(null,ctrl);
        }
    }
}