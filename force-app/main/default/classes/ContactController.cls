public with sharing class ContactController {

    @AuraEnabled
    public static List<Contact> findAll() {
        return [SELECT id, name, phone FROM Contact LIMIT 50];
    }

    @AuraEnabled
    public static List<Contact> findByName(String searchKey) {
        String name = '%' + searchKey + '%';
        return [SELECT id, name, phone FROM Contact WHERE name LIKE :name LIMIT 50];
    }

    @AuraEnabled
    public static Contact findById(String contactId) {
        return [SELECT id, name, title, phone, mobilephone, Account.Name
                    FROM Contact WHERE Id = :contactId];
    }
    
    @AuraEnabled
    public static List<Contact> getContacts() {
        List<Contact> contacts = 
                [SELECT Id, Name, MailingStreet, Phone, Email, LeadSource FROM Contact];

        //Add isAccessible() check
        return contacts;
    }

    
    

}