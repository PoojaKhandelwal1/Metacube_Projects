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
public class RefRequestWrapper {
    public String refRequestId { get; set; }
    public String refRequestName { get; set; }
    public String oppId { get; set; }
    public String oppName { get; set; }
    public String oppAccountName { get; set; }
    public String status { get; set; }
    public String requesterId { get; set; }
    public String requesterName { get; set; }
    public String subject { get; set; }
    public String projectType { get; set; }
    public String caseId { get; set; }
    public String caseNumber { get; set; }
    public String leadId { get; set; }
    public String leadName { get; set; }
    public Boolean isP2PRequest { get; set; }
    public List<AccRequestWrapper> accRequests { get; set; }
    public List<UnspecRequestWrapper> unspecRequests { get; set; }
    public Map<String, String> rrLabelMap { get; set; }
    public List<String> advRoutingGroups { get; set; }

    public RefRequestWrapper(Reference_Request__c rr) {
        this.refRequestId = rr.Id;
        this.isP2PRequest = false;
        this.refRequestName = rr.Name;
        this.oppId = rr.Opportunity__c != null ? String.valueOf(rr.Opportunity__c) : '';
        this.oppName = rr.Opportunity__c != null ? rr.Opportunity__r.Name : '';
        this.oppAccountName = rr.Opportunity__c != null ? rr.Opportunity__r.Account.Name : (rr.Case__c != null && rr.Case__r.AccountId != null ? rr.Case__r.Account.Name : '');
        this.status = rr.Reference_Request_Status__c;
        this.requesterId = rr.Requester__c != null ? String.valueOf(rr.Requester__c) : '';
        this.requesterName = rr.Requester__c != null ? rr.Requester__r.Name : '';
        this.subject = rr.Title__c != null ? rr.Title__c : '';
        this.projectType = rr.Project_Type__c;
        this.caseId = rr.Case__c != null ? String.valueOf(rr.Case__c) : '';
        this.caseNumber = rr.Case__c != null ? rr.Case__r.CaseNumber : '';
        this.leadId = rr.Lead__c != null ? String.valueOf(rr.Lead__c) : '';
        this.leadName = rr.Lead__c != null ? rr.Lead__r.Name : '';
        this.accRequests = new List<AccRequestWrapper>();
        this.unspecRequests = new List<UnspecRequestWrapper>();
        this.rrLabelMap = new Map<String, String>();
        this.advRoutingGroups = new List<String>();
        Set<String> rraIds = new Set<String>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();

        if (rr.Reference_Request_Accounts__r != null && rr.Reference_Request_Accounts__r.size() > 0) {

            for (Reference_Request_Account__c accRequest : rr.Reference_Request_Accounts__r) {
                this.accRequests.add(new AccRequestWrapper(accRequest, cs));
                rraIds.add(accRequest.Id);
                
                if (!accRequest.Managed_Request__c) {
                    this.isP2PRequest = true;
                }
            }
        }

        for (Reference_Request_Account_Contact__c rrac : WithoutSharingHelperController.getAccountContactRequests(rraIds)) {
            
            for (AccRequestWrapper rra : this.accRequests) {

                if (rra.accRequestId == rrac.Reference_Request_Account__c) {
                    rra.conRequestId = rrac.Id;
                    rra.contactId = rrac.Contact__c != null ? String.valueOf(rrac.Contact__c) : '';
                    rra.contactName = rrac.Contact__c != null ? rrac.Contact__r.Name : '';
                    rra.phone = rrac.Contact__c != null && rrac.Contact__r.Phone != null ? rrac.Contact__r.Phone : '';
                    rra.email = rrac.Contact__c != null && rrac.Contact__r.Email != null ? rrac.Contact__r.Email : '';
                }
            }
        }

        if (rr.Unspecified_Requests__r != null && rr.Unspecified_Requests__r.size() > 0) {

            for (Unspecified_Request__c unspecRequest : rr.Unspecified_Requests__r) {
                this.unspecRequests.add(new UnspecRequestWrapper(unspecRequest, cs));
            }
        }

        if (rr.Reference_Request_Labels__r != null && rr.Reference_Request_Labels__r.size() > 0) {

            for (Reference_Request_Label__c rrLabel : rr.Reference_Request_Labels__r) {
                this.rrLabelMap.put(rrLabel.Label__c, rrLabel.Id);
            }
        }

        if (rr.Adv_Routing_Group__c != null) {
            
            for (String groupName : rr.Adv_Routing_Group__c.split(',')) {
                this.advRoutingGroups.add(groupName.trim());
            }
        }
    }
}