define(['Routing_AppJs_PK', 'DealUnitServices', 'CustomMakeSort'], function(Routing_AppJs_PK, DealUnitServices, CustomMakeSort) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('DealUnitCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'DealUnitService', function($scope, $timeout, $q, $rootScope, $state, $stateParams, DealUnitService) {
        var Notification = injector1.get("Notification");
        if ($scope.dealUnit == undefined) {
            $scope.dealUnit = {};
        }
        var Currentyear = parseInt(new Date().getFullYear());
        $scope.dealUnit.dealId = '';
        $scope.dealUnit.ownedUnitRec = {};
        $scope.dealUnit.Years = [];
        $scope.dealUnit.UnitYearSelected = {};
        $scope.dealUnit.UnitMake = [];
        $scope.dealUnit.UnitMakeSelected = {};
        $scope.dealUnit.UnitModel = [];
        $scope.dealUnit.UnitModelSelected = {};
        $scope.dealUnit.UnitSubModelFilter = {};
        $scope.dealUnit.CurrentIndexMake = -1;
        $scope.dealUnit.CurrentIndexUnitModel = -1;
        $scope.dealUnit.CurrentIndexUnitSubModel = -1;
        $scope.dealUnit.UnitSubModel = [];
        $scope.dealUnit.UnitSubModelSelected = {};
        $scope.dealUnit.saveUnitModelblur = 0;
        $scope.dealUnit.saveUnitMakeBlur = 0;
        $scope.dealUnit.saveUnitSubModelBlur = 0;
        $scope.dealUnit.FilterSearchMake = '';
        $scope.dealUnit.FilterSearchUnitModel = '';
        $scope.dealUnit.FilterSearchUnitSubModel = '';
        $scope.dealUnit.isMakeDropdownOpen = false;
        $scope.dealUnit.isSubModelDropdownOpen = false;
        $scope.dealUnit.isModelDropdownOpen = false;
        $scope.dealUnit.clearAllData = function() {
            $scope.dealUnit.UnitMake = [];
            $scope.dealUnit.UnitModel = [];
            $scope.dealUnit.UnitSubModel = [];
            $scope.dealUnit.UnitYearSelected = {};
            $scope.dealUnit.UnitMakeSelected = {};
            $scope.dealUnit.UnitModelSelected = {};
            $scope.dealUnit.UnitMakeNameStr = "";
            $scope.dealUnit.UnitSubModelNameStr = "";
            $scope.dealUnit.UnitModelNameStr = "";
            $scope.dealUnit.ownedUnitRec = {};
            $scope.dealUnit.FilterSearchMake = '';
            $scope.dealUnit.FilterSearchUnitModel = '';
            $scope.dealUnit.FilterSearchUnitSubModel = '';
            $scope.dealUnit.setDefaultValidationModel();
            $scope.dealUnit.loadManageJsonData();
        }
        for (i = Currentyear; i > (Currentyear - 100 + 2); i--) {
            var year = {
                year: i
            };
            $scope.dealUnit.Years.push(year);
        }
        $scope.$on('DealUnitEvent', function(event, args) {
            $scope.dealUnit.dealId = args.dealId;
            $scope.dealUnit.ownedUnitRec.dealItemId = args.dealItemId;
            $scope.dealUnit.clearAllData();
            $scope.dealUnit.ownedUnitRec = angular.copy(args.dealSelectedModel);
            $scope.dealUnit.currentIndex = args.index;
            $scope.dealUnit.openCustomerSearchPopup();
        });
        $scope.dealUnit.loadManageJsonData = function() {
            $scope.dealUnit.ManageIconCustomerDetails = [{
                MakeName: {
                    value: [{
                        val: 'UnitMakeSelected',
                        fieldType: 'lookup'
                    }],
                    isPrimary: true
                },
                ModelName: {
                    value: [{
                        val: 'UnitModelSelected',
                        fieldType: 'lookup'
                    }],
                    isPrimary: true
                },
                SubModelName: {
                    value: [{
                        val: 'SubModelName',
                        fieldType: 'lookup'
                    }],
                    isPrimary: true
                },
                Year: {
                    value: [{
                        val: 'UnitYearSelected',
                        fieldType: 'lookup'
                    }],
                    isPrimary: true
                },
                ExteriorColour: {
                    value: [{
                        val: 'ExteriorColour',
                        fieldType: 'text'
                    }],
                    isPrimary: true
                },
            }]
        }
        $scope.dealUnit.validateFormValidationModel = function() {
            var isValidForm = true;
            angular.forEach($scope.dealUnit.COUFormValidationModal, function(value, key) {
                $scope.dealUnit.ValidateForm(key);
                if ($scope.dealUnit.COUFormValidationModal[key].isError) {
                    isValidForm = false;
                }
            });
            return isValidForm;
        }
        $scope.dealUnit.ClearAndRemoveField = function(fieldrel, targetIdToFocus) {
            $scope.dealUnit.loadManageJsonData();
            var fieldsToClearOrRemove = $scope.dealUnit.ManageIconCustomerDetails[0][fieldrel];
            if (fieldsToClearOrRemove.isPrimary == true) {
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    var key = fieldsToClearOrRemove.value[i].val;
                    if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                        $scope.dealUnit.ownedUnitRec[key] = "";
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                        $scope.dealUnit.ownedUnitRec[key] = false;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                        $scope.dealUnit[key] = null;
                        if (fieldrel == 'ModelName') {
                            $scope.dealUnit.ownedUnitRec.Model = null;
                            $scope.dealUnit.ownedUnitRec.SubModelName = null;
                            $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                            $scope.dealUnit.UnitSubModelSelected = {};
                            $scope.dealUnit.UnitSubModel = [];
                            $scope.dealUnit.FilterSearchUnitModel = '';
                            $scope.dealUnit.FilterSearchUnitSubModel = '';
                            $scope.dealUnit.UnitModelNameStr = '';
                            $scope.dealUnit.UnitSubModelNameStr = '';
                            $scope.dealUnit.filteredItemsUnitSubModel = '';
                        }
                        if (fieldrel == 'MakeName') {
                            $scope.dealUnit.UnitModelSelected = {};
                            $scope.dealUnit.UnitSubModelSelected = {};
                            $scope.dealUnit.UnitModel = [];
                            $scope.dealUnit.UnitSubModel = [];
                            $scope.dealUnit.UnitMakeNameStr = '';
                            $scope.dealUnit.UnitModelNameStr = '';
                            $scope.dealUnit.UnitSubModelNameStr = '';
                            $scope.dealUnit.ownedUnitRec.Make = null;
                            $scope.dealUnit.ownedUnitRec.Model = null;
                            $scope.dealUnit.ownedUnitRec.SubModelName = null;
                            $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                            $scope.dealUnit.FilterSearchMake = '';
                            $scope.dealUnit.FilterSearchUnitModel = '';
                            $scope.dealUnit.FilterSearchUnitSubModel = '';
                            $scope.dealUnit.filteredItemsUnitSubModel = '';
                        }
                        if (fieldrel == 'SubModelName') {
                            $scope.dealUnit.UnitSubModelSelected = {};
                            $scope.dealUnit.UnitSubModel = [];
                            $scope.dealUnit.UnitSubModelNameStr = '';
                            $scope.dealUnit.ownedUnitRec.SubModelName = null;
                            $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                            $scope.dealUnit.FilterSearchUnitSubModel = '';
                            $scope.dealUnit.filteredItemsUnitSubModel = '';
                        }
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'number') {
                        $scope.dealUnit.ownedUnitRec[key] = "";
                    }
                }
            }
            angular.element('#' + targetIdToFocus).focus();
            if (fieldrel == 'ModelName') {
                $scope.dealUnit.ClearAndRemoveField('SubModelName', 'DealSubModelId');
            }
        }
        $scope.dealUnit.ValidateForm = function(modelKey) {
            var fieldValue = '';
            if (modelKey == 'Make') {
                fieldValue = $scope.dealUnit.FilterSearchMake;
            } else if (modelKey == 'Model') {
                fieldValue = $scope.dealUnit.FilterSearchUnitModel;
            } else if (modelKey == 'SubModel') {
                fieldValue = $scope.dealUnit.FilterSearchUnitSubModel;
            } else {
                fieldValue = $scope.dealUnit.ownedUnitRec[modelKey];
            }
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.dealUnit.COUFormValidationModal[modelKey].Type;
            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.dealUnit.COUFormValidationModal[modelKey].isError = true;
                    if (fieldValue.indexOf(".") > -1) {
                        $scope.dealUnit.COUFormValidationModal[modelKey].ErrorMessage = 'Mileage value should not contain decimal';
                    } else {
                        $scope.dealUnit.COUFormValidationModal[modelKey].ErrorMessage = 'Mileage value should be a number';
                    }
                } else {
                    $scope.dealUnit.COUFormValidationModal[modelKey].isError = false;
                    $scope.dealUnit.COUFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    $scope.dealUnit.COUFormValidationModal[modelKey].isError = true;
                    $scope.dealUnit.COUFormValidationModal[modelKey].ErrorMessage = $Label.Field_Is_Required;
                } else {
                    $scope.dealUnit.COUFormValidationModal[modelKey].isError = false;
                    $scope.dealUnit.COUFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
        }
        $scope.dealUnit.setDefaultValidationModel = function() {
            $scope.dealUnit.COUFormValidationModal = {
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
        }
        $scope.dealUnit.openCustomerSearchPopup = function() {
            $scope.dealUnit.setRecordData();
            $scope.dealUnit.openPopup();
            setTimeout(function() {
                angular.element('#searchCustomer').focus();
            }, 1000);
        }
        $scope.$on('autoCompleteSelectCallback', function(event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            if (searchResult != null && searchResult.originalObject.Info == 'Unit') {
                $scope.dealUnit.UnitMakeSelected = {};
                $scope.dealUnit.UnitMakeSelected = {
                    Id: searchResult.originalObject.Value,
                    UnitMakeName: searchResult.originalObject.Name
                }
                $scope.dealUnit.changeUnitMake();
                return;
            } else if (searchResult != null && searchResult.originalObject.Info == 'UnitModel') {
                $scope.dealUnit.UnitModelSelected = {};
                $scope.dealUnit.UnitModelSelected = {
                    Id: searchResult.originalObject.Value,
                    UnitModelName: searchResult.originalObject.Name
                }
                $scope.dealUnit.changeUnitmodel();
                return;
            } else if (searchResult != null && searchResult.originalObject.Info) {
                if (searchResult.originalObject.Info.indexOf("Unit_Model__c") != -1) {
                    $scope.dealUnit.UnitSubModelSelected = {};
                    $scope.dealUnit.UnitSubModelSelected = {
                        Id: searchResult.originalObject.Value,
                        SubModelName: searchResult.originalObject.Name
                    }
                    $scope.dealUnit.ownedUnitRec.Model = $scope.dealUnit.UnitSubModelSelected.Id;
                    $scope.dealUnit.ownedUnitRec.SubModelName = $scope.dealUnit.UnitSubModelSelected.SubModelName
                    $scope.dealUnit.ownedUnitRec.SubModel = $scope.dealUnit.UnitSubModelSelected.Id
                    return;
                }
            }
            if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNIT') {
                if (($scope.dealUnit.UnitMakeSelected != null && $scope.dealUnit.UnitMakeNameStr != $scope.dealUnit.UnitMakeSelected.UnitMakeName) || $scope.dealUnit.UnitMakeNameStr == null || $scope.dealUnit.UnitMakeNameStr == "" || $scope.dealUnit.UnitMakeSelected == null) {
                    $scope.dealUnit.UnitMakeSelected = null;
                    $scope.dealUnit.UnitModelSelected = null;
                    $scope.dealUnit.UnitSubModelSelected = null;
                    $scope.dealUnit.UnitMakeNameStr = "";
                    $scope.dealUnit.UnitSubModelNameStr = "";
                    $scope.dealUnit.UnitModelNameStr = "";
                }
                return;
            } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITMODEL') {
                if (($scope.dealUnit.UnitModelSelected != null && $scope.dealUnit.UnitModelNameStr != $scope.dealUnit.UnitModelSelected.UnitModelName) || $scope.dealUnit.UnitModelNameStr == null || $scope.dealUnit.UnitModelNameStr == "" || $scope.dealUnit.UnitModelSelected == null) {
                    $scope.dealUnit.UnitModelSelected = null;
                    $scope.dealUnit.UnitSubModelSelected = null;
                    $scope.dealUnit.UnitSubModelNameStr = "";
                    $scope.dealUnit.UnitModelNameStr = "";
                }
                return;
            } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITSUBMODEL') {
                if (($scope.dealUnit.UnitSubModelSelected != null && $scope.dealUnit.UnitSubModelNameStr != $scope.dealUnit.UnitSubModelSelected.SubModelName) || $scope.dealUnit.UnitSubModelNameStr == null || $scope.dealUnit.UnitSubModelNameStr == "" || $scope.dealUnit.UnitSubModelSelected == null) {
                    $scope.dealUnit.UnitSubModelSelected = null;
                    $scope.dealUnit.UnitSubModelNameStr = "";
                }
                return;
            }
            if ($scope.dealUnit.COUFormValidationModal[validationKey] == null || $scope.dealUnit.COUFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });
        $scope.dealUnit.openPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#AddNewDealCOU').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.dealUnit.CancelCOUForm = function() {
            angular.element('#AddNewDealCOU').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.dealUnit.setRecordData = function() {
            $scope.dealUnit.UnitYearSelected = {
                year: $scope.dealUnit.ownedUnitRec.Year
            };
            $scope.dealUnit.UnitMakeSelected = {
                Id: $scope.dealUnit.ownedUnitRec.Make,
                UnitMakeName: $scope.dealUnit.ownedUnitRec.MakeName
            };
            $scope.dealUnit.UnitModelSelected = {
                Id: $scope.dealUnit.ownedUnitRec.Model,
                SubModelName: $scope.dealUnit.ownedUnitRec.SubModelName,
                UnitModelName: $scope.dealUnit.ownedUnitRec.ModelName
            };
            $scope.dealUnit.UnitMakeNameStr = $scope.dealUnit.ownedUnitRec.MakeName;
            $scope.dealUnit.UnitModelNameStr = $scope.dealUnit.ownedUnitRec.ModelName;
            $scope.dealUnit.UnitSubModelNameStr = $scope.dealUnit.ownedUnitRec.SubModelName;
            $scope.dealUnit.UnitSubModelSelected = {
                Id: $scope.dealUnit.ownedUnitRec.Model,
                SubModelName: $scope.dealUnit.ownedUnitRec.SubModelName,
            };
            $scope.dealUnit.FilterSearchMake = $scope.dealUnit.ownedUnitRec.MakeName;
            $scope.dealUnit.FilterSearchUnitModel = $scope.dealUnit.ownedUnitRec.ModelName;
            $scope.dealUnit.FilterSearchUnitSubModel = $scope.dealUnit.ownedUnitRec.SubModelName;
        }
        $scope.dealUnit.changeYear = function() {
            if (typeof $scope.dealUnit.UnitYearSelected.year == 'undefined') {
                $scope.dealUnit.ownedUnitRec.Year = null;
            } else {
                var selectedYear = parseInt($scope.dealUnit.UnitYearSelected.year);
                $scope.dealUnit.ownedUnitRec.Year = selectedYear;
            }
        }
        $scope.dealUnit.saveUnitModel = function(event) {
            $scope.dealUnit.isModelDropdownOpen = false;
            if ($scope.dealUnit.saveUnitModelBlur == 0 || $scope.dealUnit.saveUnitModelBlur == undefined) {
                if ($scope.dealUnit.ownedUnitRec.ModelName != $scope.dealUnit.FilterSearchUnitModel) {
                    $scope.dealUnit.ownedUnitRec.SubModel = null;
                    $scope.dealUnit.ownedUnitRec.SubModelName = '';
                    $scope.dealUnit.FilterSearchUnitSubModel = '';
                    $scope.dealUnit.filteredItemsUnitSubModel = '';
                    $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                }
                var isModelAlreadyExist = false;
                for (var i = 0; i < $scope.dealUnit.UnitModel.length; i++) {
                    if ($scope.dealUnit.UnitModel[i].UnitModelName == $scope.dealUnit.FilterSearchUnitModel) {
                        $scope.dealUnit.ownedUnitRec.Model = $scope.dealUnit.UnitModel[i].Id;
                        $scope.dealUnit.ownedUnitRec.ModelName = $scope.dealUnit.UnitModel[i].UnitModelName;
                        isModelAlreadyExist = true;
                    }
                }
                if (!isModelAlreadyExist) {
                    $scope.dealUnit.ownedUnitRec.ModelName = $scope.dealUnit.FilterSearchUnitModel;
                    $scope.dealUnit.ownedUnitRec.Model = null;
                    $scope.dealUnit.UnitModelSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.dealUnit.saveUnitModelBlur = 0;
            }
        }
        $scope.dealUnit.saveUnitMake = function(event) {
            $scope.dealUnit.isMakeDropdownOpen = false;
            if ($scope.dealUnit.saveUnitMakeBlur == 0 || $scope.dealUnit.saveUnitMakeBlur == undefined) {
                if ($scope.dealUnit.ownedUnitRec.MakeName != $scope.dealUnit.FilterSearchMake) {
                    $scope.dealUnit.ownedUnitRec.ModelName = '';
                    $scope.dealUnit.ownedUnitRec.Model = null;
                    $scope.dealUnit.FilterSearchUnitModel = '';
                    $scope.dealUnit.ownedUnitRec.SubModel = null;
                    $scope.dealUnit.ownedUnitRec.SubModelName = '';
                    $scope.dealUnit.FilterSearchUnitSubModel = '';
                    $scope.dealUnit.filteredItemsUnitSubModel = '';
                    $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                }
                var isMakeAlreadyExist = false;
                for (var i = 0; i < $scope.dealUnit.UnitMake.length; i++) {
                    if ($scope.dealUnit.UnitMake[i].UnitMakeName == $scope.dealUnit.FilterSearchMake) {
                        $scope.dealUnit.ownedUnitRec.Make = $scope.dealUnit.UnitMake[i].Id;
                        $scope.dealUnit.ownedUnitRec.MakeName = $scope.dealUnit.UnitMake[i].UnitMakeName;
                        isMakeAlreadyExist = true;
                    }
                }
                if (!isMakeAlreadyExist) {
                    $scope.dealUnit.ownedUnitRec.MakeName = $scope.dealUnit.FilterSearchMake;
                    $scope.dealUnit.ownedUnitRec.Make = null;
                    $scope.dealUnit.UnitMakeSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.dealUnit.saveUnitSubModelBlur = 0;
            }
        }
        $scope.dealUnit.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.dealUnit.saveUnitSubModel = function(event) {
            $scope.dealUnit.isSubModelDropdownOpen = false;
            if ($scope.dealUnit.saveUnitSubModelBlur == 0) {
                if ($scope.dealUnit.ownedUnitRec.SubModelName != $scope.dealUnit.FilterSearchUnitSubModel) {
                    $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
                }
                var isSubModelAlreadyExist = false;
                for (var i = 0; i < $scope.dealUnit.UnitSubModel.length; i++) {
                    if ($scope.dealUnit.UnitSubModel[i].SubModelName == $scope.dealUnit.FilterSearchUnitSubModel) {
                        $scope.dealUnit.ownedUnitRec.SubModel = $scope.dealUnit.UnitSubModel[i].Id;
                        $scope.dealUnit.ownedUnitRec.SubModelName = $scope.dealUnit.UnitSubModel[i].SubModelName;
                        isSubModelAlreadyExist = true;
                    }
                }
                if (!isSubModelAlreadyExist) {
                    $scope.dealUnit.ownedUnitRec.SubModelName = $scope.dealUnit.FilterSearchUnitSubModel;
                    $scope.dealUnit.ownedUnitRec.SubModel = null;
                    $scope.dealUnit.UnitSubModelSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.dealUnit.saveUnitSubModelBlur = 0;
            }
        }
        $scope.dealUnit.getUnitmakeList = function(event) {
            $scope.dealUnit.isMakeDropdownOpen = true;
            $scope.dealUnit.isModelDropdownOpen = false;
            $scope.dealUnit.isSubModelDropdownOpen = false;
            event.preventDefault();
            angular.element('.controls').hide();
            angular.element('#dealUnitMakeSelectedId').show();
            DealUnitService.getUnitmakeList().then(function(sucessResultList) {
                $scope.dealUnit.UnitMake = sucessResultList;
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
        $scope.dealUnit.getUnitModelList = function(event) {
            $scope.dealUnit.isMakeDropdownOpen = false;
            $scope.dealUnit.isModelDropdownOpen = true;
            $scope.dealUnit.isSubModelDropdownOpen = false;
            if ($scope.dealUnit.UnitMakeSelected == null || $scope.dealUnit.UnitMakeSelected == '' || $scope.dealUnit.UnitMakeSelected.Id == undefined) {
                return;
            }
            angular.element('.controls').hide();
            angular.element('#dealUnitMainModelId').show();
            DealUnitService.getUnitModelList($scope.dealUnit.UnitMakeSelected.Id).then(function(sucessResultList) {
                $scope.dealUnit.UnitModel = sucessResultList;
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
        $scope.dealUnit.getUnitSubModelList = function(event) {
            $scope.dealUnit.isMakeDropdownOpen = false;
            $scope.dealUnit.isModelDropdownOpen = false;
            $scope.dealUnit.isSubModelDropdownOpen = true;
            if ($scope.dealUnit.UnitMakeSelected == null || $scope.dealUnit.UnitMakeSelected == '' || $scope.dealUnit.UnitMakeSelected.Id == undefined) {
                return;
            }
            if ($scope.dealUnit.UnitModelSelected == null || $scope.dealUnit.UnitModelSelected == '' || $scope.dealUnit.UnitModelSelected.Id == undefined || $scope.dealUnit.UnitModelSelected.Id == '') {
                return;
            }
            angular.element('.controls').hide();
            angular.element('#DealSubModelId').show();
            DealUnitService.getUnitSubModelList($scope.dealUnit.UnitModelSelected.Id, $scope.dealUnit.UnitMakeSelected.Id).then(function(sucessResultList) {
                $scope.dealUnit.UnitSubModel = sucessResultList;
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
        $scope.dealUnit.changeUnitMake = function(make, event) {
            $scope.dealUnit.saveUnitMakeBlur = 1;
            $scope.dealUnit.UnitMakeSelected = make;
            $scope.dealUnit.FilterSearchMake = make.UnitMakeName;
            $scope.dealUnit.ownedUnitRec.MakeName = $scope.dealUnit.UnitMakeSelected.UnitMakeName;
            $scope.dealUnit.ownedUnitRec.Make = $scope.dealUnit.UnitMakeSelected.Id;
            $scope.dealUnit.UnitModel = [];
            $scope.dealUnit.UnitModelSelected = {};
            $scope.dealUnit.UnitModelNameStr = '';
            $scope.dealUnit.UnitSubModelNameStr = '';
            $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
            $scope.dealUnit.UnitSubModel = [];
            $scope.dealUnit.UnitSubModelSelected = {};
            $scope.dealUnit.ownedUnitRec.Model = null;
            $scope.dealUnit.ownedUnitRec.SubModelName = null;
            $scope.dealUnit.FilterSearchUnitModel = '';
            $scope.dealUnit.FilterSearchUnitSubModel = '';
            $scope.dealUnit.filteredItemsUnitSubModel = '';
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            $scope.dealUnit.saveUnitMakeBlur = 0;
        }
        $scope.dealUnit.changeUnitmodel = function(model, event) {
            $scope.dealUnit.saveUnitModelBlur = 1;
            $scope.dealUnit.FilterSearchUnitModel = model.UnitModelName;
            $scope.dealUnit.UnitModelSelected = model;
            $scope.dealUnit.ownedUnitRec.Model = $scope.dealUnit.UnitModelSelected.Id;
            $scope.dealUnit.ownedUnitRec.ModelName = $scope.dealUnit.UnitModelSelected.UnitModelName;
            $scope.dealUnit.ownedUnitRec.MakeModelDescription = '';
            $scope.dealUnit.UnitSubModel = [];
            $scope.dealUnit.UnitSubModelSelected = {};
            $scope.dealUnit.ownedUnitRec.SubModelName = null;
            $scope.dealUnit.FilterSearchUnitSubModel = '';
            $scope.dealUnit.UnitSubModelNameStr = '';
            $scope.dealUnit.filteredItemsUnitSubModel = '';
            $scope.dealUnit.saveUnitModelBlur = 0;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }
        $scope.dealUnit.changeUnitSubmodel = function(model, event) {
            $scope.dealUnit.saveUnitSubModelBlur = 1;
            $scope.dealUnit.FilterSearchUnitSubModel = model.SubModelName;
            $scope.dealUnit.UnitSubModelSelected = model;
            $scope.dealUnit.ownedUnitRec.SubModel = $scope.dealUnit.UnitSubModelSelected.Id;
            $scope.dealUnit.ownedUnitRec.SubModelName = $scope.dealUnit.UnitSubModelSelected.SubModelName;
            $scope.dealUnit.saveUnitSubModelBlur = 0;
            $scope.dealUnit.ownedUnitRec.MakeModelDescription = $scope.dealUnit.UnitSubModelSelected.SubmodelDescription;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }
        $scope.dealUnit.ChangeSeletedUnitMake = function(event) {
            if (event.which === 40) {
                $scope.dealUnit.CurrentIndexMake++;
            } else if (event.which === 38) {
                if ($scope.dealUnit.CurrentIndexMake >= 1) {
                    $scope.dealUnit.CurrentIndexMake--;
                }
            } else if (event.which === 13) {
                $scope.dealUnit.changeUnitMake($scope.dealUnit.filteredItemsMake[$scope.dealUnit.CurrentIndexMake], event);
                $scope.dealUnit.CurrentIndexMake = -1;
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.dealUnit.filteredItemsMake == undefined || $scope.dealUnit.filteredItemsMake.length == 0 || $scope.dealUnit.FilterSearchMake == undefined) {
                    $scope.dealUnit.CurrentIndexMake = -1;
                    return;
                }
                if (angular.lowercase($scope.dealUnit.filteredItemsMake[0].UnitMakeName).trim() == angular.lowercase($scope.dealUnit.FilterSearchMake).trim()) {
                    $scope.dealUnit.CurrentIndexMake = 0;
                } else {
                    $scope.dealUnit.CurrentIndexMake = -1;
                }
            }
        }
        $scope.dealUnit.ChangeSeletedUnitModel = function(event) {
            if (event.which === 40) {
                $scope.dealUnit.CurrentIndexUnitModel++;
            } else if (event.which === 38) {
                if ($scope.dealUnit.CurrentIndexUnitModel >= 1) {
                    $scope.dealUnit.CurrentIndexUnitModel--;
                }
            } else if (event.which === 13) {
                $scope.dealUnit.changeUnitmodel($scope.dealUnit.filteredItemsUnitModel[$scope.dealUnit.CurrentIndexUnitModel], event);
                $scope.dealUnit.filteredItemsUnitModel = {};
                $scope.dealUnit.CurrentIndexUnitModel = -1;
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.dealUnit.filteredItemsUnitModel == undefined || $scope.dealUnit.filteredItemsUnitModel.length == 0 || $scope.dealUnit.FilterSearchUnitModel == undefined) {
                    $scope.dealUnit.CurrentIndexUnitModel = -1;
                    return;
                }
                if (angular.lowercase($scope.dealUnit.filteredItemsUnitModel[0].UnitModelName).trim() == angular.lowercase($scope.dealUnit.FilterSearchUnitModel).trim()) {
                    $scope.dealUnit.CurrentIndexUnitModel = 0;
                } else {
                    $scope.dealUnit.CurrentIndexUnitModel = -1
                }
            }
        }
        $scope.dealUnit.ChangeSeletedUnitSubModel = function(event) {
            if (event.which === 40) {
                $scope.dealUnit.CurrentIndexUnitSubModel++;
            } else if (event.which === 38) {
                if ($scope.dealUnit.CurrentIndexUnitSubModel >= 1) {
                    $scope.dealUnit.CurrentIndexUnitSubModel--;
                }
            } else if (event.which === 13) {
                $scope.dealUnit.changeUnitSubmodel($scope.dealUnit.filteredItemsUnitSubModel[$scope.dealUnit.CurrentIndexUnitSubModel], event);
                $scope.dealUnit.CurrentIndexUnitSubModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.dealUnit.filteredItemsUnitSubModel == undefined || $scope.dealUnit.filteredItemsUnitSubModel.length == 0 || $scope.dealUnit.FilterSearchUnitSubModel == undefined) {
                    $scope.dealUnit.CurrentIndexUnitSubModel = -1;
                    return;
                }
                if (angular.lowercase($scope.dealUnit.filteredItemsUnitSubModel[0].SubModelName).trim() == angular.lowercase($scope.dealUnit.FilterSearchUnitSubModel).trim()) {
                    $scope.dealUnit.CurrentIndexUnitSubModel = 0;
                } else {
                    $scope.dealUnit.CurrentIndexUnitSubModel = -1;
                }
            }
        }
        $scope.dealUnit.saveDealForm = function() {
            var isValidForm = $scope.dealUnit.validateFormValidationModel();
            if (isValidForm) {
                $scope.dealUnit.SaveCustomerOwnedUnitsToserver(angular.toJson($scope.dealUnit.ownedUnitRec))
            }
        }
        $scope.dealUnit.SaveCustomerOwnedUnitsToserver = function(selectedCOURecords) {
            var dealId = $scope.dealUnit.dealId;
            DealUnitService.saveTemporaryUnit(dealId, selectedCOURecords).then(function(relatedCOUList) {
                $scope.dealUnit.ownedUnitRec = relatedCOUList.UnitList[$scope.dealUnit.currentIndex];
                if (angular.element('#AddNewDealCOU') != null) {
                    angular.element('#AddNewDealCOU').modal('hide');
                    hideModelWindow();
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                }
                $scope.$parent.CustomerOrderModel.DealItemList[$scope.dealUnit.currentIndex] = relatedCOUList.UnitList[$scope.dealUnit.currentIndex];
                $scope.$parent.CustomerOrderModel.DealInfo = relatedCOUList.DealInfo;
                $scope.$parent.CustomerOrderModel.editForBaseUnitPrice();
                Notification.success($Label.Generic_Saved);
            }, function(errorSearchResult) {
                $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                Notification.error($Label.Generic_Error);
            });
        }
        $scope.dealUnit.openDealUnitPopupWithRouting = function() {
            $scope.dealUnit.dealId = $stateParams.DealUnitParams.dealId;
            $scope.dealUnit.ownedUnitRec.dealItemId = $stateParams.DealUnitParams.dealItemId;
            $scope.dealUnit.clearAllData();
            $scope.dealUnit.ownedUnitRec = angular.copy($stateParams.DealUnitParams.dealSelectedModel);
            $scope.dealUnit.currentIndex = $stateParams.DealUnitParams.index;
            $scope.dealUnit.openCustomerSearchPopup();
        };
        $scope.dealUnit.openDealUnitPopupWithRouting();
    }])
});