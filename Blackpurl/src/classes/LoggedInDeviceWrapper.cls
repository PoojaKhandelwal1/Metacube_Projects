/** 
* Author: Nidhi Sharma
* Since: Dec 17, 2018
* Name: LoggedInDeviceWrapper 
* Description: Wrapper class for Logged in device object.
**/
public without sharing class LoggedInDeviceWrapper {
    
    public String Id;
    public String UUID;
    public String CashDrawerId;
    public String CashDrawerName;
    
    public LoggedInDeviceWrapper(Logged_In_Device__c loggedInDeviceRec) {
    	this.Id = loggedInDeviceRec.Id;
    	this.UUID = loggedInDeviceRec.Name;
    	this.CashDrawerId = loggedInDeviceRec.Cash_Drawer__c;
    	this.CashDrawerName = loggedInDeviceRec.Cash_Drawer__r.Name;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getLoggedInDeviceFieldsList(){
        List<String> coInvoicePaymentFields = new List<String>{ 'Name',
	                                                        'Cash_Drawer__c',
	                                                        'Cash_Drawer__r.Name'
	                                               		 };
        return coInvoicePaymentFields;
    }
}