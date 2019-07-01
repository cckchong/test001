//Created: 
//Author: Deloitte
//Revisions: TAL (Twinkle Li) @20170703 - Rretrieve master setup values from Lead Time Mode 
//           ...

public without sharing class SLTSampleTriggerHandler {
    
    private static string REPLACE_KEYWORD_NON_NUMERIC = '[^0-9]';
    
    public static void updateTechSiteName(List<Sample__c> newSampleList) {
    
        Set<String> siteIdSet = new Set<String> ();
        Map<String, Site__c> siteMap = new Map<String, Site__c> ();
        for(Sample__c reader : newSampleList) {
            if(!String.isBlank(reader.Site__c)) {
                siteIdSet.add(reader.Site__c);
            }
        }    
        
        if(!siteIdSet.isEmpty()) {
            for(Site__c reader: [SELECT Id, Name from Site__c WHERE Id in :siteIdSet]) {
                siteMap.put(reader.Id, reader);
            }
        }
        if(!siteMap.isEmpty()) {
            for(Sample__c reader : newSampleList) {
                if(!String.isBlank(reader.Site__c)) {
                    if(siteMap.containsKey(reader.Site__c)) {
                        reader.Tech_Site_Name__c = siteMap.get(reader.Site__c).Name;
                    }
                }
            }                
        }        
        
    }
    public static void getFactoryHoliday(List <Sample__c>  newSampleList){
  
        Map<String, List<Holiday__c>> siteNameHolidayListMap = new Map<String, List<Holiday__c>> ();
        Map<String, List<Time_Set__c>> siteNameTimeSetListMap = new Map<String, List<Time_Set__c>> ();

        List<String> siteNameList = new List<String> ();
        List<Holiday__c> tempHolidayList = new List<Holiday__c> ();
        List<Time_Set__c> tempTimeSetList = new List<Time_Set__c> ();
        
        Double holidayCountCRSToFTTC = 0;
        Double holidayCountFSCToFYOP = 0;
        Double holidayCountFTCToSMS = 0;
        Double holidayCountFTTCToFSC = 0;
        Double holidayCountFYOPToFYR = 0;
        Double holidayCountFYRToFTC = 0;
        Double holidayCountSMSToSEF = 0;
        
        String tempTimeSetName = '';
        Integer tempTimeSetNumber = 100;
        Time_Set__c targetTimeSet = null;

       
        for(Sample__c reader : newSampleList) {
            //if(reader.Factory__c != null) {
            if(!String.isBlank(reader.Tech_Site_Name__c)) {
                siteNameList.add(reader.Tech_Site_Name__c);
            }
        }
                        
        if(!siteNameList.isEmpty()) {
            for(Leave_Policy__c leaveReader : [SELECT Id, Name, (SELECT Id, Date__c, Cost__c,Leave_Policy__c, Leave_Policy__r.Name FROM Holidays__r),
                                            (SELECT Id, Name, Leave_Policy__c, Leave_Policy__r.Name,
                                                    Is_Fri_Available__c, Is_Mon_Available__c, Is_Sat_Available__c,
                                                    Is_Sun_Available__c, Is_Thu_Available__c, Is_Tue_Available__c,
                                                    Is_Wed_Available__c
                                             FROM Timesets__r)
                                           FROM Leave_Policy__c WHERE Name in: siteNameList]) {
                                      
                //get all the holidays of all leave policy
                for(Holiday__c holidayReader: leaveReader.Holidays__r) {
                

                    if(!siteNameHolidayListMap.containsKey(holidayReader.Leave_Policy__r.Name)){
                        tempHolidayList = new List<Holiday__c> ();
                    }
                    else {
                        tempHolidayList = siteNameHolidayListMap.get(holidayReader.Leave_Policy__r.Name);
                    }
                    
                    tempHolidayList.add(holidayReader);
                    siteNameHolidayListMap.put(holidayReader.Leave_Policy__r.Name, tempHolidayList);
                }
                
                //get all the timesets of all leave policy
                for(Time_Set__c timeSetReader: leaveReader.Timesets__r) {
                

                    if(!siteNameTimeSetListMap.containsKey(timeSetReader.Leave_Policy__r.Name)){
                        tempTimeSetList = new List<Time_Set__c> ();
                    }
                    else {
                        tempTimeSetList = siteNameTimeSetListMap.get(timeSetReader.Leave_Policy__r.Name);
                    }
                    
                    tempTimeSetList.add(timeSetReader);
                    siteNameTimeSetListMap.put(timeSetReader.Leave_Policy__r.Name, tempTimeSetList );
                }                
            }
            
        }
                   
        for(Sample__c sampleReader : newSampleList) {
        
            holidayCountCRSToFTTC = 0;
            holidayCountFSCToFYOP = 0;
            holidayCountFTCToSMS = 0;
            holidayCountFTTCToFSC = 0;
            holidayCountFYOPToFYR = 0;
            holidayCountFYRToFTC = 0;
            holidayCountSMSToSEF = 0;            
            
            tempTimeSetNumber = 100;
            targetTimeSet = null;
            
            //if(sampleReader.Factory__c != null) {
            //    if(siteNameHolidayListMap.containsKey(sampleReader.Factory__c)) {
            
            if(!String.isBlank(sampleReader.Tech_Site_Name__c)) {
                if(siteNameHolidayListMap.containsKey(sampleReader.Tech_Site_Name__c)) {
                    //get the number of holiday between different dates
                    //for(Holiday__c holidayReader: siteNameHolidayListMap.get(sampleReader.Factory__c)) {
                    for(Holiday__c holidayReader: siteNameHolidayListMap.get(sampleReader.Tech_Site_Name__c)) {
                        
                        //Count number holiday of Customer_Request_Sample_Date__c  and Fabric_Trim_Type_Confirm_Date__c
                        if(sampleReader.Customer_Request_Sample_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Fabric_Trim_Type_Confirm_Date__c) {
                            holidayCountCRSToFTTC= holidayCountCRSToFTTC + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Fabric_Supplier_Confirm_Date__c and Fabric_Yardage_Order_Placement_Date__c

                        if(sampleReader.Fabric_Supplier_Confirm_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Fabric_Yardage_Order_Placement_Date__c) {
                            holidayCountFSCToFYOP = holidayCountFSCToFYOP + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Fabric_Test_Completion_Date__c and Sample_Making_Start_Date__c
                        if(sampleReader.Fabric_Test_Completion_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Sample_Making_Start_Date__c) {
                            holidayCountFTCToSMS = holidayCountFTCToSMS + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Fabric_Trim_Type_Confirm_Date__c and Fabric_Supplier_Confirm_Date__c
                        if(sampleReader.Fabric_Trim_Type_Confirm_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Fabric_Supplier_Confirm_Date__c) {
                            holidayCountFTTCToFSC = holidayCountFTTCToFSC + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Fabric_Yardage_Order_Placement_Date__c and Fabric_Yardage_Receive_Date__c
                        if(sampleReader.Fabric_Yardage_Order_Placement_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Fabric_Yardage_Receive_Date__c) {
                            holidayCountFYOPToFYR = holidayCountFYOPToFYR + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Fabric_Yardage_Receive_Date__c and Fabric_Test_Completion_Date__c
                        if(sampleReader.Fabric_Yardage_Receive_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Fabric_Test_Completion_Date__c) {
                            holidayCountFYRToFTC = holidayCountFYRToFTC + holidayReader.Cost__c;
                        }
                        
                        //Count number holiday of Sample_Making_Start_Date__c and Sample_Ex_factory_Date__c
                        if(sampleReader.Sample_Making_Start_Date__c < holidayReader.Date__c &&
                            holidayReader.Date__c <= sampleReader.Sample_Ex_factory_Date__c) {
                            holidayCountSMSToSEF = holidayCountSMSToSEF + holidayReader.Cost__c;
                        }
                    }
                    
                    sampleReader.Holiday_Count_CRS_FTTC__c = holidayCountCRSToFTTC;
                    sampleReader.Holiday_Count_FSC_FYOP__c = holidayCountFSCToFYOP;
                    sampleReader.Holiday_Count_FTC_SMS__c = holidayCountFTCToSMS;
                    sampleReader.Holiday_Count_FTTC_FSC__c = holidayCountFTTCToFSC;
                    sampleReader.Holiday_Count_FYOP_FYR__c = holidayCountFYOPToFYR;
                    sampleReader.Holiday_Count_FYR_FTC__c = holidayCountFYRToFTC;
                    sampleReader.Holiday_Count_SMS_SEF__c = holidayCountSMSToSEF;
                    
                }
                
                //if(siteNameTimeSetListMap.containsKey(sampleReader.Factory__c)) {
                if(siteNameTimeSetListMap.containsKey(sampleReader.Tech_Site_Name__c)) {
                
                    //get the number of working days in a week
                    //use the first time set in each leave policy
                    //for(Time_Set__c timeSetReader : siteNameTimeSetListMap.get(sampleReader.Factory__c)) {
                    for(Time_Set__c timeSetReader : siteNameTimeSetListMap.get(sampleReader.Tech_Site_Name__c)) {

                        tempTimeSetName = timeSetReader.Name; 
                        tempTimeSetName = tempTimeSetName.right(2);
                        tempTimeSetName = tempTimeSetName.replaceAll(REPLACE_KEYWORD_NON_NUMERIC , '');
                        if(!String.isBlank(tempTimeSetName)) {
                            if(tempTimeSetNumber > Integer.valueOf(tempTimeSetName)){
                                tempTimeSetNumber = Integer.valueOf(tempTimeSetName);
                                targetTimeSet = timeSetReader;
                            }
                        }

                        
                    }
                    
                    if(targetTimeSet != null) {
                        sampleReader.Tech_TimeSetId__c = targetTimeSet.Id;
                        sampleReader.Is_Mon_Available__c = targetTimeSet.Is_Mon_Available__c;
                        sampleReader.Is_Tue_Available__c = targetTimeSet.Is_Tue_Available__c;
                        sampleReader.Is_Wed_Available__c = targetTimeSet.Is_Wed_Available__c;
                        sampleReader.Is_Thu_Available__c = targetTimeSet.Is_Thu_Available__c;
                        sampleReader.Is_Fri_Available__c = targetTimeSet.Is_Fri_Available__c;
                        sampleReader.Is_Sat_Available__c = targetTimeSet.Is_Sat_Available__c;
                        sampleReader.Is_Sun_Available__c = targetTimeSet.Is_Sun_Available__c;
                    }
                }
                
            }
        }        
    }
    
    //Added by TAL (Twinkle Li) @20170703 
    public static void retrieveLeadTimeMode(List<Sample__c> newSampleList){
        Map<String, String> mapLeadTimeMode = new Map<String, String>();
        
        for(Lead_Time_Mode__c ltm : [SELECT Id, Name, Lead_Time_Code__c, Mode__c FROM Lead_Time_Mode__c WHERE RecordType.DeveloperName = 'Lead_Time_Mode']){
            mapLeadTimeMode.put(ltm.Lead_Time_Code__c, ltm.Mode__c);
        }
        
        for(Sample__c reader : newSampleList){
            reader.Lead_Time_Mode_CRS_FTTC__c = mapLeadTimeMode.get('CRS-FTTS');
            reader.Lead_Time_Mode_FSC_FYOP__c = mapLeadTimeMode.get('FSC-FYOP');
            reader.Lead_Time_Mode_FTC_SMS__c = mapLeadTimeMode.get('FTC-SMS');
            reader.Lead_Time_Mode_FTTC_FSC__c = mapLeadTimeMode.get('FTTC-FSC');
            reader.Lead_Time_Mode_FYOP_FYR__c = mapLeadTimeMode.get('FYOP-FYR');
            reader.Lead_Time_Mode_FYR_FTC__c = mapLeadTimeMode.get('FYR-FTC');
            reader.Lead_Time_Mode_SMS_SEF__c = mapLeadTimeMode.get('SMS-SEF');
        }
    }
    
    //Added by TAL (Twinkle Li) @20170818
    public static void retrieveStandardLeadTime(List<Sample__c> newSampleList){
        Map<String, Lead_Time__c> mapStandardLeadTime = new Map<String, Lead_Time__c>();
        
        //mapping of Standard Lead Time, by Product + Fabric Supplier Code (if 'Lu Feng') + Fabric Acquire Method + Yarn Greige Availability
        for(Lead_Time__c slt : [SELECT Id, Name, Product__c, Fabric_Supplier_Code__c, Fabric_Acquire_Method__c, Yarn_Greige_Availability__c FROM Lead_Time__c WHERE RecordType.DeveloperName = 'Lead_Time']){
            if(!String.isEmpty(slt.Fabric_Supplier_Code__c) && slt.Fabric_Supplier_Code__c.replace(' ','').toLowerCase() == 'lufeng')
                mapStandardLeadTime.put(slt.Product__c.replace(' ','').toLowerCase()+slt.Fabric_Supplier_Code__c.replace(' ','').toLowerCase()+slt.Fabric_Acquire_Method__c+slt.Yarn_Greige_Availability__c, slt);
            else
                mapStandardLeadTime.put(slt.Product__c.replace(' ','').toLowerCase()+slt.Fabric_Acquire_Method__c+slt.Yarn_Greige_Availability__c, slt);
        }
        
        for(Sample__c reader : newSampleList){
            String strSamplekey = '';
            
            if(!String.isEmpty(reader.Fabric_Supplier_Code__c) && reader.Fabric_Supplier_Code__c.replace(' ','').toLowerCase() == 'lufeng'){
                if(!String.isEmpty(reader.Product__c))
                    strSamplekey = reader.Product__c.replace(' ','').toLowerCase()+reader.Fabric_Supplier_Code__c.replace(' ','').toLowerCase()+reader.Fabric_Acquire_Method__c+reader.Yarn_Greige_Availability__c;

                if(mapStandardLeadTime.containsKey(strSamplekey))
                    reader.Standard_Lead_Time__c = mapStandardLeadTime.get(strSamplekey).id;
                else{
                    if(!String.isEmpty(reader.Product__c))
                        strSamplekey = reader.Product__c.replace(' ','').toLowerCase()+reader.Fabric_Acquire_Method__c+reader.Yarn_Greige_Availability__c;
                    
                    if(mapStandardLeadTime.containsKey(strSamplekey))
                        reader.Standard_Lead_Time__c = mapStandardLeadTime.get(strSamplekey).id;
                    else
                        reader.Standard_Lead_Time__c = null;
                }
            }
            else{
                if(!String.isEmpty(reader.Product__c))
                    strSamplekey = reader.Product__c.replace(' ','').toLowerCase()+reader.Fabric_Acquire_Method__c+reader.Yarn_Greige_Availability__c;
                
                if(mapStandardLeadTime.containsKey(strSamplekey))
                    reader.Standard_Lead_Time__c = mapStandardLeadTime.get(strSamplekey).id;
                else
                    reader.Standard_Lead_Time__c = null;
            }
            
            /*if(mapStandardLeadTime.containsKey(strSamplekey)){
                reader.Standard_Lead_Time__c = mapStandardLeadTime.get(strSamplekey).id;
            }
            else{
                reader.Standard_Lead_Time__c = null;
            }*/
            
            system.debug('key: '+strSamplekey);
        }
    }
}