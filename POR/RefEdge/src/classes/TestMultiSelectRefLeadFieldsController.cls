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
public with sharing class TestMultiSelectRefLeadFieldsController {
    
    //Unit test Method
    static testMethod void checkMultiSelectFields() {
        //Start test method
        test.startTest();
            MultiSelectReferenceLeadFieldsController con = new MultiSelectReferenceLeadFieldsController();
            con.selectedFields = con.availableFields;
            con.Save();
            List < Data_Mapping__c > NomiFields = [select Name, Order__c, Id, Visible__c, Field_API_Name__c, Required__c from Data_Mapping__c where Object__c = :ConstantsController.REFERENCE_LEAD];
            system.assertEquals(con.selectedFields.size(), NomiFields.size());
            con.Cancel();
            con = new MultiSelectReferenceLeadFieldsController();
            con.Save();
            con.returnPageUrl();
            con.selectedFields = null;
            try{
                con.Save();
            }
            catch(Exception e){}
        //Stop test method
        test.stopTest();
    }
}