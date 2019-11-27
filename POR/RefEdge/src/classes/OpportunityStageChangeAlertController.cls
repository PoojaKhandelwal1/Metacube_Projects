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
    * Page: OpportunityStageChangeAlertPage 
    * Description: Class used to handle Confirmation alert on stage change of Opportunity
    * Created by: Rajneesh @12 Feb 2018
*/
public with sharing class OpportunityStageChangeAlertController extends RefEdgeEditionFeatures {

    /**
     * Properties and variables
     */
    public Boolean isEdit { get; set; }
    public Custom_Settings__c cs { get; set; }
    public String currentAccountStage { get; set; }
    public List<SelectOption> allAccountStage { get; set; }
    public String currentSelectedAccountStage { get; set; }
    public List<SelectOption> selectedAccountStage { get; set; }
    public String currentContentStage { get; set; }
    public List<SelectOption> allContentStage { get; set; }
    public String currentSelectedContentStage { get; set; }
    public List<SelectOption> selectedContentStage { get; set; }
    public Boolean isAccount { get; set; }
    public Boolean isSLDS { get; set; }
    
    /**
     * Constructor :  OpportunityStageChangeAlertPage 
     */
    public OpportunityStageChangeAlertController(ApexPages.StandardController controller) {
        cs = UtilityController.getCustomSettings();
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        isEdit = false;
        getData();
    }
    
    /**
     * Method used to get record
     */
     public void getData() {
        allAccountStage = new List<SelectOption>();
        selectedAccountStage = new List<SelectOption>();
        allContentStage = new List<SelectOption>();
        selectedContentStage = new List<SelectOption>();
        // To get opportunity stage picklist options
        Schema.DescribeFieldResult fieldResult = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry s : ple) {

            if (cs.Account_Stages__c != null && cs.Account_Stages__c != '') {

                if (!cs.Account_Stages__c.contains(s.getLabel())) {
                    allAccountStage.add(new SelectOption(s.getLabel(), s.getLabel()));
                }
            } else {
                allAccountStage.add(new SelectOption(s.getLabel(), s.getLabel())); 
            }
            
            if (cs.Content_Stages__c != null && cs.Content_Stages__c != '') {

                if (!cs.Content_Stages__c.contains(s.getLabel())) {
                    allContentStage.add(new SelectOption(s.getLabel(), s.getLabel()));
                }
            } else {
                 allContentStage.add(new SelectOption(s.getLabel(), s.getLabel())); 
            }                     
        } 

        if (cs.Account_Stages__c != null && cs.Account_Stages__c != '') {
            
            for (String obj : cs.Account_Stages__c.split(',')) {
                selectedAccountStage.add(new SelectOption(obj, obj));                               
            }
        }

        if(cs.Content_Stages__c != null && cs.Content_Stages__c != '') {
            
            for(String obj : cs.Content_Stages__c.split(',')) {
                selectedContentStage.add(new SelectOption(obj, obj));               
            }
        }
     }

    /**
     * Method used to edit fields on the form :  OpportunityStageChangeAlertPage
     */
    public PageReference editForm() {
        
        if (checkPermissions()) {
            isEdit = true;          
        }
        return null;
    }
    
    /**
     * Method used cancel :  OpportunityStageChangeAlertPage
     */
    public PageReference cancelForm() {
        cs = UtilityController.getCustomSettings();
        isEdit = false;
        getData();
        return null;
    }

    /**
     * Method used to save fields on the form 
     */
    public PageReference saveForm() {
        
        if (checkPermissions()) {
            Savepoint sp = Database.setSavepoint();
            
            try {
                cs.Account_Stages__c = '';
                cs.Content_Stages__c = '';

                for (SelectOption val : selectedAccountStage) {
                    cs.Account_Stages__c = cs.Account_Stages__c + val.getValue() + ',' ;               
                }
                cs.Account_Stages__c = cs.Account_Stages__c.removeEnd(',');

                for (SelectOption val : selectedContentStage) {
                    cs.Content_Stages__c = cs.Content_Stages__c + val.getValue() + ',' ;               
                }
                cs.Content_Stages__c = cs.Content_Stages__c.removeEnd(',');            
                upsert cs;
                isEdit = false;           
            } catch(Exception ex) {
                Apexpages.addMessages(ex);
                Database.rollback(sp);
            }
        }
        return Null;
    }
    
    /**
     * Method used to update the select Lists
     */
    public void addToList() {

        if (isAccount) {

            if (currentAccountStage != null && currentAccountStage != '') {
                currentAccountStage = currentAccountStage.replace('[', '').replace(']', '');
                String[] listofGroups = currentAccountStage.split(',');   
            
                if (listofGroups.size() > 0 && currentAccountStage != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        selectedAccountStage.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                        
                        for (integer j = 0; j < allAccountStage.size(); j++) {
                            
                            if (allAccountStage[j].getValue().trim() == listofGroups[i].trim()) {
                                allAccountStage.remove(j);
                            }
                        }
                    }
                }
            }
        } else {

            if (currentContentStage != null && currentContentStage != '') {
                currentContentStage = currentContentStage.replace('[', '').replace(']', '');
                String[] listofGroups = currentContentStage.split(',');   
            
                if (listofGroups.size() > 0 && currentContentStage != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        selectedContentStage.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                        
                        for (integer j = 0; j < allContentStage.size(); j++) {
                            
                            if (allContentStage[j].getValue().trim() == listofGroups[i].trim()) {
                                allContentStage.remove(j);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Method used to update the object Lists : DMInline
     */
    public void removeFromList() {
        
        if (isAccount) {
            
            if (currentSelectedAccountStage != null && currentSelectedAccountStage != '') {
                currentSelectedAccountStage = currentSelectedAccountStage.replace('[',  '').replace(']',  '');
                String[] listofGroups = currentSelectedAccountStage.split(',');   
            
                if (listofGroups.size() > 0 && currentSelectedAccountStage != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        allAccountStage.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                        
                        for (integer j = 0; j < selectedAccountStage.size(); j++) {
                            
                            if (selectedAccountStage[j].getValue().trim() == listofGroups[i].trim()) {
                                selectedAccountStage.remove(j);
                            }
                        }
                    }
                }
            }
        } else {

            if (currentSelectedContentStage != null && currentSelectedContentStage != '') {
                currentSelectedContentStage = currentSelectedContentStage.replace('[',  '').replace(']',  '');
                String[] listofGroups = currentSelectedContentStage.split(',');   
            
                if (listofGroups.size() > 0 && currentSelectedContentStage != '') {
                    
                    for (Integer i = 0; i < listofGroups.size(); i++) {
                        allContentStage.add(new SelectOption(listofGroups[i].trim(), listofGroups[i].trim()));
                        
                        for (integer j = 0; j < selectedContentStage.size(); j++) {
                            
                            if (selectedContentStage[j].getValue().trim() == listofGroups[i].trim()) {
                                selectedContentStage.remove(j);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        Boolean isUpsertPermission = false;
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> {
                                                UtilityController.appNamespace() + 'Enable_Reference_Prompt__c',
                                                UtilityController.appNamespace() + 'Show_Matching_Reference_Accounts_link__c',
                                                UtilityController.appNamespace() + 'Show_Matching_Reference_Content_link__c',
                                                UtilityController.appNamespace() + 'Account_Stages__c',
                                                UtilityController.appNamespace() + 'Prompt_Message__c',
                                                UtilityController.appNamespace() + 'Content_Stages__c'});
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        return isUpsertPermission;
    }
}