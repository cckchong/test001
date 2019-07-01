@IsTest
public class TestTECashAdvanceProgressBarCtrl {

    public static TestTEExpenseApplication TEExpenseApplication;    
    public static Map<String, Travel_Location__c> travelLocationMap;
    public static employee__c employee;
    public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    public static String userName = 'user1';
    
    public static void preparation(){
        TestTEExpenseApplicationCtrl.preparation(false);
        TEExpenseApplication = TestTEExpenseApplicationCtrl.TEExpenseApplication;
        travelLocationMap = TestTEExpenseApplicationCtrl.travelLocationMap;
        employee = TestTEExpenseApplicationCtrl.employee;
        EmployeeAdministrator = TestTEExpenseApplicationCtrl.EmployeeAdministrator;
    }
    
        
    @IsTest
    public static void execute() {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation();
        UserMap = TEExpenseApplication.UserMap;
        
        
        System.runAs(UserMap.get(userName)){
            
            ta = TestTEExpenseApplicationCtrl.ApplicantConfirmTA();
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
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            
            System.assertNotEquals(null, edl);
            System.assertNotEquals(null, edl.expenseDetail);
            System.assertNotEquals(null, edl.expenseDetail.Id);
            
            Cash_Advance__c ca = new Cash_Advance__c();
            ca.Travel_Application__c = ta.travelApplication.id;
            ca.Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            ca.Amount__c = 100;
            
            insert ca;
            ApexPages.StandardController stdController = new ApexPages.StandardController(ca);
            TECashAdvanceProgressBarCtrl ctrl = new TECashAdvanceProgressBarCtrl(stdController);
            System.assertNotEquals(null, ctrl);
        }
        
    }
}