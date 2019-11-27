define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('tooltipLoader', [function() {
        return function(scope, element, attrs) {
            element.tooltip({
            trigger:"hover",
            placement: "top",
            delay: {show: 100, hide: 0}
          });
        };
    }]);
});