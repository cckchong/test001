/**
 * TEExpenseApplicationViewBudgetCtrl
 * @description View travelling budget in corresponding site and department
 */

public without sharing class TEExpenseApplicationViewBudgetCtrl {
    
    private Id id;
    private static final String FINGROUOPNAMECODE = '@name';
    private static final String FIN_GROUOP_NAME= 'TE_@name_FIN';    
    private static final String BUDGET_NAME = '@name';
    private static final String BUDGET_AMOUNT = '@budget';
    private static final String REMAINING_AMOUNT = '@remaining';
    private String str = '';
    //private static final String EXPENSE_CATEGORY= 'Travel';
    
    public string budgetMsg {    
        get{
            Expense_Application__c expenseApplication = getExpenseApplication(this.id);
            if (expenseApplication.on_behalf_of__r.employee__r.expense_policy__c == null){
                budgetMsg = Label.TE_View_Budget_No_Expense_Policy;
                return budgetMsg;
            }
            
            Budget__c[] targetBudget = getBudget(expenseApplication);
             
            if (authorizedUser() && targetBudget != null){
                budgetMsg ='';
                for(Budget__c reader : targetBudget) {
                    str = Label.TE_View_Budget;
                    str = str.replace(BUDGET_NAME, reader.Expense_Category__r.Name);
                    str = str.replace(BUDGET_AMOUNT, reader.Currency__r.Name +'\t'+ reader.Budget__c);
                    str = str.replace(REMAINING_AMOUNT, reader.Currency__r.Name +'\t'+ reader.Remaining_Amount__c);                    
                    budgetMsg += expenseApplication.on_behalf_of__r.employee__r.Department__c +' ';
                    budgetMsg += str;
                }
                
                budgetMsg += Label.TE_View_Budget_Reminder;
            }
            else if (targetBudget == null)
            {
                budgetMsg = Label.TE_View_Budget_No_Budget;
            }
            else{
                budgetMsg = Label.TE_View_Budget_No_Access;
            }
            return budgetMsg;
        } private set;
    }
    
     /**
     * @description constructor with StandardController
     */
    public TEExpenseApplicationViewBudgetCtrl(ApexPages.StandardController controller) {
        
        String textId = ApexPages.currentPage().getParameters().get('id');
        if (textId != null) {
            id = textId;
        }
    }
    
    /**
     * Check whether current logged in user is authorized
     */
    private boolean authorizedUser() {
        Boolean authorized = false;
        String groupName = '';
        Expense_Application__c expenseApplication = getExpenseApplication(this.id);
        groupName = FIN_GROUOP_NAME;
        groupName = groupName.replace(FINGROUOPNAMECODE, expenseApplication.on_behalf_of__r.employee__r.expense_policy__r.name);

        //if in the authorized group
        for(GroupMember reader : [select id 
                                  from GroupMember 
                                  where
                                  UserOrGroupId = :UserInfo.getUserId()
                                  and GroupId in (select id from Group where DeveloperName = :groupName )] ){
            authorized = true;
        }
        
        //if is budget's owner or auctual approver
        Budget__c[] targetBudget = getBudget(getExpenseApplication(this.id));
        if (targetBudget != null){
            for(Budget__c reader : targetBudget) {
                if (UserInfo.getUserId() == reader.OwnerId){
                    authorized = true;
                }
            }
            if(UserInfo.getUserId() == expenseApplication.Actual_Approver_1__c ||
               UserInfo.getUserId() == expenseApplication.Actual_Approver_2__c ||
               UserInfo.getUserId() == expenseApplication.Actual_Approver_3__c ||
               UserInfo.getUserId() == expenseApplication.Actual_Approver_4__c){
               authorized = true;
            }
        }
        return authorized;
    }
    
    private Budget__c[] getBudget(Expense_Application__c expenseApplication ) {
        //String category = 'Travel';
        Budget__c[] budgetList = [select id, OwnerId,Budget__c, Remaining_Amount__c,
                                  Currency__r.Name, Expense_Category__r.Name
                                  from Budget__c
                                  where Department__c = :expenseApplication.on_behalf_of__r.employee__r.Department__c
                                  AND Site__r.Name = :expenseApplication.on_behalf_of__r.employee__r.Site__r.Name
                                  AND Year__c = :expenseApplication.Year__c];
                //Expense_Category__r.Name = :category
                
        if (budgetList.size()>0){
            return budgetList;
        }
        else{                
            return null;
        }
    }
    
    Public Expense_Application__c getExpenseApplication(id expenseApplicationId){        
        return [select id, 
                        on_behalf_of__r.employee__r.expense_policy__r.name,
                        on_behalf_of__r.employee__r.Department__c, 
                        on_behalf_of__r.employee__r.Site__r.Name,
                        Year__c,
                        Actual_Approver_1__c,
                        Actual_Approver_2__c,
                        Actual_Approver_3__c,
                        Actual_Approver_4__c
                from Expense_Application__c 
                where id = :expenseApplicationId];
    }
    
    public PageReference clear(){
        return new PageReference('/' + this.id);
    }

}