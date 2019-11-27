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
    * Page: DataCollectorManagePage
    * Description: Class used to handle DataCollectorForm creation and message content to those Form
    * Modified by: Rajneesh @June 05/2018
*/
public with sharing class DataCollectorManagePageController {
    
    /**
        * Properties and variables
    */ 
    private String customSettingId;
    public Boolean isEdit { get; set; }
    private List<Data_Mapping__c> dmList;    
    public Data_Mapping__c dmRecord { get; set; }
    public String dmRecordId { get; set; }
    public String preview { get; set; }
    public Boolean isPreview { get; set; }
    public Boolean isSLDS { get; set; }
    public List<DMWrapperClass> wrapList { get; set; }
    public String editPreviewForm { get; set; }
    // REF-1935
    Public String errorMsg { get; set; }
    
    //    Constructor
    public DataCollectorManagePageController() {
        wrapList = new List<DMWrapperClass>();
        
        //    Check theme(Lightning or classic)
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
            } else { 
            isSLDS = false;
        }
        
        dmRecordId = '';
        isEdit = true;
        isPreview = false;
        dmList = new List<Data_Mapping__c>();
        dmRecord = new Data_Mapping__c();
        
        customSettingId = ApexPages.currentPage().getParameters().get('customSettingId') != null
        ? ApexPages.currentPage().getParameters().get('customSettingId') : '';       
        dmList = [SELECT Field_API_Name__c, Label__c, DC_Message__c, Section_Name__c, Data_Collector_Name__c FROM Data_Mapping__c
            WHERE Data_Collector_Name__c !='' AND Order__c = null AND Section_Position__c = null AND
        Section_Name__c !=: ConstantsController.DC_FORM_IDENTIFY AND Object__c = null ORDER BY Label__c];
        Map<String, List<Data_Mapping__c>> dmMap = new Map<String, List<Data_Mapping__c>>();
        
        if(dmList.size() > 0) {
            
            for(Data_Mapping__c dm : dmList) {
                
                if(!dmMap.containsKey(dm.Data_Collector_Name__c))
                dmMap.put(dm.Data_Collector_Name__c, new List<Data_Mapping__c>());
                dmMap.get(dm.Data_Collector_Name__c).add(dm);
            }
            
            if(dmMap.size() > 0) {
                
                for(String dm : dmMap.keySet()) {
                    wrapList.add(new DMWrapperClass(dm, dmMap.get(dm)));
                }
            }
            
            } else {
            isEdit = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, label.No_DataCollectoer_Form));            
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
        * Method to redirect to DataCollectorCustomPage
    */
    public pageReference redirectFormPage() {
        PageReference redirectPage = new PageReference(Page.DataCollectorCustomPage.geturl() + '?customSettingId=' + customSettingId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    /**
        * Method to redirect to View / Edit Form
    */
    public pageReference editAndViewPageRedirect() {
        
        String linkUrl = '';  
        
        if (editPreviewForm == 'Edit' && customSettingId != null && customSettingId != '' && dmRecordId != null && dmRecordId != '') {
            
            linkUrl = Page.DataCollectorCustomPage.geturl() + '?customFormId=' + dmRecordId+ '?&customSettingId=' + customSettingId;
        } else {
            
            if (isSLDS && customSettingId != null && customSettingId != '' && dmRecordId != null && dmRecordId != '') {
                
                linkUrl = Page.DataCollectorPageSLDS.geturl() + '?customFormId=' + dmRecordId+ '?&customSettingId=' + customSettingId;
            } else {
                
                if (customSettingId != null && customSettingId != '' && dmRecordId != null && dmRecordId != '') {
                    
                    linkUrl = Page.datacollectorpage.geturl() + '?customFormId=' + dmRecordId+ '?&customSettingId=' + customSettingId;  
                }
            }            
        }

        if (linkUrl != null && linkUrl != '') {
            
            PageReference redirectPage = new PageReference(linkUrl);
            redirectPage.setRedirect(true);
            return redirectPage;  
        } else {
            return null;
        }  
    }
    
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }    
     
    public void showPopup() {  
        
        if(preview == 'Preview') {
            displayPopup = true; 
            isPreview = true;
            } else{
            
            if(checkPermissions()) {
                displayPopup = true; 
                isPreview = false;
            }            
        }
        dmRecord = [SELECT Field_API_Name__c, Label__c, DC_Message__c, Section_Name__c, Data_Collector_Name__c FROM Data_Mapping__c WHERE Id =: dmRecordId];     
    }
    
    // Save  record
    public void save() {
        displayPopup = false; 
        ConstantsController.shouldDataMappingProcessed = true;
        update dmRecord;
    }
    
    /**
        *   REF-1935
        *   Method will check whether Form is in Use or not before Deletion.
        *   Rajneesh (Sept 20,2018)
    */
    public void deleteForm() {

        //  Check permission to Delete Data_Mapping__c record
        if(CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'})) {
            List<Data_Mapping__c> dmListToDelete = New List<Data_Mapping__c>();
            String dcName = [SELECT Id, Data_Collector_Name__c From Data_Mapping__c WHERE Id =: dmRecordId].Data_Collector_Name__c;
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            errorMsg = '';

            if(cs.Enable_Data_Collector__c && cs.Data_Collector_Name__c == dcName) {
                errorMsg = (wrapList.size() > 1) ? Label.Warning_For_More_Than_One_DC : Label.Warning_For_Single_DC;           
            } else {
                Integer countVal = 0;
                for(DMWrapperClass dmWrap : wrapList) {
                    
                    if(dmWrap.formName != dcName) {
                        countVal++;
                    } else {                    
                        break;
                    }
                }

            dmListToDelete = wrapList.get(countVal).dmRecordList;

            if(dmListToDelete.size() > 0) {
                wrapList.remove(countVal);
                ConstantsController.shouldDataMappingProcessed = true;        
                Delete dmListToDelete;
                }
            
            }        
        }
    }

    /**
        * Method to check Permissions for Data Mapping
    */
    public static Boolean checkPermissions() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String>{ 
            UtilityController.appNamespace() + 'Field_API_Name__c',
            UtilityController.appNamespace() + 'Label__c',
            UtilityController.appNamespace() + 'Section_Name__c',
            UtilityController.appNamespace() + 'DC_Message__c',
            UtilityController.appNamespace() + 'Data_Collector_Name__c' });
        
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
    }
    
    /*
        *    Wrapper Of DM Record to set in format
    */
    Public class DMWrapperClass{
        
        public String formName { get; set; }
        public List<Data_Mapping__c> dmRecordList { get; set; }
        
        public DMWrapperClass(String fName, List<Data_Mapping__c> dmList) {
            formName = fName;
            dmRecordList = dmList;
        }
    }
}