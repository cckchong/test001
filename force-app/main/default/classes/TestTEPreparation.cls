public virtual class TestTEPreparation  extends TestELeavePreparation{

    //Pre-Set
    Public String RANDOM_STRING = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    
    //user dateSet
    public Map<String, User> UserMap ;
    public Map<String, Employee__c> EmployeeMap ;
    public Map<String, Employee_Administrator__c> EmployeeAdministratorMap;
    
    //Currency and Exchange Rate dateSet
    public TestTEExchangeRatePreparation testTEExchangeRatePreparation;
    public Map<String, Currency__c> currencyMap {get;set;}
    public Map<String, Exchange_Rate__c> exchangeRateMap {get;set;}

    //All policies dataSet
    public TestTEPolicyTypePreparation testTEPolicyTypePreparation;
    public Map<String, Site__c> NewSiteMap {get; set;}
    public Map<String, Expense_Policy__c> ExpensePolicyMap {get; set;}
    public Map<String, Expense_Type__c> ExpenseTypeMap {get; set;}
    public Map<String, Travel_Policy__c> TravelPolicyMap {get; set;}
    //public Map<String, Travel_Application_Type__c> TravelApplicationTypeMap {get; set;}
    public Map<String, Education_Policy__c> EducationPolicyMap {get; set;}
    public Map<String, RecordType> RecordTypeMap {get; set;}
    
    //All Shuttle DataSet
    public TestTERoutePreparation testTERoutePreparation;
    public Map<String, Route__c> RouteMap {get;set;} 
    public Map<String, Company_Car__c> companyCarMap {get;set;}
    public Map<String, Car_Journey__c> carJourneyMap {get;set;}
    
    //All location and Airport DateSet
    public TestTECarbonEmissionPreparation testTECarbonEmissionPreparation;
    public Map<String, Travel_Location__c> travelLocationMap {get;set;}
    public Map<String, Airport__c> AirportMap {get;set;}
    public Map<String, Cabin_Class__c> CabinClassMap {get;set;}
    
    //Travel Location Allowance
    public TestTETravelAllowancePreparation testTETravelAllowancePreparation{get;set;} 
    
    
    
    public TestTEPreparation( Boolean isSeeAllData ){
        super(isSeeAllData);
    }
    
    public void Preparation(Boolean isSeeAllData) {
        
        //Setup User
        this.UserMap = getUserMap();
        this.EmployeeMap = getEmployeeMap(this.UserMap);
        this.EmployeeAdministratorMap = getFromEmpId(this.EmployeeMap);
        
        //Setup Currency and Exchange Rate
        testTEExchangeRatePreparation = new TestTEExchangeRatePreparation(isSeeAllData);
        testTEExchangeRatePreparation.basicSetting();
        this.currencyMap = testTEExchangeRatePreparation.currencyMap;
        this.exchangeRateMap = testTEExchangeRatePreparation.exchangeRateMap;
        
        //Setup travel, education and expense policies
        this.testTEPolicyTypePreparation = new TestTEPolicyTypePreparation(isSeeAllData, currencyMap);
        this.testTEPolicyTypePreparation.basicSetting();
        this.NewSiteMap = testTEPolicyTypePreparation.NewSiteMap;
        this.ExpensePolicyMap = testTEPolicyTypePreparation.ExpensePolicyMap;
        this.ExpenseTypeMap = testTEPolicyTypePreparation.ExpenseTypeMap;
        this.TravelPolicyMap = testTEPolicyTypePreparation.TravelPolicyMap;
        //this.TravelApplicationTypeMap = testTEPolicyTypePreparation.TravelApplicationTypeMap;
        this.EducationPolicyMap = testTEPolicyTypePreparation.EducationPolicyMap;
        this.RecordTypeMap = testTEPolicyTypePreparation.RecordTypeMap;  
        
        //Init Employee Setting
        initSetting();
        
        //Setup Shuttle
        this.testTERoutePreparation = new TestTERoutePreparation(isSeeAllData, TravelPolicyMap.get('HKO').Id, this.NewSiteMap);
        this.testTERoutePreparation.basicSetting();
        
        
        //Setup travel location, Carbon Emission, Airport, Cabin Class, Flight Type
        this.testTECarbonEmissionPreparation = new TestTECarbonEmissionPreparation(isSeeAllData);
        testTECarbonEmissionPreparation.basicSetting();
        travelLocationMap = testTECarbonEmissionPreparation.travelLocationMap;
        airportMap = testTECarbonEmissionPreparation.airportMap;
        cabinClassMap = testTECarbonEmissionPreparation.cabinClassMap;
        
        //Setup Travel Location Allowance
        testTETravelAllowancePreparation = new TestTETravelAllowancePreparation(isSeeAllData);
        testTETravelAllowancePreparation.basicSetting(expensePolicyMap, travelLocationMap);
        
    }
    
    public void initSetting() {
        List<Id> empIDList = new List<Id>();
        for (Employee__c emp : EmployeeMap.values()) {
            if ((emp.Original_Employee_ID__c).equals('user1') || (emp.Original_Employee_ID__c).equals('user2')) {
                empIDList.add(emp.Id);
            }
        }
        setProperties(EducationPolicyMap.get('HKO').Id, TravelPolicyMap.get('HKO').Id, ExpensePolicyMap.get('HKO').Id, empIDList);
        //setPermissionSet(UserMap);
    }
    
    public static Map<String, Employee_Administrator__c> getFromEmpId(Map<String, Employee__c> empMap) {
        Map<String, Employee_Administrator__c> empAdminMap = new Map<String, Employee_Administrator__c>();
        Map<Id, Employee_Administrator__c> empIDMap = new Map<Id, Employee_Administrator__c>();
        List<Id> empIDList = new List<Id>();
        for (Employee__c emp : empMap.values()) {
            empIDList.add(emp.Id);
        }
        for (Employee_Administrator__c empAdmin : [SELECT Id, Name, Employee__c, Is_Self__c, Is_Employee_Active__c, Is_Mine__c, Employee_ID_and_Administrator_ID__c, 
                                                   Employee_Full_Name__c, Employee_Department__c, Employee_Administrator__c, Administrator__c, Keyword__c, 
                                                   Employee_UserId__c, Is_Active__c, On_Behalf_of_Grade__c FROM Employee_Administrator__c where Employee__c IN :empIDList]) {
                                                       empIDMap.put(empAdmin.Employee__c, empAdmin);
                                                   }
        String key;
        for (String empStr : empMap.keySet()) {
            if (empIDMap.containsKey(empMap.get(empStr).Id)) {
                key = empStr;
                if (empStr.equals('Testing (HKOTuser1)')) {
                    key = 'user1';
                } else if (empStr.equals('Testing (HKOTuser2)')) {
                    key = 'user2';
                }
                empAdminMap.put(key, empIDMap.get(empMap.get(empStr).Id));
            }
        }
        return empAdminMap;
    }
    
    public  Employee__c getEmployeefromOriginalEmployeeID(String originalEmployeeID) {
        Employee__c employee = null;
        for (Employee__c emp :[select id, Name, First_Name__c, Last_Name__c,
                               Timeset__c, user__c, Notif_Leave_Forfeiture__c, Department__c,
                               Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c,
                               Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c,
                               Original_Employee_ID__c, Expense_Policy__c, Expense_Policy__r.Name,
                               Expense_Policy__r.Local_Currency__r.Name ,Expense_Policy__r.Finance_Email__c,
                               Education_Policy__c, Travel_Policy__c, Leave_Policy__c,
                               passport_type_1__c, passport_type_2__c, passport_type_3__c
                               from Employee__c
                               where Original_Employee_ID__c = :originalEmployeeID] ) 
        { 
            employee = emp;                       
        }
        
        return employee;
    }
    
    /*
    public void setPermissionSet(Map<String, User> userMap){
        String permissionNamePrefix = 'TE_%';
        List <Id> permissionSetList = new List <Id>();
        List <PermissionSetAssignment> PermissionSetAssignmentList = new List <PermissionSetAssignment>();
       
        for ( PermissionSet reader : [select id, Name from PermissionSet WHERE Name like :permissionNamePrefix] ){
            for(user u : userMap.values()){
                PermissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = reader.id));
            }
        }
        if(!PermissionSetAssignmentList.isEmpty()){
            upsert PermissionSetAssignmentList;
        }
    }
    */
    
    public void setProperties(Id eduPolicyId, Id travelPolicyId, Id expensePolicyId, List<Id> employeeId) {
        
        List<Employee__c> emp = new List<Employee__c>();
        List<SelectOption> options = new List<SelectOption>();        
        Schema.DescribeFieldResult fieldResult = null;
        List<Schema.PicklistEntry> ple = null;
        for (Employee__c e : [SELECT Id, Education_Policy__c, Travel_Policy__c, Expense_Policy__c
                              FROM Employee__c 
                              WHERE Id IN :employeeId]){
                                  e.Education_Policy__c = eduPolicyId;
                                  e.Travel_Policy__c = travelPolicyId;
                                  e.Expense_Policy__c = expensePolicyId;
                                  e.Passport_Full_Name__c =  generateRandomString(5);
                                  e.Passport_Full_Name_2__c = generateRandomString(5);
                                  e.Passport_Full_Name_3__c = generateRandomString(5);
                                  e.Passport_Issue_Date_1__c = System.today().adddays(-10);
                                  e.Passport_Issue_Date_2__c = System.today().adddays(-10);
                                  e.Passport_Issue_Date_3__c = System.today().adddays(-10);
                                  e.Passport_Expiry_Date_1__c= System.today().adddays(10);
                                  e.Passport_Expiry_Date_2__c= System.today().adddays(10);
                                  e.Passport_Expiry_Date_3__c= System.today().adddays(10);
                                  e.Passport_No_1__c = generateRandomString(5);
                                  e.Passport_No_2__c = generateRandomString(5);
                                  e.Passport_No_3__c = generateRandomString(5);
                                  fieldResult = Employee__c.passport_type_1__c.getDescribe();
                                  ple = fieldResult.getPicklistValues();    
                                  for( Schema.PicklistEntry f : ple){
                                     e.passport_type_1__c = f.getValue();
                                  }
                                  fieldResult = Employee__c.passport_type_2__c .getDescribe();
                                  ple = fieldResult.getPicklistValues();    
                                  for( Schema.PicklistEntry f : ple){
                                     e.passport_type_2__c = f.getValue();
                                  }
                                  fieldResult = Employee__c.passport_type_3__c .getDescribe();
                                  ple = fieldResult.getPicklistValues();    
                                  for( Schema.PicklistEntry f : ple){
                                     e.passport_type_3__c = f.getValue();
                                  }
                                  e.Preferred_Seat__c = 'W';
                                  e.is_Driver__c = true;
                                  e.Mobile__c = generateRandomString(5);
                                  e.TAL_Direct_Line__c = generateRandomString(5);
                                  emp.add(e);
                              }
        if (!emp.isEmpty()){
            update emp;
            EmployeeMap.clear();
            for ( Employee__c reader : 
                [
                    select id, Name, First_Name__c, Last_Name__c,
                    Education_Policy__c, Travel_Policy__c, Expense_Policy__c, 
                    Leave_Policy__c, Timeset__c, user__c, Notif_Leave_Forfeiture__c,
                    Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c,
                    Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c,
                    Original_Employee_ID__c 
                    from Employee__c
                    where Original_Employee_ID__c in ( 'user1', 'user2' )
            ]){
                EmployeeMap.put (reader.name, reader);
            }
        }
    }
    /*
    public TETravelApplicationCtrl createTravelApplication(Employee__c employee, Map<String, Employee_Administrator__c> ea, String userName, String tdRecordTypeId){
        
        TETravelApplicationCtrl ta = new TETravelApplicationCtrl();
         TETravelDetail td = null;
        List <TETravelDetail> tdList = null;
        
        ta.TravelApplication.Selected_Passport__c = employee.passport_type_1__c;
        ta.TravelApplication.On_Behalf_of__c = ea.get(userName).id;
        
        //Create Travel Detail
        tdList = ta.travelDetailList;
         
        td = tdList[0];
        //Input one air travel detail row 
        td.TravelDetail.recordTypeId = tdRecordTypeId;
        td.DepartureDateTime = '01/01/2016 12:00';
        td.ReturnDateTime = '01/01/2017 12:00';
        td.TravelDetail.Origin_Site__c = travelLocationMap.get('HONGKONG').id;
        td.TravelDetail.Destination__c = travelLocationMap.get('LOSANGELES').id;            
        for(TEAccommodationCtrl reader :  ta.travelAccommodationList){
            if (String.IsBlank(reader.checkInDate)){
                reader.checkInDate = '';
            }
            if (String.IsBlank(reader.checkoutDate)){
                reader.checkOutDate = '';
            }
        }            
        //Create Accommodation
        ta.accommodationAddRow();
        return ta;
    }
    */
    
    Public Map<String, Map<String, String>> getRecordType(){
        Map<String, Map<String, String>> rtMap = new Map<String, Map<String, String>>();
        String tdSobj = Travel_Detail__c.sObjectType.getDescribe().getName();        
        Map<String, String> tmp = null;
        for(RecordType reader : [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType 
                                 where SobjectType = :tdSobj and IsActive = true
        ] ){
            addRt(rtMap, tdSobj, reader.Name, reader.id);
        }
        return rtMap ;
    }
    
    
    private Map<String, Map<String, String>> addRt(Map<String, Map<String, String>> rtMap, String sObj, String Name, String Id){
         Map<String, String> tmp = null;
         if(rtMap.containsKey(sObj)){
                tmp = rtMap.get(sObj);
                tmp.put(Name, id);
            }
            else{
                tmp = new Map<String, String>();
                tmp.put(Name, id);
                rtMap.put(sObj, tmp);
            }
         return rtMap;
    }
    
    public String generateRandomString(Integer len) {
       final String chars = RANDOM_STRING ;
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
        randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
   }
    

}