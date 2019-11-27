<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Part__c</label>
    <protected>false</protected>
    <values>
        <field>Additional_Fields_To_Query__c</field>
        <value xsi:type="xsd:string">Non_Inventory_Part__c,Part_Id__c,Qty_In_Stock__c,Qty_Committed__c,Retail_Price__c,AvailableParts__c,Vendor__c</value>
    </values>
    <values>
        <field>Additional_Info_To_Display__c</field>
        <value xsi:type="xsd:string">Description__c</value>
    </values>
    <values>
        <field>Display_Field_Name__c</field>
        <value xsi:type="xsd:string">Part_Number__c</value>
    </values>
    <values>
        <field>Fixed_Where_Clause__c</field>
        <value xsi:type="xsd:string">Active__c = TRUE</value>
    </values>
    <values>
        <field>Is_Special_Search__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">4.0</value>
    </values>
    <values>
        <field>Searchable_Field_Set__c</field>
        <value xsi:type="xsd:string">Part_Number__c,Description__c,Mfg_Part__c,SKU_Number__c,Vendor_Name_And_Code__c,Category__r.Name,Search_Tags__c,Status__c,Location__c,Part_Id_Text__c,Vendor__r.Name</value>
    </values>
</CustomMetadata>
