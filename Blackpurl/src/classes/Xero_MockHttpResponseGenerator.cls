/**
 * Author: Nikhil Kumar Srivastava
 * Since: Feb 25, 2019
 * Name: Xero_MockHttpResponseGenerator 
 * Description: Test class for xero callouts
**/
@isTest
global class Xero_MockHttpResponseGenerator implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        //System.assertEquals('http://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        Map<String, String> objectToEndPointURLMap = new Map<String,String>{	'ITEM'   =>  'https://api.xero.com/api.xro/2.0/Items'};
    
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(req.getEndpoint().equalsIgnoreCase(objectToEndPointURLMap.get('ITEM'))) {
        	res.setBody('{"Items":[{"UpdatedDateUTC":null,"SFId":"a0Kf4000009LW2pEAG","SalesDetails":{"UnitPrice":null,"AccountCode":"35"},"PurchaseDetails":{"UnitPrice":null,"AccountCode":null},"Name":"Test Category III","ItemID":"xxxItemID101xxx","Description":null,"Code":"Test Category III [Labour]"}]}');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/ManualJournals')) {
        	res.setBody('{"Id":"da2efeae-f0d3-4d89-bafd-4fdb0ed35c01","Status":"OK","ProviderName":"BPDev04","DateTimeUTC":"/Date(1551351385077)/","ManualJournals":[{"Date":"/Date(1551312000000+0000)/","Status":"POSTED","LineAmountTypes":"NoTax","UpdatedDateUTC":"/Date(1551351384863+0000)/","ManualJournalID":"6d037ca7-113b-4919-b4dd-22432503e76a","Narration":"CODN-00000165;stuart clark;CO-0002769;Gift Card;Deposit","JournalLines":[{"Description":"CODN-00000165;stuart clark;CO-0002769;Gift Card;Deposit","TaxType":"NONE","LineAmount":1,"AccountCode":"710","Tracking":[],"AccountID":"0289f44f-bdad-48e8-ab5a-502e9d949bd7","IsBlank":false},{"Description":"CODN-00000165;stuart clark;CO-0002769;Gift Card;Deposit","TaxType":"NONE","LineAmount":-1,"AccountCode":"710","Tracking":[],"AccountID":"0289f44f-bdad-48e8-ab5a-502e9d949bd7","IsBlank":false}],"ShowOnCashBasisReports":true}]}');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/oauth/RequestToken')) {
        	res.setBody('oauth_token=XWJTDCLFRSQB1SWSJRKUE3TT6TSWXB&oauth_token_secret=ICHSLSYK7JQVGNUSR3CLOIHCLTPQPP&oauth_callback_confirmed=true');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/organisation')) {
        	res.setBody('{"Id": "31db9217-5483-493a-bcff-45d9f58fa145","Status": "OK","ProviderName": "BPDev04","DateTimeUTC": "/Date(1551870844200)/","Organisations": [{"Name": "Demo Company (Global)","LegalName": "Demo Company (Global)","PaysTax": true,"Version": "GLOBAL","OrganisationType": "COMPANY","BaseCurrency": "USD","CountryCode": "CA","IsDemoCompany": true,"OrganisationStatus": "ACTIVE","TaxNumber": "101-2-303","FinancialYearEndDay": 31,"FinancialYearEndMonth": 12,"SalesTaxBasis": "ACCRUALS","SalesTaxPeriod": "3MONTHLY","DefaultSalesTax": "Remember previous","DefaultPurchasesTax": "Remember previous","PeriodLockDate": "/Date(1222732800000+0000)/","CreatedDateUTC": "/Date(1550466435430)/","OrganisationEntityType": "COMPANY","Timezone": "EASTERNSTANDARDTIME","ShortCode": "!Xx5vl","OrganisationID": "c327232d-37f9-4952-b850-67a38ee378e2","Edition": "BUSINESS","Class": "DEMO","Addresses": [{"AddressType": "POBOX","AddressLine1": "23 Main Street","AddressLine2": "Central City","City": "Marineville","Region": "","PostalCode": "12345","Country": "","AttentionTo": ""}],"Phones": [{"PhoneType": "OFFICE","PhoneNumber": "1234 5678","PhoneAreaCode": "800"}],"ExternalLinks": [],"PaymentTerms": {},"TaxNumberName": "Tax reg"}]}');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/account')) {
        	res.setBody('{"Id":"363f68f4-324b-4347-bd7f-10bb43daef02","Status":"OK","ProviderName":"BPDev04","DateTimeUTC":"/Date(1551871785822)/","Accounts":[{"AccountID":"562555f2-8cde-4ce9-8203-0363922537a4","Code":"090","Name":"Business Bank Account","Status":"ACTIVE","Type":"BANK","TaxType":"NONE","Class":"ASSET","EnablePaymentsToAccount":false,"ShowInExpenseClaims":false,"BankAccountNumber":"0908007006543","BankAccountType":"BANK","CurrencyCode":"USD","ReportingCode":"ASS","ReportingCodeName":"Asset","HasAttachments":false,"UpdatedDateUTC":"/Date(1550466473157+0000)/"}]}');
        	res.setStatusCode(200);
        }else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/Contacts')) {
        	res.setBody('{"Id":"24297481-e886-49a0-9640-49b034186d04","Status":"OK","ProviderName":"BPDev04","DateTimeUTC":"/Date(1551940159450)/","Contacts":[{"ContactID":"85d5af6e-7903-4d8a-869e-0238f7802c76","ContactNumber":"CTM-0008659","ContactStatus":"ACTIVE","Name":"null null CTM-0008659","EmailAddress":"","BankAccountDetails":"","Addresses":[{"AddressType":"STREET","AddressLine1":"","AddressLine2":"","City":"","Region":"Alaska","PostalCode":"","Country":"USA"},{"AddressType":"POBOX","AddressLine1":"","AddressLine2":"","City":"","Region":"Alaska","PostalCode":"","Country":"USA"}],"Phones":[{"PhoneType":"DEFAULT","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"DDI","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"FAX","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""},{"PhoneType":"MOBILE","PhoneNumber":"","PhoneAreaCode":"","PhoneCountryCode":""}],"UpdatedDateUTC":"/Date(1551940159350+0000)/","ContactGroups":[],"IsSupplier":false,"IsCustomer":false,"SalesTrackingCategories":[],"PurchasesTrackingCategories":[],"ContactPersons":[],"HasValidationErrors":false}]}');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/invoices')) {
        	res.setBody('{"Invoices":[{"InvoiceID":"12"}]}');
        	res.setStatusCode(200);
        } else if(req.getEndpoint().equalsIgnoreCase('https://api.xero.com/api.xro/2.0/creditnotes')) {
            res.setBody('{"CreditNotes":[{"CreditNoteID":"1259"}]}');
            res.setStatusCode(200);
        } else {
        	res.setbody('{}');
        	res.setStatusCode(400);
        }
       
        return res;
    }
    
}