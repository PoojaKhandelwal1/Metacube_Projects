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
 * Description: This Infl_MemberJSON class is  use to create request json for new member/Nominee 
 * (AKA Contact made reference program member in refeddge) in influitive.
 * This class is added as part of influitive integration.
 * Author:- Narender Singh Tanwar
 * Last Modified By: Rajesh @Feb 4 2017
 */
public with sharing class Infl_MemberJSON { 
    private Map<String, Object> Infl_MemberJSON = new Map<String, Object>();
    	 
	/**
     * Method is use to Add object to json
     */
    public void add(String name, Object value) {
        this.Infl_MemberJSON.put(name, value);
    }   
    
    /**
     * This Method is use to convert object to json string
     */ 
    public String serialize() {
        return JSON.serialize(Infl_MemberJSON);      
    }
}