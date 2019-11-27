public with sharing class FormSOQLUtil {
    public static List<Form__c> getFormListBasedOnType(String formType) {
    	String query = 'SELECT ';
        for(String fieldsName : FormRepositoryWrapper.getFormFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        // Child Query
        query += '(SELECT Id FROM Attachments where Name like \'%.pdf\')';
        query += ' FROM Form__c WHERE ';
        if(formType == 'Active') {
        	query += 'Is_Active__c = true';
        } else if(formType == 'Available') {
        	query += 'Is_Manual_Upload__c = false';
        }
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Form__c> getActiveFormsListBasedOnGroup(String groupingName) {
    	String query = 'SELECT ';
        for(String fieldsName : FormRepositoryWrapper.getFormFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Form__c WHERE Is_Active__c = true AND Grouping_Name__c =: groupingName';
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Product__c> getVendorProducts() {
    	if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Product__c> vendorProductList = [SELECT Id, Product_Unique_Name__c FROM Product__c LIMIT :SOQLUtil.getAvailableQueryRowsLimit()];
        return vendorProductList;
    }
    
    public static Linked_Form__c getLinkedFormById(String linkedFormId) {
    	String query = 'SELECT ';
        for(String fieldsName : LinkedFormWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Linked_Form__c WHERE Id =: linkedFormId';
        if(AccessControl.ifObjectFieldIsAccessible('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Linked_Form__c> getLinkedFormsByGroup(String groupingName) {
    	String query = 'SELECT ';
        for(String fieldsName : LinkedFormWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Linked_Form__c WHERE Grouping_Name__c =: groupingName';
        if(AccessControl.ifObjectFieldIsAccessible('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Form__c> getUnlinkedActiveFormsByGroup(String groupingName) {
    	String query = 'SELECT ';
        for(String fieldsName : FormRepositoryWrapper.getFormFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Form__c WHERE Is_Active__c = true AND Grouping_Name__c =: groupingName AND id NOT IN (SELECT Form__c FROM Linked_Form__c)';
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Form__c> getAvailableActiveFormsBySectionId(String sectionId, String sectionName) {
    	String query = 'SELECT ';
        for(String fieldsName : FormRepositoryWrapper.getFormFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Form__c WHERE Is_Active__c = true AND Grouping_Name__c =: sectionName AND id NOT IN (SELECT Form__c FROM CO_Form__c WHERE (Deal__c =: sectionId OR Deal_Finance__c =: sectionId OR Service_Order_Header__c =: sectionId))';
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<CO_Form__c> getCOFormsListById(List<Id> sectionIdList) {
    	String query = 'SELECT ';
        for(String fieldsName : COFormWrapper.fieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        // Child Query
        query += '(SELECT Id FROM Attachments where Name like \'%.pdf\')';
        query += ' FROM CO_Form__c WHERE (Deal__c IN: sectionIdList OR Deal_Finance__c IN: sectionIdList OR Service_Order_Header__c IN: sectionIdList) ORDER BY CreatedDate ASC';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
}