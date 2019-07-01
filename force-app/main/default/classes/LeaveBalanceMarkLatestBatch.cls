global class LeaveBalanceMarkLatestBatch  implements Database.Batchable<sObject>, Database.Stateful {

    /*List<String> empLeaveDateKeys;
    Map<String, Leave_Balance__c> wasLatestLb;
    String queryStr =   ' SELECT Id, Is_Latest__c, Month__c, Year__c, Unapproved_Balance__c, Tech_Employee_Leave_Type_Concatenated__c ' +
             			' FROM Leave_Balance__c ' +
              			' WHERE Tech_Leave_Type_Employee_Date_Key__c IN: empLeaveDateKeys';
    */
    global LeaveBalanceMarkLatestBatch(List<String> empLeaveDateKeys, Map<String, Leave_Balance__c> wasLatestLb) {
      //  this.empLeaveDateKeys = empLeaveDateKeys;
      //  this.wasLatestLb = wasLatestLb;
    }
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        
        //prepare query to fetch account
		//String queryStr = this.queryStr;
        
        //System.debug('### queryStr ### ' + queryStr);

        //return Database.getQueryLocator(queryStr);
        return Database.getQueryLocator('');
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        /*List<Leave_Balance__c> lbList = (List<Leave_Balance__c>) scope;
        for(Leave_Balance__c lb : lbList) {
            
            lb.Is_Latest__c = true;
            // Update the Unapproved_Balance__c
            if(!getDisableUnapprovedBalance() && wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c) != null && lb.Id != wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c).Id) {
                lb.Unapproved_Balance__c = wasLatestLb.get(lb.Tech_Employee_Leave_Type_Concatenated__c).Unapproved_Balance__c;
            }
        }
        
        update lbList;
        */
    }

    global void finish(Database.BatchableContext info){

    }
    /*
	private boolean getDisableUnapprovedBalance() {
      
        boolean disableUnapprovedBalance = false;
        
        try {
            disableUnapprovedBalance = Boolean.valueOf(Label.Tech_Disable_Leave_Balance_Trigger_Unapproved_Balance);
        } catch (Exception e) {}
        
        return disableUnapprovedBalance;
    }
    */
    global void testBatch() {
        /*if(Test.isRunningTest()) {
            String queryStr = this.queryStr;
            List<SObject> resultList = Database.query(queryStr);
            start(null);
            execute(null, resultList);
            finish(null);
        }*/
    }

}