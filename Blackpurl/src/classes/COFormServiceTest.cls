@isTest
private class COFormServiceTest {

    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test First Name', 'Test Last Name');
    	CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
    	Service_Order_Header__c soHeader = TestDataFactory.createSOHeader(coHeader.Id);
    	
    	Category__c category = TestDataFactory.createCategory('Test Category');
    	Account vendor = TestDataFactory.createVendor('Test Vendor');
    	Product__c product = TestDataFactory.createProduct(category.Id, 'Test Product2', vendor.Id);
    	Form__c form = TestDataFactory.createForm();
    	
    	List<Linked_Form__c> linkedFormList = new List<Linked_Form__c>();
    	for(Integer i = 0; i < 20; i++){
    		linkedFormList.add(TestDataFactory.sampleLinkedForm(form.Id, null, 'Service'));
    	}
		insert linkedFormList;
    }
    
    @isTest
    private static void testInsertDefaultCOForms(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	COFormService.insertDefaultCOForms(coHeader.Id, soHeader.Id);
    	List<CO_Form__c> coForm = new List<CO_Form__c>([SELECT Id FROM CO_Form__c]);
      	system.assertEquals(coForm.size(), 20);
    	Test.stopTest();
    }
    
    @isTest
    private static void testInsertDefaultCOFormsWithVendorProduct(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	Product__c product = [SELECT Id FROM Product__c LIMIT 1];
    	COFormService.insertDefaultCOForms(coHeader.Id, soHeader.Id, product.Id);
    	List<CO_Form__c> coForm = new List<CO_Form__c>([SELECT Id FROM CO_Form__c]);
      	system.assertEquals(coForm.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetActiveFormsBySectionId(){
    	Test.startTest();
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	List<FormRepositoryWrapper> formRepositoryWrapperList = new List<FormRepositoryWrapper>(COFormService.getActiveFormsBySectionId(soHeader.Id));
    	system.assertEquals(formRepositoryWrapperList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetCOFormsBySectionId(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	CO_Form__c coForm = TestDataFactory.createCOForm(soHeader.Id, coHeader.Id);
    	COFormWrapper coFormWrapper = new COFormWrapper(coForm);
    	Map<Id, List<COFormWrapper>> coFormList = new Map<Id, List<COFormWrapper>>(COFormService.getCOFormsBySectionId(soheader.Id));
    	system.assertEquals(coFormList.size(), 1);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetCOFormsBySectionIdForAllSectionName(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Map<Id, List<COFormWrapper>> coFormList = new Map<Id, List<COFormWrapper>>(COFormService.getCOFormsBySectionId(coHeader.Id));
    	system.assertEquals(coFormList.size(), 0);
    	Test.stopTest();
    }

    @isTest
    private static void testAddFormsToSection(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	List<CO_Form__c> coFormList = new List<CO_form__c>();
    	for(Integer i = 0; i < 20; i++){
    		coFormList.add(TestDataFactory.sampleCOForm(null, null));
    	}
    	List<COFormWrapper> coFormWrapperList = new List<COFormWrapper>();
    	for(CO_Form__c coForm: coFormList){
    		coFormWrapperList.add(new COFormWrapper(coForm, true));
    	}
    	String formJson = system.Json.serialize(coFormWrapperList);
    	COFormService.addFormsToSection(coHeader.Id, soHeader.Id, formJson);
    	List<CO_Form__c> coFormUpdatedList = new List<CO_Form__c>([SELECT Id FROM CO_Form__c]);
    	system.assertEquals(coFormUpdatedList.size(), 20);
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteCOForm(){
    	Test.startTest();
    	CO_Form__c coForm = TestDataFactory.createCOForm(null, null);
    	COFormService.deleteCOForm(coForm.Id);
		List<CO_Form__c> coFormList = new List<CO_Form__c>([SELECT Id FROM CO_Form__c WHERE Id =: coForm.Id]);    
		system.assertEquals(coFormList.size(), 0);	
    	Test.stopTest();
    }
    
    @isTest
    private static void testDeleteCOFormUsingSectionId(){
    	Test.startTest();
    	CO_Header__c coHeader = [SELECT Id FROM CO_Header__c LIMIT 1];
    	Service_Order_Header__c soHeader = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	CO_Form__c coForm = TestDataFactory.createCOForm(soHeader.Id, coHeader.Id);
    	Set<Id> sectionIdSet = new Set<Id>();
    	sectionIdSet.add(soHeader.Id);
    	COFormService.deleteCOFormUsingSectionId(sectionIdSet);
    	List<CO_Form__c> coFormList = new List<CO_Form__c>([SELECT Id FROM CO_Form__c WHERE Id =: coForm.Id]);    
		system.assertEquals(coFormList.size(), 0);
    	Test.stopTest();
    }
    
    @isTest
    private static void testGetActiveFormsCount(){
    	Test.startTest();
    	Map<String, Decimal> activeFormCountMap = new Map<String, Decimal>(COFormService.getActiveFormsCount());
    	system.assertEquals(activeFormCountMap.size(), 3);
    	Test.stopTest();
    }
}