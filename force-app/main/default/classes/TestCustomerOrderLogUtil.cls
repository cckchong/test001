@isTest
private class TestCustomerOrderLogUtil {
	@testSetup
	static void setup() {
		// insert a holiday at 2015/5/15 (Fri),
		Date holiday = Date.newInstance(2015, 5, 15);
		Customer_Order_Log_Holidays__c colh = new Customer_Order_Log_Holidays__c();
		colh.Name = String.valueOf(holiday);
		colh.Date__c = holiday;
		insert colh;
		
		// insert a holiday at 2015/5/16 (Sat),
		holiday = Date.newInstance(2015, 5, 16);
		colh = new Customer_Order_Log_Holidays__c();
		colh.Name = String.valueOf(holiday);
		colh.Date__c = holiday;
		insert colh;
	}
	
	static testMethod void assertGetUsersWithCustomPermission() {
		User systemAdminUser = TestCustomerOrderLogDataFactory.getSystemAdmin();
		
		Test.startTest();
		System.runAs(systemAdminUser) {
		
			String permissionSetName = 'Customer_Order_Log_TGA';
			String customPermissionName = 'CEL_TGA_Create_Right';
			
			// before assignment, test systemAdminUser should not have the custom permission
	        Set<Id> userIds = CustomerOrderLogUtil.getUsersWithCustomPermission(customPermissionName);
	        System.assert(!userIds.contains(systemAdminUser.Id));
			
			// assign the User systemAdminUser to 'Customer_Order_Log_TGA', so that he should have 'CEL_TGA_Create_Right' custom permission
			PermissionSetAssignment psa = new PermissionSetAssignment();
			psa.PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName].Id;
			psa.AssigneeId = systemAdminUser.Id;
			insert psa;
			
			// assert if userIds contains the systemAdminUser.Id
			userIds = CustomerOrderLogUtil.getUsersWithCustomPermission(customPermissionName);
	        System.assert(userIds.contains(systemAdminUser.Id));
	        
		}
		
        Test.stopTest();
	}

    static testMethod void assertGetWorkingDays() {
		Test.startTest();
    	// test startdate Sat, enddate Sun
        Date startDate = Date.newInstance(2015, 5, 9);
        Date endDate = Date.newInstance(2015, 5, 17);
        
        Integer workingDays = CustomerOrderLogUtil.getWorkingDays(startDate, endDate);
        System.assertEquals(4, workingDays);
        
    	// test startdate Sun, enddate Sat
        startDate = Date.newInstance(2015, 5, 3);
        endDate = Date.newInstance(2015, 5, 16);
        
        workingDays = CustomerOrderLogUtil.getWorkingDays(startDate, endDate);
        System.assertEquals(9, workingDays);
        
        Test.stopTest();
    }
}