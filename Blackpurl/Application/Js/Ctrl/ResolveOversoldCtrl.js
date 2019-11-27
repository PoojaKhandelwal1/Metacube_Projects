define(['Routing_AppJs_PK', 'ResolveOversoldServices'], function(Routing_AppJs_PK, ResolveOversoldServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ResolveOversoldCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'ResolveOversoldService', function($scope, $timeout, $q, $rootScope, $state, $stateParams, ResolveOversoldService) {
        var Notification = injector1.get("Notification");
        if ($scope.resolveOversoldModel == undefined) {
            $scope.resolveOversoldModel = {};
        }
        $scope.resolveOversoldModel.showPreview = true;
        $scope.oversoldJson = {};
        $scope.$on('resolveOversoldEvent', function(event, oversoldJson) {
            $scope.resolveOversoldModel.openResolveOversoldModelPopup(oversoldJson);
        });
        $scope.resolveOversoldModel.showApplyBtn = function() {
            $scope.resolveOversoldModel.showPreview = false;
        }
        $scope.resolveOversoldModel.DateFormat = $Global.DateFormat;
        $scope.resolveOversoldModel.isFormSubmitted = false;
        $scope.resolveOversoldModel.openResolveOversoldModelPopup = function(oversoldJson) {
            $scope.resolveOversoldModel.openPopup();
            $scope.oversoldJson = [];
            $scope.resolvedJson = [];
            $scope.oversoldJson = oversoldJson;
            $scope.resolvedJson = angular.copy(oversoldJson);
            var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            var date = new Date();
            var day = date.getDate();
            day = day <= 9 ? '0' + day : day;
            var monthIndex = date.getMonth();
            var year = date.getFullYear();
            for (var i = 0; i < $scope.resolvedJson.length; i++) {
                var lineitem = {};
                $scope.resolvedJson[i].QtyOut = $scope.resolvedJson[i].QtyIn;
                $scope.resolvedJson[i].RemainingQty = 0;
                $scope.resolvedJson[i].Total = 0;
                var dateFormatArray = $scope.resolveOversoldModel.DateFormat.split("/");
                if (dateFormatArray[0].indexOf('mm') != -1) {
                    lineitem.CreatedDate = monthNames[monthIndex] + ' ' + day + ', ' + year;
                } else if (dateFormatArray[1].indexOf('mm') != -1) {
                    lineitem.CreatedDate = day + ' ' + monthNames[monthIndex] + ', ' + year;
                }
                lineitem.UniqueId = 'TBD';
                lineitem.Reference = 'Count Adjustment';
                lineitem.IsCountAdjustment = true;
                lineitem.QtyOut = oversoldJson[i].RemainingQty;
                $scope.resolvedJson[i].PartFIFOActivityLineItemList.push(lineitem);
            }
            setTimeout(function() {
                angular.element('#feeCodeInput').focus();
            }, 1000);
        }
        $scope.resolveOversoldModel.ResolveOversold = function() {
            ResolveOversoldService.getResolveOversoldInStock(JSON.stringify($scope.oversoldJson)).then(function(successfulSearchResult) {
                angular.element('#resolveOversold').modal('hide');
                hideModelWindow();
                $scope.$emit('OversoldUpdate', successfulSearchResult);
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
                $scope.resolveOversoldModel.isFormSubmitted = false;
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                $scope.resolveOversoldModel.isFormSubmitted = false;
            });
        }
        $scope.resolveOversoldModel.openPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#resolveOversold').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 1000);
        }
        $scope.resolveOversoldModel.closePopup = function() {
            $scope.resolveOversoldModel.showPreview = true;
            angular.element('#resolveOversold').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.resolveOversoldModel.openResolveOversoldPopupWithRouting = function() {
            var oversoldJson = $stateParams.ResolveOversoldParams.oversoldJson;
            $scope.resolveOversoldModel.openResolveOversoldModelPopup(oversoldJson);
        }
        $scope.resolveOversoldModel.openResolveOversoldPopupWithRouting();
    }])
});