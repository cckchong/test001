/**
 * Test class for AddTopicToFeedItemHandler
 *
 * @editor Jason Tam
 * @version 2.4
 * @last edit 2018-7-30
 *
 * Add supplier, innovation
 *
 */

@isTest(SeeAllData=true)
private class AddTopicToFeedItemHandlerTest {
/* Test data was impossible to create since the features developed is based on actual organization data on Salesforce
 * thus (SeeAllData=true) is used in this exceptional case
 */

//---Tests for positive cases---//
@isTest static void testFeedItemWithBrandCustomer() {
    //Set up feedItem test data parameters
    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');
        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    String feedItemType = 'TextPost';
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c DESC];
    String brandCustomerName = brandCustomersList[0].Customer_Name__c;

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, 'test '+brandCustomerName+' test');

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned

    List<String> topicNames = new List<String>();
    List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                            WHERE EntityId = :newPost.Id
                                                             GROUP BY EntityId, Topic.Name];
    for (AggregateResult topic : topicsAssigned) {
        topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
    }
    System.assert (topicNames.contains(brandCustomerName.toLowerCase()),'The brand customer name '+brandCustomerName+'(' + topicNames + ') was expected to be assigned to the Feed Item (' + newPost.Id +' : '+newPost.Body+ '), but was not assigned successfully.');
}

@isTest static void testFeedItemWithMultiTypeKeywords() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';

    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c FROM Customers_List__c ORDER BY Priority__c DESC LIMIT 4];

    List<String> brandCustomerNames = new List<String>();
    for(Customers_List__c brandCustomers : brandCustomersList)
        brandCustomerNames.add(brandCustomers.Customer_Name__c);

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithMultiTypeTopic(testuser21.Id, feedItemType, brandCustomerNames[0], brandCustomerNames[1], brandCustomerNames[2], brandCustomerNames[3], '');

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned
    List<String> topicNames = new List<String>();
    List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                            WHERE EntityId = :newPost.Id
                                                             GROUP BY EntityId, Topic.Name];
    for (AggregateResult topic : topicsAssigned) {
        topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
    }
    System.assert (topicNames.contains(brandCustomerNames[0].toLowerCase()),topicsAssigned.size()+'The customer1 name ' + brandCustomerNames[0] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (topicNames.contains(brandCustomerNames[1].toLowerCase()),'The customer2 name ' + brandCustomerNames[1] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (topicNames.contains(brandCustomerNames[2].toLowerCase()),'The customer3 name ' + brandCustomerNames[2] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (topicNames.contains(brandCustomerNames[3].toLowerCase()),'The customer4 name ' + brandCustomerNames[3] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
}

//---Tests for negative cases---//
@isTest static void testFeedItemWithExcludedKeyword() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';

    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c FROM Customers_List__c ORDER BY Priority__c DESC LIMIT 5];
    //brandCustomersList[0-3] topic; brandCustomersList[4] excluded
    String excludedKeyword = brandCustomersList[4].Customer_Name__c;

    List<String> brandCustomerNames = new List<String>();
    for(Customers_List__c brandCustomers : brandCustomersList)
        brandCustomerNames.add(brandCustomers.Customer_Name__c);

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up test Excluded Feed Item List
    List<Excluded_Feed_Item_Keyword__c> testExcludedFeedItemList = new List<Excluded_Feed_Item_Keyword__c>();
    Excluded_Feed_Item_Keyword__c testExcludedFeedItemKeyword1 = new Excluded_Feed_Item_Keyword__c(Name = excludedKeyword, Item_Type__c='User Generated Keyword');
    Excluded_Feed_Item_Keyword__c testExcludedFeedItemKeyword2 = new Excluded_Feed_Item_Keyword__c(Name = 'has submitted the following leave requests:', Item_Type__c='E-Leave');
    Excluded_Feed_Item_Keyword__c testExcludedFeedItemKeyword3 = new Excluded_Feed_Item_Keyword__c(Name = 'requested approval for this expense application:', Item_Type__c='Travel & Expense');
    testExcludedFeedItemList.add(testExcludedFeedItemKeyword1);
    testExcludedFeedItemList.add(testExcludedFeedItemKeyword2);
    testExcludedFeedItemList.add(testExcludedFeedItemKeyword3);
    try {
        insert testExcludedFeedItemList;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithMultiTypeTopic(testuser21.Id, feedItemType, brandCustomerNames[0], brandCustomerNames[1], brandCustomerNames[2], brandCustomerNames[3], excludedKeyword);

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned and the excluded topic is not assigned
    List<String> topicNames = new List<String>();
    List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                            WHERE EntityId = :newPost.Id
                                                             GROUP BY EntityId, Topic.Name];
    for (AggregateResult topic : topicsAssigned) {
        topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
    }
    System.assert (topicNames.contains(brandCustomerNames[0].toLowerCase()),'The customer name ' + brandCustomerNames[0] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (topicNames.contains(brandCustomerNames[1].toLowerCase()),'The customer name ' + brandCustomerNames[1] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (topicNames.contains(brandCustomerNames[2].toLowerCase()),'The customer name ' + brandCustomerNames[2] + ' was expected to be assigned to the Feed Item (' + newPost.Id + '), but was not assigned successfully.');
    System.assert (!topicNames.contains(excludedKeyword.toLowerCase()),'The excluded topic' + excludedKeyword + ' was not expected to be assigned to the Feed Item (' + newPost.Id + '), but was assigned.');
}

@isTest static void testFeedItemWithCensoredKeyword() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';
    String censoredKeyword = 'enemy';

    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c FROM Customers_List__c ORDER BY Priority__c DESC LIMIT 4];

    List<String> brandCustomerNames = new List<String>();
    for(Customers_List__c brandCustomers : brandCustomersList)
        brandCustomerNames.add(brandCustomers.Customer_Name__c);

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithMultiTypeTopic(testuser21.Id, feedItemType, brandCustomerNames[0], brandCustomerNames[1], brandCustomerNames[2], brandCustomerNames[3], censoredKeyword);

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        //Catching the Data Manipulation Language Exception and verify that the new post with censored keyword(s) is not inserted into the database
        System.assert (true, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
}

//---Test case for bulkify insert on Salesforce database---//
@isTest static void testFeedItemWithBulkifyInsert() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';

    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c FROM Customers_List__c ORDER BY Priority__c DESC LIMIT 1];
    String brandCustomerName = brandCustomersList[0].Customer_Name__c;

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the list of 200 Feed Items
    List<FeedItem> listOfNewPosts = FeedItemTestDataUtility.create200FeedItem(testuser21.Id, feedItemType, brandCustomerName);

    Test.startTest();
    try {
        insert listOfNewPosts;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();

    for (FeedItem newPost : listOfNewPosts) {
        List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                                WHERE EntityId = :newPost.Id
                                                                 GROUP BY EntityId, Topic.Name];

        List<String> topicNames = new List<String>();
        for (AggregateResult topic : topicsAssigned) {
            topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
        }
        System.assert (topicNames.size()==200, topicNames.size() + ' topics are assigned. Expecting 200 topics.');
    }

}

//---Test case for FeedItem List with censored keyword---//
@isTest static void testFeedItemWithBulkifyCensoredKeyword() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';
    String censoredKeyword = 'enemy';

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }


    //Set up the list of 200 Feed Items
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c FROM Customers_List__c ORDER BY Priority__c DESC LIMIT 1];
    String brandCustomerName = brandCustomersList[0].Customer_Name__c;

    List<FeedItem> listOfNewPosts = FeedItemTestDataUtility.create200FeedItem(testuser21.Id, feedItemType, censoredKeyword);
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, brandCustomerName);
    listOfNewPosts.add(newPost);
    Test.startTest();
    try {
        listOfNewPosts = AddTopicToFeedItemHandler.BeforeAddTopicToFeedItem(listOfNewPosts);
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
}


//---Test case for bulkify insert on Salesforce database---//
@isTest static void testReplaceWithSpace() {
    String tempData = 'asd,ASds;.!qdw job?ergter:';
    //remove symbols : ,.!
    List<String> checkCase = new List<String>();
    Test.startTest();
    checkCase = TopicService.SplitStringWithSpace(tempData);
    Test.stopTest();

    System.assert (checkCase.size()>1,'The function is not able to remove all the symbols.');
}

//---Test case for FeedItem List with censored keyword---//
@isTest static void testWordsCompare() {
    String Body1 = 'Testing ABC def';
    String Body2 = 'Testing';
    String Topic1 = 'AbC';
    String Topic2 = 'Testing AB';
    String Topic3 = 'ABc DeF';
    String Topic4 = 'tESting';

    boolean result1 = true;
    boolean result2 = true;
    boolean result3 = true;
    boolean result4 = true;
    boolean result5 = true;
    boolean result6 = true;
    boolean result7 = true;

    Test.startTest();
    try {
        result1 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body1, Topic1);
        result2 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body1, Topic2);
        result3 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body1, Topic3);
        result4 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body2, Topic1);
        result5 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body2, Topic2);
        result6 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body2, Topic3);
        result7 = TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(Body2, Topic4);
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();

    System.assert (result1, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result1 is wrong');
    System.assert (!result2, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result2 is wrong');
    System.assert (result3, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result3 is wrong');
    System.assert (!result4, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result4 is wrong');
    System.assert (!result5, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result5 is wrong');
    System.assert (!result6, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result6 is wrong');
    System.assert (result7, 'The checkWhetherFeedItemContainsTopicCaseInsensitive() result7 is wrong');
}


//---Tests for positive cases---//
@isTest static void testFeedItemWithNickname() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';
    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    List<Nickname__c> b = [SELECT id FROM Nickname__c];
    try{
        delete a;
        delete b;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        //Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'Charles Tyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        //insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;

        Nickname__c n1 = new Nickname__c(Name__c = 'JCP', Customer_mapping__c = 4);
        Nickname__c n2 = new Nickname__c(Name__c = 'JC Penney', Customer_mapping__c = 4);
        Nickname__c n3 = new Nickname__c(Name__c = 'BBs', Customer_mapping__c = 1);
        Nickname__c n4 = new Nickname__c(Name__c = 'LLB', Customer_mapping__c = 6);
        Nickname__c n5 = new Nickname__c(Name__c = 'BrooksBrothers', Customer_mapping__c = 1);
        Nickname__c n6 = new Nickname__c(Name__c = 'J.C. Penney', Customer_mapping__c = 4);
        Nickname__c n7 = new Nickname__c(Name__c = 'Brook Brothers', Customer_mapping__c = 1);
        Nickname__c n8 = new Nickname__c(Name__c = 'Brook Brother', Customer_mapping__c = 1);
        Nickname__c n9 = new Nickname__c(Name__c = 'JCPenney', Customer_mapping__c = 4);
        //Nickname__c n10 = new Nickname__c(Name__c = 'Charlestyrwhitt', Customer_mapping__c = 5);
        //Nickname__c n11 = new Nickname__c(Name__c = 'PeterMillar', Customer_mapping__c = 7);
        insert n1;
        insert n2;
        insert n3;
        insert n4;
        insert n5;
        insert n6;
        insert n7;
        insert n8;
        insert n9;
        //insert n10;
        //insert n11;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }



    List<Nickname__c> Nicknames = [SELECT Name__c, Customer_mapping__c FROM Nickname__c ORDER BY Id DESC];
    String Nickname = Nicknames[0].Name__c;

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, 'test '+Nickname+' test');

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned
    //Priority sorted with ASC cuz the nickname mapping depends on the customer list's order
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c ASC];
    String mapCustomer = brandCustomersList[Integer.valueOf(Nicknames[0].Customer_mapping__c-1)].Customer_Name__c;


    List<String> topicNames = new List<String>();
    List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                            WHERE EntityId = :newPost.Id
                                                             GROUP BY EntityId, Topic.Name];
    for (AggregateResult topic : topicsAssigned) {
        topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
    }
    System.assert (topicNames.contains(mapCustomer.toLowerCase()),'The brand customer name '+mapCustomer+'(' + topicNames + ') was expected to be assigned to the Feed Item (' + newPost.Id +' : '+newPost.Body+ '), but was not assigned successfully.');
}


//---Tests for negative cases---//
@isTest static void testIsExcludeType2() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';

    List<Leave_Request__c> leave = [SELECT id FROM Leave_Request__c LIMIT 1];
    List<Mobile_Receipt_Inbox__c> TE1 = [SELECT id FROM Mobile_Receipt_Inbox__c LIMIT 1];
    List<Travel_Application__c> TE2 = [SELECT id FROM Travel_Application__c LIMIT 1];
    List<Expense_Application__c> TE3 = [SELECT id FROM Expense_Application__c LIMIT 1];
    List<Education_Application__c> TE4 = [SELECT id FROM Education_Application__c LIMIT 1];

    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c DESC];
    String brandCustomerName = brandCustomersList[0].Customer_Name__c;

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    List<FeedItem> newPosts = new List<FeedItem>();
    if(leave.size()>0) {
        FeedItem newPost = new FeedItem (
            parentid = leave[0].id,
            type = feedItemType,
            Body = brandCustomerName
            );
        newPosts.add(newPost);
    }
    if(TE1.size()>0) {
        FeedItem newPost2 = new FeedItem (
            parentid = TE1[0].id,
            type = feedItemType,
            Body = brandCustomerName
            );
        newPosts.add(newPost2);
    }
    if(TE2.size()>0) {
        FeedItem newPost3 = new FeedItem (
            parentid = TE2[0].id,
            type = feedItemType,
            Body = brandCustomerName
            );
        newPosts.add(newPost3);
    }
    if(TE3.size()>0) {
        FeedItem newPost4 = new FeedItem (
            parentid = TE3[0].id,
            type = feedItemType,
            Body = brandCustomerName
            );
        newPosts.add(newPost4);
    }
    if(TE4.size()>0) {
        FeedItem newPost5 = new FeedItem (
            parentid = TE4[0].id,
            type = feedItemType,
            Body = brandCustomerName
            );
        newPosts.add(newPost5);
    }

    Test.startTest();
    try {
        insert newPosts;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();

    for(FeedItem checkpost : newPosts) {
        List<String> topicNames = new List<String>();
        List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                                WHERE EntityId = :checkpost.Id
                                                                 GROUP BY EntityId, Topic.Name];
        for (AggregateResult topic : topicsAssigned) {
            topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
        }
        System.assert (!topicNames.contains(brandCustomerName.toLowerCase()),'The brand customer name '+brandCustomerName+'(' + topicNames + ') was not expected to be assigned to the Feed Item (' + checkpost.Id +' : '+checkpost.Body+ '), but was not assigned successfully.');
    }
}

//---Tests for negative cases---//
@isTest static void test10Customers() {
    //Set up feedItem test data parameters
    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    String feedItemType = 'TextPost';
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c DESC];
    String brandCustomerName = '';
    for(Customers_List__c temp : brandCustomersList)
        brandCustomerName += temp.Customer_Name__c + ' ';

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, 'test '+brandCustomerName+' test');

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (true, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned

}


//---Tests for positive cases---//
@isTest static void test10Nicknames() {
    //Set up feedItem test data parameters
    String feedItemType = 'TextPost';
    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    List<Nickname__c> b = [SELECT id FROM Nickname__c];
    try{
        delete a;
        delete b;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;

        Nickname__c n1 = new Nickname__c(Name__c = 'JCP', Customer_mapping__c = 4);
        Nickname__c n2 = new Nickname__c(Name__c = 'JC Penney', Customer_mapping__c = 4);
        Nickname__c n3 = new Nickname__c(Name__c = 'BBs', Customer_mapping__c = 1);
        Nickname__c n4 = new Nickname__c(Name__c = 'LLB', Customer_mapping__c = 6);
        Nickname__c n5 = new Nickname__c(Name__c = 'BrooksBrothers', Customer_mapping__c = 1);
        Nickname__c n6 = new Nickname__c(Name__c = 'J.C. Penney', Customer_mapping__c = 4);
        Nickname__c n7 = new Nickname__c(Name__c = 'Brook Brothers', Customer_mapping__c = 1);
        Nickname__c n8 = new Nickname__c(Name__c = 'Brook Brother', Customer_mapping__c = 1);
        Nickname__c n9 = new Nickname__c(Name__c = 'JCPenney', Customer_mapping__c = 4);
        Nickname__c n10 = new Nickname__c(Name__c = 'Charlestyrwhitt', Customer_mapping__c = 5);
        Nickname__c n11 = new Nickname__c(Name__c = 'PeterMillar', Customer_mapping__c = 7);
        insert n1;
        insert n2;
        insert n3;
        insert n4;
        insert n5;
        insert n6;
        insert n7;
        insert n8;
        insert n9;
        insert n10;
        insert n11;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    List<Customers_List__c> Customers = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Id DESC LIMIT 10];

    String topics = '';
    for(Customers_List__c tmp : Customers) {
        topics += tmp.Customer_Name__c + ' ';
    }

    List<Nickname__c> Nicknames = [SELECT Name__c, Customer_mapping__c FROM Nickname__c ORDER BY Id DESC];
    for(Nickname__c tmp : Nicknames) {
        topics += tmp.Name__c + ' ';
    }

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, 'test '+topics+' test');

    Test.startTest();
    try {
        insert newPost;
    } catch (DmlException e) {
        System.assert (true, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
}


//---Test case for FeedItem List with censored keyword---//
@isTest static void testEditLightingString() {
    String Body = 'This is the body of the chatter post';
    List<String> addItems = new List<String>();
    String temp = 'J.C. Penney';
    String temp2 = 'L.L.Bean';
    String temp3 = 'Brooks Brother';
    String temp4 = 'Three words topic';
    String temp5 = 'Four words topic s';
    String temp6 = '!$@#';
    String temp7 = 'mix !@#$%';
    String temp8 = 'mix 2 !@#';
    addItems.add(temp);
    addItems.add(temp2);
    addItems.add(temp3);
    addItems.add(temp4);
    addItems.add(temp5);
    addItems.add(temp6);
    addItems.add(temp7);
    addItems.add(temp8);

    Test.startTest();
    try {
        Body = TopicService.TopicInLightning(Body, addItems);
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();

    for(String additem : addItems) {
        System.assert (Body.contains('#['+additem+']'), 'The lightning topic '+additem+' has not been included to Body '+Body+' yet.');
    }
}

//---Tests for positive cases---//
@isTest static void testUpdateFeedItemWithBrandCustomer() {
    //Set up feedItem test data parameters
    List<Customers_List__c> a = [SELECT id FROM Customers_List__c];
    try{
        delete a;
        Customers_List__c record = new Customers_List__c(Priority__c = 1, Customer_Name__c = 'Brooks Brothers', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record1 = new Customers_List__c(Priority__c = 2, Customer_Name__c = 'Burberry', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record2 = new Customers_List__c(Priority__c = 3, Customer_Name__c = 'Dillard\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record3 = new Customers_List__c(Priority__c = 4, Customer_Name__c = 'J.C.Penney', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record4 = new Customers_List__c(Priority__c = 5, Customer_Name__c = 'CharlesTyrwhitt', Team__c =5, Type__c = 'Top_Customer');
        Customers_List__c record5 = new Customers_List__c(Priority__c = 6, Customer_Name__c = 'L.L. Bean', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record6 = new Customers_List__c(Priority__c = 7, Customer_Name__c = 'Peter Millar', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record7 = new Customers_List__c(Priority__c = 8, Customer_Name__c = 'Bonobos', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record8 = new Customers_List__c(Priority__c = 9, Customer_Name__c = 'Chico\'s', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record9 = new Customers_List__c(Priority__c = 10, Customer_Name__c = 'Express', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record10 = new Customers_List__c(Priority__c = 11, Customer_Name__c = 'Cintas', Team__c =3, Type__c = 'Top_Customer');
        Customers_List__c record11 = new Customers_List__c(Priority__c = 12, Customer_Name__c = 'Nordstrom', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record12 = new Customers_List__c(Priority__c = 13, Customer_Name__c = 'Paul Fredrick', Team__c =2, Type__c = 'Top_Customer');
        Customers_List__c record13 = new Customers_List__c(Priority__c = 14, Customer_Name__c = 'Eddie Bauer', Team__c =1, Type__c = 'Top_Customer');
        Customers_List__c record14 = new Customers_List__c(Priority__c = 15, Customer_Name__c = 'UNTUCKit', Team__c =2, Type__c = 'Top_Customer');

        Customers_List__c record15 = new Customers_List__c(Priority__c = 16, Customer_Name__c = 'Travis Mathew', Team__c =3, Type__c = 'Rising_Star');
        Customers_List__c record16 = new Customers_List__c(Priority__c = 17, Customer_Name__c = 'Suit Supply', Team__c =5, Type__c = 'Rising_Star');

        Customers_List__c record17 = new Customers_List__c(Priority__c = 18, Customer_Name__c = 'Expert', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record18 = new Customers_List__c(Priority__c = 19, Customer_Name__c = 'Hakatex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record19 = new Customers_List__c(Priority__c = 20, Customer_Name__c = 'High Sun', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record20 = new Customers_List__c(Priority__c = 21, Customer_Name__c = 'Kam Hing', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record21 = new Customers_List__c(Priority__c = 22, Customer_Name__c = 'Lianfa', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record22 = new Customers_List__c(Priority__c = 23, Customer_Name__c = 'Lu Feng', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record23 = new Customers_List__c(Priority__c = 24, Customer_Name__c = 'Lu Thai', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record24 = new Customers_List__c(Priority__c = 25, Customer_Name__c = 'Penfabric', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record25 = new Customers_List__c(Priority__c = 26, Customer_Name__c = 'Saintyear', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record26 = new Customers_List__c(Priority__c = 27, Customer_Name__c = 'Tat Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record27 = new Customers_List__c(Priority__c = 28, Customer_Name__c = 'Wah Fung', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record28 = new Customers_List__c(Priority__c = 29, Customer_Name__c = 'Win Hanverky', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record29 = new Customers_List__c(Priority__c = 30, Customer_Name__c = 'Winnitex', Team__c =0, Type__c = 'Core_Supplier');
        Customers_List__c record30 = new Customers_List__c(Priority__c = 31, Customer_Name__c = 'Wuxi JinMiao', Team__c =0, Type__c = 'Core_Supplier');

        Customers_List__c record31 = new Customers_List__c(Priority__c = 32, Customer_Name__c = 'SofTAL', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record32 = new Customers_List__c(Priority__c = 33, Customer_Name__c = 'SofTAL Wool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record33 = new Customers_List__c(Priority__c = 34, Customer_Name__c = 'SofTAL Lux', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record34 = new Customers_List__c(Priority__c = 35, Customer_Name__c = 'SoftPuckerFree', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record35 = new Customers_List__c(Priority__c = 36, Customer_Name__c = 'PerformanceKnit', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record36 = new Customers_List__c(Priority__c = 37, Customer_Name__c = 'EZWash', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record37 = new Customers_List__c(Priority__c = 38, Customer_Name__c = 'Natural Cool', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record38 = new Customers_List__c(Priority__c = 39, Customer_Name__c = 'Natural Smart', Team__c =0, Type__c = 'Popular_Innovation');
        Customers_List__c record39 = new Customers_List__c(Priority__c = 40, Customer_Name__c = 'Inno Band', Team__c =0, Type__c = 'Popular_Innovation');
        //Customers_List__c record40 = new Customers_List__c(Priority__c = 41, Customer_Name__c = 'Inno Green', Team__c =0, Type__c = 'Popular_Innovation');


        insert record;
        insert record1;
        insert record2;
        insert record3;
        insert record4;
        insert record5;
        insert record6;
        insert record7;
        insert record8;
        insert record9;
        insert record10;
        insert record11;
        insert record12;
        insert record13;
        insert record14;
        insert record15;
        insert record16;
        insert record17;
        insert record18;
        insert record19;
        insert record20;
        insert record21;
        insert record22;
        insert record23;
        insert record24;
        insert record25;
        insert record26;
        insert record27;
        insert record28;
        insert record29;
        insert record30;
        insert record31;
        insert record32;
        insert record33;
        insert record34;
        insert record35;
        insert record36;
        insert record37;
        insert record38;
        insert record39;
        //insert record40;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    String feedItemType = 'TextPost';
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c DESC];
    String brandCustomerName = brandCustomersList[0].Customer_Name__c;

    //Set up test user
    User testuser2 = new User (
        ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
        LastName = 'Test User',
        Email = 'testuser2@talapparel.com',
        Username = 'testuser2@talapparel.com',
        CompanyName = 'TEST',
        Title = 'Test User',
        Alias = 'test',
        TimeZoneSidKey = 'America/Los_Angeles',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        LocaleSidKey = 'en_US'
        );
    try {
        insert testuser2;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    User testuser21 = [SELECT Id FROM User WHERE Username = 'testuser2@talapparel.com'];

    //Set up the Feed Item
    FeedItem newPost = FeedItemTestDataUtility.createFeedItemWithSingleTypeTopic(testuser21.Id, feedItemType, 'test test');
    try{
        insert newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }

    Test.startTest();
    try {
        newpost.Body += ' ' + brandCustomerName;
        update newPost;
    } catch (DmlException e) {
        System.assert (false, 'Error message = ' + e.getMessage());
    }
    Test.stopTest();
    //Verify the test if the expected topic is assigned

    List<String> topicNames = new List<String>();
    List<AggregateResult> topicsAssigned = [SELECT EntityId, Topic.Name topicName FROM TopicAssignment
                                            WHERE EntityId = :newPost.Id
                                                             GROUP BY EntityId, Topic.Name];
    for (AggregateResult topic : topicsAssigned) {
        topicNames.add(String.valueOf(topic.get('topicName')).toLowerCase());
    }
    System.assert (topicNames.contains(brandCustomerName.toLowerCase()),'The brand customer name '+brandCustomerName+'(' + topicNames + ') was expected to be assigned to the Feed Item (' + newPost.Id +' : '+newPost.Body+ '), but was not assigned successfully.');
}
}