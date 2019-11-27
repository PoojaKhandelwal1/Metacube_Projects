public without sharing class XeroCreditNoteDTO extends XeroBaseInvoiceDTO {
    public String CreditNoteNumber;
    public String CreditNoteID;
    
    public XeroCreditNoteDTO(String creditNoteId) {
    	this.CreditNoteID = creditNoteId;
    }
    
    public XeroCreditNoteDTO(AccountingCustomerInvoice customerInvoiceRecord) {
    	super(customerInvoiceRecord);
    	this.CreditNoteNumber = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber;
    }

    public XeroCreditNoteDTO(AccountingVendorReturn vendorReturnRecord) {
        super(vendorReturnRecord);
        this.CreditNoteNumber = vendorReturnRecord.Name;
    }
}