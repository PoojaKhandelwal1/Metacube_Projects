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
global with sharing class UtilityController {

    /**
     * method to post messages to slack user/channel
     * used for controllers only
     * author: Gaurav Saini (1 May, 2019 - REF-2006)
     */
    @future(callout=true)
    public static void postMsgToSlack(String reqBodyJson) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://rebot-app.herokuapp.com/post-message');
        req.setHeader('Content-type', 'application/json');
        req.setBody(reqBodyJson);
        Http http = new Http();

        if (!Test.isRunningTest()) {
            HTTPResponse response = http.send(req);
            system.debug('status code: ' + response.getStatusCode());
            system.debug('status: ' + response.getStatus());
            system.debug('body: ' + response.getBody());
        }
    }

    /**
     * method to post messages to slack user/channel
     * used for batches only
     * author: Gaurav Saini (1 May, 2019 - REF-2006)
     */
    public static void postMsgToSlackSync(String reqBodyJson) {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://rebot-app.herokuapp.com/post-message');
        req.setHeader('Content-type', 'application/json');
        req.setBody(reqBodyJson);
        Http http = new Http();

        if (!Test.isRunningTest()) {
            HTTPResponse response = http.send(req);
            system.debug('status code: ' + response.getStatusCode());
            system.debug('status: ' + response.getStatus());
            system.debug('body: ' + response.getBody());
        }
    }

    /**
     * method to create soql query's WHERE clause for list view filters functionality
     * author: Gaurav Saini (6 Mar, 2019)
     */
    public static String createDynamicQuery(List<User_Mapping__c> umList) {
        String whereClause = '';
        Map<String, String> operatorMap = new Map<String, String>();
		operatorMap.put('equals', ' @@@ = \'###\' ');
		operatorMap.put('not equal to', ' @@@ != \'###\' ');
		operatorMap.put('less than', ' @@@ < \'###\' ');
		operatorMap.put('greater than', ' @@@ > \'###\' ');
		operatorMap.put('less or equal', ' @@@ <= \'###\' ');
		operatorMap.put('greater or equal', ' @@@ >= \'###\' ');
		operatorMap.put('contains', ' @@@ LIKE \'%###%\' ');
		operatorMap.put('does not contain', ' (NOT @@@ LIKE \'%###%\') ');
		operatorMap.put('starts with', ' @@@ LIKE \'###%\' ');
		operatorMap.put('includes', ' @@@ INCLUDES (\'###\') ');
		operatorMap.put('excludes', ' @@@ EXCLUDES (\'###\') ');
        String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		dateFormat = dateFormat != null ? dateFormat : 'yyyy-MM-dd';
		List<String> dateFormatList = new List<String>();

		for (String str : dateFormat.split('[./-]')) {
			dateFormatList.add(str.substring(0, 1).toLowerCase());
		}

        for (User_Mapping__c um : umList) {

            if (um.Field_API_Name__c != null) {
                String fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
                String fieldApiName = um.Field_API_Name__c.split('::')[0];
                String fieldLabel = um.Field_API_Name__c.split('::')[1];
                String fieldType = um.Field_API_Name__c.split('::')[2];
                String operator = um.Field_API_Name__c.split('::')[3];

                if (fieldType == 'PICKLIST') {

                    if (fieldValue.trim() != '') {
                        String picklistClause = '';

                        for (String value : fieldValue.split(', ')) {
                            picklistClause = picklistClause == '' ? operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value) : picklistClause + (operator == 'not equal to' ? 'AND' : 'OR') + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value); 
                        }
                        whereClause = whereClause + ' AND (' + picklistClause + ') ';
                    } else {
                        whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
                    }
                } else if (fieldType == 'MULTIPICKLIST') {

                    if (fieldValue.trim() != '') {
                        String joinedValues = fieldValue.replaceAll(', ', '\',\'');
                        whereClause = operator == 'equals' ? (whereClause + ' AND ' + fieldApiName + ' IN (\'' + joinedValues + '\') ') : whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', joinedValues);
                    } else {
                        whereClause = operator == 'excludes' ? (whereClause + ' AND ' + fieldApiName + ' != null ') : (whereClause + ' AND ' + fieldApiName + ' = null ');
                    }
                } else if (fieldType == 'DATE') {

                    if (fieldValue != null && fieldValue.trim() != '') {
                        List<String> dateList = fieldValue.split('[./-]');
                        Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
                                                                    Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
                                                                    Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
                        whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd'));
                    } else {
                        whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null ');
                    }
                } else if (fieldType == 'DATETIME') {

                    if (fieldValue != null && fieldValue.trim() != '') {
                        List<String> dateList = fieldValue.split('[./-]');
                        Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
                                                                    Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
                                                                    Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
                        whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
                    } else {
                        whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null ');
                    }
                } else if (fieldType == 'BOOLEAN') {
                    whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'false ');
                } else if (fieldType == 'DOUBLE' || fieldType == 'INTEGER' || fieldType == 'CURRENCY') {
                    whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'null ');
                } else {
                    whereClause = whereClause + ' AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', fieldValue != null ? fieldValue : 'null ');
                }
            }
        }
        return whereClause;
    }

    // moved these methods from reference lead form controller to this class so that the
    // same method can be used for both classic and lightning versions of the page
    /**
     * Method to create Reference Profile 
     */
    @future
    public static void createRBI1(String accountId, String contactId, String rlfId, Set<String> conFiltersToExclude,
                                    Set<String> accFiltersToExclude, String accName, String conName) {
        List<Reference_Basic_Information__c> upsertNewRBI = new List<Reference_Basic_Information__c>();
        List<Reference_Note__c> noteList = new List<Reference_Note__c>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Reference_Lead__c referenceLead = [SELECT Id, Nomination__c, Other_Info__c, Notification_response__c,
                                            Response_Received__c, Reference_Lead_Status__c, Nominated__c,
                                            Reference_Profile__c, Reference_Lead_Opportunity__c, No_Response_Date__c,
                                            Reference_Lead_Opportunity__r.Owner.Name, Reference_Lead_Opportunity__r.Name,
                                            Reference_Lead_Owner__c, Follow_up_timeframe__c, Reference_Lead_Account__c,
                                            Reference_Lead_Account__r.Name, Contact__c
                                            FROM Reference_Lead__c WHERE Id = :rlfId];
        
        if (contactId == null || contactId == '') {
            Reference_Basic_Information__c rbi;
            List<Reference_Basic_Information__c> rbis = [SELECT Id, Referenceability_Status__c, Is_Referenceable__c,
                                                            Reference_Program_Candidate__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE Account__c = :accountId
                                                            AND Contact__c = null];
            
            if (rbis.size() == 0) {
                upsertNewRBI.add(new Reference_Basic_Information__c(Account__c = accountId != null ? accountId : null,
                                                    Referenceability_Status__c = cs.Default_Referenceablity_Status__c,
                                                    Is_Referenceable__c = true));
            } else {
                rbi = rbis[0];
                rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                rbi.Is_Referenceable__c = true;
                rbi.Reference_Program_Candidate__c = false;
                upsertNewRBI.add(rbi);
            }
            Reference_Note__c note = new Reference_Note__c();
            note.Account__c = accountId != null ? accountId : null;
            note.Note__c = referenceLead.Other_Info__c;
            noteList.add(note);
            upsertNewRBI = WithoutSharingHelperController.upsertRBI(upsertNewRBI);
            referenceLead.Reference_Profile__c = upsertNewRBI[0].Id;
            referenceLead.Reference_Program_Member__c = true;
            referenceLead = WithoutSharingHelperController.createRefLead(referenceLead);
            createChatterForRBI1(upsertNewRBI[0], new Reference_Basic_Information__c(), accName, '', cs);
            createAttributes1(upsertNewRBI[0], new Reference_Basic_Information__c(), accountId, contactId, rlfId, conFiltersToExclude, accFiltersToExclude);
            createReferenceability1(upsertNewRBI[0], new Reference_Basic_Information__c(), accountId, contactId, rlfId, cs);
            
            if (noteList.size() > 0) {
                WithoutSharingHelperController.upsertNotes(noteList);
            }
        } else {
            List<Reference_Basic_Information__c> rbis = [SELECT Id, Referenceability_Status__c, Reference_Program_Candidate__c,
                                                            Is_Referenceable__c, Contact__c, Roll_up_Referenceability_to_All_Accounts__c,
                                                            Roll_up_Referenceability_to_Primary_Acc__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE (Account__c = :accountId AND Contact__c = null)
                                                            OR (Contact__c = :contactId and Contact__c != null)];
            Reference_Basic_Information__c accRbi, conRbi;
            
            if (rbis.size() == 0) {
                conRbi = new Reference_Basic_Information__c(Contact__c = contactId != '' ? contactId : null, Account__c = accountId != '' ? accountId : null, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true);
                upsertNewRBI.add(conRbi);
                accRbi = new Reference_Basic_Information__c(Account__c = accountId != '' ? accountId : null, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true);
                upsertNewRBI.add(accRbi);
            } else { 
                
                for (Reference_Basic_Information__c rbi : rbis) {
                    
                    if (rbi.contact__c != null) {
                        conRbi = rbi;
                        conRbi.Reference_Program_Candidate__c = false;
                        conRbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        conRbi.Is_Referenceable__c = true;
                        upsertNewRBI.add(conRbi);
                    } else {
                        accRbi = rbi;
                        // commented for #1090 - Gaurav Saini (26 Oct, 2017)
                        /*
                        accRbi.Reference_Program_Candidate__c = false;
                        accRbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        accRbi.Is_Referenceable__c = true;
                        upsertNewRBI.add(accRbi);
                        */
                    }
                }
                
                if (accRbi == null) {
                    accRbi = new Reference_Basic_Information__c(Account__c = referenceLead.Reference_Lead_Account__c, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true);
                    upsertNewRBI.add(accRbi);
                }
                
                if (conRbi == null) {
                    conRbi = new Reference_Basic_Information__c(Contact__c = contactId, Account__c = referenceLead.Reference_Lead_Account__c, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true);
                    upsertNewRBI.add(conRbi);
                }
            }
            Reference_Note__c note = new Reference_Note__c();
            note.Contact__c = contactId;
            note.Note__c = referenceLead.Other_Info__c;
            noteList.add(note);
            upsertNewRBI = WithoutSharingHelperController.upsertRBI(upsertNewRBI);
            referenceLead.Reference_Profile__c = accRbi.Id;
            referenceLead.Reference_Program_Member__c = true;
            referenceLead.Reference_Lead_Status__c = 'Converted to Program Member';
            referenceLead = WithoutSharingHelperController.createRefLead(referenceLead);
            createChatterForRBI1(accRbi,conRbi,accName,conName, cs);
            createAttributes1(accRbi, conRbi, accountId, contactId, rlfId, conFiltersToExclude, accFiltersToExclude);
            createReferenceability1(accRbi, conRbi, accountId, contactId, rlfId, cs);
            
            if (noteList.size() > 0) {
                WithoutSharingHelperController.upsertNotes(noteList);
            }
        }
    }
    
    /**
     * Method to create Referenceability 
     */
    private static void createReferenceability1(Reference_Basic_Information__c accRbi, Reference_Basic_Information__c conRbi,
                                                String accountId, String contactId, String refLaedId, Custom_Settings__c cs) {
        Set<String> referenceabilityTypePresent = new Set<String>();
        Set<String> newReferenceabilityType = new Set<String>();
        List<Referenceability__c> newReferenceabilities = new List<Referenceability__c>();
        Map<Id, Reference_Basic_Information__c> accMap = new Map<Id, Reference_Basic_Information__c>();
        
        if (conRbi.Id != null) {
            
            for (Referenceability__c ref : [SELECT Referenceability_Type__c FROM Referenceability__c
                                            WHERE Status__c = 'Approved'
                                            AND Contact__c = :contactId]) {
                referenceabilityTypePresent.add(ref.Referenceability_Type__c);
            }
            // shared contact code start
            Set<String> accountsIds = new Set<String>();
            
            if (contactId != null && contactId != '' && cs.Shared_Contacts__c && conRbi != null && conRbi.Referenceability_Status__c != ''
                        && conRbi.Referenceability_Status__c != 'Inactive') {
                Boolean addRefToAllAccountsRBI = (conRbi.Roll_up_Referenceability_to_All_Accounts__c
                                                    ? true
                                                    : (conRbi.Roll_up_Referenceability_to_Primary_Acc__c
                                                        ? false
                                                        : (cs.Roll_up_Referenceability_to_All_Accounts__c)));
                
                if (addRefToAllAccountsRBI) {
                    Map<String, Set<String>> contactAccountMap = WithoutSharingHelperController.getRelatedAccounts(new Set<String> {contactId}, cs);
                    
                    if (contactAccountMap != null && contactAccountMap.size() > 0
                                && contactAccountMap.containsKey(contactId)) {
                        accountsIds.addAll(contactAccountMap.get(contactId));
                    }
                }
                
                if (accountsIds.size() > 0) {
                    accMap = WithoutSharingHelperController.getSharedAccountsRBI(accountsIds);
                }
            }
            // end
            
            for (ReferenceLeadReferenceability__c ref : [SELECT Id, Reference_Lead__c, Referenceability_Type__c
                                                            FROM ReferenceLeadReferenceability__c
                                                            WHERE Reference_Lead__c = :refLaedId]) {
                
                if (!referenceabilityTypePresent.contains(ref.Referenceability_Type__c)) {
                    Referenceability__c newRefer = new Referenceability__c();
                    newRefer.Contact__c = contactId != '' ? contactId : null;
                    
                    if (cs.Default_Referenceablity_Status__c == ConstantsController.ACTIVE
                                || cs.Default_Referenceablity_Status__c == ConstantsController.CAUTION) {
                        newRefer.Account__c = accountId != '' ? accountId : null;
                    }
                    newRefer.Status__c = 'Approved';
                    newRefer.Comment__c = 'Mapped from Reference Lead';
                    newRefer.Verified__c = system.today();
                    newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                    newReferenceabilities.add(newRefer);
                    
                    // shared contact code start
                    for (String accId : accountsIds) {
                        
                        if (accId != accountId && accMap != null && accMap.containsKey(accId)
                                    && (accMap.get(accId).Is_Referenceable__c
                                        || accMap.get(accId).Reference_Program_Candidate__c)) {
                            newRefer = new Referenceability__c();
                            newRefer.Contact__c = contactId != '' ? contactId : null;
                            
                            if (cs.Default_Referenceablity_Status__c == ConstantsController.ACTIVE
                                        || cs.Default_Referenceablity_Status__c == ConstantsController.CAUTION) {
                                newRefer.Account__c = accId;
                            }
                            newRefer.Status__c = 'Approved';
                            newRefer.Comment__c = 'Mapped from Reference Lead';
                            newRefer.Verified__c = system.today();
                            newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                            newReferenceabilities.add(newRefer);
                        }
                    }   // end
                }
            }
        } else {
            
            for (Referenceability__c ref : [SELECT Referenceability_Type__c FROM Referenceability__c
                                                WHERE Status__c = 'Approved'
                                                AND Account__c = :accountId]) {
                referenceabilityTypePresent.add(ref.Referenceability_Type__c);
            }
            
            for (ReferenceLeadReferenceability__c ref : [SELECT Id, Reference_Lead__c, Referenceability_Type__c
                                                            FROM ReferenceLeadReferenceability__c
                                                            WHERE Reference_Lead__c = :refLaedId]) {
                
                if (!referenceabilityTypePresent.contains(ref.Referenceability_Type__c)) {
                    Referenceability__c newRefer = new Referenceability__c();
                    newRefer.Account__c = accountId != '' ? accountId : null;
                    newRefer.Status__c = 'Approved';
                    newRefer.Comment__c = 'Mapped from Reference Lead';
                    newRefer.Verified__c = system.today();
                    newRefer.Referenceability_Type__c = ref.Referenceability_Type__c;
                    newReferenceabilities.add(newRefer);
                }
            }
        }
        
        if (newReferenceabilities.size() > 0) {
            newReferenceabilities = WithoutSharingHelperController.upsertReferenceabilities(newReferenceabilities);
        }
    }
    
    /**
     * Method to create Attributes 
     */
    private static void createAttributes1(Reference_Basic_Information__c accRbi, Reference_Basic_Information__c conRbi,
                                            String accountId, String contactId, String refLeadId,
                                            Set<String> conFiltersToExclude, Set<String> accFiltersToExclude) {
        List<Account_Attribute__c> accAtts = new List<Account_Attribute__c>();
        List<Contact_Attribute__c> conAtts = new List<Contact_Attribute__c>();
        Set<String> attributesAssociatedIds = new Set<String>();
        Set<String> attribIdsToBeCreated = new Set<String>();
        Set<String> filtersToExclude = new Set<String>();
        Map<String, Set<String>> filterAttributes = new Map<String, Set<String>>();
        
        if (conRbi.Id != null) {
            
            for (Contact_Attribute__c conAtt : WithoutSharingHelperController.getContactAttribute3(new Set<Id> {contactId})) {
                attributesAssociatedIds.add(conAtt.Attribute__c);
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Label__r.Name, Attribute__c FROM Attributes_Labels__c
                                                    WHERE Attribute__c IN :attributesAssociatedIds]) {
                
                if (!filterAttributes.containsKey(attLabel.label__r.Name)) {
                    filterAttributes.put(attLabel.label__r.Name, new Set<String>());
                }
                filterAttributes.get(attLabel.label__r.Name).add(attLabel.Attribute__c);
            }
            
            for (ReferenceLeadFilter__c refiLableObj : [SELECT Filter__c, Filter__r.Name, Id,
                                                        (SELECT Id, Attribute__c FROM ReferenceLeadAttributes__r)
                                                        FROM ReferenceLeadFilter__c
                                                        WHERE Reference_Lead__c = :refLeadId]) {
                
                if (!(conFiltersToExclude.contains(refiLableObj.Filter__r.Name)
                            && filterAttributes.containsKey(refiLableObj.Filter__r.Name))) {
                    
                    for (ReferenceLeadAttributes__c rla : refiLableObj.ReferenceLeadAttributes__r) {
                        
                        if (!attributesAssociatedIds.contains(rla.Attribute__c)) {
                            attribIdsToBeCreated.add(rla.Attribute__c);
                        }
                    }
                }
            }
            
            for (String attId : attribIdsToBeCreated) {
                conAtts.add(new Contact_Attribute__c(Contact__c = contactId != '' ? contactId : null, Attribute__c = attId));
            }
            
            if (conAtts.size() > 0) {
                conAtts = WithoutSharingHelperController.upsertContactAttributes(conAtts);
            }
        } else {
            
            for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttribute3(new Set<Id> {accountId})) {
                attributesAssociatedIds.add(accAtt.Attribute__c);
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Label__r.Name, Attribute__c FROM Attributes_Labels__c
                                                    WHERE Attribute__c IN :attributesAssociatedIds]) {
                
                if (!filterAttributes.containsKey(attLabel.label__r.Name)) {
                    filterAttributes.put(attLabel.label__r.Name, new Set<String>());
                }
                filterAttributes.get(attLabel.label__r.Name).add(attLabel.Attribute__c);
            }
            
            for (ReferenceLeadFilter__c refiLableObj : [SELECT Filter__c, Filter__r.Name, Id,
                                                        (SELECT Id, Attribute__c FROM ReferenceLeadAttributes__r)
                                                        FROM ReferenceLeadFilter__c
                                                        WHERE Reference_Lead__c = :refLeadId]) {
                
                if (!(accFiltersToExclude.contains(refiLableObj.Filter__r.Name)
                            && filterAttributes.containsKey(refiLableObj.Filter__r.Name))) {
                    
                    for (ReferenceLeadAttributes__c rla : refiLableObj.ReferenceLeadAttributes__r) {
                        
                        if (!attributesAssociatedIds.contains(rla.Attribute__c)) {
                            attribIdsToBeCreated.add(rla.Attribute__c);
                        }
                    }
                }
            }
            Map<String, Set<String>> attribParentIdsMap = new Map<String, Set<String>>();
            Map<String, Boolean> attributeInheritable = new Map<String, Boolean>();
            Set<String> parentAttIds = new Set<String>();
            Map<String, String> attIdNameMap = new Map<String, String>();
            Set<String> tempSet = new Set<String>();
            
            for (Attribute__c att : [SELECT ParentIds__c, Name, Id
                                        FROM Attribute__c
                                        WHERE Id IN :attribIdsToBeCreated]) {
                tempSet = new Set<String>();
                
                if (att.ParentIds__c != null) {
                    tempSet.addAll(att.ParentIds__c.split(','));
                }
                parentAttIds.addAll(tempSet);
                attribParentIdsMap.put(att.Id, tempSet);
            }
            
            for (Attribute__c att : [SELECT Id, Inheritable__c FROM Attribute__c
                                        WHERE Id IN :parentAttIds AND Level__c = 0]) {
                
                for (String attKey : attribParentIdsMap.keySet()) {
                    
                    if (attribParentIdsMap.get(attKey).contains(att.Id)) {
                        attributeInheritable.put(attKey, att.Inheritable__c);
                    }
                }
            }
            
            for (String attId : attribIdsToBeCreated) {
                accAtts.add(new Account_Attribute__c(Account__c = accountId != '' ? accountId : null, Attribute__c = attId, Inheritable__c = attributeInheritable.get(attId)));
            }
            
            if (accAtts.size() > 0) {
                accAtts = WithoutSharingHelperController.upsertAccountAttributes(accAtts);
            }
        }
    }
    
    /**
     * Method to create chatter for Reference Profile
     */
    private static void createChatterForRBI1(Reference_Basic_Information__c rbi, Reference_Basic_Information__c crbi,
                                                String accountName, String conName, Custom_Settings__c cs) {
        String rbiNominationLink = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>(); 
        //REF-1316- Added check for CRP team member should be active
        List<User> publicGroupMembers = getCustomerReferenceTeam();
        List<sObject> postFeedItems = new List<sObject>();
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c profileCreatedNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Email__c'};

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Creation_from_Ref_Lead_Email__c') {
                profileCreatedNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        
        String body = profileCreatedNotification.DC_Message__c + '\n\n' + profileCreatedNotification.Default__c;
        body = body.replace('[Account Name]', accountName)
                    .replace('[Creator Name]', UserInfo.getName());
        
        if (conName != '') {
            body = body.replace('[Contact Name]', conName);
        } else {
            body = body.replace('Contact: [Contact Name]\n', '');
        }
        
        if (cs.Profile_Creation_from_Ref_Lead_Chatter__c && UtilityController.isNativeChatterSetting) {
            
            for (User gm : publicGroupMembers) {
                String userId = gm.Id;
                
                if (userId.startsWith('005')) {
                    postFeedItems.add(MailChatterController.preparePost(profileCreatedNotification.Section_Name__c, userId, body, rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id)));
                }
            }
        }
        
        if (cs.Profile_Creation_from_Ref_Lead_Email__c) {

            for (User gm : publicGroupMembers) {
                String userId = gm.Id;
                
                if (userId.startsWith('005')) {
                    listmail.add(MailChatterController.prepareEmail(profileCreatedNotification.Section_Name__c, userId, body + '\n\n' + profileCreatedNotification.Section_Name__c + ': <a href="' + rbiNominationLink
                        + (conName != '' ? crbi.Id : rbi.Id) + '">' + rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id) + '</a>', true, headerDocId, footerDocId));
                }
            }
        }
        
        if (cs.Enable_Slack_Integration__c && cs.Profile_Creation_from_Ref_Lead_Slack__c) {
            String slackBody = body + '\n<' + rbiNominationLink + (conName != '' ? crbi.Id : rbi.Id) + '|'
                + profileCreatedNotification.Section_Name__c + '>';
            System.enqueueJob(new SendSlackMsgQueueable(slackBody, cs.Slack_Team_Ids__c != null ? cs.Slack_Team_Ids__c : ''));
        }
        
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
    }
    // end
    
    /**
     * Method to get the encoded key to be used for encryption/decryption in microsite
     * added for #588 by Gaurav Saini (23 Nov, 2016)
     */
    public static String getEncodedKey() {
        RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        String encodedKey = '';
        
        if (protectedAppConfig.Microsite_Key__c != null && protectedAppConfig.Microsite_Key__c != '') {
            encodedKey = protectedAppConfig.Microsite_Key__c;
        }
        return encodedKey;
    }
    
    /**
     * Method to get the current package installation date FROM custom settings
     * added for #588 by Gaurav Saini (5 Dec, 2016)
     */
    public static Datetime getCurrentPackageDate() {
        RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        Datetime currentPackageDate;
        
        if (protectedAppConfig.Current_Package_Date__c != null) {
            currentPackageDate = protectedAppConfig.Current_Package_Date__c;
        }
        return currentPackageDate; 
    }
    
    /**
     * Method to get Custom Settings
     * Last Modified By: Gaurav Saini (5 Dec, 2016)
     */
    public static Custom_Settings__c CustomSettings;
    public static Custom_Settings__c getCustomSettings() {
        
        if (CustomSettings == null) {
            List<Custom_Settings__c> lstCustomSettings = new List<Custom_Settings__c>(); 
            
            if (UserInfo.isMultiCurrencyOrganization()) {
                String query = 'SELECT Id, Show_Featured_Content_First__c, Show_Contacts_in_RefSearch__c, Name, Number_of_request_accounts__c, Minimum_Deadline__c, Reminder_to_Owner__c,'
                    + 'Escalation_to_Owner_Manager__c, No_Response__c, Feedback_Message_Delay__c, Email_Enabled__c, Chatter_Enabled__c, Include_Weekends__c, Days_of_Week__c,'
                    + 'Active_Version__c, Current_Version__c, RUL_Period__c, RUL_Activities__c, Consider_No_longer_needed_a_use__c,P2P_Approve_Without_Contact__c,'
                    + 'Auto_create_delete_Reference_Content__c, Critical_Deadline_window__c, Caution_deadline_window__c, Nomination_disposition_window__c, General_Notes__c, Expire_Rewards__c,'
                    + 'Automatically_Assign_Rewards__c, Expiration_Timeframe__c, Expiration_Days__c, Default_Expiration_Days__c, Maximum_Expiration_Days__c,Shared_Contact_Field__c,'
                    + 'Organization_FiscalYearStartMonth__c, Default_Referenceablity_Status__c, Automatically_Assign_Reward_on_Feedback__c,Shared_Contact_Object__c,'
                    + 'Microsite_Visit_Chatter__c, Microsite_Visit_Email__c, Nomination_Chatter__c, Nomination_Email__c, Request_Managed_Chatter__c,Infl_Reference_Cursor__c,Infl_Event_Fetch_DateTime__c,Is_Influitive_Integration_Enabled__c ,'
                    + 'Reference_Refresh_Update_Chatter__c, Reference_Refresh_Update_Email__c, Reference_Update_Chatter__c, Reference_Update_Email__c,Influitive_API_URL__c,Influitive_Auth_Token__c,'
                    + 'Request_Managed_Email__c, Request_Peer2Peer_Chatter__c, Request_Peer2Peer_Email__c, Request_Escalation_Chatter__c, Request_Escalation_Email__c,Auto_Assign_Sales_Rewards__c,'
                    + 'Request_Feedback_Chatter__c, Request_Feedback_Email__c, Request_No_Response_Chatter__c, Request_No_Response_Email__c, Request_Reminder_Chatter__c,Auto_Assign_Sales_Reward_on_Feedback__c,'
                    + 'Request_Reminder_Email__c, Process_Update_Chatter__c, Process_Update_Email__c, Request_Approval_Decline_Email__c, Request_Approval_Decline_Chatter__c, Managed_to_P2P_Min__c,'
                    + 'Project_Owner_Update_Email__c, RUL_Activities_Contact__c, RUL_Period_Contact__c, Project_Owner_Update_Chatter__c, Status_Update_Email__c, Status_Update_Chatter__c,'
                    + 'Check_back_in_Email__c, Check_back_in_Chatter__c, Minimum_Sales_Stage__c, Reference_Lead_No_Response_Email__c, Reference_Lead_No_Response_Chatter__c,'
                    + 'Opportunity_Closed_Won_Stage__c, Manual_Automatic_Launch__c, Refresh_Wait_Days__c, Enable_Reference_Refresh__c, Quarantine_updates__c,Shared_Account_Field__c,'
                    + 'Prevent_selection_of_mapped_Attributes__c, Managed_Request_Opportunity_Threshold__c, Minimum_Opportunity_Size__c, Create_Reference_Profile__c,Expire_Sales_Rewards__c,'
                    + 'Create_Nomination__c, Client_Referenceability_check_days__c, No_Response_days__c, Last_Refresh_Date__c, Next_Refresh_launch_Date__c, cloneTriggerId__c,Sales_Expiration_Days__c,'
                    + 'Community_Home_Text__c, Community_Ref_Activities_Message__c, Apply_Opportunity_Stage_Filter__c, Filtered_Content_Ids__c,Opportunity_Product_Field_API_Name__c,'
                    + 'Manage_ContentVersion_Custom_Fields__c,P2P_Select_Inactive_Contacts__c,Sales_Expiration_Timeframe__c,'
                    + 'Reviewed_and_Ready_to_Launch__c,Remove_Points_if_Use_will_not_occur__c, Send_reminder_for_automatic__c, Profile_Update_Reminder_Email__c,Sales_Reward_Point_Email__c,Sales_Reward_Point_Chatter__c, Profile_Update_Reminder_Chatter__c,'
                    + 'RLF_Reminder_Days__c,PUM_No_Response_Days__c,Reference_Profile_Section_Header__c,Minimum_Opportunity_Size_OP__c,CurrencyIsoCode,Default_Reference_Accounts_Managed__c,Shared_Contacts__c, '
                    + 'Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c,Roll_up_Referenceability_to_All_Accounts__c,Roll_up_Referenceability_to_Primary_Acc__c,'
                    + 'Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c,Limit_Contact_Redeem__c,Initial_Notification_Email__c,Initial_Notification_Chatter__c,'
                    + 'Sales_Reward_Batch_Trigger_Id__c, Enable_Sales_Rewards_Notification__c, Next_Notification_Date__c, Last_Notification_Date__c,'
                    + 'Adv_Request_Routing__c, Adv_Rt_Acct_Team_Roles_to_Include__c, Adv_Rt_Acct_Team_Role_Picklist__c, Adv_Routing_Default__c, Adv_Rt_Acct_Team_Object__c, Adv_Rt_Acct_Team_Routeby__c, Adv_Rt_Acct_Team_User__c, Adv_Rt_Acct_Team_Contact__c, Adv_Routing_Group_Lbl__c, Adv_Routing_Group_Mandatory__c,'
                    + 'User_Reward_Chatter_Summary__c, User_Reward_Email_Summary__c, User_Reward_Onscreen_Notification__c, RefSearch_Filters_Default__c, PUM_New_Contact__c,'
                    + 'Project_Account_Required__c, Project_Contact_Required__c, Project_Opportunity_Required__c, Project_Case_Required__c, Project_Notes_Required__c, Project_Subject_Required__c, '
                    + 'Approve_Decline_Confirmation_Chatter__c, Approve_Decline_Confirmation_Email__c, Request_from_Leads__c , Ref_Prosepector_Lead_Owner__c, '
                    + 'Export_Objects__c, Import_Objects__c, Export_Object__c, Import_Object__c, Enable_Custom_Data_Loader__c, Populate_Summary_frm_Account_Description__c, Show_Related_Ref_Content_in_RefSearch__c, Show_Summary__c, '
                    + 'Ref_Prospector_Campaign_Lead_Count__c, Ref_Prospector_Lead_Count__c, Ref_Prospector_Body__c, Ref_Prospector_Subject__c, '
                    + 'Ref_Prospector_SubHdr_Txt__c, Ref_Prospector_Hdr_Txt__c, Ref_Prospector_Enable__c ,Data_Loader_Template_Fields__c,  Help_Overlay_Count__c, '
                    + 'Account_Stages__c, Prompt_Message__c, Content_Stages__c ,Show_Matching_Reference_Content_link__c, Show_Matching_Reference_Accounts_link__c, Enable_Reference_Prompt__c, Enable_Ref_Search_Export__c, Reset_Help_Assistant_Days__c, '
                    + 'Enable_Data_Collector__c, Data_Collector_Name__c, Escalate_On_Last_Reminder__c, Frequency_Of_Reminders__c, Manage_Data_Collector__c, Minimum_Opportunity_Size_DC__c, Number_Of_Reminders_To_Be_Sent__c, Opportunity_Closed_Stages__c, '
					+ 'P2P_to_Managed_Chatter__c, P2P_to_Managed_Email__c, Managed_to_P2P_Requester_Chatter__c, Managed_to_P2P_Requester_Email__c, Managed_to_P2P_Owner_Chatter__c, Managed_to_P2P_Owner_Email__c, '
                    + 'Ref_Lead_Reminder_Chatter__c, Ref_Lead_Reminder_Email__c, Ref_Lead_Reminder_member_Chatter__c, Ref_Lead_Reminder_member_Email__c, Initial_Notification_member_Chatter__c, Initial_Notification_member_Email__c, '
                    + 'Large_Opportunity_Email__c, Large_Opportunity_Chatter__c, Profile_Created_Chatter__c, Profile_Created_Email__c, Profile_Creation_from_Ref_Lead_Chatter__c, Profile_Creation_from_Ref_Lead_Email__c, '
                    + 'Nomination_Accepted_Email__c, Nomination_Accepted_Chatter__c, Nomination_Rejected_Email__c, Nomination_Rejected_Chatter__c, Ref_Lead_Owner_Update_Email__c, Ref_Lead_Owner_Update_Chatter__c, '
					+ 'Enabled_Content_Integration__c, Default_Library__c, Default_Reference_Content_Type__c, Create_Advocate_Reference_Profile__c, All_Reviews_to_CRP_Team__c, Include_Opp_Attributes_in_RefSearch__c, '
                    + 'Content_import_API_reporting_email__c, Slack_Team_Ids__c, Enable_Slack_Integration__c, Slack_Enabled__c, Request_Peer2Peer_Slack__c, Request_Managed_Slack__c, Large_Opportunity_Slack__c, Request_Approval_Decline_Slack__c, '
                    + 'Request_Reminder_Slack__c, Request_Escalation_Slack__c, Request_No_Response_Slack__c, Approve_Decline_Confirmation_Slack__c, Project_Owner_Update_Slack__c, Status_Update_Slack__c, Managed_to_P2P_Owner_Slack__c, '
                    + 'Managed_to_P2P_Requester_Slack__c, P2P_to_Managed_Slack__c, Request_Feedback_Slack__c, Microsite_Visit_Slack__c, Nomination_Slack__c, Nomination_Accepted_Slack__c, Nomination_Rejected_Slack__c, '
                    + 'Initial_Notification_Slack__c, Initial_Notification_member_Slack__c, Ref_Lead_Reminder_Slack__c, Ref_Lead_Reminder_member_Slack__c, Check_back_in_Slack__c, Ref_Lead_Owner_Update_Slack__c, Profile_Creation_from_Ref_Lead_Slack__c, '
                    + 'Reference_Refresh_Update_Slack__c, Reference_Update_Slack__c, Profile_Update_Reminder_Slack__c, Profile_Created_Slack__c, User_Reward_Slack_Summary__c, Sales_Reward_Point_Slack__c, SU_Permission_Sets__c, SU_Profiles__c, RM_Permission_Sets__c, '
                    + 'ACV_Amount_Field__c, ACV_Basis__c, RM_Profiles__c, Attach_Supporting_Documents_To_Requests__c, Create_Nominees__c, Routing_Groups_to_Exclude__c, refedge_p2p_use_adds_ref__c, Show_Owner_in_Ref_Search__c, Request_Notes_Required__c, '
                    + 'DC_Initial_Notification_Email__c, DC_Reminder_Email__c, DC_Escalation_to_Owner_Email__c, DC_Escalation_to_Manager_Email__c, DC_Manager_Review_Email__c, DC_CRP_Team_Review_Email__c, '
                    + 'DC_Initial_Notification_Chatter__c, DC_Reminder_Chatter__c, DC_Escalation_to_Owner_Chatter__c, DC_Escalation_to_Manager_Chatter__c, DC_Manager_Review_Chatter__c, DC_CRP_Team_Review_Chatter__c, '
                    + 'DC_Initial_Notification_Slack__c, DC_Reminder_Slack__c, DC_Escalation_to_Owner_Slack__c, DC_Escalation_to_Manager_Slack__c, DC_Manager_Review_Slack__c, DC_CRP_Team_Review_Slack__c '
                    + 'FROM Custom_Settings__c WHERE Active_Version__c = true order by Current_Version__c DESC limit 1';
                lstCustomSettings = WithoutSharingHelperController.getCustomSettings1(query); 
            } else {
                lstCustomSettings = WithoutSharingHelperController.getCustomSettings2();
            } 
            
            if (lstCustomSettings.size() > 0) {
                CustomSettings = lstCustomSettings[0];
            } else {
                CustomSettings = new Custom_Settings__c();
            }
        }
        return CustomSettings;
    }
    /**
     * Method to check currency is enabled for user or not
     */
    public static boolean isCurrencyEnabled(){
        Map<String,Schema.SObjectType> globaldesc = CRUDAndFLSCheckController.sObjectsMap; 
        return globaldesc.containsKey('CurrencyType');
    }
    /**
     * Method to get Object available for RefEdge DM
     * For allowing Import/Export features on Any object add the object name to respective list(In Alphabetical Order)
     */
    public static Map<String,Map<String,String>> getAvailableObjects() {
            Map<String,Map<String,String>> allObjects = new Map<String,Map<String,String>>();
            //Import Object : Add Object API Name to this List : put('API name','Label')
            allObjects.put('import',new Map<String,String>());
            allObjects.get('import').put('Reference_Basic_Information__c','Reference Profile');
            allObjects.get('import').put('Reference_Content__c','Reference Content');
            allObjects.get('import').put('Reference_Request__c','Historical Request');
            
            //Export Object : Add Object API Name to this List : put('API name','Label')
            allObjects.put('export',new Map<String,String>());
            allObjects.get('export').put('Account','Account');
            allObjects.get('export').put('Account_with_Attributes__c','Account with Attributes');
            allObjects.get('export').put('Attribute__c','Attribute'); 
            allObjects.get('export').put('Account','Account');
            allObjects.get('export').put('Reference_Request_Account__c','Account Request');
            allObjects.get('export').put('Contact','Contact');
            allObjects.get('export').put('Contact_with_Attributes__c','Contact with Attributes');
            allObjects.get('export').put('Content_with_Attributes__c','Content with Attributes');
            allObjects.get('export').put('Library__c','Library');
            allObjects.get('export').put('Label__c','Filter');
            allObjects.get('export').put('Reference_Content__c','Reference Content');
            allObjects.get('export').put('Reference_Content_Type__c','Reference Content Type');
            allObjects.get('export').put('Reference_Basic_Information__c','Reference Profile');
            allObjects.get('export').put('Referenceability_Type__c','Referenceability Type');
            allObjects.get('export').put('Unspecified_Request__c','Unspecified Request');
            return allObjects;
    }

    public static List<Data_Mapping__c> fetchData(String objectType) {
        List<Data_Mapping__c> fieldList = new List<Data_Mapping__c>();
			
	    if (objectType != null && objectType.trim() != '') {
			objectType = String.escapeSingleQuotes(objectType);
	        String objectName = 'DM' + objectType;
            String query = 'SELECT Name, Id, Required__c, Label__c, Visible__c, Order__c, Section_Name__c, Data_Collector_Name__c, Field_API_Name__c, Object__c FROM Data_Mapping__c WHERE Object__c = \''+ String.escapeSingleQuotes(objectName) + '\' ORDER BY Visible__c DESC, Order__c ASC NULLS LAST';
            
			if (objectType.trim() == 'Reference_Content__c') {
                query = 'SELECT Name, Id, Required__c, Label__c, Visible__c, Order__c, Field_API_Name__c, Object__c FROM Data_Mapping__c WHERE Object__c = \''+ String.escapeSingleQuotes(objectName) + '\' OR Object__c = \'DMContentVersion\' ORDER BY Visible__c DESC, Order__c ASC NULLS LAST';
			}
			fieldList = Database.query(query) ;
	        //First time creating DataMapping records for DM Funcationality. 
	        if (fieldList.size() == 0) {
	        	Data_Mapping__c dlMappingTemp = new Data_Mapping__c();
	        	/* REF-1333 - Here we check for the existing records with Object name DataLoaderFields ,if we found that then we update it with name 
	        	DMReference_Content and new record for Attribute Ids*/
	        	List<Data_Mapping__c> lstDm = new List<Data_Mapping__c>(); 	  
	        	
	        	if (objectType.trim() == 'Reference_Content__c') {      	
	        		lstDm = [SELECT Name, Id, Object__c,Required__c, Order__c, Label__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c 
	        								WHERE Object__c = 'DataLoaderFields'];
	        	}
	        	Decimal count = 0 ;							
				if (lstDm.size() > 0) {
					
					for (Data_Mapping__c dm : lstDm) {
						dm.Object__c = ConstantsController.DM_REFERENCE_CONTENT;
						count = (dm.Required__c != null && dm.Required__c && dm.Order__c != null && count <= dm.Order__c) ? dm.Order__c + 1 : count;
					} 
					//#REF-1592
					Map<String, Schema.SObjectType> objectMapCV = CRUDAndFLSCheckController.sObjectsMap;
					Schema.SObjectType objTypeCV = objectMapCV.get('ContentVersion');
					Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
					Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();       
					List<Data_Mapping__c> CVFieldsList = new List<Data_Mapping__c>();
					
					for (String fieldName : fieldMapCV.keySet()) {                
						Schema.DescribeFieldResult field = fieldMapCV.get(fieldName).getDescribe(); 
						Data_Mapping__c dlMappingCV = new Data_Mapping__c();
						
						if (field.isCustom() && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c' && field.isCreateable() && field.isAccessible()) {    
							
							if (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate()) {
								dlMappingCV.Required__c = true;
								dlMappingCV.Visible__c = true;
								dlMappingCV.Order__c = count++;  
		
							} else {
								dlMappingCV.Required__c = false;
								dlMappingCV.Visible__c = false;                                        
							} 
							
							dlMappingCV.Object__c = 'DMContentVersion';
							dlMappingCV.Label__c = field.getLabel();
							dlMappingCV.Field_API_Name__c= field.getName();   
							CVFieldsList.add(dlMappingCV);          
						}   
					}
					lstDm.addAll(CVFieldsList);
					
					// Added new record for Attribute id 
					dlMappingTemp.Field_API_Name__c = UtilityController.appNamespace() + 'Attribute_Ids__c';
					dlMappingTemp.Label__c = 'Attribute Ids';	
					dlMappingTemp.Object__c = ConstantsController.DM_REFERENCE_CONTENT;	
					lstDm.add(dlMappingTemp);
					ConstantsController.shouldDataMappingProcessed = true; 	       	
					upsert lstDm;	
					fieldList = UtilityController.cleanDataMappingRecords(objectType,fieldList);		       	
				} else { 
                    if (objectType.trim() == 'Reference_Request__c') {
                        Integer countImp = 1;
                        String namespace = UtilityController.appNamespace();
                        fieldList = new List<Data_Mapping__c>();
                        Map <String, Schema.SObjectField> fieldMapAddInfo = (CRUDAndFLSCheckController.sObjectsMap.get(namespace + 'Reference_Request_Additional_Info__c')).getDescribe().fields.getMap();
                        //Section_Name__c == type & Data_Collector_Name__c = object
                        //Reference Request Fields : Reference_Request__c
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Opportunity__c' ,Label__c = 'Opportunity',Object__c = 'DMReference_Request__c',Required__c = false ,Visible__c = false,Section_Name__c = 'REFERENCE', Data_Collector_Name__c = namespace + 'Reference_Request__c'));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Requester__c' ,Label__c = 'Requester',Object__c = 'DMReference_Request__c',Required__c = false ,Visible__c = false,Section_Name__c = 'REFERENCE', Data_Collector_Name__c = namespace + 'Reference_Request__c'));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Title__c' ,Label__c = 'Subject',Object__c = 'DMReference_Request__c',Required__c = false ,Visible__c = false,Section_Name__c = 'STRING', Data_Collector_Name__c = namespace + 'Reference_Request__c'));
                        //Account Request Fields : Reference_Request_Account__c
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Account__c' ,Label__c = 'Account',Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'REFERENCE', Data_Collector_Name__c = namespace + 'Reference_Request_Account__c', Order__c = countImp++));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Activity_Date__c' ,Label__c = 'Activity date',Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'DATE', Data_Collector_Name__c = namespace + 'Reference_Request_Account__c',Order__c = countImp++));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Reference_Type_Needed__c' ,Label__c = 'Reference Type Needed',Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'REFERENCE', Data_Collector_Name__c = namespace + 'Reference_Request_Account__c', Order__c = countImp++));
                        //Contact Request Fields : Reference_Request_Account_Contact__c
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Contact__c' ,Label__c = 'Contact' ,Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'REFERENCE', Data_Collector_Name__c = namespace + 'Reference_Request_Account_Contact__c', Order__c = countImp++));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Feedback_Status__c' ,Label__c = 'Use Feedback' ,Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'PICKLIST', Data_Collector_Name__c = namespace + 'Reference_Request_Account_Contact__c', Order__c = countImp++));
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Feedback_Response__c' ,Label__c = 'Feedback' ,Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'TEXTAREA', Data_Collector_Name__c = namespace + 'Reference_Request_Account_Contact__c', Order__c = countImp++));
                        //Reference Request Filters Fields : Reference_Request_Label__c
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Label__c' ,Label__c = 'Filters' ,Object__c = 'DMReference_Request__c',Required__c = false ,Visible__c = false,Section_Name__c = 'STRING', Data_Collector_Name__c = namespace + 'Reference_Request_Label__c'));
                        //Reference Request Filters Attributes Fields : Reference_Request_Label_Attribute__c
                        fieldList.add(new Data_Mapping__c (Field_API_Name__c = namespace + 'Attribute__c' ,Label__c = 'Attributes' ,Object__c = 'DMReference_Request__c',Required__c = false ,Visible__c = false,Section_Name__c = 'STRING', Data_Collector_Name__c = namespace + 'Reference_Request_Label_Attribute__c'));
                        //Reference_Request_Additional_Info__c fields
                        for (Reference_Request_Field__c rrf : [SELECT Order__c, Name, Field_API_Name__c
        										FROM Reference_Request_Field__c
        										LIMIT :limits.getLimitQueryRows()]) {
                            fieldList.add(new Data_Mapping__c (Field_API_Name__c = rrf.Field_API_Name__c ,Label__c = rrf.Name ,Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true, Section_Name__c = String.valueof(fieldMapAddInfo.get(rrf.Field_API_Name__c.toLowerCase()).getDescribe().getType()), Data_Collector_Name__c = namespace + 'Reference_Request_Additional_Info__c', Order__c = countImp++));
                        }
                        ConstantsController.shouldDataMappingProcessed = true;
                        Database.insert(fieldList);
                        fieldList = Database.query(query);
                    } else {        	
                        Integer countImp = 1;
                        Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
                        Schema.SObjectType objType = gd.get(UtilityController.appNamespace() + objectType);
                        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                        fieldList = new List<Data_Mapping__c>();
                        
                        for (String fieldName : fieldMap.keySet()) {
                            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();		                
                            dlMappingTemp = new Data_Mapping__c();
                            
                            if ((field.isCreateable() && field.isAccessible()
                                && field.getName() != UtilityController.appNamespace() + 'Data_Collector_Name__c' && field.getName() != UtilityController.appNamespace() + 'Data_Collector_Status__c'
                                && field.getName() != UtilityController.appNamespace() + 'Reminder_Date__c' && field.getName() != UtilityController.appNamespace() + 'Opportunity__c'
                                && field.getName() != UtilityController.appNamespace() + 'Number_of_Reminders_Sent__c' && field.getName() != UtilityController.appNamespace() + 'Opportunity_Owner__c'
                                && field.getName() != UtilityController.appNamespace() + 'Content_URL2__c')
                                || field.getName() == 'Id') {
                                
                                if (field.getName() == 'Id' || field.getName() == UtilityController.appNamespace() + 'Content_URL__c'
                                        || field.getName() == UtilityController.appNamespace() + 'Reference_Content_Type__c'
                                        || field.getName() == UtilityController.appNamespace() + 'Referenceability_Status__c'
                                        || field.getName() == UtilityController.appNamespace() + 'Account__c' 
                                        || field.getName() == UtilityController.appNamespace() + 'Contact__c'
                                        || field.getName() == UtilityController.appNamespace() + 'Library_ID__c'
                                        || (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate())) {
                                    dlMappingTemp.Required__c = true;
                                    dlMappingTemp.Visible__c = true;
                                    dlMappingTemp.Order__c = countImp++;
                                } else { 
                                    dlMappingTemp.Required__c = false;
                                    dlMappingTemp.Visible__c = false;
                                }
                                dlMappingTemp.Object__c = objectName;
                                dlMappingTemp.Label__c = field.getLabel();
                                dlMappingTemp.Field_API_Name__c = field.getName(); 
                                fieldList.add(dlMappingTemp); 
                            }
                        }
                        
                        if (objectType.trim() == 'Reference_Content__c') {
                            Map<String, Schema.SObjectType> objectMapCV = CRUDAndFLSCheckController.sObjectsMap;
                            Schema.SObjectType objTypeCV = objectMapCV.get('ContentVersion');
                            Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
                            Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();       
                            List<Data_Mapping__c> CVFieldsList = new List<Data_Mapping__c>();
                            //#REF-1592
                            for (String fieldName : fieldMapCV.keySet()) {                
                                Schema.DescribeFieldResult field = fieldMapCV.get(fieldName).getDescribe(); 
                                Data_Mapping__c dlMappingCV = new Data_Mapping__c();
                                
                                if (field.isCustom() && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c' && field.isCreateable() && field.isAccessible()) {    
                                    
                                    if (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate()) {
                                        dlMappingCV.Required__c = true;
                                        dlMappingCV.Visible__c = true;
                                        dlMappingCV.Order__c = countImp++;  
                
                                    } else {
                                        dlMappingCV.Required__c = false;
                                        dlMappingCV.Visible__c = false;                                        
                                    } 
                                    
                                    dlMappingCV.Object__c = 'DMContentVersion';
                                    dlMappingCV.Label__c = field.getLabel();
                                    dlMappingCV.Field_API_Name__c= field.getName();   
                                    CVFieldsList.add(dlMappingCV);          
                                }   
                            }
                            fieldList.addAll(CVFieldsList);
                        }
                        ConstantsController.shouldDataMappingProcessed = true; 
                        insert fieldList;
                    }
		        }
	        } else {
                if (objectType.trim() == 'Reference_Request__c') {
                    Decimal countImp = 1;
                    List<Data_Mapping__c> insertList = new List<Data_Mapping__c>();
                    Map<String,Data_Mapping__c> addInfoMap = new Map<String,Data_Mapping__c>();
                    Data_Mapping__c actdateOld;
                    for (Data_Mapping__c dmInfo : fieldList) {
                        
                        if (dmInfo.Data_Collector_Name__c == UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c') {
                            addInfoMap.put(dmInfo.Field_API_Name__c,dmInfo);
                            countImp = countImp > dmInfo.Order__c ? countImp : dmInfo.Order__c;
                        }
                        if (dmInfo.Field_API_Name__c == UtilityController.appNamespace() + 'Activity_Date__c' && !dmInfo.Required__c) {
                            actdateOld = dmInfo;
                        }
                    }
                    Map <String, Schema.SObjectField> fieldMapAddInfo = (CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c')).getDescribe().fields.getMap();
                    
                    for (Reference_Request_Field__c rrf : [SELECT Order__c, Name, Field_API_Name__c
                                            FROM Reference_Request_Field__c
                                            LIMIT :limits.getLimitQueryRows()]) {
                        if (addInfoMap.containsKey(rrf.Field_API_Name__c)) {
                            addInfoMap.remove(rrf.Field_API_Name__c);
                        } else {
                            insertList.add(new Data_Mapping__c (Field_API_Name__c = rrf.Field_API_Name__c ,Label__c = rrf.Name ,Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true, Section_Name__c = String.valueof(fieldMapAddInfo.get(rrf.Field_API_Name__c.toLowerCase()).getDescribe().getType()), Data_Collector_Name__c = UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c', Order__c = countImp++));
                        }
                    }
                    for (Data_Mapping__c listElement : addInfoMap.values()) {
                        if (fieldList.indexOf(listElement) != -1) {
                            fieldList.remove(fieldList.indexOf(listElement));
                        }
                    }
                    if (actdateOld != null) {
                        if (fieldList.indexOf(actdateOld) != -1) {
                            fieldList.remove(fieldList.indexOf(actdateOld));
                        }
                        addInfoMap.put(actdateOld.Field_API_Name__c,actdateOld);
                        insertList.add(new Data_Mapping__c (Field_API_Name__c = UtilityController.appNamespace() + 'Activity_Date__c' ,Label__c = 'Activity date',Object__c = 'DMReference_Request__c',Required__c = true ,Visible__c = true,Section_Name__c = 'DATE', Data_Collector_Name__c = UtilityController.appNamespace() + 'Reference_Request_Account__c',Order__c = countImp + 1));
                        
                    }
                    if (addInfoMap.size() > 0) {
                        ConstantsController.shouldDataMappingProcessed = true;
                        Database.delete(addInfoMap.values());
                    } 
                    
                    if (insertList.size() > 0) {
                        ConstantsController.shouldDataMappingProcessed = true;
                        Database.insert(insertList);
                        fieldList.addAll(insertList);
                    }
                } else {
                    if (objectType.trim() == 'Reference_Content__c') { 
                        Boolean cvFieldsExist = false;
                        Decimal count = 1;
                        //#REF-1592
                        for (Data_Mapping__c field : fieldList) {
                            
                            if (field.Object__c == 'DMContentVersion') {
                                cvFieldsExist = true;
                                break;
                            } else{
                                count = (field.Required__c != null && field.Required__c && field.Order__c != null && count <= field.Order__c) ? field.Order__c + 1 : count;
                            }
                        }

                        if (!cvFieldsExist) {
                            Map<String, Schema.SObjectType> objectMapCV = CRUDAndFLSCheckController.sObjectsMap;
                            Schema.SObjectType objTypeCV = objectMapCV.get('ContentVersion');
                            Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
                            Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();       
                            List<Data_Mapping__c> CVFieldsList = new List<Data_Mapping__c>();
                            
                            for (String fieldName : fieldMapCV.keySet()) {                
                                Schema.DescribeFieldResult field = fieldMapCV.get(fieldName).getDescribe(); 
                                Data_Mapping__c dlMappingCV = new Data_Mapping__c();
                                
                                if (field.isCustom() && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c' && field.isCreateable() && field.isAccessible()) {    
                                    
                                    if (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate()) {
                                        dlMappingCV.Required__c = true;
                                        dlMappingCV.Visible__c = true;
                                        dlMappingCV.Order__c = count++;  
                
                                    } else {
                                        dlMappingCV.Required__c = false;
                                        dlMappingCV.Visible__c = false;                                        
                                    } 
                                    
                                    dlMappingCV.Object__c = 'DMContentVersion';
                                    dlMappingCV.Label__c = field.getLabel();
                                    dlMappingCV.Field_API_Name__c= field.getName();   
                                    CVFieldsList.add(dlMappingCV);          
                                }   
                            }
                            ConstantsController.shouldDataMappingProcessed = true;
                            insert CVFieldsList;
                            fieldList.addAll(CVFieldsList);
                        } 
                    }
                    fieldList = UtilityController.cleanDataMappingRecords(objectType,fieldList);
                }
            }
	    }
        return fieldList;
	}

            
    /**
     * Method to return all currency
     * Modified By: Rekha @12 May 2017 regarding #843
     */
    public static Map<String, sObject> currencyMap;
    public static Map<String, sObject> getAllCurrency() {
        
        if (currencyMap == null) { 
            currencyMap = new Map<String, sObject>();
            
            for (sObject c : Database.query('SELECT ISOCode, ConversionRate FROM CurrencyType')) {
                currencyMap.put(String.valueOf(c.get('ISOCode')), c);
            }
        }
        return currencyMap;
    }
    
    /**
     * Method to return value of String or Blank String
     */
    public static String checkValueOfString(String strValue) {
        
        if (strValue == null) {
            return '';
        } else {
            return String.valueOf(strValue);
        }
    }
    
    /**
     * Method to convert selected items into list of String
     */
    public static List<String> convertCommaSeperatedStringToArray(String value) {
        
        if (value == null) {
            return null;
        } else {
            return value.split(',');
        }
    }

    /**
     * Method to Calculate Minimum Days FROM custom setting
     */
    public static Date calculateMinimumDays(Date deadline, integer minimumDeadline) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkIncludeWeekends = cs.Include_Weekends__c;
        Integer minDays;
        
        if (minimumDeadline != null && minimumDeadline > 0) {
            minDays = minimumDeadline;
        } else {
            minDays = (cs.Minimum_Deadline__c != null) ? Integer.valueOf(cs.Minimum_Deadline__c) : 0;
        }
        Date lastDate = Date.Today();
        DateTime lastDateTime = Datetime.newInstance(lastDate.year(), lastDate.month(), lastDate.day());
        
        if (checkIncludeWeekends) {
            Set<String> setOffDays = new Set<String>();
            
            for (String str : cs.Days_of_Week__c.split(';')) {
                setOffDays.add(str);
            }
            lastDateTime = lastDateTime.addDays(-1);
            
            while (minDays > 0) {
                lastDateTime = lastDateTime.addDays(1);
                
                if (!setOffDays.contains(lastDateTime.format('EEEE'))) {
                    minDays--;
                }
            }
        } else {
            lastDateTime = lastDateTime.addDays(minDays - 1);
        }
        return Date.newinstance(lastDateTime.year(), lastDateTime.month(), lastDateTime.day());
    }

    /**
     * Method to Check whether deadline is Offday or Not
     */
    public static Boolean isItWeekend(Date deadline) {
        Boolean isItOffDay = false;
        DateTime deadlineDateTime = Datetime.newInstance(deadline.year(), deadline.month(), deadline.day());
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkIncludeWeekends = cs.Include_Weekends__c;
        
        if (checkIncludeWeekends) {
            
            for (String days: cs.Days_of_Week__c.split(';')) {
                
                if (deadlineDateTime.format('EEEE') == days) {
                    isItOffDay = true;
                    break;
                }
            }
        }
        return isItOffDay;
    }

    /**
     * Method to Check Chatter Settings enabled od disabled
     */
    public static Boolean isNativeChatterSetting {
        get {
            return Schema.SObjectType.User.isFeedEnabled();
        }
    }

    /**
     * Method to get Map Content Type Mappings Images Path
     */
    public static Map<String, String> mapContentTypeImagePath {
        get {
            
            if (mapContentTypeImagePath == null) {
                mapContentTypeImagePath = new Map<String, String>();
                
                for (Content_Type_Mapping__c ctm : [SELECT Content_Type_Extension__c, Static_Resource_Image__c 
                                                    FROM Content_Type_Mapping__c LIMIT: limits.getLimitQueryRows()]) {
                    mapContentTypeImagePath.put(ctm.Content_Type_Extension__c, ctm.Static_Resource_Image__c);
                }
            }
            return mapContentTypeImagePath;
        }
        set;
    }
    
    /**
     * Method to get Map Doument Type
     */ 
     public static Map<String, String> mapDocumentPath { 
        get {
            Map<String, String> doctypeMap = new Map<String, String>(); 
            
            doctypeMap.put('UNKNOWN','/assets/icons/doctype/unknown_60.png');
            doctypeMap.put('TEXT', '/assets/icons/doctype/txt_60.png');
            doctypeMap.put('MP4', '/assets/icons/doctype/mp4_60.png');
            doctypeMap.put('CSV', '/assets/icons/doctype/csv_60.png');
            doctypeMap.put('EXCEL', '/assets/icons/doctype/excel_60.png');
            doctypeMap.put('JPG', 'assets/icons/doctype/image_60.png');
            doctypeMap.put('BMP', '/assets/icons/doctype/image_60.png');
            doctypeMap.put('PNG', '/assets/icons/doctype/image_60.png');
            doctypeMap.put('GIF', '/assets/icons/doctype/image_60.png');
            doctypeMap.put('LINK', '/assets/icons/doctype/link_60.png');
            doctypeMap.put('PDF', '/assets/icons/doctype/pdf_60.png');
            doctypeMap.put('POWER_POINT', '/assets/icons/doctype/ppt_60.png');
            doctypeMap.put('RTF', '/assets/icons/doctype/rtf_60.png');
            doctypeMap.put('WAV', '/assets/icons/doctype/audio_60.png');
            doctypeMap.put('MOV', '/assets/icons/doctype/video_60.png'); 
            doctypeMap.put('WORD', '/assets/icons/doctype/word_60.png');
            doctypeMap.put('WORD_X', '/assets/icons/doctype/word_60.png');
            doctypeMap.put('EXCEL_X', '/assets/icons/doctype/excel_60.png');
            doctypeMap.put('POWER_POINT_X', '/assets/icons/doctype/ppt_60.png');
            doctypeMap.put('Reference_Interview', '/assets/icons/doctype/video_60.png');
            doctypeMap.put('ZIP', '/assets/icons/doctype/unknown_60.png');  
            
            return doctypeMap;
        }
        set;
    }
     
    /**
     * Method to Create Map of Language Code & Languge
     */
    public static Map<String, String> mapContentLanguage {
        get {
            
            if (mapContentLanguage == null) {
                mapContentLanguage = new Map<String, String>();
                Schema.DescribeFieldResult field = ContentVersion.Language.getDescribe(); //Values FROM Schema
                List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
                
                for (Schema.PicklistEntry picklistValue : picklistValues) {
                    mapContentLanguage.put(picklistValue.getValue(), picklistValue.getLabel());
                }
            }
            return mapContentLanguage;
        }
        set;
    }

    /**
     * Method to return Namespace
     */
    public static String appNamespace() {
        return ''; 
    }

    /**
     * Method to return Site URL
     */
    public static String getSiteUrl() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        String uniqueUrl = '';
        
        if (appConfig.Site_URL__c != null) {
            uniqueUrl = ((appConfig.Site_URL__c.contains('https://') || appConfig.Site_URL__c.contains('http://')) 
                        ? appConfig.Site_URL__c : 'https://' + appConfig.Site_URL__c);
        }
        return uniqueUrl;
    }

    /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to clean data mapping field records
​ ​ ​ ​ ​*​ ​ ​ @return :​ Updates Data Mapping fields List
    *   @Modified By: Dixita @Aug 2018
    *   #REF-1846
​ ​ ​ ​ ​**/
    public static List<Data_Mapping__c> cleanDataMappingRecords(String objectName, List<Data_Mapping__c> fieldsList) { 
        Map<String,Data_Mapping__c> existingDM =  new Map<String,Data_Mapping__c>();
        Map<String, Schema.SObjectType> objectMap = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = objectMap.get(UtilityController.appNamespace() + objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();       
        List<Data_Mapping__c> recordsToDel = new List<Data_Mapping__c>();
        List<Data_Mapping__c> recordsToUpsert = new List<Data_Mapping__c>();
        Decimal countImp = 1;
        
        
        if (objectName.trim() == 'Reference_Content__c') {  
            Schema.SObjectType objTypeCV = objectMap.get('ContentVersion');
            Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
            Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();  
            Map<String,Data_Mapping__c> existingDMCV =  new Map<String,Data_Mapping__c>();
            
            for (Data_Mapping__c field : fieldsList) {
                
                if (field.Object__c == 'DMReference_Content__c') {
                    
                    if (fieldMap.containsKey(field.Field_API_Name__c.toLowerCase().remove(UtilityController.appNamespace())) && field.Field_API_Name__c != UtilityController.appNamespace() + 'Account__c'
                        && field.Field_API_Name__c != UtilityController.appNamespace() + 'Data_Collector_Name__c' && field.Field_API_Name__c != UtilityController.appNamespace() + 'Data_Collector_Status__c'
                        && field.Field_API_Name__c != UtilityController.appNamespace() + 'Reminder_Date__c' && field.Field_API_Name__c != UtilityController.appNamespace() + 'Opportunity__c'
                        && field.Field_API_Name__c != UtilityController.appNamespace() + 'Number_of_Reminders_Sent__c' && field.Field_API_Name__c != UtilityController.appNamespace() + 'Opportunity_Owner__c'
                        && field.Field_API_Name__c != UtilityController.appNamespace() + 'Content_URL2__c') {
                        
                        if (existingDM.containsKey(field.Field_API_Name__c.toLowerCase()) && existingDM.get(field.Field_API_Name__c.toLowerCase()) != null) {
                            recordsToDel.add(existingDM.get(field.Field_API_Name__c.toLowerCase()));
                        } else {
                            countImp = (field.Required__c != null && field.Required__c && field.Order__c != null && countImp <= field.Order__c) ? field.Order__c + 1 : countImp;
                        }
                        existingDM.put(field.Field_API_Name__c.toLowerCase(),field); 
                    } else {
                        recordsToDel.add(field);
                    }
                } 
            }
            for (Data_Mapping__c field : fieldsList) {
                
                if (field.Object__c == 'DMContentVersion') {
                    
                    if (fieldMapCV.containsKey(field.Field_API_Name__c.toLowerCase().remove(UtilityController.appNamespace())) & !existingDM.containsKey(field.Field_API_Name__c.toLowerCase())) {
                        countImp = (field.Required__c != null && field.Required__c && field.Order__c != null && countImp <= field.Order__c) ? field.Order__c + 1 : countImp;
                        existingDMCV.put(field.Field_API_Name__c.toLowerCase(),field); 
                    } else {
                        recordsToDel.add(field);
                    }
                }
            }
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe(); 
                
                if (field.isCustom() && field.isCreateable() && field.isAccessible() && field.getName() != UtilityController.appNamespace() + 'Account__c'
                    && field.getName() != UtilityController.appNamespace() + 'Data_Collector_Name__c' && field.getName() != UtilityController.appNamespace() + 'Data_Collector_Status__c'
                    && field.getName() != UtilityController.appNamespace() + 'Reminder_Date__c' && field.getName() != UtilityController.appNamespace() + 'Opportunity__c'
                    && field.getName() != UtilityController.appNamespace() + 'Number_of_Reminders_Sent__c' && field.getName() != UtilityController.appNamespace() + 'Opportunity_Owner__c'
                    && field.getName() != UtilityController.appNamespace() + 'Content_URL2__c') {
                    
                    if (existingDM.containsKey(UtilityController.appNamespace() + fieldName) || existingDM.containsKey(fieldName)) {
                        Data_Mapping__c fieldDM = existingDM.containsKey(fieldName) ? existingDM.get(fieldName) : existingDM.get(UtilityController.appNamespace() + fieldName);
                        
                        if (fieldDM.Required__c != (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate())
                                        && field.getName() != 'Id' && field.getName() != UtilityController.appNamespace() + 'Content_URL__c'
                                        && field.getName() != UtilityController.appNamespace() + 'Library_ID__c' 
                                        && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c') {
                            fieldDM.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                            
                            if (fieldDM.Required__c) {
                                fieldDM.Visible__c = true;
                                fieldDM.Order__c = countImp++;
                            } 
                            existingDM.put(fieldDM.Field_API_Name__c.toLowerCase(),fieldDM);
                            recordsToUpsert.add(fieldDM);
                        } else if (fieldDM.Required__c && fieldDM.Order__c == null) {
                            fieldDM.Order__c = countImp++;
                            fieldDM.Visible__c = true;
                            existingDM.put(fieldDM.Field_API_Name__c.toLowerCase(),fieldDM);
                            recordsToUpsert.add(fieldDM);
                        }
                    } else {
                        Data_Mapping__c fieldEntry = new Data_Mapping__c();
                        fieldEntry.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                        fieldEntry.Visible__c = fieldEntry.Required__c;
                        fieldEntry.Order__c = fieldEntry.Required__c ? countImp++ : null;
                        fieldEntry.Object__c = 'DM' + objectName;
                        fieldEntry.Label__c = field.getLabel();
                        fieldEntry.Field_API_Name__c= field.getName();   
                        existingDM.put(fieldEntry.Field_API_Name__c.toLowerCase(),fieldEntry);
                        recordsToUpsert.add(fieldEntry);
                    }
                }
            }

            for (String fieldName : fieldMapCV.keySet()) {
                Schema.DescribeFieldResult field = fieldMapCV.get(fieldName).getDescribe(); 
                
                if (field.isCustom() && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c' && field.isCreateable() && field.isAccessible() && !existingDM.containsKey(fieldName)) {
                      
                    if (existingDMCV.containsKey(fieldName)) {
                        Data_Mapping__c fieldDM = existingDMCV.get(fieldName);
                        
                        if (fieldDM.Required__c != (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate())  
                                        && field.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c') {
                            fieldDM.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                            
                            if (fieldDM.Required__c) {
                                fieldDM.Visible__c = true;
                                fieldDM.Order__c = countImp++;
                            }
                            existingDMCV.put(fieldName,fieldDM);
                            recordsToUpsert.add(fieldDM);
                        } else if (fieldDM.Required__c && fieldDM.Order__c == null) {
                            fieldDM.Order__c = countImp++;
                            fieldDM.Visible__c = true;
                            existingDM.put(fieldDM.Field_API_Name__c.toLowerCase(),fieldDM);
                            recordsToUpsert.add(fieldDM);
                        }
                    } else {
                        Data_Mapping__c fieldEntry = new Data_Mapping__c();
                        fieldEntry.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                        fieldEntry.Visible__c = fieldEntry.Required__c;
                        fieldEntry.Order__c = fieldEntry.Required__c ? countImp++ : null;
                        fieldEntry.Object__c = 'DMContentVersion';
                        fieldEntry.Label__c = field.getLabel();
                        fieldEntry.Field_API_Name__c= field.getName();   
                        existingDMCV.put(fieldName,fieldEntry);
                        recordsToUpsert.add(fieldEntry);
                    }
                }
            }
            fieldsList = existingDM.values();
            fieldsList.addAll(existingDMCV.values());
        } else { 
            
            for (Data_Mapping__c field : fieldsList) {
            
                if (fieldMap.containsKey(field.Field_API_Name__c.toLowerCase().remove(UtilityController.appNamespace()))) {
                    
                    if (existingDM.containsKey(field.Field_API_Name__c.toLowerCase()) && existingDM.get(field.Field_API_Name__c.toLowerCase()) != null) {
                        recordsToDel.add(existingDM.get(field.Field_API_Name__c.toLowerCase()));
                    } else {
                        countImp = (field.Required__c != null && field.Required__c && field.Order__c != null && countImp <= field.Order__c) ? field.Order__c + 1 : countImp;
                    }
                    existingDM.put(field.Field_API_Name__c.toLowerCase(),field); 
                } else {
                    recordsToDel.add(field);
                }
            } 
            
            for (String fieldName : fieldMap.keySet()) {
                Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe(); 
                if (field.isCustom()) {
                    
                    if (existingDM.containsKey(UtilityController.appNamespace() + fieldName) || existingDM.containsKey(fieldName)) {
                        Data_Mapping__c fieldDM = existingDM.containsKey(fieldName) ? existingDM.get(fieldName) : existingDM.get(UtilityController.appNamespace() + fieldName);
                        
                        if (fieldDM.Required__c != (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate())) {
                            fieldDM.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                            
                            if (fieldDM.Required__c) {
                                fieldDM.Visible__c = true;
                                fieldDM.Order__c = countImp++;
                            }
                            existingDM.put(fieldDM.Field_API_Name__c.toLowerCase(),fieldDM);
                            recordsToUpsert.add(fieldDM);
                        }
                    } else {
                        Data_Mapping__c fieldEntry = new Data_Mapping__c();
                        fieldEntry.Required__c = field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate();
                        fieldEntry.Visible__c = fieldEntry.Required__c;
                        fieldEntry.Order__c = fieldEntry.Required__c ? countImp++ : null;
                        fieldEntry.Object__c = 'DM' + objectName;
                        fieldEntry.Label__c = field.getLabel();
                        fieldEntry.Field_API_Name__c = field.getName();   
                        existingDM.put(fieldEntry.Field_API_Name__c.toLowerCase(),fieldEntry);
                        recordsToUpsert.add(fieldEntry);
                    }
                }
            }
            fieldsList = existingDM.values();
        }
        
        
        if (recordsToDel.size() > 0) {
            ConstantsController.shouldDataMappingProcessed = true;          
            delete recordsToDel;    
        }
        if (recordsToUpsert.size() > 0) {
            ConstantsController.shouldDataMappingProcessed = true;     
            upsert recordsToUpsert; 
        }
        if (fieldsList.size() > 0 ) { 
            Map<Decimal,Data_Mapping__c> sortingMap = new Map<Decimal,Data_Mapping__c>();
            Decimal maxOrder = 100;
            for (Data_Mapping__c item: fieldsList) {
                
                if (item.Order__c != null && sortingMap.containsKey(item.Order__c)) {
                
                    for (Decimal order = item.Order__c ; ;order = order + 0.01) {
                        if (!sortingMap.containsKey(order)) {
                            sortingMap.put(order,item);
                            break;
                        } 
                    }
                } else {
                    sortingMap.put(item.Order__c == null ? maxOrder++ : item.Order__c,item);
                }
            }
            List<Decimal> sortList = new List<Decimal>(sortingMap.keySet());
            sortList.sort();
            fieldsList = new List<Data_Mapping__c>();
            for (Decimal key: sortList) {
                fieldsList.add(sortingMap.get(key));
            }
        }
        return fieldsList;
    }


    /**
     * Method to return Community URL
     */
    public static String getCommunityUrl() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        
        if (appConfig.Refedge_Community_URL__c != null) {
            return appConfig.Refedge_Community_URL__c;
        }
        return '';
    }
    
    /**
     * Method to get User mapping
     */
    public static List<User_Mapping__c> getUserMappings(String currentProcess) {
        List<User_Mapping__c> userMappings = [SELECT Id,Order__c,Label__c,Visible__c,Field_API_Name__c,Default_Value__c,Process__c,User__c FROM User_Mapping__c 
                                            WHERE User__c =: Userinfo.getUserId() AND Process__c =: currentProcess ORDER BY Order__c NULLS LAST];
        return userMappings;
    }
    /**
     * Method to return Site URL
     */
    public static String getMicrositeTemplete() {
        List<User_Mapping__c> userMappings = [SELECT Id,Default_Value__c,Process__c,User__c FROM User_Mapping__c 
                                        WHERE User__c =: Userinfo.getUserId() AND Process__c = 'Invitation'];
                                        
        if (userMappings != null && userMappings.size() > 0 && userMappings[0].Default_Value__c != null 
                                && userMappings[0].Default_Value__c != '') {
            List<Microsite__c> microstie = [SELECT Id FROM Microsite__c WHERE Id = : userMappings[0].Default_Value__c];
            
            if (microstie.size() > 0) {
                return userMappings[0].Default_Value__c;
            } else {
                return '';
            }
        }
        return '';
    }

    /**
     * Method to get Company logo document id
     */
    public static String getCompanyLogo() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        
        if (appConfig.Company_logo_document_id__c != null) {
            return appConfig.Company_logo_document_id__c;
        }
        return '';
    }

    /**
     * Method to get Footer document id
     */
    public static String getCompanyFooter() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        
        if (appConfig.Footer_logo_document_id__c != null) {
            return appConfig.Footer_logo_document_id__c;
        }
        return '';
    }
    
    /**
     * Method to get User License
     * Modified By: Rekha @12 May 2017 regarding #843
     */
    public static Boolean isRefedgeUserLicense;
    public static Boolean isRefedgeUserLicense() {
        
        if (isRefedgeUserLicense == null) {
            //re #932
            if (CRUDAndFLSCheckController.sObjectsMap.containsKey('UserPackageLicense') 
                        && CRUDAndFLSCheckController.sObjectsMap.get('UserPackageLicense') != null) {

                if (UtilityController.appNamespace() != '') {
                    List<PackageLicense> pkgLicenses = [SELECT Id, AllowedLicenses FROM PackageLicense WHERE NamespacePrefix = 'refedge'];
                    List<UserPackageLicense> userLicenses = [SELECT Id FROM UserPackageLicense WHERE UserId = : Userinfo.getUserId() 
                                                        AND PackageLicense.NamespacePrefix = 'refedge'];

                    if (userLicenses.size() > 0) {
                        isRefedgeUserLicense = true;
                    } else {
                        isRefedgeUserLicense = false;

                        if (pkgLicenses != null && pkgLicenses.size() > 0 && pkgLicenses[0].AllowedLicenses == -1) {
                            isRefedgeUserLicense = true;
                        }
                    }
                } else {
                    isRefedgeUserLicense = true;
                }
            } else {
                isRefedgeUserLicense = false;
            }
        }
        return isRefedgeUserLicense;
    }
    
    /**
     * Method to Data Mapping Trigger
     */
    public static boolean getDataMappingTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        Boolean checkTrigger = (appConfig.Data_Mapping_Trigger__c == null ? true : appConfig.Data_Mapping_Trigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to Product Trigger
     */
    public static boolean getProductTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.ProductTrigger__c == null ? false : appConfig.ProductTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to Account Trigger
     */
    public static boolean getAccountTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.AccountTrigger__c == null ? false : appConfig.AccountTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to Account Trigger
     */
    public static boolean getLeadTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.LeadTrigger__c == null ? false : appConfig.LeadTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to Contact Trigger
     */
    public static boolean getContactTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.ContactTrigger__c == null ? false : appConfig.ContactTrigger__c );
        return checkTrigger;
    }
    
    /**
     * Method to Content Trigger
     */
    public static boolean getContentTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.ContentTrigger__c == null ? false : appConfig.ContentTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to tOpportunity Trigger
     */
    public static boolean getOpportunityTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.OpportunityTrigger__c == null ? false : appConfig.OpportunityTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to OpportunityProduct Trigger
     */
    public static boolean getOpportunityProductTrigger() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        boolean checkTrigger = (appConfig.OpportunityProductTrigger__c == null ? false : appConfig.OpportunityProductTrigger__c);
        return checkTrigger;
    }
    
    /**
     * Method to get Guest User Id
     */
    public static Set<String> getGuestUserId() {
        Set<String> userIds = new Set<String>();
        
        for (User user : WithoutSharingHelperController.getGuestUserList()) {
            userIds.add(user.Id);
        }
        return userIds;
    }
    
    /**
     * Method to sendEmailNotification for Batch failed
     */
    public static void sendEmailNotification(List<String> listOfFailedRecords, String Mode) {
        
        if ((listOfFailedRecords != NULL && listOfFailedRecords.size() > 0)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { 'referenceedge@point-of-reference.com' };
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('RefEdge Support');
            mail.setSubject(Mode);
            String mailBody = 'Failed records are: \n' + listOfFailedRecords;
            mailBody = mailBody + '\n Organization Name: ' + Userinfo.getOrganizationName() + '\n Organization Id: ' 
                                        + Userinfo.getOrganizationId() + '\n\n Please do not reply to this mail.';
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }

    /**
     * Method to add days for Rewards Expritation
     */
    public static Date rewardsExpritationDate(Custom_Settings__c cs) {
        Date expirationDate;
        Integer fiscalYearStartMonth = (cs.Organization_FiscalYearStartMonth__c != null 
                                        ? Integer.valueOf(cs.Organization_FiscalYearStartMonth__c) : 1);
                                        
        if (cs.Expire_Rewards__c && cs.Expiration_Timeframe__c != null) {
            
            if (cs.Expiration_Timeframe__c.contains('days')) { //When 'x' days FROM award Date
                ExpirationDate = Date.Today() + Integer.ValueOf(cs.Expiration_Days__c);
            } else if (cs.Expiration_Timeframe__c.contains('CY')) {
                
                if (cs.Expiration_Timeframe__c.contains('current')) { //When end of current CY
                    ExpirationDate = Date.newInstance(Date.Today().year(), 12, 31);
                } else { //When end of NEXT CY
                    ExpirationDate = Date.newInstance(Date.Today().year() + 1, 12, 31);
                }
            } else if (cs.Expiration_Timeframe__c.contains('FY')) {
                
                if (cs.Expiration_Timeframe__c.contains('current')) { //When end of current FY
                    ExpirationDate = Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1) + 
                                    (Integer.valueOf(Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1).daysBetween(
                                                    Date.newInstance(Date.Today().year() + 1, fiscalYearStartMonth, 1))) - 1);
                } else { //When end of NEXT FY
                    ExpirationDate = Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1) + 
                                    (Integer.valueOf(Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1).daysBetween(
                                                    Date.newInstance(Date.Today().year() + 2, fiscalYearStartMonth, 1))) - 1);
                }
            }
        }
        return expirationDate;
    }
    
    /**
     * Method to add days for Rewards Expritation
     */
    public static Date salesRewardsExpritationDate(Custom_Settings__c cs) {
        Date expirationDate;
        Integer fiscalYearStartMonth = (cs.Organization_FiscalYearStartMonth__c != null 
                                        ? Integer.valueOf(cs.Organization_FiscalYearStartMonth__c) : 1);
        
        if (cs.Expire_Sales_Rewards__c && cs.Sales_Expiration_Timeframe__c != null) {
            
            if (cs.Sales_Expiration_Timeframe__c.contains('days')) { //When 'x' days FROM award Date
                ExpirationDate = Date.Today() + Integer.ValueOf(cs.Sales_Expiration_Days__c);
            } else if (cs.Sales_Expiration_Timeframe__c.contains('CY')) {
                
                if (cs.Sales_Expiration_Timeframe__c.contains('current')) { //When end of current CY
                    ExpirationDate = Date.newInstance(Date.Today().year(), 12, 31);
                } else { //When end of NEXT CY
                    ExpirationDate = Date.newInstance(Date.Today().year() + 1, 12, 31);
                }
            } else if (cs.Sales_Expiration_Timeframe__c.contains('FY')) {
                
                if (cs.Sales_Expiration_Timeframe__c.contains('current')) { //When end of current FY
                    ExpirationDate = Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1) + 
                                        (Integer.valueOf(Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1).daysBetween(
                                                Date.newInstance(Date.Today().year() + 1, fiscalYearStartMonth, 1))) - 1);
                } else { //When end of NEXT FY
                    ExpirationDate = Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1) + 
                                        (Integer.valueOf(Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1).daysBetween(
                                                Date.newInstance(Date.Today().year() + 2, fiscalYearStartMonth, 1))) - 1);
                }
            }
        }
        return expirationDate;
    }

    /**
     * Ticket : #707
     * Method to Check RBI Records
     * Created By: Rekha
     */
    /*public static Set<String> checkRBI(String accId, String conId, Boolean isAccountInsert) {
        Set<String> rbiIds = new Set<String>();
        
        if (accId != null && accId != '') {
            Boolean isAccountRBI = false;
            Boolean isContactRBI = false;
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            List<Reference_Basic_Information__c> insertRBI = new List<Reference_Basic_Information__c>();
            // changes for #366 - getching rbis for the shared contacts as well
            List<Reference_Basic_Information__c> tempRBIList = new List<Reference_Basic_Information__c>();
            
            if (conId != null && conId != '') {
                tempRBIList = [SELECT Contact__c, Account__c, Is_Referenceable__c
                                FROM Reference_Basic_Information__c
                                WHERE Account__c = :accId
                                OR Contact__c = :conId];
            } else {
                tempRBIList = [SELECT Contact__c, Account__c, Is_Referenceable__c
                                FROM Reference_Basic_Information__c
                                WHERE Account__c = :accId];
            }

            for (Reference_Basic_Information__c rbiCon : tempRBIList) {
                
                if (rbiCon.Contact__c == null) {
                    isAccountRBI = true;
                }
                
                if (conId != null && conId != '' && rbiCon.Contact__c != null && rbiCon.Contact__c == conId) {
                    isContactRBI = true;
                }
            }
            
            if (conId != null && conId != '' && !isContactRBI) {
                insertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = accId, 
                            Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true));
            }
            
            if (!isAccountInsert && (conId == null || conId == '') && !isAccountRBI) {
                insertRBI.add(new Reference_Basic_Information__c(Account__c = accId, 
                            Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true));
            } else if (isAccountInsert && !isAccountRBI) {
                insertRBI.add(new Reference_Basic_Information__c(Account__c = accId, 
                            Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true));
            }
            
            if (insertRBI.size() > 0) {
                insertRBI = WithoutSharingHelperController.upsertRBI(insertRBI);
                
                for (Reference_Basic_Information__c rbi : insertRBI) {
                    rbiIds.add(rbi.Id);
                }
            }
        }
        return rbiIds;
    }*/
    /**
     * Ticket : #707
     * Method to Check RBI Records
     * Created By: Rekha
     */
    public static Set<String> checkRBI(String accId, String conId, String conAccId, Boolean isAccountInsert) {
        Set<String> rbiIds = new Set<String>();
        
        if (accId != null && accId != '') {
            Boolean isAccountRBI = false;
            Boolean isContactRBI = false;
            Reference_Basic_Information__c accRBI;
            Reference_Basic_Information__c conRBI;
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            List<Reference_Basic_Information__c> insertRBI = new List<Reference_Basic_Information__c>();
            
            for (Reference_Basic_Information__c rbiCon : WithoutSharingHelperController.getRefProfiles(accId, conId)) {
                
                if (rbiCon.Contact__c == null) {
                    isAccountRBI = true;
                    accRBI = rbiCon;
                }
                
                if (conId != null && conId != '' && rbiCon.Contact__c != null && rbiCon.Contact__c == conId) {
                    isContactRBI = true;
                    conRBI = rbiCon;
                }
            }
            
            if (conId != null && conId != '') {
                
                if (isContactRBI && (!conRBI.Is_Referenceable__c)) {
                    conRBI.Is_Referenceable__c = true;
                    conRBI.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                    conRBI.Reference_Program_Candidate__c = false;
                    insertRBI.add(conRBI);
                } else if (!isContactRBI) {
                    insertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = conAccId, 
                                                                Referenceability_Status__c = cs.Default_Referenceablity_Status__c, 
                                                                Is_Referenceable__c = true));
                }
            }
            
            if (!isAccountInsert && (conId == null || conId == '')) {
                
                if (isAccountRBI && (!accRBI.Is_Referenceable__c)) {
                    accRBI.Is_Referenceable__c = true;
                    accRBI.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                    accRBI.Reference_Program_Candidate__c = false;
                    insertRBI.add(accRBI);
                } else if (!isAccountRBI) {
                    insertRBI.add(new Reference_Basic_Information__c(Account__c = accId, 
                                                        Referenceability_Status__c = cs.Default_Referenceablity_Status__c, 
                                                        Is_Referenceable__c = true));
                }
            } else if (isAccountInsert) {
                
                if (isAccountRBI && (!accRBI.Is_Referenceable__c)) {
                    accRBI.Is_Referenceable__c = true;
                    accRBI.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                    accRBI.Reference_Program_Candidate__c = false;
                    insertRBI.add(accRBI);
                } else if (!isAccountRBI) {
                    insertRBI.add(new Reference_Basic_Information__c(Account__c = accId, 
                                                        Referenceability_Status__c = cs.Default_Referenceablity_Status__c, 
                                                        Is_Referenceable__c = true));
                }
            }
            
            if (insertRBI.size() > 0) {
                insertRBI = WithoutSharingHelperController.upsertRBI(insertRBI);
                
                for (Reference_Basic_Information__c rbi : insertRBI) {
                    rbiIds.add(rbi.Id);
                }
            }
        }
        return rbiIds;
    }
    
    /**
     * Ticket : #707
     * Method to Check RBI Records
     * Created By: Rekha
     */
    public static void checkRBI(String accId, String conId, Boolean makeAccountMember, Boolean makeContactMember, 
                                    Boolean makeAccountCandidate, 
                                    Boolean makeContactCandidate) {

        if (accId != null && accId != '') {
            Boolean isAccountRBI = false;
            Boolean isContactRBI = false;
            Reference_Basic_Information__c accRBI;
            Reference_Basic_Information__c conRBI;
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            List<Reference_Basic_Information__c> upsertRBI = new List<Reference_Basic_Information__c>();
            
            for (Reference_Basic_Information__c rbiCon : WithoutSharingHelperController.getRefProfiles(accId, conId)) {
                
                if (rbiCon.Contact__c == null) {
                    isAccountRBI = true;
                    accRBI = rbiCon;
                }
                
                if (conId != null && conId != '' && rbiCon.Contact__c != null && rbiCon.Contact__c == conId) {
                    isContactRBI = true;
                    conRBI = rbiCon;
                }
            }
            
            if (conId != null && conId != '') {
                
                if (isContactRBI && (!conRBI.Is_Referenceable__c)) {
                    
                    if (makeContactCandidate) {
                        conRBI.Reference_Program_Candidate__c = true;
                        upsertRBI.add(conRBI);
                    } else if (makeContactMember) {
                        conRBI.Is_Referenceable__c = true;
                        conRBI.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        conRBI.Reference_Program_Candidate__c = false;
                        upsertRBI.add(conRBI);
                    }
                } else if (!isContactRBI) {
                    
                    if (makeContactCandidate) {
                        upsertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = accId, Reference_Program_Candidate__c = true));
                    } else if (makeContactMember) {
                        upsertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = accId, 
                                                    Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true));
                    }
                }
            }
            
            if (accId != null && accId != '') {
                
                if (isAccountRBI && (!accRBI.Is_Referenceable__c)) {
                    
                    if (makeAccountCandidate) {
                        accRBI.Reference_Program_Candidate__c = true;
                        upsertRBI.add(accRBI);
                    } else if (makeAccountMember) {
                        accRBI.Is_Referenceable__c = true;
                        accRBI.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        accRBI.Reference_Program_Candidate__c = false;
                        upsertRBI.add(accRBI);
                    }
                } else if (!isAccountRBI) {
                    
                    if (makeAccountCandidate) {
                        upsertRBI.add(new Reference_Basic_Information__c(Account__c = accId, Reference_Program_Candidate__c = true));
                    } else if (makeAccountMember) {
                        upsertRBI.add(new Reference_Basic_Information__c(Account__c = accId, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, 
                                                                        Is_Referenceable__c = true));
                    }
                }
            }
            
            if (upsertRBI.size() > 0) {
                WithoutSharingHelperController.upsertRBI(upsertRBI);
            }
        }
    }
    /**
     * Ticket : #707
     * Method to Check RBI Records
     * Created By: Rekha
     */
    public static void checkRBI(Set<String> accIdList,
                                    String conId,
                                    Boolean makeAccountMember,
                                    Boolean makeContactMember,
                                    Boolean makeAccountCandidate,
                                    Boolean makeContactCandidate) {
        
        if (accIdList != null && accIdList.size() > 0) {
            Boolean isContactRBI = false;
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            Reference_Basic_Information__c conRBIObj = new Reference_Basic_Information__c();
            List<Reference_Basic_Information__c> upsertRBI = new List<Reference_Basic_Information__c>();
            Map<String, Reference_Basic_Information__c> accRBIMap = new Map<String, Reference_Basic_Information__c>();
            Map<Id, Boolean> accRBIExistsMap = new Map<Id, Boolean>();
            
            for (String accId : accIdList) {
                accRBIExistsMap.put(accId, false);
            }
            
            for (Reference_Basic_Information__c RBIObj : WithoutSharingHelperController.getRefProfiles(accIdList, conId)) {
                
                if (RBIObj.Contact__c == null) {
                    accRBIExistsMap.put(RBIObj.Account__c, true);
                    accRBIMap.put(RBIObj.Account__c, RBIObj);
                }
                
                if (conId != null && conId != '' && RBIObj.Contact__c != null && RBIObj.Contact__c == conId) {
                    isContactRBI = true;
                    conRBIObj = RBIObj;
                }
            }
            if (conId != null && conId != '') {
                
                if (isContactRBI && !conRBIObj.Is_Referenceable__c) {
                    
                    if (makeContactCandidate) {
                        conRBIObj.Reference_Program_Candidate__c = true;
                        upsertRBI.add(conRBIObj);
                    } else if (makeContactMember) {
                        conRBIObj.Is_Referenceable__c = true;
                        conRBIObj.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        conRBIObj.Reference_Program_Candidate__c = false;
                        upsertRBI.add(conRBIObj);
                    }
                } else if (!isContactRBI) {
                    String tempAccId = [SELECT AccountId FROM Contact WHERE Id = :conId].AccountId;
                    
                    if (makeContactCandidate) {
                        upsertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = tempAccId, Reference_Program_Candidate__c = true));
                    } else if (makeContactMember) {
                        upsertRBI.add(new Reference_Basic_Information__c(Contact__c = conId, Account__c = tempAccId, 
                                                            Referenceability_Status__c = cs.Default_Referenceablity_Status__c, Is_Referenceable__c = true));
                    }
                }
            }
            
            for (String accId : accRBIExistsMap.keySet()) {
                
                if (accRBIExistsMap.get(accId)) {
                    
                    if (makeAccountCandidate && !accRBIMap.get(accId).Is_Referenceable__c) {
                        accRBIMap.get(accId).Reference_Program_Candidate__c = true;
                        upsertRBI.add(accRBIMap.get(accId));
                    } else if (makeAccountMember && !accRBIMap.get(accId).Is_Referenceable__c) {
                        accRBIMap.get(accId).Is_Referenceable__c = true;
                        accRBIMap.get(accId).Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
                        accRBIMap.get(accId).Reference_Program_Candidate__c = false;
                        upsertRBI.add(accRBIMap.get(accId));
                    }
                } else {
                    
                    if (makeAccountCandidate) {
                        upsertRBI.add(new Reference_Basic_Information__c(Account__c = accId, Reference_Program_Candidate__c = true));
                    } else if (makeAccountMember) {
                        upsertRBI.add(new Reference_Basic_Information__c(Account__c = accId, Referenceability_Status__c = cs.Default_Referenceablity_Status__c, 
                                                                        Is_Referenceable__c = true));
                    }
                }
            }
            
            if (upsertRBI.size() > 0) {
                WithoutSharingHelperController.upsertRBI(upsertRBI);
            }
        }
    }
    /**
     * Method to delete attributes associated to account,contact and refContent
     */
    public static void deleteAttributesInstance(Set<Id> attributesToBeDeleted) {
        List<Account_Attribute__c> accAttsDelete = new List<Account_Attribute__c>();
        List<Contact_Attribute__c> conAttsDelete = new List<Contact_Attribute__c>();
        List<Content_Attribute__c> contAttsDelete = new List<Content_Attribute__c>();
        conAttsDelete = WithoutSharingHelperController.getContactAttribute5(attributesToBeDeleted);
        
        if (conAttsDelete.size() > 0) {
            WithoutSharingHelperController.deleteContactAttributes(conAttsDelete);
        }
        contAttsDelete = WithoutSharingHelperController.fetchContentAttributeinUtility(attributesToBeDeleted);
        
        if (contAttsDelete.size() > 0) {
            WithoutSharingHelperController.deleteContentAtt(contAttsDelete);
        }
        accAttsDelete = WithoutSharingHelperController.getAccountAttribute5(attributesToBeDeleted);
        
        if (accAttsDelete.size() > 0) {
            WithoutSharingHelperController.deleteAccountAttributes(accAttsDelete);
        }
    }
    
    /**
     * Method to check attribute mapping of any object
     */
    public static void checkAttributeMappingEdit(Set<Id> attMappingIds, String ObjectName) {
        
        if (ConstantsController.runCheckAttributeMappingEditMethod) {
            
            try {
                
                if (ObjectName == 'Account') {
                    ConstantsController.attMappingForAccount = false;
                }
                
                if (ObjectName == 'Contact') {
                    ConstantsController.attMappingForContact = false;
                }
                Map<String, List<Schema.PicklistEntry>> attMappingPicklistMap = new Map<String, List<Schema.PicklistEntry>>();
                Map<Id, List<Attribute__c>> attMappingAttributes = new Map<Id, List<Attribute__c>>();
                List<Attribute__c> newAttributes = new List<Attribute__c>();
                List<Schema.PicklistEntry> pick_list_values = new List<Schema.PicklistEntry>();
                Set<String> attributesExisting = new Set<String>();
                String parentAttId;
                boolean attributePresent = false;
                Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(ObjectName); //FROM the Object Api name retrieving the SObject
                Sobject Object_name = targetType.newSObject();
                Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
                Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
                Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
                Map<Id, Attribute__c> attMapingParentAttribute = new Map<Id, Attribute__c>();
                Map<String, String> mappingAttribute = new Map<String, String>();
                Map<String, String> mappingAttFilter = new Map<String, String>();
                Set<String> childAttributeToFindLabel = new Set<String>();
                Map<String, String> parentLabelMap = new Map<String, String>();
                
                //find the attributes present which are mapped FROM the AttributeMapping
                for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI2(attMappingIds)) {  
                    //map contains the attribute level 1 associated with that mapping record
                    boolean attPresent = false;
                    
                    for (Attribute__c atts : att.Attributes__r) {
                        attPresent = true;
                        break;
                    }
                    
                    if (attPresent) {
                        
                        if (!attMappingAttributes.containsKey(att.Attribute_Mapping__r.Id)) {
                            attMappingAttributes.put(att.Attribute_Mapping__r.Id, new List<Attribute__c>());
                        }
                        boolean chkParent = true;
                        
                        for (Attribute__c atts: att.Attributes__r) {
                            attMappingAttributes.get(att.Attribute_Mapping__r.Id).add(atts);
                            
                            if (chkParent) {
                                childAttributeToFindLabel.add(atts.Id);
                                mappingAttribute.put(atts.Id, att.Attribute_Mapping__r.Id);
                                chkParent = false;
                            }
                        }
                    } else {
                        attMappingAttributes.put(att.Attribute_Mapping__r.Id, new List<Attribute__c>());
                    }
                    //grab the list of picklist values for the passed field on the sobject
                    pick_list_values = field_map.get(att.Attribute_Mapping__r.Field_Api_Name__c).getDescribe().getPickListValues(); 
                    attMappingPicklistMap.put(att.Attribute_Mapping__r.Id, pick_list_values);
                    attMapingParentAttribute.put(att.Attribute_Mapping__r.Id, att);
                }
                
                if (childAttributeToFindLabel.size() > 0) {
                    
                    for (Attributes_Labels__c attLabel : WithoutSharingHelperController.getAttributeLabelsForUpdateRBI(childAttributeToFindLabel)) {
                        
                        if (mappingAttribute.containsKey(attLabel.Attribute__c)) {
                            mappingAttFilter.put(mappingAttribute.get(attLabel.Attribute__c), attLabel.label__c);
                        }
                    }
                }
                
                for (String attMapId : attMappingPicklistMap.keySet()) {
                    
                    for (Schema.PicklistEntry a : attMappingPicklistMap.get(attMapId)) { //for all values in the picklist list
                        attributePresent = false;
                        
                        for (Attribute__c att : attMappingAttributes.get(attMapId)) {
                            
                            if (mappingAttFilter.containsKey(attMapId)) {
                                parentLabelMap.put(att.parent__c, mappingAttFilter.get(attMapId));
                            }
                            parentAttId = att.parent__c;
                            
                            if (att.Name == a.getValue()) {
                                attributePresent = true;
                                attributesExisting.add(att.Id);
                            }
                        }
                        
                        //if the picklist name is not present as attribute den create it
                        if (!attributePresent
                                    && (attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Auto_add__c
                                        || attMapingParentAttribute.get(attMapId).Attribute_Mapping__r.Auto_update__c)) {
                            newAttributes.add(new Attribute__c(name = a.getValue(), Parent__c = parentAttId));
                        }
                    }
                }
                
                if (attMappingPicklistMap != null && attMappingPicklistMap.size() > 0) {
                    //if the attributes are not present in the picklist values den delete the attribute
                    List<Attribute__c> attToBeDeleted = WithoutSharingHelperController.getAttributesToBeDeleted(attributesExisting, attMappingPicklistMap);
                    
                    if (attToBeDeleted.size() > 0) {
                        Set<Id>  delAtts = new Set<Id>();
                        
                        for (Attribute__c att : attToBeDeleted) {
                            delAtts.add(att.Id);
                        }
                        UtilityController.deleteAttributesInstance(delAtts);
                        WithoutSharingHelperController.deleteAttributefromUtility(attToBeDeleted);
                    }
                }
                
                if (newAttributes.size() > 0) {
                    WithoutSharingHelperController.insertAttributesForUpdateRBI(newAttributes);
                    List<Attributes_Labels__c> attLabels = new List<Attributes_Labels__c>();
                    
                    for (Attribute__c att : newAttributes) {
                        
                        if (parentLabelMap.containsKey(att.Parent__c)) {
                            attLabels.add(new Attributes_Labels__c(Attribute__c = att.Id,
                                                                    Label__c = parentLabelMap.get(att.Parent__c)));
                        }
                    }
                    
                    if (attLabels.size() > 0) {
                        WithoutSharingHelperController.insertAttributeLabelsForUpdateRBI(attLabels);
                    }
                }
            } catch (Exception e) {
                throw e;
            }
        }
    }
    
    public static Reference_Basic_Information__c setFiltersForAccount(Reference_Basic_Information__c rbi, List<Account_Attribute__c> attList, 
                                                Map<String, Set<String>> attLabel,Map<String, String> attLabelName){
        String attributes = '';
        String attributeIds = '';
        Map<String, String> labelIds = new Map<String, String>();
        Set<String> associatedAttributes = new Set<String>();
        
        for (Account_Attribute__c a : attList) {
            
            if (attLabel.get(a.Attribute__c) != null) {
                labelIds.put(a.Attribute__c, attLabelName.get(a.Attribute__c));
            }
                
            if (attributes == '') {
                attributes = a.Attribute__r.Name;
                attributeIds = a.Attribute__c;
                associatedAttributes.add(a.Attribute__c);
            } else { 
                
                if (!associatedAttributes.contains(a.Attribute__c)) {
                    attributes = attributes + ', ' + a.Attribute__r.Name;
                    associatedAttributes.add(a.Attribute__c);
                    attributeIds = attributeIds + ',' + a.Attribute__c;
                }
            }
        }
        String labels1 = '';
        String labels2 = '';
        String LabelNames = '';
        
        for (String att: labelIds.keySet()) {
            
            for (String label : attLabel.get(att)) {
                
                if (labels1 == '') {
                    labels1 = label;
                } else {
                    
                    if (!labels1.contains(label) &&  (255 - labels1.length()) > label.length()) {
                        labels1 = labels1 + ',' + label;
                    } else {
                        
                        if (!labels1.contains(label) &&  labels2 == '') {
                            labels2 = label;
                        } else if (!labels1.contains(label) &&  !labels2.contains(label) &&  (255 - labels2.length()) > label.length()) {
                            labels2 = labels2 + ',' + label;
                        }
                    }
                }
            }
            
            if (LabelNames == '') {
                LabelNames = labelIds.get(att);
            } else if (!LabelNames.contains(labelIds.get(att))) {
                LabelNames += ', ' + labelIds.get(att);
            }
        }
        
        if (rbi.Attributes__c != attributes || rbi.Attribute_Ids__c != attributeIds
                    || rbi.Label_Ids1__c != labels1 || rbi.Label_Ids2__c != labels2 || rbi.Parent_Attributes__c != LabelNames) {
            rbi.Attributes__c = attributes;
            rbi.Attribute_Ids__c = attributeIds;
            rbi.Label_Ids1__c = labels1;
            rbi.Label_Ids2__c = labels2;
            rbi.Parent_Attributes__c = LabelNames;
            rbi.Last_Att_Ref_Update__c = dateTime.now();
            rbi.Att_Ref_Last_Update_By__c = Userinfo.getUserId();
            //added regarding ticket #623
            rbi.Attribute_Count__c = attList.size();
            
            if (UserInfo.getUserId() == rbi.Profile_Update_Owner__c || UserInfo.getUserId() == rbi.Reference_Owner__c || 
                        UserInfo.getUserId() == rbi.Account__r.OwnerId){
                rbi.Last_Refresh_Date__c = DateTime.now();
            }
        }
        return rbi;
    }
    
    public static Reference_Basic_Information__c setFiltersForContact(Reference_Basic_Information__c rbi, List<Contact_Attribute__c> attList, 
                                        Map<String, Set<String>> attLabel,Map<String, String> attLabelName){
        String attributes = '';
        String attributeIds = '';
        Map<String, String> labelIds = new Map<String, String>();
        Set<String> associatedAttributes = new Set<String>();
        
        for (Contact_Attribute__c a : attList) {
            
            if (attLabel.get(a.Attribute__c) != null) {
                labelIds.put(a.Attribute__c, attLabelName.get(a.Attribute__c));
            }
            
            if (attributes == '') {
                attributes = a.Attribute__r.Name;
                attributeIds = a.Attribute__c;
                associatedAttributes.add(a.Attribute__c);
            } else{ 
                
                if (!associatedAttributes.contains(a.Attribute__c)) {
                    attributes = attributes + ', ' + a.Attribute__r.Name;
                    associatedAttributes.add(a.Attribute__c);
                    attributeIds = attributeIds + ',' + a.Attribute__c;
                }
            }
        }
        String labels1 = '';
        String labels2 = '';
        String LabelNames = '';
        
        for (String att : labelIds.keySet()) {
            
            for (String label : attLabel.get(att)) {
                
                if (labels1 == '') {
                    labels1 = label;
                } else {
                    
                    if (!labels1.contains(label) &&  (255 - labels1.length()) > label.length()) {
                        labels1 = labels1 + ',' + label;
                    } else {
                        
                        if (!labels1.contains(label) && labels2 == '') {
                            labels2 = label;
                        } else if (!labels1.contains(label) && !labels2.contains(label) &&  (255 - labels2.length()) > label.length()) {
                            labels2 = labels2 + ',' + label;
                        }
                    }
                }
            }
            
            if (LabelNames == '') {
                LabelNames = labelIds.get(att);
            } else if (!LabelNames.contains(labelIds.get(att))) {
                LabelNames += ', ' + labelIds.get(att);
            }
        }
        
        if (rbi.Attributes__c != attributes || rbi.Attribute_Ids__c != attributeIds
                    || rbi.Label_Ids1__c != labels1 || rbi.Label_Ids2__c != labels2 || rbi.Parent_Attributes__c != LabelNames) {
            rbi.Attributes__c = attributes;
            rbi.Attribute_Ids__c = attributeIds;
            rbi.Label_Ids1__c = labels1;
            rbi.Label_Ids2__c = labels2;
            rbi.Parent_Attributes__c = LabelNames;
            //added regarding ticket #623
            rbi.Attribute_Count__c = attList.size();
            // added for REF-2058 - Gaurav Saini (9 Jan, 2018)
            rbi.Last_Att_Ref_Update__c = dateTime.now();
            rbi.Att_Ref_Last_Update_By__c = Userinfo.getUserId();
            
            if (UserInfo.getUserId() == rbi.Profile_Update_Owner__c || UserInfo.getUserId() == rbi.Reference_Owner__c || 
                        UserInfo.getUserId() == rbi.Contact__r.OwnerId){
                rbi.Last_Refresh_Date__c = DateTime.now();
            }
        }
        return rbi;
    }
    
    public static void isUserProfileExist(Id userId) {
        List<User_Profile__c> userProfile = [SELECT id FROM User_Profile__c WHERE User__c =: userId];
        
        if (userProfile.size() == 0) {
            insert new User_Profile__c(User__c = userId, Available_Points__c = 0, Lifetime_Points__c = 0);
        }
    }
    
   /**
     * Method to Check and create user profile if not exist  
     * added for #627 by Rajesh (30 Dec, 2016)
     * Modified by : Rajesh (13 Jan 2017)
     */
    public static void isUserProfileExist(Set<Id> userIds) { 
        List<User_Profile__c> profiles = new List<User_Profile__c>();
        
        for (User user : [SELECT Id FROM User WHERE Id IN (SELECT User__c FROM User_Profile__c WHERE User__c IN : userIds) 
                        LIMIT : limits.getLimitQueryRows()]) { 
             userIds.remove(user.Id);
        } 
        
        for (Id userId : userIds) {
            profiles.add(new User_Profile__c(User__c = userId, Available_Points__c = 0, Lifetime_Points__c = 0));
        } 
        
        if (profiles.size() > 0) {
            insert profiles;
        } 
    }  

    /**
     * Method to create Help Assistant Records
     * added for #1861 by Dixita (Aug, 2018)
     */
    public static void helpAssistant(List<String> pages) { 
        List<Data_Mapping__c> insertList = new List<Data_Mapping__c>();

        for (String pageName : pages) { 
            //RefSearch Classic
            if (pageName == appNamespace() + 'RfSearchPage') {
                List<Data_Mapping__c> rfSearchPage = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = Label.Reference_Search_Assistant_Header;//Title
                step.Label__c = Label.Reference_Search_Assistant_Header;//Title
                step.Default__c = Label.Reference_Search_Assistant_Value;//Default
                step.DC_Message__c = Label.Reference_Search_Assistant_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 1;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Using_Search_Filters_Header;//Title
                step.Label__c = Label.Using_Search_Filters_Header;//Title
                step.Default__c = Label.Using_Search_Filters_Value;//Default
                step.DC_Message__c = Label.Using_Search_Filters_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 2;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Viewing_All_Filters_Header;//Title
                step.Label__c = Label.Viewing_All_Filters_Header;//Title
                step.Default__c = Label.Viewing_All_Filters_Value;//Default
                step.DC_Message__c = Label.Viewing_All_Filters_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 3;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Using_Keywords_Header;//Title
                step.Label__c = Label.Using_Keywords_Header;//Title
                step.Default__c = Label.Using_Keywords_Value;//Default
                step.DC_Message__c = Label.Using_Keywords_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 4;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Getting_More_Information_Header;//Title
                step.Label__c = Label.Getting_More_Information_Header;//Title
                step.Default__c = Label.Getting_More_Information_Value;//Default
                step.DC_Message__c = Label.Getting_More_Information_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 5;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Viewing_More_Results_Header;//Title
                step.Label__c = Label.Viewing_More_Results_Header;//Title
                step.Default__c = Label.Viewing_More_Results_Value;//Default
                step.DC_Message__c = Label.Viewing_More_Results_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 6;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Making_Selections_Header;//Title
                step.Label__c = Label.Making_Selections_Header;//Title
                step.Default__c = Label.Making_Selections_Value;//Default
                step.DC_Message__c = Label.Making_Selections_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 7;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Requesting_the_Use_of_an_Account_Header;//Title
                step.Label__c = Label.Requesting_the_Use_of_an_Account_Header;//Title
                step.Default__c = Label.Requesting_the_Use_of_an_Account_Value;//Default
                step.DC_Message__c = Label.Requesting_the_Use_of_an_Account_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 8;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Understanding_Alerts_Header;//Title
                step.Label__c = Label.Understanding_Alerts_Header;//Title
                step.Default__c = Label.Understanding_Alerts_Value;//Default
                step.DC_Message__c = Label.Understanding_Alerts_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 9;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Sharing_Content_Header;//Title
                step.Label__c = Label.Sharing_Content_Header;//Title
                step.Default__c = Label.Sharing_Content_Value;//Default
                step.DC_Message__c = Label.Sharing_Content_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 10;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Help_is_just_a_click_away_Header;//Title
                step.Label__c = Label.Help_is_just_a_click_away_Header;//Title
                step.Default__c = Label.Help_is_just_a_click_away_Value;//Default
                step.DC_Message__c = Label.Help_is_just_a_click_away_Value;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'RfSearchPage';//Page Name
                step.Order__c = 11;//Order
                rfSearchPage.add(step);
                insertList.addAll(rfSearchPage);
            } else if (pageName == appNamespace() + 'RfSearchLightning') {

                List<Data_Mapping__c> rfSearchPage = new List<Data_Mapping__c>();
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = Label.Reference_Search_Assistant_Header;
                step.Label__c = Label.Reference_Search_Assistant_Header;
                step.Default__c = Label.Reference_Search_Assistant_Value;
                step.DC_Message__c = Label.Reference_Search_Assistant_Value;
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';
                step.Order__c = 1;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Using_Search_Filters_Header;//Title
                step.Label__c = Label.Using_Search_Filters_Header;//Title
                step.Default__c = Label.Using_Search_Filters_Value_Lightning;//Default
                step.DC_Message__c = Label.Using_Search_Filters_Value_Lightning;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 2;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Viewing_All_Filters_Header;//Title
                step.Label__c = Label.Viewing_All_Filters_Header;//Title
                step.Default__c = Label.Viewing_All_Filters_Value_Lightning;//Default
                step.DC_Message__c = Label.Viewing_All_Filters_Value_Lightning;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 3;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Using_Keywords_Header;//Title
                step.Label__c = Label.Using_Keywords_Header;//Title
                step.Default__c = Label.Using_Keywords_Value;//Default
                step.DC_Message__c = Label.Using_Keywords_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 4;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Getting_More_Information_Header;//Title
                step.Label__c = Label.Getting_More_Information_Header;//Title
                step.Default__c = Label.Getting_More_Information_Value;//Default
                step.DC_Message__c = Label.Getting_More_Information_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 5;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Viewing_More_Results_Header;//Title
                step.Label__c = Label.Viewing_More_Results_Header;//Title
                step.Default__c = Label.Viewing_More_Results_Value_Lighting;//Default
                step.DC_Message__c = Label.Viewing_More_Results_Value_Lighting;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 6;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Making_Selections_Header;//Title
                step.Label__c = Label.Making_Selections_Header;//Title
                step.Default__c = Label.Making_Selections_Value;//Default
                step.DC_Message__c = Label.Making_Selections_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 7;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Requesting_the_Use_of_an_Account_Header;//Title
                step.Label__c = Label.Requesting_the_Use_of_an_Account_Header;//Title
                step.Default__c = Label.Requesting_the_Use_of_an_Account_Value;//Default
                step.DC_Message__c = Label.Requesting_the_Use_of_an_Account_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 8;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Understanding_Alerts_Header;//Title
                step.Label__c = Label.Understanding_Alerts_Header;//Title
                step.Default__c = Label.Understanding_Alerts_Value;//Default
                step.DC_Message__c = Label.Understanding_Alerts_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 9;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Sharing_Content_Header;//Title
                step.Label__c = Label.Sharing_Content_Header;//Title
                step.Default__c = Label.Sharing_Content_Value;//Default
                step.DC_Message__c = Label.Sharing_Content_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 10;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Help_is_just_a_click_away_Header;//Title
                step.Label__c = Label.Help_is_just_a_click_away_Header;//Title
                step.Default__c = Label.Help_is_just_a_click_away_Value;//Default
                step.DC_Message__c = Label.Help_is_just_a_click_away_Value;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'RfSearchLightning';//Page Name
                step.Order__c = 11;//Order
                rfSearchPage.add(step);
                insertList.addAll(rfSearchPage);
            } else if (pageName == appNamespace() + 'Invitation_New') {
                List<Data_Mapping__c> invitationpage = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = Label.Create_an_Email_Invitation;//Title
                step.Label__c = Label.Create_an_Email_Invitation;//Title
                step.Default__c = Label.Create_an_Email_Invitation_Description;//Default
                step.DC_Message__c = Label.Create_an_Email_Invitation_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 1;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Select_Recipients;//Title
                step.Label__c = Label.Select_Recipients;//Title
                step.Default__c = Label.Select_Recipients_Description;//Default
                step.DC_Message__c = Label.Select_Recipients_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 2;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Invitation_Settings;//Title
                step.Label__c = Label.Invitation_Settings;//Title
                step.Default__c = Label.Invitation_Settings_Description;//Default
                step.DC_Message__c = Label.Invitation_Settings_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 3;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Select_a_Template;//Title
                step.Label__c = Label.Select_a_Template;//Title
                step.Default__c = Label.Select_a_Template_Discription;//Default
                step.DC_Message__c = Label.Select_a_Template_Discription;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 4;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Included_Content;//Title
                step.Label__c = Label.Included_Content;//Title
                step.Default__c = Label.Included_Content_Classic;//Default
                step.DC_Message__c = Label.Included_Content_Classic;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 5;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Add_Content;//Title
                step.Label__c = Label.Add_Content;//Title
                step.Default__c = Label.Included_Classic_Contents_Description;//Default
                step.DC_Message__c = Label.Included_Classic_Contents_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 6;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Preview_the_Microsite;//Title
                step.Label__c = Label.Preview_the_Microsite;//Title
                step.Default__c = Label.Preview_the_Microsite_Description;//Default
                step.DC_Message__c = Label.Preview_the_Microsite_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 7;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Share_Invitation;//Title
                step.Label__c = Label.Share_Invitation;//Title
                step.Default__c = Label.Share_Invitation_Description;//Default
                step.DC_Message__c = Label.Share_Invitation_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'Invitation_New';//Page Name
                step.Order__c = 8;//Order
                invitationpage.add(step);
                insertList.addAll(invitationpage);
            } else if (pageName == appNamespace() + 'Invitation_NewSLDS') {
                List<Data_Mapping__c> invitationpage = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = Label.Create_an_Email_Invitation;//Title
                step.Label__c = Label.Create_an_Email_Invitation;//Title
                step.Default__c = Label.Create_an_Email_Invitation_Description;//Default
                step.DC_Message__c = Label.Create_an_Email_Invitation_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 1;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Select_Recipients;//Title
                step.Label__c = Label.Select_Recipients;//Title
                step.Default__c = Label.Select_Recipients_Description;//Default
                step.DC_Message__c = Label.Select_Recipients_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 2;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Invitation_Settings;//Title
                step.Label__c = Label.Invitation_Settings;//Title
                step.Default__c = Label.Invitation_Settings_Description;//Default
                step.DC_Message__c = Label.Invitation_Settings_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 3;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Select_a_Template;//Title
                step.Label__c = Label.Select_a_Template;//Title
                step.Default__c = Label.Select_a_Template_Discription;//Default
                step.DC_Message__c = Label.Select_a_Template_Discription;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 4;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Included_Content;//Title
                step.Label__c = Label.Included_Content;//Title
                step.Default__c = Label.Included_Content_Classic;//Default
                step.DC_Message__c = Label.Included_Content_Classic;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 5;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Add_Content;//Title
                step.Label__c = Label.Add_Content;//Title
                step.Default__c = Label.Included_Classic_Contents_Description;//Default
                step.DC_Message__c = Label.Included_Classic_Contents_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 6;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Preview_the_Microsite;//Title
                step.Label__c = Label.Preview_the_Microsite;//Title
                step.Default__c = Label.Preview_the_Microsite_Description;//Default
                step.DC_Message__c = Label.Preview_the_Microsite_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 7;//Order
                invitationpage.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Share_Invitation;//Title
                step.Label__c = Label.Share_Invitation;//Title
                step.Default__c = Label.Share_Invitation_Description;//Default
                step.DC_Message__c = Label.Share_Invitation_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'Invitation_NewSLDS';//Page Name
                step.Order__c = 8;//Order
                invitationpage.add(step);
                insertList.addAll(invitationpage);
            } else if (pageName == appNamespace() + 'ReferenceUseRequest') {
                List<Data_Mapping__c> refRequest = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Label__c = Label.Requesting_a_Reference;//Title
                step.Name = Label.Requesting_a_Reference;//Title
                step.Default__c = Label.Requesting_a_Reference_Description;//Default
                step.DC_Message__c = Label.Requesting_a_Reference_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 1;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Number_of_References_Needed;//Title
                step.Label__c = Label.Number_of_References_Needed;//Title
                step.Default__c = Label.Number_of_References_Needed_Description;//Default
                step.DC_Message__c = Label.Number_of_References_Needed_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 2;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Item_Selection;//Title
                step.Label__c = Label.Item_Selection;//Title
                step.Default__c = Label.Item_Selection_Description;//Default
                step.DC_Message__c = Label.Item_Selection_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 3;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Request_Details;//Title default
                step.Label__c = Label.Request_Details;//Title
                step.Default__c = Label.Request_Details_Classic_Description;//Default body
                step.DC_Message__c = Label.Request_Details_Classic_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 4;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Label__c = Label.Delete_Overlay;//Title
                step.Name = Label.Delete_Overlay;//Title
                step.Default__c = Label.Delete_Classic_Description;//Default
                step.DC_Message__c = Label.Delete_Classic_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 5;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Additional Information';//Title
                step.Label__c = 'Additional Information';//Title
                step.Default__c = Label.Additional_Information_Description;//Default
                step.DC_Message__c = Label.Additional_Information_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 6;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Determining_Request_Routing;//Title
                step.Label__c = Label.Determining_Request_Routing;//Title
                step.Default__c = Label.Determining_Request_Routing_Descriptiong;//Default
                step.DC_Message__c = Label.Determining_Request_Routing_Descriptiong;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 7;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Submit_Your_Request;//Title
                step.Label__c = Label.Submit_Your_Request;//Title
                step.Default__c = Label.Submit_Your_Request_Description;//Default
                step.DC_Message__c = Label.Submit_Your_Request_Description;//Current value
                step.Visible__c = true;//Classic
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequest';//Page Name
                step.Order__c = 8;//Order
                refRequest.add(step);
                insertList.addAll(refRequest);
            } else if (pageName == appNamespace() + 'ReferenceUseRequestSLDS') {
                List<Data_Mapping__c> refRequest = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = Label.Requesting_a_Reference;//Title
                step.Label__c = Label.Requesting_a_Reference;//Title
                step.Default__c = Label.Requesting_a_Reference_Description;//Default
                step.DC_Message__c = Label.Requesting_a_Reference_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 1;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Request_Details;//Title
                step.Label__c = Label.Request_Details;//Title
                step.Default__c = Label.Request_Details_Description;//Default
                step.DC_Message__c = Label.Request_Details_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 2;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Number_of_References_Needed;//Title
                step.Label__c = Label.Number_of_References_Needed;//Title
                step.Default__c = Label.Number_of_References_Needed_Description;//Default
                step.DC_Message__c = Label.Number_of_References_Needed_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 3;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Delete_Overlay;//Title
                step.Label__c = Label.Delete_Overlay;//Title
                step.Default__c = Label.Delete_Description;//Default
                step.DC_Message__c = Label.Delete_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 4;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Additional Information';//Title
                step.Label__c = 'Additional Information';//Title
                step.Default__c = Label.Additional_Information_Description;//Default
                step.DC_Message__c = Label.Additional_Information_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 5;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Determining_Request_Routing;//Title
                step.Label__c = Label.Determining_Request_Routing;//Title
                step.Default__c = Label.Determining_Request_Routing_Descriptiong;//Default
                step.DC_Message__c = Label.Determining_Request_Routing_Descriptiong;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 6;//Order
                refRequest.add(step);
                step = new Data_Mapping__c();
                step.Name = Label.Submit_Your_Request;//Title
                step.Label__c = Label.Submit_Your_Request;//Title
                step.Default__c = Label.Submit_Your_Request_Description;//Default
                step.DC_Message__c = Label.Submit_Your_Request_Description;//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceUseRequestSLDS';//Page Name
                step.Order__c = 7;//Order
                refRequest.add(step);
                insertList.addAll(refRequest);
            } else if (pageName == appNamespace() + 'ReferenceRefreshPageSLDS') {
                List<Data_Mapping__c> rfSearchPage = new List<Data_Mapping__c>();
                //Step 1 
                Data_Mapping__c step = new Data_Mapping__c();
                step.Name = 'Profile Update Minder';//Title default
                step.Label__c = 'Profile Update Minder';//Title
                step.Default__c = 'Please take a moment to review and, if needed, update the information for your Accounts and Contacts that are members of the Reference Program.';//Default
                step.DC_Message__c = 'Please take a moment to review and, if needed, update the information for your Accounts and Contacts that are members of the Reference Program.';//Current value
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 1;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Accounts to Update';//Title
                step.Label__c = 'Accounts to Update';//Title
                step.Default__c = 'Accounts shown here<br/>- are members of the Reference Program<br/>- list you as the Owner<br/>- have not been reviewed recently<br/><br/>Select an Account to display that Account\'s information.';
                step.DC_Message__c = 'Accounts shown here<br/>- are members of the Reference Program<br/>- list you as the Owner<br/>- have not been reviewed recently<br/><br/>Select an Account to display that Account\'s information.';
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 2;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Account Details';//Title
                step.Label__c = 'Account Details';//Title
                step.Default__c = 'Account program member details display all details that are mapped from the Account record first with Update links for Referenceability (what the Account will do) and Attributes (what the Account is referenceable for) below.';
                step.DC_Message__c = 'Account program member details display all details that are mapped from the Account record first with Update links for Referenceability (what the Account will do) and Attributes (what the Account is referenceable for) below.';
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 3;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Program Status';//Title
                step.Label__c = 'Program Status';//Title
                step.Default__c = Label.Program_Status_Value;
                step.DC_Message__c = Label.Program_Status_Value;
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 4;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Referenceability';//Title
                step.Label__c = 'Referenceability';//Title
                step.Default__c = 'Current Referenceability (what the Account will do) is shown here and can be modified using the <u>Update</u> link.';
                step.DC_Message__c = 'Current Referenceability (what the Account will do) is shown here and can be modified using the <u>Update</u> link.';
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 5;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Attributes';//Title
                step.Label__c = 'Attributes';//Title
                step.Default__c = 'Current Attributes (what the Account is referenceable for) is shown here and can be modified using the <u>Update</u> link.';
                step.DC_Message__c = 'Current Attributes (what the Account is referenceable for) is shown here and can be modified using the <u>Update</u> link.';
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 6;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Remove from the Program';//Title
                step.Label__c = 'Remove from the Program';//Title
                step.DC_Message__c = 'If an Account is no longer referenceable click the <u>Remove</u> link and let us know why so that we can take them out of the program.';//Title
                step.Default__c = 'If an Account is no longer referenceable click the <u>Remove</u> link and let us know why so that we can take them out of the program.';//Title
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 7;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c(); 
                step.Name = 'Contact Details';//Title
                step.Label__c = 'Contact Details';//Title
                step.Default__c = 'Each Contact that is a Program Member and is associated to the Account is shown below the Account details. Referenceability and Attributes can be updated for each Contact.';
                step.DC_Message__c = 'Each Contact that is a Program Member and is associated to the Account is shown below the Account details. Referenceability and Attributes can be updated for each Contact.';
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 8;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Add Contact';//Title
                step.Label__c = 'Add Contact';//Title
                step.Default__c = Label.Add_Contact_Value;
                step.DC_Message__c = Label.Add_Contact_Value;
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 9;//Order
                rfSearchPage.add(step);
                step = new Data_Mapping__c();
                step.Name = 'Submit / No Updates';//Title
                step.Label__c = 'Submit / No Updates';//Title
                step.Default__c = Label.Submit_Value;
                step.DC_Message__c = Label.Submit_Value;
                step.Visible__c = false;//Lightning
                step.Field_API_Name__c = appNamespace() + 'ReferenceRefreshPageSLDS';//Page Name
                step.Order__c = 10;//Order
                rfSearchPage.add(step);
                insertList.addAll(rfSearchPage);
            } 
        }
        ConstantsController.shouldDataMappingProcessed = true;
        insert insertList;
    }    
    
    /**
     * Method to Prevent Open Redirects  
     * added for #656 by Rajesh (22 Dec, 2016)
     */
    public static Pagereference redirectToSource(String requestedUrl) {
        PageReference returnUrl;
        String whiteListedDomain = System.URL.getSalesforceBaseURL().toExternalForm();
    
        if (requestedUrl != null && requestedUrl != '' ) {
            
            if (!requestedUrl.contains('/') && !requestedUrl.contains('.')) {
                returnUrl= new Pagereference('/' + requestedUrl);
            } else if (requestedUrl.startsWith('/') || whiteListedDomain == New URL(requestedUrl).getHost()) {
                requestedUrl.replaceFirst('/+', '');
                returnUrl = new PageReference('/' + requestedUrl);
            } else {
                returnUrl= new PageReference(whiteListedDomain);
            }
        } else {
            returnUrl= new PageReference(whiteListedDomain);
        }
    
        returnUrl.setRedirect(true);
        return returnUrl;
    }
    
    public static Map<String, Set<String>> getRelatedAccounts(Set<String> contactIds, Custom_Settings__c cs) {
        Map<String, Set<String>> contactAccountMap = new Map<String, Set<String>>();
        
        if (cs == null) {
            cs = UtilityController.getCustomSettings();
        }
            
        if (cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' 
                    && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != '') {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                     + ' WHERE ' + contactField + ' IN :contactIds and '+accountField+' != null';
            List<sObject> objectList = Database.query(query);
            
            if (objectList != null && objectList.size() > 0) {
                
                for (sObject obj : objectList) {
                    
                    if (!contactAccountMap.containsKey((String)obj.get(contactField))) {
                        contactAccountMap.put((String)obj.get(contactField),new Set<String>());
                    }
                    contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                }
            }
        }
        return contactAccountMap;
    }
    /**
     * Method to get contacts related to an account
     */
    public static List<Contact> getAccountContacts(String accId, Custom_Settings__c cs) {
        Set<Id> contactIds = WithoutSharingHelperController.getAccountContactsForNomination(accId, cs);
        List<Contact> contacts = ([SELECT id, Name, Title, Email, Phone, AccountId,
                            (SELECT Id, Account__c, Contact__c, Name, Is_Referenceable__c, Referenceability_Status__c,
                            RUL_Last_Activity_Date__c, Reference_Program_Candidate__c, Roll_up_Referenceability_to_All_Accounts__c,
                            Roll_up_Referenceability_to_Primary_Acc__c FROM Reference_Basic_Informations__r) 
                            FROM Contact WHERE AccountId = : accId OR Id IN :contactIds order by LastName limit : Limits.getLimitQueryRows()]);
        return contacts;
    }
    
    /**
     * REF - 1223 - Consolidating batches
     * Method to sendExceptionEmailNotification for exception in batch
     */
    public static void sendExceptionEmailNotification(List<String> listOfFailedRecords, String Mode) {
    	
        if ((listOfFailedRecords != NULL && listOfFailedRecords.size() > 0)) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { 'referenceedge@point-of-reference.com' };
            mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('RefEdge Support');
            mail.setSubject(Mode);
            String mailBody = 'Exception in records are: \n' + listOfFailedRecords;
            mailBody = mailBody + '\n Organization Name: ' + Userinfo.getOrganizationName() + '\n Organization Id: ' 
            							+ Userinfo.getOrganizationId() + '\n\n Please do not reply to this mail.';
            mail.setPlainTextBody(mailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
     
    /**
     * Method return Group active group member 
     * Added for REF-1316 by Rajesh (23 march, 2018)
     * Modified by : Rajesh (23 march, 2018)
     */
    public static List<User> getCustomerReferenceTeam() {  
        List<User> publicGroupMembers = new List<User>([SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember 
        																	WHERE Group.Name = 'Customer Reference Team' AND UserOrGroupId 
        																	NOT IN :UtilityController.getGuestUserId()) AND isActive = true 
      																		LIMIT :limits.getLimitQueryRows()]);
  		return publicGroupMembers; 
    }

    /**
    * Method to delete scheduled batch if it is already been in list
    * Added for REF-1590 by Rajneesh (july 23,2018) 
    **/ 
    public static void scheduledJobDelete(String jobName) {

        String cronJobName = '%' + jobName + '%';

        List<CronTrigger> cronTriggerList = new List<CronTrigger>();
        cronTriggerList = [SELECT Id, OwnerId, CronJobDetail.JobType, CronJobDetail.Name, CronExpression, createdById FROM CronTrigger WHERE CronJobDetail.Name Like : cronJobName];
        
        if(cronTriggerList.size() > 0) {
            
            for(CronTrigger ct : cronTriggerList) {
                System.abortJob(ct.Id);
            }
        }
    }  

    /**
    * Method to exclude weeekends  
    * Added for REF-1919 by Rajneesh (sept 6,2018) 
    **/ 
    public static Date excludeWeekends(Date calculateFrom, Integer noOfDays, Boolean checkWeekends, String weekDays) {
        Set<String> setOffDays = new Set<String>();
        DateTime deadline = (DateTime) calculateFrom;
    
        if(checkWeekends) {

            for (String str: weekDays.split(';')) {
                setOffDays.add(str);
            }
        } 
        
        for(Integer i=0; i < noOfDays; i++) {
            deadline = deadline.addDays(1);
            
            if(setOffDays.size() > 0) {  

                while(true) {

                    if(setOffDays.contains(deadline.format('EEEE'))) {                         
                            deadline = deadline.addDays(1);                        
                    } else {                        
                        break;
                    }
                } 
            }
        }           
        return Date.valueOf(deadline);
    }
    
    /*
    *   REF-1975
    *   Description : This method will rollup attribute to RBI without creating Account Attribute.
	*   Created by : Rajneesh Raj @Jan/29/2019
    */
    public static String rollUpAttributeMappingRBI(Id recordId, Boolean isAccount, Id AccountId) {
		try{
            //	query to get Account's parent information dynamically..
            String queryString = 'SELECT Id, ';
            Set<String> fieldSet = new Set<String>();
            
            if(isAccount) {
                List<Attribute_Mapping__c> attriMappingList = [SELECT Id, Field_Api_Name__c, RelationShip_Name__c, Object__c, Mapping_Type__c, Auto_populate__c 
                FROM Attribute_Mapping__c WHERE (Object__c = : ConstantsController.ACCOUNT OR Object__c = : ConstantsController.REFERENCE_PROFILE) 
                AND Mapping_Type__c != : ConstantsController.CHILD_OBJECT];
                Set<String> amofAccount = new Set<String>();
                
                for(Attribute_Mapping__c amRec : attriMappingList) {
                    
                    if(amRec.Object__c == ConstantsController.ACCOUNT && amRec.Mapping_Type__c == null && amRec.Auto_populate__c) {
                        amofAccount.add(amRec.Field_Api_Name__c);
                    }
                }
                
                // Iterate over Attribute Mapping object to get Account parents information
                for(Attribute_Mapping__c am : attriMappingList) {

                    if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && !am.RelationShip_Name__c.contains('__c')) {
                        queryString += am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && am.RelationShip_Name__c.contains('__c')){
                        queryString += am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.REFERENCE_PROFILE && am.RelationShip_Name__c != null && am.RelationShip_Name__c == 'Account__c' && !amofAccount.contains(am.Field_Api_Name__c)) {
                        queryString += am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.Field_Api_Name__c);
                    }
                }
                queryString = queryString.removeEnd(', ') + ' FROM Account WHERE Id =: recordId';
            } else {
                List<Reference_Basic_Information__c> accRBI = [SELECT Id FROM Reference_Basic_Information__c WHERE Account__c =: AccountId AND Contact__c = null];

                List<Attribute_Mapping__c> attriMappingList = [SELECT Id, Field_Api_Name__c, RelationShip_Name__c, Object__c, Mapping_Type__c, Auto_populate__c, Inheritable__c 
                FROM Attribute_Mapping__c WHERE (Object__c = : ConstantsController.ACCOUNT OR Object__c = : ConstantsController.CONTACT OR Object__c = : ConstantsController.REFERENCE_PROFILE) 
                AND Mapping_Type__c != : ConstantsController.CHILD_OBJECT];
                Set<String> amofContact = new Set<String>();
                Set<String> amofAccount = new Set<String>();
				
                for(Attribute_Mapping__c amRec : attriMappingList) {
                    
                    if(amRec.Object__c == ConstantsController.CONTACT && amRec.Mapping_Type__c == null && amRec.Auto_populate__c) {
                        amofContact.add(amRec.Field_Api_Name__c);
                    } else if(amRec.Object__c == ConstantsController.ACCOUNT && amRec.Mapping_Type__c == null && amRec.Auto_populate__c && amRec.Inheritable__c && accRBI.size() > 0) {
                        amofAccount.add(amRec.Field_Api_Name__c);
                    }
                }
                
                // Iterate over Attribute Mapping object to get Contact parents information
                for(Attribute_Mapping__c am : attriMappingList) {

                    if(am.Object__c == ConstantsController.CONTACT && am.RelationShip_Name__c != null && !am.RelationShip_Name__c.contains('__c')) {
                        queryString += am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.CONTACT && am.RelationShip_Name__c != null && am.RelationShip_Name__c.contains('__c')){
                        queryString += am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.REFERENCE_PROFILE && am.RelationShip_Name__c != null && am.RelationShip_Name__c == 'Contact__c' && !amofContact.contains(am.Field_Api_Name__c)) {
                        queryString += am.Field_Api_Name__c + ', ';
                        fieldSet.add(am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && !am.RelationShip_Name__c.contains('__c') && am.Inheritable__c && accRBI.size() > 0) {
                        queryString += 'Account.' + am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add('Account.' + am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && am.RelationShip_Name__c.contains('__c') && am.Inheritable__c && accRBI.size() > 0){
                        queryString += 'Account.' + am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add('Account.' + am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c);
                    } else if(am.Object__c == ConstantsController.REFERENCE_PROFILE && am.RelationShip_Name__c != null && am.RelationShip_Name__c == 'Account__c' && !amofAccount.contains(am.Field_Api_Name__c) && am.Inheritable__c && accRBI.size() > 0) {
                        queryString += 'Account.' + am.Field_Api_Name__c + ', ';
                        fieldSet.add('Account.' + am.Field_Api_Name__c);
                    }
                }
                queryString = queryString.removeEnd(', ') + ' FROM Contact WHERE Id =: recordId';                
            }			
            //	Map with sObjectId as key and Associate attribute/s as key
            Map<Id, String> sObjectMap = new Map<Id, String>();
            String attribites = '';

            for(sObject acc : database.query(queryString)) {                  
               
                for(String fldName : fieldSet) {

                    if(!fldName.contains('.') && acc.get(fldName) != null) {
                        attribites += acc.get(fldName) +', ';
                        
                    } else if(fldName.contains('.') && (fldName.countMatches('.') == 2) && acc.getSObject(fldName.substringBefore('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).getsObject(fldName.substringBetween('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).getsObject(fldName.substringBetween('.')).get(fldName.substringAfterLast('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).getsObject(fldName.substringBetween('.')).get(fldName.substringAfterLast('.')) != '') {
                        attribites += acc.getSObject(fldName.substringBefore('.')).getsObject(fldName.substringBetween('.')).get(fldName.substringAfterLast('.')) +', '; 
                    } else if(fldName.contains('.') && (fldName.countMatches('.') == 1) && acc.getSObject(fldName.substringBefore('.')) != null && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != '') {
                        attribites += acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) +', ';  
                    } 
                }
            }
            return attribites.removeEnd(',');
        } catch(Exception ex) {
            throw ex;
            return null;
        }
	}
	
	public Static Date parseLastVisitDate(String lastVisitDate) {
		try {
			if(lastVisitDate.contains('-') && lastVisitDate.split('-')[0].length() == 4) {
	    		List<String> dateParts = lastVisitDate.split('-');
		        Integer year = Integer.valueOf(dateParts[0]);
		        Integer month = Integer.valueOf(dateParts[1]);
		        Integer day = Integer.valueOf(dateParts[2]);
		        return Date.newInstance(year,month,day);
	    	} else {
	    		return Date.parse(lastVisitDate);
	    	}
		} catch(Exception e) {
			return date.today();
		}
	}
	
	public static Map<Id, String> getUserEmailMapForSlackNotification(Custom_Settings__c cs, List <Reference_Content__c> refContentList, String notificationType) {
    	Map<Id, String> userEmailMap = new Map<Id, String>();
    	
    	if((cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c)) {
    		if((notificationType == ConstantsController.DC_MANAGER_REVIEW && cs.DC_Manager_Review_Slack__c)
    			|| (notificationType == ConstantsController.DC_REMINDER && (cs.DC_Reminder_Slack__c
    					|| cs.DC_Escalation_to_Owner_Slack__c || cs.DC_Escalation_to_Manager_Slack__c))) {
				
				for(Reference_Content__c refContent : refContentList) {
					userEmailMap.put(refContent.Opportunity__r.ownerId, '');
					
					if(refContent.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c) {
						userEmailMap.put(refContent.Opportunity__r.Owner.ManagerId, '');
		            }
				}
				
				for (User user : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
		            if (user.IsActive) {
		                userEmailMap.put(user.Id, user.Email);
		            }
		        }
    		}
    	}
		return userEmailMap;
    }
}