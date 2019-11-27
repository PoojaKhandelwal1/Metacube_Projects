/**
 * Author: Richa Mittal
 * Since: Aug 9, 2018
 * Name: COFormWrapper
 * Description: Used to convert Attachment object's serialize and deserialize operations
**/
public with sharing class AttachmentWrapper {
	
	public String Id;
	public String AttachmentURL;
	public String Name;
	public String Description;
	public String CreatedDate;
	public String ParentId;
	
	public AttachmentWrapper(Attachment attachment) {
		this.Id = attachment.Id;
		this.AttachmentURL = AttachmentService.FILE_URL_PREFIX + Id;
		this.Name = attachment.Name;
		this.Description = attachment.Description;
		this.CreatedDate = (attachment.CreatedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(attachment.CreatedDate.year(), 
																		attachment.CreatedDate.month(), attachment.CreatedDate.day())) : '' ;
		this.parentId = attachment.ParentId;
	}
	
	public static List<String> getAttachmentFieldsList() {
	   return new List<String>{ 'Id'};
   	}
}