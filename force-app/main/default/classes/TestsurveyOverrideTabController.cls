@isTest
private class TestsurveyOverrideTabController {
    
    @isTest static void testConstructListViewOptions() {
        SurveyOverrideTabController controller = new SurveyOverrideTabController();
        List<SelectOption> opts = controller.getListViewOption();

        PageReference pr = Page.SurveyOverrideTab;
        Test.setCurrentPage(pr);
        System.assertEquals(SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID, controller.selectedListId);

        System.assertEquals(4, opts.size());
        System.assertEquals(SurveyConfigurationController.SURVEY_All_SURVEYS_LIST_VIEW_ID, opts.get(0).getValue());
        System.assertEquals('All Surveys', opts.get(0).getLabel());
        
        System.assertEquals(SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID, opts.get(1).getValue());
        System.assertEquals('All My Surveys', opts.get(1).getLabel());

        System.assertEquals(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, opts.get(2).getValue());
        System.assertEquals('My Active Surveys', opts.get(2).getLabel());

        System.assertEquals(SurveyConfigurationController.SURVEY_MY_INACTIVE_SURVEYS_LIST_VIEW_ID, opts.get(3).getValue());
        System.assertEquals('My Inactive Surveys', opts.get(3).getLabel());      
    }
    
    @isTest static void testNavigateToListView() {

        PageReference pr = Page.SurveyOverrideTab;
        Test.setCurrentPage(pr);

        SurveyOverrideTabController controller = new SurveyOverrideTabController();
        controller.setListViewId(SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID);
        PageReference navigatePr = controller.navigateToListView();
        System.assertEquals('/apex/SurveyCustomizeListView?selectedListId=' + SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID, 
            navigatePr.getUrl());
        System.assertEquals(SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID, controller.getListViewId());

        controller.setListViewId(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID);
        navigatePr = controller.navigateToListView();
        System.assertEquals('/apex/SurveyCustomizeListView?selectedListId=' + SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, 
            navigatePr.getUrl());
        System.assertEquals(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, controller.getListViewId());

        controller.setListViewId(SurveyConfigurationController.SURVEY_MY_INACTIVE_SURVEYS_LIST_VIEW_ID);
        navigatePr = controller.navigateToListView();
        System.assertEquals('/apex/SurveyCustomizeListView?selectedListId=' + SurveyConfigurationController.SURVEY_MY_INACTIVE_SURVEYS_LIST_VIEW_ID, 
            navigatePr.getUrl());
        System.assertEquals(SurveyConfigurationController.SURVEY_MY_INACTIVE_SURVEYS_LIST_VIEW_ID, controller.getListViewId());
    }
    

    @isTest static void testSelectedListId() {

        PageReference pr = Page.SurveyOverrideTab;
        pr.getParameters().put('selectedListId', SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID);
        Test.setCurrentPage(pr);
        SurveyOverrideTabController controller = new SurveyOverrideTabController();
        System.assertEquals(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, controller.selectedListId);
        System.assertEquals(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, controller.getListViewId());
    }
}