/*
	LibraryErrorPageCtrl Class
	
	@Author: AN, WG
	@Description: Utility class for returning the message info which the URL contains 'msg' parameter
*/
public with sharing class LibraryErrorPageCtrl {

	//return the value from param msg
	public String message {get{
		return ApexPages.currentPage().getParameters().get('msg');		
	}set;} 
}