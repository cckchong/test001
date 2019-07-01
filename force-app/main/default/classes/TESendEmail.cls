public without sharing class TESendEmail{

    private ApexPages.StandardController standardController;

 
    public TESendEmail(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
    }
    
    
    /**
     *  overload the sendEmail method below, with a default TRUE value of sendToTarget
     */
//    public static void sendEmail(String fromOrgWideEmailAddressId, String fromDisplayName, List<String> toAddressList, List<String> ccAddressList, String emailTemplateId,String targetObjectId, Id whatId) {
    public static void sendEmail(String fromOrgWideEmailAddressName, String fromDisplayName, List<String> toAddressList, List<String> ccAddressList, String emailTemplateId,String targetObjectId, Id whatId) {
        
        sendEmail(fromOrgWideEmailAddressName, fromDisplayName, toAddressList, ccAddressList, emailTemplateId, targetObjectId, whatId, TRUE);
    
    }
    
    public static void sendEmail(String fromOrgWideEmailAddressName, String fromDisplayName, List<String> toAddressList, List<String> ccAddressList, String emailTemplateId,String targetObjectId, Id whatId, boolean sendToTarget) {

        //Messaging.reserveSingleEmailCapacity(100);
        OrgWideEmailAddress fromOrgWideEmailAddress = null;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        //if(fromOrgWideEmailAddressId != null) {
        //        mail.setOrgWideEmailAddressId(fromOrgWideEmailAddressId);
        //}
        if(fromOrgWideEmailAddressName !=null) {
            fromOrgWideEmailAddress = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName =: fromOrgWideEmailAddressName];
            mail.setOrgWideEmailAddressId(fromOrgWideEmailAddress.Id);
        }
        else {
            mail.setSenderDisplayName(fromDisplayName);        
        }
        
        /*
        //testing
        List<String> temp = new List<String> ();
        temp.add('tedpang0207@gmail.com');
        mail.setOrgWideEmailAddressId('0D2O00000008QXbKAM');
        mail.setToAddresses(temp);
        mail.setTemplateId('00XO0000000ETKeMAO');
        mail.saveAsActivity = false;
        // User,Contact or lead Id
        mail.setTargetObjectId('005O0000002UgcbIAC');
        //e.g. Travel Application Id
        mail.setWhatId('a18O0000003SzDHIA0');
        */
        
        mail.setToAddresses(toAddressList);
        mail.setCcAddresses(ccAddressList);
        mail.setTemplateId(emailtemplateId);
        // User,Contact or lead Id
        mail.setTargetObjectId(targetObjectId);
        //e.g. Travel Application Id
        mail.setWhatId(whatId);
        mail.saveAsActivity = false;
        mail.setTreatTargetObjectAsRecipient(sendToTarget);        
        //Send the email you have created
        System.debug('========================================');
        System.debug(mail);
        System.debug('========================================');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            
    }
    /**
    public static PageReference testsendEmail(){
        String fromOrgWideEmailAddressId = '0D2O00000008QXbKAM';
        String fromOrgWideEmailAddressName = 'Salesforce Admin';
        String fromDisplayName = null;
        List<String> toAddressList = new List<String> ();
        List<String> ccAddressList = new List<String> ();
        //String emailTemplateId = '00XO0000000EU5S';//'00XO0000000ETKe';// EA'00XO0000000ETvDMAW';
        //String targetObjectId = '005O0000001zzch';//'005O0000002Ugcb';//Elaine'005O0000001zzch';
        //Id whatId = 'a18O0000003T9jYIAS';//'a18O0000003T3Zr';//ea'a19O0000001kJ0i';
        //toAddressList.add('zxiang@deloitte.com.hk');
        
        String targetObjectId = '005O0000001zzch';//Elaine
        
        //CA:OPEN
        //String emailTemplateId = '00XO0000000ETv3';
        //Id whatId = 'a14O00000022BIP';
        
        //TA with all existing CA
        //String emailTemplateId = '00XO0000000ETuj';
        //Id whatId = 'a18O0000003TAyu';
        
        //Cancelled TA with existing paid out CA
        //String emailTemplateId = '00XO0000000EU4y';
        //Id whatId = 'a18O0000003T9oO';  
        
        //EA request approval 
        //String emailTemplateId = '00XO0000000EU6V';
        //Id whatId = 'a19O0000001kKVc';  
        
        //EA status changed to applicant
        //String emailTemplateId = '00XO0000000EU58';
        //Id whatId = 'a19O0000001kKNx';          
        
        //EA status changed to approver
        //String emailTemplateId = '00XO0000000EUFN';
        //Id whatId = 'a19O0000001kKNx';             
        
        //EA status changed to HCM
        //String emailTemplateId = '00XO0000000EUFS';
        //Id whatId = 'a19O0000001kKNx';            
        
        
        //Expense request approval
        //String emailTemplateId = '00XO0000000EUF8';
        //Id whatId = 'a1IO0000007vUyI';  

        //Expense status changed to applicant
        //String emailTemplateId = '00XO0000000EUFI';
        //Id whatId = 'a1IO0000007vUD7';          
        
        //Expense status changed to approver
        //String emailTemplateId = '00XO0000000EUFX';
        //Id whatId = 'a1IO0000007vUD7';             
        
        //Expense status changed to FIN
        //String emailTemplateId = '00XO0000000EUFc';
        //Id whatId = 'a1IO0000007vUCx';             
        

        //Expense status changed to HCM
        //String emailTemplateId = '00XO0000000EUIl';
        //Id whatId = 'a1IO0000007vUCx';    
               
        //TA local admin 
        //String emailTemplateId = '00XO0000000EU4j';
        //Id whatId = 'a18O0000003T9n1';          
        
        //TA TravelApplicationRequireActionAgency
        //String emailTemplateId = '00XO0000000EU6f';
        //Id whatId = 'a18O0000003TAzEIAW';  

        //TA TravelApplicationRequireActionApplicant            
        //String emailTemplateId = '00XO0000000EU5S';
        //Id whatId = 'a18O0000003TAzEIAW';  


        //TA TravelApplicationStatusChangedAgency
        //String emailTemplateId = '00XO0000000EU5m';
        //Id whatId = 'a18O0000003TAzEIAW';          
        
        //TA TravelApplicationStatusChangedApplicant
        //String emailTemplateId = '00XO0000000ETga';
        //Id whatId = 'a18O0000003TAzEIAW'; 

        //TA TravelApplicationStatusChangedSiteAdmin
        //String emailTemplateId = '00XO0000000EU5r';
        //Id whatId = 'a18O0000003TAzEIAW';        
        
        //TA TravelApplicationTravelAgency
        //String emailTemplateId = '00XO0000000ETKe';
        //Id whatId = 'a18O0000003T9gj';        
        
        
        //Td assign departure shuttle 
        //String emailTemplateId = '00XO0000000EUOA';
        //Id whatId = 'a16O0000004QSS6'; 
        
        //TravelDetailUnassignCancelDepartureShuttle
        String emailTemplateId = '00XO0000000EUOZ';
               emailTemplateId = '00XO0000000ETKeMAO';
        Id whatId = 'a18O0000003TKaCIAW'; 
                
        //toAddressList.add('tedpang@deloitte.com.hk');
        toAddressList.add('taagtuser@gmail.com');
        //ccAddressList.add('taappuser@gmail.com');
        sendEmail(fromOrgWideEmailAddressName, fromDisplayName, toAddressList, ccAddressList, emailTemplateId, targetObjectId, whatId);
        return null;
    }
    */
}