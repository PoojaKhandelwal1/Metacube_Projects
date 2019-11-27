public with sharing class SendEmail {
    
    private static String FALLBACK_SENDER = 'BlackPurl';
    private static String businessName;
    
    public static void send(List<String> emailStrList, String subject, String htmlBody, String soHeaderId) {
        if(emailStrList.size() == 0) {
            return;
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail = setDefaultFields(mail);
        
        List<String> sendTo = emailStrList;
        mail.setToAddresses(sendTo);
        List<Messaging.EmailFileAttachment> emailAttachmentList = new List<Messaging.EmailFileAttachment>();
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName('Service Order Preview.pdf');
        
        PageReference soInfoPreviewPDFPage = Page.SOInfoPrintPreviewPDF;
        soInfoPreviewPDFPage.getparameters().put('id', soHeaderId);
        Blob pageContent;
        if(!Test.isRunningTest()) {
            pageContent = soInfoPreviewPDFPage.getContentAsPdf();
        } else {
            pageContent = Blob.valueof('Test String');
        }
        emailAttachmentList.add(emailAttachment);
        emailAttachment.setBody(pageContent);
        mail.setFileAttachments(emailAttachmentList);
        
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    
    public static String sendInvoice(List<String> emailStrList, String subject, String htmlBody, String recId, string isFinalized){
        if(emailStrList.size() == 0) {
            return 'email list empty';
        }
        try {
	        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
	        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail = setDefaultFields(mail);
	        mail.setToAddresses(emailStrList);
	        
	        List<Messaging.EmailFileAttachment> emailAttachmentList = new List<Messaging.EmailFileAttachment>();
	        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
	        Blob pageContent;
	        
	        PageReference pageName;
	        String objectName = String.valueOf(Id.valueOf(recId).getSobjectType());
            if(objectName == Constants.Namespace + 'CustomerApproval__c') {
            	emailAttachment.setFileName('Customer Approval.pdf');
		        pageName = Page.ServiceWorkSheetPDF;
		        pageName.getparameters().put('customerApprovalId', recId);
            } else {
		        emailAttachment.setFileName('Customer Order Invoice.pdf');
		        pageName = Page.EmailCustomerOrderInvoice;
		        pageName.getparameters().put('id', recId);
		        pageName.getparameters().put('isFinalized', isFinalized);
            }
            pageName.setRedirect(true);
	        
	        if(!Test.isRunningTest()) {
	            pageContent = pageName.getContent();
	        } else {
	            pageContent = Blob.valueof('Test String');
	        }
	        emailAttachment.setBody(pageContent);
	        emailAttachmentList.add(emailAttachment);
	        mail.setFileAttachments(emailAttachmentList);
	        mail.setSubject(subject);
	        mail.setHtmlBody(htmlBody);
	        mails.add(mail);
	        Messaging.sendEmail(mails);
            return 'success';
        } catch(exception e){
            return e.getMessage();
        }
    }
    
    public static String sendSelectedDocument(List<DocumentWrapper> docWrapperList, List<String> emailStrList) {
       try {
            return sendSelectedDocument(docWrapperList, emailStrList, null);
        } catch(Exception e) {
            return e.getMessage();
        }
    } 
    
    public static String sendSelectedDocument(List<DocumentWrapper> docWrapperList, List<String> emailStrList, String subject) {
       try {
            List<Messaging.EmailFileAttachment> emailAttachmentList = createAttachmentList(docWrapperList);
       		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail = setDefaultFields(mail);
	        mail.setToAddresses(emailStrList);
	        //mail.setCcAddresses(new List<String>{'tarun.khandelwal@metacube.com'});
            mail.setFileAttachments(emailAttachmentList);
            if(String.isNotBlank(subject)) {
            	mail.setSubject(subject);
            } else {
            	mail.setSubject('Document from '+ businessName);
            }
	        mail.setHtmlBody('');
	        
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            return 'success';
        } catch(Exception e) {
            return e.getMessage();
        }
    }
    
    private static List<Messaging.EmailFileAttachment> createAttachmentList(List<DocumentWrapper> docWrapperList) {
        List<Messaging.EmailFileAttachment> emailAttachmentList = new List<Messaging.EmailFileAttachment>();
        List<String> attachmentIdList = new List<String>();
        for(DocumentWrapper docWrapperObj : docWrapperList) {
            if(docWrapperObj.DocumentName == 'Packing Slip') {
                emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.PrintMerchandise, docWrapperObj.COHeaderId));
            
            } else if(docWrapperObj.DocumentName == 'Service Worksheet') {
                emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.ServiceWorkSheetPDF, docWrapperObj.COHeaderId));
                
            } else if(docWrapperObj.DocumentName == 'Deposit Receipt' || docWrapperObj.DocumentName == 'Print deposit receipt') {
                emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.CODepositsPdf, docWrapperObj.COHeaderId));
            
            } else if(docWrapperObj.DocumentName == 'Offer to purchase' || docWrapperObj.DocumentName == 'Bill of sale') {
                emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.DealDocumentPdf, docWrapperObj.DealId));
            
            } else if(docWrapperObj.DocumentName == 'Invoice preview') {
                emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.EmailCustomerOrderInvoice, docWrapperObj.COInvoiceId));
            } else if(docWrapperObj.DocumentName == 'VendorOrderPDF') {
            	emailAttachmentList.add(generateAttachment(docWrapperObj.DocumentName, Page.PrintVendorOrder, docWrapperObj.VendorOrderId ));
            } else if(docWrapperObj.DocumentName == 'AttachmentFile') {
            	attachmentIdList.add(docWrapperObj.AttachmentId);
            }
        }
        if(attachmentIdList.size() > 0) {
        	List<Messaging.EmailFileAttachment> emailAttachmentsFromAttachment = getEmailAttachmentFromAttachmentObject(attachmentIdList);
        	if(emailAttachmentsFromAttachment.size() > 0) {
        		emailAttachmentList.addAll(emailAttachmentsFromAttachment);
        	}
        }
        return emailAttachmentList;
    }
    
    private static List<Messaging.EmailFileAttachment> getEmailAttachmentFromAttachmentObject(List<String> attachmentIdList) {
    	List<Messaging.EmailFileAttachment> emailAttachmentList = new List<Messaging.EmailFileAttachment>();
    	if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		List<Attachment> attachmentToEmailList = [SELECT Name,Body FROM Attachment WHERE Id IN :attachmentIdList];
		for(Integer i=0; i < attachmentToEmailList.size(); i++) {
			Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
			emailAttachment.setFileName(attachmentToEmailList[i].Name);
			emailAttachment.setBody(attachmentToEmailList[i].Body);
    		emailAttachmentList.add(emailAttachment);
		}
		return emailAttachmentList;
    }
    
    private static Messaging.EmailFileAttachment generateAttachment(String fileName, PageReference pageToEmail, String recordId) {
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName(fileName + '.pdf');
        
        pageToEmail.getparameters().put('id', recordId);
        if(fileName == 'Invoice preview') {
            pageToEmail.getparameters().put('isFinalized', 'false');
        }  else if(fileName == 'Offer to purchase' || fileName == 'Bill of sale') {
            pageToEmail.getparameters().put('documentType', fileName);
        }
        Blob pageContent;
        if(!Test.isRunningTest()) {
            pageContent = pageToEmail.getContent();
        } else {
            pageContent = Blob.valueof('Test String');
        }
        emailAttachment.setBody(pageContent);
        return emailAttachment;
    }
    
    public class DocumentWrapper {
        public String DocumentName;
        public String COHeaderId;
        public String COInvoiceId;
        public String DealId;
        public String VendorOrderId;
        public String AttachmentId;
        public DocumentWrapper() {
            
        }
    }
    
    public static void sendSupportMail(List<String> emailStrList, String subject, String htmlBody) {
        if(emailStrList.size() == 0) {
            return;
        }  
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail = setDefaultFields(mail);
        List<String> sendTo = emailStrList;
        mail.setToAddresses(sendTo);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mails.add(mail);
        Messaging.sendEmail(mails);
    }
    
    
    private static Messaging.SingleEmailMessage setDefaultFields(Messaging.SingleEmailMessage mail) {
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        String sentFromEmailString;
        if(businessProfiles.size() > 0) {
            businessName = String.isNotBlank(businessProfiles[0].Business_Name__c) ? businessProfiles[0].Business_Name__c : FALLBACK_SENDER;
            sentFromEmailString = businessProfiles[0].Business_Email__c;
        } else {
            sentFromEmailString = Configurations__c.getInstance().Sent_From_Email_Id__c;
        }
        
        mail.setReplyTo(sentFromEmailString);
        mail.setSenderDisplayName(businessName);
        return mail;
    }
    /*private static Messaging.SingleEmailMessage setDefaultFields(Messaging.SingleEmailMessage mail) {
        List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
        String sentFromEmailString;
        if(businessProfiles.size() > 0) {
            businessName = String.isNotBlank(businessProfiles[0].Business_Name__c) ? businessProfiles[0].Business_Name__c : FALLBACK_SENDER;
            sentFromEmailString = businessProfiles[0].Business_Email__c;
        } else {
            sentFromEmailString = Configurations__c.getInstance().Sent_From_Email_Id__c;
        }
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
		if (owea.size() > 0) {
		    mail.setOrgWideEmailAddressId(owea.get(0).Id);
		} else {
			mail.setSenderDisplayName(businessName);
		}
        
        mail.setReplyTo(sentFromEmailString);
        return mail;
    }*/
}