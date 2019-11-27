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
 * VF Page: ContactAttMappingInlinePageSLDS.page
 * Description: controller for displaying the attribute mappings for Contact on the inline page on contact detail page
 * Last modified by: Gaurav Saini (15 June, 2017) for #732
 */
global with sharing class SLDSContactAttMappingExtension extends RefEdgeEditionFeatures {
	
	public List<ContactRequestWrapper> conReqs { get; set; }
    
    /**
     * Constructor
     */
    public SLDSContactAttMappingExtension(ApexPages.standardController controller) {}
    
    @RemoteAction
    global static List<ContactRequestWrapper> getContactAttMappingList() {
		List<ContactRequestWrapper> conReqs = new List<ContactRequestWrapper>();
		
		for (Attribute_Mapping__c attMapping : [SELECT Object__c, Name, Inheritable__c, Filter_Label_Name__c, Field__c,
       											Auto_update__c, Auto_populate__c, Auto_delete__c, Auto_add__c, Attribute_Name__c
       											FROM Attribute_Mapping__c
       											WHERE Object__c = 'Contact'
       											AND Is_Related_Mapping__c = false]) {
			conReqs.add(new ContactRequestWrapper(attMapping));
		}
        return conReqs;
    }
    
    /**
     * Wrapper class
     */
    global class ContactRequestWrapper {
	    public Attribute_Mapping__c attMap { get; set; }
	    public string Id { get; set; }
	    public string Name { get; set; }
	    public string Mapped_Field { get; set; }
	    public string Associated_Filter { get; set; }
	    public string Associated_Attribute { get; set; }
	    public boolean Inheritable { get; set; }
	    public boolean Auto_Update { get; set; }
	    public boolean Auto_Populate { get; set; }
	    public boolean Auto_Delete { get; set; }
	    public boolean Auto_Add { get; set; }
	    
	    public ContactRequestWrapper(Attribute_Mapping__c attMapping) {
	        this.attMap = attMapping;
	        this.Id = attMapping.Id;
	        this.Name = attMapping.Name;
	        this.Mapped_Field = attMapping.Field__c;
	        this.Associated_Filter = attMapping.Filter_Label_Name__c;
	        this.Associated_Attribute = attMapping.Attribute_Name__c;
	        this.Inheritable = attMapping.Inheritable__c;
	        this.Auto_Update = attMapping.Auto_update__c;
	        this.Auto_Populate = attMapping.Auto_populate__c;
	        this.Auto_Delete = attMapping.Auto_delete__c;
	        this.Auto_Add = attMapping.Auto_delete__c;
	    }
	}
}