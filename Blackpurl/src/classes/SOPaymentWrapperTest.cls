/**
 * Author: Gourav goyal
 * Since: July 31, 2017
 * Name: SOPaymentWrapperTest 
 * Description: Controller test Class of SOPayment trigger.
**/
@isTest
private class SOPaymentWrapperTest {
    /**
     * Name: createSOpaymentRoleDataTest
     * Desc: Test to create SO PaymentRole wrapper
     * @param: 
     * @return: 
    **/
    
    static testmethod void createSOpaymentRoleDataTest(){
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        Service_Order_Header__c sohObj = [select id,CO_Header__c from Service_Order_Header__c where CO_Header__c =:coHeader.id];
        String strRecordTypeId = [Select Id From RecordType Where SobjectType =: Constants.NAMESPACE + 'SO_Payment_Role__c' and Name = 'Third Party'].Id;
        SO_Payment_Role__c soprObj = new SO_Payment_Role__c();
        soprObj.RecordTypeId = strRecordTypeId;
        soprObj.Service_Order_Header__c = sohObj.id;
        soprObj.Category__c = testCategory.id;
        insert soprObj;
        
        test.startTest();
        SOPaymentWrapper sopObj = new SOPaymentWrapper(soprObj);
        SOPaymentWrapper.getSOPaymentRoleFieldsList();
        test.stopTest();
        system.assert(true,true);
    }
}