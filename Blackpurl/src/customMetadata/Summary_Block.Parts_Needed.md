<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Parts Needed</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Block_Name__c</field>
        <value xsi:type="xsd:string">Parts Needed</value>
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
        <value xsi:type="xsd:string">{&quot;Type&quot;:{&quot;Objects&quot;:[&quot;Parts Needed&quot;]}}</value>
    </values>
    <values>
        <field>Order_Number__c</field>
        <value xsi:type="xsd:double">3.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT SUM(Qty_Needed__c) FROM Vendor_Order_Line_Item__c WHERE ((Is_Excess__c = false AND Is_From_Search__c = false AND Is_required_For_Customer__c = false AND Is_Service__c  = false) OR Is_required_For_Customer__c = true OR Is_Service__c = true) AND Vendor_Order_Line_Item_Group__c = null</value>
    </values>
    <values>
        <field>Summary_Card__c</field>
        <value xsi:type="xsd:string">Vendor_Orders</value>
    </values>
</CustomMetadata>
