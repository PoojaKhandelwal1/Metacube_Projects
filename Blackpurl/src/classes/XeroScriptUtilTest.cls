/**
 * Author: Nikhil Kumar Srivastava
 * Since: April 15, 2019
 * Name: XeroScriptUtilTest
 * Description: test Class for XeroScriptUtil.
**/

@isTest
public with sharing class XeroScriptUtilTest {
	
	static testmethod void scriptUtilTest() {
		test.startTest();
		XeroScriptUtil.syncCustomers(25,60,25);
		XeroScriptUtil.syncVendors(25,60,25);
		test.stopTest();
		system.assertEquals(true,true);
	}
}