@isTest
public class TestLibraryItemPageHitRateExtension {
    
    public static String TARGET_FUNCTION = Label.Library_Hit_Rate_Target_Function;

    @isTest
    public static void testMyController() {
    
            User currentUser = [SELECT Id, Function_Short__c FROM User Where Id = :UserInfo.getUserId()];
            currentUser.Function_Short__c = TARGET_FUNCTION;
            update currentUser;
            Library_Item__c item = LibraryTestDataUtility.insertLibItem(Label.Library_RecordType_Fabric);
            
            ApexPages.StandardController sc = new ApexPages.StandardController(item);        
            LibraryItemPageHitRateExtension ext = new LibraryItemPageHitRateExtension(sc);
            
            ext.updateCounter();
          
    }
}