/**
 * Author: Nidhi Sharma
 * Since: Oct 10, 2017 
 * Name: PrintCashReconciliationCtrl
 * Description: Used to handle all print related work related to Cash Reconciliation
**/
global without sharing class PrintCashReconciliationCtrl {
	
    global PrintCashReconciliationCtrl (NewHomePageCtrl controller){
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    //public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
    public String  dateFormat { get{ return BPUtility.getDateFormat();}private set;}
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    public String reconciledDateStr {get;private set;}
    public String cashDrawerId {get;private set;}
    public CashReconciliationDetail CashReconciliationObj{get; private set;}
    
    public PrintCashReconciliationCtrl() {
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
        /*cashDrawerId = ApexPages.currentPage().getParameters().get('CashDrawerId');
        reconciledDateStr  = ApexPages.currentPage().getParameters().get('ReconciledDate');
        if(String.isBlank(reconciledDateStr)){
            return;
        } else {
	        String reconciliationDetailJSON = getCashReconciliationDetails(BPUtility.getEncodedString(reconciledDateStr), BPUtility.getEncodedString(cashDrawerId));
	        if(String.isNotBlank(reconciliationDetailJSON)) {
                reconciliationDetailJSON = BPUtility.getDecodedString(reconciliationDetailJSON);
                CashReconciliationObj = (ReconciliationWrapper)JSON.deserialize(reconciliationDetailJSON, ReconciliationWrapper.class);
            }
        }*/
    }
    
    @RemoteAction
    global static String getCashReconciliationDetails(String dateStr, String cashDrawerId) {
		dateStr = BPUtility.getDecodedString(dateStr);
    	cashDrawerId = BPUtility.getDecodedString(cashDrawerId);
    	try {
	    	DateTime dtValue = HomeSearchFilterInterface.getDateFromString(dateStr);
	        ReconciliationWrapper reconciliationWrapperObj = CashReconciliationService.getReconciliationDetails(dtValue, cashDrawerId, true);
	        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
	        
	        CashReconciliationDetail reconciliationObj = new CashReconciliationDetail(dtValue, businessProfileList, reconciliationWrapperObj);
	        return BPUtility.getEncodedString(system.JSON.serialize(reconciliationObj));
    	} catch(Exception e) {
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return '{}';
	}
    
     public class CashReconciliationDetail {
     	public String ReconciliationDate{get; private set;}
     	public CustomerDetail.Company CompanyInfo {get; set;}
     	public ReconciliationWrapper ReconciliationObj{get; private set;}
     	
     	public CashReconciliationDetail(DateTime dtValue, List<Business_Profile__c> businessProfileList, ReconciliationWrapper reconciliationWrapperObj) {
     		this.ReconciliationDate = (dtValue != null) ? (dtValue.format('EEEE') + ' ' + dtValue.format('dd MMMM YYYY')) : '';
     		if(businessProfileList.size() > 0) {
                this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
            } else {
                this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
            }
            this.CompanyInfo.BusinessPhone = this.CompanyInfo.FormattedBusinessPhone != null ? this.CompanyInfo.FormattedBusinessPhone: '';
            this.ReconciliationObj = reconciliationWrapperObj;
     	}
     }
}