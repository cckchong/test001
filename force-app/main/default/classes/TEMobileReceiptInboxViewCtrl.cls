/**
 * TETravelRequestSendController 
 * @description To create and get mobile receipt inbox
 */
public without sharing class TEMobileReceiptInboxViewCtrl 
{
    
    /**
     * @description constructor with StandardController
     */
    public TEMobileReceiptInboxViewCtrl ( ApexPages.StandardController controller) {
    }
    
    /**
     * @description send action in Travel Request
     */
    public PageReference SendAction(){
        PageReference pageref = null;
        Mobile_Receipt_Inbox__c mobInbox = null;
        Id userId = UserInfo.getUserId();
        for( Mobile_Receipt_Inbox__c reader : [ Select id, OwnerId from Mobile_Receipt_Inbox__c where OwnerId = :userId]){
            mobInbox = reader;
        }
        if (mobInbox == null) {
            // If there is no mobile receipt inbox, create one for myself
            mobInbox = new Mobile_Receipt_Inbox__c (
            OwnerId = UserInfo.getUserId()
            );
            insert mobInbox;
            for( Mobile_Receipt_Inbox__c reader : [ Select id, OwnerId from Mobile_Receipt_Inbox__c where OwnerId = :userId]){
                mobInbox = reader;
            }
        }
        pageref = new PageReference('/' + mobInbox.id );
        // pageref = new PageReference('javascript: alert(\''+ 'Please check your email.' +'\');window.history.back();');
        pageref.setRedirect(true);
        return pageref;  
    }

    
}