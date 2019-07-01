public class TEShuttleArrangementCtrl {
    
    public List<JourneyDecorator> selectableJourneyList {get;set;} { selectableJourneyList = new List<JourneyDecorator>(); }
    public List<JourneyDecorator> unassignedSelectableJourneyList {get;set;} { unassignedSelectableJourneyList = new List<JourneyDecorator>(); }
    public List<Travel_Detail__c> routeNotMatchedJourneyList {get;set;} { routeNotMatchedJourneyList = new List<Travel_Detail__c>(); }
        
    public List<Car_Journey__c> carJourneyList {get;set;} { carJourneyList = new List<Car_Journey__c>(); }
    public String selectedCar {get;set;}
    public Car_Journey__c currCj {get;set;}
    public Integer rowToRemove {get;set;}
    public string occupied {get;set;}
    public string vacant {get;set;}
    public boolean selectAllcheckbox {get;set;}

    
    public boolean isAdmin {get;set;}
    
    public TEShuttleArrangementCtrl(ApexPages.StandardController sc) {
        Car_Journey__c cj = (Car_Journey__c) sc.getRecord();
        List<Car_Journey__c> requeriedCj = [
            SELECT Id, Available_Seats__c, Occupied_Seats__c, Vacant_Seats__c, Route__c, Route__r.Name, Date__c, Company_Car__c,
                    Route__r.From__c, Route__r.To__c, Active__c
            //Company_Car_Type__c,
            FROM Car_Journey__c WHERE Id =: cj.Id
        ];
        if(requeriedCj != null && !requeriedCj.isEmpty()) {
            this.currCj = requeriedCj[0];
        }
        
        this.initTravelApplicationJourneys();
        this.initUnassignedJourneys();
        
        isAdmin = isAdmin();
    }
   
    //Find the shuttle travel details that have already been assigned to *this* shuttle
    private void initTravelApplicationJourneys() {
        
        List<Car_Journey__c> tempCj= [
            SELECT Id, Available_Seats__c, Occupied_Seats__c, Vacant_Seats__c, Route__c, Route__r.Name, Date__c, Company_Car__c,
                    Route__r.From__c, Route__r.To__c, Active__c
            FROM Car_Journey__c WHERE Id =: this.currCj.Id
            //Company_Car_Type__c,
        ];
        
        if(tempCj != null && !tempCj.isEmpty()) {
            this.currCj = tempCj[0];
            occupied = string.valueof(this.currCj.Occupied_Seats__c);
            vacant = string.valueof(this.currCj.Vacant_Seats__c);
        }
        this.selectableJourneyList.clear();
        this.routeNotMatchedJourneyList.clear();
        
        //get assigned travel details
        for(Travel_Detail__c td : [
            SELECT Id, Departure_Assigned_Shuttle__c,  Departure_Shuttle_Logistics__c, Departure_Shuttle_Summary__c, Departure_Route__c, Departure_Route__r.Name,
            Return_Assigned_Shuttle__c, Return_Shuttle_Logistics__c, Return_Shuttle_Summary__c, Return_Route__c, Return_Route__r.Name, Name,
            No_of_Seats__c, On_Behalf_Of__c, Preferred_Airline__c, Preferred_Departure_dt__c, Preferred_Return_dt__c,
            Shuttle_From__c, Shuttle_To__c, Shuttle_From__r.Name, Shuttle_To__r.Name,
            Departure_Pick_Up_Point__c, Return_Pick_Up_Point__c, Departure_Pick_Up__c, Return_Pick_Up__c,
            Confirmed_Departure_Pick_Up__c, Confirmed_Return_Pick_Up__c,
            Departure_Pick_Up_Point__r.Location__c , Return_Pick_Up_Point__r.Location__c, Departure_Pick_Up_Point__r.Arrival_Time__c, Return_Pick_Up_Point__r.Arrival_Time__c, 
            Confirmed_Departure_Route__c, Confirmed_Departure_Pick_Up_Point__c, Confirmed_Return_Route__c, Confirmed_Return_Pick_Up_Point__c,
            Confirmed_Departure_Route__r.Name, Confirmed_Return_Route__r.Name,
            Confirmed_Departure_Pick_Up_Point__r.Location__c, Confirmed_Departure_Pick_Up_Point__r.Arrival_Time__c,
            Confirmed_Return_Pick_Up_Point__r.Location__c, Confirmed_Return_Pick_Up_Point__r.Arrival_Time__c,
            Preferred_Departure_Date__c, Preferred_Return_Date__c, Travel_Application__c, Travel_Application__r.Id, Destination__c,
            Status__c, Tech_Send_Email_Departure_Counter__c, Tech_Send_Email_Return_Counter__c, Tech_Send_Email_Total_Counter__c
            FROM Travel_Detail__c 
            WHERE (Departure_Assigned_Shuttle__c = :this.currCj.Id OR Return_Assigned_Shuttle__c = :this.currCj.Id)
            AND (Status__c = :TEConstant.STATUS_PENDING_RESERVATION OR Status__c = :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION OR Status__c = :TEConstant.STATUS_CONFIRMED)
            //ORDER BY Id ASC
        ]) {
            //if route match, add to the list; if not match, add to a temp list and then add to THE list outside this loop
            if (td.Departure_Route__c == this.currCj.Route__c || td.Return_Route__c == this.currCj.Route__c){
                addToSelectableJourneyList(td);                
            }
            else{
                routeNotMatchedJourneyList.add(td);
            }
        }
        for (Travel_Detail__c td : routeNotMatchedJourneyList){
            addToSelectableJourneyList(td);
        }
    }
    
    private void addToSelectableJourneyList(Travel_Detail__c td) {
        if (td.Departure_Assigned_Shuttle__c == this.currCj.Id) {
            this.selectableJourneyList.add(new JourneyDecorator(false, td, 'D'));
        }
        if (td.Return_Assigned_Shuttle__c == this.currCj.Id) {
            this.selectableJourneyList.add(new JourneyDecorator(false, td, 'R'));
        }
    }
    
    //Find the shuttle travel details that havn't been assigned but match *this* shuttle schedule
    private void initUnassignedJourneys() {
        this.unassignedSelectableJourneyList.clear();
        this.routeNotMatchedJourneyList.clear();
        
        //get unassigned travel details
        for(Travel_Detail__c td : [
            SELECT Id, Departure_Assigned_Shuttle__c,  Departure_Shuttle_Logistics__c, Departure_Shuttle_Summary__c, 
            Departure_Route__c, Departure_Route__r.Name, On_Behalf_Of__c, Preferred_Departure_dt__c,
            Shuttle_From__c, Shuttle_To__c, Shuttle_From__r.Name, Shuttle_To__r.Name,
            Return_Assigned_Shuttle__c, Return_Shuttle_Logistics__c, Return_Shuttle_Summary__c, Preferred_Return_dt__c,
            Return_Route__c, Return_Route__r.Name, Name, No_of_Seats__c, Preferred_Airline__c,
            Departure_Pick_Up_Point__c, Return_Pick_Up_Point__c, Departure_Pick_Up__c, Return_Pick_Up__c,
            Confirmed_Departure_Pick_Up__c, Confirmed_Return_Pick_Up__c,
            Departure_Pick_Up_Point__r.Location__c , Return_Pick_Up_Point__r.Location__c, Departure_Pick_Up_Point__r.Arrival_Time__c, Return_Pick_Up_Point__r.Arrival_Time__c, 
            Confirmed_Departure_Route__c, Confirmed_Departure_Pick_Up_Point__c, Confirmed_Return_Route__c, Confirmed_Return_Pick_Up_Point__c,
            Confirmed_Departure_Route__r.Name, Confirmed_Return_Route__r.Name,
            Confirmed_Departure_Pick_Up_Point__r.Location__c, Confirmed_Departure_Pick_Up_Point__r.Arrival_Time__c,
            Confirmed_Return_Pick_Up_Point__r.Location__c, Confirmed_Return_Pick_Up_Point__r.Arrival_Time__c,
            Preferred_Departure_Date__c, Preferred_Return_Date__c, Travel_Application__c, Travel_Application__r.Id, Destination__c,
            Status__c, Tech_Send_Email_Departure_Counter__c, Tech_Send_Email_Return_Counter__c, Tech_Send_Email_Total_Counter__c
            FROM Travel_Detail__c 
            /**Note: in case of change, change the private method below too **/
            /**check route**/
            WHERE ((Departure_Route__c != null
                    AND Departure_Assigned_Shuttle__c = '' 
                    //AND Departure_Route__c = : this.currCj.Route__c              //*** uncomment this line if need check route
                    AND Preferred_Departure_Date__c = : this.currCj.Date__c        //*** comment this line if don't need exact match for dates
                    )
                    OR 
                    (Return_Route__c != null
                    AND Return_Assigned_Shuttle__c = '' 
                    //AND Return_Route__c = : this.currCj.Route__c                 //*** uncomment this line if need check route
                    AND Preferred_Return_Date__c = : this.currCj.Date__c           //*** comment this line if don't need exact match for dates
                    ))
                AND RecordType.DeveloperName = 'Shuttle'  
                AND (Status__c = :TEConstant.STATUS_PENDING_RESERVATION OR Status__c = :TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION OR Status__c = :TEConstant.STATUS_CONFIRMED)
            //ORDER BY Id ASC
        ]) {
            //if match this shuttle's route, add to the list; if not match, add to a temp list and then add to THE list outside this loop
            if (td.Departure_Route__c == this.currCj.Route__c || td.Return_Route__c == this.currCj.Route__c){
                addToUnassignedSelectableJourneyList(td);
            }
            else{
                routeNotMatchedJourneyList.add(td);
            }
        }
        for (Travel_Detail__c td : routeNotMatchedJourneyList){
            addToUnassignedSelectableJourneyList(td);
        }
        
        for (JourneyDecorator jd : unassignedSelectableJourneyList){
            if (jd.departure && jd.journey.Departure_Route__c == this.currCj.Route__c && jd.journey.Preferred_Departure_Date__c == this.currCj.Date__c){
                jd.journey.Confirmed_Departure_Pick_Up_Point__c = jd.journey.Departure_Pick_Up_Point__c;
            }
            else if (!jd.departure && jd.journey.Return_Route__c == this.currCj.Route__c && jd.journey.Preferred_Return_Date__c == this.currCj.Date__c){
                jd.journey.Confirmed_Return_Pick_Up_Point__c = jd.journey.Return_Pick_Up_Point__c;
            }
        }
    }
    
    private void addToUnassignedSelectableJourneyList(Travel_Detail__c td) {
        //if (td.Departure_Assigned_Shuttle__c == null && td.Departure_Route__c == this.currCj.Route__c) {
        if (td.Departure_Assigned_Shuttle__c == null && td.Preferred_Departure_Date__c == this.currCj.Date__c
            && td.Shuttle_From__c == this.currCj.Route__r.From__c //checking same shuttle direction
            //&& td.Shuttle_To__c == this.currCj.Route__r.To__c 
            ) {
            this.unassignedSelectableJourneyList.add(new JourneyDecorator(false, td, 'D'));
        }
        //if (td.Return_Assigned_Shuttle__c == null && td.Return_Route__c == this.currCj.Route__c) {
        if (td.Return_Assigned_Shuttle__c == null && td.Preferred_Return_Date__c == this.currCj.Date__c
            && td.Shuttle_To__c == this.currCj.Route__r.From__c   //checking same shuttle direction
            //&& td.Shuttle_From__c == this.currCj.Route__r.To__c
            ) {
            this.unassignedSelectableJourneyList.add(new JourneyDecorator(false, td, 'R'));
        }
    }
    
    public List<selectOption> getRoutes() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption(this.currCj.Route__c, this.currCj.Route__r.Name));
        return options; //return the picklist options
    }
    
    public List<selectOption> getPoints() {
        List<selectOption> options = new List<selectOption>(); //new list for holding all of the picklist options
        options.add(new selectOption('', '-- Please Select --')); //add the first option of '- None -' in case the user doesn't want to select a value or in case no values are returned from query below
        for (Shuttle_Stop__c ss: [SELECT Id, Name, Arrival_Time__c, Location__c, Stop_Type__c FROM Shuttle_Stop__c 
                                  Where Stop_Type__c = :'P' AND Route__c = :this.currCj.Route__c
                                  ORDER BY Arrival_Time__c]) { //query for Currency
            options.add(new selectOption(ss.Id, ss.Location__c + ' (' + ss.Arrival_Time__c + ')')); //for all records found - add them to the picklist options
        }
        return options; //return the picklist options
    }
    
    public PageReference addJourney() {
        List<Travel_Detail__c> journeys = new List<Travel_Detail__c>();
        Decimal seatCount = 0;
        
        for(JourneyDecorator jd : this.unassignedSelectableJourneyList) {
            if(jd.selected) {
                if (jd.direction == 'D') {
                    if (jd.journey.Confirmed_Departure_Route__c != null && jd.journey.Confirmed_Departure_Pick_Up_Point__c != null){
                        jd.journey.Departure_Assigned_Shuttle__c = this.currCj.Id;
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, jd.journey.Name + Label.TE_Shuttle_Assignment_Select_Pick_up_Point));
                    }
                }
                else if (jd.direction == 'R') {
                    if (jd.journey.Confirmed_Return_Route__c != null && jd.journey.Confirmed_Return_Pick_Up_Point__c != null){
                        jd.journey.Return_Assigned_Shuttle__c = this.currCj.Id;
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, jd.journey.Name + Label.TE_Shuttle_Assignment_Select_Pick_up_Point)); 
                    }
                }
                seatCount = seatCount + jd.journey.No_of_Seats__c;
                journeys.add(jd.journey);  
            }
        }
/*
        if (seatCount > this.currCj.Vacant_Seats__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.TE_Too_Many_Shuttle_Assignments));
        }
        else {
*/
        try {
            Set<Travel_Detail__c> uniqueSet = new Set<Travel_Detail__c>();
            List<Travel_Detail__c> uniqueJourneys = new List<Travel_Detail__c>();
            uniqueSet.addAll(journeys);
            uniqueJourneys .addAll(uniqueSet);
            update uniqueJourneys;
        } 
        catch (Exception e) {
            if (seatCount <= this.currCj.Vacant_Seats__c){
                ApexPages.addmessages(e);
            }
        }
        
        this.initTravelApplicationJourneys();
        this.initUnassignedJourneys();
        return null;
        
    }
    
    public PageReference removeThisRow(){
        JourneyDecorator jdToRemove = selectableJourneyList[rowToRemove];
        //update journey
        jdToRemove.journey = [SELECT id, Departure_Assigned_Shuttle__c, Return_Assigned_Shuttle__c, Status__c,
                                    Confirmed_Departure_Pick_Up_Point__c, Confirmed_Departure_Route__c, Confirmed_Return_Pick_Up_Point__c, Confirmed_Return_Route__c,
                                    Destination__c, Travel_Application__c, Travel_Application__r.Id
                                FROM Travel_Detail__c WHERE Id =: jdToRemove.journey.Id Limit 1];
        if (jdToRemove.direction == 'D') {
            jdToRemove.journey.Departure_Assigned_Shuttle__c = null;
            jdToRemove.journey.Confirmed_Departure_Pick_Up_Point__c = null;
            jdToRemove.journey.Confirmed_Departure_Route__c = null;
        }
        else if (jdToRemove.direction == 'R') {
            jdToRemove.journey.Return_Assigned_Shuttle__c = null;
            jdToRemove.journey.Confirmed_Return_Pick_Up_Point__c = null;
            jdToRemove.journey.Confirmed_Return_Route__c = null;
        }
        //if it's been confirmed before, change its status to cancelled, and remove both assignments for departure and return shuttles
        //cancel corresponding accommodation requests, and the travel application too if necessary
        List<Accommodation__c> accToUpdate = new List<Accommodation__c>();            //accommodation to update list
        List<Travel_Application__c> taToUpdate = new List<Travel_Application__c>();    //travel application to update list
        if (jdToRemove.journey.Status__c == TEConstant.STATUS_CONFIRMED){
            jdToRemove.journey.Status__c = TEConstant.STATUS_CANCELLED;
            jdToRemove.journey.Departure_Assigned_Shuttle__c = null;
            jdToRemove.journey.Return_Assigned_Shuttle__c = null;
            
            boolean cancelApplication = true;
            for (Accommodation__c a : [SELECT Id, Location__c, Travel_Application__c, Status__c FROM Accommodation__c 
                                        WHERE Travel_Application__c =: jdToRemove.journey.Travel_Application__c
                                              AND Status__c != :TEConstant.STATUS_CANCELLED]){
                if (a.Location__c == jdToRemove.journey.Destination__c){
                    a.Status__c = TEConstant.STATUS_CANCELLED;
                    accToUpdate.add(a);
                }
                else{
                    cancelApplication = false;
                }
            }
            if (cancelApplication != false){
                for (Travel_Detail__c td : [SELECT Id, Travel_Application__c FROM Travel_Detail__c 
                                        WHERE Travel_Application__c =: jdToRemove.journey.Travel_Application__c
                                              AND Status__c != :TEConstant.STATUS_CANCELLED]){
                    if (td.Id != jdToRemove.journey.Id){
                        cancelApplication = false;
                    }
                }
            }
            if (cancelApplication != false){
                for (Travel_Application__c ta : [SELECT Id, Status__c FROM Travel_Application__c WHERE Id =: jdToRemove.journey.Travel_Application__r.Id
                                              AND Status__c != :TEConstant.STATUS_CANCELLED]){
                    ta.Status__c = TEConstant.STATUS_CANCELLED;
                    taToUpdate.add(ta);
                }
            }
        }
        if (!taToUpdate.isEmpty()){
            update taToUpdate;
        }
        if (!accToUpdate.isEmpty()){
            update accToUpdate;
        }
        update jdToRemove.journey;
        this.initTravelApplicationJourneys();
        this.initUnassignedJourneys();
        return null;
    }
    
    private Boolean isAdmin(){
          for (SetupEntityAccess  readrer : [SELECT Id
                FROM SetupEntityAccess 
                where SetupEntityId in ( SELECT Id  FROM CustomPermission where DeveloperName = 'TE_Is_Admin' )
                and ParentId in 
                (
                    SELECT   PermissionSetId
                    FROM PermissionSetAssignment
                    where AssigneeId  = :UserInfo.getUserId()
                )
          ]){
              return true;
          }
          return false;
    }
        

    public void increaseSendEmailCounter(){
        List<Travel_Detail__c> updateJourneyList = new List<Travel_Detail__c>();
        for(JourneyDecorator jd : this.selectableJourneyList ) {
            if(jd.selected) {
                if (jd.direction == 'D') {
                    jd.journey.Tech_Send_Email_Departure_Counter__c = jd.journey.Tech_Send_Email_Departure_Counter__c+ 1;
                }
                else if (jd.direction == 'R') {
                    jd.journey.Tech_Send_Email_Return_Counter__c = jd.journey.Tech_Send_Email_Return_Counter__c + 1;
                }
                updateJourneyList.add(jd.journey);
            }
        }
        selectAllcheckbox = false;
        update updateJourneyList;
        this.initTravelApplicationJourneys();
        this.initUnassignedJourneys();
    }
       
    /**
     * @description Decorator class for Journey with a boolean to mark as selected
     */
    private class JourneyDecorator {
        public boolean selected {get;set;}
        public Travel_Detail__c journey {get;set;}
        public string direction {get;set;}
        public boolean departure {get;set;}
       // public string shuttleSummary {get;set;}
       // public string shuttleLogistics {get;set;}
        
        public JourneyDecorator(boolean selected, Travel_Detail__c journey, string direction) {
            this.selected = selected;
            this.journey = journey;
            this.direction = direction;
            if (direction == 'D') {
                departure = true;
            }
            else if (direction == 'R') {
                departure = false;
            }
        }
    }
}