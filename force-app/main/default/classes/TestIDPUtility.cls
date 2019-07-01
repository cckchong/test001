public virtual class TestIDPUtility {
    
 //   public static Map<String, Currency__c> currencyMap;
 //   public static Map<String, Supplier__c> supplierMap;
 //   public static Map<String, Catalog__c> catalogAllMap;
 //   public static Map<String, Catalog_Item__c> catalogItemMap;
 //   public static Map<String, User> userMap;
 //   public static Map<String, Site__c> siteMap;
 //   public static Map<String, Employee__c> employeeMap;
 //   public static Map<String, Employee_Administrator__c> employeeAdministratorMap;
 //   public static Map<String, IDP_Policy__c> idpPolicyMap;
 //   public static Map<String, Catalog_Policy_Setting__c> catalogPolicySettingMap;
 //   public static Map<String, Budget__c> budgetMap;
 //   public static Map<String, Expense_Catalog__c> expenseCategoryMap;

    public static Map<String, Map<String, sObject>> prepare(boolean isSeeAllData) {
        return prepare(isSeeAllData, true);
    }

    public static Map<String, Map<String, sObject>> prepare(boolean isSeeAllData, boolean isPrepareCatalogPermission) {
        TestIDPPreparation idpPrepare = new TestIDPPreparation(isSeeAllData);
        idpPrepare.idpPreparation(isSeeAllData);

        if (isPrepareCatalogPermission) {
            idpPrepare.prepareCatalogPermission();
        }

        Map<String, Map<String, sObject>> preparedMap = new Map<String, Map<String, sObject>>();
        preparedMap.put('currencyMap', idpPrepare.currencyMap);
        preparedMap.put('supplierMap', idpPrepare.supplierMap);
        preparedMap.put('catalogAllMap', idpPrepare.catalogAllMap);
        preparedMap.put('catalogItemMap', idpPrepare.catalogItemMap);
        preparedMap.put('userMap', idpPrepare.userMap);
        preparedMap.put('siteMap', idpPrepare.siteMap);
        preparedMap.put('employeeMap', idpPrepare.employeeMap);
        preparedMap.put('employeeAdministratorMap', idpPrepare.employeeAdministratorMap);
        preparedMap.put('idpPolicyMap', idpPrepare.idpPolicyMap);
        preparedMap.put('catalogPolicySettingMap', idpPrepare.catalogPolicySettingMap);
        preparedMap.put('budgetMap', idpPrepare.budgetMap);
        //preparedMap.put('expenseCategoryMap', idpPrepare.expenseCategoryMap);

        return preparedMap;
    }

    public static Map<String, Currency__c> getCurrencyMap() {
        Map<String, Currency__c> currencyMap = new Map<String, Currency__c>();
        for (Currency__c c : [select Id, Name, Description__c, keyword__c, Is_Budget_Currency__c from Currency__c]) {
            currencyMap.put(c.Name, c);
        }
        return currencyMap;
    }

    public static Map<String, Supplier__c> getSupplierMap() {
        Map<String, Supplier__c> supplierMap = new Map<String, Supplier__c>();
        for(Supplier__c reader : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Supplier_Name__c, Supplier_Code__c, Supplier_Type__c, Status__c,   Tel_Number_1__c,  Currency__c, Remark__c, Tel_Number_2__c, Country_Code__c, Keyword__c, Fax_Number__c, Postal_Address__c, Delivery_Method__c, Payment_Method__c, Payment_Terms__c, Media_Profile__c, Telex_Number__c, City__c, State__c, Postal_Code__c, Country__c, Delivery_Terms__c, Tax__c FROM Supplier__c]) {
            supplierMap.put(reader.Supplier_Name__c, reader);
        }
        return supplierMap;
    }

    public static Map<String, Catalog__c> getCatalogAllMap() {
        Map<String, Catalog__c> catalogAllMap = new Map<String, Catalog__c>();
        for(Catalog__c reader : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Parent_Catalog__c,  Catalog_Code__c, Catalog_Name__c,  Description__c, Display_Name__c, Tech_Is_Owner__c, Parent_Catalog_Name__c, ROI_Approver__c, C_Level_Approver__c, Tech_Catalog_Owner_Queue_Name__c FROM Catalog__c]) {
            catalogAllMap.put(reader.Catalog_Name__c, reader);
        }
        return catalogAllMap;
    }

    public static Map<String, Catalog_Item__c> getCatalogItemMap() {
        Map<String, Catalog_Item__c> catalogItemMap = new Map<String, Catalog_Item__c>();
        for (Catalog_Item__c ci : [SELECT Id, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Catalog_Name__c,  Tech_Keyword_1__c, Description__c, Catalog__c, Reference_Price__c, Last_Supplier__c, Expiry_Date__c, Fixed_Asset__c, Item_Name__c, Photo_Name__c, Currency__c, Status__c, Is_Catalog__c, Photo_Doc_Id__c, Tech_Keyword_2__c, Tech_Keyword_3__c, Tech_Keyword_4__c, Tech_Keyword_5__c, Tech_Keyword_6__c, Tech_Keyword_7__c, Photo_Link__c, Photo_Display__c, Tech_Created_By__c, Tech_Is_Created_By__c, Min_Std_Price__c, Unit_Of_Measure__c, Minimum_Order_Quantity__c, Lead_Time_Days__c, Lead_Time_Format__c FROM Catalog_Item__c]) {
            catalogItemMap.put(ci.Item_Name__c, ci);
        }
        return catalogItemMap;
    }

    public static Map<String, User> getUserMap() {
        Map<String, User> userMap = new Map<String, User>();
        for (User user : [SELECT Id, Alias From User]) {
            userMap.put(user.Alias, user);
        }
        return userMap;
    }

    public static Map<String, Site__c> getSiteMap() {
        Map<String, Site__c> siteMap = new Map<String, Site__c>();
        for (Site__c site : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Site_ID__c, Admin_Email__c, keyword__c, Address__c, Warehouse__c, Tolerance_Level__c FROM Site__c]) {
            siteMap.put(site.Name, site);
        }
        return siteMap;
    }

    public static Map<String, Employee__c> getEmployeeMap() {
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
        for (Employee__c emp : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Staff_Card_ID__c, User__c, First_Name__c, tempID__c, Last_Name__c, Full_Name__c, Acting_Approver_1__c, Acting_Approver_2__c, Acting_Approver_3__c, Acting_Approver_4__c, Acting_Approvers_Updated__c, Approver_1__c, Approver_2__c, Approver_3__c, Approver_4__c, Delegation_Approval__c, Department__c, Employee_Department__c, Employee_ID__c, Employee_Type__c, Full_Department__c, Grade__c, I_Am_Acting_Approver__c, I_Am_Approver__c, Is_Active__c, Leave_Bypass_Approvals__c, Leave_Policy_Name__c, Leave_Policy__c, Notif_Leave_Forfeiture__c, Original_Employee_ID__c, Site__c, Tech_Name__c, Temp_Acting_Approver_1__c, Temp_Acting_Approver_2__c, Temp_Acting_Approver_3__c, Temp_Acting_Approver_4__c, Timeset__c, User_Updated__c, keyword__c, Tech_EMP_NUM__c, User_Email__c, Tech_User_Mapping__c, Tech_User_EMP_NUM__c, Bypass_Education_Application_Approvals__c, Bypass_Expense_Claims_Approvals__c, Bypass_Travel_Application_Approvals__c, Division__c, Education_Policy__c, Expense_Policy__c, Flight_Class__c, Frequent_Flyer_Membership_No__c, Frequent_Flyer_No_1__c, Frequent_Flyer_No_2__c, Frequent_Flyer_No_3__c, Frequent_Flyer_Program_1__c, Frequent_Flyer_Program_2__c, Frequent_Flyer_Program_3__c, Gender__c, Is_Driver__c, Mobile__c, Nationality__c, Passport_Expiry_Date_1__c, Passport_Expiry_Date_2__c, Passport_Expiry_Date_3__c, Passport_Full_Name_2__c, Passport_Full_Name_3__c, Passport_Full_Name__c, Passport_Issue_Date_1__c, Passport_Issue_Date_2__c, Passport_Issue_Date_3__c, Passport_No_1__c, Passport_No_2__c, Passport_No_3__c, Preferred_Seat__c, TAL_Direct_Line__c, Tech_Grade__c, Travel_Policy__c, Active_Approver__c, Nationality_2__c, Nationality_3__c, tmp_Passport_Type_1__c, tmp_Passport_Type_2__c, tmp_Passport_Type_3__c, Passport_Type_1__c, Passport_Type_2__c, Passport_Type_3__c, IDP_Policy__c, Department_Code__c, Function_Code__c, Function__c, Section_Code__c, Section__c, Tech_Policy_Function_Department__c, Tech_Policy_Function_Department_Section__c, Tech_IDP_Policy_Function_Department__c FROM Employee__c]) {
            employeeMap.put(emp.Name, emp);
        }
        return employeeMap;
    }

    public static Map<String, Employee_Administrator__c> getEmployeeAdministratorMap() {
        Map<String, Employee_Administrator__c> employeeAdministratorMap = new Map<String, Employee_Administrator__c>();
        for (Employee_Administrator__c empAdmin : [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp,Employee__r.Name, Administrator__c, Employee_Administrator__c, Employee_Department__c, Employee_Full_Name__c, Employee_ID_and_Administrator_ID__c, Employee_UserId__c, Employee__c, Is_Active__c, Is_Employee_Active__c, Is_Mine__c, Is_Self__c, Keyword__c, Leave_Policy_Name__c, On_Behalf_of_Grade__c, Is_User_Active__c, Is_Employee_User_Active__c, Application__c, Tech_Application__c FROM Employee_Administrator__c]) {
            employeeAdministratorMap.put(empAdmin.Employee__r.Name, empAdmin);
        }
        return employeeAdministratorMap;
    }

    public static Map<String, IDP_Policy__c> getIdpPolicyMap() {
        Map<String, IDP_Policy__c> idpPolicyMap = new Map<String, IDP_Policy__c>();
        for (IDP_Policy__c idpPolicy : [SELECT Name, Is_Group_Procurement__c FROM IDP_Policy__c]) {
            idpPolicyMap.put(idpPolicy.Name, idpPolicy);
        }
        return idpPolicyMap;
    }

    public static Map<String, Catalog_Policy_Setting__c> getCatalogPolicySettingMap() {
        Map<String, Catalog__c> catalogAllMap = getCatalogAllMap();
        Map<String, IDP_Policy__c> idpPolicyMap = getIdpPolicyMap();
        Map<String, Catalog_Policy_Setting__c> catalogPolicyMap = new Map<String, Catalog_Policy_Setting__c>();
        for (Catalog_Policy_Setting__c catalogPolicy : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Catalog__c, IDP_Policy__c, First_Threshold__c, Second_Threshold__c,  PR_Amount_Tier_Currency__c, Approval_Workflow__c, Catalog_Name__c FROM Catalog_Policy_Setting__c]) {
            String catalogName = '';
            for (String catalogKey : catalogAllMap.keySet()) {
                if (catalogAllMap.get(catalogKey).Id == catalogPolicy.Catalog__c) {
                    catalogName = catalogKey;
                    break;
                }
            }

            String policyName = '';
            for (String policyKey : idpPolicyMap.keySet()) {
                if (idpPolicyMap.get(policyKey).Id == catalogPolicy.IDP_Policy__c) {
                    policyName = policyKey;
                    break;
                }
            }

            String key = catalogName + '_' + policyName;
            catalogPolicyMap.put(key, catalogPolicy);
        }
        return catalogPolicyMap;
    }

    public static Map<String, IDP_Budget__c> getBudgetMap() {
        Map<String, IDP_Budget__c> budgetMap = new Map<String, IDP_Budget__c>();
        
        for (IDP_Budget__c budget : [ SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById,
         LastModifiedDate, LastModifiedById, SystemModstamp, LastViewedDate, LastReferencedDate, Type__c, Catalog_Name__c, 
         Currency__c, is_Yearly_Budget__c, Ext_ID__c, Year__c, Catalog__c, Site__c, Jan_Budget__c, Jan_Used_Budget__c, 
         Jan_Reserve_Budget__c, Feb_Budget__c, Feb_Reserve_Budget__c, Feb_Used_Budget__c, Section_Code__c, Department_Code__c,
         Function_Code__c, Jan_Remaining_Budget__c, Feb_Remaining_Budget__c, Year_Remaining_Budget__c,
         Current_Month_Remaining_Budget__c, Mar_Budget__c, Apr_Budget__c, May_Budget__c, Jun_Budget__c, Jul_Budget__c,
         Aug_Budget__c, Sept_Budget__c, Oct_Budget__c, Nov_Budget__c, Dec_Budget__c, Mar_Reserve_Budget__c, Apr_Reserve_Budget__c, 
         May_Reserve_Budget__c, Jun_Reserve_Budget__c, Jul_Reserve_Budget__c, Aug_Reserve_Budget__c, Sept_Reserve_Budget__c,
         Oct_Reserve_Budget__c, Nov_Reserve_Budget__c, Dec_Reserve_Budget__c, Mar_Used_Budget__c, Apr_Used_Budget__c, 
         May_Used_Budget__c, Jun_Used_Budget__c, Jul_Used_Budget__c, Aug_Used_Budget__c, Sept_Used_Budget__c, Oct_Used_Budget__c,
         Nov_Used_Budget__c, Dec_Used_Budget__c, Mar_Remaining_Budget__c, Dec_Remaining_Budget__c, Apr_Remaining_Budget__c, 
         May_Remaining_Budget__c, Jun_Remaining_Budget__c, Jul_Remaining_Budget__c, Aug_Remaining_Budget__c,
         Sept_Remaining_Budget__c, Oct_Remaining_Budget__c, Nov_Remaining_Budget__c, Current_Month_Budget__c, 
         Current_Month_Used_Budget__c, Current_Month_Reserve_Budget__c, Year_Budget__c, Year_Reserve_Budget__c, 
         Year_Used_Budget__c, Year_Budget_by_Year__c, Year_Reserve_Budget_by_Year__c, Year_Used_Budget_by_Year__c, 
         Year_Remaining_Budget_by_Year__c, Jan_Budget_by_Year__c, Feb_Budget_by_Year__c, Mar_Budget_by_Year__c, 
         Apr_Budget_by_Year__c, May_Budget_by_Year__c, Jun_Budget_by_Year__c, Jul_Budget_by_Year__c, Aug_Budget_by_Year__c, 
         Sept_Budget_by_Year__c, Oct_Budget_by_Year__c, Nov_Budget_by_Year__c, Dec_Budget_by_Year__c
        FROM IDP_Budget__c]
        ) {
            budgetMap.put(budget.Name, budget);
        }
        
        return budgetMap;
    }
    /*
    public static Map<String, Expense_Category__c> getExpenseCategoryMapMap() {
        Map<String, Expense_Category__c> expenseCatalogMap = new Map<String, Expense_Category__c>();
        for (Expense_Category__c ec : [SELECT Id, OwnerId, IsDeleted, Name, RecordTypeId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp FROM Expense_Category__c]) {
            expenseCatalogMap.put(ec.Name, ec);
        }
        return expenseCatalogMap;
    }
*/

    public static void log(String msg) {
        system.debug(logginglevel.ERROR, msg);
    }

    public static void putParam(String key, String val) {
        ApexPages.currentPage().getParameters().put(key, val);
    }

    private class testJSONObject {

        public String catalogItemId {set;get;}
        public Boolean checked{get;set;}
        public String quantity{get;set;}
        public String unitOfMeasure{get;set;}
    }

    public static String prepareJSONStringData(Map<String, Catalog_Item__c> pCatalogItemMap, Boolean isIdwithUOM) {
        
        List<testJSONObject> jsonObjectList = new List<testJSONObject> ();
        String itemName = '';
        String testJSONString = '';
        testJSONObject obj = null;
        JSONGenerator gen = JSON.createGenerator(true);     

    
        for(Integer i=1; i<5; i++){
            itemName = 'Administration_Motor Vehicles_Item_' + i;

            obj = new testJSONObject();

            obj.catalogItemId = pCatalogItemMap.get(itemName).Id;
            if(isIdwithUOM) {
             obj.catalogItemId += '_' + pCatalogItemMap.get(itemName).Unit_of_Measure__c;
            }
            obj.checked = true;
            obj.quantity ='4';
            obj.unitOfMeasure =  pCatalogItemMap.get(itemName).Unit_of_Measure__c;

            jsonObjectList.add(obj);

        }
        gen.writeStartObject();

        gen.writeObjectField('editedCatalogItemList',jsonObjectList);
        gen.writeEndObject();

        testJSONString = gen.getAsString();

        return testJSONString;
    }

}