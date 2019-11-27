global  without sharing class CadenceService {
    public static String nameSpace = CadenceConstants.NAMESPACE;
    public static String partnerAccountAPIName = 'PartnerAccount';
    public static map<String,set<String>> mapOfOpportunityRole = new map<String,set<String>>();
    public Static map<String,List<OpportunityContactRole>> mapOfOppContactRoles = new map<String,list<OpportunityContactRole>>();
    public Static map<string,List<String>> mapOfOppcontact = new map<string,List<String>>();
    
    public static List<EmailTemplate> getEmailTemplates(){ 
        List<EmailTemplate> listEmailTemplate = [Select Id, Name, Subject, Body, IsActive, Description,UIType,TemplateType,FolderId,Folder.Name,Folder.Type From EmailTemplate Where IsActive = true]; 
      	return listEmailTemplate;
    } 
    
    public static List<LookupFieldController.UserListWrapper> getUserWrapperList(){
        List<User> userList = CadenceSelector.getUserList();
        List<LookupFieldController.UserListWrapper> userListWrapperList = New List<LookupFieldController.UserListWrapper>();
        for (User user : userList){
            LookupFieldController.UserListWrapper userListWrapper = New LookupFieldController.UserListWrapper();
            userListWrapper.userName = user.Name;
            userListWrapper.userId = user.Id;
            userListWrapperList.add(userListWrapper);
        }
        return userListWrapperList;
    }
	
	public static List<LookupFieldController.DandBCompanyListWrapper> getDandBCompanyWrapperList(){
        List<SObject> dandBList = CadenceSelector.getDandBCompanyList();
        List<LookupFieldController.DandBCompanyListWrapper> dandBCompanyListWrapperList = New List<LookupFieldController.DandBCompanyListWrapper>();
        for (SObject dnBCompany : dandBList){
            LookupFieldController.DandBCompanyListWrapper dnBCompanyListWrapper = New LookupFieldController.DandBCompanyListWrapper();
            dnBCompanyListWrapper.Name  = String.valueof(dnBCompany.get('Name'));
            dnBCompanyListWrapper.Id = String.valueof(dnBCompany.get('Id'));
            dandBCompanyListWrapperList.add(dnBCompanyListWrapper);
        }
        return dandBCompanyListWrapperList;
    }
    public static List<ActionDetailController.WrapperTemplateObj> getSMSTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getSMSTemplates());
    } 
    public static List<ActionDetailController.WrapperTemplateObj> getCallTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getCallNoteTemplates());
    }
    
    public static List<ActionDetailController.WrapperTemplateObj> getVMTemplates(){
        RingDNAApiCallouts ringdnaAPI = new RingDNAApiCallouts();
        return mapToWrapperObj(ringdnaAPI.getVoicemailDrops());
    }
    
    public static List<ActionDetailController.WrapperTemplateObj> mapToWrapperObj (Map<String, String> apiMap){
        List<ActionDetailController.WrapperTemplateObj> wtList = New List<ActionDetailController.WrapperTemplateObj>();
        for(String str : apiMap.keySet()){
            ActionDetailController.WrapperTemplateObj wtObj = New ActionDetailController.WrapperTemplateObj();
            wtObj.Id = str; 
            wtObj.Name = apiMap.get(str);
            wtList.add(wtObj);
        } 
        return wtList; 
    }
    
    public static List<CriterionWrapper> getFields(String objectStr) {
        List<CriterionWrapper> criterionWrapperList = new List<CriterionWrapper>();
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        if(sObjectName != null){
            Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
            
            CriterionWrapper criterionWrapper = new CriterionWrapper();
            criterionWrapper.GroupName = '';
            List<Criterion> fieldsWithLabels = new List<Criterion>();
            List<ActionDetailController.wrapperTaskField> listWrapperTaskFields = new List<ActionDetailController.wrapperTaskField>();
            for (String field : fieldsMap.keySet()) {
                
                Schema.sObjectField fieldAPIName = fieldsMap.get(field);
                Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();
                Schema.DescribeFieldResult dfr = fieldAPIName.getDescribe();
                Integer LengthOfField = dfr.getLength();
                if (fieldDataType == Schema.DisplayType.Boolean || fieldDataType == Schema.DisplayType.Double 
                    || fieldDataType == Schema.DisplayType.Integer 
                    || fieldDataType == Schema.DisplayType.String 
                    || fieldDataType == Schema.DisplayType.Picklist
                    || fieldDataType == Schema.DisplayType.Combobox 
                    || fieldDataType == Schema.DisplayType.MULTIPICKLIST
                    || (fieldDataType == Schema.DisplayType.Textarea && ((fieldDataType != Schema.DisplayType.ENCRYPTEDSTRING)) )
                   ) {
                       if(!fieldAPIName.getDescribe().isCalculated() && fieldAPIName.getDescribe().isUpdateable()) {
                           Criterion c = new Criterion();
                           c.fieldName = fieldAPIName.getDescribe().getName();
                           c.fieldLabel = fieldAPIName.getDescribe().getLabel();
                           c.fieldDataType = getDataType(objectStr, c.fieldName);
                           if (c.fieldDataType == 'Picklist' || c.fieldDataType == 'MultiPickList'){
                               c.listPicklistValues = getPicklistValues(objectStr, c.fieldName);
                           }
                           fieldsWithLabels.add(c);
                           
                       }
                   }
            }
            criterionWrapper.fieldsDetail = fieldsWithLabels;
            criterionWrapperList.add(criterionWrapper);
        }
        return criterionWrapperList;
    }
    
    public static List<CriterionWrapper> getFieldsWithLabels(List<String> objectlist){
        String objectStr ; 
        List<Criterion> fieldsWithLabels = new List<Criterion>();
		List<CriterionWrapper> fieldList = new List<CriterionWrapper>();      
        CriterionWrapper criterionWrapper,criterionWrapperPartnerAccount;
        Integer index = 0;
        Boolean IsPartnerAccount = false;
        List<Schema.DescribeSObjectResult> descResult = Schema.describeSObjects(CadenceUtil.getValidSObjectListInOrg(objectlist));
        if(descResult != null && descResult.size() > 0){
            for(Schema.DescribeSObjectResult dsc : descResult){ 
                if(dsc != null && dsc.getName()!= null){
                    criterionWrapper = new CriterionWrapper();
                    objectStr =dsc.getName();
                    Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
                    if (sObjectName != null){
                        criterionWrapper.GroupName = objectStr;
                        if(index == 0){
                            criterionWrapper.IsParent = true;
                        }
                        
                        if(objectlist[0] == CadenceConstants.OPPORTUNITY_OBJECT_NAME && objectStr == CadenceConstants.ACCOUNT_OBJECT_NAME){
                            IsPartnerAccount = true;
                            criterionWrapperPartnerAccount = new CriterionWrapper();
                            criterionWrapperPartnerAccount.GroupName = CadenceConstants.PARTNER_ACCOUNT_OBJECT_DISPLAY_NAME;
                        }
                        
                        SObjectType r = dsc.getSobjectType(); 
                        Map<String, Schema.SObjectField> fieldsMap = dsc.fields.getMap(); 
                        for (String field : fieldsMap.keySet()) {
                            Criterion c = new Criterion();
                            Schema.sObjectField fieldAPIName = fieldsMap.get(field);
                            Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();           
                            Schema.DescribeFieldResult dfr = fieldAPIName.getDescribe();
                            c.fieldName = fieldAPIName.getDescribe().getName();
                            Integer LengthOfField = dfr.getLength();
                            if (fieldDataType == Schema.DisplayType.Boolean 
                                || fieldDataType == Schema.DisplayType.REFERENCE
                                || fieldDataType == Schema.DisplayType.Double 
                                || fieldDataType == Schema.DisplayType.Integer
                                || fieldDataType == Schema.DisplayType.Email
                                || fieldDataType == Schema.DisplayType.Phone
                                || fieldDataType == Schema.DisplayType.Date 
                                || fieldDataType == Schema.DisplayType.URL
                                || fieldDataType == Schema.DisplayType.Currency
                                || fieldDataType == Schema.DisplayType.DateTime
                                || (fieldDataType == Schema.DisplayType.String )
                                || fieldDataType == Schema.DisplayType.Picklist
                                || (fieldDataType == Schema.DisplayType.Textarea && (LengthOfField <= 255 && (fieldDataType != Schema.DisplayType.ENCRYPTEDSTRING)) )               
                                || fieldDataType == Schema.DisplayType.Combobox
                                || fieldDataType == Schema.DisplayType.MULTIPICKLIST
                               ){
                                   if(!fieldAPIName.getDescribe().isCalculated() && fieldAPIName.getDescribe().isUpdateable()){
                                       c.fieldName = fieldAPIName.getDescribe().getName();
                                       c.fieldLabel = fieldAPIName.getDescribe().getLabel();
                                       c.fieldDataType = getDataType(objectStr, c.fieldName);
                                       
                                       if (c.fieldDataType == 'Picklist' || c.fieldDataType == 'MultiPickList'){
                                           c.listPicklistValues = getPicklistValues(objectStr, c.fieldName);
                                           c.picklistApiNameAndValues = Criterion.getPicklistApiNameAndValues(objectStr, c.fieldName);
                                       }
                                       
                                       if (!(c.fieldDataType == 'Reference' && objectStr == 'DandBCompany' )){
                                           if (c.fieldDataType != 'Reference' || (c.fieldDataType == 'Reference' && validForCriteria(objectStr, c.fieldName))){
                                               if(index != 0){
                                                   c.fieldName =  objectStr + '.' + c.fieldName;
                                               }
                                               if(!(objectStr == CadenceConstants.OPPORTUNITY_ROLE_OBJECT_NAME && c.fieldLabel == 'Primary')){
                                                   fieldsWithLabels.add(c);
                                               }
                                           }
                                       }
                                       
                                   }
                               } 
                        }
                    }
                }
                index++; 
                criterionWrapper.fieldsDetail = fieldsWithLabels;
                fieldList.add(criterionWrapper);
                
                if(IsPartnerAccount && Schema.getGlobalDescribe().get(CadenceConstants.OPPORTUNITY_OBJECT_NAME).getDescribe().fields.getMap().get('PartnerAccountId') != null){
                    for(Criterion c : fieldsWithLabels){
                        String[] fields = c.fieldName.split('\\.');
                        if(fields.size() > 0){
                            Criterion criterion  = new Criterion();
                            criterion.id=c.id;
                            criterion.fieldName= CadenceConstants.PARTNER_ACCOUNT_OBJECT_NAME + '.' + fields[1];
                            criterion.fieldLabel=c.fieldLabel;
                            criterion.fieldDataType=c.fieldDataType;
                            criterion.operation=c.operation;
                            criterion.value=c.value;
                            criterion.listPicklistValues=c.listPicklistValues;
                            criterion.picklistApiNameAndValues=c.picklistApiNameAndValues;
                            criterionWrapperPartnerAccount.fieldsDetail.add(criterion);
                        }
                    }
                    if(criterionWrapperPartnerAccount != null){
            			fieldList.add(criterionWrapperPartnerAccount);
        			}
                    IsPartnerAccount = false;
                }
                
                fieldsWithLabels = new List<Criterion>();
                
            }
        }
        
        
        return fieldList;
    }
    
    public static List<CriterionWrapper> getFieldsWithLabelsForUpdate(List<String> objectlist){ 
        String objectStr ; 
        List<Criterion> fieldsWithLabels = new List<Criterion>();
        List<CriterionWrapper> fieldList = new List<CriterionWrapper>();      
        CriterionWrapper criterionWrapper;
        Integer index = 0;
        List<Schema.DescribeSObjectResult> descResult = Schema.describeSObjects(CadenceUtil.getValidSObjectListInOrg(objectlist));
        if(descResult != null && descResult.size() > 0){
            for(Schema.DescribeSObjectResult dsc : descResult){ 
                if(dsc != null && dsc.getName()!= null){
                    criterionWrapper = new CriterionWrapper();
                    objectStr =dsc.getName(); 
                    criterionWrapper.GroupName = objectStr;
                    if(index == 0){
                        criterionWrapper.IsParent = true;
                    }
                    
                    Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
                    if (sObjectName != null){
                        SObjectType r = dsc.getSobjectType(); 
                        Map<String, Schema.SObjectField> fieldsMap = dsc.fields.getMap(); 
                        for (String field : fieldsMap.keySet()) {
                            
                            Criterion c = new Criterion();
                            Schema.sObjectField fieldAPIName = fieldsMap.get(field);
                            Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();           
                            Schema.DescribeFieldResult dfr = fieldAPIName.getDescribe();
                            Integer LengthOfField = dfr.getLength();
                            
                            if (fieldDataType == Schema.DisplayType.Boolean 
                                || fieldDataType == Schema.DisplayType.REFERENCE
                                || fieldDataType == Schema.DisplayType.Double 
                                || fieldDataType == Schema.DisplayType.Integer
                                || fieldDataType == Schema.DisplayType.Email
                                || fieldDataType == Schema.DisplayType.Phone
                                || fieldDataType == Schema.DisplayType.Date
                                || fieldDataType == Schema.DisplayType.DateTime
                                || (fieldDataType == Schema.DisplayType.String )
                                || fieldDataType == Schema.DisplayType.Picklist
                                || (fieldDataType == Schema.DisplayType.Textarea && (LengthOfField <= 255 && (fieldDataType != Schema.DisplayType.ENCRYPTEDSTRING)) )               
                                || fieldDataType == Schema.DisplayType.Combobox
                                || fieldDataType == Schema.DisplayType.MULTIPICKLIST
                               ){
                                   if(!fieldAPIName.getDescribe().isCalculated() && fieldAPIName.getDescribe().isUpdateable()){
                                       
                                       c.fieldName = fieldAPIName.getDescribe().getName();
                                       c.fieldLabel = fieldAPIName.getDescribe().getLabel();
                                       c.fieldDataType = getDataType(objectStr, c.fieldName);
                                       if (c.fieldDataType == 'Picklist' || c.fieldDataType == 'MultiPickList'){
                                           c.listPicklistValues = getPicklistValues(objectStr, c.fieldName);
                                           c.picklistApiNameAndValues = Criterion.getPicklistApiNameAndValues(objectStr, c.fieldName);
                                       }
                                       if (!(c.fieldDataType == 'Reference' && (c.fieldName == nameSpace+'Cadence_ID__c' || c.fieldName == 'ReportsToId' || c.fieldName == 'OwnerId' ))){
                                           if (c.fieldDataType != 'Reference' || (c.fieldDataType == 'Reference' && validForCriteria(objectStr, c.fieldName))){
                                               if(index != 0){
                                                   c.fieldName =  objectStr + '.' + c.fieldName;
                                               }
                                               fieldsWithLabels.add(c);
                                           }
                                       }
                                       
                                   }
                               } 
                        }
                    }
                }
                index++; 
                criterionWrapper.fieldsDetail = fieldsWithLabels;
                fieldList.add(criterionWrapper);
                fieldsWithLabels = new List<Criterion>();
            }
        }
        
        return fieldList;
    }
    
    public static String getDataType(String objectStr, String field) {
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        Schema.DisplayType fieldType = fieldsMap.get(field).getDescribe().getType();
        String dataType = 'String';
        if (fieldType == Schema.DisplayType.Boolean) {
            dataType = 'Boolean';
        } else if (fieldType == Schema.DisplayType.Double || fieldType == Schema.DisplayType.Integer) {
            dataType = 'Number';
        } else if (fieldType == Schema.DisplayType.String) {
            dataType = 'String';
        } else if (fieldType == Schema.DisplayType.Picklist) {
            dataType = 'Picklist';
        }else if (fieldType == Schema.DisplayType.Email) {
            dataType = 'Email';
        }else if (fieldType == Schema.DisplayType.Phone) {
            dataType = 'Phone';
        }else if (fieldType == Schema.DisplayType.Date) {
            dataType = 'Date';
        }else if (fieldType == Schema.DisplayType.DateTime) {
            dataType = 'DateTime';
        }else if (fieldType == Schema.DisplayType.MULTIPICKLIST) {
            dataType = 'MultiPickList';
        }else if (fieldType == Schema.DisplayType.URL) {
            dataType = 'String';
        }else if (fieldType == Schema.DisplayType.Currency) {
            dataType = 'Number';
        }else if (fieldType == Schema.DisplayType.REFERENCE) {
            dataType = 'Reference';
        }
        return dataType;
    }
    
    public static List<String> getPicklistValues(String objectStr, String field) { 
        List<String> picklistValues = new List<String>();
        Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
        Map<String, Schema.SObjectField> fieldsMap = sObjectName.getDescribe().fields.getMap();
        Schema.sObjectField fieldAPIName = fieldsMap.get(field);
        Schema.DescribeFieldResult fieldResult = fieldAPIName.getDescribe();  
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklistVal : values) {
            picklistValues.add(picklistVal.getLabel());
        }     
        return picklistValues;
    }
    
    public static void setParticipantsActivation(Id cadId, Boolean active) {
        Cadence__c cad = [Select Id, Status__c, Participent_Activation__c, Record_Type__c from Cadence__c where Id = :cadId];
        if(cad.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL)) {
            return;
        }
        List<SObject> objList = getCadenceParticipants(cadId, cad.Record_Type__c);
        if(objList == null || objList.isEmpty()) {
            return;
        }
        for(SObject obj : objList) {
            if(active) {
                obj.put(nameSpace+'isActivated__c', true);
            } else {
                obj.put(nameSpace+'isActivated__c', false);
            }
        }
        Database.SaveResult[] results = Database.update(objList, false);
    }
    
    public static List<SObject> getCadenceParticipants(Id cadId, String objName) {
        if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME))
            objName = CadenceConstants.CONTACT_OBJECT_NAME;  
        String query = 'Select Id, Name, '+nameSpace+'Cadence_ID__c, '+nameSpace+'isActivated__c';
        query += ' FROM '+ objName +' WHERE '+nameSpace+'Cadence_Id__c = :cadId';
        return Database.query(query);
    }
    
    //This method is to create participant actions  
    public static List<Sequence_Action__c> createActionParticipants(Map<Id, List<CadenceAction__c>> objIdToActionMap, Map<Id, SObject> objMap, String objName) {
        List<Sequence_Action__c> partActionsToCreate = new List<Sequence_Action__c>(); 
        for(Id objId : objIdToActionMap.keySet()) {
            DateTime entranceDate = (DateTime)objMap.get(objId).get(namespace+'EntranceCriteria_Matched_Date__c');
            List<CadenceAction__c> cadActions = objIdToActionMap.get(objId);
            Integer day = 0, hour = 0;
            for(CadenceAction__c cadAct : cadActions) {
                if(cadAct.Day__c != null) {
                    day = day + (Integer)cadAct.Day__c;
                }
                if(cadAct.Hour__c != null) {
                    hour = hour + (Integer)cadAct.Hour__c;
                }
                Sequence_Action__c partAct = new Sequence_Action__c();
                partAct.Name = cadAct.Name;
                partAct.CadenceAction_ID__c = cadAct.Id;
                partAct.Expected_Execution_Date__c = CadenceUtil.addTimeInDate(entranceDate, day, hour);
                if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                    partAct.Lead_Id__c = objId;	
                } else {
                    partAct.Contact_Id__c = objId;
                }
                partActionsToCreate.add(partAct);
            }	
        }
        if(partActionsToCreate != null && partActionsToCreate.size()>0){
            insert partActionsToCreate;	
        }
        return partActionsToCreate;			
    }
    
    public Static Map<String, List<sObject>> processObjectList(List<Contact> contactList){
        List<Contact> contactListWithCadenceIds = new List<Contact>();
        List<Contact> contactListWithoutCadenceIds = new List<Contact>();
        for(Contact conObj : contactList){
            if (conObj.Cadence_ID__c == null || string.valueOf(conObj.Cadence_ID__c).trim() == ''){
                contactListWithoutCadenceIds.add(conObj);
            }else{
                contactListWithCadenceIds.add(conObj);
            }
        }
        Map<String, List<sObject>> MapOfSobjList = New Map<String, List<sObject>>();
        MapOfSobjList.put('contactListWithoutCadenceIds',contactListWithoutCadenceIds);
        MapOfSobjList.put('contactListWithCadenceIds',contactListWithCadenceIds);
        return MapOfSobjList;
    } 
    
    public Static Map<String, List<Lead>> processObjectList(List<Lead> leadList){
        List<Lead> leadListWithCadenceIds = new List<Lead>();
        List<Lead> leadListWithoutCadenceIds = new List<Lead>();
        for(Lead conObj : leadList){
            if (conObj.Cadence_ID__c == null || string.valueOf(conObj.Cadence_ID__c).trim() == ''){
                leadListWithoutCadenceIds.add(conObj);
            }else{
                leadListWithCadenceIds.add(conObj);
            }
        }
        Map<String, List<Lead>> MapOfSobjList = New Map<String, List<Lead>>();
        MapOfSobjList.put('leadListWithoutCadenceIds',leadListWithoutCadenceIds);
        MapOfSobjList.put('leadListWithCadenceIds',leadListWithCadenceIds);
        return MapOfSobjList;
    }
    
    /* Method to create email message
	 * @Param : sObjectId - List of sobject having email Ids,EmailTemplateId - Email Template Id
	 */
    public static Messaging.MassEmailMessage createEmailMessage(Id sObjectId,Id EmailTemplateId){
        Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
        mail.setSaveAsActivity(false);
        mail.setTargetObjectIds(new List<Id>{sObjectId});
        mail.setTemplateId(EmailTemplateId);
        return mail; 
    }
    
    public static NativeEmailMessage createNativeEmailMessage(String nativeMailTo,Id EmailTemplateId,Id participantId, Id actionId, String nameTo, Id usreId ){
        NativeEmailMessage emailMessage= NativeEmailController.resolveMergeFields(String.valueOf(participantId) , String.valueOf(EmailTemplateId));
        NativeEmailMessage nativeEmail = new NativeEmailMessage (nativeMailTo, '','', emailMessage.subject, emailMessage.Body,EmailTemplateId, actionId, nameTo, participantId, usreId);
        return nativeEmail; 
    }
    
	public static List<Messaging.MassEmailMessage> SendNativeEmail(List<NativeEmailMessage> nativeEmailToSend ){
        RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true);
        List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
        List<Messaging.MassEmailMessage> sfdcEmailMessageList = New List<Messaging.MassEmailMessage>(); 
        if (System.isBatch()){
            System.enqueueJob(new sendNativeEmailQueue(nativeEmailToSend));
        }else{
            nativeEmailMessageList = nativeEmailToSend;
        }
        if(nativeEmailMessageList != null && nativeEmailMessageList.size() > 0){
            sendNativeEmailTroughTrigger(JSON.serialize(nativeEmailMessageList));
        }
        return sfdcEmailMessageList;
    }
    
    public static Task getEmailTask(Id sequenceActionId, String actionName, Id sObjectId, Id templateId) {
        Task t = new Task();
        t.Subject = 'Emails: '+ actionName;
        t.Description = templateId;
        t.WhoId = sObjectId;
        t.TaskSubtype = 'Email'; 
        t.Sequence_Action__c = sequenceActionId;
        t.Status = 'Completed';
        return t;
    }
    
    /* 
	* Method to perform Task Actions
	* @Param : Id - Id of sobject (Lead/Contact),taskDescription - Json OfTaskObj
	*/
    public static Task performTaskAction(Id sObjectId, String taskDescription){
        Task taskObj = (Task)JSON.deserialize(taskDescription, Task.class);
        taskObj.WhoId = sObjectId;
        return taskObj;
    }
    
    public static List<SObject> assignCadenceToParticipants(Map<Id, Cadence__c> cadMap, List<SObject> sObjectList, Map<Id, SObject> parentMap, String objName) {
        List<SObject> objList = new List<SObject>();
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        for(SObject Obj : sObjectList) {
            Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMap, obj, parentMap.get((Id)obj.get('Id')), objName);
            if(obj.get(nameSpace+'Cadence_Id__c') != null) {
                objIdToAllCadActListMap.put((Id)obj.get('Id'), cadMap.get((Id)obj.get(nameSpace+'Cadence_Id__c')).CadenceActions__r);
                objList.add(obj); 
            }
        }
        createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(objList),  objName);
        update objList; 
        return objList; 
    }
    
    public static Map<Id, List<Sequence_Action__c>> getRemainingParticipantActions(Set<Id> objIds, String objName) { 
        Map<Id, List<Sequence_Action__c>> objToParticipantActionsMap = new Map<Id, List<Sequence_Action__c>>(); 
        List<Sequence_Action__c> participantActions;
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            participantActions = [Select Id, Name, CadenceAction_ID__c, Expected_Execution_Date__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c From Sequence_Action__c 
                                  where Lead_Id__c IN :objIds AND isActionPerformed__c = false 
                              	  order by CreatedDate];
        } else {  
            participantActions = [Select Id, Name, CadenceAction_ID__c, Expected_Execution_Date__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c From Sequence_Action__c 
                                  where Contact_Id__c IN :objIds AND isActionPerformed__c = false  order by CreatedDate];
        }
        for(Sequence_Action__c partAct : participantActions) {
            if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                if(objToParticipantActionsMap.containsKey(partAct.Lead_Id__c)) {
                    objToParticipantActionsMap.get(partAct.Lead_Id__c).add(partAct);
                } else {
                    objToParticipantActionsMap.put(partAct.Lead_Id__c, new List<Sequence_Action__c>{partAct});
                }
            } 
            else {
                if(objToParticipantActionsMap.containsKey(partAct.Contact_Id__c)) {
                    objToParticipantActionsMap.get(partAct.Contact_Id__c).add(partAct);
                } else {
                    objToParticipantActionsMap.put(partAct.Contact_Id__c, new List<Sequence_Action__c>{partAct});
                } 
            }	
        }
        return objToParticipantActionsMap;
    }
    
    public static void deleteSobjectsByIds(String ObjType, List<Id> ids){
        List<SObject> sObjList = CadenceSelector.getSobjectListByIds(ObjType, ids);
        delete sObjList;
    }
    
    public static void deleteUnperformedPartActions(Map<Id, Id> objIdToCadIdMap, String objName) {
        
        //Returning if nothing to remove
        if(objIdToCadIdMap.isEmpty()) {
            return;
        }
        
        //Deleting the part action object on changing the cadence  
        Set<Id> objIds = objIdToCadIdMap.keySet();
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            List<Sequence_Action__c> partsOfLead = [SELECT Id, Lead_Id__c, Contact_Id__c, CadenceAction_Id__c, CadenceAction_Id__r.Cadence_Id__c FROM Sequence_Action__c WHERE Lead_Id__c IN :objIds AND isActionPerformed__c=false];
            List<Sequence_Action__c> partsToDelete = new List<Sequence_Action__c>();
            for(Sequence_Action__c partAct : partsOflead) {
                if(objIdToCadIdMap.get(partAct.Lead_Id__c) == partAct.CadenceAction_Id__r.Cadence_Id__c) {
                    partsToDelete.add(partAct);
                }
            } 
            delete partsToDelete;
        } else {
            List<Sequence_Action__c> partsOfContact = [SELECT Id, Lead_Id__c, Contact_Id__c, CadenceAction_Id__c, CadenceAction_Id__r.Cadence_Id__c FROM Sequence_Action__c WHERE Contact_Id__c IN :objIds AND isActionPerformed__c=false];
            List<Sequence_Action__c> partsToDelete = new List<Sequence_Action__c>();
            for(Sequence_Action__c partAct : partsOfContact) {
                if(objIdToCadIdMap.get(partAct.Contact_Id__c) == partAct.CadenceAction_Id__r.Cadence_Id__c) {
                    partsToDelete.add(partAct);
                }
            } 
            delete partsToDelete;
        }	     
    }
    
    public static ParticipantsToProcess getSObjectsToProcess(List<SObject> objList, Map<Id, SObject> parentMap, Map<Id, Cadence__c> cadMap, String objName) {
        //Initializing the soject list as per obj
        List<SObject> sObjectsToProcess;
		List<SObject> sObjectsForOpportunity = new List<SObject>();
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            sObjectsToProcess = new List<Lead>();
        } else if(objName.equals(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
            sObjectsToProcess = new List<Contact>();
        } else {
            sObjectsToProcess = new List<Contact>();
        }  
        
        List<Sobject> unmatchedParticipantsList = new List<Sobject>();
        Map<Id, Id> oldPartActionToDelete = new Map<Id, Id>();
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        Map<Id,List<Id>> sequenceHistoryMap = getParticipantSequenceHistory((new Map<Id,SObject>(objList)).keySet(),objName);
        List<Participant_Sequence_History__c> newSequenceHistory = new List<Participant_Sequence_History__c>(); 
 
        map<String,Sobject> mapOfContacts= new Map<String,Sobject>();
        map<String,Sobject> mapOfContactsWithSequenceIsNull = new Map<String,Sobject>();
        List<Contact> oppContactList= new List<Contact>();
        if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
            getMapOpporContactRole(objList);
            mapOfOppcontact= opporContactMap(objList);
            List<String> listOfContactids = new List<String>();
            for(String oppids : mapOfOppcontact.keyset()){
                if(mapOfOppcontact.get(oppids) != null){
                    listOfContactids.addAll(mapOfOppcontact.get(oppids));
                }
            }
          
            if(listOfContactids.size() > 0){
                for(Contact con : [Select id,Cadence_Id__c,isActivated__c,EntranceCriteria_Matched_Date__c,Email,Name,OwnerId,Opportunity_Id__c from Contact Where Id In :listOfContactids]){
                    mapOfContacts.put(con.id,(Sobject)con);
                    if(con.Cadence_ID__c == null){
                        mapOfContactsWithSequenceIsNull.put(con.id,(Sobject)con);
                    }
                }
            }
        }
        
        //Updating the obj list with cadences 
        for(SObject obj : objList) {
            Map<Id, Cadence__c> cadMapNew =  removeCadencefromMap(cadMap.clone(),sequenceHistoryMap.get(obj.Id));
            if(obj.get(nameSpace+'Cadence_Id__c') == null) {                
                Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMapNew, obj, parentMap.get((Id)obj.get('Id')), objName);
                if(cad != null) {
                    if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
                        string oppIds = String.valueOf(obj.get('Id'));
                        if(mapOfOppcontact.keyset().size() > 0 && mapOfOppcontact.containskey(oppIds)){
                            for(String associateContactofOpp :mapOfOppcontact.get(oppIds)){
                                Set<String> setOfMatchRole;
                                if(CadenceService.mapOfOpportunityRole.containskey(oppIds)) 
                                setOfMatchRole = CadenceService.mapOfOpportunityRole.get(oppIds);
                                if(CadenceService.mapOfOpportunityRole.containskey(oppIds)){
                                    if(setOfMatchRole.contains(associateContactofOpp)){
                                        Contact contSobj = new Contact();
                                        if(mapOfContactsWithSequenceIsNull.containskey(associateContactofOpp)){
                                             contSobj =(Contact)UpdateSequenceOnParticipant(mapOfContactsWithSequenceIsNull.get(associateContactofOpp),cad);
                                        }
                                        if(contSobj != null && contSobj.isActivated__c) {
                                            sObjectsToProcess.add(contSobj);
                                            objIdToAllCadActListMap.put(contSobj.Id, cad.CadenceActions__r);
                                        } 
                                    }
                                }
                                else{
                                    Contact contSobj = new Contact();
                                    if(mapOfContactsWithSequenceIsNull.containskey(associateContactofOpp)){
                                         contSobj =(Contact)UpdateSequenceOnParticipant(mapOfContactsWithSequenceIsNull.get(associateContactofOpp),cad);
                                    }
                                    if(contSobj != null && contSobj.isActivated__c) {
                                        sObjectsToProcess.add(contSobj);
                                        objIdToAllCadActListMap.put(contSobj.Id, cad.CadenceActions__r);
                                    }
                                }
                            }
                        }
                    }
                    else{
                        if((Boolean)obj.get(nameSpace + 'isActivated__c')) {
                            sObjectsToProcess.add(obj);
                            objIdToAllCadActListMap.put((Id)obj.get('Id'), cad.CadenceActions__r);
                        }
                    }
                    
                }				
            } else {
                Id cadId = (Id)obj.get(nameSpace+'Cadence_Id__c'); 
                
                SObject sObj;
                Boolean isexitMatchOpp=false;
                if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
                    isexitMatchOpp = RuleCriterionMatcher.matchExitCriterionOpp(cadMapNew.get(cadId), obj, parentMap.get((Id)obj.get('Id')), objName);
                    if(isexitMatchOpp){
                        obj.put(nameSpace+'Cadence_Id__c', null);
                        sObjectsForOpportunity.add(obj);
                        
                        oppContactList.addAll(RemoveSequenceFromParticempant((Id)obj.get('Id'),mapOfOppcontact, mapOfContacts));
                    }
                    
                }else {
                    sObj= RuleCriterionMatcher.matchExitCriterion(cadMapNew.get(cadId), obj, parentMap.get((Id)obj.get('Id')), objName);
                }
                if(sObj != null || isexitMatchOpp) {
                    if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
                        for(Contact con : oppContactList){
                            newSequenceHistory.add(createHistoryObject(cadId,con.Id,objName));
                            oldPartActionToDelete.put(con.Id, cadId); 
                        }
                    }else{
                        newSequenceHistory.add(createHistoryObject(cadId,(Id)obj.get('Id'),objName));
                        oldPartActionToDelete.put((Id)obj.get('Id'), cadId); 
                    }
                    Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMapNew, obj, parentMap.get((Id)obj.get('Id')), objName);
                    if(cad != null) {
                        if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
                            string oppIds = String.valueOf(obj.get('Id'));
                            if(mapOfOppcontact.keyset().size() > 0 && mapOfOppcontact.containskey(oppIds)){
                                for(String associateContactofOpp :mapOfOppcontact.get(oppIds)){
                                    Set<String> setOfMatchRole;
                                    if(CadenceService.mapOfOpportunityRole.containskey(oppIds)) 
                                    setOfMatchRole = CadenceService.mapOfOpportunityRole.get(oppIds);
                                    if(CadenceService.mapOfOpportunityRole.containskey(oppIds) ){
                                        if(setOfMatchRole.contains(associateContactofOpp)){
                                            Sobject contSobj;
                                            if(mapOfContactsWithSequenceIsNull.containskey(associateContactofOpp)){
                                                contSobj =UpdateSequenceOnParticipant(mapOfContactsWithSequenceIsNull.get(associateContactofOpp),cad);
                                            }
                                            if(contSobj != null && (Boolean)contSobj.get(nameSpace + 'isActivated__c')) {
                                                sObjectsToProcess.add((Contact)contSobj);
                                                objIdToAllCadActListMap.put((Id)contSobj.get('Id'), cad.CadenceActions__r);
                                            }  
                                        }
                                    }else{
                                        Sobject contSobj;
                                        if(mapOfContactsWithSequenceIsNull.containskey(associateContactofOpp)){
                                            contSobj =UpdateSequenceOnParticipant(mapOfContactsWithSequenceIsNull.get(associateContactofOpp),cad);
                                        }
                                        if(contSobj != null && (Boolean)contSobj.get(nameSpace + 'isActivated__c')) {
                                            sObjectsToProcess.add((Contact)contSobj);
                                            objIdToAllCadActListMap.put((Id)contSobj.get('Id'), cad.CadenceActions__r);
                                        }
                                    }
                                }
                            }
                        }else{
                            sObjectsToProcess.add(obj);
                            objIdToAllCadActListMap.put((Id)obj.get('Id'), cad.CadenceActions__r);
                        }
                        
                    }				
                } else {
                    if(objName.equalsIgnoreCase(CadenceConstants.OPPORTUNITY_OBJECT_NAME)){
                        string oppIds = String.valueOf(obj.get('Id'));
                        if(mapOfOppcontact.keyset().size() > 0 && mapOfOppcontact.containskey(oppIds)){
                            for(String associateContactofOpp :mapOfOppcontact.get(oppIds)){
                                Contact contSobj = new Contact();
                                Cadence__c cad = RuleCriterionMatcher.assignCadenceToNotAssignedParticipant(cadMapNew, obj, parentMap.get((Id)obj.get('Id')), objName);
                                if(cad != null){
                                    Set<String> setOfMatchRole;
                                    if(CadenceService.mapOfOpportunityRole.containskey(oppIds)){
                                        setOfMatchRole = CadenceService.mapOfOpportunityRole.get(oppIds);
                                    } 
                                    if(CadenceService.mapOfOpportunityRole.containskey(oppIds)){
                                        if(setOfMatchRole.contains(associateContactofOpp)){
                                            if(mapOfContactsWithSequenceIsNull.containskey(associateContactofOpp)){
                                                contSobj =(Contact)UpdateSequenceOnParticipant(mapOfContactsWithSequenceIsNull.get(associateContactofOpp),cad);
                                            }
                                            if(contSobj != null && contSobj.isActivated__c) {
                                                sObjectsToProcess.add(contSobj);
                                                objIdToAllCadActListMap.put(contSobj.Id, cad.CadenceActions__r);
                                            }
                                        }
                                    }
                                    else{
                                        if(mapOfContacts.containskey(associateContactofOpp)){
                                            contSobj =(Contact)UpdateSequenceOnParticipant(mapOfContacts.get(associateContactofOpp),cad);
                                        }
                                        if(contSobj != null && contSobj.isActivated__c) {
                                            sObjectsToProcess.add(contSobj);
                                        }
                                    }
                                }
                                
                            }
                        }
                    }else{
                         unmatchedParticipantsList.add(obj);
                     }
                }
            }
        }
        //Insert participant History for sequence 
        if(newSequenceHistory != null && newSequenceHistory.size() > 0)
            insert newSequenceHistory;
        
        //Update Contact which exit match form Opportunity
        if(oppContactList != null && oppContactList.size() > 0){
            Database.SaveResult[] results = Database.update(oppContactList, false);
        }
        
		//Update Opportunity 
        if(sObjectsForOpportunity != null && sObjectsForOpportunity.size() > 0){
            Database.SaveResult[] results = Database.update(sObjectsForOpportunity, false);
        } 
        
        //Deleting old non performed participant actions 
        CadenceService.deleteUnperformedPartActions(oldPartActionToDelete, objName);
        //Creating new participant actions for new cadence  
        CadenceService.createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(sObjectsToProcess), objName); 
        ParticipantsToProcess participantsToProcess = new ParticipantsToProcess();
        participantsToProcess.participantsToUpdate = New Set<SObject>(sObjectsToProcess);
        sObjectsToProcess.addAll(unmatchedParticipantsList);
        participantsToProcess.allParticipantsToProcess = sObjectsToProcess;

        return participantsToProcess;
    }     
    
    public static Map<Id,List<Id>> getParticipantSequenceHistory(Set<Id> objIds,String objName){
        //This method will return Map contain ParticipantId as Key and List of sequenceIds as values that assigned Participant in past.
        Map<Id,List<Id>> sequenceHistoryMap = new Map<Id,List<Id>>();
        List<Id> sequenceIds;
        List<Participant_Sequence_History__c> sequenceHistory = [Select Sequence_Id__c,Lead_Id__c,Contact_Id__c
                                                                 From Participant_Sequence_History__c 
                                                                 where Lead_Id__c IN :objIds OR Contact_Id__c IN :objIds ];
        
        
        for(Participant_Sequence_History__c obj:sequenceHistory){
            if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                if(obj.Lead_Id__c != null && sequenceHistoryMap.containsKey(obj.Lead_Id__c)){
                    sequenceIds = new List<Id>();
                    sequenceIds = sequenceHistoryMap.get(obj.Lead_Id__c);
                    sequenceIds.add(obj.Sequence_Id__c); 
                }
                else{
                    sequenceIds = new List<Id>();
                    sequenceIds.add(obj.Sequence_Id__c); 
                    sequenceHistoryMap.put(obj.Lead_Id__c, sequenceIds);
                }
            }
            else{
                if(obj.Contact_Id__c != null && sequenceHistoryMap.containsKey(obj.Contact_Id__c)){
                    sequenceIds = new List<Id>();
                    sequenceIds = sequenceHistoryMap.get(obj.Contact_Id__c);
                    sequenceIds.add(obj.Sequence_Id__c); 
                }
                else{
                    sequenceIds = new List<Id>();
                    sequenceIds.add(obj.Sequence_Id__c); 
                    sequenceHistoryMap.put(obj.Contact_Id__c, sequenceIds);
                }    
            }
        }  
        return sequenceHistoryMap;
    }
    
    public static Map<Id, Cadence__c> removeCadencefromMap(Map<Id, Cadence__c> cadMap,List<Id> sequenceIds){
        if(sequenceIds == null || cadMap == null){
            return cadMap; 
        }
        for(Id seqId:sequenceIds){
            cadMap.remove(seqId);
        }
        return cadMap; 
    }
    
    public static Participant_Sequence_History__c createHistoryObject(Id sequenceId,Id objId,String objName){
        Participant_Sequence_History__c history = new Participant_Sequence_History__c();
        history.Sequence_Id__c = sequenceId;
        if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
            history.Lead_Id__c = objId;
        }
        else{
            history.Contact_Id__c = objId;
        }
        return history;
    }
    
    public static Map<Id, List<Sequence_Action__c>> performParticipantActions(List<SObject> objList, Map<Id, List<Sequence_Action__c>> partActionsMap) {
        Map<Id, List<Sequence_Action__c>> performedPartActions = new Map<Id, List<Sequence_Action__c>>(); 
        Map<Id, SObject> objMap = new Map<Id, SObject>(objList); 
        List<Sequence_Action__c> partActToUpdate = new List<Sequence_Action__c>();
        List<Task> tasksToCreate = new List<Task>();
        List<Messaging.MassEmailMessage> emailsToSend = new List<Messaging.MassEmailMessage>();
        List<NativeEmailMessage> nativeEmailToSend = new List<NativeEmailMessage>();
        List<Id> emailTemplateIdList = new List<Id>();
        //Return if no unperformed participant actions 
        if(partActionsMap == null || partActionsMap.isEmpty()) {
            return performedPartActions;
        } 
        //Processing the data to perform 
        for(Id objId : partActionsMap.keySet()) {
            for(Sequence_Action__c partAct : partActionsMap.get(objId)) {
                Boolean performed = false,IsTaskNotCompleted = false;
                if(partAct.CadenceAction_Id__r.Action_Id__r.Activation_Type__c.equals(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                    //Processing email type of participant action
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Type__c != null && partAct.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_EMAIL)) {
                        if(objMap.containsKey(objId) && objMap.get(objId).get('Email')!=null) {
                            String nativeMailTo = String.valueOf(objMap.get(objId).get('Email'));
                            String nativeNameTo = String.valueOf(objMap.get(objId).get('Name'));
                            String participantOwnerId = String.valueOf(objMap.get(objId).get('OwnerId'));
                            Id userId = Id.valueOf(participantOwnerId);
                            if(partAct.CadenceAction_Id__r.Action_Id__r.Email_Type__c != null && partAct.CadenceAction_Id__r.Action_Id__r.Email_Type__c.equals(CadenceConstants.NATIVE_EMAIL_TYPE)){
                                nativeEmailToSend.add(createNativeEmailMessage(nativeMailTo, partAct.CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                                                               objId, partAct.Id, nativeNameTo, userId));
                            }else{
                                emailsToSend.add(createEmailMessage(objId, partAct.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            }
                            tasksToCreate.add(getEmailTask(partAct.Id, partAct.Name, objId, partAct.CadenceAction_Id__r.Action_Id__r.Template_Id__c));
                            performed = true;
                        } 
                    }
                } else { 
                    //Setting show on target list to true if it's a manual task
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Activation_Type__c.equals(CadenceConstants.PARTICIPANT_ACTIVATION_MANUAL)) {
                        
                    if(partAct.CadenceAction_Id__r.Action_Id__r.Type__c.equals(CadenceConstants.ACTION_TYPE_TASK)) {
                        Task tsk = performTaskAction(objId, partAct.CadenceAction_Id__r.Action_Id__r.Task_Description__c);
                        tsk.Sequence_Action__c = partAct.Id; 
                        tasksToCreate.add(tsk);
                        if(tsk.Status == 'Completed'){
                            performed = true;   
                        }else{
                        	 IsTaskNotCompleted = true;
                        }
                        
                     }
                        else{
                            	partAct.Show_on_Target_List__c = true;
                        		partActToUpdate.add(partAct);    
                        }
                        
                        
                    }
                }
                if(performed) {
                    partAct.Actual_Execution_Date__c = System.Now();
                    partAct.isActionPerformed__c = true;
                    partActToUpdate.add(partAct);
                    if(performedPartActions.containsKey(objId)) {
                        performedPartActions.get(objId).add(partAct);
                    } else {
                        performedPartActions.put(objId, new List<Sequence_Action__c>{partAct});
                    }
                }
                if(IsTaskNotCompleted) {
                    partAct.Show_on_Target_List__c = true;
                    partAct.isActionPerformed__c = false;
                    partActToUpdate.add(partAct);
                    if(performedPartActions.containsKey(objId)) {
                        performedPartActions.get(objId).add(partAct);
                    } else {
                        performedPartActions.put(objId, new List<Sequence_Action__c>{partAct});
                    }
                }
           } 
        }
        if(!nativeEmailToSend.isEmpty()) {
            List<Messaging.MassEmailMessage> failedNativeEmailList =  SendNativeEmail(nativeEmailToSend);
            if (!failedNativeEmailList.isEmpty()){
                emailsToSend.addAll(failedNativeEmailList);
            }
        }
        if(!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
        }
	    
        if(!tasksToCreate.isEmpty()) {
            if(System.isBatch()) {
                Database.SaveResult[] results = Database.insert(tasksToCreate, false);
            } else {
                String tasksJson = JSON.serialize(tasksToCreate); 
                createTasks(tasksJson);
            }
        } 
	    
        if(!partActToUpdate.isEmpty()) {
            Database.update(partActToUpdate, false);
        } 
	    
        return performedPartActions;
    } 
    
    @future
    public static void createTasks(String tasksJson) {
        List<Task> tasks = (List<Task>)JSON.deserialize(tasksJson, List<Task>.class);
        //insert tasks; 
        Database.SaveResult[] results = Database.insert(tasks, false);
    }
    
    public static List<SObject> updateSObjectFields(List<SObject> objList, Map<Id, List<Sequence_Action__c>> partActionsMap, String objName, Boolean isAfter) {
        
        //Returning if list is empty		
        if(partActionsMap == null || partActionsMap.isEmpty()) {
            return null;
        }
        
        //Handling after update triggers 
        List<SObject> sObjectList = new List<SObject>();
        if (isAfter){
            for(SObject sObj : objList) {
                if(objName.equals(CadenceConstants.LEAD_OBJECT_NAME)) {
                    sObjectList.add(new Lead(Id=(Id)sObj.get('Id')));
                } else {
                    sObjectList.add(new Contact(Id=(Id)sObj.get('Id')));
                }
            }
            objList = sObjectList;
        }
        
        Map<Id, SObject> sObjsToUpdate = new Map<Id, SObject>();
        Map<Id, SObject> objMap = new Map<Id, SObject>(objList);
        Map<Id, SObject> opportunityMap = new Map<Id, SObject>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<Sequence_Action__c> partActList = new List<Sequence_Action__c>();
        
        //Getting fields map 
        Map<String, List<String>> objfieldDataTypeMap = CadenceUtil.getObjectFieldsType(objName);
        
        Map<String, List<String>> opportunityFieldDataTypeMap = new Map<String, List<String>>();
        //Gettting participant action list 
        for(Id objId : partActionsMap.keySet()) {
            partActList.addAll(partActionsMap.get(objId));
        } 		
        
        Boolean isOpportuityType = false;
        List<String> opportunityIdList = new List<String>();
        for(Sequence_Action__c partAct : partActList) {
            if(partAct.Cadence_Type__c == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
                isOpportuityType = true;
                break;
            }
        }
        
        if(isOpportuityType){
            opportunityFieldDataTypeMap = CadenceUtil.getObjectFieldsType(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
            for(SObject obj : objList){
                opportunityIdList.add(String.valueOf(obj.get('Opportunity_Id__c')));
            }
            opportunityList = CadenceSelector.getOpportunity(opportunityIdList,CadenceConstants.OPPORTUNITY_OBJECT_NAME);
            opportunityMap = new Map<Id, SObject>(opportunityList);
        }
        //Updating the obj fields 
        for(Sequence_Action__c partAct : partActList) {
            String fieldsToUpdate = partAct.CadenceAction_Id__r.Fields_To_Update_Action__c;
            if(fieldsToUpdate != null && !fieldsToUpdate.equals('')) {
                Map<String, Object> fieldMap = (Map<String, Object>)(JSON.deserializeUntyped(fieldsToUpdate));
                fieldMap.remove('sobjectType');
                Id objId;
                if(partAct.Cadence_Type__c.equals(CadenceConstants.OPPORTUNITY_OBJECT_NAME) && String.isNotBlank(partAct.Opportunity_Id__c)){
                    objId = partAct.Opportunity_Id__c;
                } else if(partAct.Lead_Id__c != null) {
                    objId = partAct.Lead_Id__c;
                } else {
                    objId = partAct.Contact_Id__c;
                }
		Object valueToUpdate = '';
                for(String fieldName : fieldMap.keySet()) {
                    List<String> apiList;
                    if(partAct.Cadence_Type__c == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
                        apiList = opportunityFieldDataTypeMap.get(fieldName);
		        valueToUpdate = GetUpdateValue(fieldMap.get(fieldName), apiList[1], valueToUpdate);
	     		CadenceUtil.updateFieldValue(opportunityMap.get(objId), apiList[0], valueToUpdate, apiList[1]);
                    }else{
                        apiList = objfieldDataTypeMap.get(fieldName);
			valueToUpdate = GetUpdateValue(fieldMap.get(fieldName), apiList[1], valueToUpdate);
			CadenceUtil.updateFieldValue(objMap.get(objId), apiList[0], valueToUpdate, apiList[1]);
                    }
                    
                }
                sObjsToUpdate.put(objId, objMap.get(objId));					
            }
        }
        if(opportunityList != null && opportunityList.size() > 0){
           Database.SaveResult[] results = Database.update(opportunityList, false);
        }
        return sObjsToUpdate.values();
        
    }
    
    public static void processParticipantsWithCadences(List<SObject> objList, Map<Id, SObject> parentMap, String objName, Boolean isTrigger) {
        Map<Id, Cadence__c> cadMap = CadenceSelector.getActiveCadencesByRecordType(New List<String> {objName});
        Map<Id, List<Sequence_Action__c>> partActToPerform = new Map<Id, List<Sequence_Action__c>>();
        
        //Getting objList to process (for perform cadence actions on it)
        ParticipantsToProcess participantsToProcess = CadenceService.getSObjectsToProcess(objList, parentMap, cadMap, objName);
        Map<Id, SObject> objMap = new Map<Id, SObject>(participantsToProcess.allParticipantsToProcess);
        //Getting non performed participant actions 
        Map<Id, List<Sequence_Action__c>> partActionsMap = CadenceService.getRemainingParticipantAction(objMap.keySet(), objName);
        
        //Getting participant action to perform 
        for(SObject sObj : objMap.values()) {
            if(partActionsMap.get((Id)sObj.get('Id')) == null) {
                continue;
            }
            Sequence_Action__c sa = partActionsMap.get((Id)sObj.get('Id')).get(0);
            if((Boolean)sObj.get(nameSpace+'isActivated__c') && sa.Show_on_Target_List__c == false) {
                SObject parentObj;
                if(parentMap.containsKey((Id)sObj.get('Id'))) {
                    parentObj = parentMap.get((Id)sObj.get('Id'));
                }
                List<Sequence_Action__c> partActList = RuleCriterionMatcher.getMatchingParticipantActions(cadMap.get((Id)sObj.get(nameSpace+'Cadence_Id__c')), sObj, parentObj, new List<Sequence_Action__c>{sa}, objName);
                if(!partActList.isEmpty()) {
                    partActToPerform.put((Id)sObj.get('Id'), partActList);		
                }
            } 	
        } 
        
        //perform participant actions  
       Map<Id, List<Sequence_Action__c>> performedPartAct = CadenceService.performParticipantActions(objMap.values(), partActToPerform);
        
        //perform participant field update
        List<SObject> fieldsUpdatedParticipants = New List<SObject>(); 
        fieldsUpdatedParticipants = CadenceService.updateSObjectFields(objMap.values(), performedPartAct, objName, false);
        
        if(!isTrigger) {
            Database.UpsertResult [] upsertResult;
            try{
                Set<SObject> listToUpdateParticipants = new Set<SObject>();
                listToUpdateParticipants.addAll(participantsToProcess.participantsToUpdate);
                if(fieldsUpdatedParticipants != null){
                    listToUpdateParticipants.addAll(New Set<SObject>(fieldsUpdatedParticipants));
                }
                if(listToUpdateParticipants.size() > 0) {
                    Contacts.flag = false;
                    Database.SaveResult[] results = Database.update(New List<SObject>(listToUpdateParticipants), false); 
                }
           	}catch(exception e){    
            	Contacts.flag =false;
            }
            
        }  
        updateRemainingParticipantAction(performedPartAct,partActionsMap);
    }
    
    public static void updateRemainingParticipantAction(Map<Id, List<Sequence_Action__c>> performedPartAct,Map<Id, List<Sequence_Action__c>> partActionsMap){
        //Updating dates on remaining participant objects 
        List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
        for(Id objId : performedPartAct.keySet()) {
            for(Sequence_Action__c sa : performedPartAct.get(objId)) { 
                Id partId = sa.Lead_Id__c == null ? sa.Contact_Id__c : sa.Lead_Id__c; 
                saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, partActionsMap.get(partId)));
            }
        }
       
        if(!saToUpdate.isEmpty()) {
            update saToUpdate;
        }
    }
    
    public static Map<Id, SObject> getParentObject(List<SObject> objList, String parentFieldName, String parentName) {
        
        Map<Id, SObject> parentMap = new Map<Id, SObject>();
        
        //Checking for parent field exist or not 
        try{
            objList.get(0).get(parentFieldName);    
        } catch(Exception e) {
            return parentMap;
        }
        
        //Getting the parent obj Map
        Set<Id> parentIds = new Set<Id>(); 
        for(SObject obj : objList) {
            if(obj.get(parentFieldName) != null) {
                parentIds.add((Id)obj.get(parentFieldName));
            }
        }
        
        //Getting parent Object records map 
        List<SObject> parentList;
        String query = CadenceUtil.getSObjectQuery(parentName);
        if(query != null) {
            query = query + 'Where Id in : parentIds';
            parentList = Database.query(query);
            return new Map<Id, SObject>(parentList);
        } 
        return parentMap;
    }
    
    
    public static boolean validForCriteria(String objectName, String fieldName){
        if (objectName == CadenceConstants.CONTACT_OBJECT_NAME){
            if (fieldName == 'MasterRecordId' || fieldName == 'AccountId' 
                || fieldName == 'CreatedById' || fieldName == 'LastModifiedById' || fieldName == 'OwnerId'
                || fieldName == 'ReportsToId' || fieldName == nameSpace+'Cadence_ID__c' ){
                return true;
            }else {
                return false;
            }
        }else if (objectName == CadenceConstants.ACCOUNT_OBJECT_NAME){
            if (fieldName == 'MasterRecordId' || fieldName == 'ParentId' 
                || fieldName == 'CreatedById' || fieldName == 'LastModifiedById' || fieldName == 'OwnerId'
                || fieldName == 'DandbCompanyId'  ){
                return true;
            }else {
                return false;
            }
        }else if (objectName == CadenceConstants.LEAD_OBJECT_NAME){
            if (fieldName == 'MasterRecordId' 
                || fieldName == 'CreatedById' || fieldName == 'LastModifiedById' || fieldName == 'OwnerId'
                || fieldName == 'DandbCompanyId' || fieldName == nameSpace+'Cadence_ID__c' ){
                return true;
            }else {
                return false;
            }
        }else if (objectName == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
            if (fieldName == nameSpace+'Celigo_Contract__c' 
                || fieldName == nameSpace+'Champion__c' || fieldName == nameSpace+'Distributor__c' || fieldName == nameSpace+'Economic_Buyer__c'
                || fieldName == nameSpace+'Eligible_Account_For_Channel_Sales__c' || fieldName == nameSpace+'End_User__c' 
                || fieldName == nameSpace+'From_Contract__c' || fieldName == nameSpace+'Order__c' || fieldName == nameSpace+'Reseller__c'){
                return true;
            }else {
                return false;
            }
        }else  {
            return false;
        }
    }
    
    //********************************Updated Logic required methods ************//
    public static Map<Id, List<Sequence_Action__c>> getRemainingParticipantAction(Set<Id> objIds, String objName) {
		
        Map<Id, List<Sequence_Action__c>> objIdToSequenceActionsMap = new Map<Id, List<Sequence_Action__c>>();
        
        //Getting all the available and unperformed action for object
        List<Sequence_Action__c> participantActions = new List<Sequence_Action__c>();
            
        if(objName == CadenceConstants.OPPORTUNITY_OBJECT_NAME){
            participantActions = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c,Opportunity_Id__c,Cadence_Type__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c, CadenceAction_Id__r.Action_Id__r.Email_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                  CadenceAction_Id__r.Index__c, Expected_Execution_Date__c, Actual_Execution_Date__c From Sequence_Action__c 
                                  where Contact_Id__c IN : objIds AND CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = 'Opportunity' AND Opportunity_Id__c != null AND isActionPerformed__c = false AND isDeferred__c = false 
                                  order by CadenceAction_Id__r.Index__c];
        }
        else{
            participantActions = [Select Id, Name, CadenceAction_ID__c, Show_on_Target_List__c, Lead_Id__c, Contact_Id__c,Opportunity_Id__c,Cadence_Type__c, isActionPerformed__c, CadenceAction_Id__r.Day__c,
                                  CadenceAction_Id__r.Hour__c, CadenceAction_Id__r.Action_Id__r.Type__c, CadenceAction_Id__r.Fields_To_Update_Action__c,
                                  CadenceAction_Id__r.Action_Id__r.Activation_Type__c, CadenceAction_Id__r.Trigger_Type__c, CadenceAction_Id__r.Action_Id__r.Email_Type__c,
                                  CadenceAction_Id__r.Action_Id__r.Task_Description__c, CadenceAction_Id__r.Action_Id__r.Template_Id__c, 
                                  CadenceAction_Id__r.Index__c, Expected_Execution_Date__c, Actual_Execution_Date__c From Sequence_Action__c 
                                  where (Lead_Id__c IN :objIds OR Contact_Id__c IN : objIds) AND CadenceAction_ID__r.Cadence_Id__r.Record_Type__c != 'Opportunity' AND isActionPerformed__c = false AND isDeferred__c = false 
                                  order by CadenceAction_Id__r.Index__c];
        }
        
        for(Sequence_Action__c sequenceAct : participantActions) {
            if(sequenceAct.Lead_Id__c == null && sequenceAct.Contact_Id__c == null) {
                continue;
            }
			
            if(sequenceAct.Lead_Id__c == null) {
                if(!objIdToSequenceActionsMap.containsKey(sequenceAct.Contact_Id__c)) {
                    objIdToSequenceActionsMap.put(sequenceAct.Contact_Id__c, new List<Sequence_Action__c>{sequenceAct});	    
                } else {
                    objIdToSequenceActionsMap.get(sequenceAct.Contact_Id__c).add(sequenceAct);
                }	    
            } else {
                if(!objIdToSequenceActionsMap.containsKey(sequenceAct.Lead_Id__c)) {
                    objIdToSequenceActionsMap.put(sequenceAct.Lead_Id__c, new List<Sequence_Action__c>{sequenceAct});    
                } else {
                    objIdToSequenceActionsMap.get(sequenceAct.Lead_Id__c).add(sequenceAct);
                }
            }
        }
        return objIdToSequenceActionsMap;
    } 
    
    //This method is to process participant if they are activated firstTime
    public static void processParticipantActivation(Map<Id, Cadence__c> cadMap, List<SObject> objList, String objName) {
        Map<Id, List<CadenceAction__c>> objIdToAllCadActListMap = new Map<Id, List<CadenceAction__c>>();
        for(SObject Obj : objList){
            if((Boolean)Obj.get(nameSpace + 'isActivated__c') == true && Obj.get(nameSpace + 'EntranceCriteria_Matched_Date__c') == null){
                Obj.put(nameSpace + 'EntranceCriteria_Matched_Date__c', System.now());
                if(cadMap != null && cadMap.containsKey((Id)Obj.get(nameSpace+'Cadence_Id__c'))) {
                    objIdToAllCadActListMap.put((Id)Obj.get('Id'), cadMap.get((Id)Obj.get(nameSpace+'Cadence_Id__c')).CadenceActions__r);
                }
            } 
        }
        if(objList != null && objList.size() > 0){
            SObject sObj = objList.get(0);
            if (sObj.get('Id') != null){
                CadenceService.createActionParticipants(objIdToAllCadActListMap, new Map<Id, SObject>(objList), objName);
            }
        }
        
	}
    
    
    public static List<Sequence_Action__c> updateActionOnParticipantExpectedDate(DateTime lastExecutionDate, Integer index, List<Sequence_Action__c> updateActions) {
        List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
        Integer day = 0, hour = 0;
        DateTime executionDate = lastExecutionDate,nextDate;

        if (lastExecutionDate == null) {
            return saToUpdate;
        }
        
        if(updateActions == null) {
            return saToUpdate;
        }
        for(Sequence_Action__c sa : updateActions) {
            if(sa.Actual_Execution_Date__c == null && sa.isActionPerformed__c == false && sa.CadenceAction_Id__r.Index__c > index) {
                if(sa.CadenceAction_ID__r.Day__c != null) {
                    day = day + (Integer)sa.CadenceAction_ID__r.Day__c;
                }
                if(sa.CadenceAction_ID__r.Hour__c != null) {
                    hour = hour + (Integer)sa.CadenceAction_ID__r.Hour__c;
                }
                nextDate = CadenceUtil.addTimeInDate(executionDate, day, hour);
                sa.Expected_Execution_Date__c = nextDate;
                saToUpdate.add(sa);
            }	    
        }
        return saToUpdate;
    }
    
    /**
     * @description - Update IsPerformed.
     * @param ids - List of Action On Participant Ids.
     * @return - List<Task> - Action On Participant Ids
     */
    public  static void UpdateIsPerformed(List<Task> taskList){
        List<Id> ActionOnParticipantIds = new List<Id>(); 
        for(Task task: taskList){
            ActionOnParticipantIds.add(task.Sequence_Action__c);
        }
        
       	List<Sequence_Action__c> actionOnParticipantList=[Select Id,isActionPerformed__c,Actual_Execution_Date__c,Lead_Id__c,Contact_Id__c,CadenceAction_Id__r.Index__c  from Sequence_Action__c Where Id in: ActionOnParticipantIds order by CadenceAction_Id__r.Index__c];
        for(Sequence_Action__c AOP:actionOnParticipantList){
            AOP.isActionPerformed__c = True;
            AOP.Actual_Execution_Date__c = System.now();
        }
        if(actionOnParticipantList != null && actionOnParticipantList.size() > 0){
            update actionOnParticipantList;
        }
       
        Map<Id, List<Sequence_Action__c>> objToPartActMap = new Map<Id, List<Sequence_Action__c>>();
        objToPartActMap = TaskService.getAllParticipantActionsForTaskOwner(taskList);
        
        //Updating dates on remaining participant objects
        List<Sequence_Action__c> saToUpdate = new List<Sequence_Action__c>();
        for(Sequence_Action__c sa : actionOnParticipantList) {
            Id objId = sa.Lead_Id__c == null ? sa.Contact_Id__c : sa.Lead_Id__c;
            saToUpdate.addAll(CadenceService.updateActionOnParticipantExpectedDate(sa.Actual_Execution_Date__c, (Integer)sa.CadenceAction_Id__r.Index__c, objToPartActMap.get(objId)));
        }
        
        if(!saToUpdate.isEmpty()) {                        
            update saToUpdate;
        }
    }
        
    //This method mark action as IsPerformed = True if this is task and Task status is completed. 
   public static void updateIsPerformedOnActionOnParticipant(Set<Id> ids) {
        List<Task> taskList = CadenceSelector.getActionOnParticipantId(ids);   
        CadenceService.UpdateIsPerformed(taskList);
   }
    
    public static List<CriterionWrapper> getFieldsWithLabelsForBatch(List<String> objectlist){
        String objectStr ; 
        List<Criterion> fieldsWithLabels = new List<Criterion>();
        List<CriterionWrapper> fieldList = new List<CriterionWrapper>();      
        CriterionWrapper criterionWrapper,criterionWrapperPartnerAccount;
        Integer index = 0;
        Boolean IsPartnerAccount = false;
        List<Schema.DescribeSObjectResult> descResult = Schema.describeSObjects(CadenceUtil.getValidSObjectListInOrg(objectlist));
        if(descResult != null && descResult.size() > 0){
            for(Schema.DescribeSObjectResult dsc : descResult){ 
                if(dsc != null && dsc.getName()!= null){
                    criterionWrapper = new CriterionWrapper();
                    objectStr =dsc.getName(); 
                    Schema.sObjectType sObjectName = Schema.getGlobalDescribe().get(objectStr);
                    if (sObjectName != null){
                        criterionWrapper.GroupName = objectStr;
                        if(index == 0){
                            criterionWrapper.IsParent = true;
                        }
                        
                        if(objectlist[0] == CadenceConstants.OPPORTUNITY_OBJECT_NAME && objectStr == CadenceConstants.ACCOUNT_OBJECT_NAME){
                            IsPartnerAccount = true;
                            criterionWrapperPartnerAccount = new CriterionWrapper();
                            criterionWrapperPartnerAccount.GroupName = CadenceConstants.PARTNER_ACCOUNT_OBJECT_DISPLAY_NAME;
                        }
                        
                        SObjectType r = dsc.getSobjectType(); 
                        Map<String, Schema.SObjectField> fieldsMap = dsc.fields.getMap(); 
                        for (String field : fieldsMap.keySet()) {
                            Criterion c = new Criterion();
                            Schema.sObjectField fieldAPIName = fieldsMap.get(field);
                            Schema.DisplayType fieldDataType = fieldAPIName.getDescribe().getType();           
                            Schema.DescribeFieldResult dfr = fieldAPIName.getDescribe();
                            c.fieldName = fieldAPIName.getDescribe().getName();
                            Integer LengthOfField = dfr.getLength();
                            if (fieldDataType == Schema.DisplayType.Boolean 
                                || fieldDataType == Schema.DisplayType.REFERENCE
                                || fieldDataType == Schema.DisplayType.Double 
                                || fieldDataType == Schema.DisplayType.Integer
                                || fieldDataType == Schema.DisplayType.Email
                                || fieldDataType == Schema.DisplayType.Phone
                                || fieldDataType == Schema.DisplayType.Date 
                                || fieldDataType == Schema.DisplayType.URL
                                || fieldDataType == Schema.DisplayType.Currency
                                || fieldDataType == Schema.DisplayType.DateTime
                                || (fieldDataType == Schema.DisplayType.String )
                                || fieldDataType == Schema.DisplayType.Picklist
                                || (fieldDataType == Schema.DisplayType.Textarea && (LengthOfField <= 255 && (fieldDataType != Schema.DisplayType.ENCRYPTEDSTRING)) )               
                                || fieldDataType == Schema.DisplayType.Combobox
                                || fieldDataType == Schema.DisplayType.MULTIPICKLIST
                               ){
                                   c.fieldName = fieldAPIName.getDescribe().getName();
                                   c.fieldLabel = fieldAPIName.getDescribe().getLabel();
                                   c.fieldDataType = getDataType(objectStr, c.fieldName);
                                   
                                   if (c.fieldDataType == 'Picklist' || c.fieldDataType == 'MultiPickList'){
                                       c.listPicklistValues = getPicklistValues(objectStr, c.fieldName);
                                   }
                                   if(index != 0){
                                       c.fieldName =  objectStr + '.' + c.fieldName;
                                   }
                                   if(!(objectStr == CadenceConstants.OPPORTUNITY_ROLE_OBJECT_NAME && c.fieldLabel == 'Primary')){
                                       fieldsWithLabels.add(c);
                                   }
                                   
                               } 
                        }
                    }
                }
                index++; 
                criterionWrapper.fieldsDetail = fieldsWithLabels;
                fieldList.add(criterionWrapper);
                
                if(IsPartnerAccount && Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('PartnerAccountId') != null){
                    for(Criterion c : fieldsWithLabels){
                        String[] fields = c.fieldName.split('\\.');
                        if(fields.size() > 0){
                            Criterion criterion  = new Criterion();
                            criterion.id=c.id;
                            criterion.fieldName = partnerAccountAPIName +'.' + fields[1];
                            criterion.fieldLabel=c.fieldLabel;
                            criterion.fieldDataType=c.fieldDataType;
                            criterion.operation=c.operation;
                            criterion.value=c.value;
                            criterion.listPicklistValues=c.listPicklistValues;
                            criterion.picklistApiNameAndValues=c.picklistApiNameAndValues;
                            criterionWrapperPartnerAccount.fieldsDetail.add(criterion);
                        }
                    }
                    IsPartnerAccount = false;
                    if(criterionWrapperPartnerAccount != null){
                        fieldList.add(criterionWrapperPartnerAccount); 
                    }
                }
                fieldsWithLabels = new List<Criterion>();
                
            }
        }
        
       
        
        return fieldList;
    }
    
    public static Sobject UpdateSequenceOnParticipant(Sobject partObj,Cadence__c cadToUpdate){
            partObj.put(nameSpace+'Cadence_Id__c', cadToUpdate.Id); 
            if(cadToUpdate.Participent_Activation__c.equalsIgnoreCase(CadenceConstants.PARTICIPANT_ACTIVATION_AUTOMATIC)) {
                partObj.put(nameSpace+'isActivated__c', true);
                partObj.put(nameSpace+'EntranceCriteria_Matched_Date__c', System.now());
            } else {
                partObj.put(nameSpace+'isActivated__c', false);
            }
        return partObj;
		
    }
    public static map<string,List<String>> opporContactMap(List<sobject> sobjectList){
        map<string,List<String>> mapOfoppcontactIds= new map<String,List<string>>();
        List<String> setOfcontactstring = new List<string>();
        List<String> allcontacts = new List<string>();
        list<OpportunityContactRole> templist = [Select ContactId,OpportunityId From OpportunityContactRole Where OpportunityId In :(sobjectList)];
        for(OpportunityContactRole oppCont : templist){
            setOfcontactstring = new List<string>();
            if(oppCont.ContactId != null ){
                if(mapOfoppcontactIds.containskey(oppCont.OpportunityId) && mapOfoppcontactIds.get(oppCont.OpportunityId) != null){
                    setOfcontactstring = mapOfoppcontactIds.get(oppCont.OpportunityId);
                    setOfcontactstring.add(oppCont.ContactId);
                }else{
                    setOfcontactstring.add(oppCont.ContactId);
                }
                
            }
            mapOfoppcontactIds.put(oppCont.OpportunityId,setOfcontactstring);
            allcontacts.addAll(setOfcontactstring);
        }
        
        List<Contact> contactList = [Select Id,Opportunity_Id__c from Contact Where Id in:setOfcontactstring];
        for(Contact con:contactList){
            con.Opportunity_Id__c = GetOpportunityIdByContactId(mapOfoppcontactIds,con.Id);
        }
        if(contactList != null && contactList.size() > 0 ){
             Database.SaveResult[] results = Database.update(contactList, false);
        }
        return mapOfoppcontactIds;
    }
    
    public static map<string,List<String>> getOpportunityOrContactMap(List<sobject> sobjectList){
        map<string,List<String>> mapOfoppcontactIds= new map<String,List<string>>();
        List<String> setOfcontactstring = new List<string>();
        list<OpportunityContactRole> contactRoleList = [Select ContactId,OpportunityId From OpportunityContactRole Where ContactId In :(sobjectList)];
        for(OpportunityContactRole oppCont : contactRoleList){
            setOfcontactstring = new List<string>();
            if(oppCont.ContactId != null ){
                if(mapOfoppcontactIds.containskey(oppCont.OpportunityId) && mapOfoppcontactIds.get(oppCont.OpportunityId) != null){
                    setOfcontactstring = mapOfoppcontactIds.get(oppCont.OpportunityId);
                    setOfcontactstring.add(oppCont.ContactId);
                }else{
                    setOfcontactstring.add(oppCont.ContactId);
                }
                
            }
            mapOfoppcontactIds.put(oppCont.OpportunityId,setOfcontactstring);
        }
        return mapOfoppcontactIds;
    }
    
    public static void getMapOpporContactRole(List<sobject> sobjectList){
        List<OpportunityContactRole> listOfContactRole = new List<OpportunityContactRole>();
        map<String,list<OpportunityContactRole>> mapOfOppContRole=new map<String,list<OpportunityContactRole>>();
        for(OpportunityContactRole oppCont : [Select ContactId,OpportunityId,Role From OpportunityContactRole Where OpportunityId In :(sobjectList)]){
            if(mapOfOppContRole.containskey(oppCont.OpportunityId)){
                if(mapOfOppContRole.get(oppCont.OpportunityId) != null)
                listOfContactRole =  mapOfOppContRole.get(oppCont.OpportunityId);
                listOfContactRole.add(oppCont);
            }  
            else
                listOfContactRole.add(oppCont);
                
            mapOfOppContRole.put(oppCont.OpportunityId,listOfContactRole);
        }
        CadenceService.mapOfOppContactRoles =mapOfOppContRole;
    }
    
    public static List<Contact> RemoveSequenceFromParticempant(string opportunityId, map<string,List<String>> mapOfOppcontact,map<String,Sobject> mapOfContacts){
        List<Contact> contactList = new List<Contact>();
        Contact contactObj = new Contact();
        if(mapOfOppcontact != null && mapOfOppcontact.containsKey(opportunityId) && mapOfOppcontact.get(opportunityId) != null){
            for(Id contatId :  mapOfOppcontact.get(opportunityId)){
                if(mapOfContacts.containsKey(contatId)){
                    contactObj =(Contact)mapOfContacts.get(contatId);
                    contactObj.Cadence_Id__c = null;
                    contactObj.isActivated__c = false;
					contactObj.EntranceCriteria_Matched_Date__c = null;
                    contactObj.Opportunity_Id__c = null;
                    contactList.add(contactObj);
                }
                
            }
        }
        return contactList;
    }
    public static String GetOpportunityIdByContactId(map<string,List<String>> mapOfOpportunityContactIds,string contactId){
        String Id = '';
        if(mapOfOpportunityContactIds != null){
            for(String oppids : mapOfOpportunityContactIds.keyset()){
                if(mapOfOpportunityContactIds.get(oppids) != null){
                    if(mapOfOpportunityContactIds.get(oppids).contains(contactId)){
                        return oppids;
                    }
                }
            }
        }
        return Id;
    }
    
    @future(callout=true)
    public static void sendNativeEmailTroughTrigger(String serializeNativeEmailMessageList)
    {   
        RingDNAApiCallouts ringDNAApiCallout = new RingDNAApiCallouts(true);
        Map<String, Object> responseMap = new Map<String, Object>();
        List<Messaging.MassEmailMessage> sfdcEmailMessageList = New List<Messaging.MassEmailMessage>();        
        List<NativeEmailMessage> nativeEmailMessageList = (List<NativeEmailMessage>) JSON.deserialize(serializeNativeEmailMessageList, List<NativeEmailMessage>.class);
        List<NativeEmailRespose> nativeEmailResposeList = new List<NativeEmailRespose>();
        try{
            nativeEmailResposeList = ringDNAApiCallout.sendNativeMassEmail(nativeEmailMessageList);    
        }catch(exception ex){
            for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
                sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));
            }
        }
        // Create map of actionId and nativeEmailMessage
        Map<Id, NativeEmailMessage> actionIdNativeEmailMessageMap = new Map<Id, NativeEmailMessage>();
        for(NativeEmailMessage nativeEmailMessage : nativeEmailMessageList ){
            actionIdNativeEmailMessageMap.put(NativeEmailMessage.ActionId, NativeEmailMessage);
        }
        if (nativeEmailResposeList != null && nativeEmailResposeList.size() > 0 ) {
            for (NativeEmailRespose nativeEmailRespose : nativeEmailResposeList){
                if (nativeEmailRespose.success == false){
                    NativeEmailMessage nativeEmailMessage = actionIdNativeEmailMessageMap.get(nativeEmailRespose.actionId);
                    sfdcEmailMessageList.add(createEmailMessage(nativeEmailMessage.ParticipantId, nativeEmailMessage.TemplateId));                    
                }
            }
        }
        if(sfdcEmailMessageList.isEmpty() == false) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(sfdcEmailMessageList, false);
        }                                        
    }
    
    public static void createandUpdateActionOnPart(List<Sequence_Action__c> listOfSeqActionToUpdate){
       if(listOfSeqActionToUpdate != null && listOfSeqActionToUpdate.size() > 0){
            Database.UpsertResult[] results = Database.upsert(listOfSeqActionToUpdate);
        }
    }
    public static Object GetUpdateValue(Object value, String fieldType,Object multipicklistvalues){
        if(fieldType == CadenceConstants.MultiPickList){
            return (Object)((string)multipicklistvalues + (string)value + ';');
        }else{
            return value;
        }
    } 																								   
}