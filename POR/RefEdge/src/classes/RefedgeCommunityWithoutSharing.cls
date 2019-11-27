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
public without sharing class RefedgeCommunityWithoutSharing {
	/**
     * Properties and variables for common controllers
     */
	public static list<Reference_Basic_Information__c> getReferenceProfileContactList(string contactId){
        return [Select Is_Referenceable__c,Account__c, Referenceability_Status__c, Lifetime_Points__c,Roll_up_Referenceability_to_All_Accounts__c,Roll_up_Referenceability_to_Primary_Acc__c From Reference_Basic_Information__c where Contact__c =: contactId];
    }
    
    public static list<Reference_Basic_Information__c> getReferenceProfileAccountList(string accountId){
        return [Select Current_Available_Balance_Points__c From Reference_Basic_Information__c where Contact__c = null AND Account__c =: accountId];
    }
    
    /**
     * Properties and variables for RefedgeCommunityActivityHistory controller
     */
    public static list<Reference_Request_Account_Contact__c> getRRACList(string contactId){
        return [Select Reference_Request_Account__r.Activity_Date__c, Referenceability_Type__r.Name, Referenceability_Type__r.Reward_points__c, Reference_Request_Account__r.Reference_Request__c, Reference_Request_Account__r.Reference_Request__r.Account_Name_f__c, Reference_Request_Account__r.Reference_Request__r.Opportunity_Stage_f__c From Reference_Request_Account_Contact__c where Contact__c = :contactId];
    }
    
    public static map<Id, Reference_Request__c> getReferenceRequestMap(set<string> setRRIds){
        return new map<Id, Reference_Request__c>([Select Account_Name_f__c, Opportunity_Stage_f__c From Reference_Request__c where Id IN : setRRIds]);
    }
    
    /**
     * Properties and variables for RefedgeCommunityHome controller
     */
     public static Custom_Settings__c getCustomSettings() {
        list < Custom_Settings__c > lstCustomSettings = [SELECT Community_Home_Text__c, Community_Ref_Activities_Message__c FROM Custom_Settings__c Where Active_Version__c = true order by Current_Version__c DESC limit 1];
        if (lstCustomSettings.size() > 0) {
            return lstCustomSettings[0];
        } 
        return new Custom_Settings__c();
    }
     
    public static list<Community_News__c> getCommunityNewsList(){
        return [select Name,Id,Featured__c,News_Body__c,Show_on_Home_Page__c,CreatedDate from Community_News__c where Show_on_Home_Page__c = true order by Featured__c desc,CreatedDate  desc];
    }
    
    /**
     * Properties and variables for RefedgeCommunityNews controller
     */
    public static list<Community_News__c> getRefedgeCommunityNews(string newsId){
        return [Select Name,Id,Featured__c,News_Body__c,Show_on_Home_Page__c from Community_News__c where Id =:newsId];
    }
    
    public static list<Community_News__c> getRefedgeCommunityNewsList(string newsId){
        return [Select Name,Id,Featured__c,News_Body__c,Show_on_Home_Page__c from Community_News__c where Id !=:newsId and Show_on_Home_Page__c = true order by CreatedDate DESC];
    }
    
    /**
     * Properties and variables for RefedgeCommunityProfile controller
     */
    public static List<Referenceability_Type__c> getReferenceabilityType(){
        return [SELECT Id, Name, Referenceability_Type__c FROM Referenceability_Type__c WHERE Visible__c = true AND Referenceability_Type__c = true ORDER BY Name];
    }
    
    public static list<Contact> getContacts(string contactId){
        return [select Id,Name,AccountId,Account.Name,FirstName,LastName,Title,Birthdate,Phone,MobilePhone,Email, MailingStreet,MailingCity,MailingLongitude,MailingLatitude,MailingState,MailingCountry,MailingPostalCode,
                        (select Id, Status__c, Referenceability_Type__c, Referenceability_Type__r.Id from Referenceabilities__r where Status__c != null)
                        from Contact where Id =:contactId];
    }
    
    public static void updateContact(Contact contact){
        update contact;
    }
    
    public static void upsertReferenceability(list<Referenceability__c> upsertReferenceabilities){
        upsert upsertReferenceabilities;
    }
    
    /**
     * Properties and variables for RefedgeCommunityParticipate controller
     */
    public static list<Referenceability__c> getReferenceabilities(string contactId){
        return [select Id, Referenceability_Type__c from Referenceability__c where Contact__c = : contactId and Status__c = 'Approved'];
    }
    public static map<string,string> getRefImages(set<string> refIds){
        map<string,string> refImages = new map<string,string>();
        for(Attachment att : [SELECT Id,parentId FROM Attachment WHERE parentId IN :refIds AND name = 'communityPic.jpg']){
        	refImages.put(att.parentId,att.Id);
        }
        return refImages;
    }
    public static list<Community_Invite__c> getCommunityInvites(string contactId, set<string> CommunityInviteIds){
        return [select Community_Participate_Deadline__c, Name, Community_Yes__c, Community_Participate_Details__c, Community_Participate_With__c, Referenceability_Type__c, Referenceability_Type__r.Name,
        			 Referenceability_Type__r.Reward_points__c, Referenceability_Type__r.Icon__c,
			        (select Id, Response__c,Community_Invite__c, Contact__c from Community_Invite_Contacts__r where Contact__c = : contactId), 
			        (select Id from Hit_Lists__r),(select Id from Account_Requests__r), (select Id from Unspecified_Requests__r)
			        from Community_Invite__c where Id IN :CommunityInviteIds];
    }
    public static list<Community_Invite_Contact__c> getCommunityInviteContacts(string contactId){
        return [select Id, Response__c,Community_Invite__c, Contact__c from Community_Invite_Contact__c where Contact__c = : contactId and Response__c = null];
    }
    public static void upsertCommunityInviteContact(list<Community_Invite_Contact__c> newCICrecords){
        upsert newCICrecords;
    }
    //Shared Contact code start
    public static set<string> getRelatedAccounts(String contactId,Custom_Settings__c cs){
		set<string> contactAccountset = new set<string>();
		if(cs == null)
			cs = UtilityController.getCustomSettings();
		if(cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != ''){
			String objectName = cs.Shared_Contact_Object__c;
	        String accountField = cs.Shared_Account_Field__c;
	        String contactField = cs.Shared_Contact_Field__c;
	        String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	        						 + ' WHERE ' + contactField + ' = \''+contactId+'\'';
	        List<sObject> objectList = Database.query(query);
	        if (objectList != null && objectList.size() > 0) {
	    		for (sObject obj : objectList) {
	    			contactAccountset.add((String)obj.get(accountField));
	    		}
	        }
		}
		return contactAccountset;
    }
    //end
}