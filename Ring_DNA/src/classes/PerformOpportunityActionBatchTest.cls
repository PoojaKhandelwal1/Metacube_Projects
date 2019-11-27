@isTest
public class PerformOpportunityActionBatchTest {
	
	public static Final String RECORD_TYPE_CONTACT = 'Contact';
	
    static testMethod void PerformOpportunityActionBatch() {
    	Opportunity opp = TestDataFactory.createOpp('Test');
    	insert opp;
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert seqRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec;
    	OpportunityContactRole oppRol = TestDataFactory.createOpportunityRole(opp.Id,contRec.Id);
    	Test.startTest();
        DataBase.executeBatch(new PerformOpportunityActionBatch());
        Test.stopTest();
    }
}