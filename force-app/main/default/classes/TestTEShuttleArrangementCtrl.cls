@isTest 
public class TestTEShuttleArrangementCtrl{
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
    public static void shuttle() {
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List <TETravelDetail> tdList = null;
        List <SelectOption> shuttleArrangementFromSelectionList = null;
        List <SelectOption> shuttleArrangementToSelectionList = null;
        TETravelDetail td = null;
        Integer counter = 1;
        preparation(false);
        UserMap = TETravelApplication.UserMap;
        recordTypeMap = TETravelApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
        TEShuttleArrangementAutoGenerationCtrl.autoGeneration();
        
        PageReference prf = null;    
        List<SelectOption> opt = null;    
        
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
        System.assertNotEquals(st.Id, null);
        for(Travel_Location__c reader : travelLocationMap.values() ){
            if (counter == 1){
                reader.site__c = TETravelApplication.NewSiteMap.get('TGA').id;
            }
            if (counter == 2){
                reader.site__c = TETravelApplication.NewSiteMap.get('HKO').id;
            }
            counter++;
        }
        upsert travelLocationMap.values();       
        System.runAs(UserMap.get(userName)){
            TETravelApplicationCtrl ta = null;
            ta = TETravelApplication.createTravelApplication(employee, EmployeeAdministrator, userName, TDRecordTypeMap.get('Shuttle'));
            tdList = ta.travelDetailList;
            td = tdList[0];
            td.DepartureDateTime = String.valueof(cj.Date__c.day()) + '/'+String.valueof(cj.Date__c.month())+'/'+String.valueof(cj.Date__c.year());
            td.ReturnDateTime = td.DepartureDateTime;
            td.TravelDetail.Shuttle_From__c = TETravelApplication.NewSiteMap.get('HKO').id;
            td.TravelDetail.Shuttle_To__c = TETravelApplication.NewSiteMap.get('TGA').id;
            td.TravelDetail.Admin_Pick_Up__c = true;
            td.TravelDetail.Site_To_Visit__c = 'TGA';
            td.TravelDetail.Departure_Pick_Up_Point__c = st.Id;
            td.TravelDetail.Return_Pick_Up_Point__c = st.Id;
            Test.startTest();
            ta.submitAction();
            System.assertNotEquals(ta.TravelApplication.Id, null);
            
            ApexPages.currentPage().getParameters().put('taid', ta.TravelApplication.Id );            
            ta = new TETravelApplicationCtrl();  
            tdList = ta.travelDetailList;
            td = tdList[0];   
            
            //update some fields in the travel detail
            List<Travel_Detail__c > tempTdList = new List<Travel_Detail__c>();
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Preferred_Departure_dt__c, Preferred_Return_dt__c,
                                                Status__c, Departure_Route__c, Return_Route__c 
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){    
                        reader.Preferred_Departure_dt__c = datetime.newInstance(cj.Date__c.year(), cj.Date__c.month(), cj.Date__c.addDays(1).day());
                        reader.Preferred_Return_dt__c = reader.Preferred_Departure_dt__c;
                        reader.Departure_Assigned_Shuttle__c = cj.Id;
                        reader.Departure_Route__c = r.Id;
                        reader.Return_Route__c = r.Id;
                        tempTdList.add(reader);
            }
            upsert tempTdList;
            
            
            //boolean testLoop = false;  
            
            System.assertNotEquals(td.TravelDetail.Id, null);
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Status__c, Departure_Route__c
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){
                System.assertEquals(reader.Preferred_Departure_Date__c , cj.Date__c);
                System.assertNotEquals(reader.Departure_Assigned_Shuttle__c, '');
                System.assertEquals(reader.Status__c, TEConstant.STATUS_PENDING_RESERVATION);
                System.assertNotEquals(reader.Departure_Route__c, null);
                //testLoop = true;
            }
            //System.assertEquals(testLoop, true);
            
            Test.setCurrentPage(Page.TEShuttleArrangementVFP);
            ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(cj);
            TEShuttleArrangementCtrl ctrl = new TEShuttleArrangementCtrl(sc);
            
            String testCar = ctrl.selectedCar;
            opt = ctrl.getRoutes();
            opt = ctrl.getPoints();
            
            //assign a shuttle for return
            if (!ctrl.unassignedSelectableJourneyList.isEmpty()){
                ctrl.unassignedSelectableJourneyList.get(0).selected = true;
            }
            prf = ctrl.addJourney();
            
            //send email for already assigned and remove a shuttle for departure
            //by making the status as CONFIRMED, the whole application will be cancelled
            if (!ctrl.selectableJourneyList.isEmpty()){
                ctrl.selectableJourneyList.get(0).selected = true;
            }
            ctrl.increaseSendEmailCounter();
 
            tempTdList.clear();
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Preferred_Departure_dt__c, Preferred_Return_dt__c,
                                                Status__c, Departure_Route__c, Return_Route__c 
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){    
                        reader.Status__c = TEConstant.STATUS_CONFIRMED;
                        tempTdList.add(reader);
            }
            upsert tempTdList;
            ctrl.rowToRemove = 0;
            prf = ctrl.removeThisRow();
            
            //test update occupied seats: delete
            Map<Id, Travel_Detail__c > oldTdMap = new Map<Id, Travel_Detail__c >();
            tempTdList.clear();
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Preferred_Departure_dt__c, Preferred_Return_dt__c, Return_Assigned_Shuttle__c,
                                                Status__c, Departure_Route__c, Return_Route__c 
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){    
                        reader.Departure_Assigned_Shuttle__c = cj.Id;
                        reader.Return_Assigned_Shuttle__c = cj.Id;
                        reader.No_of_Seats__c = 2;
                        tempTdList.add(reader);
                        oldTdMap.put(reader.Id, reader);
            }
            upsert tempTdList;
            TEShuttleAssignmentUpdateUtil.updateOccupiedSeats(oldTdMap, null);
            
            
            
            Map<Id, Travel_Detail__c > tempTdMap = new Map<Id, Travel_Detail__c >();
            tempTdList.clear();
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Preferred_Departure_dt__c, Preferred_Return_dt__c, Return_Assigned_Shuttle__c,
                                                Status__c, Departure_Route__c, Return_Route__c 
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){    
                        reader.Departure_Assigned_Shuttle__c = null;
                        reader.No_of_Seats__c = 2;
                        tempTdList.add(reader);
                        tempTdMap.put(reader.Id, reader);
            }
            upsert tempTdList;
            Test.stopTest();
            TEShuttleAssignmentUpdateUtil.updateOccupiedSeats(tempTdMap, null);
            
            tempTdList.clear();
            for (Travel_Detail__c reader : [Select Id, Preferred_Departure_Date__c, Departure_Assigned_Shuttle__c, 
                                                Preferred_Departure_dt__c, Preferred_Return_dt__c, Return_Assigned_Shuttle__c,
                                                Status__c, Departure_Route__c, Return_Route__c 
                                        From Travel_Detail__c Where Travel_Application__c = :ta.TravelApplication.Id]){    
                        reader.Return_Assigned_Shuttle__c = null;
                        reader.No_of_Seats__c = 2;
                        tempTdList.add(reader);
            }
            upsert tempTdList;
            
            TEShuttleAssignmentUpdateUtil.updateOccupiedSeats(oldTdMap, tempTdList);
            system.assertNotEquals(null, ctrl);
        }
        
    }
    
}