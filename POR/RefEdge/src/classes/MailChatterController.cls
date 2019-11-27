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
 * Class: MailChatterController 
 * Description : Class used to handle Mail and Chatter
 * Modified by: Rajesh @Feb 14 2017
 */
public with sharing class MailChatterController {
    /**
     * Message use in ReferenceRequestController and  Reminder, Escalation & No Response Batch
     */
    public static String prepareChatterEmailMessage(Date deadlineDate, String accountName, String referenceTypeName, String requestNotes) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = '\nHere are the details:\n\n' + +'Reference Account: ' + accountName + '\n' + 'Use Requested: ' + referenceTypeName + '\n' + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' +ConstantsController.NOTES+ requestNotes + '\n\n';
        return chatterEmailMessage;
    }
    
    /**
     * Message used for chatter and Email content for  Initial notification, Reminder, Escalation
     * Created by : Rajneesh(june 1, 2018)
     * REF-1308
     */ 
    public static String prepareChatterEmailRFContentMessage(String opportunityName, String opportunityStatus) {
        
        String chatterEmailMessage = '\n\n' + +'Opportunity Name: ' + opportunityName + '\n\n';
        return chatterEmailMessage;
    }

    /**
     * Message use in ReferenceRequestController and  Reminder, Escalation & No Response Batch
     */
    public static String prepareEmailMessageForAccountRequestDetail(Date deadlineDate, String accountName, String referenceTypeName, String requestNotes) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = '\nHere are the details:\n\n' + +'<strong>Reference Account:</strong> ' + accountName + '\n' + '<strong>Use Requested:</strong> ' + referenceTypeName + '\n' + '<strong>Need By:</strong> ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' +ConstantsController.NOTES+ requestNotes + '\n\n';
        return chatterEmailMessage;
    }
    
    /**
     * Method to prepare chatter Process Message
     */
    public static String prepareChatterProcessMessage(String header, String accountName, String referenceTypeName, Date deadlineDate, String projectOwner, String oppAccName) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = '\n\n' + header + (oppAccName != ''?'Opportunity Account:'+oppAccName+'\n\n' : '')+'\n\n Account:' + accountName + '\n Request type:' + referenceTypeName + '\nDeadline:' + dateValue.format('EEE, MMMM d, yyyy') + '\nOwner:' + projectOwner + '\n\n';
        return chatterEmailMessage;
    }
    
    /**
     * Method to prepare chatterEmail Message for large Opp
     */
    public static String prepareChatterEmailMessageForLargeOpp(String requester, String accountRequested, String requestType, Date Deadline, String notes) {
        DateTime dateValue;
        
        if (Deadline != null) {
            dateValue = DateTime.newInstance(Deadline.year(), Deadline.month(), Deadline.day());
        }
        String chatterEmailMessage = '\n\nRequester:' + requester + '\n\n Account Requested:' + accountRequested + '\n Request type:' + requestType + '\nAccount Request Deadline:' + dateValue.format('EEE, MMMM d, yyyy') + '\nAccount Request Notes:' + notes + '\n\n';
        return chatterEmailMessage;
    }
    
    /**
     * Message use in SelectRefUseContactsController for Approve & Decline
     */
    public static String getChatterApproveMessage(String accName,Reference_Request_Account__c refReqAccount, List<Reference_Request_Account_Contact__c> lstRRAC, Map<Id, String> mapContacts) {
        String chatterMessage = 'I have approved your Reference Use Request for a ' + refReqAccount.Reference_Type_Needed__r.Name +
            '.  Here are the details:\n\n' +
            ' Opportunity Account: ' + (accName != null ? accName : 'None') + '\n' +
            ' Reference Account: ' + refReqAccount.Account__r.Name + '\n' +
            getApproveMessageContactsDetalis(lstRRAC, mapContacts) +
            ' Request Notes:  ' + refReqAccount.Approve_Deny_Notes__c;
        return chatterMessage;
    }
    
    /**
     * Method to get Appreve Message Contact Details from Lightning page
     */
    public static String getApproveMessageContactsDetalis(List<Reference_Request_Account_Contact__c> lstRRAC, Map<Id, String> mapContacts) {
        String contactDetails = '';
        
        if (lstRRAC.size() > 0) {
            
            for (Reference_Request_Account_Contact__c rrac: lstRRAC) {
                contactDetails += ' Contact: ' + mapContacts.get(rrac.Contact__c) + '\n' + ' Title: ' + rrac.Contact_Title__c + '\n' + ' Email: ' + rrac.Contact_Email__c + '\n' + ' Phone: ' + rrac.Contact_Phone__c + '\n\n';
            }
        } else {
            contactDetails += 'Contact: No contact selected.\n\n';
        }
        return contactDetails;
    }
    
    /**
     * Method to get Chatter Decline Message
     */
    public static String getChatterDeclineMessage(Reference_Request_Account__c refReqAccount) {
        String chatterMessage = 'I have declined your Reference Use Request for a ' + refReqAccount.Reference_Type_Needed__r.Name + '.  Here are the details:\n\n' + ' Reference Account: ' + refReqAccount.Account__r.Name + '\n' + ' Type: ' + refReqAccount.Reference_Type_Needed__r.Name + '\n\n' + ' Request Notes:  ' + refReqAccount.Approve_Deny_Notes__c + '\n';
        return chatterMessage;
    }

    /**
     * Message use in AutomaticReferenceFeedbackBatch 
     */
    public static String getChatterFeedbackMessage(Reference_Request_Account_Contact__c refReqAccountContact) {
        Date d = (Date) refReqAccountContact.Reference_Request_Account__r.Deadline__c;
        DateTime dtValue = DateTime.newInstance(d.year(), d.month(), d.day());
        String chatterMessage = 'Could you please provide feedback on how the ' + refReqAccountContact.Reference_Request_Account__r.Reference_Type_Needed__r.Name + ' reference use went with ' + refReqAccountContact.Reference_Request_Account__r.Account__r.Name + ' that was scheduled for ' + dtValue.format('EEE, MMMM d, yyyy') + '? \n\n';
        return chatterMessage;
    }
    
    /**
     * Message use in ReferenceUseFeedbackController 
     */
    public static String getFeedbackResponseMessage(String selectedFeedbackOption, Reference_Request_Account_Contact__c refReqAccountContact, DateTime oldDeadlineDateValue, String feedbakResponse) {
        //New Deadline value for New scheduled use
        Date newDeadlineDate = (Date) refReqAccountContact.Reference_Request_Account__r.Deadline__c;
        DateTime newDeadlineDateVale;
        
        if (newDeadlineDate != null) {
            newDeadlineDateVale = DateTime.newInstance(newDeadlineDate.year(), newDeadlineDate.month(), newDeadlineDate.day());
        }
        //Prepare Chatter & Task String
        String chatterTaskMessage = ' I have provided feedback on how the ' + refReqAccountContact.Reference_Request_Account__r.Reference_Type_Needed__r.Name +
            ' reference use went for ' + refReqAccountContact.Reference_Request_Account__r.Account__r.Name +
            ' that was scheduled for ' + oldDeadlineDateValue.format('EEE, MMMM d, yyyy') + '\n\n' +
            ' Status: ' + selectedFeedbackOption + '\n';

        if (selectedFeedbackOption == ConstantsController.FEEDBACK_SUCCESSFUL) {
            //If Any need for successful    
        } else if (selectedFeedbackOption == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
            chatterTaskMessage += 'Comments on unsuccessful use: ' + feedbakResponse;
        } else if (selectedFeedbackOption == ConstantsController.FEEDBACK_NOT_OCCUR) {
            //If Any need for notoccur      
        } else if (selectedFeedbackOption == ConstantsController.FEEDBACK_YET_NOT_COMPLETED) {
            chatterTaskMessage += 'New scheduled use:  ' + newDeadlineDateVale.format('EEE, MMMM d, yyyy');
        }
        return chatterTaskMessage;
    }

    /**
     * Message use for Project Owner Changed for RRA and UR
     */
    public static String prepareChatterEmailOwnerMessage(String RequestName, String AccountName, String RefTypeName, String RequestStatus, 
                                                                                    Date deadlineDate, String RequestNotes, String projectOwner,string oppAccName) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = '-------------------------\n' + projectOwner + ' is now managing your  Request\n' + '-------------------------\n' + (oppAccName != ''?'Opportunity Account:'+oppAccName+'\n' : '')+'Reference Account: ' + AccountName + '\n' + 'Use Requested: ' + RefTypeName + '\n' + 'Status: ' + RequestStatus + '\n' + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' + 'Request Notes:\n' + RequestNotes + '\n\n';
        return chatterEmailMessage;
    }

    /**
     * Message use for status Changed for RRA and UR
     */
    public static String prepareChatterEmailStatusMessage(String RequestName, String AccountName, String RefTypeName, String RequestStatus, Date deadlineDate, String RequestNotes, String approveDenyNotes, String oppAccName) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = null;
        
        if (!RequestStatus.equals(ConstantsController.NO_REFERENCE_MATCH)) {
            chatterEmailMessage = 'The status of your request has changed.\n' + (oppAccName != ''?'Opportunity Account:'+oppAccName+'\n' : '')+'Reference Account: ' + AccountName + '\n' + 'Use Requested: ' + RefTypeName + '\n' + '-------------------------\n' + 'Status: ' + RequestStatus + '\n' + '-------------------------\n' + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' + 'Request Notes:\n' + RequestNotes + '\n\n';
        } else {
            chatterEmailMessage = System.Label.NO_REFERENCE_MATCH+ '\n' + 'Status: ' + RequestStatus + '\n-------------------------\n' + (oppAccName != ''?'Opportunity Account:'+oppAccName+'\n' : '')+'Reference Account: ' + AccountName + '\n' + 'Use Requested: ' + RefTypeName + '\n'  + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' + 'Request Notes:\n' + RequestNotes + '\n\n';
        }        
        return chatterEmailMessage;
    }

    /**
     * Message use for Project Owner & status Changed for RRA and UR
     */
    public static String prepareChatterEmailOwnerStatusMessage(String RequestName, String AccountName, String RefTypeName, String RequestStatus, Date deadlineDate, String RequestNotes, String approveDenyNotes, String projectOwner,String oppAccName) {
        DateTime dateValue = DateTime.newInstance(deadlineDate.year(), deadlineDate.month(), deadlineDate.day());
        String chatterEmailMessage = null;
        
        if (RequestStatus.equals(ConstantsController.NO_REFERENCE_MATCH)) {
            chatterEmailMessage = System.Label.NO_REFERENCE_MATCH + '\nStatus: ' + RequestStatus + '\n' + '-------------------------\n' +(oppAccName != ''?'Opportunity Account:'+oppAccName+'\n' : '')+ 'Reference Account: ' + AccountName + '\n' + 'Use Requested: ' + RefTypeName + '\n' + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' + 'Request Notes:\n' + RequestNotes + '\n\n';
        } else {
            chatterEmailMessage = '-------------------------\n' + projectOwner + ' is now managing your  Request\n' + 'Status: ' + RequestStatus + '\n' + '-------------------------\n' + (oppAccName != ''?'Opportunity Account:'+oppAccName+'\n' : '')+'Reference Account: ' + AccountName + '\n' + 'Use Requested: ' + RefTypeName + '\n' + 'Need By: ' + dateValue.format('EEE, MMMM d, yyyy') + '\n\n' + 'Request Notes:\n' + RequestNotes + '\n\n';
        }
        return chatterEmailMessage;
    }

    /**
     * Method to Prepare FeedItem for Post
     */
    public static FeedItem preparePost(String postTitle, String postParentId, String postBody, String linkUrl) {
        FeedItem post = new FeedItem();
        
        if (postTitle.trim().length() != 0) {
            post.Title = postTitle;
            
            if (linkUrl != 'null' && linkUrl.trim() != '') {
                post.LinkUrl = linkUrl;
            }
        }
        post.ParentId = postParentId;
        post.Body = postBody;
        return post;
    }

    /**
     * Method to Prepare FeedItem for Post for ReferenceEdge User
     */
    public static FeedItem preparePostForRefedgeUser(String postTitle, String postParentId, String postBody, String linkUrl, String userId) {
        FeedItem post = new FeedItem();
        
        if (postTitle.trim().length() != 0) {
            post.Title = postTitle;
            
            if (linkUrl != 'null') {
                post.LinkUrl = linkUrl;
            }
        }
        
        // sending the chatter post as the RefEdge user
        // done to fix the installation error when installing the package with chatter disabled
        if (userId != null && userId != '') {
            post.put('CreatedById', userId);
        }
        post.ParentId = postParentId;        
        post.Body = postBody;
        return post;
    }
    
    /**
     * Method to Prepare FeedItem for Post for Sales rewards //ReferenceEdge user is used as sender regarding #486
     */
    public static FeedItem preparePostForReward(String postTitle, String postParentId,Decimal rewardPoints,String rewardAction, String linkUrl) {
        FeedItem post = new FeedItem();
        
        if (postTitle.trim().length() != 0) {
            post.Title = postTitle;
            
            if (linkUrl != 'null') {
                post.LinkUrl = linkUrl;
            }
        }
        post.ParentId = postParentId;
        post.Body = 'Congratulations, you just earned '+rewardPoints+' points for your recent reference activity!';
        return post;
    }
    
    /**
     * Method to Prepare Email wth CC
     * author: Gaurav Saini (29 Oct, 2018) for REF-1862
     */
    public static Messaging.SingleEmailMessage prepareCCEmail(String subject, String toAddress, String ccAddress, String htmlBody,
                                                    String headerDocId, String footerDocId) {  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        String[] toAddresses = new String[] {
            toAddress
        };
        String[] ccAddresses = new String[] {
            ccAddress
        };
        //ReferenceEdge user is used as sender regarding #486
        mail.setSenderDisplayName('ReferenceEdge');
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setHtmlBody(setHtmlEmailBody(htmlBody, headerDocId, footerDocId));
        mail.setSaveAsActivity(false);
        return mail;
    }
    
    /**
     * Method to Prepare Email wth CC
     */
    public static Messaging.SingleEmailMessage prepareCCEmail(String subject, String toAddress, String ccAddress, String htmlBody) {  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject(subject);
        String[] toAddresses = new String[] {
            toAddress
        };
        String[] ccAddresses = new String[] {
            ccAddress
        };
        //ReferenceEdge user is used as sender regarding #486
        mail.setSenderDisplayName('ReferenceEdge');
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setHtmlBody(setEmailTemplateBody(htmlBody));
        mail.setSaveAsActivity(false);
        return mail;
    }
    
    /**
     * Method to Prepare email from dynamic template
     * author: Gaurav Saini (24 Oct, 2018) for REF-1862
     */
    public static Messaging.SingleEmailMessage prepareEmail(String subject, String targetObjId, String htmlBody, Boolean isRefLead,
                                                        String headerDocId, String footerDocId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjId);

        if (isRefLead) {
            mail.setSenderDisplayName('ReferenceEdge');
        }
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHtmlBody(setHtmlEmailBody(htmlBody, headerDocId, footerDocId));
        return mail;
    }

    /**
     * Method to set Email Template body
     * author: Gaurav Saini (24 Oct, 2018) for REF-1862
     */
    public static String setHtmlEmailBody(String body, String headerDocId, String footerDocId) {
        String siteUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String result = '<div style="background-color:#FFFFFF">'
                + '<center><table height="500" width="550" cellpadding="0" cellspacing="0">'
                    + '<tbody>';
        
        if (headerDocId != null && headerDocId != '') {
            result += '<tr valign="top">'
                        + '<td style="vertical-align:top;height:40px;text-align:left;background-color:#ffffff;padding-left: 5px;">'
                            + '<img src="' + siteUrl + '/servlet/servlet.ImageServer?id=' + headerDocId + '&oid=' + UserInfo.getOrganizationId() + '" alt="Company Header Logo" />'
                        + '</td>'
                    + '</tr>';
        }
        result += '<tr valign="top">'
                    + '<td style="height:2px;background-color:#e7e7e7"></td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td height="350" style="color:#000000;font-size:9pt;background-color:#ffffff;font-family:arial">'
                        + '<div style="text-align:left;font-family: arial;font-size: 9pt;padding: 10px;"><br />' + body.replaceAll('\n', '<br />') + '</div>'
                    + '</td>'
                + '</tr>'
                + '<tr valign="top">'
                    + '<td style="height:2px;background-color:#e7e7e7"></td>'
                + '</tr>';
        
        if (footerDocId != null && footerDocId != '') {
            result += '<tr valign="top">'
                        + '<td style="vertical-align:top;height:40px;text-align:left;background-color:#ffffff;padding-left: 5px;">'
                            + '<img src="' + siteUrl + '/servlet/servlet.ImageServer?id=' + footerDocId + '&oid=' + UserInfo.getOrganizationId() + '" alt="Company Footer Logo" />'
                        + '</td>'
                    + '</tr>';
        }
        result += '</tbody>'
                    + '</table></center><br /><br />'
                + '</div>';
        return result;
    }
    
    /**
     * Method to Prepare Email
     */
    public static Messaging.SingleEmailMessage prepareEmail(String subject, String targetObjId, String htmlBody, Boolean isRefLead) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjId);
        
        if (isRefLead) {
            mail.setSenderDisplayName('ReferenceEdge');
        }
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHtmlBody(setEmailTemplateBody(htmlBody));
        return mail;
    }
    /**
     * Method to prepare body for the Reference Refresh
     */
    public static String prepareBodyForRefRefresh(Set<String> accountNames, String notificationBody, String ownerId, String subject, Boolean forSlack) {
        List<String> allAccounts = new List<String>();
        allAccounts.addAll(accountNames);
        allAccounts.sort();
        Integer i = 1;
        
        for (String accName: allAccounts) {
            
            if (i <= 3) {
                notificationBody += accName + '\n';
            } else {
                break;
            }
            ++i;
        }
        String RefRefreshURL = URL.getSalesforceBaseUrl().toExternalForm() + Page.ReferenceRefreshPageSLDS.getURL() + '?userId=' + ownerId;

        if (!forSlack) {
            notificationBody += '\n\n' + subject + ': <a href="' + RefRefreshURL + '">' + RefRefreshURL + '</a>';
        } else {
            notificationBody += '\n\n' + '\n<' + RefRefreshURL + '|' + subject + '>';
        }
        return notificationBody;
    }
    
    /**
     * Method to prepare body for the Sales reward notification
     */
    public static String prepareBodyRewardNotification(String ownerName,decimal rewardPoints,String actionPerformed) { 
        
        String body = 'Hi ' + ownerName + ',\n\n Congratulations, you just earned '+rewardPoints+' points your recent reference activity!';
        
        body += '\n\nThank you for your attention!\n\n';
        
        String htmlBody = setEmailTemplateBody(body);
        return htmlBody;
    }
    
    public static Messaging.SingleEmailMessage prepareRewardEmail(String subject, Id targetObjId, String username, Decimal rewardsPoints, String action) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(targetObjId);
        mail.setSaveAsActivity(false);
        mail.setSubject(subject);
        mail.setHtmlBody(prepareBodyRewardNotification(username, rewardsPoints, action));
        return mail;
    }
     
    /**
     * Method to prepare body for the Reference Refresh
     */
    public static FeedItem preparechatterForRefRefresh(Set<String> accountNames, String ownerId, String postBody, String postTitle) {
        List<String> allAccounts = new List<String>();
        allAccounts.addAll(accountNames);
        allAccounts.sort();
        Integer i = 1;
        
        for (String accName : allAccounts) {
            
            if (i <= 3) {
                postBody += accName + '\n';
            } else {
                break;
            }
            ++i;
        }
        String RefRefreshURL = URL.getSalesforceBaseUrl().toExternalForm() + Page.ReferenceRefreshPageSLDS.getURL() + '?userId=' + ownerId;
        FeedItem post = new FeedItem();
        
        if (postTitle.trim().length() != 0) {
            post.Title = postTitle;
            
            if (RefRefreshURL != 'null') {
                post.LinkUrl = RefRefreshURL;
            }

        }
        post.ParentId = ownerId;
        post.Body = postBody;
        return post;
    }

    /**
     * Method to prepare body for the Reference Refresh
     */
    public static FeedItem preparechatterForRefRefreshUpdate(String postBody, String RefRefreshURL, String ownerId) {
        FeedItem post = new FeedItem();
        post.Title = 'Review Update(s)';
        
        if (RefRefreshURL != 'null') {
            post.LinkUrl = RefRefreshURL;
        }
        post.ParentId = ownerId;
        post.Body = postBody;
        return post;
    }

    /**
     * Method to set Email Template body
     */
    public static String setEmailTemplateBody(String body) {
        String siteUrl = URL.getSalesforceBaseUrl().toExternalForm(); //#430 by rekha
        return '<div style="background-color:#FFFFFF"><center><table height="500" width="550" cellpadding="0" cellspacing="0"><tbody><tr valign="top"><td style="vertical-align:top;height:40px;text-align:left;background-color:#ffffff;padding-left: 5px;"><img src="' + siteUrl + '/servlet/servlet.ImageServer?id=' + UtilityController.getCompanyLogo() + '&oid=' + UserInfo.getOrganizationId() + '"alt="Company Header Logo"/></td></tr><tr valign="top"><td style="height:2px;background-color:#e7e7e7"></td></tr><tr valign="top"><td height="350" style="color:#000000;font-size:9pt;background-color:#ffffff;font-family:arial"><div style="text-align:left;font-family: arial;font-size: 9pt;padding: 10px;"><br/>' + body.replace('\n', '<br></br>') + '</div></td></tr><tr valign="top"><td style="height:2px;background-color:#FFFFFF"></td></tr><tr valign="top"><td style="vertical-align:bottom;text-align:right;background-color:#ffffff"></td></tr></tbody></table></center><br><br></div>';
    }
    
    /**
     * Method to Prepare New Task
     */
    public static Task prepareTask(String OwnerId, String WhatId, Date deadlineDate, String subject, String taskBody, String refReqAccountContactId) {
        Task task = new Task();
        task.OwnerId = OwnerId;
        task.WhatId = WhatId;
        task.ActivityDate = deadlineDate;
        task.Subject = subject;
        task.Description = taskBody;
        task.IsReminderSet = true;
        task.Priority = ConstantsController.NORMAL;
        task.Status = ConstantsController.NOT_STARTED;
        task.Reference_Request_Account_Contact_Id__c = refReqAccountContactId;
        return task;
    }

    /**
     * Method to Prepare Email in term of EmailMessage Wrapper Class 
     */
    public static EmailMessage prepareEmailMessage(String subject, String targetObjectId, String htmlBody, String linkUrl) {
        EmailMessage mail = new EmailMessage();
        mail.subject = subject;
        mail.targetObjectId = targetObjectId;
        mail.body = htmlBody + linkUrl;
        return mail;
    }

    /**
     * Prepare CC Mails
     */
    public static EmailMessage prepareCCEmailMessage(String subject, String toAddress, String ccAddress, String htmlBody, String linkUrl) {
        EmailMessage mail = new EmailMessage();
        mail.subject = subject;
        mail.toAddress = toAddress;
        mail.ccAddress = ccAddress;
        mail.body = htmlBody + linkUrl;
        return mail;
    }
    /**
     * Method to prepare chatterEmail message for Account/Contact
     */
    public static String prepareChatterEmailMessageForAccountContact(String accountName, String ownerName, String contactName, String ref) {
        String chatterEmailMessage;
        
        if (contactName != '') {
            chatterEmailMessage = 'A new Contact has been nominated to the Reference Program.\n\n' + +'Contact: ' + contactName + '\n' + 'Account: ' + accountName + '\n' + 'Nominated By: ' + ownerName + '\nReferenceability: '+(ref != null ? ref : '')+'\n\n';
        } else {
            chatterEmailMessage = 'A new Account has been nominated to the Reference Program.\n\n' + +'Account: ' + accountName + '\n' + 'Nominated By: ' + ownerName + '\nReferenceability: '+(ref != null ? ref : '')+ '\n\n';
        }
        return chatterEmailMessage;
    }
    
    /**
     * Message use in ReferenceRequestController and  Reminder, Escalation & No Response Batch for Advance Routing #442 
     */
    public static String prepareChatterEmailMessageForAdvanceRouting(String body, Map<String, String> filterAttributesMap) {
        String filterAttsString = '';
        
        if (filterAttributesMap != null && filterAttributesMap.size() > 0) {
            
            for (String filterName : filterAttributesMap.keySet()) {
                filterAttsString = filterAttsString + filterName + ': ' + filterAttributesMap.get(filterName) + '\n';
            }
            body = body.replace('[Selected Filter Attributes]', filterAttsString);
        } else {
            body = body.replace('[Selected Filter Attributes]\n', '');
        }
        return body;
    }
    
    /**
     * Email Wrapper Class
     */
    public class EmailMessage {
        /**
         * Properties and variables
         */
        public String subject { get; set; }
        public String targetObjectId { get; set; }
        //For cc Mail
        public String toAddress { get; set; }
        public String ccAddress { get; set; } 
        public String body { get; set; }
        public EmailMessage() {}
    }
}