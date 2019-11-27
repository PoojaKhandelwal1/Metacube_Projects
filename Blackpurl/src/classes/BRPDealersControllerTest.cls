@isTest
private class BRPDealersControllerTest {
	
	@testSetup
    private static void setupTestData() {
    	BRP_Dealers__c brpDealerRec = new BRP_Dealers__c();
    	brpDealerRec.Party_ID__c = '123';
    	brpDealerRec.Telephone__c = '36253673';
    	brpDealerRec.Fax__c = 'testFax';
    	brpDealerRec.Website__c = 'test website';
    	brpDealerRec.Email__c = 'test@gmail.com';
    	brpDealerRec.Street__c = 'test street';
    	brpDealerRec.Line_Two__c = 'test address2';
    	brpDealerRec.City__c = 'test city';
    	brpDealerRec.Postcode__c = '356253';
    	brpDealerRec.State__c = 'test state';
    	brpDealerRec.Country__c = 'test country';
    	brpDealerRec.Company_Name__c = 'test company';
    	insert brpDealerRec;
    	
    	List<BRP_Dealer_Product_Line__c> brpDealerProductLineList = new List<BRP_Dealer_Product_Line__c>();
    	brpDealerProductLineList.add(new BRP_Dealer_Product_Line__c(Name = 'Test product 1', BRP_Dealer__c = brpDealerRec.Id));
    	brpDealerProductLineList.add(new BRP_Dealer_Product_Line__c(Name = 'Test product 2', BRP_Dealer__c = brpDealerRec.Id));
    	brpDealerProductLineList.add(new BRP_Dealer_Product_Line__c(Name = 'Test product 3', BRP_Dealer__c = brpDealerRec.Id));
    	insert brpDealerProductLineList;
    }

	@isTest
    private static void getDealerTest() {
    	BRPDealersController brpDealersControllerObj = new BRPDealersController();
    	BRPDealersController brpDealersControllerWithHomePageObj = new BRPDealersController(new NewHomePageCtrl());
    	
    	Test.startTest();
    	String result = BPUtility.getDecodedString(BRPDealersController.getDealer());
    	List<BRPDealerWrapper> brpDealerWrapperList = (List<BRPDealerWrapper>)system.JSON.deserialize(result, List<BRPDealerWrapper>.class);
    	System.assertEquals(brpDealerWrapperList[0].PartyId, '123');
    	Test.stopTest();
    }
}