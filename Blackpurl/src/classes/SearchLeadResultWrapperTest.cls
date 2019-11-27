@isTest 
public class SearchLeadResultWrapperTest {
	
	@isTest
    private static void searchLeadResultWrapperTest() {
    	SearchLeadResultWrapper searchWrapper = new SearchLeadResultWrapper();
    	SearchLeadResultWrapper.parse(System.JSON.serialize(searchWrapper));
    	System.assertNotEquals(searchWrapper, null);
    }
}