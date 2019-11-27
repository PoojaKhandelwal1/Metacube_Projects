/**
 * Author: Richa Mittal
 * Since: Jan 3, 2017
 * Name: AccSync_Customer_Batch test
 * Description: batch test Class of customer sync to QuickBooks.
**/
@isTest
public with sharing class AccSync_Customer_Batch_Test {
	@testSetup
   static void setup() {
   		
   		system.assert(true,true);
   }
	private static Integer uniqueNumber = 1;
	static testmethod void testCreateCustomer() {
		Test.startTest();
		QuickBooks_Configurations__c qbConfig = new QuickBooks_Configurations__c();
		qbConfig.Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbConfig.Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        qbConfig.OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj';
        qbConfig.OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO';
        qbConfig.Company_Id__c = '123145730762509';
		qbConfig.Enable_QuickBooks__c = true;   
		insert qbConfig;
		
		insert new General_Configurations__c(Enable_QB_Accounting__c = true);
		
   		Account testCustomer = AccSync_Customer_Batch_Test.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123', null, null, false, true, null, null, null, null, null, null, null, null, null, null, null, null);
   		Test.stopTest();
   		
   		Account customer = [select AccountingId__c, AccountingResponse__c from Account where ID = :testCustomer.Id];
   		String res = '{"Customer":{"Taxable":true,"BillAddr":{"Id":"267","Line1":"Metacube Software1 Pvt Ltd1","Line2":"Sp-6, Phase-IVI","City":"Ontario-city1","Country":"Canada","CountrySubDivisionCode":"Ontario","PostalCode":"302044"},"ShipAddr":{"Id":"268","Line1":"Metacube22 Software Pvt Ltd22","Line2":"IT-5, Phase-IV2","City":"AlabanaCity2","Country":"USA","CountrySubDivisionCode":"Alabama","PostalCode":"30203322"},"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","domain":"QBO","sparse":false,"Id":"149","SyncToken":"8","MetaData":{"CreateTime":"2016-12-15T04:16:45-08:00","LastUpdatedTime":"2016-12-19T22:42:20-08:00"},"GivenName":"CustomerQuickbook","FamilyName":"QB","FullyQualifiedName":"CustomerQuickbook QB CTM-0000018","CompanyName":"CustomerQuickbook QB","DisplayName":"CustomerQuickbook QB CTM-0000018","PrintOnCheckName":"CustomerQuickbook QB","Active":true,"PrimaryPhone":{"FreeFormNumber":"1412771716"},"AlternatePhone":{"FreeFormNumber":"8000000008"},"Mobile":{"FreeFormNumber":"8000000008"},"PrimaryEmailAddr":{"Address":"quickbook@dddddqb.com"},"DefaultTaxCodeRef":{"value":"2"}},"time":"2016-12-19T22:42:20.082-08:00"}';
   		System.debug('richa**'+customer);
   		system.assertEquals('149', customer.AccountingId__c);
	}
	
	static testmethod void testUpdateCustomer() {
		Test.startTest();
		QuickBooks_Configurations__c qbConfig = new QuickBooks_Configurations__c();
		qbConfig.Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbConfig.Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        qbConfig.OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj';
        qbConfig.OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO';
        qbConfig.Company_Id__c = '123145730762509';
		qbConfig.Enable_QuickBooks__c = true;
		insert qbConfig;
		
		insert new General_Configurations__c(Enable_QB_Accounting__c = true);
		
   		Account testCustomer = AccSync_Customer_Batch_Test.createCustomer(true, 'Test Customer1', 'a.b@gmail.com', 'Jaipur', '987456123', null, null, false, true, null, null, null, null, null, null, null, null, null, null, null, '0');
   		//update testCustomer;
   		Test.stopTest();
   		
   		Account customer = [select  AccountingId__c, AccountingResponse__c, Facebook__c from Account where ID = :testCustomer.Id];
   		String res = '{"Customer":{"Taxable":true,"BillAddr":{"Id":"267","Line1":"Metacube Software1 Pvt Ltd1","Line2":"Sp-6, Phase-IVI","City":"Ontario-city1","Country":"Canada","CountrySubDivisionCode":"Ontario","PostalCode":"302044"},"ShipAddr":{"Id":"268","Line1":"Metacube22 Software Pvt Ltd22","Line2":"IT-5, Phase-IV2","City":"AlabanaCity2","Country":"USA","CountrySubDivisionCode":"Alabama","PostalCode":"30203322"},"Job":false,"BillWithParent":false,"Balance":0,"BalanceWithJobs":0,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"PreferredDeliveryMethod":"Print","domain":"QBO","sparse":false,"Id":"149","SyncToken":"8","MetaData":{"CreateTime":"2016-12-15T04:16:45-08:00","LastUpdatedTime":"2016-12-19T22:42:20-08:00"},"GivenName":"CustomerQuickbook","FamilyName":"QB","FullyQualifiedName":"CustomerQuickbook QB CTM-0000018","CompanyName":"CustomerQuickbook QB","DisplayName":"CustomerQuickbook QB CTM-0000018","PrintOnCheckName":"CustomerQuickbook QB","Active":true,"PrimaryPhone":{"FreeFormNumber":"1412771716"},"AlternatePhone":{"FreeFormNumber":"8000000008"},"Mobile":{"FreeFormNumber":"8000000008"},"PrimaryEmailAddr":{"Address":"quickbook@dddddqb.com"},"DefaultTaxCodeRef":{"value":"2"}},"time":"2016-12-19T22:42:20.082-08:00"}';
   		System.debug('richa**'+customer);
   		system.assertEquals('149', customer.AccountingId__c);
	}
	
	private static Account createCustomer(boolean isInsert, String customerName, String email, String billingCity, String phoneNumber, String priceLevel, String salesTax, Boolean isVendor, Boolean isCustomer, String customertype, String firstName, String lastName, String Mobile, String BillingStreet, String workEmail, String otherEmail, String workPhone, String facebookUrl, String twitterUrl, String linkedInUrl, String syncToken) {
        if(AccessControl.ifObjectFieldIsCreateable('Account') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);} //!Test.isRunningTest() && 
        
        Account customer = new Account();
        customer.Name = (customerName == null) ? 'Test Customer' + uniqueNumber : customerName ;
        customer.Email__c = (email == null) ? 'Test' + uniqueNumber + '@gmail.com' : email;
        customer.Phone = (phoneNumber == null) ? '123456' + uniqueNumber : phoneNumber;
        customer.BillingCity = (billingCity == null) ? 'Test Billing City' + uniqueNumber : billingCity;
        customer.Price_Level__c = priceLevel;
        customer.Sales_Tax__c = salesTax;
        customer.Is_Vendor__c = isVendor;
        customer.Is_Customer__c = isCustomer;
        customer.Type__c = customertype;
        customer.FirstName__c = firstName;
        customer.LastName__c = lastName;
        customer.Mobile__c = Mobile;
        customer.BillingStreet = BillingStreet ;
        customer.Work_Email__c = workEmail ;
        customer.Other_Email__c = otherEmail ;
        customer.Work_Number__c = workPhone ;
        customer.Facebook__c = facebookUrl ;
        customer.Twitter__c = twitterUrl ;
        customer.LinkedIn__c = linkedInUrl ;
        customer.SyncToken__c = SyncToken;
        
        
        if(isInsert) {
            insert customer;
        }
        
        return customer;
    }
    
    
}