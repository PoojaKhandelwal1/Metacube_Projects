define(['Routing_AppJs_PK', 'PartAdjustmentInStockServices'], function (Routing_AppJs_PK, PartAdjustmentInStockServices) {

    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('PartAdjustmentInStockCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'addPartAdjustService','$translate', function ($scope, $timeout, $q, $rootScope, $state, $stateParams, addPartAdjustService,$translate) {
        var Notification = injector1.get("Notification");
        if ($scope.partAdjustModal == undefined) {
            $scope.partAdjustModal = {};
        }
        $scope.partAdjustModal.invalid = false;
        $scope.partAdjustModal.partModal = {};
        $scope.partAdjustModal.isFormSubmitted = false;
        $scope.partAdjustModal.adjustPart = {};
        $scope.partAdjustModal.adjustPart.showAdjustPreview = true;
        $scope.partAdjustModal.adjustPart.isPreviewActive = true;
        $scope.partAdjustModal.adjustPart.SelectedInStock = 'select'
        $scope.partAdjustModal.DateFormat = $Global.DateFormat;
        $scope.$on('AdjustStockEvent', function (event, partId, args, partDetailRecord) {
            $scope.partAdjustModal.adjustBucketList = args;
            for (var i = 0; i < $scope.partAdjustModal.adjustBucketList.length; i++) {
                $scope.partAdjustModal.adjustBucketList[i].isEdit = false;
            }
            $scope.partId = partId;
            $scope.partDetail = partDetailRecord;
            $scope.partAdjustModal.adjustPart.cost = $scope.partDetail.Cost;
            $scope.partAdjustModal.openPartAdjustPopup(partId);
        });
        $scope.partAdjustModal.showApplyBtn = function () {
            $scope.partAdjustModal.showPreview = false;
        }
        $scope.partAdjustModal.openPartAdjustPopup = function (partId) {
            $scope.partAdjustModal.openPopup();
            setTimeout(function () {
                angular.element('#feeCodeInput').focus();
            }, 1000);
        }
        $scope.partAdjustModal.openPopup = function () {
            angular.element('.controls').hide();
            setTimeout(function () {
                angular.element('#addNewPartAdjust').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.partAdjustModal.adjustclosePopup = function () {
            $scope.partAdjustModal.adjustPart.showAdjustPreview = true;
            $scope.partAdjustModal.adjustPart.SelectedInStock = 'select'
            $scope.partAdjustModal.adjustPart.isPreviewActive = true;
            $scope.partAdjustModal.adjustPart.QtyIn = undefined;
            $scope.partAdjustModal.adjustPart.cost = undefined;
            angular.element('#addNewPartAdjust').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });

        }
        $scope.partAdjustModal.showPreview = function (partId, qty, cost, FifoPartJSON) {
            $scope.partAdjustModal.adjustPart.showAdjustPreview = false;
            $scope.partAdjustModal.validateDecreaseQuantity();
            if (!$scope.partAdjustModal.invalid) {
                var monthNames = [
                    "Jan", "Feb", "Mar",
                    "Apr", "May", "Jun", "Jul",
                    "Aug", "Sep", "Oct",
                    "Nov", "Dec"
                ];
                var date = new Date();
                var day = date.getDate();
                day = day <= 9 ? '0' + day : day;
                var monthIndex = date.getMonth();
                var year = date.getFullYear();
                var previewList = angular.copy($scope.partAdjustModal.adjustBucketList);
                if ($scope.partAdjustModal.adjustPart.SelectedInStock == 'Increase') {
                    var gropuItem = {};
                    gropuItem.SourceName = "Stock Count";
                    var dateFormatArray = $scope.partAdjustModal.DateFormat.split("/");
                    if (dateFormatArray[0].indexOf('mm') != -1) {
                        gropuItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
                    } else if (dateFormatArray[1].indexOf('mm') != -1) {
                        gropuItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
                    }
                    gropuItem.UniqueId = "TBD";
                    gropuItem.Reference = 'Count Adjustment';
                    gropuItem.QtyIn = qty;
                    gropuItem.QtyOut = 0;
                    gropuItem.RemainingQty = qty;
                    gropuItem.Cost = cost;
                    gropuItem.Total = qty * cost;
                    gropuItem.isCostAdjustment = true;
                    previewList.push(gropuItem);
                }
                if ($scope.partAdjustModal.adjustPart.SelectedInStock == 'Decrease') {
                    for (var i = 0; i < previewList.length; i++) {
                        if (qty > 0) {
                            var deductQty = (qty < previewList[i].RemainingQty) ? qty : previewList[i].RemainingQty;
                            previewList[i].QtyOut += (+deductQty);
                            previewList[i].RemainingQty = previewList[i].QtyIn - previewList[i].QtyOut;
                            previewList[i].Total = previewList[i].RemainingQty * previewList[i].Cost;
                            qty -= deductQty;
                            var LineItem = {}
                            var dateFormatArray = $scope.partAdjustModal.DateFormat.split("/");
                            if (dateFormatArray[0].indexOf('mm') != -1) {
                                LineItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ' ' + year;
                            } else if (dateFormatArray[1].indexOf('mm') != -1) {
                                LineItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
                            }
                            LineItem.UniqueId = 'TBD';
                            LineItem.Reference = 'Count Adjustment';
                            LineItem.QtyOut = deductQty;
                            LineItem.isCostAdjustment = true;
                            previewList[i].PartFIFOActivityLineItemList.push(LineItem);
                        }
                    }
                }
                $scope.partAdjustModal.adjustBucketListPreview = previewList;
            }
        }
        $scope.partAdjustModal.applyAction = function () {
            if ($scope.partAdjustModal.adjustPart.SelectedInStock == 'Increase') {
                $scope.partAdjustModal.increaseApplyAction();
            }
            if ($scope.partAdjustModal.adjustPart.SelectedInStock == 'Decrease') {
                $scope.partAdjustModal.decreaseApplyAction();
            }
        }
        $scope.partAdjustModal.validateDecreaseQuantity = function () {
            $scope.partAdjustModal.invalid = false;
            var RemainingQty = 0;
            var Instock = $scope.partAdjustModal.adjustPart.QtyIn;
            if ($scope.partAdjustModal.adjustPart.SelectedInStock == 'Decrease') {
                if ($scope.partAdjustModal.adjustPart.QtyIn < 0) {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = true;
                    $scope.partAdjustModal.invalid = true;
                    $scope.partAdjustModal.adjustPart.showAdjustPreview = true;
                    Notification.error($translate.instant('PartAdjustmentInStock_Cannot_decrease_quantity'));
                }
                for (var i = 0; i < $scope.partAdjustModal.adjustBucketList.length; i++) {
                    var bucket = $scope.partAdjustModal.adjustBucketList[i];
                    RemainingQty += bucket.RemainingQty != null ? bucket.RemainingQty : 0;
                }
                if ($scope.partAdjustModal.adjustPart.QtyIn > RemainingQty) {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = true;
                    $scope.partAdjustModal.invalid = true;
                    $scope.partAdjustModal.adjustPart.showAdjustPreview = true;
                    Notification.error($translate.instant('PartAdjustmentInStock_what_is_in_stock'));
                } else if ($scope.partAdjustModal.adjustPart.QtyIn > $scope.partDetail.QtyAvailable) {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = true;
                    $scope.partAdjustModal.invalid = true;
                    $scope.partAdjustModal.adjustPart.showAdjustPreview = true;
                    Notification.error($translate.instant('Decresed_quantity_available_stock_error'));
                }
            }
        }
        $scope.partAdjustModal.increaseApplyAction = function () {
            addPartAdjustService.increaseAdjustInStock($scope.partId,
                parseFloat($scope.partAdjustModal.adjustPart.QtyIn),
                parseFloat($scope.partAdjustModal.adjustPart.cost)).then(function (successfulSearchResult) {
                    angular.element('#addNewPartAdjust').modal('hide');
                    hideModelWindow();
                    $scope.$emit('stockAdjustment', successfulSearchResult);
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                    $scope.partAdjustModal.isFormSubmitted = false;
                },
                function (errorSearchResult) {
                    $scope.partAdjustModal.isFormSubmitted = false;
                    responseData = errorSearchResult;
                });
        }
        $scope.partAdjustModal.decreaseApplyAction = function () {
            addPartAdjustService.decreaseAdjustInStock($scope.partId,
                parseFloat($scope.partAdjustModal.adjustPart.QtyIn),
                JSON.stringify($scope.partAdjustModal.adjustBucketList)).then(function (successfulSearchResult) {
                    angular.element('#addNewPartAdjust').modal('hide');
                    hideModelWindow();
                    $scope.$emit('stockAdjustment', successfulSearchResult);
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                    $scope.partAdjustModal.isFormSubmitted = false;
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.partAdjustModal.isFormSubmitted = false;
                });
        }
        $scope.partAdjustModal.PreviewActive = function (SelectedInStock, QtyIn, cost) {
            if (SelectedInStock == 'Increase') {
                if ((QtyIn != undefined && QtyIn != "" && QtyIn >= 0) && (cost != undefined && cost != "" && cost >= 0)) {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = false;
                } else {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = true;
                }
            } else if (SelectedInStock == 'Decrease') {
                if (QtyIn != undefined && QtyIn != "" && QtyIn >= 0) {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = false;
                } else {
                    $scope.partAdjustModal.adjustPart.isPreviewActive = true;
                }

            } else {
                $scope.partAdjustModal.adjustPart.isPreviewActive = true;
            }
        }
        $scope.partAdjustModal.openPartAdjustPopupWithRouting = function () {
            var partId = $stateParams.PartAdjustmentInStockParams.partId;
            var stockAdjsutmentList = $stateParams.PartAdjustmentInStockParams.stockAdjsutmentList;
            var partDetailRecord = $stateParams.PartAdjustmentInStockParams.PartDetail;
            $scope.partAdjustModal.adjustBucketList = stockAdjsutmentList;
            for (var i = 0; i < $scope.partAdjustModal.adjustBucketList.length; i++) {
                $scope.partAdjustModal.adjustBucketList[i].isEdit = false;
            }
            $scope.partId = partId;
            $scope.partDetail = partDetailRecord;
            $scope.partAdjustModal.adjustPart.cost = $scope.partDetail.Cost;
            $scope.partAdjustModal.openPartAdjustPopup(partId);
        }
        $scope.partAdjustModal.openPartAdjustPopupWithRouting();
    }])
});