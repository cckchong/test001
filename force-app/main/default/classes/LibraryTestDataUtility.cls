/**
 * Utility classes to create Test Data for Library
 */
public class LibraryTestDataUtility {
    
    //insert employee for testing
    public static Employee__c insertEmployee(String barcode, User u){
    	Employee__c e = new Employee__c(
    		Staff_Card_ID__c = barcode,
    		User__c = u.id
    	);
    	insert e;
    	return e;
    }
    
    //insert Library_Category_Settings__c records for testing
    public static void insertLibraryCategorySettings(){
    	Library_Category_Settings__c settings = new Library_Category_Settings__c(
    		name = 'Book',
    		Borrow_Duration_Days__c = 14,
    		Borrow_Duration_Days_Different_Country__c=14,
    		Borrow_Duration_Days_Same_Country__c=14,
    		Borrow_Duration_Days_Same_Site__c=14,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=0,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    	
    	settings = new Library_Category_Settings__c(
    		name = 'Burberry Archive',
    		Borrow_Duration_Days__c = 14,
    		Borrow_Duration_Days_Different_Country__c=0,
    		Borrow_Duration_Days_Same_Country__c=14,
    		Borrow_Duration_Days_Same_Site__c=14,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=7,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    	
    	settings = new Library_Category_Settings__c(
    		name = 'Fabric',
    		Borrow_Duration_Days__c = 14,
    		Borrow_Duration_Days_Different_Country__c=28,
    		Borrow_Duration_Days_Same_Country__c=21,
    		Borrow_Duration_Days_Same_Site__c=14,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=7,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    	
    	settings = new Library_Category_Settings__c(
    		name = 'Samples PD',
    		Borrow_Duration_Days__c = 14,
    		Borrow_Duration_Days_Different_Country__c=28,
    		Borrow_Duration_Days_Same_Country__c=21,
    		Borrow_Duration_Days_Same_Site__c=14,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=7,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    	
    	settings = new Library_Category_Settings__c(
    		name = 'Samples TGA',
    		Borrow_Duration_Days__c = 14,
    		Borrow_Duration_Days_Different_Country__c=28,
    		Borrow_Duration_Days_Same_Country__c=21,
    		Borrow_Duration_Days_Same_Site__c=14,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=7,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    	
    	settings = new Library_Category_Settings__c(
    		name = 'Warehouse',
    		Borrow_Duration_Days__c = 90,
    		Borrow_Duration_Days_Different_Country__c=90,
    		Borrow_Duration_Days_Same_Country__c=90,
    		Borrow_Duration_Days_Same_Site__c=90,
    		Renewal_Count_Limit__c=99,
    		Renewal_Day__c=7,
    		Return_Notification_Days__c=2
    	);
    	insert settings;
    }
    
    //create user
    public static User createUser(String profileName){
    	
    	Profile pf = [SELECT Id FROM Profile WHERE Name like:profileName limit 1];
        User u1 = new User(Alias = 'bUser', Email=pf.id+'@testorg.com', 
        EmailEncodingKey='UTF-8', LastName=profileName, LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = pf.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName=pf.id+'@testorg.com');
        insert u1;
        return u1;
    }
    
    //create feeds
    public static FeedItem createFeeds(String id){
    	FeedItem feedItem = new FeedItem();
        feedItem.body = 'Test';
        feedItem.parentId = id;
        insert feedItem;
        return feedItem;
    }
    
    //create library item request with itemid, inventory id, status
    public static Library_Item_Request__c insertLibRequest(String itemId, String invId, String status){
    	Library_Item_Request__c lir = new Library_Item_Request__c(
    			Library_Item__c = itemId,
                Status__c = status,
                Library_Request_Inventory__c = invId,
                Overdue_Datetime__c = datetime.now().addDays(7)
            );
            insert lir;
            return lir;
    }
    
    //insert library item request with item id, status
    public static Library_Item_Request__c insertLibRequestByItemId(String itemId, String status){
    	Library_Item_Request__c lir = new Library_Item_Request__c(
                Status__c = status,
                Library_Item__c = itemId,
                Overdue_Datetime__c = datetime.now().addDays(7)
            );
            insert lir;
            return lir;
    }
    
    //insert library item request with inventory id, status
    public static Library_Item_Request__c insertLibRequest(String invId, String status){
    	Library_Item_Request__c lir = new Library_Item_Request__c(
                Status__c = status,
                Library_Request_Inventory__c = invId,
                Overdue_Datetime__c = datetime.now().addDays(7)
            );
            insert lir;
            return lir;
    }
    
    //insert Library item Request with status NotSubmitted
    public static Library_Item_Request__c insertLibraryRequestNotSubmitted() {
        Library_Item_Request__c lir = new Library_Item_Request__c(
                Status__c = 'Not Submitted',
                Overdue_Datetime__c = datetime.now().addDays(7)
            );
        
        insert lir;
        
        return lir;
    }
    
    //insert library item request iwth status
    public static Library_Item_Request__c insertLibraryRequest(String status) {
        Library_Item_Request__c lir = new Library_Item_Request__c(
                Status__c = status,
                Overdue_Datetime__c = datetime.now().addDays(7)
            );
        
        insert lir;
        
        return lir;
    }
    
    //insert library item with name
    public static Library_Item__c insertLibItem(String name){
    	Location__c loc = LibraryTestDataUtility.insertGenLocation('MyGenLocation');
        LibraryTestDataUtility.insertDetailLocation('MyDetailLocation', loc.Id);
        
    	List<RecordType> rt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE name=:name and sobjecttype = 'Library_Item__c'
            ];
    	
    	if(name == Label.Library_RecordType_Fabric || name == Label.Library_Item_category_Samples_TGA || name == Label.Library_Item_category_Samples_PD){
    	
	    	Library_Item__c li = new Library_Item__c(
				recordtypeId = rt[0].id,
	            Item_Name__c = name,
	            Item_Description__c = name,
	            Color_ID_1__c='abc',
	            Fls_Content__c='Acetate',
	            Content_Percent__c=50,
	            Fls_Content_2__c ='Acrylic',
	            Content_Percent_2__c=50,
	            Fls_Content_3__c='Bamboo',
	            Fls_Content_4__c='Cordura',
	            Warp_Yarn_Size__c='50',
	            Yarn_Type_Warp__c='Boucle',
	            Weft_Yarn_Size__c='50',
	            Yarn_Type_Weft__c='Boucle',
	            Weave_Knit_Type_TGA__c='K-Chenille',
	            Fls_Fabric_Finish__c='3M Dual Action',
	            Created_Date__c=system.today()            
	        );
	        insert li;
	        return li;
    	}else{
    		Library_Item__c li = new Library_Item__c(
				recordtypeId = rt[0].id,
	            Item_Name__c = name,
	            Item_Description__c = name,
	            Created_Date__c=system.today() 
	        );
	        insert li;
	        return li;
    	}
    }
    
    //insert library items for fabric record type
    public static Library_Item__c insertFabricItem(){
    	
    	List<RecordType> rt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE name='Fabric' and sobjecttype = 'Library_Item__c'
            ];
    	
    	Library_Item__c li = new Library_Item__c(
    			recordtypeId = rt[0].id,
                Item_Name__c = 'fabric',
                Item_Description__c = 'fabric'
                
            );
        
        insert li;
        return li;
    }
    
    //insert libray item for general usage
    public static Library_Item__c insertLibraryItem() {
        Location__c loc = LibraryTestDataUtility.insertGenLocation('MyGenLocation');
        LibraryTestDataUtility.insertDetailLocation('MyDetailLocation', loc.Id);
        
        List<RecordType> rt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE developerName = 'Warehouse' and sobjecttype = 'Library_Item__c'
                limit 1
            ];
        
        Library_Item__c li = new Library_Item__c(
                Item_Name__c = 'Name of item',
                Item_Description__c = 'Description of item',
            	RecordTypeId = rt[0].Id
            );
        
        insert li;
        
        return li;
    }
    
    //insert library item for book record type
    public static Library_Item__c insertBorrowableBookItem() {
        List<RecordType> bookRt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE developername = 'Book'
                AND sobjecttype = 'Library_Item__c'
            ];
            
        Library_Item__c li = new Library_Item__c(
                Item_Name__c = 'My Book',
                Item_Description__c = 'Description of item'
            );
        
        insert li;
        
        return li;
    }
    
    //insert general location with name
    public static Location__c insertGenLocation(String name){
        List<RecordType> rt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE name='General Location' and sobjecttype = 'Location__c'
            ];
        
        Location__c l = new Location__c(
        	recordtypeId = rt[0].id,
            name = name
        ); 
        insert l;
        return l;
    }
    
    //insert detail location with name and parent id
    public static Location__c insertDetailLocation(String name,String parentId){
        
        List<RecordType> rt =
            [
                SELECT id, DeveloperName, Name
                FROM recordtype
                WHERE name='Detail Location' and sobjecttype = 'Location__c'
            ];
            
        Location__c l = new Location__c(
            recordtypeId = rt[0].id,
            name = name,
            Parent_Location__c = parentId
        );
        insert l;
        return l;
    }    
    
    //insert book inventory with library item
    public static Library_Inventory__c insertBookInventory(Library_Item__c li){
         
         Location__c generalLocation = LibraryTestDataUtility.insertGenLocation('HKO');
         //Location__c detailLocation = LibraryTestDataUtility.insertDetailLocation('3F', Label.Library_Default_Location_Book);
         // Changed by AN: 05/05/2015
         
        Location__c detailLocation = LibraryTestDataUtility.insertDetailLocation('3F', generalLocation.Id);
        
        Library_Inventory__c lin = new Library_Inventory__c(
            Lending_Status__c =Label.Library_Inventory_Lending_Status_available,
            Library_Item_Master__c = li.id,
            Serial_Number__c = 'abc',
            Original_Address__c = generalLocation.Id,//Label.Library_Default_Location_Book,
            Target_Address__c = generalLocation.Id, //Label.Library_Default_Location_Book,
            Detail_Current_Location__c = detailLocation.Id, //Label.Location_detail_3F,
            Detail_Home_Location__c = detailLocation.Id //Label.Location_detail_3F
        );
        insert lin;
        return lin;
    }
    
    //insert book inventory with library item 
    public static Library_Inventory__c insertBookInventory2(Library_Item__c li){
         
         Location__c generalLocation = LibraryTestDataUtility.insertGenLocation('HKO');
         //Location__c detailLocation = LibraryTestDataUtility.insertDetailLocation('3F', Label.Library_Default_Location_Book);
         Location__c detailLocation = LibraryTestDataUtility.insertDetailLocation('3F', generalLocation.Id);
         // Changed by AN: 05/05/2015
         
         Library_Inventory__c lin = new Library_Inventory__c(
            Lending_Status__c =Label.Library_Inventory_Lending_Status_available,
            Library_Item_Master__c = li.id,
            Serial_Number__c = 'abc2',
            Original_Address__c = generalLocation.Id,//Label.Library_Default_Location_Book,
            Target_Address__c = generalLocation.Id, //Label.Library_Default_Location_Book,
            Detail_Current_Location__c = detailLocation.Id, //Label.Location_detail_3F,
            Detail_Home_Location__c = detailLocation.Id //Label.Location_detail_3F
        );
        insert lin;
        return lin;
    }
    
    //insert library Cart
    public static Request__c insertRequest(String status){
    	Request__c req = new Request__c(
    		Status__c =status
    	);
    	insert req;
    	return req;
    }
    

}