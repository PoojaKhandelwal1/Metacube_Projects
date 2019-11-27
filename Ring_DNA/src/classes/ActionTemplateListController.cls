public class ActionTemplateListController {   
	@AuraEnabled
	public static List <ActionTemplate> fetchActionTemplates(String type) {
		List<ActionTemplate> actionTemplateList = New List<ActionTemplate>();
		RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts(); 
		List<Object> jsonList;

		if(test.isRunningTest()){
			jsonList = (List<Object>)JSON.deserializeUntyped(ActionTemplateListControllerTest.jsonStrForOneRecord);
		}else{
			if(type == 'SMS'){
				jsonList = ringdnaAPI.getSMSTemplatesUpdated(); 
			}
			else if(type == 'Call'){
				jsonList = ringdnaAPI.getCallNoteTemplatesUpdated();  
			}
			else if(type =='Email'){
				List<EmailTemplate>  listOfEmailTemplates =CadenceService.getEmailTemplates();
				if(listOfEmailTemplates != null){
					for(EmailTemplate emailtemp : listOfEmailTemplates){
						ActionTemplate actionTemp = New ActionTemplate(emailtemp.name,emailtemp.id, emailtemp.TemplateType, emailtemp.Description);
						actionTemp.folderId =emailtemp.folderId;
						actionTemp.subject=emailTemp.subject;
						actionTemp.body=emailTemp.body;
						actionTemplateList.add(actionTemp);
					}
				}
			}                      
		}

		if (jsonList != null) {
			for (Object obj : jsonList) {
				Map<String, Object> objMap = (Map<String, Object>)obj;           
				if((Boolean)objMap.get('enabled')) {                                               
					String teamName = '';
					List<Object> teams = (List<Object>)objMap.get('teams');
					if (teams != null){
						for(Object team : teams){
							Map<String, Object> teamMap = (Map<String, Object>)team;
							Object teamObj = teamMap.get('team');                    
							Map<String, Object> teamObjMap = (Map<String, Object>)teamObj;                    
							teamName = teamName + String.valueOf(teamObjMap.get('name')) + ', ';
						}                  
						if(teamName == '' || teamName == null){
							teamName = 'All';
						}
					}
					actionTemplateList.add(New ActionTemplate(String.valueOf(objMap.get('name')),String.valueOf(objMap.get('id')), teamName.removeEnd(', '), String.valueOf(objMap.get('template'))));
				} 
			}
		}
		return actionTemplateList;
	}

	@AuraEnabled
	public static List<Folder> getFolderType(){
		List<Folder> folderList = [select Id,Name,Type from Folder where Type = 'Email'];
		return folderList;
	}

	public class ActionTemplate {
		@AuraEnabled String name {get;set;}
		@AuraEnabled String id {get;set;}
		@AuraEnabled String type {get;set;}
		@AuraEnabled String teams {get;set;}
		@AuraEnabled String template {get;set;}
		@AuraEnabled String selectButtonLabel {get;set;}
		@AuraEnabled String disableselectButton {get;set;}
		@AuraEnabled String folderId {get;set;}
		@AuraEnabled String subject {get;set;}
		@AuraEnabled String body {get;set;}
		public ActionTemplate(String templateName, String templateId, String templateTeam, String templateType){
			name = templateName;
			id = templateId;
			teams = templateTeam;
			template = templateType;
			selectButtonLabel =  'Select'; 
		}
	}
}