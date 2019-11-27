define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('shouldFocus', [function() {
        return {
            restrict: 'A',
            link: function(scope, element, attrs) {
                scope.$watch(attrs.shouldFocus, function(newVal, oldVal) {
                    if (!(scope.CashSaleModel != '' && scope.CashSaleModel != undefined && scope.CashSaleModel != null && scope.CashSaleModel.isMobile.any())) {
                        element[0].scrollIntoView(false);
                    }
                });
            }
        };
    }]);
});