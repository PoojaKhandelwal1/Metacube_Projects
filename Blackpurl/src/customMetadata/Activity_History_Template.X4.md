<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>4</label>
    <protected>false</protected>
    <values>
        <field>Action__c</field>
        <value xsi:type="xsd:string">Commit Vendor Receiving</value>
    </values>
    <values>
        <field>Alternate_Entity__c</field>
        <value xsi:type="xsd:string">Vendor</value>
    </values>
    <values>
        <field>Color_Code__c</field>
        <value xsi:type="xsd:string">#B07BE0</value>
    </values>
    <values>
        <field>Feed_Text_Template__c</field>
        <value xsi:type="xsd:string">[You/username] stocked a $$#Receiving_Total__c receiving from vendor &lt;a href=&quot;#/ViewVendor?Id=$#hrefId&quot;&gt;$#Vendor__r.Name&lt;/a&gt;, [time period]</value>
    </values>
    <values>
        <field>Fields_To_Query__c</field>
        <value xsi:type="xsd:string">Receiving_Total__c,Vendor__r.Name</value>
    </values>
    <values>
        <field>Source_Entity__c</field>
        <value xsi:type="xsd:string">Vendor Receiving</value>
    </values>
</CustomMetadata>
