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
 * VF Page: AllAccReqofRefRequest.page
 * Description: controller for inline page on Reference request detail page to display
 *				all the account requests for that reference request
 * Last modified by: Rekha @23 august 2017
 */
public with sharing class AllAccReqofRefRequestController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public List<Reference_Request_Account__c> requestList { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public AllAccReqofRefRequestController(ApexPages.StandardController controller) {
        Reference_Request__c refObj = (Reference_Request__c)controller.getRecord();
        
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        requestList = new List<Reference_Request_Account__c>();
	        requestList = WithoutSharingHelperController.getRRAccountRequests(refObj.Id);
        }
    }
}