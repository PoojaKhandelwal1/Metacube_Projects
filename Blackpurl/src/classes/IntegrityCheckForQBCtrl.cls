/**
 * Author: Rajat Jain
 * Since: May 30, 2018
 * Name: IntegrityCheckForQBCtrl
 * Description: Ctrl class for IntegrityCheckForQBCtrl
**/
public with sharing class IntegrityCheckForQBCtrl {
    
    private List<String> listOfEntities = new List<String>();   
	public void sendIntegrityCheckMailToSupportTeam() {
		populateEntityNameToAsyncRecordListMap();
		checkBeforeNotification(entityNameToAsyncRecordListMap);
	}
	
   	private void populateEntityNameToAsyncRecordListMap() {
   		String query;    
		for(String entity : objectAPINameToObjectLabelMap.keySet()) {
	        if(enitiesWithQBJournalEntryFlagSet.contains(entity)) {
				query = 'SELECT Name from ' + entity + ' where availForQBJournalEntrySync__c = true ORDER By Name';
		    } else if(entity == 'Account'){
		    	query = 'SELECT Name, Is_Customer__c, Is_Vendor__c, availForQBSync__c, Vendor_AvailForQBSync__c, Claims_for_Service_Work__c  from ' + entity + ' where availForQBSync__c = true OR Vendor_AvailForQBSync__c = true ORDER By Name';
	        } else if(entity == 'CO_Invoice_Header__c') {
		    	query = 'SELECT Name, availForQBSync__c, availForQBJournalEntrySync__c, availForQBCOInvoicePayment__c from ' + entity + ' where availForQBSync__c = true OR availForQBJournalEntrySync__c = true OR availForQBCOInvoicePayment__c = true ORDER By Name';
	        } else {
				query = 'SELECT Name from ' + entity + ' where availForQBSync__c = true ORDER By Name';
	        }
		    List<SObject> sObjectRecList = Database.query(query);
		    setEntityNameToAsyncRecordListMap(entity, sObjectRecList);
    	}
   	}
   	
   	public void setEntityNameToAsyncRecordListMap(String entity, List<SObject> sObjectRecList) {
   		if(entity == 'Account') {
   			List<EntityInfoWrapper> notSyncCustomerNameList = new List<EntityInfoWrapper>();
   			List<EntityInfoWrapper> notSyncVendorNameList = new List<EntityInfoWrapper>();
    		for(SObject sObjRec : sObjectRecList) {
	    		if(Boolean.valueOf(sobjRec.get('Is_Customer__c')) && Boolean.valueOf(sobjRec.get('availForQBSync__c'))){
	    			notSyncCustomerNameList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Customer'));
	    		} else if(Boolean.valueOf(sobjRec.get('Is_Vendor__c')) && Boolean.valueOf(sobjRec.get('Claims_for_Service_Work__c')) && Boolean.valueOf(sobjRec.get('availForQBSync__c'))){
	    			notSyncCustomerNameList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Customer'));
	    		}
	    		if(Boolean.valueOf(sobjRec.get('Is_Vendor__c')) && Boolean.valueOf(sobjRec.get('Vendor_AvailForQBSync__c'))){
	    			notSyncVendorNameList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Vendor'));
	    		}
    		}
    		entityNameToAsyncRecordListMap.put('Customer', notSyncCustomerNameList);
    		listOfEntities.add('Customer');
    		entityNameToAsyncRecordListMap.put('Vendor', notSyncVendorNameList);
    		listOfEntities.add('Vendor');
	    } else if(entity == 'CO_Invoice_Header__c') {
   			List<EntityInfoWrapper> notSyncCOInvoiceList = new List<EntityInfoWrapper>();
   			List<EntityInfoWrapper> notSyncCOInvoiceJEList = new List<EntityInfoWrapper>();
   			List<EntityInfoWrapper> notSyncCOInvoicePayemntJEList = new List<EntityInfoWrapper>();
    		for(SObject sObjRec : sObjectRecList) {
	    		if(Boolean.valueOf(sobjRec.get('availForQBSync__c'))){
	    			notSyncCOInvoiceList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Customer Order Invoice'));
	    		} 
	    		if(Boolean.valueOf(sobjRec.get('availForQBJournalEntrySync__c')) ){
	    			notSyncCOInvoiceJEList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Customer Order Invoice JE'));
	    		}
	    		if(Boolean.valueOf(sobjRec.get('availForQBCOInvoicePayment__c')) ){
	    			notSyncCOInvoicePayemntJEList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),'Customer Order Invoice Payment JE'));
	    		}
    		}
    		entityNameToAsyncRecordListMap.put('Customer Order Invoice', notSyncCOInvoiceList);
    		listOfEntities.add('Customer Order Invoice');
    		entityNameToAsyncRecordListMap.put('Customer Order Invoice JE', notSyncCOInvoiceJEList);
    		listOfEntities.add('Customer Order Invoice JE');
    		entityNameToAsyncRecordListMap.put('Customer Order Invoice Payment JE', notSyncCOInvoicePayemntJEList);
    		listOfEntities.add('Customer Order Invoice Payment JE');
	    } else {
	    	List<EntityInfoWrapper> notSyncEntityNameList = new List<EntityInfoWrapper>();
	    	for(SObject sObjRec : sObjectRecList) {
	    		notSyncEntityNameList.add(new EntityInfoWrapper(String.valueOf(sobjRec.get('Id')),String.valueOf(sobjRec.get('Name')),objectAPINameToObjectLabelMap.get(entity)));
	    	}
	    	entityNameToAsyncRecordListMap.put(objectAPINameToObjectLabelMap.get(entity), notSyncEntityNameList);
	    	listOfEntities.add(objectAPINameToObjectLabelMap.get(entity));
	    }
   	}
   	
   	private void checkBeforeNotification(Map<String, List<EntityInfoWrapper>> entityNameToAsyncRecordListMap) {
   	    Boolean needToNofifySupportTeam = false;
   	    for(String entityName : entityNameToAsyncRecordListMap.keySet()) {
   	        if(entityNameToAsyncRecordListMap.get(entityName).size() > 0) {
   	            needToNofifySupportTeam = true;
   	            break;
   	        }
   	    }
   	    if(needToNofifySupportTeam) {
   	        notifyTheSupportAdmin(entityNameToAsyncRecordListMap);
   	    }
   	}
   	
   	private void notifyTheSupportAdmin(Map<String, List<EntityInfoWrapper>> entityNameToAsyncRecordListMap) {
   		String subject = UserInfo.getOrganizationName() +' - QB Integrity script result';
		String htmlBody = getEmailTemplateBody(entityNameToAsyncRecordListMap) ;
    	String defaultEmail = GeneralConfiguration.getSupportEmailRecipient();
		List<String> emailStrList = new List<String>();
		if(String.isNotBlank(defaultEmail)) {
			emailStrList = defaultEmail.split(';');
		} else {
			emailStrList.add(GeneralConfiguration.getSupportEmail());
		}
		sendMail(emailStrList, subject, htmlBody);
   	}
   	
   	private void sendMail(List<String> emailStrList, String subject, String htmlBody) {
   		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
   		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   		
        Messaging.EmailFileAttachment emailAttachment = getAttachment();
        mail.setToAddresses(emailStrList);
        if(String.isNotBlank(Configurations__c.getOrgDefaults().Sent_From_Email_Id__c)){
        	 mail.setReplyTo(Configurations__c.getOrgDefaults().Sent_From_Email_Id__c);
        }
        mail.setSenderDisplayName('BlackPurl Team');
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {emailAttachment});
        mails.add(mail);
        if(!Test.isRunningTest()){
        	Messaging.sendEmail(mails);
        }
   	}
   	
   	private Messaging.EmailFileAttachment getAttachment() {
   		Blob pageContent = Blob.valueOf(getDataForCSVFile());
        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
        emailAttachment.setFileName('attachment.csv');
        emailAttachment.setBody(pageContent);
        return emailAttachment;
   	}
   	
   	private String getDataForCSVFile() {
   		listOfEntities.sort();
    	String Url = System.URL.getSalesforceBaseUrl().toExternalForm()+'/' ;
    	String header = 'Entity type,Entity Name,Entity record URL \n';
    	String dataForCSVFile = header;
		for(String entity : listOfEntities) {
			string recordString =  '';
			for(EntityInfoWrapper entityObj : entityNameToAsyncRecordListMap.get(entity)) {
				recordString += entityObj.EntityType + ',' + entityObj.Name + ', ' + Url + entityObj.EntityId + '\n' ;
			}
			dataForCSVFile = dataForCSVFile + recordString;
		}
		return dataForCSVFile;
    }
    
   	public String getEmailTemplateBody(Map<String, List<EntityInfoWrapper>> entityNameToAsyncRecordListMap){
   		listOfEntities.sort();
   		String htmlBody = '';
		htmlBody += '<span> Hi Support Team, </span>';
		htmlBody += '<p>Following records are not synced with QB. Org Details are as follows - </p>';
		htmlBody += '<table >';
		htmlBody +=	  '<tr >';
		htmlBody +=	    '<td >Company Name - </td>';
		htmlBody +=	    '<td >' + UserInfo.getOrganizationName() + '</td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	  '<tr >';
		htmlBody +=	    '<td>Org Id - </td>';
		htmlBody +=	    '<td>' + UserInfo.getOrganizationId() + '</td>';
		htmlBody +=	  '</tr>';
		htmlBody +=	 '</table>';
		htmlBody += '<p style="font-weight: bold;"> Information :</p>';
    	htmlBody += '<table style="width:400px ;border-collapse: collapse;" >';
    	htmlBody += '<tr>';
    	htmlBody +=	    '<td style="border : 1px solid;font-weight: bold;"> Entity name </td>';
		htmlBody +=	    '<td style="border : 1px solid;font-weight: bold;">Number of async records ';
		htmlBody += '</tr>';	
    	for(String entity : listOfEntities) {
    	    if(entityNameToAsyncRecordListMap.get(entity).size() > 0) {
    	        htmlBody +=      '<tr >';
	            htmlBody +=     '<td style="border : 1px solid;">'+ entity + '</td>';
	            htmlBody +=     '<td style="border : 1px solid; ">';
	            htmlBody +=     (entityNameToAsyncRecordListMap.get(entity)).size() ;
	            htmlBody +=     '</td>';
	            htmlBody +=   '</tr>';
    	    }
    	}
    	htmlBody +=	 '</table>';
    	htmlBody += '<p style="margin-top: 20px;margin-bottom:5px;">From</p>';
    	htmlBody += '<p style="margin:0px;">Blackpurl Admin</p>';
		return htmlBody;
   	}
   	
   	private Set<String> enitiesWithQBJournalEntryFlagSet = new Set<String>{'CO_Deposit__c','CO_Invoice_Payment__c','Vendor_Receiving_Header__c'};
	
	private Map<String, List<EntityInfoWrapper>> entityNameToAsyncRecordListMap = new Map<String, List<EntityInfoWrapper>>();
	
	private Map<String, String> objectAPINameToObjectLabelMap = new Map<String,String>{'Account' => 'Customer',
												'Category__c '=> 'Category',
												'CO_Deposit__c' => 'Customer Order Deposit',
												'CO_Invoice_Header__c' => 'Customer Order Invoice',
												'Part_FIFO_Bucket__c'  => 'Part',
												'Part_FIFO_Bucket_Activity_Line_Item__c' => 'Part Adjustment',
												'CO_Invoice_Payment__c' => 'Payment',
												'Store_Credit__c'  => 'Store Credit',
												'Customer_Owned_Unit__c'  => 'Unit',
												'Unit_Price_Cost__c' => 'Unit Price Adjustment',
												'Vendor_Invoicing_Header__c' => 'Vendor Invoice',
												'Vendor_Receiving_Header__c' => 'Vendor Receiving',
												'Return_VO_Header__c'  => 'Vendor Return'
												};
	public class EntityInfoWrapper {
		public String EntityId;
		public String Name;
		public String EntityType;
		
		public EntityInfoWrapper(String entityId, String name, String entityType ) {
			this.EntityId = entityId;
			this.Name = name;
			this.EntityType = entityType;
		}
    }
}