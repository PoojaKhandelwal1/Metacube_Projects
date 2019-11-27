define(['Routing_AppJs_PK', 'moment', 'JqueryUI', 'UnitOrderingServices', 'AddEditUnitServices', 'underscore_min', 'NumberOnlyInput_New','UnitSpecification'], function (Routing_AppJs_PK, moment, JqueryUI, UnitOrderingServices, AddEditUnitServices, underscore_min, NumberOnlyInput_New,UnitSpecification) {

    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditUnitOrderCtrl', ['$scope', '$stateParams', '$state', 'UnitOrderingService', 'VINOperationsService', '$compile', '$rootScope','$translate','UnitReceivingServices',
        function ($scope, $stateParams, $state, UnitOrderingService, VINOperationsService, $compile, $rootScope, $translate,UnitReceivingServices) {

            var Notification = injector1.get("Notification");
            $scope.M_AddEditUO = $scope.M_AddEditUO || {};
            $scope.F_AddEditUO = $scope.F_AddEditUO || {};
            $scope.M_AddEditUO.showMakeList = false;
            $scope.M_AddEditUO.showModelList = false; 
            $scope.M_AddEditUO.showSubModelList = false;
            $scope.M_AddEditUO.showExteriorcolourlList = false;
            $scope.M_AddEditUO.isUnSavedChanges = false;
            $scope.M_AddEditUO.showFactoryOptionRec = false;
            $scope.M_AddEditUO.isEditMode = true;
            $scope.M_AddEditUO.Years = [];
            $scope.M_AddEditUO.unitRecWrapper = {};
            $scope.M_AddEditUO.unitRec = {};
            $scope.M_AddEditUO.isEdit = -1;
            $scope.M_AddEditUO.totalPriceForPriceAndCost = 0;
            $scope.M_AddEditUO.unitRec.Condition = 'New';
            $scope.M_AddEditUO.setBgColor = -1;
            $scope.M_AddEditUO.tempFactory = {}
            $scope.M_AddEditUO.tempFactory.Type = 'Factory';
            $scope.M_AddEditUO.PriceAndCostTrackingWrapperList = [];
            $scope.M_AddEditUO.UnitMakeName = '';
            $scope.M_AddEditUO.UnitCategoryName = '';
            $scope.M_AddEditUO.TagNameStr = '';
            $scope.M_AddEditUO.unitRec.AssignedTags = [];
            $scope.M_AddEditUO.unitRec.MileageType = 'Km';
            $scope.M_AddEditUO.isBlur = true;
            $scope.M_UO.isLoading = true;
            var tempMakelist = [];
            var tempModelList = [];
            var tempSubModelList = [];
            var Currentyear = parseInt(new Date().getFullYear());
            
            /* Load modals values which needs be loaded only once while page lifetime */
            for (i = Currentyear +1; i > (Currentyear - 100 + 2); i--) {
                var year = {
                    year: i
                };
                $scope.M_AddEditUO.Years.push(year);
            }

            $scope.M_AddEditUO.Conditions = ['New', 'Used'];
            $scope.M_AddEditUO.TransmissionTypeList = ['Automatic', 'Manual'];
            $scope.M_AddEditUO.MileageTypeList = ['Km', 'Mi', 'Hrs'];

            var success = function () {
                var self = this;
                this.arguments = arguments[0];
                this.calleeMethodName = arguments[0].calleeMethodName,
                    this.callback = arguments[0].callback,
                    this.handler = function (successResult) {
                        switch (self.calleeMethodName) {
                            case 'getVendorDetails':
                                handleGetVendorDetailsResponse(successResult);
                                break;
                            case 'getUnitDetails':
                                handleGetUnitDetailsResponse(successResult);
                                break;
                            /* case 'getUnitmakeList':
                                handleGetUnitmakeListResponse(successResult);
                                break;
                            case 'getUnitModelList':
                                handleGetUnitModelListResponse(successResult);
                                break;
                            case 'getUnitSubModelList':
                                handleGetUnitSubModelListResponse(successResult);
                                break; */
                            case 'saveUnitDetails':
                                handleSaveUnitDetailsResponse(successResult);
                                break;
                            case 'getApplicableTaxList':
                                handleGetApplicableTaxListResponse(successResult);
                                break;
                            case 'getUnitCategoryList':
                                handleGetUnitCategoryListResponse(successResult);
                                break;
                            case 'savePriceAndCost':
                                handlesavePriceAndCostResponse(successResult);
                                break;
                            case 'removePriceAndCost':
                                handleremovePriceAndCostResponse(successResult);
                                break;
                            case 'getActiveTagList':
                                handleGetActiveTagListResponse(successResult);
                                break;
                            default:
                                break;
                        }
                        if (typeof self.callback === 'function') {
                            self.callback();
                        }
                    }

                function handleGetVendorDetailsResponse(vendorRec) {
                    $scope.M_UO.vendorName = vendorRec.VendorName;
                    $scope.M_AddEditUO.vendorName = vendorRec.VendorName;
                    if (self.arguments.setLoadingVariableIndsideGetVendorDetails) {
                        $scope.M_UO.isLoading = false;
                    }
                }
                
                function handleGetUnitDetailsResponse(unitList) {
                    $scope.M_AddEditUO.tempUnitData = angular.copy(unitList[0]);
                    $scope.M_AddEditUO.unitRecWrapper = unitList[0];
                    $scope.M_AddEditUO.unitRec = unitList[0].UnitInfo;
                    $scope.M_UO.unitNumber = unitList[0].UnitInfo.UnitId;
                    $scope.M_UO.coNumber = unitList[0].UnitInfo.CoNumber;
                    $scope.M_UO.coId = unitList[0].UnitInfo.CoId;
                    $scope.M_UO.customerName = unitList[0].UnitInfo.CustomerName;
                    $scope.M_UO.customerId = unitList[0].UnitInfo.CustomerId;
                    if ($scope.M_AddEditUO.unitRec.IsNewUnit) {
                        $scope.M_AddEditUO.unitRec.Condition = 'New';
                    } else {
                        $scope.M_AddEditUO.unitRec.Condition = 'Used';
                    }
                    $scope.M_AddEditUO.unitRec.VIN = ($scope.M_AddEditUO.unitRec.VIN && $scope.M_AddEditUO.unitRec.VIN === 'VIN Unknown') ? '' : $scope.M_AddEditUO.unitRec.VIN;

                    $scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.unitRec.MakeName;
                    $scope.M_AddEditUO.UnitCategoryName = $scope.M_AddEditUO.unitRec.CategoryName;

                    $scope.M_AddEditUO.PriceAndCostTrackingWrapperList = unitList[0].PriceAndCostTrackingWrapperList;
                    $scope.M_AddEditUO.totalPriceForPriceAndCost = 0;
                    for (var i = 0; i < $scope.M_AddEditUO.PriceAndCostTrackingWrapperList.length; i++) {
                        $scope.M_AddEditUO.totalPriceForPriceAndCost += parseFloat($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[i].TotalPrice);
                    }
                    var additionalUnitField = $scope.M_AddEditUO.AdditionalFieldsInfo;
                    for (var key in additionalUnitField) {

                        if (additionalUnitField.hasOwnProperty(key)) {
                            if ($scope.M_AddEditUO.unitRec[key] != null && $scope.M_AddEditUO.unitRec[key] != undefined && $scope.M_AddEditUO.unitRec[key] != '') {
                                additionalUnitField[key].isPrimary = true;
                            } else {
                                additionalUnitField[key].isPrimary = false;
                            }
                        }
                    }
                    if ($scope.M_AddEditUO.unitRec.AssignedTags.length == 0) {
                        $scope.M_AddEditUO.AdditionalFieldsInfo.AssignedTags.isPrimary = false;
                    }
                    angular.element('[role ="tooltip"]').hide();
                    setTimeout(function () {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'top',
                            container: 'body'
                        });
                    }, 500);
                    $scope.M_UO.isLoading = false;
                }

                /* function handleGetUnitmakeListResponse(unitMakeList) {
                    $scope.M_AddEditUO.UnitMakeList = unitMakeList;
                } */

                /* function handleGetUnitModelListResponse(unitModelList) {
                    $scope.M_AddEditUO.showModelList = true;
                    $scope.M_AddEditUO.UnitModelList = unitModelList;
                } */

               /*  function handleGetUnitSubModelListResponse(unitSubModelList) {
                    
                    $scope.M_AddEditUO.UnitSubModelList = unitSubModelList;
                } */

                function handleSaveUnitDetailsResponse(unitList) {
                    if (unitList.HasError) {
                        Notification.error(unitList.ErrorMessage);
                        $scope.M_UO.isLoading = false;
                        return;
                    } else {
                        if ($scope.M_AddEditUO.isURLContainsUnitId) {
                            $scope.M_AddEditUO.isEditMode = false;
                            $scope.M_UO.isLoading = false;
                            var additionalUnitField = $scope.M_AddEditUO.AdditionalFieldsInfo;
                            for (var key in additionalUnitField) {

                                if (additionalUnitField.hasOwnProperty(key)) {
                                    if ($scope.M_AddEditUO.unitRec[key] != null && $scope.M_AddEditUO.unitRec[key] != undefined && $scope.M_AddEditUO.unitRec[key] != '') {
                                        additionalUnitField[key].isPrimary = true;
                                    } else {
                                        additionalUnitField[key].isPrimary = false;
                                    }
                                }
                            }
                            $scope.M_AddEditUO.tempUnitData = angular.copy(unitList[0]);
                        } else {
                            if (typeof self.callback === 'function') {
                                $scope.M_AddEditUO.unitId = unitList[0].UnitInfo.Id;
                                $scope.M_AddEditUO.unitRecWrapper = unitList[0];
                                $scope.M_AddEditUO.tempUnitData = angular.copy(unitList[0]);
                                $scope.M_AddEditUO.unitRec = unitList[0].UnitInfo;
                                
                                if ($scope.M_AddEditUO.unitRec.IsAutomatic) {
                                    $scope.M_AddEditUO.unitRec.TransmissionType = 'Automatic';
                                } else {
                                    $scope.M_AddEditUO.unitRec.TransmissionType = 'Manual';
                                }
                                $scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.unitRec.MakeName;
                                $scope.M_AddEditUO.UnitCategoryName = $scope.M_AddEditUO.unitRec.CategoryName;

                                $scope.M_AddEditUO.PriceAndCostTrackingWrapperLt = unitList[0].PriceAndCostTrackingWrapperList;
                            } else {
                                loadState($state, 'UnitOrdering.ViewVendorOrderUnits', {
                                    'vendorId': $scope.M_AddEditUO.vendorId
                                });
                            }
                        }
                    }
                }

                function handleGetApplicableTaxListResponse(taxList) {
                    $scope.M_AddEditUO.IsTaxIncludingPricing = taxList.IsTaxIncludingPricing;
                    $scope.M_AddEditUO.ApplicableTaxList = taxList.SalesTaxList;
                }

                function handleGetUnitCategoryListResponse(categoryList) {
                    $scope.M_AddEditUO.UnitCategoryList = categoryList;
                }

                function handlesavePriceAndCostResponse(unitList) {
                    $scope.M_AddEditUO.isEdit = -1;
                    setTimeout(function () {
                        $scope.M_AddEditUO.setBgColor = -1;
                        if (!$scope.$$phase) {
                            $scope.$digest();
                        }
                    }, 500)

                    $scope.M_AddEditUO.PriceAndCostTrackingWrapperList = unitList[0].PriceAndCostTrackingWrapperList;
                    angular.element('[role ="tooltip"]').hide();
                    setTimeout(function () {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'top',
                            container: 'body'
                        });
                    }, 500);
                    $scope.F_AddEditUO.calculateTotalValue();
                    $scope.M_AddEditUO.showFactoryOptionRec = false;
                    $scope.M_AddEditUO.tempFactory = {};
                    $scope.M_AddEditUO.tempFactory.Type = 'Factory';
                    $scope.M_AddEditUO.unitRec.Condition = $scope.M_AddEditUO.unitRec.IsNewUnit? 'New':'Used';
                    $scope.M_UO.isLoading = false;
                }

                function handleremovePriceAndCostResponse(unitList) {
                    $scope.F_AddEditUO.hidePriceAndCostDeleteConfirmationPopup();
                    setTimeout(function () {
                        var deletedElement = angular.element('#' + self.arguments.elementId);
                        if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                            deletedElement.addClass('bp-collapse-deleted-div-transition');
                        }
                    }, 100);

                    setTimeout(function () {
                        $scope.M_AddEditUO.PriceAndCostTrackingWrapperList = unitList[0].PriceAndCostTrackingWrapperList;
                        $scope.F_AddEditUO.calculateTotalValue();
                        angular.element('[role ="tooltip"]').hide();
                        setTimeout(function () {
                            angular.element('[data-toggle="tooltip"]').tooltip({
                                placement: 'top',
                                container: 'body'
                            });
                        }, 500);
                        if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                            $scope.$apply(); //TODO
                        }
                    }, 600);

                    $scope.M_AddEditUO.deletablePriceAndItemId = '';
                    $scope.M_AddEditUO.deletableElementId = '';
                }

                function handleGetActiveTagListResponse(tagList) {
                    $scope.M_AddEditUO.ActiveTagList = tagList;
                }
            }

            var error = function (errorMessage) { //TODO
                this.handler = function (error) {
                    $scope.M_UO.isLoading = false;
                    if (!errorMessage) {
                        console.log(error);
                    } else {
                        console.log(errorMessage);
                    }
                }
            }

            $scope.M_AddEditUO.AdditionalFieldsInfo = {
                Category: {
                    isPrimary: false,
                    label: 'Category',
                    fieldId: 'CategoryId'
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
                EngineSerialNo: {
                    isPrimary: false,
                    label: 'Engine Serial #',
                    fieldId: 'EnginSerialId'
                },
                Gears: {
                    isPrimary: false,
                    label: 'Gears',
                    fieldId: 'GearsId'
                },
                InteriorColour: {
                    isPrimary: false,
                    label: 'Interior Colour',
                    fieldId: 'InteriorColourId'
                },
                TransmissionType: {
                    isPrimary: false,
                    label: 'Transmission type',
                    fieldId: 'TransmissionTypeId'
                },
                AssignedTags: {
                    isPrimary: false,
                    label: 'Tags',
                    fieldId: 'TagsId'
                },
                KeyNo: {
                    isPrimary: false,
                    label: 'Key #',
                    fieldId: 'KeyNoId'
                },
                Location: {
                    isPrimary: false,
                    label: 'Location',
                    fieldId: 'LocationId'
                },
                ManufacturedDate: {
                    isPrimary: false,
                    label: 'Manufactured Date',
                    fieldId: 'ManufacturedDateId'
                },
                Mileage: {
                    isPrimary: false,
                    label: 'Mileage',
                    fieldId: 'MileageId'
                },
                OtherSerialNo: {
                    isPrimary: false,
                    label: 'Other Serial #',
                    fieldId: 'OtherSerialID'
                },
                Plate: {
                    isPrimary: false,
                    label: 'Plate/registration number',
                    fieldId: 'PlatId'
                },
                RegExpiryDate: {
                    isPrimary: false,
                    label: 'Reg Expiry Date',
                    fieldId: 'customerUnitRegExpiryDateOption'
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

            $scope.M_AddEditUO.dateFormat = $Global.DateFormat;
            $scope.M_AddEditUO.expiryDateOptions = {
                minDate: new Date,
                dateFormat: $scope.M_AddEditUO.dateFormat,
                showOtherMonths: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            }
            $scope.M_AddEditUO.ComplianceDateOptions = {
                minDate: new Date,
                dateFormat: $scope.M_AddEditUO.dateFormat,
                showOtherMonths: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            }
            $scope.M_AddEditUO.ManufactureDateOptions = {
                dateFormat: $scope.M_AddEditUO.dateFormat,
                showOtherMonths: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            };
            
            $scope.M_AddEditUO.vehicleSpecificationsResult = '';
            
            $scope.F_AddEditUO.keydownForVIN = function(event, vinNumber) {
            	var keyCode = event.which ? event.which : event.keyCode;
            	if(keyCode == 9 && !isBlankValue(vinNumber)) {
            		event.preventDefault();
            		angular.element('#VIN_OrderUnit').blur();
            	}
            }
            
            $scope.F_AddEditUO.getVehicleSpecification  = function(vinNumber) {
            	if(!$Global.isBRPEnabled) {
            		return;
            	}
            	if(isBlankValue(vinNumber)) {
            		$scope.M_AddEditUO.vehicleSpecificationsResult = '';
            		return;
            	}
            	$scope.M_AddEditUO.vehicleSpecificationsResult = 'Loading';
                UnitReceivingServices.getVehicleSpecification(vinNumber).then(function(response) {
                	$scope.M_AddEditUO.unitRec.mapOfNewAndOldValue =  {};
                	if(response.responseCode == 400) {
                		$scope.M_AddEditUO.vehicleSpecificationsResult = 'Match not found';
                	} else {
                		setMapofOldAndNewValue('Make', $scope.M_AddEditUO.unitRec.MakeName, 'BRP');
                        setMapofOldAndNewValue('Model', $scope.M_AddEditUO.unitRec.ModelName, response.Model);
                        setMapofOldAndNewValue('SubModel', $scope.M_AddEditUO.unitRec.SubModelName, response.ModelDescription);
                        setMapofOldAndNewValue('Year', $scope.M_AddEditUO.unitRec.Year, response.ModelYear);
                        setMapofOldAndNewValue('NumberOfCyclinder', $scope.M_AddEditUO.unitRec.Cylinders, response.Engine.NumberOfEngineCylindersNumeric);
                        $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue.isHideIgnore = true;
                	}
                }, function(error) {
                    $scope.M_UO.isLoading = false;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            }


            function setMapofOldAndNewValue(objName, oldValue, newValue) {
                if((oldValue || newValue) && oldValue != newValue) {
                	if(isBlankValue(oldValue)) {
                    	oldValue = '';
                    }
                    if(isBlankValue(newValue)) {
                    	newValue = '';
                    }
                    var tempArray = [oldValue, newValue];
                    $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue[objName]= tempArray;
                }
                if(Object.entries($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue).length == 0) {
                	$scope.M_AddEditUO.vehicleSpecificationsResult = 'Match found with all fields match';
                } else {
                	$scope.M_AddEditUO.vehicleSpecificationsResult = 'Match found with not all fields match';
                }
            }
            
            checkIfChangeExistsInEnteredAndBRPValues = function() {
            	if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
            		var arr = Object.entries($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue);
            		for(var i=0; i<arr.length; i++) {
            			if(isBlankValue(arr[i][1][0])) {
            				arr[i][1][0] = '';
            			}
            			if(isBlankValue(arr[i][1][1])) {
            				arr[i][1][1] = '';
            			}
            			if(arr[i][0] != 'isHideIgnore' && arr[i][1][0].toLowerCase() != arr[i][1][1].toLowerCase()) {
            				return;
            			}
            		}
            		if(arr.length > 0) {
            			$scope.M_AddEditUO.vehicleSpecificationsResult = 'Match found with all fields match';
            			return;
            		}
            	}
            }

            $scope.F_AddEditUO.setFocusOnElement = function (elmenetId) {
                angular.element("#" + elmenetId).focus();
            }
            $scope.F_AddEditUO.showCalander = function (elementId) {
                $scope.F_AddEditUO.setFocusOnElement(elementId);
            }
            $scope.F_AddEditUO.getMakeList = function () {
                $scope.M_AddEditUO.showMakeList = true;
                document.getElementById('makeDropDownDiv').scrollTop = 0;
            }
            $scope.F_AddEditUO.hideMakeList = function () {
                $scope.M_AddEditUO.showMakeList = false;
            }

            $scope.F_AddEditUO.selectUnitMake = function (unitMake) {
                $scope.F_AddEditUO.hideMakeList();
                $scope.M_AddEditUO.UnitMakeName = unitMake.UnitMakeName;
                $scope.M_AddEditUO.unitRec.Make = unitMake.Id;
                $scope.M_AddEditUO.unitRec.MakeName = unitMake.UnitMakeName;
                if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                    $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0] = unitMake.UnitMakeName;
                }
                    $scope.M_AddEditUO.UnitModelList = tempModelList;
                    $scope.M_AddEditUO.UnitSubModelList = tempSubModelList;
                var UnitModelList = [];
                var unitSubModelList = [];
                for(var i=0;i<$scope.M_AddEditUO.UnitModelList.length;i++){
                    if(unitMake.Id == $scope.M_AddEditUO.UnitModelList[i].MakeId) {
                        UnitModelList.push($scope.M_AddEditUO.UnitModelList[i]);
                        for(var j=0;j<$scope.M_AddEditUO.UnitSubModelList.length;j++){
                            if($scope.M_AddEditUO.UnitModelList[i].Id == $scope.M_AddEditUO.UnitSubModelList[j].ModelId) {
                                unitSubModelList.push($scope.M_AddEditUO.UnitSubModelList[j]);
                            }
                        }
                    
                    }
                }
                $scope.M_AddEditUO.UnitModelList = UnitModelList;
                $scope.M_AddEditUO.UnitSubModelList = unitSubModelList;
                $scope.M_AddEditUO.unitRec.Model = null;
                $scope.M_AddEditUO.unitRec.ModelName = '';
                $scope.M_AddEditUO.unitRec.SubModel = null;
                $scope.M_AddEditUO.unitRec.SubModelName = '';
            }

            $scope.F_AddEditUO.clearMakeModelSubModelValue = function () {
                var exists = _.filter($scope.M_AddEditUO.UnitMakeList, function (term) {
                    return term.UnitMakeName.toLowerCase() == $scope.M_AddEditUO.UnitMakeName.toLowerCase();
                });
                if (exists.length == 0) {
                    $scope.M_AddEditUO.unitRec.Make = null;
                    $scope.M_AddEditUO.unitRec.MakeName = '';
                    $scope.M_AddEditUO.unitRec.Model = null;
                    $scope.M_AddEditUO.unitRec.ModelName = '';
                    $scope.M_AddEditUO.unitRec.SubModel = null;
                    $scope.M_AddEditUO.unitRec.SubModelName = '';
                    $scope.M_AddEditUO.UnitMakeList = tempMakelist;
                    $scope.M_AddEditUO.UnitModelList = tempModelList;
                    $scope.M_AddEditUO.UnitSubModelList = tempSubModelList;
                } else {
                    $scope.M_AddEditUO.unitRec.Make = exists[0].Id;
                    $scope.M_AddEditUO.unitRec.MakeName = exists[0].UnitMakeName;
                    if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                        $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0] = exists[0].UnitMakeName;
                        console.log($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0])
                    }
                }
            }

            $scope.F_AddEditUO.getModelList = function () {
                /* if (!isBlankValue($scope.M_AddEditUO.unitRec.Make)) {
                    var successJson = {
                        'calleeMethodName': 'getUnitModelList'
                    };
                    VINOperationsService.getUnitModelList($scope.M_AddEditUO.unitRec.Make).then(new success(successJson).handler, new error().handler);
                } */
                $scope.M_AddEditUO.showModelList = true;
                document.getElementById('modelDropDownDiv').scrollTop = 0;
            }
            $scope.F_AddEditUO.hideModelList = function () {
                $scope.M_AddEditUO.showModelList = false;
            }

            $scope.F_AddEditUO.selectUnitModel = function (unitModel) {
                $scope.F_AddEditUO.hideModelList();
                $scope.M_AddEditUO.unitRec.Model = unitModel.Id;
                $scope.M_AddEditUO.unitRec.ModelName = unitModel.UnitModelName;
                if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                    $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model'][0] = unitModel.UnitModelName;
                }
                    $scope.M_AddEditUO.UnitSubModelList = tempSubModelList;

                var unitSubModelList = [];
                        for(var j=0;j<$scope.M_AddEditUO.UnitSubModelList.length;j++){
                            if(unitModel.Id == $scope.M_AddEditUO.UnitSubModelList[j].ModelId) {
                                unitSubModelList.push($scope.M_AddEditUO.UnitSubModelList[j]);
                            }
                        }
                        $scope.M_AddEditUO.UnitSubModelList = unitSubModelList;
                        $scope.M_AddEditUO.unitRec.SubModel = null;
                        $scope.M_AddEditUO.unitRec.SubModelName = '';
                        var makeIndex = _.findIndex($scope.M_AddEditUO.UnitMakeList, {
                            'Id': unitModel.MakeId
                        });
                        if(makeIndex != -1) {
                            $scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.UnitMakeList[makeIndex].UnitMakeName;
                            $scope.M_AddEditUO.unitRec.Make = $scope.M_AddEditUO.UnitMakeList[makeIndex].Id;
                            $scope.M_AddEditUO.unitRec.MakeName = $scope.M_AddEditUO.UnitMakeList[makeIndex].UnitMakeName;
                        }
            }

            $scope.F_AddEditUO.getSubModelList = function () {
               /*  if (!isBlankValue($scope.M_AddEditUO.unitRec.Model)) {
                    var successJson = {
                        'calleeMethodName': 'getUnitSubModelList'
                    };
                    VINOperationsService.getUnitSubModelList($scope.M_AddEditUO.unitRec.Model, $scope.M_AddEditUO.unitRec.Make).then(new success(successJson).handler, new error().handler);
                } */
                $scope.M_AddEditUO.showSubModelList = true;
                document.getElementById('subModelDropDownDiv').scrollTop = 0;
            }
            $scope.F_AddEditUO.hideSubModelList = function () {
                $scope.M_AddEditUO.showSubModelList = false;
            }
            function filterMakeModelSubmodelList() {
                $scope.M_AddEditUO.UnitMakeList = tempMakelist;
                $scope.M_AddEditUO.UnitModelList = tempModelList;
                $scope.M_AddEditUO.UnitSubModelList = tempSubModelList;
                if($scope.M_AddEditUO.unitRec.Make) {
                    var UnitModelList = [];
                    var unitSubModelList = [];
                for(var i=0;i<$scope.M_AddEditUO.UnitModelList.length;i++){
                    if($scope.M_AddEditUO.unitRec.Make == $scope.M_AddEditUO.UnitModelList[i].MakeId) {
                        UnitModelList.push($scope.M_AddEditUO.UnitModelList[i]);
                    }
                } 
                for(var i=0;i<UnitModelList.length;i++) {
                    for(var j=0;j<$scope.M_AddEditUO.UnitSubModelList.length;j++){
                        if((!$scope.M_AddEditUO.unitRec.Model || $scope.M_AddEditUO.unitRec.Model == $scope.M_AddEditUO.UnitSubModelList[j].ModelId) && UnitModelList[i].Id == $scope.M_AddEditUO.UnitSubModelList[j].ModelId) {
                            unitSubModelList.push($scope.M_AddEditUO.UnitSubModelList[j]);
                        }
                    }
                }
                $scope.M_AddEditUO.UnitModelList = UnitModelList;
                $scope.M_AddEditUO.UnitSubModelList = unitSubModelList;
    
            }
        }
            $scope.F_AddEditUO.selectUnitSubModel = function (unitSubModel) {
                $scope.F_AddEditUO.hideSubModelList();
                var modelIndex = _.findIndex($scope.M_AddEditUO.UnitModelList, {
                    'Id': unitSubModel.ModelId
                });
                if(modelIndex != -1) {
                    $scope.M_AddEditUO.unitRec.Model = $scope.M_AddEditUO.UnitModelList[modelIndex].Id;
                    $scope.M_AddEditUO.unitRec.ModelName = $scope.M_AddEditUO.UnitModelList[modelIndex].UnitModelName;
                    var makeIndex = _.findIndex($scope.M_AddEditUO.UnitMakeList, {
                        'Id': $scope.M_AddEditUO.UnitModelList[modelIndex].MakeId
                    });
                    if(makeIndex != -1) {
                        $scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.UnitMakeList[makeIndex].UnitMakeName;
                        $scope.M_AddEditUO.unitRec.Make = $scope.M_AddEditUO.UnitMakeList[makeIndex].Id;
                        $scope.M_AddEditUO.unitRec.MakeName = $scope.M_AddEditUO.UnitMakeList[makeIndex].UnitMakeName;
                    }
                }

                $scope.M_AddEditUO.unitRec.SubModel = unitSubModel.Id;
                $scope.M_AddEditUO.unitRec.SubModelName = unitSubModel.SubModelName;
                if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                    $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel'][0] = unitSubModel.SubModelName;
                }
                filterMakeModelSubmodelList();
            }
            $scope.F_AddEditUO.selectCylinders = function(cylinderValue) {
                if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                    $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['NumberOfCyclinder'][0] = cylinderValue;
                }
            }
            $scope.F_AddEditUO.selectUnitYear = function(year,attr) {
                if(attr == 'Year') {
                    $scope.M_AddEditUO.unitRec.Year = year;
                    if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
                        $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Year'][0] = $scope.M_AddEditUO.unitRec.Year;
                    }
                } else if(attr == 'Yearof1stRego') {
                    $scope.M_AddEditUO.unitRec.YearOf1stRego = year;
                }
               
            } 
            $scope.F_AddEditUO.saveAddEditUnitRecord = function () {
            	setDataFromBRP();
                $scope.M_AddEditUO.isUnSavedChanges = false;
                var successJson = {
                    'calleeMethodName': 'saveUnitDetails'
                };
                if (!$scope.M_AddEditUO.unitRec.VIN || $scope.F_AddEditUO.isValidVIN($scope.M_AddEditUO.unitRec.VIN)) {
                	if(!isBlankValue($scope.M_AddEditUO.unitRec.Cylinders)) {
            			$scope.M_AddEditUO.unitRec.Cylinders = parseFloat($scope.M_AddEditUO.unitRec.Cylinders);
            		} else {
            			$scope.M_AddEditUO.unitRec.Cylinders = null;
            		}
                    createUnit(successJson);
                }
            }
            
            setDataFromBRP = function() {
            	if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue) {
            		if(isBlankValue($scope.M_AddEditUO.unitRec.MakeName)) {
            			$scope.M_AddEditUO.unitRec.MakeName = '';
            		}
        			if(isBlankValue($scope.M_AddEditUO.unitRec.ModelName)) {
        				$scope.M_AddEditUO.unitRec.ModelName = '';
            		}
        			if(isBlankValue($scope.M_AddEditUO.unitRec.SubModelName)) {
        				$scope.M_AddEditUO.unitRec.SubModelName = '';
            		}
            		
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make']) {
        				if($scope.M_AddEditUO.unitRec.MakeName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.MakeName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0];
                			$scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.unitRec.MakeName;
                			$scope.M_AddEditUO.unitRec.Make = null;
                			$scope.M_AddEditUO.unitRec.Model = null;
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                		}
        			}
            		
            		if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model']) {
            			if($scope.M_AddEditUO.unitRec.ModelName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.ModelName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model'][0];
                			$scope.M_AddEditUO.unitRec.Model = null;
                		}
            		}
            		
            		if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel']) {
            			if($scope.M_AddEditUO.unitRec.SubModelName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.SubModelName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel'][0];
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                		}
            		}
            		
            		if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Year']) {
            			$scope.M_AddEditUO.unitRec.Year = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Year'][0];
                		if(!isBlankValue($scope.M_AddEditUO.unitRec.Year)) {
                			$scope.M_AddEditUO.unitRec.Year = parseFloat($scope.M_AddEditUO.unitRec.Year);
                		} else {
                			$scope.M_AddEditUO.unitRec.Year = null;
                		}
            		}
            		
            		if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['NumberOfCyclinder']) {
            			$scope.M_AddEditUO.unitRec.Cylinders = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['NumberOfCyclinder'][0];
                		if(!isBlankValue($scope.M_AddEditUO.unitRec.Cylinders)) {
                			$scope.M_AddEditUO.unitRec.Cylinders = parseFloat($scope.M_AddEditUO.unitRec.Cylinders);
                		} else {
                			$scope.M_AddEditUO.unitRec.Cylinders = null;
                		}
            		}
        		}
            }
            
            $scope.F_AddEditUO.UpdateAddEditUnitRecord = function () {
                $scope.M_AddEditUO.isUnSavedChanges = true;
            }

            $scope.F_AddEditUO.keyBoardavigation = function (event, dataList, dropDownName) {
                var keyCode = event.which ? event.which : event.keyCode;
                var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
                var indexName = dropDownName + 'CurrentIndex';
                if ($scope.M_AddEditUO[indexName] == undefined || isNaN($scope.M_AddEditUO[indexName])) {
                    $scope.M_AddEditUO[indexName] = -1;
                }
                if (keyCode == 40 && dataList != undefined && dataList != '') {
                    if (dataList.length - 1 > $scope.M_AddEditUO[indexName]) {
                        $scope.M_AddEditUO[indexName]++;
                        angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditUO[indexName])[0].offsetTop - 100;
                    }
                } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                    if ($scope.M_AddEditUO[indexName] > 0) {
                        $scope.M_AddEditUO[indexName]--;
                        angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditUO[indexName])[0].offsetTop - 100;
                    }
                } else if (keyCode == 13) {
                    if (dropDownName == 'make') {
                        $scope.F_AddEditUO.selectUnitMake(dataList[$scope.M_AddEditUO[indexName]]);
                        $scope.F_AddEditUO.hideMakeList();
                    } else if (dropDownName == 'category') {
                        $scope.F_AddEditUO.changeUnitCategory(dataList[$scope.M_AddEditUO[indexName]]);
                        $scope.F_AddEditUO.hideCategoryList();
                    } else if (dropDownName == 'tag') {
                        $scope.F_AddEditUO.selectTag(dataList[$scope.M_AddEditUO[indexName]]);
                        $scope.F_AddEditUO.hideTagsList();
                    }
                    $scope.M_AddEditUO[indexName] = -1;
                }
            }

            $scope.F_AddEditUO.isUnSavedChanges = function () {
                if (!isBlankValue($scope.M_AddEditUO.unitRec.Make || $scope.M_AddEditUO.unitRec.MakeName) && !isBlankValue($scope.M_AddEditUO.unitRec.Model || $scope.M_AddEditUO.unitRec.ModelName) &&
                    $rootScope.GroupOnlyPermissions['Unit ordering']['create/modify'] && $scope.M_AddEditUO.isEditMode) {
                    return true;
                }
                return false;
            }
            $rootScope.$on('updateUnitDetailFromDirective',function(event, args) {
            	setDataOfUnit(args.key, args.value);
            	checkIfChangeExistsInEnteredAndBRPValues();
            });
            
            function setDataOfUnit(key, value) {
        		if(key == 'Make') {
        			if(isBlankValue($scope.M_AddEditUO.unitRec.MakeName)) {
            			$scope.M_AddEditUO.unitRec.MakeName = '';
            		}
        			
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make']) {
        				if($scope.M_AddEditUO.unitRec.MakeName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.MakeName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Make'][0];
                			$scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.unitRec.MakeName;
                			$scope.M_AddEditUO.unitRec.Make = null;
                			$scope.M_AddEditUO.unitRec.Model = null;
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                		}
        			}
        		} else if(key == 'Model') {
        			if(isBlankValue($scope.M_AddEditUO.unitRec.ModelName)) {
        				$scope.M_AddEditUO.unitRec.ModelName = '';
            		}
        			
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model']) {
            			if($scope.M_AddEditUO.unitRec.ModelName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.ModelName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Model'][0];
                			$scope.M_AddEditUO.unitRec.Model = null;
                		}
            		}
        		} else if(key == 'SubModel') {
        			if(isBlankValue($scope.M_AddEditUO.unitRec.SubModelName)) {
        				$scope.M_AddEditUO.unitRec.SubModelName = '';
            		}
        			
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel']) {
            			if($scope.M_AddEditUO.unitRec.SubModelName.toLowerCase() != $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel'][0].toLowerCase()) {
                			$scope.M_AddEditUO.unitRec.SubModelName = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['SubModel'][0];
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                			$scope.M_AddEditUO.unitRec.SubModel = null;
                		}
            		}
        		} else if(key == 'Year') {
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Year']) {
            			$scope.M_AddEditUO.unitRec.Year = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['Year'][0];
                		if(!isBlankValue($scope.M_AddEditUO.unitRec.Year)) {
                			$scope.M_AddEditUO.unitRec.Year = parseFloat($scope.M_AddEditUO.unitRec.Year);
                		} else {
                			$scope.M_AddEditUO.unitRec.Year = null;
                		}
            		}
        		} else if(key == 'NumberOfCyclinder') {
        			if($scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['NumberOfCyclinder']) {
            			$scope.M_AddEditUO.unitRec.Cylinders = $scope.M_AddEditUO.unitRec.mapOfNewAndOldValue['NumberOfCyclinder'][0];
                        $scope.M_AddEditUO.AdditionalFieldsInfo['Cylinders'].isPrimary = true;
                		if(!isBlankValue($scope.M_AddEditUO.unitRec.Cylinders)) {
                			$scope.M_AddEditUO.unitRec.Cylinders = parseFloat($scope.M_AddEditUO.unitRec.Cylinders);
                		} else {
                			$scope.M_AddEditUO.unitRec.Cylinders = null;
                		}
            		}
        		}
        	}
            
            $scope.F_AddEditUO.editPriceAndCostLineItem = function (index) {

                if ($scope.M_AddEditUO.isEdit != -1) {
                    Notification.error($translate.instant('First_save_line_item_message'));
                    return;
                }
                angular.element('[role ="tooltip"]').hide();
                setTimeout(function () {
                    angular.element('[data-toggle="tooltip"]').tooltip({
                        placement: 'top',
                        container: 'body'
                    });
                }, 500);
                $scope.M_AddEditUO.isEdit = index;
                $scope.M_AddEditUO.setBgColor = index;
            }
            $scope.F_AddEditUO.savePriceUnitLineItem = function (event, index) {
                var focusedElement;

                if (event) {
                    focusedElement = event.relatedTarget;
                    if (focusedElement) {
                        if (focusedElement.id == ('totalPriceUnit' + '_' + index)) {
                            $scope.M_AddEditUO.isBlur = false;
                        }
                    }

                    if (event.type != "blur") {
                        savePriceAndCostUnitLI(index);
                    } else if (event.type == "blur" && !$scope.M_AddEditUO.isBlur) {
                        event.preventDefault();
                        $scope.M_AddEditUO.isBlur = true;
                        return;
                    } else if (event.type == "blur" && $scope.M_AddEditUO.isBlur) {
                        savePriceAndCostUnitLI(index);
                    }
                }
            }

            function savePriceAndCostUnitLI(index) {
                if (index != undefined) {
                    savePriceAndCost($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[index]);
                } else {
                    $scope.M_AddEditUO.tempFactory.UnitId = $scope.M_AddEditUO.unitId
                    savePriceAndCost($scope.M_AddEditUO.tempFactory);
                }
            }

            $scope.F_AddEditUO.openPriceAndCostDeleteConfirmationPopup = function (priceAndItemId, deletableElementId) {
                if ($scope.M_AddEditUO.isEdit != -1) {
                    Notification.error($translate.instant('First_save_line_item_message'));
                    return;
                }

                $scope.M_AddEditUO.deletablePriceAndItemId = priceAndItemId;
                $scope.M_AddEditUO.deletableElementId = deletableElementId;

                addBackdrop();
                toppopupposition = (angular.element("#" + deletableElementId + " .trDeleteBtn ").offset().top) + 20;
                leftpopupposition = (angular.element("#" + deletableElementId + " .trDeleteBtn ").offset().left) + 5;
                angular.element(".deleteConfiramtionPopup").css("left", leftpopupposition + 'px');
                angular.element(".deleteConfiramtionPopup").css("top", toppopupposition + 'px');
                setTimeout(function () {
                    angular.element(".deleteConfiramtionPopup").css("visibility", 'visible');
                    angular.element(".deleteConfiramtionPopup").css("opacity", 1);
                }, 100);

            }

            function addBackdrop() {
                setTimeout(function () {
                    var template = '<div class = "bp-modal-backdrop unitOrderingBackdrop" ng-click = "F_AddEditUO.hidePriceAndCostDeleteConfirmationPopup()"></div>';
                    template = $compile(angular.element(template))($scope);
                    angular.element("#AddEditUnitOrderWrapperId").prepend(template);
                }, 500);
            }

            $scope.F_AddEditUO.hidePriceAndCostDeleteConfirmationPopup = function () {
                angular.element(".deleteConfiramtionPopup").css("visibility", 'hidden');
                angular.element(".deleteConfiramtionPopup").css("opacity", 0);
                angular.element("#AddEditUnitOrderWrapperId").find('.bp-modal-backdrop').remove();
            }

            $scope.F_AddEditUO.deletePriceAndCost = function () {
                removePriceAndCost();
            }

            function removePriceAndCost(priceAndItemId) {
                var successJson = {
                    'calleeMethodName': 'removePriceAndCost',
                    'elementId': $scope.M_AddEditUO.deletableElementId
                };
                UnitOrderingService.removePriceAndCost($scope.M_AddEditUO.unitId, $scope.M_AddEditUO.deletablePriceAndItemId).then(new success(successJson).handler, new error().handler);
            }

            $scope.F_AddEditUO.cteareFactoryOption = function () {

                if ($scope.M_AddEditUO.isEdit != -1) {
                    Notification.error($translate.instant('First_save_line_item_message'));
                    return;
                }
                $scope.M_AddEditUO.showFactoryOptionRec = true;
                $scope.M_AddEditUO.tempFactory.TotalPrice = 0;
                $scope.M_AddEditUO.tempFactory.TotalCost = 0;
                $scope.M_AddEditUO.isEdit = $scope.M_AddEditUO.PriceAndCostTrackingWrapperList.length;
                $scope.M_AddEditUO.setBgColor = $scope.M_AddEditUO.PriceAndCostTrackingWrapperList.length;
                setTimeout(function () {
                    angular.element("#factoryOptionId").focus();
                }, 100);
            }

            $scope.F_AddEditUO.createBasePrice = function () {
                if (!isBlankValue($scope.M_AddEditUO.unitId)) {
                    createBasePrice();
                } else {
                    var successJson = {
                        'calleeMethodName': 'saveUnitDetails',
                        'callback': createBasePrice
                    };
                    createUnit(successJson);
                }
            }

            $scope.F_AddEditUO.disablePricing = function () {
                if (isBlankValue($scope.M_AddEditUO.unitRec.Make) || isBlankValue($scope.M_AddEditUO.unitRec.Model) || isBlankValue($scope.M_AddEditUO.tempFactory.TotalCost) ||
                    isBlankValue($scope.M_AddEditUO.tempFactory.TotalPrice)) {
                    return true;
                } else {
                    return false;
                }
            }

            $scope.F_AddEditUO.calculateTotalValue = function () {
                $scope.M_AddEditUO.totalPriceForPriceAndCost = 0;
                $scope.M_AddEditUO.unitRec.TotalCost = 0;
                for (var i = 0; i < $scope.M_AddEditUO.PriceAndCostTrackingWrapperList.length; i++) {
                    if ($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[i].TotalPrice) {
                        $scope.M_AddEditUO.totalPriceForPriceAndCost += parseFloat($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[i].TotalPrice);
                    }
                    if ($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[i].TotalCost) {
                        $scope.M_AddEditUO.unitRec.TotalCost += parseFloat($scope.M_AddEditUO.PriceAndCostTrackingWrapperList[i].TotalCost)
                    }
                }
            }
            $scope.F_AddEditUO.deleteFactortoption = function () {
                $scope.M_AddEditUO.showFactoryOptionRec = false;
                $scope.M_AddEditUO.tempFactory = {};
                $scope.M_AddEditUO.tempFactory.Type = 'Factory';
                $scope.F_AddEditUO.calculateTotalValue();

                $scope.M_AddEditUO.isEdit = -1;
            }
            
            $scope.F_AddEditUO.getCategoryList = function () {
                $scope.M_AddEditUO.showCategoryList = true;
                document.getElementById('categoryDropDownDiv').scrollTop = 0;
            }
            
            $scope.F_AddEditUO.hideCategoryList = function () {
                $scope.M_AddEditUO.showCategoryList = false;
            }
            
            $scope.F_AddEditUO.getTagsList = function () {
                $scope.M_AddEditUO.showTagsList = true;
                document.getElementById('tagDropDownDiv').scrollTop = 0;
                $scope.F_AddEditUO.resetTagList();
            }
            
            $scope.F_AddEditUO.hideTagsList = function () {
                $scope.M_AddEditUO.showTagsList = false;
            }
            
            $scope.F_AddEditUO.showAdditionalField = function (key) {
                $scope.M_AddEditUO.AdditionalFieldsInfo[key].isPrimary = true;
                if (key == 'Category') {
                    if ($scope.M_AddEditUO.UnitCategoryList != undefined) {
                        var defaultCategoryIndex = _.findIndex($scope.M_AddEditUO.UnitCategoryList, {
                            IsDefault: true
                        });
                        if (defaultCategoryIndex > -1) {
                            $scope.M_AddEditUO.UnitCategoryName = $scope.M_AddEditUO.UnitCategoryList[defaultCategoryIndex].Name;
                            $scope.M_AddEditUO.unitRec.Category = $scope.M_AddEditUO.UnitCategoryList[defaultCategoryIndex].Id;
                            $scope.M_AddEditUO.unitRec.CategoryName = $scope.M_AddEditUO.UnitCategoryList[defaultCategoryIndex].Name;
                        }
                    }
                }
            }

            function loadAddEditUnitOrderData() {
                var setLoadingVariableIndsideGetVendorDetails = false;
                var setDefaultTaxableField = false;
                if ($stateParams.vendorId) {
                    $scope.M_AddEditUO.unitId = '';
                    $scope.M_AddEditUO.vendorId = $stateParams.vendorId;
                    $scope.M_AddEditUO.unitRec.VendorId = $stateParams.vendorId;
                    $scope.M_UO.vendorId = $stateParams.vendorId;
                    $scope.M_UO.unitNumber = '';
                    $scope.M_UO.coNumber = '';
                    if ($stateParams.unitId) {
                        $scope.M_AddEditUO.isURLContainsUnitId = true;
                        $scope.M_AddEditUO.unitId = $stateParams.unitId;
                        $scope.M_AddEditUO.isEditMode = false;
                        getUnitDetails();
                    } else {
                        setLoadingVariableIndsideGetVendorDetails = true;
                        setDefaultTaxableField = true;
                    }
                    getVendorDetails(setLoadingVariableIndsideGetVendorDetails);
                    //getMakeList();
                    getMakeModelSubmodelList();
                    getApplicableTaxList(setDefaultTaxableField);
                    getUnitCategoryList();
                    getActiveTagList();
                } else if ($rootScope.AddEditUnitOrderParams && $rootScope.AddEditUnitOrderParams.vendorId) {
                	$scope.M_UO.coNumber = '';
                    var AddEditUnitOrderParamsJson = {
                        'vendorId': $rootScope.AddEditUnitOrderParams.vendorId
                    };
                    if ($rootScope.AddEditUnitOrderParams.unitId) {
                        AddEditUnitOrderParamsJson.unitId = $rootScope.AddEditUnitOrderParams.unitId;
                    }
                    $state.go('UnitOrdering.AddeditUnitOrder', AddEditUnitOrderParamsJson);
                }
                angular.element('html, body').stop().animate({
                    scrollTop: 0
                }, 1);
            }
            
            $scope.F_AddEditUO.editAddEditUnitRecord = function () {
                $scope.M_AddEditUO.isEditMode = true;
                $scope.M_AddEditUO.vehicleSpecificationsResult = '';
                filterMakeModelSubmodelList();
                
            }
            
            $scope.F_AddEditUO.addEditUnitOrderViewModeEnable = function () {
                $scope.M_AddEditUO.isEditMode = false;
                setUnitRecDefault($scope.M_AddEditUO.tempUnitData.UnitInfo)
            }
            
            $scope.F_AddEditUO.resetUnitData = function () {
                setUnitRecDefault($scope.M_AddEditUO.tempUnitData.UnitInfo)
            }
            
            function setUnitRecDefault(unitRec) {
                $scope.M_AddEditUO.unitRec = angular.copy(unitRec);
                if ($scope.M_AddEditUO.unitRec.IsNewUnit) {
                    $scope.M_AddEditUO.unitRec.Condition = 'New';
                } else {
                    $scope.M_AddEditUO.unitRec.Condition = 'Used';
                }
                $scope.M_AddEditUO.unitRec.VIN = (!$scope.M_AddEditUO.unitRec.VIN || $scope.M_AddEditUO.unitRec.VIN === 'VIN Unknown') ? '' : $scope.M_AddEditUO.unitRec.VIN ;
                
                var additionalUnitField = $scope.M_AddEditUO.AdditionalFieldsInfo;
                for (var key in additionalUnitField) {

                    if (additionalUnitField.hasOwnProperty(key)) {
                        if ($scope.M_AddEditUO.unitRec[key] != null && $scope.M_AddEditUO.unitRec[key] != undefined && $scope.M_AddEditUO.unitRec[key] != '') {
                            additionalUnitField[key].isPrimary = true;
                        } else {
                            additionalUnitField[key].isPrimary = false;
                        }
                    }
                }
                
                $scope.M_AddEditUO.UnitMakeName = $scope.M_AddEditUO.unitRec.MakeName;
                $scope.M_AddEditUO.UnitCategoryName = $scope.M_AddEditUO.unitRec.CategoryName;
                if ($scope.M_AddEditUO.unitRec.AssignedTags.length == 0) {
                        $scope.M_AddEditUO.AdditionalFieldsInfo.AssignedTags.isPrimary = false;
                }
            }
            function getVendorDetails(setLoadingVariableIndsideGetVendorDetails) {
                if ($scope.M_AddEditUO.vendorId) {
                    var successJson = {
                        'calleeMethodName': 'getVendorDetails',
                        'setLoadingVariableIndsideGetVendorDetails': setLoadingVariableIndsideGetVendorDetails
                    };
                    UnitOrderingService.getVendorDetails($scope.M_AddEditUO.vendorId).then(new success(successJson).handler, new error().handler);
                }
            }

           /*  function getMakeList() {
                var successJson = {
                    'calleeMethodName': 'getUnitmakeList'
                };
                VINOperationsService.getUnitmakeList().then(new success(successJson).handler, new error().handler);
            } */
            function getMakeModelSubmodelList() {
                VINOperationsService.getMakeModelSubmodelList().then(function(response) {
                    /* $scope.M_AddEditUO.unitRec.SubModelName = '';
                    $scope.M_AddEditUO.unitRec.ModelName = ''; */
                    $scope.M_AddEditUO.UnitMakeList = response.MakeList;
                    tempMakelist = angular.copy(response.MakeList);
                    tempModelList = angular.copy(response.ModelList);
                    tempSubModelList = angular.copy(response.SubModelList);

                    $scope.M_AddEditUO.UnitModelList = response.ModelList;
                    $scope.M_AddEditUO.UnitSubModelList = response.SubModelList;
                    console.log(response);
                    console.log("response");
                }).catch(function(error) {
                  handleErrorAndExecption(error);
                });
            }

            function getActiveTagList() {
                var successJson = {
                    'calleeMethodName': 'getActiveTagList'
                };
                VINOperationsService.getActiveTagList().then(new success(successJson).handler, new error().handler);
            }

            function createBasePrice() {
                $scope.M_AddEditUO.tempFactory.Type = 'Base';
                $scope.M_AddEditUO.tempFactory.ItemDescription = 'Base - Unit'
                $scope.M_AddEditUO.tempFactory.UnitId = $scope.M_AddEditUO.unitId;
                savePriceAndCost($scope.M_AddEditUO.tempFactory);
            }

            function createUnit(successJson) {
                $scope.M_AddEditUO.unitRec.Status = 'On Order';
                $scope.M_AddEditUO.unitRec.UnitType = 'ORDU';
                $scope.M_AddEditUO.unitRec.IsNewUnit = ($scope.M_AddEditUO.unitRec.Condition && $scope.M_AddEditUO.unitRec.Condition == 'New')? true:false;
                $scope.M_AddEditUO.unitRecWrapper.UnitInfo = $scope.M_AddEditUO.unitRec;
                $scope.M_AddEditUO.unitRecWrapper.PriceAndCostTrackingWrapperList = $scope.M_AddEditUO.PriceAndCostTrackingWrapperList;
                $scope.M_UO.isLoading = true;
                UnitOrderingService.saveUnitDetails(angular.toJson($scope.M_AddEditUO.unitRecWrapper)).then(new success(successJson).handler, new error().handler);
            }

            function getUnitDetails() {
                var successJson = {
                    'calleeMethodName': 'getUnitDetails'
                };
                UnitOrderingService.getUnitDetails($scope.M_AddEditUO.unitId).then(new success(successJson).handler, new error().handler);
            }

            function savePriceAndCost(priceAndCostJson) {
                var successJson = {
                    'calleeMethodName': 'savePriceAndCost'
                };
                $scope.M_UO.isLoading = true;
                UnitOrderingService.savePriceAndCost($scope.M_AddEditUO.unitId, angular.toJson(priceAndCostJson)).then(new success(successJson).handler, new error().handler);
            }

            function getApplicableTaxList(setDefaultTaxableField) {
                var successJson = {
                    'calleeMethodName': 'getApplicableTaxList'
                };
                if (setDefaultTaxableField) {
                    successJson['callback'] = $scope.F_AddEditUO.setTaxable;
                }
                VINOperationsService.getApplicableTaxList().then(new success(successJson).handler, new error().handler);
            }

            function getUnitCategoryList() {
                var successJson = {
                    'calleeMethodName': 'getUnitCategoryList'
                };
                UnitOrderingService.getUnitCategoryList().then(new success(successJson).handler, new error().handler);
            }

            $scope.F_AddEditUO.setTaxable = function () {
                $scope.M_AddEditUO.unitRec.IsTaxable = !$scope.M_AddEditUO.unitRec.IsTaxable;
                if ($scope.M_AddEditUO.unitRec.IsTaxable) {
                    if ($scope.M_AddEditUO.ApplicableTaxList != undefined) {
                        var defaultTaxIndex = _.findIndex($scope.M_AddEditUO.ApplicableTaxList, {
                            IsDefault: true
                        });
                        if (defaultTaxIndex > -1) {
                            $scope.M_AddEditUO.unitRec.ApplicableTax = $scope.M_AddEditUO.ApplicableTaxList[defaultTaxIndex].Id;
                            $scope.M_AddEditUO.unitRec.ApplicableTaxName = $scope.M_AddEditUO.ApplicableTaxList[defaultTaxIndex].Name;
                        }
                    }
                } else {
                    $scope.M_AddEditUO.unitRec.ApplicableTax = null;
                    $scope.M_AddEditUO.unitRec.ApplicableTaxName = null;
                }
            }

            $scope.F_AddEditUO.changeApplicableTax = function (tax) {
                $scope.M_AddEditUO.unitRec.ApplicableTax = tax.Id;
                $scope.M_AddEditUO.unitRec.ApplicableTaxName = tax.Name;
            }

            $scope.F_AddEditUO.selectTansmissionType = function (type) {
                $scope.M_AddEditUO.unitRec.TransmissionType = type;
                if (type == 'Automatic') {
                    $scope.M_AddEditUO.unitRec.IsAutomatic = true;
                    $scope.M_AddEditUO.unitRec.Gears = null
                } else {
                    $scope.M_AddEditUO.unitRec.IsAutomatic = false;
                }
            }

            $scope.F_AddEditUO.selectMileageType = function (type) {
                $scope.M_AddEditUO.unitRec.MileageType = type;
            }

            $scope.F_AddEditUO.changeUnitCategory = function (cateory) {
                $scope.M_AddEditUO.UnitCategoryName = cateory.Name;
                $scope.M_AddEditUO.unitRec.Category = cateory.Id;
                $scope.M_AddEditUO.unitRec.CategoryName = cateory.Name;
            }

            $scope.F_AddEditUO.selectUnitCondition = function (conditionValue) {
                $scope.M_AddEditUO.unitRec.Condition = conditionValue;
                if (conditionValue == 'New') {
                    $scope.M_AddEditUO.unitRec.IsNewUnit = true;
                } else {
                    $scope.M_AddEditUO.unitRec.IsNewUnit = false;
                }
            }

            $scope.F_AddEditUO.resetTagList = function () {
                for (var i = 0; i < $scope.M_AddEditUO.unitRec.AssignedTags.length; i++) {
                    var index = _.findIndex($scope.M_AddEditUO.ActiveTagList, {
                        Name: $scope.M_AddEditUO.unitRec.AssignedTags[i]
                    });
                    if (index > -1) {
                        $scope.M_AddEditUO.ActiveTagList.splice(index, 1);
                    }
                }
            }

            $scope.F_AddEditUO.selectTag = function (tagObj) {
                var index = _.findIndex($scope.M_AddEditUO.ActiveTagList, {
                    Name: tagObj.Name
                });
                if (index > -1) {
                    if ($scope.M_AddEditUO.unitRec.AssignedTags.length < 20) {
                        $scope.M_AddEditUO.unitRec.AssignedTags.push(tagObj.Name);
                        $scope.M_AddEditUO.ActiveTagList.splice(index, 1);
                    } else {
                        Notification.error($translate.instant('Part_tag_limit_error'));
                    }
                }
                $scope.M_AddEditUO.TagNameStr = '';
            }

            $scope.F_AddEditUO.removeTag = function (tagObj, index) {
                if (index > -1) {
                    $scope.M_AddEditUO.unitRec.AssignedTags.splice(index, 1);
                    $scope.M_AddEditUO.ActiveTagList.push({
                        Name: tagObj
                    });
                }
            }

            $scope.F_AddEditUO.isValidVIN = function (value) {
                /*if (!value) {
                    return true;
                }
                return validateVin(value);*/
            	return true;
            }

            loadAddEditUnitOrderData();
        }
    ])
})