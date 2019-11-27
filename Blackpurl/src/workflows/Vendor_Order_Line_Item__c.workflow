<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Search_Tag</fullName>
        <description>Populate Search Tag from Vendor_Order_Line_Item__c</description>
        <field>Search_Tag__c</field>
        <formula>IF( Is_required_For_Customer__c ,  CO_Header__r.Name   + &apos;,&apos; + CO_Header__r.Customer__r.Name  + &apos;,&apos; + CO_Header__c,   &apos;STOCK&apos;) + &apos;,&apos; + Part__r.Part_Number__c + &apos;-&apos; +  Part__r.Description__c + &apos;,&apos; + &apos;Required&apos; + &apos;,&apos; +  Part__r.Vendor__r.Name</formula>
        <name>Populate Search Tag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Vendor Order Line Item - Populate Search Tag</fullName>
        <actions>
            <name>Populate_Search_Tag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Populate Search Tag from Vendor_Order_Line_Item__c.Search_Tag__c field.</description>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
