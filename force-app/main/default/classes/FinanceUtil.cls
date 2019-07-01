public class FinanceUtil{
    
    /*
    private String function;
    private String department;
    private String section;
    private String policy;
    
    Public financeUtil(String policy, String function, String department, String section){
        this.policy= policy;
        this.function = function;
        this.department= department;
        this.section = section;
    }
    */
    /*
        costCenterKeyList = policy_function_department_section
    */
    Public Map<String, Cost_Center__c> CostCenterMap (List<String> costCenterKeyList){
        String [] keyArray = null;
        Set <String> keySet = new Set <String>();
        Map<String, Cost_Center__c> CostCenterMap = new Map<String, Cost_Center__c>();
        String policy = '';
        String function = '';
        String department = '';
        String section = '';
        String functionAndDepartment = '';
        String functionAndDepartmentAndSection = '';
        Cost_Center__c cc = null;
        System.debug('costCenterKeyList');
        System.debug(costCenterKeyList);
        for(String reader : costCenterKeyList){
            keyArray = reader.split('_');
            if (!(keyArray.size() == 4 || keyArray.size() == 3)){
                continue;
            }
            policy = '';
            function = '';
            department = '';
            section = '';
            
            if(!String.isBlank(keyArray[0])){
                policy = keyArray[0].toUpperCase(); 
            }
            if(!String.isBlank(keyArray[1])){
                function = keyArray[1].toUpperCase();
            }
            if(!String.isBlank(keyArray[2])){
                department = keyArray[2].toUpperCase(); 
            }
            if(keyArray.size() == 4 && !String.isBlank(keyArray[3])){
                section = keyArray[3].toUpperCase(); 
            }
            keySet.add(policy + '_' + function + '_' + department + '_' + section);
            keySet.add(policy + '_' + function + '_' + department);
        }
        System.debug(keySet);
        for(cost_center__c reader : [select id, Name, Tech_Policy_Function_Department_Section__c from cost_center__c 
                                     where Tech_Policy_Function_Department_Section__c in :keySet
                                    ]){
            CostCenterMap.put(reader.Tech_Policy_Function_Department_Section__c, reader);
            
            
            
        }
        System.debug(CostCenterMap);
        return CostCenterMap;
    }
    
    /*
        BudgetKeyList = effDate_policy_expenseCategoryId_function_department_section
        effDate = yyyy-mm-dd
    */
    Public Map<String, Budget__c> BudgetMap (List<String> BudgetKeyList){        
        String [] keyArray = null;
        String [] effDateArray = null;
        Set <String> policyCatdepKeySet = new Set <String>();
        Set <String> expenseCategoryKeySet = new Set <String>();
        Set <String> effDateKeySet = new Set <String>();
        String expenseCat = '';
        String seffDate = '';

        String policy = '';
        String function = '';
        String department = '';
        String section = '';
        String functionAndDepartment = '';
        String functionAndDepartmentAndSection = '';
        Date effDate = null;
        Map<String, Budget__c> budgetMap = new Map<String, Budget__c>();
        
        for(String reader : BudgetKeyList){
            keyArray = reader.split('_');
            if (!(keyArray.size() == 6 || keyArray.size() == 5)){
                continue;
            }
            if(!String.isBlank(keyArray[0])){
                seffDate = keyArray[0].toUpperCase();
                effDateArray = seffDate.split('-');
                if (effDateArray.size() == 3 ){
                    effDate = Date.newInstance(Integer.valueof(effDateArray[0]), Integer.valueof(effDateArray[1]), Integer.valueof(effDateArray[2]));
                }
                else{
                    continue;
                }
            }
            
            if(!String.isBlank(keyArray[1])){
                expenseCat = keyArray[1]; 
            }
            if(!String.isBlank(keyArray[2])){
                policy  = keyArray[2].toUpperCase(); 
            }
            if(!String.isBlank(keyArray[3])){
                function = keyArray[3].toUpperCase(); 
            }
            if(!String.isBlank(keyArray[4])){
                department = keyArray[4].toUpperCase(); 
            }
            if(keyArray.size() == 6 && !String.isBlank(keyArray[5])){
                section = keyArray[5].toUpperCase(); 
            }
            policyCatdepKeySet.add(expenseCat + '_' + policy + '_' + function + '_' + department + '_' + section);
            policyCatdepKeySet.add(expenseCat + '_' + policy + '_' + function + '_' + department);
            //expenseCategoryKeySet.add(expenseType);
            //effDateKeySet.add(effDate);
        }
        for(Budget__c reader : [select id, Effective_Start_Date__c, Effective_End_Date__c,Currency__r.Name,
                                Expense_Category__r.Name, Expense_Amount__c,
                                Tech_Cat_Policy_Function_Dep_Section__c, Tech_Policy_Function_Department_Section__c
                                from Budget__c 
                                where 
                                Tech_Cat_Policy_Function_Dep_Section__c in :policyCatdepKeySet
                                and Effective_Start_Date__c <= :effDate 
                                and Effective_End_Date__c >= :effDate 
                               ]){
            budgetMap.put(keyArray[0] + '_' + reader.Tech_Cat_Policy_Function_Dep_Section__c, reader);
        }
        return budgetMap;
    }
    
    /*
    Public cost_center__c CostCenter(String key){
        String [] keyArray = key.split('_');
        String function = '';
        String department = '';
        String section = '';
        String functionAndDepartment = '';
        String functionAndDepartmentAndSection = '';
        Cost_Center__c cc = null;
        
        if(keyArray.size() != 3){
            return null;
        }
        if(!String.isBlank(keyArray[0])){
            function = keyArray[0].toLowerCase(); 
        }
        if(!String.isBlank(keyArray[1])){
            department = keyArray[1].toLowerCase();
        }
        if(!String.isBlank(keyArray[2])){
            section = keyArray[2].toLowerCase(); 
        }
        functionAndDepartment = function + department;
        functionAndDepartmentAndSection = function + department + section;
        
        for(cost_center__c reader : [select id, Name, Tech_Policy_Function_Department_Section__c from cost_center__c 
                                     where Tech_Policy_Function_Department_Section__c in (:functionAndDepartment, :functionAndDepartmentAndSection )
                                    ]){
            
            if(reader.Tech_Policy_Function_Department_Section__c == functionAndDepartment && cc == null){
                cc = reader;
            }
            if(reader.Tech_Policy_Function_Department_Section__c == functionAndDepartmentAndSection){
                cc = reader;
            }
        }
        
        return cc;
    }
    
    Public Budget__c Budget(String key){
        String [] keyArray = key.split('_');
        String function = '';
        String department = '';
        String section = '';
        String functionAndDepartment = '';
        String functionAndDepartmentAndSection = '';
        Budget__c budget = null;
        
        if(keyArray.size() != 3){
            return null;
        }
        if(!String.isBlank(keyArray[0])){
            function = keyArray[0].toLowerCase(); 
        }
        if(!String.isBlank(keyArray[1])){
            department = keyArray[1].toLowerCase();
        }
        if(!String.isBlank(keyArray[2])){
            section = keyArray[2].toLowerCase(); 
        }
        functionAndDepartment = function + department;
        functionAndDepartmentAndSection = function + department + section;
        
        return budget;
    }
    */
}