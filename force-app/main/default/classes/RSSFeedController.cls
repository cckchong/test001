public without sharing class RSSFeedController {
    public Integer numColumn  {get;set;}
    
    public String rssURL {get;set;}
    
    public String panelTitle {get;set;}
    
    public Id recordID { get; set; }
    
    public RSSFeedController(){
        numColumn = 10;
    }
}