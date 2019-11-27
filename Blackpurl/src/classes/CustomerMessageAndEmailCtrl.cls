/**
 * Name: CustomerMessageAndEmailCtrl 
 * Description: 
 * 
**/
global with sharing class CustomerMessageAndEmailCtrl {
    global CustomerMessageAndEmailCtrl (NewHomePageCtrl controller){}
    public CustomerMessageAndEmailCtrl() {}
    
    @RemoteAction
    global static String emailCustomerApproval(String customerApprovalRecId, String emailAddress){
        customerApprovalRecId = BPUtility.getDecodedString(customerApprovalRecId );
        emailAddress = BPUtility.getDecodedString(emailAddress);
        List<String> emailList = new List<String>{emailAddress}; 
        String subject = 'Customer Approval Record';
        String htmlBody =''; 
        String response = SendEmail.sendInvoice(emailList, subject, htmlBody, customerApprovalRecId, null);
        return response;
    }
    
    @RemoteAction
    global static String updateEmail(String jSONString) {
    	jSONString = BPUtility.getDecodedString(jSONString);
    	AccountWrapper accObj = (AccountWrapper) System.JSON.deserialize(jSONString, AccountWrapper.class);
    	try {
    		Account accRec = new Account(Id = accObj.Id);
    		if(accObj.Type == 'Individual' && String.isNotBlank(accObj.PrimaryEmail)) {
    			accRec.Email__c	= accObj.PrimaryEmail;
    		} else if(accObj.Type == 'Business' && String.isNotBlank(accObj.PrimaryEmail)) {
    			accRec.Work_Email__c = accObj.PrimaryEmail;
    		} else if(String.isNotBlank(accObj.AlternateEmail)) {
    			accRec.Other_Email__c = accObj.AlternateEmail;
    		}
    		update accRec;
    	} catch (Exception e) {
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	
    	return 'Success';
    }
    
    public class AccountWrapper {
    	 public String Id;
    	 public String Type;
    	 public String PrimaryEmail;
    	 public String AlternateEmail;
    }
}