define(['Routing_AppJs_PK', 'AddEditPOTypeServices', 'dirNumberInput', 'AngularNgEnter'], function (Routing_AppJs_PK, AddEditPOTypeServices, dirNumberInput, AngularNgEnter) {
    var injector = angular.injector(['ui-notification', 'ng']);

    $(document).ready(function () {
        $('.controls').hide();
        $(".form-control").focus(function () {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });

        $(".anguinput").focus(function () {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });

        $('[data-toggle="tooltip"]').tooltip({
            placement: 'bottom'
        });
    })

    Routing_AppJs_PK.controller('AddEditPOTypeCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'AddEditPOTypeService','$translate', function ($scope, $q, $rootScope, $stateParams, $state, AddEditPOTypeService, $translate) {
        var Notification = injector.get("Notification");
        
        $scope.POTypeCompModal.POTypeModal = {};
        $scope.POTypeCompModal.isValidForm = true;
        $scope.POTypeCompModal.tabIndexValue = 0;
        $scope.POTypeCompModal.POTypeModal = {};
        $scope.POTypeCompModal.disableSaveButton = false;
        $scope.POTypeCompModal.helpText = {
            Code: $translate.instant('Label_Code'),
            Save: $translate.instant('Save_Label'),
            Cancel: $translate.instant('Helptext_cancel_changes'),
            Lead_Time: $translate.instant('Lead_Time'),
            Discount: $translate.instant('Discount_applied'),
            Usage: $translate.instant('Usage'),
            Landed_Cost_Adjustment: $translate.instant('Cost_adjustment')
        };

        /**
         * Method to set default values for validation model
         */
        $scope.POTypeCompModal.setDefaultValidationModal = function () {
            $scope.POTypeCompModal.poTypeFormValidationModal = {
                Code: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            };
        }

        /**
         * Method to open self popup.
         */
        $scope.POTypeCompModal.openAddPOTypePopup = function (vendorId) {
            $scope.POTypeCompModal.clearAllData();
            $scope.POTypeCompModal.POTypeModal.vendorId = vendorId;
            $scope.POTypeCompModal.openPopup();
        }

        /**
         * Method to open self popup.
         */
        $scope.POTypeCompModal.openEditPOTypePopup = function (poTypeId, vendorId) {
            $scope.POTypeCompModal.currentPOTypeId = poTypeId;
            $scope.POTypeCompModal.POTypeModal.Id = poTypeId;
            $scope.POTypeCompModal.POTypeModal.vendorId = vendorId;
            $scope.POTypeCompModal.setDataDefault();
            $scope.POTypeCompModal.getCurrentPOTypeData();
        }

        $scope.POTypeCompModal.openPopup = function () {
            setTimeout(function () {
                angular.element('#AddNewPOType').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }

        $scope.POTypeCompModal.closePopup = function () {
            angular.element('#AddNewPOType').modal('hide');
            setTimeout(function () {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }, 1000);
        }

        /**
         * Method to clear all form fields and set default values
         */
        $scope.POTypeCompModal.clearAllData = function () {
            $scope.POTypeCompModal.currentPOTypeId = null;
            $scope.POTypeCompModal.POTypeModal = {};
            $scope.POTypeCompModal.POTypeModal.Discount = 0;
            $scope.POTypeCompModal.POTypeModal.LeadTime = 0;
            $scope.POTypeCompModal.POTypeModal.LandedCostAdjustment = 0;
            $scope.POTypeCompModal.setDataDefault();
        }

        $scope.POTypeCompModal.setDataDefault = function () {
            $scope.POTypeCompModal.setDefaultValidationModal();
        }

        $scope.POTypeCompModal.CancelPOTypeForm = function (event) {
            $scope.POTypeCompModal.closePopup();
        }

        $scope.POTypeCompModal.SavePOTypeForm = function () {
            $scope.POTypeCompModal.disableSaveButton = true;
            $scope.POTypeCompModal.isValidForm = true;
            $scope.POTypeCompModal.validateForm();
            if (!$scope.POTypeCompModal.isValidForm) {
                $scope.POTypeCompModal.disableSaveButton = false;
                return;
            }
            var poTypeRecords = [];
            if ($scope.POTypeCompModal.POTypeModal.LeadTime == "" || $scope.POTypeCompModal.POTypeModal.LeadTime == null) {
                $scope.POTypeCompModal.POTypeModal.LeadTime = 0;
            }
            if ($scope.POTypeCompModal.POTypeModal.Discount == "" || $scope.POTypeCompModal.POTypeModal.Discount == null) {
                $scope.POTypeCompModal.POTypeModal.Discount = 0;
            }
            if ($scope.POTypeCompModal.POTypeModal.LandedCostAdjustment == "" || $scope.POTypeCompModal.POTypeModal.LandedCostAdjustment == null) {
                $scope.POTypeCompModal.POTypeModal.LandedCostAdjustment = 0;
            }
            poTypeRecords.push($scope.POTypeCompModal.POTypeModal);
            $scope.POTypeCompModal.savePOTypeData(poTypeRecords);


        }

        $scope.POTypeCompModal.validateForm = function () {
            angular.forEach($scope.POTypeCompModal.poTypeFormValidationModal, function (value, key) {
                $scope.POTypeCompModal.validateFieldWithKey(key);
                if ($scope.POTypeCompModal.poTypeFormValidationModal[key].isError) {
                    $scope.POTypeCompModal.isValidForm = false;
                }
            });
        }

        /**
         * Validation method for a field with modelKey value
         */
        $scope.POTypeCompModal.validateFieldWithKey = function (modelKey) {
            var fieldValue = $scope.POTypeCompModal.POTypeModal[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].Type;

            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].isError = true;
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].ErrorMessage = $translate.instant('Invalid_Field_Value');
                } else {
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].isError = false;
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || $scope.POTypeCompModal.POTypeModal[modelKey] == '') {
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].isError = true;
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].isError = false;
                    $scope.POTypeCompModal.poTypeFormValidationModal[modelKey].ErrorMessage = '';
                }
            }

            if ($scope.POTypeCompModal.poTypeFormValidationModal[modelKey].isError == true) {
                $scope.POTypeCompModal.isValidForm = false;
            }
        }

        /**
         * Get POType data from server and fill form
         */
        $scope.POTypeCompModal.getCurrentPOTypeData = function () {
            AddEditPOTypeService.getPOTypeInfoById($scope.POTypeCompModal.currentPOTypeId).then(function (poTypeRecord) {
                $scope.POTypeCompModal.UpdateFormFieldsWithExistingPOType(poTypeRecord);
            }, function (errorSearchResult) {
                Notification.error($translate.instant("GENERIC_ERROR"));
            });
        }

        /**
         * Method to Save poType record data
         */
        $scope.POTypeCompModal.savePOTypeData = function (poTypeJSON) {
            AddEditPOTypeService.savePOTypeInfo(poTypeJSON).then(function (newPOTypeDetails) {
                // If parent page has poType save callback method, then perform the method and close popup
                if (newPOTypeDetails.indexOf('Same VO Type Code already present for vendor') > -1) {
                    Notification.error(newPOTypeDetails);
                    $scope.POTypeCompModal.disableSaveButton = false;
                } else {
                    if ($scope.$parent.ViewVendor.RelatedLists_recordSaveCallback != undefined) {
                        $scope.POTypeCompModal.disableSaveButton = false;
                        angular.element('#AddNewPOType').modal('hide');
                        $scope.$parent.ViewVendor.RelatedLists_recordSaveCallback("{!$ObjectType.PO_Type__c.label}", newPOTypeDetails);
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                    }
                }
            }, function (errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR.'));
                $scope.POTypeCompModal.disableSaveButton = false;
                $scope.$parent.POTypeCompModal.closePopup();
            });
        }

        /**
         * Set all the form fields with existing POType record
         */
        $scope.POTypeCompModal.UpdateFormFieldsWithExistingPOType = function (poTypeRecord) {
            $scope.POTypeCompModal.POTypeModal = poTypeRecord[0];
            $scope.POTypeCompModal.openPopup();
        }

        $scope.POTypeCompModal.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }
        
        $scope.POTypeCompModal.openPOTypePopup = function () {
            var vendorId = $stateParams.AddEditPOTypeParams.vendorId;
            var poTypeId = $stateParams.AddEditPOTypeParams.poTypeId;
            if (poTypeId != undefined && poTypeId != null && poTypeId != '') {
                $scope.POTypeCompModal.openEditPOTypePopup(poTypeId, vendorId);
            } else {
                $scope.POTypeCompModal.openAddPOTypePopup(vendorId);
            }
            setTimeout(function () {
                angular.element("#code").focus();
            }, 2000);
        }
        $scope.POTypeCompModal.openPOTypePopup();
    }])
});