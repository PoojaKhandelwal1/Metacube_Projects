-define(['Routing_AppJs_PK', 'CustomerOrderServices', 'tel', 'AngularNgEnter', 'numberOnlyInputBlur_CO', 'CODirectives', 'dirNumberInput', 'underscore_min', 'JqueryUI', 'PartPopUpOnVendorOrderCtrl', 'COUInfoPopUpCtrl', 'NumberOnlyInput_New'], function(Routing_AppJs_PK, CustomerOrderServices, tel, AngularNgEnter, numberOnlyInputBlur_CO, CODirectives, dirNumberInput, underscore_min, JqueryUI, PartPopUpOnVendorOrderCtrl, COUInfoPopUpCtrl, NumberOnlyInput_New) {
    $(document).ready(function() {
        $('.COUInfoPopup').mouseout(function() {
            $('.COUInfoPopup').hide();
        });
        $('.btn').click(function() {
            $($(this).parent().find("input")).focus();
        });
    });
    $(document).click(function(e) {
        var errorMsgDiv = document.getElementById('CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg');
        var errorMsgDiv1 = document.getElementById('CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1');
        var childElementsIdList = [];
        var childElementsIdList1 = [];
        if (errorMsgDiv != null) {
            for (i = 0; i < errorMsgDiv.childNodes.length; i++) {
                if (errorMsgDiv.childNodes[i].nodeType == 1) {
                    childElementsIdList[i] = errorMsgDiv.childNodes[i].id;
                }
            }
        }
        if (errorMsgDiv1 != null) {
            for (i = 0; i < errorMsgDiv1.childNodes.length; i++) {
                if (errorMsgDiv1.childNodes[i].nodeType == 1) {
                    childElementsIdList1[i] = errorMsgDiv1.childNodes[i].id;
                }
            }
        }
        if (e.target.id != 'CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg' && e.target.id != 'CO_Deposits_block_deposit_header_amount_block_pricebox_addbtn_Payments' && childElementsIdList.indexOf(e.target.id) == -1) {
            $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg").hide();
        } else {
            $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg").show();
        }
        if (e.target.id != 'CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1' && e.target.id != 'CO_Deposits_block_deposit_header_amount_block_pricebox_addbtn' && childElementsIdList1.indexOf(e.target.id) == -1) {
            $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1").hide();
        } else {
            $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1").show();
        }
    });
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CustomerOrderCtrl', ['$scope', '$timeout', '$rootScope', '$state', '$stateParams', 'CustomerInfoService', 'DealService', 'SOHeaderService', 'WizardService', 'FileUploadService', 'SOPrintWorkSheetService', 'userService', '$filter', 'focusElement',
        function($scope, $timeout, $rootScope, $state, $stateParams, CustomerInfoService, DealService, SOHeaderService, WizardService, FileUploadService, SOPrintWorkSheetService, userService, $filter, focusElement) {
            var Notification = injector.get("Notification");
            var origin = window.location.origin;
            var url = origin + '/apex/';
            $scope.showLoading = true;
            var loadingIconContainerHeight = screen.height - (angular.element(".headerNav").height());
            angular.element("#NewCOLoadingIconContainerId").css("height", loadingIconContainerHeight);
            var loadingIconContainerWidth = screen.width - (angular.element(".headerNav").width());
            angular.element("#NewCOLoadingIconContainerId").css("width", loadingIconContainerWidth);
            $scope.isOpen = true;
            $scope.CustomerOrderModel = {};
            $scope.objectData = "";
            $scope.ShowContent = false;
            $scope.CustomerOrderModel.IsLoadFinancingSection = false;
            $scope.CustomerModal = {};
            $scope.CustomerOrderModel.CustomerData = {};
            $scope.CustomerOrderModel.Deal = {};
            $scope.CustomerOrderModel.Deal.showFactoryOptions = false;
            $scope.CustomerOrderModel.Deal.AllDealTypes = ['Cash Sale', 'Finance'];
            $scope.CustomerOrderModel.Deal.DealType = 'Cash Sale';
            $scope.CustomerOrderModel.Deal.DealTotal = 0.00;
            $scope.ViewCustomer = {};
            $scope.CustomerOrderModel.InvoiceHistory = {};
            $scope.CustomerOrderModel.CustomerInfo = [];
            $scope.CustomerOrderModel.CheckOutItems = [];
            $scope.CustomerOrderModel.Payment = [];
            $scope.CustomerOrderModel.isDealCheckoutActive = false;
            $scope.CustomerOrderModel.Deposits = [];
            $scope.CustomerOrderModel.hideOdometerArrival = true;
            $scope.CustomerOrderModel.hideOdometerDeparture = true;
            $scope.CustomerOrderModel.CustomerInfoData = {};
            $scope.CustomerOrderModel.MerchandiseItems = [];
            $scope.CustomerOrderModel.serviceOrderList = [];
            $scope.CustomerOrderModel.AllSectionList = [];
            $scope.CustomerOrderModel.DealInfoLoadData = {};
            $scope.CustomerOrderModel.isPageLoadFirstTime = false;
            $scope.CustomerOrderModel.dealDepositeTotal = 0;
            $scope.CustomerOrderModel.DealSummaryObj = {};
            $scope.CustomerOrderModel.DealSummaryObj.Total = 0;
            $scope.CustomerOrderModel.showMorePartsDetails = false;
            $scope.CustomerOrderModel.DuplicatePartList = {};
            $scope.CustomerOrderModel.hideStatusPicklistValue = true;
            $scope.CustomerOrderModel.collapseCheckoutSection = true;
            $scope.CustomerOrderModel.CashPaymentRoundingCentValue = $Global.Cash_Paymenmt_Rounding_Factor;
            $scope.CustomerOrderModel.hideMerchandiseSection = false;
            $scope.CustomerOrderModel.isSupressTrue = false;
            $scope.CustomerOrderModel.dateFormat = $Global.DateFormat;
            $scope.CustomerOrderModel.DuplicateSectionList = {};
            $scope.CustomerOrderModel.SelectedSection = {
                'item': 'Info Section',
                'relatedSection': 'CustomerSection',
                'sectionType': [{
                    'Object': 'Customer:',
                    'Value': 'Customer'
                }, {
                    'Object': 'User:',
                    'Value': 'User'
                }, {
                    'Object': 'Merchandise:',
                    'Value': 'Part__c'
                }, {
                    'Object': 'Kit:',
                    'Value': 'Kit_Header__c'
                }, {
                    'Object': 'Fee:',
                    'Value': 'Fee__c'
                }, {
                    'Object': 'Unit:',
                    'Value': 'Customer_Owned_Unit__c'
                }]
            }
            $scope.CustomerOrderModel.SOHeaderList = [];
            $scope.CustomerOrderModel.SOHeaderListCopy = [];
            $scope.CustomerOrderModel.SectionList = [];
            $scope.CustomerOrderModel.VendorOrderListByVendorId = [];
            $scope.CustomerOrderModel.payment_TotalAmount = false;
            $scope.CustomerOrderModel.payment_Deal_TotalAmount = false;
            $scope.CustomerOrderModel.ChangeRecords = 0;
            $scope.CustomerOrderModel.IsFirst = 0;
            $scope.CustomerOrderModel.CardInfo = {};
            $scope.WizardModel = {};
            $scope.CustomerOrderModel.isWizardMode = false;
            $scope.CustomerOrderModel.allowFromPopup = false;
            if ($scope.PrintPreviewModel == undefined) {
                $scope.PrintPreviewModel = {};
            }
            $scope.PrintPreviewModel.PrintPreviewInfo = [];
            $scope.CustomerOrderModel.factoryTotal = 0;
            $scope.CustomerOrderModel.dealerInstalledOptionsTotal = 0;
            $scope.CustomerOrderModel.allowBlur = true;
            $scope.CustomerOrderModel.Blurcalled = false;
            $scope.CustomerOrderModel.BlurcalledService = [];
            $scope.CustomerOrderModel.allowBlurservice = [];
            $scope.CustomerOrderModel.allowBlur1 = true;
            $scope.CustomerOrderModel.Blurcalled1 = false;
            $scope.CustomerOrderModel.allowBlurForDealMerch = true;
            $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
            $scope.CustomerOrderModel.BlurcalledForUnresolvedFulfillment = false;
            $scope.CustomerOrderModel.allowBlurForUnresolvedFulfillment = true;
            $scope.CustomerOrderModel.allowBlurForFIProduct = true;
            $scope.CustomerOrderModel.BlurcalledForFIProduct = false;
            $scope.CustomerOrderModel.isPaymentDropdownOpen = false;
            $scope.CustomerOrderModel.isRefundDepositBtnClicked = false;
            $scope.CustomerOrderModel.cancelPaymentClicked = false;
            $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit = false;
            $scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit = false;
            $scope.CustomerOrderModel.showCheckoutSection = false;
            $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
            $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = false;
            $scope.CustomerOrderModel.enableEmailInvoiceCheckBox = false;
            $scope.CustomerOrderModel.enableshowAmountSavedCheckBox = false;
            $scope.CustomerOrderModel.TotalDiscountAmount = 0;
            $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
            $scope.CustomerOrderModel.isDisplayActivatedQuoteCO = true;
            $scope.CustomerOrderModel.isDisplayDeletedQuoteCO = true;
            $scope.CustomerOrderModel.isDisplaySetCOAsQuote = true;
            $scope.CustomerOrderModel.isPrintInvoiceBtnVisible = false;
            $scope.CustomerOrderModel.DealFormValidationModal = {
                DownPayment: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                }
            };
            $scope.CustomerOrderModel.AgreedValueValidationModal = {
                AgreedValue: {
                    isError: false,
                    ErrorMessage: '',
                    Type: ''
                }
            };
            $scope.isOrderFinalizePressed = false;
            $scope.isInvoiceFinalizePressed = false;
            $scope.PartCompModal = {};
            $scope.$on('CustomerOrder_AddNewMerchandise', function(event, args) {
                $scope.CustomerOrderModel.createPart();
            });
            $scope.CustomerOrderModel.createPart = function() {
                $scope.PartCompModal.openAddPartPopup();
            }
            $scope.CustomerOrderModel.populateLeftSideHeadingLables = function() {
                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
            }
            $scope.CustomerOrderModel.dealUnitStatussMap = {};
            $scope.CustomerOrderModel.dealUnitStatussMap['Temporary'] = 'Cannot commit, contains Temporary Units';
            $scope.CustomerOrderModel.dealUnitStatussMap['Uncommitted'] = 'Units have not been committed to this deal';
            $scope.CustomerOrderModel.dealUnitStatussMap['Committed'] = 'Inventory Units have been reserved for this deal';
            $scope.CustomerOrderModel.dealUnitStatussMap['Delivered'] = 'Units have been delivered to the customer';
            $scope.CustomerOrderModel.dealOptionsAndFeesStatussMap = {};
            $scope.CustomerOrderModel.dealOptionsAndFeesStatussMap['Uncommitted'] = 'Options have not been committed to the deal Action required: Commit Options';
            $scope.CustomerOrderModel.dealOptionsAndFeesStatussMap['Committed'] = 'Options have been committed and ordered Action required: Await Fulfillment';
            $scope.CustomerOrderModel.dealOptionsAndFeesStatussMap['Fulfilled'] = 'All Options have been fulfilled for the deal Action required: Ready to Deliver/Invoice';
            $scope.CustomerOrderModel.DealUnresolvedFulfillmentMap = {};
            $scope.CustomerOrderModel.DealUnresolvedFulfillmentMap['Added'] = 'Item was added';
            $scope.CustomerOrderModel.DealUnresolvedFulfillmentMap['Updated'] = 'Qty was changed';
            $scope.CustomerOrderModel.DealUnresolvedFulfillmentMap['Removed'] = 'Item was removed';
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap = {};
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap['Part Sale'] = 'Show_Deal,Show_Merchandise,Show_ServiceOrder,Show_Special_Orders,Show_Deposits,Show_Checkout,Show_Invoice_History,Show_Finalize_Order,Show_Payments,Show_Items';
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap['Service Order'] = 'Show_Deal,Show_Merchandise,Show_ServiceOrder,Show_Special_Orders,Show_Deposits,Show_Checkout,Show_Invoice_History,Show_Finalize_Order,Show_Payments,Show_Items';
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap['Unit Deal'] = 'Show_Deal,Show_Merchandise,Show_ServiceOrder,Show_Special_Orders,Show_Deposits,Show_Checkout,Show_Invoice_History,Show_Finalize_Order,Show_Payments,Show_Items';
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap['Cash Sale'] = 'Show_Merchandise,Show_Checkout,Show_Special_Orders';
            $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap['Internal Service'] = 'Show_ServiceOrder,Show_Checkout,Show_Special_Orders';
            $scope.CustomerOrderModel.collapseDeposit = function() {
                if ($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1 && $scope.CustomerOrderModel.SOHeaderList.length == 0 && $scope.CustomerOrderModel.MerchandiseItems.length == 0 && $scope.CustomerOrderModel.MerchandiseGhostItems.length == 0 || !$rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    $scope.CustomerOrderModel.displaySections.Deposit = false;
                } else if ($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1 && ($scope.CustomerOrderModel.SOHeaderList.length > 0 || $scope.CustomerOrderModel.MerchandiseItems.length > 0 || $scope.CustomerOrderModel.MerchandiseGhostItems.length > 0)) {
                    $scope.CustomerOrderModel.displaySections.Deposit = true;
                } else if ($scope.CustomerOrderModel.Customer.Name != null && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deposits') > -1) {
                    $scope.CustomerOrderModel.displaySections.Deposit = true;
                }
            }
            $scope.CustomerOrderModel.setKeyWordInSTA = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Cash Sale') {
                    $scope.AddToSearch('Merchandise:');
                } else if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service') {
                    $scope.AddToSearch('Unit:');
                } else if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Unit Deal') {
                    angular.element('#CO_SearchToAdd_value').focus();
                } else if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Service Order') {
                    angular.element('#CO_SearchToAdd_value').focus();
                }
            }
            $scope.CustomerOrderModel.EnableCheckout = function(checkoutItem, index) {
                if (checkoutItem.IsInvoiceable) {
                    return false;
                } else {
                    return true;
                }
            }
            $scope.CustomerOrderModel.showCustomerInfoOverlay = function(event, custId) {
                $scope.CustomerOrderModel.OverlayInfo = {};
                $scope.CustomerOrderModel.CustomerOverlay = [];
                if (custId == null) {
                    return;
                }
                $scope.CustomerOrderModel.showInfoOverlay(event, custId);
                CustomerInfoService.customerInfo(custId).then(function(customerRecord) {
                    if (customerRecord.length > 0) {
                        $scope.CustomerOrderModel.OverlayInfo = customerRecord[0];
                        if ($scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone == "") {
                            if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeNumber != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedHomeNumber;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkNumber != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedWorkNumber;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_Mobile != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedOtherPhone;
                            }
                        }
                        if ($scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail == "") {
                            if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail;
                            }
                        }
                        $scope.CustomerOrderModel.CustomerOverlay = [{
                            label: 'Name',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_Name
                        }, {
                            label: 'PHONE PRIMARY',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone
                        }, {
                            label: 'PHONE ALT',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedOtherPhone
                        }, {
                            label: 'EMAIL',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail
                        }, {
                            label: 'ADDRESS',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_BillingStreet + ' ' + $scope.CustomerOrderModel.OverlayInfo.Cust_BillingCity
                        }];
                    }
                }, function(errorSearchResult) {
                    $scope.CustomerOrderModel.OverlayInfo = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.setPreffered = function(customerRecord) {
                $scope.CustomerOrderModel.CustomerInfoData = customerRecord;
                $scope.CustomerOrderModel.CustomerInfoDetails = [];
                if (!customerRecord.Cust_PreferredPhone) {
                    if (customerRecord.Cust_HomeNumber) {
                        customerRecord.Cust_PreferredPhone = customerRecord.Cust_HomeNumber;
                    } else if (customerRecord.Cust_WorkNumber) {
                        customerRecord.Cust_PreferredPhone = customerRecord.Cust_WorkNumber;
                    } else if (customerRecord.Cust_Mobile) {
                        customerRecord.Cust_PreferredPhone = customerRecord.Cust_OtherNumber;
                    } else {
                        customerRecord.Cust_PreferredPhone = "-";
                    }
                }
                if (!customerRecord.Cust_PreferredEmail) {
                    if (customerRecord.Cust_HomeEmail.length > 0) {
                        customerRecord.Cust_PreferredEmail = customerRecord.Cust_HomeEmail;
                    } else if (customerRecord.Cust_HomeEmail.length > 0) {
                        customerRecord.Cust_PreferredEmail = customerRecord.Cust_WorkEmail;
                    } else if (customerRecord.Cust_OtherEmail) {
                        customerRecord.Cust_PreferredEmail = customerRecord.Cust_OtherEmail;
                    } else {
                        customerRecord.Cust_PreferredEmail = "-";
                    }
                }
                $scope.CustomerOrderModel.CustomerInfoDetails = [{
                    label: 'Email:',
                    value: customerRecord.Cust_PreferredEmail
                }, {
                    label: 'Phone:',
                    value: customerRecord.Cust_PreferredPhone
                }, {
                    label: 'Cell:',
                    value: (!customerRecord.Cust_OtherNumber ? "-" : customerRecord.Cust_OtherNumber)
                }, {
                    label: 'Address:',
                    value: customerRecord.Cust_BillingStreet + '\n' + customerRecord.Cust_BillingCity + '\n' + customerRecord.Cust_BillingState + '\n' + customerRecord.Cust_BillingCountry + '\n' + customerRecord.Cust_BillingPostalCode
                }];
            }
            $scope.CustomerOrderModel.resolveFulfillmentData = function(dealId, DealUnresolvedFulfillmentJSON, UnitSelected) {
                $scope.CustomerOrderModel.chargeMethod = DealUnresolvedFulfillmentJSON.ChargeMethod;
                if (UnitSelected != undefined) {
                    DealUnresolvedFulfillmentJSON.UnitId = UnitSelected.Id;
                }
                $scope.CustomerOrderModel.UnitId = DealUnresolvedFulfillmentJSON.UnitId;
                DealService.resolveFulfillment(dealId, angular.toJson(DealUnresolvedFulfillmentJSON), $scope.CustomerOrderModel.chargeMethod, $scope.CustomerOrderModel.UnitId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealInfo = successfulSearchResult.DealInfo;
                    $scope.CustomerOrderModel.DealItemList = successfulSearchResult.UnitList;
                    $scope.CustomerOrderModel.DealTradeInList = successfulSearchResult.TradeInsList;
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.CustomerOrderModel.DealSummaryObj = successfulSearchResult.DealSummaryObj;
                    $scope.CustomerOrderModel.DealInfo.DealType = successfulSearchResult.DealInfo.DealType;
                    if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        $scope.CustomerOrderModel.StockUnitMap();
                    }
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.CustomerOrderModel.editLineItemsForOptionFees();
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'user,coInvoiceHeader').then(function(successfulSearchResult1) {
                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult);
                        //TODO
                    });
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.insertKitHeaderInDealMerchGrid = function(kitHeaderId, dealId, coHeaderId) {
                if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced') {
                    Notification.error($Label.Cannot_Add_Lineitem_To_DealMerch_After_DealInvoice);
                    return;
                }
                DealService.insertKitHeaderInDealMerchGrid(kitHeaderId, dealId, coHeaderId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                    if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        $scope.CustomerOrderModel.StockUnitMap();
                    }
                    $scope.CustomerOrderModel.DealMerchandiseItems_editRow[($scope.CustomerOrderModel.DealMerchandiseList.length - 1)].isEdit = true;
                    setTimeout(function() {
                        elementId = angular.element('#' + 'dealCoLI_Header_Price_Edit_' + ($scope.CustomerOrderModel.DealMerchandiseList.length - 1)).focus();
                        angular.element(elementId).find('input[type=text]').filter(':visible:first').focus();
                        $scope.CustomerOrderModel.scrollToPanel(null, 'DealMerchandiseSection');
                    }, 10);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.StockUnitMap = function() {
                $scope.CustomerOrderModel.dealStockIdValueJson = [];
                if ($scope.CustomerOrderModel.DealItemList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                        if ($scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitId != undefined && $scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitNumber != undefined) {
                            var obj = {
                                Id: $scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitId,
                                Value: $scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitNumber
                            };
                            $scope.CustomerOrderModel.dealStockIdValueJson.push(obj);
                        }
                    }
                    for (var i = 0; i < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length; i++) {
                        $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].ChargeMethod = 'Invoice';
                        if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].DealServiceLineItemId != null && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].DealServiceLineItemId != undefined) {
                            for (var j = 0; j < $scope.CustomerOrderModel.dealStockIdValueJson.length; j++) {
                                if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].StockId == $scope.CustomerOrderModel.dealStockIdValueJson[j].Value) {
                                    $scope.CustomerOrderModel.dealStockIdValue[i] = $scope.CustomerOrderModel.dealStockIdValueJson[j];
                                }
                            }
                        } else {
                            $scope.CustomerOrderModel.dealStockIdValue[i] = $scope.CustomerOrderModel.dealStockIdValueJson[0];
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.isSwitchToCashSale = false;
            $scope.CustomerOrderModel.isAddNewCustomer = false;
            $scope.CustomerOrderModel.openSwitchCOConfirmModal = function(isConvertingToCashSale, isAddNewCustomer) {
                $scope.CustomerOrderModel.isSwitchToCashSale = isConvertingToCashSale;
                $scope.CustomerOrderModel.isAddNewCustomer = isAddNewCustomer;
                if ($scope.CustomerOrderModel.verifySwitchingConditions()) {
                    if ($scope.CustomerOrderModel.MerchandiseItems.length > 0 || $scope.CustomerOrderModel.isSOLIExist()) {
                        angular.element('#switchCOConfirm').modal({
                            backdrop: 'static',
                            keyboard: false
                        });
                        angular.element('#switchCOConfirm').show();
                    } else {
                        if ($scope.CustomerOrderModel.isAddNewCustomer) {
                            $scope.CustomerOrderModel.CreateCustomerFromCO();
                        } else if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                            $scope.CustomerOrderModel.changeCOTypeToCashSale();
                        } else if (!$scope.CustomerOrderModel.isSwitchToCashSale) {
                            $scope.CustomerOrderModel.addCustomerToCO();
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.isSOLIExist = function() {
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOGridItems.length > 0) {
                        return true;
                    }
                }
                return false;
            }
            $scope.CustomerOrderModel.closeSwitchCOConfirmModal = function(isSwitchingAllowed) {
                angular.element('#switchCOConfirm').modal('hide');
                if (isSwitchingAllowed) {
                    if ($scope.CustomerOrderModel.isAddNewCustomer) {
                        setTimeout(function() {
                            $scope.CustomerOrderModel.CreateCustomerFromCO();
                        }, 1000);
                    } else if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                        $scope.CustomerOrderModel.changeCOTypeToCashSale();
                    } else {
                        $scope.CustomerOrderModel.addCustomerToCO();
                    }
                }
            }
            $scope.CustomerOrderModel.addCustomerToCO = function() {
                CustomerInfoService.removeCustomer($scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.result.originalObject["Value"]).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.Customer = {
                        Name: $scope.CustomerOrderModel.result["title"],
                        Value: $scope.CustomerOrderModel.result.originalObject["Value"]
                    }
                    $scope.CustomerOrderModel.coHeaderDetails = successfulSearchResult.coHeaderRec;
                    $scope.CustomerOrderModel.CardInfo = successfulSearchResult.CardInfo;
                    $scope.CustomerOrderModel.UpdateMerchandiseFromSearchResult(successfulSearchResult, false);
                    $scope.CustomerOrderModel.COUList = successfulSearchResult.COUList;
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    var scrollInfoSection = 'scrollInfoSection';
                    $scope.CustomerOrderModel.loadSODetails(scrollInfoSection);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                    $scope.CustomerOrderModel.isrefresh = false;
                });
            }
            $scope.CustomerOrderModel.verifySwitchingConditions = function() {
                if ($scope.CustomerOrderModel.isSwitchToCashSale && $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    Notification.error($Label.Switching_is_not_allowed_since_Customer_Order_is_Closed);
                    return false;
                }
                if ($scope.CustomerOrderModel.InvoiceHistory.length > 0) {
                    if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                        Notification.error($Label.Co_Type_Switching_After_Invoicing_Error_Message);
                    } else {
                        Notification.error($Label.Changing_Customer_After_Invoicing_Error_Message);
                    }
                    return false;
                }
                if ($scope.CustomerOrderModel.Payment.length > 0) {
                    if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                        Notification.error($Label.Co_Type_Switching_With_Active_Payment_Error_Message);
                    } else {
                        Notification.error($Label.Changing_Customer_With_Active_Payment_Error_Message);
                    }
                    return false;
                }
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus != undefined && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus != null && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus != '' && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Complete') {
                        Notification.error($Label.Cannot_Change_Customer_With_Service_Job_Completed_Error_Message);
                        return false;
                    }
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.COType == 'Customer') {
                    var totalDeposits = 0;
                    for (var i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                        if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                            totalDeposits += $scope.CustomerOrderModel.Deposits[i].Amount;
                        }
                    }
                    if (totalDeposits != 0) {
                        if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                            Notification.error($Label.Co_Type_Switching_With_Unused_Deposits_Error_Message);
                        } else {
                            Notification.error($Label.Changing_Customer_With_Unused_Deposits_Error_Message);
                        }
                        return false;
                    }
                }
                if ($scope.CustomerOrderModel.isSwitchToCashSale) {
                    if ($scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo != null && $scope.CustomerOrderModel.DealInfo.Id != undefined && $scope.CustomerOrderModel.DealInfo.Id != null) {
                        Notification.error($Label.CustomerOrder_Js_Can_not_switch_to_cash);
                        return false;
                    }
                    if ($scope.CustomerOrderModel.SOHeaderList.length > 0) {
                        Notification.error($Label.Co_Type_Switching_With_Service_Order_Error_Message);
                        return false;
                    }
                    if ($scope.CustomerOrderModel.SpecialOrder.length > 0) {
                        Notification.error($Label.Co_Type_Switching_With_Special_Order_Error_Message);
                        return false;
                    }
                    for (var i = 0; i < $scope.CustomerOrderModel.MerchandiseItems.length; i++) {
                        for (var item = 0; item < $scope.CustomerOrderModel.MerchandiseItems[i].COLIList.length; item++) {
                            if ($scope.CustomerOrderModel.MerchandiseItems[i].COLIList[item].Status == 'RETURN') {
                                Notification.error($Label.Co_Type_Switching_With_Return_Line_Items_Error_Message);
                                return false;
                            }
                        }
                    }
                }
                return true;
            }
            $scope.CustomerOrderModel.changeCOTypeToCashSale = function() {
                CustomerInfoService.removeCustomer($scope.CustomerOrderModel.coHeaderId, null).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.coHeaderDetails = successfulSearchResult.coHeaderRec;
                    $scope.CustomerOrderModel.IsTaxIncludingPricing = successfulSearchResult.IsTaxIncludingPricing;
                    $scope.CustomerOrderModel.IsLoadFinancingSection = successfulSearchResult.IsLoadFinancingSection;
                    if ($scope.CustomerOrderModel.IsLoadFinancingSection) {
                        $scope.CustomerOrderModel.DealType = [{
                            Value: 'Cash Deal'
                        }, {
                            Value: 'Financed'
                        }];
                    } else {
                        $scope.CustomerOrderModel.DealType = [{
                            Value: 'Cash Deal'
                        }];
                    }
                    $scope.CustomerOrderModel.StampDutyRate = successfulSearchResult.StampDutyRate;
                    $scope.CustomerOrderModel.CardInfo = successfulSearchResult.CardInfo;
                    $scope.setAllData(successfulSearchResult);
                    $scope.ShowContent = true;
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                    $scope.CustomerOrderModel.isrefresh = false;
                });
            }
            $scope.ViewCustomer.saveCustomer = function(result) {
                if (result.Id.length == 18) {
                    result.Id = result.Id.substring(0, 15);
                }
                if ($scope.CustomerOrderModel.Customer.Value.length == 18) {
                    $scope.CustomerOrderModel.Customer.Value = $scope.CustomerOrderModel.Customer.Value.substring(0, 15);
                }
                if ($scope.CustomerOrderModel.Customer.Value == result.Id) {
                    var customerId = $scope.CustomerOrderModel.Customer.Value;
                    CustomerInfoService.customerInfo(customerId).then(function(customerRecord) {
                        $scope.CustomerOrderModel.CustomerData = angular.copy(customerRecord[0]);
                        $scope.CustomerOrderModel.setPreffered(customerRecord[0]);
                    })
                }
            }
            $scope.CustomerOrderModel.isSearchToAddVisible = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails != undefined && $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return false;
                } else if ($scope.CustomerOrderModel.SelectedSection.relatedSection.indexOf('ServiceOrderSection') != -1) {
                    var soIndex = parseInt($scope.CustomerOrderModel.SelectedSection.relatedSection.replace('ServiceOrderSection', ''));
                    if ($scope.CustomerOrderModel.SOHeaderList[soIndex] != undefined && ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out') || (!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                        return false;
                    }
                } else if ($scope.CustomerOrderModel.SelectedSection.relatedSection.indexOf('DealFinancingSection') != -1) {
                    if ($scope.CustomerOrderModel.DealFinanceList.FinanceCompanyId == null || $scope.CustomerOrderModel.DealFinanceList.Status == 'Approved' || $scope.CustomerOrderModel.DealFinanceList.Status == 'Paid') {
                        return false;
                    } else {
                        return true;
                    }
                } else if ($scope.CustomerOrderModel.SelectedSection.relatedSection.indexOf('DealSection') != -1) {
                    if ($scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                        return false;
                    }
                } else if ($scope.CustomerOrderModel.SelectedSection.relatedSection.indexOf('DealMerchandiseSection') != -1 && !($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                    return false;
                } else if ($scope.CustomerOrderModel.SelectedSection.relatedSection.indexOf('MerchandiseSection') != -1 && !($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                    return false;
                }
                return true;
            }
            $scope.getSectionToMove = function(sectionId) {
                return function(SectionList) {
                    return SectionList.Id != sectionId;
                }
            }
            $scope.CustomerOrderModel.showInfoOverlay = function(event, custId) {
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element('.Customer-info-overlay').css('top', targetEle.offset().top - 45);
                angular.element('.Customer-info-overlay').css('left', event.clientX);
                angular.element('.Customer-info-overlay').show();
            }
            $scope.CustomerOrderModel.hideCustomerInfoOverlay = function() {
                angular.element('.Customer-info-overlay').hide();
            }
            $scope.CustomerOrderModel.EditCustomerOverLay = function() {
                var idParams = {
                    Id: $scope.CustomerOrderModel.Customer.Value
                };
                loadState($state, 'CustomerOrder.EditCustomer', {
                    EditCustomerParams: idParams
                })
            }
            $scope.CustomerOrderModel.createKit = function() {
                $scope.$broadcast('AddKitEvent');
            }
            $scope.CustomerOrderModel.openAddCustomerOwnedUnitPopup = function(event, SoHeaderIndex, TradeIN) {
                event.stopPropagation();
                $scope.CustomerOrderModel.currentSOHeaderIndexForCOU = SoHeaderIndex;
                $scope.CustomerOrderModel.TradeInSaveCOUResult = TradeIN;
                $scope.$broadcast('AddCustomerOwnedUnitEvent', {
                    customerId: $scope.CustomerOrderModel.Customer.Value
                });
                var AddEditUnit_Json = {
                    customerId: $scope.CustomerOrderModel.Customer.Value
                };
                loadState($state, 'CustomerOrder.AddEditUnit', {
                    AddEditUnitParams: AddEditUnit_Json
                });
            }
            $scope.loadDataFromCOU = function(COUId) {
                if ($scope.CustomerOrderModel.TradeInSaveCOUResult != undefined) {
                    DealService.getCOUListByCustomerId($scope.CustomerOrderModel.Customer.Value).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.COUList = successfulSearchResult;
                        $scope.CustomerOrderModel.setTradeInCurrentCOU(COUId, $scope.CustomerOrderModel.currentSOHeaderIndexForCOU);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                    $scope.LoadCustomerOrder();
                } else {
                    $scope.LoadCustomerOrder();
                    setTimeout(function() {
                        $scope.CustomerOrderModel.setCurrentCOU(COUId, $scope.CustomerOrderModel.currentSOHeaderIndexForCOU);
                    }, 7000);
                }
            }
            $scope.loadData = function() {
                $scope.LoadCustomerOrder();
            }
            $scope.CustomerOrderModel.createLogHoursPopup = function(soHeaderId, index) {
                if ((!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                var coHeaderId = $scope.CustomerOrderModel.coHeaderId;
                var logHourObject = {};
                logHourObject.SOHeaderId = soHeaderId;
                var days = 0;
                var hour = 0;
                var minute = 0;
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList[index].HoursLoggedList.length; i++) {
                    days += $scope.CustomerOrderModel.SOHeaderList[index].HoursLoggedList[i].TimeSpent_D;
                    hour += $scope.CustomerOrderModel.SOHeaderList[index].HoursLoggedList[i].TimeSpent_H;
                    minute += $scope.CustomerOrderModel.SOHeaderList[index].HoursLoggedList[i].TimeSpent_M;
                }
                if (minute > 59) {
                    hour += Math.floor(minute / 60);
                    minute = minute - (60 * (Math.floor(minute / 60)));
                }
                if (hour > 23) {
                    days += Math.floor(hour / 24);
                    hour = hour - (24 * (Math.floor(hour / 24)));
                }
                var PreviouslyLogged = days + 'd ' + hour + 'h ' + minute + 'm';
                logHourObject.PreviouslyLogged = PreviouslyLogged;
                var totalSec = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.EstimatedHours * 3600;
                var days = parseInt(totalSec / 86400, 10);
                var hours = parseInt(totalSec / 3600) % 24;
                var minutes = parseInt(totalSec / 60) % 60;
                var OriginalEstimate = days + "d " + hours + "h " + minutes + "m ";
                logHourObject.OriginalEstimate = OriginalEstimate;
                var HourlogParams = {
                    logHourObject: logHourObject,
                    coHeaderId: coHeaderId,
                    index: index
                };
                loadState($state, 'CustomerOrder.HourlogPopup', {
                    HourlogParams: HourlogParams
                });
            }
            $scope.logHourRecordSaveCallback = function(hourLogList, index) {
                $scope.CustomerOrderModel.SOHeaderList[index].HoursLoggedList = hourLogList;
                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus = hourLogList[0].SOHeaderStatus;
                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status = hourLogList[0].Status;
                $scope.CustomerOrderModel.createHoursLoggedGridEditItem(null);
                $scope.CustomerOrderModel.showGridsInServiceSection('ShowHoursLoggedGrid', index, 'ServiceHLSection');
            }
            $scope.ViewCustomer = {};
            $scope.COUModal = {};
            $scope.ViewCustomer.SaveCustomerOwnedUnitsToserver = function(selectedCOURecords) {
                SOHeaderService.saveCOU(selectedCOURecords, $scope.CustomerOrderModel.Customer.Value).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.COUList = successfulSearchResult.COUList;
                    if ($scope.CustomerOrderModel.COUList.length == 1) {
                        $scope.CustomerOrderModel.setCurrentCOU($scope.CustomerOrderModel.COUList[0].Id, $scope.CustomerOrderModel.currentSOHeaderIndexForCOU);
                    }
                    if (angular.element('#AddNewCOU') != null) {
                        angular.element('#AddNewCOU').modal('hide');
                    }
                    Notification.success($Label.Generic_Saved);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                });
            }
            $scope.CustomerOrderModel.openCOActionPopup = function() {
                angular.element('#coaction').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }
            $scope.CustomerOrderModel.RemoveCustomerOverLay = function() {
                CustomerInfoService.removeCustomer($scope.CustomerOrderModel.coHeaderId, null).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.Customer = {};
                    $scope.CustomerOrderModel.MerchandiseItems = successfulSearchResult.COKHList;
                    $scope.CustomerOrderModel.COUList = successfulSearchResult.COUList;
                    $scope.CustomerOrderModel.MerchandiseItems_editRow = [];
                    for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems.length; i++) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow.push({
                            isEdit: false,
                            MoveTosection: ''
                        });
                    }
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $('.Customer-info-overlay').hide();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                });
            }
            $scope.CustomerOrderModel.OpenModal = function() {
                $scope.CustomerOrderModel.ChangeRecords = 2;
            }
            $scope.UpdateMerchandiseListonTabOut = function(successfulSearchResult) {
                $scope.CustomerOrderModel.MerchandiseItems = successfulSearchResult.COKHList;
                $scope.CustomerOrderModel.MerchandiseTotal = successfulSearchResult.MerchandiseTotal.toFixed(2);
            }
            $scope.UpdateMerchandiseList = function(successfulSearchResult) {
                if (successfulSearchResult.coHeaderRec != undefined && successfulSearchResult.coHeaderRec != null) {
                    $scope.CustomerOrderModel.coHeaderDetails = successfulSearchResult.coHeaderRec;
                    $scope.CustomerOrderModel.hideMerchandiseSection = successfulSearchResult.coHeaderRec.HideMerchandiseSection;
                }
                $scope.CustomerOrderModel.MerchandiseItems = successfulSearchResult.COKHList;
                $scope.CustomerOrderModel.MerchandiseTotal = successfulSearchResult.MerchandiseTotal.toFixed(2);
                $scope.CustomerOrderModel.MerchandiseItems_editRow = [];
                var HeaderItems = [];
                var rowNumber = 0;
                for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems.length; i++) {
                    if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                        rowNumber++;
                    }
                    HeaderItems.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0,
                        rowNumber: rowNumber,
                        lineItems: [],
                        MoveTosection: ''
                    });
                    for (j = 0; j < $scope.CustomerOrderModel.MerchandiseItems[i].COLIList.length; j++) {
                        rowNumber++;
                        HeaderItems[i].lineItems.push({
                            isEdit: false,
                            radioValue: 0,
                            optionSelected: 0,
                            rowNumber: rowNumber,
                            MoveTosection: ''
                        });
                    }
                    $scope.CustomerOrderModel.MerchandiseItems_editRow = HeaderItems;
                }
                $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
            }
            $scope.CustomerOrderModel.CreateMerchandiseFromCO = function() {
                $rootScope.$broadcast('AddPartEvent');
            }
            $scope.CustomerOrderModel.CreateKitFromCO = function() {
                $rootScope.$broadcast('AddKitEvent');
            }
            $scope.CustomerOrderModel.CreateLabourFromCO = function() {
                $rootScope.$broadcast('AddLabourEvent');
            }
            $scope.CustomerOrderModel.CreateFeeFromCO = function() {
                $rootScope.$broadcast('AddFeeEvent');
            }
            $scope.$on('ReturnCustomer', function(event, args) {
                $scope.CustomerOrderModel.Customer = {
                    Name: args.Name,
                    Value: args.Value
                }
            });
            $scope.CustomerOrderModel.CreateCustomerFromCO = function() {
                $rootScope.$broadcast('AddCustomerEvent', {
                    isOpenFromSelectCustomerCustomer: 'isOpenFromSTA'
                });
            }
            $scope.CustomerOrderModel.UpdateMerchandiseFromSearchResult = function(successfulSearchResult, isMerchandise) {
                $scope.UpdateMerchandiseList(successfulSearchResult);
                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                var COKHLength = $scope.CustomerOrderModel.MerchandiseItems_editRow.length - 1;
                if (COKHLength >= 0 && isMerchandise) {
                    if ($scope.CustomerOrderModel.MerchandiseItems[COKHLength].Id != null) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHLength].isEdit = true;
                    } else {
                        if ($scope.CustomerOrderModel.MerchandiseItems[COKHLength].COLIList[0].IsEnvFee) {
                            COKHLength = ((COKHLength > 0) ? (COKHLength - 1) : COKHLength);
                        }
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHLength].lineItems[0].isEdit = true;
                        $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = $scope.CustomerOrderModel.MerchandiseItems[COKHLength].COLIList[0].QtyCommitted;
                        $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = $scope.CustomerOrderModel.MerchandiseItems[COKHLength].COLIList[0].AvaliablePartsQty;
                    }
                    setTimeout(function() {
                        angular.element('#MerchandiseSection').find('input[type=text]').not('.descEditInput').filter(':visible:first').focus();
                    }, 10);
                }
                $scope.CustomerOrderModel.COInvoiceHeaderId = ((successfulSearchResult.coInvoiceHeaderRec == null) ? ' ' : successfulSearchResult.coInvoiceHeaderRec.COInvoiceHeaderId);
            }
            $scope.CustomerOrderModel.UpdateSpecialOrder = function(specialOrderList) {
                $scope.CustomerOrderModel.SpecialOrder = specialOrderList
                $scope.CustomerOrderModel.SpecialOrder_editRow = [];
                if ($scope.CustomerOrderModel.SpecialOrder != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.SpecialOrder.length; i++) {
                        $scope.CustomerOrderModel.SpecialOrder_editRow.push({
                            isEdit: false
                        });
                    }
                }
                $scope.CustomerOrderModel.specialOrderCallback();
            }
            $scope.CustomerOrderModel.specialOrderCallback = function() {
                var isLineItemChanged = false;
                $scope.CustomerOrderModel.specialOrderCallbackMessage = '';
                var message = '';
                var isLineItemExist = false;
                var isLineItemSame = false;
                var lineItem = {};
                if ($scope.CustomerOrderModel.SPSection == 'Merchandise') {
                    if ($scope.CustomerOrderModel.MerchandiseItems.length > 0) {
                        lineItem = $scope.CustomerOrderModel.MerchandiseItems[$scope.CustomerOrderModel.SPSecondIndex].COLIList[$scope.CustomerOrderModel.SPThirdIndex];
                        if ($scope.CustomerOrderModel.SPLineItem.Qty == lineItem.Qty && $scope.CustomerOrderModel.SPLineItem.QtyCommitted == lineItem.QtyCommitted) {
                            isLineItemSame = true;
                        }
                    }
                } else if ($scope.CustomerOrderModel.SPSection == 'Service') {
                    lineItem = $scope.CustomerOrderModel.SOHeaderList[$scope.CustomerOrderModel.SPFirstIndex].SOGridItems[$scope.CustomerOrderModel.SPSecondIndex].SOKH.SOLIList[$scope.CustomerOrderModel.SPThirdIndex];
                    if ($scope.CustomerOrderModel.SPLineItem.QtyNeeded == lineItem.QtyNeeded && $scope.CustomerOrderModel.SPLineItem.StockCommited == lineItem.StockCommited) {
                        isLineItemSame = true;
                    }
                }
                if (isLineItemSame) {
                    $scope.CustomerOrderModel.SPSection = '';
                    return;
                }
                if ($scope.CustomerOrderModel.SPSection == 'Merchandise' || $scope.CustomerOrderModel.SPSection == 'DealMerchandise' || $scope.CustomerOrderModel.SPSection == 'Service') {
                    if ($scope.CustomerOrderModel.SPLineItem.POStatus != 'On Order') {
                        console.warn('On Order');
                        for (var i = 0; i < $scope.CustomerOrderModel.SpecialOrder.length; i++) {
                            if ($scope.CustomerOrderModel.SPLineItem.CoLineItemId == $scope.CustomerOrderModel.SpecialOrder[i].COLineItemId) {
                                isLineItemExist = true;
                                if ($scope.CustomerOrderModel.SPLineItem.QtyOrder != $scope.CustomerOrderModel.SpecialOrder[i].QtyNeeded) {
                                    message = $Label.Your_changes_modified_the_existing_vendor_order;
                                    isLineItemChanged = true;
                                    break;
                                }
                            }
                        }
                        if (!isLineItemExist) {
                            message = $Label.Your_changes_modified_the_existing_vendor_order;
                            isLineItemChanged = true;
                        }
                    }
                    if ($scope.CustomerOrderModel.SPLineItem.POStatus == 'On Order') {
                        for (var i = 0; i < $scope.CustomerOrderModel.SpecialOrder.length; i++) {
                            if ($scope.CustomerOrderModel.SPLineItem.CoLineItemId == $scope.CustomerOrderModel.SpecialOrder[i].COLineItemId) {
                                isLineItemExist = true;
                                if ($scope.CustomerOrderModel.SPLineItem.QtyOrder > $scope.CustomerOrderModel.SpecialOrder[i].QtyNeeded) {
                                    message = $Label.Your_changes_modified_the_existing_vendor_order_to_allocate_the_ordered_items_as;
                                    isLineItemChanged = true;
                                    break;
                                } else if ($scope.CustomerOrderModel.SPLineItem.QtyOrder < $scope.CustomerOrderModel.SpecialOrder[i].QtyNeeded) {
                                    message = $Label.Your_changes_NOT_modified_the_existing_vendor_order + '' + $Label.The_addition_items_needed_will_have_to_be_ordered_separately;
                                    isLineItemChanged = true;
                                    break;
                                }
                            }
                        }
                        if (!isLineItemExist) {
                            console.warn(3);
                            message = $Label.Your_changes_modified_the_existing_vendor_order_to_allocate_the_ordered_items_as;
                            isLineItemChanged = true;
                        }
                    }
                }
                $scope.CustomerOrderModel.specialOrderCallbackMessage = message;
                if (isLineItemChanged) {
                    angular.element('#SpecialOrderCallbackPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }
            }
            $scope.CustomerOrderModel.hideSpecialOrderCallbackPopup = function() {
                $scope.CustomerOrderModel.SPSection = '';
                angular.element('#SpecialOrderCallbackPopup').modal('hide');
            }
            $scope.UpdateDepositsList = function(depositsList) {
                $scope.CustomerOrderModel.Deposits = depositsList;
                $scope.CustomerOrderModel.Deposits_editRow = [];
                if ($scope.CustomerOrderModel.Deposits != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                        $scope.CustomerOrderModel.Deposits_editRow.push({
                            isEdit: false,
                            radioValue: 0
                        });
                    }
                }
                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
            }
            $scope.CustomerOrderModel.closeCreateDropDown = function() {
                angular.element(".customDropdownDiv").removeClass("open");
            }
            $scope.CustomerOrderModel.selectedOption = 'Please Select';
            $scope.CustomerOrderModel.optionSelected = function(optionValue, e) {
                $scope.CustomerOrderModel.deposit_method = optionValue;
                $scope.CustomerOrderModel.selectedOption = optionValue;
                if ($scope.CustomerOrderModel.isRefundDepositBtnClicked == false) {
                    $scope.CustomerOrderModel.deposit_Amount = '';
                } else {
                    $scope.CustomerOrderModel.deposit_Amount = ($scope.CustomerOrderModel.calculateLeftPanelDeposits() > 0) ? $scope.CustomerOrderModel.calculateLeftPanelDeposits() : '';
                }
                angular.element('#depositDropDownDiv').removeClass('open');
                var element = angular.element("#CO_Deposits_block_deposit_header_amount_block_pricebox_input");
                if (e) {
                    e.stopPropagation();
                    e.preventDefault();
                }
                setTimeout(function() {
                    if (element) {
                        element.focus();
                        element.select();
                    }
                }, 100);
            }
            $scope.CustomerOrderModel.addOrRefundDepositOnEnter = function(event) {
                if (($scope.CustomerOrderModel.showHideAddDepositBtn() == true) || ($scope.CustomerOrderModel.isRefundDepositBtnClicked == false && $scope.CustomerOrderModel.selectedOption != 'Please Select' && $scope.CustomerOrderModel.deposit_Amount > 0)) {
                    $scope.CustomerOrderModel.addDeposit();
                } else if ($scope.CustomerOrderModel.Deposits.length > 0 && (($scope.CustomerOrderModel.isRefundDepositBtnClicked == false && $scope.CustomerOrderModel.isPaymentDropdownOpen == false) || ($scope.CustomerOrderModel.isRefundDepositBtnClicked == true && $scope.CustomerOrderModel.selectedOption != 'Please Select' && $scope.CustomerOrderModel.deposit_Amount > 0)) && $scope.CustomerOrderModel.calculateLeftPanelDeposits() > 0) {
                    $scope.CustomerOrderModel.isRefundDepositBtnClicked = true;
                    $scope.CustomerOrderModel.refundDepositBtnClick(event);
                }
            }
            $scope.CustomerOrderModel.refundDepositBtnClick = function(event) {
                if (event) {
                    event.stopPropagation();
                }
                if ($scope.CustomerOrderModel.deposit_Amount > 0) {
                    var deposit = {};
                    deposit.PaymentMethod = $scope.CustomerOrderModel.deposit_method;
                    deposit.Amount = $scope.CustomerOrderModel.deposit_Amount;
                    deposit.CODepositId = null;
                    deposit.Deal = null;
                    $scope.CustomerOrderModel.ReverseDeposit(deposit);
                    $scope.CustomerOrderModel.addDeposit();
                } else {
                    $scope.CustomerOrderModel.selectedOption = 'Please Select';
                    $scope.CustomerOrderModel.isPaymentDropdownOpen = true;
                    $scope.CustomerOrderModel.isRefundDepositBtnClicked = true;
                    setTimeout(function() {
                        angular.element('#depositDropDownDiv').find("li:first").find('a').focus();
                    }, 100);
                }
            }
            $scope.CustomerOrderModel.expandDepositSection = function(event) {
                if (event) {
                    event.stopPropagation();
                }
                $scope.CustomerOrderModel.deposit_Amount = '';
                if (!$rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    $scope.CustomerOrderModel.displaySections.Deposit = false;
                    $scope.CustomerOrderModel.isPaymentDropdownOpen = false;
                } else {
                    $scope.CustomerOrderModel.displaySections.Deposit = true;
                    $scope.CustomerOrderModel.isPaymentDropdownOpen = true;
                }
                setTimeout(function() {
                    angular.element('#depositDropDownDiv').find("li:first").find('a').focus();
                }, 100);
                if (!$rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    $scope.CustomerOrderModel.collapseDepositSection = true;
                } else {
                    $scope.CustomerOrderModel.collapseDepositSection = false;
                }
            }
            $scope.safeApply = function(fn) {
                var phase = this.$root.$$phase;
                if (phase == '$apply' || phase == '$digest') {
                    if (fn && (typeof(fn) === 'function')) {
                        fn();
                    }
                } else {
                    this.$apply(fn);
                }
            };
            $scope.CustomerOrderModel.showHideAddDepositBtn = function() {
                if ($scope.CustomerOrderModel.deposit_Amount > $scope.CustomerOrderModel.calculateLeftPanelDeposits()) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Amount can't be greater than total deposit received";
                    return;
                }
                if ($scope.CustomerOrderModel.isRefundDepositBtnClicked == false && $scope.CustomerOrderModel.selectedOption != 'Please Select' && $scope.CustomerOrderModel.deposit_Amount > 0) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.expandCheckoutSection = function(event) {
                if (event) {
                    event.stopPropagation();
                }
                $scope.CustomerOrderModel.displaySections.Checkout = true;
                $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                $scope.CustomerOrderModel.collapseCheckoutSection = false;
                setTimeout(function() {
                    angular.element('#checkoutDropDownDiv').find("li:first").find('a').focus();
                }, 100);
            }
            $scope.CustomerOrderModel.printInvoiceChkboxClicked = function() {
                if (!(!$scope.CustomerOrderModel.EnableFinaliseInvoice() || $scope.CustomerOrderModel.EnableFinaliseInvoice1())) {
                    $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = !$scope.CustomerOrderModel.enablePrintInvoiceCheckBox;
                    if ($scope.CustomerOrderModel.enableEmailInvoiceCheckBox == true) {
                        $scope.CustomerOrderModel.enableEmailInvoiceCheckBox = !$scope.CustomerOrderModel.enableEmailInvoiceCheckBox;
                    }
                }
            }
            $scope.CustomerOrderModel.emailInvoiceChkboxClicked = function() {
                if ((!(!$scope.CustomerOrderModel.EnableFinaliseInvoice() || $scope.CustomerOrderModel.EnableFinaliseInvoice1()))) {
                    $scope.CustomerOrderModel.enableEmailInvoiceCheckBox = !$scope.CustomerOrderModel.enableEmailInvoiceCheckBox;
                    if ($scope.CustomerOrderModel.enablePrintInvoiceCheckBox == true) {
                        $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = !$scope.CustomerOrderModel.enablePrintInvoiceCheckBox;
                    }
                }
            }
            $scope.CustomerOrderModel.showAmountSaved = function() {
                $scope.CustomerOrderModel.enableshowAmountSavedCheckBox = !$scope.CustomerOrderModel.enableshowAmountSavedCheckBox;
            }
            $scope.CustomerOrderModel.addPaymentBtnClicked = function() {
                $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
                $scope.CustomerOrderModel.cancelPaymentClicked = false;
                $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
                $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                setTimeout(function() {
                    angular.element('#checkoutDropDownDiv').find("li:first").find('a').focus();
                }, 100);
            }
            $scope.CustomerOrderModel.showCancelBtnInCheckout = function() {
                var showCancelBtn = false;
                if ($scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout == true && ($scope.CustomerOrderModel.selectedOptionForCheckout != 'Please Select' || ($scope.CustomerOrderModel.selectedOptionForCheckout == 'Please Select' && $scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment != '' && $scope.CustomerOrderModel.Payment != null && $scope.CustomerOrderModel.Payment.length > 0))) {
                    showCancelBtn = true;
                }
                return showCancelBtn;
            }
            $scope.CustomerOrderModel.refundPaymentBtnClicked = function() {
                $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
                $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
                $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                $scope.CustomerOrderModel.cancelPaymentClicked = false;
                if ($scope.CustomerOrderModel.calculateBalanceDue() != 0) {
                    if ($scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                        $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                        $scope.CustomerOrderModel.isReversePayment = true;
                        angular.element('.refundBtn1').focus();
                    } else if ($scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                        $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                    }
                } else {
                    $scope.CustomerOrderModel.Payment_Amount = '';
                }
                setTimeout(function() {
                    angular.element('#checkoutDropDownDiv').find("li:first").find('a').focus();
                }, 100);
            }
            $scope.CustomerOrderModel.addOrRefundPaymentOnNgEnter = function() {
                if ($scope.CustomerOrderModel.selectedOptionForCheckout == 'Please Select') {
                    Notification.error($Label.CustomerOrder_Js_Payment_method);
                    return;
                }
                if (($scope.CustomerOrderModel.Payment_Amount != 0) && $scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                    $scope.CustomerOrderModel.addPayment();
                } else if (($scope.CustomerOrderModel.Payment_Amount != 0) && $scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                    $scope.CustomerOrderModel.refundCheckoutPayment();
                }
            }
            $scope.CustomerOrderModel.refundCheckoutPayment = function() {
                $scope.CustomerOrderModel.isReversePayment = true;
                $scope.CustomerOrderModel.PaymentReverseLink = null;
                $scope.CustomerOrderModel.Payment_method = $scope.CustomerOrderModel.Payment_method;
                $scope.CustomerOrderModel.addPayment();
            }
            $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
            $scope.CustomerOrderModel.optionSelectedForCheckout = function(optionValue, e) {
                $scope.CustomerOrderModel.Payment_method = optionValue;
                $scope.CustomerOrderModel.selectedOptionForCheckout = optionValue;
                $scope.CustomerOrderModel.cancelPaymentClicked = false;
                if ($scope.CustomerOrderModel.calculateBalanceDue() != 0) {
                    if ($scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                        if ($scope.CustomerOrderModel.Payment_method == 'Use Deposit') {
                            if ((parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed())) > 0) {
                                if (parseFloat($scope.CustomerOrderModel.calculateBalanceDue()) > (parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed()))) {
                                    $scope.CustomerOrderModel.Payment_Amount = (parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed())).toFixed(2);
                                } else {
                                    $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                                }
                            } else {
                                $scope.CustomerOrderModel.Payment_Amount = 0.00;
                            }
                        } else {
                            $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                        }
                        if ($scope.CustomerOrderModel.Payment_Amount == '' || $scope.CustomerOrderModel.Payment_Amount == null) {
                            if ($scope.CustomerOrderModel.Payment_method == 'Use Deposit') {
                                if ((parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed())) > 0) {
                                    if (parseFloat($scope.CustomerOrderModel.calculateBalanceDue()) > (parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed()))) {
                                        $scope.CustomerOrderModel.Payment_Amount = (parseFloat($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal()) - parseFloat($scope.CustomerOrderModel.calculateDepositUsed())).toFixed(2);
                                    }
                                } else {
                                    $scope.CustomerOrderModel.Payment_Amount = 0.00;
                                }
                            } else {
                                $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                            }
                        }
                        if ($scope.CustomerOrderModel.Payment_method == 'Store Credit' && $scope.CustomerOrderModel.coHeaderDetails.CustomerStoreCredit < $scope.CustomerOrderModel.calculateBalanceDue()) {
                            $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.coHeaderDetails.CustomerStoreCredit;
                        }
                    } else {
                        $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                    }
                } else {
                    $scope.CustomerOrderModel.Payment_Amount = '';
                }
                angular.element('#checkoutDropDownDiv').removeClass('open');
                var element = angular.element("#CO_Deposits_block_deposit_header_amount_block_pricebox_input_For_Checkout");
                $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
                if (e) {
                    e.stopPropagation();
                    e.preventDefault();
                }
                setTimeout(function() {
                    if (element) {
                        if ($scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                            element.focus();
                        } else if ($scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                            angular.element('.refundBtn1').focus();
                        }
                    }
                }, 100);
            }
            $scope.CustomerOrderModel.calculateSalesTaxTotalForCheckout = function() {
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var salesTaxAmt = 0;
                $scope.CustomerOrderModel.IsPartReturn = false;
                for (i = 0; i < CheckoutItemList.length; i++) {
                    if (CheckoutItemList[i].IsActive) {
                        salesTaxAmt += CheckoutItemList[i].TaxAmount;
                    }
                }
                return (salesTaxAmt).toFixed(2);
            }
            $scope.CustomerOrderModel.calculateTotalDue = function() {
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var ChekoutAmt = 0;
                $scope.CustomerOrderModel.IsPartReturn = false;
                for (i = 0; i < CheckoutItemList.length; i++) {
                    if (CheckoutItemList[i].IsActive) {
                        if (CheckoutItemList[i].Total < 0) {
                            $scope.CustomerOrderModel.IsPartReturn = true;
                        }
                        if (!$scope.CustomerOrderModel.disableCheckOutItemAddAction(CheckoutItemList[i])) {
                            ChekoutAmt += CheckoutItemList[i].Total;
                        }
                    }
                }
                if (!$scope.CustomerOrderModel.IsTaxIncludingPricing) {
                    var totalTax = 0;
                    if ($scope.CustomerOrderModel.checkoutSalesTaxList != undefined) {
                        for (i = 0; i < $scope.CustomerOrderModel.checkoutSalesTaxList.length; i++) {
                            totalTax += $scope.CustomerOrderModel.checkoutSalesTaxList[i].TaxAmount;
                        }
                    }
                    ChekoutAmt += totalTax;
                }
                return (ChekoutAmt).toFixed(2);
            }
            $scope.UpdatePaymentList = function(PaymentList) {
                $scope.CustomerOrderModel.Payment = PaymentList;
                $scope.CustomerOrderModel.Payments_editRow = [];
                for (i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                    $scope.CustomerOrderModel.Payments_editRow.push({
                        isEdit: false,
                        radioValue: 0
                    });
                    if ($scope.CustomerOrderModel.Payment[i].Amount < 0) {
                        $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = true;
                    }
                }
                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
            }
            $scope.setAllData = function(successfulSearchResult) {
                $scope.CustomerOrderModel.OrderName = successfulSearchResult.coHeaderRec.OrderName;
                $scope.CustomerOrderModel.coHeaderDetails.ModifiedDate = successfulSearchResult.coHeaderRec.ModifiedDate;
                $scope.CustomerOrderModel.coHeaderDetails.OrderStatus = successfulSearchResult.coHeaderRec.OrderStatus;
                orderName = successfulSearchResult.coHeaderRec.OrderName;
                $scope.CustomerOrderModel.CurrentUserLocale = successfulSearchResult.CurrentUserLocale;
                $scope.CustomerOrderModel.Customer = {
                    Name: successfulSearchResult.coHeaderRec.CustomerName,
                    Value: successfulSearchResult.coHeaderRec.CustomerId
                }
                $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                $scope.CustomerOrderModel.COUList = successfulSearchResult.COUList;
                for (var i = 0; i < $scope.CustomerOrderModel.COUList.length; i++) {
                    if ($scope.CustomerOrderModel.COUList[i].Status == 'Transferred') {
                        $scope.CustomerOrderModel.COUList.splice(i, 1);
                        i = i - 1;
                    }
                }
                $scope.CustomerOrderModel.ProviderList = successfulSearchResult.ProviderList;
                $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.specialOrderList;
                $scope.UpdateMerchandiseList(successfulSearchResult);
                $scope.UpdateDepositsList(successfulSearchResult.coDeposits);
                $scope.UpdatePaymentList(successfulSearchResult.coInvoicePaymentRecs);
                $scope.CustomerOrderModel.InvoiceHistory = successfulSearchResult.COInvoiceHistoryRecs;
                $scope.CustomerOrderModel.User = {
                    Name: '',
                    Value: ''
                }
                $scope.CustomerOrderModel.COInvoiceHeaderId = ((successfulSearchResult.coInvoiceHeaderRec == null) ? ' ' : successfulSearchResult.coInvoiceHeaderRec.COInvoiceHeaderId);
                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
            }
            $scope.CustomerOrderModel.loadCOonAdd = function() {
                $scope.LoadCustomerOrder();
            }
            $scope.CustomerOrderModel.refreshCustomerOrder = function() {
                $scope.CustomerOrderModel.isrefresh = true;
                $scope.LoadCustomerOrder();
            }
            $scope.CustomerOrderModel.showDatePicker = function(event) {
                angular.element(event.target).parent().parent().find("input").focus();
            }
            $scope.CustomerOrderModel.showGridsInServiceSection = function(ModelKey, index, sectionName) {
                var sectionName = sectionName + '' + index;
                $scope.CustomerOrderModel.SOHeaderList[index][ModelKey] = true;
                if (ModelKey == 'ShowNotesForCustomer') {
                    setTimeout(function() {
                        angular.element("#txtconcern" + index).focus();
                    }, 100);
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                    }, 1000);
                } else if (ModelKey == 'ShowItemsGrid') {
                    $scope.setFocus1();
                    setTimeout(function() {
                        $scope.setFocus();
                    }, 10);
                } else if (ModelKey == 'ShowScheduleJob') {
                    setTimeout(function() {
                        angular.element("#Scheduled_" + index).focus();
                    }, 100);
                } else {
                    if (ModelKey == 'ShowCauseConcernCorrection') {
                        setTimeout(function() {
                            angular.element("#txtconcern_ManualConcern_" + index).focus();
                        }, 100);
                    }
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                    }, 1000);
                }
            }
            $scope.CustomerOrderModel.openCustomerMileage = function(modelKey, soHeaderIndex, sectionName) {
                var sectionName = sectionName + '' + soHeaderIndex;
                $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex][modelKey] = true;
                setTimeout(function() {
                    $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                }, 1000);
                if ($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOSignInRec.Odometer == 0) {
                    setTimeout(function() {
                        angular.element("#odometerArrivalId" + soHeaderIndex).select();
                    }, 1010);
                } else {
                    setTimeout(function() {
                        angular.element("#odometerDepartureId" + soHeaderIndex).select();
                    }, 1010);
                }
            }
            $scope.CustomerOrderModel.openWorkPicklist = function(modelKey, soHeaderIndex, sectionName) {
                var sectionName = sectionName + '' + soHeaderIndex;
                $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex][modelKey] = true;
                setTimeout(function() {
                    $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                }, 1000);
                if (modelKey == 'hideStatusPicklistValue') {
                    setTimeout(function() {
                        angular.element("#WorkPicklistId" + soHeaderIndex).focus();
                    }, 1010);
                }
            }
            $scope.CustomerOrderModel.openAddAttachmentPopup = function(index) {
                loadState($state, 'CustomerOrder.AddAttachment', {
                    AddAttachmentParams: {
                        soHeaderIndex: index
                    }
                });
            }
            $scope.CustomerOrderModel.attachmentCallback = function(index) {
                if ($scope.CustomerOrderModel.SOHeaderList[index].AttachmentList.length > 0) {
                    var sectionName = 'ServiceAttachmentsSection' + index;
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                    }, 100);
                }
            }

            function getUrlVars() {
                var vars = {};
                var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value) {
                    vars[key] = value;
                });
                return vars;
            }
            $scope.LoadCustomerOrder = function() {
                if ($scope.CustomerOrderModel.CashPaymentRoundingCentValue == null || $scope.CustomerOrderModel.CashPaymentRoundingCentValue == "" || $scope.CustomerOrderModel.CashPaymentRoundingCentValue == undefined) {
                    $scope.CustomerOrderModel.CashPaymentRoundingCentValue = 1;
                }
                $scope.CustomerOrderModel.CashPaymentRoundingCentValue = parseInt($scope.CustomerOrderModel.CashPaymentRoundingCentValue);
                $scope.loading = false;
                if ($scope.CustomerOrderModel.coHeaderId == null || $scope.CustomerOrderModel.coHeaderId == undefined) {
                    $scope.CustomerOrderModel.coHeaderId = $stateParams.Id;
                }
                if ($stateParams.myParams != undefined && $stateParams.myParams.coliId != undefined) {
                    $scope.CustomerOrderModel.editColiId = $stateParams.myParams.coliId;
                }
                if ($scope.CustomerOrderModel.coHeaderId == null) {
                    $scope.CustomerOrderModel.coHeaderDetails = {};
                    $scope.CustomerOrderModel.InvoiceHistory = {};
                    $scope.CustomerOrderModel.CustomerInfo = [];
                    $scope.CustomerOrderModel.CheckOutItems = [];
                    $scope.CustomerOrderModel.Payment = [];
                    $scope.CustomerOrderModel.Deposits = [];
                    $scope.CustomerOrderModel.MerchandiseItems = [];
                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                    $scope.CustomerOrderModel.serviceOrderList = [];
                    $scope.CustomerOrderModel.AllSectionList = [];
                    $scope.CustomerOrderModel.SOHeaderList = [];
                    $scope.CustomerOrderModel.SectionList = [];
                    $scope.CustomerOrderModel.VendorOrderListByVendorId = [];
                    $scope.CustomerOrderModel.Customer = {};
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow = [];
                    $scope.CustomerOrderModel.NotesForCustomer_editRow = [];
                    $scope.WizardModel.CauseConcernCorrectionItems_editRow = [];
                    $scope.CustomerOrderModel.FactoryItems_editRow = [];
                    $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow = [];
                    $scope.CustomerOrderModel.OptionFeesItems_editRow = [];
                    $scope.CustomerOrderModel.DealMerchandiseItems_editRow = [];
                    $scope.CustomerOrderModel.showEditUnresolvedFulfillmentSection = false;
                    $timeout(function() {
                        $scope.CustomerOrderModel.setKeyWordInSTA();
                    }, 10);
                    $scope.showLoading = false;
                } else {
                    CustomerInfoService.getCOHeaderDetails($scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.coHeaderDetails = successfulSearchResult.coHeaderRec;
                        $scope.CustomerOrderModel.hideMerchandiseSection = successfulSearchResult.coHeaderRec.HideMerchandiseSection;
                        $scope.CustomerOrderModel.IsTaxIncludingPricing = successfulSearchResult.IsTaxIncludingPricing;
                        $scope.CustomerOrderModel.IsLoadFinancingSection = successfulSearchResult.IsLoadFinancingSection;
                        if ($scope.CustomerOrderModel.IsLoadFinancingSection) {
                            $scope.CustomerOrderModel.DealType = [{
                                Value: 'Cash Deal'
                            }, {
                                Value: 'Financed'
                            }];
                        } else {
                            $scope.CustomerOrderModel.DealType = [{
                                Value: 'Cash Deal'
                            }];
                        }
                        $scope.CustomerOrderModel.StampDutyRate = successfulSearchResult.StampDutyRate;
                        $scope.CustomerOrderModel.CardInfo = successfulSearchResult.CardInfo;
                        if (successfulSearchResult.coDeposits != undefined && successfulSearchResult.coDeposits != '' && successfulSearchResult.coDeposits != null && successfulSearchResult.coDeposits.length > 0 && $rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                            $scope.CustomerOrderModel.collapseDepositSection = false;
                        }
                        if (successfulSearchResult.coInvoicePaymentRecs != undefined && successfulSearchResult.coInvoicePaymentRecs != '' && successfulSearchResult.coInvoicePaymentRecs != null && successfulSearchResult.coInvoicePaymentRecs.length > 0 && $rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                            $scope.CustomerOrderModel.collapseCheckoutSection = false;
                        }
                        $scope.setAllData(successfulSearchResult);
                        $scope.showLoading = false;
                        $scope.ShowContent = true;
                        var custId = $scope.CustomerOrderModel.Customer.Value;
                        if (custId != null) {
                            CustomerInfoService.customerInfo(custId).then(function(customerRecord) {
                                if (customerRecord.length > 0) {
                                    $scope.CustomerOrderModel.CustomerData = angular.copy(customerRecord[0]);
                                    $scope.CustomerOrderModel.setPreffered(customerRecord[0]);
                                }
                            });
                        }
                        $scope.$watch('CustomerOrderModel.Customer.Name', function(newVal, oldVal) {
                            if (newVal != oldVal) {
                                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                                    if ($scope.CustomerOrderModel.COUList != undefined && $scope.CustomerOrderModel.COUList.length > 0) {
                                        $scope.CustomerOrderModel.setCurrentCOU($scope.CustomerOrderModel.COUList[0].Id, i);
                                    }
                                }
                                if ($scope.CustomerOrderModel.COUList.length == 0 && $scope.CustomerOrderModel.SOHeaderList != undefined) {
                                    for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                                        $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.selectedCOU = {}
                                        $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.selectedProvider = {};
                                    }
                                }
                                if ($scope.CustomerOrderModel.Customer.Value == null || $scope.CustomerOrderModel.Customer.Value == "") {
                                    return;
                                }
                                CustomerInfoService.customerInfo($scope.CustomerOrderModel.Customer.Value).then(function(customerRecord) {
                                    if (customerRecord.length > 0) {
                                        $scope.CustomerOrderModel.CustomerData = angular.copy(customerRecord[0]);
                                        $scope.CustomerOrderModel.setPreffered(customerRecord[0]);
                                    }
                                });
                            }
                        });
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        Notification.error($Label.Generic_Error);
                        $scope.CustomerOrderModel.isrefresh = false;
                    });
                    $scope.CustomerOrderModel.LoadServiceOrder();
                }
            }
            $scope.$watch('CustomerOrderModel.MasterData.TTList', function(newVal, oldVal) {
                if (newVal != oldVal && newVal != undefined) {
                    $scope.CustomerOrderModel.MasterData.TTOptionsWithDealList = [];
                    $scope.CustomerOrderModel.MasterData.TTOptionsList = [];
                    $scope.CustomerOrderModel.MasterData.TTOptionsWithQuoteList = [];
                    for (var i = 0; i < newVal.length; i++) {
                        if (newVal[i].CodeLabel == 'Internal Expense') {
                            if ($rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] || $scope.CustomerOrderModel.coHeaderDetails.COType === 'Internal Service') {
                                $scope.CustomerOrderModel.MasterData.TTOptionsList.push(newVal[i]);
                                $scope.CustomerOrderModel.MasterData.TTOptionsWithQuoteList.push(newVal[i]);
                            }
                        } else {
                            if (newVal[i].CodeLabel != 'Deal') {
                                if (newVal[i].CodeLabel != 'Quote') {
                                    $scope.CustomerOrderModel.MasterData.TTOptionsList.push(newVal[i]);
                                }
                                $scope.CustomerOrderModel.MasterData.TTOptionsWithQuoteList.push(newVal[i]);
                            } else {
                                $scope.CustomerOrderModel.MasterData.TTOptionsWithDealList.push(newVal[i]);
                            }
                        }
                    }
                }
            });
            $scope.CustomerOrderModel.ReturnCustomerDetails = function(CustomerId, CustomerName, coHeaderId) {
                $scope.CustomerOrderModel.Customer.Value = CustomerId;
                $scope.CustomerOrderModel.Customer.Name = CustomerName;
                $scope.CustomerOrderModel.coHeaderId = coHeaderId;
            }
            $scope.bindCheckOutList = function(coInvoiceItemRecs) {
                $scope.CustomerOrderModel.isDealCheckoutActive = false;
                $scope.CustomerOrderModel.CheckOutItems = [];
                $scope.CustomerOrderModel.TotalDiscountAmount = 0;
                $scope.CustomerOrderModel.enableshowAmountSavedCheckBox = false;
                var flag = false;
                if (coInvoiceItemRecs != undefined) {
                    for (i = 0; i < coInvoiceItemRecs.length; i++) {
                        if (coInvoiceItemRecs[i].IsFinalizable && coInvoiceItemRecs[i].IsActive) {
                            flag = true;
                        }
                        if (coInvoiceItemRecs[i].COLineItemId != null) {
                            $scope.CustomerOrderModel.CheckOutItems.push(coInvoiceItemRecs[i]);
                        } else {
                            if (coInvoiceItemRecs[i].IsFinalizable && coInvoiceItemRecs[i].IsActive) {
                                if (coInvoiceItemRecs[i].CheckoutType === 'Customer' && !coInvoiceItemRecs[i].DealId && !coInvoiceItemRecs[i].SOStatus && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) { // Source Section: Merchandise && Merchandise>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Customer' && !coInvoiceItemRecs[i].DealId && coInvoiceItemRecs[i].SOStatus && $rootScope.GroupOnlyPermissions['Service job']['create/modify']) { // Source Section: Service job && Service job>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Internal' && $rootScope.GroupOnlyPermissions['Internal Service']['create/modify']) { // Source Section: Service job (type=interna) && Internal Service>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Customer' && coInvoiceItemRecs[i].DealId && $rootScope.GroupOnlyPermissions['Deal']['create/modify']) { // Source Section: Deal && Deal>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Deal' && !coInvoiceItemRecs[i].SOStatus && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) { // Source Section: Deal Merchandise && Merchandise>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Deal' && coInvoiceItemRecs[i].SOStatus && $rootScope.GroupOnlyPermissions['Service job']['create/modify']) { // Source Section: Deal Service && Service job>create/modify true
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else if (coInvoiceItemRecs[i].CheckoutType === 'Third-Party' && !isBlankValue(coInvoiceItemRecs[i].DealFinanceId)) {
                                    coInvoiceItemRecs[i].IsActive = true;
                                } else {
                                    coInvoiceItemRecs[i].IsActive = false;
                                }
                            } else {
                                coInvoiceItemRecs[i].IsActive = false;
                            }
                            $scope.CustomerOrderModel.CheckOutItems.push(coInvoiceItemRecs[i]);
                        }
                        if (coInvoiceItemRecs[i].DealId) {
                            if ($scope.CustomerOrderModel.DealDepositList != undefined) {
                                $scope.CustomerOrderModel.dealDepositeTotal = 0;
                                for (var j = 0; j < $scope.CustomerOrderModel.DealDepositList.length; j++) {
                                    $scope.CustomerOrderModel.dealDepositeTotal += $scope.CustomerOrderModel.DealDepositList[j].Amount;
                                }
                            }
                            if (coInvoiceItemRecs[i].DealFinanceId) {
                                var coInvoiceItemRecsTotal = ($scope.CustomerOrderModel.DealSummaryObj.Total + $scope.CustomerOrderModel.calculateFIProductTotal() - (!isBlankValue($scope.CustomerOrderModel.DealFinanceList) ? $scope.CustomerOrderModel.DealFinanceList.DownPayment : 0)).toFixed(2);
                                if (!$scope.CustomerOrderModel.IsTaxIncludingPricing) {
                                    coInvoiceItemRecsTotal -= coInvoiceItemRecs[i].TaxAmount;
                                }
                                coInvoiceItemRecs[i].Total = parseFloat(coInvoiceItemRecsTotal);
                            } else {
                                if (coInvoiceItemRecs[i].IsActive && coInvoiceItemRecs[i].IsFinalizable) {
                                    $scope.CustomerOrderModel.isDealCheckoutActive = true;
                                }
                            }
                        }
                        if (coInvoiceItemRecs[i].IsActive && coInvoiceItemRecs[i].DiscountAmount > 0) {
                            $scope.CustomerOrderModel.TotalDiscountAmount += coInvoiceItemRecs[i].DiscountAmount;
                        }
                    }
                    if (flag == true) {
                        $scope.CustomerOrderModel.isPrintInvoiceBtnVisible = true;
                    } else {
                        $scope.CustomerOrderModel.isPrintInvoiceBtnVisible = false;
                    }
                }
                if ($scope.CustomerOrderModel.TotalDiscountAmount > 0) {
                    $scope.CustomerOrderModel.enableshowAmountSavedCheckBox = true;
                }
                var inStockItemAvailable = false;
                var activeStockItemAvailable = false;
                for (i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                    if ($scope.CustomerOrderModel.CheckOutItems[i].IsInvoiceable == true) {
                        inStockItemAvailable = true;
                    }
                    if ($scope.CustomerOrderModel.CheckOutItems[i].IsInvoiceable && $scope.CustomerOrderModel.CheckOutItems[i].IsActive) {
                        activeStockItemAvailable = true;
                    }
                }
                if (inStockItemAvailable || ($scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment != '' && $scope.CustomerOrderModel.Payment != null && $scope.CustomerOrderModel.Payment.length > 0)) {
                    $scope.CustomerOrderModel.showCheckoutSection = true;
                } else {
                    $scope.CustomerOrderModel.showCheckoutSection = false;
                }
                if ($scope.CustomerOrderModel.Payment == undefined || $scope.CustomerOrderModel.Payment == '' || $scope.CustomerOrderModel.Payment == null || $scope.CustomerOrderModel.Payment.length <= 0) {
                    $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                    $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
                } else {
                    if ($scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment.length > 0) {
                        for (var i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                            if ($scope.CustomerOrderModel.Payment[i].Amount < 0) {
                                $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = true;
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.calculateBalanceDue() != 0) {
                        if ($scope.CustomerOrderModel.displayAddPaymentBtnForCheckout == false && $scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                            $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                        } else {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                            $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
                        }
                    }
                }
                if ($scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                    $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                    $scope.CustomerOrderModel.isReversePayment = true;
                }
                if (($scope.CustomerOrderModel.calculateBalanceDue() == 0) && !(!$scope.CustomerOrderModel.EnableFinaliseInvoice() || $scope.CustomerOrderModel.EnableFinaliseInvoice1())) {
                    $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = true;
                }
                $scope.CustomerOrderModel.Payment_Amount = $scope.CustomerOrderModel.calculateBalanceDue();
                $scope.CustomerOrderModel.getCheckoutTax();
                $scope.CustomerOrderModel.sortCheckout();
            }
            $scope.CustomerOrderModel.disableCheckOutItemAddAction = function(checkOutItem) {
                if (checkOutItem.CheckoutType === 'Customer' && !checkOutItem.DealId && !checkOutItem.SOStatus && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) { // Source Section: Merchandise && Merchandise>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Customer' && !checkOutItem.DealId && checkOutItem.SOStatus && $rootScope.GroupOnlyPermissions['Service job']['create/modify']) { // Source Section: Service job && Service job>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Internal' && $rootScope.GroupOnlyPermissions['Internal Service']['create/modify']) { // Source Section: Service job (type=interna) && Internal Service>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Customer' && checkOutItem.DealId && $rootScope.GroupOnlyPermissions['Deal']['create/modify']) { // Source Section: Deal && Deal>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Deal' && !checkOutItem.SOStatus && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) { // Source Section: Deal Merchandise && Merchandise>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Deal' && checkOutItem.SOStatus && $rootScope.GroupOnlyPermissions['Service job']['create/modify']) { // Source Section: Deal Service && Service job>create/modify true
                    return false;
                } else if (checkOutItem.CheckoutType === 'Third-Party' && !isBlankValue(checkOutItem.DealFinanceId)) {
                    return false;
                } else {
                    return true;
                }
            }
            $scope.CustomerOrderModel.displayCODepositeSection = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Quote' && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deposits') > -1 && !($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' && $scope.CustomerOrderModel.Deposits.length == 0) && ((($scope.CustomerOrderModel.MerchandiseItems.length > 0 || $scope.CustomerOrderModel.MerchandiseGhostItems.length > 0) && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Merchandise') > -1) || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Cash Sale' || $scope.CustomerOrderModel.showDepositeSection())) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.isPartOrLabour_Deal_OptionFeeLI = function(OptionAndFeeLineItem) {
                if ((OptionAndFeeLineItem.LabourId != null && OptionAndFeeLineItem.LabourId != '') || (OptionAndFeeLineItem.PartId != null && OptionAndFeeLineItem.PartId != '')) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.changeCheckoutMode = function(mode) {
                if ($scope.CustomerOrderModel.calculatePaymentTotal() != 0) {
                    Notification.error($Label.CustomerOrder_Js_checkout_mode);
                    return;
                }
                if (mode == undefined) {
                    $scope.CustomerOrderModel.checkOutMode = 'Customer';
                } else {
                    $scope.CustomerOrderModel.checkOutMode = mode;
                }
                $scope.CustomerOrderModel.sortCheckout();
            }
            $scope.CustomerOrderModel.allowCheckoutSort = true;
            $scope.CustomerOrderModel.sortCheckout = function() {
                var checkoutItems = [];
                var customerCheckouts = _.filter($scope.CustomerOrderModel.CheckOutItems, function(item) {
                    return item.CheckoutType == 'Customer';
                });
                var internalCheckouts = _.filter($scope.CustomerOrderModel.CheckOutItems, function(item) {
                    return item.CheckoutType == 'Internal';
                });
                var thirdPartyCheckouts = _.filter($scope.CustomerOrderModel.CheckOutItems, function(item) {
                    return item.CheckoutType == 'Third-Party';
                });
                var dealCheckouts = _.filter($scope.CustomerOrderModel.CheckOutItems, function(item) {
                    return item.CheckoutType == 'Deal';
                });
                if ($scope.CustomerOrderModel.checkOutMode == undefined) {
                    if (thirdPartyCheckouts.length > 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Third-Party';
                    } else if (customerCheckouts.length > 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Customer';
                    } else if (internalCheckouts.length > 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Internal';
                    } else if (dealCheckouts.length > 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Deal';
                    }
                } else {
                    if (internalCheckouts.length == 0 && thirdPartyCheckouts.length == 0 && dealCheckouts.length == 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Customer';
                    } else if (customerCheckouts.length == 0 && internalCheckouts.length == 0 && dealCheckouts.length == 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Third-Party';
                    } else if (thirdPartyCheckouts.length == 0 && customerCheckouts.length == 0 && dealCheckouts.length == 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Internal';
                    } else if (thirdPartyCheckouts.length == 0 && customerCheckouts.length == 0 && internalCheckouts.length == 0) {
                        $scope.CustomerOrderModel.checkOutMode = 'Deal';
                    }
                }
                if ($scope.CustomerOrderModel.checkOutMode == 'Customer') {
                    var selectableCustomerCheckouts = _.filter(customerCheckouts, function(item) {
                        return item.IsInvoiceable == true;
                    });
                    var nonSelectableCustomerCheckouts = _.filter(customerCheckouts, function(item) {
                        return item.IsInvoiceable == false;
                    });
                    customerCheckouts = [];
                    customerCheckouts = customerCheckouts.concat(selectableCustomerCheckouts);
                    customerCheckouts = customerCheckouts.concat(nonSelectableCustomerCheckouts);
                    checkoutItems = checkoutItems.concat(customerCheckouts);
                    angular.forEach(thirdPartyCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(internalCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(dealCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    checkoutItems = checkoutItems.concat(thirdPartyCheckouts);
                    checkoutItems = checkoutItems.concat(internalCheckouts);
                    checkoutItems = checkoutItems.concat(dealCheckouts);
                } else if ($scope.CustomerOrderModel.checkOutMode == 'Third-Party') {
                    checkoutItems = checkoutItems.concat(thirdPartyCheckouts);
                    angular.forEach(customerCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(internalCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(dealCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    checkoutItems = checkoutItems.concat(customerCheckouts);
                    checkoutItems = checkoutItems.concat(internalCheckouts);
                    checkoutItems = checkoutItems.concat(dealCheckouts);
                } else if ($scope.CustomerOrderModel.checkOutMode == 'Internal') {
                    checkoutItems = checkoutItems.concat(internalCheckouts);
                    angular.forEach(customerCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(thirdPartyCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(dealCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    checkoutItems = checkoutItems.concat(customerCheckouts);
                    checkoutItems = checkoutItems.concat(thirdPartyCheckouts);
                    checkoutItems = checkoutItems.concat(dealCheckouts);
                } else if ($scope.CustomerOrderModel.checkOutMode == 'Deal') {
                    checkoutItems = checkoutItems.concat(dealCheckouts);
                    angular.forEach(customerCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(thirdPartyCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    angular.forEach(internalCheckouts, function(value, key) {
                        value.IsActive = false;
                    });
                    checkoutItems = checkoutItems.concat(customerCheckouts);
                    checkoutItems = checkoutItems.concat(internalCheckouts);
                    checkoutItems = checkoutItems.concat(thirdPartyCheckouts);
                }
                $scope.CustomerOrderModel.CheckOutItems = checkoutItems;
                if (!$scope.CustomerOrderModel.allowCheckoutSort) {
                    $scope.UpdateCheckout();
                    $scope.CustomerOrderModel.allowCheckoutSort = true;
                } else {
                    $scope.CustomerOrderModel.allowCheckoutSort = false;
                }
            }
            $scope.CustomerOrderModel.checkoutModeContainerShown = function() {
                var count = 0
                if ($scope.CustomerOrderModel.checkoutModeVisible('Customer')) {
                    count++;
                }
                if ($scope.CustomerOrderModel.checkoutModeVisible('Third-Party')) {
                    count++;
                }
                if ($scope.CustomerOrderModel.checkoutModeVisible('Internal')) {
                    count++;
                }
                if ($scope.CustomerOrderModel.checkoutModeVisible('Deal')) {
                    count++;
                }
                var isVisible = count > 1 ? true : false;
                return isVisible;
            }
            $scope.CustomerOrderModel.checkoutModeVisible = function(Type) {
                if (_.findIndex($scope.CustomerOrderModel.CheckOutItems, {
                        CheckoutType: Type
                    }) > -1) {
                    return true;
                }
                return false;
            }
            $scope.AddToSearch = function(objectName) {
                var ObjectVal = objectName;
                if (ObjectVal == 'Merchandise:') {
                    ObjectVal = 'Part__c'
                } else if (objectName == 'Unit:') {
                    ObjectVal = 'Customer_Owned_Unit__c'
                } else if (objectName == 'Stock Unit:') {
                    ObjectVal = 'Customer_Owned_Unit__c'
                } else if (objectName == 'Kit:') {
                    ObjectVal = 'Kit_Header__c'
                } else if (objectName == 'Finance:') {
                    ObjectVal = 'Product__c'
                }
                $scope.CustomerOrderModel.ObjectSelected = {
                    Name: objectName,
                    Value: ObjectVal
                }
                $timeout($scope.setFocus, 500);
            }
            $scope.setFocusWithMerchandise = function() {
                $scope.CustomerOrderModel.ObjectSelected = {
                    Name: 'Merchandise:',
                    Value: 'Part__c'
                }
                $timeout($scope.setFocus, 500);
            }
            $scope.setFocusOnStaForOptionFees = function() {}
            $scope.setFocus = function() {
                angular.element('#CO_SearchToAdd_value').focus();
            }
            $scope.financeSetFocus = function() {
                $scope.AddToSearch('Finance:');
                angular.element('#CO_SearchToAdd_value').focus();
            }
            $scope.dealSetFocus = function(dealHeaderIndex) {
                $scope.CustomerOrderModel.dealLineItemId = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealItemObj.Id;
                $scope.CustomerOrderModel.DealHeaderIndex = dealHeaderIndex;
                if ($scope.CustomerOrderModel.dealLineItemId == null) {
                    Notification.error($Label.CustomerOrder_Js_select_a_unit);
                    $scope.CustomerOrderModel.DealHeaderIndex = null;
                    return;
                }
                $scope.setFocus1();
                angular.element('#CO_SearchToAdd_value').focus();
            }
            $scope.setFocus1 = function() {
                $timeout(function() {
                    $scope.$broadcast('plusIconClickEvent', "");
                }, 505);
            }
            $scope.CustomerOrderModel.itemServiceOrdersetFocus = function() {
                $scope.AddToSearch('Merchandise:');
                angular.element('#CO_SearchToAdd_value').focus();
            }
            $scope.setFocusToCustomer = function() {
                $scope.AddToSearch('Customer:');
                angular.element('#CO_SearchToAdd_value').focus();
            }
            $scope.CustomerOrderModel.setFocusToUnit = function(soHeaderIndex) {
                $scope.AddToSearch('Unit:');
                angular.element('#CO_SearchToAdd_value').focus();
                $scope.CustomerOrderModel.scrollToPanel(null, 'ServiceOrderSection' + soHeaderIndex);
            }
            $scope.CustomerOrderModel.setFocusToUnitInternalService = function(dealUnitId, dealUnitIndex) {
                $scope.AddToSearch('Stock Unit:');
                angular.element('#CO_SearchToAdd_value').focus();
                if (dealUnitId != null) {
                    $scope.CustomerOrderModel.DealUnitId = dealUnitId;
                } else {
                    $scope.CustomerOrderModel.DealUnitId = null;
                }
                $scope.CustomerOrderModel.DealUnitIndex = dealUnitIndex;
                $scope.CustomerOrderModel.changeIndex = dealUnitIndex;
            }
            $scope.CustomerOrderModel.changeUsersSelectedForApproval = function(dealHeaderTradeInIndex, index) {
                if (!angular.isDefined($scope.CustomerOrderModel.UserSelected[index])) {
                    $scope.CustomerOrderModel.DealTradeInList[index].ApprovedBy = null;
                    $scope.CustomerOrderModel.UserSelected[index] = $scope.CustomerOrderModel.UserList[0];
                } else {
                    $scope.CustomerOrderModel.DealTradeInList[index].ApprovedBy = $scope.CustomerOrderModel.UserSelected[index].id;
                }
                DealService.updateTradeIn($scope.CustomerOrderModel.DealInfo.Id, JSON.stringify($scope.CustomerOrderModel.DealTradeInList[index])).then(function(successfulSearchResult) {});
            }
            $scope.CustomerOrderModel.cancelDeposit = function() {
                $scope.CustomerOrderModel.isPaymentDropdownOpen = false;
                $scope.CustomerOrderModel.isRefundDepositBtnClicked = false;
                $scope.CustomerOrderModel.selectedOption = 'Please Select';
                $scope.CustomerOrderModel.deposit_method = '';
                $scope.CustomerOrderModel.deposit_Amount = '';
            }
            $scope.CustomerOrderModel.cancelDealDeposit = function() {
                $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit = false;
                $scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit = false;
                $scope.CustomerOrderModel.selectedOptionForDealDeposit = 'Please Select';
                $scope.CustomerOrderModel.deal_deposit_method = '';
                $scope.CustomerOrderModel.deal_deposit_Amount = '';
                $scope.CustomerOrderModel.isDealDepositAmountError = false;
                $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = '';
            }
            $scope.CustomerOrderModel.selectedOptionForDealDeposit = 'Please Select';
            $scope.CustomerOrderModel.optionSelectedForDealDeposit = function(optionValue, e) {
                $scope.CustomerOrderModel.deal_deposit_method = optionValue;
                $scope.CustomerOrderModel.selectedOptionForDealDeposit = optionValue;
                if ($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == false) {
                    $scope.CustomerOrderModel.deal_deposit_Amount = '';
                } else {
                    $scope.CustomerOrderModel.deal_deposit_Amount = ($scope.CustomerOrderModel.calculateDealDepositTotal() > 0) ? $scope.CustomerOrderModel.calculateDealDepositTotal() : '';
                }
                angular.element('#dealDepositDropDownDiv').removeClass('open');
                var element = angular.element("#CO_Deposits_block_deposit_header_amount_block_pricebox_For_DealDeposit");
                if (e) {
                    e.stopPropagation();
                    e.preventDefault();
                }
                setTimeout(function() {
                    if (element) {
                        element.focus();
                        element.select();
                    }
                }, 100);
            }
            $scope.CustomerOrderModel.showHideAddDepositBtnForDealDeposit = function(event) {
                if (event != undefined) {
                    if (event.keyCode == 9) {
                        $scope.CustomerOrderModel.addOrRefundDealDepositOnEnter();
                    } else {
                        if ($scope.CustomerOrderModel.isDealDepositAmountError) {
                            $scope.CustomerOrderModel.isDealDepositAmountError = false;
                        }
                    }
                }
                if ($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == false && $scope.CustomerOrderModel.selectedOptionForDealDeposit != 'Please Select' && $scope.CustomerOrderModel.deal_deposit_Amount > 0) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.refundDepositBtnClickForDealDeposit = function(event) {
                if (event) {
                    event.stopPropagation();
                }
                if ($scope.CustomerOrderModel.deal_deposit_Amount > 0) {
                    var deposit = {};
                    deposit.PaymentMethod = $scope.CustomerOrderModel.deal_deposit_method;
                    deposit.Amount = $scope.CustomerOrderModel.deal_deposit_Amount;
                    deposit.CODepositId = null;
                    deposit.Deal = $scope.CustomerOrderModel.DealInfo.Id;
                    $scope.CustomerOrderModel.ReverseDealDeposit(deposit);
                    $scope.CustomerOrderModel.addDealDeposit();
                } else {
                    $scope.CustomerOrderModel.selectedOptionForDealDeposit = 'Please Select';
                    $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit = true;
                    $scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit = true;
                    setTimeout(function() {
                        angular.element('#dealDepositDropDownDiv').find("li:first").find('a').focus();
                    }, 100);
                }
            }
            $scope.CustomerOrderModel.addOrRefundDealDepositOnEnter = function(event) {
                if (($scope.CustomerOrderModel.showHideAddDepositBtnForDealDeposit(event) == true) || ($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == false && $scope.CustomerOrderModel.selectedOptionForDealDeposit != 'Please Select' && $scope.CustomerOrderModel.deal_deposit_Amount > 0)) {
                    $scope.CustomerOrderModel.addDealDeposit();
                } else if ($scope.CustomerOrderModel.DealDepositList.length > 0 && (($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == false && $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit == false) || ($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == true && $scope.CustomerOrderModel.selectedOptionForDealDeposit != 'Please Select' && $scope.CustomerOrderModel.deal_deposit_Amount > 0)) && $scope.CustomerOrderModel.calculateDealDepositTotal() > 0) {
                    $scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit = true;
                    $scope.CustomerOrderModel.refundDepositBtnClickForDealDeposit(event);
                }
            }
            $scope.CustomerOrderModel.expandDepositSectionForDealDeposit = function(event) {
                if (event) {
                    event.stopPropagation();
                }
                $scope.CustomerOrderModel.deal_deposit_Amount = '';
                $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit = true;
                setTimeout(function() {
                    angular.element('#dealDepositDropDownDiv').find("li:first").find('a').focus();
                }, 100);
            }
            $scope.CustomerOrderModel.deal_deposit_method = "Cash";
            $scope.CustomerOrderModel.deal_deposit_Amount = "";
            $scope.CustomerOrderModel.isReverseDealDeposit = false;
            $scope.CustomerOrderModel.deal_deposit_Link = null;
            $scope.CustomerOrderModel.deal_deposit_DealId = null;
            $scope.CustomerOrderModel.addDealDeposit = function() {
                $scope.CustomerOrderModel.isDealDepositAmountError = false;
                if ($scope.CustomerOrderModel.DealDepositList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.DealDepositList.length; i++) {
                        if ($scope.CustomerOrderModel.DealDeposits_editRow[i].isEdit == true) {
                            $scope.CustomerOrderModel.DealDeposits_editRow[i].isEdit = false;
                        }
                    }
                }
                var deposits = [];
                var depositModel = {};
                var maxDeposit = 999999.99;
                depositModel.PaymentMethod = $scope.CustomerOrderModel.deal_deposit_method;
                depositModel.Amount = $scope.CustomerOrderModel.deal_deposit_Amount;
                depositModel.COHeaderId = $scope.CustomerOrderModel.coHeaderId;
                depositModel.ReverseLink = $scope.CustomerOrderModel.deal_deposit_Link;
                $scope.CustomerOrderModel.deal_deposit_DealId = $scope.CustomerOrderModel.DealInfo.Id;
                depositModel.Deal = $scope.CustomerOrderModel.deal_deposit_DealId;
                if ((parseFloat($scope.CustomerOrderModel.calculateDealDepositTotal()) < (parseFloat(depositModel.Amount) * -1)) && $scope.CustomerOrderModel.isReverseDealDeposit && depositModel.ReverseLink != undefined && depositModel.ReverseLink != '' && depositModel.ReverseLink != null) { //for reverse
                    $scope.CustomerOrderModel.deal_deposit_Amount = (-1 * $scope.CustomerOrderModel.deal_deposit_Amount).toFixed(2);
                    Notification.error($Label.CustomerOrder_Js_Total_deposit_received);
                    return;
                }
                if (depositModel.Amount == "") {
                    $scope.CustomerOrderModel.isDealDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Please Enter Amount";
                    return;
                } else if ((+(depositModel.Amount)).toFixed(2) == 0) {
                    $scope.CustomerOrderModel.isDealDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Amount Can't be Zero";
                    return;
                } else if (isNaN(depositModel.Amount)) {
                    $scope.CustomerOrderModel.isDealDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Amount Should be Numeric";
                    return;
                } else if (parseFloat(depositModel.Amount) < 0 && $scope.CustomerOrderModel.isReverseDealDeposit && (depositModel.ReverseLink == undefined || depositModel.ReverseLink == '' || depositModel.ReverseLink == null)) {
                    if (parseFloat(depositModel.Amount) * -1 > $scope.CustomerOrderModel.calculateDealDepositTotal()) {
                        $scope.CustomerOrderModel.isDealDepositAmountError = true;
                        $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1").show();
                        $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Amount can't be greater than total deposit received";
                        $scope.CustomerOrderModel.isReverseDealDeposit = false;
                        $scope.CustomerOrderModel.deal_deposit_Amount = (-1 * $scope.CustomerOrderModel.deal_deposit_Amount).toFixed(2);
                        return;
                    }
                } else if (depositModel.Amount < 0 && !$scope.CustomerOrderModel.isReverseDealDeposit) {
                    $scope.CustomerOrderModel.isDealDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Amount Should be Positive";
                    return;
                } else if (depositModel.Amount < -1 * $scope.CustomerOrderModel.calculateDealDepositTotal()) {
                    $scope.CustomerOrderModel.isDealDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Total can't be Negative";
                    return;
                } else if (depositModel.Amount > maxDeposit) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDealDepositAmountErrorMsg = "Amount cannot exceed 6 digits";
                    return;
                }
                depositModel.Amount = (+(depositModel.Amount)).toFixed(2);
                deposits.push(depositModel);
                CustomerInfoService.AddDealDeposit(JSON.stringify(deposits), $scope.CustomerOrderModel.DealInfo.Id).then(function(successfulSearchResult) {
                    $scope.UpdateDealDepositsList(successfulSearchResult);
                    $scope.CustomerOrderModel.isPaymentDropdownOpenForDealDeposit = false;
                    $scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit = false;
                    $scope.CustomerOrderModel.selectedOptionForDealDeposit = 'Please Select';
                    $scope.CustomerOrderModel.deal_deposit_method = '';
                    if (depositModel.Amount > 0) {
                        $scope.CustomerOrderModel.DealDeposits_editRow[($scope.CustomerOrderModel.DealDepositList.length - 1)].isEdit = true;
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                }).then(function() {
                    CustomerInfoService.getCODepositByCOHeaderId($scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.UpdateDepositsList(successfulSearchResult);
                        $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
                $scope.CustomerOrderModel.isReverseDealDeposit = false;
                $scope.CustomerOrderModel.deal_deposit_Amount = "";
                $scope.CustomerOrderModel.deal_deposit_method = "Cash";
                $scope.CustomerOrderModel.deal_deposit_Link = "";
            }
            $scope.CustomerOrderModel.calculateDealDepositTotal = function() {
                var depositTotal = 0;
                if ($scope.CustomerOrderModel.DealDepositList != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealDepositList.length; i++) {
                        depositTotal += $scope.CustomerOrderModel.DealDepositList[i].Amount;
                    }
                }
                depositTotal = depositTotal.toFixed(2);
                return depositTotal;
            }
            $scope.CustomerOrderModel.ReverseDealDeposit = function(deposit) {
                $scope.CustomerOrderModel.isReverseDealDeposit = true;
                $scope.CustomerOrderModel.deal_deposit_method = deposit.PaymentMethod;
                $scope.CustomerOrderModel.deal_deposit_Amount = -(deposit.Amount);
                $scope.CustomerOrderModel.deal_deposit_Link = deposit.CODepositId;
                $scope.CustomerOrderModel.deal_deposit_DealId = deposit.Deal;
            }
            $scope.CustomerOrderModel.closeEditDealDepositRow = function() {
                if (!$scope.CustomerOrderModel.isReverseDealDeposit) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealDeposits_editRow.length; i++) {
                        $scope.CustomerOrderModel.DealDeposits_editRow[i].isEdit = false;
                    }
                }
            }
            $scope.CustomerOrderModel.editDealDepositItem = function(index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || $scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced') {
                    return;
                }
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.DealDeposits_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.DealDeposits_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.CustomerOrderModel.DealDeposits_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.DealDeposits_editRow[index].isEdit = true;
                }
            }
            $scope.CustomerOrderModel.paymentOption_DealDeposit = function(paymentMode) {
                $scope.CustomerOrderModel.deal_deposit_method = paymentMode;
            }
            $scope.UpdateDealDepositsList = function(depositsList) {
                $scope.CustomerOrderModel.DealDepositList = [];
                $scope.CustomerOrderModel.DealDeposits_editRow = [];
                for (i = 0; i < depositsList.length; i++) {
                    if (depositsList[i].Deal) {
                        $scope.CustomerOrderModel.DealDepositList.push(depositsList[i]);
                        $scope.CustomerOrderModel.DealDeposits_editRow.push({
                            isEdit: false,
                            radioValue: 0
                        });
                    }
                }
                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
            }
            $scope.setDeductibleFocus = function(index) {
                var id = '#DeductibleAmount' + index;
                angular.element(id).focus();
            }
            $scope.CustomerOrderModel.deposit_method = "Cash";
            $scope.CustomerOrderModel.deposit_Amount = "";
            $scope.CustomerOrderModel.isReverseDeposit = false;
            $scope.CustomerOrderModel.deposit_Link = null;
            $scope.CustomerOrderModel.deposit_DealId = null;
            $scope.CustomerOrderModel.addDeposit = function() {
                if ($scope.CustomerOrderModel.Deposits != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                        if ($scope.CustomerOrderModel.Deposits_editRow[i].isEdit == true) {
                            $scope.CustomerOrderModel.Deposits_editRow[i].isEdit = false;
                        }
                    }
                }
                $scope.CustomerOrderModel.isDepositAmountError = false;
                var deposits = [];
                var depositModel = {};
                var maxDeposit = 999999.99;
                depositModel.PaymentMethod = $scope.CustomerOrderModel.deposit_method;
                depositModel.Amount = $scope.CustomerOrderModel.deposit_Amount;
                depositModel.COHeaderId = $scope.CustomerOrderModel.coHeaderId;
                depositModel.ReverseLink = $scope.CustomerOrderModel.deposit_Link;
                depositModel.Deal = $scope.CustomerOrderModel.deposit_DealId;
                if ((parseFloat($scope.CustomerOrderModel.calculateLeftPanelDeposits()) < (parseFloat(depositModel.Amount) * -1)) && $scope.CustomerOrderModel.isReverseDeposit && depositModel.ReverseLink != undefined && depositModel.ReverseLink != '' && depositModel.ReverseLink != null) { //for reverse
                    $scope.CustomerOrderModel.deposit_Amount = (-1 * $scope.CustomerOrderModel.deposit_Amount).toFixed(2);
                    Notification.error($Label.CustomerOrder_Js_Total_deposit_received);
                    return;
                }
                if (depositModel.Amount == "") {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Please Enter Amount";
                    return;
                } else if ((+(parseFloat(depositModel.Amount))).toFixed(2) == 0) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Amount Can't be Zero";
                    return;
                } else if (isNaN(depositModel.Amount)) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Amount Should be Numeric";
                    return;
                } else if (parseFloat(depositModel.Amount) < 0 && $scope.CustomerOrderModel.isReverseDeposit && (depositModel.ReverseLink == undefined || depositModel.ReverseLink == '' || depositModel.ReverseLink == null)) {
                    if (parseFloat(depositModel.Amount) * -1 > $scope.CustomerOrderModel.calculateLeftPanelDeposits()) {
                        $scope.CustomerOrderModel.isDepositAmountError = true;
                        $("#CO_Deposits_block_deposit_header_amount_block_pricebox_error_msg1").show();
                        $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Amount can't be greater than total deposit received";
                        $scope.CustomerOrderModel.isReverseDeposit = false;
                        $scope.CustomerOrderModel.deposit_Amount = (-1 * $scope.CustomerOrderModel.deposit_Amount).toFixed(2);
                        return;
                    }
                } else if (parseFloat(depositModel.Amount) < 0 && !$scope.CustomerOrderModel.isReverseDeposit) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Amount Should be Positive";
                    return;
                } else if (parseFloat(depositModel.Amount) < -1 * $scope.CustomerOrderModel.calculateLeftPanelDeposits()) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Total can't be Negative";
                    return;
                } else if (parseFloat(depositModel.Amount) > maxDeposit) {
                    $scope.CustomerOrderModel.isDepositAmountError = true;
                    $scope.CustomerOrderModel.isDepositAmountErrorMsg = "Amount cannot exceed 6 digits";
                    return;
                }
                depositModel.Amount = (+(depositModel.Amount)).toFixed(2);
                deposits.push(depositModel);
                CustomerInfoService.AddDeposit(JSON.stringify(deposits)).then(function(successfulSearchResult) {
                    $scope.UpdateDepositsList(successfulSearchResult);
                    $scope.CustomerOrderModel.isPaymentDropdownOpen = false;
                    $scope.CustomerOrderModel.isRefundDepositBtnClicked = false;
                    $scope.CustomerOrderModel.selectedOption = 'Please Select';
                    $scope.CustomerOrderModel.deposit_method = '';
                    if (depositModel.Amount > 0 && $scope.CustomerOrderModel.Deposits[($scope.CustomerOrderModel.Deposits.length - 1)].Deal == null) {
                        $scope.CustomerOrderModel.Deposits_editRow[($scope.CustomerOrderModel.Deposits.length - 1)].isEdit = true;
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                }).then(function() {
                    if ($scope.CustomerOrderModel.DealInfo != undefined) {
                        CustomerInfoService.getDealCoDeposits($scope.CustomerOrderModel.DealInfo.Id).then(function(successfulSearchResult) {
                            $scope.UpdateDealDepositsList(successfulSearchResult);
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
                $scope.CustomerOrderModel.isReverseDeposit = false;
                $scope.CustomerOrderModel.deposit_Amount = "";
                $scope.CustomerOrderModel.deposit_method = "Cash";
                $scope.CustomerOrderModel.deposit_Link = "";
            }
            $scope.CustomerOrderModel.Payment_method = "Cash";
            $scope.CustomerOrderModel.Payment_Amount = "";
            $scope.CustomerOrderModel.PaymentReverseLink = null;
            $scope.CustomerOrderModel.isReversePayment = false;
            $scope.CustomerOrderModel.blurHide = function() {
                $scope.CustomerOrderModel.isPaymentAmountError = false;
            }
            $scope.CustomerOrderModel.getdealDepositPaymentsTotal = function(amount) {
                var PaymentModel = {};
                dealDepositTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                    if ($scope.CustomerOrderModel.CheckOutItems[i].DealId != null && $scope.CustomerOrderModel.CheckOutItems[i].DealId != '' && !$scope.CustomerOrderModel.CheckOutItems[i].DealFinanceId) {
                        if ($scope.CustomerOrderModel.CheckOutItems[i].IsActive) {
                            if ($scope.CustomerOrderModel.DealDepositList != undefined) {
                                for (var j = 0; j < $scope.CustomerOrderModel.DealDepositList.length; j++) {
                                    dealDepositTotal += $scope.CustomerOrderModel.DealDepositList[j].Amount;
                                }
                                if (dealDepositTotal >= amount) {
                                    PaymentModel.Amount = amount;
                                    PaymentModel.PaymentMethod = 'Use Deal Deposit';
                                    PaymentModel.ReverseLink = $scope.CustomerOrderModel.PaymentReverseLink;
                                    PaymentModel.COInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                                    PaymentModel.IsReverse = false;
                                    PaymentModel.DealId = $scope.CustomerOrderModel.CheckOutItems[i].DealId;
                                }
                            }
                        }
                    }
                }
                return PaymentModel;
            }
            $scope.CustomerOrderModel.addPayment = function() {
                var IsdealDepositPayment = false;
                if (($scope.CustomerOrderModel.Customer.Value == undefined || $scope.CustomerOrderModel.Customer.Value == null || $scope.CustomerOrderModel.Customer.Value == '') && ($scope.CustomerOrderModel.coHeaderDetails.COType == 'Customer')) {
                    Notification.error($Label.CustomerOrder_Js_First_add_customer);
                    return;
                }
                if ($scope.CustomerOrderModel.Payment_method == 'Store Credit' && $scope.CustomerOrderModel.coHeaderDetails.CustomerStoreCredit < $scope.CustomerOrderModel.Payment_Amount) {
                    Notification.error('Payment amount entered cannot exceed the available Store Credit Balance');
                    return;
                }
                $scope.CustomerOrderModel.isPaymentAmountError = false;
                var Payment = [];
                var PaymentModel = {};
                var maxPayment = 999999.99;
                PaymentModel.ReverseLink = $scope.CustomerOrderModel.PaymentReverseLink;
                PaymentModel.PaymentMethod = $scope.CustomerOrderModel.Payment_method;
                if ($scope.CustomerOrderModel.selectedOptionForCheckout == 'Cash' && $scope.CustomerOrderModel.Payment_Amount >= $scope.CustomerOrderModel.RoundedBalanceDue) {
                    PaymentModel.Amount = $scope.CustomerOrderModel.RoundedBalanceDue;
                    var RoundedPaymentModel = {};
                    $scope.CustomerOrderModel.RoundedBalanceDue = parseFloat($scope.CustomerOrderModel.RoundedBalanceDue);
                    RoundedPaymentModel.Amount = ($scope.CustomerOrderModel.calculateBalanceDue(true) - $scope.CustomerOrderModel.RoundedBalanceDue).toFixed(2);
                    RoundedPaymentModel.PaymentMethod = 'Cash Rounding';
                    RoundedPaymentModel.ReverseLink = $scope.CustomerOrderModel.PaymentReverseLink;
                    RoundedPaymentModel.COInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                    RoundedPaymentModel.IsReverse = $scope.CustomerOrderModel.isReversePayment;
                    Payment.push(RoundedPaymentModel);
                } else {
                    PaymentModel.Amount = $scope.CustomerOrderModel.Payment_Amount;
                }
                PaymentModel.COInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                PaymentModel.IsReverse = $scope.CustomerOrderModel.isReversePayment;
                if ((parseFloat($scope.CustomerOrderModel.calculatePaymentTotal()) < (parseFloat(PaymentModel.Amount) * -1)) && $scope.CustomerOrderModel.isReversePayment && PaymentModel.ReverseLink != undefined && PaymentModel.ReverseLink != '' && PaymentModel.ReverseLink != null) { // for reverse
                    $scope.CustomerOrderModel.Payment_Amount = (-1 * $scope.CustomerOrderModel.Payment_Amount).toFixed(2);
                    Notification.error('Amount should be less than or equal to total payment received');
                    return;
                }
                if (PaymentModel.Amount == "") {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Please Enter Amount";
                    return;
                } else if ((+(PaymentModel.Amount)).toFixed(2) == 0) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Amount Can't be Zero";
                    return;
                } else if (isNaN(PaymentModel.Amount)) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Amount Should be Numeric";
                    return;
                } else if (PaymentModel.Amount < 0 && !$scope.CustomerOrderModel.isReversePayment && !$scope.CustomerOrderModel.IsPartReturn) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Amount Should be Positive";
                    return;
                } else if (PaymentModel.PaymentMethod == 'Use Deposit' && (($scope.CustomerOrderModel.isDealCheckoutActive && (parseFloat(PaymentModel.Amount) > $scope.CustomerOrderModel.calculateDealDepositTotal())) || (!$scope.CustomerOrderModel.isDealCheckoutActive && parseFloat(PaymentModel.Amount) > (($scope.CustomerOrderModel.calculateDepositTotalWithoutDeal() - $scope.CustomerOrderModel.calculateDepositUsed()).toFixed(2))))) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Deposit Not Available";
                    angular.element('#paymentErrorMsg').css("display", 'block');
                    return;
                } else if (PaymentModel.Amount > maxPayment) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Amount cannot exceed 6 digits";
                    return;
                } else if (!$scope.CustomerOrderModel.IsPartReturn && (PaymentModel.Amount < -1 * $scope.CustomerOrderModel.calculatePaymentTotal())) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Total can't be Negative";
                    return;
                } else if (PaymentModel.PaymentMethod == 'Use Deposit' && $scope.CustomerOrderModel.IsPartReturn && PaymentModel.Amount < 0) {
                    $scope.CustomerOrderModel.isPaymentAmountError = true;
                    $scope.CustomerOrderModel.isPaymentAmountErrorMsg = "Deposit cannot be used in Part Return Case";
                    return;
                } else if (!$scope.CustomerOrderModel.allowFromPopup && PaymentModel.Amount - $scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                    if (PaymentModel.PaymentMethod != 'Cash') {
                        angular.element('#payment_ConfirmBox').show();
                        return;
                    }
                }
                if (PaymentModel.PaymentMethod == 'Use Deposit' && $scope.CustomerOrderModel.isDealCheckoutActive) {
                    var checkoutItems = [];
                    for (var i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                        if ($scope.CustomerOrderModel.CheckOutItems[i].IsActive && !$scope.CustomerOrderModel.CheckOutItems[i].DealId) {
                            $scope.CustomerOrderModel.CheckOutItems[i].IsActive = false;
                            checkoutItems.push($scope.CustomerOrderModel.CheckOutItems[i]);
                        }
                    }
                    CustomerInfoService.UpdateChekoutItems(JSON.stringify(checkoutItems), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                    var dealpaymentModel = $scope.CustomerOrderModel.getdealDepositPaymentsTotal(PaymentModel.Amount);
                    if (Object.keys(dealpaymentModel).length != 0) {
                        Payment.push(dealpaymentModel);
                        IsdealDepositPayment = true;
                    }
                } else {
                    PaymentModel.Amount = (+(PaymentModel.Amount)).toFixed(2);
                    Payment.push(PaymentModel);
                }
                $scope.CustomerOrderModel.Payment_Amount = "";
                CustomerInfoService.AddPayment(JSON.stringify(Payment)).then(function(successfulResult) {
                    $scope.CustomerOrderModel.coHeaderDetails = successfulResult.coHeaderRec;
                    $scope.CustomerOrderModel.isReversePayment = false;
                    $scope.CustomerOrderModel.PaymentReverseLink = null;
                    $scope.CustomerOrderModel.RoundedBalanceDue = 0;
                    $scope.UpdatePaymentList(successfulResult.coInvoicePaymentRecs);
                    $scope.UpdateDepositsList(successfulResult.coDeposits);
                    $scope.UpdateDealDepositsList(successfulResult.coDeposits);
                    $scope.CustomerOrderModel.calculateLeftPanelDeposits();
                    if ($scope.CustomerOrderModel.calculateBalanceDue() == 0) {
                        $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = true;
                    }
                    if ($scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                        $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                    }
                    $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
                    $scope.CustomerOrderModel.Payment_Amount = ($scope.CustomerOrderModel.calculateBalanceDue() != 0) ? $scope.CustomerOrderModel.calculateBalanceDue() : "";
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
                $scope.CustomerOrderModel.isReversePayment = false;
                $scope.CustomerOrderModel.PaymentReverseLink = null;
                $scope.CustomerOrderModel.Payment_method = "Cash";
                $scope.CustomerOrderModel.deposit_Link = "";
            }
            $scope.CustomerOrderModel.cancelPayment = function() {
                $scope.CustomerOrderModel.cancelPaymentClicked = true;
                if ($scope.CustomerOrderModel.Payment == undefined || $scope.CustomerOrderModel.Payment == '' || $scope.CustomerOrderModel.Payment == null || $scope.CustomerOrderModel.Payment.length <= 0) {
                    $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                    $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
                } else {
                    if ($scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment.length > 0) {
                        for (var i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                            if ($scope.CustomerOrderModel.Payment[i].Amount < 0) {
                                $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = true;
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.calculateBalanceDue() != 0) {
                        if ($scope.CustomerOrderModel.displayAddPaymentBtnForCheckout == false && $scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                        } else {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                        }
                        $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
                    }
                }
                if ($scope.CustomerOrderModel.calculateBalanceDue() < 0) {
                    $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                }
                $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
                $scope.CustomerOrderModel.Payment_Amount = '';
            }
            $scope.CustomerOrderModel.payment_Response = function(response) {
                if (response) {
                    angular.element('#payment_ConfirmBox').hide();
                    $scope.CustomerOrderModel.allowFromPopup = true;
                    $scope.CustomerOrderModel.addPayment();
                    $scope.CustomerOrderModel.allowFromPopup = false;
                } else {
                    angular.element('#payment_ConfirmBox').hide();
                    $scope.CustomerOrderModel.allowFromPopup = false;
                }
            }
            $scope.CustomerOrderModel.calculateDepositUsed = function() {
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var depositUsed = 0;
                for (i = 0; i < PaymentList.length; i++) {
                    if (PaymentList[i].PaymentMethod == 'Use Deposit' || PaymentList[i].PaymentMethod == 'Use Deal Deposit') {
                        depositUsed += PaymentList[i].Amount;
                    }
                }
                return parseFloat(depositUsed.toFixed(2));
            }
            $scope.CustomerOrderModel.calculateLeftPanelDeposits = function() {
                var deposits = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                    if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                        deposits += $scope.CustomerOrderModel.Deposits[i].Amount;
                    }
                }
                deposits = deposits.toFixed(2);
                deposits = deposits - $scope.CustomerOrderModel.calculateDepositUsed();
                return deposits;
            }
            $scope.CustomerOrderModel.calculateLeftPanelPayments = function() {
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var totalPayment = 0;
                for (i = 0; i < PaymentList.length; i++) {
                    totalPayment += PaymentList[i].Amount;
                }
                totalPayment = totalPayment.toFixed(2);
                return totalPayment;
            }
            $scope.CustomerOrderModel.calculateTotalPaymentsandDeposits = function() {
                var payments = parseFloat($scope.CustomerOrderModel.calculateLeftPanelPayments());
                var deposits = parseFloat($scope.CustomerOrderModel.calculateDepositTotalIncludeDeal() - $scope.CustomerOrderModel.calculateDepositUsed());
                return deposits + payments;
            }
            $scope.CustomerOrderModel.calculateLeftPanelTotalDue = function() {
                var ORDERTOTAL = $scope.CustomerOrderModel.calculateOrderTotal();
                var DEPOSITS = $scope.CustomerOrderModel.calculateLeftPanelDeposits();
                var INVOICED = $scope.CustomerOrderModel.calculateInvoiceHistoryTotal();
                var PAYMENTS = $scope.CustomerOrderModel.calculateLeftPanelPayments();
                var totalDue = ORDERTOTAL - DEPOSITS - INVOICED - PAYMENTS;
                return totalDue.toFixed(2);
            }
            $scope.CustomerOrderModel.calculateDealBalanceDue = function() {
                var balanceDue = 0;
                var dealDepositTotal = 0;
                if ($scope.CustomerOrderModel.DealDepositList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.DealDepositList.length; i++) {
                        dealDepositTotal += $scope.CustomerOrderModel.DealDepositList[i].Amount;
                    }
                }
                if ($scope.CustomerOrderModel.DealSummaryObj != undefined) {
                    balanceDue = $scope.CustomerOrderModel.DealSummaryObj.Total - dealDepositTotal;
                }
                return balanceDue.toFixed(2);
            }
            $scope.CustomerOrderModel.calculateBalanceDue = function(isRealValue) {
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var ChekoutAmt = 0;
                var balanceDue = 0;
                var totalPayment = 0;
                $scope.CustomerOrderModel.IsPartReturn = false;
                for (i = 0; i < CheckoutItemList.length; i++) {
                    if (CheckoutItemList[i].IsActive) {
                        if (CheckoutItemList[i].Total < 0) {
                            $scope.CustomerOrderModel.IsPartReturn = true;
                        }
                        if (!$scope.CustomerOrderModel.disableCheckOutItemAddAction(CheckoutItemList[i])) {
                            ChekoutAmt += CheckoutItemList[i].Total;
                        }
                    }
                }
                if (!$scope.CustomerOrderModel.IsTaxIncludingPricing) {
                    var totalTax = 0;
                    if ($scope.CustomerOrderModel.checkoutSalesTaxList != undefined) {
                        for (i = 0; i < $scope.CustomerOrderModel.checkoutSalesTaxList.length; i++) {
                            totalTax += $scope.CustomerOrderModel.checkoutSalesTaxList[i].TaxAmount;
                        }
                    }
                    ChekoutAmt += totalTax;
                }
                totalPayment = $scope.CustomerOrderModel.calculatePaymentTotal();
                if (ChekoutAmt != null && totalPayment != null) {
                    balanceDue = (ChekoutAmt).toFixed(2) - (totalPayment).toFixed(2);
                }
                balanceDue.toFixed(2) / 1;
                if ($scope.CustomerOrderModel.selectedOptionForCheckout == 'Cash' && isRealValue == undefined) {
                    balanceDue = $scope.CustomerOrderModel.CalculateCashPaymentRoundingAmount(balanceDue);
                }
                return balanceDue.toFixed(2) / 1;
            }
            $scope.CustomerOrderModel.PaymentAmountChange = function() {
                $scope.CustomerOrderModel.ChangeDue = $scope.CustomerOrderModel.Payment_Amount - $scope.CustomerOrderModel.RoundedBalanceDue;
                if ($scope.CustomerOrderModel.ChangeDue < 0) {
                    $scope.CustomerOrderModel.ChangeDue = 0.00;
                }
            }
            $scope.CustomerOrderModel.CalculateCashPaymentRoundingAmount = function(BalanceDue) {
                var CashPaymentRoundingDollarValue = $scope.CustomerOrderModel.CashPaymentRoundingCentValue / 100;
                var roundedBalanceDue = (Math.round(BalanceDue / CashPaymentRoundingDollarValue) * CashPaymentRoundingDollarValue).toFixed(2);
                roundedBalanceDue = parseFloat(roundedBalanceDue);
                $scope.CustomerOrderModel.RoundedBalanceDue = roundedBalanceDue;
                return roundedBalanceDue;
            }
            $scope.CustomerOrderModel.EnableFinaliseInvoice = function() {
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var IsEnable = false;
                if ($scope.CustomerOrderModel.checkOutMode == 'Customer') {
                    var balanceDue = $scope.CustomerOrderModel.calculateBalanceDue();
                    if (balanceDue == 0) {
                        for (i = 0; i < CheckoutItemList.length; i++) {
                            if (CheckoutItemList[i].IsActive && !$scope.CustomerOrderModel.disableCheckOutItemAddAction(CheckoutItemList[i])) {
                                IsEnable = true;
                                break;
                            }
                        }
                    }
                } else {
                    for (i = 0; i < CheckoutItemList.length; i++) {
                        if (CheckoutItemList[i].IsActive && !$scope.CustomerOrderModel.disableCheckOutItemAddAction(CheckoutItemList[i])) {
                            IsEnable = true;
                            break;
                        }
                    }
                }
                return IsEnable;
            }
            $scope.CustomerOrderModel.EnableFinaliseInvoice1 = function() {
                if (!$scope.CustomerOrderModel.EnableFinaliseOrder()) {
                    if ($scope.isInvoiceFinalizePressed == true) {
                        return true;
                    } else {
                        return false;
                    }
                } else {
                    if ($scope.isOrderFinalizePressed == true) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            $scope.CustomerOrderModel.EnableFinaliseOrder = function() {
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var IsEnable = true;
                for (i = 0; i < CheckoutItemList.length; i++) {
                    if (!(CheckoutItemList[i].IsFinalizable && CheckoutItemList[i].IsActive)) {
                        IsEnable = false;
                        break;
                    }
                }
                if ($scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.Id != undefined && $scope.CustomerOrderModel.DealInfo.Id != null && $scope.CustomerOrderModel.DealInfo.DealStatus != 'Invoiced' && $scope.CustomerOrderModel.DealInfo.DealStatus != 'Fulfilled') {
                    IsEnable = false;
                }
                if ($scope.CustomerOrderModel.calculateLeftPanelDeposits() > 0) {
                    IsEnable = false;
                }
                return IsEnable;
            }
            $scope.CustomerOrderModel.calculateInvoiceHistoryTotal = function() {
                var invoiceHistoryTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.InvoiceHistory.length; i++) {
                    if ($scope.CustomerOrderModel.InvoiceHistory[i].CheckoutType == 'Customer') {
                        invoiceHistoryTotal += $scope.CustomerOrderModel.InvoiceHistory[i].Total;
                    }
                }
                invoiceHistoryTotal = invoiceHistoryTotal.toFixed(2);
                return invoiceHistoryTotal;
            }
            $scope.CustomerOrderModel.MerchandiseGoAction = function(radioValue, kitHeaderId, Id, kitHeaderIndex, kitLineItemIndex) {
                var removelineitemId;
                if (radioValue == 0) {
                    if (kitHeaderId != null) {
                        removelineitemId = kitHeaderId;
                    } else {
                        removelineitemId = Id;
                    }
                    CustomerInfoService.removeLineItemsInMerchGrid(removelineitemId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.UpdateMerchandiseList(successfulSearchResult);
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else if (radioValue == 1) {
                    CustomerInfoService.splitCOKHItem(kitHeaderId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.UpdateMerchandiseList(successfulSearchResult);
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else if (radioValue == 2) {
                    $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].optionSelected;
                    $scope.createSpecialOrder($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[kitLineItemIndex], $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].optionSelected);
                } else if (radioValue == 3) {
                    if (kitHeaderId != null) {
                        if ($scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].MoveTosection == 'Merchandise') {
                            if (!($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                                Notification.error("You don't have permission to modify Merchandise section");
                                return;
                            }
                        }
                        if ($scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].MoveTosection != '' && $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].MoveTosection != null) {
                            var Idfrom = 'Merchandise';
                            SOHeaderService.moveLineItem(Idfrom, $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].MoveTosection, kitHeaderId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                                $scope.UpdateMerchandiseList(successfulSearchResult);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                                $scope.CustomerOrderModel.LoadServiceOrder();
                            });
                        } else {
                            $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].isEdit = false;
                            return;
                        }
                    } else {
                        var Idfrom = 'Merchandise';
                        if ($scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].MoveTosection == '+ Add New Service Job') {
                            if (!($rootScope.GroupOnlyPermissions['Service job']['create/modify'])) {
                                Notification.error("You don't have permission to create Service Job");
                                return;
                            }
                            if ($scope.CustomerOrderModel.Customer.Value == null) {
                                Notification.error($Label.CustomerOrder_Js_add_Customer_before_creating_Service);
                                return;
                            }
                            if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                                Notification.error($Label.CustomerOrder_Js_Can_t_create_Service);
                                return;
                            }
                            $scope.CustomerOrderModel.createSOHeader(kitHeaderIndex, kitLineItemIndex, Idfrom, Id, createSOHeaderCallBackFunction);
                        } else {
                            if (!($rootScope.GroupOnlyPermissions['Service job']['create/modify'])) {
                                Notification.error("You don't have permission to modify Service Job");
                                return;
                            }
                            SOHeaderService.moveLineItem(Idfrom, $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].MoveTosection, Id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                                $scope.UpdateMerchandiseList(successfulSearchResult);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                                $scope.CustomerOrderModel.LoadServiceOrder();
                            })
                        }
                    }
                }
            }

            function createSOHeaderCallBackFunction(kitHeaderIndex, kitLineItemIndex, Idfrom, Id) {
                if (!($rootScope.GroupOnlyPermissions['Service job']['create/modify'])) {
                    Notification.error("You don't have permission to modify Service Job");
                    return;
                }
                $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].MoveTosection = $scope.CustomerOrderModel.serviceOrderList[0].Id;
                SOHeaderService.moveLineItem(Idfrom, $scope.CustomerOrderModel.MerchandiseItems_editRow[kitHeaderIndex].lineItems[kitLineItemIndex].MoveTosection, Id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.UpdateMerchandiseList(successfulSearchResult);
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.LoadServiceOrder();
                })
            }
            $scope.CustomerOrderModel.editLineItemsForOptionFees = function() {
                $scope.CustomerOrderModel.OptionFeesItems_editRow = [];
                var DealItems = [];
                var rowNumber = 0;
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    DealItems.push({
                        isEdit: false,
                        KitHeaderItems: []
                    });
                    rowNumber = 0;
                    for (j = 0; j < $scope.CustomerOrderModel.DealItemList[i].DealKitHeaderList.length; j++) {
                        if ($scope.CustomerOrderModel.DealItemList[i].DealKitHeaderList[j].Id != null) {
                            rowNumber++;
                        }
                        DealItems[i].KitHeaderItems.push({
                            isEdit: false,
                            OptionFees: [],
                            radioValue: 0,
                            rowNumber: rowNumber
                        });
                        if ($scope.CustomerOrderModel.DealItemList[i].DealKitHeaderList[j].OptionAndFeeList != undefined) {
                            for (k = 0; k < $scope.CustomerOrderModel.DealItemList[i].DealKitHeaderList[j].OptionAndFeeList.length; k++) {
                                rowNumber++;
                                DealItems[i].KitHeaderItems[j].OptionFees.push({
                                    isEdit: false,
                                    optionSelected: 0,
                                    radioValue: 0,
                                    rowNumber: rowNumber,
                                    IsEnvFee: $scope.CustomerOrderModel.DealItemList[i].DealKitHeaderList[j].OptionAndFeeList[k].IsEnvFee
                                });
                            }
                        }
                    }
                }
                $scope.CustomerOrderModel.OptionFeesItems_editRow = DealItems;
            }
            $scope.CustomerOrderModel.editUnresolvedFulfillmentSection = function(event, UnresolvedFulfillmentIndex) {
                if (!$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.BlurcalledForUnresolvedFulfillment) {
                    $scope.CustomerOrderModel.allowBlurForUnresolvedFulfillment = false;
                }
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                var isEditModeEnabled = false;
                var UnresolvedFulfillments = [];
                if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length; i++) {
                        if ($scope.CustomerOrderModel.editUnresolvedFulfillment_editRow[i].isEdit == true) {
                            UnresolvedFulfillments.push($scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i]);
                            $scope.CustomerOrderModel.editUnresolvedFulfillment_editRow[i].isEdit = false;
                            isEditModeEnabled = true;
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    var lineItem = $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[UnresolvedFulfillmentIndex];
                    $scope.CustomerOrderModel.editUnresolvedFulfillment_editRow[UnresolvedFulfillmentIndex].isEdit = true;
                }
            }
            $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList = function() {
                $scope.CustomerOrderModel.editUnresolvedFulfillment_editRow = [];
                var UnresolvedFulfillments = [];
                if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length; i++) {
                        UnresolvedFulfillments.push({
                            isEdit: false,
                            optionSelected: 0
                        });
                    }
                }
                $scope.CustomerOrderModel.editUnresolvedFulfillment_editRow = UnresolvedFulfillments;
            }
            $scope.CustomerOrderModel.editOptionFeesItem = function(event, dealHeaderIndex, optionFeeKitHeaderIndex, optionFeesLineItemIndex, focusElementId) {
                if (!$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.Blurcalled1) {
                    $scope.CustomerOrderModel.allowBlur1 = false;
                }
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if (event.target.nodeName == 'I' || $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                var isEditModeEnabled = false;
                var isKit = false;
                var lineitem = [];
                var editedKitLineItem = null;
                for (i = 0; i < $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems.length; i++) {
                    if ($scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[i].isEdit == true) {
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i];
                        optionFeeKitHeaderIndex = i;
                        if ($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i].Id != null) {
                            isKit = true;
                        }
                    } else if (!isEditModeEnabled) {
                        for (j = 0; j < $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[i].OptionFees.length; j++) {
                            if ($scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[i].OptionFees[j].isEdit == true) {
                                isEditModeEnabled = true;
                                if ($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList != undefined && $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList.length > 0) {
                                    if ($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i].Id != null) {
                                        isKit = true;
                                        lineitem = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i];
                                        editedKitLineItem = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i].OptionAndFeeList[j];
                                    } else {
                                        lineitem.push($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[i].OptionAndFeeList[j]);
                                    }
                                    optionFeeKitHeaderIndex = i;
                                    optionFeesLineItemIndex = j;
                                }
                            }
                        }
                    }
                }
                if (optionFeesLineItemIndex != null) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList.length; i++) {
                        if ($scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].OptionFees[i].isEdit == true) {
                            lineItem = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList[i];
                            optionFeesLineItemIndex = i;
                            isEditModeEnabled = true;
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    if (optionFeesLineItemIndex != null) {
                        var lineItem = $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList[optionFeesLineItemIndex];
                        if ($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList[optionFeesLineItemIndex].Status == 'Invoiced' || $scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList[optionFeesLineItemIndex].Status == 'Fulfilled' || $scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced' || $scope.CustomerOrderModel.DealInfo.DealStatus == 'Fulfilled') {
                            return;
                        }
                        $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].OptionFees[optionFeesLineItemIndex].isEdit = true;
                    } else {
                        $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].isEdit = true;
                    }
                    setTimeout(function() {
                        angular.element(event.target).closest('tr').next().find('input[type=text]').filter(':visible:first').focus();
                    }, 10);
                } else {
                    if (isKit) {
                        $scope.CustomerOrderModel.updateOptionAndFeeLineItem(lineitem, editedKitLineItem, dealHeaderIndex, optionFeesLineItemIndex);
                        setTimeout(function() {
                            if (editedKitLineItem == null) {
                                $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].isEdit = false;
                            } else {
                                $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].OptionFees[optionFeesLineItemIndex].isEdit = false;
                            }
                        }, 100);
                    } else {
                        $scope.CustomerOrderModel.saveOptionAndFeeLineItem($scope.CustomerOrderModel.DealItemList[dealHeaderIndex].DealKitHeaderList[optionFeeKitHeaderIndex].OptionAndFeeList[optionFeesLineItemIndex].DealId, lineitem[0].DealItemId, event, dealHeaderIndex, optionFeesLineItemIndex, 'CO_SearchToAdd_value', lineitem[0]);
                        setTimeout(function() {
                            $scope.CustomerOrderModel.OptionFeesItems_editRow[dealHeaderIndex].KitHeaderItems[optionFeeKitHeaderIndex].OptionFees[optionFeesLineItemIndex].isEdit = false;
                        }, 100);
                    }
                }
            }
            $scope.CustomerOrderModel.updateOptionAndFeeLineItem = function(lineitem, optionandFeeJSON, dealHeaderIndex, optionFeesLineItemIndex) {
                DealService.recalculationOfDealKHLineItems(angular.toJson(lineitem), angular.toJson(optionandFeeJSON)).then(function(successfulSearchResult) {
                    if (successfulSearchResult.error.ResponseCode == '300') {
                        Notification.error(successfulSearchResult.error.ResponseMeassage);
                    }
                    $scope.CustomerOrderModel.DealItemList[dealHeaderIndex] = successfulSearchResult;
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveOptionAndFeeLineItem = function(dealId, dealItemId, event, dealIndex, optionFeesLineItemIndex, focusElementId, optionFeeItemJSON) {
                DealService.saveOptionFeesLineItem(dealId, dealItemId, angular.toJson(optionFeeItemJSON)).then(function(successfulSearchResult) {
                    if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'In Progress' && $scope.CustomerOrderModel.DealItemList[dealIndex].DealItemObj.OptionAndFeeStatus == 'Committed') {
                        $scope.CustomerOrderModel.DealItemList[dealIndex] = successfulSearchResult;
                        $scope.CustomerOrderModel.LoadServiceOrder();
                    } else {
                        $scope.CustomerOrderModel.DealItemList[dealIndex] = successfulSearchResult;
                    }
                    $scope.CustomerOrderModel.updateDealSummaryTotals();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.editRowTabOutOptionFeesQtyLineItem = function(event, dealIndex, optionFeesLineItemIndex, optionFeesKitHeaderItemIndex, focusElementId) {
                var lineitem = $scope.CustomerOrderModel.DealItemList[dealIndex].DealKitHeaderList[optionFeesKitHeaderItemIndex];
                var editedKitLineItem = $scope.CustomerOrderModel.DealItemList[dealIndex].DealKitHeaderList[optionFeesKitHeaderItemIndex].OptionAndFeeList[optionFeesLineItemIndex];
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.Blurcalled1 = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlur1 == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            if ($scope.CustomerOrderModel.DealItemList[dealIndex].DealKitHeaderList[optionFeesKitHeaderItemIndex].Id != null) {
                                $scope.CustomerOrderModel.updateOptionAndFeeLineItem(lineitem, editedKitLineItem, dealIndex, optionFeesLineItemIndex);
                            } else {
                                $scope.CustomerOrderModel.saveOptionAndFeeLineItem(editedKitLineItem.DealId, editedKitLineItem.DealItemId, event, dealIndex, optionFeesLineItemIndex, 'CO_SearchToAdd_value', editedKitLineItem);
                            }
                        }
                        $scope.CustomerOrderModel.allowBlur1 = true;
                        $scope.CustomerOrderModel.Blurcalled1 = false;
                        return;
                    }, 300);
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlur1 = false;
                    if ($scope.CustomerOrderModel.DealItemList[dealIndex].DealKitHeaderList[optionFeesKitHeaderItemIndex].OptionAndFeeList[optionFeesLineItemIndex].Qty === '') {
                        $scope.CustomerOrderModel.DealItemList[dealIndex].DealKitHeaderList[optionFeesKitHeaderItemIndex].OptionAndFeeList[optionFeesLineItemIndex].Qty = 1;
                    }
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.editLineItemsForDealMerchandise = function() {
                $scope.CustomerOrderModel.DealMerchandiseItems_editRow = [];
                var DealMerchandiseItems = [];
                var rowNumber = 0;
                if ($scope.CustomerOrderModel.DealMerchandiseList != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.DealMerchandiseList.length; i++) {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[i].Id != null) {
                            rowNumber++;
                        }
                        DealMerchandiseItems.push({
                            isEdit: false,
                            DealCOLIList: [],
                            radioValue: 0,
                            rowNumber: rowNumber
                        });
                        if ($scope.CustomerOrderModel.DealMerchandiseList[i].COLIList != undefined) {
                            for (j = 0; j < $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList.length; j++) {
                                rowNumber++;
                                DealMerchandiseItems[i].DealCOLIList.push({
                                    isEdit: false,
                                    optionSelected: 0,
                                    radioValue: 0,
                                    rowNumber: rowNumber
                                });
                            }
                        }
                    }
                }
                $scope.CustomerOrderModel.DealMerchandiseItems_editRow = DealMerchandiseItems;
            }
            $scope.CustomerOrderModel.editDealMerchandiseItems = function(event, DealCOKHIndex, DealCOLIIndex, refreshGrid) {
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    return;
                }
                if ($scope.CustomerOrderModel.BlurcalledForDealMerch) {
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                }
                if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].Status == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                var isEditModeEnabled = false;
                var isKit = false;
                var lineitem = [];
                var editedKitLineItem = null;
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if (angular.isDefined(event.parentElement)) {
                    if (event.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 && event.type != 'keydown') {
                        return;
                    }
                }
                if ((event.target.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.target.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                    return;
                }
                if (angular.isDefined(event.toElement)) {
                    if ((event.toElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.toElement.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                        return;
                    }
                }
                if (event.target.parentElement.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1) {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                for (i = 0; i < $scope.CustomerOrderModel.DealMerchandiseItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                        if ($scope.CustomerOrderModel.DealMerchandiseList[i].Id != null) {
                            isKit = true;
                        }
                    } else if (!isEditModeEnabled) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].DealCOLIList.length; j++) {
                            if ($scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].DealCOLIList[j].isEdit == true) {
                                isEditModeEnabled = true;
                                if ($scope.CustomerOrderModel.DealMerchandiseList[i].Id != null) {
                                    isKit = true;
                                    lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                                    editedKitLineItem = $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[j];
                                } else {
                                    lineitem.push($scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[j]);
                                }
                            }
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    DealService.getDealData($scope.CustomerOrderModel.DealInfo.Id, 'dealMerchandise').then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.DealMerchandiseList.length; i++) {
                            for (var item = 0; item < successfulSearchResult.DealMerchandiseList[i].COLIList.length; item++) {
                                if ($scope.CustomerOrderModel.DealMerchandiseList[i] != undefined && $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[item] != undefined) {
                                    $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[item].AvaliablePartsQty = successfulSearchResult.DealMerchandiseList[i].COLIList[item].AvaliablePartsQty;
                                }
                            }
                        }
                        var lineItem = $scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex];
                        var focusElement = angular.element(event.target).closest('tr').next().find('input').not('.descEditInput').filter(':first');
                        if (DealCOLIIndex != null) {
                            if (lineItem.Status == 'Ordered') {
                                $scope.CustomerOrderModel.openRemoveItemConfirmationPopup(lineItem, null, DealCOKHIndex, DealCOLIIndex, focusElement, 'DealMerchandise');
                                return;
                            }
                            if (!(lineItem.Status == 'Invoiced')) {
                                $scope.CustomerOrderModel.openEditModeDealMerchRow(lineItem, DealCOKHIndex, DealCOLIIndex, focusElement);
                            }
                        } else {
                            $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].isEdit = true;
                        }
                        setTimeout(function() {
                            focusElement.focus();
                        }, 10);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (isKit) {
                        $scope.CustomerOrderModel.SaveDealkitInMerchandise(lineitem, editedKitLineItem, refreshGrid);
                    } else {
                        $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineitem, refreshGrid);
                    }
                }
            }
            $scope.CustomerOrderModel.openEditModeDealMerchRow = function(lineItem, DealCOKHIndex, DealCOLIIndex, element) {
                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].DealCOLIList[DealCOLIIndex].isEdit = true;
                $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = lineItem.QtyCommitted;
                $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = lineItem.AvaliablePartsQty;
                $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue = lineItem.Qty;
                if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VendorId != null) {
                    SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VendorId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = successfulSearchResult;
                        for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                            if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].DealCOLIList[DealCOLIIndex].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                break;
                            }
                        }
                    })
                }
                setTimeout(function() {
                    element.focus();
                }, 10);
            }
            $scope.CustomerOrderModel.DealMerchandiseGoAction = function(radioValue, dealkitHeaderId, dealMerchandiesLineItemId, dealKitHeaderIndex, dealMerchandiesLineItemIndex) {
                var removelineitemId;
                if (radioValue == 0) {
                    if (dealkitHeaderId != null) {
                        removelineitemId = dealkitHeaderId;
                    } else {
                        removelineitemId = dealMerchandiesLineItemId;
                    }
                    CustomerInfoService.removeLineItemsInMerchGrid(removelineitemId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                        $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                        $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                        $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                        $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                        $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                        $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                        if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                            $scope.CustomerOrderModel.StockUnitMap();
                        }
                        CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'user,coInvoiceHeader').then(function(successfulSearchResult1) {
                            $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                            $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                        }, function(errorSearchResult) {
                            console.log(errorSearchResult); //TODO
                        });
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = 0;
            $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = 0;
            $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue = 0;
            $scope.CustomerOrderModel.editDealRowBlur = function(event, dealKitHeaderIndex, lineItemIndex, focusElementId) {
                var oldCommitQty = 0;
                var OldAvailableQty = 0;
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForDealMerch = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForDealMerch == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.SaveDealMerchOnBlur(event, dealKitHeaderIndex, lineItemIndex, true);
                        }
                        $scope.CustomerOrderModel.allowBlurForDealMerch = true;
                        $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
                        return;
                    }, 300);
                };
                if (!event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                    calculateDealMerchCommited(event, dealKitHeaderIndex, lineItemIndex, focusElementId);
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    consol.log('allow blur');
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                }
            }

            function calculateDealMerchCommited(event, dealKitHeaderIndex, lineItemIndex, focusElementId) {
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty = ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty == '') ? 1 : $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty;
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == null) {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = 0;
                }
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty == '') {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty = 1;
                }
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = parseFloat($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted);
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty = parseFloat($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty);
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty = parseFloat($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty);
                var MaxCommit = parseFloat($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue) + parseFloat($scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue);
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty != $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue) {
                    if (!$rootScope.GroupOnlyPermissions['Returns'].enabled && $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue < 0) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty = $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue;
                    }
                    $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Price;
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty > MaxCommit) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = (MaxCommit > 0 ? MaxCommit : 0);
                        if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status = 'Required';
                        }
                    } else {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty;
                        if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status = 'In Stock';
                        }
                    }
                    $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty;
                } else if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted != $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue) {
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted >= $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty;
                    }
                    var COLI_QtyCommitted = parseFloat($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted);
                    var COLI_OldQtyCommitted = parseFloat($scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue);
                    if (parseFloat($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted) > parseFloat(MaxCommit)) {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            if (!$rootScope.GroupOnlyPermissions['Oversell inventory']['enabled'] && (COLI_QtyCommitted > COLI_OldQtyCommitted)) {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = COLI_OldQtyCommitted;
                            } else {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status = 'Oversold';
                            }
                        }
                    } else if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted <= MaxCommit && $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty == $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status = 'In Stock';
                    } else {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Status = 'Required';
                        }
                    }
                }
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted - $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue));
                $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted;
                $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty;
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Price;
                $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyOrder = $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].Qty - $scope.CustomerOrderModel.DealMerchandiseList[dealKitHeaderIndex].COLIList[lineItemIndex].QtyCommitted;
            }
            $scope.CustomerOrderModel.editDealRowBlurCommited = function(event, kitHeaderIndex, lineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    if ($scope.CustomerOrderModel.DealMerchandiseList[kitHeaderIndex].COLIList[lineItemIndex].IsPart) {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.DealMerchandiseList[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == 'undefined') {
                            $scope.CustomerOrderModel.DealMerchandiseList[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = 0;
                        }
                        calculateDealMerchCommited(event, kitHeaderIndex, lineItemIndex, focusElementId);
                    }
                }
            }
            $scope.CustomerOrderModel.editRowTabOutForDealMerch = function(event, DealkitHeaderIndex, lineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    angular.element('#CO_SearchToAdd_value').focus();
                    $scope.CustomerOrderModel.editDealMerchandiseItems(event, DealkitHeaderIndex, lineItemIndex, true);
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.SaveDealMerchOnBlur = function(event, DealCOKHIndex, DealCOLIIndex, refreshGrid) {
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    return;
                }
                var isEditModeEnabled = false;
                var isKit = false;
                var lineitem = [];
                var editedKitLineItem = null;
                for (i = 0; i < $scope.CustomerOrderModel.DealMerchandiseItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                        if ($scope.CustomerOrderModel.DealMerchandiseList[i].Id != null) {
                            isKit = true;
                        }
                    } else if (!isEditModeEnabled) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].DealCOLIList.length; j++) {
                            if ($scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].DealCOLIList[j].isEdit == true) {
                                isEditModeEnabled = true;
                                if ($scope.CustomerOrderModel.DealMerchandiseList[i].Id != null) {
                                    isKit = true;
                                    lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                                    editedKitLineItem = $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[j];
                                } else {
                                    lineitem.push($scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[j]);
                                }
                            }
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'coLineItem,user').then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.COKHList.length; i++) {
                            for (var item = 0; item < successfulSearchResult.COKHList[i].COLIList.length; item++) {
                                if ($scope.CustomerOrderModel.DealMerchandiseList[i] != undefined && $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[item] != undefined) {
                                    $scope.CustomerOrderModel.DealMerchandiseList[i].COLIList[item].AvaliablePartsQty = successfulSearchResult.COKHList[i].COLIList[item].AvaliablePartsQty;
                                }
                            }
                        }
                        var lineItem = $scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex];
                        if (DealCOLIIndex != null) {
                            if (!(lineItem.Status == 'Invoiced')) {
                                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].DealCOLIList[DealCOLIIndex].isEdit = true;
                                $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = lineItem.QtyCommitted;
                                $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = lineItem.AvaliablePartsQty;
                                if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VendorId != null) {
                                    SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VendorId).then(function(successfulSearchResult) {
                                        $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = successfulSearchResult;
                                        for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                                            if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].lineItems[DealCOLIIndex].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                                break;
                                            }
                                        }
                                    })
                                }
                            }
                        } else {
                            $scope.CustomerOrderModel.DealMerchandiseItems_editRow[DealCOKHIndex].isEdit = true;
                        }
                        setTimeout(function() {
                            angular.element(event.target).closest('tr').next().find('input').not('.descEditInput').filter(':first').focus();
                        }, 10);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (isKit) {
                        $scope.CustomerOrderModel.SaveDealkitInMerchandise(lineitem, editedKitLineItem, refreshGrid);
                    } else {
                        $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineitem, refreshGrid);
                    }
                }
            }
            $scope.CustomerOrderModel.SaveDealMerchandiseToServer = function(lineItem, isUpdateGrid) {
                if (lineItem.IsFee) {
                    lineItem.QtyCommitted = lineItem.Qty;
                }
                $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = lineItem.QtyCommitted;
                $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = lineItem.AvaliablePartsQty;
                $scope.CustomerOrderModel.DealMerchandiseEditOldQtyValue = lineItem.Qty;
                userService.SaveMerchandiseLineItem($scope.CustomerOrderModel.coHeaderId, JSON.stringify(lineItem)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        $scope.CustomerOrderModel.StockUnitMap();
                    }
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'user,coInvoiceHeader').then(function(successfulSearchResult) {
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.searching = false;
                });
            }
            $scope.CustomerOrderModel.SaveDealkitInMerchandise = function(dealMerchandiesKitHeaderJSON, dealMerchandiesLineJSON, refreshGrid) {
                CustomerInfoService.updateCOKHLineItemsRecalculation(angular.toJson(dealMerchandiesKitHeaderJSON), $scope.CustomerOrderModel.coHeaderId, angular.toJson(dealMerchandiesLineJSON)).then(function(successfulSearchResult) {
                    if (successfulSearchResult.error.ResponseCode == '300') {
                        Notification.error(successfulSearchResult.error.ResponseMeassage);
                    }
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                    if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        $scope.CustomerOrderModel.StockUnitMap();
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.specialCaseForCashSaleCOTypeForDeal = function(DealCOKHIndex, DealCOLIIndex, isEditModeEnabled) {
                if ($scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex] != undefined) {
                    var lineItem = $scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex];
                    if (isEditModeEnabled) {}
                    $scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].PreviousQtyNeed = $scope.CustomerOrderModel.DealMerchandiseList[DealCOKHIndex].COLIList[DealCOLIIndex].Qty;
                }
                return true;
            }
            $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = 0;
            $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = 0;
            $scope.CustomerOrderModel.editRowBlurDealMerch = function(event, lineItemIndex, focusElementId) {
                var oldCommitQty = 0;
                var OldAvailableQty = 0;
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForDealMerch = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForDealMerch == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.saveOnBlurDealMerch(event, lineItemIndex, true, ValuetoBlur);
                        }
                        $scope.CustomerOrderModel.allowBlurForDealMerch = true;
                        $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
                        return;
                    }, 300);
                };
                if (!event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                    if ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty == '') {
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty = 1;
                    }
                    if ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty > ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue)) {
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue;
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Price;
                    } else {
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty;
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Price;
                    }
                    if ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Qty > $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted) {
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Status = 'Required';
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].AvaliablePartsQty = 0;
                    } else {
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].Status = 'In Stock';
                        $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted - $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue))
                    }
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    consol.log('allow blur');
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                }
            }
            $scope.CustomerOrderModel.saveOnBlurDealMerch = function(event, COLIIndex, refreshGrid, ValuetoBlur) {
                var isEditModeEnabled = false;
                var lineitem = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealMerchandiseList.length; i++) {
                    if ($scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].isEdit == true) {
                        $scope.CustomerOrderModel.DealMerchandiseItems_editRow[i].isEdit = false;
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.DealMerchandiseItems_editRow[COLIIndex].isEdit = true;
                    if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                        lineitem = $scope.CustomerOrderModel.DealMerchandiseList[i];
                    } else {
                        lineitem.push($scope.CustomerOrderModel.DealMerchandiseList[i]);
                    }
                    setTimeout(function() {
                        elementId = angular.element('#' + ValuetoBlur).focus();
                        angular.element(elementId).find('input[type=text]').filter(':visible:first').focus();
                    }, 10);
                }
                if (!isEditModeEnabled) {
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'coLineItem,user').then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.COKHList.length; i++) {
                            for (var item = 0; item < successfulSearchResult.COKHList[i].COLIList.length; item++) {
                                if ($scope.CustomerOrderModel.DealMerchandiseList[i] != undefined) {
                                    $scope.CustomerOrderModel.DealMerchandiseList[item].AvaliablePartsQty = successfulSearchResult.COKHList[i].COLIList[item].AvaliablePartsQty;
                                }
                            }
                        }
                        var lineitem = $scope.CustomerOrderModel.DealMerchandiseList[COLIIndex];
                        if (COLIIndex != null) {
                            if (!(lineitem.Status == 'Invoiced')) {
                                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[COLIIndex].isEdit = true;
                                $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = lineitem.QtyCommitted;
                                $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = lineitem.AvaliablePartsQty;
                                if ($scope.CustomerOrderModel.DealMerchandiseList[COLIIndex].VendorId != null) {
                                    SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.DealMerchandiseList[COLIIndex].VendorId).then(function(successfulSearchResult) {
                                        $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = successfulSearchResult;
                                        for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                                            if ($scope.CustomerOrderModel.DealMerchandiseList[COLIIndex].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                                $scope.CustomerOrderModel.DealMerchandiseItems_editRow[COLIIndex].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                                break;
                                            }
                                        }
                                    })
                                }
                            }
                        } else {
                            $scope.CustomerOrderModel.DealMerchandiseItems_editRow[COLIIndex].isEdit = true;
                        }
                        setTimeout(function() {
                            angular.element(event.target).closest('tr').next().find('input').not('.descEditInput').filter(':first').focus();
                        }, 10);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineitem, refreshGrid);
                }
            }
            $scope.CustomerOrderModel.editRowBlurCommitedDealMerch = function(event, lineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    if ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].IsPart) {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted == 'undefined') {
                            $scope.CustomerOrderModel.DealMerchandiseList[lineItemIndex].QtyCommitted = 0;
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.editRowTabOutDealMerch = function(event, lineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    angular.element('#CO_SearchToAdd_value').focus();
                    CustomerOrderModel.editDealMerchandiseItems(event, lineItemIndex);
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.editRowBlurDealMerchPrice = function(event, dealMerchLineItemIndex, focusElementId) {
                var lineItem = [];
                lineItem.push($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex]);
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForDealMerch = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForDealMerch == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineItem, true);
                        }
                        $scope.CustomerOrderModel.allowBlurForDealMerch = true;
                        $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
                        return;
                    }, 300);
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                    $scope.setFocus1();
                    angular.element('#CO_SearchToAdd_value').focus();
                    $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineItem, true);
                    $scope.CustomerOrderModel.editDealMerchandiseItems(event, dealMerchLineItemIndex);
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    setTimeout(function() {
                        angular.element(event.target).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    event.preventDefault();
                }
            }
            $scope.CustomerOrderModel.UpdateDealGridFields = function(dealMerchLineItemIndex) {
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty == '') {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty = 1;
                }
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue)) {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue;
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                } else {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty;
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                }
                if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted) {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'Required';
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = 0;
                } else {
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'In Stock';
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted - $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue))
                }
            }
            $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue = 0;
            $scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue = 0;
            $scope.CustomerOrderModel.editRowBlurDealMerchQty = function(event, dealMerchLineItemIndex, focusElementId) {
                var lineItem = [];
                lineItem.push($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex]);
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForDealMerch = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForDealMerch == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty == '') {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty = 1;
                            }
                            if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue)) {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue) > 0 ? ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue) : 0;
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                            } else {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty;
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                            }
                            if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted) {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'Required';
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = 0;
                            } else {
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'In Stock';
                                $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted - $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue));
                            }
                            $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyOrder = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty - $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted;
                            $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineItem, true);
                        }
                        $scope.CustomerOrderModel.allowBlurForDealMerch = true;
                        $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
                        return;
                    }, 300);
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty == '') {
                        $
                        scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty = 1;
                    }
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue)) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue) > 0 ? ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue + $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue) : 0;
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                    } else {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty;
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].SubTotal = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty * $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Price;
                    }
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty > $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted) {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'Required';
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = 0;
                    } else {
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Status = 'In Stock';
                        $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.DealMerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted - $scope.CustomerOrderModel.DealMerchandiseEditOldCommitedValue))
                    }
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyOrder = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty - $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted;
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.editRowBlurDealMerchCommited = function(event, dealMerchLineItemIndex, focusElementId) {
                var lineItem = [];
                lineItem.push($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex]);
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForDealMerch = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForDealMerch == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].IsPart) {
                                if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted == 'undefined') {
                                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = 0;
                                }
                            }
                            $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyOrder = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty - $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted;
                            $scope.CustomerOrderModel.SaveDealMerchandiseToServer(lineItem, true);
                        }
                        $scope.CustomerOrderModel.allowBlurForDealMerch = true;
                        $scope.CustomerOrderModel.BlurcalledForDealMerch = false;
                        return;
                    }, 300);
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlurForDealMerch = false;
                    if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].IsPart) {
                        if ($scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted == 'undefined') {
                            $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted = 0;
                        }
                    }
                    $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyOrder = $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].Qty - $scope.CustomerOrderModel.DealMerchandiseList[dealMerchLineItemIndex].QtyCommitted;
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.editFactoryItem = function($event, DealUnitIndex, factoryItemIndex) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                for (i = 0; i < $scope.CustomerOrderModel.FactoryItems_editRow[DealUnitIndex].length; i++) {
                    $scope.CustomerOrderModel.FactoryItems_editRow[DealUnitIndex].factoryOrderLineItems[i].isEdit = false;
                }
                $scope.CustomerOrderModel.FactoryItems_editRow[DealUnitIndex].factoryOrderLineItems[factoryItemIndex].isEdit = true;
            }
            $scope.CustomerOrderModel.editFactoryOptionRowTabOut = function(event, dealId, dealItemId, dealItemIndex, factoryItemIndex) {
                if (!event.shiftKey && event.keyCode == 9) {
                    if ($scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList[factoryItemIndex].Price == undefined || $scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList[factoryItemIndex].Price == null || $scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList[factoryItemIndex].Price == '') {
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList[factoryItemIndex].Price = 0;
                    }
                    var factoryLineItemJson = $scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList;
                    DealService.updateDealUnitCostPrice(angular.toJson(factoryLineItemJson), dealId, dealItemId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].FactoryOptionList[factoryItemIndex] = successfulSearchResult.FactoryOptionList[factoryItemIndex];
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty = successfulSearchResult.TotalStampDuty;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalEnforceRideawayPrice = successfulSearchResult.TotalEnforceRideawayPrice;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalBasePrice = successfulSearchResult.TotalBasePrice;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalFactoryOption = successfulSearchResult.TotalFactoryOption;
                        $timeout(function timeout() {
                            $scope.CustomerOrderModel.editLineItemsForFactoryOptions();
                            $scope.CustomerOrderModel.editForStampDuty();
                            $scope.CustomerOrderModel.calculateFactoryTotal();
                            $scope.CustomerOrderModel.FactoryItems_editRow[dealItemIndex].factoryOrderLineItems[factoryItemIndex].isEdit = false;
                        }, 1000);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            $scope.CustomerOrderModel.editDealerInstalledOptionsItem = function($event, DealUnitIndex, dealerInstalledOptionsItemIndex) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                for (i = 0; i < $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[DealUnitIndex].length; i++) {
                    $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[DealUnitIndex].dealerInstalledOptionsLineItems[i].isEdit = false;
                }
                $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[DealUnitIndex].dealerInstalledOptionsLineItems[dealerInstalledOptionsItemIndex].isEdit = true;
            }
            $scope.CustomerOrderModel.editDealerInstalledOptionsRowTabOut = function(event, dealId, dealItemId, dealItemIndex, dealerInstalledOptionsItemIndex) {
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    if ($scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList[dealerInstalledOptionsItemIndex].Price == undefined || $scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList[dealerInstalledOptionsItemIndex].Price == null || $scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList[dealerInstalledOptionsItemIndex].Price == '') {
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList[dealerInstalledOptionsItemIndex].Price = 0;
                    }
                    var dealerInstalledOptionsItemJson = $scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList;
                    DealService.updateDealUnitCostPrice(angular.toJson(dealerInstalledOptionsItemJson), dealId, dealItemId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].DealerInstalledOptionList[dealerInstalledOptionsItemIndex] = successfulSearchResult.DealerInstalledOptionList[dealerInstalledOptionsItemIndex];
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty = successfulSearchResult.TotalStampDuty;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalEnforceRideawayPrice = successfulSearchResult.TotalEnforceRideawayPrice;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalBasePrice = successfulSearchResult.TotalBasePrice;
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalDealerInstalledOption = successfulSearchResult.TotalDealerInstalledOption;
                        $timeout(function timeout() {
                            $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions();
                            $scope.CustomerOrderModel.editForStampDuty();
                            $scope.CustomerOrderModel.calculateFactoryTotal();
                            $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[dealItemIndex].dealerInstalledOptionsLineItems[dealerInstalledOptionsItemIndex].isEdit = false;
                        }, 1000);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            $scope.CustomerOrderModel.openRemoveItemConfirmationPopup = function(lineItem, FirstIndex, SecondIndex, ThirdIndex, focusElement, Section) {
                $scope.CustomerOrderModel.SPLineItem = angular.copy(lineItem);
                $scope.CustomerOrderModel.SPFirstIndex = FirstIndex;
                $scope.CustomerOrderModel.SPSecondIndex = SecondIndex;
                $scope.CustomerOrderModel.SPThirdIndex = ThirdIndex;
                $scope.CustomerOrderModel.SPfocusElement = focusElement;
                $scope.CustomerOrderModel.SPSection = Section;
                angular.element('#RemoveItemConfirmationPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }
            $scope.CustomerOrderModel.closeRemoveItemConfirmationPopup = function() {
                if ($scope.CustomerOrderModel.SPSection == 'Merchandise') {
                    $scope.CustomerOrderModel.openEditModeMerchRow($scope.CustomerOrderModel.SPLineItem, $scope.CustomerOrderModel.SPSecondIndex, $scope.CustomerOrderModel.SPThirdIndex, $scope.CustomerOrderModel.SPfocusElement);
                } else if ($scope.CustomerOrderModel.SPSection == 'DealMerchandise') {
                    $scope.CustomerOrderModel.openEditModeDealMerchRow($scope.CustomerOrderModel.SPLineItem, $scope.CustomerOrderModel.SPSecondIndex, $scope.CustomerOrderModel.SPThirdIndex, $scope.CustomerOrderModel.SPfocusElement);
                } else if ($scope.CustomerOrderModel.SPSection == 'Service') {
                    $scope.CustomerOrderModel.openEditModeServiceRow($scope.CustomerOrderModel.SPLineItem, $scope.CustomerOrderModel.SPFirstIndex, $scope.CustomerOrderModel.SPSecondIndex, $scope.CustomerOrderModel.SPThirdIndex, $scope.CustomerOrderModel.SPfocusElement);
                } else {}
                $scope.CustomerOrderModel.closePopupRemoveItemConfirmation();
            }
            $scope.CustomerOrderModel.hideRemoveItemConfirmationPopup = function() {
                $scope.CustomerOrderModel.SPSection = '';
                $scope.CustomerOrderModel.closePopupRemoveItemConfirmation();
            }
            $scope.CustomerOrderModel.closePopupRemoveItemConfirmation = function() {
                angular.element('#RemoveItemConfirmationPopup').modal('hide');
            }
            $scope.removeMerchandiseItem = function(id) {
                CustomerInfoService.removeCOLineItem(id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.UpdateMerchandiseList(successfulSearchResult);
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.createSpecialOrder = function(merchItem, voHeaderId) {
                $scope.CustomerOrderModel.itemsPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "ItemDesc",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.itemsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                $scope.CustomerOrderModel.customersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.customersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                $scope.CustomerOrderModel.stocksPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.stocksPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                merchItem.isSpecialOrder = true;
                CustomerInfoService.createSpecialOrder(merchItem.partId, merchItem.CoLineItemId, voHeaderId, $scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.itemsPageSortAttrsJSON), JSON.stringify($scope.CustomerOrderModel.customersPageSortAttrsJSON), JSON.stringify($scope.CustomerOrderModel.stocksPageSortAttrsJSON)).then(function(successfulSearchResult) {
                    $scope.UpdateMerchandiseList(successfulSearchResult);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.SavekitInMerchandise = function(lineItem, editedKitLineItem, isUpdateGrid) {
                CustomerInfoService.updateCOKHLineItemsRecalculation(angular.toJson(lineItem), $scope.CustomerOrderModel.coHeaderId, angular.toJson(editedKitLineItem)).then(function(successfulSearchResult) {
                    if (isUpdateGrid) {
                        $scope.UpdateMerchandiseList(successfulSearchResult);
                    } else {
                        $scope.UpdateMerchandiseListonTabOut(successfulSearchResult);
                    }
                    if (successfulSearchResult.error.ResponseCode == '300') {
                        Notification.error(successfulSearchResult.error.ResponseMeassage);
                    }
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.searching = false;
                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                });
            }
            $scope.SaveMerchandiseToserver = function(lineItem, isUpdateGrid) {
                if (lineItem[0].IsFee) {
                    lineItem[0].QtyCommitted = lineItem[0].Qty;
                }
                userService.SaveMerchandiseLineItem($scope.CustomerOrderModel.coHeaderId, JSON.stringify(lineItem)).then(function(successfulSearchResult) {
                    if (isUpdateGrid) {
                        $scope.UpdateMerchandiseList(successfulSearchResult);
                    } else {
                        $scope.CustomerOrderModel.MerchandiseItems = successfulSearchResult.COKHList;;
                    }
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    $scope.searching = false;
                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                });
            }
            $scope.CustomerOrderModel.Deal.addUnitToDeal = function() {
                $scope.CustomerOrderModel.Deal.DealItemList.add()
            }
            $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = [];
            $scope.CustomerOrderModel.editMerchItem = function(event, COKHIndex, COLIIndex, refreshGrid) {
                if (!$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    return;
                }
                if ($scope.CustomerOrderModel.Blurcalled) {
                    $scope.CustomerOrderModel.allowBlur = false;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                var isEditModeEnabled = false;
                var isKit = false;
                var lineitem = [];
                var editedKitLineItem = null;
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if (angular.isDefined(event.parentElement)) {
                    if (event.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 && event.type != 'keydown') {
                        return;
                    }
                }
                if ((event.target.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.target.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                    return;
                }
                if (angular.isDefined(event.toElement)) {
                    if ((event.toElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.toElement.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                        return;
                    }
                }
                if (event.target.parentElement.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1) {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.MerchandiseItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.MerchandiseItems[i];
                        if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                            isKit = true;
                        }
                    } else if (!isEditModeEnabled) {
                        for (j = 0; j < $scope.CustomerOrderModel.MerchandiseItems_editRow[i].lineItems.length; j++) {
                            if ($scope.CustomerOrderModel.MerchandiseItems_editRow[i].lineItems[j].isEdit == true) {
                                isEditModeEnabled = true;
                                if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                                    isKit = true;
                                    lineitem = $scope.CustomerOrderModel.MerchandiseItems[i];
                                    editedKitLineItem = $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j];
                                } else {
                                    lineitem.push($scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j]);
                                }
                            }
                        }
                    }
                }
                if (!$scope.CustomerOrderModel.specialCaseForCashSaleCOType(COKHIndex, COLIIndex, isEditModeEnabled)) {
                    return;
                }
                if (!isEditModeEnabled) {
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'coLineItem,user').then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.COKHList.length; i++) {
                            for (var item = 0; item < successfulSearchResult.COKHList[i].COLIList.length; item++) {
                                if ($scope.CustomerOrderModel.MerchandiseItems[i] != undefined && $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[item] != undefined) {
                                    $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[item].AvaliablePartsQty = successfulSearchResult.COKHList[i].COLIList[item].AvaliablePartsQty;
                                }
                            }
                        }
                        var focusElement = angular.element(event.target).closest('tr').next().find('input').not('.descEditInput').filter(':first');
                        var lineItem = $scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex];
                        if (COLIIndex != null) {
                            if (lineItem.Status == 'Ordered') {
                                $scope.CustomerOrderModel.openRemoveItemConfirmationPopup(lineItem, null, COKHIndex, COLIIndex, focusElement, 'Merchandise');
                                return;
                            }
                            if (!(lineItem.Status == 'Invoiced')) {
                                $scope.CustomerOrderModel.openEditModeMerchRow(lineItem, COKHIndex, COLIIndex, focusElement);
                            }
                        } else {
                            $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].isEdit = true;
                        }
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (isKit) {
                        $scope.CustomerOrderModel.SavekitInMerchandise(lineitem, editedKitLineItem, refreshGrid);
                    } else {
                        $scope.SaveMerchandiseToserver(lineitem, refreshGrid);
                    }
                }
            }
            $scope.CustomerOrderModel.openEditModeMerchRow = function(lineItem, COKHIndex, COLIIndex, element) {
                $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].isEdit = true;
                $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = lineItem.QtyCommitted;
                $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = lineItem.AvaliablePartsQty;
                $scope.CustomerOrderModel.MerchandiseEditOldQtyValue = lineItem.Qty;
                if ($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VendorId != null) {
                    SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VendorId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = successfulSearchResult;
                        for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                            if ($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                break;
                            }
                        }
                    })
                }
                setTimeout(function() {
                    if (element != undefined) {
                        element.focus();
                    }
                }, 10);
            }
            $scope.CustomerOrderModel.saveOnBlur = function(event, COKHIndex, COLIIndex, refreshGrid) {
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    return;
                }
                var isEditModeEnabled = false;
                var isKit = false;
                var lineitem = [];
                var editedKitLineItem = null;
                for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.MerchandiseItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        lineitem = $scope.CustomerOrderModel.MerchandiseItems[i];
                        if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                            isKit = true;
                        }
                    } else if (!isEditModeEnabled) {
                        for (j = 0; j < $scope.CustomerOrderModel.MerchandiseItems_editRow[i].lineItems.length; j++) {
                            if ($scope.CustomerOrderModel.MerchandiseItems_editRow[i].lineItems[j].isEdit == true) {
                                isEditModeEnabled = true;
                                if ($scope.CustomerOrderModel.MerchandiseItems[i].Id != null) {
                                    isKit = true;
                                    lineitem = $scope.CustomerOrderModel.MerchandiseItems[i];
                                    editedKitLineItem = $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j];
                                } else {
                                    lineitem.push($scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j]);
                                }
                            }
                        }
                    }
                }
                if (!$scope.CustomerOrderModel.specialCaseForCashSaleCOType(COKHIndex, COLIIndex, isEditModeEnabled)) {
                    return;
                }
                if (!isEditModeEnabled) {
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'coLineItem,user').then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.COKHList.length; i++) {
                            for (var item = 0; item < successfulSearchResult.COKHList[i].COLIList.length; item++) {
                                if ($scope.CustomerOrderModel.MerchandiseItems[i] != undefined && $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[item] != undefined) {
                                    $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[item].AvaliablePartsQty = successfulSearchResult.COKHList[i].COLIList[item].AvaliablePartsQty;
                                }
                            }
                        }
                        var lineItem = $scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex];
                        if (COLIIndex != null) {
                            if (!(lineItem.Status == 'Invoiced')) {
                                $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].isEdit = true;
                                $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = lineItem.QtyCommitted;
                                $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = lineItem.AvaliablePartsQty;
                                $scope.CustomerOrderModel.MerchandiseEditOldQtyValue = lineItem.Qty;
                                if ($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VendorId != null) {
                                    SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VendorId).then(function(successfulSearchResult) {
                                        $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise = successfulSearchResult;
                                        for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                                            if ($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                                $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                                break;
                                            }
                                        }
                                    })
                                }
                            }
                        } else {
                            $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].isEdit = true;
                        }
                        setTimeout(function() {
                            angular.element(event.target).closest('tr').next().find('input').not('.descEditInput').filter(':first').focus();
                        }, 10);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (isKit) {
                        $scope.CustomerOrderModel.SavekitInMerchandise(lineitem, editedKitLineItem, refreshGrid);
                    } else {
                        $scope.SaveMerchandiseToserver(lineitem, refreshGrid);
                    }
                }
            }
            $scope.CustomerOrderModel.specialCaseForCashSaleCOType = function(COKHIndex, COLIIndex, isEditModeEnabled) {
                if ($scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex] != undefined) {
                    var lineItem = $scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex];
                    if (isEditModeEnabled) {}
                    $scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].PreviousQtyNeed = $scope.CustomerOrderModel.MerchandiseItems[COKHIndex].COLIList[COLIIndex].Qty;
                }
                return true;
            }
            $scope.CustomerOrderModel.editRowTabOut = function(event, kitHeaderIndex, lineItemIndex, focusElementId, shiftTabEvent) {
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    if (shiftTabEvent != undefined && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].IsFee && !$scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].IsFixedPrice) {
                        setTimeout(function() {
                            angular.element('#' + focusElementId).focus();
                        }, 0);
                    } else {
                        angular.element('#CO_SearchToAdd_value').focus();
                        $scope.CustomerOrderModel.allowBlur = true;
                        $scope.CustomerOrderModel.editMerchItem(event, kitHeaderIndex, lineItemIndex, true);
                    }
                } else if ((event.shiftKey && event.keyCode == 9 && focusElementId != null)) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlur = false;
                    if (shiftTabEvent == undefined) {
                        setTimeout(function() {
                            angular.element('#' + focusElementId).focus();
                        }, 0);
                    }
                } else if (event.shiftKey && event.keyCode == 16) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlur = false;
                }
            }
            $scope.CustomerOrderModel.editRowOptionFeeTabOut = function(event, DealHeaderIndex, OptionFeeKitHeaderIndex, OptionFeesLineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    angular.element('#CO_SearchToAdd_value').focus();
                    $scope.CustomerOrderModel.editOptionFeesItem(event, DealHeaderIndex, OptionFeeKitHeaderIndex, OptionFeesLineItemIndex, focusElementId);
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                }
            }
            $scope.CustomerOrderModel.saveOptionFeesLineItem = function(dealId, optionFeeJSON) {
                if ($scope.CustomerOrderModel.DealHeaderIndex == undefined) {
                    $scope.CustomerOrderModel.DealItemListUpdated = [];
                    for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                        if ($scope.CustomerOrderModel.DealItemList[i].DealItemObj.Id != null || $scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitId != null) {
                            $scope.CustomerOrderModel.DealItemListUpdated.push($scope.CustomerOrderModel.DealItemList[i]);
                        }
                    }
                    if ($scope.CustomerOrderModel.DealItemListUpdated.length > 1) {
                        $scope.CustomerOrderModel.SelectUnitToAddOptionFee(dealId, optionFeeJSON);
                    } else if ($scope.CustomerOrderModel.DealItemListUpdated.length == 1) {
                        $scope.CustomerOrderModel.DealHeaderIndex = 0;
                        $scope.CustomerOrderModel.dealLineItemId = $scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex].DealItemObj.Id;
                        $scope.CustomerOrderModel.saveOptionFeesLineItemDetails(dealId, optionFeeJSON);
                    } else {
                        Notification.error($Label.CustomerOrder_Js_select_a_unit);
                        return;
                    }
                } else {
                    $scope.CustomerOrderModel.saveOptionFeesLineItemDetails(dealId, optionFeeJSON);
                }
            }
            $scope.CustomerOrderModel.saveOptionFeesLineItemDetails = function(dealId, optionFeeJSON) {
                var lineItemType = '';
                $scope.CustomerOrderModel.optionFeeJSONData = {
                    PartId: null,
                    FeeId: null,
                    LabourId: null,
                    IsInstall: false,
                    Qty: 1,
                    DealId: null,
                    DealItemId: null,
                    ProductId: null,
                    Price: null,
                    KitHeaderId: null
                };
                lineItemType = 'Deal';
                if (optionFeeJSON.originalObject.Info == 'Merchandise') {
                    $scope.CustomerOrderModel.optionFeeJSONData.PartId = optionFeeJSON.originalObject.Value;
                    $scope.CustomerOrderModel.optionFeeJSONData.Price = optionFeeJSON.originalObject.AdditionalDetailsForPart.Price;
                } else if (optionFeeJSON.originalObject.Info == 'Labor') {
                    $scope.CustomerOrderModel.optionFeeJSONData.LabourId = optionFeeJSON.originalObject.Value;
                    $scope.CustomerOrderModel.optionFeeJSONData.IsInstall = true;
                } else if (optionFeeJSON.originalObject.Info == 'Fee') {
                    $scope.CustomerOrderModel.optionFeeJSONData.FeeId = optionFeeJSON.originalObject.Value;
                } else if (optionFeeJSON.originalObject.Info == 'Product') {
                    $scope.CustomerOrderModel.optionFeeJSONData.ProductId = optionFeeJSON.originalObject.Value;
                    if (optionFeeJSON.originalObject.AdditionalInfo.ProductType == 'Sublet') {
                        $scope.CustomerOrderModel.optionFeeJSONData.IsInstall = true;
                    }
                } else if (optionFeeJSON.originalObject.Info == 'Kit') {
                    $scope.CustomerOrderModel.optionFeeJSONData.KitHeaderId = optionFeeJSON.originalObject.Value;
                }
                if ($scope.CustomerOrderModel.DealItemList[0].DealItemObj == undefined || ($scope.CustomerOrderModel.DealItemList[0].DealItemObj.OptionAndFeeStatus != null && $scope.CustomerOrderModel.DealItemList[0].DealItemObj.OptionAndFeeStatus != 'Uncommitted') && (optionFeeJSON.originalObject.Info == 'Merchandise' || optionFeeJSON.originalObject.Info == 'Labor' || optionFeeJSON.originalObject.Info == 'Kit' || (optionFeeJSON.originalObject.Info == 'Product' && optionFeeJSON.originalObject.AdditionalInfo.ProductType == 'Sublet'))) {
                    if (optionFeeJSON.originalObject.Info == 'Product' && optionFeeJSON.originalObject.AdditionalInfo.ProductType == 'Sublet') {
                        Notification.error('After Commit and install can not add ' + optionFeeJSON.originalObject.AdditionalInfo.ProductType);
                        return;
                    }
                    Notification.error('After Commit and install can not add ' + optionFeeJSON.originalObject.Info);
                    return;
                }
                $scope.CustomerOrderModel.optionFeeJSONData.DealItemId = $scope.CustomerOrderModel.dealLineItemId;
                $scope.CustomerOrderModel.optionFeeJSONData.DealId = dealId;
                DealService.insertOptionAndFeeLineItems($scope.CustomerOrderModel.optionFeeJSONData.PartId, $scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.optionFeeJSONData.DealId, $scope.CustomerOrderModel.optionFeeJSONData.DealItemId, angular.toJson($scope.CustomerOrderModel.optionFeeJSONData), $scope.CustomerOrderModel.isSupressTrue, true).then(function(successfulSearchResult) {
                    if (angular.isDefined(successfulSearchResult.DuplicatePart)) {
                        $scope.CustomerOrderModel.openDuplicatePartModal($scope.CustomerOrderModel.coHeaderId, lineItemType, optionFeeJSON.originalObject.AdditionalDetailsForPart, null, null)
                    } else {
                        $scope.CustomerOrderModel.insertOptionFeesLineItemDetails(dealId, successfulSearchResult)
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.insertOptionFeesLineItemDetails = function(dealId, successfulSearchResult) {
                var optionFeesListSize;
                if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'In Progress' && $scope.CustomerOrderModel.DealItemList[0].DealItemObj.OptionAndFeeStatus == 'Committed') {
                    $scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex] = successfulSearchResult;
                    $scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex].DealKitHeaderList = successfulSearchResult.UnitList[$scope.CustomerOrderModel.DealHeaderIndex].DealKitHeaderList;
                    optionFeesListSize = successfulSearchResult.UnitList[$scope.CustomerOrderModel.DealHeaderIndex].DealKitHeaderList.length;
                } else {
                    $scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex] = successfulSearchResult;
                    $scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex].DealKitHeaderList = successfulSearchResult.DealKitHeaderList;
                    optionFeesListSize = successfulSearchResult.DealKitHeaderList.length;
                }
                $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                $scope.CustomerOrderModel.editLineItemsForOptionFees();
                $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                if ($scope.CustomerOrderModel.DealItemList[$scope.CustomerOrderModel.DealHeaderIndex].DealKitHeaderList[optionFeesListSize - 1].Id != null) {
                    $scope.CustomerOrderModel.OptionFeesItems_editRow[$scope.CustomerOrderModel.DealHeaderIndex].KitHeaderItems[optionFeesListSize - 1].isEdit = true;
                } else {
                    if ($scope.CustomerOrderModel.OptionFeesItems_editRow[$scope.CustomerOrderModel.DealHeaderIndex].KitHeaderItems[optionFeesListSize - 1].OptionFees[0].IsEnvFee) {
                        optionFeesListSize = ((optionFeesListSize > 0) ? optionFeesListSize - 1 : optionFeesListSize);
                    }
                    $scope.CustomerOrderModel.OptionFeesItems_editRow[$scope.CustomerOrderModel.DealHeaderIndex].KitHeaderItems[optionFeesListSize - 1].OptionFees[0].isEdit = true;
                }
                setTimeout(function() {
                    elementId = '#DealOptionAndFeesUnitSection' + $scope.CustomerOrderModel.DealHeaderIndex;
                    angular.element(elementId).find('input[type=text]').filter(':visible:first').focus();
                    $scope.CustomerOrderModel.dealLineItemId = null;
                    $scope.CustomerOrderModel.DealHeaderIndex = undefined;
                }, 10);
            }
            $scope.CustomerOrderModel.getCheckoutTax = function() {
                CustomerInfoService.getCheckoutSalesTax($scope.CustomerOrderModel.COInvoiceHeaderId).then(function(result) {
                    $scope.CustomerOrderModel.checkoutSalesTaxList = result;
                }, function(errorSearchResult) {
                    console.log(errorSearchResult); //TODO
                });
            }
            $scope.CustomerOrderModel.updateDealSummaryTotals = function() {
                DealService.getDealData($scope.CustomerOrderModel.DealInfo.Id, 'dealInfo').then(function(result) {
                    if (result != undefined) {
                        $scope.CustomerOrderModel.DealSummaryObj.UnitsTotal = result.UnitsTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.PartsAndLabourTotals = result.PartsAndLabourTotals;
                        $scope.CustomerOrderModel.DealSummaryObj.FeesTotal = result.FeesTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.OtherProductsTotal = result.OtherProductsTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.StampDutyTotal = result.StampDutyTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.SubTotal = result.SubTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.Total = result.Total;
                        $scope.CustomerOrderModel.DealSummaryObj.SalesTaxesTotal = result.SalesTaxesTotal;
                        $scope.CustomerOrderModel.DealSummaryObj.TradeInsTotal = result.TradeInsTotal;
                        $scope.CustomerOrderModel.coHeaderDetails.OrderTotal = result.OrderTotal;
                        $scope.CustomerOrderModel.coHeaderDetails.InvoicedAmount = result.InvoicedAmount;
                        $scope.CustomerOrderModel.coHeaderDetails.UninvoicedAmount = result.UninvoicedAmount;
                    }
                }, function(errorSearchResult) {
                    console.log(errorSearchResult); //TODO
                });
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    var dealItem = $scope.CustomerOrderModel.DealItemList[i];
                    if (dealItem != undefined && dealItem.DealKitHeaderList != undefined) {
                        dealItem.TotalOptionAndFee = 0;
                        for (j = 0; j < dealItem.DealKitHeaderList.length; j++) {
                            for (k = 0; k < dealItem.DealKitHeaderList[j].OptionAndFeeList.length; k++) {
                                dealItem.TotalOptionAndFee += dealItem.DealKitHeaderList[j].OptionAndFeeList[k].Total;
                            }
                        }
                    }
                }
                $scope.CustomerOrderModel.calculateEstimatedPayment();
                $scope.CustomerOrderModel.allowCheckoutSort = true;
                $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
            }
            $scope.CustomerOrderModel.editDeductible = function(event, DeductibleJson, index) {
                if (!event.shiftKey && event.keyCode == 9) {
                    DeductibleJson.SoHeaderId = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Id;
                    DeductibleJson.CoHeaderId = $scope.CustomerOrderModel.coHeaderId;
                    SOHeaderService.editDeductibleAmount(JSON.stringify(DeductibleJson)).then(function(successfulSearchResult) {
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            $scope.CustomerOrderModel.getOutstandingItems = function(soHeaderIndex) {
                var itmesCount = 0;
                var lineItemsList = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOGridItems;
                for (var i = 0; i < lineItemsList.length; i++) {
                    for (var j = 0; j < lineItemsList[i].SOKH.SOLIList.length; j++) {
                        if (lineItemsList[i].SOKH.SOLIList[j].IsPart && (lineItemsList[i].SOKH.SOLIList[j].Status == 'Required' || lineItemsList[i].SOKH.SOLIList[j].Status == 'Ordered')) {
                            itmesCount++;
                        }
                    }
                }
                return itmesCount;
            }
            $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = 0;
            $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = 0;
            $scope.CustomerOrderModel.MerchandiseEditOldQtyValue = 0;
            $scope.CustomerOrderModel.editRowBlur = function(event, kitHeaderIndex, lineItemIndex, focusElementId) {
                var oldCommitQty = 0;
                var OldAvailableQty = 0;
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.Blurcalled = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlur == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.saveOnBlur(event, kitHeaderIndex, lineItemIndex, true);
                        }
                        $scope.CustomerOrderModel.allowBlur = true;
                        $scope.CustomerOrderModel.Blurcalled = false;
                        return;
                    }, 300);
                };
                if (event.type == 'blur' || (event.type == 'keydown' && (!event.shiftKey && event.keyCode == 9))) {
                    if (event.type == 'keydown') {
                        $scope.CustomerOrderModel.allowBlur = false;
                        event.preventDefault();
                    }
                    if (event.type == 'blur') {
                        if ($scope.CustomerOrderModel.allowBlur == false) {
                            return;
                        }
                    }
                    $scope.CustomerOrderModel.calculateLineItem(kitHeaderIndex, lineItemIndex);
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlur = false;
                    if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].IsPart) {
                        event.preventDefault();
                    }
                }
            }
            $scope.CustomerOrderModel.calculateLineItem = function(kitHeaderIndex, lineItemIndex) {
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty = ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty == '') ? 1 : $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty;
                if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == null) {
                    $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = 0;
                }
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted);
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty = parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty);
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty = parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty);
                var MaxCommit = parseFloat($scope.CustomerOrderModel.MerchandiseEditOldAvailableValue) + parseFloat($scope.CustomerOrderModel.MerchandiseEditOldCommitedValue);
                if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty != $scope.CustomerOrderModel.MerchandiseEditOldQtyValue) {
                    if (!$rootScope.GroupOnlyPermissions['Returns'].enabled && $scope.CustomerOrderModel.MerchandiseEditOldQtyValue < 0) {
                        $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty = $scope.CustomerOrderModel.MerchandiseEditOldQtyValue;
                    }
                    $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty * $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Price;
                    if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty > MaxCommit) {
                        $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = (MaxCommit > 0 ? MaxCommit : 0);
                        if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status = 'Required';
                        }
                    } else {
                        $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty;
                        if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status = 'In Stock';
                        }
                    }
                    $scope.CustomerOrderModel.MerchandiseEditOldQtyValue = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty;
                } else if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted != $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue) {
                    if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted >= $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty) {
                        $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty;
                    }
                    var COLI_QtyCommitted = parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted);
                    var COLI_OldQtyCommitted = parseFloat($scope.CustomerOrderModel.MerchandiseEditOldCommitedValue);
                    if (parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted) > parseFloat(MaxCommit) && parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty) == parseFloat($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted)) {
                        if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            if (!$rootScope.GroupOnlyPermissions['Oversell inventory']['enabled'] && (COLI_QtyCommitted > COLI_OldQtyCommitted)) {
                                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = COLI_OldQtyCommitted;
                            } else {
                                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status = 'Oversold';
                            }
                        }
                    } else if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted <= MaxCommit && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty == $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted) {
                        $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status = 'In Stock';
                    } else {
                        if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Ordered' && $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Status = 'Required';
                        }
                    }
                }
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty = ($scope.CustomerOrderModel.MerchandiseEditOldAvailableValue - ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted - $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue));
                $scope.CustomerOrderModel.MerchandiseEditOldCommitedValue = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted
                $scope.CustomerOrderModel.MerchandiseEditOldAvailableValue = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].AvaliablePartsQty
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].SubTotal = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty * $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Price;
                $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyOrder = $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].Qty - $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted;
            }
            $scope.CustomerOrderModel.editRowBlurCommited = function(event, kitHeaderIndex, lineItemIndex, focusElementId) {
                if (!event.shiftKey && event.keyCode == 9) {
                    if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].IsPart) {
                        if ($scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == '' || $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted == 'undefined') {
                            $scope.CustomerOrderModel.MerchandiseItems[kitHeaderIndex].COLIList[lineItemIndex].QtyCommitted = 0;
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.closeEditSpecialOrderRow = function() {
                for (i = 0; i < $scope.CustomerOrderModel.SpecialOrder_editRow.length; i++) {
                    $scope.CustomerOrderModel.SpecialOrder_editRow[i].isEdit = false;
                }
            }
            $scope.CustomerOrderModel.editSpecialOrderItem = function(index) {
                if (!$rootScope.GroupOnlyPermissions['Special order'].enabled) {
                    return;
                }
                if (angular.isDefined(event.parentElement)) {
                    if (event.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 && event.type != 'keydown') {
                        return;
                    }
                }
                if ((event.target.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.target.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                    return;
                }
                if (angular.isDefined(event.toElement)) {
                    if ((event.toElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.toElement.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                        return;
                    }
                }
                if (event.target.parentElement.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1) {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.SpecialOrder_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.SpecialOrder_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.CustomerOrderModel.SpecialOrder_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    if ($scope.CustomerOrderModel.SpecialOrder[index].Status == 'Required') {
                        $scope.CustomerOrderModel.SpecialOrder_editRow[index].isEdit = true;
                        SOHeaderService.getVendorOrderByVendorId($scope.CustomerOrderModel.SpecialOrder[index].VendorId).then(function(successfulSearchResult) {
                            $scope.CustomerOrderModel.VendorOrderListByVendorIdForSpecialOrder = successfulSearchResult;
                            for (i = 0; i < $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length; i++) {
                                if ($scope.CustomerOrderModel.MerchandiseItems[index].COLIList[index].VONumber == $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOName) {
                                    $scope.CustomerOrderModel.SpecialOrder_editRow[index].lineItems[index].optionSelected = $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise[i].VOId;
                                    break;
                                }
                            }
                        })
                    }
                }
            }
            $scope.CustomerOrderModel.closeEditDepositRow = function() {
                if (!$scope.CustomerOrderModel.isReverseDeposit) {
                    for (i = 0; i < $scope.CustomerOrderModel.Deposits_editRow.length; i++) {
                        $scope.CustomerOrderModel.Deposits_editRow[i].isEdit = false;
                    }
                }
            }
            $scope.CustomerOrderModel.editDepositItem = function(index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify']) {
                    return;
                }
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.Deposits_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.CustomerOrderModel.Deposits_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.Deposits_editRow[index].isEdit = true;
                }
            }
            $scope.CustomerOrderModel.ReverseDeposit = function(deposit) {
                $scope.CustomerOrderModel.isReverseDeposit = true;
                $scope.CustomerOrderModel.deposit_method = deposit.PaymentMethod;
                $scope.CustomerOrderModel.deposit_Amount = -(deposit.Amount);
                $scope.CustomerOrderModel.deposit_Link = deposit.CODepositId;
                $scope.CustomerOrderModel.deposit_DealId = deposit.Deal;
            }
            $scope.CustomerOrderModel.calculateDepositTotal = function() {
                var depositTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                    if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                        depositTotal += $scope.CustomerOrderModel.Deposits[i].Amount;
                    }
                }
                depositTotal = depositTotal.toFixed(2);
                return parseFloat(depositTotal);
            }
            $scope.CustomerOrderModel.calculateDepositTotalWithoutDeal = function() {
                var depositTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                    if ($scope.CustomerOrderModel.Deposits[i].Deal == null) {
                        if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                            depositTotal += $scope.CustomerOrderModel.Deposits[i].Amount;
                        }
                    }
                }
                depositTotal = depositTotal.toFixed(2);
                return parseFloat(depositTotal);
            }
            $scope.CustomerOrderModel.calculateDepositTotalIncludeDeal = function() {
                var depositTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                    if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                        depositTotal += $scope.CustomerOrderModel.Deposits[i].Amount;
                    }
                }
                depositTotal = depositTotal.toFixed(2);
                return depositTotal;
            }
            $scope.CustomerOrderModel.isDeleteServiceOrder = function(soIndex) {
                if (($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems.length > 0) || ($scope.CustomerOrderModel.SOHeaderList[soIndex].HoursLoggedList.length > 0) || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out' || $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == "Closed") {
                    return false;
                } else {
                    return true;
                }
            }
            $scope.CustomerOrderModel.closeEditPaymentRow = function() {
                if (!$scope.CustomerOrderModel.isReversePayment) {
                    for (i = 0; i < $scope.CustomerOrderModel.Payments_editRow.length; i++) {
                        $scope.CustomerOrderModel.Payments_editRow[i].isEdit = false;
                    }
                }
            }
            $scope.CustomerOrderModel.editPaymentItem = function(index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.Payments_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.Payments_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                    }
                    $scope.CustomerOrderModel.Payments_editRow[i].isEdit = false;
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.Payments_editRow[index].isEdit = true;
                }
            }
            $scope.CustomerOrderModel.paymentGoAction = function(index, paymentObj) {
                var selectedOption = $scope.CustomerOrderModel.Payments_editRow[index].radioValue;
                if (selectedOption == 0) {
                    $scope.CustomerOrderModel.ReversePayment(paymentObj);
                }
            }
            $scope.CustomerOrderModel.ReversePayment = function(Payment) {
                $scope.CustomerOrderModel.isReversePayment = true;
                $scope.CustomerOrderModel.PaymentReverseLink = Payment.COInvoicePaymentId;
                $scope.CustomerOrderModel.Payment_method = Payment.PaymentMethod;
                $scope.CustomerOrderModel.Payment_Amount = -(Payment.Amount).toFixed(2);
            }
            $scope.CustomerOrderModel.calculatePaymentTotal = function() {
                var PaymentTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                    if (!($scope.CustomerOrderModel.isReversePayment && $scope.CustomerOrderModel.Payment[i].PaymentMethod == 'Cash Rounding')) {
                        PaymentTotal += $scope.CustomerOrderModel.Payment[i].Amount;
                    }
                }
                if ($scope.CustomerOrderModel.Payment.length > 0) {
                    if ($scope.CustomerOrderModel.Payment_method == 'Please Select') {
                        $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                        $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                    }
                }
                PaymentTotal = PaymentTotal.toFixed(2);
                dealDepositTotal = 0;
                return parseFloat(PaymentTotal) + parseFloat(dealDepositTotal);
            }
            $scope.CustomerOrderModel.calculateDepositTotalOverlay = function(event) {
                var depositsMade = 0;
                var depositsUsed = 0;
                var depositsBalance = 0;
                for (i = 0; i < $scope.CustomerOrderModel.Deposits.length; i++) {
                    if (!($scope.CustomerOrderModel.Deposits[i].PaymentMethod == 'Invoice' && ($scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == '' || $scope.CustomerOrderModel.Deposits[i].COInvoiceNumber == null))) {
                        depositsMade += $scope.CustomerOrderModel.Deposits[i].Amount;
                    }
                }
                depositsUsed = $scope.CustomerOrderModel.calculateDepositUsed();
                depositsBalance = depositsMade - depositsUsed;
                depositsMade = depositsMade.toFixed(2);
                depositsUsed = depositsUsed.toFixed(2);
                depositsBalance = depositsBalance.toFixed(2);
                var fieldsJSON = [{
                    label: 'Deposits Made',
                    value: depositsMade
                }, {
                    label: 'Deposits Used',
                    value: depositsUsed
                }, {
                    label: 'DEPOSIT BALANCE',
                    value: depositsBalance
                }];
                $scope.CustomerOrderModel.showPriceInfoOverlay(event, fieldsJSON);
            }
            $scope.CustomerOrderModel.calculateMerchandiseTotal = function() {
                var subTotal = 0;
                for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems.length; i++) {
                    if ($scope.CustomerOrderModel.CurrentUserLocale == 'en_AU') {
                        subTotal += $scope.CustomerOrderModel.MerchandiseItems[i].SubTotal;
                    } else {
                        subTotal += $scope.CustomerOrderModel.MerchandiseItems[i].SubTotal + ($scope.CustomerOrderModel.MerchandiseItems[i].Qty * $scope.CustomerOrderModel.MerchandiseItems[i].Price * $scope.CustomerOrderModel.MerchandiseItems[i].Tax) / 100;
                    }
                }
                subTotal = subTotal.toFixed(2);
                return '$' + subTotal;
            }
            $scope.CustomerOrderModel.calculateOrderTotal = function() {
                var Total = 0;
                if (!isNaN($scope.CustomerOrderModel.MerchandiseTotal)) {
                    Total = Total + parseFloat($scope.CustomerOrderModel.MerchandiseTotal);
                }
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId == null || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId == '') {
                        Total = Total + parseFloat($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Total);
                    }
                }
                if ($scope.CustomerOrderModel.DealSummaryObj != undefined && !isNaN($scope.CustomerOrderModel.DealSummaryObj.Total) && $scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.DealType == 'Cash Deal') {
                    Total = Total + parseFloat($scope.CustomerOrderModel.DealSummaryObj.Total);
                }
                return parseFloat(Total).toFixed(2);
            }
            $scope.CustomerOrderModel.resetCauseConcernCorrection = function() {
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.ManualCause.length > 0 || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.ManualCorrection.length > 0) {
                        $scope.CustomerOrderModel.SOHeaderList[i].ShowCauseConcernCorrection = true;
                    }
                }
            }
            $scope.CustomerOrderModel.removeMerchandiseSection = function(coHeaderID) {
                if ($scope.CustomerOrderModel.MerchandiseItems != undefined && $scope.CustomerOrderModel.MerchandiseItems.length > 0) {
                    return;
                }
                CustomerInfoService.removeMerchandiseSection(coHeaderID, true).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.hideMerchandiseSection = true;
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    angular.element('html, body').stop().animate({
                        scrollTop: 0
                    }, 500, function() {
                        angular.element(document).on("scroll", function() {
                            $scope.CustomerOrderModel.onScroll();
                        });
                    });
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error(errorSearchResult);
                });
            }
            $scope.CustomerOrderModel.deleteSoHeaderInfo = function(soHeaderID) {
                $scope.CustomerOrderModel.closeCreateDropDown();
                SOHeaderService.deleteServiceOrder($scope.CustomerOrderModel.coHeaderId, soHeaderID).then(function(successfulSearchResult) {
                    if (successfulSearchResult.responseStatus == 'error') {
                        Notification.error(successfulSearchResult.response);
                    } else {
                        $scope.CustomerOrderModel.updatedResult = successfulSearchResult;
                        $scope.CustomerOrderModel.SOHeaderList = successfulSearchResult.SOList;
                        $scope.CustomerOrderModel.pinnedItems = successfulSearchResult.PinnedItemList;
                        $scope.CustomerOrderModel.getServiceOrderList();
                        $scope.CustomerOrderModel.setServiceOrderData();
                        $scope.CustomerOrderModel.resetServiceOrderData();
                        $scope.CustomerOrderModel.resetCauseConcernCorrection();
                        $scope.CustomerOrderModel.createGridEditItem(null);
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                        $scope.CustomerOrderModel.createHoursLoggedGridEditItem(null);
                        setTimeout(function() {
                            angular.element('[data-toggle="tooltip"]').tooltip();
                        }, 1000);
                        var navBarHeightDiffrenceFixedHeaderOpen = 0;
                        if ($rootScope.wrapperHeight == 95) {
                            navBarHeightDiffrenceFixedHeaderOpen = 15;
                        } else {
                            navBarHeightDiffrenceFixedHeaderOpen = 15;
                        }
                        var leftPanelLinks = angular.element(window).height() - ($rootScope.wrapperHeight + angular.element(".orderNumber").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + angular.element(".ownerInfo").height() + angular.element(".sideBarTotals").height() + 85 - navBarHeightDiffrenceFixedHeaderOpen);
                        angular.element(".leftPanelLinks").css("height", leftPanelLinks);
                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                        angular.element('html, body').stop().animate({
                            scrollTop: 0
                        }, 500, function() {
                            angular.element(document).on("scroll", function() {
                                $scope.CustomerOrderModel.onScroll();
                            });
                        });
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error(errorSearchResult);
                });
            }
            var toaloverlaytimer;
            $scope.CustomerOrderModel.calculateTotalOverlay = function(event, SOHeaderId, gridName) {
                toaloverlaytimer = $timeout(function() {
                    var isAustralianMarket = false;
                    var totalsJson;
                    CustomerInfoService.getGridTotal($scope.CustomerOrderModel.coHeaderId, SOHeaderId, gridName, isAustralianMarket).then(function(successfulSearchResult) {
                        totalsJson = successfulSearchResult;
                        var fieldsJSON = [];
                        if (totalsJson.Total_Part != 0) {
                            fieldsJSON.push({
                                label: 'Parts Total',
                                value: totalsJson.Total_Part
                            });
                        }
                        if (totalsJson.Total_Fee != 0) {
                            fieldsJSON.push({
                                label: 'Fees Total',
                                value: totalsJson.Total_Fee
                            });
                        }
                        if (SOHeaderId != null && totalsJson.Total_ShopSupplies != 0) {
                            fieldsJSON.push({
                                label: 'Shop Supplies Total',
                                value: totalsJson.Total_ShopSupplies
                            });
                        }
                        if (SOHeaderId != null && totalsJson.Total_Laobur != 0) {
                            fieldsJSON.push({
                                label: 'Labors Total',
                                value: totalsJson.Total_Laobur
                            });
                        }
                        if (SOHeaderId != null && totalsJson.Total_Sublet != 0) {
                            fieldsJSON.push({
                                label: 'Sublets Total',
                                value: totalsJson.Total_Sublet
                            });
                        }
                        if (totalsJson.Total != 0) {
                            fieldsJSON.push({
                                label: 'TOTAL',
                                value: totalsJson.Total
                            });
                        }
                        $scope.CustomerOrderModel.showPriceInfoOverlay(event, fieldsJSON);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }, 1000);
            }
            $scope.CustomerOrderModel.calculateBalanceDueTotalOverlay = function(event) {
                var ausTaxRate = $Global.Sales_Tax_Rate;
                var CheckoutItemList = $scope.CustomerOrderModel.CheckOutItems;
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var merchandise = 0;
                var salesTax = 0;
                var totalInvoice = 0;
                var payments = 0;
                for (i = 0; i < CheckoutItemList.length; i++) {
                    if (CheckoutItemList[i].IsActive) {
                        merchandise += (CheckoutItemList[i].Total);
                        salesTax += (CheckoutItemList[i].TaxAmount)
                        if ($scope.CustomerOrderModel.IsTaxIncludingPricing) {
                            totalInvoice += CheckoutItemList[i].Total;
                        } else {
                            totalInvoice += (CheckoutItemList[i].Total + CheckoutItemList[i].TaxAmount);
                        }
                    }
                }
                for (i = 0; i < PaymentList.length; i++) {
                    payments += PaymentList[i].Amount;
                }
                var fieldsJSON = [];
                fieldsJSON.push({
                    label: 'Merchandise',
                    value: (merchandise).toFixed(2)
                });
                if (!$scope.CustomerOrderModel.IsTaxIncludingPricing) {
                    fieldsJSON.push({
                        label: 'Sales Tax',
                        value: (salesTax).toFixed(2)
                    });
                }
                fieldsJSON.push({
                    label: 'Total Invoice ',
                    value: (totalInvoice).toFixed(2)
                });
                fieldsJSON.push({
                    label: 'Less: Payments',
                    value: (payments).toFixed(2)
                });
                if ($scope.CustomerOrderModel.IsTaxIncludingPricing) {
                    fieldsJSON.push({
                        label: 'Sales Tax',
                        value: (salesTax).toFixed(2)
                    });
                }
                $scope.CustomerOrderModel.showPriceInfoOverlay(event, fieldsJSON);
            }
            $scope.CustomerOrderModel.showPriceInfoOverlay = function(event, fieldsJSON) {
                $scope.CustomerOrderModel.priceOverlay = fieldsJSON;
                setTimeout(function() {
                    var targetEle = angular.element(event.target);
                    var overlayTop = angular.element('.Price-info-overlay').height() + 50;
                    angular.element('.Price-info-overlay').addClass('afterarrow');
                    if (angular.element('.Price-info-overlay').hasClass('beforearrow')) {
                        angular.element('.Price-info-overlay').removeClass('beforearrow');
                    }
                    if (targetEle.offset().top - $(document).scrollTop() < 300) {
                        angular.element('.Price-info-overlay').removeClass('afterarrow');
                        angular.element('.Price-info-overlay').addClass('beforearrow');
                        overlayTop = overlayTop - angular.element('.Price-info-overlay').height() - 115;
                    }
                    angular.element('.Price-info-overlay').css('top', targetEle.offset().top - overlayTop);
                    angular.element('.Price-info-overlay').css('left', targetEle.offset().left - 270);
                }, 10);
                angular.element('.Price-info-overlay').show();
            }
            $scope.CustomerOrderModel.hidePriceInfoOverlay = function() {
                $timeout.cancel(toaloverlaytimer);
                angular.element('.Price-info-overlay').hide();
            }
            $scope.isEmpty = function(obj) {
                return angular.equals({}, obj);
            };
            var timer;
            $scope.CustomerOrderModel.openpartpopup = function(event, partId) {
                timer = $timeout(function() {
                    $scope.$broadcast('PartPopUpEvent', partId);
                    $scope.applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
                }, 1000);
            }
            $scope.CustomerOrderModel.hidePartPopUp = function() {
                $timeout.cancel(timer);
                angular.element('.Vendor-Order-Part-Popup').hide();
            }
            var timer2;
            $scope.CustomerOrderModel.openCOUpopup = function(event, COUId) {
                timer2 = $timeout(function() {
                	var unitRelated_Json = {
                            couId: COUId
                    };
                    $scope.$broadcast('COUPopUpEvent', unitRelated_Json);
                    $scope.applyCssOnPartPopUp(event, '.COUInfoPopup');
                }, 1000);
            }
            $scope.CustomerOrderModel.hideCOUPopUp = function() {
                $timeout.cancel(timer2);
                angular.element('#COUInfoPopup').hide();
            }
            $scope.CustomerOrderModel.openHourpopup = function(IdVal) {
                angular.element("#" + IdVal).show();
            }
            $scope.CustomerOrderModel.hideHourPopUp = function(IdVal) {
                angular.element("#" + IdVal).hide();
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
            $scope.CustomerOrderModel.showCustomerInfoOverlay = function(event, custId) {
                $scope.CustomerOrderModel.OverlayInfo = {};
                $scope.CustomerOrderModel.CustomerOverlay = [];
                if (custId == null) {
                    return;
                }
                $scope.CustomerOrderModel.showInfoOverlay(event, custId);
                CustomerInfoService.customerInfo(custId).then(function(customerRecord) {
                    if (customerRecord.length > 0) {
                        $scope.CustomerOrderModel.OverlayInfo = customerRecord[0];
                        if ($scope.CustomerOrderModel.OverlayInfo.Cust_PreferredPhone == "") {
                            if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeNumber != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedHomeNumber;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkNumber != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedWorkNumber;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_Mobile != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone = $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedOtherPhone;
                            }
                        }
                        if ($scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail == "") {
                            if ($scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_HomeEmail;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_WorkEmail;
                            } else if ($scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail != "") {
                                $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail = $scope.CustomerOrderModel.OverlayInfo.Cust_OtherEmail;
                            }
                        }
                        $scope.CustomerOrderModel.CustomerOverlay = [{
                            label: 'Name',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_Name
                        }, {
                            label: 'Nick Name',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_NickName
                        }, {
                            label: 'PHONE PRIMARY',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedPreferredPhone
                        }, {
                            label: 'PHONE ALT',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_FormattedOtherPhone
                        }, {
                            label: 'EMAIL',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_PreferredEmail
                        }, {
                            label: 'ADDRESS',
                            value: $scope.CustomerOrderModel.OverlayInfo.Cust_BillingStreet + ' ' + $scope.CustomerOrderModel.OverlayInfo.Cust_BillingCity
                        }];
                    }
                }, function(errorSearchResult) {
                    $scope.CustomerOrderModel.OverlayInfo = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.showUserInfoOverlay = function(event, custId) {
                $scope.CustomerOrderModel.OverlayInfo = {};
                $scope.CustomerOrderModel.CustomerOverlay = [];
                $scope.CustomerOrderModel.showInfoOverlay(event, custId);
                CustomerInfoService.customerInfo(custId).then(function(customerRecord) {
                    if (customerRecord.length > 0) {
                        $scope.CustomerOrderModel.OverlayInfo = customerRecord[0];
                        $scope.CustomerOrderModel.CustomerOverlay = [{
                            label: 'Name',
                            value: $scope.CustomerOrderModel.OverlayInfo.User_Name
                        }, {
                            label: 'PHONE PRIMARY',
                            value: $scope.CustomerOrderModel.OverlayInfo.User_Phone
                        }, {
                            label: 'EMAIL',
                            value: $scope.CustomerOrderModel.OverlayInfo.User_Email
                        }];
                    }
                }, function(errorSearchResult) {
                    $scope.CustomerOrderModel.OverlayInfo = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.hideCustomerInfoOverlay = function() {
                angular.element('.Customer-info-overlay').hide();
            }
            $scope.CustomerOrderModel.showInvoiceDetail = function(invoiceHeaderId, event) {
                $scope.CustomerOrderModel.InvoiceDetailInfo = {};
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element('.Invoice-info-overlay').css('top', targetEle.offset().top - 275);
                angular.element('.Invoice-info-overlay').css('left', event.clientX);
                angular.element('.Invoice-info-overlay').show();
                CustomerInfoService.InvoiceDetails(invoiceHeaderId).then(function(invoicedetail) {
                    $scope.CustomerOrderModel.InvoiceDetailInfo = invoicedetail[0];
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                }, function(errorSearchResult) {
                    $scope.CustomerOrderModel.OverlayInfo = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.hideInvoiceDetail = function() {
                angular.element('.Invoice-info-overlay').hide();
            }
            $scope.CustomerOrderModel.hidePanel = function(event, id) {
                var targetelement = angular.element(event.target.closest('.heading_icon'));
                if (targetelement.hasClass('rotation90')) {
                    targetelement.removeClass('rotation90');
                } else {
                    targetelement.addClass('rotation90');
                }
                $('#' + id).toggle();
            }
            $scope.AddRemoveItems = function(index) {
                var disableCheckOutItemAddAction = $scope.CustomerOrderModel.disableCheckOutItemAddAction($scope.CustomerOrderModel.CheckOutItems[index]);
                if (disableCheckOutItemAddAction) {
                    return;
                }
                for (var i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                    if ($scope.CustomerOrderModel.Payment[i].PaymentMethod == 'Use Deal Deposit' || $scope.CustomerOrderModel.Payment[i].PaymentMethod == 'Use Deposit') {
                        if ($scope.CustomerOrderModel.isDealCheckoutActive) {
                            for (var i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                                if (!$scope.CustomerOrderModel.CheckOutItems[i].DealId || $scope.CustomerOrderModel.CheckOutItems[i].DealFinanceId) {
                                    $scope.CustomerOrderModel.CheckOutItems[i].IsActive = false;
                                }
                            }
                        } else if ($scope.CustomerOrderModel.CheckOutItems[index].DealId) {
                            $scope.CustomerOrderModel.CheckOutItems[i].IsActive = false;
                        }
                        CustomerInfoService.UpdateChekoutItems(JSON.stringify($scope.CustomerOrderModel.CheckOutItems), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                            $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                        return;
                    }
                }
                var PaymentList = $scope.CustomerOrderModel.Payment;
                var totalFinancingPayment = 0;
                for (i = 0; i < PaymentList.length; i++) {
                    if (PaymentList[i].PaymentMethod == 'Financing') {
                        totalFinancingPayment += PaymentList[i].Amount;
                    }
                }
                if (totalFinancingPayment > 0) {
                    Notification.error('You must reverse or finalize your current deal invoice before invoicing other items');
                    return;
                }
                if ($scope.CustomerOrderModel.CheckOutItems[index].IsInvoiceable && ($scope.CustomerOrderModel.CheckOutItems[index].SOStatus == null || $scope.CustomerOrderModel.CheckOutItems[index].SOStatus == "Complete" || $scope.CustomerOrderModel.CheckOutItems[index].SOStatus == "Reviewed") && $scope.CustomerOrderModel.CheckOutItems[index].CheckoutType == $scope.CustomerOrderModel.checkOutMode) {
                    $scope.CustomerOrderModel.CheckOutItems[index].IsActive = !$scope.CustomerOrderModel.CheckOutItems[index].IsActive;
                    if (($scope.CustomerOrderModel.calculateBalanceDue() == 0) && !(!$scope.CustomerOrderModel.EnableFinaliseInvoice() || $scope.CustomerOrderModel.EnableFinaliseInvoice1())) {
                        $scope.CustomerOrderModel.enablePrintInvoiceCheckBox = true;
                    }
                    $scope.UpdateCheckout(index);
                }
            }
            $scope.UpdateCheckout = function(index) {
                var checkoutList = [];
                if (index != undefined) {
                    checkoutList.push($scope.CustomerOrderModel.CheckOutItems[index]);
                } else {
                    checkoutList = $scope.CustomerOrderModel.CheckOutItems;
                }
                CustomerInfoService.UpdateChekoutItems(JSON.stringify(checkoutList), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.FinaliseInvoice = function() {
                if ($scope.isInvoiceFinalizePressed == false) {
                    $scope.isInvoiceFinalizePressed = true;
                } else {
                    return;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.COType == 'Customer') {
                    if ($scope.CustomerOrderModel.Customer.Value == undefined || $scope.CustomerOrderModel.Customer.Value == null || $scope.CustomerOrderModel.Customer.Value == '') {
                        Notification.error($Label.First_add_customer_to_Make_Payment);
                        return;
                    }
                }
                for (var i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                    if ($scope.CustomerOrderModel.CheckOutItems[i].IsActive) {
                        $scope.CustomerOrderModel.CheckOutItems[i].IsDisplayDiscountAmount = $scope.CustomerOrderModel.enableshowAmountSavedCheckBox;
                    }
                }
                var coInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                CustomerInfoService.FinaliseInvoice(JSON.stringify($scope.CustomerOrderModel.CheckOutItems), $scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.checkOutMode).then(function(successfulSearchResult) {
                    $scope.setAllData(successfulSearchResult);
                    $scope.CustomerOrderModel.LoadServiceOrder();
                    $scope.isInvoiceFinalizePressed = false;
                    if ($scope.CustomerOrderModel.enablePrintInvoiceCheckBox == true) {
                        if (successfulSearchResult.COInvoiceHistoryRecs != null && successfulSearchResult.COInvoiceHistoryRecs.length > 0) {
                            if (coInvoiceHeaderId != undefined && coInvoiceHeaderId != '' && coInvoiceHeaderId != null) {
                                $scope.CustomerOrderModel.invoicePrintPriview(coInvoiceHeaderId);
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.enableEmailInvoiceCheckBox == true) {
                        if (successfulSearchResult.COInvoiceHistoryRecs != null && successfulSearchResult.COInvoiceHistoryRecs.length > 0) {
                            if (coInvoiceHeaderId != undefined && coInvoiceHeaderId != '' && coInvoiceHeaderId != null) {
                                $scope.CustomerOrderModel.openEmailPopUp(coInvoiceHeaderId);
                            }
                        }
                    }
                    $scope.CustomerOrderModel.checkoutDownArrowClick();
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, 'InvoiceHistory');
                    }, 5000);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.FinaliseOrder = function() {
                if ($scope.isOrderFinalizePressed == false) {
                    $scope.isOrderFinalizePressed = true;
                } else {
                    return;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.COType == 'Customer') {
                    if ($scope.CustomerOrderModel.Customer.Value == undefined || $scope.CustomerOrderModel.Customer.Value == null || $scope.CustomerOrderModel.Customer.Value == '') {
                        Notification.error($Label.First_add_customer_to_Make_Payment);
                        return;
                    }
                }
                for (var i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                    if ($scope.CustomerOrderModel.CheckOutItems[i].IsActive) {
                        $scope.CustomerOrderModel.CheckOutItems[i].IsDisplayDiscountAmount = $scope.CustomerOrderModel.enableshowAmountSavedCheckBox;
                    }
                }
                var coInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                CustomerInfoService.FinaliseOrder(JSON.stringify($scope.CustomerOrderModel.CheckOutItems), $scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.checkOutMode).then(function(successfulSearchResult) {
                    $scope.setAllData(successfulSearchResult);
                    $scope.CustomerOrderModel.LoadServiceOrder();
                    $scope.isOrderFinalizePressed = false;
                    if ($scope.CustomerOrderModel.enablePrintInvoiceCheckBox == true) {
                        if (successfulSearchResult.COInvoiceHistoryRecs != null && successfulSearchResult.COInvoiceHistoryRecs.length > 0) {
                            if (coInvoiceHeaderId != undefined && coInvoiceHeaderId != '' && coInvoiceHeaderId != null) {
                                $scope.CustomerOrderModel.invoicePrintPriview(coInvoiceHeaderId);
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.enableEmailInvoiceCheckBox == true) {
                        if (successfulSearchResult.COInvoiceHistoryRecs != null && successfulSearchResult.COInvoiceHistoryRecs.length > 0) {
                            if (coInvoiceHeaderId != undefined && coInvoiceHeaderId != '' && coInvoiceHeaderId != null) {
                                $scope.CustomerOrderModel.openEmailPopUp(coInvoiceHeaderId);
                            }
                        }
                    }
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, 'InvoiceHistory');
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    }, 5000);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            angular.element(document).on("scroll", function() {
                $scope.CustomerOrderModel.onScroll();
            });
            $scope.sidepanelLink = function(event) {
                event.preventDefault();
                angular.element(document).off("scroll");
                var target = angular.element(event.target.closest('a')).attr("href");
                angular.element(angular.element(event.target.closest('a')).attr("rel")).show();
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - top_for_scroll - 60
                }, 100, function() {
                    angular.element(document).on("scroll", function() {
                        $scope.CustomerOrderModel.onScroll();
                    });
                    $scope.CustomerOrderModel.onScroll();
                });
            }
            $scope.scrollSidepanel = function() {
                if ($(".leftPanelLinks .active").position().top < 180 || $(".leftPanelLinks .active").position().top > 480) {
                    $('.leftPanelLinks').animate({
                        scrollTop: $(".leftPanelLinks .active").offset().top
                    }, 100);
                }
            }
            angular.element('.leftPanelLinks').bind('mousewheel', function(e, d) {
                var toolbox = $('.leftPanelLinks'),
                    height = toolbox.height(),
                    scrollHeight = toolbox.get(0).scrollHeight;
                if ((this.scrollTop === (scrollHeight - height) && d < 0) || (this.scrollTop === 0 && d > 0)) {
                    e.preventDefault();
                }
            });
            $scope.CustomerOrderModel.activeSidepanelink = '#CustomerSection';
            $scope.CustomerOrderModel.displaySections = {
                'Customer': true,
                'SpecialOrder': true,
                'Checkout': false,
                'Financing': true
            };
            if (!$rootScope.GroupOnlyPermissions['Merchandise']['view']) {
                $scope.CustomerOrderModel.displaySections['Merchandise'] = false;
            } else {
                $scope.CustomerOrderModel.displaySections['Merchandise'] = true;
            }
            if (!$rootScope.GroupOnlyPermissions['Deal']['view']) {
                $scope.CustomerOrderModel.displaySections['Deal'] = false;
            } else {
                $scope.CustomerOrderModel.displaySections['Deal'] = true;
            }
            if (!$rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                $scope.CustomerOrderModel.displaySections['InvoiceHistory'] = false;
                $scope.CustomerOrderModel.displaySections['Deposit'] = false;
                $scope.CustomerOrderModel.collapseDepositSection = true;
            } else {
                $scope.CustomerOrderModel.displaySections['InvoiceHistory'] = true;
                $scope.CustomerOrderModel.displaySections['Deposit'] = true;
                $scope.CustomerOrderModel.collapseDepositSection = false;
            }
            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function() {
                $scope.CustomerOrderModel.onScroll();
            });
            $scope.CustomerOrderModel.editLineItemsForCauseConcernCorrection = function() {
                $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow = [];
                var SOItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    SOItems.push({
                        isEdit: false,
                        isEditEnabled_ManualConcern: true,
                        isEditEnabled_ManualCause: true,
                        isEditEnabled_ManualCorrection: true,
                        ManualConcern: [],
                        ManualCause: [],
                        ManualCorrection: []
                    });
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualConcern'].length; j++) {
                        SOItems[i].ManualConcern.push({
                            isEdit: false
                        });
                    }
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualCause'].length; j++) {
                        SOItems[i].ManualCause.push({
                            isEdit: false
                        });
                    }
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualCorrection'].length; j++) {
                        SOItems[i].ManualCorrection.push({
                            isEdit: false
                        });
                    }
                }
                $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow = SOItems;
            }
            $scope.CustomerOrderModel.showPermissionSection = function(fieldName, index) {
                if (fieldName == 'Merchandise' && $rootScope.GroupOnlyPermissions['Merchandise']['view']) {
                    $scope.CustomerOrderModel.displaySections[fieldName] = !$scope.CustomerOrderModel.displaySections[fieldName];
                } else if (fieldName == 'ServiceOrder' && $rootScope.GroupOnlyPermissions['Service job']['view'] && !($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service')) {
                    $scope.CustomerOrderModel.displaySections[fieldName][index].display = !$scope.CustomerOrderModel.displaySections[fieldName][index].display;
                } else if (fieldName == 'ServiceOrder' && $rootScope.GroupOnlyPermissions['Internal Service']['view'] && $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service') {
                    $scope.CustomerOrderModel.displaySections[fieldName][index].display = !$scope.CustomerOrderModel.displaySections[fieldName][index].display;
                } else if (fieldName == 'Deal' && $rootScope.GroupOnlyPermissions['Deal']['view']) {
                    $scope.CustomerOrderModel.displaySections[fieldName] = !$scope.CustomerOrderModel.displaySections[fieldName];
                } else if (fieldName == 'DealMerchandise' && $rootScope.GroupOnlyPermissions['Merchandise']['view']) {
                    $scope.CustomerOrderModel.displaySections[fieldName] = !$scope.CustomerOrderModel.displaySections[fieldName];
                } else if (fieldName == 'InvoiceHistory' && $rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    $scope.CustomerOrderModel.displaySections[fieldName] = !$scope.CustomerOrderModel.displaySections[fieldName];
                } else if (fieldName == 'Deposit' && $rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    $scope.CustomerOrderModel.displaySections[fieldName] = !$scope.CustomerOrderModel.displaySections[fieldName];
                    $scope.CustomerOrderModel.collapseDepositSection = !$scope.CustomerOrderModel.collapseDepositSection;
                }
            }
            $scope.CustomerOrderModel.editLineItemsForManualNotes = function() {
                $scope.CustomerOrderModel.NotesForCustomer_editRow = [];
                var SOItemsWithNotes = [];
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    SOItemsWithNotes.push({
                        isEdit: false,
                        isEditEnabled_ManualNotes: true,
                        isEditEnabled_KitNotes: true,
                        ManualNotes: [],
                        KitHeaderNotes: []
                    });
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOReviewRec['ManualNotes'].length; j++) {
                        SOItemsWithNotes[i].ManualNotes.push({
                            isEdit: false
                        });
                    }
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOReviewRec['KitHeaderNotes'].length; j++) {
                        SOItemsWithNotes[i].KitHeaderNotes.push({
                            isEdit: false
                        });
                    }
                }
                $scope.CustomerOrderModel.NotesForCustomer_editRow = SOItemsWithNotes;
            }
            $scope.CustomerOrderModel.editCauseConcernCorrectionItem = function($event, seviceOrderIndex, causeLineItemIndex, ModelKey) {
                if ((!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey].length; i++) {
                    if ($scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][i].isEdit == true) {
                        $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][i].isEdit = false;
                        $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                        isEditModeEnabled = true;
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = true;
                    $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = false;
                    $timeout(function() {
                        angular.element('#causeConcernCorrectionLabeledit_' + ModelKey + '_' + seviceOrderIndex + '_' + causeLineItemIndex).focus();
                    }, 10);
                }
            }
            $scope.CustomerOrderModel.editCauseConcernCorrectionRowTabOut = function(event, seviceOrderIndex, causeLineItemIndex, fieldLabel, ModelKey) {
                $timeout(function() {
                    var isAlreadyExist = false;
                    var fieldValue = $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][causeLineItemIndex];
                    if (event.keyCode == 13 || event.keyCode == 9) {
                        if (fieldValue != '' && fieldValue != undefined) {
                            for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey].length; i++) {
                                if (($scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][i] == fieldValue) && (i != causeLineItemIndex)) {
                                    isAlreadyExist = true;
                                    Notification.error('Same ' + fieldLabel + ' Already Exist');
                                    setTimeout(function() {
                                        angular.element('#causeConcernCorrectionLabeledit_' + ModelKey + '_' + seviceOrderIndex + '_' + causeLineItemIndex).focus();
                                    }, 100);
                                }
                            }
                            if (!isAlreadyExist) {
                                $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][causeLineItemIndex] = fieldValue;
                                $scope.CustomerOrderModel.SaveserviceInfo(seviceOrderIndex);
                                $timeout(function timeout() {
                                    $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = false;
                                    $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                                    Notification.success(fieldLabel + ' ' + $Label.Generic_Saved);
                                }, 1000);
                            }
                        } else {
                            $scope.CustomerOrderModel.removeFromMultiSelect(causeLineItemIndex, seviceOrderIndex, ModelKey);
                            $timeout(function timeout() {
                                $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = false;
                                $scope.CustomerOrderModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                                Notification.success(fieldLabel + ' ' + $Label.Generic_Saved);
                            }, 1000);
                        }
                    }
                }, 10);
            }
            $scope.WizardModel.editLineItemsForCauseConcernCorrection = function() {
                $scope.WizardModel.CauseConcernCorrectionItems_editRow = [];
                var SOItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    SOItems.push({
                        isEditEnabled_ManualConcern: true,
                        isEditEnabled_ManualCause: true,
                        isEditEnabled_ManualCorrection: true,
                        ManualConcern: [],
                        ManualCause: [],
                        ManualCorrection: []
                    });
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualConcern'].length; j++) {
                        SOItems[i].ManualConcern.push({
                            isEdit: false
                        });
                    }
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualCause'].length; j++) {
                        SOItems[i].ManualCause.push({
                            isEdit: false
                        });
                    }
                    for (j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo['ManualCorrection'].length; j++) {
                        SOItems[i].ManualCorrection.push({
                            isEdit: false
                        });
                    }
                }
                $scope.WizardModel.CauseConcernCorrectionItems_editRow = SOItems;
            }
            $scope.WizardModel.editCauseConcernCorrectionItem = function($event, seviceOrderIndex, causeLineItemIndex, ModelKey) {
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey].length; i++) {
                    if ($scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][i].isEdit == true) {
                        $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][i].isEdit = false;
                        $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                        isEditModeEnabled = true;
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = true;
                    $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = false;
                    $timeout(function() {
                        angular.element('#causeConcernCorrectionLabeleditWizard_' + ModelKey + '_' + seviceOrderIndex + '_' + causeLineItemIndex).focus();
                    }, 10);
                }
            }
            $scope.WizardModel.editCauseConcernCorrectionRowTabOut = function(event, seviceOrderIndex, causeLineItemIndex, fieldLabel, ModelKey) {
                $timeout(function() {
                    var isAlreadyExist = false;
                    var fieldValue = $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][causeLineItemIndex];
                    if (event.keyCode == 13 || event.keyCode == 9) {
                        if (fieldValue != '' && fieldValue != undefined) {
                            for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey].length; i++) {
                                if (($scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][i] == fieldValue) && (i != causeLineItemIndex)) {
                                    isAlreadyExist = true;
                                    Notification.error('Same ' + fieldLabel + ' Already Exist');
                                    setTimeout(function() {
                                        angular.element('#causeConcernCorrectionLabeleditWizard_' + ModelKey + '_' + seviceOrderIndex + '_' + causeLineItemIndex).focus();
                                    }, 100);
                                }
                            }
                            if (!isAlreadyExist) {
                                $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOHeaderInfo[ModelKey][causeLineItemIndex] = fieldValue;
                                $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = false;
                                $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                            }
                        } else {
                            $scope.CustomerOrderModel.removeFromMultiSelect(causeLineItemIndex, seviceOrderIndex, ModelKey);
                            $timeout(function timeout() {
                                $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex][ModelKey][causeLineItemIndex].isEdit = false;
                                $scope.WizardModel.CauseConcernCorrectionItems_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                            }, 1000);
                        }
                    }
                }, 10);
            }
            $scope.CustomerOrderModel.isInstallOptionFees = function(dealId, dealItemId, DealUnitIndex, optionFeeskitHeaderItemIndex, optionFeeLineItemIndex) {
                var optionFeeKitHeaderJSON = null;
                var optionFeeItemJSON = null;
                var optionFeeItemId;
                $scope.CustomerOrderModel.UpdateDealCheckout = true;
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList != undefined && $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].Id == null) {
                    if (($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].LabourId != null && $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].LabourId != '') || $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].Status == 'Invoiced' || $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].Status == 'Fulfilled' || ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].ProductId != null && $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].ProductId != '' && $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].ProductType == 'Sublet')) {
                        return;
                    }
                    if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'In Progress' && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        for (var i = 0; i < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length; i++) {
                            for (var j = 0; j < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].RelatedOptionAndFeeIdList.length; j++) {
                                if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].Id == $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].RelatedOptionAndFeeIdList[j]) {
                                    return;
                                }
                            }
                        }
                    }
                    $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].IsInstall = !$scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex].IsInstall;
                    optionFeeItemJSON = $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].OptionAndFeeList[optionFeeLineItemIndex];
                    optionFeeItemId = optionFeeItemJSON.Id;
                    DealService.saveOptionFeesLineItem(dealId, dealItemId, angular.toJson(optionFeeItemJSON)).then(function(successfulSearchResult) {
                        if (successfulSearchResult.DealFulfillmentSectionObj != undefined) {
                            $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                            $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                            $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                            $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                        }
                        if (successfulSearchResult.UnitList != undefined) {
                            $scope.CustomerOrderModel.DealItemList.OptionAndFeeList = successfulSearchResult.UnitList.OptionAndFeeList;
                            $scope.CustomerOrderModel.editLineItemsForOptionFees();
                        }
                        $scope.CustomerOrderModel.LoadServiceOrder();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].Id != null) {
                    if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].IsServiceKit == true) {
                        return;
                    }
                    if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'In Progress' && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        for (var i = 0; i < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length; i++) {
                            for (var j = 0; j < $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].RelatedOptionAndFeeIdList.length; j++) {
                                if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].Id == $scope.CustomerOrderModel.DealUnresolvedFulfillmentList[i].DealKitHeaderId) {
                                    return;
                                }
                            }
                        }
                    }
                    $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].IsInstall = !$scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex].IsInstall;
                    optionFeeKitHeaderJSON = $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealKitHeaderList[optionFeeskitHeaderItemIndex];
                    optionFeeItemId = optionFeeKitHeaderJSON.Id;
                    DealService.recalculationOfDealKHLineItems(angular.toJson(optionFeeKitHeaderJSON), angular.toJson(optionFeeItemJSON)).then(function(successfulSearchResult) {
                        if (successfulSearchResult.DealFulfillmentSectionObj != undefined) {
                            $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                            $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                            $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                            $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                        }
                        if (successfulSearchResult.UnitList != undefined) {
                            $scope.CustomerOrderModel.DealItemList.OptionAndFeeList = successfulSearchResult.UnitList.OptionAndFeeList;
                            $scope.CustomerOrderModel.editLineItemsForOptionFees();
                        }
                        $scope.CustomerOrderModel.LoadServiceOrder();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            $scope.CustomerOrderModel.scrollToPanel = function(event, sectionToscroll) {
                if (event != null) {
                    event.preventDefault();
                }
                angular.element(document).off("scroll");
                var target = angular.element("#" + sectionToscroll);
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                var navBarHeightDiffrenceFixedHeaderClose = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 45;
                    navBarHeightDiffrenceFixedHeaderClose = 50;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 15;
                    navBarHeightDiffrenceFixedHeaderClose = 20;
                }
                var scrollTopPosition = 0;
                if (angular.element(target) != undefined && angular.element(target).offset() != undefined) {
                    if (target.selector == "#CheckoutSection") {
                        scrollTopPosition = angular.element(target).offset().top - 45 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#ServiceNotesSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 150 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#ServiceOrderSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 50 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#DealTradeInSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 105 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if ((target.selector.includes("#ServiceHLSection")) || (target.selector.includes("#ServiceAttachmentsSection"))) {
                        scrollTopPosition = angular.element(target).offset().top - 105 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if ((target.selector.includes("#ServiceHLSection")) || (target.selector.includes("#WorkPicklistStatusId"))) {
                        scrollTopPosition = angular.element(target).offset().top - 105 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#DealUnitSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 105 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#DealSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 40 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#ServiceOrderOdometerSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 150 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#DealMerchandiseSection")) {
                        scrollTopPosition = angular.element(target).offset().top - 40 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (target.selector.includes("#CO_ItemGrid_gid_container_tbody")) {
                        scrollTopPosition = angular.element(target).offset().top - 150 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if (!$scope.CustomerOrderModel.displaySections.Customer && target.selector == '#CustomerSection') {
                        scrollTopPosition = angular.element(target).offset().top - 98 - navBarHeightDiffrenceFixedHeaderClose;
                    } else if (target.selector == "#InvoiceHistory") {
                        scrollTopPosition = angular.element(target).offset().top - 38 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else if ($scope.CustomerOrderModel.displaySections.Customer && target.selector == '#CustomerSection') {
                        scrollTopPosition = angular.element(target).offset().top - 115 - navBarHeightDiffrenceFixedHeaderOpen;
                    } else {
                        scrollTopPosition = angular.element(target).offset().top - 38 - navBarHeightDiffrenceFixedHeaderOpen;
                    }
                }
                angular.element('html, body').stop().animate({
                    scrollTop: scrollTopPosition
                }, 500, function() {
                    angular.element(document).on("scroll", function() {
                        $scope.CustomerOrderModel.onScroll();
                    });
                    $scope.CustomerOrderModel.onScroll();
                });
            }
            $scope.CustomerOrderModel.statusToChevronList = {
                Sign_In: [{
                    Name: 'Service Information',
                    isActive: true,
                    key: 'Service_Information'
                }, {
                    Name: 'Sign In Unit',
                    isActive: false,
                    key: 'Sign_In_Unit'
                }, {
                    Name: 'Approval Method',
                    isActive: false,
                    key: 'Approval_Method'
                }, {
                    Name: 'Seek Approval 1',
                    isActive: false,
                    key: 'Digital_Signature_Approval'
                }, {
                    Name: 'Seek Approval 2',
                    isActive: false,
                    key: 'Print_Approval'
                }, {
                    Name: 'Seek Approval 3',
                    isActive: false,
                    key: 'Remotely_Approval'
                }]
            };
            $scope.CustomerOrderModel.overridenStatusToNextStatusMap = [{
                Key: 'New',
                value: 'Ready'
            }, {
                Key: 'Ready',
                value: 'In Progress'
            }, {
                Key: 'In Progress',
                value: 'On Hold'
            }, {
                Key: 'On Hold',
                value: 'Complete'
            }, {
                Key: 'Complete',
                value: 'Reviewed'
            }, {
                Key: 'Reviewed',
                value: 'Signed Out'
            }, {
                Key: 'Signed Out',
                value: 'Invoiced'
            }, {
                Key: 'Invoiced',
                value: 'Invoiced'
            }, ];
            $scope.CustomerOrderModel.WorkStatusToNextStatusMap = [{
                Key: 'Start Progress',
                value: 'In Progress'
            }, {
                Key: 'Put On Hold',
                value: 'On Hold'
            }, {
                Key: 'Set As Complete',
                value: 'Complete'
            }, {
                Key: 'Re-Open For Work',
                value: 'In Progress'
            }, {
                Key: 'Force To Ready',
                value: 'Ready'
            }, {
                Key: 'Force To Reviewed',
                value: 'Reviewed'
            }, {
                Key: 'Force To Sign Out',
                value: 'Signed Out'
            }, {
                Key: 'Force To Checkout',
                value: 'Signed Out'
            }, ];
            $scope.CustomerOrderModel.ServiceJobActiveStatusMap = {
                'New': ['New', 'Ready', 'In Progress', 'On Hold'],
                'Ready': ['Ready', 'New', 'In Progress', 'On Hold'],
                'In Progress': ['In Progress', 'New', 'Ready', 'On Hold'],
                'On Hold': ['On Hold', 'New', 'Ready', 'In Progress']
            };
            $scope.CustomerOrderModel.ClaimStatusToNextStatusMap = [{
                Key: 'Unsubmitted',
                value: 'Ready to Submit'
            }];
            $scope.CustomerOrderModel.bodyScrollPosition = 0;
            $scope.CustomerOrderModel.toggleWizardMode = function(workStatus, WizardMode, soHeaderIndex) {
                $scope.WizardModel.currentClaimWizardKey = '';
                if (soHeaderIndex != undefined) {
                    $scope.WizardModel.WizardSOHeaderIndex = soHeaderIndex;
                    $scope.WizardModel.WizardSOHeader = angular.copy($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex]);
                    $scope.WizardModel.WizardSOHeaderId = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id;
                }
                $scope.WizardModel.currentWizardKey = workStatus.StatusUniqueKey;
                $scope.WizardModel.currentClaimWizardKey = workStatus.StatusUniqueKey;
                if (workStatus != null && workStatus.StatusUniqueKey == 'Override') {
                    $scope.CustomerOrderModel.workOverrideAction(workStatus.AvailableStatus, soHeaderIndex);
                } else if (workStatus != null && ((workStatus.StatusUniqueKey == 'Start_Progress') || (workStatus.StatusUniqueKey == 'Put_On_Hold') || (workStatus.StatusUniqueKey == 'Set_As_Complete') || (workStatus.StatusUniqueKey == 'Re-Open_For_Work') || (workStatus.StatusUniqueKey == 'Force_To_Ready') || (workStatus.StatusUniqueKey == 'Force_To_Reviewed') || (workStatus.StatusUniqueKey == 'Force_To_Sign_Out') || (workStatus.StatusUniqueKey == 'Force_To_Checkout'))) {
                    $scope.CustomerOrderModel.workStatusChangeAction(workStatus.AvailableStatus, soHeaderIndex);
                } else if (workStatus != null && (workStatus.StatusUniqueKey == 'Log_Service_Work')) {
                    $scope.CustomerOrderModel.createLogHoursPopup($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id, soHeaderIndex)
                } else if (workStatus != null && (workStatus.StatusUniqueKey == 'Go_To_CheckOut')) {
                    if ($scope.CustomerOrderModel.CheckOutItems.length == 0) {
                        Notification.error('No Items to checkout');
                    } else {
                        $scope.CustomerOrderModel.scrollToPanel(null, 'CheckoutSection');
                    }
                } else if (workStatus != null && workStatus.StatusUniqueKey == 'Review_Service') {
                    $scope.CustomerOrderModel.PrintPreviewDetails($scope.WizardModel.WizardSOHeaderId);
                    $scope.CustomerOrderModel.currentChevronList = [{
                        Name: 'Review & Comment',
                        isActive: true,
                        key: 'Review_Service'
                    }]
                    $scope.CustomerOrderModel.isWizardMode = WizardMode;
                    $scope.CustomerOrderModel.isWorkWizardMode = WizardMode;
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') $scope.$apply();
                    angular.element('html, body').stop().animate({
                        scrollTop: 0
                    }, 1);
                } else if (workStatus != null && workStatus.StatusUniqueKey == 'Service_Sign_Out') {
                    $scope.CustomerOrderModel.currentChevronList = [{
                        Name: 'Approval Method',
                        isActive: false,
                        key: 'Approval_Method'
                    }]
                    $scope.CustomerOrderModel.isWizardMode = WizardMode;
                    $scope.CustomerOrderModel.isWorkWizardMode = WizardMode;
                    WizardService.getWizardInfo($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id, workStatus.StatusUniqueKey).then(function(successfulSearchResult) {
                        $scope.WizardModel.wizardInfo = successfulSearchResult;
                        $scope.WizardModel.createApprovalVariables();
                        $scope.WizardModel.changeApprovalMethod(true);
                        $scope.WizardModel.getCustomerInfo();
                        angular.element('html, body').stop().animate({
                            scrollTop: 0
                        }, 1);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else if (workStatus != null && workStatus.StatusUniqueKey == 'Get_Customer_Approval') {
                    $scope.CustomerOrderModel.bodyScrollPosition = angular.element(document).scrollTop();
                    $scope.CustomerOrderModel.isWizardMode = WizardMode;
                    $scope.CustomerOrderModel.isWorkWizardMode = WizardMode;
                    angular.element('html, body').stop().animate({
                        scrollTop: 0
                    }, 1);
                    WizardService.getCustomerApprovalInfo($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id, 'Get_Approval', null).then(function(successfulSearchResult) {
                        $scope.WizardModel.wizardInfo = {};
                        $scope.WizardModel.wizardInfo.Sign_In = {};
                        $scope.WizardModel.wizardInfo.Sign_In.Approval_Method = successfulSearchResult;
                        $scope.WizardModel.createApprovalVariables();
                        $scope.WizardModel.changeApprovalMethod(true);
                        $scope.WizardModel.getCustomerInfo();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else {
                    $scope.CustomerOrderModel.isWizardMode = WizardMode;
                    $scope.CustomerOrderModel.isWorkWizardMode = WizardMode;
                    if ($scope.CustomerOrderModel.isWizardMode) {
                        $scope.CustomerOrderModel.bodyScrollPosition = angular.element(document).scrollTop();
                        if (workStatus != null) {
                            WizardService.getWizardInfo($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id, workStatus.StatusUniqueKey).then(function(successfulSearchResult) {
                                $scope.WizardModel.wizardInfo = successfulSearchResult;
                                $scope.WizardModel.wizardInfo.Sign_In.Service_Information.selectedTime = $scope.CustomerOrderModel.getTimeFromSFformat($scope.WizardModel.wizardInfo.Sign_In.Service_Information.PromisedBy);
                                $scope.WizardModel.wizardInfo.Sign_In.Service_Information.selectedDate = $scope.CustomerOrderModel.getDateFromSFformat($scope.WizardModel.wizardInfo.Sign_In.Service_Information.PromisedBy);
                                $scope.WizardModel.wizardInfo.Sign_In.Service_Information.CategoryNameStr = $scope.WizardModel.wizardInfo.Sign_In.Service_Information.CategoryName;
                                $scope.WizardModel.setCurrentCOU($scope.WizardModel.wizardInfo.Sign_In.Service_Information.COUId);
                                $scope.WizardModel.createApprovalVariables();
                                $scope.WizardModel.changeApprovalMethod(true);
                                $scope.WizardModel.getCustomerInfo();
                                $scope.WizardModel.editLineItemsForCauseConcernCorrection();
                                angular.element('html, body').stop().animate({
                                    scrollTop: 0
                                }, 1);
                            }, function(errorSearchResult) {
                                responseData = errorSearchResult;
                            });
                        }
                    } else {
                        angular.element('html, body').stop().animate({
                            scrollTop: $scope.CustomerOrderModel.bodyScrollPosition
                        }, 1);
                    }
                }
            }
            $scope.CustomerOrderModel.openCustomerApproval = function(soHeaderIndex) {
                if ((!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                var workStatus = {
                    AvailableStatus: 'Get Customer Approval',
                    StatusUniqueKey: 'Get_Customer_Approval'
                };
                $scope.CustomerOrderModel.toggleWizardMode(workStatus, true, soHeaderIndex);
            }
            $scope.CustomerOrderModel.openPendingCustomerApproval = function(soHeaderIndex, sectionKey, count, status) {
                if (status == 'Pending' && sectionKey != undefined) {
                    if (sectionKey == 'Get_Approval') {
                        sectionKey = 'Get_Customer_Approval';
                    }
                    var workStatus = {
                        AvailableStatus: sectionKey.replace(/_/g, ' '),
                        StatusUniqueKey: sectionKey
                    };
                    $scope.CustomerOrderModel.toggleWizardMode(workStatus, true, soHeaderIndex, count);
                }
            }
            $scope.CustomerOrderModel.changeStatus = function(index, soHeaderIndex, newstatus, modelKey) {
                WizardService.changeStatus(soHeaderIndex, newstatus, 'Work').then(function(successfulSearchResult) {
                    $timeout(function() {
                        $scope.CustomerOrderModel.SOHeaderList[index][modelKey] = false;
                        Notification.success($Label.Generic_Saved);
                    }, 10);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveServiceOrderScheduleDate = function(soHeaderIndex, scheduledDate) {
                SOHeaderService.saveScheduleDate(soHeaderIndex, scheduledDate).then(function(successfulSearchResult) {}, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.createApprovalVariables = function() {
                $scope.WizardModel.wizardInfo.Sign_In.Digital_Signature_Approval = false;
                $scope.WizardModel.wizardInfo.Sign_In.Print_Approval = false;
                $scope.WizardModel.wizardInfo.Sign_In.Remotely_Approval = false;
                for (var i = 0; i < $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.length; i++) {
                    $scope.WizardModel.wizardInfo.Sign_In[$scope.WizardModel.wizardInfo.Sign_In.Approval_Method[i].ApprovalType] = true;
                }
            }
            $scope.WizardModel.changeApprovalMethod = function(isLoad, checkBoxModel) {
                $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method = [];
                $scope.CustomerOrderModel.currentChevronList = [];
                if (!isLoad) {
                    $scope.WizardModel.wizardInfo.Sign_In[checkBoxModel] = !$scope.WizardModel.wizardInfo.Sign_In[checkBoxModel];
                }
                if ($scope.WizardModel.currentWizardKey == 'Sign_In') {
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Service Information',
                        isActive: false,
                        key: 'Service_Information'
                    });
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Sign In Unit',
                        isActive: false,
                        key: 'Sign_In_Unit'
                    });
                }
                if ($scope.WizardModel.currentWizardKey == 'Sign_In' || $scope.WizardModel.currentWizardKey == 'Service_Sign_Out' || $scope.WizardModel.currentWizardKey == 'Get_Customer_Approval') {
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Approval Method',
                        isActive: false,
                        key: 'Approval_Method'
                    });
                }
                var DigitalSignIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.Approval_Method, {
                    ApprovalType: 'Digital_Signature_Approval'
                });
                var PrintIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.Approval_Method, {
                    ApprovalType: 'Print_Approval'
                });
                var RemoteIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.Approval_Method, {
                    ApprovalType: 'Remotely_Approval'
                });
                if ($scope.WizardModel.wizardInfo.Sign_In.Digital_Signature_Approval) {
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Seek Approval',
                        isActive: false,
                        key: 'Digital_Signature_Approval'
                    });
                    if (DigitalSignIndex == -1) {
                        var deletedDigitalSignIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method, {
                            ApprovalType: 'Digital_Signature_Approval'
                        });
                        var recordId;
                        if (deletedDigitalSignIndex > -1) {
                            recordId = $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method[deletedDigitalSignIndex].Id;
                        }
                        $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.push({
                            ApprovalType: 'Digital_Signature_Approval',
                            Id: recordId,
                            IsApprovalObtained: false
                        });
                    }
                } else if (DigitalSignIndex != -1) {
                    $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method.push($scope.WizardModel.wizardInfo.Sign_In.Approval_Method[DigitalSignIndex]);
                    $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.splice(DigitalSignIndex, 1);
                }
                if ($scope.WizardModel.wizardInfo.Sign_In.Print_Approval) {
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Seek Approval',
                        isActive: false,
                        key: 'Print_Approval'
                    });
                    if (PrintIndex == -1) {
                        var deletedPrintIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method, {
                            ApprovalType: 'Print_Approval'
                        });
                        var recordId;
                        if (deletedPrintIndex > -1) {
                            recordId = $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method[deletedPrintIndex].Id;
                        }
                        $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.push({
                            ApprovalType: 'Print_Approval',
                            Id: recordId,
                            SectionKey: 'Sign_In',
                            IsApprovalObtained: false
                        });
                    }
                } else if (PrintIndex != -1) {
                    $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method.push($scope.WizardModel.wizardInfo.Sign_In.Approval_Method[PrintIndex]);
                    $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.splice(PrintIndex, 1);
                }
                if ($scope.WizardModel.wizardInfo.Sign_In.Remotely_Approval) {
                    $scope.CustomerOrderModel.currentChevronList.push({
                        Name: 'Seek Approval',
                        isActive: false,
                        key: 'Remotely_Approval'
                    });
                    if (RemoteIndex == -1) {
                        var deletedRemoteIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method, {
                            ApprovalType: 'Remotely_Approval'
                        });
                        var recordId;
                        if (deletedRemoteIndex > -1) {
                            recordId = $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method[deletedRemoteIndex].Id;
                        }
                        $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.push({
                            ApprovalType: 'Remotely_Approval',
                            Id: recordId,
                            IsApprovalObtained: false
                        });
                    }
                } else if (RemoteIndex != -1) {
                    $scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method.push($scope.WizardModel.wizardInfo.Sign_In.Approval_Method[RemoteIndex]);
                    $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.splice(PrintIndex, 1);
                }
                var ApprovalMethodIndex = _.findIndex($scope.CustomerOrderModel.currentChevronList, {
                    key: 'Approval_Method'
                });
                for (var i = ApprovalMethodIndex + 1; i < $scope.CustomerOrderModel.currentChevronList.length; i++) {
                    $scope.CustomerOrderModel.currentChevronList[i].Name = $scope.CustomerOrderModel.currentChevronList[i].Name + ' ' + (i - ApprovalMethodIndex);
                }
                isLoad ? $scope.CustomerOrderModel.currentChevronList[0].isActive = true : $scope.CustomerOrderModel.currentChevronList[ApprovalMethodIndex].isActive = true;
            }
            $scope.WizardModel.getCustomerInfo = function() {
                if ($scope.CustomerOrderModel.CustomerInfoData == null) {
                    $scope.WizardModel.customerInfoJSON = [];
                    return;
                }
                $scope.WizardModel.customerInfoJSON = [{
                    Label: 'CALL (Home)',
                    Value: $scope.CustomerOrderModel.CustomerInfoData.Cust_HomeNumber,
                    IsSelected: false,
                    Type: 'Phone'
                }, {
                    Label: 'SEND EMAIL (Home)',
                    Value: $scope.CustomerOrderModel.CustomerInfoData.Cust_HomeEmail,
                    IsSelected: false,
                    Type: 'Email'
                }, {
                    Label: 'CALL (Other)',
                    Value: $scope.CustomerOrderModel.CustomerInfoData.Cust_Mobile,
                    IsSelected: false,
                    Type: 'Phone'
                }, {
                    Label: 'SEND EMAIL (Other)',
                    Value: $scope.CustomerOrderModel.CustomerInfoData.Cust_OtherEmail,
                    IsSelected: false,
                    Type: 'Email'
                }];
            }
            $scope.WizardModel.changeApprovalObtained = function(index) {
                $scope.WizardModel.wizardInfo.Sign_In.Approval_Method[index].IsApprovalObtained = !$scope.WizardModel.wizardInfo.Sign_In.Approval_Method[index].IsApprovalObtained;
            }
            $scope.WizardModel.saveWizardData = function() {
                WizardService.saveWizardDetails($scope.WizardModel.WizardSOHeaderId, $scope.WizardModel.currentWizardKey, JSON.stringify($scope.WizardModel.wizardInfo.Sign_In), JSON.stringify($scope.WizardModel.wizardInfo.Sign_In.deletedApproval_Method)).then(function(successfulSearchResult) {
                    //FIXME
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.saveServiceClaimWizardData = function() {
                WizardService.saveWizardDetails($scope.WizardModel.WizardSOHeaderId, $scope.WizardModel.currentClaimWizardKey, JSON.stringify($scope.WizardModel.wizardInfo.Ready_to_Submit), null).then(function(successfulSearchResult) {
                    //FIXME
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.saveGetApproval = function() {
                WizardService.saveCustomerApprovalInfo($scope.WizardModel.WizardSOHeaderId, JSON.stringify($scope.WizardModel.wizardInfo.Sign_In.Approval_Method)).then(function(successfulSearchResult) {
                    $scope.WizardModel.wizardInfo.Sign_In.Approval_Method = successfulSearchResult;
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.submitForReview = function() {
                $scope.CustomerOrderModel.saveServiceReview($scope.WizardModel.WizardSOHeaderIndex, true);
                var index = _.findIndex($scope.CustomerOrderModel.overridenStatusToNextStatusMap, {
                    Key: $scope.CustomerOrderModel.SOHeaderList[$scope.WizardModel.WizardSOHeaderIndex].SOHeaderInfo.WorkStatus
                });
                var newStatus = $scope.CustomerOrderModel.overridenStatusToNextStatusMap[index].value;
                WizardService.changeStatus($scope.WizardModel.WizardSOHeaderId, newStatus, 'Work').then(function(successfulSearchResult) {
                    $scope.WizardModel.closeWizardMode();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.SendEmailOnSignInWizard = function() {
                var RemoteIndex = _.findIndex($scope.WizardModel.wizardInfo.Sign_In.Approval_Method, {
                    ApprovalType: 'Remotely_Approval'
                });
                var Notes = '';
                if (RemoteIndex > -1) {
                    Notes = $scope.WizardModel.wizardInfo.Sign_In.Approval_Method[RemoteIndex].Notes;
                }
                WizardService.sendOnSignInWizard(JSON.stringify($scope.WizardModel.customerInfoJSON), Notes, $scope.WizardModel.WizardSOHeaderId, $scope.CustomerOrderModel.Customer.Name).then(function(successfulSearchResult) {
                    if (successfulSearchResult == 'Sent') {
                        Notification.success($Label.CustomerOrder_Js_Email_sent);
                    } else {
                        Notification.error($Label.CustomerOrder_Js_Select_valid_email_address);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.selectOptionForClaim = function(index) {
                if ($scope.CustomerOrderModel.vendorInfoJSON[index].Label != 'SEND EMAIL (Work)' && $scope.CustomerOrderModel.vendorInfoJSON[index].Label != 'SEND EMAIL (OTHER)') {
                    $scope.CustomerOrderModel.vendorInfoJSON[index].IsSelected = !$scope.CustomerOrderModel.vendorInfoJSON[index].IsSelected;
                } else {
                    return;
                }
            }
            $scope.WizardModel.SendEmailOnClaimWizard = function() {
                var sendEmail = false;
                for (var i = 0; i < $scope.CustomerOrderModel.vendorInfoJSON.length; i++) {
                    if ($scope.CustomerOrderModel.vendorInfoJSON[i].Type == 'Email' && $scope.CustomerOrderModel.vendorInfoJSON[i].IsSelected) {
                        sendEmail = true;
                        break;
                    }
                }
                if (sendEmail) {
                    var Notes = $scope.WizardModel.wizardInfo.Ready_to_Submit.Approval_Method[0].Notes;
                    Notes = Notes == undefined ? '' : Notes;
                    WizardService.sendOnSignInWizard(JSON.stringify($scope.CustomerOrderModel.vendorInfoJSON), Notes, $scope.WizardModel.WizardSOHeaderId, $scope.CustomerOrderModel.Customer.Name).then(function(successfulSearchResult) {
                        if (successfulSearchResult == 'Sent') {
                            Notification.success($Label.CustomerOrder_Js_Email_sent);
                            $scope.WizardModel.submitClaimRecords();
                        } else {
                            Notification.error($Label.CustomerOrder_Js_Select_valid_email_address);
                        }
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else {
                    $scope.WizardModel.submitClaimRecords();
                }
            }
            $scope.WizardModel.submitClaimRecords = function() {
                WizardService.submitClaimRecords($scope.WizardModel.WizardSOHeaderId).then(function(successfulSearchResult) {
                    $scope.WizardModel.closeWizardMode();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.WizardModel.saveAndExitSignIn = function(isSave) {
                if (isSave) {
                    if ($scope.WizardModel.currentWizardKey == 'Sign_In') {
                        $scope.CustomerOrderModel.SaveserviceInfo($scope.WizardModel.WizardSOHeaderIndex, true);
                        $scope.WizardModel.saveWizardData();
                    } else if ($scope.WizardModel.currentWizardKey == 'Review_Service') {
                        $scope.WizardModel.submitForReview();
                    } else if ($scope.WizardModel.currentClaimWizardKey == 'Claim_Submission') {
                        $scope.CustomerOrderModel.SaveserviceInfo($scope.WizardModel.WizardSOHeaderIndex, true);
                        $scope.WizardModel.saveServiceClaimWizardData();
                    } else if ($scope.WizardModel.currentWizardKey == 'Get_Customer_Approval') {
                        $scope.WizardModel.saveGetApproval();
                    } else if ($scope.WizardModel.currentWizardKey == 'Service_Sign_Out') {
                        var index = _.findIndex($scope.CustomerOrderModel.overridenStatusToNextStatusMap, {
                            Key: $scope.CustomerOrderModel.SOHeaderList[$scope.WizardModel.WizardSOHeaderIndex].SOHeaderInfo.WorkStatus
                        });
                        var newStatus = $scope.CustomerOrderModel.overridenStatusToNextStatusMap[index].value;
                        WizardService.changeStatus($scope.WizardModel.WizardSOHeaderId, newStatus, 'Work').then(function(successfulSearchResult) {
                            $scope.WizardModel.closeWizardMode();
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                    }
                }
                $scope.WizardModel.closeWizardMode();
            }
            $scope.WizardModel.closeWizardMode = function() {
                $scope.CustomerOrderModel.isWizardMode = false;
                $scope.CustomerOrderModel.isWorkWizardMode = false;
                $scope.CustomerOrderModel.isClaimWizardMode = false;
                angular.element('html, body').stop().animate({
                    scrollTop: $scope.CustomerOrderModel.bodyScrollPosition
                }, 1);
                $scope.LoadCustomerOrder();
            }
            $scope.WizardModel.updateApprovalList = function(approvalList) {
                for (var i = 0; i < approvalList.length; i++) {
                    for (var j = 0; j < $scope.WizardModel.wizardInfo.Sign_In.Approval_Method.length; j++) {
                        if (approvalList[i].ApprovalType == $scope.WizardModel.wizardInfo.Sign_In.Approval_Method[j].ApprovalType) {
                            $scope.WizardModel.wizardInfo.Sign_In.Approval_Method[j].Id = approvalList[i].Id;
                            break;
                        }
                    }
                }
            }
            $scope.WizardModel.getCurrentActiveChevronIndex = function() {
                if ($scope.WizardModel != null && $scope.WizardModel.currentClaimWizardKey == 'Claim_Response') {
                    $scope.CustomerOrderModel.updateFinalizeButtonVisibility();
                }
                var index = _.findIndex($scope.CustomerOrderModel.currentChevronList, {
                    isActive: true
                });
                return index + 1;
            }
            $scope.CustomerOrderModel.updateChevronList = function(workStatus, soHeaderIndex) {
                $scope.CustomerOrderModel.currentChevronList = $scope.CustomerOrderModel.statusToChevronList[workStatus.StatusUniqueKey];
                angular.forEach($scope.CustomerOrderModel.currentChevronList, function(value, key) {
                    value.isActive = false;
                });
                $scope.CustomerOrderModel.currentChevronList[0].isActive = true;
            }
            $scope.CustomerOrderModel.workOverrideAction = function(workStatus, soHeaderIndex) {
                var index = _.findIndex($scope.CustomerOrderModel.overridenStatusToNextStatusMap, {
                    Key: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.WorkStatus
                });
                var newStatus = $scope.CustomerOrderModel.overridenStatusToNextStatusMap[index].value;
                var appLogInfo = {
                    oldStatus: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.WorkStatus,
                    newStatus: newStatus,
                    soHeaderId: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id,
                    label: workStatus,
                    isWorkStatus: $scope.CustomerOrderModel.isWorkWizardMode
                };
                var COActionModelParams = {
                    appLog: appLogInfo
                };
                loadState($state, 'CustomerOrder.COActionModel', {
                    COActionModelParams: COActionModelParams
                });
            }
            $scope.CustomerOrderModel.workStatusChangeAction = function(workStatus, soHeaderIndex) {
                var index = _.findIndex($scope.CustomerOrderModel.WorkStatusToNextStatusMap, {
                    Key: workStatus
                });
                var newStatus = $scope.CustomerOrderModel.WorkStatusToNextStatusMap[index].value;
                var appLogInfo = {
                    oldStatus: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.WorkStatus,
                    newStatus: newStatus,
                    soHeaderId: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id,
                    label: workStatus,
                    type: 'Work',
                    soHeaderIndex: soHeaderIndex
                };
                var COActionModelParams = {
                    appLog: appLogInfo
                };
                loadState($state, 'CustomerOrder.COActionModel', {
                    COActionModelParams: COActionModelParams
                });
            }
            $scope.CustomerOrderModel.claimStatusChangeAction = function(claimStatus, soHeaderIndex) {
                var index = _.findIndex($scope.CustomerOrderModel.ClaimStatusToNextStatusMap, {
                    Key: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.ClaimStatus
                });
                var newStatus = $scope.CustomerOrderModel.ClaimStatusToNextStatusMap[index].value;
                var appLogInfo = {
                    oldStatus: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.ClaimStatus,
                    newStatus: newStatus,
                    soHeaderId: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id,
                    label: claimStatus,
                    type: 'Claim'
                };
                var COActionModelParams = {
                    appLog: appLogInfo
                };
                loadState($state, 'CustomerOrder.COActionModel', {
                    COActionModelParams: COActionModelParams
                });
            }
            $scope.$on('Override_Status', function(event, args) {
                var soHeaderIndex = args.soHeaderIndex;
                if ($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOSignInRec.Odometer != '' && $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOSignInRec.Odometer != undefined && ($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOReviewRec.OdometerOnDeparture === '' || $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOReviewRec.OdometerOnDeparture == undefined || $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOReviewRec.OdometerOnDeparture == null || parseFloat($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOReviewRec.OdometerOnDeparture) == 0)) {
                    $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOReviewRec.OdometerOnDeparture = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOSignInRec.Odometer;
                    $scope.CustomerOrderModel.saveOdometerDeparture(soHeaderIndex, false);
                    $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].hideOdometerDeparture = true;
                }
                $scope.LoadCustomerOrder();
            });
            $scope.CustomerOrderModel.changeWorkStatus = function(workStatus, soHeaderIndex) {
                if ($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.COUId == null || $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.COUId == undefined || $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.COUId == '') {
                    Notification.error('Please select a unit before setting the status to complete');
                    return;
                }
                var target = '#ServiceOrderSection' + soHeaderIndex;
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - 50
                }, 500, function() {}).promise().then(function() {
                    $scope.CustomerOrderModel.toggleWizardMode(workStatus, true, soHeaderIndex);
                });
                $scope.CustomerOrderModel.resetCauseConcernCorrection();
            }
            $scope.CustomerOrderModel.changeClaimStatus = function(claimStatus, soHeaderIndex) {
                var target = '#ServiceOrderSection' + soHeaderIndex;
                angular.element('html, body').stop().animate({
                    scrollTop: angular.element(target).offset().top - 48
                }, 500, function() {}).promise().then(function() {
                    $scope.CustomerOrderModel.toggleClaimWizardMode(claimStatus, true, soHeaderIndex);
                });
            }
            $scope.CustomerOrderModel.editClaimResponseDetailItemRow = function(indexVal) {
                if (indexVal == null) {
                    indexVal = -1;
                }
                if ($scope.WizardModel.wizardInfo.NonVarianceLineItemList != null) {
                    for (var i = 0; i < $scope.WizardModel.wizardInfo.NonVarianceLineItemList.length; i++) {
                        if (indexVal == i) {
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].IsEdit = true;
                        } else {
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].IsEdit = false;
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.toggleClaimWizardMode = function(claimStatus, WizardMode, soHeaderIndex) {
                $scope.WizardModel.currentWizardKey = '';
                if (soHeaderIndex != undefined) {
                    $scope.WizardModel.WizardSOHeaderIndex = soHeaderIndex;
                    $scope.WizardModel.WizardSOHeader = angular.copy($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex]);
                    $scope.WizardModel.WizardSOHeaderId = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id;
                }
                if (claimStatus.StatusUniqueKey == 'View_Claim_Response') {
                    claimStatus.StatusUniqueKey = 'Claim_Response';
                }
                if (claimStatus.StatusUniqueKey == 'View_Submitted_Claim') {
                    claimStatus.StatusUniqueKey = 'Claim_Submission';
                }
                $scope.WizardModel.currentClaimWizardKey = claimStatus.StatusUniqueKey;
                if (claimStatus != null && claimStatus.StatusUniqueKey == 'Force_Claim_Submission') {
                    $scope.CustomerOrderModel.claimStatusChangeAction(claimStatus.AvailableStatus, soHeaderIndex);
                } else if (claimStatus != null) {
                    $scope.CustomerOrderModel.isWizardMode = WizardMode;
                    $scope.CustomerOrderModel.isClaimWizardMode = WizardMode;
                    if ($scope.CustomerOrderModel.isWizardMode) {
                        $scope.WizardModel.WizardSOHeaderId = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id;
                        $scope.CustomerOrderModel.bodyScrollPosition = angular.element(document).scrollTop();
                        if (claimStatus != null) {
                            if (claimStatus.StatusUniqueKey == 'Claim_Submission') {
                                var providerId = $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.ProviderId;
                                if (providerId != null) {
                                    $scope.CustomerOrderModel.getProviderInfo(providerId);
                                }
                                $scope.CustomerOrderModel.currentChevronList = [{
                                    Name: 'Claim Information',
                                    isActive: false,
                                    key: 'Claim_Information'
                                }, {
                                    Name: 'Claim Details',
                                    isActive: false,
                                    key: 'Claim_Details'
                                }, {
                                    Name: 'Attachments',
                                    isActive: false,
                                    key: 'Attachments'
                                }, {
                                    Name: 'Submit Claim',
                                    isActive: false,
                                    key: 'Submit_Claim'
                                }];
                            } else if (claimStatus.StatusUniqueKey == 'Claim_Response') {
                                $scope.CustomerOrderModel.currentChevronList = [{
                                    Name: 'Response Information',
                                    isActive: false,
                                    key: 'Claim_Response_Information'
                                }, {
                                    Name: 'Response Details',
                                    isActive: false,
                                    key: 'Claim_Response_Details'
                                }, {
                                    Name: 'Variance Disposition',
                                    isActive: false,
                                    key: 'Claim_Response_Variance_Disposition'
                                }];
                            } else if (claimStatus.StatusUniqueKey == 'View_Claim_Response') {}
                            if ($scope.CustomerOrderModel.currentChevronList != null) {
                                $scope.CustomerOrderModel.currentChevronList[0].isActive = true;
                            }
                            WizardService.getWizardInfo($scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id, claimStatus.StatusUniqueKey).then(function(successfulSearchResult) {
                                $scope.WizardModel.wizardInfo = successfulSearchResult;
                                $scope.WizardModel.wizardInfo.NextButtonAvail = true;
                                angular.element('html, body').stop().animate({
                                    scrollTop: 0
                                }, 1);
                                if (claimStatus.StatusUniqueKey == 'Claim_Submission') {
                                    $scope.WizardModel.getCustomerInfo();
                                    if ($scope.WizardModel.wizardInfo.Ready_to_Submit != null && $scope.WizardModel.wizardInfo.Ready_to_Submit.Approval_Method.length == 0) {
                                        $scope.WizardModel.wizardInfo.Ready_to_Submit.Approval_Method.push({
                                            ApprovalType: 'Submit_Claim'
                                        })
                                    }
                                } else if (claimStatus.StatusUniqueKey == 'Claim_Response') {
                                    angular.element('html, body').stop().animate({
                                        scrollTop: 0
                                    }, 1);
                                    $scope.WizardModel.wizardInfo.ClaimDispositionsList = ['Accepted', 'Denied'];
                                    if ($scope.WizardModel.wizardInfo.ClaimDisposition == 'Accepted w/ Adjustment') {
                                        $scope.WizardModel.wizardInfo.ClaimDispositionsList.remove('Accepted w/ Adjustment');
                                        $scope.WizardModel.wizardInfo.ClaimDispositionsList.push('Accepted w/ Adjustment');
                                    }
                                    $scope.WizardModel.wizardInfo.VarianceBillToList = ['Internal', 'Customer'];
                                    if ($scope.WizardModel.wizardInfo.InternalCategoryList == null) {
                                        $scope.WizardModel.wizardInfo.InternalCategoryList = [];
                                    }
                                    $scope.CustomerOrderModel.editClaimResponseDetailItemRow(-1);
                                    $scope.CustomerOrderModel.calculateClaimResponseVariance(null);
                                    $scope.CustomerOrderModel.resetClaimResponseValidation();
                                } else if (claimStatus.StatusUniqueKey == 'View_Claim_Response') {}
                            }, function(errorSearchResult) {
                                responseData = errorSearchResult;
                            });
                        }
                    } else {
                        angular.element('html, body').stop().animate({
                            scrollTop: $scope.CustomerOrderModel.bodyScrollPosition
                        }, 1);
                    }
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }
            $scope.CustomerOrderModel.NextAction = function(index) {
                if ($scope.CustomerOrderModel.isClaimWizardMode) {
                    if ($scope.WizardModel.currentClaimWizardKey == 'Claim_Response') {
                        if ($scope.WizardModel.wizardInfo.ResponseDate == null || $scope.WizardModel.wizardInfo.ResponseDate.length == 0) {
                            $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ResponseDate'] = {
                                isError: true,
                                ErrorMessage: "Response Date is required"
                            };
                            return;
                        } else if ($scope.WizardModel.wizardInfo.ProviderClaimNumber == null || $scope.WizardModel.wizardInfo.ProviderClaimNumber.length == 0 || $scope.WizardModel.wizardInfo.ProviderClaimNumber.length == '') {
                            $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ProviderClaimNumber'] = {
                                isError: true,
                                ErrorMessage: "Claim No is required"
                            };
                            return;
                        } else {
                            $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ResponseDate'] = {
                                isError: false,
                                ErrorMessage: ""
                            };
                            $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ProviderClaimNumber'] = {
                                isError: false,
                                ErrorMessage: ""
                            };
                        }
                    }
                }
                var newIndex = index == -1 ? _.findIndex($scope.CustomerOrderModel.currentChevronList, {
                    isActive: true
                }) + 1 : index;
                if (newIndex != -1) {
                    angular.forEach($scope.CustomerOrderModel.currentChevronList, function(value, key) {
                        value.isActive = false;
                    });
                    if (newIndex < $scope.CustomerOrderModel.currentChevronList.length) {
                        $scope.CustomerOrderModel.currentChevronList[newIndex].isActive = true;
                        var sectionKey = $scope.CustomerOrderModel.currentChevronList[newIndex].key;
                        if (sectionKey == 'Digital_Signature_Approval' || sectionKey == 'Print_Approval' || sectionKey == 'Remotely_Approval' || sectionKey == 'Submit_Claim' || sectionKey == 'Review_Service') {
                            $scope.CustomerOrderModel.PrintPreviewDetails($scope.WizardModel.WizardSOHeaderId);
                        }
                    }
                }
                if (index == -1) {
                    if ($scope.CustomerOrderModel.isWorkWizardMode) {
                        if ($scope.WizardModel.currentWizardKey == 'Get_Customer_Approval') {
                            $scope.WizardModel.saveGetApproval();
                        }
                        if ($scope.WizardModel.currentWizardKey == 'Sign_In' && newIndex == 1) {
                            $scope.CustomerOrderModel.SaveserviceInfo($scope.WizardModel.WizardSOHeaderIndex, true);
                        }
                        $scope.WizardModel.saveWizardData();
                    }
                    if ($scope.CustomerOrderModel.isClaimWizardMode) {
                        if ($scope.WizardModel.currentClaimWizardKey == 'Claim_Submission') {
                            $scope.CustomerOrderModel.SaveserviceInfo($scope.WizardModel.WizardSOHeaderIndex, true);
                        } else if ($scope.WizardModel.currentClaimWizardKey == 'Claim_Response') {
                            $scope.CustomerOrderModel.SaveClaimResponse($scope.WizardModel.wizardInfo.SOHeaderId, $scope.WizardModel.wizardInfo, $scope.WizardModel.getCurrentActiveChevronIndex() - 1, false);
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.SaveAndCloseClaimResponseAction = function(index) {
                $scope.CustomerOrderModel.SaveClaimResponse($scope.WizardModel.wizardInfo.SOHeaderId, $scope.WizardModel.wizardInfo, $scope.WizardModel.getCurrentActiveChevronIndex(), true);
            }
            $scope.CustomerOrderModel.changeClaimDisposition = function(isPicklistChange, indexVal, event) {
                if (event != undefined) {
                    if (event.keyCode == 9) {
                        if ($scope.WizardModel.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty > $scope.WizardModel.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty) {
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[indexVal].ApprovedQty = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[indexVal].ClaimedQty;
                            Notification.error($Label.CustomerOrder_Js_Approved_quantity);
                            event.preventDefault();
                        }
                    }
                }
                if (isPicklistChange) {
                    $scope.WizardModel.wizardInfo.ClaimDispositionsList.remove('Accepted w/ Adjustment');
                    for (var i = 0; i < $scope.WizardModel.wizardInfo.NonVarianceLineItemList.length; i++) {
                        $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].IsEdit = false;
                        if ($scope.WizardModel.wizardInfo.ClaimDisposition == 'Accepted') {
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                        } else if ($scope.WizardModel.wizardInfo.ClaimDisposition == 'Denied') {
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = 0;
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = 0;
                        }
                    }
                    $scope.CustomerOrderModel.calculateClaimResponseVariance(null);
                } else if (!isPicklistChange) {
                    if ($scope.WizardModel.wizardInfo.ClaimDisposition == 'Denied') {
                        for (var i = 0; i < $scope.WizardModel.wizardInfo.NonVarianceLineItemList.length; i++) {
                            if (indexVal != i) {
                                $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                                $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                            } else {
                                if ($scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty == 0) {
                                    $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedQty;
                                } else if ($scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice == 0) {
                                    $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedPrice;
                                }
                            }
                        }
                    }
                    if ($scope.WizardModel.wizardInfo.ClaimDisposition != 'Accepted w/ Adjustment') {
                        $scope.CustomerOrderModel.calculateClaimResponseVariance(indexVal);
                    } else {
                        $scope.CustomerOrderModel.calculateClaimResponseVariance(null);
                    }
                    $scope.WizardModel.wizardInfo.ClaimDispositionsList.remove('Accepted w/ Adjustment');
                    $scope.WizardModel.wizardInfo.ClaimDispositionsList.push('Accepted w/ Adjustment');
                    $scope.WizardModel.wizardInfo.ClaimDisposition = 'Accepted w/ Adjustment';
                }
            }
            $scope.CustomerOrderModel.calculateClaimResponseVariance = function(indexVal) {
                if (indexVal == null) {
                    $scope.WizardModel.wizardInfo.ApprovedItems = 0;
                    $scope.WizardModel.wizardInfo.TaxAmount = 0;
                    $scope.WizardModel.wizardInfo.TotalVarianceAmount = 0;
                }
                if ($scope.WizardModel.wizardInfo.NonVarianceLineItemList != null) {
                    for (var i = 0; i < $scope.WizardModel.wizardInfo.NonVarianceLineItemList.length; i++) {
                        if (indexVal == null || indexVal == i) {
                            if (indexVal != null) {
                                $scope.WizardModel.wizardInfo.ApprovedItems -= $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                                $scope.WizardModel.wizardInfo.TaxAmount -= $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].TaxAmount;
                                $scope.WizardModel.wizardInfo.TotalVarianceAmount -= $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].VarianceAmount;
                            }
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty * $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedPrice;
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].VarianceQuantity = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedQty - $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedQty;
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].VarianceAmount = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ClaimedSubtotal - $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                            $scope.WizardModel.wizardInfo.TotalVarianceAmount += $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].VarianceAmount;
                            $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].TaxAmount = $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal * ($scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].Tax / 100);
                            $scope.WizardModel.wizardInfo.ApprovedItems += $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].ApprovedSubTotal;
                            $scope.WizardModel.wizardInfo.TaxAmount += $scope.WizardModel.wizardInfo.NonVarianceLineItemList[i].TaxAmount;
                        }
                    }
                }
                $scope.WizardModel.wizardInfo.Total = $scope.WizardModel.wizardInfo.ApprovedItems + $scope.WizardModel.wizardInfo.TaxAmount - $scope.WizardModel.wizardInfo.DeductibleAmount;
                if ($scope.WizardModel.wizardInfo.TotalVarianceAmount != 0) {
                    $scope.WizardModel.wizardInfo.VarianceHeader = 'Outstanding Variance';
                } else {
                    $scope.WizardModel.wizardInfo.VarianceHeader = 'No Variance';
                }
            }
            $scope.CustomerOrderModel.ResponseDateChanges = function(indexVal) {
                if ($scope.WizardModel.wizardInfo.ResponseDate == null || $scope.WizardModel.wizardInfo.ResponseDate.length == 0) {
                    $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ResponseDate'] = {
                        isError: true,
                        ErrorMessage: "Response Date is required"
                    };
                    $scope.WizardModel.wizardInfo.NextButtonAvail = false;
                    return;
                } else if ($scope.WizardModel.wizardInfo.ProviderClaimNumber == null || $scope.WizardModel.wizardInfo.ProviderClaimNumber.length == 0) {
                    $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ProviderClaimNumber'] = {
                        isError: true,
                        ErrorMessage: "Claim No is required"
                    };
                    $scope.WizardModel.wizardInfo.NextButtonAvail = false;
                    return;
                } else {
                    $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ResponseDate'] = {
                        isError: false,
                        ErrorMessage: ""
                    };
                    $scope.WizardModel.wizardInfo.ClaimResponseValidationModel['ProviderClaimNumber'] = {
                        isError: false,
                        ErrorMessage: ""
                    };
                }
                $scope.WizardModel.wizardInfo.NextButtonAvail = true;
            }
            $scope.CustomerOrderModel.changeVarianceBillTo = function(indexVal) {
                if ($scope.WizardModel.wizardInfo.VarianceLineItemList[i].BillTo == 'Customer') {
                    $scope.WizardModel.wizardInfo.VarianceLineItemList[i].Category = null;
                }
                $scope.CustomerOrderModel.updateFinalizeButtonVisibility();
            }
            $scope.CustomerOrderModel.changeVarianceCategory = function(indexVal) {
                $scope.CustomerOrderModel.updateFinalizeButtonVisibility();
            }
            $scope.CustomerOrderModel.updateFinalizeButtonVisibility = function() {
                if ($scope.WizardModel != null && $scope.WizardModel.wizardInfo != null) {
                    $scope.WizardModel.wizardInfo.FinalizeButtonAvail = true;
                    if ($scope.WizardModel.wizardInfo.VarianceLineItemList != null) {
                        for (var i = 0; i < $scope.WizardModel.wizardInfo.VarianceLineItemList.length; i++) {
                            if ($scope.WizardModel.wizardInfo.VarianceLineItemList[i].BillTo == 'Third_Party') {
                                $scope.WizardModel.wizardInfo.VarianceLineItemList[i].BillTo = 'Internal';
                            }
                            var VarianceLineItem = $scope.WizardModel.wizardInfo.VarianceLineItemList[i];
                            if (VarianceLineItem.BillTo == null || VarianceLineItem.BillTo.length == 0) {
                                $scope.WizardModel.wizardInfo.FinalizeButtonAvail = false;
                                break;
                            }
                            if (VarianceLineItem.BillTo == 'Internal' && (VarianceLineItem.Category == null || VarianceLineItem.Category.length == 0)) {
                                $scope.WizardModel.wizardInfo.FinalizeButtonAvail = false;
                                break;
                            }
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.setDefaultValidationModal = function() {
                $scope.CustomerOrderModel.priceValidationModal = {
                    FactoryOptionPrice: {
                        isError: false,
                        ErrorMessage: '',
                        Type: ''
                    },
                    DealerInstalledOptionPrice: {
                        isError: false,
                        ErrorMessage: '',
                        Type: ''
                    }
                };
            }
            $scope.CustomerOrderModel.resetClaimResponseValidation = function() {
                $scope.WizardModel.wizardInfo.ClaimResponseValidationModel = {
                    ResponseDate: {
                        isError: false,
                        ErrorMessage: ""
                    },
                    ProviderClaimNumber: {
                        isError: false,
                        ErrorMessage: ""
                    }
                };
                $scope.WizardModel.wizardInfo.NextButtonAvail = true;
            }
            $scope.CustomerOrderModel.SaveClaimResponse = function(ServiceOrderHeaderId, claimResponse, currentStepNumber, closeWizard) {
                WizardService.saveClaimResponse(ServiceOrderHeaderId, JSON.stringify(claimResponse), currentStepNumber).then(function(successfulSearchResult) {
                    if ($scope.WizardModel.currentClaimWizardKey == 'Claim_Response') {
                        if (currentStepNumber == 3 || closeWizard) {
                            $scope.WizardModel.closeWizardMode();
                        }
                        $scope.WizardModel.wizardInfo = successfulSearchResult;
                        $scope.WizardModel.wizardInfo.ClaimDispositionsList = ['Accepted', 'Denied'];
                        if ($scope.WizardModel.wizardInfo.ClaimDisposition == 'Accepted w/ Adjustment') {
                            $scope.WizardModel.wizardInfo.ClaimDispositionsList.remove('Accepted w/ Adjustment');
                            $scope.WizardModel.wizardInfo.ClaimDispositionsList.push('Accepted w/ Adjustment');
                        }
                        if ($scope.WizardModel.wizardInfo.InternalCategoryList == null) {
                            $scope.WizardModel.wizardInfo.InternalCategoryList = [];
                        }
                        $scope.WizardModel.wizardInfo.VarianceBillToList = ['Internal', 'Customer'];
                        $scope.CustomerOrderModel.editClaimResponseDetailItemRow(-1);
                        $scope.CustomerOrderModel.calculateClaimResponseVariance(null);
                        $scope.CustomerOrderModel.resetClaimResponseValidation();
                    } else if ($scope.WizardModel.currentClaimWizardKey == 'View_Claim_Response') {}
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.isNextbuttonActive = function() {
                var activeChevronIndex;
                if ($scope.CustomerOrderModel.currentChevronList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.currentChevronList.length; i++) {
                        if ($scope.CustomerOrderModel.currentChevronList[i].isActive) {
                            activeChevronIndex = i;
                        }
                    }
                    if (activeChevronIndex == $scope.CustomerOrderModel.currentChevronList.length - 1) {
                        return false;
                    }
                }
                return true;
            }
            $scope.CustomerOrderModel.showSection = function(sectionUniqueKey) {
                var index = _.findIndex($scope.CustomerOrderModel.currentChevronList, {
                    key: sectionUniqueKey
                });
                if (index > -1 && $scope.CustomerOrderModel.currentChevronList != undefined) {
                    return $scope.CustomerOrderModel.currentChevronList[index].isActive;
                }
                return false;
            }
            $scope.CustomerOrderModel.getDateFromSFformat = function(salesforceDate) {
                if (salesforceDate == null) {
                    return $scope.CustomerOrderModel.getCurrentDate();
                }
                var date = salesforceDate.substring(0, salesforceDate.indexOf(" "));
                return date;
            }
            $scope.CustomerOrderModel.getTimeFromSFformat = function(salesforceDate) {
                if (salesforceDate == null) {
                    return '12:00 AM';
                }
                var time = salesforceDate.substring(salesforceDate.indexOf(" ") + 1, salesforceDate.length);
                return time;
            }
            $scope.WizardModel.setCurrentCOU = function(COUId) {
                if ($scope.CustomerOrderModel.COUList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.COUList.length; i++) {
                        $scope.WizardModel.wizardInfo.Sign_In.Service_Information.selectedCOU = {};
                        if ($scope.CustomerOrderModel.COUList[i].Id == COUId) {
                            $scope.WizardModel.wizardInfo.Sign_In.Service_Information.selectedCOU = $scope.CustomerOrderModel.COUList[i];
                            $scope.WizardModel.wizardInfo.Sign_In.Service_Information.COUId = $scope.CustomerOrderModel.COUList[i].Id;
                            break;
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.showHideFactoryOption = function(event, DealUnitIndex) {
                if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                $scope.CustomerOrderModel.FactoryItems_editRow[DealUnitIndex].isEdit = !$scope.CustomerOrderModel.FactoryItems_editRow[DealUnitIndex].isEdit;
            }
            $scope.CustomerOrderModel.showHideDealerInstalledOption = function(event, DealUnitIndex) {
                if ($scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[DealUnitIndex].isEdit = !$scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow[DealUnitIndex].isEdit;
            }
            $scope.CustomerOrderModel.editTempDeals = function(dealId, dealItemId, index) {
                var dealLineItemId = dealLineItemId == undefined ? null : dealItemId;
                var DealUnit_Json = {
                    dealId: dealId,
                    dealItemId: dealLineItemId,
                    dealSelectedModel: $scope.CustomerOrderModel.DealItemList[index].DealItemObj,
                    index: index
                };
                loadState($state, 'CustomerOrder.DealUnit', {
                    DealUnitParams: DealUnit_Json
                });
            }
            $scope.CustomerOrderModel.getSFformatDate = function(currentDate, currentTime) {
                var dateTime = currentDate + ' ' + currentTime;
                return dateTime;
            }
            $scope.CustomerOrderModel.getCurrentDate = function() {
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth() + 1;
                var yyyy = today.getFullYear();
                if (dd < 10) {
                    dd = '0' + dd
                }
                if (mm < 10) {
                    mm = '0' + mm
                }
                var today = mm + '/' + dd + '/' + yyyy;
                return today;
            }
            $scope.CustomerOrderModel.validatePromisedByDate = function(index) {
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedDate.length < 10) {
                    Notification.error($Label.CustomerOrder_Js_Promised_By_Invalid);
                    return;
                }
                $scope.CustomerOrderModel.SaveserviceInfo(index);
            }
            $scope.WizardModel.toggleIsPromisedByAmPm = function(value) {
                if ($scope.WizardModel.wizardInfo.Sign_In.Service_Information.IsPromisedByAmPm == value) {
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.IsPromisedByAmPm = '';
                } else {
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.IsPromisedByAmPm = value;
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.selectedTime = '12:00 ' + value;
                }
            }
            $scope.WizardModel.changeProviderList = function() {
                for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                    if ($scope.WizardModel.wizardInfo.Sign_In.Service_Information.TransactionTypeId == $scope.CustomerOrderModel.MasterData.TTList[i].Id) {
                        $scope.WizardModel.wizardInfo.Sign_In.Service_Information.TransactionType = $scope.CustomerOrderModel.MasterData.TTList[i].Type;
                    }
                }
                if ($scope.WizardModel.wizardInfo.Sign_In.Service_Information.TransactionType != 'Internal') {
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.CategoryNameStr = '';
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.Category = null;
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information.CategoryName = '';
                }
            }
            $scope.WizardModel.addAndRemoveFromMultiSelect = function(event, index, modelName, ModelKey, fieldLabel) {
                var isAlreadyExist = false;
                var fieldValue = $scope.WizardModel.wizardInfo.Sign_In.Service_Information[modelName];
                if ((event.keyCode == 13 || event.keyCode == 9) && fieldValue != '' && fieldValue != undefined) {
                    for (var i = 0; i < $scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey].length; i++) {
                        if ($scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey][i] == $scope.WizardModel.wizardInfo.Sign_In.Service_Information[modelName]) {
                            isAlreadyExist = true;
                            Notification.error('Same ' + fieldLabel + ' Already Exist');
                        }
                    }
                    if (!isAlreadyExist) {
                        $scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey].push($scope.WizardModel.wizardInfo.Sign_In.Service_Information[modelName]);
                    }
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information[modelName] = '';
                }
                var length = $scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey].length;
                if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
                    $scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey].splice(length - 1, 1);
                }
                $scope.WizardModel.editLineItemsForCauseConcernCorrection();
            }
            $scope.WizardModel.removeFromMultiSelect = function(index, ModelKey) {
                $scope.WizardModel.wizardInfo.Sign_In.Service_Information[ModelKey].splice(index, 1);
            }
            $scope.CustomerOrderModel.addAndRemoveFromNotesMultiSelect = function(event, index, modelName, ModelKey, fieldLabel) {
                var isAlreadyExist = false;
                var fieldValue = $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName];
                if ((event.keyCode == 13 || event.keyCode == 9) && fieldValue != '' && fieldValue != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].length; i++) {
                        if ($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey][i] == $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName]) {
                            isAlreadyExist = true;
                            Notification.error('Same ' + fieldLabel + ' Already Exist');
                        }
                    }
                    if (!isAlreadyExist) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].push($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName]);
                        $scope.CustomerOrderModel.saveServiceReview(index);
                    }
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName] = '';
                }
                var length = $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].length;
                if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].splice(length - 1, 1);
                    $scope.CustomerOrderModel.saveServiceReview(index);
                }
            }
            $scope.CustomerOrderModel.removeNotesFromMultiSelect = function(index, parentIndex, ModelKey) {
                $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOReviewRec[ModelKey].splice(index, 1);
                $scope.CustomerOrderModel.saveServiceReview(parentIndex);
            }
            $scope.CustomerOrderModel.PrintPreviewDetails = function(soHeaderId) {
                $scope.PrintPreviewModel.PrintPreviewInfo = [];
                FileUploadService.PrintPreviewDetails(soHeaderId).then(function(successfulResult) {
                    $scope.PrintPreviewModel.PrintPreviewInfo = successfulResult;
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                })
            }
            $scope.CustomerOrderModel.sidepanelLink = function(event, relatedContent, isWork, isClaim, SectionScroll) {
                event.preventDefault();
                angular.element(document).off("scroll");
                var target = angular.element(angular.element(event.target).closest('a')).attr("href");
                var scrollPositionTop = 0;
                var navBarHeightDiffrenceFixedHeaderOpen = 0;
                if ($rootScope.wrapperHeight == 95) {
                    navBarHeightDiffrenceFixedHeaderOpen = 45;
                } else {
                    navBarHeightDiffrenceFixedHeaderOpen = 15;
                }
                if (!$scope.CustomerOrderModel.displaySections.Customer && target == '#CustomerSection') {
                    scrollPositionTop = angular.element(target).offset().top - 98 - navBarHeightDiffrenceFixedHeaderOpen;
                } else if ($scope.CustomerOrderModel.displaySections.Customer && target == '#CustomerSection') {
                    scrollPositionTop = angular.element(target).offset().top - 110 - navBarHeightDiffrenceFixedHeaderOpen;
                } else if (target == '#UnresolvedFulfillmentSection' || SectionScroll != undefined) {
                    scrollPositionTop = angular.element(target).offset().top - 105 - navBarHeightDiffrenceFixedHeaderOpen;
                } else {
                    scrollPositionTop = angular.element(target).offset().top - 45 - navBarHeightDiffrenceFixedHeaderOpen;
                }
                angular.element('html, body').stop().animate({
                    scrollTop: scrollPositionTop
                }, 500, function() {
                    angular.element(document).on("scroll", function() {
                        $scope.CustomerOrderModel.onScroll();
                    });
                    $scope.CustomerOrderModel.onScroll();
                }).promise().then(function() {
                    if (isWork || isClaim) {
                        $scope.CustomerOrderModel.scrollCallback(target, isWork, isClaim);
                    }
                });
            }
            if ($scope.CustomerOrderModel.IsLoadFinancingSection) {
                $scope.CustomerOrderModel.DealType = [{
                    Value: 'Cash Deal'
                }, {
                    Value: 'Financed'
                }];
            } else {
                $scope.CustomerOrderModel.DealType = [{
                    Value: 'Cash Deal'
                }];
            }
            $scope.CustomerOrderModel.onScroll = function() {
                if ($state.current.name === 'CustomerOrder') {
                    if ($scope.CustomerOrderModel.isWizardMode) {
                        return;
                    }
                    var activeSidepanelink;
                    var heading = '';
                    var scrollPos = angular.element(document).scrollTop();
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;
                    var navBarHeightDiffrenceFixedHeaderClose = 0;
                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 45;
                        navBarHeightDiffrenceFixedHeaderClose = 50;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 50;
                        navBarHeightDiffrenceFixedHeaderClose = 55;
                    }
                    var fixedHeight = 50 - navBarHeightDiffrenceFixedHeaderClose;
                    try {
                        if ($scope.CustomerOrderModel.displaySections.Customer && (isElementDefined('#CustomerSection') && (scrollPos < angular.element('#CustomerSection').position().top + angular.element('#CustomerSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen))) {
                            activeSidepanelink = '#CustomerSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.Customer && (isElementDefined('#CustomerSection') && (scrollPos < angular.element('#CustomerSection').position().top + angular.element('#CustomerSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose))) {
                            activeSidepanelink = '#CustomerSection';
                        } else if ($scope.CustomerOrderModel.displaySections.Deal && (isElementDefined('#DealSection') && (scrollPos < angular.element('#DealSection').position().top + angular.element('#DealSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#DealSection').height() != 0) {
                            activeSidepanelink = '#DealSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.Deal && (isElementDefined('#DealSection') && (scrollPos < angular.element('#DealSection').position().top + angular.element('#DealSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#DealSection').height() != 0) {
                            activeSidepanelink = '#DealSection';
                        } else if (angular.element('#DealFinancingSection').position() != undefined && $scope.CustomerOrderModel.displaySections.Financing && (isElementDefined('#DealFinancingSection') && (scrollPos < angular.element('#DealFinancingSection').position().top + angular.element('#DealFinancingSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#DealFinancingSection').height() != 0) {
                            activeSidepanelink = '#DealFinancingSection';
                        } else if (angular.element('#DealFinancingSection').position() != undefined && !$scope.CustomerOrderModel.displaySections.Financing && (isElementDefined('#DealFinancingSection') && (scrollPos < angular.element('#DealFinancingSection').position().top + angular.element('#DealFinancingSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#DealFinancingSection').height() != 0) {
                            activeSidepanelink = '#DealFinancingSection';
                        } else if ($scope.CustomerOrderModel.displaySections.DealMerchandise && (isElementDefined('#DealMerchandiseSection') && (scrollPos < angular.element('#DealMerchandiseSection').position().top + angular.element('#DealMerchandiseSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#DealMerchandiseSection').height() != 0) {
                            activeSidepanelink = '#DealMerchandiseSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.DealMerchandise && (isElementDefined('#DealMerchandiseSection') && (scrollPos < angular.element('#DealMerchandiseSection').position().top + angular.element('#DealMerchandiseSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#DealMerchandiseSection').height() != 0) {
                            activeSidepanelink = '#DealMerchandiseSection';
                        } else if (($scope.CustomerOrderModel.serviceOrderList.length > 0) && (isElementDefined($scope.CustomerOrderModel.serviceOrderList[$scope.CustomerOrderModel.serviceOrderList.length - 1].SectionID) && (scrollPos < angular.element($scope.CustomerOrderModel.serviceOrderList[$scope.CustomerOrderModel.serviceOrderList.length - 1].SectionID).position().top + angular.element($scope.CustomerOrderModel.serviceOrderList[$scope.CustomerOrderModel.serviceOrderList.length - 1].SectionID).height() + fixedHeight))) {
                            for (i = 0; i < $scope.CustomerOrderModel.serviceOrderList.length; i++) {
                                var sectionId = $scope.CustomerOrderModel.serviceOrderList[i].SectionID;
                                if ($scope.CustomerOrderModel.displaySections.ServiceOrder[i].display && (isElementDefined(sectionId) && (scrollPos < angular.element(sectionId).position().top + angular.element(sectionId).height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element(sectionId).height() != 0) {
                                    activeSidepanelink = sectionId;
                                    break;
                                } else if (!$scope.CustomerOrderModel.displaySections.ServiceOrder[i].display && (isElementDefined(sectionId) && (scrollPos < angular.element(sectionId).position().top + angular.element(sectionId).height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element(sectionId).height() != 0) {
                                    activeSidepanelink = sectionId;
                                    break;
                                }
                            }
                        } else if ($scope.CustomerOrderModel.hideMerchandiseSection == false && $scope.CustomerOrderModel.displaySections.Merchandise && (isElementDefined('#MerchandiseSection') && (scrollPos < angular.element('#MerchandiseSection').position().top + angular.element('#MerchandiseSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#MerchandiseSection').height() != 0) {
                            activeSidepanelink = '#MerchandiseSection';
                        } else if ($scope.CustomerOrderModel.hideMerchandiseSection == false && !$scope.CustomerOrderModel.displaySections.Merchandise && (isElementDefined('#MerchandiseSection') && (scrollPos < angular.element('#MerchandiseSection').position().top + angular.element('#MerchandiseSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#MerchandiseSection').height() != 0) {
                            activeSidepanelink = '#MerchandiseSection';
                        } else if ($scope.CustomerOrderModel.displaySections.SpecialOrder && (isElementDefined('#SpecialOrderSection') && (scrollPos < angular.element('#SpecialOrderSection').position().top + angular.element('#SpecialOrderSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#SpecialOrderSection').height() != 0) {
                            activeSidepanelink = '#SpecialOrderSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.SpecialOrder && (isElementDefined('#SpecialOrderSection') && (scrollPos < angular.element('#SpecialOrderSection').position().top + angular.element('#SpecialOrderSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#SpecialOrderSection').height() != 0) {
                            activeSidepanelink = '#SpecialOrderSection';
                        } else if ($scope.CustomerOrderModel.displaySections.Deposit && (isElementDefined('#DepositSection') && (scrollPos < angular.element('#DepositSection').position().top + angular.element('#DepositSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#DepositSection').height() != 0) {
                            activeSidepanelink = '#DepositSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.Deposit && (isElementDefined('#DepositSection') && (scrollPos < angular.element('#DepositSection').position().top + angular.element('#DepositSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#DepositSection').height() != 0) {
                            activeSidepanelink = '#DepositSection';
                        } else if ($scope.CustomerOrderModel.displaySections.Checkout && (isElementDefined('#CheckoutSection') && (scrollPos < angular.element('#CheckoutSection').position().top + angular.element('#CheckoutSection').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#CheckoutSection').height() != 0) {
                            activeSidepanelink = '#CheckoutSection';
                        } else if (!$scope.CustomerOrderModel.displaySections.Checkout && (isElementDefined('#CheckoutSection') && (scrollPos < angular.element('#CheckoutSection').position().top + angular.element('#CheckoutSection').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#CheckoutSection').height() != 0) {
                            activeSidepanelink = '#CheckoutSection';
                        } else if ($scope.CustomerOrderModel.displaySections.InvoiceHistory && (isElementDefined('#InvoiceHistory') && (scrollPos < angular.element('#InvoiceHistory').position().top + angular.element('#InvoiceHistory').height() + 90 - navBarHeightDiffrenceFixedHeaderOpen)) && angular.element('#InvoiceHistory').height() != 0) {
                            activeSidepanelink = '#InvoiceHistory';
                        } else if (!$scope.CustomerOrderModel.displaySections.InvoiceHistory && (isElementDefined('#InvoiceHistory') && (scrollPos < angular.element('#InvoiceHistory').position().top + angular.element('#InvoiceHistory').height() + 50 - navBarHeightDiffrenceFixedHeaderClose)) && angular.element('#InvoiceHistory').height() != 0) {
                            activeSidepanelink = '#InvoiceHistory';
                        }
                    } catch (e) {
                        console.log(e); //TODO
                    }
                    $scope.CustomerOrderModel.activeSidepanelink = activeSidepanelink;
                    if (activeSidepanelink) {
                        $scope.CustomerOrderModel.UpdateSelectedSectionItems(activeSidepanelink.replace('#', ''));
                    }
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }
            $scope.CustomerOrderModel.scrollCallback = function(target, isWork, isClaim) {
                var currentIndex = parseInt(target.replace('#ServiceInfoSection', ''));
                var targetId = isWork ? "SoHeaderWorkDropdown" + currentIndex : isClaim ? "SoHeaderClaimDropdown" + currentIndex : null;
                var targetClaimId = "SoHeaderWorkDropdown" + currentIndex;
                if (targetId != null) {
                    angular.element('#' + targetId).addClass("open");
                }
            }
            $scope.CustomerOrderModel.openRemoveTradeInFromDealModal = function(status, index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                $scope.CustomerOrderModel.currentRemoveIndexForTradeIn = index;
                if (status == false) {
                    angular.element('#removeTradeInFromDealConfirm').modal('hide');
                } else if (status == true) {
                    angular.element('#removeTradeInFromDealConfirm').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                    angular.element('#removeTradeInFromDealConfirm').show();
                }
            }
            $scope.CustomerOrderModel.showDepositeSection = function() {
                var flagDepositeSection;
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId == null) {
                        flagDepositeSection = true;
                        break;
                    } else {
                        flagDepositeSection = false;
                    }
                }
                return flagDepositeSection;
            }
            $scope.CustomerOrderModel.removeTradeInFromDeal = function(dealId, tradeInId, UnitNumber) {
                var dealTradeInListLength = $scope.CustomerOrderModel.DealTradeInList.length;
                if (tradeInId == null) {
                    $scope.CustomerOrderModel.DealTradeInList.splice($scope.CustomerOrderModel.currentRemoveIndexForTradeIn, 1);
                    angular.element('#removeTradeInFromDealConfirm').modal('hide');
                    return;
                }
                DealService.removeUnitFromDeal(dealId, tradeInId).then(function(successfulResult) {
                    $scope.CustomerOrderModel.DealInfo = successfulResult.DealInfo;
                    $scope.CustomerOrderModel.DealTradeInList = successfulResult.TradeInsList;
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulResult);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.openRemoveTradeInFromDealModal(false);
                }, function(errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                })
            }
            $scope.CustomerOrderModel.removeDeal = function(dealId) {
                DealService.removeDeal($scope.CustomerOrderModel.DealInfo.Id).then(function(successfulSearchResult) {
                    if (successfulSearchResult.responseStatus == 'success') {
                        Notification.success(successfulSearchResult.response);
                        $scope.CustomerOrderModel.DealInfo = null;
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    } else if (successfulSearchResult.responseStatus == 'error') {
                        Notification.error(successfulSearchResult.response);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error(errorSearchResult);
                });
            }
            $scope.CustomerOrderModel.openRemoveUnitFromDealModal = function(status, index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                $scope.CustomerOrderModel.currentRemoveIndex = index;
                if (status == false) {
                    angular.element('#removeUnitFromDealConfirm').modal('hide');
                } else if (status == true) {
                    angular.element('#removeUnitFromDealConfirm').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                    angular.element('#removeUnitFromDealConfirm').show();
                }
            }
            $scope.CustomerOrderModel.removeUnitFromDeal = function(dealId, dealItemId, UnitNumber) {
                var dealItemListLength = $scope.CustomerOrderModel.DealItemList.length;
                // if only 1 temporary unit, don't remove it
                if (dealItemListLength == 1 && UnitNumber == null) {
                    angular.element('#removeUnitFromDealConfirm').modal('hide');
                    return;
                }
                DealService.removeUnitFromDeal(dealId, dealItemId).then(function(successfulResult) {
                    $scope.CustomerOrderModel.DealInfo = successfulResult.DealInfo;
                    $scope.CustomerOrderModel.DealSummaryObj = successfulResult.DealSummaryObj;
                    // if if one dela item , of stock type, replace it with empty teporary unit card
                    if (dealItemListLength == 1 && UnitNumber != null) {
                        $scope.CustomerOrderModel.DealItemObjJson = {
                            Deal: null,
                            ExteriorColour: null,
                            Id: null,
                            MakeModelDescription: null,
                            MakeName: null,
                            ModelName: null,
                            SubModelName: null,
                            Year: null
                        }
                        $scope.CustomerOrderModel.FactoryOptionList = {
                            TotalPrice: 0
                        }
                        $scope.CustomerOrderModel.DealerInstalledOptionList = {
                            TotalPrice: 0
                        }
                        $scope.CustomerOrderModel.BasePrice = {
                            TotalPrice: 0
                        }
                        $scope.CustomerOrderModel.DealItemList = [];
                        DealService.saveTemporaryUnit($scope.CustomerOrderModel.DealInfo.Id, angular.toJson($scope.CustomerOrderModel.DealItemObjJson)).then(function(relatedCOUList) {
                            $scope.CustomerOrderModel.DealItemList = relatedCOUList.UnitList;
                            $scope.CustomerOrderModel.DealInfo = relatedCOUList.DealInfo;
                            $scope.CustomerOrderModel.editForBaseUnitPrice();
                            $scope.CustomerOrderModel.editForStampDuty();
                            $scope.CustomerOrderModel.editLineItemsForFactoryOptions();
                            $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions();
                            $scope.CustomerOrderModel.calculateFactoryTotal();
                            $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                            $scope.CustomerOrderModel.editLineItemsForOptionFees();
                            var newId = 'DealUnitSection' + ($scope.CustomerOrderModel.DealItemList.length - 1);
                            $timeout(function() {
                                $scope.CustomerOrderModel.scrollToPanel(null, newId);
                            }, 500);
                            Notification.success($Label.Generic_Saved);
                        }, function(errorSearchResult) {
                            Notification.error($Label.Generic_Error);
                        });
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    } else {
                        $scope.CustomerOrderModel.DealItemList = successfulResult.UnitList;
                        for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList = successfulResult.UnitList[i].FactoryOptionList;
                        }
                    }
                    $scope.CustomerOrderModel.calculateFactoryTotal();
                    $scope.CustomerOrderModel.openRemoveUnitFromDealModal(false);
                })
            }
            $scope.CustomerOrderModel.UpdateDealSection = function(index) {
                if (!$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.DealItemList.length > 0) {
                    if ($scope.CustomerOrderModel.DealItemList[0].DealItemObj != undefined) {
                        if ($scope.CustomerOrderModel.DealItemList[0].DealItemObj.OptionAndFeeStatus != null && $scope.CustomerOrderModel.DealItemList[0].DealItemObj.OptionAndFeeStatus == 'Committed') {
                            Notification.error($Label.CustomerOrder_Js_After_commit_and_install);
                            return;
                        }
                    }
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                $scope.CustomerOrderModel.DealItemObjJson = {
                    Deal: null,
                    ExteriorColour: null,
                    Id: null,
                    MakeModelDescription: null,
                    MakeName: null,
                    ModelName: null,
                    SubModelName: null,
                    Year: null
                }
                if ($scope.CustomerOrderModel.DealItemList == undefined) {
                    $scope.CustomerOrderModel.DealItemList = [];
                }
                DealService.saveTemporaryUnit($scope.CustomerOrderModel.DealInfo.Id, angular.toJson($scope.CustomerOrderModel.DealItemObjJson)).then(function(relatedCOUList) {
                    $scope.CustomerOrderModel.DealItemList = relatedCOUList.UnitList;
                    $scope.CustomerOrderModel.DealInfo = relatedCOUList.DealInfo;
                    $scope.CustomerOrderModel.editForBaseUnitPrice();
                    $scope.CustomerOrderModel.editForStampDuty();
                    $scope.CustomerOrderModel.editLineItemsForFactoryOptions();
                    $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions();
                    $scope.CustomerOrderModel.calculateFactoryTotal();
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.editLineItemsForOptionFees();
                    var newId = 'DealUnitSection' + ($scope.CustomerOrderModel.DealItemList.length - 1);
                    $timeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, newId);
                    }, 500);
                }, function(errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
            }
            $scope.CustomerOrderModel.createDealMerchAndServiceSetion = function() {
                for (var i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    if ($scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitId == null) {
                        Notification.error($Label.CustomerOrder_Js_convert_Temporary_Unit_to_Stock);
                        return;
                    }
                }
                CustomerInfoService.createDealMerchAndServiceSetion($scope.CustomerOrderModel.DealInfo.Id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealInfo = successfulSearchResult.DealInfo;
                    $scope.CustomerOrderModel.UpdateDealCheckout = true;
                    $scope.CustomerOrderModel.LoadServiceOrder();
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.UpdateTradeInSection = function(index) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.DealInfo.DealStatus != 'Quotation') {
                    Notification.error($Label.Add_TradeIn_After_commit_and_install);
                    return;
                }
                if ($scope.CustomerOrderModel.DealTradeInList == undefined) {
                    $scope.CustomerOrderModel.DealTradeInList = [];
                }
                $scope.CustomerOrderModel.DealTradeInObjJson = {
                    AgreedValue: 0,
                    AppraisalMethod: null,
                    AppraisalNotes: null,
                    AppraisalStatus: 'Pending Appraisal',
                    ApprovedBy: null,
                    Id: null,
                    Type: null,
                    UnitId: null,
                    SectionID: '#DealTradeInSection' + $scope.CustomerOrderModel.DealTradeInList.length + 1,
                    Name: 'Trade' + $scope.CustomerOrderModel.DealTradeInList.length + 1
                }
                if ($scope.CustomerOrderModel.DealItemList == undefined) {
                    $scope.CustomerOrderModel.DealItemList = [];
                }
                $scope.CustomerOrderModel.DealTradeInList.push($scope.CustomerOrderModel.DealTradeInObjJson);
                var TradeInIndex = 0;
                setTimeout(function() {
                    var sectionName = 'DealTradeInSection' + ($scope.CustomerOrderModel.DealTradeInList.length - 1);
                    $scope.CustomerOrderModel.scrollToPanel(null, sectionName);
                    if ($scope.CustomerOrderModel.COUList.length == 1) {
                        $scope.CustomerOrderModel.setTradeInCurrentCOU($scope.CustomerOrderModel.COUList[0].Id, $scope.CustomerOrderModel.DealTradeInList.length - 1);
                    }
                }, 1000);
                $scope.CustomerOrderModel.UserSelected[$scope.CustomerOrderModel.DealTradeInList.length - 1] = $scope.CustomerOrderModel.UserList[0];
            }
            $scope.CustomerOrderModel.UpdateSelectedSection = function(event, index) {
                event.preventDefault();
                if ($scope.CustomerOrderModel.SectionList[index].item == 'Deposit') {
                    if (!$rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                        $scope.CustomerOrderModel.displaySections.Deposit = false;
                        $scope.CustomerOrderModel.collapseDepositSection = true;
                    } else {
                        $scope.CustomerOrderModel.displaySections.Deposit = true;
                        $scope.CustomerOrderModel.collapseDepositSection = false;
                    }
                } else if ($scope.CustomerOrderModel.SectionList[index].item == 'Checkout' || $scope.CustomerOrderModel.SectionList[index].item == 'CheckOut') {
                    $scope.CustomerOrderModel.checkoutRightArrowClick();
                }
                if ($scope.CustomerOrderModel.SectionList[index].item.indexOf('+ Add New Deal') != -1) {
                    if (!($rootScope.GroupOnlyPermissions['Deal']['create/modify'])) {
                        Notification.error("You don't have permission to create Deal");
                        return;
                    }
                    if (($scope.CustomerOrderModel.DealInfo == null || $scope.CustomerOrderModel.DealInfo == undefined) && $scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Unit Deal') {
                        $scope.CustomerOrderModel.createDeal();
                        setTimeout(function() {
                            $scope.CustomerOrderModel.scrollToPanel(null, 'DealSection');
                            $scope.CustomerOrderModel.isPageLoadFirstTime = true;
                        }, 1000);
                    }
                }
                if ($scope.CustomerOrderModel.SectionList[index].item == '+ Add New Service Job' || $scope.CustomerOrderModel.SectionList[index].item == '+ADD New Job To Order') {
                    if ((!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                        Notification.error("You don't have permission to create Service Job");
                        return;
                    }
                    if ($scope.CustomerOrderModel.Customer.Value == null) {
                        Notification.error($Label.CustomerOrder_Js_add_Customer_before_creating_Service);
                        return;
                    }
                    if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                        Notification.error($Label.CustomerOrder_Js_Can_t_create_Service);
                        return;
                    }
                    $scope.CustomerOrderModel.createSOHeader();
                } else {
                    $scope.CustomerOrderModel.SelectedSection = $scope.CustomerOrderModel.SectionList[index];
                    $scope.CustomerOrderModel.scrollToPanel(event, $scope.CustomerOrderModel.SelectedSection.relatedSection);
                }
            }
            $scope.CustomerOrderModel.createSOHeader = function(kitHeaderIndex, kitLineItemIndex, Idfrom, Id, callBackFunc) {
                console.log('Me clicked');
                CustomerInfoService.createSOHeader($scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    var CurrentSectionResult = successfulSearchResult.SOList
                    $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                    var lastitemIndex = CurrentSectionResult.length - 1;
                    var AddedItem = CurrentSectionResult[lastitemIndex]
                    var ServiceOrderNo = $scope.CustomerOrderModel.serviceOrderList.length;
                    for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                        if ($scope.CustomerOrderModel.MasterData.TTList[i].Type == 'Customer' && $scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Quote') {
                            AddedItem.SOHeaderInfo.TransactionTypeId = $scope.CustomerOrderModel.MasterData.TTList[i].Id;
                            AddedItem.SOHeaderInfo.TransactionType = $scope.CustomerOrderModel.MasterData.TTList[i].Type;
                            AddedItem.SOHeaderInfo.TransactionTypeLabel = $scope.CustomerOrderModel.MasterData.TTList[i].CodeLabel;
                        }
                    }
                    $scope.CustomerOrderModel.SOHeaderList.push(AddedItem);
                    $scope.CustomerOrderModel.serviceOrderList.push({
                        'SectionID': '#ServiceOrderSection' + ServiceOrderNo,
                        'Name': AddedItem.SOHeaderInfo.Name,
                        'Id': AddedItem.SOHeaderInfo.Id
                    })
                    if (!$rootScope.GroupOnlyPermissions['Service job']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) {
                        $scope.CustomerOrderModel.displaySections.ServiceOrder.push({
                            'display': false
                        });
                    } else if (!$rootScope.GroupOnlyPermissions['Internal Service']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service')) {
                        $scope.CustomerOrderModel.displaySections.ServiceOrder.push({
                            'display': false
                        });
                    } else {
                        $scope.CustomerOrderModel.displaySections.ServiceOrder.push({
                            'display': true
                        });
                    }
                    $scope.CustomerOrderModel.setServiceOrderData();
                    $scope.CustomerOrderModel.resetServiceOrderData();
                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    var ServiceOrderIndex = 0;
                    var firstServiceIndex = 0;
                    setTimeout(function() {
                        for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                            $scope.CustomerOrderModel.SOHeaderList[i].hideStatusPicklistValue = false;
                        }
                        for (var j = 0; j < $scope.CustomerOrderModel.SectionList.length; j++) {
                            if ($scope.CustomerOrderModel.SectionList[j].relatedSection == 'ServiceOrderSection0') {
                                firstServiceIndex = j;
                            }
                            if ($scope.CustomerOrderModel.SectionList[j].relatedSection == 'ServiceOrderSection' + ($scope.CustomerOrderModel.serviceOrderList.length - 1)) {
                                $scope.CustomerOrderModel.SelectedSection = $scope.CustomerOrderModel.SectionList[j];
                                ServiceOrderIndex = j;
                            }
                        }
                        $scope.CustomerOrderModel.scrollToPanel(event, $scope.CustomerOrderModel.SelectedSection.relatedSection);
                        if ($scope.CustomerOrderModel.COUList.length == 1) {
                            var COUId = $scope.CustomerOrderModel.COUList[0].Id;
                            $scope.CustomerOrderModel.setCurrentCOU(COUId, ServiceOrderIndex - firstServiceIndex);
                        }
                    }, 1000);
                    $scope.CustomerOrderModel.createGridEditItem(null);
                    if (kitHeaderIndex != undefined && kitLineItemIndex != undefined && Idfrom != undefined && Id != undefined && callBackFunc != undefined) {
                        callBackFunc(kitHeaderIndex, kitLineItemIndex, Idfrom, Id);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.UpdateSelectedSectionItems = function(sectionName) {
                if ($scope.CustomerOrderModel.SelectedSection == sectionName) return;
                for (i = 0; i < $scope.CustomerOrderModel.SectionList.length; i++) {
                    if ($scope.CustomerOrderModel.SectionList[i].relatedSection == sectionName) {
                        return $scope.CustomerOrderModel.SelectedSection = $scope.CustomerOrderModel.SectionList[i];
                    }
                }
            }
            $scope.CustomerOrderModel.calculateDealSummaryOverlay = function(event) {
                var units = $scope.CustomerOrderModel.DealSummaryObj.UnitsTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.UnitsTotal : 0;
                var tradeIns = $scope.CustomerOrderModel.DealSummaryObj.TradeInsTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.TradeInsTotal : 0;
                var partsAndLabour = $scope.CustomerOrderModel.DealSummaryObj.PartsAndLabourTotals != null ? $scope.CustomerOrderModel.DealSummaryObj.PartsAndLabourTotals : 0;
                var otherProducts = $scope.CustomerOrderModel.DealSummaryObj.OtherProductsTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.OtherProductsTotal : 0;
                var fees = $scope.CustomerOrderModel.DealSummaryObj.FeesTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.FeesTotal : 0;
                var stampDuty = $scope.CustomerOrderModel.DealSummaryObj.StampDutyTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.StampDutyTotal : 0;
                var subTotal = $scope.CustomerOrderModel.DealSummaryObj.SubTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.SubTotal : 0;
                var salesTaxes = $scope.CustomerOrderModel.DealSummaryObj.SalesTaxesTotal != null ? $scope.CustomerOrderModel.DealSummaryObj.SalesTaxesTotal : 0;
                var total = $scope.CustomerOrderModel.DealSummaryObj.Total != null ? $scope.CustomerOrderModel.DealSummaryObj.Total : 0;
                var fieldsJSON = [];
                if (units != 0) {
                    fieldsJSON.push({
                        label: 'Units',
                        value: units.toFixed(2)
                    });
                }
                if (tradeIns != 0) {
                    fieldsJSON.push({
                        label: 'Trade-Ins',
                        value: tradeIns.toFixed(2)
                    });
                }
                if (partsAndLabour != 0) {
                    fieldsJSON.push({
                        label: 'Parts & Labor',
                        value: partsAndLabour.toFixed(2)
                    });
                }
                if (otherProducts != 0) {
                    fieldsJSON.push({
                        label: 'Other Products',
                        value: otherProducts.toFixed(2)
                    });
                }
                if (fees != 0) {
                    fieldsJSON.push({
                        label: 'Fees',
                        value: fees.toFixed(2)
                    });
                }
                if ($scope.CompanyLocale == 'Australia' && stampDuty != 0) {
                    fieldsJSON.push({
                        label: 'Stamp Duty',
                        value: stampDuty.toFixed(2)
                    });
                }
                if (subTotal != 0) {
                    fieldsJSON.push({
                        label: 'TOTAL',
                        value: subTotal.toFixed(2)
                    });
                }
                $scope.CustomerOrderModel.showPriceInfoOverlay(event, fieldsJSON);
            }
            $scope.DeliverydateOptions = {
                minDate: new Date,
                dateFormat: $scope.CustomerOrderModel.dateFormat
            };
            $scope.CustomerOrderModel.LoadDealData = function() {
                $scope.CustomerOrderModel.dealStockIdValueJson = [];
                $scope.CustomerOrderModel.dealStockIdValue = [];
                DealService.getDealData($scope.CustomerOrderModel.coHeaderDetails.COHeaderId, null).then(function(successfulResult) {
                    if (successfulResult != null && successfulResult != undefined && Object.keys(successfulResult).length > 0) {
                        $scope.CustomerOrderModel.DealInfo = successfulResult.DealInfo;
                        $scope.CustomerOrderModel.DealItemList = successfulResult.UnitList;
                        $scope.CustomerOrderModel.DealTradeInList = successfulResult.TradeInsList;
                        $scope.CustomerOrderModel.DealMerchandiseList = successfulResult.DealFulfillmentSectionObj.DealMerchandiseList;
                        $scope.CustomerOrderModel.SpecialOrder = successfulResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                        $scope.CustomerOrderModel.DealMerchandiseTotal = successfulResult.DealFulfillmentSectionObj.MerchandiseTotal;
                        $scope.CustomerOrderModel.DealDepositList = successfulResult.DealDepositList;
                        $scope.UpdateDealDepositsList(successfulResult.DealDepositList);
                        $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulResult.DealUnresolvedFulfillmentList;
                        if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                            $scope.CustomerOrderModel.StockUnitMap();
                        }
                        $scope.CustomerOrderModel.DealFinanceList = successfulResult.DealFinanceObj;
                        $scope.CustomerOrderModel.getListOfFinanceCompany();
                        $scope.CustomerOrderModel.editFIProduct();
                        $scope.CustomerOrderModel.UserSelected = [];
                        $scope.CustomerOrderModel.UserList = [];
                        $scope.CustomerOrderModel.DealUserList = successfulResult.UserList;
                        $scope.CustomerOrderModel.UserList = successfulResult.UserList;
                        var DefaultApproval = {
                            name: "Pending Approval",
                            isNew: false,
                            id: null,
                            email: "durga.singh@metacube.com"
                        };
                        $scope.CustomerOrderModel.UserList.splice(0, 0, DefaultApproval);
                        for (i = 0; i < $scope.CustomerOrderModel.DealTradeInList.length; i++) {
                            if ($scope.CustomerOrderModel.DealTradeInList[i].ApprovedBy == null) {
                                $scope.CustomerOrderModel.UserSelected[i] = DefaultApproval;
                            } else {
                                for (j = 0; j < successfulResult.UserList.length; j++) {
                                    if ($scope.CustomerOrderModel.DealTradeInList[i].ApprovedBy == successfulResult.UserList[j].id) {
                                        $scope.CustomerOrderModel.UserSelected[i] = successfulResult.UserList[j];
                                    }
                                }
                            }
                        }
                        $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                        $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                        $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                        for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList = successfulResult.UnitList[i].FactoryOptionList;
                        }
                        for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].OptionAndFeeList = successfulResult.UnitList[i].OptionAndFeeList;
                        }
                        $scope.CustomerOrderModel.DealSummaryObj = successfulResult.DealSummaryObj;
                        $scope.CustomerOrderModel.DealInfo.DealType = successfulResult.DealInfo.DealType;
                        $scope.CustomerOrderModel.DealInfoLoadData.AvailableOptions = ["Commit Units to Deal", "Commit & Install Options", "Add Additional Unit", "Add a Trade-In", "Remove Deal", "Set as a Quote", "Activate Quote", "Delete Quote", "Send Text to Customer"];
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                        $scope.CustomerOrderModel.editLineItemsForFactoryOptions();
                        $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions();
                        $scope.CustomerOrderModel.editForBaseUnitPrice();
                        $scope.CustomerOrderModel.editForStampDuty();
                        $scope.CustomerOrderModel.editLineItemsForOptionFees();
                        $scope.CustomerOrderModel.calculateFactoryTotal();
                        $scope.CustomerOrderModel.calculateEstimatedPayment();
                        if ($scope.CustomerOrderModel.DealItemList.length == 0) {
                            $scope.CustomerOrderModel.UpdateDealSection(0);
                        }
                        $scope.CustomerOrderModel.setDefaultValidationModal();
                        $scope.CustomerOrderModel.collapseDeposit();
                        $scope.CustomerOrderModel.updateDealSummaryTotals(successfulResult);
                        $scope.CustomerOrderModel.allowCheckoutSort = true;
                        $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                        if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Unit Deal') {
                            setTimeout(function() {
                                if (!$scope.CustomerOrderModel.isPageLoadFirstTime) {
                                    $scope.CustomerOrderModel.scrollToPanel(null, 'DealSection');
                                    $scope.CustomerOrderModel.isPageLoadFirstTime = true;
                                } else {
                                    $scope.CustomerOrderModel.scrollToPanel(null, 'DealSection');
                                }
                            }, 1000);
                        }
                    }
                })
            }
            $scope.CustomerOrderModel.optionAndFeeStatus = function() {
                for (var i = 0; i < $scope.CustomerOrderModel.DealItemList; i++) {
                    if ($scope.CustomerOrderModel.DealItemList[i].OptionAndFeeList.length > 0 && $scope.CustomerOrderModel.DealItemList[i].OptionAndFeeList.Status != 'Commited') {
                        return false;
                    } else {
                        return true;
                    }
                }
            }
            $scope.CustomerOrderModel.editLineItemsForFactoryOptions = function() {
                $scope.CustomerOrderModel.FactoryItems_editRow = [];
                var UnitItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    UnitItems.push({
                        isEdit: false,
                        factoryOrderLineItems: []
                    });
                    if ($scope.CustomerOrderModel.DealItemList[i] != undefined && $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList != undefined) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList.length; j++) {
                            UnitItems[i].factoryOrderLineItems.push({
                                isEdit: false
                            });
                        }
                    }
                }
                $scope.CustomerOrderModel.FactoryItems_editRow = UnitItems;
            }
            $scope.CustomerOrderModel.calculateFactoryTotal = function() {
                $scope.CustomerOrderModel.factoryTotal = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    $scope.CustomerOrderModel.factoryTotal[i] = 0;
                    if ($scope.CustomerOrderModel.DealItemList[i] != undefined && $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList != undefined) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList.length; j++) {
                            $scope.CustomerOrderModel.factoryTotal[i] += $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList[j].TotalPrice;
                        }
                    }
                }
                $scope.CustomerOrderModel.dealerInstalledOptionsTotal = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    $scope.CustomerOrderModel.dealerInstalledOptionsTotal[i] = 0;
                    if ($scope.CustomerOrderModel.DealItemList[i] != undefined && $scope.CustomerOrderModel.DealItemList[i].DealerInstalledOptionList != undefined) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealItemList[i].DealerInstalledOptionList.length; j++) {
                            $scope.CustomerOrderModel.dealerInstalledOptionsTotal[i] += $scope.CustomerOrderModel.DealItemList[i].DealerInstalledOptionList[j].TotalPrice;
                        }
                    }
                }
                $scope.CustomerOrderModel.updateDealSummaryTotals();
            }
            $scope.CustomerOrderModel.editBaseUnitPriceItem = function($event, DealUnitIndex) {
                if ($scope.CustomerOrderModel.isLockIconEnableOnUnitSection(DealUnitIndex) || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                    return;
                }
                if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].TotalBasePrice != null) {
                    $scope.CustomerOrderModel.BaseUnitPrice_editRow[DealUnitIndex].isEdit = !$scope.CustomerOrderModel.BaseUnitPrice_editRow[DealUnitIndex].isEdit;
                }
            }
            $scope.CustomerOrderModel.isLockIconEnableOnUnitSection = function(dealUnitIndex) {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || ($scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced') || ($scope.CustomerOrderModel.DealItemList[dealUnitIndex].IsRideawayPricingEnabled && $scope.CompanyLocale == 'Australia')) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.isOrderInvoicedOrClosed = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' || ($scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.DealStatus == 'Invoiced')) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.toggleRideawayPriceItem = function(event, DealUnitIndex) {
                if ($scope.CustomerOrderModel.isOrderInvoicedOrClosed()) {
                    return;
                }
                $scope.CustomerOrderModel.DealItemList[DealUnitIndex].IsRideawayPricingEnabled = !$scope.CustomerOrderModel.DealItemList[DealUnitIndex].IsRideawayPricingEnabled;
                if ($scope.CustomerOrderModel.DealItemList[DealUnitIndex].IsRideawayPricingEnabled == true) {
                    $scope.CustomerOrderModel.StampDuty_editRow[DealUnitIndex].isEdit = false;
                    $scope.CustomerOrderModel.BaseUnitPrice_editRow[DealUnitIndex].isEdit = false;
                }
                var totalRideaweyPrice = 0;
                var dealItemDetail = $scope.CustomerOrderModel.DealItemList[DealUnitIndex];
                if (dealItemDetail.TotalBasePrice != undefined && dealItemDetail.TotalBasePrice != null && dealItemDetail.TotalBasePrice != '') {
                    totalRideaweyPrice += parseFloat(dealItemDetail.TotalBasePrice);
                }
                if (dealItemDetail.TotalFactoryOption != undefined && dealItemDetail.TotalFactoryOption != null && dealItemDetail.TotalFactoryOption != '') {
                    totalRideaweyPrice += parseFloat(dealItemDetail.TotalFactoryOption);
                }
                if (dealItemDetail.TotalDealerInstalledOption != undefined && dealItemDetail.TotalDealerInstalledOption != null && dealItemDetail.TotalDealerInstalledOption != '') {
                    totalRideaweyPrice += parseFloat(dealItemDetail.TotalDealerInstalledOption);
                }
                if (dealItemDetail.TotalPartAndLabor != undefined && dealItemDetail.TotalPartAndLabor != null && dealItemDetail.TotalPartAndLabor != '') {
                    totalRideaweyPrice += parseFloat(dealItemDetail.TotalPartAndLabor);
                }
                if (dealItemDetail.TotalStampDuty != undefined && dealItemDetail.TotalStampDuty != null && dealItemDetail.TotalStampDuty != '') {
                    totalRideaweyPrice += parseFloat(dealItemDetail.TotalStampDuty);
                }
                $scope.CustomerOrderModel.DealItemList[DealUnitIndex].TotalEnforceRideawayPrice = totalRideaweyPrice;
                var dealItemId = $scope.CustomerOrderModel.DealItemList[DealUnitIndex].DealItemObj.Id;
                var IsRideawayPricingEnabled = $scope.CustomerOrderModel.DealItemList[DealUnitIndex].IsRideawayPricingEnabled;
                DealService.toggleRideawayPricingEnabled(dealItemId, totalRideaweyPrice, IsRideawayPricingEnabled).then(function(successResult) {
                    $scope.CustomerOrderModel.DealItemList[DealUnitIndex].TotalEnforceRideawayPrice = successResult.TotalEnforceRideawayPrice;
                }, function(errorResult) {
                    Notification.error(errorResult + ' ' + $Label.Generic_Error);
                });
            }
            $scope.CustomerOrderModel.saveEnforceRideawayPrice = function(dealUnitIndex) {
                if ($scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice == undefined || $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice == null || $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice == '') {
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice = 0;
                }
                var dealItemDetail = $scope.CustomerOrderModel.DealItemList[dealUnitIndex];
                var minRideawayPrice = 0;
                if (dealItemDetail.TotalFactoryOption != undefined && dealItemDetail.TotalFactoryOption != null && dealItemDetail.TotalFactoryOption != '') {
                    minRideawayPrice += parseFloat(dealItemDetail.TotalFactoryOption);
                }
                if (dealItemDetail.TotalDealerInstalledOption != undefined && dealItemDetail.TotalDealerInstalledOption != null && dealItemDetail.TotalDealerInstalledOption != '') {
                    minRideawayPrice += parseFloat(dealItemDetail.TotalDealerInstalledOption);
                }
                if (dealItemDetail.TotalPartAndLabor != undefined && dealItemDetail.TotalPartAndLabor != null && dealItemDetail.TotalPartAndLabor != '') {
                    minRideawayPrice += parseFloat(dealItemDetail.TotalPartAndLabor);
                }
                if (dealItemDetail.TotalStampDuty != undefined && dealItemDetail.TotalStampDuty != null && dealItemDetail.TotalStampDuty != '') {
                    var minStampDuty = 0;
                    if ((dealItemDetail.TotalFactoryOption + dealItemDetail.TotalDealerInstalledOption) > 100) {
                        minStampDuty = ((Math.ceil((dealItemDetail.TotalFactoryOption + dealItemDetail.TotalDealerInstalledOption) / 100) * 100) * ($scope.CustomerOrderModel.StampDutyRate / 100));
                    }
                    minRideawayPrice += minStampDuty;
                }
                minRideawayPrice = parseFloat(minRideawayPrice.toFixed(2));
                if ($scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice < minRideawayPrice) {
                    Notification.error('The Rideaway price you entered is below the minimum acceptable value');
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice = minRideawayPrice;
                }
                var dealItemId = $scope.CustomerOrderModel.DealItemList[dealUnitIndex].DealItemObj.Id;
                var unitJsonString = $scope.CustomerOrderModel.DealItemList[dealUnitIndex];
                DealService.updateRideawayPricing(dealItemId, angular.toJson(unitJsonString)).then(function(successResult) {
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalBasePrice = successResult.TotalBasePrice;
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalStampDuty = successResult.TotalStampDuty;
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].TotalEnforceRideawayPrice = successResult.TotalEnforceRideawayPrice;
                    $scope.CustomerOrderModel.DealItemList[dealUnitIndex].BasePriceList = successResult.BasePriceList;
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successResult);
                }, function(errorResult) {
                    Notification.error(errorResult + ' ' + $Label.Generic_Error);
                });
            }
            $scope.CustomerOrderModel.editBaseUnitPriceRowTabOut = function(event, dealId, dealItemId, dealItemIndex) {
                if (!event.shiftKey && (event.type == 'blur' || event.keyCode == 13)) {
                    if ($scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList.length == 0) {
                        $scope.CustomerOrderModel.BasePriceObj = {
                            Type: 'Base',
                            Id: null,
                            Qty: 1,
                            Price: parseInt($scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalBasePrice),
                        };
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList.push($scope.CustomerOrderModel.BasePriceObj);
                    } else {
                        for (var i = 0; i < $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList[i].TotalPrice = ($scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalBasePrice) / $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList.length;
                            $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList[i].Price = ($scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList[i].TotalPrice) / $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList[i].Qty;
                        }
                    }
                    $scope.CustomerOrderModel.editBaseUnitPriceItem(event, dealItemIndex);
                    $scope.CustomerOrderModel.saveBaseUnitPriceOnBlur(event, dealId, dealItemId, dealItemIndex, $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList);
                } else if (event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                }
            }
            $scope.CustomerOrderModel.editStampDutyRowTabOut = function(event, dealItemId, dealItemIndex) {
                if (!event.shiftKey && (event.type == 'blur' || event.keyCode == 13)) {
                    $scope.CustomerOrderModel.editStampDuty(dealItemIndex);
                    if ($scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty == null || $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty == '') {
                        $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty = 0;
                    }
                    $scope.CustomerOrderModel.updateStampDutyTotal(dealItemId, $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty);
                } else if (event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                }
            }
            $scope.CustomerOrderModel.editForStampDuty = function() {
                $scope.CustomerOrderModel.StampDuty_editRow = [];
                var UnitItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    UnitItems.push({
                        isEdit: false
                    });
                }
                $scope.CustomerOrderModel.StampDuty_editRow = UnitItems;
            }
            $scope.CustomerOrderModel.editStampDuty = function(DealUnitIndex) {
                if ($scope.CustomerOrderModel.isLockIconEnableOnUnitSection(DealUnitIndex)) {
                    return;
                }
                $scope.CustomerOrderModel.StampDuty_editRow[DealUnitIndex].isEdit = !$scope.CustomerOrderModel.StampDuty_editRow[DealUnitIndex].isEdit;
            }
            $scope.CustomerOrderModel.saveBaseUnitPriceOnBlur = function(event, dealId, dealItemId, dealItemIndex, baseUnitPriceItemJson) {
                DealService.updateDealUnitCostPrice(angular.toJson(baseUnitPriceItemJson), dealId, dealItemId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealItemList[dealItemIndex].BasePriceList = successfulSearchResult.BasePriceList;
                    $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalStampDuty = successfulSearchResult.TotalStampDuty;
                    $scope.CustomerOrderModel.DealItemList[dealItemIndex].TotalBasePrice = successfulSearchResult.TotalBasePrice;
                    $timeout(function timeout() {
                        $scope.CustomerOrderModel.editForBaseUnitPrice();
                        $scope.CustomerOrderModel.editForStampDuty();
                        $scope.CustomerOrderModel.calculateFactoryTotal();
                    }, 1000);
                    Notification.success($Label.Generic_Saved);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.editForBaseUnitPrice = function() {
                $scope.CustomerOrderModel.BaseUnitPrice_editRow = [];
                var UnitItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    UnitItems.push({
                        isEdit: false
                    });
                }
                $scope.CustomerOrderModel.BaseUnitPrice_editRow = UnitItems;
            }
            $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions = function() {
                $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow = [];
                var UnitItems = [];
                for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    UnitItems.push({
                        isEdit: false,
                        dealerInstalledOptionsLineItems: []
                    });
                    if ($scope.CustomerOrderModel.DealItemList[i] != undefined && $scope.CustomerOrderModel.DealItemList[i].DealerInstalledOptionList != undefined) {
                        for (j = 0; j < $scope.CustomerOrderModel.DealItemList[i].DealerInstalledOptionList.length; j++) {
                            UnitItems[i].dealerInstalledOptionsLineItems.push({
                                isEdit: false
                            });
                        }
                    }
                }
                $scope.CustomerOrderModel.DealerInstalledOptionsItems_editRow = UnitItems;
            }
            $scope.CustomerOrderModel.createDeal = function() {
                DealService.createDeal($scope.CustomerOrderModel.coHeaderDetails.COHeaderId).then(function(successfulResult) {
                    if (successfulResult != null && successfulResult != undefined) {
                        $scope.CustomerOrderModel.DealInfo = successfulResult.DealInfo;
                        $scope.CustomerOrderModel.DealItemList = successfulResult.UnitList;
                        $scope.CustomerOrderModel.DealTradeInList = successfulResult.TradeInsList;
                        $scope.CustomerOrderModel.DealMerchandiseList = successfulResult.DealFulfillmentSectionObj.DealMerchandiseList;
                        $scope.CustomerOrderModel.SpecialOrder = successfulResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                        $scope.CustomerOrderModel.DealMerchandiseTotal = successfulResult.DealFulfillmentSectionObj.MerchandiseTotal;
                        $scope.CustomerOrderModel.DealDepositList = successfulResult.DealDepositList;
                        $scope.UpdateDealDepositsList(successfulResult.DealDepositList);
                        $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulResult.DealUnresolvedFulfillmentList;
                        if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                            $scope.CustomerOrderModel.StockUnitMap();
                        }
                        $scope.CustomerOrderModel.DealFinanceList = successfulResult.DealFinanceObj;
                        $scope.CustomerOrderModel.getListOfFinanceCompany();
                        $scope.CustomerOrderModel.editFIProduct();
                        $scope.CustomerOrderModel.UserSelected = [];
                        $scope.CustomerOrderModel.UserList = [];
                        $scope.CustomerOrderModel.DealUserList = successfulResult.UserList;
                        $scope.CustomerOrderModel.UserList = successfulResult.UserList;
                        var DefaultApproval = {
                            name: "Pending Approval",
                            isNew: false,
                            id: null,
                            email: "durga.singh@metacube.com"
                        };
                        $scope.CustomerOrderModel.UserList.splice(0, 0, DefaultApproval);
                        for (i = 0; i < $scope.CustomerOrderModel.DealTradeInList.length; i++) {
                            if ($scope.CustomerOrderModel.DealTradeInList[i].ApprovedBy == null) {
                                $scope.CustomerOrderModel.UserSelected[i] = DefaultApproval;
                            } else {
                                for (j = 0; j < successfulResult.UserList.length; j++) {
                                    if ($scope.CustomerOrderModel.DealTradeInList[i].ApprovedBy == successfulResult.UserList[j].id) {
                                        $scope.CustomerOrderModel.UserSelected[i] = successfulResult.UserList[j];
                                    }
                                }
                            }
                        }
                        $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                        $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                        $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                        for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].FactoryOptionList = successfulResult.UnitList[i].FactoryOptionList;
                        }
                        for (i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].OptionAndFeeList = successfulResult.UnitList[i].OptionAndFeeList;
                        }
                        $scope.CustomerOrderModel.DealSummaryObj = successfulResult.DealSummaryObj;
                        $scope.CustomerOrderModel.DealInfo.DealType = successfulResult.DealInfo.DealType;
                        $scope.CustomerOrderModel.DealInfoLoadData.AvailableOptions = ["Commit Units to Deal", "Commit & Install Options", "Add Additional Unit", "Add a Trade-In", "Remove Deal", "Set as a Quote", "Activate Quote", "Delete Quote", "Send Text to Customer"];
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                        $scope.CustomerOrderModel.editLineItemsForFactoryOptions();
                        $scope.CustomerOrderModel.editLineItemsForDealerInstalledOptions();
                        $scope.CustomerOrderModel.editForBaseUnitPrice();
                        $scope.CustomerOrderModel.editForStampDuty();
                        $scope.CustomerOrderModel.editLineItemsForOptionFees();
                        $scope.CustomerOrderModel.calculateFactoryTotal();
                        $scope.CustomerOrderModel.calculateEstimatedPayment();
                        if ($scope.CustomerOrderModel.DealItemList.length == 0) {
                            $scope.CustomerOrderModel.UpdateDealSection(0);
                        }
                        $scope.CustomerOrderModel.setDefaultValidationModal();
                        $scope.CustomerOrderModel.collapseDeposit();
                        $scope.CustomerOrderModel.updateDealSummaryTotals(successfulResult);
                        $scope.CustomerOrderModel.allowCheckoutSort = true;
                        $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                    }
                })
            }
            $scope.CustomerOrderModel.calculateEstimatedPayment = function() {
                var intRate = ($scope.CustomerOrderModel.DealFinanceList.InterestRate);
                if (intRate == 0) {
                    $scope.CustomerOrderModel.DealFinanceList.EstimatedPayment = 0;
                    return;
                }
                if ($scope.CustomerOrderModel.DealFinanceList.InterestRate) {
                    if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Monthly') {
                        intRate = intRate / 12;
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Semi-Monthly') {
                        intRate = intRate / 24;
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Weekly') {
                        intRate = intRate / 52;
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Bi-Weekly') {
                        intRate = intRate / 26;
                    }
                }
                var numOfPayments = $scope.CustomerOrderModel.calculateLoanTerm();
                var loanAmount = (($scope.CustomerOrderModel.DealSummaryObj.Total + $scope.CustomerOrderModel.calculateFIProductTotal()) - $scope.CustomerOrderModel.DealFinanceList.DownPayment);
                var estimatedPayments = $scope.CustomerOrderModel.calculatePMT(intRate, numOfPayments, loanAmount, 0, 0);
                estimatedPayments = isNaN(estimatedPayments) ? 0.00 : estimatedPayments;
                $scope.CustomerOrderModel.DealFinanceList.EstimatedPayment = estimatedPayments;
            }
            $scope.CustomerOrderModel.calculateLoanTerm = function() {
                if ($scope.CustomerOrderModel.DealFinanceList.TermType == 'Months') {
                    if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Monthly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 1);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Semi-Monthly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 2);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Weekly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 4.33);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Bi-Weekly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 2.16);
                    }
                } else if ($scope.CustomerOrderModel.DealFinanceList.TermType == 'Years') {
                    if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Monthly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 12);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Semi-Monthly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 24);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Weekly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 52);
                    } else if ($scope.CustomerOrderModel.DealFinanceList.PaymentFrequency == 'Bi-Weekly') {
                        return ($scope.CustomerOrderModel.DealFinanceList.LoanTerm * 26);
                    }
                }
            }
            // Function to calculate Periodic Payments.
            $scope.CustomerOrderModel.calculatePMT = function(interestRate, numOfPayments, presentValue, futureValue, type) {
                futureValue || (futureValue = 0);
                type || (type = 0);
                pmt_value = 0;
                if (interestRate === 0) {
                    pmt_value = (presentValue + futureValue) / numOfPayments;
                } else {
                    interestRate = (interestRate / 100);
                    pvif = Math.pow(1 + interestRate, numOfPayments);
                    pmt_value = -interestRate * presentValue * (pvif + futureValue) / (pvif - 1);
                    if (type === 1) {
                        pmt_value /= (1 + interestRate);
                    }
                }
                pmt_value = (-1 * pmt_value.toFixed(2));
                return pmt_value;
            }
            $scope.CustomerOrderModel.calculateFIProductTotal = function() {
                var total = 0;
                if ($scope.CustomerOrderModel.DealFinanceList != undefined && $scope.CustomerOrderModel.DealFinanceList.FIProductList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.DealFinanceList.FIProductList.length; i++) {
                        if ($scope.CustomerOrderModel.IsTaxIncludingPricing) {
                            total += $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price;
                        } else {
                            total += $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price + $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].SalesTax;
                        }
                    }
                    $scope.CustomerOrderModel.DealFinanceList.FIProductTotal = total;
                }
                return total;
            }
            $scope.CustomerOrderModel.saveDealInfo = function() {
                SOHeaderService.saveDealInfoDetails($scope.CustomerOrderModel.DealInfo.Id, angular.toJson($scope.CustomerOrderModel.DealInfo)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    if ($scope.CustomerOrderModel.DealInfo.DealType == 'Financed' && $scope.CustomerOrderModel.DealInfo != undefined) {
                        $scope.CustomerOrderModel.getListOfFinanceCompany();
                        $scope.CustomerOrderModel.calculateFIProductTotal();
                    }
                    if ($scope.CustomerOrderModel.DealInfo.DealType == 'Financed' || $scope.CustomerOrderModel.DealInfo.DealType == 'Cash Deal') {
                        SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.coHeaderId, 'checkOut').then(function(successfulResult) {
                            $scope.CustomerOrderModel.checkOutMode = undefined;
                            $scope.bindCheckOutList(successfulResult.coInvoiceItemRecs);
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                            Notification.error($Label.Generic_Error);
                        });
                    }
                    Notification.success($Label.Generic_Saved);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveFinanceInfo = function() {
                if ($scope.CustomerOrderModel.DealFinanceList.InterestRate > 100) {
                    $scope.CustomerOrderModel.DealFinanceList.InterestRate = 100;
                }
                if ($scope.CustomerOrderModel.DealFinanceList.InterestRate == '' || isNaN($scope.CustomerOrderModel.DealFinanceList.InterestRate)) {
                    $scope.CustomerOrderModel.DealFinanceList.InterestRate = 0;
                }
                if ($scope.CustomerOrderModel.DealFinanceList.LoanTerm == '' || isNaN($scope.CustomerOrderModel.DealFinanceList.LoanTerm)) {
                    $scope.CustomerOrderModel.DealFinanceList.LoanTerm = 0;
                }
                $scope.CustomerOrderModel.DealFinanceList.DealId = $scope.CustomerOrderModel.DealInfo.Id;
                if ($scope.CustomerOrderModel.DealFinanceList.Id == null) {
                    $scope.CustomerOrderModel.DealFinanceList.Status = 'Quotation';
                }
                $scope.CustomerOrderModel.calculateEstimatedPayment();
                $scope.CustomerOrderModel.DealInfo.DownPayment = $scope.CustomerOrderModel.DealFinanceList.DownPayment;
                SOHeaderService.updateDealFinanceDetails($scope.CustomerOrderModel.DealInfo.Id, angular.toJson($scope.CustomerOrderModel.DealFinanceList)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealFinanceList = successfulSearchResult;
                    $scope.CustomerOrderModel.calculateEstimatedPayment();
                    if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length > 0) {
                        $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                    }
                    Notification.success($Label.Generic_Saved);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.getListOfFinanceCompany = function() {
                SOHeaderService.getDealFinanceMasterData().then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.FinanceCompany = [];
                    for (var i = 0; i < successfulSearchResult.length; i++) {
                        $scope.CustomerOrderModel.FinanceCompany[i] = successfulSearchResult[i];
                    }
                    if ($scope.CustomerOrderModel.FinanceCompany.length == 1) {
                        $scope.CustomerOrderModel.setCurrentFinanceCompany($scope.CustomerOrderModel.FinanceCompany[0].Id, 0);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.LoadServiceOrder = function() {
                SOHeaderService.getSOMasterData($scope.CustomerOrderModel.coHeaderId).then(function(SOMasterData) {
                    for (var i = 0; i < SOMasterData.COUList.length; i++) {
                        if (SOMasterData.COUList[i].Status == 'Transferred') {
                            SOMasterData.COUList.splice(i, 1);
                            i = i - 1;
                        }
                    }
                    $scope.CustomerOrderModel.MasterData = SOMasterData;
                    $scope.CustomerOrderModel.loadSODetails();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.bindOrderTotals = function(result) {
                if (result != undefined) {
                    if (result.OrderTotal != null) {
                        $scope.CustomerOrderModel.coHeaderDetails.OrderTotal = result.OrderTotal;
                    }
                    if (result.InvoicedAmount != null) {
                        $scope.CustomerOrderModel.coHeaderDetails.InvoicedAmount = result.InvoicedAmount;
                    }
                    if (result.UninvoicedAmount != null) {
                        $scope.CustomerOrderModel.coHeaderDetails.UninvoicedAmount = result.UninvoicedAmount;
                    }
                }
            }
            $scope.CustomerOrderModel.loadSODetails = function(loadInfoSection) {
                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.coHeaderId, null).then(function(successfulSearchResult1) {
                    if (successfulSearchResult1.SOList.length != 0) {
                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                    }
                    $scope.CustomerOrderModel.SOHeaderList = successfulSearchResult1.SOList;
                    $scope.CustomerOrderModel.pinnedItems = successfulSearchResult1.PinnedItemList;
                    $scope.CustomerOrderModel.getServiceOrderList();
                    $scope.CustomerOrderModel.setServiceOrderData();
                    $scope.CustomerOrderModel.resetServiceOrderData();
                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                    $scope.CustomerOrderModel.createGridEditItem(null);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.COInvoiceHeaderId = ((successfulSearchResult1.coInvoiceHeaderRec == null) ? ' ' : successfulSearchResult1.coInvoiceHeaderRec.COInvoiceHeaderId);
                    if (angular.isDefined($scope.CustomerOrderModel.UpdateDealCheckout) && $scope.CustomerOrderModel.UpdateDealCheckout) {
                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.UpdateDealCheckout = false;
                    }
                    $scope.CustomerOrderModel.createHoursLoggedGridEditItem(null);
                    $scope.CustomerOrderModel.createAttachmentGridEditItem(null);
                    setTimeout(function() {
                        angular.element('[data-toggle="tooltip"]').tooltip();
                    }, 1000);
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;
                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = 15;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = 15;
                    }
                    var leftPanelLinks = angular.element(window).height() - ($rootScope.wrapperHeight + angular.element(".orderNumber").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + angular.element(".ownerInfo").height() + angular.element(".sideBarTotals").height() + 85 - navBarHeightDiffrenceFixedHeaderOpen);
                    angular.element(".leftPanelLinks").css("height", leftPanelLinks);
                    $scope.CustomerOrderModel.calculateOrderTotal();
                    $scope.CustomerOrderModel.isrefresh = false;
                    $scope.CustomerOrderModel.SOHeaderList.SOHeaderInfo = {};
                    if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service') {
                        for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                            if ($scope.CustomerOrderModel.MasterData.TTList[i].Type == 'Internal') {
                                $scope.CustomerOrderModel.SOHeaderList[0].SOHeaderInfo.TransactionTypeId = $scope.CustomerOrderModel.MasterData.TTList[i].Id;
                                $scope.CustomerOrderModel.SOHeaderList[0].SOHeaderInfo.TransactionTypeLabelId = $scope.CustomerOrderModel.MasterData.TTList[i].Id;
                            }
                        }
                        $scope.CustomerOrderModel.MasterData.TTList.splice($scope.CustomerOrderModel.MasterData.TTList.indexOf('Customer') + 1, 1);
                    }
                    $scope.CustomerOrderModel.activePillboxItem = '';
                    if (loadInfoSection != undefined) {
                        setTimeout(function() {
                            $scope.CustomerOrderModel.activePillboxItem = '';
                            $scope.CustomerOrderModel.SelectedSection = $scope.CustomerOrderModel.SectionList[0];
                            $scope.CustomerOrderModel.scrollToPanel(null, $scope.CustomerOrderModel.SelectedSection.relatedSection);
                        }, 1000);
                    } else {
                        if ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Service Order') {
                            $scope.CustomerOrderModel.activePillboxItem = '#ServiceOrderSection';
                        } else {
                            $scope.CustomerOrderModel.activePillboxItem = '#MerchandiseSection';
                        }
                    }
                    $scope.CustomerOrderModel.UpdateSelectedSectionItems($scope.CustomerOrderModel.activePillboxItem.replace('#', ''));
                    $scope.CustomerOrderModel.LoadDealData();
                    $scope.CustomerOrderModel.editLineItemsForCauseConcernCorrection();
                    $scope.WizardModel.editLineItemsForCauseConcernCorrection();
                    $scope.CustomerOrderModel.editLineItemsForManualNotes();
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        if ((parseFloat($scope.CustomerOrderModel.SOHeaderList[i].SOSignInRec.Odometer) > 0) || (parseFloat($scope.CustomerOrderModel.SOHeaderList[i].SOSignInRec.Odometer) == 0 && $scope.CustomerOrderModel.SOHeaderList[i].SOReviewRec.OdometerOnDeparture > 0)) {
                            $scope.CustomerOrderModel.SOHeaderList[i].hideOdometerArrival = true;
                        } else {
                            $scope.CustomerOrderModel.SOHeaderList[i].hideOdometerArrival = false;
                        }
                    }
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        $scope.CustomerOrderModel.SOHeaderList[i].hideStatusPicklistValue = false;
                        if ($scope.CustomerOrderModel.SOHeaderList[i].SOReviewRec.OdometerOnDeparture == 0) {
                            $scope.CustomerOrderModel.SOHeaderList[i].hideOdometerDeparture = false;
                        } else {
                            $scope.CustomerOrderModel.SOHeaderList[i].hideOdometerDeparture = true;
                        }
                        $scope.CustomerOrderModel.BlurcalledService[i] = false;
                        $scope.CustomerOrderModel.allowBlurservice[i] = true;
                        if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId != null && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId != '' && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.DealId != undefined) {
                            $scope.CustomerOrderModel.setCurrentCOU($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.COUId, i);
                        }
                    }
                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                    if ($scope.CustomerOrderModel.COUList.length == 1 && $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Service Order') {
                        $scope.CustomerOrderModel.setCurrentCOU($scope.CustomerOrderModel.COUList[0].Id, 0);
                    }
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_ServiceOrder') > -1 && $scope.CustomerOrderModel.SOHeaderList.length == 1 && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Service Order' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service')) {
                            if (!$scope.CustomerOrderModel.isPageLoadFirstTime) {
                                $scope.CustomerOrderModel.scrollToPanel(null, 'ServiceOrderSection0');
                                $scope.CustomerOrderModel.isPageLoadFirstTime = true;
                            }
                        } else if ($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Merchandise') > -1 && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Cash Sale')) {
                            if (!$scope.CustomerOrderModel.isPageLoadFirstTime) {
                                if (!$scope.CustomerOrderModel.hideMerchandiseSection) {
                                    $scope.CustomerOrderModel.scrollToPanel(null, 'MerchandiseSection');
                                } else {
                                    $scope.CustomerOrderModel.scrollToPanel(null, 'CustomerSection');
                                }
                                $scope.CustomerOrderModel.isPageLoadFirstTime = true;
                            }
                        }
                    }, 3000);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                    $scope.CustomerOrderModel.isrefresh = false;
                });
                if ($scope.CustomerOrderModel.editColiId != undefined) {
                    var elementId;
                    var lineitem;
                    var COKHIndex;
                    var COLIIndex;
                    for (i = 0; i < $scope.CustomerOrderModel.MerchandiseItems.length; i++) {
                        for (j = 0; j < $scope.CustomerOrderModel.MerchandiseItems[i].COLIList.length; j++) {
                            if ($scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j].CoLineItemId.substring(0, 15) == $scope.CustomerOrderModel.editColiId.substring(0, 15)) {
                                lineitem = $scope.CustomerOrderModel.MerchandiseItems[i].COLIList[j]
                                elementId = 'COLI_Qty_Needed_Edit_' + i + '_' + j + '';
                                COKHIndex = i;
                                COLIIndex = j;
                                break;
                            }
                        }
                    }
                    $scope.CustomerOrderModel.openEditModeMerchRow(lineitem, COKHIndex, COLIIndex, undefined);
                    setTimeout(function() {
                        angular.element('#' + elementId).focus();
                    }, 3000);
                }
            }
            $scope.CustomerOrderModel.createAttachmentGridEditItem = function(indexToUpdate) {
                if (indexToUpdate == null) {
                    $scope.CustomerOrderModel.Attachment_editRow = [];
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        var SOHeader_Attachment_editRow = [];
                        for (var j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].AttachmentList.length; j++) {
                            SOHeader_Attachment_editRow.push({
                                isEdit: false,
                                radioValue: 0
                            });
                        }
                        $scope.CustomerOrderModel.Attachment_editRow.push({
                            SOHeader_Attachment_editRow: SOHeader_Attachment_editRow
                        });
                    }
                }
            }
            $scope.CustomerOrderModel.editAttachmentItem = function(parentIndex, index) {
                if ($scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Signed Out' || (!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                if (index != null) {
                    var isEditModeEnabled = false;
                    for (i = 0; i < $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow.length; i++) {
                        if ($scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                        }
                        $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow[index].isEdit = true;
                    }
                } else {
                    for (i = 0; i < $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow.length; i++) {
                        $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow[i].isEdit = false;
                    }
                }
            }
            $scope.CustomerOrderModel.createHoursLoggedGridEditItem = function(indexToUpdate) {
                if (indexToUpdate == null) {
                    $scope.CustomerOrderModel.HoursLogged_editRow = [];
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        var SOHeader_HoursLogged_editRow = [];
                        for (var j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].HoursLoggedList.length; j++) {
                            SOHeader_HoursLogged_editRow.push({
                                isEdit: false,
                                radioValue: 0
                            });
                        }
                        $scope.CustomerOrderModel.HoursLogged_editRow.push({
                            SOHeader_HoursLogged_editRow: SOHeader_HoursLogged_editRow
                        });
                    }
                }
            }
            $scope.CustomerOrderModel.editHoursLoggedItem = function(parentIndex, index) {
                if ((!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                if (index != null) {
                    var isEditModeEnabled = false;
                    for (i = 0; i < $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow.length; i++) {
                        if ($scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                        }
                        $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow[index].isEdit = true;
                    }
                } else {
                    for (i = 0; i < $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow.length; i++) {
                        $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow[i].isEdit = false;
                    }
                }
            }
            $scope.CustomerOrderModel.editHoursLoggedGoAction = function(parentIndex, index) {
                var radioValue = $scope.CustomerOrderModel.HoursLogged_editRow[parentIndex].SOHeader_HoursLogged_editRow[index].radioValue;
                if (radioValue == 0) {
                    var coHeaderId = $scope.CustomerOrderModel.coHeaderId;
                    var EditHourlogParams = {
                        logHourObject: $scope.CustomerOrderModel.SOHeaderList[parentIndex].HoursLoggedList[index],
                        coHeaderId: coHeaderId,
                        index: parentIndex,
                        isEditMode: true
                    };
                    loadState($state, 'CustomerOrder.HourlogPopup', {
                        HourlogParams: EditHourlogParams
                    });
                }
            }
            $scope.CustomerOrderModel.editAttachmentApplyAction = function(attachmentId, soHeaderId, parentIndex, index) {
                var radioValue = $scope.CustomerOrderModel.Attachment_editRow[parentIndex].SOHeader_Attachment_editRow[index].radioValue;
                if (radioValue == 0) {
                    FileUploadService.removeAttachment(attachmentId, soHeaderId).then(function(successfulResult) {
                        $scope.CustomerOrderModel.SOHeaderList[parentIndex].AttachmentList = successfulResult;
                        $scope.CustomerOrderModel.createAttachmentGridEditItem(null);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    })
                }
            }
            $scope.CustomerOrderModel.createGridEditItem = function(indextoUpdate) {
                var allItem = false;
                var firstItem = false;
                if (indextoUpdate != null) {
                    var HeaderItems_editRow = [];
                    for (var j = 0; j < $scope.CustomerOrderModel.SOHeaderList[indextoUpdate].SOGridItems.length; j++) {
                        var SOLI_editRow = [];
                        if (j == 0 && $scope.CustomerOrderModel.SOHeaderList[indextoUpdate].SOGridItems[j].SOKH.Id != null) {
                            firstItem = false;
                            allItem = true;
                        } else if (j == 0 && $scope.CustomerOrderModel.SOHeaderList[indextoUpdate].SOGridItems[j].SOKH.Id == null) {
                            firstItem = true;
                            allItem = false;
                        }
                        for (var k = 0; k < $scope.CustomerOrderModel.SOHeaderList[indextoUpdate].SOGridItems[j].SOKH.SOLIList.length; k++) {
                            SOLI_editRow.push({
                                isEdit: false,
                                radioValue: 0,
                                optionSelected: 0,
                                IsEvenRow: allItem,
                                MoveTosection: ''
                            });
                            allItem = (allItem == true ? false : true);
                        }
                        if (j == 0) {
                            HeaderItems_editRow.push({
                                isEdit: false,
                                radioValue: 0,
                                optionSelected: 0,
                                IsEvenRow: firstItem,
                                SOLI_editRow: SOLI_editRow,
                                MoveTosection: ''
                            });
                        } else {
                            HeaderItems_editRow.push({
                                isEdit: false,
                                radioValue: 0,
                                optionSelected: 0,
                                IsEvenRow: allItem,
                                SOLI_editRow: SOLI_editRow,
                                MoveTosection: ''
                            });
                            if ($scope.CustomerOrderModel.SOHeaderList[indextoUpdate].SOGridItems[j].SOKH.Id != null) {
                                allItem = (allItem == true ? false : true);
                            }
                        }
                    }
                    $scope.CustomerOrderModel.SoItems_editRow[indextoUpdate].HeaderItems_editRow = HeaderItems_editRow;
                } else {
                    $scope.CustomerOrderModel.SoItems_editRow = [];
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        var HeaderItems_editRow = [];
                        for (var j = 0; j < $scope.CustomerOrderModel.SOHeaderList[i].SOGridItems.length; j++) {
                            var SOLI_editRow = [];
                            if (j == 0 && $scope.CustomerOrderModel.SOHeaderList[i].SOGridItems[j].SOKH.Id != null) {
                                firstItem = false;
                                allItem = true;
                            } else if (j == 0 && $scope.CustomerOrderModel.SOHeaderList[i].SOGridItems[j].SOKH.Id == null) {
                                firstItem = true;
                                allItem = false;
                            }
                            for (var k = 0; k < $scope.CustomerOrderModel.SOHeaderList[i].SOGridItems[j].SOKH.SOLIList.length; k++) {
                                SOLI_editRow.push({
                                    isEdit: false,
                                    radioValue: 0,
                                    optionSelected: 0,
                                    IsEvenRow: allItem,
                                    MoveTosection: ''
                                });
                                allItem = (allItem == true ? false : true);
                            }
                            if (j == 0) {
                                HeaderItems_editRow.push({
                                    isEdit: false,
                                    radioValue: 0,
                                    optionSelected: 0,
                                    IsEvenRow: firstItem,
                                    SOLI_editRow: SOLI_editRow,
                                    MoveTosection: ''
                                });
                            } else {
                                HeaderItems_editRow.push({
                                    isEdit: false,
                                    radioValue: 0,
                                    optionSelected: 0,
                                    IsEvenRow: allItem,
                                    SOLI_editRow: SOLI_editRow,
                                    MoveTosection: ''
                                });
                                if ($scope.CustomerOrderModel.SOHeaderList[i].SOGridItems[j].SOKH.Id != null) {
                                    allItem = (allItem == true ? false : true);
                                }
                            }
                        }
                        $scope.CustomerOrderModel.SoItems_editRow.push({
                            HeaderItems_editRow: HeaderItems_editRow
                        });
                    }
                }
            }
            $scope.CustomerOrderModel.changeServiceOrderKitItemsSelectedOption = function(soHederIndex, kitHeaderindex, index, value) {
                $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[kitHeaderindex].SOLI_editRow[index].optionSelected = value
            }
            $scope.CustomerOrderModel.SelectUnitToAddOptionFee = function(dealId, optionFeeJSON) {
                loadState($state, 'CustomerOrder.SelectUnit', {
                    SelectUnitParams: {
                        dealId: dealId,
                        optionFeeJSON: optionFeeJSON
                    }
                });
            }
            $scope.CustomerOrderModel.dealItemGoAction = function(optionSelected, dealKitHeaderId, optionFeeId, dealItemId, dealItemIndex) {
                var lineItemId;
                if (dealKitHeaderId != null) {
                    lineItemId = dealKitHeaderId;
                } else {
                    lineItemId = optionFeeId;
                }
                if (optionSelected == 0) {
                    $scope.CustomerOrderModel.removeOptionFeesItem(dealItemId, lineItemId, dealItemIndex);
                }
            }
            $scope.CustomerOrderModel.removeOptionFeesItem = function(dealItemId, lineItemId, dealItemIndex) {
                DealService.removeOptionFeesItem(dealItemId, lineItemId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealItemList[dealItemIndex] = successfulSearchResult;
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                    $scope.CustomerOrderModel.editLineItemsForOptionFees();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.serviceItemGoAction = function(optionSelected, kitHeaderId, Id, index, soHederIndex, SoliIndex) {
                if (optionSelected == 0) {
                    if (kitHeaderId != null) {
                        $scope.CustomerOrderModel.removeServiceItem(kitHeaderId, index, soHederIndex);
                    } else {
                        $scope.CustomerOrderModel.removeServiceItem(Id, index, soHederIndex);
                    }
                } else if (optionSelected == 1) {
                    $scope.CustomerOrderModel.breakServiceKitLineItem(kitHeaderId, index, soHederIndex);
                } else if (optionSelected == 2) {
                    var voHeaderId = $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].radioValue
                    var partId = $scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].PartId;
                    var coli = $scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].CoLineItem;
                    if (partId != null && coli != null) {
                        $scope.CustomerOrderModel.createSpecialOrderServiceOrder(partId, coli, voHeaderId, soHederIndex)
                    }
                } else if (optionSelected == 3) {
                    if (kitHeaderId != null) {
                        if ($scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].MoveTosection == 'Merchandise') {
                            if (!($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                                Notification.error("You don't have permission to modify Merchandise section");
                                return;
                            }
                            if ($scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.IsServiceKit == true) {
                                Notification.error($Label.CustomerOrder_Js_Moved_to_Merchandise_section);
                                return;
                            }
                        }
                        if ($scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].MoveTosection != '' && $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].MoveTosection != null) {
                            SOHeaderService.moveLineItem($scope.CustomerOrderModel.SOHeaderList[soHederIndex], $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].MoveTosection, kitHeaderId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                                $scope.UpdateMerchandiseList(successfulSearchResult);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                                $scope.CustomerOrderModel.LoadServiceOrder();
                            });
                        } else {
                            $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].isEdit = false;
                            return;
                        }
                    } else {
                        var partId = $scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].PartId;
                        var coli = $scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].CoLineItem;
                        if ($scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].MoveTosection == 'Merchandise') {
                            if (!($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])) {
                                Notification.error("You don't have permission to modify Merchandise section");
                                return;
                            }
                            if ($scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].IsLabour) {
                                Notification.error($Label.CustomerOrder_Js_Labour_cannot_moved);
                                return;
                            }
                            if ($scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOGridItems[index].SOKH.SOLIList[SoliIndex].IsSublet) {
                                Notification.error("You cannot move vendor product to merchandise section");
                                return;
                            }
                        }
                        if ($scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].MoveTosection == '' || $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].MoveTosection == null || $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].MoveTosection == undefined) {
                            $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].isEdit = false;
                            return;
                        }
                        SOHeaderService.moveLineItem($scope.CustomerOrderModel.SOHeaderList[soHederIndex], $scope.CustomerOrderModel.SoItems_editRow[soHederIndex].HeaderItems_editRow[index].SOLI_editRow[SoliIndex].MoveTosection, Id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                            $scope.UpdateMerchandiseList(successfulSearchResult);
                            $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                            $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                            $scope.CustomerOrderModel.LoadServiceOrder();
                        })
                    }
                }
            }
            $scope.CustomerOrderModel.createSpecialOrderServiceOrder = function(partId, coli, voHeaderId, soHederIndex) {
                $scope.CustomerOrderModel.itemsPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "ItemDesc",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.itemsPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                $scope.CustomerOrderModel.customersPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.customersPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                $scope.CustomerOrderModel.stocksPageSortAttrsJSON = {
                    ChangesCount: 0,
                    CurrentPage: 1,
                    PageSize: 10,
                    Sorting: [{
                        FieldName: "Item",
                        SortDirection: "ASC"
                    }]
                };
                try {
                    $scope.CustomerOrderModel.stocksPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size
                } catch (ex) {}
                CustomerInfoService.createSpecialOrderServiceOrder(partId, coli, voHeaderId, $scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.itemsPageSortAttrsJSON), JSON.stringify($scope.CustomerOrderModel.customersPageSortAttrsJSON), JSON.stringify($scope.CustomerOrderModel.stocksPageSortAttrsJSON)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                    $scope.CustomerOrderModel.SOHeaderList[soHederIndex] = successfulSearchResult.SOList[soHederIndex];
                    $scope.CustomerOrderModel.setServiceOrderData();
                    $scope.CustomerOrderModel.resetServiceOrderData();
                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                    $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.createGridEditItem(soHederIndex);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.removeServiceItem = function(Id, index, soHederIndex) {
                SOHeaderService.removeLineItems(Id, $scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOHeaderInfo.Id).then(function(successfulSearchResult) {
                    if ($scope.CustomerOrderModel.SOHeaderList[soHederIndex].SOHeaderInfo.DealId != null) {
                        $scope.CustomerOrderModel.LoadServiceOrder();
                        $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult;
                        $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    } else {
                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                        $scope.CustomerOrderModel.SOHeaderList[soHederIndex] = successfulSearchResult.SOList[soHederIndex];
                        $scope.CustomerOrderModel.setServiceOrderData();
                        $scope.CustomerOrderModel.resetServiceOrderData();
                        $scope.CustomerOrderModel.resetCauseConcernCorrection();
                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                        $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.createGridEditItem(soHederIndex);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.breakServiceKitLineItem = function(kitHeaderId, index, soHederIndex) {
                SOHeaderService.splitSOKHItem(kitHeaderId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                    $scope.CustomerOrderModel.SOHeaderList[soHederIndex] = successfulSearchResult.SOList[soHederIndex];
                    $scope.CustomerOrderModel.setServiceOrderData();
                    $scope.CustomerOrderModel.resetServiceOrderData();
                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                    $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.createGridEditItem(soHederIndex);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.createNewSpecialorder = function(partid, coliId, vendorId) {
                var item = {
                    'partId': partid,
                    'CoLineItemId': coliId
                };
                if (angular.isDefined(vendorId)) {
                    $scope.createSpecialOrder(item, vendorId);
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.addServiceItem = function(Name, Value, result) {
                var lineItemType = '';
                if (result.originalObject.Info == 'Unit') {
                    var selectedIndex = $scope.CustomerOrderModel.SelectedSection.index;
                    $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.COUId = Value;
                    $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.PromisedBy = $scope.CustomerOrderModel.getSFformatDate($scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.selectedDate, $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.selectedTime);
                    if ($scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.PromisedBy == undefined || $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.PromisedBy.indexOf('undefined') > -1) {
                        $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.PromisedBy = null;
                    }
                    SOHeaderService.saveSOHeaderInfo($scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo)).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo = successfulSearchResult;
                        $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOHeaderInfo.CategoryNameStr = successfulSearchResult.CategoryName;
                    });
                } else {
                    if (Value != 'undefined') {
                        var soHeaderId = $scope.CustomerOrderModel.SOHeaderList[$scope.CustomerOrderModel.SelectedSection.index].SOHeaderInfo.Id
                        var selectedIndex = $scope.CustomerOrderModel.SelectedSection.index;
                        var customerId = $scope.CustomerOrderModel.Customer.Value;
                        if (!angular.isDefined(customerId)) {
                            customerId = null;
                        }
                        if ($scope.CustomerOrderModel.Customer.Value != null || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service') {
                            if (result.description == "Merchandise") {
                                lineItemType = 'Service';
                                SOHeaderService.checkDuplicateParts(result.originalObject.AdditionalDetailsForPart.PartId, $scope.CustomerOrderModel.coHeaderId, result.originalObject.AdditionalDetailsForPart, false, true, soHeaderId, customerId).then(function(successfulSearchResult) {
                                    if (angular.isDefined(successfulSearchResult.DuplicatePart)) {
                                        $scope.CustomerOrderModel.openDuplicatePartModal($scope.CustomerOrderModel.coHeaderId, lineItemType, result.originalObject.AdditionalDetailsForPart, false, soHeaderId);
                                    } else {
                                        $scope.CustomerOrderModel.addLineItemsFOrServiceJob(successfulSearchResult, selectedIndex);
                                    }
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                    $scope.searching = false;
                                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                                });
                            } else {
                                SOHeaderService.addLineItems(Value, soHeaderId, $scope.CustomerOrderModel.coHeaderId, customerId).then(function(successfulSearchResult) {
                                    $scope.CustomerOrderModel.addLineItemsFOrServiceJob(successfulSearchResult, selectedIndex);
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                    $scope.searching = false;
                                    $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                                });
                            }
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.addLineItemsFOrServiceJob = function(successfulSearchResult, selectedIndex, preventEditMode) {
                $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                $scope.CustomerOrderModel.SOHeaderList[selectedIndex] = successfulSearchResult.SOList[selectedIndex];
                $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.specialOrderList;
                $scope.CustomerOrderModel.getServiceOrderList();
                $scope.CustomerOrderModel.setServiceOrderData();
                $scope.CustomerOrderModel.resetServiceOrderData();
                $scope.CustomerOrderModel.resetCauseConcernCorrection();
                $scope.CustomerOrderModel.createGridEditItem(selectedIndex);
                $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                var sectionaName = $scope.CustomerOrderModel.SectionList[selectedIndex].relatedSection;
                var SOGridItemslength = $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems;
                $scope.CustomerOrderModel.StockUnitMap();
                if (preventEditMode == undefined || preventEditMode == false) {
                    if ($scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems[SOGridItemslength.length - 1].SOKH.hasChildren == true) {
                        $scope.CustomerOrderModel.SoItems_editRow[selectedIndex].HeaderItems_editRow[SOGridItemslength.length - 1].isEdit = true;
                    } else {
                        var editedSOLIIndex = SOGridItemslength.length - 1;
                        if ($scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems[editedSOLIIndex].SOKH.SOLIList[0].IsEnvFee) {
                            editedSOLIIndex = ((editedSOLIIndex > 0) ? (editedSOLIIndex - 1) : editedSOLIIndex);
                        }
                        $scope.CustomerOrderModel.SoItems_editRow[selectedIndex].HeaderItems_editRow[editedSOLIIndex].SOLI_editRow[0].isEdit = true;
                        $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue = $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems[editedSOLIIndex].SOKH.SOLIList[0].StockCommited;
                        $scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue = $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems[editedSOLIIndex].SOKH.SOLIList[0].AvailablePart;
                        $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue = $scope.CustomerOrderModel.SOHeaderList[selectedIndex].SOGridItems[editedSOLIIndex].SOKH.SOLIList[0].QtyNeeded;
                    }
                    var CO_ItemGrid_gid_container_tbody_length = SOGridItemslength.length - 1;
                    setTimeout(function() {
                        $scope.CustomerOrderModel.scrollToPanel(null, 'CO_ItemGrid_gid_container_tbody' + CO_ItemGrid_gid_container_tbody_length);
                    }, 2000);
                    setTimeout(function() {
                        elementId = '#ServiceOrderSection' + selectedIndex + ' #CO_ItemGrid_gid_container';
                        angular.element(elementId).find('input[type=text]').not('.descEditInput').filter(':visible:first').focus();
                    }, 10);
                }
            }
            $scope.CustomerOrderModel.updateServiceOrderKitHeader = function(soIndex, parentIndex, event) {}
            $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue = 0;
            $scope.CustomerOrderModel.solieditRowBlur = function(soIndex, parentIndex, index, event, refreshEditMode, focusElementId, ShiftTabEvent) {
                $scope.CustomerOrderModel.calculateServiceLineItem(soIndex, parentIndex, index);
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledService[soIndex] = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurservice[soIndex] == true) {
                            if (ShiftTabEvent != undefined) {
                                angular.element('#CO_SearchToAdd_value').focus();
                            }
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.saveServiceOnBlur(soIndex, parentIndex, index, event, true);
                        }
                        $scope.CustomerOrderModel.BlurcalledService[soIndex] = false;
                        $scope.CustomerOrderModel.allowBlurservice[soIndex] = true;
                        return;
                    }, 300);
                };
                if (event.type == 'blur' || (event.type == 'keydown' && (!event.shiftKey && event.keyCode == 9))) {
                    if (event.type == 'keydown' && ShiftTabEvent == undefined) {
                        $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                        event.preventDefault();
                    }
                    if (event.type == 'blur') {
                        if ($scope.CustomerOrderModel.allowBlurservice[soIndex] == false) {
                            return;
                        }
                    }
                    $scope.CustomerOrderModel.calculateServiceLineItem(soIndex, parentIndex, index);
                    setTimeout(function() {
                        angular.element('#' + focusElementId).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    if (ShiftTabEvent == undefined) {
                        $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                    }
                    if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].IsPart) {
                        event.preventDefault();
                    }
                }
            }
            $scope.CustomerOrderModel.calculateServiceLineItem = function(soIndex, parentIndex, index) {
                if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index] == undefined) {
                    return;
                }
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded = ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded == '') ? 1 : $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded;
                if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited == '' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited == null) {
                    $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = 0
                }
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded = parseFloat($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded);
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = parseFloat($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited);
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].AvailablePart = parseFloat($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].AvailablePart);
                var MaxCommit = parseFloat($scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue) + parseFloat($scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue);
                if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded != $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue) {
                    if (!$rootScope.GroupOnlyPermissions['Returns'].enabled && $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue < 0) {
                        $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded = $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue;
                    }
                    $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].SubTotal = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded * $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].KitPrice;
                    if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded > MaxCommit) {
                        $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = MaxCommit > 0 ? MaxCommit : 0;
                        if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Ordered' && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status = 'Required';
                        }
                    } else {
                        $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded;
                        if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Ordered' && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status = 'In Stock';
                        }
                    }
                    $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded;
                } else if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited != $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue) {
                    if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited >= $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded) {
                        $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded;
                    }
                    var SOLI_QtyCommitted = parseFloat($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited);
                    var SOLI_OldQtyCommitted = parseFloat($scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue);
                    if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited > MaxCommit && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded == $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited) {
                        if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Ordered' && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Invoiced') {
                            if (!$rootScope.GroupOnlyPermissions['Oversell inventory']['enabled'] && (SOLI_QtyCommitted > SOLI_OldQtyCommitted)) {
                                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited = SOLI_OldQtyCommitted;
                            } else {
                                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status = 'Oversold';
                            }
                        }
                    } else if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited <= MaxCommit && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded == $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited) {
                        $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status = 'In Stock';
                    } else {
                        if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Ordered' && $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status != 'Invoiced') {
                            $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].Status = 'Required';
                        }
                    }
                }
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].AvailablePart = ($scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue - ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited - $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue));
                $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited
                $scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].AvailablePart
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].SubTotal = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded * $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].KitPrice;
                $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyOrder = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].QtyNeeded - $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].StockCommited;
            }
            $scope.CustomerOrderModel.editRowTabOutServiceOrderLineItem = function(soIndex, parentIndex, index, focusElementId, event, shiftTabEvent) {
                if (!event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                    event.preventDefault();
                    if (!$scope.CustomerOrderModel.isWizardMode) {
                        if (shiftTabEvent != undefined && ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].IsFee || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].IsLabour || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].IsSublet) && !$scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].IsFixedPrice) {
                            setTimeout(function() {
                                angular.element('#' + focusElementId).focus();
                            }, 0);
                        } else {
                            angular.element('#CO_SearchToAdd_value').focus();
                            $scope.CustomerOrderModel.updateServiceOrderLineItem(soIndex, parentIndex, index, event, true);
                        }
                    } else if ($scope.CustomerOrderModel.isWizardMode) {
                        angular.element('#nextBtnForClaimSubmission').addClass('active');
                        angular.element('#nextBtnForClaimSubmission').focus();
                        $scope.CustomerOrderModel.updateServiceOrderLineItem(soIndex, parentIndex, index, event, true);
                    }
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    if (shiftTabEvent == undefined) {
                        setTimeout(function() {
                            angular.element('#' + focusElementId).focus();
                        }, 0);
                    }
                    $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                } else if (event.shiftKey && event.keyCode == 9) {
                    event.preventDefault();
                    $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                }
            }
            $scope.CustomerOrderModel.updateServiceOrderLineItem = function(soIndex, parentIndex, index, event, refreshEditMode) {
                console.warn('save calling ' + $scope.CustomerOrderModel.showRelatedPartsClicked);
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    console.warn('yes inside return');
                    return;
                }
                if ($scope.CustomerOrderModel.BlurcalledService[soIndex]) {
                    $scope.CustomerOrderModel.allowBlurservice[soIndex] = false;
                }
                if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out' || (!$rootScope.GroupOnlyPermissions['Service job']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['create/modify'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                var isEditModeEnabled = false;
                var IsparentUpdate = false;
                var parentIndexToUpdate = 0;
                var childIndexToUpdate = 0;
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if (angular.isDefined(event.parentElement)) {
                    if (event.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 && event.type != 'keydown') {
                        return;
                    }
                }
                if ((event.target.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.target.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                    return;
                }
                if (angular.isDefined(event.toElement)) {
                    if ((event.toElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1 || event.toElement.id.indexOf('merch_item_row') != -1) && event.type != 'keydown') {
                        return;
                    }
                }
                if (event.target.parentElement.parentElement.id.indexOf('CustomerOrder_SpecialOrderGrid_tbody_expandtr_td') != -1) {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                for (var i = 0; i < $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        IsparentUpdate = true;
                        parentIndexToUpdate = i;
                        break;
                    } else {
                        for (var j = 0; j < $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].SOLI_editRow.length; j++) {
                            if ($scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].SOLI_editRow[j].isEdit == true) {
                                isEditModeEnabled = true;
                                parentIndexToUpdate = i;
                                childIndexToUpdate = j;
                                break;
                            }
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, null).then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.SOList.length; i++) {
                            for (var j = 0; j < successfulSearchResult.SOList[i].SOGridItems.length; j++) {
                                for (var k = 0; k < successfulSearchResult.SOList[i].SOGridItems[j].SOKH.SOLIList.length; k++) {
                                    $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[j].SOKH.SOLIList[k].AvailablePart = successfulSearchResult.SOList[i].SOGridItems[j].SOKH.SOLIList[k].AvailablePart;
                                }
                            }
                        }
                        if (index != null) {
                            var focusElement = angular.element(event.target).closest('tr').next().find('input[type=text]').filter(':first');
                            var lineItem = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index];
                            if (lineItem.Status == 'Ordered') {
                                $scope.CustomerOrderModel.openRemoveItemConfirmationPopup(lineItem, soIndex, parentIndex, index, focusElement, 'Service');
                                return;
                            }
                            if ((lineItem.IsFee || lineItem.IsLabour || !(lineItem.Status == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out'))) {
                                $scope.CustomerOrderModel.openEditModeServiceRow(lineItem, soIndex, parentIndex, index, focusElement);
                            }
                        } else {
                            $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].isEdit = true;
                        }
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (IsparentUpdate) {
                        var soKHItemJSON = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndexToUpdate];
                        if (!soKHItemJSON.IsFixedPrice) {
                            SOHeaderService.updateSOKHLineItems(angular.toJson(soKHItemJSON), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                                if (successfulSearchResult.length == 0) {
                                    SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                        if (successfulSearchResult1.SOList.length > 0) {
                                            $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                            $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                            $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                            $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                        }
                                    }, function(errorSearchResult) {
                                        responseData = errorSearchResult;
                                    });
                                } else if (successfulSearchResult.length > 0 && successfulSearchResult[0].DealId != undefined && successfulSearchResult[0].DealId != null) {
                                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult;
                                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                                    $scope.CustomerOrderModel.StockUnitMap();
                                    SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                        if (successfulSearchResult1.SOList.length > 0) {
                                            $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                            $scope.CustomerOrderModel.setServiceOrderData();
                                            $scope.CustomerOrderModel.resetServiceOrderData();
                                            $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                            $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                            $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                            $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                        }
                                    }, function(errorSearchResult) {
                                        responseData = errorSearchResult;
                                    });
                                } else if (successfulSearchResult.error.ResponseCode == '300') {
                                    Notification.error(successfulSearchResult.error.ResponseMeassage);
                                    SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                        if (successfulSearchResult1.SOList.length > 0) {
                                            $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                                            $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                            $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                            $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                            $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                        }
                                    }, function(errorSearchResult) {
                                        responseData = errorSearchResult;
                                    });
                                } else {
                                    $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                                    $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult.SOList[soIndex];
                                    $scope.CustomerOrderModel.setServiceOrderData();
                                    $scope.CustomerOrderModel.resetServiceOrderData();
                                    $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                    $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                                    $scope.CustomerOrderModel.COInvoiceHeaderId = ((successfulSearchResult.coInvoiceHeaderRec == null) ? ' ' : successfulSearchResult.coInvoiceHeaderRec.COInvoiceHeaderId);
                                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                                }
                                if (refreshEditMode) {
                                    $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                }
                            }, function(errorSearchResult) {
                                responseData = errorSearchResult;
                            });
                        } else {
                            $scope.CustomerOrderModel.createGridEditItem(soIndex);
                        }
                    } else {
                        var lineItemJSON = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndexToUpdate].SOKH.SOLIList[childIndexToUpdate];
                        SOHeaderService.updateSOLineItems(angular.toJson(lineItemJSON), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                            if (successfulSearchResult.length == 0) {
                                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                    if (successfulSearchResult1.SOList.length > 0) {
                                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                                        $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                        $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                    }
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                });
                            } else if (successfulSearchResult.length > 0 && successfulSearchResult[0].DealId != undefined && successfulSearchResult[0].DealId != null) {
                                $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult;
                                $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                                $scope.CustomerOrderModel.StockUnitMap();
                                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                    if (successfulSearchResult1.SOList.length > 0) {
                                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                                        $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                        $scope.CustomerOrderModel.setServiceOrderData();
                                        $scope.CustomerOrderModel.resetServiceOrderData();
                                        $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                        $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                    }
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                });
                            } else if (successfulSearchResult.error.ResponseCode == '300') {
                                Notification.error(successfulSearchResult.error.ResponseMeassage);
                                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                    if (successfulSearchResult1.SOList.length > 0) {
                                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                                        $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                        $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                    }
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                });
                            } else {
                                $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                                $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult.SOList[soIndex];
                                $scope.CustomerOrderModel.setServiceOrderData();
                                $scope.CustomerOrderModel.resetServiceOrderData();
                                $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                            }
                            if (refreshEditMode) {
                                $scope.CustomerOrderModel.createGridEditItem(soIndex);
                            }
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                    }
                }
            }
            $scope.CustomerOrderModel.openEditModeServiceRow = function(lineItem, soIndex, parentIndex, index, element) {
                $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].isEdit = true;
                $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue = lineItem.StockCommited;
                $scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue = lineItem.AvailablePart;
                $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue = lineItem.QtyNeeded;
                if (!(lineItem.IsFee || lineItem.IsLabour || lineItem.IsSublet)) {
                    var vendorId = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].VendorId;
                    $scope.CustomerOrderModel.getVendorOrderBySOlIVendorId(vendorId);
                }
                setTimeout(function() {
                    element.focus();
                }, 10);
            }
            $scope.CustomerOrderModel.saveServiceOnBlur = function(soIndex, parentIndex, index, event, refreshEditMode) {
                console.warn('save calling ' + $scope.CustomerOrderModel.showRelatedPartsClicked);
                if ($scope.CustomerOrderModel.showRelatedPartsClicked == true) {
                    console.warn('yes inside return');
                    return;
                }
                if ($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out') {
                    return;
                }
                var isEditModeEnabled = false;
                var IsparentUpdate = false;
                var parentIndexToUpdate = 0;
                var childIndexToUpdate = 0;
                for (var i = 0; i < $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].isEdit == true) {
                        isEditModeEnabled = true;
                        IsparentUpdate = true;
                        parentIndexToUpdate = i;
                        break;
                    } else {
                        for (var j = 0; j < $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].SOLI_editRow.length; j++) {
                            if ($scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[i].SOLI_editRow[j].isEdit == true) {
                                isEditModeEnabled = true;
                                parentIndexToUpdate = i;
                                childIndexToUpdate = j;
                                break;
                            }
                        }
                    }
                }
                if (!isEditModeEnabled) {
                    SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, null).then(function(successfulSearchResult) {
                        for (var i = 0; i < successfulSearchResult.SOList.length; i++) {
                            for (var j = 0; j < successfulSearchResult.SOList[i].SOGridItems.length; j++) {
                                for (var k = 0; k < successfulSearchResult.SOList[i].SOGridItems[j].SOKH.SOLIList.length; k++) {
                                    $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[j].SOKH.SOLIList[k].AvailablePart = successfulSearchResult.SOList[i].SOGridItems[j].SOKH.SOLIList[k].AvailablePart;
                                }
                            }
                        }
                        if (index != null) {
                            var lineItem = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index];
                            if ((lineItem.IsFee || lineItem.IsLabour || !(lineItem.Status == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.WorkStatus == 'Signed Out')) && !lineItem.IsFixedPrice) {
                                $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].isEdit = true;
                                $scope.CustomerOrderModel.ServiceSectionEditOldCommitedValue = lineItem.StockCommited;
                                $scope.CustomerOrderModel.ServiceSectionEditOldAvailableValue = lineItem.AvailablePart;
                                $scope.CustomerOrderModel.ServiceSectionEditOldQtyValue = lineItem.QtyNeeded;
                                if (!(lineItem.IsFee || lineItem.IsLabour)) {
                                    var vendorId = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndex].SOKH.SOLIList[index].VendorId;
                                    $scope.CustomerOrderModel.getVendorOrderBySOlIVendorId(vendorId);
                                }
                            }
                        } else {
                            $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].isEdit = true;
                        }
                        setTimeout(function() {
                            elementId = '#ServiceOrderSection' + soIndex + ' #CO_ItemGrid_gid_container';
                            angular.element(elementId).find('input[type=text]').not('.descEditInput').filter(':visible:first').focus();
                        }, 10);
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                } else {
                    if (IsparentUpdate) {
                        var soKHItemJSON = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndexToUpdate];
                        if (!soKHItemJSON.IsFixedPrice) {
                            SOHeaderService.updateSOKHLineItems(angular.toJson(soKHItemJSON), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                                if (successfulSearchResult.error.ResponseCode == '300') {
                                    Notification.error(successfulSearchResult.error.ResponseMeassage);
                                }
                                $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                                $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult.SOList[soIndex];
                                $scope.CustomerOrderModel.setServiceOrderData();
                                $scope.CustomerOrderModel.resetServiceOrderData();
                                $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                if (refreshEditMode) {
                                    $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                }
                                $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                                $scope.CustomerOrderModel.COInvoiceHeaderId = ((successfulSearchResult.coInvoiceHeaderRec == null) ? ' ' : successfulSearchResult.coInvoiceHeaderRec.COInvoiceHeaderId);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                            }, function(errorSearchResult) {
                                responseData = errorSearchResult;
                            });
                        } else {
                            $scope.CustomerOrderModel.createGridEditItem(soIndex);
                        }
                    } else {
                        var lineItemJSON = $scope.CustomerOrderModel.SOHeaderList[soIndex].SOGridItems[parentIndexToUpdate].SOKH.SOLIList[childIndexToUpdate];
                        SOHeaderService.updateSOLineItems(angular.toJson(lineItemJSON), $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                            if (successfulSearchResult.length > 0 && successfulSearchResult[0].DealId != undefined && successfulSearchResult[0].DealId != null) {
                                $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult;
                                $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                                $scope.CustomerOrderModel.StockUnitMap();
                                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.SOHeaderList[soIndex].SOHeaderInfo.Id, 'soHeader,soItemGrid,checkOut,specialOrder').then(function(successfulSearchResult1) {
                                    if (successfulSearchResult1.SOList.length > 0) {
                                        $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult1);
                                        $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult1.SOList[0];
                                        $scope.CustomerOrderModel.setServiceOrderData();
                                        $scope.CustomerOrderModel.resetServiceOrderData();
                                        $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                        $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult1.specialOrderList);
                                        $scope.CustomerOrderModel.createGridEditItem(soIndex);
                                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                                    }
                                }, function(errorSearchResult) {
                                    responseData = errorSearchResult;
                                });
                            } else {
                                $scope.CustomerOrderModel.bindOrderTotals(successfulSearchResult);
                                $scope.CustomerOrderModel.SOHeaderList[soIndex] = successfulSearchResult.SOList[soIndex];
                                $scope.CustomerOrderModel.setServiceOrderData();
                                $scope.CustomerOrderModel.resetServiceOrderData();
                                $scope.CustomerOrderModel.resetCauseConcernCorrection();
                                $scope.CustomerOrderModel.UpdateSpecialOrder(successfulSearchResult.specialOrderList);
                                $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                            }
                            if (refreshEditMode) {
                                $scope.CustomerOrderModel.createGridEditItem(soIndex);
                            }
                        }, function(errorSearchResult) {
                            responseData = errorSearchResult;
                        });
                    }
                }
            }
            $scope.CustomerOrderModel.getVendorOrderBySOlIVendorId = function(vendorId) {
                $scope.CustomerOrderModel.VendorOrderListByVendorId = []
                SOHeaderService.getVendorOrderByVendorId(vendorId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.VendorOrderListByVendorId = successfulSearchResult;
                })
            }
            $scope.CustomerOrderModel.getServiceOrderList = function() {
                $scope.CustomerOrderModel.serviceOrderList = [];
                var serviceOrder = [];
                $scope.CustomerOrderModel.AllSectionList = [];
                $scope.CustomerOrderModel.AllSectionList.push({
                    'Name': 'Merchandise',
                    'Id': 'Merchandise'
                })
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    $scope.CustomerOrderModel.serviceOrderList.push({
                        'SectionID': '#ServiceOrderSection' + i,
                        'Name': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Name,
                        'Id': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Id
                    })
                    if (!$rootScope.GroupOnlyPermissions['Service job']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) {
                        serviceOrder.push({
                            'display': false
                        });
                    } else if (!$rootScope.GroupOnlyPermissions['Internal Service']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service')) {
                        serviceOrder.push({
                            'display': false
                        });
                    } else {
                        serviceOrder.push({
                            'display': true
                        });
                    }
                    if (!($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Signed Out')) {
                        $scope.CustomerOrderModel.AllSectionList.push({
                            'Name': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Name,
                            'Id': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Id
                        });
                    }
                }
                $scope.CustomerOrderModel.displaySections.ServiceOrder = serviceOrder;
            }
            $scope.CustomerOrderModel.createTimePickerList = function() {
                $scope.CustomerOrderModel.timePickerList = [];
                $scope.CustomerOrderModel.timePickerList.push('12:00 AM');
                $scope.CustomerOrderModel.timePickerList.push('12:30 AM');
                for (var i = 1; i <= 11; i++) {
                    var time = i <= 9 ? '0' + i : i;
                    if (time != 0) {
                        $scope.CustomerOrderModel.timePickerList.push(time + ':00 AM');
                    }
                    if (time != 12) {
                        $scope.CustomerOrderModel.timePickerList.push(time + ':30 AM');
                    }
                }
                $scope.CustomerOrderModel.timePickerList.push('12:00 PM');
                $scope.CustomerOrderModel.timePickerList.push('12:30 PM');
                for (var i = 1; i <= 11; i++) {
                    var time = i <= 9 ? '0' + i : i;
                    if (time != 0) {
                        $scope.CustomerOrderModel.timePickerList.push(time + ':00 PM');
                    }
                    if (time != 12) {
                        $scope.CustomerOrderModel.timePickerList.push(time + ':30 PM');
                    }
                }
            }
            $scope.CustomerOrderModel.createTimePickerList();
            $scope.CustomerOrderModel.resetServiceOrderData = function() {
                if ($scope.CustomerOrderModel.SOHeaderList != undefined) {
                    for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                        var COUId = $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.COUId;
                        $scope.CustomerOrderModel.setCurrentCOU(COUId, i);
                        $scope.CustomerOrderModel.setCurrentProvider($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.ProviderId, i);
                    }
                }
            }
            $scope.CustomerOrderModel.setServiceOrderData = function() {
                $scope.CustomerOrderModel.SOHeaderListCopy = angular.copy($scope.CustomerOrderModel.SOHeaderList);
                angular.forEach($scope.CustomerOrderModel.SOHeaderList, function(value, key) {
                    value.SOHeaderInfo.selectedTime = $scope.CustomerOrderModel.getTimeFromSFformat(value.SOHeaderInfo.PromisedBy);
                    value.SOHeaderInfo.selectedDate = $scope.CustomerOrderModel.getDateFromSFformat(value.SOHeaderInfo.PromisedBy);
                    value.SOHeaderInfo.CategoryNameStr = value.SOHeaderInfo.CategoryName;
                });
            }
            $scope.CustomerOrderModel.getProviderInfo = function(providerId) {
                SOHeaderService.getProviderInformation(providerId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.VendorInfo = successfulSearchResult.VendorDetailRec;
                    $scope.CustomerOrderModel.getVendorInfo();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.isPreferredActive = function(label, key) {
                if ($scope.CustomerOrderModel.VendorInfo[label] == key) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.getVendorInfo = function() {
                $scope.CustomerOrderModel.vendorInfoJSON = [{
                    Label: 'CALL (Work)',
                    Value: $scope.CustomerOrderModel.VendorInfo.WorkNumber,
                    IsSelected: false,
                    Type: 'Phone',
                    isPreferred: $scope.CustomerOrderModel.isPreferredActive('PreferredPhone', 'WorkNumber')
                }, {
                    Label: 'SEND EMAIL (Work)',
                    Value: $scope.CustomerOrderModel.VendorInfo.WorkEmail,
                    IsSelected: false,
                    Type: 'Email',
                    isPreferred: $scope.CustomerOrderModel.isPreferredActive('PreferredEmail', 'WorkEmail')
                }, {
                    Label: 'CALL (OTHER)',
                    Value: $scope.CustomerOrderModel.VendorInfo.OtherPhone,
                    IsSelected: false,
                    Type: 'Phone',
                    isPreferred: $scope.CustomerOrderModel.isPreferredActive('PreferredPhone', 'OtherPhone')
                }, {
                    Label: 'SEND EMAIL (OTHER)',
                    Value: $scope.CustomerOrderModel.VendorInfo.OtherEmail,
                    IsSelected: false,
                    Type: 'Email',
                    isPreferred: $scope.CustomerOrderModel.isPreferredActive('PreferredEmail', 'OtherEmail')
                }];
            }
            $scope.CustomerOrderModel.paymentOption = function(paymentMode) {
                $scope.CustomerOrderModel.Payment_method = paymentMode;
            }
            $scope.CustomerOrderModel.populateLeftSideHeadingLables = function() {
                $scope.CustomerOrderModel.LeftSideHeadingLables = {};
                $scope.CustomerOrderModel.SectionList = [];
                var currentHeadingSequenceIndex = 65;
                $scope.CustomerOrderModel.AllSectionList = [];
                $scope.CustomerOrderModel.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
                $scope.CustomerOrderModel.SectionList.push({
                    'refrenceId': null,
                    'item': 'Info Section',
                    'relatedSection': 'CustomerSection',
                    'sectionType': [{
                        'Object': 'Customer:',
                        'Value': 'Customer'
                    }, {
                        'Object': 'User:',
                        'Value': 'User'
                    }, {
                        'Object': 'Merchandise:',
                        'Value': 'Part__c'
                    }, {
                        'Object': 'Kit:',
                        'Value': 'Kit_Header__c'
                    }, {
                        'Object': 'Fee:',
                        'Value': 'Fee__c'
                    }],
                    'index': null
                });
                if ($scope.CustomerOrderModel.DealInfo != null && $scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.length != 0 && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Deal'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Deal',
                        'relatedSection': 'DealSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if ($scope.CustomerOrderModel.IsLoadFinancingSection && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1 && $scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.DealType == 'Financed') {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Financing'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Financing',
                        'relatedSection': 'DealFinancingSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if (($scope.CustomerOrderModel.DealMerchandiseList != undefined && $scope.CustomerOrderModel.DealMerchandiseList.length != 0 && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1)) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['DealMerchandise'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Deal Merchandise',
                        'relatedSection': 'DealMerchandiseSection',
                        'sectionType': [{
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }, {
                            'Object': 'Kit:',
                            'Value': 'Kit_Header__c'
                        }, {
                            'Object': 'Fee:',
                            'Value': 'Fee__c'
                        }],
                        'index': null
                    });
                    if (!$rootScope.GroupOnlyPermissions['Merchandise']['view']) {
                        $scope.CustomerOrderModel.displaySections['DealMerchandise'] = false;
                    } else {
                        $scope.CustomerOrderModel.displaySections['DealMerchandise'] = true;
                    }
                }
                if ($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_ServiceOrder') > -1) {
                    for (i = 0; i < $scope.CustomerOrderModel.serviceOrderList.length; i++) {
                        $scope.CustomerOrderModel.LeftSideHeadingLables['ServiceOrder' + i] = String.fromCharCode(currentHeadingSequenceIndex++);
                        $scope.CustomerOrderModel.SectionList.push({
                            'item': $scope.CustomerOrderModel.serviceOrderList[i].Name,
                            'relatedSection': 'ServiceOrderSection' + i,
                            'sectionType': [{
                                'Object': 'Merchandise:',
                                'Value': 'Part__c'
                            }, {
                                'Object': 'Kit:',
                                'Value': 'Kit_Header__c'
                            }, {
                                'Object': 'Labor:',
                                'Value': 'Labour_Code__c'
                            }, {
                                'Object': 'Fee:',
                                'Value': 'Fee__c'
                            }],
                            'index': i
                        });
                        if (!($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus == 'Signed Out')) {
                            $scope.CustomerOrderModel.AllSectionList.push({
                                'Name': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Name,
                                'Id': $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.Id
                            });
                        }
                    }
                    if ($scope.CustomerOrderModel.serviceOrderList.length == 0) {
                        $scope.CustomerOrderModel.AllSectionList.push({
                            'Name': '+ Add New Service Job',
                            'Id': '+ Add New Service Job'
                        });
                    }
                }
                if (($scope.CustomerOrderModel.MerchandiseItems != undefined && ($scope.CustomerOrderModel.MerchandiseItems.length != 0 || $scope.CustomerOrderModel.MerchandiseGhostItems.length != 0) && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Merchandise') > -1) || (($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Cash Sale') && $scope.CustomerOrderModel.hideMerchandiseSection == false)) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Merchandise'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Merchandise',
                        'relatedSection': 'MerchandiseSection',
                        'sectionType': [{
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }, {
                            'Object': 'Kit:',
                            'Value': 'Kit_Header__c'
                        }, {
                            'Object': 'Fee:',
                            'Value': 'Fee__c'
                        }],
                        'index': null
                    });
                }
                $scope.CustomerOrderModel.AllSectionList.push({
                    'Name': 'Merchandise',
                    'Id': 'Merchandise'
                });
                if (($scope.CustomerOrderModel.MerchandiseItems != undefined && ($scope.CustomerOrderModel.MerchandiseItems.length != 0 || $scope.CustomerOrderModel.MerchandiseGhostItems.length != 0) && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Merchandise') > -1) || (($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Cash Sale') && $scope.CustomerOrderModel.hideMerchandiseSection == false)) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['M_Items'] = 1;
                }
                if ($scope.CustomerOrderModel.SpecialOrder != undefined && ($scope.CustomerOrderModel.SpecialOrder.length != 0) && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Special_Orders') > -1) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Special_Orders'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Special Order',
                        'relatedSection': 'SpecialOrderSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if (($scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deposits') > -1) && !($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed' && $scope.CustomerOrderModel.Deposits.length == 0)) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Deposits'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Deposit',
                        'relatedSection': 'DepositSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length != 0 && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Checkout') > -1 && $scope.CustomerOrderModel.showCheckoutSection == true && $rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify']) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Checkout'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'CheckOut',
                        'relatedSection': 'CheckoutSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Closed' && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Part Sale' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Service Order' || $scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Unit Deal')) {
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': '+ Add New Service Job',
                        'relatedSection': 'None',
                        'sectionType': '',
                        'index': i
                    });
                }
                if (!($scope.CustomerOrderModel.DealInfo != null && $scope.CustomerOrderModel.DealInfo != undefined && $scope.CustomerOrderModel.DealInfo.length != 0 && $scope.CustomerOrderModel.CoTypesToVisibleSectionsMap[$scope.CustomerOrderModel.coHeaderDetails.SellingGroup].indexOf('Show_Deal') > -1) && $scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Closed' && $scope.CustomerOrderModel.coHeaderDetails.COType == 'Customer') {
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': '+ Add New Deal',
                        'relatedSection': 'DealSection',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
                if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length != 0) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['C_Items'] = 1;
                }
                if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length != 0) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['C_Payments'] = 2;
                }
                if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length != 0) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['C_Finalize_Order'] = 3;
                }
                if ($scope.CustomerOrderModel.InvoiceHistory != undefined && $scope.CustomerOrderModel.InvoiceHistory.length != 0) {
                    $scope.CustomerOrderModel.LeftSideHeadingLables['Invoice_History'] = String.fromCharCode(currentHeadingSequenceIndex++);
                    $scope.CustomerOrderModel.SectionList.push({
                        'item': 'Invoice History',
                        'relatedSection': 'InvoiceHistory',
                        'sectionType': [{
                            'Object': 'Customer:',
                            'Value': 'Customer'
                        }, {
                            'Object': 'User:',
                            'Value': 'User'
                        }, {
                            'Object': 'Merchandise:',
                            'Value': 'Part__c'
                        }],
                        'index': i
                    });
                }
            }
            $scope.CustomerOrderModel.getDateFromSFformat = function(salesforceDate) {
                if (salesforceDate == null) {
                    return $scope.CustomerOrderModel.getCurrentDate();
                }
                var date = salesforceDate.substring(0, salesforceDate.indexOf(" "));
                return date;
            }
            $scope.CustomerOrderModel.getTimeFromSFformat = function(salesforceDate) {
                if (salesforceDate == null) {
                    return '12:00 AM';
                }
                var time = salesforceDate.substring(salesforceDate.indexOf(" ") + 1, salesforceDate.length);
                return time;
            }
            $scope.CustomerOrderModel.setCurrentCOU = function(COUId, index) {
                if ($scope.CustomerOrderModel.SOHeaderList[index] != undefined) {
                    if ($scope.CustomerOrderModel.COUList != undefined) {
                        for (var i = 0; i < $scope.CustomerOrderModel.COUList.length; i++) {
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU = {};
                            if ($scope.CustomerOrderModel.COUList[i].Id == COUId) {
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU = $scope.CustomerOrderModel.COUList[i];
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.COUId = $scope.CustomerOrderModel.COUList[i].Id;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.MakeName = $scope.CustomerOrderModel.COUList[i].MakeName;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ModelName = $scope.CustomerOrderModel.COUList[i].ModelName;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitId = $scope.CustomerOrderModel.COUList[i].UnitId;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.SubModelName = $scope.CustomerOrderModel.COUList[i].SubModelName;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.VIN = $scope.CustomerOrderModel.COUList[i].VIN;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.StatusColor = $scope.CustomerOrderModel.COUList[i].StatusColor;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.StockId = $scope.CustomerOrderModel.COUList[i].StockId;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitStatus = $scope.CustomerOrderModel.COUList[i].Status;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status = $scope.CustomerOrderModel.COUList[i].Status;
                                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitType = $scope.CustomerOrderModel.COUList[i].UnitType;
                                break;
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.COUId == COUId && COUId != null) {
                        if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU == undefined) {
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU = {};
                        }
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.Id = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.COUId;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.color = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.color;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.COUId = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.COUId
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.MakeName = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.MakeName;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.ModelName = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ModelName;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.UnitId = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitId;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.SubModelName = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.SubModelName;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.VIN = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.VIN;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.StatusColor = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.StatusColor;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.StockId = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.StockId;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.UnitStatus = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitStatus;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.Status = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedCOU.UnitType = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.UnitType;
                    }
                    $scope.CustomerOrderModel.SaveserviceInfo(index);
                }
            }
            $scope.CustomerOrderModel.setTradeInCurrentCOU = function(COUId, index) {
                if ($scope.CustomerOrderModel.DealTradeInList[index] == undefined) {
                    return;
                }
                for (var i = 0; i < $scope.CustomerOrderModel.COUList.length; i++) {
                    if ($scope.CustomerOrderModel.COUList[i].Id == COUId) {
                        $scope.CustomerOrderModel.DealTradeInList[index].COUId = COUId;
                        $scope.CustomerOrderModel.DealTradeInList[index].MakeName = $scope.CustomerOrderModel.COUList[i].MakeName;
                        $scope.CustomerOrderModel.DealTradeInList[index].Make = $scope.CustomerOrderModel.COUList[i].Make;
                        $scope.CustomerOrderModel.DealTradeInList[index].Model = $scope.CustomerOrderModel.COUList[i].Model;
                        $scope.CustomerOrderModel.DealTradeInList[index].SubModel = $scope.CustomerOrderModel.COUList[i].SubModel;
                        $scope.CustomerOrderModel.DealTradeInList[index].ModelName = $scope.CustomerOrderModel.COUList[i].ModelName;
                        $scope.CustomerOrderModel.DealTradeInList[index].UnitNumber = $scope.CustomerOrderModel.COUList[i].UnitId;
                        $scope.CustomerOrderModel.DealTradeInList[index].UnitId = $scope.CustomerOrderModel.COUList[i].Id;
                        $scope.CustomerOrderModel.DealTradeInList[index].SubModelName = $scope.CustomerOrderModel.COUList[i].SubModelName;
                        $scope.CustomerOrderModel.DealTradeInList[index].VIN = $scope.CustomerOrderModel.COUList[i].VIN;
                        $scope.CustomerOrderModel.DealTradeInList[index].StatusColor = $scope.CustomerOrderModel.COUList[i].StatusColor;
                        $scope.CustomerOrderModel.DealTradeInList[index].StockId = $scope.CustomerOrderModel.COUList[i].StockId;
                        $scope.CustomerOrderModel.DealTradeInList[index].UnitStatus = $scope.CustomerOrderModel.COUList[i].Status;
                        $scope.CustomerOrderModel.DealTradeInList[index].Status = $scope.CustomerOrderModel.COUList[i].Status;
                        $scope.CustomerOrderModel.DealTradeInList[index].UnitType = $scope.CustomerOrderModel.COUList[i].UnitType;
                        $scope.CustomerOrderModel.DealTradeInList[index].Year = $scope.CustomerOrderModel.COUList[i].Year;
                        break;
                    }
                }
                $scope.CustomerOrderModel.TradeInInfo(index);
            }
            $scope.CustomerOrderModel.TradeInInfo = function(index) {
                if ($scope.CustomerOrderModel.DealTradeInList[index].AgreedValue == undefined || $scope.CustomerOrderModel.DealTradeInList[index].AgreedValue == null || $scope.CustomerOrderModel.DealTradeInList[index].AgreedValue == '') {
                    $scope.CustomerOrderModel.DealTradeInList[index].AgreedValue = 0.00;
                }
                DealService.updateTradeIn($scope.CustomerOrderModel.DealInfo.Id, JSON.stringify($scope.CustomerOrderModel.DealTradeInList[index])).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealTradeInList[index].Id = successfulSearchResult.Id;
                    $scope.CustomerOrderModel.updateDealSummaryTotals(successfulSearchResult);
                    for (var key in successfulSearchResult) {
                        $scope.CustomerOrderModel.DealTradeInList[index][key] = successfulSearchResult[key];
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.setCurrentProvider = function(providerId, index) {
                for (var i = 0; i < $scope.CustomerOrderModel.MasterData.ProviderList.length; i++) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedProvider = {};
                    if ($scope.CustomerOrderModel.MasterData.ProviderList[i].Id == providerId) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedProvider = $scope.CustomerOrderModel.MasterData.ProviderList[i];
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ProviderId = $scope.CustomerOrderModel.MasterData.ProviderList[i].Id;
                        break;
                    }
                }
                $scope.CustomerOrderModel.SaveserviceInfo(index);
            }
            $scope.CustomerOrderModel.setPaymentDealTotalAmount = function() {
                if ($scope.CustomerOrderModel.DealDepositList.length > 0 && ($scope.CustomerOrderModel.isRefundDepositBtnClickedForDealDeposit == true && $scope.CustomerOrderModel.selectedOptionForDealDeposit != 'Please Select') && $scope.CustomerOrderModel.calculateDealDepositTotal() > 0) {
                    $scope.CustomerOrderModel.payment_Deal_TotalAmount = false;
                } else {
                    $scope.CustomerOrderModel.payment_Deal_TotalAmount = true;
                }
            }
            $scope.CustomerOrderModel.resetPaymentDealTotalAmount = function() {
                $scope.CustomerOrderModel.payment_Deal_TotalAmount = false;
            }
            $scope.CustomerOrderModel.editRowTabOutFIProductLineItem = function(index, focusElementId) {
                if ($scope.CustomerOrderModel.DealFinanceList.FIProductList[index].SalesTax == null || $scope.CustomerOrderModel.DealFinanceList.FIProductList[index].SalesTax == '') {
                    $scope.CustomerOrderModel.DealFinanceList.FIProductList[index].SalesTax = 0.00;
                }
                if ($scope.CustomerOrderModel.DealFinanceList.FIProductList[index].Price == null || $scope.CustomerOrderModel.DealFinanceList.FIProductList[index].Price == '') {
                    $scope.CustomerOrderModel.DealFinanceList.FIProductList[index].Price = 0.00;
                }
                $scope.CustomerOrderModel.DealFinanceList.FIProductList[index].Total = parseInt($scope.CustomerOrderModel.DealFinanceList.FIProductList[index].SalesTax) + parseInt($scope.CustomerOrderModel.DealFinanceList.FIProductList[index].Price);
                var fIProductJSON = $scope.CustomerOrderModel.DealFinanceList.FIProductList[index];
                if (event.type == 'blur') {
                    $scope.CustomerOrderModel.BlurcalledForFIProduct = true;
                    setTimeout(function() {
                        if ($scope.CustomerOrderModel.allowBlurForFIProduct == true) {
                            var ValuetoBlur = 'CO_SearchToAdd_value';
                            $scope.CustomerOrderModel.saveFAndIProductLineItem($scope.CustomerOrderModel.DealInfo.Id, fIProductJSON, index);
                        }
                        $scope.CustomerOrderModel.allowBlurForFIProduct = true;
                        $scope.CustomerOrderModel.BlurcalledForFIProduct = false;
                        return;
                    }, 300);
                }
                if (!event.shiftKey && event.keyCode == 9) {
                    $scope.CustomerOrderModel.allowBlurForFIProduct = false;
                    event.preventDefault();
                    $scope.setFocus1();
                    angular.element('#CO_SearchToAdd_value').focus();
                    $scope.CustomerOrderModel.saveFAndIProductLineItem($scope.CustomerOrderModel.DealInfo.Id, fIProductJSON, index);
                    $scope.CustomerOrderModel.editFIProductLineItem(event, index);
                } else if (event.shiftKey && event.keyCode == 9 && focusElementId != null) {
                    event.preventDefault();
                    setTimeout(function() {
                        angular.element(event.target).focus();
                    }, 0);
                } else if (event.shiftKey && event.keyCode == 9) {
                    consol.log('allow blur');
                    $scope.CustomerOrderModel.allowBlurForFIProduct = false;
                    event.preventDefault();
                }
                if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length > 0) {
                    $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                }
            }
            $scope.CustomerOrderModel.editFIProduct = function() {
                if ($scope.CustomerOrderModel.DealFinanceList != undefined) {
                    if ($scope.CustomerOrderModel.DealFinanceList.FIProductList != undefined) {
                        $scope.CustomerOrderModel.FIProductLineItems_editRow = [];
                        for (i = 0; i < $scope.CustomerOrderModel.DealFinanceList.FIProductList.length; i++) {
                            $scope.CustomerOrderModel.FIProductLineItems_editRow.push({
                                isEdit: false,
                                optionSelected: 0
                            });
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.FIProductItemGoAction = function(optionSelected, dealItemId, fIProductId, event) {
                if (optionSelected == 0) {
                    $scope.CustomerOrderModel.removeFIProductItem(dealItemId, fIProductId, event);
                    if ($scope.CustomerOrderModel.CheckOutItems != undefined && $scope.CustomerOrderModel.CheckOutItems.length > 0) {
                        $scope.bindCheckOutList($scope.CustomerOrderModel.CheckOutItems);
                    }
                }
            }
            $scope.CustomerOrderModel.removeFIProductItem = function(dealItemId, fIProductId, event) {
                DealService.removeFIProductItems(dealItemId, fIProductId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealFinanceList.FIProductList = successfulSearchResult.FIProductList;
                    $scope.CustomerOrderModel.editFIProduct();
                    $scope.CustomerOrderModel.calculateFIProductTotal();
                    $scope.CustomerOrderModel.calculateEstimatedPayment();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.editFIProductLineItem = function(event, index) {
                if ($scope.CustomerOrderModel.BlurcalledForFIProduct) {
                    $scope.CustomerOrderModel.allowBlurForFIProduct = false;
                }
                if (event.target.nodeName == 'I' || $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                if ($scope.CustomerOrderModel.DealFinanceList.Status == 'Approved' || $scope.CustomerOrderModel.DealFinanceList.Status == 'Paid') {
                    return;
                }
                if (event.target.closest("tr.edit_panel") != null && event.target.closest("tr.edit_panel") != '') {
                    return;
                }
                if (event.target['type'] == 'text' && event.type != 'keydown') {
                    return;
                }
                if ((event.target['type'] == 'text' || event.target['type'] == 'radio' || event.target['type'] == 'select-one' || event.target['type'] == 'select' || event.target['type'] == 'button' || event.target['type'] == 'submit' || event.target['type'] == 'checkbox' || event.target['type'] == 'span') && event.type != 'keydown') {
                    return;
                }
                var isEditModeEnabled = false;
                var lineItem = [];
                for (i = 0; i < $scope.CustomerOrderModel.FIProductLineItems_editRow.length; i++) {
                    if ($scope.CustomerOrderModel.FIProductLineItems_editRow[i].isEdit == true) {
                        if ($scope.CustomerOrderModel.DealFinanceList.FIProductList[i].SalesTax == null || $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].SalesTax == '') {
                            $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].SalesTax = 0.00;
                        }
                        if ($scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price == null || $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price == '') {
                            $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price = 0.00;
                        }
                        $scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Total = parseInt($scope.CustomerOrderModel.DealFinanceList.FIProductList[i].SalesTax) + parseInt($scope.CustomerOrderModel.DealFinanceList.FIProductList[i].Price);
                        lineItem = $scope.CustomerOrderModel.DealFinanceList.FIProductList[i];
                        $scope.CustomerOrderModel.FIProductLineItems_editRow[i].isEdit = false;
                        index = i;
                        isEditModeEnabled = true;
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.FIProductLineItems_editRow[index].isEdit = true;
                    setTimeout(function() {
                        elementId = '#FAndIProductsSectionGrid';
                        angular.element(elementId).find('input[type=text]').filter(':visible:first').focus();
                    }, 10);
                } else {
                    lineItem.DealId = $scope.CustomerOrderModel.DealInfo.Id;
                    $scope.CustomerOrderModel.saveFAndIProductLineItem(lineItem.DealId, lineItem, index);
                }
            }
            $scope.CustomerOrderModel.saveFAndIProductLineItem = function(dealId, result, index) {
                result.DealId = dealId;
                DealService.saveFAndIProductLineItems(dealId, JSON.stringify(result)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealFinanceList.FIProductList[index] = successfulSearchResult;
                    $scope.CustomerOrderModel.FIProductLineItems_editRow[index].isEdit = false;
                    $scope.CustomerOrderModel.calculateEstimatedPayment();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveFAndIProductLineItemFromSta = function(dealId, result) {
                $scope.CustomerOrderModel.fIProductJson = {
                    ProductId: result.Value,
                    DealFinanceId: $scope.CustomerOrderModel.DealFinanceList.Id,
                    DealId: dealId
                };
                DealService.saveFAndIProductLineItems(dealId, JSON.stringify($scope.CustomerOrderModel.fIProductJson)).then(function(successfulSearchResult) {
                    var size = 0;
                    if ($scope.CustomerOrderModel.DealFinanceList.FIProductList == undefined) {
                        size = 0;
                    } else {
                        size = $scope.CustomerOrderModel.DealFinanceList.FIProductList.length;
                    }
                    $scope.CustomerOrderModel.DealFinanceList.FIProductList[size] = successfulSearchResult;
                    $scope.CustomerOrderModel.editFIProduct();
                    $scope.CustomerOrderModel.FIProductLineItems_editRow[size].isEdit = true;
                    $scope.CustomerOrderModel.calculateFIProductTotal();
                    $scope.CustomerOrderModel.calculateEstimatedPayment();
                    setTimeout(function() {
                        angular.element('#FIProduct_Price_Edit_' + size).focus();
                    }, 10);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.setCurrentFinanceCompany = function(financeCompanyId, index) {
                for (var i = 0; i < $scope.CustomerOrderModel.FinanceCompany.length; i++) {
                    if ($scope.CustomerOrderModel.FinanceCompany[i].Id == financeCompanyId) {
                        $scope.CustomerOrderModel.DealFinanceList.FinanceCompanyName = $scope.CustomerOrderModel.FinanceCompany[i].Name;
                        $scope.CustomerOrderModel.DealFinanceList.FinanceCompanyPhone = $scope.CustomerOrderModel.FinanceCompany[i].Phone;
                        $scope.CustomerOrderModel.DealFinanceList.FinanceCompanyEmail = $scope.CustomerOrderModel.FinanceCompany[i].Email;
                        $scope.CustomerOrderModel.DealFinanceList.FinanceCompanyAccountNumber = $scope.CustomerOrderModel.FinanceCompany[i].AccountNumber;
                        $scope.CustomerOrderModel.DealFinanceList.FinanceCompanyId = $scope.CustomerOrderModel.FinanceCompany[i].Id;
                        break;
                    }
                }
                $scope.CustomerOrderModel.SaveFinanceCompanyInfo();
            }
            $scope.CustomerOrderModel.isEmptyFinanceCompany = function(FinanceCompanyId) {
                if (FinanceCompanyId == null) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.SaveFinanceCompanyInfo = function() {
                $scope.CustomerOrderModel.DealFinanceList.DealId = $scope.CustomerOrderModel.DealInfo.Id;
                SOHeaderService.updateDealFinanceDetails($scope.CustomerOrderModel.DealInfo.Id, angular.toJson($scope.CustomerOrderModel.DealFinanceList)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealFinanceList = successfulSearchResult;
                    $scope.CustomerOrderModel.calculateEstimatedPayment();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.getSFformatDate = function(currentDate, currentTime) {
                var dateTime = currentDate + ' ' + currentTime;
                return dateTime;
            }
            $scope.CustomerOrderModel.getCurrentDate = function() {
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth() + 1;
                var yyyy = today.getFullYear();
                if (dd < 10) {
                    dd = '0' + dd
                }
                if (mm < 10) {
                    mm = '0' + mm
                }
                var today = mm + '/' + dd + '/' + yyyy;
                return today;
            }
            $scope.CustomerOrderModel.toggleIsPromisedByAmPm = function(index, value) {
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.IsPromisedByAmPm == value) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.IsPromisedByAmPm = '';
                } else {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.IsPromisedByAmPm = value;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedTime = '12:00 ' + value;
                }
                $scope.CustomerOrderModel.validatePromisedByDate(index);
            }
            $scope.CustomerOrderModel.updatedJobTypeSOIndex = null;
            $scope.CustomerOrderModel.updateProvider = function(index) {
                for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionTypeId == $scope.CustomerOrderModel.MasterData.TTList[i].Id) {
                        if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Quote' && $scope.CustomerOrderModel.MasterData.TTList[i].Type != 'Quote') {
                            $scope.CustomerOrderModel.updatedJobTypeSOIndex = index;
                            $scope.CustomerOrderModel.openActivateQuoteConfirmModal();
                        } else {
                            $scope.CustomerOrderModel.changeProviderList(index);
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.changeProviderList = function(index) {
                $scope.CustomerOrderModel.SOHeaderList[index]['ShowCauseConcernCorrection'] = false;
                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Provider = {};
                for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionTypeId == $scope.CustomerOrderModel.MasterData.TTList[i].Id) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionType = $scope.CustomerOrderModel.MasterData.TTList[i].Type;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionTypeLabel = $scope.CustomerOrderModel.MasterData.TTList[i].CodeLabel;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Provider = $scope.CustomerOrderModel.MasterData.TTList[i].ProviderList[0];
                    }
                }
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionType != 'Third-Party') {
                    for (var i = 0; i < $scope.CustomerOrderModel.pinnedItems.length; i++) {
                        if ($scope.CustomerOrderModel.pinnedItems[i] == 'Provider') {
                            $scope.CustomerOrderModel.pinnedItems.splice(i, 1);
                        }
                    }
                }
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionType != 'Internal') {
                    for (var i = 0; i < $scope.CustomerOrderModel.pinnedItems.length; i++) {
                        if ($scope.CustomerOrderModel.pinnedItems[i] == 'Category') {
                            $scope.CustomerOrderModel.pinnedItems.splice(i, 1);
                        }
                    }
                } else {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryNameStr = $scope.CustomerOrderModel.MasterData.DefaultInternalCategoryName;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryId = $scope.CustomerOrderModel.MasterData.DefaultInternalCategoryId;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryName = $scope.CustomerOrderModel.MasterData.DefaultInternalCategoryName;
                }
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Quote' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionTypeLabel != 'Quote') {
                    $scope.CustomerOrderModel.activateQuote();
                } else if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Quote' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionTypeLabel == 'Quote') {
                    $scope.CustomerOrderModel.setCOStatusAsQuote();
                }
                $scope.CustomerOrderModel.SaveserviceInfo(index);
                SOHeaderService.getSOHeaderDetails($scope.CustomerOrderModel.coHeaderId, 'checkOut').then(function(successfulResult) {
                    $scope.bindCheckOutList(successfulResult.coInvoiceItemRecs);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                });
                $scope.CustomerOrderModel.updatedJobTypeSOIndex = null;
            }
            $scope.CustomerOrderModel.addAndRemoveFromMultiSelect = function(event, index, modelName, ModelKey, fieldLabel) {
                var isAlreadyExist = false;
                var fieldValue = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[modelName];
                if ((event.keyCode == 13 || event.keyCode == 9) && fieldValue != '' && fieldValue != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[ModelKey].length; i++) {
                        if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[ModelKey][i] == $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[modelName]) {
                            isAlreadyExist = true;
                            Notification.error('Same ' + fieldLabel + ' Already Exist');
                        }
                    }
                    if (!isAlreadyExist) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[ModelKey].push($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[modelName]);
                        $scope.CustomerOrderModel.SaveserviceInfo(index);
                    }
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[modelName] = '';
                }
                var length = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[ModelKey].length;
                if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[ModelKey].splice(length - 1, 1);
                    $scope.CustomerOrderModel.SaveserviceInfo(index);
                }
                $scope.CustomerOrderModel.editLineItemsForCauseConcernCorrection();
            }
            $scope.CustomerOrderModel.removeFromMultiSelect = function(index, parentIndex, ModelKey) {
                if ($scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Signed Out' || $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo.WorkStatus == 'Invoiced') {
                    Notification.error($Label.Generic_Saved);
                    return;
                }
                $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOHeaderInfo[ModelKey].splice(index, 1);
                $scope.CustomerOrderModel.SaveserviceInfo(parentIndex);
            }
            $scope.CustomerOrderModel.addAndRemoveFromNotesMultiSelect = function(event, index, modelName, ModelKey, fieldLabel) {
                var isAlreadyExist = false;
                var fieldValue = $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName];
                if ((event.keyCode == 13 || event.keyCode == 9) && fieldValue != '' && fieldValue != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].length; i++) {
                        if ($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey][i] == $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName]) {
                            isAlreadyExist = true;
                            Notification.error('Same ' + fieldLabel + ' Already Exist');
                        }
                    }
                    if (!isAlreadyExist) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].push($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName]);
                        $scope.CustomerOrderModel.saveServiceReview(index);
                    }
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[modelName] = '';
                }
                var length = $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].length;
                if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec[ModelKey].splice(length - 1, 1);
                    $scope.CustomerOrderModel.saveServiceReview(index);
                }
                $scope.CustomerOrderModel.editLineItemsForManualNotes();
            }
            $scope.CustomerOrderModel.removeNotesFromMultiSelect = function(index, parentIndex, ModelKey) {
                $scope.CustomerOrderModel.SOHeaderList[parentIndex].SOReviewRec[ModelKey].splice(index, 1);
                $scope.CustomerOrderModel.saveServiceReview(parentIndex);
            }
            $scope.CustomerOrderModel.isServiceOrderDisabled = function(index) {
                if ($scope.CustomerOrderModel.SOHeaderList[index]) {
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ClaimStatus == 'Ready to Submit') {
                        return true;
                    } else if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Signed Out' || $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                        return true;
                    }
                }
                return false;
            }
            $scope.CustomerOrderModel.workStatusCheck = function(workStatus, index) {
                if (workStatus == 'Set As Complete') {
                    if ($scope.CustomerOrderModel.SOHeaderList[index] != undefined && ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus != 'Complete' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus != 'Signed Out' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus != 'Reviewed' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus != 'Invoiced')) {
                        return true;
                    } else {
                        return false;
                    }
                } else if (workStatus == 'Re-Open For Work') {
                    if ($scope.CustomerOrderModel.SOHeaderList[index] != undefined && ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Signed Out' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Invoiced')) {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            $scope.CustomerOrderModel.changeWorkStatusSignOut = function(soHeaderIndex) {
                var workLogInfo = {
                    oldStatus: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.WorkStatus,
                    newStatus: 'Signed Out',
                    soHeaderId: $scope.CustomerOrderModel.SOHeaderList[soHeaderIndex].SOHeaderInfo.Id,
                    type: 'Work'
                };
                CustomerInfoService.insertLogRecord(JSON.stringify(workLogInfo), workLogInfo.type).then(function(successfulSearchResult) {
                    $scope.LoadCustomerOrder();
                    Notification.success('Service Job Work Status Signed Out Successfully');
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            }
            $scope.CustomerOrderModel.claimStatusCheck = function(claimStatus, index) {
                if (claimStatus == 'Claim Submission') {
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ClaimStatus == 'Unsubmitted' && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus != 'Signed Out') {
                        return true;
                    } else {
                        return false;
                    }
                } else if (claimStatus == 'Claim Response') {
                    if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ClaimStatus == 'Submitted') {
                        return true;
                    } else {
                        return false;
                    }
                }
            }
            $scope.CustomerOrderModel.ServiceFieldsFilter = {
                SOCategory: [{
                    Field: "Type__c",
                    Value: "Internal Expense",
                    FilterObject: "Category__c"
                }]
            };
            $scope.$on('autoCompleteSelectCallback', function(event, args) {
                if ($scope.CustomerOrderModel.isWizardMode) {} else {
                    var obejctType = args.ObejctType.toUpperCase();
                    var searchResult = args.SearchResult;
                    var validationKey = args.ValidationKey;
                    var index = args.Index;
                    if (!isNaN(index)) {
                        if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryNameStr == $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryName) {
                            $scope.CustomerOrderModel.SaveserviceInfo(index);
                            return;
                        } else if (searchResult == null) {
                            Notification.error("No matching " + args.ObejctType + " records found!");
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryName = "";
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryId = null;
                            return;
                        }
                        var objectsMapping = [{
                            CATEGORY: {
                                Id: "CategoryId",
                                Name: "CategoryName",
                                selectMethod: null
                            }
                        }];
                        if (objectsMapping[0][obejctType] != null) {
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[objectsMapping[0][obejctType]["Id"]] = searchResult.originalObject.Value;
                            $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo[objectsMapping[0][obejctType]["Name"]] = searchResult.originalObject.Name;
                        }
                    }
                }
            });
            $scope.CustomerOrderModel.pinnedItemsMapping = {
                'Cause': ['KitHeaderCause', 'ManualCause'],
                'Concern': ['KitHeaderConcern', 'ManualConcern'],
                'Correction': ['KitHeaderCorrection', 'ManualCorrection'],
                'Estimated Hours': ['EstimatedHours'],
                'Job Type': ['TransactionTypeLabel'],
                'Category': ['CategoryNameStr'],
                'Stock': ['Stock']
            }
            $scope.CustomerOrderModel.addRemovePinnedItem = function(value) {
                var array = $scope.CustomerOrderModel.pinnedItems;
                var isExist = false;
                array.forEach(function(result, index) {
                    if (result === value) {
                        array.splice(index, 1);
                        isExist = true;
                    }
                });
                if (!isExist) {
                    $scope.CustomerOrderModel.pinnedItems.push(value);
                }
                if (array.length > 3) {
                    array.splice(0, 1);
                }
                $scope.CustomerOrderModel.SavepinnedItemsToServer();
            }
            $scope.CustomerOrderModel.checkItemIsPinned = function(value) {
                var array = $scope.CustomerOrderModel.pinnedItems;
                var isExist = false;
                array.forEach(function(result, index) {
                    if (result === value) {
                        isExist = true;
                    }
                });
                return isExist;
            }
            $scope.CustomerOrderModel.MerchSelected = function(SoHeaderIndex, SoKitHeaderIndex, SoLineItemIndex) {
                //FIXME
            }
            $scope.CustomerOrderModel.showSONameEditMode = function(index, sectioninfo) {
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Reviewed' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Complete' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Invoiced' || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Signed Out' || (!$rootScope.GroupOnlyPermissions['Service job']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup != 'Internal Service')) || (!$rootScope.GroupOnlyPermissions['Internal Service']['view'] && ($scope.CustomerOrderModel.coHeaderDetails.SellingGroup == 'Internal Service'))) {
                    return;
                }
                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.isSONameEdit = true;
                if (sectioninfo == "SectionList") {
                    setTimeout(function() {
                        angular.element('#SO_Section_Name_Edit_' + index).focus();
                    }, 100);
                } else {
                    setTimeout(function() {
                        angular.element('#SO_Header_Name_Edit_' + index).focus();
                    }, 100);
                }
            }
            $scope.CustomerOrderModel.UpdateSOName = function(index) {
                var isEmptySoName = false;
                var isDuplicateSoName = false;
                var isNameChanged = true;
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Name == null || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Name == '') {
                    isEmptySoName = true;
                } else {
                    for (i = 0; i < $scope.CustomerOrderModel.serviceOrderList.length; i++) {
                        if (($scope.CustomerOrderModel.serviceOrderList[i].Name).toUpperCase() == ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Name).toUpperCase()) {
                            if (i != index) {
                                isDuplicateSoName = true;
                                isNameChanged = true;
                                break;
                            } else {
                                isNameChanged = false;
                            }
                        }
                    }
                }
                if (!isDuplicateSoName && !isEmptySoName && isNameChanged) {
                    $scope.CustomerOrderModel.serviceOrderList[index].Name = $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Name;
                    $scope.CustomerOrderModel.getServiceOrderList();
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.isSONameEdit = false;
                    $scope.CustomerOrderModel.saveSONameToServer($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Name, $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Id);
                } else {
                    if (isDuplicateSoName) {
                        Notification.error($Label.CustomerOrder_Js_Service_Already_Exists);
                        isDuplicateSoName = false;
                    } else if (isEmptySoName) {
                        Notification.error($Label.CustomerOrder_Js_Enter_Service_Job_Name);
                        isEmptySoName = false;
                    } else if (!isNameChanged) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.isSONameEdit = false;
                    }
                    setTimeout(function() {
                        angular.element('#SO_Header_Name_Edit_' + index).focus();
                        angular.element('#SO_Header_Name_Edit_' + index).css("border", "1px solid #d9534f");
                    }, 100);
                }
                for (i = 0; i < $scope.CustomerOrderModel.SectionList.length; i++) {
                    if ($scope.CustomerOrderModel.SectionList[i].relatedSection == $scope.CustomerOrderModel.SelectedSection['relatedSection']) {
                        $scope.CustomerOrderModel.SelectedSection = $scope.CustomerOrderModel.SectionList[i];
                    }
                }
            }
            $scope.CustomerOrderModel.updateDealFinanceStatus = function(dealFinanceStatus) {
                CustomerInfoService.updateDealFinanceStatus($scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.DealInfo.Id, $scope.CustomerOrderModel.DealFinanceList, dealFinanceStatus).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealFinanceList.Status = dealFinanceStatus;
                    $scope.CustomerOrderModel.allowCheckoutSort = true;
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    Notification.success($Label.Generic_Saved);
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            }
            $scope.CustomerOrderModel.selectalltext = function(index, sectioninfo) {
                if (sectioninfo == "SectionList") {
                    angular.element('#SO_Section_Name_Edit_' + index).select();
                } else {
                    angular.element('#SO_Header_Name_Edit_' + index).select();
                }
            }
            $scope.CustomerOrderModel.SavepinnedItemsToServer = function() {
                var pinnedItemsJson = {
                    PinnedItemList: $scope.CustomerOrderModel.pinnedItems
                };
                SOHeaderService.savePinnedItems(JSON.stringify(pinnedItemsJson)).then(function(successfulSearchResult) {
                    //FIXME
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.PrintDealInfo = function(dealId) {
                if (!$rootScope.GroupOnlyPermissions['Deal']['view']) {
                    return;
                }
                var myWindow = window.open(url + "DealDocumentPrint?id=" + dealId, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.PrintPriview = function(soHeaderId) {
                var myWindow = window.open(url + "SOHeaderPrintPreview?id=" + soHeaderId, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.OpenPrintServiceWorkSheetPopUp = function(COHeaderId) {
                loadState($state, 'CustomerOrder.PrintServiceWorksheetPopUp', {
                    PrintServiceWorksheetParams: {
                        COHeaderId: COHeaderId
                    }
                });
            }
            $scope.CustomerOrderModel.PrintServiceWorkSheet = function(COHeaderId) {
                if (!$rootScope.GroupOnlyPermissions['Service job']['view']) {
                    return;
                }
                var i;
                for (i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.COUId == null || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.COUId == undefined || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.COUId == '') {
                        Notification.error($Label.CO_No_Unit_Selected_Error_Message);
                        return;
                    }
                }
                $scope.CustomerOrderModel.OpenPrintServiceWorkSheetPopUp(COHeaderId);
            }
            $scope.CustomerOrderModel.openDuplicatePartModal = function(COHeaderId, LineItemType, lineitemJson, isFromDealMerchandiseSection, soHeaderId) {
                var ItemJson = [];
                if (LineItemType == 'Service' || LineItemType == 'Deal') {
                    ItemJson.push(lineitemJson);
                } else {
                    ItemJson = lineitemJson;
                }
                $scope.CustomerOrderModel.DuplicatePartList = ItemJson;
                $scope.CustomerOrderModel.isSupressTrue = false;
                $scope.CustomerOrderModel.LineItemType = LineItemType;
                $scope.CustomerOrderModel.DuplicatesoHeaderId = soHeaderId;
                angular.element('#DuplicatePartWarningModal').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#DuplicatePartWarningModal').show();
            }
            $scope.CustomerOrderModel.updateDuplicateCheckBox = function() {
                $scope.CustomerOrderModel.isSupressTrue = !$scope.CustomerOrderModel.isSupressTrue;
            }
            $scope.CustomerOrderModel.showMoreDuplicateParts = function(partId) {
                if ($scope.CustomerOrderModel.showMorePartsDetails == false) {
                    CustomerInfoService.showHistoryOnSuppressPopup(partId, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.DuplicateSectionList = successfulSearchResult;
                        $scope.CustomerOrderModel.showMorePartsDetails = !$scope.CustomerOrderModel.showMorePartsDetails;
                    }, function(errorSearchResult) {
                        alert(errorSearchResult);
                        responseData = errorSearchResult;
                    });
                } else {
                    $scope.CustomerOrderModel.DuplicateSectionList = {};
                    $scope.CustomerOrderModel.showMorePartsDetails = !$scope.CustomerOrderModel.showMorePartsDetails;
                }
            }
            $scope.CustomerOrderModel.DuplicatePartclosePopup = function() {
                $scope.CustomerOrderModel.showMorePartsDetails = false;
                $scope.CustomerOrderModel.isSupressTrue = false;
                angular.element('#DuplicatePartWarningModal').modal('hide');
            }
            $scope.CustomerOrderModel.AddDuplicatePart = function() {
                MerchendiseLineItem = $scope.CustomerOrderModel.DuplicatePartList;
                if ($scope.CustomerOrderModel.LineItemType == 'Deal') {
                    DealService.insertOptionAndFeeLineItems($scope.CustomerOrderModel.optionFeeJSONData.PartId, $scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.optionFeeJSONData.DealId, $scope.CustomerOrderModel.optionFeeJSONData.DealItemId, angular.toJson($scope.CustomerOrderModel.optionFeeJSONData), $scope.CustomerOrderModel.isSupressTrue, false).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.insertOptionFeesLineItemDetails($scope.CustomerOrderModel.optionFeeJSONData.DealId, successfulSearchResult)
                        $scope.CustomerOrderModel.showMorePartsDetails = false;
                        $scope.CustomerOrderModel.isSupressTrue = false;
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                } else {
                    var isFromDealMerchandiseSection = $scope.CustomerOrderModel.LineItemType == 'DealMerchandise' ? 'DealMerchandise' : undefined;
                    var customerId = $scope.CustomerOrderModel.Customer.Value;
                    if (!angular.isDefined(customerId)) {
                        customerId = null;
                    }
                    var soHeaderId = null;
                    if ($scope.CustomerOrderModel.DuplicatesoHeaderId != undefined && $scope.CustomerOrderModel.DuplicatesoHeaderId != null) {
                        soHeaderId = $scope.CustomerOrderModel.DuplicatesoHeaderId;
                    }
                    userService.checkDuplicateParts(MerchendiseLineItem[0].PartId, $scope.CustomerOrderModel.coHeaderId, angular.toJson(MerchendiseLineItem), $scope.CustomerOrderModel.isSupressTrue, false, soHeaderId, customerId).then(function(successfulSearchResult) {
                        if ($scope.CustomerOrderModel.LineItemType == 'Service') {
                            $scope.CustomerOrderModel.addLineItemsFOrServiceJob(successfulSearchResult, $scope.CustomerOrderModel.SelectedSection.index);
                        } else {
                            $scope.CustomerOrderModel.bindMerchInsertResult(isFromDealMerchandiseSection, successfulSearchResult);
                        }
                        $scope.CustomerOrderModel.showMorePartsDetails = false;
                        $scope.CustomerOrderModel.isSupressTrue = false;
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        $scope.searching = false;
                        $scope.CustomerOrderModel.MerchandiseGhostItems = [];
                    });
                }
                angular.element('#DuplicatePartWarningModal').modal('hide');
            }
            $scope.CustomerOrderModel.PrintCODeposits = function(COHeaderId) {
                if ($rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                    window.open(url + "PrintCODeposits?id=" + COHeaderId, "", "width=1200, height=600");
                }
            }
            $scope.CustomerOrderModel.invoicePrintPriview = function(customerInvoiceId) {
                var myWindow = window.open(url + "PrintCustomerOrderInvoice?id=" + customerInvoiceId + "&isFinalized=" + true, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.invoicePrintPriviewBeforeFinalize = function() {
                var coInvoiceHeaderId = $scope.CustomerOrderModel.COInvoiceHeaderId;
                var myWindow = window.open(url + "PrintCustomerOrderInvoice?id=" + coInvoiceHeaderId + "&isFinalized=" + false, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.invoiceScannedPrintPriview = function(customerInvoiceId) {
                var myWindow = window.open(url + "PrintScannedCustomerOrderInvoice?id=" + customerInvoiceId, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.PrintPriviewMerchandise = function(coHeaderId) {
                if (!$rootScope.GroupOnlyPermissions['Merchandise']['view']) {
                    return;
                }
                if ($scope.CustomerOrderModel.MerchandiseItems == undefined || $scope.CustomerOrderModel.MerchandiseItems.length == 0) {
                    Notification.error($Label.CO_Add_Merch_LineItem_Before_Print);
                    return;
                }
                if ($scope.CustomerOrderModel.CurrentUserLocale == 'en_AU') {
                    isAustralianMarket = true;
                } else {
                    isAustralianMarket = false;
                }
                var myWindow = window.open(url + "PrintMerchandise?id=" + coHeaderId, "", "width=1200, height=600");
            }
            $scope.CustomerOrderModel.SaveEstimatedHours = function(event, index) {
                if (event.keyCode == 9) {
                    $scope.CustomerOrderModel.SaveserviceInfo(index);
                }
            }
            $scope.CustomerOrderModel.isEmptyProvider = function(index) {
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedProvider == undefined || JSON.stringify($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedProvider) == JSON.stringify({})) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.SaveserviceInfo = function(index, allowInWizard) {
                if (allowInWizard == undefined && $scope.CustomerOrderModel.isWizardMode) {
                    return;
                }
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionType != 'Third-Party') {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ProviderId = null;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedProvider = {};
                }
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.TransactionType != 'Internal') {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryNameStr = '';
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryId = null;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryName = '';
                }
                $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.PromisedBy = $scope.CustomerOrderModel.getSFformatDate($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedDate, $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedTime);
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.PromisedBy == undefined || $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.PromisedBy.indexOf('undefined') > -1) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.PromisedBy = null;
                }
                SOHeaderService.saveSOHeaderInfo($scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryNameStr = successfulSearchResult.CategoryName;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryId = successfulSearchResult.CategoryId;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.CategoryName = successfulSearchResult.CategoryName;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.ClaimStatus = successfulSearchResult.ClaimStatus;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.AvailableClaimStatusList = successfulSearchResult.AvailableClaimStatusList;
                    if (allowInWizard != undefined && allowInWizard) {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.EstimatedHours = successfulSearchResult.EstimatedHours;
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedTime = $scope.CustomerOrderModel.getTimeFromSFformat(successfulSearchResult.PromisedBy);
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.selectedDate = $scope.CustomerOrderModel.getDateFromSFformat(successfulSearchResult.PromisedBy);
                        $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.IsPromisedByAmPm = successfulSearchResult.IsPromisedByAmPm;
                        $scope.CustomerOrderModel.resetServiceOrderData();
                        $scope.CustomerOrderModel.resetCauseConcernCorrection();
                        $scope.CustomerOrderModel.setServiceOrderData();
                        $scope.WizardModel.WizardSOHeader = angular.copy($scope.CustomerOrderModel.SOHeaderList[index]);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.openCommitUnitToDealConfirmModal = function() {
                angular.element('#commitUnitConfirm').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#commitUnitConfirm').show();
            }
            $scope.CustomerOrderModel.closeCommitUnitToDealConfirmModal = function() {
                angular.element('#commitUnitConfirm').modal('hide');
                $scope.CustomerOrderModel.activateQuote();
                $scope.CustomerOrderModel.updateDealStatus();
            }
            $scope.CustomerOrderModel.commitUnitsToDeal = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Closed') {
                    return;
                }
                var isTemprarotyUnitPresent = false;
                for (var i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                    if ($scope.CustomerOrderModel.DealItemList[i].DealItemObj.UnitId == null) {
                        isTemprarotyUnitPresent = true;
                        break;
                    }
                }
                if (!isTemprarotyUnitPresent) {
                    if ($scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Quote') {
                        $scope.CustomerOrderModel.openCommitUnitToDealConfirmModal();
                    } else {
                        $scope.CustomerOrderModel.updateDealStatus();
                    }
                } else {
                    Notification.error($Label.Change_Temporary_Unit_first);
                }
            }
            $scope.CustomerOrderModel.updateDealStatus = function() {
                CustomerInfoService.updateDealStatus($scope.CustomerOrderModel.DealInfo.Id, 'In Progress').then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealInfo = successfulSearchResult;
                    if ($scope.CustomerOrderModel.DealItemList != undefined) {
                        for (var i = 0; i < $scope.CustomerOrderModel.DealItemList.length; i++) {
                            $scope.CustomerOrderModel.DealItemList[i].DealItemObj.StatusColor = 'Red';
                            $scope.CustomerOrderModel.DealItemList[i].DealItemObj.Status = 'Reserved';
                        }
                    }
                    Notification.success($Label.Deal_status_successfully_updated);
                }, function(errorSearchResult) {
                    alert(errorSearchResult);
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveSignInfo = function(index, isBlur) {
                $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer = String($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer).replace(/\b(0(?!\b))+/g, "");
                if ($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer === '' || isNaN($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer) || parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer) <= 0) {
                    if (isNaN($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer)) {
                        Notification.error($Label.CO_Odometer_Arrival_should_be_number_only);
                    }
                    if (parseFloat($scope.CustomerOrderModel.SOHeaderListCopy[index].SOSignInRec.Odometer) != '') {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer = $scope.CustomerOrderModel.SOHeaderListCopy[index].SOSignInRec.Odometer;
                    } else {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer = 0;
                    }
                } else if (($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture != '') && parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer) > parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture)) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer;
                } else if (($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture === '' || $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture == null || $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture == undefined || parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture) == 0) && $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.WorkStatus == 'Complete') {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer;
                }
                if (parseFloat($scope.CustomerOrderModel.SOHeaderListCopy[index].SOSignInRec.Odometer) === parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer)) {
                    return;
                }
                $scope.CustomerOrderModel.saveSOSignIn(index, isBlur);
            }
            $scope.CustomerOrderModel.saveSOSignIn = function(index, isBlur) {
                SOHeaderService.saveSOSignIn($scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec)).then(function(successfulSearchResult) {
                    if (isBlur) {
                        Notification.success($Label.CO_Odometer_Arrival_Saved_Successfully);
                    }
                    $scope.CustomerOrderModel.SOHeaderListCopy = angular.copy(successfulSearchResult.SOList);
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status = successfulSearchResult.SOList[index].SOHeaderInfo.Status;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer = successfulSearchResult.SOList[index].SOSignInRec.Odometer;
                    if (parseFloat($scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture) != parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture)) {
                        $scope.CustomerOrderModel.saveServiceReview(index, undefined, false);
                    }
                }, function(errorSearchResult) {
                    alert(errorSearchResult); //FIXME
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.changeSOStatusToComplete = function(index) {
                SOHeaderService.saveSOStatusToComplete($scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Id, $scope.CustomerOrderModel.coHeaderId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status = successfulSearchResult.SOList[index].SOHeaderInfo.Status;
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveOdometerDeparture = function(index, isBlur) {
                angular.element('#CO_SearchToAdd_value').focus();
                $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = String($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture).replace(/\b(0(?!\b))+/g, "");
                if (isNaN($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture) || parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture) < parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer) || $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture === '' || parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture) <= 0) {
                    if (($scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture === '' || $scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture == undefined || $scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture == null || parseFloat($scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture) == 0) && $scope.CustomerOrderModel.SOHeaderListCopy[index].SOSignInRec.Odometer != '') {
                        Notification.error($Label.CO_Odometer_Departure_as_number_validation_message);
                    }
                    if ($scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture != '') {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = $scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture;
                    } else {
                        $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = 0;
                    }
                } else if ($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer === '' || $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer == undefined || $scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer == null || parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOSignInRec.Odometer) == 0) {
                    Notification.error('Please fill odometer arrival first');
                    return;
                }
                if (parseFloat($scope.CustomerOrderModel.SOHeaderListCopy[index].SOReviewRec.OdometerOnDeparture) === parseFloat($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture)) {
                    return;
                }
                $scope.CustomerOrderModel.saveServiceReview(index, undefined, isBlur);
            }
            $scope.CustomerOrderModel.saveServiceReview = function(index, allowSave, isBlur) {
                if ($scope.CustomerOrderModel.isWorkWizardMode && allowSave == undefined) {
                    return;
                }
                SOHeaderService.saveSOReviewInfo($scope.CustomerOrderModel.coHeaderId, JSON.stringify($scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec)).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.SOHeaderListCopy = successfulSearchResult.SOList;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOReviewRec.OdometerOnDeparture = successfulSearchResult.SOList[index].SOReviewRec.OdometerOnDeparture;
                    $scope.CustomerOrderModel.SOHeaderList[index].SOHeaderInfo.Status = successfulSearchResult.SOList[index].SOHeaderInfo.Status;
                    if (isBlur) {
                        Notification.success($Label.Generic_Saved);
                    }
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.saveSONameToServer = function(SOName, SOHeaderId) {
                SOHeaderService.saveSOName($scope.CustomerOrderModel.coHeaderId, SOName, SOHeaderId).then(function(successfulSearchResult) {
                    Notification.success($Label.CO_Service_Job_Name_Saved_Successfully);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            $scope.CustomerOrderModel.checkoutDownArrowClick = function() {
                $scope.CustomerOrderModel.displaySections.Checkout = false;
                $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
                $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                $scope.CustomerOrderModel.collapseCheckoutSection = true;
                $scope.CustomerOrderModel.selectedOptionForCheckout = 'Please Select';
            }
            $scope.CustomerOrderModel.checkoutRightArrowClick = function() {
                $scope.CustomerOrderModel.displaySections.Checkout = true;
                $scope.CustomerOrderModel.collapseCheckoutSection = false;
                if ($scope.CustomerOrderModel.Payment == undefined || $scope.CustomerOrderModel.Payment == '' || $scope.CustomerOrderModel.Payment == null || $scope.CustomerOrderModel.Payment.length <= 0) {
                    $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                    $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = false;
                } else {
                    if ($scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment.length > 0) {
                        for (var i = 0; i < $scope.CustomerOrderModel.Payment.length; i++) {
                            if ($scope.CustomerOrderModel.Payment[i].Amount < 0) {
                                $scope.CustomerOrderModel.displayAddPaymentBtnForCheckout = true;
                            }
                        }
                    }
                    if ($scope.CustomerOrderModel.calculateBalanceDue() != 0) {
                        if ($scope.CustomerOrderModel.displayAddPaymentBtnForCheckout == false && $scope.CustomerOrderModel.calculateBalanceDue() > 0) {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = true;
                            $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = true;
                        } else {
                            $scope.CustomerOrderModel.isPaymentDropdownVisibleForCheckout = false;
                            $scope.CustomerOrderModel.isPaymentDropdownOpenForCheckout = false;
                        }
                    }
                }
            }
            $scope.CustomerOrderModel.displayTotalCheckoutAmount = function(event) {
                if (event) {
                    event.preventDefault();
                }
                if ($scope.CustomerOrderModel.Payment_Amount == undefined || $scope.CustomerOrderModel.Payment_Amount == '' || $scope.CustomerOrderModel.Payment_Amount == null || $scope.CustomerOrderModel.Payment_Amount < $scope.CustomerOrderModel.calculateBalanceDue()) {
                    $scope.CustomerOrderModel.payment_TotalAmount = true;
                } else {
                    $scope.CustomerOrderModel.payment_TotalAmount = false;
                }
            }
            $scope.CustomerOrderModel.hideTotalCheckoutAmount = function() {
                $scope.CustomerOrderModel.isPaymentAmountError = false;
                angular.element('#paymentErrorMsg').css("display", 'none');
                if ($scope.CustomerOrderModel.Payment_Amount != undefined && $scope.CustomerOrderModel.Payment_Amount != null && $scope.CustomerOrderModel.Payment_Amount != '') {
                    $scope.CustomerOrderModel.Payment_Amount = (parseFloat($scope.CustomerOrderModel.Payment_Amount)).toFixed(2);
                } else {
                    $scope.CustomerOrderModel.Payment_Amount = '';
                }
                $scope.CustomerOrderModel.payment_TotalAmount = false;
            }
            $scope.CustomerOrderModel.isFinancingPaymentMethodAvailable = function() {
                var dealSelectedForFinalize = 0;
                if ($scope.CustomerOrderModel.checkOutMode == 'Customer') {
                    for (i = 0; i < $scope.CustomerOrderModel.CheckOutItems.length; i++) {
                        if ($scope.CustomerOrderModel.CheckOutItems[i].IsFinalizable == true) {
                            if ($scope.CustomerOrderModel.CheckOutItems[i].DealId != null) {
                                dealSelectedForFinalize++;
                            } else {
                                return false;
                            }
                        }
                    }
                }
                if (dealSelectedForFinalize > 0) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isStoreCreditPaymentMethodAvailable = function() {
                var balanceDue = $scope.CustomerOrderModel.calculateBalanceDue();
                if (balanceDue < 0) {
                    return true;
                } else {
                    if ($scope.CustomerOrderModel.coHeaderDetails.CustomerStoreCredit == 0) {
                        return false;
                    }
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.MoveToState = function(stateName, attr) {
                if (attr != undefined && attr != null && attr != '') {
                    loadState($state, stateName, attr);
                } else {
                    loadState($state, stateName);
                }
            }
            $scope.CustomerOrderModel.refreshCustomerPricingAndTax = function() {
                CustomerInfoService.refreshCOPricingAndTax($scope.CustomerOrderModel.coHeaderId, $scope.CustomerOrderModel.coHeaderDetails.CustomerId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.coHeaderDetails = successfulSearchResult.coHeaderRec;
                    $scope.CustomerOrderModel.CardInfo = successfulSearchResult.CardInfo;
                    $scope.CustomerOrderModel.UpdateMerchandiseFromSearchResult(successfulSearchResult, false);
                    $scope.CustomerOrderModel.COUList = successfulSearchResult.COUList;
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    var scrollInfoSection = 'scrollInfoSection';
                    $scope.CustomerOrderModel.loadSODetails(scrollInfoSection);
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                    Notification.error($Label.Generic_Error);
                    $scope.CustomerOrderModel.isrefresh = false;
                });
            }
            $scope.CustomerOrderModel.setDefaultSelectedSOEditGridOption = function(SOKHitem, Solitem, SOHeader, soIndex, parentIndex, index) {
                if (index != null) {
                    if ($scope.CustomerOrderModel.isSOKitHeaderLIRemoveFromOrderActionAvailable(Solitem)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].optionSelected = 0;
                    } else if ($scope.CustomerOrderModel.isSOKitHeaderLIBreakUpKitActionAvailable(SOKHitem, Solitem)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].optionSelected = 1;
                    } else if ($scope.CustomerOrderModel.isSOKitHeaderLISpecialOrderActionAvailable(Solitem)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].optionSelected = 2;
                    } else if ($scope.CustomerOrderModel.isSOKitHeaderLIMoveToActionAvailable(SOKHitem, Solitem, SOHeader)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].SOLI_editRow[index].optionSelected = 3;
                    }
                } else {
                    if ($scope.CustomerOrderModel.isSOKitHeaderRemoveFromOrderActionAvailable()) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].optionSelected = 0;
                    } else if ($scope.CustomerOrderModel.isSOKitHeaderBreakUpKitActionAvailable(SOKHitem, SOHeader)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].optionSelected = 1;
                    } else if ($scope.CustomerOrderModel.isSOKitHeaderMoveToActionAvailable(SOKHitem, SOHeader)) {
                        $scope.CustomerOrderModel.SoItems_editRow[soIndex].HeaderItems_editRow[parentIndex].optionSelected = 2;
                    }
                }
            }
            $scope.CustomerOrderModel.setDefaultSelectedMerchEditGridOption = function(COKHitem, COlitem, COKHIndex, COLIIndex) {
                if (COLIIndex != null) {
                    if ($scope.CustomerOrderModel.isMerchKitHeaderLIRemoveFromOrderActionAvailable(COlitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].radioValue = 0;
                    } else if ($scope.CustomerOrderModel.isMerchKitHeaderLIBreakUpKitActionAvailable(COKHitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].radioValue = 1;
                    } else if ($scope.CustomerOrderModel.isMerchKitHeaderLISpecialOrderActionAvailable(COlitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].radioValue = 2;
                    } else if ($scope.CustomerOrderModel.isMerchKitHeaderLIMoveToActionAvailable(COKHitem, COlitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].lineItems[COLIIndex].radioValue = 3;
                    }
                } else {
                    if ($scope.CustomerOrderModel.isMerchKitHeaderRemoveFromOrderActionAvailable()) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].radioValue = 0;
                    } else if ($scope.CustomerOrderModel.isMerchKitHeaderBreakUpKitActionAvailable(COKHitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].radioValue = 1;
                    } else if ($scope.CustomerOrderModel.isMerchKitHeaderMoveToActionAvailable(COKHitem)) {
                        $scope.CustomerOrderModel.MerchandiseItems_editRow[COKHIndex].radioValue = 2;
                    }
                }
            }
            $scope.CustomerOrderModel.isSOKitHeaderRemoveFromOrderActionAvailable = function() {
                return true;
            }
            $scope.CustomerOrderModel.isSOKitHeaderBreakUpKitActionAvailable = function(SOKHitem, SOHeader) {
                if (SOKHitem.SOKH.hasChildren && SOKHitem.SOKH.CanItSplit && SOHeader.SOHeaderInfo.DealId == null) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isSOKitHeaderMoveToActionAvailable = function(SOKHitem, SOHeader) {
                var filteredListServiceJobForKitSize = $filter("filter")($scope.CustomerOrderModel.AllSectionList, $scope.getSectionToMove(SOHeader.SOHeaderInfo.Id)).length;
                if ($scope.CustomerOrderModel.coHeaderDetails.COType != 'Internal Service' && SOKHitem.SOKH.hasChildren && SOHeader.SOHeaderInfo.DealId == null && filteredListServiceJobForKitSize > 0) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isSOKitHeaderLIRemoveFromOrderActionAvailable = function(Solitem) {
                if (!(Solitem.IsPart && Solitem.Status == 'Ordered')) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isSOKitHeaderLIBreakUpKitActionAvailable = function(SOKHitem, Solitem) {
                if (SOKHitem.SOKH.hasChildren && Solitem.Status != 'Ordered' && SOKHitem.SOKH.CanItSplit && Solitem.DealId == null) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isSOKitHeaderLISpecialOrderActionAvailable = function(Solitem) {
                if (!Solitem.IsLabour && !Solitem.IsFee && Solitem.Status != 'RETURN' && Solitem.DealId == null && $scope.CustomerOrderModel.VendorOrderListByVendorId.length > 0 && Solitem.Status == 'Required' && $rootScope.GroupOnlyPermissions['Special order']['enabled']) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isSOKitHeaderLIMoveToActionAvailable = function(SOKHitem, Solitem, SOHeader) {
                var filteredListServiceJobSize = $filter("filter")($scope.CustomerOrderModel.AllSectionList, $scope.getSectionToMove(SOHeader.SOHeaderInfo.Id)).length;
                if ($scope.CustomerOrderModel.coHeaderDetails.COType != 'Internal Service' && !SOKHitem.SOKH.hasChildren && Solitem.DealId == null && filteredListServiceJobSize > 0) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderRemoveFromOrderActionAvailable = function() {
                return true;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderBreakUpKitActionAvailable = function(COKHitem) {
                if (COKHitem.hasChildren && COKHitem.CanItSplit) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderMoveToActionAvailable = function(COKHitem) {
                var filteredListMerchandiseForKitSize = $filter("filter")($scope.CustomerOrderModel.AllSectionList, $scope.getSectionToMove('Merchandise')).length;
                if (COKHitem.hasChildren && filteredListMerchandiseForKitSize > 0 && $scope.CustomerOrderModel.serviceOrderList.length > 0) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderLIRemoveFromOrderActionAvailable = function(COlitem) {
                if (COlitem.Status != 'Ordered') {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderLIBreakUpKitActionAvailable = function(COKHitem) {
                if (COKHitem.hasChildren && COKHitem.CanItSplit) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderLISpecialOrderActionAvailable = function(COlitem) {
                if (!COlitem.IsLabour && !COlitem.IsFee && COlitem.Status != 'RETURN' && $scope.CustomerOrderModel.VendorOrderListByVendorIdForMerchandise.length > 0 && COlitem.Status == 'Required' && $rootScope.GroupOnlyPermissions['Special order']['enabled']) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.isMerchKitHeaderLIMoveToActionAvailable = function(COKHitem, COlitem) {
                var filteredListMerchandiseSize = $filter("filter")($scope.CustomerOrderModel.AllSectionList, $scope.getSectionToMove('Merchandise')).length;
                if (!COKHitem.hasChildren && filteredListMerchandiseSize > 0 && ($scope.CustomerOrderModel.serviceOrderList.length > 0 || COlitem.IsPart)) {
                    return true;
                }
                return false;
            }
            $scope.CustomerOrderModel.SOKitHeaderAvailableActions = function(SOKHitem, SOHeader) {
                var availableActions = 0;
                if ($scope.CustomerOrderModel.isSOKitHeaderRemoveFromOrderActionAvailable()) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isSOKitHeaderBreakUpKitActionAvailable(SOKHitem, SOHeader)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isSOKitHeaderMoveToActionAvailable(SOKHitem, SOHeader)) {
                    availableActions++;
                }
                return availableActions;
            }
            $scope.CustomerOrderModel.SOKitHeaderLIAvailableActions = function(SOKHitem, Solitem, SOHeader) {
                var availableActions = 0;
                if ($scope.CustomerOrderModel.isSOKitHeaderLIRemoveFromOrderActionAvailable(Solitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isSOKitHeaderLIBreakUpKitActionAvailable(SOKHitem, Solitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isSOKitHeaderLISpecialOrderActionAvailable(Solitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isSOKitHeaderLIMoveToActionAvailable(SOKHitem, Solitem, SOHeader)) {
                    availableActions++;
                }
                return availableActions;
            }
            $scope.CustomerOrderModel.MerchKitHeaderAvailableActions = function(COKHitem) {
                var availableActions = 0;
                if ($scope.CustomerOrderModel.isMerchKitHeaderRemoveFromOrderActionAvailable()) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isMerchKitHeaderBreakUpKitActionAvailable(COKHitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isMerchKitHeaderMoveToActionAvailable(COKHitem)) {
                    availableActions++;
                }
                return availableActions;
            }
            $scope.CustomerOrderModel.MerchKitHeaderLIAvailableActions = function(COKHitem, COlitem) {
                var availableActions = 0;
                if ($scope.CustomerOrderModel.isMerchKitHeaderLIRemoveFromOrderActionAvailable(COlitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isMerchKitHeaderLIBreakUpKitActionAvailable(COKHitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isMerchKitHeaderLISpecialOrderActionAvailable(COlitem)) {
                    availableActions++;
                }
                if ($scope.CustomerOrderModel.isMerchKitHeaderLIMoveToActionAvailable(COKHitem, COlitem)) {
                    availableActions++;
                }
                return availableActions;
            }
            $scope.CustomerOrderModel.EditCustomerDetails = function(result) {
                if (result.Id.length == 18) {
                    result.Id = result.Id.substring(0, 15);
                }
                if ($scope.CustomerOrderModel.Customer.Value.length == 18) {
                    $scope.CustomerOrderModel.Customer.Value = $scope.CustomerOrderModel.Customer.Value.substring(0, 15);
                }
                if ($scope.CustomerOrderModel.Customer.Value == result.Id) {
                    var customerId = $scope.CustomerOrderModel.Customer.Value;
                    CustomerInfoService.EditCustomerDetails(customerId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.CustomerInfo = successfulSearchResult[0];
                        $scope.CustomerOrderModel.IsFirst = 1;
                        $scope.CustomerOrderModel.ChangeRecords = 1;
                        $scope.LoadCustomerOrder();
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                    });
                }
            }
            angular.element(document).on("mouseenter", ".multiselect span", function(event) {
                var element = angular.element(event.target);
                element.find("i").css("display", "block");
            });
            angular.element(document).on("mouseleave", ".multiselect span", function(event) {
                var element = angular.element(event.target);
                element.find("i").css("display", "none");
            });
            $scope.CustomerOrderModel.editManualNotes = function($event, seviceOrderIndex, notesLineItemIndex, ModelKey) {
                var isEditModeEnabled = false;
                for (i = 0; i < $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey].length; i++) {
                    if ($scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey][i].isEdit == true) {
                        $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey][i].isEdit = false;
                        $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                        isEditModeEnabled = true;
                    }
                }
                if (!isEditModeEnabled) {
                    $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey][notesLineItemIndex].isEdit = true;
                    $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = false;
                    $timeout(function() {
                        angular.element('#NotesForCustomerEdit_' + ModelKey + '_' + seviceOrderIndex + '_' + notesLineItemIndex).focus();
                    }, 10);
                }
            }
            $scope.CustomerOrderModel.editNotesForCustomerTabOut = function(event, seviceOrderIndex, notesLineItemIndex, fieldLabel, ModelKey) {
                $timeout(function() {
                    var isAlreadyExist = false;
                    var fieldValue = $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOReviewRec[ModelKey][notesLineItemIndex];
                    if (event.keyCode == 13 || event.keyCode == 9) {
                        if (fieldValue != '' && fieldValue != undefined) {
                            for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOReviewRec[ModelKey].length; i++) {
                                if (($scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOReviewRec[ModelKey][i] == fieldValue) && (i != notesLineItemIndex)) {
                                    isAlreadyExist = true;
                                    Notification.error('Same ' + fieldLabel + ' Already Exist');
                                    setTimeout(function() {
                                        angular.element('#NotesForCustomerEdit_' + ModelKey + '_' + seviceOrderIndex + '_' + notesLineItemIndex).focus();
                                    }, 100);
                                }
                            }
                            if (!isAlreadyExist) {
                                $scope.CustomerOrderModel.SOHeaderList[seviceOrderIndex].SOReviewRec[ModelKey][notesLineItemIndex] = fieldValue;
                                $scope.CustomerOrderModel.saveServiceReview(seviceOrderIndex);
                                $timeout(function timeout() {
                                    $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey][notesLineItemIndex].isEdit = false;
                                    $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                                    Notification.success(fieldLabel + ' ' + $Label.Generic_Saved);
                                }, 1000);
                            }
                        } else {
                            $scope.CustomerOrderModel.removeNotesFromMultiSelect(notesLineItemIndex, seviceOrderIndex, ModelKey);
                            $timeout(function timeout() {
                                $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex][ModelKey][notesLineItemIndex].isEdit = false;
                                $scope.CustomerOrderModel.NotesForCustomer_editRow[seviceOrderIndex]['isEditEnabled_' + ModelKey] = true;
                                Notification.success(fieldLabel + ' ' + $Label.Generic_Saved);
                            }, 1000);
                        }
                    }
                }, 10);
            }
            $scope.CustomerOrderModel.showDeleteCustomerOrderLink = function() {
                if ($scope.CustomerOrderModel.coHeaderDetails != undefined && $scope.CustomerOrderModel.coHeaderDetails.OrderStatus == 'Open' && $scope.CustomerOrderModel.MerchandiseItems != undefined && $scope.CustomerOrderModel.MerchandiseItems.length == 0 && $scope.CustomerOrderModel.SOHeaderList != undefined && $scope.CustomerOrderModel.SOHeaderList.length == 0 && $scope.CustomerOrderModel.DealInfo == undefined && $scope.CustomerOrderModel.Deposits != undefined && $scope.CustomerOrderModel.Deposits.length == 0 && $scope.CustomerOrderModel.Payment != undefined && $scope.CustomerOrderModel.Payment.length == 0 && $scope.CustomerOrderModel.InvoiceHistory != undefined && $scope.CustomerOrderModel.InvoiceHistory.length == 0) {
                    return true;
                } else {
                    return false;
                }
            }
            $scope.CustomerOrderModel.deleteCustomerOrder = function() {
                CustomerInfoService.deleteCustomerOrder($scope.CustomerOrderModel.coHeaderId).then(function(successfulResult) {
                    if (successfulResult == 'Success') {
                        Notification.success('Customer Order Deleted');
                        loadState($state, 'homePage');
                    } else {
                        Notification.error('Something is changed on this Order');
                        $scope.LoadCustomerOrder();
                    }
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            };
            $scope.CustomerOrderModel.setCOStatusAsQuote = function() {
                CustomerInfoService.setCOStatusAsQuote($scope.CustomerOrderModel.coHeaderId).then(function(successfulResult) {
                    Notification.success(successfulResult);
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
                $scope.LoadCustomerOrder();
                $scope.CustomerOrderModel.isDisplaySetCOAsQuote = true;
            };
            $scope.CustomerOrderModel.isShowCOAsQuote = function() {
                if (!$scope.CustomerOrderModel.isDisplaySetCOAsQuote || $scope.CustomerOrderModel.coHeaderDetails.OrderStatus != 'Open' || $scope.CustomerOrderModel.coHeaderDetails.COType != 'Customer' || $scope.CustomerOrderModel.Deposits.length > 0 || $scope.CustomerOrderModel.Payment.length > 0 || $scope.CustomerOrderModel.MerchandiseItems.length > 0 || $scope.CustomerOrderModel.InvoiceHistory.length > 0) {
                    return false;
                } else if ($scope.CustomerOrderModel.DealInfo != undefined && ($scope.CustomerOrderModel.DealInfo.DealStatus != 'Quotation' || $scope.CustomerOrderModel.DealDepositList.length > 0)) {
                    return false;
                }
                for (var i = 0; i < $scope.CustomerOrderModel.SOHeaderList.length; i++) {
                    if ((($scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.TransactionTypeLabel != 'Customer Pay') && $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.TransactionTypeLabel != 'Quote') || $scope.CustomerOrderModel.SOHeaderList[i].SOHeaderInfo.WorkStatus != 'New' || $scope.CustomerOrderModel.SOHeaderList[i].SOGridItems.length > 0) {
                        return false;
                    }
                }
                return true;
            };
            $scope.CustomerOrderModel.openDeleteQuoteConfirmModal = function() {
                angular.element('#deleteQuoteConfirm').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#deleteQuoteConfirm').show();
            }
            $scope.CustomerOrderModel.closeDeleteQuoteConfirmModal = function() {
                angular.element('#deleteQuoteConfirm').modal('hide');
                $scope.CustomerOrderModel.deleteQuote();
            }
            $scope.CustomerOrderModel.deleteQuote = function() {
                CustomerInfoService.deleteQuoteCustomerOrder($scope.CustomerOrderModel.coHeaderId).then(function(successfulResult) {
                    if (successfulResult == 'Success') {
                        loadState($state, 'homePage');
                    } else {
                        Notification.error('Something is changed on this Order');
                        $scope.LoadCustomerOrder();
                        $scope.CustomerOrderModel.isDisplayDeletedQuoteCO = true;
                    }
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    $scope.CustomerOrderModel.isDisplayDeletedQuoteCO = true;
                });
            };
            $scope.CustomerOrderModel.openActivateQuoteConfirmModal = function() {
                angular.element('#activateQuoteConfirm').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#activateQuoteConfirm').show();
            }
            $scope.CustomerOrderModel.closeActivateQuoteConfirmModal = function(isUpdateProvider) {
                angular.element('#activateQuoteConfirm').modal('hide');
                if ($scope.CustomerOrderModel.updatedJobTypeSOIndex != null) {
                    if (isUpdateProvider) {
                        $scope.CustomerOrderModel.changeProviderList($scope.CustomerOrderModel.updatedJobTypeSOIndex);
                    } else {
                        for (var i = 0; i < $scope.CustomerOrderModel.MasterData.TTList.length; i++) {
                            if ($scope.CustomerOrderModel.MasterData.TTList[i].Type == 'Quote') {
                                $scope.CustomerOrderModel.SOHeaderList[$scope.CustomerOrderModel.updatedJobTypeSOIndex].SOHeaderInfo.TransactionTypeId = $scope.CustomerOrderModel.MasterData.TTList[i].Id;
                                return;
                            }
                        }
                    }
                } else {
                    $scope.CustomerOrderModel.activateQuote();
                }
            }
            $scope.CustomerOrderModel.activateQuote = function() {
                CustomerInfoService.activateQuoteCO($scope.CustomerOrderModel.coHeaderId).then(function(successfulResult) {
                    if (successfulResult == 'Success') {
                        Notification.success('Customer Order Activated');
                    } else {
                        Notification.error('Something is changed on this Order');
                    }
                    $scope.LoadCustomerOrder();
                    $scope.CustomerOrderModel.isDisplayActivatedQuoteCO = true;
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    $scope.CustomerOrderModel.isDisplayActivatedQuoteCO = true;
                });
            };
            $scope.CustomerOrderModel.updateStampDutyTotal = function(dealItemId, stampDutyTotal) {
                DealService.updateStampDuty(dealItemId, (stampDutyTotal).toString()).then(function(successfulResult) {
                    $scope.LoadCustomerOrder();
                    $scope.CustomerOrderModel.isDisplayActivatedQuoteCO = true;
                    $scope.CustomerOrderModel.updateDealSummaryTotals();
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                    $scope.CustomerOrderModel.isDisplayActivatedQuoteCO = true;
                });
            };
            $scope.CustomerOrderModel.openMessagePopUp = function() {
                var messageParams = {
                    Activity: 'Text Message',
                    CustomerName: $scope.CustomerOrderModel.Customer.Name,
                    CustomerInfo: $scope.CustomerOrderModel.CustomerData
                };
                loadState($state, 'CustomerOrder.CustomerMessagingPopUp', {
                    messagingInfoParams: messageParams
                });
            }
            $scope.CustomerOrderModel.getSMSPhone = function() {
                if ($scope.CustomerOrderModel.CustomerData.Cust_OtherNumber != undefined && $scope.CustomerOrderModel.CustomerData.Cust_OtherNumber != null && $scope.CustomerOrderModel.CustomerData.Cust_OtherNumber != "") {
                    return $scope.CustomerOrderModel.CustomerData.Cust_OtherNumber;
                } else if ($scope.CustomerOrderModel.CustomerData.Cust_HomeNumber != undefined && $scope.CustomerOrderModel.CustomerData.Cust_Type == "Individual" && $scope.CustomerOrderModel.CustomerData.Cust_HomeNumber != null && $scope.CustomerOrderModel.CustomerData.Cust_HomeNumber != "") {
                    return $scope.CustomerOrderModel.CustomerData.Cust_HomeNumber;
                } else if ($scope.CustomerOrderModel.CustomerData.Cust_WorkNumber != undefined && $scope.CustomerOrderModel.CustomerData.Cust_Type == "Business" && $scope.CustomerOrderModel.CustomerData.Cust_WorkNumber != null && $scope.CustomerOrderModel.CustomerData.Cust_WorkNumber != "") {
                    return $scope.CustomerOrderModel.CustomerData.Cust_WorkNumber;
                } else {
                    return '';
                }
            }
            $scope.CustomerOrderModel.openEmailPopUp = function(COInvoiceHeaderId) {
                var messageParams = {
                    Activity: 'Email',
                    CustomerName: $scope.CustomerOrderModel.Customer.Name,
                    CustomerId: $scope.CustomerOrderModel.Customer.id,
                    customerInfo: $scope.CustomerOrderModel.CustomerInfoData,
                    COType: $scope.CustomerOrderModel.coHeaderDetails.COType,
                    COInvoiceHeaderId: COInvoiceHeaderId
                };
                $scope.CustomerOrderModel.hideHourPopUp('Invoice-info-flyout');
                loadState($state, 'CustomerOrder.CustomerMessagingPopUp', {
                    messagingInfoParams: messageParams
                });
            }
            $scope.CustomerOrderModel.showRelatedParts = function(partId, callbackElementId, lineItem, HeaderId, SectionType, SoHeaderIndex) {
                $scope.CustomerOrderModel.showRelatedPartsClicked = true;
                $scope.CustomerOrderModel.callbackElementId = callbackElementId;
                $scope.CustomerOrderModel.alternatePartsList = [];
                $scope.CustomerOrderModel.alternatePartData = {};
                $scope.CustomerOrderModel.alternatePartData.lineItem = createLineItem(lineItem, SectionType);
                $scope.CustomerOrderModel.alternatePartData.HeaderId = HeaderId;
                $scope.CustomerOrderModel.alternatePartData.DealId = lineItem.DealId;
                $scope.CustomerOrderModel.alternatePartData.SectionType = SectionType;
                $scope.CustomerOrderModel.alternatePartData.SoHeaderIndex = SoHeaderIndex;
                CustomerInfoService.getAlternatePartsList(partId).then(function(successfulResult) {
                    $scope.CustomerOrderModel.alternatePartsList = successfulResult;
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            }

            function createLineItem(originalLineItem, SectionType) {
                var lineItem = {};
                if (SectionType == 'ServiceOrder') {
                    lineItem.Id = originalLineItem.Id;
                    lineItem.Qty = originalLineItem.QtyNeeded;
                    lineItem.QtyOrder = originalLineItem.QtyOrder;
                    lineItem.VONumber = originalLineItem.VONumber;
                    lineItem.PartId = originalLineItem.PartId;
                } else if (SectionType == 'Merchandise' || SectionType == 'Deal Merchandise') {
                    lineItem.Id = originalLineItem.CoLineItemId;
                    lineItem.Qty = originalLineItem.Qty;
                    lineItem.QtyOrder = originalLineItem.QtyOrder;
                    lineItem.VONumber = originalLineItem.VONumber;
                    lineItem.PartId = originalLineItem.partId;
                }
                return lineItem;
            }
            $scope.CustomerOrderModel.hideRelatedPartPopup = function() {
                $scope.CustomerOrderModel.showRelatedPartsClicked = false;
                setTimeout(function() {
                    focusElement($scope.CustomerOrderModel.callbackElementId);
                }, 1000);
            }
            $scope.CustomerOrderModel.selectAlternatePart = function(index) {
                var item = $scope.CustomerOrderModel.alternatePartsList[index];
                if (item.RelationShip == 'Active Part' && item.PartId == $scope.CustomerOrderModel.alternatePartData.lineItem.PartId && $scope.CustomerOrderModel.alternatePartData.lineItem.VONumber != null) {
                    return;
                }
                item.IsSelected = !item.IsSelected;
            }
            $scope.CustomerOrderModel.addAlternateParts = function() {
                $scope.CustomerOrderModel.showRelatedPartsClicked = false;
                if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'ServiceOrder') {
                    addMultipleServiceOrderLineItems();
                } else if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'Merchandise' || $scope.CustomerOrderModel.alternatePartData.SectionType == 'Deal Merchandise') {
                    addMultipleCOLineItems();
                }
            }
            $scope.CustomerOrderModel.disableAlternatePartButton = function() {
                var flag = true;
                if ($scope.CustomerOrderModel.alternatePartsList != undefined) {
                    for (var i = 0; i < $scope.CustomerOrderModel.alternatePartsList.length; i++) {
                        if ($scope.CustomerOrderModel.alternatePartsList[i].IsSelected) {
                            flag = false;
                            break;
                        }
                    }
                }
                return flag;
            }

            function addMultipleServiceOrderLineItems() {
                var alterList = $scope.CustomerOrderModel.alternatePartsList;
                var PartIdsList = [];
                for (var i = 0; i < alterList.length; i++) {
                    if (alterList[i].RelationShip != 'Active Part' && alterList[i].IsSelected == true) {
                        PartIdsList.push(alterList[i].PartId);
                    }
                }
                if (PartIdsList.length > 0) {
                    SOHeaderService.addServiceOrderLineItems(JSON.stringify(PartIdsList), $scope.CustomerOrderModel.alternatePartData.HeaderId).then(function(successfulSearchResult) {
                        $scope.CustomerOrderModel.addLineItemsFOrServiceJob(successfulSearchResult, $scope.CustomerOrderModel.alternatePartData.SoHeaderIndex, true);
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        $scope.searching = false;
                    });
                }
                for (var i = 0; i < alterList.length; i++) {
                    if (alterList[i].RelationShip == 'Active Part' && alterList[i].IsSelected == false) {
                        $scope.CustomerOrderModel.removeServiceItem($scope.CustomerOrderModel.alternatePartData.lineItem.Id, null, $scope.CustomerOrderModel.alternatePartData.SoHeaderIndex);
                    }
                }
            }

            function addMultipleCOLineItems() {
                var alterList = $scope.CustomerOrderModel.alternatePartsList;
                var COLIList = [];
                for (var i = 0; i < alterList.length; i++) {
                    if (alterList[i].RelationShip != 'Active Part' && alterList[i].IsSelected == true) {
                        COLIList.push(createCOlineitem(alterList[i]));
                    }
                }
                if (COLIList.length > 0) {
                    if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'Merchandise') {
                        $scope.SaveMerchandiseToserver(COLIList, true);
                    } else if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'Deal Merchandise') {
                        $scope.CustomerOrderModel.SaveDealMerchandiseToServer(COLIList, true);
                    }
                }
                for (var i = 0; i < alterList.length; i++) {
                    if (alterList[i].RelationShip == 'Active Part' && alterList[i].IsSelected == false) {
                        if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'Merchandise') {
                            removeMerchandiseLineItem($scope.CustomerOrderModel.alternatePartData.lineItem.Id, $scope.CustomerOrderModel.alternatePartData.HeaderId);
                        } else if ($scope.CustomerOrderModel.alternatePartData.SectionType == 'Deal Merchandise') {
                            removeDealMerchandiseLineItem($scope.CustomerOrderModel.alternatePartData.lineItem.Id, $scope.CustomerOrderModel.alternatePartData.HeaderId);
                        }
                    }
                }
            }

            function createCOlineitem(alternatePart) {
                var item = {};
                item.Qty = 1;
                item.Price = alternatePart.Price;
                item.PartId = alternatePart.PartId;
                item.DealId = $scope.CustomerOrderModel.alternatePartData.DealId;
                return item;
            }

            function removeMerchandiseLineItem(lineItemId, HeaderId) {
                CustomerInfoService.removeLineItemsInMerchGrid(lineItemId, HeaderId).then(function(successfulSearchResult) {
                    $scope.UpdateMerchandiseList(successfulSearchResult);
                    $scope.bindCheckOutList(successfulSearchResult.coInvoiceItemRecs);
                    $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }

            function removeDealMerchandiseLineItem(removelineitemId, HeaderId) {
                CustomerInfoService.removeLineItemsInMerchGrid(removelineitemId, HeaderId).then(function(successfulSearchResult) {
                    $scope.CustomerOrderModel.DealMerchandiseList = successfulSearchResult.DealFulfillmentSectionObj.DealMerchandiseList;
                    $scope.CustomerOrderModel.SpecialOrder = successfulSearchResult.DealFulfillmentSectionObj.DealSpecialOrderList;
                    $scope.CustomerOrderModel.DealMerchandiseTotal = successfulSearchResult.DealFulfillmentSectionObj.MerchandiseTotal;
                    $scope.CustomerOrderModel.DealUnresolvedFulfillmentList = successfulSearchResult.DealUnresolvedFulfillmentList;
                    $scope.CustomerOrderModel.editLineItemsForDealUnresolvedFulfillmentList();
                    $scope.CustomerOrderModel.editLineItemsForDealMerchandise();
                    $scope.CustomerOrderModel.UpdateSpecialOrder($scope.CustomerOrderModel.SpecialOrder);
                    if ($scope.CustomerOrderModel.DealUnresolvedFulfillmentList != undefined && $scope.CustomerOrderModel.DealUnresolvedFulfillmentList.length > 0) {
                        $scope.CustomerOrderModel.StockUnitMap();
                    }
                    CustomerInfoService.getCOHeaderDetailsByGridName($scope.CustomerOrderModel.coHeaderId, 'user,coInvoiceHeader').then(function(successfulSearchResult1) {
                        $scope.bindCheckOutList(successfulSearchResult1.coInvoiceItemRecs);
                        $scope.CustomerOrderModel.populateLeftSideHeadingLables();
                    }, function(errorSearchResult) {
                        console.log(errorSearchResult); //TODO
                    });
                }, function(errorSearchResult) {
                    responseData = errorSearchResult;
                });
            }
            angular.element(document).on("click", "#SupersededPart .modal-backdrop", function() {
                $scope.CustomerOrderModel.hideRelatedPartPopup();
            });
            $scope.LoadCustomerOrder();
        }
    ])
});