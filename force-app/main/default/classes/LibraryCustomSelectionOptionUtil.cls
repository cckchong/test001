/*
	LibraryCustomSelectionOptionUtil Class
	
	@Autor: AN, WG
	@Custom Setting: Fls_Search_Params__c
	@Desciprtion: It is a utility class for retrieving the values from custom setting 'Fls_Search_Params'.
				  Assign the values to selection options
	
*/
public class LibraryCustomSelectionOptionUtil {

 	//private final String FABRIC_PARAM_CS = 'Fls_Search_Params';   
    //get all records from Fls_Search_Params__c to a selectOption map
    public static Map<String, List<SelectOption>> getFabricSelectionOptionMap() {
        Map<String, List<SelectOption>> resultMap = new Map<String, List<SelectOption>>();
        
        Map<String, Fls_Search_Params__c> selectionOptions = Fls_Search_Params__c.getAll();
        
        for(String key : selectionOptions.keySet()) {
            Fls_Search_Params__c fsp = selectionOptions.get(key);
            
            String fName = Label.FLS_prefix + fsp.Field_Name__c.toLowerCase() + Label.FLS_end;
            if(resultMap.get(fName) == null) {
                List<SelectOption> soList = new List<SelectOption>();
                soList.add(new SelectOption(fsp.Key__c, fsp.Value__c));

                resultMap.put(fName, soList);
            } else {
                List<SelectOption> soList = resultMap.get(fName);
                soList.add(new SelectOption(fsp.Key__c, fsp.Value__c));
                soList.sort();
                resultMap.put(fName, soList);
            }
        }
        return resultMap;
    }
    
    //get all records from Fls_Search_Params__c to a selectOption map
    public static Map<String, List<SelectOption>> getFabricSelectionOptionMapByValues() {
        Map<String, List<SelectOption>> resultMap = new Map<String, List<SelectOption>>();
        
        Map<String, Fls_Search_Params__c> selectionOptions = Fls_Search_Params__c.getAll();
        
        for(String key : selectionOptions.keySet()) {
            Fls_Search_Params__c fsp = selectionOptions.get(key);
            
            String fName = Label.FLS_prefix + fsp.Field_Name__c.toLowerCase() + Label.FLS_end;
            if(resultMap.get(fName) == null) {
                List<SelectOption> soList = new List<SelectOption>();
                soList.add(new SelectOption(fsp.Value__c, fsp.Value__c));

                resultMap.put(fName, soList);
            } else {
                List<SelectOption> soList = resultMap.get(fName);
                soList.add(new SelectOption(fsp.Value__c, fsp.Value__c));
                soList.sort();
                resultMap.put(fName, soList);
            }
        }
        return resultMap;
    }
    
}