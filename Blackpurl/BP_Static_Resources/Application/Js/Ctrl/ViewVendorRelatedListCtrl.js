define(['Routing_AppJs_PK', 'ViewVendorRelatedListServices'], function (Routing_AppJs_PK, ViewVendorRelatedListServices) {
    var injector = angular.injector(['ViewVendorRelatedListServices', 'ng']);
    var injector1 = angular.injector(['ui-notification', 'ng']);

    angular.module('routerApp.ViewVendorChildApp').register.controller('ViewVendorRelatedListCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', function ($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state) {
        var POTypesServices = injector.get("POTypesServices");
        var ActiveOrdersServices = injector.get("ActiveOrdersServices");
        var ContactsServices = injector.get("ContactsServices");
        var ProductsServices = injector.get("ProductsServices");
        var Notification = injector1.get("Notification");
        
        $scope.ViewVendorRelatedListModal.RenderPOTypesSection = true;
        $scope.ViewVendorRelatedListModal.RenderActiveOrdersSection = true;
        $scope.ViewVendorRelatedListModal.POTypes_sectionModel = {
            poTypesChangesCount: 0,
            poTypesCurrentPage: 1,
            poTypesPageSize: 10,
            sorting: [{
                fieldName: "Code",
                sortDirection: ""
            }]
        };
        try {
            $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesPageSize = $Global.Related_List_Page_Size;
        } catch (ex) {}

        $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel = {
            activeOrdersChangesCount: 0,
            activeOrdersCurrentPage: 1,
            activeOrdersPageSize: 10,
            sorting: [{
                fieldName: "PO",
                sortDirection: ""
            }]
        };
        try {
            $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersPageSize = $Global.Related_List_Page_Size //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
        } catch (ex) {}

        $scope.ViewVendorRelatedListModal.Contacts_sectionModel = {
            contactsChangesCount: 0,
            contactsCurrentPage: 1,
            contactsPageSize: 10,
            sorting: [{
                    fieldName: "FirstName",
                    sortDirection: ""
                },
                {
                    fieldName: "LastName",
                    sortDirection: ""
                }
            ]
        };
        try {
            $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsPageSize = $Global.Related_List_Page_Size //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
        } catch (ex) {}

        $scope.ViewVendorRelatedListModal.Products_sectionModel = {
            productsChangesCount: 0,
            productsCurrentPage: 1,
            productsPageSize: 10,
            sorting: [{
                fieldName: "Type",
                sortDirection: ""
            }]
        };
        try {
            $scope.ViewVendorRelatedListModal.Products_sectionModel.productsPageSize = $Global.Related_List_Page_Size //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
        } catch (ex) {}

        var sortOrderMap = {
            "ASC": "DESC",
            "DESC": ""
        };

        $scope.ViewVendorRelatedListModal.helpText = {
            PO_Type_Help: 'Purchase Orders',
            PO_Type_Settings_Help: 'Purchase Orders Options',
            ActiveOrders_Help: 'Active Orders',
            ActiveOrders_Settings_Help: 'Active Orders Options',
            Contacts_Help: 'Contacts',
            Contacts_Settings_Help: 'Cotnacts Options',
            Products_Help: 'Products',
            Products_Settings_Help: 'Products Options'
        };

        $scope.ViewVendorRelatedListModal.hidePanel = function (event, id) {
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

        $scope.ViewVendorRelatedListModal.VendorRelatedLists_recordSaveCallback = function (objType, newUpdatedRecordsInfo) {
            if (objType == $Label.Purchase_Order_Type) {
                $scope.ViewVendorRelatedListModal.POTypes_recordSaveCallback(newUpdatedRecordsInfo);
            } else if (objType == $Label.Vendor_Order_Line_Item) {
                $scope.ViewVendorRelatedListModal.ActiveOrders_recordSaveCallback(newUpdatedRecordsInfo);
            } else if (objType == $Label.Contact_Object_Display_Label) {
                $scope.ViewVendorRelatedListModal.Contacts_recordSaveCallback(newUpdatedRecordsInfo);
            } else if (objType == $Label.Product) {
                $scope.ViewVendorRelatedListModal.Products_recordSaveCallback(newUpdatedRecordsInfo);
            }
        }

        $scope.ViewVendorRelatedListModal.initModals = function () {
            $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal();
            $scope.ViewVendorRelatedListModal.ActiveOrders_initEditRowsModal();
            $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal();
            $scope.ViewVendorRelatedListModal.Products_initEditRowsModal();
        }

        $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal = function () {
            $scope.ViewVendorRelatedListModal.POTypes_editRow = [];
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length; i++) {
                $scope.ViewVendorRelatedListModal.POTypes_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }

        /**
         * Method to handle any updates in pagination controls
         */
        $scope.ViewVendorRelatedListModal.POTypes_paginationControlsAction = function () {
            POTypesServices.getPaginatedPOTypesForVendor($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.POTypes_sectionModel)
                .then(function (poTypesInfo) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = poTypesInfo.TotalPOTypes;
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes = poTypesInfo.POTypes;
                    $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal();

                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        /**
         * Method to handle sorting controls
         */
        $scope.ViewVendorRelatedListModal.POTypes_sortControlsAction = function () {
            var newSortOrder = sortOrderMap[$scope.ViewVendorRelatedListModal.POTypes_sectionModel.sorting[0].sortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.ViewVendorRelatedListModal.POTypes_sectionModel.sorting[0].sortDirection = newSortOrder;
            $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesCurrentPage = 1;
            $scope.ViewVendorRelatedListModal.POTypes_paginationControlsAction();
        }

        /**
         * Method for DOM action: Select record as preferred
         */	
        $scope.ViewVendorRelatedListModal.POTypes_makeDefault = function (event, index) {
            event.stopPropagation();
            /* Invoke add purchase order type UPDATE DEFAULT service */
            POTypesServices.updateDefaultPOType($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].Id, !$scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].IsDefault
                )
                .then(function (resultInfo) {
                    if (resultInfo.indexOf(',') != -1) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = parseInt(resultInfo.substring(0, resultInfo.indexOf(",")));
                    } else {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = parseInt(resultInfo);
                    }

                    /* If new value to update is true, then update other default to false and then update new value */
                    if (!$scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].IsDefault == true) {
                        for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length; i++) {
                            if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[i].IsDefault) {
                                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[i].IsDefault = false;
                            }
                        }
                    }
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].IsDefault = !$scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].IsDefault;
                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        /**
         * Method for DOM action: Add
         */
        $scope.ViewVendorRelatedListModal.POTypes_addAction = function (event) {
            $scope.$parent.POTypeCompModal.openAddPOTypePopup($scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Update relation field value action
         */
        $scope.ViewVendorRelatedListModal.POTypes_updateAction = function (poTypeId) {
            $scope.$parent.POTypeCompModal.openEditPOTypePopup(poTypeId, $scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Method for DOM action: Add after saving record
         */
        $scope.ViewVendorRelatedListModal.POTypes_recordSaveCallback = function (newPOTypeDetails) {
            if (newPOTypeDetails[0].isError == true) {
                Notification.info(newPOTypeDetails[0].ErrorMsg);
            } else {
                var newRecords = [newPOTypeDetails[0].POTypeRecord];
                var indexPosition = $scope.ViewVendorRelatedListModal.POTypes_getRecordIndex(newRecords[0].Id);

                /* if indexPosition is null, means the record is inserted in database so add the record in data model at top and focus on the record row */
                if (indexPosition == null) {
                    var initIndex = ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes == null || $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length == 0) ?
                        0 : ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[0].IsDefault) ? 1 : 0;
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.splice(initIndex, 0, newRecords[0]);
                    $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal();

                    if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length > $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesPageSize) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length = $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesPageSize;
                    }
                    angular.element("#PO_Types_row" + initIndex).focus();
                } else {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[indexPosition] = newRecords[0];
                    angular.element("#PO_Types_row" + indexPosition).focus();
                }

                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = newPOTypeDetails[0].TotalPOTypes;
                setTimeout(function () {
                    $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesChangesCount++;
                }, 10);
                Notification.success($Label.Generic_Saved);
                $scope.$parent.POTypeCompModal.closePopup();
            }
        }

        /**
         * Method to get the index value of POType record Id in current data model if exists
         */
        $scope.ViewVendorRelatedListModal.POTypes_getRecordIndex = function (recId) {
            var indexPosition = null;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes.length; i++) {
                if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[i].Id == recId) {
                    indexPosition = i;
                    break;
                }
            }
            return indexPosition;
        }

        /**
         * Method to open row in edit mode
         */
        $scope.ViewVendorRelatedListModal.POTypes_openRowAsEdit = function (event, index) {
            event.stopPropagation();
            var editRowIndex = $scope.ViewVendorRelatedListModal.POTypes_closeEditRows();

            if (editRowIndex != index) {
                $scope.ViewVendorRelatedListModal.POTypes_editRow[index].isEdit = true;
                setTimeout(function () {
                    angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                }, 10);
            }
        }

        /**
         * Method to close row from edit mode
         */
        $scope.ViewVendorRelatedListModal.POTypes_closeEditRows = function (event) {
            var editRowIndex;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.POTypes_editRow.length; i++) {
                if ($scope.ViewVendorRelatedListModal.POTypes_editRow[i].isEdit == true) {
                    $scope.ViewVendorRelatedListModal.POTypes_editRow[i].isEdit = false;
                    editRowIndex = i;
                    break;
                }
            }
            return editRowIndex;
        }

        /**
         * Edit row "GO" Action
         */
        $scope.ViewVendorRelatedListModal.POTypes_GoAction = function (index) {
            /* selected radio value == 1 Means Edit the record in the list */
            if ($scope.ViewVendorRelatedListModal.POTypes_editRow[index].radioValue == 1) {
                $scope.ViewVendorRelatedListModal.POTypes_updateAction($scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].Id);
            } else if ($scope.ViewVendorRelatedListModal.POTypes_editRow[index].radioValue == 2) {
                /* selected radio value == 2 Means delete the record from the list
                   Invoke add purchase order type REMOVE service */
                POTypesServices.removePOType($scope.ViewVendorRelatedListModal.VendorId,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].Id,
                        $scope.ViewVendorRelatedListModal.POTypes_sectionModel
                    )
                    .then(function (newPOTypesDetails) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes = newPOTypesDetails.POTypes;
                        $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal();
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = newPOTypesDetails.TotalPOTypes;

                        if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes % $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesPageSize == 0) {
                            $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesCurrentPage--;
                            $scope.ViewVendorRelatedListModal.POTypes_paginationControlsAction();
                        } else {
                            setTimeout(function () {
                                $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesChangesCount++;
                            }, 10);
                        }
                        Notification.success($Label.Generic_Deleted);
                    }, function (errorSearchResult) {
                        Notification.error($Label.ViewVendorRelatedListJS_Can_t_remove_Purchase);
                    });
            }
        }

        $scope.ViewVendorRelatedListModal.ActiveOrders_initEditRowsModal = function () {
            $scope.ViewVendorRelatedListModal.ActiveOrders_editRow = [];
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders.length; i++) {
                $scope.ViewVendorRelatedListModal.ActiveOrders_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }

        /**
         * Method to handle any updates in pagination controls
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_paginationControlsAction = function () {
            ActiveOrdersServices.getPaginatedActiveOrdersForVendor($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel)
                .then(function (activeOrdersInfo) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalActiveOrders = activeOrdersInfo.TotalActiveOrders;
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders = activeOrdersInfo.activeOrders;

                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        /**
         * Method to handle sorting controls
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_sortControlsAction = function () {
            var newSortOrder = sortOrderMap[$scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.sorting[0].sortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.sorting[0].sortDirection = newSortOrder;
            $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersCurrentPage = 1;
            $scope.ViewVendorRelatedListModal.ActiveOrders_paginationControlsAction();
        }

        /**
         * Method for DOM action: Add
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_addAction = function (event) {
        	//TODO remove after checking
    	}

        /**
         * Update relation field value action
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_updateAction = function (activeOrderId) {
            //TODO remove after checking
        }

        /**
         * Method for DOM action: Add after saving record
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_recordSaveCallback = function (newActiveOrderDetails) {
            if (newActiveOrderDetails[0].isError == true) {
                Notification.info(newActiveOrderDetails[0].ErrorMsg);
            } else {
                var newRecords = [newActiveOrderDetails[0].POTypeRecord];
                var indexPosition = $scope.ViewVendorRelatedListModal.ActiveOrders_getRecordIndex(newRecords[0].Id);
                /* if indexPosition is null, means the record is inserted in database so add the record in data model at top and focus on the record row */
                if (indexPosition == null) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders = newRecords.concat($scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders);
                    $scope.ViewVendorRelatedListModal.ActiveOrders_initEditRowsModal();

                    if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders.length > $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersPageSize) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders.length = $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersPageSize;
                    }
                    angular.element("#ActiveOrders_row0").focus();
                } else {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders[indexPosition] = newRecords[0];
                    angular.element("#ActiveOrders_row" + indexPosition).focus();
                }

                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalActiveOrders = newActiveOrderDetails[0].TotalActiveOrders;
                setTimeout(function () {
                    $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersCurrentPage++;
                }, 10);
                Notification.success($Label.Generic_Saved);
            }
        }

        /**
         * Method to get the index value of Active Order record Id in current data model if exists
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_getRecordIndex = function (recId) {
            var indexPosition = null;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders.length; i++) {
                if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders[i].Id == recId) {
                    indexPosition = i;
                    break;
                }
            }
            return indexPosition;
        }

        /**
         * Method to open row in edit mode
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_openRowAsEdit = function (event, index) {
            event.stopPropagation();
            var editRowIndex = $scope.ViewVendorRelatedListModal.ActiveOrders_closeEditRows();
            if (editRowIndex != index) {
                $scope.ViewVendorRelatedListModal.ActiveOrders_editRow[index].isEdit = true;
                setTimeout(function () {
                    angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                }, 10);
            }
        }

        /**
         * Method to close row from edit mode
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_closeEditRows = function (event) {
            var editRowIndex;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.ActiveOrders_editRow.length; i++) {
                if ($scope.ViewVendorRelatedListModal.ActiveOrders_editRow[i].isEdit == true) {
                    $scope.ViewVendorRelatedListModal.ActiveOrders_editRow[i].isEdit = false;
                    editRowIndex = i;
                    break;
                }
            }
            return editRowIndex;
        }

        /**
         * Edit row "GO" Action
         */
        $scope.ViewVendorRelatedListModal.ActiveOrders_GoAction = function (index) {
            /* selected radio value == 1 Means Edit the record in the list */
            if ($scope.ViewVendorRelatedListModal.ActiveOrders_editRow[index].radioValue == 1) {
                $scope.ViewVendorRelatedListModal.ActiveOrders_updateAction($scope.ViewVendorRelatedListModal.VendorRelatedInfo.ActiveOrders[index].Id);
            }
        }

        $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal = function () {
            $scope.ViewVendorRelatedListModal.Contacts_editRow = [];
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts.length; i++) {
                $scope.ViewVendorRelatedListModal.Contacts_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }

        /**
         * Method to handle any updates in pagination controls
         */
        $scope.ViewVendorRelatedListModal.Contacts_paginationControlsAction = function () {
            ContactsServices.getPaginatedContactsForVendor($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.Contacts_sectionModel)
                .then(function (contactsInfo) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = contactsInfo.TotalContacts;
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts = contactsInfo.Contacts;
                    $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal();

                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        /**
         * Method to handle sorting controls
         */
        $scope.ViewVendorRelatedListModal.Contacts_sortControlsAction = function () {
            var newSortOrder = sortOrderMap[$scope.ViewVendorRelatedListModal.Contacts_sectionModel.sorting[0].sortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.ViewVendorRelatedListModal.Contacts_sectionModel.sorting[0].sortDirection = newSortOrder;
            $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsCurrentPage = 1;
            $scope.ViewVendorRelatedListModal.Contacts_paginationControlsAction();
        }

        /**
         * Method for DOM action: Select record as preferred
         */	
        $scope.ViewVendorRelatedListModal.Contacts__updateRelation = function (index) {
            /* Invoke add purchase order type UPDATE DEFAULT service */
            ContactsServices.updateContactRelation($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Id,
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Relation
                )
                .then(function (resultInfo) {
                    if (resultInfo.indexOf(',') != -1) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = parseInt(resultInfo.substring(0, resultInfo.indexOf(",")));
                    } else {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = parseInt(resultInfo);
                    }

                    angular.element("#Contacts_row" + index).find("select").filter(':first').focus();
                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        $scope.ViewVendorRelatedListModal.Contacts_addAction = function (event) {
            $scope.$parent.VendorContactModal.openAddVendorContactPopup($scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Update relation field value action
         */
        $scope.ViewVendorRelatedListModal.Contacts_updateAction = function (contactId) {
            $scope.$parent.VendorContactModal.openEditVendorContactPopup(contactId, $scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Method for DOM action: Add after saving record
         */
        $scope.ViewVendorRelatedListModal.Contacts_recordSaveCallback = function (newContactDetails) {
            if (newContactDetails[0].isError == true) {
                Notification.info(newContactDetails[0].ErrorMsg);
            } else {
                var newRecords = [newContactDetails[0].ContactRecord];
                var indexPosition = $scope.ViewVendorRelatedListModal.Contacts_getRecordIndex(newRecords[0].Id);

                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = newContactDetails[0].TotalContacts;
                setTimeout(function () {
                    $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsChangesCount++;
                }, 10);

                /* if indexPosition is null, means the record is inserted in database so add the record in data model at top and focus on the record row */
                var initIndex = 0;
                if (indexPosition == null) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts.splice(initIndex, 0, newRecords[0]);
                    $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal();

                    if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts.length > $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsPageSize) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts.length = $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsPageSize;
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[indexPosition] = newRecords[0];
                }

                Notification.success($Label.Generic_Saved);
                $scope.$parent.VendorContactModal.closePopup();
                setTimeout(function () {
                    angular.element("#Contacts_row" + initIndex).find("select").filter(':first').focus();
                }, 10);
            }
        }

        /**
         * Method to get the index value of Contact record Id in current data model if exists
         */
        $scope.ViewVendorRelatedListModal.Contacts_getRecordIndex = function (recId) {
            var indexPosition = null;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts.length; i++) {
                if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[i].Id == recId) {
                    indexPosition = i;
                    break;
                }
            }
            return indexPosition;
        }

        /**
         * Method to open row in edit mode
         */
        $scope.ViewVendorRelatedListModal.Contacts_openRowAsEdit = function (event, index) {
            event.stopPropagation();
            var editRowIndex = $scope.ViewVendorRelatedListModal.Contacts_closeEditRows();
            if (editRowIndex != index) {
                $scope.ViewVendorRelatedListModal.Contacts_editRow[index].isEdit = true;
                setTimeout(function () {
                    angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                }, 10);
            }
        }

        /**
         * Method to close row from edit mode
         */
        $scope.ViewVendorRelatedListModal.Contacts_closeEditRows = function (event) {
            var editRowIndex;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.Contacts_editRow.length; i++) {
                if ($scope.ViewVendorRelatedListModal.Contacts_editRow[i].isEdit == true) {
                    $scope.ViewVendorRelatedListModal.Contacts_editRow[i].isEdit = false;
                    editRowIndex = i;
                    break;
                }
            }
            return editRowIndex;
        }

        /**
         * Edit row "GO" Action
         */
        $scope.ViewVendorRelatedListModal.Contacts_GoAction = function (index) {
            /* selected radio value == 1 Means Edit the record in the list */
            if ($scope.ViewVendorRelatedListModal.Contacts_editRow[index].radioValue == 1) {
                $scope.ViewVendorRelatedListModal.Contacts_updateAction($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Id);
            } else if ($scope.ViewVendorRelatedListModal.Contacts_editRow[index].radioValue == 2) {
                /* selected radio value == 2 Means delete the record from the list */
                ContactsServices.removeContact($scope.ViewVendorRelatedListModal.VendorId,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Id,
                        $scope.ViewVendorRelatedListModal.Contacts_sectionModel
                    )
                    .then(function (newContactsDetails) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts = newContactsDetails.Contacts;
                        $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal();
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = newContactsDetails.TotalContacts;

                        if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts % $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsPageSize == 0) {
                            $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsCurrentPage--;
                            $scope.ViewVendorRelatedListModal.Contacts_paginationControlsAction();
                        } else {
                            setTimeout(function () {
                                $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsChangesCount++;
                            }, 10);
                        }

                        Notification.success($Label.Generic_Deleted);
                    }, function (errorSearchResult) {
                        Notification.error($Label.Generic_Error);
                    });
            }
        }

        $scope.ViewVendorRelatedListModal.Products_initEditRowsModal = function () {
            $scope.ViewVendorRelatedListModal.Products_editRow = [];
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products.length; i++) {
                $scope.ViewVendorRelatedListModal.Products_editRow.push({
                    isEdit: false,
                    radioValue: 0,
                    optionSelected: 0
                });
            }
        }

        /**
         * Method to handle any updates in pagination controls
         */
        $scope.ViewVendorRelatedListModal.Products_paginationControlsAction = function () {
            ProductsServices.getPaginatedProductsForVendor($scope.ViewVendorRelatedListModal.VendorId,
                    $scope.ViewVendorRelatedListModal.Products_sectionModel)
                .then(function (productsInfo) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalProducts = productsInfo.TotalProducts;
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products = productsInfo.Products;
                    $scope.ViewVendorRelatedListModal.Products_initEditRowsModal();

                    setTimeout(function () {
                        $scope.ViewVendorRelatedListModal.Products_sectionModel.productsChangesCount++;
                    }, 10);
                }, function (errorSearchResult) {
                    Notification.error($Label.Generic_Error);
                });
        }

        /**
         * Method to handle sorting controls
         */
        $scope.ViewVendorRelatedListModal.Products_sortControlsAction = function () {
            var newSortOrder = sortOrderMap[$scope.ViewVendorRelatedListModal.Products_sectionModel.sorting[0].sortDirection];
            if (newSortOrder == null || newSortOrder == undefined) {
                newSortOrder = "ASC";
            }
            $scope.ViewVendorRelatedListModal.Products_sectionModel.sorting[0].sortDirection = newSortOrder;
            $scope.ViewVendorRelatedListModal.Products_sectionModel.productsCurrentPage = 1;
            $scope.ViewVendorRelatedListModal.Products_paginationControlsAction();
        }

        /**
         * Method for DOM action: Add
         */
        $scope.ViewVendorRelatedListModal.Products_addAction = function (event) {
            $scope.$parent.ProductCompModal.openAddProductPopup($scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Update relation field value action
         */
        $scope.ViewVendorRelatedListModal.Products_updateAction = function (productId) {
            $scope.$parent.ProductCompModal.openEditProductPopup(productId, $scope.ViewVendorRelatedListModal.VendorId);
        }

        /**
         * Method for DOM action: Add after saving record
         */
        $scope.ViewVendorRelatedListModal.Products_recordSaveCallback = function (newProductDetails) {
            if (newProductDetails[0].isError == true) {
                Notification.info(newProductDetails[0].ErrorMsg);
            } else {
                var newRecords = [newProductDetails[0].ProductRecord];
                var indexPosition = $scope.ViewVendorRelatedListModal.Products_getRecordIndex(newRecords[0].Id);
                /* if indexPosition is null, means the record is inserted in database so add the record in data model at top and focus on the record row */
                var initIndex = 0;
                if (indexPosition == null) {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products.splice(initIndex, 0, newRecords[0]);
                    $scope.ViewVendorRelatedListModal.Products_initEditRowsModal();

                    if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products.length > $scope.ViewVendorRelatedListModal.Products_sectionModel.productsPageSize) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products.length = $scope.ViewVendorRelatedListModal.Products_sectionModel.productsPageSize;
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products[indexPosition] = newRecords[0];
                    initIndex = indexPosition;
                }
                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalProducts = newProductDetails[0].TotalProducts;
                Notification.success($Label.Generic_Saved);
                $scope.$parent.ProductCompModal.closePopup();
                setTimeout(function () {
                    $scope.ViewVendorRelatedListModal.Products_sectionModel.productsChangesCount++;
                    angular.element("#PO_Types_row" + initIndex).focus();
                }, 10);
            }
        }

        /**
         * Method to get the index value of Product record Id in current data model if exists
         */
        $scope.ViewVendorRelatedListModal.Products_getRecordIndex = function (recId) {
            var indexPosition = null;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products.length; i++) {
                if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products[i].Id == recId) {
                    indexPosition = i;
                    break;
                }
            }
            return indexPosition;
        }

        /**
         * Method to open row in edit mode
         */
        $scope.ViewVendorRelatedListModal.Products_openRowAsEdit = function (event, index) {
            event.stopPropagation();
            var editRowIndex = $scope.ViewVendorRelatedListModal.Products_closeEditRows();
            if (editRowIndex != index) {
                $scope.ViewVendorRelatedListModal.Products_editRow[index].isEdit = true;
            }
        }

        /**
         * Method to close row from edit mode
         */
        $scope.ViewVendorRelatedListModal.Products_closeEditRows = function (event) {
            var editRowIndex;
            for (i = 0; i < $scope.ViewVendorRelatedListModal.Products_editRow.length; i++) {
                if ($scope.ViewVendorRelatedListModal.Products_editRow[i].isEdit == true) {
                    $scope.ViewVendorRelatedListModal.Products_editRow[i].isEdit = false;
                    editRowIndex = i;
                    break;
                }
            }
            return editRowIndex;
        }

        $scope.ViewVendorRelatedListModal.Products_GoAction = function (index) {
            /* selected radio value == 1 Means Edit the record in the list */
            if ($scope.ViewVendorRelatedListModal.Products_editRow[index].radioValue == 1) {
                $scope.ViewVendorRelatedListModal.Products_updateAction($scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products[index].Id);
            } else if ($scope.ViewVendorRelatedListModal.Products_editRow[index].radioValue == 2) {
                /* selected radio value == 2 Means delete the record from the list
                   Invoke add purchase order type REMOVE service */
                ProductsServices.removeProduct($scope.ViewVendorRelatedListModal.VendorId,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products[index].Id,
                        $scope.ViewVendorRelatedListModal.Products_sectionModel
                    )
                    .then(function (newProductsDetails) {
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Products = newProductsDetails.Products;
                        $scope.ViewVendorRelatedListModal.Products_initEditRowsModal();
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalProducts = newProductsDetails.TotalProducts;

                        if ($scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalProducts % $scope.ViewVendorRelatedListModal.Products_sectionModel.productsPageSize == 0) {
                            $scope.ViewVendorRelatedListModal.Products_sectionModel.productsCurrentPage--;
                            $scope.ViewVendorRelatedListModal.Products_paginationControlsAction();
                        } else {
                            setTimeout(function () {
                                $scope.ViewVendorRelatedListModal.Products_sectionModel.productsChangesCount++;
                            }, 10);
                        }
                        Notification.success($Label.Generic_Deleted);
                    }, function (errorSearchResult) {
                        Notification.error($Label.Generic_Error);
                    });
            }
        }
    }])
});