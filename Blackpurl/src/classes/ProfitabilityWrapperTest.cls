@isTest
private class ProfitabilityWrapperTest {
    
    @isTest
    private static void testWrapper(){
    	Test.startTest();
    	ProfitabilityWrapper.ProductProfitabilityWrapper productProfitabilityWrapper1 = new ProfitabilityWrapper.ProductProfitabilityWrapper('productName1', 100, 100);
    	ProfitabilityWrapper.ProductProfitabilityWrapper productProfitabilityWrapper2 = new ProfitabilityWrapper.ProductProfitabilityWrapper('productName2', 100, 100);
    	ProfitabilityWrapper.ProductProfitabilityWrapper productProfitabilityWrapper3 = new ProfitabilityWrapper.ProductProfitabilityWrapper('productName3', 100, 100);
    	ProfitabilityWrapper.ProductProfitabilityWrapper productProfitabilityWrapper4 = new ProfitabilityWrapper.ProductProfitabilityWrapper('productName4', 100, 100);
    	
    	List<ProfitabilityWrapper.ProductProfitabilityWrapper> productProfitabilityWrapperList = new List<ProfitabilityWrapper.ProductProfitabilityWrapper>();
    	productProfitabilityWrapperList.add(productProfitabilityWrapper1);
    	productProfitabilityWrapperList.add(productProfitabilityWrapper2);
    	productProfitabilityWrapperList.add(productProfitabilityWrapper3);
    	productProfitabilityWrapperList.add(productProfitabilityWrapper4);
    	
    	ProfitabilityWrapper.SectionProfitabilityWrapper sectionProfitabilityWrapper1 = new ProfitabilityWrapper.SectionProfitabilityWrapper('sectionName1', productProfitabilityWrapperList);
    	ProfitabilityWrapper.SectionProfitabilityWrapper sectionProfitabilityWrapper2 = new ProfitabilityWrapper.SectionProfitabilityWrapper('sectionName2', productProfitabilityWrapperList);
    	ProfitabilityWrapper.SectionProfitabilityWrapper sectionProfitabilityWrapper3 = new ProfitabilityWrapper.SectionProfitabilityWrapper('sectionName3', productProfitabilityWrapperList);
    	ProfitabilityWrapper.SectionProfitabilityWrapper sectionProfitabilityWrapper4 = new ProfitabilityWrapper.SectionProfitabilityWrapper('sectionName4', productProfitabilityWrapperList);
    	
    	List<ProfitabilityWrapper.SectionProfitabilityWrapper> sectionProfitabilityWrapperList = new List<ProfitabilityWrapper.SectionProfitabilityWrapper>();
    	sectionProfitabilityWrapperList.add(sectionProfitabilityWrapper1);
    	sectionProfitabilityWrapperList.add(sectionProfitabilityWrapper2);
    	sectionProfitabilityWrapperList.add(sectionProfitabilityWrapper3);
    	sectionProfitabilityWrapperList.add(sectionProfitabilityWrapper4);
    	
		ProfitabilityWrapper profitabilityWrapper = new ProfitabilityWrapper(sectionProfitabilityWrapperList);
		system.assertEquals(1600.00, profitabilityWrapper.COTotalSales);
    	Test.stopTest();
    }
}