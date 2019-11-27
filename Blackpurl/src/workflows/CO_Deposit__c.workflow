<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Search_Tags_Populate</fullName>
        <description>Used For Populating Search Tags</description>
        <field>Search_Tags__c</field>
        <formula>CO_Header__r.Customer__r.Name + &apos;,&apos; + CO_Header__r.Name</formula>
        <name>Search_Tags_Populate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Search Tags</fullName>
        <actions>
            <name>Search_Tags_Populate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Search Tags</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
