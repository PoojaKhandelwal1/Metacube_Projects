/**
 * Author: Rajat Jain
 * Since: May 22, 2018
 * Name: LogTriggerHelper 
 * Description: Helper Class to execute operation on log 
**/
public without sharing class LogTriggerHelper {
	
	public static void afterInsert(List<Log__c> newList) {
		Boolean isErrorLogExist = false;
		for(Log__c logRec : newList) {
			if(logRec.Type__c == 'Error') {
				isErrorLogExist = true;
				break;
			}
		}
		
		if(isErrorLogExist) {
			checkForFirstErrorOfDay();
		}
	} 
	
	private static void checkForFirstErrorOfDay() {
		if(AccessControl.ifObjectFieldIsAccessible('Log__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		List<Log__c> logRecordList = [SELECT Id, Name, Apex_Class__c, Integration_Type__c, CreatedDate FROM Log__c WHERE CreatedDate = TODAY AND Type__c='Error' LIMIT 2 ];
		if(logRecordList.size() == 1 && logRecordList[0].Integration_Type__c == 'QB') {
			notifySupportTeam(logRecordList[0]);
		}
	}
	
	private static void notifySupportTeam(Log__c logRecord) {
		String classNameInUpperCase = (classNameToEntityNameMap.get(logRecord.Apex_Class__c) != null) ? 
										(classNameToEntityNameMap.get(logRecord.Apex_Class__c)).toUpperCase() : '';
		String subject = UserInfo.getOrganizationName() + '-  Encountered a problem while syncing ' + classNameInUpperCase + ' to QuickBooks';
		String htmlBody = getEmailTemplateBody(logRecord) ;
		String defaultEmail = GeneralConfiguration.getSupportEmailRecipient();
		List<String> emailStrList = new List<String>();
		if(String.isNotBlank(defaultEmail)) {
			emailStrList = defaultEmail.split(';');
		} else {
			String supportMail = GeneralConfiguration.getSupportEmail();
			emailStrList = new List<String>{supportMail};
		}
		if(!Test.isRunningTest()){
			SendEmail.sendSupportMail(emailStrList, subject, htmlBody);
		}
		
	}
	
	public static String getEmailTemplateBody(Log__c logRecord) {
		String htmlBody = '';
		string Url = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+logRecord.Id;
		htmlBody += '<span> Hi Support Team, </span>';
		if(logRecord.Apex_Class__c == 'AccountingIntegrationSettingsCtrl'){
			htmlBody += '<p><span>An error occured while connecting to QB. </span>';
		} else {
			String classNameInUpperCase = (classNameToEntityNameMap.get(logRecord.Apex_Class__c) != null) ? 
										(classNameToEntityNameMap.get(logRecord.Apex_Class__c)).toUpperCase() : '';
			htmlBody += '<p><span>An error occured while syncing ' + classNameInUpperCase +  ' to QB. </span>';
		}
		htmlBody += '<span>Please check logs for more detail </span> </p>';
		htmlBody += '<p style="font-weight: bold;"> Information :</p>';
    	htmlBody += '<table style="width:400px ;border-collapse: collapse;" >';
		htmlBody +=	  '<tr >';
		htmlBody +=	    '<td style="border : 1px solid ">Company Name </td>';
		htmlBody +=	    '<td style="border : 1px solid ">' + UserInfo.getOrganizationName() + '</td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	  '<tr >';
		htmlBody +=	    '<td style="border : 1px solid ">Org Id </td>';
		htmlBody +=	    '<td style="border : 1px solid ">' + UserInfo.getOrganizationId() + '</td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	  '<tr >';
		htmlBody +=	    '<td style="border : 1px solid ">Log Number </td>';
		htmlBody +=	    '<td style="border : 1px solid "> <a href=" '+ Url + '">' + logRecord.Name +'</a> </td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	  '<tr style="border : 1px solid ">';
		htmlBody +=	    '<td style="border : 1px solid ">Entity </td>';
		htmlBody +=	    '<td style="border : 1px solid ">' + classNameToEntityNameMap.get(logRecord.Apex_Class__c) + '</td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	 '</table>';
    	htmlBody += '<p style="margin-top: 20px;margin-bottom:5px;">From</p>';
    	htmlBody += '<p style="margin:0px;">Blackpurl Admin</p>';
		return htmlBody;
	}
	
	private static Map<String,String> classNameToEntityNameMap = new Map<String,String> {'CustomerService' => 'Customer',
																	 'VendorService' => 'Vendor',
																	 'ItemCategoryService' => 'Category',
																	 'CustomerInvoiceService' => 'Customer Order Invoice',
																	 'COInvoiceJournalEntryService' => 'Customer Order Invoice',
																	 'FIFOBucketService' => 'Part',
																	 'StoreCreditJournalEntryService' => 'Store Credit', 
																	 'UnitService' => 'Unit', 
																	 'UnitPriceAndCostService' => 'Unit Price Adjustment', 
																	 'CODepositJournalEntryService' => 'Customer Order Deposit', 
																	 'VendorInvoiceService' => 'Vendor Invoice', 
																	 'VendorReturnService' => 'Vendor Return', 
																	 'VORJournalEntryService' => 'Vendor Recieve',
																	 'FIFOBucketActivityLineItemService' => 'Part Adjustment',
																	 'COInvoicePaymentJournalEntryService' => 'Payment',
																	 'COInvoicePaymentService' => 'Payment',
																	 'PartCategoryService'	=>	'Part Category Change',
                                                                     'UnitCategoryService'  =>  'Stock Unit Category Change'
	};
}