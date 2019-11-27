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
 * Page: SelectReferenceLeadAttribute
 * Description: Class used to display attributes on reference lead form.
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing class SelectReferenceLeadAttributes extends RefEdgeEditionFeatures {
    /**
     * Properties AND variables
     */
    public Map<String, Boolean> mapRequiredLabel { get; set; }
    public List<Label__c> labels;
    public List<Label__c> allLabels;
    public Map<String, List<AttributesLabelWrapper>> tempmapAttributesLabels;
    public String selectedLabelId { get; set; }
    public String selectedAttributeId { get; set; }
    private Set<Id> tempList;
    public Set<Id> refTypeIdsSet;
    //changes regarding #570 
    public Map<String, List<AttributesLabelWrapper>> mapAllAttributesLabelforBoth;
    public Map<String, List<AttributesLabelWrapper>> mapAllAttributesLabel { get; set; }

    /**
     * Constructor
     */
    public SelectReferenceLeadAttributes() {
        mapRequiredLabel = new Map<String, Boolean>();
        mapAttibuteSize = new Map<String, Integer>();
        tempmapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
        tempList = new Set<Id>();
        labels = new List<Label__c>();
        allLabels = new List<Label__c>();
        Set<String> labelIds = new Set<String>();
        
        for (Data_Mapping__c dm : [SELECT filter__c, required__c, visible__c FROM
						                Data_Mapping__c WHERE Object__c = : ConstantsController.REFERENCE_LEAD
						                AND filter__c != null AND visible__c = true ]) {
						            	
            if (!mapRequiredLabel.containsKey(dm.filter__c)) {
                mapRequiredLabel.put(dm.filter__c, false);
            }
            
            if (!mapRequiredLabel.get(dm.filter__c) && dm.Visible__c && dm.Required__c) {
                mapRequiredLabel.put(dm.filter__c, true);
            }
        }
        
        for (Label__c label : [SELECT Id, Name, Ref_Limit_to_Acct_or_Cntct__c, 
        							(SELECT Id FROM Attributes_Labels__r) 
        							FROM Label__c WHERE Id IN :mapRequiredLabel.keySet()]) {
        	
            if (label.Attributes_Labels__r.size() == 0) {
                mapRequiredLabel.remove(label.Id);
            } else {
                //changes regarding #570 
                allLabels.add(label);
            }
        }

        for (String lblId : mapRequiredLabel.keyset()) {
        	
            if (!tempmapAttributesLabels.containsKey(lblId)) {
                tempmapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
            }
        }
        
        //changes regarding #570 
        Boolean flag = false;
        mapAllAttributesLabelforBoth = new Map<String, List<AttributesLabelWrapper>>();
        mapAllAttributesLabel = new Map<String, List<AttributesLabelWrapper>>();
        Map<Id, String> attribParentMap = new Map<Id, String>();
        Set<String> parentAttIds = new Set<String>();
        List<Attributes_Labels__c> attLables = [SELECT Name, Label__c, Id, Attribute__c, Attribute__r.Name,
    									Attribute__r.ParentIds__c FROM Attributes_Labels__c
    									WHERE Label__c IN :mapRequiredLabel.keyset()
    									AND Attribute__c != null
    									ORDER BY Attribute__r.Name
    									LIMIT :limits.getLimitQueryRows()];
        
        for (Attributes_Labels__c al : attLables) {
        	
        	if (al.Attribute__r.parentIds__c != null) {
                parentAttIds.addAll(al.Attribute__r.parentIds__c.split(','));
                attribParentMap.put(al.Attribute__c, al.Attribute__r.parentIds__c);
            }
        }
        
        for (Attribute__c att : [SELECT Id, Ref_Limit_to_Acct_or_Cntct__c, Level__c FROM Attribute__c WHERE Id IN :parentAttIds AND Level__c = 0]) {
        	
        	for (Id attId : attribParentMap.keySet()) {
        		
        		if (attribParentMap.get(attId) != null && attribParentMap.get(attId).contains(att.Id)) {
        			attribParentMap.put(attId, att.Ref_Limit_to_Acct_or_Cntct__c);
        		}
        	}
        }
        
        for (Attributes_Labels__c al : attLables) {
        	
            if (!mapAllAttributesLabelforBoth.containsKey(al.Label__c)) {
                mapAllAttributesLabelforBoth.put(al.Label__c, new List<AttributesLabelWrapper>());
            }
            flag = false;
            
            for (AttributesLabelWrapper alw : mapAllAttributesLabelforBoth.get(al.Label__c)) {
            	
                if (alw.attributeLabel.Id == al.Id) {
                    flag = true;
                    break;
                }
            }
            
            if (!flag) {
                mapAllAttributesLabelforBoth.get(al.Label__c).add(new AttributesLabelWrapper(al, attribParentMap.get(al.Attribute__c)));
            }
        }
    }

    /**
     * get Attribute Labels Name for selected Label
     */
    public List<Label__c> getAttributeLabels() {
        return labels;
    } 

    /**
     * get label & its Attribute size in map for the three column calculations
     */
    public Map<String, Integer> mapAttibuteSize {
        get {
        	
            if (mapAllAttributesLabel != null) {
            	
                for (String key : mapAllAttributesLabel.keySet()) {
                    mapAttibuteSize.put(key, mapAllAttributesLabel.get(key).size());
                }
            }
            return mapAttibuteSize;
        }
        set;
    }
    /**
     * get map of label AND list of its attributes
     */
    public Map<String, List<AttributesLabelWrapper>> mapAttributesLabels {
        get {
        	
            if (mapAttributesLabels == null) {
                mapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
                
                for (String lblId: mapRequiredLabel.keyset()) {
                	
                    if (!mapAttributesLabels.containsKey(lblId)) {
                        mapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
                    }
                }
            }
            return mapAttributesLabels;
        }
        set;
    }

    /**
     * Method to SELECT AttributeTypes
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
     * Method to redirect back to Reference Lead Form
     */
    public Pagereference backToReferenceLeadForm() {
    	//changes regarding #833
        Set<Id> labelIds = new Set<Id>();
        
        for (Label__c label : labels) {
        	labelIds.add(label.Id);
        }
    	
        for (String str : mapRequiredLabel.keyset()) {
        	
            if (mapRequiredLabel.get(str) && tempmapAttributesLabels.get(str).size() < 1 && labelIds.contains(str)) {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, ConstantsController.ERROR_SELECT_REQUIRED_VALUE));
                return null;
            }
        }
        tempList.clear();
        
        for (String key : tempmapAttributesLabels.keySet()) {
            mapAttributesLabels.get(key).clear();
            mapAttributesLabels.get(key).addAll(tempmapAttributesLabels.get(key));
            
            for (AttributesLabelWrapper alw : tempmapAttributesLabels.get(key)) {
                tempList.add(alw.attributeLabel.Attribute__c);
            }
        }
        return Page.ReferenceLeadForm;
    }
    
    /**
     * Method to redirect back to Reference Lead Form on cancel
     */
    public Pagereference backToReferenceLeadFormOnCancel() {
    	
        for (String key : mapAttributesLabels.keySet()) {
            tempmapAttributesLabels.get(key).clear();
            tempmapAttributesLabels.get(key).addAll(mapAttributesLabels.get(key));
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
        return Page.ReferenceLeadForm;
    }
    
    /**
     * Wrapper Class
     */
    public class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel { get; set; }
        public String fontWeight { get; set; }
        public Boolean isSelected { get; set; } //for SF1
        public Boolean isForAccount { get; set; }
        public Boolean isForContact { get; set; }
        
        public AttributesLabelWrapper(Attributes_Labels__c attributeLabel, String limitAccCon) {
            fontWeight = ConstantsController.NORMAL;
            this.attributeLabel = attributeLabel;
            isSelected = false; //for SF1
            this.isForAccount = (limitAccCon == null || limitAccCon == '' || limitAccCon == 'Account' ? true : false);
            this.isForContact = (limitAccCon == null || limitAccCon == '' || limitAccCon == 'Contact' ? true : false);
        }
    }
}