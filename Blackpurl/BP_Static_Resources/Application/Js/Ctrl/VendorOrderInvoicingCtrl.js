define(['Routing_AppJs_PK', 'VendorOrderInvoicingServices', 'JqueryUI', 'dirNumberInput', 'DirPagination', 'tel', 'PartPopUpOnVendorOrderCtrl', 'VendorInfoCtrl'], function(Routing_AppJs_PK, VendorOrderInvoicingServices, JqueryUI, dirNumberInput, DirPagination, tel, PartPopUpOnVendorOrderCtrl, VendorInfoCtrl) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('VendorOrderInvoicingCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$filter', '$stateParams', '$state', 'vendorOrderInvoicingService','$translate', function($scope, $timeout, $q, $rootScope, $sce, $filter, $stateParams, $state, vendorOrderInvoicingService,$translate) {
        var Notification = injector1.get("Notification");
        var origin = window.location.origin;
        var url = origin + '/apex/';
        $scope.VORModel = {};
        $scope.InvoiceHistoryMiniPageLayout = {};
        if (!$rootScope.GroupOnlyPermissions['Vendor invoicing']['view']) {
            $scope.VORModel.displaySections = {
                'Info': false,
                'Invoicing': false,
                'FinalizeOrder': false
            };
        } else {
            $scope.VORModel.displaySections = {
                'Info': true,
                'Invoicing': true,
                'FinalizeOrder': true
            };
        }
        $scope.parseInt = parseInt;
        $scope.VORModel.VIHeader = {};
        $scope.VendorOrderModel = {};
        $scope.VORModel.VIGroupListCopy = [];
        $scope.SearchToadd = {};
        $scope.typeToSearch = "";
        $scope.VendorInvoiceNumber = "";
        $scope.PreferredObject = "Vendor";
        $scope.SearchableObjects = 'Vendor';
        $scope.VORModel.disableSelectCheckbox = false;
        $scope.VORModel.activeSidepanelink = '#VOI_Info_Block';
        $scope.VORModel.selectedItem = 'Info';
        $scope.VORModel.IsQBEnabled = $Global.IsQBEnabled;
        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function() {
            $scope.VORModel.onScroll();
        });
        $scope.VORModel.scrollToPanel = function(event, sectionToscroll) {
            if (event != null) {
                event.preventDefault();
            }
            angular.element(document).off("scroll");
            var target = angular.element("#" + sectionToscroll);
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 10;
            }
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 110 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VORModel.onScroll();
                });
                $scope.VORModel.onScroll();
            });
        }
        $scope.VORModel.dropDownItem = function(event, selectedSection) {
            var activeSection = $scope.VORModel.activeSidepanelink.replace('#', '');
            $scope.VORModel.selectedItem = selectedSection;
            if (activeSection != selectedSection) {
                $scope.VORModel.sidepanelLink(event, selectedSection);
            }
        }
        $scope.VORModel.sidepanelLink = function(event, relatedContent) {
            event.preventDefault();
            if (!$rootScope.GroupOnlyPermissions['Vendor invoicing']['view']) {
                return;
            }
            $scope.VORModel.displaySections[relatedContent] = true;
            angular.element(document).off("scroll");
            var target = angular.element(event.target.closest('a')).attr("href");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 10;
            }
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 110 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VORModel.onScroll();
                });
                $scope.VORModel.onScroll();
            });
        }
        $scope.InvoiceHistoryMiniPageLayout.closePopup = function() {
            $timeout.cancel(timer);
            angular.element('.Invoice-info-overlay').hide();
        }
        $scope.VORModel.onScroll = function() {
            if ($state.current.name === 'VendorOrderInvoicing') {
                var activeSidepanelink;
                var heading = '';
                var scrollPos = angular.element(document).scrollTop();
                var fixedHeight = 50;
                var selectedItem;
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 0;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                if ((isElementDefined('#VOI_Info_Block') && (scrollPos < angular.element('#VOI_Info_Block').position().top + angular.element('#VOI_Info_Block').height() + fixedHeight - navBarHeightDiffrenceFixedHeaderOpen)) || $scope.VORModel.VIHeader.VendorId == null) {
                    activeSidepanelink = '#VOI_Info_Block';
                    selectedItem = 'Info';
                } else if (isElementDefined('#VOI_invoicing_Block') && (scrollPos < angular.element('#VOI_invoicing_Block').position().top + angular.element('#VOI_invoicing_Block').height() + fixedHeight - navBarHeightDiffrenceFixedHeaderOpen)) {
                    if ($scope.VORModel.VIGroupList.length != 0) {
                        activeSidepanelink = '#VOI_invoicing_Block';
                        selectedItem = 'Invoicing';
                    } else {
                        if ($scope.VORModel.VIHeader.Status != 'Invoiced' && $scope.VORModel.VIGroupList.length != 0) {
                            activeSidepanelink = '#VOI_Finalize_Block';
                            selectedItem = 'Finalize Order';
                        } else {
                            activeSidepanelink = '#VOI_Info_Block';
                            selectedItem = 'Info';
                        }
                    }
                } else if (isElementDefined('#VOI_Finalize_Block') && (scrollPos < angular.element('#VOI_Finalize_Block').position().top + angular.element('#VOI_Finalize_Block').height() + fixedHeight - navBarHeightDiffrenceFixedHeaderOpen)) {
                    if ($scope.VORModel.VIHeader.Status != 'Invoiced' && $scope.VORModel.VIGroupList.length != 0) {
                        activeSidepanelink = '#VOI_Finalize_Block';
                        selectedItem = 'Finalize Order';
                    } else {
                        activeSidepanelink = '#VOI_Info_Block';
                        selectedItem = 'Info';
                    }
                } else {
                    activeSidepanelink = '#VOI_Finalize_Block';
                    selectedItem = 'Finalize Order';
                }
                $scope.VORModel.activeSidepanelink = activeSidepanelink;
                $scope.VORModel.selectedItem = selectedItem;
                if (!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }
        $scope.VORModel.invoicePrintPriview = function(customerInvoiceId) {
            var myWindow = window.open(url + "PrintCustomerOrderInvoice?id=" + customerInvoiceId, "", "width=1200, height=600");
        }
        $scope.VORModel.refreshVendorOrder = function() {
            $scope.VORModel.isrefresh = true;
            setTimeout(function() {
                $scope.VORModel.initFunction();
            }, 10);
        }
        var sortOrderMap = {
            "ASC": "DESC",
            "DESC": ""
        };
        $scope.VORModel.setDefaultPageSortAttrs = {};
        $scope.VORModel.setDefaultPageSortAttrs = function() {
            $scope.VORModel.receivingPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Order",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VORModel.receivingPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {
                console.log("Error " + ex);
            }
            $scope.VORModel.groupItemsPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Order",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VORModel.groupItemsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {
                console.log("Error " + ex);
            }
        }
        $scope.VORModel.calculateSidebarHeight = function() {
            var leftPanelLinks = angular.element(window).height() - (angular.element(".headerNav").height() + angular.element(".orderNumber").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + angular.element(".ownerInfo").height() + angular.element(".sideBarTotals").height() + 85);
            angular.element(".leftPanelLinks").css("height", leftPanelLinks);
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 1500);
        }
        $scope.VORModel.initFunction = function() {
            $scope.VORModel.disableFinalizeInvoiceBtn = false;
            $scope.VORModel.setDefaultPageSortAttrs();
            $scope.VORModel.VIHeader.VIHeaderId = $stateParams.Id ? $stateParams.Id : null;
            $scope.VORModel.setDefaultPageSortAttrs();
            var vendorId = null;
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            var vrHeaderId = null;
            $scope.VORModel.isrefresh = false;
            $scope.SearchToAddCallback = $scope.VORModel.searchToAddCallback;
            vendorOrderInvoicingService.getVendorInvoicing(viHeaderId, vrHeaderId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.PopulatePageModel(successfulResult);
                setTimeout(function() {
                    $scope.VORModel.calculateSidebarHeight();
                }, 10);
            });
        }
        $scope.VORModel.populateLeftSideHeadingLables = function() {
            $scope.VORModel.LeftSideHeadingLables = {};
            var currentHeadingSequenceIndex = 65;
            $scope.VORModel.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
            $scope.VORModel.LeftSideHeadingLables['Invoice'] = String.fromCharCode(currentHeadingSequenceIndex++);
            if ($scope.VORModel.VIHeader.Status != 'Invoiced' && $scope.VORModel.VIGroupList.length != 0) {
                $scope.VORModel.LeftSideHeadingLables['Finalize'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
        }
        $scope.VORModel.searchToAddCallback = function(selectedRecord) {
            if (selectedRecord.originalObject.Info == 'Vendor') {
                if ($scope.VORModel.VIGroupList.length == 0 || $scope.VORModel.VIGroupList == 'undefined') {
                    var selectedRecordId = selectedRecord.originalObject.Value;
                    if ($scope.VORModel.VIHeader == undefined) {
                        viHeaderId = null
                    } else {
                        viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
                    }
                    if (selectedRecordId.length == 18) {
                        selectedRecordId = selectedRecordId.substring(0, 15);
                    }
                    vendorOrderInvoicingService.addVendor(selectedRecordId, viHeaderId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                        $scope.VORModel.PopulatePageModel(successfulResult)
                    });
                    $scope.VORModel.resetSearchBox();
                } else {
                    Notification.error($translate.instant('NewVendorOrderInvoicing_Please_remove_all_items_from_this_invoice_before_cha'));
                }
            } else if (selectedRecord.originalObject.Info == 'Fee') {
                var selectedRecordId = selectedRecord.originalObject.Value;
                var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
                vendorOrderInvoicingService.addOtherCharges(viHeaderId, selectedRecordId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.PopulateGrid(null, successfulResult);
                    if ($scope.VORModel.OtherChargesList.length > 0) {
                        $scope.VORModel.OtherChargesListItems_editRow[$scope.VORModel.OtherChargesList.length - 1].isEdit = true;
                        $scope.VORModel.setFocus("description" + ($scope.VORModel.OtherChargesList.length - 1));
                    }
                });
            } else {}
        }
        $scope.VORModel.setFocus = function(elementId) {
            $timeout(function() {
                angular.element("#" + elementId).focus();
            }, 100);
        }
        $scope.VORModel.RelatedList_addAction = function(event, typeToSearch) {
            $scope.VORModel.setFocusToSearchBox(typeToSearch);
        }
        $scope.VORModel.setFocusToSearchBox = function(typeToSearch) {
            $scope.typeToSearch = typeToSearch;
            $scope.PreferredObject = typeToSearch;
            $scope.SearchableObjects = 'Fee__c';
            angular.element('#SearchToaddCutomer').focus();
        }
        $scope.VORModel.resetSearchBox = function() {
            $scope.typeToSearch = "";
            $scope.PreferredObject = "";
        }
        $scope.VORModel.PopulatePageModel = function(result) {
            if (result.VIHeaderRec.length > 0) {
                $scope.VORModel.VIHeader = result.VIHeaderRec[0];
                $scope.VendorInvoiceNumber = result.VIHeaderRec[0].InvoiceNumber;
                $scope.VORModel.VIHeader.VIHeaderId = result.VIHeaderRec[0].VIHeaderId;
            }
            if ($scope.VORModel.VIHeader != 'undefiend') {
                $scope.VORModel.PopulateGrid(null, result);
            }
            $scope.VORModel.populateLeftSideHeadingLables();
            document.getElementById("NewVendorInvoicingLoadingIconContainerID").style.display = "none"; // by kv 6th march 2017 #1652 
        }
        angular.element('.leftPanelLinks').bind('mousewheel', function(e, d) {
            var toolbox = $('.leftPanelLinks'),
                height = toolbox.height(),
                scrollHeight = toolbox.get(0).scrollHeight;
            if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                e.preventDefault();
            }
        });
        $scope.labelDataValue = {
            QtyComitted: 0,
            QtyAvalable: 0,
            Instock: 0,
            QtyOnOrder: 0,
            ReOrderMin: 0,
            ReOrderMax: 0,
            maxPoint: 0,
        };
        $scope.VORModel.updateVIHeaderDetails = function() {
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            var InvoiceDateString = $scope.VORModel.VIHeader.InvoiceDate;
            var InvoiceNumber = $scope.VORModel.VIHeader.InvoiceNumber;
            vendorOrderInvoicingService.updateVIHeader(viHeaderId, InvoiceNumber, InvoiceDateString, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.VIHeader = successfulResult.VIHeaderRec[0];
                if ($scope.VendorInvoiceNumber != InvoiceNumber) {
                    if ((InvoiceNumber != null && InvoiceNumber != '') && ((successfulResult.VIHeaderRec[0].InvoiceNumber == null || successfulResult.VIHeaderRec[0].InvoiceNumber == '') || (successfulResult.VIHeaderRec[0].InvoiceNumber != null && successfulResult.VIHeaderRec[0].InvoiceNumber != '' && InvoiceNumber != successfulResult.VIHeaderRec[0].InvoiceNumber))) {
                        Notification.error($translate.instant('Duplicate_Invoice_Number_Error_Message'));
                    } else {
                        Notification.success($translate.instant('Generic_Saved'));
                    }
                    $scope.VendorInvoiceNumber = successfulResult.VIHeaderRec[0].InvoiceNumber;
                } else {
                    Notification.success($translate.instant('Generic_Saved'));
                }
            }, function(errorResult) {
                Notification.error(errorResult + ' ' +$translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.onClickSelectAllVO = function(event) {
            if (event.target.attributes.class.value.indexOf("disabled_chk_tick") != -1) {
                return;
                event.stopPropagation();
            }
            $scope.VORModel.currentSelectedVOIndex = null;
            $scope.VORModel.currentSelectedVOId = null;
            if ($scope.VORModel.isAllVOSelected == true) { 
                angular.element('#VODeselectConfirmBox').show();
            } else {
                $scope.VORModel.isAllVOSelected = !$scope.VORModel.isAllVOSelected;
                $scope.VORModel.VODeselectConfirm();
            }
        }
        $scope.VORModel.onClickSelectVO = function(event, indexVal, vendorOrderId) {
            if ($scope.VORModel.disableSelectCheckbox == true || !$rootScope.GroupOnlyPermissions['Vendor invoicing']['create/modify']) {
                return;
            }
            $scope.VORModel.disableSelectCheckbox = true;
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            $scope.VORModel.populateLeftSideHeadingLables();
            if ($scope.VORModel.VRHeaderList[indexVal].InProgressVIHeaderId == null) {
                vendorOrderInvoicingService.addToItemsSubsection(viHeaderId, vendorOrderId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.PopulateGrid(null, successfulResult);
                    $scope.VORModel.disableSelectCheckbox = false;
                });
            } else {
                vendorOrderInvoicingService.removeFromItemSubSection(viHeaderId, vendorOrderId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.PopulateGrid(null, successfulResult);
                    $scope.VORModel.disableSelectCheckbox = false;
                });
            }
        }
        $scope.VORModel.editGroupItem = function(event, index) {
            if ($scope.VORModel.VIHeader.Status == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Vendor invoicing']['create/modify']) {
                return;
            }
            var isEditModeEnabled = false;
            if (event.target['type'] == 'text') {
                
            } else {
                for (i = 0; i < $scope.VORModel.VIGroupListItems_editRow.length; i++) {
                    if ($scope.VORModel.VIGroupListItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.VORModel.VIGroupListItems_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VORModel.VIGroupListItems_editRow[index].isEdit = true;
                } else {
                    $scope.VORModel.UpdateVIGroupItem(index);
                }
            }
        }
        $scope.VORModel.editOtherCharge = function(event, index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor invoicing']['create/modify'] || $scope.VORModel.VIHeader.Status == 'Invoiced') {
                return;
            }
            var isEditModeEnabled = false;
            if (event.target['type'] != 'text') {
                for (i = 0; i < $scope.VORModel.OtherChargesListItems_editRow.length; i++) {
                    if ($scope.VORModel.OtherChargesListItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.VORModel.OtherChargesListItems_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VORModel.OtherChargesListItems_editRow[index].isEdit = true;
                    $scope.VORModel.setFocus("description" + index);
                }
            }
        }
        $scope.VORModel.UpdateVIGroupItem = function(index) {
            if ($scope.VORModel.VIGroupList[index].InvoiceCost === undefined || $scope.VORModel.VIGroupList[index].InvoiceCost === '' || $scope.VORModel.VIGroupList[index].InvoiceCost === null) {
                $scope.VORModel.VIGroupList[index].InvoiceCost = 0;
            }
            if ($scope.VORModel.VIGroupList[index].Discount === undefined || $scope.VORModel.VIGroupList[index].Discount === '' || $scope.VORModel.VIGroupList[index].Discount === null) {
                $scope.VORModel.VIGroupList[index].Discount = 0;
            }
            if (parseFloat($scope.VORModel.VIGroupListCopy[index].InvoiceCost) === parseFloat($scope.VORModel.VIGroupList[index].InvoiceCost) && parseFloat($scope.VORModel.VIGroupListCopy[index].Discount) === parseFloat($scope.VORModel.VIGroupList[index].Discount)) {
                $scope.VORModel.populateItemsSubSectionEditableModel($scope.VORModel.VIGroupList);
                return;
            }
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            var vrHeaderId = null;
            var jsonString = $scope.VORModel.VIGroupList[index];
            vendorOrderInvoicingService.updateVIGroup(viHeaderId, vrHeaderId, jsonString, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successResult) {
                Notification.success($translate.instant('Generic_Saved'));
                $scope.VORModel.PopulateGrid(null, successResult);
            }, function(errorResult) {
                Notification.error(errorResult + ' ' + $translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.UpdateOtherChargeItem = function(index) {
            if ($scope.VORModel.OtherChargesList[index].Cost === undefined || $scope.VORModel.OtherChargesList[index].Cost === '' || $scope.VORModel.OtherChargesList[index].Cost === null) {
                $scope.VORModel.OtherChargesList[index].Cost = 0;
            }
            if ($scope.VORModel.OtherChargesList[index].Description === undefined || $scope.VORModel.OtherChargesList[index].Description === null) {
                $scope.VORModel.OtherChargesList[index].Description = '';
            }
            if ($scope.VORModel.OtherChargesList[index].Notes === undefined || $scope.VORModel.OtherChargesList[index].Notes === null) {
                $scope.VORModel.OtherChargesList[index].Notes = '';
            }
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            var vrHeaderId = null;
            var jsonString = $scope.VORModel.OtherChargesList[index];
            vendorOrderInvoicingService.updateOtherCharges(viHeaderId, jsonString, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successResult) {
                Notification.success($translate.instant('Generic_Saved'));
                $scope.VORModel.PopulateGrid(null, successResult);
            }, function(errorResult) {
                Notification.error(errorResult + ' ' + $translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.removeOtherCharge = function(index) {
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            var vrHeaderId = null;
            var otherChargesId = $scope.VORModel.OtherChargesList[index].Id;
            vendorOrderInvoicingService.deleteOtherCharges(viHeaderId, otherChargesId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successResult) {
                Notification.success($translate.instant('Generic_Deleted'));
                $scope.VORModel.PopulateGrid(null, successResult);
            }, function(errorResult) {
                Notification.error(errorResult + ' ' + $translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.editRowTabOutLast = function(event, index) {
            if (!event.shiftKey && event.keyCode == 9) {
                $scope.VORModel.UpdateVIGroupItem(index);
            }
        }
        $scope.VORModel.editRowTabOutOtherCharges = function(event, index) {
            $scope.VORModel.UpdateOtherChargeItem(index);
            angular.element('#SearchToaddCutomer').focus();
        }
        $scope.VORModel.PopulateGrid = function(gridName, result) {
            $scope.VORModel.totalVendorOrderInvoicing = result.totalVendorOrderInvoicing;
            $scope.VORModel.totalGroupItems = result.totalGroupItems;
            if (gridName == null || gridName == 'VOListGrid') {
                $scope.VORModel.VRHeaderList = result.VRHeaderList;
            }
            if (gridName == null || gridName == 'VOInvoicingGrid') {
                $scope.VORModel.VIGroupList = result.VIGroupList;
                $scope.VORModel.VIGroupListCopy = angular.copy($scope.VORModel.VIGroupList);
                $scope.VORModel.populateItemsSubSectionEditableModel(result.VIGroupList)
            }
            $scope.VORModel.OtherChargesList = result.OtherChargesList;
            $scope.VORModel.populateOtherChargesSubSectionEditableModel(result.OtherChargesList)
            $scope.VORModel.ItemsTotal = result.ItemsTotal;
            $scope.VORModel.TotalOtherCharges = result.TotalOtherCharges;
            $scope.VORModel.Taxes = result.Taxes;
            $scope.VORModel.TotalWithTax = result.TotalWithTax;
            $scope.VORModel.Total = result.Total;
        }
        $scope.VORModel.populateItemsSubSectionEditableModel = function(VIGroupList) {
            $scope.VORModel.VIGroupListItems_editRow = [];
            for (var i = 0; i < VIGroupList.length; i++) {
                $scope.VORModel.VIGroupListItems_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }
        $scope.VORModel.populateOtherChargesSubSectionEditableModel = function(OtherChargesList) {
            $scope.VORModel.OtherChargesListItems_editRow = [];
            for (var i = 0; i < OtherChargesList.length; i++) {
                $scope.VORModel.OtherChargesListItems_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }
        $scope.VORModel.loadAllGridDetails = function(gridName, callBackMethod) {
            if ($scope.VORModel.VIHeader.VIHeaderId != null) {
                vendorOrderInvoicingService.getVendorInvoicing($scope.VORModel.VIHeader.VIHeaderId, null, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.PopulatePageModel(successfulResult);
                    if (callBackMethod != null && callBackMethod != undefined) {
                        callBackMethod();
                    }
                });
            } else {
                document.getElementById("NewVendorInvoicingLoadingIconContainerID").style.display = "none"; // by kv 6th march 2017 #1653
            }
        }
        $scope.VORModel.Receiving_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VORModel.receivingPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VORModel.receivingPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VORModel.receivingPageSortAttrsJSON.CurrentPage = 1;
            $scope.VORModel.Receiving_paginationControlsAction();
        }
        $scope.VORModel.Receiving_paginationControlsAction = function() {
            $scope.VORModel.loadAllGridDetails(null, $scope.VORModel.Receiving_UpdatePaginationControls);
        }
        $scope.VORModel.Receiving_UpdatePaginationControls = function() {
            setTimeout(function() {
                $scope.VORModel.receivingPageSortAttrsJSON.ChangesCount++;
            }, 10);
        }
        $scope.VORModel.GroupItems_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VORModel.groupItemsPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VORModel.groupItemsPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VORModel.groupItemsPageSortAttrsJSON.CurrentPage = 1;
            $scope.VORModel.GroupItems_paginationControlsAction();
        }
        $scope.VORModel.GroupItems_paginationControlsAction = function() {
            $scope.VORModel.loadAllGridDetails(null, $scope.VORModel.GroupItems_UpdatePaginationControls);
        }
        $scope.VORModel.GroupItems_UpdatePaginationControls = function() {
            setTimeout(function() {
                $scope.VORModel.groupItemsPageSortAttrsJSON.ChangesCount++;
            }, 10);
        }
        $scope.VORModel.hidePanel = function(event, id) {
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
        function validateUniqueVendorInvoiceNumberForQB() {
        	vendorOrderInvoicingService.validateUniqueInvoiceNumberForQB($scope.VendorInvoiceNumber).then(function(successfulResult) {
    			if( successfulResult == 'Error QB') {
                	$scope.VORModel.disableFinalizeInvoiceBtn = false;
                	Notification.error($translate.instant('Error_msg_qb '));
                } else if( successfulResult == 'Duplicate') {
                	$scope.VORModel.disableFinalizeInvoiceBtn = false;
                	Notification.error('Duplicate invoice number : ' + $scope.VendorInvoiceNumber +  ' .This number already exists in your accounting application');
                } else {
    				finalizeVendorOrder();
    			} 
    		}, function(error) {
    			$scope.VORModel.disableFinalizeInvoiceBtn = false;
        		Notification.error(error);
            });
        }
        function validateVendorOrder() {
        	if($scope.VORModel.IsQBEnabled) {
        		validateUniqueVendorInvoiceNumberForQB();
        	} else {
        		finalizeVendorOrder();
        	}
        }
        function finalizeVendorOrder() {
        	vendorOrderInvoicingService.finalizeInvoiceAction($scope.VORModel.VIHeader.VIHeaderId, $scope.VORModel.receivingPageSortAttrsJSON, $scope.VORModel.groupItemsPageSortAttrsJSON).then(function(successfulResult) {
            	$scope.VORModel.PopulatePageModel(successfulResult);
            	$scope.VORModel.setDefaultPageSortAttrs();
                $scope.VORModel.Receiving_UpdatePaginationControls();
                $scope.VORModel.GroupItems_UpdatePaginationControls();
                $scope.VORModel.populateLeftSideHeadingLables();
                $scope.VORModel.scrollToPanel(event, 'VOI_Info_Block');
        	}, function(error) {
        		Notification.error(error);
            });
        }
        $scope.VORModel.finalizeOrder = function(event) {
            if ($scope.VORModel.disableFinalizeInvoiceBtn) {
                return;
            }
            if ($scope.VORModel.VIHeader.InvoiceNumber != $scope.VendorInvoiceNumber) {
                if ($scope.VORModel.VIHeader.InvoiceNumber == null || $scope.VORModel.VIHeader.InvoiceNumber == '') {
                    Notification.error($translate.instant(' Can\'t_finalize_Blank_Invoice_Number '));
                }
                return;
            }
            var voHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            $scope.VORModel.editGroupItem(event, 0);
            $scope.VORModel.disableFinalizeInvoiceBtn = true;
            validateVendorOrder();
        }
        
        var timer;
        $scope.VORModel.showPartPopUp = function(event, partId) {
            timer = $timeout(function() {
                $scope.$broadcast('PartPopUpEvent', partId);
                $scope.applyCssOnPopUp(event, '.Vendor-Order-Part-Popup');
            }, 1000);
        }
        $scope.VORModel.hidePartPopUp = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-Part-Popup').hide();
        }
        $scope.applyCssOnPopUp = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top);
            angular.element(className).css('left', event.clientX);
            setTimeout(function() {
                angular.element(className).show();
            }, 1000);
        }
        var timer3;
        $scope.VORModel.showInvoiceDetail = function(vrHeaderId, event) {
            timer3 = $timeout(function() {
                $scope.VORModel.InvoiceDetailInfo = {};
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element('.Invoice-info-overlay').css('top', targetEle.offset().top - 27);
                angular.element('.Invoice-info-overlay').css('left', event.clientX);
                angular.element('.Invoice-info-overlay').show();
                vendorOrderInvoicingService.getVRHeaderDetails(vrHeaderId).then(function(vrHeaderDetail) {
                    $scope.VORModel.vrHeaderDetail = vrHeaderDetail;
                }, function(errorSearchResult) {
                    $scope.VORModel.vrHeaderDetail = errorSearchResult;
                });
            }, 1000);
        }
        $scope.VORModel.showInfoOverlay = function(event, vendorId) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element('.Vendor-info-overlay').css('top', targetEle.offset().top - 45);
            angular.element('.Vendor-info-overlay').css('left', event.clientX);
            angular.element('.Vendor-info-overlay').show();
        }
        $scope.VORModel.showVendorInfoOverlay = function(event, vendorId) {
            $scope.$broadcast('VendorInfoPopUpEvent', vendorId);
            $scope.VORModel.showInfoOverlay(event, vendorId);
        }
        $scope.VORModel.hideVendorInfoOverlay = function() {
            angular.element('.Vendor-info-overlay').hide();
        }
        $scope.VORModel.hideInvoiceDetail = function() {
            $timeout.cancel(timer3);
            angular.element('.Invoice-info-overlay').hide();
        }
        $scope.VORModel.confirmDelete = function() {
            var dialog = ngDialog.open({
                template: '<div class="dialogBox"><h3>Delete Vendor Invoicing  ' + '</h3><hr/>' + '<form >' + '<span > Are you sure ? <hr/>' + '<div style="text-align: right;">' + '<button style="margin-right:10px;" type="button" class="btn btn-default greenBtn" ng-click="VORModel.vendorInvoicingDelete()' + ' && closeThisDialog()">Delete</button>' + '<button style="margin-right:10px;" type="button" class="btn btn-default grayBtn" ng-click="closeThisDialog()">Cancel</button>' + '</div>' + '</form>' + '</div>',
                showClose: false,
                scope: $scope,
                plain: true
            });
        };
        $scope.VORModel.showSections = function(fieldName) {
            if ($rootScope.GroupOnlyPermissions['Vendor invoicing']['view']) {
                $scope.VORModel.displaySections[fieldName] = !$scope.VORModel.displaySections[fieldName];
            }
        }
        $scope.VORModel.showDeleteInvoicingLink = function() {
            if ($scope.VORModel.VIGroupList != undefined && $scope.VORModel.VIGroupList.length == 0 && $scope.VORModel.VIHeader != undefined && $scope.VORModel.VIHeader.Status == 'In Progress' && $scope.VORModel.OtherChargesList.length == 0) {
                return true;
            } else {
                return false;
            }
        }
        $scope.VORModel.vendorInvoicingDelete = function() {
            var viHeaderId = $scope.VORModel.VIHeader.VIHeaderId;
            vendorOrderInvoicingService.deleteVendorInvoice(viHeaderId).then(function(successfulResult) {
                if (successfulResult == 'Success') {
                    Notification.success($translate.instant('NewVendorOrderInvoicing_Vendor_Invoice_Deleted_Successfully'));
                    loadState($state, 'homePage');
                } else {
                    Notification.error($translate.instant('Something_is_changed_on_this_Invoicing'));
                    $scope.VORModel.initFunction();
                }
            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
            });
        };
        $scope.VORModel.dateFormat = $Global.DateFormat;
        $scope.VORModel.VOI_InvoiceDate = {
            maxDate: new Date,
            showOtherMonths: true,
            selectOtherMonths: false,
            dateFormat: $scope.VORModel.dateFormat
        };
        $scope.VORModel.showCalendar = function(IdVal) {
            if (!$rootScope.GroupOnlyPermissions['Vendor invoicing']['create/modify']) {
                return;
            }
            angular.element("#" + IdVal).focus();
        }
        $scope.VORModel.initFunction();
    }])
});