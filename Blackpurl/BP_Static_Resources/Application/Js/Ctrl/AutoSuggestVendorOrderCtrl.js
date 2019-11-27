define(['Routing_AppJs_PK', 'AutoSuggestVendorOrderServices', 'tel'], function(Routing_AppJs_PK, AutoSuggestVendorOrderServices, tel) {
    Routing_AppJs_PK.controller('AutoSuggestVendorOrderCtrl', ['$scope', '$sce', '$timeout', 'searchservice', function($scope, $sce, $timeout, searchservice) {
        $scope.titleField = 'Name';
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
        if ($scope.userPause) {
            $scope.pause = $scope.userPause;
        }
        $scope.isNewSearchNeeded = function(newTerm, oldTerm) {
            return newTerm.length >= $scope.minLength && newTerm != oldTerm;
        }
        $scope.GetIntialdata = function() {
            if (!$scope.searchStr) {
                $scope.searchStr = null;
            }
            if ($scope.VORModel == undefined || $scope.VORModel == null || $scope.VORModel == "") {
                $scope.VORModel = {};
            }
            $scope.VORModel.searchDivActive = true;
        }
        $scope.processResults = function(responseData, str) {
            if (responseData && responseData.length > 0) {
                var resultsArray = [];
                var counter = ((responseData.length) > 10 ? 10 : responseData.length);
                var titleFields = [];
                var compareval = 0;
                if ($scope.$parent.FilterID != null || $scope.$parent.FilterID != "") {
                    counter = 0
                    for (var i = 0; i < responseData.length; i++) {
                        if (responseData[i].Info == 'Merchandise') {
                            if (responseData[i].AdditionalDetailsForPart.VendorId == $scope.$parent.FilterID) {
                                var text = '';
                                text = responseData[i][$scope.titleField];
                                if (responseData[i].Description != null) {
                                    text += ' - ' + responseData[i].Description;
                                }
                                var resultRow = {
                                    title: $sce.trustAsHtml(text),
                                    originalObject: responseData[i],
                                    info: responseData[i].Info
                                };
                                resultsArray[resultsArray.length] = resultRow;
                                counter++;
                                if (counter == 10) {
                                    break;
                                }
                            }
                        } else {
                            var text = '';
                            text = responseData[i][$scope.titleField];
                            var resultRow = {
                                title: $sce.trustAsHtml(text),
                                originalObject: responseData[i],
                                info: responseData[i].Info
                            };
                            resultsArray[resultsArray.length] = resultRow;
                            counter++;
                            if (counter == 10) {
                                break;
                            }
                        }
                    }
                } else {
                    for (var i = 0; i < counter; i++) {
                        var text = '';
                        text = responseData[i][$scope.titleField];
                        var resultRow = {
                            title: $sce.trustAsHtml(text),
                            originalObject: responseData[i],
                            info: responseData[i].Info
                        };
                        resultsArray[resultsArray.length] = resultRow;
                    }
                }
                $scope.results = resultsArray;
                compareval = $scope.results.length;
                $scope.actualResults = compareval;
                if (compareval.length > 10) {
                    var AddationalRow = {
                        title: $sce.trustAsHtml(("...and " + (responseData.length - counter).toString() + " other results")),
                        originalObject: " ",
                    };
                    $scope.results.push(AddationalRow);
                }
                if (compareval == 0 && $scope.searchStr) {
                    var AddationalRow = {
                        title: $sce.trustAsHtml(("No other results")),
                        originalObject: " ",
                    };
                    $scope.results.push(AddationalRow);
                }
            } else {
                $scope.results = [];
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
            filterParam = [{
                "Field": "Non_Inventory_Part__c",
                "Value": 'false',
                "FilterObject": "Part__c"
            }];
            var searchQueryJson = {
                "ObjectLabel": ($scope.typeToSearch == undefined) ? "Customer" : $scope.typeToSearch,
                "SearchText": str,
                "PreferredObject": ($scope.PreferredObject == undefined) ? "Customer" : $scope.PreferredObject,
                "SearchableObjects": ($scope.SearchableObjects == undefined) ? "Vendor" : $scope.SearchableObjects,
                "FilterValues": filterParam
            };
            searchQueryJson = JSON.stringify(searchQueryJson);
            var responseData = "";
            searchservice.searchText(searchQueryJson).then(function(successfulSearchResult) {
                responseData = successfulSearchResult;
                $scope.searching = false;
                $scope.processResults((($scope.dataField) ? responseData[$scope.dataField] : responseData));
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                $scope.searching = false;
            });
        }
        $scope.hideResults = function() {
            if ($scope.VORModel == undefined || $scope.VORModel == null || $scope.VORModel == "") {
                $scope.VORModel = {};
            }
            $scope.VORModel.searchDivActive = false;
        }
        $scope.resetHideResults = function() {}
        $scope.hoverRow = function(index) {}
        $scope.keyPressed = function(event) {
            if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                if (!$scope.searchStr || $scope.searchStr == "") {
                    $scope.showDropdown = false;
                    $scope.lastSearchTerm = null;
                } else if ($scope.isNewSearchNeeded($scope.searchStr, $scope.lastSearchTerm)) {
                    $scope.lastSearchTerm = $scope.searchStr;
                    $scope.showDropdown = true;
                    $scope.currentIndex = -1;
                    if ($scope.searchTimer) {
                        $timeout.cancel($scope.searchTimer);
                    }
                    $scope.searching = true;
                    $scope.searchTimer = $timeout(function() {
                        $scope.searchTimerComplete($scope.searchStr);
                    }, $scope.pause);
                }
            } else if (event.which == 13) { 
                var infoString = 'object';
                var isDataAvailable = false;
                if ($scope.results && $scope.results.length > 0 && $scope.actualResults != 0 && !($scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length)) { 
                    if ($scope.results.length > 0) {
                        for (var i = 0; i < $scope.results.length - 1; i++) {  
                            if ($scope.results[i].info.toUpperCase() === infoString.toUpperCase()) {
                                continue;
                            } else {
                                isDataAvailable = true;
                                $scope.selectResult($scope.results[i]);
                                break;
                            }
                        }
                        if (isDataAvailable == false) {
                            $scope.selectResult($scope.results[0]);
                        }
                    }
                    $scope.$apply();
                    event.preventDefault;
                    event.stopPropagation();
                }
            } else {
                event.preventDefault();
            }
        }
        $scope.selectResult = function(result) {
            $scope.showDropdown = false;
            $scope.results = [];
            $scope.searchStr = "";
            if ($scope.SearchToAddCallback == undefined) {
                $scope.$parent.ViewCustomer.selectCallBack(result);
            } else {
                $scope.SearchToAddCallback(result);
            }
        }
        var inputField = angular.element('#SearchToaddCutomer');
        inputField.on('keyup', $scope.keyPressed);
        angular.element('#SearchToAddElement').on("keyup", function(event) {
            if (event.which === 40) {
                if ($scope.results && ($scope.currentIndex + 1) < $scope.results.length) {
                    $scope.currentIndex++;
                    $scope.$apply();
                    var inputFieldEle = angular.element('.angucomplete-row');
                    inputFieldEle.removeClass('angucomplete-selected-rowHover');
                    event.preventDefault;
                    event.stopPropagation();
                }
                $scope.$apply();
            } else if (event.which == 38) {
                if ($scope.currentIndex >= 1) {
                    $scope.currentIndex--;
                    var inputtextField = angular.element('#SearchToaddCutomer');
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
            } else if (event.which == 8) {
                if (($scope.lastSearchTerm == null || $scope.lastSearchTerm == "") && ($scope.testScopeVar == "0")) {
                    $scope.testScopeVar = 1;
                } else if (($scope.lastSearchTerm == null || $scope.lastSearchTerm == "") && ($scope.testScopeVar == "1")) {
                    $scope.testScopeVar = 0;
                }
                $scope.$apply();
            }
        });
    }])
});