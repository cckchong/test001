@isTest
public class TestELeaveSupportingDocController
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
    
    public static EleaveController  eLeaveCreation () {
        EleaveController eleaveCtrl = new EleaveController(); 
        LeaveTypeMap = EleavePreparation.LeaveTypeMap;
        List < LeaveSection > leaveSectionList  = eleaveCtrl.ListLeaveSection;
          
        for ( LeaveSection reader : leaveSectionList ){
             reader.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
             reader.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 15);
             reader.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 21);
             reader.stringLeaveStartTime = stringLeaveStartTime;
             reader.stringLeaveEndTime = stringLeaveEndTime;
        } 
         
        for ( LeaveSection reader : leaveSectionList ) {
             reader.changeLeaveType();
        }
        return eleaveCtrl;
    }
    
    /*
        Test: Submit Supporting Doc Set
    */
    @isTest
    public static void submitSupportingDocSet() {
        PageReference page = null;
        ApexPages.StandardSetController sc = null;
        ELeaveSupportingDocController supporingDoc = null;
        Leave_Request__c lr = null;
        List <Leave_Request__c> lrList = new List <Leave_Request__c>();        
        Preparation(true);          
        System.runAs(UserMap.get('user1')) {
            
            EleaveController eleaveCtrl = eLeaveCreation ();
            eleaveCtrl.saveAction();
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                lr = reader.leavetransaction;
            }
            lr.status__c = LeaveRequestConstant.STATUS_APPROVED;
            update lr;
            lrList.add(lr);
        }
        
        Test.startTest();
        sc = new ApexPages.StandardSetController (lrList);
        sc.setSelected(lrList);
        supporingDoc = new ELeaveSupportingDocController(sc);
        supporingDoc.supportingDocResult('', lrList);
        page = supporingDoc.supportingDocAction();
        system.assertNotEquals(null, page);
        Test.stopTest();
    }
    
     /*
        Test: Submit a Supporting Doc
    */
    @isTest
    public static void submitSupportingDoc() {
        PageReference page = null;
        ApexPages.StandardSetController sc = null;
        ELeaveSupportingDocController supporingDoc = null;
        Leave_Request__c lr = null;
        List <Leave_Request__c> lrList = new List <Leave_Request__c>();        
        Preparation(true);          
        System.runAs(UserMap.get('user1')) {
            
            EleaveController eleaveCtrl = eLeaveCreation ();
            eleaveCtrl.saveAction();
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection ){
                lr = reader.leavetransaction;
            }
            lr.status__c = LeaveRequestConstant.STATUS_APPROVED;
            update lr;
            lrList.add(lr);
        }
        
        Test.startTest();
        sc = new ApexPages.StandardSetController (lrList);
        apexpages.currentpage().getparameters().put('id' , lr.id);
        supporingDoc = new ELeaveSupportingDocController(sc);
        supporingDoc.supportingDocResult('', lrList);
        page = supporingDoc.supportingDocAction();
        system.assertNotEquals(null, page);
        Test.stopTest();
    }
}