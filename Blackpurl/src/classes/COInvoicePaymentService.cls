public with sharing class COInvoicePaymentService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500;
    
    public static CO_Invoice_Header__c syncAccountingServer(List<AccountingCustomerInvoice> COInvoiceRecordList, CO_Invoice_Header__c coInvoiceHeader) {
        return syncToQuickBooks(COInvoiceRecordList, coInvoiceHeader);
    }  
    
    public static CO_Invoice_Header__c syncToQuickBooks(List<AccountingCustomerInvoice> COInvoiceRecordList, CO_Invoice_Header__c coInvoiceHeader) {
        if(COInvoiceRecordList == null || COInvoiceRecordList.size() == 0) {
        	return new CO_Invoice_Header__c();
        }
        coInvoiceHeader.Id = COInvoiceRecordList[0].AccountingCOInvoiceHeaderRec.COInvoiceHeaderId;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
            if(COInvoiceRecordList[0].AccountingCOInvoiceHeaderRec.COInvoicePaymentSyncToken != null) {
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('payment', COInvoiceRecordList[0].AccountingCOInvoiceHeaderRec.COInvoicePaymentAccountingId);
                if(getResponse.getStatusCode() == 200) { 
                    ResponseQuickBooksCOInvoicePayment COInvoicePaymentGetResponce = (ResponseQuickBooksCOInvoicePayment)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksCOInvoicePayment.class);
                    COInvoiceRecordList[0].AccountingCOInvoiceHeaderRec.COInvoicePaymentSyncToken = COInvoicePaymentGetResponce.Payment.SyncToken;
                } else {
                	errorLogList.add(new LogService().createErrorLog('COInvoicePaymentService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              COInvoiceRecordList[0] + LogService.METHOD_PARAM_SEPERATOR + coInvoiceHeader, LogService.QUICKBOOKS, false));
                }
            }
            QuickBooksCOInvoicePayment QCOInvPayment = new QuickBooksCOInvoicePayment(COInvoiceRecordList[0]);
            String COInvoicePaymentJSONBody = System.JSON.serialize(QCOInvPayment);
            if(decimal.valueOf(QCOInvPayment.TotalAmt) > 0) {
            	HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('payment', COInvoicePaymentJSONBody);
	            System.debug(res);
	            String response = COInvoicePaymentJSONBody;
	            if(res.getStatusCode() == 200) { 
	                String resParams = res.getBody();
	                ResponseQuickBooksCOInvoicePayment COInvoicePaymentPostResponse = (ResponseQuickBooksCOInvoicePayment)System.JSON.deserialize(resParams, ResponseQuickBooksCOInvoicePayment.class);
	                
	                coInvoiceHeader.AccountingIdForCOInvoicePayment__c = COInvoicePaymentPostResponse.Payment.Id;
	                coInvoiceHeader.SyncTokenForCOInvoicePayment__c = COInvoicePaymentPostResponse.Payment.SyncToken;
	                response += '\n\n' + resParams;
	                coInvoiceHeader.availForQBCOInvoicePayment__c = false;
	                coInvoiceHeader.accountingLastSyncTimeForCOInvPayment__c = System.now();
	            } else {
	                response += res.getBody() + '\n\n' + res.getStatus();
	                errorLogList.add(new LogService().createErrorLog('COInvoicePaymentService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              COInvoiceRecordList[0] + LogService.METHOD_PARAM_SEPERATOR + coInvoiceHeader, LogService.QUICKBOOKS, false));
	            }
	            coInvoiceHeader.AccountingResponseForCOInvoicePayment__c = QBUtil.truncateString(response, 131072);
            } else {
            	coInvoiceHeader.availForQBCOInvoicePayment__c = false;
	            coInvoiceHeader.accountingLastSyncTimeForCOInvPayment__c = System.now();
            }
            
        } catch(Exception e) {
            coInvoiceHeader.AccountingResponseForCOInvoicePayment__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('COInvoicePaymentService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              COInvoiceRecordList[0] + LogService.METHOD_PARAM_SEPERATOR + coInvoiceHeader, LogService.QUICKBOOKS, false));
        }
        
		if(errorLogList.size() > 0) {
        	insert errorLogList;
        }
        return coInvoiceHeader;
        
     }
     
     
    /*
     *   START : Quickbooks Customer wrapper
     */
     public class QuickBooksCOInvoicePayment{
        public String Id;
        
        public String SyncToken;
        
        public Date TxnDate;
        
        public String TxnStatus;
        
        public String PaymentRefNum;
        
        public String TotalAmt;
        
        public Decimal UnappliedAmt;
        
        public List<QuickBooksLineWrapper> Line;
        
        public QuickBooksCustomerRefWrapper CustomerRef;
        
        public DepositToAccountRefWrapper DepositToAccountRef;
        
        public QuickBooksCOInvoicePayment(AccountingCustomerInvoice COInvoiceRecord) {
            this.Id = COInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoicePaymentAccountingId;
            this.SyncToken = COInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoicePaymentSyncToken;
            this.TxnDate = DateTimeUtility.getDateFromFormattedDateStr(COInvoiceRecord.AccountingCOInvoiceHeaderRec.ClosedInvoiceDate); 
            
            Decimal TotalInvoicePayment = 0;
            for(AccountingCOInvoicePayment coInvoicePaymentRec: COInvoiceRecord.AccountingCOInvoicePaymentsRecs) {
            	if(coInvoicePaymentRec.PaymentMethod != 'Charge Account') {
            		TotalInvoicePayment += coInvoicePaymentRec.Amount;
            	}
            }
            
            
            
            this.Line = new List<QuickBooksLineWrapper>();
            this.Line.add(new QuickBooksLineWrapper(COInvoiceRecord, TotalInvoicePayment));
            
            this.CustomerRef = new QuickBooksCustomerRefWrapper(COInvoiceRecord.AccountingCOInvoiceHeaderRec.customer);
            
            String customerDepositAccount = Accountingutil.getChartofAccount('Customer Deposits');
            this.DepositToAccountRef  = new DepositToAccountRefWrapper(customerDepositAccount);
            
            this.TotalAmt = String.valueOf(TotalInvoicePayment);
            
        }
     }
     
     public class QuickBooksLineWrapper{
        
        public Decimal Amount;
        
        public List<QuickBooksLinkedTxnWrapper> LinkedTxn; 
        
        public QuickBooksLineWrapper(AccountingCustomerInvoice COInvoiceRecord, Decimal TotalInvoicePayment) {
            this.Amount = TotalInvoicePayment;  
            
            this.LinkedTxn = new List<QuickBooksLinkedTxnWrapper>();
            this.LinkedTxn.add(new QuickBooksLinkedTxnWrapper(COInvoiceRecord));          
        }
     }
     
     public class QuickBooksLinkedTxnWrapper{
        
        public String TxnId;
        public String TxnType;
        
        public QuickBooksLinkedTxnWrapper(AccountingCustomerInvoice COInvoiceRecord) {
            this.TxnId = COInvoiceRecord.AccountingCOInvoiceHeaderRec.AccountingId;
            this.TxnType = 'Invoice';
            
        }
     }
     
     public class QuickBooksCustomerRefWrapper{
        
        public String value;
        public String name;
        
        public QuickBooksCustomerRefWrapper(AccountingCustomerInvoice.CustomerWrapper customerRecord) {
            this.value = customerRecord.AccountingId;
            this.name = customerRecord.Name;
        }
     }
     
     public class ResponseQuickBooksCOInvoicePayment{
        public QuickBooksCOInvoicePayment payment;
     }
     
     public class DepositToAccountRefWrapper{
        public String value;
        
        public DepositToAccountRefWrapper(String value){
        	this.value = value;
        }
     }
}