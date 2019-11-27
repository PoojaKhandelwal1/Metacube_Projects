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
 * Class: AttrMaapingFilterRecordsExtensionTest
 * Description : class to test and cover AttrMaapingFilterRecordsExtension - Displays Attribute Mapping's filter criterian on Attribute Mapping detail page.
 *																			(Using AttrMaapingFilterRecords custom VF page.)
 * Modified by: Rekha Jangir @21 August 2017
 */
 @isTest
public with sharing class AttrMaapingFilterRecordsExtensionTest {
    /*
     * Method to cover fetching FilterRecords related to Attribute Mapping to display them on Attribute Mapping Detail page.
     * Created By: Pooja Khandelwal @15 Jun 2019
     */
    static testMethod void displayFilterCriterianOnAtrrMappingDetailPage() {
    	//Start: Create 'Object' type Attr Mapping Record with Filter Criteria specified for Lead Object
    	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
    	info.attName = 'Lead';
    	info.autoAdd = true;
    	info.fieldName = 'Name';
    	info.filterName = 'Lead';
    	info.selectedObject = 'Lead';
        
        AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = new AddAttributeMappingControllerSLDS.FieldValuesWrapper();
        
        List<ListViewFiltersController.FilterWrapper> filters = new List<ListViewFiltersController.FilterWrapper>();
        ListViewFiltersController.FilterWrapper filterRec = new ListViewFiltersController.FilterWrapper(new User_Mapping__c());
        filterRec.fieldApiName = 'Id';
        filterRec.fieldLabel = 'Lead ID';
		filterRec.fieldType = 'ID';
		filterRec.fieldValue = '00Q1Y00001qjbn3'; 
        filterRec.isEditable = true;
        filterRec.isNew = true;
        filterRec.isValid = true; 
		filterRec.objectName = 'Lead';
		filterRec.operator = 'equals';
		filterRec.visible = true;
        filters.add(filterRec);
        
    	AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'object', JSON.serialize(filters));
        //End: Create Object type Attr Mapping with Filter Criteria specified for Lead Object
        
        Test.startTest();
        List<Attribute_Mapping__c> attMappings = [SELECT Id FROM Attribute_Mapping__c WHERE Object__c = 'Lead'];
        AttributeMaapingFilterRecordsExtension attrFilterRecordExtension = new AttributeMaapingFilterRecordsExtension(new ApexPages.StandardController(attMappings[0]));
       	Test.stopTest();
       	
       	system.assertEquals(1, attrFilterRecordExtension.FilterCriterianList.size());
       	system.assertEquals('00Q1Y00001qjbn3', attrFilterRecordExtension.FilterCriterianList[0].fieldValue);
    }
}