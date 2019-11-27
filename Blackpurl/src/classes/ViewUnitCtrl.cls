/**
 * Author: Nidhi Sharma
 * Since: August 03, 2016
 * Name: ViewUnitCtrl
 * Description: Controller class to handle methods for View Unit page
**/

global without sharing class ViewUnitCtrl {
    
    public static Decimal MAX_HEAP_SIZE = 5000000;
    global ViewUnitCtrl (NewHomePageCtrl controller){}
    public ViewUnitCtrl() {}
    
    /**
     * Name: getUnitDetails
     * Desc: To get unit Record JSON String
     * @param:  (1) unitId - String - Unit Object record id
     * @return: String - Unit JSON String.
    **/
    @remoteAction 
    global static String getUnitDetails(String unitId) {
        unitId = BPUtility.getDecodedString(unitId);
        if(String.isBlank(unitId)){
            return BPUtility.getEncodedString('{}');
        }
        List<Customer_Owned_Unit__c> unitList = SOQLUtil.getUnitByFieldName(new Map<String, String>{'Id' => unitId});
        if(unitList.size() == 0) {
            return BPUtility.getEncodedString('{}');
        }
        String vinNumber = unitList[0].VIN_Number__c;
        List<Customer_Owned_Unit__c> similarUnits = new List<Customer_Owned_Unit__c>(); 
        if(String.isNotBlank(vinNumber)) {
            similarUnits = SOQLUtil.getUnitByFieldName(new Map<String, String>{'VIN_Number__c' => vinNumber});
        }
        List<Sales_Tax__c> salesTaxList = SOQLUtil.getSalesTax(new List<Id>());
            
        List<Service_Order_Header__c> soList = SOQLUtil.getUnitServiceOrdersByUnitId(new Set<Id>{unitId}); // Added by richa 24/01/2017 for retrieving SO's for a unit
        //System.assert(false, soList);
        UnitWrapper unitWrapperObj = new UnitWrapper(unitList[0], similarUnits, salesTaxList, soList);  // soList Added by richa 24/01/2017 for retrieving SO's for a unit
        //return System.JSON.serialize(unitWrapperObj);
        return BPUtility.getEncodedString(System.JSON.serialize(unitWrapperObj));
       
    }
    
   /**
    * Name: saveNotesForUnit
    * Desc: Method Which saves notes for unit in Database 
    * @param:   (1) unitId - String - Unit record Id
    *           (2) notes - String - Notes of Unit record
    * @return: 
    **/
    @RemoteAction
    global static void saveNotesForUnit(String unitId, String notes) {
        
        unitId = BPUtility.getDecodedString(unitId);
        notes = BPUtility.getDecodedString(notes);
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c(); 
        if(unitId != null){ 
            couRec.Id = unitId;
            couRec.Notes__c = notes;
            update couRec;
        }
    }
    
    /**
    * Name: saveUnit
    * Desc: Method Which saves unit in Database 
    * @param:   (1) unitId - String - Unit record Id
    *           (2) jSONString - String - JSON String of Unit record
    * @return: String - JSON String of CO Header Detail Record
    **/
    @RemoteAction
    global static String saveUnit(String jSONString) {
        
        jSONString = BPUtility.getDecodedString(jSONString);
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        UnitWrapper unitObj = (UnitWrapper) System.JSON.deserialize(jSONString, UnitWrapper.class);
        Customer_Owned_Unit__c couRec = setUnitFields(unitObj.UnitInfo); 
        if(unitObj.UnitInfo.Id != null){ 
            couRec.Id = unitObj.UnitInfo.Id;
        }
        upsert couRec;
        return getUnitDetails(BPUtility.getEncodedString(unitObj.UnitInfo.Id));
    }
    
    @RemoteAction
    global static String getCustomerInfo(String customerId) {
        return CustomerOrderCtrl.getRecordById(customerId);
    }
    
    /**
    * Name: savePriceAndCost
    * Desc: Method Which saves unit price and cost in Database 
    * @param:   (1) jSONString - String - Unit price and cost string
    * @return: String - json result string
    **/
    @RemoteAction
    global static String savePriceAndCost(String unitId, String jSONString) {
        
        unitId = BPUtility.getDecodedString(unitId);
        jSONString = BPUtility.getDecodedString(jSONString);
        //System.assert(false, jSONString);
        if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostObj = (UnitWrapper.PriceAndCostTrackingWrapper) System.JSON.deserialize(jSONString, UnitWrapper.PriceAndCostTrackingWrapper.class);
        Unit_Price_Cost__c unitPriceAndCostRec = setUnitPriceAndCostFields(unitPriceAndCostObj); 
        if(String.isNotBlank(unitPriceAndCostObj.Id)) {
            if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update unitPriceAndCostRec;
        } else {
            if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert unitPriceAndCostRec;
        }
        List<Customer_Owned_Unit__c> unitList = SOQLUtil.getUnitByFieldName(new Map<String, String>{'Id' => unitId});
        if(unitList.size() == 0) {
            return BPUtility.getEncodedString('[{}]');
        }
        
        UnitWrapper unitWrapperObj = new UnitWrapper(unitList[0], new List<Customer_Owned_Unit__c>(), new List<Sales_Tax__c>(), new List<Service_Order_Header__c>()); // new List<Service_Order_Header__c>() Added by richa 24/01/2017 for retrieving SO's for a unit
        
        return BPUtility.getEncodedString(System.JSON.serialize(unitWrapperObj.PriceAndCostTrackingWrapperList));
    }
    
    /**
     * Name: removeCOURecord
     * Desc: Remove Record with given Id
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String removePriceAndCost(String unitId, String recordId) {
        unitId = BPUtility.getDecodedString(unitId);
        recordId = BPUtility.getDecodedString(recordId);
        
        List<Sobject> sobjectListToDel = SOQLUtil.getReocrdByGivenId(recordId);
        if(sobjectListToDel.size() > 0) {
            if(AccessControl.ifObjectIsDeletable(sobjectListToDel[0]) == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete sobjectListToDel[0];
        }
        return getUnitDetails(BPUtility.getEncodedString(unitId));
    }
    
    /**
    * Name: uploadImage
    * Desc: Method to upload image
    * @param: (1) filename - String - File Name
    *         (2) fileData - String - File to be uploaded
    *         (3) recordId - String - Parent Id of attachment
    *         (4) description - String - Description of attachment
    * @return: void
    **/
    @RemoteAction
    global static String uploadImage(String filename, String fileData, String recordId) {
        try {
            filename = BPUtility.getDecodedString(filename);
            fileData = BPUtility.getDecodedString(fileData);
            if(Limits.getHeapSize() > MAX_HEAP_SIZE) {
                return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'File size is large')));
            }
            recordId = BPUtility.getDecodedString(recordId);
            
            if(fileData == null) {
                return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'Invalid file data')));
            }
            String base64 = fileData.substring(fileData.indexOf(',') + 1);
            Blob actualdata = EncodingUtil.base64Decode(base64);
            if(AccessControl.ifObjectFieldIsAccessible('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Document__c> existingImageList = [SELECT id FROM Document__c where Unit__c = :recordId];
            Document__c newDoc = new Document__c();
            newDoc.Is_Primary__c = existingImageList.size() == 0 ? true : false;
            newDoc.Unit__c = recordId;
            if(AccessControl.ifObjectFieldIsCreateable('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert newDoc;
            Attachment att = new Attachment(ParentId = newDoc.Id, Body = actualdata);
            att.Name = filename;
            if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert(att);
            
            return getDocumentsList(BPUtility.getEncodedString(recordId));
        } catch(Exception e){
            return BPUtility.getEncodedString(System.JSON.serialize(new ResponseWrapper('error', 'File size is large')));
        }
        return BPUtility.getEncodedString('');
    }
    
    /**
    * Name: getDocumentsList
    * Desc: Method to get all images of  unit
    * @param: (1) unitId - String - unit id
    * @return: void
    **/
    @remoteAction
    global static String getDocumentsList(String unitId) {
        unitId = BPUtility.getDecodedString(unitId);
        if(AccessControl.ifObjectFieldIsAccessible('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Document__c> docList = [select Id, Is_Primary__c, 
                                        (select Id, Name from Attachments) from Document__c where Unit__c = :unitId order By CreatedDate ASC];
        if(docList.size() == 0) {
            return BPUtility.getEncodedString('[]');
        }
        
        List<UnitWrapper.Documents> imageList = new List<UnitWrapper.Documents>();
        for(Document__c doc : docList) {
            imageList.add(new UnitWrapper.Documents(doc));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(imageList));
    }
    
    /**
    * Name: pinImage
    * Desc: Method to set primary image for unit
    * @param: (1) docId - String - document id
              (2) IsPrimary - Boolean - whether to set image primary
              (3) unitId - String - unit id
    * @return: void
    **/
    @remoteAction
    global static String pinImage(String docId, Boolean IsPrimary, String unitId) {
        docId = BPUtility.getDecodedString(docId);
        unitId = BPUtility.getDecodedString(unitId);
        if(String.isNotBlank(docId)) {
            List<Document__c> docList = [select Id, Is_Primary__c from Document__c where Unit__c = :unitId and Is_Primary__c = true];
            for(Document__c doc: docList) {
                doc.Is_Primary__c = false;
            }
            if(AccessControl.ifObjectFieldIsUpdateable('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            Document__c docToUpdate = new Document__c();
            docToUpdate.Id = docId;
            docToUpdate.Is_Primary__c = IsPrimary;
            docList.add(docToUpdate);
            update docList;
        }
        
        return BPUtility.getEncodedString('Success');
    }
    
    /**
    * Name: deleteImage
    * Desc: Method to delete the image and set the next in order image to be the primary image if deleted image is primary
    * @param: (1) docId - String - document id to delete
              (2) unitId - String - unit id
    * @return: String
    **/
    @remoteAction
    global static String deleteImage(String docId, String unitId) {
        docId = BPUtility.getDecodedString(docId);
        unitId = BPUtility.getDecodedString(unitId);
        Boolean setPrimary = false;
        if(String.isNotBlank(docId)) {
            if(AccessControl.ifObjectFieldIsAccessible('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Document__c> docList = [select id, Is_Primary__c from Document__c where id =: docId];
            if(docList.size() > 0) {
                if(docList[0].Is_Primary__c) {
                    setPrimary = true;
                }
                if(AccessControl.ifObjectIsDeletable('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                if(AccessControl.ifObjectIsDeletable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
                delete docList;
            }
            
        }
        if(setPrimary) {
            List<Document__c> docList = [select Id, Is_Primary__c from Document__c where Unit__c = :unitId Order By CreatedDate ASC];
            if(docList.size() > 0) {
                docList[0].Is_Primary__c = true;
                update docList;
            }
        }
        
        return getDocumentsList(BPUtility.getEncodedString(unitId));
    }
    
    @remoteAction
    global static String getMakeModelSubmodelList() {
        try {
    	   return BPUtility.getEncodedString(MakeModelSubModelService.getMakeModelSubmodelList());
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static Customer_Owned_Unit__c setUnitFields(UnitWrapper.UnitInfoWrapper unitInfoObj) {
        
        Customer_Owned_Unit__c couRec = new Customer_Owned_Unit__c();

        couRec.Applicable_Tax__c = unitInfoObj.ApplicableTax;
        couRec.Automatic__c = (unitInfoObj.IsAutomatic != null) ? unitInfoObj.IsAutomatic : false;
        couRec.Account__c = unitInfoObj.Customer;
        couRec.Cylinders__c = unitInfoObj.Cylinders;
        couRec.Colour__c = unitInfoObj.ExteriorColour;
        couRec.Category__c = unitInfoObj.Category;
        couRec.Date_Stocked_In__c = String.isNotBlank(unitInfoObj.DateIn) ? Date.parse(unitInfoObj.DateIn) : null; 
        couRec.Date_Stocked_Out__c = String.isNotBlank(unitInfoObj.DateOut) ? Date.parse(unitInfoObj.DateOut) : null;
        couRec.Displacement__c = unitInfoObj.Displacement;
        couRec.Engine_Serial_No__c = unitInfoObj.EngineSerialNo;
        couRec.Gears__c = unitInfoObj.Gears;
        couRec.Interior_Colour__c = unitInfoObj.InteriorColour;
        couRec.Key_No__c = unitInfoObj.KeyNo;
        couRec.Location__c = unitInfoObj.Location;
        couRec.Manufactured_Date__c = String.isNotBlank(unitInfoObj.ManufacturedDate) ? Date.parse(unitInfoObj.ManufacturedDate) : null;
        couRec.Reg_Expiry_Date__c = String.isNotBlank(unitInfoObj.RegExpiryDate) ? Date.parse(unitInfoObj.RegExpiryDate) : null;
        couRec.Mileage_Value__c = unitInfoObj.Mileage;
        couRec.Mileage_Type__c = unitInfoObj.MileageType;
        couRec.Notes__c = unitInfoObj.Notes;
        couRec.New_Unit__c = (unitInfoObj.IsNewUnit != null) ? unitInfoObj.IsNewUnit : false;
        couRec.Other_Serial_No__c = unitInfoObj.OtherSerialNo;
        couRec.Plate__c = unitInfoObj.Plate;
        couRec.Status__c = unitInfoObj.Status;
        couRec.Sub_Model__c = unitInfoObj.SubModel;
        couRec.Taxable__c = (unitInfoObj.IsTaxable != null) ? unitInfoObj.IsTaxable : false;
        couRec.Unit_Id__c = unitInfoObj.UnitId;
        couRec.Unit_Make__c = unitInfoObj.Make;
        couRec.Unit_Model__c = unitInfoObj.Model;
        couRec.Unit_Type__c = unitInfoObj.UnitType;
        couRec.VIN_Number__c = unitInfoObj.VIN;
        couRec.Year__c = unitInfoObj.Year;
        couRec.Vendor__c = unitInfoObj.VendorId;
        couRec.Stock_Id__c = unitInfoObj.StockNumber;
        couRec.Compliance_Date__c = unitInfoObj.ComplianceDate;
        couRec.Registration_Serial__c = unitInfoObj.RegistrationSerial;
        couRec.Year_Of_1st_Rego__c = unitInfoObj.YearOf1stRego;
        
        return couRec;
    }
    
    private static Unit_Price_Cost__c setUnitPriceAndCostFields(UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostObj) {
        
        Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c();

        unitPriceAndCostRec.Id = unitPriceAndCostObj.Id;
        unitPriceAndCostRec.Type__c = unitPriceAndCostObj.Type;
        unitPriceAndCostRec.Ref_No__c = unitPriceAndCostObj.RefNo;
        unitPriceAndCostRec.Item_Description__c = unitPriceAndCostObj.ItemDescription;
        unitPriceAndCostRec.Qty__c = unitPriceAndCostObj.Quantity;
        unitPriceAndCostRec.Price__c = unitPriceAndCostObj.Price;
        if(unitPriceAndCostRec.Type__c == 'Factory' || unitPriceAndCostRec.Type__c == 'Base') {
            unitPriceAndCostRec.Price__c = unitPriceAndCostObj.TotalPrice;
        }
        unitPriceAndCostRec.Total_Price__c = unitPriceAndCostObj.TotalPrice; 
        unitPriceAndCostRec.Total_Cost__c = unitPriceAndCostObj.TotalCost;
        unitPriceAndCostRec.Customer_Owned_Unit__c= unitPriceAndCostObj.UnitId;// Added by kajal - 11/17/2016 - #1293 
        return unitPriceAndCostRec;
    }
}