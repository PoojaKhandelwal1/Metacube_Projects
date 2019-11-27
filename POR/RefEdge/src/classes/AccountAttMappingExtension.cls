/**
 * ReferenceEdge
 *
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc. - test commit
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-----IS" BY POINT OF REFERENCE ("POR"),
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
 * VF Page: AccountAttMappingInlinePage
 * Description: controller for inline page on account detail page to display
 *              all the attribute mappings for the account object
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class AccountAttMappingExtension extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public List<Attribute_Mapping__c> attMappings { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public AccountAttMappingExtension(ApexPages.standardController controller) {
        
        if ((ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != null
                        && ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != '')
                    || (ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != null
                        && ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != '')
                    || ApexPages.currentPage().getParameters().get('isdtp') == 'p1'
                    || (ApexPages.currentPage().getParameters().get('retURL') != null
                        && ApexPages.currentPage().getParameters().get('retURL').contains('projectone'))) {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
            attMappings = new List<Attribute_Mapping__c>();
            
            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Name, Inheritable__c, Filter_Label_Name__c, Field__c,
                                                    Auto_update__c, Auto_populate__c, Auto_delete__c, Auto_add__c, Attribute_Name__c
                                                    FROM Attribute_Mapping__c
                                                    WHERE Object__c = 'Account'
                                                    AND Is_Related_Mapping__c = false]) {
                attMappings.add(attMapping);
            }
        }
    }
}