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
 * Description: This Infl_ReferenceJSON used to create JSON for influitive responses.
 * Author:- Narender Singh Tanwar
 * Last Modified By: Rajesh @Feb 4 2017
 */
public with sharing class Infl_ReferenceJSON {
	/**
     * Properties and variables
     */
	public String crm_opportunity_id;   
    public cls_prospect prospect;
    public cls_member member;
    public cls_advocates[] advocates;
    public String status;   
    public String participant_limit;  
    public Boolean close_challenge;  
    public String template_code;  
    public cls_account account;
    public String start_at;
    public String end_at;
    
    /**
     * Inner Classes
     */ 
    public class cls_prospect {
        public String name; 
        public String email;   
        public String title;    
        public String company;  
        public String phone;    
        public String sfdc_id;   
    }
    
    public class cls_advocates {
        //public String id;  
        public String crm_contact_id;
        public String email;
        public String first_name;
        public String last_name;
    }
    
    public class cls_member {
        public String id;   
        public String email;   
        public String crm_contact_id;
        public String first_name;
        public String last_name;
    }
    
    public class cls_account {
        public String name; 
        public String email;   
        public String title;    
        public String company;  
        public String phone;    
        public String sfdc_id;   
    }
    
    /**
     * Method to JSON Creator
     */ 
    public static String serialize(Infl_ReferenceJSON request) {
        return JSON.serialize(request);
    }
    
    public class Infl_PublishStatusJSON {
        public String participant_limit; 
        public String start_at;
        public String end_at;
        
        public String serialize(Infl_PublishStatusJSON request) {
            return JSON.serialize(request);
        }  
    }
    
}