define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('numberOnlyInputBarCode', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "tabIndex": "@tabIndex",
                "disableAttr": '=',
                "allowNegative": "@allowNegative",
                "includeZero": "@includeZero",
                "maxLength": '@',
                "precisionLength": '@'
            },
            link: function(scope, attrs) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (String(newValue).indexOf(".") != -1) {
                        scope.inputValue = oldValue;
                        return;
                    }
                    if (pieces[1] == "" && pieces.length == 2) {
                        scope.inputValue = newValue;
                        return;
                    }
                    if (arr.length === 0) return;
                    if (arr.length > scope.maxLength) {
                        scope.inputValue = oldValue;
                    }
                    if (arr[0] == '-') {
                        if (!angular.isDefined(scope.allowNegative)) {
                            scope.inputValue = oldValue;
                        } else if (angular.isDefined(scope.includeZero) && newValue != '-') {
                            if (isNaN(newValue)) {
                                scope.inputValue = oldValue;
                            } else if (String(newValue).indexOf(".") != -1) {
                                scope.inputValue = oldValue;
                            } else {
                                if (pieces[0].length > attrs.maxLength) {
                                    pieces[0] = pieces[0].substring(0, attrs.maxLength);
                                }
                                if (pieces[1] != null && pieces[1] != "" && pieces[1].length > attrs.precisionLength) {
                                    pieces[1] = pieces[1].substring(0, attrs.precisionLength);
                                }
                                scope.inputValue = pieces[0] + ((pieces[1] != null && pieces[1] != "") ? ("." + pieces[1]) : ((attrs.precisionLength > 0 && String(newValue).indexOf(".") != -1) ? "." : ""));
                            }
                        }
                    }
                    if (arr[0] == '-' && arr[1] != 0) {
                        return;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (newValue == 0 || newValue == -0) {
                        if (angular.isDefined(scope.includeZero)) {
                            
                        } else {
                            scope.inputValue = oldValue;
                        }
                    } else if (typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);
});