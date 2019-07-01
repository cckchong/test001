/**
 * LeaveBalanceTriggerHandler
 * @description Trigger Handler for the Leave Balance object
 * @date 14/01/2015
 * @author Andrew Ng
 */
public without sharing class LeaveBalanceTriggerHandler {
    
    /**
     * @deprecated see markLatestRecordNew
     */
    /*
    public static void indexLatestRecord(Map<Id, Leave_Balance__c> oldMap, List<Leave_Balance__c> newList) {
        LeaveBalanceLatestIndexHelper lbIndexHelper = new LeaveBalanceLatestIndexHelper();
        if(Trigger.isInsert) {
            
            lbIndexHelper.processInsert(newList);

        } else if(Trigger.isUpdate) {
            lbIndexHelper.processUpdate(oldMap, newList);
        }
    }
    */
    public static void preventUpdateOfCoreFields(Map<Id, Leave_Balance__c> oldMap, List<Leave_Balance__c> newList) {
        for(Leave_Balance__c lb : newList) {
            Leave_Balance__c oldLb = oldMap.get(lb.Id);
            
            if(lb.Date__c != oldLb.Date__c ||
              lb.Employee__c != oldLb.Employee__c ||
               lb.Leave_Type_Code__c != oldLb.Leave_Type_Code__c) {
                   
                   lb.addError(Label.ELeave_Cannot_Update_Leave_Balance);
               }
        }
    }
    
    private static boolean getDisableUnapprovedBalance() {
        boolean disableUnapprovedBalance = false;
        
        try {
            disableUnapprovedBalance = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger_Unapproved_Balance);
        } catch (Exception e) {}
        
        return disableUnapprovedBalance;
    }
    
    private static boolean getDisableMarkLatestRecord() {
        boolean disableTrigger = false;
        
        try {
            disableTrigger = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger);
        } catch (Exception e) {}
        
        return disableTrigger;
    }
    
    public static void markLatestRecordNew(Map<Id, Leave_Balance__c> oldMap, List<Leave_Balance__c> newList) {
        boolean disableTrigger = getDisableMarkLatestRecord();
        boolean disableUnapprovedBalance = getDisableUnapprovedBalance();

        if(disableTrigger) {
            return;
        }
        
        // First do a list of Employee ID + Leave Types that we need to update

        // This is the scope of records that have changed 
        Map<String, List<Leave_Balance__c>> lbKeyToLeaveBalances = new Map<String, List<Leave_Balance__c>>();
        List<String> empLeaveDateKeys = new List<String>();
        List<String> empLeaveTypeKeys = new List<String>();
        List<Leave_Balance__c> lbToUpdate = new List<Leave_Balance__c>();
        
        Map<String, Leave_Balance__c> wasLatestLb = new Map<String, Leave_Balance__c>();
        
        // Check which Employee+Leave Type records need to be updated
        for(Leave_Balance__c lb : newList) {
            
            // Check if the records actually need to be processed on update.
            if(Trigger.isUpdate) {
                if(oldMap.get(lb.Id).Is_Latest__c != lb.Is_Latest__c) {
                    // Just in case we did manually data patching on the Is Latest flag
                    //System.debug('>>>>> Leave_Balance__c record is ignored as the Latest flag changed >>>>>> ' + lb.Id + ' - ' + lb.Month__c + ' - ' + lb.Year__c);
                    continue;
                } else if(oldMap.get(lb.Id).Month__c == lb.Month__c && oldMap.get(lb.Id).Year__c == lb.Year__c &&
                         oldMap.get(lb.Id).Leave_Type_Code__c == lb.Leave_Type_Code__c && 
                         oldMap.get(lb.Id).Employee__c == lb.Employee__c) {
                    // It means that Month/Year/Leave Type/Employee didn't change for this record, so no need to process it
                    //System.debug('>>>>> Leave_Balance__c record is ignored as nothing of significant changed >>>>>> ' + lb.Id + ' - ' + lb.Month__c + ' - ' + lb.Year__c);
                    continue;
                }
            }

            // Build the key as formatted in the Tech_Employee_Leave_Type_Concatenated__c formula field:
            // Employee__c & "-" & Leave_Type_Code__c
            // Note that formula fields use the 15 digit ID
            System.debug('>>>>> Leave_Balance__c record is going to be processed >>>>>> ' + lb.Id + ' - ' + lb.Month__c + ' - ' + lb.Year__c);
            
            String employeeId = lb.Employee__c;
            String leaveCodeId = lb.Leave_Type_Code__c;
            String lbKey = employeeId.left(18) + '-' + leaveCodeId.left(18);
            
            if(lbKeyToLeaveBalances.get(lbKey) == null) {
                List<Leave_Balance__c> lbList = new List<Leave_Balance__c>();
                lbList.add(lb);
                lbKeyToLeaveBalances.put(lbKey, lbList);
            } else {
                List<Leave_Balance__c> lbList = lbKeyToLeaveBalances.get(lbKey);
                lbList.add(lb);
                lbKeyToLeaveBalances.put(lbKey, lbList);
            }
        }
        
        if(!lbKeyToLeaveBalances.isEmpty()) {
            // Wipe everything as Not Latest
            Map<Id, Leave_Balance__c> lbsMarked = new Map<Id, Leave_Balance__c>();
            for(Leave_Balance__c lb : 
                [
                    SELECT Id, Is_Latest__c, Month__c, Year__c, Unapproved_Balance__c, Tech_Employee_Leave_Type_Concatenated__c
                    FROM Leave_Balance__c 
                    WHERE Is_Latest__c = True
                    AND Tech_Employee_Leave_Type_Value__c IN: lbKeyToLeaveBalances.keyset()
                ]) {
                lb.Is_Latest__c = False;
                lbsMarked.put(lb.Id, lb);                    
                wasLatestLb.put(lb.Tech_Employee_Leave_Type_Concatenated__c, lb);
                System.debug('--------------------------');
                System.debug('>>> Wiping as Not Latest = ' + lb.Id + ' - ' + lb.Month__c + ' - ' + lb.Year__c + ' - ' + lb.Tech_Employee_Leave_Type_Concatenated__c);
                System.debug('--------------------------');
            }
            
            if(!lbsMarked.isEmpty()) {
                update lbsMarked.values();
                lbsMarked.clear();
            }
            
            // Query out the ones we must mark as latest
            List<AggregateResult> arList = 
               [
                   SELECT Leave_Type_Code__c, Employee__c, MAX(Date__c) max_date
                   FROM Leave_Balance__c
                   WHERE Tech_Employee_Leave_Type_Value__c IN: lbKeyToLeaveBalances.keyset()
                   GROUP BY Leave_Type_Code__c, Employee__c
               ];

            for(AggregateResult ar : arList) {
                // Build the key as formatted in the Tech_Leave_Type_Employee_Date_Key__c formula field:
                // Employee__c & "-" & Leave_Type_Code__c & "-" & TEXT(YEAR(Date__c)) & TEXT(MONTH(Date__c)) & TEXT(DAY(Date__c))
                // Note that formula fields use the 15 digit ID
                String employeeId = (String) ar.get('Employee__c');
                String leaveId = (String) ar.get('Leave_Type_Code__c');
                Date theDate = (Date) ar.get('max_date');
                String theKey = employeeId.LEFT(18) + '-' + leaveId.LEFT(18) + '-' + theDate.year() + theDate.month() + theDate.day();
                empLeaveDateKeys.add(theKey);
                
                System.debug('--------------------------');
                System.debug('>>> This key will be marked = ' + theKey);
                System.debug('--------------------------');
            }
            
            // Now re-query out the records we need to mark as latest
            for(Leave_Balance__c lb : [
                SELECT Id, Is_Latest__c, Month__c, Year__c, Unapproved_Balance__c, Tech_Employee_Leave_Type_Concatenated__c 
                FROM Leave_Balance__c 
                WHERE Tech_Leave_Type_Employee_Date_Value__c IN: empLeaveDateKeys
            ]) {
                
                System.debug('--------------------------');
                System.debug('>>> Marking as Latest = ' + lb.Id + ' - ' + lb.Month__c + ' - ' + lb.Year__c + ' - ' + lb.Tech_Employee_Leave_Type_Concatenated__c);
                System.debug('--------------------------');
                
                lb.Is_Latest__c = true;
                
                // Update the Unapproved_Balance__c
                if(!disableUnapprovedBalance && wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c) != null && lb.Id != wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c).Id) {
                    lb.Unapproved_Balance__c = wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c).Unapproved_Balance__c;
                }
                
                lbsMarked.put(lb.Id, lb);

            }
            
            update lbsMarked.values();
        }
    }
    
    public static void setEmployeeIdLeaveTypeKey(List<Leave_Balance__c> lbs) {
        if(Trigger.isBefore) {
            for(Leave_Balance__c lb : lbs) {
                if(lb.Employee__c != null && lb.Leave_Type_Code__c != null) {
                    String employeeId = lb.Employee__c;
                    String leaveTypeId = lb.Leave_Type_Code__c;
                    lb.Tech_Employee_Leave_Type_Value__c = employeeId.left(18) + '-' + leaveTypeId.left(18);
                    
                    lb.Tech_Leave_Type_Employee_Date_Value__c = employeeId.left(18) + '-' + leaveTypeId.left(18) + '-' + lb.Year__c + lb.Month__c + '1';
                }
            }
        }
    }
}