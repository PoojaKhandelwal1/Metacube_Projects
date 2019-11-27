define(['Routing_AppJs_PK', 'ViewUnitServices', 'JqueryUI', 'tel', 'CustPriceOnlyInput', 'DirPagination', 'underscore_min','FullPageModal', 'BPCarousel'],
    function (Routing_AppJs_PK, ViewUnitServices, JqueryUI, tel, CustPriceOnlyInput, DirPagination, underscore_min, FullPageModal, BPCarousel) {
        var injector = angular.injector(['ui-notification', 'ng']);
        $(document).ready(function () {
            $('.number').on('keypress', function (event) {
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
        })

        Routing_AppJs_PK.controller('ViewUnitCtrl', ['$scope', '$q', '$rootScope', '$stateParams', '$state', 'viewUnitService', '$translate', function ($scope, $q, $rootScope, $stateParams, $state, viewUnitService,$translate) {
            var Notification = injector.get("Notification");

            $scope.viewUnitModel = {};
            $scope.CustomerOrderModel = {};
            $scope.VORModel = {};
            $scope.VORModel.VOR_Header = {};
            $scope.CustomerModal = {};
            $scope.COUModal = {};
            $scope.CustomerOrderModel.OverlayInfo = {};
            $scope.CustomerOrderModel.CustomerOverlay = [];
            $scope.viewUnitModel.SelectedSection = {};
            $scope.viewUnitModel.SelectedSection.item = 'Info';
            $scope.viewUnitModel.unitDetailData = {};
            $scope.viewUnitModel.unitDetailData.UnitInfo = {};
            $scope.viewUnitModel.unitDetailData.OwnerList = {};
            $scope.viewUnitModel.PriceAndCost_editRow = [];
            $scope.viewUnitModel.ShowMore = true;
            $scope.viewUnitModel.disableApplyButton = false;
            $scope.viewUnitModel.isSearchToAddVisible = false;
            $scope.viewUnitModel.unitId = $stateParams.Id ? $stateParams.Id : null;
			
			$scope.viewUnitModel.FileUpload = {};
            $scope.viewUnitModel.FileUpload.maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
            $scope.viewUnitModel.FileUpload.maxFileSize = 750000; //After Base64 Encoding, this is the max file size
            $scope.viewUnitModel.FileUpload.attachment = '';
            $scope.viewUnitModel.FileUpload.attachmentName = '';
            $scope.viewUnitModel.FileUpload.fileSize = 0;
            $scope.viewUnitModel.FileUpload.positionIndex = 0;
            var allowedExtensions = ['jpeg','jpg','png'];
            var allowedFileTypesType = /^(?:image\/jpeg|image\/jpg|image\/png)$/i;
            //This is the code for ng-droplet
            $scope.viewUnitModel.FileUpload.interface = {};

            $scope.viewUnitModel.numberOnly = function (e) {
                var k = e.which;
                if ((k < 48 || k > 57) && (k < 96 || k > 105) && k != 8 && k != 110 && k != 190 && k != 9) {
                    e.preventDefault();
                    return false;
                }
            }

            /**
             * Method to set default values for validation model
             */
            $scope.viewUnitModel.setDefaultValidationModal = function () {
                $scope.viewUnitModel.priceValidationModal = {
                    TotalPrice: {
                        isError: false,
                        ErrorMessage: '',
                        Type: ''
                    },
                    Price: {
                        isError: false,
                        ErrorMessage: '',
                        Type: ''
                    },
                    TotalCost: {
                        isError: false,
                        ErrorMessage: '',
                        Type: ''
                    }
                };
            }

            $scope.viewUnitModel.editPriceAndCostGridItem = function (index) {
                if ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType != 'STOCK') {
                    return;
                }
                if ($scope.viewUnitModel.PriceAndCost_editRow[index].isEdit) {
                    return;
                }
                if ($scope.viewUnitModel.isPriceAndTotalPriceEditable()) {
                    for (i = 0; i < $scope.viewUnitModel.PriceAndCost_editRow.length; i++) {
                        $scope.viewUnitModel.PriceAndCost_editRow[i].isEdit = false;
                    }
                    $scope.viewUnitModel.PriceAndCost_editRow[index].isEdit = true;
                    $scope.viewUnitModel.editIndex = index;
                    setTimeout(function () {
                        if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Type == 'Dealer') {
                            angular.element('#Price_' + index).focus();
                        } else {
                            angular.element('#TotalPrice_' + index).focus();
                        }
                    }, 10);
                    angular.element(".backdropsSearchFilter").show();
                }
            }

            $scope.viewUnitModel.closeEditedPriceAndCostGridItem = function () {
                for (i = 0; i < $scope.viewUnitModel.PriceAndCost_editRow.length; i++) {
                    $scope.viewUnitModel.PriceAndCost_editRow[i].isEdit = false;
                }
                $scope.viewUnitModel.editIndex = -1;
                angular.element(".backdropsSearchFilter").hide();
            }

            $scope.viewUnitModel.isPriceAndTotalPriceEditable = function () {
                if ((($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'COU' && $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Active') ||
                        ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'ORDU' && $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'On Order') ||
                        ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'STOCK' && ($scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Sold' ||
                            $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Reserved' || $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Available')))) {
                    return true;
                }
                return false;
            }

            $scope.viewUnitModel.isFieldEditable = function (index, event, isPriceField) {
                var isNotEditable = [];
                var isNotEditableTotal = [];
                if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Type != 'Dealer') {
                    isNotEditableTotal = $scope.viewUnitModel.IsFixedTotalPrice;
                    isNotEditable = $scope.viewUnitModel.IsFixedPrice;
                } else {
                    isNotEditableTotal = $scope.viewUnitModel.IsFixedTotalPrice;
                    isNotEditable = $scope.viewUnitModel.IsFixedPrice;
                }

                if (isNotEditableTotal[index] == true && (($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'COU' && $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Active') ||
                        ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'ORDU' && $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'On Order') ||
                        ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'STOCK' && ($scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Sold' ||
                            $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Reserved' || $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Available')))) {

                    for (i = 0; i < $scope.viewUnitModel.IsFixedTotalPrice.length; i++) {
                        isNotEditableTotal[i] = true;
                        isNotEditable[i] = true;
                    }
                    if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Type != 'Dealer') {
                        isNotEditableTotal[index] = false;
                    } else {
                        isNotEditable[index] = false;
                        isNotEditableTotal[index] = false;
                    }
                } else if (isNotEditableTotal[index] == false && !event.shiftKey && event.keyCode == 9) {
                    if (isPriceField) {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price * $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    } else {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    }
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice - $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalCost;
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfiltPercentage = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount * 100) / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice;
                    viewUnitService.savePriceAndCost($scope.viewUnitModel.unitId, angular.toJson($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index])).then(function (unitPriceAndCostList) {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList = unitPriceAndCostList;
                        $scope.viewUnitModel.calculateSummaryFields();
                        Notification.success($translate.instant('Generic_Saved'));
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Generic_Error'));
                    });
                }
            }

            $scope.viewUnitModel.savePriceAndCostGridItem = function () {
                var index = -1;
                for (i = 0; i < $scope.viewUnitModel.PriceAndCost_editRow.length; i++) {
                    if ($scope.viewUnitModel.PriceAndCost_editRow[i].isEdit == true) {
                        index = i;
                        break;
                    }
                }
                if (index != -1) {
                    $scope.viewUnitModel.savePriceAndCost($scope.viewUnitModel.unitId, index);
                }
            }

            $scope.viewUnitModel.savePriceAndCost = function (unitId, index) {
                var PriceAndCostJson = angular.toJson($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index]);

                viewUnitService.savePriceAndCost(unitId, PriceAndCostJson).then(function (unitPriceAndCostList) {
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList = unitPriceAndCostList;
                    $scope.viewUnitModel.calculateSummaryFields();
                    $scope.viewUnitModel.closeEditedPriceAndCostGridItem();
                }, function (errorSearchResult) {
                    Notification.error($translate.instant('Generic_Error'));
                });
            }

            $scope.viewUnitModel.priceFieldRowTabOut = function (event, index, isPriceField) {
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') &&
                    event.type != 'keydown') {
                    return;
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    if (isPriceField) {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price * $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    } else {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    }
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice - $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalCost;
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfiltPercentage = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount * 100) / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice;
                }
            }

            $scope.viewUnitModel.priceFieldRowBlur = function (event, index, isPriceField) {
                if (isPriceField) {
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price * $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                } else {
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                }
                
                var preTaxTotalPrice;
                if($Global.isTaxIncludingPricing) {
                	preTaxTotalPrice = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice * 100) / (100 + $scope.viewUnitModel.unitDetailData.UnitInfo.ApplicableTaxRate);
                } else {
                	preTaxTotalPrice = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice;
                }
                $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount = preTaxTotalPrice - $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalCost;
                $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfiltPercentage = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount * 100) / preTaxTotalPrice;
            }

            $scope.viewUnitModel.totalPriceFieldRowTabOut = function (event, index, isPriceField) {
                if (!event.shiftKey && event.keyCode == 9) {
                    if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Type != 'Factory') {
                        setTimeout(function () {
                            angular.element('#SearchToaddCutomer').focus();
                        }, 10);
                    }
                    if (isPriceField) {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price * $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    } else {
                        $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Price = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Quantity;
                    }
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice - $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalCost;
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfiltPercentage = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount * 100) / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice;
                    if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].Type != 'Factory') {
                        $scope.viewUnitModel.closeEditedPriceAndCostGridItem();
                        $scope.viewUnitModel.savePriceAndCost($scope.viewUnitModel.unitId, index);
                    }
                }
            }

            $scope.viewUnitModel.totalCostFieldRowTabOut = function (event, index) {
                if (!event.shiftKey && event.keyCode == 9) {
                    setTimeout(function () {
                        angular.element('#SearchToaddCutomer').focus();
                    }, 10);
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount = $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice - $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalCost;
                    $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfiltPercentage = ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].ProfitAmount * 100) / $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[index].TotalPrice;
                    $scope.viewUnitModel.closeEditedPriceAndCostGridItem();
                    $scope.viewUnitModel.savePriceAndCost($scope.viewUnitModel.unitId, index);
                }
            }

            /**
             * Method to perform Delete operation for price and cost in database
             */
            $scope.viewUnitModel.removePriceAndCost = function (priceAndCostId) {
                if ($scope.viewUnitModel.disableApplyButton) {
                    return;
                }
                $scope.viewUnitModel.disableApplyButton = true;
                viewUnitService.removePriceAndCost($scope.viewUnitModel.unitId, priceAndCostId).then(function (unitDetailData) {
                    $scope.viewUnitModel.unitDetailData = unitDetailData;
                    $scope.viewUnitModel.closeEditedPriceAndCostGridItem();
                    $scope.viewUnitModel.calculateSummaryFields();
                    $scope.viewUnitModel.disableApplyButton = false;
                    Notification.success($translate.instant('Record_removed_successfully'));
                }, function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.viewUnitModel.disableApplyButton = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }

            $scope.viewUnitModel.BaseUnitTotalPrice = 0;
            $scope.viewUnitModel.BaseUnitTotalCost = 0;
            $scope.viewUnitModel.BaseUnitTotalProfit = 0;
            $scope.viewUnitModel.BaseUnitProfitPercentage = 0;
            $scope.viewUnitModel.FactoryUnitTotalPrice = 0;
            $scope.viewUnitModel.FactoryUnitTotalCost = 0;
            $scope.viewUnitModel.FactoryUnitTotalProfit = 0;
            $scope.viewUnitModel.FactoryUnitProfitPercentage = 0;
            $scope.viewUnitModel.DealerUnitTotalPrice = 0;
            $scope.viewUnitModel.DealerUnitTotalCost = 0;
            $scope.viewUnitModel.DealerUnitTotalProfit = 0;
            $scope.viewUnitModel.DealerUnitProfitPercentage = 0;
            $scope.COUModal = {};

            /**
             * Load suggestion and items of a unit
             */
            $scope.viewUnitModel.loadUnit = function () {
				$scope.viewUnitModel.isLoading = true;
                var unitId = $scope.viewUnitModel.unitId;
                $scope.viewUnitModel.populateLeftSideHeadingLables();
                viewUnitService.getUnitDetail(unitId).then(function (unitDetailData) {
                    $scope.viewUnitModel.unitDetailData = unitDetailData;
                    $scope.viewUnitModel.populateLeftSideHeadingLables();
                    $scope.viewUnitModel.isrefresh = false;
                    $scope.COUModal.ApplicableTaxList = $scope.viewUnitModel.unitDetailData.SalesTaxList;
                    $scope.viewUnitModel.IsFixedTotalPrice = [$scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList.length];
                    $scope.viewUnitModel.IsFixedPrice = [$scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList.length];
                    $scope.viewUnitModel.calculateSummaryFields();
                    $scope.viewUnitModel.setDefaultValidationModal();
					$scope.viewUnitModel.getImageList();
                }, function (errorSearchResult) {
                    $scope.viewUnitModel.isrefresh = false;
                });
                setTimeout(function () {
                    $scope.viewUnitModel.calculateSidebarHeight();
                }, 10);
            }

            $scope.viewUnitModel.calculateSummaryFields = function () {
                $scope.viewUnitModel.BaseUnitTotalPrice = 0;
                $scope.viewUnitModel.BaseUnitTotalCost = 0;
                $scope.viewUnitModel.BaseUnitTotalProfit = 0;
                $scope.viewUnitModel.FactoryUnitTotalPrice = 0;
                $scope.viewUnitModel.FactoryUnitTotalCost = 0;
                $scope.viewUnitModel.FactoryUnitTotalProfit = 0;
                $scope.viewUnitModel.DealerUnitTotalPrice = 0;
                $scope.viewUnitModel.DealerUnitTotalCost = 0;
                $scope.viewUnitModel.DealerUnitTotalProfit = 0;

                for (var i = 0; i < $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList.length; i++) {
                    $scope.viewUnitModel.IsFixedTotalPrice[i] = true;
                    $scope.viewUnitModel.IsFixedPrice[i] = true;

                    if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].Type == 'Base') {
                        $scope.viewUnitModel.BaseUnitTotalPrice += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalPrice;
                        $scope.viewUnitModel.BaseUnitTotalCost += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalCost;
                        $scope.viewUnitModel.BaseUnitTotalProfit += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].ProfitAmount;
                    } else if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].Type == 'Factory') {
                        $scope.viewUnitModel.FactoryUnitTotalPrice += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalPrice;
                        $scope.viewUnitModel.FactoryUnitTotalCost += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalCost;
                        $scope.viewUnitModel.FactoryUnitTotalProfit += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].ProfitAmount;
                    } else if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].Type == 'Dealer') {
                        $scope.viewUnitModel.DealerUnitTotalPrice += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalPrice;
                        $scope.viewUnitModel.DealerUnitTotalCost += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].TotalCost;
                        $scope.viewUnitModel.DealerUnitTotalProfit += $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList[i].ProfitAmount;
                    }
                    
                    var preTaxBaseUnitTotalPrice;
                    var preTaxFactoryUnitTotalPrice;
                    var preTaxDealerUnitTotalPrice;
                    if($Global.isTaxIncludingPricing) {
                    	preTaxBaseUnitTotalPrice = ($scope.viewUnitModel.BaseUnitTotalPrice * 100) / (100 + $scope.viewUnitModel.unitDetailData.UnitInfo.ApplicableTaxRate);
                    	preTaxFactoryUnitTotalPrice = ($scope.viewUnitModel.FactoryUnitTotalPrice * 100) / (100 + $scope.viewUnitModel.unitDetailData.UnitInfo.ApplicableTaxRate);
                    	preTaxDealerUnitTotalPrice = ($scope.viewUnitModel.DealerUnitTotalPrice * 100) / (100 + $scope.viewUnitModel.unitDetailData.UnitInfo.ApplicableTaxRate);
                    } else {
                    	preTaxBaseUnitTotalPrice = $scope.viewUnitModel.BaseUnitTotalPrice;
                    	preTaxFactoryUnitTotalPrice = $scope.viewUnitModel.FactoryUnitTotalPrice;
                    	preTaxDealerUnitTotalPrice = $scope.viewUnitModel.DealerUnitTotalPrice;
                    }
                    $scope.viewUnitModel.BaseUnitProfitPercentage = ((preTaxBaseUnitTotalPrice - $scope.viewUnitModel.BaseUnitTotalCost) / preTaxBaseUnitTotalPrice) * 100;
                    $scope.viewUnitModel.FactoryUnitProfitPercentage = ((preTaxFactoryUnitTotalPrice - $scope.viewUnitModel.FactoryUnitTotalCost) / preTaxFactoryUnitTotalPrice) * 100;
                    $scope.viewUnitModel.DealerUnitProfitPercentage = ((preTaxDealerUnitTotalPrice - $scope.viewUnitModel.DealerUnitTotalCost) / preTaxDealerUnitTotalPrice) * 100;
                }

                var DealItems = [];
                if ($scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList != undefined) {
                    for (i = 0; i < $scope.viewUnitModel.unitDetailData.PriceAndCostTrackingWrapperList.length; i++) {
                        DealItems.push({
                            isEdit: false,
                            radioValue: 0
                        });
                    }
                }
                $scope.viewUnitModel.PriceAndCost_editRow = DealItems;
            }

            /**
             * Populate Left Side panel Items
             */
            $scope.viewUnitModel.populateLeftSideHeadingLables = function () {
                $scope.viewUnitModel.LeftSideHeadingLables = {};
                var currentHeadingSequenceIndex = 65;

                $scope.viewUnitModel.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
                if ($scope.viewUnitModel.unitDetailData.UnitInfo != undefined && $scope.viewUnitModel.unitDetailData.UnitInfo.UnitType != 'COU') {
                    $scope.viewUnitModel.LeftSideHeadingLables['PriceAndCostTracking'] = String.fromCharCode(currentHeadingSequenceIndex++);
                }
                if ($scope.viewUnitModel.unitDetailData.VendorInfo != undefined && $scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'STOCK') {
                    $scope.viewUnitModel.LeftSideHeadingLables['Ordering'] = String.fromCharCode(currentHeadingSequenceIndex++);
                }

                if ($scope.viewUnitModel.unitDetailData.OwnerList.length > 1) {
                    $scope.viewUnitModel.LeftSideHeadingLables['Owners'] = String.fromCharCode(currentHeadingSequenceIndex++);
                }
            }

            $scope.FilterID = "";
            $scope.SearchToadd = {};
            $scope.typeToSearch = "";
            $scope.PreferredObject = "Vendor";

            $scope.viewUnitModel.showMoreDetails = function (status) {
                $scope.viewUnitModel.ShowMore = status;
            }

            $scope.viewUnitModel.resetHideResults = function () {
                $scope.viewUnitModel.searchDivActive = true;
            };

            $scope.viewUnitModel.hideResults = function () {
                $scope.viewUnitModel.searchDivActive = false;
            };

            $scope.viewUnitModel.select = function () {
                $scope.viewUnitModel.searchDivActive = true;
            };

            $scope.viewUnitModel.displaySections = {
                'Info': true,
                'PriceAndCostTracking': true,
                'History': true,
                'Owners': true,
                'Ordering': true
            };

            $scope.viewUnitModel.activeSidepanelink = '#InfoSection';
            $scope.viewUnitModel.selectedItem = 'Info';

            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function () {
                $scope.viewUnitModel.onScroll();
            });

            $scope.viewUnitModel.sidepanelLink = function (event, relatedContent) {
                event.preventDefault();
                $scope.viewUnitModel.displaySections[relatedContent] = true;
                angular.element(document).off("scroll");
                var target = angular.element(event.target.closest('a')).attr("href");
                var navBarHeightDiffrenceFixedHeaderOpen = 0;

                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 35;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen //110 //120
                }, 500, function () {
                    angular.element(document).on("scroll", function () {
                        $scope.viewUnitModel.onScroll();
                    });
                    $scope.viewUnitModel.onScroll();
                });
            }

            $scope.viewUnitModel.onScroll = function () {
                if ($state.current.name === 'ViewUnit') {
                    var activeSidepanelink;
                    var selectedItem;
                    var heading = '';
                    var scrollPos = angular.element(document).scrollTop();
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;

                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 40;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 50;
                    }

                    if (isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + 95 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#InfoSection';
                        selectedItem = 'Info';
                    } else if (isElementDefined('#PriceAndCostTrackingSection') && (scrollPos < angular.element('#PriceAndCostTrackingSection').position().top + angular.element('#PriceAndCostTrackingSection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        if ($scope.viewUnitModel.unitDetailData.UnitInfo != undefined && $scope.viewUnitModel.unitDetailData.UnitInfo.UnitType != 'COU') {
                            activeSidepanelink = '#PriceAndCostTrackingSection';
                            selectedItem = 'Price & Cost Tracking';
                        } else {
                            if ($scope.viewUnitModel.unitDetailData.ServiceOrdersList != undefined && $scope.viewUnitModel.unitDetailData.ServiceOrdersList.length > 0) {
                                activeSidepanelink = '#HistorySection';
                                selectedItem = 'History';
                            } else if ($scope.viewUnitModel.unitDetailData.OwnerList != undefined && $scope.viewUnitModel.unitDetailData.OwnerList.length > 1 && $scope.viewUnitModel.unitDetailData.OwnerList.length != undefined) {
                                activeSidepanelink = '#OwnersSection';
                                selectedItem = 'Owners';
                            } else {
                                activeSidepanelink = '#InfoSection';
                                selectedItem = 'Info';
                            }
                        }
                    } else if (scrollPos < angular.element('#OrderingSection').position().top + angular.element('#OrderingSection').height() + 70) {
                        if ($scope.viewUnitModel.unitDetailData.UnitInfo != undefined && $scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'STOCK') {
                            activeSidepanelink = '#OrderingSection';
                            selectedItem = 'Ordering';
                        } else if ($scope.viewUnitModel.unitDetailData.UnitInfo != undefined && $scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'ORDU') {
                            activeSidepanelink = '#OwnersSection';
                            selectedItem = 'Owners';
                        } else {
                            activeSidepanelink = '#HistorySection';
                            selectedItem = 'History';
                        }
                    } else if ($scope.viewUnitModel.unitDetailData.ServiceOrdersList != undefined 
                    		&& $scope.viewUnitModel.unitDetailData.ServiceOrdersList.length > 0 
                    		&& (isElementDefined('#HistorySection') 
                    				&& (scrollPos < angular.element('#HistorySection').position().top + angular.element('#HistorySection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen))) { 
                        activeSidepanelink = '#HistorySection';
                        selectedItem = 'History';
                    } else if (isElementDefined('#OwnersSection') && (scrollPos < angular.element('#OwnersSection').position().top + angular.element('#OwnersSection').height() + 65 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        if ($scope.viewUnitModel.unitDetailData.OwnerList != undefined && $scope.viewUnitModel.unitDetailData.OwnerList.length > 1 && $scope.viewUnitModel.unitDetailData.OwnerList.length != undefined) {
                            activeSidepanelink = '#OwnersSection';
                            selectedItem = 'Owners';
                        } else if ($scope.viewUnitModel.unitDetailData.ServiceOrdersList != undefined && $scope.viewUnitModel.unitDetailData.ServiceOrdersList.length > 0) {
                            activeSidepanelink = '#HistorySection';
                            selectedItem = 'History';
                        } else {
                            activeSidepanelink = '#InfoSection';
                            selectedItem = 'Info';
                        }
                    } else {
                        activeSidepanelink = '#InfoSection';
                        selectedItem = 'Info';
                    }
                    $scope.viewUnitModel.activeSidepanelink = activeSidepanelink;
                    $scope.viewUnitModel.selectedItem = selectedItem;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }

            $scope.viewUnitModel.refreshUnit = function () {
                $scope.viewUnitModel.isrefresh = true;
                $scope.viewUnitModel.loadUnit();
            }

            $scope.viewUnitModel.isEditButtonEnabled = function () {
                if (($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'COU' && ($scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Active' 
                		|| $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'Inactive')) ||
                    ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'ORDU' && $scope.viewUnitModel.unitDetailData.UnitInfo.Status == 'On Order') ||
                    ($scope.viewUnitModel.unitDetailData.UnitInfo.UnitType == 'STOCK' && ($scope.viewUnitModel.unitDetailData.UnitInfo.Status != 'Traded' &&
                        $scope.viewUnitModel.unitDetailData.UnitInfo.Status != 'Delivered'))) {
                    return true;
                }
            }

            $scope.viewUnitModel.editUnit = function () {
                var unitRelated_Json = {
                    couId: $scope.viewUnitModel.unitId,
                    customerId: $scope.viewUnitModel.unitDetailData.UnitInfo.Customer,
                    unitType: 'STOCK'
                };
                loadState($state, 'ViewUnit.AddEditUnit', {
                    AddEditUnitParams: unitRelated_Json
                });
            }

            $scope.viewUnitModel.dropDownItem = function (event, selectedSection) {
                var activeSection = $scope.viewUnitModel.activeSidepanelink.replace('#', '');
                $scope.viewUnitModel.selectedItem = selectedSection;
                if (activeSection != selectedSection) {
                    $scope.viewUnitModel.sidepanelLink(event, selectedSection);
                }
            }

            $scope.viewUnitModel.showCustomerInfoOverlay = function (event, custId) {
                $scope.CustomerOrderModel.OverlayInfo = {};
                $scope.CustomerOrderModel.CustomerOverlay = [];
                $scope.CustomerOrderModel.Customer = {};
                $scope.CustomerOrderModel.Customer.Value = custId;
                $scope.viewUnitModel.showCustInfoOverlay(event, custId);

                viewUnitService.openCustomerPopup(custId)
                    .then(function (successfulSearchResult) {
                            if (successfulSearchResult.length > 0) {
                                $scope.CustomerOrderModel.OverlayInfo = successfulSearchResult[0];
                                if ($scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone == "") {
                                    if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeNumber != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_HomeNumber;
                                    } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkNumber != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_WorkNumber;
                                    } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_Mobile != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_Mobile;
                                    }
                                }
                                if ($scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail == "") {
                                    if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail;
                                    } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail;
                                    } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail != "") {
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail;
                                    }
                                }

                                $scope.CustomerOrderModel.CustomerOverlay = [{
                                    label: 'Name',
                                    value: $scope.CustomerOrderModel.OverlayInfo.Cust_Name
                                }, {
                                    label: 'PHONE PRIMARY',
                                    value: $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone
                                }, {
                                    label: 'PHONE ALT',
                                    value: $scope.CustomerOrderModel.OverlayInfo.Cust_Mobile
                                }, {
                                    label: 'EMAIL',
                                    value: $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail
                                }, {
                                    label: 'ADDRESS',
                                    value: $scope.CustomerOrderModel.OverlayInfo.Cust_BillingStreet + ' ' +
                                        $scope.CustomerOrderModel.OverlayInfo.Cust_BillingCity
                                }];
                            }
                        },
                        function (errorSearchResult) {
                            responseData = errorSearchResult;
                        });
            }

            $scope.viewUnitModel.showCustInfoOverlay = function (event, custId) {
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element('.Customer-info-overlay').css('top', targetEle.offset().top - 45);
                angular.element('.Customer-info-overlay').css('left', event.clientX);
                angular.element('.Customer-info-overlay').show();
            }

            $scope.viewUnitModel.hideCustomerInfoOverlay = function () {
                angular.element('.Customer-info-overlay').hide();
            }
            
            $scope.loadData = function () {
                $scope.viewUnitModel.loadUnit();
            }

            $scope.loadDataFromCOU = function () {
                $scope.viewUnitModel.loadUnit();
            }

            $scope.viewUnitModel.selectalltext = function () {
                angular.element('#unitNotes').select();
            }

            $scope.viewUnitModel.UpdateUnitNotes = function () {
                if (unitNotes != null && unitNotes != '') {
                    $scope.viewUnitModel.saveUnitNotesToServer($scope.viewUnitModel.unitId, $scope.viewUnitModel.unitDetailData.UnitInfo.Notes);
                } else {
                    Notification.error($translate.instant('ViewUnit_Enter_notes'));
                    setTimeout(function () {
                        angular.element('#unitNotes').focus();
                        angular.element('#unitNotes').css("border", "1px solid #d9534f");
                    }, 100);
                }
            }

            $scope.viewUnitModel.saveUnitNotesToServer = function (unitId, unitNotes) {
                viewUnitService.saveUnitNotes(unitId, unitNotes)
                    .then(function (successfulSearchResult) {
                            Notification.success($translate.instant('Generic_Saved'));
                        },
                        function (errorSearchResult) {
                            responseData = errorSearchResult;
                        });
            }
            /*for preferred email*/ 
            $scope.viewUnitModel.setPrefferedEmail = function () {

                if (angular.isDefined($scope.viewUnitModel.unitDetailData.UnitInfo)) {
                    if ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail != null && $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail != "") {
                        return $scope.viewUnitModel.unitDetailData.UnitInfo[$scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail];
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Individual" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail == "" || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail == null)) {
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.HomeEmail != null && $scope.viewUnitModel.unitDetailData.UnitInfo.HomeEmail !== "") ? $scope.viewUnitModel.unitDetailData.UnitInfo.HomeEmail : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherEmail != null) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherEmail : ""
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Business" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail == "" || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredEmail != null)) {
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.WorkEmail != null && $scope.viewUnitModel.unitDetailData.UnitInfo.WorkEmail !== "") ? $scope.viewUnitModel.unitDetailData.UnitInfo.WorkEmail : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherEmail != null) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherEmail : ""
                    }
                }
            }

            /*for phone*/
            $scope.viewUnitModel.setPrefferedPhone = function () {
                if (angular.isDefined($scope.viewUnitModel.unitDetailData.UnitInfo)) {
                    if ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone != null && $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone != "") {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhoneLabel = $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone;
                        return $scope.viewUnitModel.unitDetailData.UnitInfo[$scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone];
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Individual" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone == null || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone == "")) {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhoneLabel = ($scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber != null && $scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber != "") ? 'HomeNumber' : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone != null) ? 'OtherPhone' : "HomeNumber";
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber != null && $scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber != "") ? $scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone != null) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone : ""
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Business" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone == null || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhone == "")) {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredPhoneLabel = ($scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber != null && $scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber != "") ? 'WorkNumber' : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone != null) ? 'OtherPhone' : "WorkNumber";
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber != null && $scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber != "") ? $scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber : ($scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone != null) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone : ""
                    }
                } else {
                    return '';
                }
            }

            /*for sms*/
            $scope.viewUnitModel.setPrefferedSMS = function () {
                if (angular.isDefined($scope.viewUnitModel.unitDetailData.UnitInfo)) {

                    if ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS != null && $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS != "") {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMSLabel = $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS;
                        return $scope.viewUnitModel.unitDetailData.UnitInfo[$scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS];
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Individual" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS == null || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS == "")) {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMSLabel = ($scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumberSMS != false) ? 'HomeNumberSMS' : ($scope.viewUnitModel.unitDetailData.UnitInfo.MobileNumberSMS != false) ? "MobileNumberSMS" : "HomeNumberSMS";
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumberSMS != false) ? $scope.viewUnitModel.unitDetailData.UnitInfo.HomeNumber : ($scope.viewUnitModel.unitDetailData.UnitInfo.MobileNumberSMS != false) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone : ""
                    } else if ($scope.viewUnitModel.unitDetailData.UnitInfo.Type == "Business" && ($scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS == null || $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMS == "")) {
                        $scope.viewUnitModel.unitDetailData.UnitInfo.PreferredSMSLabel = ($scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumberSMS != false) ? 'WorkNumberSMS' : ($scope.viewUnitModel.unitDetailData.UnitInfo.MobileNumberSMS != false) ? "MobileNumberSMS" : "WorkNumberSMS";
                        return ($scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumberSMS != false) ? $scope.viewUnitModel.unitDetailData.UnitInfo.WorkNumber : ($scope.viewUnitModel.unitDetailData.UnitInfo.MobileNumberSMS != false) ? $scope.viewUnitModel.unitDetailData.UnitInfo.OtherPhone : ""
                    }
                }
            }

            /**
             * start : side panel height adjustment according to screen size
             */
            $scope.viewUnitModel.calculateSidebarHeight = function () {
                windowheight = screen.height;
                var leftPanelLinks = windowheight - (angular.element(".headerNav").height() + angular.element(".unitCustomerSection").height() +
                    angular.element(".sidepaneluserinfo").height());
                angular.element(".leftPanelLinks").css("height", leftPanelLinks);
            }

            /**
             * START: for adding unit price and cost line item
             */ 
            $scope.viewUnitModel.addUnitPriceAndCostItem = function () {
                loadState($state, 'ViewUnit.AddUnitPriceAndCost', {
                    priceAndCostParams: {
                        Id: $scope.viewUnitModel.unitId
                    }
                });
            }
            
            /* Start: Upload */
            $scope.$on('$dropletReady', function whenDropletReady() {
                try {
                    var el = angular.element("droplet input[type=file]");
                    el.attr('accept', 'image/*');
                } catch (ex) {}
            });
            $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
                $scope.viewUnitModel.FileUpload.fileToBeUploaded = singlefile.file;
                var fileExtension = getExtension($scope.viewUnitModel.FileUpload.fileToBeUploaded);
                var fileType = $scope.viewUnitModel.FileUpload.fileToBeUploaded.type;
                if(allowedExtensions.indexOf(fileExtension) != -1 && allowedFileTypesType.test(fileType)) {
                	$scope.viewUnitModel.isLoading = true;
                	$scope.viewUnitModel.uploadAttachmentFile();
                } else {
                	Notification.error($translate.instant('You_must_select_a_JPEG_image_to_upload'));
                }
            });
            $scope.viewUnitModel.uploadAttachmentFile = function() {
                $scope.viewUnitModel.FileUpload.uploadFile($scope.viewUnitModel.FileUpload.fileToBeUploaded);
            }
            $scope.viewUnitModel.FileUpload.uploadFile = function(file) {
                if (file != undefined) {
                    if (file.size <= $scope.viewUnitModel.FileUpload.maxFileSize) {
                        $scope.viewUnitModel.FileUpload.attachmentName = file.name;
                        var fileReader = new FileReader();
                        fileReader.onload = function (e) {};
                        fileReader.onloadend = function(e) {
                            $scope.viewUnitModel.FileUpload.attachment = window.btoa(this.result); //Base 64 encode the file before sending it
                            $scope.viewUnitModel.FileUpload.positionIndex = 0;
                            $scope.viewUnitModel.FileUpload.fileSize = $scope.viewUnitModel.FileUpload.attachment.length;
                            $scope.viewUnitModel.FileUpload.doneUploading = false;
                            if ($scope.viewUnitModel.FileUpload.fileSize < $scope.viewUnitModel.FileUpload.maxStringSize) {
                                $scope.viewUnitModel.FileUpload.tempattachmentbody = $scope.viewUnitModel.FileUpload.attachment;
                                $scope.viewUnitModel.FileUpload.uploadAttachment();
                            } else {
                            	$scope.viewUnitModel.isLoading = false;
                            }
                        }
                        fileReader.onerror = function(e) {
                        	$scope.viewUnitModel.isLoading = false;
                        }
                        fileReader.onabort = function(e) {
                            $scope.viewUnitModel.FileUpload.uploadAttachment();
                        }
                        fileReader.readAsBinaryString(file); //Read the body of the file
                    } else {
                    	$scope.viewUnitModel.isLoading = false;
                    	Notification.error($translate.instant('File_size_should_be_less_than_750_kB'));
                    }
                } else {
                    $scope.viewUnitModel.FileUpload.uploadAttachment();
                }
            }
            
            var closeAttachmentPopup = function() {
            	angular.element('#UploadAttachmentPopup').modal('hide');
                angular.element("body").removeClass("modal-open");
                angular.element("body").css("padding", "0px");
            }
            
            $scope.viewUnitModel.FileUpload.uploadAttachment = function() {
                viewUnitService.uploadImage($scope.viewUnitModel.FileUpload.attachmentName, $scope.viewUnitModel.FileUpload.tempattachmentbody, $scope.viewUnitModel.unitId).then(function(successfulResult) {
                	if(successfulResult.responseStatus && successfulResult.responseStatus == 'error') {
                		Notification.error(successfulResult.response);
                	} else {
                        $scope.viewUnitModel.unitDetailData.ImageList = successfulResult;
                        setPrimaryImageData();
                        closeAttachmentPopup();
                	}
                	$scope.viewUnitModel.isLoading = false;
                	$scope.viewUnitModel.FileUpload.fileToBeUploaded = '';
                }, function(errorSearchResult) {
                	$scope.viewUnitModel.isLoading = false;
                    responseData = errorSearchResult;
                })
            }
            
            var setPrimaryImageData = function() {
            	var index = _.findIndex($scope.viewUnitModel.unitDetailData.ImageList, {
                    'IsPrimary': true
                });
                if(index > -1) {
                	$scope.viewUnitModel.unitDetailData.primaryImage = $scope.viewUnitModel.unitDetailData.ImageList[index];
                	$scope.viewUnitModel.unitDetailData.NonPrimaryImageList = angular.copy($scope.viewUnitModel.unitDetailData.ImageList);
                	$scope.viewUnitModel.unitDetailData.NonPrimaryImageList.splice(index, 1);
                } else {
                	$scope.viewUnitModel.unitDetailData.primaryImage = $scope.viewUnitModel.unitDetailData.ImageList[0];
                	$scope.viewUnitModel.unitDetailData.NonPrimaryImageList = angular.copy($scope.viewUnitModel.unitDetailData.ImageList);
                	$scope.viewUnitModel.unitDetailData.NonPrimaryImageList.splice(0, 1);
                }
            }
            
            $scope.viewUnitModel.getImageList = function () {
            	viewUnitService.getImageList($scope.viewUnitModel.unitId).then(function(result) {
                    $scope.viewUnitModel.unitDetailData.ImageList = result;
                    setPrimaryImageData();
                    $scope.viewUnitModel.isLoading = false;
                    $scope.viewUnitModel.isrefresh = false;
                }, function (errorSearchResult) {
                	$scope.viewUnitModel.isLoading = false;
                    $scope.viewUnitModel.isrefresh = false;
                });
            }
            
            $scope.viewUnitModel.FileUpload.pinImage = function(event, index, docId) {
            	if(index == -1 || (index!= -1 && $scope.viewUnitModel.unitDetailData.NonPrimaryImageList[index].IsPrimary)) {
            		return;
            	} else {
            		$scope.viewUnitModel.isLoading = true;
            	}
            	for(var i=0;i<$scope.viewUnitModel.unitDetailData.NonPrimaryImageList.length;i++) {
            		if($scope.viewUnitModel.unitDetailData.NonPrimaryImageList[i].IsPrimary) {
            			$scope.viewUnitModel.unitDetailData.NonPrimaryImageList[i].IsPrimary = false;
            		}
            	}
            	
            	for(var i=0;i<$scope.viewUnitModel.unitDetailData.ImageList.length;i++) {
            		if($scope.viewUnitModel.unitDetailData.ImageList[i].IsPrimary) {
            			$scope.viewUnitModel.unitDetailData.ImageList[i].IsPrimary = false;
            		}
            	}
            	
            	viewUnitService.pinImage(docId, true, $scope.viewUnitModel.unitId).then(function(result) {
            		$scope.viewUnitModel.isLoading = false;
            		if(result == 'Success') {
            			$scope.viewUnitModel.unitDetailData.NonPrimaryImageList[index].IsPrimary = true;
            			var i = _.findIndex($scope.viewUnitModel.unitDetailData.ImageList, {
                            'DocId': docId
                        });
                    	if(i > -1) {
                    		$scope.viewUnitModel.unitDetailData.ImageList[i].IsPrimary = true;
                    	}
            			setPrimaryImageData();
            		}
                    $scope.viewUnitModel.isrefresh = false;
                }, function (errorSearchResult) {
                	$scope.viewUnitModel.isLoading = false;
                    $scope.viewUnitModel.isrefresh = false;
                });
            	event.stopPropagation();
            }
            
            $scope.viewUnitModel.FileUpload.deleteImage = function(event, docId) {
            	$scope.viewUnitModel.isLoading = true;
            	viewUnitService.deleteImage(docId, $scope.viewUnitModel.unitId).then(function(result) {
                    $scope.viewUnitModel.unitDetailData.ImageList = result;
                    setPrimaryImageData();
                    $scope.viewUnitModel.isLoading = false;
                    $scope.viewUnitModel.isrefresh = false;
                }, function (errorSearchResult) {
                	$scope.viewUnitModel.isLoading = false;
                    $scope.viewUnitModel.isrefresh = false;
                });
            	event.stopPropagation();
            }
            
            $scope.viewUnitModel.openImageCarousel = function(imageURL, docId) {
            	$scope.viewUnitModel.currentViewingImgURL = imageURL;
            	$scope.viewUnitModel.currentViewingImgDocId = docId;
            }
            
            $scope.viewUnitModel.closeCarouselModal = function() {
            	angular.element('#carousel-modal').modal('hide');
            	angular.element("body").removeClass(' modal-open ').css('padding', '0px');
            }
            
            $scope.viewUnitModel.showImage = function(operator) {
            	var currentViewingImgIndex = _.findIndex($scope.viewUnitModel.unitDetailData.ImageList, {
                    'DocId': $scope.viewUnitModel.currentViewingImgDocId
                });
            	if(currentViewingImgIndex != -1) {
            		if(operator== 'Prev') {
            			currentViewingImgIndex--;
            			if(currentViewingImgIndex < 0) {
            				currentViewingImgIndex = $scope.viewUnitModel.unitDetailData.ImageList.length - 1;
            			}
            		} else if(operator == 'Next') {
            			currentViewingImgIndex++;
            			if(currentViewingImgIndex > $scope.viewUnitModel.unitDetailData.ImageList.length - 1) {
            				currentViewingImgIndex = 0;
            			}
            		}
            		$scope.viewUnitModel.currentViewingImgURL = $scope.viewUnitModel.unitDetailData.ImageList[currentViewingImgIndex].AttchmentURL;
                	$scope.viewUnitModel.currentViewingImgDocId = $scope.viewUnitModel.unitDetailData.ImageList[currentViewingImgIndex].DocId;
            	}
            }
            /* End: Upload */

            $scope.viewUnitModel.loadUnit();
        }])
    });