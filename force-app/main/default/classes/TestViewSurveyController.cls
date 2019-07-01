@isTest
private class TestViewSurveyController {

    @isTest static void testOwnerCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name from User where id = :ownerId limit 1];                   
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                PageReference pr = viewSurveyController.checkAccessRight();
                System.assert(pr == null);
            }
        }
    }   

    @isTest static void testAdminCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminId = surveyTestingUtil.adminId;

        User u = [Select Id, Name from User where id = :adminId limit 1];                   
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                PageReference pr = viewSurveyController.checkAccessRight();
                System.assert(pr == null);
            }
        }
    }

    @isTest static void testTakerCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                PageReference pr = viewSurveyController.checkAccessRight();
                System.assert(pr == null);
            }
        }
    }

    @isTest static void testGroupCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker2Id = surveyTestingUtil.taker2Id;
        String taker3Id = surveyTestingUtil.taker3Id;

        User u = [Select Id, Name from User where id = :taker2Id limit 1];                  
        User u2 = [Select Id, Name from User where id = :taker3Id limit 1];   
        Test.startTest();//Add by Vic           
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                PageReference pr = viewSurveyController.checkAccessRight();
                System.assert(pr == null);
            }
        }

        System.runAs(u2) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                PageReference pr = viewSurveyController.checkAccessRight();
                System.assert(pr == null);
            }
        }
        Test.stopTest();//Add by Vic   
    }

    @isTest static void testUnthorizedUserCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String unAuthUserId = surveyTestingUtil.unAuthUserId;
        Survey__c survey = [Select Id, Name,owner.name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                    Thank_You_Text__c, Survey_Container_CSS__c
                From Survey__c 
                where id =: surveyId limit 1];

        User u = [Select Id, Name, UserName from User where id = :unAuthUserId limit 1];                    
        System.runAs(u) {
            if (survey != null) {
                PageReference pageRef = Page.TakeSurvey;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('Id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);//add by dtt
                viewSurveyController.isPublic=false;
                PageReference pr = viewSurveyController.checkAccessRight();
                // System.assert(pr != null);
                String userName = u.name +' (' ;   //add by dtt   
                userName += u.UserName + ')';//add by dtt
                // System.assert(pr.getUrl().startsWith('/apex/SurveyErrorPage'));
                //String errMsg = 'User (' + u.UserName + ') does not have permission to take this survey(Id: ' + surveyId 
                //                  + '). Please contact survey owner for assistance.';

                String errMsg =userName + '  does not have permission to take this survey (Id: ' + surveyId 
                                  +'). Please contact the survey owner '+'('+ survey.owner.name + ') for assistance.';//add by dtt
                System.assertEquals(errMsg, pr.getParameters().get('error'));
            }
        }
    }


    

    private static ViewsurveyController createViewSurveyController(Survey__c survey) {
        return createCommonViewSurveyController(survey, true);
    }

    private static ViewsurveyController createViewBlankSurveyController(Survey__c survey) {
        return createCommonViewSurveyController(survey, false);
    }

    private static ViewsurveyController createCommonViewSurveyController(Survey__c survey, boolean hasInputAnswer) {
        PageReference pageRef = Page.TakeSurvey;
        Test.setCurrentPage(pageRef); //Applying page context here
        ApexPages.currentPage().getParameters().put('Id',survey.Id);
        ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
        ViewSurveyController viewSurveyController  = new ViewSurveyController(stdSurvey);

        // answer some question
        List<viewSurveyController.question> listQuestions = viewSurveyController.allQuestions;
        for (viewSurveyController.question q : listQuestions) {
            q.selectedOptions = new List<String>();
            if (hasInputAnswer) {
                if (q.renderFreeText == 'true') {
                    // free text
                    q.choices = 'three';
                } else if (q.renderSelectRow == 'true') {   
                    // single select horizontal
                    q.selectedOption = String.valueOf(2);
                } else if (q.renderSelectRadio == 'true') {   
                    // single select vertical
                    q.selectedOption = String.valueOf(2);
                } else {
                    // multiple select vertical
                    q.selectedOption = String.valueOf(2);
                    q.selectedOptions.add(String.valueOf(2));
                }
            } else {
                q.choices = '';
                q.selectedOption = '';
            }
        }
        return viewSurveyController;
    }

    @isTest static void testSaveDraft() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.saveAsDraft();
                System.assertEquals(true, viewSurveyController.draftRendered);
                String surveyTakerId = viewSurveyController.surveyTakerId;

                List<SurveyTaker__c> listTaker = [Select Id, Completed__c From SurveyTaker__c where id = :surveyTakerId];
                for (SurveyTaker__c taker : listTaker) {
                    System.assertEquals(false, taker.Completed__c);
                }

                // verify response
                List<SurveyQuestionResponse__c> listResponses = [Select Id, Survey_Question__c, Response__c, Survey_Question__r.Type__c 
                                                    From SurveyQuestionResponse__c 
                                                    where SurveyTaker__c = :surveyTakerId];
                for (SurveyQuestionResponse__c resp : listResponses) {
                    System.assertEquals('three', resp.Response__c);
                }
            }
        }
    }

    @isTest static void testSaveBlankDraft() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewBlankSurveyController(survey);
                viewSurveyController.saveAsDraft();
                System.assertEquals(true, viewSurveyController.draftRendered);
                String surveyTakerId = viewSurveyController.surveyTakerId;

                List<SurveyTaker__c> listTaker = [Select Id, Completed__c From SurveyTaker__c where id = :surveyTakerId];
                for (SurveyTaker__c taker : listTaker) {
                    System.assertEquals(false, taker.Completed__c);
                }

                // verify response
                List<SurveyQuestionResponse__c> listResponses = [Select Id, Survey_Question__c, Response__c, Survey_Question__r.Type__c 
                                                    From SurveyQuestionResponse__c 
                                                    where SurveyTaker__c = :surveyTakerId];
                for (SurveyQuestionResponse__c resp : listResponses) {
                    System.assert(String.isBlank(resp.Response__c));
                }
            }
        }
    }

    @isTest static void testSubmitRequiredResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                System.assertEquals(true, viewSurveyController.thankYouRendered);
                String surveyTakerId = viewSurveyController.surveyTakerId;

                List<SurveyTaker__c> listTaker = [Select Id, Completed__c From SurveyTaker__c where id = :surveyTakerId];
                for (SurveyTaker__c taker : listTaker) {
                    System.assertEquals(true, taker.Completed__c);
                }

                // verify response
                List<SurveyQuestionResponse__c> listResponses = [Select Id, Survey_Question__c, Response__c, Survey_Question__r.Type__c 
                                                    From SurveyQuestionResponse__c 
                                                    where SurveyTaker__c = :surveyTakerId];
                for (SurveyQuestionResponse__c resp : listResponses) {
                    System.assertEquals('three', resp.Response__c);
                }
            }
        }
    }

    @isTest static void testSubmitResultOfDisabledSurvey() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   
        String ownerId = surveyTestingUtil.ownerId;

        // disabled survey before making it active
        User u = [Select Id, Name From User Where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
            From Survey__c 
            where id =: surveyId limit 1];
            if (survey != null) {
                survey.Survey_Toggle__c = false;
                update survey;
            }
        }

        User u2 = [Select Id, Name from User where id = :taker1Id limit 1];                 
        System.runAs(u2) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The Survey has been disabled.  You cannot submit it!  However you may save the response as draft.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSubmitResultFutureStartDate() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   
        String ownerId = surveyTestingUtil.ownerId;

        // survey from date in the future
        User u = [Select Id, Name From User Where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
            From Survey__c 
            where id =: surveyId limit 1];
            if (survey != null) {
                DateTime currentTime = System.now();
                DateTime fromTime = System.DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 9, 0, 0);
                DateTime toTime = fromTime.addMonths(1);
                survey.Survey_Start_DateTime__c = survey.Survey_Start_DateTime__c.addDays(2);
                update survey;
            }
        }

        User u2 = [Select Id, Name from User where id = :taker1Id limit 1];                 
        System.runAs(u2) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The Survey has been disabled.  You cannot submit it!  However you may save the response as draft.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSubmitResultPastEndDate() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   
        String ownerId = surveyTestingUtil.ownerId;

        // survey from date in the future
        User u = [Select Id, Name From User Where id = :ownerId];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
            From Survey__c 
            where id =: surveyId limit 1];
            if (survey != null) {
                DateTime currentTime = System.now();
                DateTime fromTime = System.DateTime.newInstance(currentTime.year(), currentTime.month(), currentTime.day(), 9, 0, 0);
                DateTime toTime = fromTime.addMonths(1);
                survey.Survey_Start_DateTime__c = survey.Survey_Start_DateTime__c.addMonths(-3);
                survey.Survey_End_DateTime__c = survey.Survey_End_DateTime__c.addMonths(-2);
                update survey;
            }
        }

        User u2 = [Select Id, Name from User where id = :taker1Id limit 1];                 
        System.runAs(u2) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The Survey has been disabled.  You cannot submit it!  However you may save the response as draft.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    private static void clearAnswer(ViewSurveyController viewSurveyController, Integer index)  {

        if (index >= 0 && index < viewSurveyController.allQuestions.size()) {
            ViewSurveyController.question q1 = viewSurveyController.allQuestions.get(index);
            if (q1 != null) {
                if (q1.renderFreeText == 'true') {
                    q1.choices = '';
                } else if (q1.renderSelectCheckboxes == 'true') {
                    q1.selectedOption = '';
                    q1.selectedOptions.clear();
                } else {
                    q1.selectedOption = '';
                }
            }
        }
    }

    @isTest static void testSubmitMissingSingleSelectHorizontalResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                clearAnswer(viewSurveyController, 0);
                viewSurveyController.submitResults();
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('Please fill out all required fields', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSubmitMissingMultiSelectVerticalResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                clearAnswer(viewSurveyController, 1);
                viewSurveyController.submitResults();
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('Please fill out all required fields', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSubmitMissingSingleSelectVerticalResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                clearAnswer(viewSurveyController, 2);
                viewSurveyController.submitResults();
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('Please fill out all required fields', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSubmitMissingFreeTextResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                clearAnswer(viewSurveyController, 3);
                viewSurveyController.submitResults();
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('Please fill out all required fields', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testResubmitSurveyResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];

        System.runAs(u) {
        Test.startTest();//Add by Vic   
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                // submit survey again will prompt error
                viewSurveyController = createViewSurveyController(survey);
                viewSurveyController.submitResults();

                List<ApexPages.Message> msgList = ApexPages.getMessages();
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('You have already taken this survey!', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        Test.stopTest();//Add by Vic   
        }
    }

    @isTest static void testLoadDraftResponses() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Test.startTest();
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.saveAsDraft();
                String surveyTakerId = viewSurveyController.surveyTakerId;

                ViewSurveyController viewDrafSurveyController  = createViewSurveyController(survey);
                viewDrafSurveyController.loadDraftResponses(surveyId, taker1Id);

                List<ViewSurveyController.question> listDraftQuestions = viewDrafSurveyController.allQuestions;
                for (ViewSurveyController.question q : listDraftQuestions) {
                    if (q.renderFreeText == 'true') {
                        // free text
                        System.assertEquals('three', q.choices);
                    } else if (q.renderSelectRow == 'true') {   
                        // single select horizontal
                        System.assertEquals('2', q.selectedOption);
                    } else if (q.renderSelectRadio == 'true') {   
                        // single select vertical
                        System.assertEquals('2', q.selectedOption);
                    } else {
                        // multiple select vertical
                        System.assertEquals('', q.selectedOption);
                        System.assertEquals(1, q.selectedOptions.size());
                        System.assertEquals('2', q.selectedOptions.get(0));
                    }
                }
            }
            Test.stopTest();
        }
    }
 
    @isTest static void testSubmitDraftResult() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Test.startTest();
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.saveAsDraft();
                String draftSurveyTakerId = viewSurveyController.surveyTakerId;

                ViewSurveyController viewDraftSurveyController  = createViewSurveyController(survey);
                viewDraftSurveyController.loadDraftResponses(surveyId, taker1Id);
                
                viewDraftSurveyController.submitResults();
                String submitSurveyTakerId = viewSurveyController.surveyTakerId;

                System.assertEquals(true, viewDraftSurveyController.thankYouRendered);
                System.assertEquals(draftSurveyTakerId, submitSurveyTakerId);

                List<SurveyTaker__c> listTaker = [Select Id, Completed__c From SurveyTaker__c where id = :submitSurveyTakerId];
                System.assertEquals(1, listTaker.size());
                for (SurveyTaker__c taker : listTaker) {
                    System.assertEquals(true, taker.Completed__c);
                }

                // verify response
                List<SurveyQuestionResponse__c> listResponses = [Select Id, Survey_Question__c, Response__c, Survey_Question__r.Type__c 
                                                    From SurveyQuestionResponse__c 
                                                    where SurveyTaker__c = :submitSurveyTakerId];
                for (SurveyQuestionResponse__c resp : listResponses) {
                    System.assertEquals('three', resp.Response__c);
                }
                
            }
             Test.stopTest();
        }
    }    

    @isTest static void testGetResponses() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;   

        User u = [Select Id, Name from User where id = :taker1Id limit 1];                  
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            if (survey != null) {
                ViewSurveyController viewSurveyController  = createViewSurveyController(survey);
                viewSurveyController.getResponses();
            }
        }
    }

    @isTest static void testViewSurveyController() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name from User where id = :ownerId limit 1];                   
        System.runAs(u) {
        Test.startTest();//Add by Vic   
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                        Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                        Thank_You_Text__c, Survey_Container_CSS__c
                    From Survey__c 
                    where id =: surveyId limit 1];
            System.assert(survey != null);

            PageReference pageRef = Page.TakeSurvey;
            Test.setCurrentPage(pageRef); //Applying page context here
            Apexpages.currentPage().getParameters().put('id',surveyTestingUtil.surveyId);  

            Apexpages.Standardcontroller stc = new Apexpages.Standardcontroller(survey);   
            ViewSurveyController vsc = new ViewSurveyController(stc);
            vsc.init();
            System.assert(vsc.allQuestionsSize == 4);
            System.assert(surveyTestingUtil.surveyId != null);
    
            vsc.submitResults();
            for (viewSurveyController.question q : vsc.allQuestions)
            {
                q.selectedOption = String.valueof(2);
                q.choices = String.valueof(2);
                q.selectedOptions = new List<String>();
                q.selectedOptions.add(String.valueof(2));
                vsc.submitResults();            
            }
            System.assertEquals(true, vsc.thankYouRendered);   
        Test.stopTest();//Add by Vic   
        }    
    }
}