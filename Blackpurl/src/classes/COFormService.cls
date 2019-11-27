/** 
* Author: Tarun Khandelwal
* Since: Aug 07, 2018 
* Name: COFormService 
* Description: Service class which contains all methods related to CO forms.
**/
public without sharing class COFormService {
    
    private static String AUTOMATICALLY_CREATED = 'Automatically Created';
    private static String MANUAL_UPLOAD = 'Manual Upload';
    
    public static void insertDefaultCOForms(String coHeaderId, String sectionId) {
        insertDefaultCOForms(coHeaderId, sectionId, null);
    }
    
    public static void insertDefaultCOForms(String coHeaderId, String sectionId, String vendorProductId) {
        String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
            return;
        }
        if(AccessControl.ifObjectFieldIsAccessible('Linked_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Linked_Form__c> linkedFormList;
        if(vendorProductId != null) {
            linkedFormList = [SELECT Form__c, Form__r.Name, Form__r.Description__c, Form__r.Is_Manual_Upload__c, Form__r.Is_Editable__c, Form__r.Form_Edit_Config__c, Form__r.Edit_Modal_Name__c, Vendor_Product__c from Linked_Form__c 
                                                WHERE Vendor_Product__c =: vendorProductId];
        } else {
            linkedFormList = [SELECT Form__c, Form__r.Name, Form__r.Description__c, Form__r.Is_Manual_Upload__c, Form__r.Is_Editable__c, Form__r.Form_Edit_Config__c, Form__r.Edit_Modal_Name__c, Vendor_Product__c from Linked_Form__c 
                                                WHERE Grouping_Name__c =: sectionName AND Vendor_Product__c = null];
        }
        
        if(linkedFormList.size() == 0) {
            return;
        }
        
        List<CO_Form__c> coFormList = new List<CO_Form__c>();
        for(Linked_Form__c linkedFormRec : linkedFormList) {
            CO_Form__c coFormRec = new CO_Form__c();
            coFormRec.CO_Header__c = coHeaderId;
            if(sectionName == 'Deal') {
                coFormRec.Deal__c = sectionId;
            } else if(sectionName == 'Financing') {
                coFormRec.Deal_Finance__c = sectionId;
            } else if(sectionName == 'Service') {
                coFormRec.Service_Order_Header__c = sectionId;
            }
            if(String.isNotBlank(vendorProductId)) {
                coFormRec.Vendor_Product__c = vendorProductId;
            }
            coFormRec.Form_Name__c = linkedFormRec.Form__r.Name;
            coFormRec.Description__c = linkedFormRec.Form__r.Description__c;
            coFormRec.Form__c = linkedFormRec.Form__c;
            coFormRec.Linked_Form__c = linkedFormRec.Id;
            coFormRec.Vendor_Product__c = linkedFormRec.Vendor_Product__c;
            coFormRec.Source__c = AUTOMATICALLY_CREATED;
            coFormRec.Is_Manually_Uploaded__c = linkedFormRec.Form__r.Is_Manual_Upload__c;
            coFormRec.Is_Editable__c = linkedFormRec.Form__r.Is_Editable__c;
            coFormRec.Form_Edit_Config__c = linkedFormRec.Form__r.Form_Edit_Config__c;
            coFormRec.Edit_Modal_Name__c = linkedFormRec.Form__r.Edit_Modal_Name__c;
            coFormList.add(coFormRec);
        }
        
        if(coFormList.size() > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coFormList;
            
            copyAttachmentForCOForm(coFormList);
        }
    }
    
    public static List<FormRepositoryWrapper> getActiveFormsBySectionId(String sectionId) {
    	String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
        	return new List<FormRepositoryWrapper>();
        }
    	List<Form__c> activeFormList = FormSOQLUtil.getAvailableActiveFormsBySectionId(sectionId, sectionName);
    	List<FormRepositoryWrapper> activeFormObjList = new List<FormRepositoryWrapper>();
    	for(Form__c activeFormRec: activeFormList) {
    		activeFormObjList.add(new FormRepositoryWrapper(activeFormRec));
    	}
        return activeFormObjList;
    }
    
    public static Map<Id, List<COFormWrapper>> getCOFormsBySectionId(String sectionId) {
    	String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
        	return new Map<Id, List<COFormWrapper>>();
        }
        List<Id> sectionIdList = getSectionIdListBasedonSectionName(sectionId, sectionName);
        List<CO_Form__c> coFormList = FormSOQLUtil.getCOFormsListById(sectionIdList);
        
        Set<Id> formIdSet = new Set<Id>();
        for(CO_Form__c coForm: coFormList) {
        	formIdSet.add(coForm.Form__c);
        }
        Map<Id, Form__c> formIdToRecordMap = new Map<Id, Form__c>([SELECT Is_Active__c FROM Form__c WHERE Id IN :formIdSet]);
        Map<Id, List<COFormWrapper>> sectionIdToCOFormListMap = populateSectionIdToCOFormListMap(sectionId, sectionName, coFormList, formIdToRecordMap);
       	return sectionIdToCOFormListMap;
   	}
   	
   	public static void addFormsToSection(String coHeaderId, String sectionId, String formJson) {
        String sectionName = BPUtility.getSectionNameBySectionId(sectionId);
        if(String.isBlank(sectionName)) {
        	return;
        }
   		List<COFormWrapper> coFormObjList = (List<COFormWrapper>) System.JSON.deserialize(formJson, List<COFormWrapper>.class);
   		
   		List<CO_Form__c> coFormList = new List<CO_Form__c>();
   		for(COFormWrapper coFormObj: coFormObjList) {
   			CO_Form__c coFormRec = new CO_Form__c();
            coFormRec.CO_Header__c = coHeaderId;
            if(sectionName == 'Deal') {
                coFormRec.Deal__c = sectionId;
            } else if(sectionName == 'Financing') {
                coFormRec.Deal_Finance__c = sectionId;
            } else if(sectionName == 'Service') {
                coFormRec.Service_Order_Header__c = sectionId;
            }
            coFormRec.Form_Name__c = coFormObj.FormName;
            coFormRec.Description__c = coFormObj.Description;
            coFormRec.Form__c = coFormObj.Id;
            coFormRec.Source__c = MANUAL_UPLOAD;
            coFormRec.Is_Manually_Uploaded__c = coFormObj.IsManualUpload;
            coFormRec.Is_Editable__c = coFormObj.IsEditable;
            coFormRec.Form_Edit_Config__c = coFormObj.FormEditConfig;
            coFormRec.Edit_Modal_Name__c = coFormObj.EditModalName;
            coFormList.add(coFormRec);
   		}
   		
        if(coFormList.size() > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert coFormList;
            
            copyAttachmentForCOForm(coFormList);
        }
        
   	}
   	
   	public static void deleteCOForm(String coFormId) {
    	if(AccessControl.ifObjectIsDeletable('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	CO_Form__c coFormRec = new CO_Form__c();
    	coFormRec.Id = coFormId;
    	delete coFormRec;
    }
    
    public static void deleteCOFormUsingSectionId(Set<Id> sectionIdSet) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Form__c> coFormList = [Select Id from CO_Form__c where Service_Order_Header__c IN: sectionIdSet OR Deal_Finance__c IN: sectionIdSet
                                        OR Deal__c IN: sectionIdSet];
        if(coFormList.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('CO_Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete coFormList;
        }
    }
    
    public static Map<String, Decimal> getActiveFormsCount() {
        if(AccessControl.ifObjectFieldIsAccessible('Form__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        AggregateResult[] groupedResults = [select Grouping_Name__c form, count(Id)
												from Form__c where Is_Active__c = true
												group by Grouping_Name__c];
		for(AggregateResult res : groupedResults){
			sectionNameToActiveFormsCountMap.put(String.valueOf(res.get('form')), Integer.valueOf(res.get('expr0')));
		}	
		return sectionNameToActiveFormsCountMap;
    }
   	
   	private static List<Id> getSectionIdListBasedonSectionName(String sectionId, String sectionName) {
   		List<Id> sectionIdList = new List<Id>();
   		if(sectionName == 'All') {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        	List<CO_Header__c> coHeaderList = [SELECT Id, (SELECT Id FROM Service_Order_Headers__r), (SELECT Id FROM Deals__r) FROM CO_Header__c WHERE Id =: sectionId];
        	if(coHeaderList.size() > 0) {
	        	for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
	        		sectionIdList.add(soHeaderRec.Id);
	        	}
	        	if(coHeaderList[0].Deals__r.size() > 0) {
                    sectionIdList.add(coHeaderList[0].Deals__r[0].Id); // Assuming there is only one deal per CO Header
	        		List<Deal_Finance__c> dealFinanceList = [SELECT Id FROM Deal_Finance__c WHERE Deal__c =: coHeaderList[0].Deals__r[0].Id];
	        		if(dealFinanceList.size() > 0) {
		        		sectionIdList.add(dealFinanceList[0].Id);
		        	}
	        	}
        	}
        } else {
        	sectionIdList.add(sectionId);
        }
        return sectionIdList;
   	}
   	
   	private static Map<Id, List<COFormWrapper>> populateSectionIdToCOFormListMap(String sectionId, String sectionName, List<CO_Form__c> coFormList, Map<Id, Form__c> formIdToRecordMap) {
   		Map<Id, List<COFormWrapper>> sectionIdToCOFormListMap = new Map<Id, List<COFormWrapper>>();
   		Boolean isFormActive;
   		if(sectionName != 'All') {
        	List<COFormWrapper> coFormObjList = new List<COFormWrapper>();
    		for(CO_Form__c coFormRec : coFormList) {
    			isFormActive = false;
    			if(String.isNotBlank(coFormRec.Form__c)) {
    				isFormActive = formIdToRecordMap.get(coFormRec.Form__c).Is_Active__c;
    			}
	   			coFormObjList.add(new COFormWrapper(coFormRec, isFormActive));
	   		}
	   		sectionIdToCOFormListMap.put(sectionId, coFormObjList);
    	} else {
    		for(CO_Form__c coFormRec : coFormList) {
    			isFormActive = false;
    			if(String.isNotBlank(coFormRec.Form__c)) {
    				isFormActive = formIdToRecordMap.get(coFormRec.Form__c).Is_Active__c;
    			}
    			Id recId;
	   			if(String.isNotBlank(coFormRec.Service_Order_Header__c)) {
	   				recId = coFormRec.Service_Order_Header__c;
	   			} else if(String.isNotBlank(coFormRec.Deal__c)) {
	   				recId = coFormRec.Deal__c;
	   			} else if(String.isNotBlank(coFormRec.Deal_Finance__c)) {
	   				recId = coFormRec.Deal_Finance__c;
	   			}
	   			if(!sectionIdToCOFormListMap.containsKey(recId)) {
	   				sectionIdToCOFormListMap.put(recId, new List<COFormWrapper>{});
	   			}
   				sectionIdToCOFormListMap.get(recId).add(new COFormWrapper(coFormRec, isFormActive));
	   		}
    	}
   		return sectionIdToCOFormListMap;
   	}
   	
   	private static void copyAttachmentForCOForm(List<CO_Form__c> coFormList) {
   	    Map<Id, Id> formIdToCOFormIdMap = new Map<Id, Id>();
        for(CO_Form__c coFormRec: coFormList) {
            formIdToCOFormIdMap.put(coFormRec.Form__c, coFormRec.Id);
        }
        if(formIdToCOFormIdMap.size() > 0) {
            insertAttachmentsForForms(formIdToCOFormIdMap);
        }
   	}
   	
   	private static void insertAttachmentsForForms(Map<Id, Id> formIdToCOFormIdMap) {
   		if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
   		List<Attachment> atachmentList = [SELECT Name, ContentType, Body, ParentId FROM Attachment WHERE ParentId IN :formIdToCOFormIdMap.keySet()];
   		List<Attachment> attachmentListToInsert = new List<Attachment>();
   		for(Attachment attRec : atachmentList) {
   			attachmentListToInsert.add(new Attachment(Name = attRec.Name, Body = attRec.Body, ContentType = attRec.ContentType, ParentId = formIdToCOFormIdMap.get(attRec.ParentId)));
   		}
   		if(attachmentListToInsert.size() > 0) {
   			if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
   			insert attachmentListToInsert;
   		}
   	}
    
    private static Map<String, Integer> sectionNameToActiveFormsCountMap = new Map<String, Integer>{
    																'Deal' => 0,
    																'Financing' => 0, 
    																'Service' => 0
    													};
}