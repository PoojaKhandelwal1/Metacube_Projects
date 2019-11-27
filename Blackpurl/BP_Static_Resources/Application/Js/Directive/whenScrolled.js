define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('whenScrolled', [function () {
        return {
            restrict: 'A',
            link: function (scope, elem, attrs) {
                // we get a list of elements of size 1 and need the first element
                raw = elem[0];
                scope.loading = false;
                // we load more elements when scrolled past a limit
                elem.bind("scroll", function () {
                    if (raw.scrollTop + raw.offsetHeight >= raw.scrollHeight) {
                        // we can give any function which loads more elements into the list
                        scope.$apply(attrs.whenScrolled);
                    }
                });
            }
        }
    }]);
});