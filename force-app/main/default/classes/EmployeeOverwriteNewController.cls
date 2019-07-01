/**
 * @description To overwrite new button on employee page
 */
public with sharing class EmployeeOverwriteNewController {
    
    public static String returnURL = '/@prefix/e?retURL=%2F@prefix%2Fo&nooverride=1&Name='+ label.ELeave_Def_Name;
    public EmployeeOverwriteNewController (ApexPages.StandardController controller) {
    }
    
    public PageReference actionNew() {
        String prefix = '';
        Schema.DescribeSObjectResult r = Employee__c.sObjectType.getDescribe();
        prefix = r.getKeyPrefix( );
        return  new PageReference( returnURL.replace( '@prefix' , prefix  ) );
    }
}