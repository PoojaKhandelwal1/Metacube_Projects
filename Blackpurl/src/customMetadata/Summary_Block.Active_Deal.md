<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Active-Deal</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Block_Name__c</field>
        <value xsi:type="xsd:string">Active</value>
    </values>
    <values>
        <field>Data_Type__c</field>
        <value xsi:type="xsd:string">Number</value>
    </values>
    <values>
        <field>Filter_Order_Number__c</field>
        <value xsi:type="xsd:double">4.0</value>
    </values>
    <values>
        <field>Filter_Value__c</field>
        <value xsi:type="xsd:string">Deal</value>
    </values>
    <values>
        <field>Home_Search_Additional_Field_Json__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Home_Search_Filter_Json__c</field>
        <value xsi:type="xsd:string">{&quot;Type&quot;:{&quot;Objects&quot;:[&quot;Service Jobs&quot;]},&quot;Status&quot;:&quot;Active&quot;,&quot;Service_Job_TransactionType&quot;:&quot;Deal Service&quot;}</value>
    </values>
    <values>
        <field>Order_Number__c</field>
        <value xsi:type="xsd:double">2.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT COUNT(Id) FROM Service_Order_Header__c WHERE Transaction_Type__r.Type__c = &apos;Deal Service&apos; AND Work_Status__c IN(&apos;Ready&apos;,&apos;In Progress&apos;,&apos;On Hold&apos;)</value>
    </values>
    <values>
        <field>Summary_Card__c</field>
        <value xsi:type="xsd:string">Service_Jobs</value>
    </values>
</CustomMetadata>
