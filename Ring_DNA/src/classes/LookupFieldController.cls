public class LookupFieldController {
	public static String nameSpace = CadenceConstants.NAMESPACE;

	public class UserListWrapper{
		@AuraEnabled public String userName;
		@AuraEnabled public String userId;
	} 

	public class DandBCompanyListWrapper{
		@AuraEnabled public String Name;
		@AuraEnabled public String Id;
	} 

	public class UserAndDandBWrappers{
		@AuraEnabled public List<LookupFieldController.UserListWrapper> userWrapper;
		@AuraEnabled public List<LookupFieldController.DandBCompanyListWrapper> dandbWrapper;
	} 

	@AuraEnabled
	public static UserAndDandBWrappers getUserAndDandBWrappers(){
		UserAndDandBWrappers userAndDandBList = New UserAndDandBWrappers();
		userAndDandBList.userWrapper = CadenceService.getUserWrapperList();
		userAndDandBList.dandbWrapper = CadenceService.getDandBCompanyWrapperList();
		return userAndDandBList;
	}
}