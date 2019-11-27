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
* Description: Test class for ReferenceWorkspaceSLDSController
* Created By: Dixita(March, 2018)
*/
@isTest(seeAllData = false)
public with sharing class TestRefWorkspaceControllerSLDS {
    @testSetup 
    static void setup() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, contacts);
        insert nominations;
        List<Reference_Basic_Information__c> rbiAccList = TestDataFactory.setUpAccountRBI(accounts);
        
        List<Reference_Basic_Information__c> rbiContactList = TestDataFactory.setUpContactRBI(contacts);
        List<Referenceability_Type__c> refTypeList = TestDataFactory.createReferenceabilityType();
        insert refTypeList;
        List<Reference_Request__c> refReqList = TestDataFactory.createReferenceRequest();
        insert refReqList;
        List<Reference_Request_Account__c> accReqList = TestDataFactory.createAccountRequests(accounts,refReqList,refTypeList);
        insert accReqList;
        List<Unspecified_Request__c> unReqList = TestDataFactory.createUnspecifiedRequest(refReqList,refTypeList);
        insert unReqList;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        
        system.assertEquals(true,(accounts.size() > 0 && nominations.size() > 0 && refTypeList.size() > 0));
    }
    
    static testMethod void testDefaults() {
        User u = TestDataFactory.CreateUser();
        insert u;
        
        try{
            test.startTest();
                String lastURId ,lastARId;
                String namespace = UtilityController.appNamespace();
                List<String> dataListDefault = (List<String>)JSON.deserialize(ReferenceWorkspaceSLDSController.getDefaults(),(List<String>.class)); 
                Map<Decimal,User_Mapping__c> selectionList = (Map<Decimal,User_Mapping__c>) JSON.deserialize(dataListDefault[0],(Map<Decimal,User_Mapping__c>.class));
                List<List<ReferenceWorkspaceSLDSController.FieldWrapper>> fieldsList = (List<List<ReferenceWorkspaceSLDSController.FieldWrapper>>) JSON.deserialize(dataListDefault[1],(List<List<ReferenceWorkspaceSLDSController.FieldWrapper>>.class));
                List<ReferenceWorkspaceSLDSController.FieldWrapper> requestFields = fieldsList[1];
                List<ReferenceWorkspaceSLDSController.FieldWrapper> nominationFields = fieldsList[0];
                Date criticalDate = dataListDefault[2] == null ? null : (Date) JSON.deserialize(dataListDefault[2],Date.class);
                Date cautionDate = dataListDefault[3] == null ? null :(Date) JSON.deserialize(dataListDefault[3],Date.class);
                Date managed_to_P2P_Min = dataListDefault[4] == null ? null : (Date) JSON.deserialize(dataListDefault[4],Date.class);
                Date nominationCriticalDate = dataListDefault[5] == null ? null : (Date) JSON.deserialize(dataListDefault[5],Date.class);
                Custom_Settings__c cs = (Custom_Settings__c) JSON.deserialize(dataListDefault[9],(Custom_Settings__c.class));
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getFields());
                Map<String,String> email = new Map<String,String>();
                email.put('Subject', 'Test Subject');
                email.put('Notes', 'Test Notes');
                email.put('WriteToNote', 'true');
                
                List<Id> existingIds = new List<Id>();
                String dataString = '';
                User_Mapping__c lastId = new User_Mapping__c();
                for (Decimal key : selectionList.keySet()) {
                    User_Mapping__c selection = selectionList.get(key);
                    if (key == 3 ) {
                        System.assertEquals(12, ReferenceWorkspaceSLDSController.updateNewView(String.valueOf(selection.Id),'11').Order__c);
                        createListViewFilters(String.valueOf(selection.Id));
                        dataString  = ReferenceWorkspaceSLDSController.getData(JSON.serialize(selection),JSON.serialize(existingIds),'','','DESC');
                        lastId = selection;
                    } else {
                        System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getData(JSON.serialize(selection), JSON.serialize(existingIds), '', '', 'DESC'));
                    }
                }
                System.assertEquals(true, ReferenceWorkspaceSLDSController.saveAsDefaultView(JSON.serialize(selectionList),'2'));
                
                List<String> dataList = (List<String>)JSON.deserialize(dataString,(List<String>.class));
                //List<Unspecified_Request__c> unspecifiedList = (List<Unspecified_Request__c>)JSON.deserialize(dataList[0],(List<Unspecified_Request__c>.class)); 
                List<Unspecified_Request__c> unspecifiedList = [SELECT Reference_Request__r.Case__c, Reference_Request__r.Opportunity__r.Name, Reference_Request__r.Case__r.CaseNumber,  
														Reference_Request__r.Opportunity__r.Account.Name, Reference_Request__r.Title__c, LastModifiedDate, 
														Id, Name, Reference_Request__r.Id, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, 
														Requester__r.Name, Deadline__c, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Project_Owner__r.Name, Unspecified_Request_Status__c 
														FROM Unspecified_Request__c 
														WHERE Specified_Account__c = null 
														AND Deadline__c != null 
														ORDER BY Deadline__c DESC LIMIT 2];
                //List<Reference_Request_Account__c> accountList = (List<Reference_Request_Account__c>)JSON.deserialize(dataList[1],(List<Unspecified_Request__c>.class)); 
                List<Reference_Request_Account__c> accountList = [SELECT Reference_Request__r.Opportunity__r.Account.Name, Reference_Request__r.Opportunity__r.Name,
														Reference_Request__r.Case__r.CaseNumber, Reference_Request__r.Title__c, LastModifiedDate, 
														Id, Name, Reference_Request__r.Id, CreatedDate, Reference_Request__r.Opportunity__c, CreatedById, Project_Owner__c, 
														Requester__r.Name, Account__c ,Account__r.Name, Process__c, Deadline__c, Managed_Request__c, Reference_Owner__c, 
														Project_Owner__r.Name, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Account_Request_Status__c , 
														(SELECT Contact__r.Name FROM Reference_Request_Account_Contacts__r)
														FROM Reference_Request_Account__c 
														WHERE Approval_Status__c = null 
														AND Deadline__c != null 
														AND (NOT Account_Request_Status__c LIKE 'Give Up%') 
														AND Reference_Use__c = false 
														ORDER BY Deadline__c DESC LIMIT 2];
                Id accountId = accountList[1].Account__c;
                List<Reference_Note__c> notes = TestDataFactory.createReferenceNoteReq(new List<Unspecified_Request__c> {unspecifiedList.get(0)},new List<Reference_Request_Account__c> {accountList.get(1)});
                List<Contact> contact = [SELECT Id from Contact WHERE AccountId =:accountId LIMIT 1];   
                Map<String,Map<String,Object>> recordsToDisplay = new Map<String,Map<String,Object>>();
                Boolean isNomination = false;
                
                for (Unspecified_Request__c ur: unspecifiedList) {
                    Map<String,Object> instance = new Map<String,Object>();
                    instance.put('Id', ur.Id);
                    instance.put('isUR', true);
                    instance.put('isAvailable', true);
                    instance.put('Mail', JSON.serialize(email));
                    instance.put('isEdit', false);
                    instance.put('Account__c', '');
                    instance.put('Contact__c', '');
                    instance.put('User__c', ur.Project_Owner__c);
                    instance.put('Reference_Type_Needed__c', ur.Reference_Type_Needed__c);
                    instance.put('isUR', true);

                    for (ReferenceWorkspaceSLDSController.FieldWrapper fieldObj : requestFields) {
                        if (fieldObj.fieldLabel == 'Account Requested') {
                            instance.put(fieldObj.fieldLabel , 'Unspecified');
                        } else if (fieldObj.fieldName.indexOf('.') != -1) {
                            String value = '';
                            List<String> fields = fieldObj.fieldName.split('.');
                            if (fields.size() == 1) {
                                value = String.valueOf(ur.get(fields[0]));
                            } else if (fields.size() == 2) {
                                String field = fields[0] + '.' + fields[1];
                                value = String.valueOf(ur.get(field));
                            } else if (fields.size() == 3) {
                                String field = fields[0] + '.' + fields[1] + '.' + fields[2];
                                value = String.valueOf(ur.get(field));
                            } else if (fields.size() == 4) {
                                String field = fields[0] + '.' + fields[1] + '.' + fields[2] + '.' + fields[3];
                                value = String.valueOf(ur.get(field));
                            } 
                            instance.put(fieldObj.fieldLabel , value);
                            
                        } else if (fieldObj.fieldName == 'dueColor'  && isNomination == false) {
                            String backgroundColor = '#FFFFFF';
                            
                                if (criticalDate != null && ur.Deadline__c < criticalDate) {
                                    backgroundColor = '#DD0000';
                                } else if (criticalDate != null && cautionDate != null && ur.Deadline__c >= criticalDate && ur.Deadline__c <= cautionDate) {
                                    backgroundColor = '#FFCC00';
                                } else if (cautionDate != null && ur.Deadline__c > cautionDate) {
                                    backgroundColor = '#00CC00';
                                }
                            instance.put(fieldObj.fieldLabel , backgroundColor);
                        } else if (fieldObj.fieldName == 'backgroundColor' && isNomination == true) {
                            String backgroundColor = '#FFFFFF';
                            
                            if (ur.CreatedDate <= nominationCriticalDate) {
                                backgroundColor = '#DD0000';
                            }
                            if (ur.CreatedDate > nominationCriticalDate) {
                                backgroundColor = '#00CC00';
                            }
                            instance.put(fieldObj.fieldLabel , backgroundColor);
                        }  else if (fieldObj.fieldName == 'Process__c') {
                            instance.put(fieldObj.fieldLabel , 'Managed');
                        } else if (fieldObj.fieldName == 'Account_Request_Status__c') {
                            instance.put(fieldObj.fieldLabel , ur.Unspecified_Request_Status__c);
                        } else if (fieldObj.fieldName == 'hasOpportunity') {
                            instance.put(fieldObj.fieldLabel , 'false');
                        } else {
                            instance.put(fieldObj.fieldLabel , ur.get(fieldObj.fieldName));
                        }
                    }
                    instance.put('Status','On Hold');
                    instance.put('Contact__c',contact.get(0).Id);
                    instance.put('Process','Managed');
                    instance.put('User__c',u.Id);
                    recordsToDisplay.put(String.valueOf(ur.Id),instance);
                    lastURId = String.valueOf(ur.Id);
                }

                for (Reference_Request_Account__c ur: accountList) {
                    Map<String,Object> instance = new Map<String,Object>();
                    instance.put('Id', ur.Id);
                    instance.put('isUR', true);
                    instance.put('isAvailable', true);
                    instance.put('Mail', JSON.serialize(email));
                    instance.put('isEdit', false);
                    instance.put('Account__c', ur.Account__c);
                    instance.put('User__c', ur.Project_Owner__c);
                    instance.put('Reference_Type_Needed__c', ur.Reference_Type_Needed__c);
                    instance.put('isUR', false);

                    for (ReferenceWorkspaceSLDSController.FieldWrapper fieldObj : requestFields) {
                        if (fieldObj.fieldName.indexOf('.') != -1) {
                            String value = '';
                            List<String> fields = fieldObj.fieldName.split('.');
                            if (fields.size() == 1) {
                                value = String.valueOf(ur.get(fields[0]));
                            } else if (fields.size() == 2) {
                                String field = fields[0] + '.' + fields[1];
                                value = String.valueOf(ur.get(field));
                            } else if (fields.size() == 3) {
                                String field = fields[0] + '.' + fields[1] + '.' + fields[2];
                                value = String.valueOf(ur.get(field));
                            } else if (fields.size() == 4) {
                                String field = fields[0] + '.' + fields[1] + '.' + fields[2] + '.' + fields[3];
                                value = String.valueOf(ur.get(field));
                                if (fieldObj.fieldLabel == 'Contact') {
                                    field = fields[0] + '.' + namespace + 'Contact__c';
                                    value = String.valueOf(ur.get(field)) ;
                                    instance.put('Contact__c' , value);
                                }
                            } 
                            instance.put(fieldObj.fieldLabel , value);
                            
                        } else if (fieldObj.fieldName == 'dueColor'  && isNomination == false) {
                            String backgroundColor = '#FFFFFF';
                            
                                if (criticalDate != null && ur.Deadline__c < criticalDate) {
                                    backgroundColor = '#DD0000';
                                } else if (criticalDate != null && cautionDate != null && ur.Deadline__c >= criticalDate && ur.Deadline__c <= cautionDate) {
                                    backgroundColor = '#FFCC00';
                                } else if (cautionDate != null && ur.Deadline__c > cautionDate) {
                                    backgroundColor = '#00CC00';
                                }
                            instance.put(fieldObj.fieldLabel , backgroundColor);
                        } else if (fieldObj.fieldName == 'backgroundColor' && isNomination == true) {
                            String backgroundColor = '#FFFFFF';
                            
                            if (ur.CreatedDate <= nominationCriticalDate) {
                                backgroundColor = '#DD0000';
                            }
                            if (ur.CreatedDate > nominationCriticalDate) {
                                backgroundColor = '#00CC00';
                            }
                            instance.put(fieldObj.fieldLabel , backgroundColor);
                        } else if (fieldObj.fieldName == 'hasOpportunity') {
                            instance.put(fieldObj.fieldLabel , 'false');
                        } else {
                            instance.put(fieldObj.fieldLabel , ur.get(fieldObj.fieldName));
                        }
                    }
                    instance.put('Status','On Hold');
                    instance.put('Contact__c',contact.get(0).Id);
                    instance.put('Process','Managed');
                    instance.put('User__c',u.Id);
                    recordsToDisplay.put(String.valueOf(ur.Id),instance);
                    lastARId = String.valueOf(ur.Id);
                }
                
                Map<String,Object> nullRequestIdAR = recordsToDisplay.get(lastARId);
                nullRequestIdAR.put('Contact__c',contact.get(0).Id);
                nullRequestIdAR.Put('Request Name', '');
                recordsToDisplay.put((nullRequestIdAR.get('Id') + '@1' ), nullRequestIdAR);
                
                Map<String,Object> nullRequestIdUR = recordsToDisplay.get(lastURId);
                nullRequestIdUR.Put('Request Name', '');
                nullRequestIdUR.Put('Account__c', accountId);
                nullRequestIdUR.Put('Contact__c', contact[0].Id);
                recordsToDisplay.put((nullRequestIdUR.get('Id') + '@1' ), nullRequestIdUR);
                Map<String,String> inlineEditResponse = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.saveInlineEdit(recordsToDisplay,'',String.valueOf(isNomination)) , Map<String,String>.class);
                System.assertEquals('true',inlineEditResponse.get('success'));
                
            //Stop test method
            test.stopTest();
        } catch(Exception ex){
            System.debug(ex.getLineNumber() + ex.getMessage() + '::' + ex.getStackTraceString());
        }
    }
    static testMethod void testNewProject() {
        User u = TestDataFactory.CreateUser();
        insert u;
        
        try{
            test.startTest();
                // Exception cases
                String invalid = 'Invalid';
                Map<String,Map<String,Object>> value = new Map<String,Map<String,Object>>();
                ReferenceWorkspaceSLDSController.saveInlineEdit(value,'','true');
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getDateFormat());
                List<List<ReferenceWorkspaceSLDSController.FieldWrapper>> tempFieldsList= (List<List<ReferenceWorkspaceSLDSController.FieldWrapper>>) JSON.deserialize(ReferenceWorkspaceSLDSController.getFields(), List<List<ReferenceWorkspaceSLDSController.FieldWrapper>>.class);
                List<ReferenceWorkspaceSLDSController.FieldWrapper> nominationFields = tempFieldsList.get(0);
                
                for (ReferenceWorkspaceSLDSController.FieldWrapper col : nominationFields) {
                    col.userMapping = new User_Mapping__c();
                    col.visible = false;
                    break;
                }
                List<ReferenceWorkspaceSLDSController.FieldWrapper> requestFields = tempFieldsList.get(1);

                for (ReferenceWorkspaceSLDSController.FieldWrapper col : requestFields) {
                    col.visible = false;
                    break;
                }
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.saveSelectedColumns(JSON.serialize(nominationFields),'true','true'));
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.saveSelectedColumns(JSON.serialize(requestFields),'false','true'));
                ReferenceWorkspaceSLDSController.getData(invalid, invalid, '', '', 'DESC');
                List<User_Mapping__c> viewList = new List<User_Mapping__c>();
                viewList.add(new User_Mapping__c());
                ReferenceWorkspaceSLDSController.createDefaultFilters(viewList);
                ReferenceWorkspaceSLDSController.createProject(JSON.serialize(invalid));
                List<Reference_Basic_Information__c> accountRBI = [SELECT Id, Account__c, Contact__c from Reference_Basic_Information__c WHERE Account__c != null AND Contact__c != null LIMIT 1];   
                List<Referenceability_Type__c> refType = [SELECT Id FROM Referenceability_Type__c LIMIT 1];
                //Delete view
                List<String> dataListDefault = (List<String>)JSON.deserialize(ReferenceWorkspaceSLDSController.getDefaults(),(List<String>.class)); 
                User_Mapping__c view = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c = null AND User__c = :UserInfo.getUserId() AND Order__c = 2 LIMIT 1];
                view.Visible__c = true;
                update view;
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getCount(JSON.serialize(view)));
                view = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, From_Mapping__c, Default_Value__c, Order__c FROM User_Mapping__c WHERE Label__c = null AND User__c = :UserInfo.getUserId() AND Order__c = 5 LIMIT 1];
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getCount(JSON.serialize(view)));
                System.assertNotEquals(null, ReferenceWorkspaceSLDSController.getCount('invalid'));
                System.assertEquals(String.valueOf(Integer.valueOf(view.Order__c)), ReferenceWorkspaceSLDSController.deleteViewEntry(view.Id));
                
                // Create New Project
                Map<String,String> newProject = new Map<String,String>();
                //Reference_Request__c refReq = TestDataFactory.createReferenceRequest().get(0);
                newProject.put('oppId','');
                newProject.put('oppName','');
                newProject.put('accountId','');
                newProject.put('accountName','');
                newProject.put('caseId','');
                newProject.put('caseName','');
                newProject.put('contactId','');
                newProject.put('contactName','');
                newProject.put('subject','');
                newProject.put('type','Member');
                newProject.put('deadline','');
                newProject.put('note','');
                newProject.put('refType','');
                newProject.put('accountRequired','false');
                newProject.put('contactRequired','false');
                newProject.put('caseRequired','false');
                newProject.put('oppRequired','false');
                newProject.put('noteRequired','false');
                newProject.put('subjectRequired','false');
                Map<String,String> returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('false',returnString.get('success'));
                newProject.put('caseRequired','true');
                newProject.put('noteRequired','true');
                newProject.put('contactRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('false',returnString.get('success'));
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('accountRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('false',returnString.get('success'));
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('deadline','' + System.today());
                newProject.put('type','Candidate');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
                newProject.put('type', 'Member');
                newProject.put('accountId', String.valueOf(accountRBI[0].Account__c));
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
                newProject.put('type', 'Member');
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('accountId', String.valueOf(accountRBI[0].Account__c));
                newProject.put('contactId', String.valueOf(accountRBI[0].Contact__c));
                newProject.put('contactRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
                accountRBI[0].Referenceability_Status__c = 'Inactive';
                update accountRBI;
                newProject.put('type', 'Member');
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('accountId', String.valueOf(accountRBI[0].Account__c));
                newProject.put('contactId', String.valueOf(accountRBI[0].Contact__c));
                newProject.put('contactRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
                accountRBI[0].Reference_Program_Candidate__c = true;
                accountRBI[0].Is_Referenceable__c = false;
                accountRBI[0].Referenceability_Status__c = '';
                update accountRBI;
                newProject.put('type', 'Candidate');
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('accountId', String.valueOf(accountRBI[0].Account__c));
                newProject.put('contactId', String.valueOf(accountRBI[0].Contact__c));
                newProject.put('contactRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
                newProject.put('type', 'Member');
                newProject.put('refType','' + refType.get(0).Id);
                newProject.put('accountId', String.valueOf(accountRBI[0].Account__c));
                newProject.put('contactId', String.valueOf(accountRBI[0].Contact__c));
                newProject.put('contactRequired','true');
                returnString = (Map<String,String>) JSON.deserialize(ReferenceWorkspaceSLDSController.createProject(JSON.serialize(newProject)) , Map<String,String>.class);
                System.assertEquals('true',returnString.get('success'));
            test.stopTest(); 
        } catch(Exception ex){
            System.debug(ex.getLineNumber() + ex.getMessage() + '::' + ex.getStackTraceString());
        }
    }

    static void createListViewFilters(Id viewId) {
        
        try{
            String namespace = UtilityController.appNamespace();
            List<User_Mapping__c> userMappingsList = new List<User_Mapping__c>();
            User_Mapping__c tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Unspecified_Request_Status__c::Unspecified Request Status::MULTIPICKLIST::equals::' + namespace + 'Unspecified_Request__c';
            tempUM.Default_Value__c = '';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Account_Request_Status__c::Managed Request Status::PICKLIST::equals::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = 'Not Started, On Hold';
            tempUM.Visible__c = true;
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Approval_Status__c::Approval Status::PICKLIST::equals::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = '';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Approval_Status__c::Approval Status::MULTIPICKLIST::not equal to::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = 'Approved';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'CreatedDate::Created Date::DATETIME::less or equal::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = '3/18/2018';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'CreatedDate::Created Date::DATETIME::less or equal::' + namespace + 'Unspecified_Request__c';
            tempUM.Default_Value__c = '3/18/2018';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Deadline__c::Deadline::DATE::not equal to::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = '3/18/2018';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Deadline__c::Deadline::DATE::not equal to::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = '';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'CreatedDate::Created Date::DATETIME::less or equal::' + namespace + 'Nomination__c';
            tempUM.Default_Value__c = '3/18/2018';
            userMappingsList.add(tempUM);
            tempUM = new User_Mapping__c(Process__c = 'WorkspaceSLDS', User__c = UserInfo.getUserId(), Label__c = viewId);
            tempUM.Field_API_Name__c = namespace + 'Time_to_Complete__c::Time to Complete::DOUBLE::not equal to::' + namespace + 'Reference_Request_Account__c';
            tempUM.Default_Value__c = '0';
            userMappingsList.add(tempUM);
            insert userMappingsList;

            
        } catch(Exception ex){
            System.debug(ex.getLineNumber() + ex.getMessage() + '::' + ex.getStackTraceString());
        }
    }
}