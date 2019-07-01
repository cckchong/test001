public without sharing class TEAccommodationTriggerHandler {
     
    Public static void updateAccommodationStatus(Map<id, Accommodation__c> oldAccommpdationMap, Map<id, Accommodation__c> newAccommpdationMap){
        List<ID> cancelTravelApplicationId = new List<ID>();
        Set<String> siteSet = null;
        List<String> siteList = null;
        List<Travel_Application__c> TravelApplicationList = new List<Travel_Application__c>();
        
        for(Accommodation__c reader : newAccommpdationMap.values()){
            if(oldAccommpdationMap.get(reader.id).status__c !=  reader.status__c && reader.status__c == 'CN'){
                cancelTravelApplicationId.add(reader.Travel_Application__c);
            }
        }
        if(!cancelTravelApplicationId.isEmpty()){
            
            for(Travel_Application__c reader : [select id,
                                                (select id, site__r.Name from accommodations__r where status__c != :TEConstant.STATUS_DRAFT and status__c != :TEConstant.STATUS_NOT_SUBMITTED  and status__c != :TEConstant.STATUS_CANCELLED),
                                                (select id, Site_To_Visit__c from travel_details__r where status__c != :TEConstant.STATUS_DRAFT and status__c != :TEConstant.STATUS_NOT_SUBMITTED)
                                                from Travel_Application__c]){                
                siteSet = new Set<String>();
                siteList = new List<String>();
                for(travel_detail__c tdReader : reader.travel_details__r){
                    if(!String.isBlank(tdReader.Site_To_Visit__c)){
                        siteSet.addAll(tdReader.Site_To_Visit__c.split(','));
                    }
                }
                for(accommodation__c accReader : reader.accommodations__r){
                    siteSet.add(accReader.site__r.Name);
                }
                for(String sitReader : siteSet){
                    siteList.add(sitReader);
                }
                if(!siteList.isEmpty()){
                    TravelApplicationList.add(new Travel_Application__c (id = reader.id, Tech_All_Site_Name__c = String.join(siteList, '^')+'^'));
                }
            }
        }
        if(!TravelApplicationList.isEmpty()){
            upsert TravelApplicationList;
        }
    }
    
    public static void sendNewAccommodationMail(List<Accommodation__c> newAccommodationList){

        Map<Id, List<String>> TAIdSiteAndAdminEmailMap = new Map<Id, List<String>>();
        Map<Id, Travel_Application__c> travelApplicationlMap = new Map<Id, Travel_Application__c>();
        Map<Id, Set<String>> travelApplicaitonSiteMap = new Map<Id, Set<String>>();
        Map<Id, String> travelApplicaionApplicantMap = new Map<Id, String>();
        Set <Id> travelApplicaitonSet = new Set <Id>();
        Set<String> siteSet = null;
        List <String> stieList = new List <String>();
        List <String> emailAddressList = null;
        Id EmailTemplateId = null;
        String fromDisplayName = null;
        String[] strarray = null;
        
        for (EmailTemplate et : [SELECT Id, DeveloperName, Name FROM EmailTemplate WHERE DeveloperName = 'TravelApplicationLocalAdmin']){
            EmailTemplateId = et.id;
        }
        
        for(Accommodation__c reader : newAccommodationList){
            if(reader.Travel_Application_Status__c == 'PE'){
                travelApplicaitonSet.add(reader.Travel_Application__c);
                if (TAIdSiteAndAdminEmailMap.containsKey(reader.Travel_Application__c)){
                    emailAddressList = TAIdSiteAndAdminEmailMap.get(reader.Travel_Application__c);
                    emailAddressList.add(reader.Site_Email__c);
                }
                else{
                    TAIdSiteAndAdminEmailMap.put(reader.Travel_Application__c, new List<String>{reader.Site_Email__c});
                    if(String.isBlank(reader.OnBehalf_User__c)){
                        travelApplicaionApplicantMap.put(reader.Travel_Application__c, reader.Administrator_User__c);
                    }
                    else{
                        travelApplicaionApplicantMap.put(reader.Travel_Application__c, reader.OnBehalf_User__c);
                    }
                }
                
                if(travelApplicaitonSiteMap.containsKey(reader.Travel_Application__c)){
                    siteSet = travelApplicaitonSiteMap.get(reader.Travel_Application__c);
                    siteSet.add(reader.Site_Name__c);
                }
                else{
                    travelApplicaitonSiteMap.put(reader.Travel_Application__c, new set<String>{reader.Site_Name__c});
                }
            }
        }
        String tmp = '';
        for(Travel_Application__c reader : [select id, Tech_All_Site_Name__c from Travel_Application__c where id in :travelApplicaionApplicantMap.keySet()]){
           siteSet = travelApplicaitonSiteMap.get(reader.id);
           if (!String.isBlank(reader.Tech_All_Site_Name__c)){
               tmp = reader.Tech_All_Site_Name__c;
               strarray = tmp.split('\\^');
               siteSet.addAll(strarray);
           }
           for(String siteReader : siteSet){
               stieList.add(siteReader);
           }
           travelApplicationlMap.put(reader.id, new Travel_Application__c(id = reader.id, Tech_All_Site_Name__c = String.join(stieList, '^')+ '^'));
        }
        for(ID reader : travelApplicaitonSet){
            sendSingleEmailAdmin (reader, fromDisplayName, TAIdSiteAndAdminEmailMap.get(reader), new List<String>(), EmailTemplateId, travelApplicaionApplicantMap);
        }
        if(!travelApplicationlMap.values().isEmpty()){
            upsert travelApplicationlMap.values();
        }
    }
    
    private static void sendSingleEmailAdmin (ID ta, String fromDisplayName, List<String> toEmails, List<String> ccEmails, Id emailTemplateId, Map<Id, String> travelApplicaionApplicantMap){
        List<String> toAddressList = new List<String> ();
        for (String email: toEmails){
            if (email != null){
                toAddressList.add(email);    
            }                                
        }
        if (!toAddressList.isEmpty()){
            TESendEmail.sendEmail(TEConstant.ORGANIZATION_WIDE_EMAIL_NAME , fromDisplayName,toAddressList, ccEmails, emailTemplateId, travelApplicaionApplicantMap.get(ta), ta, false);
        }
    }
    
}