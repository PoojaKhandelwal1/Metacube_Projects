define(['Routing_AppJs_PK', 'ReturnVOServices', 'JqueryUI', 'dirNumberInput', 'DirPagination', 'VendorInfoCtrl', 'PartPopUpOnVendorOrderCtrl'], function(Routing_AppJs_PK, ReturnVOServices, JqueryUI, dirNumberInput, DirPagination, VendorInfoCtrl, PartPopUpOnVendorOrderCtrl) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('ReturnVOCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$filter', '$stateParams', '$state', 'ReturnVOServices', 'focusElement','$translate', function($scope, $timeout, $q, $rootScope, $sce, $filter, $stateParams, $state, ReturnVOServices, focusElement,$translate) {
        var Notification = injector1.get("Notification");
        $scope.RVO = {};
        $scope.RVO.activeSidepanelink = '#InfoSection';
        $scope.RVO.selectedItem = 'Info';
        $scope.RVO.disableButton = false;
        $scope.SearchToadd = {};
        $scope.typeToSearch = "";
        $scope.SearchableObjects = 'Part__c';
        $scope.PreferredObject = "Merchandise";
        $scope.RVO.IsQBEnabled = $Global.IsQBEnabled;
        $scope.RVO.displaySections = {
            'Info': true,
            'Return': true,
            'Finalize': true
        };
        $scope.RVO.dateFormat = $Global.DateFormat;
        $scope.RVO.ReturnedDate = {
            maxDate: new Date,
            dateFormat: $scope.RVO.dateFormat
        };
        $scope.RVO.showCalendar = function(IdVal) {
            angular.element("#" + IdVal).focus();
        }
        $scope.RVO.returnVOID = $stateParams.Id ? $stateParams.Id : null;
        $scope.RVO.loadInfo = function() {
            $scope.SearchToAddCallback = $scope.RVO.searchToAddCallback;
            ReturnVOServices.getReturnVODetail($scope.RVO.returnVOID).then(function(result) {
                setData(result, true);
            }, function(errorSearchResult) {});
        }
        $scope.RVO.scrollToPanel = function(event, sectionToscroll) {
            if (event != null) {
                event.preventDefault();
            }
            angular.element(document).off("scroll");
            var navBarHeightDiffrenceFixedHeaderOpen = 0;
            if ($rootScope.wrapperHeight == 95) {
                navBarHeightDiffrenceFixedHeaderOpen = 40;
            } else {
                navBarHeightDiffrenceFixedHeaderOpen = -25;
            }
            var target = angular.element("#" + sectionToscroll);
            angular.element('html, body').stop().animate({
                scrollTop: angular.element(target).offset().top - 120 - navBarHeightDiffrenceFixedHeaderOpen
            }, 500, function() {
                angular.element(document).on("scroll", function() {
                    $scope.RVO.onScroll();
                });
                $scope.RVO.onScroll();
            });
        }
        $scope.RVO.sidepanelLink = function(event, relatedContent) {
            event.preventDefault();
            $scope.RVO.displaySections[relatedContent] = true;
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
                    $scope.RVO.onScroll();
                });
                $scope.RVO.onScroll();
            });
        }
        $scope.RVO.onScroll = function() {
            if ($state.current.name === 'ReturnVO') {
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
                if ((isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + 100 - navBarHeightDiffrenceFixedHeaderOpen)) || ($scope.RVO.Data.VendorId == null) || ($scope.RVO.Data.VendorId == '')) {
                    activeSidepanelink = '#InfoSection';
                    selectedItem = 'Info';
                } else if (isElementDefined('#ReturnSection') && (scrollPos < angular.element('#ReturnSection').position().top + angular.element('#ReturnSection').height() + 80 - navBarHeightDiffrenceFixedHeaderOpen)) {
                    activeSidepanelink = '#ReturnSection';
                    selectedItem = 'Return';
                } else if (isElementDefined('#FinalizeSection') && (scrollPos < angular.element('#FinalizeSection').position().top + angular.element('#FinalizeSection').height() + 70 - navBarHeightDiffrenceFixedHeaderOpen)) {
                    if ($scope.RVO.showFinalizeSection()) {
                        activeSidepanelink = '#FinalizeSection';
                        selectedItem = 'Finalize';
                    }
                }
                $scope.RVO.activeSidepanelink = activeSidepanelink;
                $scope.RVO.selectedItem = selectedItem;
                if(!$scope.$$phase) {
                    $scope.$digest();
                }
            }
        }
        angular.element(document).off("scroll");
        angular.element(document).on("scroll", function() {
            $scope.RVO.onScroll();
        });
        $scope.RVO.dropDownItem = function(event, selectedSection) {
            var activeSection = $scope.RVO.activeSidepanelink.replace('#', '');
            $scope.RVO.selectedItem = selectedSection;
            if (activeSection != selectedSection) {
                $scope.RVO.sidepanelLink(event, selectedSection);
            }
        }
        $scope.RVO.showFinalizeSection = function() {
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.Status != 'Credited' && $scope.RVO.Data.ReturnVOLIList.length > 0) {
                return true;
            } else {
                return false;
            }
        }
        $scope.RVO.showSubmitReturnButton = function() {
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.Status == 'In Progress') {
                return true;
            } else {
                return false;
            }
        }
        $scope.RVO.showProcessCreditButton = function() {
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.Status == 'Approved') {
                return true;
            } else {
                return false;
            }
        }
        $scope.RVO.showSetAsApprovedButton = function() {
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.Status == 'Submitted') {
                return true;
            } else {
                return false;
            }
        }
        
        function validateUniqueCreditMemoForQB() {
        	if($scope.RVO.Data && $scope.RVO.Data.CreditMemoNumber) {
        		ReturnVOServices.validateUniqueCreditMemoForQB($scope.RVO.Data.CreditMemoNumber).then(function(successfulResult) {
        			if( successfulResult == 'Error QB') {
        				$scope.RVO.disableButton = false;
                    	Notification.error($translate.instant('Error_msg_qb '));
                    } else if( successfulResult == 'Duplicate') {
                    	$scope.RVO.disableButton = false;
                    	Notification.error('Duplicate credit number : ' + $scope.RVO.Data.CreditMemoNumber +  ' .This number already exists in your accounting application');
                    } else {
        				processCreditReturn();
        			}  
        		}, function(error) {
        			$scope.RVO.disableButton = false;
                    Notification.error($translate.instant('Generic_Some_error_occurred_please_refresh_the_page'));
                });
        	}
        }
        function processCreditReturn() {
        	ReturnVOServices.ProcessCreditReturnVO($scope.RVO.returnVOID).then(function(result) {
                setData(result);
                $scope.RVO.disableButton = false;
            });
        }
        $scope.RVO.ProcessCreditReturnVO = function() {
        	if($scope.RVO.IsQBEnabled) {
        		validateUniqueCreditMemoForQB();
        	} else {
        		processCreditReturn();
        	}
        }
        $scope.RVO.SubmitReturn = function() {
        	ReturnVOServices.SubmitReturn($scope.RVO.returnVOID).then(function(result) {
                setData(result);
                $scope.RVO.disableButton = false;
            });
            
        }
        $scope.RVO.SetAsApprovedReturnVO = function() {
        	ReturnVOServices.SetAsApprovedReturnVO($scope.RVO.returnVOID).then(function(result) {
                setData(result);
                $scope.RVO.disableButton = false;
            });
        }
        $scope.RVO.EnableFinaliseOrder = function() {
            return true;
        }
        $scope.RVO.refreshVendorOrder = function() {
            $scope.RVO.isrefresh = true;
            $scope.RVO.loadInfo();
        }
        $scope.RVO.addVendor = function(selectedVendorId) {
            ReturnVOServices.addVendor(selectedVendorId, $scope.RVO.returnVOID).then(function(result) {
                setData(result);
            });
        }
        $scope.RVO.showVendorInfoOverlay = function(event, vendorId) {
            $scope.$broadcast('VendorInfoPopUpEvent', vendorId);
            $scope.RVO.showInfoOverlay(event, vendorId);
        }
        $scope.RVO.hideVendorInfoOverlay = function() {
            angular.element('.Vendor-info-overlay').hide();
        }
        $scope.RVO.showInfoOverlay = function(event, vendorId) {
            var targetEle = angular.element(event.target);
            var elementWidth = targetEle.width();
            if (targetEle.width() > targetEle.parent().width()) {
                elementWidth = targetEle.parent().width() - 15;
            }
            angular.element('.Vendor-info-overlay').css('top', targetEle.offset().top - 45);
            angular.element('.Vendor-info-overlay').css('left', event.clientX);
            angular.element('.Vendor-info-overlay').show();
        }

        function applyCssOnPartPopUp(event, className) {
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
        $scope.RVO.openpartpopup = function(event, partId) {
            timer = $timeout(function() {
                $scope.$broadcast('PartPopUpEvent', partId);
                applyCssOnPartPopUp(event, '.PartPopupOnVenderOrder');
            }, 1000);
        }
        $scope.RVO.hidePartPopUp = function() {
            $timeout.cancel(timer);
            angular.element('.Vendor-Order-Part-Popup').hide();
        }
        $scope.RVO.RelatedList_addAction = function(event, typeToSearch) {
            $scope.RVO.setFocusToSearchBox(typeToSearch);
        }
        $scope.RVO.setFocusToSearchBox = function(typeToSearch) {
            $scope.typeToSearch = typeToSearch;
            $scope.PreferredObject = typeToSearch;
            if (typeToSearch == 'Merchandise') {
                $scope.SearchableObjects = 'Part__c';
            }
            focusElement('SearchToaddCutomer');
        }
        $scope.RVO.resetSearchBox = function() {
            $scope.typeToSearch = "";
            $scope.PreferredObject = "";
        }
        $scope.RVO.searchToAddCallback = function(selectedRecord) {
            if (selectedRecord.originalObject.Info == 'Merchandise') {
                $scope.RVO.addOneItemOnly(selectedRecord.originalObject);
            } else if (selectedRecord.originalObject.Info == 'Vendor') {
                var selectedRecordId = selectedRecord.originalObject.Value;
                if (selectedRecordId.length == 18) {
                    selectedRecordId = selectedRecordId.substring(0, 15);
                }
                $scope.RVO.addVendor(selectedRecordId);
            }
            $scope.RVO.resetSearchBox();
        }
        $scope.RVO.PrintReturnPDF = function() {
            var myWindow = window.open(url + "PrintReturnVendorOrder?id=" + $scope.RVO.returnVOID, "", "width=1200, height=600");
        }
        $scope.RVO.deleteReturnVendorOrder = function() {
            ReturnVOServices.deleteReturnVOLI($scope.RVO.returnVOID).then(function(successfulResult) {
                if (successfulResult == 'Success') {
                    Notification.success($Label.Generic_Deleted);
                    loadState($state, 'homePage');
                } else {
                    Notification.error('Something is changed on this Order');
                    $scope.RVO.loadInfo();
                }
            }, function(errorSearchResult) {
                Notification.error($Label.Generic_Error);
            });
        }
        $scope.RVO.showDeleteOrderLink = function() {
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.ReturnVOLIList.length == 0) {
                return true;
            } else {
                return false;
            }
        }
        $scope.RVO.addOneItemOnly = function(searchedRec) {
            if(searchedRec.AdditionalDetailsForPart.AvailableQty <= 0) {
                Notification.error('Cannot select a part which does not have a Qty Available');
                return;
            }
            if ($scope.RVO.Data != undefined && $scope.RVO.Data.ReturnVOLIList.length != 0) {
                for (var i = 0; i < $scope.RVO.Data.ReturnVOLIList.length; i++) {
                    if (searchedRec.Value == $scope.RVO.Data.ReturnVOLIList[i].PartId) {
                        Notification.error('Part already exists in this order');
                        return;
                    }
                }
            }
            var returnLineItemObj = {};
            returnLineItemObj.PartId = searchedRec.AdditionalDetailsForPart.PartId;
            returnLineItemObj.ReturnQty = searchedRec.AdditionalDetailsForPart.AvailableQty;
            returnLineItemObj.ItemCost = searchedRec.AdditionalDetailsForPart.Price;
            returnLineItemObj.Item = searchedRec.Name;
            returnLineItemObj.Description = searchedRec.Description;
            $scope.RVO.isSetFocus = true;
            var lineitemList = [];
            lineitemList.push(returnLineItemObj);
            $scope.RVO.saveLineItem(lineitemList);
        }
        $scope.RVO.saveLineItem = function(lineitemList) {
            ReturnVOServices.saveRVOLI($scope.RVO.returnVOID, JSON.stringify(lineitemList)).then(function(result) {
                setData(result);
            });
        }
        $scope.RVO.compareInfoandSave = function(key) {
            if ($scope.RVO.Data[key] != $scope.RVO.oldData[key]) {
                $scope.RVO.saveRVOInfo();
            }
        }
        $scope.RVO.saveRVOInfo = function() {
            var RVOHeaderInfo = angular.copy($scope.RVO.Data);
            delete RVOHeaderInfo['ReturnVOLIList'];
            ReturnVOServices.saveRVOH(JSON.stringify(RVOHeaderInfo)).then(function(result) {
                Notification.success($Label.Generic_Saved);
                setData(result);
            }, function(errorResult) {
                Notification.error(errorResult);
                setData($scope.RVO.oldData);
            });
        }
        $scope.RVO.editLineItem = function(event, index) {
            if ($scope.RVO.Data.Status == 'Credited' || !$rootScope.GroupOnlyPermissions['Vendor order']['create/modify']) {
                return;
            }
            if (event != undefined && event.target.tagName.toUpperCase() == 'INPUT' && event.target['type'] == 'text') {
                return;
            }
            var isEditEnabled = false;
            var EditRowIndex = 0;
            for (var i = 0; i < $scope.RVO.ReturnVOLIList_EditRow.length; i++) {
                if ($scope.RVO.ReturnVOLIList_EditRow[i].isEdit) {
                    isEditEnabled = true;
                    EditRowIndex = i;
                }
                $scope.RVO.ReturnVOLIList_EditRow[i].isEdit = false;
            }
            if (!isEditEnabled) {
                $scope.RVO.ReturnVOLIList_EditRow[index].isEdit = true;
                if ($scope.RVO.Data.Status == 'In Progress') {
                    focusElement('returnQty_' + index);
                } else {
                    focusElement('returnCost_' + index);
                }
            } else {
                var lineitemList = [];
                if (isBlankValue($scope.RVO.Data.ReturnVOLIList[EditRowIndex].ReturnQty)) {
                    $scope.RVO.Data.ReturnVOLIList[EditRowIndex].ReturnQty = $scope.RVO.oldData.ReturnVOLIList[EditRowIndex].ReturnQty
                }
                if (isBlankValue($scope.RVO.Data.ReturnVOLIList[EditRowIndex].ItemCost)) {
                    $scope.RVO.Data.ReturnVOLIList[EditRowIndex].ItemCost = $scope.RVO.oldData.ReturnVOLIList[EditRowIndex].ItemCost
                }
                lineitemList.push($scope.RVO.Data.ReturnVOLIList[EditRowIndex]);
                $scope.RVO.saveLineItem(lineitemList);
            }
        }
        $scope.RVO.editLineItemBlur = function(event, index) {
            if (event != undefined && event.target.tagName.toUpperCase() == 'INPUT' && event.target['type'] == 'text') {
                return;
            }
            if (isBlankValue($scope.RVO.Data.ReturnVOLIList[index].ReturnQty)) {
                $scope.RVO.Data.ReturnVOLIList[index].ReturnQty = $scope.RVO.oldData.ReturnVOLIList[index].ReturnQty
            }
            if (isBlankValue($scope.RVO.Data.ReturnVOLIList[index].ItemCost)) {
                $scope.RVO.Data.ReturnVOLIList[index].ItemCost = $scope.RVO.oldData.ReturnVOLIList[index].ItemCost
            }
            var lineitemList = [];
            lineitemList.push($scope.RVO.Data.ReturnVOLIList[index]);
            $scope.RVO.saveLineItem(lineitemList);
            angular.element('#SearchToaddCutomer').focus();
        }
        $scope.RVO.lineItemGoAction = function(index) {
            var selectedEditObj = $scope.RVO.ReturnVOLIList_EditRow[index];
            if (selectedEditObj.optionSelected == 0) {
                ReturnVOServices.deleteRVOLI($scope.RVO.returnVOID, $scope.RVO.Data.ReturnVOLIList[index].Id).then(function(result) {
                    setData(result);
                });
            }
        }

        function setData(result, isPageLoad) {
            $scope.RVO.isrefresh = false;
            $scope.RVO.Data = result;
            $scope.RVO.oldData = angular.copy(result);
            createEditModel();
            populateLeftSideHeadingLables();
            if (isPageLoad != undefined && isPageLoad == true) {
                setTimeout(function() {
                    $scope.RVO.scrollToPanel(null, 'ReturnSection');
                }, 1000);
            }
        }
        createEditModel = function() {
            $scope.RVO.ReturnVOLIList_EditRow = [];
            for (var i = 0; i < $scope.RVO.Data.ReturnVOLIList.length; i++) {
                $scope.RVO.ReturnVOLIList_EditRow.push({
                    isEdit: false,
                    radioValue: 1,
                    optionSelected: 0
                });
            }
            if ($scope.RVO.isSetFocus == true) {
                editLastRowandFocus();
            }
        }
        editLastRowandFocus = function() {
            var currentIndex = $scope.RVO.ReturnVOLIList_EditRow.length - 1;
            $scope.RVO.ReturnVOLIList_EditRow[currentIndex].isEdit = true;
            focusElement('returnQty_' + currentIndex);
            $scope.RVO.isSetFocus = false;
        }

        function populateLeftSideHeadingLables() {
            $scope.RVO.LeftSideHeadingLables = {};
            var currentHeadingSequenceIndex = 65;
            $scope.RVO.LeftSideHeadingLables['Info'] = String.fromCharCode(currentHeadingSequenceIndex++);
            $scope.RVO.LeftSideHeadingLables['Return'] = String.fromCharCode(currentHeadingSequenceIndex++);
            if ($scope.RVO.EnableFinaliseOrder() == true) {
                $scope.RVO.LeftSideHeadingLables['Finalize'] = String.fromCharCode(currentHeadingSequenceIndex++);
            }
        }
        $scope.RVO.loadInfo();
    }])
});