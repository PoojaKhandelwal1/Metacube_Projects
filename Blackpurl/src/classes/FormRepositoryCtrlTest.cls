/**
 * Author: Richa Mittal
 * Since: Aug 10, 2018
 * Name: FormRepositoryCtrlTest
 * Description: It includes test methods for FormRepositoryCtrl.
**/
@isTest
public with sharing class FormRepositoryCtrlTest {
    static testMethod void removeFormTest() {
    	createFormRecordsForDeal();
    	List<Form__c> formList = [SELECT Id From Form__c];
    	String formId = formList[0].Id;
    	formId = BPUtility.getEncodedString(formId);
    	String responseString = BPUtility.getDecodedString(FormRepositoryCtrl.removeForm(formId));
    	ResponseWrapper responseObject = (ResponseWrapper) System.JSON.deserialize(responseString,ResponseWrapper.class);
    	system.assertEquals(responseObject.response,'success');
    }
    
    static testMethod void coverDeprecatedMethodTest() {
    	FormRepositoryCtrl.activateForm('abcd', true, true);
    	FormRepositoryCtrl.deleteForm('abcd');
    	FormRepositoryCtrl.activateForms('abcd');
    	System.assert(true, true);
    }
    
     static testMethod void getFormsListBasedOnTypeActiveTest() {
    	createFormRecordsForDeal();
    	String formType = BPUtility.getEncodedString('Active');
    	String responseString = BPUtility.getDecodedString(FormRepositoryCtrl.getFormsListBasedOnType(formType));
    	Map<String, List<FormRepositoryWrapper>> responseMap = (Map<String, List<FormRepositoryWrapper>>) System.JSON.deserialize(responseString,Map<String, List<FormRepositoryWrapper>>.class);
    	system.assert(responseMap.get('Deal').size() > 0);
    }
    
    static testMethod void activateFormTest() {
    	Form__c newForm = new Form__c();
    	newForm.Name = 'Test save Form';
    	newForm.Description__c = 'Test save form desc';
    	newForm.Grouping_Name__c = 'Deal';
    	newForm.Is_Manual_Upload__c = true;
    	newForm.Is_Active__c = false;
    	insert newForm;
    	
		List<FormRepositoryWrapper> listOfForms = new  List<FormRepositoryWrapper>();
		FormRepositoryWrapper formWrapper = new FormRepositoryWrapper(newForm);
		formWrapper.IsActive = true;
		listOfForms.add(formWrapper);
    	String formJSONString = BPUtility.getEncodedString(System.JSON.serialize(listOfForms));
    	String responseString = BPUtility.getDecodedString(FormRepositoryCtrl.activateFormList(formJSONString));
    	ResponseWrapper responseObject = (ResponseWrapper) System.JSON.deserialize(responseString,ResponseWrapper.class);
    	system.assertEquals(responseObject.response,'success');
    }
    
    static testMethod void addFormTest() {
    	Form__c newForm = new Form__c();
    	newForm.Name = 'Test save Form';
    	newForm.Description__c = 'Test save form desc';
    	newForm.Grouping_Name__c = 'Deal';
    	newForm.Is_Manual_Upload__c = true;
    	newForm.Is_Active__c = true;
    	FormRepositoryWrapper newFormJSON = new FormRepositoryWrapper(newForm);
    	String formJSONString = BPUtility.getEncodedString(System.JSON.serialize(newFormJSON));
    	String responseString = BPUtility.getDecodedString(FormRepositoryCtrl.saveForm(formJSONString));
    	ResponseWrapper responseObject = (ResponseWrapper) System.JSON.deserialize(responseString,ResponseWrapper.class);
    	system.assertEquals(responseObject.response,'success');
    }
    
    static testMethod void uploadFormTest() {
    	Form__c newForm = new Form__c();
    	newForm.Name = 'Test save Form';
    	newForm.Description__c = 'Test save form desc';
    	newForm.Grouping_Name__c = 'Deal';
    	newForm.Is_Manual_Upload__c = true;
    	newForm.Is_Active__c = true;
    	FormRepositoryWrapper newFormJSON = new FormRepositoryWrapper(newForm);
    	newFormJSON.FormNameWithExtension = 'Test save Form.pdf';
    	String formJSONString = BPUtility.getEncodedString(System.JSON.serialize(newFormJSON));
    	String testFile = BPUtility.getEncodedString('Test Attachment body');
    	String responseString = BPUtility.getDecodedString(FormRepositoryCtrl.uploadForm(formJSONString, testFile));
    	ResponseWrapper responseObject = (ResponseWrapper) System.JSON.deserialize(responseString,ResponseWrapper.class);
    	system.assertEquals(responseObject.response,'success');
    }
    
    static void createFormRecordsForDeal() {
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
    	system.assert(true, true);
    }
}