@isTest
public class CadenceUtilTest {
	@isTest
	public static void testMethod1(){
		Lead l1= new Lead();
		l1.Company='Test#121';
		l1.FirstName='Test#121';
		l1.LastName='Test#121';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';
		insert l1;
		System.assertNotEquals(null, l1);

		CadenceUtil.getObjectFieldsType('Lead');
		CadenceUtil.getObjectQuery('Lead',new List<Id>{l1.id});
	}

	@isTest
	public static void CheckObjectHasAccessOrNot(){

		Test.startTest();
		List<String> objectList1 = CadenceUtil.getValidSObjectListInOrg(new List<String>{CadenceConstants.LEAD_OBJECT_NAME});
		System.assertEquals(CadenceConstants.LEAD_OBJECT_NAME, objectList1[0]);

		List<String> objectList2 = CadenceUtil.getValidSObjectListInOrg(new List<String>{'XYZ'});
		System.assertEquals(0, objectList2.size());
		Test.stopTest();
	}    
}