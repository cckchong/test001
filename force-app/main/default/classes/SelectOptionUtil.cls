/*
    SelectOptionUtil Class
    Used for sorting all selectOption values or labels
*/
global class SelectOptionUtil {
    
    /**
      Sort field to use in SelectOption i.e. Label or Value
    */
    global enum FieldToSort {
        Label, Value
    }
    
    //Sorting for the list of select option
    global static void doSort(List<Selectoption> opts, FieldToSort sortField) {
        
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (Selectoption opt : opts) {
            if (sortField == FieldToSort.Label) {
                
                //Done this cryptic to save scriptlines, if this loop executes 10000 times
                //it would every script statement would add 1, so 3 would lead to 30000.
                //Key using Label + Suffix Counter 
                
                    mapping.put((opt.getLabel() + suffix++), opt);   
            } else {
                // Key using Label + Suffix Counter               
                    mapping.put((opt.getValue() + suffix++),opt);
            }
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
       
        sortKeys.sort();
         
        // clear the original collection to rebuilt it
        opts.clear();
        
        for (String key : sortKeys) {
            
            opts.add(mapping.get(key));
        } 
    }
    
    /*
        Added by nickwu
        Sorting with fieldPath for list of selectoptions
    */
    global static void doSortByFieldPath(List<Selectoption> opts, FieldToSort sortField, String fieldPath) {
        
        Map<String, Selectoption> mapping = new Map<String, Selectoption>();
        // Suffix to avoid duplicate values like same labels or values are in inbound list 
        Integer suffix = 1;
        for (Selectoption opt : opts) {
            if (sortField == FieldToSort.Label) {
                if(!mapping.containsKey(opt.getLabel()+ ';;'+fieldPath))
                    mapping.put((opt.getLabel() + ';;'+fieldPath), opt);   
            } else {
                // Key using Label + Suffix Counter 
                if(!mapping.containsKey(opt.getValue()+ ';;'+fieldPath))              
                    mapping.put((opt.getValue() + ';;'+fieldPath),opt);
            }
        }
        
        List<String> sortKeys = new List<String>();
        sortKeys.addAll(mapping.keySet());
       
        sortKeys.sort();
         
        // clear the original collection to rebuilt it
        opts.clear();
        
        for (String key : sortKeys) {
            
            opts.add(mapping.get(key));
        }
    }
    
    
    /////
    // ZONE of Test Cases //
    /////
    static testMethod void testdoSortByValue() {
        Selectoption[] opts = new Selectoption[] {
                                   new Selectoption('v1', 'l1'),
                                   new Selectoption('v5', 'l1'),
                                   new Selectoption('v2', 'l1'),
                                   new Selectoption('v6', 'l1'),
                                   new Selectoption('v8', 'l1')
                               };
       
       doSort(opts, FieldToSort.Value);
       
       System.assertEquals(opts.size(), 5);
       System.assertEquals('v1', opts[0].getValue());
       System.assertEquals('v2', opts[1].getValue());
       System.assertEquals('v5', opts[2].getValue());
       System.assertEquals('v6', opts[3].getValue());
       System.assertEquals('v8', opts[4].getValue());
    }
    
    static testMethod void testdoSortByLabel() {
        Selectoption[] opts = new Selectoption[] {
                                   new Selectoption('v1', 'l1'),
                                   new Selectoption('v5', 'l5'),
                                   new Selectoption('v2', 'l2'),
                                   new Selectoption('v2.2', 'l2'), // Same label case
                                   new Selectoption('v6', 'l6'),
                                   new Selectoption('v8', 'l8')
                               };
       
       doSort(opts, FieldToSort.Label);
       
       System.assertEquals(opts.size(), 6);
       System.assertEquals('l1', opts[0].getLabel());
       System.assertEquals('l2', opts[1].getLabel());
       System.assertEquals('l2', opts[2].getLabel());
       System.assertEquals('l5', opts[3].getLabel());
       System.assertEquals('l6', opts[4].getLabel());
       System.assertEquals('l8', opts[5].getLabel());
    }

    static testMethod void testDoSortByFieldPath(){
 
        
        Selectoption[] opts = new Selectoption[] {
                                   new Selectoption('v1', 'l1'),
                                   new Selectoption('v5', 'l5'),
                                   new Selectoption('v2', 'l2'),
                                   new Selectoption('v2.2', 'l2'), // Same label case
                                   new Selectoption('v6', 'l6'),
                                   new Selectoption('v8', 'l8')
                               };
       
       doSortByFieldPath(opts, FieldToSort.Label,'aaa');
       doSortByFieldPath(opts, FieldToSort.Value,'aaa');
       
       System.assertEquals(opts.size(), 5);
       System.assertEquals('l1', opts[0].getLabel());
       System.assertEquals('l2', opts[1].getLabel());
        
        
    
    }
  
  //test method
  static testMethod void testLoad() {
        Selectoption[] opts = new Selectoption[] {};
       for (Integer idx = 0; idx < 2000; idx++) 
           opts.add(new Selectoption('v1', 'l1' + idx));
      
       doSort(opts, FieldToSort.Label);
       // 50,000 is max record count to be handled in apex at a time.
       // As of now its taking 150009 script lines to sort this big collection. So leaving nearly 50,000 lines for client code.
       // Here means we are good, the algo is good enough to survive within 200000 script lines governor limits.
    }
    
    
}