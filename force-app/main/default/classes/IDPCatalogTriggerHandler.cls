public without sharing  class IDPCatalogTriggerHandler{

   public static void setLevelTwoCatalogOwnerId(List<Catalog__c> newCatalogList) {
   
       set<String> levelOneCatalogIdSet = new set<String>();
       
       for(Catalog__c newCatalog : newCatalogList) {
           if(newCatalog.Parent_Catalog__c != null){
               levelOneCatalogIdSet.add(newCatalog.Parent_Catalog__c);
           }
       }
       
       Map<String, Catalog__c> levelOneCatalogIdCatalogMap = new Map<String, Catalog__c> ();
      
       for(Catalog__c levelOneCatalog : [SELECT Id, OwnerId FROM Catalog__c WHERE Id in:levelOneCatalogIdSet]) {
           levelOneCatalogIdCatalogMap.put(levelOneCatalog.Id, levelOneCatalog);
       }
       
      for(Catalog__c newCatalog : newCatalogList) {
           if(newCatalog.Parent_Catalog__c != null) {
               newCatalog.OwnerId = levelOneCatalogIdCatalogMap.get(newCatalog.Parent_Catalog__c).OwnerId;
           }
      }
   }
   
   public static void setLevelOneTwoCatalogOwnerSame (List<Catalog__c> newCatalogList) {
       Set<String> LVOneCatalogIdSet = new Set<String>();
       List<Catalog__c> LVOneCatalogList = new List<Catalog__c>();
       for(Catalog__c newCatalog : newCatalogList){
           LVOneCatalogIdSet.add(newCatalog.id);
           LVOneCatalogList.add(newCatalog);
       }   
       List<Catalog__c> LVTwoCatalogIDList = new List<Catalog__c>();
       LVTwoCatalogIDList = [select id,ownerId,Parent_Catalog__c from Catalog__c where Parent_Catalog__c in:LVOneCatalogIdSet];
       
       for(Catalog__c LVTwoCatalog:LVTwoCatalogIDList){
           for(Catalog__c LVOneCatalog:LVOneCatalogList){
               if(LVOneCatalog.id == LVTwoCatalog.Parent_Catalog__c){
                   LVTwoCatalog.ownerId = LVOneCatalog.ownerId ;
               }
           }
       }
       
       update LVTwoCatalogIDList;
   }
    /*
    public static void setLevelOneCatalogOwner(List<Catalog__c> newCatalogList) {
        
        Map<String, String> LevelOneCatalogIdCatalogownerIdMap = new Map<String, String> ();
        Map<String, Catalog__c> updateLevelTwoCatalogIdCatalogMap = new Map<String, Catalog__c> ();

        List <Catalog__c > updateLevelTwoCatalogList = new List <Catalog__c>();
        Set<String> levelOneCatalogIdSet = new Set<String> ();
        Set<String> levelTwoCatalogIdSet = new Set<String> ();

        for(Catalog__c reader: newCatalogList){
            if(reader.Parent_Catalog__c == null) {
                reader.OwnerId = reader.Tech_Catalog_Owner__c;             
                levelOneCatalogIdSet.add(reader.Id);
                LevelOneCatalogIdCatalogownerIdMap.put(reader.Id, reader.Tech_Catalog_Owner__c);
            }
            else {
                levelTwoCatalogIdSet.add(reader.Id);
                reader.OwnerId = reader.Tech_Catalog_Owner__c;             
            
            }
        }                    
        
        for(Catalog__c levelTwoCatalog: [SELECT Id, Parent_Catalog__c, Tech_Catalog_Owner__c FROM Catalog__c WHERE Parent_Catalog__c in :levelOneCatalogIdSet]) {
            system.debug(levelTwoCatalog);
            levelTwoCatalog.Tech_Catalog_Owner__c = LevelOneCatalogIdCatalogownerIdMap.get(levelTwoCatalog.Parent_Catalog__c);
            levelTwoCatalog.OwnerId = levelTwoCatalog.Tech_Catalog_Owner__c;
            updateLevelTwoCatalogIdCatalogMap.put(levelTwoCatalog.Id, levelTwoCatalog);
        }
        
        for(String selectedLevelTwoCatalogId :levelTwoCatalogIdSet) {
            if(updateLevelTwoCatalogIdCatalogMap.containskey(selectedLevelTwoCatalogId)) {
                updateLevelTwoCatalogIdCatalogMap.remove(selectedLevelTwoCatalogId);
            }
        
        }
        update updateLevelTwoCatalogIdCatalogMap.values();
   
   }
   */


                


}