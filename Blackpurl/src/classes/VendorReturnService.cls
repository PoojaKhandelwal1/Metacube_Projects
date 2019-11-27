/**
 * Author: Hitesh Gupta
 * Since: Oct 11, 2017
 * Name: VendorReturnService
 * Description: Service Class for Vendor Return (QB Integration)
**/
public with sharing class VendorReturnService {
    public static Boolean isNonTaxableItemAvailble = false;
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500;
    
    public static void syncRVOHeaders(Set<Id> RVOHeaderIds){
        AccSync_VendorReturn_Batch.runRVOHeadersForSync(RVOHeaderIds, 10);
    } 
    
    public static List<Log__c> syncAccountingServer(AccountingVendorReturn returnVOHeaderRecord, List<Return_VO_Header__c> RVOHeaderListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
        	errorLogToInsert = syncToQuickBooks(returnVOHeaderRecord, RVOHeaderListToUpdate);
        }
        return errorLogToInsert;
    } 
    
    public static List<Log__c> syncToQuickBooks(AccountingVendorReturn returnVOHeaderRecord, List<Return_VO_Header__c> RVOHeaderListToUpdate) {
        Return_VO_Header__c RVOHeader = new Return_VO_Header__c();
        RVOHeader.Id = returnVOHeaderRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(returnVOHeaderRecord.SyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('vendorcredit', returnVOHeaderRecord.AccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    ResponseQuickBooksVendorInvoice vendorInvoice = (ResponseQuickBooksVendorInvoice)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksVendorInvoice.class);
                    returnVOHeaderRecord.SyncToken = vendorInvoice.VendorCredit.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('VendorReturnService', 'syncToQuickBooks()- Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              returnVOHeaderRecord + LogService.METHOD_PARAM_SEPERATOR + RVOHeaderListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QuickBooksVendorInvoice QB_VI = new QuickBooksVendorInvoice(returnVOHeaderRecord);
            String VendorInvoiceJSONBody = System.JSON.serialize(QB_VI);
            String response = vendorInvoiceJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('vendorcredit', VendorInvoiceJSONBody);
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                ResponseQuickBooksVendorInvoice VendorInvoicePostResponse = (ResponseQuickBooksVendorInvoice)System.JSON.deserialize(resParams, ResponseQuickBooksVendorInvoice.class);
                RVOHeader.AccountingId__c = VendorInvoicePostResponse.VendorCredit.Id;
                RVOHeader.SyncToken__c = VendorInvoicePostResponse.VendorCredit.SyncToken;
                RVOHeader.AccountingResponse__c += '\n\n'+resParams; 
                RVOHeader.availForQBSync__c = false;
                RVOHeader.accountingLastSyncTime__c = System.now(); 
            }else{
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('VendorReturnService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              returnVOHeaderRecord + LogService.METHOD_PARAM_SEPERATOR + RVOHeaderListToUpdate, LogService.QUICKBOOKS, false));
            }
            response += '\n\n' + res.getBody() + '\n\n' + res.getStatus();
            RVOHeader.AccountingResponse__c = QBUtil.truncateString(response, 131072);
        } catch(Exception e) {
            RVOHeader.availForQBSync__c = true;
            RVOHeader.AccountingResponse__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('VendorReturnService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  returnVOHeaderRecord + LogService.METHOD_PARAM_SEPERATOR + RVOHeaderListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(RVOHeaderListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_VendorReturn_Batch.updateRVOHeaders(RVOHeaderListToUpdate);
            RVOHeaderListToUpdate = new List<Return_VO_Header__c>();
        }
        RVOHeaderListToUpdate.add(RVOHeader); 
        return errorLogList;
    }
    
	public class QuickBooksVendorInvoice{
        public String Id;
        public String SyncToken;
        public String DocNumber;  
        public Date TxnDate;
        public List<LineWrapper> Line;
        public VendorRefWrapper VendorRef;
		public AccountRefWrapper APAccountRef;
        public Decimal TotalAmt;
        public Decimal Balance;
		public String GlobalTaxCalculation;
		public QBTxnTaxDetailWrapper TxnTaxDetail;    

		public QuickBooksVendorInvoice(AccountingVendorReturn returnVOHeaderRecord) {
            this.Id = returnVOHeaderRecord.AccountingId;
            this.SyncToken = returnVOHeaderRecord.SyncToken;
            this.DocNumber = returnVOHeaderRecord.Name; 
            this.TxnDate = returnVOHeaderRecord.CreditedDate;
            this.Line = new List<LineWrapper>();

            Map<Id, List<AccountingFIFOBucket>> partIdToFIFOBucketMap = new Map<Id, List<AccountingFIFOBucket>>();
            Decimal Variance = 0;
            String description = '';

            for(AccountingVendorReturn.ReturnVoLineItemWrapper RVOLIRec : returnVOHeaderRecord.ReturnVOLIList) {
                this.Line.add(new LineWrapper(RVOLIRec, returnVOHeaderRecord.AccountRef1, 
                								returnVOHeaderRecord.TaxCodeAccountingId)); 

			    Variance = ((RVOLIRec.ReturnQty * RVOLIRec.ItemCost) - RVOLIRec.InventoryCost);
                description = ''; 
                description += RVOLIRec.ItemDescription;
                if(Variance != 0) {
                	isNonTaxableItemAvailble = true;
                	String invAdjustmentsAccId = AccountingUtil.getChartofAccount('Inventory Adjustments');
                    this.Line.add(new LineWrapper((description + ' Receiving Adjustment'), Variance, invAdjustmentsAccId, QBUtil.nonTaxableCodeAccId)); // Changed account returnVOHeaderRecord.AccountRef1 => invAdjustmentsAccId #3313
                    this.Line.add(new LineWrapper((description + ' Inventory Adjustment'), (Variance * -1), returnVOHeaderRecord.AccountRef1, QBUtil.nonTaxableCodeAccId)); // RVOLIRec.Inventory_GL  // Changed account invAdjustmentsAccId => returnVOHeaderRecord.AccountRef1 #3313
                } 
            }
            this.VendorRef = new VendorRefWrapper(returnVOHeaderRecord.VendorAccountingId, returnVOHeaderRecord.VendorName);
            this.TotalAmt = returnVOHeaderRecord.Total;
            this.Balance = returnVOHeaderRecord.Total; 

			Decimal TotalTaxAmount = returnVOHeaderRecord.Tax;
			Decimal taxValue = 0;
			String categoryRef = '';
			AccountingVendorReturn.AccountingPurchaseTax purchaseTax;
			
            if(QBUtil.isQBTaxCodesEnabled) {
            	this.GlobalTaxCalculation = QBUtil.TAX_EXCLUDED;
	            
            	List<AccountingVendorReturn.TaxRateComponent> taxComponentList = new List<AccountingVendorReturn.TaxRateComponent>();
				for(Integer i=0 ; i<returnVOHeaderRecord.AccountingPurchaseTaxList.size(); i++) {
					purchaseTax = returnVOHeaderRecord.AccountingPurchaseTaxList[i];
					Decimal taxAmount = (purchaseTax.SalesTaxRate*returnVOHeaderRecord.SubTotal/100);  
					Decimal taxableAmount = returnVOHeaderRecord.SubTotal;
					String purchaseTaxRateAcctId = purchaseTax.SalesTaxItemAccountingId;
					Decimal taxPercent = purchaseTax.SalesTaxRate;
					taxComponentList.add(new AccountingVendorReturn.TaxRateComponent(taxAmount, taxableAmount, purchaseTaxRateAcctId, taxPercent));
				}
				
				if(returnVOHeaderRecord.AccountingPurchaseTaxList.size() == 0 && String.isNotBlank(returnVOHeaderRecord.TaxCodeAccountingId)) {
		    		List<QB_TaxCode__c> taxCodeList = [SELECT Applicable_QB_Tax_Rates__c FROM QB_TaxCode__c WHERE Accounting_Id__c = :returnVOHeaderRecord.TaxCodeAccountingId AND Tax_Applicable_On__c =: QBUtil.PURCHASE];
		    		if(taxCodeList.size() > 0 && String.isNotBlank(taxCodeList[0].Applicable_QB_Tax_Rates__c)) {
		    			 List<String> taxRateAccIdList = taxCodeList[0].Applicable_QB_Tax_Rates__c.split(';');
		    			 for(String taxRateAccId : taxRateAccIdList) {
							taxComponentList.add(new AccountingVendorReturn.TaxRateComponent(0, 0, taxRateAccId, 0));
						}
		    		}
				}
				
				Map<String, List<String>> nonTaxableTaxCodeToTaxRatesMap = QBUtil.getNonTaxableTaxCodeWithRates(QBUtil.PURCHASE);
				if(isNonTaxableItemAvailble && nonTaxableTaxCodeToTaxRatesMap.containsKey(QBUtil.nonTaxableCodeAccId)) {
					for(String taxRateAccId : nonTaxableTaxCodeToTaxRatesMap.get(QBUtil.nonTaxableCodeAccId)) {
						taxComponentList.add(new AccountingVendorReturn.TaxRateComponent(0, 0, taxRateAccId, 0));
					}
				}
            
            	this.TxnTaxDetail = new QBTxnTaxDetailWrapper(returnVOHeaderRecord.Tax, taxComponentList);
            } else {
            	this.GlobalTaxCalculation = QBUtil.TAX_NOT_APPLICABLE;
            	if(returnVOHeaderRecord.AccountingPurchaseTaxList.size() > 0) {
					for(Integer i=0 ;i<returnVOHeaderRecord.AccountingPurchaseTaxList.size() - 1; i++) {
						purchaseTax = returnVOHeaderRecord.AccountingPurchaseTaxList[i];
						Decimal taxAmount = (purchaseTax.SalesTaxRate*this.TotalAmt/100); //.setScale(2, RoundingMode.HALF_UP)
						taxValue += taxAmount;
						categoryRef = purchaseTax.CategoyRef != null ? purchaseTax.CategoyRef : AccountingUtil.getChartofAccount('Sales Tax');
						this.Line.add(new LineWrapper('Purchase Tax - ' + purchaseTax.SalesTaxName, taxAmount, categoryRef));
					}
					purchaseTax = returnVOHeaderRecord.AccountingPurchaseTaxList[returnVOHeaderRecord.AccountingPurchaseTaxList.size() - 1];
					categoryRef = purchaseTax.CategoyRef != null ? purchaseTax.CategoyRef : AccountingUtil.getChartofAccount('Sales Tax');
					this.Line.add(new LineWrapper('Purchase Tax - ' + purchaseTax.SalesTaxName, (TotalTaxAmount - taxValue), categoryRef));
				}
            }
        }       
     }        
     
     public class LineWrapper {
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public AccountBasedExpenseLineDetailWrapper AccountBasedExpenseLineDetail;
       
        public LineWrapper(AccountingVendorReturn.ReturnVoLineItemWrapper RVOLIRec, AccountingVendorReturn.AccountRefWrapper AccountRef, String taxCodeAccountingId) { 
            this.Description = RVOLIRec.ItemDescription + ' ' + RVOLIRec.ReturnQty + '@$' + RVOLIRec.ItemCost; 
            this.Amount = RVOLIRec.ReturnQty * RVOLIRec.ItemCost; 
            this.DetailType = 'AccountBasedExpenseLineDetail';    
			this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef, taxCodeAccountingId);   
		}
        
        public LineWrapper(String Description, Decimal Amount, AccountingVendorReturn.AccountRefWrapper AccountRef, String taxCodeAccountingId) {
            this.Description = Description;
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef, taxCodeAccountingId);   
        }
         
         public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef, String taxCodeAccountingId) {
            this.Description = Description; 
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef, taxCodeAccountingId);   
        }
         
        public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef) {
            this.Description = Description; 
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef);   
        }
     }
     
	public class AccountBasedExpenseLineDetailWrapper{
        public AccountRefWrapper AccountRef;
        public QBInnerEntityWrapper TaxCodeRef;
        
        public AccountBasedExpenseLineDetailWrapper(AccountingVendorReturn.AccountRefWrapper AccountRef, String taxCodeAccountingId)	{
            this.AccountRef = new AccountRefWrapper(AccountRef); 
        	if(QBUtil.isQBTaxCodesEnabled) {
            	this.TaxCodeRef = new QBInnerEntityWrapper(taxCodeAccountingId, '');
            }
        }
        
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef, String taxCodeAccountingId)	{
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef); 
            if(QBUtil.isQBTaxCodesEnabled) {
            	this.TaxCodeRef = new QBInnerEntityWrapper(taxCodeAccountingId, '');
            }
        }
        
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef)	{
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef); 
        }
     }
     
     public class AccountRefWrapper{
        public String value;
        
        public AccountRefWrapper(AccountingVendorReturn.AccountRefWrapper AccountRef) {
            this.value = AccountRef.AccountingId;
        }
        
        public AccountRefWrapper(String CategoryAccountRef) {
            this.value = CategoryAccountRef;
        }
     }

      public class VendorRefWrapper{
        public String value;
        public String name;
        
        public VendorRefWrapper(String value, String name) {
            this.value = value;
            this.name = name;
        }
     }
     
     public class ResponseQuickBooksVendorInvoice{
        public QuickBooksVendorInvoice VendorCredit;
     }
}