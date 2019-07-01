@isTest  
public class TestTEExpenseApplicationCtrl{
    
    Public static TestTEExpenseApplication TEExpenseApplication;    
    Public static Map<String, Travel_Location__c> travelLocationMap;
    Public static employee__c employee;
    Public static Map<String, Employee_Administrator__c> EmployeeAdministrator;
    Public static String userName = 'user1';
    
    Public static void preparation(Boolean isSeeAllData){
        TEExpenseApplication = new TestTEExpenseApplication(isSeeAllData);
        travelLocationMap = TEExpenseApplication.travelLocationMap;
        employee = TEExpenseApplication.getEmployeefromOriginalEmployeeID(userName);
        EmployeeAdministrator = TEExpenseApplication.EmployeeAdministratorMap;
    }
    
    @isTest  
    public static void addRemoveRows(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.insertRow();
            edl.removeRow();
            edl.duplicateRow();
            eaCtrl.insertRows();
            eaCtrl.getCurrencies();
            eaCtrl.getLocations();
            eaCtrl.cancel();
            System.assertNotEquals(edlList.size(), 0);
            Test.stopTest();
        }    
    }
    
    @isTest  
    public static void OpenExistingTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        dateTime returndt = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c, Preferred_Departure_Date__c, Preferred_Departure_dt__c, Preferred_Return_dt__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                 returndt = reader.travel_Details__r[0].Preferred_Return_dt__c;
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue(); 
            for(selectOption reader :  expenseTypesOpts){
                if (reader.getlabel() == 'meal'){
                    edl.expenseDetail.expense_Type__c = reader.getValue();
                }
            }
                                 
            System.assertNotEquals(eaCtrl.edl.size(), 0);
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            TEExpenseApplicationCtrl.findLoaction(ta.TravelApplication.id, returndt);
            eaCtrl.onApplicantChange();
            eaCtrl.initTLAMap();
            eaCtrl.initRateMap();
            eaCtrl.refreshAllMaxCapInfo();
            for(selectOption reader :  expenseTypesOpts){
                if (reader.getlabel() == 'hotel'){
                    edl.expenseDetail.expense_Type__c = reader.getValue();
                }
            }
            eaCtrl.refreshAllMaxCapInfo();
            System.assertNotEquals(eaCtrl.ea.id, null);  
            Test.stopTest();
        }
        
    }
    
    @isTest  
    public static void submitNewGeneralExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            Test.stopTest();
        }
    }
    
    @isTest  
    public static void approveGeneralExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
            Test.stopTest();
        }
        System.runAs(UserMap.get('actapr1')){
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();             
            prc = eaCtrl.approve();
            System.assertNotEquals(eaCtrl.ea.id, null);
        }
    }
    
    @isTest  
    public static void rejectGeneralExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
            Test.stopTest();
        }
        System.runAs(UserMap.get('actapr1')){
            ApexPages.currentPage().getParameters().put('rt', 'general' );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();             
            prc = eaCtrl.reject();
            System.assertNotEquals(prc, null);
        }
    }
    
    @isTest  
    public static void saveNewTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();
            Test.stopTest();
        }
    }
    
    @isTest  
    public static void submitNewTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            Test.stopTest();
        }
        
    }
    
    
    @isTest   
    public static void ApproveTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
            
        }
        
        System.runAs(UserMap.get('actapr1')){
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();             
            prc = eaCtrl.approve();
            System.assertNotEquals(prc, null);
        }
        Test.stopTest();
    }
    
    @isTest   
    public static void RejectTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        TEExpenseApplicationCtrl eaCtrl = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.receipt_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id;
            edl.expenseDetail.Amount__c = 100;
            edl.expenseDetail.Receipt_date__c = System.Today().addDays(-1);
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();            
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.submitAndGo();
            System.assertNotEquals(prc, null);
            
            
        }
        
        System.runAs(UserMap.get('actapr1')){
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = new TEExpenseApplicationCtrl();             
            prc = eaCtrl.approve(false);
            System.assertNotEquals(prc, null);
        }
        Test.stopTest();
        
    }
    
    @isTest
    public static void saveNewEducationExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        Education_Application__c edapp;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
        System.runAs(UserMap.get(userName)){
            edapp = ApprovedEducation(UserMap);
            System.assertNotEquals(edapp.id, null);
            for(Education_Application__c  reader :
                [select id, status__c
                   from Education_Application__c 
                   where id =:edapp.id
                ]
            ){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_APPROVED);
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'education' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName); 
            eaCtrl.getApplicants();
            eaCtrl.ea.education_application__c = edapp.id;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            eaCtrl.populateEducationExpense();
            eaCtrl.getEducationApplications();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();
            edl.expenseDetail.receipt_date__c = System.Today().adddays(-2);
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void OpenExistingEducationExpense(){        
        TEExpenseApplicationCtrl eaCtrl = null;
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        Education_Application__c edapp;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
        System.runAs(UserMap.get(userName)){
            edapp = ApprovedEducation(UserMap);
            System.assertNotEquals(edapp.id, null);
            for(Education_Application__c  reader :
                [select id, status__c
                   from Education_Application__c 
                   where id =:edapp.id
                ]
            ){
                 System.assertEquals(reader.status__c, TEConstant.STATUS_APPROVED);
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'education' );
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName); 
            eaCtrl.getApplicants();
            eaCtrl.ea.education_application__c = edapp.id;
            expenseTypesOpts = eaCtrl.getExpenseTypes();
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            eaCtrl.populateEducationExpense();
            eaCtrl.getEducationApplications();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.expenseDetail.expense_Type__c = expenseTypesOpts[0].getValue();
            edl.expenseDetail.receipt_date__c = System.Today().adddays(-2);
            prc = eaCtrl.saveAndGo();
            System.assertNotEquals(prc, null);
            ApexPages.currentPage().getParameters().put('rt', 'education' );
            ApexPages.currentPage().getParameters().put('id', eaCtrl.ea.id);
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName); 
            System.assertNotEquals(eaCtrl, null);
            
            
            Test.stopTest();
        }
    }
    
    
    @isTest  
    public static void CheckErrorTravelExpense(){        
        Map<String, User> UserMap = null;        
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<ExpenseDetailBizTO> edlList = null;
        List<selectOption> expenseTypesOpts = null;
        ExpenseDetailBizTO edl;
        PageReference prc = null;
        TETravelApplicationCtrl ta = null;
        preparation(false);
        UserMap = TEExpenseApplication.UserMap;
         
        System.runAs(UserMap.get(userName)){
            ta = ApplicantConfirmTA();
            System.assertNotEquals(ta.TravelApplication.id, null); 
            for (travel_Application__c  reader :
                [select id, status__c,
                   (select id, status__c from travel_Details__r   ),
                   (select id, status__c from Accommodations__r   ),
                   (select id, status__c from TravelOptions__r  ) 
                   from travel_Application__c 
                   where id =:ta.TravelApplication.id
                ]
            ){
                
                 System.assertEquals(reader.status__c, TEConstant.STATUS_CONFIRMED); 
                 System.assertNotEquals(reader.travel_Details__r.size(), 0); 
            }
            Test.startTest();
            ApexPages.currentPage().getParameters().put('rt', 'travel' );
            TEExpenseApplicationCtrl eaCtrl = null;
            eaCtrl = TEExpenseApplication.createExpenseApplication(employee, EmployeeAdministrator, userName);
            eaCtrl.getApplicants();
            prc = eaCtrl.saveAndGo();
            eaCtrl.ea.travel_application__c = ta.TravelApplication.id;
            eaCtrl.populateLocation();
            edlList = eaCtrl.edl;
            edl = edlList[0];
            edl.onCurrencyChange();
            edl.expenseDetail.receipt_Currency__c = null;
            edl.expenseDetail.Amount__c = 0;
            expenseTypesOpts = eaCtrl.getExpenseTypes();            
            System.assertNotEquals(ExpenseTypesOpts.size(), 0);
            edl.expenseDetail.expense_Type__c = null;
            edl.expenseDetail.receipt_date__c = null;
            System.assertNotEquals(eaCtrl.edl.size(), 0);            
            prc = eaCtrl.saveAndGo();
            edl.expenseDetail.receipt_date__c = system.today().adddays(11);
            prc = eaCtrl.saveAndGo();
            System.assertEquals(prc, null);
             
            Test.stopTest();
        }
    }
    
    
    Public Static Education_Application__c ApprovedEducation(Map<String, User> UserMap){
        Education_Application__c ea = new Education_Application__c(
            On_Behalf_Of__c =  EmployeeAdministrator.get(userName).id,
            RecordTypeId = TEExpenseApplication.RecordTypeMap.get(TEConstant.EDUCATION_APPLICATION_OBJECT_NAME + '_' + TEConstant.EDUCATION_APPLICATION_EDUCATION).Id,
            Apply_Date__c = System.Today(),
            Program_Course_Title__c = TEExpenseApplication.generateRandomString(5),
            Course_URL__c = TEExpenseApplication.generateRandomString(5),
            Couse_Type__c = 'd',
            Currency__c = TEExpenseApplication.currencyMap.get('HKD').id,
            Tuition_Fee_Recommended_Currency__c = TEExpenseApplication.currencyMap.get('HKD').id,
            Degree_Course_Title__c = TEExpenseApplication.generateRandomString(5),
            Education__c = TEExpenseApplication.generateRandomString(5),
            Start_Date__c = System.Today().adddays(5),
            End_Date__c = System.Today().adddays(15),
            Length_of_Program_Year__c = 1,
            Payment_Method__c = 'a',
            Reason_of_Studying__c = TEExpenseApplication.generateRandomString(5),
            Relevancy_to_work__c = TEExpenseApplication.generateRandomString(5),
            Reliability_of_Course_Institute__c = TEExpenseApplication.generateRandomString(5),
            Remarks__c = TEExpenseApplication.generateRandomString(5),
            Status__c = TEConstant.STATUS_APPROVED,
            Tech_Applicant__c = UserMap.get(userName).id,
            Tuition_Fee__c = 100,
            Tuition_Fee_Recommended__c = 100
        );
        UpSert ea;
        return ea;
    }
    
    public static TETravelApplicationCtrl ApplicantConfirmTA(){  
        Map<String, Map<String, String>> recordTypeMap = null;
        Map<String, String> TDRecordTypeMap = null;
        List<TETravelDetail> tdList = null;
        travel_application__c tac = null;
        DateTime today = System.today();
        recordTypeMap = TEExpenseApplication.getRecordType();
        TDRecordTypeMap = recordTypeMap.get(Travel_Detail__c.sObjectType.getDescribe().getName());
            
        TETravelApplicationCtrl ta = new TETravelApplicationCtrl();
        TETravelDetail td = null;            
        ta.TravelApplication.Selected_Passport__c = employee.passport_type_1__c;
        ta.TravelApplication.On_Behalf_of__c = EmployeeAdministrator.get(userName).id;
        ta.TravelApplication.status__c = TEConstant.STATUS_CONFIRMED;
        //Create Travel Detail
        tdList = ta.travelDetailList;         
        td = tdList[0];
        td.TravelDetail.recordTypeId = TDRecordTypeMap.get('Surface');
        td.TravelDetail.Preferred_Departure_dt__c = today.adddays(-30);
        td.TravelDetail.Preferred_Return_dt__c = today.adddays(-10);
        td.TravelDetail.Origin_Site__c = travelLocationMap.get('HONGKONG').id;
        td.TravelDetail.Destination__c = travelLocationMap.get('HONGKONG').id;
        td.TravelDetail.Self_Arragnment__c = true;
        td.TravelDetail.status__c = TEConstant.STATUS_CONFIRMED;
        for(TEAccommodationCtrl reader :  ta.travelAccommodationList){
            if (String.IsBlank(reader.checkInDate)){
                reader.checkInDate = '';
            }
            if (String.IsBlank(reader.checkoutDate)){
                reader.checkOutDate = '';
            }
        }
        insert ta.TravelApplication;
        td.TravelDetail.travel_application__c = ta.TravelApplication.id;
        insert td.TravelDetail;
        return ta;
    }
    
    
}