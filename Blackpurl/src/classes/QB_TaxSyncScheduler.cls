global with sharing class QB_TaxSyncScheduler implements Schedulable {
    
    global String syncType;
    global QB_TaxSyncScheduler() {}
    global QB_TaxSyncScheduler(String syncType){
        this.syncType = syncType;
    }
    
    global void execute(SchedulableContext sc) {
        
    }
    /*
    global void execute(SchedulableContext sc) {
        if(this.syncType == 'TaxAgency'){
            syncTaxAgency();
        }else if(this.syncType == 'TaxCode'){
            syncTaxCode();
        }
    }
    
    @future(callout=true)
    private static void syncTaxAgency() {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        Boolean isValidTaxAgency = checkForTaxAgency(qbConfig);
        if(!isValidTaxAgency) {
            String taxAgencyName = qbConfig.Tax_Agency_Name__c != null ? qbConfig.Tax_Agency_Name__c : 'BP Tax Agency';
            DisplayNameWrapper taxAgencyObj = new DisplayNameWrapper(taxAgencyName);
            String taxAgencyJSONStr = system.JSON.serialize(taxAgencyObj);
            HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('taxagency', taxAgencyJSONStr);
            if(res.getStatusCode() == 200) {
                TaxAgencyWrapper taxAgencyResObj = (TaxAgencyWrapper)system.JSON.deserialize(res.getBody(), TaxAgencyWrapper.class);
                if(taxAgencyResObj.TaxAgency.Id != null){
                    qbConfig.Tax_Agency_Id__c = taxAgencyResObj.TaxAgency.Id;
                    qbConfig.Tax_Agency_Name__c = taxAgencyResObj.TaxAgency.DisplayName;
                    qbConfig.Tax_Agency_Sync_Response__c = null;
                    upsert qbConfig;
                }
                scheduleTaxCode();
            } else if(res.getStatusCode() == 400) {
                TaxAgencyError taxAgencyErrObj = (TaxAgencyError)System.JSON.deserialize(res.getBody(), TaxAgencyError.class);
                qbConfig.Tax_Agency_Sync_Response__c = (taxAgencyErrObj.Fault != null && taxAgencyErrObj.Fault.Error.size() > 0 && taxAgencyErrObj.Fault.Error[0].Detail != null) ? 
                            ((taxAgencyErrObj.Fault.Error[0].Detail.length() > 255) ? taxAgencyErrObj.Fault.Error[0].Detail.subString(0, 255) : taxAgencyErrObj.Fault.Error[0].Detail): 
                            ((res.getBody().length() > 255) ? res.getBody().subString(0, 255) : res.getBody());
                upsert qbConfig;
            } else {
                qbConfig.Tax_Agency_Sync_Response__c = (res.getBody().length() > 255) ? res.getBody().subString(0, 255) : res.getBody();
            }
        } else {
            scheduleTaxCode();
        }
    }
    
    private static void scheduleTaxCode() {
        String cronExp = QBUtil.getCronExpForGivenTime(59);
        QBUtil.abortAlreadyScheduleJobs('Tax Code Job');
        system.schedule('Tax Code Job', cronExp, new QB_TaxSyncScheduler('TaxCode'));
    }
    
    @future(callout=true)	
    public static void syncTaxCode() {
        List<Sales_Tax_Item__c> salesTaxList = [SELECT Name__c, Rate__c, AccountingId__c FROM Sales_Tax_Item__c WHERE Active__c = true];
        syncToQuickBooks(salestaxList);
    }
    
    
    public static void syncToQuickBooks(List<Sales_Tax_Item__c> salesTaxList) {
    	QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
    	
    	// Getting Tax rate from QB
    	Map<String, String> taxRateNameToIdMap = getTaxRateFromQB(qbConfig);
    	
    	// Setting Tax rate to BP from QB Rate
    	Map<String, Sales_Tax_Item__c> salesTaxNameToRecMap = setTaxRateToBP(taxRateNameToIdMap, salesTaxList);
    	
    	// Get Tax Code
    	Map<String, String> taxCodeNameToIdMap = getTaxCodeFromQB(qbConfig);
        
        // Insert BP Tax Code - based on QB Version
        List<QB_TaxCodeService.TaxCodeWrapper> taxCodeWrapperList = QB_TaxCodeService.getTaxCodeCombination();
        
        // Setting Tax Code to BP from QB Rate
        taxCodeWrapperList = setTaxCodeToBP(taxCodeNameToIdMap, taxCodeWrapperList);
        
        // Sync Remaining Tax Code
        for(QB_TaxCodeService.TaxCodeWrapper taxCodeWrapperRec : taxCodeWrapperList) {
            QB_TaxCode__c taxCodeRec = taxCodeWrapperRec.QBTaxCodeRec;
            if(String.isBlank(taxCodeRec.Accounting_Id__c)) {
                syncTaxCodeToQB(qbConfig, taxCodeWrapperRec, salesTaxNameToRecMap);
            } else {
                taxCodeRec.Tax_Code_Sync_Response__c = 'Already Synced. No Need to sync Again.';
            }
        }
        if(salesTaxNameToRecMap.size() > 0) {
            update salesTaxNameToRecMap.values();
        }  
        
        deleteExistingQBTaxCode();
        insertQBTaxCode(taxCodeWrapperList);
    }
    
    private static void deleteExistingQBTaxCode() {
        List<QB_TaxCode__c> existingQBCodeList = [Select Id from QB_TaxCode__c];
        if(existingQBCodeList.size() > 0) {
            delete existingQBCodeList;
        }
    }
    
    private static void insertQBTaxCode(List<QB_TaxCodeService.TaxCodeWrapper> taxCodeWrapperList) {
        List<QB_TaxCode__c> qbTaxCodeList = new List<QB_TaxCode__c>();
        for(QB_TaxCodeService.TaxCodeWrapper taxCodeWrapperRec : taxCodeWrapperList) {
            qbTaxCodeList.add(taxCodeWrapperRec.QBTaxCodeRec);
        }
        upsert qbTaxCodeList;
    }
    
    private static List<QB_TaxCodeService.TaxCodeWrapper> setTaxCodeToBP(Map<String, String> taxCodeNameToIdMap, 
                                                          List<QB_TaxCodeService.TaxCodeWrapper> taxCodeWrapperList) {
        for(QB_TaxCodeService.TaxCodeWrapper taxCodeWrapperRec : taxCodeWrapperList) {
            taxCodeWrapperRec.QBTaxCodeRec.Accounting_Id__c = taxCodeNameToIdMap.containsKey(taxCodeWrapperRec.QBTaxCodeRec.Name) ? 
                                        taxCodeNameToIdMap.get(taxCodeWrapperRec.QBTaxCodeRec.Name) : null;
        }
        return taxCodeWrapperList;
    }
    
    private static Map<String, Sales_Tax_Item__c> setTaxRateToBP(Map<String, String> taxRateNameToIdMap, List<Sales_Tax_Item__c> salesTaxList) {
        Map<String, Sales_Tax_Item__c> salesTaxNameToRecMap = new Map<String, Sales_Tax_Item__c>();
        for(Sales_Tax_Item__c salesTaxItemRec : salesTaxList) {
            salesTaxItemRec.AccountingId__c = taxRateNameToIdMap.containsKey(Constants.TAX_CODE_PREFIX_FOR_QB + salesTaxItemRec.Name__c) ? 
                                      taxRateNameToIdMap.get(Constants.TAX_CODE_PREFIX_FOR_QB + salesTaxItemRec.Name__c) : null;
            salesTaxNameToRecMap.put(salesTaxItemRec.Name__c, salesTaxItemRec);
        }
        return salesTaxNameToRecMap;
    }
    
    
    private static Map<String, String> getTaxRateFromQB(QuickBooks_Configurations__c qbConfig) {
        String query = 'SELECT Id, Name FROM TaxRate';
        query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('query?query='+query, null);
        
        Map<String, String> taxRateNameToIdMap = new Map<String, String>();
        if(res.getStatusCode() == 200) {
            QueryResponseWrapper taxRateResponseObj = (QueryResponseWrapper)System.JSON.deserialize(res.getBody(), QueryResponseWrapper.class);
            if(taxRateResponseObj != null && taxRateResponseObj.QueryResponse != null && taxRateResponseObj.QueryResponse.TaxRate != null){
                for(TaxRateWrapper taxRateItemObj : taxRateResponseObj.QueryResponse.TaxRate){
                    taxRateNameToIdMap.put(taxRateItemObj.Name, taxRateItemObj.Id);
                }
            }
        } else if(res.getStatusCode() == 400) {
            //TaxAgencyError taxAgencyErrObj = (TaxAgencyError)System.JSON.deserialize(res.getBody(), TaxAgencyError.class);
            qbConfig.Tax_Code_Sync_Response__c = res.getBody();
            upsert qbConfig;
        }
        
        return taxRateNameToIdMap;
    }
    
    private static Map<String, String> getTaxCodeFromQB(QuickBooks_Configurations__c qbConfig) {
        String query = 'SELECT Id, Name FROM TaxCode';
        query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('query?query='+query, null);
        
        Map<String, String> taxCodeNameToIdMap = new Map<String, String>();
        if(res.getStatusCode() == 200) {
            TaxCodeQueryResponseWrapper taxCodeResponseObj = (TaxCodeQueryResponseWrapper)System.JSON.deserialize(res.getBody(), TaxCodeQueryResponseWrapper.class);
            if(taxCodeResponseObj != null && taxCodeResponseObj.QueryResponse != null && taxCodeResponseObj.QueryResponse.TaxCode != null){
                for(TaxCodeWrapper taxCodeObj : taxCodeResponseObj.QueryResponse.TaxCode){
                    taxCodeNameToIdMap.put(taxCodeObj.Name, taxCodeObj.Id);
                }
            }
        } else if(res.getStatusCode() == 400) {
            qbConfig.Tax_Code_Sync_Response__c = res.getBody();
        }
        
        return taxCodeNameToIdMap;
    }
    
    // Send Request to create new tax code and Tax Rates
    private static void syncTaxCodeToQB(QuickBooks_Configurations__c qbConfig, QB_TaxCodeService.TaxCodeWrapper taxCodeWrapperRec, 
                                        Map<String, Sales_Tax_Item__c> salesTaxNameToRecMap) {
        QBTaxCodeWrapper QBTaxCodeObj = new QBTaxCodeWrapper(taxCodeWrapperRec, qbConfig.Tax_Agency_Id__c);  
        system.debug('Richa  -< ' + QBTaxCodeObj);
        String QBTaxCodeJSONBody = system.JSON.serialize(QBTaxCodeObj);
        HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('taxservice/taxcode', QBTaxCodeJSONBody);
        
        QB_TaxCode__c taxCodeRec = taxCodeWrapperRec.QBTaxCodeRec;
        taxCodeRec.Tax_Code_Sync_Response__c = QBTaxCodeJSONBody + '\n\n';
        
        if(res.getStatusCode() == 200) {
            QBTaxCodeWrapper taxCodeObj = (QBTaxCodeWrapper)System.JSON.deserialize(res.getBody(), QBTaxCodeWrapper.class);
            taxCodeRec.Tax_Code_Sync_Response__c += res.getBody();
            taxCodeRec.Accounting_Id__c = taxCodeObj.TaxCodeId;
            
            if(taxCodeObj.TaxRateDetails != null) {
                for(QBTaxRateWrapper taxRateObj : taxCodeObj.TaxRateDetails) {
                    if(taxRateObj != null && salesTaxNameToRecMap.containsKey(Constants.TAX_CODE_PREFIX_FOR_QB + taxRateObj.TaxRateName) 
                                        && String.isNotBlank(taxRateObj.TaxRateId)) {
                        salesTaxNameToRecMap.get(Constants.TAX_CODE_PREFIX_FOR_QB + taxRateObj.TaxRateName).AccountingId__c = taxRateObj.TaxRateId;
                    }
                }
            }
        } else {
            taxCodeRec.Tax_Code_Sync_Response__c += res.getBody();
        }
    }
    
    private static Boolean checkForTaxAgency(QuickBooks_Configurations__c qbConfig) {
        Boolean isValidTaxAgency = false;
        String taxAgencyName = qbConfig.Tax_Agency_Name__c != null ? qbConfig.Tax_Agency_Name__c : 'BP Tax Agency';
        String query = 'SELECT Id, Name FROM TaxAgency WHERE Name = \'' + taxAgencyName + '\'';
        query = EncodingUtil.urlEncode(query, 'UTF-8').replaceAll('\\+','%20');
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('query?query='+query, null);
        if(res.getStatusCode() == 200) {
            TaxAgencyQueryResponseWrapper taxAgencyRes = (TaxAgencyQueryResponseWrapper)System.JSON.deserialize(res.getBody(), TaxAgencyQueryResponseWrapper.class);
            if(taxAgencyRes.QueryResponse != null && taxAgencyRes.QueryResponse.TaxAgency != null && 
                    taxAgencyRes.QueryResponse.TaxAgency.size() > 0 && taxAgencyRes.QueryResponse.TaxAgency[0].Id != null) {
                isValidTaxAgency = true;
                qbConfig.Tax_Agency_Id__c = taxAgencyRes.QueryResponse.TaxAgency[0].Id;
                qbConfig.Tax_Agency_Name__c = taxAgencyRes.QueryResponse.TaxAgency[0].DisplayName;
                upsert qbConfig;
            }
        }
        return isValidTaxAgency;
    }
    
    public class DisplayNameWrapper {
        public String DisplayName;  
        public DisplayNameWrapper(String displayName) {
            this.DisplayName = displayName;
        }
    }
    
    
    public class QBTaxCodeWrapper {
        public String TaxCode;
        public String TaxCodeId; 
        public List<QBTaxRateWrapper> TaxRateDetails;
        
        public QBTaxCodeWrapper(QB_TaxCodeService.TaxCodeWrapper taxCodeWrapperRec, String taxAgencyId) {
            this.TaxCode = taxCodeWrapperRec.QBTaxCodeRec.Name;
            this.TaxCodeId = taxCodeWrapperRec.QBTaxCodeRec.Accounting_Id__c;
            this.TaxRateDetails = new List<QBTaxRateWrapper>();
            for(Sales_Tax_Item__c salesTaxItemRec : taxCodeWrapperRec.SalesTaxItemList) {
                this.TaxRateDetails.add(new QBTaxRateWrapper(salesTaxItemRec, taxAgencyId));
            }
        }
    }
    
    public class QBTaxRateWrapper {
        public String TaxRateName;
        public String TaxRateId; 
        public String RateValue; 
        public String TaxAgencyId;
        
        public QBTaxRateWrapper(Sales_Tax_Item__c salesTaxItemRec, String taxAgencyId) {
            this.TaxRateId = salesTaxItemRec.AccountingId__c;
            this.RateValue = String.valueOf(salesTaxItemRec.Rate__c);
            this.TaxRateName = Constants.TAX_CODE_PREFIX_FOR_QB + salesTaxItemRec.Name__c;
            this.TaxAgencyId = taxAgencyId;
        }
    }
    
    public class TaxAgencyQueryResponseWrapper {
        public TaxAgencyListWrapper QueryResponse;
    }
     
    public class TaxAgencyListWrapper {
        public List<TaxAgency> TaxAgency;
    }
     
    public class TaxAgencyWrapper {
        public TaxAgency TaxAgency;
    }
    
    public class TaxAgency {
        public String Id;
        public String DisplayName;
    }
    
    public class TaxAgencyError {
        public TaxAgencyErr Fault;
    }
    
    public class TaxAgencyErr {
        public List<ErrorWrapper> Error;
    }
    
    public class ErrorWrapper {
        public String Message;
        public String Detail;
        public String code;
    }
    
    public class QueryResponseWrapper{
        public TaxRateQueryResponseWrapper QueryResponse;
    }
    
    public class TaxRateQueryResponseWrapper{
        public List<TaxRateWrapper> TaxRate;
        
    }
    
    public class TaxRateWrapper{
        public String Name;
        public String Id;
        
    }
    
    public class TaxCodeQueryResponseWrapper {
        public TaxCodeListWrapper QueryResponse;
    }
    
    public class TaxCodeListWrapper{
        public List<TaxCodeWrapper> TaxCode;
    }
    public class TaxCodeWrapper{
        public String Name;
        public String Id;
        
    }*/
}