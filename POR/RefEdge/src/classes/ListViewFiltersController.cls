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
 * Related Resource: ListViewFilterDirective
 * Description: controller for editing list filters for list views and creating new list views
 * author: Gaurav Saini (8 Feb, 2018)
 */
public with sharing class ListViewFiltersController extends RefEdgeEditionFeatures {

    public ListViewFiltersController(ApexPages.StandardSetController controller) {}
    public ListViewFiltersController(ApexPages.StandardController controller) {}
    //#1183 : Ref Workspace
    public ListViewFiltersController(ReferenceWorkspaceSLDSController controller) {}

    /**
     * Method to get date format according to current user's locale
     * author: Gaurav Saini (14 Feb, 2018) for #1299
     */
    @RemoteAction
    public static String getDateFormat() {
        String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		return (dateFormat != null ? dateFormat : 'yyyy-MM-dd');
    }

    /**
     * method to get reference lead records
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getListViewFilters(String listViewId, String processName) {
        List<FilterWrapper> filtersList = new List<FilterWrapper>();
        
        String query = 'SELECT Id, Label__c, Visible__c, Field_API_Name__c, Default_Value__c, Order__c, From_Mapping__c FROM User_Mapping__c';
        query += ' WHERE Process__c = :processName AND Label__c = :listViewId';
        
        if(processName != 'AttMappingFilters') {
        	Id loggedInUserId = UserInfo.getUserId();
        	query += ' AND User__c =: loggedInUserId';
        }
        List<User_Mapping__c> userMappingsList = Database.query(query);
        
        if (userMappingsList != null && userMappingsList.size() > 0) {

            for (User_Mapping__c um : userMappingsList) {
                filtersList.add(new FilterWrapper(um));
            }
        }
        return JSON.serialize(filtersList);
    }

    /**
     * method to get View Record
     * author: Dixita Jain (March, 2017)
     */
    @RemoteAction
    public static String getListViewRecord(String listViewId, String processName) {
        User_Mapping__c viewSelected = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, Default_Value__c, Order__c, From_Mapping__c
                                        FROM User_Mapping__c
                                        WHERE Process__c = :processName
                                        AND Id = :listViewId
                                        LIMIT 1];
        Map<String,Object> returnMap = new Map<String,Object>();
        returnMap.put('Label__c', viewSelected.Label__c);
        returnMap.put('Visible__c', viewSelected.Visible__c);
        returnMap.put('Field_API_Name__c', viewSelected.Field_API_Name__c);
        returnMap.put('Id', viewSelected.Id);
        returnMap.put('Default_Value__c', viewSelected.Default_Value__c);
        returnMap.put('Order__c', viewSelected.Order__c);
        returnMap.put('From_Mapping__c', viewSelected.From_Mapping__c);
        return JSON.serialize(returnMap);
    }

    /**
    * method to check If name provided is unique View Record
    * author: Dixita Jain (March, 2017)
    */
    @RemoteAction
    public static String isNameUnique(String listViewName, String processName) {
        List<User_Mapping__c> viewSelected = [SELECT Id, Label__c, Visible__c, Field_API_Name__c, Default_Value__c, Order__c, From_Mapping__c
                                        FROM User_Mapping__c 
                                        WHERE Process__c = :processName 
                                        AND User__c = :UserInfo.getUserId()
                                        AND Label__c = null
                                        AND Field_API_Name__c = :listViewName];
        Boolean response = viewSelected.size() > 0 ? false : true  ;
        return JSON.serialize(response);
    }

    /**
     * method to get reference lead records
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String getFieldsList(String objMap) {
        try {
            Map<String,String> objectMap = (Map<String,String>) JSON.deserialize(objMap , Map<String,String>.class);
            Map<String,List<FieldWrapper>> fieldsMap = new Map<String,List<FieldWrapper>>();
            
            for (String objLabel : objectMap.keySet()) {
                String objName = objectMap.get(objLabel);
                Map<String, Schema.sObjectField> fieldMap = CRUDAndFLSCheckController.sObjectsMap.get(objName).getDescribe().fields.getMap();
                List<FieldWrapper> fieldsList = new List<FieldWrapper>();
                
                for (String apiName : fieldMap.keySet()) {
                    Schema.DescribeFieldResult dfr = fieldMap.get(apiName).getDescribe();

                    if (String.valueOf(dfr.getType()) != 'TEXTAREA'
                            && String.valueOf(dfr.getType()) != 'ADDRESS'
                            && String.valueOf(dfr.getName()) != 'BillingGeocodeAccuracy'
                            && String.valueOf(dfr.getName()) != 'ShippingGeocodeAccuracy') {
                        fieldsList.add(new FieldWrapper(dfr));
                    }
                }
                fieldsMap.put(objName,fieldsList);
            }
            return JSON.serialize(fieldsMap);
        } catch (Exception ex) {
            return null;
		}
    }
    

    /**
     * method to get reference lead records
     * author: Gaurav Saini (13 Oct, 2017)
    
    @RemoteAction
    public static String getFieldsList(String objName) {
        List<FieldWrapper> fieldsList = new List<FieldWrapper>();
        objName = objName.endsWith('__c') ? UtilityController.appNamespace() + objName : objName;
        Map<String, Schema.sObjectField> fieldMap = CRUDAndFLSCheckController.sObjectsMap.get(objName).getDescribe().fields.getMap();

        for (String apiName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(apiName).getDescribe();

            if (String.valueOf(dfr.getType()) != 'TEXTAREA'
                    && String.valueOf(dfr.getType()) != 'ADDRESS'
                    && String.valueOf(dfr.getName()) != 'BillingGeocodeAccuracy'
                    && String.valueOf(dfr.getName()) != 'ShippingGeocodeAccuracy') {
                fieldsList.add(new FieldWrapper(dfr));
            }
        }
        return JSON.serialize(fieldsList);
    }
    */

    /**
     * method to get reference lead records
     * author: Gaurav Saini (13 Oct, 2017)
     */
    @RemoteAction
    public static String saveUserMappings(Boolean isNewListView, String filtersListJson, String viewName,
                                            String listViewId, String processName, String objectName) {
        Savepoint sp = Database.setSavepoint();
    	String result = '';
    	
    	try {
            List<FilterWrapper> filtersList = (List<FilterWrapper>)JSON.deserialize(filtersListJson, List<FilterWrapper>.class);
            List<FilterWrapper> resultFiltersList = new List<FilterWrapper>();
            Integer filterOrder = 1;
            List<User_Mapping__c> userMappingsToInsert = new List<User_Mapping__c>();

            if (!isNewListView && processName != 'AttMappingFilters') {
                List<User_Mapping__c> userMappingsList = [SELECT Id, Label__c, Field_API_Name__c, Default_Value__c, Order__c, From_Mapping__c, Visible__c
                                                            FROM User_Mapping__c
                                                            WHERE Process__c = :processName
                                                            AND User__c = :UserInfo.getUserId()
                                                            AND Label__c = :listViewId
                                                            ORDER BY Order__c];

                if (userMappingsList != null && userMappingsList.size() > 0) {
                    delete userMappingsList;
                }

                if (filtersList != null && filtersList.size() > 0) {

                    for (FilterWrapper filter : filtersList) {
                        User_Mapping__c tempUM = new User_Mapping__c();
                        tempUM.User__c = UserInfo.getUserId();
                        tempUM.Process__c = processName;
                        tempUM.Visible__c = true;
                        tempUM.Label__c = listViewId;
                        tempUM.Order__c = filterOrder;
                        tempUM.Default_Value__c = filter.fieldValue;
                        tempUM.Field_API_Name__c = filter.fieldApiName + '::' + filter.fieldLabel + '::'
                                                    + filter.fieldType + '::' + filter.operator + '::' + filter.objectName;
                        userMappingsToInsert.add(tempUM);
                        filterOrder += 1;
                    }
                    insert userMappingsToInsert;

                    for (User_Mapping__c um : userMappingsToInsert) {
                        resultFiltersList.add(new FilterWrapper(um));
                    }
                }
                result = listViewId;
            } else if (processName != 'AttMappingFilters') {
                User_Mapping__c newListView = new User_Mapping__c();
                newListView.Field_API_Name__c = viewName;
                newListView.Process__c = processName;
                newListView.User__c = UserInfo.getUserId();
                newListView.From_Mapping__c = true;
                
                if (filtersList != null && filtersList.size() > 0) { 
                    
                    for (FilterWrapper filter : filtersList) {
                        
                        if (!objectName.contains(filter.objectName)) {
                            objectName += ',' + filter.objectName;
                        }
                    }
                }
                newListView.Default_Value__c = objectName;
                insert newListView;

                if (filtersList != null && filtersList.size() > 0) {

                    for (FilterWrapper filter : filtersList) {
                        User_Mapping__c tempUM = new User_Mapping__c();
                        tempUM.User__c = UserInfo.getUserId();
                        tempUM.Process__c = processName;
                        tempUM.Label__c = newListView.Id;
                        tempUM.Order__c = filterOrder;
                        tempUM.Visible__c = true;
                        tempUM.Default_Value__c = filter.fieldValue;
                        tempUM.Field_API_Name__c = filter.fieldApiName + '::' + filter.fieldLabel + '::'
                                                    + filter.fieldType + '::' + filter.operator + '::' + filter.objectName;
                        userMappingsToInsert.add(tempUM);
                        filterOrder += 1;
                    }
                    insert userMappingsToInsert;

                    for (User_Mapping__c um : userMappingsToInsert) {
                        resultFiltersList.add(new FilterWrapper(um));
                    }
                }
                result = String.valueOf(newListView.Id);
            } else if (processName == 'AttMappingFilters') {
                List<User_Mapping__c> userMappingsList = [SELECT Id FROM User_Mapping__c WHERE Process__c = :processName
                                                            AND Label__c = :listViewId ORDER BY Order__c];

                if (userMappingsList != null && userMappingsList.size() > 0) {
                    delete userMappingsList;
                }

                if (filtersList != null && filtersList.size() > 0) {

                    for (FilterWrapper filter : filtersList) {
                        User_Mapping__c tempUM = new User_Mapping__c();
                        tempUM.Process__c = processName;
                        tempUM.Label__c = listViewId;
                        tempUM.Order__c = filterOrder;
                        tempUM.Visible__c = true;
                        tempUM.Default_Value__c = filter.fieldValue;
                        tempUM.Field_API_Name__c = filter.fieldApiName + '::' + filter.fieldLabel + '::'
                                                    + filter.fieldType + '::' + filter.operator + '::' + filter.objectName;
                        userMappingsToInsert.add(tempUM);
                        filterOrder += 1;
                    }
                    insert userMappingsToInsert;
                    result = 'success';
                }
            }
        } catch(Exception e) {
    		Database.rollback(sp);
    		result = 'Error' + e.getMessage();
    	}
    	return result;
    }

    public class FilterWrapper {

        public String userMappingId { get; set; }
        public String listViewId { get; set; }
        public String fieldApiName { get; set; }
        public String fieldLabel { get; set; }
        public String fieldType { get; set; }
        public String operator { get; set; }
        public String fieldValue { get; set; }
        public String objectName { get; set; }
        public Boolean visible { get; set; }
        public List<PicklistOptionWrapper> selectedPicklistValues { get; set; }
        public Boolean isNew { get; set; }
        public Boolean showEditPopover { get; set; }
        public Boolean isEditable { get; set; }
        public Boolean isValid { get; set; }
        public String errorMessage { get; set; }

        public FilterWrapper(User_Mapping__c um) {
            this.userMappingId = um.Id;
            this.listViewId = um.Label__c != null ? String.valueOf(um.Label__c) : '';
            this.fieldApiName = um.Field_API_Name__c != null ? um.Field_API_Name__c.split('::')[0] : '';
            this.fieldLabel = um.Field_API_Name__c != null ? um.Field_API_Name__c.split('::')[1] : '';
            this.fieldType = um.Field_API_Name__c != null ? um.Field_API_Name__c.split('::')[2] : '';
            this.operator = um.Field_API_Name__c != null ? um.Field_API_Name__c.split('::')[3] : '';
            this.objectName = um.Field_API_Name__c != null && um.Field_API_Name__c.split('::').size() > 4 ? um.Field_API_Name__c.split('::')[4] : '';
            this.selectedPicklistValues = new List<PicklistOptionWrapper>();
            this.visible = um.Visible__c != null ? um.Visible__c : true; 
            this.isNew = false;
            this.showEditPopover = false;
            this.isEditable = (this.fieldApiName.containsIgnoreCase('Opportunity')) ? false : true;
            this.isValid = true;
            this.errorMessage = '';

            if (this.fieldType == 'PICKLIST' || this.fieldType == 'MULTIPICKLIST') {
                this.fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
            } else if (this.fieldType == 'BOOLEAN') {
                this.fieldValue = um.Default_Value__c != null ? um.Default_Value__c : 'false';
            } else {
                this.fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
            }
        }
    }

    public class FieldWrapper {

        public String apiName { get; set; }
        public String label { get; set; }
        public String fieldType { get; set; }
        public List<PicklistOptionWrapper> picklistOptions { get; set; }

        public FieldWrapper(Schema.DescribeFieldResult dfr) {
            this.apiName = String.valueOf(dfr.getName());
            this.label = String.valueOf(dfr.getLabel());
            this.fieldType = String.valueOf(dfr.getType());
            this.picklistOptions = new List<PicklistOptionWrapper>();

            if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {

                for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
                    this.picklistOptions.add(new PicklistOptionWrapper(ple.getValue(), ple.getLabel()));
                }
            }
        }
    }

    public class PicklistOptionWrapper {

        public String name { get; set; }
        public String label { get; set; }
        public Boolean isSelected { get; set; }

        public PicklistOptionWrapper(String name, String label) {
            this.name = name;
            this.label = label;
            this.isSelected = false;
        }
    }
}