@istest
Public class TestIDPSupplierPreparation {
    
    //format: [key, value]
    //[Supplier Name, Records]
    Public Map<String, Supplier__c> supplierMap {get;set;}
    Public Map<String, Supplier_Contact__c> supplierContactMap {get;set;}
    public Map<String, Currency__c> CurrencyMap {get; set;}

    Public boolean isSeeAllData;

    Public TestIDPSupplierPreparation (boolean isSeeAllData, Map<String, Currency__c> CurrencyMap) {
        this.isSeeAllData = isSeeAllData;
        initVariable(CurrencyMap);

    }
    
    Public void initVariable(Map<String, Currency__c> CurrencyMap) {
        this.supplierMap = new Map<String, Supplier__c> ();
        this.supplierContactMap = new Map<String, Supplier_Contact__c> ();
        this.currencyMap = CurrencyMap;
    }
    
    Public void basicSetting() {
        prepareSupplierTestData();
        prepareSupplierContactTestData();
    }
    
    
    Public void prepareSupplierTestData() {
        List<Supplier__c> toBeInsertedSupplier = new List<Supplier__c>();

        
        Supplier__c tempSupplier1 = new Supplier__c(
                City__c = 'Hong Kong',
                Country__c = 'Hong Kong',
                Country_Code__c = '852',
                Currency__c = this.currencyMap.get('HKD').Id,
                Delivery_Method__c = '015',
                Delivery_Terms__c = 'FOB',
                Fax_Number__c = '852-22224444',
                Keyword__c = 'All',
                Media_Profile__c = '21',
                Payment_Method__c = 'CA',
                Payment_Terms__c = '10D',
                Postal_Address__c = 'Block A, ABC Buidling',
                Postal_Code__c = '',
                Remark__c = 'test',
                State__c = '',
                Status__c = 'ACT',
                Supplier_Code__c = 'SUPPLIER1',
                Supplier_Name__c = 'SUPPLIER1',
                Supplier_Type__c = '0',
                Tax__c = 3,
                Telex_Number__c = '852-33334444',
                Tel_Number_1__c = '852-11112222',
                Tel_Number_2__c = '852-66123333'
        );
        
        Supplier__c tempSupplier2 = new Supplier__c(
                City__c = 'Hong Kong',
                Country__c = 'Hong Kong',
                Country_Code__c = '852',
                Currency__c = this.currencyMap.get('USD').Id,
                Delivery_Method__c = '015',
                Delivery_Terms__c = 'FOB',
                Fax_Number__c = '852-22224444',
                Keyword__c = 'All',
                Media_Profile__c = '21',
                Payment_Method__c = 'CA',
                Payment_Terms__c = '10D',
                Postal_Address__c = 'Block A, ABC Buidling',
                Postal_Code__c = '',
                Remark__c = 'test',
                State__c = '',
                Status__c = 'ACT',
                Supplier_Code__c = 'SUPPLIER2',
                Supplier_Name__c = 'SUPPLIER2',
                Supplier_Type__c = '0',
                Tax__c = 3,
                Telex_Number__c = '852-33334444',
                Tel_Number_1__c = '852-11112222',
                Tel_Number_2__c = '852-66123333'
        );
        Supplier__c tempSupplier3 = new Supplier__c(
                City__c = 'Hong Kong',
                Country__c = 'Hong Kong',
                Country_Code__c = '852',
                Currency__c = this.currencyMap.get('USD').Id,
                Delivery_Method__c = '015',
                Delivery_Terms__c = 'FOB',
                Fax_Number__c = '852-22224444',
                Keyword__c = 'All',
                Media_Profile__c = '21',
                Payment_Method__c = 'CA',
                Payment_Terms__c = '10D',
                Postal_Address__c = 'Block A, ABC Buidling',
                Postal_Code__c = '',
                Remark__c = 'test',
                State__c = '',
                Status__c = 'ACT',
                Supplier_Code__c = 'SUPPLIER3',
                Supplier_Name__c = 'SUPPLIER3',
                Supplier_Type__c = '0',
                Tax__c = 3,
                Telex_Number__c = '852-33334444',
                Tel_Number_1__c = '852-11112222',
                Tel_Number_2__c = '852-66123333'
        );  
                
        Supplier__c tempSupplier4 = new Supplier__c(
                City__c = 'Hong Kong',
                Country__c = 'Hong Kong',
                Country_Code__c = '852',
                Currency__c = this.currencyMap.get('CAD').Id,
                Delivery_Method__c = '015',
                Delivery_Terms__c = 'FOB',
                Fax_Number__c = '852-22224444',
                Keyword__c = 'All',
                Media_Profile__c = '21',
                Payment_Method__c = 'CA',
                Payment_Terms__c = '10D',
                Postal_Address__c = 'Block A, ABC Buidling',
                Postal_Code__c = '',
                Remark__c = 'test',
                State__c = '',
                Status__c = 'ACT',
                Supplier_Code__c = 'SUPPLIER4',
                Supplier_Name__c = 'SUPPLIER4',
                Supplier_Type__c = '0',
                Tax__c = 3,
                Telex_Number__c = '852-33334444',
                Tel_Number_1__c = '852-11112222',
                Tel_Number_2__c = '852-66123333'
        );            
                    
        toBeInsertedSupplier.add(tempSupplier1);
        toBeInsertedSupplier.add(tempSupplier2);
        toBeInsertedSupplier.add(tempSupplier3);
        toBeInsertedSupplier.add(tempSupplier4);

        
        insert toBeInsertedSupplier;
        
        for(Supplier__c reader : toBeInsertedSupplier) {
            supplierMap.put(reader.Supplier_Name__c, reader);
        
        }
    }
    
    Public void prepareSupplierContactTestData() {
        List<Supplier_Contact__c > toBeInsertedSupplierContact = new List<Supplier_Contact__c >();
        String keyName = '';
        Integer counter = 1;
        for(Supplier__c reader: supplierMap.values()) {
            Supplier_Contact__c tempSC = new Supplier_Contact__c(
                Contact_Name__c = 'Jimmy Wong ' + string.valueOf(counter),
                Email_Address__c = 'jwtest@test.com',
                Fax_Number__c = '852-12312323',
                Remark__c = 'test',
                Supplier__c = reader.Id,
                Tel_Number_1__c = '852-98765432',
                Tel_Number_2__c = '852-12345601',
                Title__c = 'Mr.'
            );
            
            counter++;
            
            toBeInsertedSupplierContact.add(tempSC);
        }
        
        insert toBeInsertedSupplierContact;
        
        for(Supplier_Contact__c sc: toBeInsertedSupplierContact) {
            for(Supplier__c s : supplierMap.values()) {
                
                if (sc.Supplier__c == s.Id) {
                    keyName = supplierMap.get(s.Supplier_Name__c).Supplier_Name__c + 'SC';
                    this.supplierContactMap.put(keyName, sc);
                }
            }
        }
    }
}