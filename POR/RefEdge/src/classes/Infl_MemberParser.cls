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
 * Description: This Infl_Member class is  use to call influitive api handler to create new member/Nominee 
 * (AKA Contact made reference program member in refeddge) in influitive.
 * This class is added as part of influitive integration and represent Member/Nominee in influitive.
 * Author:- Narender Singh Tanwar
 * Last Modified By: Rajesh @Feb 4 2017
 */

public with sharing class Infl_MemberParser { 
	/**
     * Properties and variables
     */
  	public Integer id; // Contactinfluitive_Id 
  	public String email;   
  	public String first_name;   
  	public String last_name;   
  	public Integer lifetime_points;  
  	public Integer current_points;  
   
  	public String type;  
  	public String salesforce_id;   
  	public String source; 
  	public String thumb;   
  	public String name; 
  	
   	/**
     * This method is to desearilize or convert json to object
     */
  	public static Infl_MemberParser parse(String json) {
    	return (Infl_MemberParser) System.JSON.deserialize(json, Infl_MemberParser.class);
  	}
}