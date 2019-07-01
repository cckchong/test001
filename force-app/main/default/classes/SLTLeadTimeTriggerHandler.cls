public without sharing class SLTLeadTimeTriggerHandler {
    
    
    Public static void blockUpdateDeleteRecord(Map<Id, Lead_Time__c> newLeadTimeMap, Map<Id, Lead_Time__c> oldLeadTimeMap) {
        
        Map<String, Boolean> leadTimeIdIsExistSampleMap = new Map<String, Boolean> ();
        Set<Id> leadTimeIdSet = new Set<Id> ();
        //add all to be updated lead time Id
        //if there are only to be deleted records, there will be no newMap
        if(newLeadTimeMap != null) {
            leadTimeIdSet.addAll(newLeadTimeMap.keySet());
        }
        //add all to be updated and deleted lead time id
        leadTimeIdSet.addAll(oldLeadTimeMap.keySet());
        
        
        if(!leadTimeIdSet.isEmpty()) {   
                         
            for(Sample__c reader : [SELECT Id, Standard_Lead_Time__c FROM Sample__c where Standard_Lead_Time__c in : leadTimeIdSet] ) {
                if(reader.Standard_Lead_Time__c != null) {
                    leadTimeIdIsExistSampleMap.put(reader.Standard_Lead_Time__c, true);
                }
            }
            
        }
        
        //block the update if there is a sample record linking to the lead time record
        if(newLeadTimeMap != null) {
            for(Lead_Time__c reader : newLeadTimeMap.values()) {
            
                if(leadTimeIdIsExistSampleMap.containsKey(reader.Id)) {
                
                    reader.addError(Label.SLT_Standard_Lead_Time_Not_Allow_To_Update_Delete_Message);
                }
            }    
        }
            
        //block the delete if there is a sample record linking to the lead time record
        for(Lead_Time__c reader : oldLeadTimeMap.values()) {
            if(newLeadTimeMap != null) {
                if(!newLeadTimeMap.containsKey(reader.Id)) {
                    if(leadTimeIdIsExistSampleMap.containsKey(reader.Id)) {
                        reader.addError(Label.SLT_Standard_Lead_Time_Not_Allow_To_Update_Delete_Message);
                    }           
                }
            }

            if(newLeadTimeMap == null) {
                if(leadTimeIdIsExistSampleMap.containsKey(reader.Id)) {
                    reader.addError(Label.SLT_Standard_Lead_Time_Not_Allow_To_Update_Delete_Message);
                }           
            }
            
        }            

        

    }
}