/*
* Test Class of LibraryDateWrapper
*/
@isTest
public class TestLibraryDateWrapper{
    
      @isTest
    public static void doTestDateWrapper() {
        
        LibraryDateWrapper ldw = new LibraryDateWrapper(System.today(),System.today());
        System.assertEquals(ldw.proxy.Tech_Start_Date_Proxy__c,ldw.proxy.Tech_End_Date_Proxy__c);
        
        ldw = new LibraryDateWrapper();
        ldw.proxy.Tech_Start_Date_Proxy__c = System.today();
        ldw.proxy.Tech_End_Date_Proxy__c= System.today();
        System.assertEquals(ldw.proxy.Tech_Start_Date_Proxy__c,ldw.proxy.Tech_End_Date_Proxy__c);
        
    }
}