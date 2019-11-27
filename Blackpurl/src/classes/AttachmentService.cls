/** 
* Author: Richa Mittal
* Since: Aug 09, 2018 
* Name: AttachmentService 
* Description: Service class which contains all methods related to attachment.
**/
public without sharing class AttachmentService {
    
    public static String FILE_URL_PREFIX = '/servlet/servlet.FileDownload?file=';
    public static Decimal MAX_HEAP_SIZE = 5000000;
    
    public static Map<Id, List<AttachmentWrapper>> getAttachmentListByParentId(String parentId) {
    	String objectName = (Id.valueOf(parentId)).getSObjectType().getDescribe().getName();
        if(!objectNameToSectionNameMap.containsKey(objectName)) {
            return new Map<Id, List<AttachmentWrapper>>();
        }
        String sectionName = objectNameToSectionNameMap.get(objectName);
        List<Id> sectionIdList = getSectionIdListBasedonSectionName(parentId, sectionName);
        List<Attachment> attachmentList = [SELECT Name, Description, CreatedDate, ParentId FROM Attachment WHERE ParentId IN :sectionIdList ORDER BY CreatedDate ASC];
        Map<Id, List<AttachmentWrapper>> parentIdToAttachmentListMap = populateSectionIdToAttachmentListMap(parentId, sectionName, attachmentList);
       	return parentIdToAttachmentListMap;
   	}
   	
   	public static void deleteAttachment(String attachmentId) {
        if(AccessControl.ifObjectIsDeletable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	delete new Attachment(Id = attachmentId);
   	}
   	
   	public static void uploadAttachment(String attachmentJson, String attachmentBody) {
   		AttachmentWrapper attachmentObj = (AttachmentWrapper) System.JSON.deserialize(attachmentJson, AttachmentWrapper.class);
        String base64 = attachmentBody.substring(attachmentBody.indexOf(',') + 1);
        Blob actualdata = EncodingUtil.base64Decode(base64);
        Attachment attachmentRec = new Attachment(ParentId = attachmentObj.ParentId, Body = actualdata);
        attachmentRec.Name = attachmentObj.Name;
        attachmentRec.Description = attachmentObj.Description;
        if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert(attachmentRec);
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
   	
   	private static Map<Id, List<AttachmentWrapper>> populateSectionIdToAttachmentListMap(String sectionId, String sectionName, List<Attachment> attachmentList) {
   		Map<Id, List<AttachmentWrapper>> sectionIdToAttachmentListMap = new Map<Id, List<AttachmentWrapper>>();
   		if(sectionName != 'All') {
        	List<AttachmentWrapper> attachmentObjList = new List<AttachmentWrapper>();
    		for(Attachment attachmentRec : attachmentList) {
	   			attachmentObjList.add(new AttachmentWrapper(attachmentRec));
	   		}
	   		sectionIdToAttachmentListMap.put(sectionId, attachmentObjList);
    	} else {
    		for(Attachment attachmentRec : attachmentList) {
	   			if(!sectionIdToAttachmentListMap.containsKey(attachmentRec.ParentId)) {
	   				sectionIdToAttachmentListMap.put(attachmentRec.ParentId, new List<AttachmentWrapper>{});
	   			}
   				sectionIdToAttachmentListMap.get(attachmentRec.ParentId).add(new AttachmentWrapper(attachmentRec));
	   		}
    	}
   		return sectionIdToAttachmentListMap;
   	}
   	
   	private static Map<String, String> objectNameToSectionNameMap = new Map<String, String>{
        Constants.NAMESPACE + 'Service_Order_Header__c' => 'Service',
        Constants.NAMESPACE + 'Deal__c' => 'Deal',
        Constants.NAMESPACE + 'Deal_Finance__c' => 'Financing',
        Constants.NAMESPACE + 'Product__c' => 'Vendor product',
        Constants.NAMESPACE + 'CO_Header__c' => 'All'
    };
    
    public static String getAttachmentBodyByParentIdAndName(String parentId, String fileName) {
        try {
            List<Attachment> attachmentList = [SELECT Body FROM Attachment WHERE Name = :fileName AND ParentID = :parentId ORDER BY CreatedDate ASC];
            String attachmentBody = null;
            if(!attachmentList.isEmpty()) {
                attachmentBody = BPUtility.getEncodedStr(attachmentList[0].body);
            }
            return attachmentBody;
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}