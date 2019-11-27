/**
 * Author: Rajat Jain
 * updated: May 25, 2018
 * Name: IntegrityCheckForQBCtrlTest
 * Description: It includes scenario based test cases for IntegrityCheckForQBCtrl.
**/

@isTest
private with sharing class IntegrityCheckForQBCtrlTest {
	 static testMethod void integrityCheckCtrlTest() {
	 	Test.startTest();
	 	insert new BP_Configurations__c(Support_Email_Recipient__c = 'rajat.jain@metacube.com');
	 	new IntegrityCheckForQBCtrl().sendIntegrityCheckMailToSupportTeam();
	 	new IntegrityCheckForQBCtrl.EntityInfoWrapper('entityId','name','entityType');
	 	system.assertEquals(0, [SELECT Id FROM Account].size());
        Test.stopTest();
	 }
    
}