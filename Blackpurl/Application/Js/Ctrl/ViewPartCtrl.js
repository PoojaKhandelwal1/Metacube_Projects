define(['Routing_AppJs_PK', 'ViewPartServices', 'ViewPartRelatedListServices', 'ViewPartInformationServices', 'mapsApiJs', 'PartPopUpOnVendorOrderCtrl', 'DirPagination', 'PartLocator'],
    function (Routing_AppJs_PK, ViewPartServices, ViewPartRelatedListServices, ViewPartInformationServices, mapsApiJs, PartPopUpOnVendorOrderCtrl, DirPagination, PartLocator) {
        var injector1 = angular.injector(['ui-notification', 'ng']);

        Routing_AppJs_PK.controller('ViewPartCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'PartInfoService', 'ActiveOrdersServices', 'ActiveSalesOrdersServices', 'AlternatePartsServices', 'TaxExemptionsServices', 'partOrderReceivingService', '$translate', function ($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, PartInfoService, ActiveOrdersServices, ActiveSalesOrdersServices, AlternatePartsServices, TaxExemptionsServices, partOrderReceivingService, $translate) {
            var Notification = injector1.get("Notification");

            $scope.ViewPart = {};
            $scope.CustomerModal = {};
            $scope.COUModal = {};
            $scope.ViewPart.disableModifyCostSummary = false;
            $scope.ViewPart.adjustPart = {};
            $scope.ViewPart.adjustPart.showAdjustPreview = true;
            $scope.ViewPart.adjustPart.isPreviewActive = true;
            $scope.ViewCustomer = {};
            $scope.modifyCostSoourceeditMode = true;
            $scope.currentSelectedBucket = {};
            $scope.ViewPart.OverSold = [];
            $scope.ViewPart.toggle = false;
            $scope.ViewPart.modifyCostSummaryModel = {};
            $scope.ViewPart.modifyCostSummaryModel.showPreview = true;
            $scope.ViewPart.adjustPart.SelectedInStock = 'select'
            $scope.ViewPart.PrintBarCodeValue = 'PrintBarCode';
            $scope.ViewPartRelatedListModal = {};
            $scope.SearchToadd = {};
            $scope.SearchableObjects = 'Part__c,Sales_Tax_Item__c';
            $scope.typeToSearch = "";
            $scope.PreferredObject = "Merchandise";
            $scope.ViewPart.PartLocator = {};
            
            var newUrl = window.location.origin;
            $scope.ViewPart.partId = $stateParams.Id;
            $scope.ViewPart.helpText = {
                General: $translate.instant('General_Help_Text'),
                Stocking: $translate.instant('Stocking_Help_Text'),
                Statistics: $translate.instant('Statistics_Help_Text'),
                VitalStatistics: $translate.instant('VitalStatistics_Help_Text'),
                Telemetry: $translate.instant('Telemetry_Help_Text'),
                Related: $translate.instant('Related_Help_Text'),
                ActiveOrders: $translate.instant('ActiveOrders_Help_Text'),
                ActiveSalesOrders: $translate.instant('ActiveSalesOrders_Help_Text'),
                AlternateParts: $translate.instant('AlternateParts_Help_Text'),
                TaxExemptions: $translate.instant('TaxExemptions_Help_Text'),
                CostSummary: $translate.instant('CostSummary_Help_Text'),
                CostDetails: $translate.instant('CostDetails_Help_Text')
            };
            
            $scope.ViewPart.displaySections = {
                'Info': true,
                'Statistics': true,
                'Related': true,
                'CostTracking': false
            };
            if ($rootScope.GroupOnlyPermissions['Costs']['read only']) {
                $scope.ViewPart.displaySections.CostTracking = true;
            }

            $scope.setFocusToSearchBox = function () {
                angular.element('#SearchToaddCutomer').focus();
            }

            $scope.ViewPart.activeSidepanelink = '#InfoSection';
            $scope.ViewPart.selectedItem = 'Info';

            $scope.ViewPart.dropDownItem = function (event, selectedSection) {
                var activeSection = $scope.ViewPart.activeSidepanelink.replace('#', '');
                $scope.ViewPart.selectedItem = selectedSection;
                if (activeSection != selectedSection) {
                    $scope.ViewPart.sidepanelLink(event, selectedSection);
                }
            }

            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function () {
                $scope.ViewPart.onScroll();
            });

            $scope.ViewPart.sidepanelLink = function (event, relatedContent) {
                event.preventDefault();
                if (relatedContent == 'CostTracking') {
                    $scope.ViewPart.displayCostTrackingSection(true);
                } else {
                    $scope.ViewPart.displaySections[relatedContent] = true;
                }

                angular.element(document).off("scroll");
                var target = angular.element(event.target.closest('a')).attr("href");
                var navBarHeightDiffrenceFixedHeaderOpen = 0;

                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 40;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                setTimeout(function () {
                    angular.element('html, body').stop().animate({
                        scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
                    }, 500, function () {
                        angular.element(document).on("scroll", function () {
                            $scope.ViewPart.onScroll();
                        });
                        $scope.ViewPart.onScroll();
                    });
                }, 10);
            }

            $scope.ViewPart.displayCostTrackingSection = function (isDisplaySection) {
                if ($rootScope.GroupOnlyPermissions['Costs']['read only']) {
                    $scope.ViewPart.displaySections.CostTracking = isDisplaySection;
                } else {
                    $scope.ViewPart.displaySections.CostTracking = false;
                }
            }
            $scope.ViewPart.onScroll = function () {
                if ($state.current.name === 'ViewPart') {
                    var activeSidepanelink;
                    var selectedItem;
                    var heading = '';
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;

                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 40;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 50;
                    }

                    var scrollPos = angular.element(document).scrollTop();
                    if (isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + 95 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#InfoSection';
                        selectedItem = 'Info';
                    } else if (isElementDefined('#StatisticsSection') && (scrollPos < angular.element('#StatisticsSection').position().top + angular.element('#StatisticsSection').height() + 95 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#StatisticsSection';
                        selectedItem = 'Statistics';
                    } else if (isElementDefined('#RelatedSection') && (scrollPos < angular.element('#RelatedSection').position().top + angular.element('#RelatedSection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#RelatedSection';
                        selectedItem = 'Related';
                    } else if (isElementDefined('#CostTrackingSection') && (scrollPos < angular.element('#CostTrackingSection').position().top + angular.element('#CostTrackingSection').height() + 80 - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#CostTrackingSection';
                        selectedItem = 'Cost Tracking';
                    } else {
                        activeSidepanelink = '#CostTrackingSection';
                        selectedItem = 'Cost Tracking';
                    }

                    $scope.ViewPart.activeSidepanelink = activeSidepanelink;
                    $scope.ViewPart.selectedItem = selectedItem;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }

            $scope.ViewPart.getLocations = function () {
                if ($scope.ViewPart.PartInfo != undefined && $scope.ViewPart.PartInfo.PartDetailRec.Location != null) {
                    return $scope.ViewPart.PartInfo.PartDetailRec.Location.split(';');
                }
            }

            $scope.ViewPart.currentStock = true;
            $scope.ViewPart.changeActiveButton = function (item) {
                $scope.ViewPart.activeButton = item;
                $rootScope.$broadcast('activeButtonChanged', {
                    item: $scope.ViewPart.activeButton
                });

            }

            $scope.ViewPart.PrintBarCode = function (partJSON) {
            	loadState($state, 'ViewPart.PrintBarCode', {
                    PrintBarCodeParams: {
                        partJSON: partJSON
                    }
                });

            }

            $scope.ViewPart.calculateSidebarHeight = function () {
                windowheight = screen.height;
                var leftPanelLinks = windowheight - (angular.element(".headerNav").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + 52); //window
                angular.element(".leftPanelLinks").css("height", leftPanelLinks);

            }

            $scope.ViewPart.loadPartInfo = function () {
                var partId = $scope.ViewPart.partId;
                PartInfoService.getPartInfo(partId).then(function (partInfo) {
                    $scope.ViewPart.PartInfo = partInfo;
                    $scope.ViewPart.bindPartData(partInfo);
                    $scope.ViewPart.ShowContent = true;
                    $scope.ViewPart.changeActiveButton('CurrentStock');
                    setTimeout(function () {
                        $scope.ViewPart.calculateSidebarHeight();
                    }, 10);
                    $scope.ViewPartRelatedListModal.PartRelatedInfo = partInfo.PartRelatedInfo;
                    $scope.ViewPart.PartInfo.PartFIFOBucketList = partInfo.PartFIFOBucketList;
                    $scope.ViewPartRelatedListModal.PartId = $scope.ViewPart.partId;
                    $scope.ViewPartRelatedListModal.PartIsTaxable = $scope.ViewPart.PartInfo.PartDetailRec.IsTaxable;
                    $scope.ViewPartRelatedListModal.initModals();
                    $scope.SearchToAddCallback = $scope.ViewPartRelatedListModal.searchToAddCallback;
                    $scope.ViewPart.openpartpopupOnLoad($scope.ViewPart.partId);
                    $scope.ViewPart.isrefresh = false;
                }, function (errorSearchResult) {
                    $scope.ViewPart.PartInfo = errorSearchResult;
                    $scope.ViewPart.isrefresh = false;
                });
            }

            $scope.ViewPart.bindPartData = function (partInfo) {
                $scope.ViewPart.PartInfo = partInfo;
                $scope.PartPopUpOnLoad.partModel = partInfo.PartDetailRec;
                $scope.ViewPart.ShowContent = true;
                $scope.ViewPartRelatedListModal.PartRelatedInfo = partInfo.PartRelatedInfo;
                $scope.ViewPart.PartInfo.PartFIFOBucketList = partInfo.PartFIFOBucketList;

                for (var i = 0; i < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; i++) {
                    $scope.ViewPart.PartInfo.PartFIFOBucketList[i].isEdit = false;
                    if ($scope.ViewPart.PartInfo.PartFIFOBucketList.length == 0 || $scope.ViewPart.PartInfo.PartFIFOBucketList[i].SourceName.replace(' ', '') == 'VendorReceiving' || $scope.ViewPart.PartInfo.PartFIFOBucketList[i].RemainingQty == 0) {
                        $scope.ViewPart.disableModifyCostSummary = true;
                    }
                }
                $scope.ViewPartRelatedListModal.PartId = $scope.ViewPart.partId;
                $scope.ViewPartRelatedListModal.PartIsTaxable = $scope.ViewPart.PartInfo.PartDetailRec.IsTaxable;
                $scope.ViewPartRelatedListModal.initModals();
                $scope.SearchToAddCallback = $scope.ViewPartRelatedListModal.searchToAddCallback;
                $scope.PartPopUpOnLoad.loadChart();
            }

            $scope.ViewPart.createPart = function () {
                $rootScope.$broadcast('AddPartEvent');
            }

            $scope.ViewPart.editPart = function () {
                var partRelated_Json = {
                    Id: $scope.ViewPart.partId
                };
                loadState($state, 'ViewPart.EditPart', {
                    EditPartParams: partRelated_Json
                });
            }

            $scope.partRecordSaveCallback = function () {
                $scope.ViewPart.loadPartInfo();
            }
            $scope.ViewPart.adjustStock = function () {
                var stockAdjsutmentList = [];
                for (var i = 0; i < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; i++) {
                    if ($scope.ViewPart.PartInfo.PartFIFOBucketList[i].RemainingQty > 0) {
                        stockAdjsutmentList.push($scope.ViewPart.PartInfo.PartFIFOBucketList[i]);
                    }
                }
                var PartAdjustmentInStockJSON = {
                    partId: $scope.ViewPart.partId,
                    stockAdjsutmentList: stockAdjsutmentList,
                    PartDetail: $scope.ViewPart.PartInfo.PartDetailRec
                };
                if ($rootScope.GroupOnlyPermissions['Costs']['modify']) {
                    loadState($state, 'ViewPart.PartAdjustmentInStock', {
                        PartAdjustmentInStockParams: PartAdjustmentInStockJSON
                    });
                }
            }
            
            $scope.ViewPart.openResolveOversoldPopup = function (event, partId) {
                if (!$rootScope.GroupOnlyPermissions['Costs']['modify']) {
                    return;
                }
                $scope.ViewPart.OverSold = [];
                $scope.ViewPart.OverSold.Total = 0;
                $scope.ViewPart.OverSold.Quantity = 0;
                for (var i = 0; i < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; i++) {
                    if ($scope.ViewPart.PartInfo.PartFIFOBucketList[i].SourceName == 'Oversold' && $scope.ViewPart.PartInfo.PartFIFOBucketList[i].RemainingQty < 0) {
                        $scope.ViewPart.OverSold.Total += -($scope.ViewPart.PartInfo.PartFIFOBucketList[i].Total);
                        $scope.ViewPart.OverSold.Quantity += -($scope.ViewPart.PartInfo.PartFIFOBucketList[i].RemainingQty);
                        $scope.ViewPart.OverSold.push($scope.ViewPart.PartInfo.PartFIFOBucketList[i]);
                    }
                }
                if ($scope.ViewPart.OverSold.length == 0) {
                    Notification.error($translate.instant('NewViewPart_Oversold_Item'));
                } else {
                    loadState($state, 'ViewPart.ResolveOversold', {
                        ResolveOversoldParams: {
                            oversoldJson: $scope.ViewPart.OverSold
                        }
                    });
                }
            }
            
            $scope.ViewPart.showHideRecords = function () {
                $scope.ViewPart.toggle = !$scope.ViewPart.toggle;
                PartInfoService.showHideFifoRecords($scope.ViewPart.partId, $scope.ViewPart.toggle).then(function (successfulSearchResult) {
                        $scope.ViewPart.PartInfo.PartFIFOBucketList = successfulSearchResult;
                    },
                    function (errorSearchResult) {
                        responseData = errorSearchResult;
                    });
            }
            
            $scope.$on('OversoldUpdate', function (event, args) {
                $scope.ViewPart.bindPartData(args);
                $scope.ViewPart.toggle = false;

            });
            
            $scope.$on('ModifyCostSourceUpdateBucketEvent', function (event, args) {
                $scope.currentSelectedBucket = {};
                $scope.modifyCostSoourceeditMode = true;
            });
            
            $scope.ViewPart.updateFifoBucketLineItem = function (FifoBucketHeaderIndex) {
                for (var i = 0; i < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; i++) {
                    if (i != FifoBucketHeaderIndex) {
                        $scope.ViewPart.PartInfo.PartFIFOBucketList[i].isEdit = false;
                    } else {
                        $scope.ViewPart.PartInfo.PartFIFOBucketList[FifoBucketHeaderIndex].isEdit = !$scope.ViewPart.PartInfo.PartFIFOBucketList[FifoBucketHeaderIndex].isEdit;
                    }
                }
                if ($scope.ViewPart.PartInfo.PartFIFOBucketList[FifoBucketHeaderIndex].SourceName != 'Vendor Receiving' && $scope.ViewPart.PartInfo.PartFIFOBucketList[FifoBucketHeaderIndex].SourceName != 'Vendor recieving' && $scope.ViewPart.PartInfo.PartFIFOBucketList[FifoBucketHeaderIndex].SourceName != 'Oversold') {
                    $scope.modifyCostSoourceeditMode = false;
                }
            }
            
            $scope.ViewPart.openModifyCostSourcePopup = function (event) {
                if (!$rootScope.GroupOnlyPermissions['Costs']['modify']) {
                    return;
                }
                for (var index = 0; index < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; index++) {
                    var fifobucket = $scope.ViewPart.PartInfo.PartFIFOBucketList[index];

                    if (fifobucket.isEdit == true) {
                        $scope.currentSelectedBucket = fifobucket;
                    }
                }
                if (JSON.stringify($scope.currentSelectedBucket) == '{}' || $scope.currentSelectedBucket == null || angular.isUndefined($scope.currentSelectedBucket)) {
                    $scope.modifyCostSoourceeditMode = true;
                }
                if ($scope.currentSelectedBucket != null && angular.isDefined($scope.currentSelectedBucket) && JSON.stringify($scope.currentSelectedBucket) != '{}') {
                    if ($scope.currentSelectedBucket.SourceName == 'Oversold' || $scope.currentSelectedBucket.SourceName == 'Vendor Receiving' || $scope.currentSelectedBucket.SourceName == 'Vendor recieving') {
                        $scope.modifyCostSoourceeditMode = true;
                    } else {
                        $scope.modifyCostSoourceeditMode = false;
                    }
                    if (!$scope.modifyCostSoourceeditMode) {
                        loadState($state, 'ViewPart.ModifyCostSource', {
                            ModifyCostSourceParams: {
                                selectedbucketJson: $scope.currentSelectedBucket
                            }
                        });
                    }
                    if ($scope.currentSelectedBucket.SourceName == 'Vendor Receiving' || $scope.currentSelectedBucket.SourceName == 'Vendor recieving') {
                        Notification.error($translate.instant('Match_receivings_vendor_invoice_error'));
                    }

                }
                if (JSON.stringify($scope.currentSelectedBucket) == '{}') {
                    $scope.modifyCostSoourceeditMode = true;
                }
            }
            
            $scope.ViewPart.openModifyCostSummaryPopup = function (event, partId) {
                if (!$rootScope.GroupOnlyPermissions['Costs']['modify']) {
                    return;
                }
                var ModifyCostSummaryList = [];

                for (var i = 0; i < $scope.ViewPart.PartInfo.PartFIFOBucketList.length; i++) {
                    if ($scope.ViewPart.PartInfo.PartFIFOBucketList[i].RemainingQty > 0 && $scope.ViewPart.PartInfo.PartFIFOBucketList[i].SourceName != 'Vendor Receiving') {
                        ModifyCostSummaryList.push($scope.ViewPart.PartInfo.PartFIFOBucketList[i]);
                    }
                }
                if (ModifyCostSummaryList.length == 0) {
                    Notification.error($translate.instant('NewViewPart_Oversold_Item'));
                } else {
                    loadState($state, 'ViewPart.ModifyCostSummary', {
                        ModifyCostSummaryParams: {
                            ModifyCostSummaryList: ModifyCostSummaryList
                        }
                    });
                }
            }

            $scope.$on('modifyCostUpdate', function (event, args) {
                $scope.ViewPart.bindPartData(args);
                $scope.ViewPart.toggle = false;
            });

            $scope.$on('stockAdjustment', function (event, args) {
                $scope.ViewPart.bindPartData(args);
                $scope.ViewPart.toggle = false;
            });
            $scope.$on('modifyCostSourceAdjustment', function (event, args) {
                $scope.ViewPart.bindPartData(args);
                $scope.ViewPart.toggle = false;
            });

            /**
             * Method used when to add related records via page level search box
             */
            $scope.ViewPart.setFocusToSearchBox = function (typeToSearch) {
                $scope.typeToSearch = typeToSearch;
                $scope.PreferredObject = typeToSearch;
                angular.element('#SearchToaddCutomer').focus();
            }

            $scope.ViewPart.resetSearchBox = function () {
                $scope.typeToSearch = "";
                $scope.PreferredObject = "";
            }

            $scope.ViewPart.openpartpopupOnLoad = function (partId) {
                $scope.$broadcast('PartPopUpEventOnLoad', partId);
            }

            $scope.ViewPart.refreshViewPart = function () {
                $scope.ViewPart.isrefresh = true;
                $scope.ViewPart.loadPartInfo();
                $scope.ViewPart.toggle = false;
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
            $scope.ViewPart.openpartpopup = function (event, partId) {
                timer = $timeout(function () {
                    $scope.$broadcast('PartPopUpEvent', partId);
                    $scope.applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
                }, 1000);
            }

            $scope.ViewPart.hidePartPopUp = function () {
                $timeout.cancel(timer);
                angular.element('.Vendor-Order-Part-Popup').hide();
            }

            $scope.ViewPart.ShowMessage = function () {
                if ($rootScope.GroupOnlyPermissions['Costs']['modify']) {
                    Notification.error($translate.instant('NewViewPart_Resolve_Oversold'));
                }
            }

            $scope.ViewPart.MoveToPage = function (value) {
                window.open(newUrl + '/apex/BlackPurlHome?pageName=' + value, '_blank');
            }

            $scope.ViewPart.MoveToState = function (stateName, attr) {
                if (attr != undefined && attr != null && attr != '') {
                    loadState($state, stateName, attr);
                } else {
                    loadState($state, stateName);
                }
            }

            $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel = {
                activeOrdersChangesCount: 0,
                activeOrdersCurrentPage: 1,
                activeOrdersPageSize: 10,
                sorting: [{
                    fieldName: "Name",
                    sortDirection: ""
                }]
            };
            
            try {
                $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel.activeOrdersPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel = {
                activeSalesOrdersChangesCount: 0,
                activeSalesOrdersCurrentPage: 1,
                activeSalesOrdersPageSize: 10,
                sorting: [{
                    fieldName: "Name",
                    sortDirection: ""
                }]
            };
            try {
                $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel.activeSalesOrdersPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            $scope.ViewPartRelatedListModal.AlternateParts_sectionModel = {
                alternatePartsChangesCount: 0,
                alternatePartsCurrentPage: 1,
                alternatePartsPageSize: 10,
                sorting: [{
                    fieldName: "Item",
                    sortDirection: ""
                }]
            };
            try {
                $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            $scope.ViewPartRelatedListModal.TaxExemptions_sectionModel = {
                taxExemptionsChangesCount: 0,
                taxExemptionsCurrentPage: 1,
                taxExemptionsPageSize: 10,
                sorting: [{
                    fieldName: "SalesTax",
                    sortDirection: "ASC"
                }]
            };
            try {
                $scope.ViewPartRelatedListModal.TaxExemptions_sectionModel.taxExemptionsPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            var sortOrderMap = {
                "ASC": "DESC",
                "DESC": ""
            };

            $scope.ViewPartRelatedListModal.helpText = {
                Active_Orders_Help: $translate.instant('Tooltip_Active_Orders'),
                Active_Sales_Orders_Help: $translate.instant('Tooltip_Active_Sales_Orders'),
                Active_Orders_Settings_Help: $translate.instant('Tooltip_Active_Orders_Settings'),
                Active_Sales_Orders_Settings_Help: $translate.instant('Tooltip_Active_Sales_Orders_Settings'),
                Alternate_Parts_Help: $translate.instant('Tooltip_Alternate_Parts'),
                Alternate_Parts_Settings_Help: $translate.instant('Tooltip_Alternate_Parts_Settings'),
                Tax_Exemptions_Help: $translate.instant('Tooltip_Tax_Exemptions'),
                Tax_Exemptions_Settings_Help: $translate.instant('Tooltip_Tax_Exemptions_Settings')
            };

            $scope.ViewPartRelatedListModal.hidePanel = function (event, id) {
                var targetelement = angular.element(event.target).closest('h1').find('.fa:first');
                if (targetelement.hasClass('fa-chevron-right')) {
                    targetelement.removeClass('fa-chevron-right');
                    targetelement.addClass('fa-chevron-down');
                } else {
                    targetelement.removeClass('fa-chevron-down');
                    targetelement.addClass('fa-chevron-right');
                }
                $('#' + id).toggle();
            }

            $scope.ViewPartRelatedListModal.initModals = function () {
                $scope.ViewPartRelatedListModal.AlternateParts_initModals();
            }

            /**
             * Select callback when a record is selected in search to add autocomplete box
             */
            $scope.ViewPartRelatedListModal.searchToAddCallback = function (selectedRecord) {
                var selectedRecordId = selectedRecord.originalObject.Value;
                if (selectedRecordId.length == 18) {
                    selectedRecordId = selectedRecordId.substring(0, 15);
                }
                if (selectedRecord.originalObject.Info == 'Merchandise') {
                    $scope.ViewPartRelatedListModal.AlternateParts_addActionSearchRecSelectCallback(selectedRecordId);
                } else if (selectedRecord.originalObject.Info == 'Sales Tax Item') {
                    $scope.ViewPartRelatedListModal.TaxExemptions_addActionSearchRecSelectCallback(selectedRecordId);
                }

                $scope.ViewPart.resetSearchBox();
            }

            /**
             * Method to handle any updates in pagination controls
             */
            $scope.ViewPartRelatedListModal.Active_Orders_paginationControlsAction = function () {
                ActiveOrdersServices.getPaginatedActiveOrdersForPart($scope.ViewPartRelatedListModal.PartId,
                        $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel)
                    .then(function (activeOrdersInfo) {
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalActiveOrders = activeOrdersInfo.TotalActiveOrders;
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.ActiveOrders = activeOrdersInfo.activeOrders;

                        setTimeout(function () {
                            $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel.activeOrdersChangesCount++;
                        }, 10);
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Page_Server_Save_Error'));
                    });
            }

            /**
             * Method to handle sorting controls
             */
            $scope.ViewPartRelatedListModal.Active_Orders_sortControlsAction = function () {
                var newSortOrder = sortOrderMap[$scope.ViewPartRelatedListModal.ActiveOrders_sectionModel.sorting[0].sortDirection];
                if (newSortOrder == null || newSortOrder == undefined) {
                    newSortOrder = "ASC";
                }
                $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel.sorting[0].sortDirection = newSortOrder;
                $scope.ViewPartRelatedListModal.ActiveOrders_sectionModel.activeOrdersCurrentPage = 1;
                $scope.ViewPartRelatedListModal.Active_Orders_paginationControlsAction();
            }

            /**
             * Method to handle any updates in pagination controls
             */
            $scope.ViewPartRelatedListModal.Active_Sales_Orders_paginationControlsAction = function () {
                ActiveSalesOrdersServices.getPaginatedActiveSalesOrdersForPart($scope.ViewPartRelatedListModal.PartId,
                        $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel)
                    .then(function (activeSalesOrdersInfo) {
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalActiveSalesOrders = activeSalesOrdersInfo.TotalActiveSalesOrders;
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.ActiveSalesOrders = activeSalesOrdersInfo.activeSalesOrders;

                        setTimeout(function () {
                            $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel.activeSalesOrdersChangesCount++;
                        }, 10);
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Page_Server_Save_Error'));
                    });
            }

            /**
             * Method to handle sorting controls
             */
            $scope.ViewPartRelatedListModal.Active_Sales_Orders_sortControlsAction = function () {
                var newSortOrder = sortOrderMap[$scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel.sorting[0].sortDirection];
                if (newSortOrder == null || newSortOrder == undefined) {
                    newSortOrder = "ASC";
                }
                $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel.sorting[0].sortDirection = newSortOrder;
                $scope.ViewPartRelatedListModal.ActiveSalesOrders_sectionModel.activeOrdersCurrentPage = 1;
                $scope.ViewPartRelatedListModal.Active_Sales_Orders_paginationControlsAction();
            }

            $scope.ViewPartRelatedListModal.AlternateParts_initModals = function () {
                $scope.ViewPartRelatedListModal.AlternateParts_initEditRowsModal();
            }

            /**
             * Method to handle any updates in pagination controls
             */
            $scope.ViewPartRelatedListModal.AlternateParts_paginationControlsAction = function () {
                AlternatePartsServices.getPaginatedAlternatePartsForPart($scope.ViewPartRelatedListModal.PartId,
                        $scope.ViewPartRelatedListModal.AlternateParts_sectionModel)
                    .then(function (alternatePartsInfo) {
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts = alternatePartsInfo.TotalAlternateParts;
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts = alternatePartsInfo.alternateParts;

                        setTimeout(function () {
                            $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsChangesCount++;
                        }, 10);
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Page_Server_Save_Error'));
                    });
            }

            /**
             * Method to handle sorting controls
             */
            $scope.ViewPartRelatedListModal.AlternateParts_sortControlsAction = function () {
                var newSortOrder = sortOrderMap[$scope.ViewPartRelatedListModal.AlternateParts_sectionModel.sorting[0].sortDirection];
                if (newSortOrder == null || newSortOrder == undefined) {
                    newSortOrder = "ASC";
                }
                $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.sorting[0].sortDirection = newSortOrder;
                $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsCurrentPage = 1;
                $scope.ViewPartRelatedListModal.AlternateParts_paginationControlsAction();
            }

            $scope.ViewPartRelatedListModal.AlternateParts_initEditRowsModal = function () {
                $scope.ViewPartRelatedListModal.AlternateParts_editRow = [];
                for (i = 0; i < $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.length; i++) {
                    $scope.ViewPartRelatedListModal.AlternateParts_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }

            /**
             * Method for DOM action: Select record as preferred
             */	
            $scope.ViewPartRelatedListModal.AlternateParts_makeDefault = function (event, index) {
                event.stopPropagation();
                // Invoke add purchase order type UPDATE DEFAULT service
                AlternatePartsServices.updateDefaultAlternatePart($scope.ViewPartRelatedListModal.PartId,
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].Id.substring(0, 15), !$scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].IsPreferred
                    )
                    .then(function (resultInfo) {
                        if (resultInfo.indexOf(',') != -1) {
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts = parseInt(resultInfo.substring(0, resultInfo.indexOf(",")));
                        } else {
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts = parseInt(resultInfo);
                        }
                        // If new value to update is true, then update other default to false and then update new value
                        if (!$scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].IsPreferred == true) {
                            for (i = 0; i < $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.length; i++) {
                                if ($scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[i].IsPreferred) {
                                    $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[i].IsPreferred = false;
                                }
                            }
                        }
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].IsPreferred = !$scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].IsPreferred;
                        setTimeout(function () {
                            $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsChangesCount++;
                        }, 10);
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Page_Server_Save_Error'));
                    });
            }

            /**
             * Method for DOM action: Add
             */
            $scope.ViewPartRelatedListModal.AlternateParts_addAction = function (event) {
                $scope.ViewPart.setFocusToSearchBox('Merchandise');
            }

            /**
             * Method for DOM action: Add after selecting a record in search box
             */
            $scope.ViewPartRelatedListModal.AlternateParts_addActionSearchRecSelectCallback = function (selectedRecordId) {
                /* First check if the selected record is the original part itself or is already added in the list.
                   If so, then return and information message and do not process the request */
                if ((selectedRecordId.length == 15 && selectedRecordId == $scope.ViewPartRelatedListModal.PartId.substring(0, 15)) ||
                    (selectedRecordId.length == 18 && selectedRecordId == $scope.ViewPartRelatedListModal.PartId)
                ) {
                    Notification.info($translate.instant('Part_Not_Added_As_Alternate_Part'));
                    return;
                } else {
                    var doProcess = true;
                    angular.forEach($scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts, function (value, key) {
                        if ((selectedRecordId.length == 15 && selectedRecordId == value.AlternatePartId.substring(0, 15)) ||
                            (selectedRecordId.length == 18 && selectedRecordId == value.AlternatePartId)) {
                            doProcess = false;
                        }
                    });

                    if (!doProcess) {
                        Notification.info($translate.instant('Part_Is_Already_Alternate_Part'));
                        return;
                    }
                }

                var newAlternateParts = [{
                    AlternatePartId: selectedRecordId,
                    Relation: "Alternate",
                    PartId: $scope.ViewPartRelatedListModal.PartId
                }];

                AlternatePartsServices.addAlternatePartToPart(newAlternateParts).then(function (newAlternatePartDetails) {
                    var newRecords = [newAlternatePartDetails[0].AlternatePartRecord];
                    if (newAlternatePartDetails[0].isError == true) {
                        Notification.info(newAlternatePartDetails[0].ErrorMsg);
                    } else {
                        var initIndex = ($scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts == null || $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.length == 0) ? 0 : ($scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[0].IsPreferred) ? 1 : 0;
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.splice(initIndex, 0, newRecords[0]);
                        $scope.ViewPartRelatedListModal.AlternateParts_initEditRowsModal();

                        if ($scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.length > $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsPageSize) {
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts.length = $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsPageSize;
                        }
                        $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts = newAlternatePartDetails[0].TotalAlternateParts;
                        setTimeout(function () {
                            $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsChangesCount++;
                        }, 10);

                        Notification.success($translate.instant('Part_Saved_Successfully'));
                        angular.element("#Alternate_Parts_row" + initIndex).find("select").filter(':first').focus();
                    }
                }, function (errorSearchResult) {
                    Notification.error($translate.instant('Page_Server_Save_Error'));
                });
            }

            /**
             * Update relation field value action
             */
            $scope.ViewPartRelatedListModal.AlternateParts_updateRelation = function (alternatePartJunctionId, alternateOrderRelation, indexVal) {
                AlternatePartsServices.updateAlternatePartRelation($scope.ViewPartRelatedListModal.PartId, alternatePartJunctionId, alternateOrderRelation,
                    JSON.stringify($scope.ViewPartRelatedListModal.AlternateParts_sectionModel)).then(function (successResult) {
                    $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts = successResult.alternateParts;
                    Notification.success($translate.instant('Part_Saved_Successfully'));
                }, function (errorSearchResult) {
                    Notification.error($translate.instant('Page_Server_Save_Error'));
                });
            }

            /**
             * Method to open row in edit mode
             */
            $scope.ViewPartRelatedListModal.AlternateParts_openRowAsEdit = function (event, index) {
                event.stopPropagation();
                var editRowIndex = $scope.ViewPartRelatedListModal.AlternateParts_closeEditRows();
                if (editRowIndex != index) {
                    $scope.ViewPartRelatedListModal.AlternateParts_editRow[index].isEdit = true;
                    setTimeout(function () {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                }
            }

            /**
             * Method to close row from edit mode
             */
            $scope.ViewPartRelatedListModal.AlternateParts_closeEditRows = function (event) {
                var editRowIndex;
                for (i = 0; i < $scope.ViewPartRelatedListModal.AlternateParts_editRow.length; i++) {
                    if ($scope.ViewPartRelatedListModal.AlternateParts_editRow[i].isEdit == true) {
                        $scope.ViewPartRelatedListModal.AlternateParts_editRow[i].isEdit = false;
                        editRowIndex = i;
                        break;
                    }
                }
                return editRowIndex;
            }

            $scope.ViewPartRelatedListModal.AlternateParts_GoAction = function (index) {
                // selected radio value == 1 Means delete the record from the list
                if ($scope.ViewPartRelatedListModal.AlternateParts_editRow[index].radioValue == 1) {
                    // Invoke add alternate part REMOVE service
                    AlternatePartsServices.removeAlternatePartRelation($scope.ViewPartRelatedListModal.PartId,
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts[index].Id,
                            $scope.ViewPartRelatedListModal.AlternateParts_sectionModel
                        )
                        .then(function (newAlternatePartsDetails) {
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.AlternateParts = newAlternatePartsDetails.alternateParts;
                            $scope.ViewPartRelatedListModal.AlternateParts_initEditRowsModal();
                            $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts = newAlternatePartsDetails.TotalAlternateParts;

                            if ($scope.ViewPartRelatedListModal.PartRelatedInfo.TotalAlternateParts % $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsPageSize == 0) {
                                $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsCurrentPage--;
                                $scope.ViewPartRelatedListModal.AlternateParts_paginationControlsAction();
                            } else {
                                setTimeout(function () {
                                    $scope.ViewPartRelatedListModal.AlternateParts_sectionModel.alternatePartsChangesCount++;
                                }, 10);
                            }
                            Notification.success($translate.instant('Part_Updated_Successfully'));
                        }, function (errorSearchResult) {
                            Notification.error($translate.instant('Page_Server_Save_Error'));
                        });
                }
            }
            
            $scope.ViewPart.openPartLocatorWindow = function() {
            	var isNearDealerResultRecieved = false;
                var isAllDealerResultRecieved = false;
                var isSupplierResultRecieved = false;
                $scope.ViewPart.PartLocator = {};
                $scope.ViewPart.isLoading = true;
            	PartInfoService.getPartsLocator($scope.ViewPart.partId,1,"Dealer Radius").then(function(response) {
            		console.log("DealerRadius", response);
            		isNearDealerResultRecieved = true;
            		
                    $scope.ViewPart.PartLocator.headingText = 'BRP Availability';
                    if(response.DealerNearList && response.DealerNearList.length) {
                    	$scope.ViewPart.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                    }
                    $scope.ViewPart.PartLocator.availabiltyText = 'Available from Manufacturer';
                    $scope.ViewPart.PartLocator.modalCss = 'part-locator';
                    $scope.ViewPart.PartLocator.nearDealerList = response.DealerNearList;
                    
        			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
        				setCommonFieldForPartLocator(response);

        			}
        		}).catch(function(error) {
        			$scope.ViewPart.isLoading = false;
        	      });
            	PartInfoService.getPartsLocator($scope.ViewPart.partId,1,"Dealer").then(function(response) {
            		console.log("Dealer",response);
            		isAllDealerResultRecieved = true;
            		
            		if(response.AllDealerList && response.AllDealerList.length) {
                    	$scope.ViewPart.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                    }
                    $scope.ViewPart.PartLocator.allDealerList = response.AllDealerList;
                    
        			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
        				setCommonFieldForPartLocator(response);
        			}
        		}).catch(function(error) {
        			$scope.ViewPart.isLoading = false;
        	      });
            	PartInfoService.getPartsLocator($scope.ViewPart.partId,1,"Supplier").then(function(response) {
            		console.log("Supplier",response);
            		isSupplierResultRecieved = true;
            		
            		$scope.ViewPart.PartLocator.availabiltyNumber = response.ManufacturerAvailableQty;
                    $scope.ViewPart.PartLocator.phoneNumber = response.ManufacturerPhoneNumber;
                    
        			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
        				setCommonFieldForPartLocator(response);
        			}
        		}).catch(function(error) {
        			$scope.ViewPart.isLoading = false;
        	      });
        	}
            function setCommonFieldForPartLocator(response) {
            	$scope.ViewPart.PartLocator.showDialog=true;
                $scope.ViewPart.isLoading = false;
                if(!$scope.ViewPart.PartLocator.partDescription) {
                	$scope.ViewPart.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                }
            }

            /**
             * Method to handle any updates in pagination controls
             */
            $scope.ViewPartRelatedListModal.TaxExemptions_paginationControlsAction = function () {
                TaxExemptionsServices.getPaginatedTaxExemptionsForPart($scope.ViewPartRelatedListModal.PartId,
                    $scope.ViewPartRelatedListModal.TaxExemptions_sectionModel
                ).then(function (taxExemptionsInfo) {
                    $scope.ViewPartRelatedListModal.PartRelatedInfo.TotalTaxExemptions = taxExemptionsInfo.TotalTaxExemptions;
                }, function (errorSearchResult) {
                    Notification.error($translate.instant('Page_Server_Save_Error'));
                });
            }

            if ($scope.PartPopUpOnLoad == undefined) {
                $scope.PartPopUpOnLoad = {};
                $scope.PartPopUpOnLoad.partModel = {};
            }
            $scope.$on('PartPopUpEventOnLoad', function (event, partId) {
                $scope.PartPopUpOnLoad.partModel = {};
                jsonRectangles = {};
                jsonRectangles2 = {};
                $scope.PartPopUpOnLoad.loadData(partId);
                angular.element('.partPopUp-flyout').scrollTop = 0;
            });

            $scope.$on('activeButtonChanged', function (event, args) {
                $scope.PartPopUpOnLoad.item = args.item;
            });

            $scope.PartPopUpOnLoad.loadData = function (partId) {
                partOrderReceivingService.getPartRecord(partId).then(function (partRecord) {
                    if (partRecord.PartDetailRec != undefined) {
                        $scope.PartPopUpOnLoad.partModel = partRecord.PartDetailRec;
                        $scope.PartPopUpOnLoad.loadChart();
                    }
                }, function (errorSearchResult) {
                    $scope.VORModel.OverlayInfo = errorSearchResult;
                });
            }
            $scope.PartPopUpOnLoad.loadChart = function () {
                $scope.PartPopUpOnLoad.isZeroTotalValue = false
                $scope.PartPopUpOnLoad.isZeroTotalValue1 = false;

                d3.selectAll(".PartPopupOnVenderOrdernew svg").remove();
                var commited = $scope.PartPopUpOnLoad.partModel.QtyCommited;
                var available = $scope.PartPopUpOnLoad.partModel.QtyAvailable;
                var onorder = $scope.PartPopUpOnLoad.partModel.QtyOnOrder;

                var instocktotal = $scope.PartPopUpOnLoad.partModel.QtyCommited + $scope.PartPopUpOnLoad.partModel.QtyAvailable;
                var total_instock = commited + available;
                var max = 0;
                if (commited < 0) {
                    if (Math.abs(commited) > max)
                        max = Math.abs(commited);
                }
                if (available < 0) {
                    if (Math.abs(available) > max)
                        max = Math.abs(available);
                }
                if (onorder < 0) {
                    if (Math.abs(onorder) > max)
                        max = Math.abs(onorder);
                }
                if (total_instock < 0) {
                    if (Math.abs(total_instock) > max)
                        max = Math.abs(total_instock);
                }
                available = available + max;
                commited = commited + max;
                onorder = onorder + max;
                total_instock = total_instock + max;

                var jsonRectangles = [{
                        "color": "#414449",
                        "commited": commited
                    },
                    {
                        "color": "#727983",
                        "available": available
                    },
                    {
                        "color": "#939CA9",
                        "onorder": onorder
                    }
                ];

                var total_value = jsonRectangles[0].commited + jsonRectangles[1].available + jsonRectangles[2].onorder;
                if (total_value != 0) {
                    jsonRectangles[0].commited = ((jsonRectangles[0].commited) / total_value) * 100
                    jsonRectangles[1].available = ((jsonRectangles[1].available) / total_value) * 100
                    jsonRectangles[2].onorder = ((jsonRectangles[2].onorder) / total_value) * 100
                    var ft1 = (580 * jsonRectangles[0].commited) / 100;
                    var ft2 = (580 * jsonRectangles[1].available) / 100;
                    var ft3 = (580 * jsonRectangles[2].onorder) / 100;
                    var commitedName = "COMMITED:";
                    var availablename = "AVAILABLE:";
                    var onordername = "ON ORDER:";
                    var inStock = "INSTOCK:";
                    var instock_tringle = ft1 + ft2;
                    var jsonRectangles1 = [{
                        "color": "#71BF3E",
                        "commited": instock_tringle
                    }];

                    var textsvg = d3.select('#loadPartWrapper')
                        .append('svg')
                        .data(jsonRectangles)
                        .attr({
                            'width': 580 + "px",
                            'height': 45 + "px"
                        });

                    if (jsonRectangles[0].commited >= 0) {
                        textsvg.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft1 < 100) {
                                    p = 0;
                                } else if ((580 - ft1) > 500) {
                                    p = 450;
                                } else {
                                    p = (ft1 / 2) - 50;
                                }
                                return p;
                            })
                            .attr("dy", 25)
                            .style('fill', "#414449")
                            .text(function (d) {
                                return commitedName
                            });

                        textsvg.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft1 < 100) {
                                    p = 0;
                                } else if ((580 - ft1) > 500) {
                                    p = 450;
                                } else {
                                    p = (ft1 / 2) - 50;
                                }
                                return (p + 85);
                            })
                            .attr("dy", 25)
                            .attr("font-weight", "bold")
                            .style('fill', "#414449")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.QtyCommited
                            });
                    }

                    if (jsonRectangles[1].available >= 0) {
                        textsvg.append("text")
                            .attr("dx", function (d, i) {
                                if ((ft2 <= 50) && (ft1 > 530)) {
                                    p = 450;
                                } else if ((ft1 <= 530) && (ft1 > 50)) {
                                    p = ft1 + (ft2 / 2) - 50;
                                } else if ((ft2 <= 100) && (ft1 < 50)) {
                                    p = 0;
                                } else {
                                    p = ft1 + (ft2 / 2) - 50;
                                }
                                return p;
                            })
                            .attr("dy", 45)
                            .style('fill', "#727983")
                            .text(function (d) {
                                return availablename
                            });

                        textsvg.append("text").attr("dx", function (d, i) {
                                var p;
                                if ((ft2 <= 50) && (ft1 > 530)) {
                                    p = 450;
                                } else if ((ft1 <= 530) && (ft1 > 50)) {
                                    p = ft1 + (ft2 / 2) - 50;
                                } else if ((ft2 <= 100) && (ft1 < 50)) {
                                    p = 0;
                                } else {
                                    p = ft1 + (ft2 / 2) - 50;
                                }
                                return (p + 80);
                            })
                            .attr("dy", 45)
                            .attr("font-weight", "bold")
                            .style('fill', "#727983")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.QtyAvailable
                            });
                    }

                    if (jsonRectangles[2].onorder >= 0) {
                        textsvg.append("text")
                            .attr("dx", function (d, i) {
                                if ((ft1 + ft2) >= 480) {
                                    p = 450;
                                } else if (((ft1 + ft2) < 480) && ((ft1 + ft2) > 50)) {
                                    p = ft1 + ft2 + (ft3 / 2) - 50;
                                } else if ((ft1 + ft2) <= 50) {
                                    p = ft1 + ft2 + (ft3 / 2) - 50;
                                }
                                return p;
                            })
                            .attr("dy", 30)
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return onordername
                            });

                        textsvg.append("text").attr("dx", function (d, i) {
                                var p;
                                if ((ft1 + ft2) >= 480) {
                                    p = 450;
                                } else if (((ft1 + ft2) < 480) && ((ft1 + ft2) > 50)) {
                                    p = ft1 + ft2 + (ft3 / 2) - 50;
                                } else if ((ft1 + ft2) <= 50) {
                                    p = ft1 + ft2 + (ft3 / 2) - 50;
                                }
                                return (p + 85);
                            })
                            .attr("dy", 30)
                            .attr("font-weight", "bold")
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.QtyOnOrder
                            });
                    }

                    /* Tringle  node */
                    var svg = d3.select('#loadPartWrapper')
                        .append('svg')
                        .attr({
                            'width': 580 + "px",
                            'height': 25 + "px"
                        });

                    if (jsonRectangles[0].commited >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svg.append('g');

                        if (ft1 != 0) {
                            group.attr('transform', 'translate(' + ft1 / 2 + ',' + 15 + ')');
                        } else {
                            group.attr('transform', 'translate(' + (ft1 / 2 + 5) + ',' + 15 + ')');
                        }

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', '#FFF')
                            .style("fill", "#414449")
                            .attr('stroke-width', 1)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            });
                    }

                    if (jsonRectangles[1].available >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svg.append('g').attr('transform', 'translate(' + (ft1 + (ft2 / 2)) + ',' + 15 + ')');

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', '#FFF')
                            .style("fill", "#727983")
                            .attr('stroke-width', 1)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            });
                    }

                    if (jsonRectangles[2].onorder >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svg.append('g');

                        if (ft3 != 0) {
                            group.attr('transform', 'translate(' + (ft1 + ft2 + (ft3 / 2)) + ',' + 15 + ')');
                        } else {
                            group.attr('transform', 'translate(' + (ft1 + ft2 + (ft3 / 2) - 5) + ',' + 15 + ')');
                        }

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', '#FFF')
                            .style("fill", "#939CA9")
                            .attr('stroke-width', 1)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            });
                    }

                    /* rectangle  node */
                    var svgContainer = d3.select("#loadPartWrapper").append("svg")
                        .attr("width", 580 + "px")
                        .attr("height", 36 + "px")
                        .attr("class", "rectanglecont")

                    var rectangles = svgContainer.selectAll("rect")
                        .data(jsonRectangles)
                        .enter()
                        .append("rect");
                    rectangles.append("text")
                        .attr("x", function (d) {
                            return 100
                        })
                        .attr("y", 200)
                        .attr("dy", ".35em")
                        .attr('fill', 'red')

                    var rectangleAttributes = rectangles
                        .attr("x", function (d, i) {
                            if (i == 0) {
                                d.x = 0;
                            }
                            if (i == 1) {
                                d.x = (((jsonRectangles[i - 1].commited) * 580) / 100);
                            }
                            if (i == 2) {
                                d.x = (((jsonRectangles[i - 2].commited) * 580) / 100) + (((jsonRectangles

                                    [i - 1].available) * 580) / 100);
                            }

                            if (i == 3) {
                                d.x = (((jsonRectangles[i - 3].commited) * 580) / 100) + (((jsonRectangles

                                    [i - 2].available) * 580) / 100) + (((jsonRectangles[i - 1].onorder) * 580) / 100);
                            }
                            return d.x;
                        })
                        .attr("y", function (d) {
                            return 10;
                        })
                        .attr("height", function (d) {
                            return 50;
                        })
                        .attr("width", function (d, i) {
                            if (i == 0) {
                                d.width = d.commited + "%";
                            }
                            if (i == 1) {
                                d.width = d.available + "%";
                            }
                            if (i == 2) {
                                d.width = d.onorder + "%";
                            }
                            return d.width;
                        })
                        .style("fill", function (d) {
                            return d.color;
                        });

                    var svgContainer1 = d3.select("#loadPartWrapper1").append("svg")
                        .attr("width", 580 + "px")
                        .attr("height", 36 + "px")
                        .attr("class", "rectanglecont1")

                    var rectangles = svgContainer1.selectAll("rect")
                        .data(jsonRectangles1)
                        .enter()
                        .append("rect");

                    var rectangleAttributes = rectangles
                        .attr("x", function (d) {
                            d.x = 0;
                            return d.x;
                        })
                        .attr("y", function (d) {
                            return 10;
                        })
                        .attr("height", function (d) {
                            return 50;
                        })
                        .attr("width", function (d) {
                            d.width = d.commited + "%";
                            return d.width;
                        })
                        .style("fill", function (d) {
                            return d.color;
                        });

                    var svg = d3.select('#loadPartWrapper1')
                        .append('svg')
                        .attr({
                            'width': 580 + "px",
                            'height': 30 + "px"
                        })
                        .attr("class", "inorder_tringle");

                    var arc = d3.svg.symbol().type('triangle-down')
                        .size(function (d) {
                            return scale(d);
                        });
                    var data = [.5];
                    var scale = d3.scale.linear()
                        .domain([1, 8])
                        .range([100, 580]);
                    var group = svg.append('g');

                    if (instock_tringle != 0) {
                        group.attr('transform', 'translate(' + ((instock_tringle) / 2) + ',' + 5 + ')');
                    } else {
                        group.attr('transform', 'translate(' + ((instock_tringle) / 2 + 5) + ',' + 5 + ')');
                    }
                    var line = group.selectAll('path')
                        .data(data)
                        .enter()
                        .append('path')
                        .attr('d', arc)
                        .attr('stroke', "#71BF3E")
                        .style("fill", "#71BF3E")
                        .attr('stroke-width', 1)
                        .attr('transform', function (d, i) {
                            return "translate(" + (i * 38) + "," + (10) + ")";
                        });
                    var textsvg = d3.select('#loadPartWrapper1')
                        .append('svg')
                        .data(jsonRectangles)
                        .attr("class", "instocktext")
                        .attr({
                            'width': 580 + "px",
                            'height': 30 + "px"
                        });

                    if (instock_tringle >= 0) {
                        textsvg.append("text")
                            .attr("dx", function (d, i) {
                                var p;
                                if (instock_tringle < 60) {
                                    p = 0;
                                } else {
                                    p = ((instock_tringle) / 2) - 40;
                                }
                                return p;
                            })
                            .attr("dy", 30)
                            .style('fill', "#71BF3E")
                            .text(function (d) {
                                return inStock
                            });

                        /* displaying quantity */
                        textsvg.append("text").attr("dx", function (d, i) {
                                var p;
                                if (instock_tringle < 60) {
                                    p = 0;
                                } else {
                                    p = ((instock_tringle) / 2) - 40;
                                }
                                return (p + 70);
                            })
                            .attr("dy", 30)
                            .attr("font-weight", "bold")
                            .style('fill', "#71BF3E")
                            .text(function (d) {
                                return instocktotal
                            });
                    }
                } else {
                    $scope.PartPopUpOnLoad.isZeroTotalValue = true;
                }
                var reOrder = 0;
                var isSmaller = false;;
                var available = $scope.PartPopUpOnLoad.partModel.QtyAvailable;
                var onorder = $scope.PartPopUpOnLoad.partModel.QtyOnOrder;
                var max1 = 0;
                if (available < 0) {
                    if (Math.abs(available) > max1)
                        max1 = Math.abs(available);
                }
                if (onorder < 0) {
                    if (Math.abs(onorder) > max1)
                        max1 = Math.abs(onorder);
                }
                available = available + max1;
                onorder = onorder + max1;

                var reorderAt = $scope.PartPopUpOnLoad.partModel.AutoReorderAt;
                var reorderTo = $scope.PartPopUpOnLoad.partModel.AutoReorderTo;
                var total_value1 = 0;
                var jsonRectangles2 = [{
                        "color": "#727983",
                        "available": available
                    },
                    {
                        "color": "#939CA9",
                        "onorder": onorder
                    },
                    {
                        "color": "white",
                        "reOrder": reOrder
                    }
                ];
                if ((onorder + available) > reorderTo) {
                    total_value1 = onorder + available;
                } else {
                    total_value1 = 1.5 * reorderTo;
                    isSmaller = true;
                }
                if (total_value1 != 0) {
                    jsonRectangles2[0].available = ((jsonRectangles2[0].available) / total_value1) * 100;
                    jsonRectangles2[1].onorder = ((jsonRectangles2[1].onorder) / total_value1) * 100;
                    jsonRectangles2[2].reOrder = 0;
                    if (isSmaller) {
                        jsonRectangles2[2].reOrder = 100 - (jsonRectangles2[0].available + jsonRectangles2[1].onorder);
                    }

                    var ft4 = (580 * jsonRectangles2[0].available) / 100;
                    var ft5 = (580 * jsonRectangles2[1].onorder) / 100;
                    var ft6 = 0;
                    if (isSmaller) {
                        ft6 = 580 - (ft4 + ft5);
                    }

                    var reorderAtName = "REORDER MIN:";
                    var reorderToName = "REORDER TO:";

                    var ft7 = (reorderAt * 580) / total_value1;
                    var ft8 = (reorderTo * 580) / total_value1;
                    var availablename = "AVAILABLE:";
                    var onordername = "ON ORDER:";

                    /* text node */
                    var textsvg1 = d3.select('#loadPartWrapper2')
                        .append('svg')
                        .data(jsonRectangles2)
                        .attr({
                            'width': 580 + "px",
                            'height': 45 + "px"
                        });

                    if (jsonRectangles2[0].available >= 0) {
                        /* displaying name */
                        textsvg1.append("text")
                            .attr("dx", function (d, i) {
                                var p;
                                if (ft4 < 100) {
                                    p = 0;
                                } else if ((580 - ft4) > 500) {
                                    p = 450;
                                } else {
                                    p = (ft4 / 2) - 50;
                                }
                                return p;
                            })
                            .attr("dy", 25)
                            .style('fill', "#414449")
                            .text(function (d) {
                                return availablename
                            });

                        /* displaying quantity */
                        textsvg1.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft4 < 100) {
                                    p = 0;
                                } else if ((580 - ft4) > 500) {
                                    p = 450;
                                } else {
                                    p = (ft4 / 2) - 50;
                                }
                                return (p + 80);
                            })
                            .attr("dy", 25)
                            .attr("font-weight", "bold")
                            .style('fill', "#414449")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.QtyAvailable
                            });
                    }

                    if (jsonRectangles2[1].onorder >= 0) {
                        /* displaying quantity */
                        textsvg1.append("text")
                            .attr("dx", function (d, i) {
                                var p;
                                if (ft5 >= 480) {
                                    p = 450;
                                } else if ((ft5 < 480) && (ft5 > 100)) {
                                    p = ft4 + (ft5 / 2) - 50;
                                } else if ((ft5 <= 100) && (ft4 != 0)) {
                                    p = ft4 + (ft5 / 2) - 110;
                                } else if ((ft5 <= 100) && (ft4 == 0))
                                    p = 0;
                                return p;
                            })
                            .attr("dy", 45)
                            .style('fill', "#727983")
                            .text(function (d) {
                                return onordername
                            });

                        /* displaying quantity */
                        textsvg1.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft5 >= 480) {
                                    p = 450;
                                } else if ((ft5 < 480) && (ft5 > 100)) {
                                    p = ft4 + (ft5 / 2) - 50;
                                } else if ((ft5 <= 100) && (ft4 != 0)) {
                                    p = ft4 + (ft5 / 2) - 110;
                                } else if ((ft5 <= 100) && (ft4 == 0))
                                    p = 0;
                                return (p + 85);
                            })
                            .attr("dy", 45)
                            .attr("font-weight", "bold")
                            .style('fill', "#727983")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.QtyOnOrder
                            });
                    }

                    /* Tringle  node */
                    var svg = d3.select('#loadPartWrapper2')
                        .append('svg')
                        .attr({
                            'width': 580 + "px",
                            'height': 25 + "px"
                        });

                    if (jsonRectangles2[0].available >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svg.append('g');
                        if (ft4 != 0) {
                            group.attr('transform', 'translate(' + ft4 / 2 + ',' + 15 + ')');
                        } else {
                            group.attr('transform', 'translate(' + (ft4 / 2 + 5) + ',' + 15 + ')');
                        }

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', '#FFF')
                            .style("fill", "#414449")
                            .attr('stroke-width', 1)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            });
                    }

                    if (jsonRectangles2[1].onorder >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svg.append('g');

                        if (ft5 != 0) {
                            group.attr('transform', 'translate(' + (ft4 + (ft5 / 2)) + ',' + 15 + ')');
                        } else {
                            group.attr('transform', 'translate(' + (ft4 + (ft5 / 2) - 5) + ',' + 15 + ')');
                        }

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', '#FFF')
                            .style("fill", "#727983")
                            .attr('stroke-width', 1)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            });
                    }

                    /* rectangle  node */
                    var svgContainer2 = d3.select("#loadPartWrapper2").append("svg")
                        .attr("width", 580 + "px")
                        .attr("height", 36 + "px")
                        .attr("class", "rectanglecont")

                    var rectangles = svgContainer2.selectAll("rect")
                        .data(jsonRectangles2)
                        .enter()
                        .append("rect");
                    rectangles.append("text")
                        .attr("x", function (d) {
                            return 100
                        })
                        .attr("y", 200)
                        .attr("dy", ".35em")
                        .attr('fill', 'red')

                    var rectangleAttributes = rectangles
                        .attr("x", function (d, i) {
                            if (i == 0) {
                                d.x = 0;
                            }
                            if (i == 1) {
                                d.x = (((jsonRectangles2[i - 1].available) * 580) / 100);
                            }
                            if (i == 2) {
                                d.x = (((jsonRectangles2[i - 2].available) * 580) / 100) + (((jsonRectangles2[i - 1].onorder) * 580) / 100);
                            }
                            if (i == 3) {
                                d.x = (((jsonRectangles2[i - 2].available) * 580) / 100) + (((jsonRectangles2[i - 1].onorder) * 580) / 100) + (((jsonRectangles2[i - 3].reOrder) * 580) / 100);
                            }
                            return d.x;
                        })
                        .attr("y", function (d) {
                            return 10;
                        })
                        .attr("height", function (d) {
                            return 25;
                        })
                        .attr("width", function (d, i) {
                            if (i == 0) {
                                d.width = d.available + "%";
                            }
                            if (i == 1) {
                                d.width = d.onorder + "%";
                            }
                            if (i == 2) {
                                d.width = d.reOrder + "%";
                            }
                            return d.width;
                        })
                        .attr("stroke-width", 1)
                        .attr("stroke", "rgb(114, 121, 131)")
                        .style("fill", function (d) {
                            return d.color;
                        });

                    var x1, x2;
                    x1 = ft7;
                    x2 = ft8;

                    if (x1 == 0)
                        x1 = x1 + 5;
                    if (x2 == 0)
                        x2 = x2 + 5;
                    var lineMin = svgContainer2.append("line")
                        .attr("x1", x1)
                        .attr("y1", 10)
                        .attr("x2", x1)
                        .attr("y2", 27)
                        .attr("stroke-width", 2)
                    if ((onorder + available) < reorderAt) {
                        lineMin.attr("stroke", "rgb(114, 121, 131)"); /*black*/
                    } else {
                        lineMin.attr("stroke", "rgb(227, 227, 228)"); /*white*/
                    }


                    /*triangle bottom at min*/
                    if (reorderAt >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svgContainer2.append('g').attr('transform', 'translate(' + (x1) + ',' + 27 + ')');
                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', "rgb(179, 180, 181)")
                            .style("fill", "white")
                            .attr('stroke-width', 2)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            })
                            .attr("id", "minTriangle");
                    }

                    var lineMax = svgContainer2.append("line")
                        .attr("x1", x2)
                        .attr("y1", 10)
                        .attr("x2", x2)
                        .attr("y2", 27)
                        .attr("stroke-width", 2);


                    if (isSmaller) {
                        lineMax.attr("stroke", "rgb(114, 121, 131)"); /*black*/
                    } else {
                        lineMax.attr("stroke", "rgb(227, 227, 228)"); /*white*/
                    }

                    /*triangle bottom at max*/
                    if (reorderTo >= 0) {
                        var arc = d3.svg.symbol().type('triangle-up')
                            .size(function (d) {
                                return scale(d);
                            });
                        var data = [.5];
                        var scale = d3.scale.linear()
                            .domain([1, 8])
                            .range([100, 580]);
                        var group = svgContainer2.append('g').attr('transform', 'translate(' + x2 + ',' + 27 + ')');

                        var line = group.selectAll('path')
                            .data(data)
                            .enter()
                            .append('path')
                            .attr('d', arc)
                            .attr('stroke', "rgb(179, 180, 181)")
                            .style("fill", "white")
                            .attr('stroke-width', 2)
                            .attr('transform', function (d, i) {
                                return "translate(" + (i * 38) + "," + (5) + ")";
                            })
                            .attr("id", "maxTriangle");
                    }

                    var textsvg2 = d3.select('#loadPartWrapper2')
                        .append('svg')
                        .data(jsonRectangles2)
                        .attr({
                            'width': 580 + "px",
                            'height': 45 + "px"
                        });

                    if (reorderAt >= 0) {
                        /* displaying name */
                        textsvg2.append("text")
                            .attr("dx", function (d, i) {
                                var p;
                                if (ft7 < 60) {
                                    p = 0;
                                } else {
                                    p = ft7 - 60;
                                }
                                return p;
                            })
                            .attr("dy", 45)
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return reorderAtName
                            });

                        /* displaying quantity */
                        textsvg2.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft7 < 60) {
                                    p = 0;
                                } else {
                                    p = ft7 - 60;
                                }
                                return (p + 105);
                            })
                            .attr("dy", 45)
                            .attr("font-weight", "bold")
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.AutoReorderAt
                            });
                    }

                    if (reorderTo >= 0) {
                        /* displaying name */
                        textsvg2.append("text")
                            .attr("dx", function (d, i) {
                                var p;
                                if (ft8 < 60) {
                                    p = ft7 + (ft8 / 2);
                                } else {
                                    p = ft8 - 90;
                                }
                                return p;
                            })
                            .attr("dy", 25)
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return reorderToName
                            });

                        /* displaying quantity */
                        textsvg2.append("text").attr("dx", function (d, i) {
                                var p;
                                if (ft8 < 60) {
                                    p = ft7 + (ft8 / 2);
                                } else {
                                    p = ft8 - 90;
                                }
                                return (p + 100);
                            })
                            .attr("dy", 25)
                            .attr("font-weight", "bold")
                            .style('fill', "#939CA9")
                            .text(function (d) {
                                return $scope.PartPopUpOnLoad.partModel.AutoReorderTo
                            });
                    }
                } else {
                    $scope.PartPopUpOnLoad.isZeroTotalValue1 = true;
                }
            }
            $scope.ViewPart.loadPartInfo();
        }])
    });