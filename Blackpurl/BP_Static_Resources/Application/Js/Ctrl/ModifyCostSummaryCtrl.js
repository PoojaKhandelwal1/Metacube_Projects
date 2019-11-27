define(['Routing_AppJs_PK', 'ModifyCostSummaryServices'], function (Routing_AppJs_PK, ModifyCostSummaryServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ModifyCostSummaryCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'modifyCostSummryService', function ($scope, $timeout, $q, $rootScope, $state, $stateParams, modifyCostSummryService) {
        var Notification = injector1.get("Notification");
        if ($scope.modifyCostSummaryModel == undefined) {
            $scope.modifyCostSummaryModel = {};
        }
        $scope.modifyCostSummaryModel.previewBucketList = [];
        $scope.modifyCostSummaryModel.activePreviewButton = false;
        $scope.modifyCostSummaryModel.showPreview = false;
        $scope.modifyCostSummaryModel.isFormSubmitted = false;
        $scope.$on('ModifyCostSummaryEvent', function (event, args) {
            $scope.modifyCostSummaryModel.bucketList = args;
            $scope.modifyCostSummaryModel.remainingQty = 0
            $scope.modifyCostSummaryModel.total = 0
            $scope.modifyCostSummaryModel.avgCost = 0
            for (var i = 0; i < $scope.modifyCostSummaryModel.bucketList.length; i++) {
                $scope.modifyCostSummaryModel.remainingQty += $scope.modifyCostSummaryModel.bucketList[i].RemainingQty
                $scope.modifyCostSummaryModel.total += $scope.modifyCostSummaryModel.bucketList[i].Total;
                $scope.modifyCostSummaryModel.avgCost = $scope.modifyCostSummaryModel.total / $scope.modifyCostSummaryModel.remainingQty
            }
            $scope.modifyCostSummaryModel.openmodifyCostSummaryModelPopup();

        });
        $scope.modifyCostSummaryModel.openmodifyCostSummaryModelPopup = function () {
            $scope.modifyCostSummaryModel.openPopup();
            setTimeout(function () {
                angular.element('#feeCodeInput').focus();
            }, 1000);
        }
        $scope.modifyCostSummaryModel.openPopup = function () {
            angular.element('.controls').hide();
            setTimeout(function () {
                angular.element('#modifyCostSummary').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.modifyCostSummaryModel.closePopup = function () {
            $scope.modifyCostSummaryModel.showPreview = false;
            $scope.modifyCostSummaryModel.cost = '';
            $scope.modifyCostSummaryModel.activePreviewButton = false;
            angular.element('#modifyCostSummary').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.modifyCostSummaryModel.PreviewActive = function (newCost) {
            if (newCost != undefined && newCost != "" && newCost >= 0) {
                $scope.modifyCostSummaryModel.activePreviewButton = true;
            } else {
                $scope.modifyCostSummaryModel.activePreviewButton = false;
            }
        }
        $scope.modifyCostSummaryModel.DateFormat = $Global.DateFormat;
        $scope.modifyCostSummaryModel.showModifyCostSummaryPreviewGrid = function () {
            $scope.modifyCostSummaryModel.showPreview = true;
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
            var gropuItem = {};
            var lineItem = {};
            $scope.modifyCostSummaryModel.previewBucketList = angular.copy($scope.modifyCostSummaryModel.bucketList);
            for (var i = 0; i < $scope.modifyCostSummaryModel.previewBucketList.length; i++) {

                $scope.modifyCostSummaryModel.previewBucketList[i].PartFIFOActivityLineItemList.isCostAdjustment = false;
                var lineItem = {};
                gropuItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
                var dateFormatArray = $scope.modifyCostSummaryModel.DateFormat.split("/");
                if (dateFormatArray[0].indexOf('mm') != -1) {
                    gropuItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
                } else if (dateFormatArray[1].indexOf('mm') != -1) {
                    gropuItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
                }
                lineItem.UniqueId = "TBD";
                lineItem.Reference = "Cost Adjustment";
                lineItem.isCostAdjustment = true
                lineItem.QtyOut = $scope.modifyCostSummaryModel.previewBucketList[i].RemainingQty;
                $scope.modifyCostSummaryModel.previewBucketList[i].PartFIFOActivityLineItemList.push(lineItem);
                $scope.modifyCostSummaryModel.previewBucketList[i].QtyOut = $scope.modifyCostSummaryModel.previewBucketList[i].QtyOut + $scope.modifyCostSummaryModel.previewBucketList[i].RemainingQty;
                $scope.modifyCostSummaryModel.previewBucketList[i].RemainingQty = 0;
                $scope.modifyCostSummaryModel.previewBucketList[i].isCostAdjustment = false;
            }
            gropuItem.SourceName = "cost Adjust"
            if (dateFormatArray[0].indexOf('mm') != -1) {
                gropuItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
            } else if (dateFormatArray[1].indexOf('mm') != -1) {
                gropuItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
            }
            gropuItem.UniqueId = "TBD";
            gropuItem.Reference = "Cost Adjustment";
            gropuItem.QtyIn = $scope.modifyCostSummaryModel.remainingQty;
            gropuItem.QtyOut = 0;
            gropuItem.RemainingQty = $scope.modifyCostSummaryModel.remainingQty;
            gropuItem.Cost = $scope.modifyCostSummaryModel.cost;
            gropuItem.isCostAdjustment = true
            if ($scope.modifyCostSummaryModel.cost != 'undefined' && $scope.modifyCostSummaryModel.cost != '' && $scope.modifyCostSummaryModel.cost >= 0) {
                gropuItem.Total = $scope.modifyCostSummaryModel.cost * $scope.modifyCostSummaryModel.remainingQty;
            }
            $scope.modifyCostSummaryModel.previewBucketList.push(gropuItem);
        }
        $scope.modifyCostSummaryModel.saveModifyCostSummary = function () {
            modifyCostSummryService.modifyCostSummary(JSON.stringify($scope.modifyCostSummaryModel.bucketList), parseFloat($scope.modifyCostSummaryModel.cost)).then(function (successfulSearchResult) {
                    angular.element('#modifyCostSummary').modal('hide');
                    hideModelWindow();
                    $scope.$emit('modifyCostUpdate', successfulSearchResult);
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                    $scope.modifyCostSummaryModel.isFormSubmitted = false;
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.modifyCostSummaryModel.isFormSubmitted = false;
                });
        }
        $scope.modifyCostSummaryModel.openModifyCostSummaryWithRouting = function () {
            var bucketList = $stateParams.ModifyCostSummaryParams.ModifyCostSummaryList;
            $scope.modifyCostSummaryModel.bucketList = bucketList;
            $scope.modifyCostSummaryModel.remainingQty = 0;
            $scope.modifyCostSummaryModel.total = 0;
            $scope.modifyCostSummaryModel.avgCost = 0;
            for (var i = 0; i < $scope.modifyCostSummaryModel.bucketList.length; i++) {
                $scope.modifyCostSummaryModel.remainingQty += $scope.modifyCostSummaryModel.bucketList[i].RemainingQty
                $scope.modifyCostSummaryModel.total += $scope.modifyCostSummaryModel.bucketList[i].Total;
                $scope.modifyCostSummaryModel.avgCost = $scope.modifyCostSummaryModel.total / $scope.modifyCostSummaryModel.remainingQty
            }
            $scope.modifyCostSummaryModel.openmodifyCostSummaryModelPopup();
        }
        $scope.modifyCostSummaryModel.openModifyCostSummaryWithRouting();
    }])
});