public with sharing class TalMobileNavigationRouting {
	public enum NAV_RESULT {BACK, OBJECTID, URL}
	public NAV_RESULT navResult {get;set;}
	public String navResultObjectId {get;set;}
	public String navResultUrl {get;set;}
	public String infoMessage {get;set;}
	
	public TalMobileNavigationRouting() {
		
	}
}