global with sharing class ScheduleQBSync implements Schedulable {
    global String actionType;
    
    global ScheduleQBSync(){
    	
    }
    
    global ScheduleQBSync(String actionType){
    	this.actionType = actionType;
    }
    
    global void execute(SchedulableContext SC) {
    	if(actionType == 'TaxAgency'){
    		syncTaxAgency();
    	}else if(actionType == 'TaxCode'){
    		syncTaxCode();
    	}
    }
    
    @Future(callout=true)	
    public static void syncTaxAgency(){
    	if(AccessControl.ifObjectFieldIsCreateable('QuickBooks_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('QuickBooks_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	
    	boolean isvalidTaxAgency = false;
    	QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	if(qbConfig.Tax_Agency_Id__c != null && qbConfig.Tax_Agency_Name__c != null){
    		HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('taxagency', qbConfig.Tax_Agency_Id__c);
			if(getResponse.getStatusCode() == 200){
				TaxAgencyWrapper taxAgencyGetResponce =  (TaxAgencyWrapper)System.JSON.deserialize(getResponse.getBody(), TaxAgencyWrapper.class);
				if(taxAgencyGetResponce.TaxAgency.DisplayName == qbConfig.Tax_Agency_Name__c){
					isvalidTaxAgency = true;
				}
			}
    	}
    	if(!isvalidTaxAgency){
    		String taxAgencyName = qbConfig.Tax_Agency_Name__c != null ? qbConfig.Tax_Agency_Name__c : 'BP Tax Agency';
    		QuickBooksSalesTaxItemAgencyRef QSARef =  new QuickBooksSalesTaxItemAgencyRef(taxAgencyName);
    		String salesTaxItemAgencyRefJSONBody = System.JSON.serialize(QSARef); // Added
			HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('taxagency', salesTaxItemAgencyRefJSONBody); // Added
			if(res.getStatusCode() == 200){ 
				String resParams = res.getBody();
				TaxAgencyWrapper responceQS = (TaxAgencyWrapper)System.JSON.deserialize(resParams, TaxAgencyWrapper.class);
	        	if(responceQS.TaxAgency.Id != null){
	        		qbConfig.Tax_Agency_Id__c = responceQS.TaxAgency.Id;
	        		qbConfig.Tax_Agency_Name__c = responceQS.TaxAgency.DisplayName;
	        		upsert qbConfig;
	        	}
			}
    	}
    	DateTime dtVal = system.now().addMinutes(1);
    	String day = string.valueOf(dtVal.day());
		String month = string.valueOf(dtVal.month());
		String hour = string.valueOf(dtVal.hour());
		String minute = string.valueOf(dtVal.minute());
		String second = string.valueOf(dtVal.second());
		String year = string.valueOf(dtVal.year());
		String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;
		
        List<CronTrigger> alreadyScheduledJobs = [Select Id from CronTrigger where CronJobDetail.Name = 'Tax Code Job'];
        if(alreadyScheduledJobs.size() > 0) {
            system.abortJob(alreadyScheduledJobs[0].Id);    
        }
        System.schedule('Tax Code Job', strSchedule, new ScheduleQBSync('TaxCode'));
    }
    
    
    
    @Future(callout=true)	
    public static void syncTaxCode(){
        List<Sales_Tax_Item__c> salestaxList = [select Id, Name__c, Rate__c, AccountingId__c
    											from  Sales_Tax_Item__c
    											where Active__c = true];
    	AccountingSalesTax salesTaxRecord = new AccountingSalesTax(salestaxList);
        syncToQuickBooks(salesTaxRecord);
    }
    
    
    
    public static void syncToQuickBooks(AccountingSalesTax salesTaxRecord){
    	if(AccessControl.ifObjectFieldIsCreateable('QuickBooks_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('QuickBooks_Configurations__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsCreateable('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Sales_Tax_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	
    	QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	if(salesTaxRecord.salesTaxItemsList.size() == 0 || qbConfig.Tax_Agency_Id__c == null){
    		return;
    	}
    	List<Sales_Tax_Item__c> salesTaxItemsList = new List<Sales_Tax_Item__c>();
    	System.debug(salesTaxRecord.salesTaxItemsList +'*******************');
        
        qbConfig.Tax_Code_Sync_Response__c = 'Method Called';
        try{
        	String query = 'SELECT Id, Name FROM TaxRate';
        	query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');
			HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('query?query='+query, null);
    		Map<String, String> taxRateNameToIdMap = new Map<String, String>();
    		if(getResponse.getStatusCode() == 200){ 
    			QueryResponseWrapper salesTaxQueryResponse = (QueryResponseWrapper)System.JSON.deserialize(getResponse.getBody(), QueryResponseWrapper.class);
    			if(salesTaxQueryResponse != null && salesTaxQueryResponse.QueryResponse != null
    				&& salesTaxQueryResponse.QueryResponse.TaxRate != null){
    				for(TaxRateWrapper taxRateItem : salesTaxQueryResponse.QueryResponse.TaxRate){
    					taxRateNameToIdMap.put(taxRateItem.Name, taxRateItem.Id);
    				}
    			}
    		}
    		Sales_Tax_Item__c salesTaxItem;
    		for(AccountingSalesTax.SalesTaxItemWrapper SalesTaxItemRecord : salesTaxRecord.salesTaxItemsList){
	    		salesTaxItem = new Sales_Tax_Item__c();
	    		salesTaxItem.Id = SalesTaxItemRecord.SalesTaxItem_Id;
	    		salesTaxItem.Name__c = SalesTaxItemRecord.TaxItemName;
	    		if(taxRateNameToIdMap.containsKey(SalesTaxItemRecord.SalesTaxItem_Name)){
	    			salesTaxItem.AccountingId__c = taxRateNameToIdMap.get(SalesTaxItemRecord.SalesTaxItem_Name);
	    			SalesTaxItemRecord.SalesTaxItem_AccountingId = taxRateNameToIdMap.get(SalesTaxItemRecord.SalesTaxItem_Name);
	    		}
	    		salesTaxItemsList.add(salesTaxItem);
	    	}
			QuickBooksSalesTax QB_TaxCode = new QuickBooksSalesTax(salesTaxRecord);  
			String salesTaxJSONBody = System.JSON.serialize(QB_TaxCode);
			System.debug('******' + salesTaxJSONBody + '******');
			String resParams = salesTaxJSONBody;
			//salesTax.AccountingResponse__c = salesTaxJSONBody;
			//salesTax.AccountingResponse__c = salesTaxJSONBody;
			HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('taxservice/taxcode', salesTaxJSONBody);
			System.debug(res);
			if(res.getStatusCode() == 200){ 
	        	resParams += '\n\n'+res.getBody();
	        	QuickBooksSalesTax salesTaxPostResponse = (QuickBooksSalesTax)System.JSON.deserialize(res.getBody(), QuickBooksSalesTax.class);
	        	System.debug('------------------'+ resParams +'******************'+salesTaxPostResponse);
	        	qbConfig.TaxCode_Id__c = salesTaxPostResponse.TaxCodeId;
	        	qbConfig.Tax_Code_Sync_Response__c = res.getStatus() + ' ' + res.getStatusCode();
	        	for(Sales_Tax_Item__c salesTaxItemToUpdate : salesTaxItemsList)	{
	        		if(salesTaxPostResponse.TaxRateDetails != null){
	        			for(QuickBooksTaxRateDetailWrapper TaxRateDetail : salesTaxPostResponse.TaxRateDetails)	{
		        			if(TaxRateDetail != null && Constants.TAX_CODE_PREFIX_FOR_QB + '' +salesTaxItemToUpdate.Name__c == TaxRateDetail.TaxRateName)	{
		        				if(TaxRateDetail.TaxRateId != null){
		        					salesTaxItemToUpdate.AccountingId__c = TaxRateDetail.TaxRateId;
		        				}
		        			}
		        		}
	        		}
	        	}
	        }else{
	        	//salesTax.AccountingResponse__c += '\n\n'+res.getBody();
	        	//salesTax.AccountingResponse__c += '\n\n' + res.getStatus();
	        	qbConfig.Tax_Code_Sync_Response__c = res.getBody();
	        }
	 	}catch(Exception e){
        	//salesTax.availForQBSync__c = true;
        	//salesTax.AccountingResponse__c = e.getMessage();
        	qbConfig.Tax_Code_Sync_Response__c = e.getMessage();
        }
        if(qbConfig.Tax_Code_Sync_Response__c.length() >= 225){
        	qbConfig.Tax_Code_Sync_Response__c = qbConfig.Tax_Code_Sync_Response__c.subString(0, 224);
        }
        upsert qbConfig;
        if(salesTaxItemsList.size() > 0){
        	//AccSync_SalesTax_Batch.updateSalesTaxes(slaesTaxListToUpdate);
        	//slaesTaxListToUpdate = new List<sObject>();
        	update salesTaxItemsList;
        }
        //slaesTaxListToUpdate.add(salesTax); 
        
    }
    
    
    /*
      * START : Quickbooks SalesTax wrapper
      */
     public class QuickBooksSalesTax{
    	public String TaxCode;
     	public String TaxCodeId; 
    	
    	public List<QuickBooksTaxRateDetailWrapper> TaxRateDetails;
    	
    	public QuickBooksSalesTax(AccountingSalesTax salesTaxRecord) {
    		//if(String.isBlank(salesTaxRecord.AccountingId)){
    			this.TaxCode = salesTaxRecord.SalesTaxName;// + '(' + System.now() + ')';
    			//this.TaxCode = this.TaxCode.replace(':', '-');
    		//}
    		this.TaxRateDetails = new List<QuickBooksTaxRateDetailWrapper>();
    		for(AccountingSalesTax.SalesTaxItemWrapper salesTaxItem : salesTaxRecord.salesTaxItemsList){
    			this.TaxRateDetails.add(new QuickBooksTaxRateDetailWrapper(salesTaxItem));
    		}
    		this.TaxCodeId = salesTaxRecord.AccountingId;
    	}
     }
     //End : Quickbooks SalesTax wrapper
     
     //Start : Quickbooks TaxRateDetail wrapper
     public class QuickBooksTaxRateDetailWrapper	{
     	public String TaxRateName;
     	public String TaxRateId; 
        public String RateValue; 
        public String TaxAgencyId;
	
     	public QuickBooksTaxRateDetailWrapper(AccountingSalesTax.SalesTaxItemWrapper salesTaxItem) {
    		this.TaxRateId = salesTaxItem.SalesTaxItem_AccountingId;
    		this.RateValue = String.valueOf(Integer.valueOf(salesTaxItem.SalesTaxItem_Rate));
    		if(String.isBlank(salesTaxItem.SalesTaxItem_AccountingId)){
    			this.TaxRateName = salesTaxItem.SalesTaxItem_Name;
    			this.TaxAgencyId = salesTaxItem.SalesTaxItem_TaxAgencyId;
    		}
    		
    		
    	}
     }
     // End : Quickbooks TaxRateDetail wrapper
     
	public class TaxAgencyWrapper{
		public TaxAgency TaxAgency;
	}
	
	public class TaxAgency{
		public String Id;
		public String DisplayName;
	}
	
	
	public class QuickBooksSalesTaxItemAgencyRef{ // Added
     	//public String value;
     	public String DisplayName;  
     	
     	public QuickBooksSalesTaxItemAgencyRef(String DisplayName) {
    		this.DisplayName = DisplayName;
    	}
     }
     
     
     
	public class QueryResponseWrapper{
    	public TaxRateQueryResponseWrapper QueryResponse;
    }
    
    public class TaxRateQueryResponseWrapper{
    	public List<TaxRateWrapper> TaxRate;
    	
    }
    
    public class TaxRateWrapper{
    	public String Name;
    	public String Id;
    	
    }
}