@isTest
private class TestCustomerOrderLogTrigger {
    /*
        This test performs a normal use case for 'Return re-submit'
        
        TGA Init -> PPC Confirm (Requirement Not Meet) -> PPC Impact -> TGA Feedback (Return Resubmit)
    
    */
    static testMethod void normalReturnResubmit() {
        Id logId = null;
        
        // prepare a recordtype name to Id mapping
        Map<String, Id> recordTypeNameIdMap = new Map<String, Id>();
        for (RecordType rt: [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Customer_Order_Log__c']) {
            recordTypeNameIdMap.put(rt.DeveloperName, rt.Id);
        }
        
        Test.startTest();
        // TGA to initialize a log
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            
            
            // prepare new log data
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            
            // insert, then verify recordType, status, manager and VP fields
            insert log;
            logId = log.Id;
            
            Customer_Order_Log__c logAfterInsert = [SELECT Manager__c, VP__c, RecordTypeId, Status__c FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals(TestCustomerOrderLogDataFactory.getTGAManagerUser().Id, logAfterInsert.Manager__c);
            System.assertEquals(TestCustomerOrderLogDataFactory.getTGAVPUser().Id, logAfterInsert.VP__c);
            System.assertEquals(recordTypeNameIdMap.get('TGA_Initialize'), logAfterInsert.RecordTypeId);
            System.assertEquals('Open', logAfterInsert.Status__c);
            
            // perform 'TGA submit', assert recordType and status
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(log.Id));
            Customer_Order_Log__c logAfterTGASubmit = [SELECT RecordTypeId, From_TGA_to_HK_PPC__c, Status__c FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals(recordTypeNameIdMap.get('PPC_Confirm'), logAfterTGASubmit.RecordTypeId);
            System.assertEquals('Processing', logAfterTGASubmit.Status__c);
            
        }
        
        // PPC to confirm & Impact
        System.runAs(TestCustomerOrderLogDataFactory.getPPCUser()) {
            Customer_Order_Log__c log = new Customer_Order_Log__c();
            log = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmNegative(log);
            log.Id = logId;
            
            update log;
            
            // perform PPC submit
            CustomerOrderLogButtonHandler.handlePPCSubmitClicked(String.valueOf(log.Id));
            Customer_Order_Log__c logAfterPPCConfirm = [SELECT RecordTypeId, From_HK_PPC__c, Impacted_Customer__c FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals(recordTypeNameIdMap.get('PPC_Impact'), logAfterPPCConfirm.RecordTypeId);
            // impacted customer should be default as -NIL-
            System.assertEquals('-NIL-', logAfterPPCConfirm.Impacted_Customer__c);

            // input PPC Impact mandatory fields
            log = TestCustomerOrderLogDataFactory.prepareLogPPCImpactNegative(log);
            
            update log;
            
            // should show warning as no changes in 'Data Confirm' section
            System.assert(CustomerOrderLogButtonHandler.showWarningMsgForPPCImpact(String.valueOf(log.Id)));
            
            // perform PPC impact
            CustomerOrderLogButtonHandler.handlePPCImpact(String.valueOf(log.Id));
            Customer_Order_Log__c logAfterPPCImpact = [SELECT RecordTypeId, From_HK_PPC__c, Gap_Confirmed_vs_Expected_dely__c, Requested_Delivery__c, Confirmed_Delivery__c, Status__c FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals(recordTypeNameIdMap.get('TGA_Feedback_Customer'), logAfterPPCImpact.RecordTypeId);
            System.assertEquals(String.valueOf(logAfterPPCImpact.Requested_Delivery__c.daysBetween(logAfterPPCImpact.Confirmed_Delivery__c)),
                    logAfterPPCImpact.Gap_Confirmed_vs_Expected_dely__c);
            System.assertEquals('Waiting for Confirmation', logAfterPPCImpact.Status__c);
            
        }
        
        // TGA to feedback a log
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            Customer_Order_Log__c log = new Customer_Order_Log__c();
            log = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackReturnResubmit(log);
            log.Id = logId;
            
            update log;
            
            // get full log, for comparison of 'previous version'
            Customer_Order_Log__c logBeforeComplete = [SELECT Version__c,
                                Customer__c,
                                Brand__c,
                                Product__c,
                                Dipping_Flag__c,
                                Plant__c,
                                Requested_Qty__c,
                                Requested_Delivery__c,
                                Reserved_Qty__c,
                                From_Customer_to_TGA__c,
                                From_TGA_to_HK_PPC__c,
                                From_HK_PPC__c,
                                Meet_Customer_Requirement__c,
                                Remarks__c,
                                Remark_2__c,
                                Remark_3__c,
                                From_SVP_If_need_prioritization__c,
                                Confirmed_Delivery__c,
                                Impacted_Customer__c,
                                Impacted_Volume__c,
                                Factory_transfer_if_any__c,
                                From_TGA_to_Customer__c,
                                Customer_Confirmation__c,
                                KPI_Exclude_Holidays__c,
                                KPI_3_days__c,
                                Fabric_dely_ETA_Fty__c,
                                SMV__c,
                                Washing_Finishing__c,
                                PE_item__c,
                                Others_1__c,
                                Others_2__c
                                FROM Customer_Order_Log__c WHERE Id = :log.Id];
                                
            System.assertEquals(CustomerOrderLogUtil.getWorkingDays(logBeforeComplete.From_Customer_to_TGA__c, logBeforeComplete.From_TGA_to_Customer__c.date()),
                        logBeforeComplete.KPI_Exclude_Holidays__c);
            System.assertNotEquals(null, logBeforeComplete.From_TGA_to_Customer__c);
            // perform Case Complete
            CustomerOrderLogButtonHandler.handleCaseCompletedClicked(String.valueOf(log.Id));
            Customer_Order_Log__c logAfterComplete = [SELECT RecordTypeId, Version__c, Status__c FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals(recordTypeNameIdMap.get('TGA_Initialize'), logAfterComplete.RecordTypeId);
            System.assertEquals(2, logAfterComplete.Version__c);
            System.assertEquals('Open', logAfterComplete.Status__c);
            
            // assert history 
            Customer_Order_Log_History__c logHistory = [SELECT Version__c,
                                Customer__c,
                                Brand__c,
                                Product__c,
                                Dipping_Flag__c,
                                Plant__c,
                                Requested_Qty__c,
                                Requested_Delivery__c,
                                Reserved_Qty__c,
                                From_Customer_to_TGA__c,
                                From_TGA_to_HK_PPC__c,
                                From_HK_PPC__c,
                                Meet_Customer_Requirement__c,
                                Remarks__c,
                                Remark_2__c,
                                Remark_3__c,
                                From_SVP_If_need_prioritization__c,
                                Confirmed_Delivery__c,
                                Impacted_Customer__c,
                                Impacted_Volume__c,
                                Factory_transfer_if_any__c,
                                From_TGA_to_Customer__c,
                                Customer_Confirmation__c,
                                KPI_3_days_text__c,
                                Fabric_dely_ETA_Fty__c,
                                SMV__c,
                                Washing_Finishing__c,
                                PE_item__c,
                                Others_1__c,
                                Others_2__c
                                FROM Customer_Order_Log_History__c WHERE MasterLog__c = :log.Id AND Version__c = 1];
            System.assertNotEquals(null, logHistory);
            assertPreviousVersion(logBeforeComplete, logHistory);
            
        }
        
        Test.stopTest();
        
    }
    
    /*
        Test duplicated log creation
    */
    static testMethod void testBlockDuplicatedCreation() {
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            insert log;
            Customer_Order_Log__c duplicatedLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            Database.SaveResult sr = Database.insert(duplicatedLog, false);
            System.assert(!sr.isSuccess());
        }
        
        Test.stopTest();
    }
    
    /*
        Tests the create permission for each party
    */
    static testMethod void testLogCreationPermission() {
        Test.startTest();
        // system admin, expected success
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            log.Requested_Qty__c += 1;
            Database.SaveResult sr = Database.insert(log, false);
            
            System.assert(sr.isSuccess());
        }
        
        // app owner expected fail
        System.runAs(TestCustomerOrderLogDataFactory.getAppOwner()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            log.Requested_Qty__c += 2;
            Database.SaveResult sr = Database.insert(log, false);
            
            System.assert(!sr.isSuccess());
        }
        
        // tga user, expected success
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            log.Requested_Qty__c += 3;
            Database.SaveResult sr = Database.insert(log, false);
            
            System.assert(sr.isSuccess());
        }
        
        // tga pim admin, expected success
        System.runAs(TestCustomerOrderLogDataFactory.getTGAPIMAdmin()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            log.Requested_Qty__c += 4;
            Database.SaveResult sr = Database.insert(log, false);
            
            System.assert(sr.isSuccess());
        }
        
        // tga ppc user, expected fail
        System.runAs(TestCustomerOrderLogDataFactory.getPPCUser()) {
            Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            log.Requested_Qty__c += 5;
            Database.SaveResult sr = Database.insert(log, false);
            
            System.assert(!sr.isSuccess());
        }
        
        Test.stopTest();
    }
    
    /*
        Test the edit permission for each party at each RecordType (part 1, splitted to avoid hitting 101 limit)
    */
    static testMethod void testEditPermission1() {
        Customer_Order_Log__c initLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        
        Database.SaveResult sr = null;
        
        // insert logs
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            insert new Customer_Order_Log__c[] {initLog, ppcConfirmLog, ppcImpactLog, tgaFbLog};
        }
        
        // simulate button clicks, this is needed because sharing rule changes are defined when "TGA Submit" and "PPC Impact" buttons clicked
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(ppcConfirmLog.Id));
            
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(ppcImpactLog.Id));
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcImpactLog);
            update ppcImpactLog;
            CustomerOrderLogButtonHandler.handlePPCSubmitClicked(String.valueOf(ppcImpactLog.Id));
            
            Test.startTest();
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(tgaFbLog.Id));
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(tgaFbLog);
            update tgaFbLog;
            CustomerOrderLogButtonHandler.handlePPCSubmitClicked(String.valueOf(tgaFbLog.Id));
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(tgaFbLog);
            update tgaFbLog;
            CustomerOrderLogButtonHandler.handlePPCImpact(String.valueOf(tgaFbLog.Id));
            
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            initLog.Requested_Qty__c += 100;
            sr = Database.update(initLog, false);
            System.assert(sr.isSuccess());
            
            ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcConfirmLog);
            sr = Database.update(ppcConfirmLog, false);
            System.assert(!sr.isSuccess());
            
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(ppcImpactLog);
            sr = Database.update(ppcImpactLog, false);
            System.assert(!sr.isSuccess());
            
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(tgaFbLog);
            sr = Database.update(tgaFbLog, false);
            System.assert(sr.isSuccess());
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getPPCUser()) {
            initLog.Requested_Qty__c += 100;
            sr = Database.update(initLog, false);
            System.assert(!sr.isSuccess());
            
            ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcConfirmLog);
            sr = Database.update(ppcConfirmLog, false);
            System.assert(sr.isSuccess());
            
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(ppcImpactLog);
            sr = Database.update(ppcImpactLog, false);
            System.assert(sr.isSuccess());
            
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(tgaFbLog);
            sr = Database.update(tgaFbLog, false);
            System.assert(!sr.isSuccess());
        }
                    
        Test.stopTest();    
    }
    
    /*
        Test the edit permission for each party at each RecordType (part 2, splitted to avoid hitting 101 limit)
    */
    static testMethod void testEditPermission2() {
        Customer_Order_Log__c initLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Customer_Order_Log__c tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        
        Database.SaveResult sr = null;
        
        // insert logs
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            insert new Customer_Order_Log__c[] {initLog, ppcConfirmLog, ppcImpactLog, tgaFbLog};
        }
        
        // simulate button clicks, this is needed because sharing rule changes are defined when "TGA Submit" and "PPC Impact" buttons clicked
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(ppcConfirmLog.Id));
            
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(ppcImpactLog.Id));
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcImpactLog);
            update ppcImpactLog;
            CustomerOrderLogButtonHandler.handlePPCSubmitClicked(String.valueOf(ppcImpactLog.Id));
            
            CustomerOrderLogButtonHandler.handleTGASubmitClicked(String.valueOf(tgaFbLog.Id));
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(tgaFbLog);
            update tgaFbLog;
            
            Test.startTest();
            CustomerOrderLogButtonHandler.handlePPCSubmitClicked(String.valueOf(tgaFbLog.Id));
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(tgaFbLog);
            update tgaFbLog;
            CustomerOrderLogButtonHandler.handlePPCImpact(String.valueOf(tgaFbLog.Id));
            
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getAppOwner()) {
            initLog.Requested_Qty__c += 100;
            sr = Database.update(initLog, false);
            System.assert(sr.isSuccess());
            
            ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcConfirmLog);
            sr = Database.update(ppcConfirmLog, false);
            System.assert(sr.isSuccess());
            
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(ppcImpactLog);
            sr = Database.update(ppcImpactLog, false);
            System.assert(sr.isSuccess());
            
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(tgaFbLog);
            sr = Database.update(tgaFbLog, false);
            System.assert(sr.isSuccess());
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            initLog.Requested_Qty__c += 100;
            sr = Database.update(initLog, false);
            System.assert(sr.isSuccess());
            
            ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcConfirmLog);
            sr = Database.update(ppcConfirmLog, false);
            System.assert(sr.isSuccess());
            
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(ppcImpactLog);
            sr = Database.update(ppcImpactLog, false);
            System.assert(sr.isSuccess());
            
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(tgaFbLog);
            sr = Database.update(tgaFbLog, false);
            System.assert(sr.isSuccess());
        }
        
        // test non TGA owner, should have no edit right
        System.runAs(TestCustomerOrderLogDataFactory.getTGAPIMAdmin()) {
            initLog.Requested_Qty__c += 100;
            sr = Database.update(initLog, false);
            System.assert(!sr.isSuccess());
            
            ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(ppcConfirmLog);
            sr = Database.update(ppcConfirmLog, false);
            System.assert(!sr.isSuccess());
            
            ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(ppcImpactLog);
            sr = Database.update(ppcImpactLog, false);
            System.assert(!sr.isSuccess());
            
            tgaFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(tgaFbLog);
            sr = Database.update(tgaFbLog, false);
            System.assert(!sr.isSuccess());
        }
        
        Test.stopTest();    
    }
    
    static testMethod void testImpactedCustomerNilWarning() {
        Customer_Order_Log__c ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactNegative(null);
        
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            insert ppcImpactLog;
            ppcImpactLog.Impacted_Customer__c = '-NIL-;BURBERRY LTD';
            
            Database.SaveResult sr = Database.update(ppcImpactLog, false);
            System.assert(!sr.isSuccess());
        }
                    
        Test.stopTest();    
    }
    
    /*
        Test both mark delete and physical delete
    */
    static testMethod void testDelete() {
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            // test mark delete
            Customer_Order_Log__c tgaInitializeLog = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
            insert tgaInitializeLog;
            
            CustomerOrderLogButtonHandler.handleDeleteClicked(String.valueOf(tgaInitializeLog.Id));
            tgaInitializeLog = [SELECT Id, RecordType.DeveloperName, Status__c, Requested_Qty__c FROM Customer_Order_Log__c WHERE Id = :tgaInitializeLog.Id];
            
            System.assert(tgaInitializeLog.RecordType.DeveloperName == 'Deleted');
            System.assertEquals('Deleted', tgaInitializeLog.Status__c);
            
            // test no edit after marking delete
            tgaInitializeLog.Requested_Qty__c += 100;
            Database.SaveResult sr = Database.update(tgaInitializeLog, false);
            System.assert(!sr.isSuccess());
            
            // test physical delete
            Database.DeleteResult dr = Database.delete(tgaInitializeLog, false);
            System.assert(!dr.isSuccess());
            
            // test can delete if version > 1
            Customer_Order_Log__c tgaFBLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackReturnResubmit(null);
            tgaFBLog.Requested_Qty__c += 100;
            
            insert tgaFBLog;
            
            CustomerOrderLogButtonHandler.handleCaseCompletedClicked(String.valueOf(tgaFBLog.Id));
            System.debug(CustomerOrderLogButtonHandler.handleDeleteClicked(String.valueOf(tgaFBLog.Id)));
            
            tgaFBLog = [SELECT Id, RecordType.DeveloperName, Status__c FROM Customer_Order_Log__c WHERE Id = :tgaFBLog.Id];
            
            System.assert(tgaFBLog.RecordType.DeveloperName == 'Deleted');
            System.assertEquals('Deleted', tgaFBLog.Status__c);
        }
        
        Test.stopTest();
        
    }
    
    /*
        Test case complete status, and no edit after complete
    */
    static testMethod void testCaseComplete() {
        Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(null);
        
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            insert log;
            CustomerOrderLogButtonHandler.handleCaseCompletedClicked(String.valueOf(log.Id));
            
            Customer_Order_Log__c logAfterComplete = [SELECT Id, Status__c, Requested_Qty__c  FROM Customer_Order_Log__c WHERE Id = :log.Id];
            System.assertEquals('Confirmed', logAfterComplete.Status__c);
            
            logAfterComplete.Requested_Qty__c += 100;
            Database.SaveResult sr = Database.update(logAfterComplete, false);
            System.assert(!sr.isSuccess());
            
        }
        
        Test.stopTest();
    }
    
    
    /*
        Test drop
        
        1. Test drop successful when RecordType = 'PPC Confirm', 'PPC Impact', 'TGA Feedback Customer'
        2. Test drop successful RecordType = 'Completed' AND Customer_Confirmation__c = 'Accept'
        3. Test drop fail when RecordType = 'Complete', Customer_Confirmation__c != 'Accept'
        4. Test drop fail when login user not PPC
        
    */
    static testMethod void testDrop() {
        // prepare a recordtype name to Id mapping
        Map<String, Id> recordTypeNameIdMap = new Map<String, Id>();
        for (RecordType rt: [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Customer_Order_Log__c']) {
            recordTypeNameIdMap.put(rt.DeveloperName, rt.Id);
        }
        
        // prepare logs
        Customer_Order_Log__c ppcConfirmLog = TestCustomerOrderLogDataFactory.prepareLogPPCConfirmPositive(null);
        Customer_Order_Log__c ppcImpactLog = TestCustomerOrderLogDataFactory.prepareLogPPCImpactPositive(null);
        Customer_Order_Log__c ppcTGAFbLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(null);
        Customer_Order_Log__c completeAcceptLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(null);
        Customer_Order_Log__c completeRejectLog = TestCustomerOrderLogDataFactory.prepareLogTGAFeedbackAccept(null);
        
        
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            insert ppcConfirmLog;
            ppcImpactLog.Requested_Qty__c += 100;
            insert ppcImpactLog;
            ppcTGAFbLog.Requested_Qty__c += 200;
            insert ppcTGAFbLog;
            
            completeRejectLog.Customer_Confirmation__c = 'Reject';
            completeRejectLog.Requested_Qty__c += 300;
            insert completeRejectLog;
            
            completeAcceptLog.Requested_Qty__c += 400;
            insert completeAcceptLog;
            
            CustomerOrderLogButtonHandler.handleCaseCompletedClicked(String.valueOf(completeRejectLog.Id));
            
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getPPCUser()) {
            Test.startTest();
            
            // test isUserPpcOrAdmin, should return true
            System.assert(CustomerOrderLogDropButtonHandler.isUserPpcOrAdmin(String.valueOf(UserInfo.getUserId())));
            
            // test Drop when PPC Confirm
            CustomerOrderLogDropButtonHandler.handleDrop(String.valueOf(ppcConfirmLog.Id), 'drop it~');
            Customer_Order_Log__c tmpLogForAssert = [SELECT Id, RecordType.DeveloperName FROM Customer_Order_Log__c WHERE Id = :ppcConfirmLog.Id];
            System.assertEquals('Dropped', tmpLogForAssert.RecordType.DeveloperName);
            
            // test Drop when PPC Impact
            CustomerOrderLogDropButtonHandler.handleDrop(String.valueOf(ppcImpactLog.Id), 'drop it~');
            tmpLogForAssert = [SELECT Id, RecordType.DeveloperName FROM Customer_Order_Log__c WHERE Id = :ppcImpactLog.Id];
            System.assertEquals('Dropped', tmpLogForAssert.RecordType.DeveloperName);
            
            // test Drop when TGA Feedback Customer
            CustomerOrderLogDropButtonHandler.handleDrop(String.valueOf(ppcTGAFbLog.Id), 'drop it~');
            tmpLogForAssert = [SELECT Id, RecordType.DeveloperName FROM Customer_Order_Log__c WHERE Id = :ppcTGAFbLog.Id];
            System.assertEquals('Dropped', tmpLogForAssert.RecordType.DeveloperName);
            
            // test Drop when Completed, Customer Confirmation = Accept
            System.assert(CustomerOrderLogDropButtonHandler.isCaseCompletedAccepted(String.valueOf(completeAcceptLog.Id)));
            CustomerOrderLogDropButtonHandler.handleDrop(String.valueOf(completeAcceptLog.Id), 'drop it~');
            tmpLogForAssert = [SELECT Id, RecordType.DeveloperName FROM Customer_Order_Log__c WHERE Id = :completeAcceptLog.Id];
            System.assertEquals('Dropped', tmpLogForAssert.RecordType.DeveloperName);
            
            // test no drop when Completed, Customer Confirmation != Accept
            System.assert(!CustomerOrderLogDropButtonHandler.isCaseCompletedAccepted(String.valueOf(completeRejectLog.Id)));
            
        }
        
        Test.stopTest();
    }
        
    static testMethod void testChangeOwner() {
        Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogTGAInitialize();
        Database.SaveResult sr = null;
        
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            insert log;
            log.ownerId = TestCustomerOrderLogDataFactory.getTGAPIMAdmin().Id;
            sr = Database.update(log, false);
            System.assert(sr.isSuccess());      // tga owner can transfer
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getTGAPIMAdmin()) {
            log.ownerId = TestCustomerOrderLogDataFactory.getTGAUser().Id;
            sr = Database.update(log, false);
            System.assert(sr.isSuccess());      // tga owner can transfer
            
            log.ownerId = TestCustomerOrderLogDataFactory.getTGAPIMAdmin().Id;
            sr = Database.update(log, false);
            System.assert(sr.isSuccess());      // PIM admin can transfer
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getTGAUser()) {
            log.ownerId = TestCustomerOrderLogDataFactory.getTGAUser().Id;
            sr = Database.update(log, false);
            System.assert(!sr.isSuccess());     // non owner cannot transfer
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            log.ownerId = TestCustomerOrderLogDataFactory.getSystemAdmin().Id;
            sr = Database.update(log, false);
            System.assert(sr.isSuccess());      // system admin can transfer
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getAppOwner()) {
            log.ownerId = TestCustomerOrderLogDataFactory.getAppOwner().Id;
            sr = Database.update(log, false);
            System.assert(sr.isSuccess());      // app owner can transfer
        }
        
        System.runAs(TestCustomerOrderLogDataFactory.getPPCUser()) {
            log.ownerId = TestCustomerOrderLogDataFactory.getPPCUser().Id;
            sr = Database.update(log, false);
            System.assert(!sr.isSuccess());     // ppc cannot transfer
        }
        
        Test.stopTest();
    }
    
    static testMethod void testPPCImpactWarning() {
        Customer_Order_Log__c log = TestCustomerOrderLogDataFactory.prepareLogPPCImpactNegative(null);
        Database.SaveResult sr = null;
        
        Test.startTest();
        System.runAs(TestCustomerOrderLogDataFactory.getSystemAdmin()) {
            insert log;
            
            // change Meet_Customer_Requirement__c, Remarks__c and Remark_2__c
            log.Meet_Customer_Requirement__c = 'YES';
            update log;
            
            // should NOT show warning as no changes in 'Data Confirm' section, for log.Meet_Customer_Requirement__c = 'YES'
            System.assert(!CustomerOrderLogButtonHandler.showWarningMsgForPPCImpact(String.valueOf(log.Id)));
            
            log.Meet_Customer_Requirement__c = 'NO';
            log.Remarks__c = 'Capactiy';
            log.Remark_2__c = 'No, cannot meet';
            update log;
            
            // should NOT show warning as no changes in 'Data Confirm' section, for changing all 3 values
            System.assert(!CustomerOrderLogButtonHandler.showWarningMsgForPPCImpact(String.valueOf(log.Id)));
            
        }
        
        Test.stopTest();
    }
    
    private static void assertPreviousVersion(Customer_Order_Log__c log, Customer_Order_Log_History__c hist) {
        System.assertEquals(log.Version__c, hist.Version__c);
        System.assertEquals(log.Customer__c, hist.Customer__c);
        System.assertEquals(log.Brand__c, hist.Brand__c);
        System.assertEquals(log.Product__c, hist.Product__c);
        System.assertEquals(log.Dipping_Flag__c, hist.Dipping_Flag__c);
        System.assertEquals(log.Plant__c, hist.Plant__c);
        System.assertEquals(log.Requested_Qty__c, hist.Requested_Qty__c);
        System.assertEquals(log.Requested_Delivery__c, hist.Requested_Delivery__c);
        System.assertEquals(log.Reserved_Qty__c, hist.Reserved_Qty__c);
        System.assertEquals(log.From_Customer_to_TGA__c, hist.From_Customer_to_TGA__c);
        System.assertEquals(log.From_TGA_to_HK_PPC__c, hist.From_TGA_to_HK_PPC__c);
        System.assertEquals(log.From_HK_PPC__c, hist.From_HK_PPC__c);
        System.assertEquals(log.Meet_Customer_Requirement__c, hist.Meet_Customer_Requirement__c);
        System.assertEquals(log.Remarks__c, hist.Remarks__c);
        System.assertEquals(log.Remark_2__c, hist.Remark_2__c);
        System.assertEquals(log.Remark_3__c, hist.Remark_3__c);
        System.assertEquals(log.From_SVP_If_need_prioritization__c, hist.From_SVP_If_need_prioritization__c);
        System.assertEquals(log.Confirmed_Delivery__c, hist.Confirmed_Delivery__c);
        System.assertEquals(log.Impacted_Customer__c, hist.Impacted_Customer__c);
        System.assertEquals(log.Impacted_Volume__c, hist.Impacted_Volume__c);
        System.assertEquals(log.Factory_transfer_if_any__c, hist.Factory_transfer_if_any__c);
        System.assertEquals(log.From_TGA_to_Customer__c, hist.From_TGA_to_Customer__c);
        System.assertEquals(log.Customer_Confirmation__c, hist.Customer_Confirmation__c);
        System.assertEquals(log.KPI_3_days__c, hist.KPI_3_days_text__c);
        System.assertEquals(log.Fabric_dely_ETA_Fty__c , hist.Fabric_dely_ETA_Fty__c );
        System.assertEquals(log.SMV__c , hist.SMV__c );
        System.assertEquals(log.Washing_Finishing__c , hist.Washing_Finishing__c );
        System.assertEquals(log.PE_item__c, hist.PE_item__c);
        System.assertEquals(log.Others_1__c , hist.Others_1__c );
        System.assertEquals(log.Others_2__c , hist.Others_2__c );
        
    }
    
}