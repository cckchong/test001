@isTest  
public class TestTECashAdvanceTriggerHandler {
    
    Public static TestTETravelApplication TETravelApplication;    
    Public static Map<String, Travel_Location__c> travelLocationMap;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TETravelApplication = new TestTETravelApplication(isSeeAllData);
        travelLocationMap = TETravelApplication.travelLocationMap;
        employee = TETravelApplication.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TETravelApplication.EmployeeAdministratorMap;
    }
    
    
    @isTest   
    public static void paidOutCashAdvance(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        List <TECashAdvanceCtrl> tcaList = null;
        List<Cash_Advance__c> payOutCAList = new List<Cash_Advance__c>();
        travel_application__c tac = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            tcaList = ta.cashAdvanceList;
            tcaList[0].cashAdvance.Currency__c = TETravelApplication.currencyMap.get('USD').id  ;
            tcaList[0].cashAdvance.Amount__c= 100;
            tcaList[0].collectionDate =  '01/01/2015';
            
            Test.startTest();
            ta.submitAction();            
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 tac = reader;
                 tdList = reader.Travel_Details__r;
                 taccList = reader.Accommodations__r;
                 opList = reader.Traveloptions__r;
            }
            for(Travel_Detail__c reader : tdList){
                reader.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            }
            for(Accommodation__c reader : taccList){
                reader.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            }            
            for(Traveloption__c reader : opList){
                reader.Option1__c = TETravelApplication.generateRandomString(10);
                reader.Option2__c = TETravelApplication.generateRandomString(10);
                reader.Option3__c = TETravelApplication.generateRandomString(10);
                reader.Selected_Option1__c = reader.Option1__c;
                reader.Selected_Option2__c = reader.Option2__c;
                reader.Selected_Option3__c = reader.Option3__c;
                reader.status__c = TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION;
            }
            tac.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            tac.Deadline__c = date.newInstance(2015, 1, 1);
            tac.Selected_Option_1__c = true;
            tac.status__c = TEConstant.STATUS_PENDING;
            upsert tac;
            upsert tdList;
            upsert taccList;
            upsert opList; 

            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            ta.submitAction();
            
        }
        for(Cash_Advance__c reader : [select id, status__c from Cash_Advance__c where travel_Application__c = :ta.travelApplication.id]){
            reader.status__c = TEConstant.STATUS_PAID_OUT;
            payOutCAList.add(reader);
        }
        upsert payOutCAList;
        Test.stopTest();
        
    }
    
}