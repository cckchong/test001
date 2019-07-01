@IsTest
public class TestMobileReceiptInboxCtrl {

    public static Mobile_Receipt_Inbox__c ri1;
    public static Mobile_Receipt_Inbox__c ri2;
    public static FeedItem fi;
    
    
    public static TestTEExpenseApplication TEExpenseApplication;    
    public static Map<String, Travel_Location__c> travelLocationMap;
    public static employee__c employee;
    public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    public static String userName = 'user1';
    
    public static void preparation(){
        TestTEExpenseApplicationCtrl.preparation(false);
        TEExpenseApplication = TestTEExpenseApplicationCtrl.TEExpenseApplication;
        travelLocationMap = TestTEExpenseApplicationCtrl.travelLocationMap;
        employee = TestTEExpenseApplicationCtrl.employee;
        EmployeeAdministrator = TestTEExpenseApplicationCtrl.EmployeeAdministrator;
    }
    
    public static void prepareMobileInbox() {
        // Inbox
        ri1 = new Mobile_Receipt_Inbox__c();
        insert ri1;
        
        ri2 = new Mobile_Receipt_Inbox__c();
        insert ri2;
        
        // Custom Setting
        DMS_Settings__c dms = new DMS_Settings__c();
        dms.Name = 'manager_user';
        dms.Value__c = 'abc';
        insert dms;
        
        // Content Version
        ContentVersion cv = new ContentVersion();
        cv.PathOnClient = 'my_receipt';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        cv.VersionData = bodyBlob;
        cv.Title = 'my_receipt';
        cv.Origin = 'H';
        insert cv;
        
        List<ContentVersion> cvRequeried = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id];
        
        // Feed Item
        fi = new FeedItem(
            Type = 'ContentPost',
            Title = 'My Receipt',
            Body = 'Thailand Trip',
            RelatedRecordId = cv.Id,
            ParentId = ri1.Id
        );
        
        insert fi;
    }
    
    
    @IsTest
    public static void testExecuteCore() {

        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation();
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            prepareMobileInbox();
            
            ta = TestTEExpenseApplicationCtrl.ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            
            System.assertNotEquals(null, edl);
            System.assertNotEquals(null, edl.expenseDetail);
            System.assertNotEquals(null, edl.expenseDetail.Id);
            
            System.assertNotEquals(null, MobileReceiptInboxCtrl.getMobileReceiptInbox());
            System.assertNotEquals(null, MobileReceiptInboxCtrl.getFeedItems());
            System.assertNotEquals(null, MobileReceiptInboxCtrl.getMyMobileReceiptInbox());
            System.assertNotEquals(null, MobileReceiptInboxCtrl.getExpenseDetails());
            System.assertNotEquals(null, MobileReceiptInboxCtrl.getExpenseDetailsFeedItems());
            System.assertNotEquals(null, MobileReceiptInboxCtrl.setParentId(fi.Id, ri2.Id));
        }

    }
    
    @IsTest
    public static void testExecuteRedirectionCtrl() {
        Mobile_Receipt_Inbox__c ri = new Mobile_Receipt_Inbox__c();
        insert ri;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ri);
        TEMobileReceiptInboxViewCtrl ctrl = new TEMobileReceiptInboxViewCtrl(sc);
        
        PageReference result = ctrl.SendAction();
        
        System.assertNotEquals(null, result);
        
        delete ri;
        
        PageReference result2 = ctrl.SendAction();
        System.assertNotEquals(null, result);
    }
}