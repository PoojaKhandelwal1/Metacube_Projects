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
 * Class to call influitive api handler to create new challenge in influitive
 * Change status of challenge
 * This class is added as part of influitive integration.
 */
public with sharing class Infl_Reference {
    
    private static InflAPIHandler handler = new InflAPIHandler();
    
    //REF-1964
    public static Infl_CreateReferenceResponse createReferenceChallenge(RefRequestProjectControllerSLDS.InfluitiveWrapper inflWrap, List<Contact> listOfContacts) {
        Infl_ReferenceJSON  request = new Infl_ReferenceJSON ();
        
        Infl_ReferenceJSON.cls_account account = new Infl_ReferenceJSON.cls_account();
        account.name = inflWrap.accountName;
        request.account = account;
        
        List<Infl_ReferenceJSON.cls_advocates> listOfAdvocates = new List<Infl_ReferenceJSON.cls_advocates>();
        
        if (listOfContacts.size() > 0) {
            
            for (Contact con : listOfContacts) {
                Infl_ReferenceJSON.cls_advocates advocate = new Infl_ReferenceJSON.cls_advocates();
                advocate.crm_contact_id = con.Id;
                advocate.email = con.Email;
                advocate.first_name = con.FirstName;
                advocate.last_name = con.LastName;
                listOfAdvocates.add(advocate);
            }
            request.advocates = listOfAdvocates;
        }
        
        request.status = 'requested';
        request.close_challenge = false;
        request.template_code = inflWrap.templateCode;
        request.participant_limit = inflWrap.participantLimit;
        request.start_at = inflWrap.startAt;
        request.end_at = inflWrap.endAt;
        
        // Calling APIHandler
        Infl_CreateReferenceResponse refParser = handler.createInflReference(request);
        return refParser;
    }
    
    public static Infl_CreateReferenceResponse changeReferenceChallengeStatus(String status, String challengeId, String publishRequestString) {
        Infl_CreateReferenceResponse refParser = handler.changeInflReferenceChallengeStatus(status, challengeId, publishRequestString);
        return refParser;
    }
}