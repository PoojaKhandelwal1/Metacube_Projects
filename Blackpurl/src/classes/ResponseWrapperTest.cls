@isTest 
public class ResponseWrapperTest {
	
	@isTest
    private static void responseWrapperTest() {
    	ResponseWrapper responseWrapper = new ResponseWrapper('status', 'response');
    	system.assertNotEquals(null, responseWrapper);
    }
    
    @isTest
    private static void responseWrapperConstrucutorTest() {
    	ResponseWrapper responseWrapper = new ResponseWrapper(123, 'response');
    	system.assertNotEquals(null, responseWrapper);
    }
}