'use strict';
define(['Routing_AppJs_PK', 'UnitOrderingServices', 'JqueryUI','UnitSpecification'], function(Routing_AppJs_PK, UnitOrderingServices, JqueryUI,UnitSpecification) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('UnitReceivingCtrl', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'UnitReceivingServices', '$translate',
    	function($scope, $q, $rootScope, $state, $stateParams, UnitReceivingServices, $translate) {
        var Notification = injector.get("Notification");
        $scope.M_VOUR = $scope.M_VOUR || {};
        $scope.F_VOUR = $scope.F_VOUR || {};
        $scope.M_VOUR.IsQBEnabled = $Global.IsQBEnabled;
        $scope.M_VOUR.UnitSpecificationArray = [];
        $scope.M_UO.isLoading = true;
        $scope.M_VOUR.error = {
            required: false
        };
        $scope.M_VOUR.dateFormat = $Global.DateFormat;
        $scope.M_VOUR.dateOptions = {
            maxDate: new Date,
            dateFormat: $scope.M_VOUR.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        $scope.M_VOUR.duplicateVINError = [];
        $scope.M_VOUR.defaultPrevState = {
            state: $rootScope.$previousState.name,
            attrs: {
                Id: $rootScope.$previousStateParams.Id
            }
        };
        if ($scope.M_AddEditUO && $scope.M_AddEditUO.unitRec) {
            $scope.M_VOUR.prevState = {
                state: 'UnitOrdering.ViewVendorOrderUnits',
                attrs: {
                    'vendorId': $scope.M_AddEditUO.vendorId
                }
            };
            $scope.M_VOUR.selectedUnits = angular.copy([$scope.M_AddEditUO.unitRec]);
            $scope.M_VOUR.selectedUnits[0].UnitId = $scope.M_VOUR.selectedUnits[0].Id;
            $scope.M_VOUR.selectedUnits[0].VIN = ($scope.M_VOUR.selectedUnits[0].VIN && $scope.M_VOUR.selectedUnits[0].VIN !== 'VIN Unknown') ? $scope.M_VOUR.selectedUnits[0].VIN : '';
            $scope.M_VOUR.selectedUnits[0].SalesTaxValue = (($scope.M_VOUR.selectedUnits[0].SalesTax != null) ? ($scope.M_VOUR.selectedUnits[0].TotalCost * $scope.M_VOUR.selectedUnits[0].SalesTax / 100) : 0);
        } else if ($scope.M_ViewVOUs && $scope.M_ViewVOUs.ActiveOrderList) {
            $scope.M_VOUR.selectedUnits = angular.copy($scope.M_ViewVOUs.ActiveOrderList.filter(function isSelected(unit) {
                unit.VIN = (unit.VIN && unit.VIN !== 'VIN Unknown') ? unit.VIN : '';
                unit.SalesTaxValue = ((unit.SalesTax != null) ? (unit.TotalCost * unit.SalesTax / 100) : 0);
                return unit.isSelected;
            }));
            $scope.M_VOUR.prevState = $scope.M_VOUR.defaultPrevState;
        }
        
        $scope.F_VOUR.showCalendar = function(IdVal) {
          angular.element("#" + IdVal).focus();
       }
        function validateRecieveUnitInvoiceNumber() {
        	if($scope.M_VOUR.IsQBEnabled) {
        		validateUnitInvoiceNumberForQB();
        	} else {
        		finalizeUnitReceiving($scope.M_VOUR.selectedUnits);
        	}
        }
        function validateUnitInvoiceNumberForQB() {
        	var unitsWithUniqueInvoiceNumber = [];
        	var unitsWithDuplicateInvoiceNumber = [];
        	var addUnit = true;
        	UnitReceivingServices.validateUnitInvoiceNumberForQB(JSON.stringify($scope.M_VOUR.selectedUnits)).then(function(successfulResult) {
    			if(successfulResult) {
    				console.log(successfulResult);
    				for (var i = 0; i < $scope.M_VOUR.selectedUnits.length; i++) {
    					addUnit = true;
    					for (var j = 0; j < successfulResult.length ; j++) {
    						if($scope.M_VOUR.selectedUnits[i].InvoiceNumber == successfulResult[j]) {
    							addUnit = false;
    							unitsWithDuplicateInvoiceNumber.push($scope.M_VOUR.selectedUnits[i].InvoiceNumber);
    							break;
        					}
    					}
    					if(addUnit) {
    						unitsWithUniqueInvoiceNumber.push($scope.M_VOUR.selectedUnits[i]);
    					}
    				}
    				if(unitsWithDuplicateInvoiceNumber) {
    	    			for (var j = 0; j < unitsWithDuplicateInvoiceNumber.length ; j++) {
    	    				Notification.error('Duplicate invoice number : ' + unitsWithDuplicateInvoiceNumber[j] +  ' .This number already exists in your accounting application');
    	    			}
    	    		}
    				finalizeUnitReceiving(unitsWithUniqueInvoiceNumber, unitsWithDuplicateInvoiceNumber);
    			} 
    		}, function(error) {
    			$scope.M_UO.isLoading = false;
                Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
            });
        }
        function finalizeUnitReceiving(unitListToBeFinalized, unitsWithDuplicateInvoiceNumber) {
        	if( !(unitListToBeFinalized && unitListToBeFinalized.length)) {
        		$scope.M_UO.isLoading = false;
        		return ;
        	}
        	var successJson = {
                    'type': 'unitReceivedSuccess'
                };
        	
        	UnitReceivingServices.saveUnitReceiving(JSON.stringify(unitListToBeFinalized)).then(function(response) {
        		if (response.HasError && response.ErrorMessage) {
        			if(response.DuplicateInvoiceNumbers) {
        				Notification.error('Duplicate invoice number : ' + response.DuplicateInvoiceNumbers +  ' .This invoice numbers already exists in your application');
        			} else {
        				Notification.error(response.ErrorMessage);
        			}
                } else {
                    Notification.success(unitListToBeFinalized.length + " " + $translate.instant('Orders_Received_Msg') + " - " + $translate.instant('Orders_Received_Msg2'));
                    if ($scope.M_AddEditUO) {
                        $scope.M_VOUR.prevState.attrs['ViewVendorOrderUnitsParams'] = {
                            subTab: 'OrderHistory'
                        };
                    }
                }
                if(!(unitsWithDuplicateInvoiceNumber && unitsWithDuplicateInvoiceNumber.length) && !response.DuplicateInvoiceNumbers)  {
                	$scope.F_VOUR.closeUnitReceivingModel(true, $scope.M_VOUR.prevState);
                } else {
                	if(!response.DuplicateInvoiceNumbers && $scope.M_VOUR.IsQBEnabled) {
            			for (var i = 0; i < $scope.M_VOUR.selectedUnits.length; i++) {
            				for (var j = 0; j < unitListToBeFinalized.length ; j++) {
            					if($scope.M_VOUR.selectedUnits[i].InvoiceNumber == unitListToBeFinalized[j].InvoiceNumber ) {
            						$scope.M_VOUR.selectedUnits.splice(i, 1);
            					}
            				}
            			}
                	} 
                }
                $scope.M_UO.isLoading = false;
            }, function(error) {
                $scope.M_UO.isLoading = false;
                Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
            });
        }
        
        $scope.F_VOUR.setDataFromBRP = function() {
        	for (var i = 0; i < $scope.M_VOUR.selectedUnits.length; i++) {
        		if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue) {
        			if(isBlankValue($scope.M_VOUR.selectedUnits[i].MakeName)) {
        				$scope.M_VOUR.selectedUnits[i].MakeName = '';
            		}
        			if(isBlankValue($scope.M_VOUR.selectedUnits[i].ModelName)) {
        				$scope.M_VOUR.selectedUnits[i].ModelName = '';
            		}
        			if(isBlankValue($scope.M_VOUR.selectedUnits[i].SubModelName)) {
        				$scope.M_VOUR.selectedUnits[i].SubModelName = '';
            		}
        			if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Make']) {
        				if($scope.M_VOUR.selectedUnits[i].MakeName.toLowerCase() != $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Make'][0].toLowerCase()) {
            				$scope.M_VOUR.selectedUnits[i].MakeName = $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Make'][0];
                		}
        			}
            		
        			if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Model']) {
        				if($scope.M_VOUR.selectedUnits[i].ModelName.toLowerCase() != $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Model'][0].toLowerCase()) {
                			$scope.M_VOUR.selectedUnits[i].ModelName = $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Model'][0];
                		}
        			}
            		
        			if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['SubModel']) {
        				if($scope.M_VOUR.selectedUnits[i].SubModelName.toLowerCase() != $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['SubModel'][0].toLowerCase()) {
                			$scope.M_VOUR.selectedUnits[i].SubModelName = $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['SubModel'][0];
                		}
        			}
                    
            		if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Year']) {
            			$scope.M_VOUR.selectedUnits[i].Year = $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['Year'][0];
                		if(!isBlankValue($scope.M_VOUR.selectedUnits[i].Year)) {
                			$scope.M_VOUR.selectedUnits[i].Year = parseFloat($scope.M_VOUR.selectedUnits[i].Year);
                		} else {
                			$scope.M_VOUR.selectedUnits[i].Year = null;
                		}
            		}
            		if($scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['NumberOfCyclinder']) {
            			$scope.M_VOUR.selectedUnits[i].Cylinders = $scope.M_VOUR.selectedUnits[i].mapOfNewAndOldValue['NumberOfCyclinder'][0];
                		if(!isBlankValue($scope.M_VOUR.selectedUnits[i].Cylinders)) {
                			$scope.M_VOUR.selectedUnits[i].Cylinders = parseFloat($scope.M_VOUR.selectedUnits[i].Cylinders);
                		} else {
                			$scope.M_VOUR.selectedUnits[i].Cylinders = null;
                		}
            		}
        		}
        	}
        }
        
        $scope.F_VOUR.saveUnitReceiving = function() {
        	$scope.F_VOUR.setDataFromBRP();
        	if(!$scope.F_VOUR.isDuplicateVINExists()) {
        		if ($scope.F_VOUR.isValid()) {
        			$scope.M_VOUR.error.required = false;
        			$scope.M_UO.isLoading = true;
        			validateRecieveUnitInvoiceNumber();
        		} else {
        			$scope.M_VOUR.error.required = true;
        		}
        	}
        }
        
        angular.element(document).on("click", "#unitReceivingModel .modal-backdrop", function() {
            $scope.F_VOUR.closeUnitReceivingModel(false, $scope.M_VOUR.defaultPrevState);
        });
        $scope.F_VOUR.closeUnitReceivingModel = function(reload, stateObj) {
            angular.element('#unitReceivingModel').modal('hide');
            if ($scope.M_AddEditUO && $scope.M_AddEditUO.unitRec) {
            	$scope.F_AddEditUO.resetUnitData();
            }
            $state.go(stateObj.state, stateObj.attrs, {
                reload: reload
            });
        }
        $scope.F_VOUR.isValid = function() {
            var invalidUnits = $scope.M_VOUR.selectedUnits.filter(function isInvalid(unit) {
                return !(unit.VIN && unit.VIN.trim() && unit.InvoiceNumber && unit.InvoiceNumber.trim() && unit.StockedInDateTime && unit.StockedInDateTime.trim());
            });
            return !(invalidUnits && invalidUnits.length);
        }
        $scope.F_VOUR.isValidVIN = function(value) {
            return validateVin(value);
        }
        $scope.F_VOUR.isDuplicateInvoice = function(index, value) {
            if (value && value.trim()) {
                for (var i = 0; i < $scope.M_VOUR.selectedUnits.length; i++) {
                    if (index !== i && value.trim() === $scope.M_VOUR.selectedUnits[i].InvoiceNumber) {
                        $scope.M_VOUR.selectedUnits[index].InvoiceNumber = '';
                        return true;
                    }
                }
            }
            return false;
        }
        $scope.F_VOUR.isDuplicateVINExists = function() {
        	for(var i = 0; i < $scope.M_VOUR.duplicateVINError.length; i++) {
                if($scope.M_VOUR.duplicateVINError[i]) {
                	return true;
                }
            }
        	return false;
        }
        var selectedUnitIndex ;
        
        $scope.F_VOUR.isDuplicateVIN = function(index) {
            console.log($scope.M_VOUR.selectedUnits[index]);
            var vinNumber = $scope.M_VOUR.selectedUnits[index].VIN;
            selectedUnitIndex = index;
        	if(!isBlankValue(vinNumber)) {
        		if($Global.isBRPEnabled) {
        			$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = 'Loading';
        		} else {
        			$scope.M_UO.isLoading = true;
        		}
        		for(var i = 0; i < $scope.M_VOUR.selectedUnits.length; i++) {
                    if (index !== i && vinNumber.trim() === $scope.M_VOUR.selectedUnits[i].VIN) {
                    	$scope.M_VOUR.duplicateVINError[index] = true;
                    	if($Global.isBRPEnabled) {
                    		$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
                		} else {
                			$scope.M_UO.isLoading = false;
                		}
                    	Notification.error($translate.instant('Duplicate_VIN_number'));
                        return;
                    }
                }
        		UnitReceivingServices.checkDuplicateVIN(vinNumber).then(function(response) {
            		if(response.HasError && response.ErrorMessage) {
            			Notification.error(response.ErrorMessage);
            			$scope.M_VOUR.duplicateVINError[index] = true;
            			if($Global.isBRPEnabled) {
                    		$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
                		}
                    } else {
                        $scope.M_VOUR.duplicateVINError[index] = false;
                        if($Global.isBRPEnabled) {
                        	if(!isBlankValue(vinNumber)) {
                                UnitReceivingServices.getVehicleSpecification(vinNumber).then(function(response) {
                                	$scope.M_VOUR.selectedUnits[selectedUnitIndex].mapOfNewAndOldValue =  {};
                                	if(response.responseCode == 400) {
                                		$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = 'Match not found';
                                	} else {
                                		setMapofOldAndNewValue('Make', $scope.M_VOUR.selectedUnits[index].MakeName, 'BRP');
                                        setMapofOldAndNewValue('Model', $scope.M_VOUR.selectedUnits[index].ModelName, response.Model);
                                        setMapofOldAndNewValue('SubModel', $scope.M_VOUR.selectedUnits[index].SubModelName, response.ModelDescription);
                                        setMapofOldAndNewValue('Year', $scope.M_VOUR.selectedUnits[index].Year, response.ModelYear);
                                        setMapofOldAndNewValue('NumberOfCyclinder', $scope.M_VOUR.selectedUnits[index].Cylinders, response.Engine.NumberOfEngineCylindersNumeric);
                                	}
                                }, function(error) {
                                    $scope.M_UO.isLoading = false;
                                    $scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
                                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                                });
                        	} else {
                        		$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
                        	}
                		}
                    }
                    $scope.M_UO.isLoading = false;
                }, function(error) {
                    $scope.M_UO.isLoading = false;
                    $scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
        	} else {
        		if($Global.isBRPEnabled) {
        			$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = '';
        		}
        	}
        }
        
        $rootScope.$on('updateUnitDetailFromDirective',function(event, args) {
        	setDataOfUnit(args.key, args.value, args.index);
        	checkIfChangeExistsInEnteredAndBRPValues(args.index);
        });
        
        $rootScope.$on('ignoreChangeUnitDetailFromDirective',function(event, args) {
        	checkIfChangeExistsInEnteredAndBRPValues(args.index);
        });
        
        function setDataOfUnit(key, value, index) {
        	if(key == 'Make') {
        		$scope.M_VOUR.selectedUnits[index].MakeName = value;
        	} else if(key == 'Model') {
        		$scope.M_VOUR.selectedUnits[index].ModelName = value;
        	} else if(key == 'SubModel') {
        		$scope.M_VOUR.selectedUnits[index].SubModelName = value;
        	} else if(key == 'Year') {
        		$scope.M_VOUR.selectedUnits[index].Year = value;
        		if(!isBlankValue($scope.M_VOUR.selectedUnits[index].Year)) {
        			$scope.M_VOUR.selectedUnits[index].Year = parseFloat($scope.M_VOUR.selectedUnits[index].Year);
        		} else {
        			$scope.M_VOUR.selectedUnits[index].Year = null;
        		}
        	} else if(key == 'NumberOfCyclinder') {
        		$scope.M_VOUR.selectedUnits[index].Cylinders = value;
        		if(!isBlankValue($scope.M_VOUR.selectedUnits[index].Cylinders)) {
        			$scope.M_VOUR.selectedUnits[index].Cylinders = parseFloat($scope.M_VOUR.selectedUnits[index].Cylinders);
        		} else {
        			$scope.M_VOUR.selectedUnits[index].Cylinders = null;
        		}
        	}
        }
        
        function checkIfChangeExistsInEnteredAndBRPValues(index) {
        	if($scope.M_VOUR.selectedUnits[index].mapOfNewAndOldValue) {
        		var arr = Object.entries($scope.M_VOUR.selectedUnits[index].mapOfNewAndOldValue);
        		for(var i=0; i<arr.length; i++) {
        			if(isBlankValue(arr[i][1][0])) {
        				arr[i][1][0] = '';
        			}
        			if(isBlankValue(arr[i][1][1])) {
        				arr[i][1][1] = '';
        			}
        			if(arr[i][0] != 'isHideIgnore' && arr[i][1][0].toString().toLowerCase() != arr[i][1][1].toString().toLowerCase()) {
        				return;
        			}
        		}
        		if(arr.length > 0) {
        			$scope.M_VOUR.selectedUnits[index].vehicleSpecificationsResult = 'Match found with all fields match';
        			return;
        		}
        	}
        }
       
        function setMapofOldAndNewValue(objName, oldValue, newValue) {
            if((selectedUnitIndex || selectedUnitIndex ==0)  && (oldValue || newValue) && oldValue != newValue) {
                if(isBlankValue(oldValue)) {
                	oldValue = '';
                }
                if(isBlankValue(newValue)) {
                	newValue = '';
                }
                var tempArray = [oldValue, newValue];
                $scope.M_VOUR.selectedUnits[selectedUnitIndex].mapOfNewAndOldValue[objName]= tempArray;
            }
            if(Object.entries($scope.M_VOUR.selectedUnits[selectedUnitIndex].mapOfNewAndOldValue).length == 0) {
            	$scope.M_VOUR.selectedUnits[selectedUnitIndex].vehicleSpecificationsResult = 'Match found with all fields match';
            } else {
            	$scope.M_VOUR.selectedUnits[selectedUnitIndex].vehicleSpecificationsResult = 'Match found with not all fields match';
            }
        }
        $scope.F_VOUR.loadUnitReceivingDialog = function() {
            setTimeout(function() {
                angular.element('#unitReceivingModel').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                $scope.M_UO.isLoading = false;
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply();
                }
            }, 100);
        }
        $scope.F_VOUR.loadUnitReceivingDialog();
    }])
});