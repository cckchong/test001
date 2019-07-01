/**
 * TETravelApplicationViewBudgetCtrl
 * @description View travelling budget in corresponding site and department
 * @author Zoe Xiang
 */
public without sharing class TETravelApplicationViewBudgetCtrl {
    
    private Id id;
    private static final String FINGROUOPNAMECODE = '@name';
    private static final String FIN_GROUOP_NAME= 'TE_@name_FIN';
    private static final String EXPENSE_CATEGORY= 'Travel';
    private static final String BUDGET_NAME = '@name';
    private static final String BUDGET_AMOUNT = '@budget';
    private static final String REMAINING_AMOUNT = '@remaining';
    private String str = '';
    
    public string budgetMsg {    
        get{
            Travel_Application__c TravelApplication = getTravelApplication(this.id);
            if (TravelApplication.on_behalf_of__r.employee__r.expense_policy__c == null){
                budgetMsg = Label.TE_View_Budget_No_Expense_Policy;
                return budgetMsg;
            }
            
            Budget__c targetBudget = getBudget(TravelApplication);
             
            if (authorizedUser() && targetBudget != null){
                str = Label.TE_View_Budget;
                str = str.replace(BUDGET_NAME, targetBudget.Expense_Category__r.Name);
                str = str.replace(BUDGET_AMOUNT, targetBudget.Currency__r.Name +'\t'+ targetBudget.Budget__c);
                str = str.replace(REMAINING_AMOUNT, targetBudget.Currency__r.Name +'\t'+ targetBudget.Remaining_Amount__c);   
                budgetMsg = TravelApplication.on_behalf_of__r.employee__r.Department__c +' ';
                budgetMsg += str;
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
    public TETravelApplicationViewBudgetCtrl(ApexPages.StandardController controller) {
        
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
        Travel_Application__c TravelApplication = getTravelApplication(this.id);
        groupName = FIN_GROUOP_NAME;
        groupName = groupName.replace(FINGROUOPNAMECODE, TravelApplication.on_behalf_of__r.employee__r.expense_policy__r.name);
        
        if ((TravelApplication.Actual_Approver_1__c == UserInfo.getUserId()) || (TravelApplication.Actual_Approver_2__c == UserInfo.getUserId()) ||
            (TravelApplication.Actual_Approver_3__c == UserInfo.getUserId()) || (TravelApplication.Actual_Approver_4__c == UserInfo.getUserId())){
                authorized = true;
        }
        //if in the authorized group
        if (!authorized){
            for(GroupMember reader : [select id 
                                      from GroupMember 
                                      where
                                      UserOrGroupId = :UserInfo.getUserId()
                                      and GroupId in (select id from Group where DeveloperName = :groupName )] ){
                authorized = true;
            }
        }
        //if is budget's owner
        if (!authorized){
            Budget__c targetBudget = getBudget(getTravelApplication(this.id));
            if (targetBudget != null){
                if (UserInfo.getUserId() == targetBudget.OwnerId){
                    authorized = true;
                }
            }
        }
        return authorized;
    }
    
    private Budget__c getBudget(Travel_Application__c TravelApplication ) {
        String category = 'Travel';
        Budget__c[] budgetList = [select id, OwnerId, Name, Expense_Category__r.Name,
                        Budget__c, Remaining_Amount__c, Currency__r.Name
                from Budget__c
                where Expense_Category__r.is_travel__c = true
                        AND Department__c = :TravelApplication.on_behalf_of__r.employee__r.Department__c
                        AND Site__r.Name = :TravelApplication.on_behalf_of__r.employee__r.Site__r.Name
                        AND Year__c = :TravelApplication.Year__c];
        if (budgetList.size()>0){
            return budgetList[0];
        }
        else{                
            return null;
        }
    }
    
    Public Travel_Application__c getTravelApplication(id travelApplicationId){        
        return [select id, 
                        on_behalf_of__r.employee__r.expense_policy__r.name,
                        on_behalf_of__r.employee__r.Department__c, 
                        on_behalf_of__r.employee__r.Site__r.Name,
                        Year__c,
                        Actual_Approver_1__c, Actual_Approver_2__c,
                        Actual_Approver_3__c, Actual_Approver_4__c 
                from Travel_Application__c 
                where id = :travelApplicationId];
    }
    
    public PageReference clear(){
        return new PageReference('/' + this.id);
    }

}