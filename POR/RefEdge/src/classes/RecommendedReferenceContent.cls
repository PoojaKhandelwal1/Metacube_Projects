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
    * Page: RecommendedReferenceContent 
    * Description: Class used to handle Recommended Reference Content
    * Modified by: Rajesh @29 May 2017
*/
public with sharing class RecommendedReferenceContent extends RefEdgeEditionFeatures {
    /**
        * Properties and variables
    */
    public Opportunity opp { get; set; }
    public Integer noOfAccounts { get; set; }
    public Integer noOfContents { get; set; }
    public Boolean showAccountLink { get; set; }
    public Boolean showContentLink { get; set; }
    public Boolean isSLDS { get; set; }
    public Boolean isSF1 { get; set; }
    public Boolean isConsole { get; set; }
    public Boolean  isConfirmation { get; set; }
    public Boolean  isback { get; set; }
    public List<Data_Mapping__c> dataMapList ;
    //re #362 - Custom Setting decide default value for filters ( Any or All )
    public String searchFilterDefault { get; set; }
    public String stageChangeValue { get; set; }
    public Custom_Settings__c cs { get; set; }
    public Boolean isAccountAlert {get; set;}
    public Boolean isContentAlert {get; set;}
    //REF-1883
    public String minimumStageError { get; set; }
    
    /**
        * Constructor
    */
    public RecommendedReferenceContent(ApexPages.standardController controller) {
        opp = (Opportunity) controller.getRecord();
        minimumStageError = '';
        //  REF -1302
        dataMapList = New List<Data_Mapping__c>();
        isConfirmation = false;
        isAccountAlert = false;
        isContentAlert = false;
        isback = false;
        cs = UtilityController.getCustomSettings();
        String opportId = ApexPages.currentPage().getParameters().get('opportunityId');
        
        if (opportId != null && opportId != '') {
            isback = true;
            opp = [SELECT Id, Name, StageName, AccountId FROM Opportunity WHERE Id =: opportId];
        }
        noOfAccounts = 0;
        noOfContents = 0;
        
        if (UserInfo.getUiTheme() == 'Theme4d') {
            isSLDS = true;
            isSF1 = false;
            isConsole = false;
        } else if (UserInfo.getUiTheme() == 'Theme4t') {
            isSF1 = true;
            isSLDS = false;
            isConsole = false;
        } else if (UserInfo.getUiTheme() == 'Theme4u') {
            isSF1 = false;
            isSLDS = false;
            isConsole = true;
        } else {
            isSLDS = false;
            isSF1 = false;
        }
        mappedAndStageAttributeSearch();    

        //  REF - 1302
        if (cs != null && cs.Enable_Reference_Prompt__c && !isSLDS) {
            showHideConfirmationBox();
        }  

        //  REF-1883
        if (cs.Minimum_Sales_Stage__c != null && cs.Minimum_Sales_Stage__c != '') {
            Decimal minimumStageCount, opporunityStageCount, currentCount;
            List<Opportunity> opps = [SELECT StageName FROM Opportunity WHERE Id = : opp.Id];
            List<String> lstPickvals = new List<String>();
            Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity'); //From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get('StageName').getDescribe().getPickListValues();
            minimumStageCount = opporunityStageCount = currentCount = 0;
            
            for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            	
                if (cs.Minimum_Sales_Stage__c == a.getValue()) {
                    minimumStageCount = currentCount;
                }
                
                if (opps[0].StageName == a.getValue()) {
                    opporunityStageCount = currentCount;
                }
                ++currentCount;
            }
            
            if (opporunityStageCount < minimumStageCount) {
                minimumStageError = label.MinimumSalesStage.replace('@@@', cs.Minimum_Sales_Stage__c);
            }
        }     
    }
    
    /**
        *  REF - 1302
        *  Method to check whether to show confirmation box or not.
    */
    public void showHideConfirmationBox() {
        dataMapList = new List<Data_Mapping__c>([SELECT Id, Name, Label__c, Field_API_Name__c FROM Data_Mapping__c WHERE Field_API_Name__c =: opp.Id ORDER BY createddate DESC]);
        
        if (dataMapList.Size() > 0) {
            opp = [SELECT Id, Name, StageName, AccountId FROM Opportunity WHERE Id =: opp.Id];
            isConfirmation = true;
            stageChangeValue = dataMapList[0].Label__c;
        
            if (opp.StageName != null && opp.StageName != '') {
                
                if (cs.Show_Matching_Reference_Accounts_link__c && cs.Account_Stages__c != null && cs.Account_Stages__c != '' && noOfAccounts > 0 && cs.Account_Stages__c.contains(opp.StageName)) {
                    isAccountAlert = true;
                }
                
                if (cs.Show_Matching_Reference_Content_link__c && cs.Content_Stages__c != null && cs.Content_Stages__c != '' && noOfContents > 0 && cs.Content_Stages__c.contains(opp.StageName)) {
                     isContentAlert = true;                  
                }
            }
        }
    }
    
    /**
        *  REF - 1302
        *  Method is used to delete record from DataMapping.
    */
    public void deleteDataMappingRecord() {
        
        if (dataMapList.Size() > 0) {
            ConstantsController.shouldDataMappingProcessed = true;
            delete dataMapList;
        }
    }

    /**
        * Method to search Mapped attribute & Stage attribute
    */
    private void mappedAndStageAttributeSearch() {
      //  Custom_Settings__c cs = UtilityController.getCustomSettings();
        showAccountLink = cs.Show_Matching_Reference_Accounts_link__c;
        showContentLink = cs.Show_Matching_Reference_Content_link__c;
        Map<String, Schema.SObjectField> oppProductField_map = schema.SObjectType.OpportunityLineItem.fields.getMap();
        Map<String, Schema.SObjectField> fieldMap = schema.SObjectType.Opportunity.fields.getMap();
        String theQueryOpp = 'SELECT Id, AccountId';
        //re #362 - Custom Setting decide default value for filters (Any or All)
        searchFilterDefault = cs.RefSearch_Filters_Default__c ? 'And' : 'Or';
        
        for (String fieldName : fieldMap.keyset()) {
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query String
                theQueryOpp += ', ' + theName;
            }
        }
        theQueryOpp += ', (SELECT PricebookEntry.Product2Id ';
        
        for (String fieldName : oppProductField_map.keyset()) {
            Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
            
            if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                String theName = fieldDesc.getName();
                // Continue building your dynamic query String
                theQueryOpp += ', ' + theName;
            }
        }
        theQueryOpp += ' FROM OpportunityLineItems)  FROM Opportunity WHERE Id = \'' + opp.Id + '\' LIMIT 1';
        List<Opportunity> opportunity = Database.query(theQueryOpp);
        
        if (opportunity.size() > 0) {
            Opportunity oppObj = opportunity[0];
            //Get Data mapping reords
            Set<String> labelIds = new Set<String>();
            
            for (Data_Mapping__c dm : [SELECT Visible__c, Label__c, Program_Coverage__c, Ref_Search_Coverage__c, Field_API_Name__c FROM Data_Mapping__c 
                WHERE Object__c = 'SmartSearchFilter' AND Visible__c = true ORDER BY Label__c ]) {
                
                if (dm.Field_API_Name__c != null) {
                    labelIds.add(dm.Field_API_Name__c);
                }
            }
            
            //Get Accont field values
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT Id, Name';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQuery += ', ' + theName;
                }
            }
            theQuery += ' FROM Account WHERE Id = \'' + oppObj.AccountId + '\' LIMIT 1';
            Account account;        
            List<Account> accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL(theQuery);
            
            if (accounts.size() > 0) {
                account = accounts[0];
            } 
            
            Set<String> attMappingsAccount = new Set<String>();
            Map<String, String> accountFieldValues = new Map<String, String>();
            Map<String, String> oppFieldValues = new Map<String, String>();
            Set<String> oppoProducts = new Set<String>();
            Map<String, Set<String>> oppProductsPicklistFieldValues = new Map<String, Set<String>>();
            Map<String, String> oppProductFieldLabel = new Map<String, String>();
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            
            for (OpportunityLineItem oppLineItem : oppObj.OpportunityLineItems) {
                oppoProducts.add(oppLineItem.PricebookEntry.Product2Id);
                oppLineItems.add(oppLineItem);
            }
            //Get Attribute mapping & map of attributes
            Map<String, Set<String>> selectedLabelMap = new Map<String, Set<String>>();
            Map<String, String> labelMap = new Map<String, String>();
            
            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Id, Related_Object__c, Is_Related_Mapping__c, Filter_Label_Name__c, Field_Api_Name__c, 
                Field__c, Attribute_Name__c, Is_Related_MultiSelectPicklist__c FROM Attribute_Mapping__c 
                WHERE (Object__c = :ConstantsController.ACCOUNT OR Object__c = :ConstantsController.OPPORTUNITY)]) {
                
                if (!attMapping.Is_Related_Mapping__c) {
                    
                    if (attMapping.Object__c == ConstantsController.ACCOUNT) {
                        attMappingsAccount.add(attMapping.Id);
                        
                        if (account != null && fldObjMap.containsKey(attMapping.Field_Api_Name__c) && account.get(attMapping.Field_Api_Name__c) != null) {
                            accountFieldValues.put(attMapping.Attribute_Name__c, String.valueOf(account.get(attMapping.Field_Api_Name__c)));
                        }
                    } else if ((attMapping.Field_Api_Name__c == 'StageName' && cs.Apply_Opportunity_Stage_Filter__c 
                    && attMapping.Object__c == ConstantsController.OPPORTUNITY) || (attMapping.Field_Api_Name__c != 'StageName' 
                    && attMapping.Object__c == ConstantsController.OPPORTUNITY)) {
                        attMappingsAccount.add(attMapping.Id);
                        
                        if (fieldMap.containsKey(attMapping.Field_Api_Name__c) && oppObj.get(attMapping.Field_Api_Name__c) != null) {
                            oppFieldValues.put(attMapping.Attribute_Name__c, String.valueOf(oppObj.get(attMapping.Field_Api_Name__c)));
                        }
                    }
                    } else if (attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Related_Object__c == 'OpportunityLineItem') {
                    attMappingsAccount.add(attMapping.Id);
                    
                    if (oppProductField_map.containsKey(attMapping.Field_Api_Name__c)) {
                        oppProductFieldLabel.put(attMapping.Field_Api_Name__c, attMapping.Attribute_Name__c);
                        oppProductsPicklistFieldValues.put(attMapping.Attribute_Name__c, new Set<String>());
                    }
                }
            }
            
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                
                for (String oppProfield : oppProductFieldLabel.keySet()) {
                    
                    if (oppLineItem.get(oppProfield) != null) {
                        
                        if (String.valueOf(oppLineItem.get(oppProfield)).contains(';')) {
                            
                            for (String value : String.valueOf(oppLineItem.get(oppProfield)).split(';')) {
                                oppProductsPicklistFieldValues.get(oppProductFieldLabel.get(oppProfield)).add(value.trim());
                            }
                            } else {
                            oppProductsPicklistFieldValues.get(oppProductFieldLabel.get(oppProfield)).add(String.valueOf(oppLineItem.get(oppProfield)));
                        }
                    }
                }
            }
            List<Attribute__c> rootLevelAttributes;
            Set<Id> attSet = new Set<Id>();
            Map<String, Set<String>> oppAtts = new Map<String, Set<String>>();
            Set<Id> setAtt = new Set<Id>();
            
            //get prefilter attributes
            if (attMappingsAccount != null && attMappingsAccount.size() > 0) {
                rootLevelAttributes = [SELECT Level__c, Name, Attribute_Mapping__r.Object__c, Attribute_Mapping__r.Is_Related_Mapping__c, Attribute_Mapping__r.Field_Api_Name__c, 
                    (SELECT Id, Name, Level__c, Product_ID__c FROM Attributes__r WHERE Level__c = 1) FROM Attribute__c WHERE Level__c = 0 
                AND Attribute_Mapping__c IN :attMappingsAccount];
                Map<String, String> AttributeLabelMap = new Map<String, String>();
                Set<String> attIds = new Set<String>();
                Map<Id, Set<Id>> mapAtt = new Map<Id, Set<Id>>(); 
                
                for (Attribute__c att : rootLevelAttributes) {
                    
                    for (Attribute__c attr : att.Attributes__r) { 
                        attIds.add(attr.Id);
                        //break;
                    }
                } 
                
                for (Attributes_Labels__c attLabel : WithoutSharingHelperController.fetchAttributeLabels(attIds)) {
                    AttributeLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
                    labelMap.put(attLabel.Label__c, (attLabel.Label__r.Filter_no__c != null ? String.valueOf(attLabel.Label__r.Filter_no__c) : ''));
                    
                    //re #935 - Create map for atribute
                    if (!mapAtt.containsKey(attLabel.Label__c)) { 
                        mapAtt.put(attLabel.Label__c, new Set<Id>());
                    }
                    mapAtt.get(attLabel.Label__c).add(attLabel.Attribute__c);
                } 
                
                for (Attribute__c att : rootLevelAttributes) {
                    
                    if (labelIds.contains(AttributeLabelMap.get(att.Id)) && accountFieldValues.containsKey(att.Name) 
                    && att.Attribute_Mapping__r.Object__c == ConstantsController.ACCOUNT) { 
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(att.Id))) {  
                            selectedLabelMap.put(AttributeLabelMap.get(att.Id), new Set<String>());
                        }
                        
                        for (Attribute__c attr : att.Attributes__r) {
                            
                            if (accountFieldValues.get(att.Name) == attr.Name) {
                                
                                //re #935-Check for attribute mapping
                                if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {
                                    selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                }
                                attSet.add(attr.Id);
                                break;
                                
                                } else if (accountFieldValues.get(att.Name).contains(';')) {
                                
                                for (String value : accountFieldValues.get(att.Name).split(';')) {
                                    
                                    if (value.trim() == attr.Name) {
                                        
                                        //re #935-Check for attribute mapping
                                        if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {
                                            selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                        }
                                        attSet.add(attr.Id);
                                    }
                                }
                            }
                        }
                    } else if (labelIds.contains(AttributeLabelMap.get(att.Id)) && att.Attribute_Mapping__r.Object__c == ConstantsController.OPPORTUNITY 
                    && !att.Attribute_Mapping__r.Is_Related_Mapping__c) {
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(att.Id))) {
                            selectedLabelMap.put(AttributeLabelMap.get(att.Id), new Set<String>());
                        }
                        oppAtts.put(AttributeLabelMap.get(att.Id), new Set<String>());
                        
                        for (Attribute__c attr : att.Attributes__r) {
                            
                            if (oppFieldValues.get(att.Name) != null) {
                                
                                if (oppFieldValues.get(att.Name) == attr.Name) {
                                    
                                    if (att.Attribute_Mapping__r.Field_Api_Name__c == 'StageName') {
                                        oppAtts.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                        attSet.add(attr.Id);
                                        } else {
                                        
                                        //re #935-Check for attribute mapping
                                        if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {
                                            selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                        }
                                        attSet.add(attr.Id);
                                    }
                                    break;
                                    } else if (oppFieldValues.get(att.Name).contains(';')) {
                                    
                                    for (String value : oppFieldValues.get(att.Name).split(';')) {
                                        
                                        if (value.trim() == attr.Name) {
                                            
                                            //re #935-Check for attribute mapping
                                            if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {
                                                selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                            }
                                            attSet.add(attr.Id);
                                        }
                                    }
                                }
                            }
                        }
                    } else if (labelIds.contains(AttributeLabelMap.get(att.Id)) && att.Attribute_Mapping__r.Object__c == ConstantsController.OPPORTUNITY 
                    && att.Attribute_Mapping__r.Is_Related_Mapping__c) {
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(att.Id))) {
                            selectedLabelMap.put(AttributeLabelMap.get(att.Id), new Set<String>());
                        }
                        
                        if (att.Attribute_Mapping__r.Field_Api_Name__c == 'Product2') {
                            
                            for (Attribute__c attr : att.Attributes__r) {
                                
                                if (oppoProducts.contains(attr.Product_ID__c)) {
                                    
                                    //re #935-Check for attribute mapping
                                    if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {
                                        selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                    }
                                    attSet.add(attr.Id);
                                }
                            }
                            } else {
                            
                            for (Attribute__c attr : att.Attributes__r) {
                                
                                if (oppProductsPicklistFieldValues.containsKey(att.Name) && oppProductsPicklistFieldValues.get(att.Name) != null 
                                && oppProductsPicklistFieldValues.get(att.Name).contains(attr.Name)) {
                                    
                                    //re #935-Check for attribute mapping
                                    if (mapAtt.containsKey(AttributeLabelMap.get(att.Id)) && mapAtt.get(AttributeLabelMap.get(att.Id)).contains(attr.Id)) {      
                                        selectedLabelMap.get(AttributeLabelMap.get(att.Id)).add(attr.Id);
                                    }
                                    attSet.add(attr.Id);
                                }
                            }
                        }
                    }
                }
            }
            
            String labelClause = '';
            Set<String> setLabelIds = new Set<String>();
            
            for (String labelId : selectedLabelMap.keySet()) {
                
                if (selectedLabelMap.get(labelId).size() > 0) {
                    setLabelIds.add(labelId);
                    String labelNo = (labelMap.get(labelId) != '' ? 'F' + labelMap.get(labelId) + 'F' : '');
                    
                    if (labelClause == '') {
                        labelClause = ' (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
                        } else {
                        labelClause += ' AND (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
                    }
                }
            }
            
            if (labelClause != '') {
                labelClause = 'AND ( ' + labelClause + ' )';
            }
            //for Account search
            String dynamicSOQL = 'SELECT Account__c, Attribute_Ids__c FROM Reference_Basic_Information__c WHERE Referenceability_Status__c != \'' 
            + ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != null AND Contact__c = null AND Account__c != null ' 
            + labelClause + ' ORDER BY Account__r.Name';
            
            List<Reference_Basic_Information__c> rbiList = WithoutSharingHelperController.getRBI(dynamicSOQL);
            
            Map<String, Boolean> labelLogicMap = new Map<String, Boolean>();
            
            for (Reference_Basic_Information__c rbi : rbiList) {
                
                if (setLabelIds.size() > 0) { 
                    
                    if (rbi.Attribute_Ids__c != null && rbi.Attribute_Ids__c != '') {
                        Set<String> setAttribute = new Set<String>();
                        setAttribute.addAll(rbi.Attribute_Ids__c.split(','));
                        Integer selectedlabelCount = 0;
                        Integer recordMatchCount = 0;
                        
                        for (String labelId : setLabelIds) {
                            labelLogicMap.put(labelId, false);
                            selectedlabelCount++;
                            
                            //re #701 if advance filter has AND logic
                            if (searchFilterDefault == 'And') {
                                Boolean notMatched = false;
                                
                                for (String att : selectedLabelMap.get(labelId)) {
                                    
                                    if (!setAttribute.contains(att)) {
                                        notMatched = true;
                                        break;
                                    }
                                }
                                
                                if (!notMatched) {
                                    recordMatchCount ++;
                                    labelLogicMap.put(labelId, true);
                                }
                                } else {  // if advance filter has OR logic
                                
                                for (String att : selectedLabelMap.get(labelId)) {
                                    
                                    if (setAttribute.contains(att)) {
                                        recordMatchCount++;
                                        labelLogicMap.put(labelId, true);
                                        break;
                                    }  
                                }
                            }
                            
                        }
                        
                        if (selectedlabelCount != 0) {
                            Boolean checkResult = true;
                            
                            for (Boolean flag : labelLogicMap.values()) {
                                checkResult = (checkResult && flag);
                            }
                            
                            if (checkResult) {
                                noOfAccounts++;
                            }                           
                        }
                    }
                    } else {
                    noOfAccounts++;
                }
            }
            
            //for Content search
            Map<String, Set<String>> refContentAttributes = new Map<String, Set<String>>();
            
            if (attSet.size() > 0) {              
                
                for (Content_Attribute__c contAttr : WithoutSharingHelperController.getContentAttribute(attSet)) {  
                    
                    if (!refContentAttributes.containsKey(contAttr.Reference_Content__c)) {
                        refContentAttributes.put(contAttr.Reference_Content__c, new Set<String>());
                    }
                    refContentAttributes.get(contAttr.Reference_Content__c).add(contAttr.Attribute__c);
                }
                
                for (String labelId : oppAtts.keySet()) {
                    
                    if (oppAtts.get(labelId).size() > selectedLabelMap.get(labelId).size() || !selectedLabelMap.containsKey(labelId)) {
                        selectedLabelMap.put(labelId, oppAtts.get(labelId));
                    }
                    
                    if (oppAtts.get(labelId).size() > 0) {
                        setLabelIds.add(labelId);
                    }
                }
                
                for (String contentId : refContentAttributes.keySet()) {
                    Set<String> attIds = new Set<String>();
                    Integer recordMatchingCondition = 0;
                    
                    for (String labelId : setLabelIds) {
                        
                        if (selectedLabelMap.get(labelId).size() > 0) {
                            attIds.addAll(refContentAttributes.get(contentId));
                            
                            //re #701 if advance filter has AND logic
                            if (searchFilterDefault == 'And') {
                                Boolean notMatched = false;
                                
                                for (String attId : selectedLabelMap.get(labelId)) {
                                    
                                    if (!attIds.contains(attId)) {
                                        notMatched = true;
                                        break;
                                    }
                                }
                                
                                if (!notMatched) {
                                    ++recordMatchingCondition;
                                }
                                } else {
                                
                                for (String attId : selectedLabelMap.get(labelId)) {
                                    
                                    if (attIds.contains(attId)) {
                                        ++recordMatchingCondition;
                                        break;
                                    }
                                }
                            }
                            
                        }
                    }
                    
                    if (recordMatchingCondition != 0 && recordMatchingCondition == setLabelIds.size()) {
                        noOfContents++;
                        } else if (setLabelIds.size() == 0) {
                        noOfContents++;
                    }
                }
                } else {               
                List<Reference_Content__c> listOfrefContents = WithoutSharingHelperController.getRefContent();
                noOfContents = listOfrefContents.size();
            }
            
        }
    }
}