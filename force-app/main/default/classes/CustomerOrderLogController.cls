public with sharing class CustomerOrderLogController {

    private List<Customer_Order_Log__c> allLogs;
    private List<Customer_Order_Log_History__c> histories;
    
    public CustomerOrderLogController() {

    }
    
    public PageReference redirectToGlobalForTGA(){
        String prefix = '';
        String listViewId = '';
    
        // get prefix
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(String sObj : gd.keySet()){
            Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
            if (r.getName() == 'Customer_Order_Log__c') {
                prefix = r.getKeyPrefix();
            }
            
        }
    
        // get list view Id
        String q = 'SELECT Id FROM Customer_Order_Log__c LIMIT 1';
        ApexPages.StandardSetController ACC = new ApexPages.StandardSetController(Database.getQueryLocator(q));
        
        List<SelectOption> ListViews = ACC.getListViewOptions();
        for(SelectOption w : ListViews ){
            if(w.getLabel() == Label.GlobalForTGAViewName){
                listViewId = w.getValue().left(15);
                
            }
        }
        
        return new PageReference('/' + prefix + '?fcf=' + listViewId);
        
    }
    
    // this method is called by Customer_Order_Logs_Export_to_Excel
    public List<ReportLog> getLogs() {
        List<ReportLog> combinedLog = new List<ReportLog>();
        
        for (Customer_Order_Log__c l: this.getAllLogs()) {
            // put latest version to list first (e.g. ver4)
            ReportLog newLog = new ReportLog();
            newLog.Status = l.Status__c;
            newLog.Name = l.Name;
            newLog.Owner_Name = l.Owner.Name;
            newLog.CreatedDate = String.valueOf(l.CreatedDate);
            newLog.Version = l.Version__c;
            newLog.Customer = l.Customer__c;
            newLog.Brand = l.Brand__c;
            newLog.Product = l.Product__c;
            newLog.Dipping_Flag = l.Dipping_Flag__c;
            newLog.Plant = l.Plant__c;
            newLog.Requested_Qty = l.Requested_Qty__c;
            newLog.Requested_Delivery = String.valueOf(l.Requested_Delivery__c);
            newLog.Reserved_Qty = l.Reserved_Qty__c;
            newLog.From_Customer_to_TGA = String.valueOf(l.From_Customer_to_TGA__c);
            newLog.Meet_Customer_Requirement = l.Meet_Customer_Requirement__c;
            newLog.Confirmed_Delivery = String.valueOf(l.Confirmed_Delivery__c);
            newLog.Impacted_Customer = l.Impacted_Customer__c;
            newLog.Impacted_Volume = l.Impacted_Volume__c;
            newLog.Factory_transfer_if_any = l.Factory_transfer_if_any__c;
            newLog.Gap_Confirmed_vs_Expected_dely = l.Gap_Confirmed_vs_Expected_dely__c;
            newLog.Customer_Confirmation = l.Customer_Confirmation__c;
            newLog.KPI_3_days = l.KPI_3_days__c;
            combinedLog.add(newLog);
            
            for (Customer_Order_Log_History__c h: this.getHistories()) {
                if (l.Id == h.MasterLog__c) {
                    // put version histories at bottom
                    // they should be in desc order (e.g. ver3 -> ver2 -> ver1) (due to ORDER BY CreatedDate Desc in query)
                    ReportLog newHistory = new ReportLog();
                    newHistory.Status = 'Confirmed';
                    newHistory.Name = l.Name;
                    newHistory.Owner_Name = l.Owner.Name;
                    newHistory.CreatedDate = String.valueOf(h.CreatedDate);
                    newHistory.Version = h.Version__c;
                    newHistory.Customer = h.Customer__c;
                    newHistory.Brand = h.Brand__c;
                    newHistory.Product = h.Product__c;
                    newHistory.Dipping_Flag = h.Dipping_Flag__c;
                    newHistory.Plant = h.Plant__c;
                    newHistory.Requested_Qty = h.Requested_Qty__c;
                    newHistory.Requested_Delivery = String.valueOf(h.Requested_Delivery__c);
                    newHistory.Reserved_Qty = h.Reserved_Qty__c;
                    newHistory.From_Customer_to_TGA = String.valueOf(h.From_Customer_to_TGA__c);
                    newHistory.Meet_Customer_Requirement = h.Meet_Customer_Requirement__c;
                    newHistory.Confirmed_Delivery = String.valueOf(h.Confirmed_Delivery__c);
                    newHistory.Impacted_Customer = h.Impacted_Customer__c;
                    newHistory.Impacted_Volume = h.Impacted_Volume__c;
                    newHistory.Factory_transfer_if_any = h.Factory_transfer_if_any__c;
                    newHistory.Gap_Confirmed_vs_Expected_dely = h.Gap_Confirmed_vs_Expected_dely__c;
                    newHistory.Customer_Confirmation = h.Customer_Confirmation__c;
                    newHistory.KPI_3_days = h.KPI_3_days_text__c;
                    
                    combinedLog.add(newHistory);
                }
            }
        }
        
        return combinedLog;
        
    }
    
    private List<Customer_Order_Log__c> getAllLogs() {
        if (this.allLogs == null) {
            List<Customer_Order_Log__c> returnList = new List<Customer_Order_Log__c>();
            
            for (Customer_Order_Log__c l: [SELECT Status__c,
                                            Owner.Name,
                                            Name,
                                            CreatedDate,
                                            Version__c,
                                            Customer__c,
                                            Brand__c,
                                            Product__c,
                                            Dipping_Flag__c,
                                            Plant__c,
                                            Requested_Qty__c,
                                            Requested_Delivery__c,
                                            Reserved_Qty__c,
                                            From_Customer_to_TGA__c,
                                            Meet_Customer_Requirement__c,
                                            Confirmed_Delivery__c,
                                            Impacted_Customer__c,
                                            Impacted_Volume__c,
                                            Factory_transfer_if_any__c,
                                            Gap_Confirmed_vs_Expected_dely__c,
                                            Customer_Confirmation__c,
                                            KPI_3_days__c
                                            FROM Customer_Order_Log__c
                                            ORDER BY Name Desc]) {
                returnList.add(l);
            }
            
            this.allLogs = returnList;
            
        }
        
        return this.allLogs;

    }
    
    private List<Customer_Order_Log_History__c> getHistories() {
        if (this.histories == null) {
            List<Customer_Order_Log_History__c> returnList = new List<Customer_Order_Log_History__c>();
            
            for (Customer_Order_Log_History__c h: [SELECT MasterLog__c,
                                            CreatedDate,
                                            Version__c,
                                            Customer__c,
                                            Brand__c,
                                            Product__c,
                                            Dipping_Flag__c,
                                            Plant__c,
                                            Requested_Qty__c,
                                            Requested_Delivery__c,
                                            Reserved_Qty__c,
                                            From_Customer_to_TGA__c,
                                            Meet_Customer_Requirement__c,
                                            Confirmed_Delivery__c,
                                            Impacted_Customer__c,
                                            Impacted_Volume__c,
                                            Factory_transfer_if_any__c,
                                            Gap_Confirmed_vs_Expected_dely__c,
                                            Customer_Confirmation__c,
                                            KPI_3_days_text__c
                                            FROM Customer_Order_Log_History__c
                                            ORDER BY CreatedDate Desc]) {
                returnList.add(h);
            }
            
            this.histories = returnList;
        }
        
        return this.histories;
    }
    
    // createdDate is not writable, I have to write my own report log class...
    public Class ReportLog {
        public String Status {get; set;}
        public String Name {get; set;}
        public String Owner_Name {get; set;}
        public String CreatedDate {get; set;}
        public Decimal Version {get; set;}
        public String Customer {get; set;}
        public String Brand {get; set;}
        public String Product {get; set;}
        public String Dipping_Flag {get; set;}
        public String Plant {get; set;}
        public Decimal Requested_Qty {get; set;}
        public String Requested_Delivery {get; set;}
        public Decimal Reserved_Qty {get; set;}
        public String From_Customer_to_TGA{get; set;}
        public String Meet_Customer_Requirement {get; set;}
        public String Confirmed_Delivery {get; set;}
        public String Impacted_Customer {get; set;}
        public Decimal Impacted_Volume {get; set;}
        public String Factory_transfer_if_any {get; set;}
        public String Gap_Confirmed_vs_Expected_dely {get; set;}
        public String Customer_Confirmation {get; set;}
        public String KPI_3_days {get; set;}
        
        public ReportLog() {
            
        }
    }
}