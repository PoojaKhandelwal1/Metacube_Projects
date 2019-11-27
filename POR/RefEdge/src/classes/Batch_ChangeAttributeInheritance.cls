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
 * Class: NewAttributeController
 * Description : This Batch called from NewAttributeController when any root attribute is changed its inheritance and update all child attributes
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_ChangeAttributeInheritance implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private String soqlQuery = '';
    private Boolean isInherited;
    private Boolean isDelete;
    private Attribute__c attribute;
    private set < String > childAttributes;
    private Integer accountAttributeCount = 0;
    private Integer contactAttributeCount = 0;
    private Integer contentAttributeCount = 0;
    private Integer attributeCount = 0;
    private boolean isSuccess;
    private Custom_Settings__c cs;
    
    /**
     * Constructor
     */
    global Batch_ChangeAttributeInheritance(Attribute__c attribute, Boolean isDelete) {
        this.attribute = attribute;
        this.isInherited = attribute.Inheritable__c;
        this.isDelete = isDelete;
        childAttributes = new set < string > ();
        isSuccess = true;
        string attId2 = ConstantsController.attributeId;
        string attributeId = '%' + attribute.Id + '%';
        string attributeId1 = '%' + (attId2 != null ? attId2 : '') + '%';
        string query = 'select Id, Name from Attribute__c where ParentIds__c like : attributeId';
        
        if (attId2 != null && attId2 != '') {
            query += ' or ParentIds__c like : attributeId1';
        }
        
        for (Attribute__c att: Database.query(String.escapeSingleQuotes(query))) {
            childAttributes.add(att.Id);
        }
        attributeCount = childAttributes.size();
        cs = UtilityController.getCustomSettings();
    }
    
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        soqlQuery = 'select Attribute__c,Attribute__r.Parent__c,Attribute__r.Name,Account__c from Account_Attribute__c where Attribute__c IN :childAttributes and Contact__c = null and Reference_Content__c = null';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Account_Attribute__c > scope) {
        try {
            set < string > accountIds = new set < string > ();
            list < Account_Attribute__c > accountAttributes = new list < Account_Attribute__c > ();
            map < Id, set < Id >> contactAttributeIdsMap = new map < Id, set < Id >> ();
            map < Id, set < string >> contactFromAccountAttributeIdsMap = new map < Id, set < string >> ();
            map < string, set < string >> accountContactMap = new map < string, set < string >> ();
            map < Id, Reference_Basic_Information__c > contactRBI = new map < Id, Reference_Basic_Information__c > ();
            map < String, Contact_Attribute__c > contactAttributeMap = new map < String, Contact_Attribute__c > ();
            list < Contact_Attribute__c > newContctAttrib = new list < Contact_Attribute__c > ();
            list < Contact_Attribute__c > deleteContctAttrib = new list < Contact_Attribute__c > ();

            map < Id, set < Id >> contentAttributeIdsMap = new map < Id, set < Id >> ();
            map < Id, set < Id >> accountContentMap = new map < Id, set < Id >> ();
            map < String, Content_Attribute__c > contentAttributeMap = new map < String, Content_Attribute__c > ();
            list < Content_Attribute__c > newContentAttrib = new list < Content_Attribute__c > ();
            list < Content_Attribute__c > deleteContentAttrib = new list < Content_Attribute__c > ();
            set < Id > tempSet = new set < Id > ();
            
            for (Account_Attribute__c accAtt: scope) {
                accountContactMap.put(accAtt.Account__c, new set < string > ());
                accountContentMap.put(accAtt.Account__c, new set < Id > ());
                accountIds.add(accAtt.Account__c);
                accAtt.Inheritable__c = isInherited;
                accountAttributes.add(accAtt);
            }
            //Shared Contact start
            set < string > contactIds = new set < string > ();
            
            if (cs.Shared_Contacts__c) {
                String objectName = cs.Shared_Contact_Object__c;
                String accountField = cs.Shared_Account_Field__c;
                String contactField = cs.Shared_Contact_Field__c;
                
                if (accountField != null && accountField != '' && contactField != null && contactField != '') {
                    String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName +
                        ' WHERE ' + accountField + ' IN :accountIds';
                    List < sObject > objectList = Database.query(query);
                    
                    if (objectList != null && objectList.size() > 0) {
                        
                        for (sObject obj: objectList) {
                            contactIds.add((String) obj.get(contactField));
                            
                            if (!accountContactMap.containsKey((String) obj.get(accountField))) {
                                accountContactMap.put((String) obj.get(accountField), new set < string > ());
                            }
                            accountContactMap.get((String) obj.get(accountField)).add((String) obj.get(contactField));
                        }
                    }
                }
            }
            //Shared Contact end
            list < Contact > contList = new list < Contact > ();
            
            if (cs.Shared_Contacts__c) {
                contList = WithoutSharingHelperController.getContactWithRelatedRecordsSharedContact(accountIds, contactIds);
            } else {
                contList = WithoutSharingHelperController.getContactWithRelatedRecords(accountIds);
            }
            list < Account_Reference_Content__c > accountRefContents = [Select Reference_Content__c, Account__c from Account_Reference_Content__c where Account__c IN:
                accountIds
            ];
            
            for (Contact c: contList) {
                
                if (accountContactMap.containsKey(c.AccountId))
                    accountContactMap.get(c.AccountId).add(c.Id);
                contactAttributeIdsMap.put(c.Id, new set < Id > ());
                contactFromAccountAttributeIdsMap.put(c.Id, new set < string > ());
                
                for (Contact_Attribute__c cA: c.Contact_Attributes__r) {
                    contactAttributeMap.put(cA.contact__c + '+' + cA.Account__c + '+' + cA.Attribute__c, cA);
                    
                    if (cA.From_Account__c)
                        contactFromAccountAttributeIdsMap.get(cA.contact__c).add(cA.Account__c + '+' + cA.Attribute__c);
                    else
                        contactAttributeIdsMap.get(cA.contact__c).add(cA.Attribute__c);
                }
                
                if (c.Reference_Basic_Informations__r.size() > 0)
                    contactRBI.put(c.Id, c.Reference_Basic_Informations__r[0]);
            }
            
            for (Account_Reference_Content__c accRefCon: accountRefContents) {
                
                if (accountIds.contains(accRefCon.Account__c)) {
                    
                    if (!accountContentMap.containsKey(accRefCon.Account__c)) {
                        accountContentMap.put(accRefCon.Account__c, new set < Id > ());
                    } else {
                        accountContentMap.get(accRefCon.Account__c).add(accRefCon.Reference_Content__c);
                    }
                    contentAttributeIdsMap.put(accRefCon.Reference_Content__c, new set < Id > ());
                }
            }
            
            if (contentAttributeIdsMap.size() > 0) {
                
                for (Content_Attribute__c conAtt: [Select Reference_Content__c, Attribute__c From Content_Attribute__c where Reference_Content__c In:
                        contentAttributeIdsMap.keySet()
                    ]) {
                    contentAttributeIdsMap.get(conAtt.Reference_Content__c).add(conAtt.Attribute__c);
                    contentAttributeMap.put(conAtt.Reference_Content__c + '+' + conAtt.Attribute__c, conAtt);
                }
            }
            
            if (isInherited) {
                
                for (Account_Attribute__c aT: scope) {
                    
                    if (accountContactMap != null && accountContactMap.containsKey(aT.Account__c) && accountContactMap.get(aT.Account__c) != null) {
                        
                        for (Id cntcId: accountContactMap.get(aT.Account__c)) {
                            
                            if (contactRBI.containsKey(cntcId) && (contactRBI.get(cntcId).Is_Referenceable__c)) {
                                boolean inheritAttFromAllAcc = (cs.Shared_Contacts__c ? (contactRBI.containsKey(cntcId) && contactRBI.get(cntcId).Inherit_Attributes_from_All_Accounts__c ?
                                    true : (contactRBI.containsKey(cntcId) && contactRBI.get(cntcId).Inherit_Attributes_from_Primary_Account__c ?
                                        false : (cs.Inherit_Attributes_from_All_Accounts__c))) : false);
                                
                                if ((inheritAttFromAllAcc || contactRBI.get(cntcId).Account__c == aT.Account__c) && contactFromAccountAttributeIdsMap.get(
                                        cntcId) != null && !contactFromAccountAttributeIdsMap.get(cntcId).contains(aT.Account__c + '+' + aT.Attribute__c)) {
                                    Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                    tempObj.Contact__c = cntcId;
                                    tempObj.Attribute__c = aT.Attribute__c;
                                    tempObj.From_Account__c = true;
                                    tempObj.Account__c = aT.Account__c;
                                    newContctAttrib.add(tempObj);
                                } else if ((inheritAttFromAllAcc || contactRBI.get(cntcId).Account__c == aT.Account__c) &&
                                    contactFromAccountAttributeIdsMap.get(cntcId) == null) {
                                    Contact_Attribute__c tempObj = new Contact_Attribute__c();
                                    tempObj.Contact__c = cntcId;
                                    tempObj.Attribute__c = aT.Attribute__c;
                                    tempObj.From_Account__c = true;
                                    tempObj.Account__c = aT.Account__c;
                                    newContctAttrib.add(tempObj);
                                }
                            }
                        }
                    }
                    
                    if (accountContentMap != null && accountContentMap.containsKey(aT.Account__c) && accountContentMap.get(aT.Account__c) != null) {
                        
                        for (Id cntcId: accountContentMap.get(aT.Account__c)) {
                            
                            if (contentAttributeIdsMap.get(cntcId) != null && !contentAttributeIdsMap.get(cntcId).contains(aT.Attribute__c)) {
                                Content_Attribute__c tempContentObj = new Content_Attribute__c();
                                tempContentObj.Reference_Content__c = cntcId;
                                tempContentObj.Attribute__c = aT.Attribute__c;
                                tempContentObj.Account__c = aT.Account__c;
                                tempContentObj.From_Account__c = true;
                                newContentAttrib.add(tempContentObj);
                            } else if (contentAttributeIdsMap.get(cntcId) == null) {
                                Content_Attribute__c tempContentObj = new Content_Attribute__c();
                                tempContentObj.Reference_Content__c = cntcId;
                                tempContentObj.Attribute__c = aT.Attribute__c;
                                tempContentObj.Account__c = aT.Account__c;
                                tempContentObj.From_Account__c = true;
                                newContentAttrib.add(tempContentObj);
                            } else if (contentAttributeIdsMap.get(cntcId) != null && contentAttributeIdsMap.get(cntcId).contains(aT.Attribute__c)) {
                                Content_Attribute__c tempContentObj = contentAttributeMap.get(cntcId + '+' + aT.Attribute__c);
                                tempContentObj.Account__c = aT.Account__c;
                                tempContentObj.From_Account__c = true;
                                newContentAttrib.add(tempContentObj);
                            }
                        }
                    }
                }
            } else {
                
                if (isDelete) {
                    
                    for (Account_Attribute__c aT: scope) {
                        
                        if (accountContactMap != null && accountContactMap.containsKey(aT.Account__c) && accountContactMap.get(aT.Account__c) != null) {
                            
                            for (Id cntcId: accountContactMap.get(aT.Account__c)) {
                                
                                if (contactFromAccountAttributeIdsMap.get(cntcId) != null && contactFromAccountAttributeIdsMap.get(cntcId).contains(aT.Account__c +
                                        '+' + aT.Attribute__c)) {
                                    Contact_Attribute__c tempObj = contactAttributeMap.get(cntcId + '+' + aT.Account__c + '+' + aT.Attribute__c);
                                    
                                    if (!tempSet.contains(tempObj.Id))
                                        deleteContctAttrib.add(tempObj);
                                    tempSet.add(tempObj.Id);
                                }
                            }
                        }
                        
                        if (accountContentMap != null && accountContentMap.containsKey(aT.Account__c) && accountContentMap.get(aT.Account__c) != null) {
                            
                            for (Id cntcId: accountContentMap.get(aT.Account__c)) {
                                
                                if (contentAttributeIdsMap.get(cntcId) != null && contentAttributeIdsMap.get(cntcId).contains(aT.Attribute__c)) {
                                    Content_Attribute__c tempContentObj = contentAttributeMap.get(cntcId + '+' + aT.Attribute__c);
                                    
                                    if (!tempSet.contains(tempContentObj.Id))
                                        deleteContentAttrib.add(tempContentObj);
                                    tempSet.add(tempContentObj.Id);
                                }
                            }
                        }
                    }
                } else {
                    
                    for (Account_Attribute__c aT: scope) {
                        
                        if (accountContactMap != null && accountContactMap.containsKey(aT.Account__c) && accountContactMap.get(aT.Account__c) != null) {
                            
                            for (Id cntcId: accountContactMap.get(aT.Account__c)) {
                                
                                if (contactFromAccountAttributeIdsMap.get(cntcId) != null && contactFromAccountAttributeIdsMap.get(cntcId).contains(aT.Account__c +
                                        '+' + aT.Attribute__c)) {
                                    Contact_Attribute__c tempObj = contactAttributeMap.get(cntcId + '+' + aT.Account__c + '+' + aT.Attribute__c);
                                    
                                    if (contactAttributeIdsMap.get(cntcId) != null && contactAttributeIdsMap.get(cntcId).contains(aT.Attribute__c)) {
                                        
                                        if (!tempSet.contains(tempObj.Id))
                                            deleteContctAttrib.add(tempObj);
                                        tempSet.add(tempObj.Id);
                                    } else {
                                        tempObj.From_Account__c = false;
                                        tempObj.Account__c = null;
                                        newContctAttrib.add(tempObj);
                                    }
                                }
                            }
                        }
                        
                        if (accountContentMap != null && accountContentMap.containsKey(aT.Account__c) && accountContentMap.get(aT.Account__c) != null) {
                            
                            for (Id cntcId: accountContentMap.get(aT.Account__c)) {
                                
                                if (contentAttributeIdsMap.get(cntcId) != null && contentAttributeIdsMap.get(cntcId).contains(aT.Attribute__c)) {
                                    Content_Attribute__c tempContentObj = contentAttributeMap.get(cntcId + '+' + aT.Attribute__c);
                                    tempContentObj.From_Account__c = false;
                                    tempContentObj.Account__c = null;
                                    newContentAttrib.add(tempContentObj);
                                }
                            }
                        }
                    }
                }
            }
            
            if (!deleteContctAttrib.isEmpty()) {
                ConstantsController.deleteAttributFromContact = true;
                WithoutSharingHelperController.deleteContactAttributes(deleteContctAttrib);
                contactAttributeCount = deleteContctAttrib.size();
            }
            
            if (!deleteContentAttrib.isEmpty()) {
                ConstantsController.deleteAttributeFromContent = true;
                delete deleteContentAttrib;
                contentAttributeCount = deleteContentAttrib.size();
            }
            
            if (!newContctAttrib.isEmpty()) {
                ConstantsController.fromAccount = true;
                WithoutSharingHelperController.upsertContactAttributes(newContctAttrib);
                contactAttributeCount += newContctAttrib.size();
            }
            
            if (!newContentAttrib.isEmpty()) {
                ConstantsController.fromAccountToContent = true;
                upsert newContentAttrib;
                contentAttributeCount += newContentAttrib.size();
            }
            
            if (!accountAttributes.isEmpty()) {
                ConstantsController.shouldAccountUpdate = false;
                WithoutSharingHelperController.upsertAccountAttributes(accountAttributes);
                accountAttributeCount = accountAttributes.size();
            }
        } catch (Exception e) {
            isSuccess = false;
        }
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
    	
        if (isSuccess) {
             List<sObject> postFeedItems = new  List<sObject>();
             List<Messaging.SingleEmailMessage> listMail = new List<Messaging.SingleEmailMessage>();
            
            //REF-1316- Added check for CRP team member should be active
            List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
            String body = '';
            body = 'The Attribute \'' + attribute.Name + '\' change from ' + (isInherited ? 'not inheritable' : 'inheritable') + ' to ' + 
            		(isInherited ?  'inheritable' : 'not inheritable') + ' has been completed.\n';
            body += 'The following summarizes the number of records processed by this change.\n';
            body += '\'' + attributeCount + '\' Attributes\n';
            body += '\'' + accountAttributeCount + '\' referenceable Accounts (Account Attributes)\n';
            body += '\'' + contactAttributeCount + '\' referenceable Contacts (Contact Attributes)\n';
            body += '\'' + contentAttributeCount + '\' referenceable Content (Content Attributes)\n';

            for (User member : publicGroupMembers) {
                String userId = member.Id;
                
                if (userId.startsWith('005')) {
                    postFeedItems.add(MailChatterController.preparePost('', member.Id, body, ''));
                    listMail.add(MailChatterController.prepareEmail('Attribute \'' + attribute.Name + '\' inheritance change completed.', member.Id,
                        body, true));
                }
            }
            
            if (!listMail.isEmpty()) {
                Messaging.sendEmail(listMail);
            }
                
            if (!postFeedItems.isEmpty())
                Database.SaveResult[] postItems = database.insert(postFeedItems, false);
        }
    }
}