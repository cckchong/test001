trigger TALusNewsFeedItemTrigger on FeedItem (after insert) {
    for (FeedItem f : Trigger.new) {
        if (f.CreatedById == System.Label.DowJonesUserId && f.ParentId == System.Label.FactivaRSSChatterGroupId) {
            Feeditem a = [select Id, Type, Body, RelatedRecordId from FeedItem where Id=:f.Id];
            a.Body = Datetime.now().format('MMM dd, yyyy') + '. Download your copy of TALusNews today. Read all about it!';
            update a;
            
            if (a.Type == 'ContentPost') {
                ContentVersion b = [select Id, Title from ContentVersion where Id=:a.RelatedRecordId];
                b.Title = 'TALusNews – '+ Datetime.now().format('MMM dd, yyyy') +'.pdf';
                update b;
            }
        }
    }
}