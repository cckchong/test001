@isTest
private class TestMultiselectControllerVFClass {
    static testMethod void testMultiselectController() {
        MultiselectController c = new MultiselectController();
        
        c.listLeftOptions = new List<SelectOption>();
        c.listRightOptions = new List<SelectOption>();

        c.leftOptionsHidden = 'A&a&b&b&C&c';
        c.rightOptionsHidden = '';
        
        System.assertEquals(c.listLeftOptions.size(), 3);
        System.assertEquals(c.listRightOptions.size(), 0);
    }
}