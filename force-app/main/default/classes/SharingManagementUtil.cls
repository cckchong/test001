/*
 * Utility classes for dealing with Sharing Rules across the application 
 */
public without sharing class SharingManagementUtil {
    
    //////////////////
    // Library
    //////////////////
    public static void createSharingRulesForLibraryRequest(List<Library_Item_Request__c> libItemReqs) {
    	List<Library_Item_Request__Share> libItemReqsSharingRules = new List<Library_Item_Request__Share>();
    	for(Library_Item_Request__c req: libItemReqs) {
    		String shareAccessLevel = 'Edit';    		
    		if(req.Owner_1__c != null && req.Owner_1__c != req.OwnerId) {
    			libItemReqsSharingRules.add(new Library_Item_Request__Share(AccessLevel = shareAccessLevel, ParentId = req.Id, UserOrGroupId = req.Owner_1__c ));
    		}
    		if(req.Owner_2__c != null && req.Owner_2__c != req.OwnerId) {
    			libItemReqsSharingRules.add(new Library_Item_Request__Share(AccessLevel = shareAccessLevel, ParentId = req.Id, UserOrGroupId = req.Owner_2__c ));
    		}
    		if(req.Owner_3__c != null && req.Owner_3__c != req.OwnerId) {
    			libItemReqsSharingRules.add(new Library_Item_Request__Share(AccessLevel = shareAccessLevel, ParentId = req.Id, UserOrGroupId = req.Owner_3__c ));
    		}
    		if(req.Owner_4__c != null && req.Owner_4__c != req.OwnerId) {
    			libItemReqsSharingRules.add(new Library_Item_Request__Share(AccessLevel = shareAccessLevel, ParentId = req.Id, UserOrGroupId = req.Owner_4__c ));
    		}
    	}
    	if(!libItemReqsSharingRules.isEmpty()) {
            insert libItemReqsSharingRules;
        }    		
    }
    
    //////////////////
    // ACG
    //////////////////
    public static void calculatePortalContentSharingRules(List<Portal_Content__c> settingsList, Set<Id> subComponentIds) {
        SharingManagementUtil.createSharingRulesForPortalContentAndComponents(settingsList, false);
        
        List<Portal_Content__c> portalContentList = [SELECT Id, Content_Category__c, Distribution_Level__c, Distribution_Target__c, Video_Selected__c, HTML_Selected__c 
                                                        FROM Portal_Content__c 
                                                        WHERE Video_Selected__c IN: subComponentIds OR HTML_Selected__c IN: subComponentIds];
        
        System.debug('@@@' + portalContentList);
        if(portalContentList != null && !portalContentList.isEmpty()) {
            SharingManagementUtil.createSharingRulesForPortalContentAndComponents(portalContentList, true);
        }
    }    
    
    public static void createSharingRulesForPortalContentAndComponents(List<Portal_Content__c> settingsList, boolean componentsOnly) {
        List<String> regionPublicGroupNames = new List<String>();
        List<String> regionBlogPublicGroupNames = new List<String>();
        List<Portal_Content__Share> portalContentSharingRules = new List<Portal_Content__Share>();
        
        List<Id> groupIds = new List<Id>();
        
        for(Portal_Content__c setting : settingsList) {
            if(setting.Content_Category__c != null && setting.Content_Category__c != '') {
                if(setting.Distribution_Target__c != null && setting.Distribution_Target__c != '') {
                	//Non Blog
                    regionPublicGroupNames.add(Label.ACGPublicGroupPrefix + setting.Content_Category__c + '-' + setting.Distribution_Target__c + Label.ACGContentAdminPublicGroupSuffix);
                } else {
                	//Blog
                	regionBlogPublicGroupNames.add(Label.ACGPublicGroupPrefix + setting.Content_Category__c + Label.ACGContentAdminPublicGroupSuffix);
                }
            }
        }        
        Map<String, Group> publicGroupNameToGroup = new Map<String, Group>();        
        for(Group g : [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Regular' AND (Name IN :regionPublicGroupNames OR Name IN :regionBlogPublicGroupNames)]) {
            publicGroupNameToGroup.put(g.Name, g);
            groupIds.add(g.Id);
        }        
        for(Portal_Content__c setting : settingsList) {
            if(setting.Content_Category__c != null && setting.Content_Category__c != '') {                
                //Create Rules for the Blog Group
                Group regionBlogGroup = publicGroupNameToGroup.get(Label.ACGPublicGroupPrefix + setting.Content_Category__c + Label.ACGContentAdminPublicGroupSuffix);                
                if(regionBlogGroup != null) {                    
                    if(!componentsOnly) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Id, UserOrGroupId = regionBlogGroup.Id ));
                    }
                    //Process the sub-components now
                    if(setting.HTML_Selected__c != null) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.HTML_Selected__c, UserOrGroupId = regionBlogGroup.Id ));
                    }
                    if(setting.Video_Selected__c != null) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Video_Selected__c, UserOrGroupId = regionBlogGroup.Id ));
                    }
                }                
                //Create Rules for the Non Blog Group
                if(setting.Distribution_Target__c != null && setting.Distribution_Target__c != '') {
                    Group regionGroup = publicGroupNameToGroup.get(Label.ACGPublicGroupPrefix + setting.Content_Category__c + '-' + setting.Distribution_Target__c + Label.ACGContentAdminPublicGroupSuffix);                    
                    if(regionGroup != null) {
                        if(!componentsOnly) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Id, UserOrGroupId = regionGroup.Id ));
                        }
                        //Process the sub-components now
                        if(setting.HTML_Selected__c != null) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.HTML_Selected__c, UserOrGroupId = regionGroup.Id ));
                        }
                        if(setting.Video_Selected__c != null) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Video_Selected__c, UserOrGroupId = regionGroup.Id ));
                        }
                    }
                }
            }
        }        
        if(!portalContentSharingRules.isEmpty()) {
            insert portalContentSharingRules;
        }
    }
    
    /*
    public static void calculatePortalContentSharingRules(List<Portal_Content__c> settingsList, Set<Id> subComponentIds) {
        SharingManagementUtil.createSharingRulesForPortalContentAndComponents(settingsList, false);
        
        List<Portal_Content__c> portalContentList = [SELECT Id, Sub_Category__c, BU__c, Video_Selected__c, HTML_Selected__c 
                                                        FROM Portal_Content__c 
                                                        WHERE Video_Selected__c IN: subComponentIds OR HTML_Selected__c IN: subComponentIds];
        
        System.debug('@@@' + portalContentList);
        if(portalContentList != null && !portalContentList.isEmpty()) {
            SharingManagementUtil.createSharingRulesForPortalContentAndComponents(portalContentList, true);
        }
    }
    
    public static void createSharingRulesForPortalContentAndComponents(List<Portal_Content__c> settingsList, boolean componentsOnly) {
        List<String> regionPublicGroupNames = new List<String>();
        List<String> regionDeptPublicGroupNames = new List<String>();
        List<Portal_Content__Share> portalContentSharingRules = new List<Portal_Content__Share>();
        
        List<Id> groupIds = new List<Id>();
        
        for(Portal_Content__c setting : settingsList) {
            if(setting.Sub_Category__c != null && setting.Sub_Category__c != '') {
                regionPublicGroupNames.add(Label.ACGPublicGroupPrefix + setting.Sub_Category__c + Label.ACGContentAdminPublicGroupSuffix);
                
                if(setting.BU__c != null && setting.BU__c != '') {
                    regionPublicGroupNames.add(Label.ACGPublicGroupPrefix + setting.Sub_Category__c + '-' + setting.BU__c + Label.ACGContentAdminPublicGroupSuffix);
                }
            }
        }
        
        Map<String, Group> publicGroupNameToGroup = new Map<String, Group>();
        
        for(Group g : [SELECT Id, Name, DeveloperName FROM Group WHERE Type='Regular' AND (Name IN :regionPublicGroupNames OR Name IN :regionDeptPublicGroupNames)]) {
            publicGroupNameToGroup.put(g.Name, g);
            groupIds.add(g.Id);
        }
        
        for(Portal_Content__c setting : settingsList) {
            if(setting.Sub_Category__c != null && setting.Sub_Category__c != '') {
                
                //Create Rules for the Region Group
                Group regionGroup = publicGroupNameToGroup.get(Label.ACGPublicGroupPrefix + setting.Sub_Category__c + Label.ACGContentAdminPublicGroupSuffix);
                
                if(regionGroup != null) {
                    
                    if(!componentsOnly) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Id, UserOrGroupId = regionGroup.Id ));
                    }
                    //Process the sub-components now
                    if(setting.HTML_Selected__c != null) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.HTML_Selected__c, UserOrGroupId = regionGroup.Id ));
                    }

                    if(setting.Video_Selected__c != null) {
                        portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Video_Selected__c, UserOrGroupId = regionGroup.Id ));
                    }
                }
                
                //Create Rules for the Region + Department Group
                if(setting.BU__c != null && setting.BU__c != '') {
                    Group regionDeptGroup = publicGroupNameToGroup.get(Label.ACGPublicGroupPrefix + setting.Sub_Category__c + '-' + setting.BU__c + Label.ACGContentAdminPublicGroupSuffix);
                    
                    if(regionDeptGroup != null) {
                        if(!componentsOnly) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Id, UserOrGroupId = regionDeptGroup.Id ));
                        }
                        //Process the sub-components now
                        if(setting.HTML_Selected__c != null) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.HTML_Selected__c, UserOrGroupId = regionDeptGroup.Id ));
                        }
                        if(setting.Video_Selected__c != null) {
                            portalContentSharingRules.add(new Portal_Content__Share(AccessLevel = 'Edit', ParentId = setting.Video_Selected__c, UserOrGroupId = regionDeptGroup.Id ));
                        }
                    }
                }
            }
        }
        
        if(!portalContentSharingRules.isEmpty()) {
            insert portalContentSharingRules;
        }
    }
    */
}