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
 * Class: AccountSearchController, AddNewReferenceabilitySLDS, ContactSearchController, ReferenceRefreshController
 * RfSearchController, SF1_filtersClass
 * Description: Class to provide wrapper class for Referenceability type
 * Modified by: Rekha @Feb 6 2017
 */
public without sharing class ReferenceabilityWrapper {
    /**
     * Properties and variables
     */
    public String character { get; set; }
    public List<String> alphabets { get; set; }
    public String referenceabilityTypeId { get; set; }
    private Boolean isContainsRef = false;
    private List<ReferenceabilityTypeWrapper> tempTypeWrapper;
    public Map<String, List<ReferenceabilityTypeWrapper>> mapReferenceabilityTypeWrapper { get; set; } 
    
    public List<referenceabilityTypeWrapper> referenceabilityTypeWrapper {
        get {
        	
            if (referenceabilityTypeWrapper == null) {
                referenceabilityTypeWrapper = new List<ReferenceabilityTypeWrapper>();
                
                for (Referenceability_Type__c rt : [SELECT Name, Id, Referenceability_no__c FROM Referenceability_Type__c 
                							WHERE Referenceability_Type__c = true AND Visible__c = true ORDER BY Name LIMIT : limits.getLimitQueryRows()]) {
                    referenceabilityTypeWrapper.add(new ReferenceabilityTypeWrapper(rt));
                }
            }
            return referenceabilityTypeWrapper;
        }
        set;
    }

    private Map<String, List<ReferenceabilityTypeWrapper>> getReferencibilitiesByAlphabat() {
    	
        if (mapReferenceabilityTypeWrapper == null) {
            mapReferenceabilityTypeWrapper = new Map<String, List<ReferenceabilityTypeWrapper>>();
            
            for (String s : alphabets) {
                mapReferenceabilityTypeWrapper.put(s, new List<ReferenceabilityTypeWrapper>());
            }
            mapReferenceabilityTypeWrapper.put(ConstantsController.ALL, referenceabilityTypeWrapper);
            mapReferenceabilityTypeWrapper.put('other', new List<ReferenceabilityTypeWrapper>());
            String alphbets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            
            if (character.trim().length() != 0) {
            	
                for (ReferenceabilityTypeWrapper rtw : referenceabilityTypeWrapper) {
                    String firstLetter = ((string) rtw.refType.Name).left(1);
                    
                    if (alphbets.contains(firstLetter)) {
                    	
                        if (!mapReferenceabilityTypeWrapper.containskey(firstLetter)) {
                            mapReferenceabilityTypeWrapper.put(firstLetter, new List<ReferenceabilityTypeWrapper>());
                        }
                        mapReferenceabilityTypeWrapper.get(firstLetter).add(rtw);
                    } else {
                        mapReferenceabilityTypeWrapper.get('other').add(rtw);
                    }
                }
            }
        }
        return mapReferenceabilityTypeWrapper;
    }

    public List<ReferenceabilityTypeWrapper> selectedReferenceabilityTypes {
        get {
        	
            if (selectedReferenceabilityTypes == null) {
                selectedReferenceabilityTypes = new List<ReferenceabilityTypeWrapper>();
            }
            return selectedReferenceabilityTypes;
        }
        set;
    }

    public void setDefaultReferenceabilityType(Set<Id> refTypeIds) {
    	
        for (ReferenceabilityTypeWrapper rtw : referenceabilityTypeWrapper) {
        	
            if (refTypeIds.contains(rtw.refType.Id)) {
            	
                if (rtw.fontWeight == ConstantsController.NORMAL) {
                    rtw.fontWeight = ConstantsController.BOLD;
                    selectedReferenceabilityTypes.add(new ReferenceabilityTypeWrapper(rtw.refType));
                }
            }
        }
    }

    /**
     * Constructor
     */
    public ReferenceabilityWrapper() {
        character = '';
        referenceabilityTypeId = '';
        alphabets = new List<String> {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
            'U', 'V', 'W', 'X', 'Y', 'Z', System.Label.other, System.Label.All
        };
    }

    /**
     * Method to Search Referenceability Type Alphabetically
     */
    public void showReferenceabilityAlphabet() {
    	
        if (character.trim().length() != 0) {
            Map<String, List<ReferenceabilityTypeWrapper>> tempMap = getReferencibilitiesByAlphabat();
            referenceabilityTypeWrapper = tempMap.get(character);
        }
    }

    /**
     * Method to select referenceability
     */
    public void setReferenceabilityTypes() {
    	
        for (ReferenceabilityTypeWrapper rtw : referenceabilityTypeWrapper) {
        	
            if (rtw.refType.Id == referenceabilityTypeId) {
            	
                if (rtw.fontWeight == ConstantsController.NORMAL) {
                    rtw.fontWeight = ConstantsController.BOLD;
                    selectedReferenceabilityTypes.add(new ReferenceabilityTypeWrapper(rtw.refType));
                    break;
                } else {
                	
                    for (Integer i = 0; i < selectedReferenceabilityTypes.size(); i++) {
                    	
                        if (selectedReferenceabilityTypes[i].refType.Id == rtw.refType.Id) {
                            rtw.fontWeight = ConstantsController.NORMAL;
                            selectedReferenceabilityTypes.remove(i);
                            break;
                        }
                    }
                }
            }
        }
    }

    /**
     * Method to selectAll referenceability
     */
    public void selectAllReferenceabilityTypes() {
    	
        for (ReferenceabilityTypeWrapper rtw : referenceabilityTypeWrapper) {
        	
            if (rtw.fontWeight == ConstantsController.NORMAL) {
                rtw.fontWeight = ConstantsController.BOLD;
                selectedReferenceabilityTypes.add(new ReferenceabilityTypeWrapper(rtw.refType));
            }
        } 
    }

    /**
     * Method to clear all referenceability
     */
    public void clearAllReferenceabilityTypes() {
        selectedReferenceabilityTypes.clear();
        referenceabilityTypeWrapper = null;
        mapReferenceabilityTypeWrapper = null;
    }

    /**
     * Wrapper Class
     */
    public class ReferenceabilityTypeWrapper {
        public Referenceability_Type__c refType { get; set; }
        public String fontWeight { get; set; }
        public Integer indexValue { get; set; }
        
        public ReferenceabilityTypeWrapper(Referenceability_Type__c refType) {
            fontWeight = ConstantsController.NORMAL;
            this.refType = refType;
        }
    }
}