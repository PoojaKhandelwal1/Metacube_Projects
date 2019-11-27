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
 * Class: HitListReleaseActionController
 * Description : Class used to manage Hit list release Actions. 
 * Modified by: Rajesh @21 Feb 2017
 */
public with sharing class HitListReleaseActionController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Hit_List__c hitObject { get; set; }
    private String hitListId;
    private String retURL;
    private String retPage, retId;
    private Unspecified_Request__c unspecifiedRequest;
    private Reference_Request_Account__c accReq, accReq1;
    private Reference_Request_Account_Contact__c contactRequest;
    public List<Hit_List__c> updateOtherHitLists;
    public Boolean showRequestBlock { get; set; }
    private Reference_Basic_Information__c RBI;
    public Reference_Request__c refRequestObj { get; set; }
    public List<ReferenceRequestWrapper> allAccountReq { get; set; }
    
    /**
     * Constructor
     */
    public HitListReleaseActionController() {
        hitListId = ApexPages.currentPage().getParameters().get('Id');
        retURL = ApexPages.currentPage().getParameters().get('retURl');
        allAccountReq = new List<ReferenceRequestWrapper>();
        showRequestBlock = false;
        updateOtherHitLists = new List<Hit_List__c>();
        
        if (retUrl == null) {
            retPage = ApexPages.currentPage().getParameters().get('retPage');
            retId = ApexPages.currentPage().getParameters().get('retId');
        }

        for (Hit_List__c temp : [SELECT id, deadline__c, Email__c, Phone__c, disposition__c, released__c, Contact__c, referenceability_type__c, Unspecified_Request__c, 
        						Account__c, Account_Request__c, note__c, Reference_Request__c FROM hit_list__c WHERE Id = :hitListId]) {
            hitObject = temp;
            List<Reference_Basic_Information__c> rbiList = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c WHERE Contact__c = null AND 
            					Account__c = :temp.Account__c LIMIT 1];
        	RBI = (rbiList.size() > 0 ? rbiList[0] : new Reference_Basic_Information__c());
        }
        
        if (hitObject == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.Record_Not_Found));
        }
    }
    
    /**
     * Method to set account Request 
     */
    private void setAccountRequest() {
    	
        if (hitObject.Reference_Request__c != null) {
            refRequestObj = [SELECT Id, Name, Requester__c, Reference_Request_Status__c, Opportunity__c, Opportunity__r.Account.Name, 
            				(SELECT Id, Label__c FROM Reference_Request_Labels__r), (SELECT Id, Deadline__c, Reference_Type_Needed__c, Requester__c, Managed_Request__c, 
            				Account_Request_Status__c, Reference_Request_Additional_Info__r.Id, Account__c, Reference_Type_Needed__r.Name, Account__r.Name, Name, 
            				Request_Notes__c, Project_Owner__c, Project_Owner__r.Name, Process__c FROM Reference_Request_Accounts__r), (SELECT Id, Deadline__c, 
            				Reference_Type_Needed__c, Unspecified_Request_Status__c, Reference_Request_Additional_Info__r.Id, Request_Notes__c, Project_Owner__c, Requester__c, 
            				Specified_Account__c FROM Unspecified_Requests__r WHERE Specified_Account__c = null), (SELECT Id, Name, CreatedById, LastModifiedDate, 
            				LastModifiedById, Note__c FROM Reference_Notes__r) FROM Reference_Request__c WHERE id = :hitObject.Reference_Request__c LIMIT 1][0];
            				
            List<ReferenceRequestWrapper> tempActiveReq = new List<ReferenceRequestWrapper>();
            ReferenceRequestWrapper temp;
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Reference_Request_Account__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fldObjMap.get('Account_Request_Status__c').getDescribe().getPicklistValues();
            allAccountReq = new List<ReferenceRequestWrapper>();
            
            for (Reference_Request_Account__c rra : refRequestObj.Reference_Request_Accounts__r) {
                
                if (rra.Managed_Request__c) {
                    allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, rra, '', ConstantsController.MANAGED));
                } else {
                    allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, rra, '', ConstantsController.REP2REP));
                }
            }
            
            for (Unspecified_Request__c unSpec : refRequestObj.Unspecified_Requests__r) {
                allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, unSpec, '', ConstantsController.MANAGED));
            }
            
            if (allAccountReq.size() > 2) {
            	
                for (integer i = 0; i < allAccountReq.size() - 1; i++) {
                	
                    for (integer j = i + 1; j < allAccountReq.size(); j++) {
                    	
                        if (allAccountReq.get(i).deadline < allAccountReq.get(j).deadline) {
                            temp = allAccountReq.get(i);
                            allAccountReq.set(i, allAccountReq.get(j));
                            allAccountReq.set(j, temp);
                        }
                    }
                }
            }
            
            for (ReferenceRequestWrapper RRW : allAccountReq) {
            	
                if (RRW.status == null || RRW.status == '') {
                    tempActiveReq.add(RRW);
                }
            }
            
            for (Schema.PicklistEntry P : picklistEntries) {
            	
                for (ReferenceRequestWrapper RRW : allAccountReq) {
                	
                    if (RRW.status == P.getLabel()) {
                        tempActiveReq.add(RRW);
                    }
                }
            }
            allAccountReq.clear();
            allAccountReq.addAll(tempActiveReq);
        } else {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.NO_REQUEST_FOR_HIT_RECORD));
        }
    }
    
    /**
     * Method to save
     */
    public pageReference save() {
        Savepoint sp = Database.setSavepoint();
        
        try {
            List<Reference_Request_Account__c> accReqs = new List<Reference_Request_Account__c>();
            List<Reference_Request_Account_Contact__c> accConReqs = new List<Reference_Request_Account_Contact__c>();
            Map<Id, Unspecified_Request__c> updateUnspec = new Map<Id, Unspecified_Request__c>();
            Reference_Request_Account_Contact__c contactRequest;
            Reference_Request_Account__c accReq;
            
            if (hitObject.Disposition__c == 'Released: Contact Declined') {
                hitObject.Released__c = true;
                Task taskObject = new Task();
                taskObject.Subject = 'declined reference activity';
                taskObject.WhatId = hitObject.Account__c;
                taskObject.OwnerId = Userinfo.getUserId();
                taskObject.Priority = ConstantsController.NORMAL;
                taskObject.Status = ConstantsController.COMPLETED;
                WithoutSharingHelperController.insertTask(new List<Task> { taskObject });
            } else if (hitObject.Disposition__c == 'Released: Contact Unresponsive' || hitObject.Disposition__c == 'Released: No Longer Needed') {
                hitObject.Released__c = true;
            } else if (hitObject.Disposition__c == 'Agreed') {
            	
                for (ReferenceRequestWrapper rraw : allAccountReq) {
                	
                    if (rraw.isSelected != null && rraw.isSelected) {
                    	
                        if (rraw.isUR) {
                            accReq = new Reference_Request_Account__c();
                            accReq.Account__c = hitObject.Account__c;
                            accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                            accReq.Deadline__c = rraw.unSpec.Deadline__c;
                            accReq.Reference_Request__c = hitObject.Reference_Request__c;
                            accReq.Request_Notes__c = rraw.unSpec.Request_Notes__c;
                            accReq.Requester__c = rraw.unSpec.Requester__c;
                            accReq.Reference_Type_Needed__c = rraw.unSpec.Reference_Type_Needed__c;
                            accReq.Reference_Request_Additional_Info__c = rraw.unSpec.Reference_Request_Additional_Info__c;
                            accReq.Managed_Request__c = true;
                            accReq.Project_Owner__c = RBI.Reference_Owner__c;
                            accReqs.add(accReq);
                        } else {
                            accReq = new Reference_Request_Account__c();
                            accReq.Account__c = hitObject.Account__c;
                            accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                            accReq.Deadline__c = rraw.rra.Deadline__c;
                            accReq.Reference_Request__c = hitObject.Reference_Request__c;
                            accReq.Request_Notes__c = rraw.rra.Request_Notes__c;
                            accReq.Requester__c = rraw.rra.Requester__c;
                            accReq.Reference_Type_Needed__c = rraw.rra.Reference_Type_Needed__c;
                            accReq.Reference_Request_Additional_Info__c = rraw.rra.Reference_Request_Additional_Info__c;
                            accReq.Managed_Request__c = true;
                            accReq.Project_Owner__c = RBI.Reference_Owner__c;
                            accReqs.add(accReq);

                            rraw.rra.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                            accReqs.add(rraw.rra);
                        }
                    }
                }
                
                if (accReqs.size() > 0) {
                    WithoutSharingHelperController.upsertRRAList(accReqs);
                } else {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.SELECT_REQUEST));
                    return null;
                }
                
                if (hitObject.Contact__c != null) {
                	
                    for (Reference_Request_Account__c rra : accReqs) {
                       
                        if (rra.Account_Request_Status__c != ConstantsController.UNAVAILABLE) {
                        	
                            contactRequest = new Reference_Request_Account_Contact__c();
                            contactRequest.Contact__c = hitObject.Contact__c;
                            contactRequest.Contact_Email__c = hitObject.Email__c;
                            contactRequest.Contact_Phone__c = hitObject.Phone__c;
                            contactRequest.Deadline__c = rra.Deadline__c;
                            contactRequest.Project_Owner__c = rra.Project_Owner__c;
                            contactRequest.Contact_Request_Status__c = rra.Account_Request_Status__c;
                            contactRequest.Reference_Request_Account__c = rra.Id;
                            contactRequest.Referenceability_Type__c = rra.Reference_Type_Needed__c;
                            contactRequest.Request_notes__c = rra.Request_Notes__c;
                            accConReqs.add(contactRequest);
                        }
                    }
                }
                
                for (Reference_Request_Account__c rra : accReqs) {
                	
                    for (ReferenceRequestWrapper rraw : allAccountReq) {
                    	
                        if (rraw.isUR && rraw.isSelected) {
                        	
                            if (rraw.unSpec.Deadline__c == rra.Deadline__c && rraw.unSpec.Reference_Type_Needed__c == rra.Reference_Type_Needed__c && rraw.unSpec.Request_Notes__c == rra.Request_Notes__c) {
                                rraw.unSpec.Specified_Account__c = rra.Id;
                                rraw.unSpec.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                                updateUnspec.put(rraw.unSpec.Id, rraw.unSpec);
                            }
                        }
                    }
                }
                
                if (updateUnspec.size() > 0) {
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    WithoutSharingHelperController.updateUnspecified(updateUnspec.values());
                }
                
                if (accConReqs.size() > 0) {
                    WithoutSharingHelperController.upsertRRACList(accConReqs);
                }
            }
            updateOtherHitLists.add(hitObject);
            
            if (updateOtherHitLists.size() > 0) {
                WithoutSharingHelperController.updateHitList(updateOtherHitLists);
            }
            //redirect back to previous page.
            return redirectBack();  
                  
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
    }
    
    /**
     * Method to show Request block
     */
    public void showRequestBlock() {
    	
        if (hitObject.Disposition__c == 'Agreed') {
            setAccountRequest();
        } else {
            allAccountReq = new List<ReferenceRequestWrapper>();
        }
    }
    
    /**
     * Method to cancel  
     */
    public pageReference redirectBack() {   
        //re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous page.
		if (retUrl != '' && retUrl != null) {
			return UtilityController.redirectToSource(retUrl); 
		} else if (retPage != null) {
			
			if (retId != null) {  
                 return UtilityController.redirectToSource(retPage + '?Id=' + retId);
			} else if (retPage != null) { 
                return UtilityController.redirectToSource(retPage);
            } else {
            	return new pageReference('/home/home.jsp');
            }
		} else {				
			 if (hitListId != null) {
				return new PageReference('/' + hitListId); 
			 } else {	
        		return new pageReference('/home/home.jsp');
        	}
		}
    }
}