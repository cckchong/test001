/* Controller associated with pages rendering the survey.
   * Used by SurveyPage, ResultsPage, TakeSurvey
   */
  global virtual without sharing class ViewSurveyController {
      public String  qQuestion                      {get; set;}
      // public String  demo                      {get; set;}
      public Boolean qRequired                      {get; set;}
      public String  qChoices                       {get; set;}
      public String surveyName                        {get; set;}
      public String surveyHeader                {get; set;}
      public String surveyId                          {get; 
          set{
              this.surveyId = value;
              init();
          }
      }   
      public String theOwnerName;
      public String renderSurveyPreview           {get; set;}  
      public boolean isPublic;  //add by DTT team
      public String questionName                    {get; set;}  
      public String questionType                    {get; set;}
      public Boolean questionRequired             {get; set;}
      public List<SelectOption> singleOptions   {get; set;} 
      public List<question> allQuestions        {get; set;}
      public List<String> responses                   {get; set;}
      public Integer allQuestionsSize               {get; set;}
      public String  templateURL                {get; set;}
      public String  surveyThankYouText         {get; set;}
      public String surveyContainerCss {get; set;}
      public String  surveyThankYouURL          {get; set;}
      public String  caseId                     {get; set;}
      public String contactId         {get;set;}
      public String anonymousAnswer       {get;set;}
      public List<SelectOption> anonymousOrUser {get;set;}
      public Boolean isInternal {get;set;}
      public String baseURL {get;set;}
      public Boolean allowAnonymous{get;set;}     //Added by Carmen 20160405
      /** Commented by Carmen for Future use
      public Date startDate {get;set;}            
      public Date endDate {get;set;}             
      public String startTime {get;set;}          
      public String endTime {get;set;}
      **/
      public DateTime startDateTime {get;set;}
      public DateTime endDateTime {get;set;}
      
      public Boolean surveyToggle {get;set;}
      
      public String userId{get;set;}
      public String userName{get;set;}
      public String surveyTakerId {get;set;}
      public Boolean thankYouRendered{get;set;}
      public Boolean draftRendered{get;set;}
      public List<String> newOrder {get;set;}
      public Boolean previewMode { get; set; }

      
      
      /* Retrieves the list of questions, the survey name, after retrieving the 
         necessary parameters from the url.
      */
   //------------------------------------------------------------------------------// 
      public ViewSurveyController(ApexPages.StandardController stdController) {

        // add try-catch by Connie
        try {
          // Get url parameters
          surveyId = Apexpages.currentPage().getParameters().get('id');
          /** We don't need these - Commented by Carmen
          caseId   = Apexpages.currentPage().getParameters().get('caId');
          contactId = Apexpages.currentPage().getParameters().get('cId'); 
      
          if(caseId ==null || caseId.length()<5){
              caseId = 'none';
          }
          if(contactId ==null || contactId.length()<5){
              contactId = 'none';
          }         
      **/
          /* added by Connie. check if  ownere previews survey */
          String strPreview = Apexpages.currentPage().getParameters().get('preview');
          System.debug('strPreview = ' + strPreview);
          previewMode = String.isNotBlank(strPreview) ? Boolean.valueOf(strPreview) : false;
          System.debug('previewMode = ' + previewMode);
          /* end */

          // By default the preview is not showing up
          renderSurveyPreview = 'false';
          init();  
        } catch (Exception ex) {
          System.debug(ex.getMessage());
        }  
      } 

      // commented by Connie. This constructor is never called
      //public ViewSurveyController(viewShareSurveyComponentController controller) {
       
        // add try-catch by Connie
      //  try {
       //   surveyId = Apexpages.currentPage().getParameters().get('id');
          /** Commented by Carmen
          caseId   = Apexpages.currentPage().getParameters().get('caId');
          contactId = Apexpages.currentPage().getParameters().get('cId'); 
          if(caseId ==null || caseId.length()<5){
              caseId = 'none';
          }
          if(contactId ==null || contactId.length()<5){
              contactId = 'none';
          }  **/  
          // By default the preview is not showing up
      //    renderSurveyPreview = 'false';
      //    init();
      //  } catch (Exception ex) {
      //    System.debug(ex.getMessage());
      //  }
      //}
          
      public void init()
      {   
          isPublic=false;
          if (surveyId != null){ 

              // Retrieve all necessary information to be displayed on the page
              allQuestions = new List<question>();
              allQuestionsSize = 0;
              setupQuestionList();

              setSurveyNameAndThankYou(surveyId);//Uncomment by DTT
               //system.assert(false,'333');
                           

              /** Commented by Carmen
              anonymousOrUser = new List<SelectOption>();
              anonymousOrUser.add(new SelectOption('Anonymous',System.Label.LABS_SF_Anonymous));
              anonymousOrUser.add(new SelectOption('User','User ' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName()));
              anonymousAnswer = 'Anonymous';
              **/
              isInternal =true;
              newOrder = new List<String>();
              String urlBase = URL.getSalesforceBaseUrl().toExternalForm();
              baseURL = urlBase;
              allowAnonymous = false;    //Added by Carmen 20160405
              userId = UserInfo.getUserId();
              userName = UserInfo.getName();
              /* Add by Connie. Load draft responses */
              loadDraftResponses(surveyId, userId);
                          
              String profileId = UserInfo.getProfileId();

              try
              {
                  Profile p = [select Id, UserType from Profile where Id=:profileId];
                  // modify by Connie. Set default value
                  isInternal = false;
                  if (p != null) {
                    if (p.UserType == 'Guest')
                    {
                        isInternal = false;
                    }
                    else
                    {
                        isInternal = true;
                    }
                  } 
              }
              catch (Exception e){
                  isInternal = false;
              }
              
              
              thankYouRendered=false;
              draftRendered=false;
              
              /** Added by Carmen **/
              try
              {
                  theOwnerName='';//add by dtt      
                  Survey__c survey= [select Allow_Anonymous__c,Is_Public__c, owner.name,Survey_Toggle__c from Survey__c where Id=:surveyId];
                  // modify Connie. set default values
                  allowAnonymous = false;
                  surveyToggle = false;

                  if (survey != null) {
                    theOwnerName=survey.Owner.name;//add by dtt
                    allowAnonymous = survey.Allow_Anonymous__c;
                    surveyToggle = survey.Survey_Toggle__c;
                    if(survey.Is_Public__c=='E')
                    isPublic=true;
                  } 
              }
              catch (Exception e){
                  allowAnonymous = false;
              }

              
              try
              { 
                  /** Commented out, but reserved for future use
                  Survey__c survey = [select Survey_Start_Date__c, Survey_End_Date__c, Survey_Start_Time__c, Survey_End_Time__c from Survey__c where Id=:surveyId];
                  startDate = survey.Survey_Start_Date__c;
                  endDate = survey.Survey_End_Date__c;
                  
                  if (survey.Survey_Start_Time__c != '') {
                      startTime = survey.Survey_Start_Time__c;
                  } else {
                      startTime = '00:00';
                  }
                  if (survey.Survey_Start_Time__c != '') {
                      endTime = survey.Survey_End_Time__c;
                  } else {
                      endTime = '23:30';
                  }**/
                  
                  Survey__c surveyTime = [select Survey_Start_DateTime__c, Survey_End_DateTime__c from Survey__c where Id=:surveyId];
                  startDateTime = surveyTime.Survey_Start_DateTime__c;
                  endDateTime = surveyTime.Survey_End_DateTime__c;
                }
              catch (Exception e){
                  startDateTime = System.Now();
                  endDateTime = System.Now();
              }
              /** End **/            
          }       
      }
      

  //------------------------------------------------------------------------------//  
      // commented out by Connie. Move TestViewSurveyController
      /*private static Testmethod void testViewSurveyController() {
          SurveyTestingUtil tu = new SurveyTestingUtil();
          Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
          Apexpages.Standardcontroller stc;   
          ViewSurveyController vsc = new ViewSurveyController(stc);
          vsc.init();
          System.assert(vsc.allQuestionsSize == 4);
          System.assert(tu.surveyId != null);
          
          
          vsc.submitResults();
          for (question q : vsc.allQuestions)
          {
              q.selectedOption = String.valueof(2);
              q.choices = String.valueof(2);
              q.selectedOptions = new List<String>();
              q.selectedOptions.add(String.valueof(2));
              vsc.submitResults();            
          }
          System.assertEquals(true, vsc.thankYouRendered);
          
          
          //test something
      }*/
  //----------------------------------------------------------------------------//    
      
      /* Called during the setup of the page. 
         Retrieve questions and responses from DB and inserts them in 2 lists. */
      public Integer setupQuestionList(){

          getAQuestion();
          return allQuestions.size();
      }
      
      
     /** Sets the survey's name variable
      *  param: sID   The survey ID as specified in the DB
      */
      public void setSurveyNameAndThankYou(String sId){
          Survey__c s = [SELECT Name, Id, URL__c, Thank_You_Text__c, thankYouText__c, thankYouLink__c, Survey_Header__c, Survey_Container_CSS__c FROM Survey__c WHERE Id =:sId];
          // modify by Connie
          if (s != null) {
            surveyName = s.Name;
            surveyHeader = s.Survey_Header__c;
            templateURL = s.URL__c+'id='+sId;//+'&cId={!Contact.Id}'+'&caId='+'{!Case.id}';
            surveyThankYouText = s.Thank_You_Text__c;
            if (surveyThankYouText == null)
            {
                surveyThankYouText = System.Label.LABS_SF_Survey_Submitted_Thank_you;
            }
            surveyThankYouURL = s.thankYouLink__c;
            surveyContainerCss = s.Survey_Container_CSS__c;
          } 
      }
      
  //------------------------------------------------------------------------------//    
    // commented out by Connie. Unused in application
    /*public Pagereference updateSurveyName(){
        Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
        s.Name = surveyName;
        try{
          update s;
        }catch (Exception e){
          Apexpages.addMessages(e);
        }
        return null;
    } 
    
    private static Testmethod void testUpdateSurveyName() {
        SurveyTestingUtil tu = new SurveyTestingUtil();
        Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
        Apexpages.Standardcontroller stc; 
        ViewSurveyController vsc = new ViewSurveyController(stc);
        vsc.surveyName = 'new name';
        system.assert(vsc.updateSurveyName() == null);
        
    }*/
  //------------------------------------------------------------------------------//      
      // commented out by Connie. Unused in application
      /*public Pagereference updateSurveyThankYouAndLink(){
          Survey__c s = [SELECT Name, Id, URL__c, thankYouText__c, thankYouLink__c FROM Survey__c WHERE Id =:surveyId];
          s.thankYouText__c = surveyThankYouText;
          s.thankYouLink__c = surveyThankYouURL;
          try{
              update s;
          }catch(Exception e){
              Apexpages.addMessages(e);
          }
          return null;
      }*/
    
    /*private static Testmethod void testupdateSurveyThankYouAndLink() {
      SurveyTestingUtil tu = new SurveyTestingUtil();
      Apexpages.currentPage().getParameters().put('id',tu.surveyId);  
      Apexpages.Standardcontroller stc; 
      ViewSurveyController vsc = new ViewSurveyController(stc);
      vsc.surveyThankYouText = 'new stuff';
      vsc.surveyThankYouURL = 'more new stff';
      system.assert(vsc.updateSurveyThankYouAndLink()==null);
    }*/
      
    //------------------------------------------------------------------------------//    
    /** When requested from the page - when the user clicks on 'Update Order' -
        this function will reorganize the list so that it is displayed in the new order
     */
     public Pagereference refreshQuestionList(){
      setupQuestionList();
      return null;
     }
     
     
   
  //------------------------------------------------------------------------------//      

      

  //------------------------------------------------------------------------------//    
    private static boolean checkRequired(String response, Survey_Question__c question){
      if(question.Required__c == true){
          if(response == null || response =='NO RESPONSE')
            return false;
      }
      return true;
    } 

     /** Redirects the page that displays the detailed results of the survey, 
         from all users who took the survey.**/
      
      public PageReference resultPage() {
          return new PageReference('/apex/ResultsPage?id='+surveyId);
      } 
      
  //------------------------------------------------------------------------------//  

  //------------------------------------------------------------------------------//  

     /** 
      */
      public List<String> getResponses() {
          List<SurveyQuestionResponse__c> qr = [Select Survey_Question__c, SurveyTaker__c, Response__c, Name From SurveyQuestionResponse__c limit 100];
          List<String> resp = new List<String>();
          for (SurveyQuestionResponse__c r : qr) {
              resp.add(r.Response__c);
          }
          
          return resp;
      }  

     /** Class: question
      *  Retrieves the question information and puts it in the question object
      */      
      public class question{
        public String   name                   {get; set;}
        public String   id                     {get; set;}
        public String   question               {get; set;}
        public String   orderNumber            {get; set;}
        public String   choices                {get; set;}
        public String   otherChoices           {get; set;} // add by DTT
        public String   selectedOption         {get; set;}
        public List<String> selectedOptions    {get; set;}
        public List<SelectOption> singleOptions{get; set;}
        public List<SelectOption> multiOptions {get; set;}
        public Boolean  required               {get; set;}
        public String   questionType           {get; set;}    
        public String   surveyName             {get; set;}
        public String   renderFreeText         {get; set;}
        public String   renderSelectRadio      {get; set;}
        public Boolean   addOther              {get; set;} //add by DTT
        public String   renderSelectCheckboxes {get; set;} 
        public String   renderSelectRow        {get; set;}
        public List<String> responses          {get; set;}
        public String   singleOptionsForChart  {get; set;}
        public String   qResultsForChart       {get; set;} 
        public List<String> strList            {get; set;} // The question's option as a list of string
        public List<Integer> resultsCounts     {get; set;} // The count of each response to a question's choices
        public List<SelectOption> rowOptions   {get; set;}
        public boolean  noData                 {get; set;}
        // public boolean isShuffle               {get; set;}// add by DTT
        public boolean QRandomize               {get; set;}// add by DTT
        public boolean ARandomize               {get; set;}// add by DTT
        public boolean AnRandomize               {get; set;}// add by DTT
        
        public String surveyId1                {get; set;} 
        public String questionRT                {get; set;} //add by DTT
        
        
        //add by DTT
        public List<SelectOption> shuffle(List<SelectOption> option){
            List<SelectOption> options=new List<SelectOption>();
             Integer index=option.size();

             while(option.size()>0){
             double ran=Math.random();
             Integer ran1=(Integer)Math.floor(ran*index);
             options.add(option.remove(ran1)); 
             index--;
             }
             return options;
        }

        /** Fills up the question object
         *  param:    Survey_Question__c 
         */     
       public question(Survey_Question__c sq) {
        
          name = sq.Name;
          id = sq.Id;
          question = sq.Question__c;
          orderNumber = String.valueOf(sq.OrderNumber__c+1);
          choices = sq.Choices__c;
          otherChoices =sq.Other_Choices__c;
          required = sq.Required__c;
          addOther = sq.add_another_option__c;
          questionType = sq.Type__c;
          questionRT=sq.Rich_Text__c;//add by dtt
          singleOptionsForChart = ' ';
          selectedOption = '';
          selectedOptions = new List<String>();
          List<SelectOption> singleOptions1=new List<SelectOption>();
          List<SelectOption> multiOptions1=new List<SelectOption>();
          List<SelectOption> rowOptions1=new List<SelectOption>();
          singleOptions=new List<SelectOption>();
          multiOptions=new List<SelectOption>();
          rowOptions=new List<SelectOption>();
          surveyId1 = Apexpages.currentPage().getParameters().get('id');
          Survey__c survey = [select Randomize_Answers__c from Survey__c where id=:surveyId1];//add by DTT
           ARandomize=survey.Randomize_Answers__c;//add by Vic
           AnRandomize=sq.Randomize_Answers__c;
          System.debug('11111'+sq.Randomize_Answers__c);
          // isShuffle=false; //add by Vic  Disable shuffle at this version 
       if (sq.Type__c=='Single Select--Vertical'){
                  renderSelectRadio='true';
                  
                  if(AnRandomize==true){
                      singleOptions1 = stringToSelectOptions(choices);
                      singleOptions=shuffle(singleOptions1);
                  }else{
                      singleOptions = stringToSelectOptions(choices);
                  }// Add by DTT
                  
                  renderSelectCheckboxes='false';
                  renderFreeText='false';
                  renderSelectRow = 'false';
          selectedOption = '';
          selectedOptions = new List<String>(); 
          otherChoices='';                              
        }
       else if (sq.Type__c=='Multi-Select--Vertical'){        
                  renderSelectCheckboxes='true';
                  if(AnRandomize==true){
                  multiOptions1 = stringToSelectOptions(choices);
                  multiOptions = shuffle(multiOptions1);}
                  else{multiOptions = stringToSelectOptions(choices);
                  }// Add by DTT
                  
                  renderSelectRadio='false';
                  renderFreeText='false';
                renderSelectRow = 'false';
          selectedOption = '';
          selectedOptions = new List<String>();
          otherChoices='';   
        }
       else if (sq.Type__c=='Single Select--Horizontal'){   
            renderSelectCheckboxes='false';
            if(AnRandomize==true){
            rowOptions1 = stringToSelectOptions(choices);
            rowOptions =shuffle(rowOptions1);}
            else{rowOptions = stringToSelectOptions(choices);
            }// Add by DTT

            renderSelectRadio='false';
            renderFreeText='false';
            renderSelectRow = 'true';
          selectedOption = '';
          selectedOptions = new List<String>(); 
          otherChoices='';    
        }
       else if (sq.Type__c=='Free Text'){
              renderFreeText='true';
              renderSelectRadio='false';
              renderSelectCheckboxes='false';
            renderSelectRow = 'false';
            choices='';
        }
          //responses= getResponses();
        }
        
         /** Splits up the string as given by the user and adds each option
          *  to a list to be displayed as option on the Visualforce page
          *  param: str   String as submitted by the user
          *  returns the List of SelectOption for the visualforce page
          */  
        private List<SelectOption> stringToSelectOptions(String str){
          if (str == '')
          {
              return new List<SelectOption>();
          }
          strList = str.split('\n');
        
          List<SelectOption> returnVal = new List<SelectOption>();
          Integer i = 0;
          for(String s: strList){
              if (s!='') {    
                  if (s != 'null' && s!= null) {
                      String sBis = s.replace(' ', '%20');
                      singleOptionsForChart += s.trim()+'|';
                      
                      /*RSC2012-02-20
                      String st = s.replace (' ', '&nbsp;');
                      returnVal.add(new SelectOption(String.valueOf(i),st));
                      */
                      returnVal.add(new SelectOption(String.valueOf(i),s));
                      System.debug('*****VALUES: ' + s);
                      i++;
                  }
              }
          }
          singleOptionsForChart = singleOptionsForChart.substring(0, singleOptionsForChart.length()-1);
          return returnVal;
        } 
      }
      
    /** Fills up the List of questions to be displayed on the Visualforce page
     */   
      public List<question> getAQuestion() {
              qQuestion = '';
              // demo = '';//add by L
              qChoices ='';
          
          List<Survey_Question__c> allQuestionsObject = 
                                          [Select s.Type__c, s.Id, s.Survey__c, s.Required__c, s.Question__c, s.Rich_Text__c,
                                          s.OrderNumber__c, s.Name, s.Choices__c, s.add_another_option__c, s.Other_Choices__c,
                                          s.Randomize_Answers__c
                                          From Survey_Question__c s  
                                          WHERE s.Survey__c =: surveyId ORDER BY s.OrderNumber__c];  // Change by DTT
          allQuestions = new List<question>();

         List<question> allQuestions1 = new List<question>();

          // modify by Connie. Check size and set default value to question size
          allQuestionsSize = 0;
          if (allQuestionsObject.size() > 0) {
          
            Double old_OrderNumber = 0;
            Double new_OrderNumber;
            Double difference = 0;
            /* Make sure that the order number follow each other (after deleting a question, orders might not do so) */
            
                boolean QRandomize=false;
                //surveyId = Apexpages.currentPage().getParameters().get('id');
               Survey__c survey = [select Randomize_Questions__c from Survey__c where id=:surveyId];
               QRandomize=survey.Randomize_Questions__c;// Add by DTT  Disable at this version
            
            for (Survey_Question__c q : allQuestionsObject){ 
                new_OrderNumber = q.OrderNumber__c;
                difference = new_OrderNumber - old_OrderNumber - 1;
                if (difference > 0) {
                    Double dd = double.valueOf(difference);
                    Integer newOrderInt = dd.intValue();
                    q.OrderNumber__c -= Integer.valueOf(newOrderInt); 
                }
                old_OrderNumber = q.OrderNumber__c;
                question theQ = new question(q);
                if(QRandomize==true) {
                    allQuestions1.add(theQ);
                }else{
                allQuestions.add(theQ);}
            }
               
               
              if(QRandomize==true) {
              Integer index=allQuestions1.size();

                 while(allQuestions1.size()>0){
                 double ran=Math.random();
                 Integer ran1=(Integer)Math.floor(ran*index);
                 allQuestions.add(allQuestions1.remove(ran1)); 
                 index--;
                 }
             }// Add by DTT



            allQuestionsSize = allQuestions.size();
          } 
          return allQuestions;
      }   
      
      public void submitResults()
      {
          //List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
          Boolean outOfSurveyTime = false;
          DateTime now = System.now();
          /** Commented out, but reserved for future use 
          Integer startHour = integer.valueof(startTime.left(2));
          Integer startMin = integer.valueof(startTime.right(2));
          Integer endHour = integer.valueof(endTime.left(2));
          Integer endMin = integer.valueof(endTime.right(2));
                
          Integer nowHour = now.hour();
          Integer nowMin = now.minute();
          
          if ((now.date() < startDate && nowHour < startHour && nowMin < startMin)|| (now.date() > endDate && nowHour > endHour && nowMin > endMin)) {
      **/
          System.debug ('startDateTime: ' + startDateTime);
          System.debug ('endDateTime: ' + endDateTime);
          System.debug ('now: ' + now + ', earlier than start time? ' + (now < startDateTime) + ', after end time? ' + (now > endDateTime));
          if (now < startDateTime || now > endDateTime) {
              outOfSurveyTime = true;
          }
          System.debug ('surveyToggle: ' + surveyToggle + ', outofSurveyTime: ' + outofSurveyTime);
          if (surveyToggle && !outofSurveyTime) {
              thankYouRendered = saveAnswer(true, true);
              //return new PageReference('/apex/TakeSurveyResult');

          } else {
              Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Submit_Inactive_Survey));
              //return null;
              
          } 
      }
      
      private Boolean AddSurveyTaker(Boolean completed)
      {
          String userId;
          Boolean hideUser;
          
          if (surveyId == null)
          {
              return false;
          }

            /*
          if (anonymousAnswer != 'Anonymous')
          {
              userId = UserInfo.getUserId();
          }
          else
          {
              userId = null;
          } */
          userId = UserInfo.getUserId();
          if (allowAnonymous) {
              hideUser = true;
          } else {
              hideUser = false;
          }
          
          /** Check if the Survey was taken by user already.  The checking should exist even when the Survey allows anonymous **/
          //if(anonymousAnswer != 'Anonymous' && (contactId != null || caseId != null))
          //if(contactId != null || caseId != null)
          //{
            /* mod by Connie. Check whether survey is already completed */ 
  //            List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c From SurveyTaker__c Where User__c=:userId and Contact__c=:contactId and Survey__c=:surveyId and Case__c = :caseId and User__c=:UserId];
              List<SurveyTaker__c> check = [Select Contact__c, Survey__c, Case__c, User__c, Completed__c, Hide_User__c 
                                            From SurveyTaker__c Where User__c=:userId and Contact__c=:contactId and Survey__c=:surveyId 
                                            and Case__c = :caseId and User__c=:UserId];
            
              if(check != null && check.size()>0) {
                  if (check.get(0).Completed__c == true) {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_You_have_already_taken_this_survey));            
                    return false;       
                  }
              }
          //}
          // mod by Connie. Save a new survey or update a draft survey
          if (check.size() == 0) {
              SurveyTaker__c st = new SurveyTaker__c();
              st.Contact__c = contactId;
              st.Survey__c = surveyId;
              // modify by Connie. Remove from custom object
              //st.Taken__c = 'false';
              st.Case__c = caseId;
              st.User__c = userId;
              st.Hide_User__c = hideUser;
              st.Completed__c = completed;
              insert st;  
              surveyTakerId = st.Id;
          } else {
              SurveyTaker__c st = check.get(0);
              st.Completed__c = completed;
              update st;
              surveyTakerId = st.Id;
          }
          return true;    
      }
      
      /** Added by Carmen **/
      public void saveAsDraft() {
          draftRendered = saveAnswer(false, false);
          if(draftRendered){
              //return new PageReference('/apex/TakeSurveyResult');
          }
          else{
              //return null;
          }
      }
      
  //------------------------------------------------------------------------------//  
       // added by Connie begins
      /* update Survey Question Response */
      private void updateSurveyQuestionResponse(List<SurveyQuestionResponse__c> sqrList) {
        // mod by Connie. Delete original survey response
        List<SurveyQuestionResponse__c> savedSqrList = [Select ID From SurveyQuestionResponse__c 
                                where SurveyTaker__c = :surveyTakerId ];
        if (savedSqrList != null) {
          delete savedSqrList;  
        }
        if (sqrList != null) {
          for (SurveyQuestionResponse__c sqr : sqrList) {
              sqr.SurveyTaker__c = surveyTakerId;
          }
          insert sqrList;
        }
      }
      
      /* Determine if response matches selected options in survey question */
      private String isFoundInSelectedOptions(String response, List<SelectOption> selectedOptions) {
          String selectedValue = '';
          if (selectedOptions != null && selectedOptions.size() > 0) {
            for (SelectOption option : selectedOptions) {
              if (String.isNotBlank(response) && String.isNotBlank(option.getLabel())) {
                  if (option.getLabel().trim() == response.trim()) {
                    selectedValue = option.getValue().trim();
                    system.debug('11111'+selectedValue+'  '+response.trim() );
                      return selectedValue;
                  }
              }
            }
          }
          return selectedValue;
      }
      
      private List<SurveyTaker__c> retrieveSurveyTaker(String surveyId, String userId) {
          List<SurveyTaker__c> lstSurveyTaker = [Select ID from SurveyTaker__c 
                                                 WHERE Survey__c = :surveyId and User__c = :userId 
                                                 and Completed__c = false ];   
          return lstSurveyTaker;
      }
      
      private Map<String, question> retrieveQuestionMap() {
      
        // load survey questions and fill in answers inputted in drafted version of survey
        List<question> lstQuestions = getAQuestion();
        Map<String, question> mapQuestions = new Map<String, question>();
        for (question q: lstQuestions) {
          mapQuestions.put(q.id, q);
        }
        return mapQuestions;
      }
      
      public void loadDraftResponses(String surveyId, String userId) {
          List<SurveyTaker__c> lstSurveyTaker = retrieveSurveyTaker(surveyId, userId);    
          /* has draft version */
          if (lstSurveyTaker.size() > 0) {
            // load survey question responses 
            String surveyTakerId = lstSurveyTaker.get(0).ID;
            // load survey questions and fill in answers inputted in drafted version of survey
            Map<String, question> mapQuestions = retrieveQuestionMap();
            List<SurveyQuestionResponse__c> lstResponses = [Select ID, Name, Response__c, Survey_Question__c,Other_Response__c
                                                           from SurveyQuestionResponse__c 
                                                           where SurveyTaker__c = :surveyTakerId];// Change by DTT
            for (SurveyQuestionResponse__c surveyResponse: lstResponses) {
              // match existing question in survey 
              if (mapQuestions.containsKey(surveyResponse.Survey_Question__c)) {
                  question ques = mapQuestions.get(surveyResponse.Survey_Question__c);
                  if (ques != null) {
                      String response = surveyResponse.Response__c;
                      String otherResponse =surveyResponse.Other_Response__c;// Add by DTT
                      // selection expects value, not label
                      String selectedValue = '';
                      // single selection question 
                      if (ques.renderSelectRadio == 'true') {
                          // assign response to question if it matches one of the options
                          selectedValue = isFoundInSelectedOptions(response, ques.singleOptions);
                          if (String.isNotBlank(selectedValue)) {
                              ques.selectedOption = selectedValue;
                          }
                          ques.otherChoices=otherResponse;  // Add by DTT
                      } else if (ques.renderSelectRow == 'true') {
                          // assign response to question if it matches one of the options
                          selectedValue = isFoundInSelectedOptions(response, ques.rowOptions);
                          if (String.isNotBlank(selectedValue)) {
                              ques.selectedOption = selectedValue;
                          } 
                          ques.otherChoices=otherResponse;    // Add by DTT                   
                      } else if (ques.renderSelectCheckboxes == 'true') {
                          // question allow multiple responses     
                          selectedValue = isFoundInSelectedOptions(response, ques.multiOptions);
                          if (String.isNotBlank(selectedValue)) {
                              ques.selectedOptions.add(selectedValue);
                          }        
                          ques.otherChoices=otherResponse;  // Add by DTT           
                      } else if (ques.renderFreeText == 'true') {
                          // free text
                          ques.choices = response;
                      }
                  }
              }      
            }
          } 
      }
      // end

      // added by Connie. Refactor save answer logic
      private boolean saveAnswer(boolean execRequiredValidation, boolean completed) {
        Map<String,SelectOption> singleOptionsMap=new Map<String,SelectOption>(); // Add by DTT
        Map<String,SelectOption> multiOptionsMap=new Map<String,SelectOption>(); // Add by DTT
        Map<String,SelectOption> rowOptionsMap=new Map<String,SelectOption>(); // Add by DTT
        List <SurveyQuestionResponse__c> sqrList = new List<SurveyQuestionResponse__c>();
        for (question q : allQuestions) {
          SurveyQuestionResponse__c sqr = new SurveyQuestionResponse__c();
          if (q.renderSelectRadio == 'true') {
              
            if (execRequiredValidation) {
              if (q.required &&  (q.selectedOption == null || q.selectedOption == '')) {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Fill_Out_All_Required_Fields));
                  return false;
              }
            }
            
            if (q.selectedOption == null || q.selectedOption == '') {
                sqr.Response__c = '';
            } else {
              for(SelectOption s : q.singleOptions ){
                  singleOptionsMap.put(s.getValue(),s); // Add by DTT
              }
              //Integer a=Integer.valueOf(q.selectedOption);
              sqr.Response__c=singleOptionsMap.get(String.valueOf(Integer.valueOf(q.selectedOption))).getLabel(); // Add by DTT

                //sqr.Response__c = q.singleOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
            }
            sqr.Other_Response__c=q.otherChoices; // Add by DTT
            sqr.Survey_Question__c = q.Id;
            /* modify by Connie. set status of survey response */
            sqr.Completed__c = completed;
            sqrList.add(sqr);
          } else if (q.renderFreeText == 'true') {

            if (execRequiredValidation) { 
              if (q.required && q.choices == '') {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Fill_Out_All_Required_Fields));
                  return false;
              }
            }
            System.debug('*****Select Radio ' + q.choices);
            
            sqr.Response__c = q.choices;
            sqr.Survey_Question__c = q.Id;
            /* modify by Connie. set status of survey response */
            sqr.Completed__c = completed;
            sqrList.add(sqr);
          } else if (q.renderSelectCheckboxes == 'true') {
            if (execRequiredValidation) {
              if (q.required && (q.selectedOptions == null || q.selectedOptions.size() == 0)) {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Fill_Out_All_Required_Fields));
                  return false;
              }
            }
              
            for (String opt : q.selectedOptions) {
                sqr = new SurveyQuestionResponse__c();
                if (opt == '' || opt == null) {
                    sqr.Response__c = '';
                } else {   
                  //Comment by Vic disbale at this version 
                  for(SelectOption m : q.multiOptions ){
                   multiOptionsMap.put(m.getValue(),m); // Add by DTT
                    }
                   sqr.Response__c=multiOptionsMap.get(String.valueOf(Integer.valueOf(opt))).getLabel(); // Add by DTT
                  //Comment End
                   //sqr.Response__c = q.multiOptions.get(Integer.valueOf(opt)).getLabel();
                }
                sqr.Survey_Question__c = q.Id;
                sqr.Other_Response__c=q.otherChoices; // Add by DTT
                /* modify by Connie. set status of survey response */
                sqr.Completed__c = completed;
                sqrList.add(sqr);
            }
          } else if (q.renderSelectRow == 'true') {
            if (execRequiredValidation) {
              if (q.required && (q.selectedOption == null || q.selectedOption == '')) {
                  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.LABS_SF_Fill_Out_All_Required_Fields));
                  return false;
              }
            }
            
            if (q.selectedOption == null || q.selectedOption == '') {
                sqr.Response__c = '';
            } else {
               //Comment by Vic disbale at this version 
               for(SelectOption r : q.rowOptions ){
                   rowOptionsMap.put(r.getValue(),r); // Add by DTT
               }
              //Integer a=Integer.valueOf(q.selectedOption);
              sqr.Response__c=rowOptionsMap.get(String.valueOf(Integer.valueOf(q.selectedOption))).getLabel(); // Add by DTT
               //Comment End
                //sqr.Response__c = q.rowOptions.get(Integer.valueOf(q.selectedOption)).getLabel();
            }
            sqr.Other_Response__c=q.otherChoices; // Add by DTT
            sqr.Survey_Question__c = q.Id;
            /* modify by Connie. set status of survey response */
            sqr.Completed__c = completed;
            sqrList.add(sqr);
          }
        }

        if(AddSurveyTaker(completed)) {
          updateSurveyQuestionResponse(sqrList);
          return true;    
        }
        return false;
      }

      // added by Connie Leung. Check access right to take survey
      public PageReference checkAccessRight() {   
        //add by DTT team

        //Survey__c mySurvey= [select id,Is_Public__c  from Survey__c where Id=:surveyId];
        // system.assert(false,mySurvey);
        //if(mySurvey!=null && mySurvey.Is_Public__c=='E')
        //{
        //  isPublic=true;
        //}
        if(isPublic||(surveyId==null || surveyId==''))
        {
          return null;
        }   
        SurveyCheckAccessUtil util = new SurveyCheckAccessUtil(userId, surveyId);
        if (util.canTakeSurvey()) {
          return null;
        } else {
          userName = UserInfo.getName() +' (' ;      
          userName += UserInfo.getUserName() + ')';

          PageReference pr = new PageReference('/apex/SurveyErrorPage');
          /*
          pr.getParameters().put('error', 'User (' + userName + ')  does not have permission to take this survey(Id: ' + surveyId 
                                    +'     Name:'+ theOwnerName+'). Please contact survey owner for assistance.');
          */
          pr.getParameters().put('error',  userName + '  does not have permission to take this survey (Id: ' + surveyId 
                                    +'). Please contact the survey owner '+'('+ theOwnerName + ') for assistance.');
          pr.setRedirect(true);
          return pr;
        }                               
      }
      
      public PageReference backHome() {
          return new PageReference('/');
      }
      
      


       


  }