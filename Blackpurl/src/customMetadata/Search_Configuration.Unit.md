<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Customer_Owned_Unit__c</label>
    <protected>false</protected>
    <values>
        <field>Additional_Fields_To_Query__c</field>
        <value xsi:type="xsd:string">Unit_Number__c,VIN_Number_Formula__c,Formatted_Name__c,Unit_Type__c,Make_Name__c,Model_Name__c</value>
    </values>
    <values>
        <field>Additional_Info_To_Display__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Display_Field_Name__c</field>
        <value xsi:type="xsd:string">Unit_Number__c</value>
    </values>
    <values>
        <field>Fixed_Where_Clause__c</field>
        <value xsi:type="xsd:string">Status__c != &apos;Inactive&apos;</value>
    </values>
    <values>
        <field>Is_Special_Search__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>Order__c</field>
        <value xsi:type="xsd:double">3.0</value>
    </values>
    <values>
        <field>Searchable_Field_Set__c</field>
        <value xsi:type="xsd:string">VIN_Number__c,Stock_Id__c,Unit_Make__r.Name,Unit_Model__r.Name__c,Sub_Model__r.Sub_Model_Name__c,Category__r.Name,Engine_Serial_No__c,Factory_Order_No__c,ORDU_Stock_Id__c,Other_Serial_No__c,Plate__c,Search_Tag__c,Status__c,Name,Year_As_String__c</value>
    </values>
</CustomMetadata>
