/*****************************************************
Utility Class for Chatter Group Actions

1. Post Text Post to chatter group
Used in the ArticleEditPageController 
When an article is published, the title, summary and the link will be post to the corresponding chatter group 
******************************************************/
public without sharing class ChatterUtil {

    // makes a simple chatter text post to the specified users from the running user
    /**
    public static ID simpleTextPostWithMultipleMentions(Id recordId, List<Id> usersToMention, String postText) {
        ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // add the text segment
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = postText + ' ';
        messageInput.messageSegments.add(textSegment);

        for(Id user : usersToMention) {
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = user;
            messageInput.messageSegments.add(mentionSegment);
        }

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = messageInput;
        //TESTING
        feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;

        // post it
        return ConnectApi.ChatterFeeds.postFeedItem(null, feedType, recordId, feedItemInput, null).id;
    }**/
    // method overloading
    // use default visibility setting
    public static ID simpleTextPostWithMultipleMentions(Id recordId, List<Id> usersToMention, String postText) {

        return simpleTextPostWithMultipleMentions(recordId, usersToMention, postText, 'InternalUsers');
    }
    
    // makes a simple chatter text post to the specified users from the running user
    public static ID simpleTextPostWithMultipleMentions(Id recordId, List<Id> usersToMention, String postText, String visibilityType) {
        ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // add the text segment
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = postText + ' ';
        messageInput.messageSegments.add(textSegment);

        for(Id user : usersToMention) {
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = user;
            messageInput.messageSegments.add(mentionSegment);
        }

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = messageInput;
        // set Chatter post's visibility
        // Default: InternalUsers
        //         AllUsers: internal + partners
        if (visibilityType == 'AllUsers'){
            feedItemInput.visibility = ConnectApi.FeedItemVisibilityType.AllUsers;
        }

        // post it
        return ConnectApi.ChatterFeeds.postFeedItem(null, feedType, recordId, feedItemInput, null).id;
    }
    
    // makes a simple chatter text post to the specified user from the running user 
    public static void simpleTextPostWithMention(Id recordId, Id userToMention, String postText) { 

        ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;

        ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        // add the text segment
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        textSegment.text = postText;
        messageInput.messageSegments.add(textSegment);

        ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
        mentionSegment.id = userToMention;
        messageInput.messageSegments.add(mentionSegment);       

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = messageInput;

        // post it
        ConnectApi.ChatterFeeds.postFeedItem(null, feedType, recordId, feedItemInput, null);  

    }     
    // makes a chatter post with some text and a link
    public static void simpleLinkPost(Id userId, String postText, String url, String urlName) {    

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = new ConnectApi.MessageBodyInput();

        // add the text segment
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegment.text = postText;
        feedItemInput.body.messageSegments.add(textSegment);

        // add the attachment
        ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
        linkIn.urlName = urlName;
        linkIn.url = url;
        feedItemInput.attachment = linkIn;

        // post it!
        ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, userId, feedItemInput, null);

    }   
    /*
    public static void mentionUser(Id userToMention, String postText) {    
    // Post a feed item that has an @-mention.

    String communityId = null;
    ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;

    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);

    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
    mentionSegment.id = userToMention;
    messageInput.messageSegments.add(mentionSegment);       

    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    input.body = messageInput;

    ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(communityId, feedType, userToMention, input, null);
    }
    */
}