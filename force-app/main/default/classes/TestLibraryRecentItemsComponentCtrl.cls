/**
 * Test for LibraryRecentItemsComponentCtrl
 */
@isTest
public class TestLibraryRecentItemsComponentCtrl {
    static testMethod void myUnitTest(){
        
        Library_Item__c  li = LibraryTestDataUtility.insertLibItem('Book');
        li.Can_Be_Borrowed__c =true;
        update li;
        FeedItem fi = LibraryTestDataUtility.createFeeds(li.id);
        
        LibraryRecentItemsComponentCtrl lric = new LibraryRecentItemsComponentCtrl();
        lric.recordTypeName = 'Book';
        String recordTypeName = lric.recordTypeName;
        Integer numItems = lric.numItems;
        lric.itemToPhotoMap = new Map<String, Attachment>();
        Map<String, Attachment> itemToPhotoMap = lric.itemToPhotoMap;
        
        
        List<Library_Item__c> itemList = lric.itemList;
        Map<Id, Integer> libraryItemToFeedMap = lric.libraryItemToFeedMap ;
        
        system.assertEquals(lric.isSalesforceOne,false);
        
        lric.getList();
        
        lric.getMostBorrowedList();
        
        
    }
}