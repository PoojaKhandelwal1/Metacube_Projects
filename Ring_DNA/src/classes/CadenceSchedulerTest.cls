@isTest
public class CadenceSchedulerTest {

	public static testMethod void testschedule() {
		Test.StartTest();
		CadenceScheduler sh1 = new CadenceScheduler();
		String sch = '0 0 0 * * ?'; 
		system.schedule('Test Territory Check', sch, sh1); 
		Test.stopTest(); 
	}

}