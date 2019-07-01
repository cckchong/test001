public with sharing class SurveyGroupSearchUtil {
    private SurveyGroupSearchUtil() {
        
    }

    public static boolean isUser (String userOrGroupId) {
        List<User> u = [Select Id From User Where Id = :userOrGroupId];
        return (u != null && u.size() > 0);
    }

    private static List<User> searchUsers(Set<String> setUserId) {

        List<User> listUsers = null;
        if (setUserId != null && setUserId.size() > 0) {
            listUsers = [Select Id, Email, Name_Display__c from User Where Id In :setUserId];
        } else {
            listUsers = new List<User>();
        }
        return listUsers;
    }

    public static Set<String> searchGroupMembers(List<String> groupId) {
        Set<String> setGroupMembers = new Set<String>();
        List<GroupMember> lstGroupMembers = [Select Id, GroupId, UserOrGroupId FROM GroupMember Where GroupId in :groupId];
        if(!lstGroupMembers.isEmpty()){
            for(GroupMember reader : lstGroupMembers){
                setGroupMembers.add(reader.UserOrGroupId);
            }
        }
        
        
        /*
        System.debug('[searchGroupMembers] - groupId: ' + groupId);
        Set<String> setGroupMembers = new Set<String>();
        List<GroupMember> lstGroupMembers = [Select Id, GroupId, UserOrGroupId FROM GroupMember Where GroupId = :groupId];
        if (lstGroupMembers != null && lstGroupMembers.size() > 0) {
            for (GroupMember member : lstGroupMembers) {
                System.debug('[searchGroupMembers] - member.UserOrGroupId: ' + member.UserOrGroupId);       
                if (isUser(member.UserOrGroupId)) {
                    System.debug('[searchGroupMembers] - Add user: ' + member.UserOrGroupId);
                    setGroupMembers.add(member.UserOrGroupId);
                } else {
                    // oh no, nested group encountered. Need to find group members of the nested group
                    System.debug('[searchGroupMembers] - Recursively add member in group: ' + member.UserOrGroupId);
                    setGroupMembers.addAll(searchGroupMembers(member.UserOrGroupId));
                }

            }
        }
        */
        
        return setGroupMembers;
    }

    public static List<User> searchLateSurveyTaker(String surveyId) {
        String sharingGroupName='TALGROUP_Everyone';//add by dtt
        
        //Add by DTT  
        Survey__c anonymousSurvey = [SELECT Allow_Anonymous__c,Is_Public__c From Survey__c Where id = :surveyId];
        // if(anonymousSurvey.Allow_Anonymous__c==false)  
        // {
        //     return searchUsers(null);
        // }

        List<String> groupIdList = new List<String>();
        Set<String> setSubmittedTakerId = new Set<String>();
        // query users who have taken the survey
        List<SurveyTaker__c> lstSubmittedTaker = [Select User__c From SurveyTaker__c 
                                                Where Survey__c = :surveyId AND Completed__c = :true];
        for(SurveyTaker__c taker : lstSubmittedTaker)
        {
            setSubmittedTakerId.add(taker.User__c);
        }
        
       
       
       

        // query all survey takers in survey assignment records 
        Set<String> setAssignedTakerIds = new Set<String>();
        //add by DTT
        if(anonymousSurvey.Is_Public__c!='P')
        {
            String theGroupID=[select id,DeveloperName from Group where DeveloperName =:sharingGroupName limit 1].id;
            List <GroupMember> memberLIst=[select id,UserorGroupId from GroupMember where groupid=:theGroupID];
            List<String> GroupIDL=new List<String>();
            for(GroupMember reader:memberLIst)
            {
                GroupIDL.add(reader.UserOrGroupId);
            }
            for(GroupMember reader:[select id,UserorGroupId from GroupMember where groupid in:GroupIDL])
            {
                setAssignedTakerIds.add(reader.UserorGroupId);
            }
        }
        else
        {
            List<Survey_Assignment__c> lstAssignments = [Select User__c, GroupId__c 
                                                        From Survey_Assignment__c where Survey__c = :surveyId 
                                                        AND Assignment_Nature__c = :SurveyAssignmentObjectUtil.NATURE_TAKER];

            for (Survey_Assignment__c assignment : lstAssignments) {
               if (String.IsNotBlank(assignment.User__c)) {
                     setAssignedTakerIds.add(assignment.User__c);
                 } else if (String.IsNotBlank(assignment.GroupId__c)) {
                     // query group members in this public group
                     //setAssignedTakerIds.addAll(searchGroupMembers(assignment.GroupId__c));
                     groupIdList.add(assignment.GroupId__c);
                 }
            }
            setAssignedTakerIds.addAll(searchGroupMembers(groupIdList));
        }
         system.debug('setAssignedTakerIds.size='+setAssignedTakerIds.size());
        

      
        // do subtraction to obtain user ids who have not completed the survey
        Set<String> setLateTakers = new Set<String>();
        for (String takerId : setAssignedTakerIds) {
            if (!setSubmittedTakerId.contains(takerId)) {
                setLateTakers.add(takerId);
            }
        }

        return searchUsers(setLateTakers);
    }

    public static Integer getNumLateTakers(String surveyId) {
         List<User> lstLateTakers = searchLateSurveyTaker(surveyId);
         if (lstLateTakers != null) {
            return lstLateTakers.size();
         }
         return 0;
    } 
}