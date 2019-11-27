define(['Routing_AppJs_PK', 'ViewVendorServices', 'ViewVendorRelatedListServices', 'DirPagination', 'mapsApiJs', 'tel', 'dirNumberInput'],
    function (Routing_AppJs_PK, ViewVendorServices, ViewVendorRelatedListServices, DirPagination, mapsApiJs, tel, dirNumberInput) {
        var injector = angular.injector(['ui-notification', 'ng']);

        Routing_AppJs_PK.controller('ViewVendorCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'VendorInfoService', 'POTypesServices', 'ActiveOrdersServices', 'ContactsServices', 'ProductsServices', '$translate', function ($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, VendorInfoService, POTypesServices, ActiveOrdersServices, ContactsServices, ProductsServices, $translate) {
            var Notification = injector.get("Notification");
            $scope.ViewVendor = {};
            $scope.SearchToadd = {};
            $scope.typeToSearch = 'None';
            $scope.ViewVendor.vendorId = $stateParams.Id;
            $scope.ViewVendor.ShowMore = true;
            $scope.ViewVendor.ShowContent = false;
            $scope.ViewVendor.VendorInfo = {};
            $scope.ViewVendor.VendorInfo.VendorDetailRec = {};
            $scope.ViewVendor.activeAddress = "BillingAddress";
            $scope.ViewVendor.addressOnMap = "";
            $scope.POTypeCompModal = {};
            $scope.VendorContactModal = {};
            $scope.ProductCompModal = {};
            $scope.ViewVendorRelatedListModal = {};
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
                $scope.ViewVendorRelatedListModal.POTypes_sectionModel.poTypesPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
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
                $scope.ViewVendorRelatedListModal.ActiveOrders_sectionModel.activeOrdersPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
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
                $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
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
                $scope.ViewVendorRelatedListModal.Products_sectionModel.productsPageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            $scope.ViewVendorRelatedListModal.TaxExemptionPageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "ItemDesc",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.ViewVendorRelatedListModal.TaxExemptionPageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size; //'{!JSENCODE(TEXT(Related_List_Page_Size))}';
            } catch (ex) {}

            var sortOrderMap = {
                "ASC": "DESC",
                "DESC": ""
            };

            $scope.ViewVendorRelatedListModal.helpText = {
                PO_Type_Help: $translate.instant('Vendor_Order_Types'),
                PO_Type_Settings_Help: $translate.instant('Vendor_order_options'),
                ActiveOrders_Help: $translate.instant('Active_Orders'),
                ActiveOrders_Settings_Help: $translate.instant('Tooltip_Active_Orders_Settings'),
                Contacts_Help: $translate.instant('Tooltip_Contacts'),
                Contacts_Settings_Help: $translate.instant('Tooltip_Contacts_Settings'),
                Products_Help: $translate.instant('Label_Products'),
                Products_Settings_Help: $translate.instant('Tooltip_Products_Settings')
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

            /**
             * Related lists save callback action
             */
            $scope.ViewVendorRelatedListModal.VendorRelatedLists_recordSaveCallback = function (objType, newUpdatedRecordsInfo) {
                if (objType == "{!$ObjectType.PO_Type__c.label}") {
                    $scope.ViewVendorRelatedListModal.POTypes_recordSaveCallback(newUpdatedRecordsInfo);
                } else if (objType == "{!$ObjectType.Vendor_Order_Line_Item__c.label}") {
                    $scope.ViewVendorRelatedListModal.ActiveOrders_recordSaveCallback(newUpdatedRecordsInfo);
                } else if (objType == "{!$ObjectType.Contact.label}") {
                    $scope.ViewVendorRelatedListModal.Contacts_recordSaveCallback(newUpdatedRecordsInfo);
                } else if (objType == "{!$ObjectType.Product__c.label}") {
                    $scope.ViewVendorRelatedListModal.Products_recordSaveCallback(newUpdatedRecordsInfo);
                }
            }

            /**
             * Initialize/Update default modals
             */
            $scope.ViewVendorRelatedListModal.initModals = function () {
                $scope.ViewVendorRelatedListModal.POTypes_initEditRowsModal();
                $scope.ViewVendorRelatedListModal.ActiveOrders_initEditRowsModal();
                $scope.ViewVendorRelatedListModal.Contacts_initEditRowsModal();
                $scope.ViewVendorRelatedListModal.Products_initEditRowsModal();
                $scope.ViewVendorRelatedListModal.TaxExemption_initEditRowsModal();
            }

            /**
             * Purchase Order types subsection methods
             */
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
                        Notification.error($translate.instant('Generic_Error'));
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
                // Invoke add purchase order type UPDATE DEFAULT service
                POTypesServices.updateDefaultPOType($scope.ViewVendorRelatedListModal.VendorId,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].Id, !$scope.ViewVendorRelatedListModal.VendorRelatedInfo.POTypes[index].IsDefault
                    )
                    .then(function (resultInfo) {
                        if (typeof (resultInfo) == 'string' && resultInfo.indexOf(',') != -1) {
                            $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = parseInt(resultInfo.substring(0, resultInfo.indexOf(",")));
                        } else {
                            $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalPOTypes = parseInt(resultInfo);
                        }

                        // If new value to update is true, then update other default to false and then update new value
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
                        Notification.error($translate.instant('Generic_Error'));
                    });
            }

            $scope.ViewVendorRelatedListModal.POTypes_addAction = function (event) {
                loadState($state, 'ViewVendor.AddEditPOType', {
                    AddEditPOTypeParams: {
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId
                    }
                });
            }

            $scope.ViewVendorRelatedListModal.POTypes_updateAction = function (poTypeId) {
                loadState($state, 'ViewVendor.AddEditPOType', {
                    AddEditPOTypeParams: {
                        poTypeId: poTypeId,
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId
                    }
                });
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

                    Notification.success($translate.instant('Generic_Saved'));
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
                if ($rootScope.GroupOnlyPermissions['Vendors'].enabled) {
                    event.stopPropagation();
                    var editRowIndex = $scope.ViewVendorRelatedListModal.POTypes_closeEditRows();
                    if (editRowIndex != index) {
                        $scope.ViewVendorRelatedListModal.POTypes_editRow[index].isEdit = true;
                        $scope.ViewVendorRelatedListModal.POTypes_editRow[index].radioValue = 1;
                        setTimeout(function () {
                            angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                        }, 10);
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.POTypes_editRow[index].isEdit = false;
                }
            }

            /**
             * Method to close row from edit mode
             */
            $scope.ViewVendorRelatedListModal.POTypes_closeEditRows = function (event) {
                var editRowIndex;
                for (i = 0; i < $scope.ViewVendorRelatedListModal.POTypes_editRow.length; i++) {
                    $scope.ViewVendorRelatedListModal.POTypes_editRow[i].radioValue = 0;
                }
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
                            Notification.success($translate.instant('Generic_Deleted'));
                        }, function (errorSearchResult) {
                            Notification.error($translate.instant('NewViewVendorRelatedList_Can_t_remove_Vendor'));
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
                        Notification.error($translate.instant('Generic_Error'));
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

            $scope.ViewVendorRelatedListModal.ActiveOrders_addAction = function (event) {
                //TODO Remove after checking
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

                    Notification.success($translate.instant('Generic_Saved'));
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
                    $scope.ViewVendorRelatedListModal.ActiveOrders_editRow[index].radioValue = 1;
                    setTimeout(function () {
                        angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                    }, 10);
                }
            }

            // Method to close row from edit mode
            $scope.ViewVendorRelatedListModal.ActiveOrders_closeEditRows = function (event) {
                var editRowIndex;
                for (i = 0; i < $scope.ViewVendorRelatedListModal.ActiveOrders_editRow.length; i++) {
                    $scope.ViewVendorRelatedListModal.ActiveOrders_editRow[i].radioValue = 0;
                }
                for (i = 0; i < $scope.ViewVendorRelatedListModal.ActiveOrders_editRow.length; i++) {
                    if ($scope.ViewVendorRelatedListModal.ActiveOrders_editRow[i].isEdit == true) {
                        $scope.ViewVendorRelatedListModal.ActiveOrders_editRow[i].isEdit = false;
                        editRowIndex = i;
                        break;
                    }
                }
                return editRowIndex;
            }

            /*
             * Edit row "GO" Action
             */
            $scope.ViewVendorRelatedListModal.ActiveOrders_GoAction = function (index) {
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
                        Notification.error($translate.instant('Generic_Error'));
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
                // Invoke add purchase order type UPDATE DEFAULT service
                ContactsServices.updateContactRelation($scope.ViewVendorRelatedListModal.VendorId,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Id,
                        $scope.ViewVendorRelatedListModal.VendorRelatedInfo.Contacts[index].Relation
                    )
                    .then(function (resultInfo) {
                        if (typeof (resultInfo) == 'string' && resultInfo.indexOf(',') != -1) {
                            $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = parseInt(resultInfo.substring(0, resultInfo.indexOf(",")));
                        } else {
                            $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalContacts = parseInt(resultInfo);
                            Notification.success($translate.instant('Generic_Saved'));
                        }
                        angular.element("#Contacts_row" + index).find("select").filter(':first').focus();
                        setTimeout(function () {
                            $scope.ViewVendorRelatedListModal.Contacts_sectionModel.contactsChangesCount++;
                        }, 10);
                    }, function (errorSearchResult) {
                        Notification.error($translate.instant('Generic_Error'));
                    });
            }

            /**
             * Method for DOM action: Add
             */
            $scope.ViewVendorRelatedListModal.Contacts_addAction = function (event) {
                loadState($state, 'ViewVendor.AddEditVendorContact', {
                    AddEditVendorContactParams: {
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId,
                        country: $scope.ViewVendorRelatedListModal.VendorCountry
                    }
                });
            }

            /**
             * Update relation field value action
             */
            $scope.ViewVendorRelatedListModal.Contacts_updateAction = function (contactId) {
                loadState($state, 'ViewVendor.AddEditVendorContact', {
                    AddEditVendorContactParams: {
                        contactId: contactId,
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId,
                        country: $scope.ViewVendorRelatedListModal.VendorCountry
                    }
                });
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
                    Notification.success($translate.instant('Generic_Saved'));
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
                if ($rootScope.GroupOnlyPermissions['Vendors'].enabled) {
                    event.stopPropagation();
                    var editRowIndex = $scope.ViewVendorRelatedListModal.Contacts_closeEditRows();
                    if (editRowIndex != index) {
                        $scope.ViewVendorRelatedListModal.Contacts_editRow[index].isEdit = true;
                        $scope.ViewVendorRelatedListModal.Contacts_editRow[index].radioValue = 1;
                        setTimeout(function () {
                            angular.element(event.target).closest('tr').next().find('input').filter(':first').focus();
                        }, 10);
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.Contacts_editRow[index].isEdit = false;
                }
            }

            /**
             * Method to close row from edit mode
             */
            $scope.ViewVendorRelatedListModal.Contacts_closeEditRows = function (event) {
                var editRowIndex;
                for (i = 0; i < $scope.ViewVendorRelatedListModal.Contacts_editRow.length; i++) {
                    $scope.ViewVendorRelatedListModal.Contacts_editRow[i].radioValue = 0;
                }
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

                            Notification.success($translate.instant('Generic_Deleted'));
                        }, function (errorSearchResult) {
                            Notification.error($translate.instant('Generic_Error'));
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
                        Notification.error($translate.instant('Generic_Error'));
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
                loadState($state, 'ViewVendor.AddEditProduct', {
                    AddEditProductParams: {
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId
                    }
                });
            }

            /**
             * Update relation field value action
             */
            $scope.ViewVendorRelatedListModal.Products_updateAction = function (productId) {
                loadState($state, 'ViewVendor.AddEditProduct', {
                    AddEditProductParams: {
                        productId: productId,
                        vendorId: $scope.ViewVendorRelatedListModal.VendorId
                    }
                });
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
                        $scope.ViewVendorRelatedListModal.Products_closeEditRows();
                    }
                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalProducts = newProductDetails[0].TotalProducts;
                    Notification.success($translate.instant('Generic_Saved'));
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
                if ($rootScope.GroupOnlyPermissions['Vendor products'].enabled) {
                    event.stopPropagation();
                    var editRowIndex = $scope.ViewVendorRelatedListModal.Products_closeEditRows();
                    if (editRowIndex != index) {
                        $scope.ViewVendorRelatedListModal.Products_editRow[index].isEdit = true;
                        $scope.ViewVendorRelatedListModal.Products_editRow[index].radioValue = 1;
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.Products_editRow[index].isEdit = false;
                }
            }

            /**
             * Method to close row from edit mode
             */
            $scope.ViewVendorRelatedListModal.Products_closeEditRows = function (event) {
                var editRowIndex;
                for (i = 0; i < $scope.ViewVendorRelatedListModal.Products_editRow.length; i++) {
                    $scope.ViewVendorRelatedListModal.Products_editRow[i].radioValue = 0;
                }
                for (i = 0; i < $scope.ViewVendorRelatedListModal.Products_editRow.length; i++) {
                    if ($scope.ViewVendorRelatedListModal.Products_editRow[i].isEdit == true) {
                        $scope.ViewVendorRelatedListModal.Products_editRow[i].isEdit = false;
                        editRowIndex = i;
                        break;
                    }
                }
                return editRowIndex;
            }

            /**
             * Edit row "GO" Action
             */
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
                            if (newProductsDetails.responseStatus == 'error') {
                                Notification.error(newProductsDetails.response);
                            } else {
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
                                Notification.success($translate.instant('Generic_Deleted'));
                            }
                        }, function (errorSearchResult) {
                            Notification.error($translate.instant('Generic_Error'));
                        });
                }
            }

            $scope.ViewVendorRelatedListModal.TaxExemption_initEditRowsModal = function () {
                $scope.ViewVendorRelatedListModal.TaxExemptions_editRow = [];
                for (i = 0; i < $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TaxExemptionList.length; i++) {
                    $scope.ViewVendorRelatedListModal.TaxExemptions_editRow.push({
                        isEdit: false,
                        radioValue: 0,
                        optionSelected: 0
                    });
                }
            }

            $scope.ViewVendorRelatedListModal.editTaxExemptions = function (event, index) {
                if ($rootScope.GroupOnlyPermissions['Sales Taxes'].assign) {
                    $scope.ViewVendorRelatedListModal.TaxExemptions_editRow[index].radioValue = 0;

                    var isEditModeEnabled = false;
                    for (i = 0; i < $scope.ViewVendorRelatedListModal.TaxExemptions_editRow.length; i++) {
                        if ($scope.ViewVendorRelatedListModal.TaxExemptions_editRow[i].isEdit == true) {
                            isEditModeEnabled = true;
                        }
                        $scope.ViewVendorRelatedListModal.TaxExemptions_editRow[i].isEdit = false;
                    }
                    if (!isEditModeEnabled) {
                        $scope.ViewVendorRelatedListModal.TaxExemptions_editRow[index].isEdit = true;
                    }
                } else {
                    $scope.ViewVendorRelatedListModal.TaxExemptions_editRow[index].isEdit = false;
                }
            }

          /*  $scope.ViewVendorRelatedListModal.TaxExemption_GoAction = function (indexVal) {
                if ($scope.ViewVendorRelatedListModal.TaxExemptions_editRow[indexVal].radioValue == 0) {
                    $scope.ViewVendorRelatedListModal.openTaxExemptionsPopup();
                }
            }*/

            /*$scope.ViewVendorRelatedListModal.openTaxExemptionsPopup = function () {
                loadState($state, 'ViewVendor.TaxExemption', {
                    TaxExemptionParams: {
                        parentObjectId: $scope.ViewVendorRelatedListModal.VendorId
                    }
                });
            }
*/
            $rootScope.$on('TaxExemptionCallback', function (event, args) {
                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalTaxExemptionRecords = args.TotalTaxExemptionRecords;
                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TaxExemptionList = args.TaxExemptionList;
                $scope.ViewVendorRelatedListModal.TaxExemption_initEditRowsModal();
            });

            $scope.ViewVendorRelatedListModal.TaxExemptionCallback = function (args) {
                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TotalTaxExemptionRecords = args.TotalTaxExemptionRecords;
                $scope.ViewVendorRelatedListModal.VendorRelatedInfo.TaxExemptionList = args.TaxExemptionList;
                $scope.ViewVendorRelatedListModal.TaxExemption_initEditRowsModal();

            }

            /**
             * Change Address type on Map
             */
            $scope.ViewVendor.changeActiveAddress = function (address) {
                $scope.ViewVendor.activeAddress = address;
                if (address == "BillingAddress") {
                    $scope.ViewVendor.addressOnMap = $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingStreet2 + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingStreet1 + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingCity + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingState + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingCountry + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingPostalCode
                } else {
                    $scope.ViewVendor.addressOnMap = $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingStreet2 + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingStreet1 + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingCity + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingState + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingCountry + ' ' + $scope.ViewVendor.VendorInfo.VendorDetailRec.ShippingPostalCode
                }
            }

            $scope.ViewVendor.helpText = {
                Info: $translate.instant('General_Help_Text'),
                Statistics: $translate.instant('Tooltip_View_Vendor_Statistics'),
                Vital_Statistics: $translate.instant('Page_Section_VitalStatistics'),
                Telemetry: $translate.instant('Tooltip_View_Vendor_Telemetry'),
                Related: $translate.instant('Helptext_records_related_vendor'),
                COU: $translate.instant('Customer_Owned_Units'),
                Customers: $translate.instant('Helptext_other_customers_related_vendor'),
                Contacts: $translate.instant('Helptext_contacts_related_vendor')
            };

            /**
             * Method to hide the vendor Page sections
             */
            $scope.ViewVendor.hidePanel = function (event, id) {
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

            $scope.ViewVendor.infoLabel = {
                OtherEmail: 'OTHER EMAIL',
                OtherPhone: 'OTHER PHONE',
                MobileNumberSMS: 'OTHER NUMBER SMS',
                HomeEmail: 'HOME EMAIL',
                HomeNumber: 'HOME NUMNER',
                HomeNumberSMS: 'HOME NUMBER SMS',
                WorkEmail: 'WORK EMAIL',
                WorkNumber: 'WORK NUMBER',
                WorkNumberSMS: 'WORK NUMBER SMS'
            };

            $scope.ViewVendor.setPrefferedEmail = function () {
                if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredEmail != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredEmail != "") {
                    return $scope.ViewVendor.VendorInfo.VendorDetailRec[$scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredEmail];
                } else if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredEmail == "" || $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredEmail != null) {
                    return ($scope.ViewVendor.VendorInfo.VendorDetailRec.WorkEmail != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.WorkEmail !== "") ? $scope.ViewVendor.VendorInfo.VendorDetailRec.WorkEmail : ($scope.ViewVendor.VendorInfo.VendorDetailRec.OtherEmail != null) ? $scope.ViewVendor.VendorInfo.VendorDetailRec.OtherEmail : ""
                }
            }

            $scope.ViewVendor.setPrefferedPhone = function () {
                if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhone != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhone != "") {
                    $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhoneLabel = $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhone;
                    return $scope.ViewVendor.VendorInfo.VendorDetailRec[$scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedPreferredPhone];
                } else if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhone == null || $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhone == "") {
                    $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredPhoneLabel = ($scope.ViewVendor.VendorInfo.VendorDetailRec.WorkNumber != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.WorkNumber != "") ? 'WorkNumber' : ($scope.ViewVendor.VendorInfo.VendorDetailRec.OtherPhone != null) ? 'OtherPhone' : "WorkNumber";
                    return ($scope.ViewVendor.VendorInfo.VendorDetailRec.WorkNumber != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedWorkNumber != "") ? $scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedWorkNumber : ($scope.ViewVendor.VendorInfo.VendorDetailRec.OtherPhone != null) ? $scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedOtherPhone : ""
                }
            }

            $scope.ViewVendor.setPrefferedSMS = function () {
                if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMS != null && $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMS != "") {
                    $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMSLabel = $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMS;
                    return $scope.ViewVendor.VendorInfo.VendorDetailRec[$scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedPreferredSMS];
                } else if ($scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMS == null || $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMS == "") {
                    $scope.ViewVendor.VendorInfo.VendorDetailRec.PreferredSMSLabel = ($scope.ViewVendor.VendorInfo.VendorDetailRec.WorkNumberSMS != false) ? 'WorkNumber' : ($scope.ViewVendor.VendorInfo.VendorDetailRec.MobileNumberSMS != false) ? "MobileNumber" : "WorkNumber";
                    return ($scope.ViewVendor.VendorInfo.VendorDetailRec.WorkNumberSMS != false) ? $scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedWorkNumber : ($scope.ViewVendor.VendorInfo.VendorDetailRec.MobileNumberSMS != false) ? $scope.ViewVendor.VendorInfo.VendorDetailRec.FormattedOtherPhone : ""
                }
            }

            $scope.ViewVendor.showInfoOverlay = function (event, vendorId) {
                var targetEle = angular.element(event.target);
                var elementWidth = targetEle.width();
                if (targetEle.width() > targetEle.parent().width()) {
                    elementWidth = targetEle.parent().width() - 15;
                }
                angular.element('.Vendor-info-overlay').css('top', targetEle.offset().top - 45);
                angular.element('.Vendor-info-overlay').css('left', event.clientX);
                angular.element('.Vendor-info-overlay').show();
            }
            $scope.ViewVendor.showVendorInfoOverlay = function (event, vendorId) {
                $scope.$broadcast('VendorInfoPopUpEvent', vendorId);
                $scope.ViewVendor.showInfoOverlay(event, vendorId);
            }
            $scope.ViewVendor.hideVendorInfoOverlay = function () {
                angular.element('.Vendor-info-overlay').hide();
            }

            $scope.ViewVendor.loadVendorInfo = function () {
                var vendorId = $scope.ViewVendor.vendorId;
                VendorInfoService.getVendorInfo(vendorId).then(function (vendorInfo) {
                    $scope.ViewVendor.VendorInfo = vendorInfo;
                    $scope.ViewVendor.ShowContent = true;
                    $scope.ViewVendor.changeActiveAddress('BillingAddress');
                    if ($scope.ViewVendor.VendorInfo.VendorDetailRec.RetailRate <= 0) {
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.RetailRate = $scope.ViewVendor.VendorInfo.VendorDetailRec.RetailRate * -1;
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.Increase_Decrease_Value = 'Less';
                    } else {
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.Increase_Decrease_Value = 'More'
                    }
                    setTimeout(function () {
                        $scope.ViewVendor.calculateSidebarHeight();
                    }, 10);

                    $scope.ViewVendorRelatedListModal.RenderPOTypesSection = ($scope.ViewVendor.VendorInfo.VendorDetailRec.IsPartPurchases ||
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.IsSubletPurchases ||
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.IsUnitPurchases);

                    $scope.ViewVendorRelatedListModal.RenderActiveOrdersSection = ($scope.ViewVendor.VendorInfo.VendorDetailRec.IsPartPurchases ||
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.IsSubletPurchases ||
                        $scope.ViewVendor.VendorInfo.VendorDetailRec.IsUnitPurchases);

                    $scope.ViewVendorRelatedListModal.VendorRelatedInfo = vendorInfo.VendorRelatedInfo;
                    $scope.ViewVendorRelatedListModal.VendorId = $scope.ViewVendor.vendorId;
                    $scope.ViewVendorRelatedListModal.VendorCountry = $scope.ViewVendor.VendorInfo.VendorDetailRec.BillingCountry;
                    $scope.ViewVendor.OriginAddress = vendorInfo.CompanyName.Address;
                    $scope.ViewVendorRelatedListModal.initModals();
                    $scope.ViewVendor.isrefresh = false;
                }, function (errorSearchResult) {
                    $scope.ViewVendor.VendorInfo = errorSearchResult;
                    $scope.ViewVendor.isrefresh = false;
                });
            }

            $scope.ViewVendor.calculateSidebarHeight = function () {
                var leftPanelLinks = angular.element(window).height() - (angular.element(".headerNav").height() + angular.element(".sidepaneluserinfo").height() + angular.element(".statusRow").height() + 52);
                angular.element(".leftPanelLinks").css("height", leftPanelLinks);
            }

            $scope.ViewVendor.refreshViewVendor = function () {
                $scope.ViewVendor.isrefresh = true;
                $scope.ViewVendor.loadVendorInfo();
            }

            /**
             * Related lists save callback action
             */
            $scope.ViewVendor.RelatedLists_recordSaveCallback = function (objType, newRecordsDetails) {
                $scope.ViewVendorRelatedListModal.VendorRelatedLists_recordSaveCallback(objType, newRecordsDetails);
            }

            /**
             * Set focus on search text box. It is used when to add related records via page level search box
             */
            $scope.ViewVendor.setFocusToSearchBox = function (typeToSearch) {
                $scope.typeToSearch = typeToSearch;
                $scope.PreferredObject = typeToSearch;
                angular.element('#SearchToaddCutomer').focus();
            }

            /**
             * Modals for Add/Edit Vendor component
             */
            $scope.ViewVendor.createVendor = function () {
                $rootScope.$broadcast('AddVendorEvent');
            }

            $scope.ViewVendor.editVendor = function () {
                var idParams = {
                    Id: $scope.ViewVendor.vendorId
                };
                loadState($state, 'ViewVendor.EditVendor', {
                    EditVendorParams: idParams
                });
            }

            $scope.vendorRecordSaveCallback = function () {
                $scope.ViewVendor.loadVendorInfo();
            }

            $scope.ViewVendor.showMoreDetails = function (status) {
                $scope.ViewVendor.ShowMore = status;
            }

            $scope.ViewVendor.displaySections = {
                'Info': true,
                'Statistics': true,
                'Related': true
            };

            $scope.ViewVendor.activeSidepanelink = '#InfoSection';
            $scope.ViewVendor.selectedItem = 'Info';

            $scope.ViewVendor.dropDownItem = function (event, selectedSection) {
                var activeSection = $scope.ViewVendor.activeSidepanelink.replace('#', '');
                $scope.ViewVendor.selectedItem = selectedSection;
                if (activeSection != selectedSection) {
                    $scope.ViewVendor.sidepanelLink(event, selectedSection);

                }
            }

            angular.element(document).off("scroll");
            angular.element(document).on("scroll", function () {
                $scope.ViewVendor.onScroll();
            });

            $scope.ViewVendor.sidepanelLink = function (event, relatedContent) {
                event.preventDefault();
                $scope.ViewVendor.displaySections[relatedContent] = true;
                angular.element(document).off("scroll");
                var target = angular.element(event.target.closest('a')).attr("href");
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
                        $scope.ViewVendor.onScroll();
                    });
                    $scope.ViewVendor.onScroll();
                });
            }

            $scope.ViewVendor.onScroll = function () {
                if ($state.current.name === 'ViewVendor') {
                    var activeSidepanelink;
                    var selectedItem;
                    var heading = '';
                    var scrollPos = angular.element(document).scrollTop();
                    var fixedHeight = 10;
                    var navBarHeightDiffrenceFixedHeaderOpen = 0;

                    if ($rootScope.wrapperHeight == 95) {
                        navBarHeightDiffrenceFixedHeaderOpen = -40;
                    } else {
                        navBarHeightDiffrenceFixedHeaderOpen = -40;
                    }
                    if (isElementDefined('#InfoSection') && (scrollPos < angular.element('#InfoSection').position().top + angular.element('#InfoSection').height() + fixedHeight - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#InfoSection';
                        selectedItem = 'Info';
                    } else if (isElementDefined('#RelatedSection') && (scrollPos < angular.element('#RelatedSection').position().top + angular.element('#RelatedSection').height() + fixedHeight - navBarHeightDiffrenceFixedHeaderOpen)) {
                        activeSidepanelink = '#RelatedSection';
                        selectedItem = 'Related';
                    } else {
                        activeSidepanelink = '#RelatedSection';
                        selectedItem = 'Related';
                    }

                    $scope.ViewVendor.activeSidepanelink = activeSidepanelink;
                    $scope.ViewVendor.selectedItem = selectedItem;
                    if (!$scope.$$phase) {
                        $scope.$digest();
                    }
                }
            }

            $scope.ViewVendor.loadVendorInfo();
        }])
    });