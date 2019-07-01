@isTest
public class TestIDPFavouriteListVFPCtrl {

  public static TestIDPPreparation idpPrepare;
  public static IDPFavouriteListVFPCtrl ctrl;

  public static Map<String, User> userMap;
  public static Map<String, IDP_Policy__c> idpPolicyMap;
  public static Map<String, Catalog__c> catalogAllMap;
  public static Map<String, Catalog_Item__c> catalogItemMap;
    public static Map<String, Employee_Administrator__c> employeeAdministratorMap;
    public static Map<String, Site__c> siteMap;

  public static Boolean IS_SEE_ALL_DATA = false;


  @testSetup
  public static void setup() {
    TestIDPUtility.prepare(IS_SEE_ALL_DATA);


  }

  public static void prepare(boolean isSeeAllData) {

    userMap = TestIDPUtility.getuserMap();
    //idpPolicyMap = TestIDPUtility.getidpPolicyMap();
    //employeeAdministratorMap = TestIDPUtility.getemployeeAdministratorMap();
    //siteMap = TestIDPUtility.getsiteMap();
    //catalogAllMap = TestIDPUtility.getcatalogAllMap();
    catalogItemMap = TestIDPUtility.getcatalogItemMap();    

    catalogItemMap.get('Administration_Motor Vehicles_Item_1').Expiry_Date__c  = Date.newInstance(2017, 1,1);
    catalogItemMap.get('Administration_Motor Vehicles_Item_2').Expiry_Date__c  = Date.newInstance(2099, 1,1);
    update catalogItemMap.values();    
  }

  
  //@isTest
  public static void testSingleAddToCart() {
    
    List<Favourite_Item__c> insertedfavList = new List<Favourite_Item__c> ();
    List<Favourite_Item__c> favList = new List<Favourite_Item__c> ();
    List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
    String catalogItemId = '';
    String catalogItemUOM = '';
    Integer insertQuantity = 0;

    prepare(IS_SEE_ALL_DATA);
  
    CatalogItemID = catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id;
    insertQuantity = 10;
    catalogItemUOM = catalogItemMap.get('Administration_Motor Vehicles_Item_1').Unit_of_Measure__c;

    Test.startTest();    

    System.runAs(userMap.get('user1')) {

      insertedfavList = prepareFavouriteItemData();
      PageReference pageRef = Page.IDPFavouriteListVFP;
      pageRef.getParameters().put('addToCartCatalogItemId', CatalogItemID);
      pageRef.getParameters().put('addToCartQuantity', String.valueOf(insertQuantity));
      pageRef.getParameters().put('addToCartUOM', catalogItemUOM);

      Test.setCurrentPage(pageRef);
      ctrl = new IDPFavouriteListVFPCtrl();

      //Before: 4 fav items are inserted
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(), insertedfavList.size());

      ctrl.singleAddtoCart();

      //After: 4 fav items are remained
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(),insertedfavList.size());

      //After: 1 shopping cart item is inserted
      scList = [SELECT Id, Quantity__c FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
      System.assertEquals(scList.size(),1);

      //After: 1 shopping cart item quantity is 10
      System.assertEquals(scList.get(0).Quantity__c, insertQuantity);
    }
    Test.stopTest();

  }

  //@isTest
  public static void testSingleRemoveFavouriteItem() {
    
    List<Favourite_Item__c> insertedfavList = new List<Favourite_Item__c> ();
    List<Favourite_Item__c> favList = new List<Favourite_Item__c> ();
    List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
    String catalogItemId = '';

    
    prepare(IS_SEE_ALL_DATA);
  
    CatalogItemID = catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id;

    Test.startTest();    

    System.runAs(userMap.get('user1')) {

      insertedfavList = prepareFavouriteItemData();
      PageReference pageRef = Page.IDPFavouriteListVFP;
      pageRef.getParameters().put('removeFromFavouriteCatalogItemId', CatalogItemID);

      Test.setCurrentPage(pageRef);
      ctrl = new IDPFavouriteListVFPCtrl();

      //Before: 4 fav items are inserted
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(), insertedfavList.size());

      ctrl.singleRemoveFavouriteItem();

      //After: 4 fav items are remained
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(),insertedfavList.size() - 1);

    }
    Test.stopTest();

  }

  @isTest
  public static void testMassActionRemoveFromFavouriteList() {

    List<Favourite_Item__c> insertedfavList = new List<Favourite_Item__c> ();
    List<Favourite_Item__c> favList = new List<Favourite_Item__c> ();
    String itemName = '';
    String testmMode = Label.IDP_Mass_Remove_Mode_Remove_From_Favourite_List;
    String testJSONString = '';
    prepare(IS_SEE_ALL_DATA);
    

    //Prepare JSON
    testJSONString = TestIDPUtility.prepareJSONStringData(catalogItemMap,false);


    Test.startTest();

    System.runAs(userMap.get('user1')) {
      insertedfavList = prepareFavouriteItemData();
      PageReference pageRef = Page.IDPFavouriteListVFP;
      pageRef.getParameters().put('checkedCatalogItemIdQuantityJSON', testJSONString);
      pageRef.getParameters().put('mMode', testmMode);

      Test.setCurrentPage(pageRef);

      ctrl = new IDPFavouriteListVFPCtrl();

      //Before: 4 favourite items are inserted
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(), insertedfavList.size());

      ctrl.massAction();

      //After: 0 favourite items are remained 
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(),0);

    }

    Test.stopTest();
  }

  @isTest
  public static void testMassActionAddToCart() {

    List<Favourite_Item__c> insertedfavList = new List<Favourite_Item__c> ();
    List<Favourite_Item__c> favList = new List<Favourite_Item__c> ();
    List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();

    String itemName = '';
    String testmMode = Label.IDP_Mass_Add_Mode_Add_To_Cart_Remove_Favourite;
    String testJSONString = '';
    prepare(IS_SEE_ALL_DATA);
    

    //Prepare JSON
    testJSONString = TestIDPUtility.prepareJSONStringData(catalogItemMap,false);


    Test.startTest();

    System.runAs(userMap.get('user1')) {
      insertedfavList = prepareFavouriteItemData();
      PageReference pageRef = Page.IDPFavouriteListVFP;
      pageRef.getParameters().put('checkedCatalogItemIdQuantityJSON', testJSONString);
      pageRef.getParameters().put('mMode', testmMode);

      Test.setCurrentPage(pageRef);

      ctrl = new IDPFavouriteListVFPCtrl();

      //Before: 4 favourite items are inserted
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(), insertedfavList.size());
      
      //Before: 0 shopping cart items are inserted
      scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id and Status__c = 'OP'];
      System.assertEquals(scList.size(),0);

      ctrl.massAction();

      //After: 4 favourite items are remained 
      favList = [SELECT Id FROM Favourite_Item__c WHERE User__c = :userMap.get('user1').Id];
      System.assertEquals(favList.size(),insertedfavList.size());


      //After: 4 shopping cart items are inserted
      scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id and Status__c = 'OP'];
      System.assertEquals(favList.size(),scList.size());
    }

    Test.stopTest();
  }


   @isTest
    public static void testRedirectToBrowseCatalog() {
      List<Favourite_Item__c> insertedfavList = new LIst<Favourite_Item__c> ();
      PageReference redirectedPageRef = null;

      prepare(IS_SEE_ALL_DATA);
      Test.startTest();
      system.runAs(userMap.get('user1')) {
          insertedfavList = prepareFavouriteItemData();
          PageReference pageRef = Page.IDPFavouriteListVFP;

          IDPFavouriteListVFPCtrl ctrl = new IDPFavouriteListVFPCtrl();
          ctrl.redirectPage = Label.IDP_Path_IDPBrowseCatalogVFP;
          redirectedPageRef = ctrl.redirectToPage();    
      }

      System.assertEquals(Page.IDPBrowseCatalogVFP.getUrl().toUpperCase(), redirectedPageRef.getUrl().toUpperCase());
      Test.stopTest();
    }

   @isTest
    public static void testRedirectToShoppingCart() {
      List<Favourite_Item__c> insertedfavList = new LIst<Favourite_Item__c> ();
      PageReference redirectedPageRef = null;

      prepare(IS_SEE_ALL_DATA);
      Test.startTest();
      system.runAs(userMap.get('user1')) {
          insertedfavList = prepareFavouriteItemData();
          PageReference pageRef = Page.IDPFavouriteListVFP;

          IDPFavouriteListVFPCtrl ctrl = new IDPFavouriteListVFPCtrl();
          ctrl.redirectPage = Label.IDP_Path_IDPShoppingCartVFP;
          redirectedPageRef = ctrl.redirectToPage();    
      }

      System.assertEquals(Page.IDPShoppingCartVFP.getUrl().toUpperCase(), redirectedPageRef.getUrl().toUpperCase());
      Test.stopTest();
    }

  private static List<Favourite_Item__c> prepareFavouriteItemData () {


    List<Favourite_Item__c> favourite_itemList = new List<Favourite_Item__c>();
    for(Integer i=1; i<5; i++){
      Favourite_Item__c favourite_item = new Favourite_Item__c();
      favourite_item.User__c = userMap.get('user1').Id;    //User
      favourite_item.Catalog_Item__c = catalogItemMap.get('Administration_Motor Vehicles_Item_' +String.valueOf(i)).Id;    //Catalog Item
      favourite_itemList.add(favourite_item);
    }

    insert favourite_itemList;



    return favourite_itemList;

  }
  private static void log(String msg) {
      TestIDPUtility.log(msg);
  } 
  ////@isTest
  //public static void testsingleRemoveFromCart() {

  //  List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
  //  String catalogItemIdUOM = '';

  //  prepare(IS_SEE_ALL_DATA);
    
    
  //  CatalogItemIDUOM = catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id + '_' + catalogItemMap.get('Administration_Motor Vehicles_Item_1').Unit_of_Measure__c;

  //  Test.startTest();
  //  //Check shopping cart item list is empty
    

  //  System.runAs(userMap.get('user1')) {

  //    prepareShoppingCartItemData();
  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    pageRef.getParameters().put('removeFromCartCatalogItemId', CatalogItemIDUOM);

  //    Test.setCurrentPage(pageRef);
  //    ctrl = new IDPFavouriteListVFPCtrl();

  //    //Before: 4 shopping cart items are inserted
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(),4);

  //    ctrl.singleRemoveFromCart();

  //    //After: 3 shopping cart items are remained 
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(),3);

  //  }
    
  //  Test.stopTest();
  //}

  ////@isTest
  //public static void testMassActionRemove() {

  //  List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
  //  String itemName = '';
  //  String testmMode = Label.IDP_Mass_Remove_Mode_Remove_From_Cart;
  //  String testJSONString = '';
  //  prepare(IS_SEE_ALL_DATA);
  //  prepareShoppingCartItemData();

  //  //Prepare JSON
  //  testJSONString = prepareJSONStringData(catalogItemMap);


  //  Test.startTest();

  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    pageRef.getParameters().put('checkedCatalogItemIdQuantityJSON', testJSONString);
  //    pageRef.getParameters().put('mMode', Label.IDP_Mass_Remove_Mode_Remove_From_Cart);

  //    Test.setCurrentPage(pageRef);

  //    ctrl = new IDPShoppingCartVFPCtrl();

  //    //Before: 4 shopping cart items are inserted
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(),4);

  //    ctrl.massAction();

  //    //After: 0 shopping cart items are remained 
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(),0);

  //  }

  //  Test.stopTest();
  //}

  ////@isTest
  //public static void testUpdateShoppingCartItemQuantity() {

  //  List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
  //  String itemName = 'Administration_Motor Vehicles_Item_1';
  //  String catalogItemIdUOM = '';
  //  Integer updateQuantity = 0;
  //  prepare(IS_SEE_ALL_DATA);
  //  prepareShoppingCartItemData();

    
  //      catalogItemIdUOM = catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id + '_' + catalogItemMap.get('Administration_Motor Vehicles_Item_1').Unit_of_Measure__c;
  //      updateQuantity = 2;

  //  Test.startTest();

  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    pageRef.getParameters().put('updateQuantityCatalogItemId', catalogItemIdUOM);
  //    pageRef.getParameters().put('updateCatalogItemQuantity', String.valueOf(updateQuantity));

  //    Test.setCurrentPage(pageRef);

  //    ctrl = new IDPShoppingCartVFPCtrl();

  //    //Before: item's quantity is 3
  //    scList = [SELECT Id,Quantity__c FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Catalog_Item__c = :catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id AND Status__c = 'OP' LIMIT 1];
  //    System.assertEquals(scList.get(0).Quantity__c, 3);          
      
  //    ctrl.updateShoppingCartItemQuantity();


  //    //Before: item's quantity is 2
  //    scList = [SELECT Id,Quantity__c FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Catalog_Item__c = :catalogItemMap.get('Administration_Motor Vehicles_Item_1').Id AND Status__c = 'OP' LIMIT 1];
  //    System.assertEquals(scList.get(0).Quantity__c, 2);          
  //  }
  //  Test.stopTest();

  //}

  ////@isTest
  //public static void testcloseShoppingCartItems() {

  //  List<Shopping_Cart_Item__c> scList = new List<Shopping_Cart_Item__c> ();
  //  List<Purchase_Request__c> prList = new List<Purchase_Request__c> ();
  //  List<Purchase_Request_Item__c> priList = new List<Purchase_Request_Item__c> ();
  //  String itemName = '';
  //  String testmMode = '';
  //  String testJSONString = '';
  //  prepare(IS_SEE_ALL_DATA);
  //  prepareShoppingCartItemData();

  //  //Prepare JSON and mode:new PR
  //  testJSONString = prepareJSONStringData(catalogItemMap);
  //  testmMode = Label.IDP_Create_Purchase_Request_Mode_Create_New ;

  //  Test.startTest();

  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    pageRef.getParameters().put('checkedCatalogItemIdQuantityJSON', testJSONString);
  //    pageRef.getParameters().put(Label.IDP_Create_Purchase_Request_Mode_Parameter_Name, testmMode);

  //    Test.setCurrentPage(pageRef);

  //    ctrl = new IDPShoppingCartVFPCtrl();

  //    //Before: 4 open shopping cart items
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(), 4);    

  //    ctrl.closeShoppingCartItems();

  //    //After: 0 open shopping cart items
  //    scList = [SELECT Id FROM Shopping_Cart_Item__c WHERE User__c = :userMap.get('user1').Id AND Status__c = 'OP'];
  //    System.assertEquals(scList.size(), 0);  

  //    //After: 1 Draft
  //    prList = [SELECT Id, Status__c FROM Purchase_Request__c WHERE OwnerId = :userMap.get('user1').Id];
  //    System.assertEquals(prList.size(), 1);  
  //    System.assertEquals(prList.get(0).Status__c, IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT);  

  //  }

  //  prepareShoppingCartItemData();
  //  //Prepare mode: add to existing
  //  testmMode = Label.IDP_Create_Purchase_Request_Mode_Add_To_Existing;


  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    pageRef.getParameters().clear();
  //    pageRef.getParameters().put('checkedCatalogItemIdQuantityJSON', testJSONString);
  //    pageRef.getParameters().put(Label.IDP_Create_Purchase_Request_Mode_Parameter_Name, testmMode);


  //    Test.setCurrentPage(pageRef);

  //    ctrl = new IDPShoppingCartVFPCtrl();
  //    ctrl.selectedPurchaseRequest = prList.get(0).Id;
  //    ctrl.closeShoppingCartItems();
  //    priList = [SELECT Id, Quantity__c, Status__c FROM Purchase_Request_Item__c WHERE Purchase_Request__r.OwnerId = :userMap.get('user1').Id];
      
  //    //After: item quantity is 8.
  //    System.assertEquals(priList.size(), 4);  
  //    //After item quantity is equal to the sum of new cart item quanitty(instead of the json 4) + pri quantity (3 + 3) 
  //    //supposing the json item quantity and item quantity should be sync
  //    System.assertEquals(priList.get(0).Quantity__c, 6);  
  //    System.assertEquals(priList.get(1).Quantity__c, 6);  
  //    System.assertEquals(priList.get(2).Quantity__c, 6);  
  //    System.assertEquals(priList.get(3).Quantity__c, 6);  


  //    delete prList;
  //    ctrl.selectedPurchaseRequest = Label.IDP_List_Empty_Label;

  //    ctrl.closeShoppingCartItems();
  //    //After: check message
  //    System.assertEquals(ctrl.message, Label.IDP_Shopping_Cart_Not_Available_Existing_PR_Message);
  //  }
  //  Test.stopTest();
  //}



  ////@isTest
  //public static void testPRRelatedMethod() {

  //  Boolean isCatalogRelatedPRExisted = false;
  //  PageReference prPageRef = null;
  //  Purchase_Request__c pr = null;
  //  prepare(IS_SEE_ALL_DATA);
  //  prepareShoppingCartItemData();
  //  pr = prepareExistingPRData();

  //  Test.startTest();

  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    Test.setCurrentPage(pageRef);
  //    ctrl = new IDPShoppingCartVFPCtrl();
  //    ctrl.getExistingPurchaseRequest();
  //    isCatalogRelatedPRExisted = ctrl.getisRelatedCatalogPRExisted();
  //    ctrl.selectedPurchaseRequest = String.valueOf(pr.Id);
  //    prPageRef = ctrl.viewExistingPurchaseRequest();
  //  }

  //  log(String.valueOf(isCatalogRelatedPRExisted));
  //  system.assert(isCatalogRelatedPRExisted);
  //  system.assertEquals(prPageRef.getUrl(), '/' + pr.Id);

  //  delete pr;
  //  System.runAs(userMap.get('user1')) {

  //    PageReference pageRef = Page.IDPShoppingCartVFP;
  //    Test.setCurrentPage(pageRef);
  //    ctrl = new IDPShoppingCartVFPCtrl();
  //    ctrl.getExistingPurchaseRequest();
  //    isCatalogRelatedPRExisted = ctrl.getisRelatedCatalogPRExisted();
  //    ctrl.selectedPurchaseRequest = Label.IDP_List_Empty_Label;
  //    prPageRef = ctrl.viewExistingPurchaseRequest();
  //  }

  //  system.assert(!isCatalogRelatedPRExisted);
  //  system.assertEquals(ctrl.message,  Label.IDP_Shopping_Cart_Not_Available_Existing_PR_Message);


  //  Test.stopTest();
  //}
  
  // //@isTest
  //  public static void testRedirectPage() {
      
      
  //  prepare(IS_SEE_ALL_DATA);
  //      system.runAs(userMap.get('user1')) {
  //      String catalogName = 'Administration';
  //          IDPShoppingCartVFPCtrl ctrl = new IDPShoppingCartVFPCtrl();
  //          ctrl.redirectPage = Label.IDP_Path_IDPBrowseCatalogVFP;
  //          ctrl.redirectToPage();    
  //      }
  //  }


  //public class testJSONObject {

  //  public String catalogItemId {set;get;}
  //  public Boolean checked{get;set;}
  //  public String quantity{get;set;}

  //}


  //private static Boolean isCorrectMessageAdded(ApexPages.Message message) {
  //  Boolean messageFound = false;
  //  ApexPages.Message[] pageMessages = ApexPages.getMessages();
  //  for(ApexPages.Message msg : pageMessages) {
  //  if(msg.getSummary() == message.getSummary()
  //    && msg.getDetail() == message.getDetail()
  //    && msg.getSeverity() == message.getSeverity()) {
  //    messageFound = true;        
  //  }
  //  }

  //     return messageFound;
  //}

  //  public static void log(String msg) {
  //      TestIDPUtility.log(msg);
  //  }  

  //private static List<Shopping_Cart_Item__c> prepareShoppingCartItemData() {
  //  List<Shopping_Cart_Item__c> shopping_cart_itemList = new List<Shopping_Cart_Item__c>();
  //  String itemName = '';
  //  for(Integer i=1; i<5; i++){
  //    itemName = 'Administration_Motor Vehicles_Item_' + i;
  //    Shopping_Cart_Item__c shopping_cart_item = new Shopping_Cart_Item__c();
  //    shopping_cart_item.User__c = userMap.get('user1').Id;
  //    shopping_cart_item.Catalog_Item__c = catalogItemMap.get(itemName).Id;    //Catalog Item
  //    shopping_cart_item.Status__c = 'OP';    //Status
  //    shopping_cart_item.Quantity__c = 3;    //Quantity
  //    shopping_cart_item.Unit_of_Measure__c = catalogItemMap.get(itemName).Unit_of_Measure__c;    //Unit of Measure
  //    shopping_cart_itemList.add(shopping_cart_item);
  //  }
  //  insert shopping_cart_itemList;

  //  return shopping_cart_itemList;
  //}  

  //private static Purchase_Request__c prepareExistingPRData() {

  //    Purchase_Request__c pr = new Purchase_Request__c(
  //             RecordTypeId='012p00000008u9FAAQ',
  //             Status__c='DF',
  //             On_Behalf_of__c=employeeAdministratorMap.get('Testing (HKOuser1)').Id,
  //             IDP_Policy__c=idpPolicyMap.get('HKO').Id,
  //             Catalog__c=catalogAllMap.get('Administration').Id,
  //             Delivery_Site__c=siteMap.get('HKO').Id,
  //             Is_Budget__c=true,
  //             Catalog_Name__c='Administration',
  //             Budget_Forecast__c='Within Budget',
  //             Need_by_Date__c=Date.newInstance(2017,5,31),
  //             OwnerId = userMap.get('user1').Id
  //            );

  //  insert pr;

  //  return pr;
  //}

  //private static String prepareJSONStringData(Map<String, Catalog_Item__c> pCatalogItemMap) {
        
  //      List<testJSONObject> jsonObjectList = new List<testJSONObject> ();
  //  String itemName = '';
  //  String testJSONString = '';
  //      testJSONObject obj = null;
  //      JSONGenerator gen = JSON.createGenerator(true);    

  //  for(Integer i=1; i<5; i++){

  //    itemName = 'Administration_Motor Vehicles_Item_' + i;

  //    obj = new testJSONObject();
  //    obj.catalogItemId = pCatalogItemMap.get(itemName).Id + '_' + pCatalogItemMap.get(itemName).Unit_of_Measure__c;
  //    obj.checked = true;
  //    obj.quantity ='4';

  //    jsonObjectList.add(obj);

  //  }
  //      gen.writeStartObject();

  //    gen.writeObjectField('editedCatalogItemList',jsonObjectList);
  //      gen.writeEndObject();

  //    testJSONString = gen.getAsString();

  //    return testJSONString;
  //}


}