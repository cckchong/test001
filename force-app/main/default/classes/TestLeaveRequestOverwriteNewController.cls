@isTest
public with sharing class TestLeaveRequestOverwriteNewController
{
    public static Map<String, User> UserMap;
    public static Map<String, Employee__c> EmployeeMap;
    public static Map <String, Leave_Type__c> LeaveTypeMap;     
    public static TestEleavePreparation  EleavePreparation; 
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime;
    
    public static void Preparation(Boolean isSeeAllData) {
        EleavePreparation = new TestEleavePreparation (isSeeAllData);
        UserMap = EleavePreparation.getUserMap();
        EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
        EleavePreparation.setleaveBalanceList (EmployeeMap.values());
        stringLeaveStartTime = '';
        stringLeaveEndTime  = '';
        for ( Leave_Available_Time__c reader : EleavePreparation.LeaveAvailableTimeMap.values() ){
            if ( stringLeaveStartTime == '' ){             
                 stringLeaveStartTime = reader.id;
            }
             stringLeaveEndTime = reader.id;
        }
    }

    /*
        Test: Employee Page New Botton
    */
    @isTest
    public static void EmployeeOverwriteNew() {       
        PageReference page = null;
        List<SelectOption> selectOptionList = null;
        ApexPages.StandardController sc = null;
        LeaveRequestOverwriteNewController lrNew = new LeaveRequestOverwriteNewController(sc);
        selectOptionList = lrNew.availableRecordTypes;
        system.assertNotEquals(null, selectOptionList);        
        page = lrNew.redirectIfOnlySingleRecordType();        
        system.assertEquals(null, page);
        page = lrNew.GoBtn();
        system.assertNotEquals(null, page);
        page = lrNew.CancelBtn();
        system.assertNotEquals(null, page);
        
        /*
        selectOptionList.clear();
        system.assertNotEquals(null, selectOptionList);    
        page = lrNew.redirectIfOnlySingleRecordType();        
        system.assertEquals(null, page);
        */
    }
    
    /*
        Test: Employee Page New Botton
    */
    @isTest
    public static void EmployeeOverwriteNewWithRecordType() {
        Preparation(false);
        PageReference page = null;
        List<SelectOption> selectOptionList = null;
        ApexPages.StandardController sc = null;
        LeaveRequestOverwriteNewController lrNew = new LeaveRequestOverwriteNewController(sc);
        selectOptionList = lrNew.availableRecordTypes;
        System.runAs(UserMap.get('user1')) {
            for (SelectOption reader : selectOptionList){
                lrNew.selectedRecordType = reader.getvalue();
                system.assertNotEquals(null, selectOptionList);        
                page = lrNew.redirectIfOnlySingleRecordType();
                system.assertNotEquals(null, page); 
                page = lrNew.GoBtn();
                system.assertNotEquals(null, page);
                page = lrNew.CancelBtn();
                system.assertNotEquals(null, page);
            }
        }
        //system.assertEquals(1, selectOptionList.size() );
        /*
        selectOptionList.clear();
        system.assertNotEquals(null, selectOptionList);    
        page = lrNew.redirectIfOnlySingleRecordType();        
        system.assertEquals(null, page);
        */
    }
}