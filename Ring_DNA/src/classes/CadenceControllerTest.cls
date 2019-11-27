@isTest
private class CadenceControllerTest {
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static testMethod void testCadenceQuery(){
		Cadence__c cadenceRecord = TestDataFactory.createCadence('Lead');
		Test.startTest();
		insert cadenceRecord;
		CadenceController.getCadenceDetail(cadenceRecord.Id);
		Test.stopTest();  
	}
	
	@isTest
	public static void getFieldsTest(){
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;
		Test.startTest();
		CadenceController.getFields('Contact');
		Test.stopTest();       
	}

	@isTest
	public static void getDateFormat(){
		String dateStr= '2019-03-18 01:01:23';
		String expectedOutput = '2019-03-18'; 
		Test.startTest();
		String actualOutput = CadenceController.getDateFormat(Date.valueOf(dateStr));
		System.assertEquals(actualOutput, expectedOutput);
		Test.stopTest();
	}
	
	@isTest
	public static void activateSmallerOperationCadenceTest(){
		Cadence__c cadenceobj = TestDataFactory.createCadence('Lead');
		String entryJson = TestDataFactory.createCadJsonWithSmallerOperatorCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		CadenceController.updateParticipants(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	}
	
	@isTest
	public static void activateGreaterOperationCadenceTest(){
		Cadence__c cadenceobj = TestDataFactory.createCadence('Lead');
		String entryJson = TestDataFactory.createCadJsonWithGreaterOperatorCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		CadenceController.updateParticipants(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	}
	
	@isTest
	public static void activateSmallOperationCadenceTest(){
		Cadence__c cadenceobj = TestDataFactory.createCadence('Lead');
		String exitJson = TestDataFactory.createCadJsonWithSmallerOperatorCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		CadenceController.updateParticipants(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	} 
	@isTest
	public static void activateGrtrOperationCadenceTest(){
		Cadence__c cadenceobj = TestDataFactory.createCadence('Lead');
		String exitJson = TestDataFactory.createCadJsonWithGreaterOperatorCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		CadenceController.updateParticipants(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	} 
	@isTest
	public static void deactivateCadenceTest(){        
		Cadence__c cadenceobj2 = TestDataFactory.createCadence('Lead');
		insert cadenceobj2;  
		cadenceobj2.Status__c=false;
		upsert cadenceobj2;
		Test.startTest();
		CadenceController.deactivateCadence(cadenceobj2.Id);
		Test.stopTest();
		cadenceobj2=[select Id, Status__c from Cadence__c where id =: cadenceobj2.Id];
		System.assertEquals(False, cadenceobj2.Status__c, 'Cadence deactivated');
	}

	@isTest
	public static void deactivateCadenceTestOpp(){        
		Cadence__c cadenceobj2 = TestDataFactory.createCadence('Opportunity');
		insert cadenceobj2;  
		cadenceobj2.Status__c=false;
		upsert cadenceobj2;
		Test.startTest();
		CadenceController.deactivateCadence(cadenceobj2.Id);
		Test.stopTest();
		cadenceobj2=[select Id, Status__c from Cadence__c where id =: cadenceobj2.Id];
		System.assertEquals(False, cadenceobj2.Status__c, 'Cadence deactivated');
	}

	@isTest
	static void getCadenceDataTest() {
		Cadence__c cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_OR, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadLeadAND.Entrance_Criteria__c = entryJson;
		cadLeadAND.Exit_Criteria__c = exitJson;
		insert cadLeadAND;
		Test.startTest();
		CadenceController.getCadenceData(cadLeadAND.Id);
		Test.stopTest();
	}

	@isTest
	static void getCadenceDataTestOpp() {
		Opportunity opp = TestDataFactory.createOpp('Test');
		Cadence__c cadOppAND = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test1', CadenceConstants.CONDITION_AND, '');
		cadOppAND.Entrance_Criteria__c = entryJson;
		cadOppAND.Exit_Criteria__c = exitJson;
		insert cadOppAND;

		Test.startTest();
		CadenceController.getCadenceData(cadOppAND.Id);
		Test.stopTest();
	}

	@isTest
	public static void activateCadenceTestOpp(){
		Opportunity opp = TestDataFactory.createOpp('Test');
		insert opp;
		System.assertNotEquals(null, opp);
		Cadence__c cadenceobj = TestDataFactory.createCadence('Opportunity');
		String entryJson = TestDataFactory.createCadJsonWithConditionalCriterionsForOpp('123', CadenceConstants.CONDITION_OR, '','greater');
		String exitJson = TestDataFactory.createCadJsonWithConditionalCriterionsForOpp('1234', CadenceConstants.CONDITION_AND, '','less_than');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	}

	@isTest
	public static void activateCadenceTestOpp2(){
		Opportunity opp = TestDataFactory.createOpp('Test opp-02');
		insert opp;
		System.assertNotEquals(null, opp);
		Cadence__c cadenceobj = TestDataFactory.createCadence('Opportunity');
		String entryJson = TestDataFactory.createCadJsonWithConditionalCriterionsForOpp('123', CadenceConstants.CONDITION_OR, '','greater_or_equals');
		String exitJson = TestDataFactory.createCadJsonWithConditionalCriterionsForOpp('1234', CadenceConstants.CONDITION_AND, '','less_or_equals');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  
		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	}

	@isTest
	public static void activateSequenceTestOppRole(){
		Opportunity opp = TestDataFactory.createOpp('Test role');
		insert opp;
		System.assertNotEquals(null, opp);
		Contact c1= new Contact();
		c1.FirstName='test Role';
		c1.LastName='contact';
		c1.Department='IT';
		insert c1;
		System.assertNotEquals(null, c1);
		OpportunityContactRole contactRole = new OpportunityContactRole(Role='Decision Maker',ContactId=c1.Id,OpportunityId=opp.id);
		insert contactRole;
		System.assertNotEquals(null, contactRole);

		Cadence__c cadenceobj = TestDataFactory.createCadence('Opportunity');
		String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Decision Maker', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Business User', CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c = entryJson;
		cadenceobj.Exit_Criteria__c = exitJson;
		insert cadenceobj;  

		cadenceobj.Status__c=true;
		upsert cadenceobj;
		Test.startTest();
		CadenceController.activateCadence(cadenceobj.Id);
		Test.stopTest();
		cadenceobj=[select Id, Status__c from Cadence__c where id =: cadenceobj.Id];
		System.assertEquals(True, cadenceobj.Status__c, 'Cadence Activated');
	}

	@isTest
	static void getObjCriListTest() {
		Test.startTest();
		CadenceController.getObjCriList('Contact');
		Test.stopTest();
	}
}