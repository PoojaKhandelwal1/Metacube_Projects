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
public without sharing class AttributeWrapper {
    /**
     * Properties and variables
     */
    public List<AttributesLabelWrapper> lstAttributeWrapper;
    private List<Label__c> labels;
    public Map<String, List<Data_Mapping__c>> filterDependencyMap{ get; Set; }
    public String selectedLabelId {
        get;
        Set;
    }
    public String attributeId {
        get;
        Set;
    }
    public String character {
        get;
        Set;
    }
    public Set<String> allSelectedAttrIds {
        get;
        Set;
    }
    public List<String> alphabets {
        get;
        Set;
    }
    public Map<String,Label__c> mapLabels {
        get;
        Set;
    }
    public String labelName {
        get {
            if (selectedLabelId != null)
                labelName = mapLabels.get(selectedLabelId).Name;
            return labelName;
        }
        Set;
    }
    //REF-2506
    public Boolean attributeSelected { get; Set; }
    //REF-2399
    public Boolean currentRecordsAreBulky { get; Set; }
    public String searchValue { get; Set; }
    public Boolean hasBulkRecords { get; Set; }
    public Boolean performSearch { get; Set; }
    public Map<String, Integer>labelSizeMap {
        get {
            if (mapAllAttributesLabel != null) {
                for (String key: mapAllAttributesLabel.keySet()) {
                    labelSizeMap.put(key, mapAllAttributesLabel.get(key).size());
                }
            }
            return labelSizeMap;
        }
        Set;
    }


    /**
     * Method to get filter dependency
     */
    public void getDependencyDetails() {
        filterDependencyMap = new Map<String, List<Data_Mapping__c>>();
        
        for (Data_Mapping__c dmRecord : [SELECT Field_API_Name__c, Label__c, Section_Name__c, Default__c, Visible__c, Object__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                    AND From_Mapping__c = false]) {
            if (!filterDependencyMap.containsKey(dmRecord.Label__c)) {
                filterDependencyMap.put(dmRecord.Label__c,new List<Data_Mapping__c>());
            }
            filterDependencyMap.get(dmRecord.Label__c).add(dmRecord);
        }
    }

    /**
     * Method to get Selected Attribute Name -- used in "RfSearchPage" page
     */
    public Map<String, List<AttributesLabelWrapper>> mapAttributesLabels {
        get {
            if (mapAttributesLabels == null) {
                mapLabels = new Map<String,Label__c> ();
                mapAttributesLabels = new Map<String, List<AttributesLabelWrapper>> ();
                for (Label__c lbl: getAttributeLabels()) {
                    mapAttributesLabels.put(lbl.id, new List<AttributesLabelWrapper> ());
                    mapLabels.put(lbl.id, lbl);
                }
            }
            return mapAttributesLabels;
        }
        Set;
    }

    /**
     * Method to get Selected Attribute Name -- used in "RfSearchPage" page
     */
    public Map<String,DependecyWrapper> dependentBooleanMap {
        get {
            if (dependentBooleanMap == null) {
                dependentBooleanMap = new Map<String,DependecyWrapper> ();
                for (String lbl: mapAllAttributesLabel.keySet()) {
                    dependentBooleanMap.put(lbl, new DependecyWrapper(mapAllAttributesLabel.get(lbl).size()));
                }
            }
            return dependentBooleanMap;
        }
        Set;
    }

    public Boolean dependentAnyHidden { get;Set;}

    /**
     * Method to get All Attribute Name with Label -- used in "ViewAllFilter" page
     */
    public Map<String, List<AttributesLabelWrapper>> mapAllAttributesLabel {
        get {
            if (mapAllAttributesLabel == null || performSearch) {
                performSearch = false;
                mapAllAttributesLabel = new Map<String, List<AttributesLabelWrapper>> ();
                Set<String> lblIds = new Set<String> ();
                mapAllAttributesLabel.put('Content Types', new List<AttributesLabelWrapper> ());
                mapAllAttributesLabel.put('Content Language', new List<AttributesLabelWrapper> ());
                mapAllAttributesLabel.put('Referenceability', new List<AttributesLabelWrapper> ());
                for (Label__c lbl: getAttributeLabels()) {
                    lblIds.add(lbl.id);
                    mapAllAttributesLabel.put(lbl.id, new List<AttributesLabelWrapper> ());
                }
                List<AttributesLabelWrapper> lstAttributeWrapper;
                List<Attributes_Labels__c> attLabelList;

                if (searchValue == null || searchValue.trim() == '') {
                    attLabelList = [SELECT Name, Label__c, Id, Attribute__c, Attribute__r.Parent__c, Attribute__r.Name
                                    FROM Attributes_Labels__c
                                    WHERE Label__c IN :lblIds
                                    AND Attribute__c != null
                                    ORDER BY Attribute__r.Name LIMIT :limits.getLimitQueryRows()];
                } else {
                    String tempSearchVal = searchValue.replace('*', '%') + '%';
		            tempSearchVal = String.escapeSingleQuotes(tempSearchVal);
		            tempSearchVal = '\'' + tempSearchVal + '\'';
                    String attLabelQuery = 'SELECT Name, Label__c, Id, Attribute__c, Attribute__r.Parent__c, Attribute__r.Name '
                                            + 'FROM Attributes_Labels__c '
                                            + 'WHERE Label__c IN :lblIds '
                                            + 'AND Attribute__c != null '
                                            + 'AND Attribute__r.Name LIKE ' + tempSearchVal
                                            + ' ORDER BY Attribute__r.Name LIMIT 201';
                    attLabelList = Database.query(attLabelQuery);
                }

                
                for (Attributes_Labels__c al : attLabelList) {
                    if (mapAllAttributesLabel.containsKey(al.Label__c)) {
                        lstAttributeWrapper = mapAllAttributesLabel.get(al.Label__c);
                    } else {
                        lstAttributeWrapper = new List<AttributesLabelWrapper> ();
                    }
                    if (lstAttributeWrapper.size() < 201) {
                        lstAttributeWrapper.add(new AttributesLabelWrapper(al));
                        mapAllAttributesLabel.put(al.Label__c, lstAttributeWrapper);
                    }
                }

                if (selectedLabelId != null && mapAllAttributesLabel.containsKey(selectedLabelId) && mapAllAttributesLabel.get(selectedLabelId).size()> 200) {
                    hasBulkRecords = true;
                    //REF-2399
                    currentRecordsAreBulky = true;
                }
                
                //REF-2399
                if (selectedLabelId != null && mapAllAttributesLabel.containsKey(selectedLabelId) && mapAllAttributesLabel.get(selectedLabelId).size() < 200) {
                    currentRecordsAreBulky = false;
                }
                
                //REF-2407
                if (allSelectedAttrIds.size() > 0) {
                    for (AttributesLabelWrapper alw : mapAllAttributesLabel.get(selectedLabelId)) { 
                        
                        if (allSelectedAttrIds.contains(alw.attributeLabel.Attribute__c)) {
                            alw.fontWeight = ConstantsController.BOLD;
                        } else {
                            alw.fontWeight = ConstantsController.NORMAL;
                        }
                    }
                }
            } else {
                //REF-2453
                if (selectedLabelId != null && mapAllAttributesLabel.containsKey(selectedLabelId) && mapAllAttributesLabel.get(selectedLabelId).size()> 200) {
                    hasBulkRecords = true;
                    currentRecordsAreBulky = true;
                }
                
                if (selectedLabelId != null && mapAllAttributesLabel.containsKey(selectedLabelId) && mapAllAttributesLabel.get(selectedLabelId).size() < 200) {
                    currentRecordsAreBulky = false;
                }
            }
            /*for (Data_Mapping__c dm: [select Field_API_Name__c from Data_Mapping__c where From_Mapping__c = true]) {
                if(dm.Field_API_Name__c != null)
                    mapAllAttributesLabel.put(dm.Field_API_Name__c, new list<AttributesLabelWrapper> ());
            }*/
            return mapAllAttributesLabel;
        }
        Set;
    }

    /**
     * Constructor
     */
    public AttributeWrapper() {
        attributeSelected = false;
        labelSizeMap = new Map<String,Integer>();
        allSelectedAttrIds = new Set<String> ();
        character = '';
        searchValue = '';
        performSearch = false;
        hasBulkRecords = false;
        //REF-2399
        currentRecordsAreBulky = false;
        alphabets = new List<String> {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', System.Label.All
        };
        getDependencyDetails();
        dependentAnyHidden = false;
    }
    
    /**
     * Method to get Selected Attribute Name -- used in "RfSearchPage" page
     */
    public void setDefaultAttributeLabels(Map<String, Set<String>> labelAttrMap) {
        for (String labelId: labelAttrMap.keySet()) {
            Set<String> attrSet = labelAttrMap.get(labelId);
            for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(labelId)) {
                if (attrSet.contains(alw.attributeLabel.Attribute__c)) {
                    if (alw.fontWeight == ConstantsController.NORMAL) {
                        mapAttributesLabels.get(labelId).add(alw);
                        alw.fontWeight = ConstantsController.BOLD;
                    }
                }
            }
            dependentBooleanMap.get(labelId).size = mapAllAttributesLabel.get(labelId).size();
        }
        dependentAnyHidden = false;
        for (String lbl: dependentBooleanMap.keySet()) {
            dependentAnyHidden = dependentAnyHidden || dependentBooleanMap.get(lbl).anyAttrHidden;
        }
    }
    /**
     * Method to Search Attribute Type Alphabetically
     */
    private Boolean isContainsAttribute = false;
    private Map<String, List<AttributesLabelWrapper>> tempAttributesLabelMap;
    public Pagereference showAttributeAlphabetically() {
        return null;
    }

    /**
     * Method to get Attribute Labels Name -- used in "RfSearchPage" page
     */
    public List<Label__c> getAttributeLabels() {
        if (labels == null) {
            labels = [select id, name, BasicSearchView__c,Filter_no__c,Filter_RefSearch_Visible__c from Label__c order by Name LIMIT: limits.getLimitQueryRows()];
        }
        return labels;
    }

    public Pagereference searchRecords() {
        
        //REF-2399 - rerender the page twice to set value
        if (mapAllAttributesLabel != null) {
            return null;
        }
        return null;
    }

    /**
     * Method to get Attribute Name as per Selected Label -- used in "AttributeResults" page
     */
    public List<AttributesLabelWrapper> getAttributesByLabel() {
        if (selectedLabelId != null && selectedLabelId.trim().length() != 0) {
            if (character.trim().length() == 0 || character.trim() == ConstantsController.ALL)
                lstAttributeWrapper = new List<AttributesLabelWrapper> (mapAllAttributesLabel.get(selectedLabelId));
            else {
                if (!isContainsAttribute) {
                    tempAttributesLabelMap = new Map<String, List<AttributesLabelWrapper>> ();
                    tempAttributesLabelMap.putAll(mapAllAttributesLabel);
                }
                List<AttributesLabelWrapper> attrTypeWrapper = new List<AttributesLabelWrapper> ();
                if (character.trim().length() != 0) {
                    isContainsAttribute = true;
                    //If character is not equals to "All" or "Other"
                    if (character != ConstantsController.ALL && character != 'other') {
                        for (AttributesLabelWrapper alw: tempAttributesLabelMap.get(selectedLabelId)) {
                            if (((string) alw.attributeLabel.Attribute__r.Name).startswithIgnoreCase(character)) {
                                attrTypeWrapper.add(alw);
                            }
                        }
                        return attrTypeWrapper;
                    }
                    //If character is equals to "Other"
                    if (character == 'other') {
                        for (AttributesLabelWrapper alw: tempAttributesLabelMap.get(selectedLabelId)) {
                            if (((string) alw.attributeLabel.Attribute__r.Name).length() != 0) {
                                String alphbets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
                                if (!alphbets.containsIgnoreCase(((string) alw.attributeLabel.Attribute__r.Name).left(1))) {
                                    attrTypeWrapper.add(alw);
                                }
                            }
                        }
                        return attrTypeWrapper;
                    }
                }
            }
        }
        return lstAttributeWrapper;
    }

    /**
     * Method to select AttributeTypes
     */
    public void setAttributes() {
        if (!attributeSelected) {
            attributeSelected = true;
        }
        for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(selectedLabelId)) {
            
            if (alw.attributeLabel.Attribute__c == attributeId) {
                if (alw.fontWeight == ConstantsController.NORMAL) {
                    mapAttributesLabels.get(selectedLabelId).add(alw);
                    alw.fontWeight = ConstantsController.BOLD;
                    allSelectedAttrIds.add(attributeId);
                    break;
                } else {
                    for (Integer i = 0; i<mapAttributesLabels.get(selectedLabelId).size(); i++) {
                        if (mapAttributesLabels.get(selectedLabelId)[i].attributeLabel.Attribute__c == alw.attributeLabel.Attribute__c) {
                            alw.fontWeight = ConstantsController.NORMAL;
                            mapAttributesLabels.get(selectedLabelId).remove(i);
                            allSelectedAttrIds.remove(alw.attributeLabel.Attribute__c);
                            break;
                        }
                    }
                }
            }
        }
        updateDependent();
    }
    private void updateDependent() {
        Map<String,Set<String>> visibleAttr = new Map<String,Set<String>>();
        Boolean isSelected = false;
        Set<String> selectedAttrs = new Set<String>();
        for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(selectedLabelId)) {
            if (alw.fontWeight == ConstantsController.BOLD) {
                selectedAttrs.add(alw.attributeLabel.Attribute__c);
            }
        }
        if (filterDependencyMap.containsKey(selectedLabelId) ) {

            for (Data_Mapping__c dmRecord : filterDependencyMap.get(selectedLabelId)) {

                if (!visibleAttr.containsKey(dmRecord.Field_API_Name__c)) {
                    visibleAttr.put(dmRecord.Field_API_Name__c,new Set<String>());
                }
                if (dmRecord.Default__c != null && mapAllAttributesLabel.containsKey(dmRecord.Field_API_Name__c) && selectedAttrs.contains(dmRecord.Section_Name__c)) {
                    visibleAttr.get(dmRecord.Field_API_Name__c).addAll(new List<String>(dmRecord.Default__c.split(';')));
                }
            }
            
            for (String labelDep : visibleAttr.keySet()) {
                Boolean anyAttrHidden = false;
                Integer size = 0;
                for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(labelDep)) {
                    alw.show = false;
                    
                    if (selectedAttrs.size() == 0 || visibleAttr.get(labelDep).contains(alw.attributeLabel.Attribute__c) || alw.fontWeight == ConstantsController.BOLD) {
                        alw.show = true;
                        size++;
                    } else {
                        anyAttrHidden = true;
                    }
                }
                dependentBooleanMap.get(labelDep).anyAttrHidden = anyAttrHidden;
                dependentBooleanMap.get(labelDep).size = size;
            }
        }
        dependentAnyHidden = false;
        for (String lbl: dependentBooleanMap.keySet()) {
            dependentAnyHidden = dependentAnyHidden || dependentBooleanMap.get(lbl).anyAttrHidden;
        }
    }

    /**
     * Method to selectAll Attributes
     */
    public void selectAllAttributeTypes() {
        for (AttributesLabelWrapper alw: getAttributesByLabel()) {
            if (alw.fontWeight == ConstantsController.NORMAL && alw.show) {
                alw.fontWeight = ConstantsController.BOLD;
                mapAttributesLabels.get(selectedLabelId).add(alw);
            }
        }
        if (!attributeSelected) {
            attributeSelected = true;
        }
        updateDependent();
    }

    /**
     * Method to clear all AttributeTypes
     */
    public void clearSelectedAttributeTypes() {
        mapAttributesLabels.get(selectedLabelId).clear();
        for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(selectedLabelId)) {
            alw.fontWeight = ConstantsController.NORMAL;
        }
        
        if (filterDependencyMap.containsKey(selectedLabelId)) {

            for (Data_Mapping__c dmRecord : filterDependencyMap.get(selectedLabelId)) {

                for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(dmRecord.Field_API_Name__c)) {
                    alw.show = true;
                } 
                dependentBooleanMap.get(dmRecord.Field_API_Name__c).anyAttrHidden = false;
                dependentBooleanMap.get(dmRecord.Field_API_Name__c).size = mapAllAttributesLabel.get(dmRecord.Field_API_Name__c).size();
            }
        }
        dependentAnyHidden = false;
        for (String lbl: dependentBooleanMap.keySet()) {
            dependentAnyHidden = dependentAnyHidden || dependentBooleanMap.get(lbl).anyAttrHidden;
        }
    }

    /**
     * Method to Show all AttributeTypes
     */
    public void showAll() {
        for (AttributesLabelWrapper alw: mapAllAttributesLabel.get(selectedLabelId)) {
            alw.show = true;
        }
        dependentBooleanMap.get(selectedLabelId).anyAttrHidden = false;
        dependentBooleanMap.get(selectedLabelId).size = mapAllAttributesLabel.get(selectedLabelId).size();
        dependentAnyHidden = false;
        for (String lbl: dependentBooleanMap.keySet()) {
            dependentAnyHidden = dependentAnyHidden || dependentBooleanMap.get(lbl).anyAttrHidden;
        }
    }
    /**
     * Wrapper class
     */
    public class DependecyWrapper {
        public Boolean anyAttrHidden {get; Set;}
        public Integer size {get; Set;}
        public DependecyWrapper(Integer size) {
            anyAttrHidden = false;
            this.size = size;
        }
    }
    /**
     * Wrapper class
     */
    public class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel {
            get;
            Set;
        }
        public String fontWeight {
            get;
            Set;
        }
        public Boolean show {
            get;
            Set;
        }
        public AttributesLabelWrapper(Attributes_Labels__c attributeLabel) {
            fontWeight = ConstantsController.NORMAL;
            this.attributeLabel = attributeLabel;
            show = true;
        }
    }
}