@isTest
public class PerformDMLActionBatchTest {
	Public static Final String ACTION_TYPE_CALL = 'Call';

	@isTest 
	static void DeleteSequenceTest(){
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c='Contact';
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Jon', 'Smith', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test2', CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		Opportunity opportunity = TestDataFactory.createOpp('Test-opp-01');
		insert opportunity;

		List<Contact> contactList = new List<Contact>();
		Integer i=0;
		Account acct = new Account(Name='SFDC Account');
		insert acct;

		Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.AllowSave = true;

		ID acctID = acct.ID;
		for(i=1;i<=10;i++){
			Contact con = new Contact(
					FirstName='Joe' + String.valueOf(i) ,
					LastName='Smith',
					Phone='415.555.1212',
					Cadence_ID__c = cadence1.Id,
					Opportunity_Id__c=opportunity.ID,
					AccountId=acctID);
			contactList.add(con);
		}
		Database.insert(contactList, dml);

		Action__c action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action1.Activation_Type__c = 'Automatic';
		insert action1;

		CadenceAction__c cadenceAction =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction.Day__c= 0;
		cadenceAction.Hour__c= 0;
		cadenceAction.Trigger_Type__c = 'Immediate';

		insert cadenceAction;
		System.assertNotEquals(null, cadenceAction.Id);

		List<Sequence_Action__c> listOfAction = new  List<Sequence_Action__c>();
		for(Contact con : contactList){
			Sequence_Action__c seqAction  =  new Sequence_Action__c();
			seqAction.CadenceAction_Id__c = cadenceAction.id;
			seqAction.isActionPerformed__c =false;
			seqAction.Contact_Id__c = con.Id;
			listOfAction.add(seqAction) ;
		}
		insert listOfAction;


		Test.startTest();
		List<Contact> contactListnew = [select Id,Opportunity_Id__c from Contact where Opportunity_Id__c != null];
		System.assertEquals(10, contactListnew.size());

		CadenceActionListController.deleteCadences(new List<Id>{cadence1.Id});
		Integer countSeq = [Select COUNT() from Sequence_Action__c];
		System.assertEquals(0, countSeq);
		Test.stopTest();
	}

	@isTest 
	static void BatchOperationTest(){
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c='Contact';
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Jon', 'Smith', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test2', CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		Opportunity opportunity = TestDataFactory.createOpp('Test-opp-01');
		insert opportunity;

		List<Contact> contactList = new List<Contact>();
		Integer i=0;
		Account acct = new Account(Name='SFDC Account');
		insert acct;

		Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.AllowSave = true;

		ID acctID = acct.ID;
		for(i=1;i<=10;i++){
			Contact con = new Contact(
					FirstName='Joe' + String.valueOf(i) ,
					LastName='Smith',
					Phone='415.555.1212',
					Cadence_ID__c = cadence1.Id,
					Opportunity_Id__c=opportunity.ID,
					AccountId=acctID);
			contactList.add(con);
		}
		Database.insert(contactList, dml);

		Action__c action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action1.Activation_Type__c = 'Automatic';
		insert action1;

		CadenceAction__c cadenceAction =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction.Day__c= 0;
		cadenceAction.Hour__c= 0;
		cadenceAction.Trigger_Type__c = 'Immediate';

		insert cadenceAction;
		System.assertNotEquals(null, cadenceAction.Id);

		List<Sequence_Action__c> listOfAction = new  List<Sequence_Action__c>();
		for(Contact con : contactList){
			Sequence_Action__c seqAction  =  new Sequence_Action__c();
			seqAction.CadenceAction_Id__c = cadenceAction.id;
			seqAction.isActionPerformed__c =false;
			seqAction.Contact_Id__c = con.Id;
			listOfAction.add(seqAction) ;
		}
		insert listOfAction;
		String query1 = 'select Id,Opportunity_Id__c from Contact where Cadence_ID__c  IN '+CadenceUtil.getWhereClauseForListOfIds(new List<Id>{cadence1.Id})+' and Opportunity_Id__c != null';
		String query2 = 'SELECT Id FROM Sequence_Action__c WHERE isActionPerformed__c = false AND CadenceAction_ID__r.Cadence_Id__c  IN ' + CadenceUtil.getWhereClauseForListOfIds(new List<Id>{cadence1.Id});    

		Test.startTest();
		PerformDMLActionBatch dmlOperation1=new PerformDMLActionBatch(query1,CadenceConstants.DMLUPDATE,CadenceConstants.SETCONTACTOPPNULL);
		Database.executeBatch(dmlOperation1,200);

		PerformDMLActionBatch dmlOperation=new PerformDMLActionBatch(query2,CadenceConstants.DMLDELETE,'');
		Database.executeBatch(dmlOperation,200);
		Test.stopTest();
	}
}