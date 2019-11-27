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
 * VF Page: ReminderAction.page
 * Description: controller for creating task and sending a reminder to user
 *				(opened from aggregate hit list tab)
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class ReminderActionController extends RefEdgeEditionFeatures {
    
    public Task taskObject { get; set; }
    public list<selectOption> reminderTime { get; set; }
    public String timeSelected { get; set; }
    public Date reminderDate { get; set; }
    public String hitRecordId;
    private String retUrl;
    private String retId;
    public Boolean sendEmail { get; set; }
    public Hit_List__c hitListObject { get; set; }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put('Task', new Set<String>{'IsReminderSet', 'ReminderDateTime', 'WhatId', 'Priority', 'OwnerId', 'Status'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isUpsertPermission;
    }
    
    /**
     * constructor
     */
    public ReminderActionController() {
        checkPermissions();
        taskObject = new Task(Subject = 'Hit List Reminder');
        sendEmail = false;
        reminderTime = new list<selectOption>();
        reminderTime.add(new SelectOption('0:00', '12:00 AM'));
        reminderTime.add(new SelectOption('0:30', '12:30 AM'));
        hitRecordId = ApexPages.currentPage().getParameters().get('Id');
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        hitListObject = new Hit_List__c();
        
        if (retUrl == null) {
            retId = ApexPages.currentPage().getParameters().get('retId');   
        }
        
        if (hitRecordId != null) {
            List<Hit_List__c> hitList = WithoutSharingHelperController.getHitList(hitRecordId);
            
            if (hitList.size() > 0) {
                hitListObject = hitList[0];
                String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefRequestProject.geturl()
                					+ '?Id=' + hitList[0].Reference_Request__c;
                String descriptionString = 'Hit List Reminder for \nAccount: ' + hitList[0].Account__r.Name
                							+ (hitList[0].Contact__c != null
                								? '\nContact: ' + hitList[0].Contact__r.Name : '')
            								+'\n' + LINK_URL;
                taskObject.Description = descriptionString;
            }
        }
        decimal value = 1.00;
        String timeString = '';
        
        while (value < 12.00) {
            timeString = string.valueOF(value) + ' AM';
            String timeValue = value + '';
            
            if (timeString.contains('.50')) {
                timeString = timeString.replace('.50', ':30');
                timeValue = timeValue.replace('.50', ':30');
            }
            
            if (timeString.contains('.00')) {
                timeString = timeString.replace('.00', ':00');
                timeValue = timeValue.replace('.00', ':00');
            }
            reminderTime.add(new SelectOption(timeValue, timeString));
            value += 00.50; 
        }
        reminderTime.add(new SelectOption('12:00', '12:00 PM'));
        reminderTime.add(new SelectOption('12:30', '12:30 PM'));
        value = 1.00;
        
        while (value < 12.00) {
            timeString = string.valueOF(value) + ' PM';
            String timeValue = 12 + value + '';
            
            if (timeString.contains('.50')) {
                timeString = timeString.replace('.50', ':30');
                timeValue = timeValue.replace('.50', ':30');
            }
            
            if (timeString.contains('.00')) {
                timeString = timeString.replace('.00', ':00');
                timeValue = timeValue.replace('.00', ':00');
            }
            reminderTime.add(new SelectOption(timeValue, timeString));
            value += 00.50; 
        }
    }
    
    /**
     * method to save task
     */
    public pageReference saveTask() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            taskObject.IsReminderSet = true;            
	            Time reminderTime = Time.newInstance(Integer.valueOf(timeSelected.split(':')[0]),
	        											Integer.valueOf(timeSelected.split(':')[1]), 0, 0);
	            taskObject.ReminderDateTime = DateTime.newInstance(reminderDate, reminderTime);
	            
	            if (taskObject.ReminderDateTime < system.now()) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.INVALID_TIME));
	                return null;
	            }
	            taskObject.WhatId = hitRecordId;
	            taskObject.Priority = 'Normal';
	            taskObject.Status = 'Not Started';
	            taskObject.OwnerId = Userinfo.getUserId();
	            
	            if (sendEmail) {
	                Database.DMLOptions dmlo = new Database.DMLOptions(); 
	                dmlo.EmailHeader.triggerUserEmail = true; 
	                database.insert(taskObject, dmlo);
	            } else {
	                insert taskObject;
	            }
	            
	            // re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous page.    
	            if (retUrl != null) {
	            	return UtilityController.redirectToSource(retUrl); 
	            } else if (retId != null) {
	                return new pageReference(Page.RefRequestProject.geturl() + '?Id=' + retId);
	            } else {
	                return new pageReference(Page.AggregateHitList.geturl());
	            }
	        } catch(Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }
    
    public pageReference cancel() {
    	
        if (retUrl != null) {
           return UtilityController.redirectToSource(retUrl);
        } else if (retId != null) {
            return new pageReference(Page.RefRequestProject.geturl() + '?Id=' + retId);
        } else {
            return new pageReference(Page.AggregateHitList.geturl());
        }
    }
}