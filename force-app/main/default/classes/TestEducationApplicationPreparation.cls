@isTest
public class TestEducationApplicationPreparation {
/*   
    public static Currency__c setCurrency(){
        Currency__c cad = new Currency__c(
            Name = 'CAD',
            Description__c = 'Hong Kong Dollar');
        insert cad;
        Currency__c hkd = new Currency__c(
            Name = 'HKD',
            Description__c = 'Canadian Dollar');
        insert hkd;
        List<Currency__c> currList = new List<Currency__c>();
        for (Currency__c c : [SELECT Id, Name, Description__c FROM Currency__c WHERE Name = 'HKD' LIMIT 1]){
            currList.add(c);
        }
        if (currList.isEmpty()){
            return null;
        }
        return currList.get(0);
    }
    
    public static Map<String, RecordType> getRecordType() {
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
        List<String> developerNameList = new List<String>();
        developerNameList.add('Education');
        developerNameList.add('Child_Education');
        for (RecordType rt : [select Id, Name, DeveloperName from RecordType where DeveloperName IN :developerNameList]) {
            recordTypeMap.put(rt.DeveloperName, rt);
        }
        return recordTypeMap;
    }
    
    public static Education_Application__c getEduApp(Id onBehalfOfId, Id ownerId, Currency__c curr){
        List<Education_Application__c> eduAppList = new List<Education_Application__c>();
        date d1 = date.newInstance(2015, 7, 8);
        Education_Application__c newEduApp = new Education_Application__c(
            Apply_Date__c = d1,
            On_Behalf_Of__c = onBehalfofId,//EmpAdminList.get(0).Id,
            OwnerId = ownerId,//UserMap.get('user1').Id,
            RecordTypeId = getRecordType().get('Education').Id,    // '012O00000000kxTIAQ' Education, '012O00000000kxYIAQ' Child Education
            Status__c = 'DF',
            Degree_Course_Title__c = 'Discrete Mathematics',
            Education__c = 'HKU',
            Tuition_Fee__c = 42100,
            Currency__c = curr.Id,
            Start_Date__c = d1,
            End_Date__c = d1,
            Course_URL__c = 'http://www.cs.hku.hk'
        );
        insert newEduApp;
        for (Education_Application__c ea : [SELECT Id, Status__c, Actual_Approver_1__c, Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c 
                                            FROM Education_Application__c 
                                            WHERE Id =: newEduApp.Id]){
            eduAppList.add(ea);
        }
        if (eduAppList.isEmpty()){
            return null;
        }
        return eduAppList.get(0);
    }
    
    private static Employee__c getFromEmpAdminId(Id userId){
        Employee__c emp = null;
        for (Employee__c e : [SELECT Id, User__c, Site__c 
                              FROM Employee__c 
                              WHERE Id IN (SELECT Employee_Administrator__c FROM Employee_Administrator__c WHERE Id =: userId) 
                              LIMIT 1]){
            emp = e;
        }
        return emp;
    }
    
    public static User addIntoGroup(String groupName, Id userId){
        User admin = null;
        Group g = null;
        for (Group gp : [SELECT Id, Name FROM Group WHERE Name =: groupName]){
            g = gp;
        }
        if (g == null) {
            return null;
        }
        GroupMember member = new GroupMember();
        Employee__c emp = getFromEmpAdminId(userId);
        for (User u : [SELECT Id FROM User WHERE Id = :emp.User__c LIMIT 1]){
            admin = u;
        }
        if (admin == null) {
            return null;
        }
        member.UserOrGroupId = admin.Id;
        member.GroupId = g.Id;
        insert member;
        return admin;
    }
    
    public static Site__c editSite(String newSiteName, Id empAdminId){
        Employee__c emp = getFromEmpAdminId(empAdminId);
        Site__c site = null;
        for (Site__c s : [SELECT Name, Site_ID__c FROM Site__c WHERE Id =: emp.Site__c LIMIT 1]){
            site = s;
        }
        if (site == null) {
            return null;
        }
        site.Site_ID__c = 'HKO';
        site.Name = 'HKO';
        update site;
        for (Site__c s : [SELECT Site_ID__c FROM Site__c WHERE Id =: emp.Site__c LIMIT 1]){
            site = s;
        }
        return site;
    }
    
    public static Employee__c getEmployee(Id userId){
        List<Employee__c> empList = new List<Employee__c>();
        for (Employee__c e : [SELECT Id, Approver_1__c, Approver_2__c,Approver_3__c,Approver_4__c, Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c, User__c FROM Employee__c WHERE user__c =: userId]){
            empList.add(e);
        }
        if (empList.isEmpty()) {
            return null;
        }
        return empList.get(0);
    }
    
    public static Education_Application__c getNewEduApp(Id eduAppId){
        Education_Application__c ea = null;
        for (Education_Application__c eduapp : [SELECT Id, Status__c,Actual_Approver_1__c,Actual_Approver_2__c, Actual_Approver_3__c, Actual_Approver_4__c FROM Education_Application__c WHERE Id =: eduAppId]) {
            ea = eduapp;
        }
        return ea;
    }
    
    public static Education_Policy__c createEducationPolicy(String name) {
        Education_Policy__c edpToReturn;
        List<Id> educationPolicyIDList = new List<Id>();
        for (Education_Policy__c edp : [select Id, Name from Education_Policy__c where Name = :name]) {
            educationPolicyIDList.add(edp.Id);
        }
        if (educationPolicyIDList.isEmpty()) {
            List<Education_Policy__c> educationPolicyList = new List<Education_Policy__c>();
            Education_Policy__c edp1 = new Education_Policy__c(
                Name = name,
                Child_Education_Application_Min_Grade__c = 1,
                Admin_Email__c = 'tahcmuser@gmail.com'
            );
            educationPolicyList.add(edp1);
            insert educationPolicyList;
            for (Education_Policy__c edp : educationPolicyList) {
                educationPolicyIDList.add(edp.Id);
            }
        }
        for (Education_Policy__c edp : [select Id, Name, Admin_Email__c, Child_Education_Application_Min_Grade__c, RecordTypeId from Education_Policy__c where Id IN :educationPolicyIDList]) {
            edpToReturn = edp;
        }
        return edpToReturn;
    }
    
    public static void setEducationPolicy(Id eduPolicyId, Id empAdminId) {
        Employee__c emp = null;
        for (Employee__c e : [SELECT Id, Education_Policy__c
                              FROM Employee__c 
                              WHERE Id IN (SELECT Employee__c FROM Employee_Administrator__c WHERE Id =: empAdminId) 
                              LIMIT 1]){
            emp = e;
        }
        if (emp != null) {
            emp.Education_Policy__c = eduPolicyId;
            update emp;
        }
    }
//*/
}