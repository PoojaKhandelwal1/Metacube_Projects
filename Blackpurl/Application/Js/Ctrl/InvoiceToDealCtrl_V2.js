define(['Routing_AppJs_PK', 'CustomerOrderServices_V2'], function (Routing_AppJs_PK, CustomerOrderServices_V2) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('InvoiceToDealCtrl_V2', ['$scope', '$rootScope', '$state', 'CheckoutServices', 'SOHeaderService', '$stateParams','$translate', function ($scope, $rootScope, $state, CheckoutServices, SOHeaderService, $stateParams,$translate) {
        var Notification = injector.get("Notification");
        $scope.M_InvoiceToDeal = $scope.M_InvoiceToDeal || {};
        $scope.F_InvoiceToDeal = $scope.F_InvoiceToDeal || {};
        $scope.M_InvoiceToDeal.invoiceItemList = [];
        $scope.M_InvoiceToDeal.COHeaderId = $scope.M_CO.COHeaderId;
        $scope.M_InvoiceToDeal.selectedItemsToInvoiceList = [];

        function openInvoiceToDealModal() {
            setTimeout(function () {
                angular.element('#invoiceToDealPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                $scope.M_CO.isLoading = false;
            }, 100);
        }
        $scope.F_InvoiceToDeal.toggleinvoiceItemCheckbox = function (index) {
            $scope.M_InvoiceToDeal.invoiceItemList[index].isSelected = !($scope.M_InvoiceToDeal.invoiceItemList[index].isSelected);
        }
        angular.element(document).on("click", "#invoiceToDealPopup .modal-backdrop", function () {
            $scope.F_InvoiceToDeal.hideInvoiceToDealModal();
        });
        var success = function () {
            var self = this;
            this.arguments = arguments[0];
            this.calleeMethodName = arguments[0].calleeMethodName,
                this.callback = arguments[0].callback,
                this.handler = function (successResult) {
                    switch (self.calleeMethodName) {
                        case 'finalizeInvoice':
                            handlefinalizeInvoice();
                            break;
                        default:
                            break;
                    }

                    if (typeof self.callback === 'function') {
                        self.callback();
                    }
                }

            function handlefinalizeInvoice() {
            	SOHeaderService.getCOHeaderDetailsByGridName($stateParams.Id, null).then(function(successResult) {
            		$scope.M_CO.COKHList = successResult.COKHList;
                    $scope.M_CO.coHeaderRec.MerchandiseTotal = successResult.coHeaderRec.MerchandiseTotal;
                    $scope.M_CO.coHeaderRec = successResult.coHeaderRec;
                    $scope.M_CO.COInvoiceHistoryList = successResult.COInvoiceHistoryList;
                    if ($scope.M_CO.COInvoiceHistoryList.length > 0) {
                        $scope.F_CO.invoicePrintPreview($scope.M_CO.COInvoiceHistoryList[0].COInvoiceHeaderId);
                    }
                    var param = {
                        'isDealCallback': true,
                        'expandInvoiceSection': true
                    };
                    $scope.F_CO.callGetSOHeaderDetails(param);
                    $scope.F_InvoiceToDeal.hideInvoiceToDealModal(true);
                }, function(error) {
	                  $scope.M_CO.isLoading = false;
	                  handleErrorAndExecption(error);
                });
            }
         }
            
        var error = function (errorMessage) {
            this.handler = function (error) {
                $scope.M_CO.isLoading = false;
                if (errorMessage) {
                    Notification.error(errorMessage);
                }
            }
        }
        $scope.F_InvoiceToDeal.hideInvoiceToDealModal = function (showLoading) {
            angular.element('#invoiceToDealPopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            if (!showLoading) {
                $scope.M_CO.isLoading = false;
            }

            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.F_InvoiceToDeal.pushSelectedItemsForInvoice = function () {
            var itemsToInvoiceList = [];
            for (var j = 0; j < $scope.M_InvoiceToDeal.invoiceItemList.length; j++) {
                if ($scope.M_InvoiceToDeal.invoiceItemList[j].isSelected == true) {
                	if($scope.M_InvoiceToDeal.invoiceItemList[j].Id){
                		itemsToInvoiceList.push($scope.M_InvoiceToDeal.invoiceItemList[j].Id);
                	} else {
                		itemsToInvoiceList.push($scope.M_InvoiceToDeal.invoiceItemList[j].CoLineItemId);
                	}
                    
                }
            }
            $scope.M_CO.isLoading = true;
            var successJson = {
                'calleeMethodName': 'finalizeInvoice'
            };
            var errorMessage = $translate.instant('Invoicing_error');
            CheckoutServices.finalizeInvoice(angular.toJson(itemsToInvoiceList), $scope.M_InvoiceToDeal.COHeaderId).then(
                new success(successJson).handler, new error(errorMessage).handler);
        }
        $scope.F_InvoiceToDeal.isSelectedInvoiceListEmpty = function () {
            for (var j = 0; j < $scope.M_InvoiceToDeal.invoiceItemList.length; j++) {
                if ($scope.M_InvoiceToDeal.invoiceItemList[j].isSelected == true) {
                    return false;
                }
            }
            return true;
        }
        
        var relatedUnresolvedFulfillmentNotExist = function(itemId) {
        	for (var i = 0; i < $scope.M_CO.Deal.DealUnresolvedFulfillmentList.length; i++) {
        		if (itemId === $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].DealMerchandiseLineItemId || itemId === $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].COKitHeaderId) {
                    return false;
                }
        	}
        	return true;
        }
        
        function loadInvoiceToDealData() {
            if ($scope.M_CO.Deal.DealFulfillmentSectionObj && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList) {
                for (var i = 0; i < $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length; i++) {
                	var isItemInvoiceable = true;
                	var dealMerchObj = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i];
                	if(dealMerchObj.Id) {
                		if(relatedUnresolvedFulfillmentNotExist(dealMerchObj.Id)) {
	                		for(var j = 0; j < dealMerchObj.COLIList.length; j++) {
	                			if(dealMerchObj.COLIList[j].Status == 'Invoiced' || (dealMerchObj.COLIList[j].IsPart && dealMerchObj.COLIList[j].Status != 'In Stock' && dealMerchObj.COLIList[j].Status != 'Oversold')) {
	                				isItemInvoiceable = false;
	                				break;
	                			}
	                		}
	                		if(isItemInvoiceable) {
	                			var cokhObj = dealMerchObj;
	                			var dealCOKHObj = {'Id' : dealMerchObj.Id,'ItemCode' : cokhObj.Code, 'ItemDescription' : cokhObj.ItemDescription, 'Price' : cokhObj.Price};
	                			$scope.M_InvoiceToDeal.invoiceItemList.push(dealCOKHObj);
	                		}
                		}
                	} else if(dealMerchObj.COLIList[0] && relatedUnresolvedFulfillmentNotExist(dealMerchObj.COLIList[0].CoLineItemId)) {
	                    if (dealMerchObj.COLIList[0].IsFee || (dealMerchObj.COLIList[0].Status == 'In Stock' || dealMerchObj.COLIList[0].Status == 'Oversold')) {
	                        $scope.M_InvoiceToDeal.invoiceItemList.push(dealMerchObj.COLIList[0]);
	                    }
                	}
                }
            }
            for (var j = 0; j < $scope.M_InvoiceToDeal.invoiceItemList.length; j++) {
                $scope.M_InvoiceToDeal.invoiceItemList[j].isSelected = false;
            }
            console.log( $scope.M_CO.Deal.DealFulfillmentSectionObj);
            console.log( $scope.M_InvoiceToDeal.invoiceItemList);
            openInvoiceToDealModal();
        }

        loadInvoiceToDealData();
    }])
});