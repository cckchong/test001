/*****************************************************
Controller for Chatter Component
1. Get the name of the Chatter Group
2. Check if the user is a manager of the group

******************************************************/
public without sharing class ChatterController {
    
    public Id chatterID {get; set;}
    
    public Id recordID { get; set; }    
    
    public String chatterGroupName { get{
    	
    	String result='';
    	List<CollaborationGroup> listGroups = [SELECT Name, Id FROM CollaborationGroup WHERE Id =: chatterID limit 1];
    	if(listGroups.size()>0) {
    		result = listGroups.get(0).Name.replace('_', ' ');
    	}
    	return result;
    
    } set; }
    
    public Boolean bCanPost { get {
    	List<CollaborationGroupMember> listMembers = 
    		[
    			SELECT c.Id, c.CollaborationRole, c.CollaborationGroupId 
    			FROM CollaborationGroupMember c
				WHERE c.CollaborationGroupId = :chatterID
				AND c.MemberId =:UserInfo.getUserId()
				AND c.CollaborationRole ='Admin' 
			]; //Admin - Indicates that a user is a group manager. 
		return listMembers.size()>0 || !chatterGroupName.contains(Label.ACGChatterGroupPrefix);	
    } set; }
										
}