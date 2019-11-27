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
 * VF Page: SelectProjectUseAttribute.page
 * Description: controller for selecting attributes from new project page
 * Last modified by: Gaurav Saini (15 June, 2017) for #732
 */
public with sharing class SelectProjectUseAttribute extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Map<String, Boolean> mapRequiredLabel { get; set; }
    private List<Label__c> labels;
    public Map<String, List<AttributesLabelWrapper>> tempmapAttributesLabels;
    public String selectedLabelId { get; set; }
    public String selectedAttributeId { get; set; }
    public Set<Id> tempList;
    private Id refReqId;
    public String[] groupsIds;
    public Boolean isAdvRouting;
    public Boolean isP2PRequest;
    
    /**
     * Constructor 
     */
	public SelectProjectUseAttribute(Set<Id> referIds, Set<Id> refLabelIds, Set<Id> refAttribIds, Id refRequestId,
   										Boolean isAdvRout, String[] groupsIds, Boolean isP2PRequest) {  
		mapRequiredLabel = new Map<String, Boolean>();
        mapAttibuteSize = new Map<String, Integer>();
        groupsIds=groupsIds;
        isAdvRouting=isAdvRout;
        refReqId = refRequestId;
        this.isP2PRequest = isP2PRequest;
        mapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
        tempmapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
        tempList = new Set<Id>();
        
        for (Reference_Type_Mapping__c rtm : [SELECT Id, Name, Referenceability_Type__c, Label__c, Visible__c, Required__c
        										FROM Reference_Type_Mapping__c
        										WHERE Referenceability_Type__c IN :referIds
        										AND (Visible__c = true OR Required__c = true)
        										AND Label__c != null]) {
        	
            if (!mapRequiredLabel.containsKey(rtm.Label__c)) {
                mapRequiredLabel.put(rtm.Label__c, false);
            }
            
            if (!mapRequiredLabel.get(rtm.Label__c) && rtm.Visible__c && rtm.Required__c) {
                mapRequiredLabel.put(rtm.Label__c, true);
            }
        }
        
        for (Id labelId : refLabelIds) {
            if (!mapRequiredLabel.containsKey(labelId)) {
                mapRequiredLabel.put(labelId, false);
            }
        }
        
        for (String lblId : mapRequiredLabel.keyset()) {
        	
            if (!tempmapAttributesLabels.containsKey(lblId)) {
                tempmapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
            }
        }
        
        if (groupsIds != null && isP2PRequest && isAdvRouting) { 
			
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
	        }
        } else if (groupsIds == null && isAdvRouting) {
        	
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
	        }
        }
		
        for (Attributes_Labels__c al : [SELECT Name, Label__c, Id, Attribute__c, Label__r.Filter_no__c, Attribute__r.Name
        									FROM Attributes_Labels__c
        									WHERE Label__c IN :mapRequiredLabel.keyset()
        									AND Attribute__c IN :refAttribIds
        									ORDER BY Attribute__r.Name
        									LIMIT :limits.getLimitQueryRows()]) {
        	
            if (!mapAttributesLabels.containsKey(al.Label__c)) {
                mapAttributesLabels.put(al.Label__c, new List<AttributesLabelWrapper>());
            }
            mapAttributesLabels.get(al.Label__c).add(new AttributesLabelWrapper(al, ConstantsController.NORMAL));
            
            if (tempmapAttributesLabels.get(al.Label__c) != null) {
                tempmapAttributesLabels.get(al.Label__c).add(new AttributesLabelWrapper(al, ConstantsController.NORMAL));
            }
        }
        
        for (String labelKey : mapRequiredLabel.keyset()) {
        	
            if (!mapAttributesLabels.containsKey(labelKey)) {
                mapAttributesLabels.put(labelKey, new List<AttributesLabelWrapper>());
            }
        }
    }
    
    /**
     * get Attribute Labels Name for selected Label
     */
    public List<Label__c> getAttributeLabels() {
        
        if (labels == null) {
            labels = [SELECT Id, name FROM Label__c WHERE Id IN :mapRequiredLabel.keyset() ORDER BY Name];
        }
        return labels;
    }
    
    /**
     * get All Attribute Name with Label
     */
    public Map<String, List<AttributesLabelWrapper>> mapAllAttributesLabel {
        get {
            Boolean attExists = false;
            
            if (mapAllAttributesLabel == null) {
                mapAllAttributesLabel = new Map<String, List<AttributesLabelWrapper>>();
                
                for (Attributes_Labels__c al : [SELECT Name, Label__c, Id, Attribute__c, Label__r.Filter_no__c, Attribute__r.Name
            									FROM Attributes_Labels__c
            									WHERE Label__c IN :mapRequiredLabel.keyset()
            									AND Attribute__c != null
            									ORDER BY Attribute__r.Name
            									LIMIT :limits.getLimitQueryRows()]) {
                    attExists = false;
                    
                    if (!mapAllAttributesLabel.containsKey(al.Label__c)) {
                        mapAllAttributesLabel.put(al.Label__c, new List<AttributesLabelWrapper>());
                    }
					
                    if (mapAttributesLabels.get(al.Label__c) != null) {
                    	
                        for (AttributesLabelWrapper tempObj : mapAttributesLabels.get(al.Label__c)) {
                        	
                            if (al.Attribute__c == tempObj.attributeLabel.Attribute__c) {
                                mapAllAttributesLabel.get(al.Label__c).add(new AttributesLabelWrapper(al, ConstantsController.BOLD));
                                attExists = true;
                            }
                        }
                    }
                    
                    if (!attExists) {
                        mapAllAttributesLabel.get(al.Label__c).add(new AttributesLabelWrapper(al, ConstantsController.NORMAL));
                    }
                }
                
				// changes for #436 - adding filters with no associated attributes to the map 
				if (mapAllAttributesLabel.keyset().size() != mapRequiredLabel.keyset().size()) {
					
					for (Label__c lbl : [SELECT Id FROM Label__c
											WHERE Id IN :mapRequiredLabel.keyset()
											AND Id NOT IN :mapAllAttributesLabel.keyset()]) {
						mapAllAttributesLabel.put(lbl.Id, new List<AttributesLabelWrapper>());
					}
				}
            }
            return mapAllAttributesLabel;
        }
        set;
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
     * get map of label and list of its attributes
     */
    public Map<String, List<AttributesLabelWrapper>> mapAttributesLabels {
        get {
            
            if (mapAttributesLabels == null || mapAttributesLabels.size() == 0) {
                mapAttributesLabels = new Map<String, List<AttributesLabelWrapper>>();
                
                for (String lblId : mapRequiredLabel.keyset()) {
                    mapAttributesLabels.put(lblId, new List<AttributesLabelWrapper>());
                }
            }
            return mapAttributesLabels;
        }
        set;
    }
    
    /**
     * Method to select AttributeTypes
     */
    public void setAttributes() {
        
        for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(selectedLabelId)) {
        	
            if (alw.attributeLabel.Attribute__c == selectedAttributeId) {
            	
                if (alw.fontWeight == ConstantsController.NORMAL) {
                    tempmapAttributesLabels.get(selectedLabelId).add(alw);
                    alw.fontWeight = ConstantsController.BOLD;
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
     * Wrapper Class
     */
    public class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel { get; set; }
        public String fontWeight { get; set; }
        
        public AttributesLabelWrapper(Attributes_Labels__c attributeLabel, String weight) {
            fontWeight = weight;
            this.attributeLabel = attributeLabel;
        }
    }
}