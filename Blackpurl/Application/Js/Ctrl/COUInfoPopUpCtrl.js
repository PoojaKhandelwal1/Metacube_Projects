define(['Routing_AppJs_PK', 'COUInfoPopUpServices', 'tel'], function(Routing_AppJs_PK, COUInfoPopUpServices, tel) {
    Routing_AppJs_PK.controller("COUInfoCtrl", ['$scope', 'COUService','$stateParams', '$state','$rootScope', function($scope, COUService, $stateParams, $state,$rootScope) {
        if ($scope.COUPopUp == undefined) {
            $scope.COUPopUp = {};
            $scope.COUPopUp.COUModel = {};
        }
        $scope.COUPopUp.soheaderIndex = 0 ;
        $scope.COUPopUp.index = 0 ;
        $scope.$on('COUPopUpEvent', function(event, unitRelated_Json) {
            $scope.showLoading = true;
            $scope.COUPopUp.COUModel = {};
            $scope.COUPopUp.soheaderIndex = unitRelated_Json.soHeaderIndex;
            $scope.COUPopUp.index = unitRelated_Json.index;
            $scope.COUPopUp.loadData(unitRelated_Json.couId);
            $scope.showLoading = false;
        });
        $scope.closePopup = function() {
            $('#COUInfoPopup').hide();
            $(".COUInfoPopup").hide();
        }
        $scope.COUPopUp.openHourpopup = function(IdVal) {
            angular.element("#" + IdVal).show();
        }
        $scope.COUPopUp.loadData = function(COUId) {
            COUService.getCOURecordById(COUId).then(function(COURecord) {
                $scope.COUPopUp.COUModel = COURecord[0];
                if ($scope.COUPopUp.COUModel.UnitId == null && $scope.COUPopUp.COUModel.StockId == null) $scope.closePopup();
            }, function(errorSearchResult) {
                $scope.VORModel.OverlayInfo = errorSearchResult;
            });
        }
        $scope.COUPopUp.showEditButton = function () {
        	if($rootScope.$previousState.name === 'CustomerOrder_V2' || $rootScope.$previousState.name === 'CustomerOrder_V2.AddEditUnit' || $rootScope.currentStateName === 'CustomerOrder_V2') {
                return true;
            }
        }
        $scope.COUPopUp.isEditButtonEnabled = function () {
            if (($scope.COUPopUp.COUModel.UnitType == 'COU' && $scope.COUPopUp.COUModel.Status == 'Active') ||
                ($scope.COUPopUp.COUModel.UnitType == 'ORDU' && $scope.COUPopUp.COUModel.Status == 'On Order') ||
                ($scope.COUPopUp.COUModel.UnitType == 'STOCK' && ($scope.COUPopUp.COUModel.Status != 'Traded' &&
                    $scope.COUPopUp.COUModel.Status != 'Delivered'))) {
                return true;
            }
        }
        $scope.COUPopUp.editUnit = function () {
            var unitRelated_Json = {
                couId: $scope.COUPopUp.COUModel.Id,
                customerId: $scope.COUPopUp.COUModel.CustomerId,
                soHeaderIndex:$scope.COUPopUp.soheaderIndex,
                index: $scope.COUPopUp.index,
                unitType: 'STOCK'
            };
            loadState($state, 'CustomerOrder_V2.AddEditUnit', {
                AddEditUnitParams: unitRelated_Json
            });
        }
    }])
});