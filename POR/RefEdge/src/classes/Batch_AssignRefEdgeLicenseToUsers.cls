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
/**
 * Class: ManageRefedgeLicense
 * Description : This Batch called from ManageRefedgeLicense to update all existing refedge users
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_AssignRefEdgeLicenseToUsers implements Database.Batchable < sObject > , Database.stateful {

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        set < Id > userIds = new set < Id > ();
        
        if (UtilityController.appNamespace() != '') {
            list < UserPackageLicense > userLicenses = [select Id, UserId from UserPackageLicense where PackageLicense.NamespacePrefix = 'refedge'];
            
            if (userLicenses.size() > 0) {
                
                for (UserPackageLicense userL: userLicenses) {
                    userIds.add(userL.UserId);
                }
            }
        }
        
        if (Test.isRunningTest()) {
            userIds.add(UserInfo.getUserId());
        }
        String soqlQuery = 'SELECT Refedge_License_Type__c FROM User WHERE Id IN : userIds';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < User > scope) {
        list < User > users = new list < User > ();
        
        for (User user: scope) {
            
            if (Test.isRunningTest())
                user.Refedge_License_Type__c = '';
            else
                user.Refedge_License_Type__c = 'Full License';
            users.add(user);
        }
        
        if (users.size() > 0)
            update users;
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {}
}