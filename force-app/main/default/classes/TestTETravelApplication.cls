@isTest
public  class TestTETravelApplication extends TestTEPreparation {

    public TestTETravelApplication ( Boolean isSeeAllData ){
        super(isSeeAllData);
        Preparation(isSeeAllData);
    }
    
    
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

}