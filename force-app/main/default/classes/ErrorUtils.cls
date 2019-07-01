/**
 * Helpers for error handling
 * @author Andrew Ng
 * @date 05/11/2014
 */
public class ErrorUtils {
	
    /**
     * Output a Visualforce
     */ 
    public static void outputInfoMessage(String s) {
        ApexPages.Message msNoItemsFound = new ApexPages.Message(ApexPages.Severity.INFO, s);
        ApexPages.addMessage(msNoItemsFound);
    }
    
    public static boolean isEmpty(List<SObject> sobjectList) {
        boolean result = false;
        
        if(sobjectList == null || sobjectList.isEmpty()) {
            result = true;
        }
        
        return result;
    }
    
    public static boolean isValidDecimal(String dec) {
        boolean result = true;
        
        try {
        
            Decimal theDecimal = Decimal.valueOf(dec);
            
        } catch (Exception e) {
            result = false;
        }
        
        return result;
    }
}