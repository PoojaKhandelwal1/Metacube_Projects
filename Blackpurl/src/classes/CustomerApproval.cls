public with sharing class CustomerApproval {
	
 	public String ApprovalId;
	public String SectionName;
	public String SectionKey;
	public String ServiceOrderHeader;
	public String ApprovalType{get; private set;}
	public String ApprovalDetailJson ;
	public String Notes ;
	public string Status;
	public String ApprovalDate;
	public String ApprovalDateTime;
	public String Id;
	public Boolean IsApprovalObtained;
	public Decimal ApprovalCount;
	public String signatureBlobValue{get; private set;}
	
	public CustomerApproval(CustomerApproval__c customerApproval){
	 	this.Id =customerApproval.Id;
		this.ApprovalId	=	customerApproval.Name;
		this.ApprovalType = customerApproval.ApprovalType__c;
		this.ApprovalDetailJson =customerApproval.ApprovalDetailJson__c;
		this.SectionName = customerApproval.Section_Name__c;
		this.SectionKey = customerApproval.Section_key__c;
		this.ServiceOrderHeader =  (customerApproval.Service_Order_Header__c !=null) ? customerApproval.Service_Order_Header__c:null;
		this.Status = customerApproval.Status__c;
		this.Notes = customerApproval.Notes__c;
		this.ApprovalDate = BPUtility.getExtendedDateFormat(customerApproval.LastModifiedDate);
		String TimeStr = this.ApprovalDate.substring(this.ApprovalDate.length()-8, this.ApprovalDate.length());
		this.ApprovalDate = this.approvalDate.substring(0, this.ApprovalDate.length()-8) + ' - ' + TimeStr;
		
		if(customerApproval.Status__c != null && customerApproval.Status__c == 'Approved') {
			this.IsApprovalObtained = true;
		} else {
			this.IsApprovalObtained = false;
		}
		this.ApprovalCount = customerApproval.Approval_Count__c;
		this.signatureBlobValue = (customerApproval.Attachments.size() > 0 ? '/servlet/servlet.FileDownload?file=' + customerApproval.Attachments[0].Id : null);
	}
}