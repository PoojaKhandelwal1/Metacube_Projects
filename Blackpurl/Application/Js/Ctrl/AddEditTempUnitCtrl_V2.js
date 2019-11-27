define(['Routing_AppJs_PK', 'AddEditUnitServices', 'UnitOrderingServices', 'CustomerOrderServices_V2', 'underscore_min', 'NumberOnlyInput_New', 'JqueryUI', 'moment', 'momentTimezone', 'InfoCardComponent'], function (Routing_AppJs_PK, AddEditUnitServices, UnitOrderingServices, CustomerOrderServices_V2, underscore_min, NumberOnlyInput_New, JqueryUI, moment, momentTimezone, InfoCardComponent) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddEditTempUnitCtrl_V2', ['$scope', '$rootScope', '$state', '$stateParams', 'VINOperationsService', 'CustomerOwnedUnitService', 'UnitOrderingService', 'DealService','$translate', '$q', function ($scope, $rootScope, $state, $stateParams, VINOperationsService, CustomerOwnedUnitService, UnitOrderingService, DealService, $translate, $q) {
        var Notification = injector.get("Notification");
        
        $scope.M_AddEditUnit = $scope.M_AddEditUnit || {};
        $scope.F_AddEditUnit = $scope.F_AddEditUnit || {};
        $scope.M_AddEditUnit.unitRec = {};
        $scope.M_AddEditUnit.showMakeList = false;
        $scope.M_AddEditUnit.showModelList = false;
        $scope.M_AddEditUnit.showSubModelList = false;
        $scope.M_AddEditUnit.UnitMakeName = '';
        $scope.M_AddEditUnit.unitRec.AssignedTags = [];
        $scope.M_AddEditUnit.unitRec.MakeName = '';
        $scope.M_AddEditUnit.TagNameStr = '';
        $scope.M_AddEditUnit.unitRec.MileageType = 'Km';
        $scope.M_AddEditUnit.Years = [];
        $scope.M_AddEditUnit.similarCOUList = [];
        $scope.M_AddEditUnit.SearchYear = '';
        $scope.M_AddEditUnit.SearchYearYearof1stRego = '';
        var tempMakelist = [];
        var tempModelList = [];
        var tempSubModelList = [];
        $scope.M_AddEditUnit.UnitActionsWithType = {
            'Temp Unit': $translate.instant('Set_temporary_unit'),
            'COU': $translate.instant('Add_a_new_customer_owned_unit')
        };
        $scope.M_AddEditUnit.TransmissionTypeList = ['Automatic', 'Manual'];
        $scope.M_AddEditUnit.MileageTypeList = ['Km', 'Mi', 'Hrs'];
        
        var vehicleSpecification;
        
        $scope.F_AddEditUnit.keydownForVIN = function(event) {
        	var keyCode = event.which ? event.which : event.keyCode;
        	if(keyCode == 9 && !isBlankValue($scope.M_AddEditUnit.unitRec.VIN)) {
        		event.preventDefault();
        		angular.element('#VIN_Unit').blur();
        	}
        }
        
        $scope.M_AddEditUnit.vehicleSpecificationsResult = '';
        $scope.F_AddEditUnit.getVehicleSpecification = function() {
        	if(!$Global.isBRPEnabled) {
        		return;
        	}
        	if(isBlankValue($scope.M_AddEditUnit.unitRec.VIN)) {
        		$scope.M_AddEditUnit.vehicleSpecificationsResult = '';
        		return;
        	}
        	$scope.M_AddEditUnit.vehicleSpecificationsResult = 'Loading'
        	CustomerOwnedUnitService.getVehicleSpecification($scope.M_AddEditUnit.unitRec.VIN).then(function(successResult) {
        		if(successResult.responseCode == 400) {
        			$scope.M_AddEditUnit.vehicleSpecificationsResult = 'Match not found';
        		} else {
        			$scope.M_AddEditUnit.vehicleSpecificationsResult = 'Match found';
        			vehicleSpecification = successResult;
        			vehicleSpecification.MakeName = 'BRP';
        			setVehicleFormattedName();
        		}
	        }, function(errorSearchResult) {
	            Notification.error("Error in getting vehicle specification");
	        });
        }
        
        $scope.F_AddEditUnit.setDataFromBRP = function() {
        	if(isBlankValue($scope.M_AddEditUnit.unitRec.MakeName)) {
        		$scope.M_AddEditUnit.unitRec.MakeName = '';
    		}
			if(isBlankValue($scope.M_AddEditUnit.unitRec.ModelName)) {
				$scope.M_AddEditUnit.unitRec.ModelName = '';
    		}
			if(isBlankValue($scope.M_AddEditUnit.unitRec.SubModelName)) {
				$scope.M_AddEditUnit.unitRec.SubModelName = '';
    		}
    		if($scope.M_AddEditUnit.unitRec.MakeName.toLowerCase() != vehicleSpecification.MakeName.toLowerCase()) {
    			$scope.M_AddEditUnit.unitRec.MakeName = vehicleSpecification.MakeName;
    			$scope.M_AddEditUnit.unitRec.Make = null;
    			$scope.M_AddEditUnit.unitRec.Model = null;
    			$scope.M_AddEditUnit.unitRec.SubModel = null;
    			$scope.M_AddEditUnit.UnitValidation['MakeName']['isError'] = false;
    		}
    		
    		if($scope.M_AddEditUnit.unitRec.ModelName.toLowerCase() != vehicleSpecification.Model.toLowerCase()) {
    			$scope.M_AddEditUnit.unitRec.ModelName = vehicleSpecification.Model;
    			$scope.M_AddEditUnit.unitRec.Model = null;
    			$scope.M_AddEditUnit.unitRec.SubModel = null;
    			$scope. M_AddEditUnit.UnitValidation['ModelName']['isError'] = false;
    		}
    		
    		if($scope.M_AddEditUnit.unitRec.SubModelName.toLowerCase() != vehicleSpecification.ModelDescription.toLowerCase()) {
    			$scope.M_AddEditUnit.unitRec.SubModelName = vehicleSpecification.ModelDescription;
    			$scope.M_AddEditUnit.unitRec.SubModel = null;
    		}
    		
    		$scope.M_AddEditUnit.unitRec.Year = vehicleSpecification.ModelYear;
    		if(!isBlankValue($scope.M_AddEditUnit.unitRec.Year)) {
    			$scope.M_AddEditUnit.unitRec.Year = parseFloat($scope.M_AddEditUnit.unitRec.Year);
    		}
        	$scope.M_AddEditUnit.SearchYear = vehicleSpecification.ModelYear;
    		
        	if(vehicleSpecification.Engine) {
            	$scope.M_AddEditUnit.unitRec.Cylinders = vehicleSpecification.Engine.NumberOfEngineCylindersNumeric;
            	if(!isBlankValue($scope.M_AddEditUnit.unitRec.Cylinders)) {
            		$scope.M_AddEditUnit.unitRec.Cylinders = parseFloat($scope.M_AddEditUnit.unitRec.Cylinders);
        			$scope.M_AddEditUnit.AdditionalFieldsInfo.Cylinders.isPrimary = true;
        		}
        	}
        }
        
        setLoadingFlag = function(value) {
        	if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                $scope.M_CO.isLoading = value;
            } else {
                $scope.M_AddEditUnit.isLoading = value;
            }
        }
        
        getMatchedValueFromList = function(listToIterate, valueToMatch, entityName) {
        	var exists = _.filter(listToIterate, function (term) {
        		if(entityName == 'Make') {
        			return term.UnitMakeName.toLowerCase() == $scope.M_AddEditUnit.unitRec.MakeName.toLowerCase();
        		} else if(entityName == 'Model') {
        			return term.UnitModelName.toLowerCase() == valueToMatch.toLowerCase();
        		} else if(entityName == 'Submodel') {
        			return term.SubModelName.toLowerCase() == valueToMatch.toLowerCase();
        		}
            });
        	return exists;
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
        	vehicleSpecification.formattedName = formattedName;
        	createVehiclePayload();
        }
        
        createVehiclePayload = function() {
        	$scope.M_AddEditUnit.unitCardInfoPayload = {
            		headerText: vehicleSpecification.formattedName,
            		buttonActionVisible: true,
            		buttonText: 'Use'
            }
        }

        var success = function () {
            var self = this;
            this.arguments = arguments[0];
            this.calleeMethodName = arguments[0].calleeMethodName,
                this.callback = arguments[0].callback,
                this.handler = function (successResult) {
                    switch (self.calleeMethodName) {
                        case 'saveTemporaryUnit':
                            handleSaveTemporaryUnitResponse(successResult);
                            break;
                        case 'addCustomerOwnedUnit':
                            handleAddCustomerOwnedUnitResponse(successResult);
                            break;
                        case 'getActiveTagList':
                            handleGetActiveTagListResponse(successResult);
                            break;
                        case 'getUnitCategoryList':
                            handleGetUnitCategoryListResponse(successResult);
                            break;
                        default:
                            break;
                    }

                    if (typeof self.callback === 'function') {
                        self.callback();
                    }
                }

            function handleGetUnitmakeListResponse(unitMakeList) {
                /* $scope.M_AddEditUnit.UnitMakeList = unitMakeList; */
            }
/* 
            function handleGetUnitModelListResponse(unitModelList) {
                $scope.M_AddEditUnit.showModelList = true;
                $scope.M_AddEditUnit.UnitModelList = unitModelList;
            } */

            /* function handleGetUnitSubModelListResponse(unitSubModelList) {
                $scope.M_AddEditUnit.showSubModelList = true;
                $scope.M_AddEditUnit.UnitSubModelList = unitSubModelList;
            } */

            function handleGetActiveTagListResponse(tagList) {
                $scope.M_AddEditUnit.ActiveTagList = tagList;
            }

            function handleGetUnitCategoryListResponse(categoryList) {
                $scope.M_AddEditUnit.UnitCategoryList = categoryList;
            }

            function handleSaveTemporaryUnitResponse(successResult) {
                $scope.F_AddEditUnit.hideAddEditUnitOrderModal();
                $scope.M_CO.Deal = successResult;
                $scope.M_CO.coHeaderRec.OrderTotal = successResult.DealInfo.OrderTotal;
                $scope.M_CO.coHeaderRec.InvoicedAmount = successResult.DealInfo.InvoicedAmount;
                $scope.M_CO.coHeaderRec.UninvoicedAmount = successResult.DealInfo.UninvoicedAmount;

                if (self.arguments.unitIndex != undefined) {
                    setTimeout(function () {
                        $scope.M_CO.expandedDivFlag = false;
                        $scope.M_CO.expandedInnerDivFlag = false;
                        $scope.M_CO.expandedInner2DivFlag = false;
                        $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                        $scope.F_CO.expandInnerSection('Deal_DU' + self.arguments.unitIndex + '_SectionId', 'Deal_DU' + self.arguments.unitIndex);
                        $scope.F_CO.expandInner2Section('Deal_DU' + self.arguments.unitIndex + '_InfoSectionId', 'Deal_DU' + self.arguments.unitIndex + '_Info');
                    }, 100);
                }
            }

           function handleAddCustomerOwnedUnitResponse(COUList) {
            	if($state.current.name.indexOf('CustomerOrder_V2') > -1) {
            		if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                        $scope.M_CO.COUList.push(COUList[0]);
                    }
                    var sectionIndex = $stateParams.AddEditTempUnitParams.SectionIndex;
                    if ($stateParams.AddEditTempUnitParams.SectionName == 'Service Job') {
                        $scope.M_CO.SOHeaderList[sectionIndex].SOInfo.UnitId = COUList[0].Id;
                        $scope.F_CO.saveServiceJobInfo(sectionIndex);
                    } else if ($stateParams.AddEditTempUnitParams.SectionName == 'Trade In') {
                        $scope.M_CO.TradeIn.selectedUnitId = COUList[0].Id;
                        $scope.F_CO.saveTradeInUnit(sectionIndex);
                    }
            	}
                
                $scope.F_AddEditUnit.hideAddEditUnitOrderModal(COUList[0].Id);
            }
        }

        //TODO common error handling
        var error = function (errorMessage) {
            this.handler = function (error) {
                if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                    $scope.M_CO.isLoading = false;
                } else {
                    $scope.M_AddEditUnit.isLoading = false;
                }
                if (!errorMessage) {
                    console.log(error);
                } else {
                    console.log(errorMessage);
                }
            }
        }

        $scope.M_AddEditUnit.AdditionalFieldsInfo = {
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
            OtherSerialNo: {
                isPrimary: false,
                label: 'Other Serial #',
                fieldId: 'OtherSerialID'
            },
            Tags: {
                isPrimary: false,
                label: 'Tags',
                fieldId: 'TagsId'
            },
            ComplianceDate: {
                isPrimary: false,
                label: 'Compliance Date',
                fieldId: 'ComplianceDateId'
            },
            Yearof1stRego: {
                isPrimary: false,
                label: 'Year of 1st Rego',
                fieldId: 'Yearof1stRegoId'
            },
            RegistrationSerial: {
                isPrimary: false,
                label: 'Registration Serial#',
                fieldId: 'RegistrationSerialId'
            }
        };
        $scope.M_AddEditUnit.dateFormat = $Global.DateFormat;
        $scope.M_AddEditUnit.CurrentUserTZSIDKey = $Global.CurrentUserTZSIDKey;
        $scope.M_AddEditUnit.SchedulingDateFormat = $Global.SchedulingDateFormat;
        $scope.M_AddEditUnit.RegExpDateOptions = {
            dateFormat: $scope.M_AddEditUnit.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        
        $scope.M_AddEditUnit.ComplianceDateOptions = {
            dateFormat: $scope.M_AddEditUnit.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        $scope.M_AddEditUnit.ManufactureDateOptions = {
            dateFormat: $scope.M_AddEditUnit.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };

        function openAddEditUnitOrderModal() {
            setTimeout(function () {
                angular.element('#tempUnitMmodal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                    $scope.M_CO.isLoading = false;
                }
            }, 100);
        }

        angular.element(document).on("click", "#tempUnitMmodal .modal-backdrop", function (event) {
            $scope.F_AddEditUnit.hideAddEditUnitOrderModal();
        });

        $scope.F_AddEditUnit.showAdditionalField = function (key) {
            $scope.M_AddEditUnit.AdditionalFieldsInfo[key].isPrimary = true;
            if (key == 'Category') {
                if ($scope.M_AddEditUnit.UnitCategoryList != undefined) {
                    var defaultCategoryIndex = _.findIndex($scope.M_AddEditUnit.UnitCategoryList, {
                        IsDefault: true
                    });
                    if (defaultCategoryIndex > -1) {
                        $scope.M_AddEditUnit.UnitCategoryName = $scope.M_AddEditUnit.UnitCategoryList[defaultCategoryIndex].Name;
                        $scope.M_AddEditUnit.unitRec.Category = $scope.M_AddEditUnit.UnitCategoryList[defaultCategoryIndex].Id;
                        $scope.M_AddEditUnit.unitRec.CategoryName = $scope.M_AddEditUnit.UnitCategoryList[defaultCategoryIndex].Name;
                    }
                }
            }
        }

        $scope.F_AddEditUnit.hideAddEditUnitOrderModal = function (unitId) {
            angular.element('#tempUnitMmodal').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                $scope.M_CO.isLoading = false;
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            } else if ($rootScope.$previousState.name === 'CustomerOrder_V2.AddEditCustomerV2') {
                $scope.M_AddEditUnit.isLoading = false;
                var selectedCustomerWithCOUJson = {
                    CustomerId: $stateParams.AddEditTempUnitParams.CustomerId,
                    SellingGroup: $stateParams.AddEditTempUnitParams.SellingGroup,
                    addCustomerCoBuyer : $stateParams.AddEditTempUnitParams.addCustomerCoBuyer
                }
                $rootScope.$broadcast('selectedCustomerWithCOUCallback', selectedCustomerWithCOUJson);
            } else if ($rootScope.$previousState.name === 'AddEditCustomerV2') {
                $scope.M_AddEditUnit.isLoading = false;
                loadState($state, 'ViewCustomer', {
                    Id: $stateParams.AddEditTempUnitParams.CustomerId
                });
            } else if($rootScope.$previousState.name.indexOf('AddEditAppointment') > -1) {
            	$scope.M_AddEditUnit.isLoading = false;
            	var customerId = $stateParams.AddEditTempUnitParams.CustomerId;
            	if(unitId) {
            		$scope.F_AddEditApp.COUSaveCallback(customerId, unitId, ($rootScope.$previousState.name == 'AddEditAppointment.AddEditCustomerV2'));
            	}
                loadState($state, 'AddEditAppointment');
            }
        }

        $scope.F_AddEditUnit.clearMakeModelSubModelValue = function () {
            var exists = _.filter($scope.M_AddEditUnit.UnitMakeList, function (term) {
                return term.UnitMakeName.toLowerCase() == $scope.M_AddEditUnit.unitRec.MakeName.toLowerCase();
            });
            if (exists.length == 0) {
                $scope.M_AddEditUnit.unitRec.Make = null;
                $scope.M_AddEditUnit.unitRec.Model = null;
                $scope.M_AddEditUnit.unitRec.ModelName = '';
                $scope.M_AddEditUnit.unitRec.SubModel = null;
                $scope.M_AddEditUnit.unitRec.SubModelName = '';
                filterMakeModelSubmodelList();
            } else {
                $scope.M_AddEditUnit.unitRec.Make = exists[0].Id;
                $scope.M_AddEditUnit.unitRec.MakeName = exists[0].UnitMakeName;
            }
        }

        $scope.F_AddEditUnit.clearModelSubModelValue = function () {
            var exists = _.filter($scope.M_AddEditUnit.UnitModelList, function (term) {
                return term.UnitModelName.toLowerCase() == $scope.M_AddEditUnit.unitRec.ModelName.toLowerCase();
            });
            if (exists.length == 0) {
                $scope.M_AddEditUnit.unitRec.Model = null;
                $scope.M_AddEditUnit.unitRec.SubModel = null;
                $scope.M_AddEditUnit.unitRec.SubModelName = '';
                filterMakeModelSubmodelList();
            } else {
                $scope.M_AddEditUnit.unitRec.Model = exists[0].Id;
                $scope.M_AddEditUnit.unitRec.ModelName = exists[0].UnitModelName;
            }
        }

        $scope.F_AddEditUnit.clearSubModelValue = function () {
            var exists = _.filter($scope.M_AddEditUnit.UnitSubModelList, function (term) {
                if(term.SubModelName) {
                    return term.SubModelName.toLowerCase() == $scope.M_AddEditUnit.unitRec.SubModelName.toLowerCase();
                }
            });
            if (exists.length == 0) {
                $scope.M_AddEditUnit.unitRec.SubModel = null;
            } else {
                $scope.M_AddEditUnit.unitRec.SubModel = exists[0].Id;
                $scope.M_AddEditUnit.unitRec.SubModelName = exists[0].SubModelName;
            }
        }

        function loadAddUnitOrderModalData() {
            openAddEditUnitOrderModal();
            getUnitCategoryList();
            getActiveTagList();
            getMakeModelSubmodelList();
        }

        function getMakeModelSubmodelList() {
            VINOperationsService.getMakeModelSubmodelList().then(function(response) {
                $scope.M_AddEditUnit.unitRec.SubModelName = '';
                $scope.M_AddEditUnit.unitRec.ModelName = '';
                $scope.M_AddEditUnit.UnitMakeList = response.MakeList;
                $scope.M_AddEditUnit.UnitModelList = response.ModelList;
                $scope.M_AddEditUnit.UnitSubModelList = response.SubModelList;
                tempMakelist = angular.copy(response.MakeList);
                tempModelList = angular.copy(response.ModelList);
                tempSubModelList = angular.copy(response.SubModelList);
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

        function getUnitCategoryList() {
            var successJson = {
                'calleeMethodName': 'getUnitCategoryList'
            };
            UnitOrderingService.getUnitCategoryList().then(new success(successJson).handler, new error().handler);
        }
        $scope.F_AddEditUnit.getMakeList = function () {
            $scope.M_AddEditUnit.showMakeList = true;
            document.getElementById('makeDropDownDiv').scrollTop = 0;
            filterMakeModelSubmodelList();
        }
        $scope.F_AddEditUnit.getSubModelList = function () {
            $scope.M_AddEditUnit.showSubModelList = true;
            document.getElementById('subModelDropDownDiv').scrollTop = 0;
            $scope.M_AddEditUnit.UnitSubModelList = tempSubModelList;
            filterMakeModelSubmodelList();
            
        }
        function filterMakeModelSubmodelList() {
            $scope.M_AddEditUnit.UnitMakeList = tempMakelist;
            $scope.M_AddEditUnit.UnitModelList = tempModelList;
            $scope.M_AddEditUnit.UnitSubModelList = tempSubModelList;
            if($scope.M_AddEditUnit.unitRec.Make) {
                var UnitModelList = [];
                var unitSubModelList = [];
            for(var i=0;i<$scope.M_AddEditUnit.UnitModelList.length;i++){
                if($scope.M_AddEditUnit.unitRec.Make == $scope.M_AddEditUnit.UnitModelList[i].MakeId) {
                    UnitModelList.push($scope.M_AddEditUnit.UnitModelList[i]);
                }
            } 
            for(var i=0;i<UnitModelList.length;i++) {
                for(var j=0;j<$scope.M_AddEditUnit.UnitSubModelList.length;j++){
                    if((!$scope.M_AddEditUnit.unitRec.Model || $scope.M_AddEditUnit.unitRec.Model == $scope.M_AddEditUnit.UnitSubModelList[j].ModelId) && UnitModelList[i].Id == $scope.M_AddEditUnit.UnitSubModelList[j].ModelId) {
                        unitSubModelList.push($scope.M_AddEditUnit.UnitSubModelList[j]);
                    }
                }
            }
            $scope.M_AddEditUnit.UnitModelList = UnitModelList;
            $scope.M_AddEditUnit.UnitSubModelList = unitSubModelList;

        }
    }
        $scope.F_AddEditUnit.getModelList = function () {
            $scope.M_AddEditUnit.showModelList = true;
            document.getElementById('modelDropDownDiv').scrollTop = 0;
            filterMakeModelSubmodelList();
        }
        $scope.F_AddEditUnit.hideTagsList = function () {
            $scope.M_AddEditUnit.showTagsList = false;
        }

        $scope.F_AddEditUnit.resetTagList = function () {
            for (var i = 0; i < $scope.M_AddEditUnit.unitRec.AssignedTags.length; i++) {
                var index = _.findIndex($scope.M_AddEditUnit.ActiveTagList, {
                    Name: $scope.M_AddEditUnit.unitRec.AssignedTags[i]
                });
                if (index > -1) {
                    $scope.M_AddEditUnit.ActiveTagList.splice(index, 1);
                }
            }
        }

        $scope.F_AddEditUnit.getYears = function (attr) {
           if(attr == 'Year') {
            $scope.M_AddEditUnit.showYears = true;
            document.getElementById('yearDropDownDiv').scrollTop = 0;
           } else {
            $scope.M_AddEditUnit.showYearof1stRegoYears = true;
            document.getElementById('Yearof1stRegoDropDownDiv').scrollTop = 0;
           }
            
        }
        $scope.F_AddEditUnit.getTagsList = function () {
            $scope.M_AddEditUnit.showTagsList = true;
            document.getElementById('tagDropDownDiv').scrollTop = 0;
            $scope.F_AddEditUnit.resetTagList();
        }

        $scope.F_AddEditUnit.selectMileageType = function (type) {
            $scope.M_AddEditUnit.unitRec.MileageType = type;
        }

        $scope.F_AddEditUnit.hideMakeList = function () {
            $scope.M_AddEditUnit.showMakeList = false;
        }
        $scope.F_AddEditUnit.hideModelList = function () {
            $scope.M_AddEditUnit.showModelList = false;
        }

        $scope.F_AddEditUnit.hideSubModelList = function () {
            $scope.M_AddEditUnit.showSubModelList = false;
        }
        $scope.F_AddEditUnit.keyBoardNavigation = function (event, dataList, dropDownName) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_AddEditUnit[indexName] == undefined || isNaN($scope.M_AddEditUnit[indexName])) {
                $scope.M_AddEditUnit[indexName] = -1;
            }

            if (dropDownName === 'make') {
                $scope.M_AddEditUnit.showMakeList = true;
            } else if (dropDownName === 'category') {
                $scope.M_AddEditUnit.showCategoryList = true;
            } else if (dropDownName === 'tag') {
                $scope.M_AddEditUnit.showTagsList = true;
            } else if (dropDownName === 'model') {
                $scope.M_AddEditUnit.showModelList = true;
            } else if (dropDownName === 'subModel') {
                $scope.M_AddEditUnit.showSubModelList = true;
            } else if (dropDownName === 'year') {
                $scope.M_AddEditUnit.showYears = true;
            }else if (dropDownName === 'Yearof1stRego') {
                $scope.M_AddEditUnit.showYearof1stRegoYears = true;
            }

            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_AddEditUnit[indexName]) {
                    $scope.M_AddEditUnit[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditUnit[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_AddEditUnit[indexName] > 0) {
                    $scope.M_AddEditUnit[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_AddEditUnit[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_AddEditUnit[indexName] !== -1) {
                if (dropDownName === 'make') {
                    $scope.F_AddEditUnit.selectUnitMake(dataList[$scope.M_AddEditUnit[indexName]]);
                    $scope.F_AddEditUnit.hideMakeList();
                } else if (dropDownName === 'category') {
                    $scope.F_AddEditUnit.changeUnitCategory(dataList[$scope.M_AddEditUnit[indexName]]);
                    $scope.F_AddEditUnit.hideCategoryList();
                } else if (dropDownName === 'tag') {
                    $scope.F_AddEditUnit.selectTag(dataList[$scope.M_AddEditUnit[indexName]]);
                    $scope.F_AddEditUnit.hideTagsList();
                } else if (dropDownName === 'model') {
                    $scope.F_AddEditUnit.selectUnitModel(dataList[$scope.M_AddEditUnit[indexName]]);
                    $scope.F_AddEditUnit.hideModelList();
                } else if (dropDownName === 'subModel') {
                    $scope.F_AddEditUnit.selectUnitSubModel(dataList[$scope.M_AddEditUnit[indexName]]);
                    $scope.F_AddEditUnit.hideSubModelList();
                } else if (dropDownName === 'year') {
                    $scope.M_AddEditUnit.unitRec.Year = dataList[$scope.M_AddEditUnit[indexName]].year;
                    $scope.M_AddEditUnit.SearchYear = dataList[$scope.M_AddEditUnit[indexName]].year;
                    $scope.M_AddEditUnit.showYears = false;
                } else if (dropDownName === 'Yearof1stRego') {
                    $scope.M_AddEditUnit.unitRec.Yearof1stRego = dataList[$scope.M_AddEditUnit[indexName]].year;
                    $scope.M_AddEditUnit.SearchYearYearof1stRego = dataList[$scope.M_AddEditUnit[indexName]].year;
                    $scope.M_AddEditUnit.showYearof1stRegoYears = false;
                }
                $scope.M_AddEditUnit[indexName] = -1;
            }
        }

        $scope.F_AddEditUnit.hideTagsList = function () {
            $scope.M_AddEditUnit.showTagsList = false;
        }
        $scope.F_AddEditUnit.removeTag = function (tagObj, index) {
            if (index > -1) {
                $scope.M_AddEditUnit.unitRec.AssignedTags.splice(index, 1);
                $scope.M_AddEditUnit.ActiveTagList.push({
                    Name: tagObj
                });
            }
        }
        $scope.F_AddEditUnit.getCategoryList = function () {
            $scope.M_AddEditUnit.showCategoryList = true;
            document.getElementById('categoryDropDownDiv').scrollTop = 0;
        }
        $scope.F_AddEditUnit.hideCategoryList = function () {
            $scope.M_AddEditUnit.showCategoryList = false;
        }

        $scope.F_AddEditUnit.changeUnitCategory = function (cateory) {
            $scope.M_AddEditUnit.UnitCategoryName = cateory.Name;
            $scope.M_AddEditUnit.unitRec.Category = cateory.Id;
            $scope.M_AddEditUnit.unitRec.CategoryName = cateory.Name;
        }

        $scope.F_AddEditUnit.selectTansmissionType = function (type) {
            $scope.M_AddEditUnit.unitRec.TransmissionType = type;
            if (type == 'Automatic') {
                $scope.M_AddEditUnit.unitRec.IsAutomatic = true;
                $scope.M_AddEditUnit.unitRec.Gears = null
            } else {
                $scope.M_AddEditUnit.unitRec.IsAutomatic = false;
            }
        }

        $scope.F_AddEditUnit.selectTag = function (tagObj) {
            var index = _.findIndex($scope.M_AddEditUnit.ActiveTagList, {
                Name: tagObj.Name
            });
            if (index > -1) {
                if ($scope.M_AddEditUnit.unitRec.AssignedTags.length < 20) {
                    $scope.M_AddEditUnit.unitRec.AssignedTags.push(tagObj.Name);
                    $scope.M_AddEditUnit.ActiveTagList.splice(index, 1);
                } else {
                    Notification.error($translate.instant('Part_tag_limit_error'));
                }
            }
            $scope.M_AddEditUnit.TagNameStr = '';
        }
        $scope.F_AddEditUnit.selectUnitMake = function (unitMake) {
            $scope.F_AddEditUnit.hideMakeList();
            $scope.M_AddEditUnit.UnitMakeName = unitMake.UnitMakeName;
            $scope.M_AddEditUnit.unitRec.Make = unitMake.Id;
            $scope.M_AddEditUnit.unitRec.MakeName = unitMake.UnitMakeName;
            $scope.M_AddEditUnit.unitRec.Model = null;
            $scope.M_AddEditUnit.unitRec.ModelName = '';
            $scope.M_AddEditUnit.unitRec.SubModel = null;
            $scope.M_AddEditUnit.unitRec.SubModelName = '';
            $scope.M_AddEditUnit.UnitModelList = tempModelList;
            $scope.M_AddEditUnit.UnitSubModelList = tempSubModelList;
            var UnitModelList = [];
            var unitSubModelList = [];
            for(var i=0;i<$scope.M_AddEditUnit.UnitModelList.length;i++){
                if(unitMake.Id == $scope.M_AddEditUnit.UnitModelList[i].MakeId) {
                    UnitModelList.push($scope.M_AddEditUnit.UnitModelList[i]);
                    for(var j=0;j<$scope.M_AddEditUnit.UnitSubModelList.length;j++){
                        if($scope.M_AddEditUnit.UnitModelList[i].Id == $scope.M_AddEditUnit.UnitSubModelList[j].ModelId) {
                            unitSubModelList.push($scope.M_AddEditUnit.UnitSubModelList[j]);
                        }
                    }
                
                }
            }
            $scope.M_AddEditUnit.UnitModelList = UnitModelList;
            $scope.M_AddEditUnit.UnitSubModelList = unitSubModelList;
        }

        $scope.F_AddEditUnit.selectUnitModel = function (unitModel) {
            $scope.F_AddEditUnit.hideModelList();
            $scope.M_AddEditUnit.unitRec.Model = unitModel.Id;
            $scope.M_AddEditUnit.unitRec.ModelName = unitModel.UnitModelName;
            $scope.M_AddEditUnit.unitRec.SubModel = null;
            $scope.M_AddEditUnit.unitRec.SubModelName = '';
            $scope.M_AddEditUnit.UnitSubModelList = tempSubModelList;
                var unitSubModelList = [];
                        for(var j=0;j<$scope.M_AddEditUnit.UnitSubModelList.length;j++){
                            if(unitModel.Id == $scope.M_AddEditUnit.UnitSubModelList[j].ModelId) {
                                unitSubModelList.push($scope.M_AddEditUnit.UnitSubModelList[j]);
                            }
                        }
            $scope.M_AddEditUnit.UnitSubModelList = unitSubModelList;
            var makeIndex = _.findIndex($scope.M_AddEditUnit.UnitMakeList, {
                'Id': unitModel.MakeId
            });
            if(makeIndex != -1) {
                $scope.M_AddEditUnit.UnitMakeName = $scope.M_AddEditUnit.UnitMakeList[makeIndex].UnitMakeName;
                $scope.M_AddEditUnit.unitRec.Make = $scope.M_AddEditUnit.UnitMakeList[makeIndex].Id;
                $scope.M_AddEditUnit.unitRec.MakeName = $scope.M_AddEditUnit.UnitMakeList[makeIndex].UnitMakeName;
            }
        }

        $scope.F_AddEditUnit.selectUnitSubModel = function (unitSubModel) {
            console.log(unitSubModel);
            var modelIndex = _.findIndex($scope.M_AddEditUnit.UnitModelList, {
                'Id': unitSubModel.ModelId
            });
            if(modelIndex != -1) {
                $scope.M_AddEditUnit.unitRec.Model = $scope.M_AddEditUnit.UnitModelList[modelIndex].Id;
                $scope.M_AddEditUnit.unitRec.ModelName = $scope.M_AddEditUnit.UnitModelList[modelIndex].UnitModelName;
                var makeIndex = _.findIndex($scope.M_AddEditUnit.UnitMakeList, {
                    'Id': $scope.M_AddEditUnit.UnitModelList[modelIndex].MakeId
                });
                if(makeIndex != -1) {
                    $scope.M_AddEditUnit.UnitMakeName = $scope.M_AddEditUnit.UnitMakeList[makeIndex].UnitMakeName;
                    $scope.M_AddEditUnit.unitRec.Make = $scope.M_AddEditUnit.UnitMakeList[makeIndex].Id;
                    $scope.M_AddEditUnit.unitRec.MakeName = $scope.M_AddEditUnit.UnitMakeList[makeIndex].UnitMakeName;
                }
            }
            console.log(modelIndex);
            $scope.F_AddEditUnit.hideSubModelList();
            $scope.M_AddEditUnit.unitRec.SubModel = unitSubModel.Id;
            $scope.M_AddEditUnit.unitRec.SubModelName = unitSubModel.SubModelName;
            
        }
        $scope.F_AddEditUnit.setFocusOnElement = function (elmenetId) {
            angular.element("#" + elmenetId).focus();
        }

        $scope.F_AddEditUnit.showCalender = function (elementId) {
            $scope.F_AddEditUnit.setFocusOnElement(elementId);
        }

        $scope.F_AddEditUnit.isValidVIN = function (value) {
            if (!value) {
                return true;
            }
            return validateVin(value);
        }

        var Currentyear = parseInt(new Date().getFullYear());
        for (var i = Currentyear + 1; i > (Currentyear - 100 + 2); i--) {
            var year = {
                year: i
            };
            $scope.M_AddEditUnit.Years.push(year);
        }

        var saveTempUnit = function () {
            if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                $scope.M_CO.isLoading = true;
            }
            var successJson = {
                'calleeMethodName': 'saveTemporaryUnit'
            };

            if ($stateParams.AddEditTempUnitParams && $stateParams.AddEditTempUnitParams.SectionIndex != undefined) {
                successJson.unitIndex = $stateParams.AddEditTempUnitParams.SectionIndex;
            }
            DealService.saveTemporaryUnit($scope.M_CO.Deal.DealInfo.Id, angular.toJson($scope.M_AddEditUnit.unitRec)).then(new success(successJson).handler, new error().handler);
        }
        
        $scope.M_AddEditUnit.UnitValidation = {
	        VIN: {
	            isError: false,
	            Type: ''
	        },
	        MakeName: {
	            isError: false,
	            Type: 'required'
	        },
	        ModelName: {
	            isError: false,
	            Type: 'required'
	        }
        }
        
        $scope.F_AddEditUnit.ValidateUnitFields = function(modelKey) {
            var validationType = $scope.M_AddEditUnit.UnitValidation[modelKey].Type;
            if (validationType.indexOf('required') > -1) {
                if (!$scope.M_AddEditUnit.unitRec[modelKey] && ($scope.M_AddEditUnit.unitRec[modelKey] !== "0")) {
                    $scope.M_AddEditUnit.UnitValidation[modelKey].isError = true;
                } else {
                    $scope.M_AddEditUnit.UnitValidation[modelKey].isError = false;
                }
            }
        }
        
        $scope.F_AddEditUnit.disablesaveBtn = function () {
            if (($scope.M_AddEditUnit.unitRec.MakeName == null || $scope.M_AddEditUnit.unitRec.MakeName == '') ||
                ($scope.M_AddEditUnit.unitRec.ModelName == null || $scope.M_AddEditUnit.unitRec.ModelName == '')) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_AddEditUnit.addUnit = function () {
            var customerId;
            if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                $scope.M_CO.isLoading = true;
                customerId = $scope.M_CO.coHeaderRec.CustomerId;
            } else {
                $scope.M_AddEditUnit.isLoading = true;
                customerId = $stateParams.AddEditTempUnitParams.CustomerId;
            }
            if ($stateParams.AddEditTempUnitParams.UnitType == 'Temp Unit') {
                saveTempUnit();
            } else if ($stateParams.AddEditTempUnitParams.UnitType == 'COU') {
                checkForSimiliarCouWithActiveVin($scope.M_AddEditUnit.unitRec).then(function(isSimilarActiveVINPresent) {
            		if(!isSimilarActiveVINPresent) {
            			addCustomerOwnedUnit(customerId);
            		} else {
            			$scope.M_AddEditUnit.isLoading = false;
            			if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                    		$scope.M_CO.isLoading = false;
                    	}
            			Notification.error($translate.instant('NewAddNewCOU_Active_VIN'));
            		}
                }, function(errorSearchResult) {
                	$scope.M_AddEditUnit.isLoading = false;
                	if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                		$scope.M_CO.isLoading = false;
                	}
                    Notification.error(errorMessage);
                });                
            }
        }
        
        function addCustomerOwnedUnit(customerId) {
        	var ownedRecs = [];
            ownedRecs.push($scope.M_AddEditUnit.unitRec);
            var successJson = {
                'calleeMethodName': 'addCustomerOwnedUnit'
            };
            VINOperationsService.addCustomerOwnedUnit(customerId, angular.toJson(ownedRecs)).then(new success(successJson).handler, new error().handler);
        }
        
        function checkForSimiliarCouWithActiveVin(couRec) {
        	var defer = $q.defer();
        	var isSimilarActiveVINPresent = false;
        	getSimilarUnits(couRec).then(function(similarCOUList) {
        		if (similarCOUList) {
                    for (var i = 0; i < similarCOUList.length; i++) {
                        if (similarCOUList[i].PriorityNumber == 1 && couRec.Id != similarCOUList[i].Id) {
                            isSimilarActiveVINPresent = true;
                            break;
                        }
                    }
                }
        		defer.resolve(isSimilarActiveVINPresent);
            }, function(errorSearchResult) {
            	defer.reject($translate.instant('GENERIC_ERROR'));
            });
        	return defer.promise;
        }
        
        function getSimilarUnits(couRec) {
        	var defer = $q.defer();
        	VINOperationsService.getSimilarUnits(angular.toJson(couRec)).then(function (similarCOUList) {
                $scope.M_AddEditUnit.similarCOUList = similarCOUList;
                defer.resolve(similarCOUList);
            },
            function (errorSearchResult) {
            	defer.reject($translate.instant('GENERIC_ERROR'));
            });
        	return defer.promise;
        }
        
        function loadAddEditUnitOrderData() {
            loadAddUnitOrderModalData();
            $scope.M_AddEditUnit.UnitType = $stateParams.AddEditTempUnitParams.UnitType;
            if ($stateParams.AddEditTempUnitParams.UnitType == 'Temp Unit') {
                if ($stateParams.AddEditTempUnitParams.SectionId != undefined) {
                    if ($state.current.name === 'CustomerOrder_V2.AddEditTempUnit') {
                        $scope.M_AddEditUnit.unitRec = angular.copy($scope.M_CO.Deal.UnitList[$stateParams.AddEditTempUnitParams.SectionIndex].DealItemObj);
                        if ($scope.M_AddEditUnit.unitRec.Year) {
                            $scope.M_AddEditUnit.SearchYear = $scope.M_AddEditUnit.unitRec.Year;
                        }
                        if ($scope.M_AddEditUnit.unitRec.Model) {
                            $scope.M_AddEditUnit.UnitActionsWithType['Temp Unit'] = $translate.instant('Edit_temporary_unit');
                        }
                    }
                    $scope.M_AddEditUnit.unitRec.Id = $stateParams.AddEditTempUnitParams.SectionId;
                }
            }
        }

        loadAddEditUnitOrderData();
    }])
});