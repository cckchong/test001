/**
 * Scheduled job to fetch Dow Jones RSS feed into Chatter Group
 * @author Ken Yau
 * @date 22/02/2016
 */
public class TalusNewsScheduledJob implements Schedulable {

    static Dom.Document doc = new Dom.Document();

    @future(callout=true)
    public static void convertFeed(String xml) {
        System.Debug('Call Web Service to get the RSS feed.');
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        // url that returns the XML in the response body
        req.setEndpoint(System.Label.FactivaRSSFeed);
        req.setMethod('GET');
        if (xml == '') {
            System.Debug('Call Web Service to get the RSS feed.');
            HttpResponse res = h.send(req);
            TalusNewsScheduledJob.doc = res.getBodyDocument();
            System.Debug('Got the XML from Web.');
        } else {
            TalusNewsScheduledJob.doc.load(xml);
        }

        List<FeedItem> feedsToInsert = new List<FeedItem>{};
        System.Debug('Number of items before loop: ' + feedsToInsert.size());

        for(dom.XmlNode channel : TalusNewsScheduledJob.doc.getRootElement().getChildElements()) {
            if (channel.getName() == 'channel') {
                for(dom.XmlNode node : channel.getChildElements()) {
                    if (node.getName() == 'item') {
                        String a_title = node.getChildElement('title', null).getText();
                        String a_description = node.getChildElement('description', null).getText();
                        String a_link = node.getChildElement('link', null).getText();
                        String a_author = node.getChildElement('author', null).getText();
                        String a_pubDate = node.getChildElement('pubDate', null).getText();
                        
                        System.Debug('Title: ' + a_title );                        
                        
                        FeedItem f = new FeedItem (
                        CreatedById = System.Label.DowJonesUserId,
                        Title = a_title,
                        Type = 'LinkPost',
                        LinkUrl = a_link,
                        Body = a_author + ', ' + a_pubDate + '\r\n' + a_description,
                        ParentId = System.Label.FactivaRSSChatterGroupId);
                        feedsToInsert.add(f);
                    }
                }
            }
        }     

        System.Debug('Number of items after loop: ' + feedsToInsert.size());        
        insert feedsToInsert;
    }
    
    /**
     * Execute the scheduled job
     */
    public static void execute(SchedulableContext sc) {
        System.Debug('Start run the scheduled job.');                
        TalusNewsScheduledJob.convertFeed('');
        System.Debug('Finish run the scheduled job.');  
    }    
}