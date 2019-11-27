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
* VF Page: HelpAssistantSetting.page
* Description: Class to manage customization of Help overlay text.
* Created By: Dixita Aug 2018 - #1861
*/
public with sharing class HelpAssistantSetting extends RefEdgeEditionFeatures {

    /** 
     * Properties and variables 
     */
    public String namespace {
        get {
            return UtilityController.appNamespace();
        }
        set;
    } 

    public static Boolean isSLDS {
        get {
            if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
                isSLDS = true;       
            } else {
                isSLDS = false;   
            }
            return isSLDS;
        }
        set {}
    }

    /**
     * RemoteAction used to get Page List
     */
    @RemoteAction
    public static String getData() {
        Map<String,List<Data_Mapping__c>> helpListClassic = new Map<String,List<Data_Mapping__c>>();
        Map<String,List<Data_Mapping__c>> helpListLightning = new Map<String,List<Data_Mapping__c>>();
        List<Object> returnList = new List<Object>();
        List<PageWrapper> pageList = new List<PageWrapper>();
        pageList.add(new PageWrapper('Reference Search',UtilityController.appNamespace() + 'RfSearchPage',UtilityController.appNamespace() + 'RfSearchLightning'));
        pageList.add(new PageWrapper('Invitations',UtilityController.appNamespace() + 'Invitation_New',UtilityController.appNamespace() + 'Invitation_NewSLDS'));
        pageList.add(new PageWrapper('Reference Request',UtilityController.appNamespace() + 'ReferenceUseRequest',UtilityController.appNamespace() + 'ReferenceUseRequestSLDS'));
        pageList.add(new PageWrapper('Profile Update Minder','',UtilityController.appNamespace() + 'ReferenceRefreshPageSLDS'));
        
        List<String> pageName = new List<String>();
        pageName.add(UtilityController.appNamespace() + 'RfSearchPage');
        pageName.add(UtilityController.appNamespace() + 'RfSearchLightning');
        pageName.add(UtilityController.appNamespace() + 'Invitation_New');
        pageName.add(UtilityController.appNamespace() + 'Invitation_NewSLDS');
        pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequest');
        pageName.add(UtilityController.appNamespace() + 'ReferenceUseRequestSLDS');
        pageName.add(UtilityController.appNamespace() + 'ReferenceRefreshPageSLDS');

        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(pageName)) {

            if (dm.Visible__c) {//classic

                if (!helpListClassic.containsKey(dm.Field_API_Name__c)) {
                    helpListClassic.put(dm.Field_API_Name__c , new List<Data_Mapping__c>());
                }
                helpListClassic.get(dm.Field_API_Name__c).add(dm);
            } else {
                if (!helpListLightning.containsKey(dm.Field_API_Name__c)) {
                    helpListLightning.put(dm.Field_API_Name__c , new List<Data_Mapping__c>());
                }
                helpListLightning.get(dm.Field_API_Name__c).add(dm);
            }
        }
        returnList.add(JSON.serialize(pageList));
        returnList.add(JSON.serialize(helpListLightning));
        returnList.add(JSON.serialize(helpListClassic)); 
        returnList.add(JSON.serialize(UtilityController.getCustomSettings()));
        return JSON.serialize(returnList);
    }

    /*
     * RemoteAction to Save Edited Entry 
    */
    @RemoteAction
    public static String saveEdit(String currentSelectString) {
        if (currentSelectString != null && currentSelectString != '') {
            Data_Mapping__c dm = (Data_Mapping__c) JSON.deserialize(currentSelectString, Data_Mapping__c.class);
            ConstantsController.shouldDataMappingProcessed = true;
            update dm; 
        } 
        return null;
    }
    /**
     * Wrapper class
    */
    public class PageWrapper {
        public String header {get;set;}
        public String lightningPage {get;set;}
        public String classicPage {get;set;}
        public Boolean show {get;set;}
        public PageWrapper(String header, String classicPage, String lightningPage) {
            this.header = header;
            this.classicPage = classicPage;
            this.lightningPage = lightningPage;
            show = true;
        }
    }
}