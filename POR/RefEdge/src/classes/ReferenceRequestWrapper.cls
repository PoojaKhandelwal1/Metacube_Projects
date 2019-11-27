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
 * Class: RfSearchController, RequestWithoutOppController, RequestWithOppController, RefRequestProjectController
 * HitListReleaseActionController, AssignActionController
 * Description: Wrapper class of Request
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class ReferenceRequestWrapper {
    /**
     * Properties and variables
     */
    public String backgroundColor { get; set; }
    public boolean isOpp { get; set; }
    public Id id { get; set; }
    public boolean isReq { get; set; }
    public Reference_Request_Account__c rra { get; set; }
    public Reference_Request_Account_Contact__c rrac { get; set; }
    public Unspecified_Request__c unSpec { get; set; }
    public Boolean isUR { get; set; }
    public Date deadline { get; set; }
    public Reference_Request__c request { get; set; }
    public String processStatus { get; set; }
    public String status { get; set; }
    public boolean isSelected { get; set; }

    /**
     * Constructor for contact Request
     */
    public ReferenceRequestWrapper(Boolean isOpp, Boolean isReq, Reference_Request__c request, Reference_Request_Account__c rra, 
    								Reference_Request_Account_Contact__c rrac, String backgroundColor, String status) {
        this.request = request;
        this.rra = rra;
        this.backgroundColor = backgroundColor;
        this.isOpp = isOpp;
        this.isReq = isReq;
        this.isUR = false;
        this.deadline = rra.Deadline__c;
        this.processStatus = status;
        this.id = rra.Id;
        this.status = rra.Account_Request_Status__c;
        this.isSelected = false;
        this.rrac = rrac;
    }
    
    /**
     * Constructor for Account Request
     */
    public ReferenceRequestWrapper(Boolean isOpp, Boolean isReq, Reference_Request__c request, Reference_Request_Account__c rra, 
    								String backgroundColor, String status) {
        this.request = request;
        this.rra = rra;
        this.backgroundColor = backgroundColor;
        this.isOpp = isOpp;
        this.isReq = isReq;
        this.isUR = false;
        this.deadline = rra.Deadline__c;
        this.processStatus = status;
        this.id = rra.Id;
        this.status = rra.Account_Request_Status__c;
        this.isSelected = false;

    }

    /**
     * Constructor for Unspecified Request
     */
    public ReferenceRequestWrapper(Boolean isOpp, Boolean isReq, Reference_Request__c request, Unspecified_Request__c unSpec, 
    								String backgroundColor, String status) {
        this.request = request;
        this.unSpec = unSpec;
        this.backgroundColor = backgroundColor;
        this.isOpp = isOpp;
        this.isUR = true;
        this.isReq = isReq;
        this.deadline = unSpec.Deadline__c;
        this.processStatus = status;
        this.id = unSpec.Id;
        this.status = unSpec.Unspecified_Request_Status__c;
        this.isSelected = false;
    }
}