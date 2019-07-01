@isTest(SeeAllData=true)
private class TestRemoveFeedPageExtension {

    private static void insertTextPost(Integer numberOfRecords) {
        List<FeedItem> feedItems = new List<FeedItem>();
        for (Integer i = 0; i < numberOfRecords ; i++) {
            FeedItem f = new FeedItem();
            f.createdById = UserInfo.getUserId();
            f.parentId = UserInfo.getUserId();
            f.Type = 'TextPost';
            f.body = 'testing! testing! ' + String.valueOf(i);
            
            feedItems.add(f);
        }
        
        insert feedItems;
        
    }

    /*
        Test controller functionality
        
        It first clear all FeedItems on 'TextPost' with current userId, then insert 2*recordsPerPage records.
        Therefore, there will be 2 pages only.
        
    */ 
    static testMethod void testControllerExtension() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        // insert test data
        Integer recordsPerPage = RemoveFeedPageExtension.RECORDS_PER_PAGE;
        insertTextPost(2 * recordsPerPage);
    
        // performs search
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        System.assertEquals(0, e.selectedCount);
        e.feedItem.Type = 'TextPost';
        e.fromTime = Datetime.now().addMinutes(-5);
        e.toTime = Datetime.now();
        e.search();
        
        // assert search
        System.assertEquals(2 * recordsPerPage, e.feedItems.size());
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(0, e.currentPage);
        System.assertEquals(e.feedItems.size(), e.resultCount);
        
        // unselect all
        e.isSelectAll = false;
        e.onSelectAll();
        System.assertEquals(0, e.selectedCount);
        
        // select all
        e.isSelectAll = true;
        e.onSelectAll();
        System.assertEquals(e.resultCount, e.selectedCount);
        
        // test delete
        e.deleteFeed();
        List<FeedItem> feedsAfterDel = [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
        System.assert(feedsAfterDel == null || feedsAfterDel.isEmpty());
        System.assertEquals(0, e.currentPage);
        System.assertEquals(0, e.feedItems.size());
        System.assertEquals(0, e.listWindow.size());
        
    }
    
    /*
        Test controller's listWindow(Divisible) by turning pages
    */
    static testMethod void testListWindowDivisible() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        /*------------ Test records divisible 3x ----------------- */
        // insert test data
        Integer recordsPerPage = RemoveFeedPageExtension.RECORDS_PER_PAGE;
        Integer numberOfRecords = 3 * recordsPerPage;
        insertTextPost(numberOfRecords);
        
        // performs search
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        System.assertEquals(0, e.selectedCount);
        e.feedItem.Type = 'TextPost';
        e.search();
        
        // assert search, at page 0
        System.assertEquals(numberOfRecords, e.feedItems.size());
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(0, e.currentPage);
        System.assertEquals(e.feedItems.size(), e.resultCount);
        System.assertEquals(false, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.getFirstRecordNumber());
        System.assertEquals(recordsPerPage, e.getLastRecordNumber());
        
        // turn to page 1
        e.next();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(2 * recordsPerPage, e.getLastRecordNumber());
        
        // turn to page 2
        e.next();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(false, e.getHasNext());
        System.assertEquals(2, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(2 * recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(numberOfRecords, e.getLastRecordNumber());
        
        // back to page 1
        e.previous();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(2 * recordsPerPage, e.getLastRecordNumber());
        
        // back to page 0
        e.previous();
        System.assertEquals(0, e.currentPage);
        System.assertEquals(false, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(1, e.getFirstRecordNumber());
        System.assertEquals(recordsPerPage, e.getLastRecordNumber());
        
    }
    
    /*
        Test controller's listWindow(Not Divisible) by turning pages
    */
    static testMethod void testListWindowNotDivisible() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        /*------------ Test records divisible 3x + 3 ----------------- */
        // insert test data
        Integer recordsPerPage = RemoveFeedPageExtension.RECORDS_PER_PAGE;
        Integer numberOfRecords = 3 * recordsPerPage + 3;
        insertTextPost(numberOfRecords);
        
        // performs search
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        System.assertEquals(0, e.selectedCount);
        e.feedItem.Type = 'TextPost';
        e.search();
        
        // assert search, at page 0
        System.assertEquals(numberOfRecords, e.feedItems.size());
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(0, e.currentPage);
        System.assertEquals(e.feedItems.size(), e.resultCount);
        System.assertEquals(false, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.getFirstRecordNumber());
        System.assertEquals(recordsPerPage, e.getLastRecordNumber());
        
        // turn to page 1
        e.next();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(2 * recordsPerPage, e.getLastRecordNumber());
        
        // turn to page 2
        e.next();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(2, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(2 * recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(3 * recordsPerPage, e.getLastRecordNumber());
        
        // turn to page 3
        e.next();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(false, e.getHasNext());
        System.assertEquals(3, e.currentPage);
        System.assertEquals(3, e.listWindow.size());
        System.assertEquals(3 * recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(numberOfRecords, e.getLastRecordNumber());
        
        // back to page 2
        e.previous();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(2, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(2 * recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(3 * recordsPerPage, e.getLastRecordNumber());
        
        // back to page 1
        e.previous();
        System.assertEquals(true, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(1, e.currentPage);
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(recordsPerPage + 1, e.getFirstRecordNumber());
        System.assertEquals(2 * recordsPerPage, e.getLastRecordNumber());
        
        // back to page 0
        e.previous();
        System.assertEquals(0, e.currentPage);
        System.assertEquals(false, e.getHasPrevious());
        System.assertEquals(true, e.getHasNext());
        System.assertEquals(recordsPerPage, e.listWindow.size());
        System.assertEquals(1, e.getFirstRecordNumber());
        System.assertEquals(recordsPerPage, e.getLastRecordNumber());
        
    }
    
    /* Test Limit */
    static testMethod void testListLimit() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        // insert test data
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        Integer listLimit = e.getLIST_LIMIT();
        insertTextPost(listLimit + 1);
        
        // performs search
        System.assertEquals(0, e.selectedCount);
        e.feedItem.Type = 'TextPost';
        e.search();
        
        // assert search
        System.assertEquals(listLimit, e.feedItems.size());
    
    }
    
    /* test delete error */
    static testMethod void testDeleteError() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        // insert test data
        insertTextPost(1);
        
        // performs search
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        e.feedItem.Type = 'TextPost';
        e.search();
        
        // assert search
        System.assertEquals(1, e.feedItems.size());
        
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
        
        // select all
        e.isSelectAll = true;
        e.onSelectAll();
        System.assertEquals(1, e.selectedCount);
        
        // test delete
        e.deleteFeed();
        System.assert(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty());
        System.assertEquals(0, e.currentPage);
        System.assertEquals(0, e.feedItems.size());
        System.assertEquals(0, e.listWindow.size());
        
    }
    
    /* test wrong user Id */
    static testMethod void testWrongUserId() {
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        // insert test data
        insertTextPost(1);
        
        // performs search
        RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
        e.feedItem.Type = 'TextPost';
        e.createdById = 'hello! yeah~';
        e.search();
        
        // assert error is shown in page
        System.assert(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty());
    
    }
    
    /* test no permission right to view feed */
    static testMethod void testNoPermission() {
        // create a private group (by admin)
        CollaborationGroup g = new CollaborationGroup();
        g.CollaborationType = 'Private';
        g.Name = 'Testing Testing';
        g.OwnerId = UserInfo.getUserId();
        g.IsAutoArchiveDisabled = true;
        
        insert g;    
        
        // clear data!
        delete [SELECT Id FROM FeedItem WHERE CreatedById=:UserInfo.getUserId() AND Type='TextPost'];
    
        // insert test data
        FeedItem f = new FeedItem();
        f.createdById = UserInfo.getUserId();
        f.parentId = g.Id;        // post to the group!
        f.Type = 'TextPost';
        f.body = 'testing! testing!';
        
        insert f;
        
        // create a 'civilian' user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(Alias = 'removef', Email='standarduser@helloworld.hi',
            EmailEncodingKey='UTF-8', LastName='Testing Remove Feed', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@helloworld.hi');
        
        // runAs the civilian
        Id adminId = UserInfo.getUserId();
        System.runAs(u) {
            RemoveFeedPageExtension e = new RemoveFeedPageExtension(new ApexPages.StandardController(new FeedItem()));
            e.feedItem.Type = 'TextPost';
            e.createdById = adminId ;
            e.search();
            
            // assert error is shown in page
            System.assert(ApexPages.getMessages() != null && !ApexPages.getMessages().isEmpty());
            
        }
        
    }
    
    
}