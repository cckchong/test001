/*
	LibraryDateWrapper class
	
	@Author: AN, WG
	@Object: Library_Item__c
	@Description: Used to wrap the Date type fields for page displaying from date & to date
*/
public class LibraryDateWrapper {

    public Library_Item__c proxy {get;set;}
    
    //constructor, initial the Library_Item__c object proxy
    public LibraryDateWrapper() {
        proxy = new Library_Item__c();
    }
    
    //constructor, inital the proxy with start date and end date
    public LibraryDateWrapper(Date minDate, Date maxDate) {
        if(proxy ==null)proxy = new Library_Item__c();
        this.proxy.Tech_Start_Date_Proxy__c = minDate;
        this.proxy.Tech_End_Date_Proxy__c = maxDate;
    }
}