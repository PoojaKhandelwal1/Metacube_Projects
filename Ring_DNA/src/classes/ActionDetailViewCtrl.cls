public class ActionDetailViewCtrl {

	public class ActionDetailWrapper {
		@AuraEnabled public Action action;
		@AuraEnabled public List<ParticipantWrapper> participantList;
		@AuraEnabled public List<SequenceWrapper> cadWrapper; 
	}

	@AuraEnabled
	public static ActionDetailWrapper getActionData(Id actionId) {

		Action__c action = [Select Id, Name, Type__c, Task_Description__c, Template_Id__c, Template_Name__c, Activation_Type__c From Action__c where Id = :actionId]; 

		Action actionWrapper = New Action(action.Id, action.Activation_Type__c, action.Name, action.Task_Description__c,
				action.Template_Id__c, action.Template_Name__c, action.Type__c);
		ActionDetailWrapper actDetailWrap = new ActionDetailWrapper();
		actDetailWrap.action = actionWrapper;
		//Getting Sequences data 
		List<CadenceAction__c> cadenceActions = [Select Id, Cadence_Id__c from CadenceAction__c where Action_ID__c = :action.Id];
		Set<Id> cadenceIds = new Set<Id>();
		for(CadenceAction__c cadAction : cadenceActions) {
			cadenceIds.add(cadAction.Cadence_Id__c);
		}

		//Getting cadence wise participants
		Map<Id, Integer> cadenceWiseParticipants = CadenceActionListController.getCadenceWiseParticipants();

		List<Cadence__c> cadenceList = [Select Id, Name, Status__c, Record_Type__c, Participent_Activation__c From Cadence__c where Id IN : cadenceIds];
		List<SequenceWrapper> cadWrapList = new List<SequenceWrapper>();
		for(Cadence__c cad : cadenceList) {
			SequenceWrapper cadWrap = new SequenceWrapper();
			cadWrap.id = cad.Id;
			cadWrap.name = cad.Name;
			if(cad.Status__c) {
				cadWrap.status = 'Active';    
			} else {
				cadWrap.status = 'Inactive';
			}
			cadWrap.recordType = cad.Record_Type__c;
			cadWrap.activation = cad.Participent_Activation__c;
			cadWrap.participants = cadenceWiseParticipants.get(cad.Id);
			cadWrapList.add(cadWrap);
		}
		actDetailWrap.cadWrapper = new List<SequenceWrapper>();
		actDetailWrap.cadWrapper.addAll(cadWrapList);

		//Getting participants
		List<ParticipantWrapper> partWrapper = new List<ParticipantWrapper>();
		List<Lead> leadParticipants = [Select Id, Name, Priority__c, Company, Email, Phone, isActivated__c from Lead where IsConverted != true AND Cadence_ID__c IN :cadenceIds];
		List<Contact> contactParticipants = [Select Id, Name, Priority__c, Account.name, Account.Id, Email, Phone, isActivated__c from Contact where Cadence_ID__c IN :cadenceIds];

		for(Lead l : leadParticipants) {
			Integer priority = 0;
			if(l.Priority__c != null) {
				priority = (Integer)l.Priority__c;
			} 
			ParticipantWrapper partWrap = new ParticipantWrapper(l.Id ,l.Name, priority, l.Company, '' ,'Lead', l.Email, l.Phone, '', l.isActivated__c);
			partWrapper.add(partWrap);
		}        

		for(Contact cont : contactParticipants) {
			Integer priority = 0;
			if(cont.Priority__c != null) {
				priority = (Integer)cont.Priority__c;

			}
			ParticipantWrapper partWrap = new ParticipantWrapper(cont.Id, cont.Name, priority, cont.Account.name, cont.Account.Id, 'Contact', cont.Email, cont.Phone, '', cont.isActivated__c);
			partWrapper.add(partWrap);
		}        
		actDetailWrap.participantList = partWrapper;

		return actDetailWrap;
	}

	@AuraEnabled
	public static List<ParticipantWrapper> getCadenceParticipantsData(Id cadId) {

		if(cadId == null) {
			return null;
		}

		List<ParticipantWrapper> partWrapper = new List<ParticipantWrapper>();
		List<Lead> leadParticipants = [Select Id, Name, Company, Email, Phone, isActivated__c, Priority__c from Lead where IsConverted != true AND Cadence_ID__c = :cadId];
		List<Contact> contactParticipants = [Select Id, Name, Account.name, Account.Id, Email, Phone, isActivated__c, Priority__c from Contact where Cadence_ID__c = :cadId];

		for(Lead l : leadParticipants) {
			Integer priority = 0;
			if(l.Priority__c != null) {
				priority = (Integer)l.Priority__c;
			}
			ParticipantWrapper partWrap = new ParticipantWrapper(l.Id ,l.Name, priority, l.Company, '', 'Lead', l.Email, l.Phone, '', l.isActivated__c);
			partWrapper.add(partWrap);
		}        

		for(Contact cont : contactParticipants) {
			Integer priority = 0;
			if(cont.Priority__c != null) {
				priority = (Integer)cont.Priority__c;    
			}

			ParticipantWrapper partWrap = new ParticipantWrapper(cont.Id, cont.Name, priority, cont.Account.name, cont.Account.Id, 'Contact', cont.Email, cont.Phone, '', cont.isActivated__c);
			partWrapper.add(partWrap);
		}        
		return partWrapper;
	}

	@AuraEnabled
	public static void togglePartActivation(String selectedRows) {
		List<ParticipantWrapper> wrapList = (List<ParticipantWrapper>)JSON.deserialize(selectedRows, List<ParticipantWrapper>.class);
		List<sObject> participants = new List<sObject>();
		for(ParticipantWrapper partWrap : wrapList) {
			if(partWrap.objType.equalsIgnoreCase('Contact')) {
				Contact cont = new Contact(Id = partWrap.id);	
				cont.isActivated__c = partWrap.status.equalsIgnoreCase('Disabled');
				participants.add(cont);
			} else { 
				Lead l = new Lead(Id = partWrap.id);
				l.isActivated__c = partWrap.status.equalsIgnoreCase('Disabled');
				participants.add(l); 
			}
		}
		Database.SaveResult[] results = Database.update(participants, false);
	}

	public class SequenceWrapper {
		@AuraEnabled public Id id;
		@AuraEnabled public String name;
		@AuraEnabled public String activation;
		@AuraEnabled public String recordType;
		@AuraEnabled public String status;
		@AuraEnabled public Integer participants;
	}

	public class ParticipantWrapper {
		@AuraEnabled public Id id;
		@AuraEnabled public String name;
		@AuraEnabled public Integer priority;
		@AuraEnabled public String company;
		@AuraEnabled public String companyId;
		@AuraEnabled public String objType;
		@AuraEnabled public String email;
		@AuraEnabled public String phone;
		@AuraEnabled public String nextAction;
		@AuraEnabled public String status;

		public ParticipantWrapper(Id actionId, String name, Integer priority, String company, String companyId, String objType, String email, String phone, String nextAction, Boolean status) {
			this.id = actionId;
			this.name = name;     
			this.priority = priority;
			this.company = company;
			this.companyId = companyId;

			this.objType = objType;
			if(status) {
				this.status	= 'Active';
			} else {
				this.status = 'Disabled';
			}
			this.email = email;
			this.phone = phone;
			this.nextAction = nextAction;
		}

	}
}