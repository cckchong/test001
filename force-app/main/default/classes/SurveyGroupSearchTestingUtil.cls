public with sharing class SurveyGroupSearchTestingUtil {
	
  public String        surveyId       {get; set;}
  public List<String>  questionIds    {get; set;}
  public String        surveyTakerId  {get; set;}
  public String        ownerId     {get; set;}
  public String        adminId 	{ get; set; }
  public String        taker1Id { get; set; }
  public String        taker2Id { get; set; }
  public String        taker3Id { get; set; }
  public String        taker4Id { get; set; }
  public String        taker5Id { get; set; }

  public String        group1Id { get; set; }
  public String        group2Id { get; set; }
  public String        group3Id { get; set; }
  public String        group4Id { get; set; }
  public String        group5Id { get; set; }

  public String        ownerSurveyAssignmentId { get; set; }
  public String        adminSurveyAssignmentId { get; set; }
  public String        takerSurveyAssignmentId { get; set; }
  public String        groupSurveyAssignmentId { get; set; }
  public String        surveyTakerAnonymouseId  {get; set;}

  public SurveyGroupSearchTestingUtil() {
	questionIds = new List<String>();
	createTestSurvey();
	createTestSurveyUsers();
	createTestSurveyAssignments();
	createSurveyTaker();
  }
    
  private void createSurveyTaker() {
    SurveyTaker__c st = new SurveyTaker__c();
    st.User__c = taker1Id;
    st.Survey__c = surveyId;
    st.Completed__c = true;

    SurveyTaker__c st2 = new SurveyTaker__c();
    st2.User__c = taker2Id;
    st2.Survey__c = surveyId;
    st2.Completed__c = false;

    List<SurveyTaker__c> lst = new List<SurveyTaker__c>();
    lst.add(st);
    lst.add(st2);
    insert lst;
  }
  
  public void createTestSurvey(){
    Survey__c s = new Survey__c();
    s.Name = 'Testing Survey';
    s.Submit_Response__c = 'empty'; 
    s.Survey_Header__c = 'Testing Survey Header';
    s.Thank_You_Text__c = 'Testing Thank You Text';

    DateTime currentTime = System.now();
    DateTime fromTime = System.DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 9, 0, 0);
    DateTime toTime = fromTime.addMonths(1);
    s.Survey_Start_DateTime__c = fromTime;
    s.Survey_End_DateTime__c = toTime;
    s.Survey_Toggle__c = true;
    s.OwnerId = UserInfo.getUserId();
    s.Allow_Anonymous__c = false;
    insert s;
    surveyId = s.Id;
    ownerId = UserInfo.getUserId();
  }
  
  // added by Connie for testing begins
  public void createTestSurveyUsers() {

    User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
    
    // run as logged in user
    System.runAs (thisUser) {

      Profile p = [select id, name from profile where name = 'TAL FE Standard Platform User'];
      UserRole r = [select id, name from userrole where name = 'TAL GTS Group 1 Staff'];
    
      User surveyAdmin = new User(Alias = 'Admin', Email='newAdmin@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newAdmin@testorg.com');
      insert surveyAdmin;
      adminId = surveyAdmin.id;

      User surveyTaker = new User(Alias = 'TakerA', Email='newTakerA@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingY', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newTakerA@testorg.com');
      insert surveyTaker; 
      taker1Id = surveyTaker.id;

      User surveyTaker2 = new User(Alias = 'TakerB', Email='newTakerB@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingY', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newTakerB@testorg.com');
      insert surveyTaker2; 
      taker2Id = surveyTaker2.id;

      User surveyTaker3 = new User(Alias = 'TakerC', Email='newTakerC@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingY', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newTakerC@testorg.com');
      insert surveyTaker3; 
      taker3Id = surveyTaker3.id;

      User surveyTaker4 = new User(Alias = 'TakerD', Email='newTakerD@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingY', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newTakerD@testorg.com');
      insert surveyTaker4; 
      taker4Id = surveyTaker4.id;

      User surveyTaker5 = new User(Alias = 'TakerE', Email='newTakerE@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingY', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
           TimeZoneSidKey='America/Los_Angeles', UserName='newTakerE@testorg.com');
      insert surveyTaker5; 
      taker5Id = surveyTaker5.id;

      Group newGroup1 = new Group(Name  = '~Test Search Group 1', Type = 'Regular');
      Group newGroup2 = new Group(Name  = '~Test Search Group 2', Type = 'Regular');
      Group newGroup3 = new Group(Name  = '~Test Search Group 3', Type = 'Regular');
      Group newGroup4 = new Group(Name  = '~Test Search Group 4', Type = 'Regular');
      Group newGroup5 = new Group(Name  = '~Test Search Group 5', Type = 'Regular');

      insert newGroup1;
      group1Id = newGroup1.Id;

      insert newGroup2;
	  group2Id = newGroup2.Id;

      insert newGroup3;
      group3Id = newGroup3.Id;

      insert newGroup4;
      group4Id = newGroup4.Id;

      insert newGroup5;
      group5Id = newGroup5.Id;

      System.debug('[SurveyGroupSearchTestingUtil] - group1Id: ' + group1Id);
      System.debug('[SurveyGroupSearchTestingUtil] - group2Id: ' + group2Id);
      System.debug('[SurveyGroupSearchTestingUtil] - group3Id: ' + group3Id);
      System.debug('[SurveyGroupSearchTestingUtil] - group4Id: ' + group4Id);
      System.debug('[SurveyGroupSearchTestingUtil] - group5Id: ' + group5Id);

      List<GroupMember> listGroupMember = new List<GroupMember>();

      // add taker 1, taker 2, group 2 and group 3 to group 1
      GroupMember gm = new GroupMember();
      gm.groupId = group1Id;
      gm.userOrGroupId = taker1Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group1Id;
      gm.userOrGroupId = taker2Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group1Id;
      gm.userOrGroupId = group2Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group1Id;
      gm.userOrGroupId = group3Id;
      listGroupMember.add(gm);

	  // add group 4 and group 5 to group 2
	  gm = new GroupMember();
      gm.groupId = group2Id;
      gm.userOrGroupId = group4Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group2Id;
      gm.userOrGroupId = group5Id;
      listGroupMember.add(gm);
      
      // add taker 1 and taker 3 to group 3
	  gm = new GroupMember();
      gm.groupId = group3Id;
      gm.userOrGroupId = taker1Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group3Id;
      gm.userOrGroupId = taker3Id;
      listGroupMember.add(gm);

      // add taker 2 and taker 4 to group 4
      gm = new GroupMember();
      gm.groupId = group4Id;
      gm.userOrGroupId = taker2Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group4Id;
      gm.userOrGroupId = taker4Id;
      listGroupMember.add(gm);

      // add taker 1 and taker 5 to group 5
      gm = new GroupMember();
      gm.groupId = group5Id;
      gm.userOrGroupId = taker1Id;
      listGroupMember.add(gm);

      gm = new GroupMember();
      gm.groupId = group5Id;
      gm.userOrGroupId = taker5Id;
      listGroupMember.add(gm);

      insert listGroupMember;
    }
  }

  public void createTestSurveyAssignments() {

      Survey_Assignment__c sa = new Survey_Assignment__c();
      sa.User__c = ownerId;
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
      insert sa;
      ownerSurveyAssignmentId = sa.Id;
    
      sa = new Survey_Assignment__c();
      sa.User__c = adminId;
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
      insert sa;
      adminSurveyAssignmentId = sa.Id;

      List<Survey_Assignment__c> lstAssignments = new List<Survey_Assignment__c>();
      sa = new Survey_Assignment__c();
      sa.User__c = taker1Id;
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      lstAssignments.add(sa);

      sa = new Survey_Assignment__c();
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      sa.GroupId__c = group1Id;
      lstAssignments.add(sa);

  	  insert lstAssignments;
  }
  // end
}