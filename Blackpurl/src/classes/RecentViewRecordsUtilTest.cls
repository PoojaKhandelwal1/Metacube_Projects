@isTest 
public class RecentViewRecordsUtilTest {
	
	@testSetup
    private static void setupTestData() {
    	Category__c categoryRec = TestDataFactory.createCategory('Test');
    }
    
    @isTest
    private static void getOrgBlankSearchResultsTest() {
    	Utility.PageAndSortFilter pageSortFilter = new Utility.PageAndSortFilter();
    	pageSortFilter.PageSize = 2;
    	pageSortFilter.PageNumber = 1;
    	pageSortFilter.SearchText = 'Text';
    	List<Utility.SortByMapping> sortMappingList = new List<Utility.SortByMapping>(); 
    	sortMappingList.add(new Utility.SortByMapping('T', 'DESC'));
    	pageSortFilter.SortBy = sortMappingList;
    	RecentViewRecordsUtil.getOrgBlankSearchResults(pageSortFilter);
    	system.assertEquals(Utility.sortMapping.size(), 0);
    }
     
    @isTest
    private static void getOrgBlankSearchResultsFilterPresentTest() {
    	Utility.PageAndSortFilter pageSortFilter = new Utility.PageAndSortFilter();
    	pageSortFilter.PageSize = 2;
    	pageSortFilter.PageNumber = 1;
    	pageSortFilter.SearchText = 'Text';
    	List<Utility.SortByMapping> sortMappingList = new List<Utility.SortByMapping>();
    	sortMappingList.add(new Utility.SortByMapping('Abcd', 'DESC'));
    	pageSortFilter.SortBy = sortMappingList;
    	RecentViewRecordsUtil.getOrgBlankSearchResults(pageSortFilter);
    	system.assertEquals(Utility.sortMapping.size(), 1);
    }
}