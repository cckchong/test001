trigger AccountTrigger on Account(before insert, before update) {
   
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        AccountTriggerHandler.bypassSalesperson (Trigger.New);
    }
}