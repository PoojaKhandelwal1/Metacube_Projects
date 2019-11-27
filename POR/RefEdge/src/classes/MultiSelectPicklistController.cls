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
 *	Component : POR_MultiSelectPicklist.component
 * 	Description : Class used to handel multi select pick list component
 * 	Last Modified By : Rajesh @Feb 4 2017
 */
public with sharing class MultiSelectPicklistController {
    /**
     * Properties and variables
     */
    public SelectOption[] leftOptions { get; set; }
    public SelectOption[] rightOptions { get; set; }
    
    /**
     * Method used to Parse &-separated values and labels from value and put them in option
     */ 
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        
        for (Integer i = 0; i < parts.size() / 2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i * 2], 'UTF-8'), EncodingUtil.urlDecode(parts[(i * 2) + 1], 'UTF-8')));
        }
    }
	
	/**
     * Method for hidden text field containing the options from the left list
     */ 
    public String leftOptionsHidden {
        get;
        set {
            leftOptionsHidden = value;
            setOptions(leftOptions, value);
        }
    }
    
	/**
     * Method for hidden text field containing the options from the right list
     */
    public String rightOptionsHidden {
        get;
        set {
            rightOptionsHidden = value;
            setOptions(rightOptions, value);
        }
    }
}