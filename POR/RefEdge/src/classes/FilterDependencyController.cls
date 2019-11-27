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
 * VF Page: FilterDependencySetting.page
 * Description: 
 * Last Modified By: Dixita @April 2019 REF-2130
 */
 public with sharing class FilterDependencyController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public String dateFormat { get; set; }
    public String todayDate { get; set; }
    public static Boolean isSLDS {
        get {
            if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
                isSLDS = true;       
            } else {
                isSLDS = false;  
            }
            return isSLDS;
        }
        set {}
    }
    public static String cs {
        get {
            return UtilityController.getCustomSettings().Id;
        }
        set {}
    }
    /**
     * Constructor
     */
    public FilterDependencyController() {
        dateFormat = ConstantsController.localeDateFormatMap.containsKey(UserInfo.getLocale())
                    ? ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0) : 'yyyy-MM-dd';
        todayDate = Date.today().year() + '-' + Date.today().month() + '-' + Date.today().day();
    }
    
    /**
     * RemoteAction to get Filter Dependency List
     */
    @RemoteAction
    public static String getFilterDependencyList() {
        List<String> returnList = new List<String>();
        List<FilterDependecyWrapper> filterist = new List<FilterDependecyWrapper>();
        Map<Id,String> filterId = new Map<Id,String>();
        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, Default__c, Visible__c, Object__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                    AND From_Mapping__c = true]) {
            filterId.put(dm.Label__c,'');  
            filterId.put(dm.Field_API_Name__c,''); 
            filterist.add(new FilterDependecyWrapper(dm));                
        }

        for (Label__c filter : [SELECT Id, Name ,(SELECT Id FROM Attributes_Labels__r LIMIT 1) FROM Label__c ORDER BY Name desc LIMIT :limits.getLimitQueryRows()]) {
            
            if (filterId.containsKey(filter.Id)) {
                filterId.put(filter.Id,filter.Name);  
            } else if (filter.Attributes_Labels__r.size() > 0) {
                filterId.put(filter.Id,filter.Name);
            }
        }
        returnList.add(JSON.serialize(filterist));
        returnList.add(JSON.serialize(filterId));
        return JSON.serialize(returnList);
    }
    

    /**
     * RemoteAction to get Attribute Dependency List 
     */
    @RemoteAction
    public static String getAttributeDependencyList(String dmRecord, String cfIdListString, String isNew) {
        try {
            Integer dataLimit = 50;
            List<String> cfId = cfIdListString == null || cfIdListString == '' ? new List<String>() : (List<String>)JSON.deserialize(cfIdListString,List<String>.class);
            Boolean firstCall = cfIdListString == null || cfIdListString == '' || cfIdListString == '';
            FilterDependecyWrapper dmwrapper = isNew == 'false' ? (FilterDependecyWrapper)JSON.deserialize(dmRecord,FilterDependecyWrapper.class) : new FilterDependecyWrapper(dmRecord.split(';')[0],dmRecord.split(';')[1]);
            Map<String,String> selectedAtt = new Map<String,String>();
            Map<String,String> controllingAttributes = new Map<String,String>();
            List<ControllingWrapper> controllingList = new List<ControllingWrapper>();
            List<String> returnList = new List<String>();
            
            for (Attributes_Labels__c attFilter : [SELECT Id, Attribute__c,Attribute__r.Name, Label__c, Label__r.Name FROM Attributes_Labels__c
                                        WHERE Label__c = :dmwrapper.cfId AND Attribute__c NOT IN :cfId ORDER BY Attribute__r.Name ASC LIMIT :dataLimit]) {
                if (isNew == 'false') {
                    controllingAttributes.put(attFilter.Attribute__c, attFilter.Attribute__r.Name);
                } else {
                    controllingList.add(new ControllingWrapper(attFilter.Attribute__c, attFilter.Attribute__r.Name, new List<String>()));
                }
            }
            
            if (isNew == 'false') {
                for (Data_Mapping__c dm : [SELECT Section_Name__c, Default__c
                                            FROM Data_Mapping__c
                                            WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                            AND From_Mapping__c = false 
                                            AND Section_Name__c IN :controllingAttributes.keySet()
                                            AND Data_Collector_Name__c =:dmwrapper.dmRecord]) {
                    selectedAtt.put(dm.Section_Name__c,dm.Default__c);
                }
                for (String id : controllingAttributes.keySet()) {
                    if (selectedAtt.containsKey(id) && selectedAtt.get(id) != null && selectedAtt.get(id) != '') {
                        controllingList.add(new ControllingWrapper(id, controllingAttributes.get(id), selectedAtt.get(id).split(';')));
                    } else {
                        controllingList.add(new ControllingWrapper(id, controllingAttributes.get(id), new List<String>()));
                    }
                }
            }
            if (firstCall) {
                returnList.add(JSON.serialize(getDependentAttributes(dmwrapper.dfId)));
                returnList.add(JSON.serialize(controllingList));
                returnList.add(JSON.serialize(dmwrapper));
                returnList.add(JSON.serialize(getVisibleDependentList(dmwrapper.dmRecord)));
                return JSON.serialize(returnList);
            } else {
                return JSON.serialize(controllingList);
            }
        } catch (Exception ex) {
            return CRUDAndFLSCheckController.getCleanSystemErrorMsg(ex.getmessage());
        }
    }
    /**
     * Method to get visible Attribute List
     */
    public static Set<String> getVisibleDependentList(String dmRecord) {
        Set<String> returnList= new Set<String>();
        for (Data_Mapping__c dm : [SELECT Default__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                        AND From_Mapping__c = false AND Data_Collector_Name__c =:dmRecord]) {
            if (dm.Default__c != null && dm.Default__c != '') {
                for (String attr : dm.Default__c.split(';')) {
                    if (!returnList.contains(attr)) {
                        returnList.add(attr);
                    }
                }                              

            }
        }
        return returnList;
    }
        
    /**
     * Method to get Dependent Filter Attributes
     */
    public static Map<Id,String> getDependentAttributes(String filterId) {
        Map<Id,String> dependentAttributes = new Map<Id,String>();
        for (Attributes_Labels__c attFilter : [SELECT Id, Attribute__c,Attribute__r.Name FROM Attributes_Labels__c
                                    WHERE Label__c = :filterId ORDER BY Attribute__r.Name DESC]) {
            
            dependentAttributes.put(attFilter.Attribute__c,attFilter.Attribute__r.Name);
        }
        return dependentAttributes;
    }

    /**
     * RemoteAction to save Filter Dependency List
     */
    @RemoteAction
    public static String saveFilterDependency(String record, String isNew, String dmRecord) {
        Savepoint sp = Database.setSavepoint();
        if (checkPermissions(true)) {
            try {
                List<ControllingWrapper> wrapperList = (List<ControllingWrapper>)JSON.deserialize(record,List<ControllingWrapper>.class);
                List<Data_Mapping__c> dmrecordstoInsert = new List<Data_Mapping__c>();
                List<Data_Mapping__c> dmrecordstoDelete = new List<Data_Mapping__c>();
                FilterDependecyWrapper dmwrapper = (FilterDependecyWrapper)JSON.deserialize(dmRecord,FilterDependecyWrapper.class);
                
                if (isNew == 'false') {
                    for (Data_Mapping__c dm : [SELECT Id FROM Data_Mapping__c
                                                    WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                                    AND From_Mapping__c = false 
                                                    AND Data_Collector_Name__c =:dmwrapper.dmRecord]) {
                        dmrecordstoDelete.add(dm);
                    }
                } else {
                    Data_Mapping__c parent = new Data_Mapping__c();
                    parent.From_Mapping__c = true;
                    parent.Field_API_Name__c = dmwrapper.dFId;
                    parent.Label__c = dmwrapper.cFId;
                    parent.Object__c = ConstantsController.DEPENDENT_FILTERS;
                    ConstantsController.shouldDataMappingProcessed = true;
                    insert parent;
                    dmwrapper.dmRecord = parent.Id;
                }
                for (ControllingWrapper entry: wrapperList) { 
                    Data_Mapping__c cfRecord = new Data_Mapping__c();
                    cfRecord.Default__c = '';
                    
                    for (String dependentID : entry.dependentWrapperList) {
                        cfRecord.Default__c += dependentID + ';';
                    }
                    cfRecord.Default__c = cfRecord.Default__c.removeEnd(';');
                    
                    if (cfRecord.Default__c != '') {
                        cfRecord.From_Mapping__c = false;
                        cfRecord.Field_API_Name__c = dmwrapper.dFId;
                        cfRecord.Label__c = dmwrapper.cFId;
                        cfRecord.Data_Collector_Name__c = dmwrapper.dmRecord;
                        cfRecord.Section_Name__c = entry.id;
                        cfRecord.Object__c = ConstantsController.DEPENDENT_FILTERS;
                        dmrecordstoInsert.add(cfRecord);
                    }
                }

                if (dmrecordstoInsert.size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;
                    insert dmrecordstoInsert;
                }
                if (dmrecordstoDelete.size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;
                    delete dmrecordstoDelete;
                }
            } catch (Exception ex) {
                Database.rollback(sp);
                return CRUDAndFLSCheckController.getCleanSystemErrorMsg(ex.getmessage());
            }
            return 'true';
        } else {
            return 'Insufficient Access.';
        }
    }

    /**
     * RemoteAction to delete Filter Dependency
     */
    @RemoteAction
    public static String deleteFilterDependency(String dmRecord) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        if (checkPermissions(false)) {
            try {
                List<Data_Mapping__c> dmListToDelete = new List<Data_Mapping__c>();
                for (Data_Mapping__c dm : [SELECT Id FROM Data_Mapping__c
                                            WHERE Id =:dmRecord OR Data_Collector_Name__c =:dmRecord]) {
                    dmListToDelete.add(dm);
                }
                
                if (dmListToDelete.size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;
                    delete dmListToDelete;
                }
                result = 'true';
            } catch (Exception ex) {
                Database.rollback(sp);
                result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(ex.getmessage());
            }
        } else {
            result = 'Insufficient Access.';
        }
        return result;
    }
    
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean checkAll) {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        Map<String, Set<String>> fieldMapCS = new Map<String, Set<String>>();
        Boolean isUpsertPermission = false;
        
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> {
                                            UtilityController.appNamespace() + 'Default__c',
                                            UtilityController.appNamespace() + 'Data_Collector_Name__c',
                                            UtilityController.appNamespace() + 'Section_Name__c',
                                            UtilityController.appNamespace() + 'Label__c',
                                            UtilityController.appNamespace() + 'Field_API_Name__c',
                                            UtilityController.appNamespace() + 'Object__c',
                                            UtilityController.appNamespace() + 'From_Mapping__c'});
        isUpsertPermission = checkAll ? CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'}) && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true)
        : CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'});
        return isUpsertPermission;
    }

    /**
     * Wrapper Class : FilterDependecy
     */
 	public class FilterDependecyWrapper {
 		public String dFId { get; set; }
 		public String cFId { get; set; }
        public String dmRecord { get; set; }
		
 		public FilterDependecyWrapper(Data_Mapping__c dmRecord) {
 			dFId = dmRecord.Field_API_Name__c;
            cFId = dmRecord.Label__c;
            this.dmRecord = dmRecord.Id;
 		}
         public FilterDependecyWrapper(String cFId, String dFId) {
 			this.dFId = dFId;
            this.cFId = cFId;
 		}
 	}

    /**
     * Wrapper Class
     */
 	public class DependentWrapper {
 		public Boolean selected { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		
 		public DependentWrapper(String id, String name) {
 			selected = false;
 			this.name = name;
 			this.id = id;
 		}
 	}
     /**
     * Wrapper Class
     */
 	public class ControllingWrapper {
 		public List<String> dependentWrapperList { get; set; }
 		public String id { get; set; }
 		public String name { get; set; }
 		
 		public ControllingWrapper(String id, String name, List<String> dependentWrapperList) {
 			this.id = id;
 			this.name = name;
 			this.dependentWrapperList = dependentWrapperList;
 		}
 	}
}