/**
 * Author: Ashish Garg
 * Since: Dec. 23, 2015
 * Name: AccountingDataMigrationRMPayment
 * Description: Class is used for migration of Payment records to  Accounting Software
**/
global with sharing class AccountingDataMigrationRMPayment implements Database.batchable<sObject>,Database.Stateful {
	
	global AccountingDataMigrationRMPayment() {}
	global AccountingDataMigrationRMPayment(List<Id> recordIds, boolean exportAllData) {}
	global AccountingDataMigrationRMPayment(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
	private String query = 'SELECT Id from CO_Invoice_Payment__c limit 1';
	
	global AccountingDataMigrationRMPayment(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {}
    global Database.QueryLocator start(Database.BatchableContext BC) {return Database.getQueryLocator(query);}
	global void execute(Database.BatchableContext BC, List<sObject> scope) {}
	global void finish(Database.BatchableContext BC) {}
}