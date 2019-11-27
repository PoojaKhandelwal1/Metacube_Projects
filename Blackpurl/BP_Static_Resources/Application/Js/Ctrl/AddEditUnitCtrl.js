define(['Routing_AppJs_PK', 'AddEditUnitServices', 'JqueryUI', 'CustomMakeSort', 'underscore_min', 'dirNumberInput',  'moment', 'momentTimezone', 'InfoCardComponent'], function (Routing_AppJs_PK, AddEditUnitServices, JqueryUI, CustomMakeSort, underscore_min, dirNumberInput, moment, momentTimezone, InfoCardComponent) {

    var injector = angular.injector(['ui-notification', 'ng']);
    
    $(document).ready(function () {
        $(".form-control").focus(function () {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });
        
        $('#addmoreinfoBtnId').click(function () {
            if ($(this).hasClass('keep_open')) {} else {
                $('.dropdown-menu').addClass("keep_open");
            }
        });
        
        $('#closemodal').click(function () {
            $('#pop').modal('hide');
        });
        
        $(document).on('click', '.dropdown-menu', function (e) {
            $(this).hasClass('keep_open') && e.stopPropagation();
        });
        
        setTimeout(function () {
            $('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 1000);
        
        $(".datepicker").datepicker();
        
        $('.btn').click(function () {
            $($(this).parent().find("input")).focus();
        });
        
        $("#dateOut").datepicker({
            maxDate: new Date()
        });
        
        $('.number').keypress(function (event) {
            var $this = $(this);
            if ((event.which != 46 || $this.val().indexOf('.') != -1) &&
                ((event.which < 48 || event.which > 57) &&
                    (event.which != 0 && event.which != 8))) {
                event.preventDefault();
            }

            var text = $(this).val();
            if ((event.which == 46) && (text.indexOf('.') == -1)) {
                setTimeout(function () {
                    if ($this.val().substring($this.val().indexOf('.')).length > 3) {
                        $this.val($this.val().substring(0, $this.val().indexOf('.') + 3));
                    }
                }, 1);
            }

            if ((text.indexOf('.') != -1) &&
                (text.substring(text.indexOf('.')).length > 2) &&
                (event.which != 0 && event.which != 8) &&
                ($(this)[0].selectionStart >= text.length - 2)) {
                event.preventDefault();
            }
        });

        $('.textfielduserinput').bind('keypress', function (event) {
            var regex = new RegExp("^[a-zA-Z0-9 \-]+$");
            var key = String.fromCharCode(!event.charCode ? event.which : event.charCode);
            if (!regex.test(key)) {
                event.preventDefault();
                return false;
            }
        });

        $(".numberOnly").keypress(function (e) {
            if (e.which != 8 && e.which != 0 && (e.which < 48 || e.which > 57)) {
                return false;
            }
        });
    });

    Routing_AppJs_PK.controller('AddEditUnitCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'CustomerOwnedUnitService', 'VINOperationsService','$translate', function ($scope, $timeout, $q, $rootScope, $state, $stateParams, CustomerOwnedUnitService, VINOperationsService,$translate) {
        var Notification = injector.get("Notification");

        if ($scope.COUModal == undefined) {
            $scope.COUModal = {};
        }

        $scope.COUModal.CustomerMasterData = {};
        var Currentyear = parseInt(new Date().getFullYear());

        $scope.COUModal.ownedUnitRec = {};
        $scope.COUModal.ownedUnitRec.IsTaxable = false;
        $scope.COUModal.ownedUnitRec.IsActive = true;
        $scope.COUModal.currentCOUId = null;
        $scope.ViewCustomer = '';
        $scope.COUModal.Years = [];
        $scope.COUModal.UnitYearSelected = {};
        $scope.COUModal.YearOf1stRego = {};
        $scope.COUModal.UnitMake = [];
        $scope.COUModal.UnitMakeSelected = {};
        $scope.COUModal.UnitModel = [];
        $scope.COUModal.UnitModelSelected = {};
        $scope.COUModal.UnitSubModel = [];
        $scope.COUModal.UnitSubModelSelected = {};
        $scope.COUModal.DateFormat = $Global.DateFormat;
        $scope.COUModal.SchedulingDateFormat = $Global.SchedulingDateFormat;
        $scope.COUModal.CurrentUserTZSIDKey = $Global.CurrentUserTZSIDKey;
        $scope.COUModal.SimilarCOU = {};
        $scope.COUModal.isSimilarUnitRec = false;
        $scope.COUModal.CurrentIndexMake = -1;
        $scope.COUModal.CurrentIndexUnitModel = -1;
        $scope.COUModal.CurrentIndexUnitSubModel = -1;
        $scope.COUModal.currentSelectedTagIndex = -1;
        $scope.COUModal.saveUnitModelblur = 0
        $scope.COUModal.saveUnitMakeBlur = 0;
        $scope.COUModal.saveUnitSubModelBlur = 0;
        $scope.COUModal.FilterSearchMake = '';
        $scope.COUModal.FilterSearchUnitModel = '';
        $scope.COUModal.FilterSearchUnitSubModel = '';
        $scope.COUModal.disableSaveButton = false;
        $scope.COUModal.COUFormValidationModal = {};
        var tempMakelist = [];
        var tempModelList = [];
        var tempSubModelList = [];

        // Load modals values which needs be loaded only once while page lifetime
        for (i = Currentyear +1; i > (Currentyear - 100 + 2); i--) {
            var year = {
                year: i
            };
            $scope.COUModal.Years.push(year);
        }

        $scope.COUModal.showCalendar = function (IdVal) {
            angular.element("#" + IdVal).focus();
        }
        
        /**
         * Method to set default values for validation model
         */
        $scope.COUModal.setDefaultValidationModel = function () {
            $scope.COUModal.COUFormValidationModal = {
                Mileage: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Numeric'
                },
                MakeName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                ModelName: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Cylinders: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Numeric'
                },
                Displacement: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Numeric'
                },
                Gear: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Numeric'
                }
            };

            if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                var vin = {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
                $scope.COUModal.COUFormValidationModal.VIN = vin;
                var TotalBaseCost = {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required, Numeric'
                }
                $scope.COUModal.COUFormValidationModal.TotalBaseCost = TotalBaseCost;
                if ($scope.COUModal.currentCOUId != undefined && $scope.COUModal.currentCOUId != null && $scope.COUModal.currentCOUId != '') {
                    var dateIn = {
                        isError: false,
                        ErrorMessage: '',
                        Type: 'Required'
                    }
                    $scope.COUModal.COUFormValidationModal.DateIn = dateIn;
                }
            }
        }
        $scope.COUModal.CategoryFieldsFilter = {
            UnitCategory: [{
                Field: "Type__c",
                Value: "Unit",
                FilterObject: "Category__c"
            }]
        };
        $scope.$on('autoCompleteSelectCallback', function (event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;

            if (searchResult != null && searchResult.originalObject.Info == 'Unit') {
                $scope.COUModal.UnitMakeSelected = {};
                $scope.COUModal.UnitMakeSelected = {
                    Id: searchResult.originalObject.Value,
                    UnitMakeName: searchResult.originalObject.Name
                }
                $scope.COUModal.changeUnitMake();
                return;
            } else if (searchResult != null && searchResult.originalObject.Info == 'UnitModel') {
                $scope.COUModal.UnitModelSelected = {};
                $scope.COUModal.UnitModelSelected = {
                    Id: searchResult.originalObject.Value,
                    UnitModelName: searchResult.originalObject.Name
                }
                $scope.COUModal.changeUnitmodel();
                return;
            } else if (searchResult != null && searchResult.originalObject.Info) {
                if (searchResult.originalObject.Info.indexOf("Unit_Model__c") != -1) {
                    $scope.COUModal.UnitSubModelSelected = {};
                    $scope.COUModal.UnitSubModelSelected = {
                        Id: searchResult.originalObject.Value,
                        SubModelName: searchResult.originalObject.Name
                    }
                    $scope.COUModal.ownedUnitRec.Model = $scope.COUModal.UnitSubModelSelected.Id;
                    $scope.COUModal.ownedUnitRec.SubModelName = $scope.COUModal.UnitSubModelSelected.SubModelName
                    $scope.COUModal.ownedUnitRec.SubModel = $scope.COUModal.UnitSubModelSelected.Id
                    return;
                }
            }

            if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNIT') {

                if (($scope.COUModal.UnitMakeSelected != null && $scope.COUModal.UnitMakeNameStr != $scope.COUModal.UnitMakeSelected.UnitMakeName) ||
                    $scope.COUModal.UnitMakeNameStr == null ||
                    $scope.COUModal.UnitMakeNameStr == "" ||
                    $scope.COUModal.UnitMakeSelected == null) {
                    $scope.COUModal.UnitMakeSelected = null;
                    $scope.COUModal.UnitModelSelected = null;
                    $scope.COUModal.UnitSubModelSelected = null;
                    $scope.COUModal.UnitMakeNameStr = "";
                    $scope.COUModal.UnitSubModelNameStr = "";
                    $scope.COUModal.UnitModelNameStr = "";
                }
                return;
            } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITMODEL') {
                if (($scope.COUModal.UnitModelSelected != null && $scope.COUModal.UnitModelNameStr != $scope.COUModal.UnitModelSelected.UnitModelName) ||
                    $scope.COUModal.UnitModelNameStr == null ||
                    $scope.COUModal.UnitModelNameStr == "" ||
                    $scope.COUModal.UnitModelSelected == null) {
                    $scope.COUModal.UnitModelSelected = null;
                    $scope.COUModal.UnitSubModelSelected = null;
                    $scope.COUModal.UnitSubModelNameStr = "";
                    $scope.COUModal.UnitModelNameStr = "";
                }
                return;
            } else if ((searchResult == null || searchResult.originalObject.Value == null) && obejctType == 'UNITSUBMODEL') {
                if (($scope.COUModal.UnitSubModelSelected != null && $scope.COUModal.UnitSubModelNameStr != $scope.COUModal.UnitSubModelSelected.SubModelName) ||
                    $scope.COUModal.UnitSubModelNameStr == null ||
                    $scope.COUModal.UnitSubModelNameStr == "" ||
                    $scope.COUModal.UnitSubModelSelected == null) {
                    $scope.COUModal.UnitSubModelSelected = null;
                    $scope.COUModal.UnitSubModelNameStr = "";
                }
                return;
            }

            if ($scope.COUModal.CategoryNameStr == $scope.COUModal.ownedUnitRec.CategoryName) {
                return;
            } else if (searchResult == null) {
                Notification.error($translate.instant('No_matching_object_type_found',{ObejctType: args.ObejctType}));
                $scope.COUModal.CategoryNameStr = "";
                $scope.COUModal.ownedUnitRec.CategoryName = "";
                $scope.COUModal.ownedUnitRec.CategoryId = null;
                return;
            }
            
            var objectsMapping = [{
                CATEGORY: {
                    Id: "CategoryId",
                    Name: "CategoryName",
                    selectMethod: $scope.COUModal.setCategoryRecordDataByForm
                }
            }];

            if (objectsMapping[0][obejctType] != null) {
                $scope.COUModal.ownedUnitRec[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.COUModal.ownedUnitRec[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
            }

            if ($scope.COUModal.COUFormValidationModal[validationKey] == null || $scope.COUModal.COUFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });

        $scope.COUModal.setCategoryRecordDataByForm = function (searchResult) {
            $scope.COUModal.ownedUnitRec.Category = searchResult.originalObject.Value;
            $scope.COUModal.ownedUnitRec.CategoryName = searchResult.originalObject.Name;
        }

        /**
         * Event listener to open and set data in Add Customer Owned Unit popup
         */
        $scope.$on('AddCustomerOwnedUnitEvent', function (event, custId) {
            $scope.COUModal.customerId = custId.customerId;
            $scope.COUModal.currentCOUId = null;
            $scope.COUModal.UnitType = custId.unitType;
            $scope.COUModal.addNewCOUModal();
        });

        $scope.COUModal.showToolTip = function () {
            angular.element('.tooltip').hide();
            $timeout(function () {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 100);
        }

        $scope.COUModal.addNewCOUModal = function () {
            $scope.COUModal.clearAllData();
            $scope.COUModal.disableSaveButton = false;
            $scope.COUModal.getActiveTagList();
            $scope.COUModal.openPopup();
            $scope.COUModal.ownedUnitRec.AssignedTags = [];
            
        }
         function getMakeModelSubmodelList() {
            VINOperationsService.getMakeModelSubmodelList().then(function(response) {
                $scope.COUModal.UnitMake = response.MakeList;
                $scope.COUModal.UnitModel = response.ModelList;
                $scope.COUModal.UnitSubModel = response.SubModelList;
                tempMakelist = angular.copy(response.MakeList);
                tempModelList = angular.copy(response.ModelList);
                tempSubModelList = angular.copy(response.SubModelList);
                console.log(response);
                console.log("response");
            }).catch(function(error) {
              handleErrorAndExecption(error);
            });
        }



        $scope.COUModal.changeApplicableTax = function () {
            var selectedTaxIndex = _.findIndex($scope.COUModal.ApplicableTaxList, {
                Id: $scope.COUModal.ownedUnitRec.ApplicableTax
            });
            if (selectedTaxIndex > -1) {
                $scope.COUModal.Tax_Rate = $scope.COUModal.ApplicableTaxList[selectedTaxIndex].TaxRate;
            }
        }

        $scope.COUModal.onKeyUpTaxable = function (event) {
            if (event.keyCode == 13) {
                $scope.COUModal.onSelectTaxable();
            }
        }

        $scope.COUModal.onSelectTaxable = function () {
            if ($scope.COUModal.ownedUnitRec.Id != null && $scope.COUModal.ownedUnitRec.UnitType == 'STOCK' && !$rootScope.GroupOnlyPermissions['Sales Taxes']['assign']) {
                return;
            }
            $scope.COUModal.ownedUnitRec.IsTaxable = !$scope.COUModal.ownedUnitRec.IsTaxable;
            if ($scope.COUModal.ownedUnitRec.IsTaxable == true) {
                angular.element("#customerUnitMainTaxableId").show();
            } else {
                angular.element("#customerUnitMainTaxableId").hide();
            }
        }
        
        $scope.COUModal.onChangeActive = function () {
            if ($scope.COUModal.ownedUnitRec.IsActive) {
                angular.element("#customerUnitMainActiveId").show();
            } else {
                angular.element("#customerUnitMainActiveId").hide();
            }
        }

        /**
         * Event listener to open and set data in EDIT Customer Owned Unit popup
         */
        $scope.$on('EditCustomerOwnedUnitEvent', function (event, args) {
            $scope.COUModal.customerId = args.customerId;
            $scope.COUModal.MileageList = [{
                    Value: 'Km'
                },
                {
                    Value: 'Mi'
                },
                {
                    Value: 'Hrs'
                }
            ];
            $scope.COUModal.SimilarCOU.length = 0;
            $scope.COUModal.getActiveTagList();
            $scope.COUModal.editCOU(args.couId);
        });

        $scope.COUModal.AddCustomerOwnedUnitEvent = function () {
            $scope.COUModal.customerId = $stateParams.AddEditUnitParams.customerId;
            $scope.COUModal.UnitType = $stateParams.AddEditUnitParams.unitType;
            $scope.COUModal.addNewCOUModal();
        }

        $scope.COUModal.EditCustomerOwnedUnitEvent = function (args) {
            $scope.COUModal.customerId = args.customerId;
            $scope.COUModal.MileageList = [{
                    Value: 'Km'
                },
                {
                    Value: 'Mi'
                },
                {
                    Value: 'Hrs'
                }
            ];
            $scope.COUModal.SimilarCOU.length = 0;
            $scope.COUModal.editCOU(args.couId);
            $scope.COUModal.getActiveTagList();
        }

        $scope.COUModal.getApplicabletaxList = function () {
            if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK' || $scope.COUModal.ownedUnitRec.UnitType == 'ORDU') {
                VINOperationsService.getApplicableTaxList().then(function (taxList) {
                    $scope.COUModal.IsTaxIncludingPricing = taxList.IsTaxIncludingPricing;
                    $scope.COUModal.ApplicableTaxList = taxList.SalesTaxList;
                    var defaultTaxIndex = _.findIndex(taxList.SalesTaxList, {
                        IsDefault: true
                    });
                    if (defaultTaxIndex > -1) {
                        if ($scope.COUModal.ownedUnitRec.ApplicableTax == null) {
                            $scope.COUModal.ownedUnitRec.ApplicableTax = $scope.COUModal.ApplicableTaxList[defaultTaxIndex].Id;
                            $scope.COUModal.Tax_Rate = $scope.COUModal.ApplicableTaxList[defaultTaxIndex].TaxRate;
                        }
                    }
                }, function (errorSearchResult) {});
            }
        }
        $scope.COUModal.getDefaultUnitCategory = function () {
            VINOperationsService.getDefaultUnitCategory().then(function (defaultUnitCategory) {
                if (defaultUnitCategory.Id != null && defaultUnitCategory.Id != "") {
                    $scope.COUModal.CategoryNameStr = defaultUnitCategory.CategoryName;
                    if ($scope.COUModal.AdditionalFieldsInfo['Category'].isPrimary) {
                        $scope.COUModal.ownedUnitRec.CategoryId = defaultUnitCategory.Id;
                        $scope.COUModal.ownedUnitRec.Category = defaultUnitCategory.Id; 
                        $scope.COUModal.ownedUnitRec.CategoryName = defaultUnitCategory.CategoryName;
                    }
                } else {
                    $scope.COUModal.ownedUnitRec.Category = '';
                    $scope.COUModal.ownedUnitRec.CategoryId = null;
                    $scope.COUModal.CategoryNameStr = "";
                    $scope.COUModal.ownedUnitRec.CategoryName = "";
                }

            }, function (errorSearchResult) {});
        }
        
        /**
         * Set popup data and Open popup for EDIT purpose
         */
        $scope.COUModal.editCOU = function (couId) {
            $scope.COUModal.disableSaveButton = false;
            $scope.COUModal.currentCOUId = couId;
            $scope.COUModal.getCurrentCOUData($scope.COUModal.currentCOUId);
        }

        $scope.COUModal.openPopup = function () {
            setTimeout(function () {
                angular.element('#AddNewCOU').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }

        /**
         * Clear and Set Default Values and validations for popup
         */
        $scope.COUModal.clearAllData = function () {
            $scope.COUModal.UnitMake = [];
            $scope.COUModal.UnitModel = [];
            $scope.COUModal.UnitSubModel = [];
            $scope.COUModal.UnitYearSelected = {};
            $scope.COUModal.YearOf1stRego = {};
            $scope.COUModal.UnitMakeSelected = {};
            $scope.COUModal.UnitModelSelected = {};
            $scope.COUModal.UnitSubModelSelected = {};
            $scope.COUModal.CategoryNameStr = "";
            $scope.COUModal.UnitMakeNameStr = "";
            $scope.COUModal.UnitSubModelNameStr = "";
            $scope.COUModal.UnitModelNameStr = "";
            $scope.COUModal.ownedUnitRec = {};
            $scope.COUModal.FilterSearchMake = '';
            $scope.COUModal.FilterSearchUnitModel = '';
            $scope.COUModal.FilterSearchUnitSubModel = '';
            $scope.COUModal.ownedUnitRec.CategoryId = null;
            $scope.COUModal.ownedUnitRec.CategoryName = "";
            $scope.COUModal.ownedUnitRec.IsTaxable = false;

            if ($scope.COUModal.UnitType != undefined) {
                $scope.COUModal.ownedUnitRec.UnitType = $scope.COUModal.UnitType;
            }
            $scope.COUModal.getApplicabletaxList();
            $scope.COUModal.getDefaultUnitCategory();
            $scope.COUModal.setDefaultValidationModel();
            $scope.COUModal.SimilarCOU.length = 0;
            $scope.COUModal.loadAdditionalFields();
            $scope.COUModal.loadManageJsonData();
            if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                $scope.COUModal.ownedUnitRec.IsTaxable = true;
                $scope.COUModal.AdditionalFieldsInfo['IsTaxable'].isPrimary = true;
            }
            
            if($scope.COUModal.currentCOUId && ($scope.COUModal.ownedUnitRec.UnitType != 'ORDU')) {
            	$scope.COUModal.ownedUnitRec.IsActive = true;
                $scope.COUModal.AdditionalFieldsInfo['IsActive'].isPrimary = true;
            }

            $scope.COUModal.MileageList = [{
                    Value: 'Km'
                },
                {
                    Value: 'Mi'
                },
                {
                    Value: 'Hrs'
                }
            ];
            $scope.COUModal.ownedUnitRec.MileageType = $scope.COUModal.MileageList[0].Value;
            $scope.COUModal.UnitMake = tempMakelist;
            $scope.COUModal.UnitModel = tempModelList;
            $scope.COUModal.UnitSubModel = tempSubModelList;
        }

        $scope.COUModal.loadAdditionalFields = function () {
            if ($scope.COUModal.ownedUnitRec.UnitType == 'COU' || $scope.COUModal.ownedUnitRec.UnitType == undefined) {
                $scope.COUModal.AdditionalFieldsInfo = {
                    InteriorColour: {
                        isPrimary: false,
                        label: 'Interior Colour',
                        fieldId: 'InteriorColourId'
                    },
                    KeyNo: {
                        isPrimary: false,
                        label: 'Key #',
                        fieldId: 'KeyNoId'
                    },
                    EngineSerialNo: {
                        isPrimary: false,
                        label: 'Engine Serial #',
                        fieldId: 'EnginSerialId'
                    },
                    OtherSerialNo: {
                        isPrimary: false,
                        label: 'Other Serial #',
                        fieldId: 'OtherSerialID'
                    },
                    Cylinders: {
                        isPrimary: false,
                        label: 'Cylinders',
                        fieldId: 'CylindersId'
                    },
                    Displacement: {
                        isPrimary: false,
                        label: 'Displacement',
                        fieldId: 'DisplacementId'
                    },
                    IsAutomatic: {
                        isPrimary: false,
                        label: 'Automatic/Gears',
                        fieldId: 'AutomaticId'
                    },
                    ComplianceDate: {
                        isPrimary: false,
                        label: 'Compliance Date',
                        fieldId: 'ComplianceDateId'
                    },
                    YearOf1stRego: {
                        isPrimary: false,
                        label: 'Year of 1st Rego',
                        fieldId: 'YearOf1stRegoId'
                    },
                    RegistrationSerial: {
                        isPrimary: false,
                        label: 'Registration Serial#',
                        fieldId: 'RegistrationSerialId'
                    },
                    ManufacturedDate: {
                        isPrimary: false,
                        label: 'Manufactured Date',
                        fieldId: 'ManufacturedDateId'
                    }
                }
            } else if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                $scope.COUModal.AdditionalFieldsInfo = {
                    Plate: {
                        isPrimary: false,
                        label: 'Plate/Reg#',
                        fieldId: 'PlatId'
                    },
                    RegExpiryDate: {
                        isPrimary: false,
                        label: 'Reg Expiry Date',
                        fieldId: 'customerUnitRegExpiryDateOption'
                    },
                    Mileage: {
                        isPrimary: false,
                        label: 'Mileage',
                        fieldId: 'MileageId'
                    },
                    InteriorColour: {
                        isPrimary: false,
                        label: 'Interior Colour',
                        fieldId: 'InteriorColourId'
                    },
                    KeyNo: {
                        isPrimary: false,
                        label: 'Key #',
                        fieldId: 'KeyNoId'
                    },
                    EngineSerialNo: {
                        isPrimary: false,
                        label: 'Engine Serial #',
                        fieldId: 'EnginSerialId'
                    },
                    OtherSerialNo: {
                        isPrimary: false,
                        label: 'Other Serial #',
                        fieldId: 'OtherSerialID'
                    },
                    Cylinders: {
                        isPrimary: false,
                        label: 'Cylinders',
                        fieldId: 'CylindersId'
                    },
                    Displacement: {
                        isPrimary: false,
                        label: 'Displacement',
                        fieldId: 'DisplacementId'
                    },
                    IsAutomatic: {
                        isPrimary: false,
                        label: 'Automatic/Gears',
                        fieldId: 'AutomaticId'
                    },
                    Category: {
                        isPrimary: false,
                        label: 'Category',
                        fieldId: 'CategoryId'
                    },
                    Location: {
                        isPrimary: false,
                        label: 'Location',
                        fieldId: 'LocationId'
                    },
                    IsTaxable: {
                        isPrimary: false,
                        label: 'Taxable',
                        fieldId: 'TaxableId'
                    },
                    ManufacturedDate: {
                        isPrimary: false,
                        label: 'Manufactured Date',
                        fieldId: 'ManufacturedDateId'
                    },
                    ComplianceDate: {
                        isPrimary: false,
                        label: 'Compliance Date',
                        fieldId: 'ComplianceDateId'
                    },
                    YearOf1stRego: {
                        isPrimary: false,
                        label: 'Year of 1st Rego',
                        fieldId: 'YearOf1stRegoId'
                    },
                    RegistrationSerial: {
                        isPrimary: false,
                        label: 'Registration Serial#',
                        fieldId: 'RegistrationSerialId'
                    }
                }
                if (!$scope.COUModal.IsCreateMode) {
                    var isTaxable = {
                        isPrimary: false,
                        label: 'Taxable',
                        fieldId: 'TaxableId'
                    };
                    $scope.COUModal.AdditionalFieldsInfo.IsTaxable = isTaxable;
                }
                if ($scope.COUModal.currentCOUId != undefined && $scope.COUModal.currentCOUId != null && $scope.COUModal.currentCOUId != '') {
                    var dateIn = {
                        isPrimary: true,
                        label: 'Date Stocked In',
                        fieldId: 'DateInId'
                    };
                    $scope.COUModal.AdditionalFieldsInfo.DateIn = dateIn;

                    if ($scope.COUModal.ownedUnitRec.DateOut != undefined && $scope.COUModal.ownedUnitRec.DateOut != null && $scope.COUModal.ownedUnitRec.DateOut != '') {
                        var dateOut = {
                            isPrimary: true,
                            label: 'Date Stocked Out',
                            fieldId: 'DateOutId'
                        };
                        $scope.COUModal.AdditionalFieldsInfo.DateOut = dateOut;
                    }
                }
            } else if ($scope.COUModal.ownedUnitRec.UnitType == 'ORDU') {
                $scope.COUModal.AdditionalFieldsInfo = {
                    InteriorColour: {
                        isPrimary: false,
                        label: 'Interior Colour',
                        fieldId: 'InteriorColourId'
                    },
                    KeyNo: {
                        isPrimary: false,
                        label: 'Key #',
                        fieldId: 'KeyNoId'
                    },
                    EngineSerialNo: {
                        isPrimary: false,
                        label: 'Engine Serial #',
                        fieldId: 'EngineSerialId'
                    },
                    OtherSerialNo: {
                        isPrimary: false,
                        label: 'Other Serial #',
                        fieldId: 'OtherSerialID'
                    },
                    Cylinders: {
                        isPrimary: false,
                        label: 'Cylinders',
                        fieldId: 'CylindersId'
                    },
                    Displacement: {
                        isPrimary: false,
                        label: 'Displacement',
                        fieldId: 'DisplacementId'
                    },
                    IsAutomatic: {
                        isPrimary: false,
                        label: 'Automatic/Gears',
                        fieldId: 'AutomaticId'
                    },
                    Category: {
                        isPrimary: false,
                        label: 'Category',
                        fieldId: 'CategoryId'
                    },
                    IsTaxable: {
                        isPrimary: false,
                        label: 'Taxable',
                        fieldId: 'TaxableId'
                    },
                    ManufacturedDate: {
                        isPrimary: false,
                        label: 'Manufactured Date',
                        fieldId: 'ManufacturedDateId'
                    },
                    ComplianceDate: {
                        isPrimary: false,
                        label: 'Compliance Date',
                        fieldId: 'ComplianceDateId'
                    },
                    YearOf1stRego: {
                        isPrimary: false,
                        label: 'Year of 1st Rego',
                        fieldId: 'YearOf1stRegoId'
                    },
                    RegistrationSerial: {
                        isPrimary: false,
                        label: 'Registration Serial#',
                        fieldId: 'RegistrationSerialId'
                    }
                }
            }
            
            if($scope.COUModal.currentCOUId && ($scope.COUModal.ownedUnitRec.UnitType != 'ORDU')) {
            	$scope.COUModal.AdditionalFieldsInfo.IsActive = {
            		isPrimary: true,
                    label: 'Active',
                    fieldId: 'activeFlagId'	
                }
            }
        }

        $scope.COUModal.setDisplayAdditionalFields = function () {
            var additionalUnitField = $scope.COUModal.AdditionalFieldsInfo;
            for (var key in additionalUnitField) {

                if (additionalUnitField.hasOwnProperty(key)) {
                    if (($scope.COUModal.ownedUnitRec[key] != null && $scope.COUModal.ownedUnitRec[key] != undefined && typeof ($scope.COUModal.ownedUnitRec[key]) != 'boolean') ||
                        ($scope.COUModal.ownedUnitRec[key] == true && typeof ($scope.COUModal.ownedUnitRec[key]) == 'boolean')) {
                        additionalUnitField[key].isPrimary = true;
                    }
                }
            }
        }

        /**
         * Set form Values from record and validations for popup
         */
        $scope.COUModal.setRecordData = function () {
            $scope.COUModal.UnitYearSelected = {
                year: $scope.COUModal.ownedUnitRec.Year
            };
            $scope.COUModal.YearOf1stRego = {
                year: parseInt($scope.COUModal.ownedUnitRec.YearOf1stRego)
            };
            $scope.COUModal.UnitMakeSelected = {
                Id: $scope.COUModal.ownedUnitRec.Make,
                UnitMakeName: $scope.COUModal.ownedUnitRec.MakeName
            };
            $scope.COUModal.UnitModelSelected = {
                Id: $scope.COUModal.ownedUnitRec.Model,
                SubModelName: $scope.COUModal.ownedUnitRec.SubModelName,
                UnitModelName: $scope.COUModal.ownedUnitRec.ModelName
            };
            $scope.COUModal.CategoryNameStr = $scope.COUModal.ownedUnitRec.CategoryName;
            $scope.COUModal.UnitMakeNameStr = $scope.COUModal.ownedUnitRec.MakeName;
            $scope.COUModal.UnitModelNameStr = $scope.COUModal.ownedUnitRec.ModelName;
            $scope.COUModal.UnitSubModelNameStr = $scope.COUModal.ownedUnitRec.SubModelName;
            $scope.COUModal.loadAdditionalFields();
            $scope.COUModal.setDisplayAdditionalFields();
            $scope.COUModal.UnitSubModelSelected = {
                Id: $scope.COUModal.ownedUnitRec.SubModel,
                SubModelName: $scope.COUModal.ownedUnitRec.SubModelName,
            };
            $scope.COUModal.FilterSearchMake = $scope.COUModal.ownedUnitRec.MakeName;
            $scope.COUModal.FilterSearchUnitModel = $scope.COUModal.ownedUnitRec.ModelName;
            $scope.COUModal.FilterSearchUnitSubModel = $scope.COUModal.ownedUnitRec.SubModelName;
            $scope.COUModal.MileageList = [{
                    Value: 'Km'
                },
                {
                    Value: 'Mi'
                },
                {
                    Value: 'Hrs'
                }
            ];
        }

        /**
         * Get COU related data from server and fill form
         */
        $scope.COUModal.getCurrentCOUData = function () {
            CustomerOwnedUnitService.getCOUInfoById($scope.COUModal.currentCOUId).then(function (couRecord) {
                $scope.UpdateFormFieldsWithExistingCOU(couRecord);
                $scope.COUModal.getApplicabletaxList();
                $scope.COUModal.setDefaultValidationModel();
            }, function (errorSearchResult) {});
        }

        $scope.COUModal.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }

        $scope.COUModal.onFocusOnTagInput = function () {
            $scope.COUModal.isFocused = true;
            if (!$scope.COUModal.isAlreadyFocusedOnTagInput) {
                $scope.COUModal.isAlreadyFocusedOnTagInput = true;
                $scope.COUModal.resetTagList();
            }
        }

        $scope.COUModal.resetTagList = function () {
            for (var i = 0; i < $scope.COUModal.ownedUnitRec.AssignedTags.length; i++) {
                var index = _.findIndex($scope.COUModal.ActiveTagList, {
                    Name: $scope.COUModal.ownedUnitRec.AssignedTags[i]
                });
                if (index > -1) {
                    $scope.COUModal.ActiveTagList.splice(index, 1);
                }
            }
        }

        $scope.COUModal.selectTag = function (tagObj) {
            var index = _.findIndex($scope.COUModal.ActiveTagList, {
                Name: tagObj.Name
            });
            if (index > -1) {
                if ($scope.COUModal.ownedUnitRec.AssignedTags.length < 20) {
                    $scope.COUModal.ownedUnitRec.AssignedTags.push(tagObj.Name);
                    $scope.COUModal.ActiveTagList.splice(index, 1);
                } else {
                    Notification.error($translate.instant('Part_tag_limit_error'));
                }
            }
            $scope.COUModal.TagNameStr = '';
        };

        $scope.COUModal.removeTag = function (tagObj, index) {
            if (index > -1) {
                $scope.COUModal.ownedUnitRec.AssignedTags.splice(index, 1);
                $scope.COUModal.ActiveTagList.push({
                    Name: tagObj,
                    Id: tagObj
                });
            }
        };

        $scope.COUModal.getActiveTagList = function () {
            VINOperationsService.getActiveTagList().then(function (tagList) {
                $scope.COUModal.ActiveTagList = tagList;
            }, function (errorSearchResult) {

            });
        }

        /**
         * Set all the form fields with existing COU record
         */
        $scope.UpdateFormFieldsWithExistingCOU = function (couRecord) {
            $scope.COUModal.ownedUnitRec = couRecord[0];
            if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                if ($scope.COUModal.ownedUnitRec.TotalBasePrice != null) {
                    $scope.COUModal.ownedUnitRec.TotalBasePrice = ($scope.COUModal.ownedUnitRec.TotalBasePrice).toFixed(2);
                }
                if ($scope.COUModal.ownedUnitRec.TotalBaseCost != null) {
                    $scope.COUModal.ownedUnitRec.TotalBaseCost = ($scope.COUModal.ownedUnitRec.TotalBaseCost).toFixed(2);
                }
            }
            $scope.COUModal.setRecordData();
            $scope.COUModal.openPopup();
            $scope.COUModal.showToolTip();
            $scope.COUModal.maxDateCalculation();
        }

        /**
         * Method to set selected year modal value in Owned unit Year field value
         */
        $scope.COUModal.changeYear = function () {
            if (typeof $scope.COUModal.UnitYearSelected.year == 'undefined') {
                $scope.COUModal.ownedUnitRec.Year = null;
            } else {
                var selectedYear = parseInt($scope.COUModal.UnitYearSelected.year);
                $scope.COUModal.ownedUnitRec.Year = selectedYear;
            } if(typeof $scope.COUModal.YearOf1stRego.year == 'undefined') {
                $scope.COUModal.ownedUnitRec.YearOf1stRego = null;
            } else {
                var selectedYear = parseInt($scope.COUModal.YearOf1stRego.year);
                $scope.COUModal.ownedUnitRec.YearOf1stRego = selectedYear;
            } 
        }

        /**
         * Keyboard Handling of Tags autocomplete
         */
        $scope.COUModal.changeSeletedTag = function (event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.COUModal.FilteredTagList.length - 1) > $scope.COUModal.currentSelectedTagIndex) {
                    $scope.COUModal.currentSelectedTagIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.COUModal.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.COUModal.currentSelectedTagIndex > 0) {
                    $scope.COUModal.currentSelectedTagIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.COUModal.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
                $scope.COUModal.selectTag($scope.COUModal.FilteredTagList[$scope.COUModal.currentSelectedTagIndex]);
                $scope.COUModal.currentSelectedTagIndex = -1;
                $scope.COUModal.closeAutocomplete();
            }
        }

        $scope.COUModal.closeAutocomplete = function () {
            angular.element('#saveButton').focus();
        }

        /**
         * Method to set selected Make related value in Owned unit Year field value
         */
        $scope.COUModal.changeUnitMake = function (make, event) {
            $scope.COUModal.saveUnitMakeBlur = 1;
            $scope.COUModal.FilterSearchMake = make.UnitMakeName;
            $scope.COUModal.UnitMakeSelected = make;
            $scope.COUModal.ownedUnitRec.Make = $scope.COUModal.UnitMakeSelected.Id;
            $scope.COUModal.ownedUnitRec.MakeName = make.UnitMakeName;
           // $scope.COUModal.UnitModel = [];
            $scope.COUModal.UnitModelSelected = {};
           // $scope.COUModal.UnitSubModel = [];
            $scope.COUModal.UnitSubModelSelected = {};
            $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
            $scope.COUModal.UnitModelNameStr = '';
            $scope.COUModal.UnitSubModelNameStr = '';
            $scope.COUModal.ownedUnitRec.Model = null;
            $scope.COUModal.ownedUnitRec.SubModelName = null;
            $scope.COUModal.FilterSearchUnitModel = '';
            $scope.COUModal.FilterSearchUnitSubModel = '';
            $scope.COUModal.filteredItemsUnitSubModel = '';
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            $scope.COUModal.saveUnitMakeBlur = 0;
            var UnitModelList = [];
            var unitSubModelList = [];
            for(var i=0;i<$scope.COUModal.UnitModel.length;i++){
                if(make.Id == $scope.COUModal.UnitModel[i].MakeId) {
                    UnitModelList.push($scope.COUModal.UnitModel[i]);
                    for(var j=0;j<$scope.COUModal.UnitSubModel.length;j++){
                        if($scope.COUModal.UnitModel[i].Id == $scope.COUModal.UnitSubModel[j].ModelId) {
                            unitSubModelList.push($scope.COUModal.UnitSubModel[j]);
                        }
                    }
                
                }
            }
            $scope.COUModal.UnitModel = UnitModelList;
            $scope.COUModal.UnitSubModel = unitSubModelList;
        }

        $scope.COUModal.ChangeSeletedUnitMake = function (event) {
            if (event.which === 40) {

                $scope.COUModal.CurrentIndexMake++;
            } else if (event.which === 38) {
                if ($scope.COUModal.CurrentIndexMake >= 1) {
                    $scope.COUModal.CurrentIndexMake--;
                }
            } else if (event.which === 13) {
                $scope.COUModal.changeUnitMake($scope.COUModal.filteredItemsMake[$scope.COUModal.CurrentIndexMake], event);
                $scope.COUModal.CurrentIndexMake = -1
            } 
            else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.COUModal.filteredItemsMake == undefined || $scope.COUModal.filteredItemsMake.length == 0 || $scope.COUModal.FilterSearchMake == undefined || $scope.COUModal.FilterSearchMake == '') {
                    $scope.COUModal.CurrentIndexMake = -1
                    /* $scope.COUModal.UnitModel = tempModelList;
                    $scope.COUModal.UnitSubModel = tempSubModelList; */
                    return;
                }
                if (angular.lowercase($scope.COUModal.filteredItemsMake[0].UnitMakeName).trim() == angular.lowercase($scope.COUModal.FilterSearchMake).trim()) {
                    $scope.COUModal.CurrentIndexMake = 0;
                } else {
                    $scope.COUModal.CurrentIndexMake = -1
                }

            }
            filterMakeModelSubmodelList();
        }

        $scope.COUModal.ChangeSeletedUnitModel = function (event) {
            if (event.which === 40) {
                $scope.COUModal.CurrentIndexUnitModel++;
            } else if (event.which === 38) {
                if ($scope.COUModal.CurrentIndexUnitModel >= 1) {
                    $scope.COUModal.CurrentIndexUnitModel--;
                }
            } else if (event.which === 13) {
                $scope.COUModal.changeUnitmodel($scope.COUModal.filteredItemsUnitModel[$scope.COUModal.CurrentIndexUnitModel], event);
                $scope.COUModal.filteredItemsUnitModel = {};
                $scope.COUModal.CurrentIndexUnitModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.COUModal.filteredItemsUnitModel == undefined || $scope.COUModal.filteredItemsUnitModel.length == 0 || $scope.COUModal.FilterSearchUnitModel == undefined || $scope.COUModal.FilterSearchUnitModel == '') {
                    $scope.COUModal.CurrentIndexUnitModel = -1
                    return;
                }
                if (angular.lowercase($scope.COUModal.filteredItemsUnitModel[0].UnitModelName).trim() == angular.lowercase($scope.COUModal.FilterSearchUnitModel).trim()) {
                    $scope.COUModal.CurrentIndexUnitModel = 0;
                } else {
                    $scope.COUModal.CurrentIndexUnitModel = -1
                }
            }
            filterMakeModelSubmodelList();
        }
        
        /**
         * Sub Model Select Enter
         */
        $scope.COUModal.ChangeSeletedUnitSubModel = function (event) {
            if (event.which === 40) {
                $scope.COUModal.CurrentIndexUnitSubModel++;
            } else if (event.which === 38) {
                if ($scope.COUModal.CurrentIndexUnitSubModel >= 1) {
                    $scope.COUModal.CurrentIndexUnitSubModel--;
                }
            } else if (event.which === 13) {
                $scope.COUModal.changeUnitSubmodel($scope.COUModal.filteredItemsUnitSubModel[$scope.COUModal.CurrentIndexUnitSubModel], event);
                $scope.COUModal.CurrentIndexUnitSubModel = -1
            } else {
                if (angular.element(event.target).parent().hasClass("open") == false) {
                    angular.element(event.target).parent().addClass("open");
                }
                if ($scope.COUModal.filteredItemsUnitSubModel == undefined || $scope.COUModal.filteredItemsUnitSubModel.length == 0 || $scope.COUModal.FilterSearchUnitSubModel == undefined || $scope.COUModal.FilterSearchUnitSubModel == '' ) {
                    $scope.COUModal.CurrentIndexUnitSubModel = -1
                    return;
                }
                if (angular.lowercase($scope.COUModal.filteredItemsUnitSubModel[0].SubModelName).trim() == angular.lowercase($scope.COUModal.FilterSearchUnitSubModel).trim()) {
                    $scope.COUModal.CurrentIndexUnitSubModel = 0;
                } else {
                    $scope.COUModal.CurrentIndexUnitSubModel = -1;
                }
            }
            filterMakeModelSubmodelList();
        }

        $scope.COUModal.getUnitmakeList = function (event) {
            event.preventDefault();
            angular.element('.controls').hide();
            angular.element('#customerUnitMakeSelectedId').show();
            if (angular.element(event.target).parent().hasClass("open") == false) {
                if ($(".selectDropbox").hasClass("open") == true) {
                    setTimeout(function () {
                        $(".selectDropbox").removeClass("open");
                    }, 5);
                }
                angular.element(event.target).parent().addClass("open");
            }
            filterMakeModelSubmodelList();
        }
        function filterMakeModelSubmodelList() {
            $scope.COUModal.UnitMake = tempMakelist;
            $scope.COUModal.UnitModel = tempModelList;
            $scope.COUModal.UnitSubModel = tempSubModelList;
            if($scope.COUModal.ownedUnitRec.Make) {
                var UnitModelList = [];
                var unitSubModelList = [];
                for(var i=0;i<$scope.COUModal.UnitModel.length;i++){
                    if($scope.COUModal.ownedUnitRec.Make == $scope.COUModal.UnitModel[i].MakeId) {
                        UnitModelList.push($scope.COUModal.UnitModel[i]);
                    }
                } 
                for(var i=0;i<UnitModelList.length;i++) {
                    for(var j=0;j<$scope.COUModal.UnitSubModel.length;j++){
                        if((!$scope.COUModal.ownedUnitRec.Model || $scope.COUModal.ownedUnitRec.Model == $scope.COUModal.UnitSubModel[j].ModelId) && UnitModelList[i].Id == $scope.COUModal.UnitSubModel[j].ModelId) {
                            unitSubModelList.push($scope.COUModal.UnitSubModel[j]);
                        }
                    }
                }
                $scope.COUModal.UnitModel = UnitModelList;
                $scope.COUModal.UnitSubModel = unitSubModelList;
            }

        }


        $scope.COUModal.getUnitModelList = function (event) {
            angular.element('.controls').hide();
            angular.element('#customerUnitMainModelId').show();
            if (angular.element(event.target).parent().hasClass("open") == false) {
                if ($(".selectDropbox").hasClass("open") == true) {
                    setTimeout(function () {
                        $(".selectDropbox").removeClass("open");
                    }, 5);
                }
                angular.element(event.target).parent().addClass("open");
            }
            filterMakeModelSubmodelList();
        }

        $scope.COUModal.getUnitSubModelList = function (event) {
            angular.element('.controls').hide();
            angular.element('#customerSubModelId').show();
            if (angular.element(event.target).parent().hasClass("open") == false) {
                if ($(".selectDropbox").hasClass("open") == true) {
                    setTimeout(function () {
                        $(".selectDropbox").removeClass("open");
                    }, 5);
                }
                angular.element(event.target).parent().addClass("open");
            }
            filterMakeModelSubmodelList();
        }

        $scope.COUModal.saveUnitModel = function (event) {
            if ($scope.COUModal.saveUnitModelBlur == 0 || $scope.COUModal.saveUnitModelBlur == undefined) {
                if ($scope.COUModal.ownedUnitRec.ModelName != $scope.COUModal.FilterSearchUnitModel) {
                    $scope.COUModal.ownedUnitRec.SubModel = null;
                    $scope.COUModal.ownedUnitRec.SubModelName = '';
                    $scope.COUModal.FilterSearchUnitSubModel = '';
                    $scope.COUModal.filteredItemsUnitSubModel = '';
                    $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isModelAlreadyExist = false;
                for (var i = 0; i < $scope.COUModal.UnitModel.length; i++) {
                    if ($scope.COUModal.UnitModel[i].UnitModelName == $scope.COUModal.FilterSearchUnitModel) {
                        $scope.COUModal.ownedUnitRec.Model = $scope.COUModal.UnitModel[i].Id;
                        $scope.COUModal.ownedUnitRec.ModelName = $scope.COUModal.UnitModel[i].UnitModelName;
                        isModelAlreadyExist = true;
                    }
                }
                if (!isModelAlreadyExist) {
                    $scope.COUModal.ownedUnitRec.ModelName = $scope.COUModal.FilterSearchUnitModel;
                    $scope.COUModal.ownedUnitRec.Model = null;
                    $scope.COUModal.UnitModelSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.COUModal.saveUnitModelBlur = 0;
            }
        }

        $scope.COUModal.saveUnitMake = function (event) {
            if ($scope.COUModal.saveUnitMakeBlur == 0 || $scope.COUModal.saveUnitMakeBlur == undefined) {
                if ($scope.COUModal.ownedUnitRec.MakeName != $scope.COUModal.FilterSearchMake) {
                    $scope.COUModal.ownedUnitRec.ModelName = '';
                    $scope.COUModal.ownedUnitRec.Model = null;
                    $scope.COUModal.FilterSearchUnitModel = '';
                    $scope.COUModal.ownedUnitRec.SubModel = null;
                    $scope.COUModal.ownedUnitRec.SubModelName = '';
                    $scope.COUModal.FilterSearchUnitSubModel = '';
                    $scope.COUModal.filteredItemsUnitSubModel = '';
                    $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isMakeAlreadyExist = false;
                for (var i = 0; i < $scope.COUModal.UnitMake.length; i++) {
                    if ($scope.COUModal.UnitMake[i].UnitMakeName == $scope.COUModal.FilterSearchMake) {
                        $scope.COUModal.ownedUnitRec.Make = $scope.COUModal.UnitMake[i].Id;
                        $scope.COUModal.ownedUnitRec.MakeName = $scope.COUModal.UnitMake[i].UnitMakeName;
                        isMakeAlreadyExist = true;
                    }
                }
                if (!isMakeAlreadyExist) {
                    $scope.COUModal.ownedUnitRec.MakeName = $scope.COUModal.FilterSearchMake;
                    $scope.COUModal.ownedUnitRec.Make = null;
                    $scope.COUModal.UnitMakeSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.COUModal.saveUnitMakeBlur = 0;
            }
        }

        $scope.COUModal.saveUnitSubModel = function (event) {
            if ($scope.COUModal.saveUnitSubModelBlur == 0 || $scope.COUModal.saveUnitSubModelBlur == undefined) {
                if ($scope.COUModal.ownedUnitRec.SubModelName != $scope.COUModal.FilterSearchUnitSubModel) {
                    $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
                }
                var isSubModelAlreadyExist = false;
                for (var i = 0; i < $scope.COUModal.UnitSubModel.length; i++) {
                    if ($scope.COUModal.UnitSubModel[i].SubModelName == $scope.COUModal.FilterSearchUnitSubModel) {
                        $scope.COUModal.ownedUnitRec.SubModel = $scope.COUModal.UnitSubModel[i].Id;
                        $scope.COUModal.ownedUnitRec.SubModelName = $scope.COUModal.UnitSubModel[i].SubModelName;
                        isSubModelAlreadyExist = true;
                    }
                }
                if (!isSubModelAlreadyExist) {
                    $scope.COUModal.ownedUnitRec.SubModelName = $scope.COUModal.FilterSearchUnitSubModel;
                    $scope.COUModal.ownedUnitRec.SubModel = null;
                    $scope.COUModal.UnitSubModelSelected = {};
                }
                angular.element(event.target).closest('.selectDropbox').removeClass("open");
            } else {
                $scope.COUModal.saveUnitSubModelBlur = 0;
            }
        }

        $scope.COUModal.changeUnitmodel = function (model, event) {
            $scope.COUModal.saveUnitModelBlur = 1;
            $scope.COUModal.FilterSearchUnitModel = model.UnitModelName;
            $scope.COUModal.UnitModelSelected = model;
            $scope.COUModal.ownedUnitRec.Model = $scope.COUModal.UnitModelSelected.Id;
            //$scope.COUModal.UnitSubModel = [];
            $scope.COUModal.UnitSubModelSelected = {};
            $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
            $scope.COUModal.ownedUnitRec.SubModelName = null;
            $scope.COUModal.FilterSearchUnitSubModel = '';
            $scope.COUModal.UnitSubModelNameStr = '';
            $scope.COUModal.filteredItemsUnitSubModel = '';
            $scope.COUModal.saveUnitModelBlur = 0;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
            var unitSubModelList = [];
            for(var i=0;i<$scope.COUModal.UnitSubModel.length;i++){
                if(model.Id == $scope.COUModal.UnitSubModel[i].ModelId) {
                    unitSubModelList.push($scope.COUModal.UnitSubModel[i]);
                }
            }
            $scope.COUModal.UnitSubModel = unitSubModelList;
            var makeIndex = _.findIndex($scope.COUModal.UnitMake, {
                'Id': model.MakeId
            });
            if(makeIndex != -1) {
                $scope.COUModal.saveUnitMakeBlur = 1;
                $scope.COUModal.FilterSearchMake = $scope.COUModal.UnitMake[makeIndex].UnitMakeName;
                $scope.COUModal.UnitMakeSelected = $scope.COUModal.UnitMake[makeIndex];
                $scope.COUModal.ownedUnitRec.Make = $scope.COUModal.UnitMake[makeIndex].Id;
                $scope.COUModal.ownedUnitRec.MakeName = $scope.COUModal.UnitMake[makeIndex].UnitMakeName;
            }
        }

        $scope.COUModal.changeUnitSubmodel = function (model, event) {
            console.log(model);
            console.log("dinesh");
            var modelIndex = _.findIndex($scope.COUModal.UnitModel, {
                'Id': model.ModelId
            });
            if(modelIndex != -1) {
                $scope.COUModal.saveUnitModelBlur = 1;
                $scope.COUModal.FilterSearchUnitModel = $scope.COUModal.UnitModel[modelIndex].UnitModelName;
                $scope.COUModal.UnitModelSelected = $scope.COUModal.UnitModel[modelIndex];
                $scope.COUModal.ownedUnitRec.Model = $scope.COUModal.UnitModel[modelIndex].Id;
                $scope.COUModal.ownedUnitRec.ModelName = $scope.COUModal.UnitModel[modelIndex].UnitModelName;
                
                var makeIndex = _.findIndex($scope.COUModal.UnitMake, {
                    'Id': $scope.COUModal.UnitModel[modelIndex].MakeId
                });
                if(makeIndex != -1) {
                    $scope.COUModal.saveUnitMakeBlur = 1;
                    $scope.COUModal.FilterSearchMake = $scope.COUModal.UnitMake[makeIndex].UnitMakeName;
                    $scope.COUModal.UnitMakeSelected = $scope.COUModal.UnitMake[makeIndex];
                    $scope.COUModal.ownedUnitRec.Make = $scope.COUModal.UnitMake[makeIndex].Id;
                    $scope.COUModal.ownedUnitRec.MakeName = $scope.COUModal.UnitMake[makeIndex].UnitMakeName;
                }
            }
            $scope.COUModal.saveUnitSubModelBlur = 1;
            $scope.COUModal.FilterSearchUnitSubModel = model.SubModelName;
            $scope.COUModal.UnitSubModelSelected = model;
            $scope.COUModal.ownedUnitRec.SubModel = $scope.COUModal.UnitSubModelSelected.Id;
            $scope.COUModal.ownedUnitRec.SubModelName = $scope.COUModal.UnitSubModelSelected.SubModelName;
            $scope.COUModal.saveUnitSubModelBlur = 0;
            $scope.COUModal.ownedUnitRec.MakeModelDescription = $scope.COUModal.UnitSubModelSelected.SubmodelDescription;
            angular.element(event.target).closest('.selectDropbox').removeClass("open");
        }

        /**
         * OnBlur method for VIN field
         */
        $scope.COUModal.OnBlurVin = function (args) {
            if ($scope.COUModal.ownedUnitRec.Id == null || args == 'VIN') {
                if ($scope.COUModal.ownedUnitRec.VIN != null && $scope.COUModal.ownedUnitRec.VIN != '' && args == 'VIN' &&
                    $scope.COUModal.COUFormValidationModal[args] != undefined) {
                    $scope.COUModal.COUFormValidationModal[args].isError = false;
                }
                $scope.COUModal.getSimilarUnits($scope.COUModal.ownedUnitRec);
            }
            if($scope.COUModal.ownedUnitRec.UnitType == 'COU'&& $Global.isBRPEnabled) {
            	getVehicleSpecification();
            }
        }
        
        var vehicleSpecification;
        $scope.COUModal.vehicleSpecificationsResult = '';
        
        $scope.COUModal.keydownForVIN = function(event) {
        	var keyCode = event.which ? event.which : event.keyCode;
        	if(keyCode == 9 && !isBlankValue($scope.COUModal.ownedUnitRec.VIN)) {
        		event.preventDefault();
        		angular.element('#VINFieldId').blur();
        	}
        }
        
        getVehicleSpecification = function() {
        	if(isBlankValue($scope.COUModal.ownedUnitRec.VIN)) {
        		$scope.COUModal.vehicleSpecificationsResult = '';
        		return;
        	}
        	$scope.COUModal.vehicleSpecificationsResult = 'Loading';
        	CustomerOwnedUnitService.getVehicleSpecification($scope.COUModal.ownedUnitRec.VIN).then(function(successResult) {
        		if(successResult.responseCode == 400) {
        			$scope.COUModal.vehicleSpecificationsResult = 'Match not found';
        		} else {
        			$scope.COUModal.vehicleSpecificationsResult = 'Match found';
        			vehicleSpecification = successResult;
        			vehicleSpecification.MakeName = 'BRP';
        			setVehicleFormattedName();
        		}
	        }, function(errorSearchResult) {
	            Notification.error("Error in getting vehicle specification");
	        });
        }
        
        setVehicleFormattedName = function() {
        	var formattedName = '';
        	if(!isBlankValue(vehicleSpecification.ModelYear)) {
        		formattedName += vehicleSpecification.ModelYear;
        	}
        	if(!isBlankValue(vehicleSpecification.MakeName)) {
        		formattedName += ' ' + vehicleSpecification.MakeName;
        	}
        	if(!isBlankValue(vehicleSpecification.Model)) {
        		formattedName += ' ' + vehicleSpecification.Model;
        	}
        	if(!isBlankValue(vehicleSpecification.ModelDescription)) {
        		formattedName += ' ' + vehicleSpecification.ModelDescription;
        	}
        	vehicleSpecification.formattedNameForCard = formattedName;
        	createVehiclePayload();
        }
        
        createVehiclePayload = function() {
        	$scope.COUModal.unitCardInfoPayload = {
            		headerText: vehicleSpecification.formattedNameForCard,
            		buttonActionVisible: true,
            		buttonText: 'Use'
            }
        }
        
        $scope.COUModal.setDataFromBRP = function() {
        	if(isBlankValue($scope.COUModal.ownedUnitRec.MakeName)) {
				$scope.COUModal.ownedUnitRec.MakeName = '';
    		}
			if(isBlankValue($scope.COUModal.ownedUnitRec.ModelName)) {
				$scope.COUModal.ownedUnitRec.ModelName = '';
    		}
			if(isBlankValue($scope.COUModal.ownedUnitRec.SubModelName)) {
				$scope.COUModal.ownedUnitRec.SubModelName = '';
    		}
        	if($scope.COUModal.ownedUnitRec.MakeName.toLowerCase() != vehicleSpecification.MakeName.toLowerCase()) {
    			$scope.COUModal.ownedUnitRec.MakeName = vehicleSpecification.MakeName;
    			$scope.COUModal.ownedUnitRec.Make = null;
    			$scope.COUModal.ownedUnitRec.Model = null;
    			$scope.COUModal.ownedUnitRec.SubModel = null;
    		}
        	$scope.COUModal.FilterSearchMake = vehicleSpecification.MakeName;
        	
        	if($scope.COUModal.ownedUnitRec.ModelName.toLowerCase() != vehicleSpecification.Model.toLowerCase()) {
    			$scope.COUModal.ownedUnitRec.ModelName = vehicleSpecification.Model;
    			$scope.COUModal.ownedUnitRec.Model = null;
    			$scope.COUModal.ownedUnitRec.SubModel = null;
    		}
        	$scope.COUModal.FilterSearchUnitModel = vehicleSpecification.Model;
        	
        	if($scope.COUModal.ownedUnitRec.SubModelName.toLowerCase() != vehicleSpecification.ModelDescription.toLowerCase()) {
    			$scope.COUModal.ownedUnitRec.SubModelName = vehicleSpecification.ModelDescription;
    			$scope.COUModal.ownedUnitRec.SubModel = null;
    		}
        	$scope.COUModal.FilterSearchUnitSubModel = vehicleSpecification.ModelDescription;
        	
        	$scope.COUModal.ownedUnitRec.Year = vehicleSpecification.ModelYear;
    		if(!isBlankValue($scope.COUModal.ownedUnitRec.Year)) {
    			$scope.COUModal.ownedUnitRec.Year = parseInt($scope.COUModal.ownedUnitRec.Year);
    		} else {
            	$scope.COUModal.ownedUnitRec.Year = null;
            }
    		$scope.COUModal.UnitYearSelected = {
                year: $scope.COUModal.ownedUnitRec.Year
            };
            $scope.COUModal.YearOf1stRego = {
                year: $scope.COUModal.ownedUnitRec.YearOf1stRego
            };
        	if(vehicleSpecification.Engine) {
            	$scope.COUModal.ownedUnitRec.Cylinders = vehicleSpecification.Engine.NumberOfEngineCylindersNumeric;
            	if(!isBlankValue($scope.COUModal.ownedUnitRec.Cylinders)) {
            		$scope.COUModal.ownedUnitRec.Cylinders = parseFloat($scope.COUModal.ownedUnitRec.Cylinders);
        			$scope.COUModal.AdditionalFieldsInfo.Cylinders.isPrimary = true;
        		} else {
                	$scope.COUModal.ownedUnitRec.Cylinders = null;
        		}
        	}
        }

        $scope.COUModal.OnBlurDateIn = function (args) {
            if ($scope.COUModal.ownedUnitRec.UnitType == 'Stock' && $scope.COUModal.ownedUnitRec.Id != null) {
                if ($scope.COUModal.ownedUnitRec.DateIn != null && $scope.COUModal.ownedUnitRec.DateIn != '' && $scope.COUModal.COUFormValidationModal[DateIn] != undefined) { // 15th march, 2017 kajal 
                    $scope.COUModal.COUFormValidationModal[args].isError = false;
                }
            }
        }

        $scope.COUModal.OnBlurMileage = function () {
            $scope.COUModal.ValidateForm("Mileage");
        }

        /**
         * Method to find similar COU records with similar VIN numbers in database
         */
        $scope.COUModal.getSimilarUnits = function (ownedUnitRec) {
            VINOperationsService.getSimilarUnits(angular.toJson(ownedUnitRec)).then(function (SimilarCOU) {
                    $scope.COUModal.SimilarCOU = SimilarCOU;
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                });
        }

        /**
         * Method to perform SAVE action for popup
         */
        $scope.COUModal.CancelCOUForm = function () {
            angular.element('#AddNewCOU').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }

        /**
         * Method to perform CANCEL action for popup
         */
        $scope.COUModal.SaveCOUForm = function () {

            if ($scope.COUModal.ownedUnitRec.Mileage == "" || $scope.COUModal.ownedUnitRec.Mileage == undefined) {
                $scope.COUModal.ownedUnitRec.Mileage = null;
            }
            if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                if ($scope.COUModal.ownedUnitRec.TotalBasePrice === '' || $scope.COUModal.ownedUnitRec.TotalBasePrice == undefined) { 
                    $scope.COUModal.ownedUnitRec.TotalBasePrice = null;
                }
                if ($scope.COUModal.ownedUnitRec.TotalBaseCost === '' || $scope.COUModal.ownedUnitRec.TotalBaseCost == undefined) { 
                    $scope.COUModal.ownedUnitRec.TotalBaseCost = null;
                }
            }
            if (!$scope.COUModal.isSimilarUnitRec) {
                $scope.COUModal.checkSimilarRec();
            } else {
                $scope.COUModal.checkSimilarUnitsData();
            }
        }

        $scope.COUModal.checkSimilarRec = function () {
            VINOperationsService.getSimilarUnits(angular.toJson($scope.COUModal.ownedUnitRec)).then(function (SimilarCOU) {
                    $scope.COUModal.isSimilarUnitRec = true;
                    $scope.COUModal.SimilarCOU = SimilarCOU;
                    $scope.COUModal.checkSimilarUnitsData();
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                }
            );
        }

        $scope.COUModal.checkSimilarUnitsData = function () {
            var isValidForm = $scope.COUModal.validateFormValidationModel();
            if (isValidForm) {
                isValidForm = $scope.COUModal.validateVINNumber();
            }
            $scope.COUModal.isSimilarUnitRec = false;
            if (isValidForm) {
                var ownedRecs = [];
                ownedRecs.push($scope.COUModal.ownedUnitRec);
                $scope.COUModal.SaveCustomerOwnedUnitsToserver(angular.toJson(ownedRecs));
            }
        }

        $scope.COUModal.SaveCustomerOwnedUnitsToserver = function (selectedCOURecords) {
            var customerId = $scope.COUModal.customerId;
            if ($scope.COUModal.disableSaveButton) {
                return;
            }
            $scope.COUModal.disableSaveButton = true;
            /* Update customer to database and refresh list
               Method to add/update customers JSON array and refresh related customers list */
            VINOperationsService.addCustomerOwnedUnit(customerId, selectedCOURecords).then(function (relatedCOUList) {
                if (relatedCOUList.HasError) {
                    $scope.COUModal.disableSaveButton = false;
                    Notification.error(relatedCOUList.ErrorMessage);
                    return;
                }
                if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK' && $scope.COUModal.ownedUnitRec.Id == null) {
                    $state.go('ViewUnit', {
                        Id: relatedCOUList[0].Id
                    }, {
                        reload: true
                    });
                } else {
                	if($rootScope.$previousState.name === 'CustomerOrder_V2') {
                		hideModelWindow();
                        loadState($state, $rootScope.$previousState.name, {
                            Id: $rootScope.$previousStateParams.Id
                        });
                        for (var i = 0; i < $scope.M_CO.COUList.length; i++) {
                            if ($scope.M_CO.COUList[i].Id === relatedCOUList[0].Id) {
                            	$scope.M_CO.COUList[i] = relatedCOUList[0];
                            }
                        }
                        $scope.$parent.F_CO.selectCustomerUnit($scope.COUModal.index, $scope.COUModal.soHeaderIndex);
                	} else {
                		 $scope.$parent.loadDataFromCOU(relatedCOUList[0].Id);
                         hideModelWindow();
                         loadState($state, $rootScope.$previousState.name, {
                             Id: $rootScope.$previousStateParams.Id
                         });
                	}
                }
                if (angular.element('#AddNewCOU') != null) {
                    angular.element('#AddNewCOU').modal('hide');
                }
                $scope.COUModal.disableSaveButton = false;
                Notification.success($translate.instant('Generic_Saved'));
            }, function (errorSearchResult) {
                $scope.COUModal.disableSaveButton = false;
                $scope.ViewCustomer.CustomerInfo = errorSearchResult;
                Notification.error($translate.instant('Generic_Error'));
            });
        }
        
        /**
         * Method to perform a validation process on over the whole validation model and returns the form valid status
         */
        $scope.COUModal.validateFormValidationModel = function () {
            var isValidForm = true;
            angular.forEach($scope.COUModal.COUFormValidationModal, function (value, key) {
                $scope.COUModal.ValidateForm(key);
                if ($scope.COUModal.COUFormValidationModal[key].isError) {
                    isValidForm = false;
                }
            });
            return isValidForm;
        }
        
        $scope.COUModal.maxDateCalculation = function () {
            $scope.COUModal.dateOptions5 = {
                minDate: $scope.COUModal.ownedUnitRec.DateIn,
                dateFormat: $scope.COUModal.DateFormat
            };
        }
        
        $scope.dateOptions1 = {
            dateFormat: $scope.COUModal.DateFormat
        };
        
        $scope.COUModal.ValidateForm = function (modelKey) {
            var fieldValue = $scope.COUModal.ownedUnitRec[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.COUModal.COUFormValidationModal[modelKey].Type;

            // If validation type has Vin type validation, then perform VIN validation first
            /*if (validateType.indexOf('VIN') > -1) {
                if (fieldValue != '' && fieldValue != undefined) {
                    result = $scope.COUModal.validateVin(fieldValue);
                } else {
                    result = true;
                }
                if (result == false) {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = true;
                    $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = $Label.Label_Invalid + ' ' + $Label.Label_VIN;

                } else {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = false;
                    $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = '';
                }
            }*/

            // Numeric fields validation
            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && isNaN(fieldValue)) {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = true;
                    if (modelKey === 'Mileage') {
                        $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = $translate.instant('Mileage_value_should_be_number');
                    } else if (modelKey === 'TotalBaseCost') {
                        $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = $translate.instant('Cost_value_should_be_number');
                    } else if (modelKey === 'TotalBasePrice') {
                        $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = $translate.instant('Price_value_should_be_number');
                    }
                } else {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = false;
                    $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = true;
                    $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.COUModal.COUFormValidationModal[modelKey].isError = false;
                    $scope.COUModal.COUFormValidationModal[modelKey].ErrorMessage = '';
                }
            }
        }

        $scope.COUModal.validateVINNumber = function () {
            var isValid = !$scope.COUModal.validateUniqueVIN();
            if (!isValid) {
                Notification.error($translate.instant('NewAddNewCOU_Active_VIN'));
                return;
            }
            /*if ($scope.COUModal.ownedUnitRec.VIN != '' && $scope.COUModal.ownedUnitRec.VIN != undefined) {
                isValid = $scope.COUModal.validateVin($scope.COUModal.ownedUnitRec.VIN);
            }
            if (!isValid) {
                Notification.error($Label.NewAddNewCOU_VIN_not_valid);
                return;
            }*/
            return isValid;
        }

        $scope.COUModal.validateUniqueVIN = function () {
            var isSimilarActiveVINPresent = false;
            if ($scope.COUModal.SimilarCOU != undefined && $scope.COUModal.SimilarCOU != null) {
                for (var i = 0; i < $scope.COUModal.SimilarCOU.length; i++) {
                    if ($scope.COUModal.SimilarCOU[i].PriorityNumber == 1 && $scope.COUModal.ownedUnitRec.Id != $scope.COUModal.SimilarCOU[i].Id) {
                        isSimilarActiveVINPresent = true;
                        break;
                    }
                }
            }
            return isSimilarActiveVINPresent;
        }
        $scope.COUModal.validatePromisedByDate = function (index) {
            if ($scope.COUModal.ownedUnitRec.DateIn.length < 10) {
                Notification.error($translate.instant('Select_valid_date'));
                return;
            }
        }

        $scope.COUModal.loadManageJsonData = function () {
            if ($scope.COUModal.ownedUnitRec.UnitType == 'COU' || $scope.COUModal.ownedUnitRec.UnitType == undefined) {
                $scope.COUModal.ManageIconCustomerDetails = [{
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    VIN: {
                        value: [{
                            val: 'VIN',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
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
                    Color: {
                        value: [{
                            val: 'Color',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    StockId: {
                        value: [{
                            val: 'StockId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    Plate: {
                        value: [{
                            val: 'Plate',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    RegExpiryDate: {
                        value: [{
                            val: 'RegExpiryDate',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    Mileage: {
                        value: [{
                            val: 'Mileage',
                            fieldType: 'number'
                        }],
                        isPrimary: true
                    },
                    InteriorColour: {
                        value: [{
                            val: 'InteriorColour',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    KeyNo: {
                        value: [{
                            val: 'KeyNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    EngineSerialNo: {
                        value: [{
                            val: 'EngineSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    OtherSerialNo: {
                        value: [{
                            val: 'OtherSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Cylinders: {
                        value: [{
                            val: 'Cylinders',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Displacement: {
                        value: [{
                            val: 'Displacement',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    IsAutomatic: {
                        value: [{
                            val: 'IsAutomatic',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    ComplianceDate: {
                        value: [{
                            val: 'ComplianceDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    YearOf1stRego: {
                        value: [{
                            val: 'YearOf1stRego',
                            fieldType: 'lookup'
                        }],
                        isPrimary: false
                    },
                    RegistrationSerial: {
                        value: [{
                            val: 'RegistrationSerial',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    ManufacturedDate: {
                        value: [{
                            val: 'ManufacturedDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    }
                }]
            } else if ($scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                $scope.COUModal.ManageIconCustomerDetails = [{
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    VIN: {
                        value: [{
                            val: 'VIN',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
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
                    IsNewUnit: {
                        value: [{
                            val: 'IsNewUnit',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Color: {
                        value: [{
                            val: 'Color',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    StockId: {
                        value: [{
                            val: 'StockId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    Plate: {
                        value: [{
                            val: 'Plate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Mileage: {
                        value: [{
                            val: 'Mileage',
                            fieldType: 'number'
                        }],
                        isPrimary: false
                    },
                    InteriorColour: {
                        value: [{
                            val: 'InteriorColour',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    KeyNo: {
                        value: [{
                            val: 'KeyNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    EngineSerialNo: {
                        value: [{
                            val: 'EngineSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    OtherSerialNo: {
                        value: [{
                            val: 'OtherSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Cylinders: {
                        value: [{
                            val: 'Cylinders',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Displacement: {
                        value: [{
                            val: 'Displacement',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    IsAutomatic: {
                        value: [{
                            val: 'IsAutomatic',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Category: {
                        value: [{
                            val: 'Category',
                            fieldType: 'lookup'
                        }],
                        isPrimary: false
                    },
                    Location: {
                        value: [{
                            val: 'Location',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    TotalBaseCost: {
                        value: [{
                            val: 'TotalBaseCost',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    TotalBasePrice: {
                        value: [{
                            val: 'TotalBasePrice',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    IsTaxable: {
                        value: [{
                            val: 'IsTaxable',
                            fieldType: 'boolean'
                        }],
                        isPrimary: false
                    },
                    ManufacturedDate: {
                        value: [{
                            val: 'ManufacturedDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    RegExpiryDate: {
                        value: [{
                            val: 'RegExpiryDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    ComplianceDate: {
                        value: [{
                            val: 'ComplianceDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    YearOf1stRego: {
                        value: [{
                            val: 'YearOf1stRego',
                            fieldType: 'lookup'
                        }],
                        isPrimary: false
                    },
                    RegistrationSerial: {
                        value: [{
                            val: 'RegistrationSerial',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    }
                }]
                if ($scope.COUModal.currentCOUId != undefined && $scope.COUModal.currentCOUId != null && $scope.COUModal.currentCOUId != '') {
                    var dateIn = {
                        value: [{
                            val: 'DateIn',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    };
                    $scope.COUModal.ManageIconCustomerDetails[0].DateIn = dateIn;

                    if ($scope.COUModal.ownedUnitRec.DateOut != undefined && $scope.COUModal.ownedUnitRec.DateOut != null && $scope.COUModal.ownedUnitRec.DateOut != '') {
                        var dateOut = {
                            value: [{
                                val: 'DateOut',
                                fieldType: 'text'
                            }],
                            isPrimary: true
                        };
                        $scope.COUModal.ManageIconCustomerDetails[0].DateOut = dateOut;
                    }
                }
            } else if ($scope.COUModal.ownedUnitRec.UnitType == 'ORDU') {
                $scope.COUModal.ManageIconCustomerDetails = [{
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    VIN: {
                        value: [{
                            val: 'VIN',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
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
                    IsNewUnit: {
                        value: [{
                            val: 'IsNewUnit',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Color: {
                        value: [{
                            val: 'Color',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    StockId: {
                        value: [{
                            val: 'Stock#',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    UnitId: {
                        value: [{
                            val: 'UnitId',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    FactoryOrderNo: {
                        value: [{
                            val: 'FactoryOrderNo',
                            fieldType: 'text'
                        }],
                        isPrimary: true
                    },
                    InteriorColour: {
                        value: [{
                            val: 'InteriorColour',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    KeyNo: {
                        value: [{
                            val: 'KeyNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    EngineSerialNo: {
                        value: [{
                            val: 'EngineSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    OtherSerialNo: {
                        value: [{
                            val: 'OtherSerialNo',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Cylinders: {
                        value: [{
                            val: 'Cylinders',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Displacement: {
                        value: [{
                            val: 'Displacement',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    IsAutomatic: {
                        value: [{
                            val: 'IsAutomatic',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    Category: {
                        value: [{
                            val: 'Category',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    IsTaxable: {
                        value: [{
                            val: 'IsTaxable',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    ManufacturedDate: {
                        value: [{
                            val: 'ManufacturedDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    ComplianceDate: {
                        value: [{
                            val: 'ComplianceDate',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    },
                    YearOf1stRego: {
                        value: [{
                            val: 'YearOf1stRego',
                            fieldType: 'lookup'
                        }],
                        isPrimary: false
                    },
                    RegistrationSerial: {
                        value: [{
                            val: 'RegistrationSerial',
                            fieldType: 'text'
                        }],
                        isPrimary: false
                    }
                }]
            }
            
            if($scope.COUModal.currentCOUId && ($scope.COUModal.ownedUnitRec.UnitType != 'ORDU')) {
            	$scope.COUModal.ManageIconCustomerDetails[0]['IsActive'] = {
            		value: [{
                        val: 'IsActive',
                        fieldType: 'boolean'
                    }],
                    isPrimary: true	
                } 
            }
        }

        $scope.COUModal.AdditionalFieldsSearch = '';

        $scope.FilterAdditionalFields = function (items) {
            var result = {};
            angular.forEach(items, function (value, key) {
                if (value.label.toLowerCase().indexOf($scope.COUModal.AdditionalFieldsSearch) != -1) {
                    result[key] = value;
                }
            });
            return result;
        }

        $scope.COUModal.ShowAdditionalField = function (key) {
            if (key == 'Category') {
                $scope.COUModal.AdditionalFieldsInfo[key].isPrimary = true;
                $scope.COUModal.getDefaultUnitCategory();
                var targetId = $scope.COUModal.AdditionalFieldsInfo[key].fieldId;
                setTimeout(function () {
                    if (targetId != undefined) {
                        angular.element('#' + targetId + '_Input').focus();
                    }
                }, 500);
            } else if (key == 'ManufacturedDate') {
                $scope.COUModal.AdditionalFieldsInfo[key].isPrimary = true;
                var targetId = $scope.COUModal.AdditionalFieldsInfo[key].fieldId;
                setTimeout(function () {
                    if (targetId != undefined) {
                        angular.element('#' + targetId).find("input").focus();
                    }
                }, 500);
            } else {
                $scope.COUModal.AdditionalFieldsInfo[key].isPrimary = true;
                var targetId = $scope.COUModal.AdditionalFieldsInfo[key].fieldId;
                setTimeout(function () {
                    if (targetId != undefined) {
                        angular.element('#' + targetId).focus();
                    }
                }, 500);
            }

        }
        $scope.COUModal.manageAdditionalFields = function (key) {
            var result = false;
            if ($scope.COUModal.AdditionalFieldsInfo[key].isPrimary == false) {
                result = true;
            }
            if (key == 'DateIn' && $scope.COUModal.ownedUnitRec.UnitType == 'STOCK') {
                if ($scope.COUModal.ownedUnitRec.DateOut != undefined && $scope.COUModal.ownedUnitRec.DateOut != null && $scope.COUModal.ownedUnitRec.DateOut != '') {
                    $scope.COUModal.dateOptions3 = {
                        maxDate: $scope.COUModal.ownedUnitRec.DateOut,
                        dateFormat: $scope.COUModal.DateFormat
                    };
                } else {
                    $scope.COUModal.dateOptions3 = {
                        maxDate: moment().tz($scope.COUModal.CurrentUserTZSIDKey).format($scope.COUModal.SchedulingDateFormat),
                        dateFormat: $scope.COUModal.DateFormat
                    };
                }
            }
            return result;

        }

        $scope.COUModal.ClearAndRemoveField = function (fieldrel, targetIdToFocus) {
            $scope.COUModal.loadManageJsonData();
            var fieldsToClearOrRemove = $scope.COUModal.ManageIconCustomerDetails[0][fieldrel];

            if (fieldsToClearOrRemove.isPrimary == true) {
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    var key = fieldsToClearOrRemove.value[i].val;
                    if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                        $scope.COUModal.ownedUnitRec[key] = "";
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                        $scope.COUModal.ownedUnitRec[key] = false;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                        $scope.COUModal[key] = null;
                        if (fieldrel == 'ModelName') {
                            $scope.COUModal.ownedUnitRec.Model = null;
                            $scope.COUModal.ownedUnitRec.SubModelName = null;
                            $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
                            $scope.COUModal.UnitSubModelSelected = {};
                            $scope.COUModal.UnitSubModel = [];
                            $scope.COUModal.FilterSearchUnitModel = '';
                            $scope.COUModal.FilterSearchUnitSubModel = '';
                            $scope.COUModal.UnitModelNameStr = '';
                            $scope.COUModal.UnitSubModelNameStr = '';
                            $scope.COUModal.filteredItemsUnitSubModel = '';
                            filterMakeModelSubmodelList();
                            /* $scope.COUModal.UnitModel = tempModelList;
                            $scope.COUModal.UnitSubModel = tempSubModelList; */
                        }
                        if (fieldrel == 'MakeName') {
                            $scope.COUModal.UnitModelSelected = {};
                            $scope.COUModal.UnitSubModelSelected = {};
                            $scope.COUModal.UnitModel = [];
                            $scope.COUModal.UnitSubModel = [];
                            $scope.COUModal.UnitMakeNameStr = '';
                            $scope.COUModal.UnitModelNameStr = '';
                            $scope.COUModal.UnitSubModelNameStr = '';
                            $scope.COUModal.ownedUnitRec.Make = null;
                            $scope.COUModal.ownedUnitRec.Model = null;
                            $scope.COUModal.ownedUnitRec.SubModelName = null;
                            $scope.COUModal.ownedUnitRec.MakeModelDescription = '';
                            $scope.COUModal.FilterSearchMake = '';
                            $scope.COUModal.FilterSearchUnitModel = '';
                            $scope.COUModal.FilterSearchUnitSubModel = '';
                            $scope.COUModal.filteredItemsUnitSubModel = '';
                            filterMakeModelSubmodelList();
                        }
                        if (fieldrel == 'SubModelName') {
                            $scope.COUModal.UnitSubModelSelected = {};
                            $scope.COUModal.FilterSearchUnitSubModel = '';
                            $scope.COUModal.filteredItemsUnitSubModel = '';
                            $scope.COUModal.UnitSubModel = [];
                            $scope.COUModal.UnitSubModelNameStr = '';
                            $scope.COUModal.ownedUnitRec.SubModelName = null;
                            filterMakeModelSubmodelList();
                        }
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'number') {
                        $scope.COUModal.ownedUnitRec[key] = "";
                    }
                }
            } else {
                for (i = 0; i < fieldsToClearOrRemove.value.length; i++) {
                    var key = fieldsToClearOrRemove.value[i].val;
                    if (fieldsToClearOrRemove.value[i].fieldType == 'text') {
                        if (fieldrel = 'Cylinders') {
                            $scope.COUModal.ownedUnitRec[key] = null;
                        } else {
                            $scope.COUModal.ownedUnitRec[key] = "";
                        }
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'boolean') {
                        $scope.COUModal.ownedUnitRec[key] = false;
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'lookup') {
                        $scope.COUModal.ownedUnitRec[key] = null;
                        if (fieldrel == 'Category') {
                            $scope.COUModal.CategoryNameStr = '';
                        }
                    } else if (fieldsToClearOrRemove.value[i].fieldType == 'number') {
                        $scope.COUModal.ownedUnitRec[key] = "";
                    }
                    $scope.COUModal.AdditionalFieldsInfo[key].isPrimary = false;
                }
            }

            angular.element('#' + targetIdToFocus).focus();
            if (fieldrel == 'ModelName') {
                $scope.COUModal.ClearAndRemoveField('SubModelName', 'customerSubModelId'); /* Changed by richa text -> customerSubModelId #116 PE 27/09/2016 */
            }
            if (fieldrel == 'IsAutomatic') {
                $scope.COUModal.ownedUnitRec.Gears = '';
            }
        }

        $scope.COUModal.gearActive = function () {
            $scope.COUModal.ownedUnitRec.IsAutomatic = !$scope.COUModal.ownedUnitRec.IsAutomatic;
            if ($scope.COUModal.ownedUnitRec.IsAutomatic) {
                angular.element("#customerUnitMainAutomaticId").show();
            } else {
                angular.element("#customerUnitMainAutomaticId").hide();
            }
        }
        
        $scope.COUModal.gearNewUnit = function () {
            $scope.COUModal.ownedUnitRec.IsNewUnit = !$scope.COUModal.ownedUnitRec.IsNewUnit;
        }
        
        $scope.COUModal.validateVin = function (vin) {
            if (vin.trim().length != 17) {
                return true;
            }
            var no_ioq = '[a-hj-npr-z0-9]'; /*Don't allow characters I,O or Q */
            var matcher = new RegExp("^" + no_ioq + "{8}[0-9xX]" + no_ioq + "{8}$", 'i'); /*Case insensitive*/
            if (vin.match(matcher) == null) {
                return false;
            }
            return $scope.COUModal.checkDigitCalculation(vin);
        };

        /**
         * Check digit calculation for ViN validation
         */
        $scope.COUModal.checkDigitCalculation = function (vin) {
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

        angular.element("#Price").on('focus', function () {
            angular.element("#PriceTooltipId").show();
        });

        angular.element("#Price").on('blur', function () {
            angular.element("#PriceTooltipId").show();
        });

        angular.element("#Cost").on('focus', function () {
            angular.element("#CostTooltipId").show();
        });

        angular.element("#Cost").on('blur', function () {
            angular.element("#CostTooltipId").show();
        });
        
        $scope.COUModal.dateOptionsForRegExpiryDate = {
            minDate: moment().tz($scope.COUModal.CurrentUserTZSIDKey).format($scope.COUModal.SchedulingDateFormat),
            dateFormat: $scope.COUModal.DateFormat
        };

        $scope.COUModal.openCOUPopup = function () {
            var unitId = $stateParams.AddEditUnitParams.couId;
            if (unitId != undefined && unitId != null && unitId != '') {
                $scope.COUModal.ownedUnitRec.UnitType = $stateParams.AddEditUnitParams.unitType;
                $scope.COUModal.EditCustomerOwnedUnitEvent($stateParams.AddEditUnitParams);
                $scope.COUModal.soHeaderIndex = $stateParams.AddEditUnitParams.soHeaderIndex;
                $scope.COUModal.index = $stateParams.AddEditUnitParams.index;
            } else {
                $scope.COUModal.AddCustomerOwnedUnitEvent();
            }
            getMakeModelSubmodelList();
            $scope.COUModal.TagNameStr = '';
            $scope.COUModal.isAlreadyFocusedOnTagInput = false;
        }
        $scope.COUModal.openCOUPopup();
    }])
});