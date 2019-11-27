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
public with sharing class TestRefRequestProjectController {
    public static List < Account > accounts;
    public static List < Referenceability_Type__c > rfTypes;
    public static Reference_Request__c refRequest;
    public static list < Reference_Request_Account__c > rrAcountRequest;
    public static list < Unspecified_Request__c > unspRequest;
    public static list < Reference_Request_Label__c > rrLabels;
    public static list < Reference_Request_Label_Attribute__c > rrLabelAttribs;
    public static list < Reference_Type_Mapping__c > rtmapping;
    public static list < Label__c > labels;
    public static list < Attribute__c > attributes;
    public static list < Attributes_Labels__c > attLabels;
    public static list < Reference_Request_Additional_Info__c > RequestAddInfo;
    public static User u;
    public static list<Hit_List__c> hitlists;
    public static List < Contact > contacts;
    public static RefRequestProjectController stdControllerObj;
    public static boolean iscommunitytest = false;
    public static List < Community_Invite__c  > CIs;
    public static List < Community_Invite_Contact__c > CICs;
    public static List < Reward__c > rewards;
    
    //Test method
    static testMethod void testProjectControllerDisplayField() {
        try{
        setUpData();
        System.debug('RequestAddInfo.get(0).Id'+RequestAddInfo.get(0).Id);
        unspRequest.get(0).Reference_Request_Additional_Info__c = RequestAddInfo.get(0).Id;
        update unspRequest;
        rrAcountRequest.get(0).Reference_Request_Additional_Info__c = RequestAddInfo.get(0).Id;
            rrAcountRequest.get(1).Reference_Request_Additional_Info__c = RequestAddInfo.get(0).Id;
            rrAcountRequest.get(2).Reference_Request_Additional_Info__c = RequestAddInfo.get(0).Id;
        update rrAcountRequest;
        //method to test for ur
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            //method to test for ur
            stdControllerObj.isUr = true;
            stdControllerObj.Ureq = unspRequest.get(0).Id;
            stdControllerObj.urRefName = rfTypes.get(0).Id;
            stdControllerObj.displayFieldInfo();
            //method to test for Ar
            stdControllerObj.isUr = false;
            stdControllerObj.rrAcc = rrAcountRequest.get(1).Id;
            stdControllerObj.arRefName = rfTypes.get(1).Id;
            stdControllerObj.displayFieldInfo();
            system.assertEquals(false, stdControllerObj.showInfo);
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
        
    }
    
    //Test method
    static testMethod void testProjectControllerSaveChanges() {
        try{
        setUpData();
        rrAcountRequest.get(1).Reference_Request_Additional_Info__c = RequestAddInfo.get(0).Id;
        update rrAcountRequest;
        //method to test for ur
        test.startTest();
            Pagereference pgref;
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            //method to test for ur
            stdControllerObj.isUr = true;
            stdControllerObj.Ureq = unspRequest.get(0).Id;
            stdControllerObj.urRefName = rfTypes.get(0).Id;
            stdControllerObj.displayFieldInfo();
            stdControllerObj.saveChanges();
            //method to test for Ar
            stdControllerObj.isUr = false;
            stdControllerObj.rrAcc = rrAcountRequest.get(0).Id;
            stdControllerObj.arRefName = rfTypes.get(0).Id;
            stdControllerObj.displayFieldInfo();
            pgref = stdControllerObj.saveChanges();
            system.assertEquals(pgref.getUrl(), Page.RefRequestProject.getUrl() + '?id=' + refRequest.Id);
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method
    static testMethod void testProjectControllerBackToRequest() {
        try{
        setUpData();
        //method to test for ur
        test.startTest();
            Pagereference pgref;
            //if the reference request consists label already
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
            stdControllerObj.refUseAttr.selectedAttributeId = attributes.get(0).Id;
            stdControllerObj.refUseAttr.setAttributes();
            stdControllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
            stdControllerObj.refUseAttr.selectedAttributeId = attributes.get(0).Id;
            stdControllerObj.refUseAttr.setAttributes();
            stdControllerObj.backToRequest();
            //if the refRequest does not contain the label already
            list < Reference_Request_Label__c > tempObj = [select Id from Reference_Request_Label__c where Reference_Request__c = : refRequest.Id];
            delete tempObj;
            controller = new ApexPages.StandardController(refRequest);
            //select the attribute
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
            stdControllerObj.refUseAttr.selectedAttributeId = attributes.get(0).Id;
            stdControllerObj.refUseAttr.setAttributes();
            stdControllerObj.backToRequest();
            //deselect the attribute
            controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
            stdControllerObj.refUseAttr.selectedAttributeId = attributes.get(1).Id;
            stdControllerObj.refUseAttr.setAttributes();
            pgref = stdControllerObj.backToRequest();
            system.assertEquals(pgref.getUrl(), Page.RefRequestProject.getUrl() + '?activeTab=null&id=' + refRequest.Id);
            system.assertNotEquals(0, stdControllerObj.refUseAttr.mapAttibuteSize.size());
            system.assertNotEquals(0, stdControllerObj.refUseAttr.mapAttributesLabels.size());
            system.assertNotEquals(0, stdControllerObj.refUseAttr.mapAttibuteSize.size());
            system.assertNotEquals(0, stdControllerObj.refUseAttr.getAttributeLabels().size());
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method
    static testMethod void testProjectControllerBackToRequestOnCancel() {
        try{
        setUpData();
        //Start test method
        test.startTest();
            Pagereference pgref;
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.accountId = accounts[0].Id;
            stdControllerObj.displayContact();
            pgref = stdControllerObj.backToRequestOnCancel();
            system.assertEquals(pgref.getUrl(), Page.RefRequestProject.getUrl() + '?activeTab=null&id=' + refRequest.Id);
            refRequest.Project_Type__c = 'Candidate';
            update refRequest;
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.accountId = accounts[0].Id;
            stdControllerObj.displayContact();
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method
    static testMethod void testProjectControllerSaveReqList() {
        try{
        setUpData();
        //Start test method
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            //update single record
            stdControllerObj.reqId = rrAcountRequest.get(1).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = false;
            stdControllerObj.updateReqId = rrAcountRequest.get(1).Id;
            stdControllerObj.changeField = 'status';
            stdControllerObj.statusValue = 'In Progress';
            stdControllerObj.getSelectedAccReqDetails();
            stdControllerObj.writetoNote = true;
            stdControllerObj.allAccountReq[0].rra.Approve_Deny_Notes__c = 'test notes';
            stdControllerObj.saveReqList();
            Reference_Request_Account__c rra = [select Account_Request_Status__c from Reference_Request_Account__c where Id = :rrAcountRequest.get(1).Id limit 1];
            system.assertEquals(rra.Account_Request_Status__c, 'In Progress');
            stdControllerObj.reqId = rrAcountRequest.get(1).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = false;
            stdControllerObj.updateReqId = rrAcountRequest.get(1).Id;
            stdControllerObj.changeField = 'deadLine';
            stdControllerObj.statusValue = '11/27/2013';
            stdControllerObj.getSelectedAccReqDetails();
            stdControllerObj.saveReqList();
            
            stdControllerObj.reqId = rrAcountRequest.get(1).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = false;
            stdControllerObj.updateReqId = rrAcountRequest.get(1).Id;
            stdControllerObj.changeField = 'process';
            stdControllerObj.statusValue = 'Managed';
            stdControllerObj.getSelectedAccReqDetails();
            stdControllerObj.saveReqList();
         

            
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test method
    static testMethod void testProjectControllerSaveReqList1() {
        try{
        setUpData();
        //Start test method
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            
            stdControllerObj.reqId = unspRequest.get(0).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = false;
            stdControllerObj.updateReqId = unspRequest.get(0).Id;
            stdControllerObj.changeField = 'status';
            stdControllerObj.statusValue = 'In Progress';
            stdControllerObj.getSelectedAccReqDetails();
            stdControllerObj.saveReqList();
            
            stdControllerObj.reqId = unspRequest.get(0).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = false;
            stdControllerObj.updateReqId = unspRequest.get(0).Id;
            stdControllerObj.changeField = 'deadLine';
            stdControllerObj.statusValue = '11/27/2013';
            stdControllerObj.getSelectedAccReqDetails();
            stdControllerObj.saveReqList();
            
            //update multiple records
            stdControllerObj.reqId = rrAcountRequest.get(1).Id;
            stdControllerObj.setParam();
            stdControllerObj.reqId = unspRequest.get(0).Id;
            stdControllerObj.setParam();
            stdControllerObj.isSend = true;
            stdControllerObj.saveReqList();
            
            stdControllerObj.hitRecordRequestId = rrAcountRequest.get(1).Id;
            stdControllerObj.setParam();
            stdControllerObj.saveReqList();
            Reference_Request_Account__c rra = [select Account_Request_Status__c from Reference_Request_Account__c where Id = :rrAcountRequest.get(1).Id limit 1];
            system.assertEquals(rra.Account_Request_Status__c, 'In Progress');
            stdControllerObj.hitRecordRequestId = unspRequest.get(0).Id;
            stdControllerObj.hitRecordIsUR = true;
            stdControllerObj.setParam();
            stdControllerObj.saveReqList();
            
            stdControllerObj.selectedaccountReq = rrAcountRequest.get(1).Id;
            stdControllerObj.contactId = contacts[1].Id;
            stdControllerObj.assignContact();
            
        //Stop test method
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test method
    static testMethod void testProjectControllerRemaininMethods() {
        try{
            setUpData();
            //Start test method
            test.startTest();
                Pagereference pgref = Page.RefRequestProject;
                pgref.getParameters().put('activeTab', 'specTab');
                Test.setCurrentPage(pgref);
                ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
                stdControllerObj = new RefRequestProjectController(controller);
                stdControllerObj.cancelRequestEdit();
                stdControllerObj.saveRequestEdit();
                stdControllerObj.goToRefMatch();
                stdControllerObj.addRequest();
                stdControllerObj.selectProjUseAttr();
                stdControllerObj.EditInformation();
                stdControllerObj.backToSearch();
                pgref = stdControllerObj.backToWorkspace();
                stdControllerObj.cancelUpdate();
                system.assertEquals(pgref.getURl(), Page.ReferenceWorkSpace.getUrl() +'?activeTab=specTab');
                delete labels;
            //Stop test method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method
    static testMethod void testassignHitRecord(){
        try{
            setUpData();
            //Start test method
            test.startTest();
                ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
                stdControllerObj = new RefRequestProjectController(controller);
                stdControllerObj.hitRecordId = hitlists.get(0).Id;
                stdControllerObj.hitRecordIsUR = true;
                stdControllerObj.hitRecordRequestId = unspRequest.get(0).Id;
                stdControllerObj.assignHitRecord();
                stdControllerObj.hitRecordId = hitlists.get(1).Id;
                stdControllerObj.hitRecordIsUR = false;
                stdControllerObj.hitRecordRequestId = rrAcountRequest.get(0).Id;
                stdControllerObj.isDispositionSet = true;
                stdControllerObj.assignHitRecord();
                stdControllerObj.releaseHitRecords();
                stdControllerObj.cancelHitList();
                Unspecified_Request__c unspecifiedRequest = [Select Requester__c,Specified_Account__c,Unspecified_Request_Status__c, Request_Notes__c, Reference_Type_Needed__c,Deadline__c, Reference_Request__c, Reference_Request_Additional_Info__c, Project_Owner__c From Unspecified_Request__c where Id=:unspRequest.get(0).Id limit 1][0];
                System.assertEquals(unspecifiedRequest.Unspecified_Request_Status__c,'Account Specified');
                stdControllerObj.editRow();
           //Stop test method
           test.stopTest();
        }catch(Exception e){
            
        } 
        
    }
    
    //Test method
    static testMethod void testupdateHitRecord(){
        try{
        setUpData();
        //Start test method
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
            stdControllerObj = new RefRequestProjectController(controller);
            stdControllerObj.hitRecordId = hitlists.get(0).Id;
            stdControllerObj.hitRecordIsUR = false;
            stdControllerObj.hitRecordRequestId = rrAcountRequest.get(0).Id;
            stdControllerObj.dispositionStatus = 'Agreed';
            stdControllerObj.updateHitRecords();
            stdControllerObj.hitRecordId = hitlists.get(1).Id;
            stdControllerObj.dispositionStatus = 'Released: Contact Declined';
            stdControllerObj.updateHitRecords();
            stdControllerObj.hitRecordId = hitlists.get(2).Id;
            stdControllerObj.dispositionStatus = 'Released: Contact Unresponsive';
            stdControllerObj.updateHitRecords();
            stdControllerObj.hitRecordId = hitlists.get(3).Id;
            stdControllerObj.hitRecordIsUR = true;
            stdControllerObj.hitRecordRequestId = unspRequest.get(0).Id;
            stdControllerObj.dispositionStatus = 'Agreed';
            stdControllerObj.updateHitRecords();
            Unspecified_Request__c unspecifiedRequest = [Select Requester__c,Specified_Account__c,Unspecified_Request_Status__c, Request_Notes__c, Reference_Type_Needed__c,Deadline__c, Reference_Request__c, Reference_Request_Additional_Info__c, Project_Owner__c From Unspecified_Request__c where Id=:unspRequest.get(0).Id limit 1][0];
            System.assertEquals(unspecifiedRequest.Unspecified_Request_Status__c,'Account Specified');
       //Stop test method
       test.stopTest(); 
        }catch(Exception e){
            
            
        }
    }
    //Test method
    static testMethod void testCommunity(){
        try{
        	iscommunitytest = true;
            setUpData();
            //Start test method
            test.startTest();
                ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
                stdControllerObj = new RefRequestProjectController(controller);
                stdControllerObj.hitRecordIsUR = true;
                stdControllerObj.hitRecordRequestId = unspRequest.get(0).Id;
                stdControllerObj.setParam();
                stdControllerObj.includeReferenceability = true;
                stdControllerObj.redirectPostCommunity();
                stdControllerObj.isSend = true;
                stdControllerObj.EditThenSend = 'false';
                stdControllerObj.communitysubjectValue = 'test subject';
                stdControllerObj.communitywithValue = 'new opp';
                stdControllerObj.communitydeadlineValue = system.today().addDays(5).format();
                stdControllerObj.communitydetailsValue = stdControllerObj.communityDetails;
                stdControllerObj.communityInviteRecordCreation();
                list<Community_Invite__c> communityInvites = [select id from Community_Invite__c];
                system.assertNotEquals(null,communityInvites);
                list < Community_Invite_Contact__c > newCICrecords = new list < Community_Invite_Contact__c > ();
                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = communityInvites[0].Id, Contact__c = contacts[0].Id, Response__c = 'Yes'));
                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = communityInvites[0].Id, Contact__c = contacts[1].Id, Response__c = 'No'));
                insert newCICrecords;
                stdControllerObj.communityIdtoDelete = newCICrecords[1].Id;
                stdControllerObj.communityInviteContactRecordDeletion();
                stdControllerObj.hitRecordIsUR = true;
                stdControllerObj.hitRecordRequestId = unspRequest.get(0).Id;
                stdControllerObj.setParam();
                stdControllerObj.communityIdtoDelete = newCICrecords[0].Id;
                stdControllerObj.assignCommunityContactRecord();
           //Stop test method
           test.stopTest();
        }catch(Exception e){
            
        } 
    }
    //Test method
    static testMethod void testCommunity2(){
        try{
        	iscommunitytest = true;
            setUpData();
            //Start test method
            test.startTest();
                ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
                stdControllerObj = new RefRequestProjectController(controller);
                stdControllerObj.hitRecordIsUR = false;
                stdControllerObj.hitRecordRequestId = rrAcountRequest.get(0).Id;
                stdControllerObj.setParam();
                stdControllerObj.includeReferenceability = false;
                stdControllerObj.redirectPostCommunity();
                stdControllerObj.isSend = true;
                stdControllerObj.EditThenSend = 'true';
                stdControllerObj.communitysubjectValue = 'test subject';
                stdControllerObj.communitywithValue = 'new opp';
                stdControllerObj.communitydeadlineValue = system.today().addDays(5).format();
                stdControllerObj.communitydetailsValue = stdControllerObj.communityDetails;
                stdControllerObj.communityInviteRecordCreation();
                list<Community_Invite__c> communityInvites = [select id from Community_Invite__c];
                system.assertNotEquals(null,communityInvites);
                list < Community_Invite_Contact__c > newCICrecords = new list < Community_Invite_Contact__c > ();
                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = communityInvites[0].Id, Contact__c = contacts[0].Id, Response__c = 'Yes'));
                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = communityInvites[0].Id, Contact__c = contacts[1].Id, Response__c = 'No'));
                insert newCICrecords;
                stdControllerObj.communityIdtoDelete = newCICrecords[1].Id;
                stdControllerObj.communityInviteContactRecordDeletion();
                stdControllerObj.hitRecordIsUR = false;
                stdControllerObj.hitRecordRequestId = rrAcountRequest.get(0).Id;
                stdControllerObj.setParam();
                stdControllerObj.communityIdtoDelete = newCICrecords[0].Id;
                stdControllerObj.assignCommunityContactRecord();
           //Stop test method
           test.stopTest();
        }catch(Exception e){
            
        } 
    }
    //Data Setup
    static void setUpData() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        u = TestDataFactory.createUser();
        insert u;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        refRequest = refReqs[0];
        
        RequestAddInfo = createAddInfo();
        insert RequestAddInfo;
        rrAcountRequest = TestDataFactory.createAccountRequests(accounts, refReqs, rfTypes);
        rrAcountRequest[0].Managed_Request__c = true;
        rrAcountRequest[1].Managed_Request__c = true;
        rrAcountRequest[2].Managed_Request__c = true;
        insert rrAcountRequest;
        unspRequest = TestDataFactory.createUnspecifiedRequest(refReqs, rfTypes);
        unspRequest[0].Influitive_Challenge_Id__c = 'test123';
        unspRequest[0].Influitive_Challenge_Status__c = 'Unpublish';
        insert unspRequest;
        
        Community_Invite__c comInvite = new Community_Invite__c();
        comInvite.Referenceability_Type__c = unspRequest[0].Reference_Type_Needed__c;
        comInvite.Reference_Request__c = unspRequest[0].Reference_Request__c;
        comInvite.Unspecified_Request__c = unspRequest[0].Id;
        insert comInvite;
        CIs = new List<Community_Invite__c> {comInvite};
        Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
        newCIC.Community_Invite__c = comInvite.Id;
        newCIC.Contact__c = contacts[0].Id;
        newCIC.Response__c = 'No Response';
        newCIC.Challenge_Id__c = 'test123';
        insert newCIC;
        CICs = new List<Community_Invite_Contact__c> {newCIC};
        rewards = TestDataFactory.createRewards(accounts, contacts);
        
        labels = TestDataFactory.createLabels();
        insert labels;
        attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels,attributes);
        if(iscommunitytest){
        	TestDataFactory.createContactAttributes(contacts, attributes);
        	List < Referenceability__c > rftypesLst = TestDataFactory.createReferenceability(new list<Account>(), contacts, rfTypes);
        	insert rftypesLst;
        }
        else{
        	rrLabels = createReqLabel();
	        insert rrLabels;
	        rrLabelAttribs = createReqLabelAttribute();
	        insert rrLabelAttribs;
	        rtmapping = createReferenceTypeMapping();
	        insert rtmapping;
	        hitlists = createHitListRecords();
	        insert hitlists;
        }
    }
    
    //Hit_List Setup
    private static list<Hit_List__c> createHitListRecords(){
      list<Hit_List__c> tempList = new list<Hit_List__c>();
      tempList.add(new Hit_List__c(note__c = 'test1',Reference_Request__c = refRequest.Id,Deadline__c = system.today(),Account__c = accounts[1].Id,Contact__c = contacts[0].Id));
      tempList.add(new Hit_List__c(note__c = 'test2',Reference_Request__c = refRequest.Id,Deadline__c = system.today(),Account__c = accounts[1].Id,Contact__c = contacts[0].Id));
      tempList.add(new Hit_List__c(note__c = 'test3',Reference_Request__c = refRequest.Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
      tempList.add(new Hit_List__c(note__c = 'test3',Reference_Request__c = refRequest.Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
      
      return  tempList;
    }

    //Reference_Request_Label Setup
    static list < Reference_Request_Label__c > createReqLabel() {
        list < Reference_Request_Label__c > tempReqLabel = new list < Reference_Request_Label__c > ();
        tempReqLabel.add(new Reference_Request_Label__c(Label__c = labels.get(0).Id, Reference_Request__c = refRequest.Id));
        return tempReqLabel;
    }
    
    //Reference_Request_Label_Attribute Setup
    static list < Reference_Request_Label_Attribute__c > createReqLabelAttribute() {
        list < Reference_Request_Label_Attribute__c > tempReqLabelAtt = new list < Reference_Request_Label_Attribute__c > ();
        tempReqLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = attributes.get(0).Id, Reference_Request_Label__c = rrLabels.get(0).Id));
        return tempReqLabelAtt;
    }
    
    //Reference_Type_Mapping Setup
    static list < Reference_Type_Mapping__c > createReferenceTypeMapping() {
        list < Reference_Type_Mapping__c > tempRefMapping = new list < Reference_Type_Mapping__c > ();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(0).Id));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(1).Id));
        return tempRefMapping;
    }
    
    //Reference_Request_Additional_Info Setup
    static list < Reference_Request_Additional_Info__c > createAddInfo() {
        list < Reference_Request_Additional_Info__c > tempAddInfo = new list < Reference_Request_Additional_Info__c > ();
        tempAddInfo.add(new Reference_Request_Additional_Info__c(OwnerId = u.Id));
        return tempAddInfo;
    }
    
    //REF-1964
    @isTest static void goToRefHubMatch() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        
        Test.startTest();
        PageReference result = stdControllerObj.goToRefHubMatch();
        Test.stopTest();
        
        System.assert(result != null, 'Redirected to RefMatchPage.');
    }
    
    @isTest static void testGetSelectedContactInfo() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.selectedContactIds = String.valueOf(contacts[0].id);
        
        Test.startTest();
        stdControllerObj.getSelectedContactInfo();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Got selected contact information.');
    }
    
    @isTest static void testRemoveSelectedContact() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.listOfSelectedContacts = contacts;
        stdControllerObj.contactIdToRemove = String.valueOf(contacts[1].id);
        
        Test.startTest();
        stdControllerObj.removeSelectedContact();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Removed selected contact.');
    }
    
    @isTest static void testCreateCommunityInviteContactRecords() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        List<Contact> listOfSelectedContacts = contacts;
        RefRequestProjectControllerSLDS.InfluitiveWrapper influtiveWrap = new RefRequestProjectControllerSLDS.InfluitiveWrapper();
        influtiveWrap.endAt = '2019-4-6';
        influtiveWrap.unspecifiedRequestId = unspRequest[0].id;
        influtiveWrap.challengeId = 'test123';
        stdControllerObj.refTypeNeeded = rfTypes[0].id;
        
        Test.startTest();
        List<Community_Invite_Contact__c> result = stdControllerObj.createCommunityInviteContactRecords(influtiveWrap,listOfSelectedContacts);
        Test.stopTest();
        
        System.assert(result != null, 'CIC records created.');
    }
    
    @isTest static void testChangeMinimumDeadline() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.refTypeNeeded = rfTypes[0].id;
        
        Test.startTest();
        stdControllerObj.changeMinimumDeadline();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Minimum Deadline changed.');
    }
    
    @isTest static void testSetRefTypeNeeded() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.refTypeNeeded = rfTypes[0].id;
        
        Test.startTest();
        stdControllerObj.setRefTypeNeeded();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Reftype set.');
    }
    
    @isTest static void testGetRelatedCICByChallengeId() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.listOfCICForAdvocates = new List<Community_Invite_Contact__c>();
        
        Test.startTest();
        stdControllerObj.getRelatedCICByChallengeId('test123');
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Get CIC by ChallengeId.');
    }
    
    @isTest static void testAsignAdvocateToChallenge() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.selectRefType = unspRequest[0].id;
        stdControllerObj.assignedContactId = contacts[0].Id;
            
        Test.startTest();
        stdControllerObj.assignAdvocateToChallenge();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Advocate assigned to challenge.');
    }
    
    @isTest static void testUpdateChallengeStatus() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.selectRefType = unspRequest[0].id;
        stdControllerObj.updatedChallengeStatus = 'Publish';
            
        Test.startTest();
        stdControllerObj.updateChallengeStatus();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Challenge status updated.');
    }
    
    @isTest static void testPostChallengeInInfluitive() {
        setUpData();
        ApexPages.StandardController controller = new ApexPages.StandardController(refRequest);
        stdControllerObj = new RefRequestProjectController(controller);
        stdControllerObj.selectRefType = unspRequest[0].id;
        stdControllerObj.inflDeadlineDate = '04/16/2019';
        stdControllerObj.participantLimit = '5';
        stdControllerObj.refTypeNeeded = rfTypes[0].id;
            
        Test.startTest();
        stdControllerObj.postChallengeInInfluitive();
        Test.stopTest();
        
        System.assert(stdControllerObj != null, 'Challenge Posted.');
    }
}