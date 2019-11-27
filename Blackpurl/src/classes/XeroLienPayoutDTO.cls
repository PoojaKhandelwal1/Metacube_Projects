public with sharing class XeroLienPayoutDTO {
    public String Id;
    public String Type;
    public String InvDate;
    public String DueDate;
    public String InvoiceNumber;
    public String Status;
	public String LineAmountType;
	public List<XeroLineItemDTO> LineItems;
	public XeroContactDTO Contact;
	public String SFId;
	public String Url;
	
    public XeroLienPayoutDTO(AccountingLienPayout accountingLienPayoutRec) {
		this.SFId = accountingLienPayoutRec.Id;
		this.Type= 'ACCPAY';
		this.InvDate = DateTimeUtility.getFormttedDateFromDateTime(accountingLienPayoutRec.InvoiceDate, 'yyyy-MM-dd'); 
		this.DueDate = DateTimeUtility.getFormttedDateFromDateTime(accountingLienPayoutRec.InvoiceDate, 'yyyy-MM-dd'); 
		this.InvoiceNumber = accountingLienPayoutRec.InvoiceNumber;
		this.Status = 'AUTHORISED';
		this.LineAmountType = 'Exclusive';
		this.LineItems = new List<XeroLineItemDTO>{new XeroLineItemDTO(accountingLienPayoutRec)};
		this.Contact = new XeroContactDTO(accountingLienPayoutRec.XeroCustomerAccountingId);
		this.Url = AccountingUtil.getURL(accountingLienPayoutRec.CoHeaderId, 'CustomerOrder_V2');
    }
    
}