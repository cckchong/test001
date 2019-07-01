@istest
public class TestTECarbonEmissionPreparation{

    public Map<String, Flight_Type__c> FlightTypeMap {get;set;}
    public Map<String, Cabin_Class__c> CabinClassMap {get;set;}
    public Map<String, Travel_Location__c> TravelLocationMap {get;set;}
    public Map<String, Travel_Distance__c> TravelDistanceMap {get;set;}
    public Map<String, GHG_Factor__c> GHGFactorMap {get;set;}
    public Map<String, carbon_Emission__c> carbonEmissionMap {get;set;}
    public Map<String, Airport__c> AirportMap {get;set;}
    
    public Boolean isSeeAllData;
    
    public TestTECarbonEmissionPreparation(Boolean isSeeAllData) {
        this.isSeeAllData = isSeeAllData;
        FlightTypeMap = new Map<String, Flight_Type__c>();
        CabinClassMap = new Map<String, Cabin_Class__c>();
        TravelLocationMap = new Map<String, Travel_Location__c>();
        TravelDistanceMap = new Map<String, Travel_Distance__c>();
        GHGFactorMap = new Map<String, GHG_Factor__c>();
        carbonEmissionMap = new Map<String, carbon_Emission__c>();
        AirportMap = new Map<String, Airport__c>();
    }
    
    public void BasicSetting() {

        /**
         * init flight type. Key: [D, S, L]
         */
        List<Flight_Type__c> flightTypeList = new List<Flight_Type__c>();
        Flight_Type__c ft1 = new Flight_Type__c(
            Name = 'Domestic',
            Short_Name__c = 'D',
            Min_Range__c = 0,
            Max_Range__c = 786
        );
        flightTypeList.add(ft1);
        Flight_Type__c ft2 = new Flight_Type__c(
            Name = 'Long-haul international',
            Short_Name__c = 'L',
            Min_Range__c = 3700,
            Max_Range__c = 99999999
        );
        flightTypeList.add(ft2);
        Flight_Type__c ft3 = new Flight_Type__c(
            Name = 'Short-haul international',
            Short_Name__c = 'S',
            Min_Range__c = 786,
            Max_Range__c = 3700
        );
        flightTypeList.add(ft3);
        insert flightTypeList;
        List<ID> flightTypeIDList = new List<ID>();
        for (Flight_Type__c ft : flightTypeList) {
            flightTypeIDList.add(ft.Id);
        }
        for (Flight_Type__c ft : [select Id, Name, Short_Name__c, Min_Range__c, Max_Range__c from Flight_Type__c where Id IN :flightTypeIDList]) {
            FlightTypeMap.put(ft.Short_Name__c, ft);
        }
        
        /**
         * init flight class. Key: [AVERAGE, BUSINESSCLASS, FIRSTCLASS, ECONOMYCLASS, PREMIUMECONOMYCLASS]
         */
        List<Cabin_Class__c> cabinClassList = new List<Cabin_Class__c>();
        Cabin_Class__c cc1 = new Cabin_Class__c(
            Name = 'Average',
            Cabin_Class_Full_Name__c = 'Average'
        );
        cabinClassList.add(cc1);
        Cabin_Class__c cc2 = new Cabin_Class__c(
            Name = 'Business Class',
            Cabin_Class_Full_Name__c = 'Business Class'
        );
        cabinClassList.add(cc2);
        Cabin_Class__c cc3 = new Cabin_Class__c(
            Name = 'First Class',
            Cabin_Class_Full_Name__c = 'First Class;First/Global first'
        );
        cabinClassList.add(cc3);
        Cabin_Class__c cc4 = new Cabin_Class__c(
            Name = 'Economy Class',
            Cabin_Class_Full_Name__c = 'Economy Class'
        );
        cabinClassList.add(cc4);
        Cabin_Class__c cc5 = new Cabin_Class__c(
            Name = 'Premium Economy Class',
            Cabin_Class_Full_Name__c = 'Preminum Economy Class'
        );
        cabinClassList.add(cc5);
        insert cabinClassList;
        List<ID> cabinClassIDList = new List<ID>();
        for (Cabin_Class__c cc : cabinClassList) {
            cabinClassIDList.add(cc.Id);
        }
        for (Cabin_Class__c cc : [select Id, Name, Cabin_Class_Full_Name__c, Tech_Keyword__c from Cabin_Class__c where Id IN :cabinClassIDList]) {
            CabinClassMap.put(cc.Tech_Keyword__c, cc);
        }
        
        /**
         * init GHG factor. Key: [LECONOMYCLASS, SECONOMYCLASS, LBUSINESSCLASS, SBUSINESSCLASS]
         */
        List<GHG_Factor__c> ghgFactorList = new List<GHG_Factor__c>();
        GHG_Factor__c gf1 = new GHG_Factor__c(
            Name = 'System generated',
            Cabin_Class__c = CabinClassMap.get('ECONOMYCLASS').Id,
            Flight_Type__c = FlightTypeMap.get('L').Id,
            Emission_Factor__c = 0.08345
        );
        ghgFactorList.add(gf1);
        GHG_Factor__c gf2 = new GHG_Factor__c(
            Name = 'System generated',
            Cabin_Class__c = CabinClassMap.get('ECONOMYCLASS').Id,
            Flight_Type__c = FlightTypeMap.get('S').Id,
            Emission_Factor__c = 0.09336
        );
        ghgFactorList.add(gf2);
        
        GHG_Factor__c gf3 = new GHG_Factor__c(
            Name = 'System generated',
            Cabin_Class__c = CabinClassMap.get('BUSINESSCLASS').Id,
            Flight_Type__c = FlightTypeMap.get('L').Id,
            Emission_Factor__c = 0.08345
        );
        ghgFactorList.add(gf3);
        GHG_Factor__c gf4 = new GHG_Factor__c(
            Name = 'System generated',
            Cabin_Class__c = CabinClassMap.get('BUSINESSCLASS').Id,
            Flight_Type__c = FlightTypeMap.get('S').Id,
            Emission_Factor__c = 0.09336
        );
        ghgFactorList.add(gf4);
        
        insert ghgFactorList;
        List<ID> ghgFactorIDList = new List<ID>();
        for (GHG_Factor__c gf : ghgFactorList) {
            ghgFactorIDList.add(gf.Id);
        }
        for (GHG_Factor__c gf : [select Id, Name, Flight_Type__c, Cabin_Class__c, Tech_Flight_Type_Cabin_Class__c, Emission_Factor__c, Emission_Factor_2__c, Emission_Factor_3__c, RecordTypeId 
            from GHG_Factor__c where Id IN :ghgFactorIDList]) {
            GHGFactorMap.put(gf.Tech_Flight_Type_Cabin_Class__c, gf);
        } 
        
        /**
         * init travel location. Key: [HONGKONG, LOSANGELES, DALLASFTWORTH, SANFRANCISCO, VANCOUVER, DONGGUAN]
         */
        List<Travel_Location__c> travelLocationList = new List<Travel_Location__c>();
        Travel_Location__c tl1 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'CHINA',
            City__c = 'HONG KONG',
            City_Code__c = 'HKG'
        );
        travelLocationList.add(tl1);
        Travel_Location__c tl2 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'USA',
            City__c = 'LOS ANGELES',
            City_Code__c = 'LAX'
        );
        travelLocationList.add(tl2);
        Travel_Location__c tl3 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'USA',
            City__c = 'DALLAS FT WORTH',
            City_Code__c = 'DFW'
        );
        travelLocationList.add(tl3);
        Travel_Location__c tl4 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'USA',
            City__c = 'SAN FRANCISCO',
            City_Code__c = 'SFO'
        );
        travelLocationList.add(tl4);
        Travel_Location__c tl5 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'CANADA',
            City__c = 'VANCOUVER',
            City_Code__c = 'YVR'
        );
        travelLocationList.add(tl5);
        Travel_Location__c tl6 = new Travel_Location__c(
            Name = 'System generated',
            Country__c = 'CHINA',
            City__c = 'DONGGUAN'
        );
        travelLocationList.add(tl6);
        insert travelLocationList;
        List<ID> travelLocationIDList = new List<ID>();
        for (Travel_Location__c tl : travelLocationList) {
            travelLocationIDList.add(tl.Id);
        }
        for (Travel_Location__c tl : [select Id, Name, Country__c, City__c, City_Code__c, Tech_City_String__c from Travel_Location__c where Id IN :travelLocationIDList]) {
            TravelLocationMap.put(tl.Tech_City_String__c, tl);
        }
        
        /**
         * init airport Key: [HONGKONG, LOSANGELES, DALLASFTWORTH, SANFRANCISCO, VANCOVER]
         */
        List<Airport__c> airportList = new List<Airport__c>();
        airportList.add(new Airport__c(Name = 'HONG KONG',  Travel_Location__c = TravelLocationMap.get('HONGKONG').id));
        airportList.add(new Airport__c(Name = 'LOS ANGELES',  Travel_Location__c = TravelLocationMap.get('LOSANGELES').id));
        airportList.add(new Airport__c(Name = 'DALLAS FT WORTH',  Travel_Location__c = TravelLocationMap.get('DALLASFTWORTH').id));
        airportList.add(new Airport__c(Name = 'SAN FRANCISCO',  Travel_Location__c = TravelLocationMap.get('SANFRANCISCO').id));
        airportList.add(new Airport__c(Name = 'VANCOUVER',  Travel_Location__c = TravelLocationMap.get('VANCOUVER').id));
        insert airportList;
        for (Airport__c reader : [select Id, Name, Airport_Code__c, Airport_ExtID__c, Is_Primary__c, Tech_Airport_Name__c, Travel_Location__c from AirPort__c where id in :airportList]) {
            AirportMap.put(reader.Tech_Airport_Name__c, reader);
        } 
        /**
         * init travel distance. Key: [HONGKONGLOSANGELES, LOSANGELESDALLASFTWORTH, DALLASFTWORTHSANFRANCISCO, SANFRANCISCOHONGKONG, VANCOUVERHONGKONG, HONGKONGVANCOUVER]
         */
        List<Travel_Distance__c> travelDistanceList = new List<Travel_Distance__c>();
        Travel_Distance__c td1 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('HONGKONG').Id,
            To_Airport__c = AirportMap.get('LOSANGELES').Id,
            Distance__c = 11708
        );
        travelDistanceList.add(td1);
        Travel_Distance__c td2 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('LOSANGELES').Id,
            To_Airport__c = AirportMap.get('DALLASFTWORTH').Id,
            Distance__c = 2053
        );
        travelDistanceList.add(td2);
        Travel_Distance__c td3 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('DALLASFTWORTH').Id,
            To_Airport__c = AirportMap.get('SANFRANCISCO').Id,
            Distance__c = 2424
        );
        travelDistanceList.add(td3);
        Travel_Distance__c td4 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('SANFRANCISCO').Id,
            To_Airport__c = AirportMap.get('HONGKONG').Id,
            Distance__c = 11170
        );
        travelDistanceList.add(td4);
        Travel_Distance__c td5 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('VANCOUVER').Id,
            To_Airport__c = AirportMap.get('HONGKONG').Id,
            Distance__c = 10278
        );
        travelDistanceList.add(td5);
        Travel_Distance__c td6 = new Travel_Distance__c(
            Name = 'System generated',
            From_Airport__c = AirportMap.get('HONGKONG').Id,
            To_Airport__c = AirportMap.get('VANCOUVER').Id,
            Distance__c = 10278
        );
        travelDistanceList.add(td6);
        insert travelDistanceList;
        List<ID> travelDistanceIDList = new List<ID>();
        for (Travel_Distance__c td : travelDistanceList) {
            travelDistanceIDList.add(td.Id);
        }
        for (Travel_Distance__c td : [select Id, Name, From_Airport__c , To_Airport__c, Distance__c, Flight_Type__c, Tech_From_To__c from Travel_Distance__c where Id IN :travelDistanceIDList]) {
            TravelDistanceMap.put(td.Tech_From_To__c, td);
        }
        
        
        
        
        
        /**
         * init GHG factor. Key: [HONGKONGLOSANGELESSECONOMYCLASS, HONGKONGLOSANGELESLECONOMYCLASS,
                                  LOSANGELESDALLASFTWORTHSECONOMYCLASS, LOSANGELESDALLASFTWORTH,
                                  DALLASFTWORTHSANFRANCISCOSECONOMYCLASS,DALLASFTWORTHSANFRANCISCO,
                                  SANFRANCISCOHONGKONGSECONOMYCLASS,SANFRANCISCOHONGKONGLECONOMYCLASS,
                                  VANCOUVERHONGKONGSECONOMYCLASS,VANCOUVERHONGKONGLECONOMYCLASS,
                                  HONGKONGVANCOUVERSECONOMYCLASS,HONGKONGVANCOUVERLECONOMYCLASS]
         */
        List<Carbon_Emission__c> carbonEmissionList = new List<Carbon_Emission__c>();
        Carbon_Emission__c ce1 = new Carbon_Emission__c(
            Name = 'System generated',
            GHG_Factor__c = GHGFactorMap.get('LECONOMYCLASS').Id,
            Travel_Distance__c= TravelDistanceMap.get('HONGKONGLOSANGELES').Id
        );
        carbonEmissionList.add(ce1);

        Carbon_Emission__c ce2= new Carbon_Emission__c(
            Name = 'System generated',
            GHG_Factor__c = GHGFactorMap.get('SECONOMYCLASS').Id,
            Travel_Distance__c= TravelDistanceMap.get('LOSANGELESDALLASFTWORTH').Id
        );
        carbonEmissionList.add(ce2);
       
        Carbon_Emission__c ce3= new Carbon_Emission__c(
            Name = 'System generated',
            GHG_Factor__c = GHGFactorMap.get('SECONOMYCLASS').Id,
            Travel_Distance__c= TravelDistanceMap.get('DALLASFTWORTHSANFRANCISCO').Id
        );
        carbonEmissionList.add(ce3);
        
        
        Carbon_Emission__c ce4 = new Carbon_Emission__c(
            Name = 'System generated',
            GHG_Factor__c = GHGFactorMap.get('LECONOMYCLASS').Id,
            Travel_Distance__c= TravelDistanceMap.get('SANFRANCISCOHONGKONG').Id
        );
        carbonEmissionList.add(ce4);    

        insert carbonEmissionList;
        List<ID> carbonEmissionIDList= new List<ID>();
        for (Carbon_Emission__c ce: carbonEmissionList) {
            carbonEmissionIDList.add(ce.Id);
        }
        for (Carbon_Emission__c ce: [SELECT Id, Name, RecordTypeId, Travel_Distance__c, GHG_Factor__c, GHG_Emission__c, Tech_Travel_Distance_GHG_Factor__c, GHG_Emission_2__c, GHG_Emission_3__c
                                     FROM Carbon_Emission__c
                                     where Id IN :carbonEmissionIDList]) {
            carbonEmissionMap.put(ce.Tech_Travel_Distance_GHG_Factor__c, ce);
        }
    }
}