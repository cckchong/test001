public class ExpenseDetailBizTO implements Comparable{

    private final static String DEFAULT_MESSAGE = 'No Such Information';
    
    public Integer lineNo{get;set;}
    public Expense_Detail__c expenseDetail{get;set;}
    public TEExpenseApplicationCtrl controller{get;set;}
    public boolean enablePeople{get;set;}{enablePeople = false;}
    public boolean isEmptyLine{get;set;}
    public boolean isSaved{get;set;}{isSaved = false;}
    public Expense_Type__c expenseType{get;set;}
    public String maxCapInfo{get;set;}{maxCapInfo=DEFAULT_MESSAGE;}
    public double mealCap{get;set;}
    public Id mealCurrency{get;set;}
    public Id hotelCurrency{get;set;}
    public double hotelCap{get;set;}
    public Travel_Location_Allowance__c tla{get;set;}
    public String isExceedCap{get;set;}{isExceedCap= 'N';}
    public boolean showMessage{get;set;}{showMessage= false;}
    public boolean showIconFlag{get;set;}{showIconFlag= false;}
    public boolean isfinAction{get;set;}{isfinAction= false;}
    public boolean showReminder{get;set;}{showReminder= false;}
    public boolean isGeneralEditable{get;set;}{isGeneralEditable = false;}
    
    public boolean expenseTypeFlag{get;set;}{expenseTypeFlag= false;}
    public boolean receiptDateFlag{get;set;}{receiptDateFlag= false;}
    public boolean destinationFlag{get;set;}{destinationFlag= false;}
    public boolean currencyFlag{get;set;}{currencyFlag= false;}
    public boolean amountFlag{get;set;}{amountFlag= false;}
    public boolean finalAmountFlag{get;set;}{finalAmountFlag= false;}
    

    public ExpenseDetailBizTO(TEExpenseApplicationCtrl ctrl, Id recordTypeId){
        lineNo = 0; 
        controller = ctrl;
        expenseDetail = new Expense_Detail__c();
        expenseDetail.amount__c = 0.00;
        expenseDetail.Number_Of_People__c = 1;
        //expenseDetail.Number_Of_People__c = null;
        expenseDetail.recordTypeId = recordTypeId;
    }
    
    public ExpenseDetailBizTO(TEExpenseApplicationCtrl ctrl, Integer line, Id recordTypeId){
        lineNo = line; 
        controller = ctrl;
        expenseDetail = new Expense_Detail__c();
        expenseDetail.amount__c = 0.00;
        expenseDetail.Number_Of_People__c = 1;
        //expenseDetail.Number_Of_People__c = null;
        expenseDetail.recordTypeId = recordTypeId;
    }
    
    public ExpenseDetailBizTO(TEExpenseApplicationCtrl ctrl, Expense_Detail__c detail, Integer line){
        lineNo = line; 
        controller = ctrl;
        expenseDetail = detail;
        checkFinAction(expenseDetail);
    }
    
    public void checkFinAction(Expense_Detail__c detail){
        if(detail.status__c == TEConstant.STATUS_PENDING_FIN_Confirmation){
            isfinAction = true;
        }
    }
    
    public void insertRow(){
        controller.insertRow(lineNo);
    }
    /**
    public void insertFiveRows(){
        for (integer i = 0; i < 5; i++){
            controller.insertRow(lineNo);
        }
    }
    */
    public void removeRow(){
        controller.removeRow(lineNo);
    }
    
    public void duplicateRow(){
        controller.duplicateRow(lineNo);
    }
    
    public void triggerEnablePeople(){
    
        if(expenseDetail.Expense_Type__c != null){
            if(controller.expenseTypeMap!=null && controller.expenseTypeMap.size()>0){
                
                expenseType = controller.expenseTypeMap.get(expenseDetail.Expense_Type__c);
                 if(expenseType.Require_Number_of_People_Data__c){
                    enablePeople = true;
                    //expenseDetail.Number_Of_People__c = 1;
                }else {
                    enablePeople = false;
                    expenseDetail.Number_Of_People__c = 1;
                    //expenseDetail.Number_Of_People__c = null;
                }
            }
            
           
        } else {
            enablePeople = false;
            expenseDetail.Number_Of_People__c = 1;
            //expenseDetail.Number_Of_People__c = null;
        }
        
        refreshCap();
        updateReminder();
    }
    
    public void refreshShowIconFlag(){
        
        if(expenseType!=null && ((expenseType.Is_Meal_Expense__c || expenseType.Is_Hotel_Expense__c) && expenseDetail.Destination__c != null)){
            showIconFlag= true;
        } else {
            showIconFlag= false;
        }
    }
    
    public void initMaxCapParam(){
        mealCap = null;
        hotelCap =  null;
        mealCurrency = null;
        hotelCurrency = null;
        maxCapInfo = DEFAULT_MESSAGE ;
        showMessage = false;
    }

    public void refreshCap(){
        
        initMaxCapParam();
        refreshShowIconFlag();
         
        if(controller.tlaMap != null && expenseDetail.Destination__c != null){
            if(controller.tlaMap.containsKey(expenseDetail.Destination__c)){
                tla = controller.tlaMap.get(expenseDetail.Destination__c); 
                mealCap = tla.Daily_Maximum_Meal__c;
                hotelCap = tla.Daily_Maximum_Hotel_Cost__c;
                mealCurrency = tla.Expense_Policy__r.Meal_Allowance_Currency__c;
                hotelCurrency = tla.Expense_Policy__r.Hotel_Allowance_Currency__c;
                
                refreshInfo();
                controller.refreshTotalAmount();
            }
        }
    }
    
    public void refreshExceedCapFlag(){
       if(controller.tlaMap != null && expenseDetail.Destination__c != null){
           tla = controller.tlaMap.get(expenseDetail.Destination__c); 
           if(tla!=null){
               refreshInfo();
               controller.refreshTotalAmount();
           }
       }
       
    }
    
 

    public void refreshInfo(){
        Decimal dec = null;
        if(expenseType != null){
           
            if(expenseDetail.Destination__c != null){
            
                if(expenseType.Is_Meal_Expense__c ){
                
                    Travel_Location__c tl = [SELECT  Name FROM Travel_Location__c WHERE id = :expenseDetail.Destination__c];
                    dec = mealCap;
                    maxCapInfo = 'Limit for Meals in '+tl.Name+' is: '+tla.Maximum_of_Meal_Allowance_Currency__c+' '+((dec== null)? '':String.Valueof(dec.setscale(2)))+'/person';
                    showMessage = true;
                    System.debug('maxCapInfo '+maxCapInfo );
                } else if(expenseType.Is_Hotel_Expense__c ){
                    Travel_Location__c tl = [SELECT  Name FROM Travel_Location__c WHERE id = :expenseDetail.Destination__c];
                    dec = hotelCap;
                    maxCapInfo = 'Limit for Hotels in '+tl.Name+' is: '+tla.Maximum_of_Hotel_Allowance_Currency__c+' '+((dec== null)? '':String.Valueof(dec.setscale(2)))+'/person';
                    showMessage = true;
                }
            }
        }   
    }
    
    public void initMaxCapInfo(){
         if(controller.tlaMap != null && expenseDetail.Destination__c != null){
            if(controller.tlaMap.containsKey(expenseDetail.Destination__c)){
                tla = controller.tlaMap.get(expenseDetail.Destination__c); 
                mealCap = tla.Daily_Maximum_Meal__c;
                hotelCap = tla.Daily_Maximum_Hotel_Cost__c;
                mealCurrency = tla.Expense_Policy__r.Meal_Allowance_Currency__c;
                hotelCurrency = tla.Expense_Policy__r.Hotel_Allowance_Currency__c;
                
                refreshInfo();
                controller.refreshTotalAmount();
                refreshShowIconFlag();
            }
        }
    }
    
    public void refreshLineCapInfo(){
        initMaxCapParam();
        refreshShowIconFlag();
         
        if(controller.tlaMap != null && expenseDetail.Destination__c != null){
            if(controller.tlaMap.containsKey(expenseDetail.Destination__c)){
                tla = controller.tlaMap.get(expenseDetail.Destination__c); 
                mealCap = tla.Daily_Maximum_Meal__c;
                hotelCap = tla.Daily_Maximum_Hotel_Cost__c;
                mealCurrency = tla.Expense_Policy__r.Meal_Allowance_Currency__c;
                hotelCurrency = tla.Expense_Policy__r.Hotel_Allowance_Currency__c;
                
                refreshInfo();
                
            }
        }
    
    }
    
    public void updateReminder(){
        
        if(expenseType != null && controller.duration > 0){
            Double timeLimit = expenseType.Duration_Threshold__c;
            
            if(controller.duration > timeLimit && !String.isBlank(expenseType.Reminder__c)){
                showReminder = true;
            }
            
        } else {
            
            showReminder = false;
        
        }
    
    }  

     // Implement the compareTo() method
    public Integer compareTo(Object compareTo) {
        ExpenseDetailBizTO bizTO = (ExpenseDetailBizTO)compareTo;
        if(lineNo >bizTO.lineNo){
            return 1;
        }else if (lineNo < bizTO.lineNo){
            return -1;
        }else {
            return 0;
        }
    }
    
    public void setCurrencyByLoc(){
        expenseDetail.Receipt_Currency__c = null;
        if(expenseDetail.Destination__c != null){
            List<Travel_Location__c>  tempList = [select name, currency__c from travel_location__c where id =:expenseDetail.Destination__c]; 
            if(tempList.size() > 0){
                expenseDetail.Receipt_Currency__c =  tempList[0].currency__c;
            }
        }
    
    }
    
    public void onCurrencyChange(){
        setCurrencyByLoc();
        refreshCap();
    }
}