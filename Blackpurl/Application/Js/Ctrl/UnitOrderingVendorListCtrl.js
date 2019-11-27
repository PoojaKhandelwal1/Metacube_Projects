define(['Routing_AppJs_PK', 'UnitOrderingServices'], function(Routing_AppJs_PK, UnitOrderingServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('UnitOrderingVendorListCtrl', ['$scope', '$stateParams', '$state', '$rootScope', 'UnitOrderingService','$translate',
        function($scope, $stateParams, $state, $rootScope, UnitOrderingService,$translate) {
            var Notification = injector1.get("Notification");
            $scope.M_UO.isLoading = true;
            $scope.F_UO.selectVendor = function() {
                var selectVendor_Json = {
                    type: 'Unit Ordering',
                    isOpenFromUnitOrdering: true,
                    additionalFiltervalues: [{
                        'Field': 'Unit_Purchases__c',
                        'Value': false,
                        'Operator': '='
                    }]
                };
                $scope.F_UO.MoveToState('UnitOrdering.UnitOrderingVendorList.SelectCustomer', {
                    myParams: selectVendor_Json
                });
            }
            $scope.$on('selectedCustomerForUOCallback', function(event, args) {
                $scope.M_UO.selectedVendorId = args;
                $scope.M_UO.isLoading = true;
                UnitOrderingService.setUnitPurchaseFlagForVendor($scope.M_UO.selectedVendorId).then(function(successResult) {
                    loadState($state, 'UnitOrdering.AddeditUnitOrder', {
                        'vendorId': $scope.M_UO.selectedVendorId
                    });
                }, function(errorResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            });
            $scope.F_UO.getVendorsList = function() {
                UnitOrderingService.getVendorsList().then(function(successResult) {
                    $scope.M_UO.vendorsList = successResult;
                    $scope.M_UO.isLoading = false;
                }, function(errorResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                    $scope.M_UO.isLoading = false;
                });
            }
            $scope.F_UO.getVendorsList();
        }
    ])
});