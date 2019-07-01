/**
 * TETravelPrice
 * @description Travel Price
 */
public without sharing class TETravelPriceCtrl{

    Public TETravelApplicationCtrl travelApplicationCtrl{get;set;}
    Public Travel_Price__c travelPrice{get;set;}
    Public String id{get;set;}
    Public String invoiceDate{get;set;}
    Public Boolean checkInvoiceNo{get;set;}
    Public Boolean checkBookingDate{get;set;}
    Public Boolean checkType{get;set;}
    Public Boolean checkCurrency{get;set;}
    Public Boolean checkAmount{get;set;}
    Public Boolean checkreq {get;set;}
    Public Static String ROW_ACTION_REMOVE = 'R';
    Public Static String ROW_ACTION_ADD = 'A';
    Public Static String ROW_ACTION_DUPLICATE = 'D';
    
    Public TETravelPriceCtrl(String Id, TETravelApplicationCtrl travelApplicationCtrl){
        this.id = id;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.travelPrice = new Travel_Price__c (amount__c = 0);
        this.checkInvoiceNo = true;
        this.checkBookingDate = true;
        this.checkType = true;
        this.checkCurrency = true;
        this.checkAmount = true;
        this.checkreq = false;
    }
    
    public TETravelPriceCtrl(TETravelApplicationCtrl travelApplicationCtrl, Travel_Price__c travelPrice){
        DateTime dt = null;
        this.id = travelPrice.id;
        this.travelApplicationCtrl = travelApplicationCtrl;
        this.travelPrice = travelPrice;
        dt = this.travelPrice.invoice_date__c;
        if (dt != null){
            this.invoiceDate = dt.format(TETravelApplicationCtrl.DATE_FORMAT);
        }
        this.checkInvoiceNo = true;
        this.checkBookingDate = true;
        this.checkType = true;
        this.checkCurrency = true;
        this.checkAmount = true;
        this.checkreq = false;
    }
    
    public void addRow(){
        this.travelApplicationCtrl.airfareRows(this.id, ROW_ACTION_ADD);
    }
    
    public void removeRow(){
        if (this.travelPrice.id != null){
            delete this.travelPrice;
        }
        this.travelApplicationCtrl.airfareRows(this.id, ROW_ACTION_REMOVE);
    }
    
    public void duplicateRow(){
        this.travelApplicationCtrl.airfareRows(this.id, ROW_ACTION_DUPLICATE);
    }
    
    public Boolean getisEdit(){
        return (travelApplicationCtrl.istravelagent && String.isBlank(this.travelPrice.id) );
        
    }
}