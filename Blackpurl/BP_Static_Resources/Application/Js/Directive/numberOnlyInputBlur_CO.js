define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {	
	Routing_AppJs_PK.directive('numberOnlyInputBlur', [function() {
		return {
	        restrict: 'EA',
	        template: '<input type="text" onfocus="this.select();" class="form-control text-center" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" ng-blur="callbackFunction({ event: $event,KitIndex : kitIndex,ColiIndex : coliIndex ,FocusId : null})"  />',
	        scope: {
	            inputValue: '=',
	            "idVal": "@idVal",
	            "tabIndex": "@tabIndex",
	            "disableAttr": '=',
	            "includeNegative": "@includeNegative",
	            "includeZero": "@includeZero",
	            "callbackFunction": "&",
	            "kitIndex": "=",
	            "coliIndex": "="
	        },
	        link: function(scope) {
	            scope.$watch('inputValue', function(newValue, oldValue) {
                	if(newValue == oldValue){ 
	            		return;
	            	}                   
	                var arr = String(newValue).split("");
	                var pieces = String(newValue).split(".");
	                if(pieces[1] == "" && pieces.length == 2) {
	                    scope.inputValue = newValue;
	                    return;
	                }					
                    if(angular.isDefined(scope.includeNegative) && scope.includeNegative  === 'false' && newValue < 0){
						 scope.inputValue = oldValue;
						 return;
	                }                   
					if(arr.length === 0) {
	                	return;
	                }else if(arr.length == 2){
	                	if(arr[0] == '-' && arr[1] == '-'){
	                		scope.inputValue = oldValue;
	                	}
	                }
	                if((!angular.isDefined(scope.includeNegative) || scope.includeNegative  === 'true') && arr[0] == '-' && arr[1] != 0) {
	                    return;
	                } else if(isNaN(newValue)) {
	                    scope.inputValue = oldValue;
	                } else if(newValue == 0 || newValue == -0) {
	                    if(angular.isDefined(scope.includeZero) && scope.includeZero   === 'true') { 
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