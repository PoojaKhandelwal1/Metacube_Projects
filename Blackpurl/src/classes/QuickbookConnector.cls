/* ###########################################################################
//
//    Class: QuickbooksConnector
//
/* ###########################################################################*/
global with sharing class QuickbookConnector {
    
    public static String Consumer_Key; // 'qyprdFawAAiD3SLud6d5RvREaVOoAn'; //Consumer_Key__c
    public static String Request_Token_URL = 'https://oauth.intuit.com/oauth/v1/get_request_token';
    public static String Consumer_Secret; // 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr'; //Consumer_Secret__c
    public static String Temporary_Token_Secret; // ''; //Temporary_Token_Secret__c
    public static String OAuth_Token; // 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj'; //OAuth_Token__c
    public static String Access_Token_URL; // '';
    public static String OAuth_Token_Secret; // 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO'; //OAuth_Token__c
    public static String CompanyId; // CompanyId
    public static String End_Point_URL;
    public static Integer Request_Timeout_In_MiliSec = Integer.valueOf((QuickBooks_Configurations__c.getOrgDefaults().Request_Timeout__c != null ? QuickBooks_Configurations__c.getOrgDefaults().Request_Timeout__c : 10)*1000);
	public static final Integer QUICKBOOKS_MAX_RETRY_COUNT = 2;
/*=============================================================================
//
//    Function: generateHeader    
//
/*=============================================================================*/
    public static String generateHeader(String signature, Map<String,String> parameters) {
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header + key + '="'+parameters.get(key)+'", ';
        }
        return header + 'oauth_signature="' + signature + '"';
    }
    
    
/*=============================================================================
//
//    Function: generateSignature    
//
/*=============================================================================*/
    public static String generateSignature(HttpRequest req, String consumerSecret, String tokenSecret, Map<String,String> parameters) {
        String s    = createBaseString(req, parameters);         
        String key  = consumerSecret+'&'+tokenSecret;
        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s), Blob.valueOf(key));
        String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        return signature;
    }
    
/*=============================================================================
//
//    Function: createBaseString    
//
/*=============================================================================*/
    private static String createBaseString(HttpRequest req, Map<String,String> parameters) {
        Map<String,String> p = parameters.clone();
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
 
        return req.getMethod().toUpperCase()+ '&' +
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
    
/*=============================================================================
//
//    Function: getUrlParams    
//
/*=============================================================================*/
    private static Map<String,String> getUrlParams(String value) {
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            System.debug('getUrlParams: '+s);
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                // RFC 5849 section 3.4.1.3.1 and 3.4.1.3.2 specify that parameter names 
                // and values are decoded then encoded before being sorted and concatenated
                // Section 3.6 specifies that space must be encoded as %20 and not +
                String encName = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[0], 'UTF-8'), 'UTF-8').replace('+','%20');
                String encValue = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[1], 'UTF-8'), 'UTF-8').replace('+','%20');
                System.debug('getUrlParams:  -> '+encName+','+encValue);
                res.put(encName,encValue);
            }
        }
        return res;
    }
    
/*=============================================================================
//
//    Function: parseResponse    
//
/*=============================================================================*/
    private static Map<String,String> parseResponse(HttpResponse res) {
        Map<String,String> responseMap = new Map<String,String>();
        if(res.getStatusCode() == 200){
            String resParams = res.getBody();
            responseMap.put('responseBody', resParams);
            //responseMap.put('responseCode', res.getStatusCode());
        }else{
            responseMap.put('responseBody', res.getStatus());
            //responseMap.put('responseCode', res.getStatusCode());
        }
        return responseMap;
    }
    
    public static HttpResponse sendRequestToQuickBooks(String objectType, String requestBody){
        System.debug('***************-------------') ;
        getQuickBooksConfigurations();
        //String companyId = '123145730762509';
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        String APIURL = End_Point_URL+CompanyId+'/'+objectType; // 'https://sandbox-quickbooks.api.intuit.com/v3/company/'
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', EncodingUtil.urlEncode(OAuth_Token, 'UTF-8'));
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(APIURL);
        req.setMethod('POST'); 
        req.setTimeout(Request_Timeout_In_MiliSec); 
        req.setBody(requestBody);
        
        String signature = generateSignature(req, Consumer_Secret, OAuth_Token_Secret, parameters);
        String header = generateHeader(signature, parameters);
        
        req.setHeader('Authorization', header);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        Http http = new Http();
        if(Test.isRunningTest()){
            res = new HttpResponse();
            //res.setStatusCode(200);
            //System.assert(false, objectType.equals('customer'));
            res.setHeader('Content-Type', 'application/json');
            if(objectType == 'customer') {
                res.setBody('{"Customer":{"Taxable":true,"BillAddr":{"Id":"267","Line1":"Metacube Software1 Pvt Ltd1","Line2":"Sp-6, Phase-IVI","City":"Ontario-city1","Country":"Canada","CountrySubDivisionCode":"Ontario","PostalCode":"302044"},"ShipAddr":{"Id":"268","Line1":"Metacube22 Software Pvt Ltd22","Line2":"IT-5, Phase-IV2","City":"AlabanaCity2","Country":"USA","CountrySubDivisionCode":"Alabama","PostalCode":"30203322"},"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","domain":"QBO","sparse":false,"Id":"149","SyncToken":"8","MetaData":{"CreateTime":"2016-12-15T04:16:45-08:00","LastUpdatedTime":"2016-12-19T22:42:20-08:00"},"GivenName":"CustomerQuickbook","FamilyName":"QB","FullyQualifiedName":"CustomerQuickbook QB CTM-0000018","CompanyName":"CustomerQuickbook QB","DisplayName":"CustomerQuickbook QB CTM-0000018","PrintOnCheckName":"CustomerQuickbook QB","Active":true,"PrimaryPhone":{"FreeFormNumber":"1412771716"},"AlternatePhone":{"FreeFormNumber":"8000000008"},"Mobile":{"FreeFormNumber":"8000000008"},"PrimaryEmailAddr":{"Address":"quickbook@dddddqb.com"},"DefaultTaxCodeRef":{"value":"2"}},"time":"2016-12-19T22:42:20.082-08:00"}');
            } else if(objectType == 'vendor') {
                res.setBody('{"Vendor":{"BillAddr":{"Id":"296","Line1":"Metacube software Pvt ltd","Line2":"SP-6, Phase-IV","City":"Black River-City","Country":"Mauritius","CountrySubDivisionCode":"Black River","PostalCode":"111111111"},"Balance":0,"AcctNum":"VendorQuickBook1/ACQB1","Vendor1099":false,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"domain":"QBO","sparse":false,"Id":"170","SyncToken":"0","MetaData":{"CreateTime":"2016-12-20T23:46:16-08:00","LastUpdatedTime":"2016-12-20T23:46:16-08:00"},"CompanyName":"VendorQuickBook1","DisplayName":"VendorQuickBook1 VDR-0012","PrintOnCheckName":"VendorQuickBook1","Active":true,"PrimaryPhone":{"FreeFormNumber":"1111111111"},"AlternatePhone":{"FreeFormNumber":"2222222222"},"Mobile":{"FreeFormNumber":"2222222222"},"Fax":{"FreeFormNumber":"3333333333"},"PrimaryEmailAddr":{"Address":"vendorquickbook1@metacube.com"},"WebAddr":{"URI":"http://www.metacube.com"}},"time":"2016-12-20T23:46:15.902-08:00"}');
            } else if(objectType == 'item?minorversion=4')  {
                res.setBody('{"Item":{"Name":"Category Unique1 [Labour]","Description":"Category Unique1","Active":true,"FullyQualifiedName":"Category Unique1 [Labour]","Taxable":false,"UnitPrice":0,"Type":"Service","IncomeAccountRef":{"value":"79","name":"Sales of Product Income"},"PurchaseCost":0,"ExpenseAccountRef":{"value":"80","name":"Cost of Goods Sold"},"TrackQtyOnHand":false,"domain":"QBO","sparse":false,"Id":"82","SyncToken":"2","MetaData":{"CreateTime":"2016-12-26T04:12:34-08:00","LastUpdatedTime":"2016-12-26T04:13:17-08:00"}},"time":"2016-12-26T04:13:17.367-08:00"}');                   
            } else if(objectType == 'salesreceipt') {
                res.setBody('{"SalesReceipt":{"domain":"QBO","sparse":false,"Id":"1075","SyncToken":"0","MetaData":{"CreateTime":"2017-07-28T00:25:54-07:00","LastUpdatedTime":"2017-07-28T00:25:54-07:00"},"CustomField":[],"DocNumber":"INV-00000134","TxnDate":"2017-07-28","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","LineNum":1,"Description":"Part_2106 - test part","Amount":15.23,"DetailType":"SalesItemLineDetail","SalesItemLineDetail":{"ItemRef":{"value":"1","name":"Services"},"UnitPrice":15.23,"Qty":1,"TaxCodeRef":{"value":"TAX"}}},{"Amount":15.23,"DetailType":"SubTotalLineDetail","SubTotalLineDetail":{}}],"TxnTaxDetail":{"TxnTaxCodeRef":{"value":"28"},"TotalTax":2.13,"TaxLine":[{"Amount":1.07,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"27"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}},{"Amount":1.06,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"28"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}}]},"CustomerRef":{"value":"209","name":"QB Test 1 CTM-0032699"},"BillAddr":{"Id":"354","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"ShipAddr":{"Id":"355","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"TotalAmt":17.36,"ApplyTaxAfterDiscount":false,"PrintStatus":"PrintComplete","EmailStatus":"NotSet","Balance":0,"DepositToAccountRef":{"value":"4","name":"1001 Undeposited Funds"}},"time":"2017-07-28T00:25:53.894-07:00"}');                   
            } else if(objectType == 'journalentry') {
                res.setBody('{"JournalEntry":{"Adjustment":false,"domain":"QBO","sparse":false,"Id":"675","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T21:39:37-08:00","LastUpdatedTime":"2017-01-17T21:39:37-08:00"},"DocNumber":"PBN-00000311","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"PrivateNote":"QB Part1;Part Created","Line":[{"Id":"0","Description":"QB Part1 - increased by 100.0@$100.0","Amount":10000.00,"DetailType":"JournalEntryLineDetail","JournalEntryLineDetail":{"PostingType":"Credit","Entity":{"Type":"Vendor","EntityRef":{"value":"178","name":"QB Vendor VDR-0014"}},"AccountRef":{"value":"128","name":"A/P Accrual - Inventory"}}},{"Id":"1","Description":"QB Part1 - increased by 100.0@$100.0","Amount":10000.00,"DetailType":"JournalEntryLineDetail","JournalEntryLineDetail":{"PostingType":"Debit","AccountRef":{"value":"81","name":"Inventory Asset"}}}],"TxnTaxDetail":{}},"time":"2017-01-17T21:39:37.529-08:00"}');
            } else if(objectType == 'bill') {
                res.setBody('{"Bill":{"DueDate":"2017-01-18","Balance":180.00,"domain":"QBO","sparse":false,"Id":"689","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T22:30:55-08:00","LastUpdatedTime":"2017-01-17T22:30:55-08:00"},"DocNumber":"VI-0000019","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"QB Part1 - QB Part1 1.00@$200.00","Amount":180.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"QB Part1 - QB Part1 Receiving Adjustment","Amount":-80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"QB Part1 - QB Part1 Inventory Adjustment","Amount":80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"81","name":"Inventory Asset"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"178","name":"QB Vendor VDR-0014"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":180.00},"time":"2017-01-17T22:30:55.871-08:00"}');
            } else if(objectType == 'vendorcredit') {
                res.setBody('{"VendorCredit":{"domain":"QBO","sparse":false,"Id":"6746","SyncToken":"0","MetaData":{"CreateTime":"2018-06-07T02:38:27-07:00","LastUpdatedTime":"2018-06-07T02:38:27-07:00"},"DocNumber":"CreditMemoNumber-1234","TxnDate":"2018-06-07","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 1.00@$0.00","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"140","name":"201 BP Accrued Inventory Payable"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 Receiving Adjustment","Amount":-21345.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"139","name":"430 BP Inventory Adjustments"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 Inventory Adjustment","Amount":21345.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"140","name":"201 BP Accrued Inventory Payable"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"4","Description":"Purchase Tax - GST R 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"174","name":"4300 BP Labor Sales"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"5","Description":"Purchase Tax - Combi 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"164","name":"1311 BP Used Unit Inventory"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"6","Description":"Purchase Tax - Local Tax R 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"173","name":"4200 BP Parts Sales"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"7","Description":"Purchase Tax - PST R1 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"79","name":"Sales of Product Income"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"1433","name":"01062018 QBVen3 VDR-0172"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":0},"time":"2018-06-07T02:38:27.930-07:00"}');
            } else if(objectType == 'taxagency') {
            	res.setBody('{"TaxAgency":{"DisplayName":"Test Agency new"}}');
            } else if(objectType == 'taxservice/taxcode') {
            	res.setBody('{"TaxRateDetails":[{"TaxRateName":"BP Test tax0","TaxRateId":null,"TaxAgencyId":"123456","RateValue":"1"},{"TaxRateName":"BP Test tax1","TaxRateId":null,"TaxAgencyId":"123456","RateValue":"1"},{"TaxRateName":"BP Test tax2","TaxRateId":null,"TaxAgencyId":"123456","RateValue":"1"}]}');
            } 
            
            if(String.isNotBlank(End_Point_URL)) {
                res.setStatusCode(200);
            }
        }else{
            res = http.send(req); 
        }
        System.debug('***************' + res.getBody() + '-------------') ;
        return res;
    }
    
    
    
    
    public static HttpResponse getRequestFromQuickBooks(String objectType, String quickbookId){
        getQuickBooksConfigurations();
        //String companyId = '123145730762509';
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        // 'https://sandbox-quickbooks.api.intuit.com/v3/company/'
        String APIURL = End_Point_URL+CompanyId+'/'+objectType;
        if(quickbookId != null){
            APIURL += '/'+quickbookId;
        } 
        
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', EncodingUtil.urlEncode(OAuth_Token, 'UTF-8'));
        parameters.put('oauth_version', '1.0');
        
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(APIURL);
        req.setMethod('GET'); 
        req.setTimeout(Request_Timeout_In_MiliSec); 
        String signature = generateSignature(req, Consumer_Secret, OAuth_Token_Secret, parameters);
        String header = generateHeader(signature, parameters);
        
        req.setHeader('Authorization', header);
        req.setHeader('Accept', 'application/json'); 
        req.setHeader('Content-type', 'application/json');
        Http http = new Http();
        if(Test.isRunningTest()){
            res = new HttpResponse();
            //res.setStatusCode(200);
            //System.assert(false, objectType.equals('customer'));
            res.setHeader('Content-Type', 'application/json');
            if(objectType == 'customer') {
                res.setBody('{"Customer":{"Taxable":true,"BillAddr":{"Id":"267","Line1":"Metacube Software1 Pvt Ltd1","Line2":"Sp-6, Phase-IVI","City":"Ontario-city1","Country":"Canada","CountrySubDivisionCode":"Ontario","PostalCode":"302044"},"ShipAddr":{"Id":"268","Line1":"Metacube22 Software Pvt Ltd22","Line2":"IT-5, Phase-IV2","City":"AlabanaCity2","Country":"USA","CountrySubDivisionCode":"Alabama","PostalCode":"30203322"},"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","domain":"QBO","sparse":false,"Id":"149","SyncToken":"8","MetaData":{"CreateTime":"2016-12-15T04:16:45-08:00","LastUpdatedTime":"2016-12-19T22:42:20-08:00"},"GivenName":"CustomerQuickbook","FamilyName":"QB","FullyQualifiedName":"CustomerQuickbook QB CTM-0000018","CompanyName":"CustomerQuickbook QB","DisplayName":"CustomerQuickbook QB CTM-0000018","PrintOnCheckName":"CustomerQuickbook QB","Active":true,"PrimaryPhone":{"FreeFormNumber":"1412771716"},"AlternatePhone":{"FreeFormNumber":"8000000008"},"Mobile":{"FreeFormNumber":"8000000008"},"PrimaryEmailAddr":{"Address":"quickbook@dddddqb.com"},"DefaultTaxCodeRef":{"value":"2"}},"time":"2016-12-19T22:42:20.082-08:00"}');
            } else if(objectType == 'vendor') {
                res.setBody('{"Vendor":{"BillAddr":{"Id":"296","Line1":"Metacube software Pvt ltd","Line2":"SP-6, Phase-IV","City":"Black River-City","Country":"Mauritius","CountrySubDivisionCode":"Black River","PostalCode":"111111111"},"Balance":0,"AcctNum":"VendorQuickBook1/ACQB1","Vendor1099":false,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"domain":"QBO","sparse":false,"Id":"170","SyncToken":"0","MetaData":{"CreateTime":"2016-12-20T23:46:16-08:00","LastUpdatedTime":"2016-12-20T23:46:16-08:00"},"CompanyName":"VendorQuickBook1","DisplayName":"VendorQuickBook1 VDR-0012","PrintOnCheckName":"VendorQuickBook1","Active":true,"PrimaryPhone":{"FreeFormNumber":"1111111111"},"AlternatePhone":{"FreeFormNumber":"2222222222"},"Mobile":{"FreeFormNumber":"2222222222"},"Fax":{"FreeFormNumber":"3333333333"},"PrimaryEmailAddr":{"Address":"vendorquickbook1@metacube.com"},"WebAddr":{"URI":"http://www.metacube.com"}},"time":"2016-12-20T23:46:15.902-08:00"}');
            } else if(objectType == 'item') {
                res.setBody('{"Item":{"Name":"Category Unique1 [Labour]","Description":"Category Unique1","Active":true,"FullyQualifiedName":"Category Unique1 [Labour]","Taxable":false,"UnitPrice":0,"Type":"Service","IncomeAccountRef":{"value":"79","name":"Sales of Product Income"},"PurchaseCost":0,"ExpenseAccountRef":{"value":"80","name":"Cost of Goods Sold"},"TrackQtyOnHand":false,"domain":"QBO","sparse":false,"Id":"82","SyncToken":"2","MetaData":{"CreateTime":"2016-12-26T04:12:34-08:00","LastUpdatedTime":"2016-12-26T04:13:17-08:00"}},"time":"2016-12-26T04:13:17.367-08:00"}');                   
            } else if(objectType == 'salesreceipt') {
                res.setBody('{"SalesReceipt":{"domain":"QBO","sparse":false,"Id":"1075","SyncToken":"0","MetaData":{"CreateTime":"2017-07-28T00:25:54-07:00","LastUpdatedTime":"2017-07-28T00:25:54-07:00"},"CustomField":[],"DocNumber":"INV-00000134","TxnDate":"2017-07-28","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","LineNum":1,"Description":"Part_2106 - test part","Amount":15.23,"DetailType":"SalesItemLineDetail","SalesItemLineDetail":{"ItemRef":{"value":"1","name":"Services"},"UnitPrice":15.23,"Qty":1,"TaxCodeRef":{"value":"TAX"}}},{"Amount":15.23,"DetailType":"SubTotalLineDetail","SubTotalLineDetail":{}}],"TxnTaxDetail":{"TxnTaxCodeRef":{"value":"28"},"TotalTax":2.13,"TaxLine":[{"Amount":1.07,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"27"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}},{"Amount":1.06,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"28"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}}]},"CustomerRef":{"value":"209","name":"QB Test 1 CTM-0032699"},"BillAddr":{"Id":"354","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"ShipAddr":{"Id":"355","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"TotalAmt":17.36,"ApplyTaxAfterDiscount":false,"PrintStatus":"PrintComplete","EmailStatus":"NotSet","Balance":0,"DepositToAccountRef":{"value":"4","name":"1001 Undeposited Funds"}},"time":"2017-07-28T00:25:53.894-07:00"}');                   
            } else if(objectType == 'journalentry') {
                res.setBody('{"JournalEntry":{"Adjustment":false,"domain":"QBO","sparse":false,"Id":"675","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T21:39:37-08:00","LastUpdatedTime":"2017-01-17T21:39:37-08:00"},"DocNumber":"PBN-00000311","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"PrivateNote":"QB Part1;Part Created","Line":[{"Id":"0","Description":"QB Part1 - increased by 100.0@$100.0","Amount":10000.00,"DetailType":"JournalEntryLineDetail","JournalEntryLineDetail":{"PostingType":"Credit","Entity":{"Type":"Vendor","EntityRef":{"value":"178","name":"QB Vendor VDR-0014"}},"AccountRef":{"value":"128","name":"A/P Accrual - Inventory"}}},{"Id":"1","Description":"QB Part1 - increased by 100.0@$100.0","Amount":10000.00,"DetailType":"JournalEntryLineDetail","JournalEntryLineDetail":{"PostingType":"Debit","AccountRef":{"value":"81","name":"Inventory Asset"}}}],"TxnTaxDetail":{}},"time":"2017-01-17T21:39:37.529-08:00"}');
            } else if(objectType == 'bill') {
                res.setBody('{"Bill":{"DueDate":"2017-01-18","Balance":180.00,"domain":"QBO","sparse":false,"Id":"689","SyncToken":"0","MetaData":{"CreateTime":"2017-01-17T22:30:55-08:00","LastUpdatedTime":"2017-01-17T22:30:55-08:00"},"DocNumber":"VI-0000019","TxnDate":"2017-01-18","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"QB Part1 - QB Part1 1.00@$200.00","Amount":180.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"QB Part1 - QB Part1 Receiving Adjustment","Amount":-80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"129","name":"VendorInvoiceLiabilitiesAccount"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"QB Part1 - QB Part1 Inventory Adjustment","Amount":80.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"81","name":"Inventory Asset"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"178","name":"QB Vendor VDR-0014"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":180.00},"time":"2017-01-17T22:30:55.871-08:00"}');
            } else if(objectType == 'vendorcredit') {
                res.setBody('{"VendorCredit":{"domain":"QBO","sparse":false,"Id":"6746","SyncToken":"0","MetaData":{"CreateTime":"2018-06-07T02:38:27-07:00","LastUpdatedTime":"2018-06-07T02:38:27-07:00"},"DocNumber":"CreditMemoNumber-1234","TxnDate":"2018-06-07","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 1.00@$0.00","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"140","name":"201 BP Accrued Inventory Payable"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"2","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 Receiving Adjustment","Amount":-21345.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"139","name":"430 BP Inventory Adjustments"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"3","Description":"01062018 QBVen3aprt3 - 01062018 QBVen3aprt3 Inventory Adjustment","Amount":21345.00,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"140","name":"201 BP Accrued Inventory Payable"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"4","Description":"Purchase Tax - GST R 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"174","name":"4300 BP Labor Sales"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"5","Description":"Purchase Tax - Combi 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"164","name":"1311 BP Used Unit Inventory"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"6","Description":"Purchase Tax - Local Tax R 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"173","name":"4200 BP Parts Sales"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}},{"Id":"7","Description":"Purchase Tax - PST R1 1","Amount":0,"DetailType":"AccountBasedExpenseLineDetail","AccountBasedExpenseLineDetail":{"AccountRef":{"value":"79","name":"Sales of Product Income"},"BillableStatus":"NotBillable","TaxCodeRef":{"value":"NON"}}}],"VendorRef":{"value":"1433","name":"01062018 QBVen3 VDR-0172"},"APAccountRef":{"value":"128","name":"A/P Accrual - Inventory"},"TotalAmt":0},"time":"2018-06-07T02:38:27.930-07:00"}');
            } else if(objectType.contains('reports/')) {
                res.setBody('{"Header":{"Time":"2018-09-10T22:24:05-07:00","ReportName":"ProfitAndLoss","ReportBasis":"Accrual","StartPeriod":"2018-08-01","EndPeriod":"2018-08-31","SummarizeColumnsBy":"Total","Currency":"USD","Option":[{"Name":"AccountingStandard","Value":"GAAP"},{"Name":"NoReportData","Value":"false"}]},"Columns":{"Column":[{"ColTitle":"","ColType":"Account","MetaData":[{"Name":"ColKey","Value":"account"}]},{"ColTitle":"Total","ColType":"Money","MetaData":[{"Name":"ColKey","Value":"total"}]}]},"Rows":{"Row":[{"Header":{"ColData":[{"value":"Income"},{"value":""}]},"Rows":{"Row":[{"ColData":[{"value":"401 Sales - BP Parts 1","id":"130"},{"value":"2172.66"}],"type":"Data"},{"ColData":[{"value":"402 Sales - BP Parts 2","id":"131"},{"value":"130652.28"}],"type":"Data"},{"ColData":[{"value":"4100 BP Unit Sales","id":"172"},{"value":"260814.34"}],"type":"Data"},{"ColData":[{"value":"411 Sales - BP Labor 1","id":"134"},{"value":"6075.00"}],"type":"Data"},{"ColData":[{"value":"4200 BP Parts Sales","id":"173"},{"value":"796.03"}],"type":"Data"},{"ColData":[{"value":"430 BP Inventory Adjustments","id":"139"},{"value":"667612.52"}],"type":"Data"},{"ColData":[{"value":"4300 BP Labor Sales","id":"174"},{"value":"3959.40"}],"type":"Data"},{"ColData":[{"value":"4500 BP Other Fees & Charges","id":"179"},{"value":"130.00"}],"type":"Data"},{"ColData":[{"value":"Billable Expense Income","id":"85"},{"value":"16396.22"}],"type":"Data"},{"ColData":[{"value":"Sales of Product Income","id":"79"},{"value":"24962.44"}],"type":"Data"},{"ColData":[{"value":"Services","id":"1"},{"value":"214.96"}],"type":"Data"}]},"Summary":{"ColData":[{"value":"Total Income"},{"value":"1113785.85"}]},"type":"Section","group":"Income"},{"Header":{"ColData":[{"value":"Cost of Goods Sold"},{"value":""}]},"Rows":{"Row":[{"ColData":[{"value":"501 COGS - BP Parts 1","id":"132"},{"value":"13494.36"}],"type":"Data"},{"ColData":[{"value":"502 COGS - BP Parts 2","id":"133"},{"value":"118552.56"}],"type":"Data"},{"ColData":[{"value":"5100 BP Unit COGS","id":"180"},{"value":"129340.48"}],"type":"Data"},{"ColData":[{"value":"5200 BP Parts COGS","id":"181"},{"value":"1009.16"}],"type":"Data"},{"ColData":[{"value":"5300 BP Labor COGS","id":"182"},{"value":"9224.56"}],"type":"Data"},{"ColData":[{"value":"5310 BP Sublet COGS","id":"183"},{"value":"985.45"}],"type":"Data"},{"ColData":[{"value":"5400 BP Warranty Plan COGS","id":"184"},{"value":"4473.28"}],"type":"Data"},{"ColData":[{"value":"5500 BP Cash Payment Rounding","id":"186"},{"value":"0.01"}],"type":"Data"}]},"Summary":{"ColData":[{"value":"Total Cost of Goods Sold"},{"value":"277079.86"}]},"type":"Section","group":"COGS"},{"Summary":{"ColData":[{"value":"Gross Profit"},{"value":"836705.99"}]},"type":"Section","group":"GrossProfit"},{"Header":{"ColData":[{"value":"Expenses"},{"value":""}]},"Rows":{"Row":[{"ColData":[{"value":"6041 BP Applied Technician Wages","id":"188"},{"value":"-5137.40"}],"type":"Data"},{"ColData":[{"value":"Legal & Professional Fees","id":"12"},{"value":"-1304.72"}],"type":"Data"},{"ColData":[{"value":"Uncategorized Expense","id":"31"},{"value":"6544.73"}],"type":"Data"}]},"Summary":{"ColData":[{"value":"Total Expenses"},{"value":"102.61"}]},"type":"Section","group":"Expenses"},{"Summary":{"ColData":[{"value":"Net Operating Income"},{"value":"836603.38"}]},"type":"Section","group":"NetOperatingIncome"},{"Header":{"ColData":[{"value":"Other Expenses"},{"value":""}]},"Rows":{"Row":[{"ColData":[{"value":"Depreciation","id":"40"},{"value":"-87.70"}],"type":"Data"}]},"Summary":{"ColData":[{"value":"Total Other Expenses"},{"value":"-87.70"}]},"type":"Section","group":"OtherExpenses"},{"Summary":{"ColData":[{"value":"Net Other Income"},{"value":"87.70"}]},"type":"Section","group":"NetOtherIncome"},{"Summary":{"ColData":[{"value":"Net Income"},{"value":"836691.08"}]},"type":"Section","group":"NetIncome"}]}}');
            }else if(objectType == 'taxagency') {
            	res.setBody('{"TaxAgency":{"DisplayName":"Test Agency new"}}');
            } 
            if(objectType.contains('companyinfo/')) {
                res.setBody('{"CompanyInfo":{"CompanyName":"Sandbox Company_US_1","LegalName":"Sandbox Company_US_1","CompanyAddr":{"Id":"1","Line1":"123 Sierra Way","City":"San Pablo","CountrySubDivisionCode":"CA","PostalCode":"87999","Lat":"36.6788345","Long":"-5.4464622"},"CustomerCommunicationAddr":{"Id":"1","Line1":"123 Sierra Way","City":"San Pablo","CountrySubDivisionCode":"CA","PostalCode":"87999","Lat":"36.6788345","Long":"-5.4464622"},"LegalAddr":{"Id":"1","Line1":"123 Sierra Way","City":"San Pablo","CountrySubDivisionCode":"CA","PostalCode":"87999","Lat":"36.6788345","Long":"-5.4464622"},"PrimaryPhone":{},"CompanyStartDate":"2016-11-18","FiscalYearStartMonth":"January","Country":"US","Email":{"Address":"noreply@quickbooks.com"},"WebAddr":{},"SupportedLanguages":"en","NameValue":[{"Name":"NeoEnabled","Value":"true"},{"Name":"IsQbdtMigrated","Value":"false"},{"Name":"CompanyType","Value":"Other"},{"Name":"SubscriptionStatus","Value":"TRIAL"},{"Name":"OfferingSku","Value":"QuickBooks Online Plus"},{"Name":"PayrollFeature","Value":"false"},{"Name":"AccountantFeature","Value":"false"},{"Name":"QBOIndustryType","Value":"Landscaping Services"},{"Name":"ItemCategoriesFeature","Value":"false"},{"Name":"AssignedTime","Value":"2016-11-20T23:36:34-08:00"}],"domain":"QBO","sparse":false,"Id":"1","SyncToken":"8","MetaData":{"CreateTime":"2016-11-18T02:18:37-08:00","LastUpdatedTime":"2016-12-14T01:46:23-08:00"}},"time":"2017-04-25T00:26:24.107-07:00"}');
            } else if(objectType.contains('query?query=')) {
                if(objectType.contains('salesreceipt')) {
                    res.setBody('{"SalesReceipt":{"domain":"QBO","sparse":false,"Id":"1075","SyncToken":"0","MetaData":{"CreateTime":"2017-07-28T00:25:54-07:00","LastUpdatedTime":"2017-07-28T00:25:54-07:00"},"CustomField":[],"DocNumber":"INV-00000134","TxnDate":"2017-07-28","CurrencyRef":{"value":"USD","name":"United States Dollar"},"Line":[{"Id":"1","LineNum":1,"Description":"Part_2106 - test part","Amount":15.23,"DetailType":"SalesItemLineDetail","SalesItemLineDetail":{"ItemRef":{"value":"1","name":"Services"},"UnitPrice":15.23,"Qty":1,"TaxCodeRef":{"value":"TAX"}}},{"Amount":15.23,"DetailType":"SubTotalLineDetail","SubTotalLineDetail":{}}],"TxnTaxDetail":{"TxnTaxCodeRef":{"value":"28"},"TotalTax":2.13,"TaxLine":[{"Amount":1.07,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"27"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}},{"Amount":1.06,"DetailType":"TaxLineDetail","TaxLineDetail":{"TaxRateRef":{"value":"28"},"PercentBased":true,"TaxPercent":10,"NetAmountTaxable":15.23}}]},"CustomerRef":{"value":"209","name":"QB Test 1 CTM-0032699"},"BillAddr":{"Id":"354","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"ShipAddr":{"Id":"355","Country":"Australia","CountrySubDivisionCode":"New South Wales"},"TotalAmt":17.36,"ApplyTaxAfterDiscount":false,"PrintStatus":"PrintComplete","EmailStatus":"NotSet","Balance":0,"DepositToAccountRef":{"value":"4","name":"1001 Undeposited Funds"}},"time":"2017-07-28T00:25:53.894-07:00"}');
                }else if(objectType.contains('Bill')){
                	res.setBody('{"QueryResponse":{"VendorCredit":null,"Vendor":null,"TotalCount":null,"TaxRate":null,"TaxCode":null,"SalesReceipt":null,"RefundReceipt":null,"maxResults":null,"Invoice":null,"Customer":null,"CreditMemo":null,"Bill":[{"SyncToken":"syncToken1","Id":"12","DocNumber":"1"},{"SyncToken":"syncToken2","Id":"123","DocNumber":"2"}]}}');
                }else if(objectType.contains('TaxRate')) {
              		res.setBody('{"QueryResponse":{"TaxRate":[{"Name":"Test1","Id":"123"},{"Name":"Test2","Id":"456"}]}}');
                }else {
                    res.setBody('{"QueryResponse":{"Account":[{"Name":"A/P Accrual - Inventory","AccountType":"Accounts Payable","sparse":true,"Id":"128"},{"Name":"Abc Payable","AccountType":"Other Current Liability","sparse":true,"Id":"146"},{"Name":"Accounts Payable (A/P)","AccountType":"Accounts Payable","sparse":true,"Id":"33"},{"Name":"Accounts Receivable (A/R)","AccountType":"Accounts Receivable","sparse":true,"Id":"84"},{"Name":"Advertising","AccountType":"Expense","sparse":true,"Id":"7"},{"Name":"Agency1 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"149"},{"Name":"Agency2 Payable C","AccountType":"Other Current Liability","sparse":true,"Id":"148"},{"Name":"Arizona Dept. of Revenue Payable","AccountType":"Other Current Liability","sparse":true,"Id":"89"},{"Name":"Automobile","AccountType":"Expense","sparse":true,"Id":"55"},{"Name":"Fuel","AccountType":"Expense","sparse":true,"Id":"56"},{"Name":"Bank Charges","AccountType":"Expense","sparse":true,"Id":"8"},{"Name":"Billable Expense Income","AccountType":"Income","sparse":true,"Id":"85"},{"Name":"Board of Equalization Payable","AccountType":"Other Current Liability","sparse":true,"Id":"90"},{"Name":"BP Accrued Inventory Payable","AccountType":"Other Current Liability","sparse":true,"Id":"140"},{"Name":"BP Customer Deposits","AccountType":"Other Current Liability","sparse":true,"Id":"141"},{"Name":"BP GST Payable","AccountType":"Other Current Liability","sparse":true,"Id":"143"},{"Name":"BP Inventory Adjustments","AccountType":"Income","sparse":true,"Id":"139"},{"Name":"BP Parts Inventory 1","AccountType":"Other Current Asset","sparse":true,"Id":"144"},{"Name":"BP Parts Inventory 2","AccountType":"Other Current Asset","sparse":true,"Id":"145"},{"Name":"BP PST Payable","AccountType":"Other Current Liability","sparse":true,"Id":"142"},{"Name":"Checking","AccountType":"Bank","sparse":true,"Id":"35"},{"Name":"COGS - BP Parts 1","AccountType":"Cost of Goods Sold","sparse":true,"Id":"132"},{"Name":"COGS - BP Parts 2","AccountType":"Cost of Goods Sold","sparse":true,"Id":"133"},{"Name":"Commissions & fees","AccountType":"Expense","sparse":true,"Id":"9"},{"Name":"Cost of Goods Sold","AccountType":"Cost of Goods Sold","sparse":true,"Id":"80"},{"Name":"Depreciation","AccountType":"Other Expense","sparse":true,"Id":"40"},{"Name":"Design income","AccountType":"Income","sparse":true,"Id":"82"},{"Name":"Discounts given","AccountType":"Income","sparse":true,"Id":"86"},{"Name":"Disposal Fees","AccountType":"Expense","sparse":true,"Id":"28"},{"Name":"Dues & Subscriptions","AccountType":"Expense","sparse":true,"Id":"10"},{"Name":"Equipment Rental","AccountType":"Expense","sparse":true,"Id":"29"},{"Name":"Fees Billed","AccountType":"Income","sparse":true,"Id":"5"},{"Name":"Hitesh Gupta","AccountType":"Accounts Receivable","sparse":true,"Id":"92"},{"Name":"Insurance","AccountType":"Expense","sparse":true,"Id":"11"},{"Name":"Workers Compensation","AccountType":"Expense","sparse":true,"Id":"57"},{"Name":"Interest Earned","AccountType":"Other Income","sparse":true,"Id":"25"},{"Name":"Inventory Asset","AccountType":"Other Current Asset","sparse":true,"Id":"81"},{"Name":"Inventory Shrinkage","AccountType":"Cost of Goods Sold","sparse":true,"Id":"147"},{"Name":"Job Expenses","AccountType":"Expense","sparse":true,"Id":"58"},{"Name":"Cost of Labor","AccountType":"Expense","sparse":true,"Id":"59"},{"Name":"Installation","AccountType":"Expense","sparse":true,"Id":"60"},{"Name":"Maintenance and Repairs","AccountType":"Expense","sparse":true,"Id":"61"},{"Name":"Equipment Rental","AccountType":"Expense","sparse":true,"Id":"62"},{"Name":"Job Materials","AccountType":"Expense","sparse":true,"Id":"63"},{"Name":"Decks and Patios","AccountType":"Expense","sparse":true,"Id":"64"},{"Name":"Fountain and Garden Lighting","AccountType":"Expense","sparse":true,"Id":"65"},{"Name":"Plants and Soil","AccountType":"Expense","sparse":true,"Id":"66"},{"Name":"Sprinklers and Drip Systems","AccountType":"Expense","sparse":true,"Id":"67"},{"Name":"Permits","AccountType":"Expense","sparse":true,"Id":"68"},{"Name":"Landscaping Services","AccountType":"Income","sparse":true,"Id":"45"},{"Name":"Job Materials","AccountType":"Income","sparse":true,"Id":"46"},{"Name":"Decks and Patios","AccountType":"Income","sparse":true,"Id":"47"},{"Name":"Fountains and Garden Lighting","AccountType":"Income","sparse":true,"Id":"48"},{"Name":"Plants and Soil","AccountType":"Income","sparse":true,"Id":"49"},{"Name":"Sprinklers and Drip Systems","AccountType":"Income","sparse":true,"Id":"50"},{"Name":"Labor","AccountType":"Income","sparse":true,"Id":"51"},{"Name":"Installation","AccountType":"Income","sparse":true,"Id":"52"},{"Name":"Maintenance and Repair","AccountType":"Income","sparse":true,"Id":"53"},{"Name":"Legal & Professional Fees","AccountType":"Expense","sparse":true,"Id":"12"},{"Name":"Accounting","AccountType":"Expense","sparse":true,"Id":"69"},{"Name":"Bookkeeper","AccountType":"Expense","sparse":true,"Id":"70"},{"Name":"Lawyer","AccountType":"Expense","sparse":true,"Id":"71"},{"Name":"Loan Payable","AccountType":"Other Current Liability","sparse":true,"Id":"43"},{"Name":"Maintenance and Repair","AccountType":"Expense","sparse":true,"Id":"72"},{"Name":"Building Repairs","AccountType":"Expense","sparse":true,"Id":"73"},{"Name":"Computer Repairs","AccountType":"Expense","sparse":true,"Id":"74"},{"Name":"Equipment Repairs","AccountType":"Expense","sparse":true,"Id":"75"},{"Name":"Mastercard","AccountType":"Credit Card","sparse":true,"Id":"41"},{"Name":"Meals and Entertainment","AccountType":"Expense","sparse":true,"Id":"13"},{"Name":"Miscellaneous","AccountType":"Other Expense","sparse":true,"Id":"14"},{"Name":"MyJobs","AccountType":"Accounts Receivable","sparse":true,"Id":"91"},{"Name":"Notes Payable","AccountType":"Long Term Liability","sparse":true,"Id":"44"},{"Name":"Office Expenses","AccountType":"Expense","sparse":true,"Id":"15"},{"Name":"Opening Balance Equity","AccountType":"Equity","sparse":true,"Id":"34"},{"Name":"Other Income","AccountType":"Income","sparse":true,"Id":"83"},{"Name":"Other Portfolio Income","AccountType":"Other Income","sparse":true,"Id":"26"},{"Name":"Penalties & Settlements","AccountType":"Other Expense","sparse":true,"Id":"27"},{"Name":"Pest Control Services","AccountType":"Income","sparse":true,"Id":"54"},{"Name":"Prepaid Expenses","AccountType":"Other Current Asset","sparse":true,"Id":"3"},{"Name":"Promotional","AccountType":"Expense","sparse":true,"Id":"16"},{"Name":"PST Payable","AccountType":"Other Current Liability","sparse":true,"Id":"95"},{"Name":"PST123 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"96"},{"Name":"PST1234 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"97"},{"Name":"PST12345 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"98"},{"Name":"PST123456 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"99"},{"Name":"PST123457 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"100"},{"Name":"Purchases","AccountType":"Expense","sparse":true,"Id":"78"},{"Name":"Refunds-Allowances","AccountType":"Income","sparse":true,"Id":"6"},{"Name":"Rent or Lease","AccountType":"Expense","sparse":true,"Id":"17"},{"Name":"Retained Earnings","AccountType":"Equity","sparse":true,"Id":"2"},{"Name":"Sales - BP Fees 1","AccountType":"Income","sparse":true,"Id":"137"},{"Name":"Sales - BP Fees 2","AccountType":"Income","sparse":true,"Id":"138"},{"Name":"Sales - BP Labor 1","AccountType":"Income","sparse":true,"Id":"134"},{"Name":"Sales - BP Labor 2","AccountType":"Income","sparse":true,"Id":"135"},{"Name":"Sales - BP Parts 1","AccountType":"Income","sparse":true,"Id":"130"},{"Name":"Sales - BP Parts 2","AccountType":"Income","sparse":true,"Id":"131"},{"Name":"Sales of Product Income","AccountType":"Income","sparse":true,"Id":"79"},{"Name":"Sales Tax Item1 Payable","AccountType":"Other Current Liability","sparse":true,"Id":"93"}],"startPosition":1,"maxResults":100},"time":"2017-04-25T01:16:38.658-07:00"}');
                }
            }
            
            if(String.isNotBlank(End_Point_URL)) {
                res.setStatusCode(200);
            }
        }else{
            res = http.send(req); 
        }
        system.debug('***************** ' + res.getBody() + ' ********************');
        return res;
    }
    
    
    public static void getQuickBooksConfigurations() {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        Consumer_Key = qbConfig.Consumer_Key__c;
        End_Point_URL = qbConfig.End_Point_URL__c;
        Consumer_Secret = qbConfig.Consumer_Secret__c;
        OAuth_Token = qbConfig.OAuth_Token__c;
        OAuth_Token_Secret = qbConfig.OAuth_Token_Secret__c;
        CompanyId = qbConfig.Company_Id__c;
    }
    
    public static Map<String,String> getResponseNVP(HttpRequest req){
        
        Http http = new Http();
        HttpResponse res;

        res = http.send(req); 
        String resParams = res.getBody();
            
        Map<String,String> rp = new Map<String,String>();
        
        for(String s : resParams.split('&')) {
            List<String> kv = s.split('=');
            rp.put(kv[0],kv[1]);
        }
        
        return rp;
    }
    
    public static HttpResponse OAuthConnectionStep2(String tokenParm, String tokenVerifier){
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        
        QuickBooks_Configurations__c qbConfigData = QuickBooks_Configurations__c.getOrgDefaults();
        Consumer_Key = qbConfigData.Consumer_Key__c;
        Consumer_Secret = qbConfigData.Consumer_Secret__c;
        String tokenParmSecret = qbConfigData.OAuth_Token_Secret__c;
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Quickbooks_oauth_callback', 'UTF-8')); //'/apex/AccountingIntegrationSettings'
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', tokenParm);
        parameters.put('oauth_verifier', tokenVerifier);
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint('https://oauth.intuit.com/oauth/v1/get_access_token');
        req.setMethod('POST');
        req.setTimeout(Request_Timeout_In_MiliSec);
        String signature = QuickbookConnector.generateSignature(req, Consumer_Secret, tokenParmSecret, parameters);
        
        String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Quickbooks_oauth_callback' + '&';
        body += 'oauth_consumer_key=' + Consumer_Key + '&';
        body += 'oauth_nonce=' + nonce + '&';
        body += 'oauth_signature_method=HMAC-SHA1&';
        body += 'oauth_timestamp=' + timestamp + '&';
        body += 'oauth_version=1.0&';
        body += 'oauth_token=' + tokenParm + '&';
        body += 'oauth_verifier=' + tokenVerifier + '&';
        body += 'oauth_signature=' + signature; 
        
        req.setBody(body);
        Http http = new Http();
        if(Test.isRunningTest()){
            res = new HttpResponse();
            //res.setStatusCode(200);
            //System.assert(false, objectType.equals('customer'));
            res.setBody('oauth_token_secret=tsfrorfbeO8Bw9xlsPhl0HaAilx94UXlwDKtR2L7&oauth_token=lvprdHhVffytEzqkLVFoVPXwf1qSizqw13EiMKWlfyIOltru');
            
            //System.assert(false,res.getBody()); 
            res.setStatusCode(200);
        } else{
        res = http.send(req);
        }
        //res = http.send(req);
        return res;
    }
    
    
    public static HttpResponse OAuthConnection(String ConsumerKey, String ConsumerSecret){
        Consumer_Key = BPUtility.getDecodedString(ConsumerKey);
        Consumer_Secret = BPUtility.getDecodedString(ConsumerSecret);
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Quickbooks_oauth_callback', 'UTF-8')); //Page.Quickbooks_oauth_callback
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(Request_Token_URL); //'https://oauth.intuit.com/oauth/v1/get_request_token'
        req.setMethod('POST'); //POST
        req.setTimeout(Request_Timeout_In_MiliSec);
        String signature = QuickbookConnector.generateSignature(req, Consumer_Secret, '', parameters);
        
        String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Quickbooks_oauth_callback' + '&';
        body += 'oauth_consumer_key=' + Consumer_Key + '&';
        body += 'oauth_nonce=' + nonce + '&';
        body += 'oauth_signature_method=HMAC-SHA1&';  
        body += 'oauth_timestamp=' + timestamp + '&';
        body += 'oauth_version=1.0&';
        body += 'oauth_signature=' + signature;
        req.setBody(body);
        
        Http http = new Http();
        if(Test.isRunningTest()){
            res = new HttpResponse();
            //res.setStatusCode(200);
            //System.assert(false, objectType.equals('customer'));
            res.setBody('oauth_token_secret=bZnnJ7MZDQcfzkcd3NWtRfVUZww1wAmtYle9n6ms&oauth_token=qyprdnDRNACG0x8mmkZDpG8rkJbdGkp4ESvgc2h5cCr7YHVC&oauth_callback_confirmed=true');
            
            //System.assert(false,res.getBody()); 
            res.setStatusCode(200);
        } else{
        res = http.send(req);
        }
        //res = http.send(req);
        return res;
    }
}