@isTest
private with sharing class CadenceBatchTest {
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';

	@isTest
	private static void CadenceBatchTest(){
		Cadence__c cad = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		cad.Name='contact';
		cad.Status__c=true;
		cad.Record_Type__c='Contact';
		cad.Participent_Activation__c='Automatic';
		insert cad; 
		Test.startTest();
		CadenceBatch cb= new CadenceBatch(cad.Id);
		Database.executeBatch(cb);
		Test.stopTest();
	}
	@isTest
	static void startdemoTest(){

		Test.startTest();
		Cadence__c cad = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		cad.Name='contact';
		cad.Status__c=true;
		cad.Record_Type__c='Contact';
		cad.Participent_Activation__c='Automatic';
		insert cad; 
		List<Cadence__c> cad1 = [select Id, Name from Cadence__c];
		Test.stopTest();
		System.assert(cad1[0].Name.Contains('contact'));
	}
}