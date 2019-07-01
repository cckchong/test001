@isTest
private class TestTETRAttachmentTriggerHandler {

     
     public Static String temp;
     Public static TestTEExpenseApplication TEExpenseApplication;    
     Public static Map<String, Travel_Location__c> travelLocationMap;
     Public static employee__c employee;
     Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
     Public static String userName = 'user1';
    
     Public static void preparation(Boolean isSeeAllData){
        TEExpenseApplication = new TestTEExpenseApplication(isSeeAllData);
        travelLocationMap = TEExpenseApplication.travelLocationMap;
        employee = TEExpenseApplication.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEExpenseApplication.EmployeeAdministratorMap;
     }
     
     public static void attachmentFileContent(){
        temp = ' CHINA INTELLIGENCE TRAVEL MANAGEMENT SERVICES LTD          DATE : 23 SEP 2014\r\n';
        temp += ' SUITE A 22/F WORLD TRUST TOWER                             ITINERARY\r\n';
        temp += ' 50 STANLEY STREET                                          PAGE : 01\r\n';
        temp += ' CENTRAL HONG KONG                                          CONSULTANT NAME:\r\n';
        temp += ' TEL 21113737 FAX 21111331                                  ANGELA LAU\r\n';
        temp += '                                                            ABACUS REF: GVAKKT\r\n';
        temp += '  \r\n';
        temp += '  \r\n';
        temp += ' ITINERARY PREPARED FOR:\r\n';
        temp += '  1 HO/JESSICA MS\r\n';
        temp += '  \r\n';
        temp += '  \r\n';
        temp += '  \r\n';
        temp += '  \r\n';
        temp += '                THANK YOU FOR BOOKING WITH US';
        temp += '                HAVE A PLEASANT TRIP\r\n';
        temp += '                                               FLIGHT            STOP/EQP/\r\n';
        temp += '                CITY/TERMINAL/                 CLASS             FLYING TIME/\r\n';
        temp += ' DAY DATE       STOPOVER CITY          TIME    STATUS            SERVICES\r\n';
        temp += ' --- ----       --------------         ----    ------            ------------\r\n';
        temp += '  \r\n';
        temp += ' SAT 27SEP DEP  HONG KONG              0930    CX 898            NON-STOP\r\n';
        temp += '                TERMINAL 1                     ECONOMY CLASS     B77ER\r\n';
        temp += '           ARR  LOS ANGELES            0755    CONFIRMED         13HR 25MIN\r\n';
        temp += '                TOM BRADLEY INTL TERM\r\n';
        temp += '                HO/JESSICA MS      SEAT  40C**RESERVED**\r\n';
        temp += '                FREQUENT FLYER - CX-1546629075\r\n';
        temp += '  \r\n';
        temp += ' SAT 27SEP DEP  LOS ANGELES            1020    CX 7520           NON-STOP\r\n';
        temp += '                TERMINAL 4                     ECONOMY CLASS     BOEING 767 300\r\n';
        temp += '           ARR  DALLAS FT WORTH        1520    CONFIRMED         03HR 00MIN\r\n';
        temp += '                TERMINAL D\r\n';
        temp += '                LOS ANGELES-DALLAS FT WORTH OPERATED BY AMERICAN AIRLINES\r\n';
        temp += '                HO/JESSICA MS      SEAT  34H**RESERVED**\r\n';
        temp += '                FREQUENT FLYER - CX-1546629075\r\n';
        temp += '  \r\n';
        temp += ' SAT 04OCT DEP  DALLAS FT WORTH        1035    AA 193            NON-STOP\r\n';
        temp += '                                               ECONOMY           BOEING 737-800\r\n';
        temp += '           ARR  SAN FRANCISCO          1215    CONFIRMED         03HR 40MIN\r\n';
        temp += '                TERMINAL 2                                       FOOD FOR PURCH\r\n';
        temp += '                HO/JESSICA MS\r\n';
        temp += '                FREQUENT FLYER - CX-1546629075\r\n';
        temp += '  \r\n';
        temp += ' SAT 04OCT DEP  SAN FRANCISCO          1345    CX 879            NON-STOP\r\n';
        temp += '                INTERNATIONAL TERMINAL         ECONOMY CLASS     B77ER\r\n';
        temp += '     05OCT ARR  HONG KONG              1900    CONFIRMED         14HR 15MIN\r\n';
        temp += '                TERMINAL 1\r\n';
        temp += '                HO/JESSICA MS      SEAT  59A**RESERVED**\r\n';
        temp += '                FREQUENT FLYER - CX-1546629075\r\n';
        temp += '    \r\n';
        temp += ' --- ----       --------------         ----    ------            ------------\r\n';
        temp += ' ONWARD/RETURN FLIGHT RESERVATIONS AND TIMING MUST BE\r\n';
        temp += ' RECONFIRMED 72 HOURS BEFORE DEPARTURE\r\n';
        temp += '  - TICKET CONDITIONS\r\n';
        temp += '  - HKG/LOS ANGELES/DALLAS//SAN FRANCISCO/HKG VALID ON CX ONLY\r\n';
        temp += '  - DALLAS/SAN FRANCISCO VALID ON AA ONLY\r\n';
        temp += '  - MAX STAY 1 MONTHS\r\n';
        temp += '  - NON-ENDORSABLE,NON-REROUTABLE,NON-REFUNDABLE\r\n';
        temp += '  - REBOOKING/HKD1300 PER TRANSACTION CHANGES AND MUST BE MADE\r\n';
        temp += '    BEFORE TICKETED FLIGHT/DATE,PLUS HKD100 HANDLING FEE\r\n';
        temp += '  - OTHERWISE ADDITIONAL NO SHOW FEE HKD1200 APPLIED\r\n';
        temp += '  - TICKET MUST BE REVALIDATED/REISSUED NO LATER THAN\r\n';
        temp += '    1 WORKING DAY AFTER THE ORIGINAL DEPARTURE DATE\r\n';
        temp += '  - DEPARTURE HKG VALID FROM 01AUG14-30JUN15\r\n';
        temp += '   \r\n';
        temp += '   \r\n';
        temp += ' AIRLINE CODE\r\n';
        temp += ' CX-CATHAY PACIFIC AIRWAY   REF:3HDKSO  AA-AMERICAN AIRLINES      REF:IDVMPA \r\n';
        temp += '   \r\n';
     }
     
     @IsTest
     public static void attachmentwithEP(){
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        List <Expense_Application__Feed > eafList;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        attachmentFileContent();
        preparation(true);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            expense_Application__c ea = new expense_Application__c ();
            ea.On_Behalf_Of__c= EmployeeAdministrator.get(userName).id;
            insert ea;
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            ApexPages.currentPage().getParameters().put('id', ea.id);
            TEExpenseApplicationCtrl eaCtrl = new TEExpenseApplicationCtrl();
            eaCtrl.ea.id = ea.id;
            Attachment attach = new Attachment (
            ParentId = ea.id,
            Name = 'TEST', 
            IsPrivate = false,
            ContentType =  'text/plain', 
            Body = Blob.valueOf(temp),
            Description = ''
            );
            insert attach;
            attachmentTO ato = new attachmentTO(attach, eaCtrl  );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            ato.deleteFile();
            ato = new attachmentTO(new Expense_Application__Feed (), eaCtrl);
            Test.stopTest();
        }
     }
     
     @IsTest
     public static void createTR() {
        attachmentFileContent();
        TestTEPreparation TEPreparation = new TestTEPreparation (false);
        TEPreparation.Preparation(false);
        
        Travel_Application__c tr = new Travel_Application__c ( status__c = TEConstant.STATUS_CONFIRMED  );
        insert tr;  
        system.assertNotEquals(tr.id, null);
        Traveloption__c to = new Traveloption__c(Travel_Application__c = tr.id, status__c = TEConstant.STATUS_CONFIRMED);
        insert to;  
        system.assertNotEquals(to.id, null);


        Attachment attach = new Attachment (
          ParentId = tr.Id,
          Name = 'TEST',//tr.Name,
          IsPrivate = false,
          ContentType =  'text/plain', 
          Body = Blob.valueOf(temp),
          Description = ''
        );
        insert attach;
        
        system.assertNotEquals(attach.id,  null); 
        
        Test.startTest(); 

        List<Journey__c> journeyList =  [select id, Flight__c,Cabin_Class__c, Cabin_Class_Display__c,To_Airport_Text__c, From_Airport_Text__c,  Departure_Date__c,ETD__c, Arrival_Date__c,ETA__c from Journey__c where Travel_Application__c = :tr.Id];
        
        system.assertEquals(journeyList.get(0).flight__c , 'CX 898');
        system.assertEquals(journeyList.get(1).flight__c , 'CX 7520');        
        system.assertEquals(journeyList.get(2).flight__c , 'AA 193');   
        system.assertEquals(journeyList.get(3).flight__c , 'CX 879');   


        system.assertEquals(String.Valueof(journeyList.get(0).Cabin_Class_Display__c).toUpperCase(), 'ECONOMY CLASS');
        system.assertEquals(String.Valueof(journeyList.get(1).Cabin_Class_Display__c).toUpperCase(), 'ECONOMY CLASS');        
        system.assertEquals(String.Valueof(journeyList.get(2).Cabin_Class_Display__c).toUpperCase(), 'ECONOMY CLASS');
        system.assertEquals(String.Valueof(journeyList.get(3).Cabin_Class_Display__c).toUpperCase(), 'ECONOMY CLASS');           

        system.assertEquals(journeyList.get(0).From_Airport_Text__c, 'HONG KONG');
        system.assertEquals(journeyList.get(1).From_Airport_Text__c, 'LOS ANGELES');        
        system.assertEquals(journeyList.get(2).From_Airport_Text__c, 'DALLAS FT WORTH');   
        system.assertEquals(journeyList.get(3).From_Airport_Text__c, 'SAN FRANCISCO');  


        system.assertEquals(journeyList.get(0).Departure_Date__c , Date.newInstance(2014, 09, 27));
        system.assertEquals(journeyList.get(1).Departure_Date__c , Date.newInstance(2014, 09, 27));        
        system.assertEquals(journeyList.get(2).Departure_Date__c , Date.newInstance(2014, 10, 04));   
        system.assertEquals(journeyList.get(3).Departure_Date__c , Date.newInstance(2014, 10, 04));   

        system.assertEquals(journeyList.get(0).ETD__c , '0930');
        system.assertEquals(journeyList.get(1).ETD__c , '1020');        
        system.assertEquals(journeyList.get(2).ETD__c , '1035');   
        system.assertEquals(journeyList.get(3).ETD__c , '1345');
         
        system.assertEquals(journeyList.get(0).To_Airport_Text__c, 'LOS ANGELES');
        system.assertEquals(journeyList.get(1).To_Airport_Text__c, 'DALLAS FT WORTH');        
        system.assertEquals(journeyList.get(2).To_Airport_Text__c, 'SAN FRANCISCO');   
        system.assertEquals(journeyList.get(3).To_Airport_Text__c, 'HONG KONG');
 
        system.assertEquals(journeyList.get(0).Arrival_Date__c , Date.newInstance(2014, 09, 27));
        system.assertEquals(journeyList.get(1).Arrival_Date__c , Date.newInstance(2014, 09, 27));        
        system.assertEquals(journeyList.get(2).Arrival_Date__c , Date.newInstance(2014, 10, 04));   
        system.assertEquals(journeyList.get(3).Arrival_Date__c , Date.newInstance(2014, 10, 05));   
        
        system.assertEquals(journeyList.get(0).ETA__c , '0755');
        system.assertEquals(journeyList.get(1).ETA__c , '1520');        
        system.assertEquals(journeyList.get(2).ETA__c , '1215');   
        system.assertEquals(journeyList.get(3).ETA__c , '1900');  
        
        List<Journey_Log__c> JourneyLogList = new List<Journey_Log__c>();
        for(Journey_Log__c reader: [select Name, id, Status__c from Journey_Log__c where   Travel_Application__c = :tr.Id]){
            reader.status__c = TEConstant.STATUS_CONFIRMED;
            JourneyLogList.add(reader);
        }
        upsert JourneyLogList;
        
        List <Journey__c> cancelJourneyList = [select id, status__c from Journey__c where travel_Application__c = :tr.id];
        for(Journey__c reader : cancelJourneyList){
            reader.status__c = TEConstant.STATUS_CANCELLED;
        }
        upsert cancelJourneyList;  
        Test.stopTest();

     }       
    
    
    
}