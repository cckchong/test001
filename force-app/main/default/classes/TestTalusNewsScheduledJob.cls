@isTest
private class TestTalusNewsScheduledJob {

    static testMethod void TalusNewsScheduledJobTest() {
        
        String xml = '<rss version="2.0"><channel><item><title>T</title><description>Textile industry players want effective implementation of economic stimulus packages to improve competitiveness as the country is moving toward free trade agreements with several countries.</description><link>http://www.google.com</link><author>The Jakarta Post</author><pubDate>Fri, 19 Feb 2016 00:00:00 GMT</pubDate></item></channel></rss>';
        
        TalusNewsScheduledJob.convertFeed(xml);
        
        
    }

}