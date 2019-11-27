public with sharing class XeroInvoicePaymentDTO {
    public String PaymentID;
    public String Type;
    public XeroInvoiceDTO Invoice;
    public XeroCreditNoteDTO CreditNote;
    public XeroAccountDTO Account;
    public String InvDate;
    public Decimal Amount;
    public String Reference;
    public String Status;
    
    public XeroInvoicePaymentDTO(AccountingCustomerInvoice customerInvoiceRecord, CO_Invoice_Header__c coInvoiceRecObj) {
        this.Account = new XeroAccountDTO(AccountingUtil.getChartofAccount('Customer Deposits'));
        this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceDate, 'yyyy-MM-dd');
        this.Amount = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.totalPaymentExcludingChargeAccount;
        this.Reference = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber +
        					';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.customer.Name +
        					';' + customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderNumber +
        					';';
        if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal < 0) {
            this.Type = 'CreditNote';
            this.CreditNote = new XeroCreditNoteDTO(coInvoiceRecObj.Xero_Accounting_Id__c);
            this.Reference += 'Refund';
			this.Amount *= -1;
        } else {
            this.Type = 'Invoice';
            this.Invoice = new XeroInvoiceDTO(coInvoiceRecObj.Xero_Accounting_Id__c);
            this.Reference += 'Payment';
        }
        this.Status = 'AUTHORISED';
   
    }
}
