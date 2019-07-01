trigger TEAccommodationTrigger on Accommodation__c (After insert, After update) {

      if (Trigger.isInsert && Trigger.isAfter){
          TEAccommodationTriggerHandler.sendNewAccommodationMail(Trigger.new);
          
      }
      if (Trigger.isupdate && Trigger.isAfter){
          TEAccommodationTriggerHandler.updateAccommodationStatus(Trigger.oldMap, Trigger.newMap);
          
      }
      
}