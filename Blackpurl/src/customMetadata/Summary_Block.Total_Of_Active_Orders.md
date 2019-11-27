<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Total Of Active Orders</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Block_Name__c</field>
        <value xsi:type="xsd:string">Active Orders</value>
    </values>
    <values>
        <field>Data_Type__c</field>
        <value xsi:type="xsd:string">Number</value>
    </values>
    <values>
        <field>Filter_Order_Number__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Filter_Value__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Home_Search_Additional_Field_Json__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Home_Search_Filter_Json__c</field>
        <value xsi:type="xsd:string">{&quot;Type&quot;:{&quot;Objects&quot;:[&quot;Customer Orders&quot;]},&quot;Status&quot;:&quot;Open&quot;}</value>
    </values>
    <values>
        <field>Order_Number__c</field>
        <value xsi:type="xsd:double">1.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT COUNT(Id) FROM CO_Header__c WHERE Order_status__c = &apos;Open&apos;</value>
    </values>
    <values>
        <field>Summary_Card__c</field>
        <value xsi:type="xsd:string">Customer_Orders</value>
    </values>
</CustomMetadata>
