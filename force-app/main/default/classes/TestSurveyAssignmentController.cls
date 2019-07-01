@isTest
private class TestSurveyAssignmentController {
    
    @isTest 
    static void testDisplayAdministratorAssignment() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.ADMINISTRATOR);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> ll = surveyAssignmentController.selectedSurveyAssignments;
                System.assertEquals(1, ll.size());
            }
        }
    }

    @isTest 
    static void testDisplayTakerAssignment() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> ll = surveyAssignmentController.selectedSurveyAssignments;
                System.assertEquals(3, ll.size());
            }
        }
    }

    @isTest 
    static void testCheckAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.checkAccessright();
                System.assertEquals(null, pr);
            }
        }
    }

    @isTest 
    static void testCheckNoAccessRight() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
        String taker1Id = surveyTestingUtil.taker1Id;

        List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                    From Survey_Assignment__c 
                                    where id =: takerSurveyAssignmentId];
        Survey_Assignment__c surveyAssignment = null;
        if (listSA != null && listSA.size() > 0) {
            surveyAssignment = listSA.get(0);
        }

        if (surveyAssignment != null) {

            User u = [Select Id From  User Where id = :taker1Id];
            System.runAs(u) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.checkAccessright();
                System.assertNotEquals(null, pr);
            }
        } 
    }

    @isTest 
    static void testDeleteSurveyAssignment() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
        String ownerId = surveyTestingUtil.ownerId;
        String groupSurveyAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;

        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                surveyAssignmentController.selectedSurveyAssignmentId = takerSurveyAssignmentId;
                PageReference pr = surveyAssignmentController.deleteSurveyAssignment();
                System.assertEquals('/apex/surveyassignmentdisplaypage?access=view&mode=' + SurveyAssignmentObjectUtil.TAKER 
                    + '&surveyId=' + surveyId, pr.getUrl());

                surveyAssignmentController.loadSelectedSurveyAssignments();
                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> ll = surveyAssignmentController.selectedSurveyAssignments;
                System.assertEquals(2, ll.size());
                System.assertEquals(groupSurveyAssignmentId, ll.get(0).Id);
            } 
        }
    }

    @isTest 
    static void testBackButtonClick() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.back(); 
                System.assertEquals('/apex/SurveyManagerPage?id=' + surveyId, pr.getUrl());
            } 
        }
    }

    @isTest 
    static void testShowAddSharingForAdministrator() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String adminSurveyAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: adminSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.ADMINISTRATOR);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.showAddSharing(); 
                System.assertEquals('/apex/SurveyAssignmentCreateAdminPage?access=add&mode=' + 
                        + SurveyAssignmentObjectUtil.ADMINISTRATOR + '&surveyId=' + surveyId, pr.getUrl());
            } 
        }
    }


    @isTest 
    static void testShowAddSharingForTaker() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentDisplayPage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_VIEW);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.showAddSharing(); 
                System.assertEquals('/apex/SurveyAssignmentCreatePage?access=add&mode=' + 
                        + SurveyAssignmentObjectUtil.TAKER + '&surveyId=' + surveyId, pr.getUrl());
            } 
        }   

    }

    @isTest 
    static void testQueryUserAndGroup() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentCreatePage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_ADD);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                surveyAssignmentController.inputUser = 'Taker';
                surveyAssignmentController.queryUsers();

                surveyAssignmentController.inputPublicGroup = 'Survey';
                surveyAssignmentController.queryGroups();

                surveyAssignmentController.inputUser = '111';
                surveyAssignmentController.queryUsers();
            } 
        }
    }

    @isTest 
    static void testBackToAssignmentButtonClick() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentCreatePage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_ADD);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                PageReference pr = surveyAssignmentController.backToAssignmentListing(); 
                System.assertEquals('/apex/SurveyAssignmentDisplayPage?access=view&mode=' 
                        + SurveyAssignmentObjectUtil.TAKER
                        + '&surveyId=' + surveyId, pr.getUrl());
            } 
        }
    }

    @isTest 
    static void testSaveAssignment() {
        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
        String taker1Id = surveyTestingUtil.taker1Id;
        String taker5Id = surveyTestingUtil.taker5Id;
        String group2Id = surveyTestingUtil.group2Id;
        String groupId = surveyTestingUtil.groupId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {
            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentCreatePage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_ADD);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                surveyAssignmentController.inputUser = 'TestingX';
                surveyAssignmentController.queryUsers();

                surveyAssignmentController.inputPublicGroup = 'Test';
                surveyAssignmentController.queryGroups();

                surveyAssignmentController.selectedUsers = new List<String>();
                surveyAssignmentController.selectedPublicGroups = new List<String>();
                surveyAssignmentController.unselectedUsers = new List<String>();
                surveyAssignmentController.unselectedPublicGroups = new List<String>();

                surveyAssignmentController.selectedUsers.add(taker5Id);
                surveyAssignmentController.selectedPublicGroups.add(group2Id);

                surveyAssignmentController.doAddGroup();
                surveyAssignmentController.doAddUser();

                surveyAssignmentController.selectedUsers.clear();
                surveyAssignmentController.selectedPublicGroups.clear();

                surveyAssignmentController.unselectedUsers.add(taker5Id);
                surveyAssignmentController.unselectedPublicGroups.add(group2Id);

                surveyAssignmentController.doRemoveUser();
                surveyAssignmentController.doRemoveGroup();

                surveyAssignmentController.selectedUsers.add(taker5Id);
                surveyAssignmentController.selectedPublicGroups.add(group2Id);

                surveyAssignmentController.doAddGroup();
                surveyAssignmentController.doAddUser();

                PageReference pr = surveyAssignmentController.saveAssignment(); 
                System.assertEquals('/apex/SurveyAssignmentDisplayPage?access=view&mode=' 
                        + SurveyAssignmentObjectUtil.TAKER
                        + '&surveyId=' + surveyId, pr.getUrl());

                // 2 takers and 2 public groups are inserted into database
                List<Survey_Assignment__c> ll = [Select Id, User__c, GroupId__c From Survey_Assignment__c where Survey__c = :surveyId];
                Set<String> ss = new Set<String>();
                for (Survey_Assignment__c result : ll) {
                    if (result.User__c != null && String.isNotBlank(result.User__c)) {
                        ss.add(result.User__c);
                    } else if (result.GroupId__c != null && String.IsNotBlank(result.GroupId__c)) {
                        ss.add(result.GroupId__c);
                    }
                }                
                System.assertEquals(true, ss.contains(groupId));
                System.assertEquals(true, ss.contains(group2Id));
                System.assertEquals(true, ss.contains(taker5Id));
                System.assertEquals(true, ss.contains(taker1Id));           
            } 
        }
    }

    @isTest 
    static void testConstructSelectOptions() {

        SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        String surveyId = surveyTestingUtil.surveyId;
        String takerSurveyAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
        String taker1Id = surveyTestingUtil.taker1Id;
        String taker5Id = surveyTestingUtil.taker5Id;
        String group2Id = surveyTestingUtil.group2Id;
        String groupId = surveyTestingUtil.groupId;

        String ownerId = surveyTestingUtil.ownerId;
        User u = [Select id, name, username from User where id = :ownerId];
        System.runAs(u) {

            List<Survey_Assignment__c> listSA = [Select id, Name, User__c, GroupId__c, Assignment_Nature__c, Survey__c 
                                        From Survey_Assignment__c 
                                        where id =: takerSurveyAssignmentId];
            Survey_Assignment__c surveyAssignment = null;
            if (listSA != null && listSA.size() > 0) {
                surveyAssignment = listSA.get(0);
            }

            if (surveyAssignment != null) {
                PageReference pageRef = Page.SurveyAssignmentCreatePage;
                Test.setCurrentPage(pageRef);//Applying page context here
                ApexPages.currentPage().getParameters().put('surveyId',surveyId);
                ApexPages.currentPage().getParameters().put('mode', SurveyAssignmentObjectUtil.TAKER);
                ApexPages.currentPage().getParameters().put('access', SurveyAssignmentObjectUtil.MODE_ADD);
                ApexPages.StandardController stdSurveyAssignment = new ApexPages.StandardController(surveyAssignment);
                SurveyAssignmentController surveyAssignmentController  = new SurveyAssignmentController(stdSurveyAssignment);

                surveyAssignmentController.inputUser = 'TestingX';
                surveyAssignmentController.queryUsers();

                surveyAssignmentController.inputPublicGroup = 'Test';
                surveyAssignmentController.queryGroups();

                List<SelectOption> optUserSelect = surveyAssignmentController.getSelectedUserOptions();
                List<SelectOption> optUserUnSelect = surveyAssignmentController.getUnselectedUserOptions();
                System.assertEquals(8, optUserUnSelect.size());
                System.assertEquals(1, optUserSelect.size());

                List<SelectOption> optGroupSelect = surveyAssignmentController.getSelectedGroupOptions();
                List<SelectOption> optGroupUnSelect = surveyAssignmentController.getUnselectedGroupOptions();
                System.assertEquals(4, optGroupUnSelect.size());
                System.assertEquals(2, optGroupSelect.size());

                surveyAssignmentController.selectedUsers = new List<String>();
                surveyAssignmentController.selectedPublicGroups = new List<String>();
                surveyAssignmentController.unselectedUsers = new List<String>();
                surveyAssignmentController.unselectedPublicGroups = new List<String>();

                surveyAssignmentController.selectedUsers.add(taker1Id);
                surveyAssignmentController.selectedUsers.add(taker5Id);
                surveyAssignmentController.selectedPublicGroups.add(group2Id);

                surveyAssignmentController.doAddGroup();
                surveyAssignmentController.doAddUser();
                
                optUserSelect = surveyAssignmentController.getSelectedUserOptions();
                optUserUnSelect = surveyAssignmentController.getUnselectedUserOptions();
                System.assertEquals(7, optUserUnSelect.size());
                System.assertEquals(2, optUserSelect.size());

                optGroupSelect = surveyAssignmentController.getSelectedGroupOptions();
                optGroupUnSelect = surveyAssignmentController.getUnselectedGroupOptions();
                System.assertEquals(2, optGroupSelect.size());
                System.assertEquals(4, optGroupUnSelect.size());
            } 
        }
    }
}