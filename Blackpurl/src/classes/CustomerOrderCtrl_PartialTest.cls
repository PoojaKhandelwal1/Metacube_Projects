global with sharing class CustomerOrderCtrl_PartialTest {
    
    @future
	global static void moveLineItemFromOneServiceOrderToAnother(String sectionFrom, String sectionTo, String idToMove, String coHeaderId){
		String movedLineItem = BPUtility.getDecodedString(CustomerOrderCtrl.moveLineItem(BPUtility.getEncodedString(sectionFrom), BPUtility.getEncodedString(sectionTo), BPUtility.getEncodedString(idToMove), BPUtility.getEncodedString(coHeaderId)));
        SOHeaderWrapper SOHeaderDetails22 = (SOHeaderWrapper) System.JSON.deserialize(movedLineItem, SOHeaderWrapper.class);
	}
    
}