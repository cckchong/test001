@isTest(SeeAllData='true')
private class TestViewSurveyResultsReportController {
    
    @isTest static void testGetReportResponse() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];

            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('reportId', reportId);
                ApexPages.currentPage().getParameters().put('ext', 'xls');
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);

                viewSurveyResultsReportController.ReportResponse rr = reportReportController.getReportResponse();
                System.assert(rr != null);
                System.assertEquals(1, rr.exportDataResp.exportDataList.size());
                System.assert(String.IsNotBlank(rr.exportDataResp.takerNameColumnName));
            }
        }
    }

    @isTest static void testGetAnonymouseReportResponse() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String anonymouseSurveyId = surveyTestingUtil.anonymouseSurveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: anonymouseSurveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId', anonymouseSurveyId);
                ApexPages.currentPage().getParameters().put('reportId', reportId);
                ApexPages.currentPage().getParameters().put('ext', 'xls');
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);

                viewSurveyResultsReportController.ReportResponse rr = reportReportController.getReportResponse();
                System.assert(rr != null);
                System.assertEquals(1, rr.exportDataResp.exportDataList.size());
                System.debug('takerNameColumnName:' + rr.exportDataResp.takerNameColumnName);
                System.assert(String.IsBlank(rr.exportDataResp.takerNameColumnName));
            }
        }
    }

    @isTest static void testSurveyResultFilename() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('reportId', reportId);
                ApexPages.currentPage().getParameters().put('ext', 'xls');
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);
                String filename = reportReportController.surveyResultFilename;
                String surveyName = survey.Name;
                if (String.isNotBlank(surveyName)) {
                    surveyName = surveyName.replace(' ', '_');
                }
                System.assert(filename.startsWith(surveyName.replace('_', '')));           
                System.assert(filename.endsWith('xls'));            
            }
        }
    }

    @isTest static void testRefreshPage() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('reportId', reportId);
                ApexPages.currentPage().getParameters().put('ext', 'xls');
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);
                PageReference pr = reportReportController.refreshPage();
                System.assert(null == pr);
                System.assert(reportReportController.reportResponse != null);           
            }
        }
    }

    @isTest static void testNumSurveyLateTaker() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            survey.Is_Public__c='P';  
            update survey;                                   
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);
                Integer num = reportReportController.numLateTakers;
                System.assertEquals(4, num);
            }
        }
    }

    @isTest static void testSurveyLateTakerResult() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);
                String filename = reportReportController.surveyLateTakerFilename;
                String surveyName = survey.Name;
                if (String.isNotBlank(surveyName)) {
                    surveyName = surveyName.replace(' ', '_');
                }
                System.assert(filename.startsWith(surveyName));
                System.assert(filename.endsWith('xls'));        
            }
        }
    }

    @isTest static void testSendReminderEmail() {
        
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String ownerId = surveyTestingUtil.ownerId;

        User u = [Select Id, Name, UserName From User where id = :ownerId limit 1];
        System.runAs(u) {
            Report report = [Select id from Report where Name = 'Survey with Questions and Responses' limit 1];
            String reportId = report.Id;
            Survey__c survey = [Select Id, Name, Allow_Anonymous__c, Hide_Survey_Name__c, Survey_Toggle__c, 
                                                    Survey_Header__c, Survey_Start_DateTime__c, Survey_End_DateTime__c,  
                                                    Thank_You_Text__c, Survey_Container_CSS__c
                                                From Survey__c 
                                                where id =: surveyId limit 1];
            survey.Is_Public__c='P';
            update survey;                              
            if (survey != null) {
                PageReference pageRef = Page.viewSurveyResultsReportPage;
                Test.setCurrentPage(pageRef); //Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.StandardController stdSurvey = new ApexPages.StandardController(survey);
                viewSurveyResultsReportController reportReportController  = new viewSurveyResultsReportController(stdSurvey);
                reportReportController.sendReminderEmail();
            
                List<Survey_Email_Queue__c> ll = [Select Id, Survey_Email_Type__c, Survey__c, Survey_Email_Sent__c, 
                                                        Survey_Email_Scheduled_Sent_Date__c
                                                  From Survey_Email_Queue__c 
                                                  Where Survey__c = :surveyId AND Survey_Email_Type__C = 'Reminder'];
                System.assertEquals(4, ll.size());

                for (Survey_Email_Queue__c seq : ll) {
                    System.assertEquals('Reminder', seq.Survey_Email_Type__c);
                    System.assertEquals(true, seq.Survey_Email_Sent__c);
                    System.assertEquals(surveyId, seq.Survey__c);
                    System.assertEquals(DateTime.now().date(), seq.Survey_Email_Scheduled_Sent_Date__c);                            
                }
            }
        }
    }
}