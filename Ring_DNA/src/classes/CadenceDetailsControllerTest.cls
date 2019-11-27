@isTest
public class CadenceDetailsControllerTest {
	@isTest
	static void createListForUIInputTest(){
		CadenceDetailsController.UiInputList uiobj = new CadenceDetailsController.UiInputList();
		Test.startTest();
		CadenceDetailsController.createListForUIInput();
		Test.stopTest();       
	}
}