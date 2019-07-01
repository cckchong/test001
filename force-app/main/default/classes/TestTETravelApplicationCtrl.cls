@isTest  
public class TestTETravelApplicationCtrl{
    
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
    public static void addRemoveitem(){    
        Map<String, User> UserMap = null;
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List <TETravelDetail> tdList = null;
        List <TEAccommodationCtrl> taccList = null;
        List <TECashAdvanceCtrl> tcaList = null;
        //List <TETravelOption> airOptList = null;
        //List <TETravelOption> hotelOptList = null;
        TETravelDetail td = null;
        String tdAirRecordTypeId = null;
        String tdSurfaceRecordTypeId = null;
        String tdShuttleRecordTypeId = null;
        Integer size = 0 ;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();
        System.runAs(UserMap.get(userName)) {
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tcaList = ta.cashAdvanceList;
            // Add a travel Detail Row
            tdList[0].addRow();
            // Remove a travel Detail Row
            tdList[0].removeRow();
            tdList[0].getisEdit();
            
            
            // Add an Accommodation Row
            taccList[0].addRow();
            // Remove an Accommodation Row
            taccList[0].removeRow();
            taccList[0].getisEdit();
            
            // Remove a Cash Adv. Row
            tcaList[0].removeRow();
            // Add a Cash Adv. Row
            tcaList[0].addRow();
            tcaList[0].getisEdit();
            tcaList[0].getisNewCashAdvance();
            tcaList[0].getisDelete();
            ta.getisApplicantMode();
            ta.getDT_FORMAT();
            ta.getDate_FORMAT();
            ta.getisSave();
            ta.getisApplicantMode();
            ta.getshortCurrencySelectionList();
            ta.changeApplicant();
            ta.getApplyDate();
            System.assertEquals(tdList.size(), ta.NUM_OF_ROW_DEF);
            System.assertNotEquals(taccList.size(), 0);
            System.assertNotEquals(tcaList.size(), 0);
        }
        Test.stopTest();
    }
    
    @isTest   
    public static void cancelTA(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        travel_application__c tac = null;
        PageReference prf = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            prf = ta.cancelAction();
            System.assertNotEquals(prf, null); 
            ta.submitAction();
            prf  = ta.cancelAction();
            System.assertNotEquals(prf, null);        
            Test.stopTest(); 
         }    
    }
    
    @isTest   
    public static void saveNewTA(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();        
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            ta.saveAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
        }
        Test.stopTest();
    }
    
    @isTest   
    public static void submitNewTA(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List <TETravelOption> airOptList = null;
        List <TETravelOption> hotelOptList = null;
        Integer size = 0;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();        
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);

            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl();             
            airOptList = ta.airTravelOptionList;
            hotelOptList = ta.hotelTravelOptionList;
            
            size = airOptList.size();
            // Remove a Air opt Row
            airOptList[0].removeRow();
            //Add a Air opt Row
            airOptList[0].addRow();
            System.assertEquals(airOptList.size(), size);

            size = hotelOptList.size();            
            // Add a hotel opt Row
            hotelOptList[0].addRow();
            // Remove a hotel opt Row
            hotelOptList[0].removeRow();
            System.assertEquals(hotelOptList.size(), size);
        }
        Test.stopTest();
    }
    
    @isTest   
    public static void openExistingTA(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List <TECashAdvanceCtrl> tcaList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();        
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            tcaList = ta.cashAdvanceList;
            tcaList[0].cashAdvance.Currency__c = TETravelApplication.currencyMap.get('HKD').id  ;
            tcaList[0].cashAdvance.Amount__c= 100;
            tcaList[0].collectionDate =  '01/01/2015';
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );
            ta = new TETravelApplicationCtrl();            
        }
        Test.stopTest();
        
    }
    
    @isTest   
    public static void travelAgentSubmitTAwithOption(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
            }
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
            }
            ta.TravelApplication.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency2__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency3__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.submitAction();
            
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
                 /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
                 // for(Travel_Detail__c tdreader : reader.Travel_Details__r){
                 //     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_SELECTION);
                 // }
                 for(Accommodation__c tdreader : reader.Accommodations__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_SELECTION);
                 }
                 for(Traveloption__c tdreader : reader.Traveloptions__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_SELECTION);
                 }
            }
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void ApplicantSelectOption(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
            }
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
            }
            ta.TravelApplication.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency2__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency3__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.submitAction();
            
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            ta.TravelApplication.Selected_Option_1__c = true;
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
                reader.TravelOption.Selected_Option2__c = reader.TravelOption.Option2__c;
                reader.TravelOption.Selected_Option3__c = reader.TravelOption.Option3__c;
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
            }
            ta.submitAction();
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
               /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
                 // for(Travel_Detail__c tdreader : reader.Travel_Details__r){
                 //     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 // }
                 for(Accommodation__c tdreader : reader.Accommodations__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 }
                 for(Traveloption__c tdreader : reader.Traveloptions__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 }
            }
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void TravelAgentSubmitConfirmDate(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction(); 
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);               
            }
            for(TEAccommodationCtrl reader : taccList){
                 if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
            }
            ta.TravelApplication.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency2__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency3__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Selected_Option_1__c = true;
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
                reader.TravelOption.Selected_Option2__c = reader.TravelOption.Option2__c;
                reader.TravelOption.Selected_Option3__c = reader.TravelOption.Option3__c;
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
            }
            List<Travel_Detail__c> tdcList = new List<Travel_Detail__c>();
            List<Accommodation__c> accommodationcList = new List<Accommodation__c>();
            List<Traveloption__c> tocList = new List<Traveloption__c>();
            
            for(TETravelDetail reader : tdList){
                reader.travelDetail.status__c = TEConstant.STATUS_PENDING_RESERVATION;
                tdcList.add(reader.travelDetail);                
            }
            for(TEAccommodationCtrl reader : taccList){
                reader.accommodation.status__c = TEConstant.STATUS_PENDING_RESERVATION;
                if(reader.accommodation.id != null){
                    accommodationcList.add(reader.accommodation);
                }
            }
            for(TETravelOption reader : tAiropList){
               reader.TravelOption.status__c = TEConstant.STATUS_PENDING_RESERVATION;
               tocList.add(reader.TravelOption);
            }
            for(TETravelOption reader : tHotelopList){
               reader.TravelOption.status__c = TEConstant.STATUS_PENDING_RESERVATION;
               tocList.add(reader.TravelOption);
            }
            upsert tdcList;
            upsert accommodationcList;
            upsert tocList;
            
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            ta.deadline = '01/01/2015';
            ta.submitAction();
            
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
               /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
                 // for(Travel_Detail__c tdreader : reader.Travel_Details__r){
                 //     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION);
                 // }
                 for(Accommodation__c tdreader : reader.Accommodations__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION);
                 }
                 for(Traveloption__c tdreader : reader.Traveloptions__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION);
                 }
            }
            
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void ApplicantConfirmTA(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        travel_application__c tac = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
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
            
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c where id =:ta.TravelApplication.id]
            ){
                  /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
                 // System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED);
                 for(Travel_Detail__c tdreader : reader.Travel_Details__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_CONFIRMED);
                 }
                 for(Accommodation__c tdreader : reader.Accommodations__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_CONFIRMED);
                 }
                 for(Traveloption__c tdreader : reader.Traveloptions__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_CONFIRMED);
                 }
            }
            Test.stopTest();
        }
    }
    
    @isTest  
    public static void insertPriceAndItinerary(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        List<TETravelPriceCtrl> priceList = null;
        List<TETravelItineraryCtrl> ItineraryList = null;
        travel_application__c tac = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
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
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }
            for(Accommodation__c reader : taccList){
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }            
            for(Traveloption__c reader : opList){
                reader.Option1__c = TETravelApplication.generateRandomString(10);
                reader.Option2__c = TETravelApplication.generateRandomString(10);
                reader.Option3__c = TETravelApplication.generateRandomString(10);
                reader.Selected_Option1__c = reader.Option1__c;
                reader.Selected_Option2__c = reader.Option2__c;
                reader.Selected_Option3__c = reader.Option3__c;
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }
            tac.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            tac.Deadline__c = date.newInstance(2015, 1, 1);
            tac.Selected_Option_1__c = true;
            tac.status__c = TEConstant.STATUS_CONFIRMED;
            upsert tac;
            upsert tdList;
            upsert taccList;
            upsert opList; 

            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id);            
            ta = new TETravelApplicationCtrl();
            priceList = ta.travelPriceList;
            priceList[0].addRow();
            priceList[0].RemoveRow();
            for(TETravelPriceCtrl reader : priceList){
                reader.travelPrice.Type__c = 'Visa';
                reader.travelPrice.Amount__c = 100;
                reader.travelPrice.Currency__c = TETravelApplication.currencyMap.get('HKD').id;
                reader.invoiceDate = '01/01/2017';
                reader.travelPrice.Invoice_No__c = TETravelApplication.generateRandomString(5);
            }
            
            ItineraryList = ta.travelItineraryList;
            ItineraryList[0].addRow();
            ItineraryList[0].RemoveRow();
            for(TETravelItineraryCtrl reader : ItineraryList){
                reader.journey.Flight__c = TETravelApplication.generateRandomString(5);
                reader.journey.From_Airport_Text__c = TETravelApplication.AirportMap.get('HONGKONG').Name;
                reader.journey.To_Airport_Text__c = TETravelApplication.AirportMap.get('LOSANGELES').Name;
                reader.journey.Cabin_Class__c = TETravelApplication.CabinClassMap.get('ECONOMYCLASS').id;
            }
            //ta.saveAction();
            ta.submitAction();
            for(journey__c reader : [select id, From_Airport_Text__c , To_Airport_Text__c  from journey__c where travel_application__c = :ta.TravelApplication.Id]){
                System.assertNotEquals(reader.id, null);
                System.assertEquals(reader.From_Airport_Text__c, TETravelApplication.AirportMap.get('HONGKONG').Name);
                System.assertEquals(reader.To_Airport_Text__c, TETravelApplication.AirportMap.get('LOSANGELES').Name);
            }
            for(travel_Price__c reader : [select id, amount__c from travel_Price__c where travel_application__c = :ta.TravelApplication.Id]){
                System.assertNotEquals(reader.id, null);
                System.assertEquals(reader.amount__c, 100);
            }
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id);            
            ta = new TETravelApplicationCtrl(); 
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void saveTAWithShuttle(){
        Integer counter = 1;
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List <TETravelDetail> tdList = null;
        List <SelectOption> shuttleArrangementFromSelectionList = null;
        List <SelectOption> shuttleArrangementToSelectionList = null;
        List<TEAccommodationCtrl> taccList = null;
        Accommodation__c newAccommodation = new Accommodation__c();
        TETravelDetail td = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        for(Travel_Location__c reader : travelLocationMap.values() ){
            if (counter == 1){
                reader.site__c = TETravelApplication.NewSiteMap.get('TGA').id;
            }
            if (counter == 2){
                reader.site__c = TETravelApplication.NewSiteMap.get('HKO').id;
            }
        }
        upsert travelLocationMap.values();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        TEShuttleArrangementAutoGenerationCtrl.autoGeneration(); 
        Test.startTest();
        
        Route__c r = new Route__c();
        r.From__c = TETravelApplication.NewSiteMap.get('TGA').id;
        r.To__c = TETravelApplication.NewSiteMap.get('HKO').id;
        insert r;
        System.assertNotEquals(r.Id, null);
        Car_Journey__c cj = new Car_Journey__c();
        cj.Date__c = System.Today().addDays(5);
        cj.Route__c = r.Id;
        insert cj;
        System.assertNotEquals(cj.Id, null);
        Shuttle_Stop__c st = new Shuttle_Stop__c();
        st.Route__c = r.Id;
        insert st;
       // ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
       //  ta = new TETravelApplicationCtrl(); 
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Shuttle'));
            tdList = ta.travelDetailList;
            td = tdList[0];
            td.DepartureDateTime = '01/'+String.valueof(System.Today().addMonths(1).month())+'/'+String.valueof(System.Today().year());
            td.ReturnDateTime = td.DepartureDateTime;
            td.TravelDetail.Shuttle_From__c = TETravelApplication.NewSiteMap.get('HKO').id;
            td.TravelDetail.Shuttle_To__c = TETravelApplication.NewSiteMap.get('TGA').id;
            td.TravelDetail.Admin_Pick_Up__c = true;
            td.TravelDetail.Site_To_Visit__c = 'TGA';
            td.TravelDetail.Departure_Pick_Up_Point__c = st.Id;
            td.TravelDetail.Return_Pick_Up_Point__c = st.Id;
            ta.accommodationAddRow();
            shuttleArrangementFromSelectionList = td.getshuttleArrangementFromSelectionList();
            shuttleArrangementtoSelectionList = td.getshuttleArrangementToSelectionList();
            System.assertNotEquals(shuttleArrangementFromSelectionList.size(), 0);
            System.assertNotEquals(shuttleArrangementtoSelectionList.size() , 0);
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            taccList = ta.travelAccommodationList;
            System.assertEquals(ta.travelApplication.status__c, 'PE');
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    newAccommodation.accommodation_By__c = reader.accommodation.accommodation_By__c;
                    newAccommodation.location__c = reader.accommodation.location__c;
                    newAccommodation.check_in_Date__c = reader.accommodation.check_in_Date__c;
                    newAccommodation.check_Out_Date__c = reader.accommodation.check_Out_Date__c;
                    newAccommodation.travel_Application__c = reader.accommodation.travel_Application__c;
                    reader.cancelRow();
                }
            }
            upsert newAccommodation;
            System.assertNotEquals(newAccommodation.id, null);
        }
        Test.stopTest();
        
    }
    
    @isTest   
    public static void errorCheckBeforeSubmit(){
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        TETravelDetail td = null;
        TEAccommodationCtrl acc = null;
        TECashAdvanceCtrl ca = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        Test.startTest();        
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            td = ta.travelDetailList[0];
            //Input one air travel detail row 
            //td.TravelDetail.recordTypeId = tdRecordTypeId;
            td.DepartureDateTime = '';
            td.ReturnDateTime = '';
            td.TravelDetail.Origin_Site__c = null;
            td.TravelDetail.Destination__c = null;
            
            ca = ta.cashAdvanceList[0];
            ca.cashAdvance.Currency__c = null;
            ca.cashAdvance.Amount__c = 100;
            ca.collectionDate = '';
            
            acc = ta.travelAccommodationList[0];
            acc.checkInDate = '';
            acc.checkOutDate = '';
            acc.accommodation.Accommodation_By__c = 'Air';
            acc.accommodation.location__c = null;
            
            ta.saveAction();
            ca = ta.cashAdvanceList[0];
            ca.cashAdvance.Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ca.cashAdvance.Amount__c = null;
            ca.collectionDate = '';
            
            acc.checkInDate = '01/01/2015';
            acc.checkOutDate = '';
            acc.accommodation.Accommodation_By__c = '';
            acc.accommodation.location__c = null;
            
            ta.saveAction();
            
            System.assertEquals(ta.TravelApplication.id, null);
        }
        Test.stopTest();
    }
    
    @isTest   
    public static void errorChecktravelAgentSubmitTAwithOption(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
            }
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                //reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                //reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
                break;
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Destination__c = null;
                reader.TravelOption.From__c = null;
                reader.travelOption.Check_in_Date__c = null;
                reader.travelOption.Check_Out_Date__c = null;
                break;
                
            }
            ta.TravelApplication.Option_Estimated_Price1__c = null;
            ta.TravelApplication.Option_Estimated_Price2__c = null;
            ta.TravelApplication.Option_Estimated_Price3__c = null;
            ta.saveAction();
            
            
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = '';
                reader.TravelOption.Destination__c = travelLocationMap.get('HONGKONG').id;
                reader.TravelOption.From__c = travelLocationMap.get('HONGKONG').id;
                reader.travelOption.Check_in_Date__c = null;
                reader.travelOption.Check_Out_Date__c = null;
                break;
            }
            
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
            }
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void errorCheckApplicantSelectOption(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
            }
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
            }
            ta.TravelApplication.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency2__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency3__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.submitAction();
            
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            ta.submitAction();
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
                 
            }
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void AgentAddPrice(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        List<TETravelPriceCtrl> travelPriceList = new List<TETravelPriceCtrl>();
        travel_application__c tac = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        employee.site__c = TETravelApplication.NewSiteMap.get('HKO').id;
        //employee.Employee_Department__c = 'IT';
        upsert employee; 
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            Test.startTest();
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));

            ta.submitAction();
            ta.travelApplication.status__c = TEConstant.STATUS_CONFIRMED;
            upsert ta.travelApplication;
            Travel_Price__c tp = new Travel_Price__c();
            tp.Type__c = 'Visa';
            tp.Amount__c = 100;
            tp.Currency__c = TETravelApplication.currencyMap.get('USD').id;
            tp.Invoice_Date__c = Date.newInstance(2017,2,2);
            tp.Invoice_No__c = TETravelApplication.generateRandomString(5);
            tp.travel_application__c = ta.travelApplication.id;
            insert tp;
            
            apexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            travelPriceList = ta.travelPriceList;
            travelPriceList[0].duplicateRow();
            travelPriceList[0].removeRow();
            Test.stopTest();
        }
    }
    
    @isTest   
    public static void reArrangeTravelApplication(){ 
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        List<TEAccommodationCtrl> taccList = null;
        List<TETravelOption> tAiropList = null;
        List<TETravelOption> tHotelopList = null;
        PageReference prf = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
           
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.id, null);            
            UserMap = null;
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            tdList = ta.travelDetailList;
            taccList = ta.travelAccommodationList;
            tAiropList = ta.airTravelOptionList;
            tHotelopList = ta.hotelTravelOptionList;
            
            System.assertEquals(ta.TravelApplication.status__c, TEConstant.STATUS_PENDING);
            for(TETravelDetail reader : tdList){
                System.assertEquals(reader.travelDetail.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
            }
            for(TEAccommodationCtrl reader : taccList){
                if(reader.accommodation.id != null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_PENDING_ARRANGEMENT);
                }
                if(reader.accommodation.id == null){
                    System.assertEquals(reader.accommodation.status__c, TEConstant.STATUS_DRAFT);
                }
            }
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option2__c = TETravelApplication.generateRandomString(10);
                reader.TravelOption.Option3__c = TETravelApplication.generateRandomString(10);
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Option1__c = TETravelApplication.generateRandomString(10);
            }
            ta.TravelApplication.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            ta.TravelApplication.Option_Estimated_Currency__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency2__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.TravelApplication.Option_Estimated_Currency3__c = TETravelApplication.currencyMap.get('HKD').id;
            ta.submitAction();
            
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            ta.TravelApplication.Selected_Option_1__c = true;
            for(TETravelOption reader : tAiropList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
                reader.TravelOption.Selected_Option2__c = reader.TravelOption.Option2__c;
                reader.TravelOption.Selected_Option3__c = reader.TravelOption.Option3__c;
            }
            for(TETravelOption reader : tHotelopList){
                reader.TravelOption.Selected_Option1__c = reader.TravelOption.Option1__c;
            }
            ta.submitAction();
            for (travel_application__c reader :[select id , status__c,
                                                (select id, status__c from Travel_Details__r ),
                                                (select id, status__c from Accommodations__r ),
                                                (select id, status__c from Traveloptions__r )
                                                from travel_application__c
                                                where id = :ta.TravelApplication.id
             ]){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_PENDING);
                /*Comment by DTT Support Team  Reason:Can add invoice regardless the status*/
                 // for(Travel_Detail__c tdreader : reader.Travel_Details__r){
                 //     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 // }
                 for(Accommodation__c tdreader : reader.Accommodations__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 }
                 for(Traveloption__c tdreader : reader.Traveloptions__r){
                     System.assertEquals(tdreader.status__c, TEConstant.STATUS_PENDING_RESERVATION);
                 }
            }
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl(); 
            prf = ta.RearrangeAction();
            System.assertNotEquals(prf, null);
            Test.stopTest();
        }
    }

    //Add by DTT
    @isTest  
    public static void insertPriceOnly(){  
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<Travel_Detail__c> tdList = null;
        List<Accommodation__c> taccList = null;
        List<TravelOption__c> opList = null;
        List<TETravelPriceCtrl> priceList = null;
        List<TETravelItineraryCtrl> ItineraryList = null;
        travel_application__c tac = null;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        System.runAs(UserMap.get(userName)){            
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Air'));
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
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }
            for(Accommodation__c reader : taccList){
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }            
            for(Traveloption__c reader : opList){
                reader.Option1__c = TETravelApplication.generateRandomString(10);
                reader.Option2__c = TETravelApplication.generateRandomString(10);
                reader.Option3__c = TETravelApplication.generateRandomString(10);
                reader.Selected_Option1__c = reader.Option1__c;
                reader.Selected_Option2__c = reader.Option2__c;
                reader.Selected_Option3__c = reader.Option3__c;
                reader.status__c = TEConstant.STATUS_CONFIRMED;
            }
            tac.Option_Estimated_Price1__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price2__c = Math.round(Math.random()*1000);
            tac.Option_Estimated_Price3__c = Math.round(Math.random()*1000);
            tac.Deadline__c = date.newInstance(2015, 1, 1);
            tac.Selected_Option_1__c = true;
            tac.status__c = TEConstant.STATUS_CONFIRMED;
            upsert tac;
            upsert tdList;
            upsert taccList;
            upsert opList; 

            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id);            
            ta = new TETravelApplicationCtrl();
            priceList = ta.travelPriceList;
            priceList[0].addRow();
            priceList[0].RemoveRow();
            for(TETravelPriceCtrl reader : priceList){
                reader.travelPrice.Type__c = 'Visa';
                reader.travelPrice.Amount__c = 100;
                reader.travelPrice.Currency__c = TETravelApplication.currencyMap.get('HKD').id;
                reader.invoiceDate = '01/01/2017';
                reader.travelPrice.Invoice_No__c = TETravelApplication.generateRandomString(5);
            }
            
            ItineraryList = ta.travelItineraryList;
            ItineraryList[0].addRow();
            ItineraryList[0].RemoveRow();
            for(TETravelItineraryCtrl reader : ItineraryList){
                reader.journey.Flight__c = TETravelApplication.generateRandomString(5);
                reader.journey.From_Airport_Text__c = TETravelApplication.AirportMap.get('HONGKONG').Name;
                reader.journey.To_Airport_Text__c = TETravelApplication.AirportMap.get('LOSANGELES').Name;
                reader.journey.Cabin_Class__c = TETravelApplication.CabinClassMap.get('ECONOMYCLASS').id;
            }
            //ta.saveAction();
            //ta.submitAction();
            ta.savePriceAction();
            // for(journey__c reader : [select id, From_Airport_Text__c , To_Airport_Text__c  from journey__c where travel_application__c = :ta.TravelApplication.Id]){
            //     System.assertNotEquals(reader.id, null);
            //     System.assertEquals(reader.From_Airport_Text__c, TETravelApplication.AirportMap.get('HONGKONG').Name);
            //     System.assertEquals(reader.To_Airport_Text__c, TETravelApplication.AirportMap.get('LOSANGELES').Name);
            // }
            // for(travel_Price__c reader : [select id, amount__c from travel_Price__c where travel_application__c = :ta.TravelApplication.Id]){
            //     System.assertNotEquals(reader.id, null);
            //     System.assertEquals(reader.amount__c, 100);
            // }
            // ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id);            
            // ta = new TETravelApplicationCtrl(); 
            Test.stopTest();
        }
    }
    
}