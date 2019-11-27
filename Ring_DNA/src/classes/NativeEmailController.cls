public class NativeEmailController {
	@AuraEnabled
	public static SendNativeEmailResult sendEmail(String mailTo, String mailCc, String mailBcc, String subject, String body,String participantId,String templateId,String sequenceActionId){
		SendNativeEmailResult sendNativeEmail= new SendNativeEmailResult();
		RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true); 
		Id  sObjectId = Id.valueOf(participantId);
		String objName = sObjectId.getSObjectType().getDescribe().getName();
		Sobject participant =  Database.query('Select Id,OwnerId,Email,Name from '+objName +' where Id = :sObjectId');
		if (participant.get('Email') != null){
			mailTo = String.valueOf(participant.get('Email'));
			String participantOwnerId = String.valueOf(participant.get('OwnerId'));
			Map<String, Object> responseMap = ringDNAApiCallout.sendNativeEmail(mailTo, '', body, String.valueOf(sequenceActionId),  subject,  participantOwnerId);
			if (responseMap.isEmpty()  || (!responseMap.isEmpty() && (responseMap.get('success') == false || responseMap.get('success') == 'false')) ){
				sendNativeEmail = sendSfdcEmail(participantId,templateId,sequenceActionId, mailCc, mailBcc);
			}
			else if((!responseMap.isEmpty() && (responseMap.get('success') == true || responseMap.get('success') == 'true'))){
				sendNativeEmail.Success =true;
			}
		}else{
			sendNativeEmail.Success =false;
			sendNativeEmail.Message ='Invalid email address.'; 
		}
		if (sendNativeEmail.Success){
			List<Sequence_Action__c> sequenceActionList = CadenceSelector.getParticipantActions(new Set<Id>{sequenceActionId});
			createTasks(participantId,sequenceActionList,templateId);
			updateSequenceAction(sequenceActionList,participantId);
		}
		return sendNativeEmail;
	}

	public class NativeEmailWrapper {
		@AuraEnabled public String recordType;
		@AuraEnabled public String sequenceActionAPI;
		@AuraEnabled public String recordTypeAPI;
		@AuraEnabled public String emailTemplateBody;
		@AuraEnabled public String emailTemplateSubject;
	}

	@TestVisible
	private class SendNativeEmailResult{
		@AuraEnabled public Boolean Success;
		@AuraEnabled public String Message;
	}

	@AuraEnabled
	public static NativeEmailWrapper getData(String participantId,String emailTemplateId){
		Id pId = Id.ValueOf(participantId);
		Sequence_Action__c sequenceAction=[SELECT Cadence_Type__c FROM Sequence_Action__c WHERE Lead_ID__c = :pId OR Contact_Id__c =: pId LIMIT 1];
		EmailTemplate emailTemp = [Select id,Body from EmailTemplate where id=:emailTemplateId];
		NativeEmailWrapper obj=new NativeEmailWrapper();
		obj.recordType=sequenceAction.Cadence_Type__c;
		obj.sequenceActionAPI=cadenceConstants.NAMESPACE+'Sequence_Action__c';        
		if(obj.recordType==cadenceConstants.CONTACT_OBJECT_NAME || obj.recordType ==cadenceConstants.OPPORTUNITY_OBJECT_NAME){
			obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Contact_Id__c';
		}else{
			obj.recordTypeAPI=cadenceConstants.NAMESPACE+'Lead_Id__c';
		}
		if(emailTemp != null){
			NativeEmailMessage emailMessage=resolveMergeFields(participantId, emailTemplateId);
			obj.emailTemplateBody=emailMessage.body;
			obj.emailTemplateSubject=emailMessage.subject;
		}
		return obj;
	}

	public static NativeEmailMessage resolveMergeFields(String participantId, String emailTemplateId){
		Messaging.SingleEmailMessage[] previewEmails = new Messaging.SingleEmailMessage[]{};
		Messaging.SingleEmailMessage firstPreviewEmail = new Messaging.SingleEmailMessage();
		firstPreviewEmail.setUseSignature(false);
		NativeEmailMessage emailMessage=new NativeEmailMessage();
		firstPreviewEmail.setSaveAsActivity(false);
		List<String> sendTo=new List<String>();
		sendTo.add('dummy@gmail.com');
		firstPreviewEmail.setToAddresses(sendTo);
		firstPreviewEmail.setTemplateId(Id.valueOf(emailTemplateId));
		firstPreviewEmail.setTargetObjectId(Id.valueOf(participantId));
		previewEmails.add(firstPreviewEmail);
		Messaging.SingleEmailMessage secondPreviewEmail = new Messaging.SingleEmailMessage();
		previewEmails.add(secondPreviewEmail);
		List<Messaging.SendEmailResult> previewResult;
		try{
			previewResult = Messaging.sendEmail(previewEmails);
		}
		catch (Exception e) {
			emailMessage.subject=firstPreviewEmail.subject;
			emailMessage.body=firstPreviewEmail.plainTextBody;
		}
		return emailMessage;
	}

	private static SendNativeEmailResult sendSfdcEmail(String participantId,string templateId,string sequenceActionId,string mailCc,string mailBcc){
		SendNativeEmailResult sendNativeEmail= new SendNativeEmailResult();
		List<Messaging.SingleEmailMessage> emailsToSend = new  List<Messaging.SingleEmailMessage>();
		emailsToSend.add(createEmailMessage(Id.valueOf(participantId),templateId,mailCc,mailBcc));
		if(!emailsToSend.isEmpty()) {
			Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
			if (results != null && results.get(0).isSuccess()) {
				sendNativeEmail.Success =true;
				return sendNativeEmail;
			}else{
				sendNativeEmail.Success =false;
				sendNativeEmail.Message =results != null ? results.get(0).getErrors()[0].getMessage():'';
			}
		}
		return sendNativeEmail;
	}

	private static void createTasks(String participantId,List<Sequence_Action__c> sequenceActionList,String templateId){
		List<Sequence_Action__c> listOfSequence_Action = new List<Sequence_Action__c>();
		List<Task> tasksToCreate = new List<Task>();
		Sequence_Action__c partAct = sequenceActionList != null && sequenceActionList.size() > 0? sequenceActionList[0]:new Sequence_Action__c();
		partAct.Actual_Execution_Date__c = System.Now();
		partAct.isActionPerformed__c = true;
		listOfSequence_Action.add(partAct);
		tasksToCreate.add(CadenceService.getEmailTask(null,partAct.Name,participantId,templateId));
		if(tasksToCreate != null && tasksToCreate.size()>0){
			Database.SaveResult[] results = Database.insert(tasksToCreate, false);
		}
		if(listOfSequence_Action != null && listOfSequence_Action.size()>0){
			update listOfSequence_Action;
		}
	}

	private static void updateSequenceAction(List<Sequence_Action__c> sequenceActionList,string participantId){
		//Updating dates on remaining participant objects 
		Id participantIds  = (Id)participantId;
		String objType = participantIds.getSObjectType().getDescribe().getName();
		Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantAction(new Set<Id>{participantIds},objType);
		Map<Id, List<Sequence_Action__c>> performedPartAct = new Map<Id, List<Sequence_Action__c>>{participantId =>sequenceActionList};
		if(sequenceActionList != null && sequenceActionList.size() > 0 && sequenceActionList[0].Cadence_Type__c == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
			List<SObject> sobjectList = CadenceSelector.getSobjectListByIds(CadenceConstants.CONTACT_OBJECT_NAME,new List<Id>{participantId});
			CadenceService.updateSObjectFields(sobjectList, performedPartAct, CadenceConstants.CONTACT_OBJECT_NAME, false);
		}
		CadenceService.updateRemainingParticipantAction(performedPartAct,partActionsMap);
	}

	private static Messaging.SingleEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId,Id mailCc,Id mailBcc){
		List<String> listofemailParticipant = new List<String>{sObjectId,mailCc,mailBcc}; 
		Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
		String objName = sObjectId.getSObjectType().getDescribe().getName();
		for(Sobject sobj : Database.query('Select Id,Email,Name from '+objName +' where Id In :listofemailParticipant')){
			if(sobj.get('Id') == sObjectId && sobj.get('Email') != null){
				singleEmail.setToAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
			}
			if(sobj.get('Id') == mailCc && sobj.get('Email') != null){
				singleEmail.setCcAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
			}
			else if(sobj.get('Id') == mailBcc && sobj.get('Email') != null){
				singleEmail.setBccAddresses(New List<String>{String.valueOf(sobj.get('Email'))});
			}
		}
		singleEmail.setTargetObjectId(sObjectId);
		singleEmail.setSaveAsActivity(false);
		singleEmail.setTemplateId(EmailTemplateId);
		return singleEmail; 
	}

}