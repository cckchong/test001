@isTest
public class TestTEExpenseReportsCtrl {
    
    public static testMethod void testTEExpenseReportsCtrl() {
		TEExpenseReportsCtrl ctrl = new TEExpenseReportsCtrl();
        
        ctrl.proxyDateFrom.Receipt_Date__c = System.Today();
        ctrl.proxyDateTo.Receipt_Date__c = System.Today().addDays(1);
        ctrl.selectedPrnFilter = 'all';
        
        PageReference result = ctrl.generatePrnPayrollReport();
        Map<String, String> params = result.getParameters();
        System.assertNotEquals(null, params.get('dateFromStr'));
        System.assertNotEquals(null, params.get('dateToStr'));
        System.assertNotEquals(null, params.get('filterOpt'));

    }
    
    public static testMethod void testTEExpenseReportsPrnCtrlAll() {
        Test.setCurrentPage(Page.TEExpenseReportsPrnVFP);
        ApexPages.currentPage().getParameters().put('dateFromStr', '20160401');
        ApexPages.currentPage().getParameters().put('dateToStr', '20160430');
        ApexPages.currentPage().getParameters().put('filterOpt', 'all');
        
        Expense_Detail_Log__c edl = new Expense_Detail_Log__c();
        edl.Employee_ID__c = 'X123 Chan Tai Man';
        edl.Employee_Full_Name__c = 'Chan Tai Man';
        edl.Original_Employee_ID__c = 'X123';
        edl.Employee_Grade__c = '8';
        edl.Local_Amount__c = 500;
        edl.Type__c = 'Expense_Detail_Closed';
        edl.Currency__c = 'HKD';
        edl.Amount__c = 500;
        insert edl;
        
        Expense_Detail_Log__c edl2 = new Expense_Detail_Log__c();
        edl2.Employee_ID__c = 'X123 Chan Tai Man';
        edl2.Employee_Full_Name__c = 'Chan Tai Man';
        edl2.Original_Employee_ID__c = 'X123';
        edl2.Employee_Grade__c = '8';
        edl2.Local_Amount__c = 600;
        edl2.Type__c = 'Expense_Detail_Closed';
        edl2.Currency__c = 'HKD';
        edl2.Amount__c = 600;
        insert edl2;
        
        Test.setCreatedDate(edl.Id, Datetime.newInstance(2016, 04, 15, 0, 0, 0));
        TEExpenseReportsPrnCtrl ctrl = new TEExpenseReportsPrnCtrl();
        System.assertEquals(true, ctrl.resultStr.contains('X123'));
    }
    
    public static testMethod void testTEExpenseReportsPrnCtrlGte7() {
        Test.setCurrentPage(Page.TEExpenseReportsPrnVFP);
        ApexPages.currentPage().getParameters().put('dateFromStr', '20160401');
        ApexPages.currentPage().getParameters().put('dateToStr', '20160430');
        ApexPages.currentPage().getParameters().put('filterOpt', 'gte7');
        
        Expense_Detail_Log__c edl = new Expense_Detail_Log__c();
        edl.Employee_ID__c = 'X123 Chan Tai Man';
        edl.Employee_Full_Name__c = 'Chan Tai Man';
        edl.Original_Employee_ID__c = 'X123';
        edl.Employee_Grade__c = '8';
        edl.Local_Amount__c = 500;
        edl.Type__c = 'Expense_Detail_Closed';
        edl.Currency__c = 'HKD';
        edl.Amount__c = 500;
        insert edl;
        
        Test.setCreatedDate(edl.Id, Datetime.newInstance(2016, 04, 15, 0, 0, 0));
        TEExpenseReportsPrnCtrl ctrl = new TEExpenseReportsPrnCtrl();
        System.assertEquals(true, ctrl.resultStr.contains('X123'));
    }
    
	public static testMethod void testTEExpenseReportsPrnCtrlLt7() {
        Test.setCurrentPage(Page.TEExpenseReportsPrnVFP);
        ApexPages.currentPage().getParameters().put('dateFromStr', '20160401');
        ApexPages.currentPage().getParameters().put('dateToStr', '20160430');
        ApexPages.currentPage().getParameters().put('filterOpt', 'lt7');
        
        Expense_Detail_Log__c edl = new Expense_Detail_Log__c();
        edl.Employee_ID__c = 'X123 Chan Tai Man';
        edl.Employee_Full_Name__c = 'Chan Tai Man';
        edl.Original_Employee_ID__c = 'X123';
        edl.Employee_Grade__c = '8';
        edl.Local_Amount__c = 500;
        edl.Type__c = 'Expense_Detail_Closed';
        edl.Currency__c = 'HKD';
        edl.Amount__c = 500;
        insert edl;
        
        Test.setCreatedDate(edl.Id, Datetime.newInstance(2016, 04, 15, 0, 0, 0));
        TEExpenseReportsPrnCtrl ctrl = new TEExpenseReportsPrnCtrl();
        System.assertEquals(false, ctrl.resultStr.contains('X123'));
    }
    
}