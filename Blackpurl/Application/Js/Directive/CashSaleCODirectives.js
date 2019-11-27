define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	
	Routing_AppJs_PK.directive('numberOnlyInputCashSale', [function() {
		return {
            restrict: 'EA',
            template: '<input type="text" onfocus="this.select();" class="{{classVal}}" ng-model="inputValue" id="{{idVal}}" ng-disabled="disableAttr" tabindex="{{tabIndex}}" ng-focus="focus" ng-blur="blur"/>',
            scope: {
                inputValue: '=',
                "idVal": "@idVal",
                "classVal": "@classVal",
                "tabIndex": "@tabIndex",
                "disableAttr": '=',
                "focus": '=',
                "blur": '=',
                "includeNegative": "=includeNegative",
                "includeZero": "@includeZero"
            },
            
            link: function(scope, element, attrs) {
        		scope.$watch('idVal', function(id) {
	        		 angular.element('#'+scope.idVal).bind('focus', function()	{
	        			if(scope.idVal == 'saleQuantityContent')	{
		            			scope.$parent.CashSaleModel.editedLineItemAttributeId = 'quantity_' + scope.$parent.CashSaleModel.editLineItemIndex;
		            			scope.$apply(); //TODO
	        			} else if(scope.idVal == 'editSalePrice')	{
			            		scope.$parent.CashSaleModel.editedLineItemAttributeId = 'price_' + scope.$parent.CashSaleModel.editLineItemIndex;
				            	scope.$apply();
	        			}
        				
        			}); 
        			
        			angular.element('#'+scope.idVal).bind('blur', function()	{
        					scope.$parent.CashSaleModel.editedLineItemAttributeId = '';
        					scope.$apply();
        			}); 
	        	});		
	        			
        		
        		
                scope.$watch('inputValue', function(newValue, oldValue) {
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
		 			if(pieces[1] == "" && pieces.length ==2 ){ 
						scope.inputValue = newValue; 
						return;
                    }
                    if (arr.length === 0) {
                    	return;
                    }
                    
                    if(angular.isDefined(scope.includeNegative) && scope.includeNegative == false)	{
                    	if (arr[0] == '-')	{
                    		scope.inputValue = oldValue;
                    		return;
                    	}
                    }
                    
                    if (arr[0] == '-' && arr[1] != 0) {
                        return;
                    } else if (isNaN(newValue)) {
                        if(oldValue == "undefined" || isNaN(oldValue)){
                        	scope.inputValue = "";
                        } else	{
                        	scope.inputValue = oldValue;
                        }
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