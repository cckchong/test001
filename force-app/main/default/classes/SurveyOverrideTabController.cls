// Created by Connie
// Date: 2016-07-04
// Retrieve RecentlyViewItem in tab
public virtual with sharing class SurveyOverrideTabController {

    // added by connie. testing
    public String selectedListId { get; set; }
    private List<SelectOption> listViewOption;
    private String listViewId;
    public boolean isAdmin;

    public String getDefaultListViewId { get; set; }

    public SurveyOverrideTabController() {
    
        listViewOption = new List<SelectOption>();
        isAdmin=false;//add by DTT
        isAdmin();//add by DTT
        system.debug('This is Admin'+isAdmin);
        resetListViewId();

        if (ApexPages.currentPage().getParameters().containsKey('selectedListId')) {
            selectedListId = ApexPages.currentPage().getParameters().get('selectedListId');
            System.debug('selectedListId parameter found. Id: ' + selectedListId);
        } else {
            //selectedListId = '00Bp0000000MsB9';
            selectedListId = SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID;
            System.debug('Default selectedListId id: ' + selectedListId);
        }
        listViewId = selectedListId;
        System.debug('listViewId in SurveyOverrideTabController: ' + listViewId);

        
    }

    //add by DTT
    public void isAdmin()
    {
        Id currentID=UserInfo.getUserId();
        User currentUser=[select id, name, profile.name from user where id=:currentID];
        if(currentUser!=null && currentUser.profile.name=='System Administrator')
        {
            isAdmin=true;
            return;
        }
        isAdmin=false;
        

    }
    //add by DTT

    // list view id returned by standard set controller is not unique and does not match the ids of Survey list views
    private void resetListViewId() {
/*        listViewOption.add(new SelectOption('00Bp0000000MsB9', 'All My Surveys'));
        listViewOption.add(new SelectOption('00Bp0000000Q5I5', 'My Active Surveys'));
        listViewOption.add(new SelectOption('00Bp0000000Ms7R', 'My Inactive Surveys'));
        */
        if(isAdmin)
        {
            listViewOption.add(new SelectOption(SurveyConfigurationController.SURVEY_All_SURVEYS_LIST_VIEW_ID, 'All Surveys'));
        }
        listViewOption.add(new SelectOption(SurveyConfigurationController.SURVEY_ALL_MY_SURVEY_LIST_VIEW_ID, 'All My Surveys'));
        listViewOption.add(new SelectOption(SurveyConfigurationController.SURVEY_MY_ACTIVE_SURVEYS_LIST_VIEW_ID, 'My Active Surveys'));
        listViewOption.add(new SelectOption(SurveyConfigurationController.SURVEY_MY_INACTIVE_SURVEYS_LIST_VIEW_ID, 'My Inactive Surveys'));
    }

    public String getListViewId() {
        return listViewId;
    }

    public PageReference navigateToListView() {
        System.debug('list view id = ' + listViewId);
        PageReference pr = new PageReference('/apex/SurveyCustomizeListView');
        pr.getParameters().put('selectedListId', listViewId);
        pr.setRedirect(true);
        return pr;
    }

    public void setListViewId(String otherListViewId) {
        listViewId = otherListViewId;
    }

    // retrieve all list view ids and names of Survey
    public List<SelectOption> getListViewOption() {
        return listViewOption;
    }
    // end     
}