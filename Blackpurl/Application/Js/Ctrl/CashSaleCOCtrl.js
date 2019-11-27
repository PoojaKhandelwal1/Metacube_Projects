define(['Routing_AppJs_PK', 'CashSaleCOServices', 'underscore_min', 'tel', 'AngularNgEnter', 'CashSaleCODirectives', 'CashSaleSTACtrl', 'shouldFocus'], function(Routing_AppJs_PK, CashSaleCOServices, underscore_min, tel, AngularNgEnter, CashSaleCODirectives, CashSaleSTACtrl, shouldFocus) { 
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CashSaleCOCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', '$window', '$document', 'CashSaleCOService', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, $window, $document, CashSaleCOService) {
        var Notification = injector1.get("Notification");
        var origin = window.location.origin;
        var url = origin + '/apex/';
        $scope.CashSaleModel = {};
        $scope.CashSaleModel.CustomerInfoData = {};
        $scope.CashSaleModel.CoHeaderRecordId = '';
        $scope.CashSaleModel.IsNewLineItemInserted = false;
        $scope.CashSaleModel.IsLineItemEditMode = false;
        $scope.CashSaleModel.showContent = false;
        $scope.CashSaleModel.specialOrderCODetails = {};                     
        $scope.CashSaleModel.isItemDescEditMode = false; 
        $scope.CashSaleModel.CashPaymentRoundingCentValue = $Global.Cash_Paymenmt_Rounding_Factor; 
        $scope.CashSaleModel.isCancelEditOnNewLineItemInsert = false; 
        $scope.CashSaleModel.displayGrid = false; 
        $scope.CashSaleModel.disableFinalizeButton = false; 
        if ($scope.CashSaleModel.coHeaderId == null || $scope.CashSaleModel.coHeaderId == undefined) {
            $scope.CashSaleModel.coHeaderId = $stateParams.Id ? $stateParams.Id : null;
        }
        $scope.CashSaleModel.selectedcashSaleChevronIndex = '1';
        $scope.CashSaleModel.displaySection = 'Add to Sale';
        $scope.CashSaleModel.cashSaleChevronList = [{
            Name: 'Back',
            isActive: true
        }, {
            Name: 'Add to Sale',
            isActive: false
        }, {
            Name: 'Edit Sale',
            isActive: false
        }, {
            Name: 'Review Sale',
            isActive: false
        }, {
            Name: 'Checkout',
            isActive: false
        }];
        $scope.CashSaleModel.calculateGridContainerHeight = function() {
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 15;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 25;
            }
            var GridContainerHeight = $(document).height() - ($rootScope.wrapperHeight + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSale_header_OrdNumber_status").height() + angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height() + 13 - navBarHeightDiffrenceFixedHeaderOpen); 
            angular.element(".cashSaleGridWrpper").css("height", GridContainerHeight);
            var CashSaleContentContainerHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight + angular.element("#mainContainerDueSection").height();
            angular.element(".cashSaleContent").css("height", CashSaleContentContainerHeight);
            var scrollableDivHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight;
            angular.element(".cashSaleHeader_and_cashSaleGridWrpper").css("height", scrollableDivHeight);
            var scrollableLeftDivHeight = $(document).height() - ($rootScope.wrapperHeight + +angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSaleCopyright").height() + 13);
            angular.element(".EditSaleSection.EditSaleSectionScroll").css("height", scrollableLeftDivHeight - navBarHeightDiffrenceFixedHeaderOpen);
            var GridContainerMB = angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height();
            setTimeout(function() {
                if (angular.element('.cashSaleGridWrpper').length > 0) {
                    angular.element('.cashSaleGridWrpper')[0].scrollIntoView(true);
                }
            }, 10);
        }
        $scope.CashSaleModel.loadCustomerOrder = function() {
            $scope.CashSaleModel.disableFinalizeButton = false; 
            $scope.CashSaleModel.previousURL = $rootScope.$previousState.name; 
            $scope.CashSaleModel.previousURLId = $rootScope.$previousStateParams.Id;
            $scope.CashSaleModel.previousURLParams = $rootScope.$previousStateParams.myParams;
            if ($scope.CashSaleModel.CashPaymentRoundingCentValue == null || $scope.CashSaleModel.CashPaymentRoundingCentValue == "" || $scope.CashSaleModel.CashPaymentRoundingCentValue == undefined) {
                $scope.CashSaleModel.CashPaymentRoundingCentValue = 1;
            }
            $scope.CashSaleModel.CashPaymentRoundingCentValue = parseInt($scope.CashSaleModel.CashPaymentRoundingCentValue);
            CashSaleCOService.getCOHeaderDetails($scope.CashSaleModel.coHeaderId).then(function(customerOrderData) {
                if (customerOrderData.COInvoiceHistoryRecs.length > 0) {
                    $scope.CashSaleModel.CoHeaderRecordId = customerOrderData.COInvoiceHistoryRecs[0].COInvoiceHeaderId;
                }
                $scope.CashSaleModel.showContent = true;
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                if ($scope.CashSaleModel.COData.coHeaderRec.CustomerId != null) {
                    CashSaleCOService.customerInfo($scope.CashSaleModel.COData.coHeaderRec.CustomerId).then(function(customerRecord) {
                        if (customerRecord.length > 0) {
                            $scope.CashSaleModel.setPreffered(customerRecord[0]);
                        }
                    });
                }
                $scope.CashSaleModel.setFocusToSTA();
                if ($scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    $scope.CashSaleModel.selectedcashSaleChevronIndex = '4';
                    $scope.CashSaleModel.displaySection = 'Checkout';
                }
                if (!$scope.CashSaleModel.disableChevronWhenNoLI() && !$scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    $scope.CashSaleModel.selectedcashSaleChevronIndex = '3';
                    $scope.CashSaleModel.displaySection = 'Review Sale';
                }
            }, function(errorSearchResult) {});
        }
        $scope.CashSaleModel.setFocusToSTA = function() {
            setTimeout(function() {
                angular.element('#cashSaleSTAInput').focus();
            }, 10);
        }
        $scope.CashSaleModel.bindCustomerOrderData = function(customerOrderData) {
            $scope.CashSaleModel.COData = customerOrderData;
            $scope.CashSaleModel.loadCustomerOrderCallback();
        }
        $scope.CashSaleModel.loadCustomerOrderCallback = function() {
            if ($scope.CashSaleModel.COData.coInvoiceHeaderRec != undefined) {
                CashSaleCOService.getCheckoutSalesTax($scope.CashSaleModel.COData.coInvoiceHeaderRec.COInvoiceHeaderId).then(function(result) {
                    $scope.CashSaleModel.checkoutSalesTaxList = result;
                    $scope.CashSaleModel.doCustomerOrderCalculation();
                }, function(errorSearchResult) {});
            } else {
                $scope.CashSaleModel.doCustomerOrderCalculation();
            }
        }
        $scope.CashSaleModel.doCustomerOrderCalculation = function() {
            var totalSalesTax = 0;
            var MerchTotal = 0
            for (var i = 0; i < $scope.CashSaleModel.COData.allCOLineItemRecs.length; i++) {
                MerchTotal += $scope.CashSaleModel.COData.allCOLineItemRecs[i].SubTotal;
            }
            var totalSalesTax = 0;
            if ($scope.CashSaleModel.checkoutSalesTaxList != undefined) {
                for (i = 0; i < $scope.CashSaleModel.checkoutSalesTaxList.length; i++) {
                    totalSalesTax += $scope.CashSaleModel.checkoutSalesTaxList[i].TaxAmount;
                }
            }
            if (!$scope.CashSaleModel.COData.IsTaxIncludingPricing) {
                $scope.CashSaleModel.COData.MerchandiseTotal = MerchTotal + totalSalesTax;
            } else {
                $scope.CashSaleModel.COData.MerchandiseTotal = MerchTotal
            }
            $scope.CashSaleModel.COData.SalexTax = totalSalesTax;
            if ($scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Closed' && $scope.CashSaleModel.COData.COInvoiceHistoryRecs.length > 0) {
                $scope.CashSaleModel.COData.coInvoicePaymentRecs = $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0].COInvoiceHeaderPaymentRecs;
            }
            if ($scope.CashSaleModel.IsNewLineItemInserted && !$scope.CashSaleModel.isItemDescEditMode) {
                var index = ($scope.CashSaleModel.COData.allCOLineItemRecs.length - 1); <!-- 05/11/2016 -->
                if (index > 1) {
                    index = (($scope.CashSaleModel.COData.allCOLineItemRecs[index].IsEnvFee) ? (index - 1) : index);
                }
                $scope.CashSaleModel.openeditAction(index);
            }
            setTimeout(function() {
                $scope.CashSaleModel.calculateGridContainerHeight();
            }, 10);
        }
        $scope.CashSaleModel.editLineItemIndex = -1;
        $scope.CashSaleModel.openeditAction = function(index) {
            $scope.CashSaleModel.editLineItemIndex = index;
            $scope.CashSaleModel.NextAction(2, false); 
            $scope.CashSaleModel.IsLineItemEditMode = true;
            if (index > -1) {
                $scope.CashSaleModel.editLineItem = angular.copy($scope.CashSaleModel.COData.allCOLineItemRecs[index]);
                $scope.CashSaleModel.editLineItem.Price = ($scope.CashSaleModel.editLineItem.Price).toFixed(2);
                $scope.CashSaleModel.editLineItemCopy = angular.copy($scope.CashSaleModel.COData.allCOLineItemRecs[index]);
            }
            if ($scope.CashSaleModel.IsNewLineItemInserted) {
                setTimeout(function() {
                    angular.element('#editSaleSaveBtnId').focus();
                }, 10);
            } else {
                setTimeout(function() {
                    angular.element('#saleQuantityContent').focus();
                }, 10);
            }
        }
        $scope.CashSaleModel.isPaymentDropdownOpen = false;
        $scope.CashSaleModel.openCheckoutScreen = function(e) {
            if (e) {
                e.stopPropagation();
            }
            $scope.CashSaleModel.IsPaymentReverseMode = false;
            $scope.CashSaleModel.isPaymentDropdownOpen = true;
            setTimeout(function() {
                angular.element('#dropDownDiv').find("li:first").find('a').focus();
            }, 10);
            if ($scope.CashSaleModel.displaySection == 'Checkout' && $scope.CashSaleModel.COData.allCOLineItemRecs != undefined && $scope.CashSaleModel.COData.allCOLineItemRecs != '' && $scope.CashSaleModel.COData.allCOLineItemRecs != null && $scope.CashSaleModel.COData.allCOLineItemRecs.length > 0 && !$scope.CashSaleModel.IsPaymentReverseMode && $scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Closed') {
                setTimeout(function() {
                    angular.element('#checkoutPrintInvoiceBtnId').focus();
                }, 12);
            }
            if ($scope.CashSaleModel.displaySection == 'Checkout' && !$scope.CashSaleModel.disableReversePaymentBtn() && !$scope.CashSaleModel.IsPaymentReverseMode && $scope.CashSaleModel.calculateBalanceDue() == 0 && $scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Open') {
                setTimeout(function() {
                    angular.element('#checkoutFinaliseSaleBtnId').focus();
                }, 12);
            }
        }
        $scope.CashSaleModel.NextAction = function(index, isAllowFirstToEdit) {
            $scope.CashSaleModel.moveIndextoNext = index;
            if (index == 4) {
                if ($scope.CashSaleModel.disableChevronWhenNoLI()) {
                    return;
                }
            } else if (index == 1 || index == 3) {
                if ($scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    return;
                }
            } else if (index == 2) {
                if (($scope.CashSaleModel.disableChevronWhenNoLI() && !$scope.CashSaleModel.IsNewLineItemInserted) || $scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    return;
                }
            }
            if ($scope.CashSaleModel.IsLineItemEditMode) {
                angular.element('#NavigateConfirmBox').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                return;
            }
            if (index == 4 && $scope.CashSaleModel.displaySection != 'Checkout') { 
                $scope.CashSaleModel.selectedOption = 'Please Select';
                $scope.CashSaleModel.Payment_Amount = "";
            }
            $scope.CashSaleModel.selectedcashSaleChevronIndex = index;
            $scope.CashSaleModel.displaySection = $scope.CashSaleModel.cashSaleChevronList[index].Name;
            if (index == 3) {
                if (!$scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    $scope.CashSaleModel.setFocusToSTA();
                }
            }
            var COLI = [];
            for (var i = 0; i < $scope.CashSaleModel.COData.allCOLineItemRecs.length; i++) {
                COLI.push($scope.CashSaleModel.COData.allCOLineItemRecs[i]);
            }
            if (index == 2 && isAllowFirstToEdit == undefined && COLI.length == 1) {
                $scope.CashSaleModel.openeditAction(0);
            }
            if (index == 1) {
                $scope.CashSaleModel.setFocusToSTA();
            }
        }
        $scope.CashSaleModel.ConfirmBox_Response = function(response) {
            if (response) {
                $scope.CashSaleModel.IsLineItemEditMode = false;
                $scope.CashSaleModel.IsNewLineItemInserted = false;
                if (($scope.CashSaleModel.disableChevronWhenNoLI() && !$scope.CashSaleModel.IsNewLineItemInserted) || $scope.CashSaleModel.disableChevronWhenOrderClosed()) {
                    angular.element('#cashSaleCrumbs .cashSaleCrumbs_li3 a').addClass('disableChevron');
                    angular.element('#ReviewSaleEditSaleBlock').addClass('disableReviewOptions');
                }
                $scope.CashSaleModel.NextAction($scope.CashSaleModel.moveIndextoNext);
            }
            angular.element('#NavigateConfirmBox').modal('hide');
        }
        $scope.CashSaleModel.navigateFromReviewScreen = function(e, screenIndex) {
            if (e) {
                e.stopPropagation();
            }
            $scope.CashSaleModel.NextAction(screenIndex);
        }
        $scope.$on('cashSaleSTACallback', function(name, args) {
            $scope.CashSaleModel.recentlyAddedLineItem = args;
            $scope.CashSaleModel.InsertLineItem($scope.CashSaleModel.recentlyAddedLineItem);
        });
        $scope.CashSaleModel.InsertLineItem = function(lineItem) {
            $scope.CashSaleModel.IsNewLineItemInserted = true;
            $scope.CashSaleModel.selectedOption = 'Please Select';
            if (lineItem.Info == "Fee") {
                $scope.CashSaleModel.InsertFee(lineItem);
            }
            if (lineItem.Info == "Merchandise") {
                $scope.CashSaleModel.InsertPart(lineItem);
            }
        }
        $scope.CashSaleModel.InsertFee = function(lineItem) {
            CashSaleCOService.insertFeeInQuickCashSale(lineItem.Id, $scope.CashSaleModel.coHeaderId).then(function(customerOrderData) {
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
            });
        }
        $scope.CashSaleModel.InsertPart = function(lineItem) {
            if (lineItem.Info == "Merchandise" && lineItem.AdditionalDetails.AvailableQty <= 0 && !lineItem.NonInventoryPart) { 
                $scope.CashSaleModel.showOversoldPopup();
                return;
            }
            var LineItemList = [];
            LineItemList.push(lineItem.AdditionalDetails);
            CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
            });
        }
        $scope.CashSaleModel.IsPartReturn = false;
        $scope.CashSaleModel.UpdateLineItem = function() {
            var LineItemList = [];
            if ($scope.CashSaleModel.editLineItem.Qty == undefined || $scope.CashSaleModel.editLineItem.Qty == null || $scope.CashSaleModel.editLineItem.Qty === '') {
                Notification.error($Label.CashSaleCO_Please_enter_a_quantity_to_sell);
                return;
            }
            if ($scope.CashSaleModel.editLineItem.Price == undefined || $scope.CashSaleModel.editLineItem.Price == null || $scope.CashSaleModel.editLineItem.Price === '') {
                Notification.error($Label.CashSaleCO_Please_enter_the_price);
                return;
            }
            if ($scope.CashSaleModel.editLineItem.Price < 0) {
                Notification.error($Label.CashSaleCO_The_price_cannot_be_negative);
                return;
            }
            if ($scope.CashSaleModel.editLineItem.IsPart && !$scope.CashSaleModel.editLineItem.NonInventoryPart && $scope.CashSaleModel.editLineItem.Qty > ($scope.CashSaleModel.editLineItem.AvaliablePartsQty + $scope.CashSaleModel.editLineItemCopy.Qty)) {
                if ($scope.CashSaleModel.editLineItem.Qty != $scope.CashSaleModel.editLineItemCopy.Qty && $scope.CashSaleModel.editLineItem.Qty > 0) { 
                    $scope.CashSaleModel.showOversoldPopup();
                    return;
                }
            }
            if ($scope.CashSaleModel.editLineItem.Qty < 0) {
                $scope.CashSaleModel.IsPartReturn = true;
            }
            LineItemList.push($scope.CashSaleModel.editLineItem);
            CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                $scope.CashSaleModel.editLineItem = null;
                $scope.CashSaleModel.IsLineItemEditMode = false;
                $scope.CashSaleModel.IsNewLineItemInserted = false;
                $scope.CashSaleModel.isItemDescEditMode = false;
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                $scope.CashSaleModel.editedLineItemAttributeId = '';
                $scope.CashSaleModel.NextAction(3);
            });
        }
        $scope.CashSaleModel.OpenLineItemDescEditAction = function() {
            $scope.CashSaleModel.COLI_ItemDesc = $scope.CashSaleModel.editLineItem.ItemDescription;
            $scope.CashSaleModel.isItemDescEditMode = true;
            setTimeout(function() {
                angular.element('#' + 'cashSalePartDetailsSectionEditItemDescId').focus();
            }, 10);
        }
        $scope.CashSaleModel.editCOLIItemDesc = function() {
            var LineItemList = [];
            if ($scope.CashSaleModel.COLI_ItemDesc == undefined || $scope.CashSaleModel.COLI_ItemDesc == null || $scope.CashSaleModel.COLI_ItemDesc === '') {
                Notification.error($Label.CashSaleCO_Please_enter_an_item_description);
                return;
            }
            $scope.CashSaleModel.editLineItem.ItemDescription = $scope.CashSaleModel.COLI_ItemDesc;
            LineItemList.push($scope.CashSaleModel.editLineItem);
            CashSaleCOService.editLineItemDesc($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                $scope.CashSaleModel.editLineItem = null;
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                $scope.CashSaleModel.editLineItem = angular.copy($scope.CashSaleModel.COData.allCOLineItemRecs[$scope.CashSaleModel.editLineItemIndex]);
                $scope.CashSaleModel.isItemDescEditMode = false;
                setTimeout(function() {
                    angular.element('#saleQuantityContent').focus();
                }, 10);
            });
        }
        $scope.CashSaleModel.keydown = function(event) {
            if (event.which == 9 || event.which == 13) {
                $scope.CashSaleModel.editCOLIItemDesc();
            }
        }
        $scope.CashSaleModel.cancelLineItemDescEditAction = function() {
            $scope.CashSaleModel.COLI_ItemDesc = '';
            $scope.CashSaleModel.isItemDescEditMode = false;
            setTimeout(function() {
                angular.element('#saleQuantityContent').focus();
            }, 10);
        }
        $scope.CashSaleModel.removeLineItem = function(lineItemId) {
            CashSaleCOService.removeLineItemsInMerchGrid(lineItemId, $scope.CashSaleModel.coHeaderId).then(function(customerOrderData) {
                $scope.CashSaleModel.editLineItem = null;
                $scope.CashSaleModel.IsLineItemEditMode = false;
                $scope.CashSaleModel.IsNewLineItemInserted = false;
                $scope.CashSaleModel.isItemDescEditMode = false;
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                $scope.CashSaleModel.editedLineItemAttributeId = '';
                if (customerOrderData.allCOLineItemRecs.length > 0 && !($scope.CashSaleModel.isCancelEditOnNewLineItemInsert)) {
                    $scope.CashSaleModel.NextAction(3);
                } else {
                    $scope.CashSaleModel.NextAction(1);
                }
                $scope.CashSaleModel.isCancelEditOnNewLineItemInsert = false;
            }, function(errorSearchResult) {
                $scope.CashSaleModel.isCancelEditOnNewLineItemInsert = false;
            });
        }
        $scope.CashSaleModel.cancelEditAction = function(lineItemId) {
            if ($scope.CashSaleModel.isCancelEditOnNewLineItemInsert) {
                return;
            }
            $scope.CashSaleModel.isCancelEditOnNewLineItemInsert = false;
            if ($scope.CashSaleModel.IsNewLineItemInserted) {
                $scope.CashSaleModel.isCancelEditOnNewLineItemInsert = true;
                $scope.CashSaleModel.removeLineItem(lineItemId);
            } else {
                $scope.CashSaleModel.editLineItem = null;
                $scope.CashSaleModel.IsLineItemEditMode = false;
                $scope.CashSaleModel.editedLineItemAttributeId = '';
                $scope.CashSaleModel.isItemDescEditMode = false;
                $scope.CashSaleModel.IsNewLineItemInserted = false;
                $scope.CashSaleModel.NextAction(3);
            }
        }
        $scope.CashSaleModel.cancelReversePaymentAction = function() {
            $scope.CashSaleModel.IsPaymentReverseMode = false;
            $scope.CashSaleModel.isReversePaymentMethodSelectedFromDropdown = false;
            $scope.CashSaleModel.ReverseLink = null;
            $scope.CashSaleModel.Payment_Amount = "";
            $scope.CashSaleModel.selectedOption = 'Please Select';
        }
        $scope.CashSaleModel.showOversoldPopup = function() {
            setTimeout(function() {
                angular.element('#createSpecialOrderActionBtn').focus();
            }, 200);
            angular.element('#OversoldPopUp').modal({
                backdrop: 'static',
                keyboard: false
            });
        }
        $scope.CashSaleModel.closeOversoldPopup = function(isCancelAction) {
            $scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder = false; 
            if (isCancelAction != undefined && isCancelAction) {
                $scope.CashSaleModel.IsNewLineItemInserted = false;
            }
            angular.element('#OversoldPopUp').modal('hide');
        }
        $scope.CashSaleModel.createSpecialOrderAction = function() {
            $scope.CashSaleModel.displayGrid = true; 
            var LineItemList = [];
            if ($scope.CashSaleModel.editLineItem != undefined && $scope.CashSaleModel.editLineItem != '' && $scope.CashSaleModel.editLineItem != null && $scope.CashSaleModel.editLineItem.Qty != undefined && $scope.CashSaleModel.editLineItem.Qty != '' && $scope.CashSaleModel.editLineItem.Qty != null) { 
                LineItemList.push($scope.CashSaleModel.editLineItem);
            } else {
                $scope.CashSaleModel.recentlyAddedLineItem.AdditionalDetails.Qty = 1;
                LineItemList.push($scope.CashSaleModel.recentlyAddedLineItem.AdditionalDetails);
            }
            CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                $scope.CashSaleModel.closeOversoldPopup();
                $scope.CashSaleModel.IsLineItemEditMode = false;
                $scope.CashSaleModel.IsNewLineItemInserted = false;
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                $scope.CashSaleModel.editedLineItemAttributeId = '';
                $scope.CashSaleModel.NextAction(3);
                var coLiId = "";
                var coKHLength = $scope.CashSaleModel.COData.COKHList.length;
                if ($scope.CashSaleModel.COData.COKHList[coKHLength - 1].COLIList[0].Status == "Required") {
                    coLiId = $scope.CashSaleModel.COData.COKHList[coKHLength - 1].COLIList[0].CoLineItemId;
                }
                var json = {
                    "coliId": coLiId
                };
                $scope.CashSaleModel.MoveToState('CustomerOrder', {
                    Id: $scope.CashSaleModel.coHeaderId,
                    myParams: json
                });
            });
        }
        $scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder = false;
        $scope.CashSaleModel.openSelectCustomerPopUpForSpecialOrder = function() {
            if ($scope.CashSaleModel.COData.coHeaderRec.CustomerId == null || $scope.CashSaleModel.COData.coHeaderRec.CustomerId == undefined || $scope.CashSaleModel.COData.coHeaderRec.CustomerId == '') {
                $scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder = true;
                $scope.CashSaleModel.openSelectCustomerPopUp();
            } else {
                $scope.CashSaleModel.createSpecialOrderAction();
            }
        }
        $scope.CashSaleModel.openSelectCustomerPopUp = function() {
            $scope.CashSaleModel.COHeaderDetailsForAddCustomer = {
                "COHeaderId": $scope.CashSaleModel.coHeaderId,
                "type": "Part Sale"
            };
            $scope.CashSaleModel.MoveToState('CashSaleCO.SelectCustomer', {
                myParams: $scope.CashSaleModel.COHeaderDetailsForAddCustomer
            });
        }
        $scope.$on('selectedCustomerForQCSCallback', function(event, args) {
            $scope.CashSaleModel.customerId = args;
            if ($scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder) { 
                $scope.CashSaleModel.displayGrid = true; 
                $scope.CashSaleModel.IsLineItemEditMode = false; 
            }
            CashSaleCOService.updateCustomerInQCS($scope.CashSaleModel.coHeaderId, $scope.CashSaleModel.customerId).then(function(customerOrderData) {
                if (!$scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder) { 
                    $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                }
                if ($scope.CashSaleModel.customerId != null) {
                    CashSaleCOService.customerInfo($scope.CashSaleModel.customerId).then(function(customerRecord) {
                        if (customerRecord.length > 0) {
                            $scope.CashSaleModel.setPreffered(customerRecord[0]);
                        }
                    });
                }
                if ($scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder) {
                    $scope.CashSaleModel.createSpecialOrderAction();
                }
            });
        });
        $scope.CashSaleModel.addCustomer = function() {
            $scope.CashSaleModel.openSelectCustomerPopUp();
        }
        $scope.CashSaleModel.setPreffered = function(customerRecord) {
            $scope.CashSaleModel.CustomerInfoData = customerRecord;
            if (!customerRecord.Cust_PreferredPhone) {
                if (customerRecord.Cust_HomeNumber) {
                    customerRecord.Cust_PreferredPhone = customerRecord.Cust_HomeNumber;
                } else if (customerRecord.Cust_WorkNumber) {
                    customerRecord.Cust_PreferredPhone = customerRecord.Cust_WorkNumber;
                } else if (customerRecord.Cust_Mobile) {
                    customerRecord.Cust_PreferredPhone = customerRecord.Cust_OtherNumber;
                } else {
                    customerRecord.Cust_PreferredPhone = '';
                }
            }
            if (!customerRecord.Cust_PreferredEmail) {
                if (customerRecord.Cust_HomeEmail.length > 0) {
                    customerRecord.Cust_PreferredEmail = customerRecord.Cust_HomeEmail;
                } else if (customerRecord.Cust_HomeEmail.length > 0) {
                    customerRecord.Cust_PreferredEmail = customerRecord.Cust_WorkEmail;
                } else if (customerRecord.Cust_OtherEmail) {
                    customerRecord.Cust_PreferredEmail = customerRecord.Cust_OtherEmail;
                } else {
                    customerRecord.Cust_PreferredEmail = '';
                }
            }
        }
        $scope.CashSaleModel.showSelectCustomerOption = function() {
            if ($scope.CashSaleModel.COData != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != undefined) {
                var totalPayment = 0;
                for (var i = 0; i < $scope.CashSaleModel.COData.coInvoicePaymentRecs.length; i++) {
                    totalPayment += $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].Amount;
                }
            }
            if ($scope.CashSaleModel.COData != undefined && (totalPayment != 0 || ($scope.CashSaleModel.COData.COInvoiceHistoryRecs != undefined && $scope.CashSaleModel.COData.COInvoiceHistoryRecs.length > 0))) { 
                return false;
            }
            return true;
        }
        $scope.CashSaleModel.forceOversoldAction = function() {
            $scope.CashSaleModel.isOpenSelectCustomerPopUpFromSpecialOrder = false; 
            var LineItemList = [];
            if ($scope.CashSaleModel.editLineItem != undefined && $scope.CashSaleModel.editLineItem != '' && $scope.CashSaleModel.editLineItem != null && $scope.CashSaleModel.editLineItem.Qty != undefined && $scope.CashSaleModel.editLineItem.Qty != '' && $scope.CashSaleModel.editLineItem.Qty != null) { 
                $scope.CashSaleModel.editLineItem.QtyCommitted = $scope.CashSaleModel.editLineItem.Qty;
                LineItemList.push($scope.CashSaleModel.editLineItem);
                CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                    $scope.CashSaleModel.closeOversoldPopup();
                    $scope.CashSaleModel.editLineItem = null;
                    $scope.CashSaleModel.IsLineItemEditMode = false;
                    $scope.CashSaleModel.IsNewLineItemInserted = false;
                    $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                    $scope.CashSaleModel.editedLineItemAttributeId = '';
                    $scope.CashSaleModel.NextAction(3);
                });
            } else if ($scope.CashSaleModel.IsNewLineItemInserted) {
                var LineItemList = [];
                LineItemList.push($scope.CashSaleModel.recentlyAddedLineItem.AdditionalDetails);
                CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                    var coKHLength = customerOrderData.COKHList.length;
                    customerOrderData.COKHList[coKHLength - 1].COLIList[0].QtyCommitted = 1;
                    var LineItemList = [];
                    LineItemList.push(customerOrderData.COKHList[coKHLength - 1].COLIList[0]);
                    CashSaleCOService.saveLineItemInQuickCashSale($scope.CashSaleModel.coHeaderId, JSON.stringify(LineItemList)).then(function(customerOrderData) {
                        $scope.CashSaleModel.closeOversoldPopup();
                        $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                    });
                });
            }
        }
        $scope.CashSaleModel.calculateBalanceDue = function(isRealValue) { 
            var balanceDue = 0;
            if ($scope.CashSaleModel.COData != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != undefined) {
                balanceDue = $scope.CashSaleModel.COData.MerchandiseTotal;
                var totalDeposit = 0;
                for (var i = 0; i < $scope.CashSaleModel.COData.coInvoicePaymentRecs.length; i++) { 
                    if ($scope.CashSaleModel.selectedOption == 'Cash' && isRealValue == undefined) {
                        if ($scope.CashSaleModel.COData.coInvoicePaymentRecs[i].PaymentMethod != 'Cash Rounding') {
                            totalDeposit += $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].Amount;
                        }
                    } else {
                        totalDeposit += $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].Amount;
                    }
                }
                totalDeposit = totalDeposit.toFixed(2);
                balanceDue = balanceDue - totalDeposit;
                if ($scope.CashSaleModel.selectedOption == 'Cash' && isRealValue == undefined) { 
                    balanceDue = $scope.CashSaleModel.CalculateCashPaymentRoundingAmount(balanceDue);
                }
            }
            return balanceDue.toFixed(2);
        }
        $scope.CashSaleModel.checkOutMode = 'Customer';
        $scope.CashSaleModel.finalizeQuickSale = function() {
            if ($scope.CashSaleModel.disableFinalizeButton) {
                return;
            }
            $scope.CashSaleModel.disableFinalizeButton = true; 
            CashSaleCOService.finalizeQuickSale(JSON.stringify($scope.CashSaleModel.COData.coInvoiceItemRecs), $scope.CashSaleModel.coHeaderId, $scope.CashSaleModel.checkOutMode).then(function(customerOrderData) {
                $scope.CashSaleModel.bindCustomerOrderData(customerOrderData);
                if ($scope.CashSaleModel.displaySection == 'Checkout' && $scope.CashSaleModel.COData.allCOLineItemRecs != undefined && $scope.CashSaleModel.COData.allCOLineItemRecs != '' && $scope.CashSaleModel.COData.allCOLineItemRecs != null && $scope.CashSaleModel.COData.allCOLineItemRecs.length > 0 && !$scope.CashSaleModel.IsPaymentReverseMode && $scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Closed') {
                    setTimeout(function() {
                        angular.element('#checkoutPrintInvoiceBtnId').focus();
                    }, 12);
                }
                $scope.CashSaleModel.disableFinalizeButton = false;
            }, function(errorSearchResult) {
                $scope.CashSaleModel.disableFinalizeButton = false;
                responseData = errorSearchResult;
            });
        }
        $scope.CashSaleModel.selectedOption = 'Please Select';
        $scope.CashSaleModel.optionSelected = function(optionValue) {
            $scope.CashSaleModel.selectedOption = optionValue;
            angular.element('#dropDownDiv').removeClass('open');
            var element = angular.element("#checkoutPaymentInputBoxId");
            if (element) {
                element.focus();
            }
            $scope.CashSaleModel.Payment_method = $scope.CashSaleModel.selectedOption;
            $scope.CashSaleModel.Payment_Amount = $scope.CashSaleModel.calculateBalanceDue();
            if ($scope.CashSaleModel.Payment_method == 'Store Credit' && $scope.CashSaleModel.COData.coHeaderRec.CustomerStoreCredit < $scope.CashSaleModel.Payment_Amount) {
                $scope.CashSaleModel.Payment_Amount = $scope.CashSaleModel.COData.coHeaderRec.CustomerStoreCredit;
            }
        }
        $scope.CashSaleModel.PaymentAmountChange = function() {
            $scope.CashSaleModel.ChangeDue = $scope.CashSaleModel.Payment_Amount - $scope.CashSaleModel.RoundedBalanceDue;
            if ($scope.CashSaleModel.ChangeDue < 0) {
                $scope.CashSaleModel.ChangeDue = 0.00;
            }
        }
        $scope.CashSaleModel.CalculateCashPaymentRoundingAmount = function(BalanceDue) {
            var CashPaymentRoundingDollarValue = $scope.CashSaleModel.CashPaymentRoundingCentValue / 100;
            var roundedBalanceDue = (Math.round(BalanceDue / CashPaymentRoundingDollarValue) * CashPaymentRoundingDollarValue).toFixed(2);
            roundedBalanceDue = parseFloat(roundedBalanceDue); 
            $scope.CashSaleModel.RoundedBalanceDue = roundedBalanceDue;
            return roundedBalanceDue;
        }
        $scope.CashSaleModel.addPayment = function() {
            $scope.CashSaleModel.Payment_method = $scope.CashSaleModel.selectedOption;
            $scope.CashSaleModel.isPaymentMethodError = false;
            $scope.CashSaleModel.isPaymentAmountError = false;
            if ($scope.CashSaleModel.Payment_method == 'Store Credit' && $scope.CashSaleModel.COData.coHeaderRec.CustomerStoreCredit < $scope.CashSaleModel.Payment_Amount) {
                Notification.error('Payment amount entered cannot exceed the available Store Credit Balance');
                return;
            }
            var Payment = [];
            var PaymentModel = {};
            var maxPayment = 999999.99;
            PaymentModel.ReverseLink = $scope.CashSaleModel.ReverseLink;
            PaymentModel.PaymentMethod = $scope.CashSaleModel.Payment_method;
            if ($scope.CashSaleModel.selectedOption == 'Cash' && $scope.CashSaleModel.Payment_Amount >= $scope.CashSaleModel.RoundedBalanceDue && !$scope.CashSaleModel.IsPaymentReverseMode) { 
                PaymentModel.Amount = $scope.CashSaleModel.RoundedBalanceDue;
                var RoundedPaymentModel = {};
                $scope.CashSaleModel.RoundedBalanceDue = parseFloat($scope.CashSaleModel.RoundedBalanceDue);
                RoundedPaymentModel.Amount = ($scope.CashSaleModel.calculateBalanceDue(true) - $scope.CashSaleModel.RoundedBalanceDue).toFixed(2);
                RoundedPaymentModel.PaymentMethod = 'Cash Rounding';
                RoundedPaymentModel.ReverseLink = $scope.CashSaleModel.ReverseLink;
                RoundedPaymentModel.COInvoiceHeaderId = $scope.CashSaleModel.COData.coInvoiceHeaderRec.COInvoiceHeaderId;
                RoundedPaymentModel.IsReverse = $scope.CashSaleModel.IsReverse;
                Payment.push(RoundedPaymentModel);
            } else {
                PaymentModel.Amount = $scope.CashSaleModel.Payment_Amount;
            }
            PaymentModel.COInvoiceHeaderId = $scope.CashSaleModel.COData.coInvoiceHeaderRec.COInvoiceHeaderId;
            PaymentModel.IsReverse = $scope.CashSaleModel.IsReverse; 
            var balanceDue = $scope.CashSaleModel.calculateBalanceDue();
            if (PaymentModel.PaymentMethod == "Please Select") {
                $scope.CashSaleModel.isPaymentMethodError = true;
                $scope.CashSaleModel.isPaymentMethodErrorMsg = "Please Select Payment Method";
            } else if (PaymentModel.Amount == "") {
                $scope.CashSaleModel.isPaymentAmountError = true;
                $scope.CashSaleModel.isPaymentAmountErrorMsg = "Please Enter Amount";
            } else if ((+(PaymentModel.Amount)).toFixed(2) == 0) {
                $scope.CashSaleModel.isPaymentAmountError = true;
                $scope.CashSaleModel.isPaymentAmountErrorMsg = "Amount Can't be Zero";
            } else if (isNaN(PaymentModel.Amount)) {
                $scope.CashSaleModel.isPaymentAmountError = true;
                $scope.CashSaleModel.isPaymentAmountErrorMsg = "Amount Should be Numeric";
            } else if (parseFloat(PaymentModel.Amount) > balanceDue && !$scope.CashSaleModel.IsPaymentReverseMode) { 
                if (PaymentModel.PaymentMethod != 'Cash') { 
                    $scope.CashSaleModel.isPaymentAmountError = true;
                    $scope.CashSaleModel.isPaymentAmountErrorMsg = "Amount Should not be greater than the balance due";
                }
            } else if (PaymentModel.Amount < 0 && !$scope.CashSaleModel.IsPaymentReverseMode && balanceDue >= 0) { 
                $scope.CashSaleModel.isPaymentAmountError = true;
                $scope.CashSaleModel.isPaymentAmountErrorMsg = "Amount Should be greater than Zero";
            } else if (parseFloat(PaymentModel.Amount) > maxPayment) {
                $scope.CashSaleModel.isPaymentAmountError = true;
                $scope.CashSaleModel.isPaymentAmountErrorMsg = "Amount cannot exceed 6 digits";
            }
            if ($scope.CashSaleModel.isPaymentMethodError) {
                Notification.error($scope.CashSaleModel.isPaymentMethodErrorMsg);
                return;
            } else if ($scope.CashSaleModel.isPaymentAmountError) {
                Notification.error($scope.CashSaleModel.isPaymentAmountErrorMsg);
                return;
            }
            $scope.CashSaleModel.IsPaymentReverseMode = false;
            PaymentModel.Amount = (+(PaymentModel.Amount)).toFixed(2);
            Payment.push(PaymentModel);
            $scope.CashSaleModel.processingPayment = true;
            CashSaleCOService.AddPayment(JSON.stringify(Payment)).then(function(successfulResult) {
                $scope.CashSaleModel.isReversePayment = false;
                $scope.CashSaleModel.ReverseLink = null; 
                $scope.CashSaleModel.Payment_Amount = 0;
                $scope.CashSaleModel.IsReverse = false; 
                $scope.CashSaleModel.RoundedBalanceDue = 0; 
                $scope.CashSaleModel.COData.coInvoicePaymentRecs = successfulResult.coInvoicePaymentRecs; 
                $scope.CashSaleModel.calculateGridContainerHeight();
                $scope.CashSaleModel.processingPayment = false;
                if ($scope.CashSaleModel.displaySection == 'Checkout' && !$scope.CashSaleModel.disableReversePaymentBtn() && !$scope.CashSaleModel.IsPaymentReverseMode && $scope.CashSaleModel.calculateBalanceDue() == 0 && $scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Open') {
                    setTimeout(function() {
                        angular.element('#checkoutFinaliseSaleBtnId').focus();
                    }, 12);
                }
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
            $scope.CashSaleModel.isReversePayment = false;
            $scope.CashSaleModel.ReverseLink = null;
            $scope.CashSaleModel.Payment_Amount = "";
            $scope.CashSaleModel.Payment_method = "Cash";
            $scope.CashSaleModel.selectedOption = 'Please Select';
        }
        $scope.CashSaleModel.isStoreCreditPaymentMethodAvailable = function() {
            var balanceDue = $scope.CashSaleModel.calculateBalanceDue();
            if ($scope.CashSaleModel.COData.coHeaderRec.CustomerId != null) {
                if (balanceDue < 0) {
                    return true;
                } else {
                    if ($scope.CashSaleModel.COData.coHeaderRec.CustomerStoreCredit == 0) {
                        return false;
                    }
                    return true;
                }
            }
            return false;
        }
        $scope.CashSaleModel.IsPaymentReverseMode = false;
        $scope.CashSaleModel.isReversePaymentMethodSelectedFromDropdown = false;
        $scope.CashSaleModel.ReverseLink = null;
        $scope.CashSaleModel.IsReverse = false; 
        $scope.CashSaleModel.openReversePaymentScreen = function() {
            $scope.CashSaleModel.IsPaymentReverseMode = true;
            if ($scope.CashSaleModel.reversiblePaymentListLength() == 1 || $scope.CashSaleModel.isReversePaymentMethodSelectedFromDropdown) {
                $scope.CashSaleModel.selectedOption = $scope.CashSaleModel.COData.coInvoicePaymentRecs[$scope.CashSaleModel.reversePaymentRecordIndexWithListSizeOne].PaymentMethod; 
                $scope.CashSaleModel.ReversePaymentAmount = $scope.CashSaleModel.COData.coInvoicePaymentRecs[$scope.CashSaleModel.reversePaymentRecordIndexWithListSizeOne].Amount.toFixed(2); 
                $scope.CashSaleModel.ReverseLink = $scope.CashSaleModel.COData.coInvoicePaymentRecs[$scope.CashSaleModel.reversePaymentRecordIndexWithListSizeOne].COInvoicePaymentId; 
                $scope.CashSaleModel.IsReverse = true; 
            }
            setTimeout(function() {
                angular.element('#checkoutReversePaymentButton').focus();
            }, 10);
        }
        $scope.CashSaleModel.reverseRefundOption = function() {
            if ($scope.CashSaleModel.COData != null && $scope.CashSaleModel.COData != '' && $scope.CashSaleModel.COData != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != '' && $scope.CashSaleModel.COData.coInvoicePaymentRecs != null && $scope.CashSaleModel.COData.coInvoicePaymentRecs.length == 1 && $scope.CashSaleModel.COData.coInvoicePaymentRecs[0].Amount < 0) {
                return true;
            } else {
                return false;
            }
        }
        $scope.CashSaleModel.disableReversePaymentBtn = function() {
            var isPaymentAvailabeForReverse = false;
            if (($scope.CashSaleModel.COData.allCOLineItemRecs == undefined || $scope.CashSaleModel.COData.allCOLineItemRecs == '' || $scope.CashSaleModel.COData.allCOLineItemRecs == null || $scope.CashSaleModel.COData.allCOLineItemRecs.length == 0)) {
                return true;
            }
            if (($scope.CashSaleModel.COData.coInvoicePaymentRecs == undefined || $scope.CashSaleModel.COData.coInvoicePaymentRecs == '' || $scope.CashSaleModel.COData.coInvoicePaymentRecs == null || $scope.CashSaleModel.COData.coInvoicePaymentRecs.length == 0)) {
                return true;
            }
            if ($scope.CashSaleModel.COData.coInvoicePaymentRecs != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != '' && $scope.CashSaleModel.COData.coInvoicePaymentRecs != null && $scope.CashSaleModel.COData.coInvoicePaymentRecs.length > 0) {
                for (var i = 0; i < $scope.CashSaleModel.COData.coInvoicePaymentRecs.length; i++) {
                    if ($scope.CashSaleModel.COData.coInvoicePaymentRecs[i].ReverseLink == null && $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].IsReverse == false) { 
                        isPaymentAvailabeForReverse = true;
                        break;
                    }
                }
            }
            return !isPaymentAvailabeForReverse;
        }
        $scope.CashSaleModel.reversePaymentRecordIndexWithListSizeOne = 0;
        $scope.CashSaleModel.reversiblePaymentListLength = function() {
            var lengthOfReversiblePaymentList = 0;
            if ($scope.CashSaleModel.COData != undefined && $scope.CashSaleModel.COData != '' && $scope.CashSaleModel.COData != null && $scope.CashSaleModel.COData.coInvoicePaymentRecs != undefined && $scope.CashSaleModel.COData.coInvoicePaymentRecs != '' && $scope.CashSaleModel.COData.coInvoicePaymentRecs != null && $scope.CashSaleModel.COData.coInvoicePaymentRecs.length > 0) {
                for (var i = 0; i < $scope.CashSaleModel.COData.coInvoicePaymentRecs.length; i++) {
                    if ($scope.CashSaleModel.COData.coInvoicePaymentRecs[i].ReverseLink == null && $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].IsReverse == false && $scope.CashSaleModel.COData.coInvoicePaymentRecs[i].PaymentMethod != 'Cash Rounding') {
                        $scope.CashSaleModel.reversePaymentRecordIndexWithListSizeOne = i;
                        lengthOfReversiblePaymentList++;
                    }
                }
            }
            return lengthOfReversiblePaymentList;
        }
        $scope.CashSaleModel.selectPaymentToBeReversed = function(index) {
            $scope.CashSaleModel.isReversePaymentMethodSelectedFromDropdown = true;
            $scope.CashSaleModel.selectedOption = $scope.CashSaleModel.COData.coInvoicePaymentRecs[index].PaymentMethod;
            $scope.CashSaleModel.ReversePaymentAmount = $scope.CashSaleModel.COData.coInvoicePaymentRecs[index].Amount.toFixed(2); 
            $scope.CashSaleModel.ReverseLink = $scope.CashSaleModel.COData.coInvoicePaymentRecs[index].COInvoicePaymentId;
            $scope.CashSaleModel.IsReverse = true; 
            setTimeout(function() {
                angular.element('#checkoutReversePaymentButton').focus();
            }, 10);
        }
        $scope.CashSaleModel.reversePayment = function() {
            $scope.CashSaleModel.isReversePaymentMethodSelectedFromDropdown = false;
            $scope.CashSaleModel.Payment_method = $scope.CashSaleModel.selectedOption;
            $scope.CashSaleModel.Payment_Amount = -($scope.CashSaleModel.ReversePaymentAmount);
            $scope.CashSaleModel.addPayment();
            $scope.CashSaleModel.IsPaymentReverseMode = false;
        }
        $scope.CashSaleModel.invoicePrintPriview = function() {
            if ($scope.CashSaleModel.COData.COInvoiceHistoryRecs[0] != undefined && $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0] != "" && $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0] != null) {
                var customerInvoiceId = $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0].COInvoiceHeaderId;
                var myWindow = window.open(url + "PrintCustomerOrderInvoice?id=" + customerInvoiceId, "", "width=1200, height=600");
            }
        }
        $scope.CashSaleModel.printReceipt = function() {
            var customerInvoiceId = $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0].COInvoiceHeaderId;
            var myWindow = window.open(url + "PrintScannedCustomerOrderInvoice?id=" + customerInvoiceId, "", "width=1200, height=600");
        }
        $scope.CashSaleModel.disableChevronWhenNoLI = function() {
            if ($scope.CashSaleModel.COData != undefined && $scope.CashSaleModel.COData != null && $scope.CashSaleModel.COData != '' && $scope.CashSaleModel.COData.allCOLineItemRecs.length > 0 ) { 
                return false;
            } else {
                return true;
            }
        }
        $scope.CashSaleModel.disableChevronWhenOrderClosed = function() {
            if ($scope.CashSaleModel.COData == undefined || $scope.CashSaleModel.COData == null || $scope.CashSaleModel.COData == '' || $scope.CashSaleModel.COData.coHeaderRec == undefined || $scope.CashSaleModel.COData.coHeaderRec == '' || $scope.CashSaleModel.COData.coHeaderRec == null || $scope.CashSaleModel.COData.coHeaderRec.OrderStatus == 'Closed') {
                return true;
            } else {
                return false;
            }
        }
        $scope.CashSaleModel.NextActionOnBack = function() {
            if ($scope.CashSaleModel.displaySection == 'Review Sale') {
                $scope.CashSaleModel.NextActionOnExit()
            } else if ($scope.CashSaleModel.displaySection == 'Checkout' && $scope.CashSaleModel.disableChevronWhenOrderClosed()) { 
                $scope.CashSaleModel.NextActionOnExit();
            } else if ($scope.CashSaleModel.displaySection == 'Add to Sale' && $scope.CashSaleModel.disableChevronWhenNoLI()) { 
                $scope.CashSaleModel.NextActionOnExit();
            } else {
                $scope.CashSaleModel.NextAction(3);
            }
        }
        $scope.CashSaleModel.NextActionOnExit = function() {
            loadState($state, 'homePage');
        }
        $scope.CashSaleModel.editedLineItemAttributeId = '123';
        $scope.CashSaleModel.setFocusOnLineItemAttribute = function() {
            $scope.CashSaleModel.editedLineItemAttributeId = 'COLI_ItemDesc_' + $scope.CashSaleModel.editLineItemIndex; 
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                $scope.$apply(); //TODO
            }
        }
        $scope.CashSaleModel.removeFocusOnLineItemAttribute = function(event) {
            $scope.CashSaleModel.editedLineItemAttributeId = ''; 
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') { 
                $scope.$apply(); //TODO
            }
        }
        angular.element($window).bind('orientationchange', function(event) {
            $scope.CashSaleModel.calculateGridContainerHeight1();
        });

        function getDeviceOrientation() {
            if (Math.abs(window.orientation) === 90) {
                return 'Landscape';
            } else {
                return 'Portrait';
            }
        }
        $scope.CashSaleModel.calculateGridContainerHeight1 = function() {
            var deviceHeight;
            if (getDeviceOrientation() === 'Landscape') {
                deviceHeight = $(window).height();
            } else if (getDeviceOrientation() === 'Portrait') {
                deviceHeight = $(document).height();
            }
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 15;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 25;
            }
            var GridContainerHeight = deviceHeight - ($rootScope.wrapperHeight + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSale_header_OrdNumber_status").height() + angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height() + 13 - navBarHeightDiffrenceFixedHeaderOpen);
            angular.element(".cashSaleGridWrpper").css("height", GridContainerHeight);
            var CashSaleContentContainerHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight + angular.element("#mainContainerDueSection").height();
            angular.element(".cashSaleContent").css("height", CashSaleContentContainerHeight);
            var scrollableDivHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight;
            angular.element(".cashSaleHeader_and_cashSaleGridWrpper").css("height", scrollableDivHeight);
            var scrollableLeftDivHeight = deviceHeight - ($rootScope.wrapperHeight + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSaleCopyright").height() + 13 - navBarHeightDiffrenceFixedHeaderOpen);
            angular.element(".EditSaleSection.EditSaleSectionScroll").css("height", scrollableLeftDivHeight);
            var GridContainerMB = angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height();
            setTimeout(function() {
                if (angular.element('.cashSaleGridWrpper').length > 0) {
                    angular.element('.cashSaleGridWrpper')[0].scrollIntoView(true);
                }
            }, 10);
        }
        $scope.safeApply = function(fn) {
            var phase = this.$root.$$phase;
            if (phase == '$apply' || phase == '$digest') {
                if (fn && (typeof(fn) === 'function')) {
                    fn();
                }
            } else {
                this.$apply(fn);
            }
        };
        $scope.CashSaleModel.EmailInvoicePreview = function() {
            var json = {
                customerId: $scope.CashSaleModel.COData.coHeaderRec.CustomerId,
                coHeaderId: $scope.CashSaleModel.COData.COInvoiceHistoryRecs[0].COInvoiceHeaderId,
                Activity: 'Email',
                customerInfo: $scope.CashSaleModel.CustomerInfoData,
                CustomerName: $scope.CashSaleModel.CustomerInfoData.Cust_Name
            };
            $scope.CashSaleModel.MoveToState('CashSaleCO.CustomerMessagingPopUp', {
                messagingInfoParams: json
            });
        }
        $scope.CashSaleModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.CashSaleModel.loadCustomerOrder();
    }])
});