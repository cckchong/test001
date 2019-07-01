@isTest
public  class TestTEExpenseApplication extends TestTEPreparation {

    public TestTEExpenseApplication ( Boolean isSeeAllData ){
        super(isSeeAllData);
        Preparation(isSeeAllData);
    }

    public TEExpenseApplicationCtrl createExpenseApplication(Employee__c employee, Map<String, Employee_Administrator__c> ea, String userName){
        TEExpenseApplicationCtrl eaCtrl = new TEExpenseApplicationCtrl();
        
        return eaCtrl;
    }    
 
    
}