define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {	
	Routing_AppJs_PK.directive('numberOnlyInputBlurCoaImport', [function() {
		return {
			restrict: 'EA',
			template: '<input type="text" onfocus="this.select();" class="form-control text-left priceField" ng-disabled="packaged==false" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" ng-blur="callbackFunction({ event: $event,KitIndex : kitIndex,ColiIndex : coliIndex ,FocusId : null})"  />',
			scope: {
				inputValue: '=',
				"idVal": "@idVal",
				"tabIndex": "@tabIndex",
				"disableAttr": '=',
				"includeNegative": "@includeNegative",
				"includeZero": "@includeZero",
				"packaged" : '=',
				"callbackFunction": "&",
				"kitIndex": "=",
				"coliIndex": "="
			},
			link: function(scope) {
				scope.$watch('inputValue', function(newValue, oldValue) {
					var arr = String(newValue).split("");
					var pieces = String(newValue).split(".");
					if(pieces[1] == "" && pieces.length == 2) {
						scope.inputValue = newValue;
						return;
					}
					if(arr.length === 0) return;
					if(angular.isDefined(scope.includeNegative) && arr[0] == '-' && arr[1] != 0) {
						scope.inputValue = oldValue;
						return;
					} else if(isNaN(newValue)) {
						scope.inputValue = oldValue;
					} else if(newValue == 0 || newValue == -0) {
						if(angular.isDefined(scope.includeZero)) {
						} else {
							scope.inputValue = oldValue;
						}
					} else if(typeof(pieces[1]) != "undefined" && pieces[1].length > 2) {
						scope.inputValue = oldValue;
					}
				});
			}
		};
    }]);
});   