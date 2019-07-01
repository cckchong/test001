/**
 * @description determine which app that user has selected
 */
public class HomeLeftNavigationCtrl {

    public String selectedApp {get;set;}

    /** Education **/
    public boolean childEducationApplicable {get;set;} {childEducationApplicable = false;}
    public String EducationHCMLinkId {get;set;}
    
    public HomeLeftNavigationCtrl() {
        this.init();
    }
    
    private void init() {
        // Get tab set describes for each app
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();

        // Iterate through each tab set describe for each app and display the info
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
            if (tsr.isSelected()) {
                selectedApp = tsr.getLabel();
                break;   
            }           
        }
        
        for (Employee_Administrator__c eas: [SELECT Id, Name, Employee_UserId__c, Administrator__c, Employee__r.Tech_Grade__c, Employee__r.Education_Policy__c,
                                             Employee__r.Education_Policy__r.Child_Education_Application_Min_Grade__c,
                                             Employee__r.Education_Policy__r.Child_Education_Application_Max_Grade__c
                                             FROM Employee_Administrator__c 
                                             WHERE Administrator__c = :String.valueOf(UserInfo.getUserId()).subString(0, 15)]) { 
            if (eas.Employee__r.Tech_Grade__c >= eas.Employee__r.Education_Policy__r.Child_Education_Application_Min_Grade__c &&
                eas.Employee__r.Tech_Grade__c <= eas.Employee__r.Education_Policy__r.Child_Education_Application_Max_Grade__c ){
                childEducationApplicable = true;
            }
        }
        
        // Determine Education & Expense HCM Link
        String physicalAddress;
        For (User u : [Select Id, Physical_Delivery_Address__c From User Where Id = :UserInfo.getUserId()]){
            physicalAddress = u.Physical_Delivery_Address__c;
        }
        List<String> temp = new List<String>();
        For(String reader : Label.TE_Education_HCM_List_View_ID_Map.split(';'))
        {    
            if (reader != ''){
                temp = reader.split(',');
                if (!temp.isEmpty() && temp.size() >= 2){
                    if (temp[0] == physicalAddress && temp[1] != ''){
                        EducationHCMLinkId = temp[1];
                    }
                }
            }
        }
    }
}