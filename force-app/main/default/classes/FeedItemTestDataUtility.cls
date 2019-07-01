/**
 * Utility class to create Feed Item test data
 *
 * @author  Rodrigue Poon
 * @version 1.0
 * @since   2018-07-31
 */
@isTest
public class FeedItemTestDataUtility {
public static FeedItem createFeedItemWithSingleTypeTopic (Id userID, String feedItemType, String topicToInject) {
    FeedItem newPost = new FeedItem (
        parentid = userID,
        type = feedItemType,
        Body = topicToInject,
        CreatedById = userID
        );
    //Body = 'Today ' + topicToInject +' did a very good job.'
    return newPost;
}

public static FeedItem createFeedItemWithMultiTypeTopic (Id userID, String feedItemType, String topicToInject1, String topicToInject2, String topicToInject3, String topicToInject4, String topicToInject5) {
    FeedItem newPost = new FeedItem (
        parentid = userID,
        type = feedItemType,
        CreatedById = userID,
        Body = topicToInject1 + ' Awarded the Platinum Certification Status under JCP Supplier Status Program 2017 Based on a list of very comprehensive assessment criteria covering 3 major aspects (namely Delivery, Quality & Compliance) with 18 scoring items, I am excited to share that TAL has been awarded by ' + topicToInject2 + ' the Platinum Certification Status (the highest status of the program) again, which is the 2nd year in a row since the program roll-out in last year ! This is an important recognition of the premium quality products and great services provided to JCP by our teams, including but not limited to ' + topicToInject3 + ', VNG,ETG,KAT, MS, RS, PPC, PE, etc,  Great job, everyone !  Lets work together to continue to delight ' + topicToInject4 + ' and other customers and grow the business of the ' + topicToInject5 + 'Group !'
        );
    return newPost;
}

public static List<FeedItem> create200FeedItem (Id userID, String feedItemType, String topicToInject) {

    List<FeedItem> listOfFeedItem = new List<FeedItem>();
    for (integer i; i<200; i++) {
        FeedItem newPost = new FeedItem(
            parentid = userID,
            type = feedItemType,
            CreatedById = userID,
            Body = 'Today ' + topicToInject + ' ' + i + ' did a very good job.'
            );
        listOfFeedItem.add(newPost);
    }
    return listOfFeedItem;
}
}