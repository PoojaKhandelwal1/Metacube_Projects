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
public with sharing class TestManageRefedgeLicense {
	//Unit Test Method 
    static testMethod void testUnitMethod01() {
    	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
    	Test.startTest();
    		ManageRefedgeLicense obj = new ManageRefedgeLicense();
    		obj.sortField = 'isActive';
    		obj.sortToggle(); 
    		obj.addRemoveLicense();
    		obj.next();
    		obj.previous();
    		obj.selectedUserId = UserInfo.getUserId();
    		obj.removeSingleUserLicense();
    		if(obj.addRemoveUser.size() > 0)
    			obj.addRemoveUser[0].isSelected = true;
    		obj.done();
    		obj.addRemoveUser = null;
    		obj.done();
    		system.assertEquals(obj.pbsTitle, 'Licensed Users');
    		system.assertEquals(obj.pbTitle, '');
    		obj.updateUsers();
    	Test.stopTest();
    }
}