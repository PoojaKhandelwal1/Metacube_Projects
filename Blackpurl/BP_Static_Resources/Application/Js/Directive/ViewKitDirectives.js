define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {

    Routing_AppJs_PK.directive('numberOnlyInputHeader', [function () {
        return {
            restrict: 'EA',
            template: '<input type="text" ng-blur="blur();" onfocus="this.select();" ng-disabled="disabledValue==true" class="form-control" ng-model="inputValue" id="{{idVal}}" style="width: 60%;"/>',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                disabledValue: '='
            },
            link: function (scope) {
                scope.blur = function () {
                    scope.$parent.blurcallback();
                }

                scope.$watch('inputValue', function (newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0)
                        return;
                    if (arr[0] == '-') {
                        scope.inputValue = oldValue;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (typeof (pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);

    Routing_AppJs_PK.directive('numberOnlyInputKit', [function () {
        return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();" class="form-control" ng-model="inputValue"  id="{{idVal}}" style="width: 60%;"/>',
            scope: {
                inputValue: '=',
                "idVal": "@idVal"
            },
            link: function (scope) {
                scope.inputValue = Math.round(scope.inputValue * 100) / 100;
                scope.$watch('inputValue', function (newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0)
                        return;
                    if (arr[0] == '-') {
                        scope.inputValue = oldValue;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (typeof (pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);
});