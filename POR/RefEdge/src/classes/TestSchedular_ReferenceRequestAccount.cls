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
public class TestSchedular_ReferenceRequestAccount {
    
    public static testMethod void testschedule() {
        Test.StartTest();
            Schedular_ReferenceRequestAccount schedularClass = new Schedular_ReferenceRequestAccount();
            String sch = '0 0 1 * * ?';
            String scheduleId = system.schedule('Schedular_ReferenceRequestAccount class', sch, schedularClass);
            
            for (integer i=0; i<=5; i++) {
                system.schedule('Schedular_ReferenceRequestAccount class'+i, sch, schedularClass);
            }
            system.schedule('Schedular_ReferenceRequestAccount class9', sch, schedularClass);
            system.assert(scheduleId != null);
        Test.stopTest();
    }
}