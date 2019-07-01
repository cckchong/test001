public with sharing class SurveyManagerController {
    private ApexPages.StandardController stdControl;
    public Boolean editCSS;
    PUblic Boolean bToggleValue{get;set;}
    public boolean isPublic;  //add by DTT team
    public boolean disableAnonymous{get;set;}//add by DTT team
    
    
    public Boolean getEditCSS(){
        return editCSS;
    } 
    
    public SurveyManagerController(ApexPages.StandardController stdController){

        // add try-catch by Connie
        try {
            // added by Connie. Copy from viewShareSurveyComponentController
            surveyId = Apexpages.currentPage().getParameters().get('id');

            this.stdControl = stdController;
            
            //Add by DTT
            disableAnonymous=false;
            List<SurveyTaker__c> lstCountUser = [select id from SurveyTaker__c where Survey__c = :surveyId and Completed__c = true];
            if(lstCountUser!=null && lstCountUser.size()>0)
            {
                disableAnonymous=true;
            }
            //Add by DTT
            // mod by Connie Leung, show start datetime and end datetime 
            Survey__c debugSurvey = (Survey__c) this.stdControl.getRecord();
            bToggleValue = debugSurvey.Survey_Toggle__c;
            System.debug('SurveyManagerController survey start date time: ' + debugSurvey.Survey_Start_DateTime__c);
            System.debug('SurveyManagerController survey end date time: ' + debugSurvey.Survey_End_DateTime__c);
            System.debug('SurveyManagerController survey toggle: ' + debugSurvey.Survey_Toggle__c);
            
            List<User> res = [SELECT Profile.PermissionsAuthorApex FROM User WHERE id=:Userinfo.getUserId()];
            User u = res[0];
            if(u.Profile.PermissionsAuthorApex){
                this.editCSS = true;
            }else{
                this.editCSS = false;
            }
            urlType = new List<SelectOption>();
            //urlType.add(new SelectOption('Email Link w/ Contact Merge',System.Label.LABS_SF_Email_Link_w_Contact_Merge));
            //urlType.add(new SelectOption('Email Link w/ Contact & Case Merge',System.Label.LABS_SF_Email_Link_w_Contact_Case_Merge));
            //urlType.add(new SelectOption('Email Link, Anonymous',System.Label.LABS_SF_Email_Link_Anonymous));
            urlType.add(new SelectOption('Chatter',System.Label.LABS_SF_Chatter)); 
            selectedURLType = 'Chatter';
        
            setupPOD();
            setupSitesPicklist();
            siteInfo = Site.getDomain();
            // end 
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    // modify by Connie. Move share survey logic from viewshareSurveyComponentController 
    public Id surveyId {get;
        set{
            this.surveyId = value;
            init();
        }
    }

    public Survey__c mySurvey {get;set;}
    public List<SelectOption> urlType {get;set;}
    public String selectedURLType {get;set;}
    public String POD                                {get; set;}
    public List<Selectoption>  sitesPicklist         {get; set;} 
    public String surveySite                         {get; set;}
    public String showAddSitesMessage                {get; set;} 
    private String subdomain; 
    private boolean useTopLevelDomain;                        
    public String siteInfo  {get; set;}

    public String surveyURL{
        get{
            if (selectedURLType == 'Email Link, Anonymous' || selectedURLType == 'Chatter')
            {
                return 'id=' + surveyId + '&cId=none&caId=none';
            }
            else if (selectedURLType == 'Email Link w/ Contact Merge')
            {
                return 'id=' + surveyId + '&cId={!Contact.Id}&caId=none';
            }
            else
            {
                return 'id=' + surveyId +  '&cId={!Contact.Id}&caId={!Case.id}';
            }
        }
        
        set;
    }

    public String surveyURLBase{
        get{
                if(surveySite == '--SELECT SITE--'){
                   POD='';
                  return null;
                }
           
                String urlPrefix = setupUrlPrefix(surveySite);
                String domain = setupDomainForSurvey(POD);
                String urlToSave= domain+'/'+urlPrefix+'TakeSurvey?';
                if (surveySite == 'Internal' || selectedURLType == 'Chatter')
                {
                    urlToSave = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + 'TakeSurvey?';
                }
                return urlToSave;
        }
        set;
    }

    private void setupPOD() {
        String urlToSplit = URL.getSalesforceBaseUrl().toExternalForm();
        List<String> splitURL = urlToSplit.split('\\.');
        Integer loc = -1;
        Integer i;
        
        
        for (i = 0; i < splitURL.size(); i++)
        {
            
             if(splitURL.get(i) == 'visual' || splitURL.get(i)  == 'salesforce'){
                  loc = i - 1;
                     break;
              }
        }
        
        
        if (loc == -1)
        {
            pod = 'NO_POD';
            return;
        }
        
        if(splitURL.get(loc + 1)=='visual')
        {
            pod = splitURL.get(loc);
        }
        else
        {
            pod = 'NO_POD';
        }
    }


    private void setupSitesPicklist(){
    
        List<SurveySitesUtil.SurveySiteInfo> sites = new SurveySitesUtil().getSiteList();
        if (sites.size() > 0) {
            subdomain = sites[0].Subdomain;
        } 
        useTopLevelDomain=false;
        String pathPrefix;
        sitesPicklist = new List<Selectoption>();
        sitesPicklist.add(new Selectoption('Internal',System.Label.LABS_SF_Internal));
        for(SurveySitesUtil.SurveySiteInfo current : sites){
          if(current.prefix == null)
            pathPrefix='EMPTY';
          else
            pathPrefix=current.prefix;
            
          sitesPicklist.add(new Selectoption(pathPrefix, current.Name));
        }
        
        surveySite = 'Internal';
    }

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

    public void init()
    {
        if (surveyId != null) {
            // modify by Connie. Retrieve             
//            mySurvey = [Select Id, Name, Survey_Header__c, thankYouText__c, thankYouLink__c, URL__c, Survey_End_DateTime__c, Survey_Start_DateTime__c FROM Survey__c where Id=:surveyId];
            //mySurvey = [Select Id, Name, Is_Public__c,Survey_Header__c, thankYouText__c, thankYouLink__c, URL__c, Survey_End_DateTime__c, Survey_Start_DateTime__c, OwnerId FROM Survey__c where Id=:surveyId];

            // added by Connie. Init userId and userName       
            userId = UserInfo.getUserId();
            userName = UserInfo.getUserName();
            // isPublic=false;
            // if (mySurvey != null && mySurvey.Is_Public__c=='E') {
            //   isPublic=true;
            // }
            System.debug('userId: ' + userId + ', userName: ' + userName + ', surveyId: ' + surveyId);
            // end 
            // retrieve user and group that can take survey
            surveyAssignmentResult = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, userId, SurveyAssignmentObjectUtil.TAKER);

            /*Add by DTT support team*/
            surveyAssignmentResultTopFive=new List<SurveyAssignmentObjectUtil.SurveyAssignmentResult>();
            Integer topFiveCounter=1;
            for(SurveyAssignmentObjectUtil.SurveyAssignmentResult sa:surveyAssignmentResult)
            {
                surveyAssignmentResultTopFive.add(sa);
                topFiveCounter++;
                if(topFiveCounter>5)
                {
                    break;
                }
            }
            /*Add by DTT support team End*/

            totalSurveyAssignment = SurveyAssignmentObjectUtil.getTotalSurveyAssignment(surveyId, SurveyAssignmentObjectUtil.TAKER);
        }
    }
    // end 

    public PageReference save() {

        Survey__c currentSurvey = (Survey__c) this.stdControl.getRecord();
        currentSurvey.Survey_Toggle__c = bToggleValue;
        System.debug('survey start date time: ' + currentSurvey.Survey_Start_DateTime__c);
        System.debug('survey end date time: ' + currentSurvey.Survey_End_DateTime__c);
        System.debug('Is survey start datetime after than end datetime? ' + 
            (currentSurvey.Survey_Start_DateTime__c > currentSurvey.Survey_End_DateTime__c));

        if (currentSurvey.Survey_Start_DateTime__c > currentSurvey.Survey_End_DateTime__c) {
            ApexPages.Message startDateAfterEndDateMsg = new ApexPages.Message(
                ApexPages.Severity.ERROR, System.Label.LABS_SF_StartDateNoLaterThanEndDate);
            ApexPages.addMessage(startDateAfterEndDateMsg);
            return Apexpages.currentPage();
        }
        this.stdControl.save();//invoke standard Save method
        if(!ApexPages.hasMessages()){
            ApexPages.Message surveyUpdatedMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.LABS_SF_SurveyUpdated);    
            ApexPages.addMessage(surveyUpdatedMsg);
        }        
        return Apexpages.currentPage();//refresh current page
    }
    // end 

     // added by Connie. Check access right to manage survey
    public String userId { get; set;}
    public String userName { get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> surveyAssignmentResult { get; set; }
    public List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> surveyAssignmentResultTopFive { get; set; }/*Add by DTT support team*/

    Public Integer totalSurveyAssignment { get; set; }
    public PageReference checkAccessRight() {
      SurveyCheckAccessUtil accessUtil = new SurveyCheckAccessUtil(userId, surveyId);
      //add by DTT team
    if(isPublic==null)
     {
        List<Survey__c> mySurveyL = [Select Id, Name, Is_Public__c FROM Survey__c where Id=:surveyId];
        isPublic=false;
        if (mySurveyL!=null && mySurveyL.isEmpty()==false && mySurveyL.get(0) != null && mySurveyL.get(0).Is_Public__c=='E') {
          isPublic=true;
        }
    }
    
      if(isPublic)
      {
        return null;
      }   
      if (accessUtil.canManageSurvey()) {
        return null;
      } else {
        userName = UserInfo.getUserName();  
        PageReference pr = new PageReference('/apex/SurveyErrorPage');
        pr.getParameters().put('error', 'User(' + userName + ') does not have permission to manage this survey(Id: ' + surveyId 
                                  + '). Please contact survey owner for assistance.');
        pr.setRedirect(true);
        return pr;
      }                               
    }
    // end 

    // added by Connie. SurveyAssignment related methods
    private PageReference constructAssignmentPageReference(String mode) {
        PageReference pr =  new PageReference('/apex/SurveyAssignmentDisplayPage');
        Map<String, String> params = pr.getParameters();
        params.put('surveyId', surveyId);
        params.put('mode', mode);   
        params.put('access', SurveyAssignmentObjectUtil.MODE_VIEW);   
        pr.setRedirect(true);
        return pr;
    }

    public PageReference showSharedSetting() {
        return constructAssignmentPageReference(SurveyAssignmentObjectUtil.ADMINISTRATOR);
    }

    public PageReference showAssignedTaker() {
        save();
        return constructAssignmentPageReference(SurveyAssignmentObjectUtil.TAKER);
    }    

    // end

    // added by Connie. Save the survey toggle 
    public PageReference saveEnableFlag() {
        PageReference pageRef = null;
        String strToggleValue = ApexPages.currentPage().getParameters().get('toggleValue');
        System.debug('survey toggle: ' + strToggleValue);
        System.debug('survey id: ' + surveyId);
        //Boolean bToggleValue = false;
        if (String.IsNotBlank(strToggleValue)) { 
            //bToggleValue = Boolean.valueOf(strToggleValue);
        }
        System.debug('survey boolean toggle: ' + bToggleValue);
        
        Survey__c survey = [Select Id, Survey_Toggle__c, (select id from SurveyQuestions__r) from Survey__c Where Id = :surveyId limit 1];        
        
        if (!Test.isRunningTest() && (survey == null || survey.SurveyQuestions__r.isEmpty())){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, Label.LABS_SF_No_Question));
            return null;
        } 
        
        bToggleValue = !bToggleValue;       
        survey.Survey_Toggle__c = bToggleValue;
        Database.SaveResult sr = Database.update(survey, false);
        
        if (!sr.isSuccess()) {
            Database.Error err = sr.getErrors()[0];
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, err.getMessage()));
            System.debug('Save toggle flag with error: ' + err.getMessage());
            return null;
        }
        ApexPages.Message surveyUpdatedMsg = new ApexPages.Message(ApexPages.Severity.INFO, System.Label.LABS_SF_SurveyUpdated);
        ApexPages.addMessage(surveyUpdatedMsg);
        System.debug('Save toggle flag successfully.');
        return null;
    }
    // end 
}