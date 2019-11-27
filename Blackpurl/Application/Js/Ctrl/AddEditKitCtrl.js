define(['Routing_AppJs_PK', 'AddEditKitServices', 'AngularNgEnter', 'AddEditUnitServices', 'CustomMakeSort'], function(Routing_AppJs_PK, AddEditKitServices, AngularNgEnter, AddEditUnitServices, CustomMakeSort) {
    var injector = angular.injector(['ui-notification', 'ng']);
    $(document).ready(function() {
        $('.controls').hide();
        $(".form-control").focus(function() {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).css('display', 'block');
            if ($(this).hasClass("txtbox")) {
                $(".multiselect").css("border", "1px solid #ccc");
                $(this).parent().css("border", "2px solid #00AEEF");
            } else {
                $(".multiselect").css("border", "1px solid #ccc");
            }
        })
        $(document).on("mouseenter", ".multiselect span", function() {
            $(this).find("i").css("display", "block");
        });
        $(document).on("mouseleave", ".multiselect span", function() {
            $(this).find("i").css("display", "none");
        });
    })
    // injected AddEditUnitServices,VINOperationsService
    Routing_AppJs_PK.controller('AddEditKitCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$stateParams', '$state', 'AddEditKitService', 'VINOperationsService','$translate', function($scope, $timeout, $q, $rootScope, $stateParams, $state, AddEditKitService, VINOperationsService,$translate) {
        var Notification = injector.get("Notification");
        /****** Modals initialization ******/
        if ($scope.KitCompModal == undefined) {
            $scope.KitCompModal = {};
        }
        $scope.KitCompModal.KitModal = {};
        $scope.KitCompModal.SimilarKits = [];
        $scope.KitCompModal.tabIndexValue = 2000;
        $scope.KitCompModal.FilterSearchMake = '';
        $scope.KitCompModal.FilterSearchUnitModel = '';
        $scope.KitCompModal.FilterSearchUnitSubModel = '';
        $scope.KitCompModal.filteredItemsMake = {};
        $scope.KitCompModal.CurrentIndexMake = -1;
        $scope.KitCompModal.CurrentIndexUnitModel = -1;
        $scope.KitCompModal.CurrentIndexUnitSubModel = -1;
        $scope.KitCompModal.CauseConcernCorrectionItems_editRow = [];
        $scope.KitCompModal.setDefaultValidationModel = function() {
            $scope.KitCompModal.KitFormValidationModal = {
                Code: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required,Maxlength',
                    Maxlength: 50
                },
                Description: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            };
        }
        $scope.KitCompModal.KitValidationModel = {
            Make: {
                isError: false,
                ErrorMessage: '',
                Type: ''
            },
            Model: {
                isError: false,
                ErrorMessage: '',
                Type: ''
            },
            SubModel: {
                isError: false,
                ErrorMessage: '',
                Type: ''
            }
        };
        $scope.KitCompModal.helpText = {
            Code: $translate.instant('Helptext_kit_code'),
            Description: $translate.instant('Helptext_kit_desc'),
            Concern: $translate.instant('Helptext_concern'),
            Cause: $translate.instant('Helptext_cause'),
            Correction: $translate.instant('Helptext_correction'),
            Make: $translate.instant('Helptext_make'),
            Model: $translate.instant('Helptext_model'),
            SubModel: $translate.instant('Helptext_submodel')
        };
        /****** Add/Edit Labour events ******/
        $scope.$on('AddKitEvent', function() {
            $scope.KitCompModal.disableSaveBtn = false;  
            $scope.KitCompModal.openAddKitPopup();
        });
        $scope.$on('EditKitEvent', function(event, kitInfo) {
            $scope.KitCompModal.disableSaveBtn = false;  
            $scope.KitCompModal.openEditkitPopup(kitInfo);
        });
        $scope.KitCompModal.formFieldJustGotFocus = function(Value) {
            showToolTip(Value);
        }
        $scope.KitCompModal.openEditkitPopup = function(kitInfo) {
            $scope.KitCompModal.clearAllData();
            kitInfo = angular.copy(kitInfo);
            $scope.KitCompModal.setDefaultValidationModel();
            $scope.KitCompModal.KitMasterData = [];
            $scope.KitCompModal.KitModal.TransactionTypeList = [];
            AddEditKitService.getMasterData().then(function(masterData) {
                $scope.KitCompModal.KitMasterData = masterData;
                $scope.KitCompModal.UnitMakeList = $scope.KitCompModal.KitMasterData.UnitMakeList;
                $scope.KitCompModal.TransactionType = $scope.KitCompModal.KitMasterData.TransactionTypeList;
                $scope.KitCompModal.isEditMode = true;
                $scope.KitCompModal.KitModal.Id = kitInfo.Id;
                $scope.KitCompModal.KitModal.Code = kitInfo.Code;
                $scope.KitCompModal.KitModal.Description = kitInfo.Description;
                $scope.KitCompModal.KitModal.CanItSplit = kitInfo.CanItSplit;
                $scope.KitCompModal.KitModal.IsServiceKit = kitInfo.IsServiceKit;
                $scope.KitCompModal.KitModal.NumberOfLabours = kitInfo.NumberOfLabours;
                $scope.KitCompModal.FilterSearchMake = kitInfo.MakeName;
                $scope.KitCompModal.FilterSearchUnitModel = kitInfo.ModelName;
                $scope.KitCompModal.FilterSearchUnitSubModel = kitInfo.SubModelName;
                $scope.KitCompModal.UnitMakeSelected = {
                    Id: kitInfo.MakeId,
                    UnitMakeName: kitInfo.MakeName
                };
                $scope.KitCompModal.UnitModelSelected = {
                    Id: kitInfo.ModelId,
                    SubModelName: kitInfo.SubModelName,
                    UnitModelName: kitInfo.ModelName
                };
                $scope.KitCompModal.UnitSubModelSelected = {
                    Id: kitInfo.SubModelId,
                    SubModelName: kitInfo.SubModelName,
                };
                $scope.KitCompModal.KitModal.Concern = kitInfo.Concern;
                $scope.KitCompModal.KitModal.Cause = kitInfo.Cause;
                $scope.KitCompModal.KitModal.Correction = kitInfo.Correction;
                $scope.KitCompModal.editLineItemsForCauseConcernCorrection();
                $scope.KitCompModal.KitModal.TransactionTypeList = kitInfo.TransactionTypeList;
                var makeObj = {
                    UnitMakeName: kitInfo.MakeName,
                    Id: kitInfo.MakeId
                };
                $scope.KitCompModal.SelectedMake = makeObj;
                $scope.KitCompModal.setModelOptions();
                var modelObj = {
                    UnitModelName: kitInfo.ModelName,
                    SubModelName: kitInfo.SubModelName,
                    Id: kitInfo.SubModelId
                };
                var subModelObj = {
                    UnitModelName: kitInfo.ModelName,
                    SubModelName: kitInfo.SubModelName,
                    Id: kitInfo.SubModelId
                };
                $scope.KitCompModal.SelectedModel = modelObj;
                $scope.KitCompModal.SelectedSubModel = subModelObj;
                $scope.KitCompModal.KitModal.IsActive = kitInfo.IsActive;
                $scope.KitCompModal.openPopup();
                $scope.KitCompModal.clearFields('SelectedSubModel', 'dropdown');
                setTimeout(function() {
                    angular.element('#txtdescription').focus();
                }, 1000);
            }, function(errorSearchResult) {
                //FIXME
            });
        }
        /****** Add/Edit Labour eventlisteners ******/
        $scope.KitCompModal.openAddKitPopup = function() {
            $scope.KitCompModal.clearAllData();
            $scope.KitCompModal.openPopup();
            setTimeout(function() {
                angular.element('#feeCodeInput').focus();
            }, 1000);
        }
        $scope.KitCompModal.openPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#addNewKit').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.KitCompModal.closePopup = function() {
            angular.element('#addNewKit').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.KitCompModal.clearAllData = function() {
            $scope.KitCompModal.isEditMode = false;
            $scope.KitCompModal.KitModal = {};
            $scope.KitCompModal.ownedUnitRec = {};
            $scope.KitCompModal.SimilarKits = [];
            $scope.KitCompModal.LoadMasterData();
            $scope.KitCompModal.ownedUnitRec.Make = null;
            $scope.KitCompModal.ownedUnitRec.Model = null;
            $scope.KitCompModal.ownedUnitRec.SubModel = null;
            $scope.KitCompModal.ownedUnitRec.MakeName = '';
            $scope.KitCompModal.ownedUnitRec.SubModelName = '';
            $scope.KitCompModal.ownedUnitRec.ModelName = '';
            $scope.KitCompModal.ownedUnitRec.SubModelName = null;
            $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
            $scope.KitCompModal.UnitMake = [];
            $scope.KitCompModal.UnitModel = [];
            $scope.KitCompModal.UnitSubModel = [];
            $scope.KitCompModal.UnitMakeSelected = {};
            $scope.KitCompModal.UnitModelSelected = {};
            $scope.KitCompModal.UnitSubModelSelected = {};
            $scope.KitCompModal.setDataDefault();
        }
        $scope.KitCompModal.setDataDefault = function() {
            $scope.KitCompModal.KitModal.CanItSplit = true;
            $scope.KitCompModal.KitModal.IsServiceKit = false;
            $scope.KitCompModal.KitModal.IsActive = true;
            $scope.KitCompModal.KitModal.Code = null;
            $scope.KitCompModal.KitModal.Description = null;
            $scope.KitCompModal.KitModal.Concern = [];
            $scope.KitCompModal.KitModal.Correction = [];
            $scope.KitCompModal.KitModal.Cause = [];
            $scope.KitCompModal.KitModal.TransactionTypeList = [];
            $scope.KitCompModal.setDefaultValidationModel();
            var makeObj = {
                UnitMakeName: '',
                Id: null
            };
            $scope.KitCompModal.SelectedMake = makeObj;
            var modelObj = {
                UnitModelName: '',
                SubModelName: '',
                Id: null
            };
            var subModelObj = {
                UnitModelName: '',
                SubModelName: '',
                Id: null
            };
            $scope.KitCompModal.SelectedModel = modelObj;
            $scope.KitCompModal.SelectedSubModel = subModelObj;
            $scope.KitCompModal.UnitMakeSelected = {
                Id: $scope.KitCompModal.ownedUnitRec.Make,
                UnitMakeName: $scope.KitCompModal.ownedUnitRec.MakeName
            };
            $scope.KitCompModal.UnitModelSelected = {
                Id: $scope.KitCompModal.ownedUnitRec.Model,
                SubModelName: $scope.KitCompModal.ownedUnitRec.SubModelName,
                UnitModelName: $scope.KitCompModal.ownedUnitRec.ModelName
            };
            $scope.KitCompModal.UnitSubModelSelected = {
                Id: $scope.KitCompModal.ownedUnitRec.SubModel,
                SubModelName: $scope.KitCompModal.ownedUnitRec.SubModelName,
            };
            $scope.KitCompModal.FilterSearchMake = $scope.KitCompModal.KitModal.MakeName;
            $scope.KitCompModal.FilterSearchUnitModel = $scope.KitCompModal.KitModal.ModelName;
            $scope.KitCompModal.FilterSearchUnitSubModel = $scope.KitCompModal.KitModal.SubModelName;
        }
        $scope.KitCompModal.setModelOptions = function() {
            if ($scope.KitCompModal.SelectedMake == '' || $scope.KitCompModal.SelectedMake == null) {
                $scope.KitCompModal.SelectedModel = '';
                $scope.KitCompModal.SelectedSubModel = '';
            }
            $scope.KitCompModal.UnitModelList = $scope.KitCompModal.KitMasterData.UnitModelList[0].unitMakeNameToUnitModelMap[$scope.KitCompModal.SelectedMake.UnitMakeName];
            $scope.KitCompModal.UnitSubModelList = $scope.KitCompModal.KitMasterData.UnitModelList[0].unitMakeNameToUnitModelMap[$scope.KitCompModal.SelectedMake.UnitMakeName];
            $scope.KitCompModal.SelectedSubModel = '';
        }
        $scope.KitCompModal.isTransactionTypeSelected = function(ttModel) {
            for (var i = 0; i < $scope.KitCompModal.KitModal.TransactionTypeList.length; i++) {
                if (ttModel.TTName == $scope.KitCompModal.KitModal.TransactionTypeList[i].TTName) {
                    return true;
                }
            }
            return false;
        }
        $scope.KitCompModal.updateTTModel = function(rowNumber, ttModel) {
            if ($scope.KitCompModal.KitModal.TransactionTypeList == undefined) {
                $scope.KitCompModal.KitModal.TransactionTypeList = [];
            }
            var isExist = $scope.KitCompModal.isTransactionTypeSelected(ttModel);
            if (!isExist) {
                $scope.KitCompModal.KitModal.TransactionTypeList.push(ttModel);
            } else {
                for (var i = 0; i < $scope.KitCompModal.KitModal.TransactionTypeList.length; i++) {
                    if (ttModel.TTName == $scope.KitCompModal.KitModal.TransactionTypeList[i].TTName) {
                        $scope.KitCompModal.KitModal.TransactionTypeList.splice(i, 1);
                    }
                }
            }
        }
        $scope.KitCompModal.toggleServiceKit = function() {
            if ($scope.KitCompModal.KitModal.IsServiceKit && $scope.KitCompModal.KitModal.NumberOfLabours > 0) {
                Notification.error($translate.instant('AddEditKit_Can_t_deselect_because_of_labor'));
                return;
            }
            $scope.KitCompModal.KitModal.IsServiceKit = !$scope.KitCompModal.KitModal.IsServiceKit;
            $scope.KitCompModal.resetServiceKitSection($scope.KitCompModal.KitModal.IsServiceKit);
        }
        $scope.KitCompModal.resetServiceKitSection = function(isServiceKit) {
            if (!isServiceKit) {
                $scope.KitCompModal.KitModal.Concern = [];
                $scope.KitCompModal.KitModal.Correction = [];
                $scope.KitCompModal.KitModal.Cause = [];
                $scope.KitCompModal.NewConcern = '';
                $scope.KitCompModal.NewCorrection = '';
                $scope.KitCompModal.NewCause = '';
                $scope.KitCompModal.KitModal.TransactionTypeList = [];
                var makeObj = {
                    UnitMakeName: '',
                    Id: null
                };
                $scope.KitCompModal.SelectedMake = makeObj;
                var modelObj = {
                    UnitModelName: '',
                    SubModelName: '',
                    Id: null
                };
                var subModelObj = {
                    UnitModelName: '',
                    SubModelName: '',
                    Id: null
                };
                $scope.KitCompModal.SelectedModel = modelObj;
                $scope.KitCompModal.SelectedSubModel = subModelObj;
            } else {
                for (var i = 0; i < $scope.KitCompModal.TransactionType.length; i++) {
                    $scope.KitCompModal.KitModal.TransactionTypeList.push(angular.copy($scope.KitCompModal.TransactionType[i]));
                }
            }
        }
        $scope.KitCompModal.adjustTabIndex = function(e) {
            if (!$scope.KitCompModal.isEditMode()) {
                if (e.which == 9) {
                    $('#feeCodeInput').focus();
                    e.preventDefault();
                }
            } else {
                angular.element('#txtdescription').focus();
            }
        }
        $scope.KitCompModal.clearFields = function(key, type) {
            if (type == 'value') {
                $scope.KitCompModal.KitModal[key] = '';
            } else if (type == 'array') {
                $scope.KitCompModal.KitModal[key] = [];
                $scope.KitCompModal[$scope.multiInputModel[key]] = '';
            } else if (type == 'dropdown') {
                $scope.KitCompModal[key] = '';
            } else if (type == 'lookup') {
                $scope.KitCompModal[key] = null;
                if (key == 'SelectedModel') {
                    $scope.KitCompModal.ownedUnitRec.Model = null;
                    $scope.KitCompModal.ownedUnitRec.SubModelName = null;
                    $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
                    $scope.KitCompModal.UnitSubModelSelected = {}; 
                    $scope.KitCompModal.UnitSubModel = []; 
                    $scope.KitCompModal.FilterSearchUnitModel = '';
                    $scope.KitCompModal.FilterSearchUnitSubModel = '';
                }
                if (key == 'SelectedMake') {
                    $scope.KitCompModal.UnitMakeSelected = {};
                    $scope.KitCompModal.UnitModelSelected = {}; 
                    $scope.KitCompModal.UnitSubModelSelected = {}; 
                    $scope.KitCompModal.UnitModel = []; 
                    $scope.KitCompModal.UnitSubModel = []; 
                    $scope.KitCompModal.ownedUnitRec.Make = null;
                    $scope.KitCompModal.ownedUnitRec.Model = null;
                    $scope.KitCompModal.ownedUnitRec.SubModelName = null;
                    $scope.KitCompModal.ownedUnitRec.MakeModelDescription = ''; 
                    $scope.KitCompModal.FilterSearchMake = ''; 
                    $scope.KitCompModal.FilterSearchUnitModel = '';
                    $scope.KitCompModal.FilterSearchUnitSubModel = '';
                    $scope.KitCompModal.filteredItemsUnitSubModel = ''; 
                }
                if (key == 'Selectedsubmodel') { 
                    $scope.KitCompModal.UnitSubModelSelected = {};
                    $scope.KitCompModal.FilterSearchUnitSubModel = '';
                    $scope.KitCompModal.filteredItemsUnitSubModel = ''; 
                    $scope.KitCompModal.UnitSubModel = [];
                    $scope.KitCompModal.ownedUnitRec.SubModelName = null;
                }
            }
            if (key == 'Code' || key == 'Description') {
                $scope.KitCompModal.getSimilarKits(key);
            }
        }
        $scope.KitCompModal.LoadMasterData = function() {
            $scope.KitCompModal.KitMasterData = [];
            AddEditKitService.getMasterData().then(function(masterData) {
                $scope.KitCompModal.KitMasterData = masterData;
                $scope.KitCompModal.UnitMakeList = $scope.KitCompModal.KitMasterData.UnitMakeList;
                $scope.KitCompModal.TransactionType = $scope.KitCompModal.KitMasterData.TransactionTypeList;
                $scope.KitCompModal.editLineItemsForCauseConcernCorrection();
            }, function(errorSearchResult) {});
        }
        $scope.KitCompModal.editLineItemsForCauseConcernCorrection = function() {
            $scope.KitCompModal.CauseConcernCorrectionItems_editRow = [];
            var SOItems = {};
            SOItems = {
                isEditEnabled_Concern: true,
                isEditEnabled_Cause: true,
                isEditEnabled_Correction: true,
                Concern: [],
                Cause: [],
                Correction: []
            };
            for (j = 0; j < $scope.KitCompModal.KitModal.Concern.length; j++) {
                SOItems.Concern.push({
                    isEdit: false
                });
            }
            for (j = 0; j < $scope.KitCompModal.KitModal.Cause.length; j++) {
                SOItems.Cause.push({
                    isEdit: false
                });
            }
            for (j = 0; j < $scope.KitCompModal.KitModal.Correction.length; j++) {
                SOItems.Correction.push({
                    isEdit: false
                });
            }
            $scope.KitCompModal.CauseConcernCorrectionItems_editRow = SOItems;
        }
        $scope.KitCompModal.editCauseConcernCorrectionItem = function($event, causeLineItemIndex, ModelKey) {
            var isEditModeEnabled = false;
            for (i = 0; i < $scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey].length; i++) {
                if ($scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey][i].isEdit == true) {
                    $scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey][i].isEdit = false;
                    $scope.KitCompModal.CauseConcernCorrectionItems_editRow['isEditEnabled_' + ModelKey] = true;
                    isEditModeEnabled = true;
                }
            }
            if (!isEditModeEnabled) {
                $scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey][causeLineItemIndex].isEdit = true;
                $scope.KitCompModal.CauseConcernCorrectionItems_editRow['isEditEnabled_' + ModelKey] = false;
                $timeout(function() {
                    angular.element('#causeConcernCorrectionLabeledit_' + ModelKey + '_' + causeLineItemIndex).focus();
                    $('.controls').hide();
                    $('#' + $($event.target).attr('rel')).css('display', 'block');
                    $(".multiselect").css("border", "1px solid #ccc");
                    $($event.target).closest('.multiselect').css("border", "2px solid #00AEEF");
                }, 10);
            }
        }
        $scope.KitCompModal.editCauseConcernCorrectionRowTabOut = function(event, causeLineItemIndex, ModelKey) {
            $timeout(function() {
                var isAlreadyExist = false;
                var fieldValue = $scope.KitCompModal.KitModal[ModelKey][causeLineItemIndex];
                if (event.keyCode == 13 || event.keyCode == 9) {
                    if (fieldValue != '' && fieldValue != undefined) {
                        for (var i = 0; i < $scope.KitCompModal.KitModal[ModelKey].length; i++) {
                            if (($scope.KitCompModal.KitModal[ModelKey][i] == fieldValue) && (i != causeLineItemIndex)) {
                                isAlreadyExist = true;
                                Notification.error('Same ' + ModelKey + ' Already Exist');
                                setTimeout(function() {
                                    angular.element('#causeConcernCorrectionLabeledit_' + ModelKey + '_' + causeLineItemIndex).focus();
                                }, 100);
                            }
                        }
                        if (!isAlreadyExist) {
                            $scope.KitCompModal.KitModal[ModelKey][causeLineItemIndex] = fieldValue;
                            $timeout(function timeout() {
                                $scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey][causeLineItemIndex].isEdit = false;
                                $scope.KitCompModal.CauseConcernCorrectionItems_editRow['isEditEnabled_' + ModelKey] = true;
                            }, 1000);
                        }
                    } else {
                        $scope.KitCompModal.removeFromMultiSelect(event, causeLineItemIndex, ModelKey);
                        $timeout(function timeout() {
                            $scope.KitCompModal.CauseConcernCorrectionItems_editRow[ModelKey][causeLineItemIndex].isEdit = false;
                            $scope.KitCompModal.CauseConcernCorrectionItems_editRow['isEditEnabled_' + ModelKey] = true;
                        }, 1000);
                    }
                }
            }, 10);
        }
        $scope.KitCompModal.validateForm = function() {
            angular.forEach($scope.KitCompModal.KitFormValidationModal, function(value, key) {
                $scope.KitCompModal.validateFieldWithKey(key);
            });
        }
        $scope.KitCompModal.validateSubModel = function() {
            var subModelList = $scope.KitCompModal.UnitSubModelList;
            $scope.KitCompModal.UnitSubModelList = [];
            if (subModelList != undefined) {
                for (var i = 0; i < subModelList.length; i++) {
                    if (subModelList[i].SubModelName != null) {
                        $scope.KitCompModal.UnitSubModelList.push(subModelList[i]);
                    }
                }
            }
            return $scope.KitCompModal.UnitSubModelList;
        }
        $scope.KitCompModal.validateFieldWithKey = function(modelKey) {
            var fieldValue = $scope.KitCompModal.KitModal[modelKey];
            var validateType = $scope.KitCompModal.KitFormValidationModal[modelKey].Type;
            var isError = false;
            var ErrorMessage = '';
            if (validateType.indexOf('Maxlength') > -1) {
                if (fieldValue != undefined && fieldValue != '' && fieldValue.length > $scope.KitCompModal.KitFormValidationModal[modelKey].Maxlength) {
                    isError = true;
                    ErrorMessage = $translate.instant('Max_Length_Should_Be')+ ' ' + $scope.KitCompModal.KitFormValidationModal[modelKey].Maxlength;
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    isError = true;
                    ErrorMessage = $translate.instant('Field_Is_Required');
                }
            }
            $scope.KitCompModal.KitFormValidationModal[modelKey].isError = isError;
            $scope.KitCompModal.KitFormValidationModal[modelKey].ErrorMessage = ErrorMessage;
            if ($scope.KitCompModal.KitFormValidationModal[modelKey].isError == true) {
                $scope.KitCompModal.isValidForm = false;
            }
        }
        $scope.KitCompModal.SaveKitForm = function(event) {
            if ($scope.KitCompModal.disableSaveBtn) {
                return;
            }
            $scope.KitCompModal.isValidForm = true;
            $scope.KitCompModal.validateForm();
            if (!$scope.KitCompModal.isValidForm) {
                return;
            }
            for (var i = 0; i < $scope.KitCompModal.SimilarKits.length; i++) {
                if ($scope.KitCompModal.SimilarKits[i].PriorityValue == 1) {
                    Notification.error($translate.instant('AddEditKit_Similar_Record_Present'));
                    return;
                }
            }
            $scope.KitCompModal.saveKitData();
        }
        $scope.KitCompModal.saveKitData = function() {
            if ($scope.KitCompModal.UnitMakeSelected != null && $scope.KitCompModal.UnitMakeSelected != undefined) {
                $scope.KitCompModal.KitModal.MakeId = $scope.KitCompModal.UnitMakeSelected.Id;
                $scope.KitCompModal.KitModal.MakeName = $scope.KitCompModal.UnitMakeSelected.UnitMakeName;
            }
            if ($scope.KitCompModal.UnitModelSelected != null && $scope.KitCompModal.UnitModelSelected != undefined) {
                $scope.KitCompModal.KitModal.ModelId = $scope.KitCompModal.UnitModelSelected.Id;
                $scope.KitCompModal.KitModal.ModelName = $scope.KitCompModal.UnitModelSelected.UnitModelName;
            }
            if ($scope.KitCompModal.UnitSubModelSelected != null && $scope.KitCompModal.UnitSubModelSelected != undefined) {
                $scope.KitCompModal.KitModal.SubModelId = $scope.KitCompModal.UnitSubModelSelected.Id;
                $scope.KitCompModal.KitModal.SubModelName = $scope.KitCompModal.UnitSubModelSelected.SubModelName;
            }
            if ($scope.KitCompModal.FilterSearchMake != undefined && $scope.KitCompModal.FilterSearchMake != null && $scope.KitCompModal.FilterSearchMake != '' && ($scope.KitCompModal.FilterSearchUnitModel == undefined || $scope.KitCompModal.FilterSearchUnitModel == null || $scope.KitCompModal.FilterSearchUnitModel == '')) {
                $scope.KitCompModal.KitValidationModel["Model"].isError = true;
                return;
            } else if (($scope.KitCompModal.FilterSearchUnitModel != undefined && $scope.KitCompModal.FilterSearchUnitModel != null && $scope.KitCompModal.FilterSearchUnitModel != '') && ($scope.KitCompModal.FilterSearchMake == undefined || $scope.KitCompModal.FilterSearchMake == null || $scope.KitCompModal.FilterSearchMake == '')) {
                $scope.KitCompModal.KitValidationModel["Make"].isError = true;
                return;
            } else if ($scope.KitCompModal.FilterSearchUnitSubModel != undefined && $scope.KitCompModal.FilterSearchUnitSubModel != null && $scope.KitCompModal.FilterSearchUnitSubModel != '') {
                var isError = false;
                if ($scope.KitCompModal.FilterSearchMake == undefined || $scope.KitCompModal.FilterSearchMake == null || $scope.KitCompModal.FilterSearchMake == '') {
                    $scope.KitCompModal.KitValidationModel["Make"].isError = true;
                    isError = true;
                }
                if ($scope.KitCompModal.FilterSearchUnitModel == undefined || $scope.KitCompModal.FilterSearchUnitModel == null || $scope.KitCompModal.FilterSearchUnitModel == '') {
                    $scope.KitCompModal.KitValidationModel["Model"].isError = true;
                    isError = true;
                }
                if (isError == true) {
                    return;
                }
            }
            $scope.KitCompModal.disableSaveBtn = true; 
            AddEditKitService.saveKitInfo($scope.KitCompModal.KitModal).then(function(kitRec) {
                if ($scope.$parent.kitRecordSaveCallback != undefined && $scope.KitCompModal.isEditMode) {
                    $scope.$parent.kitRecordSaveCallback(kitRec.KitHeaderRec);
                }
                Notification.success($translate.instant('Generic_Saved'));
                angular.element('#addNewKit').modal('hide');
                hideModelWindow();
                $scope.KitCompModal.disableSaveBtn = false; 
                $state.go('ViewKit', {
                    Id: kitRec.KitHeaderRec.Id
                });
            }, function(errorSearchResult) {
                $scope.KitCompModal.disableSaveBtn = false; 
                Notification.error(errorSearchResult);
            });
        }
        $scope.KitCompModal.getSimilarKits = function(modelKey) {
            var fieldValue = $scope.KitCompModal.KitModal[modelKey];
            $scope.KitCompModal.SimilarKits = {};
            if ((($scope.KitCompModal.KitModal['Code'] == '' || $scope.KitCompModal.KitModal['Code'] == null) && ($scope.KitCompModal.KitModal['Description'] == null || $scope.KitCompModal.KitModal['Description'] == '')) || $scope.KitCompModal.isEditMode) {
                return;
            }
            AddEditKitService.getSimilarKits($scope.KitCompModal.KitModal).then(function(similarKits) {
                $scope.KitCompModal.SimilarKits = similarKits;
            }, function(errorSearchResult) {});
        }
        $scope.KitCompModal.removeFromMultiSelect = function(event, index, modelKey) {
            $scope.KitCompModal.KitModal[modelKey].splice(index, 1);
        }
        $scope.multiInputModel = {
            'Concern': 'NewConcern',
            'Cause': 'NewCause',
            'Correction': 'NewCorrection'
        };
        $scope.KitCompModal.addAndRemoveFromMultiSelect = function(event, modelKey) {
            var isAlreadyExist = false;
            var fieldValue = $scope.KitCompModal.KitModal[modelKey];
            if ((event.keyCode == 13 || event.keyCode == 9) && $scope.KitCompModal[$scope.multiInputModel[modelKey]] != '' && $scope.KitCompModal[$scope.multiInputModel[modelKey]] != undefined) {
                for (var i = 0; i < $scope.KitCompModal.KitModal[modelKey].length; i++) {
                    if ($scope.KitCompModal.KitModal[modelKey][i] == $scope.KitCompModal[$scope.multiInputModel[modelKey]]) {
                        isAlreadyExist = true;
                        if(modelKey === 'Concern') {
                        	Notification.error($translate.instant('Same_concern_already_exist'));
                        } else if(modelKey === 'Cause') {
                        	Notification.error($translate.instant('Same_cause_already_exist'));
                        } else if(modelKey === 'Correction') {
                        	Notification.error($translate.instant('Same_correction_already_exist'));
                        }
                    }
                }
                if (!isAlreadyExist) {
                    $scope.KitCompModal.KitModal[modelKey].push($scope.KitCompModal[$scope.multiInputModel[modelKey]]);
                }
                $scope.KitCompModal[$scope.multiInputModel[modelKey]] = '';
                $scope.KitCompModal.editLineItemsForCauseConcernCorrection();
            }
            var length = fieldValue.length;
            if (event.keyCode === 8 && ($scope.KitCompModal[$scope.multiInputModel[modelKey]] == undefined || $scope.KitCompModal[$scope.multiInputModel[modelKey]] == '')) {
                $scope.KitCompModal.KitModal[modelKey].splice(length - 1, 1);
            }
        }
        $scope.KitCompModal.openKitPopup = function() {
            $scope.KitCompModal.disableSaveBtn = false;  
            if ($stateParams.EditKitParams != undefined && $stateParams.EditKitParams.kitRecord != undefined && $stateParams.EditKitParams.kitRecord != null && $stateParams.EditKitParams.kitRecord != '') {
                $scope.KitCompModal.openEditkitPopup($stateParams.EditKitParams.kitRecord);
            } else {
                $scope.KitCompModal.openAddKitPopup();
            }
        }
        $scope.KitCompModal.getUnitmakeList = function(event) {
            event.preventDefault();
            angular.element('.controls').hide();
            angular.element('#kitAppliesToMake').show();
            VINOperationsService.getUnitmakeList().then(function(sucessResultList) {
                $scope.KitCompModal.UnitMake = sucessResultList;
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
        // Method to set selected Make related value in Owned unit Year field value
        $scope.KitCompModal.changeUnitMake = function(make, event) {
            $scope.KitCompModal.saveUnitMakeBlur = 1;
            $scope.KitCompModal.FilterSearchMake = make.UnitMakeName;
            $scope.KitCompModal.UnitMakeSelected = make;
            $scope.KitCompModal.ownedUnitRec.Make = $scope.KitCompModal.UnitMakeSelected.Id;
            $scope.KitCompModal.ownedUnitRec.MakeName = make.UnitMakeName;
            $scope.KitCompModal.UnitModel = [];
            $scope.KitCompModal.UnitModelSelected = {};
            $scope.KitCompModal.UnitSubModel = [];
            $scope.KitCompModal.UnitSubModelSelected = {};
            $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
            $scope.KitCompModal.UnitModelNameStr = '';
            $scope.KitCompModal.UnitSubModelNameStr = '';
            $scope.KitCompModal.ownedUnitRec.Model = null;
            $scope.KitCompModal.ownedUnitRec.SubModelName = null;
            $scope.KitCompModal.FilterSearchUnitModel = '';
            $scope.KitCompModal.FilterSearchUnitSubModel = '';
            $scope.KitCompModal.filteredItemsUnitSubModel = '';
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            $scope.KitCompModal.saveUnitMakeBlur = 0;
        }
        // Make Select Enter
        $scope.KitCompModal.ChangeSeletedUnitMake = function(event) {
            if (event.which === 40) {
                $scope.KitCompModal.CurrentIndexMake++;
            } else if (event.which === 38) {
                if ($scope.KitCompModal.CurrentIndexMake >= 1) {
                    $scope.KitCompModal.CurrentIndexMake--;
                }
            } else if (event.which === 13) {
                $scope.KitCompModal.changeUnitMake($scope.KitCompModal.filteredItemsMake[$scope.KitCompModal.CurrentIndexMake], event);
                $scope.KitCompModal.CurrentIndexMake = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) { 
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.KitCompModal.filteredItemsMake == undefined || $scope.KitCompModal.filteredItemsMake.length == 0 || $scope.KitCompModal.FilterSearchMake == undefined) {
                    $scope.KitCompModal.CurrentIndexMake = -1
                    return;
                }
                if (angular.lowercase($scope.KitCompModal.filteredItemsMake[0].UnitMakeName).trim() == angular.lowercase($scope.KitCompModal.FilterSearchMake).trim()) {
                    $scope.KitCompModal.CurrentIndexMake = 0;
                } else {
                    $scope.KitCompModal.CurrentIndexMake = -1
                }
            }
        }
        // Model Select Enter
        $scope.KitCompModal.ChangeSeletedUnitModel = function(event) {
            if (event.which === 40) {
                $scope.KitCompModal.CurrentIndexUnitModel++;
            } else if (event.which === 38) {
                if ($scope.KitCompModal.CurrentIndexUnitModel >= 1) {
                    $scope.KitCompModal.CurrentIndexUnitModel--;
                }
            } else if (event.which === 13) {
                $scope.KitCompModal.changeUnitmodel($scope.KitCompModal.filteredItemsUnitModel[$scope.KitCompModal.CurrentIndexUnitModel], event);
                $scope.KitCompModal.filteredItemsUnitModel = {}; 
                $scope.KitCompModal.CurrentIndexUnitModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) { 
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.KitCompModal.filteredItemsUnitModel == undefined || $scope.KitCompModal.filteredItemsUnitModel.length == 0 || $scope.KitCompModal.FilterSearchUnitModel == undefined) {
                    $scope.KitCompModal.CurrentIndexUnitModel = -1
                    return;
                }
                if (angular.lowercase($scope.KitCompModal.filteredItemsUnitModel[0].UnitModelName).trim() == angular.lowercase($scope.KitCompModal.FilterSearchUnitModel).trim()) {
                    $scope.KitCompModal.CurrentIndexUnitModel = 0;
                } else {
                    $scope.KitCompModal.CurrentIndexUnitModel = -1
                }
            }
        }
        $scope.KitCompModal.saveUnitMake = function(event) {
            if ($scope.KitCompModal.saveUnitMakeBlur == 0 || $scope.KitCompModal.saveUnitMakeBlur == undefined) {
                if ($scope.KitCompModal.UnitMakeSelected.UnitMakeName != $scope.KitCompModal.FilterSearchMake) { 
                    $scope.KitCompModal.ownedUnitRec.ModelName = '';
                    $scope.KitCompModal.ownedUnitRec.Model = null;
                    $scope.KitCompModal.FilterSearchUnitModel = '';
                    $scope.KitCompModal.ownedUnitRec.SubModel = null;
                    $scope.KitCompModal.ownedUnitRec.SubModelName = '';
                    $scope.KitCompModal.FilterSearchUnitSubModel = '';
                    $scope.KitCompModal.filteredItemsUnitSubModel = '';
                    $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isMakeAlreadyExist = false;
                for (var i = 0; i < $scope.KitCompModal.UnitMake.length; i++) {
                    if ($scope.KitCompModal.UnitMake[i].UnitMakeName == $scope.KitCompModal.FilterSearchMake) {
                        $scope.KitCompModal.ownedUnitRec.Make = $scope.KitCompModal.UnitMake[i].Id;
                        $scope.KitCompModal.ownedUnitRec.MakeName = $scope.KitCompModal.UnitMake[i].UnitMakeName;
                        isMakeAlreadyExist = true;
                    }
                }
                if (!isMakeAlreadyExist) {
                    $scope.KitCompModal.UnitMakeSelected.UnitMakeName = $scope.KitCompModal.FilterSearchMake;
                    $scope.KitCompModal.UnitMakeSelected.Id = null;
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
                if (($scope.KitCompModal.FilterSearchMake != undefined && $scope.KitCompModal.FilterSearchMake != null && $scope.KitCompModal.FilterSearchMake != '')) {
                    $scope.KitCompModal.KitValidationModel["Make"].isError = false;
                }
            } else {
                $scope.KitCompModal.saveUnitMakeBlur = 0;
            }
        }
        $scope.KitCompModal.getUnitModelList = function(event) {
            if ($scope.KitCompModal.FilterSearchMake == null || $scope.KitCompModal.FilterSearchMake == '' || $scope.KitCompModal.UnitMakeSelected.Id == undefined) {
                return;
            }
            angular.element('.controls').hide();
            angular.element('#KitUnitMainModelId').show();
            VINOperationsService.getUnitModelList($scope.KitCompModal.UnitMakeSelected.Id).then(function(sucessResultList) {
                $scope.KitCompModal.UnitModel = sucessResultList;
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
        $scope.KitCompModal.saveUnitModel = function(event) {
            if ($scope.KitCompModal.saveUnitModelBlur == 0 || $scope.KitCompModal.saveUnitModelBlur == undefined) {
                if ($scope.KitCompModal.UnitModelSelected.UnitModelName != $scope.KitCompModal.FilterSearchUnitModel) { 
                    $scope.KitCompModal.ownedUnitRec.SubModel = null;
                    $scope.KitCompModal.ownedUnitRec.SubModelName = '';
                    $scope.KitCompModal.FilterSearchUnitSubModel = '';
                    $scope.KitCompModal.filteredItemsUnitSubModel = '';
                    $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isModelAlreadyExist = false;
                for (var i = 0; i < $scope.KitCompModal.UnitModel.length; i++) {
                    if ($scope.KitCompModal.UnitModel[i].UnitModelName == $scope.KitCompModal.FilterSearchUnitModel) {
                        $scope.KitCompModal.ownedUnitRec.Model = $scope.KitCompModal.UnitModel[i].Id;
                        $scope.KitCompModal.ownedUnitRec.ModelName = $scope.KitCompModal.UnitModel[i].UnitModelName;
                        isModelAlreadyExist = true;
                    }
                }
                if (!isModelAlreadyExist) {
                    $scope.KitCompModal.UnitModelSelected.UnitModelName = $scope.KitCompModal.FilterSearchUnitModel;
                    $scope.KitCompModal.UnitModelSelected.Id = null;
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
                if (($scope.KitCompModal.FilterSearchUnitModel != undefined && $scope.KitCompModal.FilterSearchUnitModel != null && $scope.KitCompModal.FilterSearchUnitModel != '')) {
                    $scope.KitCompModal.KitValidationModel["Model"].isError = false;
                }
            } else {
                $scope.KitCompModal.saveUnitModelBlur = 0;
            }
        }
        $scope.KitCompModal.changeUnitmodel = function(model, event) {
            $scope.KitCompModal.saveUnitModelBlur = 1;
            $scope.KitCompModal.FilterSearchUnitModel = model.UnitModelName;
            $scope.KitCompModal.UnitModelSelected = model;
            $scope.KitCompModal.ownedUnitRec.Model = $scope.KitCompModal.UnitModelSelected.Id;
            $scope.KitCompModal.UnitSubModel = [];
            $scope.KitCompModal.UnitSubModelSelected = {};
            $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
            $scope.KitCompModal.ownedUnitRec.SubModelName = null;
            $scope.KitCompModal.FilterSearchUnitSubModel = '';
            $scope.KitCompModal.UnitSubModelNameStr = ''; 
            $scope.KitCompModal.filteredItemsUnitSubModel = ''; 
            $scope.KitCompModal.saveUnitModelBlur = 0;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }
        // Sub Model Select Enter
        $scope.KitCompModal.ChangeSeletedUnitSubModel = function(event) {
            if (event.which === 40) {
                $scope.KitCompModal.CurrentIndexUnitSubModel++;
            } else if (event.which === 38) {
                if ($scope.KitCompModal.CurrentIndexUnitSubModel >= 1) {
                    $scope.KitCompModal.CurrentIndexUnitSubModel--;
                }
            } else if (event.which === 13) {
                $scope.KitCompModal.changeUnitSubmodel($scope.KitCompModal.filteredItemsUnitSubModel[$scope.KitCompModal.CurrentIndexUnitSubModel], event);
                $scope.KitCompModal.CurrentIndexUnitSubModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) { 
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.KitCompModal.filteredItemsUnitSubModel == undefined || $scope.KitCompModal.filteredItemsUnitSubModel.length == 0 || $scope.KitCompModal.FilterSearchUnitSubModel == undefined) {
                    $scope.KitCompModal.CurrentIndexUnitSubModel = -1
                    return;
                }
                if (angular.lowercase($scope.KitCompModal.filteredItemsUnitSubModel[0].SubModelName).trim() == angular.lowercase($scope.KitCompModal.FilterSearchUnitSubModel).trim()) {
                    $scope.KitCompModal.CurrentIndexUnitSubModel = 0;
                } else {
                    $scope.KitCompModal.CurrentIndexUnitSubModel = -1;
                }
            }
        }
        $scope.KitCompModal.getUnitSubModelList = function(event) {
            if ($scope.KitCompModal.FilterSearchMake == null || $scope.KitCompModal.FilterSearchMake == '' || $scope.KitCompModal.UnitMakeSelected.Id == undefined) { 
                return;
            }
            if ($scope.KitCompModal.FilterSearchUnitModel == null || $scope.KitCompModal.FilterSearchUnitModel == '' || $scope.KitCompModal.UnitModelSelected.Id == undefined || $scope.KitCompModal.UnitModelSelected.Id == '') { 
                return;
            }
            angular.element('.controls').hide();
            angular.element('#KitUnitMainSubModelId').show();
            VINOperationsService.getUnitSubModelList($scope.KitCompModal.UnitModelSelected.Id, $scope.KitCompModal.UnitMakeSelected.Id).then(function(sucessResultList) {
                $scope.KitCompModal.UnitSubModel = sucessResultList;
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
        $scope.KitCompModal.saveUnitSubModel = function(event) {
            if ($scope.KitCompModal.saveUnitSubModelBlur == 0 || $scope.KitCompModal.saveUnitSubModelBlur == undefined) {
                if ($scope.KitCompModal.ownedUnitRec.SubModelName != $scope.KitCompModal.FilterSearchUnitSubModel) { 
                    $scope.KitCompModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isSubModelAlreadyExist = false;
                for (var i = 0; i < $scope.KitCompModal.UnitSubModel.length; i++) {
                    if ($scope.KitCompModal.UnitSubModel[i].SubModelName == $scope.KitCompModal.FilterSearchUnitSubModel) {
                        $scope.KitCompModal.ownedUnitRec.SubModel = $scope.KitCompModal.UnitSubModel[i].Id;
                        $scope.KitCompModal.ownedUnitRec.SubModelName = $scope.KitCompModal.UnitSubModel[i].SubModelName;
                        isSubModelAlreadyExist = true;
                    }
                }
                if (!isSubModelAlreadyExist) {
                    $scope.KitCompModal.UnitSubModelSelected.SubModelName = $scope.KitCompModal.FilterSearchUnitSubModel;
                    $scope.KitCompModal.UnitSubModelSelected.Id = null;
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.KitCompModal.saveUnitSubModelBlur = 0;
            }
        }
        $scope.KitCompModal.changeUnitSubmodel = function(model, event) {
            $scope.KitCompModal.saveUnitSubModelBlur = 1;
            $scope.KitCompModal.FilterSearchUnitSubModel = model.SubModelName;
            $scope.KitCompModal.UnitSubModelSelected = model;
            $scope.KitCompModal.ownedUnitRec.SubModel = $scope.KitCompModal.UnitSubModelSelected.Id;
            $scope.KitCompModal.ownedUnitRec.SubModelName = $scope.KitCompModal.UnitSubModelSelected.SubModelName;
            $scope.KitCompModal.saveUnitSubModelBlur = 0;
            $scope.KitCompModal.ownedUnitRec.MakeModelDescription = $scope.KitCompModal.UnitSubModelSelected.SubmodelDescription; 
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }
        $scope.KitCompModal.openKitPopup();
    }])
});