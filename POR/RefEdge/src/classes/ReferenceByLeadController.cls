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
 * VF Page: Referencebylead.page
 * Description: Class to manage reference lead request
 * Last modified by: Gaurav Saini (18 April, 2017) for #5
 */
public with sharing class ReferenceByLeadController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Reference_Lead__c referenceLead { get; set; }
    public String option1 { get; set; }
    public String option2 { get; set; }
    public String option3 { get; set; }
    public Boolean referenceableBlock { get; set; }
    public Boolean showRefLeadBlock { get; set; }
    public String optionSelected { get; set; }
    public Boolean showMessage { get; set; }
    public String accountName { get; set; }
    public Pagereference pg;
    // added for #5
    public Boolean isSLDS { get; set; }
    public Boolean isSF1 { get; set; }
    public String refLeadId { get; set; }
    public Boolean isSLDSSet { get; set; }
    
    /**
     * Constructor
     */
    public ReferenceByLeadController(ApexPages.StandardController controller) {
        refLeadId = ApexPages.currentPage().getParameters().get('Id');
        isSLDSSet = false;
        
        // added for #5 - checking the currently enabled environment
        if (UserInfo.getUiTheme() == 'Theme4d') {
            system.debug('*********SLDS');
            isSLDS = true;
            isSF1 = false;
        } else if (UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSF1 = true;
            isSLDS = false;
        } else {
            system.debug('********normal');
            isSLDS = false;
            isSF1 = false;
        }
        
        // related to #812
        if (Test.isRunningTest()) {
        	reset();
        }
    }
    
    public PageReference reset() {
        
        if (!isSLDS) {
        	isSLDSSet = true;
	        referenceableBlock = false;
	        showMessage = false;
	        List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLead(refLeadId);
	        
	        if (refLeads.size() > 0) {
	            referenceLead = refLeads[0];
	            accountName = referenceLead.Reference_Lead_Account__r.Name;
	            
	            if (referenceLead.Reference_Profile__c == null
	            			&& referenceLead.Nomination__c == null
	            			&& referenceLead.Reference_Lead_Status__c != 'No Updates') {
	                showRefLeadBlock = true;
	                
	                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBIReferenceable(referenceLead.Reference_Lead_Account__c)) {
	                    
	                    if (rbi.Is_Referenceable__c) {
	                        referenceableBlock = true;
	                    }
	                }
	                
	                if (referenceableBlock) {
	                    option1 = 'Yes';
	                    option2 = 'No';
	                } else {
	                    option1 = Label.RefLeadOption1;
	                    option2 = Label.RefLeadOption2;
	                    option3 = Label.RefLeadOption4;
	                }
	            } else {
	                showRefLeadBlock = false;
	            }
	        }
	        return null;
        } else {
        	return new PageReference(Page.ReferenceByLeadSLDS.getURL() + '?Id=' + refLeadId);
        }
    }
    
    /**
     * Method to redirect to Reference Lead form
     */
    public void redirectToRefLeadForm() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (referenceableBlock) {
        	
            if (optionSelected == '1') {
            	
                if (cs.Create_Reference_Profile__c) {
                    pg = new PageReference(Page.ReferenceLeadForm.getURL() + '?id=' + referenceLead.Id + '&option=1');
                } else if (cs.Create_Nomination__c) {
                    pg = new PageReference(Page.NominationFormSLDS.getURL() + '?refLeadId=' + referenceLead.Id);
                }
                pg.setRedirect(true);
            } else if (optionSelected == '2') {
            	// added for #1139 - Gaurav Saini (23 Nov, 2017)
            	referenceLead.Response_received__c = true;
                referenceLead.Reference_Lead_Status__c = 'No Updates';
                WithoutSharingHelperController.updateRefLead(referenceLead);
                showMessage = true;
            }
        } else if (!referenceableBlock) {
        	
            if (optionSelected == '1') {
            	
                if (cs.Create_Reference_Profile__c) {
                    pg = new PageReference(Page.ReferenceLeadForm.getURL() + '?id=' + referenceLead.Id + '&option=1');
                } else if (cs.Create_Nomination__c) {
                    pg = new PageReference(Page.NominationFormSLDS.getURL() + '?refLeadId=' + referenceLead.Id);
                }
                pg.setRedirect(true);
            } else if (optionSelected == '2') {
                pg = new PageReference(Page.ReferenceLeadForm.getURL() + '?id=' + referenceLead.Id + '&option=2');
                pg.setRedirect(true);
            } else if (optionSelected == '3') {
                pg = new PageReference(Page.ReferenceLeadForm.getURL() + '?id=' + referenceLead.Id + '&option=3');
                pg.setRedirect(true);
            }
        }
    }
    
    /**
     * Method to load reference Lead form
     */
    public pageReference loadRefLeadForm() {
        return pg;
    }
    
    /**
     * Method to return to home page
     */
    public pageReference returnHomePage() {
        return new pageReference('/home/home.jsp');
    }
}