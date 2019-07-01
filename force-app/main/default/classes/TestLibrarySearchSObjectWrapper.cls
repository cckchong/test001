/**
 * Test for SearchSObjectWrapper
 */
@isTest
public class TestLibrarySearchSObjectWrapper {

    static testMethod void myUnitTest(){
        SearchSObjectWrapper sow = new SearchSObjectWrapper('Library_Item__c');
        
        sow.getLibraryItem();
        
        System.assertNotEquals(sow.obj, null);
        sow = new SearchSObjectWrapper('Library_Inventory__c');
        sow.clear();
        
        LibraryDateWrapper ldw = new LibraryDateWrapper(System.today(),System.today());
        System.assertEquals(ldw.proxy.Tech_Start_Date_Proxy__c,ldw.proxy.Tech_End_Date_Proxy__c);
        
        ldw = new LibraryDateWrapper();
        ldw.proxy.Tech_Start_Date_Proxy__c = System.today();
        ldw.proxy.Tech_End_Date_Proxy__c= System.today();
        System.assertEquals(ldw.proxy.Tech_Start_Date_Proxy__c,ldw.proxy.Tech_End_Date_Proxy__c);
        
        
        LibraryNumberWrapper lnw1 = new LibraryNumberWrapper();
        lnw1 .min = 1.5;
        lnw1 .max = 2.5;
        System.assertEquals(lnw1 .min, 1.5);
        System.assertEquals(lnw1 .max, 2.5);
        
        lnw1 = new LibraryNumberWrapper(Double.valueOf(2.55555), Double.valueOf(2.55555));
        System.assertEquals(lnw1 .min, lnw1 .max);
        
        MultiSelectWrapper msw = new MultiSelectWrapper();
        List<SelectOption> selectOptions = new List<SelectOption>();
        selectOptions.add(new SelectOption('abc','abc'));
        selectOptions.add(new SelectOption('abc1','abc1'));
        msw = new MultiSelectWrapper(selectOptions);
        
        List<String> optionValues = new List<String>();
        optionValues.add('abc');
        optionValues.add('abc1');
        msw = new MultiSelectWrapper(optionValues);
    }
}