public class TEShuttleAssignmentCtrl {
    private static final String LIST_VIEW_All = 'All';
    private static final String LIST_VIEW_ALL_ACTIVE = 'All Active';
    private static final String LIST_VIEW_UPCOMING = 'Upcoming - All';
    private static final String LIST_VIEW_THIS_WEEK = 'This Week';
    private static final String LIST_VIEW_NEXT_WEEK = 'Next Week';
    private static final String LIST_VIEW_TWO_WEEK = 'These Two Weeks';
    private static final String SOQL_FROM_SHUTTLE = 'Select id, Date__c, Route__r.id, Route__r.Name, Route__c, Name, Remarks__c, ' +
                                                      'Vacant_Seats__c, Company_Car__r.id, Company_Car__r.Name, Occupied_Seats__c, ' +
                                                      'Active__c, Driver_Name__c, Driver_Mobile__c, Driver_TAL_Direct_Line__c ' +
                                               'From Car_Journey__c ';
    //private static final String TEST_ROUTE_ID = '';                                     

    public List<Car_Journey__c> carJourneyList {get;set;} { carJourneyList = new List<Car_Journey__c>(); }
    public List<ShuttleDecorator> shuttleList {get;set;} { shuttleList = new List<ShuttleDecorator>(); }
    public String selectedListView{get;set;}
    public Date fromDate{get;set;}
    public string fromDateStr{get;set;}
    public Date toDate{get;set;}
    public string toDateStr{get;set;}
    public Boolean isActive{get;set;}
    public Map<String , Integer> tdcounter{get;set;} { tdcounter = new Map<String , Integer>();}
    
    public TEShuttleAssignmentCtrl(ApexPages.StandardController sc) {
        selectedListView = LIST_VIEW_TWO_WEEK;
        onListViewChange();
    }
    
    public List<SelectOption> getListViews(){
        List<SelectOption> optns = new List<Selectoption>();
        optns.add(new selectOption(LIST_VIEW_UPCOMING, LIST_VIEW_UPCOMING));
        optns.add(new selectOption(LIST_VIEW_THIS_WEEK, LIST_VIEW_THIS_WEEK));
        optns.add(new selectOption(LIST_VIEW_NEXT_WEEK, LIST_VIEW_NEXT_WEEK));
        optns.add(new selectOption(LIST_VIEW_TWO_WEEK, LIST_VIEW_TWO_WEEK));         
        return optns;
    }
    
    public void onListViewChange(){
         if (selectedListView == LIST_VIEW_All){
             this.fromDateStr = '';
             this.toDateStr = '';
             this.isActive = true;
             //runQuery(SOQL_FROM_SHUTTLE);
         }
         else if (selectedListView == LIST_VIEW_ALL_ACTIVE){
             this.isActive = true;
             //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c >= TODAY AND Active__c = TRUE ');
         }
         else if (selectedListView == LIST_VIEW_UPCOMING){
             this.fromDateStr = System.today().format();
             this.toDateStr = '';
             this.isActive = true;
             //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c >= TODAY ');
         }
         else if (selectedListView == LIST_VIEW_THIS_WEEK){
             this.fromDateStr = System.today().toStartofWeek().format();
             this.toDateStr = System.today().toStartofWeek().adddays(6).format();
             this.isActive = true;
             //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c = THIS_WEEK ');
         }
         else if (selectedListView == LIST_VIEW_NEXT_WEEK){
             this.fromDateStr = System.today().toStartofWeek().adddays(7).format();
             this.toDateStr = System.today().toStartofWeek().adddays(13).format();
             this.isActive = true;
             //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c = NEXT_WEEK ');
         }
         else if (selectedListView == LIST_VIEW_TWO_WEEK){
             this.fromDateStr = System.today().toStartofWeek().format();
             this.toDateStr = System.today().toStartofWeek().adddays(13).format();
             this.isActive = true;
         }
         showFilteredShuttles();
    }
    
    private void runQuery(string query) {
        carJourneyList.clear();
        //tmp = query;
        carJourneyList = Database.query(query + ' Limit 1000 ');  
    }
    
    private void incrementToCounterMap(String key) {
        if (this.tdcounter.containsKey(key)){
            this.tdcounter.put(key, this.tdcounter.get(key) + 1);
        }
        else{
            this.tdcounter.put(key, 1);
        }
    }
    
    private void getTdCount(List<Car_Journey__c> carJourneyListResult) {
        this.tdcounter.clear();
        Map<Id, String> carJourneyDateRoute = new Map<Id, String>();
        for (Car_Journey__c cj : carJourneyListResult){
            carJourneyDateRoute.put(cj.id, cj.Date__c.format() + cj.Route__c);
        }
        
        /**
        System.Debug('@@@@@@@@@@@@@@@@@@@@@Groupable');
        system.Debug(Schema.sObjectType.travel_detail__c.fields.Tech_Return_Date_Route__c.isGroupable());
        AggregateResult[] departureAggregate = [Select Tech_Departure_Date_Route__c , count(id) tdCount
                                             From travel_detail__c 
                                             Where Tech_Departure_Date_Route__c in :carJourneyDateRoute.values() 
                                             And Departure_Assigned_Shuttle__c = null
                                             Group By Tech_Departure_Date_Route__c];
        
        AggregateResult[] returnAggregate = [Select Tech_Return_Date_Route__c , count(id) tdCount
                                             From travel_detail__c 
                                             Where Tech_Return_Date_Route__c in :carJourneyDateRoute.values() 
                                             And Return_Assigned_Shuttle__c = null
                                             Group By Tech_Return_Date_Route__c];
        
        for (AggregateResult ar : departureAggregate){
            tdcounter.put((string)ar.get('Tech_Departure_Date_Route__c'), (integer) ar.get('tdCount'));
        }         
        
        for (AggregateResult ar : returnAggregate){
            if (tdcounter.containsKey((string)ar.get('Tech_Return_Date_Route__c'))){
                tdcounter.put((string)ar.get('Tech_Return_Date_Route__c'), 
                              tdcounter.get((string)ar.get('Tech_Return_Date_Route__c')) + (integer) ar.get('tdCount'));
            }
            else{
                tdcounter.put((string)ar.get('Tech_Departure_Date_Route__c'), (integer) ar.get('tdCount'));
            }
        }
        **/
       
        List<travel_detail__c> dtdList = [Select Tech_Departure_Date_Route__c , Id
                                             From travel_detail__c 
                                             Where 
                                             Tech_Departure_Date_Route__c in :carJourneyDateRoute.values() 
                                             And Departure_Assigned_Shuttle__c = null
                                             And 
                                             (Status__c = : TEConstant.STATUS_PENDING_RESERVATION
                                             OR Status__c = : TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION
                                             OR Status__c = : TEConstant.STATUS_CONFIRMED
                                             )
                                            // Group By Tech_Departure_Date_Route__c
                                            ];
        
        List<travel_detail__c> rtdList = [Select Tech_Return_Date_Route__c , Id
                                             From travel_detail__c 
                                             Where Tech_Return_Date_Route__c in :carJourneyDateRoute.values() 
                                             And Return_Assigned_Shuttle__c = null
                                             And
                                             (Status__c = : TEConstant.STATUS_PENDING_RESERVATION
                                             OR Status__c = : TEConstant.STATUS_PENDING_APPLICANT_CONFIRMATION
                                             OR Status__c = : TEConstant.STATUS_CONFIRMED
                                             )
                                            // Group By Tech_Return_Date_Route__c
                                            ];
                                            
        for (travel_detail__c td : dtdList){
            incrementToCounterMap(td.Tech_Departure_Date_Route__c);
        }         
        for (travel_detail__c td : rtdList){
            incrementToCounterMap(td.Tech_Return_Date_Route__c);
        }
    }
    
    public void showFilteredShuttles(){  
        //**
        String todateString;
        String fromdateString;
        String sql;
        List<String> conditions = new List<String>();
        if (fromDateStr != '')
        {
            fromDate = Date.parse(fromDateStr );
            fromdateString = Datetime.newInstance(fromDate , Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
            conditions.add('Date__c >= ' + fromdateString);
            //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c <= ' + fromdateString);
        }
        if (toDateStr!= '')
        {
            toDate = Date.parse(toDateStr);
            todateString = Datetime.newInstance(toDate, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
            conditions.add('Date__c <= ' + todateString );
            //runQuery(SOQL_FROM_SHUTTLE + 'Where Date__c <= ' + todateString );
        }
        conditions.add('Active__c = ' + isActive);
        sql = SOQL_FROM_SHUTTLE;
        if(!conditions.isEmpty()) {
            sql +=  'Where '+String.format(' {0}',new List<String>{ String.join(conditions, ' AND ') });
        }
        //1. get the list of shuttles
        runQuery(sql); 
        //2. get shuttle requests count for the shuttle list
        getTdCount(this.carJourneyList);
        //3. construct shuttle decorator class list with counts
        this.initShuttleList();
    }
    
    public PageReference newShuttleSchedule(){  
        String returnURL = '';
        PageReference returnPage;
        String preFix = '';
        
        Schema.DescribeSObjectResult r = Car_Journey__c.sObjectType.getDescribe();
        preFix  = r.getKeyPrefix();
        returnURL = '/' + preFix + '/e?retURL=/apex/TEShuttleAssignmentVFP';
        
        returnPage = new PageReference(returnURL);
        return returnPage;
    }
    
    private void initShuttleList() {
        this.ShuttleList.clear();
        for (Car_Journey__c cj : carJourneyList){
            if (tdCounter.containsKey(cj.Date__c.format() + cj.Route__c)){
                this.ShuttleList.add(new ShuttleDecorator(cj, tdCounter.get(cj.Date__c.format() + cj.Route__c)));
            }
            else{
                this.ShuttleList.add(new ShuttleDecorator(cj, 0));
            }
        }
    }
    
    /**
     * @description Decorator class for Shuttle with a count of shuttle requests
     */
    private class ShuttleDecorator {
        public Car_Journey__c cj {get;set;}
        public integer requestCount {get;set;}
        
        public ShuttleDecorator(Car_Journey__c cj, integer count) {
            this.cj = cj;
            this.requestCount = count;
        }
    }
}