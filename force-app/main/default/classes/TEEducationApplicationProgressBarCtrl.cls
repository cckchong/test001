/**
 * TEEducationApplicationProgressBarCtrl
 * @author Kelvin Wong
 * @description show progress bar of Education Application
 */
public class TEEducationApplicationProgressBarCtrl {
    
    /**
     * @description status label to show
     */
    public Education_Application__c MyRequest {get; set;}
    
    /**
     * @description step number of the current progress
     */
    public Integer Step {get; set;}
    
    public boolean staffType{get;set;} {staffType = false;}

    /**
     * @description constructor with StandardController
     * @param stdController controller of Education Application(s)
     */
    public TEEducationApplicationProgressBarCtrl(ApexPages.StandardController stdController) {
        this.MyRequest = (Education_Application__c) stdController.getRecord();
        this.MyRequest = [select Id, toLabel(Status__c), RecordTypeId from Education_Application__c where Id =: MyRequest.Id];
        Education_Application__c MyRequest2 = [select Status__c, RecordTypeId from Education_Application__c where Id =: MyRequest.Id];
        Step = TEConstant.getEducationApplicationStep(MyRequest2.Status__c);
        
        if (MyRequest.RecordTypeId != getRecordType('Child_Education').Id){
            staffType = true;
        }
    }
    
    private RecordType getRecordType(string rtname){
         try {
            RecordType rt = [SELECT Id, DeveloperName, Name, SobjectType FROM RecordType WHERE DeveloperName =: rtname AND SobjectType = 'Education_Application__c' Limit 1];
            //return mapRecordTypeInfos.get(rtname);  
            return rt;
            }
         catch(Exception ex) { 
             return null;
            //die silently 
         }
    } 
    
    
}