/**
 * The AddTopicToFeedItemHandler handles the business logic for the AddTopicToFeedItemTrigger
 * to identify keywords from users' posts on Salesforce Chatter and
 * automatically assign related topics to the new post.
 *
 * @author  Rodrigue Poon
 * @since   2018-03-23
 *
 * @editor Jason Tam
 * @version 3
 * @last edit 2018-07-12
 *
 * Included Innovation
 */

public class AddTopicToFeedItemHandler {

//check whether the feeditem contains the censored keyword
public static boolean BeforeAddTopicToFeedItem (FeedItem newFeedItem){
    if(newFeedItem.Body == null) return false;
    List<Censored_Feed_Item_Keyword__c> censoredList = [SELECT Name FROM Censored_Feed_Item_Keyword__c];
    for (Censored_Feed_Item_Keyword__c censoredWord : censoredList)
        if (newFeedItem.Body.containsIgnoreCase(String.valueOf(censoredWord.Name)))
            return true;

    return false;
}

//the overload function is build for the RSS Post Schedule job in case censor function
public static List<FeedItem> BeforeAddTopicToFeedItem (List<FeedItem> newFeedItem){

    List<Censored_Feed_Item_Keyword__c> censoredList = [SELECT Name FROM Censored_Feed_Item_Keyword__c];
    List<FeedItem> returnFeedItemList = new List<FeedItem>();

    for (FeedItem feedItem : newFeedItem) {
        if(feedItem.Body == null) continue;
        for (Censored_Feed_Item_Keyword__c censoredWord : censoredList)
            //avoid null pointer error
            //drop the feedItems with censored keywords
            if (!feedItem.Body.containsIgnoreCase(String.valueOf(censoredWord.Name))) {
                returnFeedItemList.add(feedItem);
                break;
            }
    }
    return returnFeedItemList;
}

//exclude Sample App Feed
public static boolean isGroupPost (FeedItem newFeedItem){
    Id parent = newFeedItem.ParentId;
    //separately check so that the run time of the function may get shorten
    List<CollaborationGroup> sample = [SELECT id FROM CollaborationGroup WHERE id =: parent];
    if (sample.size() > 0) return true;

    return false;
}

public static void AddTopicToFeedItem (List<FeedItem> newFeedItem){
    //---Initialize name list from brand customers, nicknames and innovations---//
    List<Customers_List__c> brandCustomersList = [SELECT Customer_Name__c, Priority__c FROM Customers_List__c ORDER BY Priority__c ASC];
    List<Nickname__c> Nicknames = [SELECT Name__c, Customer_mapping__c FROM Nickname__c];

    //Store the customers' name and innovations' name to string
    List<String> TopicCheckList = new List<String>();
    for(Customers_List__c temp : brandCustomersList) {
        TopicCheckList.add(temp.Customer_Name__c);
    }

    //existingTopicNames-> topics already existed; TopicCheckList-> Topics that DB should have included
    for(Customers_List__c temp : brandCustomersList) {
        try{
            Topic newTopicToCreate = new Topic(Name = temp.Customer_Name__c);
            insert newTopicToCreate;
        } catch (DmlException e) {
            System.debug('An error has occured when inserting a new record to Topic: ' + e.getMessage());
        }
    }

    //List of topics for comparison
    List<Topic> topicList = [SELECT Id, Name FROM Topic WHERE Name In :TopicCheckList];

    //Set up list of topics on the exclusion
    List<String> excludedTopicNames = new List<String>();
    List<Excluded_Feed_Item_Keyword__c> excludedTopics = [SELECT Id, Name FROM Excluded_Feed_Item_Keyword__c
                                                          WHERE Item_Type__c = 'User Generated Keyword'];
    for (Excluded_Feed_Item_Keyword__c excludedTopic : excludedTopics) {
        excludedTopicNames.add(String.valueOf(excludedTopic.Name).toLowerCase());
    }


    //---Process Starts---//
    for (FeedItem feedItem : newFeedItem) {
        //avoid null pointer error
        if(feedItem.Body == null) continue;

        String feedItemBody = string.valueOf(feedItem.Body);

        //Set up list of topics manually assigned to the new Feed Item
        List<TopicAssignment> newTopicAssignments = [SELECT EntityId FROM TopicAssignment
                                                     WHERE EntityId = :feedItem.Id];

        Boolean TypeIncorrect = false;
        //check whether the feed item is belong to the excluded types
        //In this excluded part, it is better to check those need to add topic cuz the number of comparison can be reduced
        if(feedItem.CreatedById != feedItem.ParentId) {
            if(isGroupPost(feedItem))   TypeIncorrect = false;
             else TypeIncorrect = true;
        }

        //---Check if user had manually assigned topic(s) to the new Feed Item & whether topic is on the exclusion list---//
        if(!( !newTopicAssignments.isEmpty() || newTopicAssignments.size() > 0 || TypeIncorrect) ) {
            //---Checks whether the Feed Item Body contains any keywords from the Brand Customer List, Nickname List or Innovation List---//

            //avoid no of topic > 10
            Integer numberOfTopic = 0;
            //record the customer-mapping to avoid redundant search on nickname
            List<Integer> CustomerAssigned = new List<Integer>();
            //record the innovation-mapping to avoid redundant search on nickname

            //check for every elements on the list -> Customer -> Nickname -> Innovation
            for (Customers_List__c brandCustomer : brandCustomersList) {
                if (TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(feedItemBody,brandCustomer.Customer_Name__c)) {
                    if(numberOfTopic >= 10) {
                        feedItem.addError('Maximum number of topic assignments have been exceeded.');
                        break;
                    }
                    //find the corresponding topic
                    for(Topic topicTemp : topicList) {
                        //The condition after || is needed
                        // - the function sometimes cannot recognize the exact equal but with rich text topic
                        //   ^.equals() function helps include those cases
                        // ****** Please do not drop either one of them \/
                        if(TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(topicTemp.Name,brandCustomer.Customer_Name__c) || topicTemp.Name.equals(brandCustomer.Customer_Name__c)) {
                            //** Assign topic
                            TopicService.assignTopicToFeedItem(feedItem, String.valueOf(topicTemp.Id), topicTemp.Name, excludedTopicNames);
                            numberOfTopic++;
                            CustomerAssigned.add(Integer.valueOf(brandCustomer.Priority__c));
                            break;
                        }
                    }
                }
            }
            for (Nickname__c Nickname : Nicknames) {
                //Skip the nickname search if the formal name has already been assigned
                if (CustomerAssigned.contains(Integer.valueOf(Nickname.Customer_mapping__c)))   continue;

                if (TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(feedItemBody,Nickname.Name__c)) {
                    if(numberOfTopic >= 10) {
                        feedItem.addError('Maximum number of topic assignments have been exceeded.');
                        break;
                    }
                    //find the corresponding topic
                    //Nickname.Customer_mapping__c = priority of the customer
                    //brandCustomersList has been sorted by priority
                    String mapCustomer = brandCustomersList[Integer.valueOf(Nickname.Customer_mapping__c-1)].Customer_Name__c;
                    for(Topic topicTemp : topicList) {
                        //The condition after || is needed
                        // - the function sometimes cannot recognize the exact equal but with rich text topic
                        // - .equals() function helps include those cases
                        // ****** Please do not drop either one of them
                        if(TopicService.checkWhetherFeedItemContainsTopicCaseInsensitive(topicTemp.Name,mapCustomer) || topicTemp.Name.equals(mapCustomer)) {
                            //***Assign topic
                            TopicService.assignTopicToFeedItem(feedItem, String.valueOf(topicTemp.Id), topicTemp.Name, excludedTopicNames);
                            numberOfTopic++;
                            break;
                        }
                    }
                }
            }
            
        } else {
            system.debug('User has already assigned a topic hashtag to the Feed Item. No topic will be automatically assigned.');
        }
    }

}
}