<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Total Of Deposits</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Block_Name__c</field>
        <value xsi:type="xsd:string">Deposits</value>
    </values>
    <values>
        <field>Data_Type__c</field>
        <value xsi:type="xsd:string">Currency</value>
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
        <value xsi:type="xsd:string">[{&quot;UIFieldKey&quot;:&quot;Customer_Order_Deposits&quot;,&quot;Label&quot;:&quot;Deposits&quot;,&quot;IsDisplayed&quot;:true}]</value>
    </values>
    <values>
        <field>Home_Search_Filter_Json__c</field>
        <value xsi:type="xsd:string">{&quot;Type&quot;:{&quot;Objects&quot;:[&quot;Customer Orders&quot;]},&quot;Status&quot;:&quot;Open&quot;,&quot;Customer_Order_Deposits&quot;:{&quot;SelectedOption&quot;:2,&quot;Value1&quot;:0}}</value>
    </values>
    <values>
        <field>Order_Number__c</field>
        <value xsi:type="xsd:double">2.0</value>
    </values>
    <values>
        <field>Query__c</field>
        <value xsi:type="xsd:string">SELECT SUM(Total_Deposit_And_Payment__c) FROM CO_Header__c WHERE Order_status__c = &apos;Open&apos;</value>
    </values>
    <values>
        <field>Summary_Card__c</field>
        <value xsi:type="xsd:string">Customer_Orders</value>
    </values>
</CustomMetadata>
