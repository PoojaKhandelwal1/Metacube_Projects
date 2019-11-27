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
 * Page : RefedgeSetupHomePage
 * Description : This class called from RefedgeSetupHomePage to provide all setup things
 * Modified by: Rekha Jangir @Feb 14 2016
 */
public with sharing class RefedgeSetupHomeController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String porAppConfigurationKeyPerfix { get; set; }
    public Boolean isEditionKey { get; set; }
    public String micrositePrefix { get; set; }
    public String groupName { get; set; }
    public String publicGroupId { get; set; }
    public List<Microsite__c> listMicrosite { get; set; }
    public Boolean isSiteSetNativeCustomSetting { get; set; }
    public List<Profile> salespersonProfile { get; set; }
    public List<Profile> reManagerProfile { get; set; }
    //public List<PermissionSet> salespersonPS { get; set; }
    //public List<PermissionSet> reManagerPS { get; set; }
    public Boolean isUpdateReferenceabilityTypes { get; set; }
    public Boolean isUpdateReferenceProfiles { get; set; }
    public Boolean isUpdateReferenceContent { get; set; }
    public Boolean isCreateRequestInvitationRecords { get; set; }
    public Boolean isUpdateRewardDeclinedRequestRecord { get; set; }
    public Boolean isProgressReferenceabilityTypes { get; set; }
    public Boolean isProgressReferenceProfiles { get; set; }
    public Boolean isProgressReferenceContent { get; set; }
    public Boolean isProgressRequestInvitationRecords { get; set; }
    public Boolean isProgressRewardDeclinedRequestRecord { get; set; }
    public Boolean isUpdateRefedgeCustomSetting { get; set; }
    public Boolean isProgressAccountContactRequests { get; set; }
    public Boolean isUpdateAccountContactRequests { get; set; }
    public Boolean isUpdateFilters { get; set; }
    public Boolean isUpdateAttributes { get; set; }
    public Boolean isProgressFilterNumbers { get; set; }
    public Boolean isUpdateFilterNumbers { get; set; }
    public Boolean isProgressContactAvailablePoints { get; set; }
    public Boolean isUpdateContactAvailablePoints { get; set; }
    public Boolean isProgressProfileUpdates { get; set; }
    public Boolean isUpdateProfileUpdates { get; set; }
    public Boolean isProgressInfluitiveDataSync { get; set; }
    public Boolean isUpdateInfluitiveDataSync { get; set; }
    public Boolean isProgressContactAttributes { get; set; }
    public Boolean isUpdateContactAttributes { get; set; }
    public Boolean isUpdateInheritableAttributes { get; set; }
    public Boolean isCreateSalesReward { get; set; }
    public Boolean isAllowSalesReward { get; set; }
    public Boolean isInfluitiveEnabled { get; set; }
    public String psName { get; set; }
    public Boolean isProgressRBIPointsUpdates { get; set; }
    public Boolean isUpdateRBIPoints { get; set; } 
    // Related To #1184
    public Boolean isProgressUpdateAttributeInRefContent { get; set; }
    public Boolean isUpdateAttributeInRefContent { get; set; }
    //  REF-1448
    public Boolean isResetColumnSelector { get; set; }
      
    //related to #639
    public Boolean isUpdateRelatedAttributeMapping { get; set; } 
    //re #988
    public Boolean isUpdateProductAttribute { get; set; } 
    // re #1127 - to check Reference Activities created for nomination.
    public Boolean isReferenceActivitiesCreated { get; set; }
    public Static Integer totalRewardsToPostInfl = 0;
    public Static Integer postedRewardsInfl = 0;    
    private Custom_Settings__c cs;
    // added for #498 - to check if Remote Site Setting exists
    public static Boolean isRssPresent {
        get {
            
            if (isRssPresent == null) {
                HttpRequest request = new HttpRequest();
                request.setEndpoint(protocolAndHost);
                request.setMethod('GET');
                
                try {
                    new Http().send(request);
                    isRssPresent = true;
                } catch (CalloutException e) {
                    isRssPresent = false;
                }
            }
            return isRssPresent;
        }
    }
    
    // added for #498 - to get the remote site setting URL
    public static String protocolAndHost {
        get {
            
            if (protocolAndHost == null) {
                protocolAndHost = Url.getSalesforceBaseUrl().toExternalForm().replace('http:', 'https:');
            }
            system.debug('return value - ' + protocolAndHost);
            return protocolAndHost;
        }
    }
    // added for #1166 - Gaurav Saini (28 Nov, 2017)
    public Boolean isReferenceLeadUpdated { get; set; }
    public Boolean isReferenceLeadInProgress { get; set; }
    //   Added for REF-2079 - Rajneesh Raj (10 jan 2019)
    public Boolean isOpporProductAMUpdated { get; set; }
    //  REF-2224
    public Boolean isEnableOppAttribute { get; set; }
    private List<Data_Mapping__c> DMRecordList = new List<Data_Mapping__c>();
    
    /**
     * method to get deployment string for remote site setting
     * added for #498
     */
    public String getDeployXml() {
        return '<?xml version="1.0" encoding="utf-8"?>'
            + '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
            + '<env:Header>'
            + '<urn:SessionHeader xmlns:urn="http://soap.sforce.com/2006/04/metadata">'
            + '<urn:sessionId>' + UserInfo.getSessionId() + '</urn:sessionId>'
            + '</urn:SessionHeader>'
            + '</env:Header>'
            + '<env:Body>'
            + '<createMetadata xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '<metadata xsi:type="RemoteSiteSetting">'
            + '<fullName>Salesforce_API_' + String.valueOf(DateTime.now().getTime()).right(4) + '</fullName>'
            + '<description>Salesforce API</description>'
            + '<disableProtocolSecurity>false</disableProtocolSecurity>'
            + '<isActive>true</isActive>'
            + '<url>' + protocolAndHost + '</url>'
            + '</metadata>'
            + '</createMetadata>'
            + '</env:Body>'
            + '</env:Envelope>';
    }
    //REF-1259
    public Boolean isRemoveDuplicateReferenceProfiles { get; set; }
    
    /**
     * Constructor
     */
    public RefedgeSetupHomeController() {
        Schema.DescribeSObjectResult D = Microsite__c.sObjectType.getDescribe();
        micrositePrefix = D.getKeyPrefix();
        isEnableOppAttribute = true;
        //ServiceCall();
        refresh();
    }
    
    /**
     * method to call batch for update reference lead data
     * author: Gaurav Saini (28 Nov, 2017) for #1166
     */
    public void updateRefLeads() {
        
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Lead__c', new Set<String>{
                            UtilityController.appNamespace() + 'Ref_Lead_From_Opportunity__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                ID batchId = Database.executebatch(new Batch_DataUpdate_RefLeads());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Reference_Leads_Updated__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to refresh Data
     */
    public void refresh() {
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        Set<String> setApexJob = new Set<String>();
        
        for (AsyncApexJob aaj : [SELECT Status, ApexClassId FROM AsyncApexJob WHERE(JobType = 'BatchApex'
                OR JobType = 'ScheduledApex') AND Status NOT IN('Aborted', 'Completed', 'Failed') LIMIT: limits.getLimitQueryRows()]) {
            setApexJob.add(aaj.ApexClassId);
        }

        Set<String> apexClasses = new Set<String>();
        
        for (ApexClass ac : [SELECT Name, Id FROM ApexClass WHERE Id IN: setApexJob LIMIT: limits.getLimitQueryRows()]) {
            apexClasses.add(ac.Name.toLowerCase().trim());
        }
        //REF-1259
        isRemoveDuplicateReferenceProfiles = appConfig.Is_Merge_Duplicate_Profiles__c;
        // Re #1184
        isProgressUpdateAttributeInRefContent = apexClasses.contains('Batch_UpdateAttributeToReferenceContent');
        isUpdateAttributeInRefContent = appConfig.Update_Attribute_in_Reference_Content__c;
        //  REF-1448
        isResetColumnSelector = appConfig.Reset_Column_Selector_for_RfSearch_Page__c;
        //  REF-2079
        isOpporProductAMUpdated = appConfig.Update_Opportunity_Product_Attribute_Map__c;
        // added for #1166 - Gaurav Saini (28 Nov, 2017)
        // for batch to update reference leads
        isReferenceLeadInProgress = apexClasses.contains('batch_dataupdate_refleads');
        isReferenceLeadUpdated = appConfig.Is_Reference_Leads_Updated__c;
        
        //Install PRO Key
        DescribeSObjectResult porAppConfiguration = POR_App_Configuration__c.sObjectType.getDescribe();
        porAppConfigurationKeyPerfix = porAppConfiguration.getKeyPrefix();
        isEditionKey = (appConfig.Edition_Key__c != null ? true : false);

        //Check microsite for org
        listMicrosite = new List<Microsite__c>([SELECT Id FROM Microsite__c LIMIT : 1]);

        //Check site setup or not
        isSiteSetNativeCustomSetting = (appConfig.Site_URL__c != null ? true : false);

        //Check Referenceability_no__c is null or not
        isProgressReferenceabilityTypes = apexClasses.contains('batch_dataupdate_reftypes');
        isUpdateReferenceabilityTypes = appConfig.Is_Update_Referenceability_Types__c;

        //Check RBI 
        isProgressReferenceProfiles = apexClasses.contains('batch_dataupdate_rbi');
        isUpdateReferenceProfiles = appConfig.Is_Update_Reference_Profiles__c;

        //Check Reference Content 
        isProgressReferenceContent = apexClasses.contains('batch_dataupdate_refContent');
        isUpdateReferenceContent = appConfig.Is_Update_Reference_Content__c;

        //Check Reference Requests Invitation 
        isProgressRequestInvitationRecords = apexClasses.contains('batch_datacreate_rri');
        isCreateRequestInvitationRecords = appConfig.Is_Create_Request_Invitation_Records__c;

        //Check Rewards 
        isProgressRewardDeclinedRequestRecord = apexClasses.contains('batch_deleterewarddeclinedrequest');
        isUpdateRewardDeclinedRequestRecord = appConfig.Is_Update_Reward_Declined_Request_Record__c;
        
        //Check contact attribute batch 
        isProgressContactAttributes = apexClasses.contains('batch_updateaccountnameconatt');
        isUpdateContactAttributes = appConfig.Update_Account_in_Contact_Attributes__c;
        
        //check No Longer Needed requests
        isProgressAccountContactRequests = (apexClasses.contains('batch_changeallnolongerneededar') && apexClasses.contains('batch_changeallnolongerneededcr'));
        isUpdateAccountContactRequests = appConfig.Update_Account_and_Contact_Request_NLN__c;
        
        //Update Refedge Custom Setting
        isUpdateRefedgeCustomSetting = appConfig.Is_Update_Custom_Setting__c;
        
        //update filters
        isUpdateFilters = appConfig.Update_Filters__c;
        
        //update attributes
        isUpdateAttributes = appConfig.Update_Attributes__c;
        
        //User reward permission
        isAllowSalesReward = (RefEdgeEditionFeatures.isBasic) ? false : true; //re #262
             
        isCreateSalesReward = appConfig.Create_Sales_Reward_RefTypes__c;
          
        //update Profile Updates
        isProgressProfileUpdates = apexClasses.contains('batch_profileupdatenoresponse');
        isUpdateProfileUpdates = appConfig.Update_Profile_Updates__c;
        
        //update Contacts Available Points
        isProgressContactAvailablePoints = apexClasses.contains('batch_resetcontactrewardpoints');
        isUpdateContactAvailablePoints = appConfig.Update_Contact_Available_Points__c;
        
        //Check Filters 
        isProgressFilterNumbers = apexClasses.contains('batch_dataupdate_filters');
        isUpdateFilterNumbers = appConfig.Update_Filter_Numbers__c;
        
        //check for RBI current Avilable points
        isProgressRBIPointsUpdates = apexClasses.contains('batch_updatecurrentavailablepoints');
        isUpdateRBIPoints = appConfig.Update_Current_Available_Points_for_RBI__c;
        
        //isProgressInfluitiveDataSync = apexClasses.contains('RefedgeSetupHomeController');
        isUpdateInfluitiveDataSync = appConfig.Sync_Reward_to_Influitive__c;
         
        isUpdateInheritableAttributes = appConfig.Update_Inheritable_Value_in_Attributes__c;
        
        //re #1127 - Set app configuration setting value for nomination reference activity.
        isReferenceActivitiesCreated = appConfig.Create_Nomination_Reference_Activities__c; 
        
        //related to #639
        isUpdateRelatedAttributeMapping = appConfig.Update_Related_Attribute_Mapping_for_A_C__c;
        
        cs = UtilityController.getCustomSettings();
        isInfluitiveEnabled = cs.Is_Influitive_Integration_Enabled__c;
        
        //Public Groups
        List<Group> publicGroups = [SELECT Id FROM Group WHERE Name = : 'Customer Reference Team'
                                                    LIMIT : limits.getLimitQueryRows()];
        publicGroupId = (publicGroups.size() > 0 ? '' + publicGroups[0].id : '');

        //Create Profile
        salespersonProfile = new List<Profile>();
        reManagerProfile = new List<Profile>();
        
        for (Profile pro : [SELECT Id, Name FROM Profile WHERE Name = 'RE Salesperson'
                                OR Name = 'Reference Manager' LIMIT : limits.getLimitQueryRows() ]) {
                
            if (pro.Name == 'RE Salesperson') {
                salespersonProfile.add(pro);
            }
                
            if (pro.Name == 'Reference Manager') {
                reManagerProfile.add(pro);
            }
        }
        /*
        //Create Permission set
        salespersonPS = new List<PermissionSet>();
        reManagerPS = new List<PermissionSet>();
        
        for (PermissionSet ps : [SELECT Id, Name FROM PermissionSet WHERE Name = 'RESalesperson'
                                OR Name = 'ReferenceManager' LIMIT : limits.getLimitQueryRows() ]) {
                
            if (ps.Name == 'RESalesperson') {
                salespersonPS.add(ps);
            }
                
            if (ps.Name == 'ReferenceManager') {
                reManagerPS.add(ps);
            }
        }*/
        checkPermissionsCS();
        checkPermissionsRefTypes();
        checkPermissionsAtt(new Set<String> { UtilityController.appNamespace() + 'Inheritable__c', UtilityController.appNamespace() + 'Root_Parent__c' });
        checkPermissionsDataMapping();
        checkPermissionsCSUpdate();
        
        //re #988
        List<Attribute__c> atts = [SELECT Id, Product_ID__c FROM Attribute__c WHERE Level__c = 0 
                                            AND Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY 
                                            AND Attribute_Mapping__r.Field_Api_Name__c = 'Product2'];
        
        if (atts.size() > 0) {
            
            if (atts[0].Product_ID__c != null && atts[0].Product_ID__c != '') {
                isUpdateProductAttribute = true;
            } else {
                isUpdateProductAttribute = false;
            }
        } else {
            isUpdateProductAttribute = false;
        }  

        //  REF-2224
        DMRecordList = [SELECT Id, Name, Label__c FROM Data_Mapping__c WHERE Name =: ConstantsController.OPP_ATTRIBUTE AND Label__c =: ConstantsController.OPP_ATTRIBUTE];
        
        if(DMRecordList.size() > 0) {
            isEnableOppAttribute = true;
        } else {
            isEnableOppAttribute = false;
        } 
    }
    /**
     * Method to update the Product Filter Id in the Product root attribute
     * Created By: Rekha @15 September 2017
     */
    public void updateUpdateFilterIdInRootAttributeForProduct() {
        try {

            if (checkPermissionsAtt(new Set<String> { UtilityController.appNamespace() + 'Product_ID__c' })) {
                //re #988
                List<Attribute__c> atts = [SELECT Id, Product_ID__c FROM Attribute__c WHERE Level__c = 0 
                                                    AND Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY 
                                                    AND Attribute_Mapping__r.Field_Api_Name__c = 'Product2'];
                
                if (atts.size() > 0) {
                    
                    String attId = '';
                    String labelId = '';
                    Attributes_Labels__c attributeLabel;
                    
                    attId = atts[0].Id;
                    List<Attribute__c> tempList = [SELECT Id, (SELECT Label__c, Attribute__c FROM Attributes_Labels__r) 
                                                    FROM Attribute__c WHERE Parent__c = :attId LIMIT 1];
                    
                    if (tempList.size() > 0) {
                        labelId = tempList[0].Attributes_Labels__r[0].Label__c;
                    }
                    
                    if (labelId == null || labelId == '') {
                        List<Attributes_Labels__c> tempList1 = [SELECT Label__c, Attribute__c FROM Attributes_Labels__c WHERE Attribute__c = :attId];
                        
                        if (tempList1.size() > 0) {
                            attributeLabel = tempList1[0];
                            labelId = tempList1[0].Label__c;
                        }
                    }
                    
                    atts[0].Product_ID__c = labelId;
                    update atts;
                    isUpdateProductAttribute = true;
                    
                    if (attributeLabel != null) {
                        delete attributeLabel;
                    }
                }
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * re #1127 - Method to Create Reference Activities
     */
    public void createReferenceActivities() {
      
        try {
                 
            if (checkPermissionsRefActivity()) {  
                Set<String> setRefType = new Set<String>();
                List<Data_Mapping__c> lstNominationRefTypesMapping = new List<Data_Mapping__c>();  
                // getting Referenceability type
                List<Referenceability_Type__c> refTypeResult = [SELECT Id, Name, Visible__c, Referenceability_code__c FROM Referenceability_Type__c 
                                                        WHERE Visible__c = true AND Sales_Reward__c = false ORDER BY Name DESC LIMIT :limits.getLimitQueryRows()]; 
                                                        
                List<Data_Mapping__c> mapDataMapping = [SELECT Referenceability_Type__c FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION_REFERENCEABILITY 
                                                    AND Visible__c = true LIMIT :limits.getLimitQueryRows()];
                
                for (Data_Mapping__c reftype : mapDataMapping) {
                    setRefType.add(reftype.Referenceability_Type__c);
                } 
               
                for (Referenceability_Type__c rt : refTypeResult) {
           
                    if (!setRefType.contains(rt.Id)) {
                        lstNominationRefTypesMapping.add(new Data_Mapping__c(Name = rt.Name, Referenceability_Type__c = rt.Id, Visible__c = true, 
                                                             Object__c = ConstantsController.NOMINATION_REFERENCEABILITY));
                    }
                }
                
                if (lstNominationRefTypesMapping.size() > 0) { 
                    ConstantsController.shouldDataMappingProcessed = true;
                    insert lstNominationRefTypesMapping;
                } 
              
                // Update Custom setting configuration values.
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Create_Nomination_Reference_Activities__c = true;
                upsert appConfig;
                
                refresh();
            }
            
        } catch (Exception e) { 
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }  
    /**
     * Method to Create Referenceability Types for Sales Rewards
     */
    public void updateCreateSalesRefTypes() {
        try { 
            
            if (checkPermissionsRefTypes()) {
                List<Referenceability_Type__c> newReferenciablities = new List<Referenceability_Type__c>();
                Set<String> refCodeSet = new Set<String>();
                // getting Referenceability code list
                List<Referenceability_Type__c> refTypeResult =  [SELECT Id, Name, Visible__c, Referenceability_code__c FROM Referenceability_Type__c 
                                                        WHERE Referenceability_code__c != null ORDER BY Referenceability_code__c DESC]; 
                
                // #647 - Creating set for Referenceability Type  
                for (Referenceability_Type__c reftype : refTypeResult) {
                    refCodeSet.add(reftype.Referenceability_code__c);
                }  
                
                // #647 - Check if Referenceability_code__c already exist so this will skip to add same Referenceability Type 
                if (!refCodeSet.contains(ConstantsController.INVITATION_TO_CO_WORKER)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Invitation to Co-Worker', 
                                                                    Referenceability_code__c = ConstantsController.INVITATION_TO_CO_WORKER, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 2, Visible__c = true));
                }  
                
                if (!refCodeSet.contains(ConstantsController.INVITATION_TO_CONTACT)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Invitation to Contact', 
                                                                    Referenceability_code__c = ConstantsController.INVITATION_TO_CONTACT, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 20, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.NOMINATION_APPROVED)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Nomination - Approved', 
                                                                    Referenceability_code__c = ConstantsController.NOMINATION_APPROVED, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 50, Visible__c = true));
                }
                                                                    
                if (!refCodeSet.contains(ConstantsController.NOMINATION_SUBMITTED)) {                                                   
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Nomination - Submitted', 
                                                                    Referenceability_code__c = ConstantsController.NOMINATION_SUBMITTED, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 5, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.PROFILE_UPDATE)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Profile Update', 
                                                                    Referenceability_code__c = ConstantsController.PROFILE_UPDATE, Sales_Reward__c = true, 
                                                                    Sales_Point__c = 100, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.Reference_Use_Feedback)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Reference Use Feedback', 
                                                                    Referenceability_code__c = ConstantsController.Reference_Use_Feedback, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 15, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.REQUEST_SALES)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Request', 
                                                                    Referenceability_code__c = ConstantsController.REQUEST_SALES, Sales_Reward__c = true, 
                                                                    Sales_Point__c = 40, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.RLF_REFERRED)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'RLF - Referred to New Owner', 
                                                                    Referenceability_code__c = ConstantsController.RLF_REFERRED, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 8, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.RLF_RESPONSE)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'RLF - Response', 
                                                                    Referenceability_code__c = ConstantsController.RLF_RESPONSE, Sales_Reward__c = true, 
                                                                    Sales_Point__c = 80, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.REFERANCE_USE)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = 'Record Reference Use', 
                                                                    Referenceability_code__c = ConstantsController.REFERANCE_USE, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 50, Visible__c = true));
                }
                
                if (!refCodeSet.contains(ConstantsController.REFERENCE_CONTENT_TYPE)) {
                    newReferenciablities.add(new Referenceability_Type__c(Name = ConstantsController.REFERENCE_CONTENT_TYPE, 
                                                                    Referenceability_code__c = ConstantsController.REFERENCE_CONTENT_TYPE, 
                                                                    Sales_Reward__c = true, Sales_Point__c = 5, Visible__c = true));
                }
                
                if (newReferenciablities.size() > 0) {
                    insert newReferenciablities;
                }
                
                // #865 - Set visibility true for all Sales referencibility type.  
                for (Referenceability_Type__c reftype : refTypeResult) {
                    reftype.Visible__c = true;                    
                } 
                
                update refTypeResult;
                
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Create_Sales_Reward_RefTypes__c = true;
                upsert appConfig;
                
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsRefTypes() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String> { 
                                                'Name',
                                                UtilityController.appNamespace() + 'Referenceability_code__c',
                                                UtilityController.appNamespace() + 'Sales_Reward__c',
                                                UtilityController.appNamespace() + 'Sales_Point__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
    
    /**
     * Method to check Permissions for referenceability type for Nomination Setting 
     */
    public Boolean checkPermissionsRefActivity() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String> {  
                                                UtilityController.appNamespace() + 'Visible__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * Method to Update contact attributes which do not has the account value
     */
    public void updateContactAttributes() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Contact_Attribute__c', new Set<String>{
                            UtilityController.appNamespace() + 'Account__c'});
            
             if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true) || Test.isRunningTest()) {
                ID batchprocessid = Database.executebatch(new Batch_UpdateAccountNameConAtt());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Account_in_Contact_Attributes__c = true;
                upsert appConfig;
                refresh(); 
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to Update Profile Updates
     */
    public void updateRewardsOnInfluitiveIntegration() {  
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String>{
                            UtilityController.appNamespace() + 'Infl_Event_Fetch_DateTime__c'});
            Boolean isCSUpdate = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
            fieldMap.clear();
            
            fieldMap.put(UtilityController.appNamespace() + 'Reward__c', new Set<String>{
                            UtilityController.appNamespace() + 'Account__c',
                            UtilityController.appNamespace() + 'Contact__c',
                            UtilityController.appNamespace() + 'Transaction__c',
                            UtilityController.appNamespace() + 'Amount__c',
                            UtilityController.appNamespace() + 'RewardDate__c',
                            UtilityController.appNamespace() + 'Referenceability_Type__c',
                            UtilityController.appNamespace() + 'Available_Points__c',
                            UtilityController.appNamespace() + 'Expired_Points_in_influitive__c',
                            UtilityController.appNamespace() + 'Influitive_Id__c',
                            UtilityController.appNamespace() + 'Influitive_ID2__c'});
            Boolean isRewardUpsert = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
            
            if (((isCSUpdate && isRewardUpsert) || Test.isRunningTest()) && cs.Is_Influitive_Integration_Enabled__c != null 
                                            && cs.Is_Influitive_Integration_Enabled__c) {
                
                //ID batchprocessid = Database.executebatch(new INfl_Batch_Events(),1);
                
                // Method will execute and sync records from side (RefEdge and Influitive)
                syncInfluitiveEventsWithRefEdge();
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Sync_Reward_to_Influitive__c = true;
                //upsert appConfig; 
                isProgressInfluitiveDataSync = true;
                refresh(); 
            } 
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
   /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to use to call influitive api handler to get All Events (AKA Rewards in refeddge) from influitive and issue reward to contact if not exist. 
​ ​ ​ ​ ​*​ ​ ​ @return :​ Its a future method and its run in background.
    *   @Created By: Rajesh @Feb 2018
​ ​ ​ ​ ​**/
    @future (callout = true)
    public static void syncInfluitiveEventsWithRefEdge() {  
        /* Initialize variables*/
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<String, String> contactEventMap = new Map<String, String>();
        Map<Integer, String> contactMap = new Map<Integer, String>();
        Map<String, String> refTypeMap = new Map<String, String>();
        Map<String, String> reverseRefTypeMap = new Map<String, String>();
        Map<String, List<Infl_EventsParser.cls_events>> mapIds = new Map<String, List<Infl_EventsParser.cls_events>>();
        List<Reward__c> issueRewards = new List<Reward__c>();
        List<Reward__c> redeemRewards = new List<Reward__c>();    
        Set<String> setContactId = new Set<String>();
        List<Contact> lstContact = null; 
        Set<String> rewardFailedToPost = new Set<String>(); 
        List<Infl_EventsParser.cls_events> issueEvents =  null;
        List<String> message = new List<String>(); 
        Integer totalRewardsToPost = 0;
        Integer postedRewards = 0; 
        String lastFetchEventTimeStamp = '';  
        InflAPIHandler apiHandler = new InflAPIHandler();
        Boolean isError = false;
        Set<String> eventIds = new Set<String>(); 
        List<Data_Mapping__c> dm = new List<Data_Mapping__c>();
        List<Infl_EventsParser> lstEventParser = new List<Infl_EventsParser>();
        
        if (cs.Is_Influitive_Integration_Enabled__c != null && cs.Is_Influitive_Integration_Enabled__c) { 
            /*TRY & Catch to handle callout exception*/
            try {
                Infl_EventsParser response = null;
                /*Creating HttpRequest to get events*/ 
                HttpRequest req = new HttpRequest(); 
                req.setEndpoint(cs.Influitive_API_URL__c + '/api/events');
                String apiToken = cs.Influitive_Auth_Token__c;
                req.setHeader('Authorization', 'Token token="' + apiToken +'"');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/vnd.infl-v3+json'); 
                req.setMethod('GET');
                
                if (!String.isBlank(cs.Infl_Event_Fetch_DateTime__c)) {
                    req.setHeader('start_at', cs.Infl_Event_Fetch_DateTime__c); 
                }   
                dm  = [SELECT Label__c, Object__c, CreatedDate FROM Data_Mapping__c WHERE Object__c = 'INFL_CURSOR' LIMIT 1]; 
                
                if (!dm.IsEmpty()) {
                    req.setEndpoint( dm[0].Label__c); 
                    /*for (Data_Mapping__c maping : dm[0].Label__c) {
                        req.setEndpoint(maping.Label__c); 
                    }*/ 
                }            
                 
                HttpResponse res = new HttpResponse();
                Http http = new Http();  
                String next = '';
                Infl_EventsParser eventParser ;
                Integer apiCalls = 0; 
                // Requeting to Rest APIs 
                List<Referenceability_Type__c> refceabilitys = [SELECT Name, Id, Referenceability_code__c 
                                                                        FROM Referenceability_Type__c LIMIT :limits.getLimitQueryRows()];
                            
                for (Referenceability_Type__c refceability : refceabilitys) {
                    refTypeMap.put(refceability.id,refceability.Referenceability_code__c);
                    reverseRefTypeMap.put(refceability.Referenceability_code__c, refceability.id);
                }
                contactMap = new Map<Integer,String>();
                             
                while (apiCalls < 10) {  
                    res = http.send(req);
        
                    if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                        eventParser = Infl_EventsParser.parse(res.getBody());  
                        
                        if (eventParser != null && !eventParser.events.isEmpty()) {  
                            lstEventParser.add(eventParser);
                            /*List<Infl_EventsParser.cls_events> eventsT  = eventParser.events;
                            eventsT.sort();
                            lastFetchEventTimeStamp = eventsT.get(eventParser.events.size() - 1).created_at;*/ 
                            
                            for (Infl_EventsParser.cls_contacts con : eventParser.contacts) {
                                
                                if (con.crm_contact_id != null && con.crm_contact_id != '') {
                                    contactMap.put(con.id, con.crm_contact_id);
                                    setContactId.add(con.crm_contact_id);
                                }
                            } 
                            
                            for (Infl_EventsParser.cls_events event : eventParser.events) {
                                eventIds.add(''+event.id);
                            }   
                            
                            next = eventParser.links.next;
                        
                            //Setting curson for next fetch
                            if (next != null) {
                                 req.setEndpoint(next); 
                            } else {
                                break;
                            }      
                                             
                        } else {
                            isError = true;
                            message.add('No Events recived from Influitive APIs. <br/><p> Please do not reply to this mail.</p>');  
                            break;                  
                        }
                    } else {
                        isError = true;
                        message.add('We are not getting expected response from Influitive APIs, here are the details:<br/><br/> <b>API URl:</b>' + cs.Influitive_API_URL__c + '/api/events' + 
                                    ' <br/><b>Status Code: </b>' + res.getStatusCode() + '<br/><b> Error Message: </b>' + res.getStatus() + '<br/><p> Please do not reply to this mail.</p>');
                        break;  
                    }  
                    apiCalls = apiCalls + 1;  
                } 
                
                if (!isError) {
                    Set<String> inflIdSet = new Set<String>();
                    // Filtering Events which we have to issue reward 
                    List<Reward__c> inflReward = [SELECT Contact__c, Influitive_Id__c, Influitive_ID2__c FROM Reward__c WHERE Influitive_ID2__c IN :eventIds 
                                                    AND Contact__c IN : setContactId LIMIT :limits.getLimitQueryRows()];
                    
                    for (Reward__c reward : inflReward) {
                        
                        if (reward.Influitive_ID2__c != null) {
                            inflIdSet.add(reward.Influitive_ID2__c);
                        }
                    }
                    
                    for (Infl_EventsParser parser : lstEventParser) {
                        
                        for (Infl_EventsParser.cls_events event : parser.events) {
                            
                            if (!(inflIdSet.contains(String.valueOf(event.id)) || inflIdSet.contains(String.valueOf(event.uuid))) && event.type != ConstantsController.EXPIRED_REWARD_EVENT && event.points != 0
                                        && contactMap.containsKey(event.contact_id)) {
                                String contactCrmId = contactMap.get(event.contact_id);
                                
                                // checking if contact exist in salesforce
                                if (contactCrmId != '') {
                                    
                                    if (!mapIds.containsKey(contactCrmId)) {
                                        mapIds.put(contactCrmId, new List<Infl_EventsParser.cls_events>());
                                    }
                                    mapIds.get(contactCrmId).add(event);
                                }
                            }
                        }
                    }
                 
                
                    String query = 'SELECT Id, Email, AccountId, (SELECT Influitive_Id__c,Influitive_ID2__c, Available_Points__c, Expired_Points_in_influitive__c, Transaction__c, ' 
                            + 'Referenceability_Type__c, Expired_Points__c, Expired__c, Contact__c, Id, Amount__c FROM Rewards__r WHERE ' 
                            + ' (Expired__c = true OR Influitive_ID2__c = null OR Expired_Points_in_Influitive__c > 0) LIMIT 180 ) '
                            + 'FROM Contact WHERE Id IN : setContactId LIMIT 180';  
                            
                    lstContact = Database.query(query); 
                    contactEventMap = new Map<String, String>();  
                     
                    //Insert reward to refedge for events we get from Influitive.                   
                    for (Contact contact : lstContact) {
                        
                        if (contact.email != null) {
                            contactEventMap.put(contact.id, contact.email);
                        }
                        
                        if (setContactId.contains(contact.Id)) {
                            
                            if (mapIds != null && mapIds.size() > 0 && mapIds.containsKey(contact.Id)) {
                                                                
                                //Adding rewards to refedge   
                                for (Infl_EventsParser.cls_events event : mapIds.get(contact.Id)) {
                                    //Getting Referenceability_Type__c id
                                    String accountId = contact.AccountId;
                                    String referenceabilityId =  reverseRefTypeMap.get(event.type);  
                                    
                                    if (referenceabilityId == null && accountId != null) {
                                        referenceabilityId = reverseRefTypeMap.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);
                                    }
                                    
                                    if (referenceabilityId != null && referenceabilityId != '' && event.points != null) {
                                        String createEventdate = event.created_at;
                                        Date createdAt = null;
                                        
                                        if (createEventdate != null) {
                                            createdAt = Date.valueOf(createEventdate);
                                        }
                                        String crmContactId = contactMap.get(event.contact_id);
                                        Reward__c reward = null;
                                       
                                        if (event.points > 0 && crmContactId != null && crmContactId != '') { 
                                            reward = new Reward__c(Account__c = accountId, Contact__c = crmContactId,
                                                                   Transaction__c ='Issue', Amount__c = event.points, 
                                                                   Available_Points__c = event.points, Referenceability_Type__c = referenceabilityId,
                                                                   Influitive_ID2__c = '' + event.uuid, RewardDate__c = createdAt); 
                                            issueRewards.add(reward);
                                        } else if (event.points < 0 && crmContactId != null && crmContactId != '') {
                                            Integer points = Integer.valueOf(event.points)*-1;
                                            reward = new Reward__c(Account__c = accountId, Contact__c = crmContactId, Transaction__c = 'Redeem', 
                                                                    Amount__c = points, Influitive_ID2__c = '' + event.uuid, RewardDate__c = createdAt);
                                            redeemRewards.add(reward);
                                        }
                                    }
                                }
                            }
                        }
                    } 
                   
                    /*Post Rewards to influitive which is exist in Refedge but not at hub or not yet expired*/
                    List<Reward__c> inflRewards = postToInfluitive(lstContact, refTypeMap, contactEventMap);
                    Database.SaveResult[] issueContact;
                    Database.SaveResult[] redeemContact;
                    Database.SaveResult[] updateReward; 
                    
                     //insert issueRewards;
                    if (issueRewards.size() > 0) {
                        issueContact = database.insert(issueRewards, false); 
                    } 
                    
                    if (redeemRewards.size() > 0) {
                        redeemContact = database.insert(redeemRewards, false); 
                    } 
                    
                    //updating rewards
                    if (inflRewards.size() > 0) { 
                        updateReward = database.update(inflRewards, false); 
                    }
                    
                    Integer totalCallOuts = postedRewardsInfl + apiCalls; 
                    Integer processCycleLeft = 0;
                    
                    if (next != null) {
                        Integer intVal = Integer.valueOf(next.substringAfterLast('=')) ;
                        processCycleLeft = math.abs(intVal/5000) + 1; 
                    }
                    
                    String successMsg = 'Sync Rewards to Influitive process executed successfully.<br/><br/>';
                    successMsg += 'Here are the details : <br/>';
                    successMsg += '<br/>Total Events Ids received from Influitive : ' + eventIds.size() + '<br/>';
                    successMsg += '<br/>Total Contact received with CRM Contact Id from Influitive : '+ setContactId.size() + '<br/>'; 
                    successMsg += '<br/>Total Issued Rewards : '+ issueRewards.size() + '<br/>';
                    successMsg += '<br/>Total Redeemed Rewards : '+ redeemRewards.size() + '<br/>';
                    successMsg += '<br/>Total Rewards post to Influitive : ' + inflRewards.size() + '<br/>'; 
                    successMsg += '<br/>Total Callouts for this Process : ' + String.valueof(totalCallOuts) + '<br/>';   
                    successMsg += '<br/>Last API URl Cursor : ' + next + '<br/>';
                    successMsg += '<br/>Sync Rewards Process Cycle left: ' + processCycleLeft + '<br/>';
                    
                    if (processCycleLeft > 0) {
                        successMsg += '<br/><I>Note : Due to salesforce Callout limitation we need to run the process again '+ processCycleLeft +' times to cover all the events available in Influitive Hub. Please refresh the <b>RefEdge Setup</b> page and click again on <b>Sync Rewards to Influitive</b> link.</I><br/>'; 
                    } else  {
                        successMsg += '<br/>Sync Rewards Process Cycle completed successfully. Now if you execute the process again you will get new events which is created from now.<br/>';
                    }
                    /*Added Contact, Issue, Redeemed Rewards details*/
                    String contatDetails = '';
                    
                    if (setContactId.size() > 0) { 
                        successMsg += '<br/><br/><b> Contact Details:</b><br/> ';
                        
                        for (String con : setContactId) {
                            contatDetails += con + ',';
                        }
                        contatDetails = contatDetails.removeEnd(',');
                        successMsg += '<i>' + contatDetails + '</i><br/>'; 
                    }
                    
                    if (issueContact != null) {
                        String issueIds = '', issueError = '';
                        
                        for (Database.SaveResult sr : issueContact) {
     
                            if (sr.isSuccess()) {  
                                issueIds += sr.getId() + ',';
                            } else { 
                                  
                                for (Database.Error err : sr.getErrors()) { 
                                    issueError += 'Error : ' + err.getStatusCode() + ': ' + err.getMessage() + '</br>' ; 
                                    issueError += 'Issue fields that affected this error: ' + err.getFields() + '</br>'; 
                                } 
                            } 
                        }
                        successMsg += '<br/><br/><b> Issue Rewards Details:</b> <br/>';
                        successMsg +=  'Success Ids : <i>' + issueIds + '</i><br/>';
                        successMsg += issueError + '<br/>';
                    }
                    
                    if (redeemContact != null) {
                        String redeemIds = '', redeemError = '';
                        
                        for (Database.SaveResult sr : redeemContact) {
     
                            if (sr.isSuccess()) {  
                                redeemIds += sr.getId() + ',';
                            } else { 
                                  
                                for (Database.Error err : sr.getErrors()) { 
                                    redeemError += 'Error : ' + err.getStatusCode() + ': ' + err.getMessage() + '</br>' ; 
                                    redeemError += 'Reward fields that affected this error: ' + err.getFields() + '</br>'; 
                                } 
                            } 
                        }
                        successMsg += '<br/><br/><b> Redeem Rewards Details:</b> <br/>';
                        successMsg +=  'Success Ids : <i>' + redeemIds + '</i><br/>';
                        successMsg += redeemError + '<br/>';
                    }
                    
                    if (updateReward != null) {
                        String postIds = '', postError = '';
                        
                        for (Database.SaveResult sr : updateReward) {
     
                            if (sr.isSuccess()) {  
                                postIds += sr.getId() + ',';
                            } else { 
                                  
                                for (Database.Error err : sr.getErrors()) { 
                                    postError += 'Error : ' + err.getStatusCode() + ': ' + err.getMessage() + '</br>' ; 
                                    postError += 'Reward fields that affected this error: ' + err.getFields() + '</br>'; 
                                } 
                            } 
                        }
                        successMsg += '<br/><br/><b> Post Rewards Details:</b> <br/>';
                        successMsg +=  'Success Ids : <i>' + postIds + '</i><br/>';
                        successMsg += postError + '<br/>';
                    }  
                        
                    if (next != null) {
                        //dm  = [SELECT Label__c,Object__c FROM Data_Mapping__c WHERE Object__c = 'INFL_CURSOR' LIMIT 1]; 
                        if(dm.size() > 0) {
                             dm[0].Label__c = next;
                             ConstantsController.shouldDataMappingProcessed = true;
                             update dm;
                        } else { 
                            dm.add(new Data_Mapping__c(Label__c = next, Object__c = 'INFL_CURSOR')); 
                            ConstantsController.shouldDataMappingProcessed = true;  
                            insert dm;
                        }
                    } else {
                        //dm  = [SELECT Label__c,Object__c FROM Data_Mapping__c WHERE Object__c = 'INFL_CURSOR' LIMIT 1];/
                        if(dm.size() > 0) {  
                            cs.Infl_Event_Fetch_DateTime__c = json.serialize(dm[0].createdDate).replace('"','');
                            update cs;
                        
                            ConstantsController.shouldDataMappingProcessed = true; 
                            // moved DML to w/o sharing for security report issue
                            WithoutSharingHelperController.deleteDataMappingsInRefSearch(dm);
                        }
                        
                        
                        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                        appConfig.Sync_Reward_to_Influitive__c = true;
                        upsert appConfig;  
                    }         
                    message.add(successMsg + '<br/><p> Please do not reply to this mail.</p>'); 
                }                          
            } catch(CalloutException e) {   
                isError = true; 
                message.add('We are not getting expected response from Influitive APIs, here are the details:<br/><br/> <b>API URl:</b>' + cs.Influitive_API_URL__c + '/api/events' + 
                                    '<br/><b> Error Message: </b>' + e.getMessage() +  '<br/><b>line # :' + e.getLineNumber() + '<br/><p> Please do not reply to this mail.</p>');

            } catch(Exception e) {  
                isError = true; 
                message.add('Error while insert infl events as reward in refedge : <br/>line # :' + e.getLineNumber() 
                                            + ' <br/>Type :' + e.getTypeName() + '<br/><b> Message : </b>' + e.getMessage()); 
            }
             
            system.debug('-API Response Message-->'+ message);
            if (isError) {
                InflAPIAbstractHandler.sendInflExceptionEmail('Sync Rewards to Influitive process execution failed', message);
            } else {
                InflAPIAbstractHandler.sendInflExceptionEmail('Sync Rewards to Influitive process executed successfully.', message);
            }
        }
     } 
     
   /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to use to post reward to influitive which are not exist in there(Expired /Issue / Redeem).  
    *   @Created By: Rajesh @Feb 2018
​ ​ ​ ​ ​**/
    private static List<Reward__c> postToInfluitive(List<Contact> scope, Map<String, String> refTypeMap, Map<String, String> contactEventMap) {  
        Integer totalRewardsToPost = 0;
        Integer postedRewards = 0; 
        List<Reward__c> inflRewards = new List<Reward__c>();
        Set<String> rewardFailedToPost = new Set<String>();
        Integer callOuts = 0; 
        InflAPIHandler apiHandler = new InflAPIHandler();
        
        for (Contact contact : scope) {
            List<Reward__c> rewards = contact.Rewards__r;
            
            if (!rewards.isEmpty()) {
                
                for (Reward__c reward : rewards) {
                    String refType = refTypeMap.get(reward.Referenceability_Type__c);
                    
                    if (refType != null) {
                       totalRewardsToPost++; 
                    }
                }
             }
        }
         
        for (Contact contact : scope) {
            
            if (postedRewards == 88) {
                break;
            }
            List<Reward__c> rewards = contact.Rewards__r;
            
            if (rewards != null && !rewards.isEmpty()) {
                
                for (Reward__c reward : rewards) {  
                    
                    if (postedRewards == 88) {
                        break;
                    }
                    String refType = refTypeMap.get(reward.Referenceability_Type__c);
                    boolean expireInfl  = (reward.Expired_Points_in_influitive__c != null && reward.Expired_Points_in_influitive__c > 0) ? true : false;
                    
                    //in case redeem refType will come null so adding default Non-Reference Activity ref type.
                    if (reward.Transaction__c == ConstantsController.REDEEM) {
                       refType = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                    }
                    String contactId = reward.Contact__c;
                    String rewardId = reward.Id;
                    //checking if reward are expired in both refedge and influitive side then no need to post event.
                    boolean flag = !((expireInfl == true || reward.Expired__c == true) && (expireInfl == true && reward.Expired__c == true));
                    
                    //Ignore reward which have no referenceability_code mapped to referenceability
                    if (refType == null) {
                       rewardFailedToPost.add(reward.id);
                    }
                    
                    if (refType != null && flag) {
                        postedRewards++;
                        
                        //Constructing Infl_EventJSON object
                        Infl_EventJSON request = new Infl_EventJSON(); 
                        request.type = refType;
                        //Contact
                        Infl_EventJSON.cls_contact inflcontact = new Infl_EventJSON.cls_contact();
                        inflcontact.email = contactEventMap.get(contactId);
                        inflcontact.crm_contact_id = contactId;//re #190 
                        request.contact = inflcontact;
                        InflCreateEventResponse response = null;
                        
                        if (reward.Transaction__c == ConstantsController.ISSUE && reward.Influitive_ID2__c == null) {
                            //if no influitive id
                            request.points = String.valueOf(reward.Amount__c);
                            response = apiHandler.createInflEvent(request);
                            
                            //REF-2300
                            if (response != null && response.id == null) {
                                request.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                                response = new InflCreateEventResponse();
                                response = apiHandler.createInflEvent(request);           
                            }
                            
                            if (reward.Expired__c) {
                                refType = ConstantsController.EXPIRED_REWARD_EVENT;
                                request.type = refType;
                                request.points = '-' + String.valueOf(reward.Expired_Points__c );
                                apiHandler.createInflEvent(request); 
                            }
                        } else if (reward.Transaction__c == ConstantsController.REDEEM) {
                            request.points = '-' + String.valueOf(reward.Amount__c );
                            response = apiHandler.createInflEvent(request); 
                        } else if (reward.Expired__c) {
                            refType = ConstantsController.EXPIRED_REWARD_EVENT;
                            request.type = refType;
                            //if reward was expired so reedeem this reward in influitive and posting negative event
                            request.points = '-' + String.valueOf(reward.Expired_Points__c );
                            response = apiHandler.createInflEvent(request); 
                        } else if (!reward.Expired__c && expireInfl) {
                            refType = ConstantsController.EXPIRED_REWARD_EVENT;
                            request.type = refType;
                            //if reward not expired but expired on influitive
                            request.points = String.valueOf(reward.Expired_Points_in_influitive__c);
                            response = apiHandler.createInflEvent(request); 
                        } else if (!reward.Expired__c) {
                            //if reward not expired
                            request.points = String.valueOf(reward.Available_Points__c);
                            response = apiHandler.createInflEvent(request);
                            
                            //REF-2300
                            if (response != null && response.id == null) {
                                request.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                                response = new InflCreateEventResponse();
                                response = apiHandler.createInflEvent(request);           
                            }
                        }
                        
                        //Checking if any reward get failed to post in influitive REF-2300
                        if (response == null && (response.id == null || response.id == '')) {
                            rewardFailedToPost.add(reward.id);
                        }
                        
                        //Update influitive id on reward if reward expired no need to update
                        if (response != null && response.id != null && response.id != '') {
                            
                            if (reward.Influitive_ID2__c == null) {
                                reward.Influitive_ID2__c = response.id;
                            }
                            
                            if (reward.Expired__c == true) {
                                reward.Expired_Points_in_influitive__c = reward.Expired_Points__c ;
                            } else {
                                reward.Expired_Points_in_influitive__c = 0;
                            }
                            inflRewards.add(reward);
                        }
                    }
                } 
            }
        } 
        
        totalRewardsToPostInfl = totalRewardsToPost;
        postedRewardsInfl = postedRewards;
        return inflRewards;
    } 
    
    /**
     * Method to Update Profile Updates
     */
    public void updateProfileUpdates() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Refresh__c', new Set<String>{
                            UtilityController.appNamespace() + 'Reference_Refresh_Status__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true) && cs.PUM_No_Response_Days__c != null && cs.PUM_No_Response_Days__c > 0) {
                ID batchprocessid = Database.executebatch(new Batch_ProfileUpdateNoResponse(true));
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Profile_Updates__c = true;
                upsert appConfig;
                refresh();
            } else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Fill_No_Response_Days);
                Apexpages.addMessage(message);
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to Update current avilable point for RBI - #808
     */
    public void updateRBIPoint() {
        
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Basic_Information__c', new Set<String>{
                            UtilityController.appNamespace() + 'Current_Available_Balance_Points__c'}); 
            fieldMap.put(UtilityController.appNamespace() + 'Reward__c', new Set<String>{
                            UtilityController.appNamespace() + 'Expired__c'});
              
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {                
                ID batchprocessid = Database.executebatch(new Batch_UpdateCurrentAvailablePoints());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Current_Available_Points_for_RBI__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to update all related attribute mapping to account and contact
     * Created By: Rekha @1 May 2017
     */
    public void updateAccConRelatedAttributeMappings() {
        try {
            
            if (checkPermissionsAttMapping()) {
                Map<Id, Boolean> mappingMap = new Map<Id, Boolean>();
                Set<Id> attMapping = new Set<Id>();
                //fetch all related mapping for account and contact
                List<Attribute_Mapping__c> attributeMappings = [SELECT Id, Child_RelationShipName__c, RelationShip_Name__c, 
                                    Object__c, Field_Api_Name__c, Related_Object__c, Mapping_Type__c 
                                    FROM Attribute_Mapping__c 
                                    WHERE Related_Object__c = 'Account' OR Related_Object__c = 'Contact' 
                                    LIMIT : limits.getLimitQueryRows()];
                
                //change base object and relationship 
                for (Attribute_Mapping__c attMapp : attributeMappings) {
                    
                    if (attMapp.Related_Object__c == 'Account') {
                        attMapp.Child_RelationShipName__c = '';
                        attMapp.RelationShip_Name__c = UtilityController.appNamespace() + 'Account__c';
                        attMapp.Object__c = 'Reference Profile';
                        attMapp.Mapping_Type__c = 'Parent Object';
                    } else if (attMapp.Related_Object__c == 'Contact') {
                        attMapp.Child_RelationShipName__c = '';
                        attMapp.RelationShip_Name__c = UtilityController.appNamespace() + 'Contact__c';
                        attMapp.Object__c = 'Reference Profile';
                        attMapp.Mapping_Type__c = 'Parent Object';
                    }
                }
                
                if (attributeMappings.size() > 0) {
                    update attributeMappings;
                }
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Related_Attribute_Mapping_for_A_C__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsAttMapping() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Attribute_Mapping__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Mapping_Type__c',
                                                UtilityController.appNamespace() + 'Object__c',
                                                UtilityController.appNamespace() + 'RelationShip_Name__c',
                                                UtilityController.appNamespace() + 'Child_RelationShipName__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * Method to update all Attributes
     */
    public void updateInheritableAttributes() {
        try {
            
            if (checkPermissionsAtt(new Set<String> { UtilityController.appNamespace() + 'Inheritable__c' })) {
                Map<Id, Boolean> mappingMap = new Map<Id, Boolean>();
                Set<Id> attMapping = new Set<Id>();
                List<Attribute__c> attributes = [SELECT Name, Id, Inheritable__c, Attribute_Mapping__c,level__c FROM Attribute__c 
                                    WHERE Attribute_Mapping__c != null and level__c = 0 ORDER BY level__c LIMIT : limits.getLimitQueryRows()];
                
                for (Attribute__c newAtt : attributes) {
                    attMapping.add(newAtt.Attribute_Mapping__c);
                }
                List<Attribute_Mapping__c> attMappings = [SELECT Id, Inheritable__c FROM Attribute_Mapping__c WHERE Id In : attMapping];
                
                for (Attribute_Mapping__c attM : attMappings) {
                    mappingMap.put(attM.Id, attM.Inheritable__c);
                }
                
                for (Attribute__c newAtt : attributes) {
                    newAtt.Inheritable__c = mappingMap.get(newAtt.Attribute_Mapping__c);
                }
                
                if (attributes.size() > 0) {
                    update attributes;
                }
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Inheritable_Value_in_Attributes__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsAtt(Set<String> fieldSet) {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Attribute__c', fieldSet);
        Boolean isUpdatePermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        Boolean isDeletePermission = true;

        if (fieldSet.contains(UtilityController.appNamespace() + 'Product_ID__c')) {
            isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Attributes_Labels__c'});
        }
        return isUpdatePermission && isDeletePermission;
    }
    /**
     * Method to update all Attributes
     */
    public void updateAttributes() {
        try {
            
            if (checkPermissionsAtt(new Set<String> { UtilityController.appNamespace() + 'Root_Parent__c' })) {
                List<Attribute__c> attributelist = new List<Attribute__c>();
                Map<String, Attribute__c> rootAttributeMap = new Map<String, Attribute__c>();
                List<Attribute__c> attributes = [SELECT Name, Id, parent__c, Root_Parent__c, level__c, parentIds__c 
                                                FROM Attribute__c ORDER BY level__c limit : limits.getLimitQueryRows()];
                
                for (Attribute__c newAtt : attributes) {
                    
                    if (newAtt.Level__c == 0 && !rootAttributeMap.containsKey(newAtt.Id)) {
                        rootAttributeMap.put(newAtt.Id,newAtt);
                    }
                }
                
                for (Attribute__c newAtt : attributes) {
                    
                    if (newAtt.Level__c > 0) {
                        Set<String> tempSet = new Set<String>();
                        
                        if (newAtt.ParentIds__c != null) {
                            tempSet.addAll(newAtt.ParentIds__c.split(','));
                        }
                        
                        for (String parentId : tempSet) {
                            
                            if (rootAttributeMap.containsKey(parentId)) {
                                newAtt.Root_Parent__c = rootAttributeMap.get(parentId).Name;
                                attributelist.add(newAtt);
                            }
                        }
                    }
                }
                
                if (attributelist.size() > 0) {
                    update attributelist;
                }
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Attributes__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    /**
     * Method to update all Filters
     */
    public void updateFilters() {
        try {
            
            if (checkPermissionsDataMapping()) {
                List<Label__c> labelList = [SELECT Id, Name, BasicSearchView__c, Filter_RefSearch_Visible__c FROM Label__c 
                                        ORDER BY Name LIMIT: limits.getLimitQueryRows()];
                                        
                for (Label__c label : labelList) {
                    label.Filter_RefSearch_Visible__c = true;
                }
                
                if (labelList.size() > 0) {
                    update labelList;
                }
                List<Data_Mapping__c> filterList = [SELECT Name, Order__c, Id, Required__c, Filter_RefSearch_Visible__c, Label__c, Visible__c, Field_API_Name__c 
                                            FROM Data_Mapping__c WHERE Object__c = 'Filter' ORDER BY Order__c, Label__c];
                Set<String> fieldApiSet = new Set<String>();
                
                for (Data_Mapping__c dm : filterList) {
                    fieldApiSet.add(dm.Field_API_Name__c);
                    dm.Filter_RefSearch_Visible__c= true;
                }
                
                if (!fieldApiSet.contains('Referenceability')) {
                    filterList.add(new Data_Mapping__c(Required__c = false, Filter_RefSearch_Visible__c = true, Label__c = 'Referenceability', 
                                                    Field_API_Name__c = 'Referenceability', Object__c = 'Filter'));
                }
                
                if (!fieldApiSet.contains('Content Language')) {
                    filterList.add(new Data_Mapping__c(Required__c = false, Filter_RefSearch_Visible__c = true, Label__c = 'Content Language', 
                                                    Field_API_Name__c = 'Content Language', Object__c = 'Filter'));
                }
                
                if (!fieldApiSet.contains('Content Types')) {
                    filterList.add(new Data_Mapping__c(Required__c = false, Filter_RefSearch_Visible__c = true, Label__c = 'Content Types', 
                                                    Field_API_Name__c = 'Content Types', Object__c = 'Filter'));
                }
                
                for (Attribute_Mapping__c attM : [SELECT Id, field__c, Field_Api_Name__c, Filter_Label_Name__c FROM Attribute_Mapping__c 
                        WHERE Is_Related_Mapping__c = true and Object__c != 'Opportunity' and Related_Object__c != 'OpportunityLineItem']) {
                    
                    if (!fieldApiSet.contains(attM.Id)) {
                        filterList.add(new Data_Mapping__c(Required__c = false, Filter_RefSearch_Visible__c = true, Label__c = attM.Filter_Label_Name__c, 
                                                    Field_API_Name__c = attM.Id, Object__c = 'Filter', From_Mapping__c = true));
                    }
                }
                
                if (filterList.size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;
                    upsert filterList;
                }
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Filters__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsDataMapping() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Required__c',
                                                UtilityController.appNamespace() + 'Filter_RefSearch_Visible__c',
                                                UtilityController.appNamespace() + 'Label__c',
                                                UtilityController.appNamespace() + 'Field_API_Name__c',
                                                UtilityController.appNamespace() + 'Object__c',
                                                UtilityController.appNamespace() + 'From_Mapping__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
    }
    /**
     * Method to Update old Filter
     */
    public void updateFilterNumbers() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Label__c', new Set<String>{
                            UtilityController.appNamespace() + 'Filter_no__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                ID batchprocessid = Database.executebatch(new Batch_DataUpdate_Filters());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Filter_Numbers__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    /**
     * Method to Update old Referenceability Types
     */
    public void updateReferenceabilityTypes() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String>{
                            UtilityController.appNamespace() + 'Referenceability_no__c',
                            UtilityController.appNamespace() + 'Referenceability_Type__c',
                            UtilityController.appNamespace() + 'Request_type__c',
                            UtilityController.appNamespace() + 'Project_type__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                ID batchprocessid = Database.executebatch(new Batch_DataUpdate_RefTypes());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Update_Referenceability_Types__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }

    /**
     * Method to Update Reference Profiles
     */
    public void updateReferenceProfiles() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Contact_Attribute__c', new Set<String>{
                            UtilityController.appNamespace() + 'Reference_Basic_Information__c'});
            fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String>{
                            UtilityController.appNamespace() + 'Reference_Basic_Information__c'});
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Basic_Information__c', new Set<String>{
                            UtilityController.appNamespace() + 'Attributes__c',
                            UtilityController.appNamespace() + 'Attribute_Ids__c',
                            UtilityController.appNamespace() + 'Label_Ids1__c',
                            UtilityController.appNamespace() + 'Label_Ids2__c',
                            UtilityController.appNamespace() + 'Parent_Attributes__c',
                            UtilityController.appNamespace() + 'Last_Att_Ref_Update__c',
                            UtilityController.appNamespace() + 'Att_Ref_Last_Update_By__c',
                            UtilityController.appNamespace() + 'Last_Refresh_Date__c',
                            UtilityController.appNamespace() + 'ReferenceabilityType_Ids1__c',
                            UtilityController.appNamespace() + 'ReferenceabilityType_Ids2__c',
                            UtilityController.appNamespace() + 'Referenceability__c'});

            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                ID batchprocessid = Database.executebatch(new Batch_DataUpdate_RBI());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Update_Reference_Profiles__c = true;
                upsert appConfig;
                refresh();
            } else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Complete_Previous_Scripts);
                Apexpages.addMessage(message);
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }

    /**
     * Method to Update Reference Content 
     */
    public void updateReferenceContents() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String>{
                            UtilityController.appNamespace() + 'Associated_Accounts__c',
                            UtilityController.appNamespace() + 'Reference_Content_Type_Name__c',
                            UtilityController.appNamespace() + 'Content_ID__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                ID batchprocessid = Database.executebatch(new Batch_DataUpdate_RefContent());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Update_Reference_Content__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }

    /**
     * Method to update Reference Requests and Invitations
     */
    public void updateReferenceRequestsInvitations() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Requests_and_Invitations__c', new Set<String>{
                            UtilityController.appNamespace() + 'Opportunity__c',
                            UtilityController.appNamespace() + 'Reference_Request__c',
                            UtilityController.appNamespace() + 'Invitation__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false)) {
                ID batchprocessid = Database.executebatch(new Batch_DataCreate_RRI());
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Create_Request_Invitation_Records__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }

    /**
     * Method to Delete Reward Declined Request
     */
    public void deleteRewards() {
        try {
            ID batchprocessid = Database.executebatch(new Batch_deleteRewardDeclinedRequest());
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
            appConfig.Is_Update_Reward_Declined_Request_Record__c = true;
            upsert appConfig;
            refresh();
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to Delete Reward Declined Request
     */
    public void updateAccountContactRequests() {
        try {
            
            if (checkPermissionsCSUpdate()) {
                cs.Consider_No_longer_needed_a_use__c = true;
                update cs;
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Update_Account_and_Contact_Request_NLN__c = true;
                upsert appConfig;
                refresh();
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
     /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsCSUpdate() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Consider_No_longer_needed_a_use__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    /**
     * Method to Create Chatter Group
     */
    /*
    public void createChatterGroup() {
        try {
            if (isChatterEnabled && groupName == 'Customer Reference Team') {
                Map < String, schema.sobjecttype > gd = CRUDAndFLSCheckController.sObjectsMap;
                if (gd.containsKey('CollaborationGroup')) {
                    sObject sObj = CRUDAndFLSCheckController.sObjectsMap.get('CollaborationGroup').newSObject();
                    sObj.put('Name', groupName);
                    sObj.put('CollaborationType', 'Private');
                    sObj.put('CanHaveGuests', true);
                    insert sObj;
                    refresh();
                } else {
                    throw new CustomException(system.label.Turn_on_Chatter_Settings);
                }
            } else {
                throw new CustomException(system.label.Create_a_Group_Message);
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    */
    /**
     * Method to Create Group
     */
    public void createPublicGroup() {
        try {
            if (groupName == 'Customer Reference Team') {
                Group g = new Group(Name = groupName, Type = 'Regular', DoesIncludeBosses = true);
                insert g;
                refresh();
            } else {
                throw new CustomException(system.label.Create_a_Group_Message);
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to delete and Schedule Jobs which are scheduled by ReferenceEdge User through the post install script
     * regarding #486
     * changes regarding #744
     */
    public void scheduleJobs() {
        try {
            Set<String> deleteJobs = new Set<String>();
            Map<String, String> cronMap = new Map<String, String>();
            RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
            String jobName = '';
            Set<String> jobNames = new Set<String>{'RefEdge_AccountAttribute', 'RefEdge_ContactAttribute',
                                        'RefEdge_ContentAttribute', 'RefEdge_ReferenceRequestAccount',
                                        'RefEdge_ResetRBIRewardsPoint', 'RefEdge_SendRefYetNotification',
                                        'RefEdge_ResetAccountRULAndSmartSearch', 'RefEdge_MicrositeVisits',
                                        'RefEdge_ReferenceRequestFeedback','RefEdge_ResetAccountRUL',
                                        'RefEdge_ReferenceRequestNoResponse', 'RefEdge_SmartSearchCount',
                                        'RefEdge_ReferenceRequestReminder', 'RefEdge_ReferenceRequestEscalation',
                                        'RefEdge_ResetContactRUL', 'RefEdge_OpportunityAttribute',
                                        'RefEdge_AdvancedRouting', 'RefEdge_InactiveOwnersNotification',
                                        'RefEdge_ReferenceContentReminder', 'RefEdge_SyncObjectMappingAttributes'};
            //get all scheduled job which are scheduled by the ReferenceEdge user
            for (CronTrigger ct : [SELECT Id, OwnerId, CronJobDetailId, CronJobDetail.JobType, CronJobDetail.Name, CronExpression, createdById FROM CronTrigger LIMIT :limits.getLimitQueryRows()]) {
                
                //  REF-2221 (Rajneesh - April, 4, 2019)
                if(ct.CronJobDetailId != null && CronJobDetail.Name != null) {
                    cronMap.put(ct.Id, String.valueOf(ct.CronJobDetail.Name)); 
                    jobName = (String.valueOf(ct.CronJobDetail.Name).contains('Retry : ') ? 
                                            String.valueOf(ct.CronJobDetail.Name).substringAfterLast('Retry : ').substringBefore(' Schedular')
                                            : String.valueOf(ct.CronJobDetail.Name).substringBefore(' Schedular'));

                    if (jobNames.contains(jobName)) {
                        deleteJobs.add(String.valueOf(ct.CronJobDetail.Name));
                        //to delete the scheduled job one by one
                        System.abortJob(ct.Id);
                    }
                }
            }
            Set<String> setApexClassId = new Set<String>();
            
            //get all scheduled jobs 
            for (AsyncApexJob aaj : [SELECT Status, ApexClassId FROM AsyncApexJob
                                        WHERE JobType = 'ScheduledApex'
                                        AND Status NOT IN ('Aborted', 'Completed', 'Failed')
                                        LIMIT :limits.getLimitQueryRows()]) {
                setApexClassId.add(aaj.ApexClassId);
            }
            
            Set<String> apexClasses = new Set<String>();
            
            //get apex class of scheduled jobs
            for (ApexClass ac : [SELECT Name, Id FROM ApexClass WHERE Id IN :setApexClassId
                                    LIMIT :limits.getLimitQueryRows()]) {
                apexClasses.add(ac.Name.toLowerCase().trim());
            }
            
            //AccountAttribute Schedular
            Schedular_AccountAttribute aaSchedularClass = new Schedular_AccountAttribute();
            String aasch = '0 0 1 * * ?';
            
            if (!apexClasses.contains('schedular_accountattribute')) {
                Id aaSchedularId = System.Schedule('RefEdge_AccountAttribute Schedular', aasch, aaSchedularClass);
            }
            
            //ContactAttribute Schedular
            Schedular_ContactAttribute caSchedularClass = new Schedular_ContactAttribute();
            String casch = '0 20 1 * * ?';
            
            if (!apexClasses.contains('schedular_contactattribute')) {
                Id caSchedularId = System.Schedule('RefEdge_ContactAttribute Schedular', casch, caSchedularClass);
            }
            
            //ContentAttribute Schedular
            Schedular_AttributeMapping coaSchedularClass = new Schedular_AttributeMapping();
            String coasch = '0 40 1 * * ?';
            
            if (!apexClasses.contains('schedular_attributemapping')) {
                Id coaSchedularId = System.Schedule('RefEdge_ContentAttribute Schedular', coasch, coaSchedularClass);
            }
            
            //ResetRBIRewardsPoint Schedular
            Schedular_ResetRBIRewardsPoint rrrSchedularClass = new Schedular_ResetRBIRewardsPoint();
            String rrrsch = '0 0 2 * * ?';
            
            if (!apexClasses.contains('schedular_resetrbirewardspoint')) {
                Id rrrSchedularId = System.Schedule('RefEdge_ResetRBIRewardsPoint Schedular', rrrsch, rrrSchedularClass);
            }
            
            //SendRefYetNotification Schedular
            Schedular_SendRefYetNotification srynSchedularClass = new Schedular_SendRefYetNotification();
            String srynsch = '0 20 2 * * ?';
            
            if (!apexClasses.contains('schedular_sendrefyetnotification')) {
                Id srynSchedularId = System.Schedule('RefEdge_SendRefYetNotification Schedular', srynsch, srynSchedularClass);
            }
                        
            //MicrositeVisits Schedular
            Schedular_ResetRULSetting rrsSchedularClass = new Schedular_ResetRULSetting();
            String rrssch = '0 40 2 * * ?';
            
            if (!apexClasses.contains('schedular_resetrulsetting')) {
                Id rrsSchedularId = System.Schedule('RefEdge_MicrositeVisits Schedular', rrssch, rrsSchedularClass);
            }
            
            //ReferenceRequestAccount Schedular
            Schedular_ReferenceRequestAccount srrnrSchedularClass = new Schedular_ReferenceRequestAccount();
            String srrnrsch = '0 0 3 * * ?';
            
            if (!apexClasses.contains('Schedular_referencerequestaccount')) {
                Id srrnrSchedularId = System.Schedule('RefEdge_ReferenceRequestAccount Schedular', srrnrsch, srrnrSchedularClass);
            }
            
            //  REF-1308 
            //ReferenceContentReminder Schedular
            Schedular_ReferenceContentReminder srefConSchedularClass = new Schedular_ReferenceContentReminder();
            String srctrsch = '0 20 3 * * ?';
            
            if (!apexClasses.contains('Schedular_referencecontentreminder')) {
                Id srctrschedularId = System.Schedule('RefEdge_ReferenceContentReminder Schedular', srctrsch, srefConSchedularClass);
            } 
            
            //ResetAccountRULAndSmartSearch Schedular
            Schedular_ResetAccountRULAndSmartSearch rarulSchedularClass = new Schedular_ResetAccountRULAndSmartSearch();
            String rarulsch = '0 40 3 * * ?';
            
            if (!apexClasses.contains('Schedular_resetaccountrulandsmartsearch')) {
                Id srrnrSchedularId = System.Schedule('RefEdge_ResetAccountRULAndSmartSearch Schedular', rarulsch, rarulSchedularClass);
            }

            //ReferenceRequestFeedback Schedular
            Scheduler_RefReqReminderAndFeedback srrfSchedularClass = new Scheduler_RefReqReminderAndFeedback();
            String srrfsch = '0 0 4 * * ?';
            
            if (!apexClasses.contains('scheduler_refreqreminderandfeedback')) {
                Id srrfSchedularId = System.Schedule('RefEdge_ReferenceRequestFeedback Schedular', srrfsch, srrfSchedularClass);
            }
            
            //ResetContactRUL Schedular
            Schedular_ResetContactRUL rcrSchedularClass = new Schedular_ResetContactRUL();
            String rcrsch = '0 20 4 * * ?';
            
            if (!apexClasses.contains('schedular_resetcontactrul')) {
                Id rcrSchedularId = System.Schedule('RefEdge_ResetContactRUL Schedular', rcrsch, rcrSchedularClass);
            }
            
            //OpportunityAttribute Schedular
            Schedular_OpportunityAttribute oppAttSchedularClass = new Schedular_OpportunityAttribute();
            String oppAttrsch = '0 40 4 * * ?';
            
            if (!apexClasses.contains('schedular_opportunityattribute')) {
                Id oppAttSchedularId = System.Schedule('RefEdge_OpportunityAttribute Schedular', oppAttrsch, oppAttSchedularClass);
            }
            
            //Advanced routing schedular
            Schedular_AdvRoutingBusinessGroup advRoutingSchedularClass = new Schedular_AdvRoutingBusinessGroup();
            String advRoutingrsch = '0 0 5 * * ?';
            
            if (!apexClasses.contains('schedular_advroutingbusinessgroup')) {
                Id advRoutingSchedularId = System.Schedule('RefEdge_AdvancedRouting Schedular', advRoutingrsch, advRoutingSchedularClass);
            }
            
            //Advanced routing schedular
            Schedular_InactiveOwnersNotification inactiveOwnerNotiSchedularClass = new Schedular_InactiveOwnersNotification();
            String inactiveOwnerNotirsch = '0 20 5 ? * MON';
            
            if (!apexClasses.contains('schedular_inactiveownersnotification')) {
                Id inactiveOwnerNotiSchedularId = System.Schedule('RefEdge_InactiveOwnersNotification Schedular', inactiveOwnerNotirsch, inactiveOwnerNotiSchedularClass);
            }

            // Sync attributes for sObject Attribute Mappings
            Schedular_SyncTaxonomyAttributes syncTaxonomyAttsSchedularClass = new Schedular_SyncTaxonomyAttributes();
            String syncTaxonomyAttsSch = '0 40 5 * * ?';
            
            if (!apexClasses.contains('schedular_synctaxonomyattributes')) {
                Id syncTaxonomyAttsSchedularId = System.Schedule('RefEdge_SyncObjectMappingAttributes Schedular', syncTaxonomyAttsSch, syncTaxonomyAttsSchedularClass);
            }

        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
     /**
     * Method to calculate months 
     */
    static string returnMonth(Integer month, String launchFreq) {
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
    static string addMonths(Integer month, Integer monthVal) {
        string finalExp = '';
        Integer tempMonth = month;
        
        for (Integer i = 0; i < 12 / monthVal; i++) {
            finalExp += (finalExp == '' ? '' + tempMonth : ',' + tempMonth);
            tempMonth = (tempMonth + monthVal > 12 ? tempMonth + monthVal - 12 : tempMonth + monthVal);
        }
        return finalExp;
    }

    /**
     * Method to Create Permission Set
     */
    public void createPermissionSet() {
        Savepoint sp = Database.setSavepoint();
        try {
            String profileQuery = '';
            Map<String, Schema.SObjectField> fldProfileObjMap = schema.SObjectType.Profile.fields.getMap();
            Set<String> profileFields = new Set<String>();
            
            for (String field : fldProfileObjMap.keyset()) {
                profileFields.add(field);
                profileQuery += (profileQuery == '' ? field : ',' + field);
            }
            List<Profile> profile = database.query('SELECT ' + profileQuery + ' FROM Profile WHERE name =: psName');

            if (profile.size() > 0) {
                String profileId = profile.get(0).id;

                PermissionSet ps = new PermissionSet(Label = profile.get(0).Name, Name = profile.get(0).Name.replaceAll('\\s+', ''));
                insert ps;

                //Insert ObjectPermissions
                Set<String> nativeObject = new Set<String> {
                    'Account', 'Contact', 'Opportunity', 'Case', 'Lead', 'ContentVersion'
                };
                List<ObjectPermissions> objPermissionList = new List<ObjectPermissions>();
                
                for (ObjectPermissions op : [SELECT SobjectType, ParentId, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, 
                        PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE Parent.ProfileId = : profileId]) {
                    
                    if (op.SobjectType.contains('refedge__') || nativeObject.contains(op.SobjectType)) {
                        objPermissionList.add(new ObjectPermissions(SobjectType = op.SobjectType, ParentId = ps.Id,
                            PermissionsRead = op.PermissionsRead, PermissionsCreate = op.PermissionsCreate,
                            PermissionsEdit = op.PermissionsEdit, PermissionsDelete = op.PermissionsDelete,
                            PermissionsViewAllRecords = op.PermissionsViewAllRecords,
                            PermissionsModifyAllRecords = op.PermissionsModifyAllRecords));
                    }
                }
                insert objPermissionList;

                //Insert FieldPermissions
                List<FieldPermissions> fieldPermissionList = new List<FieldPermissions>();
                
                for (FieldPermissions fp : [SELECT SobjectType, Field, ParentId, PermissionsRead, PermissionsEdit FROM FieldPermissions 
                        WHERE Parent.ProfileId = : profileId ORDER BY SobjectType ASC]) {
                    
                    if (fp.SobjectType.contains('refedge__') || nativeObject.contains(fp.SobjectType)) {
                        
                        if (!fp.Field.contains('Task.')) {
                            fieldPermissionList.add(new FieldPermissions(SobjectType = fp.SobjectType, Field = fp.Field, ParentId = ps.Id,
                                PermissionsRead = fp.PermissionsRead, PermissionsEdit = fp.PermissionsEdit));
                        }
                    }
                }

                insert fieldPermissionList;

                //Insert Apex Class, Page & Tabs Permissions
                List<SetupEntityAccess> setupEntityAccessList = new List<SetupEntityAccess>();
                
                for (SetupEntityAccess sea : [SELECT SetupEntityType, SetupEntityId, ParentId FROM SetupEntityAccess WHERE Parent.ProfileId =: profileId]) {
                    setupEntityAccessList.add(new SetupEntityAccess(SetupEntityId = sea.SetupEntityId, ParentId = ps.Id));
                }
                insert setupEntityAccessList;

                //Update PermissionSet 
                Set<String> notEditableFields = new Set<String> {
                    'id', 'createdbyid', 'createddate', 'systemmodstamp',
                    'lastmodifiedbyid', 'isownedbyprofile', 'namespaceprefix',
                    'profileid', 'userlicenseid', 'lastmodifieddate', 'name'
                };
                Map<String, Schema.SObjectField> fldPermissionSetObjMap = schema.SObjectType.PermissionSet.fields.getMap();
                PermissionSet psUpdate = new PermissionSet(Id = ps.Id);
                
                for (String field : fldPermissionSetObjMap.keyset()) {
                    
                    if (profileFields.contains(field) && !notEditableFields.contains(field)) {
                        psUpdate.put(field, profile.get(0).get(field));
                    }
                }
                update psUpdate;

                refresh();
            } else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, System.label.Create_profile_message + ' \'' + psName + '\'');
                Apexpages.addMessage(message);
            }
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }

    /**
     * Method to upgrade custom setting
     */
    public void upgradeCustomSetting() {
        try {
            
            if (!isUpdateRefedgeCustomSetting && checkPermissionsCS()) {
                List<Custom_Settings__c> customSettings = [SELECT Current_Version__c, Caution_deadline_window__c, Critical_Deadline_window__c, Nomination_disposition_window__c,
                    Default_Expiration_Days__c, Maximum_Expiration_Days__c, Organization_FiscalYearStartMonth__c, Default_Referenceablity_Status__c,
                    Microsite_Visit_Chatter__c, Microsite_Visit_Email__c, Nomination_Chatter__c, Nomination_Email__c, Request_Managed_Chatter__c,
                    Request_Managed_Email__c, Request_Peer2Peer_Chatter__c, Request_Peer2Peer_Email__c, Request_Escalation_Chatter__c, Request_Escalation_Email__c,
                    Request_Feedback_Chatter__c, Request_Feedback_Email__c, Request_No_Response_Chatter__c, Request_No_Response_Email__c, Request_Reminder_Chatter__c,
                    Request_Reminder_Email__c, Request_Approval_Decline_Email__c, Request_Approval_Decline_Chatter__c, Project_Owner_Update_Chatter__c,
                    Reference_Refresh_Update_Chatter__c, Reference_Refresh_Update_Email__c, Reference_Update_Chatter__c, Reference_Update_Email__c,
                    Project_Owner_Update_Email__c, Status_Update_Chatter__c, Status_Update_Email__c, Reference_Lead_No_Response_Email__c,
                    Reference_Lead_No_Response_Chatter__c, Check_back_in_Email__c, Check_back_in_Chatter__c, Initial_Notification_Email__c, Initial_Notification_Chatter__c,
                    Client_Referenceability_check_days__c, Prevent_selection_of_mapped_Attributes__c, Create_Nomination__c,
                    Minimum_Opportunity_Size__c, No_Response_days__c, Opportunity_Closed_Won_Stage__c,Consider_No_longer_needed_a_use__c,
                    RUL_Activities__c, RUL_Activities_Contact__c, RUL_Period__c, RUL_Period_Contact__c
                    FROM Custom_Settings__c WHERE Active_Version__c = true LIMIT 1];
                
                if (customSettings.size() > 0) {
                    customSettings[0].Current_Version__c = '1.75';
                    customSettings[0].Caution_deadline_window__c = (customSettings[0].Caution_deadline_window__c == null ? 7 : customSettings[0].Caution_deadline_window__c);
                    customSettings[0].Critical_Deadline_window__c = (customSettings[0].Critical_Deadline_window__c == null ? 4 : customSettings[0].Critical_Deadline_window__c);
                    customSettings[0].Nomination_disposition_window__c = (customSettings[0].Nomination_disposition_window__c == null ? 10 : customSettings[0].Nomination_disposition_window__c);
                    customSettings[0].Default_Expiration_Days__c = (customSettings[0].Default_Expiration_Days__c == null ? 7 : customSettings[0].Default_Expiration_Days__c);
                    customSettings[0].Maximum_Expiration_Days__c = (customSettings[0].Maximum_Expiration_Days__c == null ? 14 : customSettings[0].Maximum_Expiration_Days__c);
                    customSettings[0].Organization_FiscalYearStartMonth__c = (customSettings[0].Organization_FiscalYearStartMonth__c == null ? getOrganization() : customSettings[0].Organization_FiscalYearStartMonth__c);
                    customSettings[0].Default_Referenceablity_Status__c = (customSettings[0].Default_Referenceablity_Status__c == null ? ConstantsController.ACTIVE : customSettings[0].Default_Referenceablity_Status__c);
                    customSettings[0].Microsite_Visit_Chatter__c = (customSettings[0].Microsite_Visit_Chatter__c == null ? true : customSettings[0].Microsite_Visit_Chatter__c);
                    customSettings[0].Microsite_Visit_Email__c = (customSettings[0].Microsite_Visit_Email__c == null ? true : customSettings[0].Microsite_Visit_Email__c);
                    customSettings[0].Nomination_Chatter__c = (customSettings[0].Nomination_Chatter__c == null ? true : customSettings[0].Nomination_Chatter__c);
                    customSettings[0].Nomination_Email__c = (customSettings[0].Nomination_Email__c == null ? true : customSettings[0].Nomination_Email__c);
                    customSettings[0].Request_Managed_Chatter__c = (customSettings[0].Request_Managed_Chatter__c == null ? true : customSettings[0].Request_Managed_Chatter__c);
                    customSettings[0].Request_Managed_Email__c = (customSettings[0].Request_Managed_Email__c == null ? true : customSettings[0].Request_Managed_Email__c);
                    customSettings[0].Request_Peer2Peer_Chatter__c = (customSettings[0].Request_Peer2Peer_Chatter__c == null ? true : customSettings[0].Request_Peer2Peer_Chatter__c);
                    customSettings[0].Request_Peer2Peer_Email__c = (customSettings[0].Request_Peer2Peer_Email__c == null ? true : customSettings[0].Request_Peer2Peer_Email__c);
                    customSettings[0].Request_Escalation_Chatter__c = (customSettings[0].Request_Escalation_Chatter__c == null ? true : customSettings[0].Request_Escalation_Chatter__c);
                    customSettings[0].Request_Escalation_Email__c = (customSettings[0].Request_Escalation_Email__c == null ? true : customSettings[0].Request_Escalation_Email__c);
                    customSettings[0].Request_Feedback_Chatter__c = (customSettings[0].Request_Feedback_Chatter__c == null ? true : customSettings[0].Request_Feedback_Chatter__c);
                    customSettings[0].Request_Feedback_Email__c = (customSettings[0].Request_Feedback_Email__c == null ? true : customSettings[0].Request_Feedback_Email__c);
                    customSettings[0].Request_No_Response_Chatter__c = (customSettings[0].Request_No_Response_Chatter__c == null ? true : customSettings[0].Request_No_Response_Chatter__c);
                    customSettings[0].Request_No_Response_Email__c = (customSettings[0].Request_No_Response_Email__c == null ? true : customSettings[0].Request_No_Response_Email__c);
                    customSettings[0].Request_Reminder_Chatter__c = (customSettings[0].Request_Reminder_Chatter__c == null ? true : customSettings[0].Request_Reminder_Chatter__c);
                    customSettings[0].Request_Reminder_Email__c = (customSettings[0].Request_Reminder_Email__c == null ? true : customSettings[0].Request_Reminder_Email__c);
                    customSettings[0].Request_Approval_Decline_Email__c = (customSettings[0].Request_Approval_Decline_Email__c == null ? true : customSettings[0].Request_Approval_Decline_Email__c);
                    customSettings[0].Request_Approval_Decline_Chatter__c = (customSettings[0].Request_Approval_Decline_Chatter__c == null ? true : customSettings[0].Request_Approval_Decline_Chatter__c);
                    customSettings[0].Project_Owner_Update_Chatter__c = (customSettings[0].Project_Owner_Update_Chatter__c == null ? true : customSettings[0].Project_Owner_Update_Chatter__c);
                    customSettings[0].Project_Owner_Update_Email__c = (customSettings[0].Project_Owner_Update_Email__c == null ? true : customSettings[0].Project_Owner_Update_Email__c);
                    customSettings[0].Reference_Refresh_Update_Chatter__c = (customSettings[0].Reference_Refresh_Update_Chatter__c == null ? true : customSettings[0].Reference_Refresh_Update_Chatter__c);
                    customSettings[0].Reference_Refresh_Update_Email__c = (customSettings[0].Reference_Refresh_Update_Email__c == null ? true : customSettings[0].Reference_Refresh_Update_Email__c);
                    customSettings[0].Reference_Update_Chatter__c = (customSettings[0].Reference_Update_Chatter__c == null ? true : customSettings[0].Reference_Update_Chatter__c);
                    customSettings[0].Reference_Update_Email__c = (customSettings[0].Reference_Update_Email__c == null ? true : customSettings[0].Reference_Update_Email__c);
                    customSettings[0].Status_Update_Chatter__c = (customSettings[0].Status_Update_Chatter__c == null ? true : customSettings[0].Status_Update_Chatter__c);
                    customSettings[0].Status_Update_Email__c = (customSettings[0].Status_Update_Email__c == null ? true : customSettings[0].Status_Update_Email__c);
                    customSettings[0].Reference_Lead_No_Response_Email__c = (customSettings[0].Reference_Lead_No_Response_Email__c == null ? true : customSettings[0].Reference_Lead_No_Response_Email__c);
                    customSettings[0].Reference_Lead_No_Response_Chatter__c = (customSettings[0].Reference_Lead_No_Response_Chatter__c == null ? true : customSettings[0].Reference_Lead_No_Response_Chatter__c);
                    customSettings[0].Check_back_in_Email__c = (customSettings[0].Check_back_in_Email__c == null ? true : customSettings[0].Check_back_in_Email__c);
                    customSettings[0].Check_back_in_Chatter__c = (customSettings[0].Check_back_in_Chatter__c == null ? true : customSettings[0].Check_back_in_Chatter__c);
                    customSettings[0].Initial_Notification_Email__c = (customSettings[0].Initial_Notification_Email__c == null ? true : customSettings[0].Initial_Notification_Email__c);
                    customSettings[0].Initial_Notification_Chatter__c = (customSettings[0].Initial_Notification_Chatter__c == null ? true : customSettings[0].Initial_Notification_Chatter__c);
                    customSettings[0].Client_Referenceability_check_days__c = (customSettings[0].Client_Referenceability_check_days__c == null ? 60 : customSettings[0].Client_Referenceability_check_days__c);
                    customSettings[0].Prevent_selection_of_mapped_Attributes__c = (customSettings[0].Prevent_selection_of_mapped_Attributes__c == null ? true : customSettings[0].Prevent_selection_of_mapped_Attributes__c);
                    customSettings[0].Create_Nomination__c = (customSettings[0].Create_Nomination__c == null ? true : customSettings[0].Create_Nomination__c);
                    customSettings[0].Minimum_Opportunity_Size__c = (customSettings[0].Minimum_Opportunity_Size__c == null ? 50000000 : customSettings[0].Minimum_Opportunity_Size__c);
                    customSettings[0].No_Response_days__c = (customSettings[0].No_Response_days__c == null ? 62 : customSettings[0].No_Response_days__c);
                    customSettings[0].Opportunity_Closed_Won_Stage__c = (customSettings[0].Opportunity_Closed_Won_Stage__c == null ? 'Closed Won' : customSettings[0].Opportunity_Closed_Won_Stage__c);
                    customSettings[0].RUL_Activities__c = (customSettings[0].RUL_Activities__c == null ? 3 : customSettings[0].RUL_Activities__c);
                    customSettings[0].RUL_Activities_Contact__c = (customSettings[0].RUL_Activities_Contact__c == null ? 3 : customSettings[0].RUL_Activities_Contact__c);
                    customSettings[0].RUL_Period__c = (customSettings[0].RUL_Period__c == null ? 90 : customSettings[0].RUL_Period__c);
                    customSettings[0].RUL_Period_Contact__c = (customSettings[0].RUL_Period_Contact__c == null ? 90 : customSettings[0].RUL_Period_Contact__c);
                    customSettings[0].Consider_No_longer_needed_a_use__c = (customSettings[0].Consider_No_longer_needed_a_use__c == null ? true : customSettings[0].Consider_No_longer_needed_a_use__c);
                    customSettings[0].Approve_Decline_Confirmation_Email__c = (customSettings[0].Approve_Decline_Confirmation_Email__c == null ? true : customSettings[0].Approve_Decline_Confirmation_Email__c);
                    customSettings[0].Approve_Decline_Confirmation_Chatter__c = (customSettings[0].Approve_Decline_Confirmation_Chatter__c == null ? true : customSettings[0].Approve_Decline_Confirmation_Chatter__c);
                    customSettings[0].Sales_Reward_Point_Chatter__c = (customSettings[0].Sales_Reward_Point_Chatter__c == null ? true : customSettings[0].Sales_Reward_Point_Chatter__c);
                    customSettings[0].Sales_Reward_Point_Email__c = (customSettings[0].Sales_Reward_Point_Email__c == null ? true : customSettings[0].Sales_Reward_Point_Email__c);
                    customSettings[0].User_Reward_Email_Summary__c = (customSettings[0].User_Reward_Email_Summary__c == null ? true : customSettings[0].User_Reward_Email_Summary__c);
                    customSettings[0].User_Reward_Chatter_Summary__c = (customSettings[0].User_Reward_Chatter_Summary__c == null ? true : customSettings[0].User_Reward_Chatter_Summary__c);
                    ConstantsController.updateCustomSettingWithValidation = false;
                    update customSettings;

                    POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                    appConfig.Is_Update_Custom_Setting__c = true;
                    upsert appConfig;
                    refresh();
                }
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissionsCS() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Current_Version__c',
                                                UtilityController.appNamespace() + 'Caution_deadline_window__c',
                                                UtilityController.appNamespace() + 'Critical_Deadline_window__c',
                                                UtilityController.appNamespace() + 'Nomination_disposition_window__c',
                                                UtilityController.appNamespace() + 'Default_Expiration_Days__c',
                                                UtilityController.appNamespace() + 'Maximum_Expiration_Days__c',
                                                UtilityController.appNamespace() + 'Organization_FiscalYearStartMonth__c',
                                                UtilityController.appNamespace() + 'Default_Referenceablity_Status__c',
                                                UtilityController.appNamespace() + 'Microsite_Visit_Chatter__c',
                                                UtilityController.appNamespace() + 'Microsite_Visit_Email__c',
                                                UtilityController.appNamespace() + 'Nomination_Chatter__c',
                                                UtilityController.appNamespace() + 'Nomination_Email__c',
                                                UtilityController.appNamespace() + 'Request_Managed_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_Managed_Email__c',
                                                UtilityController.appNamespace() + 'Request_Peer2Peer_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c',
                                                UtilityController.appNamespace() + 'Request_Escalation_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_Escalation_Email__c',
                                                UtilityController.appNamespace() + 'Request_Feedback_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_Feedback_Email__c',
                                                UtilityController.appNamespace() + 'Request_No_Response_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_No_Response_Email__c',
                                                UtilityController.appNamespace() + 'Request_Reminder_Chatter__c',
                                                UtilityController.appNamespace() + 'Request_Reminder_Email__c',
                                                UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c',
                                                UtilityController.appNamespace() + 'Request_Approval_Decline_Chatter__c',
                                                UtilityController.appNamespace() + 'Project_Owner_Update_Chatter__c',
                                                UtilityController.appNamespace() + 'Project_Owner_Update_Email__c',
                                                UtilityController.appNamespace() + 'Reference_Refresh_Update_Chatter__c',
                                                UtilityController.appNamespace() + 'Reference_Refresh_Update_Email__c',
                                                UtilityController.appNamespace() + 'Reference_Update_Chatter__c',
                                                UtilityController.appNamespace() + 'Reference_Update_Email__c',
                                                UtilityController.appNamespace() + 'Status_Update_Chatter__c',
                                                UtilityController.appNamespace() + 'Status_Update_Email__c',
                                                UtilityController.appNamespace() + 'Reference_Lead_No_Response_Email__c',
                                                UtilityController.appNamespace() + 'Reference_Lead_No_Response_Chatter__c',
                                                UtilityController.appNamespace() + 'Check_back_in_Email__c',
                                                UtilityController.appNamespace() + 'Check_back_in_Chatter__c',
                                                UtilityController.appNamespace() + 'Initial_Notification_Email__c',
                                                UtilityController.appNamespace() + 'Initial_Notification_Chatter__c',
                                                UtilityController.appNamespace() + 'Client_Referenceability_check_days__c',
                                                UtilityController.appNamespace() + 'Prevent_selection_of_mapped_Attributes__c',
                                                UtilityController.appNamespace() + 'Create_Nomination__c',
                                                UtilityController.appNamespace() + 'Minimum_Opportunity_Size__c',
                                                UtilityController.appNamespace() + 'No_Response_days__c',
                                                UtilityController.appNamespace() + 'Opportunity_Closed_Won_Stage__c',
                                                UtilityController.appNamespace() + 'RUL_Activities__c',
                                                UtilityController.appNamespace() + 'RUL_Activities_Contact__c',
                                                UtilityController.appNamespace() + 'RUL_Period__c',
                                                UtilityController.appNamespace() + 'RUL_Period_Contact__c',
                                                UtilityController.appNamespace() + 'Consider_No_longer_needed_a_use__c',
                                                UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c',
                                                UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Chatter__c',
                                                UtilityController.appNamespace() + 'Sales_Reward_Point_Chatter__c',
                                                UtilityController.appNamespace() + 'Sales_Reward_Point_Email__c',
                                                UtilityController.appNamespace() + 'User_Reward_Email_Summary__c',
                                                UtilityController.appNamespace() + 'User_Reward_Chatter_Summary__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    /**
     * Method to get Organization Details
     */
    private static Integer getOrganization() {
        List<Organization> organization = [SELECT FiscalYearStartMonth, UsesStartDateAsFiscalYearName FROM Organization LIMIT 1];
        return (organization.size() > 0 ? organization[0].FiscalYearStartMonth : 1);
    }
    
    /**
     * Method to Update Contact Available Points 
     */
    public void updateContactAvailablePoints() {
        try {
            ID batchprocessid = Database.executebatch(new Batch_ResetContactRewardPoints());
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
            appConfig.Update_Contact_Available_Points__c = true;
            upsert appConfig;
            refresh();
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Re #1184, #1181
     * Method to Update Update_Attribute_in_Reference_Content__c 
     * Modified By: Rajneesh @Dec/08/2017
     */
    public void updateAttributeInRefContent() {
        ID batchprocessid = Database.executebatch(new Batch_UpdateAttributeToReferenceContent());
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        appConfig.Update_Attribute_in_Reference_Content__c = true;
        upsert appConfig;
        refresh();
    }
    /**
     * REF-1448, 1902
     * Method to Update Reset_Column_Selector_for_RfSearch_Page__c 
     * Modified By: Rajneesh Raj @ Aug 14,2018
     */
    Public void resetColumnSelector() {
        List<User_Mapping__c> userMapList = [SELECT id, Name FROM User_Mapping__c WHERE Process__c = 'Column Selector' LIMIT :limits.getLimitQueryRows()];
        POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        appConfig.Reset_Column_Selector_for_RfSearch_Page__c = true;
        
         if (userMapList.Size() > 0 && CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'User_Mapping__c' })) {
            Delete userMapList;
        }
        upsert appConfig;
        refresh();
    }
    
    /**
     * REF-1259
     * method to call batch for removing duplicate reference profiles
     */
    public void removeDuplicateRBIs() {
        try {
            List<String> objectNames = new List<String> {UtilityController.appNamespace() + 'Reference_Basic_Information__c', 
                                                         UtilityController.appNamespace() + 'Account_Attribute__c', 
                                                         UtilityController.appNamespace() + 'Referenceability__c',
                										 UtilityController.appNamespace() + 'Contact_Attribute__c',
                										 UtilityController.appNamespace() + 'Contact_Reference_Content__c',
                                                         UtilityController.appNamespace() + 'Account_Reference_Content__c'};
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String>{
                         UtilityController.appNamespace() + 'Reference_Content__c',
                         UtilityController.appNamespace() + 'Contact__c',
                         UtilityController.appNamespace() + 'Reference_Basic_Information__c'});
            fieldMap.put(UtilityController.appNamespace() + 'Contact_Attribute__c', new Set<String>{
                         UtilityController.appNamespace() + 'Reference_Basic_Information__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true) && CRUDAndFLSCheckController.isDeletable(objectNames)) {
                removeDuplicates();
                POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
                appConfig.Is_Merge_Duplicate_Profiles__c = true;
                upsert appConfig;
                refresh();
            } else {
                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Complete_Previous_Scripts);
                Apexpages.addMessage(message);
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    public void removeDuplicates() {
        Set<Id> accIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        List<AggregateResult> rbiList = [SELECT count(id), Account__c, Contact__c 
                                         FROM Reference_Basic_Information__c
                                         GROUP BY Contact__c, Account__c 
                                         HAVING (count(Id) > 1) LIMIT : limits.getLimitQueryRows()];
        
        for (AggregateResult rbi : rbiList) {
            
            if (rbi.get(UtilityController.appNamespace() + 'Contact__c') != null) {
                conIds.add((Id)rbi.get(UtilityController.appNamespace() + 'Contact__c'));
                
            }
            
            if (rbi.get(UtilityController.appNamespace() + 'Account__c') != null && rbi.get(UtilityController.appNamespace() + 'Contact__c') == null) {
                accIds.add((Id)rbi.get(UtilityController.appNamespace() + 'Account__c'));
            }
        }
        
        List<Account> listOfAccount = [SELECT Id,(SELECT Id, Account__c,Attributes__c,Contact__c FROM Reference_Basic_Informations__r WHERE Contact__c = null),
                                       (SELECT Id,Reference_Content__c FROM Account_Reference_Contents__r),
                                       (SELECT Id,Account__c,Contact__c,Referenceability_Type__c FROM Referenceabilities__r WHERE Contact__c = null),
                                       (SELECT Id,Account__c,Contact__c,Attribute__c,Reference_Content__c FROM Account_Attributes__r) 
                                       FROM Account 
                                       WHERE Id IN : accIds];
        
        List<Contact> listOfContact = [SELECT Id,(SELECT Id, Account__c,Attributes__c,Contact__c FROM Reference_Basic_Informations__r),
                                       (SELECT Id,Reference_Content__c FROM Contact_Reference_Contents__r),
                                       (SELECT Id,Account__c,Contact__c,Referenceability_Type__c FROM Referenceabilities__r),
                                       (SELECT Id,Account__c,Contact__c,Attribute__c FROM Contact_Attributes__r) 
                                       FROM Contact 
                                       WHERE Id IN : conIds];
        
        List<Reference_Basic_Information__c> accRbi;
        List<Reference_Basic_Information__c> rbisToDelete = new List<Reference_Basic_Information__c>();
        List<Account_Attribute__c> accAttrtoDelete = new List<Account_Attribute__c>();
        List<Referenceability__c> accReftoDelete = new List<Referenceability__c>();
        List<Account_Reference_Content__c> accRefContoDelete = new List<Account_Reference_Content__c>();
        
        Map<String, Account_Attribute__c> mapSetOfAccAttributesWithContent;
        Map<String, Account_Attribute__c> mapSetOfAccAttributesWithCon;
        Map<String, Account_Attribute__c> mapSetOfAccAttributes;
        Map<String, Referenceability__c> mapSetOfAccRefWithCon;
        Map<String, Referenceability__c> mapSetOfAccRef;
        Map<String, Account_Reference_Content__c> mapSetOfAccRefContent;
        Map<String, Reference_Basic_Information__c> mapContactIdRbi;                                
        
        if (listOfAccount.size() > 0) {
            ConstantsController.isCallFromBatchRemoveDuplicateRBI = true;
            ConstantsController.shouldAccountAttributeDeleteOfContent = true;
            
            for (Account accObj : listOfAccount) {
                
                if (accObj.Reference_Basic_Informations__r.size() > 0) {
                    accRbi = new List<Reference_Basic_Information__c>();
                    mapContactIdRbi = new Map<String, Reference_Basic_Information__c>();                    
                    
                    for (Reference_Basic_Information__c rbi : accObj.Reference_Basic_Informations__r) {
                        
                        if (rbi.Contact__c != null) {
                            
                            if (mapContactIdRbi.containsKey(rbi.Contact__c)) {
                                rbisToDelete.add(rbi);
                            } else {
                                mapContactIdRbi.put(rbi.Contact__c, rbi);
                            }
                        } else {
                            accRbi.add(rbi);
                        }
                    }
                    accRbi.remove(0);
                    rbisToDelete.addAll(accRbi);
                }
                
                if (accObj.Account_Attributes__r.size() > 0) {
                    mapSetOfAccAttributesWithContent = new Map<String,Account_Attribute__c>();
                    mapSetOfAccAttributesWithCon = new Map<String,Account_Attribute__c>();
                    mapSetOfAccAttributes = new Map<String,Account_Attribute__c>(); 
                    
                    for (Account_Attribute__c accAttri : accObj.Account_Attributes__r) {
                        
                        if (accAttri.Contact__c != null) {
                            
                            if (mapSetOfAccAttributesWithCon.containsKey(accAttri.Attribute__c) && 
                                mapSetOfAccAttributesWithCon.get(accAttri.Attribute__c).Contact__c == accAttri.Contact__c) {
                                    accAttri.Reference_Content__c = null;
                                    accAttri.Contact__c = null;
                                    accAttri.Reference_Basic_Information__c = null;
                                    accAttrtoDelete.add(accAttri);
                                } else {
                                    mapSetOfAccAttributesWithCon.put(accAttri.Attribute__c, accAttri);
                                }
                        } else if (accAttri.Reference_Content__c != null) {
                            
                            if (mapSetOfAccAttributesWithContent.containsKey(accAttri.Attribute__c) && 
                                mapSetOfAccAttributesWithContent.get(accAttri.Attribute__c).Reference_Content__c == accAttri.Reference_Content__c) {
                                    accAttri.Reference_Basic_Information__c = null;
                                    accAttrtoDelete.add(accAttri);
                                } else {
                                    mapSetOfAccAttributesWithContent.put(accAttri.Attribute__c, accAttri);
                                }
                        } else {
                            
                            if (mapSetOfAccAttributes.containsKey(accAttri.Attribute__c)) {
                                accAttri.Reference_Basic_Information__c = null;
                                accAttrtoDelete.add(accAttri);
                            } else {
                                mapSetOfAccAttributes.put(accAttri.Attribute__c, accAttri);
                            }
                        }
                    }
                    
                }
                
                if (accObj.Referenceabilities__r.size() > 0) {
                    mapSetOfAccRefWithCon = new Map<String,Referenceability__c>();
                    mapSetOfAccRef = new Map<String,Referenceability__c>(); 
                    
                    for (Referenceability__c accRef : accObj.Referenceabilities__r) {
                        
                        if (accRef.Contact__c != null) {
                            
                            if (mapSetOfAccRefWithCon.containsKey(accRef.Referenceability_Type__c) && 
                                mapSetOfAccRefWithCon.get(accRef.Referenceability_Type__c).Contact__c == accRef.Contact__c) {
                                    accReftoDelete.add(accRef);
                                } else {
                                    mapSetOfAccRefWithCon.put(accRef.Referenceability_Type__c, accRef);
                                }
                        } else {
                            
                            if (mapSetOfAccRef.containsKey(accRef.Referenceability_Type__c)) {
                                accReftoDelete.add(accRef);
                            } else {
                                mapSetOfAccRef.put(accRef.Referenceability_Type__c, accRef);
                            }
                        }
                    }
                }
                
                if (accObj.Account_Reference_Contents__r.size() > 0) {
                    mapSetOfAccRefContent = new Map<String,Account_Reference_Content__c>(); 
                    
                    for (Account_Reference_Content__c accRefCont : accObj.Account_Reference_Contents__r) {
                        
                        if(mapSetOfAccRefContent.containsKey(accRefCont.Reference_Content__c)) {
                            accRefContoDelete.add(accRefCont);
                        } else {
                            mapSetOfAccRefContent.put(accRefCont.Reference_Content__c, accRefCont);
                        }
                    }                
                }
            }
        }
        
        Map<String,Contact_Attribute__c> mapSetOfConAttributes;
        Map<String,Contact_Reference_Content__c> mapSetOfConRefContent;
        Map<String, Referenceability__c> mapSetOfConRef;
        List<Contact_Attribute__c> conAttriToDelete = new List<Contact_Attribute__c>();
        List<Contact_Reference_Content__c> conRefConToDelete = new List<Contact_Reference_Content__c>();
        
        if (listOfContact.size() > 0) {
            
            for (Contact conObj : listOfContact) {
                
                if (conObj.Reference_Basic_Informations__r.size() > 0) {
                    accRbi = new List<Reference_Basic_Information__c>();
                    accRbi.addAll(conObj.Reference_Basic_Informations__r);           
                    accRbi.remove(0);
                    rbisToDelete.addAll(accRbi);
                }
                
                if (conObj.Contact_Attributes__r.size() > 0) {
                    mapSetOfConAttributes = new Map<String,Contact_Attribute__c>(); 
                    
                    for (Contact_Attribute__c conAttri : conObj.Contact_Attributes__r) {
                        
                        if (mapSetOfConAttributes.containsKey(conAttri.Attribute__c)) {
                            conAttri.Reference_Basic_Information__c = null;
                            conAttriToDelete.add(conAttri);
                        } else {
                            mapSetOfConAttributes.put(conAttri.Attribute__c, conAttri);
                        }
                    }
                }
                
                if (conObj.Referenceabilities__r.size() > 0) {
                    mapSetOfConRef = new Map<String,Referenceability__c>(); 
                    
                    for (Referenceability__c conRef : conObj.Referenceabilities__r) {
                        
                        if (mapSetOfConRef.containsKey(conRef.Referenceability_Type__c)) {
                            accReftoDelete.add(conRef);
                        } else {
                            mapSetOfConRef.put(conRef.Referenceability_Type__c, conRef);
                        }
                    }
                }
                
                if (conObj.Contact_Reference_Contents__r.size() > 0) {
                    mapSetOfConRefContent = new Map<String,Contact_Reference_Content__c>(); 
                    
                    for (Contact_Reference_Content__c conRefCont : conObj.Contact_Reference_Contents__r) {
                        
                        if(mapSetOfConRefContent.containsKey(conRefCont.Reference_Content__c)) {
                            conRefConToDelete.add(conRefCont);
                        } else {
                            mapSetOfConRefContent.put(conRefCont.Reference_Content__c, conRefCont);
                        }
                    }                
                }
            }
        }
        
        if (conRefConToDelete.size() > 0) {
            DELETE conRefConToDelete;
        }

        if (accRefContoDelete.size() > 0) {
            DELETE accRefContoDelete;
        }

        if (conAttriToDelete.size() > 0) {
            UPSERT conAttriToDelete;
            DELETE conAttriToDelete;
        }

        if (accAttrtoDelete.size() > 0) {
            UPSERT accAttrtoDelete;
            DELETE accAttrtoDelete;
        }

        if (accReftoDelete.size() > 0) {
            DELETE accReftoDelete;
        }
        
        if (rbisToDelete.size() > 0) {
            DELETE rbisToDelete;
        }
    }

    /**
     * REF-2079
     * Method to Update Update_Opportunity_Product_Attribute_Map__c
	 * And To check whether opportunity product attribute mapping is updated or not with Auto-Populate checkbox checked.
     * Modified By: Rajneesh Raj @ Jan 10,2019
     */
    Public void resetOpportunityProductAM() {
        
		List<Attribute_Mapping__c> updateAM = new List<Attribute_Mapping__c>();
		Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Attribute_Mapping__c', new Set<String> {  
        										UtilityController.appNamespace() + 'Auto_populate__c'}); 
        for(Attribute_Mapping__c am : [SELECT Id, Name, Auto_populate__c FROM Attribute_Mapping__c WHERE Auto_populate__c = false AND Object__c =: ConstantsController.OPPORTUNITY AND Related_Object__c =: ConstantsController.OPPORTUNITYLINEITEM AND Mapping_Type__c	= 'Child Object']) {
			am.Auto_populate__c = true;
			updateAM.add(am);
		}
		if(updateAM.size() > 0 && CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
			update updateAM;
		}
		POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
        appConfig.Update_Opportunity_Product_Attribute_Map__c = true;
                
        upsert appConfig;
        refresh();
    }

    /**
     * REF-2224
     * Method to restrict functionality of Opportunity Attribute creation on Account
	 * Skip Opportunity Attribute Mapping functionality from Opportunity trigger.
     * Created By: Rajneesh Raj @ April 10,2019
    */
    public void restrictOppAttributeCreation() {
        
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> {  
        										UtilityController.appNamespace() + 'Label__c'});
        //  Check Delete and Insert permission
        if(CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false) && CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Data_Mapping__c' })) {
            ConstantsController.shouldDataMappingProcessed = true;
            if(DMRecordList.size() > 0) {
                delete DMRecordList;
            } else {
                Data_Mapping__c dmRecord = new Data_Mapping__c();
                dmRecord.Name = ConstantsController.OPP_ATTRIBUTE;
                dmRecord.Label__c = ConstantsController.OPP_ATTRIBUTE;
                insert dmRecord;
            }
        }        
        refresh();
    }

    /*
     * REF-2289 Update Reference_Content which have 'null'(String) value in Content_URL field
     **/
    public void updateContentURL() {
        try {
            Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String>{
                            UtilityController.appNamespace() + 'Content_URL__c'});
            
            if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
                
                List<Reference_Content__c> listRefContent = new List<Reference_Content__c>();
                listRefContent = [SELECT Id, Content_URL__c FROM Reference_Content__c WHERE Content_URL__c = 'null'];
                
                if (listRefContent.size() > 0) {
                    
                    for (Reference_Content__c refCon : listRefContent) {
                        refCon.Content_URL__c = null;
                    }
                    update listRefContent;
                }
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }   
    }
}