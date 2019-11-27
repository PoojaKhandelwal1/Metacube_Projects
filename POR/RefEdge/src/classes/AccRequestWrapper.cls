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
public class AccRequestWrapper {
        public String accRequestId { get; set; }
        public String accRequestName { get; set; }
        public String accountId { get; set; }
        public String accountName { get; set; }
        public String requestStatus { get; set; }
        public String deadline { get; set; }
        public String refTypeId { get; set; }
        public String refTypeName { get; set; }
        public String process { get; set; }
        public String reqNotes { get; set; }
        public String emailNotes { get; set; }
        public String ownerId { get; set; }
        public String ownerName { get; set; }
        public String refOwnerId { get; set; }
        public String addInfoId { get; set; }
        public Boolean isManaged { get; set; }
        public String conRequestId { get; set; }
        public String contactId { get; set; }
        public String contactName { get; set; }
        public String phone { get; set; }
        public String email { get; set; }
        public String deadlineColor { get; set; }
        //REF-1964
        public String challengeId { get; set; }
        public String challengeStatus { get; set; }

        public AccRequestWrapper(Reference_Request_Account__c ar, Custom_Settings__c cs) {
            this.accRequestId = ar.Id;
            this.accRequestName = ar.Name;
            this.accountId = ar.Account__c != null ? String.valueOf(ar.Account__c) : '';
            this.accountName = ar.Account_f__c != null ? String.valueOf(ar.Account_f__c) : '';
            this.requestStatus = ar.Account_Request_Status__c;
            this.deadline = ar.Deadline__c != null ? ar.Deadline__c.format() : '';
            this.refTypeId = ar.Reference_Type_Needed__c != null ? String.valueOf(ar.Reference_Type_Needed__c) : '';
            this.refTypeName = ar.Reference_Type_Needed_f__c != null ? String.valueOf(ar.Reference_Type_Needed_f__c) : '';
            this.process = ar.Process__c;
            this.reqNotes = ar.Request_Notes__c != null ? ar.Request_Notes__c : '';
            this.emailNotes = ar.Approve_Deny_Notes__c != null ? ar.Approve_Deny_Notes__c : '';
            this.refOwnerId = ar.Reference_Owner__c != null ? String.valueOf(ar.Reference_Owner__c) : '';
            this.ownerId = ar.Project_Owner__c != null ? String.valueOf(ar.Project_Owner__c) : '';
            this.ownerName = ar.Project_Owner__c != null ? ar.Project_Owner__r.Name : '';
            this.addInfoId = ar.Reference_Request_Additional_Info__c != null ? String.valueOf(ar.Reference_Request_Additional_Info__c) : '';
            this.isManaged = ar.Managed_Request__c;
            this.conRequestId = '';
            this.contactId = '';
            this.contactName = '';
            this.phone = '';
            this.email = '';
            Date criticalDate = Date.today().addDays(Integer.valueOf(cs.Critical_Deadline_window__c));
            Date cautionDate = Date.today().addDays(Integer.valueOf(cs.Caution_Deadline_window__c));

            if (ar.Deadline__c <= criticalDate) {
                this.deadlineColor = '#DD0000';
            } else if (ar.Deadline__c > criticalDate && ar.Deadline__c <= cautionDate) {
                this.deadlineColor = '#FFCC00';
            } else if (ar.Deadline__c > cautionDate) {
                this.deadlineColor = '#00CC00';
            }
            //REF-1964
       	 	this.challengeId = ar.Influitive_Challenge_Id__c != null ? String.valueOf(ar.Influitive_Challenge_Id__c) : '';
        	this.challengeStatus = ar.Influitive_Challenge_Status__c != null ? String.valueOf(ar.Influitive_Challenge_Status__c) : '';
        }
    }