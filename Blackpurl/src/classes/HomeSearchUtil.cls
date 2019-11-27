/**
 * Author: Tarun Khandelwal
 * Since: Feb 15, 2016
 * Name: HomeSearchUtil
 * Description: Class used to hold utility methods, variables and mapping used in Home Search screen
 * 
**/
public with sharing class HomeSearchUtil {
    public static List<PaginationSorting.SortAttrs> sortMapping;
    
    /**
     * Name: getGenericObjectNameBySelectedObject 
     * Description: To get Generic object name by Selected object set
     * @param: 1. Set<String> objectNamesSet - selected object set
     * @return: String
     */ 
    public static String getGenericObjectNameBySelectedObject(Set<String> objectNamesSet) {
        List<String> objectNames = new List<String>(objectNamesSet);
        if(objectNamesSet.size() == 0) {
            return Label.Generic_Object_Label;
        }
        
        if(objectNames.size() == 1) {
            return objectNames[0];
        } 
        
        for(String groupName : groupNameToGroupObjectsMap.keySet()) {
            Set<String> mapObjects = new Set<String>(groupNameToGroupObjectsMap.get(groupName));
            
            boolean isAGroup = true;
            for(String objNameSelected : objectNamesSet) {
                if( mapObjects.contains(objNameSelected) == false ) {
                    isAGroup = false;
                    break;
                }
            }
            if(isAGroup){
                return groupName;
            }
        }
        
        return Label.Generic_Object_Label;
    }
    
    /**
     * Name: getPickValues 
     * Description: To get picklist values by describe call
     * @param:  1. String objectName - object name
     *          2. String fieldName - Picklist field API Name
     * @return: List<String> - Picklist options
     */
    public static List<String> getPickValues(String objectName, String fieldName) {
        List<String> lstPickvals = new List<String>();
        
        if(Schema.getGlobalDescribe().containsKey(objectName)) {
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType();
            
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            if(field_map.containsKey(fieldName)) {
                List<Schema.PicklistEntry> pick_list_values = field_map.get(fieldName).getDescribe().getPickListValues();
                
                for (Schema.PicklistEntry a : pick_list_values) {
                    lstPickvals.add(a.getValue());
                }
            }
        }
        return lstPickvals;
    }
    
    /**
     * Name: getUserPermissions
     * Description: to get permissions
     * @param:  
     * @return: Map<String, Map<String, Boolean>> - permission map
     */
    public static Map<String, Map<String, Boolean>> permissionsMap;
    public static Map<String, Map<String, Boolean>> getUserPermissions() {
        if(permissionsMap == null) {
        String permissionsJson = NewHomePageCtrl.getUserPermissions(UserInfo.getUserId());
        UserGroupWrapper groupDetails = (UserGroupWrapper)System.JSON.deserialize(permissionsJson, UserGroupWrapper.class);
            permissionsMap = groupDetails.GroupOnlyPermissions;
        }
        return permissionsMap;
    }
    
    /**
     * Name: filterListBasedOnPermissions 
     * Description: To remove values from list which are restricted for current user (user permissions)
     * @param:  1. List<String> listToFilter - list to filter
     *          2. List<String> Map<String, String> - map to get permissions based of key
     * @return: List<String> - filtered list
     */
    public static List<String> filterListBasedOnPermissions(List<String> listToFilter, Map<String, String> keyToPermissionsMap) {
        Map<String, Map<String, Boolean>> permissionsMap = getUserPermissions();
        
        String PrimaryLabel = '';
        String SecondaryLabel = '';
        for(String filterName: keyToPermissionsMap.keySet()) {
            List<String> permissionNames = keyToPermissionsMap.get(filterName).split(',');
            Boolean permissionValue = false;
            for(String name: permissionNames) {
                PrimaryLabel = Constants.permissionTypeToLabelListMap.get(name)[0];
                SecondaryLabel = Constants.permissionTypeToLabelListMap.get(name)[1];
                permissionValue = permissionValue || permissionsMap.get(name).get(PrimaryLabel);
            }
            
            if(!permissionValue) {
                for(Integer i=0; i<listToFilter.size(); i++) {
                    if(listToFilter[i] == filterName) {
                        listToFilter.remove(i);
                    }
                }
            }
        }
        return listToFilter;
    }
    
    //Modified by Nidhi - #1152 - 19-10-2016   
    // Map of object name to owner field API Name
    public static Map<String, String> objectToOwnerObjectFieldName = new Map<String,String>{'Part__c'   =>  'Vendor__r',
                                                                                            'CO_Invoice_Header__c'  =>  'CO_Header__r.Owner__c',
                                                                                            'CO_Invoice_Payment__c' =>  'CO_Invoice_Header__r.CO_Header__r.Owner__c',
                                                                                            'CO_Deposit__c' =>  'CO_Header__r.Owner__c',
                                                                                            'Service_Order_Header__c' => 'CO_Header__r.Owner__c',
                                                                                            'Product__c'    =>  'Vendor__r'
                                                                                        };
    
    // Map of object name to related grid columns name and field API name(Used in sorting attributes for records)
    public static Map<String, Map<String, String>> obejctNameToMapOfSortLabelToAPIName = new Map<String, Map<String, String>>{
                                                                                            'Account' => new Map<String, String>{'Id'       =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name',
                                                                                                                                 'Drivers License' => 'Drivers_License__c'
                                                                                                                            },
                                                                                            CONSTANTS.NAMESPACE+'Part__c' => new Map<String, String>{'Id'       =>  'Id',
                                                                                                                                 'Key'      =>  'Part_Number__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Vendor__r.Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Labour_Code__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Code__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'CO_Header__c' => new Map<String, String>{'Id'=>    'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner__r.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            'User' => new Map<String, String>{   'Id'       =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'CreatedBy.Name',
                                                                                                                                 'Name'     =>  'Title',
                                                                                                                                 'Status' => 'IsActive'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Kit_Header__c' => new Map<String, String>{'Id' =>  'Id',
                                                                                                                                 'Key'      =>  'Code__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Fee__c' => new Map<String, String>{ 'Id'       =>  'Id',
                                                                                                                                 'Key'      =>  'Code__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            
                                                                                            CONSTANTS.NAMESPACE+'CO_Invoice_Header__c' => new Map<String, String>{ 'Id' =>  'Id',
                                                                                                                                 'Key'      =>  'Invoice_Number__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'CO_Header__r.Owner__r.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Invoice_Number__c'
                                                                                                                                },
                                                                                                                                
                                                                                            CONSTANTS.NAMESPACE+'CO_Invoice_Payment__c' => new Map<String, String>{ 'Id'    =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'CO_Invoice_Header__r.CO_Header__r.Owner__r.Name',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                                                                
                                                                                            CONSTANTS.NAMESPACE+'CO_Deposit__c' => new Map<String, String>{ 'Id'    =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'CO_Header__r.Owner__r.Name',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                                                                                                    
                                                                                            CONSTANTS.NAMESPACE+'Vendor_Order_Header__c' => new Map<String, String>{ 'Id'   =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner__r.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                             CONSTANTS.NAMESPACE+'Return_VO_Header__c' => new Map<String, String>{ 'Id'   =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },                                
                                                                                            CONSTANTS.NAMESPACE+'Vendor_Receiving_Header__c' => new Map<String, String>{ 'Id'   =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner__r.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Vendor_Invoicing_Header__c' => new Map<String, String>{ 'Id'   =>  'Id',
                                                                                                                                 'Key'      =>  'Vendor_Invoice_Number__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner__r.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Category__c' => new Map<String, String>{ 'Id'  =>  'Id',
                                                                                                                                 'Key'      =>  'Unique_Category__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Price_Level__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Name__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                             CONSTANTS.NAMESPACE+'CO_Line_Item__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'Owner'    =>  'CO_Header__r.Owner__r.Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate'
                                                                                                                                },
                                                                                             CONSTANTS.NAMESPACE+'Service_Order_Line_Item__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'Owner'    =>  'Service_Order_Header__r.CO_Header__r.Owner__r.Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Option_Fee__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'Owner'    =>  'Deal__r.CO_Header__r.Owner__r.Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Sales_Tax__c' => new Map<String, String>{'Id'=>    'Id',
                                                                                                                                 'Key'      =>  'Name__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                                                                
                                                                                            CONSTANTS.NAMESPACE+'Product__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Code__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Vendor__r.Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            CONSTANTS.NAMESPACE+'Service_Order_Header__c' => new Map<String, String>{ 'Id'    =>  'Id',
                                                                                                                                 'Key'      =>  'Name',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'CO_Header__r.Owner__r.Name',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                            //Added by Nidhi - #1152 - 19-10-2016   
                                                                                            CONSTANTS.NAMESPACE+'Customer_Owned_Unit__c' => new Map<String, String>{ 'Id'    =>  'Id',
                                                                                                                                 'Key'      =>  'Stock_Id__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name',
                                                                                                                                 'Compliance Date' => 'Compliance_Date__c',
                                                                                                                                 'Year of 1st Rego' => 'Year_Of_1st_Rego__c',
                                                                                                                                 'Registration Serial#' => 'Registration_Serial__c',
                                                                                                                                 'Manufactured Date' => 'Manufactured_Date__c'
                                                                                                                                },
                                                                                                                                
                                                                                           CONSTANTS.NAMESPACE+'Vendor_Order_Line_Item__c' => new Map<String, String>{ 'Id'    =>  'Id',
                                                                                                                                 'Key'      =>  'Needed_For__c',
                                                                                                                                 'Owner'    =>  'Owner.Name'
                                                                                                                                },
                                                                                          CONSTANTS.NAMESPACE+'Deal__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Type__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Status__c',
                                                                                                                                 'Name'     =>  'Name'
                                                                                                                                },
                                                                                         CONSTANTS.NAMESPACE+'Deal_Item__c' => new Map<String, String>{'Id'=>  'Id',
                                                                                                                                 'Key'      =>  'Type__c',
                                                                                                                                 'LastModifiedDate' =>  'LastModifiedDate',
                                                                                                                                 'Created'  =>  'CreatedDate',
                                                                                                                                 'Owner'    =>  'Owner.Name',
                                                                                                                                 'Status'   =>  'Customer_Owned_Unit__r.Status__c',
                                                                                                                                 'Name'     =>  'Name',
                                                                                                                                 'Compliance Date'   =>  'Customer_Owned_Unit__r.Compliance_Date__c',
                                                                                                                                 'Year of 1st Rego'   =>  'Customer_Owned_Unit__r.Year_Of_1st_Rego__c',
                                                                                                                                 'Registration Serial#'   =>  'Customer_Owned_Unit__r.Registration_Serial__c',
                                                                                                                                 'Manufactured Date'   =>  'Customer_Owned_Unit__r.Manufactured_Date__c'
                                                                                                                                }                                                                            
                                                                                                                                
                                                                                    };
    //Modified by Nidhi - #1152 - 19-10-2016   
    public static Map<String, String> searchableObjectToUniqueValueFieldMap = new Map<String, String>{
        'Account'                   => 'Name',
        'Part__c'                   => 'Name',
        'Labour_Code__c'            => 'Name',
        'Kit_Header__c'             => 'Name',
        'Fee__c'                    => 'Name',
        'CO_Header__c'              => 'Name',
        'CO_Invoice_Header__c'      => 'Invoice_Number__c',
        'CO_Invoice_Payment__c'     => 'Name',
        'CO_Deposit__c'             => 'Name', 
        'Vendor_Order_Header__c'    => 'Name',
        'Return_VO_Header__c'    => 'Name',
        'Vendor_Receiving_Header__c'=> 'Name',
        'Vendor_Invoicing_Header__c'=> 'Name',
        'Category__c'               => 'Unique_Category__c',
        'Price_Level__c'            => 'Name',
        'Sales_Tax__c'              => 'Name',
        'Product__c'                => 'Name',
        'User'                      => 'UserName',
        'Service_Order_Header__c'   => 'Name',
        'Customer_Owned_Unit__c'    => 'Stock_Id__c',
        'Vendor_Order_Line_Item__c' => 'Name',
        'CO_Line_Item__c'           => 'Name',
        'Service_Order_Line_Item__c'=> 'Name',
        'Option_Fee__c'         => 'Name',
        'Hours_Logged__c'           => 'Name',
        'Technician__c' => 'Name',
        'Payroll_Time__c'           => 'Name',
        'Part_FIFO_Bucket__c' => 'Name',
        'Part_FIFO_Bucket_Activity_Line_Item__c' => 'Name',
        'Vendor_Invoicing_Header__c' => 'Vendor_Invoice_Number__c',
        'Deal__c' => 'Name',
        'Deal_Item__c' => 'Name'
    }; 
    
    public static Map<String, Set<String>> searchableSpecialObjectToFieldsMap = new Map<String, Set<String>>{
            'CO_Invoice_Header__c'              => new Set<String> {
                                                    'Id', 
                                                    'CO_Header__c',
                                                    'Invoice_Date__c',
                                                    'CO_Header__r.Customer_Name__c', 
                                                    'Invoice_Number__c',
                                                    'Total__c',
                                                    'SalesTax_Total__c',
                                                    'Invoice_Date__c',
                                                    'Sub_Total__c',
                                                    'Taxable_Total__c',
                                                    'Non_Taxable_Total__c',
                                                    'CO_Header__r.Account_Type__r.Name'
                                                    },
            'Vendor_Invoicing_Header__c'        => new Set<String> {
                                                    'Id', 
                                                    'Invoice_Date__c',
                                                    'Vendor_Invoice_Number__c',
                                                    'Vendor__r.Name',
                                                    'Total_With_Tax__c',
                                                    'Sub_Total__c',
                                                    'Tax_Total__c',
                                                    'Vendor__r.Purchase_Tax__c',
                                                    'Status__c',
                                                    'Taxable_Total__c',
                                                    'Non_Taxable_Total__c',
                                                    'Applicable_Purchase_Tax_Name__c',
                                                    'Vendor__r.Vendor_Account_Type__r.Name',
                                                    '(SELECT Sales_Tax_Item_Name__c, Tax_Rate__c FROM Individual_Taxes__r)'
                                                    }                            
    };
    // A Map of Objects to associated fields on which search to be performed -> Used to make JSON + Result Wrapper
    public static Map<String, Set<String>> searchableObjectToFieldsMap = new Map<String, Set<String>>{
            'Account'       => new Set<String>{ 'Id', 
                                                'Is_Customer__c', 
                                                'Is_Vendor__c', 
                                                'Customer_Number__c',
                                                'Active__c', 
                                                'Name', 
                                                'Description', 
                                                'Phone', 
                                                'Email__c', 
                                                'BillingStreet', 
                                                'BillingCity', 
                                                'BillingState', 
                                                'BillingCountry', 
                                                'BillingPostalCode',
                                                'Sales_Tax__r.Name__c', 
                                                'Price_Level__r.Name__c', 
                                                'Preferred_Email__c',
                                                'Preferred_Phone__c',
                                                'Vendor_Code__c',
                                                'Owner.Name', 
                                                'OwnerId',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Status__c',
                                                'FirstName__c',
                                                'LastName__c',
                                                'Nickname__c',
                                                'Birth_Date__c',
                                                'VIP__c',
                                                'Job_Title__c',
                                                'ShippingStreet',
                                                'ShippingCity',
                                                'ShippingState',
                                                'Mobile__c',
                                                'Other_Email__c',
                                                'Home_Number__c',
                                                'Work_Email__c',
                                                'Work_Number__c',
                                                'Facebook__c',
                                                'LinkedIn__c',
                                                'Twitter__c',
                                                'Website',
                                                'Sales_Tax__c',
                                                'Sales_Tax__r.Name__c',
                                                'Price_Level__c',
                                                'Price_Level__r.Name__c',
                                                'Open_Orders__c',
                                                'Orders_Lifetime__c',
                                                'Average_Spend_per_Order__c',
                                                'Last_Visit_Order__c',
                                                'Purchase_Tax__c',
                                                'Purchase_Tax__r.Name__c',
                                                'Part_Category_Default__c',
                                                'Part_Category_Default__r.Name',
                                                'Unit_Category_Default__c',
                                                'Unit_Category_Default__r.Name',
                                                'Claims_for_Service_Work__c',
                                                'Flooring_Company__c',
                                                'Unit_Purchases__c',
                                                'Part_Purchases__c',
                                                'Sublet_Purchases__c',
                                                'Warranty_Plan_Sales_on_Unit_Deals__c',
                                                'Id_Number__c',
                                                'Formatted_Home_number__c',
                                                'Formatted_Mobile_Number__c',
                                                'Formatted_Work_Number__c',
                                                'Formatted_Preferred_Phone__c',
                                                'Type__c',
                                                'Account_Type__r.Name',
                                                'Vendor_Account_Type__r.Name',
                                                'Drivers_License__c'
                                            },
                                            
            'Part__c'       => new Set<String>{ 'Id', 
                                                'Part_Number__c', 
                                                'Active__c', 
                                                'Description__c', 
                                                'AvailableParts__c', 
                                                'Vendor__c',
                                                'Vendor__r.Vendor_Code__c',
                                                'Qty_In_Stock__c',
                                                'Qty_Committed__c',
                                                'Qty_On_Order__c',
                                                'Retail_Price__c',
                                                'Location__c',
                                                'Category__r.Name',
                                                'Category__c',
                                                'Status__c',
                                                'Name',
                                                'Last_Cost__c',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Vendor__r.OwnerId',
                                                'Vendor__r.Name',
                                                'Vendor__r.Owner.Name',
                                                'Status__c',
                                                'Status__c',
                                                'MSRP__c',
                                                'Enviro_Fee__c',
                                                'Average_Cost__c',
                                                'Package_Cost__c',
                                                'Package_Qty__c',
                                                'Package_Unit__c',
                                                'Last_Counted__c',
                                                'Last_Sold__c',
                                                'Last_Stocked__c',
                                                'Auto_reorder_Min__c',
                                                'Auto_reorder_Max__c',
                                                'Order_Lots__c',
                                                'Superseded_By__c',
                                                'Superseded_By__r.Part_Number__c',
                                                'Oversold_Qty__c',
                                                'Oversold_Cost__c',
                                                'Total_Cost__c',
                                                'Mfg_Part__c', // Added by richa 28/11/2016
                                                'SKU_Number__c', // Added by richa 28/11/2016
                                                'Non_Inventory_Part__c', // Added by richa 28/11/2016
                                                'Assigned_Tag_1__c',
                                                'Assigned_Tag_2__c',
                                                'PRD1Qty__c',
                                                'PRD1Cost__c',
                                                'PRD2Qty__c',
                                                'PRD2Cost__c',
                                                'PRD3Qty__c',
                                                'PRD3Cost__c',
                                                'PRD4Qty__c',
                                                'PRD4Cost__c',
                                                'Part_Type__c'
                                            },
             
            'Hours_Logged__c'       => new Set<String>{ 'Id',
                                                'Name',
                                                'Technician__r.Technician_Name__c',
                                                'Start_Date_Time__c',
                                                'End_Date_Time__c',
                                                'Service_Order_Header__r.CO_Header__r.Name',
                                                'Task__r.Name__c',
                                                'Service_Order_Header__r.Name__c',
                                                'Notes__c',
                                                'LastModifiedDate',
                                                'Calculated_Hours__c',
                                                'Work_Performed_Date__c',
                                                'Time_Spent__c',
                                                'Billed_Hours__c',
                                                'Service_Order_Header__r.SO_Type__c',
                                                'Service_Order_Header__r.Work_Status__c',
                                                'Service_Order_Header__r.CO_Header__r.Customer_name__c',
                                                'Efficiency__c',
                                                'Service_Order_Header__r.Transaction_Type__c',
                                                'Service_Order_Header__r.Transaction_Type__r.Code_Label__c'
                                            },
            'Technician__c'         => new Set<String>{ 'Id',
                                                        'Name',
                                                        'Type__c',
                                                        'LastModifiedDate',
                                                        'Technician_Name__c',
                                                        '(Select Id, Service_Order_Header__c, Service_Order_Header__r.Work_Status__c, Task__c, Calculated_Hours__c,'+ 
                                                                'Billed_Hours__c from Hours_Logged__r)', 
                                                        '(Select Id, Total_Time__c from Payroll_Times__r)'
                                            },
                                            
            'Payroll_Time__c'       => new Set<String>{ 'Id',
                                                        'Name',
                                                        'Technician__c',
                                                        'Technician__r.Technician_Name__c',
                                                        'Start_Date__c',
                                                        'End_Date__c',
                                                        'Formatted_Total_time__c',
                                                        'Total_time__c',
                                                        'Payroll_Date__c',
                                                        'In_Time__c'
                                            },                           
                                           
            'Labour_Code__c'=> new Set<String>{ 'Id', 
                                                'Name', 
                                                'Name__c',
                                                'Active__c', 
                                                'Description__c', 
                                                'Code__c', 
                                                'Category__r.Name',
                                                'Category__c',
                                                'Rate__c',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Owner.Name',
                                                'OwnerId',
                                                'Status__c',
                                                'Code__c',
                                                'Hours__c'
                                            },
            
            'Kit_Header__c' => new Set<String>{ 'Id', 
                                                'Name', 
                                                'Active__c', 
                                                'Description__c', 
                                                'Code__c', 
                                                'Fixed_Price__c',
                                                'OwnerId',
                                                'Owner.Name', 
                                                'LastModifiedDate', 
                                                'CreatedDate', 
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Code__c',
                                                'Kit_Unique_Name__c',
                                                'Status__c',
                                                'Service_Kit__c'
                                            },
                                            
            'Fee__c'        => new Set<String>{ 'Id', 
                                                'Name', 
                                                'Active__c', 
                                                'Description__c', 
                                                'Code__c', 
                                                'Category__c',
                                                'Category__r.Name',
                                                'Price__c',
                                                'Owner.Name', 
                                                'OwnerId',
                                                'LastModifiedDate', 
                                                'CreatedDate', 
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Fee_Unique_Name__c',
                                                'Status__c',
                                                'Code__c'
                                            },
            
            'CO_Header__c'=> new Set<String>{   'Id', 
                                                'Name', 
                                                'Customer__c',
                                                'Customer__r.Name',
                                                'CO_Type__c',
                                                'Order_status__c', 
                                                'Total_Order_Value__c', 
                                                'Total_COLI__c',
                                                'Deal_Total__c',
                                                'Total_SO_Tax_Amount__c',
                                                'Total_SO__c',
                                                'Owner__r.Name', 
                                                'Owner__c',
                                                'LastModifiedDate',
                                                'LastModifiedDate__c', 
                                                'CreatedDate',
                                                'CreatedDate__c',
                                                'Total_Balance_Due__c',
                                                'Status__c',
                                                'Total_Payment__c',
                                                'Total__c',
                                                'Total_Deposit__c',
                                                'Customer_Name__c',
                                                'TotalNumberOfSOHeader__c ', // Added by richa 20/01/2017 for global search changes for CO
                                                'Selling_Group__c', // Added by richa 20/01/2017 for global search changes for CO
                                                'TotalNumberOfCOLI__c', // Added by richa 20/01/2017 for global search changes for CO
                                                'NumberOfDeals__c', // Added by richa 20/01/2017 for global search changes for CO
                                                'Total_COLI_Clearfix__c', // Added by richa 20/01/2017 for global search changes for CO
                                                'Order_Total__c',
                                                'Total_Deposit_And_Payment__c',
                                                'Invoiced_Amount__c',
                                                'Uninvoiced_Amount__c',
                                                'Deal_Header_Total__c',
                                                'Service_Order_Subtotal__c',
                                                'Merchandise_Total__c',
                                                'Hide_Merchandise_Section__c',
                                                'Last_Comment__c',
                                                'Account_Type__r.Name',
                                                'Merchandise_Pre_Tax_Part_Total__c',
                                                'Merchandise_Pre_Tax_Fee_Total__c',
                                                'Parts_And_Accessories_Tax_Amount__c',
                                                'Merchandise_Profit__c',
                                                'Merchandise_Status__c',
                                                'Parts_And_Accessories_Total__c',
                                                'Merchandise_Transaction_Type__c',
                                                'Parts_And_Accessories_Invoiced_Total__c',
                                                'Merchandise_Sale_Type__c' 
                                            
                                            },
           
            'CO_Invoice_Header__c'=> new Set<String>{'Id', 
                                                    'Name', 
                                                    'Invoice_Number__c',   
                                                    'CO_Header__r.Customer__c',
                                                    'CO_Header__r.Customer__r.Name',
                                                    'CO_Header__r.Customer_Name__c',
                                                    'CO_Header__r.CO_Type__c',
                                                    'Invoice_Status__c', 
                                                    'Total_Payment__c',
                                                    'Total__c',
                                                    'CO_Header__r.Owner__r.Name',
                                                    'CO_Header__r.Owner__c',
                                                    'LastModifiedDate', 
                                                    'CreatedDate',
                                                    'LastModifiedDate__c',
                                                    'CreatedDate__c',
                                                    'CO_Header__c',
                                                    'CO_Header__r.Name',
                                                    'CO_Header__r.Owner__c',
                                                    'CO_Header__r.Owner__r.Name',
                                                    'CO_Header__r.Total_Balance_Due__c',
                                                    'Status__c',
                                                    'Part_Total__c',
                                                    'Fee_Total__c',
                                                    'Total_Fee_With_Shop_Supplies__c',
                                                    'Labour_Total__c',
                                                    'Sublet_Total__c',
                                                    'Unit_Total__c',
                                                    'SalesTax_Total__c',
                                                    'Invoice_Date__c',
                                                    'Invoice_Date_Formula__c',
                                                    'CO_Header__r.Customer_Name__c',
                                                    'Warranty_Product_Total__c',
                                                    'Other_Product_Total__c',
                                                    'Product_Total__c',
                                                    'Trade_In_Total__c',
                                                    'Deal_Profitability__c',
                                                    'Invoice_Profitability__c',
                                                    'Stamp_Duty_Total__c',
                                                    'Total_Amount_Except_Charge_Account__c',
                                                    'Taxable_Total__c',
                                                    'Non_Taxable_Total__c',
                                                    'Pre_Tax_Part_Total__c',
                                                    'Pre_Tax_Labour_Total__c',
                                                    'Pre_Tax_Sublet_Total__c',
                                                    'Pre_Tax_Unit_Total__c',
                                                    'Pre_Tax_Trade_In_Total__c',
                                                    'Pre_Tax_Warranty_Product_Total__c',
                                                    'Pre_Tax_Other_Product_Total__c',
                                                    'Deal_Commission__c',
                                                    'Salesperson__c',
                                                    'CO_Header__r.Account_Type__r.Name',
                                                    'Lien_Payout_Total__c'
                                            },
            
            'CO_Invoice_Payment__c'=> new Set<String>{'Id', 
                                                    'Name', 
                                                    'CO_Invoice_Header__r.CO_Header__c',
                                                    'CO_Invoice_Header__r.CO_Header__r.Name',
                                                    'CO_Invoice_Header__r.CO_Header__r.Customer__c',
                                                    'CO_Invoice_Header__r.CO_Header__r.Customer__r.Name',
                                                    'CO_Invoice_Header__r.CO_Header__r.CO_Type__c',
                                                    'Amount__c',
                                                    'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c',
                                                    'CO_Invoice_Header__r.CO_Header__r.Owner__r.Name',
                                                    'CO_Invoice_Header__r.CO_Header__r.Owner__c',
                                                    'CO_Invoice_Header__r.Status__c',
                                                    'CO_Invoice_Header__r.Invoice_Number__c',
                                                    'LastModifiedDate', 
                                                    'CreatedDate',
                                                    'LastModifiedDate__c',
                                                    'CreatedDate__c',
                                                    'Payment_Method__c',
                                                    'Reverse_Payment_From__c',
                                                    'Reverse_Payment_From__r.Name',
                                                    'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c',
                                                    'CO_Invoice_Header__r.CO_Header__r.Account_Type__r.Name',
                                                    'Cash_Drawer__r.Name',
                                                    'Payment_Date__c'
                                            },       
                                            
            'CO_Deposit__c'         => new Set<String>{'Id', 
                                                    'Name', 
                                                    'CO_Invoice_Header__r.CO_Header__c',
                                                    'CO_Header__r.Name',
                                                    'CO_Header__r.Customer__c',
                                                    'CO_Header__r.Customer__r.Name',
                                                    'CO_Header__r.Customer_Name__c',
                                                    'CO_Header__r.CO_Type__c',
                                                    'Amount__c',
                                                    'CO_Header__r.Owner__r.Name',
                                                    'CO_Header__r.Owner__c',
                                                    'CO_Invoice_Header__r.Status__c',
                                                    'LastModifiedDate', 
                                                    'CreatedDate',
                                                    'LastModifiedDate__c',
                                                    'CreatedDate__c',
                                                    'Payment_Method__c',
                                                    'CO_Header__r.Customer_Name__c',
                                                    'CO_Header__r.Account_Type__r.Name',
                                                    'Cash_Drawer__r.Name',
                                                    'Payment_Date__c'
                                            },                                                                          
            
            'Vendor_Order_Header__c'=> new Set<String>{ 'Id', 
                                                        'Name', 
                                                        'Vendor__c',
                                                        'Vendor__r.Name',
                                                        'Status__c',
                                                        'Owner__r.Name', 
                                                        'Owner__c',
                                                        'LastModifiedDate', 
                                                        'CreatedDate',
                                                        'LastModifiedDate__c',
                                                        'CreatedDate__c',
                                                        'Total__c',
                                                        'Total_Recieved__c',
                                                        'Status__c',
                                                        'Purchase_Order_Type__c',
                                                        'Purchase_Order_Type__r.Code__c',
                                                        'Vendor__r.Vendor_Account_Type__r.Name'                                                        
                                            },  
                                            
            'Return_VO_Header__c'=> new Set<String>{ 'Id', 
                                                        'Name', 
                                                        'Vendor__c',
                                                        'Vendor__r.Name',
                                                        'Status__c',
                                                        'OwnerId',
                                                        'Owner.Name',
                                                        'LastModifiedDate', 
                                                        'CreatedDate',
                                                        'LastModifiedDate__c',
                                                        'CreatedDate__c',
                                                        'Total__c',
                                                        'Vendor__r.Vendor_Account_Type__r.Name'
                                            },
                                                                           
            'Vendor_Receiving_Header__c'=> new Set<String>{ 'Id', 
                                                            'Name', 
                                                            'Vendor__c',
                                                            'Vendor__r.Name',
                                                            'Status__c', 
                                                            'Owner__r.Name', 
                                                            'Owner__c',
                                                            'Packing_Slip_Number__c',
                                                            'LastModifiedDate', 
                                                            'CreatedDate',
                                                            'LastModifiedDate__c',
                                                            'CreatedDate__c',
                                                            'Status__c',
                                                            'Receiving_Total__c',
                                                            'Receipt_Number__c',
                                                            'Vendor__r.Vendor_Account_Type__r.Name'
                                            },
                                            
            'Vendor_Invoicing_Header__c'=> new Set<String>{ 'Id', 
                                                            'Name', 
                                                            'Vendor_Invoice_Number__c',
                                                            'Vendor__c',
                                                            'Vendor__r.Name',
                                                            'Status__c', 
                                                            'Owner__r.Name', 
                                                            'Owner__c',
                                                            'Invoice_Number__c',
                                                            'LastModifiedDate', 
                                                            'CreatedDate',
                                                            'LastModifiedDate__c',
                                                            'CreatedDate__c',
                                                            'Status__c',
                                                            'Total__c',
                                                            'Total_With_Tax__c',
                                                            'Vendor__r.Vendor_Account_Type__r.Name'
                                            },
            'Category__c'=> new Set<String>{    'Id', 
                                                'Name', 
                                                'Description__c',
                                                'Status__c', 
                                                'Owner.Name', 
                                                'OwnerId',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Unique_Category__c',
                                                'Type__c',
                                                'Active__c'
                                },
            'Price_Level__c'=> new Set<String>{ 'Id', 
                                                'Name__c', 
                                                'Description__c',
                                                'Status__c', 
                                                'Owner.Name', 
                                                'OwnerId',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Name',
                                                'Discount_Markup__c',
                                                'Active__c'
                                },
            'Sales_Tax__c'=> new Set<String>{   'Id', 
                                                'Name__c', 
                                                'Forms_Label__c',
                                                'Status__c', 
                                                'Owner.Name', 
                                                'OwnerId',
                                                'LastModifiedDate', 
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Name',
                                                'Rate__c',
                                                'Active__c'
                                },
                                
            'Product__c' => new Set<String>{    'Id',
                                                'Description__c',
                                                'Category__r.Name',
                                                'Name',
                                                'Price__c',
                                                'Status__c', 
                                                'LastModifiedDate',
                                                'Vendor__r.Vendor_Code__c',
                                                'Cost__c',
                                                'Code__c',
                                                'Vendor__r.Owner.Name',
                                                'Vendor__r.Name',
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Product_Unique_Name__c',
                                                'Type__c',
                                                'Vendor__c',
                                                'Vendor__r.Vendor_Account_Type__r.Name'
                                },
                                
            'User'      => new Set<String>  {   'Id',
                                                'Name',
                                                'UserName',
                                                'Email',
                                                'LastModifiedDate',
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'CreatedBy.Name',
                                                'IsActive',
                                                'Phone'
                                },
                                
            'Service_Order_Header__c' => new Set<String>    {   'Id',
                                                'Name',
                                                'Name__c',
                                                'CO_Header__c',
                                                'CO_Header__r.Name',
                                                'CO_Header__r.Customer__c',
                                                'CO_Header__r.Customer__r.Name',
                                                'CO_Header__r.Owner__r.Name',
                                                'CO_Header__r.Owner__c',
                                                'Work_Status__c',
                                                'Total__c',
                                                'Tax_Amount__c',
                                                'SO_Type__c',
                                                'Technician_Name__c',
                                                'Hrs_Billed__c',
                                                'Hrs_Logged__c',
                                                'Total_Parts__c',
                                                'Total_Labor__c',
                                                'SO_Type__c',
                                                'Total_Sublet__c',
                                                'Total_Fees__c',
                                                'Total_Fee_With_Shop_Supplies__c',
                                                'Total_Tax__c',
                                                'Total_With_Tax__c',
                                                'Customer_Owned_Unit__c',
                                                'Customer_Owned_Unit__r.Unit_Id__c',
                                                'Customer_Owned_Unit__r.Stock_Id__c',
                                                'Customer_Owned_Unit__r.Unit_Type__c',
                                                'Customer_Owned_Unit__r.Unit_Number__c',
                                                'Customer_Owned_Unit__r.VIN_Number__c',
                                                'Customer_Owned_Unit__r.Plate__c',
                                                'SO_Concern__c',
                                                'Transaction_Type__c',
                                                'Transaction_Type__r.Code_Label__c',
                                                'LastModifiedDate',
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'CreatedBy.Name',
                                                'Deal__c',
                                                'CO_Header__r.Customer_Name__c',
                                                'Scheduled_Date__c'
                                },

            //Added by Nidhi - #1152 - 19-10-2016   
            'Customer_Owned_Unit__c' => new Set<String> {   'Id',
                                                'Name',
                                                'Stock_Id__c',
                                                'Year__c',
                                                'Unit_Make__r.Name',
                                                'Unit_Model__r.Name__c',
                                                'Unit_Model__r.Sub_Model__c',
                                                'Sub_Model__r.Sub_Model_Name__c',
                                                'Sub_Model__c',
                                                'Colour__c',
                                                'Status__c',
                                                'LastModifiedDate',
                                                'VIN_Number__c',
                                                'VIN_Number_Formula__c',
                                                'New_Unit__c',
                                                'Total_Base_Unit_Price__c',
                                                'Total_Base_Units_Cost__c', 
                                                'Total_Dealer_Options_Cost__c', 
                                                'Total_Dealer_Options_Price__c', 
                                                'Total_Factory_Options_Cost__c',
                                                'Total_Factory_Options_Price__c',
                                                'Deal_Options_WIP__c',
                                                'Total_Cost__c', 
                                                'Total_Price__c',
                                                'Location__c',
                                                'Category__r.Name',
                                                'Date_Stocked_In__c',
                                                'Age__c',
                                                'Key_No__c',
                                                'Engine_Serial_No__c',
                                                'Other_Serial_No__c',
                                                'Interior_Colour__c',
                                                'Owner.Name',
                                                'CreatedDate',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'Unit_Number__c',
                                                'Unit_Type__c', //Added by Pooja 8 Dec 2016
                                                'Date_Stocked_Out__c',
                                                'Taxable__c',
                                                'Applicable_Tax__c',
                                                'Applicable_Tax__r.Name__c',
                                                'Cylinders__c',
                                                'Automatic__c',
                                                'Manufactured_Date__c',
                                                'Mileage__c',
                                                'Mileage_Value__c',
                                                'Plate__c',
                                                'Reg_Expiry_Date__c',
                                                'Make_Name__c',
                                                'Model_Name__c',
                                                'Account__r.Name',
                                                'Account__r.Preferred_Phone__c',
                                                'Account__r.Home_Number__c',
                                                'Account__r.Mobile__c',
                                                'Account__r.Formatted_Home_number__c',
                                                'Account__r.Formatted_Mobile_Number__c',
                                                'Account__r.Formatted_Work_Number__c',
                                                'Account__r.Formatted_Preferred_Phone__c',
                                                'Assigned_Tag_1__c',
                                                'Assigned_Tag_2__c',
                                                'Unit_Type__c',
                                                'Account__r.Account_Type__r.Name',
                                                'Mileage_Type__c',
                                                'Compliance_Date__c',
                                                'Year_Of_1st_Rego__c',
                                                'Registration_Serial__c',
                                                'Manufactured_Date__c'
                                },
                                
            'CO_Line_Item__c' => new Set<String>  {   
                                                'Id',
                                                'Name',
                                                'Qty__c',
                                                'Part__c',
                                                'Fee__c',
                                                'Part__r.Vendor__r.Name',
                                                'Part__r.Part_Type__c',
                                                'Part__r.Category__r.Name',
                                                'Fee__r.Code__c',
                                                'Part__r.Part_Number__c',
                                                'Fee__r.Category__r.Name',
                                                'CO_Header__r.Customer_Name__c',
                                                'Invoice_Number__r.Invoice_Date__c',
                                                'LastModifiedDate',
                                                'CO_Header__r.Owner__r.Name',
                                                'Price__c',
                                                'Revenue__c',
                                                'Price_When_Tax_Included__c',
                                                'Part__r.Description__c',
                                                'Fee__r.Description__c',
                                                'Item_Code__c',
                                                'Item_Description__c',
                                                'Per_Item_Profit__c',
                                                'Invoice_Number__r.Invoice_Number__c'
                                },
            'Deal__c' => new Set<String>  {
                                                'Id',
                                                'Name',
                                                'CO_Header__r.Name',
                                                'CO_Header__r.Customer_Name__c',
                                                'CO_header__r.Customer__r.Name',
                                                'Type__c',
                                                'CO_Header__r.Deal_Total__c ',
                                                'Status__c',
                                                'LastModifiedDate',
                                                'CreatedDate',
                                                'Delivery_Date__c',
                                                'Unit_Price_And_Cost_Total__c',
                                                'Trade_In_Total__c',
                                                'Product_Total__c',
                                                'Fee_Total__c',
                                                'Sales_Tax_Total__c',
                                                'Part_Total__c',
                                                'Labour_Total__c',
                                                'Stamp_Duty_Total__c',
                                                'Lien_Payout_Total__c',
                                                'F_I_Total__c',
                                                'CO_Header__r.Owner__r.Name',
                                                'Owner.Name',
                                                'Pre_Tax_Fee_Total__c',
                                                'Pre_Tax_Other_Product_Total__c',
                                                'Pre_Tax_Part_And_Labor_Total__c',
                                                'Pre_Tax_Trade_In_Total__c',
                                                'Pre_Tax_Unit_Price_And_Cost_Total__c'
                                },
             'Deal_Item__c' => new Set<String>  {
                                                'Id',
                                                'Name',
                                                'Customer_Owned_Unit__r.Id',
                                                'Customer_Owned_Unit__r.Name',
                                                'Customer_Owned_Unit__r.Make_Name__c',
                                                'Customer_Owned_Unit__r.Model_Name__c',
                                                'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c',
                                                'Customer_Owned_Unit__r.Year__c',
                                                'Customer_Owned_Unit__r.Status__c',
                                                'Customer_Owned_Unit__r.VIN_Number_Formula__c',
                                                'Customer_Owned_Unit__r.New_Unit__c',
                                                'Customer_Owned_Unit__r.Category__r.Name',
                                                'Customer_Owned_Unit__r.Date_Stocked_In__c',
                                                'Customer_Owned_Unit__r.Age__c',
                                                'Customer_Owned_Unit__r.Mileage_Value__c',
                                                'Customer_Owned_Unit__r.Mileage_Type__c',
                                                'Customer_Owned_Unit__r.Colour__c',
                                                'Customer_Owned_Unit__r.Interior_Colour__c',
                                                'Customer_Owned_Unit__r.Stock_Id__c',
                                                'Customer_Owned_Unit__r.Unit_Number__c',
                                                'Customer_Owned_Unit__r.Assigned_Tag_2__c',
                                                'Customer_Owned_Unit__r.Assigned_Tag_1__c',
                                                'Deal__r.CO_Header__c',
                                                'Deal__r.CO_Header__r.Name',
                                                'Deal__r.CO_Header__r.Customer_Name__c',
                                                'Deal__r.Type__c',
                                                'Deal__r.Status__c',
                                                'Other_Product_Total__c',
                                                'Labour_Total__c',
                                                'Base_Price__c',
                                                'Dealer_Option_Total__c',
                                                'Factory_Option_Total__c',
                                                'Fee_Total__c',
                                                'Part_Total__c',
                                                'Sublet_Total__c',
                                                'Warranty_Product_Total__c',
                                                'Stamp_Duty_Total__c',
                                                'Total_Price__c',
                                                'Date_Sold__c',
                                                'Type__c',
                                                'Owner.Name',
                                                'LastModifiedDate',
                                                'CreatedDate',
                                                'Customer_Owned_Unit__r.Compliance_Date__c',
                                                'Customer_Owned_Unit__r.Year_Of_1st_Rego__c',
                                                'Customer_Owned_Unit__r.Registration_Serial__c',
                                                'Customer_Owned_Unit__r.Manufactured_Date__c'
            					},
            'Service_Order_Line_Item__c' => new Set<String>  {   
                                                'Id',
                                                'Name',
                                                'Part__r.Vendor__r.Name',
                                                'Sublet__r.Vendor__r.Name',
                                                'Part__r.Part_Number__c',
                                                'Part__r.Part_Type__c',
                                                'Labour_Code__r.Code__c',
                                                'Fee__r.Code__c',
                                                'Qty_Needed__c',
                                                'Kit_Price__c',
                                                'Revenue__c',
                                                'Per_Item_Profit__c',
                                                'Price_When_Tax_Included__c',
                                                'Part__r.Description__c',
                                                'Fee__r.Description__c',
                                                'Labour_Code__r.Description__c',
                                                'Sublet__r.Code__c',
                                                'Sublet__r.Description__c',
                                                'Item_Code__c',
                                                'Item_Description__c',
                                                'Part__r.Category__r.Name',
                                                'Fee__r.Category__r.Name',
                                                'Labour_Code__r.Category__r.Name',
                                                'Sublet__r.Category__r.Name',
                                                'Service_Order_Header__r.CO_Header__r.Customer_Name__c',
                                                'Service_Order_Header__r.CO_Header__r.Owner__r.Name',
                                                'LastModifiedDate',
                                                'Service_Order_Header__r.Invoice_Number__r.Invoice_Number__c',
                                                'Service_Order_Header__r.Invoice_Number__r.Invoice_Date__c',
                                                'Sublet__r.Type__c'
                                },
            'Option_Fee__c' => new Set<String>  {   
                                                'Id',
                                                'Name',
                                                'Product__c',
                                                'Part__c',
                                                'Fee__c',
                                                'Labour_Code__c',
                                                'Revenue__c',
                                                'Per_Item_Profit__c',
                                                
                                                'Product__r.Description__c',
                                                'Part__r.Description__c',
                                                'Fee__r.Description__c',
                                                'Labour_Code__r.Description__c',
                                                'Item_Code__c',
                                                'Item_Description__c',
                                                'Part__r.Part_Type__c',
                                                'Part__r.Vendor__r.Name',
                                                'Product__r.Vendor__r.Name',
                                                
                                                'Part__r.Part_Number__c',
                                                'Labour_Code__r.Code__c',
                                                'Fee__r.Code__c',
                                                'Product__r.Code__c',
                                                'Product__r.Type__c',
                                                
                                                'Part__r.Category__r.Name',
                                                'Fee__r.Category__r.Name',
                                                'Labour_Code__r.Category__r.Name',
                                                'Product__r.Category__r.Name',
                                                
                                                'Deal__r.CO_Header__r.Customer_Name__c',
                                                'Deal__r.CO_Header__r.Owner__r.Name',
                                                
                                                'Deal__r.Invoice_Number__r.Invoice_Number__c',
                                                'Deal__r.Invoice_Number__r.Invoice_Date__c',
                                                'Qty__c',
                                                'Price__c',
                                                'Price_When_Tax_Included__c',
                                                'LastModifiedDate'
                                },                  
            'Vendor_Order_Line_Item__c' => new Set<String>  {   
                                                'Id',
                                                'Name',
                                                'Part__r.Vendor__r.Name',
                                                'Sublet__r.Vendor__r.Name',
                                                'Service_Order_Line_Item__r.Item_Code__c',
                                                'Service_Order_Line_Item__r.Item_Description__c',
                                                'Part__r.Description__c', 
                                                'Part__r.Item_Description__c',
                                                'CO_Header__r.Name',
                                                'CO_Header__c',
                                                'Cost__c',
                                                'Qty_Needed__c',
                                                'Part__r.Status__c',
                                                'Part__r.Part_Type__c',
                                                'Part__r.Part_Number__c',
                                                'Part__r.Last_Cost__c',
                                                'Is_required_For_Customer__c',
                                                'Is_Service__c',
                                                'CO_Header__r.Customer__r.Name',
                                                'LastModifiedDate',
                                                'Status__c',
                                                'Dealer_Name__c',
                                                'Total_Cost__c',
                                                'Owner.Name',
                                                'LastModifiedDate__c',
                                                'CreatedDate__c',
                                                'CreatedDate',
                                                'Needed_For__c',
                                                'Customer__c'
                                },
            'Part_FIFO_Bucket__c' => new Set<String>  {   
                                                'Name',
                                                'CreatedDate',
                                                'Qty_In__c',
                                                'Cost__c',
                                                'Source_Name__c',
                                                'Part__c',
                                                'Qty_In_Stock_When_Created__c',
                                                'Average_Cost_When_Created__c',
                                                '(SELECT CO_Line_Item__r.Price__c from Coli_Fifo_Line_Items_Junction__r WHERE CO_Line_Item__c != null AND CO_Line_Item__r.Price__c != null )'
                                },
             'Part_FIFO_Bucket_Activity_Line_Item__c' => new Set<String>  {   
                                                'Name',
                                                'CreatedDate',
                                                'Qty_Out__c',
                                                'Cost__c',
                                                'CO_Invoice_Header__c',
                                                'Reference__c',
                                                'Part_FIFO_Bucket__r.Cost__c',
                                                'Part_FIFO_Bucket__r.Part__c',
                                                'Qty_In_Stock_When_Created__c',
                                                'Average_Cost_When_Created__c',
                                                '(SELECT CO_Line_Item__r.Price__c from Coli_Fifo_Line_Items_Junction__r WHERE CO_Line_Item__c != null AND CO_Line_Item__r.Price__c != null)'
                                }
                                                             
          };
    
    //Modified by Nidhi - #1152 - 19-10-2016   
    // A map to define group with object names
    public static Map<String, List<String>> groupNameToGroupObjectsMap = new Map<String, List<String>>{ 'People'            => new List<String>{'Customers', 'Vendors'},
                                                                                                        'Products'          => new List<String>{'Parts', 'Kits', 'Fees', 'Labor Codes', 'Sublets', 'Vendor Product', 'Inventory Unit'},
                                                                                                        'Customer Sales'    => new List<String>{'Customer Orders', 'Customer Invoices', 'Customer Payments', 'Service Jobs', 'Unit Deals', 'Parts Order'},
                                                                                                        'Vendor Ordering'   => new List<String>{'Vendor Orders', 'Vendor Receivings', 'Vendor Invoices'},
                                                                                                        'Setting'           => new List<String>{'Item Categories', 'Sales Taxes', 'Price Levels'}
                                                                                                    };
    
    //Modified by Nidhi - #1152 - 19-10-2016   
    // A map to define group/display object name to object API name
    public static Map<String, String> displayObjectNameToObjectAPINameMap = new Map<String, String>{'People'            => 'Account',
                                                                                                    'Customers'         => 'Account',
                                                                                                    'Vendors'           => 'Account',
                                                                                                    'Parts'             => 'Part__c',
                                                                                                    'Kits'              => 'Kit_Header__c',
                                                                                                    'Fees'              => 'Fee__c',
                                                                                                    'Labor Codes'       => 'Labour_Code__c',
                                                                                                    'Sublets'           => 'Product__c',
                                                                                                    'Vendor Product'   => 'Product__c',
                                                                                                    'Financing Product' => 'Product__c',
                                                                                                    'Deal Product'      => 'Product__c',
                                                                                                    'Warranty Plan'     => 'Product__c',
                                                                                                    'Other Product'     => 'Product__c',
                                                                                                    'Users'             => 'User',
                                                                                                    'Customer Orders'   => 'CO_Header__c',
                                                                                                    'Customer Invoices' => 'CO_Invoice_Header__c',
                                                                                                    'Customer Payments' => 'CO_Invoice_Payment__c',
                                                                                                    'Customer Deposits' => 'CO_Deposit__c',
                                                                                                    'Vendor Orders'     => 'Vendor_Order_Header__c',
                                                                                                    'Vendor Return' => 'Return_VO_Header__c',
                                                                                                    'Vendor Receivings' => 'Vendor_Receiving_Header__c',
                                                                                                    'Vendor Invoices'   => 'Vendor_Invoicing_Header__c',
                                                                                                    'Item Categories'   => 'Category__c',
                                                                                                    'Price Levels'      => 'Price_Level__c',
                                                                                                    'Sales Taxes'       => 'Sales_Tax__c',
                                                                                                    'Service Jobs'      => 'Service_Order_Header__c',
                                                                                                    //Dinesh Kumar 10/10/2016
                                                                                                    'Parts Needed'      => 'Vendor_Order_Line_Item__c',
                                                                                                    'Inventory Unit'        => 'Customer_Owned_Unit__c',
                                                                                                    'Part Inventory Valuation'      => 'Part__c',
                                                                                                    'Customer Unit'        => 'Customer_Owned_Unit__c',
                                                                                                    'Invoiced Items'       => 'CO_Line_Item__c',
                                                                                                    'SOLI'                 => 'Service_Order_Line_Item__c',
                                                                                                    'Option and Fee'       => 'Option_Fee__c',
                                                                                                    'Technician Hours'     => 'Hours_Logged__c',
                                                                                                    'Payroll Hours'        => 'Payroll_Time__c',
                                                                                                    'Technician Performance'=> 'Technician__c',
                                                                                                    'Unit Deals' => 'Deal__c',
                                                                                                    'Part FIFO' => 'Part_FIFO_Bucket__c',
                                                                                                    'Part FIFO Line Item' => 'Part_FIFO_Bucket_Activity_Line_Item__c',
                                                                                                    'Tax Detail Customer Invoices' => 'CO_Invoice_Header__c',
                                                                                                    'Tax Detail Vendor Invoices' => 'Vendor_Invoicing_Header__c',
                                                                                                    'Deal Units' => 'Deal_Item__c',
                                                                                                    'Parts Order' => 'CO_Header__c'
                                                                                                };
    // Special Searching filters - which is having multiple objects to search but only display in one name LIKE - Tax Detail
    public static Map<String, String> displayObjectNameToObjectAPINameSpecialSearchMap = new Map<String, String> {
                                                                                                    'Tax Detail Customer Invoices'  => 'CO_Invoice_Header__c',
                                                                                                    'Tax Detail Vendor Invoices'    => 'Vendor_Invoicing_Header__c'
                                                                                                };
    
    //Modified by Nidhi - #1152 - 19-10-2016                                                                                                
    // A map to define group/display object name to object API name
    public static Map<String, String> displayObjectAPINameToObjectNameMap = new Map<String, String>{'Account'                       => 'Customer',
                                                                                                    CONSTANTS.NAMESPACE+'Part__c'                       => 'Part',
                                                                                                    CONSTANTS.NAMESPACE+'Kit_Header__c'                 => 'Kit',
                                                                                                    CONSTANTS.NAMESPACE+'Fee__c'                        => 'Fee',
                                                                                                    CONSTANTS.NAMESPACE+'Labour_Code__c'                => 'Labor Code',
                                                                                                    CONSTANTS.NAMESPACE+'Product__c'                    => 'Sublet',
                                                                                                    'User'                          => 'User',
                                                                                                    CONSTANTS.NAMESPACE+'CO_Header__c'                  => 'Customer Order',
                                                                                                    CONSTANTS.NAMESPACE+'CO_Invoice_Header__c'          => 'Customer Invoice',
                                                                                                    CONSTANTS.NAMESPACE+'CO_Invoice_Payment__c'         => 'Customer Payment',
                                                                                                    CONSTANTS.NAMESPACE+'CO_Deposit__c'                 => 'Customer Payment',
                                                                                                    CONSTANTS.NAMESPACE+'Vendor_Order_Header__c'        => 'Vendor Order',
                                                                                                    CONSTANTS.NAMESPACE+'Vendor_Receiving_Header__c'    => 'Vendor Receiving',
                                                                                                    CONSTANTS.NAMESPACE+'Vendor_Invoicing_Header__c'    => 'Vendor Invoice',
                                                                                                    CONSTANTS.NAMESPACE+'Category__c'                   => 'Item Categorie',
                                                                                                    CONSTANTS.NAMESPACE+'Price_Level__c'                => 'Price Level',
                                                                                                    CONSTANTS.NAMESPACE+'Sales_Tax__c'                  => 'Sales Tax',
                                                                                                    CONSTANTS.NAMESPACE+'Service_Order_Header__c'       => 'Service Job',
                                                                                                    CONSTANTS.NAMESPACE+'Vendor_Order_Line_Item__c'     => 'Parts Needed',
                                                                                                    CONSTANTS.NAMESPACE+'Customer_Owned_Unit__c'        => 'Inventory Unit',
                                                                                                    CONSTANTS.NAMESPACE+'Customer_Owned_Unit__c'        => 'Customer Unit',
                                                                                                    CONSTANTS.NAMESPACE+'CO_Line_Item__c'               => 'Invoiced Items',
                                                                                                    CONSTANTS.NAMESPACE+'Service_Order_Line_Item__c'    => 'SOLI',
                                                                                                    CONSTANTS.NAMESPACE+'Option_Fee__c'                 => 'Option and Fee',
                                                                                                    CONSTANTS.NAMESPACE+'Hours_Logged__c'               => 'Technician Hours',
                                                                                                    CONSTANTS.NAMESPACE+'Payroll_Time__c'               => 'Payroll Hours',
                                                                                                    CONSTANTS.NAMESPACE+'Technician__c'                 => 'Technician Performance',
                                                                                                    CONSTANTS.NAMESPACE+'Part_FIFO_Bucket__c'           => 'Part FIFO',
                                                                                                    CONSTANTS.NAMESPACE+'Deal__c'          				=> 'Unit Deals',
                                                                                                    CONSTANTS.NAMESPACE+'Deal_Item__c'          		=> 'Deal Units'
                                                                                                };
    
    //Modified by Nidhi - #1152 - 19-10-2016                                                                                                
    // A map to define group/display object name to object API name
    public static Map<String, Integer> displayObjectNameToTypeNumber = new Map<String, Integer>{'Customers'         => 1,
                                                                                                'Vendors'           => 2,
                                                                                                'Parts'             => 3,
                                                                                                'Kits'              => 4,
                                                                                                'Fees'              => 5,
                                                                                                'Labor Codes'       => 6,
                                                                                                'Users'             => 7,
                                                                                                'Customer Orders'   => 8,
                                                                                                'Customer Invoices' => 9,
                                                                                                'Vendor Orders'     => 10,
                                                                                                'Vendor Receivings' => 11,
                                                                                                'Vendor Invoices'   => 12,
                                                                                                'Item Categories'   => 13,
                                                                                                'Price Levels'      => 14,
                                                                                                'Sales Taxes'       => 15,
                                                                                                'Sublets'           => 16,
                                                                                                'Customer Payments' => 17,
                                                                                                'Service Jobs'      => 18,
                                                                                                'Inventory Unit'    => 19,
                                                                                                'Parts Needed'      => 20,
                                                                                                'Part Inventory Valuation'  => 21,
                                                                                                'Customer Unit'  => 22,
                                                                                                'Financing Product' => 23,
                                                                                                'Deal Product'      => 24,
                                                                                                'Warranty Plan'     => 25,
                                                                                                'Vendor Return'     => 26,
                                                                                                'Other Product'     => 27,
                                                                                                'Technician Hours'  => 28,
                                                                                                'Payroll Hours'     => 29,
                                                                                                'Technician Performance' => 30,
                                                                                                'Unit Deals' => 31,
                                                                                                'Deal Units' => 32,
                                                                                                'Parts Order' => 33
                                                                                                
                                                                                            };

    //Modified by Nidhi - #1152 - 19-10-2016                                                                                    
    public static Map<String, Integer> filterGroupToOrderMap = new Map<String, Integer>{'Reporting' => 1,
                                                                                        'Customer Sales'    => 2,
                                                                                        'Vendor Orders' => 3,
                                                                                        'Product'   => 4,
                                                                                        'People'    => 5,
                                                                                        'Setting'   => 6,
                                                                                        'Settings'  => 6,
                                                                                        
                                                                                        'Customer Payments' => 6,
                                                                                        'Invoice Summary' => 7,
                                                                                        'Tax Detail' => 8,
                                                                                        'Payroll Hours' => 9,
                                                                                        'Technician Hours' => 10,
                                                                                        'Technician Performance' => 11,
                                                                                        'Part Inventory Valuation' => 12,
                                                                                        'Part Inventory Aging' => 13,
                                                                                        'Part Movement' => 14,
                                                                                        'Active Part Sales' => 15,
                                                                                        'Open Service Jobs'   => 16,
                                                                                        'Active Unit Deals' => 17,
                                                                                        'Deal Units' => 18,
                                                                                        'My Customer Orders'    => 19,
                                                                                        'All Customer Orders'   => 20,
                                                                                        'Recent Customer Invoices'  => 21,
                                                                                        'My Vendor Orders'  => 22,
                                                                                        'All Vendor Orders' => 23,
                                                                                        'Active Receivings' => 24,
                                                                                        'Recent Vendor Invoices'    => 24,
                                                                                        'Recent Parts'  => 25,
                                                                                        'Parts Needed'  =>26,
                                                                                        'Stock Units'               => 26,
                                                                                        'Kits'                      => 28,
                                                                                        'Sublets'                   => 29,
                                                                                        'Labor'                     => 30,
                                                                                        'Labour'                    => 29,
                                                                                        'Fees'                      => 31,
                                                                                        'Customers'                 => 32,
                                                                                        'Customer'                  => 32,
                                                                                        'Customer Units'            => 33,
                                                                                        'Vendors'                   => 34,
                                                                                        'Vendor'                    => 35,
                                                                                        'Category'                  => 35,
                                                                                        'Price Level'               => 36,
                                                                                        'Sales Tax'                 => 37,
                                                                                        'Product History Detail'    => 38,
                                                                                        'Product History Summary'   => 39

                                                                                    };
    
    // Map to define label to UI map Key
    public static Map<String, Map<String, String>> objectNameToLabelToJSONKeyMap = new Map<String, Map<String, String>> {
            'Customers' => new Map<String, String>{ 'Id' => 'People_Id',
                                                    'Name' => 'People_Name',
                                                    'Phone' => 'People_Phone',
                                                    'Email' => 'People_Email',
                                                    'Address' => 'People_BillingAddress',
                                                    'City' => 'People_BillingCity',
                                                    'State' => 'People_StateProv',
                                                    'Country' => 'People_Country',
                                                    'Sales Tax' => 'People_SalesTax',
                                                    'Price Level' => 'People_PriceLevel',
                                                    'Account Type' => 'Customer_AccountType',
                                                    'Drivers License' => 'Customers_Drivers_License'
                            
                            },
            'Invoiced Items' => new Map<String, String>{ 'Type' => 'InvoicedItem_Type',
                                                    'Item' => 'InvoicedItem_Item',
                                                    'Customer' => 'InvoicedItem_Customer',
                                                    'Invoice date' => 'InvoicedItem_InvoiceDate',
                                                    'Category' => 'InvoicedItem_Category',
                                                    'Invoiced By' => 'InvoicedItem_InvoicedBy',
                                                    'Vendor' => 'InvoicedItem_Vendor',
                                                    'Qty' => 'InvoicedItem_Quantity',
                                                    'Revenue' => 'InvoicedItem_Revenue'
                            
                            },
                            
            'Technician Hours' => new Map<String, String>{ 'Type' => 'TechinicianHours_ItemType',
                                                    'Technician' => 'TechinicianHours_Technician',
                                                    'Date' => 'TechinicianHours_Date',
                                                    'Job Type' => 'TechinicianHours_JobType',
                                                    'Customer' => 'InvoicedItem_Customer'
                            },
             'Technician Performance' => new Map<String, String>{ 'Technician' => 'TechinicianPerformance_Technician',
                                                    'Date' => 'TechinicianPerformance_Date'
             },
                            
             'Payroll Hours' => new Map<String, String>{ 'Employee' => 'Payroll_Employee',
                                                    'Date' => 'Payroll_Date'
                            },
                            
            'Vendors' =>  new Map<String, String> { 'Id' => 'People_Id',
                                                    'Name' => 'People_Name',
                                                    'Phone' => 'People_Phone',
                                                    'Email' => 'People_Email',
                                                    'Address' => 'People_BillingAddress',
                                                    'City' => 'People_BillingCity',
                                                    'State' => 'People_StateProv',
                                                    'Country' => 'People_Country',
                                                    'Sales Tax' => 'People_SalesTax',
                                                    'Price Level' => 'People_PriceLevel',
                                                    'Purchase Sales Tax' => 'Vendor_PurchaseSalesTax',
                                                    'Account Type' => 'Vendor_AccountType'
                            },  
            'People' => new Map<String, String> {   'Id' => 'People_Id',
                                                    'Name' => 'People_Name',
                                                    'Phone' => 'People_Phone',
                                                    'Email' => 'People_Email',
                                                    'Address' => 'People_BillingAddress',
                                                    'City' => 'People_BillingCity',
                                                    'State' => 'People_StateProv',
                                                    'Country' => 'People_Country',
                                                    'Sales Tax' => 'People_SalesTax',
                                                    'Price Level' => 'People_PriceLevel'
                                },
                                            
            'Products' => new Map<String, String> { 'Item'              => 'Product_Item',
                                                    'Description'       => 'Product_Description',
                                                    'Category'          => 'Product_Category' ,
                                                    'Price'             => 'Product_Price'
                                                    //'Qty Available'     => 'Product_QtyAvailable'
                                                },      
                                                                        
            'Kits' => new Map<String, String> {     'Item'              => 'Product_Item',
                                                    'Description'       => 'Product_Description',
                                                    'Category'          => 'Product_Category',
                                                    'Price'             => 'Product_Price',
                                                    //'Qty Available'     => 'Product_QtyAvailable',
                                                    'Kit Price'         => 'Kit_KitPrice',
                                                    'Fixed Price'       => 'Kit_FixedPrice' ,
                                                    'Service Kit'       =>'Kit_ServiceKit' 
                                                },  
                                                
            'Fees' => new Map<String, String> {     'Item'              => 'Product_Item',
                                                    'Description'       => 'Product_Description',
                                                    'Category'          => 'Product_Category' ,
                                                    'Price'             => 'Product_Price',
                                                    //'Qty Available'     => 'Product_QtyAvailable',
                                                    'Fee Type'          => 'Fee_FeeType'
                                                },  
                                                
            'Service_Jobs' => new Map<String, String> { 'Scheduled'      => 'Service_Job_Scheduled',
                                                        'Job Type'       => 'Service_Job_Job_Type',
                                                        'VIN'            => 'Service_Job_VIN',
                                                        'Plate Number'           => 'Service_Job_Plate_Number'
                                                },                                                  
                                                
            'Inventory_Unit' => new Map<String, String> { 'VIN'             => 'Inventory_Unit_VIN',
                                                        'Stock Number'      => 'Inventory_Unit_Stock_Number',
                                                        'Make'              => 'Inventory_Unit_Make',
                                                        'Model'             => 'Inventory_Unit_Model',
                                                        'SubModel'          => 'Inventory_Unit_SubModel', 
                                                        'Year'              => 'Inventory_Unit_Year',
                                                        'Ext Colour'        => 'Inventory_Unit_Ext_Colour',
                                                        'New Unit'          => 'Inventory_Unit_New_Unit',
                                                        'Base Unit Price'   => 'Inventory_Unit_Base_Unit_Price',
                                                        'Factory Options'   => 'Inventory_Unit_Factory_Options',
                                                        'Dealer Options'    => 'Inventory_Unit_Dealer_Options',
                                                        'Total Price'       => 'Inventory_Unit_Total_Price',
                                                        'Base Unit Cost'    => 'Inventory_Unit_Base_Unit_Cost',
                                                        'Factory Option Cost'=> 'Inventory_Unit_Factory_Option_Cost',
                                                        'Dealer Option Cost'=> 'Inventory_Unit_Dealer_Option_Cost', 
                                                        'Deal Options WIP'  => 'Inventory_Unit_Deal_Options_WIP',
                                                        'Total Cost'        => 'Inventory_Unit_Total_Cost',
                                                        'Location'          => 'Inventory_Unit_Location', 
                                                        'Category'          => 'Inventory_Unit_Category',
                                                        'Stocked'           => 'Inventory_Unit_Stocked_In',
                                                        'Age'               => 'Inventory_Unit_Age',
                                                        'Key Number'        => 'Inventory_Unit_Key_Number',
                                                        'Engine Number'     => 'Inventory_Unit_Engine_Number',
                                                        'Other Number'      => 'Inventory_Unit_Other_Number',
                                                        'Int Colour'        => 'Inventory_Unit_Int_Colour',
                                                        'Stocked Out'       => 'Inventory_Unit_Stocked_Out',
                                                        'Taxable'           => 'Inventory_Unit_Taxable',
                                                        'Applicable Tax'    => 'Inventory_Unit_Applicable_Tax',
                                                        'Cylinders'         => 'Inventory_Unit_Cylinders' ,
                                                        'Automatic'         => 'Inventory_Unit_Automatic',
                                                        'Manufactured Date' => 'Inventory_Unit_Manufactured_Date',
                                                        'Mileage'           => 'Inventory_Unit_Mileage',
                                                        'Plate Number'      => 'Inventory_Unit_Plate_Number',
                                                        'Reg Expiry'        => 'Inventory_Unit_Reg_Expiry',
                                                        'Tags'              => 'AssignedTags' ,
                                                        'Unit Type'         => 'Inventory_Unit_Unit_Type',
                                                        'Compliance Date'         => 'Inventory_Unit_Compliance_Date',
                                                        'Year of 1st Rego'         => 'Inventory_Unit_Year_Of_1st_Rego',
                                                        'Registration Serial#'         => 'Inventory_Unit_Registration_Serial'
                                                },  
                                                
            'Customer_Unit' => new Map<String, String> {'Unit ID'           => 'Customer_Unit_Unit_ID',
                                                        'Customer'          => 'Customer_Unit_Customer' ,
                                                        'Year'              => 'Customer_Unit_Year',
                                                        'Make'              => 'Customer_Unit_Make',
                                                        'Model'             => 'Customer_Unit_Model',
                                                        'SubModel'          => 'Customer_Unit_SubModel',
                                                        'Mileage'           => 'Customer_Unit_Mileage',  
                
                                                        'VIN'               => 'Customer_Unit_VIN',
                                                        'Plate Number'      => 'Customer_Unit_Plate_Number',
                                                        'Reg Expiry'        => 'Customer_Unit_Reg_Expiry' ,
                                                        'Key Number'        => 'Customer_Unit_Key_Number',
                                                        'Engine Number'     => 'Customer_Unit_Engine_Number',
                                                        'Other Number'      => 'Customer_Unit_Other_Number',
                                                        'Ext Colour'        => 'Customer_Unit_Ext_Colour',
                                                        'Int Colour'        => 'Customer_Unit_Int_Colour',
                                                        'Tags'              => 'AssignedTags',
                                                        'Account Type' => 'Customer_AccountType',
                                                        'Compliance Date' => 'Customer_Unit_Compliance_Date',
                                                        'Year of 1st Rego' => 'Customer_Unit_Year_Of_1st_Rego',
                                                        'Registration Serial#' => 'Customer_Unit_Registration_Serial',
                                                        'Manufactured Date' => 'Customer_Unit_Manufactured_Date'
                                                },  
                                                                                                
                                                
            'Labor_Codes' => new Map<String, String> {  'Item'          => 'Product_Item',
                                                        'Description'   => 'Product_Description',
                                                        'Category'      => 'Product_Category' ,
                                                        'Price'         => 'Product_Price'
                                                        //'Qty Available' => 'Product_QtyAvailable'
                                                },
            'Product__c' => new Map<String, String> {   'Category'  =>  'Category__r.Name',
                                                        'Code'      => 'Code__c',
                                                        'Cost'      => 'Cost__c',
                                                        'Description'=> 'Description__c',
                                                        'Modified'  =>  'LastModifiedDate',
                                                        'Price'     =>  'Price__c',
                                                        'Status'    =>  'Status__c',
                                                        'Vendor Code'=> 'Vendor_Code__c'
                                                },                              
                                                
            'Parts' => new Map<String, String> {        'Item'          => 'Product_Item',
                                                        'Description'   => 'Product_Description',
                                                        'Category'      => 'Product_Category' ,
                                                        'Price'         => 'Product_Price',
                                                        'Qty Available' => 'Product_QtyAvailable',
                                                        'Vendor'        => 'Part_Vendor',
                                                        'Cost'          => 'Part_Cost',
                                                        'Avg Cost'      => 'Part_AverageCost',
                                                        'Location'      => 'Part_Location', 
                                                        'In Stock'      => 'Part_InStock',
                                                        'Committed'     => 'Part_Committed',
                                                        'On Order'      => 'Part_OnOrder',
                                                        'Packaged Part' => 'Part_PackagedPart',
                                                        'LastCounted'   => 'Part_LastCounted',
                                                        'Last Sold'     => 'Part_LastSold',
                                                        'Last Stocked'  => 'Part_LastStocked',
                                                        'Reorder At'    => 'Part_ReorderAt', 
                                                        'Reorder To'    => 'Part_ReorderTo',
                                                        'Status'        =>  'Part_Status',
                                                        'Non Inventory' =>  'Part_NonInventory', //Added by richa 28/11/2016
                                                        'SKU'           =>  'Part_SKUNumber', //Added by richa 28/11/2016
                                                        'Mfg Part'      =>  'Part_MfgPart', //Added by richa 28/11/2016
                                                        'Oversold Qty'  =>  'Part_OversoldQty',
                                                        'Oversold Cost' =>  'Part_OversoldCost',
                                                        'PRD1 Qty'      => 'Part_PRD1Qty',
                                                        'PRD1 Cost'     => 'Part_PRD1Cost',
                                                        'PRD2 Qty'      => 'Part_PRD2Qty',
                                                        'PRD2 Cost'     => 'Part_PRD2Cost',
                                                        'PRD3 Qty'      => 'Part_PRD3Qty',
                                                        'PRD3 Cost'     => 'Part_PRD3Cost',
                                                        'PRD4 Qty'      => 'Part_PRD4Qty',
                                                        'PRD4 Cost'     => 'Part_PRD4Cost',
                                                        'Tags'          =>  'AssignedTags',
                                                        'Part Type'     =>  'Part_Type'
                                           },
                                           
            'Invoiced Items' => new Map<String, String> {'Item Type' => 'InvoicedItem_Type',
                                                        'Item'   => 'InvoicedItem_Item',
                                                        'Customer'      => 'InvoicedItem_Customer' ,
                                                        'Invoice date'         => 'InvoicedItem_InvoiceDate',
                                                        'Category' => 'InvoicedItem_Category',
                                                        'Invoiced By'        => 'InvoicedItem_InvoicedBy',
                                                        'Vendor'          => 'InvoicedItem_Vendor',
                                                        'Quantity'      => 'InvoicedItem_Quantity',
                                                        'Revenue'      => 'InvoicedItem_Revenue'
                                           },
                                           
            'Customer_Sales' => new Map<String, String> {   'Id'            => 'Customer_Sales_Id',
                                                            'Customer'      => 'Customer_Sales_Customer',
                                                            'Total'         => 'Customer_Sales_Total',
                                                            'Balance Due'   => 'Customer_Sales_Balance_Due'
                                            },
                                            
            'Customer_Orders' => new Map<String, String> {  'Id'            => 'Customer_Sales_Id',
                                                            'Customer'      => 'Customer_Sales_Customer',
                                                            'Total'         => 'Customer_Sales_Total',
                                                            'Balance Due'   => 'Customer_Sales_Balance_Due',
                                                            'Deposits'      => 'Customer_Order_Deposits',
                                                            'Invoiced'      => 'Customer_Order_Payments',
                                                            'Status'        => 'Customer_Order_Status',
                                                            'Deal Total'    => 'Customer_Order_Deal_Total',
                                                            'Notes'         => 'Customer_Order_Notes',
                                                            'Account Type' => 'Customer_AccountType'
                                                },
                                                
            'Customer_Invoices' => new Map<String, String> {'Id'            => 'Customer_Sales_Id',
                                                            'Customer'      => 'Customer_Sales_Customer',
                                                            'Total'         => 'Customer_Sales_Total',
                                                            'Balance Due'   => 'Customer_Sales_Balance_Due',
                                                            'Deposits'      => 'Customer_Order_Deposits',
                                                            'Payments'      => 'Customer_Order_Payments',
                                                            'Customer Order'=> 'CO_Invoice_Header_Customer_Order',
                                                            'Status'        => 'CO_Invoice_Header_Status',
                                                            'Part Total'    => 'CO_Invoice_Header_Part_Total',
                                                            'Fee Total'     => 'CO_Invoice_Header_Fee_Total',
                                                            'Labour Total'  => 'CO_Invoice_Header_Labour_Total',
                                                            'Unit Total'    => 'CO_Invoice_Header_Unit_Total',
                                                            'Sublet Total'  => 'CO_Invoice_Header_Sublet_Total',
                                                            'SalesTax Total'=> 'CO_Invoice_Header_SalesTax_Total',
                                                            'Commission'    => 'CO_Invoice_Header_Commission',
                                                            'Salesperson'   => 'CO_Invoice_Header_Salesperson',
                                                            'Account Type' => 'Customer_AccountType',
                                                            'Invoice Date' => 'COInvoice_InvoiceDate',
                                                            'Lien Payout' => 'CO_Invoice_Header_LienPayout_Total'                                                            
                                                    },
                                                    
            'Customer_Payments' => new Map<String, String> {'Id'            => 'Customer_Sales_Id',
                                                            'Customer'      => 'Customer_Sales_Customer',
                                                            'Total'         => 'Customer_Sales_Total',
                                                            'Customer Order'=> 'CO_Payment_Customer_Order',
                                                            'Payment Method'=> 'CO_Payment_Payment_Method',
                                                            'Account Type' => 'Customer_AccountType',
                                                            'Cash Drawer'	=> 'CO_Payment_Cash_Drawer'
                                                    },
            
                                                    
            'Vendor_Ordering' => new Map<String, String>{   'Id'            => 'Vendor_Ordering_Id',
                                                            'Vendor'        => 'Vendor_Ordering_Vendor',
                                                            'Total'         => 'Vendor_Ordering_Total'
                                                    },
                                                    
            'Vendor_Orders' => new Map<String, String>{     'Id'            => 'Vendor_Ordering_Id',
                                                            'Vendor'        => 'Vendor_Ordering_Vendor',
                                                            'Total'         => 'Vendor_Ordering_Total',
                                                            'Purchase Order'=> 'Vendor_Order_Purchase_Order',
                                                            'Total Recieved'=> 'Vendor_Order_Total_Recieved' ,
                                                            'Status'        => 'Vendor_Order_Status',
                                                            'Account Type'  =>  'Vendor_AccountType'
                                                    },
                                                    
            'Vendor_Receivings' => new Map<String, String>{ 'Id'            => 'Vendor_Ordering_Id',
                                                            'Vendor'        => 'Vendor_Ordering_Vendor',
                                                            'Total'         => 'Vendor_Ordering_Total',
                                                            'Status'        => 'Vendor_Invoicing_Header_Status',
                                                            'Account Type'  => 'Vendor_AccountType'
                                                    },
                                                    
            'Vendor_Invoices' => new Map<String, String>{   'Id'            => 'Vendor_Ordering_Id',
                                                            'Vendor'        => 'Vendor_Ordering_Vendor',
                                                            'Total'         => 'Vendor_Ordering_Total',
                                                            'Status'        => 'Vendor_Invoicing_Header_Status',
                                                            'Account Type'  => 'Vendor_AccountType'
                                                    },                      
            
            'Category__c' => new Map<String, String>{       'Id'            => 'Category_Id',
                                                            'Status'        => 'Category_Status'
                                                    },
                                                    
            'Price_Level__c' => new Map<String, String>{        'Id'        => 'Price_Level_Id',
                                                            'Status'        => 'Price_Level_Status'
                                                    },
                                                    
            'Sales_Tax__c' => new Map<String, String>{      'Id'            => 'Sales_Tax_Id',
                                                            'Status'        => 'Sales_Tax_Status'
                                                },
            'Parts_Needed' => new Map<String, String>{'Part Type'     =>  'Part_Type'},
                                            
            'Sublets' => new Map<String, String> { 'Item'              => 'Product_Item',
                                                    'Description'       => 'Product_Description',
                                                    'Category'          => 'Product_Category' ,
                                                    'Price'             => 'Product_Price',
                                                    'Product Type'      => 'Product_Type',
                                                    'Account Type'      => 'Vendor_AccountType'
                                                },
                                                
            'Invoiced_Items' => new Map<String, String> { 'Item'             => 'InvoicedItem_Item',
                                                        'Customer'          => 'InvoicedItem_Customer',
                                                        'InvoiceDate'       => 'InvoicedItem_InvoiceDate' ,
                                                        'Category'          => 'InvoicedItem_Category',
                                                        'Invoiced By'       => 'InvoicedItem_InvoicedBy',
                                                        'Vendor'            => 'InvoicedItem_Vendor',
                                                        'Quantity'          => 'InvoicedItem_Quantity',
                                                        'Revenue'           => 'InvoicedItem_Revenue',
                                                        'Part Type'         => 'Part_Type'
                                                },
            'Tax_Detail' => new Map<String, String>{'Account Type'		=> 'Customer_AccountType'},
            
            'Unit_Deals' => new Map<String, String>{'Delivery'          		=> 'Unit_Deals_Delivery',
            										'Units'						=> 'Unit_Deals_Units',
            										'Trade Ins'					=> 'Unit_Deals_Trade_Ins',
            										'Lien Payout'				=> 'Unit_Deals_Lien_payout',
            										'Parts And Labour'			=> 'Unit_Deals_Parts_And_Labour',
            										'Deal Products'				=> 'Unit_Deals_Other_Products',
            										'Fees'						=> 'Unit_Deals_Fees',
            										'Stamp Duty'				=> 'Unit_Deals_Stamp_Duty',
            										'Financing Products'		=> 'Unit_Deals_Financing_Products',
            										'Sales Tax'					=> 'Unit_Deals_Sales_Tax',
            										'Order Number'				=> 'Unit_Deals_Order_Number',
            										'Customer'					=> 'Unit_Deals_Customer',
            										'Deal Type'					=> 'Unit_Deals_Deal_Type',
            										'Total'						=> 'Unit_Deals_Total' 
            										}, 
         'Deal_Units' => new Map<String, String>{	'Stock Number' => 'Deal_Units_Stock_Number',
            										'Make' => 'Deal_Units_Make',
													'Model' => 'Deal_Units_Model',
													'Submodel' => 'Deal_Units_Submodel',
													'Year' => 'Deal_Units_Year',
													'Status' => 'Deal_Units_Status',
													'Order Number' => 'Deal_Units_Order_Number',
													'Total Price' => 'Deal_Units_Total_Price',
													'Deal Type' => 'Deal_Units_Deal_Type',
													'Customer' => 'Deal_Units_Deal_Customer',
													'Date Sold' => 'Deal_Units_Date_Sold',
													'Base Price' => 'Deal_Units_Base_Price',
													'Factory Options' => 'Deal_Units_Factory_Options',
													'Dealer Installed' => 'Deal_Units_Dealer_Installed',
													'Part Options' => 'Deal_Units_Part_Options',
													'Labor Options' => 'Deal_Units_Labor_Options',
													'Sublet Options' => 'Deal_Units_Sublet_Options',
													'Fee Options' => 'Deal_Units_Fee_Options',
													'Warranty Options' => 'Deal_Units_Warranty_Options',
													'Other Products' => 'Deal_Units_Other_Products',
													'Stamp Duty' => 'Deal_Units_Stamp_Duty',
													'VIN' => 'Deal_Units_VIN',
													'New Unit' => 'Deal_Units_New_Unit',
													'Category' => 'Deal_Units_Category',
													'Stocked In' => 'Deal_Units_Stocked_In',
													'Age' => 'Deal_Units_Age',
													'Tags' => 'AssignedTags',
													'Mileage' => 'Deal_Units_Mileage',
													'Mileage Type' => 'Deal_Units_Mileage_Type',
													'Ext Color' => 'Deal_Units_Ext_Color',
													'Int Color' => 'Deal_Units_Int_Color',
													'Compliance Date' => 'Deal_Units_Compliance_Date',
                                                    'Year of 1st Rego' => 'Deal_Units_Year_Of_1st_Rego',
                                                    'Registration Serial#' => 'Deal_Units_Registration_Serial',
                                                    'Manufactured Date' => 'Deal_Units_Manufactured_Date'
            										},
           'Parts_Order'  => new Map<String, String>{'Order Number' => 'Parts_Order_Order_Number',
           											 'Customer'	=> 'Parts_Order_Customer',
           											 'Sale Type' => 'Parts_Order_Sale_Type',
           											 'Total' => 'Parts_Order_Total',
           											 'Status' => 'Parts_Order_Status',
           											 'Deposits' => 'Parts_Order_Deposits',
           											 'Invoiced' => 'Parts_Order_Invoiced',
           											 'Modified' => 'Parts_Order_Modified',
           											 'Parts' => 'Parts_Order_Parts',
           											 'Fees' => 'Parts_Order_Fees',
           											 'Sales Tax' => 'Parts_Order_Sales_Tax'
            										}    										
            										
            										           
    };
    
    
    // Map of object name to owner field API Name
    public static Map<String, List<String>> objectToCommonNumericFieldAPIName = 
                        new Map<String, List<String>>{'Parts'               =>  new List<String>{'Retail_Price__c', 'Last_Cost__c'},
                                                        'Kits'              =>  new List<String>{'Fixed_Price__c'},
                                                        'Labor Codes'       =>  new List<String>{'Rate__c'},
                                                        'Fees'              =>  new List<String>{'Price__c'},
                                                        'Sublets'           =>  new List<String>{'Price__c'},
                                                        'Vendor Product'    => new List<String>{'Price__c'},
                                                        'Sales Taxes'       =>  new List<String>(),
                                                        'Price Levels'      =>  new List<String>(),
                                                        'Item Categories'   =>  new List<String>(),
                                                        'Customers'         =>  new List<String>(),
                                                        'Vendors'           =>  new List<String>(),
                                                        'Customer Orders'   =>  new List<String>{'Order_Total__c', 'Total_Balance_Due__c', 'Invoiced_Amount__c', 'Total_Deposit_And_Payment__c', 'Uninvoiced_Amount__c'},
                                                        'Customer Invoices' =>  new List<String>{'Total_Payment__c', 'CO_Header__r.Total_Balance_Due__c'},
                                                        'Service Jobs'  =>  new List<String>{'Total_With_Tax__c'},
                                                        'Customer Payments' =>  new List<String>{'Amount__c'},
                                                        'Customer Deposits' =>  new List<String>{'Amount__c'},
                                                        'Vendor Orders'     =>  new List<String>{'Total__c'},
                                                        'Vendor Return' =>  new List<String>{'Total__c'},
                                                        'Vendor Receivings' =>  new List<String>{'Receiving_Total__c'},
                                                        'Vendor Invoices'   =>  new List<String>(),
                                                        'People'            =>  new List<String>(),
                                                        //Added by Nidhi - #1152 - 19-10-2016
                                                        'Inventory Unit'    =>  new List<String>{'Total_Price__c', 'Total_Cost__c', 'Total_Base_Unit_Price__c', 'Total_Factory_Options_Price__c', 'Total_Dealer_Options_Price__c', 'Total_Base_Units_Cost__c', 'Total_Factory_Options_Cost__c', 'Total_Dealer_Options_Cost__c'},
                                                        'Tax Detail Customer Invoices'  =>  new List<String>{'Sub_Total__c', 'SalesTax_Total__c', 'Total__c', 'Taxable_Total__c', 'Non_Taxable_Total__c'},
                                                        'Tax Detail Vendor Invoices'    =>  new List<String>{'Sub_Total__c', 'Tax_Total__c', 'Total_With_Tax__c', 'Taxable_Total__c', 'Non_Taxable_Total__c'},
                                                        'Unit Deals' =>  new List<String>{'CO_Header__r.Deal_Total__c'},
                                                        'Deal Units' =>  new List<String>{'Total_Price__c'},
                                                        'Parts Order'   =>  new List<String>()
                                                    };
    
    // Map of object name to owner field API Name
    public static Map<String, List<String>> objectToCommonNumericFieldLabelName = 
                        new Map<String, List<String>>{'Parts'               =>  new List<String>{'Price', 'Cost'},
                                                        'Kits'              =>  new List<String>{'Price'},
                                                        'Labor Codes'       =>  new List<String>{'Price'},
                                                        'Fees'              =>  new List<String>{'Price'},
                                                        'Sublets'           =>  new List<String>{'Price'},
                                                        'Vendor Product'    =>  new List<String>{'Price'},
                                                        'Sales Taxes'       =>  new List<String>(),
                                                        'Price Levels'      =>  new List<String>(),
                                                        'Item Categories'   =>  new List<String>(),
                                                        'Customers'         =>  new List<String>(),
                                                        'Vendors'           =>  new List<String>(),
                                                        'Customer Orders'   =>  new List<String>{'Total', 'Balance_Due', 'Invoiced', 'Deposits', 'Uninvoiced'},
                                                        'Service Jobs'  =>  new List<String>{'Total'},
                                                        'Customer Invoices' =>  new List<String>{'Total', 'Balance_Due'},
                                                        'Customer Payments' =>  new List<String>{'Total'},
                                                        'Customer Deposits' =>  new List<String>{'Total'},
                                                        'Vendor Orders'     =>  new List<String>{'Total'},
                                                        'Vendor Return' =>  new List<String>{'Total'},
                                                        'Vendor Receivings' =>  new List<String>{'Total'},
                                                        'Vendor Invoices'   =>  new List<String>(),
                                                        'People'            =>  new List<String>(),
                                                        //Added by Nidhi - #1152 - 19-10-2016
                                                        'Inventory Unit'    =>  new List<String>{'Price', 'Cost', 'Base_Unit_Price', 'Factory_Options', 'Dealer_Options', 'Base_Unit_Cost', 'Factory_Option_Cost', 'Dealer_Option_Cost'},
                                                        'Tax Detail Customer Invoices'  =>  new List<String>{'Sub_Total', 'Tax_Total', 'Invoice_Total', 'Taxable_Total', 'Non_Taxable_Total'},
                                                        'Tax Detail Vendor Invoices'    =>  new List<String>{'Sub_Total', 'Tax_Total', 'Invoice_Total',  'Taxable_Total', 'Non_Taxable_Total'},
                                                        'Unit Deals' =>  new List<String>{'Total'},
                                                        'Deal Units'  =>  new List<String>{'Total_Price'},
                                                        'Parts Order'   =>  new List<String>()
                                                    };
                                                    
    // Map of object name to owner field API Name
    public static Map<String, List<String>> objectToCommonNumericFieldTypeMap = 
                        new Map<String, List<String>>{  'Parts'             =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Kits'              =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Labor Codes'       =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Fees'              =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Sublets'           =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Vendor Product'    =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Sales Taxes'       =>  new List<String>(),
                                                        'Price Levels'      =>  new List<String>(),
                                                        'Item Categories'   =>  new List<String>(),
                                                        'Customers'         =>  new List<String>(),
                                                        'Vendors'           =>  new List<String>(),
                                                        'Customer Orders'   =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Service Jobs'      =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Customer Invoices' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Customer Payments' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Customer Deposits' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Vendor Orders'     =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Vendor Return'     =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Vendor Receivings' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Vendor Invoices'   =>  new List<String>(),
                                                        //Added by Nidhi - #1152 - 19-10-2016
                                                        'Inventory Unit'    => new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Tax Detail Customer Invoices'  =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Tax Detail Vendor Invoices'    =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2, HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Unit Deals' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Deal Units' =>  new List<String>{HomeSearchReportUtil.NUMERIC_TYPE_2},
                                                        'Parts Order'   =>  new List<String>()
                                                        
                                                    };

    //START : Added by nidhi - 10-11-2016
    //Map of object name to Map of field name to field value                                                
    public static Map<String, Map<String, String>> objectNameToMapOfFieldNameToFieldValueMap = 
                        new Map<String, Map<String, String>>{'Customer_Owned_Unit__c'   =>  new Map<String, String>{'Unit_Type__c' => '\'Stock\''},
                                                            'CO_Invoice_Header__c'      =>  new Map<String, String>{'Status__c' => '\'Closed\''} 
                                                    };          
                                                    
                                                    
    public static Map<String, Map<String, String>> groupFieldNameToObjAPINameToFieldAPINameMap =                                                                                                                                    
                        new Map<String, Map<String, String>> {'Products_Price' => new Map<String, String>{'Part__c' => 'Retail_Price__c',
                                                                                                        'Labour_Code__c' => 'Rate__c',
                                                                                                        'Fee__c' => 'Price__c',
                                                                                                        'Product__c' => 'Price__c',
                                                                                                        'Kit_Header__c' => 'Fixed_Price__c',
                                                                                                        'Customer_Owned_Unit__c' => 'Total_Price__c'},
                                                                                                        
                                                                'Products_Description' => new Map<String, String>{'Part__c' => 'Part_Number__c',
                                                                                                        'Labour_Code__c' => 'Description__c',
                                                                                                        'Fee__c' => 'Fee_Unique_Name__c',
                                                                                                        'Product__c' => 'Description__c',
                                                                                                        'Kit_Header__c' => 'Kit_Unique_Name__c'},
                                                                                                        
                                                                'Products_Code' => new Map<String, String>{'Part__c' => 'Part_Number__c',
                                                                                                        'Labour_Code__c' => 'Description__c',
                                                                                                        'Fee__c' => 'Fee_Unique_Name__c',
                                                                                                        'Product__c' => 'Description__c',
                                                                                                        'Kit_Header__c' => 'Kit_Unique_Name__c',
                                                                                                        'Customer_Owned_Unit__c' => 'Stock_Id__c'},                                     
                                                                
                                                                'Products_Cost' => new Map<String, String>{'Part__c' => 'Last_Cost__c',
                                                                                                        'Product__c' => 'Cost__c',
                                                                                                        'Customer_Owned_Unit__c' => 'Total_Cost__c'},
                                                                                                        
                                                                                                        
                                                                'Customer_Sales_Id_Number' => new Map<String, String>{'CO_Header__c' => 'Name',
                                                                                                        'CO_Invoice_Header__c' => 'Invoice_Number__c',
                                                                                                        'CO_Invoice_Payment__c' => 'Name',
                                                                                                        'CO_Deposit__c' => 'Name',
                                                                                                        'Service_Order_Header__c' => 'CO_Header__r.Name'},
                                                                                                        
                                                                'Customer_Sales_Name' => new Map<String, String>{'CO_Header__c' => 'Customer_Name__c',
                                                                                                        'CO_Invoice_Header__c' => 'CO_Header__r.Customer_Name__c',
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Customer_Name__c',
                                                                                                        'Service_Order_Header__c' => 'CO_Header__r.Customer_Name__c'},
                                                                                                        
                                                                'Customer_Sales_Status' => new Map<String, String>{'CO_Header__c' => 'Status__c',
                                                                                                        'CO_Invoice_Header__c' => 'Status__c',
                                                                                                        'Service_Order_Header__c' => 'Work_Status__c'},
                                                                                                        
                                                                'Customer_Sales_Balance_Due' => new Map<String, String>{'CO_Header__c' => 'Total_Balance_Due__c',
                                                                                                        'CO_Invoice_Header__c' => 'CO_Header__r.Total_Balance_Due__c'},
                                                                                                        
                                                                                                                                                
                                                                'Customer_Sales_Total' => new Map<String, String>{'CO_Header__c' => 'Order_Total__c',
                                                                                                        'CO_Invoice_Header__c' => 'Total_Payment__c',
                                                                                                        'CO_Invoice_Payment__c' => 'Amount__c',
                                                                                                        'CO_Deposit__c' => 'Amount__c',
                                                                                                        'Service_Order_Header__c' => 'Total__c'},
                                                                                                        
                                                                'Customer_Sales_Order_Number' => new Map<String, String>{
                                                                                                        'CO_Invoice_Header__c' => 'CO_Header__r.Name',
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Name',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Name'} ,
                                                                
                                                                'Customer_Payments_Customer_Name' => new Map<String, String>{
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Customer_Name__c'} ,   
                                                                
                                                                'Customer_Payments_Order_Number' => new Map<String, String>{
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Name',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Name'} ,
                                                                
                                                                'Customer_Payments_Owner' => new Map<String, String>{
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Owner__r.Name',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Owner__r.Name'} , 
                                                                 'Customer_Payments_Account_Type' => new Map<String, String>{
                                                                                                        'CO_Invoice_Payment__c' => 'CO_Invoice_Header__r.CO_Header__r.Account_Type__r.Name',
                                                                                                        'CO_Deposit__c' => 'CO_Header__r.Account_Type__r.Name'} ,
                                                                                                                                               
                                                                'Vendor_Ordering_ID_Number' => new Map<String, String>{
                                                                                                        'Vendor_Order_Header__c' => 'Name',
                                                                                                        'Return_VO_Header__c' => 'Name',
                                                                                                        'Vendor_Receiving_Header__c' => 'Receipt_Number__c',
                                                                                                        'Vendor_Invoicing_Header__c' => 'Invoice_Number__c'},
                                                                
                                                                'Vendor_Ordering_Total' => new Map<String, String>{
                                                                                                        'Vendor_Order_Header__c' => 'Total__c',
                                                                                                        'Return_VO_Header__c' => 'Total__c'},
                                                                                                        
                                                                
                                                                'Vendor_Ordering_Account_Type' => new Map<String, String>{
                                                                                                        'Vendor_Order_Header__c' => 'Vendor__r.Vendor_Account_Type__r.Name',
                                                                                                        'Return_VO_Header__c' => 'Vendor__r.Vendor_Account_Type__r.Name'}, 
                                                                                                        
                                                                'Tax_Detail_Account_Type' => new Map<String, String>{
                                                                                                        'CO_Invoice_Header__c' => 'CO_Header__r.Account_Type__r.Name',
                                                                                                        'Vendor_Invoicing_Header__c' => 'Vendor__r.Vendor_Account_Type__r.Name '},                                                                                                         
                                                                                                        
                                                                'Setting_Key' => new Map<String, String>{
                                                                                                        'Category__c' => 'Unique_Category__c',
                                                                                                        'Price_Level__c' => 'Name__c',
                                                                                                        'Sales_Tax__c' => 'Name__c'}, 
                                                                                                        
                                                                'Setting_Summary' => new Map<String, String>{
                                                                                                        'Category__c' => 'Description__c',
                                                                                                        'Price_Level__c' => 'Description__c',
                                                                                                        'Sales_Tax__c' => 'Forms_Label__c'}                                                                                                                                                                                                                                                                                                                                                                                                                                                 
                        
                                                            };          
    
    public static Map<String, String> filterLabelToPermissionNameMap = new Map<String, String> {    'Price Levels' => 'Price Levels',
                                                                                    'Sales Taxes' => 'Sales Taxes',
                                                                                    'Service Jobs' => 'Service job',
                                                                                    'Users' => 'System Settings',
                                                                                    'Vendor Invoices' => 'Vendor invoicing',
                                                                                    'Vendor Orders' => 'Vendor order',
                                                                                    'Vendor Receivings' => 'Vendor receiving',
                                                                                    'Customer Orders' => 'Merchandise,Service job,Deal',
                                                                                    'Technician Hours' => 'Manage job clocking',
                                                                                    'Payroll Hours' => 'Manage payroll clocking',
                                                                                    'Part FIFO' => 'Costs',
                                                                                    'Tax Detail' => 'Sales Taxes'
                                                                                };
                                                                                
     public static Map<String, String> entityTypeToPermissionNameMap = new Map<String, String> {
                                                                                    'Part Inventory Valuation' => 'Costs',
                                                                                    'Parts Needed' => 'Vendor order',
                                                                                    'Open Service Jobs' => 'Service job',
                                                                                    'My Vendor Orders' => 'Vendor order',
                                                                                    'All Vendor Orders' => 'Vendor order',
                                                                                    'Active Receivings' => 'Vendor receiving',
                                                                                    'Recent Vendor Invoices' => 'Vendor invoicing',
                                                                                    'Technician Hours' => 'Manage job clocking',
                                                                                    'Payroll Hours' => 'Manage payroll clocking',
                                                                                    'Part Movement' => 'Costs',
                                                                                    'Tax Detail' => 'Sales Taxes'
                                                                                };
    
    public static Map<String, String> objectAPILabelToPermissionNameMap = new Map<String, String> { 'Price_Level__c' => 'Price Levels',
                                                                                    'Sales_Tax__c' => 'Sales Taxes',
                                                                                    'Service_Order_Header__c' => 'Service job',
                                                                                    'User' => 'System Settings',
                                                                                    'Vendor_Invoicing_Header__c' => 'Vendor invoicing',
                                                                                    'Vendor_Order_Header__c' => 'Vendor order',
                                                                                    'Vendor_Receiving_Header__c' => 'Vendor receiving',
                                                                                    'CO_Header__c' => 'Merchandise,Service job,Deal'
                                                                                };
    
    public static Map<String, Set<String>> entityTypeToCostColumnsMap = new Map<String, Set<String>> {  'Invoice Summary' => new Set<String>{'Invoice Profit', 'Deal Profit', 'Commission'},
                                                                                    'Recent Customer Invoices' => new Set<String>{'Invoice Profit', 'Deal Profit', 'Commission'},
                                                                                    'Stock Units' => new Set<String>{'Base Unit Cost', 'Factory Option Cost', 'Dealer Option Cost', 'Total Cost'},
                                                                                    'Recent Parts' => new Set<String>{'Cost', 'Average Cost', 'Package Cost', 'Oversold Cost', 'Total Cost'},
                                                                                    'Parts Needed' => new Set<String>{'Total Cost'},
                                                                                    'Sublets' => new Set<String>{'Cost'},
                                                                                    'Part Inventory Valuation' => new Set<String>{'Cost', 'Average Cost', 'Package Cost', 'Oversold Cost', 'Total Cost'},
                                                                                    'Product History Detail' => new Set<String>{'Profit', 'Average Profit', 'Total Profit'},
                                                                                    'Product History Summary' => new Set<String>{'Profit', 'Average Profit', 'Total Profit'},
                                                                                    'Stock Unit Valuation' => new Set<String>{'Base Unit Cost', 'Factory Option Cost', 'Dealer Option Cost', 'Deal Options WIP', 'Total Cost'}
                                                                                 };
    public static Map<String, Map<String, String>> entityTypeToModifyCostColumnsMap = new Map<String, Map<String, String>> {'Invoice Summary' => new Map<String, String>{'Commission' => 'CO_Invoice_Header_Commission'},
                                                                                                        'Recent Customer Invoices' => new Map<String, String>{'Commission' => 'CO_Invoice_Header_Commission'}
                                                                                 };
    
    public static Map<String, String> objectNameToPermissionNameMap = new Map<String, String> { 'Price Levels' => 'Price Levels',
                                                                                    'Sales Taxes' => 'Sales Taxes',
                                                                                    'Customer Orders' => 'Merchandise,Service job,Deal',
                                                                                    'Users' => 'System Settings',
                                                                                    'Vendor Invoices' => 'Vendor invoicing',
                                                                                    'Vendor Orders' => 'Vendor order',
                                                                                    'Vendor Receivings' => 'Vendor receiving'
                                                                                };
    
    public static Map<String, Set<String>> filterNameToHiddenFieldMap = new Map<String, Set<String>> {'Invoice Summary' => new Set<String>{'Stamp Duty Total'},
                                                                                    'Recent Customer Invoices' => new Set<String>{'Stamp Duty Total'}
                                                                                };
    
    public static Map<String, List<String>> objectNameToNumericFieldApiNameMap = new Map<String, List<String>> {
                                                                                'Vendor Return' => new List<String>{'Total__c'},
                                                                                'Invoiced Item' => new List<String>{'Qty__c'},
                                                                                'SOLI' => new List<String>{'Qty_Needed__c', 'Revenue__c', 'Per_Item_Profit__c'},
                                                                                'SOLI Without Permission' => new List<String>{'Qty_Needed__c', 'Revenue__c'},
                                                                                'Option and Fee' => new List<String>{'Qty__c', 'Revenue__c', 'Per_Item_Profit__c'}
                                                                                }; 
                                                                                
    // Used when there are sorting on multiple objects and Field API names are different - Added by TK
    public static Map<String, Map<String, String>> objectNameToCommonApiToAPINameMap = 
                new Map<String, Map<String, String>> {
                    'Service_Order_Line_Item__c' => new Map<String, String>{'CO_Header__r.Customer_Name__c' => 'Service_Order_Header__r.CO_Header__r.Customer_Name__c',
                                                                            'Invoice_Number__r.Invoice_Number__c' => 'Service_Order_Header__r.Invoice_Number__r.Invoice_Number__c',
                                                                            'Price__c' => 'Kit_Price__c'},
                    'Option_Fee__c'              => new Map<String, String>{'CO_Header__r.Customer_Name__c' => 'Deal__r.CO_Header__r.Customer_Name__c',
                                                                            'Invoice_Number__r.Invoice_Number__c' => 'Deal__r.Invoice_Number__r.Invoice_Number__c'}
                };  
    
    public static Map<String, Map<String, String>> searchNameToChildQueryObjNameToFieldToFilterNameMap = new Map<String, Map<String, String>> {
                                                                                'Technician Performance' => new Map<String, String>{'Hours_Logged__r'=> 'Start_Date__c',
                                                                                                                                    'Payroll_Times__r'=> 'Start_Date__c'},
                                                                                 'Part FIFO' => new Map<String,String>{'Part_FIFO_Bucket_Activity_Line_Items__r'=> 'CreatedDate'}
                                                                                };
                                                                                
    public static Set<String> ObjectToExcludeFromRecentSearchSet = new Set<String> {'Technician Performance','Technician Hours','Payroll Hours'};
                                                                                
    public static Map<String, Set<String>> searchNameToFieldToFilterNameMap = new Map<String, Set<String>> {
                                                                                'Technician Performance' => new Set<String>{'Start_Date__c'}
                                                                                };                                                                            
    public static Map<String, Map<String, String>> childObjNameToFilterFieldNameToAPIName = new Map<String, Map<String, String>> {
                                                                                'Hours_Logged__r' => new Map<String, String>{'Start_Date__c'=> 'Start_Date_Time__c'}
                                                                                };                                                                            
    
    public static Set<String> objectWithNoPaginationSet = 
            new Set<String>{'Technician__c', 'Part_FIFO_Bucket__c', 'Part_FIFO_Bucket_Activity_Line_Item__c'};
                                                                                    
    public static String implementNameSpace(String objName){
        String objNameWithNameSpace;
        if(objName.indexOf(Constants.NAMESPACE) == -1 && objName.indexOf('__c') != -1) {
            objName = Constants.NAMESPACE + objName;
        }
        return objName;
    }                                                                                                                                                                                
     
    // Map used in Inventory Aging Home Search for Parts records
    public static Map<String, String> agingPeriodsToPeriodValueMap = new Map<String, String> 
                                               {'PRD1' => Part_Aging_Period__c.getOrgDefaults().Period_1__c + 'day-',
                                               'PRD2' => Part_Aging_Period__c.getOrgDefaults().Period_2__c + 'day-',
                                               'PRD3' => Part_Aging_Period__c.getOrgDefaults().Period_3__c + 'day-',
                                               'PRD4' => '>' + Part_Aging_Period__c.getOrgDefaults().Period_3__c + 'day-'
                                               };                                                                                                                                                                               
}
