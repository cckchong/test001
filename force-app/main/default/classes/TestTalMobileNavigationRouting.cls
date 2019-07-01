/**
 * Test of TalMobileNavigationRouting
 */
@isTest
private class TestTalMobileNavigationRouting {

    static testMethod void myUnitTest() {
        TalMobileNavigationRouting TalMobileNav = new TalMobileNavigationRouting();
        
        TalMobileNav.navResultObjectId = 'Library_Item__c';
        TalMobileNav.navResultUrl = 'www.tal.com';
        TalMobileNav.infoMessage = 'abc';
        system.assertEquals('abc',TalMobileNav.infoMessage );
        TalMobileNav.navResult = TalMobileNav.navResult;
    }
}