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
public with sharing class TestAutoAddPermissionController {
    
    public static testMethod void testStandardUser() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        AutoAddPermissionController aapc = new AutoAddPermissionController(sc);
        aapc.cs = cs;
        system.assertNotEquals(null, cs);
        aapc.getSelectlist();
        aapc.isprofile = true;
        aapc.editForm();
	    aapc.addToList();
	    aapc.removeFromList();
	    aapc.cancelForm();
	    aapc.saveForm();
	    aapc.onChangeType();
    }

    public static testMethod void testStandardUser1() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        cs.SU_Profiles__c = 'System Administrator, Partner User';
        cs.SU_Permission_Sets__c = 'RefEdge RE Salesperson, RefEdge Reference Manager';
        cs.RM_Profiles__c = 'System Administrator, Partner User';
        cs.RM_Permission_Sets__c = 'RefEdge RE Salesperson, RefEdge Reference Manager';
        update cs;
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        AutoAddPermissionController aapc = new AutoAddPermissionController(sc);
        aapc.cs = cs;
        system.assertNotEquals(null, cs);
        aapc.getSelectlist();
        aapc.isprofile = true;
        aapc.editForm();
        aapc.profilesToInclude = 'System Administrator, Partner User';
        aapc.permissionToInclude = 'RefEdge RE Salesperson, RefEdge Reference Manager';       
	    aapc.addToList();
        aapc.currentSelectedProfile = 'System Administrator, Partner User';
        aapc.currentSelectedPermission = 'RefEdge RE Salesperson, RefEdge Reference Manager';        
	    aapc.removeFromList();
	    aapc.cancelForm();
        aapc.selectedVal = 'Standard User';
	    aapc.saveForm();
	    aapc.onChangeType();
    }

    public static testMethod void testReferenceManager() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        cs.SU_Profiles__c = 'System Administrator, Partner User';
        cs.SU_Permission_Sets__c = 'RefEdge RE Salesperson, RefEdge Reference Manager';
        cs.RM_Profiles__c = 'System Administrator, Partner User';
        cs.RM_Permission_Sets__c = 'RefEdge RE Salesperson, RefEdge Reference Manager';
        update cs;
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        AutoAddPermissionController aapc = new AutoAddPermissionController(sc);
        aapc.cs = cs;
        system.assertNotEquals(null, cs);
        aapc.getSelectlist();
        aapc.isprofile = false;
        aapc.editForm();
        aapc.profilesToInclude = 'System Administrator, Partner User';
        aapc.permissionToInclude = 'RefedgeRESalesperson, RefedgeReferenceManager';        
	    aapc.addToList();
        aapc.currentSelectedProfile = 'System Administrator, Partner User';
        aapc.currentSelectedPermission = 'RefedgeRESalesperson, RefedgeReferenceManager';        
	    aapc.removeFromList();
	    aapc.cancelForm();
        aapc.selectedVal = 'Reference Manager';
        aapc.selectedProfile.add(new SelectOption('System Administrator', 'System Administrator'));
        aapc.SelectedPermission.add(new SelectOption('RefedgeRESalesperson', 'RefEdge RE Salesperson'));     
	    aapc.saveForm();
	    aapc.onChangeType();
    }

    public static testMethod void testStandardUserNew() {
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();
        cs.SU_Profiles__c = 'System Administrator, Partner User';
        cs.SU_Permission_Sets__c = 'Service Cloud User, Sales Cloud User';
        cs.RM_Profiles__c = 'System Administrator, Partner User';
        cs.RM_Permission_Sets__c = 'Service Cloud User, Sales Cloud User';
        update cs;
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        AutoAddPermissionController aapc = new AutoAddPermissionController(sc);
        aapc.cs = cs;
        system.assertNotEquals(null, cs);
        aapc.getSelectlist();
        aapc.isprofile = false;
        aapc.editForm();
        aapc.profilesToInclude = 'System Administrator, Partner User';
        aapc.permissionToInclude = 'RefedgeRESalesperson, RefedgeReferenceManager';     
	    aapc.addToList();
        aapc.currentSelectedProfile = 'System Administrator, Partner User';
        aapc.currentSelectedPermission = 'RefedgeRESalesperson, RefedgeReferenceManager';       
	    aapc.removeFromList();
	    aapc.cancelForm();
        aapc.selectedVal = 'Standard User';
        aapc.selectedProfile.add(new SelectOption('System Administrator', 'System Administrator'));
        aapc.SelectedPermission.add(new SelectOption('RefedgeRESalesperson', 'RefEdge RE Salesperson'));     
	    aapc.saveForm();
	    aapc.onChangeType();
    }
}