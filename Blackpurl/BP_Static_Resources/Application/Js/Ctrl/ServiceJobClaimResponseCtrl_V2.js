define(['Routing_AppJs_PK', 'JqueryUI', 'CustomerOrderServices_V2', 'moment', 'underscore_min'], function(Routing_AppJs_PK, JqueryUI, CustomerOrderServices_V2, moment, underscore_min) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ServiceJobClaimResponseCtrl_V2', ['$scope', '$rootScope', '$state', '$stateParams', 'SOClaimService', 'SOHeaderService', function($scope, $rootScope, $state, $stateParams, SOClaimService, SOHeaderService) {
        var Notification = injector.get("Notification");
        $scope.M_SOClaimRes = $scope.M_SOClaimRes || {};
        $scope.F_SOClaimRes = $scope.F_SOClaimRes || {};
        $scope.M_SOClaimRes.dateFormat = $Global.DateFormat;
        $scope.M_SOClaimRes.StatusUniqueKey = 'Claim_Response';
        $scope.M_SOClaimRes.ClaimResponseStepNo = 1;
        $scope.M_SOClaimRes.isExitSOClaimRes = false;
        $scope.M_SOClaimRes.ClaimResponseStatusMap = {
            1: 'Response Information',
            2: 'Response Detail',
            3: 'Variance Disposition'
        }
        $scope.M_SOClaimRes.NoOfStepsInClaimResponse = Object.keys($scope.M_SOClaimRes.ClaimResponseStatusMap).length;
        $scope.M_SOClaimRes.wizardInfo = {};
        $scope.M_SOClaimRes.ResponseDateOptions = {
            /*minDate: '',*/
            dateFormat: $scope.M_SOClaimRes.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        var shopSuppliesCustomSetting;
        var tempNonVarianceLIList = [];
        var soliToIndividualTaxListMap;
        function generateTempNonVarianceLIList(claimLIList) {
        	tempNonVarianceLIList = [];
        	tempNonVarianceLIList = JSON.parse(JSON.stringify(claimLIList));
        }
        function refreshSOHeaderData(isBindAllServiceJobData) {
        	var successJson = {
                'calleeMethodName': 'getSOHeaderDetails',
                'isBindAllServiceJobData' : isBindAllServiceJobData
            };
            var recordId;
            if(isBindAllServiceJobData) {
                recordId = $scope.M_CO.COHeaderId;
            } else {
                recordId = $scope.M_SOClaimRes.WizardSOHeaderId;
            }
            SOHeaderService.getSOHeaderDetails(recordId, null).then(new success(successJson).handler, new error().handler);
        }
        var success = function() {
            var self = this;
            this.arguments = arguments[0];
            this.calleeMethodName = arguments[0].calleeMethodName,
                this.callback = arguments[0].callback,
                this.handler = function(successResult) {
                    switch (self.calleeMethodName) {
                        case 'getWizardInfo':
                            handleGetWizardInfoResponse(successResult);
                            break;
                        case 'saveClaimResponse':
                            handleSaveClaimResponse(successResult);
                            break;
                        case 'getSOHeaderDetails':
                            handleGetSOHeaderDetailsResponse(successResult);
                            break;
                        case 'finalizeClaimResponse':
                        	handleFinalizeClaimResponse(successResult);
                            break;
                        case 'getShopSuppliesConfiguration':
                        	handleGetShopSuppliesConfiguration(successResult);
                        	break;
                        case 'getIndividualTaxesForSO':
                        	handleGetIndividualTaxesForSO(successResult);
                        	break;
                        default:
                            break;
                    }
                    if(typeof self.callback === 'function') {
                        self.callback();
                    }
                }

            function handleGetWizardInfoResponse(wizardInfo) {
                $scope.M_SOClaimRes.wizardInfo = wizardInfo;
                generateTempNonVarianceLIList($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList);
                setVarianceCategoryName();
                $scope.M_SOClaimRes.wizardInfo.NextButtonAvail = true;
                $scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList = ['Accepted', 'Denied'];
                if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition == 'Accepted with adjustments') {
                    if($scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.indexOf('Accepted with adjustments') == -1) {
                    	$scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.push('Accepted with adjustments');
                    }
                }
                $scope.M_SOClaimRes.wizardInfo.VarianceBillToList = ['Internal', 'Customer'];
                if ($scope.M_SOClaimRes.wizardInfo.InternalCategoryList == null) {
                    $scope.M_SOClaimRes.wizardInfo.InternalCategoryList = [];
                }
                //$scope.F_SOClaimRes.calculateClaimResponseVariance(null);
                //$scope.M_SOClaimRes.ResponseDateOptions.minDate = $scope.M_SOClaimRes.wizardInfo.SubmittedDate;
                var index = _.findIndex($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList, {
        			'IsCalculateSupplies': true
        		});
                if(index != -1) {
                	getShopSuppliesConfiguration();
                }
                getIndividualTaxesForSO();
            }

            function handleSaveClaimResponse(wizardInfo) {
            	if($scope.M_SOClaimRes.isExitSOClaimRes) {
            		$scope.F_SOClaimRes.closeSOClaimResModal();
            	}
                $scope.M_SOClaimRes.wizardInfo = wizardInfo;
                generateTempNonVarianceLIList($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList);
                $scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList = ['Accepted', 'Denied'];
                if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition == 'Accepted with adjustments') {
                    if($scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.indexOf('Accepted with adjustments') == -1) {
                    	$scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.push('Accepted with adjustments');
                    }
                }
                if ($scope.M_SOClaimRes.wizardInfo.InternalCategoryList == null) {
                    $scope.M_SOClaimRes.wizardInfo.InternalCategoryList = [];
                }
                $scope.M_SOClaimRes.wizardInfo.VarianceBillToList = ['Internal', 'Customer'];
                $scope.F_SOClaimRes.calculateClaimResponseVariance(null);
                $scope.F_SOClaimRes.setSaveBtnAvailability();
                $scope.M_SOClaimRes.isLoading = false;
            }
            
            function handleFinalizeClaimResponse(successResult) {
            	$scope.F_SOClaimRes.closeSOClaimResModal(self.arguments.isBindAllServiceJobData);
            }
            
            function handleGetShopSuppliesConfiguration(successResult) {
            	//$scope.M_SOClaimRes.isLoading = false;
            	shopSuppliesCustomSetting = successResult;
            }
            
            function handleGetIndividualTaxesForSO(individualTaxesData) {
            	$scope.M_SOClaimRes.isLoading = false;
            	soliToIndividualTaxListMap = individualTaxesData;
            	$scope.F_SOClaimRes.calculateClaimResponseVariance(null);
            }
            
            function handleGetSOHeaderDetailsResponse(serviceOrderHeader) {
                if(self.arguments.isBindAllServiceJobData) {
                    $scope.M_CO.SOHeaderList = serviceOrderHeader;
                } else {
                    $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex] = serviceOrderHeader[0];
                    if (!isBlankValue($scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex].SOInfo.UnitId)) {
                        if($stateParams.ServiceJobClaimResponseParams.coType != 'Internal Service') {
                            var index = _.findIndex($scope.M_CO.COUList, {
                            'Id': $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex].SOInfo.UnitId
                            });
                        $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex].SOInfo.UnitName = $scope.M_CO.COUList[index].FormattedName;
                        }
                    }
                }
                if (serviceOrderHeader.length > 0) {
                    $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeader[0].OrderTotal;
                    $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeader[0].InvoicedAmount;
                    $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeader[0].UninvoicedAmount;
                    $scope.M_CO.coHeaderRec.TotalPayments = serviceOrderHeader[0].TotalPayments;
                }
                $scope.F_CO.getSpecialOrdersData();
            }
        }
        var error = function(errorMessage) {
            this.handler = function(error) {
                if (!errorMessage) {
                    console.log(error);
                } else {
                    console.log(errorMessage);
                }
            }
        }
        
        $scope.F_SOClaimRes.ClaimResponseStepName = function(stepNo) {
            return $scope.M_SOClaimRes.ClaimResponseStatusMap[stepNo];
        }
        $scope.F_SOClaimRes.showCalander = function(elementId) {
            angular.element("#" + elementId).focus();
        }
        angular.element(document).on("click", "#ServiceJobClaimResponseModal .modal-backdrop", function() {
            $scope.F_SOClaimRes.closeSOClaimResModal();
        });
        $scope.F_SOClaimRes.closeSOClaimResModal = function(isBindAllServiceJobData) {
        	if($scope.M_SOClaimRes.ClaimResponseStepNo == 3) {
            	refreshSOHeaderData(isBindAllServiceJobData);
        	}
        	$scope.M_SOClaimRes.isLoading = false;
            angular.element('#ServiceJobClaimResponseModal').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        
        function getShopSuppliesConfiguration() {
        	var successJson = {
                    'calleeMethodName': 'getShopSuppliesConfiguration'
            };
            SOClaimService.getShopSuppliesConfiguration().then(new success(successJson).handler, new error().handler);
        }
        
        function getIndividualTaxesForSO() {
        	var successJson = {
                    'calleeMethodName': 'getIndividualTaxesForSO'
            };
            SOClaimService.getIndividualTaxesForSO($scope.M_SOClaimRes.WizardSOHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function setVarianceCategoryName() {
            if ($scope.M_SOClaimRes.wizardInfo != undefined) {
                for (var i = 0; i < $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList; i++) {
                    var categoryId = $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[i].Category;
                    var index = -1;
                    if (categoryId != null) {
                        index = _.findIndex($scope.M_SOClaimRes.wizardInfo.InternalCategoryList, {
                            Id: categoryId
                        });
                    }
                }
                if (index > -1) {
                    $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].CategoryName = $scope.M_SOClaimRes.wizardInfo.InternalCategoryList[index].CategoryName;
                }
            }
        }
        $scope.F_SOClaimRes.isValueValid = function(type, indexVal, event) {
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty);
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty);
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice);
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice);
            if (type == 'Price') {
                if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice > $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedPrice) {
                    $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = tempNonVarianceLIList[indexVal].ApprovedPrice;
                    Notification.error($Label.CustomerOrder_Js_Approved_quantity);
                } else {
                    $scope.F_SOClaimRes.changeClaimDisposition(false, indexVal, undefined);
                }
            } else if (type == 'Qty') {
                if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty > $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty) {
                    $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty = tempNonVarianceLIList[indexVal].ApprovedQty;
                    Notification.error($Label.CustomerOrder_Js_Approved_quantity);
                } else {
                    $scope.F_SOClaimRes.changeClaimDisposition(false, indexVal, undefined);
                }
            }
        }
        $scope.F_SOClaimRes.changeClaimDisposition = function(isPicklistChange, indexVal, event) {
            if (event != undefined) {
                if (event.keyCode == 9) {
                	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty);
                	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty);
                	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice);
                	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice);
                    if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty > $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty) {
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty = tempNonVarianceLIList[indexVal].ApprovedQty;
                        Notification.error($Label.CustomerOrder_Js_Approved_quantity);
                        event.preventDefault();
                    } else if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice > $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedPrice) {
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedPrice = tempNonVarianceLIList[indexVal].ApprovedPrice;
                        Notification.error($Label.CustomerOrder_Js_Approved_quantity);
                        event.preventDefault();
                    }
                }
            }
            if (isPicklistChange) {
                $scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.remove('Accepted with adjustments');
                for (var i = 0; i < $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList.length; i++) {
                    $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].IsEdit = false;
                    if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition == 'Accepted') {
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                    } else if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition == 'Denied') {
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = 0;
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = 0;
                    }
                }
                $scope.F_SOClaimRes.calculateClaimResponseVariance(null);
            } else if (!isPicklistChange) {
                if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition == 'Denied') {
                    for (var i = 0; i < $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList.length; i++) {
                        if (indexVal != i) {
                            $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                            $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                        } else {
                            if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty == 0) {
                                $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                            } else if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice == 0) {
                                $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                            }
                        }
                    }
                }
                if ($scope.M_SOClaimRes.wizardInfo.ClaimDisposition != 'Accepted with adjustments') {
                    $scope.F_SOClaimRes.calculateClaimResponseVariance(indexVal);
                } else {
                    $scope.F_SOClaimRes.calculateClaimResponseVariance(null);
                }
                if($scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.indexOf('Accepted with adjustments') == -1) {
                	$scope.M_SOClaimRes.wizardInfo.ClaimDispositionsList.push('Accepted with adjustments');
                }
            }
        }
        
        var setClaimDispositionValue = function() {
        	var index = _.findIndex($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList, function(claimLI) {
                return claimLI.VarianceAmount !== 0;
            });
            if(index != -1) {
            	$scope.M_SOClaimRes.wizardInfo.ClaimDisposition = 'Accepted with adjustments';
            } else {
            	$scope.M_SOClaimRes.wizardInfo.ClaimDisposition = 'Accepted';
            }
        }
        
        $scope.F_SOClaimRes.calculateClaimResponseVariance = function(indexVal) {
            if (indexVal == null) {
                $scope.M_SOClaimRes.wizardInfo.ApprovedItems = 0;
                $scope.M_SOClaimRes.wizardInfo.TaxAmount = 0;
                $scope.M_SOClaimRes.wizardInfo.TotalVarianceAmount = 0;
            }
            if ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList != null) {
                for (var i = 0; i < $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList.length; i++) {
                    if (indexVal == null || indexVal == i) {
                        if (indexVal != null) {
                            $scope.M_SOClaimRes.wizardInfo.ApprovedItems -= $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                            //$scope.M_SOClaimRes.wizardInfo.TaxAmount -= $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].TaxAmount;
                            $scope.M_SOClaimRes.wizardInfo.TotalVarianceAmount -= $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].VarianceAmount;
                        }
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty * $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice;
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].VarianceQuantity = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedQty - $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedQty;
                        $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].VarianceAmount = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ClaimedSubtotal - $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                        $scope.M_SOClaimRes.wizardInfo.TotalVarianceAmount += $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].VarianceAmount;
                        if($scope.M_SOClaimRes.wizardInfo.IsTaxIncludingPricing) {
                        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].preTaxApprovedSubTotal = parseFloat(($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal/(1+$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].Tax/100)).toFixed(2));
                        	//$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].TaxAmount = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal - preTaxApprovedSubTotal;
                        } else {
                        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].preTaxApprovedSubTotal = parseFloat($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal);
                        	//$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].TaxAmount = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal * ($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].Tax / 100);
                        }
                        $scope.M_SOClaimRes.wizardInfo.ApprovedItems += $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                        //$scope.M_SOClaimRes.wizardInfo.TaxAmount += $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].TaxAmount;
                    }
                }
                $scope.M_SOClaimRes.wizardInfo.TaxAmount = calculateTaxAmountFromIndividualTaxes();
            }
            $scope.M_SOClaimRes.wizardInfo.Total = $scope.M_SOClaimRes.wizardInfo.ApprovedItems - $scope.M_SOClaimRes.wizardInfo.DeductibleAmount;
            if(!$scope.M_SOClaimRes.wizardInfo.IsTaxIncludingPricing) {
            	$scope.M_SOClaimRes.wizardInfo.Total += $scope.M_SOClaimRes.wizardInfo.TaxAmount;
            }
            if ($scope.M_SOClaimRes.wizardInfo.TotalVarianceAmount != 0) {
                $scope.M_SOClaimRes.wizardInfo.VarianceHeader = 'Outstanding Variance';
            } else {
                $scope.M_SOClaimRes.wizardInfo.VarianceHeader = 'No Variance';
            }
            if(indexVal != null) {
            	setClaimDispositionValue();
            }
            generateTempNonVarianceLIList($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList);
        }

        function setClaimResponseData() {
            var successJson = {
                'calleeMethodName': 'getWizardInfo'
            };
            SOClaimService.getWizardInfo($scope.M_SOClaimRes.WizardSOHeaderId, $scope.M_SOClaimRes.StatusUniqueKey).then(new success(successJson).handler, new error().handler);
        }
        
        function saveVarianceLI(index) {
        	SOClaimService.saveVarianceLI(angular.toJson($scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index])).then(function(successfulResult) {}, function(errorResult) {});
        }
        
        function calculateTaxAmountFromIndividualTaxes() {
        	var salesTaxItemNameToTaxableAmountMap = {};
        	for(var res in soliToIndividualTaxListMap) {
        		var taxableAmount = 0;
        		var claimLIIndex = _.findIndex($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList, {
        			'ServiceOrderLineItem': res
        		});
        		if(claimLIIndex != -1) {
        			taxableAmount = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[claimLIIndex].preTaxApprovedSubTotal;
        		}
        		for(var i=0; i<soliToIndividualTaxListMap[res].length; i++) {
        			if(isBlankValue(salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName])) salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName] = {};
        			if($scope.M_SOClaimRes.wizardInfo.IsTaxIncludingPricing) {
        				if(isBlankValue(salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxAmount'])) salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxAmount'] = 0;
        				salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxAmount'] += parseFloat(((taxableAmount*soliToIndividualTaxListMap[res][i].TaxRate)/100).toFixed(2));
        			} else {
            			if(isBlankValue(salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxableAmount'])) salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxableAmount'] = 0;
            			salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['TaxableAmount'] += taxableAmount;
            			salesTaxItemNameToTaxableAmountMap[soliToIndividualTaxListMap[res][i].SalesTaxItemName]['Rate'] = soliToIndividualTaxListMap[res][i].TaxRate;
        			}
        		}
        	}
        	
        	var totalTaxAmount = 0;
        	for(var taxItem in salesTaxItemNameToTaxableAmountMap) {
        		if($scope.M_SOClaimRes.wizardInfo.IsTaxIncludingPricing) {
        			totalTaxAmount += salesTaxItemNameToTaxableAmountMap[taxItem].TaxAmount;
        		} else {
        			totalTaxAmount += parseFloat(((salesTaxItemNameToTaxableAmountMap[taxItem].TaxableAmount*salesTaxItemNameToTaxableAmountMap[taxItem].Rate)/100).toFixed(2));
        		}
        	}
        	return parseFloat(totalTaxAmount.toFixed(2));
        }
        
        $scope.F_SOClaimRes.isStep1NextButtonDisabled = function() {
            if (!isBlankValue($scope.M_SOClaimRes.wizardInfo)) {
                if (isBlankValue($scope.M_SOClaimRes.wizardInfo.ProviderClaimNumber) || isBlankValue($scope.M_SOClaimRes.wizardInfo.ResponseDate)) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return true;
            }
        }
        $scope.F_SOClaimRes.SetFocusOnDropdown = function(elmenetId) {
            angular.element("#" + elmenetId).focus();
        }
        $scope.F_SOClaimRes.changeVarianceBillTo = function(billTo, index) {
            $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].BillTo = billTo;
            if ($scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].BillTo == 'Customer') {
                $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].Category = null;
            }
            $scope.F_SOClaimRes.setSaveBtnAvailability();
        }
        $scope.F_SOClaimRes.changeVarianceCategory = function(category, index) {
            $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].Category = category.Id;
            $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[index].CategoryName = category.CategoryName;
            $scope.F_SOClaimRes.setSaveBtnAvailability();
            saveVarianceLI(index);
        }
        $scope.F_SOClaimRes.setSaveBtnAvailability = function() {
            if ($scope.M_SOClaimRes.wizardInfo != null) {
                $scope.M_SOClaimRes.SaveButtonAvail = true;
                if ($scope.M_SOClaimRes.wizardInfo.VarianceLineItemList != null) {
                    for (var i = 0; i < $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList.length; i++) {
                        if ($scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[i].BillTo == 'Third_Party') {
                            $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[i].BillTo = 'Internal';
                        }
                        var VarianceLineItem = $scope.M_SOClaimRes.wizardInfo.VarianceLineItemList[i];
                        if (VarianceLineItem.BillTo == null || VarianceLineItem.BillTo.length == 0) {
                            $scope.M_SOClaimRes.SaveButtonAvail = false;
                            break;
                        }
                        if (VarianceLineItem.BillTo == 'Internal' && (VarianceLineItem.Category == null || VarianceLineItem.Category.length == 0)) {
                            $scope.M_SOClaimRes.SaveButtonAvail = false;
                            break;
                        }
                    }
                }
            }
        }
        $scope.F_SOClaimRes.SaveClaimResponse = function(ServiceOrderHeaderId, claimResponse, currentStepNumber, closeWizard) {
        	$scope.M_SOClaimRes.isLoading = true;
        	var successJson = {
                'calleeMethodName': 'saveClaimResponse'
            };
            document.getElementById('ServiceJobClaimResponseModal').scrollTop = 0;
            if(currentStepNumber == 3 && $scope.M_SOClaimRes.WizardSOHeaderStatus == 'Invoiced') {
                    $scope.F_SOClaimRes.closeSOClaimResModal();
            } else {
                 SOClaimService.saveClaimResponse(ServiceOrderHeaderId, JSON.stringify(claimResponse), currentStepNumber).then(new success(successJson).handler, new error().handler);         
            }
		}
           
        $scope.F_SOClaimRes.updateClaimedValues = function(index) {
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ApprovedQty = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ClaimedQty;
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ApprovedPrice = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ClaimedPrice;
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ClaimedSubtotal = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ClaimedQty * $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].ClaimedPrice;
        	$scope.F_SOClaimRes.calculateClaimResponseVariance(index);
        	if($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index].IsCalculateSupplies) {
        		var shopSupplyIndex = _.findIndex($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList, {
        			'SOLIType': 'Shop Supply'
        		});
        		if(shopSupplyIndex != -1) {
        			calculateShopSuppliesValues(shopSupplyIndex);
        		}
        	}
        }
        
        function calculateShopSuppliesValues(shopSupplyIndex) {
        	var labourSOLIList = [];
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList
        	for(var j = 0; j < $scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex].SOGridItems.length; j++) {
        		labourSOLIList = labourSOLIList.concat(_.filter($scope.M_CO.SOHeaderList[$stateParams.ServiceJobClaimResponseParams.soHeaderIndex].SOGridItems[j].SOLIList, function(soli) {
                	var isShopSuppliesAppliedOnLabor = false;
        			if(soli.IsLabour && $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList) {
                		for(var i = 0; i < $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList.length; i++) {
                			if($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].ServiceOrderLineItem == soli.Id && 
                					$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[i].IsCalculateSupplies) {
                				isShopSuppliesAppliedOnLabor = true;
                			}
                		}
                	}
        			return (isShopSuppliesAppliedOnLabor);
                }));
        	}
        	var shopSupplyAmount = 0;
        	for(var i=0; i<labourSOLIList.length; i++) {
        		if(shopSuppliesCustomSetting) {
        			var index = _.findIndex($scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList, {
            			'ServiceOrderLineItem': labourSOLIList[i].Id
            		});
        			if(index != -1) {
        				var claimLI = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[index];
        				if(shopSuppliesCustomSetting.CalculationMethod == 'Fixed Amount per Hour') {
                            shopSupplyAmount += (claimLI.ApprovedQty * shopSuppliesCustomSetting.SuppliesRate);
                        } else if(shopSuppliesCustomSetting.CalculationMethod == 'Percentage of Labor Total') {
                        	shopSupplyAmount += ((claimLI.ApprovedQty * claimLI.ApprovedPrice * shopSuppliesCustomSetting.SuppliesRate) / 100);
                        }
        			}
        		}
        	}
        	shopSupplyAmount = shopSupplyAmount.toFixed(2);
        	if(shopSupplyAmount > shopSuppliesCustomSetting.MaximumPerInvoice) {
                shopSupplyAmount = shopSuppliesCustomSetting.MaximumPerInvoice;
            }
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[shopSupplyIndex].ClaimedPrice = shopSupplyAmount;
        	$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[shopSupplyIndex].ApprovedPrice = shopSupplyAmount;
			$scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[shopSupplyIndex].ClaimedSubtotal = $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[shopSupplyIndex].ClaimedQty * $scope.M_SOClaimRes.wizardInfo.NonVarianceLineItemList[shopSupplyIndex].ClaimedPrice;
			$scope.F_SOClaimRes.calculateClaimResponseVariance(shopSupplyIndex);
        }
        
        $scope.F_SOClaimRes.finalizeClaimResponse = function(soHeaderId, claimResponse) {
        	$scope.M_SOClaimRes.isLoading = true;
        	var successJson = {
                'calleeMethodName': 'finalizeClaimResponse',
                'isBindAllServiceJobData' : true
            };
        	SOClaimService.finalizeClaimResponse(soHeaderId, JSON.stringify(claimResponse)).then(new success(successJson).handler, new error().handler);
        }

        function openSOClaimResModal() {
        	$scope.M_SOClaimRes.isLoading = true;
            setTimeout(function() {
                angular.element('#ServiceJobClaimResponseModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
            if ($stateParams.ServiceJobClaimResponseParams.soHeaderId != undefined) {
                $scope.M_SOClaimRes.WizardSOHeaderIndex = $stateParams.ServiceJobClaimResponseParams.soHeaderIndex;
                $scope.M_SOClaimRes.WizardSOHeaderId = $stateParams.ServiceJobClaimResponseParams.soHeaderId;
                $scope.M_SOClaimRes.WizardSOHeader = angular.copy($scope.M_CO.SOHeaderList[$scope.M_SOClaimRes.WizardSOHeaderIndex]);
                $scope.M_SOClaimRes.WizardSOHeaderStatus = $stateParams.ServiceJobClaimResponseParams.soStatus;
                setClaimResponseData();
            }
        }
        openSOClaimResModal();
    }])
});