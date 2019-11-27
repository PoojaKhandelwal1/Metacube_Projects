/**
 * Author: Tarun Khandelwal
 * Since: August 20, 2018
 * Name: GeneralAccountWrapper
 * Description: Wrapper class for General Account Object
**/
public without sharing class GeneralAccountWrapper {
    
    public String AccountingId;
    public String AccountName;
    public String AccountNumber;
    public String AccountType;
    public String Id;
    public String LastModifiedDate;
    public String AccountInfo;
    
    public GeneralAccountWrapper(General_Account__c generalAccountRec) {
        setDefaultFields(generalAccountRec);
    }
    
    public GeneralAccountWrapper(General_Account__c generalAccountRec, String timeZone){
        setDefaultFields(generalAccountRec);
        if(timeZone != null){
            List<String> timeZoneList = timeZone.split(' ');
            timeZone = '';
            for(String s : timeZoneList){
                if(s.length() > 0){
                    timeZone += s.substring(0,1);
                }
            }
        }
        this.LastModifiedDate = (generalAccountRec.LastModifiedDate != null) ? 
                                BPUtility.getExtendedDateFormat(generalAccountRec.LastModifiedDate) + ' ' + timeZone : '';
    }
    
    private void setDefaultFields(General_Account__c generalAccountRec) {
        this.AccountingId = generalAccountRec.Accounting_Id__c;
        this.AccountName = generalAccountRec.Account_Name__c;
        this.AccountNumber = generalAccountRec.Account_Number__c;
        this.AccountType = generalAccountRec.Account_Type__c;
        this.Id = generalAccountRec.Id;
        this.AccountInfo = '';
        if(this.AccountNumber != null) {
        	this.AccountInfo += this.AccountNumber + ' - ';
        }
        this.AccountInfo += this.AccountName;
    }
    
    public static List<String> getGeneralAccountFields() {
       return new List<String>{'Accounting_Id__c', 
                                'Account_Name__c', 
                                'Account_Number__c',
                                'Account_Type__c', 
                                'LastModifiedDate'
                              };
    } 
}