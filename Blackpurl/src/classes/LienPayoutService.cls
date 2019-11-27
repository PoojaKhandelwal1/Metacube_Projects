/**
 * Author: Pooja Khandelwal
 * Since: Nov. 26, 2018
 * Name: LienPayoutService
 * Description: Service Class for Lien Payout Service (For QB Bill Integration)
**/
public with sharing class LienPayoutService {
    
    public static void syncLienPayouts(Set<Id> dealItemIdSet){
        AccSync_LienPayout_Batch.runLienPayoutForSync(dealItemIdSet, new Set<Id>(), 10);
    } 
    
    public static List<Log__c> syncAccountingServer(AccountingLienPayout dealItemRecord, List<Deal_Item__c> dealItemListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
            errorLogToInsert = syncToQuickBooks(dealItemRecord, dealItemListToUpdate);
        }
        return errorLogToInsert; 
    } 
    
    public static List<Log__c> syncToQuickBooks(AccountingLienPayout dealItemRecord, List<Deal_Item__c> dealItemListToUpdate){
        Deal_Item__c dealItem = new Deal_Item__c();
        dealItem.Id = dealItemRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>(); 
        try{
            if(dealItemRecord.SyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('bill', dealItemRecord.AccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    ResponseQuickBooksLienPayout lienPayout = (ResponseQuickBooksLienPayout)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksLienPayout.class);
                    dealItemRecord.SyncToken = lienPayout.Bill.SyncToken;
                } else {
                    errorLogList.add(new LogService().createErrorLog('LienPayoutService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              dealItemRecord + LogService.METHOD_PARAM_SEPERATOR + dealItemListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            
            QuickBooksLienPayout QB_LienPayout = new QuickBooksLienPayout(dealItemRecord);
            String lienPayoutJSONBody = system.JSON.serialize(QB_LienPayout);
            String response = lienPayoutJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('bill', lienPayoutJSONBody);
            
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                ResponseQuickBooksLienPayout lienPayoutPostResponse = (ResponseQuickBooksLienPayout)System.JSON.deserialize(resParams, ResponseQuickBooksLienPayout.class);
                dealItem.Lien_Payout_Accounting_Id__c = lienPayoutPostResponse.Bill.Id;
                dealItem.Lien_Payout_Sync_Token__c = lienPayoutPostResponse.Bill.SyncToken;
                response += '\n\n'+resParams; 
                dealItem.Lien_Payout_Avail_For_QB_Sync__c = false;
                dealItem.Lien_Payout_Accounting_Last_Sync_Time__c = System.now(); 
            }else{
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('LienPayoutService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              dealItemRecord + LogService.METHOD_PARAM_SEPERATOR + dealItemListToUpdate, LogService.QUICKBOOKS, false));
            }
            dealItem.Lien_Payout_Accounting_Response__c = QBUtil.truncateString(response, 32768);
        }catch(Exception e){
            dealItem.Lien_Payout_Avail_For_QB_Sync__c = true;
            dealItem.Lien_Payout_Accounting_Response__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('LienPayoutService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              dealItemRecord + LogService.METHOD_PARAM_SEPERATOR + dealItemListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(dealItemListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT){
            AccSync_LienPayout_Batch.updateDealItems(dealItemListToUpdate);
            dealItemListToUpdate = new List<Deal_Item__c>();
        }
        dealItemListToUpdate.add(dealItem); 
        return errorLogList;
    }

     /*
     *   START : Quickbooks Lien Payout Journal Entry - Bill wrapper
     */
   public class QuickBooksLienPayout {
        public String Id;
        public String SyncToken;
        public String DocNumber;  
        public Date TxnDate;
        public List<LineWrapper> Line;
        public VendorRefWrapper VendorRef;
        //public AccountRefWrapper APAccountRef;
        public Decimal TotalAmt;
        public Decimal Balance;
        public String GlobalTaxCalculation;
        
        public QuickBooksLienPayout(AccountingLienPayout dealItemRecord) {
            this.Id = dealItemRecord.AccountingId;
            this.SyncToken = dealItemRecord.SyncToken;
            this.DocNumber = dealItemRecord.InvoiceNumber;
            this.TxnDate = dealItemRecord.InvoiceDate;
            
            this.Line = new List<LineWrapper>();
            String itemDesc = 'Lien payout:' + (!String.isBlank(dealItemRecord.UnitVinNumber) ? (' ' + dealItemRecord.UnitVinNumber) : '') 
                    				+  (!String.isBlank(dealItemRecord.FinanceCompany.Name) ? (' ' + dealItemRecord.FinanceCompany.Name) : '');
            this.Line.add(new LineWrapper(itemDesc, dealItemRecord.LienPayout, dealItemRecord.CategoyIncomeGLAccountRef));
            
            this.VendorRef = new VendorRefWrapper(dealItemRecord.FinanceCompany);
            this.TotalAmt = this.Balance = dealItemRecord.LienPayout;
            this.GlobalTaxCalculation = QBUtil.TAX_NOT_APPLICABLE;
        }
    }
     
    public class LineWrapper {
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public AccountBasedExpenseLineDetailWrapper AccountBasedExpenseLineDetail;
        
        public LineWrapper(String description, Decimal amount, String categoryAccountRef) {
            this.Description = description; 
            this.Amount = amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(categoryAccountRef);   
        }
    }

    public class AccountBasedExpenseLineDetailWrapper {
        public AccountRefWrapper AccountRef;

        public AccountBasedExpenseLineDetailWrapper(String categoryAccountRef)  {
            this.AccountRef = new AccountRefWrapper(categoryAccountRef); 
        }
    }
     
    public class AccountRefWrapper {
        public String value;
        
        public AccountRefWrapper(String categoryAccountRef) {
            this.value = categoryAccountRef;
        }
    }

    public class VendorRefWrapper {
        public String value;
        public String name;
        public VendorRefWrapper(AccountingLienPayout.VendorWrapper vendorRef) {
            this.value = vendorRef.AccountingId;
            this.name = vendorRef.Name;
        }
     }
     
     public class ResponseQuickBooksLienPayout {
        public QuickBooksLienPayout Bill;
     }
}