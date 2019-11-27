define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('numberOnlyInputVr', [function() {
		return {
            restrict: 'EA',
            template: '<input type="text" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" />',
            scope: {
				inputValue: '=',
            	"idVal": "@idVal"
            },
            link: function (scope) {
                scope.$watch('inputValue', function(newValue,oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0) return;
                    if(arr[0] == '-') {
                    	scope.inputValue = oldValue;
                    }
                    else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    }
                    else if(typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
                        scope.inputValue = oldValue;
                    }
                });
            }
        };
    }]);
});	        