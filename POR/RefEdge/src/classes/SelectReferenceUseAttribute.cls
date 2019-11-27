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
 * VF Page: SelectReferenceUseAttribute.page
 * Description: controller for selecting attributes from reference request page
 * Last modified by: Nibin Babu (8 Aug, 2019) for REF-2366
 */
public with sharing class SelectReferenceUseAttribute {
    
    /**
     * Properties and variables
     */
    public Map<String, Boolean> mapRequiredLabel { get; set; }
    private List<Label__c> labels;
    public Map<String, List<AttributesLabelWrapper>> tempmapAttributesLabels;
    public String selectedLabelId { get; set; }
    public String selectedAttributeId { get; set; }
    private Set<Id> tempList;
    //REF-2366
    public Set<Id> refTypeIdsSet { get; set; }
    public String[] groupsIds;
    public Boolean isAdvRouting;
    public Boolean isP2PRequest;
    //  REF-2124
    public Boolean isHelpoverlay { get; set; }
    //REF-2366
    public  Map<String, List<AttributesLabelWrapper>> mapAllAttributesLabel { get; set; }
    public Map<String, Integer> mapAttibuteSize { get; set; }
    public Map<String, List<AttributesLabelWrapper>> mapAttributesLabels { get; set; }
    public String labelAttributesToBeSelected { get; set; }
    public String labelAttributesToBeSelectedFromAttributeResults { get; set; }
    public String selectedAttributeLabelsIdsFromAttributeResults { get; set; }
    public Map<String, List<AttributesLabelWrapper>> mapSelectedLabelAttributesFromAttributeResult { get; set; }
    //REF-2653
    public String mapPreviouslySelectedFilterAttributeString { get; set; }
    
    /**
     * Constructor
     */
    public SelectReferenceUseAttribute() {
        //REF-2653
        mapPreviouslySelectedFilterAttributeString = '';
        //REF-2366
        labelAttributesToBeSelected = '';
        labelAttributesToBeSelectedFromAttributeResults = '';
        selectedAttributeLabelsIdsFromAttributeResults = '';
        mapSelectedLabelAttributesFromAttributeResult = new Map<String, List<AttributesLabelWrapper>>();
        
        isAdvRouting = false;
        isP2PRequest = false;
        isHelpoverlay = false;
        // re #678 - Zendesk SBX - Attempt to de-reference a null object
        refTypeIdsSet = new Set<Id>();
        mapRequiredLabel = new Map<String, Boolean>();
        mapAttibuteSize = new Map<String, Integer>();
        tempmapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
        mapAllAttributesLabel = new Map<String, List<AttributesLabelWrapper>>();
        mapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
        tempList = new Set<Id>();
        labelWrapperMap = new Map<String, LabelWrapper>(); // for SF1
        setLabelAtrr();
        createMapAllAttributesLabel();
    }
    
    /**
     * Method to set label attributes
     */
    public void setLabelAtrr() {
        //mapAttributesLabels.clear();
        mapRequiredLabel.clear();
        
        for (Reference_Type_Mapping__c rtm : [SELECT Id, Name, Referenceability_Type__c, Label__c, Visible__c, Required__c
                                                FROM Reference_Type_Mapping__c
                                                WHERE Referenceability_Type__c IN :refTypeIdsSet
                                                AND (Visible__c = true OR Required__c = true)
                                                AND Label__c != null]) {
            
            if (!mapRequiredLabel.containsKey(rtm.Label__c)) {
                mapRequiredLabel.put(rtm.Label__c, false);
            }
            
            if (!mapRequiredLabel.get(rtm.Label__c) && rtm.Visible__c && rtm.Required__c) {
                mapRequiredLabel.put(rtm.Label__c, true);
            }
        }
        
        for (String lblId : mapRequiredLabel.keyset()) {
            
            if (!tempmapAttributesLabels.containsKey(lblId)) {
                tempmapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
            }
            
            //REF-2366
            if (!mapSelectedLabelAttributesFromAttributeResult.containsKey(lblId)) {
                mapSelectedLabelAttributesFromAttributeResult.put(lblId, new List<AttributesLabelWrapper>());
            }
        }
        
        if (groupsIds != null && isAdvRouting) { 
             
            for (Label__c lbl : [SELECT Id, Name, CreatedDate, Description__c, Required__c, Visible__c,
                                    Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                    FROM Label__c
                                    WHERE Show_in_P2P__c = true
                                    AND (Adv_Routing_Group__c IN :groupsIds OR Adv_Routing_Group__c = null)]) {
                
                if (!mapRequiredLabel.containsKey(lbl.Id)) {
                    mapRequiredLabel.put(lbl.Id, false);
                }
                
                if (!mapRequiredLabel.get(lbl.Id) && lbl.Show_in_P2P__c && lbl.Required_in_P2P__c) {
                    mapRequiredLabel.put(lbl.Id, true);
                }
            }
            
            for (String lblId : mapRequiredLabel.keyset()) {
                
                if (!tempmapAttributesLabels.containsKey(lblId)) {
                    tempmapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
                }
                
                //REF-2653
                if (!mapSelectedLabelAttributesFromAttributeResult.containsKey(lblId)) {
                    mapSelectedLabelAttributesFromAttributeResult.put(lblId, new List<AttributesLabelWrapper>());
                }
            }
        } else if (groupsIds == null && isAdvRouting && isP2PRequest) {
            
            for (Label__c lbl : [SELECT Id,  Name, CreatedDate, Description__c, Required__c, Visible__c,
                                    Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                    FROM Label__c
                                    WHERE (Adv_Routing_Group__c = null AND Show_in_P2P__c = true)]) {
                
                if (!mapRequiredLabel.containsKey(lbl.Id)) {
                    mapRequiredLabel.put(lbl.Id, false);
                }
                
                if (!mapRequiredLabel.get(lbl.Id) && lbl.Show_in_P2P__c && lbl.Required_in_P2P__c) {
                    mapRequiredLabel.put(lbl.Id, true);
                }
            }
            
            for (String lblId : mapRequiredLabel.keyset()) {
                
                if (!tempmapAttributesLabels.containsKey(lblId)) {
                    tempmapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
                }
                
                //REF-2653
                if (!mapSelectedLabelAttributesFromAttributeResult.containsKey(lblId)) {
                    mapSelectedLabelAttributesFromAttributeResult.put(lblId, new List<AttributesLabelWrapper>());
                }
            }
        }
    }
    
    /**
     * Method to create map of All Attribute labels REF-2366
     */
    private void createMapAllAttributesLabel() {
        mapAllAttributesLabel.clear();
        
        List<Label__c> tempListOfFilters = [SELECT Id, Name, 
                                            (SELECT Name, Label__c, Label__r.Name, Id, Attribute__c, Attribute__r.Name 
                                             FROM Attributes_Labels__r 
                                             WHERE Attribute__c != null 
                                             ORDER BY Attribute__r.Name 
                                             LIMIT 201) 
                                            FROM Label__c 
                                            WHERE Id IN :mapRequiredLabel.keyset()
                                            LIMIT :limits.getLimitQueryRows()];
        List<Attributes_Labels__c> tempListOfAttributeLabels = new List<Attributes_Labels__c>();
        
        for (Label__c label : tempListOfFilters) {
            
            if (label.Attributes_Labels__r.size() > 0) {
                tempListOfAttributeLabels.addAll(label.Attributes_Labels__r);
            }
        }
        
        for (Attributes_Labels__c al : tempListOfAttributeLabels) {
            
            if (!mapAllAttributesLabel.containsKey(al.Label__c)) {
                mapAllAttributesLabel.put(al.Label__c, new List<AttributesLabelWrapper>());
            }
            mapAllAttributesLabel.get(al.Label__c).add(new AttributesLabelWrapper(al));
        }
    }
    
    /**
     * get Attribute Labels Name for selected Label
     */
    public List<Label__c> getAttributeLabels() {
        setLabelAtrr();
        labels = [SELECT Id, Name FROM Label__c WHERE Id IN :mapRequiredLabel.keyset() ORDER BY Name];
        return labels;
    }
    
    /**
     * get All Attribute Name with Label REF-2366
     */
    
    public void getMapAllAttrributesLabel() {
        getAttributeLabels();  
        Boolean flag = false; 
        
        // Comment code for re #493/re #678
        if (mapAllAttributesLabel != null) {
            
            List<Label__c> tempListOfFilters = [SELECT Id, Name, 
                                                (SELECT Name, Label__c, Label__r.Name, Id, Attribute__c, Attribute__r.Name 
                                                 FROM Attributes_Labels__r 
                                                 WHERE Attribute__c != null 
                                                 ORDER BY Attribute__r.Name 
                                                 LIMIT 201) 
                                                FROM Label__c 
                                                WHERE Id IN :mapRequiredLabel.keyset()
                                                LIMIT :limits.getLimitQueryRows()];
            List<Attributes_Labels__c> tempListOfAttributeLabels = new List<Attributes_Labels__c>();
            
            for (Label__c label : tempListOfFilters) {
                
                if (label.Attributes_Labels__r.size() > 0) {
                    tempListOfAttributeLabels.addAll(label.Attributes_Labels__r);
                }
            }
            
            for (Attributes_Labels__c al : tempListOfAttributeLabels) {
                
                if (!mapAllAttributesLabel.containsKey(al.Label__c)) {
                    mapAllAttributesLabel.put(al.Label__c, new List<AttributesLabelWrapper>());
                }
                
                // changes for #436 - adding filters with no associated attributes to the map                     
                flag = false;
                
                for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(al.Label__c)) {
                    
                    if (alw.attributeLabel.Id == al.Id) {
                        flag = true;
                        break;
                    }
                }
                
                if (!flag) {
                    mapAllAttributesLabel.get(al.Label__c).add(new AttributesLabelWrapper(al));
                }
            }
            
        }
        
        for (Label__c label : labels) {
            
            if (!mapAllAttributesLabel.containsKey(label.Id)) {
                mapAllAttributesLabel.put(label.Id, new List<AttributesLabelWrapper>());
            }
        }
    }
    
    /**
     * get label & its Attribute size in map for the three column calculations REF-2366
     */
    public void getMapAttributeSize() {
        if (mapAllAttributesLabel != null) {
            
            for (String key : mapAllAttributesLabel.keySet()) {
                mapAttibuteSize.put(key, mapAllAttributesLabel.get(key).size());
            }
        }
    }
    
    /**
     * get map of label and list of its attributes REF-2366
     */
    
    public void getMapAttrributesLabels() {
        setLabelAtrr();
        
        for (String lblId : mapRequiredLabel.keyset()) {
            
            if (!mapAttributesLabels.containsKey(lblId)) {
                mapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
            }
        }
    }
    
    /**
     * Method to select AttributeTypes
     */
    public void setAttributes() {
        
        for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(selectedLabelId)) {
            
            if (alw.attributeLabel.Attribute__c == selectedAttributeId) {
                
                if (alw.fontWeight == ConstantsController.NORMAL) {
                    alw.fontWeight = ConstantsController.BOLD;
                    tempmapAttributesLabels.get(selectedLabelId).add(alw);
                    break;
                } else {
                    
                    for (Integer i = 0; i < tempmapAttributesLabels.get(selectedLabelId).size(); i++) {
                        
                        if (tempmapAttributesLabels.get(selectedLabelId)[i].attributeLabel.Attribute__c == alw.attributeLabel.Attribute__c) {
                            alw.fontWeight = ConstantsController.NORMAL;
                            tempmapAttributesLabels.get(selectedLabelId).remove(i);
                            break;
                        }
                    }
                }
            }
        }
    }
    
    /**
     * Method to redirect back to Reference Use Request Page
     */
    public Pagereference backToRequest() {
        
        for (String str : mapRequiredLabel.keyset()) {
            
            if (mapRequiredLabel.get(str) && tempmapAttributesLabels.get(str).size() < 1) {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, ConstantsController.ERROR_SELECT_REQUIRED_VALUE));
                return null;
            }
        }
        tempList.clear();
        
        for (String key : tempmapAttributesLabels.keySet()) {
            mapAttributesLabels.get(key).clear();
            mapAttributesLabels.get(key).addAll(tempmapAttributesLabels.get(key));
            
            for (AttributesLabelWrapper alw: tempmapAttributesLabels.get(key)) {
                tempList.add(alw.attributeLabel.Attribute__c);
            }
        }
        isHelpoverlay = true;
        return Page.ReferenceUseRequest;
    }
    
    /**
     * Method to redirect back to Reference Use Request Page on cancel
     */
    public Pagereference backToRequestOnCancel() {
        
        for (String key : mapAttributesLabels.keySet()) {
            tempmapAttributesLabels.get(key).clear();
            tempmapAttributesLabels.get(key).addAll(mapAttributesLabels.get(key));
            //REF-2653
            mapSelectedLabelAttributesFromAttributeResult.get(key).clear();
            mapSelectedLabelAttributesFromAttributeResult.get(key).addAll(mapAttributesLabels.get(key));
        }
        
        for (String key : mapAllAttributesLabel.keySet()) {
            
            for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(key)) {
                
                if (tempList.contains(alw.attributeLabel.Attribute__c)) {
                    alw.fontWeight = ConstantsController.BOLD;
                } else {
                    alw.fontWeight = ConstantsController.NORMAL;
                }
            }
        }
        isHelpoverlay = true;
        return Page.ReferenceUseRequest;
    }
    
    /**
     * Wrapper Class
     */
    public class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel { get; set; }
        public String fontWeight { get; set; }
        public Boolean isSelected { get; set; } //for SF1
        
        public AttributesLabelWrapper(Attributes_Labels__c attributeLabel) {
            fontWeight = ConstantsController.NORMAL;
            this.attributeLabel = attributeLabel;
            isSelected = false;
        }
    }
    
    public Map<String, LabelWrapper> labelWrapperMap {
        get {
            
            for (Label__c label : getAttributeLabels()) {
                
                if (!labelWrapperMap.containsKey(label.Id)) {
                    labelWrapperMap.put(label.Id, new LabelWrapper(label));
                }
            }
            return labelWrapperMap;
        }
        set;
    }
    
    /**
     * Method to redirect back to Reference Use Request Page on done in SF1
     */
    public Pagereference backToSF1ReferenceUseRequestOnDone() {
        LabelWrapper labelWrapperObj = labelWrapperMap.get(selectedLabelId);
        mapAttributesLabels.get(selectedLabelId).clear();
        Set<String> ids = new Set<String>();
        String attNames = '';
        
        for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(selectedLabelId)) {
            
            if (alw.isSelected) {
                mapAttributesLabels.get(selectedLabelId).add(alw);
                ids.add(alw.attributeLabel.Attribute__c);
                
                if (attNames == '') {
                    attNames = alw.attributeLabel.Attribute__r.Name;
                } else {
                    attNames += ', ' + alw.attributeLabel.Attribute__r.Name;
                }
            }
        }
        labelWrapperObj.selectedAttributes = attNames;
        labelWrapperObj.selectedAttIds = ids;
        return null;
    }
    
    /**
     * Wrapper Class
     */
    public class LabelWrapper {
        public Label__c label { get; set; }
        public String selectedAttributes { get; set; }
        public Set<String> selectedAttIds { get; set; }
        
        public LabelWrapper(Label__c label) {
            this.label = label;
            selectedAttIds = new Set<String>();
            selectedAttributes = '';
        }
    }
    
    //REF-2366 set already selected attributes
    public void setSelectedAttributes() {
        
        if (!String.isBlank(labelAttributesToBeSelected)) {
            Map<String,List<String>> mapSelectedLabelsAttributes = (Map<String,List<String>>)JSON.deserialize(labelAttributesToBeSelected, Map<String,List<String>>.class);
            
            for (String labelId : mapSelectedLabelsAttributes.keySet()) {
                
                if (mapAllAttributesLabel.containsKey(labelId)) {
                    
                    for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(labelId)) {
                        
                        if (mapSelectedLabelsAttributes.get(labelId).contains(alw.attributeLabel.Attribute__c)) {
                            alw.fontWeight = ConstantsController.BOLD;
                            
                            if (!tempmapAttributesLabels.containsKey(labelId)) {
                                tempmapAttributesLabels.put(labelId, new List<AttributesLabelWrapper>());
                            }
                            tempmapAttributesLabels.get(labelId).add(alw);
                        }
                    }
                }
            }
        }
        
        if (!String.isBlank(labelAttributesToBeSelectedFromAttributeResults) && !String.isBlank(selectedAttributeLabelsIdsFromAttributeResults)) {

            Map<String,List<String>> mapSelectedLabelsAttributes = (Map<String,List<String>>)JSON.deserialize(labelAttributesToBeSelectedFromAttributeResults, Map<String,List<String>>.class);
            Map<String,List<String>> mapSelectedLabelIdAttributeLabels = (Map<String,List<String>>)JSON.deserialize(selectedAttributeLabelsIdsFromAttributeResults, Map<String,List<String>>.class);
            List<String> listAttributeLabelIds = new List<String>();
            
            for(List<String> listOfString : mapSelectedLabelIdAttributeLabels.values()) {
                listAttributeLabelIds.addAll(listOfString);
            }
            List<Attributes_Labels__c> listAttributeLabels = [SELECT Id, Name, Label__c, Label__r.Name, Attribute__c, Attribute__r.Name
                                                              FROM Attributes_Labels__c
                                                              WHERE Id IN :listAttributeLabelIds];
            
            for (Attributes_Labels__c al :listAttributeLabels) {
                
                if (mapSelectedLabelsAttributes.containsKey(al.Label__c)) {
                    
                    if (!mapSelectedLabelAttributesFromAttributeResult.containsKey(al.Label__c)) {
                        mapSelectedLabelAttributesFromAttributeResult.put(al.Label__c, new List<AttributesLabelWrapper>());
                    }
                    AttributesLabelWrapper alw = new AttributesLabelWrapper(al);
                    alw.fontWeight = ConstantsController.BOLD;
                    mapSelectedLabelAttributesFromAttributeResult.get(al.Label__c).add(alw);
                    
                    if (!tempmapAttributesLabels.containsKey(al.Label__c)) {
                        tempmapAttributesLabels.put(al.Label__c, new List<AttributesLabelWrapper>());
                    }
                    tempmapAttributesLabels.get(al.Label__c).add(alw);
                }
            }
        }
    }
     
    //REF-2653
    public void setPreviouslySelectedAttributes() {
        Map<String,List<String>> mapFilterAttributes = new Map<String,List<String>>();
        Map<String,List<String>> mapFilterAttributesBulk = new Map<String,List<String>>();
        Map<String,List<String>> mapFilterAttributesLabelsBulk = new Map<String,List<String>>();
        Map<String, Map<String,List<String>>> result = new  Map<String, Map<String,List<String>>>();
        
        for (String labelId : mapAllAttributesLabel.keySet()) {
            
            if (mapAttibuteSize.containsKey(labelId)) { 
                
                if (mapAttibuteSize.get(labelId) > 200) {
                    
                    if (mapSelectedLabelAttributesFromAttributeResult.containsKey(labelId)) {
                        
                        for (AttributesLabelWrapper alw : mapSelectedLabelAttributesFromAttributeResult.get(labelId)) {
                            
                            if (alw.fontWeight == ConstantsController.BOLD) {
                                
                                if (!mapFilterAttributesBulk.containsKey(labelId)) {
                                    mapFilterAttributesBulk.put(labelId, new List<String>());
                                    mapFilterAttributesLabelsBulk.put(labelId, new List<String>());
                                }
                                mapFilterAttributesBulk.get(labelId).add(alw.attributeLabel.Attribute__c);
                                mapFilterAttributesLabelsBulk.get(labelId).add(alw.attributeLabel.Id);
                            }
                        }
                    }  
                } else {
                    if (mapAllAttributesLabel.containsKey(labelId)) {
                        
                        for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(labelId)) {
                            
                            if (alw.fontWeight == ConstantsController.BOLD) {
                                
                                if (!mapFilterAttributes.containsKey(labelId)) {
                                    mapFilterAttributes.put(labelId,new List<String>());
                                }
                                mapFilterAttributes.get(labelId).add(alw.attributeLabel.Attribute__c);
                            }
                        }
                    }
                }   
            }
        }
        result.put('filter', mapFilterAttributes.keySet().size() > 0 ? mapFilterAttributes : null);
        result.put('bulkFilter', mapFilterAttributesBulk.keySet().size() > 0 ? mapFilterAttributesBulk : null);
        result.put('bulkFilterAttributeLabel', mapFilterAttributesLabelsBulk.keySet().size() > 0 ? mapFilterAttributesLabelsBulk : null);
        
        mapPreviouslySelectedFilterAttributeString = '';
        mapPreviouslySelectedFilterAttributeString = JSON.serialize(result);
    }
}