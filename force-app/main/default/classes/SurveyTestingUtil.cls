public with sharing class SurveyTestingUtil {
  public String        surveyId       {get; set;}
  public List<String>  questionIds    {get; set;}
  //public Map<String, List<String>>  questionIds    {get; set;}
  public String          contactId      {get; set;}
  public String        surveyTakerId  {get; set;}
  public String        contactId2     {get; set;}
  public String        ownerId     {get; set;}
  public String        newOwnerId { get; set; }
  public String        adminId { get; set; }
  public String        admin2Id { get; set; }
  public String        taker1Id { get; set; }
  public String        taker2Id { get; set; }
  public String        taker3Id { get; set; }
  public String        taker4Id { get; set; }
  public String        taker5Id { get; set; }
  public String        unAuthUserId { get; set; }
  public String        groupId { get; set; }
  public String        group2Id { get; set; }
  public String        ownerSurveyAssignmentId { get; set; }
  public String        adminSurveyAssignmentId { get; set; }
  public String        takerSurveyAssignmentId { get; set; }
  public String        groupSurveyAssignmentId { get; set; }
  public String        surveyTakerAnonymouseId  {get; set;}
  public String        anonymouseSurveyId  {get; set;}
  public List<String>  anonymousQuestionIds    {get; set;}



  public SurveyTestingUtil(){
    questionIds = new List<String>();
    // added by Connie
    anonymousQuestionIds = new List<String>();
    // end
    createTestSurvey();
    createTestQuestions();
    createTestContact();
    createSurveyTaker();
    createTestResponses();
    // added by Connie
    createTestSurveyUsers();
    createTestSurveyAssignments();
    createTestCustomSettings();
    // end 
  }
  
  private static TestMethod void testConstructor(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    System.assert(tu.surveyId != null);
  }
  
  private void createSurveyTaker(){
    SurveyTaker__c st = new SurveyTaker__c();
    st.Contact__c = contactId;
    st.Survey__c = surveyId;
    //st.Taken__c = 'false';
    st.Completed__c = true;
    insert st;
    surveyTakerId = st.Id;

    SurveyTaker__c st2 = new SurveyTaker__c();
    st2.Contact__c = contactId;
    st2.Survey__c = anonymouseSurveyId;
    //st2.Taken__c = 'false';
    st2.Completed__c = true;
    insert st2;
    surveyTakerAnonymouseId = st2.Id;
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

    Survey__c s1 = new Survey__c();
    s1.Name = 'Testing Survey 1';
    s1.Submit_Response__c = 'empty'; 
    s1.Survey_Header__c = 'Testing Survey Header 1';
    s1.Thank_You_Text__c = 'Testing Thank You Text 1';

    // added by Connie
    currentTime = System.now();
    fromTime = System.DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 9, 0, 0);
    toTime = fromTime.addMonths(1);
    s1.Survey_Start_DateTime__c = fromTime;
    s1.Survey_End_DateTime__c = toTime;
    s1.Survey_Toggle__c = true;
    s1.OwnerId = UserInfo.getUserId();
    s1.Allow_Anonymous__c = true;
    insert s1;
    anonymouseSurveyId = s1.Id;
    // end
  }
  
  public void createTestQuestions(){
 //   questionIds.add(createQuestion(0));
 //   questionIds.add(createQuestion(1));
 //   questionIds.add(createQuestion(2));
 //   questionIds.add(createQuestion(3));

    questionIds.add(createQuestion(0, surveyId));
    questionIds.add(createQuestion(1, surveyId));
    questionIds.add(createQuestion(2, surveyId));
    questionIds.add(createQuestion(3, surveyId));

    anonymousQuestionIds.add(createQuestion(0, anonymouseSurveyId));
    anonymousQuestionIds.add(createQuestion(1, anonymouseSurveyId));
    anonymousQuestionIds.add(createQuestion(2, anonymouseSurveyId));
    anonymousQuestionIds.add(createQuestion(3, anonymouseSurveyId));
  }
  
  // modify by Connie
//  private String createQuestion(Integer i){
  private String createQuestion(Integer i, String surveyId){

    Survey_Question__c q = new Survey_Question__c();
    q.Name = 'Testing Question';
    q.Survey__c = surveyId;
    q.Type__c = getType(i);
    q.Choices__c = getChoices();
    q.Question__c = 'Testing Question question';
    q.OrderNumber__c = i;
    q.Required__c = true;
    insert q;
    return q.id;        
  }
  
  
  private void createTestContact() {
    Contact c = new Contact();
    c.LastName = 'Doe';
    c.FirstName = 'John';
    c.Email = 'surveyAppUser@hotmail.com';
    insert c;
    contactId = c.Id;   
    
    Contact c2 = new Contact();
    c2.LastName = 'Doe2';
    c2.FirstName = 'John2';
    c2.Email = 'surveyAppUser2@hotmail.com';
    insert c2;
    contactId2 = c2.Id;   
  }
  
  private String createTestResponses() {
    SurveyQuestionResponse__c r = new SurveyQuestionResponse__c();
    r.Response__c = 'two';
    Survey_Question__c sq = [Select id from Survey_Question__c where id=: questionIds[1] limit 1];
    r.Survey_Question__c = sq.id;
    r.SurveyTaker__c = surveyTakerId;
    r.Completed__c = true;
    insert r;

    SurveyQuestionResponse__c r2 = new SurveyQuestionResponse__c();
    r2.Response__c = 'three';
    Survey_Question__c sq2 = [Select id from Survey_Question__c where id=: anonymousQuestionIds[1] limit 1];
    r2.Survey_Question__c = sq2.id;
    r2.SurveyTaker__c = surveyTakerAnonymouseId;
    r2.Completed__c = true;
    insert r2;
    return 'true';
  }
  
  private String getType(Integer i){
    if      (i==1)
     return 'Multi-Select--Vertical';
    else if (i==2)
     return 'Single Select--Vertical';
    else if (i==3)
     return 'Free Text';
    else
     return 'Single Select--Horizontal';
  }

  private String getChoices(){
    return 'one\ntwo\nthree\n';
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
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com1',
           TimeZoneSidKey='America/Los_Angeles', UserName='newAdmin@testorg.com');
      insert surveyAdmin;
      adminId = surveyAdmin.id;

      User surveyAdmin2 = new User(Alias = 'Admin2', Email='newAdmin2@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com2',
           TimeZoneSidKey='America/Los_Angeles', UserName='newAdmin2@testorg.com');
      insert surveyAdmin2;
      admin2Id = surveyAdmin2.id;

      User surveyTaker = new User(Alias = 'Taker1', Email='newTaker1@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com3',
           TimeZoneSidKey='America/Los_Angeles', UserName='newTaker1@testorg.com');
      insert surveyTaker; 
      taker1Id = surveyTaker.id;

      User surveyTaker2 = new User(Alias = 'Taker2', Email='newTaker2@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com4',
           TimeZoneSidKey='America/Los_Angeles', UserName='newTaker2@testorg.com');
      insert surveyTaker2; 
      taker2Id = surveyTaker2.id;

      User surveyTaker3 = new User(Alias = 'Taker3', Email='newTaker3@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com5',
           TimeZoneSidKey='America/Los_Angeles', UserName='newTaker3@testorg.com');
      insert surveyTaker3; 
      taker3Id = surveyTaker3.id;

      User surveyTaker4 = new User(Alias = 'Taker4', Email='newTaker4@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com6',
           TimeZoneSidKey='America/Los_Angeles', UserName='newTaker4@testorg.com');
      insert surveyTaker4; 
      taker4Id = surveyTaker4.id;

      User surveyTaker5 = new User(Alias = 'Taker5', Email='newTaker5@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com7',
           TimeZoneSidKey='America/Los_Angeles', UserName='newTaker5@testorg.com');
      insert surveyTaker5; 
      taker5Id = surveyTaker5.id;

      User unAuthorizedUser = new User(Alias = 'Unauth', Email='unauthorizedUser@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='1',
           TimeZoneSidKey='America/Los_Angeles', UserName='unauthorizedUser@testorg.com');
      insert unAuthorizedUser;
      unAuthUserId = unAuthorizedUser.Id;

      User newOwner = new User(Alias = 'NewOwner', Email='newowner@testorg.com', 
           EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
           LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,FederationIdentifier='newAdmin@testorg.com8',
           TimeZoneSidKey='America/Los_Angeles', UserName='newowner@testorg.com');
      insert newOwner;
      newOwnerId = newOwner.Id;

      Group newGroup = new Group(Name  = '~Test Public Group', Type = 'Regular');
      insert newGroup;
      groupId = newGroup.Id;

      List<GroupMember> listGroupMember = new List<GroupMember>();
      // add survey taker 2 and survey taker 3 into group 
      GroupMember gm1 = new GroupMember();
      gm1.groupId = groupId;
      gm1.userOrGroupId = taker2Id;
      listGroupMember.add(gm1);

      GroupMember gm2 = new GroupMember();
      gm2.groupId = groupId;
      gm2.userOrGroupId = taker3Id;
      listGroupMember.add(gm2);
      
      Group newGroup2 = new Group(Name  = '~Test Public Group 2', Type = 'Regular');
      insert newGroup2;
      group2Id = newGroup2.Id;

      // add survey taker 4 into group 2 
      GroupMember gm3 = new GroupMember();
      gm3.groupId = group2Id;
      gm3.userOrGroupId = taker4Id;
      listGroupMember.add(gm3);
      insert listGroupMember;

      // create 55 admin user accounts to test SurveyAdminListHelper
      List<User> listAdminUser = new List<User>();
      for (Integer i = 3; i < 58; i++) {
        User adminUser = new User(Alias = 'Ado' + i, Email='newAdmin' + i + '@testorg.com', 
             EmailEncodingKey='UTF-8', LastName='TestingX', LanguageLocaleKey='en_US', 
             LocaleSidKey='en_US', ProfileId = p.Id, userroleid = r.Id,
             TimeZoneSidKey='America/Los_Angeles', UserName='newAdmin' + i + '@testorg.com');
        listAdminUser.add(adminUser);
      }
      insert listAdminUser;
    }
  }

  public void createTestCustomSettings() {  

    SurveySettings__c settings = null;
    for (SurveySettings__c  reader : [select id from SurveySettings__c where name = 'global'] ){
        settings = reader;
    }
    if(settings == null){
        settings = new SurveySettings__c(ReminderEmailThreshold__c = 100, name='global');
        insert settings;
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

      sa = new Survey_Assignment__c();
      sa.User__c = taker1Id;
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      insert sa;
      takerSurveyAssignmentId = sa.Id;

      sa = new Survey_Assignment__c();
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      sa.GroupId__c = groupId;
      insert sa; 
      
      sa = new Survey_Assignment__c();
      sa.Survey__c = surveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      sa.GroupId__c = group2Id;
      insert sa; 
      groupSurveyAssignmentId = sa.Id;

      List<Survey_Assignment__c> listAnonymousAssignment = new List<Survey_Assignment__c>();
      sa = new Survey_Assignment__c();
      sa.User__c = ownerId;
      sa.Survey__c = anonymouseSurveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
      listAnonymousAssignment.add(sa);
    
      sa = new Survey_Assignment__c();
      sa.User__c = adminId;
      sa.Survey__c = anonymouseSurveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR;
      listAnonymousAssignment.add(sa);

      sa = new Survey_Assignment__c();
      sa.User__c = taker1Id;
      sa.Survey__c = anonymouseSurveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      listAnonymousAssignment.add(sa);

      sa = new Survey_Assignment__c();
      sa.Survey__c = anonymouseSurveyId;
      sa.Assignment_Nature__c = SurveyAssignmentObjectUtil.NATURE_TAKER;
      sa.GroupId__c = groupId;
      listAnonymousAssignment.add(sa); 
      insert listAnonymousAssignment;
  }
  // end

}