/**
 * Author: Tarun Khandelwal
 * Since: March 31, 2017
 * Name: BarcodePrintCtrl
 * Description: Controller Class of BarcodePrint Page.
**/
global with sharing class BarcodePrintCtrl {
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    
    global BarcodePrintCtrl(NewHomePageCtrl controller){}
    
    public BarcodePrintCtrl() {
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    @RemoteAction
    global static String getBarcodeInfo(String partId) {
        try {
            partId = BPUtility.getDecodedString(partId);
            List<Part__c> parts = SOQLUtil.getPartDetailRecordsByFieldName('Id', partId);
            if(parts.size() == 0) {
                return '{}';
            }
            List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
            return BPUtility.getEncodedString(System.JSON.serialize(new BarcodeInfoWrapper(parts[0], businessProfileList)));  
        } catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('');
        }
    }
    
    @RemoteAction
    global static String getBarcodeLabelTemplate(String templateName) {
        try {
            List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
            return BPUtility.getEncodedString(System.JSON.serialize(new BarcodeInfoWrapper(businessProfileList)));
        } catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('');
        }
    }
    
    @RemoteAction
    global static String saveBarcodeLabelTemplate(String templateXml) {
        if(AccessControl.ifObjectFieldIsUpdateable('Business_Profile__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        try {
            List<Business_Profile__c> businessProfiles = SOQLUtil.getBusinessProfileData(new List<id>());
            if(businessProfiles.size() > 0) {
                Business_Profile__c businessProfileRec =  businessProfiles[0];
                businessProfileRec.Part_Label_Template__c = BPUtility.getDecodedString(templateXml);
                update businessProfileRec;
            }
            return BPUtility.getEncodedString('SUCCESS');
        } catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('ERROR');
        }
    }
    
    public class BarcodeInfoWrapper {
        public String PartId;
        public String Id;
        public String Description;
        public Decimal RetailPrice;
        public CustomerDetail.Company CompanyInfo;
        public String labelTemplateXml;
        
        public BarcodeInfoWrapper(Part__c partRec, List<Business_Profile__c> businessProfileList) {
            this.PartId = partRec.Part_ID__c;
            this.Description = partRec.Description__c;
            this.RetailPrice = (partRec.Retail_Price__c != null) ? partRec.Retail_Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.Id = partRec.Id;
            if(businessProfileList.size() > 0) {
                this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
            } else {
                this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
            }
        }
        
        public BarcodeInfoWrapper(List<Business_Profile__c> businessProfileList) {
            if(!businessProfileList.isEmpty()) {
                this.labelTemplateXml = businessProfileList[0].Part_Label_Template__c;
            }
        }
        
    }
}