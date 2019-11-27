define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    $(document).ready(function() {
        $(".form-control").focus(function() {
            $('.controls').hide();
            $('#' + $(this).attr('rel')).show();
        });
        $('#closemodal').click(function() {
            $('#pop').modal('hide');
        });
        setTimeout(function() {
            $('[data-toggle="tooltip"]').tooltip({
                placement: 'bottom'
            });
        }, 2000);
    });
    Routing_AppJs_PK.controller('SelectUnitCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', function($scope, $timeout, $q, $rootScope, $state, $stateParams) {
        if ($scope.SelectUnit == undefined) {
            $scope.SelectUnit = {};
        }
        $scope.SelectUnit.DealUnitInfo = {};
        $scope.SelectUnit.dealId = null;
        $scope.SelectUnit.optionFeeJSON = {};
        $scope.SelectUnit.getSelectUnit = function(dealItemId, dealHeaderIndex) {
            $scope.$parent.CustomerOrderModel.dealLineItemId = dealItemId;
            $scope.$parent.CustomerOrderModel.DealHeaderIndex = dealHeaderIndex;
            $scope.$parent.CustomerOrderModel.saveOptionFeesLineItemDetails($scope.SelectUnit.dealId, $scope.SelectUnit.optionFeeJSON);
            $scope.SelectUnit.cancelSelectUnitPopup();
        }
        $scope.$on('SelectUnitEvent', function(event, args) {
            $scope.SelectUnit.dealId = args.dealId;
            $scope.SelectUnit.optionFeeJSON = args.optionFeeJSON;
            $scope.SelectUnit.DealItemList = $scope.$parent.CustomerOrderModel.DealItemList;
            setTimeout(function() {
                $scope.SelectUnit.openSelectUnitPopup();
            }, 100);
        });
        $scope.SelectUnit.openSelectUnitPopup = function() {
            angular.element('.controls').hide();
            setTimeout(function() {
                angular.element('#SelectUnitPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }
        $scope.SelectUnit.cancelSelectUnitPopup = function() {
            angular.element('#SelectUnitPopup').modal('hide');
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.SelectUnit.openSelectUnitPopupWithRouting = function() {
            $scope.SelectUnit.dealId = $stateParams.SelectUnitParams.dealId;
            $scope.SelectUnit.optionFeeJSON = $stateParams.SelectUnitParams.optionFeeJSON;
            $scope.SelectUnit.DealItemList = $scope.$parent.CustomerOrderModel.DealItemList;
            setTimeout(function() {
                $scope.SelectUnit.openSelectUnitPopup();
            }, 100);
        }
        $scope.SelectUnit.openSelectUnitPopupWithRouting();
    }])
});