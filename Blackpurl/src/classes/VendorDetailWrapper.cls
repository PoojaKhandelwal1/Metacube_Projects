/**
 * Author: Tarun Khandelwal
 * Since: Aug 02, 2018
 * Name: VendorDetailWrapper
 * Description: Apex class to get vendor data for messaging popup for now - It can be used other places
**/
public class VendorDetailWrapper {
    public String VendorId;
    public String VendorName;
    public String PrefferedEmail;
    public String VendorWorkEmail;
    public String VendorOtherEmail;
    
    public VendorDetailWrapper() {
        
    }
    
    public VendorDetailWrapper(Account vendorRec) {
    	this.VendorId = vendorRec.Id;
    	this.VendorName = vendorRec.Name;
    	this.PrefferedEmail = vendorRec.Preferred_Email__c;
    	this.VendorWorkEmail = vendorRec.Work_Email__c;
    	this.VendorOtherEmail = vendorRec.Other_Email__c;
    }
    
    public static List<String> fieldsList() {
        List<String> vendorFields = new List<String>{ 'Name',
                                                    'Work_Email__c',
                                                    'Preferred_Email__c',
                                                    'Other_Email__c'
                                                };
        return vendorFields;
    }
}