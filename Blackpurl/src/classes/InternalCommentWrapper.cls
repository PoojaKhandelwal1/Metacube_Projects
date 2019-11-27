/**
 * Author: Pooja Kahndelwal
 * Since: Aug 29, 2018
 * Name: InternalCommentWrapper
 * Description: Used to convert Internal Comment object's serialize and deserialize operations
**/
public with sharing class InternalCommentWrapper {
	public String Id;
	public String CoHeaderId;
	public String Comment;
	public String CreatedById;
	public String CreatedByName;
	public String CreatedDate;
	public String CreatedTime;
	public String LastModifiedDate;
	public String LastModifiedTime;
	public Boolean isEdited;
	
	public InternalCommentWrapper(Internal_Comment__c internalComment) {
		this.Id = internalComment.Id;
		this.CoHeaderId = internalComment.CO_Header__c;
		this.Comment = internalComment.Comment__c;
		this.CreatedById = internalComment.CreatedBy.Id;
		this.CreatedByName = internalComment.CreatedBy.Name; 
		this.CreatedDate = (internalComment.CreatedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(internalComment.CreatedDate.year(), 
																		internalComment.CreatedDate.month(), internalComment.CreatedDate.day())) : null;
		this.LastModifiedDate = (internalComment.LastModifiedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(internalComment.LastModifiedDate.year(), 
																		internalComment.LastModifiedDate.month(), internalComment.LastModifiedDate.day())) : null;
		this.CreatedTime = (internalComment.CreatedDate != null) ? internalComment.CreatedDate.format('h:mma') : null;	
		this.LastModifiedTime = (internalComment.LastModifiedDate != null) ? internalComment.LastModifiedDate.format('h:mma') : null;		
		this.isEdited = (internalComment.CreatedDate == internalComment.LastModifiedDate) ? false : true; 													
	}
	
	public static List<String> getInternalCommentFieldsList() {
	   return new List<String>{ 'Id',
	   							'CO_Header__c',
	   							'Comment__c',
	   							'CreatedBy.Id',
	   							'CreatedBy.Name',
	   							'CreatedDate',
	   							'LastModifiedDate'
	   						};
   	}
}