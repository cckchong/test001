/**
 * @description test class for LeaveBalanceTriggerHandler
 * @author Andrew Ng
 */ 
@isTest
public class TestLeaveBalanceTriggerHandler {
    public static Map<String, User> UserMap ;
    public static Map<String, Employee__c> EmployeeMap ;
    public static Map <String, Leave_Type__c> LeaveTypeMap;     
    public static TestEleavePreparation  EleavePreparation; 
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime ;
     
     
    public static void preparation() {
        EleavePreparation = new TestEleavePreparation(false);
        UserMap = EleavePreparation.getUserMap();
        EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
        LeaveTypeMap = EleavePreparation.LeaveTypeMap;
    }
    
    /**
     * @description Basic test cases for the Leave Balance trigger
     */
    @IsTest
    public static void testMarkBalanceOfLatest() {
        preparation();        
        List<String> empKeys = new List<String>();
        empKeys.addAll(EmployeeMap.keyset());
        
        Employee__c emp = EmployeeMap.get(empKeys[0]);
        
        List<String> leaveKeys = new List<String>();
        leaveKeys.addAll(LeaveTypeMap.keyset());
        
        Leave_Type__c lt = LeaveTypeMap.get(leaveKeys[0]);
        
        
        boolean disableTrigger = false;
        boolean disableUnapprovedBalance = false;
        
        Leave_Balance__c lb0 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '2999',
            Month__c = '12',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Unapproved_Balance__c = 66,
            Forfeited__c = 55,
            Increment_Days__c = 55 
        );
        insert lb0;
            
        Test.startTest();
        
        try {
            disableUnapprovedBalance = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger_Unapproved_Balance);
        } catch (Exception e) {}
        
        try {
            disableTrigger = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger);
        } catch (Exception e) {}
        
        System.assertEquals(false, disableTrigger);
        System.assertEquals(false, disableUnapprovedBalance);
        List<Leave_Balance__c> lbsToInsert = new List<Leave_Balance__c>();
        
        Leave_Balance__c lb1 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '3000',
            Month__c = '1',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Forfeited__c = 55,
            Increment_Days__c = 55 
        );
        

        
        Leave_Balance__c lb2 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '3000',
            Month__c = '2',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Forfeited__c = 55,
            Increment_Days__c = 55 
        );
        
        lbsToInsert.add(lb1);
        lbsToInsert.add(lb2);
        insert lbsToInsert;
		
        Leave_Balance__c lb1Refreshed = [SELECT Id, Is_Latest__c FROM Leave_Balance__c WHERE Id = :lb1.Id];
        System.assertEquals(false, lb1Refreshed.Is_Latest__c);
        
        Leave_Balance__c lb2Refreshed = [SELECT Id, Is_Latest__c, Unapproved_Balance__c FROM Leave_Balance__c WHERE Id = :lb2.Id];
        System.assertEquals(true, lb2Refreshed.Is_Latest__c);
        System.assertEquals(lb0.Unapproved_Balance__c, lb2Refreshed.Unapproved_Balance__c);
        
        
        lb1Refreshed.Month__c = '3';
        
        boolean updateExceptionThrown = false;
        try {
        	update lb1Refreshed;
        } catch (Exception e) {
            updateExceptionThrown = true;
        }
        
        System.assertEquals(true, updateExceptionThrown);
        
		Test.stopTest();
    }
    
    /**
     * @description Basic test cases for the Leave Balance trigger
     */
    @IsTest
    public static void testForceMarkLatest() {
        preparation();        
        List<String> empKeys = new List<String>();
        empKeys.addAll(EmployeeMap.keyset());
        
        Employee__c emp = EmployeeMap.get(empKeys[0]);
        
        List<String> leaveKeys = new List<String>();
        leaveKeys.addAll(LeaveTypeMap.keyset());
        
        Leave_Type__c lt = LeaveTypeMap.get(leaveKeys[0]);
        
        
        boolean disableTrigger = false;
        boolean disableUnapprovedBalance = false;
        
        Leave_Balance__c lb0 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '2999',
            Month__c = '12',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Unapproved_Balance__c = 66,
            Forfeited__c = 55,
            Increment_Days__c = 55 
        );
        insert lb0;
            
        Test.startTest();
        
        try {
            disableUnapprovedBalance = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger_Unapproved_Balance);
        } catch (Exception e) {}
        
        try {
            disableTrigger = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger);
        } catch (Exception e) {}
        
        System.assertEquals(false, disableTrigger);
        System.assertEquals(false, disableUnapprovedBalance);
        List<Leave_Balance__c> lbsToInsert = new List<Leave_Balance__c>();
        
        Leave_Balance__c lb1 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '3000',
            Month__c = '1',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Forfeited__c = 55,
            Increment_Days__c = 55
        );

        Leave_Balance__c lb2 = new Leave_Balance__c(
            Employee__c = emp.Id,
            Leave_Type_Code__c = lt.Id,
            Year__c = '3000',
            Month__c = '2',
            Opening_Balance_Days__c = 55,
            Approved_Current_Period__c = 55,
            Approved_Future_Period__c = 55,
            Maximum_Cumulative_Entitlement__c = 55,
            Forfeited__c = 55,
            Increment_Days__c = 55 
        );
        
        lbsToInsert.add(lb1);
        lbsToInsert.add(lb2);
        insert lbsToInsert;
		
        Leave_Balance__c lb1Refreshed = [SELECT Id, Is_Latest__c FROM Leave_Balance__c WHERE Id = :lb1.Id];
        System.assertEquals(false, lb1Refreshed.Is_Latest__c);
        
        Leave_Balance__c lb2Refreshed = [SELECT Id, Is_Latest__c, Unapproved_Balance__c FROM Leave_Balance__c WHERE Id = :lb2.Id];
        System.assertEquals(true, lb2Refreshed.Is_Latest__c);
        System.assertEquals(lb0.Unapproved_Balance__c, lb2Refreshed.Unapproved_Balance__c);
        
        lb1Refreshed.Is_Latest__c = true;
        update lb1Refreshed;
        
        lb1Refreshed = [SELECT Id, Is_Latest__c FROM Leave_Balance__c WHERE Id = :lb1.Id];
        System.assertEquals(true, lb1Refreshed.Is_Latest__c);
        
		Test.stopTest();
    }
}