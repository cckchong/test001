/**
 * TEEducationApplicationRemoteActionsUtils
 * @author Kelvin Wong
 * @description Recall approval process of Education Application(s)
 */
global without sharing class TEEducationApplicationRemoteActionsUtils {

      /**
       * @description Constructor with StandardController
       * @param ctrl Controller of Education Application(s)
       */
      global TEEducationApplicationRemoteActionsUtils (ApexPages.StandardController ctrl) {
        
      }
      
      /**
       * @description Recall approval process given the Education Application record ID
       * @param recordId ID to recall approval process
       * @return the record ID that has been recalled
       */
      //*
      @RemoteAction
      public static String recallApprovalProcess(String recordId) {
          
          Education_Application__c ea = null;
          Approval.ProcessResult result =  null;
          for ( Education_Application__c reader : [select id, status__c from Education_Application__c where id = :recordId ]){
              ea = reader;
          }
                
          List<ProcessInstance> procIns = new List<ProcessInstance>(
              [SELECT Id FROM ProcessInstance WHERE Status = 'Pending' and TargetObjectId = :recordId]);
                        
          if (procIns != null && !procIns.isEmpty() && (ea.Status__c == TEConstant.STATUS_PENDING_APPROVAL || ea.Status__c == TEConstant.STATUS_PENDING_HCM_APPROVAL)) {
              List<ProcessInstanceWorkitem>  workItem = new List<ProcessInstanceWorkitem>(
                  [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstanceId = :procIns[0].id]);
              
              if(workItem != null && !workItem.isEmpty()) {
                  Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
                  pwr.setAction('Removed');
                  pwr.setWorkitemId(workItem[0].Id);
                  result = Approval.process(pwr);
              } else {
                  throw new TalException(Label.TE_Education_Application_Unable_To_Recall);
              }
              
          } else {
              throw new TalException(Label.TE_Education_Application_Unable_To_Recall);
          }
          
          return recordId;
      }
      //*/
}