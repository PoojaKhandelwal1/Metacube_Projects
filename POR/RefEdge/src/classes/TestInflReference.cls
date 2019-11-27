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
@isTest(seeAllData = false)
public class TestInflReference{
    /*
     * Getting all references from influitive and creating contact requests
     */
    private static final String API_URL = 'https://pointofreference.influitive.com:443';
    private static final String API_AUTH_TOKEN = 'b3431ebb96d5248c8f78dad57a9c41e1ffe1b38b';
    /* Create contact request this will create complete challenge event in influitive
     */
    static testmethod void createContactRequest(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            customSetting.Influitive_API_URL__c = API_URL;
            customSetting.Influitive_Auth_Token__c = API_AUTH_TOKEN;
            update customSetting;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            Reference_Basic_Information__c newrbi = new Reference_Basic_Information__c(Contact__c = contacts[0].Id, Account__c = contacts[0].AccountId, Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE);
            insert newrbi;
            Referenceability_Type__c defaultRefType = createReferenceabilityType();
            
            List < Reference_Request_Account_Contact__c > rrAccConts = new List < Reference_Request_Account_Contact__c > ();
            List < Reference_Request_Account__c > rrAccs = new List < Reference_Request_Account__c > ();
            List < Reference_Request__c > refReqList = new List < Reference_Request__c > ();
            
            refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = ConstantsController.IN_PROGRESS,Reference_Use__c = false));
            insert refReqList;
            rrAccs.add( new Reference_Request_Account__c(Reference_Type_Needed__c = defaultRefType.id,Account__c= contacts[0].AccountId,Account_Request_Status__c =ConstantsController.IN_PROGRESS,
                        Reference_Request__c = refReqList[0].id,Reference_Use__c = false,Process__c = ConstantsController.MANAGED,Deadline__c = system.today()));
            rrAccs = WithoutSharingHelperController.insertRRA(rrAccs);
            rrAccConts.add(new Reference_Request_Account_Contact__c(Referenceability_Type__c = defaultRefType.id, Reference_Request_Account__c = rrAccs[0].Id, 
                            Activity_Date__c = system.today(),Reference_Use__c = false,Deadline__c = system.today(),influitiveId__c = null,
                             Contact__c = contacts[0].id, Contact_Request_Status__c = ConstantsController.IN_PROGRESS));
     
            insert rrAccConts; 
            System.assert(true);
        }
         //Stop test method
        test.stopTest();
    }
    
    private static Referenceability_Type__c createReferenceabilityType(){
        Referenceability_Type__c refType = new Referenceability_Type__c(Name = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_code__c = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
        insert refType;
        return [select id ,Referenceability_code__c from Referenceability_Type__c where Visible__c = true AND id =: refType.id limit 1];
    }
    
    @isTest static void testCreateReferenceChallenge() {
        User u = TestDataFactory.CreateUser();
        
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Is_Influitive_Integration_Enabled__c = true;
            customSetting.Influitive_API_URL__c = API_URL;
            customSetting.Influitive_Auth_Token__c = API_AUTH_TOKEN;
            update customSetting;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            RefRequestProjectControllerSLDS.InfluitiveWrapper inflWrap = new RefRequestProjectControllerSLDS.InfluitiveWrapper();
            inflWrap.accountName = 'test';
            inflWrap.templateCode = 'test';
            inflWrap.participantLimit = '1';
            inflWrap.startAt = '2019-4-6';
            inflWrap.endAt = '2019-4-9';
             
            Infl_CreateReferenceResponse refResponse = Infl_Reference.createReferenceChallenge(inflWrap,contacts);
            Infl_CreateReferenceResponse refRes = Infl_Reference.changeReferenceChallengeStatus('Publish','test123',null);
            System.assertNotEquals(inflWrap,null);
        }
        test.stopTest();
    }
}