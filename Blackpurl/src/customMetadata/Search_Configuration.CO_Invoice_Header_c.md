<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>CO_Invoice_Header__c</label>
    <protected>false</protected>
    <values>
        <field>Additional_Fields_To_Query__c</field>
        <value xsi:type="xsd:string">CO_Header__r.Customer_Name__c</value>
    </values>
    <values>
        <field>Additional_Info_To_Display__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Display_Field_Name__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Fixed_Where_Clause__c</field>
        <value xsi:type="xsd:string">Status__c = &apos;Closed&apos;</value>
    </values>
    <values>
        <field>Is_Special_Search__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">10.0</value>
    </values>
    <values>
        <field>Searchable_Field_Set__c</field>
        <value xsi:type="xsd:string">Invoice_Number__c,CO_Header__r.Name,Invoice_Status__c,Search_Tag__c</value>
    </values>
</CustomMetadata>
