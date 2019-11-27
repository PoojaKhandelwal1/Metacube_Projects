'use strict';
define(['Routing_AppJs_PK', 'HighlightSearchTextFilter'], function(Routing_AppJs_PK, HighlightSearchTextFilter) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.directive('autocompletev2', ['$sce', '$compile', '$timeout', 'userService', 'focusElement', '$filter', function($sce, $compile, $timeout, userService, focusElement, $filter) {
        return {
            restrict: 'E',
            scope: {
                templateName: '@',
                sectionName: '@',
                soheaderIndex: '@',
                unitIndex: '@',
                sectionId: '@',
                isDisabled: '=',
                financeVendorId: '@',
                customerId: '@',
                defaultValue: '=',
                createActionAvailableOnDropdown: '=',
                isNonSearchableDropdown: '=',
                listData: '=',
                ngClassName : '=',
                onBlurInputAction: '&',
                linkedSoJobTypeId: '@',
                selectedCustomerId : '@',
                setDirRefreshFnForParamChange : '&'
            },
            templateUrl: function(element, attrs) {
                return $sce.trustAsResourceUrl($Global.applicationPath + '/templates/' + attrs.templateName + '.html');
            },
            link: function($scope, element, attrs) {
            
            	$scope.refreshDirOnParamChange = function(paramName) {
            		if(paramName === 'financeVendorId') {
            			updateFinanceCompanyId();
            		} else if(paramName === 'linkedSoJobTypeId') {
            			updateLinkedSoJobTypeId();
            		}
        	    }
            	
        	    $scope.setDirRefreshFnForParamChange({theDirFn: $scope.refreshDirOnParamChange});
                
                $scope.$watch('defaultValue', function(newValue, oldValue) {
                	$scope.searchStr = $scope.defaultValue || '';
                });
                
                var Notification = injector.get("Notification");
                var sectionNameToSearchDataMap = {
                    'Customer': {
                        searchableObjects: 'Customer',
                        filterValues: [{
                            'Field': 'Is_Customer__c',
                            'Value': true,
                            'Operator': '=',
                            'FilterObject': 'Account'
                        }],
                        keywordsList: []
                    },
                    'CustomerCoBuyer': {
                        searchableObjects: 'Customer',
                        filterValues: [{
                            'Field': 'Is_Customer__c',
                            'Value': true,
                            'Operator': '=',
                            'FilterObject': 'Account'
                        },{
                            'Field': 'Id',
                            'Value': "'" + $scope.selectedCustomerId + "'",
                            'Operator': '!=',
                            'FilterObject': 'Account'
                        }],
                        keywordsList: []
                    },
                    'CustomerOwnedUnit': {
                        keywordsList: []
                    },
                    'JobType':{
                    	keywordsList: []
                    },
                    'Service Job': {
                        searchableObjects: 'Part__c,Fee__c,Labour_Code__c,Kit_Header__c,Product__c',
                        filterValues: [{
                            'Field': 'Type__c',
                            'Value': "'Sublet'",
                            'Operator': '=',
                            'FilterObject': 'Product__c'
                        }],
                        keywordsList: ['Merchandise', 'Kit', 'Fee', 'Labor', 'Sublet']
                    },
                    'Linked Service Job': {
                    	searchableObjects: 'Service_Order_Header__c',
                    	isSpecialSearch: true,
                    	filterValues: (!(isBlankValue($scope.linkedSoJobTypeId)) ? [{
                            'Field': 'Transaction_Type__c',
                            'Value': "'" + $scope.linkedSoJobTypeId + "'",
                            'Operator': '=',
                            'FilterObject': 'Service_Order_Header__c'
                        }] : []),
                        keywordsList: []
                    },
                    'Merchandise Section': {
                        searchableObjects: 'Part__c,Fee__c,Kit_Header__c',
                        filterValues: [{
                            "Field": "Service_Kit__c",
                            "Value": false,
                            'Operator': '=',
                            "FilterObject": "Kit_Header__c"
                        }] ,
                        keywordsList: ['Merchandise', 'Fee', 'Kit']
                    },
                    'Stock Unit': {
                        searchableObjects: 'Customer_Owned_Unit__c',
                        filterValues: ($scope.sectionId.includes('DealUnit') ? [{
                            "Field": "Unit_Type__c",
                            "Value": "'COU'",
                            'Operator': '!=',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }, {
                            "Field": "",
                            "Value": "(Status__c = 'Available' OR (Status__c = 'On Order' AND Is_Ordered_Unit_Added_To_Deal__c = false) )",
                            'Operator': '=',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }] : [{
                            "Field": "Unit_Type__c",
                            "Value": "'STOCK'",
                            'Operator': '=',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }, {
                            "Field": "Status__c",
                            "Value": "'Sold'",
                            'Operator': '!=',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }]),
                        keywordsList: []
                    },
                    'Deal': {
                        searchableObjects: 'Part__c,Fee__c,Labour_Code__c,Kit_Header__c,Product__c',
                        filterValues: [],
                        keywordsList: ['Merchandise', 'Labor', 'Kit', 'Fee', 'Warranty', 'Other Product', 'Sublet'] // 'Merchandise','Labor','Kit' will be handled on the basis of deal status
                    },
                    'Committed Deal': {
                        searchableObjects: 'Fee__c,Product__c',
                        filterValues: [{
                            'Field': 'Type__c',
                            'Value': "'Sublet'",
                            'Operator': '!=',
                            'FilterObject': 'Product__c'
                        }],
                        keywordsList: ['Fee', 'Warranty', 'Other Product'] // 'Merchandise','Labor','Kit' will be handled on the basis of deal status
                    },
                    'DealMerch Section': {
                        searchableObjects: 'Part__c,Kit_Header__c',
                        filterValues: [{
                            "Field": "Service_Kit__c",
                            "Value": false,
                            'Operator': '=',
                            "FilterObject": "Kit_Header__c"
                        }],
                        keywordsList: ['Merchandise', 'Kit']
                    },
                    'DealService Section': {
                        searchableObjects: 'Part__c,Labour_Code__c,Kit_Header__c,Product__c',
                        filterValues: [{
                            'Field': 'Type__c',
                            'Value': "'Sublet'",
                            'Operator': '=',
                            'FilterObject': 'Product__c'
                        }],
                        keywordsList: ['Merchandise', 'Kit', 'Labor', 'Sublet']
                    },
                    'DealFinance': {
                        searchableObjects: 'Product__c',
                        filterValues: ((isBlankValue($scope.financeVendorId)) ? [{
                            'Field': 'Type__c',
                            'Value': "'Financing Product'",
                            'Operator': '=',
                            'FilterObject': 'Product__c'
                        }] : [{
                            'Field': 'Type__c',
                            'Value': "'Financing Product'",
                            'Operator': '=',
                            'FilterObject': 'Product__c'
                        }, {
                            "Field": "Vendor__c",
                            "Value": "'" + $scope.financeVendorId + "'",
                            'Operator': '=',
                            "FilterObject": "Product__c"
                        }]),
                        keywordsList: []
                    },
                    'Warranty Plan': {
                        searchableObjects: 'Product__c',
                        filterValues: [{
                            "Field": "Type__c",
                            "Value": "'Warranty Plan'",
                            'Operator': '=',
                            "FilterObject": "Product__c"
                        }],
                        keywordsList: []
                    },
                    'Other Product': {
                        searchableObjects: 'Product__c',
                        filterValues: [{
                            "Field": "",
                            "Value": "(Type__c = 'Deal Product' OR Type__c = 'Financing Product' OR Type__c = 'Third Party')", // if filter values has OR conditions then add them like complete where clause and set field value blank
                            "FilterObject": "Product__c"
                        }],
                        keywordsList: []
                    },
                    'Sublet': {
                        searchableObjects: 'Product__c',
                        filterValues: [{
                            "Field": "Type__c",
                            "Value": "'Sublet'",
                            'Operator': '=',
                            "FilterObject": "Product__c"
                        }],
                        keywordsList: []
                    },
                    'Labor': {
                        searchableObjects: 'Labour_Code__c',
                        filterValues: [],
                        keywordsList: []
                    },
                    'Merchandise': {
                        searchableObjects: 'Part__c',
                        filterValues: [],
                        keywordsList: []
                    },
                    'Kit': {
                        searchableObjects: 'Kit_Header__c',
                        filterValues: ($scope.sectionName == 'DealMerch Section' || $scope.sectionName == 'Merchandise Section') ? [{
                            "Field": "Service_Kit__c",
                            "Value": false,
                            'Operator': '=',
                            "FilterObject": "Kit_Header__c"
                        }] : [],
                        keywordsList: []
                    },
                    'Fee': {
                        searchableObjects: 'Fee__c',
                        filterValues: [],
                        keywordsList: []
                    }
                };
                var entityNameToImageNameMap = {
                    'Search': 'search',
                    'Close': 'close',
                    'Customer': 'customer',
                    'Part': 'part',
                    'Merchandise': 'part',
                    'Fee': 'fee_V2',
                    'Labor': 'labor',
                    'down_arrow': 'arrow-down-1',
                    'Kit': 'kit',
                    'Product': 'sublet',
                    'Sublet': 'sublet',
                    'Warranty Plan': 'Warranty-product',
                    'Financing Product': 'finance-product_V2',
                    'Deal Product': 'Deal-financing_V2',
                    'Unit': 'Unit_V2',
                    'Stock unit': 'Unit_V2',
                    'COU': 'Unit_V2',
                    'Other Product': 'vendor-product',
                    'Order unit': 'Unit_V2'
                };
                $scope.keywordNameToEntityObjectMap = {
                    'Customer': 'Customer',
                    'User': 'User',
                    'Merchandise': 'Merchandise',
                    'Kit': 'Kit',
                    'Fee': 'Fee',
                    'Stock Unit': 'Stock unit', 
                    'COU': 'COU', 
                    'Labor': 'Labor',
                    'Warranty': 'Warranty Plan',
                    'Other Product': 'Other Product',
                    'Sublet': 'Sublet',
                    'Finance': 'DealFinance'
                };
                $scope.setInitialData = function() {
                	if($scope.isNonSearchableDropdown) {
                    	$scope.results = angular.copy($scope.listData);
                    }
                    $scope.showDropdown = true;
                    $scope.keywordsList = sectionNameToSearchDataMap[$scope.sectionName]['keywordsList'];
                    $scope.isSearchBoxFocussed = true;
                }
                $scope.selectKeyword = function(keyword) {
                    $scope.selectedKeyword = keyword;
                    $scope.showDropdown = false;
                    $scope.searchStr = '';
                    $scope.results = [];
                    $scope.lastSearchTerm = null;
                    $scope.currentDropDownIndex = -1;
                    focusElement('autocomplete' + $scope.sectionId);
                }
                $scope.clearSelectedKeyword = function() {
                    $scope.selectedKeyword = '';
                    focusElement('autocomplete' + $scope.sectionId);
                }
                $scope.findReultsIndexWithFilteredKeywords = function(index) {
                    if ($scope.keywordsList && $filter("filter")($scope.keywordsList, $scope.searchStr).length) {
                        return index + $filter("filter")($scope.keywordsList, $scope.searchStr).length;
                    } else {
                        return index;
                    }
                }
                function updateFinanceCompanyId() {
                	if(sectionNameToSearchDataMap['DealFinance']) {
                		sectionNameToSearchDataMap['DealFinance'].filterValues = ((isBlankValue($scope.financeVendorId)) ? [{
	                            'Field': 'Type__c',
	                            'Value': "'Financing Product'",
	                            'Operator': '=',
	                            'FilterObject': 'Product__c'
	                        }] : [{
	                            'Field': 'Type__c',
	                            'Value': "'Financing Product'",
	                            'Operator': '=',
	                            'FilterObject': 'Product__c'
	                        }, {
	                            "Field": "Vendor__c",
	                            "Value": "'" + $scope.financeVendorId + "'",
	                            'Operator': '=',
	                            "FilterObject": "Product__c"
	                        }]);
                	}
                }
                
                function updateLinkedSoJobTypeId() {
                	if(sectionNameToSearchDataMap['Linked Service Job']) {
                		sectionNameToSearchDataMap['Linked Service Job'].filterValues = (!(isBlankValue($scope.linkedSoJobTypeId)) ? [{
	                        'Field': 'Transaction_Type__c',
	                        'Value': "'" + $scope.linkedSoJobTypeId + "'",
	                        'Operator': '=',
	                        'FilterObject': 'Service_Order_Header__c'
	                    }] : []);
                	}
                }
                
                $scope.ApplicationImagePath = $Global.ApplicationImagePath;
                $scope.getintialdata = function(entityName, overrideIconName) {
                    if (overrideIconName != undefined && overrideIconName != null) {
                        return $sce.trustAsResourceUrl($scope.ApplicationImagePath + '/Icons/' + entityNameToImageNameMap[overrideIconName] + '.svg');
                    } else {
                        return $sce.trustAsResourceUrl($scope.ApplicationImagePath + '/Icons/' + entityNameToImageNameMap[entityName] + '.svg');
                    }
                }
                var PAUSE_TIMER = 500;
                var MIN_LENGTH = 3;
                $scope.lastSearchTerm = null;
                $scope.searchTimer = null;
                $scope.currentDropDownIndex = -1;
                $scope.searching = false;
                $scope.searchStr = $scope.defaultValue || '';
                $scope.isNoResults = false;
                $scope.isSearchBoxFocussed = false;

                function getContentUrl() {
                    return $sce.trustAsResourceUrl($Global.applicationPath + '/templates/' + $scope.templateName + '.html');
                }
                angular.element(document).on("click", function(e) {
                    if (angular.element(e.target).parent().closest('.autocomplete_v2').length == 0) {
                        hideDropDown();
                    }
                });
				
                function isNewSearchNeeded(newTerm, oldTerm) {
                    return newTerm.length >= MIN_LENGTH && newTerm != oldTerm
                }
                var success = function() {
                    var self = this;
                    this.arguments = arguments[0];
                    this.type = arguments[0].type,
                        this.handler = function(successResult) {
                            switch (self.type) {
                                case 'Search':
                                    handleSearchResponse(successResult);
                                    break;
                                default:
                                    break;
                            }
                        }

                    function handleSearchResponse(searchResults) {
                        $scope.searching = false;
                        $scope.overrideIconName = null;
                        var counter = 10;
                        if (searchResults.length == 0) {
                            $scope.isNoResults = true;
                        }
                        for (var i = 0; i < searchResults.length; i++) {
                            if (searchResults[i].Info == 'Merchandise') {
                                searchResults[i].Info = 'Part';
                            }
                            if (searchResults[i].Info == 'Product') {
                                searchResults[i].OverrideIconName = searchResults[i].AdditionalInfoObj.ProductType;
                            }
                            if (searchResults[i].Info == 'Object') {
                                searchResults.splice(i, 1);
                                i--;
                            }
                            if ($scope.sectionName == 'Stock Unit') {
                                if (searchResults[i].Info == 'Unit' && searchResults[i].AdditionalInfoObj.UnitType === 'ORDU') {
                                	searchResults[i].Info = 'Order unit';
                                } else {
                                	searchResults[i].Info = 'Stock unit';
                                }
                            }
                        }
                        if (searchResults.length < 10) {
                            counter = searchResults.length + 1;
                        }
                        $scope.results = searchResults.slice(0, counter);
                    }
                }
                var error = function(errorMessage) {
                    this.handler = function(error) {
                        if (!errorMessage) {
                            console.log(error);
                        } else {
                            console.log(errorMessage);
                        }
                        $scope.searching = false;
                    }
                }
                function hideDropDown() {
                    $scope.showDropdown = false;
                    $scope.results = [];
                    $scope.searchStr = $scope.defaultValue || '';
                    $scope.searching = false;
                    $scope.lastSearchTerm = null;
                    $scope.isNoResults = false;
                    $scope.selectedKeyword = '';
                    $scope.currentDropDownIndex = -1;
                    $scope.isSearchBoxFocussed = false;
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply();
                    }
                }
                $scope.keyDown = function(event) {
                    if (event.which == 8 && angular.element('#autocomplete' + $scope.sectionId).length && angular.element('#autocomplete' + $scope.sectionId).context.activeElement.selectionStart === 0) {
                        $scope.selectedKeyword = '';
                        $scope.showDropdown = true;
                    }
                }
                $scope.keyPressed = function(event) {
                    if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                        if ((!$scope.searchStr || $scope.searchStr == "") && !$scope.isNonSearchableDropdown) {
                            $scope.results = [];
                            $scope.lastSearchTerm = null;
                            $scope.searching = false;
                        } else if (isNewSearchNeeded($scope.searchStr, $scope.lastSearchTerm) && !$scope.isNonSearchableDropdown) {
                            $scope.lastSearchTerm = $scope.searchStr;
                            $scope.showDropdown = true;
                            if ($scope.searchTimer) {
                                $timeout.cancel($scope.searchTimer);
                            }
                            $scope.searching = true;
                            $scope.searchTimer = $timeout(function() {
                                searchTimerComplete($scope.searchStr);
                            }, PAUSE_TIMER);
                        }
                    } else {
                        var keyCode = event.which ? event.which : event.keyCode;
                        var tempList = $scope.results;
                        var dropDownDivId = '#' + $scope.sectionId + 'DropDownDiv';
                        var idSubStr = '';
                        var totalRecordsToTraverse = 0;
                        if (tempList) {
                            totalRecordsToTraverse += tempList.length;
                        }
                        if($scope.keywordsList) {
                        	totalRecordsToTraverse += $filter("filter")($scope.keywordsList, $scope.searchStr).length;
                        }
                        
                        if (keyCode == 40 && totalRecordsToTraverse > 0) {
                            if (totalRecordsToTraverse - 1 > $scope.currentDropDownIndex) {
                                $scope.currentDropDownIndex++;
                                if ($scope.templateName == 'Customer' && $scope.sectionName !='CustomerCoBuyer' && $scope.sectionId != 'CustomerCoBuyer') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#customerInfo_';
                                } else if ($scope.templateName == 'Customer' && $scope.sectionName =='CustomerCoBuyer' && $scope.sectionId == 'CustomerCoBuyer') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#customerCOBuyerInfo_';
                                } else if ($scope.templateName == 'CustomerOwnedUnit') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#couInfo_';
                                } else if ($scope.templateName == 'JobType') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#jobType_';
                                } else if ($scope.keywordsList && $scope.templateName == 'Entity') {
                                    if ($scope.currentDropDownIndex < $filter("filter")($scope.keywordsList, $scope.searchStr).length) {
                                        idSubStr = '#entityKeyword_';
                                    } else {
                                        idSubStr = '#entityInfo_';
                                    }
                                } else {
                                    idSubStr = '#entityInfo_';
                                }
                                angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.currentDropDownIndex)[0].offsetTop - 100;
                            }
                        } else if (keyCode === 38) {
                            if ($scope.currentDropDownIndex > 0) {
                                $scope.currentDropDownIndex--;
                                if ($scope.templateName == 'Customer') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else  
                                    idSubStr = '#customerInfo_';
                                } else if ($scope.templateName == 'CustomerOwnedUnit') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#couInfo_';
                                } else if ($scope.templateName == 'JobType') { // same code in both if and else but can not be moved before if and else as it depends on value of $scope.currentDropDownIndex which is incrementing in if and decrementing in else
                                    idSubStr = '#jobType_';
                                } else if ($scope.keywordsList && $scope.templateName == 'Entity') {
                                    if ($scope.currentDropDownIndex < $filter("filter")($scope.keywordsList, $scope.searchStr).length) {
                                        idSubStr = '#entityKeyword_';
                                    } else {
                                        idSubStr = '#entityInfo_';
                                    }
                                } else {
                                    idSubStr = '#entityInfo_';
                                }
                                angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.currentDropDownIndex)[0].offsetTop - 100;
                            }
                        } else if (keyCode == 13 && $scope.currentDropDownIndex !== -1) {
                            if ($scope.keywordsList && $filter("filter")($scope.keywordsList, $scope.searchStr).length > 0 && $scope.currentDropDownIndex < $filter("filter")($scope.keywordsList, $scope.searchStr).length) {
                                $scope.selectKeyword($filter("filter")($scope.keywordsList, $scope.searchStr)[$scope.currentDropDownIndex]);
                            } else {
                                $scope.selectResult(tempList[$scope.currentDropDownIndex]);
                            }
                            $scope.currentDropDownIndex = -1;
                        }
                    }
                }
                
                $scope.openAddEditCustomerPopup = function() {
                	$scope.showDropdown = false;
                    $scope.isSearchBoxFocussed = false;
                	$scope.$emit('createCustomerAutoCompleteCallback');
                }
                
                $scope.openAddEditCOUPopup = function() {
                	$scope.showDropdown = false;
                    $scope.isSearchBoxFocussed = false;
                	$scope.$emit('createCOUAutoCompleteCallback');
                }
                
                function searchTimerComplete(str) {
                    if (str != null) {
                        if (str.length >= MIN_LENGTH) {
                            SerachSuggestion(str);
                        }
                    } else {
                        SerachSuggestion("");
                    }
                }
                
                function SerachSuggestion(str) {
                    var responseData = [];
                    var searchQueryJson = {};
                    var successJson = {
                        'type': 'Search'
                    };
                    if (str != '' && str != null) {
                    	searchQueryJson = {
                            "SearchText": str,
                            "IsSpecialSearch": sectionNameToSearchDataMap[$scope.sectionName]['isSpecialSearch'] ? sectionNameToSearchDataMap[$scope.sectionName]['isSpecialSearch'] : false,
                            "SearchableObjects": sectionNameToSearchDataMap[(!isBlankValue($scope.selectedKeyword)) ? $scope.keywordNameToEntityObjectMap[$scope.selectedKeyword] : $scope.sectionName]['searchableObjects'],
                            "FilterValues": sectionNameToSearchDataMap[(!isBlankValue($scope.selectedKeyword)) ? $scope.keywordNameToEntityObjectMap[$scope.selectedKeyword] : $scope.sectionName]['filterValues']
                        }
                        searchQueryJson = JSON.stringify(searchQueryJson);
                        userService.getSearchResult(searchQueryJson).then(function(successResult) {
                        	if(successResult != SKIP_API_REQUEST) {
                        		new success(successJson).handler(successResult);
                        	}
                        }, new error().handler);
                    }
                }
                
                $scope.setFocus = function(id) {
                	setTimeout(function(){
                		angular.element("#"+ id).focus();	
                	},100);
                }
                $scope.selectResult = function(result, event) {
                    //check right or left mouse;
                    //Impact only on CO Control
                    //#4500 assembla
                    var clickTest = ((event) === undefined) ? 1 : event.which;
                     switch(clickTest) {
                            case 1:
                            //only execute left mouse button click result leave on browser;
                            $scope.isNoResults = false;
                            var successJson = {};
                            hideDropDown();
                            if ($scope.templateName == 'Customer'&& $scope.sectionName !='CustomerCoBuyer' && $scope.sectionId != 'CustomerCoBuyer') {
                                successJson = {
                                    'type': 'addCustomer',
                                    'selectedId': result.Id
                                };
                            }  else if ($scope.templateName == 'Customer'&& $scope.sectionName =='CustomerCoBuyer' && $scope.sectionId == 'CustomerCoBuyer') {
                                successJson = {
                                    'type': 'addCustomerCoBuyer',
                                    'selectedId': result.Id
                                };
                            }else if ($scope.templateName == 'CustomerOwnedUnit') {
                                successJson = {
                                    'type': 'addCustomerOwnedUnit',
                                    'selectedId': result.UnitId,
                                    'selectedJSON': result
                                };
                            } else if ($scope.templateName == 'JobType' && $scope.sectionId !== 'LinkedSOJobType') {
                                angular.element('#autocomplete' + $scope.sectionId).blur();
                                successJson = {
                                    'type': 'selectJobType',
                                    'selectedJobType': result
                                };
                            } else if ($scope.templateName == 'JobType' && $scope.sectionId === 'LinkedSOJobType') {
                            	angular.element('#autocomplete' + $scope.sectionId).blur();
                            	successJson = {
                                    'type': 'selectLinkedSOJobType',
                                    'selectLinkedSOJobType': result
                                };
                            } else if ($scope.templateName == 'Entity') {
                                if ($scope.sectionName == 'Deal' || $scope.sectionName == 'Committed Deal') {
                                    successJson = {
                                        'type': 'addOptionFee',
                                        'selectedId': result.Id,
                                        'unitIndex': $scope.unitIndex,
                                        'selectedJSON': result
                                    };
                                } else if ($scope.sectionName == 'Service Job' || $scope.sectionName == 'DealService Section') {
                                    successJson = {
                                        'type': 'addSOLineItem',
                                        'selectedId': result.Id,
                                        'soheaderIndex': $scope.soheaderIndex,
                                        'selectedJSON': result.AdditionalInfoObj
                                    };
                                } else if ($scope.sectionName == 'Merchandise Section') {
                                    if (result.Info == 'Part') {
                                        successJson = {
                                            'type': 'addCOLineItem',
                                            'selectedId': result.Id,
                                            'selectedJSON': result.AdditionalInfoObj
                                        };
                                        
                                        /*Start: For Cash Sale Oversold Functionality*/
                                        if (!$scope.customerId && result.AdditionalInfoObj.AvailableQty <= 0 && !result.AdditionalInfoObj.NonInventoryPart) {
                                            successJson['isOutOfStockPart'] = true;
                                        }
                                        /*End: For Cash Sale Oversold Functionality*/
                                    } else if (result.Info == 'Fee') {
                                        successJson = {
                                            'type': 'addCOLineItem',
                                            'FeeId': result.Id
                                        };
                                    } else if (result.Info == 'Kit') {
                                        successJson = {
                                                'type': ($scope.customerId) ? 'addCOLineItem' : 'addKitInCashSale',
                                                'selectedId': result.Id
                                            };
                                        }
                                } else if ($scope.sectionName == 'Stock Unit') {
                                    if ($scope.sectionId.includes('DealUnit')) {
                                        successJson = {
                                            'type': 'addStockUnit',
                                            'selectedId': result.Id,
                                            'UnitIndex': $scope.unitIndex
                                        };
                                    } else if ($scope.sectionId.includes('ServiceJob')) {
                                        successJson = {
                                            'type': 'addStockUnit',
                                            'selectedId': result.Id,
                                            'soheaderIndex': $scope.soheaderIndex
                                        };
                                    }
                                } else if ($scope.sectionName == 'DealMerch Section') {
                                    if(result.Info === 'Kit') {
                                        successJson = {
                                                'type': 'addDealCOLineItem',
                                                'selectedId': result.Id,
                                                'kitId': result.Id
                                            };
                                    } else {
                                        successJson = {
                                                'type': 'addDealCOLineItem',
                                                'selectedId': result.Id,
                                                'selectedJSON': result.AdditionalInfoObj
                                            };
                                    }
                                } else if ($scope.sectionName == 'DealFinance') {
                                    successJson = {
                                        'type': 'saveDealFAndIProduct',
                                        'selectedId': result.Id
                                    };
                                } else if ($scope.sectionName == 'Linked Service Job') {
                                    successJson = {
                                            'type': 'LinkedServiceJob',
                                            'selectedId': result.Id,
                                            'selectedJSON': result
                                        };
                                }
                            }
                            $scope.$emit('AutoCompleteCallbackHandler', successJson);
                            break;
                            default:
                            return true;
                        }
                }
            }
        };
    }]);
});