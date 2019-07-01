/*****************************************************
Controller for Landing Tab (ConnecTAL) Page

Function getPageURL()
1. Find URL the default landing local site for the user
	Get    a. User Local Site
		   b. Specific Local Site Page Using the Unique Page Name
		   c. Specific Local Site template Name
		   d. Construct the landing Page URL
Function getDepartmentalPage()
2. Find URL of the departmental page
	Get    a. User Local Site and Department Name
		   b. Specific Local Site Page Using the Unique Page Name
		   c. Specific Local Site template Name
		   d. Construct the landing Page URL
******************************************************/
public without sharing class ACGLandingCtrl {
	
	User usr = new User();
	
	public ACGLandingCtrl(){
		//Get Current User Info
		usr = SystemUtil.getCurrentUserInfo();
	}
	
	public String getPageUrl(){
		String url='';
		if(usr.Default_Landing_Page__c != '' && usr.Default_Landing_Page__c != null) {			
			//url =  ACGUtil.getPageURL(usr.Default_Landing_Page__c, 'Site');
			url =  ACGUtil.getDefaultLandingPageURL(usr.Default_Landing_Page__c);
			
		}
		return url;
	}
	
	public PageReference getDepartmentalPage(){
		//Construct Unique Page Name for Category Page
		String strContentCategory = ApexPages.currentPage().getParameters().get('ContentCategory') == null ? '' :  ApexPages.currentPage().getParameters().get('ContentCategory');
		String strLevel = ApexPages.currentPage().getParameters().get('Level') == null ? '' :  ApexPages.currentPage().getParameters().get('Level');
		String strTarget = ApexPages.currentPage().getParameters().get('Target') == null ? '' :  ApexPages.currentPage().getParameters().get('Target');
		String directURL='';
		//Check if Unique Page Exist and get Template Unique Name
		List<Portal_Content__c> uniquePages = 
			[
				SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c, Content_Category__c, Distribution_Level__c, Distribution_Target__c
				FROM Portal_Content__c 
				WHERE RecordType.DeveloperName = 'Settings'
				AND Content_Category__c = :strContentCategory
			];
		system.debug('@@@ strContentCategory ' + strContentCategory);
		system.debug('@@@ uniquePages ' + uniquePages.size());
		if(!uniquePages.isEmpty() && uniquePages.size() > 0) {
			if(uniquePages.size() == 1) {
				directURL = '/apex/' + uniquePages.get(0).Template_Unique_Name__c + '?uniquePageName=' + uniquePages.get(0).Unique_Page_Name__c;				
			} else {
				for(Portal_Content__c acg: uniquePages) {
					if((acg.Distribution_Target__c == strTarget && acg.Distribution_Level__c == strLevel) ||
						acg.Content_Category__c.contains('Blog') || acg.Content_Category__c.contains('Office')) {
						directURL = '/apex/' + acg.Template_Unique_Name__c + '?uniquePageName=' +acg.Unique_Page_Name__c;
						break;
					}
				}
			}
			directURL += '&' +Label.ConnecTalTab;
		} else {
			directURL = '/apex/UnderConstruction';
			directURL += '?' + Label.ConnecTalTab;	
		}
		//Construct URL for landing page
		system.debug('@@@ directURL ' + directURL);
		PageReference url = new PageReference(directURL);
		return url;
	}
	
	public PageReference getSiteMapURL(){
 		String strLandingPage = ApexPages.currentPage().getParameters().get('LandingPage') == null ? '' :  ApexPages.currentPage().getParameters().get('LandingPage');
 		String strConCat = ApexPages.currentPage().getParameters().get('ConCat') == null ? '' :  ApexPages.currentPage().getParameters().get('ConCat');
		//Check if Unique Page Exist and get Template Unique Name
		List<Portal_Content__c> uniquepages = new List<Portal_Content__c>();
		
		List<String> strs = SystemUtil.getPicklistValues('Portal_content__c', 'Content_Category__c');
		Set<String> setConCat = new Set<String>();
		setConCat.addAll(strs);
		if(strConCat !='' && strLandingPage == '') {
			//Blog or Office Page
			uniquepages = 
				[
					SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
					FROM Portal_Content__c 
					WHERE RecordType.DeveloperName = 'Settings'
					AND Page_Name__c = 'MainPage'
					AND Content_Category__c = :strConCat
					limit 1
				];
			system.debug('@@@ Blog Page ' + uniquepages);
		} else if(strConCat =='' && strLandingPage != '') {
			//General Landing Page
			uniquepages = 
				[
					SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
					FROM Portal_Content__c 
					WHERE RecordType.DeveloperName = 'Settings' 
					AND Distribution_Target__c = :strLandingPage
					AND Page_Name__c = 'MainPage'
					AND Content_Category__c = 'General'
					limit 1
				];
			system.debug('@@@ General Page ' + uniquepages);
		} else if(strConCat !='' && strLandingPage != '') {
			//Category Page
			uniquepages = 
				[
					SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
					FROM Portal_Content__c 
					WHERE RecordType.DeveloperName = 'Settings' 
					AND Distribution_Target__c = :strLandingPage
					AND Page_Name__c = 'MainPage'
					AND Content_Category__c = :strConCat
					limit 1
				];
			system.debug('@@@ Category Page ' + uniquepages);
		}
		String directURL='';
		if(uniquepages.size()>0) {
			directURL = '/apex/' + uniquepages.get(0).Template_Unique_Name__c + '?uniquePageName=' + uniquepages.get(0).Unique_Page_Name__c;
			directURL += '&' +Label.ConnecTalTab;	
		}
		else {
			directURL = '/apex/UnderConstruction';
			directURL += '?' + Label.ConnecTalTab;	
		}
		
		//Construct URL for landing page		
		PageReference url = new PageReference(directURL);
		return url;
	}	
	
	/*
	public PageReference getSiteMapURL(){
 		String strSiteName = ApexPages.currentPage().getParameters().get('Sitename') == null ? '' :  ApexPages.currentPage().getParameters().get('Sitename');
		//Check if Unique Page Exist and get Template Unique Name
		List<Portal_Content__c> uniquepages = 
			[
				SELECT Id, Unique_Page_Name__c, Template_Unique_Name__c
				FROM Portal_Content__c 
				WHERE RecordType.DeveloperName = 'Settings' 
				AND Distribution_Target__c = :strSiteName
				AND Page_Name__c = 'MainPage'
				AND Content_Category__c = 'General'
				limit 1
			];
		String directURL='';
		if(uniquepages.size()>0) {
			directURL = '/apex/' + uniquepages.get(0).Template_Unique_Name__c + '?uniquePageName=' + uniquepages.get(0).Unique_Page_Name__c;
			directURL += '&' +Label.ConnecTalTab;	
		}
		else {
			directURL = '/apex/UnderConstruction';
			directURL += '?' + Label.ConnecTalTab;	
		}
		
		//Construct URL for landing page		
		PageReference url = new PageReference(directURL);
		return url;
	}
	*/
}