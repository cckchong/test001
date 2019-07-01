@isTest
public class TestUtil {

    public static testMethod User getTestSystemAdminUser() {
        // It's fair to assume that there is at least one sys admin user in an org as this is enforced for all Salesforce org.
        return [Select Id, ProfileId, Username, Profile.Name from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
    }
        
    public static testMethod User getTestACGSystemAdminUser() {
        String USER_GLOBAL = 'Far East';
        String USER_REGION = 'CORP';
        String USER_LOCAL = 'TAL';
        String USER_GRADE = '21';
        String USER_DEPT = 'IT';
        String USER_FUNCTION = '';
        String USER_LANG = 'en';
        String USER_ADMIN_REGION = 'Far East;CORP;TAL';
        String USER_ADMIN_DEPT = 'IT;HKHCM';
        Boolean USER_CREATE_PAGE = true;      
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 15) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
            randStr += chars.substring(idx, idx+1);
        }
        String testEmail = 'test' + randStr + '@testy.salesforce.com';
        User u = new User(  Alias = 'standt', Email=testEmail, 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName= testEmail, 
                            Location_Global__c=USER_GLOBAL, 
                            Location_Region__c=USER_REGION,
                            Location_Local__c=USER_LOCAL,
                            Grade__c=USER_GRADE,
                            Department__c=USER_DEPT,
                            Function__c=USER_FUNCTION,
                            Portal_Language__c=USER_LANG,
                            Administrative_Regions__c=USER_ADMIN_REGION,
                            Administrative_Department__c=USER_ADMIN_DEPT,
                            Create_Portal_Page__c=USER_CREATE_PAGE
                            );
        return u;        
    }
    
    public static testMethod Portal_Content__c getAnnouncement() {
        RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Rich_Text' limit 1];
        Portal_Content__c announcement = new Portal_Content__c(
        RecordTypeId = rt.Id
        , Category__c = 'Local'
        , Sub_Category__c = 'TAL'
        , BU__c = 'IT'
        , Expiry_Date__c = date.today()+30 
        , Share_to_Group__c = true
        , Status__c = 'Published'
        , Distribution_Grade__c ='ALL'
        , Language__c = 'en'
        //Content
        , Title_en__c = 'Sample Title', Title_zhhk__c = 'Sample Traditional Chinese Title'//, Title_zhcn__c, Title_th__c, Title_vi__c, Title_id__c
        , Summary_en__c = 'Sample Summary', Summary_zhhk__c = 'Sample Traditional Chinese Summary'//, Summary_zhcn__c, Summary_th__c, Summary_vi__c, Summary_id__c
        , Contents_en__c = 'Sample Content', Contents_zhhk__c = 'Sample Traditional Chinese Content'//, Contents_zhcn__c, Contents_th__c, Contents_vi__c, Contents_id__c
        , Revised_en__c = false, Revised_zhhk__c = true //, Revised_zhcn__c, Revised_th__c, Revised_vi__c, Revised_id__c
        );
        return announcement;
    }
    
    public static testMethod Portal_Content__c getTemplate() {
        RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'template' limit 1];
        Portal_Content__c template = new Portal_Content__c(
        RecordTypeId = rt.Id
        , Template_Name__c = 'MainTemplate1_Left'
        , Tech_Total_Component__c = 6
        );
        return template;
    }
    
    public static testMethod Portal_Content__c getSettings() {
        RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Settings' limit 1];
        Portal_Content__c setting = new Portal_Content__c(
        RecordTypeId = rt.Id
        , Page_Name__c = 'MainPage'
        , Category__c = 'Local'
        , Sub_Category__c = 'TAL'
        , BU__c = 'IT'
        );
        return setting;
    }
    
    public static testMethod Portal_Content__c getHTML() {
        RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'html' limit 1];
        Portal_Content__c html = new Portal_Content__c(
        RecordTypeId = rt.Id
        , Contents__c = 'HTML Contents'
        );
        return html;
    }
    
    public static testMethod Portal_Content__c getVideo() {
        RecordType rt = [Select Id, Name From RecordType Where DeveloperName = 'Video' limit 1];
        Portal_Content__c video = new Portal_Content__c(
        RecordTypeId = rt.Id
        , Contents__c = 'Video'
        , HTML__c = '<iframe width="420" height="315" src="//www.youtube.com/embed/r6hxqg3PgRQ" frameborder="0" allowfullscreen></iframe>'
        );
        return video;
    }
    
    public static testMethod List<DepartmentSetting__c> getDepartmentSettings() {
        List<DepartmentSetting__c> returnList = new list<DepartmentSetting__c>();
        DepartmentSetting__c dept1 = new DepartmentSetting__c(
                                        Name = 'IT'
                                        ,Department__c = 'IT'
                                        ,Local_Site__c = 'TAL'
                                        ,Department_Full_Name__c = 'Information Technology'
                                        );
        DepartmentSetting__c dept2 = new DepartmentSetting__c(
                                        Name = 'HKHCM'
                                        ,Department__c = 'HKHCM'
                                        ,Local_Site__c = 'TAL'
                                        ,Department_Full_Name__c = 'HK Human Capital Management'
                                        );
        returnList.add(dept1);
        returnList.add(dept2);
        return returnList;
    }
    
    public static testMethod List<SiteSetting__c> getSiteSettings() {
        List<SiteSetting__c> returnList = new list<SiteSetting__c>();
        SiteSetting__c site1 = new SiteSetting__c(
                                        Name = 'TAL'
                                        ,Global__c = 'Far East'
                                        ,Regional__c = 'CORP'
                                        );
        SiteSetting__c site2 = new SiteSetting__c(
                                        Name = 'CORP'
                                        ,Global__c = 'Far East'
                                        ,Regional__c = null
                                        );
        returnList.add(site1);
        returnList.add(site2);
        return returnList;
    }
    
    public static testMethod CollaborationGroup getChatterGroup() {
        CollaborationGroup chatterGroupNoPost = new CollaborationGroup(
            CollaborationType='Public',
            OwnerId = UserInfo.getUserId());
        return chatterGroupNoPost;
    }
            
    
    public static testMethod FeedItem getChatterPhoto() {
        FeedItem chatterPhoto = new FeedItem(            
            ContentFileName='kittens.jpg',
            ContentData=EncodingUtil.base64Decode('fluffykittens')
        );
        return chatterPhoto;
    }

    public static testMethod FeedItem getChatterFile() {
        FeedItem chatterFile = new FeedItem(            
            ContentFileName='kittens.pdf',
            ContentData=EncodingUtil.base64Decode('fluffykittens')
        );
        return chatterFile;
    }
    
    public static testMethod FeedItem getChatterTextPost() {
        FeedItem textPost = new FeedItem(            
            Title='Hello',
            Body='World'
        );
        return textPost;
    }
    
    public static testMethod String generateRandomString() {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 20) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), 62);
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
    
    /*
    public static testMethod Map<String,Schema.RecordTypeInfo> getPortalContentRecordType(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Portal_Content__c; 
        Map<String,Schema.RecordTypeInfo> PortalContentRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        return PortalContentRecordTypeInfo;
    }
    */
    
}