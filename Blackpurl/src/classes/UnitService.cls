/**
 * Author: Richa Mittal
 * Since: Dec. 13, 2017
 * Name: UnitService
 * Description: Service Class for Unit (QB Integration)
**/
public with sharing class UnitService {
    
    public static void syncCOUs(Set<Id> COUIds){
        AccSync_Unit_Batch.runCOUsForSync(COUIds, 10);
    } 
    
    public static List<Log__c> syncAccountingServer(AccountingUnit couRecord, List<Customer_Owned_Unit__c> COUListToUpdate){
    	List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
        	 errorLogToInsert = syncToQuickBooks(couRecord, COUListToUpdate);
        }
        return errorLogToInsert;
    } 
    
    public static List<Log__c> syncToQuickBooks(AccountingUnit couRecord, List<Customer_Owned_Unit__c> COUListToUpdate){
        Customer_Owned_Unit__c COU = new Customer_Owned_Unit__c();
        COU.Id = couRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>(); 
        try{
            if(couRecord.SyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('bill', couRecord.AccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    ResponseQuickBooksStockUnit stockUnit = (ResponseQuickBooksStockUnit)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksStockUnit.class);
                    couRecord.SyncToken = stockUnit.Bill.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('UnitService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              couRecord + LogService.METHOD_PARAM_SEPERATOR + COUListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QuickBooksStockUnit QB_StockUnit = new QuickBooksStockUnit(couRecord);
            String COUJSONBody = System.JSON.serialize(QB_StockUnit);
            System.debug('*************');
            System.debug(COUJSONBody);
            String response = COUJSONBody;
            
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('bill', COUJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200) { 
                String resParams = res.getBody();
                ResponseQuickBooksStockUnit COUPostResponse = (ResponseQuickBooksStockUnit)System.JSON.deserialize(resParams, ResponseQuickBooksStockUnit.class);
                COU.AccountingId__c = COUPostResponse.Bill.Id;
                COU.SyncToken__c = COUPostResponse.Bill.SyncToken;
                response += '\n\n'+resParams; 
                COU.availForQBSync__c = false;
                COU.accountingLastSyncTime__c = System.now(); 
            }else{
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('UnitService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              couRecord + LogService.METHOD_PARAM_SEPERATOR + COUListToUpdate, LogService.QUICKBOOKS, false));
            }
            COU.AccountingResponse__c = QBUtil.truncateString(response, 32768);
        }catch(Exception e){
            COU.availForQBSync__c = true;
            COU.AccountingResponse__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('UnitService', 'syncToQuickBooks() -  exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
        	                                  couRecord + LogService.METHOD_PARAM_SEPERATOR + COUListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(COUListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT){
            AccSync_Unit_Batch.updateCOUs(COUListToUpdate);
            COUListToUpdate = new List<Customer_Owned_Unit__c>();
        }
        COUListToUpdate.add(COU);
        return errorLogList;
    }

     /*
     *   START : Quickbooks VI Journal Entry wrapper
     */
     public class QuickBooksStockUnit {
         
        public String Id;
        public String SyncToken;
        public String DocNumber;  
        public Date TxnDate;
        public List<LineWrapper> Line;
        public VendorRefWrapper VendorRef;
        public Decimal TotalAmt;
        public Decimal Balance;
		public String PrivateNote;
		public QBTxnTaxDetailWrapper TxnTaxDetail;
        public String GlobalTaxCalculation;
        
        public QuickBooksStockUnit(AccountingUnit couRecord) {
            this.Id = couRecord.AccountingId;
            this.SyncToken = couRecord.SyncToken;
            this.DocNumber = couRecord.InvoiceNumber;
            this.TxnDate = couRecord.CreatedDate;
            this.PrivateNote = couRecord.ItemDesc;
            this.Line = new List<LineWrapper>();
            List<Category__c> defaultCategory = [select Name, Inventory_GL__c  from Category__c
                									where Type__c = 'Unit' AND Active__c = true AND Default__c = true]; 
            
            String inventoryGLValue = couRecord.Inventory_GL != null ? couRecord.Inventory_GL : defaultCategory[0].Inventory_GL__c;
            
            if(QBUtil.isQBTaxCodesEnabled) {
                this.Line.add(new LineWrapper(couRecord, inventoryGLValue, couRecord.AppliedQBTaxCode));
            } else {
                this.Line.add(new LineWrapper(couRecord, inventoryGLValue));
            }
                
            this.VendorRef = new VendorRefWrapper(couRecord.Vendor);
            this.TotalAmt = couRecord.TotalCost;
            this.Balance = couRecord.TotalCost;
			
			AccountingUnit.AccountingPurchaseTax purchaseTax;
		    if(QBUtil.isQBTaxCodesEnabled) {
		        this.GlobalTaxCalculation = QBUtil.TAX_EXCLUDED;
                Decimal totalTax = couRecord.TotalPurchaseTax;
                List<AccountingUnit.TaxRateComponent> taxComponentList = new List<AccountingUnit.TaxRateComponent>();
		        if(couRecord.AccountingPurchaseTaxList != null && couRecord.AccountingPurchaseTaxList.size() > 0) {
		            for(Integer i=0 ;i<couRecord.AccountingPurchaseTaxList.size(); i++) {
                        purchaseTax = couRecord.AccountingPurchaseTaxList[i];
                        Decimal taxAmount = (purchaseTax.SalesTaxRate * this.TotalAmt/100).setScale(2, RoundingMode.HALF_UP);
                        Decimal taxableAmount = this.TotalAmt;
                        Decimal taxPercent = purchaseTax.SalesTaxRate;
                        String purchaseTaxRateAcctId = purchaseTax.QBTaxCodeRef;
                        taxComponentList.add(new AccountingUnit.TaxRateComponent(taxAmount, taxableAmount, purchaseTaxRateAcctId, taxPercent));
                    }
		        } else if(couRecord.AppliedTaxRate == 0 && couRecord.AccountingPurchaseTaxList.size() == 0) {
		            if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<QB_TaxCode__c> taxCodeList = [SELECT Applicable_QB_Tax_Rates__c FROM QB_TaxCode__c WHERE Accounting_Id__c = :couRecord.AppliedQBTaxCode AND Tax_Applicable_On__c =: QBUtil.PURCHASE];
                    if(taxCodeList.size() > 0  && String.isNotBlank(taxCodeList[0].Applicable_QB_Tax_Rates__c)) {
                        List<String> taxRateAccIdList = taxCodeList[0].Applicable_QB_Tax_Rates__c.split(';');
                        for(String taxRateAccId : taxRateAccIdList) {
                            taxComponentList.add(new AccountingUnit.TaxRateComponent(0, 0, taxRateAccId, 0));
                        }
                    }
		        }
		        this.TxnTaxDetail = new QBTxnTaxDetailWrapper(totalTax, taxComponentList);
		    } else if(couRecord.AccountingPurchaseTaxList.size() > 0) {
		        Decimal TotalTaxAmount = couRecord.TotalPurchaseTax;
	            Decimal taxValue = 0;
	            String categoryRef = '';
		        for(Integer i=0 ;i<couRecord.AccountingPurchaseTaxList.size() - 1; i++) {
                    purchaseTax = couRecord.AccountingPurchaseTaxList[i];
                    Decimal taxAmount = (purchaseTax.SalesTaxRate * this.TotalAmt/100); //.setScale(2, RoundingMode.HALF_UP)
                    taxValue += taxAmount;
                    categoryRef = purchaseTax.CategoyRef != null ? purchaseTax.CategoyRef : AccountingUtil.getChartofAccount('Sales Tax');
	                this.Line.add(new LineWrapper('Purchase Tax - ' + purchaseTax.SalesTaxName, taxAmount, categoryRef));
                }
                purchaseTax = couRecord.AccountingPurchaseTaxList[couRecord.AccountingPurchaseTaxList.size() - 1];
                categoryRef = purchaseTax.CategoyRef != null ? purchaseTax.CategoyRef : AccountingUtil.getChartofAccount('Sales Tax');
                this.Line.add(new LineWrapper('Purchase Tax - ' + purchaseTax.SalesTaxName, (TotalTaxAmount - taxValue), categoryRef));
		    }
        }
    }
     
    public class LineWrapper {
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public AccountBasedExpenseLineDetailWrapper AccountBasedExpenseLineDetail;
        
        public LineWrapper(AccountingUnit couRec, String CategoryAccountRef) {
            this.Description = couRec.ItemDesc;
            this.Amount = (couRec.TotalCost != null) ? couRec.TotalCost : 0;
            this.DetailType = 'AccountBasedExpenseLineDetail';   
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef);   
        }
        
        public LineWrapper(AccountingUnit couRec, String CategoryAccountRef, String taxCodeRefId) {
            this.Description = couRec.ItemDesc;
            this.Amount = (couRec.TotalCost != null) ? couRec.TotalCost : 0;
            this.DetailType = 'AccountBasedExpenseLineDetail';   
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef, taxCodeRefId);   
        }
        
        public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef) {
            this.Description = Description; 
            this.Amount = (Amount != null) ? Amount : 0;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef);   
        }
        public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef, String taxCodeRefId) {
            this.Description = Description; 
            this.Amount = (Amount != null) ? Amount : 0;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef, taxCodeRefId);   
        }
    }

	public class AccountBasedExpenseLineDetailWrapper{
        public AccountRefWrapper AccountRef;
        public QBInnerEntityWrapper TaxCodeRef;
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef)	{
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef); 
        }
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef, String taxCodeRefId)  {
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef); 
            this.TaxCodeRef =  String.isNotBlank(taxCodeRefId) ? new QBInnerEntityWrapper(taxCodeRefId,'') : null; 
        }
    }

    public class AccountRefWrapper {
        public String value;
        public AccountRefWrapper(AccountingVendorInvoice.AccountRefWrapper AccountRef) {
            this.value = AccountRef.AccountingId;
        }
        public AccountRefWrapper(String CategoryAccountRef) {
            this.value = CategoryAccountRef;
        }
    }

    public class VendorRefWrapper {
        
        public String value;
        public String name;
        public VendorRefWrapper(AccountingUnit.VendorWrapper VendorRef) {
            this.value = VendorRef.AccountingId;
            this.name = VendorRef.Name;
        }
    }
     
    public class ResponseQuickBooksStockUnit{
        public QuickBooksStockUnit Bill;
    }
}