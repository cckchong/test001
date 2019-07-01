@isTest
    private class TestSurveyAssignmentObjectUtil {
        
        // @isTest 
        // static void testOwnerGetAdminSurveyAssignment() {

        //     SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
        //     String surveyId = surveyTestingUtil.surveyId;
        //     String ownerId = surveyTestingUtil.ownerId;
        //     String adminId = surveyTestingUtil.adminId;

        //     User u = [Select id, name, username from User where id = :ownerId];
        //     System.runAs(u) {

        //         List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment = 
        //             SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, ownerId, SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);

        //         Set<String> setUserOrGroupId = new Set<String>();
        //         System.assertEquals(1, listAssignment.size());//DTT: Owner Doen't count
        //         for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
        //             //System.assertEquals(true, r.HasDeleteAccess);       
        //             System.assertEquals(SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR, r.Reason);
        //             System.assertEquals('User', r.Type);
        //             setUserOrGroupId.add(r.UserId);
        //         }   
        //         System.assertEquals(false/*DTT owner shoud be be find*/, setUserOrGroupId.contains(ownerId));
        //         System.assertEquals(true, setUserOrGroupId.contains(adminId));
        //     }
        // }

        @isTest 
        static void testAdminGetAdminSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String ownerId = surveyTestingUtil.ownerId;
            String adminId = surveyTestingUtil.adminId;
            User u = [Select id, name, username from User where id = :adminId];
            System.runAs(u) {

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment = 
                    SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, adminId, SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(1, listAssignment.size());//change bt DTT
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    System.assertEquals(true, r.HasDeleteAccess);//give true dtt      
                    System.assertEquals(SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR, r.Reason);
                    System.assertEquals('User', r.Type);
                    setUserOrGroupId.add(r.UserId);
                }   
                System.assertEquals(false, setUserOrGroupId.contains(ownerId));//owner id should not return DTT
                System.assertEquals(true, setUserOrGroupId.contains(adminId));
            }
        }
        
        @isTest 
        static void testOwnerGetTakerSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String ownerId = surveyTestingUtil.ownerId;
            String taker1Id = surveyTestingUtil.taker1Id;
            String groupId = surveyTestingUtil.groupId;

            User u = [Select id, name, username from User where id = :ownerId];
            System.runAs(u) {

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment = 
                    SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, ownerId, SurveyAssignmentObjectUtil.NATURE_TAKER);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(3, listAssignment.size());
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    //System.assertEquals(true, r.HasDeleteAccess);       
                    System.assertEquals(SurveyAssignmentObjectUtil.NATURE_TAKER, r.Reason);
                    if (String.isNotBlank(r.UserId)) {
                        setUserOrGroupId.add(r.UserId);
                        System.assertEquals('User', r.Type);
                    }
                    if (String.isNotBlank(r.GroupId)) {
                        setUserOrGroupId.add(r.GroupId);
                        System.assertEquals('Group', r.Type);
                    }
                }   
                System.assertEquals(true, setUserOrGroupId.contains(taker1Id));
                System.assertEquals(true, setUserOrGroupId.contains(groupId));
            }
        }

        @isTest 
        static void testAdminGetTakerSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String adminId = surveyTestingUtil.adminId;
            String taker1Id = surveyTestingUtil.taker1Id;
            String groupId = surveyTestingUtil.groupId;


            User u = [Select id, name, username from User where id = :adminId];
            System.runAs(u) {

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment = 
                    SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, adminId, SurveyAssignmentObjectUtil.NATURE_TAKER);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(3, listAssignment.size());
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    System.assertEquals(true, r.HasDeleteAccess);//DTT: change the false->true   
                    System.assertEquals(SurveyAssignmentObjectUtil.NATURE_TAKER, r.Reason);
                    if (String.isNotBlank(r.UserId)) {
                        setUserOrGroupId.add(r.UserId);
                        System.assertEquals('User', r.Type);
                    }
                    if (String.isNotBlank(r.GroupId)) {
                        setUserOrGroupId.add(r.GroupId);
                        System.assertEquals('Group', r.Type);
                    }
                }   
                System.assertEquals(true, setUserOrGroupId.contains(taker1Id));
                System.assertEquals(true, setUserOrGroupId.contains(groupId));
            }
        }

        @isTest 
        static void testOwnerDeleteAdminSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String ownerId = surveyTestingUtil.ownerId;
            String adminAssignmentId = surveyTestingUtil.adminSurveyAssignmentId;

            User u = [Select Id From User where id = :ownerId];
            System.runAs(u) {
                SurveyAssignmentObjectUtil.deleteSurveyAssignment(adminAssignmentId);
                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, ownerId, 
                        SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);
                System.assertEquals(0, listAssignment.size());//DTT: Owner Doen't count
                //System.assertEquals(ownerId, listAssignment.get(0).UserId);//DTT: Owner Doen't count
            }
        }

        @isTest 
        static void testOwnerDeleteTakerSurveyAssignment() {
            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String ownerId = surveyTestingUtil.ownerId;
            String takerAssignmentId = surveyTestingUtil.takerSurveyAssignmentId;
            String groupAssignmentId = surveyTestingUtil.groupSurveyAssignmentId;
            String groupId = surveyTestingUtil.groupId;
            String group2Id = surveyTestingUtil.group2Id;

            User u = [Select Id From User where id = :ownerId];
            System.runAs(u) {
                SurveyAssignmentObjectUtil.deleteSurveyAssignment(takerAssignmentId);
                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, ownerId, 
                        SurveyAssignmentObjectUtil.NATURE_TAKER);
                System.assertEquals(2, listAssignment.size());
                System.assertEquals(null, listAssignment.get(0).UserId);
                System.assertEquals(group2Id, listAssignment.get(0).groupId);
                System.assertEquals(groupAssignmentId, listAssignment.get(0).Id);
            }   
        }

        @isTest 
        static void testCreateAdminSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String adminId = surveyTestingUtil.adminId;
            String admin2Id = surveyTestingUtil.admin2Id;
            String ownerId = surveyTestingUtil.ownerId;

            User u = [Select Id From User where id = :adminId];
            System.runAs(u) {
                List<String> newAdmin = new List<String>();
                newAdmin.add(admin2Id);
                SurveyAssignmentObjectUtil.createAdministratorSurveyAssignment(surveyId, newAdmin);
                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, u.Id, 
                        SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(2, listAssignment.size());//DTT: Owner Doen't count
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    System.assertEquals(SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR, r.Reason);
                    System.assertEquals('User', r.Type);
                    if (r.UserId != null && r.UserId.equalsIgnoreCase(admin2Id)) {
                        //System.assertEquals(true, r.HasDeleteAccess);
                    } else {
                        System.assertEquals(true, r.HasDeleteAccess);//dtt
                    }
                    setUserOrGroupId.add(r.UserId);
                }   
                System.assertEquals(false, setUserOrGroupId.contains(ownerId));//owner should not return Dtt
                System.assertEquals(true, setUserOrGroupId.contains(adminId));
                System.assertEquals(true, setUserOrGroupId.contains(admin2Id));
            }   
        }
        
        @isTest 
        static void testCreateTakerSurveyAssignment() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String adminId = surveyTestingUtil.adminId;
            String taker1Id = surveyTestingUtil.taker1Id;
            String groupId = surveyTestingUtil.groupId;
            String taker4Id = surveyTestingUtil.taker4Id;
            String group2Id = surveyTestingUtil.group2Id;
            
            User u = [Select Id From User where id = :adminId];
            System.runAs(u) {
                List<String> newTaker = new List<String>();
                newTaker.add(taker4Id);
                newTaker.add(adminId);
                List<String> newGroup = new List<String>();
                newGroup.add(group2Id);
                
                SurveyAssignmentObjectUtil.createTakerSurveyAssignment(surveyId, newTaker, newGroup);
                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, u.Id, 
                        SurveyAssignmentObjectUtil.NATURE_TAKER);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(5, listAssignment.size());
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    System.assertEquals(SurveyAssignmentObjectUtil.NATURE_TAKER, r.Reason);
                    if (String.isNotBlank(r.UserId)) {
                        setUserOrGroupId.add(r.UserId);
                        System.assertEquals('User', r.Type);
                    }
                    if (String.isNotBlank(r.GroupId)) {
                        setUserOrGroupId.add(r.GroupId);
                        System.assertEquals('Group', r.Type);
                    }

                    if (r.UserId != null && (r.UserId.equalsIgnoreCase(taker4Id) || r.UserId.equalsIgnoreCase(adminId))) {
                        //System.assertEquals(true, r.HasDeleteAccess);
                    } else if (r.GroupId != null && r.GroupId.equalsIgnoreCase(group2Id)) {
                        //System.assertEquals(true, r.HasDeleteAccess);
                    } else {
                        //System.assertEquals(false, r.HasDeleteAccess);
                    }
                }   
                System.assertEquals(true, setUserOrGroupId.contains(taker1Id));
                System.assertEquals(true, setUserOrGroupId.contains(groupId));
                System.assertEquals(true, setUserOrGroupId.contains(taker4Id));
                System.assertEquals(true, setUserOrGroupId.contains(group2Id));
                System.assertEquals(true, setUserOrGroupId.contains(adminId));
            }
        }

        @isTest 
        static void testChangeSurveyAssignmentOwner() {

            SurveyTestingUtil surveyTestingUtil = new SurveyTestingUtil();
            String surveyId = surveyTestingUtil.surveyId;
            String ownerId = surveyTestingUtil.ownerId;
            String newOwnerId = surveyTestingUtil.newOwnerId;
            String adminId = surveyTestingUtil.adminId;
            String taker1Id = surveyTestingUtil.taker1Id;
            String groupId = surveyTestingUtil.groupId;
            
            User u = [Select Id From User where id = :ownerId];
            System.runAs(u) {
                
                Survey__c survey = [Select id, OwnerId From Survey__c where id = :surveyId];
                survey.OwnerId = newOwnerId;
                update survey;
            }

            User u2 = [Select Id From User where id = :newOwnerId];
            System.runAs(u2) {

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, u2.id, 
                        SurveyAssignmentObjectUtil.NATURE_ADMINISTRATOR);

                Set<String> setUserOrGroupId = new Set<String>();
                System.assertEquals(1, listAssignment.size());//DTT: Owner Doen't count
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment) {
                    System.assertEquals('User', r.Type);
                    //System.assertEquals(true, r.HasDeleteAccess);
                    setUserOrGroupId.add(r.UserId);
                }   
                System.assertEquals(false, setUserOrGroupId.contains(newOwnerId));//change by DTT
                System.assertEquals(true, setUserOrGroupId.contains(adminId));
                System.assertEquals(false, setUserOrGroupId.contains(ownerId));

                List<SurveyAssignmentObjectUtil.SurveyAssignmentResult> listAssignment2
                    = SurveyAssignmentObjectUtil.getSurveyAssignment(surveyId, u2.id, 
                        SurveyAssignmentObjectUtil.NATURE_TAKER);

                Set<String> setUserOrGroupId2 = new Set<String>();
                System.assertEquals(3, listAssignment2.size());
                for (SurveyAssignmentObjectUtil.SurveyAssignmentResult r : listAssignment2) {
                    //System.assertEquals(true, r.HasDeleteAccess);
                    if (String.isNotBlank(r.UserId)) {
                        setUserOrGroupId2.add(r.UserId);
                        System.assertEquals('User', r.Type);
                    }
                    if (String.isNotBlank(r.GroupId)) {
                        setUserOrGroupId2.add(r.GroupId);
                        System.assertEquals('Group', r.Type);
                    }
                }   
                System.assertEquals(true, setUserOrGroupId2.contains(groupId));
                System.assertEquals(true, setUserOrGroupId2.contains(taker1Id));
            }
        }
    }