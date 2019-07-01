@isTest
public  class TestSLTSampleTriggerHandler {
    
    Public Static Site__c hkoSite;
    Public static Leave_Policy__c hkoLeavePolicy;
    Public static Map<String,Time_Set__c> timeSetMap;
   
    @isTest
    public static void test() {
        Sample__c sample1 = null;
        String sample1Id = '';
        TimeSetMap = new Map<String, Time_Set__c> ();
        
        prepareData();
        
        Test.StartTest();

        sample1 = new Sample__c(
            Name = 'testSample',
            Site__c = hkoSite.Id,
            Tech_TimeSetId__c = ''
        );
        
        insert sample1;
        sample1Id = sample1.Id;
        
        //List<Sample__c> temp = new List<Sample__c> ();
        //temp.add(sample1);
        //SLTSampleTriggerHandler.updateTechSiteName(temp);
        
        for(Sample__c reader : [SELECT Id, Holiday_Count_FSC_FYOP__c, Holiday_Count_FTC_SMS__c, 
                            Holiday_Count_FTTC_FSC__c, Holiday_Count_FYOP_FYR__c, 
                            Holiday_Count_FYR_FTC__c, Holiday_Count_SMS_SEF__c, 
                            Is_Mon_Available__c, Is_Tue_Available__c, 
                            Is_Wed_Available__c, Is_Thu_Available__c, 
                            Is_Fri_Available__c, Is_Sat_Available__c, 
                            Is_Sun_Available__c,Tech_TimeSetId__c, Tech_Site_Name__c
                    FROM Sample__c]) {
            sample1 = reader;
       
        }

        //system.assertEquals(sample1.Tech_TimeSetId__c ,string.valueOf(timeSetMap));
        
        //system.assertEquals(null,sample1); 
        system.assertEquals(true,sample1.Is_Mon_Available__c);
        system.assertEquals(true,sample1.Is_Tue_Available__c);
        system.assertEquals(true,sample1.Is_Wed_Available__c);
        system.assertEquals(true,sample1.Is_Thu_Available__c);
        system.assertEquals(true,sample1.Is_Fri_Available__c);
        system.assertEquals(false,sample1.Is_Sat_Available__c);
        system.assertEquals(false,sample1.Is_Sun_Available__c);


        Date day1 = Date.newInstance(2017, 1, 1);
        Date day2 = Date.newInstance(2017, 1, 5);
        Date day3 = Date.newInstance(2017, 1, 10);
        Date day4 = Date.newInstance(2017, 1, 15);
        Date day5 = Date.newInstance(2017, 1, 20);
        Date day6 = Date.newInstance(2017, 1, 25);
        Date day7 = Date.newInstance(2017, 1, 30);        
        Date day8 = Date.newInstance(2017, 2, 5);        

        sample1.Customer_Request_Sample_Date__c = day1;
        sample1.Fabric_Trim_Type_Confirm_Date__c = day2;
        sample1.Fabric_Supplier_Confirm_Date__c = day3;
        sample1.Fabric_Yardage_Order_Placement_Date__c = day4;
        sample1.Fabric_Yardage_Receive_Date__c = day5;
        sample1.Fabric_Test_Completion_Date__c = day6;
        sample1.Sample_Making_Start_Date__c = day7;
        sample1.Sample_Ex_factory_Date__c = day8;
        
        update Sample1;
        
        for(Sample__c reader : [SELECT Id, Holiday_Count_FSC_FYOP__c, Holiday_Count_FTC_SMS__c, 
                            Holiday_Count_FTTC_FSC__c, Holiday_Count_FYOP_FYR__c, 
                            Holiday_Count_FYR_FTC__c, Holiday_Count_SMS_SEF__c, 
                            Holiday_Count_CRS_FTTC__c, 
                            Is_Mon_Available__c, Is_Tue_Available__c, 
                            Is_Wed_Available__c, Is_Thu_Available__c, 
                            Is_Fri_Available__c, Is_Sat_Available__c, 
                            Is_Sun_Available__c,Tech_TimeSetId__c, Tech_Site_Name__c

                    FROM Sample__c]) {
            sample1 = reader;
       
        }

        system.assertEquals(1,sample1.Holiday_Count_CRS_FTTC__c);
        system.assertEquals(1,sample1.Holiday_Count_FTTC_FSC__c);
        system.assertEquals(1,sample1.Holiday_Count_FSC_FYOP__c);
        system.assertEquals(1,sample1.Holiday_Count_FYOP_FYR__c);
        system.assertEquals(1,sample1.Holiday_Count_FYR_FTC__c);
        system.assertEquals(1,sample1.Holiday_Count_FTC_SMS__c);
        system.assertEquals(1,sample1.Holiday_Count_SMS_SEF__c);
                
        Test.StopTest();

    }
    
    
    private static void prepareData() {
        prepareSite();
        prepareLeavePolicy();
        prepareTimeSet();
        prepareHoliday();
    }
    
    private static void prepareSite(){
        hkoSite = new Site__c(
            Name= 'HKO'
            
        );
        
        insert hkoSite;
    }
    private static void prepareLeavePolicy(){
        hkoLeavePolicy = new Leave_Policy__c (
            Leave_Soft_Doc_Require__c = true,
            Time_Zone_Offset__c = 8,
            Leave_Hard_Doc_Require__c = true,
            Period_Frequency__c = 'A',
            Name = 'HKO'
        );
        insert hkoLeavePolicy;    
    
    }
    
    private static void prepareHoliday() {
    
     Date testingHoliday1 = Date.newInstance(2017, 1, 3);
     Date testingHoliday2 = Date.newInstance(2017, 1, 7);
     Date testingHoliday3 = Date.newInstance(2017, 1, 13);
     Date testingHoliday4 = Date.newInstance(2017, 1, 17);
     Date testingHoliday5 = Date.newInstance(2017, 1, 23);
     Date testingHoliday6 = Date.newInstance(2017, 1, 27);
     Date testingHoliday7 = Date.newInstance(2017, 2, 3);
     //Date testingHoliday8 = Date.newInstance(2017, 2, 10);

     List<Holiday__c> holidayList = new List<Holiday__c> ();
     
        Holiday__c holiday1 = new Holiday__c(
            Name = 'Holiday Testing 1',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday1,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 1'
        );
        
        Holiday__c holiday2 = new Holiday__c(
            Name = 'Holiday Testing 2',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday2,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 2'
        );
        
        Holiday__c holiday3 = new Holiday__c(
            Name = 'Holiday Testing 3',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday3,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 3'
        );        
        
        Holiday__c holiday4 = new Holiday__c(
            Name = 'Holiday Testing 4',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday4,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 4'
        );       
        Holiday__c holiday5 = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday5,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 5'
        );        
        
        Holiday__c holiday6 = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday6,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 6'
        );        
        Holiday__c holiday7 = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday7,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 7'
        );
        /*       
        Holiday__c holiday8 = new Holiday__c(
            Name = 'Holiday Testing',
            Description__c = 'Holiday Testing',
            Date__c = testingHoliday8,
            Type__c = 'H', 
            Minute__c = null, 
            Hour__c = null, 
            Cost__c = 1, 
            Leave_Policy__c = hkoLeavePolicy.id,
            Holiday_External_ID__c = 'Holiday Testing 8'
        );     
        */             
        holidayList.add(holiday1);      
        holidayList.add(holiday2);               
        holidayList.add(holiday3);               
        holidayList.add(holiday4);               
        holidayList.add(holiday5);               
        holidayList.add(holiday6); 
        holidayList.add(holiday7);  
        //holidayList.add(holiday8);               
        insert holidayList;
    }    
    
    private static void prepareTimeSet() {

        List<Time_Set__c> toBeInsertedTimeSetList = new List<Time_Set__c> ();

        Time_Set__c TimeSet1 = new Time_Set__c (
            Time_Set_ID__c = 'HKO_TS1', 
            Name = 'HKO-1',
            Leave_Policy__c = hkoLeavePolicy.id,
            MonStartTime1__c = '09:00',
            MonEndTime1__c = '18:00',
            ThuStartTime1__c = '09:00',
            ThuEndTime1__c = '18:00',            
            WedStartTime1__c = '09:00',
            WedEndTime1__c = '18:00',
            TueStartTime1__c = '09:00',
            TueEndTime1__c = '18:00',
            FriStartTime1__c = '09:00',
            FriEndTime1__c = '18:00',
            SatStartTime1__c = null,
            SatEndTime1__c = null,
            SunStartTime1__c = null,
            SunEndTime1__c = null
        );

        Time_Set__c TimeSet2 = new Time_Set__c (
            Time_Set_ID__c = 'HKO_TS2', 
            Name = 'HKO-2',
            Leave_Policy__c = hkoLeavePolicy.id,
            MonStartTime1__c = '09:00',
            MonEndTime1__c = '18:00',
            ThuStartTime1__c = '09:00',
            ThuEndTime1__c = '18:00',            
            WedStartTime1__c = '09:00',
            WedEndTime1__c = '18:00',
            TueStartTime1__c = '09:00',
            TueEndTime1__c = '18:00',
            FriStartTime1__c = '09:00',
            FriEndTime1__c = '18:00',
            SatStartTime1__c = '09:00',
            SatEndTime1__c = '18:00',
            SunStartTime1__c = null,
            SunEndTime1__c = null
        );        
        
        toBeInsertedTimeSetList.add(TimeSet1);
        toBeInsertedTimeSetList.add(TimeSet2);
        
        insert toBeInsertedTimeSetList;        
        
        
        for ( Time_Set__c reader : 
            [
                 select id, Name , Leave_Policy__c , 
                 MonStartTime1__c, MonEndTime1__c, 
                 ThuStartTime1__c, ThuEndTime1__c, 
                 WedStartTime1__c, WedEndTime1__c,
                 TueStartTime1__c, TueEndTime1__c, 
                 FriStartTime1__c, FriEndTime1__c,
                 SatStartTime1__c, SatEndTime1__c, 
                 SunStartTime1__c, SunEndTime1__c,
                Is_Mon_Available__c, Is_Tue_Available__c, 
                Is_Wed_Available__c, Is_Thu_Available__c, 
                Is_Fri_Available__c, Is_Sat_Available__c, 
                Is_Sun_Available__c
                 from Time_Set__c 
        ]){
            TimeSetMap.put ( reader.name, reader );
        }        
    
    }
}