define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('UnitOrderingCtrl', ['$scope', '$stateParams', '$state', '$rootScope', function($scope, $stateParams, $state, $rootScope) {
        var Notification = injector1.get("Notification");
        $scope.M_UO = $scope.M_UO || {};
        $scope.F_UO = $scope.F_UO || {};
        $scope.M_UO.vendorName = '';
        $scope.M_UO.unitNumber = '';
        $scope.M_UO.vendorId = '';
        $scope.M_UO.isViewChanged = false;
        $scope.M_UO.isLoading = true;
        $scope.F_UO.MoveToState = function(stateName, attr) {
            if (attr) {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
    }])
});