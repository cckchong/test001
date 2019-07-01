/**
 * Test for MultiSelectWrapper
 */
@isTest
public class TestLibraryMultiSelectWrapper {

    static testMethod void myUnitTest(){
    
        MultiSelectWrapper msw = new MultiSelectWrapper();
        List<SelectOption> selectOptions = SystemUtil.availRecordTypesSO('Library_Item__c');
        
        system.assertNotEquals(selectOptions, null);
        
        msw = new MultiSelectWrapper(selectOptions);
        
        List<String> strList = new List<String>();
        strList.add('a');
        strList.add('b');
        
        msw = new MultiSelectWrapper(strList);
        
        Schema.DescribeFieldResult F = Account.Industry.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        
        msw = new MultiSelectWrapper(P);
        
    }
}