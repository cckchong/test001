@isTest
private class TestSurveyManagerController {
    
    @isTest static void testOwnerCheckAccessRight() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.checkAccessRight();
                System.assert(pr == null);
                System.assertEquals(3, managerController.surveyAssignmentResult.size());                    
            }
        }
    }

    @isTest static void testAdminCheckAccessRight() {
        // user should see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminId = surveyTestingUtil.adminId;

        User u = [Select Id, Name, UserName From User where id = :adminId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.checkAccessRight();
                System.assert(pr == null);
                System.assertEquals(3, managerController.surveyAssignmentResult.size());                    
            }
        }
    }
    
    @isTest static void testTakerCheckAccessRight() {
        // user should see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker1Id = surveyTestingUtil.taker1Id;

        User u = [Select Id, Name, UserName From User where id = :taker1Id limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c,Is_Public__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            survey.Is_Public__c='P';
            update survey;
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.checkAccessRight();
                System.assert(pr != null);

                String errorUrl = 'User(' + u.UserName 
                    + ') does not have permission to manage this survey(Id: ' 
                    + surveyId 
                    + '). Please contact survey owner for assistance.';
                String encodeErrorUrl = '/apex/SurveyErrorPage?error=' + EncodingUtil.urlEncode(errorUrl, 'UTF-8');
                System.assertEquals(encodeErrorUrl, pr.getUrl());
            }
        }
    }

    @isTest static void testGroupCheckAccessRight() {
        // user in public group should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String taker2Id = surveyTestingUtil.taker2Id;
        String taker3Id = surveyTestingUtil.taker3Id;

        User u2 = [Select Id, Name, UserName From User where id = :taker2Id limit 1];
        User u3 = [Select Id, Name, UserName From User where id = :taker3Id limit 1];
        System.runAs(u2) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Is_Public__c,Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
                survey.Is_Public__c='P';
                update survey;
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.checkAccessRight();
                System.assert(pr != null);

                String errorUrl = 'User(' + u2.UserName 
                    + ') does not have permission to manage this survey(Id: ' 
                    + surveyId 
                    + '). Please contact survey owner for assistance.';
                String encodeErrorUrl = '/apex/SurveyErrorPage?error=' + EncodingUtil.urlEncode(errorUrl, 'UTF-8');
                System.assertEquals(encodeErrorUrl, pr.getUrl());
            }
        }

        System.runAs(u3) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.checkAccessRight();
                System.assert(pr != null);

                String errorUrl = 'User(' + u3.UserName 
                    + ') does not have permission to manage this survey(Id: ' 
                    + surveyId 
                    + '). Please contact survey owner for assistance.';
                String encodeErrorUrl = '/apex/SurveyErrorPage?error=' + EncodingUtil.urlEncode(errorUrl, 'UTF-8');
                System.assertEquals(encodeErrorUrl, pr.getUrl());
            }
        }
    }
    

    //comment by DTT:Reason, User U can not acceess to the test record
    // @isTest static void testUnauthorizedUserCheckAccessRight() {
    //     // user should not see this page
    //     // user in public group should not see this page
    //     SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
    //     String surveyId = surveyTestingUtil.surveyId;
    //     String unAuthUserId = surveyTestingUtil.unAuthUserId;
    //     String ownerId = surveyTestingUtil.ownerId;
    //     Survey__c survey = null;

    //     User u1 = [Select Id, Name, UserName From User where id = :ownerId limit 1];
    //     System.runAs(u1) {
    //         survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
    //                         Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
    //                         Thank_You_Text__c, Survey_Container_CSS__c
    //                     From Survey__c 
    //                     where id =: surveyId limit 1];
    //     }

    //     User u = [Select Id, Name, UserName From User where id = :unAuthUserId limit 1];
    //     System.runAs(u) {
    //         if (survey != null) {
    //             PageReference pageRef = Page.SurveyManagerPage;
    //             Test.setCurrentPage(pageRef); //Applying page context here
    //             ApexPages.currentPage().getParameters().put('id',surveyId);
    //             ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
    //             SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

    //             PageReference pr = managerController.checkAccessRight();
    //             System.assert(pr != null);

    //             String errorUrl = 'User(' + u.UserName 
    //                 + ') does not have permission to manage this survey(Id: ' 
    //                 + surveyId 
    //                 + '). Please contact survey owner for assistance.';
    //             String encodeErrorUrl = '/apex/SurveyErrorPage?error=' + EncodingUtil.urlEncode(errorUrl, 'UTF-8');
    //             System.assertEquals(encodeErrorUrl, pr.getUrl());
    //         }
    //     }
    // }
    
    @isTest static void testSave() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                survey.Survey_Header__c = 'Survey Header updated';
                PageReference pr = managerController.save();
                System.assert(pr != null);
                String retUrl = Page.SurveyManagerPage.getUrl() + '?id=' + surveyId;
                System.assertEquals(retUrl, pr.getUrl(), 'Incorrect ' + pr.getUrl() + ' is returned instead');

                Survey__c newSurvey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                        From Survey__c 
                                        where id =: surveyId limit 1];
                System.assertEquals('Survey Header updated', newSurvey.Survey_Header__c);
            }
        }
    }

    @isTest static void testShowSharedSetting() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.showSharedSetting();
                System.assert(pr != null);
                String errorUrl = '/apex/SurveyAssignmentDisplayPage?access=view&mode=' 
                    + SurveyAssignmentObjectUtil.ADMINISTRATOR
                    + '&surveyId=' + surveyId;
                System.assertEquals(errorUrl, pr.getUrl());
            }
        }
    }

    @isTest static void testShowAssignedTaker() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                PageReference pr = managerController.showAssignedTaker();
                System.assert(pr != null);
                String errorUrl = '/apex/SurveyAssignmentDisplayPage?access=view&mode=' 
                    + SurveyAssignmentObjectUtil.TAKER
                    + '&surveyId=' + surveyId;
                System.assertEquals(errorUrl, pr.getUrl());
            }
        }
    }

    @isTest static void testSurveyBaseUrl() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                managerController.showAddSitesMessage = 'additional message'; 
                System.assertEquals('additional message', managerController.showAddSitesMessage);

                managerController.getEditCSS(); 
                String urlBase = managerController.surveyURLBase;
                String url = managerController.surveyURL;
                System.assert(urlBase != null);
                System.assert(url != null);

                managerController.selectedURLType = 'Email Link w/ Contact Merge';
                String emailUrl = managerController.surveyURL;
                System.assert(emailUrl != null);

                managerController.selectedURLType = 'blah';
                String otherUrl = managerController.surveyURL;
                System.assert(otherUrl != null);
            }
        }
    }

    @isTest static void testValidateSurveyDateOutOfRange() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                survey.Survey_Start_DateTime__c = DateTime.newinstance(2016, 9, 1, 9, 0, 0); 
                survey.Survey_End_DateTime__c = DateTime.newinstance(2016, 9, 1, 8, 59, 0); 
                managerController.save();

                // get the list of ApexPages.Message
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                // or loop over the messages
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('Survey start date must be equal to or earlier than end date.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity()); 
                }
            }
        }

    }

    @isTest static void testValidateSurveyDateInRange() {
        // user should not see this page
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                survey.Survey_Start_DateTime__c = DateTime.newinstance(2016, 9, 1, 9, 0, 0); 
                survey.Survey_End_DateTime__c = DateTime.newinstance(2016, 9, 2, 23, 59, 59); 
                managerController.save();

                // get the list of ApexPages.Message
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                // or loop over the messages
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The survey has been updated.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
                }
            }
        }
    }

    @isTest static void testSaveEnableFlag() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.SurveyManagerPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('id',surveyId);
                ApexPages.currentPage().getParameters().put('toggleValue', 'false');                
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                SurveyManagerController managerController  = new SurveyManagerController(stdSurvey);

                managerController.saveEnableFlag();

                // verify the value of Survey Toggle 
                Survey__c verifyDisableSurvey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
                System.assertEquals(false, verifyDisableSurvey.Survey_Toggle__c);

                // get the list of ApexPages.Message
                List<ApexPages.Message> msgList = ApexPages.getMessages();
                // or loop over the messages
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The survey has been updated.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
                }

                ApexPages.currentPage().getParameters().put('toggleValue', 'true');
                managerController.saveEnableFlag();
                
                Survey__c verifyEnableSurvey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                    Thank_You_Text__c, Survey_Container_CSS__c
                                From Survey__c 
                                where id =: surveyId limit 1];
                System.assertEquals(true, verifyEnableSurvey.Survey_Toggle__c);

                // get the list of ApexPages.Message
                msgList = ApexPages.getMessages();
                // or loop over the messages
                for(ApexPages.Message msg :  ApexPages.getMessages()) {
                    System.assertEquals('The survey has been updated.', msg.getSummary());
                    System.assertEquals(ApexPages.Severity.INFO, msg.getSeverity()); 
                }
            }
        }

    }
}