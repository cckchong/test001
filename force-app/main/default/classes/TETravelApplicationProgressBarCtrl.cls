/**
 * TETravelApplicationProgressBarCtrl
 * @author Kelvin Wong
 * @description show progress bar of Travel Application
 */
public class TETravelApplicationProgressBarCtrl {
    
    /**
     * @description status label to show
     */
    public Travel_Application__c MyRequest {get; set;}
    
    /**
     * @description step number of the current progress
     */
    public Integer Step {get; set;}
    public Boolean isLate {get; set;}

    /**
     * @description constructor with StandardController
     * @param stdController controller of Travel Application(s)
     */
    public TETravelApplicationProgressBarCtrl(ApexPages.StandardController stdController) {
        this.MyRequest = (Travel_Application__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c)//, is_Late_Application__c 
        from Travel_Application__c where Id =: MyRequest.Id];
        Travel_Application__c MyRequest2 = [select Status__c,
        is_Late_Application__c  
        from Travel_Application__c where Id =: MyRequest.Id];
        Step = TEConstant.getTravelApplicationStep(MyRequest2.Status__c);
        isLate = MyRequest2.is_Late_Application__c;
    }

}