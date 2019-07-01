public with sharing class CaseTriggerHandler {
    private static Boolean markedClose = false;

    public static void handleBeforeUpdate(List<Case> cases) {
        setDefaultEntitlement(cases);
    }
    
    public static void handleBeforeInsert(List<Case> cases) {
        setDefaultEntitlement(cases);
    }
    
    public static void markClose(Map<ID, Case> oldCases, Map<ID, Case> newCases) {
        if (!markedClose || Test.isRunningTest()) {// Prevent trigger executing the 2nd time
            markedClose = true;
        
            List<Case> cases = new List<Case>();
            
            Map<ID, Case> newCasesFromDB = new Map<ID, Case>([Select id, IsClosed from Case where id in :newCases.keySet()]);
        
            for (Id caseId : oldCases.keySet()) {
                Case oldCase = oldCases.get(caseId);
                Case newCase = newCasesFromDB.get(caseId);
                
                if (oldCase != null && oldCase.isClosed != null && newCase != null && newCase.isClosed != null) {
                    if (!oldCase.isClosed && newCase.IsClosed) {
                        cases.add(new Case(id = newCase.id
                                            , closed_by__c = UserInfo.getUserId()));
                    }
                } /*else {
                    SystemUtil.handleException(new TALException('This is diagnosis message for TAG close case, please contact Admin if you receive this message\n' + ' Old Case = ' + oldCase + '\n New Case = ' + newCase + '\n oldCases = ' + oldCases + '\n newCases = ' + newCases + '\n newCasesFromDB = ' + newCasesFromDB));
                }*/
               	/*
                    The logic has a bug, in that this case may occur: The case is already closed, and the user changes the Owner of the case. 
                    This will throw the exception. Inspecting the record shows that this is what happened on the record.
                    Note that on the UI, it's never possible for the user to Close the Case and change the owner at the same time. 
                    So we don't need to worry about this case. Therefore, I can now say that to fix this issue, I can make an assumption 
                    that first, if the user doesn't have access to the "New Case", we never need to run this logic because we can assume that 
                    the Case is already closed before, and the Closed_By__c field was already successfully updated. OR I can assume the case 
                    is not closed yet, and just being transferred to a new owner, who will do the appropriate close action
                */
            }
            
            update cases;
        }
    }
    
    public static void setDefaultEntitlement(List<Case> cases) {
        // Search for case reocrd types by record type id
        Set<Id> caseTypeIds = new Set<Id>();
    
        for (Case c : cases) {
            if (c.entitlementId == null) {
                caseTypeIds.add(c.RecordTypeId);
            }
        }
        
        System.debug('Case Type Ids = ' + caseTypeIds);
        
        // Find out all case record type developer name
        Map<Id, RecordType> caseTypes = new Map<Id, RecordType>([Select id, developerName from RecordType where id in :caseTypeIds]);
    
        Map<String, Id> caseTypeToEntitlementMap = new Map<String, Id>();
    
        for (Case c : cases) {
            if (c.entitlementId == null) {
                c.recordType = caseTypes.get(c.RecordTypeId);
                caseTypeToEntitlementMap.put(c.recordType.developerName, null);
            }
        }
        
        System.debug('Case Types = ' + caseTypes);
        
        // Find out entitlement by case type developer name
        List<Entitlement> entitlements = [Select Id, Case_Type_Developer_Name__c from Entitlement where Case_Type_Developer_Name__c in :caseTypeToEntitlementMap.keySet() order by lastModifiedDate asc];
        
        for (Entitlement entitlement : entitlements) {
            caseTypeToEntitlementMap.put(entitlement.Case_Type_Developer_Name__c, entitlement.id);
        }
        
        System.debug('Entitlements = ' + entitlements);

        // Set the default entitlement if it is not yet selected        
        for (Case c : cases) {
            if (c.entitlementId == null) {
                c.entitlementId = caseTypeToEntitlementMap.get(c.RecordType.developerName);
            }
        }
        
        System.debug('Cases = ' + cases);
    }
}