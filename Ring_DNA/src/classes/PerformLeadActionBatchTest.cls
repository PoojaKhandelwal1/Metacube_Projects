@isTest
public class PerformLeadActionBatchTest {
    static testMethod void PerformLeadActionBatch() {
		Lead leadRec = TestDataFactory.createLead();
		insert leadRec; 
    	Test.startTest();
        DataBase.executeBatch(new PerformLeadActionBatch());
        Test.stopTest();
    }
}