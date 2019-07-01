@isTest
public with sharing class TestEleaveFeedTriggerHandler
{    
    public static Map<String, User> UserMap ;
    public static Map<String, Employee__c> EmployeeMap ;
    public static Map <String, Leave_Type__c> LeaveTypeMap;     
    public static TestEleavePreparation  EleavePreparation; 
    public static String stringLeaveStartTime;
    public static String stringLeaveEndTime ;
    
    public static void Preparation(Boolean isSeeAllData) {
         EleavePreparation = new TestEleavePreparation (isSeeAllData);
         UserMap = EleavePreparation.getUserMap();
         EmployeeMap = EleavePreparation.getEmployeeMap(UserMap);
         EleavePreparation.setleaveBalanceList (EmployeeMap.values());
         stringLeaveStartTime = '';
         stringLeaveEndTime  = '';
         for ( Leave_Available_Time__c reader : EleavePreparation.LeaveAvailableTimeMap.values() ){
             if ( stringLeaveStartTime == '' ){             
                 stringLeaveStartTime = reader.id;
             }
             stringLeaveEndTime = reader.id;
         }
    }
     
    public static EleaveController  eLeaveCreation () {
        EleaveController eleaveCtrl = new EleaveController(); 
        LeaveTypeMap = EleavePreparation.LeaveTypeMap;
        List < LeaveSection > leaveSectionList  = eleaveCtrl.ListLeaveSection;
          
        for ( LeaveSection reader : leaveSectionList ){
             reader.leavetransaction.Leave_Type__c = LeaveTypeMap.get( 'HKO Annual LeaveT' ).id;                 
             reader.leavetransaction.From_Date__c = Date.newInstance(2015, 3, 15);
             reader.leavetransaction.To_Date__c = Date.newInstance(2015, 3, 21);
             reader.stringLeaveStartTime = stringLeaveStartTime;
             reader.stringLeaveEndTime = stringLeaveEndTime;
        } 
         
        for ( LeaveSection reader : leaveSectionList ) {
             reader.changeLeaveType();
        }
        return eleaveCtrl;
    }
    
    @IsTest
    public static void createFeedItemAndComment() {        
        Id leaveRequestId = null;
        Leave_Request__c lr = null;
        Preparation(false);         
        System.runAs(UserMap.get('user1')) {
            EleaveController eleaveCtrl = eLeaveCreation();
            
            eleaveCtrl.saveAction();             
            eleaveCtrl = new EleaveController(eleaveCtrl.request.id);
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                system.assertNotEquals(null, reader.leavetransaction.id );
                leaveRequestId = reader.leavetransaction.id;                
            }
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(0, lr.Tech_Supporting_Doc_Counter__c);
            Test.startTest(); 
            FeedItem fi = new FeedItem ( 
                ParentId = leaveRequestId ,
                Type = 'ContentPost',
                ContentFileName = 'ContentPost',
                ContentData = Blob.valueOf('Unit Test Attachment Body')
                
            );
            insert fi;  
            system.assertNotEquals(null, fi.id );
            
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(1, lr.Tech_Supporting_Doc_Counter__c);
            
            FeedComment fc = new FeedComment (
                CommentType = 'ContentComment',
                FeedItemId = fi.id,
                CommentBody = 'comment'
                
            );
            insert fc;
            system.assertNotEquals(null, fc.id );
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(2, lr.Tech_Supporting_Doc_Counter__c);
            Test.stopTest();
        }        
    }
    
    
    @IsTest
    public static void deleteFeedItemAndComment() {        
        Id leaveRequestId = null;
        Leave_Request__c lr = null;
        Preparation(false);         
        System.runAs(UserMap.get('user1')) {
            EleaveController eleaveCtrl = eLeaveCreation();
            
            eleaveCtrl.saveAction();             
            eleaveCtrl = new EleaveController(eleaveCtrl.request.id);
            for ( LeaveSection reader : eleaveCtrl.ListLeaveSection) {
                system.assertNotEquals(null, reader.leavetransaction.id );
                leaveRequestId = reader.leavetransaction.id;
            }
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(0, lr.Tech_Supporting_Doc_Counter__c);
            /*
            FeedItem fi = new FeedItem ( 
                ParentId = leaveRequestId ,
                Type = 'ContentPost',
                ContentFileName = 'ContentPost',
                ContentData = Blob.valueOf('Unit Test Attachment Body')
            );
            insert fi;  
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(1, lr.Tech_Supporting_Doc_Counter__c);
            Test.startTest(); 
           
            
            FeedComment fc = new FeedComment (
                CommentType = 'ContentComment',
                FeedItemId = fi.id,
                CommentBody = 'comment'
                
            );
            insert fc;
            lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            system.assertEquals(2, lr.Tech_Supporting_Doc_Counter__c);
            */
            //FeedComment fc1 = new FeedComment (
            //    CommentType = 'ContentComment',
            //    FeedItemId = fi.id,
            //    CommentBody = 'comment'
            //    
            //);
            
            //insert fc1;
            //lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            //system.assertEquals(3, lr.Tech_Supporting_Doc_Counter__c);
            
            //delete fc1;
            //lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            //system.assertEquals(2, lr.Tech_Supporting_Doc_Counter__c);
            //delete fi;
            //lr = [select id, Tech_Supporting_Doc_Counter__c from Leave_Request__c where id = :leaveRequestId ];
            //system.assertEquals(0, lr.Tech_Supporting_Doc_Counter__c);
            //Test.stopTest();
        }
        
    }
    
}