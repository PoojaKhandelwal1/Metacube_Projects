define(['Routing_AppJs_PK', 'CashSaleSTAServices', 'CashSaleCODirectives', 'shouldFocus'], function(Routing_AppJs_PK, CashSaleSTAServices, CashSaleCODirectives, shouldFocus) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CashSaleSTACtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', '$window', '$document', 'searchService', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, $window, $document, searchService) {
        var Notification = injector1.get("Notification");
        $scope.CashSaleModel = {};
        $scope.CashSaleModel.searchTimer = null;
        $scope.CashSaleModel.searchTerm = '';
        $scope.CashSaleModel.lastSearchTerm = '';
        $scope.CashSaleModel.minLength = 3;
        $scope.CashSaleModel.pause = 1000;
        $scope.CashSaleModel.searchResult = [];
        $scope.CashSaleModel.currentIndex = -1;
        $scope.CashSaleModel.isCashSaleSTAActive = false;
        $scope.CashSaleModel.isMobile = {
            Android: function() {
                return $window.navigator.userAgent.match(/Android/i);
            },
            BlackBerry: function() {
                return $window.navigator.userAgent.match(/BlackBerry/i);
            },
            iOS: function() {
                return $window.navigator.userAgent.match(/iPhone|iPad|iPod/i);
            },
            Opera: function() {
                return $window.navigator.userAgent.match(/Opera Mini/i);
            },
            Windows: function() {
                return $window.navigator.userAgent.match(/IEMobile/i);
            },
            any: function() {
                return ($scope.CashSaleModel.isMobile.Android() || $scope.CashSaleModel.isMobile.BlackBerry() || $scope.CashSaleModel.isMobile.iOS() || $scope.CashSaleModel.isMobile.Opera() || $scope.CashSaleModel.isMobile.Windows());
            }
        };
        $scope.CashSaleModel.searchQuery = {
            ObjectLabel: "",
            SearchText: "p-00",
            PreferredObject: "Customer",
            SearchableObjects: "Part__c,Fee__c",
            FilterValues: [{
                'Field': 'Active__c',
                'Value': true,
                'FilterObject': 'Part__c'
            }, {
                'Field': 'Active__c',
                'Value': true,
                'FilterObject': 'Fee__c'
            }]
        };
        $scope.CashSaleModel.loadSTA = function() {
            var currentPageName = $state.$current.name;
            if (currentPageName.toLowerCase().indexOf('cashsaleco') > -1) { 
                $scope.CashSaleModel.searchType = "CashSaleCO";
            } else if (currentPageName.toLowerCase().indexOf('pricefileimport') > -1) {
                $scope.CashSaleModel.searchType = "PriceFileImport";
                $scope.CashSaleModel.searchQuery.SearchableObjects = "Vendor";
                $scope.CashSaleModel.searchQuery.FilterValues.push({
                    "Field": "Active__c",
                    "Value": true,
                    "FilterObject": "Vendor"
                });
            }
        }
        $document.click(function(e) {
            if (e.target.id != 'cashSaleSTAInput') {
                $scope.CashSaleModel.hideTimer = $timeout(function() {
                    $scope.CashSaleModel.isCashSaleSTAActive = false; 
                    $scope.CashSaleModel.showDropdown = false;
                    $scope.CashSaleModel.results = [];
                    $scope.CashSaleModel.searching = false;
                }, $scope.pause);
            }
        });
        $scope.CashSaleModel.setFocusOnSTA = function() {
            $scope.CashSaleModel.isCashSaleSTAActive = true;
        }
        $scope.CashSaleModel.removeFocusOnSTA = function() {
            $scope.CashSaleModel.isCashSaleSTAActive = false;
            $scope.CashSaleModel.showDropdown = false;
        }
        $scope.CashSaleModel.isNewSearchNeeded = function(newTerm, oldTerm) {
            return newTerm.length >= $scope.CashSaleModel.minLength && newTerm != oldTerm;
        }
        $scope.CashSaleModel.keyPressed = function(event) {
            if (($scope.CashSaleModel.searchTerm == null || $scope.CashSaleModel.searchTerm == undefined || $scope.CashSaleModel.searchTerm == "")) {
                $scope.CashSaleModel.isKeyword = false;
                $scope.CashSaleModel.keywordValue = "";
                $scope.CashSaleModel.searchResult = [];
                $scope.CashSaleModel.searching = false;
                $scope.CashSaleModel.currentIndex = -1;
                $scope.CashSaleModel.showDropdown = false;
                if ($scope.$root != null && $scope.$root != '' && $scope.$root != undefined) { 
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply();
                    }
                }
            }
            if (event.which === 27) {
                $scope.CashSaleModel.showDropdown = false;
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply();
                }
            }
            else if ((event.which == 38 || event.which == 40 || event.which == 13)) {
                if (event.which === 40) {
                    if ($scope.CashSaleModel.searchResult && ($scope.CashSaleModel.currentIndex + 1) < $scope.CashSaleModel.searchResult.length) {
                        $scope.CashSaleModel.currentIndex++;
                    }
                } else if (event.which == 38) { 
                    if ($scope.CashSaleModel.currentIndex >= 1) {
                        $scope.CashSaleModel.currentIndex--;
                        event.preventDefault;
                        event.stopPropagation();
                    }
                } else if (event.which == 13) {
                    $scope.CashSaleModel.selectItemfromSTA($scope.CashSaleModel.currentIndex);
                }
                $scope.$apply(); //TODO
            } else if ($scope.CashSaleModel.isNewSearchNeeded($scope.CashSaleModel.searchTerm, $scope.CashSaleModel.lastSearchTerm)) {
                $scope.CashSaleModel.lastSearchTerm = $scope.CashSaleModel.searchTerm;
                if ($scope.CashSaleModel.searchTimer) {
                    $timeout.cancel($scope.CashSaleModel.searchTimer);
                }
                $scope.CashSaleModel.searchTimer = $timeout(function() {
                    $scope.CashSaleModel.searchTimerComplete($scope.CashSaleModel.searchTerm);
                }, $scope.CashSaleModel.pause);
            }
        }
        $scope.CashSaleModel.selectItemfromSTA = function(index) {
            $scope.CashSaleModel.showDropdown = false;
            if (($scope.CashSaleModel.searchType).indexOf('CashSaleCO') > -1) {
                $scope.$emit("cashSaleSTACallback", $scope.CashSaleModel.searchResult[index]);
            } else if (($scope.CashSaleModel.searchType).indexOf('PriceFileImport') > -1) {
                $scope.CashSaleModel.searchTerm = $scope.CashSaleModel.searchResult[index].Title;
                $scope.$emit("priceFileImportSTACallback", $scope.CashSaleModel.searchResult[index]);
            }
        }
        var inputField = angular.element('#cashSaleSTAInput');
        angular.element('body').on('keyup', '#cashSaleSTAInput', $scope.CashSaleModel.keyPressed);
        $scope.CashSaleModel.searchTimerComplete = function(str) {
            if (str != null) {
                if (str.length >= $scope.CashSaleModel.minLength) {
                    $scope.CashSaleModel.SearchSuggestion(str);
                }
            } else {
                $scope.CashSaleModel.SearchSuggestion("");
            }
        }
        $scope.CashSaleModel.SearchSuggestion = function(searchString) {
            $scope.CashSaleModel.searchQuery.SearchText = searchString;
            $scope.CashSaleModel.searching = true;
            searchService.searchText(JSON.stringify($scope.CashSaleModel.searchQuery)).then(function(successfulSearchResult) {
                $scope.CashSaleModel.searching = false;
                $scope.CashSaleModel.processResults(successfulSearchResult);
                $scope.CashSaleModel.showDropdown = true; 
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
                $scope.CashSaleModel.searching = false;
            });
        }
        $scope.CashSaleModel.processResults = function(responseData) {
            $scope.CashSaleModel.searchResult = [];
            var result = [];
            var resultObj;
            for (var i = 0; i < responseData.length; i++) {
                resultObj = {};
                if (responseData[i]['Info'] == "Merchandise") {
                    resultObj.Title = responseData[i].Name + ' - ' + responseData[i].Description;
                    resultObj.Info = responseData[i].Info;
                    resultObj.Id = responseData[i].Value;
                    resultObj.NonInventoryPart = responseData[i].NonInventoryPart;
                    if (!resultObj.NonInventoryPart) {
                        resultObj.AdditionalInfo = 'Quantity available: ' + responseData[i]['AdditionalDetailsForPart'].AvailableQty;
                    }
                    resultObj.AdditionalDetails = responseData[i]['AdditionalDetailsForPart'];
                    result.push(resultObj);
                } else if (responseData[i]['Info'] == "Fee") {
                    resultObj.Title = responseData[i].Name;
                    resultObj.Info = responseData[i].Info;
                    resultObj.Id = responseData[i].Value;
                    resultObj.AdditionalDetails = responseData[i]['AdditionalDetailsForPart'];
                    result.push(resultObj);
                } else if (responseData[i]['Info'] == "Vendor") {  
                    resultObj.Title = responseData[i].Name;
                    resultObj.Info = responseData[i].Info;
                    resultObj.Id = responseData[i].Value;
                    resultObj.CategoryName = responseData[i].AdditionalInfo.CategoryName; 
                    resultObj.CategoryId = responseData[i].AdditionalInfo.CategoryId; 
                    resultObj.AdditionalInfo = 'Vendor Code: ' + responseData[i].AdditionalInfo.VendorCode; 
                    resultObj.AdditionalInfoWithVendorPricingFields = responseData[i].AdditionalInfo;
                    resultObj.AdditionalDetails = responseData[i]['AdditionalDetailsForPart'];
                    result.push(resultObj);
                }
                if (result.length == 8) {
                    break;
                }
            }
            $scope.CashSaleModel.searchResult = result;
            $scope.CashSaleModel.currentIndex = -1;
            setTimeout(function() {
                if ($scope.CashSaleModel != '' && $scope.CashSaleModel != undefined && $scope.CashSaleModel != null && $scope.CashSaleModel.isMobile.any()) { 
                    var myDiv = document.getElementById('globalSearchStrInputSuggestions');
                    myDiv.scrollTop = 0;
                } else {
                    if (angular.element('#SearchResult_0').length > 0) { 
                        angular.element('#SearchResult_0')[0].scrollIntoView(false);
                    }
                }
            }, 10);
        }
        $scope.$on('clearSearchTermBeforeImportNewFile', function(name, args) {
            $scope.CashSaleModel.searchTerm = args;
        });
    }])
});