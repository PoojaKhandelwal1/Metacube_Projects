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
 * Page: RewardSettings
 * Description : Class used to update user and sales points of referenceability types.
 * Modified by: Rajesh @June 2 2017
 */
public with sharing class RewardSettingsController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String customSettingId;
    public Custom_Settings__c customSetting { get; set; }
    public List<Referenceability_Type__c> refTypes { get; set; }
    public List<Referenceability_Type__c> salesRefTypes { get; set; }
    public Boolean isEdit { get; set; }
    public Boolean isMinderSetting { get; set; }
    
    /**
     * Constructor
     */
    public RewardSettingsController() {        
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        String minderSetting = apexPages.currentPage().getParameters().get('manage');
        refTypes = new List<Referenceability_Type__c>();
        salesRefTypes = new List<Referenceability_Type__c>();
        
        //Added this change for #117  Sales reward minder setting
        if (minderSetting !=  null && minderSetting == 'true') {
            isMinderSetting = true;
            List<Custom_Settings__c> cs =  [SELECT Sales_Reward_Batch_Trigger_Id__c, Enable_Sales_Rewards_Notification__c, Id, Reward_Minder_Settings__c,
                Sales_Rewards_Notification_Frequency__c,Next_Notification_Date__c,Last_Notification_Date__c
                FROM Custom_Settings__c WHERE Id = :customSettingId ];
            
            if (cs.size() > 0) {
            	customSetting = cs[0];
            }
        } else {
            customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
            isEdit = false;
            
            for (Referenceability_Type__c ref : [SELECT Reward_points__c, Sales_Point__c, Name, Sales_Reward__c, Id, Visible__c FROM Referenceability_Type__c WHERE Visible__c = true
            					ORDER BY Name  LIMIT : limits.getLimitQueryRows()]) {
            	
            	if (ref.Sales_Reward__c && ref.Visible__c) {
            		salesRefTypes.add(ref);
            	} else {
            		refTypes.add(ref);
            	}
            }
            isMinderSetting = false;
        }
        checkPermissions(true, '');
    }

    /**
     * Method to Edit Reward Settings
     */
    public pageReference editRewardSettings() {
        isEdit = true;
        return null;
    }

    /**
     * Method to Update Referenceability Types
     */
    public pageReference saveReferenceabilityTypes() {
    	
    	if (checkPermissions(false, 'Referenceability_Type__c')) {
    		
	        try {
	            update refTypes;
	            update salesRefTypes;
	            isEdit = false;
	        } catch (Exception e) {
	            Apexpages.addMessages(e);
	        }
    	}
        return null;
    }

    /**
     * Method to Update Save Reward Minder Setting //Added this change for #117  Sales reward minder setting
     */
    public void saveSalesRewardMinderSettting() {
    	
    	if (checkPermissions(false, 'Custom_Settings__c')) {
	        List<CronTrigger> listCronTrigger = [SELECT Id FROM CronTrigger WHERE id = : customSetting.Sales_Reward_Batch_Trigger_Id__c 
	        										LIMIT : limits.getLimitQueryRows()];
	        
	        if (customSetting.Enable_Sales_Rewards_Notification__c ==  true) {
	            
	            //When no frequency selected
	            if (customSetting.Sales_Rewards_Notification_Frequency__c == null || customSetting.Sales_Rewards_Notification_Frequency__c == '') {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.Sales_Reward_Notification_Frequency));
	                return;
	            }
	            
	           	if (customSetting.Next_Notification_Date__c == null) {
	             	Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.Sales_Reward_Notification_Date_Mention));
	                return;
	            }
	            
	            //When date is before today
	            if (customSetting.Next_Notification_Date__c < date.today()) {
	                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.Sales_Reward_Next_Notification_Date));
	                return;
	            } 
	            
	            Schedular_SalesRewardNotification notificationSchedular = new Schedular_SalesRewardNotification();
	            Datetime dt = customSetting.Next_Notification_Date__c; 
	            String timeForScheduler = '';
	            
	            if (customSetting.Sales_Rewards_Notification_Frequency__c == 'Weekly') {//re #283 
	            	dt = dt.addDays(7);
	            	timeForScheduler= '0 0 1 ' + dt.day() + ' ' + dt.month() + ' ?';
	            } else {
	           		timeForScheduler= '0 0 1 ' + dt.day() + ' ' + returnMonth(dt.month(), customSetting.Sales_Rewards_Notification_Frequency__c) + ' ?';
	            } 
	            
	            try {
	                    
	                if (listCronTrigger.size() > 0) {
	                    System.abortJob(customSetting.Sales_Reward_Batch_Trigger_Id__c);
	                }
	                //Scheduleing Batch
	                Id scheduleId = System.schedule('Job Sales Reward Notification : ' + customSetting.Sales_Rewards_Notification_Frequency__c, 
	                								timeForScheduler, notificationSchedular);
	                customSetting.Sales_Reward_Batch_Trigger_Id__c = scheduleId;
	                update customSetting;
	            } catch (Exception e) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            	Apexpages.addMessage(message);
	            }
	        
	        } else {
	        	
	            if (listCronTrigger.size() > 0) {
	             	System.abortJob(customSetting.Sales_Reward_Batch_Trigger_Id__c);
	            }
	        }
	        isEdit = false;
    	}
    }
    
    /**
     * Method to return Custom Setting
     */
    public pageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }

    /**
     * Method to return Reward Settings
     */
    public pageReference returnRewardSettings() {
        PageReference returnPage = new PageReference(Page.RewardSettings.geturl() + '?customSettingId=' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to return Sales Reward Minder Settings //Added this change for #117  Sales reward minder setting
     */
    public pageReference returnSalesRewardMinderSettings() {
        PageReference returnPage = new PageReference(Page.RewardSettings.geturl() + '?customSettingId=' + customSettingId + '&manage=true');
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to calculate months
     */
    private string returnMonth(Integer month, String launchFreq) {
        string scheduledMonth;
        
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
    public Boolean checkPermissions(Boolean both, String action) {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	if (both == true || action == 'Custom_Settings__c') {
    		fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
        									UtilityController.appNamespace() + 'Sales_Reward_Batch_Trigger_Id__c' });
    	}
    	
    	if (both == true || action == 'Referenceability_Type__c') {
    		fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String>());
    	}
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
}