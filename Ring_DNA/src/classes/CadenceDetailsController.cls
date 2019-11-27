public class CadenceDetailsController {

	public static String nameSpace = CadenceConstants.NAMESPACE;

	@AuraEnabled
	public static UiInputList createListForUIInput(){
		UiInputList uilObj = new UiInputList();
		uilObj.mpList = CadenceService.getPicklistValues(nameSpace+'Cadence__c', nameSpace+'matching_priority__c');
		uilObj.atList = CadenceService.getPicklistValues(nameSpace+'Cadence__c', nameSpace+'Participent_Activation__c');
		return uilObj;
	}
	public class UiInputList{
		@AuraEnabled
		public List<String> mpList;
		@AuraEnabled
		public List<String> atList;
		public UiInputList(){
			mpList = new List<String>();
			atList = new List<String>();
		}
	}
}