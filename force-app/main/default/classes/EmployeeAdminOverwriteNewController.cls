/**
 * @description To overwrite New buttom on employee admin page
 */
public with sharing class EmployeeAdminOverwriteNewController {
    
    public static String returnURL = '/@prefix/e?retURL=%2F@prefix&nooverride=1&Name='+ label.ELeave_Def_Name;
    public EmployeeAdminOverwriteNewController (ApexPages.StandardController controller) {
    }
   
    /**
    * @description To redirect new employee admin creation paage
    */ 
    public PageReference actionNew() {
        String prefix = '';
        Schema.DescribeSObjectResult r = Employee_Administrator__c.sObjectType.getDescribe();
        prefix = r.getKeyPrefix( );
        return  new PageReference( returnURL.replace( '@prefix' , prefix  ) );
    }
}