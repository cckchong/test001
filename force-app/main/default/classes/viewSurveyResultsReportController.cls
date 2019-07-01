// added by Connie Leung
    global virtual with sharing class viewSurveyResultsReportController {
        
        public String reportId { get; set; }
        public String surveyId { get; set; }
        public String reportName { get; set; }
        public String extension { get; set; }
        public ReportResponse reportResponse { get; set; }
        public String sharingGroupName;
        public Integer totalAssignUser{get;set;}
        public String isPublic;
        public Boolean AllowAnonymous{ get; set; }
        //------------------------------------------------------------------------------// 
        public viewSurveyResultsReportController(ApexPages.StandardController stdController) {
            // Get url parameters
            reportId = Apexpages.currentPage().getParameters().get('reportId');
            surveyId = Apexpages.currentPage().getParameters().get('surveyId');

            //Add by DTT Support Team
            sharingGroupName='TALGROUP_Everyone';
            system.debug(surveyId);
            survey__c tempSurvey=[select id, Is_Public__c, Allow_Anonymous__c from survey__c where id=:surveyId];
            // system.assert(false,tempSurvey);
            if(tempSurvey==null || tempSurvey.Is_Public__c==null || tempSurvey.Is_Public__c=='')
            {
                isPublic='P';

            }
            else
            {
                isPublic=tempSurvey.Is_Public__c;
            }
            AllowAnonymous=tempSurvey.Allow_Anonymous__c;
            //Add by DTT Support Team

            // load optional extension parameter
            if (Apexpages.currentPage().getParameters().containsKey('ext')) {
                extension = Apexpages.currentPage().getParameters().get('ext');
            } else {
                extension = 'xls';
            }
                    
            // run report in sync mode     
            if (String.IsNotBlank(reportId)) {    
                reportResponse = getReportResponse();
            }
            totalAssignUser=getGroupMemberTotal();//Add by DTT Support Team
           
        } 

        public PageReference refreshPage() {
            System.debug('Fire refreshPage starts.');
            //sumResp = getReportResponse();
            reportResponse = getReportResponse();
            totalAssignUser=getGroupMemberTotal();//Add by DTT Support Team
            System.debug('Fire refreshPage ends.');
            return null;
        }
        
        // reference: https://developer.salesforce.com/blogs/developer-relations/2015/03/transforming-analytics-api-data-salesforce1-lightning-components.html
        //https://developer.salesforce.com/blogs/developer-relations/2015/03/navigating-reports-records-lightning-events.html
        // https://developer.salesforce.com/blogs/developer-relations/2015/04/displaying-summary-and-matrix-reports.html    
        public class ReportResponse {
            public ReportResponse() {}
            public summaryReportResponse sumResp { get; set; }
            //public String grandTotalLabel { get; set; }
            public Integer numSurveyTaker { get; set; }
            // added by Connie. Store data export to report file
            public exportDataResponse exportDataResp { get; set; }
        }

        public class summaryReportResponse {
            public List<summaryReportGroup> groupList { get; set;}
            public summaryReportResponse(){}
        }   
        
        // data of sumamry report group
        public class summaryReportGroup {
            public String fieldName {get; set;}
            public String fieldValue {get; set;}
            public String fieldLabel {get; set;}
            public String groupKey {get; set;}
            public String percentLabel { get; set; }
            public String recordCountLabel { get; set; }        
            public String numPersonChosen { get; set; }
            public String total { get; set; }   
            public summaryReportGroup(){}
        }
        
        // data of sumamry report group
        public class exportDataResponse {
            public List<exportData> exportDataList { get; set; }
            public String takerNameColumnName { get; set; }
            public exportDataResponse() {}
        }

        public class exportData {
            public String surveyName { get; set; }
            public String question {get; set;}
            public String response {get; set;}
            public String otherresponse {get; set;}//add by L
            public Decimal totalResponse { get; set; }
            public String takerName { get; set; }   
            public Boolean required { get; set; }
            public Decimal questionNumber { get; set; }
            public String surveyTakenTime { get; set; }
            public String surveyCreatedTime { get; set; }
            public exportData(){}
        }

        public ReportResponse getReportResponse() {
            
            Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
            Reports.ReportMetadata reportMd = describe.getReportMetadata();
            List<Reports.ReportFilter> lstReportFilter = new List<Reports.ReportFilter>(); 
            lstReportFilter.add(new Reports.ReportFilter('Survey__c.Id', 'equals', surveyId));
            // filter out question response status = draft and question receives at least 1 
            lstReportFilter.add(new Reports.ReportFilter('SurveyQuestionResponse__c.Completed__c', 'equals', 'true'));
            lstReportFilter.add(new Reports.ReportFilter('Survey_Question__c.Total_Completed_Responses__c', 'greaterThan', '0'));
            // end 
            reportMd.setReportFilters(lstReportFilter);
            reportName = reportMd.getName();
            
            //get the report result
            Reports.ReportResults results = Reports.ReportManager.runReport(reportId, reportMd, true);
            ReportResponse reportResponse = new ReportResponse();
            if (results != null) {
                reportResponse = getSummaryReportResponse(results);
                reportResponse.exportDataResp = getExportDataResponse();
            } else {
                reportResponse.sumResp = new summaryReportResponse();
                //reportResponse.grandTotalLabel = '';
                reportResponse.numSurveyTaker = 0;
                reportResponse.exportDataResp = new exportDataResponse();
            } 
            return reportResponse;
        }
        
        private ReportResponse getSummaryReportResponse(Reports.ReportResults results) {

            ReportResponse reportResponse = new ReportResponse();
            summaryReportResponse srr = new summaryReportResponse();
            reportResponse.sumResp = srr;
        
            //get the metadata
            Reports.ReportMetadata reportMetadata = results.getReportMetadata();
        
            //get the extended metadata
            Reports.ReportExtendedMetadata reportExtendedMetadata = results.getReportExtendedMetadata();
        
            // get the map of the aggregate column names to their name and label
            List<String> aggregateFieldNames = reportMetadata.getAggregates();      
            Map<String, Reports.AggregateColumn> aggregateColumnMap = reportExtendedMetadata.getAggregateColumnInfo();
        
            //get the map of the grouping column names to their name and label
            Map<String, Reports.GroupingColumn> groupingColumnMap = reportExtendedMetadata.getGroupingColumnInfo();     
                
            // map group key to grouping column
            Map<Integer, Reports.GroupingColumn> groupInfoMap = new Map<Integer, Reports.GroupingColumn>();
            List<Reports.GroupingInfo> lstGroupingInfo = reportMetadata.getGroupingsDown();
            for (Reports.GroupingInfo info : lstGroupingInfo) {
                Reports.GroupingColumn groupingColumn = groupingColumnMap.get(info.getName());
                groupInfoMap.put(groupingColumn.getGroupingLevel(), groupingColumn);
            }

            // get Question in first dimension and Question Response in second dimension
            Map<String,Reports.ReportFact> reportFactMap = results.getFactMap();
            List<summaryReportGroup> groupList = new List<summaryReportGroup>();
            for (Reports.GroupingValue groupingValue: results.getGroupingsDown().getGroupings()) {  
                // get first level of data
                summaryReportGroup srg = createAggregateGroup(0, groupInfoMap, groupingValue, reportFactMap);
                groupList.add(srg);

                // get second level of data  (Response)            
                for (Reports.GroupingValue responseGroup : groupingValue.getGroupings()) {
                    summaryReportGroup sumRespGroup = createAggregateGroup(1, groupInfoMap, responseGroup, reportFactMap);
                    groupList.add(sumRespGroup);
                }
            }
            /* commented out by Connie. Remove Grand Total Row */
            /*Reports.ReportFactWithDetails respFactDetails = (Reports.ReportFactWithDetails) reportFactMap.get('T!T'); 
            if (respFactDetails != null) {
                List<Reports.SummaryValue> respAggregates = respFactDetails.getAggregates();
                if (respAggregates != null) {
                    if (respAggregates.get(2) != null) {
                        reportResponse.grandTotalLabel = respAggregates.get(2).getLabel();
                        Decimal grandTotal = (Decimal) respAggregates.get(2).getValue();
                        if (grandTotal > 1) {
                            reportResponse.grandTotalLabel = reportResponse.grandTotalLabel + ' ' + System.Label.LABS_SF_Records;
                        } else  {
                            reportResponse.grandTotalLabel = reportResponse.grandTotalLabel + ' ' + System.Label.LABS_SF_Record;
                        }
                        reportResponse.grandTotalLabel = '(' + reportResponse.grandTotalLabel + ')';
                    }
                }
            }*/
            srr.groupList = groupList;
    //      List<AggregateResult> lstCountUser = [select COUNT(User__c) totalUser from SurveyTaker__c where Survey__c = :surveyId];
            List<AggregateResult> lstCountUser = [select COUNT(User__c) totalUser from SurveyTaker__c where Survey__c = :surveyId and Completed__c = true];
            reportResponse.numSurveyTaker = Integer.valueOf(lstCountUser.get(0).get('totalUser'));      
            return reportResponse;
        }

        private summaryReportGroup createAggregateGroup(Integer level, Map<Integer, Reports.GroupingColumn> groupInfoMap, 
                Reports.GroupingValue responseGroup, Map<String,Reports.ReportFact> reportFactMap) {

            summaryReportGroup sumRespGroup = new summaryReportGroup();
            sumRespGroup.groupKey = responseGroup.getKey();             
            sumRespGroup.fieldName = '';
            if (groupInfoMap.containsKey(level)) {
                for (Integer i = 0; i < level; i++) {
                    sumRespGroup.fieldName = sumRespGroup.fieldName + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';   
                }
                sumRespGroup.fieldName = sumRespGroup.fieldName + groupInfoMap.get(level).getLabel();           
            }
            sumRespGroup.fieldValue = (String) responseGroup.getValue();
            sumRespGroup.fieldLabel = responseGroup.getLabel();
            sumRespGroup.recordCountLabel = '';
            sumRespGroup.percentLabel = '';

            Reports.ReportFactWithDetails respFactDetails = (Reports.ReportFactWithDetails) reportFactMap.get(sumRespGroup.groupKey+'!T');  
            List<Reports.SummaryValue> respAggregates = respFactDetails.getAggregates();
            Integer respAggregateCounter = 0;
            System.debug('level = ' + level);
            System.debug('sumRespGroup.groupKey = ' + sumRespGroup.groupKey+'!T');
            System.debug('sumRespGroup.fieldName = ' + sumRespGroup.fieldName);
            System.debug('sumRespGroup.fieldValue = ' + sumRespGroup.fieldValue);
            System.debug('sumRespGroup.fieldLabel = ' + sumRespGroup.fieldLabel);
            if (respAggregates != null) {
                for (Reports.SummaryValue respAggregate : respAggregates) {
                    if (respAggregateCounter != null) {
                        // number of people chosen
                        if (respAggregateCounter == 0) {
                            if (respAggregate != null) {
                                sumRespGroup.numPersonChosen = respAggregate.getLabel();
                                System.debug('sumRespGroup.numPersonChosen = ' + sumRespGroup.numPersonChosen);
                            }
                        }
                         // total
                        if (respAggregateCounter == 1) {
                            if (respAggregate != null) {
                                sumRespGroup.total = respAggregate.getLabel();
                                System.debug('sumRespGroup.total = ' + sumRespGroup.total);
                            }
                        }
                        // row count
                        if (respAggregateCounter == 2) {
                            if (respAggregate != null) {
                                sumRespGroup.recordCountLabel = respAggregate.getLabel();
                                Decimal recordCount = (Decimal)(respAggregate.getValue());
                                if (recordCount > 1) {
                                    sumRespGroup.recordCountLabel = sumRespGroup.recordCountLabel + ' ' + System.Label.LABS_SF_Records;
                                } else {
                                    sumRespGroup.recordCountLabel = sumRespGroup.recordCountLabel + ' ' + System.Label.LABS_SF_Record;
                                }
                                sumRespGroup.recordCountLabel = '(' + sumRespGroup.recordCountLabel + ')';
                                System.debug('sumRespGroup.recordCountLabel = ' + sumRespGroup.recordCountLabel);
                            }
                        }
                    }
                    respAggregateCounter++;
                }
            }
            return sumRespGroup;
        }

        // generate survey filename by concatenating survey name and timestamp
        public String surveyResultFilename { 
            get { 
                Survey__c mySurveyObj = [Select Name from Survey__c where id = :surveyId];
                String surveyFilename = 'SurveyResult';
                if (mySurveyObj != null && String.isNotBlank(mySurveyObj.Name)) {
                    surveyFilename = String.join(mySurveyObj.Name.split(' '), '_');                
                    surveyFilename = replaceSpecialChar(surveyFilename, '');
                    surveyFilename = surveyFilename.equals('') ? 'Survey' : surveyFilename;
                }
                string currDateTime = Datetime.now().format('yyyyMMddHHmmss');
                surveyFilename = surveyFilename + '_' + currDateTime + '.' + extension;
                
                System.debug('surveyResultFilename = ' + surveyFilename); 
                return surveyFilename;
            }   
        }

        private String replaceSpecialChar(String str, string replace){
            str = str.replaceAll('[|,|.|\\,||"||:|~|!|@|`|#|$|%|^|&|*|_|+|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '');
            str = str.replace('/', '');
            str = str.replace('\\', '');        
            return str;
        }

        public String surveyName { 
            get { 
                Survey__c mySurveyObj = [Select Name from Survey__c where id = :surveyId];
                return mySurveyObj.Name;
            }   
        }

        // added by Connie. Create data for export to file purpose
        private exportDataResponse getExportDataResponse() {

            exportDataResponse expResponse = new exportDataResponse();

            Survey__c anonymousSurvey = [SELECT Allow_Anonymous__c From Survey__c Where Survey__c.id = :surveyId ];
            List<SurveyQuestionResponse__c> lstSurveyResponses = 
                    [SELECT Survey_Question__r.Survey__r.Name, Survey_Question__r.Name, Other_Response__c, Response__c, Survey_Question__r.Total_Responses__c, 
                            Survey_Question__r.Required__c, SurveyTaker__r.User__r.Name,
                            Survey_Question__r.OrderNumber__c, Survey_Question__r.Survey__r.CreatedDate,
                            SurveyTaker__r.LastModifiedDate, Survey_Question__r.Survey__r.Allow_Anonymous__c,
                            Survey_Question__r.Total_Completed_Responses__c
                     From SurveyQuestionResponse__c
                     Where Survey_Question__r.Survey__r.id = :surveyId and SurveyTaker__r.Completed__c = true
                     Order By Survey_Question__r.OrderNumber__c];

            if (anonymousSurvey.Allow_Anonymous__c) {
                expResponse.takerNameColumnName = '';
            } else {
                expResponse.takerNameColumnName = 'Taker Name';
            }        
            List<exportData> exportDataList = new List<exportData>();
            for (SurveyQuestionResponse__c obj : lstSurveyResponses) {
                exportData data = new exportData();
                exportDataList.add(data);
                data.surveyName =  obj.Survey_Question__r.Survey__r.Name;
                data.questionNumber = obj.Survey_Question__r.OrderNumber__c;
                data.question = obj.Survey_Question__r.Name;
                data.response = obj.Response__c;
                data.otherresponse=obj.Other_Response__c;//add by L
                data.totalResponse = obj.Survey_Question__r.Total_Completed_Responses__c;
                data.required = obj.Survey_Question__r.Required__c;
                if (anonymousSurvey.Allow_Anonymous__c) {
                    data.takerName = '';
                } else {
                    data.takerName = obj.SurveyTaker__r.User__r.Name;
                }
                data.surveyCreatedTime = obj.Survey_Question__r.Survey__r.CreatedDate.format();
                data.surveyTakenTime = obj.SurveyTaker__r.LastModifiedDate.format();
                System.debug('data.surveyName = ' + data.surveyName);
                System.debug('data.questionNumber = ' + data.questionNumber);
                System.debug('data.otherresponse = ' + data.otherresponse);
                System.debug('data.question = ' + data.question);
                System.debug('data.response = ' + data.response);   
                System.debug('data.totalResponse = ' + data.totalResponse);
                System.debug('data.required = ' + data.required);
                System.debug('data.takerName = ' + data.takerName);
                System.debug('data.surveyCreatedTime = ' + data.surveyCreatedTime);
                System.debug('data.surveyTakenTime = ' + data.surveyTakenTime);
            }
            expResponse.exportDataList = exportDataList;
            return expResponse;
        }

        // added by Connie. Export survey taker who has not completed the survey 
        public Integer numLateTakers {
            get {
                if(isPublic=='P')
                {
                    return SurveyGroupSearchUtil.getNumLateTakers(surveyId);
                }
                else
                {
                    if(reportResponse==null ||reportResponse.numSurveyTaker==null)
                    {
                        return getGroupMemberTotal();
                    }
                    return getGroupMemberTotal()-reportResponse.numSurveyTaker;
                }
                
            }
        }

        public String surveyLateTakerResult { 
            get { 
                String result = '';
                // construct csv string 
                result = '"Email","Display Name"\n';
                List<User> lstUsers = SurveyGroupSearchUtil.searchLateSurveyTaker(surveyId);            
                for (User user : lstUsers) {
                    String userEmail = String.IsNotBlank(user.Email) ? user.Email.trim() : '';
                    String displayName = String.IsNotBlank(user.Name_Display__c) ? user.Name_Display__c.trim() : '';
                    result += '"' + userEmail + '","' + displayName + '"\n';  
                }

                return result;
            }
        }
        public String surveyLateTakerFilename { 
            get { 
                Survey__c mySurveyObj = [Select Name from Survey__c where id = :surveyId];
                String surveyFilename = '';
                if (mySurveyObj != null && String.isNotBlank(mySurveyObj.Name)) {
                    surveyFilename = String.join(mySurveyObj.Name.split(' '), '_');
                }
                surveyFilename += '_SurveyLateTaker';
                string currDateTime = Datetime.now().format('yyyyMMddHHmmss');
                surveyFilename = surveyFilename + '_' + currDateTime + '.' + extension;
                System.debug('surveyLateTakerFilename = ' + surveyFilename);
                return surveyFilename;
            }
        }
        // end 

        // Added by Connie. Method to send reminder emails to user
        public void sendReminderEmail() {
            SurveySettings__c globalSetting = SurveySettings__c.getValues('global');
            Decimal maxThreshold = globalSetting.ReminderEmailThreshold__c;
            List<User> lstUsers = SurveyGroupSearchUtil.searchLateSurveyTaker(surveyId);    
                     

            // if (lstUsers.size() < maxThreshold) {
            if (numLateTakers< maxThreshold) {
                EmailTemplate emailTemplate = [SELECT Id From EmailTemplate 
                                                where DeveloperName = 'Survey_Reminder_Email_Template1' limit 1];
                // create survey email queue object to send reminder email
                List<Survey_Email_Queue__c> ll = new List<Survey_Email_Queue__c>();
                for (User user : lstUsers) {
                    Survey_Email_Queue__c seq = new Survey_Email_Queue__c();
                    seq.Survey_Email_Scheduled_Sent_Date__c = DateTime.Now().date();
                    seq.Survey_Email_Sent__c = true;
                    seq.Survey_Notify_User__c = user.Id;
                    seq.Survey__c = surveyId;           
                    seq.Survey_Email_Type__c = 'Reminder';  
                    ll.add(seq);

                    System.debug('sent date: ' + seq.Survey_Email_Scheduled_Sent_Date__c + ', sent: '
                        + seq.Survey_Email_Sent__c + ', notify user id: ' + 
                        seq.Survey_Notify_User__c + ', survey id: ' + seq.Survey__c);
                }
                Boolean hasError = false;
                Survey__c survey = [Select Id From Survey__c where Id = :surveyId limit 1];
                List<Database.SaveResult> dsr = Database.insert(ll, false);
                Integer i = 0;
                for (Database.SaveResult result : dsr) {
                    if (!result.isSuccess()) {
                        Database.Error err = result.getErrors()[0];
                        survey.addError('Unable to send reminder email due to following exception: '
                               + err.getMessage());
                        hasError = true;
                    } else {
                        System.debug('No error in record: ' + i);
                    }
                    i++;
                }
                if (!hasError) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                        'Survey reminder emails are sent.'));
                }
            } else {
                List<String> parameters = new List<String>();
                parameters.add(String.valueOf(Integer.valueOf(maxThreshold)));
                String errMsg = String.format(System.Label.LABS_SF_ExceedSurveyReminderEmailThreshold, parameters);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, errMsg));
            }   
        }

        /*Add by DTT Support Team*/
        public Integer getGroupMemberTotal()
        {
            Set <String> allUsers=new Set<String>();
            if(isPublic=='P')
            {
                // return SurveyGroupSearchUtil.getNumLateTakers(surveyId)+reportResponse.numSurveyTaker;
                
               Integer returnInt=SurveyAssignmentObjectUtil.getTotalSurveyAssignment(surveyId, SurveyAssignmentObjectUtil.TAKER);
               if(returnInt==null)
               {
                return 0;
               }

               return returnInt;
               
            }
         
            String theGroupID=[select id,DeveloperName from Group where DeveloperName =:sharingGroupName limit 1].id;
            List <GroupMember> memberLIst=[select id,UserorGroupId from GroupMember where groupid=:theGroupID];
            List<String> GroupIDL=new List<String>();
            for(GroupMember reader:memberLIst)
            {
                GroupIDL.add(reader.UserOrGroupId);
            }
            for(GroupMember reader:[select id,UserorGroupId from GroupMember where groupid in:GroupIDL])
            {
                allUsers.add(reader.UserorGroupId);
            }
            if(allUsers==null)
            {
                return 0;
            }
            else
            {
                return allUsers.size();
            }
        }
    }