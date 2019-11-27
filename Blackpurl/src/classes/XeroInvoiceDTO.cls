public without sharing class XeroInvoiceDTO extends XeroBaseInvoiceDTO {
    public String InvoiceNumber;
    public String InvoiceID;
    
    public XeroInvoiceDTO(String invoiceId) {
    	this.InvoiceID = invoiceId;
    }
    
    public XeroInvoiceDTO(AccountingCustomerInvoice customerInvoiceRecord) {
    	super(customerInvoiceRecord);
    	this.InvoiceNumber = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber;
    }
    
    public XeroInvoiceDTO(AccountingVendorInvoice voInvoice) {
        super(voInvoice);
        this.InvoiceNumber = voInvoice.AccountingVIHeaderRec.InvoiceNumber;
    }
    
    public XeroInvoiceDTO(AccountingUnit unitInvoiceRecord) {
        super(unitInvoiceRecord);
        this.InvoiceNumber = unitInvoiceRecord.InvoiceNumber;
    }
}