/**
* Author: Pooja Khandelwal
* Since: Mar. 17, 2017
* Name: COAImportCtrl
* Description: Apex class which contains all remoted methods related to COA Import Page.
**/
global with sharing class COAImportCtrl {
  	
  	global COAImportCtrl (NewHomePageCtrl controller){}
    public COAImportCtrl() {}
  	
    
    @RemoteAction
    global static String importCOAFile(String recordJSON) {
      
        recordJSON = BPUtility.getDecodedString(recordJSON);
        decimal sucessCount = 0;
        decimal errorCount = 0;
        decimal newRecords =  0;
       
        List<FieldMapping> recordList = (List<FieldMapping>) System.JSON.deserialize(recordJSON, List<FieldMapping>.class);
        Set<String> accountNumberSet = new Set<String>();
        Set<String> duplicateSet = new Set<String>();
        for(FieldMapping record : recordList) {
            accountNumberSet.add(record.AccountNumber);
        } 
        
        if(AccessControl.ifObjectFieldIsAccessible('General_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<General_Account__c> existingAccountList = [select Id, Accounting_Id__c from General_Account__c where Accounting_Id__c IN: accountNumberSet];
        Map<String, String> accountNumberToAccountIdMap = new Map<String, String>();
        for(General_Account__c accountRec : existingAccountList) {
            accountNumberToAccountIdMap.put(accountRec.Accounting_Id__c, accountRec.Id);
        }
        
        List<General_Account__c> accountRecordListToUpsert = new List<General_Account__c>();
        
        for(FieldMapping record : recordList) {
            try{
            	if(!duplicateSet.contains(record.AccountNumber)){
					General_Account__c accountRec = new General_Account__c();
	                accountRec.Accounting_Id__c =record.AccountNumber;
	                accountRec.Account_Name__c = record.AccountDescription;
	                accountRec.Account_Type__c = record.AccountType;
	                                
	                if(accountNumberToAccountIdMap.containsKey(record.AccountNumber)) {
                		accountRec.Id = accountNumberToAccountIdMap.get(record.AccountNumber);
	                }
	                duplicateSet.add(record.AccountNumber);
	                accountRecordListToUpsert.add(accountRec);
            	}
            }catch(exception ex){
                errorCount++;
            }
        }
        //system.assert(false, accountRecordListToUpsert);
                
        if(AccessControl.ifObjectFieldIsUpdateable('General_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('General_Account__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        Database.UpsertResult [] cr  = Database.upsert(accountRecordListToUpsert ,false);
        
        for(Database.UpsertResult Result : cr){
             if (result.isSuccess()) {
                    if(result.isCreated()){
                        newRecords++;
                    }
                    sucesscount++;
             }else{
                errorcount++;   
             }
        }
        String SuccessCounter = String.valueOf(sucesscount);
        String ErrorCounter = String.valueOf(errorcount);
        String newRecordsCounter = String.valueOf(newRecords);
        return BPUtility.getEncodedString(System.JSON.serialize( new UploadResult(SuccessCounter,ErrorCounter,newRecordsCounter)));
    }

    public class FieldMapping {
        
        public String AccountNumber;
        public String AccountDescription;
        public String AccountType;
        
        public FieldMapping() {
            
        }
    }
    public class UploadResult{
        public String SucessCount;
        public String ErrorCount;
        public string NewRecords;
         public UploadResult( String sucessCount,String errorCount,String newRecords) {
            this.SucessCount = sucessCount;
            this.ErrorCount = errorCount;
            this.newRecords = newRecords;
        }
    }
}