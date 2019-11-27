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
 * VF Page: RefProspectorSettingsPage.page
 * Description: controller for custom setting inline page with Ref prospector fields
 * Author: Gaurav Saini (7 Nov, 2017)
 */
public with sharing class RefProspectorSettingsController extends RefEdgeEditionFeatures {
    
    public RefProspectorSettingsController() {}
    
    /**
     * method to check permissions
     * author: Gaurav Saini (8 Nov, 2017)
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Ref_Prospector_Subject__c',
    											UtilityController.appNamespace() + 'Ref_Prospector_Body__c',
    											UtilityController.appNamespace() + 'Ref_Prospector_Hdr_Txt__c',
    											UtilityController.appNamespace() + 'Ref_Prospector_SubHdr_Txt__c',
    											UtilityController.appNamespace() + 'Ref_Prosepector_Lead_Owner__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * method to get permissions message
     * author: Gaurav Saini (8 Nov, 2017)
     */
    @RemoteAction
    public static String getPermissionsMessage() {
    	checkPermissions();
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * method to get custom settings data for ref prospector
     * author: 7 Nov, 2017
     */
    @RemoteAction
    public static String getRefProspectData() {
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	CustomSettingWrapper csWrapper = new CustomSettingWrapper(cs);
    	return JSON.serialize(csWrapper);
    }
    
    /**
     * method to get picklist values for ref lead owner field
     * author: 7 Nov, 2017
     */
    @RemoteAction
    public static String getRefLeadOwnerOptions() {
    	Map<String, Schema.sObjectField> fieldsMap = Schema.sObjectType.Account.fields.getMap();
    	List<OptionWrapper> userLookupFields = new List<OptionWrapper>();
    	userLookupFields.add(new OptionWrapper('', '--None--'));
    	
    	for (String fieldAPIName : fieldsMap.keySet()) {
    		Schema.DescribeFieldResult dfr = fieldsMap.get(fieldAPIName).getDescribe();
    		
    		if (String.valueOf(dfr.getType()) == 'REFERENCE' && String.valueOf(dfr.getReferenceTo()) == '(User)') {
    			userLookupFields.add(new OptionWrapper(String.valueOf(dfr.getName()), String.valueOf(dfr.getLabel())));
    		}
    	}
    	return JSON.serialize(userLookupFields);
    }
    
    /**
     * method to save custom settings data for ref prospector
     * author: 7 Nov, 2017
     */
    @RemoteAction
    public static String saveCustomSettings(String csWrapperJSON) {
    	String result = '';
    	Savepoint sp = Database.setSavepoint();
    	
    	try {
    		CustomSettingWrapper csWrapper = (CustomSettingWrapper)JSON.deserialize(csWrapperJSON, CustomSettingWrapper.class);
	    	Custom_Settings__c cs = new Custom_Settings__c();
	    	cs.Id = csWrapper.csId;
	    	cs.Ref_Prospector_Subject__c = csWrapper.subject;
	    	cs.Ref_Prospector_Body__c = csWrapper.body;
	    	cs.Ref_Prospector_Hdr_Txt__c = csWrapper.headerText;
	    	cs.Ref_Prospector_SubHdr_Txt__c = csWrapper.subHeaderText;
	    	cs.Ref_Prosepector_Lead_Owner__c = csWrapper.refLeadOwner;
	    	cs.Ref_Prospector_Enable__c = csWrapper.enableRefProspector;
	    	update cs;
	    	result = 'success';
    	} catch(Exception e) {
    		Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return result;
    }
    
    public class CustomSettingWrapper {
    	public String csId { get; set; }
    	public String subject { get; set; }
    	public String body { get; set; }
    	public String headerText { get; set; }
    	public String subHeaderText { get; set; }
    	public String refLeadOwner { get; set; }
    	public String leadCount { get; set; }
    	public String campaignLeadCount { get; set; }
    	public Boolean enableRefProspector { get; set; }
    	
    	public CustomSettingWrapper(Custom_Settings__c cs) {
    		this.csId = cs.Id;
    		this.subject = cs.Ref_Prospector_Subject__c != null ? cs.Ref_Prospector_Subject__c : '';
    		this.body = cs.Ref_Prospector_Body__c != null ? cs.Ref_Prospector_Body__c : '';
    		this.headerText = cs.Ref_Prospector_Hdr_Txt__c != null ? cs.Ref_Prospector_Hdr_Txt__c : '';
    		this.subHeaderText = cs.Ref_Prospector_SubHdr_Txt__c != null ? cs.Ref_Prospector_SubHdr_Txt__c : '';
    		this.refLeadOwner = cs.Ref_Prosepector_Lead_Owner__c != null ? cs.Ref_Prosepector_Lead_Owner__c : '';
    		this.leadCount = cs.Ref_Prospector_Lead_Count__c != null
    							? cs.Ref_Prospector_Lead_Count__c + '' : '0';
    		this.campaignLeadCount = cs.Ref_Prospector_Campaign_Lead_Count__c != null
    									? cs.Ref_Prospector_Campaign_Lead_Count__c + '' : '0';
    		this.enableRefProspector = cs.Ref_Prospector_Enable__c;
    	}
    }
    
    public class OptionWrapper {
    	public String value { get; set; }
    	public String label { get; set; }
    	
    	public OptionWrapper(String value, String label) {
    		this.value = value;
    		this.label = label;
    	}
    }
}