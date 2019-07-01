@isTest
private class TestUserTriggerHandler {
    
    static testMethod void myUnitTest() {                
        //Create Chatter Group
        /*
        List<CollaborationGroup> grps = new List<CollaborationGroup>();
        CollaborationGroup grp = new CollaborationGroup();
        grp.Name = 'ACG-General-Apparel-S';
        grp.CollaborationType  = 'Public';
        grps.add(grp);
        
        CollaborationGroup grp2 = new CollaborationGroup();
        grp2.Name = 'ACG-General-TALCORP-S';
        grp2.CollaborationType  = 'Public';
        grps.add(grp2);
        
        CollaborationGroup grp3 = new CollaborationGroup();
        grp3.Name = 'ACG-IT-TALCORP-S';
        grp3.CollaborationType  = 'Public';
        grps.add(grp3);
        try {
            insert grps;
        } catch (exception e) {
            
        }
        */
        
        //Added by TAL (Twinkle LI) @20170824 for APP Public Group
        List<Group> listAppGroup = new List<Group>();
        listAppGroup.add(new Group(Name = 'APP-IT'));
        insert listAppGroup;
        
        User usr = TestClassUtil.getTestACGSystemAdminUser();
        usr.IsActive = true;
        usr.Function_short__c = 'IT';
        insert usr;
        
        usr = TestClassUtil.getTestACGSystemAdminUser();
        usr.IsActive = true;
        usr.Department__c = 'IT';
        insert usr;
        
        usr = TestClassUtil.getTestACGSystemAdminUser();
        usr.IsActive = true;
        usr.Section_short__c = 'IT';
        insert usr;
        
        system.assertEquals(true, usr.Id != null);
        
        usr.Default_Landing_Page__c = 'TALCORP';
        usr.Portal_Language__c = 'en';        
        update usr;        
        
        usr.Administrative_Category__c = 'General';
        usr.Administrative_Target__c = 'Apparel;TALCORP';               
        update usr;
        
        usr.Administrative_Category__c = 'General;IT';
        usr.Administrative_Target__c = 'Apparel;TALCORP';               
        update usr;
        
        usr.Administrative_Category__c = 'General';
        usr.Administrative_Target__c = 'TALCORP';               
        update usr;
    }
}