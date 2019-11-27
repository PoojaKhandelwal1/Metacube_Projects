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
public class ConetntWrapper {
    /**
     * Properties and variables
     */
    public Boolean isSelected {
        get;
        set;
    }
    public Reference_Content__c refContent {
        get;
        set;
    }
    public ContentVersion contentVersion {
        get;
        set;
    }
    public String fileTypeImagePath {
        get;
        set;
    }
    public String accountName {
        get;
        set;
    }
    public String accountIds {
        get;
        set;
    }
    /**
     * Constructor
     */
    public ConetntWrapper(Reference_Content__c refContent, ContentVersion contentVersion, String accountName, String accountIds) {
        this.isSelected = false;
        this.refContent = refContent;
        this.contentVersion = contentVersion;
        this.fileTypeImagePath = (UtilityController.mapDocumentPath.containsKey(contentVersion.FileType) ? UtilityController.mapDocumentPath.get(contentVersion.FileType) : '/assets/icons/doctype/unknown_60.png');
        this.accountName = accountName;
        this.accountIds = accountIds;
    }
}