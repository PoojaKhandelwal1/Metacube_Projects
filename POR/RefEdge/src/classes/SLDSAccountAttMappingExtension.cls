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
 * VF Page: SLDSAccountAttMapping 
 * Description: Controller used to handle account attribute mapping in lightning.
 * Last modified by: Rajesh @Feb 6 2017
 */
global with sharing class SLDSAccountAttMappingExtension extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
    public List<AccountRequestWrapper> accReqs { get; set; }
     
    /**
     * Constructor
     */
    public SLDSAccountAttMappingExtension(ApexPages.standardController controller) {} 
    
    /**
     * Method used to get account attribute mapping list.
     */ 
    @RemoteAction
    global static List<AccountRequestWrapper> getAccountAttMappingList() {         
       List<AccountRequestWrapper> accReqs = new List<AccountRequestWrapper>();
       
       for (Attribute_Mapping__c attMapping : [SELECT Object__c, Name, Inheritable__c, Filter_Label_Name__c, Field__c, Auto_update__c, Auto_populate__c, Auto_delete__c, 
       											Auto_add__c, Attribute_Name__c FROM Attribute_Mapping__c WHERE Object__c = 'Account' AND Is_Related_Mapping__c = FALSE ]) {
                  accReqs.add(new AccountRequestWrapper(attMapping)); 
        } 
        return accReqs;
    }
    
    /**
     * Wrapper class for Account request
     */ 
    global class AccountRequestWrapper {    	
      	public Attribute_Mapping__c attMap { get; set; }
      	public String Id { get; set; }
      	public String Name { get; set; }
      	public String Mapped_Field { get; set; }
      	public String Associated_Filter { get; set; }
      	public String Associated_Attribute { get; set; }
      	public Boolean Inheritable { get; set; }
      	public Boolean Auto_Update { get; set; }
      	public Boolean Auto_Populate { get; set; }
      	public Boolean Auto_Delete { get; set; }
      	public Boolean Auto_Add { get; set; }
            
      	public AccountRequestWrapper(Attribute_Mapping__c attMapping) { 
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