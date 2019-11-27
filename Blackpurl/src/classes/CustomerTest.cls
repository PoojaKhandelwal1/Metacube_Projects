@isTest
private class CustomerTest {

    static testMethod void CustomerConstructorTest() {
        Account customerAccount =  new Account();
        
        customerAccount.Name = 'Customer Name';
        customerAccount.FirstName__c = 'FirstName';
        customerAccount.LastName__c = 'LastName';
        customerAccount.Email__c = 'customerHome@email.test';
        customerAccount.Home_Number__c = '3333333333';
        
        // Address fields
        customerAccount.BillingStreet = 'H.N13 Sitapura';
        customerAccount.BillingCity = 'Jaipur';
        customerAccount.BillingState = 'Rajasthan';
        customerAccount.BillingCountry = 'India';
        customerAccount.BillingPostalCode = '302022';
        
        customerAccount.Birth_Date__c = Date.newInstance(2000, 01, 01);
        customerAccount.Active__c = true;
        customerAccount.Company_Name__c = 'Company Name';
        customerAccount.Job_Title__c = 'Job Title';
        
        // Phone And Email
        customerAccount.Work_Email__c = 'customerWork@email.test';
        customerAccount.Other_Email__c = 'customerOther@email.test';
        customerAccount.Mobile__c = '1111111111';
        customerAccount.Work_Number__c = '2222222222';
        customerAccount.Home_Number_SMS__c = true;
        customerAccount.Mobile_Number_SMS__c = true;
        customerAccount.Work_Number_SMS__c = true;
        customerAccount.Preferred_Email__c = 'customerOther@email.test';
        customerAccount.Preferred_Phone__c = '2222222222';
        customerAccount.Preferred_SMS__c = '2222222222';
        
        customerAccount.Is_Customer__c = true;
        customerAccount.Is_Vendor__c = false;
        customerAccount.Nickname__c = 'Nick Name';
        customerAccount.Type__c = 'Individual';
        insert customerAccount;
        
        Customer customerWrapper = new Customer(customerAccount);
        system.assertEquals(customerWrapper.BusinessName,'Customer Name');
        
        List<String> CustomerFieldsList = Customer.fieldsList();
        String CustomerJson = '{"BusinessName":"Customer Name","LastName":"LastName","HomeEmail":"customerHome@email.test"}';
        Customer CustomerRec = Customer.parse(CustomerJson);
    }
    
    static testMethod void CustomerConstructorWithPreferredContactTest() {
        Account customerAccount =  new Account();
        
        customerAccount.Name = 'Customer Name';
        customerAccount.FirstName__c = 'FirstName';
        customerAccount.LastName__c = 'LastName';
        
        // Phone And Email
        customerAccount.Work_Email__c = 'customerWork@email.test';
        customerAccount.Other_Email__c = 'customerOther@email.test';
        insert customerAccount;
        
        Customer customerWrapper = new Customer(customerAccount);
        system.assertEquals(customerWrapper.BusinessName,'Customer Name');
    }
    
    static testMethod void CustomerConstructorWithPreferredAsHomeTest() {
        Account customerAccount =  new Account();
        
        customerAccount.Name = 'Customer Name';
        customerAccount.FirstName__c = 'FirstName';
        customerAccount.LastName__c = 'LastName';
        
        // Phone And Email
        customerAccount.Email__c = 'customerHome@email.test';
        customerAccount.Home_Number__c = '3333333333';
        customerAccount.Preferred_Email__c = 'customerHome@email.test';
        customerAccount.Preferred_Phone__c = '3333333333';
        customerAccount.Preferred_SMS__c = '3333333333';
        insert customerAccount;
        
        Customer customerWrapper = new Customer(customerAccount);
        system.assertEquals(customerWrapper.PreferredEmail,'HomeEmail');
    }
    
    static testMethod void CustomerConstructorWithPreferredAsMobileTest() {
        Account customerAccount =  new Account();
        
        customerAccount.Name = 'Customer Name';
        customerAccount.FirstName__c = 'FirstName';
        customerAccount.LastName__c = 'LastName';
        
        // Phone And Email
        customerAccount.Work_Email__c = 'customerWork@email.test';
        customerAccount.Mobile__c = '3333333333';
        customerAccount.Preferred_Email__c = 'customerWork@email.test';
        customerAccount.Preferred_Phone__c = '3333333333';
        customerAccount.Preferred_SMS__c = '3333333333';
        insert customerAccount;
        
        Customer customerWrapper = new Customer(customerAccount);
        system.assertEquals(customerWrapper.PreferredEmail,'WorkEmail');
    }
}