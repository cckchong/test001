public with sharing class SurveyAssignmentObjectUtil {

    public static final String ADMINISTRATOR = 'admin';
    public static final String TAKER = 'taker';
    public static final String NATURE_ADMINISTRATOR = 'Administrator';
    public static final String NATURE_TAKER = 'Taker';
    public static final String MODE_VIEW = 'view';
    public static final String MODE_ADD = 'add';

    // 
    public class SurveyAssignmentResult {
        public String Id { get; set; }
        public String UserId {get; set;}
        public String GroupId {get; set;}
        public String UserOrGroupName { get; set; }
        public String Type { get; set; }
        public String Reason { get; set; }
        public String Email { get; set; }
        public boolean HasDeleteAccess { get; set; }
        //public boolean HasCheck { get; set; }
        public SurveyAssignmentResult(){}
    }
    
    public static Integer getTotalSurveyAssignment(String surveyId, String assignmentNature) {
        Set <String> userSet = new Set <String>();
        Set <String> groupSet = new Set <String>();
        for(Survey_Assignment__c reader : [Select id, User__c, User__r.Name, GroupId__c, Type__c, Assignment_Nature__c 
                            from Survey_Assignment__c where Survey__c = :surveyId 
                            and Assignment_Nature__c = :assignmentNature
                            order by Type__c
                    ]){
            userSet.add(reader.User__c);
            groupSet.add(reader.GroupId__c);
            
         }

         for(GroupMember reader : [SELECT Id, UserOrGroupId, GroupId FROM GroupMember where GroupId = :groupSet]){
            userSet.add(reader.UserOrGroupId); 
         }
         if(userSet.contains(null))
         {
            return userSet.size()-1;
         }
         else
         {
            return userSet.size();
         }
         
    }
    
    
    public static  List<SurveyAssignmentResult> getSurveyAssignment(String surveyId, String userId, String assignmentNature) {

        String surveyOwner=[select id, ownerid from Survey__c where id =:surveyId].ownerid;// ADD by DTT team
        Map<String, UserRecordAccess> UserDelRecordAccessMap = new Map<String, UserRecordAccess>();        
        set<id> SurveyAssignmentIdSet = new set<id>();
        set<id> SurveyAssignmentuIdSet = new set<id>();
        set<id> GroupNameSet = new set<id>();
        List<SurveyAssignmentResult> listResult = new List<SurveyAssignmentResult>();
        // retrieve survey assignment records associated to a particular survey record
        List<Survey_Assignment__c> listSurveyAssignments = 
                    [Select id, User__c, User__r.Name, GroupId__c, Type__c, Assignment_Nature__c,
                            User__r.Email
                            from Survey_Assignment__c where Survey__c = :surveyId 
                            and Assignment_Nature__c = :assignmentNature
                            and user__c !=:surveyOwner// ADD by DTT team
                            order by Type__c
                    ]; 
        for (Survey_Assignment__c a : listSurveyAssignments) {
            SurveyAssignmentIdSet.add(a.id);
            SurveyAssignmentuIdSet.add(a.User__c);
            GroupNameSet.add(a.GroupId__c);
        }
        Map <id, Group> GroupMap = new Map <id, Group>([Select id, Name from Group Where Id = :GroupNameSet]);

        //Comment by DTT Support Team
        //for (UserRecordAccess  a : [Select  HasDeleteAccess,  RecordId 
        //                                             From UserRecordAccess 
        //                                             Where 
        //                                             UserId  =:userId
        //                                             and RecordId in :SurveyAssignmentuIdSet                                            
        //                                               ]) {
        //    if(a.HasDeleteAccess){
        //        UserDelRecordAccessMap.put(a.RecordId, a);
        //    }
        //}

        
        /*
        for (Survey_Assignment__c a : listSurveyAssignments) {
            SurveyAssignmentResult result = new SurveyAssignmentResult();
            result.Id = a.id;
            result.Type = a.Type__c;
            // user name and group name is mutually exclusive. Use a single property to store the single value
            if (String.IsNotBlank(a.User__c)) {
                result.UserId =  a.User__c;
                result.UserOrGroupName = a.User__r.Name;
            } else if (String.IsNotBlank(a.GroupId__c)) {
                result.GroupId =  a.GroupId__c;
                // since groupid is not a look up field, group name cannot retrieve by relationship
                // group name is retrieved by separate SOQL statement
                List<Group> listGroup = [Select Name from Group Where Id = :a.GroupId__c];
                if (listGroup != null && listGroup.size() > 0) {
                    result.UserOrGroupName = listGroup.get(0).Name;
                } else {
                    result.UserOrGroupName = '';
                }
            } else {
                result.UserOrGroupName = '';
            }
            result.Reason = a.Assignment_Nature__c;

            // check if user has delete to a particular survey assignment record
            // record owner, system administrator and users whose role is on the top part of the hierarchy 
            // can delete record
            List<UserRecordAccess> listRecAccess = [ Select RecordId, HasDeleteAccess 
                                                     From UserRecordAccess 
                                                     Where UserId = :userId and RecordId = :a.Id ];
            result.HasDeleteAccess = false;
            if (listRecAccess != null && listRecAccess.size() > 0) {
                result.HasDeleteAccess = listRecAccess.get(0).HasDeleteAccess;
            }
            System.debug('result.Id: ' + result.Id + ', user or group name: ' + result.UserOrGroupName);
            listResult.add(result);
        }
        */
        
        for (Survey_Assignment__c a : listSurveyAssignments) {
            SurveyAssignmentResult result = new SurveyAssignmentResult();
            result.Id = a.id;
            result.Type = a.Type__c;
            result.email = a.user__r.email;
            // user name and group name is mutually exclusive. Use a single property to store the single value
            if (String.IsNotBlank(a.User__c)) {
                result.UserId =  a.User__c;
                result.UserOrGroupName = a.User__r.Name;
            } else if (String.IsNotBlank(a.GroupId__c)) {
                result.GroupId =  a.GroupId__c;
                result.UserOrGroupName = '';
                // since groupid is not a look up field, group name cannot retrieve by relationship
                // group name is retrieved by separate SOQL statement
                //List<Group> listGroup = [Select Name from Group Where Id = :a.GroupId__c];                
                if(GroupMap.containskey(a.GroupId__c)){
                    result.UserOrGroupName = GroupMap.get(a.GroupId__c).Name;
                }
                /*
                if (listGroup != null && listGroup.size() > 0) {
                    result.UserOrGroupName = listGroup.get(0).Name;
                } else {
                    result.UserOrGroupName = '';
                }
                */
            } else {
                result.UserOrGroupName = '';
            }
            result.Reason = a.Assignment_Nature__c;

            // check if user has delete to a particular survey assignment record
            // record owner, system administrator and users whose role is on the top part of the hierarchy 
            // can delete record
            /*
            List<UserRecordAccess> listRecAccess = [ Select RecordId, HasDeleteAccess 
                                                     From UserRecordAccess 
                                                     Where UserId = :userId and RecordId = :a.Id ];
            */
           
            
            //Comment by DTT Support Team
            //result.HasDeleteAccess = false;
            //if(UserDelRecordAccessMap.containsKey(a.Id)){
            result.HasDeleteAccess = true;
            //}
            /*
            if (listRecAccess != null && listRecAccess.size() > 0) {
                result.HasDeleteAccess = listRecAccess.get(0).HasDeleteAccess;
            }
            */
            System.debug('result.Id: ' + result.Id + ', user or group name: ' + result.UserOrGroupName);
            listResult.add(result);
        }
        
        
        // sort by name
        Map<String, SurveyAssignmentResult> sortNameMap = new Map<String, SurveyAssignmentResult>();
        Map<String, SurveyAssignmentResult> sortNameMap1 = new Map<String, SurveyAssignmentResult>();//add by DTT
        Integer suffix = 1;
        for (SurveyAssignmentResult sar: listResult) {
            if(sar.type=='User')
            sortNameMap.put(sar.USerOrGroupName + suffix, sar);
            suffix++;
        }
        for (SurveyAssignmentResult sar: listResult) {
            if(sar.type=='Group')
            sortNameMap1.put(sar.USerOrGroupName + suffix, sar);
            suffix++;
        }

        listResult.clear();
        List<String> sortKeys = new List<String>(sortNameMap.keySet());
        List<String> sortKeys1 = new List<String>(sortNameMap1.keySet());
        
        sortKeys.sort();
        for (String key : sortKeys) {
            listResult.add(sortNameMap.get(key));
        }
        sortKeys1.sort();
        for (String key : sortKeys1) {
            listResult.add(sortNameMap1.get(key));
        }
        
        return listResult;
    }

    public static void deleteSurveyAssignment(String surveyAssignmentId) {

        List<Survey_Assignment__c> ll = [Select id from Survey_Assignment__c where id = :surveyAssignmentId];
        delete ll;
    }

    public static void createAdministratorSurveyAssignment(String surveyId, List<String> listUserId) {
        createSurveyAssignment(surveyId, listUserId, null, NATURE_ADMINISTRATOR);
    }

    public static void createTakerSurveyAssignment(String surveyId, List<String> listUserId, List<String> listGroupId) {
        createSurveyAssignment(surveyId, listUserId, listGroupId, NATURE_TAKER);        
    }

    private static void createSurveyAssignment(String surveyId, List<String> listUserId, List<String> listGroupId,
        String reason) {
        
        List<Survey_Assignment__c> ll = [Select id, User__c, GroupId__c from Survey_Assignment__c 
                                         where Survey__c = :surveyId and Assignment_Nature__c = :reason];
        Map<String, String> mapExistAssignments = new Map<String, String>();
        for (Survey_Assignment__c a : ll) {
            if (String.isNotBlank(a.User__c)) {
                mapExistAssignments.put(a.User__c, a.User__c);
            } else if (String.isNotBlank(a.GroupId__c)) {
                mapExistAssignments.put(a.GroupId__c, a.GroupId__c);                    
            }
        }                                
        List<Survey_Assignment__c> newSurveyAssignment = new List<Survey_Assignment__c>();
        if (listUserId != null && listUserId.size() > 0) {
            for (String userId : listUserId) {
                if (!mapExistAssignments.containsKey(userId)) {
                    Survey_Assignment__c newUser = new Survey_Assignment__c();
                    newUser.Assignment_Nature__c = reason;
                    newUser.Survey__c = surveyId;
                    newUser.User__c = userId;
                    newUser.GroupId__c = '';
                    newSurveyAssignment.add(newUser);
                }
            }
        }
        if (listGroupId != null && listGroupId.size() > 0) {
            for (String groupId : listGroupId) {
                if (!mapExistAssignments.containsKey(groupId)) {
                    Survey_Assignment__c newGroup = new Survey_Assignment__c();
                    newGroup.Assignment_Nature__c = reason;
                    newGroup.Survey__c = surveyId;
                    newGroup.User__c = null;
                    newGroup.GroupId__c = groupId;
                    newSurveyAssignment.add(newGroup);
                }
            }
        }

        if (newSurveyAssignment.size() > 0) {
            insert newSurveyAssignment;
        }
    }
}