define(['Routing_AppJs_PK'], function(Routing_AppJs_PK) {
    Routing_AppJs_PK.directive('priceOnlyInput', [function() {
        return {
            restrict: 'EA',
            template: '<input id="{{idValue}}" type="text" rel="{{relValue}}" class="{{classValue}} " tab-index="{{tabIndex}}" include-zero="includeZero" ng-disabled="packaged==false|| disabledValue==true" placeholder="{{placeHolderValue}}" ng-model="inputValue" ng-focus="focusValue()" ng-blur="blurValue();setPrecision();blurFunction(param1, param2);" ng-keyup="inputKeyupAction();" ng-change="validatePriceInput();" ng-class="{\'redborder\' : validationModal[validationModalKey][\'isError\'] == true  || addRedBorder}" title="{{validationModal[validationModalKey][\'ErrorMessage\']}}"/>',
            scope: {
                idValue: '@',
                addRedBorder: '=',
                classValue: '@',
                placeHolderValue: '@',
                maxLength: '@',
                maxValue: '@',
                precisionLength: '@',
                relValue: '@',
                inputValue: '=',
                validationModal: '=',
                validationModalKey: '@',
                inputModel: '=',
                blurCallback: '=',
                packaged: '=',
                tabIndex: '@tabIndex',
                allowNegative: '@allowNegative',
                blurValue: '=', 
                formatValue: '=',
                disabledValue: '=',
                inputKeyupAction: '=',
                blurFunction: '&',
                includeZero: '@',
            },
            link: function(scope, el, attrs) {
                scope.inputMaxLength = parseInt(attrs.maxLength) + parseInt(attrs.precisionLength) + 1;
                var oldValue = scope.inputValue;
                scope.focusValue = function() {
                    showToolTip(attrs.relValue);
                }
                scope.validatePriceInput = function() {
                    var newValue = scope.inputValue;
                    var arr = String(newValue).split("");
                    var pieces = String(newValue).split(".");
                    if (arr.length === 0) {
                        oldValue = "";
                        return;
                    }
                    if (arr[0] == '-') {
                        if (!angular.isDefined(scope.allowNegative)) {
                            scope.inputValue = oldValue;
                        } else if (angular.isDefined(scope.allowNegative) && newValue != '-') {
                            if (isNaN(newValue)) {
                                scope.inputValue = oldValue;
                            } else if (attrs.precisionLength == -1 && String(newValue).indexOf(".") != -1) {
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
                    } else if (isNaN(newValue)) {
                        scope.inputValue = oldValue;
                    } else if (newValue > attrs.maxValue && pieces[0].length == attrs.maxLength) { 
                        scope.inputValue = oldValue;
                    } else if (attrs.precisionLength == -1 && String(newValue).indexOf(".") != -1) {
                        scope.inputValue = oldValue;
                    } else if (newValue == 0 || newValue == -0) {
                        if (angular.isDefined(scope.includeZero) && scope.includeZero === 'false') { 
                            scope.inputValue = oldValue;
                        }
                    } else {
                        if (pieces[0].length > attrs.maxLength) {
                            pieces[0] = pieces[0].substring(0, attrs.maxLength);
                        }
                        if (pieces[1] != null && pieces[1] != "" && pieces[1].length > attrs.precisionLength) {
                            pieces[1] = pieces[1].substring(0, attrs.precisionLength);
                        }
                        scope.inputValue = pieces[0] + ((pieces[1] != null && pieces[1] != "") ? ("." + pieces[1]) : ((attrs.precisionLength > 0 && String(newValue).indexOf(".") != -1) ? "." : ""));
                    }
                    var maxValue = parseInt(attrs.maxValue);
                    if (maxValue != undefined && newValue > maxValue) {
                        scope.inputValue = oldValue;
                    }
                    oldValue = scope.inputValue;
                }
                /**
                 * Returns a rounded number in the scope.precisionLength setup by the directive
                 * @param  {Number} num Number to be rounded
                 * @return {Number}     Rounded number
                 */
                function round(num) {
                    var d = Math.pow(10, attrs.precisionLength);
                    return Math.round(num * d) / d;
                }
                /**
                 * Returns a string that represents the rounded number
                 * @param  {Number} value Number to be rounded
                 * @return {String}       The string representation
                 */
                function formatPrecision(value) {
                    return parseFloat(value).toFixed(attrs.precisionLength);
                }
                /**
                 * Method to validate input if is not null
                 *
                 */
                scope.validateInputValue = function() {
                    var validateType = scope.validationModal[scope.validationModalKey].Type;
                    var fieldValue = scope.inputValue;
                    var minValue = scope.validationModal[scope.validationModalKey].Value;
                    if (validateType.indexOf('Required') > -1) {
                        if (fieldValue == undefined || fieldValue == null || fieldValue.length == 0) {
                            scope.validationModal[scope.validationModalKey].isError = true;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = $Label.Field_Is_Required;
                        } else {
                            scope.validationModal[scope.validationModalKey].isError = false;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = '';
                        }
                    } else if (validateType.indexOf('OrderLots') > -1) {
                        if (fieldValue == undefined || fieldValue == null || fieldValue.length == 0) {} else {
                            if (fieldValue < 1) {
                                scope.validationModal[scope.validationModalKey].isError = true;
                                scope.validationModal[scope.validationModalKey].ErrorMessage = $Label.Cannot_Be_less_than_Zero;
                            } else {
                                scope.validationModal[scope.validationModalKey].isError = false;
                                scope.validationModal[scope.validationModalKey].ErrorMessage = '';
                            }
                        }
                    }
                    if (validateType.indexOf('MinValue') > -1) {
                        if (fieldValue <= minValue) {
                            scope.validationModal[scope.validationModalKey].isError = true;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = $Label.Value_must_be_greater_than + ' ' + minValue;
                        } else {
                            scope.validationModal[scope.validationModalKey].isError = false;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = '';
                        }
                    }
                    if (validateType.indexOf('MaxValue') > -1) {
                        if (fieldValue > minValue) {
                            scope.validationModal[scope.validationModalKey].isError = true;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = $Label.Value_must_be_lesser_than + ' ' + minValue;
                        } else {
                            scope.validationModal[scope.validationModalKey].isError = false;
                            scope.validationModal[scope.validationModalKey].ErrorMessage = '';
                        }
                    }
                    if (validateType.indexOf('NotZero') > -1) {
                        if (fieldValue == undefined || fieldValue == null || fieldValue.length == 0) {} else {
                            if (fieldValue == 0) {
                                scope.validationModal[scope.validationModalKey].isError = true;
                                scope.validationModal[scope.validationModalKey].ErrorMessage = $Label.StoreCredits_Zero_Balance_Error_Text;
                            } else {
                                scope.validationModal[scope.validationModalKey].isError = false;
                                scope.validationModal[scope.validationModalKey].ErrorMessage = '';
                            }
                        }
                    }
                    if (scope.validationModal[scope.validationModalKey].isError == true) {
                        scope.inputModel.isValidForm = false;
                    }
                }
                scope.setPrecision = function() {
                    var value = scope.inputValue;
                    if (attrs.precisionLength !== '-1') {
                        if (value) {
                            if (scope.formatValue != undefined && scope.formatValue != null && scope.formatValue == false) {} else {
                                scope.inputValue = formatPrecision(value);
                            }
                            scope.inputValue;
                        }
                    }
                    if (value != 0 && value == "") {
                        scope.inputValue = null;
                    }
                    if (scope.validationModal != undefined && scope.validationModalKey != undefined && scope.validationModal[scope.validationModalKey] != undefined) {
                        scope.validateInputValue();
                    }
                    if (scope.blurCallback != undefined) {
                        scope.blurCallback();
                    }
                }
            }
        };
    }]);
});