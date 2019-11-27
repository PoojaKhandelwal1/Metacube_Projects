public without sharing abstract class XeroBaseInvoiceDTO {
    public String SFId;
    public String Type;
    public XeroContactDTO Contact;
    public String InvDate;
    public String DueDate;
    public String Status;
    public String Url;
    public String LineAmountTypes;
    public String InvoiceID;
    public List<XeroLineItemDTO> LineItems; 
    
    public XeroBaseInvoiceDTO() { 
    	this.Status = 'AUTHORISED';
    }
    
    public XeroBaseInvoiceDTO(AccountingCustomerInvoice customerInvoiceRecord) {
    	this.SFId = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderId;
    	if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.InvoiceTotal < 0) {
    		this.Type = 'ACCRECCREDIT';
    	} else {
    		this.Type = 'ACCREC';
    	}
    	this.LineItems = new List<XeroLineItemDTO>();
    	this.Contact = new XeroContactDTO(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.XeroCustomerAccountingId);
    	this.Status = 'AUTHORISED';
    	this.Url = AccountingUtil.getURL(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderId, 'CustomerOrder_V2');
    	if(GeneralConfiguration.getTaxIncludingPricing()) {
    		this.LineAmountTypes = 'Inclusive'; 
    	} else {
    		this.LineAmountTypes = 'Exclusive';
    	}
    	this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceDate, 'yyyy-MM-dd');
    	this.DueDate = DateTimeUtility.getFormttedDateFromDateTime(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceDate, 'yyyy-MM-dd');
    	for(Object lineItemRec : AccountingCustomerInvoiceService.setAllInvoiceItemRec(customerInvoiceRecord)) {
    		this.LineItems.add( (XeroLineItemDTO) lineItemRec);
    	}
    }
    
    
    public XeroBaseInvoiceDTO(AccountingVendorInvoice voInvoice) {
        this.SFId = voInvoice.AccountingVIHeaderRec.VIHeaderId;
        this.Type = 'ACCPAY';
        this.Status = 'AUTHORISED';
        this.LineAmountTypes = 'Exclusive';
        this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(voInvoice.AccountingVIHeaderRec.InvoiceDate, 'yyyy-MM-dd');
        this.DueDate = DateTimeUtility.getFormttedDateFromDateTime(voInvoice.AccountingVIHeaderRec.InvoiceDate, 'yyyy-MM-dd');
        //this.Contact = new Map<String, String>{'ContactID' => voInvoice.vendor.XeroVendorAccountingId};
        this.Contact = new XeroContactDTO(voInvoice.vendor.XeroVendorAccountingId);
        this.Url = AccountingUtil.getURL(voInvoice.AccountingVIHeaderRec.VIHeaderId, 'VendorOrderInvoicing');
        this.LineItems = XeroVendorInvoiceUtility.setAllInvoiceItemRec(voInvoice);
    }
    
     public XeroBaseInvoiceDTO(AccountingVendorReturn vendorReturn) {
        this.SFId = vendorReturn.Id;
        this.Type = 'ACCPAYCREDIT';
        this.Status = 'AUTHORISED';
        this.LineAmountTypes = 'Exclusive';
        this.Contact = new XeroContactDTO(vendorReturn.XeroVendorAccountingId);
        this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(vendorReturn.CreditedDate, 'yyyy-MM-dd');
        this.DueDate = DateTimeUtility.getFormttedDateFromDateTime(vendorReturn.CreditedDate, 'yyyy-MM-dd');
        this.Url = AccountingUtil.getURL(vendorReturn.Id, 'ReturnVO');
        this.LineItems = XeroVendorInvoiceUtility.setAllInvoiceItemRec(vendorReturn);
    }
    
    public XeroBaseInvoiceDTO(AccountingUnit unitRec) {
        this.SFId = unitRec.Id;
        this.Type = 'ACCPAY';
        this.Status = 'AUTHORISED';
        this.LineAmountTypes = 'Exclusive';
        this.Contact = new XeroContactDTO(unitRec.XeroVendorAccountingId);
        this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(DateTimeUtility.getDateTimeFromDate(unitRec.CreatedDate), 'yyyy-MM-dd');
        this.DueDate = DateTimeUtility.getFormttedDateFromDateTime(DateTimeUtility.getDateTimeFromDate(unitRec.CreatedDate), 'yyyy-MM-dd');
        this.Url = AccountingUtil.getURL(unitRec.Id, 'ViewUnit');
        this.LineItems = XeroVendorInvoiceUtility.setAllInvoiceItemRec(unitRec);
    }
}