define(['Routing_AppJs_PK', 'UserSettingsServices', 'dirNumberInput', 'JqueryUI', 'NumberOnlyInput_New', 'underscore_min', 'moment'], function(Routing_AppJs_PK, UserSettingsServices, dirNumberInput, JqueryUI, NumberOnlyInput_New, underscore_min, moment) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('userSettingController', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', '$window', '$document', '$location', 'UserSettingService','$translate', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, $window, $document, $location, UserSettingService,$translate) {
        var Notification = injector1.get("Notification");
        $scope.currentusername = $Global.UserFirstName;
        $scope.currentUserGroupName = $Global.userGroupName;
        $scope.currentUserGroupColor = $Global.userGroupColor;
        $scope.currentuseremail = $Global.UserEmail;
        $scope.showAddNewCustomer = true;
        $scope.UserSettingModel = {};
        $scope.UserSettingModel.IsTrialOrg = $Global.IsTrialOrg;
        $scope.UserSettingModel.communityURL = $Global.communityURL;
        $scope.UserSettingModel.communityQuestionURL = $Global.communityquestionURL;
        $scope.UserSettingModel.communityCaseURL = $Global.communitycaseURL;
        $scope.UserSettingModel.isLoading = false;
        $scope.UserSettingModel.UserList = [];
        $scope.UserSettingModel.FeeNameStr = "";
        $scope.UserSettingModel.ApplicableFeeStr = "";
        $scope.UserSettingModel.AccountTypeJson = {};
        $scope.UserSettingModel.dateFormat = $Global.DateFormat;
        $scope.UserSettingModel.currentSelectedEnvFeeIndex = -1;
        $scope.UserSettingModel.isPeriod1Valid = true;
        $scope.UserSettingModel.isPeriod2Valid = true;
        $scope.UserSettingModel.isPeriod3Valid = true;
        $scope.UserSettingModel.isShopSuppliesValid = true;
        $scope.UserSettingModel.AccountTypeId = '';
        $scope.UserSettingModel.isSuppliesRateValid = true;
        $scope.UserSettingModel.isMaximumPerInvoiceValid = true;
        $scope.UserSettingModel.isApplicableFeeValid = true;
        $scope.UserSettingModel.isLoadTechScheduling = $Global.IsLoadTechScheduling;
        $scope.UserSettingModel.IsFusionMappingEnabled = $Global.IsFusionMappingEnabled;
        
        $scope.UserSettingModel.currentDropDownIndex = -1;
        var newUrl = window.location.origin;
        $scope.UserSettingsHomePage = {};
        $scope.UserSettingsHomePage.isShow = true;
        $scope.UserSettingModel.AppliesToList = [{
            "Name": "Customers"
        }, {
            "Name": "Vendors"
        }];
        
        $scope.UserSettingModel.Settings = [{
            "Name": "Accounting_integration",
            "Description": "Setup_maintain_accounting_data",
            "ImageURL": "Accounting-integration.svg"
        }, {
            "Name": "Label_Billing",
            "Description": "Billing_payment_history",
            "ImageURL": "Billing.svg"
        }, {
            "Name": "Business_profile",
            "Description": "Update_information_business",
            "ImageURL": "Business-profile.svg"
        }, {
            "Name": "Categories",
            "Description": "Create_manage_categories",
            "ImageURL": "Categories.svg"
        }, 
        {
            "Name": "Cash_drawers",
            "Description": "Manage_and_create_additional_registers",
            "ImageURL": "Cash-drawers.svg"
        },
        {
            "Name": "Form_repository",
            "Description": "Setup_and_manage_your_forms",
            "ImageURL": "Form-repository.svg"
        }, {
            "Name": "Fusion_mapping",
            "Description": "Map_your_transactional_data_for_HD-fusion",
            "ImageURL": "Fusion-mapping.svg"
        }, {
            "Name": "Linked_fee_management",
            "Description": "Set_up_automated_fees",
            "ImageURL": "Linked-fee.svg"
        }, {
            "Name": "Linked_form_management",
            "Description": "Set_up_your_list_of_automated_forms",
            "ImageURL": "Linked-form.svg"
        }, {
            "Name": "Make_model",
            "Description": "Create_makes_models",
            "ImageURL": "Makes-models.svg"
        }, {
            "Name": "Settings_and_controls",
            "Description": "System_wide_settings_controls_and_defaults",
            "ImageURL": "Settings-controls.svg"
        }, {
            "Name": "Support",
            "Description": "Help_and_community",
            "ImageURL": "Support.svg"
        }, {
            "Name": "Tag_management",
            "Description": "Create_manage_tags",
            "ImageURL": "Tag-management.svg"
        }, {
            "Name": "Tax_management",
            "Description": "Price_levels_and_sales_tax",
            "ImageURL": "Sales-tax.svg"
        }, {
            "Name": "User_permissions",
            "Description": "Manage_user_permissions",
            "ImageURL": "User-permissions.svg"
        }, {
            "Name": "Users",
            "Description": "Add_view _and_manage_users",
            "ImageURL": "Users.svg"
        }];
        $scope.UserSettingModel.openAddEditAccountTypeModalWindow = function(Id) {
            setDefaultValidationModel();
            setTimeout(function() {
                angular.element('#add-account-type').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            GetTaxExempData(Id)
        }
        function GetTaxExempData(accountTypeId) {
            if (accountTypeId) {
                $scope.UserSettingModel.AccountTypeId = accountTypeId;
                UserSettingService.getRecForAccountType($scope.UserSettingModel.AccountTypeId).then(function(successResul) {
                    $scope.UserSettingModel.AccountTypeJson = successResul;
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            } else {
                UserSettingService.getAllActiveSalesTax().then(function(successResul) {
                    $scope.UserSettingModel.AccountTypeJson.TaxExemptionsList = successResul;
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
                $scope.UserSettingModel.AccountTypeJson.AppliesTo = "Customers";
            }
        }

        $scope.UserSettingModel.changeActiveFlagForrAccountType = function(id,event,type,isUpdate) {
             var isOtherActiveDefaultrAccountTypeAvailable = false;
             if(!isUpdate && id) {
                  event.preventDefault();
                  Notification.error('This account type is already in use.');
                  return;
             }
             if ($scope.UserSettingModel.AccountTypeJson.IsActive) { // Current value (Active true) before click on checkbox and user is trying to deactivate it
                 for(var i=0; i<$scope.UserSettingModel.AccountTypeMasterData.length;i++) {
                        if($scope.UserSettingModel.AccountTypeMasterData[i].AppliesTo === type && $scope.UserSettingModel.AccountTypeMasterData[i].Id != id 
                                && $scope.UserSettingModel.AccountTypeMasterData[i].IsActive && $scope.UserSettingModel.AccountTypeMasterData[i].IsDefault) {
                            isOtherActiveDefaultrAccountTypeAvailable = true;
                            break;
                        }
                 }
                 
                 if(!isOtherActiveDefaultrAccountTypeAvailable && event != undefined) {
                     event.preventDefault();
                     Notification.error('Unable to deactivate default account type. Change the default account type first.');
                 } else {
                     $scope.UserSettingModel.AccountTypeJson.IsDefault = false;
                     $scope.UserSettingModel.AccountTypeJson.IsActive = false;
                 }
             }else {
                 $scope.UserSettingModel.AccountTypeJson.IsActive = true;
             }
          }


        $scope.UserSettingModel.chnageDefaultFlagForAccountType = function (Id,event,type) {
            var index = _.findIndex($scope.UserSettingModel.AccountTypeMasterData, {
                        'Id': Id
            });
              if(index != -1 && $scope.UserSettingModel.AccountTypeMasterData[index].IsDefault) {  
                  event.preventDefault();
                  Notification.error('You cannot deselect a default account type.');
                 return;
              }

                $scope.UserSettingModel.isValidForm = true;
                $scope.UserSettingModel.validateAccountType();
                if (!$scope.UserSettingModel.isValidForm) {
                    event.preventDefault();
                    return;
                }
                var isOthertherDefualtAccountTypeAvailable = false;
                var defualtAccountTypeIndex = -1;
              if (!$scope.UserSettingModel.AccountTypeJson.IsDefault) { // Current value (Default false) before click on checkbox and user is trying to set default to true
                  for(var i=0; i<$scope.UserSettingModel.AccountTypeMasterData.length;i++) {
                        if($scope.UserSettingModel.AccountTypeMasterData[i].AppliesTo === type
                                && $scope.UserSettingModel.AccountTypeMasterData[i].Id != Id 
                                && $scope.UserSettingModel.AccountTypeMasterData[i].IsDefault) {
                            isOthertherDefualtAccountTypeAvailable = true;
                            defualtAccountTypeIndex = i;
                            break;
                        }
                 }
                  
                 if(isOthertherDefualtAccountTypeAvailable && defualtAccountTypeIndex != -1 && event != undefined) {
                     event.preventDefault();
                     //AccountTypeList = [];
                     $scope.UserSettingModel.defaultAccountTypeList = {};
                     $scope.UserSettingModel.defaultAccountTypeList = angular.copy($scope.UserSettingModel.AccountTypeMasterData[defualtAccountTypeIndex]);
                     angular.element('#change-default-account-type').modal({
                            backdrop: 'static',
                            keyboard: false
                    });
                 } else {
                     $scope.UserSettingModel.AccountTypeJson.IsDefault.IsDefault = true;
                     $scope.UserSettingModel.AccountTypeJson.IsDefault.IsActive = true;
                 }
             } else { 
                 $scope.UserSettingModel.AccountTypeJson.IsDefault.IsDefault = false;
            }

        }

        $scope.UserSettingModel.confirmChangeDefault = function() {
            $scope.UserSettingModel.defaultAccountTypeList.IsDefault = false;
             $scope.UserSettingModel.AccountTypeJson.IsDefault = true;
              $scope.UserSettingModel.AccountTypeJson.IsActive = true;
             $scope.UserSettingModel.hideCoinfirmDefaultModalWindow();
        }

        $scope.UserSettingModel.hideCoinfirmDefaultModalWindow = function() {
             angular.element('#change-default-account-type').modal('hide');
            angular.element("body").removeClass("modal-open");
        }
        angular.element(document).on("click", "#add-account-type .modal-backdrop", function() {
            $scope.UserSettingModel.hideAccountTypeModalWindow();
        });

        function setDefaultValidationModel() {
            $scope.UserSettingModel.AccountTypeValidationModal = {
                AccountType: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,Duplicate',
                    Maxlength: 50
                },
                AppliesTo: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            };
        }
        $scope.UserSettingModel.validateAccountType = function() {
            angular.forEach($scope.UserSettingModel.AccountTypeValidationModal, function(value, key) {
                $scope.UserSettingModel.validateFieldWithKey(key);
            });
        }
        $scope.UserSettingModel.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
            var keyCode = event.which ? event.which : event.keyCode;
            var tempList = angular.copy(dropdownList);
            var dropDownDivId = '#' + dropdownDivId;
            var idSubStr = '';
            var totalRecordsToTraverse = 0;
            if (tempList) {
                totalRecordsToTraverse += tempList.length;
            }
            if (keyCode == 40 && totalRecordsToTraverse > 0) {
                if (totalRecordsToTraverse - 1 > $scope.UserSettingModel.currentDropDownIndex) {
                    $scope.UserSettingModel.currentDropDownIndex++;
                    if (templateName == 'appliesto') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else
                        idSubStr = '#appliesto_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.UserSettingModel.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.UserSettingModel.currentDropDownIndex > 0) {
                    $scope.UserSettingModel.currentDropDownIndex--;
                    if (templateName == 'appliesto') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.M_FormRepository.currentDropDownIndex which is incrementing in if and decrementing in else  
                        idSubStr = '#appliesto_';
                    }
                    angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.UserSettingModel.currentDropDownIndex)[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.UserSettingModel.currentDropDownIndex !== -1) {
                if (templateName == 'appliesto') {
                    $scope.UserSettingModel.setAppliesTo(tempList[$scope.UserSettingModel.currentDropDownIndex].Name);
                }
                $scope.UserSettingModel.currentDropDownIndex = -1;
            }
        }
        $scope.UserSettingModel.validateFieldWithKey = function(modelKey) {
            var fieldValue = $scope.UserSettingModel.AccountTypeJson[modelKey];
            var validateType = $scope.UserSettingModel.AccountTypeValidationModal[modelKey].Type;
            var isError = false;
            var ErrorMessage = '';
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            if (validateType.indexOf('Duplicate') > -1){
                for(var i =0; i<$scope.UserSettingModel.AccountTypeMasterData.length;i++) {
                    if((!$scope.UserSettingModel.AccountTypeId || ($scope.UserSettingModel.AccountTypeMasterData && $scope.UserSettingModel.AccountTypeId != $scope.UserSettingModel.AccountTypeMasterData[i].Id))) {
                        if(fieldValue.toLowerCase() == $scope.UserSettingModel.AccountTypeMasterData[i].AccountType.toLowerCase()) {
                             isError = true;
                             ErrorMessage = $translate.instant('Duplicate Value');
                             break;
                        }
                    }
                }
               
            }
            $scope.UserSettingModel.AccountTypeValidationModal[modelKey].isError = isError;
            $scope.UserSettingModel.AccountTypeValidationModal[modelKey].ErrorMessage = ErrorMessage;
            if ($scope.UserSettingModel.AccountTypeValidationModal[modelKey].isError == true) {
                $scope.UserSettingModel.isValidForm = false;
            }
        }

        $scope.UserSettingModel.preventDefaultAction = function(event) {
            event.preventDefault();
        }

        $scope.UserSettingModel.setAppliesTo = function(Appliesto) {
            $scope.UserSettingModel.AccountTypeJson.AppliesTo = Appliesto;
            $scope.UserSettingModel.showAppliesToDropDown = false;
        }
        $scope.UserSettingModel.saveAccountType = function() {
            $scope.UserSettingModel.isValidForm = true;
            $scope.UserSettingModel.validateAccountType();
            if (!$scope.UserSettingModel.isValidForm) {
                return;
            }
            if (!$scope.UserSettingModel.AccountTypeId) {
                $scope.UserSettingModel.AccountTypeJson.IsActive = true;
                $scope.UserSettingModel.AccountTypeJson.IsDefault = false;
            }
           
           if($scope.UserSettingModel.defaultAccountTypeList) {
             var defaultCheckIndex = _.findIndex($scope.UserSettingModel.AccountTypeMasterData, {
                        Id: $scope.UserSettingModel.defaultAccountTypeList.Id
            });
             $scope.UserSettingModel.AccountTypeMasterData[defaultCheckIndex].IsDefault = false;
           }
            UserSettingService.saveAccountType(angular.toJson($scope.UserSettingModel.AccountTypeJson)).then(function(successResul) {
                var tempdesc = '';
                    for(var i=0;i<$scope.UserSettingModel.AccountTypeJson.TaxExemptionsList.length;i++) {
                        if($scope.UserSettingModel.AccountTypeJson.TaxExemptionsList[i].IsSelected) {
                            tempdesc += $scope.UserSettingModel.AccountTypeJson.TaxExemptionsList[i].SalesTaxName + ',';
                         }
                    } 
                    tempdesc = tempdesc.slice(0,tempdesc.length-1);
                    tempAccountTypeJson = {
                        "AccountType" : $scope.UserSettingModel.AccountTypeJson.AccountType,
                        "AppliesTo" : $scope.UserSettingModel.AccountTypeJson.AppliesTo,
                        "Id" : successResul,
                        "IsActive" : $scope.UserSettingModel.AccountTypeJson.IsActive,
                        "IsDefault" : $scope.UserSettingModel.AccountTypeJson.IsDefault,
                        "TaxExemptions" : tempdesc.length ? tempdesc : 'None'

                    }
                if(!$scope.UserSettingModel.AccountTypeId) {
                    $scope.UserSettingModel.AccountTypeMasterData.push(tempAccountTypeJson);
                } else {
                    var index = _.findIndex($scope.UserSettingModel.AccountTypeMasterData, {
                        Id: $scope.UserSettingModel.AccountTypeId
                    });
                    $scope.UserSettingModel.AccountTypeMasterData[index] = tempAccountTypeJson;
                }
                SortAccountTypeList($scope.UserSettingModel.AccountTypeMasterData);
                $scope.UserSettingModel.hideAccountTypeModalWindow();
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
            //saveAccountType
        }
        $scope.UserSettingModel.hideAccountTypeModalWindow = function() {
            angular.element('#add-account-type').modal('hide');
            angular.element("body").removeClass("modal-open");
            $scope.UserSettingModel.AccountTypeJson = {};
            $scope.UserSettingModel.AccountTypeId = '';
        }
        $scope.UserSettingModel.handleSettingAction = function(settingName) {
            if (settingName === 'Accounting_integration') {
                $scope.UserSettingModel.MoveToState('AccountingIntegrationSettings');
            } else if (settingName === 'Label_Billing') {
                $scope.UserSettingModel.MoveToState('UserSetting', {
                    Id: 'Billing'
                });
            } else if (settingName === 'Business_profile') {
                $scope.UserSettingModel.MoveToState('UserSetting', {
                    Id: 'Business_Profile'
                });
            } else if (settingName === 'Categories') {
                $scope.UserSettingModel.MoveToPage('CategoryMgmt');
            } else if (settingName === 'Form_repository') {
                $scope.UserSettingModel.MoveToState('FormRepository');
            } else if (settingName === 'Linked_fee_management') {
                $scope.UserSettingModel.MoveToState('LinkedFee');
            } else if (settingName === 'Make_model') {
                $scope.UserSettingModel.MoveToPage('MakeMgmt');
            } else if (settingName === 'Settings_and_controls') {
                $scope.UserSettingModel.MoveToState('UserSetting', {
                    Id: 'Price_And_Tax'
                });
            } else if (settingName === 'Support') {
                $scope.UserSettingModel.MoveToState('UserSetting', {
                    Id: 'Support'
                });;
            } else if (settingName === 'Tag_management') {
                $scope.UserSettingModel.MoveToState('TagManagement');
            } else if (settingName === 'Tax_management') {
                $scope.UserSettingModel.MoveToPage('SystemSettings');
            } else if (settingName === 'User_permissions') {
                $scope.UserSettingModel.MoveToState('GroupSummary');
            } else if (settingName === 'Users') {
                $scope.UserSettingModel.MoveToState('User');
            } else if (settingName === 'Linked_form_management') {
                $scope.UserSettingModel.MoveToState('LinkedForm');
            } else if (settingName === 'Fusion_mapping') {
                $scope.UserSettingModel.MoveToState('FusionMapping');
            }  else if (settingName === 'Cash_drawers') {
                $scope.UserSettingModel.MoveToState('CashDrawer');
            }
        }
        $scope.UserSettingModel.displaySettingTile = function(settingName) {
            if (settingName === 'Fusion_mapping' && !$scope.UserSettingModel.IsFusionMappingEnabled) {
                return false;
            } else {
                return true;
            }
        }
        $scope.billingdateOptions = {
            minDate: new Date,
            dateFormat: $scope.UserSettingModel.dateFormat
        };
        $scope.$on('autoCompleteSelectCallback', function(event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            if (searchResult != null) {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.DefaultEnvironmentalFee = searchResult.originalObject.Value;
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.ApplicableFee = searchResult.originalObject.Value;
            }
        });
        $scope.UserSettingModel.FeeFieldsFilter = {
            ActiveFee: [{
                Field: "Active__c",
                Value: true,
                FilterObject: "Fee__c"
            }]
        };
        $scope.$on('UpgradeAccount', function() {
            $scope.UserSettingModel.navigateToScreen('Billing');
        });
        $scope.UserSettingModel.validatePeriod1Field = function() {
            var priceObj = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData;
            if ((parseFloat(priceObj.Period1) < parseFloat(priceObj.Period2)) && parseFloat(priceObj.Period1) > 0) {
                $scope.UserSettingModel.isPeriod1Valid = true;
            } else {
                $scope.UserSettingModel.isPeriod1Valid = false;
            }
        }
        $scope.UserSettingModel.validatePeriod2Field = function() {
            var priceObj = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData;
            if ((parseFloat(priceObj.Period1) < parseFloat(priceObj.Period2)) && parseFloat(priceObj.Period2) > 0) {
                $scope.UserSettingModel.isPeriod2Valid = true;
            } else {
                $scope.UserSettingModel.isPeriod2Valid = false;
            }
        }
        $scope.UserSettingModel.validatePeriod3Field = function() {
            var priceObj = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData;
            if ((parseFloat(priceObj.Period2) < parseFloat(priceObj.Period3)) && parseFloat(priceObj.Period3) > 0) {
                priceObj.Period4 = 'Greater than ' + priceObj.Period3;
                $scope.UserSettingModel.isPeriod3Valid = true;
            } else {
                $scope.UserSettingModel.isPeriod3Valid = false;
            }
        }
        $scope.UserSettingModel.validateShopSuppliesSection = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CalculationMethod != 'Not Calculated') {
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SuppliesRate != '') {
                    $scope.UserSettingModel.isSuppliesRateValid = true;
                } else {
                    $scope.UserSettingModel.isSuppliesRateValid = false;
                }
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.MaximumPerInvoice != '') {
                    $scope.UserSettingModel.isMaximumPerInvoiceValid = true;
                } else {
                    $scope.UserSettingModel.isMaximumPerInvoiceValid = false;
                }
                if ($scope.UserSettingModel.ApplicableFeeStr != '') {
                    $scope.UserSettingModel.isApplicableFeeValid = true;
                } else {
                    $scope.UserSettingModel.isApplicableFeeValid = false;
                }
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CalculationMethod != 'Not Calculated') {
                if ($scope.UserSettingModel.isSuppliesRateValid && $scope.UserSettingModel.isMaximumPerInvoiceValid && $scope.UserSettingModel.isApplicableFeeValid) {
                    $scope.UserSettingModel.isShopSuppliesValid = true;
                } else {
                    $scope.UserSettingModel.isShopSuppliesValid = false;
                }
            }
        }

        function showTooltip(containerName) {
            angular.element('[role ="tooltip"]').hide();
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'top',
                    container: containerName
                });
            }, 500);
        }
        $scope.UserSettingModel.resetSuppliesRateValue = function() {
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SuppliesRate = '';
        }
        $scope.UserSettingModel.IsPeriodValid = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData != undefined) {
                $scope.UserSettingModel.validatePeriod1Field();
                $scope.UserSettingModel.validatePeriod2Field();
                $scope.UserSettingModel.validatePeriod3Field();
                $scope.UserSettingModel.validateShopSuppliesSection();
            }
            if ($scope.UserSettingModel.isShopSuppliesValid && $scope.UserSettingModel.isPeriod1Valid && $scope.UserSettingModel.isPeriod2Valid && $scope.UserSettingModel.isPeriod3Valid && $scope.UserSettingModel.validateShopSetting()) {
                return true;
            } else {
                return false;
            }
        }
        $scope.UserSettingModel.validateShopSetting = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData) {
                var index = _.findIndex($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration, {
                    IsWorking: true
                });
                if (index > -1) {
                    return true;
                } else {
                    return false
                }
            }
            return false
        }
        $scope.UserSettingModel.validateTime = function(shopSettingLineItemIndex, timeVariable) {
            if (moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable], 'h:mmA').format('h:mmA') == "Invalid date") {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex][timeVariable];
            } else {
                if (timeVariable == 'FromTime') {
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['ToTime'] != '' && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['ToTime'] != null && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['ToTime'] != undefined && moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['FromTime'], 'h:mmA').diff(moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['ToTime'], 'h:mmA'), 'minutes') >= 0) {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex][timeVariable];
                    } else {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable], 'h:mmA').format('h:mmA');
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex] = angular.copy($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]);
                    }
                } else if (timeVariable == 'ToTime') {
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['FromTime'] != '' && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['FromTime'] != null && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['FromTime'] != undefined && moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['FromTime'], 'h:mmA').diff(moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]['ToTime'], 'h:mmA'), 'minutes') >= 0) {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex][timeVariable];
                    } else {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable], 'h:mmA').format('h:mmA');
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex] = angular.copy($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]);
                    }
                } else {
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable] = moment($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex][timeVariable], 'h:mmA').format('h:mmA');
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy[shopSettingLineItemIndex] = angular.copy($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[shopSettingLineItemIndex]);
                }
            }
        }
        $scope.UserSettingModel.resetToDefaultTime = function(indexShopSetingItem) {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData) {
                if (!$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[indexShopSetingItem].IsWorking) {
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[indexShopSetingItem].FromTime = '8:00AM';
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration[indexShopSetingItem].ToTime = '5:00PM';
                }
            }
        }
        $scope.UserSettingModel.Users = {};
        $scope.UserSettingModel.Users.toggleShowLicensedUsers = function() {
            $scope.UserSettingModel.Users.showUsersSection = !$scope.UserSettingModel.Users.showUsersSection;
            $scope.UserSettingModel.Users.showLicensedUsersSection = !$scope.UserSettingModel.Users.showLicensedUsersSection;
        };
        $scope.UserSettingModel.UserLastName = $Global.UserLastName;
        $scope.UserSettingModel.idToMapSettingState = {
            "Home": "System Settings",
            "Price_And_Tax": "Settings & Controls",
            "Import_And_Export": "Import & Export",
            "Support": "Support",
            "User": "Users",
            "Business_Profile": "Business Profile",
            "Billing": "Billing",
        };
        $scope.UserSettingModel.PriceAndTax = {};
        $scope.UserSettingModel.PriceAndTaxSectionData = {};
        $scope.UserSettingModel.PriceAndTax.PriceIncludeTax = [{
            "Label": "No",
            "Value": false
        }, {
            "Label": "Yes",
            "Value": true
        }];
        $scope.UserSettingModel.PriceAndTax.ShopSuppliesList = [{
            "Label": "Not Calculated",
            "Value": "Not Calculated"
        }, {
            "Label": "Percentage of Labor Total",
            "Value": "Percentage of Labor Total"
        }, {
            "Label": "Fixed Amount per Hour",
            "Value": "Fixed Amount per Hour"
        }];
        $scope.UserSettingModel.showDatePicker = function() {
            angular.element('#UserSettingDatePicker').focus();
        }
        $scope.UserSettingModel.PriceAndTax.toogleSectionView = function(sectionName) {
            $scope.UserSettingModel.PriceAndTax[sectionName] = !$scope.UserSettingModel.PriceAndTax[sectionName];
        }
        $scope.UserSettingModel.PriceAndTax.changeSeletedEnvFee = function(event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.UserSettingModel.PriceAndTax.FilteredEnvFeeList.length - 1) > $scope.UserSettingModel.currentSelectedEnvFeeIndex) {
                    $scope.UserSettingModel.currentSelectedEnvFeeIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.UserSettingModel.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.UserSettingModel.currentSelectedEnvFeeIndex > 0) {
                    $scope.UserSettingModel.currentSelectedEnvFeeIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.UserSettingModel.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
                $scope.UserSettingModel.PriceAndTax.selectFee($scope.UserSettingModel.PriceAndTax.FilteredEnvFeeList[$scope.UserSettingModel.currentSelectedEnvFeeIndex]);
                $scope.UserSettingModel.currentSelectedEnvFeeIndex = -1;
                $scope.UserSettingModel.PriceAndTax.closeAutocomplete('stampDutyRate');
            }
        }
        $scope.UserSettingModel.PriceAndTax.closeAutocomplete = function(eleId) {
            angular.element('#' + eleId).focus();
        }
        $scope.UserSettingModel.PriceAndTax.selectFee = function(selectedFee) {
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.DefaultEnvironmentalFee = selectedFee.Id;
            $scope.UserSettingModel.FeeNameStr = selectedFee.ItemDesc;
        };
        $scope.UserSettingModel.PriceAndTax.selectApplicableFee = function(selectedFee) {
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.ApplicableFee = selectedFee.Id;
            $scope.UserSettingModel.ApplicableFeeStr = selectedFee.ItemDesc;
        };
        $scope.UserSettingModel.PriceAndTax.timePeriodInterval = ['12:00AM', '12:30AM', '1:00AM', '1:30AM', '2:00AM', '2:30AM', '3:00AM', '3:30AM', '4:00AM', '4:30AM', '5:00AM', '5:30AM', '6:00AM', '6:30AM', '7:00AM', '7:30AM', '8:00AM', '8:30AM', '9:00AM', '9:30AM', '10:00AM', '10:30AM', '11:00AM', '11:30AM', '12:00PM', '12:30PM', '1:00PM', '1:30PM', '2:00PM', '2:30PM', '3:00PM', '3:30PM', '4:00PM', '4:30PM', '5:00PM', '5:30PM', '6:00PM', '6:30PM', '7:00PM', '7:30PM', '8:00PM', '8:30PM', '9:00PM', '9:30PM', '10:00PM', '10:30PM', '11:00PM', '11:30PM', ];

        function getPriceAndTaxMasterData() {
            var defer = $q.defer();
            UserSettingService.getPriceAndTaxMasterData().then(function(MasterData) {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData = MasterData;
                UserSettingService.getCurrentConfiguration().then(function(configurationData) {
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData = configurationData;
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfigurationCopy = angular.copy($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.shopSettingConfiguration);
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == '' || $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == null || $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == undefined) {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor = 1;
                    }
                    $scope.UserSettingModel.PriceAndTax.SetDefaultSpuppliesFee();
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.defaultPriceLevel == '' && $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.priceLevelList.length > 0) $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.defaultPriceLevel = $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.salesTaxList[0].id;
                    $scope.UserSettingModel.PriceAndTax.SetDefaultBillingCountry();
                    $scope.UserSettingModel.PriceAndTax.SetDefaultBillingState();
                    $scope.UserSettingModel.PriceAndTax.SetDefaultTimeZone();
                    $scope.UserSettingModel.PriceAndTax.SetDefaultPriceLevel();
                    defer.resolve();
                }, function(errorSearchResult) {
                    defer.reject($translate.instant('GENERIC_ERROR'));
                });
            }, function(errorSearchResult) {
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }

        function getActiveFeeList() {
            var defer = $q.defer();
            UserSettingService.getActiveFeeList().then(function(feeList) {
                $scope.UserSettingModel.PriceAndTax.ActiveFeeList = feeList;
                for (var i = 0; i < feeList.length; i++) {
                    if (feeList[i].IsDefault) {
                        $scope.UserSettingModel.FeeNameStr = feeList[i].ItemDesc;
                    }
                }
                defer.resolve();
            }, function(errorSearchResult) {
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }

        function getTaxCategoryList() {
            var defer = $q.defer();
            UserSettingService.getTaxCategoryList().then(function(taxCategoryList) {
                $scope.UserSettingModel.PriceAndTax.taxCategoryList = taxCategoryList;
                defer.resolve();
            }, function(errorSearchResult) {
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        $scope.UserSettingModel.PriceAndTax.setDefaultTradeTaxCategory = function() {
            var categoryId = '';
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.AccrueTradeTaxUntilUnitSold) {
                var deafualtTaxCategoryIndex = _.findIndex($scope.UserSettingModel.PriceAndTax.taxCategoryList, {
                    'IsDefault': true
                });
                categoryId = $scope.UserSettingModel.PriceAndTax.taxCategoryList[deafualtTaxCategoryIndex].Id;
            } else {
                categoryId = '';
            }
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxPendingSaleCategory = categoryId;
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxLiabilityCategory = categoryId;
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxExpenseCategory = categoryId;
        }
        $scope.UserSettingModel.PriceAndTax.loadPriceAndTaxData = function() {
            $scope.UserSettingModel.isLoading = true;
            $scope.UserSettingModel.PriceAndTax.isPriceAndTaxDataSaved = false;
            $q.all([$scope.UserSettingModel.PriceAndTax.getAllActiveFeeList(),
                getPriceAndTaxMasterData(),
                getActiveFeeList(),
                getAllAccountTypeData(),
                getTaxCategoryList()
            ]).then(function() {
                $scope.UserSettingModel.isLoading = false;
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
            });
        }

        function SortAccountTypeList(successResult) {
            successResult.sort(function(a, b){
                    if(a.AccountType.toLowerCase() < b.AccountType.toLowerCase()) return -1;
                    if(a.AccountType.toLowerCase() > b.AccountType.toLowerCase()) return 1;
                    return 0;
                });
                    $scope.UserSettingModel.AccountTypeMasterData  = [];
                    var tempList = [];
                    var accountTypeLength;
                    for (var i = 0; i < successResult.length; i++) {
                        if(successResult[i].IsDefault && successResult[i].AppliesTo == 'Customers') {
                            $scope.UserSettingModel.AccountTypeMasterData[0] = successResult[i];
                        }
                    }
                for (var i = 0; i < successResult.length; i++) {
                    tempList = _.filter(successResult, function(AccountType){
                        return (AccountType.AppliesTo == 'Customers' && !AccountType.IsDefault);
                    });
                }
                accountTypeLength = $scope.UserSettingModel.AccountTypeMasterData.length;
                for(var i=0;i<tempList.length; i ++) {
                    $scope.UserSettingModel.AccountTypeMasterData[accountTypeLength + i] = tempList[i];
                }
                 for (var i = 0; i < successResult.length; i++) {
                        if(successResult[i].IsDefault && successResult[i].AppliesTo == 'Vendors') {
                            $scope.UserSettingModel.AccountTypeMasterData[$scope.UserSettingModel.AccountTypeMasterData.length] = successResult[i];
                        }
                    }
                for (var i = 0; i < successResult.length; i++) {
                    tempList = _.filter(successResult, function(AccountType){
                        return (AccountType.AppliesTo == 'Vendors' && !AccountType.IsDefault);
                    });
                }
                accountTypeLength = $scope.UserSettingModel.AccountTypeMasterData.length;
                for(var i=0;i<tempList.length; i ++) {
                    $scope.UserSettingModel.AccountTypeMasterData[i+accountTypeLength] = tempList[i];
                }
                
        }

        function getAllAccountTypeData() {
            UserSettingService.getAllAccountTypeData().then(function(successResult) {
                SortAccountTypeList(successResult);
            }, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserSettingModel.PriceAndTax.getAllActiveFeeList = function() {
            var defer = $q.defer();
            UserSettingService.getAllActiveFeeList(null).then(function(feeList) {
                $scope.UserSettingModel.PriceAndTax.AllActiveFeeList = feeList;
                defer.resolve();
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }
        $scope.UserSettingModel.PriceAndTax.SetDefaultSpuppliesFee = function() {
            if ($scope.UserSettingModel.PriceAndTax.AllActiveFeeList == undefined) {
                $scope.UserSettingModel.PriceAndTax.getAllActiveFeeList();
            }
            var j = _.findIndex($scope.UserSettingModel.PriceAndTax.AllActiveFeeList, {
                Id: $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.ApplicableFee
            });
            if (j != -1) {
                $scope.UserSettingModel.ApplicableFeeStr = $scope.UserSettingModel.PriceAndTax.AllActiveFeeList[j].ItemDesc;
            }
        }
        $scope.UserSettingModel.PriceAndTax.countryChange = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.CountryName == 'Australia') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.priceIncludeTax = true;
            } else {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.priceIncludeTax = false;
            }
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.StateList;
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec[0];
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.TimezoneList;
            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[0];
        }
        $scope.UserSettingModel.PriceAndTax.stateTimeChange = function() {
            for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec.length; i++) {
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i].CountryId == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.Id && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i].StateId == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state.Id) {
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i];
                    return;
                } else {
                    $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time = '';
                }
            }
        }
        $scope.UserSettingModel.PriceAndTax.savePriceAndTaxData = function() {
            if (!isBlankValue($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CalculationMethod) && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CalculationMethod == 'Not Calculated') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SuppliesRate = null;
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.MaximumPerInvoice = null;
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.ApplicableFee = null;
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.ItemizedByLaborCode = false;
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == '' || $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == null || $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor == undefined) {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor = 1;
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor != 1) {
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor < 1) {
                    Notification.error($translate.instant('Value_Cannot_Be_Less_Than_One'));
                    return;
                } else if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.CashPaymentRoundingFactor % 5 != 0) {
                    Notification.error($translate.instant('Value_Should_Be_Multiple_Of_Five'));
                    return;
                }
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry != undefined && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry != null && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry != '') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.regionId = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.Id;
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state != undefined && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state != null && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state != '') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.stateId = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state.Id;
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time != undefined && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time != null && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time != '') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.timezoneId = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time.Id;
            }
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.AccrueTradeTaxUntilUnitSold && (!$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxPendingSaleCategory || !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxLiabilityCategory || !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TradeTaxExpenseCategory)) {
                Notification.error($translate.instant('All_trade_tax_categories_are_required'));
                return;
            }
            $scope.UserSettingModel.isLoading = true;
            UserSettingService.savePriceAndTaxData(angular.toJson($scope.UserSettingModel.PriceAndTax.PriceAndTaxData)).then(function(configurationData) {
                Notification.success($translate.instant('Generic_Saved'));
                $scope.UserSettingModel.isLoading = false;
                $scope.UserSettingModel.PriceAndTax.isPriceAndTaxDataSaved = true;
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
            });
        };
        $scope.UserSettingModel.PriceAndTax.SetDefaultBillingCountry = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.regionId == '') {
                for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList.length; i++) {
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList[i].IsDefault) {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry = $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList[i];
                    }
                }
            } else {
                for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList.length; i++) {
                    if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList[i].Id == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.regionId) {
                        $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry = $scope.UserSettingModel.PriceAndTax.PriceAndTaxMasterData.countryList[i];
                    }
                }
            }
        }
        $scope.UserSettingModel.PriceAndTax.SetDefaultPriceLevel = function() {}
        $scope.UserSettingModel.PriceAndTax.SetDefaultBillingState = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry != undefined) {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.StateList;
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.stateId == '') {
                    for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec.length; i++) {
                        if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec[i].IsDefault) {
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec[i];
                        }
                    }
                } else {
                    for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec.length; i++) {
                        if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec[i].Id == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.stateId) {
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.StateRec[i];
                        }
                    }
                }
            }
        }
        $scope.UserSettingModel.PriceAndTax.SetDefaultTimeZone = function() {
            if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry != undefined) {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.TimezoneList;
                if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.timezoneId == '') {
                    for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec.length; i++) {
                        if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i].CountryId == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.SelectedCountry.Id && $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i].StateId == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.state.Id) {
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i];
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.defaultTime = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time;
                        }
                    }
                } else {
                    for (i = 0; i < $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec.length; i++) {
                        if ($scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i].Id == $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.timezoneId) {
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.TimeRec[i];
                            $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.defaultTime = $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.Time;
                        }
                    }
                }
            }
        }
        $scope.UserSettingModel.applyFilter = function(FilterValue, event) {
            if (FilterValue == 'Customer_Invoice') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforCustomerInvoice = !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforCustomerInvoice;
            } else if (FilterValue == 'Service_Job') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforServiceJob = !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforServiceJob;
            } else if (FilterValue == 'Order_Deposit') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforOrderDeposit = !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforOrderDeposit;
            } else if (FilterValue == 'Deal_Document') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforDealDocuments = !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforDealDocuments;
            } else if (FilterValue == 'Receipts') {
                $scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforSalesReceipt = !$scope.UserSettingModel.PriceAndTax.PriceAndTaxData.IsSignatureLineforSalesReceipt;
            }
        }
        $scope.UserSettingModel.BusinessProfile = {};
        $scope.UserSettingModel.BusinessProfile.SameAsBusiness = [{
            "Level": "No",
            "Value": false
        }, {
            "Level": "Yes",
            "Value": true
        }];
        $scope.UserSettingModel.BusinessProfile.IsSaveButtonEnabled = function() {
            var isButtonEnable = true;
            angular.forEach($scope.UserSettingModel.BusinessProfileValidation, function(value, key) {
                if ($scope.UserSettingModel.BusinessProfileValidation[key]['isError'] == true) {
                    isButtonEnable = false;
                    return;
                }
            });
            return isButtonEnable;
        }
        $scope.UserSettingModel.BusinessProfileValidation = {
            BusinessName: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            BusinessEmail: {
                isError: false,
                ErrorMessage: '',
                Type: 'email,required'
            },
            BusinessPhone: {
                isError: false,
                ErrorMessage: '',
                Type: 'phone,Maxlength,Minlength,required',
                Maxlength: 10,
                Minlength: 10
            },
            BusinessStreetAddress1: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            BusinessCity: {
                isError: false,
                ErrorMessage: '',
                Type: 'required '
            },
            BusinessZipCode: {
                isError: false,
                ErrorMessage: '',
                Type: 'required Maxlength',
                Maxlength: 10
            },
            BusinessCountry: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            BusinessState: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            ShippingStreetAddress1: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            ShippingCity: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            ShippingZipCode: {
                isError: false,
                ErrorMessage: '',
                Type: 'required Maxlength',
                Maxlength: 10
            },
            ShippingCountry: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            },
            ShippingState: {
                isError: false,
                ErrorMessage: '',
                Type: 'required'
            }
        }
        $scope.UserSettingModel.ValidateBusinessProfile = function(modelKey) {
            var validationObj = $scope.UserSettingModel.BusinessProfileValidation[modelKey];
            var isError = false;
            var ErrorMessage = '';
            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            if (($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.CountryName == 'Australia') && (validationObj.Type.indexOf('phone') > -1)) {
                validationObj.Minlength = 8;
            } else if (validationObj.Type.indexOf('phone') > -1) {
                validationObj.Minlength = 10;
            }
            if (modelKey == 'IsSameAsBusinessAddress' && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj['IsSameAsBusinessAddress']) {
                $scope.UserSettingModel.BusinessProfileValidation['ShippingStreetAddress1']['isError'] = false;
                $scope.UserSettingModel.BusinessProfileValidation['ShippingStreetAddress1']['ErrorMessage'] = '';
                $scope.UserSettingModel.BusinessProfileValidation['ShippingCity']['isError'] = false;
                $scope.UserSettingModel.BusinessProfileValidation['ShippingCity']['ErrorMessage'] = '';
                $scope.UserSettingModel.BusinessProfileValidation['ShippingZipCode']['isError'] = false;
                $scope.UserSettingModel.BusinessProfileValidation['ShippingZipCode']['ErrorMessage'] = '';
                $scope.UserSettingModel.BusinessProfileValidation['ShippingCountry']['isError'] = false;
                $scope.UserSettingModel.BusinessProfileValidation['ShippingCountry']['ErrorMessage'] = '';
                $scope.UserSettingModel.BusinessProfileValidation['ShippingState']['isError'] = false;
                $scope.UserSettingModel.BusinessProfileValidation['ShippingState']['ErrorMessage'] = '';
                return;
            }
            if (modelKey != 'IsSameAsBusinessAddress') {
                if (!(modelKey.indexOf('Shipping') > -1 && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj['IsSameAsBusinessAddress'])) {
                    var validateType = validationObj.Type;
                    if (validateType.indexOf('Minlength') > -1) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != undefined && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != '' && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey].length < validationObj.Minlength) {
                            isError = true;
                            ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + validationObj.Minlength;
                        }
                    }
                    if (validateType.indexOf('Maxlength') > -1) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != undefined && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != '' && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey].length > validationObj.Maxlength) {
                            isError = true;
                            ErrorMessage = $translate.instant('Max_Length_Should_Be') + ' ' + validationObj.Maxlength;
                        }
                    }
                    if (validateType.indexOf('phone') > -1) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != undefined && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != '' && !phoneRegEx.test($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey])) {
                            isError = true;
                            ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Phone_Number');
                        }
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != undefined && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != '' && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey].length == 9 && ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.CountryName == 'Australia')) {
                            isError = true;
                            ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + '8' + $translate.instant('or') + '10';
                        }
                    }
                    if (validateType.indexOf('email') > -1) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != undefined && $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] != '' && !emailRegEx.test($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey])) {
                            isError = true;
                            ErrorMessage = $translate.instant('CustomerOrder_Js_Select_valid_email_address');
                        }
                    }
                    if (validateType.indexOf('required') > -1) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] == undefined || $scope.UserSettingModel.BusinessProfile.BusinessProfileObj[modelKey] == '') {
                            isError = true;
                            ErrorMessage = $translate.instant('Field_Is_Required');
                        }
                    }
                }
                $scope.UserSettingModel.BusinessProfileValidation[modelKey]['isError'] = isError;
                $scope.UserSettingModel.BusinessProfileValidation[modelKey]['ErrorMessage'] = ErrorMessage;
            }
        }
        $scope.UserSettingModel.BusinessProfile.toggleBusinessDetailSectionView = function() {
            $scope.UserSettingModel.BusinessProfile.showBusinessDetailSection = !$scope.UserSettingModel.BusinessProfile.showBusinessDetailSection;
        };
        $scope.UserSettingModel.BusinessProfile.toggleBusinessAddressSectionView = function() {
            $scope.UserSettingModel.BusinessProfile.showBusinessAddressSection = !$scope.UserSettingModel.BusinessProfile.showBusinessAddressSection;
        };
        $scope.UserSettingModel.BusinessProfile.toggleShippingAddressSectionView = function() {
            $scope.UserSettingModel.BusinessProfile.showShippingAddressSection = !$scope.UserSettingModel.BusinessProfile.showShippingAddressSection;
        };
        $scope.UserSettingModel.BusinessProfile.loadBusinessProfileData = function() {
            $scope.UserSettingModel.isLoading = true;
            $scope.UserSettingModel.BusinessProfile.isBusinessProfileDataSaved = false;
            UserSettingService.getBusinessProfileMasterData().then(function(BusinessProfileData) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData = BusinessProfileData.CountryList;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj = BusinessProfileData.BusinessProfileObj;
                $scope.UserSettingModel.BusinessProfile.SetDefaultCountry();
                $scope.UserSettingModel.BusinessProfile.SetDefaultState();
                $scope.UserSettingModel.isLoading = false;
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
            });
        };
        $scope.UserSettingModel.BusinessProfile.SetDefaultCountry = function() {
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj != undefined) {
                if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountryId == '') {
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[0];
                } else {
                    for (i = 0; i < $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.length; i++) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[i].Id == $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountryId) {
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[i];
                        }
                    }
                }
                if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountryId == '') {
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[0];
                } else {
                    for (i = 0; i < $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.length; i++) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[i].Id == $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountryId) {
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData[i];
                        }
                    }
                }
            }
        }
        $scope.UserSettingModel.BusinessProfile.SetDefaultState = function() {
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj != undefined) {
                if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessStateId == '') {
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList;
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec[0];
                } else {
                    for (i = 0; i < $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList.length; i++) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList[i].Id == $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessStateId) {
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList;
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList[i];
                        }
                    }
                }
                if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingStateId == '') {
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList;
                    $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec[0];
                } else {
                    for (i = 0; i < $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList.length; i++) {
                        if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList[i].Id == $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingStateId) {
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList;
                            $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList[i];
                        }
                    }
                }
            }
        }
        $scope.UserSettingModel.BusinessProfile.countryChange = function() {
            $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.StateList;
            $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec[0];
            $scope.UserSettingModel.ValidateBusinessProfile('BusinessPhone');
        }
        $scope.UserSettingModel.BusinessProfile.shippingCountryChange = function() {
            $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.StateList;
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec.length != 0) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec[0];
            }
        }
        $scope.UserSettingModel.BusinessProfile.setShippingAddressData = function() {
            if (!$scope.UserSettingModel.BusinessProfile.BusinessProfileObj.IsSameAsBusinessAddress) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingStreetAddress1 = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessStreetAddress1;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingStreetAddress2 = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessStreetAddress2;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCity = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCity;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingZipCode = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessZipCode;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.ShippingStateRec = $scope.UserSettingModel.BusinessProfile.BusinessProfileMasterData.StateRec;
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState;
            } else {
                return;
            }
        }
        $scope.UserSettingModel.BusinessProfile.saveBusinessProfileData = function() {
            if (!($scope.UserSettingModel.BusinessProfile.IsSaveButtonEnabled())) {
                return;
            }
            var isError = false;
            var elementWithError = '';
            angular.forEach($scope.UserSettingModel.BusinessProfileValidation, function(value, key) {
                $scope.UserSettingModel.ValidateBusinessProfile(key);
                if ($scope.UserSettingModel.BusinessProfileValidation[key]['isError'] == true) {
                    if (!isError) {
                        elementWithError = key;
                        isError = true;
                    }
                }
            });
            if (isError) {
                Notification.error($translate.instant('UserSettings_Error'));
                return;
            }
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry != undefined) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountryId = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.Id;
            }
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState != undefined) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessStateId = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessState.Id;
            }
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry != undefined) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountryId = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingCountry.Id;
            }
            if ($scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState != undefined) {
                $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingStateId = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.ShippingState.Id;
            }
            $scope.UserSettingModel.isLoading = true;
            $rootScope.CompanyLocale = $scope.UserSettingModel.BusinessProfile.BusinessProfileObj.BusinessCountry.CountryName;
            UserSettingService.saveBusinessProfileData(angular.toJson($scope.UserSettingModel.BusinessProfile.BusinessProfileObj)).then(function(configurationData) {
                Notification.success($translate.instant('Generic_Saved'));
                $scope.UserSettingModel.isLoading = false;
                $scope.UserSettingModel.BusinessProfile.isBusinessProfileDataSaved = true;
            });
        };
        $scope.UserSettingModel.Billing = {};
        $scope.UserSettingModel.Billing.DataToUpgrade = {};
        $scope.UserSettingModel.Billing.TimeList = [];
        $scope.UserSettingModel.countryCodeToIDDMap = {
            'IN': 91,
            'CN': 01,
            'US': 01,
            'AU': 61,
            'FR': 33
        };
        jQuery.ajax({
            url: '//freegeoip.net/json/',
            type: 'POST',
            dataType: 'jsonp',
            success: function(locationInfo) {
                $scope.UserSettingModel.LocationInfo = locationInfo;
                $scope.UserSettingModel.Billing.DataToUpgrade.IDDCode = $scope.UserSettingModel.countryCodeToIDDMap[$scope.UserSettingModel.LocationInfo.country_code];
            }
        });
        $scope.UserSettingModel.Billing.getTimeList = function() {
            for (var i = 0; i < 12; i++) {
                $scope.UserSettingModel.Billing.TimeList.push((i < 10 && i > 0 ? '0' : '') + "" + (i == 0 ? 12 : i) + "-" + ((i + 1) < 10 && (i + 1) > 0 ? '0' : '') + "" + (i + 1) + " AM");
            }
            for (var i = 0; i < 12; i++) {
                $scope.UserSettingModel.Billing.TimeList.push((i < 10 && i > 0 ? '0' : '') + "" + (i == 0 ? 12 : i) + "-" + ((i + 1) < 10 && (i + 1) > 0 ? '0' : '') + "" + (i + 1) + " PM");
            }
        };
        $scope.UserSettingModel.Billing.toggleTrialAccountSectionView = function() {
            $scope.UserSettingModel.Billing.showTrialAccountSection = !$scope.UserSettingModel.Billing.showTrialAccountSection;
        };
        $scope.UserSettingModel.Support = {};
        $scope.UserSettingModel.Support.toggleTrialAccountSectionView = function() {
            $scope.UserSettingModel.Support.showTrialAccountSection = !$scope.UserSettingModel.Support.showTrialAccountSection;
        };
        $scope.UserSettingModel.Billing.toggleUpgradeAccountSectionView = function() {
            $scope.UserSettingModel.Billing.showUpgradeAccountSection = !$scope.UserSettingModel.Billing.showUpgradeAccountSection;
        };
        $scope.UserSettingModel.Billing.upgradeAccount = function() {
            $scope.UserSettingModel.Billing.TimeList = [];
            $scope.UserSettingModel.Billing.getTimeList();
            $scope.UserSettingModel.Billing.DataToUpgrade.UpgradeTime = $scope.UserSettingModel.Billing.TimeList[0];
            $scope.UserSettingModel.Billing.viewTrialAccountScreen = false;
            $scope.UserSettingModel.Billing.ViewUpgradeAccountScreen = true;
            $scope.UserSettingModel.Billing.showUpgradeAccountSection = true;
        };
        $scope.UserSettingModel.Billing.showLicenseDetails = function() {
            $scope.UserSettingModel.Billing.viewTrialAccountScreen = false;
            $scope.UserSettingModel.Billing.ViewLicenseDetailScreen = true;
            $scope.UserSettingModel.Billing.showLicenseDetailSection = true;
        };
        $scope.UserSettingModel.ImportAndExport = {};
        $scope.UserSettingModel.ImportAndExport.toggleImportDataSectionView = function() {
            $scope.UserSettingModel.ImportAndExport.showImportDataSection = !$scope.UserSettingModel.ImportAndExport.showImportDataSection;
        };
        $scope.UserSettingModel.ImportAndExport.toggleExportDataSectionView = function() {
            $scope.UserSettingModel.ImportAndExport.showExportDataSection = !$scope.UserSettingModel.ImportAndExport.showExportDataSection;
        };
        $scope.UserSettingModel.ImportAndExport.showTable = function() {
            $scope.UserSettingModel.ImportAndExport.showExportDataTable = true;
            UserSettingService.exportData().then(function(exportresult) {
                Notification.success(exportresult);
            }, function(errorSearchResult) {});
        }
        $scope.UserSettingModel.ImportAndExport.openExportWizard = function() {
            window.open('{!$Page.AccountingExport}', "_self");
        }
        $scope.UserSettingModel.BillingValidation = {
            Phone: {
                isError: false,
                ErrorMessage: '',
                Type: 'required,phone,Maxlength,Minlength',
                Maxlength: 10,
                Minlength: 10
            },
        }
        $scope.UserSettingModel.isSendActive = false;
        $scope.UserSettingModel.billingValidateForm = function(modelKey) {
            var validationObj = $scope.UserSettingModel.BillingValidation[modelKey];
            var isError = false;
            var ErrorMessage = '';
            var phoneRegEx = /^([0-9\(\)\/\+ \-]*)$/;
            var validateType = validationObj.Type;
            if (validateType.indexOf('Minlength') > -1) {
                if ($scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != undefined && $scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != '' && $scope.UserSettingModel.Billing.DataToUpgrade[modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + validationObj.Minlength;
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != undefined && $scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != '' && $scope.UserSettingModel.Billing.DataToUpgrade[modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_Length_Should_Be') + ' ' + validationObj.Maxlength;
                }
            }
            if (validateType.indexOf('Phone') > -1) {
                if ($scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != undefined && $scope.UserSettingModel.Billing.DataToUpgrade[modelKey] != '' && !phoneRegEx.test($scope.UserSettingModel.Billing.DataToUpgrade[modelKey])) {
                    isError = true;
                    ErrorMessage = $translate.instant('Label_Invalid') + ' ' + $translate.instant('Label_Phone_Number');
                }
            }
            if (validateType.indexOf('required') > -1) {
                if ($scope.UserSettingModel.Billing.DataToUpgrade[modelKey] == undefined || $scope.UserSettingModel.Billing.DataToUpgrade[modelKey] == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.UserSettingModel.BillingValidation[modelKey]['isError'] = isError;
            $scope.UserSettingModel.BillingValidation[modelKey]['ErrorMessage'] = ErrorMessage;
            if (!isError) {
                $scope.UserSettingModel.isSendActive = true;
            } else {
                $scope.UserSettingModel.isSendActive = false;
            }
        }
        var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
        $scope.UserSettingModel.validationModelInit = function() {
            $scope.UserSettingModel.UserSettingModelValidationList = [];
            angular.forEach($scope.UserSettingModel.NewUserList, function(index, newuser) {
                $scope.UserSettingModel.UserSettingModelValidation = {
                    email: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'email'
                    },
                    name: {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'required,Maxlength,Minlength',
                        Maxlength: 80,
                        Minlength: 2
                    }
                };
                $scope.UserSettingModel.UserSettingModelValidationList.push($scope.UserSettingModel.UserSettingModelValidation);
            })
        }
        $scope.UserSettingModel.validateForm = function(modelKey, index) {
            var validationObj = $scope.UserSettingModel.UserSettingModelValidationList[index][modelKey];
            var isError = false;
            var ErrorMessage = '';
            var emailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
            var validateType = $scope.UserSettingModel.UserSettingModelValidationList[index][modelKey].Type;
            if (validateType.indexOf('Minlength') > -1) {
                if ($scope.UserSettingModel.NewUserList[index][modelKey] != undefined && $scope.UserSettingModel.NewUserList[index][modelKey] != '' && $scope.UserSettingModel.NewUserList[index][modelKey].length < validationObj.Minlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Min_Length_Should_Be') + ' ' + validationObj.Minlength;
                }
            }
            if (validateType.indexOf('Maxlength') > -1) {
                if ($scope.UserSettingModel.NewUserList[index][modelKey] != undefined && $scope.UserSettingModel.NewUserList[index][modelKey] != '' && $scope.UserSettingModel.NewUserList[index][modelKey].length > validationObj.Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_Length_Should_Be') + ' ' + validationObj.Maxlength;
                }
            }
            if ($scope.UserSettingModel.NewUserList[index].name != undefined && $scope.UserSettingModel.NewUserList[index].name != '') {
                if (validateType.indexOf('email') > -1) {
                    if ($scope.UserSettingModel.NewUserList[index][modelKey] == undefined || $scope.UserSettingModel.NewUserList[index][modelKey] == '' || !emailRegEx.test($scope.UserSettingModel.NewUserList[index][modelKey])) {
                        isError = true;
                        ErrorMessage = $translate.instant('Invalid_email_id');
                    }
                }
            }
            if ($scope.UserSettingModel.NewUserList[index].email != undefined && $scope.UserSettingModel.NewUserList[index].email != '') {
                if (validateType.indexOf('required') > -1) {
                    if ($scope.UserSettingModel.NewUserList[index][modelKey] == '') {
                        isError = true;
                        ErrorMessage = $translate.instant('Field_Is_Required');
                    }
                }
            }
            $scope.UserSettingModel.UserSettingModelValidationList[index][modelKey].isError = isError;
            $scope.UserSettingModel.UserSettingModelValidationList[index][modelKey].ErrorMessage = ErrorMessage;
        }
        $scope.UserSettingModel.loadUserInfo = function() {
            $scope.UserSettingModel.enableAddNewButton = false;
            $scope.UserSettingModel.enableUpgradeProButton = false;
            $scope.UserSettingModel.isLoading = true;
            UserSettingService.getAllUsers().then(function(UserList) {
                $scope.UserSettingModel.bindUsersList(UserList);
                $scope.UserSettingModel.isLoading = false;
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
            });
        }
        $scope.UserSettingModel.bindUsersList = function(UserList) {
            $scope.UserSettingModel.UserList = UserList;
            $scope.UserSettingModel.NewUserList = [];
            if ($scope.UserSettingModel.UserList.length < 5) {
                $scope.showAddNewCustomer = true;
                while (($scope.UserSettingModel.UserList.length + $scope.UserSettingModel.NewUserList.length) < 5) {
                    $scope.UserSettingModel.NewUserList.push({
                        'name': '',
                        'email': '',
                        'isNew': true
                    });
                }
            }
            $scope.UserSettingModel.validationModelInit();
            if ($scope.UserSettingModel.NewUserList.length == 0) {
                $scope.UserSettingModel.enableUpgradeProButton = true;
            }
        }
        $scope.UserSettingModel.goTOCommunity = function() {
            if ($scope.UserSettingModel.isSendActive) {
                window.open($scope.UserSettingModel.communityURL);
            }
        }
        $scope.UserSettingModel.createNewUserRow = function() {
            $scope.UserSettingModel.NewUserList.push({
                'name': '',
                'email': '',
                'isNew': true
            });
            $scope.UserSettingModel.enableUpgradeProButton = false;
            $scope.UserSettingModel.validationModelInit();
        }
        $scope.UserSettingModel.IsAddNewButtonEnabled = function() {
            var isvalidData = true;
            if ($scope.UserSettingModel.UserSettingModelValidationList == undefined) {
                isvalidData = false;
            } else {
                for (var i = 0; i < $scope.UserSettingModel.UserSettingModelValidationList.length; i++) {
                    if ($scope.UserSettingModel.UserSettingModelValidationList[i].name.isError || $scope.UserSettingModel.UserSettingModelValidationList[i].email.isError) {
                        isvalidData = false;
                        break;
                    }
                }
                if ($scope.UserSettingModel.NewUserList != undefined && $scope.UserSettingModel.NewUserList.length > 0 && ($scope.UserSettingModel.NewUserList[0].name == '' || $scope.UserSettingModel.NewUserList[0].email == '')) {
                    isvalidData = false;
                }
            }
            return isvalidData;
        }
        $scope.UserSettingModel.sendEmail = function(arg) {
            $scope.UserSettingModel.subjectKey = arg;
            $scope.UserSettingModel.isLoading = true;
            UserSettingService.sendEmail($scope.UserSettingModel.subjectKey).then(function(emailResult) {
                Notification.success(emailResult);
                $scope.UserSettingModel.isLoading = false;
            }, function(errorSearchResult) {
                $scope.UserSettingModel.isLoading = false;
            });
        }
        $scope.UserSettingModel.upgradeAccount = function() {
            if ($scope.UserSettingModel.isSendActive) {
                $scope.UserSettingModel.isLoading = true;
                UserSettingService.upgradeAccount(angular.toJson($scope.UserSettingModel.Billing.DataToUpgrade)).then(function(emailResult) {
                    Notification.success(emailResult);
                    $scope.UserSettingModel.isLoading = false;
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    $scope.UserSettingModel.isLoading = false;
                });
            }
        }
        $scope.UserSettingModel.ImportAndExport.exportedDataAttachmentList = [];
        $scope.UserSettingModel.ImportAndExport.loadExportData = function() {
            $scope.UserSettingModel.isLoading = true;
            UserSettingService.getExportFiles().then(function(exportResult) {
                $scope.UserSettingModel.ImportAndExport.exportdata = exportResult;
                for (var i = 0; i < $scope.UserSettingModel.ImportAndExport.exportdata.length; i++) {
                    for (var j = 0; j < $scope.UserSettingModel.ImportAndExport.exportdata[i].exportedFiles.length; j++) {
                        $scope.UserSettingModel.ImportAndExport.exportedDataAttachmentList.push($scope.UserSettingModel.ImportAndExport.exportdata[i].exportedFiles[j]);
                    }
                }
                $scope.UserSettingModel.isLoading = false;
            }, function(errorMessage) {
                Notification.error(errorMessage);
                $scope.UserSettingModel.isLoading = false;
            });
        }
        $scope.UserSettingModel.createUsers = function() {
            if ($scope.UserSettingModel.IsAddNewButtonEnabled) {
                $scope.UserSettingModel.isLoading = true;
                UserSettingService.createUsers(angular.toJson($scope.UserSettingModel.NewUserList)).then(function(UserList) {
                    $scope.UserSettingModel.bindUsersList(UserList);
                    $scope.UserSettingModel.isLoading = false;
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                    $scope.UserSettingModel.isLoading = false;
                });
            }
        }
        $scope.UserSettingModel.loadUserSetting = function() {
            $scope.UserSettingModel.Users.showHomeSection = true;
            UserSettingService.setSystemSettingVisited().then(function(successResul) {}, function(errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.UserSettingModel.MoveToPage = function(value) {
            window.open(newUrl + '/apex/BlackPurlHome?pageName=' + value, '_blank');
        }
        $scope.UserSettingModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
                setTimeout(function() {
                    var Id = attr.Id;
                    $rootScope.pageTitle = $scope.UserSettingModel.idToMapSettingState[Id];
                    showTooltip('body');
                }, 100)
            } else {
                loadState($state, stateName);
                showTooltip('body');
            }
        }
        $scope.UserSettingModel.navigateToScreen = function(value) {
            $scope.UserSettingModel.navigationItem = value;
            if (value == 'User') {
                $scope.UserSettingModel.Users.showUsersSection = true;
                $scope.UserSettingModel.loadUserInfo();
            }
            if (value == 'Price_And_Tax') {
                $scope.UserSettingModel.PriceAndTax.loadPriceAndTaxData();
                $scope.UserSettingModel.PriceAndTax.showPriceAndTaxScreen = true;
                $scope.UserSettingModel.PriceAndTax.showAppSetting = false;
                $scope.UserSettingModel.PriceAndTax.showTaxSetting = false;
                $scope.UserSettingModel.PriceAndTax.showPriceSetting = false;
                $scope.UserSettingModel.PriceAndTax.showdisclaimers = false;
                $scope.UserSettingModel.PriceAndTax.showOtherSetting = false;
                $scope.UserSettingModel.PriceAndTax.showShopSupplies = false;
                $scope.UserSettingModel.PriceAndTax.showShopSettings = false;
            }
            if (value == 'Business_Profile') {
                $scope.UserSettingModel.BusinessProfile.loadBusinessProfileData();
                $scope.UserSettingModel.BusinessProfile.showBusinessProfileSection = true;
                $scope.UserSettingModel.BusinessProfile.showBusinessDetailSection = true;
                $scope.UserSettingModel.BusinessProfile.showBusinessAddressSection = true;
                $scope.UserSettingModel.BusinessProfile.showShippingAddressSection = true;
                $scope.UserSettingModel.BusinessProfile.isSameAsBusiness = $scope.UserSettingModel.BusinessProfile.SameAsBusiness[0];
            }
            if (value == 'Billing') {
                $scope.UserSettingModel.isLoading = true;
                UserSettingService.getBillingProfile().then(function(successresult) {
                    $scope.UserSettingModel.Billing.noOfDays = successresult;
                    $scope.UserSettingModel.isLoading = false;
                }, function(errorSearchResult) {
                    $scope.UserSettingModel.isLoading = false;
                });
                $scope.UserSettingModel.Users.showHomeSection = false;
                $scope.UserSettingModel.Billing.showBillingSection = true;
                $scope.UserSettingModel.Billing.viewTrialAccountScreen = true;
                $scope.UserSettingModel.Billing.showTrialAccountSection = true;
                $scope.UserSettingModel.Billing.ViewUpgradeAccountScreen = false;
                $scope.UserSettingModel.Billing.ViewLicenseDetailScreen = false;
            }
            if (value == 'Support') {
                $scope.UserSettingModel.Support.showSupportSection = true;
                $scope.UserSettingModel.Support.viewTrialAccountScreen = true;
                $scope.UserSettingModel.Support.showTrialAccountSection = true;
                $scope.UserSettingModel.Support.ViewUpgradeAccountScreen = false;
                $scope.UserSettingModel.Support.ViewLicenseDetailScreen = false;
            }
            if (value == 'Import_And_Export') {
                $scope.UserSettingModel.ImportAndExport.loadExportData()
                $scope.UserSettingModel.ImportAndExport.showImportSection = true;
                $scope.UserSettingModel.ImportAndExport.showImportDataSection = true;
                $scope.UserSettingModel.ImportAndExport.showExportDataSection = true;
            }
            $rootScope.pageTitle = $scope.UserSettingModel.idToMapSettingState[value];
        };
        if ($stateParams.Id == undefined || $stateParams.Id == null || $stateParams.Id == '') {
            loadState($state, 'UserSetting', {
                Id: 'Home'
            });
        }
        $scope.UserSettingModel.getBusinessInfoOnAccountSettingsPage = function() {
            UserSettingService.getBusinessInfo().then(function(businessInfo) {
                $scope.UserSettingModel.businessInfo = businessInfo;
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        if ($stateParams.Id == 'Home') {
            $scope.UserSettingModel.getBusinessInfoOnAccountSettingsPage();
            $scope.UserSettingModel.loadUserSetting();
        } else {
            $scope.UserSettingModel.userSettingValue = $stateParams.Id;
            $scope.UserSettingModel.navigateToScreen($scope.UserSettingModel.userSettingValue);
            $scope.UserSettingModel.Users.showHomeSection = false;
        }
    }])
});