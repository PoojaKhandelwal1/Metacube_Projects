define(['Routing_AppJs_PK', 'AddEditCustomerServices', 'CustomMakeSortData', 'dirNumberInput'], function(Routing_AppJs_PK, AddEditCustomerServices, CustomMakeSortData, dirNumberInput) {
    $(document).ready(function() {
        $('.Customer-Suggestion-overlay').mouseover(function() {
            $('.Customer-Suggestion-overlay').show();
        })
        $('.Customer-Suggestion-overlay').mouseout(function() {
            $('.Customer-Suggestion-overlay').hide();
        })
    });
    $(document).ready(function() {
        $('#addmoreinfoBtnId').click(function() {
            if ($(this).hasClass('keep_open')) {} else {
                $('.dropdown-menu').addClass("keep_open");
            }
        });
        $('[data-toggle="tooltip"]').tooltip({
            placement: 'bottom'
        });
        $(document).on('click', '.dropdown-menu', function(e) {
            $(this).hasClass('keep_open') && e.stopPropagation();
        });
        $('.controls').hide();
        $(".form-control").focus(function() {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).css('display', 'block');
        })
        $('#closemodal').click(function() {
            $('#pop').modal('hide');
        });
        $('.btn').on("click", function() {
            $($(this).parent().find("input")).focus();
        });
    })
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditCustomerCtrl', ['$q', '$scope', '$rootScope', '$stateParams', '$state', 'addEditCustomerService', function($q, $scope, $rootScope, $stateParams, $state, addEditCustomerService) {
        var Notification = injector.get("Notification");
        if (angular.isDefined($scope.CustomerModal)) {} else {
            $scope.CustomerModal = {};
            $scope.CustomerModal.AppointmentId = '';
        }

        

        $scope.handler = 'pop';
        if (angular.isDefined($scope.selectedObject)) {} else {
            $scope.selectedObject = {};
        }
        $scope.selectedObject.ChangeRecords = 0;
        $scope.CustomerModal.FirstCall = 0;
        $scope.$on('AddCustomerEvent', function(event, args) {
            $scope.CustomerModal.disableSaveBtn = false; 
            $scope.CustomerModal.isOpenFromSTA = '';
            if (args != undefined) {
                if (args.isOpenFromSelectCustomerCustomer == 'isOpenFromSelectCustomerCustomer') {
                    $scope.CustomerModal.sellingType = args.sellingType;
                    $scope.CustomerModal.isOpenFromSelectCustomerCustomer = args.isOpenFromSelectCustomerCustomer;
                } else if (args.isOpenFromSelectCustomerCustomer == 'isOpenFromSTA') {
                    $scope.CustomerModal.isOpenFromSTA = args.isOpenFromSelectCustomerCustomer;
                }
            } else {
                $scope.CustomerModal.isOpenFromSelectCustomerCustomer = '';
            }
            $scope.CustomerModal.addNewCustomer();
        });
        $scope.$on('LoadMasterData', function() {
            $scope.CustomerModal.disableSaveBtn = false;
            $scope.CustomerModal.initUnit = {
                Year: null,
                Make: null,
                Model: null,
                SubModel: null,
                VIN: '',
                Plate: '',
                Mileage: null,
                Color: ''
            };
            $scope.CustomerModal.loadCustomerMasterData();
        });
        $scope.CustomerModal.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.$on('EditCustomerEvent', function(event, customerId) {
            $scope.CustomerModal.disableSaveBtn = false;
            $scope.CustomerModal.editCustomer(customerId);
        });
        $scope.$on('EditCustomerRelatedEvent', function(event, customerId) {
            $scope.CustomerModal.disableSaveBtn = false;
            $scope.CustomerModal.editCustomer(customerId);
        });
        $scope.CustomerModal.noSpecialChar = function(event) {
            var regex = new RegExp("^[a-zA-Z0-9]+$");
            var key = String.fromCharCode(!event.charCode ? event.which : event.charCode);
            if (!regex.test(key)) {
                event.preventDefault();
                return false;
            }
        }
        $scope.CustomerModal.showInfoOverlay = function(event, index) {
            var currentPageName;
            if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '') {
                currentPageName = $stateParams.myParams.A_View_StateName;
            } else {
                currentPageName = $rootScope.$previousState.name;
            }
            if (currentPageName.toLowerCase().indexOf('customerorder') == -1 || $rootScope.$previousState.name === 'SelectCustomer') {
                return;
            }
            var targetEle = angular.element('#' + event + index);
            var scrolledTop = -($('.modal-content').offset().top - 30);
            var elementWidth = targetEle.width();
            angular.element('.Customer-Suggestion-overlay').css('top', targetEle.offset().top + scrolledTop - 40);
            angular.element('.Customer-Suggestion-overlay').css('left', '200px');
            angular.element('.Customer-Suggestion-overlay').show();
            $scope.CustomerModal.SimilarCustomerSelect = {
                Value: $scope.CustomerModal.SimilarCustomers[index].Id,
                Name: $scope.CustomerModal.SimilarCustomers[index].CustomerName
            }
        }
        $scope.CustomerModal.hideCustomerInfoOverlay = function() {
            angular.element('.Customer-Suggestion-overlay').hide();
        }
        $scope.CustomerModal.loadCustomerMasterData = function() {
            if ($scope.CustomerModal.CustomerMasterData == undefined) {
                addEditCustomerService.getCustomerAllMasterData().then(function(CustomerMasterData) {
                    $scope.CustomerModal.CustomerMasterData = CustomerMasterData;
                    $scope.CustomerModal.SetMasterData();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            } else {
                $scope.CustomerModal.SetMasterData();
            }
        }
        $scope.CustomerModal.SetMasterData = function() {
            var Curryear = new Date().getFullYear();
            var curr = parseInt(Curryear);
            $scope.CustomerModal.BirthYears = [];
            $scope.CustomerModal.BirthDays = [];
            $scope.CustomerModal.ModelYears = [];
            for (i = 1900; i < curr; i++) {
                var year = {
                    year: i
                };
                $scope.CustomerModal.BirthYears.push(year);
            }
            for (i = curr; i > (curr - 100 + 2); i--) {
                var year = {
                    modelyear: i.toString()
                };
                $scope.CustomerModal.ModelYears.push(year);
            }
            $scope.CustomerModal.ClearAlldata();
            $scope.CustomerModal.IsEditMode = false;
            $scope.CustomerModal.disableSaveBtn = false;
            $scope.CustomerModal.initUnit = {
                Year: null,
                Make: null,
                Model: null,
                SubModel: null,
                VIN: '',
                Plate: '',
                Mileage: null,
                Color: ''
            };
            var args;
            if ($state.current.name === 'ViewCustomer.EditCustomer' || $state.current.name === 'CustomerOrder.EditCustomer') {
                args = $stateParams.EditCustomerParams;
            } else {
                args = $stateParams.myParams;
            }
            $scope.CustomerModal.disableSaveBtn = false;
            $scope.CustomerModal.isOpenFromSTA = '';
            if (args != undefined) {
                if (args.isOpenFromSelectCustomerCustomer == 'isOpenFromSelectCustomerCustomer') {
                    $scope.CustomerModal.sellingType = args.sellingType;
                    $scope.CustomerModal.isOpenFromSelectCustomerCustomer = args.isOpenFromSelectCustomerCustomer;
                } else if (args.isOpenFromSelectCustomerCustomer == 'isOpenFromSTA') {
                    $scope.CustomerModal.isOpenFromSTA = args.isOpenFromSelectCustomerCustomer;
                }
            } else {
                $scope.CustomerModal.isOpenFromSelectCustomerCustomer = '';
            }
            var customerId;
            if ($state.current.name === 'ViewCustomer.EditCustomer' || $state.current.name === 'CustomerOrder.EditCustomer') {
                customerId = $stateParams.EditCustomerParams.Id;
            }
            if (customerId != undefined && customerId != null) {
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply(); //TODO
                }
                $scope.CustomerModal.editCustomer(customerId);
            } else {
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply(); //TODO
                }
                $scope.CustomerModal.addNewCustomer();
            }
        }
        $scope.CustomerModal.addNewCustomer = function() {
            $scope.CustomerModal.ClearAlldata();
            $scope.CustomerModal.IsEditMode = false;
            angular.element('#pop').modal({
                backdrop: 'static',
                keyboard: false
            });
        }
        $scope.CustomerModal.editCustomer = function(customerId) {
            $scope.CustomerModal.SelectedAccountType = {};
            addEditCustomerService.editCustomerDetails(customerId).then(function(CustomerData) {
                $scope.CustomerModal.IsEditMode = true;
                $scope.CustomerModal.CustomerInfo = CustomerData[0]
                $scope.CustomerModal.SetCustomerFormDefault();
                $scope.CustomerModal.CustomerValidationCOU = [];
                $scope.CustomerModal.CustumerUnitModal = [];
                
                $scope.CustomerModal.SelectedAccountType.AccountType = CustomerData[0].AccountTypeName;
                $scope.CustomerModal.SelectedAccountType.AccountTypeId = CustomerData[0].AccountTypeId;
                addEditCustomerService.getAllAccountTypeData().then(function(AccountTypeList) { 
                    $scope.CustomerModal.AccountTypeList = AccountTypeList;
                });
                $scope.CustomerModal.isVendorFlag = $scope.CustomerModal.CustomerInfo.IsVendor;
                angular.element('#pop').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            });
        }
        $scope.CustomerModal.ClearAlldata = function() {
            try {
                $scope.CustomerModal.Country = $scope.CustomerModal.CustomerMasterData.CountryList;
            } catch (err) {
                Notification.error('Country is not selected');
                return;
            }
            $scope.CustomerModal.SelectedState = null; 
            $scope.CustomerModal.ShippingCountry = $scope.CustomerModal.CustomerMasterData.CountryList;
            $scope.CustomerModal.PriceLevel = $scope.CustomerModal.CustomerMasterData.PriceLevelList;
            $scope.CustomerModal.SalesTax = $scope.CustomerModal.CustomerMasterData.SalesTaxList;
            $scope.CustomerModal.DefaultOrderingTaxId = $scope.CustomerModal.CustomerMasterData.DefaultOrderingTaxId;
            $scope.CustomerModal.UnitMakeSelected = [];
            $scope.CustomerModal.UnitMakeNameStr = [];
            $scope.CustomerModal.UnitModelNameStr = [];
            $scope.CustomerModal.UnitSubModelNameStr = [];
            $scope.CustomerModal.UnitModelFilter = [];
            $scope.CustomerModal.UnitSubModelFilter = [];
            $scope.CustomerModal.CurrentIndexMake = [];
            $scope.CustomerModal.CurrentIndexUnitModel = [];
            $scope.CustomerModal.CurrentIndexUnitModel = [];
            $scope.CustomerModal.CurrentIndexUnitSubModel = [];
            $scope.CustomerModal.filteredItemsMake = [];
            $scope.CustomerModal.filteredItemsModel = [];
            $scope.CustomerModal.filteredItemsSubModel = [];
            $scope.CustomerModal.FilterSearchMake = [];
            $scope.CustomerModal.FilterSearchUnitModel = [];
            $scope.CustomerModal.FilterSearchUnitSubModel = [];
            $scope.CustomerModal.saveUnitModelBlur = [];
            $scope.CustomerModal.saveUnitMakeBlur = [];
            $scope.CustomerModal.saveUnitSubModelBlur = [];
            $scope.CustomerModal.UnitModel = [];
            $scope.CustomerModal.UnitSubModel = [];
            $scope.CustomerModal.UnitModelSelected = [];
            $scope.CustomerModal.UnitYearSelected = [];
            $scope.CustomerModal.UnitSubModelSelected = [];
            $scope.CustomerModal.SimilarCOU = {};
            $scope.CustomerModal.SimilarCustomers = [];
            $scope.CustomerModal.SetDafaultBillingCountry();
            $scope.CustomerModal.SetDafaultBillingState();
            $scope.CustomerModal.SetDafaultPriceLevel();
            $scope.CustomerModal.SetDafaultSalesTax();
            $scope.CustomerModal.UnitMake = $scope.CustomerModal.CustomerMasterData.UnitMakeList;
            $scope.CustomerModal.VendorSelectedSalesTax = {};
            $scope.CustomerModal.BirthyearSelected = {};
            $scope.CustomerModal.BirthmonthSelected = {};
            $scope.CustomerModal.BirthdaySelected = {};
            $scope.CustomerModal.MileageList = [{
                Value: 'Km'
            }, {
                Value: 'Mi'
            }, {
                Value: 'Hrs'
            }];
            $scope.CustomerModal.SetDefaultBirthday();
            $scope.CustomerModal.tabIndexValue = 500;
            $scope.CustomerModal.AdditionalFieldsInfo = {
                OtherPhone: {
                    isPrimary: false,
                    label: $Label.Other_Phone,
                    fieldId: 'otherPhoneId',
                    displayType: 'Both'
                },
                OtherEmail: {
                    isPrimary: false,
                    label: $Label.Other_Email,
                    fieldId: 'otherEmail',
                    displayType: 'Both'
                },
                Birthdate: {
                    isPrimary: false,
                    label: $Label.Label_Birthday,
                    fieldId: 'birthMonth',
                    displayType: 'Individual'
                },
                FacebookLink: {
                    isPrimary: false,
                    label: $Label.Label_Facebook,
                    fieldId: 'facebookLink',
                    displayType: 'Both'
                },
                TwitterLink: {
                    isPrimary: false,
                    label: $Label.Label_Twitter,
                    fieldId: 'twitterLink',
                    displayType: 'Both'
                },
                LinkedInLink: {
                    isPrimary: false,
                    label: $Label.Label_LinkedIn,
                    fieldId: 'LinkedinLink',
                    displayType: 'Both'
                },
                CustomerUnit: {
                    isPrimary: false,
                    label: $Label.Label_Customer_Unit,
                    displayType: 'Both'
                },
                Company: {
                    isPrimary: false,
                    label: $Label.Label_Company,
                    fieldId: 'companyName',
                    displayType: 'Individual'
                },
                DriversLicense: {
                    isPrimary: false,
                    label: 'Drivers License',
                    fieldId: 'driversLicenseId',
                    displayType: 'Individual'
                },
                JobTitle: {
                    isPrimary: false,
                    label: $Label.Job_Title,
                    fieldId: 'jobTitle',
                    displayType: 'Individual'
                },
                PriceLevel: {
                    isPrimary: false,
                    label: $Label.Label_Price_Level,
                    fieldId: 'priceLevelDropDown',
                    displayType: 'Both'
                },
                IsVendor: {
                    isPrimary: false,
                    label: $Label.Vendor_Object_Display_Label,
                    fieldId: 'vendorDropDown',
                    displayType: 'Both'
                },
                Active: {
                    isPrimary: false,
                    label: $Label.Label_Active,
                    displayType: 'Both'
                }
            };
            $scope.CustomerModal.CustomerValidation = {
                FirstName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'firstName,required,Maxlength,Minlength',
                    Maxlength: 80,
                    Minlength: 2
                },
                LastName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'lastName,required,Maxlength,Minlength',
                    Maxlength: 80,
                    Minlength: 2
                },
                BusinessName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'required,Maxlength,Minlength',
                    Maxlength: 80,
                    Minlength: 2
                },
                HomeEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email'
                },
                WorkEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email'
                },
                OtherEmail: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'email'
                },
                HomeNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10
                },
                WorkNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10
                },
                OtherPhone: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'phone,Maxlength,Minlength',
                    Maxlength: 10,
                    Minlength: 10
                },
                BillingPostalCode: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'PostalCode,Maxlength',
                    Maxlength: 10
                },
                ShippingPostalCode: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'PostalCode,Maxlength',
                    Maxlength: 10
                }
            };
            $scope.CustomerModal.CustomerValidationCOU = [{
                VIN: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'VIN'
                },
                Mileage: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Numeric'
                },
                Make: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Model: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            }];
            $scope.CustomerModal.CustomerInfo = {};
            $scope.CustomerModal.CustomerInfo = {
                IsBothAddressSame: true,
                IsCustomer: true,
                Active: true,
                WorkNumberSMS: false,
                MobileNumberSMS: false,
                HomeNumberSMS: false,
                IsVendor: false
            };
            $scope.CustomerModal.CustomerInfo.Type = 'Individual';
            $scope.CustomerModal.CustumerUnitModal = [{
                Year: null,
                Make: null,
                Model: null,
                SubModel: null,
                VIN: '',
                Plate: '',
                Color: '',
                Mileage: null,
                MileageType: 'Km'
            }];
        }
        $scope.CustomerModal.manageAdditionalFields = function(key) {
            var result = false;
            if ($scope.CustomerModal.AdditionalFieldsInfo[key].isPrimary == false) {
                result = true;
            }
            if ($scope.CustomerModal.IsEditMode == true && key == 'CustomerUnit') {
                result = false;
            }
            if ($scope.CustomerModal.CustomerInfo.Type == 'Business' && $scope.CustomerModal.AdditionalFieldsInfo[key].displayType == 'Individual') {
                result = false;
            }
            return result;
        }
        $scope.CustomerModal.DateFormat = $Global.DateFormat;
        $scope.CustomerModal.dateOptionsForRegExpiryDate = {
            minDate: new Date,
            dateFormat: $scope.CustomerModal.DateFormat
        };
        $scope.CustomerModal.SetCustomerFormDefault = function() {
            if ($scope.CustomerModal.CustomerInfo.BirthYear != null && $scope.CustomerModal.CustomerInfo.BirthMonth != null && $scope.CustomerModal.CustomerInfo.BirthDay != null) {
                $scope.CustomerModal.BirthyearSelected = {
                    year: $scope.CustomerModal.CustomerInfo.BirthYear
                };
                $scope.CustomerModal.BirthmonthSelected = $scope.CustomerModal.CustomerInfo.BirthMonth
                $scope.CustomerModal.ChangeMonth();
                $scope.CustomerModal.BirthdaySelected = {
                    day: $scope.CustomerModal.CustomerInfo.BirthDay
                };
            }
            if ($scope.CustomerModal.CustomerInfo.BillingCountry != '') {
                for (i = 0; i < $scope.CustomerModal.CustomerMasterData.CountryList.length; i++) {
                    if ($scope.CustomerModal.CustomerMasterData.CountryList[i].CountryName == $scope.CustomerModal.CustomerInfo.BillingCountry) {
                        $scope.CustomerModal.SelectedCountry = $scope.CustomerModal.CustomerMasterData.CountryList[i];
                    }
                }
                $scope.CustomerModal.State = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedCountry.CountryName];
                for (i = 0; i < $scope.CustomerModal.State.length; i++) {
                    if ($scope.CustomerModal.State[i].StateName == $scope.CustomerModal.CustomerInfo.BillingState) {
                        $scope.CustomerModal.SelectedState = $scope.CustomerModal.State[i];
                    }
                }
                if ($scope.CustomerModal.CustomerInfo.IsBothAddressSame) {
                    angular.element("#sameAsBA").addClass("chked");
                    angular.element("#billingaddress").slideUp();
                } else {
                    for (i = 0; i < $scope.CustomerModal.CustomerMasterData.CountryList.length; i++) {
                        if ($scope.CustomerModal.CustomerMasterData.CountryList[i].CountryName == $scope.CustomerModal.CustomerInfo.ShippingCountry) {
                            $scope.CustomerModal.SelectedShippingCountry = $scope.CustomerModal.CustomerMasterData.CountryList[i];
                        }
                    }
                    if(!$scope.CustomerModal.SelectedShippingCountry) {
                    	$scope.CustomerModal.SelectedShippingCountry = $scope.CustomerModal.SelectedCountry;
                    }
                    if($scope.CustomerModal.SelectedShippingCountry) {
                    	$scope.CustomerModal.ShippingState = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedShippingCountry.CountryName];
                    	for (i = 0; i < $scope.CustomerModal.ShippingState.length; i++) {
                            if ($scope.CustomerModal.ShippingState[i].StateName == $scope.CustomerModal.CustomerInfo.ShippingState) {
                                $scope.CustomerModal.SelectedShippingState = $scope.CustomerModal.ShippingState[i];
                            }
                        }
                    }
                }
            } else {
                $scope.CustomerModal.CustomerInfo.IsBothAddressSame = true;
            }
            if ($scope.CustomerModal.CustomerInfo.PriceLevelId != null) {
                for (i = 0; i < $scope.CustomerModal.PriceLevel.length; i++) {
                    if ($scope.CustomerModal.PriceLevel[i].Id == $scope.CustomerModal.CustomerInfo.PriceLevelId) {
                        $scope.CustomerModal.SelectedPriceLevel = $scope.CustomerModal.PriceLevel[i];
                    }
                }
                $scope.CustomerModal.AdditionalFieldsInfo['PriceLevel'].isPrimary = true;
            }
            if ($scope.CustomerModal.CustomerInfo.SalesTaxId != null) {
                for (i = 0; i < $scope.CustomerModal.SalesTax.length; i++) {
                    if ($scope.CustomerModal.SalesTax[i].Id == $scope.CustomerModal.CustomerInfo.SalesTaxId) {
                        $scope.CustomerModal.SelectedSalesTax = $scope.CustomerModal.SalesTax[i];
                    }
                }
            }
            if ($scope.CustomerModal.CustomerInfo.IsVendor == true) {
                if ($scope.CustomerModal.CustomerInfo.PurchaseTaxId != null) {
                    for (i = 0; i < $scope.CustomerModal.SalesTax.length; i++) {
                        if ($scope.CustomerModal.SalesTax[i].Id == $scope.CustomerModal.CustomerInfo.PurchaseTaxId) {
                            $scope.CustomerModal.VendorSelectedSalesTax = $scope.CustomerModal.SalesTax[i];
                        }
                    }
                }
            }
            angular.forEach($scope.CustomerModal.AdditionalFieldsInfo, function(value, key) {
                if ($scope.CustomerModal.CustomerInfo[key] != null && $scope.CustomerModal.CustomerInfo[key] != '') {
                    $scope.CustomerModal.AdditionalFieldsInfo[key].isPrimary = true;
                }
            });
            $scope.CustomerModal.AdditionalFieldsInfo.Active.isPrimary = true;
        }
        $scope.CustomerModal.isFeildDisplay = function(fieldLabel) {
            for (i = 0; i < $scope.CustomerModal.PrimaryFields.length; i++) {
                if ($scope.CustomerModal.PrimaryFields.label == fieldLabel) {
                    return true;
                }
            }
            return false;
        }
        $scope.CustomerModal.AddSimilarCustomer = function() {
            $scope.selectedObject.coHeaderId = $stateParams.Id;
            if ($scope.selectedObject.coHeaderId == undefined) {
                $scope.selectedObject.coHeaderId = '';
            }
            addEditCustomerService.addCustomer($scope.selectedObject.coHeaderId, $scope.CustomerModal.SimilarCustomerSelect.Value).then(function(sucessCustomerResult) {
                $scope.CustomerModal.ReturnCustomerDetails($scope.CustomerModal.SimilarCustomerSelect.Value, $scope.CustomerModal.SimilarCustomerSelect.Name);
                $scope.selectedObject.ChangeRecords = 0;
                angular.element('#pop').modal('hide');
                hideModelWindow();
                loadState($state, 'CustomerOrder', {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.CustomerModal.ReturnCustomerDetails = function(value, Name) {
            var Customer = {
                Name: Name,
                Value: value
            }
            $scope.$emit('ReturnCustomer', Customer);
        }
        $scope.CustomerModal.OnFocus = function(targetId) {
            angular.element('.controls').hide();
            angular.element('#' + targetId).show();
        }
        $scope.CustomerModal.OnBlurVin = function(value) {
            $scope.CustomerModal.getSimilarCOUs(value);
        }
        $scope.CustomerModal.ClearAndRemoveField = function(fieldrel, targetIdToFocus) {
            var fieldsToClearOrRemove = $scope.CustomerModal.ManageIconCustomerDetails[0][fieldrel];
            if (fieldsToClearOrRemove.isPrimary == true) {
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    var key = fieldsToClearOrRemove.value[i].val;
                    if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                        $scope.CustomerModal.CustomerInfo[key] = "";
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                        $scope.CustomerModal.CustomerInfo[key] = false;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                        $scope.CustomerModal.CustomerInfo[key] = null;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'dropdown') {}
                    if (fieldrel == 'CountryState') {
                        $scope.CustomerModal.SetDafaultBillingCountry();
                        $scope.CustomerModal.SetDafaultBillingState();
                    } else if (fieldrel == 'ShippingCountryState') {
                        $scope.CustomerModal.SetDafaultShippingCountry();
                        $scope.CustomerModal.SetDafaultShippingState();
                    } else if (fieldrel == 'CityPostal') { 
                        $scope.CustomerModal.SetDafaultBillingCountry();
                        $scope.CustomerModal.SetDafaultBillingState();
                    } else if (fieldrel == 'CityPostalShipping') { 
                        $scope.CustomerModal.SetDafaultShippingCountry();
                        $scope.CustomerModal.SetDafaultShippingState();
                    }
                }
            } else {
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    var key = fieldsToClearOrRemove.value[i].val;
                    if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                        $scope.CustomerModal.CustomerInfo[key] = "";
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                        $scope.CustomerModal.CustomerInfo[key] = false;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                        $scope.CustomerModal.CustomerInfo[key] = null;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'dropdown') {
                        //FIXME
                    }
                    if (fieldrel == 'PriceLevel') {
                        $scope.CustomerModal.SetDafaultPriceLevel();
                    } else if (fieldrel == 'TaxLevel') {
                        $scope.CustomerModal.SetDafaultSalesTax();
                    } else if (fieldrel == 'Birthdate') {
                        $scope.CustomerModal.SetDefaultBirthday();
                    } else if (fieldrel == 'IsVendor') {
                        $scope.CustomerModal.SetDafaultPurchaseTax();
                    }
                    $scope.CustomerModal.AdditionalFieldsInfo[key].isPrimary = false;
                }
            }
            angular.element('#' + targetIdToFocus).focus();
        }
        $scope.CustomerModal.ClearAndRemoveSectionField = function(index, fieldrel, fieldId) {
            if (index == 0) {
                var fieldsToClearOrRemove = $scope.CustomerModal.ManageIconCustomerDetails[0][fieldrel];
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                        var key = fieldsToClearOrRemove.value[i].val;
                        if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                            $scope.CustomerModal.CustumerUnitModal[0][key] = "";
                        } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                            $scope.CustomerModal.CustumerUnitModal[0][key] = false;
                        } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                            $scope.CustomerModal.CustumerUnitModal[0][key] = null;
                        } else if (fieldsToClearOrRemove.value[i].fieldType == 'dropdown') {
                            //FIXME
                        }
                        if (fieldrel == 'CustomerUnitMakeModel') {
                            $scope.CustomerModal.UnitMakeSelected[0] = {};
                            $scope.CustomerModal.UnitModelSelected[0] = {};
                            $scope.CustomerModal.UnitSubModelSelected[0] = {};
                            $scope.CustomerModal.UnitModel[0] = [];
                            $scope.CustomerModal.UnitSubModel[0] = [];
                            $scope.CustomerModal.FilterSearchMake[0] = '';
                            $scope.CustomerModal.FilterSearchUnitModel[0] = '';
                            $scope.CustomerModal.FilterSearchUnitSubModel[0] = '';
                        } else if (fieldrel == 'CustomerUnitSubModelYear') {
                            $scope.CustomerModal.UnitYearSelected[0] = {};
                            $scope.CustomerModal.UnitSubModelSelected[0] = {};
                            $scope.CustomerModal.FilterSearchUnitSubModel[0] = '';
                        }
                    }
                    angular.element('#' + fieldId).focus();
                }
            } else {
                if (fieldrel == 'CustomerUnitLicensePlate') {
                    $scope.CustomerModal.CustumerUnitModal.Plate = "";
                    $scope.CustomerModal.CustumerUnitModal.RegExpiryDate = "";
                }
                $scope.CustomerModal.CustumerUnitModal.splice(index, 1);
                $scope.CustomerModal.UnitMakeSelected.splice(index, 1);
                $scope.CustomerModal.UnitModel.splice(index, 1);
                $scope.CustomerModal.CustomerValidationCOU.splice(index, 1);
            }
        }
        $scope.CustomerModal.getOtherSimilarCustomer = function() {
            var SimilarCustomerJson = {};
            angular.copy($scope.CustomerModal.CustomerInfo, SimilarCustomerJson);
            if (SimilarCustomerJson['Type'] == 'Individual') {
                SimilarCustomerJson['BusinessName'] = "";
                SimilarCustomerJson['WorkEmail'] = "";
                SimilarCustomerJson['WorkNumber'] = "";
            } else {
                SimilarCustomerJson['LastName'] = "";
                SimilarCustomerJson['HomeEmail'] = "";
                SimilarCustomerJson['HomeNumber'] = "";
            }
            addEditCustomerService.getOtherSimilarCustomer(JSON.stringify(SimilarCustomerJson)).then(function(SimilarCustomer) {
                $scope.CustomerModal.SimilarCustomers = SimilarCustomer;
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.CustomerModal.getSimilarCOUs = function(Vin) {
            addEditCustomerService.getSimilarCOUs(Vin).then(function(SimilarCOU) {
                $scope.CustomerModal.SimilarCOU = SimilarCOU;
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.CustomerModal.validatePhone = function() {
            $scope.CustomerModal.validateForm('HomeNumber');
            $scope.CustomerModal.validateForm('OtherPhone');
            $scope.CustomerModal.validateForm('WorkNumber');
        }
        $scope.CustomerModal.validateForm = function(modelKey) {
            var validationObj = $scope.CustomerModal.CustomerValidation[modelKey];
            if (($scope.CustomerModal.SelectedCountry.CountryName == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
                validationObj.Minlength = 8;
            } else if (validationObj.Type.indexOf('phone') > -1) {
                validationObj.Minlength = 10;
            }
            var isError = false;
            var ErrorMessage = '';
            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            var postalCodeRegEx = /^[a-zA-Z\d\s\-]+$/;
            var nameRegEx = /^[a-zA-Z\d\s]+$/;
            var validateType = validationObj.Type;
            if (validateType.indexOf('Minlength') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && $scope.CustomerModal.CustomerInfo[modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = $Label.Min_Length_Should_Be + ' ' + validationObj.Minlength;
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && $scope.CustomerModal.CustomerInfo[modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = $Label.Max_Length_Should_Be + ' ' + validationObj.Maxlength;
                }
            }
            if (validateType.indexOf('phone') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && !phoneRegEx.test($scope.CustomerModal.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $Label.Label_Invalid + ' ' + $Label.Label_Phone_Number;
                }
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && $scope.CustomerModal.CustomerInfo[modelKey].length == 9 && ($scope.CustomerModal.SelectedCountry.CountryName == 'Australia')) {
                    isError = true;
                    ErrorMessage = $Label.Min_Length_Should_Be + ' ' + '8 or 10';
                }
            }
            if (validateType.indexOf('email') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && !emailRegEx.test($scope.CustomerModal.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $Label.Label_Invalid + ' ' + $Label.Label_Email;
                }
            }
            if (validateType.indexOf('PostalCode') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] != undefined && $scope.CustomerModal.CustomerInfo[modelKey] != '' && !postalCodeRegEx.test($scope.CustomerModal.CustomerInfo[modelKey])) {
                    isError = true;
                    ErrorMessage = $Label.Label_Invalid + ' ' + $Label.Label_Postal;
                }
            }
            if (validateType.indexOf('required') > -1) {
                if ($scope.CustomerModal.CustomerInfo[modelKey] == undefined || $scope.CustomerModal.CustomerInfo[modelKey] == '') {
                    isError = true;
                    ErrorMessage = $Label.Field_Is_Required;
                }
            }
            $scope.CustomerModal.CustomerValidation[modelKey]['isError'] = isError;
            $scope.CustomerModal.CustomerValidation[modelKey]['ErrorMessage'] = ErrorMessage;
        }
        $scope.CustomerModal.ValidateCou = function(index, modelKey) {
            angular.element('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
            var fieldValue = '';
            if (modelKey == 'Make') {
                fieldValue = $scope.CustomerModal.FilterSearchMake[index];
            } else if (modelKey == 'Model') {
                fieldValue = $scope.CustomerModal.FilterSearchUnitModel[index];
            } else if (modelKey == 'SubModel') {
                fieldValue = $scope.CustomerModal.FilterSearchUnitSubModel[index];
            } else {
                fieldValue = $scope.CustomerModal.CustumerUnitModal[index][modelKey];
            }
            var numericRegex = /^[0-9]*$/;
            var ValidateType = $scope.CustomerModal.CustomerValidationCOU[index][modelKey].Type;
            if (ValidateType.indexOf('VIN') > -1) {
                if (fieldValue != '' && fieldValue != undefined) {
                    result = $scope.CustomerModal.validateVin(fieldValue);
                } else {
                    result = true;
                }
                if (result == false) {
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = true;
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = $Label.Label_Invalid + ' Vin No';
                } else {
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = false;
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = '';
                }
            }
            if (ValidateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && isNaN(fieldValue)) {
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = true;
                } else {
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = false;
                    $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = '';
                }
            }
            if (($scope.CustomerModal.CustumerUnitModal[index]['VIN'] != null && $scope.CustomerModal.CustumerUnitModal[index]['VIN'] != '' && $scope.CustomerModal.CustumerUnitModal[index]['VIN'] != undefined) || ($scope.CustomerModal.FilterSearchMake[index] != null && $scope.CustomerModal.FilterSearchMake[index] != '' && $scope.CustomerModal.FilterSearchMake[index] != undefined) || ($scope.CustomerModal.FilterSearchUnitModel[index] != null && $scope.CustomerModal.FilterSearchUnitModel[index] != '' && $scope.CustomerModal.FilterSearchUnitModel[index] != undefined) || ($scope.CustomerModal.FilterSearchUnitSubModel[index] != null && $scope.CustomerModal.FilterSearchUnitSubModel[index] != '' && $scope.CustomerModal.FilterSearchUnitSubModel[index] != undefined) || ($scope.CustomerModal.CustumerUnitModal[index]['Plate'] != null && $scope.CustomerModal.CustumerUnitModal[index]['Plate'] != '' && $scope.CustomerModal.CustumerUnitModal[index]['Plate'] != undefined) || ($scope.CustomerModal.CustumerUnitModal[index]['Color'] != null && $scope.CustomerModal.CustumerUnitModal[index]['Color'] != '' && $scope.CustomerModal.CustumerUnitModal[index]['Color'] != undefined) || ($scope.CustomerModal.CustumerUnitModal[index]['Year'] != null && $scope.CustomerModal.CustumerUnitModal[index]['Year'] != '' && $scope.CustomerModal.CustumerUnitModal[index]['Year'] != undefined)) {
                if (ValidateType.indexOf('Required') > -1) {
                    if (fieldValue == undefined || fieldValue == '' || fieldValue == null) {
                        $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = true;
                        $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = 'Field is Required';
                    } else {
                        $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = false;
                        $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = '';
                    }
                }
            } else {
                $scope.CustomerModal.CustomerValidationCOU[index][modelKey].isError = false;
                $scope.CustomerModal.CustomerValidationCOU[index][modelKey].ErrorMessage = ''
            }
        };
        // VIN Code validator
        $scope.CustomerModal.validateVin = function(vin) {
            if (vin.trim().length != 17) {
                return true;
            }
            // Reject based on bad pattern match
            no_ioq = '[a-hj-npr-z0-9]'; // Don't allow characters I,O or Q
            matcher = new RegExp("^" + no_ioq + "{8}[0-9xX]" + no_ioq + "{8}$", 'i'); // Case insensitive
            if (vin.match(matcher) == null) {
                return false;
            }
            // Reject base on bad check digit
            return $scope.CustomerModal.checkDigitCalculation(vin);
        };
        $scope.CustomerModal.checkDigitCalculation = function(vin) {
            var upperCaseVin = vin.toUpperCase();
            var letterMap = {
                A: 1,
                B: 2,
                C: 3,
                D: 4,
                E: 5,
                F: 6,
                G: 7,
                H: 8,
                J: 1,
                K: 2,
                L: 3,
                M: 4,
                N: 5,
                P: 7,
                R: 9,
                S: 2,
                T: 3,
                U: 4,
                V: 5,
                W: 6,
                X: 7,
                Y: 8,
                Z: 9,
                1: 1,
                2: 2,
                3: 3,
                4: 4,
                5: 5,
                6: 6,
                7: 7,
                8: 8,
                9: 9,
                0: 0
            };
            var weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
            var products = 0;
            for (var i = 0; i < upperCaseVin.length; i++) {
                products += letterMap[upperCaseVin[i]] * weights[i];
            }
            var checkDigitShouldBe = products % 11;
            if (checkDigitShouldBe == 10) {
                checkDigitShouldBe = 'X';
            }
            return checkDigitShouldBe == upperCaseVin[8];
        }
        //Modals
        $scope.CustomerModal.ManageIconCustomerDetails = [{
            FnameLname: {
                value: [{
                    val: 'FirstName',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            NickName: {
                value: [{
                    val: 'Nickname',
                    fieldType: 'text'
                }, {
                    val: 'LastName',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            BusinessName: {
                value: [{
                    val: 'BusinessName',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            CompanyName: {
                value: [{
                    val: 'CompanyName',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            HomeEmail: {
                value: [{
                    val: 'HomeEmail',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            WorkEmail: {
                value: [{
                    val: 'WorkEmail',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            HomePhone: {
                value: [{
                    val: 'HomeNumber',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            WorkPhone: {
                value: [{
                    val: 'WorkNumber',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            BillingAddLine1: {
                value: [{
                    val: 'BillingStreet1',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            BillingAddLine2: {
                value: [{
                    val: 'BillingStreet2',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            ShippingAddLine1: {
                value: [{
                    val: 'ShippingStreet1',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            ShippingAddLine2: {
                value: [{
                    val: 'ShippingStreet2',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            CountryState: {
                value: [{
                    val: 'BillingCity',
                    fieldType: 'text'
                }, {
                    val: 'BillingState',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            ShippingCountryState: {
                value: [{
                    val: 'ShippingCity',
                    fieldType: 'text'
                }, {
                    val: 'ShippingState',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            CityPostal: {
                value: [{
                    val: 'BillingPostalCode',
                    fieldType: 'text'
                }, {
                    val: 'BillingCountry',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            CityPostalShipping: {
                value: [{
                    val: 'ShippingPostalCode',
                    fieldType: 'text'
                }, {
                    val: 'ShippingCountry',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            Birthdate: {
                value: [{
                    val: 'Birthdate',
                    fieldType: 'dropdown'
                }],
                isPrimary: false
            },
            LinkedInLink: {
                value: [{
                    val: 'LinkedInLink',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            TwitterLink: {
                value: [{
                    val: 'TwitterLink',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            FacebookLink: {
                value: [{
                    val: 'FacebookLink',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            Company: {
                value: [{
                    val: 'Company',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            DriversLicense: {
                value: [{
                    val: 'DriversLicense',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            JobTitle: {
                value: [{
                    val: 'JobTitle',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            PriceLevel: {
                value: [{
                    val: 'PriceLevel',
                    fieldType: 'lookup'
                }],
                isPrimary: false
            },
            AccountType: {
                value: [{
                    val: 'AccountType',
                    fieldType: 'lookup'
                }],
                isPrimary: false
            },
            TaxLevel: {
                value: [{
                    val: 'TaxLevel',
                    fieldType: 'lookup'
                }],
                isPrimary: false
            },
            OtherPhone: {
                value: [{
                    val: 'OtherPhone',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            OtherEmail: {
                value: [{
                    val: 'OtherEmail',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            IsVendor: {
                value: [{
                    val: 'IsVendor',
                    fieldType: 'boolean'
                }],
                isPrimary: false
            },
            Active: {
                value: [{
                    val: 'Active',
                    fieldType: 'boolean'
                }],
                isPrimary: false
            },
            CustomerUnitMakeModel: {
                value: [{
                    val: 'Make',
                    fieldType: 'lookup'
                }, {
                    val: 'Model',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            CustomerUnitSubModelYear: {
                value: [{
                    val: 'Submodel',
                    fieldType: 'lookup'
                }, {
                    val: 'Year',
                    fieldType: 'lookup'
                }],
                isPrimary: true
            },
            CustomerUnitModelVin: {
                value: [{
                    val: 'VIN',
                    fieldType: 'text'
                }],
                isPrimary: false
            },
            CustomerUnitLicensePlate: {
                value: [{
                    val: 'Plate',
                    fieldType: 'text'
                }, {
                    val: 'RegExpiryDate',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            CustomerUnitMilage: {
                value: [{
                    val: 'Mileage',
                    fieldType: 'text'
                }],
                isPrimary: true
            },
            customerUnitColor: {
                value: [{
                    val: 'Color',
                    fieldType: 'text'
                }],
                isPrimary: true
            }
        }];
        $scope.CustomerModal.AdditionalFieldsSearch = '';
        $scope.CustomerModal.ChangeCustomerType = function(CustomerType) {
            $scope.CustomerModal.CustomerInfo.Type = CustomerType;
        }
        $scope.FilterAdditionalFields = function(items) {
            var result = {};
            angular.forEach(items, function(value, key) {
                if (value.label.toLowerCase().indexOf($scope.CustomerModal.AdditionalFieldsSearch) != -1) {
                    result[key] = value;
                }
            });
            return result;
        }
        $scope.CustomerModal.ShowAdditionalField = function(key) {
            if (key == 'CustomerUnit') {
                var unit = {
                    Year: null,
                    Make: null,
                    Model: null,
                    SubModel: null,
                    VIN: '',
                    Plate: '',
                    Mileage: null,
                    Color: ''
                };
                $scope.CustomerModal.CustumerUnitModal.push(unit);
                var validation = {
                    VIN: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'VIN,Required'
                    },
                    Mileage: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Numeric'
                    },
                    Make: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required'
                    },
                    Model: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required'
                    }
                };
                $scope.CustomerModal.CustomerValidationCOU.push(validation);
            } else {
                $scope.CustomerModal.AdditionalFieldsInfo[key].isPrimary = true;
            }
            var targetId = $scope.CustomerModal.AdditionalFieldsInfo[key].fieldId;
            if (key == 'CustomerUnit') {
                var Id = ($scope.CustomerModal.CustumerUnitModal.length - 1);
                var targetid = 'vinId' + Id;
                setTimeout(function() {
                    if (targetid != undefined) {
                        angular.element('#' + targetid).focus();
                    }
                }, 10);
                angular.element('.dropdown-menu').removeClass("keep_open");
            } else {
                if (key == 'FacebookLink') {
                    $scope.CustomerModal.CustomerInfo.FacebookLink = "https://www.facebook.com/";
                } else if (key == 'LinkedInLink') {
                    $scope.CustomerModal.CustomerInfo.LinkedInLink = "https://www.LinkedIn.com/";
                } else if (key == 'TwitterLink') {
                    $scope.CustomerModal.CustomerInfo.TwitterLink = "https://www.Twitter.com/";
                }
                setTimeout(function() {
                    if (targetId != undefined) {
                        angular.element('#' + targetId).focus();
                    }
                }, 10);
            }
        }
        $scope.CustomerModal.ChangeMonth = function() {
            if ($scope.CustomerModal.BirthyearSelected.year != 'undefined' && $scope.CustomerModal.BirthyearSelected.year != '' && $scope.CustomerModal.BirthyearSelected.year != null) {
                $scope.CustomerModal.BirthDays = [];
                $scope.CustomerModal.BirthDaySelected = {};
                var month = parseInt($scope.CustomerModal.BirthmonthSelected) - 1;
                var year = parseInt($scope.CustomerModal.BirthyearSelected.year);
                var monthStart = new Date(year, month, 1);
                var monthEnd = new Date(year, month + 1, 1);
                var monthLength = (monthEnd - monthStart) / (1000 * 60 * 60 * 24);
                for (i = 1; i < monthLength + 1; i++) {
                    var days = {
                        day: i
                    };
                    $scope.CustomerModal.BirthDays.push(days);
                }
            }
        }
        $scope.CustomerModal.ChangeYear = function() {
            if (($scope.CustomerModal.BirthmothSelected != 'undefined') && ($scope.CustomerModal.BirthmothSelected != '-1')) {
                $scope.CustomerModal.BirthDays = [];
                $scope.CustomerModal.BirthDaySelected = {};
                var month = parseInt($scope.CustomerModal.BirthmonthSelected) - 1;
                var year = parseInt($scope.CustomerModal.BirthyearSelected.year);
                var monthStart = new Date(year, month, 1);
                var monthEnd = new Date(year, month + 1, 1);
                var monthLength = (monthEnd - monthStart) / (1000 * 60 * 60 * 24);
                for (i = 1; i < monthLength + 1; i++) {
                    var days = {
                        day: i
                    };
                    $scope.CustomerModal.BirthDays.push(days);
                }
            }
        }
        $scope.$on('autoCompleteSelectCallback', function(event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            var Index = args.Index
            if (Index != null) {
                var automcompletevalue = Index.split('_');
                var indexvar = automcompletevalue[1];
                if (searchResult != null && searchResult.originalObject.Info == 'Unit') {
                    $scope.CustomerModal.UnitMakeSelected[indexvar] = {};
                    $scope.CustomerModal.UnitMakeSelected[indexvar] = {
                        Id: searchResult.originalObject.Value,
                        UnitMakeName: searchResult.originalObject.Name
                    }
                    $scope.CustomerModal.changeUnitMake(indexvar);
                    return;
                } else if (searchResult != null && searchResult.originalObject.Info == 'UnitModel') {
                    $scope.CustomerModal.UnitModelSelected[indexvar] = {};
                    $scope.CustomerModal.UnitModelSelected[indexvar] = {
                        Id: searchResult.originalObject.Value,
                        UnitModelName: searchResult.originalObject.Name
                    }
                    $scope.CustomerModal.changeUnitmodel(indexvar);
                    return;
                } else if (searchResult != null && searchResult.originalObject.Info) {
                    if (searchResult.originalObject.Info.indexOf("Unit_Model__c") > -1) {
                        $scope.CustomerModal.UnitSubModelSelected[indexvar] = {};
                        $scope.CustomerModal.UnitSubModelSelected[indexvar] = {
                            Id: searchResult.originalObject.Value,
                            SubModelName: searchResult.originalObject.Name
                        }
                        $scope.CustomerModal.CustumerUnitModal[indexvar].Model = $scope.CustomerModal.UnitSubModelSelected[indexvar].Id;
                        $scope.CustomerModal.CustumerUnitModal[indexvar].SubModel = $scope.CustomerModal.UnitSubModelSelected[indexvar].Id;
                        $scope.CustomerModal.CustumerUnitModal[indexvar].SubModelName = $scope.CustomerModal.UnitSubModelSelected[indexvar].SubModelName;
                    }
                    return;
                }
                if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNIT') {
                    if (($scope.CustomerModal.UnitMakeSelected[indexvar] != null && $scope.CustomerModal.UnitMakeNameStr[indexvar] != $scope.CustomerModal.UnitMakeSelected[indexvar].UnitMakeName) || $scope.CustomerModal.UnitMakeNameStr[indexvar] == null || $scope.CustomerModal.UnitMakeNameStr[indexvar] == "" || $scope.CustomerModal.UnitMakeSelected[indexvar] == null) {
                        $scope.CustomerModal.UnitMakeSelected[indexvar] = null;
                        $scope.CustomerModal.UnitModelSelected[indexvar] = null;
                        $scope.CustomerModal.UnitSubModelSelected[indexvar] = null;
                        $scope.CustomerModal.UnitMakeNameStr[indexvar] = "";
                        $scope.CustomerModal.UnitSubModelNameStr[indexvar] = "";
                        $scope.CustomerModal.UnitModelNameStr[indexvar] = "";
                    }
                    return;
                } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITMODEL') {
                    if (($scope.CustomerModal.UnitModelSelected[indexvar] != null && $scope.CustomerModal.UnitModelNameStr[indexvar] != $scope.CustomerModal.UnitModelSelected[indexvar].UnitModelName) || $scope.CustomerModal.UnitModelNameStr[indexvar] == null || $scope.CustomerModal.UnitModelNameStr[indexvar] == "" || $scope.CustomerModal.UnitModelSelected[indexvar] == null) {
                        $scope.CustomerModal.UnitModelSelected[indexvar] = null;
                        $scope.CustomerModal.UnitSubModelSelected[indexvar] = null;
                        $scope.CustomerModal.UnitSubModelNameStr[indexvar] = "";
                        $scope.CustomerModal.UnitModelNameStr[indexvar] = "";
                    }
                    return;
                } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITSUBMODEL') {
                    if (($scope.CustomerModal.UnitSubModelSelected[indexvar] != null && $scope.CustomerModal.UnitSubModelNameStr[indexvar] != $scope.CustomerModal.UnitSubModelSelected[indexvar].SubModelName) || $scope.CustomerModal.UnitSubModelNameStr[indexvar] == null || $scope.CustomerModal.UnitSubModelNameStr[indexvar] == "" || $scope.CustomerModal.UnitSubModelSelected[indexvar] == null) {
                        $scope.CustomerModal.UnitSubModelSelected[indexvar] = null;
                        $scope.CustomerModal.UnitSubModelNameStr = "";
                    }
                    return;
                }
            }
        });
        $scope.CustomerModal.changeUnitMake = function(index, make, event) {
            $scope.CustomerModal.saveUnitMakeBlur[index] = 1;
            $scope.CustomerModal.UnitMakeSelected[index] = make;
            $scope.CustomerModal.FilterSearchMake[index] = make.UnitMakeName;
            $scope.CustomerModal.CustumerUnitModal[index].Make = $scope.CustomerModal.UnitMakeSelected[index].Id;
            $scope.CustomerModal.UnitModelSelected[index] = {};
            $scope.CustomerModal.CustumerUnitModal[index].SubModel = null;
            $scope.CustomerModal.UnitSubModelSelected[index] = {};
            $scope.CustomerModal.CustumerUnitModal[index].Model = null;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            $scope.CustomerModal.UnitModelNameStr[index] = '';
            $scope.CustomerModal.UnitSubModelNameStr[index] = '';
            $scope.CustomerModal.CustumerUnitModal[index].Model = null;
            $scope.CustomerModal.CustumerUnitModal[index].SubModelName = null;
            $scope.CustomerModal.FilterSearchUnitModel[index] = '';
            $scope.CustomerModal.FilterSearchUnitSubModel[index] = '';
            $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = '';
            $scope.CustomerModal.saveUnitMakeBlur[index] = 0;
        }
        $scope.CustomerModal.changeUnitYear = function(index) {
            if (typeof $scope.CustomerModal.UnitYearSelected[index].modelyear == 'undefined') {
                $scope.CustomerModal.CustumerUnitModal[index].Year = null;
            } else {
                $scope.CustomerModal.CustumerUnitModal[index].Year = $scope.CustomerModal.UnitYearSelected[index].modelyear;
            }
        }
        $scope.CustomerModal.changeUnitmodel = function(index, model, event) {
            $scope.CustomerModal.saveUnitModelBlur[index] = 1; 
            $scope.CustomerModal.FilterSearchUnitModel[index] = model.UnitModelName;
            $scope.CustomerModal.UnitModelSelected[index] = model;
            $scope.CustomerModal.CustumerUnitModal[index].Model = $scope.CustomerModal.UnitModelSelected[index].Id;
            $scope.CustomerModal.UnitSubModel[index] = null;
            $scope.CustomerModal.CustumerUnitModal[index].SubModelName = null;
            $scope.CustomerModal.FilterSearchUnitSubModel[index] = '';
            $scope.CustomerModal.UnitSubModelNameStr[index] = '';
            $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = '';
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            $scope.CustomerModal.saveUnitModelBlur[index] = 0;
        }
        $scope.CustomerModal.changeUnitSubmodel = function(index, model, event) {
            $scope.CustomerModal.saveUnitSubModelBlur[index] = 1;
            $scope.CustomerModal.UnitSubModelSelected[index] = model;
            $scope.CustomerModal.FilterSearchUnitSubModel[index] = model.SubModelName;
            $scope.CustomerModal.CustumerUnitModal[index].SubModel = $scope.CustomerModal.UnitSubModelSelected[index].Id;
            $scope.CustomerModal.CustumerUnitModal[index].SubModelName = $scope.CustomerModal.UnitSubModelSelected[index].SubModelName;
            $scope.CustomerModal.saveUnitSubModelBlur[index] = 0;
            $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = $scope.CustomerModal.UnitSubModelSelected[index].SubmodelDescription; 
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }
        // Make Select Enter
        $scope.CustomerModal.ChangeSeletedUnitMake = function(event, index) {
            if (!angular.isDefined($scope.CustomerModal.CurrentIndexMake[index])) {
                $scope.CustomerModal.CurrentIndexMake[index] = {
                    CurrentIndexMake: -1
                }
            }
            if (event.which === 40) {
                $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake++;
            } else if (event.which === 38) {
                if ($scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake >= 1) {
                    $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake--;
                }
            } else if (event.which === 13) {
                var CurrentIndexVal = $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake;
                var CurrentIndexMakeVal = $scope.CustomerModal.filteredItemsMake[index][CurrentIndexVal];
                $scope.CustomerModal.changeUnitMake(index, CurrentIndexMakeVal, event);
                $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake = -1;
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.CustomerModal.filteredItemsMake[index] == undefined || $scope.CustomerModal.filteredItemsMake[index].length == 0 || $scope.CustomerModal.FilterSearchMake[index] == undefined) {
                    $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake = -1
                    return;
                }
                if (angular.lowercase($scope.CustomerModal.filteredItemsMake[index][0].UnitMakeName).trim() == angular.lowercase($scope.CustomerModal.FilterSearchMake[index]).trim()) {
                    $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake = 0;
                } else {
                    $scope.CustomerModal.CurrentIndexMake[index].CurrentIndexMake = -1
                }
            }
        }
        $scope.CustomerModal.ChangeSeletedUnitModel = function(event, index) {
            if (!angular.isDefined($scope.CustomerModal.CurrentIndexUnitModel[index])) {
                $scope.CustomerModal.CurrentIndexUnitModel[index] = {
                    CurrentIndexUnitModel: -1
                }
            }
            if (event.which === 40) {
                $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel++;
            } else if (event.which === 38) {
                if ($scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel >= 1) {
                    $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel--;
                }
            } else if (event.which === 13) {
                var CurrentIndexVal = $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel;
                var CurrentIndexUnitModelVal = $scope.CustomerModal.filteredItemsModel[index][CurrentIndexVal];
                $scope.CustomerModal.filteredItemsModel = {}; 
                $scope.CustomerModal.changeUnitmodel(index, CurrentIndexUnitModelVal, event);
                $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) { 
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.CustomerModal.filteredItemsModel[index] == undefined || $scope.CustomerModal.filteredItemsModel[index].length == 0 || $scope.CustomerModal.FilterSearchUnitModel[index] == undefined) {
                    $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel = -1;
                    return;
                }
                if (angular.lowercase($scope.CustomerModal.filteredItemsModel[index][0].UnitModelName).trim() == angular.lowercase($scope.CustomerModal.FilterSearchUnitModel[index]).trim()) {
                    $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel = 0;
                } else {
                    $scope.CustomerModal.CurrentIndexUnitModel[index].CurrentIndexUnitModel = -1
                }
            }
        }
        $scope.CustomerModal.ChangeSeletedUnitSubModel = function(event, index) {
            if (!angular.isDefined($scope.CustomerModal.CurrentIndexUnitSubModel[index])) {
                $scope.CustomerModal.CurrentIndexUnitSubModel[index] = {
                    CurrentIndexUnitSubModel: -1
                }
            }
            if (event.which === 40) {
                $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel++;
            } else if (event.which === 38) {
                if ($scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel >= 1) {
                    $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel--;
                }
            } else if (event.which === 13) {
                var CurrentIndexVal = $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel;
                var CurrentIndexMakeVal = $scope.CustomerModal.filteredItemsSubModel[index][CurrentIndexVal];
                $scope.CustomerModal.changeUnitSubmodel(index, CurrentIndexMakeVal, event);
                $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) { 
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.CustomerModal.filteredItemsSubModel[index] == undefined || $scope.CustomerModal.filteredItemsSubModel[index].length == 0 || $scope.CustomerModal.FilterSearchUnitSubModel[index] == undefined) {
                    $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel = -1;
                    return;
                }
                if (angular.lowercase($scope.CustomerModal.filteredItemsSubModel[index][0].SubModelName).trim() == angular.lowercase($scope.CustomerModal.FilterSearchUnitSubModel[index]).trim()) {
                    $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel = 0;
                } else {
                    $scope.CustomerModal.CurrentIndexUnitSubModel[index].CurrentIndexUnitSubModel = -1;
                }
            }
        }
        $scope.CustomerModal.saveUnitModel = function(index, event) {
            if ($scope.CustomerModal.saveUnitModelBlur[index] == 0 || $scope.CustomerModal.saveUnitModelBlur[index] == undefined) { 
                if ($scope.CustomerModal.CustumerUnitModal[index].ModelName != $scope.CustomerModal.FilterSearchUnitModel[index]) { 
                    $scope.CustomerModal.CustumerUnitModal[index].SubModel = null;
                    $scope.CustomerModal.CustumerUnitModal[index].SubModelName = '';
                    $scope.CustomerModal.FilterSearchUnitSubModel[index] = '';
                    $scope.CustomerModal.filteredItemsSubModel[index] = '';
                    $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = '';
                }
                var isModelAlreadyExist = false;
                if ($scope.CustomerModal.UnitModel[index] != null) {
                    for (var i = 0; i < $scope.CustomerModal.UnitModel[index].length; i++) { 
                        if ($scope.CustomerModal.UnitModel[index][i].UnitModelName == $scope.CustomerModal.FilterSearchUnitModel[index]) { 
                            $scope.CustomerModal.CustumerUnitModal[index].Model = $scope.CustomerModal.UnitModel[index][i].Id; 
                            $scope.CustomerModal.CustumerUnitModal[index].ModelName = $scope.CustomerModal.UnitModel[index][i].UnitModelName; 
                            isModelAlreadyExist = true;
                        }
                    }
                }
                if (!isModelAlreadyExist) {
                    $scope.CustomerModal.CustumerUnitModal[index].ModelName = $scope.CustomerModal.FilterSearchUnitModel[index];
                    $scope.CustomerModal.CustumerUnitModal[index].Model = null;
                    $scope.CustomerModal.UnitModelSelected[index] = {}; 
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.CustomerModal.saveUnitModelBlur[index] = 0;
            }
        }
        $scope.CustomerModal.saveUnitMake = function(index, event) {
            if ($scope.CustomerModal.saveUnitMakeBlur[index] == 0 || $scope.CustomerModal.saveUnitMakeBlur[index] == undefined) { 
                if ($scope.CustomerModal.CustumerUnitModal[index].MakeName != $scope.CustomerModal.FilterSearchMake[index]) { 
                    $scope.CustomerModal.CustumerUnitModal[index].ModelName = '';
                    $scope.CustomerModal.CustumerUnitModal[index].Model = null;
                    $scope.CustomerModal.FilterSearchUnitModel[index] = '';
                    $scope.CustomerModal.CustumerUnitModal[index].SubModel = null;
                    $scope.CustomerModal.CustumerUnitModal[index].SubModelName = '';
                    $scope.CustomerModal.FilterSearchUnitSubModel[index] = '';
                    $scope.CustomerModal.filteredItemsSubModel[index] = '';
                    $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = '';
                }
                var isMakeAlreadyExist = false;
                if ($scope.CustomerModal.UnitMake[index] != null) {
                    for (var i = 0; i < $scope.CustomerModal.UnitMake[index].length; i++) { 
                        if ($scope.CustomerModal.UnitMake[index][i].UnitMakeName == $scope.CustomerModal.FilterSearchMake[index]) { 
                            $scope.CustomerModal.CustumerUnitModal[index].Make = $scope.CustomerModal.UnitMake[index][i].Id; 
                            $scope.CustomerModal.CustumerUnitModal[index].MakeName = $scope.CustomerModal.UnitMake[index][i].UnitMakeName; 
                            isMakeAlreadyExist = true;
                        }
                    }
                }
                if (!isMakeAlreadyExist) {
                    $scope.CustomerModal.CustumerUnitModal[index].MakeName = $scope.CustomerModal.FilterSearchMake[index];
                    $scope.CustomerModal.CustumerUnitModal[index].Make = null;
                    $scope.CustomerModal.UnitMakeSelected[index] = {}; 
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.CustomerModal.saveUnitMakeBlur[index] = 0;
            }
        }
        $scope.CustomerModal.saveUnitSubModel = function(index, event) {
            if ($scope.CustomerModal.saveUnitSubModelBlur[index] == 0 || $scope.CustomerModal.saveUnitSubModelBlur[index] == undefined) { 
                if ($scope.CustomerModal.CustumerUnitModal[index].SubModelName != $scope.CustomerModal.FilterSearchUnitSubModel[index]) { 
                    $scope.CustomerModal.CustumerUnitModal[index].MakeModelDescription = '';
                }
                var isSubModelAlreadyExist = false;
                if ($scope.CustomerModal.UnitSubModel[index] != null) {
                    for (var i = 0; i < $scope.CustomerModal.UnitSubModel[index].length; i++) { 
                        if ($scope.CustomerModal.UnitSubModel[index][i].SubModelName == $scope.CustomerModal.FilterSearchUnitSubModel[index]) { 
                            $scope.CustomerModal.CustumerUnitModal[index].SubModel = $scope.CustomerModal.UnitSubModel[index][i].Id; 
                            $scope.CustomerModal.CustumerUnitModal[index].SubModelName = $scope.CustomerModal.UnitSubModel[index][i].SubModelName; 
                            isSubModelAlreadyExist = true;
                        }
                    }
                }
                if (!isSubModelAlreadyExist) {
                    $scope.CustomerModal.CustumerUnitModal[index].SubModelName = $scope.CustomerModal.FilterSearchUnitSubModel[index];
                    $scope.CustomerModal.CustumerUnitModal[index].SubModel = null;
                    $scope.CustomerModal.UnitSubModelSelected[index] = {}; 
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.CustomerModal.saveUnitSubModelBlur[index] = 0;
            }
        }
        $scope.CustomerModal.getUnitmakeList = function(index, event) {
            event.preventDefault();
            angular.element('.controls').hide();
            angular.element('#CustomerUnitOptionalMakeModel' + index).show();
            addEditCustomerService.getUnitmakeList().then(function(sucessResultList) {
                $scope.CustomerModal.UnitMake[index] = sucessResultList;
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    if ($(".selectDropbox").hasClass("open") == true) {
                        setTimeout(function() {
                            $(".selectDropbox").removeClass("open");
                        }, 5);
                    }
                    angular.element(event.target).parent().addClass("open");
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.CustomerModal.showDatePicker = function(event) {
            angular.element(event.target).parent().parent().find("input").focus();
        }
        $scope.CustomerModal.getUnitModelList = function(index, event) {
            if ($scope.CustomerModal.UnitMakeSelected[index] == null || $scope.CustomerModal.UnitMakeSelected[index] == '' || $scope.CustomerModal.UnitMakeSelected[index].Id == undefined) {
                return;
            }
            angular.element('.controls').hide();
            angular.element('#CustomerUnitOptionalMakeModel' + index).show();
            addEditCustomerService.getUnitModelList($scope.CustomerModal.UnitMakeSelected[index].Id).then(function(sucessResultList) {
                $scope.CustomerModal.UnitModel[index] = sucessResultList;
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    if ($(".selectDropbox").hasClass("open") == true) {
                        setTimeout(function() {
                            $(".selectDropbox").removeClass("open");
                        }, 5);
                    }
                    angular.element(event.target).parent().addClass("open");
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
            });
        }
        $scope.CustomerModal.getUnitSubModelList = function(index, event) {
            if ($scope.CustomerModal.UnitMakeSelected[index] == null || $scope.CustomerModal.UnitMakeSelected[index] == '' || $scope.CustomerModal.UnitMakeSelected[index].Id == undefined) { 
                return;
            }
            if ($scope.CustomerModal.UnitModelSelected[index] == null || $scope.CustomerModal.UnitModelSelected[index] == '' || $scope.CustomerModal.UnitModelSelected[index].Id == undefined || $scope.CustomerModal.UnitModelSelected[index].Id == '') { 
                return;
            }
            angular.element('.controls').hide();
            angular.element('#CustomerUnitOptionalSubModelYear' + index).show();
            addEditCustomerService.getUnitSubModelList($scope.CustomerModal.UnitModelSelected[index].Id, $scope.CustomerModal.UnitMakeSelected[index].Id).then(function(sucessResultList) {
                $scope.CustomerModal.UnitSubModel[index] = sucessResultList;
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    if ($(".selectDropbox").hasClass("open") == true) {
                        setTimeout(function() {
                            $(".selectDropbox").removeClass("open");
                        }, 5);
                    }
                    angular.element(event.target).parent().addClass("open");
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.CustomerModal.SetCustomerActiveStatus = function(status) {
            if (status == false) {
                angular.element('#deactiveCustomerConfirm').show();
            } else {
                $scope.CustomerModal.CustomerInfo.Active = true;
            }
        }
        $scope.CustomerModal.DeactiveCustomer = function(status) {
            if (status == false) {
                angular.element('#deactiveCustomerConfirm').hide();
            } else {
                $scope.CustomerModal.CustomerInfo.Active = false;
                angular.element('#deactiveCustomerConfirm').hide();
            }
        }
        $scope.CustomerModal.SetVendorActive = function(status) {
            if ($scope.CustomerModal.isVendorFlag) {
                return;
            }
            $scope.CustomerModal.CustomerInfo['IsVendor'] = status;
            if ($scope.CustomerModal.CustomerInfo['IsVendor'] == true) {
                $scope.CustomerModal.SetDafaultPurchaseTax();
            }
        }
        $scope.CustomerModal.SetDafaultBillingCountry = function() {
            for (i = 0; i < $scope.CustomerModal.CustomerMasterData.CountryList.length; i++) {
                if ($scope.CustomerModal.CustomerMasterData.CountryList[i].IsDefault) {
                    $scope.CustomerModal.SelectedCountry = $scope.CustomerModal.CustomerMasterData.CountryList[i];
                }
            }
        }
        $scope.CustomerModal.SetDafaultBillingState = function() {
            $scope.CustomerModal.State = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedCountry.CountryName];
            var isDefaultState = false;
            for (i = 0; i < $scope.CustomerModal.State.length; i++) {
                if ($scope.CustomerModal.State[i].IsDefault) {
                    $scope.CustomerModal.SelectedState = $scope.CustomerModal.State[i];
                    isDefaultState = true;
                }
            }
            if (!isDefaultState) {
                $scope.CustomerModal.SelectedState = null;
            }
        }
        $scope.CustomerModal.SetDafaultShippingCountry = function() {
            for (i = 0; i < $scope.CustomerModal.CustomerMasterData.CountryList.length; i++) {
                if ($scope.CustomerModal.CustomerMasterData.CountryList[i].IsDefault) {
                    $scope.CustomerModal.SelectedShippingCountry = $scope.CustomerModal.CustomerMasterData.CountryList[i];
                }
            }
        }
        $scope.CustomerModal.SetDafaultShippingState = function() {
            $scope.CustomerModal.ShippingState = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedShippingCountry.CountryName];
            for (i = 0; i < $scope.CustomerModal.ShippingState.length; i++) {
                if ($scope.CustomerModal.State[i].IsDefault) {
                    $scope.CustomerModal.SelectedShippingState = $scope.CustomerModal.ShippingState[i];
                }
            }
        }
        $scope.CustomerModal.SetDafaultPriceLevel = function() {
            for (i = 0; i < $scope.CustomerModal.PriceLevel.length; i++) {
                if ($scope.CustomerModal.PriceLevel[i].IsDefault) {
                    $scope.CustomerModal.SelectedPriceLevel = $scope.CustomerModal.PriceLevel[i];
                }
            }
            
        }
        $scope.CustomerModal.SetDafaultSalesTax = function() {
            for (i = 0; i < $scope.CustomerModal.SalesTax.length; i++) {
                if ($scope.CustomerModal.SalesTax[i].IsDefault) {
                    $scope.CustomerModal.SelectedSalesTax = $scope.CustomerModal.SalesTax[i];
                }
            }
        }
        $scope.CustomerModal.SetDafaultPurchaseTax = function() {
            var defaultSalesTax;
        	for(i = 0; i < $scope.CustomerModal.SalesTax.length; i++) {
            	if($scope.CustomerModal.SalesTax[i].Id.substr(0,15) === $scope.CustomerModal.DefaultOrderingTaxId) {
                    $scope.CustomerModal.VendorSelectedSalesTax = $scope.CustomerModal.SalesTax[i];
                } else if($scope.CustomerModal.SalesTax[i].IsDefault){
                	defaultSalesTax = $scope.CustomerModal.SalesTax[i];
                } 
            }
            if(!$scope.CustomerModal.VendorSelectedSalesTax.Id) {
            	$scope.CustomerModal.VendorSelectedSalesTax = defaultSalesTax;
            }
        }
        $scope.CustomerModal.SetDefaultBirthday = function() {
            $scope.CustomerModal.BirthdaySelected = {};
            $scope.CustomerModal.BirthyearSelected = {};
            $scope.CustomerModal.BirthmonthSelected = "";
        }
        $scope.CustomerModal.LoadCustomerInfoDetail = function() {}
        $scope.CustomerModal.changeBillingCountry = function() {
            $scope.CustomerModal.State = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedCountry.CountryName];
            $scope.CustomerModal.SelectedState = $scope.CustomerModal.State[0];
        }
        $scope.CustomerModal.changeShippingCountry = function() {
            $scope.CustomerModal.ShippingState = $scope.CustomerModal.CustomerMasterData.StateList[0].countryNameToStateMap[$scope.CustomerModal.SelectedShippingCountry.CountryName];
            $scope.CustomerModal.SelectedShippingState = $scope.CustomerModal.ShippingState[0];
        }
        $scope.CustomerModal.changePriceLevel = function() {
            //FIXME
        }
        $scope.CustomerModal.changeAccountType = function(accountTypeRec) {
            $scope.CustomerModal.SelectedAccountType.AccountType = accountTypeRec.AccountType;
            $scope.CustomerModal.SelectedAccountType.AccountTypeId = accountTypeRec.Id;
        }
        $scope.CustomerModal.changeSalesTax = function() {
            //FIXME
        }
        $scope.CustomerModal.SetAddressData = function() {
            //set Default Country                                   
            $scope.CustomerModal.CustomerInfo.IsBothAddressSame = ($scope.CustomerModal.CustomerInfo.IsBothAddressSame == true) ? false : true;
            $scope.CustomerModal.CustomerInfo.ShippingStreet1 = $scope.CustomerModal.CustomerInfo.BillingStreet1;
            $scope.CustomerModal.CustomerInfo.ShippingStreet2 = $scope.CustomerModal.CustomerInfo.BillingStreet2;
            $scope.CustomerModal.CustomerInfo.ShippingCity = $scope.CustomerModal.CustomerInfo.BillingCity;
            $scope.CustomerModal.CustomerInfo.ShippingPostalCode = $scope.CustomerModal.CustomerInfo.BillingPostalCode;
            $scope.CustomerModal.ShippingState = $scope.CustomerModal.State;
            $scope.CustomerModal.SelectedShippingState = $scope.CustomerModal.SelectedState;
            $scope.CustomerModal.SelectedShippingCountry = $scope.CustomerModal.SelectedCountry;
            $scope.CustomerModal.ShippingState = $scope.CustomerModal.State;
            $scope.CustomerModal.SelectedShippingState = $scope.CustomerModal.SelectedState;
        }
        $scope.CustomerModal.CancelCustomer = function() {
            $scope.selectedObject.ChangeRecords = 0;
            angular.element('#pop').modal('hide');
            hideModelWindow();
            if ($scope.CustomerModal.isOpenFromSelectCustomerCustomer != undefined && $scope.CustomerModal.isOpenFromSelectCustomerCustomer != '') {
                setTimeout(function() {
                    var A_View_StateName;
                    var A_View_StateParams;
                    if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '') {
                        A_View_StateName = $stateParams.myParams.A_View_StateName;
                        A_View_StateParams = $stateParams.myParams.A_View_StateParams;
                    }
                    var selectCustomer_Json = {
                        type: $scope.CustomerModal.sellingType,
                        A_View_StateName: A_View_StateName,
                        A_View_StateParams: A_View_StateParams
                    };
                    if ($state.current.name === 'CashSaleCO.AddCustomer') {
                        selectCustomer_Json['COHeaderId'] = $rootScope.$previousStateParams.myParams.COHeaderId;
                    }
                    loadState($state, $rootScope.$previousState.name, {
                        myParams: selectCustomer_Json
                    });
                }, 1000);
            } else {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }
        }
        //save customer Functionality
        $scope.CustomerModal.SaveCustomer = function() {
            if ($scope.CustomerModal.disableSaveBtn) {
                return;
            }
            for (var key in $scope.CustomerModal.CustomerValidation) {
                if ($scope.CustomerModal.CustomerValidation.hasOwnProperty(key)) {
                    var validationObj = $scope.CustomerModal.CustomerValidation[key];
                    if (validationObj.Type.indexOf('required') > -1) {
                        if ($scope.CustomerModal.CustomerInfo[key] == undefined || $scope.CustomerModal.CustomerInfo[key] == "") {
                            $scope.CustomerModal.CustomerValidation[key]['isError'] = true;
                            $scope.CustomerModal.CustomerValidation[key]['ErrorMessage'] = $Label.Field_Is_Required;
                        }
                    }
                }
            }
            if($scope.CustomerModal.SelectedAccountType) {
                $scope.CustomerModal.CustomerInfo.AccountTypeName = $scope.CustomerModal.SelectedAccountType.AccountType;
                $scope.CustomerModal.CustomerInfo.AccountTypeId = $scope.CustomerModal.SelectedAccountType.AccountTypeId;
            }
            if ($scope.CustomerModal.CustomerInfo.Type == 'Individual') {
                $scope.CustomerModal.CustomerValidation['BusinessName'].isError = false;
            } else {
                $scope.CustomerModal.CustomerValidation['FirstName'].isError = false;
                $scope.CustomerModal.CustomerValidation['LastName'].isError = false;
            }
            for (var key in $scope.CustomerModal.CustomerValidation) {
                if ($scope.CustomerModal.CustomerValidation.hasOwnProperty(key)) {
                    var validationObj = $scope.CustomerModal.CustomerValidation[key];
                    if (validationObj.isError == true) {
                        var target = angular.element("#txt" + key);
                        if (key == 'FirstName' || key == 'LastName') {
                            angular.element('#pop').stop().animate({
                                scrollTop: angular.element(target).offset().top - 200
                            }, 100);
                        }
                        return;
                    }
                }
            }
            for (var key in $scope.CustomerModal.CustomerInfo) {
                if (key == 'PreferredPhone' || key == 'PreferredEmail' || key == 'PreferredSMS') {
                    if ($scope.CustomerModal.CustomerInfo[key] != null && $scope.CustomerModal.CustomerInfo[key] != undefined && $scope.CustomerModal.CustomerInfo[key] != "") {
                        var preferredValue = $scope.CustomerModal.CustomerInfo[key];
                        if ($scope.CustomerModal.CustomerInfo[preferredValue] == null || $scope.CustomerModal.CustomerInfo[preferredValue] == undefined) {
                            $scope.CustomerModal.CustomerValidation[preferredValue].isError = true;
                            $scope.CustomerModal.CustomerValidation[preferredValue].ErrorMessage = $Label.Field_Is_Required;
                            return;
                        }
                    }
                }
            }
            for (var i = 0; i < $scope.CustomerModal.CustumerUnitModal.length; i++) {
                if (angular.toJson($scope.CustomerModal.CustumerUnitModal[i]) != angular.toJson($scope.CustomerModal.initUnit)) {
                    var validateObj = $scope.CustomerModal.CustomerValidationCOU[i];
                    for (var key in validateObj) {
                        $scope.CustomerModal.ValidateCou(i, key);
                    }
                }
            }
            for (var i = 0; i < $scope.CustomerModal.CustomerValidationCOU.length; i++) {
                var validateObj = $scope.CustomerModal.CustomerValidationCOU[i];
                for (var key in validateObj) {
                    if (validateObj.hasOwnProperty(key)) {
                        var validationObj = validateObj[key];
                        if (validationObj.isError == true) {
                            return;
                        }
                    }
                }
            }
            if ($scope.CustomerModal.SimilarCOU.length > 0) {
                Notification.error('Similar Active VIN is Already Present.');
                return;
            }
            if ($scope.CustomerModal.AdditionalFieldsInfo['Birthdate'].isPrimary == true) {
                var Setvalue = 0;
                if (typeof $scope.CustomerModal.BirthyearSelected['year'] == 'undefined') {
                    Setvalue++
                }
                if (typeof $scope.CustomerModal.BirthdaySelected['day'] == 'undefined') {
                    Setvalue++
                }
                if ($scope.CustomerModal.BirthmonthSelected == "") {
                    Setvalue++
                }
                if (Setvalue == 0) {
                    $scope.CustomerModal.CustomerInfo['BirthDay'] = $scope.CustomerModal.BirthdaySelected.day;
                    $scope.CustomerModal.CustomerInfo['BirthMonth'] = $scope.CustomerModal.BirthmonthSelected;
                    $scope.CustomerModal.CustomerInfo['BirthYear'] = $scope.CustomerModal.BirthyearSelected.year;
                } else if (Setvalue != 3 && Setvalue != 0) {
                    Notification.error($Label.Label_Invalid + ' ' + $Label.Label_Birthday + ' ' + $Label.Label_Date);
                    return;
                } else {
                    $scope.CustomerModal.CustomerInfo['BirthDay'] = null;
                    $scope.CustomerModal.CustomerInfo['BirthMonth'] = null;
                    $scope.CustomerModal.CustomerInfo['BirthYear'] = null;
                }
            } else {
                $scope.CustomerModal.CustomerInfo['BirthDay'] = null;
                $scope.CustomerModal.CustomerInfo['BirthMonth'] = null;
                $scope.CustomerModal.CustomerInfo['BirthYear'] = null;
            }
            if ($scope.CustomerModal.CustomerInfo.Type == 'Individual') {
                $scope.CustomerModal.CustomerInfo['WorkNumber'] = '';
                $scope.CustomerModal.CustomerInfo['WorkEmail'] = '';
            } else {
                $scope.CustomerModal.CustomerInfo['HomeNumber'] = '';
                $scope.CustomerModal.CustomerInfo['HomeEmail'] = '';
                $scope.CustomerModal.CustomerInfo['CompanyName'] = '';
                $scope.CustomerModal.CustomerInfo['DriversLicense'] = '';
                $scope.CustomerModal.CustomerInfo['JobTitle'] = '';
                $scope.CustomerModal.CustomerInfo['BirthYear'] = null;
                $scope.CustomerModal.CustomerInfo['BirthDay'] = null;
                $scope.CustomerModal.CustomerInfo['BirthMonth'] = null;
            }
            $scope.CustomerModal.CustomerInfo.BillingCountry = $scope.CustomerModal.SelectedCountry['CountryName'];
            try {
                $scope.CustomerModal.CustomerInfo.BillingState = $scope.CustomerModal.SelectedState['StateName'];
            } catch (err) {
                Notification.error($Label.Billing_state_not_selected);
                return;
            }
            if ($scope.CustomerModal.CustomerInfo.IsBothAddressSame != true) {
                $scope.CustomerModal.CustomerInfo.ShippingCountry = $scope.CustomerModal.SelectedShippingCountry['CountryName'];
                try {
                    $scope.CustomerModal.CustomerInfo.ShippingState = $scope.CustomerModal.SelectedShippingState['StateName'];
                } catch (err) {
                    Notification.error('Shipping State not selected');
                    return;
                }
            } else {
                $scope.CustomerModal.CustomerInfo.ShippingCountry = $scope.CustomerModal.SelectedCountry['CountryName'];
                try {
                    $scope.CustomerModal.CustomerInfo.ShippingState = $scope.CustomerModal.SelectedState['StateName'];
                } catch (err) {
                    Notification.error('Shipping State not selected');
                    return;
                }
            }
            if ($scope.CustomerModal.AdditionalFieldsInfo['PriceLevel'].isPrimary == true) {
                $scope.CustomerModal.CustomerInfo.PriceLevelId = $scope.CustomerModal.SelectedPriceLevel.Id;
            } else {
                $scope.CustomerModal.CustomerInfo.PriceLevelId = null;
            }
            if ($scope.CustomerModal.AdditionalFieldsInfo['IsVendor'].isPrimary == true && $scope.CustomerModal.CustomerInfo['IsVendor'] == true) {
                $scope.CustomerModal.CustomerInfo.PurchaseTaxId = $scope.CustomerModal.VendorSelectedSalesTax.Id;
            } else {
                $scope.CustomerModal.CustomerInfo.PurchaseTaxId = null
            }
            for (var i = 0; i < $scope.CustomerModal.CustumerUnitModal.length; i++) {
                if ($scope.CustomerModal.CustumerUnitModal[i].Mileage == '' || $scope.CustomerModal.CustumerUnitModal[i].Mileage == undefined || $scope.CustomerModal.CustumerUnitModal[i].Mileage == null) {
                    $scope.CustomerModal.CustumerUnitModal[i].Mileage = 0;
                }
                $scope.CustomerModal.CustumerUnitModal[i].UnitType = 'COU';
                $scope.CustomerModal.CustumerUnitModal[i].Status = 'Active';
            }
            var deferred = $q.defer();
            $scope.CustomerModal.disableSaveBtn = true;
            deferred.promise.then(function(result) {
                return addEditCustomerService.saveCustomer(angular.toJson($scope.CustomerModal.CustomerInfo), angular.toJson($scope.CustomerModal.CustumerUnitModal));
            }).then(function(result) {
                var currentPageName;
                if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '') {
                    currentPageName = $stateParams.myParams.A_View_StateName;
                } else {
                    currentPageName = $rootScope.$previousState.name;
                }
                if ((currentPageName.indexOf('CustomerOrder') != -1 || currentPageName.indexOf('NewCustomerOrder') != -1) && ($scope.CustomerModal.isOpenFromSelectCustomerCustomer == undefined || $scope.CustomerModal.isOpenFromSelectCustomerCustomer == '' || $scope.CustomerModal.isOpenFromSelectCustomerCustomer == null)) {
                    if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateParams != undefined && $stateParams.myParams.A_View_StateParams != '') {
                        $scope.selectedObject.coHeaderId = $stateParams.myParams.A_View_StateParams.Id;
                    } else {
                        $scope.selectedObject.coHeaderId = $rootScope.$previousStateParams.Id;
                    }
                    if ($scope.selectedObject.coHeaderId == undefined) {
                        $scope.selectedObject.coHeaderId = '';
                    }
                    if ($scope.selectedObject.coHeaderId != null) {
                        angular.element('#pop').modal('hide');
                        hideModelWindow();
                        if ($state.current.name === 'CustomerOrder.EditCustomer') {
                            if ($scope.$parent.CustomerOrderModel != undefined && $scope.$parent.CustomerOrderModel.EditCustomerDetails != undefined && $scope.CustomerModal.IsEditMode) {
                                $scope.$parent.CustomerOrderModel.EditCustomerDetails(result);
                            }
                            loadState($state, 'CustomerOrder', {
                                Id: $rootScope.$previousStateParams.Id
                            });
                        } else {
                            loadState($state, 'ViewCustomer', {
                                Id: result.Id
                            });
                        }
                    }
                    Notification.success($Label.Customer_Object_Display_Label + ' ' + $Label.Saved_Successfully); 
                } else if ($scope.CustomerModal.isOpenFromSelectCustomerCustomer != undefined && $scope.CustomerModal.isOpenFromSelectCustomerCustomer != '' && $scope.CustomerModal.isOpenFromSelectCustomerCustomer == 'isOpenFromSelectCustomerCustomer' && currentPageName.indexOf('CashSaleCO') != -1 && $state.current.name === 'CashSaleCO.AddCustomer') {  
                    $scope.$emit("selectedCustomerForQCSCallback", result.Id);
                    angular.element('#pop').modal('hide');
                    hideModelWindow();
                    var previousStateName;
                    var previousState_IdParams;
                    if ($stateParams.myParams != undefined && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '' && $stateParams.myParams.A_View_StateParams != undefined) {
                        previousStateName = $stateParams.myParams.A_View_StateName;
                        previousState_IdParams = $stateParams.myParams.A_View_StateParams.Id;
                    } else {
                        previousStateName = $rootScope.$previousState.name;
                        previousState_IdParams = $rootScope.$previousStateParams.Id;
                    }
                    loadState($state, previousStateName, {
                        Id: previousState_IdParams
                    });
                } else if ($scope.CustomerModal.isOpenFromSelectCustomerCustomer != undefined && $scope.CustomerModal.isOpenFromSelectCustomerCustomer != '') {
                    var addeditCustomerJobSchedulingJson = {
                        customerId: result.Id,
                        AppointmentId: $scope.CustomerModal.AppointmentId
                    }
                    $scope.$emit("selectedCustomerCallback", addeditCustomerJobSchedulingJson);
                    angular.element('#pop').modal('hide');
                    hideModelWindow();
                } else {
                    if ($scope.$parent.ViewCustomer != undefined && $scope.$parent.ViewCustomer.saveCustomer != undefined && $scope.CustomerModal.IsEditMode) { 
                        angular.element('#pop').modal('hide');
                        hideModelWindow();
                        $scope.$parent.ViewCustomer.saveCustomer(result);
                        loadState($state, 'ViewCustomer', {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    } else {
                        angular.element('#pop').modal('hide');
                        hideModelWindow();
                        Notification.success($Label.Customer_Object_Display_Label + ' ' + $Label.Saved_Successfully); 
                        loadState($state, 'ViewCustomer', {
                            Id: result.Id
                        });
                    }
                }
                angular.element('#pop').modal('hide');
                $scope.CustomerModal.disableSaveBtn = false;
                return 'Sucess';
            }, function(errorResult) {
                $scope.CustomerModal.disableSaveBtn = false;
            });
            deferred.resolve('1');
        }
        $scope.CustomerModal.markFavourite = function(key, modalName) {
            if ($scope.CustomerModal.CustomerInfo[key] == modalName) {
                $scope.CustomerModal.CustomerInfo[key] = '';
                if (modalName == 'HomeNumber' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.HomeNumberSMS = false;
                } else if (modalName == 'WorkNumber' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.WorkNumberSMS = false;
                } else if (modalName == 'OtherPhone' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.MobileNumberSMS = false;
                }
            } else {
                $scope.CustomerModal.CustomerInfo[key] = modalName;
                if (modalName == 'HomeNumber' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.HomeNumberSMS = true;
                } else if (modalName == 'WorkNumber' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.WorkNumberSMS = true;
                } else if (modalName == 'OtherPhone' && key == 'PreferredSMS') {
                    $scope.CustomerModal.CustomerInfo.MobileNumberSMS = true;
                }
            }
        }
        $scope.CustomerModal.markSMS = function(key) {
            $scope.CustomerModal.CustomerInfo[key] = !$scope.CustomerModal.CustomerInfo[key];
            if ($scope.CustomerModal.CustomerInfo[key] == false) {
                if ($scope.CustomerModal.CustomerInfo.PreferredSMS == 'HomeNumber' && key == 'HomeNumberSMS') {
                    $scope.CustomerModal.CustomerInfo.PreferredSMS = '';
                }
                if ($scope.CustomerModal.CustomerInfo.PreferredSMS == 'WorkNumber' && key == 'WorkNumberSMS') {
                    $scope.CustomerModal.CustomerInfo.PreferredSMS = '';
                }
                if ($scope.CustomerModal.CustomerInfo.PreferredSMS == 'OtherPhone' && key == 'MobileNumberSMS') {
                    $scope.CustomerModal.CustomerInfo.PreferredSMS = '';
                }
            }
        }
        $scope.CustomerModal.ShowOrHideActive = function(key) {
            if (($scope.CustomerModal.IsEditMode == false) && (key == "Active")) {
                return false;
            } else {
                return true;
            }
        }
        if ($stateParams.myParams != undefined && $stateParams.myParams != '' && $stateParams.myParams != null) {
            $scope.CustomerModal.AppointmentId = $stateParams.myParams.AppointmentId;
        }
        $scope.CustomerModal.loadCustomerMasterData();
    }]);
});