public class CadenceActionListController {

	public static String nameSpace = CadenceConstants.NAMESPACE;

	public class ActionWrapper {
		@AuraEnabled public Id actionId;
		@AuraEnabled public String name;
		@AuraEnabled public String type;
		@AuraEnabled public Integer cadences;
		@AuraEnabled public Integer participants;
		@AuraEnabled public Double effectivity;
	}

	public class ActionDeleteMessageWrapper {
		public ActionDeleteMessageWrapper(){
			actionIds = new List<Id>();
			name = '';
			deletedCount = 0;
		}
		@AuraEnabled public List<Id> actionIds;
		@AuraEnabled public String name;
		@AuraEnabled public Integer deletedCount;
	}

	public class CadenceWrapper {
		@AuraEnabled public Id cadId;
		@AuraEnabled public String name;
		@AuraEnabled public String status;
		@AuraEnabled public String objType;
		@AuraEnabled public String activation;
		@AuraEnabled public Integer participants;

		public CadenceWrapper(Id cadId, String name, Boolean status, String objType, String activation) {
			this.cadId = cadId;
			this.name = name;
			if(status) {
				this.status = 'Active';
			} else {
				this.status = 'Inactive';
			}
			this.objType = objType;
			this.activation = activation;
		}
	}

	@AuraEnabled
	public static List<ActionWrapper> fetchCadenceActions() {

		List<ActionWrapper> actionWrapperList = new List<ActionWrapper>();
		Map<Id, Integer> cadenceCount = new Map<Id, Integer>();

		//getting all the actions and their types
		List<Action__c> actionList = [SELECT Id, Name, Type__c FROM Action__c Order by CreatedDate desc];
		//Getting all the cadences count 
		List<AggregateResult> cadenceActions = [SELECT Action_Id__c, COUNT_DISTINCT(Cadence_Id__c) cadenceCount FROM CadenceAction__c GROUP BY Action_Id__c];
		for(AggregateResult result : cadenceActions) {
			cadenceCount.put((Id)result.get(nameSpace+'Action_Id__c'), (Integer)result.get('cadenceCount'));
		}

		//Getting all participants counts
		Map<Id, Integer> actionWiseParticipants = getActionWiseParticipants();

		for(Action__c action : actionList) {
			ActionWrapper actionWrap = new ActionWrapper();
			actionWrap.actionId = action.Id;
			actionWrap.name	= action.Name;
			actionWrap.type = action.Type__c;
			if(cadenceCount.containsKey(action.Id)) {
				actionWrap.cadences = cadenceCount.get(action.Id);
			} else {
				actionWrap.cadences = 0;  				             
			}
			if(actionWiseParticipants.containsKey(action.Id)) {
				actionWrap.participants = actionWiseParticipants.get(action.Id);
			} else { 
				actionWrap.participants = 0;
			}
			actionWrapperList.add(actionWrap);
		}
		return actionWrapperList;
	}

	@AuraEnabled 
	public static List<CadenceWrapper> getCadenceData() {
		// Start CadenceScheduler 
		CadenceUtil.startCadenceScheduler();
		//getting all the cadences and their types
		List<Cadence__c> cadenceList = [SELECT Id, Name, Status__c, Record_Type__c, Participent_Activation__c FROM Cadence__c Order by CreatedDate desc];

		//Getting cadence wise participants 
		Map<Id, Integer> cadWiseParts = getCadenceWiseParticipants();

		List<CadenceWrapper> cadWrapList = new List<CadenceWrapper>();
		for(Cadence__c cad : cadenceList) {
			CadenceWrapper cadWrap = new CadenceWrapper(cad.Id, cad.Name, cad.status__c, cad.Record_Type__c, cad.Participent_Activation__c);
			if(cadWiseParts.containsKey(cad.Id)) {
				cadWrap.participants = cadWiseParts.get(cad.Id);
			} else {
				cadWrap.participants = 0;
			}
			cadWrapList.add(cadWrap);
		}

		return cadWrapList;

	}

	@AuraEnabled
	public static void deleteCadences(List<Id> cadIds) {
		if(!cadIds.isEmpty()) {
			List<Cadence__c> cadencesToDelete = new List<Cadence__c>();
			for(Id cadId: cadIds) {
				Cadence__c obj = new Cadence__c(Id = cadId);
				cadencesToDelete.add(obj);
			}
			deleteActionOnpartcipants(cadIds);
			delete cadencesToDelete;
		}    
	}


	@AuraEnabled
	public static ActionDeleteMessageWrapper ExcludedDeleteActions(List<Id> actionIds) {
		ActionDeleteMessageWrapper actionDeleteMessageWrapper = new ActionDeleteMessageWrapper();
		if(!actionIds.isEmpty()) {
			List<CadenceAction__c> cadenceActons = [Select Action_Id__c,Action_Id__r.Name, Cadence_Id__r.Name,
			                                        (Select isActionPerformed__c from Sequence_Actions__r where isActionPerformed__c = false)
			                                        from CadenceAction__c
			                                        Where Action_Id__c in : actionIds //Cadence_Id__r.Status__c = True 
			                                        Order by Action_Id__r.Name];
			Map<ID, CadenceAction__c> cadenceActonsMap = new Map<ID, CadenceAction__c>();
			for(CadenceAction__c cadAcaion : cadenceActons){
				cadenceActonsMap.put(cadAcaion.Action_Id__c,cadAcaion);
			}
			for(Id id : cadenceActonsMap.keySet()){
				CadenceAction__c cadAcaion = cadenceActonsMap.get(id);
				if(cadAcaion.Sequence_Actions__r.size() > 0){
					actionDeleteMessageWrapper.actionIds.add(cadAcaion.Action_Id__c);
					actionDeleteMessageWrapper.name  = actionDeleteMessageWrapper.name + cadAcaion.Action_Id__r.Name + ',';
				}
			}
			actionDeleteMessageWrapper.deletedCount = (actionIds.size() - cadenceActonsMap.keySet().size());
		}  
		return actionDeleteMessageWrapper;
	}

	public static Boolean IsExistActionId(List<Id> actionIds,Id actionId){
		Boolean IsExist = false;
		for(Id id : actionIds){
			if(actionId == id){
				IsExist = true;
				break;
			}
		}
		return IsExist;
	}

	@AuraEnabled
	public static ActionDeleteMessageWrapper deleteActions(List<Id> actionIds) {
		ActionDeleteMessageWrapper actionDeleteMessageWrapper;
		if(!actionIds.isEmpty()) {
			List<Action__c> actionsToDelete = new List<Action__c>();
			actionDeleteMessageWrapper = ExcludedDeleteActions(actionIds);
			for(Id actionId: actionIds) {
				if(!IsExistActionId(actionDeleteMessageWrapper.actionIds, actionId)){
					Action__c obj = new Action__c(Id =actionId);
					actionsToDelete.add(obj);
				}
			}

			delete actionsToDelete;
		} 

		if(actionDeleteMessageWrapper != null && actionDeleteMessageWrapper.name.length() > 0){
			actionDeleteMessageWrapper.name = actionDeleteMessageWrapper.name.substring(0, actionDeleteMessageWrapper.name.length() -1);
		}

		return actionDeleteMessageWrapper;
	}


	public static Map<Id, Integer> getCadenceWiseParticipants() {
		Map<Id, Integer> cadWiseParticipants = new Map<Id, Integer>();
		List<AggregateResult> cadParticipants = [Select Cadence_ID__c, count(Id) participants from Contact where Cadence_Id__c!=null group by Cadence_ID__c];
		cadParticipants.addAll([Select Cadence_ID__c, count(Id) participants from Lead where Cadence_Id__c!=null AND IsConverted = False group by Cadence_ID__c]);

		if(!cadParticipants.isEmpty()) {
			for(AggregateResult result : cadParticipants) {
				if(cadWiseParticipants.containsKey((Id)result.get(nameSpace+'Cadence_ID__c'))) {
					cadWiseParticipants.put((Id)result.get(nameSpace+'Cadence_ID__c'), (cadWiseParticipants.get((Id)result.get(nameSpace+'Cadence_ID__c')) + (Integer)result.get('participants')));
				} else {
					cadWiseParticipants.put((Id)result.get(nameSpace+'Cadence_ID__c'), (Integer)result.get('participants'));
				}
			}
		}
		return cadWiseParticipants;
	}

	public static Map<Id, Integer> getActionWiseParticipants() {
		Map<Id, Integer> actionWiseParticipants = new Map<Id, Integer>();
		Map<Id, Integer> cadWiseParticipants = getCadenceWiseParticipants();
		Map<Id, Set<Id>> actionIdToCadencesIds = new Map<Id, Set<Id>>();
		List<CadenceAction__c> cadActions = [Select Id, Cadence_Id__c, Action_Id__c from CadenceAction__c];

		for(CadenceAction__c action : cadActions) {

			if(actionIdToCadencesIds.containsKey(action.Action_Id__c)) {
				actionIdToCadencesIds.get(action.Action_Id__c).add(action.Cadence_Id__c);
			} else {
				actionIdToCadencesIds.put(action.Action_Id__c, new Set<Id>{action.Cadence_Id__c});
			}
		}

		for(Id actId : actionIdToCadencesIds.keySet()) {
			for(Id cadId : actionIdToCadencesIds.get(actId)) {
				if(cadWiseParticipants.containsKey(cadId)) {
					if(actionWiseParticipants.containsKey(actId)) {
						actionWiseParticipants.put(actId, actionWiseParticipants.get(actId) + cadWiseParticipants.get(cadId));
					} else {
						actionWiseParticipants.put(actId, cadWiseParticipants.get(CadId));
					}
				}
			}
		}
		return actionWiseParticipants;
	}

	public static void deleteActionOnpartcipants(List<Id> cadIds){  
		String query = 'SELECT Id FROM Sequence_Action__c WHERE isActionPerformed__c = false AND CadenceAction_ID__r.Cadence_Id__c  IN ' + CadenceUtil.getWhereClauseForListOfIds(cadIds);
		Integer dmlLimits = CadenceConstants.DMLOPERATION;
		Integer  actionOnParticipantsCount = [select COUNT() from Sequence_Action__c where CadenceAction_ID__r.Cadence_Id__c  IN :cadIds and isActionPerformed__c=false];
		if(actionOnParticipantsCount >= dmlLimits){
			PerformDMLActionBatch dmlOperation=new PerformDMLActionBatch(query,CadenceConstants.DMLDELETE,'');
			Database.executeBatch(dmlOperation,200);
		}else{
			Database.delete([select Id from Sequence_Action__c where CadenceAction_ID__r.Cadence_Id__c  IN :cadIds and isActionPerformed__c=false], false);
			dmlLimits = dmlLimits - actionOnParticipantsCount;
		}

		query = 'select Id,Opportunity_Id__c from Contact where Cadence_ID__c  IN '+CadenceUtil.getWhereClauseForListOfIds(cadIds)+' and Opportunity_Id__c != null';
		Integer contactCount = [select COUNT() from Contact where Cadence_ID__c  IN :cadIds and Opportunity_Id__c != null];
		if(contactCount >= dmlLimits){
			PerformDMLActionBatch dmlOperation=new PerformDMLActionBatch(query,CadenceConstants.DMLUPDATE,CadenceConstants.SETCONTACTOPPNULL);
			Database.executeBatch(dmlOperation,200);
		}else{
			List<Contact> contactList = [select Id,Opportunity_Id__c from Contact where Cadence_ID__c  IN :cadIds and Opportunity_Id__c != null];
			if(contactList != null && contactList.size() > 0){
				for(Contact con : contactList){
					con.Opportunity_Id__c = null;
				}
				Database.update(contactList, false);
			}
		}
	}
}