@isTest(seeAllData = true)
private class TestSurveyAndQuestionController {
    
    //test constructor and calls within it
    @isTest static void testCreateQuestionController(){
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            System.assert(survey != null);
            Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);
            SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
            cqc.addQuestion();
            cqc.getNewQuestionNum();
            cqc.makeNewQuestionLink();
            System.assert(cqc.surveyId == surveyTestingUtil.surveyId);
        }
    }

    //test constructor and calls within it
    @isTest static void testEditQuestion(){
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            System.assert(survey != null);
            Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);
            SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
            cqc.editQuestion();
            cqc.questionReference = surveyTestingUtil.questionIds[0];
            cqc.editQuestion();
            cqc.questionReference = surveyTestingUtil.questionIds[1];
            cqc.editQuestion();
            cqc.questionReference = surveyTestingUtil.questionIds[2];
            cqc.editQuestion();
            cqc.questionReference = surveyTestingUtil.questionIds[3];
            System.assert(cqc.editQuestion()==null);   
        } 
    }

    //test the saving of new questions
    @isTest static void testsaveAndNewQuestion(){
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            System.assert(survey != null);
            Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);
            SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
            //test saving new question
            cqc.demo = 'THIS IS A NEW QUESTION';
            cqc.qChoices = '1\\n2\\n3\\3';
            cqc.qRequired=true;
            cqc.questionType='Single Select--Vertical';
            cqc.saveAndNewQuestion();
            System.assertEquals(5, cqc.getNewQuestionNum());
            //edit existing question
            SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
            cqcI.questionReference = surveyTestingUtil.questionIds[0];
            cqcI.editQuestion();
            cqcI.demo = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW THIS IS A NEW';
            cqcI.qChoices = '1\\n2\\n3\\3';
            cqcI.qRequired=true;
            cqcI.questionType='Single Select--Vertical';
            cqcI.saveAndNewQuestion();
            System.assertEquals(5, cqcI.getNewQuestionNum());
        }
      }


     @isTest static void testSaveQuestion(){
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
            System.assert(survey != null);
            Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);

            SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
            //test saving new question
            cqc.demo = 'THIS IS A NEW QUESTION';
            cqc.qChoices = '1\\n2\\n3\\3';
            cqc.qRequired=true;
            cqc.questionType='Single Select--Vertical';
            cqc.showSingleSelect = 'true';
            cqc.controllerSavQuestion();
            System.assertEquals(5, cqc.getNewQuestionNum());
            //edit existing question
            SurveyAndQuestionController cqcI = new SurveyAndQuestionController(std);
            cqcI.questionReference = surveyTestingUtil.questionIds[0];
            cqcI.editQuestion();
            cqcI.demo = 'THIS IS A NEW QUESTION THAT IS EXTRA LONG SO THE NAME SHORTENING CALL WILL BE USED, THIS SHOULD BE LONG ENOUGH NOW';
            cqcI.qChoices = '1\\n2\\n3\\3';
            cqcI.qRequired=true;
            cqcI.questionType='Single Select--Vertical';
            cqcI.showSingleSelect = 'true';
            cqcI.controllerSavQuestion();
            System.assertEquals(5, cqcI.getNewQuestionNum());
        }
      }
  
      @isTest static void testPreviewQuestion(){
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
            System.assert(survey != null);
            Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);
            SurveyAndQuestionController cqc = new SurveyAndQuestionController(std);
            
            cqc.questionReference = surveyTestingUtil.questionIds[0];
            cqc.editQuestion();
            cqc.previewQuestion();

            cqc.questionReference = surveyTestingUtil.questionIds[1];
            cqc.editQuestion();
            cqc.previewQuestion();
            
            cqc.questionReference = surveyTestingUtil.questionIds[2];
            cqc.editQuestion();
            System.assert(cqc.previewQuestion()==null);
            
            cqc.questionReference = surveyTestingUtil.questionIds[3];
            cqc.editQuestion();
            System.assert(cqc.previewQuestion()==null);
        }
      }

      @isTest static void testRefreshQuestionList() {
          SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
          PageReference pageRef = Page.SurveyPage;
          Test.setCurrentPage(pageRef);
          Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
          String surveyId = surveyTestingUtil.surveyId;
          String ownerId = surveyTestingUtil.ownerId;

          User u = [Select Id, Name From User where id = :ownerId];
          System.runAs(u) {
              Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                            Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                            Thank_You_Text__c, Survey_Container_CSS__c
                            From Survey__c 
                            where id =: surveyId limit 1];
              System.assert(survey != null);
              Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
              SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
              vsc.getAQuestion();
              
              // Retrieve questions for this survey
              List<Survey_Question__c> sq = new List<Survey_Question__c>();
              sq = [Select id, orderNumber__c from Survey_Question__c];
              
              // get question with orderNumber 1
              Survey_Question__c first = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: surveyTestingUtil.surveyId];
              System.assert(first.orderNumber__c == 1 );    
             
              // Specify the new order
              vsc.newOrderW = vsc.allQuestions[2].id + ',' +
              vsc.allQuestions[0].id + ',' +
              vsc.allQuestions[1].id + ',' +
              vsc.allQuestions[3].id + ',';
              
              vsc.updateOrderList();
                    
              // Verify that the question with order 1 is not the same as the one retrieved previously
              Survey_Question__c second = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: surveyTestingUtil.surveyId];
              System.assert(second.id != first.id);
              
              // update the question list, and make sure it has been modified as well
              vsc.refreshQuestionList();
            System.assert(vsc.allQuestions[1].id != first.id);
          }
      }
    

     @isTest static void testDeleteQuestion() {
          SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
          PageReference pageRef = Page.SurveyPage;
          Test.setCurrentPage(pageRef);
          Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
          String surveyId = surveyTestingUtil.surveyId; 
          String ownerId = surveyTestingUtil.ownerId;

          User u = [Select Id, Name From User where id = :ownerId];
          System.runAs(u) { 
              Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                            Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                            Thank_You_Text__c, Survey_Container_CSS__c
                            From Survey__c 
                            where id =: surveyId limit 1];
              System.assert(survey != null);
              Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
              SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
              
              
              // Get a question to delete
              Survey_Question__c sq = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: surveyTestingUtil.surveyId];
              vsc.questionReference = sq.Id;
              vsc.deleteRefresh();
              
              Survey_Question__c sq2 = [Select id, orderNumber__c from Survey_Question__c Where orderNumber__c =: 1 and Survey__c =: surveyTestingUtil.surveyId];
              System.assert(sq.Id != sq2.Id);      
          }
    }

    @isTest static void testValidateQuestionSingleSelectQuestion() {

      SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
      PageReference pageRef = Page.SurveyPage;
      Test.setCurrentPage(pageRef);
      Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
          String surveyId = surveyTestingUtil.surveyId; 
          String ownerId = surveyTestingUtil.ownerId;

      User u = [Select Id, Name From User where id = :ownerId];
      System.runAs(u) { 
          Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
          System.assert(survey != null);
          Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
          SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
          
          vsc.addQuestion();
          vsc.showSingleSelect = 'TRUE';
          vsc.questionType = 'Single Select--Vertical';
          vsc.demo = null;
          vsc.qChoices = '1\r\n2\r\n3\r\n4\r\n';
          vsc.controllerSavQuestion();

          // or loop over the messages
          for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(System.Label.LABS_SF_BlankQuestion, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
          }
        }
    }

    @isTest static void testValidateQuestionSingleSelectChoice() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId; 
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) { 
          Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
          System.assert(survey != null);
          Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
          SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
          
          vsc.addQuestion();
          vsc.showSingleSelect = 'TRUE';
          vsc.questionType = 'Single Select--Vertical';
          vsc.demo = 'Dummy question';
          vsc.qChoices = null;
          vsc.controllerSavQuestion();

          // or loop over the messages
          for(ApexPages.Message msg :  ApexPages.getMessages()) {
            System.assertEquals(System.Label.LABS_SF_BlankChoices, msg.getSummary());
            System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
          }
        }
    } 

    @isTest static void testValidateQuestionSingleSelectQuestionType() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId; 
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) { 
          Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
          System.assert(survey != null);
          Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
          SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
          
           vsc.addQuestion();
           vsc.showRowQuestion = 'TRUE';
           vsc.questionType = null;
           vsc.demo = 'Dummy question?';
           vsc.qChoices = '1\r\n2\r\n3\r\n4\r\n';
           vsc.controllerSavQuestion();

            // or loop over the messages
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(System.Label.LABS_SF_BlankQuestionType, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
            }
        }
    }

    @isTest static void testValidateQuestionMultiSelectQuestion() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId; 
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) { 
          Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
          System.assert(survey != null);
          Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
          SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
          
           vsc.addQuestion();
           vsc.showMultiSelect = 'TRUE';
           vsc.questionType = 'Multi-Select--Vertical';
           vsc.demo = null;
           vsc.qChoices = '1\r\n2\r\n3\r\n4\r\n';
           vsc.controllerSavQuestion();

            // or loop over the messages
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(System.Label.LABS_SF_BlankQuestion, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
            }
        }
    }

    @isTest static void testValidateQuestionRowSelectQuestion() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId; 
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) { 
          Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                        From Survey__c 
                        where id =: surveyId limit 1];
          System.assert(survey != null);
          Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
          SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
          
           vsc.addQuestion();
           vsc.showRowQuestion = 'TRUE';
           vsc.questionType = 'Single Select--Horizontal';
           vsc.demo = null;
           vsc.qChoices = '1\r\n2\r\n3\r\n4\r\n';
           vsc.controllerSavQuestion();

            // or loop over the messages
            for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(System.Label.LABS_SF_BlankQuestion, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
            }
        }
    }

     @isTest static void testValidateQuestionFreeTextQuestion() {
          SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
          PageReference pageRef = Page.SurveyPage;
          Test.setCurrentPage(pageRef);
          Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
          String surveyId = surveyTestingUtil.surveyId; 
          String ownerId = surveyTestingUtil.ownerId;

          User u = [Select Id, Name From User where id = :ownerId];
          System.runAs(u) { 
              Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                            Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                            Thank_You_Text__c, Survey_Container_CSS__c
                            From Survey__c 
                            where id =: surveyId limit 1];
              System.assert(survey != null);
              Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
              SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
              
              vsc.addQuestion();
              vsc.showFreeText = 'TRUE';
              vsc.questionType = 'Free Text';
              vsc.demo = null;
              vsc.controllerSavQuestion();

              // or loop over the messages
              for(ApexPages.Message msg :  ApexPages.getMessages()) {
                 System.assertEquals(System.Label.LABS_SF_BlankQuestion, msg.getSummary());
                 System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
              }
         }
    }

    @isTest static void testValidateQuestionFreeTextQuestionType() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        PageReference pageRef = Page.SurveyPage;
        Test.setCurrentPage(pageRef);
        Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
        String surveyId = surveyTestingUtil.surveyId; 
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name From User where id = :ownerId];
        System.runAs(u) { 
              Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                            Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                            Thank_You_Text__c, Survey_Container_CSS__c
                            From Survey__c 
                            where id =: surveyId limit 1];
              System.assert(survey != null);
              Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
              SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);
              
              vsc.addQuestion();
              vsc.showFreeText = 'TRUE';
              vsc.questionType = null;
              vsc.demo = 'Free text question?';
              vsc.controllerSavQuestion();

              // or loop over the messages
              for(ApexPages.Message msg :  ApexPages.getMessages()) {
                System.assertEquals(System.Label.LABS_SF_BlankQuestionType, msg.getSummary());
                System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
              }
        }
    }
    
    @isTest static void testValidateQuestion() {
          SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
          PageReference pageRef = Page.SurveyPage;
          Test.setCurrentPage(pageRef);
          Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);
          String surveyId = surveyTestingUtil.surveyId; 
          String ownerId = surveyTestingUtil.ownerId;

          User u = [Select Id, Name From User where id = :ownerId];
          System.runAs(u) { 
              Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                            Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                            Thank_You_Text__c, Survey_Container_CSS__c
                            From Survey__c 
                            where id =: surveyId limit 1];
              System.assert(survey != null);
              Apexpages.Standardcontroller std = new ApexPages.StandardController(survey);        
              SurveyAndQuestionController vsc = new SurveyAndQuestionController(std);

              vsc.addQuestion();              
              vsc.controllerSavQuestion();

              // or loop over the messages
              for(ApexPages.Message msg :  ApexPages.getMessages()) {
                 System.assertEquals(System.Label.LABS_SF_BlankQuestionType, msg.getSummary());
                 System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
              }   
          }
    }
}