global with sharing class GSurveysController {
  
  public String surveyDelete                       {get; set;}
  public String surveyCopy                         {get; set;}
  public String newSurveyName                      {get; set;}
  public List<miniSurvey>allSurveys                {get; set;}
  public List<miniSurvey>myAllSurveys              {get; set;}
  public String username                           {get; set;}
  public String userId                             {get; set;}
  public String POD                                {get; set;}
  public List<Selectoption>  sitesPicklist         {get; set;} 
  public String surveySite                         {get; set;}
  public String showAddSitesMessage                {get; set;} 
  private String subdomain;
  private boolean useTopLevelDomain;
  
  public String siteInfo  {get; set;}
  
  public GSurveysController(ApexPages.StandardController stdController){
    username = System.Userinfo.getUserId();    
    setMyAllSurveys();
    setupSitesPicklist();
    siteInfo = Site.getDomain();
  }
      
  private void setupSitesPicklist(){
    List<SurveySitesUtil.SurveySiteInfo> sites = new SurveySitesUtil().getSiteList();
    if (sites.size() > 0) {
        subdomain = sites[0].Subdomain;
    }
    useTopLevelDomain=false;
    String pathPrefix;
    sitesPicklist = new List<Selectoption>();
//    List<Site> sites = [select Name, Subdomain, TopLevelDomain, UrlPathPrefix from Site where Status = 'Active' ];
    //setupDomain(sites);
    setupShowSites(sites.size());
    sitesPicklist.add(new Selectoption('--SELECT SITE--',System.Label.LABS_SF_SELECTSITE ));
    sitesPicklist.add(new Selectoption('Internal',System.Label.LABS_SF_Internal));
    for(SurveySitesUtil.SurveySiteInfo s : sites){
      if(s.prefix == null)
        pathPrefix='EMPTY';
      else
        pathPrefix=s.prefix;
      sitesPicklist.add(new Selectoption(pathPrefix, s.Name));
    }
  }

/*
  private void setupDomain(list <Site> sites){
    String subD;
    String tLevelDomain;
    useTopLevelDomain =false;
    if(sites!=null && sites.size()>0){
      if(sites[0].TopLevelDomain != null && sites[0].TopLevelDomain.length()>0){
        subdomain = sites[0].TopLevelDomain;
        useTopLevelDomain=true;
      }
      else
        subdomain = sites[0].Subdomain;
    }
  }
*/
  private void setupShowSites(Integer i){
    if(i>0){
      showAddSitesMessage = 'false';
    }
    else{
      showAddSitesMessage = 'true';
    }
  }

  private void setAllSurveys(){
   List<Survey__c> surveys = [Select Id, Name from Survey__c where IsDeleted = false order by Name];
  
   if(allSurveys == null){
      allSurveys = new List<miniSurvey>();
    }
   else{
      allSurveys.clear(); 
    }
   for(Survey__c s : surveys){
      allSurveys.add(new miniSurvey(s.Name, s.Id));
    }
  }

  /* Added by Jack 08-06-2016 for Current Surveys correct list of surveys */
  private void setMyAllSurveys( ){
    String user = UserInfo.getUserId();
    List<Survey__c> surveys = [Select Id, Name from Survey__c where IsDeleted = false and OwnerId = :user];
  
    if(allSurveys == null){
      myAllSurveys = new List<miniSurvey>();
    }
    else{
      myAllSurveys.clear(); 
    }
    for(Survey__c s : surveys){
      myAllSurveys.add(new miniSurvey(s.Name, s.Id));
    }
  }
  
  // Commente by Connie. Move to testGSurveyController
  /*private static TestMethod void testGSurveysController(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.allSurveys.size()>0);
  } */ 
  
  public Pagereference makeNewSurvey(){   
    if(newSurveyName==null){
     POD='';
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Name_Is_Required));
     return null;
    }
    if(surveySite == '--SELECT SITE--'){
     POD='';
     ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Survey_Site_Is_Required));
     return null;
    }
    
    
    
    String urlPrefix = setupUrlPrefix(surveySite);
    String domain = setupDomainForSurvey(POD);
    String urlToSave= domain+'/'+urlPrefix+'TakeSurvey?';
    if (surveySite == 'Internal')
    {
        urlToSave = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'TakeSurvey?';
    }
    
    Survey__c s = new Survey__c();
    s.Name = newSurveyName;
    s.URL__c = urlToSave;
    s.Submit_Response__c = 'empty';
    s.thankYouText__c = System.Label.LABS_SF_Survey_Submitted_Thank_you;
    s.thankYouLink__c='http://www.salesforce.com';
    try{
      insert s;
      
      // added by Connie. Create a survey assignment record where owner is its survey administrator
      Survey_Assignment__c ownerAssignment = new Survey_Assignment__c();
      ownerAssignment.Survey__c = s.Id;
      ownerAssignment.Assignment_Nature__c = 'Administrator';
      ownerAssignment.User__c = UserInfo.getUserId();
      insert ownerAssignment;
      // end 

      //createAnonSurveyTaker(s.Id);
      return new Pagereference('/apex/SurveyManagerPage?id='+s.Id);
    }catch(Exception e){
      return null;
    }
  }

  // commented by Connie. Not used in controller
  /*private static void createAnonSurveyTaker(String surveyId){
     list <SurveyTaker__c> sTakers = [select id from SurveyTaker__c where Survey__c = :surveyId and Contact__c = null and Case__c = null];
     if(sTakers != null && sTakers.size()>0)
       return;
     SurveyTaker__c st = new SurveyTaker__c();      
     st.Case__c = null;
     st.Survey__c = surveyId;
     st.Contact__c = null;
     insert st;
  }*/
  
  private String setupDomainForSurvey(String pod){
    if(pod != 'NO_POD' && !useTopLevelDomain && checkSubdomain(subdomain)){
      return 'http://'+subdomain+'.'+pod+'.force.com';
    }
    else if(pod != 'NO_POD' && useTopLevelDomain && checkSubdomain(subdomain)){
      return 'http://'+subdomain+'.'+pod;
    }
    else if(useTopLevelDomain) {
      return 'http://'+subdomain;   
    }
    else{
      return 'http://'+subdomain+'.force.com';
    }
  }
  
  private boolean checkSubdomain(String subdomain){
    if(subdomain == null)
     return false;
    else if (subdomain.contains('developer-edition'))
     return true;
    else
     return false;
  }
  
  private String setupUrlPrefix(String site){
    if(site == null || site=='EMPTY')
     return '';
    else
     return site+'/';
  }

  public Pagereference doSurveyReset(){
    setAllSurveys();
    return null;
  }

  // Commente by Connie. Move to testGSurveyController
  /*private static TestMethod void testMakeNewSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assert(sc.makeNewSurvey()==null);
    sc.surveySite = '--SELECT SITE--';
    sc.newSurveyName = 'TestMakeNewSurvey';
    system.assert(sc.makeNewSurvey()==null);
    sc.surveySite = 'blah';
    System.assert(sc.makeNewSurvey()!=null);
    sc.doSurveyReset();     
  }*/
  
  public static webservice String deleteSurvey(String deleteId){
    Survey__c s= [Select Id, Name from Survey__c where Id =:deleteId];
    // added by Connie
    String surveyName = s.Name;
    delete s;
    // mod by Connie. return Survey is deleted message
    // return 'true';
    String deletedLabel = System.Label.LABS_SF_Survey_Deleted;
    String deletedMessage = String.format(deletedLabel, new String[] { surveyName } );
    return deletedMessage;
  }

    /*
  public static webservice String copySurvey(String copyId){
    Survey__c c= [Select Id, Name from Survey__c where Id =:copyId];
  Survey__c cCopy = c.clone(false, false, false, false);
    insert cCopy;
    return 'true';
  }
  */

  // added by Connie. Return complex type in web service method 
  global class copySurveyResult {
    WebService Boolean status {get; set;}
    WebService String url {get; set;}
    WebService String errorMessage {get; set; }
    public copySurveyResult() {}
  }
    
  //public static webservice String copySurvey(String copyId){
  public static webservice copySurveyResult copySurvey(String copyId){
    // retrieve Survey and related Survey_Question
    String strSurveySQL = getCreatableFieldsSOQL('Survey__c','id=\'' + copyId + '\'');
    String strSurveyQuestionSQL = getCreatableFieldsSOQL('Survey_Question__c','Survey__c=\'' + copyId + '\'');

    Survey__c c = (Survey__c)Database.query(strSurveySQL);
   
    // added by Connie. if success, navigate to url. Otherwise, error message is shown
    copySurveyResult result = new copySurveyResult();
    result.status = false;
    result.url = '';
    result.errorMessage = System.Label.LABS_SF_CopySurveyFailed;
    // end 
    if (c != null) {
      Survey__c cCopy = c.clone(false, true);
      List<Survey_Question__c> newSurveyQuestions = new List<Survey_Question__c>();
      if (cCopy != null) {
              Integer nameLength = Schema.SObjectType.Survey__c.fields.Name.getLength(); 
        System.debug('Maximum length of survey name = ' + nameLength);
        
        String copySurveyName = c.Name + '_Copy';
        if (copySurveyName.length() > nameLength) {
          copySurveyName = copySurveyName.substring(0, nameLength);
        }
        cCopy.Name = copySurveyName;
        // added by Connie. Default survey enabled to false
        cCopy.Survey_Toggle__c = false;
        // added by Connie. Clear Survey Admin List 1, 2, 3, 4 and 5
        cCopy.Survey_Admin_List_1__c = '';
        cCopy.Survey_Admin_List_2__c = '';
        cCopy.Survey_Admin_List_3__c = '';
        cCopy.Survey_Admin_List_4__c = '';
        cCopy.Survey_Admin_List_5__c = '';        
        insert cCopy;
        // added by Connie. get id of the new survey and generate the url to the new survey
        String newSurveyId = cCopy.Id;

        List<Survey_Question__c> lstSurveyQuestions = (List<Survey_Question__c>)Database.query(strSurveyQuestionSQL);
        for (Survey_Question__c sQues : lstSurveyQuestions) {
          Survey_Question__c sQuesClone = sQues.clone(false, true);
          if (sQuesClone != null) {
            sQuesClone.Survey__c = cCopy.ID;
            newSurveyQuestions.add(sQuesClone);
          }
        }
        
        insert newSurveyQuestions;
        // commented out by Connie. Return to survey manager page of new url
        //String successLabel = System.Label.LABS_SF_CopySurveySuccess;
        //String successMessage = String.format(successLabel, new String[] { c.Name, copySurveyName } );
        //return successMessage;

        // added by Connie. Create a survey assignment where current user is the administrator of the survey
        Survey_Assignment__c ownerAssignment = new Survey_Assignment__c();
        ownerAssignment.Survey__c = newSurveyId;
        ownerAssignment.Assignment_Nature__c = 'Administrator';
        ownerAssignment.User__c = UserInfo.getUserId();
        insert ownerAssignment;
        // end 

        String url = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SurveyManagerPage?id=' + newSurveyId;
        System.debug('copySurvey new Survey URL = ' + url);
        result.status = true;
        result.url = url;
        result.errorMessage = '';
        //return url;
        return result;
      }
    }
    //return System.Label.LABS_SF_CopySurveyFailed;
    return result;
  } 
  
   // added by Connie
  // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    private static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ 
          return null; 
        }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
    }
    // end 
    
  // Commente by Connie. Move to testGSurveyController  
  /*private static TestMethod void testDeleteSurvey(){
    SurveyTestingUtil tu = new SurveyTestingUtil();
    Apexpages.currentPage().getParameters().put('uId', Userinfo.getUserId());
    Apexpages.Standardcontroller stc;
    GSurveysController sc = new GSurveysController(stc);
    System.assertEquals(GSurveysController.deleteSurvey(tu.surveyId),'true');
  }*/
      
  public Class miniSurvey{
    public String sName {get; set;}
    public String sId   {get; set;}
    
    public miniSurvey(String miniName, String miniId){
      sName = miniName;
      sId = miniId;
    } 
      
  }
}