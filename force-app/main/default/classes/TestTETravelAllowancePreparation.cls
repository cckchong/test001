@istest
public class TestTETravelAllowancePreparation{

    public Boolean isSeeAllData;
    
    public TestTETravelAllowancePreparation(Boolean isSeeAllData) {
        this.isSeeAllData = isSeeAllData;
       
    }
    
    public void basicSetting(Map<String, Expense_Policy__c> expensePolicyMap,  Map<String, Travel_Location__c> travelLocationMap){
        List<Travel_Location_Allowance__c> tlaList = new List<Travel_Location_Allowance__c>();
        for(Expense_Policy__c tpreader : expensePolicyMap.values()){
            for(Travel_Location__c tlreader : travelLocationMap.values()){
                tlaList.add(new Travel_Location_Allowance__c(
                                Daily_Maximum_Cost__c = 100,
                                Daily_Maximum_Hotel_Cost__c = 100,
                                Daily_Maximum_Meal__c = 100,
                                Expense_Policy__c = tpreader.id,
                                Travel_Location__c = tlreader.id
                           ));
            }
        }        
       upsert tlaList; 
    }
}