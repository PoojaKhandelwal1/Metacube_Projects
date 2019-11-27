/**
 * Author: Pooja Kahndelwal
 * Since: Aug 29, 2018
 * Name: InternalCommentService
 * Description: Service Class used to perform CRUD operations on Internal Comment Object
**/
public without sharing class InternalCommentService {
    
   	public static void saveInternalComment(InternalCommentWrapper internalCommentObj) {
        Internal_Comment__c internalCommentRec = new Internal_Comment__c();
        internalCommentRec.CO_Header__c = internalCommentObj.CoHeaderId;
        internalCommentRec.Comment__c = internalCommentObj.Comment;
        internalCommentRec.Id = internalCommentObj.Id;
        
        if(String.isBlank(internalCommentRec.Id)) { 
            if(AccessControl.ifObjectFieldIsCreateable('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        } else {
            if(AccessControl.ifObjectFieldIsUpdateable('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        }
        upsert internalCommentRec;
   	}
   	
   	public static void saveInternalCommentOnCO(String internalCommentJSON) {
   		InternalCommentWrapper internalCommentObj = (InternalCommentWrapper) System.JSON.deserialize(internalCommentJSON, InternalCommentWrapper.class);
   		saveInternalComment(internalCommentObj);
   		if(!String.isBlank(internalCommentObj.CoHeaderId)) {
        	saveLastNoteOnCO(internalCommentObj.CoHeaderId);
        }
   	}
   	
   	private static void saveLastNoteOnCO(String coHeaderId) {
    	if(AccessControl.ifObjectFieldIsAccessible('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Internal_Comment__c> internalCommentList = [SELECT CreatedDate, Comment__c, CO_Header__r.Last_Comment__c FROM Internal_Comment__c WHERE CO_Header__c =: coHeaderId ORDER by CreatedDate DESC LIMIT 1];
    	String lastNote = '';
    	if(internalCommentList.size() == 0) {
    		lastNote = '';
    	} else {
    		String createdDate = (internalCommentList[0].CreatedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(internalCommentList[0].CreatedDate.year(), 
																		internalCommentList[0].CreatedDate.month(), internalCommentList[0].CreatedDate.day())) : null;
    		lastNote = (createdDate != null) ? (createdDate + (!String.isBlank(internalCommentList[0].Comment__c) ? ('-' + internalCommentList[0].Comment__c) : '')) : (!String.isBlank(internalCommentList[0].Comment__c) ? internalCommentList[0].Comment__c : '');
    		lastNote = (lastNote.length() > 255) ? lastNote.substring(0, 254) : lastNote;
    	}
    	if(internalCommentList.size() != 0 && internalCommentList[0].CO_Header__r.Last_Comment__c == lastNote){
    		return;
    	}
    	CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, Last_Comment__c = lastNote);
    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    update coHeaderRec;
    }
     
   	public static List<InternalCommentWrapper> getInternalCommentListByCOId(String coHeaderId) {
   		String query;   
        query = 'SELECT '; 
        for(String fieldsName : InternalCommentWrapper.getInternalCommentFieldsList()){
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'Internal_Comment__c';
        query += ' WHERE CO_Header__c =: coHeaderId';
        query += ' ORDER by CreatedDate DESC';
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        if(AccessControl.ifObjectFieldIsAccessible('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Internal_Comment__c> internalCommentList  = Database.query(query);
        List<InternalCommentWrapper> internalCommentRecList = new List<InternalCommentWrapper>();
        for(Internal_Comment__c internalCommentRec: internalCommentList) {
        	internalCommentRecList.add(new InternalCommentWrapper(internalCommentRec));
        }
        return internalCommentRecList;
   	}
   	
   	public static void deleteInternalComment(String internalCommentId) { 
   		if(AccessControl.ifObjectIsDeletable('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    	delete new Internal_Comment__c(Id = internalCommentId);
   	}
   	
   	public static void deleteInternalCommentFromCO(String internalCommentId) {
   		if(AccessControl.ifObjectFieldIsAccessible('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
   		List<Internal_Comment__c> internalCommentList = [SELECT CO_Header__c FROM Internal_Comment__c WHERE Id =: internalCommentId];
   		String coHeaderId = internalCommentList[0].CO_Header__c;
   		deleteInternalComment(internalCommentId);
   		if(!String.isBlank(coHeaderId)) {
        	saveLastNoteOnCO(coHeaderId);
        }
   	}
   	
   	public static void deleteInternalCommentsFromCO(String coHeaderId) {
   		if(AccessControl.ifObjectFieldIsAccessible('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
   		List<Internal_Comment__c> internalCommentList = [SELECT Id FROM Internal_Comment__c WHERE CO_Header__c =: coHeaderId];
   		if(AccessControl.ifObjectIsDeletable('Internal_Comment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
   		delete internalCommentList;
   	}
}