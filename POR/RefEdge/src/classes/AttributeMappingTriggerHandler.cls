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
public with sharing class AttributeMappingTriggerHandler {
    /**
     * Properties and variables
     */
    public static list < Attribute_Mapping__c > newAttMapping = new list < Attribute_Mapping__c > ();
    public static list < Attribute_Mapping__c > oldAttMapping = new list < Attribute_Mapping__c > ();
    public static map < Id, Attribute_Mapping__c > newAttMappingMap = new map < Id, Attribute_Mapping__c > ();
    public static map < Id, Attribute_Mapping__c > oldAttMappingMap = new map < Id, Attribute_Mapping__c > ();

    /**
     * Method called on before insert of Attribute Mapping
     */
    public static void onBeforeInsert() {
        List<Attribute_Mapping__c> attMappings = [SELECT Object__c, Child_RelationShipName__c, RelationShip_Name__c, Related_Object__c,
                                                    Mapping_Type__c, Field_Api_Name__c FROM Attribute_Mapping__c
                                                    WHERE Id NOT IN :newAttMapping];

        for (Attribute_Mapping__c attMapping: newAttMapping) {

            for (Attribute_Mapping__c existingAttMapping: attMappings) {

                if (existingAttMapping.Field_Api_Name__c != null
                        && existingAttMapping.Object__c == attMapping.Object__c
                        && existingAttMapping.Field_Api_Name__c == attMapping.Field_Api_Name__c
                        && existingAttMapping.RelationShip_Name__c == attMapping.RelationShip_Name__c
                        && existingAttMapping.Child_RelationShipName__c == attMapping.Child_RelationShipName__c
                        && existingAttMapping.Related_Object__c == attMapping.Related_Object__c
                        && existingAttMapping.Mapping_Type__c == attMapping.Mapping_Type__c) {
                    attMapping.addError(System.Label.DUPLICATE_FIELD_MAPPING_NOT_ALLOWED);
                }
            }
        }
    }

    /**
     * Method called on after insert of Attribute Mapping
     */
    public static void onAfterInsert() {
        list < Attribute__c > newAttributes = new list < Attribute__c > ();
        list < Attributes_Labels__c > attLabels = new list < Attributes_Labels__c > ();
        map < String, Attribute__c > attMapParentAtt = new map < String, Attribute__c > ();
        map < String, Label__c > attMapFilter = new map < String, Label__c > ();
        map < String, List < Schema.PicklistEntry >> attMappingPicklistMap = new map < String, List < Schema.PicklistEntry >> ();
        Map < String, Schema.SObjectField > accountField_map = schema.SObjectType.Account.fields.getMap(); //get a map of fields for the passed sobject
        Map < String, Schema.SObjectField > contactField_map = schema.SObjectType.Contact.fields.getMap();
        Map < String, Schema.SObjectField > oppField_map = schema.SObjectType.Opportunity.fields.getMap();
        Map < String, Schema.SObjectField > oppProductField_map = schema.SObjectType.OpportunityLineItem.fields.getMap();
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content__c'); //From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map < String, Schema.SObjectField > rfContentField_map = sobject_describe.fields.getMap();
        boolean accountPresent = false;
        boolean contactPresent = false;
        boolean refContentPresent = false;
        boolean oppProductPresent = false;
        string oppMappingId = '';
        string oppRelatedMappingId = '';
        Boolean isOppPicklistMapping = false;

        for (Attribute_Mapping__c attMapping: newAttMapping) {

            if (attMapping.Field_API_Name__c != null && attMapping.Field_API_Name__c != '') {
                List < Schema.PicklistEntry > pick_list_values = new List < Schema.PicklistEntry > ();

                if (attMapping.Related_Object__c == '' || attMapping.Related_Object__c == null) {
                    String ObjectApi_name = '';
                    set < Id > accIds = new set < Id > ();
                    if (attMapping.Object__c == ConstantsController.ACCOUNT) {
                        pick_list_values.addAll(accountField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues());
                        accountPresent = true;
                    }
                    if (attMapping.Object__c == ConstantsController.CONTACT) {
                        pick_list_values.addAll(contactField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues());
                        contactPresent = true;
                    }
                    if (attMapping.Object__c == ConstantsController.OPPORTUNITY && oppField_map.containsKey(attMapping.Field_Api_Name__c) && oppField_map.get(attMapping.Field_Api_Name__c) != null) {
                        //pick_list_values.addAll(oppField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues());
                        for(Schema.PicklistEntry sp : oppField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues()){
                            if((attMapping.Field_Api_Name__c == 'StageName' && sp.getValue() != 'Closed Won' && sp.getValue() != 'Closed Lost') || attMapping.Field_Api_Name__c != 'StageName'){
                                pick_list_values.add(sp);
                            }
                        }

                        if (attMapping.Field_Api_Name__c == 'StageName') {
                            oppMappingId = attMapping.Id;
                        } else {
                            isOppPicklistMapping = true;
                        }
                    }
                    if (attMapping.Object__c == ConstantsController.REFERENCE_CONTENT) {
                        pick_list_values.addAll(rfContentField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues());
                        refContentPresent = true;
                    }

                    attMappingPicklistMap.put(attMapping.Id, pick_list_values);
                    attMapParentAtt.put(attMapping.Id, new Attribute__c(name = attMapping.Attribute_Name__c, Attribute_Mapping__c = attMapping.Id,Inheritable__c = attMapping.Inheritable__c));
                    attMapFilter.put(attMapping.Id, new Label__c(name = attMapping.Filter_Label_Name__c));
                }
                if(attMapping.Related_Object__c == 'OpportunityLineItem' && attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Field_Api_Name__c == 'Product2'){
                    attMapParentAtt.put(attMapping.Id, new Attribute__c(name = attMapping.Attribute_Name__c, Attribute_Mapping__c = attMapping.Id));
                    attMapFilter.put(attMapping.Id, new Label__c(name = attMapping.Filter_Label_Name__c));
                    oppRelatedMappingId = attMapping.Id;
                }
                else if(attMapping.Related_Object__c == 'OpportunityLineItem' && attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Field_Api_Name__c != 'Product2'){
                    pick_list_values.addAll(oppProductField_map.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues());
                    attMappingPicklistMap.put(attMapping.Id, pick_list_values);
                    attMapParentAtt.put(attMapping.Id, new Attribute__c(name = attMapping.Attribute_Name__c, Attribute_Mapping__c = attMapping.Id));
                    attMapFilter.put(attMapping.Id, new Label__c(name = attMapping.Filter_Label_Name__c));
                    oppProductPresent = true;
                }
            } else {
                //REF-2556 : Inheritable update
                attMapParentAtt.put(attMapping.Id, new Attribute__c(Name = attMapping.Attribute_Name__c, Attribute_Mapping__c = attMapping.Id,Inheritable__c = attMapping.Inheritable__c));
                attMapFilter.put(attMapping.Id, new Label__c(Name = attMapping.Filter_Label_Name__c));
            }
        }
        if (attMapParentAtt.size() > 0) {
            insert attMapParentAtt.values();
            insert attMapFilter.values();
        }
        for (String attMapId: attMappingPicklistMap.keySet()) {
            for (Schema.PicklistEntry a: attMappingPicklistMap.get(attMapId)) { //for all values in the picklist list
                newAttributes.add(new Attribute__c(name = a.getValue(), Parent__c = attMapParentAtt.get(attMapId).Id));
            }
        }
        if (newAttributes.size() > 0)
            insert newAttributes;
        for (Attribute__c att: [select Parent__r.Attribute_Mapping__c, Id from Attribute__c where Id In: newAttributes]) {
            attLabels.add(new Attributes_Labels__c(Label__c = attMapFilter.get(att.Parent__r.Attribute_Mapping__c).Id, Attribute__c = att.Id));
        }
        if(oppRelatedMappingId != null && oppRelatedMappingId != ''){
        	//re #988
        	Attribute__c att = attMapParentAtt.get(oppRelatedMappingId);
        	att.Product_ID__c = attMapFilter.get(oppRelatedMappingId).Id;
        	update att;
        	//attLabels.add(new Attributes_Labels__c(Label__c = attMapFilter.get(oppRelatedMappingId).Id, Attribute__c = attMapParentAtt.get(oppRelatedMappingId).Id));
        }
        if (attLabels.size() > 0)
            insert attLabels;
		if(oppMappingId != null && oppMappingId != ''){
			Data_Mapping__c oppoDataMapping = new Data_Mapping__c(Label__c= attMapFilter.get(oppMappingId).Name, Field_API_Name__c = attMapFilter.get(oppMappingId).Id,Visible__c = true,Required__c= true, Object__c = 'SmartSearchFilter');
			ConstantsController.shouldDataMappingProcessed = true;
			insert oppoDataMapping;
		}
        if (accountPresent) {
            Batch_AddAttributesToAccount c = new Batch_AddAttributesToAccount();
            Database.executeBatch(c);
        }
        if (contactPresent) {
            Batch_AddAttributesToContact c = new Batch_AddAttributesToContact();
            Database.executeBatch(c);
        }
        if (refContentPresent) {
            Batch_AddAttributesToContent c = new Batch_AddAttributesToContent();
            Database.executeBatch(c);
        }
        if(oppProductPresent || isOppPicklistMapping){
        	Batch_AddOppAttributesToAccount c = new Batch_AddOppAttributesToAccount();
            Database.executeBatch(c);
        }
    }
    /**
     * Method called on after update of Attribute Mapping
     */
    public static void onAfterUpdate() {
        list<Attribute__c> attList = new list<Attribute__c>();
        set<Id> mappingIds = new set<Id>();
        for (Attribute_Mapping__c attMapping: newAttMapping) {
        	if(newAttMappingMap.get(attMapping.Id).Inheritable__c != oldAttMappingMap.get(attMapping.Id).Inheritable__c){
        		mappingIds.add(attMapping.Id);
        	}
        }
        for (Attribute__c att: [select Inheritable__c,Attribute_Mapping__c from Attribute__c where Attribute_Mapping__c IN : mappingIds]) {
        	att.Inheritable__c = newAttMappingMap.get(att.Attribute_Mapping__c).Inheritable__c;
        	attList.add(att);
        }
        update attList;
    }
    /**
     * Method called on before delete of Attribute Mapping
     */
    public static void onBeforeDelete() {
        for (Attribute__c att: [select Id from Attribute__c where Level__c = 0 and Attribute_Mapping__c In: oldAttMapping]) {
            ConstantsController.AttributedIds.add(att.Id);
        }
        map < Id, Data_Mapping__c > dataMappings = new map < Id, Data_Mapping__c > ([select Id, Field_API_Name__c from Data_Mapping__c where(Object__c = 'Filter'
            OR Object__c = 'SmartSearchFilter') and Field_API_Name__c IN: oldAttMappingMap.keySet()]);
        if (dataMappings.size() > 0)
            ConstantsController.labelIds = dataMappings.keySet();
    }
    
    /**
     * Method called on after delete of Attribute Mapping
     */
    public static void onAfterDelete() { 
        try {
            ConstantsController.attMappingForAccount = false;
            ConstantsController.attMappingForContact = false;
            ConstantsController.attMappingForRefContent = false;
            List<Attribute__c> attributesToBeDeleted = new List<Attribute__c>();
            List<Attribute__c> deleteParentAtt = new List<Attribute__c>();
            List<Account_Attribute__c> accAttsDelete = new List<Account_Attribute__c>();
            List<Contact_Attribute__c> conAttsDelete = new List<Contact_Attribute__c>();
            List<Content_Attribute__c> contAttsDelete = new List<Content_Attribute__c>();
            List<Label__c> labels = new List<Label__c>();
            Set<Id> labelIds = new Set<Id>();
            Set<String> attMappingIds = new Set<String>();

            for (Attribute_Mapping__c am : oldAttMapping) {
                attMappingIds.add(am.Id);

                List<User_Mapping__c> userMappingsToDelete = [SELECT Id FROM User_Mapping__c
                                                                WHERE Label__c IN :attMappingIds
                                                                AND Process__c = 'AttMappingFilters'];

                if (userMappingsToDelete != null && userMappingsToDelete.size() > 0) {
                    delete userMappingsToDelete;
                }
            }

            for (Attribute__c att: [select Id, (Select Id from Attributes__r) from Attribute__c where Id IN: ConstantsController.AttributedIds]) {
                for (Attribute__c childatt: att.Attributes__r) {
                    attributesToBeDeleted.add(childatt);
                }
                deleteParentAtt.add(att);
            }
            for (Attributes_Labels__c attLabel: [select Label__c from Attributes_Labels__c where Attribute__c In: attributesToBeDeleted]) {
                labelIds.add(attLabel.label__c);
            }
            for (Label__c label: [select Id from Label__c where Id In: labelIds]) {
                labels.add(label);
            }
            if (ConstantsController.labelIds != null && ConstantsController.labelIds.size() > 0) {
                list < Data_Mapping__c > deleteMappingList = [select Id from Data_Mapping__c where Id In: ConstantsController.labelIds];
                if (deleteMappingList != null && deleteMappingList.size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;
                     system.debug('=========================> deleteMappingList '+deleteMappingList);
                    delete deleteMappingList;
                    Database.emptyRecycleBin( deleteMappingList ); 
                     system.debug('=========================> emptyRecycleBin '+deleteMappingList);
                }
            }
            if (attributesToBeDeleted.size() > 0)
                delete attributesToBeDeleted;
            if (deleteParentAtt.size() > 0)
                delete deleteParentAtt;
            if (labels.size() > 0)
                delete labels;
        } catch (Exception e) {
            throw e;
        }
    }
}