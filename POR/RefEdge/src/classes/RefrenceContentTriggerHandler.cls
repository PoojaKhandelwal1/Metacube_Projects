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
public with sharing class RefrenceContentTriggerHandler {
    public static list < Reference_Content__c > newReferenceContents;
    public static list < Reference_Content__c > oldReferenceContents;
    public static map < Id, Reference_Content__c > newReferenceContentMap;
    public static map < Id, Reference_Content__c > oldReferenceContentMap;

    public static void onBeforeUpdate() {
        set<Id> internalUseRC = new set<Id>();
		/*
		* REF-1814 
		* Rajneesh (July 9, 2018)
		*/		
		Set<Id> refContTypeIdsSet = new Set<Id>();
		Set<Id> refContentIdsSet = new Set<Id>();
		List<Reference_Type_Mapping__c> refMap = new List<Reference_Type_Mapping__c>([SELECT Name FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__r.Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE]);
        
        for (Reference_Content__c tempObj: newReferenceContents) {
            
			if(tempObj.Internal_Use__c){
                internalUseRC.add(tempObj.Id);
            }
			
			//	REF-1814
			if(refMap.size() > 0 && tempObj.Data_Collector_Name__c != null && tempObj.Data_Collector_Name__c != '' && tempObj.Reference_Content_Type__c != oldReferenceContentMap.get(tempObj.Id).Reference_Content_Type__c) {
				refContTypeIdsSet.add(tempObj.Reference_Content_Type__c);
				refContentIdsSet.add(tempObj.Id);
			}			
        }
		
        if(internalUseRC.size() > 0) {
            for(Reference_Content__c tempObj: [select Id,(select Id from Related_Reference_Contents__r) from Reference_Content__c where ID IN : internalUseRC LIMIT: limits.getLimitQueryRows()]){
                for(Related_Reference_Content__c rrc : tempObj.Related_Reference_Contents__r){
                    newReferenceContentMap.get(tempObj.Id).addError(system.label.Cannot_check_internal_use_for_Content_Collection);
                    break;
                }
            }
        }
		
		if(refContTypeIdsSet.size() > 0 && refContentIdsSet.size() > 0) {
			// Map containing Reference Content Type as key and Reference Type Mapping Field set as value 
			Map<Id, Set<String>> refContentTypeMapping = new Map<Id, Set<String>>();
		
			for(Reference_Type_Mapping__c rtm : [SELECT Name, Reference_Content_Type__c FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__c =: refContTypeIdsSet]) {
				
				if(!refContentTypeMapping.containsKey(rtm.Reference_Content_Type__c))
					refContentTypeMapping.put(rtm.Reference_Content_Type__c, new Set<String>());
				refContentTypeMapping.get(rtm.Reference_Content_Type__c).add(rtm.Name);
			}
			
			if(refContentTypeMapping.size() > 0) {
				
				for(Id rcId : refContentIdsSet) {
					
					if(refContentTypeMapping.containsKey(newReferenceContentMap.get(rcId).Reference_Content_Type__c)) {
						
						for(Reference_Type_Mapping__c rtMapp : refMap) {
							
							if(!refContentTypeMapping.get(newReferenceContentMap.get(rcId).Reference_Content_Type__c).contains(rtMapp.Name)){
								newReferenceContentMap.get(rcId).addError(System.label.DC_Reference_Content_Type);
								break;
							}
						}
						
					}
				}
			}
		}
    }
    
    public static void onAfterInsert(){
        if(ConstantsController.attMappingForRefContent){
            //if(System.isBatch() || System.isFuture())
                checkForAttributeMapping();
            /*else{
                ConstantsController.attMappingForRefContent = false;
                checkForAttributeMappingFuture();
            }*/
        }
    }

    //On after Delete
    public static void onAfterDelete() {
        List < ContentDocument > contentDocuments = new List < ContentDocument > ();
        set < string > contentIds = new set < String > ();

        //Get Content Ids
        for (Reference_Content__c rc: oldReferenceContents) {
            contentIds.add(rc.Content_ID__c);
        }

        //Get ContentVersion & ContentDocument to be deleted
        for (ContentDocument conDoc: [select Id from ContentDocument where LatestPublishedVersionId IN: contentIds]) {
            contentDocuments.add(conDoc);
        }
        //If ContentDocument size greater than 'ZERO'
        if (contentDocuments.size() > 0)
            delete contentDocuments;
           
        if (!ConstantsController.isCallFromInfluitiveAPI) {
            
            ConstantsController.shouldAccountAttributeDeleteOfContent = true;
            
            
            list < Account_Attribute__c > accuntAttribDelete = new list < Account_Attribute__c > ([select Id from Account_Attribute__c where Id In: ConstantsController.AccountAttsDelete]);
            if (accuntAttribDelete.size() > 0){
                ConstantsController.deleteAttributeFromAccount = false;
                //delete accuntAttribDelete; 
                WithoutSharingHelperController.deleteAccountAttributes(accuntAttribDelete);
            }
            
        }
        
    }
    public static void onBeforeDelete(){
        ConstantsController.AccountAttsDelete = new list<Account_Attribute__c>();
        for(Account_Attribute__c accAtt: [select Id from Account_Attribute__c where Reference_Content__c In: oldReferenceContents]){
            ConstantsController.AccountAttsDelete.add(accAtt);

        }
    }
    public static void onAfterUpdate() {
        set < Id > deleteAttributeOfContent = new set < Id > ();
        set < Id > addAttributeOfContent = new set < Id > ();
        for (Reference_Content__c tempObj: newReferenceContents) {
            if ((oldReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.ACTIVE || oldReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.CAUTION) && (newReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.INACTIVE || newReferenceContentMap.get(tempObj.Id).Content_Status__c == null))
                deleteAttributeOfContent.add(tempObj.Id);
            if ((oldReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.INACTIVE || oldReferenceContentMap.get(tempObj.Id).Content_Status__c == null) && (newReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.ACTIVE || newReferenceContentMap.get(tempObj.Id).Content_Status__c == ConstantsController.CAUTION))
                addAttributeOfContent.add(tempObj.Id);
        }
        if (deleteAttributeOfContent.size() > 0)
            deleteAttributeFromAccount(deleteAttributeOfContent);
        if (addAttributeOfContent.size() > 0)
            addAttributeToAccount(addAttributeOfContent);
        if(ConstantsController.attMappingForRefContent){
            //if(System.isBatch() || System.isFuture())
                checkForAttributeMapping();
            /*else{
                ConstantsController.attMappingForRefContent = false;
                checkForAttributeMappingFuture();
            }*/
        }
    }
    @future
    private static void checkForAttributeMappingFuture(){
        checkForAttributeMapping();
    }
    private static void checkForAttributeMapping(){
        ConstantsController.attMappingForRefContent = false;
        Savepoint sp = database.setSavepoint();

        try{
            Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace()+'Reference_Content__c');//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> fldObjMap = sobject_describe.fields.getMap();
            list<Attribute_Mapping__c> attMappings = new list<Attribute_Mapping__c>();
            Set<String> apiNames = new Set<String>();
            for (String apiName : fldObjMap.keySet()) {
                apiNames.add(UtilityController.appNamespace() + apiName);
            }
            for(Attribute_Mapping__c attM : [select Field_Api_Name__c,Auto_populate__c,Auto_add__c,Auto_Update__c,Auto_delete__c 
                                            from Attribute_Mapping__c where object__c = :ConstantsController.REFERENCE_CONTENT 
                                            and Field_Api_Name__c != null and Auto_populate__c = true and Is_Related_Mapping__c = false LIMIT: limits.getLimitQueryRows()]){
                if(apiNames.contains(attM.Field_Api_Name__c.tolowerCase())){
                    attMappings.add(attM);
                }
            }
            
            map<String,list<Reference_Content__c>> attMappingRefContent = new map<String,list<Reference_Content__c>>();
            set<Id> mappingCreateAttribute = new set<Id>();
            map<String,set<String>> RefContentFieldAttDelete = new map<String,set<String>>();
            list<Content_Attribute__c > deleteRefContentAtt = new list<Content_Attribute__c >();
            list<Content_Attribute__c > createRefContentAtt = new list<Content_Attribute__c >();
            map<Id,map<Id,Content_Attribute__c>> contentAttributesAssociated = new map<Id,map<Id,Content_Attribute__c>>();
            set<Id> attMappingForUpdateAndDelete = new set<Id>();
            set<String> preventDuplicacy = new set<String>();
            //create a map of attributMapping and accounts in which the field value is not null
            if(attMappings.size()>0){
                for(Reference_Content__c acc : newReferenceContents){
                    for(Attribute_Mapping__c attMapping :  attMappings){
                        if(((oldReferenceContentMap != null && oldReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c)!=null &&  newReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c) == null) ||(newReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != null)) && attMapping.Auto_populate__c  ){
                            if(!attMappingRefContent.containsKey(attMapping.Id))
                                attMappingRefContent.put(attMapping.Id,new list<Reference_Content__c>());
                            attMappingRefContent.get(attMapping.Id).add(acc);
                        }
                        if(attMapping.Auto_add__c || attMapping.Auto_Update__c || attMapping.Auto_delete__c)
                            attMappingForUpdateAndDelete.add(attMapping.Id);

                    }
                    contentAttributesAssociated.put(acc.Id,new map<Id,Content_Attribute__c>());

                }
                UtilityController.checkAttributeMappingEdit(attMappingForUpdateAndDelete, UtilityController.appNamespace()+'Reference_Content__c');
                //if the trigger is an update trigger 
                if(oldReferenceContentMap != null){
                    for(Attribute_Mapping__c attMapping : attMappings){
                        if( attMappingRefContent.get(attMapping.Id) != null){
                            for(Reference_Content__c acc : attMappingRefContent.get(attMapping.Id)){
                                //if the value is changed then we have to delete the previous value attribute
                                if(oldReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c)!=null && oldReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c) != acc.get(attMapping.Field_Api_Name__c)){
                                    if(!RefContentFieldAttDelete.containsKey(acc.Id))       
                                        RefContentFieldAttDelete.put(acc.Id,new set<String>());
                                    //this map consists of the acocunt Id and value 
                                    for(String att : String.valueOf(oldReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c)).split(';')){
                                        boolean attributePresent = false;
                                        if(newReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c) !=null){
                                            for(string newAtt : string.valueOf(newReferenceContentMap.get(acc.Id).get(attMapping.Field_Api_Name__c)).split(';')){
                                                if(newAtt == att)
                                                    attributePresent = true;
                                            }
                                        }
                                        if(!attributePresent)
                                            RefContentFieldAttDelete.get(acc.Id).add(att);
                                    }
                                }
                            }
                        }
                    }
                    //delete the previous field value attributes
                        for(Content_Attribute__c accAtt : [select name,Id,attribute__r.Name,Reference_Content__r.Id,Attribute__r.Id,Is_fromMapping__c from Content_Attribute__c where Reference_Content__c  In :contentAttributesAssociated.keySet()  LIMIT: limits.getLimitQueryRows() ]){
                            if(RefContentFieldAttDelete.containsKey(accAtt.Reference_Content__r.Id) && accAtt.Is_fromMapping__c ){
                                if(RefContentFieldAttDelete.get(accAtt.Reference_Content__r.Id).contains(accAtt.attribute__r.Name))
                                    deleteRefContentAtt.add(accAtt);
                            }
                            //if(contentAttributesAssociated.containsKey(accAtt.Reference_Content__r.Id))
                                contentAttributesAssociated.get(accAtt.Reference_Content__r.Id).put(accAtt.Attribute__r.Id,accAtt);

                        }
                        if(deleteRefContentAtt.size()>0){
                            ConstantsController.attMappingForAccount = false;
                            ConstantsController.attMappingForContact = false;
                            ConstantsController.attMappingForRefContent = false;
                            //delete deleteRefContentAtt;
                            WithoutSharingHelperController.deleteContentAtt(deleteRefContentAtt);
                        }
                }
                
                //create new field value accountAttributes
                //query all the parent along with child attributes of the mapping
                for(Attribute__c att : [select Id,name,Attribute_Mapping__r.Id,Attribute_Mapping__r.Field_Api_Name__c,Attribute_Mapping__r.Auto_populate__c,(Select Id, Name From Attributes__r),Attribute_Mapping__r.Inheritable__c from Attribute__c where Attribute_Mapping__c In : attMappingRefContent.keySet() and level__c = 0 LIMIT: limits.getLimitQueryRows()]){
                    if(attMappingRefContent.get(att.Attribute_Mapping__r.Id)!= null && att.Attribute_Mapping__r.Auto_populate__c){
                        for(Reference_Content__c acc : attMappingRefContent.get(att.Attribute_Mapping__r.Id)){
                            for(Attribute__c childAtt : att.Attributes__r){
                                if(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c) != null){
                                    for(String attStr : string.valueOf(acc.get(att.Attribute_Mapping__r.Field_Api_Name__c)).split(';')){
                                        if(attStr == childAtt.Name && !preventDuplicacy.contains(acc.Id+''+childAtt.Id) &&  !contentAttributesAssociated.get(acc.Id).containsKey(childAtt.Id)){
                                            createRefContentAtt.add(new Content_Attribute__c(Reference_Content__c = acc.Id,Attribute__c = childAtt.Id,Is_fromMapping__c = true)); 
                                            preventDuplicacy.add(acc.Id+''+childAtt.Id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if(createRefContentAtt.size()>0){
                    ConstantsController.attMappingForAccount = false;
                    ConstantsController.attMappingForContact = false;
                    ConstantsController.attMappingForRefContent = false;
                    //insert createRefContentAtt;
                    WithoutSharingHelperController.upsertContentAtt(createRefContentAtt);
                }
            }
        }catch(Exception e){
            
            throw e;

        }
    }
       //this method would delete all the attributes when the picklist values are changed or updated
   
    //this method would delete attribute from all the contacts of the reference content
    static void deleteAttributeFromAccount(set < Id > deleteAttributeOfContent) {
        //map to store the attributes of the corresponding contents
        map < Id, set < Id >> contentAttributes = new map < Id, set < Id >> ();
        //map to store the accounts of the corresponding content
        map < Id, set < Id >> contentAccount = new map < Id, set < Id >> ();
        //map to store the attributes of the corresponding account
        map < Id, set < Id >> accountAttributes = new map < Id, set < Id >> ();
        set < Id > accountIds = new set < Id > ();
        //map to store the deleted attributes of the corresponding account
        map < Id, set < Id >> deleteAccountAttribute = new map < Id, set < Id >> ();
        map < string, set < Id >> contentAccountAttribMap = new map < String, set < Id >> ();
        //list to be deleted containing records of Account_Attribute__c
        list < Account_Attribute__c > deleteAccountAttrib = new list < Account_Attribute__c > ();
        //loop to create the contentAccount map
        for (Account_Reference_Content__c tempObj: [select Account__c, Reference_Content__c from Account_Reference_Content__c where Reference_Content__c In: deleteAttributeOfContent]) {
            accountIds.add(tempObj.Account__c);
        }
        //loop to create the accountAttributes map
        for (Account_Attribute__c tempObj: [select Account__c, Attribute__c, Reference_Content__c from Account_Attribute__c where Account__c In: accountIds and Reference_Content__c In: deleteAttributeOfContent]) {
            deleteAccountAttrib.add(tempObj);
        }
        if (deleteAccountAttrib.size() > 0) {
            ConstantsController.shouldAccountAttributeDeleteOfContent = true;
            //delete deleteAccountAttrib;
            WithoutSharingHelperController.deleteAccountAttributes(deleteAccountAttrib);
        }
    }

    static void addAttributeToAccount(set < Id > addAttributeOfContent) {
        map < Id, set < Id >> contentAttribMap = new map < Id, set < Id >> ();
        map < Id, set < Id >> contentAccountMap = new map < Id, set < Id >> ();
        map < Id, set < Id >> accountAttribMap = new map < Id, set < Id >> ();
        set < Id > accountIds = new set < Id > ();
        Account_Attribute__c accAttObj;
        list < Account_Attribute__c > newAccAtt = new list < Account_Attribute__c > ();
        for (Content_Attribute__c tempObj: [Select Reference_Content__c, Attribute__c From Content_Attribute__c where Reference_Content__c In: addAttributeOfContent and Account__c = null]) {
            if (!contentAttribMap.containsKey(tempObj.Reference_Content__c))
                contentAttribMap.put(tempObj.Reference_Content__c, new set < Id > ());
            contentAttribMap.get(tempObj.Reference_Content__c).add(tempObj.Attribute__c);
        }
        for (Account_Reference_Content__c tempObj: [select Account__c, Reference_Content__c from Account_Reference_Content__c where Reference_Content__c In: addAttributeOfContent]) {
            accountIds.add(tempObj.Account__c);
            if (!contentAccountMap.containsKey(tempObj.Reference_Content__c))
                contentAccountMap.put(tempObj.Reference_Content__c, new set < Id > ());
            contentAccountMap.get(tempObj.Reference_Content__c).add(tempObj.Account__c);
        }
        //loop to create the accountAttributes map
        for (Account_Attribute__c tempObj: [select Account__c, Attribute__c, Reference_Content__c from Account_Attribute__c where Account__c In: accountIds and Reference_Content__c In: contentAccountMap.keySet()]) {
            if (!accountAttribMap.containsKey(tempObj.Account__c))
                accountAttribMap.put(tempObj.Account__c, new set < Id > ());
            accountAttribMap.get(tempObj.Account__c).add(tempObj.Attribute__c);

        }
        for (Id contentId: contentAttribMap.keySet()) {
            if (contentAccountMap.get(contentId) != null) {
                for (Id accId: contentAccountMap.get(contentId)) {
                    if (contentAttribMap.get(contentId) != null) {
                        for (Id attId: contentAttribMap.get(contentId)) {
                            if (accountAttribMap.get(accId) != null) {
                                if (!accountAttribMap.get(accId).contains(attId)) {
                                    accAttObj = new Account_Attribute__c();
                                    accAttObj.Account__c = accId;
                                    accAttobj.Attribute__c = attId;
                                    accAttObj.Reference_Content__c = contentId;
                                    newAccAtt.add(accAttObj);
                                }
                            } else {
                                accAttObj = new Account_Attribute__c();
                                accAttObj.Account__c = accId;
                                accAttobj.Attribute__c = attId;
                                accAttObj.Reference_Content__c = contentId;
                                newAccAtt.add(accAttObj);
                            }
                        }
                    }
                }
            }
        }
        if (newAccAtt.size() > 0) {
            //insert newAccAtt;
            WithoutSharingHelperController.upsertAccountAttributes(newAccAtt);
            ConstantsController.addAttributesToContent = false;
        }
    } 
    
    public static void onBeforeInsert() {
        
        for (Reference_Content__c tempObj: newReferenceContents) {
            
            if(String.isBlank(tempObj.External_Source_Id__c)) {
                
                tempObj.addError('Please provide external_source_id');
            }
        }
    }
}