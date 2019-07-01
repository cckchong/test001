public with sharing class TEExpenseReportsCtrl {

    public Expense_Detail__c proxyDateFrom {get;set;}
    public Expense_Detail__c proxyDateTo {get;set;}
    public List<SelectOption> prnFilterOptions {get;set;}
    public String selectedPrnFilter {get;set;}
    public List<TEExpenseReportsPrnCtrl.ExpenseDetailLogVO> previewResultList {get;set;}
    
    public TEExpenseReportsCtrl() {
        setupPrnPayrollReport();
    }
    
    private void setupPrnPayrollReport() {
        this.proxyDateFrom = new Expense_Detail__c();
        this.proxyDateTo = new Expense_Detail__c();
        
        Date currentDate = System.Today();
        
        this.proxyDateFrom.Receipt_Date__c = Date.newInstance(currentDate.year(), currentDate.month(), 1);
        this.proxyDateTo.Receipt_Date__c = currentDate.addMonths(1).toStartofMonth().addDays(-1);
        
        this.prnFilterOptions = new List<SelectOption>();
        this.prnFilterOptions.add(new SelectOption('all', 'All'));
        this.prnFilterOptions.add(new SelectOption('gte7', '>= G7'));
        this.prnFilterOptions.add(new SelectOption('lt7', '< G7'));
    }
    
    public PageReference generatePrnPayrollReport() {
        PageReference pr = new PageReference('/apex/TEExpenseReportsPrnVFP');
        pr.setRedirect(true);
        pr.getParameters().put('dateFromStr', getDateString(proxyDateFrom.Receipt_Date__c));
        pr.getParameters().put('dateToStr', getDateString(proxyDateTo.Receipt_Date__c));
        pr.getParameters().put('filterOpt', selectedPrnFilter);
        
        return pr;
    }
    
    private String getDateString(Date theDate) {
        String result = '';
        result += theDate.year();
        
        if(theDate.month() < 10) {
            result += '0' + theDate.month();
        } else {
            result += theDate.month();
        }
        
        if(theDate.day() < 10) {
            result += '0' + theDate.day();
        } else {
            result += theDate.day();
        }
        
        return result;
    }
    
    public PageReference previewPrnPayrollReport(){
        TEExpenseReportsPrnCtrl PrnCtrl = new TEExpenseReportsPrnCtrl(selectedPrnFilter,getDateString(proxyDateFrom.Receipt_Date__c), getDateString(proxyDateTo.Receipt_Date__c));
        previewResultList = PrnCtrl.orderedExpenseDetailVoList;
        System.debug(String.valueOf(previewResultList));
        return null;
    }
}