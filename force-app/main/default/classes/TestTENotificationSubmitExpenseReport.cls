@isTest 
public class TestTENotificationSubmitExpenseReport{
    //Public static TestTETravelApplication TETravelApplication; 
    Public static TestTEExpenseApplication TEExpenseApplication;   
    Public static Map<String, Travel_Location__c> travelLocationMap;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEExpenseApplication = new TestTEExpenseApplication(isSeeAllData);
        travelLocationMap = TEExpenseApplication.travelLocationMap;
        employee = TEExpenseApplication.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEExpenseApplication.EmployeeAdministratorMap;
    }

    @isTest 
    public static void batch() {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        travel_application__c tac = null;
        PageReference prf = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
    
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = ApplicantConfirmTA();
            
            Test.startTest();
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            upsert eaCtrl.ea;
    
            TENotificationSubmitExpenseReportBatch batch = new TENotificationSubmitExpenseReportBatch();
            List<sObject> scope = new List<sObject>();
            scope.add(ta.TravelApplication);
            batch.execute(null, scope);
            System.assertNotEquals(null, batch);
            batch.start(null);
            Test.stopTest();
        }
    }
    
    
    public static TETravelApplicationCtrl ApplicantConfirmTA(){  
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        travel_application__c tac = null;
        DateTime today = System.today();
        recordTypeMap = TEExpenseApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
            
        TETravelApplicationCtrl ta = new TETravelApplicationCtrl();
        TETravelDetail td = null;            
        ta.TravelApplication.Selected_Passport__c = employee.passport_type_1__c;
        ta.TravelApplication.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;
        ta.TravelApplication.status__c = TEConstant.STATUS_CONFIRMED;
        //Create Travel Detail
        tdList = ta.travelDetailList;         
        td = tdList[0];
        td.TravelDetail.recordTypeId = TDRecordTypeMap.get('Surface');
        td.TravelDetail.Preferred_Departure_dt__c = today.adddays(-30);
        td.TravelDetail.Preferred_Return_dt__c = today.adddays(-10);
        td.TravelDetail.Origin_Site__c = travelLocationMap.get('HONGKONG').id;
        td.TravelDetail.Destination__c = travelLocationMap.get('HONGKONG').id;
        td.TravelDetail.Self_Arragnment__c = true;
        td.TravelDetail.status__c = TEConstant.STATUS_CONFIRMED;
        for(TEAccommodationCtrl reader :  ta.travelAccommodationList){
            if (String.IsBlank(reader.checkInDate)){
                reader.checkInDate = '';
            }
            if (String.IsBlank(reader.checkoutDate)){
                reader.checkOutDate = '';
            }
        }
        insert ta.TravelApplication;
        td.TravelDetail.travel_application__c = ta.TravelApplication.id;
        insert td.TravelDetail;
        return ta;
    }
}