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
public class TestRewardTriggerHandler {
    
    //Test method
    static testMethod void afterInsert() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        test.startTest();
            list<Reward__c> rw = new list<Reward__c>();
            rw.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = contacts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            rw.add(new Reward__c(Contact__c = contacts[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            insert rw;
            Reference_Basic_Information__c acc = [select Lifetime_Points__c from Reference_Basic_Information__c where Account__c =:accounts[1].Id limit 1];
            rw = new list<Reward__c>();
            rw.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = contacts[1].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 80));
            rw.add(new Reward__c(Contact__c = contacts[0].Id, Amount__c = -100));
            insert rw;
            
        test.stopTest();
        System.assertEquals(acc.Lifetime_Points__c,100);
    }
    //Test method
    static testMethod void afterUpdate() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        ConstantsController.isInfluitiveNotRunning = true;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        Set<String> setIds = new Set<String>();
        
        for(Account accountA : accounts){
            setIds.add(accountA.id);
        }
        List<Reference_Basic_Information__c> acc1 = [select Lifetime_Points__c from Reference_Basic_Information__c where Account__c in :setIds];
        List<Reference_Basic_Information__c > tmp = new List<Reference_Basic_Information__c>();
        for(Reference_Basic_Information__c  RBIA : acc1){
            RBIA.Is_Referenceable__c =true;
            tmp.add(RBIA);
        }
        update tmp;
        
        test.startTest();
            list<Reward__c> rw = new list<Reward__c>();
            rw.add(new Reward__c(Account__c = accounts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            rw.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = contacts[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 200,Available_Points__c =200));
            insert rw;
            list<Reward__c> redeemrewards = new list<Reward__c>();
            redeemrewards.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = contacts[1].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 150));
            redeemrewards.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = contacts[0].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 20));
            insert redeemrewards;
            rw[0].contact__c = contacts[0].Id;
            rw[0].Amount__c = 200;
            rw[1].Amount__c = 70;
            
            try {
                update rw;
            } catch (Exception e) {
                system.assertNotEquals(e.getDmlMessage(0), '');
            }
            rw[1].Amount__c = 210;
            update rw;
            Reference_Basic_Information__c acc = [select Lifetime_Points__c from Reference_Basic_Information__c where Account__c =:accounts[0].Id limit 1];
            System.assertEquals(acc.Lifetime_Points__c,200);
            redeemrewards[0].Amount__c = 140;
            redeemrewards[1].Amount__c = 120;
            update redeemrewards;
            delete redeemrewards;
            rw[0].Expired__c = true;
            rw[0].Expired_Points__c = rw[0].Available_Points__c;
            rw[0].Available_Points__c = 0;
            rw[0].Expiration_Date__c = date.today().addDays(2);
            update rw;
            rw[0].Expired__c = false;
            rw[0].Expired_Points__c = 0;
            rw[0].Available_Points__c = 100;
            rw[0].Expiration_Date__c = date.today().addDays(2);
            update rw;
            rw[0].Expired__c = true;
            rw[0].Expired_Points__c = 50;
            rw[0].Available_Points__c = 0;
            rw[0].Expiration_Date__c = date.today().addDays(2);
            update rw;
        
        test.stopTest();
        
    }
    
    //Test method
    static testMethod void afterDelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        ConstantsController.isInfluitiveNotRunning = true;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        test.startTest();
            list<Reward__c> issuerewards = new list<Reward__c>();
            issuerewards.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = contacts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            issuerewards.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = null,Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            insert issuerewards;
            Reference_Basic_Information__c acc = [select Lifetime_Points__c from Reference_Basic_Information__c where Account__c =:accounts[1].Id limit 1];
            list<Reward__c> redeemrewards = new list<Reward__c>();
            redeemrewards.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = contacts[1].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 80));
            redeemrewards.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = null,Transaction__c = ConstantsController.REDEEM, Amount__c = 100));
            insert redeemrewards;
            try {
                delete issuerewards;
            } catch (Exception e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.RewardDelete);
            }
            try {
                delete redeemrewards;
            } catch (Exception e) {
                system.assertNotEquals(e.getDmlMessage(0), System.Label.RewardDelete);
            }
            try {
                delete issuerewards;
            } catch (Exception e) {
                //system.assertEquals(e.getDmlMessage(0), System.Label.RewardDelete);
                 System.assert(e.getMessage().contains('ENTITY_IS_DELETED'), 'message=' + e.getMessage());
            }
        test.stopTest();
        System.assertEquals(acc.Lifetime_Points__c,100);
    }
    
    //Test method
    static testMethod void afterUnDelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        test.startTest();
            list<Reward__c> issuerewards = new list<Reward__c>();
            issuerewards.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = contacts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            issuerewards.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = contacts[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c =100));
            insert issuerewards;
            Set<String> setIds = new Set<String>();
            for(Account accountA : accounts){
                setIds.add(accountA.id);
            }
            List<Reference_Basic_Information__c> acc = [select Lifetime_Points__c from Reference_Basic_Information__c where Account__c in :setIds];
            List<Reference_Basic_Information__c > tmp = new List<Reference_Basic_Information__c>();
            for(Reference_Basic_Information__c  RBIA : acc){
                RBIA.Is_Referenceable__c =true;
                tmp.add(RBIA);
            }
            update tmp;
            list<Reward__c> redeemrewards = new list<Reward__c>();
            redeemrewards.add(new Reward__c(Account__c = accounts[1].Id,Contact__c = null,Transaction__c = ConstantsController.REDEEM, Amount__c = 80));
            redeemrewards.add(new Reward__c(Account__c = accounts[0].Id,Contact__c = null,Transaction__c = ConstantsController.REDEEM, Amount__c = 100));
            insert redeemrewards;
            try {
                delete issuerewards;
            } catch (Exception e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.RewardDelete);
            }
            delete redeemrewards;
            undelete issuerewards;
            undelete redeemrewards;
        test.stopTest();
        System.assertEquals(acc[0].Lifetime_Points__c,100);
    }
    /*Test method to test rewards creation on the basis of Transaction - #1164*/
    //Test method
    static testMethod void testForBeforeInsert() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        ConstantsController.isInfluitiveNotRunning = true;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        test.startTest();
        
        /**************************Influitive integration Enabled***************************/
        
        /*Case when rewards having Transaction details*/
        list<Reward__c> rw = new list<Reward__c>(); 
        rw.add(new Reward__c(Contact__c = contacts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c = 100));
        rw.add(new Reward__c(Contact__c = contacts[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 200,Available_Points__c = 200));
        insert rw;
        list<Reward__c> redeemrewards = new list<Reward__c>();
        redeemrewards.add(new Reward__c(Contact__c = contacts[1].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 150));
        redeemrewards.add(new Reward__c(Contact__c = contacts[0].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 20));
        insert redeemrewards;
            
        /*Case when rewards without Transaction details*/
        try {
            list<Reward__c> rwt = new list<Reward__c>(); 
            rwt.add(new Reward__c(Contact__c = contacts[0].Id, Amount__c = 100));
            rwt.add(new Reward__c(Contact__c = contacts[1].Id, Amount__c = -10));
            insert rwt;
        }
        catch(Exception e)
        {
            Boolean expectedExceptionThrown =  e.getMessage().contains('Please mention proper Transaction details like Issue or Redeem') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        } 
        
        /*************************Influitive integration Desabled****************************/ 
        customSetting.Is_Influitive_Integration_Enabled__c = false;
        update customSetting;
        
        list<Reward__c> reward = new list<Reward__c>(); 
        reward.add(new Reward__c(Contact__c = contacts[0].Id, Transaction__c = ConstantsController.ISSUE, Amount__c = 100,Available_Points__c = 100));
        reward.add(new Reward__c(Contact__c = contacts[1].Id,Transaction__c = ConstantsController.ISSUE, Amount__c = 200,Available_Points__c = 200));
        insert reward; 
        
        list<Reward__c> redeem = new list<Reward__c>();
        redeem.add(new Reward__c(Contact__c = contacts[1].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 150));
        redeem.add(new Reward__c(Contact__c = contacts[0].Id,Transaction__c = ConstantsController.REDEEM, Amount__c = 20));
        insert redeem;
        Reference_Basic_Information__c con = [select Lifetime_Points__c from Reference_Basic_Information__c where Contact__c =:contacts[1].Id limit 1];
        System.assertNotEquals(con.Lifetime_Points__c, null);
        test.stopTest(); 
    }
    
}