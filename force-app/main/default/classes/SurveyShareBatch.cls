global class SurveyShareBatch implements Database.Batchable<SObject> {
    global List<Survey_Assignment__Share> insertList;
    // global Set<String> setAssignmentAdmin;
    // global List<id> adminIdSet;
    // global String thequery;
    // public SurveyShareBatch(List<Survey_Assignment__Share> newList) {
    //     insertList=newList;
    // }

    global SurveyShareBatch(List<Survey_Assignment__Share> myinsertList)
    {
        this.insertList=new List<Survey_Assignment__Share>();
        this.insertList=myinsertList;
    }

    global List<Survey_Assignment__Share> start(Database.BatchableContext context) {
        // system.debug(thequery);
        return this.insertList;
    }
    global void execute(Database.BatchableContext BC, List<Survey_Assignment__Share> scope){
      
        System.debug('scope '+scope.size());//by DTT
        insert scope;
    }
    global void finish(Database.BatchableContext context) {
    }
}