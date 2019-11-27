define(['Routing_AppJs_PK', 'AutoCompleteServices'], function(Routing_AppJs_PK, AutoCompleteServices) {
    Routing_AppJs_PK.directive('autocompleteNew', ['$sce', '$timeout', 'newAutoCompleteSuggestionService', function($sce, $timeout, newAutoCompleteSuggestionService) {
        return {
            restrict: 'EA',
            scope: {
                "id": "@id",
                "placeholder": "@placeholder",
                "validationkey": "@validationkey",
                "typeToSearch": "@type",
                "titleField": "@titlefield",
                "errorclass": "=",
                "typesearchmodal": "=",
                "relValue": "@relValue",
                "tabIndex": "@tabIndex",
                "filterParam": "=",
                "searchFieldName": "=",
                "selectedObject": "=selectedobject",
                "source": "=source",
            },
            template: '<div class="angucomplete-holder selectCustomerAutoComplete" id="{{id}}">' + '<div class="form-control form-control-small"  ng-class="{\'ErrorBox\': errorclass[validationkey].isError == true}"  title="{{errorclass[validationkey].ErrorMessage}}"  data-toggle="tooltip">' + '<input  id="{{id}}_Input" ng-model="typesearchmodal" class="anguinput" ng-attr-tabindex="{{tabIndex}}"  ng-focus="getintialdata()" ng-blur="setselecteddata()" rel="{{relValue}}"  type="text" placeholder="{{placeholder}}" style="width: 100%;" /><i class="fa fa-search fa-select-customer fa-flip-horizontal"></i>' + '</div>' + '<div id="SearchToaddCutomerSuggestions" class="angucomplete-dropdown" ng-if="showDropdown">' + '<div class="angucomplete-searching" ng-show="searching">Searching...</div>' + '<div class="angucomplete-searching noResultFound" ng-show="!searching && (!results || results.length == 0 || (results.length == 1 && (results[0].title == \'+ CREATE CUSTOMER\' || results[0].title == \'+ CREATE VENDOR\')))">No results found</div>' + '<div  ng-repeat="result in results">' + '<div  class="col-md-12" ng-click="selectResult(result)" ng-mouseover="hoverRow($index)"' + 'ng-class="{\'select-angucomplete-row\': (result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\') && result.title != otherResults, \'select-angucomplete-selected-row\': $index == currentIndex && (result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\') && result.title != otherResults,\'select-angucomplete-border-Bottom-None\':  (result.title == \'+ CREATE CUSTOMER\' || result.title == \'+ CREATE VENDOR\' || result.title == otherResults)}">' + '<div id="SearchResult_{{$index}}" class="angucomplete-title col-lg-12 P0" >' + '<p class = "col-md-9 breakWord M0 P0" ng-class="{\'angucomplete-selected-text\': result.description == \'AdditionalInfo\',\'angucomplete-selected-border\': result.description == \'AdditionalResult\', \'SearchItemName\':(result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\') && result.title != otherResults, \'results\':result.title == otherResults}"> <i ng-if = "result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\' && result.title != otherResults && typeToSearch == \'Customer\'" class = " pull-left fa fa-users FC7 F18"></i>' + '<i ng-if = "result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\' && result.title != otherResults && typeToSearch == \'Vendor\'" class = " pull-left fa fa-industry FC7 F18"></i>' + '<span ng-if = "(result.title != \'+ CREATE CUSTOMER\') && (result.title != \'+ CREATE VENDOR\')">{{result.title}}</span>' + '<button class="btn T4 blueBtnAdd" ng-class="{\'MT\': results.length<=6}" ng-click="" ng-if = "result.title == \'+ CREATE CUSTOMER\'">Create Customer</button>' + '<button class="btn T4 blueBtnAdd" ng-class="{\'MT\': results.length<=6}" ng-click="" ng-if = "result.title == \'+ CREATE VENDOR\'">Create Vendor</button>' + '</p>' + '<div class="row" ng-if = "(result.title != \'+ CREATE CUSTOMER\' && result.title != \'+ CREATE VENDOR\') && result.title != otherResults">' + '<div class="col-md-12 customerAdditionalInfo"><span ng-if = "result.originalObject.Email != \'\' && result.originalObject.Email != null"><span class="AdditionalInfoLabel" >Email: </span>' + '<span class="AdditionalInfo  breakWord" ng-class="{\'angucomplete-selected-text\': result.description == \'AdditionalInfo\' ,\'angucomplete-selected-border\': result.description == \'AdditionalResult\'}" ng-bind="result.originalObject.Email"></span></span>' + '<span ng-if = "result.originalObject.Phone != \'\' && result.originalObject.Phone != null && result.originalObject.Email != \'\' && result.originalObject.Email != null">, </span>' + '<span  ng-if = "result.originalObject.Phone != \'\' && result.originalObject.Phone != null"><span class="AdditionalInfoLabel">Phone: </span>' + '<span class="AdditionalInfo " ng-class="{\'angucomplete-selected-text\': result.description == \'AdditionalInfo\',\'angucomplete-selected-border\': result.description == \'AdditionalResult\'}" ng-bind="(result.originalObject.Phone | tel)"></span></span>' +
                '</div></div></div></div>',
            link: function($scope, elem, attrs) {
                $scope.lastSearchTerm = null;
                $scope.currentIndex = null;
                $scope.justChanged = false;
                $scope.searchTimer = null;
                $scope.hideTimer = null;
                $scope.searching = false;
                $scope.pause = 500;
                $scope.minLength = 3;
                $scope.searchStr = null;
                $scope.UserDetails = null;
                $scope.getintialdata = function() {
                    $scope.currentIndex = null;
                    $scope.showDropdown = false;
                    $scope.results = [];
                    $scope.searching = false;
                    setTimeout(function() {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'bottom'
                        });
                    }, 10);
                }
                $scope.setselecteddata = function() {
                    
                    $scope.currentIndex = null;
                }
                if ($scope.userPause) {
                    $scope.pause = $scope.userPause;
                }
                $scope.isNewSearchNeeded = function(newTerm, oldTerm) {
                    return newTerm.length >= $scope.minLength && newTerm != oldTerm;
                }
                $scope.processResults = function(responseData, objectType) {
                    if (responseData.length >= 0) {
                        if (responseData && responseData.length >= 0) {
                            $scope.results = [];
                            var counter = ((responseData.length) > 5 ? 5 : responseData.length);
                            var titleFields = [];
                            var compareval = 0;
                            for (var i = 0; i < counter; i++) {
                                var text = '';
                                text = responseData[i][$scope.titleField];
                                var resultRow = {
                                    title: $sce.trustAsHtml(text),
                                    originalObject: responseData[i],
                                };
                                $scope.results[$scope.results.length] = resultRow;
                            }
                            if (responseData.length > 5) {
                                var otherResultText = ' other results';
                                if (responseData.length == 6) {
                                    otherResultText = ' other result';
                                }
                                var AddationalRow = {
                                    title: "...and " + (responseData.length - counter).toString() + otherResultText,
                                    description: "AdditionalResult",
                                    image: "",
                                    originalObject: " ",
                                };
                                $scope.otherResults = AddationalRow.title;
                                $scope.results.push(AddationalRow);
                            }
                            if (objectType == 'Vendor' && $scope.source != 'Return Vendor Order') {
                                $scope.results.push({
                                    title: "+ CREATE VENDOR",
                                    originalObject: " ",
                                    description: "AdditionalInfo",
                                });
                            } else if (objectType == 'Customer') {
                                $scope.results.push({
                                    title: "+ CREATE CUSTOMER",
                                    originalObject: " ",
                                    description: "AdditionalInfo",
                                });
                            }
                        }
                    }
                }
                $scope.searchTimerComplete = function(str) {
                    if (str != null) {
                        if (str.length >= $scope.minLength) {
                            $scope.SearchSuggestion(str);
                        }
                    } else {
                        $scope.SearchSuggestion("");
                    }
                }
                $scope.SearchSuggestion = function(str) {
                    var searchQueryJson = {
                        "ObjectLabel": $scope.typeToSearch,
                        "SearchText": str,
                        "SearchFieldName": $scope.searchFieldName,
                        "FilterValues": [{
                            'Field': 'Active__c',
                            'Value': true,
                            'Operator': '='
                        }]
                    };
                    if ($scope.filterParam != undefined && $scope.filterParam.length > 0) {
                        searchQueryJson["FilterValues"] = searchQueryJson["FilterValues"].concat($scope.filterParam);
                    }
                    searchQueryJson = JSON.stringify(searchQueryJson);
                    var responseData = "";
                    newAutoCompleteSuggestionService.searchText(searchQueryJson).then(function(successfulSearchResult) {
                        responseData = successfulSearchResult.CustomerList;
                        $scope.searching = false;
                        $scope.processResults((($scope.dataField) ? responseData[$scope.dataField] : responseData), $scope.typeToSearch);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        $scope.searching = false;
                    });
                }
                $scope.hideResults = function() {}
                $scope.resetHideResults = function() {}
                $scope.hoverRow = function(index) {
                    var inputFieldEle = elem.find('.select-angucomplete-row');
                    $scope.currentIndex = index;
                    inputFieldEle.addClass('select-angucomplete-selected-rowHover');
                }
                $scope.keyPressed = function(event) {
                    $scope.searchStr = $scope.typesearchmodal;
                    if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                        if (!$scope.searchStr || $scope.searchStr == "") {
                            $scope.showDropdown = false;
                            $scope.lastSearchTerm = null;
                        } else if ($scope.isNewSearchNeeded($scope.searchStr, $scope.lastSearchTerm)) {
                            $scope.lastSearchTerm = $scope.searchStr;
                            $scope.showDropdown = true;
                            $scope.currentIndex = -1;
                            $scope.results = [];
                            if ($scope.searchTimer) {
                                $timeout.cancel($scope.searchTimer);
                            }
                            $scope.searching = true;
                            $scope.searchTimer = $timeout(function() {
                                $scope.searchTimerComplete($scope.searchStr);
                            }, $scope.pause);
                        }
                    } else {
                        event.preventDefault();
                    }
                }
                $scope.selectResult = function(result) {
                    if (typeof result != 'undefined') {
                        $scope.typesearchmodal = $scope.searchStr = $scope.lastSearchTerm = result.title;
                    }
                    $scope.showDropdown = false;
                    $scope.results = [];
                    if ($scope.typesearchmodal == "") {
                        result = {
                            originalObject: {
                                Name: "",
                                Value: null
                            }
                        };
                    } else if (typeof result != 'undefined' && result["title"] != "+ CREATE CUSTOMER" && result["title"] != "+ CREATE VENDOR") {
                        $scope.$emit('autoCompleteSelectCustomerCallback', {
                            ObejctType: $scope.typeToSearch,
                            SearchResult: result,
                            ValidationKey: $scope.validationkey,
                            Index: $scope.id
                        });
                        $scope.typesearchmodal = "";
                    } else if (typeof result != 'undefined' && result["title"] == "+ CREATE CUSTOMER") {
                        $scope.searchStr = "";
                        $scope.typesearchmodal = "";
                        $scope.selectedObject.CreateCustomerFromCO();
                    } else if (typeof result != 'undefined' && result["title"] == "+ CREATE VENDOR") { 
                        $scope.searchStr = "";
                        $scope.typesearchmodal = "";
                        $scope.selectedObject.CreateNewVendorFromVendorPopUp();
                    } else {
                        $scope.$emit('autoCompleteSelectCustomerCallback', {
                            ObejctType: $scope.typeToSearch,
                            SearchResult: null,
                            ValidationKey: $scope.validationkey,
                            Index: $scope.id
                        });
                    }
                }
                var inputField = elem.find('input');
                inputField.on('keyup', $scope.keyPressed);
                elem.on("keyup", function(event) {
                    if (event.which === 40) {
                        if ($scope.results && ($scope.currentIndex + 1) < $scope.results.length) {
                            $scope.currentIndex++;
                            $scope.$apply();
                            var inputFieldEle = elem.find('.select-angucomplete-row');
                            inputFieldEle.removeClass('select-angucomplete-selected-rowHover');
                            event.preventDefault;
                            event.stopPropagation();
                        }
                        $scope.$apply();
                    } else if (event.which == 38) {
                        if ($scope.currentIndex >= 1) {
                            $scope.currentIndex--;
                            var inputtextField = elem.find('input');
                            $scope.$apply();
                            event.preventDefault;
                            event.stopPropagation();
                        }
                    } else if (event.which == 13) {
                        if ($scope.results && $scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length) {
                            $scope.selectResult($scope.results[$scope.currentIndex]);
                            $scope.$apply();
                            event.preventDefault;
                            event.stopPropagation();
                        } else {
                            $scope.showDropdown = true;
                            event.preventDefault;
                            event.stopPropagation();
                        }
                    } else if (event.which == 27) {
                        $scope.results = [];
                        $scope.showDropdown = false;
                        $scope.$apply();
                    } else if (event.which == 9) {
                        $scope.results = [];
                        $scope.showDropdown = false;
                        $scope.currentIndex = null;
                        $scope.$apply();
                    }
                });
            }
        };
    }]);
});