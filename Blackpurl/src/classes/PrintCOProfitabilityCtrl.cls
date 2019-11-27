global without sharing class PrintCOProfitabilityCtrl {
	
    public PrintCOProfitabilityCtrl() {
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    
    @RemoteAction
    global static String getCOProfitability(String coId) {
        coId = BPUtility.getDecodedString(coId);
        try {
        	ProfitabilityWrapper profitabilityWrapperObj = COService.getCOProfitability(coId); 
        	List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
        	List<CO_Header__c> coHeaderList = [SELECT Customer_Name__c, Name FROM CO_Header__c WHERE Id =: coId];
        	COProfitabilityDetail profitabilityObj = new COProfitabilityDetail(businessProfileList, profitabilityWrapperObj, coHeaderList);
            return BPUtility.getEncodedString(system.JSON.serialize(profitabilityObj));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public class COProfitabilityDetail {
     	public CustomerDetail.Company CompanyInfo {get; set;}
     	public String CustomerName;
     	public String CustomerOrderName;
     	public ProfitabilityWrapper ProfitabilityObj{get; private set;}
     	
     	public COProfitabilityDetail(List<Business_Profile__c> businessProfileList, ProfitabilityWrapper profitabilityWrapperObj, List<CO_Header__c> coHeaderList) {
     		if(businessProfileList.size() > 0) {
                this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
            } else {
                this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
            }
            this.CompanyInfo.BusinessPhone = this.CompanyInfo.FormattedBusinessPhone != null ? this.CompanyInfo.FormattedBusinessPhone: '';
            this.ProfitabilityObj = profitabilityWrapperObj;
            if(coHeaderList.size() > 0) {
             	this.CustomerName = coHeaderList[0].Customer_Name__c;
        		this.CustomerOrderName = coHeaderList[0].Name;
            } 
     	}
     }
}