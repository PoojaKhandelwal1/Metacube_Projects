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
public abstract class RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private static Map < String, Boolean > mapFeatures;
    private static String editionName;
    private static POR_App_Configuration__c cs;
    private static boolean alreadygotEdition = false;
    /**
     * getter for page accessible or not
     */
    public Boolean IsPageAccessible {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            getEditionFeatures();
            String pageUrl = Apexpages.currentPage().getURL();
            String pageName = pageUrl.substringAfter('apex/');
            if (pageName.contains('?'))
                pageName = pageName.substringBefore('?');
            if (pageName.contains(UtilityController.appNamespace()))
                pageName = pageName.substringAfter(UtilityController.appNamespace());
            pageName = pageName.toLowerCase();
            if (mapFeatures.get(pageName) != null)
                return mapFeatures.get(pageName);
            else
                return false;
        }
    }
    
    /**
     * getter for full license accessible or not 
     */
    public Boolean isFullLicenseAccessible {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if(editionName == 'Basic' || editionName == 'Pro'){
            	return true;
            }
            else if(editionName == 'PROwithCommunities'){
            	string numberOfLicense = RefEdgeDecodingClass.getLicenseNumber(cs.Edition_Key__c);
		        String[] licenses = numberOfLicense.split('###');
		        Integer refedgeAllowdLicense = Integer.valueOf(licenses[0]);
		        if(refedgeAllowdLicense != 0 && refedgeAllowdLicense < 0){
		        	return true;
		        }
		        else {
		            User currentUser = [SELECT Refedge_License_Type__c FROM User WHERE Id =: Userinfo.getuserId()];
		            return (currentUser.Refedge_License_Type__c != null && currentUser.Refedge_License_Type__c == 'Full License');
		        }
            }
            else {
            	return false;
            }
        }
    }
    
    /**
     * getter for community license accessible or not
     */
    public Boolean isCommunityLicenseAccessible {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if(editionName == 'PROwithCommunities'){
            	string numberOfLicense = RefEdgeDecodingClass.getLicenseNumber(cs.Edition_Key__c);
		        String[] licenses = numberOfLicense.split('###');
		        Integer communityAllowdLicense = Integer.valueOf(licenses[1]);
		        if(communityAllowdLicense != 0 && communityAllowdLicense < 0){
		        	return true;
		        }
		        else {
		            User currentUser = [SELECT Refedge_License_Type__c FROM User WHERE Id =: Userinfo.getuserId()];
		            return (currentUser.Refedge_License_Type__c != null && currentUser.Refedge_License_Type__c == 'Community License');
		        }
            }
            else{
            	return false;
            }
        }
    }
    
    /**
     * getter for basic edition
     */
    public static Boolean isBasic {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if (editionName == 'Basic') {
                return true;
            } else
                return false;
        }
        private set;
    }
    /**
     * getter for PRO edition
     */
    public static Boolean isPro {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if (editionName == 'Pro') {
                return true;
            } else
                return false;
        }
        private set;
    }
    /**
     * getter for PRO with Community edition
     */
    public static Boolean isProCom {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if (editionName == 'PROwithCommunities') {
                return true;
            } else
                return false;
        }
        private set;
    }
    /**
     * getter for enterprise edition
     */
    public static Boolean isEnterprise {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if (editionName == 'Enterprise') {
                return true;
            } else
                return false;
        }
        private set;
    }
    /**
     * getter for enterprise with community edition
     */
    public static Boolean isEnterpriseCom {
        get {
            if(!alreadygotEdition){
            	getEdition();
            	alreadygotEdition = true;
            }
            if (editionName == 'EnterprisewithCommunities') {
                return true;
            } else
                return false;
        }
        private set;
    }
    /**
     * Method to get editions
     */
    private static void getEdition() {
        if (Test.isRunningTest()) {
            editionName = 'Pro';
        } else {
            cs = POR_App_Configuration__c.getOrgDefaults();
            string editioncode = '';
            if (cs.Edition_Key__c != null && cs.Edition_Key__c != '')
                editioncode = refEdgeDecodingClass.getDecodedData(cs.Edition_Key__c);
            if (editioncode == RefEdgeEditionConstants.ENTERPRISECOM) {
                editionName = 'EnterprisewithCommunities';
            } else if (editioncode == RefEdgeEditionConstants.ENTERPRISE) {
                editionName = 'Enterprise';
            } else if (editioncode == RefEdgeEditionConstants.PROCOM) {
                editionName = 'PROwithCommunities';
            } else if (editioncode == RefEdgeEditionConstants.PRO) {
                editionName = 'Pro';
            } else {
                editionName = 'Basic';
            }
        }
    }
    /**
     * Method to get edition features
     */
    private static void getEditionFeatures() {
        mapFeatures = new Map < String, Boolean > ();
        XMLParsingForEditions dom = new XMLParsingForEditions();
        dom.edition = editionName;
        map < String, List < String >> featureMap = dom.getAllFeatures(getXML());
        for (String key: featureMap.keySet()){
            mapFeatures.put(key, true);
        }
    }
    /**
     * Method to get XML of pages
     */
    private static String getXML() {
        String xml = '<editions>' +
            '<edition name="Basic">' +
            '<features>' +
            '<feature name="rfsearchpage">' +
            '</feature>' +
            '<feature name="referencecontenttypesettingmatrix">' +
            '</feature>' +
            '<feature name="refrequestprojectslds">' +
            '</feature>' +
            '</features>' +
            '</edition>' +

            '<edition name="Pro">' +
            '<features>' +
            '<feature name="rfsearchpage">' +
            '</feature>' +
            '<feature name="DeleteRefRequest">' +
            '</feature>' +
            '<feature name="referencecontenttypesettingmatrix">' +
            '</feature>' +
            '<feature name="referenceuserequest">' +
            '</feature>' +
            '<feature name="requestsettingmatrix">' +
            '</feature>' +
            '<feature name="multiselectreferencesettingfields">' +
            '</feature>' +
            '<feature name="refrequestproject">' +
            '</feature>' +
            '<feature name="refrequestprojectslds">' +
            '</feature>' +
            '<feature name="selectprojectuseattribute">' +
            '</feature>' +
            '<feature name="updaterequestinformation">' +
            '</feature>' +
            '<feature name="viewallreferencenotes">' +
            '</feature>' +
            '<feature name="aggregatehitlist">' +
            '</feature>' +
            '<feature name="hitlistreleaseaction">' +
            '</feature>' +
            '<feature name="reminderaction">' +
            '</feature>' +
            '<feature name="assignaction">' +
            '</feature>' +
            '<feature name="referenceworkspaceslds">' +
            '</feature>' +
            '<feature name="referenceworkspace">' +
            '<subfeature name="RefView"/>' +
            '<subfeature name="MixAndManaged"/>' +
            '</feature>' +
            '<feature name="redeemreward">' +
            '</feature>' +
            '<feature name="salesuserprofile">' +
            '</feature>' +
            '<feature name="newproject">' +
            '</feature>' +
            '<feature name="rewardsettings">' +
            '</feature>' +
            '<feature name="issuereward">' +
            '</feature>' +
            '<feature name="editreward">' +
            '</feature>' +
            '<feature name="invitation">' +
            '</feature>' +
            '<feature name="invitationcontactslookup">' +
            '</feature>' +
            '<feature name="invitationcoworkerslookup">' +
            '</feature>' +
            '<feature name="sf1_referenceuserequest">' +
            '</feature>' +
            '<feature name="sf1_selectreferenceuseattribute">' +
            '</feature>' +
            '<feature name="sf1_requestinfo">' +
            '</feature>' +
            '<feature name="questionsettingmatrix">' +
            '</feature>' +
            '<feature name="advroutingsettings">' +
            '</feature>' +
            '<feature name="advancedroutingchecker">' +
            '</feature>' +
            '<feature name="referencerefreshpage">' +
            '</feature>' +
            '<feature name="fetchfile">' +
            '</feature>' +
            '<feature name="dminline">' +
            '</feature>' +
            '<feature name="dataloadersettingpage">' +
            '</feature>' +
            '<feature name="exportpage">' +
            '</feature>' +
            '</features>' +
            '</edition>' +

            '<edition name="Enterprise">' +
            '<features>' +
            '<feature name="rfsearchpage">' +
            '</feature>' +
            '<feature name="referencecontenttypesettingmatrix">' +
            '</feature>' +
            '<feature name="referenceuserequest">' +
            '</feature>' +
            '<feature name="requestsettingmatrix">' +
            '</feature>' +
            '<feature name="multiselectreferencesettingfields">' +
            '</feature>' +
            '<feature name="refrequestproject">' +
            '</feature>' +
            '<feature name="refrequestprojectslds">' +
            '</feature>' +
            '<feature name="updaterequestinformation">' +
            '</feature>' +
            '<feature name="selectprojectuseattribute">' +
            '</feature>' +
            '<feature name="viewallreferencenotes">' +
            '</feature>' +
            '<feature name="aggregatehitlist">' +
            '</feature>' +
            '<feature name="hitlistreleaseaction">' +
            '</feature>' +
            '<feature name="reminderaction">' +
            '</feature>' +
            '<feature name="assignaction">' +
            '</feature>' +
            '<feature name="referenceworkspaceslds">' +
            '</feature>' +
            '<feature name="referenceworkspace">' +
            '<subfeature name="RefView"/>' +
            '<subfeature name="MixAndManaged"/>' +
            '</feature>' +
            '<feature name="redeemreward">' +
            '</feature>' +
            '<feature name="salesuserprofile">' +
            '</feature>' +
            '<feature name="rewardsettings">' +
            '</feature>' +
            '<feature name="issuereward">' +
            '</feature>' +
            '<feature name="editreward">' +
            '</feature>' +
            '<feature name="invitation">' +
            '</feature>' +
            '<feature name="newproject">' +
            '</feature>' +
            '<feature name="invitationcontactslookup">' +
            '</feature>' +
            '<feature name="invitationcoworkerslookup">' +
            '</feature>' +
            '<feature name="sf1_referenceuserequest">' +
            '</feature>' +
            '<feature name="sf1_selectreferenceuseattribute">' +
            '</feature>' +
            '<feature name="sf1_requestinfo">' +
            '</feature>' +
            '<feature name="advroutingsettings">' +
            '</feature>' +
            '<feature name="advancedroutingchecker">' +
            '</feature>' +
            '<feature name="questionsettingmatrix">' +
            '</feature>' +
            '<feature name="referencerefreshpage">' +
            '</feature>' +
            '<feature name="fetchfile">' +
            '</feature>' +
            '<feature name="dataloadersettingpage">' +
            '</feature>' +
            '<feature name="dminline">' +
            '</feature>' +
            '<feature name="exportpage">' +
            '</feature>' +
            '</features>' +
            '</edition>' +

            '<edition name="PROwithCommunities">' +
            '<features>' +
            '<feature name="rfsearchpage">' +
            '</feature>' +
            '<feature name="referencecontenttypesettingmatrix">' +
            '</feature>' +
            '<feature name="referenceuserequest">' +
            '</feature>' +
            '<feature name="DeleteRefRequest">' +
            '</feature>' +
            '<feature name="requestsettingmatrix">' +
            '</feature>' +
            '<feature name="multiselectreferencesettingfields">' +
            '</feature>' +
            '<feature name="refrequestproject">' +
            '</feature>' +
            '<feature name="refrequestprojectslds">' +
            '</feature>' +
            '<feature name="selectprojectuseattribute">' +
            '</feature>' +
            '<feature name="updaterequestinformation">' +
            '</feature>' +
            '<feature name="viewallreferencenotes">' +
            '</feature>' +
            '<feature name="aggregatehitlist">' +
            '</feature>' +
            '<feature name="hitlistreleaseaction">' +
            '</feature>' +
            '<feature name="reminderaction">' +
            '</feature>' +
            '<feature name="assignaction">' +
            '</feature>' +
            '<feature name="referenceworkspaceslds">' +
            '</feature>' +
            '<feature name="referenceworkspace">' +
            '<subfeature name="RefView"/>' +
            '<subfeature name="MixAndManaged"/>' +
            '</feature>' +
            '<feature name="redeemreward">' +
            '</feature>' +
            '<feature name="salesuserprofile">' +
            '</feature>' +
            '<feature name="editreward">' +
            '</feature>' +
            '<feature name="newproject">' +
            '</feature>' +
            '<feature name="rewardsettings">' +
            '</feature>' +
            '<feature name="issuereward">' +
            '</feature>' +
            '<feature name="invitation">' +
            '</feature>' +
            '<feature name="invitationcontactslookup">' +
            '</feature>' +
            '<feature name="invitationcoworkerslookup">' +
            '</feature>' +
            '<feature name="sf1_referenceuserequest">' +
            '</feature>' +
            '<feature name="sf1_selectreferenceuseattribute">' +
            '</feature>' +
            '<feature name="sf1_requestinfo">' +
            '</feature>' +
            '<feature name="questionsettingmatrix">' +
            '</feature>' +
            '<feature name="referencerefreshpage">' +
            '</feature>' +
            '<feature name="refedgecommunityactivityhistory">' +
            '</feature>' +
            '<feature name="refedgecommunitychatter">' +
            '</feature>' +
            '<feature name="refedgecommunityhome">' +
            '</feature>' +
            '<feature name="refedgecommunityleaderboard">' +
            '</feature>' +
            '<feature name="refedgecommunitynews">' +
            '</feature>' +
            '<feature name="refedgecommunityinvite">' +
            '</feature>' +
            '<feature name="refedgecommunityparticipate">' +
            '</feature>' +
            '<feature name="refedgecommunityprofile">' +
            '</feature>' +
            '<feature name="refedgecommunitytemplate">' +
            '</feature>' +
            '<feature name="managerefedgelicense">' +
            '</feature>' +
            '<feature name="advroutingsettings">' +
            '</feature>' +
            '<feature name="advancedroutingchecker">' +
            '</feature>' +
            '<feature name="deleterefrequest">' +
            '</feature>' +
            '<feature name="posttocommunitypage">' +
            '</feature>' +
            '<feature name="fetchfile">' +
            '</feature>' +
            '<feature name="dminline">' +
            '</feature>' +
            '<feature name="dataloadersettingpage">' +
            '</feature>' +
            '<feature name="exportpage">' +
            '</feature>' +
            '</features>' +
            '</edition>' +
            '<edition name="EnterprisewithCommunities">' +
            '<features>' +
            '<feature name="rfsearchpage">' +
            '</feature>' +
            '<feature name="DeleteRefRequest">' +
            '</feature>' +
            '<feature name="referencecontenttypesettingmatrix">' +
            '</feature>' +
            '<feature name="referenceuserequest">' +
            '</feature>' +
            '<feature name="requestsettingmatrix">' +
            '</feature>' +
            '<feature name="multiselectreferencesettingfields">' +
            '</feature>' +
            '<feature name="refrequestproject">' +
            '</feature>' +
            '<feature name="refrequestprojectslds">' +
            '</feature>' +
            '<feature name="updaterequestinformation">' +
            '</feature>' +
            '<feature name="selectprojectuseattribute">' +
            '</feature>' +
            '<feature name="viewallreferencenotes">' +
            '</feature>' +
            '<feature name="aggregatehitlist">' +
            '</feature>' +
            '<feature name="hitlistreleaseaction">' +
            '</feature>' +
            '<feature name="reminderaction">' +
            '</feature>' +
            '<feature name="assignaction">' +
            '</feature>' +
            '<feature name="referenceworkspaceslds">' +
            '</feature>' +
            '<feature name="referenceworkspace">' +
            '<subfeature name="RefView"/>' +
            '<subfeature name="MixAndManaged"/>' +
            '</feature>' +
            '<feature name="redeemreward">' +
            '</feature>' +
            '<feature name="salesuserprofile">' +
            '</feature>' +
            '<feature name="rewardsettings">' +
            '</feature>' +
            '<feature name="issuereward">' +
            '</feature>' +
            '<feature name="editreward">' +
            '</feature>' +
            '<feature name="invitation">' +
            '</feature>' +
            '<feature name="newproject">' +
            '</feature>' +
            '<feature name="invitationcontactslookup">' +
            '</feature>' +
            '<feature name="invitationcoworkerslookup">' +
            '</feature>' +
            '<feature name="sf1_referenceuserequest">' +
            '</feature>' +
            '<feature name="sf1_selectreferenceuseattribute">' +
            '</feature>' +
            '<feature name="sf1_requestinfo">' +
            '</feature>' +
            '<feature name="questionsettingmatrix">' +
            '</feature>' +
            '<feature name="referencerefreshpage">' +
            '</feature>' +
            '<feature name="deleterefrequest">' +
            '</feature>' +
            '<feature name="refedgecommunityhome">' +
            '</feature>' +
            '<feature name="refedgecommunitynews">' +
            '</feature>' +
            '<feature name="refedgecommunityparticipate">' +
            '</feature>' +
            '<feature name="refedgecommunitychatter">' +
            '</feature>' +
            '<feature name="refedgecommunityprofile">' +
            '</feature>' +
            '<feature name="refedgecommunityleaderboard">' +
            '</feature>' +
            '<feature name="refedgecommunityactivityhistory">' +
            '</feature>' +
            '<feature name="refedgecommunityinvite">' +
            '</feature>' +
            '<feature name="managerefedgelicense">' +
            '</feature>' +
            '<feature name="advroutingsettings">' +
            '</feature>' +
            '<feature name="advancedroutingchecker">' +
            '</feature>' +
            '<feature name="posttocommunitypage">' +
            '</feature>' +
            '<feature name="dminline">' +
            '</feature>' +
            '<feature name="fetchfile">' +
            '</feature>' +
            '<feature name="dataloadersettingpage">' +
            '</feature>' +
            '<feature name="exportpage">' +
            '</feature>' +
            '</features>' +
            '</edition>' +
            '</editions>';
        return xml;
    }
}