/**
 * The AddTopicToFeedItemTrigger is implemented on the FeedItem Object
 * to identify keywords from users' posts on Salesforce Chatter and
 * automatically tag the post with existing topic
 *
 * @author  Rodrigue Poon
 * @since   2018-03-23
 *
 * @editor Jason Tam
 * @version 2.0
 * @last edit 2018-6-1
 *
 * Debug and modify the program follow the new instruction approached at the meeting(2018-5-30)
 *
 */

trigger AddTopicToFeedItemTrigger on FeedItem (after insert, before insert, after update) {
    if (Trigger.IsBefore) {
        for (FeedItem feedItem : Trigger.new) {
            if(AddTopicToFeedItemHandler.BeforeAddTopicToFeedItem(feedItem)) {
                //Comment out the following method:feedItem.addError() to disable the Feed Item censorship feature
                feedItem.addError('This post contains explicit wordings which are found inappropriate for work. It will not be published in Chatter. Please review and update your Chatter post with appropriate wordings before sharing. For further query, please log incident case and contact system administrator.');
            }
        }
    }
    if (Trigger.IsAfter) {
        AddTopicToFeedItemHandler.AddTopicToFeedItem(Trigger.new);
    }
    if (Trigger.IsUpdate) {
        AddTopicToFeedItemHandler.AddTopicToFeedItem(Trigger.new);
    }
}