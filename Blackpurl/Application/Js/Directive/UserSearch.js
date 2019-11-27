define(['Routing_AppJs_PK', 'UserSearchServices'], function (Routing_AppJs_PK, UserSearchServices) {

    Routing_AppJs_PK.directive('usersearch', ['$sce', '$timeout', 'UserSearchSuggestionService', function ($sce, $timeout, UserSearchSuggestionService) {
        return {
            restrict: 'EA',
            scope: {
                "id": "@id",
                "typesearchmodal": "=",
                "titleField": "@titlefield",
                "placeholder": "@placeholder",
                "tabIndex": "@tabIndex",
                "addClass": "@addClass",
                "ownerModel": "="
            },
            template: '<div class="angucomplete-holder {{addClass}}" id="{{id}}" >' +
                '<div class="form-control form-control-small"  data-toggle="tooltip">' +
                '<input  id="{{id}}_Input" ng-model="typesearchmodal" class="anguinput " ng-attr-tabindex="{{tabIndex}}"  ng-focus="getintialdata()" ng-blur="setselecteddata()" type="text" placeholder="{{placeholder}}" style="width: 100%;" />' +
                '</div>' +
                '<div id="SearchToaddCutomerSuggestions" class="angucomplete-dropdown" ng-if="showDropdown">' +
                '<div class="angucomplete-searching" ng-show="searching">Searching...</div>' +
                '<div class="angucomplete-searching" ng-show="!searching && (!results || results.length == 0)">No results found</div>' +
                '<div  class="angucomplete-row" ng-repeat="result in results" ng-click="selectResult(result)"' +
                ' ng-mouseover="hoverRow($index)" ng-class="{\'angucomplete-selected-row\': $index == currentIndex}"' +
                '<div id="SearchResult_{{$index}}" class="angucomplete-title col-lg-8"  ng-bind="result.title"></div>' +
                '</div>' +
                '</div>' +
                '</div>',

            link: function ($scope, elem, attrs) {
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
                $scope.getintialdata = function () {
                    $scope.currentIndex = null;
                    $scope.showDropdown = false;
                    $scope.results = [];
                    $scope.searching = false;
                    setTimeout(function () {
                        angular.element('[data-toggle="tooltip"]').tooltip({
                            placement: 'bottom'
                        });
                    }, 10);
                }

                $scope.setselecteddata = function () {
                    $scope.selectResult($scope.results[$scope.currentIndex]);
                    $scope.currentIndex = null;
                }

                if ($scope.userPause) {
                    $scope.pause = $scope.userPause;
                }

                $scope.isNewSearchNeeded = function (newTerm, oldTerm) {
                    return newTerm.length >= $scope.minLength && newTerm != oldTerm
                }

                $scope.processResults = function (responseData, str) {
                    if (responseData.length > 0) {
                        if (responseData && responseData.length > 0) {
                            $scope.results = [];
                            var counter = ((responseData.length) > 10 ? 10 : responseData.length);
                            var titleFields = [];
                            var compareval = 0;

                            for (var i = 0; i < counter; i++) {
                                var text = '';
                                text = responseData[i][$scope.titleField];
                                var resultRow = {
                                    title: $sce.trustAsHtml(text),
                                    originalObject: responseData[i],
                                }
                                $scope.results[$scope.results.length] = resultRow;
                            }
                        }
                    }
                }

                $scope.searchTimerComplete = function (str) {
                    if (str != null) {
                        if (str.length >= $scope.minLength) {
                            $scope.SearchSuggestion(str);
                        }
                    } else {
                        $scope.SearchSuggestion("");
                    }
                }

                $scope.SearchSuggestion = function (str) {
                    var searchQueryJson = {
                        "ObjectLabel": "User",
                        "SearchText": str,
                        "PreferredObject": "User",
                        "FilterValues": null
                    }

                    searchQueryJson = JSON.stringify(searchQueryJson);
                    var responseData = "";

                    UserSearchSuggestionService.searchText(searchQueryJson)
                        .then(function (successfulSearchResult) {
                            responseData = successfulSearchResult;
                            $scope.searching = false;
                            $scope.processResults((($scope.dataField) ? responseData[$scope.dataField] : responseData));

                        }, function (errorSearchResult) {
                            responseData = errorSearchResult;
                            $scope.searching = false;
                        });
                }

                $scope.hideResults = function () {}
                $scope.resetHideResults = function () {}

                $scope.hoverRow = function (index) {
                    var inputFieldEle = elem.find('.angucomplete-row');
                    inputFieldEle.addClass('angucomplete-selected-rowHover');
                    $scope.currentIndex = index;
                }

                $scope.keyPressed = function (event) {
                    $scope.searchStr = $scope.typesearchmodal;
                    if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                        if (!$scope.searchStr || $scope.searchStr == "") {
                            $scope.showDropdown = false;
                            $scope.lastSearchTerm = null
                        } else if ($scope.isNewSearchNeeded($scope.searchStr, $scope.lastSearchTerm)) {
                            $scope.lastSearchTerm = $scope.searchStr;
                            $scope.showDropdown = true;
                            $scope.currentIndex = -1;
                            $scope.results = [];
                            if ($scope.searchTimer) {
                                $timeout.cancel($scope.searchTimer);
                            }
                            $scope.searching = true;
                            $scope.searchTimer = $timeout(function () {
                                $scope.searchTimerComplete($scope.searchStr);
                            }, $scope.pause);
                        }
                    } else {
                        event.preventDefault();
                    }
                }

                $scope.selectResult = function (result) {
                    $scope.showDropdown = false;
                    $scope.results = [];
                    if (typeof result != 'undefined') {
                        $scope.typesearchmodal = $scope.searchStr = $scope.lastSearchTerm = result.title;
                        $scope.$emit('userSelectCallBack', {
                            SearchResult: result
                        });
                    }
                }

                var inputField = elem.find('input');
                inputField.on('keyup', $scope.keyPressed);

                elem.on("keyup", function (event) {
                    if (event.which === 40) {
                        if ($scope.results && ($scope.currentIndex + 1) < $scope.results.length) {
                            $scope.currentIndex++;
                            $scope.$apply(); //FIXME
                            var inputFieldEle = elem.find('.angucomplete-row');
                            inputFieldEle.removeClass('angucomplete-selected-rowHover');
                            event.preventDefault;
                            event.stopPropagation();
                        }
                        $scope.$apply();
                    } else if (event.which == 38) {
                        if ($scope.currentIndex >= 1) {
                            $scope.currentIndex--;
                            var inputtextField = elem.find('input');
                            $scope.$apply(); //FIXME
                            event.preventDefault;
                            event.stopPropagation();
                        }
                    } else if (event.which == 13) {
                        if ($scope.results && $scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length) {
                            $scope.selectResult($scope.results[$scope.currentIndex]);
                            $scope.$apply(); //FIXME
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