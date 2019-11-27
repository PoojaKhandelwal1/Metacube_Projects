@isTest
public class CadenceActionsControllerTest {

	public static Final String ACTION_TYPE_CALL = 'Call';
	@isTest
	public static void getActionListTest(){
		Action__c actionList1= TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionList1;
		Action__c actionList2= TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionList2;
		CadenceActionsController.CadenceActionWrapper cadencewrap;
		CadenceActionsController.UiInputList uiInputwrap;
		Test.startTest();
		cadencewrap= CadenceActionsController.getActionList('Lead');
		uiInputwrap = CadenceActionsController.createListForUIInput();
		Test.stopTest();
		System.assertEquals(2, cadencewrap.actionList.size(), 'actionlist size must be two');
		System.assertEquals(1, cadencewrap.actionTypeList.size(), 'actiontypelist size must be one');
	}
}