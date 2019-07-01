/**
 * IDPCatalogPermissonCtrl
 * @description 
 
 updated
 1. disable checkbox
 2. change owner to a queue
 */
public without sharing class IDPCatalogPermissonCtrl {
    
    //*
    Public static Map<String,List<String>> objResults {get; set;}    
    Public static Map<String,String> valueLabelMap {get; set;}
    
    Public static String SEPARATOR = ',';
    Public static Integer SIZE_LIMIT = 1000;
    Public static String REPLACE = '[^a-zA-Z0-9_,-]';
    Public Employee__c emp {get; set;}
    Public String permissionMatrixSelect {get; set;}
    Public String userSelect {get; set;} 
    Public String catalogSelect {get; set;}
    Public String catalogItemSelect {get; set;}
    Public String depSelect {get; set;}
    Public String policySelect {get; set;}
    Public String msg {get; set;}
    Public Boolean isSave {get; set;}
    Public Boolean showResult {get; set;}
    Public Map<id, Catalog__c> catlogMap {get; set;}
    Public Map<id, Catalog_Item__c> catlogItemMap {get; set;}
    Public List <SelectOption> permissionMatrixList{get; set;}

    Public List <SelectOption> catlogItemOptList1{get; set;}
    Public List <SelectOption> catlogItemOptList2{get; set;}
    Public List <SelectOption> catlogItemOptList3{get; set;}
    Public List <SelectOption> catlogItemOptList4{get; set;}
    Public List <SelectOption> catlogItemOptList5{get; set;}
    Public List <SelectOption> catlogItemOptList6{get; set;}
    Public List <SelectOption> catlogItemOptList7{get; set;}
    Public List <SelectOption> catlogItemOptList8{get; set;}
    Public List <SelectOption> catlogItemOptList9{get; set;}
    Public List <SelectOption> catlogItemOptList10{get; set;}

    Public List <SelectOption> catlogOptList{get; set;}
    Public List <SelectOption> userList{get; set;}
    Public List <SelectOption> userList1{get; set;}
    Public List <SelectOption> userList2{get; set;}
    Public List <SelectOption> userList3{get; set;}
    Public List <SelectOption> userList4{get; set;}
    Public List <SelectOption> userList5{get; set;}
    Public List <SelectOption> userList6{get; set;}
    Public List <SelectOption> userList7{get; set;}
    Public List <SelectOption> userList8{get; set;}
    Public List <SelectOption> userList9{get; set;}
    Public List <SelectOption> userList10{get; set;}
    Public List <SelectOption> depList{get; set;}
    Public List <SelectOption> policyList{get; set;}
    Public Map <String, String> depTranslate{get; set;}
    Public Map <String, String> userTranslate{get; set;}
    Public Map<String, Catalog_Item_Permission__c> CatalogItemPermission{get; set;}
    Public Map <String, Map<String, Boolean>> tableMap {get; set;}
    Public Map <String, Map<String, Boolean>> fakeDisabledCheckedTableMap {get; set;} 
    Map<String, String> leveltwoCatalogIdLevelOneCatalogIdMap {get; set;}

    Public IDPCatalogPermissonCtrl(){
        String userId = '';
        Set<Id> tempUserIdSet = new Set<Id> ();
        Map<Id, Set<Id>> tempUserOwnerCatalogSetMap = new Map<Id, Set<Id>> ();
        String path = ''; 
        msg = '';
        policySelect = '';
        userSelect = '';
        catalogSelect = '';
        catalogItemSelect = '';
        permissionMatrixSelect = '';
        depSelect = '';
        isSave = false;
        showResult = false;
        emp = new Employee__c ();
        catlogMap = new Map<id, Catalog__c>();
        tableMap = new Map <String, Map<String, Boolean>>();
        fakeDisabledCheckedTableMap = new Map <String, Map<String, Boolean>>();
        leveltwoCatalogIdLevelOneCatalogIdMap = new Map<String, String>();
        depTranslate = new Map <String, String>();
        userTranslate = new Map <String, String>();        
        catlogItemMap = new Map<id, Catalog_Item__c>();
        PermissionMatrixList = new List <SelectOption>();
        catlogOptList = new List <SelectOption>();
        catlogItemOptList1 = new List <SelectOption>();
        catlogItemOptList2 = new List <SelectOption>();
        catlogItemOptList3 = new List <SelectOption>();
        catlogItemOptList4 = new List <SelectOption>();
        catlogItemOptList5 = new List <SelectOption>();
        catlogItemOptList6 = new List <SelectOption>();
        catlogItemOptList7 = new List <SelectOption>();
        catlogItemOptList8 = new List <SelectOption>();
        catlogItemOptList9 = new List <SelectOption>();
        catlogItemOptList10 = new List <SelectOption>();
        userList = new List <SelectOption>();
        userList1 = new List <SelectOption>();
        userList2 = new List <SelectOption>();
        userList3 = new List <SelectOption>();
        userList4 = new List <SelectOption>();
        userList5 = new List <SelectOption>();
        userList6 = new List <SelectOption>();
        userList7 = new List <SelectOption>();
        userList8 = new List <SelectOption>();
        userList9 = new List <SelectOption>();
        userList10 = new List <SelectOption>();
        depList = new List <SelectOption>();
        policyList = new List <SelectOption>();
        userId = UserInfo.getUserId();
        tempUserIdSet.add(userId);
        tempUserOwnerCatalogSetMap = IDPCommonUtils.getUserCatalogs(tempUserIdSet);
        system.debug(tempUserOwnerCatalogSetMap);
        objResults = IDPCommonUtils.dependPickListValue('Employee__c', 'Function_Code__c', 'Department_Code__c');
        
        valueLabelMap = new Map<String,String>();
        valueLabelMap  = IDPCommonUtils.picklistWithTranslation('Employee__c', 'Function_Code__c', 'Department_Code__c');
        system.debug(valueLabelMap);

        for(Employee__c reader :[select id, idp_policy__c, idp_policy__r.Name from employee__c where user__c = :UserInfo.getUserId()]){
            policySelect = reader.idp_policy__c;
        }
        
        for(Catalog__c reader : [select id, Name, Display_Name__c, (select id, Name, Display_Name__c from Catalogs__r order by Display_Name__c asc) 
                                 from Catalog__c 
                                 where Parent_Catalog__c = null
                                 and Id in : tempUserOwnerCatalogSetMap.get(userId) 
                                 //and Tech_Is_Owner__c = true
                                 //and idp_policy__c = :policySelect 
                                 order by Display_Name__c asc]){
            catlogMap.put(reader.id, reader);
            catlogOptList.add(new SelectOption(reader.Id, reader.Display_Name__c));
            for(Catalog__c CatlogReader : reader.Catalogs__r){
                catlogMap.put(CatlogReader.id, CatlogReader);
                catlogOptList.add(new SelectOption(CatlogReader.Id, CatlogReader.Display_Name__c));
            }
        }
        policyList.add(new SelectOption('', ''));
        for(IDP_policy__c reader : [select id, Name  from IDP_policy__c order by Name]){
            policyList.add(new SelectOption(reader.Id, reader.Name));
        }
        //catlogItemOptList.add(new SelectOption('', ''));
        






        
        for(Catalog_Item__c reader : [select id, Name, Item_Name__c, Catalog__c, Catalog__r.Catalog_Name__c, Catalog__r.Parent_Catalog__r.Catalog_Name__c
                                      from Catalog_Item__c 
                                      where Status__c = :IDPConstant.CATALOG_ITEM_STATUS_ACTIVE
                                      //and Catalog__r.Tech_Is_Owner__c = true
                                      and Catalog__r.Parent_Catalog__c != null
                                      and Catalog__c in : tempUserOwnerCatalogSetMap.get(userId)                                       
                                      order by Catalog__r.Parent_Catalog__r.Catalog_Name__c asc, Catalog__r.Catalog_Name__c asc, Item_Name__c asc
                                      ]){
            catlogItemMap.put(reader.id, reader);
            path = '';
            if(reader.Catalog__r.Parent_Catalog__c != null){
                path = reader.Catalog__r.Parent_Catalog__r.Catalog_Name__c + ' / ';
            }
            path += reader.Catalog__r.Catalog_Name__c +' / '+ reader.Item_Name__c;

            if(catlogItemOptList1.size() < SIZE_LIMIT){
                catlogItemOptList1.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList2.size() < SIZE_LIMIT){
                catlogItemOptList2.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList3.size() < SIZE_LIMIT){
                catlogItemOptList3.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList4.size() < SIZE_LIMIT){
                catlogItemOptList4.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList5.size() < SIZE_LIMIT){
                catlogItemOptList5.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList6.size() < SIZE_LIMIT){
                catlogItemOptList6.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList7.size() < SIZE_LIMIT){
                catlogItemOptList7.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList8.size() < SIZE_LIMIT){
                catlogItemOptList8.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList9.size() < SIZE_LIMIT){
                catlogItemOptList9.add(new SelectOption(reader.Id, path));
            }
            else if(catlogItemOptList10.size() < SIZE_LIMIT){
                catlogItemOptList10.add(new SelectOption(reader.Id, path));
            }
        }








        for(user reader : [select id, name_display__c, Name  from user where isactive = true order by name_display__c, Name //limit 1000
        ]){
            path = reader.name_display__c;
            if(String.isBlank(reader.name_display__c)){
                path = reader.Name;
            }
            userTranslate.put(reader.Id, path );
            if(userList1.size() < SIZE_LIMIT){
                userList1.add(new SelectOption(reader.Id, path));
            }
            else if(userList2.size() < SIZE_LIMIT){
                userList2.add(new SelectOption(reader.Id, path));
            }
            else if(userList3.size() < SIZE_LIMIT){
                userList3.add(new SelectOption(reader.Id, path));
            }
            else if(userList4.size() < SIZE_LIMIT){
                userList4.add(new SelectOption(reader.Id, path));
            }
            else if(userList5.size() < SIZE_LIMIT){
                userList5.add(new SelectOption(reader.Id, path));
            }
            else if(userList6.size() < SIZE_LIMIT){
                userList6.add(new SelectOption(reader.Id, path));
            }
            else if(userList7.size() < SIZE_LIMIT){
                userList7.add(new SelectOption(reader.Id, path));
            }
            else if(userList8.size() < SIZE_LIMIT){
                userList8.add(new SelectOption(reader.Id, path));
            }
            else if(userList9.size() < SIZE_LIMIT){
                userList9.add(new SelectOption(reader.Id, path));
            }
            else if(userList10.size() < SIZE_LIMIT){
                userList10.add(new SelectOption(reader.Id, path));
            }
        }
        depList.add(new SelectOption('all', 'All'));
        depTranslate.put('all', 'All');
        for(String key : objResults.keySet()){
            if(objResults.get(key).isempty()){
                //key = key.replace(' ', '');
                //depList.add(new SelectOption(key + '-', key));
                depList.add(new SelectOption(key + '-', key));
                //depTranslate.put(key + '-', key);
                depTranslate.put(key + '-', key);
            }
            
            for(String value : objResults.get(key)){
            
                //depList.add(new SelectOption(key + '-' + value, key + ' - ' + value));          
                depList.add(new SelectOption(key + '-' + value, valueLabelMap.get(key) + ' - ' + valueLabelMap.get(value))); 
                depTranslate.put(key + '-' + value, valueLabelMap.get(key) + ' - ' + valueLabelMap.get(value));
            }
        }
        
        
        system.debug('depList: '+depList);
        
        permissionMatrixList.add(new SelectOption('opt1', 'Department - Catalog'));
        permissionMatrixList.add(new SelectOption('opt2', 'User - Catalog'));
        permissionMatrixList.add(new SelectOption('opt3', 'User - Item'));

        system.debug(permissionMatrixList.size());
    }
     
    Public void result(){
        List <String> depSelectList = new List <String>();
        List <String> userSelectList = new List <String>();
        List <String> catlogOptSelectList = new List <String>();
        List <String> catlogItemOptSelectList = new List <String>();
        List<String> validUserIdList = new List<String> ();
        Map <String, Boolean> rowAttrib = new Map <String, Boolean>();
        Map<String, Catalog_Item_Permission__c> levelOneCatalogItemPermission = new Map<String, Catalog_Item_Permission__c> ();
        Map <String, Boolean> fakeDisabledCheckedRowAttrib = new Map <String, Boolean>();
        
        Boolean isAll = false;
        String key = '';
        tableMap.clear(); 
        showResult = validation();
        if(!showResult){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            return;
        }
        isSave = false;
          
        
        if(permissionMatrixSelect == 'opt1'){
            system.debug(depSelect);
            //depSelect = depSelect.replaceAll(REPLACE, '');
                        
            depSelectList = depSelect.split(SEPARATOR);
            system.debug(depSelectList);
            
            
            for(String reader : depSelectList){
            if (reader == 'all'){
                    isAll = true;
                }
            }
            if(isAll){
                depSelectList.clear();
                for(SelectOption reader : depList){
                    key = reader.getValue();
                    if(key != 'all'){
                        //key = key.replace('-', '_');
                        depSelectList.add(key);
                    }
                }
            }
            
            
            catalogSelect = catalogSelect.replaceAll(REPLACE, '');
            catlogOptSelectList = catalogSelect.split(SEPARATOR);
            catalogItemPermission = getCatalogItemPermission(permissionMatrixSelect, depSelectList, null, catlogOptSelectList, null, policySelect);

            leveltwoCatalogIdLevelOneCatalogIdMap = new Map<String, String> ();
            for(Catalog__c reader : [SELECT Id, Parent_Catalog__c, Parent_Catalog__r.Catalog_Name__c FROM Catalog__c Where Id in :catlogOptSelectList]) {
                if(reader.Parent_Catalog__c != null) {
                    leveltwoCatalogIdLevelOneCatalogIdMap.put(reader.Id, reader.Parent_Catalog__c);
                }
                else {
                    leveltwoCatalogIdLevelOneCatalogIdMap.put(reader.Id, reader.Id);
                }
            }           
            
            levelOneCatalogItemPermission = getCatalogItemPermission(permissionMatrixSelect, depSelectList, null, leveltwoCatalogIdLevelOneCatalogIdMap.values(), null, policySelect);
           
            for(String col : depSelectList){
                system.debug(col);
                rowAttrib = new Map <String, Boolean>();
                fakeDisabledCheckedRowAttrib = new Map <String, Boolean>();
                             
                for(String row : catlogOptSelectList){
                    rowAttrib.put(row, false);               
                    fakeDisabledCheckedRowAttrib.put(row, false);
             
                    //policySelect 
                    if(catalogItemPermission.containsKey(policySelect + '_' + col + '_' + row )){
                    //if(catalogItemPermission.containsKey( col + '_' + row  +'_' + policySelect  )){
                        rowAttrib.put(row, true);
                        fakeDisabledCheckedRowAttrib.put(row, true);
                              
                    }
                                              
                    if(leveltwoCatalogIdLevelOneCatalogIdMap.containskey(row)) {
                        String fakeRow = leveltwoCatalogIdLevelOneCatalogIdMap.get(row);
                        
                        if(levelOneCatalogItemPermission.containsKey(policySelect + '_' + col + '_' + fakeRow)){
                            fakeDisabledCheckedRowAttrib.put(row, true);
                        }
                    }
                              
                }
                tableMap.put(col, rowAttrib);
                fakeDisabledCheckedTableMap.put(col, fakeDisabledCheckedRowAttrib);
            }
        }
        system.debug('tableMap: '+tableMap);
        
        if(permissionMatrixSelect == 'opt2'){            
            Map <id, Catalog_Item_Permission__c> CatalogItemPermissionMap = new Map <id, Catalog_Item_Permission__c>();
            userSelect = userSelect.replaceAll(REPLACE, '');
            userSelectList = userSelect.split(SEPARATOR);
            catalogSelect = catalogSelect.replaceAll(REPLACE, '');
            catlogOptSelectList = catalogSelect.split(SEPARATOR);
            catalogItemPermission = getCatalogItemPermission(permissionMatrixSelect, null, userSelectList, catlogOptSelectList, null, '');
            
            leveltwoCatalogIdLevelOneCatalogIdMap = new Map <String, String> ();
            for(Catalog__c reader : [SELECT Id, Parent_Catalog__c FROM Catalog__c Where Id in :catlogOptSelectList]) {
                if(reader.Parent_Catalog__c != null) {
                    leveltwoCatalogIdLevelOneCatalogIdMap.put(reader.Id, reader.Parent_Catalog__c);
                }
                else {
                    leveltwoCatalogIdLevelOneCatalogIdMap.put(reader.Id, reader.Id);
                }
            }
            validUserIdList =validationEmployeeRecords(userSelectList);
            if( validUserIdList.size() != userSelectList.size() ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            }
                          
                      
            for(String col : validUserIdList){
                rowAttrib = new Map <String, Boolean>();                
                fakeDisabledCheckedRowAttrib = new Map <String, Boolean>();
                
                List<Catalog_Item_Permission__c> userPermissionList = IDPCommonUtils.getUserAllPermission(col);
                Map<String, Catalog_Item_Permission__c> catalogIdPermissionMap = new Map<String, Catalog_Item_Permission__c>();
                for(Catalog_Item_Permission__c cip :userPermissionList) {
                    if(cip.isCatalogLevel__c == true) {
                        catalogIdPermissionMap.put(cip.Catalog__c, cip);
                    }
                }
                     
                for(String row : catlogOptSelectList){
                    rowAttrib.put(row, false);                
                    fakeDisabledCheckedRowAttrib.put(row, false);
                    
                    if(catalogItemPermission.containsKey(col+'_'+row)){
                        rowAttrib.put(row, true);                
                        fakeDisabledCheckedRowAttrib.put(row, true);
 
                    }

                    if(catalogIdPermissionMap.containsKey(row)) {
                        fakeDisabledCheckedRowAttrib.put(row, true);
                    }
                    if(leveltwoCatalogIdLevelOneCatalogIdMap.containsKey(row)) {
                        if(catalogIdPermissionMap.containsKey(leveltwoCatalogIdLevelOneCatalogIdMap.get(row))) {
                            fakeDisabledCheckedRowAttrib.put(row, true);
                        }
                    }
                    
                }
                tableMap.put(col, rowAttrib);
                fakeDisabledCheckedTableMap.put(col, fakeDisabledCheckedRowAttrib);
            }
        }
        
        system.debug('tableMap2: '+tableMap);
        
        if(permissionMatrixSelect == 'opt3'){
            userSelect = userSelect.replaceAll(REPLACE, '');
            userSelectList = userSelect.split(SEPARATOR);
            catalogItemSelect = catalogItemSelect.replaceAll(REPLACE, '');
            catlogItemOptSelectList  = catalogItemSelect.split(SEPARATOR);
            catalogItemPermission = getCatalogItemPermission(permissionMatrixSelect, null, userSelectList, null, catlogItemOptSelectList, '');
              
            Map<String, Catalog_Item__c > catalogItemIdCatalogItemMap = new Map<String, Catalog_Item__c >();
            for(Catalog_Item__c reader : [SELECT Id, Catalog__c, Catalog__r.Parent_Catalog__c FROM Catalog_Item__c Where Id in :catlogItemOptSelectList]) {
                catalogItemIdCatalogItemMap.put(reader.Id, reader);
            }
            validUserIdList =validationEmployeeRecords(userSelectList);
            if( validUserIdList.size() != userSelectList.size() ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
            }
                            
            
            for(String col : validUserIdList){
                rowAttrib = new Map <String, Boolean>();
                fakeDisabledCheckedRowAttrib = new Map <String, Boolean>();
                
                List<Catalog_Item_Permission__c> userPermissionList = IDPCommonUtils.getUserAllPermission(col);
                Map<String, Catalog_Item_Permission__c> catalogIdPermissionMap = new Map<String, Catalog_Item_Permission__c>();
                for(Catalog_Item_Permission__c cip :userPermissionList) {
                    if(cip.isCatalogLevel__c == true) {
                        catalogIdPermissionMap.put(cip.Catalog__c, cip);
                    }
                } 
                
                for(String row : catlogItemOptSelectList){
                    rowAttrib.put(row, false);            
                    fakeDisabledCheckedRowAttrib.put(row, false);
                                    
                    if(catalogItemPermission.containsKey(col+'_'+row)){
                        rowAttrib.put(row, true);               
                        fakeDisabledCheckedRowAttrib.put(row, true);
                    }
                    
                    if(catalogItemIdCatalogItemMap.containsKey(row)) {
                         if(catalogIdPermissionMap.containsKey(catalogItemIdCatalogItemMap.get(row).Catalog__c)) {
                             fakeDisabledCheckedRowAttrib.put(row, true);
                         }
                         
                         if(catalogIdPermissionMap.containsKey(catalogItemIdCatalogItemMap.get(row).Catalog__r.Parent_Catalog__c)) {
                             fakeDisabledCheckedRowAttrib.put(row, true);
                         }                         
                    }

                    
                }
                tableMap.put(col, rowAttrib);                            
                fakeDisabledCheckedTableMap.put(col, fakeDisabledCheckedRowAttrib);
            }
        }
        system.debug('tableMap3: '+tableMap);
    }
    
    Public Map<String, Catalog_Item_Permission__c> getCatalogItemPermission(String opt, List<String> departmentList, List<Id> userList, List<String> catalogList, List<String> itemList, String policy){
        Map<String, Catalog_Item_Permission__c> cip = new Map<String, Catalog_Item_Permission__c>();
        List<String> tmpdepartmentList = new List<String> ();
        String key = '';
        if(opt == 'opt1'){
            for(String reader : departmentList){
                tmpdepartmentList.add(reader.replace('-', '_'));                
            }
            for(Catalog_Item_Permission__c reader : [select id, Catalog__c, Catalog_Item__c, Department__c, Function__c, IDP_Policy__c,
                                                           isCatalogItemLevel__c, isCatalogLevel__c, isDepartmentLevel__c, isUserLevel__c, 
                                                           User__c, Function_Department__c  
                                                           from Catalog_Item_Permission__c
                                                           where Function_Department__c in :tmpdepartmentList
                                                           and Catalog__c in :catalogList
                                                           and idp_policy__c = :policy
                                                          ]){
                key = reader.Function_Department__c.replace('_','-');
                cip.put(reader.IDP_Policy__c + '_' + key +'_'+ reader.Catalog__c, reader);
            }
        }        
        if(opt == 'opt2'){
            for(Catalog_Item_Permission__c reader : [select id, Catalog__c, Catalog_Item__c, Department__c, Function__c, IDP_Policy__c,
                                                           isCatalogItemLevel__c, isCatalogLevel__c, isDepartmentLevel__c, isUserLevel__c, 
                                                           User__c, Function_Department__c
                                                           from Catalog_Item_Permission__c
                                                           where User__c in :userList
                                                           and Catalog__c in :catalogList
                                                          ]){
                cip.put(reader.User__c +'_'+ reader.Catalog__c, reader);
            }
        }
        if(opt == 'opt3'){
            for(Catalog_Item_Permission__c reader : [select id, Catalog__c, Catalog_Item__c, Department__c, Function__c, IDP_Policy__c,
                                                           Catalog__r.display_name__c, Catalog__r.Parent_Catalog__r.display_name__c,
                                                           isCatalogItemLevel__c, isCatalogLevel__c, isDepartmentLevel__c, isUserLevel__c, 
                                                           User__c, Function_Department__c
                                                           from Catalog_Item_Permission__c
                                                           where User__c in :userList
                                                           and Catalog_Item__c in :itemList
                                                          ]){
                cip.put(reader.User__c +'_'+ reader.Catalog_Item__c, reader);
            }
        }
        return cip;
    }
 
    Public Boolean validation(){
        msg = '';
        if(permissionMatrixSelect == 'opt1'){

            depSelect = depSelect.replaceAll(REPLACE, '');

            catalogSelect = catalogSelect.replaceAll(REPLACE, '');
            if(String.isblank(policySelect) || String.isblank(depSelect) || String.isblank(catalogSelect)){
                msg = 'Please fill in all required fields';
                return false;  
            }
        }
        if(permissionMatrixSelect == 'opt2'){
            userSelect = userSelect.replaceAll(REPLACE, '');
            catalogSelect = catalogSelect.replaceAll(REPLACE, '');
            if(String.isblank(userSelect) || String.isblank(catalogSelect)){
                msg = 'Please fill in all required fields';
                return false;  
            }
        }
        if(permissionMatrixSelect == 'opt3'){
            userSelect = userSelect.replaceAll(REPLACE, '');
            catalogItemSelect = catalogItemSelect.replaceAll(REPLACE, '');
            if(String.isblank(userSelect) || String.isblank(catalogItemSelect)){
                msg = 'Please fill in all required fields';
                return false;  
            }
        }
        return true;
    }
    
    Public void save(){
        
        system.debug(logginglevel.ERROR, 'save() tableMap:' + tableMap);

        system.debug(logginglevel.ERROR, 'save() policySelect:' + policySelect);
        
        Set<String> removeKeySet = new Set<String> ();
        List <Catalog_Item_Permission__c> newCIP = new List <Catalog_Item_Permission__c>();
        List <Catalog_Item_Permission__c> delCIP = new List <Catalog_Item_Permission__c>();
        List <String> keyList = new List <String>();
        List <String> depList = new List <String>();
        Map <String, Boolean> row = null;
        Map <String, Boolean> allResult = new Map <String, Boolean>();
        Map<String, Catalog_Item_Permission__c> tmpKeyNewCIPMap = new Map<String, Catalog_Item_Permission__c>();  
        String function, department, catalog, catalogItem, usr;
        String catkey = '';
        String tmpKey = '';
        
                
        for(String rowkey : tableMap.keySet()){
             row = tableMap.get(rowkey);
             for (String colkey : row.keySet()){
                 catkey = '';
                 if(permissionMatrixSelect == 'opt1'){
                     catkey = policySelect + '_';
                 }
                 catkey += rowkey + '_' + colkey;
                 allResult.put(catkey, row.get(colkey));
                 //allResult.put(rowkey + '_' + colkey, row.get(colkey));
             }
        }
        
        for(String key : allResult.keySet()){
            //if(CatalogItemPermission.containskey(key) && !allResult.get(key)){
            if(CatalogItemPermission.containskey(key)){
                delCIP.add(CatalogItemPermission.get(key));
            }
        }
        
        system.debug(logginglevel.ERROR, 'save() allResult:'+allResult);

        for(String key : allResult.keySet()){
            if (allResult.get(key)){
                if(permissionMatrixSelect == 'opt1'){
                    System.debug('*******'+key);
                    keyList = key.split('_');
                    depList = keyList[1].split('-');
                    function = depList[0];
                    department = '';
                    if(depList.size() == 2){
                        department = depList[1];
                    }
                    catalog = keyList[2];
                    newCIP.add(new Catalog_Item_Permission__c(IDP_policy__c = policySelect, function__c = function, department__c = department, catalog__c = catalog, isCatalogLevel__c = true, isDepartmentLevel__c = true));
                }
                if(permissionMatrixSelect == 'opt2'){
                    keyList = key.split('_');
                    usr = keyList[0];
                    catalog = keyList[1];
                    tmpKey = usr + '_' + leveltwoCatalogIdLevelOneCatalogIdMap.get(catalog); 
                    
                    newCIP.add(new Catalog_Item_Permission__c(user__c = usr, catalog__c = catalog, isUserLevel__c = true, isCatalogLevel__c = true));
                }
                if(permissionMatrixSelect == 'opt3'){
                        keyList = key.split('_');
                        usr = keyList[0];
                        catalogItem = keyList[1]; 
                        newCIP.add(new Catalog_Item_Permission__c(user__c = usr, Catalog_Item__c = catalogItem, isCatalogItemLevel__c = true, isUserLevel__c = true));
                }
            }
        }
        
        for(Catalog_Item_Permission__c cip : newCIP) {
            if(permissionMatrixSelect == 'opt1'){
                tmpKeyNewCIPMap.put(cip.IDP_Policy__c + '_' + cip.Function__c +'-' + cip.Department__c + '_' + cip.Catalog__c, cip);
            }
            
            if(permissionMatrixSelect == 'opt2'){
                tmpKeyNewCIPMap.put(cip.User__c + '_' + cip.Catalog__c, cip);
            }
            if(permissionMatrixSelect == 'opt3'){
                tmpKeyNewCIPMap.put(cip.User__c + '_' + cip.Catalog_Item__c,cip);
            }
        }
        
        Set<String> catalogIdSet = new Set<String> ();
        for(Catalog_Item_Permission__c cip : newCIP) {
            if(cip.isCatalogLevel__c) {
                catalogIdSet.add(cip.Catalog__c);
            }
        }
        
        leveltwoCatalogIdLevelOneCatalogIdMap = new Map<String, String> ();
        for(Catalog__c reader : [SELECT Id, Parent_Catalog__c FROM Catalog__c WHERE Id in: catalogIdSet]) {
            if(reader.Parent_Catalog__c !=null) {
                leveltwoCatalogIdLevelOneCatalogIdMap.put(reader.Id, reader.Parent_Catalog__c);
            }
        }

        for(Catalog_Item_Permission__c cip: tmpKeyNewCIPMap.values()) {
                tmpKey = '';
                if(permissionMatrixSelect == 'opt1'){
                    if(leveltwoCatalogIdLevelOneCatalogIdMap.containsKey(cip.Catalog__c)) {
                        tmpKey = cip.IDP_Policy__c + '_' + cip.Function__c +'-' + cip.Department__c + '_' + leveltwoCatalogIdLevelOneCatalogIdMap.get(cip.Catalog__c);
                        if(tmpKeyNewCIPMap.containsKey(tmpKey)) {
                            tmpKey = cip.IDP_Policy__c + '_' + cip.Function__c +'-' + cip.Department__c + '_' + cip.Catalog__c;
                            removeKeySet.add(tmpKey);
                        }
                    }
                }
                if(permissionMatrixSelect == 'opt2'){
                    if(leveltwoCatalogIdLevelOneCatalogIdMap.containsKey(cip.Catalog__c)) {
                        tmpKey = cip.User__c + '_' + leveltwoCatalogIdLevelOneCatalogIdMap.get(cip.Catalog__c);
                        if(tmpKeyNewCIPMap.containsKey(tmpKey)) {
                            tmpKey = cip.User__c + '_' + cip.Catalog__c;
                            removeKeySet.add(tmpKey);
                        }
                    }
                }
        }
        system.debug(CatalogItemPermission);
        system.debug(tmpKeyNewCIPMap);
        for(String removeKey : removeKeySet) {
            system.debug(removeKey );
            tmpKeyNewCIPMap.remove(removeKey);
        }

        newCIP = tmpKeyNewCIPMap.values();

        system.debug(logginglevel.ERROR, 'save() newCIP:' + newCIP);
        system.debug(logginglevel.ERROR, 'save() delCIP:' + delCIP);

        if(!delCIP.isempty()){
            delete delCIP;
        }
        if(!newCIP.isempty()){
            system.debug(newCIP);
            upsert newCIP;
            removeSubPermissions(newCIP);
        }
        result();
        isSave = true;

        

    }
    
    Public Boolean removeSubPermissions(List<Catalog_Item_Permission__c> cipList) {
        
        List<User> funcDepSubUserListtemp = new List<User> ();
        List<String> funcDepSubUserList = new List<String> ();

        List<Catalog_Item_Permission__c> upsertedCIPList = new List<Catalog_Item_Permission__c> ();
        List<Catalog_Item_Permission__c> toBeDeletedSubCIPList = new List<Catalog_Item_Permission__c> ();
        List<Catalog__c> subCataloglist = new List<Catalog__c> (); 
        List<Catalog_Item__c> subCatalogItemList = new List<Catalog_Item__c> ();
        List<String> upsertedCIPCataloglist = new List<String> (); 
        List<String> upsertedCIPFuncDepList = new List<String> ();
        List<String> upsertedCIPUserIdList = new List<String> ();
        List<String> uniqueKeyList = new List<String> ();
        String policyName = '';
        String tempKey = '';

        Boolean isSuccess = false;

        if(!cipList.isEmpty()) {
            upsertedCIPList = [SELECT Id, Catalog__c, User__c, Function_Department__c, Unique_Key__c 
                                FROM Catalog_Item_Permission__c
                                WHERE Id in :cipList];
        }
        //Get Selected IDP Policy Name
        for(SelectOption so : this.policyList) {
            if(so.getValue() == this.policySelect) {
                policyName = so.getLabel();
                break;
            }
        }

        //Get all updated permission related Catalog
        //Get all updated permission related Deparment and Function
        for(Catalog_Item_Permission__c cip : upsertedCIPList) {
            upsertedCIPCataloglist.add(cip.Catalog__c);
            if(permissionMatrixSelect == 'opt1'){
                upsertedCIPFuncDepList.add(cip.Function_Department__c);
            }
            else  if(permissionMatrixSelect == 'opt2' || permissionMatrixSelect == 'opt3'){
                upsertedCIPUserIdList.add(cip.User__c);
            }
        }

        //Handling the deletion related deparmentFunction - level two catalog permission

        //Get all related sub catalog , i.e. level two catalog
        if(!upsertedCipCataloglist.isEmpty()) {
            subCataloglist = [SELECT Id FROM Catalog__c WHERE Parent_Catalog__c in :upsertedCIPCataloglist];
        }

        if(!upsertedCipCataloglist.isEmpty()) {

            subCatalogItemlist = [SELECT Id 
                                    FROM Catalog_Item__c 
                                    WHERE Catalog__c in :subCataloglist 
                                    OR Catalog__c in :upsertedCIPCataloglist];


        }

        //Selected Department to Catalog Permission
        if(permissionMatrixSelect == 'opt1'){

            if(!subCataloglist.isEmpty()) {

                //Form the key and add them in the list
                //The key is Selected IDP Policy + '_' Function + '_' + Department + '_' + Level Two Catalog Id
                for(Catalog_Item_Permission__c cip : upsertedCIPList) {
                    for(Catalog__c cat : subCataloglist) {
                        tempKey = policyName + '_' + cip.Function_Department__c + '_' + String.valueOf(cat.Id).left(15);
                        uniqueKeyList.add(tempKey);
                    }
                }
            }

            //Handling the deletion sub User - catalog permission
            if(!upsertedCIPFuncDepList.isEmpty()) {
                for(User u : [SELECT Id, Function_Deparment__c  FROM User WHERE Function_Deparment__c in : upsertedCIPFuncDepList]) {
                    funcDepSubUserList.add(String.valueOf(u.Id));
                }
            }

            if(!funcDepSubUserList.isEmpty()) {
                uniqueKeyList.addAll(removeSubUserToCatalogPermissionUniqueKey(funcDepSubUserList, subCataloglist));
            }

            //Handling the deletion sub User - catalog item permission
            if(!funcDepSubUserList.isEmpty() && !subCatalogItemlist.isEmpty()) {
                uniqueKeyList.addAll(getSubUserToCatalogItemPermissionUniqueKey(funcDepSubUserList, subCatalogItemlist));
            }
        }
        //Selected User to Catalog Permission
        if(permissionMatrixSelect == 'opt2'){
            //Handling the deletion sub User - catalog permission
            if(!upsertedCIPUserIdList.isEmpty() && !subCataloglist.isEmpty()) {
                uniqueKeyList.addAll(removeSubUserToCatalogPermissionUniqueKey(upsertedCIPUserIdList, subCataloglist));
            }

            //Handling the deletion sub User - catalog item permission
            if(!upsertedCIPUserIdList.isEmpty() && !subCatalogItemlist.isEmpty()) {
                uniqueKeyList.addAll(getSubUserToCatalogItemPermissionUniqueKey(upsertedCIPUserIdList, subCatalogItemlist));
            }

        }

        if(!uniqueKeyList.isEmpty()) {
            toBeDeletedSubCIPList = [SELECT Id , Unique_Key__c from Catalog_Item_Permission__c WHERE Unique_Key__c in : uniqueKeyList];
            if(!toBeDeletedSubCIPList.isEmpty()) {
                delete toBeDeletedSubCIPList;
            }
             
            System.debug('uniqueKeyList:---------' + uniqueKeyList);
            System.debug('toBeDeletedSubCIPList: ' + toBeDeletedSubCIPList);
            System.debug('toBeDeletedSubCIPList size: ' + toBeDeletedSubCIPList.size());
        }
        return isSuccess;
    }

    private List<String> removeSubUserToCatalogPermissionUniqueKey(List<String> pUserIdList, List<Catalog__c> pCatalogList) {
        
        List<String> tempUniqueKeyList = new List<String> ();
        String tempkey = '';

        for(String userId : pUserIdList) {
            for(Catalog__c cat : pCatalogList) {
                    tempKey = '';
                    tempKey = String.valueOf(userId).left(15) + '_' + String.valueOf(cat.Id).left(15);
                    tempUniqueKeyList.add(tempKey);
            }
        }

        return tempUniqueKeyList;
    }

    private List<String> getSubUserToCatalogItemPermissionUniqueKey(List<String> pUserIdList, List<Catalog_Item__c> pCatalogItemList) {
        
        List<String> tempUniqueKeyList = new List<String> ();
        String tempkey = '';

        for(String userId : pUserIdList) {
            for(Catalog_Item__c item : pCatalogItemList) {
                tempKey = '';
                tempKey = String.valueOf(userId).left(15) + '_' + String.valueOf(item.Id).left(15);
                
                tempUniqueKeyList.add(tempKey);
            }
        }

        return tempUniqueKeyList;
    }

    Public List<string> validationEmployeeRecords(List<String> pUserIdList) {
    //Public Boolean validationEmployeeRecords(List<String> pUserIdList) {

        Map<string, Employee__c> tmpUserIdEmployeeMap = new Map<string, Employee__c>();
        List<String> tmpValidUserIdList = new List<String> ();
        //String noEmployeeUserName = '';
        String fieldErrorUserName = '';

        
        for(Employee__c reader :[SELECT Id, User__c, IDP_Policy__c, Function__c, Department__c FROM employee__c WHERE User__c in :pUserIdList]) {
            tmpUserIdEmployeeMap.put(reader.User__c, reader);
        }
        for(String userId :pUserIdList) {
            if(tmpUserIdEmployeeMap.containsKey(userId)) {
                if(tmpUserIdEmployeeMap.get(userId).IDP_Policy__c == null || 
                    String.isBlank(tmpUserIdEmployeeMap.get(userId).Function__c) || 
                    String.isBlank(tmpUserIdEmployeeMap.get(userId).Department__c) ) {
                    fieldErrorUserName += userTranslate.get(userId) + ', ';
                }
                else {
                    tmpValidUserIdList.add(userId);
                }
            }
            else {
                fieldErrorUserName += userTranslate.get(userId) + ', ';
            }
        }
        if(!String.isBlank(fieldErrorUserName)) {
            fieldErrorUserName += '@';
            fieldErrorUserName = fieldErrorUserName.replace(', @', '');          
            msg = 'The following user(s) does/do not set up the Employee record(s) (IDP Policy/ Function/ Department): ' + fieldErrorUserName;
//            tmpShowResult = false;
        }
        
        return tmpValidUserIdList;
        
//        Boolean tmpShowResult = true;
        
        
        /*
        for(Employee__c reader :[SELECT Id, User__c, IDP_Policy__c, Function__c, Department__c FROM employee__c WHERE User__c in :pUserIdList]) {
            tmpUserIdEmployeeMap.put(reader.User__c, reader);
            if(reader.IDP_Policy__c == null || String.isBlank(reader.Function__c) || String.isBlank(reader.Department__c) ) {
                fieldErrorUserName += userTranslate.get(reader.User__c) + ', ';
            }
            
        }
        
        
        if(!String.isBlank(fieldErrorUserName)) {
            fieldErrorUserName += '@';
            fieldErrorUserName = fieldErrorUserName.replace(', @', '');          
            msg = 'The following user(s) does/do not set up the IDP Policy/ Function/ Department: ' + fieldErrorUserName;
            msg += '<Br/><Br/>';
            tmpShowResult = false;
        }

                
        for(String userId :pUserIdList) {
            if(!tmpUserIdEmployeeMap.containsKey(userId)) {
                noEmployeeUserName += userTranslate.get(userId) + ', ';
            }
        }
  
        
        if(!String.isBlank(noEmployeeUserName)) {
            noEmployeeUserName += '@';
            noEmployeeUserName = noEmployeeUserName.replace(', @', '');      
            msg += 'The following user(s) does/do not have employee records: ' + noEmployeeUserName;
            tmpShowResult = false;
        }
        */        
        
    }
    
        
    //*/
}