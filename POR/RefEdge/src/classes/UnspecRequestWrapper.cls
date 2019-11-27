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
public class UnspecRequestWrapper {
    public String unspecRequestId { get; set; }
    public String unspecRequestName { get; set; }
    public String deadline { get; set; }
    public String refTypeId { get; set; }
    public String refTypeName { get; set; }
    public String requestStatus { get; set; }
    public String addInfoId { get; set; }
    public String emailNotes { get; set; }
    public String reqNotes { get; set; }
    public String deadlineColor { get; set; }
    public String ownerId { get; set; }
    public String ownerName { get; set; }
    //REF-1964
    public String challengeId { get; set; }
    public String challengeStatus { get; set; }

    public UnspecRequestWrapper(Unspecified_Request__c ur, Custom_Settings__c cs) {
        this.unspecRequestId = ur.Id;
        this.unspecRequestName = ur.Name;
        this.deadline = ur.Deadline__c != null ? ur.Deadline__c.format() : '';
        this.refTypeId = ur.Reference_Type_Needed__c != null ? String.valueOf(ur.Reference_Type_Needed__c) : '';
        this.refTypeName = ur.Reference_Type_Needed_f__c != null ? String.valueOf(ur.Reference_Type_Needed_f__c) : '';
        this.requestStatus = ur.Unspecified_Request_Status__c;
        this.addInfoId = ur.Reference_Request_Additional_Info__c != null ? String.valueOf(ur.Reference_Request_Additional_Info__c) : '';
        this.emailNotes = ur.Notes__c != null ? ur.Notes__c : '';
        this.reqNotes = ur.Request_Notes__c != null ? ur.Request_Notes__c : '';
        this.ownerId = ur.Project_Owner__c != null ? String.valueOf(ur.Project_Owner__c) : '';
        this.ownerName = ur.Project_Owner__c != null ? ur.Project_Owner__r.Name : '';
        Date criticalDate = Date.today().addDays(Integer.valueOf(cs.Critical_Deadline_window__c));
        Date cautionDate = Date.today().addDays(Integer.valueOf(cs.Caution_Deadline_window__c));

        if (ur.Deadline__c <= criticalDate) {
            this.deadlineColor = '#DD0000';
        } else if (ur.Deadline__c > criticalDate && ur.Deadline__c <= cautionDate) {
            this.deadlineColor = '#FFCC00';
        } else if (ur.Deadline__c > cautionDate) {
            this.deadlineColor = '#00CC00';
        }
        //REF-1964
        this.challengeId = ur.Influitive_Challenge_Id__c != null ? String.valueOf(ur.Influitive_Challenge_Id__c) : '';
        this.challengeStatus = ur.Influitive_Challenge_Status__c != null ? String.valueOf(ur.Influitive_Challenge_Status__c) : '';
    }
}