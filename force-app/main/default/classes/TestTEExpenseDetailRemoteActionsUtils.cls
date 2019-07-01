@isTest 
public class TestTEExpenseDetailRemoteActionsUtils{
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
        Map<String, RecordType> recordTypeMap = null;
        recordTypeMap = TEPreparation.RecordTypeMap;
        
        Test.startTest();  
            Expense_Application__c ea4 = new Expense_Application__c();
            ea4.On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id;
            ea4.RecordTypeId = recordTypeMap.get(TEConstant.EXPENSE_APPLICATION_OBJECT_NAME + '_' + TEConstant.EXPENSE_APPLICATION_RECORD_TYPE_GENERAL_EXPENSES).Id;
            insert ea4;
            Expense_Detail__c ed4 = new Expense_Detail__c();
            ed4.Expense_Application__c = ea4.Id;
            ed4.Status__c = TEConstant.STATUS_DRAFT ;
            ed4.Amount__c = 1;
            ed4.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            insert ed4;
            try{
                result = TEExpenseDetailRemoteActionsUtils.recallApprovalProcess(ed4.Id);       
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
        Test.stopTest();
    }
    
    @isTest  
    public static void recallGeneralExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        preparation(false);
        UserMap = TEPreparation.UserMap;
        String result;
         
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            TEExpenseApplicationCtrl eaCtrl = new TEExpenseApplicationCtrl();
            eaCtrl.getApplicants();
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEPreparation.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            try{
                result = TEExpenseDetailRemoteActionsUtils.recallApprovalProcess(edl.expenseDetail.Id);      
                system.assertNotEquals(null, result);
            }
            catch(Exception ex){
            }
            Test.stopTest();
        }
    }
}