global without sharing class SurveyAssignmentController {

    private ApexPages.StandardController stdControl;

    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveyAssignments { get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList1{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList2{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList3{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList4{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList5{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList6{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList7{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList8{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList9{ get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> selectedSurveySubList10{ get; set; }


    Public Map<id, Boolean> selectedItem { get; set; }
    public String surveyId  { get; set; }
    public String mode { get; set; }
    public String assignmentNature { get; set; }
    public String surveyOwnerId { get; set; }
    public String userId { get; set; }
    public String userName { get; set; }
    private String access { get; set; }
    public String theOwnerName;//ADD by DTT Support Team
    public Integer maxAdmin;//ADD by DTT Support Team

    public SurveyAssignmentController(ApexPages.StandardController stdController) {
          maxAdmin=10;
          try {
             theOwnerName='';
             selectedItem = new Map<id, Boolean> ();
             this.stdControl = stdController;
             surveyId = ApexPages.currentPage().getParameters().get('surveyId');
             mode = ApexPages.currentPage().getParameters().get('mode');
             assignmentNature = '';
             if (mode != null && mode.equals(SurveyAssignmentObjectUtil.ADMINISTRATOR)) { 
                assignmentNature = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
             } else if (mode != null && mode.equals(SurveyAssignmentObjectUtil.TAKER)) {
                assignmentNature = SurveyAssignmentObjectUtil.NATURE_TAKER;
             }  
             access = ApexPages.currentPage().getParameters().get('access');

             System.debug('Survey Id: ' + surveyId + ', mode: ' + mode + ', access: ' + access);
             if (surveyId != null) {
                
                List<Survey__c> listSurvey = [Select OwnerId,owner.name from Survey__c where id = :surveyId ];
                if (listSurvey != null && listSurvey.size() > 0) {
                    surveyOwnerId = listSurvey.get(0).OwnerId;
                    // theOwnerName=listSurvey.get(0).owner.name;//ADD by DTT Support Team
                }
             }
            
             System.debug('SurveyOwnerId: ' + surveyOwnerId);

             userId = UserInfo.getUserId();
             userName = UserInfo.getUserName();
             resultSetSize = 100;
             System.debug('userId: ' + userId + ', userName: ' + userName);

             if (access == SurveyAssignmentObjectUtil.MODE_VIEW) {
                 loadSelectedSurveyAssignments();
             }

             if (access == SurveyAssignmentObjectUtil.MODE_ADD) {
                inputUser = '';
                inputPublicGroup = '';
                
                // query group when assign taker
             
                    queryGroups();
                    queryUsers();
             }
             
             
          } catch (Exception ex) {
             System.debug(ex.getMessage());
          }
    }

    public void loadSelectedSurveyAssignments() {
        selectedSurveyAssignments = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, userId, assignmentNature);
        Integer counter=1;
        Integer theLimist=1000;
        Integer theLimist2=theLimist*2;
        Integer theLimist3=theLimist*3;
        Integer theLimist4=theLimist*4;
        Integer theLimist5=theLimist*5;
        Integer theLimist6=theLimist*6;
        Integer theLimist7=theLimist*7;
        Integer theLimist8=theLimist*8;
        Integer theLimist9=theLimist*9;
        Integer theLimist10=theLimist*10;

       
        selectedSurveySubList1=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList2=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList3=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList4=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList5=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList6=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList7=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList8=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList9=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
        selectedSurveySubList10=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();

        for(SurveyAssignmentObjectUtil.SurveyAssignmentResult reader : selectedSurveyAssignments){
            selectedItem.put(reader.id, false);

            if(counter<=theLimist)
            {
                selectedSurveySubList1.add(reader);
            }
            else if(counter>theLimist&&counter<=theLimist2)
            {
                selectedSurveySubList2.add(reader);
            }
            else if(counter>theLimist2&&counter<=theLimist3)
            {
                selectedSurveySubList3.add(reader);
            }
            else if(counter>theLimist3&&counter<=theLimist4)
            {
                selectedSurveySubList4.add(reader);
            }
            else if(counter>theLimist4&&counter<=theLimist5)
            {
                selectedSurveySubList5.add(reader);
            }
            else if(counter>theLimist5&&counter<=theLimist6)
            {
                selectedSurveySubList6.add(reader);
            }
            counter++;
        }
    }

    public String selectedSurveyAssignmentId { get; set; }
    public PageReference deleteSurveyAssignment() {
        SurveyAssignmentObjectUtil.deleteSurveyAssignment(selectedSurveyAssignmentId);   
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteAllSurveyAssignment() {        
        List<Survey_Assignment__c> SAList = new List<Survey_Assignment__c>();
        List<String> assignList =  new List<String>();
        PageReference pageRef = null;
        for(SurveyAssignmentObjectUtil.SurveyAssignmentResult reader : selectedSurveyAssignments){
            if(selectedItem.get(reader.id)){
                SAList.add(new Survey_Assignment__c(id = reader.id));
            }
        }
        if(!SAList.isempty()){
            delete SAList;
        }
        //SurveyAssignmentObjectUtil.deleteSurveyAssignment(selectedSurveyAssignmentId);   
        pageRef = new PageReference(ApexPages.currentPage().getUrl());
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference back() {
        PageReference pr = new PageReference('/apex/SurveyManagerPage');
        pr.getParameters().put('id', surveyId);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference showAddSharing() {

          PageReference pr;  
         if (mode == SurveyAssignmentObjectUtil.ADMINISTRATOR) {
          pr = new PageReference('/apex/SurveyAssignmentCreateAdminPage');
        } else if (mode == SurveyAssignmentObjectUtil.TAKER) {
          pr = new PageReference('/apex/SurveyAssignmentCreatePage');
        }
        Map<String, String> params = pr.getParameters();
        params.put('surveyId', surveyId);
        params.put('mode', mode);
        params.put('access', SurveyAssignmentObjectUtil.MODE_ADD);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference checkAccessRight() {

          SurveyCheckAccessUtil accessUtil = new SurveyCheckAccessUtil(userId, surveyId);
          if (accessUtil.canManageSurvey() || (surveyId==null || surveyId=='')) {//ADD by DTT Support team
          return null;
          } else {
            userName = UserInfo.getUserName();  
            System.debug('User name: ' + userName);
            PageReference pr = new PageReference('/apex/SurveyErrorPage');
            pr.getParameters().put('error', 'User(' + userName + ') does not have permission to manage this survey(Id: ' + surveyId 
                                      +'). Please contact survey owner for assistance.');
            pr.setRedirect(true);
            return pr;
          }                               
    }

    public Integer resultSetSize { get; set; }
    public String inputUser { get; set; }
    // public Group must begin with ~
    public String inputPublicGroup { get; set; }

    private Map<String, String> userSelectedMap = new Map<String, String>();
    private Map<String, String> existinguserSelectedMap = new Map<String, String>();
    private Map<String, String> userUnselectedMap = new Map<String, String>();
    private Map<String, String> groupSelectedMap = new Map<String, String>();
    private Map<String, String> existinggroupSelectedMap = new Map<String, String>();
    private Map<String, String> groupUnselectedMap = new Map<String, String>();

    public void queryUsers() {
        Integer counter = 1;
        Integer selectcounter = 1;
        Integer Rowlimit = 950;
        String likeUserName = '%' + inputUser + '%';
        System.debug('inputUser: ' + inputUser + ', likeUserName: ' + likeUserName);
        userUnselectedMap = new Map<String, String>();
        if(userSelectedMap==null || userSelectedMap.isEmpty())
        {
                    userSelectedMap = new Map<String, String>();

        }
        List<user> readerList= [select id, Name_Display__c, Name, 
                           (Select id, user__c, user__r.Name_Display__c, user__r.Name,Assignment_Nature__c from Survey_Assignments_User__r where Survey__c = :surveyId AND Assignment_Nature__c = :assignmentNature) /*Add By DTT Support Team 2016-11-01*/
                           from user 
                           where isactive = true 
                           and (profile.UserLicense.name='Salesforce' or profile.UserLicense.name='Salesforce Platform')//Add by DTT Team
                           and Id!=:surveyOwnerId//Add by DTT Team
                           and FederationIdentifier != null//Add by DTT Team
                           and (Name_Display__c like :likeUserName or Name like :likeUserName )                          
                           order by Name_Display__c 
                          ];
            //*
        system.debug(userUnselectedMap);//DTT
        system.debug(userSelectedMap);//DTT
        //system.debug('here'+readerList);//DTT
        for(user reader:readerList)
         {
            if(selectcounter <= Rowlimit && !reader.Survey_Assignments_User__r.isEmpty()&& !userSelectedMap.containsKey(reader.Survey_Assignments_User__r[0].user__c) && reader.Survey_Assignments_User__r[0].Assignment_Nature__c ==assignmentNature){
                system.debug(reader.Survey_Assignments_User__r[0].user__c);

                if(!String.IsBlank(reader.Survey_Assignments_User__r[0].user__r.Name_Display__c)){
                    userSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name_Display__c);
                    existinguserSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name_Display__c); /*Comment by DTT support team*/
                }
                else{
                    userSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name);
                    existinguserSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name);
                }
                selectcounter ++;   
                // counter ++;//add by DTT support Team
            }
            //*/
        }
        counter=selectcounter;
        system.debug(userSelectedMap);//DTT
        system.debug(userUnselectedMap);//DTT

        for(user reader:readerList)
         {
            system.debug(reader.Survey_Assignments_User__r);
            if(reader.Survey_Assignments_User__r.isEmpty() && counter <= Rowlimit &&!userSelectedMap.containsKey(reader.id)){                
                if(!String.IsBlank(reader.Name_Display__c)){
                    userUnselectedMap.put(reader.id, reader.Name_Display__c);
                }
                else{
                    userUnselectedMap.put(reader.id, reader.Name);
                }
                counter ++;
            }

         }
         system.debug(userUnselectedMap);//DTT

        //queryCommon('User', likeUserName, userUnselectedMap, 'users', 'user');                         
    }
    /*
    Add by DTT Support, qurry all the admin
    */
    // public void queryAdmins() {

    //     Integer counter = 1;
    //     Integer selectcounter = 1;
    //     Integer Rowlimit = 950;
    //     String likeUserName = '%' + inputUser + '%';
    //     System.debug('inputUser: ' + inputUser + ', likeUserName: ' + likeUserName);
    //     userUnselectedMap = new Map<String, String>();
    //     if(userSelectedMap==null || userSelectedMap.isEmpty())
    //     {
    //                 userSelectedMap = new Map<String, String>();

    //     }
    //     List<user> readerList= [select id, Name_Display__c, Name, 
    //                        (Select id, user__c, user__r.Name_Display__c, user__r.Name,Assignment_Nature__c from Survey_Assignments_User__r where Survey__c = :surveyId ) /*Add By DTT Support Team 2016-11-01*/
    //                        from user 
    //                        where isactive = true 
    //                        and profile.UserLicense.name='Salesforce'//Add by DTT Team
    //                        and Id!=:surveyOwnerId//Add by DTT Team
    //                        and (Name_Display__c like :likeUserName or Name like :likeUserName )                          
    //                        order by Name_Display__c 
    //                       ];
    //         //*
    //     for(user reader:readerList)
    //      {
    //         // system.debug(reader.Survey_Assignments_User__r[0].Assignment_Nature__c);
    //         if(selectcounter <= Rowlimit && !reader.Survey_Assignments_User__r.isEmpty()&& !userSelectedMap.containsKey(reader.Survey_Assignments_User__r[0].user__c) && reader.Survey_Assignments_User__r[0].Assignment_Nature__c ==assignmentNature){
    //             // system.debug(reader.Survey_Assignments_User__r[0].user__c);

    //             if(!String.IsBlank(reader.Survey_Assignments_User__r[0].user__r.Name_Display__c)){
    //                 userSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name_Display__c);
    //                 existinguserSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name_Display__c); /*Comment by DTT support team*/
    //             }
    //             else{
    //                 userSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name);
    //                 existinguserSelectedMap.put(reader.Survey_Assignments_User__r[0].user__c, reader.Survey_Assignments_User__r[0].user__r.Name);
    //             }
    //             selectcounter ++;   
    //             // counter ++;//add by DTT support Team
    //         }
    //         //*/
    //     }
    //     counter=selectcounter;
    //     for(user reader:readerList)
    //      {
    //         if(reader.Survey_Assignments_User__r.isEmpty() && counter <= Rowlimit &&!userSelectedMap.containsKey(reader.id)){                
    //             if(!String.IsBlank(reader.Name_Display__c)){
    //                 userUnselectedMap.put(reader.id, reader.Name_Display__c);
    //             }
    //             else{
    //                 userUnselectedMap.put(reader.id, reader.Name);
    //             }
    //             counter ++;
    //         }
 
    //      }

    //     //queryCommon('User', likeUserName, userUnselectedMap, 'users', 'user');                         
    // }
    /*
    End
    */

    public void queryGroups() {
        
        Map<String, Survey_Assignment__c > surveyAssignmentMap = new Map<String, Survey_Assignment__c >();
        String likePublicGroup = '%' + inputPublicGroup + '%';
        System.debug('inputPublicGroup: ' + inputPublicGroup + ', likePublicGroup: ' + likePublicGroup);
        groupUnselectedMap = new Map<String, String>();
        if(groupSelectedMap==null || groupSelectedMap.isEmpty())
        {
            groupSelectedMap = new Map<String, String>();
        }
        Integer counter = 1;
        Integer selectcounter = 1;
        Integer Rowlimit = 950;
        
        for(Survey_Assignment__c reader : [select id, GroupId__c
                                           from Survey_Assignment__c 
                                           where Survey__c = :surveyId]){
            surveyAssignmentMap.put(reader.GroupId__c, reader);        
        }

        List<group> GroupList=[select id, Name from Group 
                            where Name like :likePublicGroup
                            and type='Regular'//add by DTT
                            //and id not in :surveyAssignmentList
                           ];
        for(Group reader :GroupList){

            if(surveyAssignmentMap.containsKey(reader.id) && selectcounter <= Rowlimit && !groupSelectedMap.containsKey(reader.id)){/*change by DTT Support Team*/       
                groupSelectedMap.put(reader.id, reader.Name);
                existinggroupSelectedMap.put(reader.id, reader.Name);
                selectcounter ++;
            }
          
            //*
           
            //*/
        }
        counter=selectcounter;
        for(Group reader :GroupList){
          if(!surveyAssignmentMap.containsKey(reader.id) && counter < Rowlimit && !groupSelectedMap.containsKey(reader.id)){
                groupUnselectedMap.put(reader.id, reader.Name);
                counter ++;
            }
             
        }


        //queryCommon('Group', likePublicGroup, groupUnselectedMap, 'groups', 'group');                         
    }

    private void queryCommon(String objectName, String searchValue, Map<String, String> recordMap, 
        String tooManyObjects, String noObject) {

        String countSql = 'Select COUNT(id) numEntries From ' + objectName + ' Where Name like :searchValue ';
        if (objectName.equals('User')) {
            countSql += ' and IsActive = true ';
        }
        List<AggregateResult> aggregResults = (List<AggregateResult>)Database.query(countSql);
        if (aggregResults != null && aggregResults.size() > 0) {
            Integer numEntries = Integer.valueOf(aggregResults[0].get('numEntries'));
            if (numEntries > resultSetSize) {
                // show warning message
                ApexPages.Message tooManyResultsMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Too many ' + tooManyObjects + ' found. Only return the first ' 
                            + resultSetSize + ' results. Please refine search criteria.');
                ApexPages.addMessage(tooManyResultsMsg);
            } else if (numEntries == 0) {
                ApexPages.Message zeroResultsMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'No ' + noObject + ' is found. Please refine search criteria.');                
                ApexPages.addMessage(zeroResultsMsg);
            }
        } 

        String query = 'Select Id, Name ';
        if (objectName.equals('User')) {
            query += ', Name_Display__c ';
        }
        
        query += 'From ' + objectName + ' Where Name like :searchValue '; 
        if (objectName.equals('User')) {
            query += ' and IsActive = true ';
        }
        query += ' limit :resultSetSize';
        List<SObject> groupQueryList = Database.query(query);
        for (SObject u : groupQueryList) {
        
            if (objectName.equals('User')) {
                if(String.isBlank((String)u.get('Name_Display__c'))){
                    recordMap.put((String)u.get('Id'), (String)u.get('Name'));
                }
                else{
                    recordMap.put((String)u.get('Id'), (String)u.get('Name_Display__c'));
                }
            }
            else{
                recordMap.put((String)u.get('Id'), (String)u.get('Name'));
            }
            
            System.debug('Id: ' + (String) u.get('Id') + ', name: ' + (String) u.get('Name'));
        }                           
    }

    // Create the select options for the two select lists on the page
    public List<SelectOption> getSelectedUserOptions() {
        return selectOptionsFromMap(userSelectedMap);
    }

    public List<SelectOption> getUnselectedUserOptions() {
        return selectOptionsFromMap(userUnselectedMap);
    }

    // Create the select options for the two select lists on the page
    public List<SelectOption> getSelectedGroupOptions() {
        // return null;//vic test
        return selectOptionsFromMap(groupSelectedMap);
    }

    public List<SelectOption> getUnselectedGroupOptions() {
        return selectOptionsFromMap(groupUnselectedMap);
    }

    private List<SelectOption> selectOptionsFromMap(Map<String, String> mapOptions) {

        List<SelectOption> options = new List<SelectOption>();
        for (String key : mapOptions.keySet()) {
            //System.debug('********************' + key +'********************'+ mapOptions.get(key));
            options.add(new SelectOption(key, mapOptions.get(key)));
        }
        doSort(options);
        return options;
    }

    // sort selection option by label
    private void doSort(List<Selectoption> opts) {
        
        Map<String, SelectOption> mapping = new Map<String, SelectOption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (Selectoption opt : opts) {
            // Done this cryptic to save scriptlines, if this loop executes 10000 times
            // it would every script statement would add 1, so 3 would lead to 30000.
            mapping.put((opt.getLabel() + suffix++), // Key using Label + Suffix Counter  
                         opt);   
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
        sortKeys.sort();
        // clear the original collection to rebuilt it
        opts.clear();
        
        for (String key : sortKeys) {
            opts.add(mapping.get(key));
        }
    }

    public transient List<String> selectedUsers   { get; set; }
    public transient List<String> unselectedUsers { get; set; }
    public transient List<String> selectedPublicGroups   { get; set; }
    public transient List<String> unselectedPublicGroups { get; set; }

    public void doAddUser() {
        //Add by DTT Support Team
        if(mode.equals(SurveyAssignmentObjectUtil.ADMINISTRATOR) && selectedUsers !=null && userSelectedMap!=null && selectedUsers.size()+userSelectedMap.size()>maxAdmin)
        {
             ApexPages.Message msg1 = new Apexpages.Message(ApexPages.Severity.Error,'You can only select 10 admins');
             ApexPages.addmessage(msg1);
             return;
        }
       
        //Add by DTT Support Team
        moveFields(selectedUsers, userUnselectedMap, userSelectedMap);
    }

    public void doRemoveUser() {
        moveFields(unselectedUsers, userSelectedMap, userUnselectedMap);
    }

    public void doAddGroup() {
        moveFields(selectedPublicGroups, groupUnselectedMap, groupSelectedMap);
    }

    public void doRemoveGroup() {
        moveFields(unselectedPublicGroups, groupSelectedMap, groupUnselectedMap);
    }

    // move unselected options to selected options
    private void moveFields(List<String> items, Map<String, String> fromMap, Map<String, String> ToMap) {
        /*Add by DTT Support Team*/
        Integer counter;
        counter=items.size()+ToMap.size();
        // system.assert(false,counter);
        if(counter>990)
          {
  
              ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'You can not add more than 1000 users/groups');
              ApexPages.addmessage(msg);
              return;
              
          }
        /*Add by DTT Support Team End*/
        
        for (String objectId : items) {
            if (fromMap.containsKey(objectId)) {
                ToMap.put(objectId, fromMap.get(objectId));
                fromMap.remove(objectId);
            }   
        }

      
    }

    public PageReference backToAssignmentListing() {

        PageReference pr = new PageReference('/apex/SurveyAssignmentDisplayPage');
        Map<String, String> params = pr.getParameters();
        params.put('surveyId', surveyId);
        params.put('mode', mode);
        params.put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
        pr.setRedirect(true);
        return pr;
    }

    private List<Survey_Assignment__c> createUserSurveyAssignmentList(Set<String> setExistIds, String surveyId, String nature) {

        List<Survey_Assignment__c> listSurveyAssignment = new List<Survey_Assignment__c>();
        // system.debug('userSelectedMap'+userSelectedMap);
        // system.debug('setExistIds'+setExistIds);

        for (String userId : userSelectedMap.keySet()) {
            System.debug('User selected map: ' + userId);
            if (!setExistIds.contains(userId)) {
                Survey_Assignment__c sa = new Survey_Assignment__c();
                sa.Survey__c = surveyId;
                sa.User__c = userId;
                sa.Assignment_Nature__c = nature;
                System.debug('User survey assignment: ' + sa);
                listSurveyAssignment.add(sa);
            }
        }
        return listSurveyAssignment;
    }

    private List<Survey_Assignment__c> createGroupSurveyAssignmentList(Set<String> setExistIds, 
        String surveyId, String nature) {

        List<Survey_Assignment__c> listSurveyAssignment = new List<Survey_Assignment__c>();
        for (String groupId : groupSelectedMap.keySet()) {
            System.debug('Group selected map: ' + groupId);
            if (!setExistIds.contains(groupId)) {
                Survey_Assignment__c sa = new Survey_Assignment__c();
                sa.Survey__c = surveyId;
                sa.GroupId__c = groupId;
                sa.Assignment_Nature__c = nature;
                System.debug('Group survey assignment: ' + sa);
                listSurveyAssignment.add(sa);
            }
        }
        return listSurveyAssignment;
    }

    private Boolean persistSurveyAssignment(List<Survey_Assignment__c> listSurveyAssignment) {

        boolean noError = true;
        if (listSurveyAssignment.size() > 0) {
            List<Database.SaveResult> results = Database.insert(listSurveyAssignment, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    noError = false;
                    for (Database.Error err : result.getErrors()) {
                        System.debug('Insert Survey Assignment error message: ' + err.getMessage());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, err.getMessage()));
                    }
                }
            }
        }
        return noError;
    }
    //public String tmp {get; set;}
    public PageReference saveAssignment() {
        String nature  = '';
        if (mode == SurveyAssignmentObjectUtil.ADMINISTRATOR) {
            nature = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
        } else if (mode == SurveyAssignmentObjectUtil.TAKER) {
            nature = SurveyAssignmentObjectUtil.NATURE_TAKER;
        }
        
         /*Comment by DTT*/
        List<Survey_Assignment__c> listExisting = new List<Survey_Assignment__c>();
        for(String reader : userSelectedMap.keySet()){
            if(existinguserSelectedMap.containskey(reader)){ //change by DTT support team
                listExisting.add(new Survey_Assignment__c(User__c = reader, Assignment_Nature__c = nature));
            }
        }
        for(String reader : groupSelectedMap.keySet()){
            if(existinggroupSelectedMap.containskey(reader)){//Change by DTT support team
                listExisting.add(new Survey_Assignment__c(GroupId__c = reader, Assignment_Nature__c = nature));
            }
        } 
        
        /*Add by DTT*/
        // if (mode == SurveyAssignmentObjectUtil.ADMINISTRATOR && listExisting.size()>15) {
        //     ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'You can only add 10 Admins');
        //     ApexPages.addmessage(msg);
        //     return null;
        // }
        /*Add by DTT*/


        system.debug('check if it have run here');
        /*
        List<Survey_Assignment__c> listExisting = 
            [Select Id, User__c, GroupId__c 
             FROM Survey_Assignment__c 
             where Survey__c = :surveyId 
             And Assignment_Nature__c = :nature];
        //*/
        Set<String> setUser = new Set<String>();
        Set<String> setGroupId = new Set<String>();   
        system.debug('listExisting'+listExisting);  
        for (Survey_Assignment__c sa : listExisting) {
            if (String.IsNotBlank(sa.User__c)) {
                setUser.add(sa.User__c);
                System.debug('Add ' + sa.User__c + ' into user set.');
            }
            if (String.IsNotBlank(sa.GroupId__c)) {
                setGroupId.add(sa.GroupId__c);
                System.debug('Add ' + sa.GroupId__c + ' into group set.');
            }
        }
        //tmp = String.valueof(setUser);
        //return null;
        // save 


        delete [Select id, user__c, user__r.Name_Display__c, user__r.Name from Survey_Assignment__c where 
                                        Survey__c =:surveyId and user__r.id!=:surveyOwnerId 
                                        AND user__c not in:userSelectedMap.keySet()
                                        AND GroupId__c not in:groupSelectedMap.keySet()
                                        AND Assignment_Nature__c =:assignmentNature
                                        ];
             


        




        List<Survey_Assignment__c> listUser = createUserSurveyAssignmentList(setUser, surveyId, nature);
        List<Survey_Assignment__c> listGroup = createGroupSurveyAssignmentList(setGroupId, surveyId, nature);        
        boolean noError = true;
        noError = noError && persistSurveyAssignment(listUser);
        noError = noError && persistSurveyAssignment(listGroup);
        if (!noError) {
            return null;
        } else {
            PageReference pr = new PageReference('/apex/SurveyAssignmentDisplayPage');
            Map<String, String> params = pr.getParameters();
            params.put('surveyId', surveyId);
            params.put('mode', mode);
            params.put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
            pr.setRedirect(true);
            return pr;
        }
    }
}