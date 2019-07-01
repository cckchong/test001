public class TestIDPUserPreparation extends TestEleavePreparation{

    //user dateSet
    public Map<String, User> UserMap {get;set;}
    public Map<String, Employee__c> EmployeeMap {get;set;}
    public Map<String, Employee_Administrator__c> EmployeeAdministratorMap {get;set;}
    public Map<String, Site__c> siteMap;
    public Map<String, IDP_Policy__c> idpPolicyMap;
    public Map<String, Currency__c> currencyMap;
    public Map<String, Expense_Policy__c> expensePolicyMap;

    public TestIDPUserPreparation( Boolean isSeeAllData, Map<String, Site__c> siteMap, Map<String, IDP_Policy__c> idpPolicyMap, Map<String, Currency__c> currencyMap){
        super(isSeeAllData);
        initVariable(siteMap, idpPolicyMap, currencyMap);
    }

    Public void initVariable(Map<String, Site__c> siteMap, Map<String, IDP_Policy__c> idpPolicyMap, Map<String, Currency__c> currencyMap) {
        this.UserMap = new Map<String,User> ();
        this.EmployeeMap = new Map<String, Employee__c> ();
        this.EmployeeAdministratorMap = new Map<String, Employee_Administrator__c> ();
        this.ExpensePolicyMap = new Map<String, Expense_Policy__c> ();
        this.siteMap = siteMap;
        this.idpPolicyMap = idpPolicyMap;
        this.currencyMap = currencyMap;
    }

    Public void idpBasicSetting() {

        this.ExpensePolicyMap = getExpensePolicyMap();
        this.UserMap = getIDPUserMap();
        this.EmployeeMap = getIDPEmployeeMap();
        this.EmployeeAdministratorMap = getIDPEmployeeAdministratorMap();
        

        system.debug('ExpensePolicyMap:'+ExpensePolicyMap);


    }
    public Map<String, User> getIDPUserMap() {

        system.debug(logginglevel.ERROR, 'u0: '+system.now());

        Map <String, User> UserMap = new Map<String, User> ();
        List <PermissionSetAssignment> PermissionSetAssignmentList = new List <PermissionSetAssignment>();
        //List <ID> groupIDList = new List <ID>();
        Map<String, Id> groupMap = new Map<String, Id> ();
        List <GroupMember> userGroupList = new List <GroupMember>();
        Map<String, Id> permissionSetMap = new Map<String, Id>();
        //List <String> Permission_SetID = new List <String>();

        String user_ProfileName = 'TAL FE Standard Platform User'; 
        String Admin_ProfileName = 'System Administrator'; 
        String Permission_Set = 'Leave_User_Prod';
        String IDP_Permission_Set = 'IDP_%';
        String TE_GROUP_NAME = 'TE_%_%';
        String HCM_GROUP_NAME = 'ELE_%_Admin';
        String IDP_GROUP_NAME = 'IDP_%';
        String IDP_CATALOG_ADMIN_GROUP_NAME = 'IDP_Catalog_Administration';
        String IDP_PURCHASER_TAA_GROUP_NAME = 'IDP_TAA_Procurement';
        String IDP_PERMISSION_USER = 'IDP_User';
        STring IDP_PERMISSION_CATALOG_OWNER = 'IDP_Catalog_Owner';
        String USER_PHYSICAL_DELIVERY_ADDRESS_HKO = 'HKO';
        String USER_PHYSICAL_DELIVERY_ADDRESS_TAA = 'TAA';

        String Admin_Email = 'admin@testclass.com';        
        String Admin_Alias = 'admin';         
        
        String user1_Email = 'user1@testclass.com';        
        String user1_Alias = 'user1'; 
        
        String approver1_Email = 'approver1@testclass.com';        
        String approver1_Alias = 'apr1'; 
        
        String approver2_Email = 'approver2@testclass.com';        
        String approver2_Alias = 'apr2'; 
        
        String approver3_Email = 'approver3@testclass.com';        
        String approver3_Alias = 'apr3'; 
        
        String approver4_Email = 'approver4@testclass.com';        
        String approver4_Alias = 'apr4'; 
        
        String actingapprover1_Email = 'actingapprover1@testclass.com';        
        String actingapprover1_Alias = 'actapr1'; 
         
        String actingapprover2_Email = 'actingapprover2@testclass.com';        
        String actingapprover2_Alias = 'actapr2'; 
        
        String actingapprover3_Email = 'actingapprover3@testclass.com';        
        String actingapprover3_Alias = 'actapr3'; 
        
        String actingapprover4_Email = 'actingapprover4@testclass.com';        
        String actingapprover4_Alias = 'actapr4'; 

        String catalogOwnerUser_Email = 'COUser@testclass.com';        
        String catalogOwnerUser_Alias = 'COUser';    

        String user2_Email = 'user2@testclass.com';        
        String user2_Alias = 'user2'; 

        String approver1TAA_Email = 'approver1TAA@testclass.com';        
        String approver1TAA_Alias = 'apr1T'; 
        
        String approver2TAA_Email = 'approver2TAA@testclass.com';        
        String approver2TAA_Alias = 'apr2T'; 
        
        String approver3TAA_Email = 'approver3TAA@testclass.com';        
        String approver3TAA_Alias = 'apr3T'; 
        
        String approver4TAA_Email = 'approver4@TAAtestclass.com';        
        String approver4TAA_Alias = 'apr4T'; 
        
        String actingapprover1TAA_Email = 'actingapprover1TAA@testclass.com';        
        String actingapprover1TAA_Alias = 'actapr1T'; 
         
        String actingapprover2TAA_Email = 'actingapproverTAA@testclass.com';        
        String actingapprover2TAA_Alias = 'actapr2T'; 
        
        String actingapprover3TAA_Email = 'actingapprover3TAA@testclass.com';        
        String actingapprover3TAA_Alias = 'actapr3T'; 
        
        String actingapprover4TAA_Email = 'actingapprover4TAA@testclass.com';        
        String actingapprover4TAA_Alias = 'actapr4T'; 

        String purchaserUser_Email = 'purch@testclass.com';        
        String purchaserUser_Alias = 'purch';        

        String cLevel_Email = 'clevel@testclass.com';        
        String cLevel_Alias = 'clevel';  

        String roiUser_Email = 'roiUser@testclass.com';        
        String roiUser_Alias = 'roiUser';  

        system.debug(logginglevel.ERROR, 'u1: '+system.now());

        for ( PermissionSet reader : [select id, Name from PermissionSet WHERE Name like :IDP_Permission_Set and LicenseId = null]){
            permissionSetMap.put(reader.Name, reader.Id);
            system.debug(logginglevel.ERROR, 'u8: '+permissionSetMap);
        }

        system.debug(logginglevel.ERROR, 'u2: '+system.now());

        for(Group reader : [select id, DeveloperName from Group where DeveloperName like :IDP_GROUP_NAME]){
            groupMap.put(reader.DeveloperName, reader.Id);
        }
        
        systemAdminprofile = [ SELECT Id FROM Profile WHERE Name = :Admin_ProfileName ];
        
        system.debug(logginglevel.ERROR, 'u3: '+system.now());

        Profile talFEStdPlatformUserprofile = [ SELECT Id FROM Profile WHERE Name = :user_ProfileName ];        
        User adminUser = userCreation ( Admin_Alias, Admin_Email, systemAdminprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        adminUser.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;
        UserMap.put (adminUser.Alias, adminUser);
        

        //-----------------------------------HKO------------------------------------------//


        //HKO Requestor
        User user = userCreation ( user1_Alias, user1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        user.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (user.Alias, user );
        
        //HKO IM Approver
        User approver1 = userCreation ( approver1_Alias, approver1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver1.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (approver1.Alias, approver1);
        
        //HKO VP 
        User approver2 = userCreation ( approver2_Alias, approver2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver2 .Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (approver2.Alias, approver2);
    
        User actingapprover1 = userCreation ( actingapprover1_Alias, actingapprover1_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover1.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (actingapprover1.Alias, actingapprover1 );
        
        User actingapprover2 = userCreation ( actingapprover2_Alias, actingapprover2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover2.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (actingapprover2.Alias, actingapprover2 );
        
        
        //Admin CatalogOwner
        User catalogOwner = userCreation ( catalogOwnerUser_Alias, catalogOwnerUser_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        catalogOwner.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (catalogOwner.Alias, catalogOwner);
        
        //-----------------------------------HKO END------------------------------------------//

        //-----------------------------------TAA------------------------------------------//

        //TAA Requestor
        user = userCreation ( user2_Alias, user2_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        user.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (user.Alias, user );
        
        //TAA IM 
        User approver1TAA = userCreation ( approver1TAA_Alias, approver1TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver1TAA.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (approver1TAA.Alias, approver1TAA);
                
        //TAA Director
        User approver2TAA = userCreation ( approver2TAA_Alias, approver2TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver2TAA .Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (approver2TAA.Alias, approver2TAA);
        
        //TAA MD
        User approver3TAA = userCreation ( approver3TAA_Alias, approver3TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        approver3TAA.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (approver3TAA.Alias, approver3TAA);
    
        
        User actingapprover1TAA = userCreation ( actingapprover1TAA_Alias, actingapprover1TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover1TAA.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (actingapprover1TAA.Alias, actingapprover1TAA );
        
        User actingapprover2TAA = userCreation ( actingapprover2TAA_Alias, actingapprover2TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover2TAA.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (actingapprover2TAA.Alias, actingapprover2TAA );
        
        User actingapprover3TAA = userCreation ( actingapprover3TAA_Alias, actingapprover3TAA_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        actingapprover3TAA.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (actingapprover3TAA.Alias, actingapprover3TAA );
        
        //TAA Local Purchaser
        User purchaser = userCreation ( purchaserUser_Alias, purchaserUser_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        purchaser.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_TAA;        
        UserMap.put (purchaser.Alias, purchaser);


        //-----------------------------------TAA END------------------------------------------//
        

        //-----------------------------------C-LEVEL/ ROI VERIFIER------------------------------------------//
        User clevel = userCreation ( cLevel_Alias, cLevel_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        clevel.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (clevel.Alias, clevel);

        User roiUser = userCreation ( roiUser_Alias, roiUser_Email, talFEStdPlatformUserprofile.Id, USER_GLOBAL, USER_REGION, USER_LOCAL, USER_GRADE, USER_DEPT, USER_FUNCTION, USER_LANG, USER_ADMIN_REGION, USER_ADMIN_DEPT, USER_CREATE_PAGE );
        roiUser.Physical_Delivery_Address__c = USER_PHYSICAL_DELIVERY_ADDRESS_HKO;        
        UserMap.put (roiUser.Alias, roiUser);
        //-----------------------------------C-LEVEL/ ROI VERIFIER END------------------------------------------//

        for(User u : UserMap.values()) {
            u.Function_short__c = 'IT';
            u.Department__c = 'IT';
        }        
        insert UserMap.values();
        system.debug(logginglevel.ERROR, 'UserMap '+UserMap);


        system.debug(logginglevel.ERROR, 'u4: '+system.now());

        List<ID> usrIDList = new List<ID> ();
        for ( User usr : UserMap.values() ){
            usrIDList.add(usr.id);
        }
        UserMap.clear();
        
        for ( User reader : 
            [
                select id,
                Alias, Email, 
                EmailEncodingKey, LastName, LanguageLocaleKey, 
                LocaleSidKey, ProfileId, 
                TimeZoneSidKey, UserName,
                Location_Global__c,
                Location_Region__c,
                Location_Local__c,
                Grade__c,
                Department__c,
                Function__c,
                Portal_Language__c,
                Administrative_Regions__c,
                Administrative_Department__c,
                Create_Portal_Page__c,
                Physical_Delivery_Address__c
                from user
                where id in :usrIDList
        ]){
            UserMap.put ( reader.Alias, reader);
            if (!permissionSetMap.isEmpty()){
                PermissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = reader.id, PermissionSetId = permissionSetMap.get(IDP_PERMISSION_USER)));
            }       

        }
        userGroupList.add(new GroupMember(UserOrGroupId = UserMap.get(catalogOwnerUser_Alias).id, GroupId = groupMap.get(IDP_CATALOG_ADMIN_GROUP_NAME)));
        userGroupList.add(new GroupMember(UserOrGroupId = UserMap.get(purchaserUser_Alias).id, GroupId = groupMap.get(IDP_PURCHASER_TAA_GROUP_NAME)));
        
        PermissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = UserMap.get(catalogOwnerUser_Alias).id, PermissionSetId = permissionSetMap.get(IDP_PERMISSION_CATALOG_OWNER)));
        PermissionSetAssignmentList.add(new PermissionSetAssignment(AssigneeId = UserMap.get(purchaserUser_Alias).id, PermissionSetId = permissionSetMap.get(IDP_PERMISSION_CATALOG_OWNER)));




        system.debug(logginglevel.ERROR, 'u5: '+system.now());
        System.runAs(UserMap.get('admin')){       
            if(!PermissionSetAssignmentList.isempty()){
                system.debug(logginglevel.ERROR, 'u6: '+system.now());

                insert PermissionSetAssignmentList;
            }
            
            if(!userGroupList.isempty()){
                system.debug(logginglevel.ERROR, 'u7: '+system.now());

                insert userGroupList;
            }
        } 
        system.debug(logginglevel.ERROR, 'u8: '+system.now());
        system.debug(logginglevel.ERROR, 'u6: permissionSetMap '+permissionSetMap.size());

        system.debug(logginglevel.ERROR, 'u6: usrIDList '+usrIDList.size());
        system.debug(logginglevel.ERROR, 'u6: groupMap '+groupMap.size());
        system.debug(logginglevel.ERROR, 'u6: userGroupList '+userGroupList.size());
        system.debug(logginglevel.ERROR, 'UserMap '+UserMap);

        List<PermissionSetAssignment> perSetAssList =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                FROM PermissionSetAssignment
                                                                WHERE AssigneeId = :UserMap.get(catalogOwnerUser_Alias).id ];
        system.debug('##perSetAssList' + perSetAssList);

        for (PermissionSetAssignment perSetAss : perSetAssList) {
            system.debug('Assigned UserPerSet:'+ perSetAss.PermissionSet.Name);
        }

        return UserMap;
    }   


    Public Map<String, Expense_Policy__c> getExpensePolicyMap() {

        List<Expense_Policy__c> ExpensePolicyList = new List<Expense_Policy__c>();
        Expense_Policy__c ep1 = new Expense_Policy__c(
            Name = 'HKO',
            keyword__c = 'all',
            Local_Currency__c = CurrencyMap.get('HKD').Id,
            //new
            Allowance_Currency__c = CurrencyMap.get('HKD').Id,
            Cash_Advance_Late_Application_Threshold__c = 5,
            Maximum_of_fitness_expense_currency__c = CurrencyMap.get('HKD').Id,
            Hotel_Allowance_Currency__c = CurrencyMap.get('HKD').Id,
            Maximum_of_fitness_expense__c = 6000,
            Meal_Allowance_Currency__c = CurrencyMap.get('HKD').Id
        );
        Expense_Policy__c ep2 = new Expense_Policy__c(
            Name = 'TAA',
            keyword__c = 'all',
            Local_Currency__c = CurrencyMap.get('USD').Id,
            //new
            Allowance_Currency__c = CurrencyMap.get('USD').Id,
            Cash_Advance_Late_Application_Threshold__c = 5,
            Maximum_of_fitness_expense_currency__c = CurrencyMap.get('USD').Id,
            Hotel_Allowance_Currency__c = CurrencyMap.get('USD').Id,
            Maximum_of_fitness_expense__c = 6000,
            Meal_Allowance_Currency__c = CurrencyMap.get('USD').Id
        );
        ExpensePolicyList.add(ep1);
        ExpensePolicyList.add(ep2);
        insert ExpensePolicyList;
        List<ID> NewExpensePolicyIDList = new List<ID>();
        for (Expense_Policy__c ep : ExpensePolicyList) {
            NewExpensePolicyIDList.add(ep.Id);
        }
        for (Expense_Policy__c ep : [SELECT Id, Name, keyword__c, Local_Currency__c,
                                            Allowance_Currency__c, Cash_Advance_Late_Application_Threshold__c, Maximum_of_fitness_expense_currency__c,
                                            Hotel_Allowance_Currency__c, Maximum_of_fitness_expense__c, Meal_Allowance_Currency__c
                                    FROM Expense_Policy__c 
                                    where Id IN :NewExpensePolicyIDList]) {
            ExpensePolicyMap.put(ep.Name, ep);
        }

        return ExpensePolicyMap;
    }

    Public Map<String, Employee__c> getIDPEmployeeMap() {
        Map<String, Employee__c> EmployeeMap = new Map<String, Employee__c>();
        
        Employee__c user1= new Employee__c(
            Name = 'user1',
            Original_Employee_ID__c = 'user1',
            Employee_ID__c = 'user1',
            //Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'user1',
            Last_Name__c = 'user1',
            //Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            //Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('user1').id,
            Approver_1__c = UserMap.get('apr1').id,
            Approver_2__c = UserMap.get('apr2').id,
            //Approver_3__c = UserMap.get('apr3').id,
            //Approver_4__c = UserMap.get('apr4').id,
            Acting_Approver_1__c = UserMap.get('actapr1').id,
            Acting_Approver_2__c = UserMap.get('actapr2').id,
            //Acting_Approver_3__c = UserMap.get('actapr3').id,
            //Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('HKO').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            IDP_Policy__c = idpPolicyMap.get('HKO').Id,
            Expense_Policy__c = expensePolicyMap.get('HKO').Id
        );
        
        Employee__c user2= new Employee__c(
            Name = 'user2',
            Original_Employee_ID__c = 'user2',
            Employee_ID__c = 'user2',
            //Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'user2',
            Last_Name__c = 'user2',
            //Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            //Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('user2').id,
            Approver_1__c = UserMap.get('apr1T').id,
            Approver_2__c = UserMap.get('apr2T').id,
            Approver_3__c = UserMap.get('apr3T').id,
            //Approver_4__c = UserMap.get('apr4').id,
            Acting_Approver_1__c = UserMap.get('actapr1T').id,
            Acting_Approver_2__c = UserMap.get('actapr2T').id,
            Acting_Approver_3__c = UserMap.get('actapr3T').id,
            //Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('TAA').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            IDP_Policy__c = idpPolicyMap.get('TAA').Id,
            Expense_Policy__c = expensePolicyMap.get('TAA').Id
            
        );

        Employee__c purchaser = new Employee__c(
            Name = 'purch',
            Original_Employee_ID__c = 'purch',
            Employee_ID__c = 'purch',
            //Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'purch',
            Last_Name__c = 'purch',
            //Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            //Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('purch').id,
            //Approver_1__c = UserMap.get('apr1').id,
            //Approver_2__c = UserMap.get('apr2').id,
            //Approver_3__c = UserMap.get('apr3').id,
            //Approver_4__c = UserMap.get('apr4').id,
            //Acting_Approver_1__c = UserMap.get('actapr1').id,
            //Acting_Approver_2__c = UserMap.get('actapr2').id,
            //Acting_Approver_3__c = UserMap.get('actapr3').id,
            //Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('HKO').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            IDP_Policy__c = idpPolicyMap.get('TAA').Id,
            Expense_Policy__c = expensePolicyMap.get('TAA').Id
        );


        Employee__c COUser = new Employee__c(
            Name = 'COUser',
            Original_Employee_ID__c = 'COUser',
            Employee_ID__c = 'COUser',
            //Employee_Type__c = EmployeeTypeMap.get('HKOPermanent').id,
            First_Name__c = 'COUser',
            Last_Name__c = 'COUser',
            //Leave_Policy__c = LeavepolicyMap.get('HKO').id,
            //Timeset__c = TimeSetMap.get('HKO_TS1').id,
            user__c = UserMap.get('COUser').id,
            //Approver_1__c = UserMap.get('apr1').id,
            //Approver_2__c = UserMap.get('apr2').id,
            //Approver_3__c = UserMap.get('apr3').id,
            //Approver_4__c = UserMap.get('apr4').id,
            //Acting_Approver_1__c = UserMap.get('actapr1').id,
            //Acting_Approver_2__c = UserMap.get('actapr2').id,
            //Acting_Approver_3__c = UserMap.get('actapr3').id,
            //Acting_Approver_4__c = UserMap.get('actapr4').id,
            Site__c = SiteMap.get('HKO').id,
            Grade__c = EMPLOYEE_GRADE,
            //Employee_Department__c = 'IT'
            Function_Code__c = 'IT',
            Department_Code__c = 'IT',
            IDP_Policy__c = idpPolicyMap.get('HKO').Id,
            Expense_Policy__c = expensePolicyMap.get('HKO').Id
        );

        EmployeeMap.put(user1.Name, user1);
        EmployeeMap.put(user2.Name, user2);
        EmployeeMap.put(purchaser.Name, purchaser);
        EmployeeMap.put(COUser.Name, COUser);

        insert EmployeeMap.values();

        return EmployeeMap;
    }

    Public Map<String, Employee_Administrator__c> getIDPEmployeeAdministratorMap() {

        Map<String, Employee_Administrator__c> resultMap = new Map<String, Employee_Administrator__c> ();
        Map<Employee__c, List<Employee__c>> eaMap = new Map<Employee__c, List<Employee__c>>();
        List<Employee__c> employees = new List<Employee__c> ();
        List<Employee_Administrator__c> eas = new List<Employee_Administrator__c>();
        
        employees.add(this.EmployeeMap.get('user1'));
        employees.add(this.EmployeeMap.get('user2'));
        employees.add(this.EmployeeMap.get('COUser'));
        eaMap.put(this.EmployeeMap.get('user1'), employees);
        eaMap.put(this.EmployeeMap.get('user2'), employees);
        eaMap.put(this.EmployeeMap.get('COUser'), employees);
        IDPEmployeeAdministratorCreation (eaMap);
        
        /*
        for(Employee_Administrator__c ea: [select id, Application__c from Employee_Administrator__c] ){
            ea.Application__c  = 'IDP';
            eas.adD(ea);
        }
        if(!eas.isEmpty()){
            upsert eas;
        }
        */
        
        for (Employee_Administrator__c empAdmin : [SELECT Id, Name, Employee__c, Is_Self__c, Is_Employee_Active__c, Employee__r.Name,
                                                            Is_Mine__c, Employee_ID_and_Administrator_ID__c, 
                                                           Employee_Full_Name__c, Employee_Department__c, Employee_Administrator__c, 
                                                           Administrator__c, Keyword__c, Employee_UserId__c, Is_Active__c, On_Behalf_of_Grade__c 
                                                   FROM Employee_Administrator__c where Employee__c IN :employees AND Application__c INCLUDES ('IDP')]) {
            
            resultMap.put(empAdmin.Employee__r.Name, EmpAdmin);
        }

        return resultMap;
    }
    
    
     private  List <Employee_Administrator__c> IDPEmployeeAdministratorCreation ( Map< Employee__c, List<Employee__c> > EmployeeAdministratorMap ) {
        List <Employee_Administrator__c> EmployeeAdministrator = new List <Employee_Administrator__c>();
        Set<ID> selfEmployeeAdministratorIds = new Set<ID>();
        
        for ( Employee__c key : EmployeeAdministratorMap.keyset() ){
            for ( Employee__c val : EmployeeAdministratorMap.get(key) ){
                if ( val.id != key.id ) {
                    EmployeeAdministrator.add(new Employee_Administrator__c (Application__c  = 'IDP', Employee_Administrator__c = key.id, Employee__c = val.id ));
                } else {
                    selfEmployeeAdministratorIds.add(key.id);
                }
            }
        }
        
        for(Employee_Administrator__c  ea : [Select Application__c  ,  Employee_Administrator__c, Employee__c from Employee_Administrator__c where Employee_Administrator__c in :selfEmployeeAdministratorIds and Is_Self__c = true] ){
            EmployeeAdministrator.add(new Employee_Administrator__c (Application__c  = 'IDP', id = ea.id));
        }
        upsert EmployeeAdministrator;
        
        employeeAdministrator.addAll([Select Employee_Administrator__c, Employee__c from Employee_Administrator__c where Employee_Administrator__c in :selfEmployeeAdministratorIds and Is_Self__c = true]);
        
        return EmployeeAdministrator;
    }
}