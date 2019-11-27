/**
 * Author: Pooja Khandelwal
 * Since: July 4, 2017
 * Name: DeleteEmptyRecordsScheduler_PartialTest
 * Description: Test class for DeleteEmptyRecordsSchedulerCtrl PartialTest 
**/
global with sharing class DeleteEmptyRecordsScheduler_PartialTest {
    
    @future 
	global static void deleteCustomerOrderPartialTest(Id kitHeaderId, Id SOHeaderInfoId, Id coHeaderId, Id customerId, Id feeId, Id labourCodeId){
		String lineitems1 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(kitHeaderId), BPUtility.getEncodedString(SOHeaderInfoId), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
		
		String lineitems2 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(feeId), BPUtility.getEncodedString(SOHeaderInfoId), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
		String lineitems3 = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCodeId), BPUtility.getEncodedString(SOHeaderInfoId), BPUtility.getEncodedString(coHeaderId), BPUtility.getEncodedString(customerId)));
		
		list<CO_Header__c> coHeaderlist = [select  Customer__c from CO_Header__c];
        
        system.assertEquals(coHeaderlist.size(), 1 );
        DeleteEmptyRecordsSchedulerCtrl.deleteCustomerOrder();
        list<CO_Header__c> coHeaderlist1 = [select  Customer__c from CO_Header__c];
        system.assertEquals(coHeaderlist1.size(), 1 );
	}
}