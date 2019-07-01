public without sharing class TETravelPriceErrorCtrl {
    //testing purpose
    private ApexPages.StandardController standardController;

    public TETravelPriceErrorCtrl (ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }

    public static void processErrorTravelPrices(){
        List<Travel_Price__c> travelPriceToUpdateList = new List<Travel_Price__c>();
        
        For (Travel_Price__c tp : [Select Id, Is_Error__c, Error_Message__c From Travel_Price__c Where Is_Error__c = :True]){
            tp.Is_Error__c = False;
            tp.Error_Message__c = '';
            travelPriceToUpdateList.add(tp);
        }
        
        if(!travelPriceToUpdateList.isEmpty()){
            upsert travelPriceToUpdateList;
        }
    }
}