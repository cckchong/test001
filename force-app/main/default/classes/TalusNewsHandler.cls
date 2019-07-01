/**
 * Handler for TalusNews
 * @author Ken Yau
 * @date 22/02/2016
 */
public class TalusNewsHandler {

    public Dom.Document getDocument() {
        Dom.Document doc = null;
        if (!System.Test.isRunningTest()) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            // url that returns the XML in the response body
            req.setEndpoint(System.Label.FactivaRSSFeed);
            req.setMethod('GET');
            HttpResponse res = h.send(req);
            doc = res.getBodyDocument();
        }
        return doc;    
    }

    public void convertFeed(String xml) {
        Dom.Document doc = new Dom.Document();
        if (xml == '') {
            doc = getDocument();
        } else {
            doc.load(xml);
        }

        List<FeedItem> feedsToInsert = new List<FeedItem>{};

        for(dom.XmlNode channel : doc.getRootElement().getChildElements()) {
            if (channel.getName() == 'channel') {
                for(dom.XmlNode node : channel.getChildElements()) {
                    if (node.getName() == 'item') {
                        String a_title = node.getChildElement('title', null).getText();
                        String a_description = node.getChildElement('description', null).getText();
                        String a_link = node.getChildElement('link', null).getText();
                        String a_author = node.getChildElement('author', null).getText();
                        String a_pubDate = node.getChildElement('pubDate', null).getText();
                        
                        FeedItem f = new FeedItem (
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

        insert feedsToInsert;
    }
}