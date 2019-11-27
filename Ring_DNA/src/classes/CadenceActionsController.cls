public class CadenceActionsController {
	public static String nameSpace = CadenceConstants.NAMESPACE;

	@AuraEnabled
	public static CadenceActionWrapper getActionList(String type){
		List<action__C> actionList = [Select Id, Name, type__c, Activation_Type__c from Action__c];
		List<Action> actionClsList = new List<Action>();
		for (action__C action : actionList){
			actionClsList.add(New Action(action.Id, action.Activation_Type__c, action.Name, '','', '', action.Type__c));
		}
		CadenceActionWrapper wrapperObj = new CadenceActionWrapper();
		wrapperObj.actionList = actionList;
		wrapperObj.actionClsList = actionClsList;
		wrapperObj.actionTypeList = getActionTypeList(actionList);
		wrapperObj.fieldList = CadenceController.getFieldsForSA(type);

		return wrapperObj;
	}  

	public class CadenceActionWrapper{
		@AuraEnabled public List<action__C> actionList;
		@AuraEnabled public List<Action> actionClsList;
		@AuraEnabled public List<string> actionTypeList;
		@AuraEnabled public List<CriterionWrapper> fieldList = New List<CriterionWrapper>{New CriterionWrapper()};
	}

	public static List<String> getActionTypeList(List<Action__C> actionList){
		List<String> actionTypeList = new List<String>();
		for (Action__C actObj : actionList){
			if(!actionTypeList.contains(actObj.type__c)){
				actionTypeList.add(actObj.type__c);
			}
		}
		return actionTypeList;
	}

	@AuraEnabled
	public static UiInputList createListForUIInput(){
		UiInputList uilObj = new UiInputList();
		uilObj.pList = CadenceService.getPicklistValues(nameSpace+'CadenceAction__c', nameSpace+'Priority__c');
		return uilObj;
	}

	public class UiInputList{
		@AuraEnabled
		public List<String> pList;        
		public UiInputList(){
			pList = new List<String>();           
		}
	}
}