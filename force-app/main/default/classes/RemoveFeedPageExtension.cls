public without sharing class RemoveFeedPageExtension {
    public static Integer LIST_LIMIT = 500;
    public static Integer RECORDS_PER_PAGE = 20;
    
    public FeedItem feedItem {set; get;}
    public List<FeedItemSelected> feedItems {set; get;}        // this is the full list
    
    // variable for input boxes
    public String createdById {set; get;}
    public Datetime fromTime {set; get;}
    public Datetime toTime {set; get;}
    
    // variables for selection boxes
    public Boolean isSelectAll {set; get;}
    public Integer resultCount {
        get{
            return (feedItems == null? 0 : this.feedItems.size());
        
    
        }
    }
    public Integer selectedCount {
        get {
            if (feedItems == null) {
                return 0;
            } else {
                Integer count = 0;
                
                for (FeedItemSelected fis: feedItems) {
                    if (fis.selected) {
                        count++;
                    }
                }
                
                return count;
            }
        }
    }
    
    // variables for pagination
    public List<FeedItemSelected> listWindow {set; get;}       // this is the "window", for pagination
    public Integer currentPage {set; get;}

    public RemoveFeedPageExtension (ApexPages.StandardController stdController) {
        this.feedItem = (FeedItem) stdController.getRecord();
        this.createdById = String.valueOf(UserInfo.getUserId());
        this.feedItem.Type = 'TrackedChange';
        this.isSelectAll = false;
        
    }
    
    public void search() {
        this.feedItems = new List<FeedItemSelected>();
        
        // build the query
        Id createdById = null;
        try {
            createdById = Id.valueOf(this.createdById);
            
        } catch (Exception e) {
            // invalid Id
            ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.ERROR, 'Invalid ID! Please search again');
            ApexPages.addmessage(errMsg);
            
            return;
        
        }
        
        String type = feedItem.Type;
        
        String timeFilter = (fromTime == null) && (toTime == null)? '' : 'AND (' +
                        (fromTime != null? 'CreatedDate >= :fromTime' : '') + 
                        ((fromTime != null) && (toTime != null)? ' AND ': '') +
                        (toTime != null? 'CreatedDate <= :toTime' : '') + ') ';
                        
        String query = 'SELECT Id, CreatedBy.Name, CreatedDate, Body FROM FeedItem ' +
                    'WHERE CreatedById=:createdById AND Type=:type ' + timeFilter + 'ORDER BY CreatedDate DESC LIMIT :LIST_LIMIT';
                    
        // query the feeditems
        for (FeedItem f: Database.query(query)) {
            FeedItemSelected fis = new FeedItemSelected(f);
            this.feedItems.add(fis);
 
        }
        
        // set page to 0
        this.currentPage = 0;
        this.turnPage();
        
        this.isSelectAll = false;

    }
    
    public void deleteFeed() {
        List<FeedItem> delList = new List<FeedItem>();
        List<Integer> removeIndexes = new List<Integer>();
        
        // get the items to be removed
        for (Integer i = 0; i < feedItems.size(); i++) {
            if (feedItems.get(i).selected) {
                delList.add(feedItems.get(i).feedItem);
                removeIndexes.add(i);
                
            }
        }
        
        // delete the feeds
        List<Database.DeleteResult> drs = Database.delete(delList, false);
        
        for (Database.DeleteResult dr: drs) {
            if (!dr.isSuccess()) {
                FeedItemSelected failedFis;
                for (FeedItemSelected fis: ListWindow) {
                    if (fis.feedItem.Id == dr.getId()) {
                        failedFis = fis;
                        break;
                        
                    }
                }
            
                String errMsgString = String.format('Error in deleting the record [Id={0}, Message={1}, Error Messages={2}]',
                    new String[] {String.valueOf(failedFis.feedItem.Id), failedFis.feedBody, String.valueOf(dr.getErrors())});
            
                ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.ERROR, errMsgString);
                ApexPages.addmessage(errMsg);
                
            }
        }
        
        this.search();
        
    }
    
    public void onSelectAll() {
        if (this.feedItems != null) {
            for (FeedItemSelected fis: this.feedItems) {
                fis.selected = isSelectAll ;
            
            }
        }
    }
    
    public void next() {
        this.currentPage += 1;
        this.turnPage();
        
    }
    
    public void previous() {
        this.currentPage -=1;
        this.turnPage();
        
    }
    
    private void turnPage() {
        this.listWindow = new List<FeedItemSelected>();
        
        Integer numberOfRecords = currentPage == (feedItems.size() / RECORDS_PER_PAGE)?     // this checks the last page of size NOT divisble
                Math.mod(feedItems.size(), RECORDS_PER_PAGE) : RECORDS_PER_PAGE;

        for (Integer i = currentPage * RECORDS_PER_PAGE ; i < currentPage * RECORDS_PER_PAGE + numberOfRecords ; i++) {
            listWindow.add(feedItems.get(i));
            
        }
        
        // assign the feed body
        this.getFeedBodyToListWindow();
    
    }
    
    private void getFeedBodyToListWindow() {
        List<String> feedIds = new List<String>();
        
        for (FeedItemSelected fis: this.listWindow) {
            if (!fis.isFeedBodyFetched) {
                feedIds.add(fis.feedItem.Id);
            }
            
        }
        
        
        if (!feedIds.isEmpty()) {
            // get the body of the feeditem by ConnectApi.FeedElement
            // because connectAPI does NOT work in system mode, need to check if user has permission
            Map<Id, String> feedIdToBodyMap = new Map<Id, String>();
            try {
                ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.getFeedElementBatch(null, feedIds);
                for (ConnectApi.BatchResult b: batchResults) {
                    if (b.isSuccess()) {
                        ConnectApi.FeedElement fe = null;
                        if(b.getResult() instanceof ConnectApi.FeedElement) {
                            fe = (ConnectApi.FeedElement) b.getResult();
                            feedIdToBodyMap.put(Id.valueOf(fe.id), fe.header.text + (fe.body.text == null ? '' : ' - ' + fe.body.text));
                            
                        }
                    
                    } else {
                        ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.ERROR, b.getErrorMessage());
                        ApexPages.addmessage(errMsg);
                    
                    }
                }
            } catch (Exception e) {
                // user does not have permission to use ConnectApi
                ApexPages.message errMsg = new ApexPages.message(ApexPages.severity.ERROR, 
                           'You do not have permission to access some of the feeds. The \'Message\' column may show empty.');
                ApexPages.addmessage(errMsg);
                
                // get the feedItem.body instead, but it may be empty...
                for (FeedItemSelected fis: this.listWindow) {
                    feedIdToBodyMap.put(fis.feedItem.Id, fis.feedItem.Body);
                }
                
            
            }
            
            // map the messages to the feeds list
            for (FeedItemSelected fis: this.listWindow) {
                fis.feedBody = feedIdToBodyMap.get(fis.feedItem.Id);
                fis.isFeedBodyFetched = true;
                
            }
        }
    }
    
    
    public Boolean getHasNext() {
        return feedItems == null? false : 
            Math.mod(feedItems.size(), RECORDS_PER_PAGE) == 0 ?
            this.currentPage != (feedItems.size() / RECORDS_PER_PAGE) - 1 : this.currentPage != (feedItems.size() / RECORDS_PER_PAGE);
    
    }
    
    public Boolean getHasPrevious() {
        return (this.currentPage > 0);
        
    }
    
    public Integer getFirstRecordNumber() {
        return (feedItems == null || feedItems.isEmpty()) ? 0 : currentPage * RECORDS_PER_PAGE + 1;
        
    }
    
    public Integer getLastRecordNumber() {
        if (feedItems == null || feedItems.isEmpty()) return 0;
    
        return currentPage == feedItems.size() / RECORDS_PER_PAGE ?
                    currentPage * RECORDS_PER_PAGE + Math.mod(feedItems.size(), RECORDS_PER_PAGE):
                    currentPage * RECORDS_PER_PAGE + RECORDS_PER_PAGE;
    
    }
    
    public Integer getLIST_LIMIT() {
        return LIST_LIMIT;
        
    }

    public class FeedItemSelected {
        public FeedItem feedItem {get; set;}
        public Boolean selected {get; set;}
        public String feedBody {get; set;}
        public Boolean isFeedBodyFetched {get; set;}
                
        public FeedItemSelected(FeedItem f) {
            this.feedItem = f;
            this.selected = false;
            this.isFeedBodyFetched = false;
        
        }
    }
    
}