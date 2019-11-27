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
private class TestInvitationCoworkersLookupController {
    private static list<User> coworkers;
    
    //Test method for save and delete
    static testMethod void testSaveAndDelete() {
        coworkers= createUsers();
        insert coworkers;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.InvitationCoworkersLookup;
            Test.setCurrentPage(pageRef);
            Apexpages.currentPage().getParameters().put('strText', coworkers[0].Id);
            InvitationCoworkersLookupController controller = new InvitationCoworkersLookupController();
            controller.save();
            system.assertEquals(1,controller.listUsers.size());
        //Stop test method
        test.stopTest();
    }
    
    //Test method for save and delete for search
    static testMethod void testSaveAndDeleteForSearch() {
        coworkers= createUsers();
        insert coworkers;
          //Start test method
        test.startTest();
            InvitationCoworkersLookupController controller = new InvitationCoworkersLookupController();
            controller.searchText = 'PORnitin';
            controller.getUsers();
            controller.save();
            controller.search();
            system.assertEquals(2,controller.listUsers.size());
           //Stop test method
        test.stopTest();
    }
    
    //Creation of User records
    private static list<User> createUsers(){
        list<User> tempUser = new list<User>();
        Profile p = [select id from profile where name like '%System Admin%'];
        tempUser.add(new User( alias = 'jpusr', email = 'PORnitin@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'PORnitin1@newtest.com')); 
        tempUser.add(new User( alias = 'jpusr1', email = 'PORnitin2@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'PORnitin3@newtest.com'));   
        return tempUser;
    }
}