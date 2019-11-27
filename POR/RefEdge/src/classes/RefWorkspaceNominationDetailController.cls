/**
* ReferenceEdge
*
* Point of Reference, Inc. - Copyright 2014 All rights reserved.
*
* @company : Point of Reference, Inc.
* @website : www.point-of-reference.com
*
* Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"),
* WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT.
* POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
* MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR,
* AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF
* ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING,
* WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS
* WRITTEN CONSENT FROM COMPANY.
*/
/**
* VF Page: RefWorkspaceNominationDetail.page
* Description: 
* Created By: Dixita(Jan, 2018)
*/
public with sharing class RefWorkspaceNominationDetailController extends RefEdgeEditionFeatures {

    /**
     * Properties and variables
     */
    public String dateFormat { get; set; }
    public String todayDate { get; set; }
    public String selectedTheme {
        get { 
            if (isSLDS) {
                selectedTheme = 'LightningCSS_2_3';       
            } else {
                selectedTheme = 'LightningCSS';   
            }
            return selectedTheme;
        }
        set {}
    }

    public static Boolean isSLDS {
        get {
            Boolean URLIsSLDS = apexpages.currentpage() != null && apexpages.currentpage().getparameters().containsKey('isSLDS') ? apexpages.currentpage().getparameters().get('isSLDS') == 'true' : false;
            
            if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
                isSLDS = true;      
            } else {
                isSLDS = URLIsSLDS;   
            }
            return isSLDS;
        }
        set {}
    }

    public String followUp {
        get {
            if (isSLDS) {
                followUp = 'assets/styles/custom-slds.css';       
            } else {
                followUp = 'assets/styles/salesforce-lightning-design-system-vf.css';    
            }
            return followUp;
        }
        set {}
    }
     /**
     * Constructor
     */
    public RefWorkspaceNominationDetailController(ApexPages.StandardController stdController) { 
        dateFormat = ConstantsController.localeDateFormatMap.containsKey(UserInfo.getLocale())
                    ? ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0) : 'yyyy-MM-dd';
        todayDate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
    }
    
    /**
     * RemoteAction to get all Filters
     */
    @RemoteAction
    public static List<FilterWrapper> getFilters() {
        List<FilterWrapper> filters = new List<FilterWrapper>();
        
        for (Label__c label : [SELECT Id, Name, Visible__c, Required__c, Ref_Limit_to_Acct_or_Cntct__c, 
                            (SELECT Id FROM Attributes_Labels__r) FROM Label__c 
                            WHERE Visible__c = true order by Nomination_Filter_Order__c]) {
            
            if (label.Attributes_Labels__r.size() > 0) {
                filters.add(new FilterWrapper(label.Id, label.Name, label.Required__c, label.Ref_Limit_to_Acct_or_Cntct__c));
            }
        }
        return filters;
    }

    /**
     * RemoteAction to get all Filters
     */
    @RemoteAction
    public static String deleteNominationRecord(String nominationId) {
        List<Nomination__c> nominationList = [SELECT Id from Nomination__c WHERE Id =:nominationId];
        String returnValue = '';

        if (nominationList.size() > 0) {
            Database.DeleteResult result = Database.delete(nominationList.get(0), true);
            returnValue = JSON.serialize(result);
        } else {
            returnValue = null;
        }
        return returnValue;
    }

    /**
     * method to create Reference Note on nomination
     * author: Dixita (1 Mar, 2018)
     */
    @RemoteAction
    public static String createNote(String noteMapJson) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Map<String, String> noteMap = (Map<String, String>)JSON.deserialize(noteMapJson, Map<String, String>.class);
            Reference_Note__c refNote = new Reference_Note__c();

            if (noteMap.containsKey('refNoteId') && noteMap.get('refNoteId') != '') {
                refNote.Id = noteMap.get('refNoteId');
            }
            refNote.Note_Date__c = Date.valueOf(noteMap.get('noteDate'));
            refNote.Note__c = noteMap.get('noteValue');
            refNote.Nomination__c = noteMap.get('nomId');
            WithoutSharingHelperController.upsertNotes(new List<Reference_Note__c> { refNote });
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }

    /**
     * method to delete Reference Note records
     * author: Dixita #REF-2201
     */
    @RemoteAction
    public static String deleteRefNote(String noteId) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        
        try {
            Reference_Note__c refNoteToDelete = new Reference_Note__c(Id = noteId);
            WithoutSharingHelperController.deleteRefNotesForUpdateRBI(new List<Reference_Note__c> { refNoteToDelete });
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }
    /**
     * method to get Reference Note records
     * author: Dixita #REF-2201
     */
    @RemoteAction
    public static String getRelatedNotes(String nominationId) {
        List<RefNoteWrapper> refNotes = new List<RefNoteWrapper>();

        for (Reference_Note__c note : [SELECT Id, Note__c, CreatedBy.Name, Note_Date__c, LastModifiedDate,
                                        CreatedDate, LastModifiedById, LastModifiedBy.Name, Nomination__c
                                        FROM Reference_Note__c
                                        WHERE Nomination__c =:nominationId]) {
            refNotes.add(new RefNoteWrapper(note));
        }
        return JSON.serialize(refNotes);
    }
    /**
     * RemoteAction to get all Referenceabilities
     */
    @RemoteAction
    public static List<RefTypeWrapper> getRef() {
        List<RefTypeWrapper> refTypes = new List<RefTypeWrapper>();
       
        List<Referenceability_Type__c> refTypeList = [SELECT Id, Name, Visible__c, Ref_Limit_to_Acct_or_Cntct__c 
															FROM Referenceability_Type__c WHERE Visible__c = true 
															AND Sales_Reward__c = false AND Id IN (SELECT Referenceability_Type__c 
															FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION_REFERENCEABILITY AND Visible__c = true) 
															ORDER BY Name LIMIT :limits.getLimitQueryRows()];
			
        for (Referenceability_Type__c ref : refTypeList) {
            refTypes.add(new RefTypeWrapper(ref.Id, ref.Name, ref.Ref_Limit_to_Acct_or_Cntct__c));
        }
        return refTypes;
    }

    /**
     * RemoteAction to get all attributes to related Filters
     */
    @RemoteAction
    public static Map<String, List<RefTypeWrapper>> getAllFilterAttributes(String filterIdsJson) {
        Set<String> filterIds = (Set<String>) JSON.deserialize(filterIdsJson, Set<String>.class);
        Map<String, List<RefTypeWrapper>> lstAttributeWrapper = new Map<String, List<RefTypeWrapper>>();
        
        Map<Id, String> attribParentMap = new Map<Id, String>();
        Set<String> parentAttIds = new Set<String>();
        
        List<Attributes_Labels__c> attLables = [SELECT Name, Label__c, Id, Attribute__c, Attribute__r.Name,
    									Attribute__r.ParentIds__c FROM Attributes_Labels__c
    									WHERE Label__c IN :filterIds
    									AND Attribute__c != null
    									ORDER BY Attribute__r.Name
    									LIMIT :limits.getLimitQueryRows()];
        
        for (Attributes_Labels__c al : attLables) {
        	
        	if (al.Attribute__r.ParentIds__c != null) {
                parentAttIds.addAll(al.Attribute__r.ParentIds__c.split(','));
                attribParentMap.put(al.Attribute__c, al.Attribute__r.ParentIds__c);
            }
        }
        
        for (Attribute__c att : [SELECT Id, Ref_Limit_to_Acct_or_Cntct__c, Level__c FROM Attribute__c WHERE Id IN :parentAttIds AND Level__c = 0]) {
        	
        	for (Id attId : attribParentMap.keySet()) {
        		
        		if (attribParentMap.get(attId) != null && attribParentMap.get(attId).contains(att.Id)) {
        			attribParentMap.put(attId, att.Ref_Limit_to_Acct_or_Cntct__c);
        		}
        	}
        }
        
        for (Attributes_Labels__c al : attLables) {
        	
        	if (!lstAttributeWrapper.containsKey(al.Label__c)) {
        		lstAttributeWrapper.put(al.Label__c, new List<RefTypeWrapper>());
        	}
        	lstAttributeWrapper.get(al.Label__c).add(new RefTypeWrapper(al.Attribute__r.Id, al.Attribute__r.Name, attribParentMap.get(al.Attribute__c)));
        }
        return lstAttributeWrapper;
    }

    /**
     * Method to get Nomination Object Details
     */
    @RemoteAction
    public static String getDefaults(String nomId) {
        List<Object> returnList = new List<Object>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        String namespace = UtilityController.appNamespace();
        List<Nomination_Label__c> nominationLabelList = new List<Nomination_Label__c>();
        Map<Id, List<NominationFilterAttributeWrapper>> filterAttributes = new Map<Id, List<NominationFilterAttributeWrapper>>();
        List<Nomination_Referenceability__c> nomRef = new List<Nomination_Referenceability__c>();
        List<Reference_Note__c> nomNotes = new List<Reference_Note__c>();
        List<Map<String, Object>> fieldList = new List<Map<String, Object>>();
        Map<String,List<MultiPicklistWrapper>> mapNameSelectedMultiPickOptions = new Map<String,List<MultiPicklistWrapper>>(); 
        Map<String,List<MultiPicklistWrapper>> mapNameAvailMultiPickOptions = new Map<String,List<MultiPicklistWrapper>>();
        List<Schema.PicklistEntry> picklistEntry ;
        Boolean isForAccount = false;
        Boolean isReferenceable = false;
        String accId = '';
        Set<String> fieldSet = new Set<String>{'account__c','contact__c','disposition__c','email_enabled__c',
                                               'get_current_instance__c','new_nomination_URL__c','referenceability__c',
                                               'note__c','status__c','test_area_field__c',
                                               'influitive_id__c','sample_field_01_del__c'};
       
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Nomination__c'); //From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> fldObjMap = sobject_describe.fields.getMap();
        Map<String,Boolean> fieldsFormList = new Map<String,Boolean>();
        
        for (Data_Mapping__c field : [SELECT Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION AND Visible__c = true  ORDER BY Order__c]) {
            fieldsFormList.put(field.Field_API_Name__c, field.Required__c);
        }
        String query = 'SELECT Id, Name, Account__c, Other_Info__c, Influitive_Id__c, Contact__c, Email_Enabled__c, Manager__r.Name, Contact__r.Name, Referenceability__c, CreatedDate, Account__r.Name, Disposition__c, CreatedById, Note__c, Status__c, OwnerId, Owner.Name';
        
        for (String field : fldObjMap.keyset()) {
            
            if (!query.containsIgnoreCase(' ' + field.remove(namespace))) { 
                query += ', '  + fldObjMap.get(field).getDescribe().getName().remove(namespace);
            }
            
            if (!fieldSet.contains(field.remove(namespace)) && fldObjMap.get(field).getDescribe().isCustom()
                        && fldObjMap.get(field).getDescribe().isUpdateable()) {

                Map<String, Object> fieldMap = new Map<String, Object>();
                fieldMap.put('Name',fldObjMap.get(field).getDescribe().getName());
                fieldMap.put('Label',fldObjMap.get(field).getDescribe().getLabel());
                fieldMap.put('Type',fldObjMap.get(field).getDescribe().getType());
                fieldMap.put('inlineHelpText',fldObjMap.get(field).getDescribe().getInlineHelpText());
                fieldMap.put('required',(!fldObjMap.get(field).getDescribe().isNillable() && !fldObjMap.get(field).getDescribe().isDefaultedOnCreate()));

                if (String.valueOf(fldObjMap.get(field).getDescribe().getType()).equalsIgnoreCase('Picklist') ||
                    String.valueOf(fldObjMap.get(field).getDescribe().getType()).equalsIgnoreCase('MultiPicklist')) {
                        picklistEntry = fldObjMap.get(field).getDescribe().getPicklistValues();
                        Map<String, String> pickListValues = new Map<String, String>();
                        List<MultiPicklistWrapper> multiPickAvailOptions = new List<MultiPicklistWrapper>();

                        if (String.valueOf(fldObjMap.get(field).getDescribe().getType()).equalsIgnoreCase('MultiPicklist')) {
                            
                            for (Schema.PicklistEntry value : picklistEntry) {
                                multiPickAvailOptions.add(new MultiPicklistWrapper(String.valueOf(value.getLabel()), String.valueOf(value.getValue())));
                            } 
                            mapNameAvailMultiPickOptions.put(fldObjMap.get(field).getDescribe().getName(), multiPickAvailOptions);
                        } else {
                             
                            for (Schema.PicklistEntry value : picklistEntry) {
                                pickListValues.put(value.getLabel(), value.getValue());
                            } 
                            fieldMap.put('Values',pickListValues); 
                        }
                }
                if (fieldsFormList.containsKey(fldObjMap.get(field).getDescribe().getName())) {
                    fieldMap.put('required',String.valueOF(fieldsFormList.get(fldObjMap.get(field).getDescribe().getName()) || (Boolean)fieldMap.get('required')));
                    fieldList.add(fieldMap);
                }
            }
        }

        picklistEntry = fldObjMap.get(namespace + 'Status__c').getDescribe().getPicklistValues();
        List<OptionWrapper> statusPickListValues = new List<OptionWrapper>();

        for (Schema.PicklistEntry value : picklistEntry) {
            statusPickListValues.add(new OptionWrapper (value.getLabel(), value.getValue()));
        }

        picklistEntry = fldObjMap.get(namespace + 'Disposition__c').getDescribe().getPicklistValues();
        List<OptionWrapper> dispositionPickListValues = new List<OptionWrapper>();
        dispositionPickListValues.add(new OptionWrapper('', '--None--'));
        
        for (Schema.PicklistEntry value : picklistEntry) {
            dispositionPickListValues.add(new OptionWrapper ( value.getLabel(), value.getValue()));
        } 
        Map<String,Object> nominationMap = new Map<String,Object>();
        query += ' FROM Nomination__c WHERE Id = \'' + nomId + '\' LIMIT 1';
        List<Nomination__c> nominationObjList = Database.query(query);
        
        if (nominationObjList.size() > 0) {
            Nomination__c nomination = nominationObjList[0];
            
            for (String field : fldObjMap.keyset()) {
                
                if (String.valueOf(fldObjMap.get(field).getDescribe().getType()).equalsIgnoreCase('MULTIPICKLIST')) {
                    List<MultiPicklistWrapper> multiPickOptions = new List<MultiPicklistWrapper>();
                    
                    if (!String.isEmpty(String.valueOf(nomination.get(field)))) {
                        String multiPickValue = String.valueOf(nomination.get(field));
                        for (String selValue : multiPickValue.split(';')) {
                            multiPickOptions.add(new MultiPicklistWrapper(selValue, selValue));
                        }
                        mapNameSelectedMultiPickOptions.put(fldObjMap.get(field).getDescribe().getName(), multiPickOptions);
                        nominationMap.put(fldObjMap.get(field).getDescribe().getName(), multiPickValue);
                    } else {
                        mapNameSelectedMultiPickOptions.put(fldObjMap.get(field).getDescribe().getName(), multiPickOptions);
                        nominationMap.put(fldObjMap.get(field).getDescribe().getName(), '');
                    }
                } else {
                    nominationMap.put(fldObjMap.get(field).getDescribe().getName(), nomination.get(field));
                }
            }
            nominationMap.put('Account__r.Name', nomination.Account__r.Name);
            accId = nomination.Account__c;
            nominationMap.put('Contact__r.Name', nomination.Contact__r.Name);
            nominationMap.put('Manager__r.Name', nomination.Manager__r.Name);
            nominationMap.put('Owner.Name', nomination.Owner.Name);
            
            isForAccount = (nomination.Contact__c == null || String.valueOf(nomination.Contact__c) == '') ? true : false;
            
            if (isForAccount) {
                query = 'SELECT Id, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Account__c = \'' + nomination.Account__c + '\' AND Contact__c = null';
            } else {
                query = 'SELECT Id, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c = \'' + nomination.Contact__c + '\'';
            }
            List<Reference_Basic_Information__c> nomRBI = new List<Reference_Basic_Information__c>();
            nomRBI = WithoutSharingHelperController.getRBI(query);
            isReferenceable = (nomRBI.size() == 0) ? false : nomRBI[0].Is_Referenceable__c;
            nominationLabelList = [SELECT Id, Name, Label__c, Label__r.Name, Label__r.Required__c FROM Nomination_Label__c WHERE Nomination__c = :nomId];
            filterAttributes = new Map<Id, List<NominationFilterAttributeWrapper>>();
            Set<String> labelIds = new Set<String>();
            
            for (Nomination_Label__c nomi : nominationLabelList) {
                filterAttributes.put(nomi.Label__c, new List<NominationFilterAttributeWrapper>());
                labelIds.add(nomi.Id);
            }
        
            for (Nomination_Label_Attribute__c NLA : [SELECT Id, Attribute__c, Attribute__r.Name, Nomination_Label__c ,Nomination_Label__r.Label__c
                                    FROM Nomination_Label_Attribute__c WHERE Nomination_Label__c IN :labelIds]) {
                
                if (filterAttributes.containsKey(NLA.Nomination_Label__r.Label__c)) {
                    filterAttributes.get(NLA.Nomination_Label__r.Label__c).add(new NominationFilterAttributeWrapper(NLA.Attribute__c,NLA.Attribute__r.Name,NLA.Id,NLA.Nomination_Label__c));
                }
            }
            nomRef = [SELECT Id, Name, Referenceability_Type__c, Referenceability_Type__r.Name FROM Nomination_Referenceability__c WHERE Nomination__c = :nomId];
        }
        returnList.add(JSON.serialize(cs));
        returnList.add(JSON.serialize(namespace));
        returnList.add(JSON.serialize(fieldList));
        returnList.add(JSON.serialize(isReferenceable));
        returnList.add(JSON.serialize(nominationMap));
        returnList.add(JSON.serialize(nominationLabelList));
        returnList.add(JSON.serialize(filterAttributes));
        returnList.add(JSON.serialize(nomRef));
        returnList.add(JSON.serialize(dispositionPickListValues));
        returnList.add(JSON.serialize(statusPickListValues));
        returnList.add(JSON.serialize(fetchContacts(accId,cs)));
        returnList.add(JSON.serialize(mapNameAvailMultiPickOptions));
        returnList.add(JSON.serialize(mapNameSelectedMultiPickOptions));
        return JSON.serialize(returnList);
    }

    /**
     * Method to get all informations of available contacts
     * Created By: Rekha Jangir @Dec/28/2016
     * Ticket #658
     */
    private static List<OptionWrapper> fetchContacts(String accId, Custom_Settings__c cs) {
    	Set<Id> contactIdsForAttMapping = new Set<Id>();
    	Map<String, Schema.SObjectField> fldObjConMap = schema.SObjectType.Contact.fields.getMap();
        List<Schema.SObjectField> fldObjConMapValues = fldObjConMap.values();
        List<OptionWrapper> contactList = new List<OptionWrapper>();
        if (accId != null && accId != '') {
            contactIdsForAttMapping = WithoutSharingHelperController.getAccountContactsForNomination(accId, cs);
                
            //make dynamic query for account to get values of mapped attribute
            String theQuery = 'SELECT Id, Name, Title, Email, Phone, AccountId';
            
            for (Schema.SObjectField s : fldObjConMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getName() != 'OtherGeocodeAccuracy' 
                        && fieldDesc.getName() != 'MailingGeocodeAccuracy' && 
                        (fieldDesc.getType() == Schema.DisplayType.PICKLIST || 
                        fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQuery += ', ' + theName;
                }
            }
            //re #992
            theQuery += ', ( SELECT Id, Account__c, Contact__c, Name, Is_Referenceable__c, Referenceability_Status__c,'
                        +'RUL_Last_Activity_Date__c ,Reference_Program_Candidate__c, Roll_up_Referenceability_to_All_Accounts__c,'
                        +'Roll_up_Referenceability_to_Primary_Acc__c FROM Reference_Basic_Informations__r) FROM Contact WHERE ';
            theQuery += ' AccountId = \'' + accId + '\' OR Id IN :contactIdsForAttMapping ORDER BY LastName LIMIT 1001';
            List<Contact> contacts = WithoutSharingHelperController.getContactsUsingDynamicSOQL(theQuery, contactIdsForAttMapping);
            
            // changes for #1138 - Gaurav Saini (17 Nov, 2017)
            if (contactList.size() == 0) {
                contactList.add(new OptionWrapper('', '--None--'));
            }
            Integer size = 1;
            
            for (Contact con : contacts) {
                
                if (size < 1000) {
                    contactList.add(new OptionWrapper(con.Id, con.Name));
                } else {
                    break;
                }
                size++;
            }
        }
        return contactList;
    }

    /**
     * Method to get Nomination Object Details
     */
    @RemoteAction
    public static String updateNomination(String nominationString) {
        String namespace = UtilityController.appNamespace();
        Set<String> fieldSet = new Set<String>{'account__c', 'contact__c', 'disposition__c', 'email_enabled__c',
                                                'get_current_instance__c', 'new_nomination_URL__c', 'referenceability__c',
                                                'note__c', 'status__c', 'test_area_field__c',
                                                'influitive_id__c', 'sample_field_01_del__c'};
        String returnValue = '';
        try {
            Map<String, String> nominationMap = (Map<String, String>)JSON.deserialize(nominationString, Map<String, String>.class);
            String query = 'SELECT Id, Disposition__c, Note__c, Status__c, Other_Info__c, Manager__c';
            Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Nomination__c'); //From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> fldObjMap = sobject_describe.fields.getMap();
            List<String> fieldsToUpdate = new List<String>();
                    

            for (String field : fldObjMap.keyset()) {
                
                if (!query.containsIgnoreCase(' ' + field.remove(namespace))) {
                    query += ', '  + fldObjMap.get(field).getDescribe().getName();
                }
            }
            query += ' FROM Nomination__c WHERE Id = \'' + String.valueOf(nominationMap.get('Id')) + '\' LIMIT 1';
            List<Nomination__c> nominationObjList = Database.query(query);
            Nomination__c nomination = nominationObjList[0];
            nomination.Contact__c = nominationMap.get(UtilityController.appNamespace() + 'Contact__c') == '' ? null : nominationMap.get(UtilityController.appNamespace() + 'Contact__c');
            nomination.Disposition__c = nominationMap.get(UtilityController.appNamespace() + 'Disposition__c');
            nomination.Status__c = nominationMap.get(UtilityController.appNamespace() + 'Status__c');
            nomination.Note__c = nominationMap.get(UtilityController.appNamespace() + 'Note__c');
            
            for (String field : fldObjMap.keyset()) {
                
                if (!fieldSet.contains(field.remove(namespace)) && fldObjMap.get(field).getDescribe().isCustom()
                            && fldObjMap.get(field).getDescribe().isUpdateable()) {
                    
                    if (String.valueOf(fldObjMap.get(field).getDescribe().getType()) == 'DATETIME') {
                        nomination.put(fldObjMap.get(field).getDescribe().getName() , (nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == null || nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == '') ? null : DateTime.valueOf(nominationMap.get(fldObjMap.get(field).getDescribe().getName())));
                    } else if (String.valueOf(fldObjMap.get(field).getDescribe().getType()) == 'DATE') {
                        nomination.put(fldObjMap.get(field).getDescribe().getName() , (nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == null || nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == '') ? null : Date.valueOf(nominationMap.get(fldObjMap.get(field).getDescribe().getName())));
                    } else if (String.valueOf(fldObjMap.get(field).getDescribe().getType()) == 'BOOLEAN') {
                        nomination.put(fldObjMap.get(field).getDescribe().getName() , (nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == null || nominationMap.get(fldObjMap.get(field).getDescribe().getName()) == '') ? false : Boolean.valueOf(nominationMap.get(fldObjMap.get(field).getDescribe().getName())));
                    } else {
                        nomination.put(fldObjMap.get(field).getDescribe().getName() , nominationMap.get(fldObjMap.get(field).getDescribe().getName()));
                    }
                }
            }

            if (nominationMap.get(UtilityController.appNamespace() + 'Manager__c') != null && nominationMap.get(UtilityController.appNamespace() + 'Manager__c') != '') {
                nomination.Manager__c = nominationMap.get(UtilityController.appNamespace() + 'Manager__c');
            } else if (nomination.Manager__c == null) {
                nomination.Manager__c = UserInfo.getuserid();
            } 
            nomination = WithoutSharingHelperController.upsertNomination(nomination); 
            returnValue = nomination.Id;
        } catch (Exception ex) {
            returnValue = 'false:' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(ex.getMessage());
        }
        return returnValue;
    }

    /**
     * Method to Save Nomination Attributes
     */
    @RemoteAction
    public static String saveAttributes(String nominationId, String manager, String isSLDSString, String attributesString, String filterString, String attributestoLabelString) {
        try {
            Map<String, List<RefTypeWrapper>> nominationMap = (Map<String, List<RefTypeWrapper>>)JSON.deserialize(attributesString, Map<String, List<RefTypeWrapper>>.class);
            Map<Id, List<NominationFilterAttributeWrapper>> attributestoLabel = (Map<Id, List<NominationFilterAttributeWrapper>>)JSON.deserialize(attributestoLabelString, Map<Id, List<NominationFilterAttributeWrapper>>.class);
            List<Nomination_Label__c> nomLabelsExisting = (List<Nomination_Label__c>)JSON.deserialize(filterString, List<Nomination_Label__c>.class);
            List<Nomination_Label__c> nomLabelsToInsert = new List<Nomination_Label__c>();
            List<Nomination_Label_Attribute__c> nomLabelAttToDelete = new List<Nomination_Label_Attribute__c>();
            List<String> nomLabelAttToDeleteIds = new List<String>();
            Set<Nomination_Label__c> nomLabelsToDelete = new Set<Nomination_Label__c>();
            Set<Nomination_Label_Attribute__c> nomLabelAttrsToInsert = new Set<Nomination_Label_Attribute__c>();
            Map<Id,List<Nomination_Label_Attribute__c>> nomLabelAttrsToInsertMapToLabelId = new Map<Id,List<Nomination_Label_Attribute__c>>();
            
            Map<Id,Nomination_Label__c> labelToNomLabelMap = new Map<Id,Nomination_Label__c>();
            
            for (Nomination_Label__c nomLabel : nomLabelsExisting) {
                labelToNomLabelMap.put(nomLabel.Label__c,nomLabel);
            }
            
            for (String labelId : nominationMap.keySet()) {
                List<Nomination_Label_Attribute__c> nomLabelAttrList =  new List<Nomination_Label_Attribute__c>();
                
                for(RefTypeWrapper attr : nominationMap.get(labelId)) {
                    Boolean attMatched = false;

                    if (attributestoLabel.containsKey(labelId)) {
                        
                        for (Integer index = 0 ; index < attributestoLabel.get(labelId).size() ; index++) {
                            if (attributestoLabel.get(labelId).get(index).attributeId == attr.id ) {
                                
                                if (!attr.isSelected) {
                                    nomLabelAttToDeleteIds.add(attributestoLabel.get(labelId).get(index).id);
                                    attributestoLabel.get(labelId).remove(index);
                                }
                                attMatched = true;
                                break ;
                            }
                        }
                        
                        if (!attMatched && attr.isSelected) {
                            Nomination_Label_Attribute__c newNomLabelAttr = new Nomination_Label_Attribute__c();
                            newNomLabelAttr.Attribute__c = attr.id;
                            newNomLabelAttr.Nomination_Label__c = labelToNomLabelMap.get(labelId).Id;
                            nomLabelAttrsToInsert.add(newNomLabelAttr);
                            //String attributeId, String attributeName, String id, String nominationLabelId
                            NominationFilterAttributeWrapper attrEntry = new NominationFilterAttributeWrapper(attr.id,attr.name,'',labelToNomLabelMap.get(labelId).Id);
                            attributestoLabel.get(labelId).add(attrEntry);
                        }

                    } else if (attr.isSelected) {
                        Boolean entryDue = false;
                        
                        for (Nomination_Label__c nom :nomLabelsToInsert) {
                            if (nom.Label__c == labelId) {
                                entryDue = true;
                            }
                        }
                        if (!entryDue) {
                            Nomination_Label__c newNomLabel = new Nomination_Label__c();
                            newNomLabel.Nomination__c = nominationId.trim();
                            newNomLabel.Label__c = labelId;
                            nomLabelsToInsert.add(newNomLabel);
                        }
                        Nomination_Label_Attribute__c newNomLabelAttr = new Nomination_Label_Attribute__c();
                        newNomLabelAttr.Attribute__c = attr.id;
                        nomLabelAttrList.add(newNomLabelAttr);
                    }
                }
                nomLabelAttrsToInsertMapToLabelId.put(labelId,nomLabelAttrList);
                
                if (attributestoLabel.containsKey(labelId) && attributestoLabel.get(labelId).size() == 0 ) {
                    nomLabelsToDelete.add(labelToNomLabelMap.get(labelId));
                }
            }
            
            if (nomLabelsToInsert.size() > 0) {
                insert nomLabelsToInsert;
            }

            
            for (Nomination_Label__c nomLabel : nomLabelsToInsert) {
                
                if (nomLabelAttrsToInsertMapToLabelId.containsKey(nomLabel.Label__c) && nomLabelAttrsToInsertMapToLabelId.get(nomLabel.Label__c).size() > 0) {
                    for (Nomination_Label_Attribute__c record : nomLabelAttrsToInsertMapToLabelId.get(nomLabel.Label__c)) {
                        record.Nomination_Label__c = nomLabel.Id;
                        nomLabelAttrsToInsert.add(record);
                    }
                }
            }
            if (nomLabelsToDelete.size() > 0) {
                delete new List<Nomination_Label__c> (nomLabelsToDelete);
            }

            if (nomLabelAttToDeleteIds.size() > 0) {
                delete [SELECT Id FROM Nomination_Label_Attribute__c WHERE Id IN:nomLabelAttToDeleteIds];
            }
            
            if (nomLabelAttrsToInsert.size() > 0) {
                insert new List<Nomination_Label_Attribute__c>(nomLabelAttrsToInsert);
            }
            
            if (isSLDSString == 'true' && (manager == null || manager == '')) {
                Nomination__c nomination = [SELECT Id, Manager__c from Nomination__c WHERE Id =:nominationId];
                nomination.Manager__c = UserInfo.getuserid();
                nomination = WithoutSharingHelperController.upsertNomination(nomination); 
            } 
            return nominationId;
        } catch(Exception ex) {
            return null;
        }
    }


    /**
     * Method to Save Nomination Referenceability
     */
    @RemoteAction
    public static String saveRef(String nominationId, String manager, String isSLDSString, String changedListString, String existingRefString) {
        try {
            List<RefTypeWrapper> changedList = (List<RefTypeWrapper>)JSON.deserialize(changedListString, List<RefTypeWrapper>.class);
            List<Nomination_Referenceability__c> existingRefs = (List<Nomination_Referenceability__c>)JSON.deserialize(existingRefString, List<Nomination_Referenceability__c>.class);
            Map<Id,Nomination_Referenceability__c> existingRefsMap = new Map<Id,Nomination_Referenceability__c>();
            List<Nomination_Referenceability__c> refToDelete = new  List<Nomination_Referenceability__c>();
            List<Nomination_Referenceability__c> refToInsert = new  List<Nomination_Referenceability__c>();
            
            for (Nomination_Referenceability__c temp : existingRefs) {
                existingRefsMap.put(temp.Referenceability_Type__c , temp);
            }

            for (RefTypeWrapper refWrapper : changedList) {
                
                if (existingRefsMap.containsKey(refWrapper.id)) {
                    if (!refWrapper.isSelected) {
                        refToDelete.add(existingRefsMap.get(refWrapper.id));
                    }
                } else if (refWrapper.isSelected) {
                    Nomination_Referenceability__c nomRef = new Nomination_Referenceability__c();
                    nomRef.Nomination__c = nominationId;
                    nomRef.Referenceability_Type__c = refWrapper.id;
                    refToInsert.add(nomRef);
                }
            }
            
            if (refToInsert.size() > 0) {
                insert refToInsert;
            }

            if (refToDelete.size() > 0) {
                delete refToDelete;
            }
            if (isSLDSString == 'true' && (manager == null || manager == '')) {
                Nomination__c nomination = [SELECT Id, Manager__c from Nomination__c WHERE Id =:nominationId];
                nomination.Manager__c = UserInfo.getuserid();
                nomination = WithoutSharingHelperController.upsertNomination(nomination); 
            } 
            return nominationId;
        } catch(Exception ex) {
            return null;
        }
    }

    /**
     * Method to get URL to redirect to Detail page of redirect Id
     */
    @RemoteAction
    public static String redirectToDetail(String redirectId) {
        PageReference nextPage = new PageReference('/' + redirectId + '?nooverride=1');
        return nextPage.getUrl();
    }

    /**
     * Method to check Permissions
     */
    @RemoteAction
    public static Boolean checkPermissions() {
		Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c', new Set<String> { 
											UtilityController.appNamespace() + 'Label__c',
											UtilityController.appNamespace() + 'From_Mapping__c',
											UtilityController.appNamespace() + 'Process__c',
											UtilityController.appNamespace() + 'User__c',
											UtilityController.appNamespace() + 'Field_API_Name__c',
											UtilityController.appNamespace() + 'Default_Value__c',
											UtilityController.appNamespace() + 'Order__c' });	
        fieldMap.put(UtilityController.appNamespace() + 'Nomination__c', new Set<String> { 
											UtilityController.appNamespace() + 'Disposition__c',
											UtilityController.appNamespace() + 'Status__c',
                                            UtilityController.appNamespace() + 'Other_Info__c',
                                            UtilityController.appNamespace() + 'Name',
											UtilityController.appNamespace() + 'Note__c'});																																			
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
    }

    public class RefNoteWrapper {
        public String refNoteId { get; set; }
        public String noteValue { get; set; }
        public String noteDate { get; set; }
        public String createdBy { get; set; }
        public String lastModDate { get; set; }
        public String createdDate { get; set; }
        public String lastModBy { get; set; }
        public String lastModById { get; set; }

        public RefNoteWrapper(Reference_Note__c note) {
            this.refNoteId = note.Id;
            this.noteValue = note.Note__c != null ? note.Note__c : '';
            this.noteDate = note.Note_Date__c != null ? note.Note_Date__c.format() : '';
            this.createdBy = note.CreatedBy.Name;
            this.lastModDate = note.LastModifiedDate != null ? note.LastModifiedDate.format() : '';
            this.createdDate = note.CreatedDate != null ? note.CreatedDate.format() : '';
            this.lastModBy = note.LastModifiedBy.Name;
            this.lastModById = String.valueOf(note.LastModifiedById);
        }
    }

    /**
     * Wrapper Class
     */
 	public class RefTypeWrapper {
 		public Boolean isSelected { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		public Boolean avaliableForAccount { get; set; }
		public Boolean avaliableForContact { get; set; }
		
 		public RefTypeWrapper(String refId, String refName, String option) {
 			isSelected = false;
 			name = refName;
 			id = refId;
 			this.avaliableForAccount = (option == null || option == '' || option == 'Account' ? true : false);
			this.avaliableForContact = (option == null || option == '' || option == 'Contact' ? true : false);
 		}
 	}

    /**
     * Wrapper Class
     */
 	public class FilterWrapper {
 		public Boolean required { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		public Boolean avaliableForAccount { get; set; }
		public Boolean avaliableForContact { get; set; }
		public Boolean isShow { get; set; }
 		
 		public FilterWrapper(String filterId, String filterName, Boolean required, String option) {
 			this.required = required;
 			isShow = false;
 			name = filterName;
 			id = filterId;
 			this.avaliableForAccount = (option == null || option == '' || option == 'Account' ? true : false);
			this.avaliableForContact = (option == null || option == '' || option == 'Contact' ? true : false);
 		}
 	}
    
    /**
     * Wrapper Class
     */
 	public class OptionWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		
 		public OptionWrapper(String id, String name) {
 			this.id = id;
 			this.name = name;
 		}
 	}
    
    /**
     * Wrapper Class
     */
 	public class NominationFilterAttributeWrapper {
 		public String attributeName { get; set; }
 		public String attributeId { get; set; }
 		public String id { get; set; }
        public String nominationLabelId { get; set; }
 		
 		public NominationFilterAttributeWrapper(String attributeId, String attributeName, String id, String nominationLabelId) {
 			this.attributeName = attributeName;
            this.attributeId = attributeId;
            this.id = id;
            this.nominationLabelId = nominationLabelId;
 		}
 	}

    // class to get multipicklist options
    public class MultiPicklistWrapper { 
        String value { get; set; }
        String name { get; set; }
        
        public MultiPicklistWrapper(String label,String value) { 
            this.name = label; 
            this.value = value;   
        }
    }
}