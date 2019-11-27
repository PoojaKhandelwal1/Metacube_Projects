	define(['Routing_AppJs_PK', 'AddEditVendorServices', 'NumberOnlyInput_New'], function(Routing_AppJs_PK, AddEditVendorServices, NumberOnlyInput_New) {
	    var injector = angular.injector(['ui-notification', 'ng']);
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
	        $(".form-control").focus(function() {
	            $('.controls').hide();
	            $('#' + $(this).attr('rel')).show();
	        })
	        $('#closemodal').click(function() {
	            $('#pop').modal('hide');
	        });
	    })
	    Routing_AppJs_PK.controller('AddEditVendorCtrl', ['$scope', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'addEditVendorService', '$translate', function($scope, $q, $rootScope, $sce, $stateParams, $state, addEditVendorService,$translate) {
	        var Notification = injector.get("Notification");
	        $scope.handler = 'pop';
	        $scope.selectedObject = {};
	        $scope.selectedObject.ChangeRecords = 0;
	        var stateParams = '';
	        if ($scope.VendorModal == undefined) {
	            $scope.VendorModal = {};
	        }
	        $scope.VendorModal.openAddVendorPopup = function() {
	            $scope.VendorModal.ClearAllData();
	            $scope.VendorModal.IsEditMode = false;
	            $scope.VendorModal.openPopup();
	        }

	        $scope.VendorModal.openEditVendorPopup = function(vendorId) {
	        	$scope.VendorModal.EditVendorId = vendorId;
	        	$scope.VendorModal.IsEditMode = true;
	            addEditVendorService.getVendorInfoById(vendorId).then(function(vendorRecord) {
	                
	                if ($scope.VendorModal.IsEditMode) {
	                    var Active = {
	                        isPrimary: false,
	                        label: 'Active',
	                        fieldId: 'activeId'
	                    };
	                    $scope.VendorModal.AdditionalFieldsInfo.Active = Active;
	                    $scope.VendorModal.SelectedAccountType = {};
	                    $scope.VendorModal.SelectedAccountType.AccountType = vendorRecord.VendorDetailRec.AccountTypeName;
	                    $scope.VendorModal.SelectedAccountType.AccountTypeId = vendorRecord.VendorDetailRec.AccountTypeId;
	                }
	                $scope.VendorModal.VendorInfo = vendorRecord.VendorDetailRec;
	                if (vendorRecord.VendorDetailRec.RetailBaseValue === "Item Cost") {
	                    $scope.VendorModal.VendorInfo.RetailBaseValue_Option = $scope.VendorModal.RetailBaseValue_Options[1]; 
	                } else {
	                    $scope.VendorModal.VendorInfo.RetailBaseValue_Option = $scope.VendorModal.RetailBaseValue_Options[0]; 
	                }
	                if ($scope.VendorModal.VendorInfo.RetailRate <= 0) {
	                    $scope.VendorModal.VendorInfo.Increase_Decrease_Option = $scope.VendorModal.Increase_Decrease_Options[0]; 
	                    $scope.VendorModal.VendorInfo.RetailRate = $scope.VendorModal.VendorInfo.RetailRate * -1;
	                } else {
	                    $scope.VendorModal.VendorInfo.Increase_Decrease_Option = $scope.VendorModal.Increase_Decrease_Options[1]; 
	                }
	                if (vendorRecord.VendorDetailRec.RetailRounding == true) {
	                    $scope.VendorModal.VendorInfo.RetailRounding_Option = $scope.VendorModal.RetailRounding_Options[1];
	                } else {
	                    $scope.VendorModal.VendorInfo.RetailRounding_Option = $scope.VendorModal.RetailRounding_Options[0]; 
	                }
	                $scope.VendorModal.SetVendorFormDefault();
	                $scope.VendorModal.openPopup();
	            });
	        }
	        $scope.VendorModal.disableSaveButton = false;
	        $scope.VendorModal.openPopup = function() {
	            angular.element('#newVendor').modal({
	                backdrop: 'static',
	                keyboard: false
	            });
	        }
	        $scope.VendorModal.closePopup = function() {
	            $scope.VendorModal.ClearAllData();
	            angular.element('#newVendor').modal('hide');
	            hideModelWindow();
	            if ($scope.VendorModal.isOpenFromSelectVendor != undefined && $scope.VendorModal.isOpenFromSelectVendor != '') {
	                var A_View_StateName;
	                var A_View_StateParams;
	                if ($stateParams.myParams != undefined && $stateParams.myParams != '' && $stateParams.myParams.A_View_StateName != undefined && $stateParams.myParams.A_View_StateName != '') {
	                    A_View_StateName = $stateParams.myParams.A_View_StateName;
	                    A_View_StateParams = $stateParams.myParams.A_View_StateParams;
	                }
	                var selectVendor_Json = {
	                    type: $scope.VendorModal.createVendorFor,
	                    A_View_StateName: A_View_StateName,
	                    A_View_StateParams: A_View_StateParams
	                };
	                loadState($state, $rootScope.$previousState.name, {
	                    myParams: selectVendor_Json
	                });
	            } else {
	                loadState($state, $rootScope.$previousState.name, {
	                    Id: $rootScope.$previousStateParams.Id
	                });
	            }
	        }
	        $scope.VendorModal.formFieldJustGotFocus = function(Value) {
	            showToolTip(Value);
	        }
	        $scope.VendorModal.helpText = {
	            VendorName: $translate.instant('Helptext_provide_company_name'),
	            VendorAccountNumber: $translate.instant('Helptext_account_number_provided_by_vendor'),
	            VendorTaxId: $translate.instant('Helptext_tax_id_provided_by_vendor'),
	            WorkEmail: $translate.instant('Helptext_work_email'),
	            OtherEmail: $translate.instant('Helptext_add_alternative_email'),
	            Phone: $translate.instant('Helptext_provide_phone_number'),
	            OtherPhone:$translate.instant('Helptext_provide_alternative_phone_number'),
	            Fax: $translate.instant('Helptext_provide_fax_number'),
	            Website: $translate.instant('Helptext_add_Website'),
	            Facebook: $translate.instant('Helptext_add_facebook_profile_link'),
	            Linkedin: $translate.instant('Helptext_add_linkedin_profile_link'),
	            Twitter: $translate.instant('Helptext_add_twitter_profile_link'),
	            PartCategory: $translate.instant('Helptext_provide_part_category_for_the_vendor'),
	            PurchaseTaxLevel: $translate.instant('Helptext_purchase_tax_level_for_the_vendor'),
	            SalesPriceLevel: $translate.instant('Helptext_sales_price_level_for_the_vendor'),
	            MerchandiseCategory: $translate.instant('Helptext_provide_merchandise_category_for_the_vendor')
	        };
	        $scope.VendorModal.showInfoOverlay = function(event, index) {
	            var targetEle = angular.element('#' + event + index);
	            var scrolledTop = -($('.modal-content').offset().top - 30);
	            var elementWidth = targetEle.width();
	            angular.element('.Vendor-Suggestion-overlay').css('top', targetEle.offset().top + scrolledTop - 40);
	            angular.element('.Vendor-Suggestion-overlay').css('left', '280px');
	            angular.element('.Vendor-Suggestion-overlay').show();
	            $scope.VendorModal.SimilarVendorSelect = {
	                Value: $scope.VendorModal.SimilarVendors[index].Id,
	                Name: $scope.VendorModal.SimilarVendors[index].VendorName
	            }
	        }
	        $scope.VendorModal.setDefaultDataForPricingSection = function() {
	            $scope.VendorModal.VendorInfo.RetailRate = 0;
	            $scope.VendorModal.VendorInfo.Increase_Decrease_Option = $scope.VendorModal.Increase_Decrease_Options[0]; 
	            $scope.VendorModal.VendorInfo.RetailBaseValue_Option = $scope.VendorModal.RetailBaseValue_Options[0]; 
	            $scope.VendorModal.VendorInfo.RetailRounding_Option = $scope.VendorModal.RetailRounding_Options[0]; 
	            $scope.VendorModal.VendorInfo.RetailRoundTo = 95;
	        }
	        $scope.VendorModal.change_Increase_Decrease_Value = function() {
	            if ($scope.VendorModal.VendorInfo.RetailBaseValue_Option.label == "Item Cost") {
	                $scope.VendorModal.VendorInfo.Increase_Decrease_Option = $scope.VendorModal.Increase_Decrease_Options[1]; 
	            } else {
	                $scope.VendorModal.VendorInfo.Increase_Decrease_Option = $scope.VendorModal.Increase_Decrease_Options[0]; 
	            }
	        }
	        $scope.VendorModal.hideVendorInfoOverlay = function() {
	            angular.element('.Vendor-Suggestion-overlay').hide();
	        }
	        $scope.VendorModal.loadVendorMasterData = function() {
	            if ($scope.VendorModal.VendorMasterData == undefined) {
	                addEditVendorService.getVendorAllMasterData().then(function(VendorMasterData) {
	                    $scope.VendorModal.VendorMasterData = VendorMasterData;
	                    $scope.VendorModal.SetMasterData();
	                }, function(errorSearchResult) {
	                    responseData = errorSearchResult;
	                });
	            } else {
	                $scope.VendorModal.SetMasterData();
	            }
	            	addEditVendorService.getAllAccountTypeForVendor().then(function(AccoutTypeMasterData) {
	            	$scope.VendorModal.SelectedAccountType = {};
	                  $scope.VendorModal.AccountTypeList = AccoutTypeMasterData;
	                  if(!$scope.VendorModal.IsEditMode){
	                  	for(var i=0; i<$scope.VendorModal.AccountTypeList.length;i++) {
		                    if($scope.VendorModal.AccountTypeList[i].IsDefault) {
		                         $scope.VendorModal.SelectedAccountType.AccountType = $scope.VendorModal.AccountTypeList[i].AccountType;
		                          $scope.VendorModal.SelectedAccountType.AccountTypeId = $scope.VendorModal.AccountTypeList[i].Id;
		                    }
                		}
	                  }
	                  
	                }, function(errorSearchResult) {
	                    responseData = errorSearchResult;
	                });
	        }
	        $scope.VendorModal.SetMasterData = function() {
	            var Curryear = new Date().getFullYear();
	            var curr = parseInt(Curryear);
	            $scope.VendorModal.BirthYears = [];
	            $scope.VendorModal.BirthDays = [];
	            $scope.VendorModal.ModelYears = [];
	            for (i = 1900; i < curr; i++) {
	                var year = {
	                    year: i
	                };
	                $scope.VendorModal.BirthYears.push(year);
	            }
	            for (i = curr; i > (curr - 100 + 2); i--) {
	                var year = {
	                    modelyear: i.toString()
	                };
	                $scope.VendorModal.ModelYears.push(year);
	            }
	            $scope.VendorModal.ClearAllData();
	            $scope.VendorModal.IsEditMode = false;
	            $scope.VendorModal.disableSaveBtn = false; 
	            $scope.VendorModal.initUnit = {
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
	            if ($state.current.name === 'ViewVendor.EditVendor') {
	                var args = $stateParams.EditVendorParams;
	            } else {
	                var args = $stateParams.myParams;
	            }
	            $scope.VendorModal.disableSaveBtn = false; 
	            $scope.VendorModal.isOpenFromSTA = '';
	            if (args != undefined) {
	                if (args.isOpenFromSelectVendor == 'isOpenFromSelectVendor') {
	                    $scope.VendorModal.createVendorFor = args.sellingType;
	                    $scope.VendorModal.isOpenFromSelectVendor = args.isOpenFromSelectVendor;
	                } else if (args.isOpenFromSelectVendor == 'isOpenFromSTA') {
	                    $scope.VendorModal.isOpenFromSTA = args.isOpenFromSelectVendor;
	                }
	            } else {
	                $scope.VendorModal.isOpenFromSelectVendor = '';
	            }
	            var vendorId;
	            if ($state.current.name === 'ViewVendor.EditVendor') {
	                vendorId = $stateParams.EditVendorParams.Id;
	            }
	            if (vendorId != undefined && vendorId != null) {
	                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
	                    $scope.$apply();
	                }
	                $scope.VendorModal.openEditVendorPopup(vendorId);
	            } else {
	                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
	                    $scope.$apply();
	                }
	                $scope.VendorModal.openAddVendorPopup();
	            }
	        }
	        $scope.VendorModal.getCurrentVendorData = function() {
	            addEditVendorService.getVendorInfoById($scope.VendorModal.currentVendorId).then(function(vendorRecord) {
	                $scope.VendorModal.VendorInfo = vendorRecord.VendorDetailRec;
	                $scope.VendorModal.SetVendorFormDefault();
	                $scope.VendorModal.openPopup();
	            }, function(errorSearchResult) {
	            });
	        }
	        $scope.VendorModal.tabIndexValue = 5000;
	        $scope.VendorModal.adjustTabIndex = function(e) {
	            if (e.which == 9) {
	                $('#vendorName').focus();
	                e.preventDefault();
	            }
	        }
	        $scope.VendorModal.tabIndexValue = 5000;
	        $scope.VendorModal.adjustTabIndex = function(e) {
	            if (e.which == 9) {
	                $('#vendorName').focus();
	                e.preventDefault();
	            }
	        }
	        $scope.VendorModal.ClearAllData = function() {
	            try {
	                $scope.VendorModal.Country = $scope.VendorModal.VendorMasterData.CountryList;
	            } catch (err) {
	                Notification.error($translate.instant('AddEditCustomer_Select_Country'));
	                return;
	            }
	            $scope.VendorModal.SelectedState = null; 
	            $scope.VendorModal.ShippingCountry = $scope.VendorModal.VendorMasterData.CountryList;
	            $scope.VendorModal.SalesPriceLevel = $scope.VendorModal.VendorMasterData.PriceLevelList;
	            $scope.VendorModal.PurchaseTaxLevel = $scope.VendorModal.VendorMasterData.SalesTaxList;
	            $scope.VendorModal.PartCategory = $scope.VendorModal.VendorMasterData.CategoryList;
	            $scope.VendorModal.SimilarVendors = [];
	            $scope.VendorModal.SetDafaultBillingCountry();
	            $scope.VendorModal.SetDafaultBillingState();
	            $scope.VendorModal.SetDafaultShippingCountry();
	            $scope.VendorModal.SetDafaultShippingState();
	            $scope.VendorModal.SetDafaultSalesPriceLevel();
	            $scope.VendorModal.SetDafaultPurchaseTaxLevel();
	            $scope.VendorModal.SetDafaultPartCategory();
	            $scope.VendorModal.SetDafaultMerchandiseCategory();
	            $scope.VendorModal.VendorSelectedSalesTax = {};
	            $scope.VendorModal.AdditionalFieldsInfo = {
	                OtherPhone: {
	                    isPrimary: false,
	                    label: 'Other Phone',
	                    fieldId: 'otherPhoneId'
	                },
	                VendorTaxId: {
	                    isPrimary: false,
	                    label: 'Vendor Tax Id',
	                    fieldId: 'vendorTaxId'
	                },
	                OtherEmail: {
	                    isPrimary: false,
	                    label: 'Other Email',
	                    fieldId: 'otherEmail'
	                },
	                Fax: {
	                    isPrimary: false,
	                    label: 'Fax',
	                    fieldId: 'fax'
	                },
	                ProductAndServices: {
	                    isPrimary: true,
	                    label: 'Products & Services',
	                    fieldId: 'ProductAndServicesId'
	                },
	                Website: {
	                    isPrimary: false,
	                    label: 'Website',
	                    fieldId: 'websiteId'
	                },
	                FacebookLink: {
	                    isPrimary: false,
	                    label: 'Facebook',
	                    fieldId: 'facebookLink'
	                },
	                TwitterLink: {
	                    isPrimary: false,
	                    label: 'Twitter',
	                    fieldId: 'twitterLink'
	                },
	                LinkedInLink: {
	                    isPrimary: false,
	                    label: 'LinkedIn',
	                    fieldId: 'LinkedinLink'
	                },
	                PartCategory: {
	                    isPrimary: false,
	                    label: 'Part Category',
	                    fieldId: 'partCategoryDropDown'
	                },
	                MerchandiseCategory: {
	                    isPrimary: false,
	                    label: 'Merchandise Category',
	                    fieldId: 'merchandiseCategoryDropDown'
	                },
	                PurchaseTaxLevel: {
	                    isPrimary: true,
	                    label: 'Purchase Tax Level',
	                    fieldId: 'purchaseTaxLevel'
	                },
	                SalesPriceLevel: {
	                    isPrimary: false,
	                    label: 'Sales Price Level',
	                    fieldId: 'salesPriceLevel'
	                },
	            }  
	            $scope.VendorModal.VendorValidation = {
	                VendorName: {
	                    isError: false,
	                    ErrorMessage: '',
	                    Type: 'required,Maxlength,Minlength',
	                    Maxlength: 80,
	                    Minlength: 2
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
	                Fax: {
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
	            }
	            $scope.VendorModal.VendorInfo = {};
	            $scope.VendorModal.VendorInfo = {
	                IsBothAddressSame: true,
	                IsVendor: true,
	                Active: true,
	                WorkNumberSMS: false,
	                MobileNumberSMS: false,
	                HomeNumberSMS: false,
	                IsCustomer: false,
	                IsClaimsForServiceWork: false,
	                IsFlooringCompany: false,
	                IsPartPurchases: false,
	                IsMerchandisePurchases: false,
	                IsSubletPurchases: false,
	                IsUnitPurchases: false,
	                IsWarrantyPlans: false,
	                IsFinanceCompany: false,
	                IsFinancingProducts: false,
	                IsCalculatePartRetailPrice: false
	            };
	            $scope.VendorModal.Increase_Decrease_Options = [{
	                Id: 1,
	                label: 'Less'
	            }, {
	                Id: 2,
	                label: 'More'
	            }];
	            $scope.VendorModal.RetailBaseValue_Options = [{
	                Id: 1,
	                label: 'MSRP'
	            }, {
	                Id: 2,
	                label: 'Item Cost'
	            }];
	            $scope.VendorModal.RetailRounding_Options = [{
	                Id: 1,
	                value: false,
	                label: 'Is Not'
	            }, {
	                Id: 2,
	                value: true,
	                label: 'Is'
	            }];
	            $scope.VendorModal.setDefaultDataForPricingSection();
	        }
	        $scope.VendorModal.ShowFieldCondition = function(key) {
	            if ($scope.VendorModal.AdditionalFieldsInfo != undefined && $scope.VendorModal.AdditionalFieldsInfo[key].isPrimary) {
	                if (key == 'PurchaseTaxLevel') {
	                    if ($scope.VendorModal.IsEditMode) {
	                        if ($rootScope.GroupOnlyPermissions['Sales Taxes'].assign) {
	                            return true;
	                        } else {
	                            return false;
	                        }
	                    } else {
	                        return true;
	                    }
	                } else if (key == 'SalesPriceLevel') {
	                    if ($scope.VendorModal.IsEditMode) {
	                        if ($rootScope.GroupOnlyPermissions['Price Levels'].assign) {
	                            return true;
	                        } else {
	                            return false;
	                        }
	                    } else {
	                        return true;
	                    }
	                }
	            } else {
	                return false;
	            }
	            return true;
	        }
	        $scope.VendorModal.ManageAdditionalFields = function(key) {
	            var result = false;
	            if (!$scope.VendorModal.AdditionalFieldsInfo[key].isPrimary) {
	                if (key == 'PurchaseTaxLevel') {
	                    if ($scope.VendorModal.IsEditMode) {
	                        if ($rootScope.GroupOnlyPermissions['Sales Taxes'].assign) {
	                            result = true;
	                        } else {
	                            result = false;
	                        }
	                    } else {
	                        result = true;
	                    }
	                } else if (key == 'SalesPriceLevel') {
	                    if ($scope.VendorModal.IsEditMode) {
	                        if ($rootScope.GroupOnlyPermissions['Price Levels'].assign) {
	                            result = true;
	                        } else {
	                            result = false;
	                        }
	                    } else {
	                        result = true;
	                    }
	                } else {
	                    result = true;
	                }
	            }
	            return result;
	        }
	        $scope.VendorModal.SetVendorFormDefault = function() {
	            if ($scope.VendorModal.VendorInfo.BillingCountry != '') {
	                for (var i = 0; i < $scope.VendorModal.VendorMasterData.CountryList.length; i++) {
	                    if ($scope.VendorModal.VendorMasterData.CountryList[i].CountryName == $scope.VendorModal.VendorInfo.BillingCountry) {
	                        $scope.VendorModal.SelectedCountry = $scope.VendorModal.VendorMasterData.CountryList[i];
	                    }
	                }
	                $scope.VendorModal.State = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedCountry.CountryName];
	                for (var i = 0; i < $scope.VendorModal.State.length; i++) {
	                    if ($scope.VendorModal.State[i].StateName == $scope.VendorModal.VendorInfo.BillingState) {
	                        $scope.VendorModal.SelectedState = $scope.VendorModal.State[i];
	                    }
	                }
	            }
	            if ($scope.VendorModal.VendorInfo.IsBothAddressSame) {
	            } else {
	                for (var i = 0; i < $scope.VendorModal.VendorMasterData.CountryList.length; i++) {
	                    if ($scope.VendorModal.VendorMasterData.CountryList[i].CountryName == $scope.VendorModal.VendorInfo.ShippingCountry) {
	                        $scope.VendorModal.SelectedShippingCountry = $scope.VendorModal.VendorMasterData.CountryList[i];
	                    }
	                }
	                $scope.VendorModal.ShippingState = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedShippingCountry.CountryName];
	                for (var i = 0; i < $scope.VendorModal.ShippingState.length; i++) {
	                    if ($scope.VendorModal.ShippingState[i].StateName == $scope.VendorModal.VendorInfo.ShippingState) {
	                        $scope.VendorModal.SelectedShippingState = $scope.VendorModal.ShippingState[i];
	                    }
	                }
	            }
	            if ($scope.VendorModal.VendorInfo.SalesPriceLevelId != null) {
	                for (var i = 0; i < $scope.VendorModal.SalesPriceLevel.length; i++) {
	                    if ($scope.VendorModal.SalesPriceLevel[i].Id == $scope.VendorModal.VendorInfo.SalesPriceLevelId) {
	                        $scope.VendorModal.SelectedSalesPriceLevel = $scope.VendorModal.SalesPriceLevel[i];
	                    }
	                }
	                $scope.VendorModal.AdditionalFieldsInfo['SalesPriceLevel'].isPrimary = true;
	            }
                $scope.VendorModal.AdditionalFieldsInfo['PurchaseTaxLevel'].isPrimary = true;
	            if ($scope.VendorModal.VendorInfo.PurchaseTaxLevelId != null) {
	                for (var i = 0; i < $scope.VendorModal.PurchaseTaxLevel.length; i++) {
	                    if ($scope.VendorModal.PurchaseTaxLevel[i].Id == $scope.VendorModal.VendorInfo.PurchaseTaxLevelId) {
	                        $scope.VendorModal.SelectedPurchaseTaxLevel = $scope.VendorModal.PurchaseTaxLevel[i];
	                    }
	                }
	            }
	            if ($scope.VendorModal.VendorInfo.PartCategoryId != null && $scope.VendorModal.VendorInfo.PartCategoryId != '' && $scope.VendorModal.VendorInfo.PartCategoryId != undefined) {
	                for (var i = 0; i < $scope.VendorModal.PartCategory.length; i++) {
	                    if ($scope.VendorModal.PartCategory[i].Id == $scope.VendorModal.VendorInfo.PartCategoryId) {
	                        $scope.VendorModal.SelectedPartCategory = $scope.VendorModal.PartCategory[i];
	                    }
	                }
	                $scope.VendorModal.AdditionalFieldsInfo['PartCategory'].isPrimary = true;
	            }
	            if ($scope.VendorModal.VendorInfo.MerchandiseCategoryId != null && $scope.VendorModal.VendorInfo.MerchandiseCategoryId != '' && $scope.VendorModal.VendorInfo.MerchandiseCategoryId != undefined) {
	                for (var i = 0; i < $scope.VendorModal.PartCategory.length; i++) {
	                    if ($scope.VendorModal.PartCategory[i].Id == $scope.VendorModal.VendorInfo.MerchandiseCategoryId) {
	                        $scope.VendorModal.SelectedMerchandiseCategory = $scope.VendorModal.PartCategory[i];
	                    }
	                }
	                $scope.VendorModal.AdditionalFieldsInfo['MerchandiseCategory'].isPrimary = true;
	            }
	            angular.forEach($scope.VendorModal.AdditionalFieldsInfo, function(value, key) {
	                if ($scope.VendorModal.VendorInfo[key] != null && $scope.VendorModal.VendorInfo[key] != '') {
	                    $scope.VendorModal.AdditionalFieldsInfo[key].isPrimary = true;
	                }
	            });
	            $scope.VendorModal.AdditionalFieldsInfo.ProductAndServices.isPrimary = true;
	            angular.forEach($scope.ProductAndServicesMap, function(value, key) {
	                if ($scope.VendorModal.VendorInfo[value] == true) {
	                	displayCorrespondingFieldForProductAndService(key);
	                }
	            });
	            $scope.VendorModal.AdditionalFieldsInfo.Active.isPrimary = true;
	        }
	        $scope.VendorModal.isFeildDisplay = function(fieldLabel) {
	            for (i = 0; i < $scope.VendorModal.PrimaryFields.length; i++) {
	                if ($scope.VendorModal.PrimaryFields.label == fieldLabel) {
	                    return true;
	                }
	            }
	            return false;
	        }
	        $scope.VendorModal.AddSimilarCustomer = function() {
	            addEditCustomerService.addCustomer($scope.selectedObject.coHeaderId, $scope.VendorModal.SimilarCustomerSelect.Value).then(function(sucessCustomerResult) {
	                angular.copy($scope.VendorModal.SimilarCustomerSelect, $scope.selectedObject.Customer);
	                $scope.selectedObject.ChangeRecords = 0;
	                angular.element('#pop').modal('hide');
	            }, function(errorSearchResult) {
	                responseData = errorSearchResult;
	            });
	        }
	        $scope.VendorModal.OnFocus = function(targetId) {
	            angular.element('.controls').hide();
	            angular.element('#' + targetId).show();
	        }
	        $scope.VendorModal.OnBlurVin = function(value) {
	            $scope.VendorModal.getSimilarCOUs(value);
	        }
	        $scope.VendorModal.ClearAndRemoveField = function(fieldrel, targetIdToFocus) {
	            var fieldsToClearOrRemove = $scope.VendorModal.ManageIconVendorDetails[0][fieldrel];
	            for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
	                var key = fieldsToClearOrRemove.value[i].val;
	                if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
	                    $scope.VendorModal.VendorInfo[key] = "";
	                } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
	                    $scope.VendorModal.VendorInfo[key] = false;
	                } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
	                    $scope.VendorModal.VendorInfo[key] = null;
	                } else if (fieldsToClearOrRemove.value[i].fieldType == 'dropdown') {}
	                if (fieldrel == 'CityState') {
	                    $scope.VendorModal.SetDafaultBillingState();
	                } else if (fieldrel == 'CountryPostal') {
	                    $scope.VendorModal.SetDafaultBillingCountry();
	                    $scope.VendorModal.SetDafaultBillingState();
	                } else if (fieldrel == 'ShippingCityState') {
	                    $scope.VendorModal.SetDafaultShippingState();
	                } else if (fieldrel == 'CountryPostalShipping') {
	                    $scope.VendorModal.SetDafaultShippingCountry();
	                    $scope.VendorModal.SetDafaultShippingState();
	                } else if (fieldrel == 'SalesPriceLevel') {
	                    $scope.VendorModal.SetDafaultSalesPriceLevel();
	                } else if (fieldrel == 'PurchaseTaxLevel') {
	                    $scope.VendorModal.SetDafaultPurchaseTaxLevel();
	                } else if (fieldrel == 'PartCategory') {
	                    $scope.VendorModal.SetDafaultPartCategory();
	                } else if (fieldrel == 'MerchandiseCategory') {
	                    $scope.VendorModal.SetDafaultMerchandiseCategory();
	                }
	            }
	            if (fieldsToClearOrRemove.isPrimary == false) {
	                $scope.VendorModal.AdditionalFieldsInfo[key].isPrimary = false;
	            }
	            angular.element('#' + targetIdToFocus).focus();
	        }
	        $scope.VendorModal.getOtherSimilarVendor = function() {
	            var similarVendorJson = {};
	            angular.copy($scope.VendorModal.VendorInfo, similarVendorJson);
	            addEditVendorService.getOtherSimilarVendor(JSON.stringify(similarVendorJson)).then(function(similarVendor) {
	                $scope.VendorModal.SimilarVendors = similarVendor;
	            }, function(errorSearchResult) {
	                responseData = errorSearchResult;
	            });
	        }
	        $scope.VendorModal.validatePhone = function() {
	            $scope.VendorModal.validateForm('OtherPhone');
	            $scope.VendorModal.validateForm('WorkNumber');
	        }
	        $scope.VendorModal.validateForm = function(modelKey) {
	            var validationObj = $scope.VendorModal.VendorValidation[modelKey];
	            if (($scope.VendorModal.SelectedCountry.CountryName == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
	                validationObj.Minlength = 8;
	            } else if (validationObj.Type.indexOf('phone') > -1) {
	                validationObj.Minlength = 10;
	            }
	            var isError = false;
	            var ErrorMessage = '';
	            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
	            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
	            var postalCodeRegEx = /^[a-zA-Z\d\s\-]+$/;
	            var validateType = validationObj.Type;
	            if (validateType.indexOf('Minlength') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && $scope.VendorModal.VendorInfo[modelKey].length < validationObj.Minlength) {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Min_Length_Should_Be') + validationObj.Minlength;
	                }
	            }
	            if (validateType.indexOf('Maxlength') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && $scope.VendorModal.VendorInfo[modelKey].length > validationObj.Maxlength) {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Max_Length_Should_Be') + validationObj.Maxlength;
	                }
	            }
	            if (validateType.indexOf('phone') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && !phoneRegEx.test($scope.VendorModal.VendorInfo[modelKey])) {
	                    isError = true;
	                    if (modelKey == "WorkNumber" || modelKey == "OtherPhone") {
	                        ErrorMessage = $translate.instant('Invalid_phone_number');
	                    } else if (modelKey == "Fax") {
	                        ErrorMessage = $translate.instant('Invalid_fax_number');
	                    }
	                }
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && $scope.VendorModal.VendorInfo[modelKey].length == 9 && ($scope.VendorModal.SelectedCountry.CountryName == 'Australia')) {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + '8 or 10';
	                }
	            }
	            if (validateType.indexOf('email') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && !emailRegEx.test($scope.VendorModal.VendorInfo[modelKey])) {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Invalid_email_id');
	                }
	            }
	            if (validateType.indexOf('PostalCode') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] != undefined && $scope.VendorModal.VendorInfo[modelKey] != '' && !postalCodeRegEx.test($scope.VendorModal.VendorInfo[modelKey])) {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Postal');
	                }
	            }
	            if (validateType.indexOf('required') > -1) {
	                if ($scope.VendorModal.VendorInfo[modelKey] == undefined || $scope.VendorModal.VendorInfo[modelKey] == '') {
	                    isError = true;
	                    ErrorMessage = $translate.instant('Field_Is_Required');
	                }
	            }
	            $scope.VendorModal.VendorValidation[modelKey]['isError'] = isError;
	            $scope.VendorModal.VendorValidation[modelKey]['ErrorMessage'] = ErrorMessage;
	            return (!isError);
	        }
	        $scope.VendorModal.ManageIconVendorDetails = [{
	            VendorName: {
	                value: [{
	                    val: 'VendorName',
	                    fieldType: 'text'
	                }],
	                isPrimary: true
	            },
	            VendorCode: {
	                value: [{
	                    val: 'VendorCode',
	                    fieldType: 'text'
	                }],
	                isPrimary: true
	            },
	            VendorAccountNumber: {
	                value: [{
	                    val: 'VendorAccountNumber',
	                    fieldType: 'text'
	                }],
	                isPrimary: true
	            },
	            VendorTaxId: {
	                value: [{
	                    val: 'VendorTaxId',
	                    fieldType: 'text'
	                }],
	                isPrimary: false
	            },
	            WorkEmail: {
	                value: [{
	                    val: 'WorkEmail',
	                    fieldType: 'text'
	                }],
	                isPrimary: true
	            },
	            WorkNumber: {
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
	            CityState: {
	                value: [{
	                    val: 'BillingCity',
	                    fieldType: 'text'
	                }, {
	                    val: 'BillingState',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: true
	            },
	            CountryPostal: {
	                value: [{
	                    val: 'BillingCountry',
	                    fieldType: 'lookup'
	                }, {
	                    val: 'BillingPostalCode',
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
	            ShippingCityState: {
	                value: [{
	                    val: 'ShippingCity',
	                    fieldType: 'text'
	                }, {
	                    val: 'ShippingState',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: true
	            },
	            CountryPostalShipping: {
	                value: [{
	                    val: 'ShippingPostalCode',
	                    fieldType: 'text'
	                }, {
	                    val: 'ShippingCountry',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: true
	            },
	            Fax: {
	                value: [{
	                    val: 'Fax',
	                    fieldType: 'text'
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
	            Website: {
	                value: [{
	                    val: 'Website',
	                    fieldType: 'text'
	                }],
	                isPrimary: false
	            },
	            PartCategory: {
	                value: [{
	                    val: 'PartCategory',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: false
	            },
	            MerchandiseCategory: {
	                value: [{
	                    val: 'MerchandiseCategory',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: false
	            },
	            PurchaseTaxLevel: {
	                value: [{
	                    val: 'PurchaseTaxLevel',
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
	            SalesPriceLevel: {
	                value: [{
	                    val: 'SalesPriceLevel',
	                    fieldType: 'lookup'
	                }],
	                isPrimary: false
	            },
	            ForeignCurrency: {
	                value: [{
	                    val: 'ForeignCurrency',
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
	        }];
	        $scope.VendorModal.AdditionalFieldsSearch = '';
	        $scope.FilterAdditionalFields = function(items) {
	            var result = {};
	            angular.forEach(items, function(value, key) {
	                if (value.label.toLowerCase().indexOf($scope.VendorModal.AdditionalFieldsSearch) != -1) {
	                    result[key] = value;
	                }
	            });
	            return result;
	        }
	        $scope.VendorModal.ShowAdditionalField = function(key) {
	            $scope.VendorModal.AdditionalFieldsInfo[key].isPrimary = true;
	            var targetId = $scope.VendorModal.AdditionalFieldsInfo[key].fieldId;
	            if (key == 'FacebookLink') {
	                $scope.VendorModal.VendorInfo.FacebookLink = "https://www.facebook.com/";
	            } else if (key == 'LinkedInLink') {
	                $scope.VendorModal.VendorInfo.LinkedInLink = "https://www.LinkedIn.com/";
	            } else if (key == 'TwitterLink') {
	                $scope.VendorModal.VendorInfo.TwitterLink = "https://www.Twitter.com/";
	            } else if (key == 'Website') {
	                $scope.VendorModal.VendorInfo.Website = "http://";
	            }
	            setTimeout(function() {
	                if (targetId != undefined) {
	                    angular.element('#' + targetId).focus();
	                }
	            }, 100);
	        }
	        $scope.launchAlert = function(bool) {
	            alert('!!! first function call to finish');
	        };
	        $scope.VendorModal.SetVendorActiveStatus = function(status) {
	            if (status) {
	                angular.element('.ConfirmBox-overlay').show();
	                angular.element('#confirmButton').focus();
	            } else {
	                $scope.VendorModal.VendorInfo.Active = true;
	            }
	        }
	        $scope.VendorModal.DeactiveVendor = function(status) {
	            if (!status) {
	                angular.element('.ConfirmBox-overlay').hide();
	            } else {
	                $scope.VendorModal.VendorInfo.Active = false;
	                angular.element('.ConfirmBox-overlay').hide();
	            }
	        }
	        $scope.VendorModal.SetDafaultBillingCountry = function() {
	            for (var i = 0; i < $scope.VendorModal.VendorMasterData.CountryList.length; i++) {
	                if ($scope.VendorModal.VendorMasterData.CountryList[i].IsDefault) {
	                    $scope.VendorModal.SelectedCountry = $scope.VendorModal.VendorMasterData.CountryList[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultBillingState = function() {
	            $scope.VendorModal.State = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedCountry.CountryName];
	            for (var i = 0; i < $scope.VendorModal.State.length; i++) {
	                if ($scope.VendorModal.State[i].IsDefault) {
	                    $scope.VendorModal.SelectedState = $scope.VendorModal.State[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultShippingCountry = function() {
	            for (var i = 0; i < $scope.VendorModal.VendorMasterData.CountryList.length; i++) {
	                if ($scope.VendorModal.VendorMasterData.CountryList[i].IsDefault) {
	                    $scope.VendorModal.SelectedShippingCountry = $scope.VendorModal.VendorMasterData.CountryList[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultShippingState = function() {
	            $scope.VendorModal.ShippingState = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedShippingCountry.CountryName];
	            for (var i = 0; i < $scope.VendorModal.ShippingState.length; i++) {
	                if ($scope.VendorModal.ShippingState[i].IsDefault) {
	                    $scope.VendorModal.SelectedShippingState = $scope.VendorModal.ShippingState[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultSalesPriceLevel = function() {
	            for (var i = 0; i < $scope.VendorModal.SalesPriceLevel.length; i++) {
	                if ($scope.VendorModal.SalesPriceLevel[i].IsDefault) {
	                    $scope.VendorModal.SelectedSalesPriceLevel = $scope.VendorModal.SalesPriceLevel[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultPurchaseTaxLevel = function() {
	            for (var i = 0; i < $scope.VendorModal.PurchaseTaxLevel.length; i++) {
	            	if ($scope.VendorModal.PurchaseTaxLevel[i].Id && ($scope.VendorModal.PurchaseTaxLevel[i].Id).includes($scope.VendorModal.VendorMasterData.DefaultOrderingTaxId)) {
	                    $scope.VendorModal.SelectedPurchaseTaxLevel = $scope.VendorModal.PurchaseTaxLevel[i];
	                }
	            }
	            if(!$scope.VendorModal.SelectedPurchaseTaxLevel) {
	            	for (var i = 0; i < $scope.VendorModal.PurchaseTaxLevel.length; i++) {
		            	if ($scope.VendorModal.PurchaseTaxLevel[i].IsDefault) {
		                    $scope.VendorModal.SelectedPurchaseTaxLevel = $scope.VendorModal.PurchaseTaxLevel[i];
		                }
		            }
	            }
	        }
	        $scope.VendorModal.SetDafaultPartCategory = function() {
	            for (var i = 0; i < $scope.VendorModal.PartCategory.length; i++) {
	                if ($scope.VendorModal.PartCategory[i].IsDefault) {
	                    $scope.VendorModal.SelectedPartCategory = $scope.VendorModal.PartCategory[i];
	                }
	            }
	        }
	        $scope.VendorModal.SetDafaultMerchandiseCategory = function() {
	            for (var i = 0; i < $scope.VendorModal.PartCategory.length; i++) {
	                if ($scope.VendorModal.PartCategory[i].IsDefault) {
	                    $scope.VendorModal.SelectedMerchandiseCategory = $scope.VendorModal.PartCategory[i];
	                }
	            }
	        }
	        $scope.VendorModal.changeAccountType = function(AccountTypeRec){
	        	 $scope.VendorModal.SelectedAccountType.AccountType = AccountTypeRec.AccountType;
	             $scope.VendorModal.SelectedAccountType.AccountTypeId = AccountTypeRec.Id;
	        }
	        $scope.VendorModal.changeBillingCountry = function() {
	            $scope.VendorModal.State = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedCountry.CountryName];
	            $scope.VendorModal.SelectedState = $scope.VendorModal.State[0];
	        }
	        $scope.VendorModal.changeShippingCountry = function() {
	            $scope.VendorModal.ShippingState = $scope.VendorModal.VendorMasterData.StateList[0].countryNameToStateMap[$scope.VendorModal.SelectedShippingCountry.CountryName];
	            $scope.VendorModal.SelectedShippingState = $scope.VendorModal.ShippingState[0];
	        }
	        $scope.VendorModal.SetAddressData = function() {
	            $scope.VendorModal.VendorInfo.IsBothAddressSame = ($scope.VendorModal.VendorInfo.IsBothAddressSame == true) ? false : true;
	            if ($scope.VendorModal.VendorInfo.IsBothAddressSame == true) {
	                $scope.VendorModal.VendorInfo.ShippingStreet1 = $scope.VendorModal.VendorInfo.BillingStreet1;
	                $scope.VendorModal.VendorInfo.ShippingStreet2 = $scope.VendorModal.VendorInfo.BillingStreet2;
	                $scope.VendorModal.VendorInfo.ShippingCity = $scope.VendorModal.VendorInfo.BillingCity;
	                $scope.VendorModal.VendorInfo.ShippingPostalCode = $scope.VendorModal.VendorInfo.BillingPostalCode;
	                $scope.VendorModal.SelectedShippingCountry = $scope.VendorModal.SelectedCountry;
	                $scope.VendorModal.SelectedShippingState = $scope.VendorModal.SelectedState;
	            }
	        }
	        $scope.ProductAndServicesMap = {
	            PartPurchase: 'IsPartPurchases',
	            UnitPurchase: 'IsUnitPurchases',
	            SubletPurchase: 'IsSubletPurchases',
	            ClaimsForServiceWork: 'IsClaimsForServiceWork',
	            WarrantyPlans: 'IsWarrantyPlans',
	            FinanceCompany: 'IsFinanceCompany',
	            FinancingProducts: 'IsFinancingProducts',
	            FlooringCompany: 'IsFlooringCompany',
	            MerchandisePurchase: 'IsMerchandisePurchases'
	        };
	        $scope.VendorModal.SetProductAndServices = function(checkBoxName) {
	            $scope.VendorModal.VendorInfo[$scope.ProductAndServicesMap[checkBoxName]] = !$scope.VendorModal.VendorInfo[$scope.ProductAndServicesMap[checkBoxName]];
	            if($scope.VendorModal.VendorInfo[$scope.ProductAndServicesMap[checkBoxName]]){
	            	displayCorrespondingFieldForProductAndService(checkBoxName);
	            }
	        }
	        function displayCorrespondingFieldForProductAndService(checkBoxName) {
	        	switch(checkBoxName) {
	            	case 'PartPurchase'			: $scope.VendorModal.AdditionalFieldsInfo['PartCategory'].isPrimary = true; break;
	            	case 'ClaimsForServiceWork'	: $scope.VendorModal.AdditionalFieldsInfo['SalesPriceLevel'].isPrimary = true; break;
	            	case 'MerchandisePurchase' 	: $scope.VendorModal.AdditionalFieldsInfo['MerchandiseCategory'].isPrimary = true; break;
            	}
	        }
	        $scope.VendorModal.SaveVendor = function() {
	            if ($scope.VendorModal.disableSaveButton) {
	                return;
	            }
	            for (var key in $scope.VendorModal.VendorValidation) {
	                if ($scope.VendorModal.VendorValidation.hasOwnProperty(key)) {
	                    var validationObj = $scope.VendorModal.VendorValidation[key];
	                    if (validationObj.Type.indexOf('required') > -1) {
	                        if ($scope.VendorModal.VendorInfo[key] == undefined || $scope.VendorModal.VendorInfo[key] == "") {
	                            $scope.VendorModal.VendorValidation[key]['isError'] = true;
	                            $scope.VendorModal.VendorValidation[key]['ErrorMessage'] = $translate.instant('Field_Is_Required');
	                        }
	                    }
	                }
	            }
	            for (var key in $scope.VendorModal.VendorValidation) {
	                if ($scope.VendorModal.VendorValidation.hasOwnProperty(key)) {
	                    var validationObj = $scope.VendorModal.VendorValidation[key];
	                    if (validationObj.isError == true) {
	                        return;
	                    }
	                }
	            }
	            for (var key in $scope.VendorModal.VendorInfo) {
	                if (key == 'PreferredPhone' || key == 'PreferredEmail' || key == 'PreferredSMS') {
	                    if ($scope.VendorModal.VendorInfo[key] != null && $scope.VendorModal.VendorInfo[key] != undefined && $scope.VendorModal.VendorInfo[key] != "") {
	                        var preferredValue = $scope.VendorModal.VendorInfo[key];
	                        if ($scope.VendorModal.VendorInfo[preferredValue] == null || $scope.VendorModal.VendorInfo[preferredValue] == undefined) {
	                            $scope.VendorModal.VendorValidation[preferredValue].isError = true;
	                            $scope.VendorModal.VendorValidation[preferredValue].ErrorMessage = $translate.instant('Field_Is_Required');
	                            return;
	                        }
	                    }
	                }
	            }
	            for (var key in $scope.VendorModal.AdditionalFieldsInfo) {
	                if ($scope.VendorModal.AdditionalFieldsInfo.hasOwnProperty(key)) {
	                    var validationObj = $scope.VendorModal.AdditionalFieldsInfo[key];
	                    if (validationObj['isPrimary'] == false && key != 'Active') {
	                        $scope.VendorModal.VendorInfo[key] = "";
	                    }
	                }
	            }
	            $scope.VendorModal.VendorInfo.BillingCountry = $scope.VendorModal.SelectedCountry['CountryName'];
	            try {
	                $scope.VendorModal.VendorInfo.BillingState = $scope.VendorModal.SelectedState['StateName'];
	            } catch (err) {
	                Notification.error($translate.instant('NewAddEditVendor_Billing_state'));
	                return;
	            }
	            if ($scope.VendorModal.VendorInfo.IsBothAddressSame != true) {
	                $scope.VendorModal.VendorInfo.ShippingCountry = $scope.VendorModal.SelectedShippingCountry['CountryName'];
	                try {
	                    $scope.VendorModal.VendorInfo.ShippingState = $scope.VendorModal.SelectedShippingState['StateName'];
	                } catch (err) {
	                    Notification.error($translate.instant('NewAddEditVendor_Shipping_state'));
	                    return;
	                }
	            } else {
	                $scope.VendorModal.VendorInfo.ShippingStreet1 = $scope.VendorModal.VendorInfo.BillingStreet1;
	                $scope.VendorModal.VendorInfo.ShippingStreet2 = $scope.VendorModal.VendorInfo.BillingStreet2;
	                $scope.VendorModal.VendorInfo.ShippingCity = $scope.VendorModal.VendorInfo.BillingCity;
	                $scope.VendorModal.VendorInfo.ShippingPostalCode = $scope.VendorModal.VendorInfo.BillingPostalCode;
	                $scope.VendorModal.VendorInfo.ShippingCountry = $scope.VendorModal.VendorInfo.BillingCountry;
	                $scope.VendorModal.VendorInfo.ShippingState = $scope.VendorModal.VendorInfo.BillingState;
	            }
	            if ($scope.VendorModal.AdditionalFieldsInfo['SalesPriceLevel'].isPrimary == true) {
	                $scope.VendorModal.VendorInfo.SalesPriceLevelId = $scope.VendorModal.SelectedSalesPriceLevel.Id;
	            } else {
	                $scope.VendorModal.VendorInfo.SalesPriceLevelId = null;
	            }
	            if ($scope.VendorModal.AdditionalFieldsInfo['PurchaseTaxLevel'].isPrimary == true) {
	                $scope.VendorModal.VendorInfo.PurchaseTaxLevelId = $scope.VendorModal.SelectedPurchaseTaxLevel.Id;
	            } else {
	                $scope.VendorModal.VendorInfo.PurchaseTaxLevelId = null;
	            }
	            if ($scope.VendorModal.AdditionalFieldsInfo['PartCategory'].isPrimary == true) {
	                $scope.VendorModal.VendorInfo.PartCategoryId = $scope.VendorModal.SelectedPartCategory.Id;
	            } else {
	                $scope.VendorModal.VendorInfo.PartCategoryId = null;
	            }
	            if ($scope.VendorModal.AdditionalFieldsInfo['MerchandiseCategory'].isPrimary == true) {
	                $scope.VendorModal.VendorInfo.MerchandiseCategoryId = $scope.VendorModal.SelectedMerchandiseCategory.Id;
	            } else {
	                $scope.VendorModal.VendorInfo.MerchandiseCategoryId = null;
	            }
	            $scope.VendorModal.VendorInfo.RetailRounding = $scope.VendorModal.VendorInfo.RetailRounding_Option.value;
	            $scope.VendorModal.VendorInfo.RetailBaseValue = $scope.VendorModal.VendorInfo.RetailBaseValue_Option.label;
	            if (($scope.VendorModal.VendorInfo.Increase_Decrease_Option.label === "More" && parseFloat($scope.VendorModal.VendorInfo.RetailRate) < 0) || ($scope.VendorModal.VendorInfo.Increase_Decrease_Option.label === "Less" && parseFloat($scope.VendorModal.VendorInfo.RetailRate) > 0)) {
	                $scope.VendorModal.VendorInfo.RetailRate = parseFloat($scope.VendorModal.VendorInfo.RetailRate) * -1;
	            }
	            if($scope.VendorModal.SelectedAccountType) {
	            	$scope.VendorModal.VendorInfo.AccountTypeName = $scope.VendorModal.SelectedAccountType.AccountType;
	            	$scope.VendorModal.VendorInfo.AccountTypeId = $scope.VendorModal.SelectedAccountType.AccountTypeId;
	            }
	            $scope.VendorModal.disableSaveButton = true; 
	            addEditVendorService.saveVendor(angular.toJson($scope.VendorModal.VendorInfo)).then(function(saveResult) {
	                Notification.success($translate.instant('Generic_Saved')); 
	                $scope.VendorModal.disableSaveButton = false; 
	                if ($scope.$parent.vendorRecordSaveCallback != undefined && $scope.VendorModal.IsEditMode) { 
	                    angular.element('#newVendor').modal('hide');
	                    hideModelWindow();
	                    $scope.$parent.vendorRecordSaveCallback();
	                    loadState($state, 'ViewVendor', {
	                        Id: $rootScope.$previousStateParams.Id
	                    });
	                } else if ($scope.VendorModal.isOpenFromSelectVendor != undefined && $scope.VendorModal.isOpenFromSelectVendor != '') {
	                    angular.element('#newVendor').modal('hide');
	                    hideModelWindow();
	                    $scope.$emit("selectedCustomerCallback", saveResult.Id);
	                } else {
	                    angular.element('#newVendor').modal('hide');
	                    hideModelWindow();
	                    loadState($state, 'ViewVendor', {
	                        Id: saveResult.Id
	                    });
	                }
	                $scope.VendorModal.ClearAllData();
	                angular.element('#newVendor').modal('hide');
	            }, function(errorSearchResult) {
	                $scope.VendorModal.disableSaveButton = false;   
	                responseData = errorSearchResult;
	            });
	        }
	        $scope.VendorModal.markFavourite = function(key, modalName) {
	            if ($scope.VendorModal.VendorInfo[key] == modalName) {
	                $scope.VendorModal.VendorInfo[key] = '';
	                if (modalName == 'WorkNumber' && key == 'PreferredSMS') {
	                    $scope.VendorModal.VendorInfo.WorkNumberSMS = false;
	                } else if (modalName == 'OtherPhone' && key == 'PreferredSMS') {
	                    $scope.VendorModal.VendorInfo.MobileNumberSMS = false;
	                }
	            } else {
	                $scope.VendorModal.VendorInfo[key] = modalName;
	                if (modalName == 'WorkNumber' && key == 'PreferredSMS') {
	                    $scope.VendorModal.VendorInfo.WorkNumberSMS = true;
	                } else if (modalName == 'OtherPhone' && key == 'PreferredSMS') {
	                    $scope.VendorModal.VendorInfo.MobileNumberSMS = true;
	                }
	            }
	        }
	        $scope.VendorModal.markSMS = function(key) {
	            $scope.VendorModal.VendorInfo[key] = !$scope.VendorModal.VendorInfo[key];
	            if ($scope.VendorModal.VendorInfo[key] == false) {
	                if ($scope.VendorModal.VendorInfo.PreferredSMS == 'WorkNumber' && key == 'WorkNumberSMS') {
	                    $scope.VendorModal.VendorInfo.PreferredSMS = '';
	                }
	                if ($scope.VendorModal.VendorInfo.PreferredSMS == 'OtherPhone' && key == 'MobileNumberSMS') {
	                    $scope.VendorModal.VendorInfo.PreferredSMS = '';
	                }
	            }
	        }
	        $scope.VendorModal.loadVendorMasterData();
	    }])
	});