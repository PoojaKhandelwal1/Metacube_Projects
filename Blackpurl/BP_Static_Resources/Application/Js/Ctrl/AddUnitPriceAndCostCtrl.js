define(['Routing_AppJs_PK', 'AddUnitPriceAndCostServices', 'JqueryUI', 'dirNumberInput'], function(Routing_AppJs_PK, AddUnitPriceAndCostServices, JqueryUI, dirNumberInput) {
    var injector = angular.injector(['ui-notification', 'ng']);
    $(document).ready(function() {
        $(".form-control").focus(function() {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        })
        $('#closemodal').click(function() {
            $('#pop').modal('hide');
        });
        setTimeout(function() {
            $('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 2000);
    });
    Routing_AppJs_PK.controller('AddUnitPriceAndCostCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'AddUnitPriceAndCostService','$translate', function($scope, $q, $rootScope, $state, $stateParams, AddUnitPriceAndCostService,$translate) {
        var Notification = injector.get("Notification");
        if ($scope.addUnitPriceAndCost == undefined) {
            $scope.addUnitPriceAndCost = {};
        }
        $scope.addUnitPriceAndCost.isValidForm = true;
        $scope.addUnitPriceAndCost.unitPriceAndCostRec = {};
        $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected = '';
        $scope.addUnitPriceAndCost.unitPriceAndCostRec.Type = '';
        $scope.addUnitPriceAndCost.tabIndexValue = 4000;
        $scope.addUnitPriceAndCost.clearAllData = function() {
            $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalPrice = "0.00";
            $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalCost = "0.00";
            $scope.addUnitPriceAndCost.unitPriceAndCostRec.ItemDescription = "";
            $scope.addUnitPriceAndCost.unitPriceAndCostRec.Type = '';
            $scope.addUnitPriceAndCost.unitPriceCostItemType = [{
                Value: "Base",
                Type: "Base"
            }, {
                Value: "Factory",
                Type: "Factory"
            }];
            $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected = $scope.addUnitPriceAndCost.unitPriceCostItemType[0].Value; 
            $scope.addUnitPriceAndCost.disableSaveButton = false; 
            $scope.addUnitPriceAndCost.setDefaultValidationModel();
        }
        $scope.addUnitPriceAndCost.helpText = {
            Type: $translate.instant('Unit_price_cost_item_type'),
            ItemDescription: $translate.instant('Unit_price_cost_item_description'),
            TotalPrice: $translate.instant('Unit_price_cost_item_total_price'),
            TotalCost: $translate.instant('Unit_price_cost_item_total_cost')
        };
        $scope.addUnitPriceAndCost.clearFields = function(key) {
            $scope.addUnitPriceAndCost.unitPriceAndCostRec[key] = '';
            if (key == 'Type') {
                $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected = $scope.addUnitPriceAndCost.unitPriceCostItemType[0].Value;
            }
        }
        $scope.addUnitPriceAndCost.setDefaultValidationModel = function() {
            $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal = {
                ItemDescription: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                TotalPrice: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                TotalCost: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                }
            };
        }

        $scope.addUnitPriceAndCost.unitPriceCostItemType = [{
            Value: "Base",
            Type: "Base"
        }, {
            Value: "Factory",
            Type: "Factory"
        }];
        $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected = $scope.addUnitPriceAndCost.unitPriceCostItemType[0].Value;
        $scope.addUnitPriceAndCost.changeUnitpriceCostItemType = function(index) {}
        $scope.$on('AddUnitPriceAndCostItemEvent', function(event, args) {
            $scope.addUnitPriceAndCost.clearAllData();
            $scope.addUnitPriceAndCost.openPopup();
        });
        $scope.addUnitPriceAndCost.AddUnitPriceAndCostItemEvent = function() {
            $scope.addUnitPriceAndCost.disableSaveButton = false;
            $scope.addUnitPriceAndCost.clearAllData();
            $scope.addUnitPriceAndCost.openPopup();
        }
        $scope.addUnitPriceAndCost.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.addUnitPriceAndCost.validateFormValidationModel = function() {
            var isValidForm = true;
            angular.forEach($scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal, function(value, key) {
                $scope.addUnitPriceAndCost.validateFieldWithKey(key);
                if ($scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[key].isError) {
                    isValidForm = false;
                }
            });
            return isValidForm;
        }
        // START: Form validation process
        // Method to validate form
        $scope.addUnitPriceAndCost.validateForm = function() {
            angular.forEach($scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal, function(value, key) {
                $scope.addUnitPriceAndCost.validateFieldWithKey(key);
                if ($scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[key].isError) {
                    $scope.addUnitPriceAndCost.isValidForm = false;
                }
            });
        }
        // Validation method for a field with modelKey value
        $scope.addUnitPriceAndCost.validateFieldWithKey = function(modelKey) {
            var fieldValue = $scope.addUnitPriceAndCost.unitPriceAndCostRec[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].Type;
            // Numeric fields validation
            if (modelKey == 'ItemDescription') {
                if ($scope.$parent.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList != undefined) {
                    for (var i = 0; i < $scope.$parent.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList.length; i++) {
                        if (($scope.$parent.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].ItemDescription).toLowerCase() == fieldValue.toLowerCase()) {
                            $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError = true;
                            Notification.error($translate.instant('Unique_Factory_Description'));
                            return;
                        }
                    }
                }
            }
            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError = true;
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].ErrorMessage = $translate.instant('Invalid_Field_Value');
                } else {
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError = false;
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || $scope.addUnitPriceAndCost.unitPriceAndCostRec[modelKey] == '') {
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError = true;
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError = false;
                    $scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            // Set validation flag value
            if ($scope.addUnitPriceAndCost.UnitPriceCostFormValidationModal[modelKey].isError == true) {
                $scope.addUnitPriceAndCost.isValidForm = false;
            }
        }

        $scope.addUnitPriceAndCost.openPopup = function() {
            setTimeout(function() {
                angular.element('#AddUnitPriceAndCost').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.addUnitPriceAndCost.cancelUnitPriceCostForm = function() {
            angular.element('#AddUnitPriceAndCost').modal('hide');
            setTimeout(function() {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }
        $scope.addUnitPriceAndCost.saveUnitPriceCostForm = function() {
            var isValidForm = $scope.addUnitPriceAndCost.validateFormValidationModel();
            if (isValidForm) {
                if ($scope.addUnitPriceAndCost.disableSaveButton) {
                    return;
                }
                $scope.addUnitPriceAndCost.disableSaveButton = true;
                $scope.addUnitPriceAndCost.unitPriceAndCostRec.Type = $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected;
                if ($scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalPrice == '' || $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalPrice == null) {
                    $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalPrice = "0.00";
                }
                if ($scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalCost == '' || $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalCost == null) {
                    $scope.addUnitPriceAndCost.unitPriceAndCostRec.TotalCost = "0.00";
                }
                $scope.addUnitPriceAndCost.unitPriceAndCostRec.Type = $scope.addUnitPriceAndCost.unitPriceCostItemTypeSelected;
                $scope.addUnitPriceAndCost.unitPriceAndCostRec.UnitId = $scope.$parent.viewUnitModel.unitId;
                $scope.addUnitPriceAndCost.SaveUnitPriceAndCostItemToserver($scope.$parent.viewUnitModel.unitId, angular.toJson($scope.addUnitPriceAndCost.unitPriceAndCostRec)); 
            }
        }
        $scope.addUnitPriceAndCost.SaveUnitPriceAndCostItemToserver = function(unitId, unitCostAndPriceRecs) {
            AddUnitPriceAndCostService.savePriceAndCost(unitId, unitCostAndPriceRecs).then(function(unitPriceAndCostList) {
                angular.element('#AddUnitPriceAndCost').modal('hide');
                $scope.$parent.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList = unitPriceAndCostList;
                $scope.$parent.viewUnitModel.calculateSummaryFields();
                $scope.addUnitPriceAndCost.disableSaveButton = false;
                Notification.success($translate.instant('Generic_Saved'));
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                }, {
                    reload: true
                });
            }, function(errorSearchResult) {
                $scope.addUnitPriceAndCost.disableSaveButton = false;
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.addUnitPriceAndCost.AddUnitPriceAndCostItemEvent();
    }])
});