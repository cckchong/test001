@isTest
public  class TestSLTLeadTimeTriggerHandler {
    
    Public Static Lead_Time__c leadTime1;
    Public Static Sample__c sample1;
    @isTest
    public static void testUpdate() {
        
        prepareData();
        
        //leadTime1.Garment_Dye__c = true;
        
        
        try{
            update leadTime1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.SLT_Standard_Lead_Time_Not_Allow_To_Update_Delete_Message);
            System.AssertEquals(expectedExceptionThrown, true);
        }         
    }
    @isTest
    public static void testDelete() {
        
        prepareData();
        try{
            delete leadTime1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(Label.SLT_Standard_Lead_Time_Not_Allow_To_Update_Delete_Message);
            System.AssertEquals(expectedExceptionThrown, true);
        }   
    }   
    
    private static void prepareData() {
        leadTime1 = new Lead_Time__c (
            Name ='Lead Time 1'
        );
        
        insert leadTime1;
        
        sample1 = new Sample__c(
            name = 'Sample 1',
            Standard_Lead_Time__c = leadTime1.Id
        );
        
        insert sample1;
    
    }
    
}