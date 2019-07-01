@isTest 
public class TestTEExpenseAppRemoteActionsUtils{
    Public Static TestTEPreparation TEPreparation; 
    Public static Map<String, Travel_Location__c> travelLocationMap;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEPreparation = new TestTEPreparation (isSeeAllData);
        TEPreparation.Preparation(isSeeAllData);
        travelLocationMap = TEPreparation.travelLocationMap;
        employee = TEPreparation.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEPreparation.EmployeeAdministratorMap;
    }
    
    @isTest 
    //Scenario 1: cannot be recalled
    public static void cannotBeRecalled() {
        PageReference prf = null;  
        Map<String, User> UserMap = null; 
        String result; 
        
        preparation(false);
        UserMap = TEPreparation.UserMap;
        
        Test.startTest();  
            Expense_Application__c ea = new Expense_Application__c();
            ea.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            insert ea;
            TEExpenseAppRemoteActionsUtils ctrl = new TEExpenseAppRemoteActionsUtils(null);
            try{
                result = TEExpenseAppRemoteActionsUtils.recallApprovalProcess(ea.Id);      
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
        Test.stopTest();
    }
    
    @isTest 
    //Scenario 2: can be recalled 
    public static void canBeRecalled(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        string result;
         
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
            TEExpenseApplicationCtrl eaCtrl = new TEExpenseApplicationCtrl();
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            try{
                result = TEExpenseAppRemoteActionsUtils.recallApprovalProcess(eaCtrl.ea.id);      
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
            Test.stopTest();
        }
    }
    
     public static TETravelApplicationCtrl ApplicantConfirmTA(){  
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        travel_application__c tac = null;
        DateTime today = System.today();
        recordTypeMap = TEPreparation.getRecordType();
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