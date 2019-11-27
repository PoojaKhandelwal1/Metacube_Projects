define(['Routing_AppJs_PK', 'VendorOrderServices', 'JqueryUI', 'VendorOrder_NumberOnlyInput', 'DirPagination', 'VendorInfoCtrl', 'PartPopUpOnVendorOrderCtrl', 'ModalDialog', 'PartLocator'], function(Routing_AppJs_PK, VendorOrderServices, JqueryUI, VendorOrder_NumberOnlyInput, DirPagination, VendorInfoCtrl, PartPopUpOnVendorOrderCtrl, ModalDialog, PartLocator) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('VendorOrderCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$filter', '$stateParams', '$state', 'vendorOrderService', '$translate', function($scope, $timeout, $q, $rootScope, $sce, $filter, $stateParams, $state, vendorOrderService, $translate) {
        var Notification = injector1.get("Notification");
        $scope.VendorOrderModel = {};
        $scope.VORModel = {};
        $scope.VORModel.VOR_Header = {};
        $scope.VendorOrderModel.SelectedSection = {};
        $scope.VendorOrderModel.IsARIPartSmartEnabled = $Global.IsARIPartSmartEnabled;
        $scope.VendorOrderModel.SelectedSection.item = 'Info';
        $scope.VendorOrderModel.isPermittedToEditVOHeader = $Global.isPermittedToEditVOHeader;
        $scope.VendorOrderModel.VendorOrderHeader = {};
        $scope.VendorOrderModel.vendorOrderLineItemGroupList = {};
        $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = {};
        $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = {};
        $scope.VendorOrderModel.groupItems_editRow = [];
        $scope.VendorOrderModel.groupItemsForCancel_editRow = [];
        $scope.VendorOrderModel.requiredForCustomerItems_editRow = [];
        $scope.VendorOrderModel.requiredForStockItems_editRow = [];
        $scope.VendorOrderModel.requiredForCustomerItems_selected = [];
        $scope.VendorOrderModel.requiredForStockItems_selected = [];
        $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 0;
        $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 0;
        $scope.VendorOrderModel.disableAddSelectedButton = false;
        $scope.VendorOrderModel.showExportConfirmationModal = false;
        $scope.VendorOrderModel.ConfirmationModel = {};
        $scope.VendorOrderModel.PartLocator = {};
        $scope.VendorOrderModel.ExportTypeList = ['Generic (.csv)', 'Parts Canada (.csv)', 'HDnet Australia', 'BossWeb'];
        $scope.VendorOrderModel.ExportTypeMap = {
        		"1": {
        			Name: "Generic (.csv)",
        			Value: "Generic"
        		},
        		"2": {
        			Name: "Parts Canada (.csv)",
        			Value: "Parts Canada"
        		},
        		"3": {
        			Name: "HDnet Australia",
        			Value: "HDnet Australia"
        		},
                "4": {
                    Name: "BossWeb",
                    Value: "BossWeb"
                }
        };
        $scope.VendorOrderModel.VendorOrderExportType = {
    			Name: "Generic (.csv)",
    			Value: "Generic"
    	};
        $scope.FilterID = "";
        $scope.SearchToadd = {};
        $scope.typeToSearch = "";
        $scope.PreferredObject = "Vendor";
        $scope.VendorOrderModel.VendorOrderHeader.disableFinalizeOrderBtn = false;
        $scope.VendorOrderModel.helpText = {
            Order: $Label.Order,
            Items: $Label.Items,
            RequiredForCustomer: $Label.Required_For_Customer,
            RequiredForStock: $Label.Required_For_Stock,
            StockExcess: $Label.Stock_Excess,
            ReceivingHistory: $Label.Receiving_History,
            Finalize: $Label.Finalize
        };
        $scope.$on('blurOnSearchInput', function(data) {
            $scope.VendorOrderModel.searchDivActive = data;
        });
        $scope.VendorOrderModel.resetHideResults = function() {
            $scope.VendorOrderModel.searchDivActive = true;
        };
        $scope.VendorOrderModel.hideResults = function() {
            $scope.VendorOrderModel.searchDivActive = false;
        };
        $scope.VendorOrderModel.select = function() {
            $scope.VendorOrderModel.searchDivActive = true;
        };
        if ($rootScope.GroupOnlyPermissions['Vendor order']['view']) {
            $scope.VendorOrderModel.displaySections = {
                'Info': true,
                'Order': true,
                'StockExcess': true,
                'ReceivingHistory': true,
                'Finalize': true
            }
        } else {
            $scope.VendorOrderModel.displaySections = {
                'Info': false,
                'Order': false,
                'StockExcess': false,
                'ReceivingHistory': false,
                'Finalize': false
            }
        }
        $scope.VendorOrderModel.showSection = function(sectionName) {
            if (!$rootScope.GroupOnlyPermissions['Vendor order']['view']) {
                return;
            }
            $scope.VendorOrderModel.displaySections[sectionName] = !$scope.VendorOrderModel.displaySections[sectionName];
        }
        $scope.VendorOrderModel.activeSidepanelink = '#InfoSection';
        $scope.VendorOrderModel.selectedItem = 'Info';
        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function() {
            $scope.VendorOrderModel.onScroll();
        });
        $scope.VendorOrderModel.scrollToPanel = function(event, sectionToscroll) {
            if (event != null) {
                event.preventDefault();
            }
            angular.element(document).off("scroll");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 45;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = 0;
            }
            var target = angular.element("#" + sectionToscroll);
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VendorOrderModel.onScroll();
                });
                $scope.VendorOrderModel.onScroll();
            });
        }
        $scope.VendorOrderModel.sidepanelLink = function(event, relatedContent) {
            event.preventDefault();
            if ($rootScope.GroupOnlyPermissions['Vendor order']['view']) {
                $scope.VendorOrderModel.displaySections[relatedContent] = true;
            }
            angular.element(document).off("scroll");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = -25;
            }
            var target = angular.element(event.target.closest('a')).attr("href");
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.VendorOrderModel.onScroll();
                });
                $scope.VendorOrderModel.onScroll();
            });
        }
        
        
      //This is the code for ng-droplet
        $scope.FileUpload = {};
        /**
         * @property interface
         * @type {Object}
         */
        $scope.FileUpload.interface = {};
        /**
         * @property uploadCount
         * @type {Number}
         */
        $scope.FileUpload.uploadCount = 0;
        /**
         * @property success
         * @type {Boolean}
         */
        $scope.FileUpload.success = false;
        /**
         * @property error
         * @type {Boolean}
         */
        $scope.FileUpload.error = false;
        var allowedExtensions = [];
        var allowedFileTypesType;
        var maxStringSize;
        var maxFileSize;
        var maxFileSizeText;
        var chunkSize;

        $scope.$on('$dropletReady', function whenDropletReady() {
             $('.browse_but input').attr('title', ' ');
             try {
             	var el = angular.element("droplet.part-smart-droplet input[type=file]");
                 el.attr('accept', '.csv');
             } catch (ex) {}
       });

        $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
         $scope.FileUpload.fileToBeUploaded = singlefile.file;
         $scope.FileUpload.fileExtension = getExtension($scope.FileUpload.fileToBeUploaded);
            var fileType = $scope.FileUpload.fileToBeUploaded.type;
            if(allowedExtensions.indexOf($scope.FileUpload.fileExtension) != -1 && (allowedFileTypesType ? allowedFileTypesType.test(fileType) : true)) {
            	$scope.VendorOrderModel.isLoading = true;
            	uploadFile($scope.FileUpload.fileToBeUploaded);
            } else {
               Notification.error($translate.instant('Please_select_a_valid_file'));
            }
        });
        
        $scope.VendorOrderModel.setPartSmartFileReadData = function() {
	        allowedExtensions = ['txt', 'csv'];
	        maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
	        maxFileSize = 750000; //After Base64 Encoding, this is the max file size (750 KB max)
	        maxFileSizeText = $translate.instant('750_KB');
	        chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
        }
        
        function uploadFile(file) {
            if (file != undefined) {
                if (file.size <= maxFileSize) {
                    $scope.FileUpload.attachmentName = file.name;
                    var fileReader = new FileReader();
                    fileReader.onload = function (e) {};
                    fileReader.onloadend = function(e) {
                 	var fileFormat = $scope.FileUpload.fileExtension ? $scope.FileUpload.fileExtension : file.type;
            		if(!file.type || file.type == "") {
            			fileFormat = (($scope.FileUpload.attachmentName.toLowerCase()).includes("csv")) ? 'text/csv' : 
            					((($scope.FileUpload.attachmentName.toLowerCase()).includes("plain")) ? 'text/plain' : fileFormat);
            		}
             		$scope.VendorOrderModel.isLoading = false;
             		$scope.VendorOrderModel.showPartSmartImportedContent(this.result, fileFormat);
                 		
                    }
                    fileReader.onerror = function(e) {
                    	$scope.VendorOrderModel.isLoading = false;
                    }
                    fileReader.onabort = function(e) {
                    	$scope.VendorOrderModel.isLoading = false;
                    }
                    fileReader.readAsBinaryString(file); //Read the body of the file
                } else {
                	$scope.VendorOrderModel.isLoading = false;
                  $translate('File_size_should_be_less_than_parameterized_size',{ maxFileSize : maxFileSizeText}).then(function(success) {
                    Notification.error(success);
                  }, function(error) {
                    Notification.error($translate.instant('File_size_should_be_less_than_max_size'));
                  });
                }
            } else {
            	$scope.VendorOrderModel.isLoading = false;
            }
        }
        
        $scope.VendorOrderModel.onScroll = function() {
            if ($state.current.name === 'VendorOrder') {
                var activeSidepanelink;
                var selectedItem;
                var heading = '';
                var scrollPos = angular.element(document).scrollTop();
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 45;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 35;
                }
                if ((isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + 95 - navBarHeightDiffrenceFixedHeaderOpen)) || ($scope.VendorOrderModel.VendorOrderHeader.VendorId == null) || ($scope.VendorOrderModel.VendorOrderHeader.VendorId == '')) {
                    activeSidepanelink = '#InfoSection';
                    selectedItem = 'Info';
                } else if (isElementDefined('#OrderSection') && (scrollPos < angular.element('#OrderSection').position().top + angular.element('#OrderSection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) //50
                {
                    activeSidepanelink = '#OrderSection';
                    selectedItem = 'Order';
                } else if (isElementDefined('#StockExcessSection') && (scrollPos < angular.element('#StockExcessSection').position().top + angular.element('#StockExcessSection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) //50
                {
                    if ($scope.VendorOrderModel.StockExcessList != undefined && $scope.VendorOrderModel.StockExcessList.length != 0) {
                        activeSidepanelink = '#StockExcessSection';
                        selectedItem = 'StockExcess';
                    } else {
                        if ($scope.VendorOrderModel.VRHistoryList != undefined && $scope.VendorOrderModel.VRHistoryList.length != 0) {
                            activeSidepanelink = '#ReceivingHistorySection';
                            selectedItem = 'ReceivingHistory';
                        } else if ($scope.VendorOrderModel.EnableFinaliseOrder() == true) {
                            activeSidepanelink = '#FinalizeSection';
                            selectedItem = 'Finalize';
                        } else {
                            activeSidepanelink = '#OrderSection';
                            selectedItem = 'Order';
                        }
                    }
                } else if (isElementDefined('#ReceivingHistorySection') && (scrollPos < angular.element('#ReceivingHistorySection').position().top + angular.element('#ReceivingHistorySection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) //70
                {
                    if ($scope.VendorOrderModel.VRHistoryList != undefined && $scope.VendorOrderModel.VRHistoryList.length != 0) {
                        activeSidepanelink = '#ReceivingHistorySection';
                        selectedItem = 'ReceivingHistory';
                    } else if ($scope.VendorOrderModel.EnableFinaliseOrder() == true) {
                        activeSidepanelink = '#FinalizeSection';
                        selectedItem = 'Finalize';
                    } else {
                        activeSidepanelink = '#StockExcessSection';
                        selectedItem = 'StockExcess';
                    }
                } else if (isElementDefined('#FinalizeSection') && (scrollPos < angular.element('#FinalizeSection').position().top + angular.element('#FinalizeSection').height() + 65 - navBarHeightDiffrenceFixedHeaderOpen)) //50
                {
                    if ($scope.VendorOrderModel.EnableFinaliseOrder() == true) {
                        activeSidepanelink = '#FinalizeSection';
                        selectedItem = 'Finalize';
                    } else {
                        activeSidepanelink = '#ReceivingHistorySection';
                        selectedItem = 'ReceivingHistory';
                    }
                } else {
                    activeSidepanelink = '#FinalizeSection';
                    selectedItem = 'Finalize';
                }
                $scope.VendorOrderModel.activeSidepanelink = activeSidepanelink;
                $scope.VendorOrderModel.selectedItem = selectedItem;
                if (!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }
        $scope.VendorOrderModel.dropDownItem = function(event, selectedSection) {
            var activeSection = $scope.VendorOrderModel.activeSidepanelink.replace('#', '');
            $scope.VendorOrderModel.selectedItem = selectedSection;
            if (activeSection != selectedSection) {
                $scope.VendorOrderModel.sidepanelLink(event, selectedSection);
            }
        }
        var sortOrderMap = {
            "ASC": "DESC",
            "DESC": ""
        };
        $scope.VendorOrderModel.itemsPageSortAttrsJSON = {};
        $scope.VendorOrderModel.customersPageSortAttrsJSON = {};
        $scope.VendorOrderModel.stocksPageSortAttrsJSON = {};
        
        /* Method to set default page 
         * sort attributes JSON */
        $scope.VendorOrderModel.setDefaultPageSortAttrs = function() {
            $scope.VendorOrderModel.itemsPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "ItemDesc",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VendorOrderModel.itemsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
            $scope.VendorOrderModel.customersPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Item",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VendorOrderModel.customersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
            $scope.VendorOrderModel.stocksPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "Item",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.VendorOrderModel.stocksPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
        }
        $scope.VendorOrderModel.refreshVendorOrder = function() {
            $scope.VendorOrderModel.isrefresh = true;
            $scope.VendorOrderModel.loadVendor();
        }
        $scope.VendorOrderModel.calculateSidebarHeight = function() {
            var leftPanelLinks = angular.element(window).height() - (angular.element(".headerNav").height() + angular.element(".orderNumber").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + angular.element(".ownerInfo").height() + angular.element(".sideBarTotals").height() + 65); //85
            angular.element(".leftPanelLinks").css("height", leftPanelLinks);
        }
        $scope.VendorOrderModel.loadVendor = function() {
            $scope.VendorOrderModel.VendorOrderHeader.disableFinalizeOrderBtn = false; 
            $scope.VendorOrderModel.voHeaderId = $stateParams.Id ? $stateParams.Id : null;
            $scope.VendorOrderModel.setDefaultPageSortAttrs();
            $scope.SearchToAddCallback = $scope.VendorOrderModel.searchToAddCallback;
            if ($scope.VendorOrderModel.VendorOrderHeader.VendorId == null || $scope.VendorOrderModel.VendorOrderHeader.VendorId == '') {
                $scope.VendorOrderModel.populateLeftSideHeadingLables();
            }
            $scope.VendorOrderModel.loadAllGridDetails();
            $scope.VendorOrderModel.searchDivActive = false;
            $scope.VendorOrderModel.hideTimer = null;
            $scope.VendorOrderModel.pause = 500;
            setTimeout(function() {
                $scope.VendorOrderModel.calculateSidebarHeight();
            }, 10);
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 2000);
        }
        $scope.VendorOrderModel.hidePanel = function(event, id) {
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
        $scope.VendorOrderModel.loadAllGridDetails = function() {
            if ($scope.VendorOrderModel.voHeaderId != null) {
                var RequiredType = null;
                vendorOrderService.getVOLineItem($scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON, RequiredType).then(function(successfulResult) {
                    $scope.VendorOrderModel.populatePageModels(successfulResult);
                    $scope.VendorOrderModel.isrefresh = false;
                    $scope.VendorOrderModel.adjustSectionScroll();
                    $scope.VendorOrderModel.requiredForStockItems_selected = [];
                    $scope.VendorOrderModel.requiredForCustomerItems_selected = [];
                    $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 0;
                    $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 0;
                    for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length; i++) {
                        $scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isSelected = false;
                    }
                    for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length; i++) {
                        $scope.VendorOrderModel.requiredForStockItems_editRow[i].isSelected = false;
                    }
                    vendorOrderService.getVendorDetails($scope.VendorOrderModel.VendorOrderHeader.VendorId).then(function(successResults){
                    	$scope.VendorOrderModel.VendorInfo = successResults;
                    },function(error){
                    	
                    });
                });
            }
        }
        // Add Vendor callback method
        $scope.VendorOrderModel.addVendor = function(selectedVendorId) {
            $scope.VendorOrderModel.setDefaultPageSortAttrs();
            vendorOrderService.addVendor(selectedVendorId, $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VendorOrderModel.populatePageModels(successfulResult);
            });
        }
        $scope.VendorOrderModel.populateLeftSideHeadingLables = function() {
            $scope.VendorOrderModel.LeftSideHeadingLables = {};
            var currentHeadingSequenceIndex = 65;
            $scope.VendorOrderModel.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
            $scope.VendorOrderModel.LeftSideHeadingLables['Order'] = String.fromCharCode(currentHeadingSequenceIndex++);
            if ($scope.VendorOrderModel.StockExcessList != undefined && $scope.VendorOrderModel.StockExcessList.length != 0) {
                $scope.VendorOrderModel.LeftSideHeadingLables['Stock_Excess'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
            if ($scope.VendorOrderModel.VRHistoryList != undefined && $scope.VendorOrderModel.VRHistoryList.length != 0) {
                $scope.VendorOrderModel.LeftSideHeadingLables['Receiving_History'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
            if ($scope.VendorOrderModel.EnableFinaliseOrder() == true) {
                $scope.VendorOrderModel.LeftSideHeadingLables['Finalize'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
            $scope.VendorOrderModel.LeftSideHeadingLables['Received'] = String.fromCharCode(currentHeadingSequenceIndex++);;
            $scope.VendorOrderModel.LeftSideHeadingLables['R_Items'] = 1
            $scope.VendorOrderModel.LeftSideHeadingLables['R_Outstanding'] = 2
            if ($scope.VORModel.VOR_Header.Status == "In Progress") {
                $scope.VendorOrderModel.LeftSideHeadingLables['Finalize'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
            if ($scope.VORModel.VOR_Header.Status == "Invoiced" || $scope.VORModel.VOR_Header.Status == "Stocked") {
                $scope.VORModel.LeftSideHeadingLables['Invoice_History'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
        }
        $scope.VendorOrderModel.populatePageModels = function(newResult) {
            $scope.VendorOrderModel.OrderTypes = newResult.OrderTypes;
            if ($scope.VendorOrderModel.voHeaderId == null || $scope.VendorOrderModel.voHeaderId == 'undefined') {
                var url = '?id=' + newResult.VendorOrderHeader.Id;
                window.history.pushState("string", "Title", url);
            }
            $scope.VendorOrderModel.voHeaderId = newResult.VendorOrderHeader.Id;
            $scope.VendorOrderModel.GroupTotalCost = newResult.GroupTotalCost;
            $scope.VendorOrderModel.TotalReceivedCost = newResult.TotalReceivedCost;
            $scope.VendorOrderModel.TotalUnreceivedCost = newResult.TotalUnreceivedCost;
            $scope.VendorOrderModel.TotalLineItemGroups = newResult.TotalLineItemGroups;
            $scope.VendorOrderModel.vendorOrderLineItemGroupList = newResult.VendorOrderLineItemGroupList;
            $scope.VendorOrderModel.populateGroupItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemGroupList);
            $scope.VendorOrderModel.TotalRequiredForCustomers = newResult.TotalRequiredForCustomers;
            $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = newResult.VOLineItemRequiredForCustomer;
            $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList);
            $scope.VendorOrderModel.TotalRequiredForStocks = newResult.TotalRequiredForStocks;
            $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = newResult.VOLineItemRequiredForStock;
            $scope.VendorOrderModel.populateReqForStockItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByStockList);
            $scope.VendorOrderModel.VendorOrderHeader = newResult.VendorOrderHeader;
            for (var i = 0; i < newResult.OrderTypes.length; i++) {
                if (newResult.OrderTypes[i].Id == $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id) {
                    $scope.VendorOrderModel.VendorOrderHeader.OrderType = newResult.OrderTypes[i];
                }
                if ($scope.VendorOrderModel.VendorOrderHeader.OrderType.Id == null || $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id == undefined) {
                    if (newResult.OrderTypes[i].IsDefault) {
                        $scope.VendorOrderModel.VendorOrderHeader.OrderType = newResult.OrderTypes[i];
                    }
                }
            }
            $scope.FilterID = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            $scope.VendorOrderModel.StockExcessList = newResult.StockExcessList;
            $scope.VendorOrderModel.VRHistoryList = newResult.VRHistoryList;
            if ($scope.VendorOrderModel.vendorOrderLineItemGroupList.length == 0) {
                $scope.SearchableObjects = 'Vendor,Part__c';
            } else {
                if ($scope.VendorOrderModel.VendorOrderHeader.VendorId == null || $scope.VendorOrderModel.VendorOrderHeader.VendorId == '') {
                    $scope.SearchableObjects = 'Vendor';
                } else {
                    $scope.SearchableObjects = 'Part__c';
                }
            }
            $scope.VendorOrderModel.populateLeftSideHeadingLables();
        }
        $scope.VendorOrderModel.PopulateOnDemandAddSearched = function(Result) {
            $scope.VendorOrderModel.TotalLineItemGroups = Result.TotalLineItemGroups;
            $scope.VendorOrderModel.vendorOrderLineItemGroupList = Result.VendorOrderLineItemGroupList;
            $scope.VendorOrderModel.groupItems_editRow = [];
            $scope.VendorOrderModel.groupItemsForCancel_editRow = [];
            var IdToEdit = Result.NewLineItemId;
            var vendorGroupItems = $scope.VendorOrderModel.vendorOrderLineItemGroupList;
            for (var i = 0; i < vendorGroupItems.length; i++) {
                voLineItems = vendorGroupItems[i].VendorOrderLineItemList;
                voLineItems_editRow = [];
                var EditableGroupId = 0;
                for (var j = 0; j < voLineItems.length; j++) {
                    if (voLineItems[j].Id == IdToEdit) {
                        voLineItems_editRow.push({
                            isEdit: true,
                            radioValue: 1,
                            optionSelected: 0
                        });
                        EditableGroupId = 1;
                    } else {
                        voLineItems_editRow.push({
                            isEdit: false,
                            radioValue: 1,
                            optionSelected: 0
                        });
                    }
                }
                if (EditableGroupId == 1) {
                    $scope.VendorOrderModel.groupItems_editRow.push({
                        isEdit: true,
                        radioValue: 1,
                        optionSelected: 0,
                        voLineItems_editRow: voLineItems_editRow
                    });
                    EditableGroupId = 0;
                    $scope.VendorOrderModel.groupItemsForCancel_editRow.push({
                        isEdit: true,
                        radioValue: 1,
                        optionSelected: 0,
                        voLineItems_editRow: voLineItems_editRow
                    });
                } else {
                    $scope.VendorOrderModel.groupItems_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0,
                        voLineItems_editRow: voLineItems_editRow
                    });
                    $scope.VendorOrderModel.groupItemsForCancel_editRow.push({
                        isEdit: true,
                        radioValue: 0,
                        optionSelected: 0,
                        voLineItems_editRow: voLineItems_editRow
                    });
                }
            }
            $scope.VendorOrderModel.TotalLineItemGroups = Result.TotalLineItemGroups;
            $scope.VendorOrderModel.TotalRequiredForCustomers = Result.TotalRequiredForCustomers;
            $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = Result.VOLineItemRequiredForCustomer;
            $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList);
            $scope.VendorOrderModel.TotalRequiredForStocks = Result.TotalRequiredForStocks;
            $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = Result.VOLineItemRequiredForStock;
            $scope.VendorOrderModel.populateReqForStockItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByStockList);
            $scope.VendorOrderModel.StockExcessList = Result.StockExcessList;
            $scope.VendorOrderModel.VendorOrderHeader = Result.VendorOrderHeader;
            $scope.VendorOrderModel.OrderTypes = Result.OrderTypes;
            for (var i = 0; i < Result.OrderTypes.length; i++) {
                if (Result.OrderTypes[i].Id == $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id) {
                    $scope.VendorOrderModel.VendorOrderHeader.OrderType = Result.OrderTypes[i];
                }
            }
            $scope.FilterID = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            if ($scope.VendorOrderModel.VendorOrderHeader.VendorId == null || $scope.VendorOrderModel.VendorOrderHeader.VendorId == '') {
                $scope.SearchableObjects = 'Vendor';
            } else {
                $scope.SearchableObjects = 'Part__c';
            }
            $scope.VendorOrderModel.populateLeftSideHeadingLables();
        }
        $scope.VendorOrderModel.populateGroupItemsEditableModel = function(vendorGroupItems) {
            $scope.VendorOrderModel.groupItems_editRow = [];
            $scope.VendorOrderModel.groupItemsForCancel_editRow = [];
            for (var i = 0; i < vendorGroupItems.length; i++) {
                voLineItems = vendorGroupItems[i].VendorOrderLineItemList;
                voLineItems_editRow = [];
                for (var j = 0; j < voLineItems.length; j++) {
                    voLineItems_editRow.push({
                        isEdit: false,
                        radioValue: 1,
                        optionSelected: 0
                    });
                }
                $scope.VendorOrderModel.groupItems_editRow.push({
                    isEdit: false,
                    radioValue: 1,
                    optionSelected: 0,
                    voLineItems_editRow: voLineItems_editRow
                });
                $scope.VendorOrderModel.groupItemsForCancel_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0,
                    voLineItems_editRow: voLineItems_editRow
                });
            }
        }
        //Function To open & close edit Mode only work for parent rows On Click Group Row Edit & Expand Row Method
        $scope.VendorOrderModel.editGroupItem = function(event, index) {
            if ($rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                var isEditModeEnabled = false;
                var lineitem = [];
                if (event.target.id == "VO_Group_block_grid_container_expend_tbody_tr_td_3_" + index) {
                    return;
                }
                for (var i = 0; i < $scope.VendorOrderModel.groupItems_editRow[index].voLineItems_editRow.length; i++) {
                    if ($scope.VendorOrderModel.groupItems_editRow[index].voLineItems_editRow[i].isEdit == true) {
                        $scope.VendorOrderModel.groupItems_editRow[index].voLineItems_editRow[i].isEdit = false;
                    }
                }
                for (i = 0; i < $scope.VendorOrderModel.groupItems_editRow.length; i++) {
                    if ($scope.VendorOrderModel.groupItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.VendorOrderModel.groupItems_editRow[i].isEdit = false;
                    $scope.VendorOrderModel.groupItems_editRow[index].showActionBlock = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VendorOrderModel.groupItems_editRow[index].isEdit = true;
                    $scope.VendorOrderModel.groupItems_editRow[index].showActionBlock = true;
                } else {
                    var RequiredType = null;
                    vendorOrderService.getVOLineItem($scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON, RequiredType).then(function(successfulResult) {
                        $scope.VendorOrderModel.populatePageModels(successfulResult);
                    });
                }
                if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[index].VendorOrderLineItemList.length == 1) {
                    setTimeout(function() {
                        angular.element("#VO_Group_block_grid_container_expend_tbody_tr_td_3_" + index).focus();
                    }, 10);
                }
            } else {
                $scope.VendorOrderModel.groupItems_editRow[index].isEdit = false;
            }
        }
        $scope.VendorOrderModel.editGroupItemForCancel = function(event, index) {
            if ($rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                var isEditModeEnabled = false;
                var lineitem = [];
                for (i = 0; i < $scope.VendorOrderModel.groupItemsForCancel_editRow.length; i++) {
                    if ($scope.VendorOrderModel.groupItemsForCancel_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.VendorOrderModel.groupItemsForCancel_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VendorOrderModel.groupItemsForCancel_editRow[index].isEdit = true;
                }
            } else {
                $scope.VendorOrderModel.groupItemsForCancel_editRow[index].isEdit = false;
            }
        }
        $scope.VendorOrderModel.editvoLineItem = function(event, parentindex, index) {
            var isEditModeEnabled = false;
            var lineitem = [];
            var partId = null;
            var voLineItem = null;
            var qtyRequired = null;
            if ($scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow[index].isEdit == true) {} else {
                for (i = 0; i < $scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow.length; i++) {
                    if ($scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit == true) {
                        $scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit
                        isEditModeEnabled = true;
                        var partId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[i].PartId;
                        var voLineItem = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[i].Id;
                        var qtyRequired = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[i].Need;
                    }
                    $scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow[i].isEdit = false;
                    setTimeout(function() {
                        angular.element('#Location_' + parentindex + '_' + index).focus();
                    }, 10);
                }
            }
            if (!isEditModeEnabled) {
                if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].IsExcess == false) {
                    $scope.VendorOrderModel.groupItems_editRow[parentindex].voLineItems_editRow[index].isEdit = true;
                    $scope.VendorOrderModel.groupItems_editRow[parentindex].showActionBlock = false;
                }
            } else {
                if (partId != null && voLineItem != null && qtyRequired != null) {
                    if ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked') {
                        $scope.VendorOrderModel.saveVolineItems(partId, voLineItem, qtyRequired, parentindex);
                    }
                }
            }
        }
        $scope.VendorOrderModel.isAddSelectedVisible = function() {
            var isVisible = false;
            if (($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked') && ($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length > 0 || $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length > 0)) {
                isVisible = true;
            }
            return isVisible;
        }
        $scope.VendorOrderModel.editRowTabOut = function(event, parentindex, index) {
            if (!event.shiftKey && event.keyCode == 9) {
                var partId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].PartId;
                var voLineItem = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].Id;
                var qtyRequired = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].Need;
                $scope.VendorOrderModel.saveVolineItems(partId, voLineItem, qtyRequired, parentindex)
                setTimeout(function() {
                    angular.element('#SearchToaddCutomer').focus();
                }, 10);
            }
        }
        $scope.VendorOrderModel.editRowTabOutForVOG = function(event, parentindex, index) {
            if (!event.shiftKey && event.keyCode == 9) {
                var partId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].PartId;
                var voLineItem = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList[index].Id;
                var qtyRequired = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].Need;
                $scope.VendorOrderModel.saveVolineItems(partId, voLineItem, qtyRequired, parentindex)
                setTimeout(function() {
                    angular.element('#SearchToaddCutomer').focus();
                }, 10);
            }
        }
        $scope.VendorOrderModel.saveVolineItems = function(partId, voLineItem, qtyRequired, parentindex) {
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            var voHeaderId = $scope.VendorOrderModel.voHeaderId;
            var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
            var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
            var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
            var IsSearched = false;
            if (qtyRequired == '') {
                qtyRequired = 1;
            }
            vendorOrderService.addSearchedRecord(partId, vendorId, voHeaderId, qtyRequired, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, voLineItem, IsSearched).then(function(resultInfo) {
                $scope.VendorOrderModel.populateGroupOnly(parentindex, resultInfo);
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.populateGroupOnly = function(parentindex, resultInfo) {
            if (resultInfo.RecentlyEditedGroupList.length > 0) {
                $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex] = resultInfo.RecentlyEditedGroupList[0];
                var voLineItems = [];
                var voLineItems = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentindex].VendorOrderLineItemList;
                var voLineItems_editRow = [];
                for (var j = 0; j < voLineItems.length; j++) {
                    voLineItems_editRow.push({
                        isEdit: false,
                        radioValue: 1,
                        optionSelected: 0
                    });
                }
                var groupItems_editRow = {
                    isEdit: false,
                    showActionBlock: false,
                    radioValue: 1,
                    optionSelected: 0,
                    voLineItems_editRow: voLineItems_editRow
                };
                $scope.VendorOrderModel.groupItems_editRow[parentindex] = groupItems_editRow;
                $scope.VendorOrderModel.TotalLineItemGroups = resultInfo.TotalLineItemGroups;
                $scope.VendorOrderModel.TotalRequiredForCustomers = resultInfo.TotalRequiredForCustomers;
                $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = resultInfo.VOLineItemRequiredForCustomer;
                $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList);
                $scope.VendorOrderModel.GroupTotalCost = resultInfo.GroupTotalCost;
                $scope.VendorOrderModel.TotalReceivedCost = resultInfo.TotalReceivedCost;
                $scope.VendorOrderModel.TotalUnreceivedCost = resultInfo.TotalUnreceivedCost;
                $scope.VendorOrderModel.TotalRequiredForStocks = resultInfo.TotalRequiredForStocks;
                $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = resultInfo.VOLineItemRequiredForStock;
                $scope.VendorOrderModel.populateReqForStockItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByStockList);
                $scope.VendorOrderModel.StockExcessList = resultInfo.StockExcessList;
                $scope.VendorOrderModel.VendorOrderHeader = resultInfo.VendorOrderHeader;
                $scope.VendorOrderModel.OrderTypes = resultInfo.OrderTypes;
                for (var i = 0; i < resultInfo.OrderTypes.length; i++) {
                    if (resultInfo.OrderTypes[i].Id == $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id) {
                        $scope.VendorOrderModel.VendorOrderHeader.OrderType = resultInfo.OrderTypes[i];
                    }
                }
                $scope.VendorOrderModel.populateLeftSideHeadingLables();
                $scope.FilterID = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
                if ($scope.VendorOrderModel.VendorOrderHeader.VendorId == null || $scope.VendorOrderModel.VendorOrderHeader.VendorId == '') {
                    $scope.SearchableObjects = 'Vendor';
                } else {
                    $scope.SearchableObjects = 'Part__c';
                }
            } else {
                $scope.VendorOrderModel.populatePageModels(resultInfo);
            }
        }
        $scope.VendorOrderModel.isEditModeForVOLIGroupItems = function(index) {
            if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[index].VendorOrderLineItemList.length == 1 && ($scope.VendorOrderModel.groupItems_editRow[index].showActionBlock || $scope.VendorOrderModel.groupItems_editRow[index].isEdit) && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[index].VendorOrderLineItemList[0].IsExcess && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[index].VendorOrderLineItemList[0].IsRequiredForCustomer && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[index].VendorOrderLineItemList[0].IsService && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Open')) {
                return true;
            } else {
                return false;
            }
        }
        $scope.VendorOrderModel.isEditModeForVOLIGroupLineItems = function(parentIndex, index) {
            if ($scope.VendorOrderModel.groupItems_editRow[parentIndex].voLineItems_editRow[index].isEdit && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList[index].IsRequiredForCustomer && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList[index].IsExcess && !$scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList[index].IsService && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Open') && $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList.length > 1) {
                return true;
            } else {
                return false;
            }
        }
        $scope.VendorOrderModel.itemsPageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VendorOrderModel.itemsPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VendorOrderModel.itemsPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage = 1;
            $scope.VendorOrderModel.Items_paginationControlsAction();
        }
        $scope.VendorOrderModel.Items_paginationControlsAction = function() {
            vendorOrderService.getPaginatedItemsForVOHeader('Items', $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON).then(function(resultInfo) {
                $scope.VendorOrderModel.TotalLineItemGroups = resultInfo.TotalLineItemGroups;
                $scope.VendorOrderModel.vendorOrderLineItemGroupList = resultInfo.VendorOrderLineItemGroupList;
                $scope.VendorOrderModel.populateGroupItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemGroupList);
                setTimeout(function() {
                    $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                }, 10);
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.groupAllSimilarVOLineItem = function(partId) {
            vendorOrderService.groupAllSimilarVOLineItem($scope.VendorOrderModel.VendorOrderHeader.VendorId, partId, $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON
            ).then(function(resultInfo) {
                $scope.VendorOrderModel.populatePageModels(resultInfo);
                setTimeout(function() {
                    $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                    $scope.VendorOrderModel.customersPageSortAttrsJSON.ChangesCount++;
                    $scope.VendorOrderModel.stocksPageSortAttrsJSON.ChangesCount++;
                }, 100);
                setTimeout(function() {
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }, 1000);
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.selectCheckbox = function(index) {
            if ($scope.VendorOrderModel.groupItemsForCancel_editRow[index].radioValue == 1) {
                $scope.VendorOrderModel.groupItemsForCancel_editRow[index].radioValue = 0;
            } else {
                $scope.VendorOrderModel.groupItemsForCancel_editRow[index].radioValue = 1;
            }
        }
        $scope.VendorOrderModel.groupItemsGoActionCancel = function(index) {
            var selectedRadioValue = 1;
            selectedRadioValue = $scope.VendorOrderModel.groupItems_editRow[index].radioValue;
            var voHeaderId = $scope.VendorOrderModel.VendorOrderHeader.Id;
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId
            var voLineItemGroupId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[index].Id;
            vendorOrderService.cancelOrderOfItem(voLineItemGroupId, vendorId, voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON).then(function(resultInfo) {
                $scope.VendorOrderModel.populatePageModels(resultInfo);
                setTimeout(function() {
                    $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                    $scope.VendorOrderModel.customersPageSortAttrsJSON.ChangesCount++;
                    $scope.VendorOrderModel.stocksPageSortAttrsJSON.ChangesCount++;
                }, 100);
                setTimeout(function() {
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }, 1000);
            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
                $scope.VendorOrderModel.loadAllGridDetails();
            });
        }
        $scope.VendorOrderModel.groupItemsGoAction = function(index, parentGirdIndex) {
            var selectedRadioValue = 1;
            if (parentGirdIndex == null) {
                selectedRadioValue = $scope.VendorOrderModel.groupItems_editRow[index].radioValue;
            } else {
                selectedRadioValue = $scope.VendorOrderModel.groupItems_editRow[parentGirdIndex].voLineItems_editRow[index].radioValue;
            }
            if (selectedRadioValue == 1) {
                var partId = (parentGirdIndex == null) ? $scope.VendorOrderModel.vendorOrderLineItemGroupList[index].PartId : $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentGirdIndex].VendorOrderLineItemList[index].PartId;
                $scope.VendorOrderModel.groupAllSimilarVOLineItem(partId);
            } else if (selectedRadioValue == 2) {
                if (parentGirdIndex == null) {
                    var voLineItemGroupId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[index].Id;
                    var itemsGridNewPN = $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage;
                    if ($scope.VendorOrderModel.TotalLineItemGroups % $scope.VendorOrderModel.itemsPageSortAttrsJSON.PageSize == 1) {
                        $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                    }
                    vendorOrderService.removeGroupFromOrder(voLineItemGroupId, $scope.VendorOrderModel.VendorOrderHeader.VendorId, $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON
                    ).then(function(resultInfo) {
                        $scope.VendorOrderModel.populatePageModels(resultInfo);
                        setTimeout(function() {
                            $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                            $scope.VendorOrderModel.customersPageSortAttrsJSON.ChangesCount++;
                            $scope.VendorOrderModel.stocksPageSortAttrsJSON.ChangesCount++;
                            for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length; i++) {
                                var idToSelect = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[i].Id;
                                for (var j = 0; j < $scope.VendorOrderModel.requiredForCustomerItems_selected.length; j++) {
                                    if ($scope.VendorOrderModel.requiredForCustomerItems_selected[j] == idToSelect) {
                                        $scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isEdit = true;
                                        break;
                                    }
                                }
                            }
                            for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length; i++) {
                                var idToSelect = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[i].Id;
                                for (var j = 0; j < $scope.VendorOrderModel.requiredForStockItems_selected.length; j++) {
                                    if ($scope.VendorOrderModel.requiredForStockItems_selected[j] == idToSelect) {
                                        $scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit = true;
                                        break;
                                    }
                                }
                            }
                        }, 100);
                        setTimeout(function() {
                            if (!$scope.$$phase) {
                                $scope.$digest();
                            }
                        }, 1000);
                    }, function(errorSearchResult) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                    });
                } else {
                    var voLineItemGroupId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentGirdIndex].Id;
                    var voLineItemId = $scope.VendorOrderModel.vendorOrderLineItemGroupList[parentGirdIndex].VendorOrderLineItemList[index].Id;
                    vendorOrderService.removeLineItemFromOrder(voLineItemId, voLineItemGroupId, $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.VendorOrderHeader.VendorId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON
                    ).then(function(resultInfo) {
                        $scope.VendorOrderModel.populateGroupOnly(parentGirdIndex, resultInfo);
                        setTimeout(function() {
                            $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                            $scope.VendorOrderModel.customersPageSortAttrsJSON.ChangesCount++;
                            $scope.VendorOrderModel.stocksPageSortAttrsJSON.ChangesCount++;
                        }, 10);
                    }, function(errorSearchResult) {
                        Notification.error($translate.instant('GENERIC_ERROR'));
                    });
                }
            }
        }
        $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel = function(requiredForCustomerItems) {
            $scope.VendorOrderModel.requiredForCustomerItems_editRow = [];
            for (var i = 0; i < requiredForCustomerItems.length; i++) {
                $scope.VendorOrderModel.requiredForCustomerItems_editRow.push({
                    isEdit: false,
                    radioValue: 1,
                    optionSelected: 0
                });
            }
        }
        $scope.VendorOrderModel.editRequiredForCustomerItem = function(event, index) {
            var isEditModeEnabled = false;
            var lineitem = [];
            for (i = 0; i < $scope.VendorOrderModel.requiredForCustomerItems_editRow.length; i++) {
                if ($scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isEdit == true) {
                    isEditModeEnabled = true;
                    $scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isEdit = false;
                }
            }
            if (!isEditModeEnabled) {
                $scope.VendorOrderModel.requiredForCustomerItems_editRow[index].isEdit = true;
            } else {
            }
        }
        $scope.VendorOrderModel.customersPageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VendorOrderModel.customersPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VendorOrderModel.customersPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = 1;
            $scope.VendorOrderModel.RequiredByCustomer_paginationControlsAction();
        }
        $scope.VendorOrderModel.RequiredByCustomer_paginationControlsAction = function() {
            vendorOrderService.getPaginatedItemsForVOHeader('Customers', $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.customersPageSortAttrsJSON).then(function(resultInfo) {
                $scope.VendorOrderModel.TotalRequiredForCustomers = resultInfo.TotalRequiredForCustomers;
                $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = resultInfo.VOLineItemRequiredForCustomer;
                $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList);
                for (var i = 0; i < $scope.VendorOrderModel.requiredForCustomerItems_selected.length; i++) {
                    for (var j = 0; j < $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length; j++) {
                        if ($scope.VendorOrderModel.requiredForCustomerItems_selected[i] == $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[j].Id) {
                            $scope.VendorOrderModel.requiredForCustomerItems_editRow[j].isEdit = true;
                        }
                    }
                }
                setTimeout(function() {
                    $scope.VendorOrderModel.customersPageSortAttrsJSON.ChangesCount++;
                }, 10);
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.requiredForCustomerItemsGoAction = function(index) {
            if ($scope.VendorOrderModel.requiredForCustomerItems_editRow[index].radioValue == 1) {
                $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage = 1;
                $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = 1;
                $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = 1;
                var partId = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].PartId;
                $scope.VendorOrderModel.groupAllSimilarVOLineItem(partId);
            } else if ($scope.VendorOrderModel.requiredForCustomerItems_editRow[index].radioValue == 2) {
                var partId = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].PartId;
                var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
                var voHeaderId = $scope.VendorOrderModel.voHeaderId;
                var qtyRequired = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].Need;
                var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
                var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
                var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
                var voLineItem = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].Id;
                var itemsGridNewPN = $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage;
                if ($scope.VendorOrderModel.TotalRequiredForCustomers % $scope.VendorOrderModel.customersPageSortAttrsJSON.PageSize == 1) {
                    $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                }
                var IsSearched = false;
                vendorOrderService.addSearchedRecord(partId, vendorId, voHeaderId, qtyRequired, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, voLineItem, IsSearched).then(function(resultInfo) {
                    $scope.VendorOrderModel.populatePageModels(resultInfo);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
        }
        $scope.VendorOrderModel.populateReqForStockItemsEditableModel = function(requiredForStockItems) {
            $scope.VendorOrderModel.requiredForStockItems_editRow = [];
            for (var i = 0; i < requiredForStockItems.length; i++) {
                $scope.VendorOrderModel.requiredForStockItems_editRow.push({
                    isEdit: false,
                    radioValue: 1,
                    optionSelected: 0
                });
            }
        }
        $scope.VendorOrderModel.editRequiredForStockItem = function(event, index) {
            var isEditModeEnabled = false;
            var lineitem = [];
            if ($scope.VendorOrderModel.VendorOrderHeader.Status == 'On Order') {
                return;
            }
            if ($scope.VendorOrderModel.requiredForStockItems_editRow[index].isEdit == true) {
                for (i = 0; i < $scope.VendorOrderModel.requiredForStockItems_editRow.length; i++) {
                    $scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit = false
                }
            } else {
                for (i = 0; i < $scope.VendorOrderModel.requiredForStockItems_editRow.length; i++) {
                    if ($scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.VendorOrderModel.requiredForStockItems_editRow[index].isEdit = true;
                }
            }
        }
        $scope.VendorOrderModel.stocksPageSortControlsAction = function() {
            var newSortOrder = sortOrderMap[$scope.VendorOrderModel.stocksPageSortAttrsJSON.Sorting[0].SortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.VendorOrderModel.stocksPageSortAttrsJSON.Sorting[0].SortDirection = newSortOrder;
            $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = 1;
            $scope.VendorOrderModel.RequiredByStock_paginationControlsAction();
        }
        $scope.VendorOrderModel.RequiredByStock_paginationControlsAction = function() {
            vendorOrderService.getPaginatedItemsForVOHeader('Stocks', $scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.stocksPageSortAttrsJSON).then(function(resultInfo) {
                $scope.VendorOrderModel.TotalRequiredForStocks = resultInfo.TotalRequiredForStocks;
                $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = resultInfo.VOLineItemRequiredForStock;
                $scope.VendorOrderModel.populateReqForStockItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByStockList);
                for (var i = 0; i < $scope.VendorOrderModel.requiredForStockItems_selected.length; i++) {
                    for (var j = 0; j < $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length; j++) {
                        if ($scope.VendorOrderModel.requiredForStockItems_selected[i] == $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[j].Id) {
                            $scope.VendorOrderModel.requiredForStockItems_editRow[j].isEdit = true;
                        }
                    }
                }
                setTimeout(function() {
                    $scope.VendorOrderModel.stocksPageSortAttrsJSON.ChangesCount++;
                }, 10);
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.solieditRowBlur = function(event, index, parentIndex) {
            if (event.keyCode == 9) {
                if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList[index].Need <= 0) {
                    Notification.error($translate.instant('NewVendorOrder_Please_enter_a_positive_quantity'));
                    event.stopPropagation();
                    setTimeout(function() {
                        angular.element(event.target).focus();
                    }, 100);
                }
            }
        }
        $scope.VendorOrderModel.requiredForStockItemsGoAction = function(index) {
            if ($scope.VendorOrderModel.requiredForStockItems_editRow[index].radioValue == 1) {
                $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage = 1;
                $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = 1;
                $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = 1;
                var partId = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].PartId;
                $scope.VendorOrderModel.groupAllSimilarVOLineItem(partId);
            } else if ($scope.VendorOrderModel.requiredForStockItems_editRow[index].radioValue == 2) {
                var partId = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].PartId;
                var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
                var voHeaderId = $scope.VendorOrderModel.voHeaderId;
                var qtyRequired = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].Need;
                var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
                var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
                var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
                var voLineItem = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].Id;
                var itemsGridNewPN = $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage;
                if ($scope.VendorOrderModel.TotalRequiredForStocks % $scope.VendorOrderModel.stocksPageSortAttrsJSON.PageSize == 1) {
                    $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                }
                var IsSearched = false
                vendorOrderService.addSearchedRecord(partId, vendorId, voHeaderId, qtyRequired, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, voLineItem, IsSearched).then(function(resultInfo) {
                    $scope.VendorOrderModel.populatePageModels(resultInfo);
                }, function(errorSearchResult) {
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
        }
        $scope.VendorOrderModel.searchToAddCallback = function(selectedRecord) {
            if ($scope.VendorOrderModel.VendorOrderHeader.Status != 'On Order') {
                if (selectedRecord.originalObject.Info == 'Merchandise') {
                    $scope.VendorOrderModel.addOneItemOnly(selectedRecord.originalObject, 1, null);
                } else if (selectedRecord.originalObject.Info == 'Vendor') {
                    var selectedRecordId = selectedRecord.originalObject.Value;
                    if (selectedRecordId.length == 18) {
                        selectedRecordId = selectedRecordId.substring(0, 15);
                    }
                    $scope.VendorOrderModel.addVendor(selectedRecordId);
                }
            } else {
                Notification.error($translate.instant('NewVendorOrder_You_cannot_add_items_to_a_submitted_vendor_order'));
            }
            $scope.VendorOrderModel.resetSearchBox();
        }
        $scope.VendorOrderModel.addOneItemOnly = function(originalObject, qtyRequired, voLineItem) {
            var partId = originalObject.Value;
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            var voHeaderId = $scope.VendorOrderModel.voHeaderId;
            $scope.VendorOrderModel.itemsPageSortAttrsJSON.Sorting[0]["FieldName"] = "LastModified";
            $scope.VendorOrderModel.itemsPageSortAttrsJSON.Sorting[0]["SortDirection"] = "";
            $scope.VendorOrderModel.itemsPageSortAttrsJSON.CurrentPage = 1;
            $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = 1;
            $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = 1;
            var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
            var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
            var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
            var IsSearched = true;
            vendorOrderService.addSearchedRecord(partId, vendorId, voHeaderId, qtyRequired, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON, voLineItem, IsSearched).then(function(resultInfo) {
                $scope.VendorOrderModel.PopulateOnDemandAddSearched(resultInfo);
                if (resultInfo.NewLineItemId != null) {
                    var parentIndex = -1;
                    var childIndex = -1;
                    for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemGroupList.length; i++) {
                        for (var j = 0; j < $scope.VendorOrderModel.vendorOrderLineItemGroupList[i].VendorOrderLineItemList.length; j++) {
                            if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[i].VendorOrderLineItemList[j].Id == resultInfo.NewLineItemId) {
                                parentIndex = i;
                                childIndex = j;
                            }
                        }
                    }
                    if (parentIndex != -1 && childIndex != -1) {
                        $scope.VendorOrderModel.groupItems_editRow[parentIndex].voLineItems_editRow[childIndex].isEdit = true;
                        if ($scope.VendorOrderModel.vendorOrderLineItemGroupList[parentIndex].VendorOrderLineItemList.length == 1) {
                            setTimeout(function() {
                                angular.element("#VO_Group_block_grid_container_expend_tbody_tr_td_3_" + parentIndex).focus();
                            }, 10);
                        } else {
                            setTimeout(function() {
                                angular.element("#VendorOrderItem_Grid tr.Editable_row:first div.secondchild").find('input').focus();
                            }, 10);
                        }
                    }
                }
                setTimeout(function() {
                    $scope.VendorOrderModel.itemsPageSortAttrsJSON.ChangesCount++;
                }, 1000);
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.groupAllVOLineItemByRequiredType = function(isRequiredForCustomer) {
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            var voHeaderId = $scope.VendorOrderModel.voHeaderId;
            var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
            var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
            var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
            vendorOrderService.groupAllVOLineItem(vendorId, voHeaderId, isRequiredForCustomer, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON).then(function(resultInfo) {
                $scope.VendorOrderModel.populatePageModels(resultInfo);
            }, function(errorSearchResult) {
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.updateVOHederOrderStatus = function(status) {
            if (status != null && (status == 'Open' || status == 'Locked' || status == 'On Order' || status == 'Partially Received' || status == 'Received' || status == 'Cancelled')) { /* Richa ||status == 'Cancelled' */
                $scope.VendorOrderModel.VendorOrderHeader.Status = status;
            }
            vendorOrderService.updateVOHederOrderType($scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id, $scope.VendorOrderModel.VendorOrderHeader.Status).then(function(resultInfo) {
                if (status == null) {
                    $scope.VendorOrderModel.loadAllGridDetails();
                }
                Notification.success($translate.instant('Generic_Saved'));
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.VendorOrderModel.selectalltext = function () {
            angular.element('#unitNotes').select();
        }
        
        $scope.VendorOrderModel.updateVONotes = function () {
            if ($scope.VendorOrderModel.VendorOrderHeader.Notes != undefined) {
            	vendorOrderService.updateVONotes($scope.VendorOrderModel.voHeaderId, $scope.VendorOrderModel.VendorOrderHeader.Notes)
                .then(function (successfulSearchResult) {
                    Notification.success($translate.instant('Generic_Saved'));
                },
                function (errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
        }
        
        $scope.VendorOrderModel.RelatedList_addAction = function(event, typeToSearch) {
            $scope.VendorOrderModel.setFocusToSearchBox(typeToSearch);
        }
        $scope.VendorOrderModel.setFocusToSearchBox = function(typeToSearch) {
            $scope.typeToSearch = typeToSearch;
            $scope.PreferredObject = typeToSearch;
            angular.element('#SearchToaddCutomer').focus();
        }
        $scope.VendorOrderModel.resetSearchBox = function() {
            $scope.typeToSearch = "";
            $scope.PreferredObject = "";
        }
        $scope.applyCssOnPartPopUp = function(event, className) {
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
        var timer;
        $scope.VendorOrderModel.openpartpopup = function(event, partId) {
            timer = $timeout(function() {
                $scope.$broadcast('PartPopUpEvent', partId);
                $scope.applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
            }, 1000);
        }
        $scope.VendorOrderModel.hidePartPopUp = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-Part-Popup').hide();
        }
        var timer2;
        $scope.VendorOrderModel.showNeededForPopUp = function(event, voGroupId, voHeaderId) {
            timer2 = $timeout(function() {
                $scope.applyCssOnPopUp(event, '.Vendor-Order-popup');
                vendorOrderService.getGroupRecDetail(voGroupId, voHeaderId).then(function(voGroupRecord) {
                    if (voGroupRecord.length > 0) {
                        $scope.VendorOrderModel.voGroupRecordDetail = voGroupRecord[0];
                    }
                }, function(errorSearchResult) {
                    $scope.VendorOrderModel.OverlayInfo = errorSearchResult;
                });
            }, 500);
        }
        $scope.VendorOrderModel.hideNeededForPopUp = function() {
            $timeout.cancel(timer2);
            angular.element('.Vendor-Order-popup').hide();
        }
        var timer1;
        $scope.VendorOrderModel.showCOPopUp = function(event, coHeaderId) {
            timer1 = $timeout(function() {
                $scope.applyCssOnPopUp(event, '.Vendor-Order-CODetail-Popup');
                vendorOrderService.getCOHeaderRec(coHeaderId).then(function(coHeaderRecord) {
                    if (coHeaderRecord.length > 0) {
                        $scope.VendorOrderModel.coHeaderInfoDetail = coHeaderRecord[0];
                    }
                }, function(errorSearchResult) {
                    $scope.CustomerOrder.OverlayInfo = errorSearchResult;
                });
            }, 500);
        }
        $scope.VendorOrderModel.hideCOPopUp = function() {
            $timeout.cancel(timer1);
            angular.element('.Vendor-Order-CODetail-Popup').hide();
        }
        var timer3;
        $scope.VendorOrderModel.showPopUpVendorOrderPartDetails = function(event, voli) {
            timer3 = $timeout(function() {
                $scope.applyCssOnPopUpRight(event, '.Vendor-Order-Needpopup');
                vendorOrderService.getStockRecDetail(voli).then(function(partRecord) {
                    $scope.VendorOrderModel.voliPartDetails = partRecord[0];
                }, function(errorSearchResult) {
                    $scope.VendorOrderModel.OverlayInfo = errorSearchResult;
                });
            }, 500);
        }
        $scope.VendorOrderModel.hidePopUpVendorOrderPartDetails = function() {
            $timeout.cancel(timer3);
            angular.element('.Vendor-Order-Needpopup').hide();
        }
        $scope.VendorOrderModel.getLocations = function() {
            if ($scope.VendorOrderModel.partInfoDetail != undefined && $scope.VendorOrderModel.partInfoDetail.Location != null) {
                return $scope.VendorOrderModel.partInfoDetail.Location.split(';');
            }
        }
        $scope.applyCssOnPopUp = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top - 45);
            angular.element(className).css('left', targetEle.offset().left + elementWidth + 10);
            angular.element(className).show();
            $scope.VendorOrderModel.LockVendorOrder = function() {
                $scope.VendorOrderModel.VendorOrderHeader.Status = 'Locked';
            }
        }
        $scope.applyCssOnPopUpRight = function(event, className) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element(className).css('top', targetEle.offset().top - 45);
            angular.element(className).css('left', targetEle.offset().left + elementWidth + 10);
            angular.element(className).show();
            $scope.VendorOrderModel.LockVendorOrder = function() {
                $scope.VendorOrderModel.VendorOrderHeader.Status = 'Locked';
            }
        }
        $scope.VendorOrderModel.showInfoOverlay = function(event, vendorId) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element('.Vendor-info-overlay').css('top', targetEle.offset().top - 45);
            angular.element('.Vendor-info-overlay').css('left', event.clientX);
            angular.element('.Vendor-info-overlay').show();
        }
        $scope.VendorOrderModel.showVendorInfoOverlay = function(event, vendorId) {
            $scope.$broadcast('VendorInfoPopUpEvent', vendorId);
            $scope.VendorOrderModel.showInfoOverlay(event, vendorId);
        }
        $scope.VendorOrderModel.hideVendorInfoOverlay = function() {
            angular.element('.Vendor-info-overlay').hide();
        }
        $scope.VendorOrderModel.PrintServiceWorkSheet = function() {
            var myWindow = window.open(url + "PrintVendorOrder?id=" + $scope.VendorOrderModel.voHeaderId, "", "width=1200, height=600");
        }
        $scope.VendorOrderModel.EnableFinaliseOrder = function() {
            if ($scope.VendorOrderModel.VendorOrderHeader.Status == 'On Order' || $scope.VendorOrderModel.vendorOrderLineItemGroupList.length == 0 || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Partially Received' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Received' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Cancelled') { /* Richa || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Cancelled' */
                return false;
            } else {
                return true;
            }
        }
        $scope.VendorOrderModel.finalizeOrder = function() {
            if ($scope.VendorOrderModel.VendorOrderHeader.disableFinalizeOrderBtn) {
                return;
            }
            $scope.VendorOrderModel.VendorOrderHeader.disableFinalizeOrderBtn = true;
            var voHeaderId = $scope.VendorOrderModel.VendorOrderHeader.Id;
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId
            vendorOrderService.finalizeVendorOrder(voHeaderId, vendorId, $scope.VendorOrderModel.itemsPageSortAttrsJSON, $scope.VendorOrderModel.customersPageSortAttrsJSON, $scope.VendorOrderModel.stocksPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VendorOrderModel.populatePageModels(successfulResult);
                $scope.VendorOrderModel.scrollToPanel(event, 'InfoSection');
            }, function(errorSearchResult) {
                $scope.VendorOrderModel.OverlayInfo = errorSearchResult;
                $scope.VendorOrderModel.VendorOrderHeader.disableFinalizeOrderBtn = false;
            });
        }
        $scope.VendorOrderModel.createPart = function() {
            $rootScope.$broadcast('AddPartVOEvent', {
                vendorName: $scope.VendorOrderModel.VendorOrderHeader.VendorName,
                vendorId: $scope.VendorOrderModel.VendorOrderHeader.VendorId
            });
        }
        $scope.VendorOrderRecordSaveCallback = function(partId) {
            $scope.originalObject = {};
            $scope.originalObject.Info = 'Merchandise'
            $scope.originalObject.Value = partId;
            $scope.VendorOrderModel.addOneItemOnly($scope.originalObject, 1, null);
        }
        $scope.VendorOrderModel.enableSelectedBtnInOrderSection = function() {
            var enableButton = false;
            if ($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length > 0 && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked')) {
                if ($scope.VendorOrderModel.getSelectAllStatusForReqForCustomers() == 'PartialCheck' || $scope.VendorOrderModel.getSelectAllStatusForReqForCustomers() == 'chked') {
                    enableButton = true;
                }
            }
            if (!enableButton) {
                if ($scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length > 0 && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked')) {
                    if ($scope.VendorOrderModel.getSelectAllStatusForReqForStock() == 'PartialCheck' || $scope.VendorOrderModel.getSelectAllStatusForReqForStock() == 'chked') {
                        enableButton = true;
                    }
                }
            }
            return enableButton;
        }
        $scope.VendorOrderModel.selectDeselectAllForReqForCustomers = function() {
            if (!$rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                return;
            }
            if ($scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus == 2) {
                $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 0;
                for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length; i++) {
                    $scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isEdit = false;
                }
                $scope.VendorOrderModel.requiredForCustomerItems_selected = [];
            } else {
                $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 2;
                $scope.VendorOrderModel.getAllselectedRecords(true);
            }
        }
        $scope.VendorOrderModel.getAllselectedRecords = function(IsRequiredForCustomer) {
            var VendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            var voHeaderId = $scope.VendorOrderModel.voHeaderId;
            vendorOrderService.getAllselectedRecordService(VendorId, voHeaderId, IsRequiredForCustomer).then(function(successfulResult) {
                if (IsRequiredForCustomer) {
                    $scope.VendorOrderModel.requiredForCustomerItems_selected = successfulResult;
                    for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length; i++) {
                        $scope.VendorOrderModel.requiredForCustomerItems_editRow[i].isEdit = true;
                    }
                    $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 2;
                } else {
                    $scope.VendorOrderModel.requiredForStockItems_selected = successfulResult;
                    for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length; i++) {
                        $scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit = true;
                    }
                    $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 2;
                }
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.adjustSectionScroll = function() {
            var sectionName = '';
            if ($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length > 0 && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked')) {
                sectionName = 'Order_RequiredForCustomer';
            } else if ($scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length > 0 && ($scope.VendorOrderModel.VendorOrderHeader.Status == 'Open' || $scope.VendorOrderModel.VendorOrderHeader.Status == 'Locked')) {
                sectionName = 'Order_RequiredForStock';
            } else {
                sectionName = 'Order_Items';
            }
            if (sectionName != '') {
                setTimeout(function() {
                    $scope.VendorOrderModel.scrollToPanel(null, sectionName);
                }, 1000);
            }
        }
        $scope.VendorOrderModel.addSelectedItemsFromReqForSectionToOrderSection = function() {
            var selectedVOLIIdJSON = $scope.VendorOrderModel.requiredForCustomerItems_selected.concat($scope.VendorOrderModel.requiredForStockItems_selected);
            var vendorId = $scope.VendorOrderModel.VendorOrderHeader.VendorId;
            var voHeaderId = $scope.VendorOrderModel.voHeaderId;
            var itemsPageSortAttrsJSON = $scope.VendorOrderModel.itemsPageSortAttrsJSON;
            var customersPageSortAttrsJSON = $scope.VendorOrderModel.customersPageSortAttrsJSON;
            var stocksPageSortAttrsJSON = $scope.VendorOrderModel.stocksPageSortAttrsJSON;
            vendorOrderService.addSelectedLineItems(selectedVOLIIdJSON, vendorId, voHeaderId, itemsPageSortAttrsJSON, customersPageSortAttrsJSON, stocksPageSortAttrsJSON).then(function(successfulResult) {
                $scope.VendorOrderModel.requiredForCustomerItems_selected = [];
                $scope.VendorOrderModel.requiredForStockItems_selected = [];
                if (($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length > 0) && ($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList.length == ($filter('filter')($scope.VendorOrderModel.requiredForCustomerItems_editRow, {
                        isEdit: true
                    }).length))) {
                    var itemsGridNewPN = $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage;
                    $scope.VendorOrderModel.customersPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                    $scope.VendorOrderModel.RequiredByCustomer_paginationControlsAction();
                }
                if (($scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length > 0) && ($scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length == ($filter('filter')($scope.VendorOrderModel.requiredForStockItems_editRow, {
                        isEdit: true
                    }).length))) {
                    var itemsGridNewPN = $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage;
                    $scope.VendorOrderModel.stocksPageSortAttrsJSON.CurrentPage = (itemsGridNewPN > 1) ? (itemsGridNewPN - 1) : 1;
                    $scope.VendorOrderModel.RequiredByStock_paginationControlsAction();
                }
                $scope.VendorOrderModel.VRHistoryList = successfulResult.VRHistoryList;
                $scope.VendorOrderModel.vendorOrderLineItemReqByStockList = successfulResult.VOLineItemRequiredForStock;
                $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList = successfulResult.VOLineItemRequiredForCustomer;
                $scope.VendorOrderModel.vendorOrderLineItemGroupList = successfulResult.VendorOrderLineItemGroupList;
                $scope.VendorOrderModel.TotalRequiredForStocks = successfulResult.TotalRequiredForStocks;
                $scope.VendorOrderModel.TotalRequiredForCustomers = successfulResult.TotalRequiredForCustomers;
                $scope.VendorOrderModel.TotalLineItemGroups = successfulResult.TotalLineItemGroups;
                $scope.VendorOrderModel.StockExcessList = successfulResult.StockExcessList;
                $scope.VendorOrderModel.GroupTotalCost = successfulResult.GroupTotalCost;
                $scope.VendorOrderModel.TotalReceivedCost = successfulResult.TotalReceivedCost;
                $scope.VendorOrderModel.TotalUnreceivedCost = successfulResult.TotalUnreceivedCost;
                $scope.VendorOrderModel.populateGroupItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemGroupList);
                $scope.VendorOrderModel.populateReqForCustomerItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList);
                $scope.VendorOrderModel.populateReqForStockItemsEditableModel($scope.VendorOrderModel.vendorOrderLineItemReqByStockList);
                $scope.VendorOrderModel.TotalLineItemGroups = successfulResult.TotalLineItemGroups;
                $scope.VendorOrderModel.VendorOrderHeader = successfulResult.VendorOrderHeader;
                $scope.VendorOrderModel.OrderTypes = successfulResult.OrderTypes;
                for (var i = 0; i < successfulResult.OrderTypes.length; i++) {
                    if (successfulResult.OrderTypes[i].Id == $scope.VendorOrderModel.VendorOrderHeader.OrderType.Id) {
                        $scope.VendorOrderModel.VendorOrderHeader.OrderType = successfulResult.OrderTypes[i];
                    }
                }
                $scope.VendorOrderModel.populateLeftSideHeadingLables();
                $scope.VendorOrderModel.adjustSectionScroll();
                $scope.VendorOrderModel.disableAddSelectedButton = false;
            }, function(errorSearchResult) {
                $scope.VendorOrderModel.disableAddSelectedButton = false;			
                Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        $scope.VendorOrderModel.getSelectAllStatusForReqForStock = function() {
            if ($scope.VendorOrderModel.requiredForStockItems_selected.length == 0) {
                $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 0;
                return '';
            }
            if ($scope.VendorOrderModel.TotalRequiredForStocks == $scope.VendorOrderModel.requiredForStockItems_selected.length) {
                $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 2;
                return 'chked';
            } else {
                $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 1;
                return 'PartialCheck';
            }
        }
        $scope.VendorOrderModel.selectDeselectAllForReqForStock = function() {
            if (!$rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                return;
            }
            if ($scope.VendorOrderModel.RequiredForStockItemSelectedStatus == 2) {
                $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 0;
                for (var i = 0; i < $scope.VendorOrderModel.vendorOrderLineItemReqByStockList.length; i++) {
                    $scope.VendorOrderModel.requiredForStockItems_editRow[i].isEdit = false;
                }
                $scope.VendorOrderModel.requiredForStockItems_selected = [];
            } else {
                $scope.VendorOrderModel.RequiredForStockItemSelectedStatus = 2;
                $scope.VendorOrderModel.getAllselectedRecords(false);
            }
        }
        $scope.VendorOrderModel.addRemoveSelectedRequiredForStockVoli = function(index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                return;
            }
            if ($scope.VendorOrderModel.requiredForStockItems_editRow[index].isEdit == false) {
                $scope.VendorOrderModel.requiredForStockItems_selected.push($scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].Id);
                $scope.VendorOrderModel.requiredForStockItems_editRow[index].isEdit = true;
            } else {
                var idToRemove = $scope.VendorOrderModel.vendorOrderLineItemReqByStockList[index].Id;
                for (var i = 0; i < $scope.VendorOrderModel.requiredForStockItems_selected.length; i++) {
                    if ($scope.VendorOrderModel.requiredForStockItems_selected[i] == idToRemove) {
                        $scope.VendorOrderModel.requiredForStockItems_selected.splice(i, 1);
                        $scope.VendorOrderModel.requiredForStockItems_editRow[index].isEdit = false;
                    }
                }
            }
            $scope.VendorOrderModel.getSelectAllStatusForReqForStock();
        }
        $scope.VendorOrderModel.getSelectAllStatusForReqForCustomers = function() {
            if ($scope.VendorOrderModel.requiredForCustomerItems_selected.length == 0) {
                $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 0;
                return '';
            }
            if ($scope.VendorOrderModel.TotalRequiredForCustomers == $scope.VendorOrderModel.requiredForCustomerItems_selected.length) {
                $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 2;
                return 'chked';
            } else {
                $scope.VendorOrderModel.RequiredForCustomerItemSelectedStatus = 1;
                return 'PartialCheck';
            }
        }
        $scope.VendorOrderModel.addRemoveSelectedRequiredForCustomerVoli = function(index) {
            if (!$rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                return;
            }
            if ($scope.VendorOrderModel.requiredForCustomerItems_editRow[index].isEdit == false) {
                $scope.VendorOrderModel.requiredForCustomerItems_selected.push($scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].Id);
                $scope.VendorOrderModel.requiredForCustomerItems_editRow[index].isEdit = true;
            } else {
                var idToRemove = $scope.VendorOrderModel.vendorOrderLineItemReqByCustomerList[index].Id;
                for (var i = 0; i < $scope.VendorOrderModel.requiredForCustomerItems_selected.length; i++) {
                    if ($scope.VendorOrderModel.requiredForCustomerItems_selected[i] == idToRemove) {
                        $scope.VendorOrderModel.requiredForCustomerItems_selected.splice(i, 1);
                        $scope.VendorOrderModel.requiredForCustomerItems_editRow[index].isEdit = false;
                    }
                }
            }
            $scope.VendorOrderModel.getSelectAllStatusForReqForCustomers();
        }
        $scope.VendorOrderModel.showDeleteOrderLink = function() {
            if ($scope.VendorOrderModel.vendorOrderLineItemGroupList != undefined && $scope.VendorOrderModel.vendorOrderLineItemGroupList.length == 0 && $scope.VendorOrderModel.VendorOrderHeader != undefined && $scope.VendorOrderModel.VendorOrderHeader.Status == 'Open') {
                return true;
            } else {
                return false;
            }
        }
        $scope.VendorOrderModel.deleteVendorOrder = function() {
            vendorOrderService.deleteVendorOrder($scope.VendorOrderModel.VendorOrderHeader.Id).then(function(successfulResult) {
                if (successfulResult == 'Success') {
                    Notification.success($translate.instant('Generic_Deleted'));
                    loadState($state, 'homePage');
                } else {
                    Notification.error($translate.instant('Something_is_changed_on_this_Order'));
                    $scope.VendorOrderModel.loadVendor();
                }
            }, function(errorSearchResult) {
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        
        $scope.VendorOrderModel.openMailPopup = function() {
        	var messageParams = {
                    Activity: 'Email',
                    IsEmailFromVendorOrder: true,
                    VendorName: $scope.VendorOrderModel.VendorOrderHeader.VendorName,
                    CustomerInfo : {
                        'Cust_PreferredEmail': '',
                        'Cust_WorkEmail': $scope.VendorOrderModel.VendorInfo.VendorWorkEmail,
                        'Cust_OtherEmail': $scope.VendorOrderModel.VendorInfo.VendorOtherEmail,
                        'Cust_Type': 'Business'
                    },
                    VendorOrderId: $scope.VendorOrderModel.VendorOrderHeader.Id,
                    VendorId: $scope.VendorOrderModel.VendorOrderHeader.VendorId,
                    VendorOrderNumber: $scope.VendorOrderModel.VendorOrderHeader.VOName
                }
        	var SelectedDocumentList = ['VendorOrderPDF'];
        	messageParams.SelectedDocuments = SelectedDocumentList;
        	loadState($state, 'VendorOrder.CustomerMessagingPopUp', {
                messagingInfoParams: messageParams
            });
        }
        
        $scope.VendorOrderModel.exportVendorOrderData = function() {
        	var pageURL = url + 'VendorOrderExport?id=' + $scope.VendorOrderModel.VendorOrderHeader.Id + '&type=' + $scope.VendorOrderModel.VendorOrderExportType.Value;
        	window.location.assign(pageURL);
        	$scope.VendorOrderModel.resetDefaultExportType();
        }
        
        $scope.VendorOrderModel.resetDefaultExportType = function() {
        	$scope.VendorOrderModel.showExportConfirmationModal = false;
        	$scope.VendorOrderModel.VendorOrderExportType = {Name: "Generic (.csv)",Value: "Generic"};
        }
        
        $scope.VendorOrderModel.setFocusOnInput = function(elementId) {
        	angular.element("#" + elementId).focus();
        }
        
        $scope.VendorOrderModel.openConfirmationDialog = function(id) {
        	if(id === 'VendorExport' && $scope.VendorOrderModel.vendorOrderLineItemGroupList.length == 0) {
        		return;
        	}
        	$scope.VendorOrderModel.showExportConfirmationModal = true;
            $scope.VendorOrderModel.ConfirmationModel = {
                id: id,
                payload: {}
            };
            switch (id) {
	            case 'VendorExport':
                    $scope.VendorOrderModel.ConfirmationModel.headingText = $translate.instant('Export_order_label');
                    $scope.VendorOrderModel.ConfirmationModel.messageText = '<div class="text-left dropdown-container"><p>Select a format to export</p>';
	                $scope.VendorOrderModel.ConfirmationModel.modalCss = "vendor-export-confirmation";
	                $scope.VendorOrderModel.ConfirmationModel.isAlert = true;
	                $scope.VendorOrderModel.ConfirmationModel.okBtnLabel = $translate.instant('Export');
	                $scope.VendorOrderModel.ConfirmationModel.hideCloseIcon = true;
	                $scope.VendorOrderModel.ConfirmationModel.okBtnCss = 'bp-btn-small H200';
	                $scope.VendorOrderModel.ConfirmationModel.okBtnFunc = $scope.VendorOrderModel.exportVendorOrderData;
	                $scope.VendorOrderModel.ConfirmationModel.cancelBtnFunc = $scope.VendorOrderModel.resetDefaultExportType;
	                $scope.VendorOrderModel.ConfirmationModel.confirmationSource = 'VendorOrderExport';
	                break;
	            case 'PartSmart':
	            	$scope.VendorOrderModel.ConfirmationModel.headingText = $translate.instant('Part_not_found_label');
	            	$scope.VendorOrderModel.ConfirmationModel.messageText = $translate.instant('Part_not_found_description') + ":";
	            	$scope.VendorOrderModel.ConfirmationModel.modalCss = "part-smart-confirmation";
	            	$scope.VendorOrderModel.ConfirmationModel.isAlert = true;
	            	$scope.VendorOrderModel.ConfirmationModel.okBtnLabel = $translate.instant('Okay_label');
	            	$scope.VendorOrderModel.ConfirmationModel.hideCloseIcon = true;
	            	$scope.VendorOrderModel.ConfirmationModel.cancelBtnFunc = $scope.VendorOrderModel.closeModalDialog;
	                $scope.VendorOrderModel.ConfirmationModel.helperText = '<div class="text-left list-wrapper"><ul class="disk-type-list">';
                    	for(var i = 0; i < $scope.PartSmart.PartNotFoundList.length; i++) {
	                	$scope.VendorOrderModel.ConfirmationModel.helperText += '<li>' + $scope.PartSmart.PartNotFoundList[i] + '</li>';
                    	}
	                $scope.VendorOrderModel.ConfirmationModel.helperText += '</ul></div>';
	                $scope.VendorOrderModel.ConfirmationModel.confirmationSource = 'PartSmart'; 
	                break;
            }
            $scope.VendorOrderModel.ConfirmationModel.showDialog = true;
        }
        $scope.VendorOrderModel.closeModalDialog = function() {
        	$scope.VendorOrderModel.showExportConfirmationModal = false;
        	$scope.VendorOrderModel.ConfirmationModel.showDialog = false;
        }
        $scope.VendorOrderModel.openPartSmartAttachmentDialog = function() {
        	loadState($state, 'VendorOrder.AddAttachment', {
                AddAttachmentParams: {
                    'IsFfromNewUI': true,
                    'IsImportingPartSmart': true,
                    'IsFromVendorOrder': true
                }
            });
        }
        $scope.PartSmart = {"PartsToAdd" : [], "IsAddingFromPartSmart" : false};
        
        function addPartSmartItemsToVO(partObj) {
        	var defer = $q.defer();
        	vendorOrderService.addPartSmartItemsToVO(angular.toJson(partObj), $scope.VendorOrderModel.VendorOrderHeader.Id).then(function(coHeaderResult) {
        		defer.resolve(coHeaderResult);
            }, function(error) {
            	$scope.VendorOrderModel.isLoading = false;
            	Notification.error($translate.instant('GENERIC_ERROR'));
            	defer.reject($translate.instant('Error_in_adding_related_parts'));
            });
        	return defer.promise;
        }
        
        function addPartsSmartItems() {
        	$scope.VendorOrderModel.isLoading = true;
        	vendorOrderService.searchPartSmartItems(angular.toJson($scope.PartSmart.PartsToAdd), $scope.VendorOrderModel.VendorOrderHeader.VendorId).then(function(partList) {
        		$scope.PartSmart.PartsToAdd = [];
        		if(partList) {
        			$scope.PartSmart.PartNotFoundList= [];
        			var partExistsInBPList = [];
        			for(var i = 0; i < partList.length; i++) {
        				if(!partList[i].PartId) {
							$scope.PartSmart.PartNotFoundList.push(partList[i].PartNumber);
						} else {
							partExistsInBPList.push(partList[i]);
						}
        			}
        			if(partExistsInBPList.length) {
        				var viewsPromises = [];
        				for(var i = 0; i < partExistsInBPList.length; i++) {
        					viewsPromises.push(addPartSmartItemsToVO(partExistsInBPList[i]));
        				}
        				return $q.all(viewsPromises).then(function() {
        					//Get vo data
        					$scope.VendorOrderModel.loadAllGridDetails();
        					$scope.VendorOrderModel.isLoading = false;
        					if($scope.PartSmart.PartNotFoundList.length) {
                        		$scope.VendorOrderModel.openConfirmationDialog('PartSmart');
                        		$scope.PartSmart.PartNotFoundList = [];
                        	}
        	        	});
        			} else {
        				$scope.VendorOrderModel.isLoading = false;
        				if($scope.PartSmart.PartNotFoundList.length) {
                    		$scope.VendorOrderModel.openConfirmationDialog('PartSmart');
                    		$scope.PartSmart.PartNotFoundList = [];
                    	}
        			}
        		} else {
        			$scope.VendorOrderModel.isLoading = false;
        		}
            }, function(error) {
            	$scope.VendorOrderModel.isLoading = false;
            	Notification.error($translate.instant('GENERIC_ERROR'));
            });
        };
        
        function textToJson(partsmartContentStr) {
            $scope.VendorOrderModel.isLoading = true;
           	var partObj = {};
           	var contentArray = partsmartContentStr.split("\n");
           	for(var i = 0; i < contentArray.length; i++) {
           		var x = contentArray[i];
               	if(x.length > 0) {
               		var arr = x.split(' ');
               		arr[0] = x.substring(0, 2).trim();
   	                arr[1] = x.substring(2, x.length).trim();
   	                if(arr[0] === "hS" && arr[1] !== "P") {
   	                	$scope.PartSmart.PartsToAdd = [];
   	                	$scope.VendorOrderModel.isLoading = false;
   	                	return;
   	                } else {
   	                	if(arr[0] === "DH") {
   	                		if(partObj && partObj["PartNumber"] && partObj["Qty"]) {
   	                			$scope.PartSmart.PartsToAdd.push(partObj);
   	                		}
   	                		partObj = {};
   	                	} else {
   	                		if(arr[0] === "dP") {
   	    	                	partObj["PartNumber"] = arr[1];
   	    	                } else if(arr[0] === "dQ") {
   	    	                	partObj["Qty"] = (arr[1] ? parseFloat(arr[1]) : 0);
   	    	                }
   	                	}
   	                }
               	}
           	}
           	if(partObj && partObj["PartNumber"] && partObj["Qty"]) {
       			$scope.PartSmart.PartsToAdd.push(partObj);
       			partObj = {};
            }
       }
        
        $scope.VendorOrderModel.openPartLocatorWindow = function(part) {
        	var isNearDealerResultRecieved = false;
            var isAllDealerResultRecieved = false;
            var isSupplierResultRecieved = false;
            $scope.VendorOrderModel.isLoading = true;
            $scope.VendorOrderModel.PartLocator = {};
            vendorOrderService.getPartsLocator(part.PartId,1,"Dealer Radius").then(function(response) {
        		console.log("DealerRadius", response);
        		isNearDealerResultRecieved = true;
        		
                $scope.VendorOrderModel.PartLocator.headingText = 'BRP Availability';
                if(response.DealerNearList && response.DealerNearList.length) {
                	$scope.VendorOrderModel.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                }
                $scope.VendorOrderModel.PartLocator.availabiltyText = 'Available from Manufacturer';
                $scope.VendorOrderModel.PartLocator.modalCss = 'part-locator';
                $scope.VendorOrderModel.PartLocator.nearDealerList = response.DealerNearList;
                
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);

    			}
    		}).catch(function(error) {
    			$scope.VendorOrderModel.isLoading = false;
    	      });
            vendorOrderService.getPartsLocator(part.PartId,1,"Dealer").then(function(response) {
        		console.log("Dealer",response);
        		isAllDealerResultRecieved = true;
        		
        		if(response.AllDealerList && response.AllDealerList.length) {
                	$scope.VendorOrderModel.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                }
                $scope.VendorOrderModel.PartLocator.allDealerList = response.AllDealerList;
                
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);
    			}
    		}).catch(function(error) {
    			$scope.VendorOrderModel.isLoading = false;
    	      });
            vendorOrderService.getPartsLocator(part.PartId,1,"Supplier").then(function(response) {
        		console.log("Supplier",response);
        		isSupplierResultRecieved = true;
        		
        		$scope.VendorOrderModel.PartLocator.availabiltyNumber = response.ManufacturerAvailableQty;
                $scope.VendorOrderModel.PartLocator.phoneNumber = response.ManufacturerPhoneNumber;
                
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);
    			}
    		}).catch(function(error) {
    			$scope.VendorOrderModel.isLoading = false;
    	      });
    	}
        function setCommonFieldForPartLocator(response) {
        	$scope.VendorOrderModel.PartLocator.showDialog=true;
            $scope.VendorOrderModel.isLoading = false;
            if(!$scope.VendorOrderModel.PartLocator.partDescription) {
            	$scope.VendorOrderModel.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
            }
        }
        
        
        $scope.VendorOrderModel.showPartSmartImportedContent = function(partsmartContentStr, fileType) {
        	$scope.VendorOrderModel.isLoading = true;
        	if(fileType && (fileType.toLowerCase()).includes('csv')) {
        		var fileKeyToObjKeyMap = {"Part Number" : "PartNumber", "Quantity" : "Qty"};
    	    	$scope.PartSmart.PartsToAdd = partsmartCSVToJson(partsmartContentStr, fileKeyToObjKeyMap, 'Vendor Order');
        	} else if(fileType && ((fileType.toLowerCase()).includes('txt') || (fileType.toLowerCase()).includes('text/plain'))) {
        		textToJson(partsmartContentStr);
        	} else {		//fileType && fileType == 'text/xml'
        		Notification.error($translate.instant('This_file_format_is_not_supported'));
        		$scope.VendorOrderModel.isLoading = false;
        		return;
        	} 
        	
            if($scope.PartSmart.PartsToAdd.length) {
            	addPartsSmartItems();
            } else {
            	Notification.error($translate.instant('Invalid_part_file_format_error_message'));
            	$scope.VendorOrderModel.isLoading = false;
            }
        }
        
        $scope.VendorOrderModel.loadVendor();
    }])
});