var app = angular.module('angucomplete', ['ui-notification']);
app.directive('angucomplete', ['$parse', '$sce', '$timeout', '$q', 'userService', 'Notification', '$rootScope', function($parse, $sce, $timeout, $q, userService, Notification, $rootScope) {
    return {
        restrict: 'EA',
        scope: {
            "id": "@id",
            "placeholder": "@placeholder",
            "selectedObject": "=selectedobject",
            "url": "@url",
            "dataField": "@datafield",
            "titleField": "@titlefield",
            "descriptionField": "@descriptionfield",
            "otherDesc": "@otherdesc",
            "imageField": "@imagefield",
            "imageUri": "@imageuri",
            "inputClass": "@inputclass",
            "userPause": "@pause",
            "minLengthUser": "@minlength",
            "matchClass": "@matchclass"
        },
        template: '<div class="angucomplete-holder"> <div class="{{inputClass}}"> <span >{{selectedObject.ObjectSelected.Name}}</span><input text" id="{{id}}_value" ng-model="searchStr" class="anguinput" ng-focus="GetIntialdata()"  type="text" placeholder="{{placeholder}}" class="" onmouseup="this.select();" ng-focus="resetHideResults()" ng-blur="hideResults()"/></div><div id="{{id}}_dropdown" class="angucomplete-dropdown" ng-if="showDropdown"><div class="angucomplete-searching" ng-show="searching">Searching...</div><div class="angucomplete-searching" ng-show="!searching && (!results || results.length == 0)">No results found</div><div class="angucomplete-row" ng-repeat="result in results" ng-click="selectResult(result)" ng-mouseover="hoverRow($index)" ng-class="{\'angucomplete-selected-row\': $index == currentIndex}"><div class="row"><div  class="angucomplete-AddResult col-lg-8" ng-if="result.description==\'AdditionalResults\'" >  {{ result.title }}</div ><div  class="angucomplete-AddtionalInfo col-lg-8" ng-if="result.description==\'AdditionalInfo\'"> {{ result.title }}</div ><div  ng-if="result.description !=\'AdditionalInfo\' && result.description !=\'AdditionalResults\'"><div class="angucomplete-title col-lg-8" ng-if="matchClass" ng-bind="result.title"></div><div ng-if="result.description !=\'Object\' && result.description !=\'section\'" class="angucomplete-description col-lg-4 pull-right" style="text-align:right" > &gt; {{result.description}}</div><div></div></div>',
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
            $scope.ObjectData = null;
            $scope.ObjectDataValue = "";
            $scope.testScopeVar = "0";
            $scope.UserDetails = null;
            $scope.GetIntialdata = function() {
                $scope.selectedObject.searchDivActive = true;
                if (!$scope.searchStr) {
                    if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') >= 0) {
                        $scope.lastSearchTerm = $scope.searchStr;
                        $scope.showDropdown = true;
                        $scope.currentIndex = -1;
                        $scope.results = [];
                        $scope.searching = true;
                        $scope.searchTimerComplete($scope.searchStr);
                    } else {
                        $scope.searchStr = null;
                    }
                }
                if (($scope.searchStr == null || $scope.searchStr == "") && ($scope.selectedObject.ObjectSelected == "" || $scope.selectedObject.ObjectSelected == null || angular.isDefined($scope.selectedObject.ObjectSelected) == false)) {
                    $scope.lastSearchTerm = $scope.searchStr;
                    $scope.showDropdown = true;
                    $scope.currentIndex = -1;
                    $scope.results = [];
                    $scope.searching = true;
                    $scope.searchTimerComplete($scope.searchStr);
                }
            }
            $scope.$on('plusIconClickEvent', function(event, args) {
                if ($scope.selectedObject.ObjectSelected != "" && $scope.selectedObject.ObjectSelected != null && angular.isDefined($scope.selectedObject.ObjectSelected) == true) {
                    $scope.selectedObject.ObjectSelected.Name = "";
                    $scope.selectedObject.ObjectSelected.Value = "Customer_Owned_Unit__c,Customer_Owned_Unit__c,Part__c,Labour_Code__c,Kit_Header__c,Fee__c,Product__c,Product__c";
                }
                $scope.lastSearchTerm = $scope.searchStr;
                $scope.showDropdown = true;
                $scope.currentIndex = -1;
                $scope.results = [];
                $scope.searchStr = null;
                $scope.searching = true;
                $scope.selectedObject.searchDivActive = true;
                $scope.searchTimerComplete($scope.searchStr);
            });
            if ($scope.minLengthUser && $scope.minLengthUser != "") {
                $scope.minLength = $scope.minLengthUser;
            }
            if ($scope.userPause) {
                $scope.pause = $scope.userPause;
            }
            isNewSearchNeeded = function(newTerm, oldTerm) {
                return newTerm.length >= $scope.minLength && newTerm != oldTerm;
            }
            $scope.processResults = function(responseData, str) {
                if (!($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') > -1 || $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') > -1)) {
                    var counter = 0;
                    for (i = 0; i < responseData.length; i++) {
                        if (responseData[i]['Info'] == 'Kit') {
                            if (responseData[i]['AdditionalDetailsForPart'].IsServiceKit == true) {
                                responseData.splice(i, 1);
                                --i;
                            }
                        }
                        if (i > 10) {
                            break;
                        }
                    }
                    counter = ((responseData.length) > 10 ? 10 : responseData.length);
                    $scope.ProcessResponsedataMerchandise(responseData, str, counter);
                } else {
                    var counter = ((responseData.length) > 10 ? 10 : responseData.length);
                    $scope.ProcessResponsedataMerchandise(responseData, str, counter);
                }
            }
            $scope.ProcessResponsedataMerchandise = function(responseData, str, counter) {
                if (responseData && responseData.length >= 0) {
                    var resultsArray = [];
                    var titleFields = [];
                    if ($scope.titleField && $scope.titleField != "") {
                        titleFields = $scope.titleField.split(",");
                    }
                    var compareval = 0;
                    for (var i = 0; i < counter; i++) {
                        var titleCode = [];
                        for (var t = 0; t < titleFields.length; t++) {
                            titleCode.push(responseData[i][titleFields[t]]);
                        }
                        var description = "";
                        if ($scope.descriptionField) {
                            if (responseData[i][$scope.descriptionField] != 'Object' && responseData[i][$scope.descriptionField] != 'section') {
                                compareval = 1;
                            }
                            description = responseData[i][$scope.descriptionField];
                        }
                        var text = titleCode.join(' ');
                        if ($scope.matchClass) {
                            if (responseData[i][$scope.otherDesc] != null) {
                                text = text + " - " + responseData[i][$scope.otherDesc];
                            }
                        }
                        var resultRow = {
                            title: text,
                            description: description,
                            originalObject: responseData[i],
                        }
                        resultsArray[resultsArray.length] = resultRow;
                    }
                    if (responseData.length > 10) {
                        var AddationalRow = {
                            title: "...and " + (responseData.length - counter).toString() + " other results",
                            description: "AdditionalResults",
                            image: "",
                            originalObject: " ",
                        }
                        resultsArray.push(AddationalRow);
                    }
                    $scope.results = resultsArray;
                } else {
                    $scope.results = [];
                }
            }
            $scope.isRemove = false;
            $scope.SerachSuggestion = function(str) {
                var responseData = [];
                if ($scope.selectedObject.coHeaderDetails.SellingGroup == 'Internal Service') {
                    var filterParam = [{
                        "Field": "Unit_Type__c",
                        "Value": "STOCK",
                        "FilterObject": "Customer_Owned_Unit__c"
                    }]
                }
                var ObjectDatavar = (($scope.selectedObject.ObjectSelected) ? $scope.selectedObject.ObjectSelected.Name : '');
                var itemsInSearch = $scope.selectedObject.SelectedSection['sectionType'];
                if ($scope.selectedObject.coHeaderDetails.SellingGroup != undefined && $scope.selectedObject.SelectedSection['item'] == 'Info Section' && $scope.selectedObject.coHeaderDetails.SellingGroup == 'Internal Service' && !$scope.isRemove) {
                    var removedItem = itemsInSearch.splice(0, 6);
                    $scope.isRemove = true;
                }
                if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') >= 0) {
                    var selectedSectionForSOtypeSta = {
                        'item': 'Info Section',
                        'relatedSection': 'CustomerSection',
                        'sectionType': [{
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }, {
                            'Object': 'Kit:',
                            'Value': 'Kit_Header__c'
                        }, {
                            'Object': 'Fee:',
                            'Value': 'Fee__c'
                        }, {
                            'Object': 'Labor:',
                            'Value': 'Labour_Code__c'
                        }, {
                            'Object': 'Sublet:',
                            'Value': 'Product__c'
                        }]
                    };
                    itemsInSearch = selectedSectionForSOtypeSta['sectionType'];
                }
                if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') >= 0) {
                    var selectedSectionForSOtypeSta = {
                        'item': 'Deal Section',
                        'relatedSection': 'DealSection',
                        'sectionType': [{
                            'Object': 'Stock Unit:',
                            'Value': 'Customer_Owned_Unit__c'
                        }, {
                            'Object': 'COU:',
                            'Value': 'Customer_Owned_Unit__c'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }, {
                            'Object': 'Labor:',
                            'Value': 'Labour_Code__c'
                        }, {
                            'Object': 'Kit:',
                            'Value': 'Kit_Header__c'
                        }, {
                            'Object': 'Fee:',
                            'Value': 'Fee__c'
                        }, {
                            'Object': 'Warranty:',
                            'Value': 'Product__c'
                        }, {
                            'Object': 'Other Product:',
                            'Value': 'Product__c'
                        }, {
                            'Object': 'Sublet:',
                            'Value': 'Product__c'
                        }]
                    };
                    itemsInSearch = selectedSectionForSOtypeSta['sectionType'];
                }
                if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') >= 0) 
                {
                    var selectedSectionForSOtypeSta = {
                        'item': 'Deal Merchandise',
                        'relatedSection': 'DealMerchandiseSection',
                        'sectionType': [{
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }, {
                            'Object': 'Kit:',
                            'Value': 'Kit_Header__c'
                        }]
                    };
                    itemsInSearch = selectedSectionForSOtypeSta['sectionType'];
                }
                if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealFinancingSection') >= 0) {
                    var selectedSectionForSOtypeSta = {
                        'item': 'Deal Financing Section',
                        'relatedSection': 'DealFinancingSection',
                        'sectionType': [{
                            'Object': 'Finance:',
                            'Value': 'Product__c'
                        }]
                    };
                    itemsInSearch = selectedSectionForSOtypeSta['sectionType'];
                }
                if (str == '' || str == null) {
                    for (var i = 0; i < itemsInSearch.length; i++) {
                        responseData.push({
                            AdditionalDetailsForPart: null,
                            Description: null,
                            Info: "Object",
                            Name: itemsInSearch[i].Object,
                            Value: itemsInSearch[i].Value
                        });
                    }
                    $scope.searching = false;
                    $scope.processResults(responseData, str);
                } else {
                    var ObjectLabel = ''
                    if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'Stock Unit:') { 
                        var filterParam = [{
                            "Field": "Status__c",
                            "Value": 'Available',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }];
                    }
                    if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'COU:') { 
                        var filterParam = [{
                            "Field": "Unit_Type__c",
                            "Value": 'COU',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }, {
                            "Field": "Account__c",
                            "Value": $scope.selectedObject.Customer.Value,
                            "FilterObject": "Customer_Owned_Unit__c"
                        }, {
                            "Field": "Status__c",
                            "Value": 'Active',
                            "FilterObject": "Customer_Owned_Unit__c"
                        }];
                    } else if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'Warranty:') { 
                        var filterParam = [{
                            "Field": "Type__c",
                            "Value": 'Warranty Plan',
                            "FilterObject": "Product__c"
                        }];
                    } else if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'Finance:') { 
                        var filterParam = [{
                            "Field": "Type__c",
                            "Value": 'Financing Product',
                            "FilterObject": "Product__c"
                        }, {
                            "Field": "Vendor__c",
                            "Value": $scope.selectedObject.DealFinanceList.FinanceCompanyId,
                            "FilterObject": "Product__c"
                        }];
                    } else if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'Other Product:') { 
                        var filterParam = [];
                        filterParam = [{
                            "Field": "Type__c",
                            "Value": 'Deal Product',
                            "FilterObject": "Product__c"
                        }, {
                            "Field": "Type__c",
                            "Value": 'Financing Product',
                            "FilterObject": "Product__c"
                        }, {
                            "Field": "Type__c",
                            "Value": 'Third Party',
                            "FilterObject": "Product__c"
                        }];
                    } else if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected.Name == 'Sublet:') { 
                        var filterParam = [{
                            "Field": "Type__c",
                            "Value": 'Sublet',
                            "FilterObject": "Product__c"
                        }];
                    }
                    if ($scope.selectedObject.ObjectSelected && $scope.selectedObject.ObjectSelected.Name != null && $scope.selectedObject.ObjectSelected.Name != undefined) {
                        ObjectLabel = $scope.selectedObject.ObjectSelected['Value'];
                    } else {
                        for (var i = 0; i < itemsInSearch.length; i++) {
                            ObjectLabel += (ObjectLabel == '' ? itemsInSearch[i].Value : ',' + itemsInSearch[i].Value)
                            if (itemsInSearch[i].Object == 'Stock Unit:') {
                                filterParam = [{
                                    "Field": "Status__c",
                                    "Value": 'Available',
                                    "FilterObject": "Customer_Owned_Unit__c"
                                }];
                            }
                            if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealFinancingSection') >= 0) {  
                                filterParam = [{
                                    "Field": "Type__c",
                                    "Value": 'Financing Product',
                                    "FilterObject": "Product__c"
                                }, {
                                    "Field": "Vendor__c",
                                    "Value": $scope.selectedObject.DealFinanceList.FinanceCompanyId,
                                    "FilterObject": "Product__c"
                                }];
                            }
                            if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') >= 0) {  
                                if (itemsInSearch[i].Object == 'Sublet:') {
                                    filterParam = [{
                                        "Field": "Type__c",
                                        "Value": 'Sublet',
                                        "FilterObject": "Product__c"
                                    }];
                                }
                            }
                        }
                    }
                    var searchQueryJson = {
                        "ObjectLabel": "",
                        "SearchText": str,
                        "PreferredObject": "Customer",
                        "SearchableObjects": ObjectLabel.replace(':', ''),
                        "FilterValues": (filterParam == undefined || filterParam == '') ? [] : filterParam
                    }
                    searchQueryJson = JSON.stringify(searchQueryJson);
                    userService.searchText(searchQueryJson).then(function(successfulSearchResult) {
                        responseData = successfulSearchResult;
                        $scope.searching = false;
                        $scope.processResults((($scope.dataField) ? responseData[$scope.dataField] : responseData), str);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        $scope.searching = false;
                    });
                }
            }

            function setNoResultFoundConidtion() {
                $scope.searching = false;
                $scope.results = [];
            }
            $scope.searchTimerComplete = function(str) {
                if (str != null) {
                    if (str.length >= $scope.minLength) {
                        if ($scope.selectedObject.SelectedSection.relatedSection == 'CustomerSection' && $scope.selectedObject.coHeaderDetails.SellingGroup == 'Internal Service') {
                            setNoResultFoundConidtion();
                            return;
                        } else {
                            $scope.SerachSuggestion(str);
                        }
                    } else if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') >= 0) {
                        $scope.SerachSuggestion("");
                    }
                } else {
                    $scope.SerachSuggestion("");
                }
            };
            $scope.hideResults = function() {
                $scope.hideTimer = $timeout(function() {
                    $scope.selectedObject.searchDivActive = false;
                    $scope.showDropdown = false;
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    $scope.selectedObject.populateLeftSideHeadingLables();
                }, $scope.pause);
            };
            $scope.resetHideResults = function() {
                if ($scope.hideTimer) {
                    $timeout.cancel($scope.hideTimer);
                };
            };
            $scope.hoverRow = function(index) {
                var inputFieldEle = elem.find('.angucomplete-row');
                inputFieldEle.addClass('angucomplete-selected-rowHover');
                $scope.currentIndex = index;
                $scope.GetGhostLine();
            }
            $scope.GetGhostLine = function() {
                if ($scope.results[$scope.currentIndex]["description"] == "Merchandise" && $scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') < 0 && $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') < 0 && $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') < 0) {
                    var GhostKeys = $scope.results[$scope.currentIndex].originalObject["AdditionalDetailsForPart"];
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    $scope.selectedObject.MerchandiseGhostItems.push(GhostKeys);
                } else {
                    $scope.selectedObject.MerchandiseGhostItems = [];
                }
                $scope.selectedObject.populateLeftSideHeadingLables();
            }
            $scope.keyPressed = function(event) {
                if (!(event.which == 38 || event.which == 40 || event.which == 13)) {
                    if (!$scope.searchStr || $scope.searchStr == "") {
                        $scope.showDropdown = false;
                        $scope.lastSearchTerm = null
                    } else if (isNewSearchNeeded($scope.searchStr, $scope.lastSearchTerm)) {
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
                    if ($scope.results && $scope.results.length > 0 && !($scope.currentIndex >= 0 && $scope.currentIndex < $scope.results.length)) { 
                        if ($scope.currentIndex != -1) {
                            if ($scope.results[0]["description"] == "Merchandise") {
                                var GhostKeys = $scope.results[0].originalObject["AdditionalDetailsForPart"];
                                $scope.selectedObject.MerchandiseGhostItems = [];
                                $scope.selectedObject.MerchandiseGhostItems.push(GhostKeys);
                            } else {
                                $scope.selectedObject.MerchandiseGhostItems = [];
                            }
                            $scope.selectedObject.populateLeftSideHeadingLables();
                            $scope.selectResult($scope.results[0]);
                            $scope.$apply();
                            event.preventDefault;
                            event.stopPropagation();
                        }
                    }
                } else {
                    event.preventDefault();
                }
            }
            $scope.selectResult = function(result) {
                angular.element('#CO_SearchToAdd_value').focus();
                if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') >= 0) {
                    var soIndex = parseInt($scope.selectedObject.SelectedSection.relatedSection.replace('ServiceOrderSection', '')); 
                    if ($scope.selectedObject.SOHeaderList[soIndex] != undefined && ($scope.selectedObject.SOHeaderList[soIndex].SOHeaderInfo.TransactionType == 'Third-Party' && $scope.selectedObject.SOHeaderList[soIndex].SOHeaderInfo.ProviderId == null)) { 
                        Notification.error($Label.angucomplete_Provider_Not_Selected);
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        $scope.searching = false;
                        return;
                    }
                    if (result["description"] == "Object") {
                        $scope.selectedObject.ObjectSelected = {
                            Name: result["title"],
                            Value: result.originalObject["title"]
                        }
                        $scope.selectedObject.ObjectSelected.Value = result.originalObject["Value"];
                        $scope.searchStr = "";
                    } else {
                        var Name = result.originalObject["Name"];
                        var Value = result.originalObject["Value"];
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        $scope.searching = false;
                        if (result["description"] != "AdditionalResults") {
                            $scope.selectedObject.addServiceItem(Name, Value, result);
                        }
                    }
                } else if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') >= 0 && result["description"] != 'Unit') {
                    if (result["description"] == "Object") {
                        $scope.selectedObject.ObjectSelected = {
                            Name: result["title"],
                            Value: result.originalObject["title"]
                        }
                        $scope.selectedObject.ObjectSelected.Value = result.originalObject["Value"];
                        $scope.searchStr = "";
                    } else {
                        var Name = result.originalObject["Name"];
                        var Value = result.originalObject["Value"];
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        $scope.searching = false;
                        if (result["description"] != "AdditionalInfo") { 
                            $scope.selectedObject.saveOptionFeesLineItem($scope.selectedObject.DealInfo.Id, result);
                        }
                    }
                } else if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealFinancingSection') >= 0) {
                    if (result["description"] == "Object") {
                        $scope.selectedObject.ObjectSelected = {
                            Name: result["title"],
                            Value: result.originalObject["title"]
                        }
                        $scope.selectedObject.ObjectSelected.Value = result.originalObject["Value"];
                        $scope.searchStr = "";
                    } else {
                        var Name = result.originalObject["Name"];
                        var Value = result.originalObject["Value"];
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        $scope.searching = false;
                        $scope.selectedObject.saveFAndIProductLineItemFromSta($scope.selectedObject.DealInfo.Id, result.originalObject);
                    }
                }
                else if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') >= 0) {
                    if (result["description"] == "Object") {
                        $scope.selectedObject.ObjectSelected = {
                            Name: result["title"],
                            Value: result.originalObject["title"]
                        }
                        $scope.selectedObject.ObjectSelected.Value = result.originalObject["Value"];
                        $scope.searchStr = "";
                    } else {
                        var Name = result.originalObject["Name"];
                        var Value = result.originalObject["Value"];
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        $scope.searching = false;
                        if (result["description"] == 'Merchandise') {
                            $scope.SaveMerchandiseSearchSource('DealMerchandiseSection', result.originalObject["AdditionalDetailsForPart"]);
                        } else if (result["description"] == 'Kit') {
                            $scope.selectedObject.insertKitHeaderInDealMerchGrid(result.originalObject.Value, $scope.selectedObject.DealInfo.Id, $scope.selectedObject.coHeaderId);
                        }
                    }
                } else {
                    if ($scope.matchClass) {
                        result.title = result.title.toString().replace(/(<([^>]+)>)/ig, '');
                    }
                    if (result["description"] == "Object") {
                        $scope.selectedObject.ObjectSelected = {
                            Name: result["title"],
                            Value: result.originalObject["title"]
                        }
                        $scope.selectedObject.ObjectSelected.Value = result.originalObject["Value"];
                        $scope.searchStr = "";
                    } else if ($scope.selectedObject.SelectedSection['item'] == 'Info Section' && ((result["description"]) == "Merchandise" || (result["description"]) == "Kit" || (result["description"]) == "Fee") && !($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                        $scope.showDropdown = false;
                        $scope.results = [];
                        $scope.searchStr = "";
                        Notification.error("Can't add Item in Merchandise Section ");
                        return;
                    } else if ((result["description"]) == "Customer") {
                        if ($scope.selectedObject.DealTradeInList != undefined) {
                            if ($scope.selectedObject.DealTradeInList.length > 0) {
                                Notification.error($Label.angucomplete_Customer_Change);
                                return;
                            }
                        }
                        $scope.selectedObject.result = result;
                        if ($scope.selectedObject.coHeaderDetails.COType == 'Customer' || $scope.selectedObject.coHeaderDetails.COType == 'Cash Sale') {
                            $scope.selectedObject.openSwitchCOConfirmModal(false, false);
                            $scope.showDropdown = false;
                            $scope.results = [];
                            if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected != null && $scope.selectedObject.ObjectSelected != "" && $scope.selectedObject.ObjectSelected.Name != undefined && $scope.selectedObject.ObjectSelected.Name != null && $scope.selectedObject.ObjectSelected.Name != "") {
                                $scope.selectedObject.ObjectSelected.Name = "";
                                $scope.searchStr = "";
                            }
                            return;
                        }
                        if ($scope.selectedObject.coHeaderDetails.COType == 'Internal Service') {
                            Notification.error('Cannot add customer to Internal Service CO');
                        } else {
                            userService.addCustomer($scope.selectedObject.coHeaderId, result.originalObject["Value"]).then(function(successfulSearchResult) {
                                $scope.selectedObject.Customer = {
                                    Name: result["title"],
                                    Value: result.originalObject["Value"]
                                }
                                if ($scope.selectedObject.coHeaderId == null || $scope.selectedObject.coHeaderId == 'undefined') {
                                    $scope.selectedObject.coHeaderId = successfulSearchResult.coHeaderRec.COHeaderId;
                                    $scope.selectedObject.loadCOonAdd();
                                }
                                $scope.selectedObject.coHeaderDetails = successfulSearchResult.coHeaderRec;
                                $scope.selectedObject.CardInfo = successfulSearchResult.CardInfo;
                                $scope.selectedObject.UpdateMerchandiseFromSearchResult(successfulSearchResult, false);
                                $scope.selectedObject.COUList = successfulSearchResult.COUList;
                                $scope.selectedObject.populateLeftSideHeadingLables();
                            }, function(errorSearchResult) {
                                Notification.error(errorSearchResult);
                                $scope.searching = false;
                                $scope.selectedObject.MerchandiseGhostItems = [];
                            });
                        }
                        $scope.searchStr = "";
                    } else if (result["description"] == "User") {
                        $scope.selectedObject.User = {
                            Name: result["title"],
                            Value: result.originalObject["Value"]
                        }
                        $scope.searchStr = "";
                    } else if (result["description"] == "Merchandise") {
                        $scope.SaveMerchandiseSearchSource();
                        $scope.searchStr = "";
                    } else if (result["description"] == "AdditionalResults") {
                        $scope.searchStr = "";
                    } else if (result["description"] == "Unit") {
                        if ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealSection') >= 0 && result["description"] == 'Unit' && $scope.selectedObject.ObjectSelected.Name == 'COU:') { 
                            $scope.SaveTradeInUnit(result.originalObject["Value"]);
                            $scope.searchStr = "";
                        } else {
                            $scope.SaveDealUnit(result.originalObject["Value"]);
                            $scope.searchStr = "";
                            $scope.selectedObject.changeIndex = undefined;
                        }
                    } else if (result["title"] == "+Add New Customer:") {
                        $scope.searchStr = "";
                        if ($scope.selectedObject.coHeaderDetails.COType == 'Customer' || $scope.selectedObject.coHeaderDetails.COType == 'Cash Sale') {
                            $scope.selectedObject.openSwitchCOConfirmModal(false, true);
                            $scope.showDropdown = false;
                            $scope.results = [];
                            return;
                        }
                    } else if (result["title"] == "+Add New Merchandise:") {
                        $scope.searchStr = "";
                        $scope.selectedObject.CreateMerchandiseFromCO();
                    } else if (result["title"] == "+Add New Kit:") {
                        $scope.searchStr = "";
                        $scope.selectedObject.CreateKitFromCO();
                    } else if (result["title"] == "+Add New Labour:") {
                        $scope.searchStr = "";
                        $scope.selectedObject.CreateLabourFromCO();
                    } else if (result["title"] == "+Add New Fee:") {
                        $scope.searchStr = "";
                        $scope.selectedObject.CreateFeeFromCO();
                    } else if (result["title"] == "ADVANCE SEARCH") {
                        $scope.searchStr = "";
                        loadState($state, 'HomeSearch');
                    } else if (result["description"] == "Kit") {
                        userService.insertKitHeaderInMerchGrid(result.originalObject["Value"], $scope.selectedObject.coHeaderId).then(function(successfulSearchResult) {
                            $scope.selectedObject.UpdateMerchandiseFromSearchResult(successfulSearchResult, true);
                            $scope.selectedObject.COUList = successfulSearchResult.COUList;
                            $scope.selectedObject.populateLeftSideHeadingLables();
                        });
                    } else if (result["description"] == "Fee") {
                        userService.insertFeeInMerchGrid(result.originalObject["Value"], $scope.selectedObject.coHeaderId).then(function(successfulSearchResult) {
                            $scope.selectedObject.UpdateMerchandiseFromSearchResult(successfulSearchResult, true);
                            $scope.selectedObject.COUList = successfulSearchResult.COUList;
                            $scope.selectedObject.populateLeftSideHeadingLables();
                            $scope.selectedObject.coHeaderDetails = successfulSearchResult.coHeaderRec;
                            $scope.selectedObject.coHeaderId = successfulSearchResult.coHeaderRec.COHeaderId;
                        });
                    } else if (result["description"] == "") {
                        $scope.searchStr = "";
                        $scope.selectedObject.CreateCustomerFromCO();
                    } else {
                        $scope.searchStr = $scope.lastSearchTerm = result.title;
                    }
                    $scope.showDropdown = false;
                    $scope.results = [];
                }
                if (result["description"] != "Object" && ($scope.selectedObject.ObjectSelected != undefined && $scope.selectedObject.ObjectSelected != null && $scope.selectedObject.ObjectSelected != "" && $scope.selectedObject.ObjectSelected.Name != undefined && $scope.selectedObject.ObjectSelected.Name != null && $scope.selectedObject.ObjectSelected.Name != "")) {
                    $scope.selectedObject.ObjectSelected.Name = "";
                    $scope.searchStr = "";
                }
            }
            $scope.SaveTradeInUnit = function(selectedItemId) {
                $scope.selectedObject.UpdateTradeInSection(0);
                $scope.selectedObject.setTradeInCurrentCOU(selectedItemId, $scope.selectedObject.DealTradeInList.length - 1);
            }
            $scope.SaveDealUnit = function(selectedItemId) {
                if ($scope.selectedObject.DealInfo.DealStatus != 'Quotation') {
                    Notification.error($Label.CustomerOrder_Js_After_commit_and_install);
                    return;
                }
                for (i = 0; i < $scope.selectedObject.DealItemList.length; i++) {
                    if ($scope.selectedObject.DealItemList[i].DealItemObj.UnitId == selectedItemId) {
                        Notification.error($Label.angucomplete_Unit_Already_Exist);
                        return;
                    }
                }
                if ($scope.selectedObject.changeIndex == undefined || $scope.selectedObject.changeIndex == null) {
                    for (i = 0; i < $scope.selectedObject.DealItemList.length; i++) {
                        if ($scope.selectedObject.DealItemList[i].DealItemObj.Make == null && $scope.selectedObject.DealItemList[i].DealItemObj.UnitId == null) {
                            $scope.selectedObject.DealUnitId = $scope.selectedObject.DealItemList[i].DealItemObj.Id;
                            $scope.selectedObject.DealUnitIndex = i;
                            break;
                        }
                    }
                }
                if ($scope.selectedObject.DealUnitIndex == undefined || $scope.selectedObject.DealUnitIndex == null) { 
                    $scope.selectedObject.DealUnitId = null;
                    $scope.selectedObject.DealUnitIndex = $scope.selectedObject.DealItemList.length;
                }
                userService.addUnitToDeal($scope.selectedObject.DealUnitId, selectedItemId, $scope.selectedObject.DealInfo.Id).then(function(successfulSearchResult) {
                    $scope.selectedObject.DealItemList = successfulSearchResult.UnitList;
                    $scope.selectedObject.DealInfo = successfulSearchResult.DealInfo;
                    $scope.selectedObject.DealSummaryObj = successfulSearchResult.DealSummaryObj;
                    setTimeout(function() {
                        $scope.selectedObject.editLineItemsForFactoryOptions();
                        $scope.selectedObject.editLineItemsForDealerInstalledOptions();
                        $scope.selectedObject.calculateFactoryTotal();
                        angular.element('#CO_SearchToAdd_value').blur();
                        $scope.selectedObject.editForBaseUnitPrice();
                        $scope.selectedObject.DealUnitId = null;
                        $scope.selectedObject.DealUnitIndex = null;
                    }, 10);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.searching = false;
                    $scope.selectedObject.MerchandiseGhostItems = [];
                });
            }
            $scope.SaveMerchandiseSearchSource = function(isFromDealMerchandiseSection, merchJson) { 
                var MerchendiseLineItem = [];
                var lineItemType = ''
                if (isFromDealMerchandiseSection != undefined) { 
                    if ($scope.selectedObject.DealInfo.DealStatus == 'Invoiced') {
                        Notification.error($Label.Cannot_Add_Lineitem_To_DealMerch_After_DealInvoice);
                        return;
                    }
                    MerchendiseLineItem.push(merchJson);
                    MerchendiseLineItem[0].DealId = $scope.selectedObject.DealInfo.Id; 
                    MerchendiseLineItem = JSON.stringify(MerchendiseLineItem);
                    lineItemType = 'DealMerchandise';
                } else {
                    MerchendiseLineItem = JSON.stringify($scope.selectedObject.MerchandiseGhostItems, function(key, val) {
                        if (key == '$$hashKey') {
                            return undefined;
                        }
                        return val;
                    });
                    lineItemType = 'Merchandise';
                }
                if (MerchendiseLineItem != undefined && JSON.parse(MerchendiseLineItem)[0].Status == 'Out of Stock' && $scope.selectedObject.coHeaderDetails.SellingGroup == 'Cash Sale') {
                    Notification.error($Label.CO_Special_Orders_not_added_in_Cash_Sale);
                    return;
                }
                var customerId = $scope.selectedObject.Customer.Value;
                if (!angular.isDefined(customerId)) {
                    customerId = null;
                }
                userService.checkDuplicateParts(JSON.parse(MerchendiseLineItem)[0].PartId, $scope.selectedObject.coHeaderId, MerchendiseLineItem, $scope.selectedObject.isSupressTrue, true, null, customerId).then(function(successfulSearchResult) {
                    if (angular.isDefined(successfulSearchResult.DuplicatePart)) {
                        $scope.selectedObject.openDuplicatePartModal($scope.selectedObject.coHeaderId, lineItemType, JSON.parse(MerchendiseLineItem), null)
                    } else {
                        $scope.selectedObject.bindMerchInsertResult(isFromDealMerchandiseSection, successfulSearchResult);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.searching = false;
                    $scope.selectedObject.MerchandiseGhostItems = [];
                });
            }
            $scope.selectedObject.bindMerchInsertResult = function(isFromDealMerchandiseSection, successfulSearchResult) {
                if (isFromDealMerchandiseSection != undefined) {
                    $scope.selectedObject.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.selectedObject.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.selectedObject.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.selectedObject.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.selectedObject.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.selectedObject.editLineItemsForDealMerchandise();
                    $scope.selectedObject.UpdateSpecialOrder($scope.selectedObject.SpecialOrder);
                    $scope.selectedObject.StockUnitMap();
                    $scope.selectedObject.DealMerchandiseItems_editRow[($scope.selectedObject.DealMerchandiseList.length - 1)].DealCOLIList[0].isEdit = true; 
                    $scope.selectedObject.DealMerchandiseEditOldCommitedValue = $scope.selectedObject.DealMerchandiseList[$scope.selectedObject.DealMerchandiseList.length - 1].COLIList[0].QtyCommitted; 
                    $scope.selectedObject.DealMerchandiseEditOldAvailableValue = $scope.selectedObject.DealMerchandiseList[$scope.selectedObject.DealMerchandiseList.length - 1].COLIList[0].AvaliablePartsQty; 
                    setTimeout(function() {
                        elementId = angular.element('#' + 'DealCOLI_Qty_Needed_Edit_' + ($scope.selectedObject.DealMerchandiseList.length - 1) + '_0').focus(); 
                        angular.element(elementId).find('input[type=text]').filter(':visible:first').focus();
                        $scope.selectedObject.scrollToPanel(null, 'DealMerchandiseSection');
                    }, 10);
                } else {
                    if ($scope.selectedObject.coHeaderId == null || $scope.selectedObject.coHeaderId == 'undefined') {
                        $scope.selectedObject.coHeaderDetails = successfulSearchResult.coHeaderRec;
                        $scope.selectedObject.coHeaderId = successfulSearchResult.coHeaderRec.COHeaderId;
                        $scope.selectedObject.loadCOonAdd();
                    }
                    $scope.searching = false;
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    $scope.selectedObject.hideMerchandiseSection = successfulSearchResult.coHeaderRec.HideMerchandiseSection; 
                    $scope.selectedObject.UpdateMerchandiseFromSearchResult(successfulSearchResult, true);
                    $scope.selectedObject.populateLeftSideHeadingLables();
                    setTimeout(function() {
                        if ($scope.selectedObject.SelectedSection != '#MerchandiseSection') angular.element("#CustomerOrder_MerchandiseItemGrid tr.Editable_row:last").find('input').filter(':first').focus();
                    }, 10);
                }
            }
            $scope.setSelectionRange = function(input, selectionStart, selectionEnd) {
                if (input.setSelectionRange) {
                    input.focus();
                    input.setSelectionRange(selectionStart, selectionEnd);
                } else if (input.createTextRange) {
                    var range = input.createTextRange();
                    range.collapse(true);
                    range.moveEnd('character', selectionEnd);
                    range.moveStart('character', selectionStart);
                    range.select();
                }
            };
            var inputField = elem.find('input');
            inputField.on('keyup', $scope.keyPressed);
            elem.on("keyup", function(event) {
                if (event.which === 40) {
                    if ($scope.results && ($scope.currentIndex + 1) < $scope.results.length) {
                        $scope.currentIndex++;
                        if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') >= 0 || $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') >= 0) {
                        } else {
                            $scope.GetGhostLine();
                        }
                        $scope.$apply(); //TODO
                        var inputFieldEle = elem.find('.angucomplete-row');
                        inputFieldEle.removeClass('angucomplete-selected-rowHover');
                        event.preventDefault;
                        event.stopPropagation();
                    }
                    $scope.$apply(); //TODO
                } else if (event.which == 38) {
                    if ($scope.currentIndex >= 1) {
                        $scope.currentIndex--;
                        if ($scope.selectedObject.SelectedSection.relatedSection.indexOf('ServiceOrderSection') >= 0 || $scope.selectedObject.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') >= 0) {
                        } else {
                            $scope.GetGhostLine();
                        }
                        var inputtextField = elem.find('input');
                        $scope.setSelectionRange(inputtextField, 1, 2);
                        $scope.$apply(); //TODO
                        event.preventDefault;
                        event.stopPropagation();
                    }
                } else if (event.which == 13) {
                    if ($scope.currentIndex != -1) {
                        if ($scope.results[$scope.currentIndex] != undefined && $scope.results[$scope.currentIndex]["description"] == "Customer" && $scope.selectedObject.DealTradeInList != undefined) {
                            if ($scope.selectedObject.DealTradeInList.length > 0) {
                                Notification.error($Label.angucomplete_Customer_Change);
                                return;
                            }
                        }
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
                    }
                } else if (event.which == 27) {
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    $scope.results = [];
                    $scope.showDropdown = false;
                    $scope.$apply();
                } else if (event.which == 8) {
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    if (($scope.lastSearchTerm == null || $scope.lastSearchTerm == "") && ($scope.testScopeVar == "0")) {
                        $scope.testScopeVar = 1;
                    } else if (($scope.lastSearchTerm == null || $scope.lastSearchTerm == "") && ($scope.testScopeVar == "1")) {
                        $scope.testScopeVar = 0;
                        $scope.selectedObject.ObjectSelected = "";
                        $scope.selectedObject.ObjectSelected = "";
                    }
                    $scope.$apply();
                } else if (event.which == 8) {
                    $scope.selectedObject.MerchandiseGhostItems = [];
                    $scope.showDropdown = true;
                    event.preventDefault;
                    event.stopPropagation();
                } else {
                    $scope.selectedObject.MerchandiseGhostItems = [];
                }
            });
        }
    };
}]);