public class UserGroupWrapper {
    
    public Map<String, Map<String, Permission>> UserGroupPermissions;
    public UserPermissionGroup UserPermissionGroupDetails;
    //public Map<String, GroupPermission> GroupOnlyPermissions;
    
    public Map<String, Map<String, Boolean>> GroupOnlyPermissions;
    public UserGroupWrapper(User_Group__c userGroup) {
        UserGroupPermissions = new Map<String, Map<String, Permission>>();
        if(userGroup != null) {
            for(String categoryName : Constants.userPermissionCategoryNameList) {
                UserGroupPermissions.put(categoryName, getPermissionCategoriesMap(categoryName, userGroup));
            }
            UserPermissionGroupDetails = new UserPermissionGroup(userGroup);
        }
    }
    
    /**public UserGroupWrapper(User_Group__c userGroupRec, Boolean onlyPermissionNeeded) {
        GroupOnlyPermissions = new Map<String, GroupPermission>();
        if(userGroupRec != null) {
            for(String categoryNameStr : Constants.categoryNameToPermissionTypeListMap.keySet()) {
                for(String permissionTypeStr : Constants.categoryNameToPermissionTypeListMap.get(categoryNameStr)) {
                    String fieldValue = (userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr)) != null) ? 
                                            String.valueOf(userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr))) : '';
                    GroupOnlyPermissions.put(permissionTypeStr, new GroupPermission(fieldValue, 
                                                                    Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[0],
                                                                    Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[1]));
                } 
            }
        }
    }*/
    
    
    public UserGroupWrapper(User_Group__c userGroupRec, Boolean onlyPermissionNeeded) {
        GroupOnlyPermissions = new Map<String, Map<String, Boolean>>();
        if(userGroupRec != null) {
            for(String categoryNameStr : Constants.categoryNameToPermissionTypeListMap.keySet()) {
                for(String permissionTypeStr : Constants.categoryNameToPermissionTypeListMap.get(categoryNameStr)) {
                    
                    Map<String, Boolean> permissionLabelToValueMap = new Map<String, Boolean>();
                    
                    String fieldValue = (userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr)) != null) ? 
                                            String.valueOf(userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr))) : '';
                    
                    String PrimaryLabel = Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[0];
                    String SecondaryLabel = Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[1];
                    
                    if(fieldValue == 'Primary') {
                        permissionLabelToValueMap.put(PrimaryLabel, true);
                        if(String.isNotBlank(SecondaryLabel)){
                            permissionLabelToValueMap.put(SecondaryLabel, false);
                        }
                    }else if(fieldValue == 'Secondary'){
                        permissionLabelToValueMap.put(PrimaryLabel, true);
                        permissionLabelToValueMap.put(SecondaryLabel, true);
                    }else   {
                        if(String.isNotBlank(PrimaryLabel)){
                            permissionLabelToValueMap.put(PrimaryLabel, false);
                        }
                        
                        if(String.isNotBlank(SecondaryLabel)){
                            permissionLabelToValueMap.put(SecondaryLabel, false);
                        }
                    }
                    GroupOnlyPermissions.put(permissionTypeStr, permissionLabelToValueMap);
                }
            }
        }
    }
    
    /*private Map<String, GroupPermission> getPermissionOnlyMap(String categoryName, User_Group__c userGroupRec) {
        Map<String, GroupPermission> PermissionMap = new Map<String, GroupPermission>();
        List<String> permissionTypeList = Constants.categoryNameToPermissionTypeListMap.get(categoryName);
        for(String permissionTypeStr : permissionTypeList) {
            String fieldValue = (userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr)) != null) ? 
                                    String.valueOf(userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr))) : '';
            PermissionMap.put(permissionTypeStr, new GroupPermission(fieldValue, 
                                                                Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[0],
                                                                Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[1]));
        }
        
        
        return PermissionMap;
    }*/
    
    public Map<String,Permission> getPermissionCategoriesMap(String catName, User_Group__c userGroupRec) {
        Map<String,Permission> PermissionMap = new Map<String,Permission>();
        List<String> permissionTypeList = Constants.categoryNameToPermissionTypeListMap.get(catName);
        for(String permissionTypeStr : permissionTypeList) {
            String fieldValue = (userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr)) != null) ? 
                                    String.valueOf(userGroupRec.get(Constants.permissionTypeToFieldAPINameMap.get(permissionTypeStr))) : '';
            PermissionMap.put(permissionTypeStr, new Permission(fieldValue, 
                                                                Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[0],
                                                                Constants.permissionTypeToLabelListMap.get(permissionTypeStr)[1]));
        }
        return PermissionMap;
        
          /*  if(catName == 'General Permissions') { 
                PermissionMap.put('System Settings',new Permission(userGroup.System_Settings__c,'enabled',''));
                PermissionMap.put('Sales Taxes',new Permission(userGroup.Sales_Taxes__c,'assign','create/modify'));
                PermissionMap.put('Price file import',new Permission(userGroup.Price_file_import__c,'enabled',''));
                PermissionMap.put('Accounting settings export',new Permission(userGroup.Accounting_settings_export__c,'enabled',''));
                PermissionMap.put('Price Levels',new Permission(userGroup.Price_Levels__c,'assign','create/modify'));
                PermissionMap.put('Costs',new Permission(userGroup.Costs__c,'read only','modify'));
                
            } else if(catName == 'Transaction Permissions') {
                PermissionMap.put('Quick sale',new Permission(userGroup.quick_sale__c,'enabled',''));
                PermissionMap.put('Merchandise',new Permission(userGroup.Merchandise__c,'view','create/modify'));
                PermissionMap.put('Service job',new Permission(userGroup.Service_job__c,'view','create/modify'));
                PermissionMap.put('Deal',new Permission(userGroup.Deal__c,'view','create/modify'));
                PermissionMap.put('Customer invoicing',new Permission(userGroup.Customer_invoicing__c,'view','create/modify'));
                PermissionMap.put('Internal Service',new Permission(userGroup.Internal_Service__c,'view','create/modify'));
                PermissionMap.put('Vendor order',new Permission(userGroup.Vendor_order__c,'view','create/modify'));
                PermissionMap.put('Vendor receiving',new Permission(userGroup.Vendor_receiving__c,'view','create/modify'));
                PermissionMap.put('Vendor invoicing',new Permission(userGroup.Vendor_invoicing__c,'view','create/modify'));
               
            } else if(catName == 'Special Actions') {
                PermissionMap.put('Override price',new Permission(userGroup.Override_price__c,'enabled',''));
                PermissionMap.put('Oversell inventory',new Permission(userGroup.Oversell_inventory__c,'enabled',''));
                PermissionMap.put('Special order',new Permission(userGroup.Special_order__c,'enabled',''));
                PermissionMap.put('Returns',new Permission(userGroup.Returns__c,'enabled',''));
            
            } else if(catName == 'Records') {
                PermissionMap.put('Customers',new Permission(userGroup.customers__c,'enabled',''));
                PermissionMap.put('Vendors',new Permission(userGroup.vendors__c,'enabled',''));
                PermissionMap.put('Vendor products',new Permission(userGroup.vendor_products__c,'enabled',''));
                PermissionMap.put('Parts',new Permission(userGroup.parts__c,'enabled',''));
                PermissionMap.put('Labor',new Permission(userGroup.labor__c,'enabled',''));
                PermissionMap.put('Stock units',new Permission(userGroup.stock_units__c,'enabled',''));
                PermissionMap.put('Fees',new Permission(userGroup.fees__c,'enabled',''));
                PermissionMap.put('Kits',new Permission(userGroup.kits__c,'enabled',''));
            }
            
            //System.assert(false, PermissionMap);
        */
    }
    
    
    public class GroupPermission {
        public String PrimaryLabel {get;set;}
        public String SecondaryLabel {get;set;} 
        public String AccessType {get;set;}
        public GroupPermission(String accessTypeStr, String primaryLabelStr, String secondaryLabelStr) {
            this.AccessType = accessTypeStr;
            this.PrimaryLabel = primaryLabelStr;
            this.SecondaryLabel = secondaryLabelStr;
        }
    }
    
    public class Permission {
        public Boolean Primary{get;set;}
        public Boolean Secondary{get;set;}
        public String PrimaryLabel{get;set;}
        public String SecondaryLabel{get;set;}
        
        public Permission(String Value,String primarylabel,String secondarylabel){
            if(Value == 'None') {
                this.primary = false;
                this.secondary = false;
            } else if(Value == 'Primary') {
                this.Primary = true;
                this.Secondary = false;
            } else if(Value == 'Secondary') {
                this.Primary = true;
                this.Secondary = true;
            }
            this.PrimaryLabel= primarylabel;
            this.SecondaryLabel = secondarylabel;
        }
    }
    
    public class UserPermissionGroup{
          public String UserGroupName;
          public string GroupOwner;
          public string OwnerId;
          public String GroupCreatedBy;
          public String UserGroupId;
          public String ColorCode;
          public DateTime CreatedDate;
          public boolean  IsSystemCreated;
          public String CopyGroupId;
          public DateTime LastModifiedDate;
          public Decimal NoOfUser;
          
          public UserPermissionGroup(User_Group__c userPermission){
            this.UserGroupName = userPermission.Name;
            this.OwnerId = userPermission.OwnerId;
            this.GroupOwner = userPermission.Owner.Name;
            this.GroupCreatedBy = userPermission.Is_System_Created__c ? 'Created automatically' : (UserInfo.getUserId() == userPermission.CreatedById ? 'Created by you' : 'Created by '+ userPermission.CreatedBy.Name) ;
            this.UserGroupId = userPermission.id;
            this.ColorCode = userPermission.Colour_Code__c;
            this.CreatedDate = userPermission.Createddate;
            this.IsSystemCreated = userPermission.Is_System_Created__c;
            this.LastModifiedDate = userPermission.LastModifiedDate;
            this.NoOfUser = userPermission.User_To_Groups1__r.size();
          }
    }
    
    public class UserGroupJunctionWrapper{
        public String UserId;
        public String GroupId;
        public String UserGroupName;
        public String UserFirstName;
        public String UserLastName;
        public String Name;
        public String UserRole;
        
        public UserGroupJunctionWrapper(User_To_Group__c userGroupJunctionRec){
            this.UserId  = userGroupJunctionRec.User__c;
            this.GroupId = userGroupJunctionRec.User_Group__c;
            this.UserGroupName = userGroupJunctionRec.User_Group__r!= null ? userGroupJunctionRec.User_Group__r.Name : '';
            this.UserFirstName = userGroupJunctionRec.User__r != null ? userGroupJunctionRec.User__r.FirstName : '';
            this.UserLastName = userGroupJunctionRec.User__r != null ? userGroupJunctionRec.User__r.LastName : '';
            this.Name = userGroupJunctionRec.User__r != null ? userGroupJunctionRec.User__r.Name : '';
            this.UserRole = 'Role';
        }
        
        public UserGroupJunctionWrapper(User userObj){
            this.UserId  = userObj.Id;
            this.UserFirstName = userObj.FirstName;
            this.UserLastName = userObj.LastName;
            if(userObj.User_To_Groups1__r.size() > 0){
                this.GroupId = userObj.User_To_Groups1__r[0].Id;
                this.UserGroupName = userObj.User_To_Groups1__r[0].User_Group__r.Name;
            }
            this.Name = userObj.Name;
            this.UserRole = 'Role';
        }
        
        
    }
    
    public static list<String> userFieldList(){
          List<String> userFields = new List<String>{ 'Id',
                                                        'FirstName',
                                                        'LastName',
                                                        'Name'
                                                    };
         return userFields;
    }
    
    
   public static list<String> userGroupJunctionFieldList(){
          List<String> usergroupJunctionFields = new List<String>{ 'Id',
                                                            'User__c',
                                                            'User_Group__c',
                                                            'User_Group__r.Name',
                                                            'User__r.Name',
                                                            'CreatedDate',
                                                            'Owner.Name',
                                                            'OwnerId',
                                                            'LastModifiedDate',
                                                            'User__r.FirstName',
                                                            'User__r.LastName'
            
                                                            };
         return usergroupJunctionFields;
    }
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> usergroupFields = new List<String>{    'id',
                                                            'Name',
                                                            'Colour_Code__c',
                                                            'OwnerId',
                                                            'Owner.Name',
                                                            'CreatedDate',
                                                            'CreatedById',
                                                            'CreatedBy.Name',
                                                            'System_Settings__c',
                                                            'Sales_Taxes__c',
                                                            'Price_file_import__c',
                                                            'Accounting_settings_export__c',
                                                            'Price_Levels__c',
                                                            'Costs__c',
                                                            'Set_cash_drawer__c',
                                                            'quick_sale__c',
                                                            'Merchandise__c',
                                                            'Service_job__c',
                                                            'Deal__c',
                                                            'Customer_invoicing__c',
                                                            'Internal_Service__c',
                                                            'Vendor_order__c',
                                                            'Vendor_receiving__c',
                                                            'Vendor_invoicing__c',
                                                            'Override_price__c',
                                                            'Oversell_inventory__c',
                                                            'Special_order__c',
                                                            'Returns__c',
                                                            'customers__c',
                                                            'vendors__c',
                                                            'vendor_products__c',
                                                            'parts__c',
                                                            'labor__c',
                                                            'stock_units__c' ,
                                                            'fees__c',
                                                            'kits__c',
                                                            'Is_System_Created__c',
                                                            'LastModifiedDate',
                                                            'Cash_reconciliation__c ',
                                                            'Manage_job_clocking__c',
                                                            'Manage_payroll_clocking__c',
                                                            'Unit_ordering__c',
                                                            'Backdating__c'
                                                        };
        return usergroupFields;
    }
    
    public class UserGroupPermissionList{
        public UserPermissionGroup UserPermissionGroupDetails;
        public List<Map<String,Permission>> userGroupPermissions;
        
        
    }
    
   
}