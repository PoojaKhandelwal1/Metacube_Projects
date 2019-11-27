define(['Routing_AppJs_PK', 'ViewCustomerServices', 'DirPagination', 'mapsApiJs', 'tel', 'COUInfoPopUpCtrl', 'dirNumberInput'], function(Routing_AppJs_PK, ViewCustomerServices, DirPagination, mapsApiJs, tel, COUInfoPopUpCtrl, dirNumberInput) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ViewCustomerCtrl', ['$q', '$scope', '$rootScope', '$timeout', '$stateParams', '$state', 'CustomerOrdersService', 'CustomerInfoService1', 'RelatedCustomersService', 'CustomerOwnedUnitsService', 'CustomerActiveOrdersService', 'CustomerContactsService', 'StoreCreditService','$translate',
        function($q, $scope, $rootScope, $timeout, $stateParams, $state, CustomerOrdersService, CustomerInfoService1, RelatedCustomersService, CustomerOwnedUnitsService, CustomerActiveOrdersService, CustomerContactsService, StoreCreditService, $translate) {
            var Notification = injector1.get("Notification");
            $scope.showLoading = true;
            $scope.ViewCustomer = {};
            $scope.ViewCustomer.CustomerInfo = {};
            $scope.SearchToadd = {};
            $scope.CustomerModal = {};
            $scope.COUModal = {};
            $scope.ViewCustomer.ShowMore = true;
            $scope.ViewCustomer.ShowContent = false;
            $scope.ViewCustomer.customerId = $stateParams.Id;
            $scope.ViewCustomer.showAllData = 1;
            $scope.ViewCustomer.activeAddress = "BillingAddress"
            $scope.ViewCustomer.addressOnMap = "";
            $scope.ViewCustomer.DateFormat = $Global.ExtendedDateFormat;
            var sortOrderMap = {
                "ASC": "DESC",
                "DESC": ""
            };
            $scope.ViewCustomer.COUPageSortAttrsJSON = {};
            $scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON = {};
            $scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON = {};
            $scope.ViewCustomer.customersPageSortAttrsJSON = {};
            $scope.ViewCustomer.contactsPageSortAttrsJSON = {};
            $scope.ViewCustomer.OriginAddress = '';
            $scope.ViewCustomer.setDefaultPageSortAttrs = function() {
                $scope.ViewCustomer.COUPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "ItemDesc",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.COUPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Name",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Name",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.StoreCreditPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Name",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.StoreCreditPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.SMSMessagePageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Name",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.SMSMessagePageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.customersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.customersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.contactsPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.contactsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
                $scope.ViewCustomer.TaxExemptionPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "ItemDesc",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.ViewCustomer.TaxExemptionPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
            }
            $scope.ViewCustomer.changeActiveAddress = function(address) {
                $scope.ViewCustomer.activeAddress = address;
                if (address == "BillingAddress") {
                    $scope.ViewCustomer.addressOnMap = $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingStreet2 + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingStreet1 + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingCity + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingState + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingCountry + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingPostalCode;
                } else {
                    $scope.ViewCustomer.addressOnMap = $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingStreet2 + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingStreet1 + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingCity + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingState + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingCountry + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.ShippingPostalCode;
                }
            }
            $scope.ViewCustomer.helpText = {
                Info: $translate.instant('Basic_information'),
                Statistics: $translate.instant('All_statistics'),
                Vital_Statistics: $translate.instant('Vital_statistics'),
                Telemetry: $translate.instant('Tooltip_View_Vendor_Telemetry'),
                Related: $translate.instant('Related_records'),
                COU: $translate.instant('Customer_Owned_Units'),
                Customers: $translate.instant('Tooltip_View_Vendor_Customers'),
                Contacts: $translate.instant('Tooltip_View_Vendor_Contacts'),
                StoreCreditsSummary: $translate.instant('Store_credit_summary'),
                StoreCreditsActivity: $translate.instant('Store_credit_activities')
            };
            $scope.ViewCustomer.infoLabel = {
                OtherEmail: 'Other Email',
                OtherPhone: 'Other Phone',
                MobileNumberSMS: 'SMS Other',
                HomeEmail: 'HOME EMAIL',
                HomeNumber: 'Home Number',
                HomeNumberSMS: 'SMS Home',
                WorkEmail: 'Work Email',
                WorkNumber: 'Work Number',
                WorkNumberSMS: 'SMS Work'
            };
            $scope.ViewCustomer.displaySections = {
                'Info': true,
                'Statistics': true,
                'Related': true,
                'ActivityStream': true,
                'StoreCredits': true
            };
            $scope.ViewCustomer.loadCustomerInfo = function() {
                var customerId = $scope.ViewCustomer.customerId;
                $scope.ViewCustomer.setDefaultPageSortAttrs();
                var customerInfo = {};
                customerInfo.customerId = customerId;
                customerInfo.COUPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.COUPageSortAttrsJSON);
                customerInfo.ActiveOrdersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON);
                customerInfo.customersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.customersPageSortAttrsJSON);
                customerInfo.contactsPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.contactsPageSortAttrsJSON);
                customerInfo.AllCustomerOrdersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON);
                customerInfo.StoreCreditPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.StoreCreditPageSortAttrsJSON);
                customerInfo.SMSMessagePageSortAttrsJSON = angular.toJson($scope.ViewCustomer.SMSMessagePageSortAttrsJSON);
                customerInfo = JSON.stringify(customerInfo);
                CustomerInfoService1.getCustomerDetails(customerInfo).then(function(customerInfo) {
                    $scope.ViewCustomer.ShowContent = true;
                    if (customerInfo != {} && customerInfo.CustomerInfo != null) {
                        $scope.ViewCustomer.CustomerInfo = customerInfo;
                        $scope.COUModal.ApplicableTaxList = $scope.ViewCustomer.CustomerInfo.ApplicableTaxList;
                        $scope.setAllData(customerInfo);
                        $scope.ViewCustomer.changeActiveAddress('BillingAddress');
                        $scope.ViewCustomer.isrefresh = false;
                    } else {
                        $scope.ViewCustomer.showAllData = 0;
                        $scope.ViewCustomer.isrefresh = false;
                    }
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    $scope.ViewCustomer.ShowContent = false;
                    $scope.ViewCustomer.showAllData = 0;
                    $scope.ViewCustomer.isrefresh = false;
                });
            }
            $scope.ViewCustomer.refreshViewCustomer = function() {
                $scope.ViewCustomer.isrefresh = true;
                $scope.ViewCustomer.loadCustomerInfo();
            }
            $scope.ViewCustomer.saveCustomer = function(result) {
                if (result.Id.length == 18) {
                    result.Id = result.Id.substring(0, 15);
                }
                if ($scope.ViewCustomer.customerId.length == 18) {
                    $scope.ViewCustomer.customerId = $scope.ViewCustomer.customerId.substring(0, 15);
                }
                if ($scope.ViewCustomer.customerId == result.Id) {
                    var customerId = $scope.ViewCustomer.customerId;
                    var customerInfo = {};
                    customerInfo.customerId = customerId;
                    customerInfo.COUPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.COUPageSortAttrsJSON);
                    customerInfo.ActiveOrdersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON);
                    customerInfo.customersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.customersPageSortAttrsJSON);
                    customerInfo.contactsPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.contactsPageSortAttrsJSON);
                    customerInfo.AllCustomerOrdersPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON);
                    customerInfo.StoreCreditPageSortAttrsJSON = angular.toJson($scope.ViewCustomer.StoreCreditPageSortAttrsJSON);
                    customerInfo.SMSMessagePageSortAttrsJSON = angular.toJson($scope.ViewCustomer.SMSMessagePageSortAttrsJSON);
                    customerInfo = JSON.stringify(customerInfo);
                    CustomerInfoService1.getCustomerDetails(customerInfo).then(function(customerInfo) {
                        $scope.ViewCustomer.CustomerInfo = customerInfo;
                        $scope.ViewCustomer.changeActiveAddress('BillingAddress');
                    });
                } else {
                    $scope.ViewCustomer.addUpdateCustomerRecord(result.Id, "Family");
                }
            }
            $scope.ViewCustomer.showMoreDetails = function(status) {
                $scope.ViewCustomer.ShowMore = status;
            }
            $scope.setAllData = function(customerInfo) {
                $scope.ViewCustomer.User = {
                    Name: $Global.UserFirstName + $Global.UserLastName,
                    Value: ''
                }
                $scope.ViewCustomer.CMOwnedUnits = [];
                $scope.ViewCustomer.TotalCOURecords = customerInfo.TotalCOURecords;
                $scope.ViewCustomer.UpdateOwnedUnitsLists(customerInfo.CustomerOwnedUnitList);
                $scope.ViewCustomer.OriginAddress = customerInfo.CompanyName.Address;
                $scope.ViewCustomer.ActiveOrders = [];
                $scope.ViewCustomer.TotalActiveOrderRecords = customerInfo.TotalActiveSalesOrderRecords;
                $scope.ViewCustomer.UpdateActiveOrdersLists(customerInfo.ActiveSalesOrderList);
                $scope.ViewCustomer.CustomerOrders = [];
                $scope.ViewCustomer.TotalCustomerOrderRecords = customerInfo.TotalCustomerOrderRecords;
                $scope.ViewCustomer.UpdateCustomerOrdersLists(customerInfo.AllCustomerOrderList);
                $scope.ViewCustomer.StoreCredits = [];
                $scope.ViewCustomer.TotalStoreCreditRecords = customerInfo.TotalStoreCreditRecords;
                $scope.ViewCustomer.UpdateStoreCreditsLists(customerInfo.StoreCreditList);
                $scope.ViewCustomer.CMCustomers = [];
                $scope.ViewCustomer.TotalCustomerRecords = customerInfo.TotalCustomerRecords;
                $scope.ViewCustomer.UpdateRelatedCustomersLists(customerInfo.RelatedCustomerList);
                $scope.ViewCustomer.CMContacts = [];
                $scope.ViewCustomer.TotalContactRecords = customerInfo.TotalContactRecords;
                $scope.ViewCustomer.UpdateCustomerContactsLists(customerInfo.ContactList);
                $scope.ViewCustomer.TaxExemptions = [];
                $scope.ViewCustomer.TotalTaxExemptionRecords = customerInfo.TotalTaxExemptionRecords;
                $scope.ViewCustomer.TotalMessageRecords = customerInfo.TotalMessageRecords;
                $scope.ViewCustomer.SMSMessageList = customerInfo.SMSMessageList;
                $scope.ViewCustomer.UpdateTaxExemptionsLists(customerInfo.TaxExemptionList);
            }
            $scope.ViewCustomer.setPrefferedEmail = function() {
                if (angular.isDefined($scope.ViewCustomer.CustomerInfo.CustomerInfo)) {
                    if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail != "") {
                        return $scope.ViewCustomer.CustomerInfo.CustomerInfo[$scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail];
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Individual" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail == "" || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail == null)) {
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeEmail != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeEmail !== "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeEmail : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherEmail != null) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherEmail : "";
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Business" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail == "" || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredEmail != null)) {
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkEmail != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkEmail !== "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkEmail : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherEmail != null) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherEmail : "";
                    }
                }
            }
            $scope.ViewCustomer.setPrefferedPhone = function() {
                if (angular.isDefined($scope.ViewCustomer.CustomerInfo.CustomerInfo)) {
                    if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone != "") {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhoneLabel = $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone;
                        return $scope.ViewCustomer.CustomerInfo.CustomerInfo[$scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedPreferredPhone];
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Individual" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone == null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone == "")) {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhoneLabel = ($scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumber != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumber != "") ? 'FormattedHomeNumber' : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone != null) ? 'FormattedOtherPhone' : "FormattedHomeNumber";
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumber != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumber != "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedHomeNumber : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone != null) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone : "";
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Business" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone == null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone == "")) {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhoneLabel = ($scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumber != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumber != "") ? 'FormattedWorkNumber' : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone != null) ? 'FormattedOtherPhone' : "FormattedWorkNumber";
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumber != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumber != "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedWorkNumber : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone != null) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedOtherPhone : "";
                    }
                } else {
                    return '';
                }
            }
            $scope.ViewCustomer.setPrefferedSMS = function() {
                if (angular.isDefined($scope.ViewCustomer.CustomerInfo.CustomerInfo)) {
                    if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS != null && $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS != "") {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMSLabel = $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS;
                        return $scope.ViewCustomer.CustomerInfo.CustomerInfo[$scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedPreferredSMS];
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Individual" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS == null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS == "")) {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMSLabel = ($scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumberSMS != false) ? 'HomeNumberSMS' : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.MobileNumberSMS != false) ? "MobileNumberSMS" : "HomeNumberSMS";
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumberSMS != false) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedHomeNumber : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.MobileNumberSMS != false) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedOtherPhone : "";
                    } else if ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == "Business" && ($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS == null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS == "")) {
                        $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMSLabel = ($scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumberSMS != false) ? 'WorkNumberSMS' : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.MobileNumberSMS != false) ? "MobileNumberSMS" : "WorkNumberSMS";
                        return ($scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumberSMS != false) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedWorkNumber : ($scope.ViewCustomer.CustomerInfo.CustomerInfo.MobileNumberSMS != false) ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedOtherPhone : "";
                    }
                }
            }
            $scope.ViewCustomer.UpdateOwnedUnitsLists = function(CustomerOwnedUnitList) {
                $scope.ViewCustomer.CMOwnedUnits = CustomerOwnedUnitList;
                $scope.ViewCustomer.CMOwnedUnits_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.CMOwnedUnits.length; i++) {
                    $scope.ViewCustomer.CMOwnedUnits_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.UpdateActiveOrdersLists = function(ActiveSalesOrderList) {
                $scope.ViewCustomer.ActiveOrders = ActiveSalesOrderList;
                $scope.ViewCustomer.ActiveOrders_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.ActiveOrders.length; i++) {
                    $scope.ViewCustomer.ActiveOrders_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.UpdateRelatedCustomersLists = function(RelatedCustomersList) {
                $scope.ViewCustomer.CMCustomers = RelatedCustomersList;
                $scope.ViewCustomer.CMCustomers_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.CMCustomers.length; i++) {
                    $scope.ViewCustomer.CMCustomers_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.UpdateCustomerContactsLists = function(ContactList) {
                $scope.ViewCustomer.CMContacts = ContactList;
                $scope.ViewCustomer.CMContacts_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.CMContacts.length; i++) {
                    $scope.ViewCustomer.CMContacts_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.UpdateTaxExemptionsLists = function(TaxExemptionList) {
                $scope.ViewCustomer.TaxExemptions = TaxExemptionList;
                $scope.ViewCustomer.TaxExemptions_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.TaxExemptions.length; i++) {
                    $scope.ViewCustomer.TaxExemptions_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.closeEditCustomerOwnedUnitRows = function(event) {
                $scope.ViewCustomer.UpdateOwnedUnitsLists($scope.ViewCustomer.CMOwnedUnits);
            }
            $scope.ViewCustomer.closeEditCustomerActiveOrderRows = function(event) {
                $scope.ViewCustomer.UpdateActiveOrdersLists($scope.ViewCustomer.ActiveOrders);
            }
            $scope.ViewCustomer.closeEditCustomerRows = function(event) {
                $scope.ViewCustomer.UpdateRelatedCustomersLists($scope.ViewCustomer.CMCustomers);
            }
            $scope.ViewCustomer.closeEditContactRows = function(event) {
                $scope.ViewCustomer.UpdateCustomerContactsLists($scope.ViewCustomer.CMContacts);
            }
            $scope.ViewCustomer.allowHidingActionPanel = true;
            $scope.ViewCustomer.hideAllCOUActionPanel = function(event) {
                if ($scope.ViewCustomer.allowHidingActionPanel) {
                    for (i = 0; i < $scope.ViewCustomer.CMOwnedUnits_editRow.length; i++) {
                        $scope.ViewCustomer.CMOwnedUnits_editRow[i].isEdit = false;
                    }
                }
                $scope.ViewCustomer.allowHidingActionPanel = true;
            }
            $scope.ViewCustomer.editOwnedUnit = function(event, index) {
                if ($rootScope.GroupOnlyPermissions['Customers'].enabled) {
                    $scope.ViewCustomer.CMOwnedUnits_editRow[index].radioValue = 1;
                    var isEditModeEnabled = false;
                    var durtyCustomerOwnedUnits = [];
                    for (i = 0; i < $scope.ViewCustomer.CMOwnedUnits_editRow.length; i++) {
                        if ($scope.ViewCustomer.CMOwnedUnits_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                            durtyCustomerOwnedUnits.push(JSON.stringify($scope.ViewCustomer.CMOwnedUnits[i]));
                        }
                        $scope.ViewCustomer.CMOwnedUnits_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.ViewCustomer.CMOwnedUnits_editRow[index].isEdit = true;
                        setTimeout(function() {
                            angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                            angular.element(event.target).closest('tr').next().find('input').filter(':first').prop('checked', true);
                        }, 10);
                    }
                } else {
                    $scope.ViewCustomer.CMOwnedUnits_editRow[index].isEdit = false;
                }
            }
            $scope.ViewCustomer.editActiveOrder = function(event, index) {
                $scope.ViewCustomer.ActiveOrders_editRow[index].radioValue = 0;
                var isEditModeEnabled = false;
                var durtyCustomerActiveOrders = [];
                for (i = 0; i < $scope.ViewCustomer.ActiveOrders_editRow.length; i++) {
                    if ($scope.ViewCustomer.ActiveOrders_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        durtyCustomerActiveOrders.push(JSON.stringify($scope.ViewCustomer.ActiveOrders[i]));
                    }
                    $scope.ViewCustomer.ActiveOrders_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.ViewCustomer.ActiveOrders_editRow[index].isEdit = true;
                    setTimeout(function() {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                }
            }
            $scope.ViewCustomer.isActiveOrdersAndOrderHistoryBlockAccessible = function() {
                if ($rootScope.GroupOnlyPermissions['Merchandise'].view || $rootScope.GroupOnlyPermissions['Service job'].view || $rootScope.GroupOnlyPermissions['Deal'].view) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.ViewCustomer.editRelatedCustomer = function(event, index) {
                if ($rootScope.GroupOnlyPermissions['Customers'].enabled) {
                    $scope.ViewCustomer.CMCustomers_editRow[index].radioValue = 0;
                    var isEditModeEnabled = false;
                    var durtyCustomers = [];
                    for (i = 0; i < $scope.ViewCustomer.CMCustomers_editRow.length; i++) {
                        if ($scope.ViewCustomer.CMCustomers_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                            durtyCustomers.push(JSON.stringify($scope.ViewCustomer.CMCustomers[i]));
                        }
                        $scope.ViewCustomer.CMCustomers_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.ViewCustomer.CMCustomers_editRow[index].isEdit = true;
                        setTimeout(function() {
                            angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                        }, 10);
                    }
                } else {
                    $scope.ViewCustomer.CMCustomers_editRow[index].isEdit = false;
                }
            }
            $scope.ViewCustomer.editRelatedContact = function(event, index) {
                $scope.ViewCustomer.CMContacts_editRow[index].radioValue = 0;
                var isEditModeEnabled = false;
                var durtyContacts = [];
                for (i = 0; i < $scope.ViewCustomer.CMContacts_editRow.length; i++) {
                    if ($scope.ViewCustomer.CMContacts_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        durtyContacts.push(JSON.stringify($scope.ViewCustomer.CMContacts[i]));
                    }
                    $scope.ViewCustomer.CMContacts_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.ViewCustomer.CMContacts_editRow[index].isEdit = true;
                    setTimeout(function() {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                }
            }
            $scope.ViewCustomer.editTaxExemptions = function(event, index) {
                if ($rootScope.GroupOnlyPermissions['Sales Taxes'].assign) {
                    $scope.ViewCustomer.TaxExemptions_editRow[index].radioValue = 0;
                    var isEditModeEnabled = false;
                    for (i = 0; i < $scope.ViewCustomer.TaxExemptions_editRow.length; i++) {
                        if ($scope.ViewCustomer.TaxExemptions_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                        }
                        $scope.ViewCustomer.TaxExemptions_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.ViewCustomer.TaxExemptions_editRow[index].isEdit = true;
                    }
                } else {
                    $scope.ViewCustomer.TaxExemptions_editRow[index].isEdit = false;
                }
            }
            $scope.loadData = function() {
                $scope.ViewCustomer.loadCustomerInfo();
            }
            $scope.loadDataFromCOU = function() {
                $scope.ViewCustomer.loadCustomerInfo();
            }
            $scope.ViewCustomer.SaveCustomerOwnedUnitsToserver = function(selectedCOURecords) {
                var customerId = $scope.ViewCustomer.customerId;
                CustomerOwnedUnitsService.addCustomerOwnedUnit(customerId, selectedCOURecords, $scope.ViewCustomer.COUPageSortAttrsJSON).then(function(relatedCOUList) {
                    $scope.ViewCustomer.TotalCOURecords = relatedCOUList.TotalCOURecords;
                    $scope.ViewCustomer.UpdateOwnedUnitsLists(relatedCOUList.CustomerOwnedUnitList);
                    setTimeout(function() {
                        $scope.ViewCustomer.COUPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    if (angular.element('#AddNewCOU') != null) {
                        angular.element('#AddNewCOU').modal('hide');
                    }
                    Notification.success($translate.instant('Generic_Saved'));
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.removeCustomerOwnedUnitRecord = function(customerOwnedUnitId) {
                // Calculate for new page number of grid
                var gridNewPN = $scope.ViewCustomer.COUPageSortAttrsJSON.CurrentPage;
                if ($scope.ViewCustomer.TotalCOURecords % $scope.ViewCustomer.COUPageSortAttrsJSON.PageSize == 1) {
                    $scope.ViewCustomer.COUPageSortAttrsJSON.CurrentPage = (gridNewPN > 1) ? (gridNewPN - 1) : 1;
                }
                CustomerOwnedUnitsService.removeCustomerOwnedUnit($scope.ViewCustomer.customerId, customerOwnedUnitId, $scope.ViewCustomer.COUPageSortAttrsJSON).then(function(relatedCOUList) {
                    $scope.ViewCustomer.TotalCOURecords = relatedCOUList.TotalCOURecords;
                    $scope.ViewCustomer.UpdateOwnedUnitsLists(relatedCOUList.CustomerOwnedUnitList);
                    setTimeout(function() {
                        $scope.ViewCustomer.COUPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    Notification.success($translate.instant('Generic_Deleted'));
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.getAndUpdateRelatedCustomers = function() {
                var customerId = $scope.ViewCustomer.customerId;
                RelatedCustomersService.getRelatedCustomers(customerId, $scope.ViewCustomer.customersPageSortAttrsJSON).then(function(relatedCustomers) {
                    $scope.ViewCustomer.TotalCustomerRecords = relatedCustomers.TotalCustomerRecords;
                    $scope.ViewCustomer.UpdateRelatedCustomersLists(relatedCustomers.RelatedCustomerList);
                    setTimeout(function() {
                        $scope.ViewCustomer.customersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                });
            }
            $scope.applyCssOnPartPopUp = function(event, className) {
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element(className).css('top', targetEle.offset().top);
                angular.element(className).css('left', event.clientX);
                setTimeout(function() {
                    angular.element(className).show();
                }, 1000);
            }
            $scope.ViewCustomer.openCOUpopup = function(event, COUId) {
            	var unitRelated_Json = {
                        couId: COUId
                };
                timer2 = $timeout(function() {
                    $scope.$broadcast('COUPopUpEvent', unitRelated_Json);
                    $scope.applyCssOnPartPopUp(event, '.COUInfoPopup');
                }, 1000);
            }
            $scope.ViewCustomer.hideCOUPopUp = function() {
                $timeout.cancel(timer2);
                angular.element('#COUInfoPopup').hide();
            }
            $scope.ViewCustomer.selectCallBack = function(selectedRecord) {
                if (selectedRecord.originalObject.Info == 'Customer') {
                    var parentCustomerId = $scope.ViewCustomer.customerId;
                    var selectedRecordId = selectedRecord.originalObject.Value;
                    if (selectedRecordId.length == 18) {
                        selectedRecordId = selectedRecordId.substring(0, 15);
                    }
                    if (parentCustomerId.length == 18) {
                        parentCustomerId = parentCustomerId.substring(0, 15);
                    }
                    if (parentCustomerId == selectedRecordId) {
                        Notification.error($translate.instant('Cannot_add_parent_customer_child_related_list'));
                        return;
                    }
                    $scope.ViewCustomer.addUpdateCustomerRecord(selectedRecord.originalObject.Value, 'Family');
                }
            }
            $scope.ViewCustomer.addUpdateCustomerRecord = function(relatedCustomerId, relation) {
                var parentCustomerId = $scope.ViewCustomer.customerId;
                var selectedCustomerRecords = [{
                    Id: relatedCustomerId,
                    Relation: relation,
                    ParentCustomer: parentCustomerId
                }];
                if (selectedCustomerRecords.Relation == "") {
                    var gridNewPN = $scope.ViewCustomer.customersPageSortAttrsJSON.CurrentPage;
                    if ($scope.ViewCustomer.TotalCustomerRecords % $scope.ViewCustomer.customersPageSortAttrsJSON.PageSize == 1) {
                        $scope.ViewCustomer.customersPageSortAttrsJSON.CurrentPage = (gridNewPN > 1) ? (gridNewPN - 1) : 1;
                    }
                }
                RelatedCustomersService.addRelatedCustomer(selectedCustomerRecords, $scope.ViewCustomer.customersPageSortAttrsJSON).then(function(relatedCustomers) {
                    $scope.ViewCustomer.TotalCustomerRecords = relatedCustomers.TotalCustomerRecords;
                    $scope.ViewCustomer.UpdateRelatedCustomersLists(relatedCustomers.RelatedCustomerList);
                    setTimeout(function() {
                        $scope.ViewCustomer.customersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    if (relation == "") {
                        Notification.success($translate.instant('Generic_Deleted'));
                    } else {
                        Notification.success($translate.instant('Generic_Saved'));
                    }
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.addUpdateContactRecord = function(relatedContactId, relation) {
                var parentCustomerId = $scope.ViewCustomer.customerId;
                var selectedContactRecords = [{
                    Id: relatedContactId,
                    Relation: relation,
                    ParentCustomer: parentCustomerId
                }];
                CustomerContactsService.updateRelation(selectedContactRecords, $scope.ViewCustomer.contactsPageSortAttrsJSON).then(function(relatedContacts) {
                    $scope.ViewCustomer.TotalContactRecords = relatedContacts.TotalContactRecords;
                    $scope.ViewCustomer.UpdateCustomerContactsLists(relatedContacts.ContactList);
                    setTimeout(function() {
                        $scope.ViewCustomer.contactsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    Notification.success($translate.instant('Generic_Saved'));
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.updateContactsToServer = function(selectedContactRecords) {
                CustomerContactsService.addCustomerContact(selectedContactRecords, $scope.ViewCustomer.contactsPageSortAttrsJSON).then(function(relatedContacts) {
                    $scope.ViewCustomer.TotalContactRecords = relatedContacts.TotalContactRecords;
                    $scope.ViewCustomer.UpdateCustomerContactsLists(relatedContacts.ContactList);
                    setTimeout(function() {
                        $scope.ViewCustomer.contactsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    Notification.success($translate.instant('Generic_Saved'));
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.removeCustomerContactRecord = function(customerContactId) {
                var gridNewPN = $scope.ViewCustomer.contactsPageSortAttrsJSON.CurrentPage;
                if ($scope.ViewCustomer.TotalContactRecords % $scope.ViewCustomer.contactsPageSortAttrsJSON.PageSize == 1) {
                    $scope.ViewCustomer.contactsPageSortAttrsJSON.CurrentPage = (gridNewPN > 1) ? (gridNewPN - 1) : 1;
                }
                CustomerContactsService.removeCustomerContact($scope.ViewCustomer.customerId, customerContactId, $scope.ViewCustomer.contactsPageSortAttrsJSON).then(function(relatedCustomerContactList) {
                    $scope.ViewCustomer.TotalContactRecords = relatedCustomerContactList.TotalContactRecords;
                    $scope.ViewCustomer.UpdateCustomerContactsLists(relatedCustomerContactList.ContactList);
                    setTimeout(function() {
                        $scope.ViewCustomer.contactsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    Notification.success($translate.instant('Generic_Deleted'));
                }, function(errorSearchResult) {
                    $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }
            $scope.ViewCustomer.addUpdateCOURecord = function(couId) {
                var selectedCOURecords = [{
                    Id: couId
                }];
                $scope.ViewCustomer.SaveCustomerOwnedUnitsToserver(angular.toJson(selectedCOURecords));
            }
            $scope.ViewCustomer.CM_OwnedUnits_GoAction = function(indexVal) {
                if ($scope.ViewCustomer.CMOwnedUnits_editRow[indexVal].radioValue == 1) {
                    $scope.ViewCustomer.openEditCustomerOwnedUnitPopup($scope.ViewCustomer.CMOwnedUnits[indexVal].Id);
                } else if ($scope.ViewCustomer.CMOwnedUnits_editRow[indexVal].radioValue == 4) {
                    $scope.ViewCustomer.removeCustomerOwnedUnitRecord($scope.ViewCustomer.CMOwnedUnits[indexVal].Id);
                }
            }
            $scope.ViewCustomer.CM_ActiveOrders_GoAction = function(indexVal) {
                
            }
            $scope.ViewCustomer.CM_Customers_GoAction = function(indexVal) {
                if ($scope.ViewCustomer.CMCustomers_editRow[indexVal].radioValue == 1) {
                    $scope.ViewCustomer.editRelatedCustomerPopUp($scope.ViewCustomer.CMCustomers[indexVal].Id);
                } else if ($scope.ViewCustomer.CMCustomers_editRow[indexVal].radioValue == 2) {
                    $scope.ViewCustomer.addUpdateCustomerRecord($scope.ViewCustomer.CMCustomers[indexVal].Id, "");
                }
            }
            $scope.ViewCustomer.CM_Contacts_GoAction = function(indexVal) {
                if ($scope.ViewCustomer.CMContacts_editRow[indexVal].radioValue == 1) {
                    $scope.ViewCustomer.openEditContactPopup($scope.ViewCustomer.CMContacts[indexVal].Id);
                } else if ($scope.ViewCustomer.CMContacts_editRow[indexVal].radioValue == 2) {
                    $scope.ViewCustomer.removeCustomerContactRecord($scope.ViewCustomer.CMContacts[indexVal].Id);
                }
            }
           /* $scope.ViewCustomer.TaxExemption_GoAction = function(indexVal) {
                if ($scope.ViewCustomer.TaxExemptions_editRow[indexVal].radioValue == 0) {
                    $scope.ViewCustomer.openTaxExemptionsPopup();
                }
            }
            $scope.ViewCustomer.openTaxExemptionsPopup = function() {
                loadState($state, 'ViewCustomer.TaxExemption', {
                    TaxExemptionParams: {
                        parentObjectId: $scope.ViewCustomer.CustomerInfo.CustomerInfo.Id
                    }
                });
            }*/
            $scope.$on('TaxExemptionCallback', function(event, args) {
                $scope.ViewCustomer.TotalTaxExemptionRecords = args.TotalTaxExemptionRecords;
                $scope.ViewCustomer.UpdateTaxExemptionsLists(args.TaxExemptionList);
            });
            $scope.ViewCustomer.openAddCustomerOwnedUnitPopup = function(event) {
                event.stopPropagation();
                var addCOUJson = {
                    customerMasterData: $scope.ViewCustomer.CustomerInfo.CustomerInfo.CustomerMasterData,
                    customerId: $scope.ViewCustomer.customerId,
                    unitType: 'COU'
                };
                loadState($state, 'ViewCustomer.COU', {
                    AddEditUnitParams: addCOUJson
                });
            }
            $scope.ViewCustomer.openEditCustomerOwnedUnitPopup = function(selectedCOUId) {
                var editCOUJson = {
                    couId: selectedCOUId,
                    customerId: $scope.ViewCustomer.customerId
                };
                loadState($state, 'ViewCustomer.COU', {
                    AddEditUnitParams: editCOUJson
                });
            }
            $scope.ViewCustomer.callbackAfterCOUSave = function() {
                $scope.$broadcast('AddCustomerOwnedUnitEvent', $scope.ViewCustomer.customerId);
            }
            $scope.ViewCustomer.openAddContactPopup = function() {
                loadState($state, 'ViewCustomer.AddEditCustomerContact', {
                    AddEditCustomerContactParams: {
                        parentCustomerId: $scope.ViewCustomer.customerId,
                        country: $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingCountry
                    }
                });
            }
            $scope.ViewCustomer.openEditContactPopup = function(selectedContactId) {
                loadState($state, 'ViewCustomer.AddEditCustomerContact', {
                    AddEditCustomerContactParams: {
                        contactId: selectedContactId,
                        parentCustomerId: $scope.ViewCustomer.customerId,
                        country: $scope.ViewCustomer.CustomerInfo.CustomerInfo.BillingCountry
                    }
                });
            }
            $scope.ViewCustomer.editRelatedCustomerPopUp = function(relatedCustomer) {
                var idParams = {
                    Id: relatedCustomer
                };
                loadState($state, 'ViewCustomer.EditCustomer', {
                    EditCustomerParams: idParams
                });
            }
            $scope.setFocusToSearchBox = function() {
                angular.element('#SearchToaddCutomer').focus();
            }
            $scope.ViewCustomer.activeSidepanelink = '#InfoSection';
            $scope.ViewCustomer.selectedItem = 'Info';
            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function() {
                $scope.ViewCustomer.onScroll();
            });
            $scope.ViewCustomer.sidepanelLink = function(event, relatedContent) {
                event.preventDefault();
                $scope.ViewCustomer.displaySections[relatedContent] = true;
                angular.element(document).off("scroll");
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 40;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                var target = angular.element(angular.element(event.target.closest('a'))).attr("href");
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
                }, 500, function() {
                    angular.element(document).on("scroll", function() {
                        $scope.ViewCustomer.onScroll();
                    });
                    $scope.ViewCustomer.onScroll();
                });
            }
            $scope.ViewCustomer.onScroll = function() {
                if ($state.current.name === 'ViewCustomer') {
                    var activeSidepanelink;
                    var selectedItem;
                    var heading = '';
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;
                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 0;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 10;
                    }
                    var scrollPos = angular.element(document).scrollTop();
                    if (isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#InfoSection';
                        selectedItem = 'Info';
                    } else if (isElementDefined('#StatisticsSection') && (scrollPos < angular.element('#StatisticsSection').position().top + angular.element('#StatisticsSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#StatisticsSection';
                        selectedItem = 'Statistics';
                    } else if (isElementDefined('#RelatedSection') && (scrollPos < angular.element('#RelatedSection').position().top + angular.element('#RelatedSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#RelatedSection';
                        selectedItem = 'Related';
                    } else if (isElementDefined('#ActivitySection') && (scrollPos < angular.element('#ActivitySection').position().top + angular.element('#ActivitySection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#ActivitySection';
                        selectedItem = 'ActivityStream';
                    } else if (isElementDefined('#StoreCreditsSection') && (scrollPos < angular.element('#StoreCreditsSection').position().top + angular.element('#StoreCreditsSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#StoreCreditsSection';
                        selectedItem = 'StoreCredits';
                    }
                    $scope.ViewCustomer.activeSidepanelink = activeSidepanelink;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }
            $scope.ViewCustomer.dropDownItem = function(event, selectedSection) {
                var activeSection = $scope.ViewCustomer.activeSidepanelink.replace('#', '');
                $scope.ViewCustomer.selectedItem = selectedSection;
                if (activeSection != selectedSection) {
                    $scope.ViewCustomer.sidepanelLink(event, selectedSection);
                }
            }
            $scope.ViewCustomer.editCustomerDetails = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                var idParams = {
                    Id: CustomerId
                };
                loadState($state, 'ViewCustomer.EditCustomer', {
                    EditCustomerParams: idParams
                });
            }
            $scope.ViewCustomer.NewCustomer = function() {
                $scope.$broadcast('AddCustomerEvent');
            }
            $scope.ViewCustomer.CustomerContacts_recordSaveCallback = function(relatedCustomerContactList) {
                $scope.ViewCustomer.Contacts_paginationControlsAction();
            }
            $scope.ViewCustomer.COUs_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                CustomerOwnedUnitsService.getCustomerOwnedUnits(CustomerId, $scope.ViewCustomer.COUPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.CMOwnedUnits = [];
                    $scope.ViewCustomer.TotalCOURecords = resultInfo.TotalCOURecords;
                    $scope.ViewCustomer.UpdateOwnedUnitsLists(resultInfo.CustomerOwnedUnitList);
                    setTimeout(function() {
                        $scope.ViewCustomer.COUPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.ActiveOrders_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                CustomerActiveOrdersService.getCustomerActiveOrders(CustomerId, $scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.ActiveOrders = [];
                    $scope.ViewCustomer.TotalActiveOrderRecords = resultInfo.TotalActiveSalesOrderRecords;
                    $scope.ViewCustomer.UpdateActiveOrdersLists(resultInfo.ActiveSalesOrderList);
                    setTimeout(function() {
                        $scope.ViewCustomer.ActiveOrdersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.selectAllText = function (elmId) {
                angular.element('#'+ elmId).select();
            }
            $scope.ViewCustomer.updateCustomerNotes = function () {
                if($scope.ViewCustomer.CustomerInfo.CustomerInfo.Notes) {
                    $scope.ViewCustomer.saveCustomerNotesToServer($scope.ViewCustomer.customerId, $scope.ViewCustomer.CustomerInfo.CustomerInfo.Notes);
                }
            }
            $scope.ViewCustomer.saveCustomerNotesToServer = function (customerId, customerNotes) {
                CustomerInfoService1.saveCustomerNotes(customerId, customerNotes).then(function (successfulSearchResult) {
                    Notification.success($translate.instant('Generic_Saved'));
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.ViewCustomer.Customers_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                RelatedCustomersService.getRelatedCustomers(CustomerId, $scope.ViewCustomer.customersPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.CMCustomers = [];
                    $scope.ViewCustomer.TotalCustomerRecords = resultInfo.TotalCustomerRecords;
                    $scope.ViewCustomer.UpdateRelatedCustomersLists(resultInfo.RelatedCustomerList);
                    setTimeout(function() {
                        $scope.ViewCustomer.customersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.Contacts_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                CustomerContactsService.getCustomerContacts(CustomerId, $scope.ViewCustomer.contactsPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.CMContacts = [];
                    $scope.ViewCustomer.TotalContactRecords = resultInfo.TotalContactRecords;
                    $scope.ViewCustomer.UpdateCustomerContactsLists(resultInfo.ContactList);
                    setTimeout(function() {
                        $scope.ViewCustomer.contactsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    setTimeout(function() {
                        if (!$scope.$$phase) {
                            $scope.$digest();
                        }
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.UpdateCustomerOrdersLists = function(CustomerSalesOrderList) {
                $scope.ViewCustomer.CustomerOrders = CustomerSalesOrderList;
                $scope.ViewCustomer.CustomerOrders_editRow = [];
                for (i = 0; i < $scope.ViewCustomer.CustomerOrders.length; i++) {
                    $scope.ViewCustomer.CustomerOrders_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }
            $scope.ViewCustomer.closeEditCustomerOrderRows = function(event) {
                $scope.ViewCustomer.UpdateCustomerOrdersLists($scope.ViewCustomer.CustomerOrders);
            }
            $scope.ViewCustomer.editCustomerOrder = function(event, index) {
                $scope.ViewCustomer.CustomerOrders_editRow[index].radioValue = 0;
                var isEditModeEnabled = false;
                var durtyCustomerOrders = [];
                for (i = 0; i < $scope.ViewCustomer.CustomerOrders_editRow.length; i++) {
                    if ($scope.ViewCustomer.CustomerOrders_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        durtyCustomerOrders.push(JSON.stringify($scope.ViewCustomer.CustomerOrders[i]));
                    }
                    $scope.ViewCustomer.CustomerOrders_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.ViewCustomer.CustomerOrders_editRow[index].isEdit = true;
                    setTimeout(function() {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                }
            }
            $scope.ViewCustomer.CM_CustomerOrders_GoAction = function(indexVal) {
                if ($scope.ViewCustomer.CustomerOrders_editRow[indexVal].radioValue == 1) {
                }
            }
            $scope.ViewCustomer.CustomerOrders_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                CustomerOrdersService.getAllCustomerOrdersListByCustomerId(CustomerId, $scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.CustomerOrders = [];
                    $scope.ViewCustomer.TotalCustomerOrderRecords = resultInfo.TotalCustomerOrderRecords;
                    $scope.ViewCustomer.UpdateCustomerOrdersLists(resultInfo.AllCustomerOrderList);
                    setTimeout(function() {
                        $scope.ViewCustomer.CustomerOrdersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.UpdateStoreCreditsLists = function(StoreCreditsList) {
                $scope.ViewCustomer.StoreCredits = StoreCreditsList;
            }
            $scope.ViewCustomer.MessageHistory_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                CustomerInfoService1.getCustomerMessageHistory(CustomerId, $scope.ViewCustomer.SMSMessagePageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.SMSMessageList = [];
                    $scope.ViewCustomer.TotalMessageRecords = resultInfo.TotalMessageRecords;
                    $scope.ViewCustomer.SMSMessageList = resultInfo.MessageHistoryList;
                    setTimeout(function() {
                        $scope.ViewCustomer.SMSMessagePageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.StoreCredits_paginationControlsAction = function() {
                var CustomerId = $scope.ViewCustomer.customerId;
                StoreCreditService.getCustomerStoreCredit(CustomerId, $scope.ViewCustomer.StoreCreditPageSortAttrsJSON).then(function(resultInfo) {
                    $scope.ViewCustomer.StoreCredits = [];
                    $scope.ViewCustomer.TotalStoreCreditRecords = resultInfo.TotalStoreCreditRecords;
                    $scope.ViewCustomer.UpdateStoreCreditsLists(resultInfo.customerStoreCreditList);
                    setTimeout(function() {
                        $scope.ViewCustomer.StoreCreditPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }
            $scope.ViewCustomer.ShowAdjustStoreCreditsPopup = function() {
                $scope.ViewCustomer.StoreCreditJson = {};
                $scope.ViewCustomer.setStoreCreditDefaultValidationModel();
                angular.element('#StoreCreditAdjust').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                setTimeout(function() {
                    angular.element('#AmountInput').focus();
                }, 500);
            }
            $scope.ViewCustomer.CloseAdjustStoreCreditsPopup = function() {
                angular.element('#StoreCreditAdjust').modal('hide');
            }
            $scope.ViewCustomer.StoreCreditJson = {};
            $scope.ViewCustomer.disableStoreCreditSaveButton = false;
            $scope.ViewCustomer.AddStoreCredit = function() {
                if ($scope.ViewCustomer.disableStoreCreditSaveButton) {
                    return;
                }
                $scope.ViewCustomer.disableStoreCreditSaveButton = true;
                $scope.ViewCustomer.validateStoreCreditForm();
                if (!$scope.ViewCustomer.validateStoreCreditForm()) {
                    $scope.ViewCustomer.disableStoreCreditSaveButton = false;
                    return;
                }
                if ($scope.ViewCustomer.StoreCreditJson.Amount < 0 && $scope.ViewCustomer.StoreCreditJson.Amount < ($scope.ViewCustomer.CustomerInfo.CustomerInfo.TotalStoreCredit * -1)) {
                    $scope.ViewCustomer.disableStoreCreditSaveButton = false;
                    Notification.error($translate.instant('StoreCredits_Negative_Balance_Error_Text'));
                    return;
                }
                var StoreCreditJsonList = [$scope.ViewCustomer.StoreCreditJson];
                StoreCreditService.addStoreCredit($scope.ViewCustomer.customerId, StoreCreditJsonList, $scope.ViewCustomer.StoreCreditPageSortAttrsJSON).then(function(successResul) {
                    $scope.ViewCustomer.TotalStoreCreditRecords = successResul.TotalStoreCreditRecords;
                    $scope.ViewCustomer.CustomerInfo.CustomerInfo.TotalStoreCredit = successResul.TotalStoreCreditValue;
                    $scope.ViewCustomer.UpdateStoreCreditsLists(successResul.customerStoreCreditList);
                    $scope.ViewCustomer.disableStoreCreditSaveButton = false;
                    $scope.ViewCustomer.CloseAdjustStoreCreditsPopup();
                    Notification.success($translate.instant('Generic_Saved'));
                }, function(errorMessage) {
                    $scope.ViewCustomer.disableStoreCreditSaveButton = false;
                    Notification.error(errorMessage);
                });
            }
            $scope.ViewCustomer.validateStoreCreditForm = function() {
                $scope.ViewCustomer.isStoreCreditFormValid = true;
                angular.forEach($scope.ViewCustomer.StoreCreditFormValidationModal, function(value, key) {
                    $scope.ViewCustomer.validateStoreCreditFieldWithKey(key);
                });
                return $scope.ViewCustomer.isStoreCreditFormValid;
            }
            $scope.ViewCustomer.validateStoreCreditFieldWithKey = function(modelKey) {
                var fieldValue = $scope.ViewCustomer.StoreCreditJson[modelKey];
                var isError = false;
                var ErrorMessage = '';
                if ($scope.ViewCustomer.StoreCreditFormValidationModal != undefined && $scope.ViewCustomer.StoreCreditFormValidationModal != '' && $scope.ViewCustomer.StoreCreditFormValidationModal != null) {
                    var validateType = $scope.ViewCustomer.StoreCreditFormValidationModal[modelKey].Type;
                    if (isError == false && validateType.indexOf('Required') > -1) {
                        if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                            isError = true;
                            ErrorMessage = $translate.instant('Field_Is_Required');
                        }
                    }
                    if (isError == false && validateType.indexOf('NotZero') > -1) {
                        if (fieldValue == 0) {
                            isError = true;
                            ErrorMessage = $translate.instant('StoreCredits_Zero_Balance_Error_Text');
                        }
                    }
                    $scope.ViewCustomer.StoreCreditFormValidationModal[modelKey].isError = isError;
                    $scope.ViewCustomer.StoreCreditFormValidationModal[modelKey].ErrorMessage = ErrorMessage;
                    if ($scope.ViewCustomer.StoreCreditFormValidationModal[modelKey].isError == true) {
                        $scope.ViewCustomer.isStoreCreditFormValid = false;
                    }
                }
            }
            $scope.ViewCustomer.setStoreCreditDefaultValidationModel = function() {
                $scope.ViewCustomer.StoreCreditFormValidationModal = {
                    Amount: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required,NotZero'
                    },
                    Reference: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required'
                    }
                };
            }
            $scope.ViewCustomer.openMessagePopUp = function(element) {
                var custName = ($scope.ViewCustomer.CustomerInfo.CustomerInfo.Type == 'Individual' ? $scope.ViewCustomer.CustomerInfo.CustomerInfo.FirstName + ' ' + $scope.ViewCustomer.CustomerInfo.CustomerInfo.LastName : $scope.ViewCustomer.CustomerInfo.CustomerInfo.BusinessName);
                var prefSMSPhone = (($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS != null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS != "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo[$scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredSMS] : '');
                var prefCallPhone = (($scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone != null || $scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone != "") ? $scope.ViewCustomer.CustomerInfo.CustomerInfo[$scope.ViewCustomer.CustomerInfo.CustomerInfo.PreferredPhone] : '');
                var messageParams = {
                    Activity: 'Text Message',
                    CustomerInfo: {
                        'Cust_Id': $scope.ViewCustomer.CustomerInfo.CustomerInfo.Id,
                        'Cust_Name': custName,
                        'Cust_Type': $scope.ViewCustomer.CustomerInfo.CustomerInfo.Type,
                        'Cust_PreferredPhone': prefCallPhone,
                        'Cust_PreferredSMS': prefSMSPhone,
                        'Cust_HomeNumber': $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumber,
                        'Cust_HomeNumberSMS': $scope.ViewCustomer.CustomerInfo.CustomerInfo.HomeNumberSMS,
                        'Cust_FormattedHomeNumber': $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedHomeNumber,
                        'Cust_WorkNumber': $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumber,
                        'Cust_WorkNumberSMS': $scope.ViewCustomer.CustomerInfo.CustomerInfo.WorkNumberSMS,
                        'Cust_FormattedWorkNumber': $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedWorkNumber,
                        'Cust_OtherNumber': $scope.ViewCustomer.CustomerInfo.CustomerInfo.OtherPhone,
                        'Cust_MobileNumberSMS': $scope.ViewCustomer.CustomerInfo.CustomerInfo.MobileNumberSMS,
                        'Cust_FormattedOtherPhone': $scope.ViewCustomer.CustomerInfo.CustomerInfo.FormattedOtherPhone
                    }
                };
                loadState($state, 'ViewCustomer.CustomerMessagingPopUp', {
                    messagingInfoParams: messageParams
                });
            }
            $scope.ViewCustomer.loadCustomerInfo();
        }
    ]);
});