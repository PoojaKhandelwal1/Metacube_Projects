define(['Routing_AppJs_PK', 'ModifyCostSourceServices', 'dirNumberInput'], function (Routing_AppJs_PK, ModifyCostSourceServices, dirNumberInput) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ModifyCostSourceCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'modifyCostSourceService', function ($scope, $timeout, $q, $rootScope, $state, $stateParams, modifyCostSourceService) {
        var Notification = injector1.get("Notification");
        if ($scope.modifyCostSourceModel == undefined) {
            $scope.modifyCostSourceModel = {};
        }
        $scope.modifyCostSourceModel.isAdjustmentRemaining = true;
        $scope.modifyCostSourceModel.showPreview = false;
        $scope.modifyCostSourceModel.isFormSubmitted = false;
        $scope.$on('ModifyCostSourceEvent', function (event, selectedbucket) {
            $scope.modifyCostSourceModel.previewBucketList = [];
            $scope.modifyCostSourceModel.showPreview = false;
            $scope.modifyCostSourceModel.adjustedCost = 0;
            $scope.modifyCostSourceModel.isAdjustmentRemaining = true;
            $scope.modifyCostSourceModel.openModifyCostSourceModelPopup(selectedbucket);
            $scope.selectedbucketmodel = selectedbucket;
        });
        $scope.selectedbucketmodel = {};
        $scope.modifyCostSourceModel.DateFormat = $Global.DateFormat;
        $scope.modifyCostSourceModel.showModifyCostSourcePreviewGrid = function () {
            $scope.modifyCostSourceModel.showPreview = true;
            $scope.modifyCostSourceModel.previewBucketList = [];
            var monthNames = [
                "Jan", "Feb", "Mar",
                "Apr", "May", "Jun", "Jul",
                "Aug", "Sep", "Oct",
                "Nov", "Dec"
            ];
            var date = new Date();
            var day = date.getDate();
            if (day < 10) {
                day = '0' + day;
            }
            var monthIndex = date.getMonth();
            var year = date.getFullYear();
            var gropuItem = {};
            $scope.modifyCostSourceModel.previewBucketList = [];
            $scope.selectedbucketmodeltemp = angular.copy($scope.selectedbucketmodel.selectedbucket);
            $scope.modifyCostSourceModel.previewBucketList.push($scope.selectedbucketmodeltemp);
            for (var i = 0; i < $scope.modifyCostSourceModel.previewBucketList.length; i++) {
                $scope.extraActivityLineItem = {}
                var dateFormatArray = $scope.modifyCostSourceModel.DateFormat.split("/");
                if (dateFormatArray[0].indexOf('mm') != -1) {
                    $scope.extraActivityLineItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
                } else if (dateFormatArray[1].indexOf('mm') != -1) {
                    $scope.extraActivityLineItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
                }
                $scope.extraActivityLineItem.UniqueId = 'TBD';
                $scope.extraActivityLineItem.Reference = 'Cost Adjustment';
                $scope.extraActivityLineItem.QtyOut = $scope.selectedbucketmodel.selectedbucket.RemainingQty;
                $scope.modifyCostSourceModel.previewBucketList[i].QtyOut = $scope.selectedbucketmodel.selectedbucket.QtyIn;
                $scope.modifyCostSourceModel.previewBucketList[i].RemainingQty = 0;
                $scope.modifyCostSourceModel.previewBucketList[i].Total = 0.0;
                $scope.modifyCostSourceModel.previewBucketList[i].PartFIFOActivityLineItemList.push($scope.extraActivityLineItem);
            }
            gropuItem.SourceName = "Cost Adjust"

            if (dateFormatArray[0].indexOf('mm') != -1) {
                gropuItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
            } else if (dateFormatArray[1].indexOf('mm') != -1) {
                gropuItem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
            }
            gropuItem.UniqueId = "TBD";
            gropuItem.Reference = 're :' + $scope.selectedbucketmodel.selectedbucket.UniqueId;
            if ($scope.modifyCostSourceModel.isAdjustmentRemaining) {
                gropuItem.QtyIn = $scope.selectedbucketmodel.selectedbucket.RemainingQty;
                gropuItem.QtyOut = 0;
            } else {
                gropuItem.QtyIn = $scope.selectedbucketmodel.selectedbucket.QtyIn;
                gropuItem.QtyOut = $scope.selectedbucketmodel.selectedbucket.QtyOut;
            }

            gropuItem.RemainingQty = $scope.selectedbucketmodel.selectedbucket.RemainingQty;
            gropuItem.Cost = $scope.modifyCostSourceModel.adjustedCost;
            gropuItem.PartFIFOActivityLineItemList = [];
            gropuItem.isCostAdjustment = true
            gropuItem.Total = gropuItem.Cost * gropuItem.RemainingQty;
            if ($scope.modifyCostSourceModel.isAdjustmentRemaining == false) {
                $scope.presoldActivityLineItem = {}
                $scope.presoldActivityLineItem.CreatedDate = monthNames[monthIndex] + ' ' + day + ' ' + year;
                $scope.presoldActivityLineItem.UniqueId = 'TBD';
                $scope.presoldActivityLineItem.Reference = 'Presold on:' + $scope.selectedbucketmodel.selectedbucket.UniqueId;
                $scope.presoldActivityLineItem.QtyOut = $scope.selectedbucketmodel.selectedbucket.QtyOut;
                gropuItem.PartFIFOActivityLineItemList.push($scope.presoldActivityLineItem);
            }
            $scope.modifyCostSourceModel.previewBucketList.push(gropuItem);
        }

        $scope.modifyCostSourceModel.updateCost = function () {
            $scope.modifyCostSourceModel.showPreview = false;
        }
        $scope.modifyCostSourceModel.onClickCostSource = function (event) {
            $scope.modifyCostSourceModel.isAdjustmentRemaining = !$scope.modifyCostSourceModel.isAdjustmentRemaining;
            if ($scope.modifyCostSourceModel.showPreview) {
                $scope.modifyCostSourceModel.showPreview = !$scope.modifyCostSourceModel.showPreview;
            }
        }
        $scope.modifyCostSourceModel.showApplyBtn = function () {
            $scope.modifyCostSourceModel.showPreview = false;
        }
        $scope.modifyCostSourceModel.openModifyCostSourceModelPopup = function (selectedbucket) {
            $scope.bucket = selectedbucket;
            $scope.modifyCostSourceModel.openPopup();
            setTimeout(function () {
                angular.element('#feeCodeInput').focus();
            }, 1000);
        }
        $scope.modifyCostSourceModel.openPopup = function () {
            angular.element('.controls').hide();
            setTimeout(function () {
                angular.element('#modifyCostSource').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.modifyCostSourceModel.closePopup = function () {
            $scope.modifyCostSourceModel.showPreview = true;
            angular.element('#modifyCostSource').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }

        $scope.modifyCostSourceModel.modifyCostSourcValidationModal = {
            adjustedCost: {
                isError: false,
                ErrorMessage: '',
                Type: 'Required'
            }
        }
        $scope.saveAdjustedCostSource = function () {
            modifyCostSourceService.saveAdjustedCostDetails(angular.toJson($scope.selectedbucketmodel.selectedbucket), parseFloat($scope.modifyCostSourceModel.adjustedCost), $scope.modifyCostSourceModel.isAdjustmentRemaining).then(function (successfulSearchResult) {
                    $scope.modifyCostSourceModel.showPreview = true;
                    angular.element('#modifyCostSource').modal('hide');
                    hideModelWindow();
                    $scope.$emit('modifyCostSourceAdjustment', successfulSearchResult);
                    $scope.$emit('ModifyCostSourceUpdateBucketEvent', {
                        updatedbucket: {}
                    });
                    $scope.selectedbucketmodel.selectedbucket = {};
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                    $scope.modifyCostSourceModel.isFormSubmitted = false;
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.modifyCostSourceModel.isFormSubmitted = false;
                });
        }
        $scope.modifyCostSourceModel.openModifyCostSourceWithRouting = function () {
            var selectedbucket = {
                selectedbucket: $stateParams.ModifyCostSourceParams.selectedbucketJson
            };
            $scope.modifyCostSourceModel.previewBucketList = [];
            $scope.modifyCostSourceModel.showPreview = false;
            $scope.modifyCostSourceModel.adjustedCost = 0;
            $scope.modifyCostSourceModel.isAdjustmentRemaining = true;
            $scope.modifyCostSourceModel.openModifyCostSourceModelPopup(selectedbucket);
            $scope.selectedbucketmodel = selectedbucket;
        }
        $scope.modifyCostSourceModel.openModifyCostSourceWithRouting();
    }])
});