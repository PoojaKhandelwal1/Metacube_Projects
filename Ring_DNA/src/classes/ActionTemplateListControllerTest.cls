@isTest
public class ActionTemplateListControllerTest {

	public static string jsonStrForOneRecord ='[{"enabled": true,"groups": [], "id": 30, "name": "Sumit SMS Template","template": "Implemented for cadence"}]' ;

	static testMethod void fetchActionTemplatesTest(){
		test.startTest();
		ActionTemplateListController.fetchActionTemplates('Call');
		test.stopTest();
	}
}