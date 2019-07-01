@isTest
private class TestTalusNewsTrigger {

    static testMethod void TalusNewsTriggerTest() {
        
        FeedItem f = new FeedItem(
            CreatedById = System.Label.DowJonesUserId,
            ParentId = System.Label.FactivaRSSChatterGroupId,
            Type = 'ContentPost',
            RelatedRecordId = '0686F000001kRifQAE',
            Body = 'a'
        );
        
        insert f;
        
    }

}