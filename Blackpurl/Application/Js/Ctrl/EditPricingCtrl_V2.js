define(['Routing_AppJs_PK', 'EditPricingServices_V2'], function(Routing_AppJs_PK, EditPricingServices_V2) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('EditPricingCtrl_V2', ['$scope', '$rootScope', '$state', '$stateParams', 'EditPricingService','$translate', function($scope, $rootScope, $state, $stateParams, EditPricingService,$translate) {
        var Notification = injector.get("Notification");
        $scope.M_EditPrice = $scope.M_EditPrice || {};
        $scope.F_EditPrice = $scope.F_EditPrice || {};
        $scope.M_EditPrice.UnitPriceData = {};
        $scope.M_EditPrice.shownSaveButton = '';
        $scope.M_EditPrice.PriceLocalFactoryOption = [];
        $scope.M_EditPrice.PriceLocalDealerOption = [];
        $scope.F_EditPrice.enableSaveAction = function(event, element, index) {
            switch (element) {
                case "BasePrice":
                    if ($scope.M_EditPrice.UnitPriceData.TotalBasePrice_Old != $scope.M_EditPrice.UnitPriceData.TotalBasePrice) {
                        saveActionFromKeyBoard(event, element, index);
                        $scope.M_EditPrice.shownSaveButton = element;
                    }
                    break;
                case "StampDuty":
                    if ($scope.M_EditPrice.UnitPriceData.TotalStampDuty_Old != $scope.M_EditPrice.UnitPriceData.TotalStampDuty) {
                        saveActionFromKeyBoard(event, element, index);
                        $scope.M_EditPrice.shownSaveButton = element;
                    }
                    break;
                case "RideawayPrice":
                    if ($scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice_Old != $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice) {
                        saveActionFromKeyBoard(event, element, index);
                        $scope.M_EditPrice.shownSaveButton = element;
                    }
                    break;
                case "DealerInstalled":
                    if ((!isNaN(index)) && $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Price_Old != $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Price) {
                        saveActionFromKeyBoard(event, element, index);
                        $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].TotalPrice = $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Qty * $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Price;
                    }
                    break;
                case "FactoryOption":
                    if ((!isNaN(index)) && $scope.M_EditPrice.UnitPriceData.FactoryOptionList[index].Price_Old != $scope.M_EditPrice.UnitPriceData.FactoryOptionList[index].Price) {
                        saveActionFromKeyBoard(event, element, index);
                    }
                    break;
            }
        }
        $scope.F_EditPrice.restoreOriginalValueOnBlur = function(event, calleeItem, index) {
            // Check for Reset value if focus is on related save button
            if (event.relatedTarget && (event.relatedTarget.id == ('SaveBtn' + calleeItem) || event.relatedTarget.id == ('SaveBtn' + calleeItem + index) || event.relatedTarget.id == ('InputFor' + calleeItem) || event.relatedTarget.id == ('InputFor' + calleeItem + index))) {
                return;
            }
            if ($scope.F_EditPrice.isCurrentLocaleAustralia()) {
                if ($scope.M_CO.isLoading === false) {
                    $scope.F_EditPrice.hideSaveBtn();
                    switch (calleeItem) {
                        case 'StampDuty':
                            $scope.M_EditPrice.UnitPriceData.TotalStampDuty = $scope.M_EditPrice.UnitPriceData.TotalStampDuty_Old;
                            break;
                        case 'BasePrice':
                            $scope.M_EditPrice.UnitPriceData.TotalBasePrice = $scope.M_EditPrice.UnitPriceData.TotalBasePrice_Old;
                            break;
                        case 'DealerInstalled':
                            $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Price = $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[index].Price_Old;
                            break;
                        case 'FactoryOption':
                            $scope.M_EditPrice.UnitPriceData.FactoryOptionList[index].Price = $scope.M_EditPrice.UnitPriceData.FactoryOptionList[index].Price_Old;
                            break;
                        case 'RideawayPrice':
                            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice_Old;
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        $scope.F_EditPrice.actionOnSaveButton = function(event, targetInput, index) {
            if (event.keyCode == 13) {
                saveActionFromKeyBoard(event, targetInput, index);
            } else if (event.keyCode == 9 && targetInput) {
                event.preventDefault();
                setFocusOnInput(targetInput, index);
            }
        }

        function setFocusOnInput(targetInput, index) {
            if (!isNaN(index)) {
                $scope.F_CO.setFocusOnInput('InputFor' + targetInput + index);
            } else {
                $scope.F_CO.setFocusOnInput('InputFor' + targetInput);
            }
        }

        function saveActionFromKeyBoard(event, targetInput, index) {
            if (event.keyCode == 13) {
                if (targetInput.includes('BasePrice') || targetInput.includes('Factory') || targetInput.includes('Dealer')) {
                    $scope.F_EditPrice.saveAction();
                } else if (targetInput.includes('StampDuty')) {
                    $scope.F_EditPrice.updateStampDutyTotal();
                } else if (targetInput.includes('Rideaway')) {
                    $scope.F_EditPrice.updateRideawayPricing();
                }
            }
        }
        $scope.F_EditPrice.hideSaveBtn = function() {
            $scope.M_EditPrice.shownSaveButton = '';
        }
        $scope.F_EditPrice.getMinimumRideawayThresholdValue = function() {
            var unitPrice = $scope.M_EditPrice.UnitPriceData;
            if (unitPrice.TotalEnforceRideawayPrice == undefined || unitPrice.TotalEnforceRideawayPrice == null || unitPrice.TotalEnforceRideawayPrice == '') {
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = 0;
                unitPrice.TotalEnforceRideawayPrice = 0;
            }
            var minRideawayPrice = 0;
            if (unitPrice.TotalBasePrice != undefined && unitPrice.TotalBasePrice != null && unitPrice.TotalBasePrice != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalBasePrice);
            }
            if (unitPrice.TotalFactoryOption != undefined && unitPrice.TotalFactoryOption != null && unitPrice.TotalFactoryOption != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalFactoryOption);
            }
            if (unitPrice.TotalDealerInstalledOption != undefined && unitPrice.TotalDealerInstalledOption != null && unitPrice.TotalDealerInstalledOption != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalDealerInstalledOption);
            }
            if (unitPrice.TotalPartAndLabor != undefined && unitPrice.TotalPartAndLabor != null && unitPrice.TotalPartAndLabor != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalPartAndLabor);
            }
            if (unitPrice.TotalFee && unitPrice.TotalFee != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalFee);
            }
            if (unitPrice.TotalSublet) {
                minRideawayPrice += parseFloat(unitPrice.TotalSublet);
            }
            if (unitPrice.TotalStampDuty != undefined && unitPrice.TotalStampDuty != null && unitPrice.TotalStampDuty != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalStampDuty);
            }
            minRideawayPrice = parseFloat(minRideawayPrice.toFixed(2));
            return minRideawayPrice;
        }
        $scope.F_EditPrice.recalculateMinimumRideAwayWhileSaving = function() {
            var unitPrice = $scope.M_EditPrice.UnitPriceData;
            if (unitPrice.TotalEnforceRideawayPrice == undefined || unitPrice.TotalEnforceRideawayPrice == null || unitPrice.TotalEnforceRideawayPrice == '') {
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = 0;
                unitPrice.TotalEnforceRideawayPrice = 0;
            }
            var minRideawayPrice = 0;
            if (unitPrice.TotalFactoryOption != undefined && unitPrice.TotalFactoryOption != null && unitPrice.TotalFactoryOption != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalFactoryOption);
            }
            if (unitPrice.TotalDealerInstalledOption != undefined && unitPrice.TotalDealerInstalledOption != null && unitPrice.TotalDealerInstalledOption != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalDealerInstalledOption);
            }
            if (unitPrice.TotalPartAndLabor != undefined && unitPrice.TotalPartAndLabor != null && unitPrice.TotalPartAndLabor != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalPartAndLabor);
            }
            if (unitPrice.TotalFee && unitPrice.TotalFee != '') {
                minRideawayPrice += parseFloat(unitPrice.TotalFee);
            }
            if (unitPrice.TotalSublet) {
                minRideawayPrice += parseFloat(unitPrice.TotalSublet);
            }
            if ($scope.M_CO.StampDutyRate == undefined || $scope.M_CO.StampDutyRate == null || $scope.M_CO.StampDutyRate == '') {
                $scope.M_CO.StampDutyRate = 0;
            }
            if (unitPrice.TotalStampDuty != undefined && unitPrice.TotalStampDuty != null && unitPrice.TotalStampDuty != '') {
                var minStampDuty = 0;
                if ((unitPrice.TotalFactoryOption + unitPrice.TotalDealerInstalledOption) > 100) {
                    minStampDuty = ((Math.ceil((unitPrice.TotalFactoryOption + unitPrice.TotalDealerInstalledOption) / 100) * 100) * ($scope.M_CO.StampDutyRate / 100));
                }
                minRideawayPrice += minStampDuty;
            }
            minRideawayPrice = parseFloat(minRideawayPrice.toFixed(2));
            return minRideawayPrice;
        }
        $scope.F_EditPrice.toggleRideawayPriceItem = function(event) {
            $scope.F_EditPrice.hideSaveBtn();
            $scope.M_CO.isLoading = true;
            var minRideawayPrice = $scope.F_EditPrice.getMinimumRideawayThresholdValue();
            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = minRideawayPrice;
            var IsRideawayPricingEnabled = $scope.M_EditPrice.UnitPriceData.IsRideawayPricingEnabled;
            var dealItemId = $scope.M_EditPrice.UnitPriceData.DealItemObj.Id;
            var dealItemIndex = $scope.M_EditPrice.UnitIndex;
            EditPricingService.toggleRideawayPricingEnabled(dealItemId, minRideawayPrice, IsRideawayPricingEnabled).then(function(successResult) {
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = successResult.TotalEnforceRideawayPrice;
                $scope.M_CO.Deal.UnitList[dealItemIndex].IsRideawayPricingEnabled = successResult.IsRideawayPricingEnabled;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalEnforceRideawayPrice = successResult.TotalEnforceRideawayPrice;
                $scope.M_CO.isLoading = false;
                $scope.F_CO.updateDealSummaryTotals();
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice_Old = $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice;
            }, function(errorResult) {
                $scope.M_CO.isLoading = false;
                Notification.error(errorResult + ' ' + $translate.instant('Generic_Error'));
            });
        }
        $scope.F_EditPrice.updateRideawayPricing = function() {
            $scope.M_CO.isLoading = true;
            var minRideawayPrice = $scope.F_EditPrice.recalculateMinimumRideAwayWhileSaving();
            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = parseFloat($scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice);
            if ($scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice < minRideawayPrice) {
                Notification.error($translate.instant('Min_rideaway_price_error'));
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = minRideawayPrice;
            }
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            var dealItemId = $scope.M_EditPrice.UnitPriceData.DealItemObj.Id;
            var dealItemIndex = $scope.M_EditPrice.UnitIndex;
            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = parseFloat($scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice);
            var changedPriceModel = $scope.M_EditPrice.UnitPriceData;
            EditPricingService.updateRideawayPricing(dealItemId, angular.toJson(changedPriceModel)).then(function(successResult) {
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalBasePrice = successResult.TotalBasePrice;
                $scope.M_CO.Deal.UnitList[dealItemIndex].Total = successResult.Total;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalStampDuty = successResult.TotalStampDuty;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalEnforceRideawayPrice = successResult.TotalEnforceRideawayPrice;
                $scope.M_CO.Deal.UnitList[dealItemIndex].BasePriceList = successResult.BasePriceList;
                $scope.M_CO.Deal.UnitList[dealItemIndex].IsRideawayPricingEnabled = successResult.IsRideawayPricingEnabled;
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice_Old = $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice;
                $scope.F_EditPrice.setLocalModal();
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_EditPrice.hideSaveBtn();
                $scope.M_CO.isLoading = false;
            }, function(errorResult) {
                Notification.error(errorResult + ' ' + $translate.instant('Generic_Error'));
                $scope.M_CO.isLoading = false;
            });
        }
        $scope.F_EditPrice.updateStampDutyTotal = function() {
            $scope.M_CO.isLoading = true;
            var stampDutyTotal = parseFloat($scope.M_EditPrice.UnitPriceData.TotalStampDuty);
            var dealItemId = $scope.M_EditPrice.UnitPriceData.DealItemObj.Id;
            var dealItemIndex = $scope.M_EditPrice.UnitIndex;
            EditPricingService.updateStampDuty(dealItemId, (stampDutyTotal).toString()).then(function(successfulResult) {
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalStampDuty = successfulResult.TotalStampDuty;
                $scope.M_CO.Deal.UnitList[dealItemIndex].Total = successfulResult.Total;
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_EditPrice.setLocalModal();
                $scope.F_EditPrice.hideSaveBtn();
                $scope.M_CO.isLoading = false;
            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
                $scope.M_CO.isLoading = false;
            });
        };
        $scope.F_EditPrice.evaluateAcceptableValueOfRidewayPricing = function() {
            minRideawayPrice = $scope.F_EditPrice.getMinimumRideawayThresholdValue();
            if ($scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice < minRideawayPrice) {
            	Notification.error($translate.instant('Min_rideaway_price_error'));
                $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = minRideawayPrice;
            }
        }
        $scope.F_EditPrice.saveAction = function() {
            $scope.M_CO.isLoading = true;
            var baseFactoryDealerJSON = [];
            if ($scope.M_EditPrice.UnitPriceData.BasePriceList == undefined || $scope.M_EditPrice.UnitPriceData.BasePriceList.length == 0) {
                $scope.M_EditPrice.BasePriceObj = {
                    Type: 'Base',
                    Id: null,
                    Qty: 1,
                    Price: parseFloat($scope.M_EditPrice.UnitPriceData.TotalBasePrice),
                };
                $scope.M_EditPrice.UnitPriceData.BasePriceList.push($scope.M_EditPrice.BasePriceObj);
            } else {
                for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.BasePriceList.length; i++) {
                    $scope.M_EditPrice.UnitPriceData.BasePriceList[i].TotalPrice = ($scope.M_EditPrice.UnitPriceData.TotalBasePrice) / $scope.M_EditPrice.UnitPriceData.BasePriceList.length;
                    $scope.M_EditPrice.UnitPriceData.BasePriceList[i].Price = ($scope.M_EditPrice.UnitPriceData.BasePriceList[i].TotalPrice) / $scope.M_EditPrice.UnitPriceData.BasePriceList[i].Qty;
                }
            }
            for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.BasePriceList.length; i++) {
                baseFactoryDealerJSON.push($scope.M_EditPrice.UnitPriceData.BasePriceList[i]);
            }
            for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.FactoryOptionList.length; i++) {
                $scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price = parseFloat($scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price);
                baseFactoryDealerJSON.push($scope.M_EditPrice.UnitPriceData.FactoryOptionList[i]);
            }
            for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList.length; i++) {
                $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Qty = parseInt($scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Qty);
                $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price = parseFloat($scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price);
                $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].TotalPrice = parseFloat($scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].TotalPrice);
                baseFactoryDealerJSON.push($scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i]);
            }
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            var dealItemId = $scope.M_EditPrice.UnitPriceData.DealItemObj.Id;
            var dealItemIndex = $scope.M_EditPrice.UnitIndex;
            EditPricingService.updateDealUnitCostPrice(angular.toJson(baseFactoryDealerJSON), dealId, dealItemId).then(function(successfulSearchResult) {
                $scope.M_CO.Deal.UnitList[dealItemIndex].BasePriceList = successfulSearchResult.BasePriceList;
                $scope.M_CO.Deal.UnitList[dealItemIndex].DealerInstalledOptionList = successfulSearchResult.DealerInstalledOptionList;
                $scope.M_CO.Deal.UnitList[dealItemIndex].FactoryOptionList = successfulSearchResult.FactoryOptionList;
                $scope.M_CO.Deal.UnitList[dealItemIndex].Total = successfulSearchResult.Total;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalDealerInstalledOption = successfulSearchResult.TotalDealerInstalledOption;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalEnforceRideawayPrice = successfulSearchResult.TotalEnforceRideawayPrice;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalFactoryOption = successfulSearchResult.TotalFactoryOption;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalStampDuty = successfulSearchResult.TotalStampDuty;
                $scope.M_CO.Deal.UnitList[dealItemIndex].TotalBasePrice = successfulSearchResult.TotalBasePrice;
                $scope.F_EditPrice.setLocalModal();
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_EditPrice.hideSaveBtn();
                $scope.M_CO.isLoading = false;
                if (!$scope.F_EditPrice.isCurrentLocaleAustralia()) {
                    $scope.F_EditPrice.hideEditPricingModal();
                }
                Notification.success($translate.instant('Generic_Saved'));
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                $scope.M_CO.isLoading = false;
                Notification.error($translate.instant('Generic_Error'));
            });
        }
        $scope.F_EditPrice.tabActionFromLastInput = function(event) {
            event.preventDefault();
            if ($scope.M_EditPrice.UnitPriceData.IsRideawayPricingEnabled && $scope.F_EditPrice.isCurrentLocaleAustralia()) {
                $scope.F_CO.setFocusOnInput('InputForRideawayPrice');
            } else {
                $scope.F_CO.setFocusOnInput('InputForBasePrice');
            }
        }

        function openEditPricingModal() {
            setTimeout(function() {
                angular.element('#editPricingDetails').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                $scope.M_CO.isLoading = false;
            }, 100);
        }
        angular.element(document).on("click", "#editPricingDetails .modal-backdrop", function() {
            $scope.F_EditPrice.hideEditPricingModal();
        });
        $scope.F_EditPrice.hideEditPricingModal = function() {
            angular.element('#editPricingDetails').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            $scope.M_CO.isLoading = false;
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.F_EditPrice.isCurrentLocaleAustralia = function() {
            if ($scope.CompanyLocale === 'Australia') {
                return true;
            } else {
                return false;
            }
        }
        $scope.F_EditPrice.setLocalModal = function() {
            angular.copy($scope.M_CO.Deal.UnitList[$scope.M_EditPrice.UnitIndex], $scope.M_EditPrice.UnitPriceData);
            if ($scope.M_EditPrice.UnitPriceData && $scope.M_EditPrice.UnitPriceData.FactoryOptionList) {
                for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.FactoryOptionList.length; i++) {
                    $scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price = $scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price.toFixed(2);
                    $scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price_Old = $scope.M_EditPrice.UnitPriceData.FactoryOptionList[i].Price;
                }
            }
            if ($scope.M_EditPrice.UnitPriceData && $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList) {
                for (var i = 0; i < $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList.length; i++) {
                    $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price = $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price.toFixed(2);
                    $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].TotalPrice = $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].TotalPrice.toFixed(2);
                    $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price_Old = $scope.M_EditPrice.UnitPriceData.DealerInstalledOptionList[i].Price;
                }
            }
            $scope.M_EditPrice.UnitPriceData.TotalBasePrice = $scope.M_EditPrice.UnitPriceData.TotalBasePrice.toFixed(2);
            $scope.M_EditPrice.UnitPriceData.TotalStampDuty = $scope.M_EditPrice.UnitPriceData.TotalStampDuty.toFixed(2);
            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice = $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice.toFixed(2);
            $scope.M_EditPrice.UnitPriceData.TotalBasePrice_Old = $scope.M_EditPrice.UnitPriceData.TotalBasePrice;
            $scope.M_EditPrice.UnitPriceData.TotalStampDuty_Old = $scope.M_EditPrice.UnitPriceData.TotalStampDuty;
            $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice_Old = $scope.M_EditPrice.UnitPriceData.TotalEnforceRideawayPrice;
        }
        
        $scope.F_EditPrice.refreshDealUnitPriceCost = function() {
        	$scope.M_CO.isLoading = true;
        	var dealItemId = $scope.M_EditPrice.UnitPriceData.DealItemObj.Id;
            var unitId = $scope.M_EditPrice.UnitPriceData.DealItemObj.UnitId;
            var isRideawayPricingEnabled = $scope.M_EditPrice.UnitPriceData.IsRideawayPricingEnabled;
        	EditPricingService.refreshDealUnitPriceCost(dealItemId, unitId).then(function() {
        		$scope.F_CO.getAndUpdateDealAndDealItemTotals($scope.M_EditPrice.UnitIndex, 'unit', dealItemId).then(function() {
            		$scope.M_EditPrice.isRefreshLinkAvailable = false;
            		$scope.F_EditPrice.setLocalModal();
            		if(isRideawayPricingEnabled) {
            			$scope.M_EditPrice.UnitPriceData.IsRideawayPricingEnabled = true;
            			$scope.F_EditPrice.toggleRideawayPriceItem();
            		} else {
            			$scope.M_CO.isLoading = false;
            		}
    	        }, function(error) {
    	        	Notification.error($translate.instant('GENERIC_ERROR'));
    	       	 	$scope.M_CO.isLoading = false; 
    	        });
        	}, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                $scope.M_CO.isLoading = false;
            });
        }

        function loadEditPricingModalData() {
            $scope.M_EditPrice.UnitIndex = $stateParams.EditPricingParams.unitIndex;
            $scope.F_EditPrice.setLocalModal();
            openEditPricingModal();
            
            $scope.M_CO.isLoading = true;
            var dealItemId = $scope.M_CO.Deal.UnitList[$scope.M_EditPrice.UnitIndex].DealItemObj.Id;
            var unitId = $scope.M_CO.Deal.UnitList[$scope.M_EditPrice.UnitIndex].DealItemObj.UnitId;
            EditPricingService.checkForRefreshLinkOnDealUnitPriceCost(dealItemId, unitId).then(function(isRefreshLinkAvailable) {
            	$scope.M_EditPrice.isRefreshLinkAvailable = isRefreshLinkAvailable;
            	$scope.M_CO.isLoading = false;
            }, function(error) {
                Notification.error($translate.instant('GENERIC_ERROR'));
                $scope.M_CO.isLoading = false;
            });
        }
        loadEditPricingModalData();
    }])
});