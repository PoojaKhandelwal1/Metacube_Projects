@isTest
public class PerformContactActionBatchTest {
	public static Final String RECORD_TYPE_CONTACT = 'Contact';
	
    static testMethod void PerformContactActionBatch() {
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert seqRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
    	Test.startTest();
        DataBase.executeBatch(new PerformContactActionBatch());
        Test.stopTest();
    }
}