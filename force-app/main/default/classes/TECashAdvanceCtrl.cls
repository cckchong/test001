/**
 * TECashAdvanceCtrl
 * @description Cash Advance list
 */
public without sharing class TECashAdvanceCtrl{
    Public String Id{get;set;}
    Public Cash_Advance__c cashAdvance{get;set;}
    Public TETravelApplicationCtrl travelApplicationCtrl{get;set;}
    Public String collectionDate{get;set;}
    Public Boolean checkCurrency{get;set;}
    Public Boolean checkAmount{get;set;}
    Public Boolean checkCollectionDate{get;set;}
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
 
    Public TECashAdvanceCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl){
        Schema.DescribeFieldResult defStatus;
        List <Schema.PicklistEntry> pickVals;
        this.checkCurrency = true;
        this.checkAmount = true;
        this.checkCollectionDate = true;
        this.cashAdvance = new cash_advance__c(amount__c = 0);
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.Id = Id;        
        defStatus = Cash_Advance__c.status__c.getDescribe();
        pickVals = defStatus.getPicklistValues();        
        for (Schema.PicklistEntry pv: pickVals){
            if (pv.isDefaultValue()){
                this.cashAdvance.status__c = pv.getValue();
            }
        }
    }
    
    Public TECashAdvanceCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl, Cash_Advance__c cashAdvance){
        DateTime tmpcollectionDate = null;
        this.checkCurrency = true;
        this.checkAmount = true;
        this.checkCollectionDate = true;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.Id = cashAdvance.Id;
        this.cashAdvance = cashAdvance;
        tmpcollectionDate = this.cashAdvance.Expected_Collection_Date__c;
        if (tmpcollectionDate != null){
            this.collectionDate = tmpcollectionDate.format(TETravelApplicationCtrl.Date_FORMAT, travelApplicationCtrl.travelApplication.On_Behalf_of__r.Employee_Administrator__r.user__r.TimeZoneSidKey);
        }
    }
    
    Public Void addRow(){
        this.travelApplicationCtrl.cashAdvanceRow(this.id, ROW_ACTION_ADD);
    }
    
    Public Void RemoveRow(){
        if(this.cashAdvance.status__c == TEConstant.STATUS_DRAFT ){
            if (this.cashAdvance.id != null){
                delete this.cashAdvance;
            }
            this.travelApplicationCtrl.cashAdvanceRow(this.id, ROW_ACTION_REMOVE);
        }
        
    }
    
    Public Boolean getisNewCashAdvance(){
        return 
        (
            this.travelApplicationCtrl.isMySelf &&
            (
                this.travelApplicationCtrl.travelApplication.status__c == TEConstant.STATUS_DRAFT || 
                this.travelApplicationCtrl.travelApplication.status__c == TEConstant.STATUS_NOT_SUBMITTED  ||
                this.travelApplicationCtrl.travelApplication.status__c == TEConstant.STATUS_PENDING  || 
                this.travelApplicationCtrl.travelApplication.status__c == TEConstant.STATUS_CANCELLED  ||
                (
                    this.travelApplicationCtrl.travelApplication.status__c == TEConstant.STATUS_CONFIRMED 
                    && this.travelApplicationCtrl.travelApplication.Tech_Earliest_Departure_Date__c > system.today()
                )
            )
        );
    }
    
    Public Boolean getisDelete(){
        return this.travelApplicationCtrl.isMySelf && 
        (this.cashAdvance.id == null || this.cashAdvance.Status__c == TEConstant.STATUS_DRAFT);
    }
    
    Public Boolean getisEdit(){
        return 
        (
            
            this.travelApplicationCtrl.isMySelf &&
            (this.cashAdvance.Status__c == TEConstant.STATUS_DRAFT || 
             this.cashAdvance.Status__c == TEConstant.STATUS_NOT_SUBMITTED  || 
             this.cashAdvance.Status__c == TEConstant.STATUS_PENDING  || 
             this.cashAdvance.Status__c == TEConstant.STATUS_REJECT ||
             this.cashAdvance.Status__c == TEConstant.STATUS_CANCELLED 
            )
        );
    }
}