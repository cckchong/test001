/**
 * @description helper functions for the Leave Balance Latest Index Table
 */
public class LeaveBalanceLatestIndexHelper {

    private static boolean helperHasRun = false;
    
    public void processUpdate(Map<Id, Leave_Balance__c> oldMap, List<Leave_Balance__c> newList) {
        if(helperHasRun) {
            return;
        }
        
        List<Leave_Balance__c> leaveBalanceList = new List<Leave_Balance__c>();
        
        for(Leave_Balance__c lb : newList) {
            Leave_Balance__c oldLb = oldMap.get(lb.Id);
            
            if(lb.Is_Latest__c != oldLb.Is_Latest__c) {
                   
				leaveBalanceList.add(lb);
            }
        }
        
        if(!leaveBalanceList.isEmpty()) {
            processInsert(leaveBalanceList);
        }
    }
        
    public void processInsert(List<Leave_Balance__c> leaveBalanceList) {
        if(!Test.isRunningTest()) {
            if(helperHasRun) {
                return; // Remember that Test methods count as one transaction
            } else {
                helperHasRun = true;    
            }
        }
        System.debug('LeaveBalanceLatestIndexHelper:process - Entering method');
        Map<String, Leave_Balance_Latest_Index__c> leaveBalanceIndexMap = getIndexRecords(leaveBalanceList);
        Map<String, Leave_Balance__c> existingLatestLeaveBalanceMap = getCurrentLatestLeaveBalances(leaveBalanceIndexMap.values());
        Map<String, Leave_Balance__c> leaveBalancesInContextMap = 
            new Map<String, Leave_Balance__c>([SELECT Id, Unapproved_Balance__c, Is_Latest__c, Employee__c, Leave_Type_Code__c, Date__c FROM Leave_Balance__c WHERE Id IN: leaveBalanceList]);
        
        List<Leave_Balance_Latest_Index__c> indexRecordsToUpsert = new List<Leave_Balance_Latest_Index__c>();
        Map<String, Leave_Balance_Latest_Index__c> indexRecordsToUpsertMap = new Map<String, Leave_Balance_Latest_Index__c>();
        Map<String, Date> indexRecordsToUpsertDateMap = new Map<String, Date>(); // We only care about indexing the latest records in both the Database and this Trigger context
        
        List<Leave_Balance__c> lbRecordsToUpdate = new List<Leave_Balance__c>();
        
        // First create a catalog of latest Dates per recordKey
        for(Leave_Balance__c lb : leaveBalancesInContextMap.values()) {
        	String recordKey = getLeaveBalanceEmployeeLeaveTypeKey(lb);
            if(indexRecordsToUpsertDateMap.get(recordKey) != null) {
                if(lb.Date__c > indexRecordsToUpsertDateMap.get(recordKey)) {
                    indexRecordsToUpsertDateMap.put(recordKey, lb.Date__c);
                }
            } else {
                indexRecordsToUpsertDateMap.put(recordKey, lb.Date__c);
            }    
        }
        
        for(Leave_Balance__c lb : leaveBalancesInContextMap.values()) {
            System.debug('LeaveBalanceLatestIndexHelper:process - Processing Leave Balance = ' + lb.Id);
            
            String recordKey = getLeaveBalanceEmployeeLeaveTypeKey(lb);
            
            if(leaveBalanceIndexMap.get(recordKey) == null) {
                System.debug('LeaveBalanceLatestIndexHelper:process - No Index Found = ' + recordKey);
                
                // Is there an earlier one already indexed in this Trigger context?
                if(lb.Date__c == indexRecordsToUpsertDateMap.get(recordKey)) {
                       
                       lb.Is_Latest__c = true;
                       // Generate a new index record
                       Leave_Balance_Latest_Index__c lbli = new Leave_Balance_Latest_Index__c(
                           Employee_and_Leave_Type_Id__c = recordKey,
                           Latest_Leave_Balance__c = lb.Id
                       );
                       
                       //indexRecordsToUpsert.add(lbli);
                       indexRecordsToUpsertMap.put(recordKey, lbli);
                       lbRecordsToUpdate.add(lb);
				}

            } else {
                System.debug('LeaveBalanceLatestIndexHelper:process - Index Found = ' + recordKey);
                
                System.debug('LeaveBalanceLatestIndexHelper:process - Index Points to = ' + leaveBalanceIndexMap.get(recordKey).Latest_Leave_Balance__c);
                
                Leave_Balance_Latest_Index__c lbli = leaveBalanceIndexMap.get(recordKey);
                if(lb.Id == lbli.Latest_Leave_Balance__c || lbli.Latest_Leave_Balance__r.Date__c < lb.Date__c || lbli.Latest_Leave_Balance__c == null) {
                    
                    System.debug('LeaveBalanceLatestIndexHelper:process - The incoming record is the new latest = ' + recordKey);
                    
                    Leave_Balance__c oldLb = existingLatestLeaveBalanceMap.get(lbli.Latest_Leave_Balance__c);
                    
                    if(lb.Date__c == indexRecordsToUpsertDateMap.get(recordKey)) {
                        lb.Is_Latest__c = true;
                        
                        if(oldLb != null) {
                            oldLb.Is_Latest__c = false;
                            lb.Unapproved_Balance__c = oldLb.Unapproved_Balance__c;
                        }
                        
                        lbli.Latest_Leave_Balance__c = lb.Id;
                        
                        //indexRecordsToUpsert.add(lbli);
                        indexRecordsToUpsertMap.put(recordKey, lbli);
                        lbRecordsToUpdate.add(lb);
                        
                        if(oldLb != null && lb.Id != oldLb.Id) {
                            lbRecordsToUpdate.add(oldLb);
                        }
                    } // Else, there's another Leave Balance that is even more "later" within the Trigger Context

                } else {
                    // Ensure that the leave balance is always false
                    if(lb.Is_Latest__c) {
                        System.debug('LeaveBalanceLatestIndexHelper:process - Forcing record as NOT latest');
                        lb.Is_Latest__c = false;
                        lbRecordsToUpdate.add(lb);
                    }
                }
            }
        }
        
        if(!indexRecordsToUpsertMap.isEmpty()) {
            upsert indexRecordsToUpsertMap.values();
        }
        
        if(!lbRecordsToUpdate.isEmpty()) {
            update lbRecordsToUpdate;
        }
        
        System.debug('LeaveBalanceLatestIndexHelper:process - Exiting method');
    }
    
    public Map<String, Leave_Balance_Latest_Index__c> getIndexRecords(List<Leave_Balance__c> leaveBalanceList) {

        Map<String, Leave_Balance_Latest_Index__c> leaveBalanceIndexMap = new Map<String, Leave_Balance_Latest_Index__c>(); // The key is employeeId + '-' + leaveId
        for(Leave_Balance_Latest_Index__c li :
           [
               SELECT 	Id, 
               			Employee_and_Leave_Type_Id__c, 
               			Latest_Leave_Balance__c, 
               			Latest_Leave_Balance__r.Unapproved_Balance__c, 
               			Latest_Leave_Balance__r.Date__c, 
               			Latest_Leave_Balance__r.Is_Latest__c
               FROM Leave_Balance_Latest_Index__c
               WHERE Employee_and_Leave_Type_Id__c IN: getConcatenatedEmployeeIdLeaveId(leaveBalanceList)
           ]) {
        
               leaveBalanceIndexMap.put(li.Employee_and_Leave_Type_Id__c, li);
		}
        
        return leaveBalanceIndexMap;
    }
    
    public Map<String, Leave_Balance__c> getCurrentLatestLeaveBalances(List<Leave_Balance_Latest_Index__c> lbliList) {
        Map<String, Leave_Balance__c> currentLatestLeaveBalances = new Map<String, Leave_Balance__c>();
        List<Id> leaveBalanceIdList = new List<Id>();
        
        for(Leave_Balance_Latest_Index__c lbli : lbliList) {
            if(lbli.Latest_Leave_Balance__c != null) {
            	leaveBalanceIdList.add(lbli.Latest_Leave_Balance__c);
            }
        }
        
        currentLatestLeaveBalances = new Map<String, Leave_Balance__c>([SELECT Id, Unapproved_Balance__c, Is_Latest__c FROM Leave_Balance__c WHERE Id IN: leaveBalanceIdList]);
        
        return currentLatestLeaveBalances;
    }
    
    public Set<String> getConcatenatedEmployeeIdLeaveId(List<Leave_Balance__c> leaveBalanceList) {
        Set<String> resultKeys = new Set<String>();
        
        for(Leave_Balance__c lb : leaveBalanceList) {
            resultKeys.add(getLeaveBalanceEmployeeLeaveTypeKey(lb));
        }
    
        return resultKeys;
    }
    
    public String getLeaveBalanceEmployeeLeaveTypeKey(Leave_Balance__c lb) {
        if(lb.Employee__c == null || lb.Leave_Type_Code__c == null) {
            throw new TalException('LeaveBalanceLatestIndexHelper: getLeaveBalanceEmployeeLeaveTypeKey - Invalid Leave Balance Record');
        }
        
        return lb.Employee__c + '-' + lb.Leave_Type_Code__c;
    }
}