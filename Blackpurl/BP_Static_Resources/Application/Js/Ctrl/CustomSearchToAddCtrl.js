define(['Routing_AppJs_PK', 'CustomSearchToAddServices'], function(Routing_AppJs_PK, CustomSearchToAddServices) {
    Routing_AppJs_PK.controller("CustomSearchToAddCtrl", ['$q', '$scope', '$rootScope', '$stateParams', '$state', '$parse', '$sce', '$timeout', 'searchservice', function($q, $scope, $rootScope, $stateParams, $state, $parse, $sce, $timeout, searchservice) {
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
            if (!$scope.searchStr || $scope.searchStr == null) {
                $scope.searchStr = "";
                responseData = [];
                $scope.showDropdown = true;
                $scope.processResults(responseData, $scope.searchStr);
            }
            if ($scope.searchStr != null && !$scope.searchStr && $scope.searchStr.length <= 2 && $scope.SelectedObjectValue != null && $scope.SelectedObjectValue != '' && $scope.SelectedObjectValue != undefined) {
                $scope.showDropdown = false;
            }
        }
        $scope.hideDropdown = function() {
            setTimeout(function() {
                $scope.showDropdown = false;
            }, 10);
        }
        $scope.processResults = function(responseData, str) {
            var resultsArray = [];
            if (!($scope.SelectedObjectValue != null && $scope.SelectedObjectValue != '' && $scope.SelectedObjectValue != undefined)) {
                for (i = 0; i < $scope.SearchableObjectsModal.length; i++) {
                    var strToMatch = $scope.SearchableObjectsModal[i].Name.toLowerCase();
                    if (str == null || str == '' || (strToMatch.indexOf(str.toLowerCase()) > -1)) {
                        resultsArray.push({
                            title: $scope.SearchableObjectsModal[i].Name,
                            originalObject: "",
                            ObjectType: "Object",
                            info: "Object"
                        });
                    }
                }
            }
            if (responseData && responseData.length > 0) {
                var counter = ((responseData.length) > 10 ? 10 : responseData.length);
                var titleFields = [];
                var compareval = 0;
                for (var i = 0; i < counter; i++) {
                    if (responseData[i].Info != "Object") {
                        var text = '';
                        text = responseData[i][$scope.titleField];
                        if (responseData[i].Description != null) {
                            text += ' - ' + responseData[i].Description;
                        }
                        var resultRow = {
                            title: $sce.trustAsHtml(text),
                            originalObject: responseData[i],
                            ObjectType: "Record",
                            info: responseData[i].Info
                        }
                        resultsArray[resultsArray.length] = resultRow;
                    }
                }
                if (responseData.length > 10) {
                    var AddationalRow = {
                        title: $sce.trustAsHtml(("...and " + (responseData.length - counter).toString() + " other results")),
                        originalObject: " ",
                        ObjectType: "Custom"
                    }
                    resultsArray.push(AddationalRow);
                }
                resultsArray.push({
                    title: $sce.trustAsHtml("+ Add New"),
                    originalObject: " ",
                    ObjectType: "Custom"
                });
            }
            $scope.results = resultsArray;
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
                "ObjectLabel": ($scope.typeToSearch == undefined) ? "Customer" : $scope.typeToSearch,
                "SearchText": str,
                "PreferredObject": ($scope.PreferredObject == undefined) ? "Customer" : $scope.PreferredObject,
                "SearchableObjects": ($scope.SearchableObjects == undefined) ? "" : $scope.SearchableObjects
            }
            searchQueryJson = JSON.stringify(searchQueryJson);
            var responseData = "";
            searchservice.searchText(searchQueryJson).then(function(successfulSearchResult) {
                responseData = successfulSearchResult;
                $scope.searching = false;
                $scope.processResults((($scope.dataField) ? responseData[$scope.dataField] : responseData), $scope.searchStr);
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                $scope.searching = false;
            });
        }
        $scope.hideResults = function() {}
        $scope.resetHideResults = function() {}
        $scope.hoverRow = function(index) {}
        $scope.keyPressed = function(event) {
            if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                if (!$scope.searchStr || $scope.searchStr == "") {
                    $scope.showDropdown = false;
                    $scope.lastSearchTerm = null
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
            } else if (event.which == 13) { // for selecting first result on pressing enter without selecting any result
                var infoString = 'object';
                var isDataAvailable = false;
                if ($scope.results && $scope.results.length > 0 && !($scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length)) {
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
                    $scope.$apply(); //FIXME
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
                $scope.SearchToAddCallback(result);
            } else {
                $scope.SearchToAddCallback(result);
            }
        }
        var inputField = angular.element('#SearchToAddKit');
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
                    var inputtextField = angular.element('#SearchToAddKit');
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
                if (!$scope.searchStr) {
                    $scope.SetDetfault();
                }
                $scope.$apply();
            }
        });
    }]);
});