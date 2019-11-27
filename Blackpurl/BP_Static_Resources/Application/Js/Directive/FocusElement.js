var app = angular.module('FocusElement', []);
app.factory('focusElement', ['$timeout', '$window', function($timeout, $window) {
    return function(id) {
        /**
         * timeout makes sure that it is invoked after any other event has been triggered.
         * e.g. click events that need to run before the focus or
         * inputs elements that are in a disabled state but are enabled when those events
         * are triggered.
         */
        $timeout(function() {
            var element = $window.document.getElementById(id);
            if (element) element.focus();
        });
    };
}]);
app.directive('eventFocus', ['focus', function(focus) {
    return function(scope, elem, attr) {
        elem.on(attr.eventFocus, function() {
            focus(attr.eventFocusId);
        });
        /**
         * Removes bound events in the element itself
         * when the scope is destroyed
         */
        scope.$on('$destroy', function() {
            elem.off(attr.eventFocus);
        });
    };
}]);