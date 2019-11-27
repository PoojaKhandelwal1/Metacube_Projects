define(['Routing_AppJs_PK', 'AddEditFeeServices', 'underscore_min', 'dirNumberInput'], function(Routing_AppJs_PK, AddEditFeeServices, underscore_min, dirNumberInput) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditFeeCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'AddEditFeeService','$translate', function($scope, $q, $rootScope, $state, $stateParams, AddEditFeeService,$translate) {
        var Notification = injector.get("Notification");
        if ($scope.AddEditFee == undefined) {
            $scope.AddEditFee = {};
        }
        $scope.AddEditFee.costMethodValueList = [];
        $scope.AddEditFee.tabIndexValue = 4000;
        $scope.AddEditFee.disableSaveButton = false; 
        $scope.AddEditFee.adjustTabIndex = function(e) {
            if (e.which == 9) {
                $('#feetxtCode').focus();
                e.preventDefault();
            }
        }
        $scope.AddEditFee.ActiveOrderPageSortAttrsJSON = {
            ChangesCount: 0,
            CurrentPage: 1,
            PageSize: 10,
            Sorting: [{
                FieldName: "LastModifiedDate",
                SortDirection: "DESC"
            }]
        };
        $scope.AddEditFee.setDefaultValidationModel = function() {
            $scope.AddEditFee.FeeFormValidationModal = {
                Code: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,Maxlength',
                    Maxlength: 50
                },
                CategoryName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Description: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                CostRate: { 
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                }
            };
            $scope.AddEditFee.SimilarFee = [];
        }
        $scope.AddEditFee.helpText = {
            Code: $translate.instant('Helptext_fee_code'),
            Description: $translate.instant('Helptext_fee_desc'),
            FeePrices: $translate.instant('Helptext_fee_price'),
            FeeFixedRate: $translate.instant('Helptext_fee_fix_rate'),
            Price: $translate.instant('Helptext_fee_rate'),
            CategoryName: $translate.instant('Helptext_fee_category'),
            FeeTaxable: $translate.instant('Helptext_fee_taxable'),
            CostRate: $translate.instant('Helptext_fee_cost_rate'),
            CostMethod: $translate.instant('Helptext_fee_cost_method'),
        }
        $scope.AddEditFee.FeeFieldsFilter = {
            FeeCategory: [{
                Field: "Type__c",
                Value: "Fee",
                FilterObject: "Category__c"
            }]
        };
        /****** Add/Edit Fee eventlisteners ******/
        $scope.AddEditFee.addNewFee = function() {
            $scope.AddEditFee.disableSaveButton = false; 
            $scope.AddEditFee.setDefaultValidationModel();
            $scope.AddEditFee.clearAllData();
            $scope.AddEditFee.loadDefaultFeeData();
            $scope.AddEditFee.openPopup();
            setTimeout(function() {
                angular.element('#feetxtCode').focus();
            }, 1500);
        }
        /****** Add/Edit Fee events ******/
        $scope.$on('AddFeeEvent', function() {
            $scope.AddEditFee.addNewFee();
        });
        $scope.$on('EditFeeEvent', function(event, feeId) {
            $scope.AddEditFee.openEditFeePopup(feeId);
        });
        $scope.$on('autoCompleteSelectCallback', function(event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            if ($scope.AddEditFee.CategoryNameStr == $scope.AddEditFee.feeModel.CategoryName) {
                return;
            } else if (searchResult == null) {
                Notification.error($translate.instant('No_matching_object_type_found',{ObejctType: args.ObejctType}));
                $scope.AddEditFee.CategoryNameStr = "";
                $scope.AddEditFee.feeModel.CategoryName = "";
                $scope.AddEditFee.feeModel.CategoryId = null;
                return;
            }
            var objectsMapping = [{
                CATEGORY: {
                    Id: "CategoryId",
                    Name: "CategoryName",
                    selectMethod: null
                }
            }];
            if (objectsMapping[0][obejctType] != null) {
                $scope.AddEditFee.feeModel[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.AddEditFee.feeModel[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
            }
            $scope.AddEditFee.validateFieldWithKey(validationKey);
            if ($scope.AddEditFee.FeeFormValidationModal[validationKey] == null || $scope.AddEditFee.FeeFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });
        $scope.AddEditFee.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.AddEditFee.clearAllData = function() {
            $scope.AddEditFee.isEditMode = false;
            $scope.AddEditFee.feeModel = {};
            $scope.AddEditFee.feeModel.IsTaxable = false;
            $scope.AddEditFee.feeModel.IsActive = true;
            $scope.AddEditFee.feeModel.IsIncludeInProfitCalculation = false;
            $scope.AddEditFee.feeModel.Price = "0.00";
            $scope.AddEditFee.SimilarFee = [];
            $scope.AddEditFee.feeModel.CategoryId = null;
            $scope.AddEditFee.CategoryNameStr = "";
            $scope.AddEditFee.feeModel.CategoryName = "";
            $scope.AddEditFee.formatCostValue = true;
            $scope.AddEditFee.feeModel.CostMethod = "Fixed Cost";
            $scope.AddEditFee.feeModel.CostRate = "0.00";
        }
        $scope.AddEditFee.loadDefaultFeeData = function() {
            AddEditFeeService.getApplicableTaxList().then(function(taxList) {
                $scope.AddEditFee.costMethodValueList = taxList.CostPicklistValues;
                $scope.AddEditFee.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.AddEditFee.TaxList = taxList.taxObj.SalesTaxList;
                var defaultTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                    IsDefault: true
                });
                if (defaultTaxIndex > -1) {
                    $scope.AddEditFee.feeModel.ApplicableTaxId = $scope.AddEditFee.TaxList[defaultTaxIndex].Id;
                    $scope.AddEditFee.Tax_Rate = $scope.AddEditFee.TaxList[defaultTaxIndex].TaxRate;
                }
            }, function(errorSearchResult) {
                //TODO
            });
            AddEditFeeService.getDefaultFeeData().then(function(feeInfo) {
                if (feeInfo.CategoryId != null && feeInfo.CategoryId != "") {
                    $scope.AddEditFee.feeModel.CategoryId = feeInfo.CategoryId;
                    $scope.AddEditFee.CategoryNameStr = feeInfo.CategoryName;
                    $scope.AddEditFee.feeModel.CategoryName = feeInfo.CategoryName;
                } else {
                    $scope.AddEditFee.feeModel.CategoryId = null;
                    $scope.AddEditFee.CategoryNameStr = "";
                    $scope.AddEditFee.feeModel.CategoryName = "";
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
            });
        }
        $scope.AddEditFee.changeApplicableTax = function() {
            var selectedTaxIndex = _.findIndex($scope.AddEditFee.TaxList, {
                Id: $scope.AddEditFee.feeModel.ApplicableTaxId
            });
            if (selectedTaxIndex > -1) {
                $scope.AddEditFee.Tax_Rate = $scope.AddEditFee.TaxList[selectedTaxIndex].TaxRate;
            }
        }
        $scope.AddEditFee.openEditFeePopup = function(feeId) {
            $scope.AddEditFee.setDefaultValidationModel();
            $scope.AddEditFee.isEditMode = true;
            $scope.AddEditFee.disableSaveButton = false; 
            AddEditFeeService.getApplicableTaxList().then(function(taxList) {
                $scope.AddEditFee.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.AddEditFee.TaxList = taxList.taxObj.SalesTaxList;
                $scope.AddEditFee.costMethodValueList = taxList.CostPicklistValues;
                AddEditFeeService.getFeeInfoById(feeId, $scope.AddEditFee.ActiveOrderPageSortAttrsJSON).then(function(feeInfo) {
                    $scope.AddEditFee.feeModel = feeInfo.FeeRec;
                    $scope.AddEditFee.TotalLinkedFee = feeInfo.TotalLinkedFee;
                    if ($scope.AddEditFee.feeModel.CostMethod == 'Fixed Cost') {
                        if ($scope.AddEditFee.feeModel.CostRate != null) {
                            $scope.AddEditFee.feeModel.CostRate = $scope.AddEditFee.feeModel.CostRate.toFixed(2);
                            $scope.AddEditFee.formatCostValue = true;
                        }
                    } else {
                        $scope.AddEditFee.formatCostValue = false;
                    }
                    $scope.AddEditFee.CategoryNameStr = $scope.AddEditFee.feeModel.CategoryName;
                    if ($scope.AddEditFee.feeModel.ApplicableTaxId != null) {
                        var salesTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                            Id: $scope.AddEditFee.feeModel.ApplicableTaxId
                        });
                        if (salesTaxIndex > -1) {
                            $scope.AddEditFee.Tax_Rate = taxList.taxObj.SalesTaxList[salesTaxIndex].TaxRate;
                        }
                    }
                    var defaultTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                        IsDefault: true
                    });
                    if (defaultTaxIndex > -1 && $scope.AddEditFee.feeModel.ApplicableTaxId == null) {
                        $scope.AddEditFee.feeModel.ApplicableTaxId = $scope.AddEditFee.TaxList[defaultTaxIndex].Id;
                        $scope.AddEditFee.Tax_Rate = $scope.AddEditFee.TaxList[defaultTaxIndex].TaxRate;
                    }
                    if ($scope.AddEditFee.feeModel.CostMethod == 'Percent Retail') {
                        $scope.AddEditFee.FeeFormValidationModal['CostRate'].Type = 'Percent';
                    } else {
                        $scope.AddEditFee.FeeFormValidationModal['CostRate'].Type = '';
                    }
                    $scope.AddEditFee.openPopup();
                    setTimeout(function() {
                        angular.element('#feetxtDescription').focus();
                    }, 2000);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }, function(errorSearchResult) {
            });
        }
        $scope.AddEditFee.onKeyUpTaxable = function(event) {
            if (event.keyCode == 13) {
                $scope.AddEditFee.onSelectTaxable();
            }
        }
        $scope.AddEditFee.onSelectTaxable = function() {
            if ($scope.AddEditFee.isEditMode && !$rootScope.GroupOnlyPermissions['Sales Taxes']['assign']) {
                return;
            }
            $scope.AddEditFee.feeModel.IsTaxable = !$scope.AddEditFee.feeModel.IsTaxable;
        }
        $scope.AddEditFee.onKeyUpActive = function(event) {
            if (event.keyCode == 13) {
                $scope.AddEditFee.onSelectActive();
            }
        }
        $scope.AddEditFee.onSelectActive = function() {
            if ($scope.AddEditFee.feeModel.IsActive && $scope.AddEditFee.TotalLinkedFee != 0) {
                Notification.error($translate.instant('Fee_used_in_link_fee_error'));
                return;
            }
            $scope.AddEditFee.feeModel.IsActive = !$scope.AddEditFee.feeModel.IsActive;
        }
        $scope.AddEditFee.SaveFeeForm = function() {
            $scope.AddEditFee.isValidForm = true;
            $scope.AddEditFee.validateForm();
            if (!$scope.AddEditFee.isValidForm) {
                Notification.error($translate.instant('AddEditFee_Error'));
                return;
            }
            for (var i = 0; i < $scope.AddEditFee.SimilarFee.length; i++) {
                if ($scope.AddEditFee.SimilarFee[i].PriorityValue == 1) {
                    Notification.error($translate.instant('AddEditFee_Similar_Record_Present'));
                    return;
                }
            }
            $scope.AddEditFee.saveFeeData();
        }
        $scope.AddEditFee.saveFeeData = function() {
            if ($scope.AddEditFee.disableSaveButton) {
                return;
            }
            $scope.AddEditFee.disableSaveButton = true; 
            if ($scope.AddEditFee.feeModel.CostRate == undefined || $scope.AddEditFee.feeModel.CostRate == null || $scope.AddEditFee.feeModel.CostRate === '') {
                $scope.AddEditFee.feeModel.CostRate = 0.00;
            }
            AddEditFeeService.saveFeeInfo($scope.AddEditFee.feeModel, $scope.AddEditFee.ActiveOrderPageSortAttrsJSON).then(function(feeInfo) {
                angular.element('#AddEditFee').modal('hide');
                hideModelWindow();
                if ($scope.$parent.feeRecordSaveCallback != undefined) {
                    $scope.$parent.feeRecordSaveCallback(feeInfo.FeeRec);
                }
                $state.go('ViewFee', {
                    Id: feeInfo.FeeRec.Id
                });
                $scope.AddEditFee.disableSaveButton = false; 
                Notification.success($translate.instant('Generic_Saved'));
            }, function(errorSearchResult) {
                $scope.AddEditFee.disableSaveButton = false; 
                Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
            });
        }
        $scope.AddEditFee.getSimilarFees = function(modelKey) {
            var fieldValue = $scope.AddEditFee.feeModel[modelKey];
            $scope.AddEditFee.SimilarFee = {};
            if ((($scope.AddEditFee.feeModel['Code'] == '' || $scope.AddEditFee.feeModel['Code'] == null) && ($scope.AddEditFee.feeModel['Description'] == null || $scope.AddEditFee.feeModel['Description'] == '')) || $scope.AddEditFee.isEditMode) {
                return;
            }
            AddEditFeeService.getSimilarFees($scope.AddEditFee.feeModel).then(function(SimilarFee) {
                $scope.AddEditFee.SimilarFee = SimilarFee;
            }, function(errorSearchResult) {});
        }
        $scope.AddEditFee.changeCostMethodValidateType = function() {
            if ($scope.AddEditFee.feeModel.CostMethod == 'Percent Retail') {
                $scope.AddEditFee.FeeFormValidationModal['CostRate'].Type = 'Percent';
                $scope.AddEditFee.feeModel.CostRate = "0";
                $scope.AddEditFee.formatCostValue = false;
            } else {
                $scope.AddEditFee.FeeFormValidationModal['CostRate'].Type = '';
                $scope.AddEditFee.feeModel.CostRate = "0.00";
                $scope.AddEditFee.FeeFormValidationModal['CostRate'].isError = false;
                $scope.AddEditFee.FeeFormValidationModal['CostRate'].ErrorMessage = '';
                $scope.AddEditFee.formatCostValue = true;
            }
        }
        $scope.AddEditFee.validateForm = function() {
            angular.forEach($scope.AddEditFee.FeeFormValidationModal, function(value, key) {
                $scope.AddEditFee.validateFieldWithKey(key);
            });
        }
        $scope.AddEditFee.validateFieldWithKey = function(modelKey) {
            var fieldValue = $scope.AddEditFee.feeModel[modelKey];
            var isError = false;
            var ErrorMessage = '';
            var validateType = $scope.AddEditFee.FeeFormValidationModal[modelKey].Type;
            if (validateType.indexOf('Maxlength') > -1) {
                if (fieldValue != undefined && fieldValue != '' && fieldValue.length > $scope.AddEditFee.FeeFormValidationModal[modelKey].Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_Length_Should_Be')+' ' + $scope.AddEditFee.FeeFormValidationModal[modelKey].Maxlength;
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            if (validateType.indexOf('Percent') > -1) {
                if (fieldValue != undefined && fieldValue != null && fieldValue != '' && (parseFloat(fieldValue) > 100 || parseFloat(fieldValue) < 0)) {
                    isError = true;
                    ErrorMessage = $translate.instant('Percent_value_between_0_to_100');
                    $scope.AddEditFee.FeeFormValidationModal[modelKey].isError = true;
                    $scope.AddEditFee.FeeFormValidationModal[modelKey].ErrorMessage = $translate.instant('Percent_value_between_0_to_100');
                } else {
                    $scope.AddEditFee.FeeFormValidationModal[modelKey].isError = false;
                    $scope.AddEditFee.FeeFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            $scope.AddEditFee.FeeFormValidationModal[modelKey].isError = isError;
            $scope.AddEditFee.FeeFormValidationModal[modelKey].ErrorMessage = ErrorMessage;
            if ($scope.AddEditFee.FeeFormValidationModal[modelKey].isError == true) {
                $scope.AddEditFee.isValidForm = false;
            }
        }
        $scope.AddEditFee.clearFields = function(key) {
            $scope.AddEditFee.feeModel[key] = '';
            $scope.AddEditFee.getSimilarFees(key);
        }
        $scope.AddEditFee.closePopup = function() {
            angular.element('#AddEditFee').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.AddEditFee.openPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#AddEditFee').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.AddEditFee.openFeePopup = function() {
            if ($stateParams.feeParams != undefined && $stateParams.feeParams.Id != undefined && $stateParams.feeParams.Id != null && $stateParams.feeParams.Id != '') {
                $scope.AddEditFee.openEditFeePopup($stateParams.feeParams.Id);
            } else {
                $scope.AddEditFee.addNewFee();
            }
        }
        $scope.AddEditFee.setDefaultValidationModel();
        $scope.AddEditFee.openFeePopup();
    }])
});