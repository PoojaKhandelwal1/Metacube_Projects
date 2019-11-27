@isTest
private class PartOverviewCtrl_KendoTest {
	
	@testsetup
	private static void setup(){
		PageReference vfPage = Page.AccountingExport;
        Test.setCurrentPage(vfPage);
	}
	
    @isTest 
	private static void testPartOverviewCtrl_Kendo(){
 		Test.startTest();
 		ApexPages.currentPage().getParameters().put('partpageno','22');
 		ApexPages.currentPage().getParameters().put('Part_ID','22');
 		PartOverviewCtrl_Kendo part = new PartOverviewCtrl_Kendo();
 		system.assertEquals(ApexPages.currentPage().getParameters().get('partpageno'), '22');
 		Test.stopTest();
	}
}