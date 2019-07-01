public with sharing class TEExpenseReportsPrnCtrl implements TEVisualforceReportInf {

    public Datetime dateFrom {get;set;}
    public Datetime dateTo {get;set;}
    public String filterOpt {get;set;}
    public String resultStr {get;set;}
    public List<ExpenseDetailLogVO> orderedExpenseDetailVoList {get;set;}

    private final Integer COL_WIDTH = 25;
    private final String EMPTY_SPACE = ' ';
    private final String LINE_BREAK = '\r\n';
    
    public interface PrnWritable {
        String getValue(String key);
    }
    
    public class ExpenseDetailLogVO implements PrnWritable {
        public String origEmployeeNo {get;set;}
        public String fullName {get;set;}
        public Decimal localAmount {get;set;}
        public String site {get;set;}
        
        public ExpenseDetailLogVO(String origEmployeeNo, String fullName, Decimal localAmount, String site) {
            this.origEmployeeNo = origEmployeeNo;
            this.fullName = fullName;
            this.localAmount = localAmount;
            this.site = site;
        }
        
        public String getValue(String key) {
            if(key == 'origEmployeeNo') {
                return origEmployeeNo;
            } else if(key == 'fullName') {
                return fullName;
            } else if(key == 'localAmount') {
                return String.valueOf(localAmount);
            } else if(key == 'site') {
                return site;
            } else {
                return '';
            }
        }
    }
    
    public TEExpenseReportsPrnCtrl() {
        getParameters();
        execute();
    }

    public TEExpenseReportsPrnCtrl(String fO, String dFrom, String dTo) {
        this.filterOpt = FO;
        this.dateFrom = formatDate(dFrom, true);
        this.dateTo = formatDate(dTo, false);
        execute();
    }
        
    public void getParameters() {
        String dateFromStr = ApexPages.currentPage().getParameters().get('dateFromStr');
        String dateToStr = ApexPages.currentPage().getParameters().get('dateToStr');
        this.filterOpt = ApexPages.currentPage().getParameters().get('filterOpt');
        
        this.dateFrom = formatDate(dateFromStr, true);
        this.dateTo = formatDate(dateToStr, false);
    }
    
    public void execute() {
        fetchPrnLog();
    }
    
    /**
     * @description assumes the String is in yyyyMMdd format
     */
    private Datetime formatDate(String str, boolean isFrom) {
        Datetime parsedDate;

        try {
            if(isFrom) {
                parsedDate = Datetime.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(4, 6)), Integer.valueOf(str.right(2)), 0, 0, 0);
            } else {
                parsedDate = Datetime.newInstance(Integer.valueOf(str.left(4)), Integer.valueOf(str.substring(4, 6)), Integer.valueOf(str.right(2)), 23, 59, 59);
            }
            
        } catch (Exception e) {
            throw new TalException('Invalid date format. Must be yyyyMMdd. ' + e.getMessage());
        }
        
        return parsedDate;
    }

    private void fetchPrnLog() {
        Map<String, ExpenseDetailLogVO> employeeIdToLog = new Map<String, ExpenseDetailLogVO>();
        List<Expense_Detail_Log__c> expenseLogList = new List<Expense_Detail_Log__c>();
        //List<ExpenseDetailLogVO> orderedExpenseDetailVoList = new List<ExpenseDetailLogVO>();
        orderedExpenseDetailVoList = new List<ExpenseDetailLogVO>();

        List<Expense_Detail_Log__c> resultList = new List<Expense_Detail_Log__c>();
        List<String> colHeaderList = new List<String>();
        colHeaderList.add('OrigEmployeeNo');
        colHeaderList.add('FullName');
        colHeaderList.add('Site');
        colHeaderList.add('LocalAmount');
        
        if(String.isBlank(filterOpt) || filterOpt == 'all') {
            resultList = [
                SELECT Employee_ID__c, Original_Employee_ID__c, Id, Employee_Full_Name__c, Local_Amount_For_Payroll__c, Site__c
                FROM expense_detail_log__c
                WHERE Type__c IN ('Expense_Detail_Closed', 'Cash_Advance_Closed')
                AND Pay_Cheque__c = false
                AND (CreatedDate >= :dateFrom AND CreatedDate <= :dateTo)
                ORDER BY Original_Employee_ID__c ASC
            ];
        } else if(filterOpt == 'gte7') {
            resultList = [
                SELECT Employee_ID__c, Original_Employee_ID__c, Id, Employee_Full_Name__c, Local_Amount_For_Payroll__c, Site__c
                FROM expense_detail_log__c
                WHERE Type__c IN ('Expense_Detail_Closed', 'Cash_Advance_Closed')
                AND Pay_Cheque__c = false
                AND (CreatedDate >= :dateFrom AND CreatedDate <= :dateTo)
                AND Tech_Grade__c >= 7
                ORDER BY Original_Employee_ID__c ASC
            ];
        } else if(filterOpt == 'lt7') {
            resultList = [
                SELECT Employee_ID__c, Original_Employee_ID__c, Id, Employee_Full_Name__c, Local_Amount_For_Payroll__c, Site__c
                FROM expense_detail_log__c
                WHERE Type__c IN ('Expense_Detail_Closed', 'Cash_Advance_Closed')
                AND Pay_Cheque__c = false
                AND (CreatedDate >= :dateFrom AND CreatedDate <= :dateTo)
                AND (Tech_Grade__c < 7 OR Tech_Grade__c = null)
                ORDER BY Original_Employee_ID__c ASC
            ];
        }
        
        if(resultList != null && !resultList.isEmpty()) {
            for(Expense_Detail_Log__c log : resultList) {
                ExpenseDetailLogVO vo;
                
                if(employeeIdToLog.get(log.Employee_ID__c) == null) {
                    vo = new ExpenseDetailLogVO(log.Original_Employee_ID__c, log.Employee_Full_Name__c, log.Local_Amount_For_Payroll__c, log.Site__c);
                    expenseLogList.add(log);
                    
                } else {
                    vo = employeeIdToLog.get(log.Employee_ID__c);
                    vo.localAmount += log.Local_Amount_For_Payroll__c;
                }
                
                employeeIdToLog.put(log.Employee_ID__c, vo);
            }
            
            
            for(Expense_Detail_Log__c dl : expenseLogList) {
                orderedExpenseDetailVoList.add(employeeIdToLog.get(dl.Employee_ID__c));
            }

        }
        
        if(orderedExpenseDetailVoList != null && !orderedExpenseDetailVoList.isEmpty()) {
            this.resultStr = prnWriter(orderedExpenseDetailVoList, colHeaderList);
        } else {
            this.resultStr = 'NO DATA AVAILABLE';
        }
    }

    private String prnWriter(List<PrnWritable> resultList, List<String> colHeaderList) {
        String result = '';
        result += 'TAL TRAVEL AND EXPENSE PRN PAYROLL FILE: Closed from ' + dateFrom.format() + ' to ' + dateTo.format() + LINE_BREAK + LINE_BREAK;
        
        for(String header : colHeaderList) {
            result += padColValue(header, COL_WIDTH);
        }
        
        result += LINE_BREAK;
        
        for(PrnWritable obj : resultList) {
            for(String key : colHeaderList) {
                String value = obj.getValue(key);
                result += padColValue(value, COL_WIDTH);
            }
            
            result += LINE_BREAK;
        }
        
        return result;
    }
    
    private String padColValue(String value, Integer colWidth) {
        String result = '';
        if(value != null) {
            Integer valSize = value.length();
            
            if(value.length() > colWidth) {
                result = value.left(colWidth);
            } else {
                result = value + EMPTY_SPACE.repeat(colWidth - value.length());
            }
        }
        
        return result;
    }
}