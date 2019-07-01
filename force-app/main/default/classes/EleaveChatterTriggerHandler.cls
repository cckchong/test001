/**
 * @description Used inside the FeedItem trigger to prevent users from deleting their CC posts
 */
public class EleaveChatterTriggerHandler {

    public static void preventUserFromModifyingLeavePost(List<FeedItem> posts) {
        if(Trigger.isUpdate || Trigger.isDelete) {
            for(FeedItem f : posts) {
                Id theParent = f.ParentId;
                if(theParent != null) {
                    boolean isLeaveRequest = (Leave_Request__c.getSObjectType() == theParent.getSobjectType());
                    if(f.CreatedById == UserInfo.getUserId() && f.Body.contains(Label.ELeave_Chatter_CC_Message) && isLeaveRequest) {
                        f.AddError(Label.ELeave_Cannot_Delete_CC_Message);
                    }
                }
            }
        }
    }
}