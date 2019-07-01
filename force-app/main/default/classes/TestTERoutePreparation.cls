@istest
public class TestTERoutePreparation {
    
    public Map<String, Route__c> RouteMap {get;set;}
    public Map<String, Company_Car__c> companyCarMap {get;set;}
    public Map<String, Car_Journey__c> carJourneyMap {get;set;}
    public Map<String, Site__c> SiteMap {get;set;}
    public Map<String, Shuttle_Stop__c> shuttleStopMap {get;set;}
    public Boolean isSeeAllData;
    Public Id travelPolicyId;
    
    public TestTERoutePreparation(Boolean isSeeAllData , Id travelPolicyId, Map<String, Site__c> SiteMap) {
        this.isSeeAllData = isSeeAllData;
        this.travelPolicyId = travelPolicyId;
        this.SiteMap = SiteMap;
        this.RouteMap = new Map<String, Route__c>();
        this.companyCarMap = new Map<String, Company_Car__c>();
        this.carJourneyMap = new Map<String, Car_Journey__c>();
    }
    
    public void BasicSetting() {
    
        List<Company_Car__c> companyCarList = new List<Company_Car__c>();
        List<Route__c> routeList = new List<Route__c>();
        List<Shuttle_Stop__c> shuttleStopList = new List<Shuttle_Stop__c>();
        
        Employee__c driver = [Select Id, Name from Employee__c Where is_Driver__c = true limit 1];
        
        Company_Car__c cc1 = new Company_Car__c (
            Name = 'TAL 328',
            Driver__c =  driver.Id,            
            Manufacturer__c = 'Test Manufacturer',
            Model__c = 'Test Model',
            Number_of_Seats__c = 2,
            Travel_Policy__c = this.travelPolicyId            
        );
        companyCarList.add(cc1);
        insert companyCarList;
        
        Route__c r1 = new Route__c (
            Name = 'HKO -> TAA @ 07:20',
            Departure_Hour__c = '07',
            Departure_Minute__c = '20',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('HKO').id,
            To__c = SiteMap.get('TGA').id
            
        );
        routeList.add(r1);
        
        Route__c r2 = new Route__c (
            Name = 'HKO -> TAA @ 08:00',
            Departure_Hour__c = '08',
            Departure_Minute__c = '00',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('HKO').id,
            To__c = SiteMap.get('TGA').id
            
        );
        routeList.add(r2);
        
        Route__c r3 = new Route__c (
            Name = 'HKO -> TAA @ 09:00 (For Guest)',
            Departure_Hour__c = '09',
            Departure_Minute__c = '00',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('HKO').id,
            To__c = SiteMap.get('TGA').id
            
        );
        routeList.add(r3);
        
        Route__c r4 = new Route__c (
            Name = 'TAA -> HKO @ 18:15',
            Departure_Hour__c = '18',
            Departure_Minute__c = '15',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('TGA').id,
            To__c = SiteMap.get('HKO').id
            
        );
        routeList.add(r4);
        
        Route__c r5 = new Route__c (
            Name = 'HKO -> TAA @ 06:30',
            Departure_Hour__c = '06',
            Departure_Minute__c = '30',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('HKO').id,
            To__c = SiteMap.get('TGA').id
            
        );
        routeList.add(r5);
        
        Route__c r6 = new Route__c (
            Name = 'HKO -> TAA @ 06:45 (For Guest)',
            Departure_Hour__c = '06',
            Departure_Minute__c = '45',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('HKO').id,
            To__c = SiteMap.get('TGA').id
            
        );
        routeList.add(r6);
        
        Route__c r7 = new Route__c (
            Name = 'TAA -> HKO @ 18:15 (For Guest)',
            Departure_Hour__c = '18',
            Departure_Minute__c = '15',
            Friday__c = true,
            Saturday__c = true,
            Sunday__c = true,
            Thursday__c = true,
            Monday__c = true,
            Tuesday__c = true,
            Wednesday__c = true,
            For_Guest__c = false,
            From__c = SiteMap.get('TGA').id,
            To__c = SiteMap.get('HKO').id
            
        );
        routeList.add(r7);
        insert routeList;
        
        /**
         * init Route Key: [HKO -> TAA @ 07:20, HKO -> TAA @ 08:00, HKO -> TAA @ 09:00 (For Guest), 
                            TAA -> HKO @ 18:15, HKO -> TAA @ 06:30, HKO -> TAA @ 06:45 (For Guest),
                            TAA -> HKO @ 18:15 (For Guest)]
         */
        for(Route__c reader : [
                SELECT id, Default_Car__c, 
                Departure_Hour__c, Departure_Minute__c, Departure_Time_12H_Format__c, Departure_Time__c, 
                Friday__c, Saturday__c, Sunday__c, Thursday__c, Monday__c, Tuesday__c, Wednesday__c,
                For_Guest__c,  Name,
                To__c, From__c
                FROM Route__c
                where id in :routeList
        ]){
            RouteMap.put(reader.Name, reader);
        }
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '06',
                Arrival_Minute__c = '30',
                Location__c = 'ToKwaWan',
                Route__c = RouteMap.get('HKO -> TAA @ 06:30').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '06',
                Arrival_Minute__c = '45',
                Location__c = 'Kowloon Tong',
                Route__c = RouteMap.get('HKO -> TAA @ 06:30').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '07',
                Arrival_Minute__c = '00',
                Location__c = 'Shatin',
                Route__c = RouteMap.get('HKO -> TAA @ 06:30').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'PAL and then TAA',
                Route__c = RouteMap.get('HKO -> TAA @ 06:30').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '06',
                Arrival_Minute__c = '45',
                Location__c = 'TAL Building',
                Route__c = RouteMap.get('HKO -> TAA @ 06:45 (For Guest)').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '18',
                Arrival_Minute__c = '45',
                Location__c = 'PAL',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15 (For Guest)').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '07',
                Arrival_Minute__c = '20',
                Location__c = 'Shenzheng',
                Route__c = RouteMap.get('HKO -> TAA @ 07:20').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'PAL and then TAA',
                Route__c = RouteMap.get('HKO -> TAA @ 07:20').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '08',
                Arrival_Minute__c = '00',
                Location__c = 'Shenzheng',
                Route__c = RouteMap.get('HKO -> TAA @ 08:00').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'PAL and then TAA',
                Route__c = RouteMap.get('HKO -> TAA @ 08:00').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'PAL and then TAA',
                Route__c = RouteMap.get('HKO -> TAA @ 06:45 (For Guest)').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '18',
                Arrival_Minute__c = '15',
                Location__c = 'TAA',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15 (For Guest)').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'TAL Building',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15 (For Guest)').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '09',
                Arrival_Minute__c = '00',
                Location__c = 'Shenzheng',
                Route__c = RouteMap.get('HKO -> TAA @ 09:00 (For Guest)').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'TAA/PAL',
                Route__c = RouteMap.get('HKO -> TAA @ 09:00 (For Guest)').id,
                Stop_Type__c = 'D'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '18',
                Arrival_Minute__c = '15',
                Location__c = 'TAA',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '18',
                Arrival_Minute__c = '45',
                Location__c = 'PAL',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15').id,
                Stop_Type__c = 'P'
        ));
        
        shuttleStopList.add( new Shuttle_Stop__c(
                Arrival_Hour__c = '',
                Arrival_Minute__c = '',
                Location__c = 'Shengzhen',
                Route__c = RouteMap.get('TAA -> HKO @ 18:15').id,
                Stop_Type__c = 'D'
        ));
        
        insert shuttleStopList;
        shuttleStopMap = new Map<String, Shuttle_Stop__c>([select id, Arrival_Hour__c, Arrival_Minute__c, Arrival_Time__c,
                                                           Location__c, Route__c, Stop_Type__c, Name
                                                           from Shuttle_Stop__c
                                                          ]);
    }
}