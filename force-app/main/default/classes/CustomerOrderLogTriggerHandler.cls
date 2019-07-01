public class CustomerOrderLogTriggerHandler {
    
    public static void handleBeforeUpdate(Map<Id, Customer_Order_Log__c> oldLogMap,
                Map<Id, Customer_Order_Log__c> newLogMap) {
        // get the new owners' manager and VP
        Set<Id> newOwnerIds = new Set<Id>();
        for (Customer_Order_Log__c log: newLogMap.values()) {
            newOwnerIds.add(log.OwnerId);
        }
        
        Map<Id, User> newOwnerIdUserObjectMap = new Map<Id, User>([SELECT Id, ManagerId, UserRole.Name FROM User WHERE Id IN :newOwnerIds]);
        
        Map<Id, Id> newOwnerIdVPIdMap = new Map<Id, Id>();
        List<User> VPs = [SELECT Id, UserRole.Name FROM User WHERE Title LIKE :Label.TGATeamVPSearchKeyword And IsActive = true ORDER BY Name DESC];
        for (User newOwner: newOwnerIdUserObjectMap.values()) {
            for (User VP: VPs) {
                if (newOwner.UserRole.Name == VP.UserRole.Name) {
                    newOwnerIdVPIdMap.put(newOwner.Id, VP.Id);
                    break;
                    
                }
            }
        }
        
        // get users with 'CEL_PPC_Edit_Right' custom permission, for apex sharing
        Set<Id> ppcUserIds = CustomerOrderLogUtil.getUsersWithCustomPermission('CEL_PPC_Edit_Right');
        
        // get sharing of PPC, for removing the sharing
        List<Customer_Order_Log__Share> allPPCLogShrs = [SELECT Id, ParentId, RowCause from Customer_Order_Log__Share
                 WHERE ParentId = :newLogMap.values() AND RowCause = :Schema.Customer_Order_Log__Share.RowCause.Allow_PPC_Edit__c];
        
        // start trigger logic
        for (Customer_Order_Log__c log: newLogMap.values()) {
            Customer_Order_Log__c oldLog = oldLogMap.get(log.Id);
            
            // handle "From TGA to Customer" date
            if (!oldLog.From_TGA_to_Customer_Checkbox__c && log.From_TGA_to_Customer_Checkbox__c) {
                // Insert date if "From TGA to Customer" is checked
                log.From_TGA_to_Customer__c = datetime.now();
                
            }
            
            // warn if "NIL" is not the only element in the impacted customer list
            if (oldLog.Impacted_Customer__c != log.Impacted_Customer__c) {
                Set<String> impactedCustomers = new Set<String>();
                impactedCustomers.addAll(log.Impacted_Customer__c.split(';'));
                
                if (impactedCustomers.contains('-NIL-') && impactedCustomers.size() != 1) {
                    log.adderror(Label.ErrMsgNIL);
                    
                }
            }
            
            // handles ownership change
            if (oldLog.OwnerId!= log.OwnerId) {
                // set previous owner field
                log.Previous_Owner__c = oldLog.OwnerId;
                
                // change manager field
                log.Manager__c = newOwnerIdUserObjectMap.get(log.OwnerId) == null ?
                            null : newOwnerIdUserObjectMap.get(log.OwnerId).ManagerId;
            
                // change VP field
                log.VP__c = newOwnerIdVPIdMap.get(log.OwnerId);

            }
            
            // calculate KPI (exclude weekends & holidays)
            if (oldLog.From_TGA_to_Customer__c != log.From_TGA_to_Customer__c) {
                if (log.From_Customer_to_TGA__c != null && log.From_TGA_to_Customer__c != null) {
                    log.KPI_Exclude_Holidays__c = CustomerOrderLogUtil.getWorkingDays(log.From_Customer_to_TGA__c, log.From_TGA_to_Customer__c.date());
                
                }
            }
            
            // handle sharing, grant PPC edit when after 'TGA Submit'
            if (log.Is_TGA_Submit_Clicked__c) {
                List<Customer_Order_Log__Share> logShrs = new List<Customer_Order_Log__Share>();
                
                for (Id ppcUserId: ppcUserIds) {
                    Customer_Order_Log__Share logShr= new Customer_Order_Log__Share();
                    logShr.AccessLevel = 'Edit';
                    logShr.ParentId = log.Id;
                    logShr.RowCause = Schema.Customer_Order_Log__Share.RowCause.Allow_PPC_Edit__c;
                    logShr.UserOrGroupId = ppcUserId;
                    logShrs.add(logShr);
                    
                }
                
                if (logShrs != null && !logShrs.isEmpty()) insert logShrs;
            }
            
            // handle sharing, remove PPC edit when after 'PPC Impact'
            if (log.Is_PPC_Impact_Clicked__c) {
                List<Customer_Order_Log__Share> deleteLogShrs = new List<Customer_Order_Log__Share>();
                
                for (Customer_Order_Log__Share logShr : allPPCLogShrs) {
                    if (log.Id == logShr.ParentId) {
                        deleteLogShrs.add(logShr);
                        
                    }
                }
                
                if (deleteLogShrs != null && !deleteLogShrs.isEmpty()) delete deleteLogShrs;
            }
            
            // new history after the "complete email" is sent
            if (log.Is_Complete_Email_Sent__c) {
                Customer_Order_Log_History__c history = new Customer_Order_Log_History__c();
                history.Name = log.LogNumber__c + ' V' + log.Version__c;
                history.LOG__c = log.LogNumber__c;
                history.Version__c = log.Version__c ;
                history.Customer__c = log.Customer__c ;
                history.Brand__c = log.Brand__c ;            
                history.Product__c = log.Product__c ;
                history.Dipping_Flag__c = log.Dipping_Flag__c ;
                history.Plant__c = log.Plant__c ;
                history.Requested_Qty__c = log.Requested_Qty__c ;
                history.Requested_Delivery__c = log.Requested_Delivery__c ;
                history.Reserved_Qty__c = log.Reserved_Qty__c;
                history.Fabric_dely_ETA_Fty__c = log.Fabric_dely_ETA_Fty__c;
                history.SMV__c = log.SMV__c;
                history.Washing_Finishing__c = log.Washing_Finishing__c;
                history.PE_item__c = log.PE_item__c;
                history.Others_1__c = log.Others_1__c;
                history.Others_2__c = log.Others_2__c;
                
                history.From_Customer_to_TGA__c = log.From_Customer_to_TGA__c ;
                history.From_TGA_to_HK_PPC__c = log.From_TGA_to_HK_PPC__c ;
                
                history.From_HK_PPC__c = log.From_HK_PPC__c ;
                history.Meet_Customer_Requirement__c = log.Meet_Customer_Requirement__c ;
                history.Remarks__c = log.Remarks__c ;
                history.Remark_2__c = log.Remark_2__c ;
                history.Remark_3__c = log.Remark_3__c ;
                
                history.From_SVP_If_need_prioritization__c = log.From_SVP_If_need_prioritization__c;
                history.Confirmed_Delivery__c = log.Confirmed_Delivery__c ;
                history.Impacted_Customer__c = log.Impacted_Customer__c ;
                history.Impacted_Volume__c = log.Impacted_Volume__c ;
                history.Factory_transfer_if_any__c = log.Factory_transfer_if_any__c ;
                
                history.From_TGA_to_Customer__c = log.From_TGA_to_Customer__c ;
                history.Customer_Confirmation__c = log.Customer_Confirmation__c ;
                history.KPI_3_days_text__c = log.KPI_3_days__c;
                
                history.MasterLog__c = log.id;

                insert history ;
                
                // new log initialization
                log.Version__c  = log.Version__c + 1;
                log.From_Customer_to_TGA__c = null;
                log.From_TGA_to_HK_PPC__c = null;
                log.From_HK_PPC__c = null;
                log.Remark_2__c = null;
                log.Remark_3__c = null;
                log.From_SVP_If_need_prioritization__c = null;
                log.Confirmed_Delivery__c = null;
                log.Impacted_Customer__c = '-NIL-';
                log.Impacted_Volume__c = null;
                log.Factory_transfer_if_any__c = null;
                log.Customer_Confirmation__c = null;
                log.From_TGA_to_Customer_Checkbox__c = false;
                log.Remarks__c = null;
                log.Meet_Customer_Requirement__c = null;
                log.From_TGA_to_Customer__c = null;
            }
        }
    }

    public static void handleBeforeDelete(List<Customer_Order_Log__c> logs) {
        for (Customer_Order_Log__c log: logs) {
            log.adderror(Label.ErrMsgDeleteRecord, false);
        }
        
    }


    public static void handleBeforeInsert(List<Customer_Order_Log__c> logs) {
        // get all logs for same log comparison
        List<Customer_Order_Log__c> allLogs = [SELECT 
                    Id,
                    LogNumber__c,
                    Customer__c,
                    Brand__c,
                    Product__c,
                    Dipping_Flag__c,
                    Plant__c,
                    Requested_Qty__c,
                    Requested_Delivery__c,
                    Reserved_Qty__c
                    FROM Customer_Order_Log__c];
        
        // get creator user object for managerId
        User creator = [SELECT ManagerId, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        // get creator's VP
        Id VPId = null;
        List<User> VPs = [SELECT Id FROM User WHERE Title LIKE :Label.TGATeamVPSearchKeyword 
                        AND UserRole.Name = :creator.UserRole.Name And IsActive = true
                        ORDER BY Name DESC];// trick to assign "Yvonne Chow" as TGA team 5 VP temporarily, later on it should be "Betsy Chan"
        if (VPs != null && !VPs.isEmpty()) {
            VPId = VPs.get(0).Id;
        }
        
        // get system admin profile, admin can create log
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        // get users with custom permission 'CEL_TGA_Create_Right'
        Set<Id> tgaCreateIds = CustomerOrderLogUtil.getUsersWithCustomPermission('CEL_TGA_Create_Right');
        
        RecordType tgaInit = [SELECT Id FROM RecordType WHERE DeveloperName = 'TGA_Initialize'];
        
        // start trigger logic
        for (Customer_Order_Log__c log: logs) {    
            // only users with 'CEL_TGA_Create_Right' can create log
            if (!tgaCreateIds.contains(UserInfo.getUserId()) && UserInfo.getProfileId() != sysAdminProfile.Id) {
                log.adderror(Label.ErrMsgOnlyTGACanCreate);
                
            }
                    
            // check if the same record is being created
            for (Customer_Order_Log__c l: allLogs) {
                if (l.Customer__c == log.Customer__c && l.Brand__c == log.Brand__c
                    && l.Product__c == log.Product__c && l.Dipping_Flag__c == log.Dipping_Flag__c
                    && l.Plant__c == log.Plant__c && l.Requested_Qty__c == log.Requested_Qty__c
                    && l.Requested_Delivery__c == log.Requested_Delivery__c && l.Reserved_Qty__c == log.Reserved_Qty__c) {
                        
                        log.adderror(String.format(Label.ErrMsgLogCreated, new String[] {l.LogNumber__c}));
                        break;
                }
            }
            
            // assign Manager
            log.Manager__c = creator == null? null : creator.ManagerId;
            
            // assign VP
            if (VPs != null && !VPs.isEmpty()) {
                log.VP__c = VPId;
            }
            
            // default impacted_customer as -NIL-
            log.Impacted_Customer__c = '-NIL-';
            
            // set record type to TGA initialize
            log.RecordTypeId = tgaInit.Id;
        }
        
    }


    public static void handleAfterUpdate(Map<Id, Customer_Order_Log__c> oldLogMap,
                Map<Id, Customer_Order_Log__c> newLogMap) {
        // get a list of previous histories of the logs, for skipping duplicated version change in later part
        List<Customer_Order_Log_Track_History__c> existingHistories = [SELECT Id, Customer_Order_Log__r.Id, Field__c, OldValue__c, NewValue__c
            FROM Customer_Order_Log_Track_History__c WHERE Customer_Order_Log__c IN :oldLogMap.keySet()];
                    
        // create a customized track history
        List<Schema.FieldSetMember> trackedFields = SObjectType.Customer_Order_Log__c.FieldSets.HistoryTracking.getFields();
        List<Customer_Order_Log_Track_History__c> fieldChanges = new List<Customer_Order_Log_Track_History__c>();
        
        // start trigger logic
        for (Customer_Order_Log__c log: newLogMap.values()) {
            Customer_Order_Log__c oldLog = oldLogMap.get(log.Id);
                
            for (Schema.FieldSetMember fsm : trackedFields) {
                String fieldName  = fsm.getFieldPath();
                String fieldLabel = fsm.getLabel();
                
                if (oldLog.Version__c != log.Version__c) {
                    // case return-resubmit, only track version change
                    if (fieldName != 'Version__c') {
                        continue;
                        
                    } else {
                        // don't save history if triggered twice (as trigger will be re-run again after workflow)
                        String oldVersion = String.valueOf(oldLog.Version__c);
                        String newVersion = String.valueOf(log.Version__c);
                        
                        Boolean versionChangeExist = false;
                        
                        for (Customer_Order_Log_Track_History__c hist : existingHistories) {
                            if (hist.Customer_Order_Log__c == log.Id && hist.Field__c == fieldLabel
                                && hist.OldValue__c == oldVersion && hist.NewValue__c == newVersion) {
                                    versionChangeExist = true;
                                    break;
                            }
                            
                        }
                        
                        if (versionChangeExist) {
                            break;
                            
                        }
                    }
                }
                
                if (oldLog.get(fieldName) != log.get(fieldName)) {
                    String oldValue;
                    String newValue;
                    
                    if (log.get(fieldName) instanceOf Datetime) {
                        // don't need the time
                        oldValue = oldLog.get(fieldName) == null? null: String.valueOf(((Datetime) oldLog.get(fieldName)).date());
                        newValue = log.get(fieldName) == null? null: String.valueOf(((Datetime) log.get(fieldName)).date());
                        
                    } else {
                        oldValue = String.valueOf(oldLog.get(fieldName));
                        newValue = String.valueOf(log.get(fieldName));
                    }
                    
                    if (oldValue != null && oldValue.length()>255) oldValue = oldValue.substring(0,255);
                    if (newValue != null && newValue.length()>255) newValue = newValue.substring(0,255); 
                    
                    Customer_Order_Log_Track_History__c th = new Customer_Order_Log_Track_History__c();
                    th.OldValue__c = oldValue; 
                    th.NewValue__c = newValue;
                    th.Field__c = fieldLabel;
                    th.Customer_Order_Log__c= log.Id;
                    
                    fieldChanges.add(th);
                }
            }
        }
        
        insert fieldChanges;
        
    }
    
}