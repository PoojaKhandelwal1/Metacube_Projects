define(['Routing_AppJs_PK', 'VendorOrderReceivingServices', 'AngularNgEnter', 'NumberOnlyInput_VR', 'DirPagination', 'PartPopUpOnVendorOrderCtrl', 'AutoSuggestVendorOrderCtrl', 'VendorInfoCtrl', 'dirNumberInput', 'DYMOBarcodeLabelService', 'BarcodePrintService'], function(Routing_AppJs_PK, VendorOrderReceivingServices, AngularNgEnter, NumberOnlyInput_VR, DirPagination, PartPopUpOnVendorOrderCtrl, AutoSuggestVendorOrderCtrl, VendorInfoCtrl, dirNumberInput, DYMOBarcodeLabelService, BarcodePrintService) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('VendorOrderReceivingCtrl', ['$q', '$scope', '$rootScope', '$stateParams', '$state', '$filter', '$timeout', 'vendorOrderReceivingService', '$translate', 'DYMOBarcodeLabelService', 'BarcodePrintService', function($q, $scope, $rootScope, $stateParams, $state, $filter, $timeout, vendorOrderReceivingService, $translate, DYMOBarcodeLabelService, BarcodePrintService) {
        var Notification = injector.get("Notification");
        var origin = window.location.origin;
        var url = origin + '/apex/';
        $scope.VORModel = {};
        $scope.PackagingSlipNumber = '';
        $scope.VORModel.VOR_Header = {};
        $scope.VORModel.SelectedVendorOrdersList = {};
        $scope.VORtool = {};
        $scope.VendorOrderModel = {};
        $scope.COPopupModel = {};
        $scope.VORModel.isLoading = false;
        $scope.VORModel.outstandingItems_editRow = [];
        $scope.VORModel.outstandingItems_selected = [];
        $scope.VORModel.OutstandingItemSelectedStatus = 0;
        $scope.VORModel.disableAddSelectedButton = false;
        $scope.VORtool.helpText = {
            Rec: 'Received',
        };
        $scope.labelDataValue = {
            QtyComitted: 0,
            QtyAvalable: 0,
            Instock: 0,
            QtyOnOrder: 0,
            ReOrderMin: 0,
            ReOrderMax: 0,
            maxPoint: 0,
        };
        $scope.VORModel.HoldResult = {};
        $scope.FilterID = "";
        $scope.SearchToadd = {};
        $scope.typeToSearch = "";
        $scope.PreferredObject = "Vendor";
        var sortOrderMap = {
            "ASC": "DESC",
            "DESC": ""
        };
        var timer;
        
        $scope.VORModel.showNeededForPopUp = function(event, vrGroupId) {
            $scope.applyCssOnPopUp(event, '.Vendor-Order-popup');
            vendorOrderReceivingService.getGroupRecDetail(vrGroupId).then(function(vrGroupRecord) {
                if (vrGroupRecord.length > 0) {
                    $scope.VendorOrderModel.voGroupRecordDetail = vrGroupRecord[0];
                }
            }, function(errorSearchResult) {
                $scope.VendorOrderModel.OverlayInfo = errorSearchResult;
            });
        }
        $scope.VORModel.hideNeededForPopUp = function() {
            angular.element('.Vendor-Order-popup').hide();
        }
        $scope.VORModel.viewCOHeader = function(coHeaderId) {
            window.open('/apex/customerOrder?id=' + coHeaderId, '_blank');
        }
        $scope.VORModel.showPartPopUp = function(event, partId) {
            $scope.applyCssOnPopUp(event, '.Vendor-Order-Part-Popup');
            vendorOrderReceivingService.getPartRecord(partId).then(function(partRecord) {
                if (partRecord.PartDetailRec != undefined) {
                    $scope.VendorOrderModel.partInfoDetail = partRecord.PartDetailRec;
                }
            }, function(errorSearchResult) {
                $scope.VORModel.OverlayInfo = errorSearchResult;
            });
        }
        $scope.applyCssOnPopUpRight = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top - 22);
            angular.element(className).css('left', targetEle.offset().left + elementWidth - 400);
            angular.element(className).show();
        }
        $scope.applyCssOnPopUp = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top - 22);
            angular.element(className).css('left', event.clientX);
            angular.element(className).show();
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
        $scope.applyCssOnPartPopUp = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top - 22);
            angular.element(className).css('left', event.clientX);
            setTimeout(function() {
                angular.element(className).show();
            }, 1000);
        }
        var timer;
        $scope.VORModel.showCOPopUp = function(event, coHeaderId) {
            if (coHeaderId == null || coHeaderId == 'undefined') {
                return;
            }
            timer = $timeout(function() {
                $scope.applyCssOnPopUp(event, '.Vendor-Order-CODetail-Popup');
                vendorOrderReceivingService.getCOHeaderRec(coHeaderId).then(function(coHeaderRecord) {
                    if (coHeaderRecord.length > 0) {
                        $scope.VendorOrderModel.coHeaderInfoDetail = coHeaderRecord[0];
                    }
                }, function(errorSearchResult) {
                    $scope.VendorOrderModel.OverlayInfo = errorSearchResult;
                });
            }, 1000);
        }
        $scope.VORModel.hideCOPopUp = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-CODetail-Popup').hide();
        }
        $scope.COPopupModel.closeCOPopup = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-CODetail-Popup').hide();
        }
        $scope.VORModel.hidePartPopUp = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-Part-Popup').hide();
        }
        $scope.VORModel.setDefaultPageSortAttrs = {};
        $scope.VORModel.vendorOrdersPageSortAttrsJSON = {};
        $scope.VORModel.groupItemsVOGPageSortAttrsJSON = {};
        $scope.VORModel.outstandingVOGPageSortAttrsJSON = {};
        $scope.VORModel.setDefaultPageSortAttrs = function() {
            $scope.VORModel.vendorOrdersPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Order",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VORModel.vendorOrdersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
            $scope.VORModel.groupItemsVOGPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Order",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VORModel.groupItemsVOGPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
            $scope.VORModel.outstandingVOGPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Order",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VORModel.outstandingVOGPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
        }
        $scope.VORModel.setDefaultValidationModel = function() {
            $scope.VORModel.VendorOrderReceivingFormValidationModal = {
                PackagingSlipNumber: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                },
                ReceivingFromInvoiceTotal: {
                    isError: false,
                    ErrorMessage: '',
                    Type: 'Required'
                }
            };
        }
        $scope.VORModel.setDefaultValidationModel();
        $scope.VORModel.hidePanel = function(event, id) {
            var targetelement = angular.element(event.target).closest('h1').find('.fa:first');
            if (targetelement.hasClass('fa-cheVORon-right')) {
                targetelement.removeClass('fa-cheVORon-right');
                targetelement.addClass('fa-cheVORon-down');
            } else {
                targetelement.removeClass('fa-cheVORon-down');
                targetelement.addClass('fa-cheVORon-right');
            }
            $('#' + id).toggle();
        }
        $scope.VORModel.calculateSidebarHeight = function() {
            var leftPanelLinks = angular.element(window).height() - (angular.element(".headerNav").height() + angular.element(".orderNumber").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + angular.element(".ownerInfo").height() + angular.element(".sideBarTotals").height() + 83);
            angular.element(".leftPanelLinks").css("height", leftPanelLinks);
        }
        $scope.$watch(function() {
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 2000);
        });
        $scope.VORModel.loadVendor = function() {
            $scope.VORModel.disableCommitReceivingBtn = false;
            $scope.VORModel.VOR_Header.VORId = null;
            if ($stateParams.myParams != undefined && $stateParams.myParams.Id != undefined && $stateParams.myParams.Id != null && $stateParams.myParams.Id != '') {
                $scope.VORModel.VOR_Header.VORId = $stateParams.myParams.Id;
            } else {
                $scope.VORModel.VOR_Header.VORId = $stateParams.Id;
            }
            if ($scope.VORModel.VOR_Header.VORId != null && $scope.VORModel.VOR_Header.VORId.trim().length != 15 && $scope.VORModel.VOR_Header.VORId.trim().length != 18) {
                $scope.VORModel.VOR_Header.VORId = null;
            }
            $scope.SearchToAddCallback = $scope.VORModel.searchToAddCallback;
            $scope.VORModel.setDefaultPageSortAttrs();
            if ($scope.VORModel.VOR_Header.VendorName == null) {
                $scope.VORModel.populateLeftSideHeadingLables();
            }
            $scope.VORModel.loadAllGridDetails(null, null);
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 2000);
        }
        $scope.VORModel.loadAllGridDetails = function(gridName, callBackMethod) {
            if ($scope.VORModel.VOR_Header.VORId != null) {
                var lastEditedPartId = null
                vendorOrderReceivingService.getVORDetails($scope.VORModel.VOR_Header.VORId, gridName, lastEditedPartId, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.populatePageModels(gridName, successfulResult);
                    if (callBackMethod != null && callBackMethod != undefined) {
                        callBackMethod();
                    }
                    if ($scope.VORModel.isrefresh) {
                        $scope.VORModel.outstandingItems_selected = [];
                        $scope.VORModel.OutstandingItemSelectedStatus = 0;
                        for (var i = 0; i < $scope.VORModel.outstandingVOGList.length; i++) {
                            $scope.VORModel.outstandingItems_editRow[i].isSelected = false;
                        }
                    }
                    $scope.VORModel.isrefresh = false;
                    setTimeout(function() {
                        $scope.VORModel.calculateSidebarHeight();
                    }, 10);
                    $scope.VORModel.adjustSectionScroll();
                    $scope.VORModel.isLoading = false;
                });
            } else {
                document.getElementById("VRLoadingIconContainerId").style.display = "none";
            }
        }
        $scope.VORModel.addVendor = function(selectedVendorId) {
            $scope.VORModel.setDefaultPageSortAttrs();
            vendorOrderReceivingService.addVendor(selectedVendorId, $scope.VORModel.VOR_Header.VORId).then(function(successfulResult) {
                if ($scope.VORModel.VOR_Header.VORId == null || $scope.VORModel.VOR_Header.VORId == 'undefined') {
                    var url = '?id=' + successfulResult;
                }
                $scope.VORModel.VOR_Header.VORId = successfulResult;
                $scope.VORModel.loadAllGridDetails(null, null);
                setTimeout(function() {
                    angular.element('#packingSlipNumber').focus();
                }, 2000);
            });
        }
        $scope.VORModel.populatePageModels = function(gridName, newResult) {
            $scope.VORModel.VOR_Header = (newResult.VOR_Header != null) ? newResult.VOR_Header : {};
            $scope.PackagingSlipNumber = $scope.VORModel.VOR_Header.PackagingSlipNumber;
            $scope.VORModel.isCommitActionAvailable = isBlankValue($scope.PackagingSlipNumber) ? false: true;
            $scope.VORModel.GroupTotalCost = newResult.GroupTotalCost;
            $scope.VORModel.VIHistoryList = newResult.VIHistoryList
            if (gridName == null || gridName.toLowerCase() == 'groupitems') {
                $scope.VORModel.totalGroupItems = newResult.totalGroupItems;
                $scope.VORModel.VORLineItemGroupList = newResult.VORGroupList;
                $scope.VORModel.populateVORLineItemGroupListEditableModel($scope.VORModel.VORLineItemGroupList);
            }
            if (gridName == null || gridName.toLowerCase() == 'vendororder') {
                $scope.VORModel.isAllVOSelected = newResult.isAllVOSelected;
                $scope.VORModel.SelectedVendorOrdersList = newResult.SelectedVendorOrdersList;
                $scope.VORModel.totalVendorOrders = newResult.totalVendorOrders;
                $scope.VORModel.vendorOrdersList = newResult.vendorOrdersList;
                $scope.VORModel.populateVendorOrdersEditableModel($scope.VORModel.vendorOrdersList);
            }
            if (gridName == null || gridName.toLowerCase() == 'outstanding') {
                $scope.VORModel.totalOutstandingItems = newResult.totalOutstandingItems;
                $scope.VORModel.outstandingVOGList = newResult.outstandingVOGList;
                $scope.VORModel.populateOutstandingItemsEditableModel($scope.VORModel.outstandingVOGList);
            }
            $scope.FilterID = $scope.VORModel.VOR_Header.VendorId;
            if ($scope.VORModel.vendorOrdersList.length == 0) {
                $scope.SearchableObjects = 'Vendor,Part__c';
            } else {
                if (($scope.VORModel.outstandingVOGList.length == 0) && ($scope.VORModel.VORLineItemGroupList.length == 0)) {
                    if ($scope.VORModel.VOR_Header.VendorId == null) {
                        $scope.SearchableObjects = 'Vendor';
                    } else {
                        $scope.SearchableObjects = 'Vendor,Part__c';
                    }
                } else {
                    $scope.SearchableObjects = 'Part__c';
                }
            }
            if (gridName == null) {
                $scope.VORModel.ReceivingForVO_UpdatePaginationControls();
                $scope.VORModel.OutstandingItems_UpdatePaginationControls();
                setTimeout(function() {
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }, 500);
            }
            $scope.VORModel.populateLeftSideHeadingLables();
            document.getElementById("VRLoadingIconContainerId").style.display = "none";
        }
        var timer;
        $scope.VORModel.openpartpopup = function(event, index) {
            timer = $timeout(function() {
                var partId = $scope.VORModel.VORLineItemGroupList[index].PartId;
                $scope.$broadcast('PartPopUpEvent', partId);
                $scope.applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
            }, 1000);
        }
        $scope.VORModel.populateLeftSideHeadingLables = function() {
            $scope.VORModel.LeftSideHeadingLables = {};
            var currentHeadingSequenceIndex = 65;
            $scope.VORModel.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
            $scope.VORModel.LeftSideHeadingLables['I_General'] = 1
            $scope.VORModel.LeftSideHeadingLables['I_Receiving_For_Vendor'] = 2
            if (($scope.VORModel.VORLineItemGroupList != undefined && $scope.VORModel.VORLineItemGroupList.length != 0) || ($scope.VORModel.outstandingVOGList != undefined && $scope.VORModel.outstandingVOGList.length != 0)) {
                $scope.VORModel.LeftSideHeadingLables['Received'] = String.fromCharCode(currentHeadingSequenceIndex++);
                $scope.VORModel.LeftSideHeadingLables['R_Items'] = 1
                $scope.VORModel.LeftSideHeadingLables['R_Outstanding'] = 2
            }
            if ($scope.VORModel.VOR_Header.Status == "In Progress") {
                $scope.VORModel.LeftSideHeadingLables['Finalize'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
            if ($scope.VORModel.VOR_Header.Status == "Invoiced" || $scope.VORModel.VOR_Header.Status == "Stocked") {
                $scope.VORModel.LeftSideHeadingLables['Invoice_History'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
        }
        $scope.VORModel.populateVORLineItemGroupListEditableModel = function(vendorOrdersGroupList) {
            $scope.VORModel.groupItems_editRow = [];
            for (var i = 0; i < vendorOrdersGroupList.length; i++) {
                voLineItems = vendorOrdersGroupList[i].VendorOrderLineItemList;
                voLineItems_editRow = [];
                for (var j = 0; j < voLineItems.length; j++) {
                    voLineItems_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
                $scope.VORModel.groupItems_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0,
                    voLineItems_editRow: voLineItems_editRow,
                    isChanged: 0
                });
            }
        }
        $scope.VORModel.preventDecimal = function($event) {
            if ($event.which === 46) return false;
            if ($event.target.value.indexOf('.') != -1) $event.target.value = parseInt($event.target.value, 10);
        }
        $scope.VORModel.populateVendorOrdersEditableModel = function(vendorOrdersList) {
            $scope.VORModel.vendorOrderItems_editRow = [];
            for (var i = 0; i < vendorOrdersList.length; i++) {
                voLIGroups = vendorOrdersList[i].VOLIGroups;
                voliGroups_editRow = [];
                var isEditableVendorOrder = vendorOrdersList[i].InProgressVRId == null || vendorOrdersList[i].InProgressVRId.substring(0, 15) == $scope.VORModel.VOR_Header.VORId.substring(0, 15);
                for (var j = 0; j < voLIGroups.length; j++) {
                    voliGroups_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
                $scope.VORModel.vendorOrderItems_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0,
                    voliGroups_editRow: voliGroups_editRow,
                    isEditable: isEditableVendorOrder
                });
            }
        }
        $scope.VORModel.populateOutstandingItemsEditableModel = function(outstandingItemsList) {
            $scope.VORModel.outstandingItems_editRow = [];
            for (var i = 0; i < outstandingItemsList.length; i++) {
                $scope.VORModel.outstandingItems_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0,
                    isSelected: false
                });
            }
        }
        $scope.VORModel.RelatedList_addAction = function(event, typeToSearch) {
            $scope.VORModel.setFocusToSearchBox(typeToSearch);
        }
        $scope.VORModel.searchToAddCallback = function(selectedRecord) {
            if (selectedRecord.originalObject.Info == 'Merchandise') {
                $scope.VORModel.AddItemFromSearch(selectedRecord.originalObject);
            } else if (selectedRecord.originalObject.Info == 'Vendor') {
                var selectedRecordId = selectedRecord.originalObject.Value;
                if (selectedRecordId.length == 18) {
                    selectedRecordId = selectedRecordId.substring(0, 15);
                }
                $scope.VORModel.addVendor(selectedRecordId);
            }
            $scope.VORModel.resetSearchBox();
        }
        $scope.VORModel.setFocusToSearchBox = function(typeToSearch) {
            $scope.typeToSearch = typeToSearch;
            $scope.PreferredObject = typeToSearch;
            angular.element('#SearchToaddCutomer').focus();
        }
        $scope.VORModel.resetSearchBox = function() {
            $scope.typeToSearch = "";
            $scope.PreferredObject = "";
        }
        $scope.VORModel.AddItemFromSearch = function(selectedData) {
            var partId = selectedData.Value;
            var vendorId = $scope.VORModel.VOR_Header.VendorId;
            var VORId = $scope.VORModel.VOR_Header.VORId;
            var isFromSearchToAdd = 'true'
            $scope.VORModel.groupItemsVOGPageSortAttrsJSON.FieldName = 'LastModifiedDate';
            vendorOrderReceivingService.addToItemSubsection(VORId, partId, vendorId, isFromSearchToAdd, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                if (successfulResult.isFoundPartInOtherVOHeader == true) {
                    $scope.VORModel.HoldResult = {
                        'VORId': VORId,
                        'partId': partId,
                        'vendorId': vendorId
                    };
                    $scope.VORModel.StockexcessConfirmBoxShow();
                } else {
                    $scope.VORModel.OnCompleteSearch(successfulResult);
                }
            }, function(errorSearchResult) {
                $scope.VORModel.OverlayInfo = errorSearchResult;
            });
        }
        $scope.VORModel.OnCompleteSearch = function(successfulResult) {
            $scope.VORModel.VORLineItemGroupList = successfulResult.VORGroupList;
            $scope.VORModel.isAllVOSelected = successfulResult.isAllVOSelected;
            $scope.VORModel.totalOutstandingItems = successfulResult.totalOutstandingItems;
            $scope.VORModel.outstandingVOGList = successfulResult.outstandingVOGList;
            $scope.FilterID = $scope.VORModel.VOR_Header.VendorId;
            if ($scope.VORModel.vendorOrdersList.length == 0) {
                $scope.SearchableObjects = 'Vendor,Part__c';
            } else {
                if (($scope.VORModel.outstandingVOGList.length == 0) && ($scope.VORModel.VORLineItemGroupList.length == 0)) {
                    if ($scope.VORModel.VOR_Header.VendorId == null) {
                        $scope.SearchableObjects = 'Vendor';
                    } else {
                        $scope.SearchableObjects = 'Vendor,Part__c';
                    }
                } else {
                    $scope.SearchableObjects = 'Part__c';
                }
            }
            $scope.VORModel.EditRecent(successfulResult);
        }
        $scope.VORModel.EditRecent = function(successfulResult) {
            var recentlyEdit = successfulResult.RecentlyEditedVORGroupList;
            var voliGroups_editRow = [];
            if (recentlyEdit.length > 0 || recentlyEdit != null || recentlyEdit != 'undefined') {
                $scope.VORModel.groupItems_editRow = [];
                var vendorOrdersGroupList = $scope.VORModel.VORLineItemGroupList;
                for (var i = 0; i < vendorOrdersGroupList.length; i++) {
                    voLineItems = vendorOrdersGroupList[i].VendorOrderLineItemList;
                    voLineItems_editRow = [];
                    for (var j = 0; j < voLineItems.length; j++) {
                        voLineItems_editRow.push({
                            isEdit: false,
                            radioValue: 0,
                            optionSelected: 0
                        });
                    }
                    if (recentlyEdit.length > 0 && (recentlyEdit[0].Id == vendorOrdersGroupList[i].Id)) {
                        $scope.VORModel.groupItems_editRow.push({
                            isEdit: true,
                            radioValue: 0,
                            optionSelected: 0,
                            voLineItems_editRow: voLineItems_editRow,
                            isChanged: 0
                        });
                    } else {
                        $scope.VORModel.groupItems_editRow.push({
                            isEdit: false,
                            radioValue: 0,
                            optionSelected: 0,
                            voLineItems_editRow: voLineItems_editRow,
                            isChanged: 0
                        });
                    }
                }
            } else {
                $scope.VORModel.populatePageModels(null, successfulResult);
            }
            setTimeout(function() {
                angular.element('#' + 'received_qty_Edit_' + (0)).focus();
                angular.element('#' + 'received_qty_Edit_' + (0)).select();
            }, 10);
            var newId = 'rowGroupIineItem' + (0);
            $timeout(function() {
                $scope.VORModel.scrollToPanel(null, newId);
            }, 500);
        }
        $scope.VORModel.editVendorOrderReceivedItem = function(event, index) {
            if ($scope.VORModel.VOR_Header.Status == 'Stocked' || $scope.VORModel.VOR_Header.Status == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
                return;
            }
            a = event;
            if (event.target.attributes.class != null && (event.target.attributes.class.value.indexOf("chk_tick") != -1 || event.target.attributes.class.value.indexOf("chksqure") != -1)) {
                return;
            }
            var isEditModeEnabled = false;
            var prevEditedRowIndex;
            var isEditableVendorOrder = $scope.VORModel.vendorOrderItems_editRow[index].isEditable;
            for (i = 0; i < $scope.VORModel.vendorOrderItems_editRow.length; i++) {
                if ($scope.VORModel.vendorOrderItems_editRow[i].isEdit == true) {
                    isEditModeEnabled = true;
                    prevEditedRowIndex = i;
                }
                $scope.VORModel.vendorOrderItems_editRow[i].isEdit = false;
            }
            if (isEditableVendorOrder && (!isEditModeEnabled || (prevEditedRowIndex != null && prevEditedRowIndex != index))) {
                $scope.VORModel.vendorOrderItems_editRow[index].isEdit = true;
            }
        }
        $scope.VORModel.editvoGroupItem = function(event, parentindex, index) {
            var isEditModeEnabled = false;
            var prevEditedRowIndex;
            if (event.target.tagName == 'P' || event.target.tagName == 'I') {
                
            } else {
                if ($scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[index].isEdit == true) {
                    $scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[index].isEdit = false;
                    return;
                }
            }
            if ($scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[index].isEdit == false) {
                for (i = 0; i < $scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow.length; i++) {
                    if ($scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        prevEditedRowIndex = i;
                    }
                    $scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[i].isEdit = false;
                }
            }
            if (!isEditModeEnabled || (prevEditedRowIndex != null && prevEditedRowIndex != index)) {
                $scope.VORModel.vendorOrderItems_editRow[parentindex].voliGroups_editRow[index].isEdit = true;
            }
        }
        $scope.VORModel.editOutstandingItem = function(event, index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
                return;
            }
            if ($scope.VORModel.VOR_Header.Status == 'Stocked' || $scope.VORModel.VOR_Header.Status == 'Invoiced') {
                return;
            }
            if (event.target['type'] == 'radio' || event.target.nodeName == 'I' || event.target.classList[0] == 'chk_tick') {
                return;
            }
            var isEditModeEnabled = false;
            var prevEditedRowIndex;
            for (i = 0; i < $scope.VORModel.outstandingItems_editRow.length; i++) {
                if ($scope.VORModel.outstandingItems_editRow[i].isEdit == true) {
                    isEditModeEnabled = true;
                    prevEditedRowIndex = i;
                }
                $scope.VORModel.outstandingItems_editRow[i].isEdit = false;
            }
            if (!isEditModeEnabled || (prevEditedRowIndex != null && prevEditedRowIndex != index)) {
                $scope.VORModel.outstandingItems_editRow[index].isEdit = true;
            }
        }
        $scope.VORModel.onClickReceivingFromInvoice = function(event) {
            $scope.VORModel.VOR_Header.IsReceivingFromInvoice = !$scope.VORModel.VOR_Header.IsReceivingFromInvoice;
            if ($scope.VORModel.VOR_Header.ReceivingFromInvoiceTotal == null || $scope.VORModel.VOR_Header.ReceivingFromInvoiceTotal == '') {
                $scope.VORModel.VOR_Header.ReceivingFromInvoiceTotal = 0;
            }
            if ($scope.VORModel.VOR_Header.IsReceivingFromInvoice) {
                
            } else {
                delete $scope.VORModel.VendorOrderReceivingFormValidationModal.ReceivingFromInvoiceTotal;
            }
            $scope.VORModel.updateVORHeaderDetails();
        }
        $scope.VORModel.numberOnlyValue = function(e) {
            -1 !== $.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) || /65|67|86|88/.test(e.keyCode) && (!0 === e.ctrlKey || !0 === e.metaKey) || 35 <= e.keyCode && 40 >= e.keyCode || (e.shiftKey || 48 > e.keyCode || 57 < e.keyCode) && (96 > e.keyCode || 105 < e.keyCode) && e.preventDefault();
        }
        $scope.VORModel.updateVORHeaderDetails = function() {
            var UpdatedPackagingSlipNumber = $scope.VORModel.VOR_Header.PackagingSlipNumber;
            if ($scope.VORModel.VOR_Header.PackagingSlipNumber != null && $scope.VORModel.VOR_Header.PackagingSlipNumber != undefined && $scope.VORModel.VOR_Header.PackagingSlipNumber != "") {
                vendorOrderReceivingService.updateVORHeaderDetails($scope.VORModel.VOR_Header.VORId, $scope.VORModel.VOR_Header).then(function(successfulResult) {
                    $scope.VORModel.VOR_Header = successfulResult;
                    $scope.PackagingSlipNumber = successfulResult.PackagingSlipNumber;
                    if (successfulResult.PackagingSlipNumber == null || successfulResult.PackagingSlipNumber == '') {
                    	Notification.error($translate.instant('NewVendorOrderReceiving_Packaging_Slip_Required'));
                    } else if(successfulResult.PackagingSlipNumber != null && UpdatedPackagingSlipNumber != successfulResult.PackagingSlipNumber) {
                        Notification.error($translate.instant('Duplicate_Packaging_Slip_Error_Message'));
                        $scope.VORModel.isCommitActionAvailable = true;
                 	} else {
                        Notification.success($translate.instant('Generic_Saved'));
                        $scope.VORModel.isCommitActionAvailable = true;
                    }
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
            } else {
                $scope.VORModel.VOR_Header.PackagingSlipNumber = $scope.PackagingSlipNumber;
                $scope.VORModel.isCommitActionAvailable = isBlankValue($scope.PackagingSlipNumber) ? false: true;
                Notification.error($translate.instant('NewVendorOrderReceiving_Packaging_Slip_Required'));
            }
        }
        $scope.VORModel.PrintVendorReceiving = function() {
            if ($rootScope.GroupOnlyPermissions['Vendor receiving']['view']) {
                window.open(url + "PrintVendorOrderReceiving?id=" + $scope.VORModel.VOR_Header.VORId, "", "width=1200, height=600");
            }
        }
        $scope.VORModel.vendorOrderItems_GoAction = function(index, parentGirdIndex) {
            if (parentGirdIndex == null) {
                var vorId = $scope.VORModel.VOR_Header.VORId;
                var vohId = $scope.VORModel.vendorOrdersList[index].Id;
                var vogId = null
                vendorOrderReceivingService.addAllLineItemsToItemSubsection(vorId, vohId, vogId, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.populatePageModels(null, successfulResult);
                });
            } else {
                var vorId = $scope.VORModel.VOR_Header.VORId;
                var vohId = null;
                var vogId = $scope.VORModel.vendorOrdersList[parentGirdIndex].VOLIGroups[index].Id;
                vendorOrderReceivingService.addAllLineItemsToItemSubsection(vorId, vohId, vogId, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.populatePageModels(null, successfulResult);
                });
            }
        }
        $scope.VORModel.vendorOrderReceivingGroup_GoAction = function(index) {
            $scope.VORModel.VORLineItemGroupList[index]
        }
        $scope.VORModel.outstandingItems_GoAction = function(index, parentGirdIndex) {
            var partId = $scope.VORModel.outstandingVOGList[index].PartId;
            var itemsGridNewPN = $scope.VORModel.outstandingVOGPageSortAttrsJSON.CurrentPage;
            if ($scope.VORModel.totalOutstandingItems % $scope.VORModel.outstandingVOGPageSortAttrsJSON.PageSize == 1) {
                $scope.VORModel.outstandingVOGPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
            }
            vendorOrderReceivingService.addToItemSubsection($scope.VORModel.VOR_Header.VORId, partId, $scope.VORModel.VOR_Header.VendorId, false, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.populatePageModels(null, successfulResult);
            });
        }
        $scope.VORModel.onClickSelectAllVO = function(event) {
            $scope.VORModel.currentSelectedVOIndex = null;
            $scope.VORModel.currentSelectedVOId = null;
            $scope.VORModel.isAllVOSelected = true;
            if (!$scope.VORModel.isAllVOSelected) {
                angular.element('#VODeselectConfirmBox').show();
            } else {
                $scope.VORModel.VODeselectConfirm();
            }
        }
        
        $scope.VORModel.getAllVOSelectStatus = function() {
            var allSelected, partialSelected;
            if($scope.VORModel.vendorOrdersList) {
               for(var i = 0; i < $scope.VORModel.vendorOrdersList.length; i++) {
	                if($scope.VORModel.vendorOrdersList[i].InProgressVRId && $scope.VORModel.vendorOrdersList[i].InProgressVRId == $scope.VORModel.VOR_Header.VORId) {
	                   allSelected = partialSelected = true;
	                } else if(allSelected) {
                    	allSelected = false;
                        break;
	                }
	            }
            }
            return (allSelected ? 'allSelected' : (partialSelected ? 'partialSelected' : 'None'));
        }
        
        $scope.VORModel.selectDeselectAllVO = function(event) {       	
             if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
               return;
             }
             if($scope.VORModel.getAllVOSelectStatus() == 'None') {
            	 $scope.VORModel.isLoading = true;
                $scope.VORModel.onClickSelectAllVO(event,true);
             } else {
               for(var i =0 ; i<$scope.VORModel.vendorOrdersList.length;i++) {
            	   if($scope.VORModel.vendorOrdersList[i].InProgressVRId == $scope.VORModel.VOR_Header.VORId) {
            		   $scope.VORModel.isLoading = true;
            		   deselectVOResponsive(i,$scope.VORModel.vendorOrdersList[i].Id);
            	   }
               }      
            }
        }

        function deselectVOResponsive(indexVal, vendorOrderId) {
           var InProgressVRId = $scope.VORModel.VOR_Header.VORId;
           var isSelected = $scope.VORModel.isAllVOSelected;
           if (indexVal != null) {
               $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId = ($scope.VORModel.vendorOrdersList[indexVal].InProgressVRId == null) ? $scope.VORModel.VOR_Header.VORId : null;
               InProgressVRId = $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId;
               $scope.VORModel.isAllVOSelected = !$scope.VORModel.isAllVOSelected;
           }
           vendorOrderReceivingService.receiveVendorOrderItems(vendorOrderId, InProgressVRId, isSelected).then(function(successfulResult) {
               if (successfulResult == true) {
                   //$scope.VORModel.isAllVOSelected = !$scope.VORModel.isAllVOSelected;
                   $scope.VORModel.loadAllGridDetails(null, null);
               } else if (indexVal != null) {
                   $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId = null;
                   $scope.VORModel.isLoading = false;
               }
           });
       }
       
        $scope.VORModel.onClickSelectVO = function(event, indexVal, vendorOrderId) {
            $scope.VORModel.isAllVOSelected = false;
            if (($scope.VORModel.vendorOrdersList[indexVal].InProgressVRId != null && $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId != $scope.VORModel.VOR_Header.VORId) || $scope.VORModel.VOR_Header.Status == 'Stocked' || $scope.VORModel.VOR_Header.Status == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) { /*  || $scope.VORModel.isAllVOSelected == null Changed by richa */
                return;
            }
            a = event;
            $scope.VORModel.currentSelectedVOIndex = indexVal;
            $scope.VORModel.currentSelectedVOId = vendorOrderId;
            if ($scope.VORModel.vendorOrdersList[indexVal].InProgressVRId != null) {
                if ($scope.VORModel.isAllVOSelected) {
                    $scope.VORModel.VODeselectConfirm();
                } else {
                    angular.element('#VODeselectConfirmBox').show();
                }
            } else {
                $scope.VORModel.VODeselectConfirm();
            }
        }
        $scope.VORModel.editGroupItem = function(event, index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
                return;
            }
            if (event.target['type'] == 'text') {} else {
                var isEditModeEnabled = false;
                var lineitem = [];
                for (i = 0; i < $scope.VORModel.groupItems_editRow.length; i++) {
                    if ($scope.VORModel.groupItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        index = i;
                    }
                    $scope.VORModel.groupItems_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VORModel.groupItems_editRow[index].isEdit = true;
                } else {
                    var vrGroupId = $scope.VORModel.VORLineItemGroupList[index].Id;
                    var partId = $scope.VORModel.VORLineItemGroupList[index].PartId;
                    var qty = $scope.VORModel.VORLineItemGroupList[index].ReceivedQty;
                    var cost = $scope.VORModel.VORLineItemGroupList[index].Cost;
                    var vorId = $scope.VORModel.VOR_Header.VORId;
                    $scope.VORModel.updateReceivedItemGroup(vorId, partId, vrGroupId, qty, cost, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON)
                }
                setTimeout(function() {
                    angular.element(event.target).closest('tr').find('input').not('.descEditInput').filter(':first').focus();
                }, 100);
            }
        }
        $scope.VORModel.updateReceivedItemGroup = function(vorId, partId, vrGroupId, qty, cost, vendorOrdersPageSortAttrsJSON, groupItemsPageSortAttrsJSON, outstandingVOGPageSortAttrsJSON) {
            vendorOrderReceivingService.updateItemsSection(vorId, partId, vrGroupId, qty, cost, vendorOrdersPageSortAttrsJSON, groupItemsPageSortAttrsJSON, outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.populatePageModels(null, successfulResult)
            });
        }
        $scope.VORModel.updateReceivedItemGroupChildClick = function(vorId, partId, vrGroupId, qty, cost, vendorOrdersPageSortAttrsJSON, groupItemsPageSortAttrsJSON, outstandingVOGPageSortAttrsJSON) {
            vendorOrderReceivingService.updateItemsSection(vorId, partId, vrGroupId, qty, cost, vendorOrdersPageSortAttrsJSON, groupItemsPageSortAttrsJSON, outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.OnCompleteSearch(successfulResult)
            });
        }
        $scope.VORModel.editRowTabOutRecieved = function(event, index) {
            $scope.VORModel.groupItems_editRow[index].isChanged = 1;
        }
        $scope.VORModel.editRowTabOutLast = function(event, index) {
            $scope.VORModel.groupItems_editRow[index].isChanged = 1;
            if (!event.shiftKey && event.keyCode == 9) {
                var vrGroupId = $scope.VORModel.VORLineItemGroupList[index].Id;
                var partId = $scope.VORModel.VORLineItemGroupList[index].PartId;
                var qty = $scope.VORModel.VORLineItemGroupList[index].ReceivedQty;
                var cost = $scope.VORModel.VORLineItemGroupList[index].Cost;
                var vorId = $scope.VORModel.VOR_Header.VORId;
                $scope.VORModel.updateReceivedItemGroup(vorId, partId, vrGroupId, qty, cost, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON)
                $scope.VORModel.scrollToPanel(event, 'VOR_Items_Block');
                setTimeout(function() {
                    angular.element('#SearchToaddCutomer').focus();
                }, 10);
            }
        }
        $scope.VORModel.editRowTabOutChild = function(event, parentindex, index) {
            if (!event.shiftKey && event.keyCode == 9) {
                var result = $scope.VORModel.ReceivedItemTotalValidation(parentindex);
                if (result == true) {
                    var groupJSONString = [];
                    groupJSONString[0] = $scope.VORModel.VORLineItemGroupList[parentindex];
                    var vrGroupId = $scope.VORModel.VORLineItemGroupList[parentindex].Id;
                    var partId = $scope.VORModel.VORLineItemGroupList[parentindex].PartId;
                    var vorId = $scope.VORModel.VOR_Header.VORId;
                    vendorOrderReceivingService.updateLineItemsOfItemsSection(vorId, partId, vrGroupId, groupJSONString, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                        $scope.VORModel.OnCompleteSearch(successfulResult);
                    });
                } else {
                    $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[index].isEdit = false;
                    Notification.error($translate.instant('NewVendorOrderReceiving_Total_Quantity_Match'));
                }
            }
        }
        $scope.VORModel.editVolItem = function(event, index, parentindex) {
            var isEditModeEnabled = false;
            var lineitem = [];
            var partId = null;
            var voLineItem = null;
            var qtyRequired = null;
            if ($scope.VORModel.groupItems_editRow[parentindex].isChanged == 1) {
                var vrGroupId = $scope.VORModel.VORLineItemGroupList[parentindex].Id;
                var partId = $scope.VORModel.VORLineItemGroupList[parentindex].PartId;
                var qty = $scope.VORModel.VORLineItemGroupList[parentindex].ReceivedQty;
                var cost = $scope.VORModel.VORLineItemGroupList[parentindex].Cost;
                var vorId = $scope.VORModel.VOR_Header.VORId;
                $scope.VORModel.updateReceivedItemGroupChildClick(vorId, partId, vrGroupId, qty, cost, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON)
            } else {
                if (event.target['type'] == 'text') {} else {
                    for (i = 0; i < $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow.length; i++) {
                        if ($scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit == true) {
                            $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit
                            isEditModeEnabled = true;
                        }
                        $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit = false;
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[index].isEdit = true;
                } else {
                    var result = $scope.VORModel.ReceivedItemTotalValidation(parentindex);
                    if (result == true) {
                        var groupJSONString = [];
                        groupJSONString[0] = $scope.VORModel.VORLineItemGroupList[parentindex];
                        var vrGroupId = $scope.VORModel.VORLineItemGroupList[parentindex].Id;
                        var partId = $scope.VORModel.VORLineItemGroupList[parentindex].PartId;
                        var vorId = $scope.VORModel.VOR_Header.VORId;
                        vendorOrderReceivingService.updateLineItemsOfItemsSection(vorId, partId, vrGroupId, groupJSONString, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                            $scope.VORModel.OnCompleteSearch(successfulResult);
                        });
                    } else {
                        $scope.VORModel.groupItems_editRow[parentindex].voLineItems_editRow[index].isEdit = true;
                        Notification.error($translate.instant('Item_can_be_saved_only_till_reciving_total_not_eqaul_to_group_total'));
                    }
                }
            }
        }
        $scope.VORModel.ReceivedItemTotalValidation = function(index) {
            var GroupItem = $scope.VORModel.VORLineItemGroupList[index];
            var Ispackaged = $scope.VORModel.VORLineItemGroupList[index].UnitType;
            var voli = GroupItem.VendorOrderLineItemList;
            var qtyReceived = 0;
            var PackageQty = $scope.VORModel.VORLineItemGroupList[index].PackageQty;
            if (Ispackaged != null && Ispackaged != 'NULL') {
                for (i = 0; i < voli.length; i++) {
                    qtyReceived = qtyReceived + parseInt(voli[i].ReceivedQty);
                }
                qtyReceived = qtyReceived / PackageQty;
                if (qtyReceived != GroupItem.ReceivedQty) {
                    return false;
                } else {
                    return true;
                }
            } else {
                for (i = 0; i < voli.length; i++) {
                    qtyReceived = qtyReceived + parseInt(voli[i].ReceivedQty);
                }
                if (qtyReceived != GroupItem.ReceivedQty) {
                    return false;
                } else {
                    return true;
                }
            }
        }
        $scope.VORModel.StockexcessConfirmBoxShow = function() {
            angular.element('#StockexcessConfirmBox').modal({
                backdrop: 'static',
                keyboard: false
            });
        }
        $scope.VORModel.StockexcessConfirmBox_Response = function(response) {
            if (response) {
                $scope.VORModel.isAllVOSelected = false;
                $scope.VORModel.StockexcessConfirm();
            }
            angular.element('#StockexcessConfirmBox').modal('hide');
        }
        $scope.VORModel.StockexcessConfirm = function() {
            var vorId = $scope.VORModel.HoldResult.VORId;
            var partId = $scope.VORModel.HoldResult.partId;
            var vendorId = $scope.VORModel.VOR_Header.VendorId;
            $scope.VORModel.HoldResult = {};
            vendorOrderReceivingService.addToItemSubsectionAfterConfimation(vorId, partId, vendorId, true, true, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.OnCompleteSearch(successfulResult)
            });
        }
        $scope.VORModel.VODeselectConfirmBox_Response = function(response) {
            if (response) {
                $scope.VORModel.isAllVOSelected = false;
                $scope.VORModel.VODeselectConfirm();
            }
            angular.element('#VODeselectConfirmBox').hide();
        }
        $scope.VORModel.VODeselectConfirm = function() {
            var indexVal = $scope.VORModel.currentSelectedVOIndex;
            var vendorOrderId = ($scope.VORModel.currentSelectedVOId != undefined) ? $scope.VORModel.currentSelectedVOId : null;
            var InProgressVRId = $scope.VORModel.VOR_Header.VORId;
            var isSelected = $scope.VORModel.isAllVOSelected;
            if (indexVal != null) {
                $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId = ($scope.VORModel.vendorOrdersList[indexVal].InProgressVRId == null) ? $scope.VORModel.VOR_Header.VORId : null;
                InProgressVRId = $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId;
            }
            vendorOrderReceivingService.receiveVendorOrderItems(vendorOrderId, InProgressVRId, isSelected).then(function(successfulResult) {
                if (successfulResult == true) {
                    $scope.VORModel.loadAllGridDetails(null, null);
                } else if (indexVal != null) {
                    $scope.VORModel.vendorOrdersList[indexVal].InProgressVRId = null;
                    $scope.VORModel.isLoading = false;
                }
            });
        }
        $scope.VORModel.groupItemsGoAction = function(index) {
            if ($scope.VORModel.groupItems_editRow[index].radioValue != 0) {
                var vrGroupId = $scope.VORModel.VORLineItemGroupList[index].Id;
                var vorId = $scope.VORModel.VOR_Header.VORId;
                var itemsGridNewPN = $scope.VORModel.groupItemsVOGPageSortAttrsJSON.CurrentPage;
                if ($scope.VORModel.totalGroupItems % $scope.VORModel.groupItemsVOGPageSortAttrsJSON.PageSize == 1) {
                    $scope.VORModel.groupItemsVOGPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                }
                vendorOrderReceivingService.removeItem(vorId, vrGroupId, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                    $scope.VORModel.populatePageModels(null, successfulResult);
                    setTimeout(function() {
                        $scope.VORModel.groupItemsVOGPageSortAttrsJSON.ChangesCount++;
                    }, 10);
                    for (var i = 0; i < $scope.VORModel.outstandingVOGList.length; i++) {
                        var idToSelect = $scope.VORModel.outstandingVOGList[i].PartId;
                        for (var j = 0; j < $scope.VORModel.outstandingItems_selected.length; j++) {
                            if ($scope.VORModel.outstandingItems_selected[j] == idToSelect) {
                                $scope.VORModel.outstandingItems_editRow[i].isSelected = true;
                                $scope.VORModel.outstandingItems_editRow[i].isEdit = false;
                                break;
                            }
                        }
                    }
                });
            }
        }
        $scope.VORModel.ReceivingForVO_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VORModel.vendorOrdersPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VORModel.vendorOrdersPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VORModel.vendorOrdersPageSortAttrsJSON.CurrentPage = 1;
            $scope.VORModel.ReceivingForVO_paginationControlsAction();
        }
        $scope.VORModel.ReceivingForVO_paginationControlsAction = function() {
            $scope.VORModel.loadAllGridDetails('VendorOrder', $scope.VORModel.ReceivingForVO_UpdatePaginationControls);
        }
        $scope.VORModel.ReceivingForVO_UpdatePaginationControls = function() {
            setTimeout(function() {
                $scope.VORModel.vendorOrdersPageSortAttrsJSON.ChangesCount++;
            }, 10);
        }
        $scope.VORModel.OutstandingItems_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VORModel.outstandingVOGPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VORModel.outstandingVOGPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VORModel.outstandingVOGPageSortAttrsJSON.CurrentPage = 1;
            $scope.VORModel.OutstandingItems_paginationControlsAction();
        }
        $scope.VORModel.OutstandingItems_paginationControlsAction = function() {
            $scope.VORModel.loadAllGridDetails('OutStanding', $scope.VORModel.OutstandingItems_UpdatePaginationControls);
        }
        $scope.VORModel.OutstandingItems_UpdatePaginationControls = function() {
            for (var i = 0; i < $scope.VORModel.outstandingItems_selected.length; i++) {
                for (var j = 0; j < $scope.VORModel.outstandingVOGList.length; j++) {
                	if($scope.VORModel.outstandingVOGList[j].PartId && $scope.VORModel.outstandingItems_selected[i] == $scope.VORModel.outstandingVOGList[j].PartId) {
                		$scope.VORModel.outstandingItems_editRow[j].isSelected = true;
                	} else if($scope.VORModel.outstandingVOGList[j].SubletId && $scope.VORModel.outstandingItems_selected[i] == $scope.VORModel.outstandingVOGList[j].Id) {
                		$scope.VORModel.outstandingItems_editRow[j].isSelected = true;
                	}
                }
            }
            setTimeout(function() {
                $scope.VORModel.outstandingVOGPageSortAttrsJSON.ChangesCount++;
            }, 10);
        }
        $scope.VORModel.GroupItems_PageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VORModel.groupItemsVOGPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VORModel.groupItemsVOGPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VORModel.groupItemsVOGPageSortAttrsJSON.CurrentPage = 1;
            $scope.VORModel.GroupItems_paginationControlsAction();
        }
        $scope.VORModel.GroupItems_paginationControlsAction = function() {
            $scope.VORModel.loadAllGridDetails(null, $scope.VORModel.GroupItems_UpdatePaginationControls);
        }
        $scope.VORModel.GroupItems_UpdatePaginationControls = function() {
            setTimeout(function() {
                $scope.VORModel.groupItemsVOGPageSortAttrsJSON.ChangesCount++;
            }, 10);
        }
        $scope.VORModel.addAllReceiving = function() {
            
        }
        $scope.VORModel.removeAllReceived = function() {
            var vorId = $scope.VORModel.VOR_Header.VORId;
            vendorOrderReceivingService.removeAllItemsFromItemSubSection(vorId, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.populatePageModels(null, successfulResult);
            });
        }
        $scope.VORModel.addAllOutstanding = function() {
            var vorId = $scope.VORModel.VOR_Header.VORId;
            vendorOrderReceivingService.addAllLineItemsToItemSubsection(vorId, null, null, $scope.VORModel.vendorOrdersPageSortAttrsJSON, $scope.VORModel.groupItemsVOGPageSortAttrsJSON, $scope.VORModel.outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.populatePageModels(null, successfulResult);
            });
        }
        $scope.VORModel.finalizeOrder = function(event) {
            if ($scope.VORModel.disableCommitReceivingBtn || !$scope.VORModel.isCommitActionAvailable) {
                return;
            }
            $scope.VORModel.isLoading = true;
            var vorId = $scope.VORModel.VOR_Header.VORId;
            $scope.VORModel.disableCommitReceivingBtn = true; //  Added by Pooja 21 Jan. 2017
            vendorOrderReceivingService.CommitReceiving(vorId).then(function(successfulResult) {
                if(successfulResult != $translate.instant('NewVendorOrderReceiving_Packaging_Slip_Required')) {
                	$scope.VORModel.VOR_Header.Status = successfulResult.Status;
                    $scope.VORModel.populateLeftSideHeadingLables();
                    $scope.VORModel.scrollToPanel(event, 'VOR_Info_Block');
                } else {
                	Notification.error($translate.instant('NewVendorOrderReceiving_Packaging_Slip_Required'));
                	$scope.VORModel.disableCommitReceivingBtn = false;
                }
                $scope.VORModel.isLoading = false;
            }, function(errorResult) {
                $scope.VORModel.disableCommitReceivingBtn = false;
                $scope.VORModel.isLoading = false;
            });
        }
        $scope.VORModel.confirmDelete = function() {
            var dialog = ngDialog.open({
                template: '<div class="dialogBox"><h3>Delete Vendor Invoicing  ' + '</h3><hr/>' + '<form >' + '<span > Are you sure ? <hr/>' + '<div style="text-align: right;">' + '<button style="margin-right:10px;" type="button" class="btn btn-default greenBtn" ng-click="VORModel.vendorRecievingDelete()' + ' && closeThisDialog()">Delete</button>' + '<button style="margin-right:10px;" type="button" class="btn btn-default grayBtn" ng-click="closeThisDialog()">Cancel</button>' + '</div>' + '</form>' + '</div>',
                showClose: false,
                scope: $scope,
                plain: true
            });
        };
        $scope.VORModel.loadVendorRefresh = function() {
            $scope.VORModel.isrefresh = true;
            $scope.VORModel.loadVendor();
        }
        $scope.VORModel.showDeleteReceivingLink = function() {
            if ($scope.VORModel.VORLineItemGroupList != undefined && $scope.VORModel.VORLineItemGroupList.length == 0 && $scope.VORModel.VOR_Header != undefined && $scope.VORModel.VOR_Header.Status == 'In Progress') {
                return true;
            } else {
                return false;
            }
        }
        $scope.VORModel.vendorRecievingDelete = function() {
            vendorOrderReceivingService.deleteVendorRecieving($scope.VORModel.VOR_Header.VORId).then(function(successfulResult) {
                if (successfulResult == 'Success') {
                    Notification.success($translate.instant('NewVendorOrderReceiving_Recieving_Delete'));
                    loadState($state, 'homePage');
                } else {
                    Notification.error($translate.instant('Something_is_changed_on_this_Receiving'));
                    $scope.VORModel.loadVendor();
                }
            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
            });
        };
        if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['view']) {
            $scope.VORModel.displaySections = {
                'Info': false,
                'Received': false,
                'Finalize': false,
                'InvoiceHistory': false
            };
        } else {
            $scope.VORModel.displaySections = {
                'Info': true,
                'Received': true,
                'Finalize': true,
                'InvoiceHistory': true
            };
        }
        $scope.VORModel.showSections = function(fliedName) {
            if ($rootScope.GroupOnlyPermissions['Vendor receiving']['view']) {
                $scope.VORModel.displaySections[fliedName] = !$scope.VORModel.displaySections[fliedName];
            }
        }
        $scope.VORModel.activeSidepanelink = '#InfoSection';
        $scope.VORModel.selectedItem = 'Info';
        $scope.VORModel.dropDownItem = function(event, selectedSection) {
            var activeSection = $scope.VORModel.activeSidepanelink.replace('#', '');
            $scope.VORModel.selectedItem = selectedSection;
            if (activeSection != selectedSection) {
                $scope.VORModel.sidepanelLink(event, selectedSection);
            }
        }
        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function() {
            $scope.VORModel.onScroll();
        });
        $scope.VORModel.scrollToPanel = function(event, sectionToscroll) {
            if (event != null) {
                event.preventDefault();
            }
            angular.element(document).off("scroll");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 0;
            }
            var target = angular.element("#" + sectionToscroll);
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 110 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VORModel.onScroll();
                });
                $scope.VORModel.onScroll();
            });
        }
        $scope.VORModel.sidepanelLink = function(event, relatedContent) {
            event.preventDefault();
            angular.element(document).off("scroll");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 0;
            }
            var target = angular.element(event.target.closest('a')).attr("href");
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VORModel.onScroll();
                });
                $scope.VORModel.onScroll();
            });
        }
        $scope.VORModel.onScroll = function() {
            if ($state.current.name === 'VendorOrderReceiving') {
                var activeSidepanelink;
                var selectedItem;
                var heading = '';
                var scrollPos = angular.element(document).scrollTop();
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 25;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 10;
                }
                if ((isElementDefined('#VOR_Info_Block') && (scrollPos < angular.element('#VOR_Info_Block').position().top + angular.element('#VOR_Info_Block').height() + 80 - navBarHeightDiffrenceFixedHeaderOpen)) || $scope.VORModel.VOR_Header.VendorName == null) {
                    activeSidepanelink = '#InfoSection';
                    selectedItem = 'Info';
                } else if (isElementDefined('#VOR_Vendor_Received_Block') && (scrollPos < angular.element('#VOR_Vendor_Received_Block').position().top + angular.element('#VOR_Vendor_Received_Block').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen) && angular.element('#VOR_Vendor_Received_Block').height() != 0) {
                    activeSidepanelink = '#ReceivedSection';
                    selectedItem = 'Received';
                } else if ((isElementDefined('#VOR_Finalize_Block') && (scrollPos < angular.element('#VOR_Finalize_Block').position().top + angular.element('#VOR_Finalize_Block').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#VOR_Finalize_Block').height() != 0) {
                    activeSidepanelink = '#FinalizeSection';
                    selectedItem = 'Finalize';
                } else if ((isElementDefined('#VOR_Vendor_Invoicing_Block') && (scrollPos < angular.element('#VOR_Vendor_Invoicing_Block').position().top + angular.element('#VOR_Vendor_Invoicing_Block').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#VOR_Vendor_Invoicing_Block').height() != 0) {
                    activeSidepanelink = '#InvoiceHistorySection';
                    selectedItem = 'InvoiceHistory';
                }
                $scope.VORModel.activeSidepanelink = activeSidepanelink;
                $scope.VORModel.selectedItem = selectedItem;
                if (!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }
        $scope.VORModel.adjustSectionScroll = function() {
            var sectionName = '';
            if ($scope.VORModel.outstandingVOGList.length > 0) {
                sectionName = 'VOR_Outstanding_Items_Block';
            } else if ($scope.VORModel.VORLineItemGroupList.length > 0) {
                sectionName = 'VOR_Items_Block';
            }
            if (sectionName != '') {
                setTimeout(function() {
                    $scope.VORModel.scrollToPanel(null, sectionName);
                }, 1000);
            }
        }
        $scope.VORModel.enableSelectedBtnInReceivedSection = function() {
            var enableButton = false;
            if ($scope.VORModel.outstandingVOGList.length > 0) {
                if ($scope.VORModel.getSelectAllStatusForOutstandingItems() == 'PartialCheck' || $scope.VORModel.getSelectAllStatusForOutstandingItems() == 'chked') {
                    enableButton = true;
                }
            }
            return enableButton;
        }
        $scope.VORModel.selectDeselectAllForOutstandingItems = function() {
            if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
                return;
            }
            if ($scope.VORModel.OutstandingItemSelectedStatus == 2) {
                $scope.VORModel.OutstandingItemSelectedStatus = 0;
                for (var i = 0; i < $scope.VORModel.outstandingVOGList.length; i++) {
                    $scope.VORModel.outstandingItems_editRow[i].isSelected = false;
                }
                $scope.VORModel.outstandingItems_selected = [];
            } else {
                $scope.VORModel.OutstandingItemSelectedStatus = 2;
                $scope.VORModel.getAllselectedRecords();
            }
        }
        $scope.VORModel.getAllselectedRecords = function() {
            var VendorId = $scope.VORModel.VOR_Header.VendorId;
            var vrHeaderId = $scope.VORModel.VOR_Header.VORId;
            vendorOrderReceivingService.getAllVOLIGroupItem(VendorId, vrHeaderId).then(function(successfulResult) {
                $scope.VORModel.outstandingItems_selected = successfulResult;
                for (var i = 0; i < $scope.VORModel.outstandingVOGList.length; i++) {
                    $scope.VORModel.outstandingItems_editRow[i].isSelected = true;
                }
                $scope.VORModel.OutstandingItemSelectedStatus = 2;
            }, function(errorSearchResult) {
                Notification.error($translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.getSelectAllStatusForOutstandingItems = function() {
            if ($scope.VORModel.outstandingItems_selected.length == 0) {
                $scope.VORModel.OutstandingItemSelectedStatus = 0;
                return '';
            }
            if ($scope.VORModel.totalOutstandingItems == $scope.VORModel.outstandingItems_selected.length) {
                $scope.VORModel.OutstandingItemSelectedStatus = 2;
                return 'chked';
            } else {
                $scope.VORModel.OutstandingItemSelectedStatus = 1;
                return 'PartialCheck';
            }
        }
        $scope.VORModel.addRemoveSelectedOutstandingVRli = function(index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor receiving']['create/modify']) {
                return;
            }
            if ($scope.VORModel.outstandingItems_editRow[index].isSelected == false) {
                if($scope.VORModel.outstandingVOGList[index].PartId) {
            		$scope.VORModel.outstandingItems_selected.push($scope.VORModel.outstandingVOGList[index].PartId);
            	} else if($scope.VORModel.outstandingVOGList[index].SubletId) {
            		$scope.VORModel.outstandingItems_selected.push($scope.VORModel.outstandingVOGList[index].VendorOrderLineItemList[0].Id);
            	}
                $scope.VORModel.outstandingItems_editRow[index].isSelected = true;
            } else {
                var idToRemove = $scope.VORModel.outstandingVOGList[index].PartId;
                for (var i = 0; i < $scope.VORModel.outstandingItems_selected.length; i++) {
                    if ($scope.VORModel.outstandingItems_selected[i] == idToRemove) {
                        $scope.VORModel.outstandingItems_selected.splice(i, 1);
                        $scope.VORModel.outstandingItems_editRow[index].isSelected = false;
                    }
                }
            }
            $scope.VORModel.getSelectAllStatusForOutstandingItems();
        }
        $scope.VORModel.getLabelPrintingData = function(VORHeaderId) {
        	DYMOBarcodeLabelService.dymoFrameworkInitHelper(); // Load DYMO init async
            
        	vendorOrderReceivingService.getLabelPrintingData(VORHeaderId).then(function(successfulResult) {
                angular.element("#PrintBarCodeLabel .table tbody").scrollTop(0);
                $scope.VORModel.PrintBarCodeLabelCopy = angular.copy(successfulResult);
                $scope.VORModel.PrintBarCodeLabel = successfulResult
                $scope.VORModel.noOfLabelPrint = 0;
                for (var i = 0; i < $scope.VORModel.PrintBarCodeLabel.length; i++) {
                    if ($scope.VORModel.PrintBarCodeLabel[i].IsSelected) {
                        $scope.VORModel.noOfLabelPrint += parseInt($scope.VORModel.PrintBarCodeLabel[i].NoOfStockLabels) + parseInt($scope.VORModel.PrintBarCodeLabel[i].NoOfCustomerLabels);
                    }
                }
                var WindowHeight = window.innerHeight;
                var popupHeight = WindowHeight;
                angular.element("#PrintBarCodeLabel").css("max-height", popupHeight + 'px');
                var tableHeaddingHeight = angular.element("#PrintBarCodeLabel .heading").height() + 55;
                var tableHeaderHeight = angular.element("#PrintBarCodeLabel .table thead").height();
                var tableFooterHeight = angular.element("#PrintBarCodeLabel .formBtn").height()
                var totalHeightDifference = popupHeight - (tableHeaddingHeight + tableHeaderHeight + tableFooterHeight + 100)
                angular.element("#PrintBarCodeLabel .table tbody").css("max-height", totalHeightDifference + 'px');
            }, function(errorSearchResult) {
                Notification.error($translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.PrintBarCode = function() {
            $scope.VORModel.PrintBarCode.Temp = [];
            for (var i = 0; i < $scope.VORModel.PrintBarCodeLabel.length; i++) {
                if ($scope.VORModel.PrintBarCodeLabel[i].IsSelected) {
                    $scope.VORModel.PrintBarCode.Temp.push($scope.VORModel.PrintBarCodeLabel[i]);
                }
            }
            if(DYMOBarcodeLabelService.checkEnvironment()) {
            	DYMOBarcodeLabelService.printVendorReceivingPartLabels("/labels/PartLabelTemplate.label", $scope.VORModel.PrintBarCode.Temp);
            } else {
            	window.open(url + "BarcodePrint?JSON=" + '&PageName=' + 'isFromVOR' + '&JSON=' + encodeString(angular.toJson($scope.VORModel.PrintBarCode.Temp)), "", "width=1200, height=600");
            }
        }
        $scope.VORModel.checkLabelPrint = function(index) {
            $scope.VORModel.PrintBarCodeLabel[index].IsSelected = !$scope.VORModel.PrintBarCodeLabel[index].IsSelected;
            if ($scope.VORModel.PrintBarCodeLabel[index].IsSelected) {
                $scope.VORModel.noOfLabelPrint += parseInt($scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels) + parseInt($scope.VORModel.PrintBarCodeLabel[index].NoOfCustomerLabels);
            }
            if (!$scope.VORModel.PrintBarCodeLabel[index].IsSelected) {
                $scope.VORModel.noOfLabelPrint -= parseInt($scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels) + parseInt($scope.VORModel.PrintBarCodeLabel[index].NoOfCustomerLabels);
                $scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels = $scope.VORModel.PrintBarCodeLabelCopy[index].NoOfStockLabels;
            }
        }
        $scope.VORModel.calculateNoOfLabel = function(index) {
            $scope.VORModel.noOfLabelPrint = 0;
            if ($scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels == 0 && $scope.VORModel.PrintBarCodeLabel[index].NoOfCustomerLabels == 0) {
                $scope.VORModel.PrintBarCodeLabel[index].IsSelected = false;
            }
            if ($scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels == '') {
                $scope.VORModel.PrintBarCodeLabel[index].IsSelected = false;
                $scope.VORModel.PrintBarCodeLabel[index].NoOfStockLabels = $scope.VORModel.PrintBarCodeLabelCopy[index].NoOfStockLabels;
            }
            for (var i = 0; i < $scope.VORModel.PrintBarCodeLabel.length; i++) {
                if ($scope.VORModel.PrintBarCodeLabel[i].IsSelected) {
                    $scope.VORModel.noOfLabelPrint += parseInt($scope.VORModel.PrintBarCodeLabel[i].NoOfStockLabels) + parseInt($scope.VORModel.PrintBarCodeLabel[i].NoOfCustomerLabels);
                }
            }
        }
        $scope.VORModel.addSelectedItemsFromOutstandingToItemSection = function() {
            var selectedVRLIIdJSON = $scope.VORModel.outstandingItems_selected;
            var vrHeaderId = $scope.VORModel.VOR_Header.VORId;
            var vendorOrdersPageSortAttrsJSON = $scope.VORModel.vendorOrdersPageSortAttrsJSON;
            var groupItemsVOGPageSortAttrsJSON = $scope.VORModel.groupItemsVOGPageSortAttrsJSON;
            var outstandingVOGPageSortAttrsJSON = $scope.VORModel.outstandingVOGPageSortAttrsJSON;
            vendorOrderReceivingService.groupAllSelectedLineItems(vrHeaderId, selectedVRLIIdJSON, vendorOrdersPageSortAttrsJSON, groupItemsVOGPageSortAttrsJSON, outstandingVOGPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VORModel.outstandingItems_selected = [];
                setTimeout(function() { // TODAY kajal 14th april, 2017
                    if (($scope.VORModel.outstandingVOGList.length > 0) && ($scope.VORModel.outstandingVOGList.length == ($filter('filter')($scope.VORModel.outstandingItems_editRow, {
                            isSelected: true
                        }).length))) { // 5th april, 2017
                        var itemsGridNewPN = $scope.VORModel.outstandingVOGPageSortAttrsJSON.CurrentPage;
                        $scope.VORModel.outstandingVOGPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                        $scope.VORModel.OutstandingItems_paginationControlsAction();
                    }
                }, 20);
                $scope.VORModel.GroupTotalCost = successfulResult.GroupTotalCost;
                $scope.VORModel.SelectedVendorOrdersList = successfulResult.SelectedVendorOrdersList;
                $scope.VORModel.VIHistoryList = successfulResult.VIHistoryList;
                $scope.VORModel.VORLineItemGroupList = successfulResult.VORGroupList;
                $scope.VORModel.VOR_Header = successfulResult.VOR_Header;
                $scope.VORModel.isAllVOSelected = successfulResult.isAllVOSelected;
                $scope.VORModel.outstandingVOGList = successfulResult.outstandingVOGList;
                $scope.VORModel.totalGroupItems = successfulResult.totalGroupItems;
                $scope.VORModel.totalOutstandingItems = successfulResult.totalOutstandingItems;
                $scope.VORModel.totalVendorOrders = successfulResult.totalVendorOrders;
                $scope.VORModel.vendorOrdersList = successfulResult.vendorOrdersList;
                if (successfulResult.RecentlyEditedVORGroupList.length > 0) {
                    $scope.VORModel.EditRecent(successfulResult);
                }
                $scope.VORModel.populateVORLineItemGroupListEditableModel($scope.VORModel.VORLineItemGroupList);
                $scope.VORModel.populateOutstandingItemsEditableModel($scope.VORModel.outstandingVOGList);
                $scope.VORModel.populateLeftSideHeadingLables();
                $scope.VORModel.adjustSectionScroll();
                $scope.VORModel.disableAddSelectedButton = false;
            }, function(errorSearchResult) {
                $scope.VORModel.disableAddSelectedButton = false;
                Notification.error($translate.instant('Generic_Error'));
            });
        }
        $scope.VORModel.doBlur = function(event) {
            var target = event.target;
            target.blur();
        }
        $scope.VORModel.updatePackagingSlipNumber = function() {
            if ($scope.PackagingSlipNumber != $scope.VORModel.VOR_Header.PackagingSlipNumber) {
                $scope.VORModel.isCommitActionAvailable = false;
                $scope.VORModel.updateVORHeaderDetails();
            } else {
                $scope.VORModel.isCommitActionAvailable = isBlankValue($scope.PackagingSlipNumber) ? false: true;
                return;
            }
        }
        $scope.VORModel.loadVendor();
    }]);
});