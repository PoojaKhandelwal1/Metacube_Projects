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
trigger UserTrigger on User(before insert, before update) {
    //Variables
    Integer refedgeLicense = 0;
    Integer communityLicense = 0;
    Integer refedgeUsedLicense = 0;
    Integer communityUsedLicense = 0;
    Boolean isLicenseIssued = false;
    boolean isOldKey = false;
    
    //Before context
    if (Trigger.isBefore) {
    	
        //Before insert
        if (Trigger.isInsert) {
        	
            for (User user : Trigger.new) {
            	
                if (user.isActive && user.Refedge_License_Type__c != null && user.Refedge_License_Type__c != '') {
                    isLicenseIssued = true;
                    break;
                }
            }
        } //END

        //Before update 
        if (Trigger.isUpdate) {
        	
            for (User user : Trigger.new) {
            	
                if ((Trigger.oldMap.get(user.Id).Refedge_License_Type__c != Trigger.newMap.get(user.Id).Refedge_License_Type__c) &&
                		user.Refedge_License_Type__c != null && user.Refedge_License_Type__c != '' && user.isActive) {
                    isLicenseIssued = true;
                    break;
                }
            }
        } //END
    }
    
    if (isLicenseIssued) {
        POR_App_Configuration__c cs = POR_App_Configuration__c.getOrgDefaults();
        
        if (cs.Edition_Key__c != null && cs.Edition_Key__c != '') {
        	
            try {
                string numberOfLicense = RefEdgeDecodingClass.getLicenseNumber(cs.Edition_Key__c);

                String[] licenses = numberOfLicense.split('###');
                
                if (licenses.size() > 0) {
                    refedgeLicense = Integer.valueOf(licenses[0]);
                }
                
                if (licenses.size() > 1) {
                    communityLicense = Integer.valueOf(licenses[1]);
                }
                refedgeUsedLicense = [SELECT count() FROM User WHERE Refedge_License_Type__c = 'Full License'];
                communityUsedLicense = [SELECT count() FROM User WHERE Refedge_License_Type__c = 'Community License'];
            } catch (Exception e) {
                isOldKey = true;
            }
        }
        
        //Before context
        if (Trigger.isBefore) {
        	
            //Before insert
            if (Trigger.isInsert) {
            	
                for (User user : Trigger.new) {
                	
                    //Refedge license
                    if (user.isActive && user.Refedge_License_Type__c == 'Full License') {
                    	
                        if (isOldKey) {
                            user.addError('If you want to issue Referencedge Professional License, Make sure you have updated the Edition Key also.');
                        } else {
                        	
                            if (refedgeLicense > 0 && refedgeUsedLicense >= refedgeLicense) {
                                user.addError('Referencedge Professional LICENSE LIMIT EXCEEDED');
                            } else {
                                refedgeUsedLicense++;
                            }
                        }
                    }

                    //Community license
                    if (user.isActive && user.Refedge_License_Type__c == 'Community License') {
                    	
                        if (isOldKey) {
                            user.addError('If you want to issue Referencedge Community License, Make sure you have updated the Edition Key also.');
                        } else {
                        	
                            if (communityLicense > 0 && communityUsedLicense >= communityLicense) {
                                user.addError('Referencedge Community LICENSE LIMIT EXCEEDED');
                            } else {
                                communityUsedLicense++;
                            }
                        }
                    }
                }
            } //END

            //Before update 
            if (Trigger.isUpdate) {
            	
                for (User user : Trigger.new) {
                	
                    if ((Trigger.oldMap.get(user.Id).Refedge_License_Type__c != Trigger.newMap.get(user.Id).Refedge_License_Type__c) 
                		&& user.isActive && user.Refedge_License_Type__c != null && user.Refedge_License_Type__c != '') {
                    	
                        //Refedge license
                        if (user.isActive && user.Refedge_License_Type__c == 'Full License') {
                        	
                            if (refedgeLicense > 0 && refedgeUsedLicense >= refedgeLicense) {
                                user.addError('Referencedge Professional LICENSE LIMIT EXCEEDED');
                            } else {
                                refedgeUsedLicense++;
                            }
                        }

                        //Community license
                        if (user.isActive && user.Refedge_License_Type__c == 'Community License') {
                        	
                            if (communityLicense > 0 && communityUsedLicense >= communityLicense) {
                                user.addError('Referencedge Community LICENSE LIMIT EXCEEDED');
                            } else {
                                communityUsedLicense++;
                            }
                        }
                    }
                }
            } //END
        }
    }
}