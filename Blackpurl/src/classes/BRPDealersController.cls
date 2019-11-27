global with sharing class BRPDealersController {  

    global BRPDealersController(NewHomePageCtrl controller){} 
    public BRPDealersController() { }    
 
    @RemoteAction
    global static String getDealer() {
        if(AccessControl.ifObjectIsAccessible('BRP_Dealers__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<BRP_Dealers__c> dealerList = [SELECT City__c, Company_Name__c, Country__c, Email__c, Fax__c, Line_Two__c, Party_ID__c, Person_Name__c,
                                                Postcode__c, State__c, Street__c, Telephone__c, Type_Code__c, Website__c,
                                                (SELECT Name FROM BRP_Dealer_Product_Lines__r)
                                                FROM BRP_Dealers__c WHERE Company_Name__c != null];
        
        List<BRPDealerWrapper> brpDealerWrapperObjList = new List<BRPDealerWrapper>();
        for(BRP_Dealers__c brpDealerRec : dealerList) {
        	brpDealerWrapperObjList.add(new BRPDealerWrapper(brpDealerRec));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(brpDealerWrapperObjList));
    }
}