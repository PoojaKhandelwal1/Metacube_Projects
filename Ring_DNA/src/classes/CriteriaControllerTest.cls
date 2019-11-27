@isTest
public class CriteriaControllerTest {
	@isTest
	public static void getFieldsTest(){
		Test.startTest();
		CriteriaController.getFields('Contact');
		Test.stopTest();
	}
}