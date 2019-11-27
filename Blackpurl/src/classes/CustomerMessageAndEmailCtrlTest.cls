@isTest
private class CustomerMessageAndEmailCtrlTest {
    @testsetup
    private static void setup(){
    	Notes__c notes = TestDataFactory.createNotes();
    	CustomerApproval__c customerApproval = TestDataFactory.createCustomerApproval('Approved', notes.Id);
    }
    
    @isTest
    private static void testConstructor(){
    	Test.startTest();
    	CustomerMessageAndEmailCtrl customerMessageAndEmailCtrl = new CustomerMessageAndEmailCtrl();
    	CustomerMessageAndEmailCtrl customerMessageAndEmailCtrlWithHomePage = new CustomerMessageAndEmailCtrl(new NewHomePageCtrl());
       	Test.stopTest();
    }
    
    @isTest
    private static void testEmailCustomerApproval(){
    	Test.startTest();
    	CustomerApproval__c customerApproval = [SELECT Id FROM CustomerApproval__c LIMIT 1];
    	String response = CustomerMessageAndEmailCtrl.emailCustomerApproval(BPUtility.getEncodedString(customerApproval.Id), BPUtility.getEncodedString('arjita.marelay@metacube.com'));
    	system.assertEquals('success', response);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateEmailForIndividual(){
    	Test.startTest();
    	Account account = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
    	CustomerMessageAndEmailCtrl.AccountWrapper accountWrapper = new CustomerMessageAndEmailCtrl.AccountWrapper();
    	accountWrapper.Id = account.Id;
    	accountWrapper.Type = 'Individual';
    	accountWrapper.PrimaryEmail = 'arjita.marelay@metacube.com';
    	accountWrapper.AlternateEmail = '';
    	String jSONString = system.json.serialize(accountWrapper);
    	String response = CustomerMessageAndEmailCtrl.updateEmail(BPUtility.getEncodedString(jSONString));
    	system.assertEquals('Success', response);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateEmailForBusiness(){
    	Test.startTest();
    	Account account = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
    	CustomerMessageAndEmailCtrl.AccountWrapper accountWrapper = new CustomerMessageAndEmailCtrl.AccountWrapper();
    	accountWrapper.Id = account.Id;
    	accountWrapper.Type = 'Business';
    	accountWrapper.PrimaryEmail = 'arjita.marelay@metacube.com';
    	accountWrapper.AlternateEmail = '';
    	String jSONString = system.json.serialize(accountWrapper);
    	String response = CustomerMessageAndEmailCtrl.updateEmail(BPUtility.getEncodedString(jSONString));
    	system.assertEquals('Success', response);
    	Test.stopTest();
    }
    
    @isTest
    private static void testUpdateEmailForAlternateEmail(){
    	Test.startTest();
    	Account account = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test Fname', 'Test Lname');
    	CustomerMessageAndEmailCtrl.AccountWrapper accountWrapper = new CustomerMessageAndEmailCtrl.AccountWrapper();
    	accountWrapper.Id = account.Id;
    	accountWrapper.Type = '';
    	accountWrapper.PrimaryEmail = '';
    	accountWrapper.AlternateEmail = 'arjita.marelay@metacube.com';
    	String jSONString = system.json.serialize(accountWrapper);
    	String response = CustomerMessageAndEmailCtrl.updateEmail(BPUtility.getEncodedString(jSONString));
    	system.assertEquals('Success', response);
    	Test.stopTest();
    }
}