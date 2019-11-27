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
 * VF Page: Custom Setting->Profile Update Minder Settings  
 * Description: Used to handle Profile Minder Settings 
 * Last modified by:  Rajesh @Feb 10 2017
 */
public with sharing class ReferenceRefreshSettings extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String recordId;
    private String prevFrequency; 
    public Custom_Settings__c customSetting { get; set; }
    public Boolean isEdit { get; set; } 
    public Boolean isMatched { get; set; } 
    public Boolean isBatchProcess { get; set; } 
	public String rrKeyPerfix { get; set; }
	// re #805 - Add variable to check launch button is clicked 
	public Boolean isLaunchClicked { get; set; } 
	
    /**
     * Constructor
     */
    public ReferenceRefreshSettings(ApexPages.StandardController controller) {
        recordId = ApexPages.currentPage().getParameters().get('customSettingId');
        checkPermissions();
        refresh();
        
        DescribeSObjectResult rr = Reference_Refresh__c.sObjectType.getDescribe();
        rrKeyPerfix = rr.getKeyPrefix();
    }
    
	/**
     * Method to edit
     */
	public void editTheSettings() {
        isEdit = true;
    }
	
    /**
     * Method to refresh
     */
    public void refresh() {
        //Find custom setting
        for (Custom_Settings__c cs : [SELECT Enable_Reference_Refresh__c, Id, Manual_Automatic_Launch__c, Launch_Frequency__c, Next_Refresh_launch_Date__c, 
    									Last_Refresh_Date__c, Refresh_Wait_Days__c, Quarantine_updates__c, cloneTriggerId__c, Reviewed_and_Ready_to_Launch__c 
        							 	FROM Custom_Settings__c WHERE Id = :recordId ]) {
            customSetting = cs;
            prevFrequency = customSetting.Launch_Frequency__c;
        }
        
        //Check record match or not
        isMatched = false;
        Date todayDate = Date.Today();
        
        for (Reference_Basic_Information__c rbi : [SELECT Managed_Reference_Account__c, Profile_Update_Owner__c, Last_Refresh_Date__c, Last_Refresh_Sent__c,
        											(SELECT Id, Reference_Refresh_Status__c, Is_Active__c,Quarantined__c FROM Reference_Refreshs__r WHERE Is_Active__c = true)
        									 		FROM Reference_Basic_Information__c WHERE Contact__c = null AND Is_Referenceable__c = true 
        									 		AND (Referenceability_Status__c = 'Active' OR Referenceability_Status__c = 'Caution')]) {
            Boolean isMatchedR = false;
            
            if (!rbi.Managed_Reference_Account__c || (rbi.Managed_Reference_Account__c && rbi.Profile_Update_Owner__c != null)) {
            	
            	if ((rbi.Last_Refresh_Date__c != null && rbi.Last_Refresh_Date__c.dateGMT().daysBetween(todayDate) >= customSetting.Refresh_Wait_Days__c) &&
                	(rbi.Last_Refresh_Sent__c == null || (rbi.Last_Refresh_Sent__c != null && rbi.Last_Refresh_Sent__c.dateGMT().daysBetween(todayDate) >= customSetting.Refresh_Wait_Days__c))) {
                	isMatchedR = true;
                }
                
                if (rbi.Reference_Refreshs__r.size() > 0 && rbi.Reference_Refreshs__r.get(0).Quarantined__c 
			                && (rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Profile Updated' 
			                || rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Pending Approval')) {
                	isMatchedR = false;
                }
            }
            
            if (isMatchedR) {
            	isMatched = isMatchedR;
            }
        }
        
        //Check batch running or not
        Set<String> setApexJob = new Set<String>();
        
        for (AsyncApexJob aaj : [SELECT Status, ApexClassId FROM AsyncApexJob WHERE (JobType = 'BatchApex'OR JobType = 'ScheduledApex') 
        							AND Status NOT IN ('Aborted', 'Completed', 'Failed') LIMIT :limits.getLimitQueryRows()]) {
            setApexJob.add(aaj.ApexClassId);
        }

        Set<String> apexClasses = new Set<String>();
        
        for (ApexClass ac : [SELECT Name, Id FROM ApexClass WHERE Id IN :setApexJob LIMIT :limits.getLimitQueryRows()]) {
            
            if (ac.Name == 'Batch_ReferenceRefreshCreation') {
                apexClasses.add(ac.Name.toLowerCase().trim());
            }
        }
        isBatchProcess = (apexClasses.size() > 0 ? true : false);
                
        isEdit = false;
    }
	
	/**
     * Method to launch link
     */
    public void launchLink() { 
    	isMatched = false;
    	isBatchProcess = true;
    	isLaunchClicked = false;
        Database.executeBatch(new Batch_ReferenceRefreshCreation(true));
    }
	
    /**
     * Method to launch
     */
    public void launchReferenceRefresh() {
    	isMatched = false;
    	isBatchProcess = false;
    	customSetting.Reviewed_and_Ready_to_Launch__c = false;
    	update customSetting;
        Database.executeBatch(new Batch_ReferenceRefreshCreation());
        isLaunchClicked = true;
    }
	
	/**
     * Method to changeLaunchProcess
     */
	public void changeLaunchProcess() {
        customSetting.Reviewed_and_Ready_to_Launch__c = false;
    }
	
    /**
     * Method to Save
     */
    public void saveTheSettings() {
        try {
        	
        	if (checkPermissions()) {
	            List<CronTrigger> listCronTrigger = [SELECT Id FROM CronTrigger WHERE id = :customSetting.cloneTriggerId__c LIMIT :limits.getLimitQueryRows()];
	            
	            if (customSetting.Manual_Automatic_Launch__c == 'Automatic') {
	                
	                if (customSetting.Next_Refresh_launch_Date__c == null) {
	                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.Next_Update_Launch_Date));
	                    return;
	                }
	                
	                if (customSetting.Next_Refresh_launch_Date__c < date.today()) {
	                	Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.RefreshLaunchDateValidation));
		                return;
		            }
		            
	                if (customSetting.Launch_Frequency__c != null) {
	                   
	                    if (listCronTrigger.size() > 0) {
	                        System.abortJob(customSetting.cloneTriggerId__c);
	                    }
	                    Schedular_ReferenceRefresh tempSchedule = new Schedular_ReferenceRefresh();
	                    Datetime dt = customSetting.Next_Refresh_launch_Date__c;
	                    String timeForScheduler = '0 0 1 ' + dt.day() + ' ' + returnMonth(dt.month(), customSetting.Launch_Frequency__c) + ' ?';
	                    Id scheduleId = system.schedule('RefEdge_ProfileUpdate: ' + customSetting.Launch_Frequency__c, timeForScheduler, tempSchedule);
	
	                    customSetting.cloneTriggerId__c = scheduleId;
	                }
	                
	                update customSetting;
	            } else if (customSetting.Manual_Automatic_Launch__c == null || customSetting.Manual_Automatic_Launch__c == 'Manual') {
	               
	                if (listCronTrigger.size() > 0) {
	                    System.abortJob(customSetting.cloneTriggerId__c);
	                }
	                customSetting.cloneTriggerId__c = null;
	                
	                update customSetting;
	            }
	            isEdit = false;
        	}
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(message);
        }
    }

    /**
     * Method to cancel
     */
    public void cancel() {
        refresh();
    }

    /**
     * Method to Return Custom Settings
     */
    public pageReference returnCustomSettings() {
        return new PageReference('/' + recordId);
    }

    /**
     * Method to calculate months
     */
    private String returnMonth(Integer month, String launchFreq) {
        String scheduledMonth;
        
        if (launchFreq == 'Monthly') {
            scheduledMonth = '*';
        } else if (launchFreq == 'Quarterly') {
            scheduledMonth = addMonths(month, 3);
        } else if (launchFreq == 'Semi-Annually') {
            scheduledMonth = addMonths(month, 6);
        } else if (launchFreq == 'Annually') {
            scheduledMonth = ' ' + month;
        }
        return scheduledMonth;
    }

    /**
     * Method to addMonths
     */
    private string addMonths(Integer month, Integer monthVal) {
        string finalExp = '';
        Integer tempMonth = month;
        
        for (Integer i = 0; i < 12 / monthVal; i++) {
            finalExp += (finalExp == '' ? '' + tempMonth : ',' + tempMonth);
            tempMonth = (tempMonth + monthVal > 12 ? tempMonth + monthVal - 12 : tempMonth + monthVal);
        }
        return finalExp;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        										UtilityController.appNamespace() + 'cloneTriggerId__c',
        										UtilityController.appNamespace() + 'Reviewed_and_Ready_to_Launch__c'});  
        										
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
        return isUpsertPermission; 
    }
}