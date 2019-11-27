define(['Routing_AppJs_PK', 'ViewKitServices', 'ViewKitDirectives', 'PartPopUpOnVendorOrderCtrl', 'CustomSearchToAddCtrl', 'DirPagination'],
    function (Routing_AppJs_PK, ViewKitServices, ViewKitDirectives, PartPopUpOnVendorOrderCtrl, CustomSearchToAddCtrl, DirPagination) {
        var injector = angular.injector(['ui-notification', 'ng']);

        Routing_AppJs_PK.controller('ViewKitCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$stateParams', '$state', 'kitInfoService', '$translate', function ($scope, $timeout, $q, $rootScope, $stateParams, $state, kitInfoService, $translate) {
            var Notification = injector.get("Notification");

            $scope.Viewkit = {};
            $scope.Viewkit.kitId = $stateParams.Id;
            $scope.Viewkit.ShowContent = false;
            $scope.Viewkit.HeaderUpdated = false;
            $scope.Viewkit.selectedItem = 'Info';
            $scope.SearchableObjectsModal = [{
                    "Name": "Part",
                    "Object": "Part__c"
                },
                {
                    "Name": "Labour",
                    "Object": "Labour_Code__c"
                },
                {
                    "Name": "Fee",
                    "Object": "Fee__c"
                }
            ];

            var sortOrderMap = {
                "ASC": "DESC",
                "DESC": ""
            };
            $scope.Viewkit.kitLineItemsPageSortAttrsJSON = {};

            $scope.Viewkit.setDefaultPageSortAttrs = function () {
                $scope.Viewkit.kitLineItemsPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "LastModifiedDate",
                        SortDirection: "DESC"
                    }]
                };
                try {
                    $scope.Viewkit.kitLineItemsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}

                $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "LastModifiedDate",
                        SortDirection: "DESC"
                    }]
                };
                try {
                    $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
                } catch (ex) {}
            }

            $scope.Viewkit.loadKitInfo = function () {
                var kitId = $scope.Viewkit.kitId;
                $scope.Viewkit.setDefaultPageSortAttrs();

                kitInfoService.getKitInfo(kitId, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                    $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                    $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                    $scope.Viewkit.TotalActiveOrder = kitInfo.TotalActiveOrder;
                    $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                    $scope.Viewkit.ActiveOrderList = kitInfo.ActiveOrderList;
                    $scope.Viewkit.ShowContent = true;
                    setTimeout(function () {
                        $scope.Viewkit.kitLineItemsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            }

            $scope.blurcallback = function () {
                if ($scope.Viewkit.kitInfo.FixedPrice == "" || $scope.Viewkit.kitInfo.FixedPrice == null || $scope.Viewkit.kitInfo.FixedPrice == undefined) {
                    $scope.Viewkit.kitInfo.FixedPrice = 0;
                }
                $scope.Viewkit.HeaderUpdated = true;
                $scope.Viewkit.updateKitHeader($scope.Viewkit.kitInfo.Id, JSON.stringify($scope.Viewkit.kitInfo), false);
            }

            $scope.Viewkit.updateKitContents = function (KitHeaderLineItemList) {
                $scope.Viewkit.kitContentsItems = KitHeaderLineItemList;
                $scope.Viewkit.kitContentsItems_editRow = [];
                for (i = 0; i < $scope.Viewkit.kitContentsItems.length; i++) {
                    $scope.Viewkit.kitContentsItems_editRow.push({
                        isEdit: false,
                        radioValue: 0
                    });
                }
            }

            $scope.Viewkit.editKitContentsItem = function (event, index) {
                if ($rootScope.GroupOnlyPermissions['Kits'].enabled) {
                    if (event.target['type'] == 'text' && event.type != 'keydown') {
                        return;
                    }
                    if (event.target.attributes.class != null &&
                        (event.target.className == "fa fa-check-square chksqure" || event.target.attributes.class.value.indexOf("chk_tick") != -1 ||
                            event.target.attributes.class.value.indexOf("chksqure") != -1)) {
                        var isEditModeEnabled = false;
                        var lineitem = [];
                        for (i = 0; i < $scope.Viewkit.kitContentsItems_editRow.length; i++) {
                            if ($scope.Viewkit.kitContentsItems_editRow[i].isEdit == true) {
                                isEditModeEnabled = true;
                                if (i != index) {
                                    $scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[i]), $scope.Viewkit.kitInfo.Id);
                                    $scope.Viewkit.kitContentsItems_editRow[i].isEdit = false;
                                } else {}
                            }
                        }
                        if (!isEditModeEnabled) {
                            $scope.Viewkit.kitContentsItems[index].IsFixedPrice = !$scope.Viewkit.kitContentsItems[index].IsFixedPrice;
                            $scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[index]), $scope.Viewkit.kitInfo.Id);
                        }
                    } else {
                        var isEditModeEnabled = false;
                        var lineitem = [];
                        for (i = 0; i < $scope.Viewkit.kitContentsItems_editRow.length; i++) {
                            if ($scope.Viewkit.kitContentsItems_editRow[i].isEdit == true) {
                                isEditModeEnabled = true;
                                $scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[i]), $scope.Viewkit.kitInfo.Id);
                            }
                            $scope.Viewkit.kitContentsItems_editRow[i].isEdit = false;
                        }
                        if (!isEditModeEnabled) {
                            $scope.Viewkit.kitContentsItems_editRow[index].isEdit = true;
                            $scope.Viewkit.oldDescriptionValue = $scope.Viewkit.kitContentsItems[index].ItemDescription;
                            setTimeout(function () {
                                angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                            }, 10);
                        }
                    }
                } else {
                    $scope.Viewkit.kitContentsItems_editRow[index].isEdit = false;
                }
            }

            $scope.Viewkit.updateKitLineItem = function (jsonString, kitHeaderId) {
                kitInfoService.updateKitLineItem(jsonString, kitHeaderId, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                    if (kitInfo.ResponseDetails.ResponseCode == '200' || kitInfo.ResponseDetails.ResponseCode == null) {
                        $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                        $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                        $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                        setTimeout(function () {
                            $scope.Viewkit.kitLineItemsPageSortAttrsJSON.ChangesCount++;
                        }, 10);
                        Notification.success($translate.instant('ViewKit_Kit_updated'));
                    } else {
                        Notification.error(kitInfo.ResponseDetails.ResponseMeassage);
                        $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                        $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                        $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                    }
                    $scope.Viewkit.oldDescriptionValue = '';
                }, function (errorSearchResult) {
                    $scope.Viewkit.kitInfo = errorSearchResult;
                    $scope.Viewkit.oldDescriptionValue = '';
                });
            }

            $scope.Viewkit.closeEditKitContentsRow = function () {
                for (i = 0; i < $scope.Viewkit.kitContentsItems_editRow.length; i++) {
                    if ($scope.Viewkit.kitContentsItems_editRow[i].isEdit == true) {
                        $scope.Viewkit.kitContentsItems_editRow[i].isEdit = false;
                    }
                }
            }

            $scope.Viewkit.editRowBlur = function (event, index) {
                if ($scope.Viewkit.kitContentsItems[index].QtyNeeded == "" || $scope.Viewkit.kitContentsItems[index].QtyNeeded == null || $scope.Viewkit.kitContentsItems[index].QtyNeeded == undefined) {
                    $scope.Viewkit.kitContentsItems[index].QtyNeeded = 1;
                }
                if ($scope.Viewkit.kitContentsItems[index].KitPrice == "" || $scope.Viewkit.kitContentsItems[index].KitPrice == null || $scope.Viewkit.kitContentsItems[index].KitPrice == undefined) {
                    $scope.Viewkit.kitContentsItems[index].KitPrice = 0;
                }
                if (event.keyCode == 9) {
                    $scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[index]), $scope.Viewkit.kitInfo.Id);
                }
            }

            $scope.Viewkit.EditRowBlurQtyNeedeed = function (event, index) {
                if(event.keyCode == 9) {
            		if ($scope.Viewkit.kitContentsItems[index].QtyNeeded == "" || $scope.Viewkit.kitContentsItems[index].QtyNeeded == null || $scope.Viewkit.kitContentsItems[index].QtyNeeded == undefined) {
                        $scope.Viewkit.kitContentsItems[index].QtyNeeded = 1;
                    }
            		if(!$scope.Viewkit.kitContentsItems[index].IsFixedPrice) {
            			$scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[index]), $scope.Viewkit.kitInfo.Id);
            		}
            	}
            }

            $scope.Viewkit.kitContentsGoAction = function (index) {
                $scope.Viewkit.kitContentsItems_editRow[index].isEdit = false;
                var isKitWithUnfixedPricePresent = false;

                if ($scope.Viewkit.kitInfo.IsFixedPrice != true || $scope.Viewkit.kitContentsItems[index].TotalPrice == 0) {
                    isKitWithUnfixedPricePresent = true;
                } else {
                    for (var i = 0; i < $scope.Viewkit.kitContentsItems.length; i++) {
                        if (i != index && $scope.Viewkit.kitContentsItems[i].IsFixedPrice != true) {
                            isKitWithUnfixedPricePresent = true;
                            break;
                        }
                    }
                }
                if (isKitWithUnfixedPricePresent == false) {
                    Notification.error($translate.instant('ViewKit_fixed_Price'));
                    return;
                }

                if ($scope.Viewkit.kitContentsItems_editRow[index].radioValue == 1) {
                    var kitLineItemId = $scope.Viewkit.kitContentsItems[index].Id;
                    kitInfoService.removeKitLineItem(kitLineItemId, $scope.Viewkit.kitInfo.Id, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON)
                        .then(function (kitInfo) {
                            var itemsGridNewPN = $scope.Viewkit.kitLineItemsPageSortAttrsJSON.CurrentPage;
                            if ($scope.Viewkit.TotalKitLineItems % $scope.Viewkit.kitLineItemsPageSortAttrsJSON.PageSize == 1) {
                                $scope.Viewkit.kitLineItemsPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                            }
                            if (kitInfo.ResponseDetails.ResponseCode == '200' || kitInfo.ResponseDetails.ResponseCode == null) {
                                $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                                $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                                $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                                Notification.success($translate.instant('ViewKit_Kit_updated'));
                            } else {
                                Notification.error(kitInfo.ResponseDetails.ResponseMeassage);
                                $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                                $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                                $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                            }
                        });
                }
            }

            $scope.Viewkit.updateKitHeader = function (kitHeaderId, JsonKitHeader, flag) {
                var sumOfFixedTotalPrice = 0;
                for (var i = 0; i < $scope.Viewkit.kitContentsItems.length; i++) {
                    if ($scope.Viewkit.kitContentsItems[i].IsFixedPrice == true) {
                        sumOfFixedTotalPrice = sumOfFixedTotalPrice + $scope.Viewkit.kitContentsItems[i].TotalPrice;
                    }
                }
                if ($scope.Viewkit.kitInfo.FixedPrice < sumOfFixedTotalPrice) {
                    Notification.error($translate.instant('ViewKit_Kit_Header_Total'));
                    return;
                }

                kitInfoService.updateKitHeader(kitHeaderId, JsonKitHeader, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                    if (kitInfo.ResponseDetails.ResponseCode == '200' || kitInfo.ResponseDetails.ResponseCode == null) {
                        $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                        $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                        $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                        $scope.Viewkit.ShowContent = true;
                        $scope.Viewkit.HeaderUpdated = false;
                        setTimeout(function () {
                            $scope.Viewkit.kitLineItemsPageSortAttrsJSON.ChangesCount++;
                        }, 10);
                        if ($scope.Viewkit.kitInfo.IsFixedPrice && flag) {
                            setTimeout(function () {
                                angular.element('#kitPrimaryRowTotal').focus();
                            }, 10);
                        }
                        Notification.success($translate.instant('ViewKit_Kit_updated'));
                    } else {
                        Notification.error(kitInfo.ResponseDetails.ResponseMeassage);
                        $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                        $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                        $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList)
                    }
                }, function (errorSearchResult) {
                    $scope.Viewkit.kitInfo = errorSearchResult;
                });
            }

            $scope.Viewkit.toggleKitPrimaryRowFixedChkBox = function () {
                if (!$rootScope.GroupOnlyPermissions['Kits'].enabled) {
                    return;
                }
                $scope.Viewkit.kitInfo.IsFixedPrice = !$scope.Viewkit.kitInfo.IsFixedPrice;
                $scope.Viewkit.updateKitHeader($scope.Viewkit.kitInfo.Id, JSON.stringify($scope.Viewkit.kitInfo), true);
            }

            $scope.Viewkit.toggleKitItemRowFixedChkBox = function (event, index) {
                var IsFixedPrice = !$scope.Viewkit.kitContentsItems[index].IsFixedPrice;
                if (IsFixedPrice) {
                    $scope.Viewkit.kitContentsItems[index].IsFixedPrice = true;
                    setTimeout(function () {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                } else {
                    $scope.Viewkit.kitContentsItems[index].IsFixedPrice = false;
                    $scope.Viewkit.updateKitLineItem(JSON.stringify($scope.Viewkit.kitContentsItems[index]), $scope.Viewkit.kitInfo.Id);
                }
            }

            $scope.SearchToadd = {};
            $scope.SearchableObjects = "Part__c,Labour_Code__c,Fee__c";
            $scope.typeToSearch = "";
            $scope.PreferredObject = "Merchandise";
            $scope.SelectedObjectValue = null;
            $scope.SetDetfault = function (selectedRecord) {
                $scope.SelectedObjectValue = null;
                $scope.SearchableObjects = 'Part__c,Labour_Code__c,Fee__c';
            }

            $scope.SearchToAddCallback = function (selectedRecord) {
                if (selectedRecord.ObjectType == "Object") {
                    $scope.SelectedObjectValue = selectedRecord.title;
                    for (i = 0; i < $scope.SearchableObjectsModal.length; i++) {
                        if ($scope.SearchableObjectsModal[i].Name == $scope.SelectedObjectValue) {
                            $scope.SearchableObjects = $scope.SearchableObjectsModal[i].Object
                        }
                    }
                } else {
                    $scope.SelectedObjectValue = "";
                    $scope.SearchableObjects = 'Part__c,Labour_Code__c,Fee__c';
                    if (selectedRecord.originalObject.Value != null) {
                        kitInfoService.insertKitLineItem($scope.Viewkit.kitInfo.Id, selectedRecord.originalObject.Value, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                            if (Object.keys(kitInfo).length != 0) {
                                if (kitInfo.ResponseDetails.ResponseCode == '200' || kitInfo.ResponseDetails.ResponseCode == null) {
                                    $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                                    $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                                    $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                                    $scope.Viewkit.kitContentsItems_editRow[kitInfo.KitHeaderLineItemList.length - 1].isEdit = true;
                                    $scope.Viewkit.oldDescriptionValue = kitInfo.KitHeaderLineItemList[kitInfo.KitHeaderLineItemList.length - 1].ItemDescription;
                                    setTimeout(function () {
                                        angular.element('#kitItem_totalPrice_' + (kitInfo.KitHeaderLineItemList.length - 1)).focus();
                                    }, 10);
                                    $scope.Viewkit.ShowContent = true;
                                    setTimeout(function () {
                                        $scope.Viewkit.kitLineItemsPageSortAttrsJSON.ChangesCount++;
                                    }, 10);

                                    $scope.Viewkit.HeaderUpdated = false;
                                    setTimeout(function () {
                                        angular.element('.gid_container_Customer.grid_container_row .edit_panel.sample-show-hide').find('input').filter(':first').focus();
                                    }, 10);
                                } else {
                                    Notification.error(kitInfo.ResponseDetails.ResponseMeassage);
                                    $scope.Viewkit.kitInfo = kitInfo.KitHeaderRec;
                                    $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                                    $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList)
                                }
                            }
                        }, function (errorSearchResult) {
                            //TODO
                        });
                    }
                }
            }

            $scope.Viewkit.editKitDetails = function () {
                var kitRelated_Json = {
                    kitRecord: $scope.Viewkit.kitInfo
                };
                loadState($state, 'ViewKit.EditKit', {
                    EditKitParams: kitRelated_Json
                });
            }

            $scope.Viewkit.newKitPopUp = function () {
                $scope.$broadcast('AddKitEvent');
            }

            $scope.Viewkit.displaySections = {
                'Info': true,
                'KitContents': true,
                'Related': true,
                'Statistics': true,
                'ActivityStream': true
            };

            $scope.Viewkit.activeSidepanelink = '#KitInfoSection';
            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function () {
                $scope.Viewkit.onScroll();
            });

            $scope.Viewkit.sidepanelLink = function (event, relatedContent) {
                event.preventDefault();
                angular.element(document).off("scroll");
                var target = angular.element(angular.element(event.target.closest('a'))).attr("href");
                var navBarHeightDiffrenceFixedHeaderOpen = 0;

                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 40;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
                }, 500, function () {
                    angular.element(document).on("scroll", function () {
                        $scope.Viewkit.onScroll();
                    });
                    $scope.Viewkit.onScroll();
                });
            }

            $scope.Viewkit.onScroll = function () {
                if ($state.current.name === 'ViewKit') {
                    var activeSidepanelink;
                    var selectedItem;
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;

                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 0;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 10;
                    }

                    var scrollPos = angular.element(document).scrollTop();
                    if (isElementDefined('#KitInfoSection') && (scrollPos < angular.element('#KitInfoSection').position().top + angular.element('#KitInfoSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        selectedItem = 'Info';
                        activeSidepanelink = '#KitInfoSection';
                    } else if (isElementDefined('#KitContentsSection') && (scrollPos < angular.element('#KitContentsSection').position().top + angular.element('#KitContentsSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        selectedItem = 'Kit Contents';
                        activeSidepanelink = '#KitContentsSection';
                    } else {
                        if ($scope.Viewkit.ActiveOrderList != undefined && $scope.Viewkit.ActiveOrderList.length != 0) {
                            if (isElementDefined('#RelatedSection') && (scrollPos < angular.element('#RelatedSection').position().top + angular.element('#RelatedSection').height() + 50 - navBarHeightDiffrenceFixedHeaderOpen)) {

                                activeSidepanelink = '#RelatedSection';
                            } else {
                                activeSidepanelink = '#RelatedSection';
                            }
                            selectedItem = 'Related';
                        } else {
                            activeSidepanelink = '#KitContentsSection';
                            selectedItem = 'Content';
                        }
                    }
                    $scope.Viewkit.activeSidepanelink = activeSidepanelink;
                    $scope.Viewkit.selectedItem = selectedItem;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }

            $scope.kitRecordSaveCallback = function (KitHeaderRec) {
                if ($scope.Viewkit.kitId.substring(0, 15) == KitHeaderRec.Id.substring(0, 15)) {
                    $scope.Viewkit.kitInfo = KitHeaderRec;
                }
            }

            $scope.setFocusToSearchBox = function () {
                angular.element('#SearchToAddKit').focus();
            }
            
            $scope.applyCssOnPartPopUp = function (event, className) {
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element(className).css('top', targetEle.offset().top);
                angular.element(className).css('left', event.clientX);
                setTimeout(function () {
                    angular.element(className).show();
                }, 1000);
            }

            var timer;
            $scope.Viewkit.openpartpopup = function (event, partId) {
                timer = $timeout(function () {
                    $scope.$broadcast('PartPopUpEvent', partId);
                    $scope.applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
                }, 1000);
            }

            $scope.Viewkit.hidePartPopUp = function () {
                $timeout.cancel(timer);
                angular.element('.Vendor-Order-Part-Popup').hide();
            }

            $scope.Viewkit.kitLineItemsPageSortControlsAction = function () {
                var newSortOrder = sortOrderMap[$scope.Viewkit.kitLineItemsPageSortAttrsJSON.Sorting[0].SortDirection];
                if (newSortOrder == null || newSortOrder == undefined) {
                    newSortOrder = "ASC";
                }
                $scope.Viewkit.kitLineItemsPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
                $scope.Viewkit.kitLineItemsPageSortAttrsJSON.CurrentPage = 1;
                $scope.Viewkit.Items_paginationControlsAction();
            }

            $scope.Viewkit.KitLineItems_paginationControlsAction = function () {
                var kitId = $scope.Viewkit.kitId;
                kitInfoService.getKitInfo(kitId, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                    $scope.Viewkit.TotalKitLineItems = kitInfo.TotalLineItem;
                    $scope.Viewkit.updateKitContents(kitInfo.KitHeaderLineItemList);
                    $scope.Viewkit.ShowContent = true;
                    setTimeout(function () {
                        $scope.Viewkit.kitLineItemsPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    $scope.Viewkit.kitInfo = errorSearchResult;
                });
            }

            $scope.Viewkit.KitActiveOrder_paginationControlsAction = function () {
                var kitId = $scope.Viewkit.kitId;
                kitInfoService.getKitInfo(kitId, $scope.Viewkit.kitLineItemsPageSortAttrsJSON, $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON).then(function (kitInfo) {
                    $scope.Viewkit.ActiveOrderList = kitInfo.ActiveOrderList;
                    $scope.Viewkit.ShowContent = true;
                    setTimeout(function () {
                        $scope.Viewkit.kitActiveOrdersPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    $scope.Viewkit.kitInfo = errorSearchResult;
                });
            }
            $scope.Viewkit.dropDownItem = function (event, selectedSection) {
                var activeSection = $scope.Viewkit.activeSidepanelink.replace('#', '');
                $scope.Viewkit.selectedItem = selectedSection;
                if (activeSection != selectedSection) {
                    $scope.Viewkit.sidepanelLink(event, selectedSection);
                }
            }
            
            $scope.Viewkit.populateOldDescValue = function (kitLineItem) {
            	kitLineItem.ItemDescription = (isBlankValue(kitLineItem.ItemDescription) && !isBlankValue($scope.Viewkit.oldDescriptionValue)) ?
            											$scope.Viewkit.oldDescriptionValue : kitLineItem.ItemDescription;
            }
            
            $scope.Viewkit.loadKitInfo();
        }]);
    });