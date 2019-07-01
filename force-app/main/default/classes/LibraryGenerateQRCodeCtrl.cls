/*
	LibraryGenerateQRCodeCtrl Class
	Used in Force.com site, and make it public
*/
public without sharing class LibraryGenerateQRCodeCtrl{

    
    public Library_Inventory__c inv {get;set;}
    
    public Boolean bPrintableView {get;set;} { bPrintableView = false; }
    
    public LibraryGenerateQRCodeCtrl(ApexPages.StandardController controller) {
        
    }
    
    //generate QR code
    public void genQrCode() {
    	String gogogo = ApexPages.currentPage().getParameters().get(Label.Library_generate);
        
        if(gogogo == Label.library_True) {
        	List<Library_Inventory__c> invlist = [Select Id, Name, Temp_QR_Code_Number__c, Temp_QR_Code__c From Library_Inventory__c Where Id =:Label.Library_linv00000721 limit 1];
        	if(invlist!=null && !invlist.isEmpty()){
        		inv = invlist[0];
        		inv.Temp_QR_Code_Number__c = autoNumber(inv.Temp_QR_Code_Number__c, 'INV');
        		SystemUtil.SafeUpdate(inv);
        	}
        	
        	bPrintableView = true;
        	
        	invlist =  [Select Id, Name, Temp_QR_Code_Number__c, Temp_QR_Code__c From Library_Inventory__c Where Id =:Label.Library_linv00000721 limit 1];
        	if(invlist!=null && !invlist.isEmpty()){
        		inv = invlist[0];
        	}
        }
    }
    
    //do nothing
    public PageReference doNothing() {
    	return null;
    }
    
    //generate autoNumber
    public static String autoNumber(String oldValue, String prefix) {
		String result = prefix;
		integer num = Integer.valueof(oldValue.substring(prefix.length(), oldValue.length()))+1;
		for(Integer i = 0; i < 10 - String.valueOf(num).length(); i++) {
			result += '0';
		}
		result += String.valueOf(num) ;
    	return result;
    }
}