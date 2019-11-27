public class TargetListController {

	public static String nameSpace = CadenceConstants.NAMESPACE;

	@AuraEnabled
	public static String retrieveSesstionId() {
		return UserInfo.getSessionId();
	}

	@AuraEnabled
	public static List<TargetListWrapper> getTargetList(String pgId){

		List<TargetListWrapper> tlList = New List<TargetListWrapper>();
		// pgId - Public group id 
		tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.LEAD_OBJECT_NAME, pgId));
		tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.CONTACT_OBJECT_NAME, pgId));
		TargetListInit tlObj = New TargetListInit();
		tlObj.tlWList = tlList;                      
		return tlList;

	} 

	@AuraEnabled 
	public static TargetListInit getTargetListInitData(String pgId){

		List<TargetListWrapper> tlList = New List<TargetListWrapper>();
		tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.LEAD_OBJECT_NAME, pgId));
		tlList.AddAll(TargetListController.getTargetListforSObject(CadenceConstants.CONTACT_OBJECT_NAME, pgId));
		TargetListInit tlObj = New TargetListInit();
		List<Group> gList =  CadenceSelector.getAllPublicGroup(); 
		List<GrouplistWrapper> pgList = new List<GrouplistWrapper>();
		GrouplistWrapper glwObj = new GrouplistWrapper();
		glwObj.Id = String.ValueOf(UserInfo.getUserID());
		glwObj.Name = 'Record Owner';
		pgList.add(glwObj);
		for (Group gObj : gList){
			GrouplistWrapper obj = new GrouplistWrapper(); 
			obj.Id = String.ValueOf(gObj.Id);
			obj.Name = gObj.Name;
			pgList.add(obj);
		}
		tlObj.pgList = pgList;
		tlObj.tlWList = tlList;
		tlObj.selectedGroup = pgId;
		return tlObj;
	}

	public class TargetListInit{
		@AuraEnabled public List<GrouplistWrapper> pgList;
		@AuraEnabled public List<TargetListWrapper> tlWList;
		@AuraEnabled public String selectedGroup;
	}
	public class GrouplistWrapper {
		@AuraEnabled public String Id;
		@AuraEnabled public String Name;
	}
	public class TargetListWrapper {
		@AuraEnabled public String name;
		@AuraEnabled public String linkActionName;
		@AuraEnabled public Integer priorityNumber;
		@AuraEnabled public String priority;
		@AuraEnabled public String company;
		@AuraEnabled public String companyId;
		@AuraEnabled public String type;
		@AuraEnabled public String actionType;
		@AuraEnabled public String email;
		@AuraEnabled public String phone;
		@AuraEnabled public String mobile;
		@AuraEnabled public String nextAction;
		@AuraEnabled public String actionPerformDay;
		@AuraEnabled public String participantId;
		@AuraEnabled public String participantActionsId;        
		@AuraEnabled public String emailTempId;
		@AuraEnabled public String tempId;
		@AuraEnabled public String cadenceId;
		@AuraEnabled public String cadenceName;
		@AuraEnabled public String taskId;
		@AuraEnabled public String emailType;
		@AuraEnabled public String nameSpace;
		public TargetListWrapper(){
			nameSpace = CadenceConstants.NAMESPACE;
		}
	}

	@AuraEnabled
	public static void deletePA(List<Id> ids){
		List<Sequence_Action__c> saListToUpdate = new List<Sequence_Action__c>();
		List<Sequence_Action__c> saList = [Select Id, Name, Contact_Id__c, Lead_Id__c, isDeferred__c, isActionPerformed__c from Sequence_Action__c where Id IN :ids];
		for (Sequence_Action__c saObj : saList){


			saObj.isDeferred__c = true;

			saListToUpdate.add(saObj);
		}
		Update saListToUpdate;
		createTask(saListToUpdate);
	}

	public static void createTask(List<Sequence_Action__c> saList){
		List<Task> tList = New List<Task>();
		for (Sequence_Action__c saObj :saList){
			Task t= new Task();
			t.Subject = saObj.Name;
			t.Sequence_Action__c = saObj.Id;
			t.Status='Deferred';
			if (saObj.Contact_Id__c != null){
				t.WhoId= saObj.Contact_Id__c;
			}else {
				t.WhoId= saObj.Lead_Id__c;
			}
			tList.add(t);
		}
		insert tList;
	}

	/**
	 * @description - created target list for SObject(lead/Contact)
	 * @param objType - sObject name string
	 * @return - List of TargetList(Wrapper class) 
	 */
	public static List<TargetListWrapper> getTargetListforSObject(String objectType, String pgId){
		List<TargetListWrapper> tlList = New List<TargetListWrapper>();
		// SObject list with related participentActions
		List<SObject> soList;
		if (pgId == '' ||  pgId == String.ValueOf(UserInfo.getUserID())){
			soList =  CadenceSelector.getParticipantsWithCadenceActionsOfUser(objectType);
		}else{
			soList =  CadenceSelector.getParticipantsWithCadenceActionsOfPublicGroup(objectType, Id.valueOf(pgId));
		}
		System.debug('soList'+soList);
		List<Id> paIdsList = New List<Id>();
		List<Id> sequenceParticipantIds = New List<Id>();
		// Created list of cadenceAction ids
		for (SObject sObj : soList){            
			for (Sequence_Action__c paObj :  getAPOfSObject(sObj, objectType)){
				sequenceParticipantIds.add(paObj.Id);
				if (paObj.CadenceAction_ID__c != null){
					paIdsList.Add(paObj.CadenceAction_ID__c);
				}
			}
		}

		Map<Id,Id> sequenceParticipantIdMap = new   Map<Id,Id>();
		for(Task tasks : CadenceSelector.getTasks(sequenceParticipantIds)){
			if(!sequenceParticipantIdMap.containsKey(tasks.Sequence_Action__c)){
				sequenceParticipantIdMap.put(tasks.Sequence_Action__c,tasks.Id);
			}
		}
		System.debug('sequenceParticipantIdMap:'+sequenceParticipantIds);
		// Created list of cadenceActions 
		list<CadenceAction__c> caList= CadenceSelector.getCadenceActionsByIds(paIdsList);
		Map<Id, CadenceAction__c> caMap = New Map<Id, CadenceAction__c>(caList);
		// Itrate SObject list to create list of Wrapper 
		for (SObject sObj : soList){
			for (Sequence_Action__c paObj :  getAPOfSObject(sObj, objectType)){
				TargetListWrapper tlObj = New TargetListWrapper();
				String caId= (String)paObj.get(nameSpace+'CadenceAction_ID__c');
				CadenceAction__c caObj = caMap.get(caId);
				Task taskObj = null;

				if (caObj != null && caObj.Action_Id__r.Activation_Type__c == CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL  && (getDaysToPerformAction(sObj, caObj) < 1)){

					tlObj.taskId = sequenceParticipantIdMap.get(paObj.Id);

					tlObj.participantId = (String)sObj.get('Id');
					tlObj.cadenceId = (String)sObj.get(nameSpace+'Cadence_ID__c');
					setCadenceDetails(tlObj, sObj, objectType);
					tlObj.participantActionsId = paObj.Id;
					tlObj.linkActionName =  caObj.Name;             
					tlObj.actionType = caObj.Action_Id__r.Type__c;
					tlObj.emailType = caObj.Action_Id__r.Email_Type__c;
					tlObj.emailTempId = caObj.Action_Id__r.Template_Id__c;
					tlObj.tempId = caObj.Action_Id__r.Template_Id__c;                                       
					tlObj.type = objectType;
					tlObj.name = (String)sObj.get('Name');
					tlObj.priority = caObj.Priority__c;
					tlObj.priorityNumber = Integer.valueOf(caObj.Priority_number__c);

					if (objectType == CadenceConstants.LEAD_OBJECT_NAME){
						tlObj.company = (String)sObj.get('Company');

					}else {
						setContactCompanyDetail(tlObj, sObj);
					}

					if (objectType == CadenceConstants.LEAD_OBJECT_NAME){
						if((String)sObj.get('Phone') != null){
							tlObj.phone = (String)sObj.get('Phone');
						}else{
							tlObj.phone = (String)sObj.get('MobilePhone');
						}
					}else{
						if((String)sObj.get('Phone') != null){
							tlObj.phone = (String)sObj.get('Phone');
						}
						else if((String)sObj.get('MobilePhone') != null){
							tlObj.phone = (String)sObj.get('MobilePhone');
						} 
						else if ((String)sObj.get('HomePhone') != null){
							tlObj.phone = (String)sObj.get('HomePhone');
						}
						else if ((String)sObj.get('OtherPhone') != null){
							tlObj.phone = (String)sObj.get('OtherPhone');
						}
						else {
							tlObj.phone = (String)sObj.get('AssistantPhone');
						}
					}

					tlObj.email = (String)sObj.get('Email');

					if (getDaysToPerformAction(sObj, caObj) < 0){
						tlObj.actionPerformDay = 'Previous';
						tlObj.nextAction = caObj.Action_Id__r.Id;
					} else {
						tlObj.actionPerformDay = 'Today';
						tlObj.nextAction = caObj.Action_Id__r.Id;
					}

					tlList.Add(tlObj);
				}
			}
		}

		return tlList;
	}


	/**
	 * @description - to get list of Action on Participants from SObject(lead/Contact)
	 * @param objType - sObject name string
	 * @param sObj - object to get apList
	 * @return - List of Sequence_Action__c
	 */
	public static  List<Sequence_Action__c> getAPOfSObject(SObject sObj, String objType){
		List<Sequence_Action__c> apList;
		if (objType == CadenceConstants.LEAD_OBJECT_NAME){
			Lead lObj = (Lead)sObj;            
			apList =  lObj.Sequence_Actions__r;            
		}else {
			Contact cObj = (Contact)sObj;
			apList =  cObj.Sequence_Actions__r;
		}
		return apList;
	}


	/**
	 * @description - Used to get company name of contact
	 * @param sObj - contact object
	 * @return - String  - company name
	 */
	public static void setContactCompanyDetail(TargetListWrapper tlObj, SObject sObj){
		Contact cObj = (Contact)sObj;
		tlObj.company = cObj.Account.Name;
		tlObj.companyId = cObj.Account.Id;
	}
	/**
	 * @description - Used to get cadenceDetails
	 */
	public static void setCadenceDetails(TargetListWrapper tlObj, SObject sObj, String objectType){
		if (objectType == CadenceConstants.LEAD_OBJECT_NAME){
			Lead lObj = (Lead)sObj;
			tlObj.cadenceId = lObj.Cadence_ID__c;
			tlObj.cadenceName = lObj.Cadence_ID__r.name;
		}else {
			Contact cObj = (Contact)sObj;
			tlObj.cadenceId = cObj.Cadence_ID__c;
			tlObj.cadenceName = cObj.Cadence_ID__r.name;
		}
	}

	/**
	 * @description - Method is used to find days to perform cadence Action
	 * @param sObj - sObject (Lead/Contact)
	 * @param caObj - CadenceAction object
	 * @return - Integer - days to perform
	 */
	public static Integer getDaysToPerformAction(SObject sObj, CadenceAction__c caObj){
		DateTime dt = (DateTime)sObj.get(nameSpace+'EntranceCriteria_Matched_Date__c');
		Map<String, String> dtMap = CadenceUtil.getTimeDiff(system.now(), dt);
		Integer dayToPerform;
		Integer hourToPerform;
		if (caObj.Day__c != null) {
			dayToPerform = Integer.valueOf(caObj.Day__c);
		}else {
			dayToPerform = 0;
		}
		if (caObj.Hour__c != null) {
			hourToPerform = Integer.valueOf(caObj.Hour__c);
		} else {
			hourToPerform = 0;
		} 

		Integer dayFromMatchedDate = Integer.valueOf(dtMap.get('day'));
		Integer hourFromMatchedDate = Integer.valueOf(dtMap.get('hour'));
		Integer hour = (dayToPerform * 24 + hourToPerform ) - (dayFromMatchedDate * 24 + hourFromMatchedDate );
		return hour/24;
	}

	@AuraEnabled
	public static void createPushTopic() {
		List<PushTopic> pt = [Select Id from PushTopic where Name='actionperform'];
		if(pt.size() > 0) {
			delete pt;
		}

		PushTopic pushTopic = new PushTopic();
		pushTopic.Name = 'actionperform';
		pushTopic.Query = 'SELECT Id, '+nameSpace+'isActionPerformed__c, Name FROM '+nameSpace+'Sequence_Action__c Where '+nameSpace+'show_on_Target_List__c = true';
		pushTopic.ApiVersion = 39.0;
		pushTopic.NotifyForOperationCreate = true;
		pushTopic.NotifyForOperationUpdate = true;
		pushTopic.NotifyForOperationUndelete = true;
		pushTopic.NotifyForOperationDelete = true;
		pushTopic.NotifyForFields = 'Referenced';
		upsert pushTopic;
	}
}