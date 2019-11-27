define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('select', ['$interpolate', function($interpolate) {
        return {
            restrict: 'E',
            require: 'ngModel',
            link: function(scope, elem, attrs, ctrl) {
                var defaultOptionTemplate;
                scope.defaultOptionText = attrs.defaultOption;
                if (attrs.defaultOption == undefined) {
                    return;
                }
                defaultOptionTemplate = '<option value="" disabled selected style="display: none;">{{defaultOptionText}}</option>';
                elem.prepend($interpolate(defaultOptionTemplate)(scope));
            }
        };
    }]);
});