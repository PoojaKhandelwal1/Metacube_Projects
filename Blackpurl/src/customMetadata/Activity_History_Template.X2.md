<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>2</label>
    <protected>false</protected>
    <values>
        <field>Action__c</field>
        <value xsi:type="xsd:string">Finalize Customer Invoice</value>
    </values>
    <values>
        <field>Alternate_Entity__c</field>
        <value xsi:type="xsd:string">Customer</value>
    </values>
    <values>
        <field>Color_Code__c</field>
        <value xsi:type="xsd:string">#F5A623</value>
    </values>
    <values>
        <field>Feed_Text_Template__c</field>
        <value xsi:type="xsd:string">[You/username] finalized a $$#Total__c invoice to customer &lt;a href=&quot;#/ViewCustomer?Id=$#hrefId&quot;&gt;$#CO_Header__r.Customer_Name__c&lt;/a&gt;, [time period]</value>
    </values>
    <values>
        <field>Fields_To_Query__c</field>
        <value xsi:type="xsd:string">Total__c,CO_Header__r.Customer_Name__c</value>
    </values>
    <values>
        <field>Source_Entity__c</field>
        <value xsi:type="xsd:string">Customer Invoice</value>
    </values>
</CustomMetadata>
