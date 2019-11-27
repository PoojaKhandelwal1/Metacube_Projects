/**
 * Author: Pooja Khandelwal
 * Since: Jan. 6, 2017
 * Name: VendorInvoiceService
 * Description: Service Class for Vendor Invoice (QB Integration)
**/
public with sharing class VendorInvoiceService {
    
    public static Boolean isSyncRecordContainsNonTaxableItem; 
    public static void syncVIHeaders(Set<Id> VIHeaderIds){
        AccSync_VendorInvoice_Batch.runVIHeadersForSync(VIHeaderIds, 10);
    } 
    
    public static List<Log__c> syncAccountingServer(AccountingVendorInvoice vendorInvoiceRecord, List<Vendor_Invoicing_Header__c> VIHeaderListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()) {
            errorLogToInsert = syncToQuickBooks(vendorInvoiceRecord, VIHeaderListToUpdate);
        }
        return errorLogToInsert;
    } 

    public static List<Log__c> syncToQuickBooks(AccountingVendorInvoice vendorInvoiceRecord, List<Vendor_Invoicing_Header__c> VIHeaderListToUpdate){
        Vendor_Invoicing_Header__c VIHeader = new Vendor_Invoicing_Header__c();
        VIHeader.Id = vendorInvoiceRecord.AccountingVIHeaderRec.VIHeaderId;
        isSyncRecordContainsNonTaxableItem = false;
        List<Log__c> errorLogList = new List<Log__c>(); 
        try{
            if(vendorInvoiceRecord.AccountingVIHeaderRec.SyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('bill', vendorInvoiceRecord.AccountingVIHeaderRec.AccountingId);
                if(getResponse.getStatusCode() == 200){ 
                    ResponseQuickBooksVendorInvoice vendorInvoice = (ResponseQuickBooksVendorInvoice)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksVendorInvoice.class);
                    vendorInvoiceRecord.AccountingVIHeaderRec.SyncToken = vendorInvoice.Bill.SyncToken;
                } else {
                    errorLogList.add(new LogService().createErrorLog('VendorInvoiceService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              vendorInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + VIHeaderListToUpdate, LogService.QUICKBOOKS, false));
                }
            }
            QuickBooksVendorInvoice QB_VI = new QuickBooksVendorInvoice(vendorInvoiceRecord);
            String VendorInvoiceJSONBody = system.JSON.serialize(QB_VI);
            system.debug('*************');
            system.debug(VendorInvoiceJSONBody);
            String response = VendorInvoiceJSONBody;
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('bill', VendorInvoiceJSONBody);
            System.debug(res);
            if(res.getStatusCode() == 200){ 
                String resParams = res.getBody();
                ResponseQuickBooksVendorInvoice VendorInvoicePostResponse = (ResponseQuickBooksVendorInvoice)System.JSON.deserialize(resParams, ResponseQuickBooksVendorInvoice.class);
                VIHeader.AccountingId__c = VendorInvoicePostResponse.Bill.Id;
                VIHeader.SyncToken__c = VendorInvoicePostResponse.Bill.SyncToken;
                response += '\n\n'+resParams; 
                VIHeader.availForQBSync__c = false;
                VIHeader.accountingLastSyncTime__c = System.now(); 
            }else{
                response += '\n\n'+res.getBody();
                response += '\n\n'+res.getStatus();
                errorLogList.add(new LogService().createErrorLog('VendorInvoiceService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                              vendorInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + VIHeaderListToUpdate, LogService.QUICKBOOKS, false));
            }
            VIHeader.AccountingResponse__c = QBUtil.truncateString(response, 131072);
        }catch(Exception e){
            VIHeader.availForQBSync__c = true;
            VIHeader.AccountingResponse__c = e.getMessage();
            errorLogList.add(new LogService().createErrorLog('VendorInvoiceService', 'syncToQuickBooks() - exception', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              vendorInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + VIHeaderListToUpdate, LogService.QUICKBOOKS, false));
        }
        if(VIHeaderListToUpdate.size() > QBUtil.MAX_RECORDS_UPDATE_LIMIT){
            AccSync_VendorInvoice_Batch.updateVIHeaders(VIHeaderListToUpdate);
            VIHeaderListToUpdate = new List<Vendor_Invoicing_Header__c>();
        }
        VIHeaderListToUpdate.add(VIHeader); 
        return errorLogList;
    }

     /*
     *   START : Quickbooks VI Journal Entry wrapper
     */
     public class QuickBooksVendorInvoice{
        public String Id;
        public String SyncToken;
        public String DocNumber;  
        public Date TxnDate;
        public List<LineWrapper> Line;
        public VendorRefWrapper VendorRef;
        public AccountRefWrapper APAccountRef;
        public QBTxnTaxDetailWrapper TxnTaxDetail;
        public Decimal TotalAmt;
        public Decimal Balance;
        public String GlobalTaxCalculation;
        
        public QuickBooksVendorInvoice(AccountingVendorInvoice vendorInvoiceRecord) {
            this.Id = vendorInvoiceRecord.AccountingVIHeaderRec.AccountingId;
            this.SyncToken = vendorInvoiceRecord.AccountingVIHeaderRec.SyncToken;
            this.DocNumber = vendorInvoiceRecord.AccountingVIHeaderRec.InvoiceNumber; 
            this.TxnDate = (vendorInvoiceRecord.AccountingVIHeaderRec.InvoiceDate != null) ? vendorInvoiceRecord.AccountingVIHeaderRec.InvoiceDate :
                                    vendorInvoiceRecord.AccountingVIHeaderRec.CreatedDate;
            this.Line = new List<LineWrapper>();
            
            Map<Id, List<AccountingFIFOBucket>> partIdToFIFOBucketMap = new Map<Id, List<AccountingFIFOBucket>>();
            for(AccountingFIFOBucket PartFIFOBucketRec : vendorInvoiceRecord.AccountingPartFIFOBucketList) {
                if(partIdToFIFOBucketMap.containsKey(PartFIFOBucketRec.PartId)) {
                    List<AccountingFIFOBucket> FIFOBucketList = partIdToFIFOBucketMap.get(PartFIFOBucketRec.PartId);
                    FIFOBucketList.add(PartFIFOBucketRec);
                    partIdToFIFOBucketMap.put(PartFIFOBucketRec.PartId, FIFOBucketList);
                } else {
                    List<AccountingFIFOBucket> FIFOBucketList = new List<AccountingFIFOBucket>();
                    FIFOBucketList.add(PartFIFOBucketRec);
                    partIdToFIFOBucketMap.put(PartFIFOBucketRec.PartId, FIFOBucketList);
                }
            }
            
            Decimal RecevingTotalAmt = 0;
            Decimal Variance = 0;
            Decimal Total = 0;
            String description = '';
            Decimal totalQtyOut = 0;

            for(AccountingVendorInvoice.AccountingVIGroup VIGroupRec : vendorInvoiceRecord.AccountingVIGroupsList) {
                totalQtyOut = 0;
                if(QBUtil.isQBTaxCodesEnabled) {
                    this.Line.add(new LineWrapper(VIGroupRec, vendorInvoiceRecord.AccountRef1, vendorInvoiceRecord.AppliedQBTaxCode));
                } else {
                    this.Line.add(new LineWrapper(VIGroupRec, vendorInvoiceRecord.AccountRef1));
                }
                if(VIGroupRec.ReceivingQty != null && VIGroupRec.ReceivingCost != null) {
                    RecevingTotalAmt += VIGroupRec.ReceivingQty * VIGroupRec.ReceivingCost;
                }
                Variance = VIGroupRec.ReceivingCost - VIGroupRec.InvoiceCostMinusDiscount;
                
                description = ''; 
                description += VIGroupRec.ItemDesc;
                
                if(Variance != 0) {
                    Total = VIGroupRec.InvoiceTotalQty * Variance;
                    if(QBUtil.isQBTaxCodesEnabled) {
                        isSyncRecordContainsNonTaxableItem = true;
	                    this.Line.add(new LineWrapper((description + ' Receiving Adjustment'), Total, vendorInvoiceRecord.AccountRef1, QBUtil.nonTaxableCodeAccId));
	                    this.Line.add(new LineWrapper((description + ' Inventory Adjustment'), (Total * -1), VIGroupRec.Inventory_GL, QBUtil.nonTaxableCodeAccId));
                    } else {
                        this.Line.add(new LineWrapper((description + ' Receiving Adjustment'), Total, vendorInvoiceRecord.AccountRef1));
                        this.Line.add(new LineWrapper((description + ' Inventory Adjustment'), (Total * -1), VIGroupRec.Inventory_GL));
                    }
                } /*else if(Variance < 0) {
                    this.Line.add(new LineWrapper((description + ' Receiving Adjustment'), Total, vendorInvoiceRecord.AccountRef1));
                    this.Line.add(new LineWrapper((description + ' Inventory Adjustment'), (Total * -1), VIGroupRec.Inventory_GL));
                } */
                
                if(partIdToFIFOBucketMap.containsKey(VIGroupRec.PartId)) {
                    description += ' pre-sold Cost Adjustment';
                    List<AccountingFIFOBucket> FIFOBucketList = partIdToFIFOBucketMap.get(VIGroupRec.PartId);
                    for(AccountingFIFOBucket PartFIFOBucketRec : FIFOBucketList) {
                        totalQtyOut += PartFIFOBucketRec.QtyOut;
                    }
                }
                if(Variance != 0 && totalQtyOut > 0) {
                    Total = totalQtyOut * Variance;
                    isSyncRecordContainsNonTaxableItem = true;
                    if(QBUtil.isQBTaxCodesEnabled) {
                        this.Line.add(new LineWrapper(description, Total, VIGroupRec.Inventory_GL, QBUtil.nonTaxableCodeAccId));
                        this.Line.add(new LineWrapper(description, (Total * -1), VIGroupRec.COGS_GL, QBUtil.nonTaxableCodeAccId));
                    } else {
                        this.Line.add(new LineWrapper(description, Total, VIGroupRec.Inventory_GL));
                        this.Line.add(new LineWrapper(description, (Total * -1), VIGroupRec.COGS_GL));
                    }
                }
            }
            Decimal totalTaxAmount = vendorInvoiceRecord.AccountingVIHeaderRec.TotalPartSubtotal != null ? vendorInvoiceRecord.AccountingVIHeaderRec.TotalPartSubtotal : 0;
            if(QBUtil.isQBTaxCodesEnabled) {
                for(AccountingVendorInvoice.OtherChargesWrapper otherChargesRec : vendorInvoiceRecord.AccountingOtherChargesList) {
                    if(otherChargesRec.IsTaxable) {
                       totalTaxAmount += otherChargesRec.Cost != null ? otherChargesRec.Cost : 0;
                       this.Line.add(new LineWrapper('Other Charge - ' + otherChargesRec.ItemDesc, otherChargesRec.Cost, otherChargesRec.CategoyRef, vendorInvoiceRecord.AppliedQBTaxCode)); 
                    } else {
                        isSyncRecordContainsNonTaxableItem = true;
                        this.Line.add(new LineWrapper('Other Charge - ' + otherChargesRec.ItemDesc, otherChargesRec.Cost, otherChargesRec.CategoyRef, QBUtil.nonTaxableCodeAccId));
                    }
	                
	            }
            } else {
                for(AccountingVendorInvoice.OtherChargesWrapper otherChargesRec : vendorInvoiceRecord.AccountingOtherChargesList) {
	                this.Line.add(new LineWrapper('Other Charge - ' + otherChargesRec.ItemDesc, otherChargesRec.Cost, otherChargesRec.CategoyRef));
	            }
            }
            this.VendorRef = new VendorRefWrapper(vendorInvoiceRecord.vendor);
            this.TotalAmt = this.Balance = vendorInvoiceRecord.AccountingVIHeaderRec.TotalAmt;
            AccountingVendorInvoice.AccountingPurchaseTax purchaseTax;
            if(QBUtil.isQBTaxCodesEnabled) {
                this.GlobalTaxCalculation = QBUtil.TAX_EXCLUDED;
                Decimal totalTax = (totalTaxAmount * vendorInvoiceRecord.AppliedTaxRate).setScale(2, RoundingMode.HALF_UP);
                List<AccountingVendorInvoice.TaxRateComponent> taxComponentList = new List<AccountingVendorInvoice.TaxRateComponent>();
                if(vendorInvoiceRecord.AccountingPurchaseTaxList.size() > 0) {
                    for(Integer i = 0; i < vendorInvoiceRecord.AccountingPurchaseTaxList.size(); i++) {
                        purchaseTax = vendorInvoiceRecord.AccountingPurchaseTaxList[i];
                        Decimal taxAmount = ((purchaseTax.SalesTaxRate * totalTaxAmount / 100).setScale(2, RoundingMode.HALF_UP));
                        Decimal taxableAmount = totalTaxAmount;
                        Decimal taxPercent = purchaseTax.SalesTaxRate;
                        String purchaseTaxRateAcctId = purchaseTax.QBTaxCodeRef;
                        taxComponentList.add(new AccountingVendorInvoice.TaxRateComponent(taxAmount, taxableAmount, purchaseTaxRateAcctId, taxPercent));
                    }
                } else if(vendorInvoiceRecord.AppliedTaxRate == 0 && String.isNotBlank(vendorInvoiceRecord.AppliedQBTaxCode)) {
                    if(AccessControl.ifObjectFieldIsAccessible('QB_TaxCode__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<QB_TaxCode__c> taxCodeList = [SELECT Applicable_QB_Tax_Rates__c FROM QB_TaxCode__c WHERE Accounting_Id__c = :vendorInvoiceRecord.AppliedQBTaxCode AND Tax_Applicable_On__c =: QBUtil.PURCHASE];
                    if(taxCodeList.size() > 0  && String.isNotBlank(taxCodeList[0].Applicable_QB_Tax_Rates__c)) {
                        List<String> taxRateAccIdList = taxCodeList[0].Applicable_QB_Tax_Rates__c.split(';');
                        for(String taxRateAccId : taxRateAccIdList) {
                            taxComponentList.add(new AccountingVendorInvoice.TaxRateComponent(0, 0, taxRateAccId, 0));
                        }
                    }
                }
                if(isSyncRecordContainsNonTaxableItem) {
                    Map<String, List<String>> nonTaxCodeToRatesMap = QBUtil.getNonTaxableTaxCodeWithRates(QBUtil.PURCHASE);
                    if(nonTaxCodeToRatesMap.containsKey(QBUtil.nonTaxableCodeAccId)) {
                        for(String acctId : nonTaxCodeToRatesMap.get(QBUtil.nonTaxableCodeAccId)) {
                            taxComponentList.add(new AccountingVendorInvoice.TaxRateComponent(0, 0, acctId, 0));
                        }
                    }
                }
                this.TxnTaxDetail = new QBTxnTaxDetailWrapper(totalTax, taxComponentList);  
            } else {
                Decimal taxValue = 0;
                String categoryRef = '';
                this.GlobalTaxCalculation = QBUtil.TAX_NOT_APPLICABLE;
                if(vendorInvoiceRecord.AccountingPurchaseTaxList.size() > 0) {
                    for(Integer i = 0; i < vendorInvoiceRecord.AccountingPurchaseTaxList.size(); i++) {
                        purchaseTax = vendorInvoiceRecord.AccountingPurchaseTaxList[i];
                        Decimal taxAmount = ((purchaseTax.SalesTaxRate * vendorInvoiceRecord.AccountingVIHeaderRec.TotalPartSubtotal / 100).setScale(2, RoundingMode.HALF_UP)) + 
                                   ((purchaseTax.SalesTaxRate * vendorInvoiceRecord.AccountingVIHeaderRec.TotalOtherChargeSubtotal / 100).setScale(2, RoundingMode.HALF_UP));
                        categoryRef = purchaseTax.CategoyRef != null ? purchaseTax.CategoyRef : AccountingUtil.getChartofAccount('Sales Tax');
                        this.Line.add(new LineWrapper('Purchase Tax - ' + purchaseTax.SalesTaxName, taxAmount, categoryRef));
                    }
                }
            }
        }
    }
     
    public class LineWrapper {
        public String Description;
        public Decimal Amount;
        public String DetailType;
        public AccountBasedExpenseLineDetailWrapper AccountBasedExpenseLineDetail;
        
        public LineWrapper(AccountingVendorInvoice.AccountingVIGroup VIGroupRec, AccountingVendorInvoice.AccountRefWrapper AccountRef) {
            this.Description = VIGroupRec.ItemDesc + ' ' + VIGroupRec.InvoiceTotalQty + '@$' + VIGroupRec.InvoiceCost;
            this.Amount = ((VIGroupRec.InvoiceTotalQty * VIGroupRec.InvoiceCost)*((100.00 - VIGroupRec.Discount)/ 100)).setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'AccountBasedExpenseLineDetail';    
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef);   
        }
        
        public LineWrapper(String Description, Decimal Amount, AccountingVendorInvoice.AccountRefWrapper AccountRef) {
            this.Description = Description;
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef);   
        }
         public LineWrapper(AccountingVendorInvoice.AccountingVIGroup VIGroupRec, AccountingVendorInvoice.AccountRefWrapper AccountRef, String taxCodeRefAccountingId) {
            this.Description = VIGroupRec.ItemDesc + ' ' + VIGroupRec.InvoiceTotalQty + '@$' + VIGroupRec.InvoiceCost;
            this.Amount = ((VIGroupRec.InvoiceTotalQty * VIGroupRec.InvoiceCost)*((100.00 - VIGroupRec.Discount)/ 100)).setScale(2, RoundingMode.HALF_UP);
            this.DetailType = 'AccountBasedExpenseLineDetail';    
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef, taxCodeRefAccountingId);   
        }
        
        public LineWrapper(String Description, Decimal Amount, AccountingVendorInvoice.AccountRefWrapper AccountRef, String taxCodeRefAccountingId) {
            this.Description = Description;
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(AccountRef, taxCodeRefAccountingId);   
        }
         public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef) {
            this.Description = Description; 
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef);   
        }
        public LineWrapper(String Description, Decimal Amount, String CategoryAccountRef, String taxCodeRefAccountingId) {
            this.Description = Description; 
            this.Amount = Amount;
            this.DetailType = 'AccountBasedExpenseLineDetail';
            this.AccountBasedExpenseLineDetail = new AccountBasedExpenseLineDetailWrapper(CategoryAccountRef, taxCodeRefAccountingId);   
        }
    }

    public class AccountBasedExpenseLineDetailWrapper {
        public AccountRefWrapper AccountRef;
        public QBInternalEntity TaxCodeRef; //change Wrapper to replace by intrnal entity 
        public AccountBasedExpenseLineDetailWrapper(AccountingVendorInvoice.AccountRefWrapper AccountRef) {
            this.AccountRef = new AccountRefWrapper(AccountRef); 
        }
        public AccountBasedExpenseLineDetailWrapper(AccountingVendorInvoice.AccountRefWrapper AccountRef, String taxCodeRefAccountingId) {
            this.AccountRef = new AccountRefWrapper(AccountRef); 
            this.TaxCodeRef =  String.isNotBlank(taxCodeRefAccountingId) ? new QBInternalEntity(taxCodeRefAccountingId) : null;
        }
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef)  {
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef); 
        }
        public AccountBasedExpenseLineDetailWrapper(String CategoryAccountRef, String taxCodeRefAccountingId)  {
            this.AccountRef = new AccountRefWrapper(CategoryAccountRef);
            this.TaxCodeRef =  String.isNotBlank(taxCodeRefAccountingId) ? new QBInternalEntity(taxCodeRefAccountingId) : null; 
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
        public VendorRefWrapper(AccountingVendorInvoice.VendorWrapper VendorRef) {
            this.value = VendorRef.AccountingId;
            this.name = VendorRef.Name;
        }
     }
     public class QBInternalEntity {
        public String value;
        public QBInternalEntity(String acctId) {
            this.value = acctId;
        }
     }
     public class ResponseQuickBooksVendorInvoice {
        public QuickBooksVendorInvoice Bill;
     }
}