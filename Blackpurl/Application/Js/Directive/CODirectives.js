define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('ngEnterInPricebox', [function() {
        return function(scope, element, attrs) {
            element.bind("keypress", function(event) {
                if (event.which === 13) {
                    scope.$apply(function() {
                        scope.$eval(attrs.ngEnterInPricebox, {
                            'event': event
                        });
                    });
                    event.preventDefault();
                }
            });
        };
    }]);
    Routing_AppJs_PK.directive('numberOnlyInputBlurService', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" ng-blur="callbackFunction({SoIndex :soIndex ,KitIndex : kitIndex,SoliIndex : soliIndex, event: $event,RefreshEdit : refreshEdit,FocusId : null})"  />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "tabIndex": "@tabIndex",
                "disableAttr": '=',
                "includeNegative": "@includeNegative",
                "includeZero": "@includeZero",
                "callbackFunction": "&",
                "kitIndex": "=",
                "soIndex": "=",
                "soliIndex": "="
            },
            link: function(scope) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    if (newValue == oldValue) {
                        return;
                    }
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (pieces[1] == "" && pieces.length == 2) {
                        scope.inputValue = newValue;
                        return;
                    }
                    if (arr.length === 0) return;
                    if (angular.isDefined(scope.includeNegative) && scope.includeNegative === 'false' && newValue < 0) {
                        scope.inputValue = oldValue;
                        return;
                    }
                    if (newValue == '-') {
                        return;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (newValue == 0 || newValue == -0) {
                        if (angular.isDefined(scope.includeZero)) {} else {
                            scope.inputValue = oldValue;
                        }
                    } else if (typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);
    Routing_AppJs_PK.directive('numberOnlyInputCo', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "tabIndex": "@tabIndex",
                "disableAttr": '=',
                "includeNegative": "@includeNegative",
                "includeZero": "@includeZero"
            },
            link: function(scope) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (pieces[1] == "" && pieces.length == 2) {
                        scope.inputValue = newValue;
                        return;
                    }
                    if (arr.length === 0) return;
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
    Routing_AppJs_PK.directive('numberOnlyInputClaim', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();"  class="form-control text-center" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "tabIndex": "@tabIndex",
                "disableAttr": '=',
                "includeNegative": "@includeNegative",
                "precisionLength": '@',
            },
            link: function(scope, el, attrs) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0) return;
                    if (arr[0] == '-' && arr[1] != 0) {
                        return;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                        var newValue = scope.inputValue;
                        var pieces = String(newValue).split(".");
                        if (pieces[1] != null && pieces[1] != "" && pieces[1].length > attrs.precisionLength) {
                            pieces[1] = pieces[1].substring(0, attrs.precisionLength);
                        }
                        scope.inputValue = pieces[0] + ((pieces[1] != null && pieces[1] != "") ? ("." + pieces[1]) : ((attrs.precisionLength > 0 && String(newValue).indexOf(".") != -1) ? "." : ""));
                    } else if (typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                        var newValue = scope.inputValue;
                        var pieces = String(newValue).split(".");
                        if (pieces[1] != null && pieces[1] != "" && pieces[1].length > attrs.precisionLength) {
                            pieces[1] = pieces[1].substring(0, attrs.precisionLength);
                        }
                        scope.inputValue = pieces[0] + ((pieces[1] != null && pieces[1] != "") ? ("." + pieces[1]) : ((attrs.precisionLength > 0 && String(newValue).indexOf(".") != -1) ? "." : ""));
                    }
                });
            }
        };
    }]);
    Routing_AppJs_PK.directive('numberOnlyInputService', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" ng-blur="CO_SearchToAdd_value" onfocus="this.select();" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" tabindex="{{tabIndex}}" />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "tabIndex": "@tabIndex"
            },
            link: function(scope) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0) return;
                    if (arr[0] == '-') {
                        scope.inputValue = oldValue;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
                scope.focusSerchtoAdd = function() {
                    angular.element('#CO_SearchToAdd_value').focus();
                }
            }
        };
    }]);
    Routing_AppJs_PK.directive('priceOnlyInputCustomerOrder', [function() {
        return {
            restrict: 'EA',
            template: '<input type="text" class="form-control" ng-model="inputValue" id="{{idVal}}" />',
            scope: {
                inputValue: '=',
                "idVal": "@idVal"
            },
            link: function(scope) {
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0) return;
                    if (arr[0] == '-') {
                        scope.inputValue = oldValue;
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);
    Routing_AppJs_PK.directive('tooltip', [function() {
        return {
            restrict: 'A',
            link: function(scope, element, attrs) {
                $(element).hover(function() {
                    $(element).tooltip('show');
                }, function() {
                    $(element).tooltip('hide');
                });
            }
        };
    }]);
});