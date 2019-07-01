/**
 * @description To handle user account and employee record mapping
 */
 
public without sharing class ELeaveUserTriggerHandler {

    public static void handleELeave(Map<ID, User> users) {
        handleEmployeeMatching(users, false);
    }

    public static void handleEmployeeMatching(Map<ID, User> users, Boolean isLogin) {
        Map<String, User> employeeNumberToUser = new Map<String, user>();
        Map<ID, Employee__c> employees = new Map<ID, Employee__c>();
        
        // Find out all employee number
        for(ID userId : users.keySet()) {
            User user = users.get(userId);
            employeeNumberToUser.put(getUniqueEmployeeId(user), user);
        }
        
        // Check for update to existing matching
        for (Employee__c employee : [Select id, user__c, employee_id__c from Employee__c where user__c in :users.keySet()]) {
            User user = users.get(employee.user__c);

            if (employee.employee_id__c != getUniqueEmployeeId(user)) {
                if (isLogin) {
                    SystemUtil.handleException(new TALException('Unexpected update to employee ID for user ' + user.username));
                    return;
                } else {
                    user.addError('Unexpected update to employee ID for user ' + user.username);
                }
            }
        }
        
        // Check for employee ID duplication
        for (Employee__c employee : [Select id, Employee_ID__c, user__c from Employee__c where Employee_id__c in :employeeNumberToUser.keySet()]) {
            User user = employeeNumberToUser.get(employee.employee_id__c);
        
            if (employee.user__c == null) {
                employee.user__c = user.id;
                employees.put(employee.id, employee);
            } else if (employee.user__c != user.id) {
                if (isLogin) {
                    SystemUtil.handleException(new TALException('Duplicated employee ID ' + employee.employee_id__c));
                } else {
                    user.addError('Duplicated employee ID ' + employee.employee_id__c);
                }
            }
        }
        
        update employees.values();
    }
    
    /**
     * @description Map user account to employee record
     */
    public static void handleELeave(Map<ID, User> oldUsers, Map<ID, User> newUsers) {
            Boolean isLogin = false;   
            Map<String, String> employeeNumberMap = new Map<String, String>();
            if (oldUsers.size() == 1 && newUsers.size() == 1) {
                    isLogin = true;
            }        
            Map<ID, User> users = new Map<ID, User>();
            for (ID userId : oldUsers.keySet()) {
                User olduser = oldUsers.get(userId);
                User newUser = newUsers.get(userId);                
                if (oldUser == null || newUser == null) {
                    continue;
                }                
                if ((oldUser.firstName != newUser.firstName) || (oldUser.lastName != newUser.lastName) || (oldUser.EmployeeNumber!= newUser.EmployeeNumber)) {
                    employeeNumberMap.put(oldUser.EmployeeNumber, newUser.EmployeeNumber); 
                    users.put(newUser.id, newUser);
                }
            }            
            handleEmployeeMatching(users, isLogin);        
            List<Employee__c> employees = [Select id, User_Updated__c, Original_Employee_ID__c from Employee__c where user__c in :users.keySet()];
            for (Employee__c employee : employees) {
                if ( employeeNumberMap.containsKey(employee.Original_Employee_ID__c) ){
                    employee.Original_Employee_ID__c = employeeNumberMap.get(employee.Original_Employee_ID__c);
                }
                employee.User_Updated__c = employee.User_Updated__c == null ? 1 : employee.User_Updated__c + 1;
            }
            update employees;
    }
    
    public static String getUniqueEmployeeId(User user) {
        return user.Physical_Delivery_Address__c + user.employeeNumber;
    }
}