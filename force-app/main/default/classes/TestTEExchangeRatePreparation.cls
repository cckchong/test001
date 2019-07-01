@istest
public class TestTEExchangeRatePreparation {
    
    public Map<String, Currency__c> currencyMap {get;set;}
    public Map<String, Exchange_Rate__c> exchangeRateMap {get;set;}
    public boolean isSeeAllData;
    
    public TestTEExchangeRatePreparation(Boolean isSeeAllData) {
        this.isSeeAllData = isSeeAllData;
        currencyMap = new Map<String, Currency__c> ();
        exchangeRateMap = new Map<String, Exchange_Rate__c>();
    }
    
    public void basicSetting() {
        
        /**
         * init currency. Key: [HKD, USD, CAD]
         */
        List<Currency__c> currencyList = new List<Currency__c>();
        Currency__c hkd = new Currency__c (
            Name = 'HKD',
            Description__c = 'Hong Kong Dollar',
            Is_Budget_Currency__c = true,
            keyword__c = 'all'
        );
        currencyList.add(hkd);
        Currency__c usd = new Currency__c (
            Name = 'USD',
            Description__c = 'US Dollar',
            keyword__c = 'all'
        );
        currencyList.add(usd);
        Currency__c cad = new Currency__c (
            Name = 'CAD',
            Description__c = 'Canadian Dollar',
            keyword__c = 'all'
        );
        currencyList.add(cad);
        insert currencyList;
        List<ID> currencyIDList = new List<ID>();
        for (Currency__c c : currencyList) {
            currencyIDList.add(c.Id);
        }
        for (Currency__c c : [select Id, Name, Description__c, keyword__c from Currency__c where Id IN :currencyIDList]) {
            currencyMap.put(c.Name, c);
        }

        /**
         * init exchange rate. Key: [USDHKD20150807, USDHKD20150810, CADHKD20150810, HKDHKD20150810]
         */
        List<Exchange_Rate__c> exchangeRateList = new List<Exchange_Rate__c>();
        Exchange_Rate__c er1 = new Exchange_Rate__c(
            //Date__c = Date.parse('11/26/2015'),
            Date__c = Date.newInstance(2015, 11, 26),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BK',
            Rate__c = 7.7515
        );
        exchangeRateList.add(er1);
        Exchange_Rate__c er2 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BK',
            Rate__c = 7.7557
            //,
            //Is_Latest__c = true

        );
        exchangeRateList.add(er2);
        Exchange_Rate__c er3 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('CAD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BK',
            Rate__c = 5.9599
        );
        exchangeRateList.add(er3);
        Exchange_Rate__c er4 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('HKD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BK',
            Rate__c = 1
        );
        exchangeRateList.add(er4);        
        Exchange_Rate__c er5 = new Exchange_Rate__c(
            //Date__c = Date.parse('01/01/2014'),
            Date__c = Date.newInstance(2014, 1, 1),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BK',
            Rate__c = 7.7511
        );
        exchangeRateList.add(er5);
        Exchange_Rate__c er6 = new Exchange_Rate__c(
//            Date__c = Date.parse('08/07/2015'),
            Date__c = Date.newInstance(2015, 8, 7),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BU',
            Rate__c = 7.7515
        );
        exchangeRateList.add(er6);
        Exchange_Rate__c er7 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BU',
            Rate__c = 7.7557
        );
        exchangeRateList.add(er7);
        Exchange_Rate__c er8 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('CAD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BU',
            Rate__c = 5.9599
        );
        exchangeRateList.add(er8);
        Exchange_Rate__c er9 = new Exchange_Rate__c(
            //Date__c = Date.parse('08/10/2015'),
            Date__c = Date.newInstance(2015, 8, 10),
            From_Currency__c = currencyMap.get('HKD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BU',
            Rate__c = 1
        );
        exchangeRateList.add(er9);        
        Exchange_Rate__c er10 = new Exchange_Rate__c(
            //Date__c = Date.parse('01/01/2014'),
            Date__c = Date.newInstance(2014, 1, 1),
            From_Currency__c = currencyMap.get('USD').Id,
            To_Currency__c = currencyMap.get('HKD').Id,
            Type__c = 'BU',
            Rate__c = 7.7511
        );
        exchangeRateList.add(er10);

        insert exchangeRateList;
        List<ID> exchangeRateIDList = new List<ID>();
        for (Exchange_Rate__c er : exchangeRateList) {
            exchangeRateIDList.add(er.ID);
        }
        for (Exchange_Rate__c er : [select Id, Tech_From_To_Currency_ID__c, Rate__c, Exchange_Rate_ID__c, Is_Latest__c, From_Currency__c, To_Currency__c, Date__c, 
                                    From_Currency_Description__c, To_Currency_Description__c, Tech_From_To_Currency__c, Tech_From_To_Currency_Date__c from Exchange_Rate__c where Id IN :exchangeRateIDList]) {
            exchangeRateMap.put(er.Tech_From_To_Currency_Date__c, er);
        }

    }
}