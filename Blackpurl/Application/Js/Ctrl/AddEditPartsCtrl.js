define(['Routing_AppJs_PK', 'AddEditPartsServices', 'underscore_min', 'dirNumberInput'], function (Routing_AppJs_PK, AddEditPartsServices, underscore_min,

    dirNumberInput) {
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
        setTimeout(function () {
            angular.element('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 2000);
    });

    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditPartsCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'AddEditPartService','$translate', function ($scope, $timeout, $q, $rootScope, $state, $stateParams, AddEditPartService,$translate) {
        var Notification = injector1.get("Notification");

        $scope.PartCompModal = $scope.PartCompModal || {};
        $scope.PartCompModal.PartModal = {};
        $scope.PartCompModal.PartPricingFieldsOfVendor = {};
        $scope.PartCompModal.VendorNameStr = "";
        $scope.PartCompModal.FeeNameStr = "";
        $scope.PartCompModal.CategoryNameStr = "";
        $scope.PartCompModal.ReplacedByNameStr = "";
        $scope.PartCompModal.PartLocations = [];
        $scope.PartCompModal.tabIndexValue = 1000;
        $scope.PartCompModal.isValidForm = true;
        $scope.PartCompModal.Tax_Rate = 1;
        $scope.PartCompModal.disableVendorInputBox = false;
        $scope.PartCompModal.disableNonInventoryCheckbox = false;
        $scope.PartCompModal.PartModal.isOrderLot = false;
        $scope.PartCompModal.currentSelectedTagIndex = -1;
        $scope.PartCompModal.currentSelectedEnvFeeIndex = -1;
        $scope.PartCompModal.disableSaveButton = false;
        
        $scope.PartCompModal.setDefaultValidationModel = function () {
            $scope.PartCompModal.PartFormValidationModal = {
                PartNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                Description: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                InStockQty: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                Location: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                EnvFeeId: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                VendorId: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                CategoryId: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                AutoReorderTo: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'AutoReorderTo'
                },
                OrderLots: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'OrderLots'
                },
                PartId: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                },
                SKUNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'AllowSpaces'
                }
            };
        }

        $scope.PartCompModal.applyTaxText = "Default";
        $scope.PartCompModal.PriceMethod = [{
            label: "Default"
        }];
        $scope.PartCompModal.PriceMethodValue = 'Default';
        $scope.PartCompModal.applyTextModel = function (labelText) {
            $scope.PartCompModal.applyTaxText = labelText
        }

        $scope.PartCompModal.helpText = {
            PartNumber: $translate.instant('Tooltip_Add_Part_Number'),
            Description: $translate.instant('Tooltip_Add_Part_Description'),
            Vendor: $translate.instant('Tooltip_Add_Part_Vendor'),
            Catagory: $translate.instant('Tooltip_Add_Part_Category'),
            PriceMethod: $translate.instant('Tooltip_Add_Part_PriceMethod'),
            ReplaceBy: $translate.instant('Tooltip_Add_Part_ReplaceBy'),
            InStockQuantity: $translate.instant('Add_Part_Tooltip_InStockQuantity'),
            Location: $translate.instant('Tooltip_Add_Part_Location'),
            Cost: $translate.instant('Tooltip_Add_Part_Cost'),
            CostForNewPart: $translate.instant('Tooltip_Add_Part_CostForNewPart'),
            PackagedCost: $translate.instant('Add_Part_Tooltip_Package_Cost'),
            PackagedCostForNewPart: $translate.instant('Add_Part_Tooltip_PackagedCostForNewPart'),
            MSRP: $translate.instant('Tooltip_Add_Part_MSRP'),
            Retail: $translate.instant('Tooltip_Add_Part_Retail'),
            Enviro: $translate.instant('Tooltip_Add_Part_Enviro'),
            EnviroFeeCode: $translate.instant('Add_Part_Tooltip_Enviro_Fee_Code'),
            AutoRecorderAt: $translate.instant('Tooltip_Add_Part_AutoRecorderAt'),
            AutoRecorderTo: $translate.instant('Tooltip_Add_Part_AutoRecorderTo'),
            OrderLots: $translate.instant('Tooltip_Add_Part_OrderLots'),
            GeneralInfo: $translate.instant('Tooltip_Add_Part_GeneralInfo'),
            LocationAndQty: $translate.instant('Tooltip_Add_Part_LocationAndQty'),
            PriceAndCost: $translate.instant('Tooltip_Add_Part_PriceAndCost'),
            OrderingInfo: $translate.instant('Tooltip_Add_Part_OrderingInfo'),
            Qty: $translate.instant('Add_Part_Tooltip_Qty'),
            ApplicableTax: $translate.instant('Add_Part_Tooltip_Applicable_Tax'),
            Tag: $translate.instant('Tags'),
            PackageCost: $translate.instant('Add_Part_Tooltip_Package_Cost'),
            PkgUnitOfMeasure: $translate.instant('Add_Part_Tooltip_Pkg_Unit_of_Measure'),
            ItemsPerPackage: $translate.instant('Add_Part_Tooltip_Items_Per_Package'),
            CostingInfo: $translate.instant('Add_Part_Tooltip_CostingInfo'),
            InStockQuantityForNewPart: $translate.instant('Add_Part_Tooltip_InStockQuantityForNewPart'),
            MfgPart: $translate.instant('Mfg_part'),
            SKUNumber: $translate.instant('Stock_unit'),
            PartType: $translate.instant('Part_type')
        };

        $scope.PartCompModal.getPreTaxRetail = function() {
    		return ($scope.PartCompModal.IsTaxIncludingPricing && $scope.PartCompModal.Tax_Rate) ? ($scope.PartCompModal.PartModal.Retail / (1 + $scope.PartCompModal.Tax_Rate / 100)).toFixed(2) : parseFloat($scope.PartCompModal.PartModal.Retail).toFixed(2);
        }
        
        $scope.PartCompModal.getProfitAmount = function () {
        	$scope.PartCompModal.PartModal.Cost = ($scope.PartCompModal.PartModal.Cost ? $scope.PartCompModal.PartModal.Cost : 0);
            return ($scope.PartCompModal.getPreTaxRetail() - $scope.PartCompModal.PartModal.Cost).toFixed(2);
        }
        
        $scope.PartCompModal.getProfitPercent = function () {
            return ($scope.PartCompModal.getPreTaxRetail() == 0 || $scope.PartCompModal.getProfitAmount() == 0) ? 0 : (($scope.PartCompModal.getProfitAmount() / $scope.PartCompModal.getPreTaxRetail()) * 100).toFixed(2);
        }
        
        $scope.PartCompModal.openAddPartPopup = function () {
            $scope.PartCompModal.clearAllData();
            $scope.PartCompModal.getAndSetSystemDefaultCategory();
            $scope.PartCompModal.getActiveFeeList();
            $scope.PartCompModal.getActiveTagList();
            $scope.PartCompModal.currentPartId = null;
            $scope.PartCompModal.disableVendorInputBox = false;
            $scope.PartCompModal.PartModal.Active = true;
            $scope.PartCompModal.openPopup();
        }

        $scope.PartCompModal.resetEnviFeeCodeValue = function () {
            if ($scope.PartCompModal.PartModal.EnviroFee == undefined || $scope.PartCompModal.PartModal.EnviroFee == '' ||
                $scope.PartCompModal.PartModal.EnviroFee == 0) {
                $scope.PartCompModal.PartModal.EnvFeeId = null;
                $scope.PartCompModal.FeeNameStr = '';
            } else {
                $scope.PartCompModal.getDefaultEnvFeeData();
            }
        }

        $scope.PartCompModal.openEditPartPopup = function (partId) {
            $scope.PartCompModal.currentPartId = partId;
            $scope.PartCompModal.disableVendorInputBox = false;
            $scope.PartCompModal.setDataDefault();
            $scope.PartCompModal.getActiveFeeList();
            $scope.PartCompModal.getActiveTagList();
            $scope.PartCompModal.getCurrentPartData();
        }
        $scope.PartCompModal.openAddVOPartPopup = function (vendorName, vendorId) {
            $scope.PartCompModal.clearAllData();
            $scope.PartCompModal.VendorNameStr = vendorName;
            $scope.PartCompModal.PartModal.VendorId = vendorId;
            $scope.PartCompModal.getAndSetSystemDefaultCategory();
            $scope.PartCompModal.getActiveFeeList();
            $scope.PartCompModal.getActiveTagList();
            $scope.PartCompModal.currentPartId = null;
            $scope.PartCompModal.disableVendorInputBox = true;
            $scope.PartCompModal.disableNonInventoryCheckbox = true;
            $scope.PartCompModal.PartModal.Active = true;
            $scope.PartCompModal.openPopup();
        }
        
        $scope.$on('AddPartEvent', function () {
            $scope.PartCompModal.openAddPartPopup();

        });
        $scope.$on('EditPartEvent', function (event, args) {
            $scope.PartCompModal.openEditPartPopup(args.partId);
        });

        $scope.$on('AddPartVOEvent', function (event, args) {
            $scope.PartCompModal.openAddVOPartPopup(args.vendorName, args.vendorId);
        });
        
        $scope.PartCompModal.PartFieldsFilter = {
            PartCategory: [{
                Field: "Type__c",
                Value: "Part",
                FilterObject: "Category__c"
            }],
            EnvFee: [{
                Field: "Active__c",
                Value: true,
                FilterObject: "Fee__c"
            }]
        };

        $scope.PartCompModal.openPopup = function () {
            setTimeout(function () {
                angular.element('#AddNewPart').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
            setTimeout(function () {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            });
        }

        $scope.PartCompModal.closePopup = function () {
            angular.element('#AddNewPart').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }

        /**
         * Event listener when a record is selected from Search bar
         */
        $scope.$on('autoCompleteSelectCallback', function (event, args) {
            var obejctType = args.ObejctType.toUpperCase();
            var searchResult = args.SearchResult;
            var validationKey = args.ValidationKey;
            var objectsMapping = [{
                VENDOR: {
                    Id: "VendorId",
                    Name: "VendorName",
                    selectMethod: $scope.PartCompModal.vendorSelectCallback
                },
                CATEGORY: {
                    Id: "CategoryId",
                    Name: "CategoryName",
                    selectMethod: null
                },
                MERCHANDISE: {
                    Id: "ReplacedById",
                    Name: "ReplacedByName",
                    selectMethod: null
                },
                FEE: {
                    Id: "EnvFeeId",
                    Name: "EnvFeeName",
                    selectMethod: null
                }
            }];

            if (searchResult != null && objectsMapping[0][obejctType] != null) {
                $scope.PartCompModal.PartModal[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                $scope.PartCompModal.PartModal[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
                 if(args.VendorCode) {
                    setVendorPartPricingFields(searchResult.originalObject.AdditionalInfo);
                }
            }
            $scope.PartCompModal.validateFieldWithKey(validationKey);

            if ($scope.PartCompModal.PartFormValidationModal[validationKey].isError == false) {
                if (objectsMapping[0][obejctType].selectMethod != null) {
                    objectsMapping[0][obejctType].selectMethod(searchResult);
                }
            }
        });

        function setVendorPartPricingFields(PartPricingFieldsOfVendor) {
            $scope.PartCompModal.PartPricingFieldsOfVendor.IsCalculatePartRetailPrice = PartPricingFieldsOfVendor.IsCalculatePartRetailPriceFlag;
            $scope.PartCompModal.PartPricingFieldsOfVendor.RetailBaseValue = PartPricingFieldsOfVendor.RetailBaseValue;
            $scope.PartCompModal.PartPricingFieldsOfVendor.RetailRate = PartPricingFieldsOfVendor.RetailRate;
            $scope.PartCompModal.PartPricingFieldsOfVendor.RetailRounding = PartPricingFieldsOfVendor.RetailRounding;
            $scope.PartCompModal.PartPricingFieldsOfVendor.RetailRoundTo = PartPricingFieldsOfVendor.RetailRoundTo;

            if ($scope.PartCompModal.PartPricingFieldsOfVendor.IsCalculatePartRetailPrice) {
                $scope.PartCompModal.PartModal.Retail = caculatePartRetailPrice();
            }
        }

        function caculatePartRetailPrice() {
            var BaseValue; /*Decimal*/
            if ($scope.PartCompModal.PartPricingFieldsOfVendor.RetailBaseValue == 'Item Cost') {
                BaseValue = (!$scope.PartCompModal.PartModal.Cost ? 0 : $scope.PartCompModal.PartModal.Cost);
            } else {
                BaseValue = (!$scope.PartCompModal.PartModal.MSRP ? 0 : $scope.PartCompModal.PartModal.MSRP);
            }
            var RetailRate = parseFloat($scope.PartCompModal.PartPricingFieldsOfVendor.RetailRate);
            var calculatedRetailPrice = parseFloat(BaseValue) + (parseFloat(BaseValue) * parseFloat(RetailRate / 100)); /*Decimal*/
            calculatedRetailPrice = calculatedRetailPrice.toFixed(2);
            if ($scope.PartCompModal.PartPricingFieldsOfVendor.RetailRounding) {
                var RetailRoundingCentValueOnVendor = parseFloat($scope.PartCompModal.PartPricingFieldsOfVendor.RetailRoundTo); /*Decimal*/
                calculatedRetailPrice = applyRoundingToCalculatedRetailPrice(RetailRoundingCentValueOnVendor, calculatedRetailPrice);
            }
            return calculatedRetailPrice;
        }

        function applyRoundingToCalculatedRetailPrice(RetailRoundingCentValue, RetailPriceValue) {
            var RoundingValue = parseFloat(RetailRoundingCentValue / 100);
            var RetailPriceIntegerValue = Math.floor(RetailPriceValue);

            if ((RetailPriceValue - parseFloat(RetailPriceIntegerValue)) > RoundingValue) {
                RetailPriceIntegerValue = parseInt(RetailPriceIntegerValue) + 1;
            }
            var roundedRetailPriceValue = parseFloat(RetailPriceIntegerValue) + RoundingValue;
            return roundedRetailPriceValue;
        }

        $scope.PartCompModal.performActionOnBaseValueChange = function (pricingMethod) {
            if ($scope.PartCompModal.PartPricingFieldsOfVendor.IsCalculatePartRetailPrice && (pricingMethod == $scope.PartCompModal.PartPricingFieldsOfVendor.RetailBaseValue)) {
                $scope.PartCompModal.PartModal.Retail = caculatePartRetailPrice();
            }
        }

        /**
         * Method to clear all form fields and set default values
         */
        $scope.PartCompModal.clearAllData = function () {
            $scope.PartCompModal.PartModal = {};
            $scope.PartCompModal.PartLocations = [{
                nameVal: "",
                show: true
            }];
            $scope.PartCompModal.PartModal.AssignedTags = [];
            $scope.PartCompModal.setDataDefault();
        }

        /**
         * Set form Values from record and validations for popup
         */
        $scope.PartCompModal.setRecordData = function () {
            if ($scope.PartCompModal.PartModal.VendorName != null) {
                $scope.PartCompModal.VendorNameStr = $scope.PartCompModal.PartModal.VendorName;
            }
            if ($scope.PartCompModal.PartModal.EnvFeeName != null) {
                $scope.PartCompModal.FeeNameStr = $scope.PartCompModal.PartModal.EnvFeeName;
            }
            if ($scope.PartCompModal.PartModal.CategoryName != null) {
                $scope.PartCompModal.CategoryNameStr = $scope.PartCompModal.PartModal.CategoryName;
            }
            if ($scope.PartCompModal.PartModal.ReplacedByName != null) {
                $scope.PartCompModal.ReplacedByNameStr = $scope.PartCompModal.PartModal.ReplacedByName;
            }

            var partLocations = $scope.PartCompModal.PartModal.Location;
            if (partLocations != null) {
                $scope.PartCompModal.PartLocations = [];
                var locationsArr = partLocations.split(";");
                for (i = 0; i < locationsArr.length; i++) {
                    if (locationsArr[i] != null && locationsArr[i].trim().length != 0) {
                        $scope.PartCompModal.PartLocations.push({
                            nameVal: locationsArr[i].trim(),
                            show: false
                        });
                    }
                }
            }

            if ($scope.PartCompModal.PartLocations.length == 0) {
                $scope.PartCompModal.PartLocations = [{
                    nameVal: "",
                    show: true
                }];
            }
            $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 1].show = true;
        }

        /**
         * Set default data for new
         */
        $scope.PartCompModal.setDataDefault = function () {
            $scope.PartCompModal.setDefaultValidationModel();

            $scope.PartCompModal.CategoryNameStr = "";
            $scope.PartCompModal.VendorNameStr = "";
            $scope.PartCompModal.FeeNameStr = "";
            $scope.PartCompModal.TagNameStr = "";
            $scope.PartCompModal.ReplacedByNameStr = "";
            $scope.PartCompModal.PartModal.IsTaxable = true;
            $scope.PartCompModal.PartModal.IsOrderLot = false;
            $scope.PartCompModal.PartModal.IsPackagedPart = false;
            $scope.PartCompModal.PartModal.MfgPart = "";
            $scope.PartCompModal.PartModal.SKUNumber = "";
            $scope.PartCompModal.PartModal.PartType = "Part";
            $scope.PartCompModal.PartModal.IsNonInventoryPart = false;
            $scope.PartCompModal.disableSaveButton = false;
            $scope.PartCompModal.setDefaultForNumberFields();
            $scope.PartCompModal.isAlreadyFocusedOnTagInput = false;
        }

        $scope.PartCompModal.setDefaultForNonInventoryPart = function () {
            $scope.PartCompModal.PartModal.InStockQty = 0;
            $scope.PartCompModal.PartModal.IsPackagedPart = false;
            $scope.PartCompModal.PartModal.IsOrderLot = false;
            $scope.PartCompModal.PartModal.AutoReorderAt = 0;
            $scope.PartCompModal.PartModal.AutoReorderTo = 0;
            $scope.PartCompModal.PartModal.Cost = 0;
        }

        $scope.PartCompModal.setDefaultForNumberFields = function () {

            if ($scope.PartCompModal.PartModal.OrderLots == null || $scope.PartCompModal.PartModal.OrderLots == "") {
                $scope.PartCompModal.PartModal.OrderLots = 1;
            }
            if ($scope.PartCompModal.PartModal.InStockQty == null || $scope.PartCompModal.PartModal.InStockQty == "") {
                $scope.PartCompModal.PartModal.InStockQty = 0;
            }
            if ($scope.PartCompModal.PartModal.PackagedUnit == null || $scope.PartCompModal.PartModal.PackagedUnit == "") {
                $scope.PartCompModal.PartModal.PackagedUnit = 'PKG';
            }
            if ($scope.PartCompModal.PartModal.Cost == null || $scope.PartCompModal.PartModal.Cost == "") {
                $scope.PartCompModal.PartModal.Cost = 0;
            }
            if ($scope.PartCompModal.PartModal.PackagedCost == null || $scope.PartCompModal.PartModal.PackagedCost == "") {
                $scope.PartCompModal.PartModal.PackagedCost = 0;
            }
            if ($scope.PartCompModal.PartModal.MSRP == null || $scope.PartCompModal.PartModal.MSRP == "") {
                $scope.PartCompModal.PartModal.MSRP = 0;
            }
            if ($scope.PartCompModal.PartModal.Retail == null || $scope.PartCompModal.PartModal.Retail == "") {
                $scope.PartCompModal.PartModal.Retail = 0;
            }
            if ($scope.PartCompModal.PartModal.EnviroFee == null || $scope.PartCompModal.PartModal.EnviroFee == "") {
                $scope.PartCompModal.PartModal.EnviroFee = 0;
            }
            if ($scope.PartCompModal.PartModal.PackagedQty == null || $scope.PartCompModal.PartModal.PackagedQty == "") {
                $scope.PartCompModal.PartModal.PackagedQty = 1;
            }
            if ($scope.PartCompModal.PartModal.AutoReorderAt == null || $scope.PartCompModal.PartModal.AutoReorderAt == "") {
                $scope.PartCompModal.PartModal.AutoReorderAt = 0;
            }
            if ($scope.PartCompModal.PartModal.AutoReorderTo == null || $scope.PartCompModal.PartModal.AutoReorderTo == "") {
                $scope.PartCompModal.PartModal.AutoReorderTo = 0;
            }
        }

        $scope.PartCompModal.CancelPartForm = function (event) {
            $scope.PartCompModal.closePopup();
        }

        $scope.PartCompModal.SavePartForm = function (event) {
            $scope.PartCompModal.isValidForm = true;
            $scope.PartCompModal.PartModal.Location = $scope.PartCompModal.joinAndAssignLocationValues();
            $scope.PartCompModal.setDefaultForNumberFields();
            if ($scope.PartCompModal.PartModal.IsNonInventoryPart) {
                $scope.PartCompModal.setDefaultForNonInventoryPart();
            }

            $scope.PartCompModal.validateForm();
            if ($scope.PartCompModal.isValidForm) {
                var partRecords = [];
                partRecords.push($scope.PartCompModal.PartModal);

                $scope.PartCompModal.savePartData(partRecords);
            }
        }

        $scope.PartCompModal.onClickOrderLot = function (event) {
            $scope.PartCompModal.PartModal.IsOrderLot = !$scope.PartCompModal.PartModal.IsOrderLot;

        }

        $scope.PartCompModal.onClickPackagedPart = function (event) {
            $scope.PartCompModal.PartModal.IsPackagedPart = !$scope.PartCompModal.PartModal.IsPackagedPart;
            if ($scope.PartCompModal.PartModal.IsPackagedPart == true) {
                $scope.PartCompModal.PartModal.PackagedUnit = 'PKG';
                $scope.PartCompModal.PartModal.PackagedQty = 1;
                $scope.PartCompModal.PartModal.PackagedCost = $scope.PartCompModal.PartModal.Cost;
            } else {
                $scope.PartCompModal.PartModal.PackagedCost = 0;
                $scope.PartCompModal.PartModal.PackagedQty = 1;
            }
        }

        $scope.PartCompModal.onClickTaxable = function (event) {
            if ($scope.PartCompModal.currentPartId == null || ($scope.PartCompModal.currentPartId != null && $rootScope.GroupOnlyPermissions['Sales Taxes']['assign'])) {
                $scope.PartCompModal.PartModal.IsTaxable = !$scope.PartCompModal.PartModal.IsTaxable;
            }
        }

        $scope.PartCompModal.onClickNonInventoryPart = function () {
            if (!$scope.PartCompModal.disableNonInventoryCheckbox) {
                if ($scope.PartCompModal.currentPartId != null) {
                    $scope.PartCompModal.disableSaveButton = true;
                    AddEditPartService.isNonInventoryFieldEditable($scope.PartCompModal.currentPartId).then(function (successfulSearchResult) {
                        if (successfulSearchResult.isAllowed) {
                            $scope.PartCompModal.PartModal.IsNonInventoryPart = !$scope.PartCompModal.PartModal.IsNonInventoryPart;
                        } else {
                            Notification.error($translate.instant('Update_Part_Checkbox'));
                        }
                        $scope.PartCompModal.disableSaveButton = false;
                    }, function (errorSearchResult) {
                    	//FIXME
                    });
                } else {
                    $scope.PartCompModal.PartModal.IsNonInventoryPart = !$scope.PartCompModal.PartModal.IsNonInventoryPart;
                }
            } else {
                Notification.error($translate.instant('Cannot_Add_Non_Inventory_Part_On_Vendor_Order'));
            }
        }

        $scope.PartCompModal.onSelectActive = function () {
            if ($scope.PartCompModal.currentPartId != null) {
                $scope.PartCompModal.disableSaveButton = true;
                AddEditPartService.isNonInventoryFieldEditable($scope.PartCompModal.currentPartId).then(function (successfulSearchResult) {
                    if (successfulSearchResult.isAllowed) {
                        $scope.PartCompModal.PartModal.Active = !$scope.PartCompModal.PartModal.Active;
                    } else {
                        Notification.error($translate.instant('Update_Part_Checkbox'));
                    }
                    $scope.PartCompModal.disableSaveButton = false;
                }, function (errorSearchResult) {
                	//FIXME
                });
            } else {
                $scope.PartCompModal.PartModal.Active = !$scope.PartCompModal.PartModal.Active;
            }
        }

        /**
         * Event handler for First Location field validation (Required)
         */
        $scope.PartCompModal.validateFirstLocationField = function (event) {
            var locationVal = $scope.PartCompModal.PartLocations[0].nameVal;
            if (locationVal.trim().length == 0) {
                $scope.PartCompModal.PartLocations[0].nameVal = "";
                $scope.PartCompModal.PartFormValidationModal["Location"].isError = true;
                $scope.PartCompModal.PartFormValidationModal["Location"].ErrorMessage = $translate.instant('Field_Is_Required');
            } else {
                $scope.PartCompModal.PartFormValidationModal["Location"].isError = false;
                $scope.PartCompModal.PartFormValidationModal["Location"].ErrorMessage = '';
            }
        }

        /**
         * Event handler for Location field validation for unique value
         */
        $scope.PartCompModal.validateLocationUniqueness = function (event) {
            var locationVal = $scope.PartCompModal.PartLocations[0].nameVal;
            if (locationVal.trim().length != 0) {
                $scope.PartCompModal.PartFormValidationModal["Location"].isError = false;
                $scope.PartCompModal.PartFormValidationModal["Location"].ErrorMessage = '';
            }
            // First reset the error box
            $scope.PartCompModal.addRemoveErrorClassOnLocationField(false, null);

            if ($scope.PartCompModal.PartLocations.length > 1 &&
                !$scope.PartCompModal.isLastLocationEmpty() &&
                $scope.PartCompModal.isLastLocationAlreadyExists()
            ) {
                $scope.PartCompModal.addRemoveErrorClassOnLocationField(true, $scope.PartCompModal.PartLocations.length - 1);
            }
        }

        $scope.PartCompModal.vendorSelectCallback = function (searchResult) {
            $scope.PartCompModal.getAndSetDefaultCategory();
        }

        $scope.PartCompModal.onBlurPackageCost = function () {
            if ($scope.PartCompModal.PartModal.IsPackagedPart) {
                if ($scope.PartCompModal.PartModal.PackagedCost != null &&
                    $scope.PartCompModal.PartModal.PackagedQty != null &&
                    $scope.PartCompModal.PartModal.PackagedQty != "" &&
                    $scope.PartCompModal.PartModal.PackagedQty != 0) {
                    $scope.PartCompModal.PartModal.Cost = ($scope.PartCompModal.PartModal.PackagedCost / $scope.PartCompModal.PartModal.PackagedQty).toFixed(2);
                }
            }
        }

        $scope.PartCompModal.packageCostCallback = function () {
            if ($scope.PartCompModal.PartModal.IsPackagedPart) {
                if ($scope.PartCompModal.PartModal.PackagedCost != null &&
                    $scope.PartCompModal.PartModal.PackagedQty != null &&
                    $scope.PartCompModal.PartModal.PackagedQty != "" &&
                    $scope.PartCompModal.PartModal.PackagedQty != 0) {
                    $scope.PartCompModal.PartModal.PackagedCost = ($scope.PartCompModal.PartModal.PackagedQty * $scope.PartCompModal.PartModal.Cost).toFixed(2);
                }
            }
        }

        $scope.PartCompModal.adjustTabIndex = function (e) {
            if (e.which == 9) {
                $('#partNumber').focus();
                e.preventDefault();
            }
        }

        $scope.PartCompModal.formFieldJustGotFocus = function (Value) {
            showToolTip(Value);
        }
        $scope.PartCompModal.OnFocus = function (targetId) {
            angular.element('.controls').hide();
            angular.element('#' + targetId).show();

        }

        /**
         * Add a new location to modal
         */
        $scope.PartCompModal.addLocationInput = function (index) {
            if ($scope.PartCompModal.isLastLocationEmpty() || $scope.PartCompModal.isLastLocationAlreadyExists()) {
                var elemId = "#pLocation" + ($scope.PartCompModal.PartLocations.length - 1);
                angular.element(elemId).focus();

                return;
            } else {
                $scope.PartCompModal.PartLocations.push({
                    nameVal: "",
                    show: true
                });
                $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 2].show = false;
            }

            setTimeout(function () {
                var elemId = "#pLocation" + (index + 1);
                angular.element(elemId).parent().css("margin-top", "10px");
                angular.element(elemId).focus();
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 10);
        }

        /**
         * delete the location value from modal from specified index
         */
        $scope.PartCompModal.delLocationInput = function (index) {
            if (index == 0) {
                $scope.PartCompModal.PartLocations[0].nameVal = "";
                var elemId = "#pLocation" + (index);
                angular.element(elemId).focus();
                return;
            }

            if (index == $scope.PartCompModal.PartLocations.length - 1) {
                $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 2].show = true;
            }
            $scope.PartCompModal.PartLocations.splice(index, 1);

            var elemId = "#pLocation" + (index - 1);
            angular.element(elemId).focus();
        }
        
        /**
         * Method to check if last location value is empty or not
         * Return true if last location value is empty
         */
        $scope.PartCompModal.isLastLocationEmpty = function () {
            var lastLocationVal = $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 1].nameVal.toString();
            if (lastLocationVal == null) {
                return true;
            } else if (lastLocationVal.trim().length == 0) {
                $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 1].nameVal = lastLocationVal.trim();
                return true;
            } else {
                return false;
            }
        }

        /**
         * Method to check if any location already exists in locations boxes
         * Return true if existing location value found
         */
        $scope.PartCompModal.isLastLocationAlreadyExists = function () {
            var lastLocationVal = $scope.PartCompModal.PartLocations[$scope.PartCompModal.PartLocations.length - 1].nameVal;
            var duplicateLocationValue = false;

            for (i = 0; i < $scope.PartCompModal.PartLocations.length - 1; i++) {
                duplicateLocationValue = angular.equals(lastLocationVal, $scope.PartCompModal.PartLocations[i].nameVal);
                if (duplicateLocationValue == true) {
                    break;
                }
            }
            // If this one is a duplicate entry, then add an error message
            if (duplicateLocationValue) {
                $scope.PartCompModal.addRemoveErrorClassOnLocationField(true, $scope.PartCompModal.PartLocations.length - 1);
            }

            return duplicateLocationValue;
        }

        /**
         * Method to join all location values by a delimiter (";")
         * And assign the location value to part location value
         */
        $scope.PartCompModal.joinAndAssignLocationValues = function () {
            var joinedLocations = "";

            for (i = 0; i < $scope.PartCompModal.PartLocations.length; i++) {
                joinedLocations += $scope.PartCompModal.PartLocations[i].nameVal + ";";
            }
            joinedLocations = joinedLocations.substring(0, joinedLocations.length - 1);
            return joinedLocations;
        }

        /**
         * Method to add/remove error class on location field with index value and error message
         */
        $scope.PartCompModal.addRemoveErrorClassOnLocationField = function (isError, indexVal) {
            var duplicateLocationTitle = "Duplicate location value";
            if (isError) {
                var currentElem = angular.element(document.querySelector('#pLocation' + indexVal));
                currentElem.addClass("redborder");
                currentElem.attr("title", duplicateLocationTitle);
            } else {
                var currentElem = angular.element(document.querySelector('[title="' + duplicateLocationTitle + '"]'));
                currentElem.removeClass("redborder");
                currentElem.removeAttr("title");
            }
        }

        $scope.PartCompModal.validateForm = function () {
            angular.forEach($scope.PartCompModal.PartFormValidationModal, function (value, key) {
                $scope.PartCompModal.validateFieldWithKey(key);
                if ($scope.PartCompModal.PartFormValidationModal[key].isError) {
                    $scope.PartCompModal.isValidForm = false;
                }
            });
        }

        $scope.PartCompModal.validateFieldWithKey = function (modelKey) {
            var fieldValue = $scope.PartCompModal.PartModal[modelKey];
            var numericRegex = /^[0-9]*$/;
            var validateType = $scope.PartCompModal.PartFormValidationModal[modelKey].Type;

            if (validateType.indexOf('Numeric') > -1) {
                if (fieldValue != '' && fieldValue != undefined && !numericRegex.test(fieldValue)) {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('Invalid_Field_Value');
                } else {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                }
            }

            if (validateType.indexOf('AllowSpaces') > -1) {
                if (fieldValue != '' && fieldValue != undefined && (fieldValue.trim()).indexOf(' ') > -1) {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('SKU_error_on_whitespace');
                } else {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                }
            }

            if (validateType.indexOf('Required') > -1) {
                if (fieldValue == undefined || fieldValue == null || $scope.PartCompModal.PartModal[modelKey] == '') {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                } else {
                    $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                    $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                }
                if (modelKey.indexOf('EnvFeeId') > -1 && $scope.PartCompModal.PartFormValidationModal[modelKey].isError) {
                    if ($scope.PartCompModal.PartModal.EnviroFee == null || $scope.PartCompModal.PartModal.EnviroFee == undefined ||
                        $scope.PartCompModal.PartModal.EnviroFee == 0) {
                        $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                        $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                    }
                }
            }

            if (validateType.indexOf('OrderLots') > -1) {
                if (fieldValue == 'undefined' || fieldValue == null || fieldValue.length == 0) {} else {
                    if (fieldValue < 1) {
                        $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                        $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('Field_Is_Required');
                    } else {
                        $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                        $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                    }

                }
            }

            if (validateType.indexOf('AutoReorderTo') > -1) {
                if (fieldValue == 'undefined' || fieldValue == null || fieldValue.length == 0) {
                    //FIXME
                } else {
                    if (typeof $scope.PartCompModal.PartModal.AutoReorderAt == 'undefined' || $scope.PartCompModal.PartModal.AutoReorderAt == null) {

                        if (fieldValue != 'undefined' && AutoReorderAt != null) {
                            $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                            $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('First_Fill_ReorderAt');
                        }
                    } else if (parseInt($scope.PartCompModal.PartModal.AutoReorderTo) < parseInt($scope.PartCompModal.PartModal.AutoReorderAt)) {
                        $scope.PartCompModal.PartFormValidationModal[modelKey].isError = true;
                        $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = $translate.instant('ReorderTo_Must_Gretaer_Than_ReOrderAt');
                    } else {
                        $scope.PartCompModal.PartFormValidationModal[modelKey].isError = false;
                        $scope.PartCompModal.PartFormValidationModal[modelKey].ErrorMessage = '';
                    }

                }
            }

            if (modelKey == 'Location') {
                $scope.PartCompModal.PartFormValidationModal["Location"].isError = false;
                $scope.PartCompModal.PartFormValidationModal["Location"].ErrorMessage = '';
            }
            if ($scope.PartCompModal.PartFormValidationModal[modelKey].isError == true) {
                $scope.PartCompModal.isValidForm = false;
            }

        }
        $scope.PartCompModal.getCurrentPartData = function () {
            AddEditPartService.getApplicableTaxList().then(function (taxList) {
                $scope.PartCompModal.IsTaxIncludingPricing = taxList.IsTaxIncludingPricing;
                $scope.PartCompModal.TaxList = taxList.SalesTaxList;
                AddEditPartService.getPartInfoById($scope.PartCompModal.currentPartId).then(function (partRecord) {
                    $scope.PartCompModal.UpdateFormFieldsWithExistingPart(partRecord);
                    $scope.PartCompModal.getAndSetDefaultCategory(true);
                    var defaultTaxIndex = _.findIndex(taxList.SalesTaxList, {
                        IsDefault: true
                    });
                    var TaxIndex = _.findIndex(taxList.SalesTaxList, {
                        Id: $scope.PartCompModal.PartModal.ApplicableTaxId
                    });
                    if (TaxIndex > -1 && $scope.PartCompModal.PartModal.ApplicableTaxId != null) {
                        $scope.PartCompModal.Tax_Rate = $scope.PartCompModal.TaxList[TaxIndex].TaxRate;
                    }
                    if (defaultTaxIndex > -1 && $scope.PartCompModal.PartModal.ApplicableTaxId == null) {
                        $scope.PartCompModal.PartModal.ApplicableTaxId = $scope.PartCompModal.TaxList[defaultTaxIndex].Id;
                        $scope.PartCompModal.Tax_Rate = $scope.PartCompModal.TaxList[defaultTaxIndex].TaxRate;
                    }
                    $scope.PartCompModal.getDefaultEnvFeeData();
                }, function (errorSearchResult) {

                });
            }, function (errorSearchResult) {
                //FIXME
            });
        }

        /**
         * Get default category for part as selected vendor value
         */
        $scope.PartCompModal.getAndSetDefaultCategory = function (isCalledFromEditDirectly) {
            AddEditPartService.getDefaultPartByVendorId($scope.PartCompModal.PartModal.VendorId).then(function (categoryRecord) {
            	$scope.PartCompModal.PartTypeList = ['Part', 'Merchandise'];
                $scope.PartCompModal.UpdateCategoryInForm(categoryRecord, $scope.PartCompModal.PartModal.VendorId,isCalledFromEditDirectly);
            }, function (errorSearchResult) {
                //FIXME
            });
        }

        $scope.PartCompModal.getAndSetSystemDefaultCategory = function () {
            AddEditPartService.getDefaultPartByVendorId('').then(function (categoryRecord) {
                $scope.PartCompModal.UpdateCategoryInForm(categoryRecord, $scope.PartCompModal.PartModal.VendorId);
            }, function (errorSearchResult) {
            	//FIXME
            });

            AddEditPartService.getApplicableTaxList().then(function (taxList) {
                $scope.PartCompModal.IsTaxIncludingPricing = taxList.IsTaxIncludingPricing;
                $scope.PartCompModal.TaxList = taxList.SalesTaxList;
                var defaultTaxIndex = _.findIndex(taxList.SalesTaxList, {
                    IsDefault: true
                });
                if (defaultTaxIndex > -1) {
                    $scope.PartCompModal.PartModal.ApplicableTaxId = $scope.PartCompModal.TaxList[defaultTaxIndex].Id;
                    $scope.PartCompModal.Tax_Rate = $scope.PartCompModal.TaxList[defaultTaxIndex].TaxRate;
                }
            }, function (errorSearchResult) {
            	//FIXME
            });

            $scope.PartCompModal.getDefaultEnvFeeData();
        }

        /**
         * Keyboard Handling of Tags autocomplete
         */
        $scope.PartCompModal.changeSeletedTag = function (event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.PartCompModal.FilteredTagList.length - 1) > $scope.PartCompModal.currentSelectedTagIndex) {
                    $scope.PartCompModal.currentSelectedTagIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.PartCompModal.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.PartCompModal.currentSelectedTagIndex > 0) {
                    $scope.PartCompModal.currentSelectedTagIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.PartCompModal.currentSelectedTagIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
                $scope.PartCompModal.selectTag($scope.PartCompModal.FilteredTagList[$scope.PartCompModal.currentSelectedTagIndex]);
                $scope.PartCompModal.currentSelectedTagIndex = -1;
                $scope.PartCompModal.closeAutocomplete('applicableTaxId');
            }
        }

        $scope.PartCompModal.changeSeletedEnvFee = function (event) {
            var keyCode = event.which ? event.which : event.keyCode;
            if (keyCode === 40) {
                if (($scope.PartCompModal.FilteredEnvFeeList.length - 1) > $scope.PartCompModal.currentSelectedEnvFeeIndex) {
                    $scope.PartCompModal.currentSelectedEnvFeeIndex++;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.PartCompModal.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 38) {
                if ($scope.PartCompModal.currentSelectedEnvFeeIndex > 0) {
                    $scope.PartCompModal.currentSelectedEnvFeeIndex--;
                    angular.element('#autocompleteScrollDiv')[0].scrollTop = angular.element('#tag_' + $scope.PartCompModal.currentSelectedEnvFeeIndex)[0].offsetTop - 100;
                }
            } else if (keyCode === 13) {
                $scope.PartCompModal.selectFee($scope.PartCompModal.FilteredEnvFeeList[$scope.PartCompModal.currentSelectedEnvFeeIndex]);
                $scope.PartCompModal.currentSelectedEnvFeeIndex = -1;
                $scope.PartCompModal.closeAutocomplete('stampDutyRate');
            }
        }

        $scope.PartCompModal.closeAutocomplete = function (eleId) {
            angular.element('#' + eleId).focus();
        }

        $scope.PartCompModal.resetEnvFeeId = function () {
            if ($scope.PartCompModal.FeeNameStr == null || $scope.PartCompModal.FeeNameStr == '' || $scope.PartCompModal.FeeNameStr == undefined) {
                $scope.PartCompModal.PartModal.EnvFeeId = null;
            }
        }

        $scope.PartCompModal.selectFee = function (selectedFee) {
            $scope.PartCompModal.PartModal.EnvFeeId = selectedFee.Id;
            $scope.PartCompModal.FeeNameStr = selectedFee.ItemDesc;
        };

        $scope.PartCompModal.getActiveFeeList = function () {
            AddEditPartService.getActiveFeeList().then(function (feeList) {
                $scope.PartCompModal.ActiveFeeList = feeList;
            }, function (errorSearchResult) {
            	//FIXME
            });
        }

        $scope.PartCompModal.onFocusOnTagInput = function () {
            $scope.PartCompModal.isFocused = true;
            if (!$scope.PartCompModal.isAlreadyFocusedOnTagInput) {
                $scope.PartCompModal.isAlreadyFocusedOnTagInput = true;
                $scope.PartCompModal.resetTagList();
            }
        }

        $scope.PartCompModal.resetTagList = function () {
            for (var i = 0; i < $scope.PartCompModal.PartModal.AssignedTags.length; i++) {
                var index = _.findIndex($scope.PartCompModal.ActiveTagList, {
                    Name: $scope.PartCompModal.PartModal.AssignedTags[i]
                });
                if (index > -1) {
                    $scope.PartCompModal.ActiveTagList.splice(index, 1);
                }
            }
        }

        $scope.PartCompModal.selectTag = function (tagObj) {
            var index = _.findIndex($scope.PartCompModal.ActiveTagList, {
                Name: tagObj.Name
            });
            if (index > -1) {
                if ($scope.PartCompModal.PartModal.AssignedTags.length < 20) {
                    $scope.PartCompModal.PartModal.AssignedTags.push(tagObj.Name);
                    $scope.PartCompModal.ActiveTagList.splice(index, 1);
                } else {
                    Notification.error($translate.instant('Cannot add more than 20 tags'));
                }
            }
            $scope.PartCompModal.TagNameStr = '';
        };

        $scope.PartCompModal.removeTag = function (tagObj, index) {
            if (index > -1) {
                $scope.PartCompModal.PartModal.AssignedTags.splice(index, 1);
                $scope.PartCompModal.ActiveTagList.push({
                    Name: tagObj,
                    Id: tagObj
                });
            }
        };

        $scope.PartCompModal.getActiveTagList = function () {
            AddEditPartService.getActiveTagList().then(function (tagList) {
                $scope.PartCompModal.ActiveTagList = tagList;
            }, function (errorSearchResult) {
            	//FIXME
            });
        }

        $scope.PartCompModal.getDefaultEnvFeeData = function () {
            if ($scope.PartCompModal.PartModal.EnvFeeId == null || $scope.PartCompModal.PartModal.EnvFeeId == undefined) {
                if ($scope.PartCompModal.PartModal.DefaultEnvFeeId == null || $scope.PartCompModal.PartModal.DefaultEnvFeeId == undefined) {
                    var defaultFeeIndex = _.findIndex($scope.PartCompModal.ActiveFeeList, {
                        IsDefault: true
                    });
                    if (defaultFeeIndex > -1) {
                        $scope.PartCompModal.PartModal.DefaultEnvFeeName = $scope.PartCompModal.ActiveFeeList[defaultFeeIndex].ItemDesc;
                        $scope.PartCompModal.PartModal.DefaultEnvFeeId = $scope.PartCompModal.ActiveFeeList[defaultFeeIndex].Id;
                        $scope.PartCompModal.PartModal.EnvFeeName = $scope.PartCompModal.PartModal.DefaultEnvFeeName;
                        $scope.PartCompModal.PartModal.EnvFeeId = $scope.PartCompModal.PartModal.DefaultEnvFeeId;
                        $scope.PartCompModal.FeeNameStr = $scope.PartCompModal.PartModal.EnvFeeName;
                    }
                } else {
                    $scope.PartCompModal.PartModal.EnvFeeName = $scope.PartCompModal.PartModal.DefaultEnvFeeName;
                    $scope.PartCompModal.PartModal.EnvFeeId = $scope.PartCompModal.PartModal.DefaultEnvFeeId;
                    $scope.PartCompModal.FeeNameStr = $scope.PartCompModal.PartModal.EnvFeeName;
                }
            }
        }

        $scope.PartCompModal.changeApplicableTax = function () {
            var selectedTaxIndex = _.findIndex($scope.PartCompModal.TaxList, {
                Id: $scope.PartCompModal.PartModal.ApplicableTaxId
            });
            if (selectedTaxIndex > -1) {
                $scope.PartCompModal.Tax_Rate = $scope.PartCompModal.TaxList[selectedTaxIndex].TaxRate;
            }
        }

        /**
         * Method to Save part record data
         */
        $scope.PartCompModal.savePartData = function (partJSON) {
            if ($scope.PartCompModal.disableSaveButton) {
                return;
            }
            $scope.PartCompModal.disableSaveButton = true;
            AddEditPartService.savePartInfo(partJSON).then(function (partId) {
                if (partId == 1001) {
                    Notification.error($translate.instant('Cannot_Replace_With_Same_Part_Select_Another_Part'));
                    $scope.PartCompModal.disableSaveButton = false;
                    return;
                } else if (partId == 1002) {
                    Notification.error($translate.instant('Part_Already_Exits'));
                    $scope.PartCompModal.disableSaveButton = false;
                    return;
                }

                if ($scope.$parent.partRecordSaveCallback != undefined) {
                    $scope.$parent.partRecordSaveCallback();
                }

                Notification.success($translate.instant('Part_Saved_Successfully'));
                $scope.PartCompModal.disableSaveButton = false;
                angular.element('#AddNewPart').modal('hide');
                hideModelWindow();
                loadState($state, 'ViewPart', {
                    Id: partId
                });
            }, function (errorSearchResult) {
                $scope.PartCompModal.disableSaveButton = false;
            });
        }
        $scope.PartCompModal.CategoryMap = { Part: {}, Merchandise: {} };
        /**
         * Set default category in form
         */
        $scope.PartCompModal.UpdateCategoryInForm = function (categoryRecord, IsVendorSelected,isCalledFromEditDirectly) {
        	if(IsVendorSelected) {
        		if(!categoryRecord.IsMerchandisePurchases) {
        			$scope.PartCompModal.PartTypeList.splice(1,1);
            	} else if(!categoryRecord.IsPartPurchases) {
            		$scope.PartCompModal.PartTypeList.splice(0,1);
        		}
        		if(!isCalledFromEditDirectly){  
        			$scope.PartCompModal.PartModal.PartType = $scope.PartCompModal.PartTypeList.length > 0 ? $scope.PartCompModal.PartTypeList[0]:''; 
        		}
        		$scope.PartCompModal.CategoryMap.Part = {CategoryId: categoryRecord.DefaultPartCategoryId, CategoryName: categoryRecord.DefaultPartCategoryName};
        		$scope.PartCompModal.CategoryMap.Merchandise = {CategoryId: categoryRecord.DefaultMerchandiseCategoryId, CategoryName: categoryRecord.DefaultMerchandiseCategoryName};
    		} else {
    			$scope.PartCompModal.PartModal.CategoryId = categoryRecord.DefaultPartCategoryId;
    			$scope.PartCompModal.PartModal.CategoryName = categoryRecord.DefaultPartCategoryName;
    			$scope.PartCompModal.CategoryNameStr = categoryRecord.DefaultPartCategoryName;
			}
        	if(!isCalledFromEditDirectly){
        		$scope.PartCompModal.changePartTypeCategory();
        	}
        }

        /**
         * Set all the form fields with existing Part record
         */
        $scope.PartCompModal.UpdateFormFieldsWithExistingPart = function (partRecord) {
            $scope.PartCompModal.PartModal = partRecord[0];
            var PartPricingFieldsOfVendor = {
                'IsCalculatePartRetailPriceFlag': $scope.PartCompModal.PartModal.IsCalculatePartRetailPriceOnVendor,
                'RetailBaseValue': $scope.PartCompModal.PartModal.RetailBaseValueOnVendor,
                'RetailRate': $scope.PartCompModal.PartModal.RetailRateOnVendor,
                'RetailRounding': $scope.PartCompModal.PartModal.RetailRoundingFlagOnVendor,
                'RetailRoundTo': $scope.PartCompModal.PartModal.RetailRoundingCentValueOnVendor
            }
            setVendorPartPricingFields(PartPricingFieldsOfVendor);
            $scope.PartCompModal.setRecordData();
            $scope.PartCompModal.openPopup();
        }

        $scope.PartCompModal.initialize = function () {
            var currentdate = new Date();
            var datetime = "Last Sync: " + currentdate.getDate() + "/" +
                (currentdate.getMonth() + 1) + "/" +
                currentdate.getFullYear() + " @ " +
                currentdate.getHours() + ":" +
                currentdate.getMinutes() + ":" +
                currentdate.getSeconds();
        }

        $scope.PartCompModal.openPartPopup = function () {
            if ($state.current.name === 'ViewPart.EditPart') {
                var partId = $stateParams.EditPartParams.Id;
            }
            if (partId != undefined && partId != null && partId != '') {
                $scope.PartCompModal.openEditPartPopup(partId);
            } else {
                $scope.PartCompModal.openAddPartPopup();
            }
        }
        $scope.PartCompModal.PartTypeList = ['Part', 'Merchandise'];
        $scope.PartCompModal.changePartTypeCategory = function() {
        	$scope.PartCompModal.PartModal.CategoryId = $scope.PartCompModal.CategoryMap[$scope.PartCompModal.PartModal.PartType].CategoryId;
            $scope.PartCompModal.PartModal.CategoryName = $scope.PartCompModal.CategoryMap[$scope.PartCompModal.PartModal.PartType].CategoryName;
            $scope.PartCompModal.CategoryNameStr = $scope.PartCompModal.CategoryMap[$scope.PartCompModal.PartModal.PartType].CategoryName;
            
        }
        $scope.PartCompModal.openPartPopup();
        $scope.PartCompModal.initialize();
    }])
});