define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.directive('numbersOnly', [function() {
		return {
			restrict : 'EA',
			template : '<input type="text" onfocus="this.select();" id="{{idValue}}" class="{{classValue}}" placeholder="{{placeHolderValue}}" ' + 
						'max-length="{{maxLength}}" max-value="{{maxValue}}" min-value="{{minValue}}" ng-model="inputModelValue"' + 
						'rel="{{relValue}}" ng-attr-tabindex="{{tabIndex}}" ng-keydown="blurHandlingOnTab($event); inputKeydownValue({$event: $event});"' + 
						'ng-disabled="disabledValue" ng-focus="focusValue()" ng-keyup="inputKeyupValue({$event: $event})" ng-blur="setInputValueOnBlur();blurValue({$event: $event});" ng-class="ngClassName"/>',
			scope : {
				idValue : '@',
				classValue : '@',
				ngClassName : '=',
				placeHolderValue : '@',
				maxLength : '@',
                maxValue : '@',
				minValue : '@',
                defaultValue : '@', //Edited - should be equal to or greater than min value
				inputModelValue : '=',
				includeNegative :'=',
				includeZero :'=',
				includeBlank: '=',
				precisionLength : '@',
				forcePrecisionLength : '=',
				relValue : '@',
				tabIndex : '@tabIndex',
				disabledValue : '=',
				focusValue : '&',
				blurValue : '&' ,
				inputKeyupValue : '&',
				inputKeydownValue: '&'
			},
			
			link : function (scope, el, attrs) {
				scope.$watch('inputModelValue', function(newValue,oldValue) {
					scope.validateNumberInput(newValue,oldValue);
				});
				
				scope.validateNumberInput = function (newValue,oldValue) {
					var arr = String(newValue).split("");
					var pieces = String(newValue).split(".");
					if(!newValue)	{ /* When newValue is reset with (''/undefined/null) value of oldValue based on below conditions, 
										the watch runs again and goes to infinte loop using isNaN(newValue) condition; 
										so simply return when newValue is undefined/''/null and keep value as it is */
						return;
					}
					
					scope.checkForIncludeZero(arr, pieces, newValue, oldValue);
					scope.checkForIncludeNegative(arr, newValue, oldValue);
					scope.checkForPrecisionLength(arr, pieces, newValue, oldValue);
					scope.checkForInputNumberValidity(arr, pieces, newValue, oldValue);
					scope.checkForMaxMinValueValidity(oldValue);
					scope.checkForMaxLength(oldValue);
				}		
				
				// Check For includeZero in a number
				scope.checkForIncludeZero = function(arr, pieces, newValue,oldValue) {
					if(angular.isDefined(scope.precisionLength) && scope.precisionLength > 0) { //if number can contain decimal values then validate input value for 0 only when entering last digit of decimal place
						if(angular.isDefined(scope.includeZero) && scope.includeZero === false && pieces.length === 2 && pieces[1].length == scope.precisionLength)	{ //if number can't be equal to 0
							if(newValue == 0 || (newValue == '-0' && (!angular.isDefined(scope.includeNegative) || scope.includeNegative === false))) { //if number is equals to 0 or -0(even when -ve is not allowed) then reset it with old value 
								scope.inputModelValue = oldValue;
								return;
							}
						}
					} else { //if number can't contain decimal values then validate input value for 0 everytime when user enters
						if(angular.isDefined(scope.includeZero) && scope.includeZero === false)	{ //if number can't be equal to 0
							if(newValue == 0 || newValue == '-0') { //if number is equals to 0 or -0 then reset it with old value 
								scope.inputModelValue = oldValue;
								return;
							}
						}
					}
				}
				
				// Check For includeNegative in a number
				scope.checkForIncludeNegative = function(arr, newValue,oldValue) {
					if(angular.isDefined(scope.includeNegative) && scope.includeNegative === true) { //if number can contain -ve values
						if(String(newValue).indexOf('-0') != -1 && (!angular.isDefined(scope.precisionLength) || scope.precisionLength == -1 || scope.precisionLength == 0)) { //if number contains -0 and also can't contain decimal values, then reset it with old value
							scope.inputModelValue = oldValue;
							return;
						}
					} else if(!angular.isDefined(scope.includeNegative) || scope.includeNegative === false) { //if number only can contains only +ve values
						if(arr[0] === '-') { //if starting char is - then reset it with oldValue
							scope.inputModelValue = oldValue;
							return;
						}
					}
				}
				
				// Check For precision length in a number
				scope.checkForPrecisionLength = function(arr, pieces, newValue, oldValue) {
					if(angular.isDefined(scope.precisionLength) && scope.precisionLength > 0) { //if number can contain decimal values
						if(pieces.length > 2) { //if number cantains more than one '.' then reset it with old value 
							scope.inputModelValue = oldValue;
							return;
						} else if(pieces.length === 2 && (isNaN(pieces[0]) || isNaN(pieces[1]))) { /* if number cantains valid '.' then if the value before or after '.' is 
																									invalid then number then reset it with old value */
							scope.inputModelValue = oldValue;
							return;
						} else if(pieces.length === 2 && (pieces[1].length > scope.precisionLength)) { /* if number cantains valid '.' and value length after '.' is 
																											greater than given precisionLength
																											then reset it with old value */
							scope.inputModelValue = oldValue;
							return;
						}
					}else if(!angular.isDefined(scope.precisionLength) || scope.precisionLength == -1 || scope.precisionLength == 0) { //if number can't contain decimal values
						if(String(newValue).indexOf('.') != -1)	{	//if new value contains '.' at any place then reset it with old Integer value
							scope.inputModelValue = oldValue;
							return;
						}
					}
				}
				
				// isNaN check to validate final input model value
				scope.checkForInputNumberValidity = function(arr, pieces, newValue, oldValue) {
					if(angular.isDefined(scope.includeNegative) && scope.includeNegative === true && arr.length === 1 && arr[0] === '-') { 
						return;
					}else if(angular.isDefined(scope.precisionLength) && scope.precisionLength > 0 && arr.length === 1 && arr[0] === '.') {
						return;
					}else if(isNaN(scope.inputModelValue)) {
						scope.inputModelValue = oldValue;
						return;
					}
				}
				
				scope.checkForMaxMinValueValidity = function(oldValue) { // Edited
					if(angular.isDefined(scope.maxValue) && (parseFloat(scope.inputModelValue) > parseFloat(scope.maxValue))) {
						scope.inputModelValue = oldValue;
						return;
					}
				}
                
				scope.checkForMaxLength = function(oldValue) {
					scope.maxLength = parseInt(scope.maxLength);
					if(angular.isDefined(scope.maxLength) && scope.maxLength > 0 && String(parseInt(scope.inputModelValue)).length > scope.maxLength) {
						scope.inputModelValue = oldValue;
						return;
					}
				}
				
                scope.blurHandlingOnTab = function(event) {
					if(event.keyCode === 9) {
						scope.setInputValueOnBlur();
					}
				}
				
				// Set Input model value On Blur of Input text box
				scope.setInputValueOnBlur = function() {
					if((angular.isDefined(scope.includeBlank) && scope.includeBlank === true) && (scope.inputModelValue === '' || scope.inputModelValue === undefined || scope.inputModelValue === null
							|| scope.inputModelValue === '-' || scope.inputModelValue === '.'))	{
						scope.inputModelValue = '';
					} else	{
                        if(scope.inputModelValue == '' || scope.inputModelValue == undefined || scope.inputModelValue == null
                            || scope.inputModelValue == '-' || scope.inputModelValue == '.') {
                            if(angular.isDefined(scope.defaultValue))	{
                        		scope.inputModelValue = scope.defaultValue;
                        	}else if(angular.isDefined(scope.includeZero) && scope.includeZero === false) {
                                if(angular.isDefined(scope.minValue) && scope.minValue)	{
                                    scope.inputModelValue = scope.minValue;
                                }else{
                                    scope.inputModelValue = 1;
                                }
                            }else	{
                                if(angular.isDefined(scope.minValue) && scope.minValue)	{
                                    scope.inputModelValue = scope.minValue;
                                }else{
                                    scope.inputModelValue = 0;
                                }
                            }
                        }
						
                        // validate whole input value for the include 0 & min value on tab out
                        else if(angular.isDefined(scope.includeZero) && scope.includeZero === false && (scope.inputModelValue == 0 || parseFloat(scope.inputModelValue) == -0))	{ //if number can't be equal to 0 & whole number is equals to 0 or -0 then reset it either with default value, with 1 or with min value
							if(angular.isDefined(scope.defaultValue)) {
                        		scope.inputModelValue = scope.defaultValue;
                        	} else if(angular.isDefined(scope.minValue) && scope.minValue) {
                                scope.inputModelValue = scope.minValue;
                            } else {
                                scope.inputModelValue = 1;
                            }
						} else if((angular.isDefined(scope.minValue) && scope.minValue) && (parseFloat(scope.inputModelValue) < parseFloat(scope.minValue))) {//if whole number is less than min value then reset it with min value 
							scope.inputModelValue = scope.minValue;
						} 
                        
                        if(angular.isDefined(scope.precisionLength) && scope.precisionLength > 0 && (!angular.isDefined(scope.forcePrecisionLength) || scope.forcePrecisionLength == true))	{
                            scope.inputModelValue = parseFloat(scope.inputModelValue).toFixed(scope.precisionLength);
                            var finalPieces = String(scope.inputModelValue).split(".");
                            if(finalPieces[0] == '')	{
                                if(angular.isDefined(scope.minValue) && scope.minValue)	{
                                    finalPieces[0] = scope.minValue;
                                }else{
                                    finalPieces[0] = 0;
                                }
                            }

                            if(finalPieces[1] == '') {
                                finalPieces[1] = 0;
                            }
                            scope.inputModelValue = finalPieces[0] + '.' + finalPieces[1];
                            scope.inputModelValue = parseFloat(scope.inputModelValue).toFixed(scope.precisionLength);
                        }
                    }
				}
			}
		};
    }]);
});   