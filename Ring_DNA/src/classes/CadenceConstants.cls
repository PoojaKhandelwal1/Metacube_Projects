public with sharing class CadenceConstants {

	//Namespace for managed package
	public static final String orgNamespace = [select NamespacePrefix from ApexClass where Name = 'TargetListController'].NamespacePrefix;
	public static final String NAMESPACE = orgNamespace == null ? '' : orgNamespace+'__';
	public static final String ORANIZATION_ID = Userinfo.getOrganizationId();    

	// Object names
	public static final String CONTACT_OBJECT_NAME = 'Contact';
	public static final String ACCOUNT_OBJECT_NAME = 'Account';
	public static final String CONTACT_ACCOUNT_OBJECT_FIELD_NAME = 'DandBCompanyId';
	public static final String LEAD_OBJECT_NAME = 'Lead';
	public static final String DB_OBJECT_NAME = 'DandBCompany';
	public static final String LEAD_DB_OBJECT_FIELD_NAME = 'DandBCompanyId';
	public static final String OPPORTUNITY_OBJECT_NAME = 'Opportunity';
	public static final String CONTRACT_OBJECT_NAME = 'Contract';
	public static final String PRICE_BOOK_OBJECT_NAME = 'Pricebook2';
	public static final String CAMPAIGN_OBJECT_NAME = 'Campaign';
	public static final String PARTNER_ACCOUNT_OBJECT_DISPLAY_NAME = 'Partner Account';
	public static final String PARTNER_ACCOUNT_OBJECT_NAME = 'PartnerAccount';

	public static final String OPPORTUNITY_ROLE_OBJECT_NAME = 'OpportunityContactRole';

	public static final String SFDC_EMAIL_TYPE = 'SFDC';
	public static final String NATIVE_EMAIL_TYPE = 'NATIVE';
	//cadence criterion types
	public static final String CRITERION_TYPE_ENTRY = 'Entry';
	public static final String CRITERION_TYPE_EXIT = 'Exit'; 

	//Cadence execution criterion 
	public static final String 	EXECUTION_CRITERION_NO_CRITERION = 'No Additional Criterion';
	public static final String 	EXECUTION_CRITERION_CONDITION_MATCHES = 'Conditions are met';

	//Cadence conditions for criterions 
	public static final String CONDITION_AND = 'All of the conditions are met (AND)';
	public static final String CONDITION_OR = 'Any of the conditions are met (OR)';
	public static final String CONDITION_CUSTOM = 'Custom Logic';

	//Cadence Participent Activation 
	public static final String PARTICIPANT_ACTIVATION_MANUAL = 'Manual';  
	public static final String PARTICIPANT_ACTIVATION_AUTOMATIC = 'Automatic';

	public static final String MULTIPLE_CADENCE_MATCHES_ERROR = 'Multiple cadence matches found for this record';

	//Cadence Action Trigger type - 
	public static final String CADENCE_ACTION_TRIGGER_TYPE_IMMEDIATE = 'Immediate';
	public static final String CADENCE_ACTION_TRIGGER_TYPE_TIME_BASED = 'Time Based';

	//Action types - 
	public static final String ACTION_TYPE_TASK = 'Task';
	public static final String ACTION_TYPE_EMAIL = 'Email';
	public static final String ACTION_TYPE_CALL = 'Call';
	public static final String ACTION_TYPE_CALL_VOICEMAIL = 'Call+Voicemail';
	public static final String ACTION_TYPE_SMS = 'SMS';

	//Task status 
	public static final String COMPLETED = 'Completed';
	public static final String MISSED = 'Missed';
	public static final String CONNECTED = 'Connected';

	//Salesforce actual Limits 10000 DML
	public static final Integer DMLOPERATION = 9000;
	public static final String  DMLDELETE = 'delete';
	public static final String  DMLINSERT = 'insert';
	public static final String  DMLUPDATE = 'update';

	//Other Operations name in batch
	public static final String SETCONTACTOPPNULL = 'SetContactOppNull';
	
	//Multi Pick List
	public static final string MultiPickList = 'MultiPickList';
}