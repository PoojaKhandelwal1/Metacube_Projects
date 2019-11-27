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
 * Page: RefContentAttMappingInlinePage
 * Description : Class used to show Attribute Mappings on Reference Content detail page.
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class RefContentAttMappingExtension extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public List<Attribute_Mapping__c> attMappings { get; set; }
    
    /**
     * Constructor
     */
    public RefContentAttMappingExtension(ApexPages.standardController controller) {
        attMappings = new List<Attribute_Mapping__c> ();
        
        for (Attribute_Mapping__c attMapping : [SELECT Object__c, Name, Inheritable__c, Filter_Label_Name__c, Field__c,
                Auto_update__c, Auto_populate__c, Auto_delete__c, Auto_add__c, Attribute_Name__c
                FROM Attribute_Mapping__c WHERE Object__c = 'Reference Content'
                AND Is_Related_Mapping__c = false
            ]) {
            attMappings.add(attMapping);
        }
    }
}