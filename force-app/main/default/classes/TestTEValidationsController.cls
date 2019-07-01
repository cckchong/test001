@IsTest
public class TestTEValidationsController{
    
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
    public static void checkOneExpenseToOneTravelApplication() {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            system.assertEquals(null, prc);
            
            Test.stopTest();
        }
        
    }
    
    @isTest 
    public static void checkExistingTravelDistance() {
        preparation(false);
        Test.startTest();
        Travel_Application__c ta = new Travel_Application__c (on_behalf_of__c = EmployeeAdministrator.get(username).id);
        insert ta;
        Map<Id, Journey__c> journeyMap = new Map<Id, Journey__c> ();
        Journey__c j = new Journey__c(Travel_Application__c = ta.id, From_Airport__c = TEExpenseApplication.AirportMap.get('HONGKONG').id, To_Airport__c = TEExpenseApplication.AirportMap.get('LOSANGELES').id  );
        insert j;
        journeyMap.put(j.id, j);
        
        TEValidationsController.checkExistingTravelDistance(journeyMap, j.id, '');
        System.assertNotEquals(j.id, null);
        Test.stopTest();
    
    }
    
    @isTest 
    public static void blockApplicantRecallExpenseApplicationWhenPAC() {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        List<Expense_Application__c> eaList = new List<Expense_Application__c>();
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            Test.startTest();
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
        }
        eaList = [select id, status__c from Expense_Application__c where id = :eaCtrl.ea.id];
        for (Expense_Application__c reader : eaList){
            reader.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
        }
        upsert eaList;
        for (Expense_Application__c reader : eaList){
            reader.status__c = TEConstant.STATUS_NOT_SUBMITTED;
        }
        try{
            upsert eaList;
        }
        catch(Exception e) {system.assertNotEquals(null, eaList);}
        
        Test.stopTest();
    }
    
    @isTest  
    public static void blockApplicantRecallExpenseDetailWhenPAC (){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        List<Expense_Detail__c> edList = new List<Expense_Detail__c>();        
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
        TEExpenseApplicationCtrl eaCtrl = null;
        
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            
        }
        
        edList = [select id, status__c from Expense_Detail__c where expense_application__c  = :eaCtrl.ea.id];
        for (Expense_Detail__c reader : edList){
            reader.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
        }
        upsert edList;
        for (Expense_Detail__c reader : edList){
            reader.status__c = TEConstant.STATUS_NOT_SUBMITTED;
        }
        try{
            upsert edList;
        }
        catch(Exception e) {system.assertNotEquals(null, edList);}
        
        
        Test.stopTest();
    }
    
    
    @isTest  
    public static void checkExistingExpenseDetail(){
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        List<Expense_Application__c> eaList = new List<Expense_Application__c>();
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            Test.startTest();
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 0;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertEquals(prc, null);
            
        }
        
        
        Test.stopTest();
    }
    
    @isTest  
    public static void checkOverlappedEducationApplication(){
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        PageReference prc = null;
        Education_Application__c edapp;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
        Education_Application__c ea = ApprovedEducation(UserMap);
        UpSert ea;
        ea = ApprovedEducation(UserMap);
        ea.Status__c = TEConstant.STATUS_PENDING_APPROVAL;
        
        try{
            UpSert ea;
        }
        catch(Exception e) {system.assertEquals(null, ea.id);}
        
        
        System.assertEquals(ea.id, null);
    }
    
    @isTest  
    public static void isQueueUser(){
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        List<Expense_Application__c> eaList = new List<Expense_Application__c>();
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        Test.startTest();
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
             Boolean check = TEValidationsController.isQueueUser('HKO');
             System.assertEquals(check , true);
        }
        
        
        Test.stopTest();
    }
    
     Public Static Education_Application__c ApprovedEducation(Map<String, User> UserMap){
        
        
        Education_Application__c ea = new Education_Application__c(
            On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
            Apply_Date__c = System.Today(),
            Program_Course_Title__c = TEExpenseApplication.generateRandomString(5),
            Course_URL__c = TEExpenseApplication.generateRandomString(5),
            Couse_Type__c = 'd',
            Currency__c = TEExpenseApplication.currencyMap.get('HKD').id,
            Tuition_Fee_Recommended_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id,
            Degree_Course_Title__c = TEExpenseApplication.generateRandomString(5),
            Education__c = TEExpenseApplication.generateRandomString(5),
            Start_Date__c = System.Today().adddays(5),
            End_Date__c = System.Today().adddays(15),
            Length_of_Program_Year__c = 1,
            Payment_Method__c = 'a',
            Reason_of_Studying__c = TEExpenseApplication.generateRandomString(5),
            Relevancy_to_work__c = TEExpenseApplication.generateRandomString(5),
            Reliability_of_Course_Institute__c = TEExpenseApplication.generateRandomString(5),
            Remarks__c = TEExpenseApplication.generateRandomString(5),
            Status__c = TEConstant.STATUS_APPROVED,
            Tech_Applicant__c = UserMap.get(userName).id,
            Tuition_Fee__c = 100,
            Tuition_Fee_Recommended__c = 100
        );
        
        return ea;
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
        td.TravelDetail.Preferred_Departure_dt__c = today.adddays(-20);
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