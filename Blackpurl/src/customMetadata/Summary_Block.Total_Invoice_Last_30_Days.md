<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Total Invoice-Last 30 Days</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Block_Name__c</field>
        <value xsi:type="xsd:string">Invoices</value>
    </values>
    <values>
        <field>Data_Type__c</field>
        <value xsi:type="xsd:string">Currency</value>
    </values>
    <values>
        <field>Filter_Order_Number__c</field>
        <value xsi:type="xsd:double">3.0</value>
    </values>
    <values>
        <field>Filter_Value__c</field>
        <value xsi:type="xsd:string">Last 30 Days</value>
    </values>
    <values>
        <field>Home_Search_Additional_Field_Json__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Home_Search_Filter_Json__c</field>
        <value xsi:type="xsd:string">{&quot;Type&quot;:{&quot;Objects&quot;:[&quot;Customer Invoices&quot;]},&quot;CreatedDate&quot;:{&quot;SelectedOption&quot;:4}}</value>
    </values>
    <values>
        <field>Order_Number__c</field>
        <value xsi:type="xsd:double">1.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT SUM(Total__c) FROM CO_Invoice_Header__c WHERE Invoice_Date__c = LAST_N_DAYS:30</value>
    </values>
    <values>
        <field>Summary_Card__c</field>
        <value xsi:type="xsd:string">Store_Summary</value>
    </values>
</CustomMetadata>
