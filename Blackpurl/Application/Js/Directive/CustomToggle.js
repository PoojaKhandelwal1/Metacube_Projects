define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('customtoggle', [function() {
        return {
            restrict: 'A',
            link: function(scope, element, attrs) {
                if (attrs.customtoggle == "tooltip") {
                    $(element).tooltip({
                        placement: 'right'
                    });
                }
                if (attrs.customtoggle == "popover") {
                    $(element).popover();
                }
            }
        };
    }]);
});