@IsTest
public class TestTECarbonEmissionLogBatch {

    public static Flight_Type__c ft;
    public static Cabin_Class__c cc;
    public static Travel_Location__c tl1;
    public static Travel_Location__c tl2;
    public static Airport__c air1;
    public static Airport__c air2;
    public static Travel_Distance__c td;
    public static GHG_Factor__c ef;
    public static Travel_Application__c submittedTa;
    
    public static void prepareCarbonData() {
        ft = new Flight_Type__c(Name = 'Long', Short_Name__c = 'L', Min_Range__c = 0, Max_Range__c = 10);
        insert ft;
        
        cc = new Cabin_Class__c(Name = 'Economy');
        insert cc;
        
        tl1 = new Travel_Location__c(Name = 'Vancouver');
        tl2 = new Travel_Location__c(Name = 'Toronto');
        insert tl1;
        insert tl2;
        
        air1 = new Airport__c(Name = 'YVR', Travel_Location__c = tl1.Id);
        air2 = new Airport__c(Name = 'YYZ', Travel_Location__c = tl2.Id);
        insert air1;
        insert air2;
        
        
        td = new Travel_Distance__c(From_Airport__c = air1.Id, To_Airport__c = air2.Id, Flight_Type__c = ft.Id, Distance__c = 5);
        insert td;
        
        ef = new GHG_Factor__c(Flight_Type__c = ft.Id, Cabin_Class__c = cc.Id);
        insert ef;
    }
    
    public static void prepareNewTa() {
    
        TestTETravelApplicationCtrl.preparation(false);
        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;

        UserMap = TestTETravelApplicationCtrl.TETravelApplication.UserMap;
        recordTypeMap = TestTETravelApplicationCtrl.TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();        
        System.runAs(UserMap.get(TestTETravelApplicationCtrl.userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TestTETravelApplicationCtrl.TETravelApplication.createTravelApplication(TestTETravelApplicationCtrl.employee, 
                                                                                         TestTETravelApplicationCtrl.EmployeeAdministrator, 
                                                                                         TestTETravelApplicationCtrl.userName, 
                                                                                         TDRecordTypeMap.get('Air'));
            ta.saveAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            submittedTa = ta.TravelApplication;
            submittedTa.Status__c = TEConstant.STATUS_CONFIRMED;
            update submittedTa;
        }
    }
    
    public static void prepareJourney() {
        Journey__c jy = new Journey__c();
        jy.Cabin_Class__c = cc.Id;
        jy.Travel_Application__c = submittedTa.Id;
        jy.From_Airport__c = air1.Id;
        jy.To_Airport__c = air1.Id;
        jy.From_Airport_Text__c = 'YVR';
        jy.To_Airport_Text__c = 'YYZ';
        insert jy;
    }
    
    @IsTest
    public static void execute() {
        prepareCarbonData();
        prepareNewTa();
        prepareJourney();
        
        TECarbonEmissionLogBatch ceBatch = new TECarbonEmissionLogBatch();
        ceBatch.execute(null);
        System.assertNotEquals(null, ceBatch);
    }
}