@isTest
public class LinkedFormControllerTest {
	
	@testSetup
    static void createLinkedFormRecordsForDeal() {
    	Form__c newForm = new Form__c();
    	newForm.Name = 'Test deal Form';
    	newForm.Description__c = 'Test deal form';
    	newForm.Grouping_Name__c = 'Deal';
    	newForm.Is_Manual_Upload__c = true;
    	newForm.Is_Active__c = true;
    	insert newForm;
    	
    	Attachment attachment = new Attachment();
    	attachment.ParentId = newForm.Id;
    	Blob actualdata = EncodingUtil.base64Decode('Test Attachment body');
    	attachment.Body = actualdata;
    	attachment.Name= 'Test Attachment';
    	insert Attachment; 
    	
    	Account vendor = TestUtil.createVendor(false, 'Test Vendor');
        vendor.Finance_Company__c = true;
        insert vendor;
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c testPart1 = TestUtil.createPart(true, 'Part11', vendor.Id, 'Test Part1', testCategory.Id);
        
        Product__c testProduct1 = TestUtil.createProduct(false, testCategory.Id, 'Test Product2', vendor.Id);
        testProduct1.Type__c = 'Financing Product';
        insert testProduct1;
    	
    	Linked_Form__c linkedForm = new Linked_Form__c();
    	linkedForm.Form__c = newForm.Id;
    	linkedForm.Is_Required__c = false;
    	linkedForm.Grouping_Name__c = 'Deal';
    	linkedForm.Vendor_Product__c = testProduct1.Id;
    	insert linkedForm;
    }
    
    static testMethod void getActiveFormsByGroupTest() {
    	Form__c newForm1 = new Form__c();
    	newForm1.Name = 'Test deal Form';
    	newForm1.Description__c = 'Test deal form';
    	newForm1.Grouping_Name__c = 'Deal';
    	newForm1.Is_Manual_Upload__c = true;
    	newForm1.Is_Active__c = true;
    	insert newForm1;
    	
    	String groupingName = BPUtility.getEncodedString('Deal');
    	String responseString = BPUtility.getDecodedString(LinkedFormController.getActiveFormsByGroup(groupingName));
    	List<FormRepositoryWrapper> responseList = (List<FormRepositoryWrapper>) System.JSON.deserialize(responseString, List<FormRepositoryWrapper>.class);
    	system.assert(responseList.size() > 0);
    }
    
    static testMethod void getLinkedFormsByGroupTest() {
    	String groupingName = BPUtility.getEncodedString('Deal');
    	String responseString = BPUtility.getDecodedString(LinkedFormController.getLinkedFormsByGroup(groupingName));
    	List<LinkedFormWrapper> responseList = (List<LinkedFormWrapper>) System.JSON.deserialize(responseString, List<LinkedFormWrapper>.class);
    	system.assert(responseList.size() > 0);
    }
    
    static testMethod void deleteLinkedFormTest() {
    	List<Linked_Form__c> linkedForm = [SELECT Id FROM Linked_Form__c];
    	String linkedFormId = BPUtility.getEncodedString(linkedForm[0].Id);
    	String responseString = BPUtility.getDecodedString(LinkedFormController.deleteLinkedForm(linkedFormId));
    	system.assertEquals(responseString, 'Success');
    }
    
    static testMethod void getVendorProductsTest() {
    	String responseString = BPUtility.getDecodedString(LinkedFormController.getVendorProducts());
    	List<LinkedFormWrapper.VendorProductWrapper> responseList = (List<LinkedFormWrapper.VendorProductWrapper>) System.JSON.deserialize(responseString, List<LinkedFormWrapper.VendorProductWrapper>.class);
    	system.assert(responseList.size() > 0);
    }
    
    static testMethod void getOverviewDetailsTest() {
    	String responseString = BPUtility.getDecodedString(LinkedFormController.getOverviewDetails());
    	List<LinkedFormWrapper.LinkedFormOverviewWrapper> responseList = (List<LinkedFormWrapper.LinkedFormOverviewWrapper>) System.JSON.deserialize(responseString, List<LinkedFormWrapper.LinkedFormOverviewWrapper>.class);
    	system.assert(responseList.size() > 0);
    }
    
    static testMethod void saveLinkedFormTest() {
    	List<Form__c> form = [SELECT Id FROM Form__c];
    	List<Product__c> product = [SELECT Id FROM Product__c];
    	Linked_Form__c linkedForm = new Linked_Form__c();
    	linkedForm.Form__c = form[0].Id;
    	linkedForm.Is_Required__c = true;
    	linkedForm.Grouping_Name__c = 'Deal';
    	linkedForm.Vendor_Product__c = product[0].Id;
    	String linkedFormJSONString = BPUtility.getEncodedString(System.JSON.serialize(new LinkedFormWrapper(linkedForm)));
    	String responseString = BPUtility.getDecodedString(LinkedFormController.saveLinkedForm(linkedFormJSONString));
    	LinkedFormWrapper responseList = (LinkedFormWrapper) System.JSON.deserialize(responseString, LinkedFormWrapper.class);
    	system.assert(responseList.Id != null);
    }
}