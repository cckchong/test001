public with sharing class IDPPurchaseOrderProgressBarCtrl {

    public static Purchase_Order__c po {get;}
    public static List<Purchase_Order_Item__c> poiList {get;}
    public static Map<String, Integer> statusStepMap;
    public static String stepLabel {set;}
    public static String isStepActive {set;}
    public static String stepLabel1 { get{ return getStepLabel(1); } }
    public static String stepLabel2 { get{ return getStepLabel(2); } }
    public static String stepLabel3 { get{ return getStepLabel(3); } }
    public static String stepLabel4 { get{ return getStepLabel(4); } }
    public static String stepLabel5 { get{ return getStepLabel(5); } }
    public static String stepLabel6 { get{ return getStepLabel(6); } }
    public static String isStepActive1 { get{ return getIsStepActive(1); } }
    public static String isStepActive2 { get{ return getIsStepActive(2); } }
    public static String isStepActive3 { get{ return getIsStepActive(3); } }
    public static String isStepActive4 { get{ return getIsStepActive(4); } }
    public static String isStepActive5 { get{ return getIsStepActive(5); } }
    public static String isStepActive6 { get{ return getIsStepActive(6); } }
    public static Boolean isPartialDelivered;
    public static Boolean isDelivered;

    public static final String PURCHASE_ORDER_STATUS_DRAFT = 'DF';
    public static final String PURCHASE_ORDER_STATUS_ORDERED = 'ORD';
    public static final String PURCHASE_ORDER_STATUS_DELIVERED = 'DEL';
    public static final String PURCHASE_ORDER_STATUS_PARTIAL_ORDERED = 'PO';
    public static final String PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED = 'PD';
    public static final String PURCHASE_ORDER_STATUS_CLOSED = 'CL';
    public static final String PURCHASE_ORDER_STATUS_CANCELLED = 'CN';
    public static final String PURCHASE_ORDER_STATUS_INVOICED = 'INV';

    public IDPPurchaseOrderProgressBarCtrl() {
        po = [SELECT id, status__c FROM Purchase_Order__c WHERE ID = :ApexPages.currentPage().getParameters().get('poId') LIMIT 1];
        poiList = [SELECT id, Quantity__c, Received_Quantity__c, Status__c FROM Purchase_Order_Item__c WHERE Purchase_Order__c = :po.Id];
        statusStepMap = new Map<String, Integer>();
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_DRAFT, 1);
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_ORDERED, 2);
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_PARTIAL_DELIVERED, 3);
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_DELIVERED, 4);
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_CLOSED, 5);
        statusStepMap.put(IDPConstant.PURCHASE_ORDER_STATUS_CANCELLED, 6);
    }

    public static String getStepLabel(Integer stepNo) {
        String status = po.Status__c;
        String label = '';

        if (stepNo == 1)
            label = 'Draft';    
        else if (stepNo == 2)
            label = 'Ordered';
        else if (stepNo == 3) {
            label = ((status == IDPConstant.PURCHASE_ORDER_STATUS_CLOSED && !getIsPartialDelivered() && !getIsDelivered()) ? 'Invoiced' : 'Partial Delivered');
        }
        else if (stepNo == 4) {
            label = ((status == IDPConstant.PURCHASE_ORDER_STATUS_CLOSED && !getIsDelivered()) ? 'Invoiced' : 'Delivered');
        }
        else if (stepNo == 5) 
            label = 'Invoiced';
            //label = ((status == IDPConstant.PURCHASE_ORDER_STATUS_CANCELLED ) ? 'Canceled' :  'Invoiced');
        else if (stepNo == 6) 
            label = 'Canceled';
        else
            label = 'Unknown';

        return label;
    }

    public static String getIsStepActive(Integer stepNo) {
        return stepNo <= statusStepMap.get(po.Status__c) ? 'active' : '';
    }

    public static boolean getIsPartialDelivered() {
        for (Purchase_Order_Item__c poi : poiList) {
            if (poi.Received_Quantity__c > 0)
                return true;
        }

        return false;
    }

    public static boolean getIsDelivered() {
        if (poiList.size() == 0)
            return false;

        for (Purchase_Order_Item__c poi : poiList) {
            if (poi.Received_Quantity__c < poi.Quantity__c)
                return false;
        }

        return true;
    }

}