define(['Routing_AppJs_PK', 'AddEditLabourServices', 'dirNumberInput', 'underscore_min'], function (Routing_AppJs_PK, AddEditLabourServices, dirNumberInput, underscore_min) {

    var injector = angular.injector(['ui-notification', 'ng']);

    Routing_AppJs_PK.controller('AddEditLabourCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', '$timeout', 'AddEditLabourService', '$translate', function ($scope, $q, $rootScope, $stateParams, $state, $timeout, AddEditLabourService,$translate) {
        var Notification = injector.get("Notification");

        if ($scope.AddEditLabour == undefined) {
            $scope.AddEditLabour = {};
        }
        $scope.AddEditLabour.costMethodValueList = [];
        $scope.AddEditLabour.tabIndexValue = 3000;
        $scope.AddEditLabour.isValidForm = true;
        $scope.AddEditLabour.LabourFormValidationModal = {};
        $scope.AddEditLabour.disableSaveButton = false;
        $scope.AddEditLabour.helpText = {
            LabourCode: $translate.instant('Labor_code'),
            LabourDescription: $translate.instant('Labor_description'),
            LabourHours: $translate.instant('Labor_hours'),
            LabourFixedRate: $translate.instant('Labor_fixed_rate'),
            LabourRate: $translate.instant('Labor_rate_required_if_fixed_rate_selected'),
            LabourCategory: $translate.instant('Labor_category'),
            LabourTaxable: $translate.instant('Labor_taxable'),
            CostRate: $translate.instant('Labor_cost_rate_cost_rate_percentage'),
            CostMethod: $translate.instant('Labor_cost_method'),
            CalculateSupplies: $translate.instant('Labor_Supplies_Detail')
        }
        $scope.AddEditLabour.hasShopSuppliesCalculationMethod = false;
        $scope.AddEditLabour.SuppliesDetailList = [];
        $scope.AddEditLabour.SuppliesDetailEditableIndex = -1;
        $scope.AddEditLabour.adjustTabIndex = function (e) {
            if (e.which == 9) {
                $('#Code').focus();
                e.preventDefault();
            }
        }

        /**
         * Method to set default values for validation model
         */
        $scope.AddEditLabour.setDefaultValidationModel = function () {
            $scope.AddEditLabour.LabourFormValidationModal = {
                LabourCode: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                LabourDescription: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                LabourHours: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,MinValue',
                    Value: 0
                },
                LabourRate: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'MinimumValue,Rate',
                    Value: 0
                },
                CostRate: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                }
            };
        }

        $scope.AddEditLabour.LabourFieldsFilter = {
            LabourCategory: [{
                Field: "Type__c",
                Value: "Labour",
                FilterObject: "Category__c"
            }]
        };

        $scope.AddEditLabour.addNewLabour = function () {
            $scope.AddEditLabour.disableSaveButton = false;
            $scope.AddEditLabour.ClearAlldata();
            $scope.AddEditLabour.loadDefaultLabourData();
            $scope.AddEditLabour.IsEditMode = false;
            $scope.AddEditLabour.LabourRecord.LabourStatus = true;
            $scope.AddEditLabour.openPopup();
        }

        $scope.AddEditLabour.editLabour = function (labourRecord) {
            $scope.AddEditLabour.disableSaveButton = false;
            $scope.AddEditLabour.ClearAlldata();
            $scope.AddEditLabour.IsEditMode = true;
            $scope.AddEditLabour.LoadFormData(labourRecord);

            $scope.AddEditLabour.hasShopSuppliesCalculationMethod = labourRecord.hasShopSuppliesCalculationMethod;
            if ($scope.AddEditLabour.hasShopSuppliesCalculationMethod && labourRecord.CalculateSupplies && labourRecord.SuppliesDetail) {
                $scope.AddEditLabour.SuppliesDetailList = labourRecord.SuppliesDetail.split("\n");
            }
        }

        $scope.$on('AddLabourEvent', function () {
            $scope.AddEditLabour.addNewLabour();
        });

        $scope.$on('EditLabourEvent', function (event, params) {
            $scope.AddEditLabour.editLabour(angular.copy(params.labourRecord));
        });

        /**
         * Event listener when a record is selected from Search bar
         */
        $scope.$on('autoCompleteSelectCallback', function (event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;

            if ($scope.AddEditLabour.CategoryNameStr == $scope.AddEditLabour.LabourRecord.LabourCategory.Name) {
                return;
            } else if (searchResult == null) {
            	$translate('No_matching_object_type_found',{'ObejctType':args.ObejctType}).then(function(successData) {
            		Notification.error(successData);
            	},function(error){});
                $scope.AddEditLabour.CategoryNameStr = "";
                $scope.AddEditLabour.LabourRecord.LabourCategory = {
                    Id: null,
                    Name: ""
                };
                return;
            }

            var objectsMapping = [{
                CATEGORY: {
                    Id: "LabourCategoryId",
                    Name: "LabourCategoryName",
                    selectMethod: $scope.AddEditLabour.setLabourRecordDataByForm
                }
            }];

            if (objectsMapping[0][obejctType] != null) {
                $scope.AddEditLabour.LabourRecord[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.AddEditLabour.LabourRecord[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
            }
            $scope.AddEditLabour.validateFieldWithKey(validationKey);
            if ($scope.AddEditLabour.LabourFormValidationModal[validationKey] == null || $scope.AddEditLabour.LabourFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });

        $scope.AddEditLabour.openPopup = function () {
            setTimeout(function () {
                angular.element('#AddEditLabour').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);

            setTimeout(function () {
                if ($scope.AddEditLabour.IsEditMode) {
                    angular.element("#Description").focus();
                } else {
                    angular.element("#Code").focus();
                }
            }, 100);
        }

        $scope.AddEditLabour.ClearAlldata = function () {
            $scope.AddEditLabour.formatCostValue = true;
            $scope.AddEditLabour.CategoryNameStr = "";
            $scope.AddEditLabour.LabourRecord = {};
            $scope.AddEditLabour.LabourRecord.LabourCategory = {
                Id: null,
                Name: ""
            };
            $scope.AddEditLabour.setDefaultValidationModel();
            $scope.AddEditLabour.SimilarLabourRecords = [];
            $scope.AddEditLabour.LabourRecord.CostMethod = "Fixed Cost";
            $scope.AddEditLabour.LabourRecord.CostRate = "0.00";
        }

        $scope.AddEditLabour.loadDefaultLabourData = function () {
            AddEditLabourService.getApplicableTaxList().then(function (taxList) {
                $scope.AddEditLabour.costMethodValueList = taxList.CostPicklistValues;
                $scope.AddEditLabour.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.AddEditLabour.TaxList = taxList.taxObj.SalesTaxList;
                var defaultTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                    IsDefault: true
                });
                if (defaultTaxIndex > -1) {
                    $scope.AddEditLabour.LabourRecord.ApplicableTaxId = $scope.AddEditLabour.TaxList[defaultTaxIndex].Id;
                    $scope.AddEditLabour.Tax_Rate = $scope.AddEditLabour.TaxList[defaultTaxIndex].TaxRate;
                }
            }, function (errorSearchResult) {
                //FIXME
            });

            AddEditLabourService.getDefaultLabourData().then(function (labourInfo) {
                if (labourInfo.LabourCategory != null && labourInfo.LabourCategory.Id != null && labourInfo.LabourCategory.Id != "") {
                    $scope.AddEditLabour.LabourRecord.LabourCategory = {
                        Id: labourInfo.LabourCategory.Id,
                        Name: labourInfo.LabourCategory.Name
                    };
                } else {
                    $scope.AddEditLabour.LabourRecord.LabourCategory = {
                        Id: null,
                        Name: ""
                    };
                }
                $scope.AddEditLabour.hasShopSuppliesCalculationMethod = labourInfo.hasShopSuppliesCalculationMethod;
                $scope.AddEditLabour.LabourRecord.LabourTaxable = true;
                $scope.AddEditLabour.LabourRecord.LabourRate = 0;
                $scope.AddEditLabour.CategoryNameStr = $scope.AddEditLabour.LabourRecord.LabourCategory.Name;
            }, function (errorSearchResult) {
                responseData = errorSearchResult;
                Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
            });
        }

        $scope.AddEditLabour.changeApplicableTax = function () {
            var selectedTaxIndex = _.findIndex($scope.AddEditLabour.TaxList, {
                Id: $scope.AddEditLabour.LabourRecord.ApplicableTaxId
            });
            if (selectedTaxIndex > -1) {
                $scope.AddEditLabour.Tax_Rate = $scope.AddEditLabour.TaxList[selectedTaxIndex].TaxRate;
            }
        }

        // Method to populate form data
        $scope.AddEditLabour.LoadFormData = function (LabourRecord) {
            AddEditLabourService.getApplicableTaxList().then(function (taxList) {
                $scope.AddEditLabour.costMethodValueList = taxList.CostPicklistValues;
                $scope.AddEditLabour.IsTaxIncludingPricing = taxList.taxObj.IsTaxIncludingPricing;
                $scope.AddEditLabour.TaxList = taxList.taxObj.SalesTaxList;
                var defaultTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                    IsDefault: true
                });

                $scope.AddEditLabour.LabourRecord = LabourRecord;
                $scope.AddEditLabour.CategoryNameStr = $scope.AddEditLabour.LabourRecord.LabourCategory.Name;
                if ($scope.AddEditLabour.LabourRecord.ApplicableTaxId != null) {
                    var salesTaxIndex = _.findIndex(taxList.taxObj.SalesTaxList, {
                        Id: $scope.AddEditLabour.LabourRecord.ApplicableTaxId
                    });
                    if (salesTaxIndex > -1) {
                        $scope.AddEditLabour.Tax_Rate = taxList.taxObj.SalesTaxList[salesTaxIndex].TaxRate;
                    }
                }
                if (defaultTaxIndex > -1 && $scope.AddEditLabour.LabourRecord.ApplicableTaxId == null) {
                    $scope.AddEditLabour.LabourRecord.ApplicableTaxId = $scope.AddEditLabour.TaxList[defaultTaxIndex].Id;
                    $scope.AddEditLabour.Tax_Rate = $scope.AddEditLabour.TaxList[defaultTaxIndex].TaxRate;
                }
                if ($scope.AddEditLabour.LabourRecord.CostMethod == 'Percent Retail') {
                    $scope.AddEditLabour.LabourFormValidationModal['CostRate'].Type = 'Percent';
                    $scope.AddEditLabour.formatCostValue = false;
                } else {
                    $scope.AddEditLabour.LabourFormValidationModal['CostRate'].Type = '';
                    $scope.AddEditLabour.formatCostValue = true;
                    if ($scope.AddEditLabour.LabourRecord.CostRate != null) {
                        $scope.AddEditLabour.LabourRecord.CostRate = $scope.AddEditLabour.LabourRecord.CostRate.toFixed(2);
                    }
                }
                $scope.AddEditLabour.openPopup();
            }, function (errorSearchResult) {
                //TODO
            });

        }

        $scope.AddEditLabour.SaveLabourForm = function (event) {
            $scope.AddEditLabour.isValidForm = true;
            $scope.AddEditLabour.getSimilarLabours('CODE');
            $scope.AddEditLabour.validateForm();

            if (!$scope.AddEditLabour.isValidForm) {
                Notification.error($translate.instant('AddEditFee_Error'));
                return;
            }
            /* Check if any Labour record with the same Code already exists in database, if so then show the error msg */
            for (var i = 0; i < $scope.AddEditLabour.SimilarLabourRecords.length; i++) {
                if ($scope.AddEditLabour.SimilarLabourRecords[i].PriorityLevel == 1) {
                    Notification.error($translate.instant('AddEditLabour_Similar_Labour_record'));
                    return;
                }
            }

            if ($scope.AddEditLabour.LabourRecord.LabourRate == "" || $scope.AddEditLabour.LabourRecord.LabourRate == null) {
                $scope.AddEditLabour.LabourRecord.LabourRate = 0;
            }

            if ($scope.AddEditLabour.SuppliesDetailList && $scope.AddEditLabour.SuppliesDetailList.length) {
                var suppliesDetail = '';
                for (var i = 0; i < $scope.AddEditLabour.SuppliesDetailList.length; i++) {
                    suppliesDetail += $scope.AddEditLabour.SuppliesDetailList[i] + "\n";
                }
                $scope.AddEditLabour.LabourRecord.SuppliesDetail = suppliesDetail;
            }
            var labourRecords = [];
            labourRecords.push($scope.AddEditLabour.LabourRecord);
            $scope.AddEditLabour.SaveLabourData(labourRecords);
        }

        $scope.AddEditLabour.setLabourRecordDataByForm = function (searchResult) {
            $scope.AddEditLabour.LabourRecord.LabourCategory.Id = searchResult.originalObject.Value;
            $scope.AddEditLabour.LabourRecord.LabourCategory.Name = searchResult.originalObject.Name;
        }

        /**
         * Method to perform Save Labour Data
         */
        $scope.AddEditLabour.SaveLabourData = function (labourRecords) {
            if ($scope.AddEditLabour.isValidForm) {
                if ($scope.AddEditLabour.disableSaveButton) {
                    return;
                }
                $scope.AddEditLabour.disableSaveButton = true;
                if ($scope.AddEditLabour.LabourRecord.CostRate == undefined || $scope.AddEditLabour.LabourRecord.CostRate == null || $scope.AddEditLabour.LabourRecord.CostRate === '') {
                    $scope.AddEditLabour.LabourRecord.CostRate = 0.00;
                }
                AddEditLabourService.saveLabourInfo(labourRecords).then(function (labourId) {
                    if ($scope.$parent.labourRecordSaveCallback != undefined) {
                        $scope.$parent.labourRecordSaveCallback(labourId);
                    }

                    Notification.success($translate.instant('Generic_Saved'));
                    angular.element('#AddEditLabour').modal('hide');
                    hideModelWindow();
                    $scope.AddEditLabour.disableSaveButton = false;
                    $state.go('ViewLabour', {
                        Id: labourId
                    });
                }, function (errorSearchResult) {
                    $scope.AddEditLabour.disableSaveButton = false;
                    Notification.error(errorSearchResult);
                });
            }
        }

        /**
         * Method to be processed when Fixed Rate checkbox is selected/deselected
         */
        $scope.AddEditLabour.onKeyUpFixedRate = function (event) {
            // If space/enter, then process the checkbox click functionality
            if (event.keyCode == 32 || event.keyCode == 13) {
                $scope.AddEditLabour.onSelectFixedRate();
            }
        }
        $scope.AddEditLabour.onSelectFixedRate = function () {
            $scope.AddEditLabour.LabourRecord.LabourFixedRate = !$scope.AddEditLabour.LabourRecord.LabourFixedRate;
        }

        /**
         * Method to be processed when Taxable checkbox is selected/deselected
         */
        $scope.AddEditLabour.onKeyUpTaxable = function (event) {
            // If space/enter, then process the checkbox click functionality
            if (event.keyCode == 32 || event.keyCode == 13) {
                $scope.AddEditLabour.onSelectTaxable();
            }
        }
        $scope.AddEditLabour.onSelectTaxable = function () {
            if (!$rootScope.GroupOnlyPermissions['Sales Taxes'].assign) {
                return;
            }
            $scope.AddEditLabour.LabourRecord.LabourTaxable = !$scope.AddEditLabour.LabourRecord.LabourTaxable;
        }
        $scope.AddEditLabour.onKeyUpActive = function (event) {
            // If space/enter, then process the checkbox click functionality
            if (event.keyCode == 13) {
                $scope.AddEditLabour.onSelectActive();
            }
        }
        $scope.AddEditLabour.onSelectActive = function () {
            $scope.AddEditLabour.LabourRecord.LabourStatus = !$scope.AddEditLabour.LabourRecord.LabourStatus;
        }

        $scope.AddEditLabour.changeCostMethodValidateType = function () {
            if ($scope.AddEditLabour.LabourRecord.CostMethod == 'Percent Retail') {
                $scope.AddEditLabour.LabourFormValidationModal['CostRate'].Type = 'Percent';
                $scope.AddEditLabour.LabourRecord.CostRate = "0";
                $scope.AddEditLabour.formatCostValue = false;
            } else {
                $scope.AddEditLabour.LabourFormValidationModal['CostRate'].Type = '';
                $scope.AddEditLabour.LabourRecord.CostRate = "0.00";
                $scope.AddEditLabour.LabourFormValidationModal['CostRate'].isError = false;
                $scope.AddEditLabour.LabourFormValidationModal['CostRate'].ErrorMessage = '';
                $scope.AddEditLabour.formatCostValue = true;
            }

        }

        $scope.AddEditLabour.validateForm = function () {
            angular.forEach($scope.AddEditLabour.LabourFormValidationModal, function (value, key) {
                $scope.AddEditLabour.validateFieldWithKey(key);
                if ($scope.AddEditLabour.LabourFormValidationModal[key].isError) {
                    $scope.AddEditLabour.isValidForm = false;
                }
            });
        }

        $scope.AddEditLabour.numberOnly = function (e) {
            var k = e.which;
            /* numeric inputs can come from the keypad or the numeric row at the top */
            if ((k < 48 || k > 57) && (k < 96 || k > 105) && k != 8 && k != 110 && k != 190 && k != 9) {
                e.preventDefault();
                return false;
            }
        }

        /**
         * Validation method for a field with modelKey value
         */
        $scope.AddEditLabour.validateFieldWithKey = function (modelKey) {
            if ($scope.AddEditLabour.LabourFormValidationModal[modelKey] == null) {
                return;
            }
            var fieldValue = $scope.AddEditLabour.LabourRecord[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.AddEditLabour.LabourFormValidationModal[modelKey].Type;
            var minValue = $scope.AddEditLabour.LabourFormValidationModal[modelKey].Value;
            var rateRegex = /^\d+(\.[0-9][0-9]?)?$/;
            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = true;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = 'Invalid field Value';
                } else {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Rate') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !rateRegex.test(fieldValue)) {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = true;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = 'Please enter a valid decimal value with two decimal places';
                } else {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if ($scope.AddEditLabour.LabourRecord.LabourFixedRate == true) {
                if (fieldValue != undefined) {
                    fieldValue = fieldValue.toString();
                }

                if (validateType.indexOf('MinimumValue') > -1) {
                    if (fieldValue != '' && fieldValue != undefined) {
                        if (fieldValue <= minValue) {
                            $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = true;
                            $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = $Label.Value_must_be_greater_than + ' ' + minValue;
                        } else {
                            $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                            $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';
                        }
                    } else {
                        $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                        $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';
                    }
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || $scope.AddEditLabour.LabourRecord[modelKey] == '') {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = true;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Percent') > -1) {
                if (fieldValue != undefined && fieldValue != null && fieldValue != '' && (parseFloat(fieldValue) > 100 || parseFloat(fieldValue) < 0)) {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = true;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = $translate.instant('Percent_value_between_0_to_100');
                } else {
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].isError = false;
                    $scope.AddEditLabour.LabourFormValidationModal[modelKey].ErrorMessage = '';

                }
            }
            if ($scope.AddEditLabour.LabourFormValidationModal[modelKey].isError == true) {
                $scope.AddEditLabour.isValidForm = false;
            }
        }

        /**
         * Method to retrieve similar records on code or description change
         */
        $scope.AddEditLabour.getSimilarLabours = function (fieldNameModified) {
            if ($scope.AddEditLabour.IsEditMode == false && fieldNameModified == 'CODE' &&
                $scope.AddEditLabour.LabourRecord.LabourCode != null &&
                $scope.AddEditLabour.LabourRecord.LabourCode != ""
            ) {
                $scope.AddEditLabour.getSimilarLabourRecords($scope.AddEditLabour.LabourRecord.LabourCode, $scope.AddEditLabour.LabourRecord.LabourDescription);
            } else if ($scope.AddEditLabour.IsEditMode == false && fieldNameModified == 'DESCRIPTION' &&
                $scope.AddEditLabour.LabourRecord.LabourDescription != null &&
                $scope.AddEditLabour.LabourRecord.LabourDescription != ""
            ) {
                $scope.AddEditLabour.getSimilarLabourRecords($scope.AddEditLabour.LabourRecord.LabourCode, $scope.AddEditLabour.LabourRecord.LabourDescription);
            }
        }

        /**
         * Method to find similar Labour records with similar code and description in database
         */
        $scope.AddEditLabour.getSimilarLabourRecords = function (code, description) {
            AddEditLabourService.getSimilarLabourRecords(code, description)
                .then(function (SimilarLabourRecords) {
                    $scope.AddEditLabour.SimilarLabourRecords = SimilarLabourRecords;
                }, function (errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($translate.instant('Generic_Error'));
                });
        }
        $scope.AddEditLabour.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }
        /**
         * Method to perform SAVE action for popup
         */
        $scope.AddEditLabour.closePopup = function () {
            angular.element('#AddEditLabour').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }

        $scope.AddEditLabour.OpenLabourPopup = function () {
            if ($stateParams.EditLabourParams && $stateParams.EditLabourParams.labourRecord) {
                $scope.AddEditLabour.editLabour(angular.copy($stateParams.EditLabourParams.labourRecord));
            } else {
                $scope.AddEditLabour.addNewLabour();
            }
        }

        $scope.AddEditLabour.editSuppliesDetailItemTabOut = function (event, index) {
            $timeout(function () {
                var isValidEdit = true;
                if (event.keyCode == 13 || event.keyCode == 9) {
                    if ($scope.AddEditLabour.SuppliesDetailList[index] && $scope.AddEditLabour.SuppliesDetailList[index].trim()) {
                        for (var i = 0; i < $scope.AddEditLabour.SuppliesDetailList.length; i++) {
                            if ((i != index && $scope.AddEditLabour.SuppliesDetailList[i] == $scope.AddEditLabour.SuppliesDetailList[index])) {
                                isValidEdit = false;
                                Notification.error($translate.instant('Same_Supplies_Detail_Already_Exist'));
                                setTimeout(function () {
                                    angular.element('#suppliesDetailEdit_' + index).focus();
                                }, 100);
                            }
                        }
                    }
                    if (isValidEdit) {
                        $scope.AddEditLabour.SuppliesDetailEditableIndex = -1;
                    }
                }
            }, 10);
        }

        $scope.AddEditLabour.removeFromMultiSelect = function (index) {
            $scope.AddEditLabour.SuppliesDetailList.splice(index, 1);
        }

        $scope.AddEditLabour.addAndRemoveFromMultiSelect = function (event, value) {
            if ((event.keyCode == 13 || event.keyCode == 9) && value && value.trim()) {
                if ($scope.AddEditLabour.SuppliesDetailList.indexOf(value) != -1) {
                    Notification.error($translate.instant('Same_Supplies_Detail_Already_Exist'));
                } else {
                    $scope.AddEditLabour.SuppliesDetailList.push(value);
                    $scope.AddEditLabour.NewSuppliesDetail = '';
                }
            }
            /*remove using backspace */
            if (event.keyCode === 8 && !value) {
                $scope.AddEditLabour.SuppliesDetailList.splice($scope.AddEditLabour.SuppliesDetailList.length - 1, 1);
            }
        }

        $scope.AddEditLabour.OpenLabourPopup();
    }])
});