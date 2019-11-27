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
public with sharing class RefEdgeDecodingClass {
    /**
     * Properties and variables
     */
    private static String spclChar = 'Pneumonultamicrosc12';
    private static String licenseChar = 'Sclmmiro2';
    
    /**
     * Method to get Decoded Data
     */
    public static String getDecodedData(string encryptedstring) {
        try {
            if (encryptedstring.contains(spclChar)) {
                blob decryptedData = getDecryptedString(encryptedstring);
                return getFinalStringToEncrypt(decryptedData);
            } else
                return RefEdgeEditionConstants.BASIC;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return RefEdgeEditionConstants.BASIC;
        }
    }
    
    /**
     * Method to get license
     */
    private static boolean islicenseNumber = false;
    public static String getLicenseNumber(string encryptedstring) {
        islicenseNumber = true;
        blob decryptedData = getDecryptedString(encryptedstring);
        return getFinalStringToEncrypt(decryptedData);
    }
    
    /**
     * Method to get Final String 
     */
    private static string getFinalStringToEncrypt(blob decryptedData) {
        try {
            //String b64Decrypted = EncodingUtil.base64Encode(decryptedData);
            String b64Decrypted = decryptedData.toString();
            
            String edition = b64Decrypted.substringBetween(spclChar);
            String orgId = b64Decrypted.substringBeforeLast(spclChar).substringAfterLast(spclChar);
            
            //String salesforcelicense = b64Decrypted.substringBetween(licenseChar);
            //String communitylicense = b64Decrypted.substringBeforeLast(licenseChar).substringAfterLast(licenseChar);
            
            //system.assert(false, edition + '***'+orgId +'***'+salesforcelicense+'***'+communitylicense);
            if(islicenseNumber){
                b64Decrypted = decryptedData.toString();
                String salesforcelicense = b64Decrypted.substringBetween(licenseChar);
                String communitylicense = b64Decrypted.substringBeforeLast(licenseChar).substringAfterLast(licenseChar);
                return salesforcelicense+'###'+communitylicense;
            }
                
            if (!Test.isRunningTest() && orgId != userInfo.getOrganizationId().substring(0, 15))
                edition = RefEdgeEditionConstants.BASIC;
            return edition;
        } catch (Exception e) {
            throw e;
        }
    }
    /**
     * Method to get decrypted String
     */
    private static blob getDecryptedString(String encryptedstring) {
        try {
            blob encryptedData = EncodingUtil.base64Decode(encryptedstring.substringBefore(spclChar));
            blob key = EncodingUtil.base64Decode(encryptedstring.substringAfter(spclChar));
            blob decryptedData = Crypto.decryptWithManagedIV('AES256', key, encryptedData);
            return decryptedData;
        } catch (Exception e) {
            throw e;
        }
    }
}