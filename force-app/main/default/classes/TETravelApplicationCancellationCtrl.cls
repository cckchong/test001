/**
 * TETravelApplicationCancellationCtrl
 * @description Cancel Travel Application(s)
 * @author Ted Pang
 */
public without sharing class TETravelApplicationCancellationCtrl {
    private ApexPages.StandardSetController standardController;
    private Id id;
    private Travel_Application__c r {get; set;}
    private Map<Id, String> recordtype;
    
    public TalMobileNavigationRouting mobileRoute {get;set;} { mobileRoute = new TalMobileNavigationRouting();}
    
    /**
     * @description constructor with StandardController
     */
    public TETravelApplicationCancellationCtrl(ApexPages.StandardController controller) {
        
        recordtype = new Map<Id, String> ();

        String textId = ApexPages.currentPage().getParameters().get('id');
        
        if (textId != null) {
            id = textId;
        }
        
        for ( RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SObjectType  = :TEConstant.TRAVEL_APPLICATION_OBJECT_NAME  
                AND IsActive = true
            ] ) {
            recordtype.put ( rt.id , rt.DeveloperName );
        }
    }
  
    /**
     * Get Requests where cancellation is not allowed
     * @param  ids List of ID to be blocked
     * @return     List of Travel Application(s)
     */
    private Map<String, String> getBlockedRequests(List<Id> ids) {
        Map<String, String> blockedNameMessageMap = new Map<String, String>();
        for(Travel_Application__c ta : [SELECT Name FROM Travel_Application__c where Id = :ids and Allow_Cancel__c = false]){
            blockedNameMessageMap.put(ta.Name, Label.TE_Travel_Application_Unable_To_Recall_By_Other); //error message for unable to cancel
        }
        for (Leave_Request__c lr : [SELECT Id, Travel_Application__r.Name From Leave_Request__c 
                                        Where Travel_Application__c = :ids 
                                              And (Status__c = :LeaveRequestConstant.STATUS_PENDING_APPROVAL OR Status__c = :LeaveRequestConstant.STATUS_APPROVED)]){
            if (!blockedNameMessageMap.containsKey(lr.Travel_Application__r.Name)){
                blockedNameMessageMap.put(lr.Travel_Application__r.Name, Label.TE_Cannot_Cancel_Travel_With_Leave_Application);
            }                                
        }
        
        return blockedNameMessageMap;
    }
    
    /**
     * Get Requests where recall is not allowed
     * @param  ids List of ID to be blocked
     * @return     List of Travel Application(s)
     */
    private Map<String, String> getBlockedRecallRequests(List<Id> ids) {
        Map<String, String> blockedNameMessageMap = new Map<String, String>();
        for(Travel_Application__c ta : [SELECT Name FROM Travel_Application__c where Id = :ids and Allow_Recall__c = false]){
            blockedNameMessageMap.put(ta.Name, Label.TE_Travel_Application_Cannot_Recall); //error message for unable to cancel
        }
        return blockedNameMessageMap;
    }
    
    
    /**
     * Get the Travel Application  in scope
     * @param  ids List of ID to get requests
     * @return     List of Travel Application(s)
     */
    private List<Travel_Application__c> getRequests(List<Id> ids) {
        return [SELECT  Id
                    , Status__c
                    , allow_cancel__c
                    , recordTypeId
                FROM Travel_Application__c where Id = :ids and (Allow_Cancel__c = true OR Allow_Recall__c = True)];
    }
    
    Public PageReference clear(){
        return new PageReference('/' + this.id);
    }
    
    /**
     * @description cancel the Travel Application 
     * @return PageReference the navigation endpoint
     */
    public PageReference cancel() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Travel_Application__c> requestsToBeCancel = new List<Travel_Application__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();
        
        List<Id> taCancelIdList = new List<Id>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :Travel_Detail__c.sObjectType.getDescribe().getName()   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single Travel application
            selectedRequestIds.add(id);
            requestsToBeCancel = getRequests(selectedRequestIds);
        } 
        else {
            // No requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Travel_Application_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        //start processing...
        for (Travel_Application__c travelapplication : requestsToBeCancel){
            if (travelapplication.status__c == TEConstant.STATUS_CONFIRMED) { 
                taCancelIdList.add(travelapplication.Id);
            } 
        }
        
        String message = prepareMessage(selectedRequestIds);
                
        if (message != '') {
            // Some requests cannot be cancelled. (Allow_Cancel__c = false)
            if(isSalesforceOne) {

                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = message;
                return null;
                
            } else {
                return new PageReference('javascript: alert(\'' + message + '\');window.history.back();' );
            }
        } else {
            // All requests can be cancelled.
            for (Travel_Application__c travelapplication : requestsToBeCancel){
                if (travelapplication.status__c == TEConstant.STATUS_CONFIRMED) {
                    travelapplication.status__c = TEConstant.STATUS_CANCELLED; 
                    travelapplication.Leave_Date__c = null;
                    travelapplication.num_of_leave_days__c = 0;
                } 
            }
            update requestsToBeCancel;
            
            updateStatus(TEConstant.STATUS_CANCELLED, taCancelIdList);
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                return null;                 
                
            } else {
                if (id != null) {
                    return new PageReference('/' + id);
                } else {
                    return new PageReference('javascript: window.history.back();');
                }
            }
        }
    }
    
    /**
     * @description recall the Travel Application 
     * @return PageReference the navigation endpoint
     */
    public PageReference recall() {
        boolean isSalesforceOne = SystemUtil.isMobileDevice();
        String labelcontext = '';
        List<Travel_Application__c> requestsToBeRecall = new List<Travel_Application__c>();
        List<Id> selectedRequestIds = new List<Id>();
        Map<Id, String> recordtype = new Map<Id, String>();

        List<Id> taRecallIdList = new List<Id>();
        
        for (RecordType rt : 
            [
                SELECT Id, DeveloperName 
                FROM RecordType
                WHERE SobjectType  = :Travel_Detail__c.sObjectType.getDescribe().getName()   AND IsActive = true
            ]) {
             
             recordtype.put ( rt.id , rt.DeveloperName );
             
         }

        if (id != null) {
            // Cancel a single Travel application
            selectedRequestIds.add(id);
            requestsToBeRecall = getRequests(selectedRequestIds);
        } 
        else {
            // No requests for cancel
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = Label.TE_Travel_Application_Cancel_Fail;
                return null;
            } else { 
                return new PageReference('javascript: window.history.back();');
            }
        }
        
        
        //start processing...
        for (Travel_Application__c travelapplication : requestsToBeRecall){
            if (travelapplication.status__c == TEConstant.STATUS_PENDING) { 
                taRecallIdList.add(travelapplication.Id);
            } 
        }
        
        String message = prepareRecallMessage(selectedRequestIds);
                
        if (message != '') {
            // Some requests cannot be cancelled. (Allow_Cancel__c = false)
            if(isSalesforceOne) {

                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                this.mobileRoute.infoMessage = message;
                return null;
                
            } else {
                return new PageReference('javascript: alert(\'' + message + '\');window.history.back();' );
            }
        } else {
            // All requests can be cancelled.
            for (Travel_Application__c travelapplication : requestsToBeRecall){
                if (travelapplication.status__c == TEConstant.STATUS_PENDING) {
                    travelapplication.status__c = TEConstant.STATUS_NOT_SUBMITTED; 
                } 
            }
            update requestsToBeRecall;
            
            updateStatus(TEConstant.STATUS_NOT_SUBMITTED, taRecallIdList);
            if(isSalesforceOne) {
                this.mobileRoute.navResult = TalMobileNavigationRouting.NAV_RESULT.BACK;
                return null;                 
                
            } else {
                if (id != null) {
                    return new PageReference('/' + id);
                } else {
                    return new PageReference('javascript: window.history.back();');
                }
            }
        }
    }
        
    private String prepareMessage(List<Id> ids) {
        String message = '';
        String temp = '';
        Map<String, String> blockedRequestMessageMap = getBlockedRequests(ids);
        
        for (String requestName : blockedRequestMessageMap.keySet()) {
            if (blockedRequestMessageMap.get(requestName) == Label.TE_Travel_Application_Unable_To_Recall_By_Other){
                if (temp != '') {
                    temp += ', ';
                }
                temp += requestName;
            }
        }
        
        if (temp != '') {
            message = Label.TE_Travel_Application_Cannot_Cancel + ' ' + temp + ' ' + Label.TE_Travel_Application_Unable_To_Recall_By_Other;
        }
        
        temp = '';
        for (String requestName : blockedRequestMessageMap.keySet()) {
            if (blockedRequestMessageMap.get(requestName) == Label.TE_Cannot_Cancel_Travel_With_Leave_Application){
                if (temp != '') {
                    temp += ', ';
                }
                temp += requestName;
            }
        }
        
        if (temp != '') {
            if (message == ''){
                message = Label.TE_Travel_Application_Cannot_Cancel;
            }
            message = message + ' ' + temp + ' ' + Label.TE_Cannot_Cancel_Travel_With_Leave_Application;
        }
        
        return message;
    }
    
    private String prepareRecallMessage(List<Id> ids) {
        String message = '';
        String temp = '';
        Map<String, String> blockedRequestMessageMap = getBlockedRecallRequests(ids);
        
        for (String requestName : blockedRequestMessageMap.keySet()) {
            if (blockedRequestMessageMap.get(requestName) == Label.TE_Travel_Application_Cannot_Recall){
                if (temp != '') {
                    temp += ', ';
                }
                temp += requestName;
            }
        }
        
        if (temp != '') {
            message = Label.TE_Travel_Application_Cannot_Be_Recalled + ' ' + temp + ' ' + Label.TE_Travel_Application_Cannot_Recall;
        }
        
        return message;
    }
    
    private void updateStatus(String status, List<Id> taIdList) {
        List<Travel_Detail__c> travelDetailList = new List<Travel_Detail__c>();
        List<Accommodation__c> accommodationList = new List<Accommodation__c>();
        List<TravelOption__c> travelOptionList = new List<TravelOption__c>();
        List<Journey__c> journeyList = new List<Journey__c>();
        List<Cash_Advance__c > cashAdvanceList = new List<Cash_Advance__c >();
        //travel detail
        for (Travel_Detail__c td : [SELECT Id, Status__c FROM Travel_Detail__c WHERE Travel_Application__r.Id IN :taIdList]){
                travelDetailList.add(td);
        }
        for (Travel_Detail__c td : travelDetailList){
            td.Departure_Assigned_Shuttle__c = null;
            td.Return_Assigned_Shuttle__c = null;
            td.Confirmed_Departure_Pick_Up_Point__c = null;
            td.Confirmed_Departure_Route__c = null;
            td.Confirmed_Return_Pick_Up_Point__c = null;
            td.Confirmed_Return_Route__c = null;
            td.Status__c = status;
        }
        update travelDetailList;
        //accommodation
        for (Accommodation__c acc : [SELECT Id, Status__c FROM Accommodation__c WHERE Travel_Application__r.Id IN :taIdList]){
                accommodationList.add(acc);
        }
        for (Accommodation__c acc : accommodationList){
            acc.Status__c = status;
        }
        update accommodationList;
        //travel option
        for (TravelOption__c to : [SELECT Id, Status__c FROM TravelOption__c WHERE Travel_Application__r.Id IN :taIdList]){
                travelOptionList.add(to);
        }
        for (TravelOption__c to : travelOptionList){
            to.Status__c = status;
        }
        update travelOptionList;
        //journey
        for (Journey__c j : [SELECT Id, Status__c FROM Journey__c WHERE Travel_Application__r.Id IN :taIdList]){
                journeyList.add(j);
        }
        for (Journey__c j : journeyList){
            j.Status__c = status;
        }
        update journeyList;

    }
}