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
public class AccountWrapper {
    /**
     * Properties and variables
     */
    public Reference_Basic_Information__c acc {
        get;
        set;
    }
    public boolean isSelected {
        get;
        set;
    }
    public Integer relatedAR {
        get;
        set;
    }
    public Integer hitListCount{
        get;
        set;
    }
    public string accountId{
    	get;
    	set;
	}
	public boolean isAlreadyHit{
    	get;
    	set;
	} 
	public Integer refContentCount{
    	get;
    	set;
	}
	
    /**
     * Constructor
     */
    public AccountWrapper(Reference_Basic_Information__c acc, integer hitList, boolean isAlreadyHit, Integer refContentCount) {
        this.isSelected = false;
        this.acc = acc;
        this.hitListCount = hitList;
        this.accountId = acc.Account__r.Id;
        this.relatedAR = 0;
        this.isAlreadyHit = isAlreadyHit;
        this.refContentCount = refContentCount;
    }
    /**
     * Constructor
     */
    public AccountWrapper(Reference_Basic_Information__c acc, Integer relatedAR, Integer hitList, Boolean isAlreadyHit, Integer refContentCount) {  
        this.isSelected = false;
        this.acc = acc;
        this.relatedAR = (relatedAR > 0? relatedAR : 0);
        this.hitListCount = hitList;
        this.accountId = acc.Account__r.Id;
        this.isAlreadyHit = isAlreadyHit;
        this.refContentCount = refContentCount;
    }
    
    
    
    /**
     * Constructor
     */
    public AccountWrapper(Boolean isSelected, Reference_Basic_Information__c acc,integer hitList, boolean isAlreadyHit) {
        this.isSelected = isSelected;
        this.acc = acc;
        this.hitListCount = hitList;
        this.accountId = acc.Account__r.Id;
        this.relatedAR = 0;
        this.isAlreadyHit = isAlreadyHit;
    }
    /**
     * Constructor
     */
    public AccountWrapper(Boolean isSelected, Reference_Basic_Information__c acc, integer relatedAR,integer hitList, boolean isAlreadyHit) {
        this.isSelected = isSelected;
        this.acc = acc;
        this.relatedAR = (relatedAR > 0? relatedAR : 0);
        this.hitListCount = hitList;
        this.accountId = acc.Account__r.Id;
        this.isAlreadyHit = isAlreadyHit;
    }
}