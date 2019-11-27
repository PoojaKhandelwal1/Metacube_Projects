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
 * Description: Influitive EventsParser class
 * Last Modified By: Rajesh @Feb 6 2017
 */
public with sharing class Infl_EventsParser { 
	/**
     * Properties and variables
     */
    public cls_events[] events { get; set; }
    public cls_contacts[] contacts { get; set; }
    public cls_links links;
    //This field use to monitor that how many api call we have already made to influitive
    public Integer apiCalls { get; set; } 
    
    /**
     * Inner classes
     */
    public class cls_events implements Comparable { 
       /**
     	* Properties and variables
     	*/
        public Integer id { get; set; }  
        public String uuid { get; set; } 
        public String type { get; set; }
        public String created_at { get; set; }  
        public Integer contact_id { get; set; } 
        public Integer points { get; set; } 
        public cls_params params;
        
        /**
     	* Method to compare
     	*/
        public Integer compareTo(Object compareTo) {
            cls_events compareToObj = (cls_events)compareTo;
            
            if (id == compareToObj.id) {
            	return 0;
            }
                        
            if (id > compareToObj.id) {
            	return 1;
            }
            return -1;  
        }
    }
    
    public class cls_params {
        public Challenge challenge { get; set; }
        public Integer nps_score { get; set; }
    }
    
    public class Challenge {
        public String id { get; set; }
        public String type { get; set; }
    }
    
    public class cls_contacts implements Comparable {
    	
    	/**
     	* Properties and variables
     	*/
        public Integer id { get; set; }    
        public String name { get; set; }  
        public String first_name; 
        public String last_name;   
        public String email { get; set; } 
        public String type { get; set; }  
        public String created_at; 
        public String joined_at;
        public Integer current_points;  
        public Integer total_points { get; set; } 
        public Integer nps_score;
        public String crm_contact_id { get; set; }
        public Integer contact_events { get; set; }
        
        /**
     	* Method to compare
     	*/
        public Integer compareTo(Object compareTo) {
            cls_contacts compareToObj = (cls_contacts) compareTo;
            
            if (id == compareToObj.id) { 
            	return 0;
            }
            
            if (id > compareToObj.id) {
            	return 1;
            }
            return -1;  
        }
    }
    
    public class cls_links {
        public String self; 
        public String next;
    }
    
   /**
   	* Method to JSON Parser
    */ 
    public static Infl_EventsParser parse(String json) {
        return (Infl_EventsParser) System.JSON.deserialize(json, Infl_EventsParser.class);
    }
}