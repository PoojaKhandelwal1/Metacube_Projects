<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Customer_Owned_Unit_Update_Search_Tag</fullName>
        <field>Search_Tag__c</field>
        <formula>Unit_Make__r.Name + &apos;,&apos; + Unit_Model__r.Name__c + &apos;,&apos; +  Submodel__r.Name__c + &apos;,&apos; + TEXT(Year__c) + &apos;,&apos; +  VIN_Number__c + &apos;,&apos; +  Location__c + &apos;,&apos; +  Category__r.Name</formula>
        <name>Customer Owned Unit: Update Search Tag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Customer Owned Unit%3A Populate Search Tag</fullName>
        <actions>
            <name>Customer_Owned_Unit_Update_Search_Tag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Customer_Owned_Unit__c.Unit_Type__c</field>
            <operation>equals</operation>
            <value>STOCK</value>
        </criteriaItems>
        <description>To populate field value to be search.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
