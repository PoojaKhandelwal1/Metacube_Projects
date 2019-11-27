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
public with sharing class TestRefEdgeDecodingClass {
    
    //Unit Test method
    static testMethod void checkRefEdgeDecoding() {
        //Start test method
        test.startTest();
            String decodedString = RefEdgeDecodingClass.getDecodedData('SssKCoR/q2OdMQD9SiT1jmkkfLTmDhEJ0D9vF2Agj4b3RsAFZolwXLYvvhRcbgsg=Pneumonoultramicrosc12w9ufGUijBc9slY4lpoL/vCiAX8tzMybvwwtkiLMFCIL=');
            system.assertEquals('000', decodedString);
            decodedString = RefEdgeDecodingClass.getDecodedData('');
            system.assertEquals('000', decodedString);
            decodedString = RefEdgeDecodingClass.getDecodedData('s414zuziUEIuvzHjECmsrzCKRp12LVwZj9MyFXAu7nR4nvYCKpFtdpqFUwSOv47VVFkBO7+cKN06J+JTSDkPctngV5m7o/aYouunR0rkKcwpibAuaNnQnZenvYTgbNvjBJ7HkBCLgV6K/aQZ6X63zEXmFSpoc2VtDtkty6KW/Dc=Pneumonultamicrosc12WlKmIfL7ggewMWGX0Qk6T6kJL8bqUB03d+i09em8CjQ=');
            system.assertEquals('333', decodedString);
        //Stop test method
        test.stopTest();
    }
}