<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SO_Populate_Search_Tag</fullName>
        <description>Populate Search Tag from CO_Header__c.Search_Tag__c field</description>
        <field>Search_Tag__c</field>
        <formula>CO_Header__r.Search_Tag__c + &apos;,&apos; +  Customer_Owned_Unit__r.Unit_Id__c + &apos;,&apos; +  CO_Header__r.Name</formula>
        <name>SO: Populate Search Tag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Search Tag</fullName>
        <actions>
            <name>SO_Populate_Search_Tag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Search Tag from CO_Header__c.Search_Tag__c field.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
