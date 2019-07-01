public without sharing class IDPPurchaseRequestProgressBarCtrl {

    public static Purchase_Request__c pr {get;}
    public static Map<String, Integer> statusStepMap;
    public static String stepLabel {set;}
    public static String isStepActive {set;}
    public static String stepLabel1 { get{ return getStepLabel(1); } }
    public static String stepLabel2 { get{ return getStepLabel(2); } }
    public static String stepLabel3 { get{ return getStepLabel(3); } }
    public static String stepLabel4 { get{ return getStepLabel(4); } }
    public static String stepLabel5 { get{ return getStepLabel(5); } }
    public static String stepLabel6 { get{ return getStepLabel(6); } }
    public static String stepLabel7 { get{ return getStepLabel(7); } }
    public static String stepLabel8 { get{ return getStepLabel(8); } }
    public static String stepLabel9 { get{ return getStepLabel(9); } }
    public static String isStepActive1 { get{ return getIsStepActive(1); } }
    public static String isStepActive2 { get{ return getIsStepActive(2); } }
    public static String isStepActive3 { get{ return getIsStepActive(3); } }
    public static String isStepActive4 { get{ return getIsStepActive(4); } }
    public static String isStepActive5 { get{ return getIsStepActive(5); } }
    public static String isStepActive6 { get{ return getIsStepActive(6); } }
    public static String isStepActive7 { get{ return getIsStepActive(7); } }
    public static String isStepActive8 { get{ return getIsStepActive(8); } }
    public static String isStepActive9 { get{ return getIsStepActive(9); } }


    public IDPPurchaseRequestProgressBarCtrl() {
        pr = [SELECT id, status__c FROM Purchase_Request__c WHERE ID = :ApexPages.currentPage().getParameters().get('prId') LIMIT 1];
        statusStepMap = new Map<String, Integer>();
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_DRAFT, 1);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED, 1);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_PURCHASE_CONFIRMATION, 2);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_PENDING_APPROVAL, 3);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_APPROVED, 4);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED, 4);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_ORDERED, 5);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_CANCELLED, 5);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_ORDERED, 6);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_PARTIAL_DELIVERED, 7);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_DELIVERED, 8);
        statusStepMap.put(IDPConstant.PURCHASE_REQUEST_STATUS_CLOSED, 9);
    }

    public static String getStepLabel(Integer stepNo) {
        String status = pr.Status__c;
        String label = '';

        if (stepNo == 1)
            label = status == IDPConstant.PURCHASE_REQUEST_STATUS_NOT_SUBMITTED ? 'Not Submitted' : 'Draft';    
        else if (stepNo == 2)
            label = 'Pending Purchase Confirmation';
        else if (stepNo == 3)
            label = 'Pending Approval';
        else if (stepNo == 4)
            label = status == IDPConstant.PURCHASE_REQUEST_STATUS_REJECTED ? 'Rejected' : 'Approved';   
        else if (stepNo == 5)
            label = status == IDPConstant.PURCHASE_REQUEST_STATUS_CANCELLED ? 'Cancelled' : 'Partial Ordered';
        else if (stepNo == 6)
            label = 'Ordered';
        else if (stepNo == 7)
            label = 'Partial Delivered';
        else if (stepNo == 8)
            label = 'Delivered';
        else if (stepNo == 9)
            label = 'Invoiced';
        else
            label = 'Unknown';

        return label;
    }

    public static String getIsStepActive(Integer stepNo) {
        return stepNo <= statusStepMap.get(pr.Status__c) ? 'active' : '';
    }

}