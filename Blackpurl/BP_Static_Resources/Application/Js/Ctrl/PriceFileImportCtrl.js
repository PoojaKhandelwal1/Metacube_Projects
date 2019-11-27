define(['Routing_AppJs_PK', 'PriceFileImportServices', 'JqueryUI', 'underscore_min', 'PriceFileImport_Select', 'PriceFileImport_NumberOnlyInputBlur', 'PriceFileImport_CustomFilter', 'dirNumberInput', 'CashSaleSTACtrl', 'CustomToggle'], function(Routing_AppJs_PK, PriceFileImportServices, JqueryUI, underscore_min, PriceFileImport_Select, PriceFileImport_NumberOnlyInputBlur, PriceFileImport_CustomFilter, dirNumberInput, CashSaleSTACtrl, CustomToggle) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('PriceFileImportCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'priceFileImportService','$translate', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, priceFileImportService,$translate) {
        var Notification = injector1.get("Notification");
        if ($scope.PriceFileImportModel == undefined) {
            $scope.PriceFileImportModel = {};
        }
        $scope.PriceFileImportModel.selectedcashSaleChevronIndex = '1';
        $scope.PriceFileImportModel.fieldNumber = 1;
        $scope.PriceFileImportModel.displaySection = 'Import Settings';
        $scope.PriceFileImportModel.priceFileChevronList = [{
            Name: 'Back',
            isActive: true
        }, {
            Name: 'Import Settings',
            isActive: false
        }, {
            Name: 'Field Mapping',
            isActive: false
        }, {
            Name: 'Results',
            isActive: false
        }];
        $scope.PriceFileImportModel.PartPricingFieldsOnVendor = {};
        $scope.maxStringSize = 6000000;
        $scope.maxFileSize = 4350000;
        $scope.chunkSize = 950000;
        $scope.attachment = '';
        $scope.attachmentName = '';
        $scope.fileSize = 0;
        $scope.positionIndex = 0;
        $scope.isBrowseFile = false;
        $scope.FileUpload = {};
        $scope.FileUpload.maxStringSize = 6000000;
        $scope.FileUpload.maxFileSize = 4350000;
        $scope.FileUpload.chunkSize = 950000;
        $scope.FileUpload.attachment = '';
        $scope.FileUpload.attachmentName = '';
        $scope.FileUpload.fileSize = 0;
        $scope.FileUpload.positionIndex = 0;
        $scope.FileUpload.isBrowseFile = false;
        $scope.PriceFileImportModel.isProcessingFile = false;
        $scope.PriceFileImportModel.PriceFileTabledata = [];
        $scope.PriceFileImportModel.delimiter = ',';
        $scope.PriceFileImportModel.IsInstall = false;
        $scope.PriceFileImportModel.ConstantTableHeight = 290;
        $scope.PriceFileImportModel.isScrollInTable = false;
        $scope.PriceFileImportModel.enableSubmitBtn = false;
        $scope.PriceFileImportModel.FieldsMapped = [];
        $scope.PriceFileImportModel.calculatedFieldsMapped = [];
        $scope.PriceFileImportModel.SuccessResultCount = 0;
        $scope.PriceFileImportModel.ErrorResultCount = 0;
        $scope.PriceFileImportModel.InsertedCount = 0;
        $scope.PriceFileImportModel.UpdatedCount = 0;
        $scope.PriceFileImportModel.InvalidRecords = [];
        $scope.PriceFileImportModel.fieldMappingJSON = [];
        $scope.PriceFileImportModel.partRecordFields = [{
            Key: "Part Number",
            isPrimary: true
        }, {
            Key: "Description",
            isPrimary: true
        }, {
            Key: "MSRP",
            isPrimary: true
        }, {
            Key: "Retail",
            isPrimary: true
        }, {
            Key: "Enviro Fee",
            isPrimary: true
        }, {
            Key: "Item Cost",
            isPrimary: true
        }, {
            Key: "MSRP",
            isPrimary: false
        }, {
            Key: "RETAIL",
            isPrimary: false
        }, {
            Key: "Mfg Part #",
            isPrimary: true
        }, {
            Key: "SKU #",
            isPrimary: true
        }, {
            Key: "PACKAGE QTY",
            isPrimary: true
        }, {
            Key: "ALL PRICES ARE PER ITEM",
            isPrimary: true
        }, {
            Key: "ALL COSTS ARE PER ITEM",
            isPrimary: true
        }, {
            Key: "REPLACED BY PART#",
            isPrimary: true
        }, {
            Key: "REPLACES PART#",
            isPrimary: true
        }];
        $scope.PriceFileImportModel.FieldsMapped[11] = true;
        $scope.PriceFileImportModel.FieldsMapped[12] = true;
        $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
        $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
        $scope.PriceFileImportModel.partRecordCalculatedFields = [{
            key: "MSRP",
            isIncreased: false,
            value: 0.00,
            MappedIndex: -1
        }, {
            key: "RETAIL",
            isIncreased: false,
            value: 0.00,
            MappedIndex: -1
        }];
        $scope.PriceFileImportModel.PartRecordResultJson = [];
        for (var i = 0; i < $scope.PriceFileImportModel.partRecordFields.length; i++) {
            if ($scope.PriceFileImportModel.partRecordFields[i].isPrimary == true) {
                $scope.PriceFileImportModel.PartRecordResultJson.push({
                    Key: $scope.PriceFileImportModel.partRecordFields[i].Key,
                    Value: '',
                    MappedField: '',
                    ActualValue: '',
                    isNumericValue: false
                });
            }
        }
        var vendor = {
            Key: 'Vendor',
            Value: '',
            MappedField: ''
        }
        var category = {
            Key: 'Category',
            Value: '',
            MappedField: ''
        }
        $scope.PriceFileImportModel.PartRecordResultJson.splice(2, 0, vendor);
        $scope.PriceFileImportModel.PartRecordResultJson.splice(3, 0, category);
        $scope.PriceFileImportModel.PriceFileImportValidationModal = {
            MSRP: {
                isError: false,
                ErrorMessage: '',
                Type: ''
            },
            RETAIL: {
                isError: false,
                ErrorMessage: '',
                Type: ''
            }
        };
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
        $scope.$on('$dropletReady', function whenDropletReady() {
            try {
                $scope.FileUpload.interface.allowedExtensions(['csv']);
                $scope.FileUpload.interface.defineHTTPSuccess([/2.{2}/]);
                $scope.FileUpload.interface.useArray(false);
                $scope.FileUpload.interface.setMaximumValidFiles(1);
            } catch (ex) {}
        });
        $scope.$on('$dropletSuccess', function onDropletSuccess(event, response, files) {
            $scope.FileUpload.uploadCount = files.length;
            $scope.FileUpload.success = true;
            $timeout(function timeout() {
                $scope.FileUpload.success = false;
            }, 100);
        });
        $scope.$on('$dropletError', function onDropletError(event, response) {
            $scope.FileUpload.error = true;
            $timeout(function timeout() {
                $scope.FileUpload.error = false;
            }, 100);
        });
        $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
            $scope.FileUpload.fileToBeUploaded = singlefile.file;
            $scope.PriceFileImportModel.hideGrid();
            $scope.PriceFileImportModel.validateCSV(singlefile.file);
        });
        $scope.FileUpload.uploadFile = function(file) {
            $scope.FileUpload.isloading = true;
            if (file != undefined) {
                if (file.size <= $scope.FileUpload.maxFileSize) {
                    $scope.FileUpload.attachmentName = file.name;
                    var fileReader = new FileReader();
                    fileReader.onloadend = function(e) {
                        $scope.FileUpload.attachment = window.btoa(this.result);
                        $scope.FileUpload.positionIndex = 0;
                        $scope.FileUpload.fileSize = $scope.FileUpload.attachment.length;
                        $scope.FileUpload.doneUploading = false;
                        if ($scope.FileUpload.fileSize < $scope.FileUpload.maxStringSize) {
                            $scope.FileUpload.isloading = false;
                            $scope.FileUpload.tempattachmentbody = $scope.FileUpload.attachment;
                            $scope.FileUpload.uploadAttachment();
                        } else {
                            $scope.FileUpload.isloading = false;
                        }
                    }
                    fileReader.onerror = function(e) {}
                    fileReader.onabort = function(e) {
                        $scope.FileUpload.isloading = false
                        $scope.FileUpload.uploadAttachment();
                    }
                    fileReader.readAsBinaryString(file);
                } else {
                    $scope.FileUpload.isloading = false;
                }
            } else {
                $scope.FileUpload.isloading = false;
                $scope.FileUpload.uploadAttachment();
            }
        }
        $scope.PriceFileImportModel.calculateJsonForFields = function() {
            $scope.PriceFileImportModel.enableSubmitBtn = false;
            $scope.PriceFileImportModel.fieldMappingJSON = [];
            $scope.PriceFileImportModel.PriceFieldMappingStatusJSON = [];
            $scope.PriceFileImportModel.FieldsMapped = [];
            $scope.PriceFileImportModel.calculatedFieldsMapped = [];
            $scope.PriceFileImportModel.fieldMappingJSON = [];
            $scope.PriceFileImportModel.partRecordFields = [{
                Key: "Part Number",
                isPrimary: true
            }, {
                Key: "Description",
                isPrimary: true
            }, {
                Key: "MSRP",
                isPrimary: true
            }, {
                Key: "RETAIL",
                isPrimary: true
            }, {
                Key: "Enviro Fee",
                isPrimary: true
            }, {
                Key: "Item Cost",
                isPrimary: true
            }, {
                Key: "MSRP",
                isPrimary: false
            }, {
                Key: "RETAIL",
                isPrimary: false
            }, {
                Key: "Mfg Part #",
                isPrimary: true
            }, {
                Key: "SKU #",
                isPrimary: true
            }, {
                Key: "PACKAGE QTY",
                isPrimary: true
            }, {
                Key: "ALL PRICES ARE PER ITEM",
                isPrimary: true
            }, {
                Key: "ALL COSTS ARE PER ITEM",
                isPrimary: true
            }, {
                Key: "REPLACED BY PART#",
                isPrimary: true
            }, {
                Key: "REPLACES PART#",
                isPrimary: true
            }];
            $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
            $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
            $scope.PriceFileImportModel.partRecordCalculatedFields = [{
                key: "MSRP",
                isIncreased: false,
                value: 0.00,
                MappedIndex: -1
            }, {
                key: "RETAIL",
                isIncreased: false,
                value: 0.00,
                MappedIndex: -1
            }];
            $scope.PriceFileImportModel.PartRecordResultJson = [];
            for (var i = 0; i < $scope.PriceFileImportModel.partRecordFields.length; i++) {
                if ($scope.PriceFileImportModel.partRecordFields[i].isPrimary == true) {
                    $scope.PriceFileImportModel.PartRecordResultJson.push({
                        Key: $scope.PriceFileImportModel.partRecordFields[i].Key,
                        Value: '',
                        MappedField: '',
                        ActualValue: '',
                        isCalculated: false
                    });
                }
            }
            var vendor = {
                Key: 'Vendor',
                Value: '',
                MappedField: '',
                isCalculated: false
            }
            var category = {
                Key: 'Category',
                Value: '',
                MappedField: '',
                isCalculated: false
            }
            $scope.PriceFileImportModel.PartRecordResultJson.splice(2, 0, vendor);
            $scope.PriceFileImportModel.PartRecordResultJson.splice(3, 0, category);
            for (var i = 0; i < $scope.PriceFileImportModel.PartRecordResultJson.length; i++) {
                if ($scope.PriceFileImportModel.PartRecordResultJson[i].Key == 'Vendor') {
                    $scope.PriceFileImportModel.PartRecordResultJson[i].Value = $scope.PriceFileImportModel.recentlyAddedVendor.Title;
                } else if ($scope.PriceFileImportModel.PartRecordResultJson[i].Key == 'Category') {
                    $scope.PriceFileImportModel.PartRecordResultJson[i].Value = $scope.PriceFileImportModel.recentlyAddedVendor.CategoryName;
                }
            }
            var fieldLabel = '';
            if (!$scope.PriceFileImportModel.IsInstall) {
                var setRecord = $scope.PriceFileImportModel.fieldNumber - 1;
                var arr = $scope.PriceFileImportModel.rows[setRecord].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                for (i = 0; i < arr.length; i++) {
                    if (arr[i].toUpperCase() == 'MSRP') {
                        fieldLabel = 'MSRP(FROM FILE)'
                    } else if (arr[i].toUpperCase() == 'RETAIL') {
                        fieldLabel = 'RETAIL(FROM FILE)'
                    } else {
                        fieldLabel = arr[i].toUpperCase()
                    }
                    $scope.PriceFileImportModel.fieldMappingJSON.push({
                        id: i,
                        label: fieldLabel
                    });
                }
                if ($scope.PriceFileImportModel.fieldNumber != $scope.PriceFileImportModel.FileLength) {
                    var arrNext = $scope.PriceFileImportModel.rows[setRecord + 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                    for (i = 0; i < arr.length; i++) {
                        if (arr[i].toUpperCase() == 'MSRP') {
                            fieldLabel = 'MSRP(FROM FILE)'
                        } else if (arr[i].toUpperCase() == 'RETAIL') {
                            fieldLabel = 'RETAIL(FROM FILE)'
                        } else {
                            fieldLabel = arr[i].toUpperCase()
                        }
                        $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: fieldLabel,
                            value: arrNext[i],
                            status: ''
                        });
                    }
                } else {
                    var arrPrev = $scope.PriceFileImportModel.rows[setRecord - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                    for (i = 0; i < arr.length; i++) {
                        if (arr[i].toUpperCase() == 'MSRP') {
                            fieldLabel = 'MSRP(FROM FILE)'
                        } else if (arr[i].toUpperCase() == 'RETAIL') {
                            fieldLabel = 'RETAIL(FROM FILE)'
                        } else {
                            fieldLabel = arr[i].toUpperCase()
                        }
                        $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: fieldLabel,
                            value: arrPrev[i],
                            status: ''
                        });
                    }
                }
                if ($scope.PriceFileImportModel.fieldMappingJSON != undefined) {
                    $scope.PriceFileImportModel.fieldMappingJSON.unshift({
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length,
                        label: 'Calculated value'
                    });
                    $scope.PriceFileImportModel.fieldMappingJSON.unshift({
                        id: -10,
                        label: 'None'
                    });
                    $scope.PriceFileImportModel.fieldMappingJSON.push({
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length,
                        label: 'MSRP'
                    }, {
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length + 1,
                        label: 'RETAIL'
                    });
                }
                return;
            } else {
                var rows = $scope.PriceFileImportModel.rows;
                var tableRecord = 0;
                var cells = rows[0].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                for (var i = 0; i < $scope.PriceFileImportModel.PriceFileTabledata.length; i++) {
                    $scope.PriceFileImportModel.fieldMappingJSON.push({
                        id: i,
                        label: 'COLUMN ' + String.fromCharCode(65 + i)
                    });
                    if ($scope.PriceFileImportModel.fieldNumber != $scope.PriceFileImportModel.FileLength) {
                        var arrNext = cells
                        $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: 'COLUMN ' + String.fromCharCode(65 + i),
                            value: arrNext[i],
                            status: ''
                        });
                    } else {
                        var arrPrev = cells
                        $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: 'COLUMN ' + String.fromCharCode(65 + i),
                            value: arrPrev[i],
                            status: ''
                        });
                    }
                }
                if ($scope.PriceFileImportModel.fieldMappingJSON != undefined) {
                    $scope.PriceFileImportModel.fieldMappingJSON.unshift({
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length,
                        label: 'Calculated value'
                    });
                    $scope.PriceFileImportModel.fieldMappingJSON.unshift({
                        id: -10,
                        label: 'None'
                    });
                    $scope.PriceFileImportModel.fieldMappingJSON.push({
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length,
                        label: 'MSRP'
                    }, {
                        id: $scope.PriceFileImportModel.fieldMappingJSON.length + 1,
                        label: 'RETAIL'
                    });
                }
            }
        }
        $scope.PriceFileImportModel.calculateMsrpValue = function() {
            $scope.PriceFileImportModel.calculateMappedFieldValues(0);
        }
        $scope.PriceFileImportModel.calculateRetailValue = function() {
            $scope.PriceFileImportModel.calculateMappedFieldValues(1);
        }
        $scope.PriceFileImportModel.closeComfirmationPopup = function(cancel) {
            if (cancel == true) {
                angular.element('#ProcessFileConfirmationPopup').modal('hide');
                return;
            }
            $scope.PriceFileImportModel.mergeMappedFields();
        }
        $scope.PriceFileImportModel.openComfirmationPopup = function() {
            angular.element('#ProcessFileConfirmationPopup').modal('show');
        }
        $scope.PriceFileImportModel.showToolTip = function(value) {
            angular.element("#" + value).show();
        }
        $scope.PriceFileImportModel.hideToolTip = function(value) {
            angular.element("#" + value).hide();
        }
        var ImportedPartIdList = [];
        $scope.PriceFileImportModel.mergeMappedFields = function() {
            $scope.PriceFileImportModel.SuccessResultCount = 0;
            $scope.PriceFileImportModel.ErrorResultCount = 0;
            $scope.PriceFileImportModel.InsertedCount = 0;
            $scope.PriceFileImportModel.UpdatedCount = 0;
            angular.element('#ProcessFileConfirmationPopup').modal('hide');
            $scope.PriceFileImportModel.isProcessingFile = true;
            var ImportJsonMap = {
                'PART NUMBER': {
                    key: 'PartNumber',
                    valueIndex: '',
                    formula: []
                },
                'DESCRIPTION': {
                    key: 'Description',
                    valueIndex: '',
                    formula: []
                },
                'MSRP': {
                    key: 'MSRP',
                    valueIndex: '',
                    formula: []
                },
                'RETAIL': {
                    key: 'Retail',
                    valueIndex: '',
                    formula: []
                },
                'ENVIRO FEE': {
                    key: 'EnviroFee',
                    valueIndex: '',
                    formula: []
                },
                'ITEM COST': {
                    key: 'ItemCost',
                    valueIndex: '',
                    formula: []
                },
                'MFG PART #': {
                    key: 'MfgPart',
                    valueIndex: '',
                    formula: []
                },
                'SKU #': {
                    key: 'SKU',
                    valueIndex: '',
                    formula: []
                },
                'PACKAGE QTY': {
                    key: 'PackageQty',
                    valueIndex: '',
                    formula: []
                },
                'ALL PRICES ARE PER ITEM': {
                    key: 'AllPricesArePerItem',
                    valueIndex: '',
                    formula: []
                },
                'ALL COSTS ARE PER ITEM': {
                    key: 'AllCostsArePerItem',
                    valueIndex: '',
                    formula: []
                },
                'REPLACED BY PART#': {
                    key: 'ReplacedByPart',
                    valueIndex: '',
                    formula: []
                },
                'REPLACES PART#': {
                    key: 'ReplacesPart',
                    valueIndex: '',
                    formula: []
                }
            }
            var resultIndex = 0;
            for (resultIndex = 0; resultIndex < $scope.PriceFileImportModel.PartRecordResultJson.length; resultIndex++) {
                if ($scope.PriceFileImportModel.PartRecordResultJson[resultIndex].Key == 'MSRP' && $scope.PriceFileImportModel.partRecordCalculatedFields[0].MappedIndex != -1) {
                    if ($scope.PriceFileImportModel.PartRecordResultJson[resultIndex].MappedField.toLowerCase() == 'retail') {
                        for (i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                            if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.PriceFileImportModel.PartRecordResultJson[5].MappedField.toLowerCase()) {
                                ImportJsonMap['MSRP'].valueIndex = i;
                            }
                        }
                        ImportJsonMap['MSRP'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[1].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[1].value);
                        ImportJsonMap['MSRP'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[0].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[0].value);
                    } else {
                        for (i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                            if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.PriceFileImportModel.PartRecordResultJson[4].MappedField.toLowerCase()) {
                                ImportJsonMap['MSRP'].valueIndex = i;
                            }
                        }
                        ImportJsonMap['MSRP'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[0].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[0].value);
                    }
                } else if ($scope.PriceFileImportModel.PartRecordResultJson[resultIndex].Key == 'RETAIL' && $scope.PriceFileImportModel.partRecordCalculatedFields[1].MappedIndex != -1) {
                    if ($scope.PriceFileImportModel.PartRecordResultJson[resultIndex].MappedField.toLowerCase() == 'msrp') {
                        for (i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                            if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.PriceFileImportModel.PartRecordResultJson[4].MappedField.toLowerCase()) {
                                ImportJsonMap['RETAIL'].valueIndex = i;
                            }
                        }
                        if (!$scope.PriceFileImportModel.PartPricingFieldsOnVendor.IsCalculatePartRetailPrice) {
                            ImportJsonMap['RETAIL'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[0].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[0].value);
                            ImportJsonMap['RETAIL'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[1].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[1].value);
                        }
                    } else {
                        for (i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                            if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.PriceFileImportModel.PartRecordResultJson[5].MappedField.toLowerCase()) {
                                ImportJsonMap['RETAIL'].valueIndex = i;
                            }
                        }
                        ImportJsonMap['RETAIL'].formula.push(($scope.PriceFileImportModel.partRecordCalculatedFields[1].isIncreased == 'false' ? -1 : 1) * $scope.PriceFileImportModel.partRecordCalculatedFields[1].value);
                    }
                } else {
                    for (i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                        if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.PriceFileImportModel.PartRecordResultJson[resultIndex].MappedField.toLowerCase() && ImportJsonMap[$scope.PriceFileImportModel.PartRecordResultJson[resultIndex].Key.toUpperCase()] != undefined) {
                            ImportJsonMap[$scope.PriceFileImportModel.PartRecordResultJson[resultIndex].Key.toUpperCase()].valueIndex = i;
                        }
                    }
                }
            };
            $scope.PriceFileImportModel.importstart($scope.PriceFileImportModel.fieldNumber, ImportJsonMap, false);
        }
        $scope.PriceFileImportModel.importstart = function(fileIndexstart, ImportJsonMap, isRepeat) {
            fileIndexstart = ($scope.PriceFileImportModel.IsInstall == true && isRepeat == false) ? 0 : fileIndexstart;
            var ImportJsonMap = ImportJsonMap;
            var importPriceFileJson = [];
            var counter = 0;
            var mappedvalue = 0;
            var mappedkey = '';
            var vendorId = $scope.PriceFileImportModel.recentlyAddedVendor.Id;
            for (fileIndex = fileIndexstart; fileIndex < $scope.PriceFileImportModel.rows.length; fileIndex++) {
                try {
                    var cells = $scope.PriceFileImportModel.rows[fileIndex].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                    for (var i = 0; i < cells.length; i++) {
                        cells[i] = cells[i].replace(/[^\x20-\x7E]+/g, '');
                        if (cells[i] != undefined && cells[i] != null && cells[i] != '') {
                            cells[i] = cells[i].trim();
                        }
                        window.btoa(cells[i]);
                    }
                    var element = {}
                    for (var key in ImportJsonMap) {
                        mappedvalue = cells[ImportJsonMap[key].valueIndex];
                        mappedkey = ImportJsonMap[key].key;
                        if (ImportJsonMap[key].formula.length != 0) {
                            for (var formulaIndex = 0; formulaIndex < ImportJsonMap[key].formula.length; formulaIndex++) {
                                if (!isNaN(parseFloat(mappedvalue)) || !isNaN(parseFloat(ImportJsonMap[key].formula[formulaIndex]))) {
                                    mappedvalue = parseFloat(mappedvalue) + (parseFloat(mappedvalue) * parseFloat(ImportJsonMap[key].formula[formulaIndex]) / 100);
                                }
                            }
                        }
                        element[mappedkey] = mappedvalue;
                    }
                    element['AllPricesArePerItem'] = $scope.PriceFileImportModel.FieldsMapped[11];
                    element['AllCostsArePerItem'] = $scope.PriceFileImportModel.FieldsMapped[12];
                    if ((cells[ImportJsonMap['PART NUMBER'].valueIndex])) {
                        importPriceFileJson.push(element);
                    }
                } catch (ex) {
                    $scope.PriceFileImportModel.InvalidRecords.push('unable to process line no ' + fileIndex + ' Error ' + ex.message);
                }
                if (fileIndex == ($scope.PriceFileImportModel.rows.length - 1) || counter == 600) {
                    priceFileImportService.InserPriceFileRecords(vendorId, angular.toJson(importPriceFileJson)).then(function(successfulSearchResult) {
                        if (parseFloat(successfulSearchResult.SucessCount) != 'NAN') {
                            $scope.PriceFileImportModel.SuccessResultCount += parseFloat(successfulSearchResult.SucessCount);
                            $scope.PriceFileImportModel.InsertedCount += parseFloat(successfulSearchResult.NewRecords);
                            $scope.PriceFileImportModel.UpdatedCount += parseFloat(successfulSearchResult.SucessCount) - parseFloat(successfulSearchResult.NewRecords);
                            $scope.PriceFileImportModel.SuccessResultCount += parseFloat(successfulSearchResult.ErrorCount);
                            $scope.PriceFileImportModel.ErrorResultCount += parseFloat(successfulSearchResult.ErrorCount);
                            ImportedPartIdList = ImportedPartIdList.concat(Array.from(successfulSearchResult.ImportedPartIdSet));
                        }
                        if (fileIndex == ($scope.PriceFileImportModel.rows.length - 1)) {
                            $scope.PriceFileImportModel.isProcessingFile = false;
                            if ($scope.PriceFileImportModel.SuccessResultCount > 0) {
                                priceFileImportService.createActivityHistory(vendorId).then(function(successfulSearchResult) {
                                });
                                priceFileImportService.importSupersessionPartNumbeInformation(angular.toJson(ImportedPartIdList)).then(function() {
                                }, function(error) {
                                    console.error("importSupersessionPartNumbeInformation error" + error);
                                });
                            }
                        } else {
                            $scope.PriceFileImportModel.importstart((fileIndex + 1), ImportJsonMap, true);
                        }
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        angular.element('#ProcessFileConfirmationPopup').modal('hide');
                    });
                    break;
                }
                counter++;
            }
        }
        $scope.PriceFileImportModel.calculateMappedFieldValues = function(index) {
            var i = index
            for (k = 0; k < $scope.PriceFileImportModel.partRecordCalculatedFields.length; k++) {
                var total = '';
                var indexToMap = $scope.PriceFileImportModel.partRecordCalculatedFields[i].MappedIndex;
                var percent = 0.00;
                if ($scope.PriceFileImportModel.partRecordCalculatedFields[i].value == '' || $scope.PriceFileImportModel.partRecordCalculatedFields[i].value == '-') {
                    continue;
                }
                if ($scope.PriceFileImportModel.partRecordCalculatedFields[i].value == 'NaN') {
                    $scope.PriceFileImportModel.partRecordCalculatedFields[i].value = 0.00;
                }
                if ($scope.PriceFileImportModel.partRecordCalculatedFields[i].isIncreased == 'true') {
                    percent = parseFloat($scope.PriceFileImportModel.partRecordCalculatedFields[i].value);
                } else {
                    percent = parseFloat($scope.PriceFileImportModel.partRecordCalculatedFields[i].value) * -1;
                }
                if ($scope.PriceFileImportModel.PartRecordResultJson[indexToMap] == undefined) {
                    continue;
                }
                if (percent != null) {
                    var calculatevalueRec = 0;
                    var Keytomap = ''
                    if ($scope.PriceFileImportModel.PartRecordResultJson[indexToMap].ActualValue == 'MSRP') {
                        calculatevalueRec = $scope.PriceFileImportModel.PartRecordResultJson[4].Value;
                    } else if ($scope.PriceFileImportModel.PartRecordResultJson[indexToMap].ActualValue == 'RETAIL') {
                        calculatevalueRec = $scope.PriceFileImportModel.PartRecordResultJson[5].Value;
                    } else {
                        Keytomap = $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].ActualValue
                    }
                    for (var j = 0; j < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; j++) {
                        if (Keytomap == $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[j].fieldLabel) {
                            calculatevalueRec = $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[j].value;
                            break;
                        }
                    }
                    total = parseFloat(calculatevalueRec) + (parseFloat(calculatevalueRec) * (percent / 100));
                }
                if (total == 'NaN') {
                    total = 0.00;
                }
                $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].Value = total.toFixed(2);
                var fieldName = $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].Key;
                if ((fieldName == 'RETAIL') || (fieldName == 'MSRP')) {
                    if (!isNaN(parseFloat($scope.PriceFileImportModel.PartRecordResultJson[indexToMap].Value)) && isFinite($scope.PriceFileImportModel.PartRecordResultJson[indexToMap].Value)) {
                        $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].isNumericValue = true;
                    } else {
                        $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].isNumericValue = false;
                    }
                }
                if (index == 0) {
                    i = i + 1;
                } else {
                    i = i - 1;
                }
                if ($scope.PriceFileImportModel.PartPricingFieldsOnVendor.IsCalculatePartRetailPrice && (fieldName == $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailBaseValue)) {
                    $scope.PriceFileImportModel.PartRecordResultJson[5].Value = caculatePartRetailPrice($scope.PriceFileImportModel.PartRecordResultJson[indexToMap].Value);
                    $scope.PriceFileImportModel.PartRecordResultJson[5].isNumericValue = true;
                    $scope.PriceFileImportModel.partRecordCalculatedFields[1].MappedIndex = 5;
                    $scope.PriceFileImportModel.PartRecordResultJson[5].ActualValue = $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].ActualValue
                    $scope.PriceFileImportModel.PartRecordResultJson[5].MappedField = $scope.PriceFileImportModel.PartRecordResultJson[indexToMap].MappedField
                }
            }
        }
        $scope.PriceFileImportModel.updateStatusOfMappedFields = function(index) {
            var PriceFieldMappingStatusJSON;
            if ($scope.PriceFileImportModel.FieldsMapped[index] == undefined) {
                return;
            }
            if ($scope.PriceFileImportModel.FieldsMapped[index] == 'Calculated value') {
                PriceFieldMappingStatusJSON = {
                    value: 'Calculation not defined',
                    fieldLabel: ''
                };
            }
            if (index == 2 || index == 3) {
                if ($scope.PriceFileImportModel.FieldsMapped[2] == 'Calculated value' && $scope.PriceFileImportModel.FieldsMapped[3] == 'Calculated value') {
                    $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'MSRP'];
                    $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL'];
                } else {
                    if (index == 2) {
                        $scope.PriceFileImportModel.FieldsMapped[6] = '';
                        $scope.PriceFileImportModel.partRecordCalculatedFields[0].MappedIndex = -1;
                        $scope.PriceFileImportModel.partRecordCalculatedFields[0].value = 0;
                        $scope.PriceFileImportModel.partRecordCalculatedFields[0].isIncreased = ''
                    } else if (index == 3) {
                        $scope.PriceFileImportModel.FieldsMapped[7] = '';
                        $scope.PriceFileImportModel.partRecordCalculatedFields[1].isIncreased = '';
                        $scope.PriceFileImportModel.partRecordCalculatedFields[1].value = 0;
                        $scope.PriceFileImportModel.partRecordCalculatedFields[1].MappedIndex = -1;
                    }
                    $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
                    $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
                }
            } else if (index == 7) {
                if ($scope.PriceFileImportModel.FieldsMapped != undefined && $scope.PriceFileImportModel.FieldsMapped[index] == 'MSRP') {
                    PriceFieldMappingStatusJSON = {
                        value: $scope.PriceFileImportModel.PartRecordResultJson[4].Value,
                        fieldLabel: 'MSRP'
                    };
                    $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
                } else {
                    $scope.PriceFileImportModel.ExcludeMsrpFieldList = ['Calculated value', 'MSRP'];
                }
            } else if (index == 6) {
                if ($scope.PriceFileImportModel.FieldsMapped != undefined && $scope.PriceFileImportModel.FieldsMapped[index] == 'RETAIL') {
                    PriceFieldMappingStatusJSON = {
                        value: $scope.PriceFileImportModel.PartRecordResultJson[5].Value,
                        fieldLabel: 'RETAIL'
                    };
                    $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL', 'MSRP'];
                } else {
                    $scope.PriceFileImportModel.ExcludeRetailFieldList = ['Calculated value', 'RETAIL'];
                }
            } else if (index == 10) {
                if ($scope.PriceFileImportModel.FieldsMapped[index] == 'None' || $scope.PriceFileImportModel.FieldsMapped[index] == '' || $scope.PriceFileImportModel.FieldsMapped[index] == null || $scope.PriceFileImportModel.FieldsMapped[index] == undefined) {
                    $scope.PriceFileImportModel.FieldsMapped[11] = true;
                    $scope.PriceFileImportModel.FieldsMapped[12] = true;
                }
                if ($scope.PriceFileImportModel.FieldsMapped[11] == undefined) {
                    $scope.PriceFileImportModel.FieldsMapped[11] = true;
                }
                if ($scope.PriceFileImportModel.FieldsMapped[12] == undefined) {
                    $scope.PriceFileImportModel.FieldsMapped[12] = true;
                }
                $scope.PriceFileImportModel.PartRecordResultJson[11].Value = $scope.PriceFileImportModel.FieldsMapped[11];
                $scope.PriceFileImportModel.PartRecordResultJson[11].ActualValue = '';
                $scope.PriceFileImportModel.PartRecordResultJson[11].MappedField = '';
                $scope.PriceFileImportModel.PartRecordResultJson[12].Value = $scope.PriceFileImportModel.FieldsMapped[11];
                $scope.PriceFileImportModel.PartRecordResultJson[12].ActualValue = '';
                $scope.PriceFileImportModel.PartRecordResultJson[12].MappedField = '';
            }
            for (var i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                if (index != 11 && index != 12) {
                    if (($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel).toUpperCase() == ($scope.PriceFileImportModel.FieldsMapped[index]).toUpperCase()) {
                        PriceFieldMappingStatusJSON = $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i];
                        break;
                    }
                }
            }
            for (var j = 0; j < $scope.PriceFileImportModel.PartRecordResultJson.length; j++) {
                if ($scope.PriceFileImportModel.partRecordFields[index].Key == $scope.PriceFileImportModel.PartRecordResultJson[j].Key) {
                    if (!$scope.PriceFileImportModel.partRecordFields[index].isPrimary) {
                        for (var calculatedIndex = 0; calculatedIndex < $scope.PriceFileImportModel.partRecordCalculatedFields.length; calculatedIndex++) {
                            if ($scope.PriceFileImportModel.partRecordCalculatedFields[calculatedIndex].key == $scope.PriceFileImportModel.PartRecordResultJson[j].Key) {
                                $scope.PriceFileImportModel.partRecordCalculatedFields[calculatedIndex].MappedIndex = j;
                            }
                        }
                        $scope.PriceFileImportModel.PartRecordResultJson[j].Value = PriceFieldMappingStatusJSON.value;
                        $scope.PriceFileImportModel.PartRecordResultJson[j].MappedField = PriceFieldMappingStatusJSON.fieldLabel;
                        $scope.PriceFileImportModel.PartRecordResultJson[j].ActualValue = PriceFieldMappingStatusJSON.fieldLabel;
                    } else {
                        if (PriceFieldMappingStatusJSON != undefined) {
                            $scope.PriceFileImportModel.PartRecordResultJson[j].Value = PriceFieldMappingStatusJSON.value;
                            $scope.PriceFileImportModel.PartRecordResultJson[j].ActualValue = PriceFieldMappingStatusJSON.fieldLabel;
                            $scope.PriceFileImportModel.PartRecordResultJson[j].MappedField = PriceFieldMappingStatusJSON.fieldLabel;
                        } else if (index == 11 || index == 12) {
                            $scope.PriceFileImportModel.PartRecordResultJson[j].Value = $scope.PriceFileImportModel.FieldsMapped[index];
                            $scope.PriceFileImportModel.PartRecordResultJson[j].ActualValue = '';
                            $scope.PriceFileImportModel.PartRecordResultJson[j].MappedField = '';
                        } else {
                            $scope.PriceFileImportModel.PartRecordResultJson[j].Value = '';
                            $scope.PriceFileImportModel.PartRecordResultJson[j].ActualValue = '';
                            $scope.PriceFileImportModel.PartRecordResultJson[j].MappedField = '';
                        }
                    }
                    var fieldName = $scope.PriceFileImportModel.PartRecordResultJson[j].Key;
                    if ((fieldName == 'RETAIL') || (fieldName == 'MSRP') || (fieldName == 'Enviro Fee') || (fieldName == 'Item Cost')) {
                        if (!isNaN(parseFloat($scope.PriceFileImportModel.PartRecordResultJson[j].Value)) && isFinite($scope.PriceFileImportModel.PartRecordResultJson[j].Value)) {
                            $scope.PriceFileImportModel.PartRecordResultJson[j].isNumericValue = true;
                        } else {
                            $scope.PriceFileImportModel.PartRecordResultJson[j].isNumericValue = false;
                        }
                    }
                    if ($scope.PriceFileImportModel.PartPricingFieldsOnVendor.IsCalculatePartRetailPrice && (fieldName == $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailBaseValue)) {
                        $scope.PriceFileImportModel.PartRecordResultJson[5].Value = caculatePartRetailPrice($scope.PriceFileImportModel.PartRecordResultJson[j].Value);
                        $scope.PriceFileImportModel.PartRecordResultJson[5].isNumericValue = true;
                        $scope.PriceFileImportModel.partRecordCalculatedFields[1].MappedIndex = 5;
                        $scope.PriceFileImportModel.PartRecordResultJson[5].ActualValue = $scope.PriceFileImportModel.PartRecordResultJson[j].ActualValue
                        $scope.PriceFileImportModel.PartRecordResultJson[5].MappedField = $scope.PriceFileImportModel.PartRecordResultJson[j].MappedField
                    }
                    break;
                }
            }
            for (var i = 0; i < $scope.PriceFileImportModel.PriceFieldMappingStatusJSON.length; i++) {
                if ($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != '' && $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != null && $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != undefined) {
                    for (var j = 0; j < $scope.PriceFileImportModel.PartRecordResultJson.length; j++) {
                        if (($scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].fieldLabel).toUpperCase() == ($scope.PriceFileImportModel.PartRecordResultJson[j].MappedField).toUpperCase()) {
                            $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].status = 'Mapped';
                            break;
                        } else {
                            $scope.PriceFileImportModel.PriceFieldMappingStatusJSON[i].status = '';
                        }
                    }
                }
            }
            if (index == 6 || index == 7) {
                var indexvalue = (index == 6 ? 0 : 1)
                $scope.PriceFileImportModel.calculateMappedFieldValues(indexvalue);
            }
            $scope.PriceFileImportModel.validateFieldsMappedOnSubmit();
        }

        function caculatePartRetailPrice(MSRP_Or_ItemCost) {
            var BaseValue = (!MSRP_Or_ItemCost ? 0 : MSRP_Or_ItemCost);
            var RetailRate = parseFloat($scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRate);
            var calculatedRetailPrice = parseFloat(BaseValue) + (parseFloat(BaseValue) * parseFloat(RetailRate / 100));
            calculatedRetailPrice = calculatedRetailPrice.toFixed(2);
            if ($scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRounding) {
                var RetailRoundingCentValueOnVendor = parseFloat($scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRoundTo);
                calculatedRetailPrice = applyRoundingToCalculatedRetailPrice(RetailRoundingCentValueOnVendor, calculatedRetailPrice);
            }
            return calculatedRetailPrice;
        }

        function applyRoundingToCalculatedRetailPrice(RetailRoundingCentValue, RetailPriceValue) {
            var RoundingValue = parseFloat(RetailRoundingCentValue / 100);
            var RetailPriceIntegerValue = Math.floor(RetailPriceValue);
            if ((RetailPriceValue - parseFloat(RetailPriceIntegerValue)) > RoundingValue) {
                RetailPriceIntegerValue = parseInt(RetailPriceIntegerValue) + 1;
            }
            var roundedRetailPriceValue = parseFloat(RetailPriceIntegerValue) + RoundingValue;
            return roundedRetailPriceValue;
        }
        $scope.FileUpload.uploadAttachment = function() {
            $scope.FileUpload.isloading = true;
        }
        $scope.PriceFileImportModel.loadPriceFileImport = function() {
            setTimeout(function() {
                $scope.PriceFileImportModel.calculateGridContainerHeight();
            }, 10);
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'bottom'
                });
            }, 1000);
        }
        $scope.PriceFileImportModel.calculateTbodyWidth = function() {
            if (angular.element(".grid_priceFileData tbody").height() < $scope.PriceFileImportModel.ConstantTableHeight) {
                $scope.PriceFileImportModel.isScrollInTable = true;
            } else {
                $scope.PriceFileImportModel.isScrollInTable = false;
            }
        }
        $scope.$on('priceFileImportSTACallback', function(name, args) {
            $scope.PriceFileImportModel.recentlyAddedVendor = args;
            setVendorPartPricingFieldsOnPFI(args.AdditionalInfoWithVendorPricingFields);
        });

        function setVendorPartPricingFieldsOnPFI(PartPricingFieldsOnVendor) {
            $scope.PriceFileImportModel.PartPricingFieldsOnVendor.IsCalculatePartRetailPrice = PartPricingFieldsOnVendor.IsCalculatePartRetailPriceFlag;
            $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailBaseValue = PartPricingFieldsOnVendor.RetailBaseValue;
            $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRate = PartPricingFieldsOnVendor.RetailRate;
            $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRounding = PartPricingFieldsOnVendor.RetailRounding;
            $scope.PriceFileImportModel.PartPricingFieldsOnVendor.RetailRoundTo = PartPricingFieldsOnVendor.RetailRoundTo;
        }
        $scope.PriceFileImportModel.disableChevronWhenNoLI = function() {
            return true;
        }
        $scope.PriceFileImportModel.reCalculateHeightForSections = function() {
            setTimeout(function() {
                if ($scope.PriceFileImportModel.selectedcashSaleChevronIndex == '2') {
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("position", "absolute");
                    angular.element(".cashSaleContent").css("height", (angular.element(".priceFileImporterFileToImport").height() + 160));
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("height", (angular.element(".priceFileImporterFileToImport").height() + 190));
                    angular.element(".cashSaleDetailsSection").css("height", (angular.element(".priceFileImporterFileToImport").height() + 190));
                } else if ($scope.PriceFileImportModel.selectedcashSaleChevronIndex == '1') {
                    setTimeout(function() {
                        $scope.PriceFileImportModel.calculateGridContainerHeight();
                    }, 10);
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("position", "fixed");
                }
            }, 100);
        }
        $scope.PriceFileImportModel.calculateGridContainerHeight = function() {
            var GridContainerHeight = screen.height - (angular.element(".headerNav").height() + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSaleCopyright").height() + 105);
            angular.element(".cashSaleGridWrpper").css("height", GridContainerHeight);
            var CashSaleContentContainerHeight = GridContainerHeight;
            angular.element(".cashSaleContent").css("height", CashSaleContentContainerHeight);
            angular.element(".priceFileResult").css("height", CashSaleContentContainerHeight);
            angular.element(".cashSaleDetailsSection").css("height", CashSaleContentContainerHeight);
            var priceFileImporterSectionHeight = CashSaleContentContainerHeight - 94;
            var priceFileImporterContentSectionHeight = priceFileImporterSectionHeight - 52;
            angular.element(".priceFileImporterContentSection").css("height", priceFileImporterContentSectionHeight);
            var dragAndDropHeaderMarginLeft = (angular.element(".dragAndDropHeaderSection").width() - 358) / 2;
            angular.element(".dragAndDropHeaderSection h2").css("margin-left", dragAndDropHeaderMarginLeft);
            angular.element(".dragAndDropHeaderSection span.orSectionmargin").css("margin-left", dragAndDropHeaderMarginLeft);
            var browseActionBtnMarginLeft = (angular.element(".priceFileImporterContentSection").width() - 195) / 2;
            var scrollableDivHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight;
            angular.element(".cashSaleHeader_and_cashSaleGridWrpper").css("height", scrollableDivHeight);
            var GridContainerMB = angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height();
            setTimeout(function() {
                if (angular.element('.cashSaleGridWrpper').length > 0) {
                    angular.element('.cashSaleGridWrpper')[0].scrollIntoView(true);
                }
            }, 10);
        }
        $scope.PriceFileImportModel.removeFile = function() {
            $scope.PriceFileImportModel.PriceFileTabledata = [];
            $scope.PriceFileImportModel.fieldNumber = 1;
            $scope.PriceFileImportModel.delimiter = ',';
            $scope.PriceFileImportModel.IsInstall = false;
            $('#fileUpload').attr('title', 'No file chosen');
            setTimeout(function() {
                $scope.PriceFileImportModel.calculateGridContainerHeight();
            }, 10);
            $scope.PriceFileImportModel.recentlyAddedVendor = null;
            $scope.$broadcast("clearSearchTermBeforeImportNewFile", '');
        }
        $scope.PriceFileImportModel.NextAction = function(index) {
            $scope.PriceFileImportModel.selectedcashSaleChevronIndex = index;
            $scope.PriceFileImportModel.displaySection = $scope.PriceFileImportModel.priceFileChevronList[index].Name;
        }
        $scope.PriceFileImportModel.backAction = function() {
            if ($scope.PriceFileImportModel.selectedcashSaleChevronIndex == 1) {
                $scope.PriceFileImportModel.MoveToState('UserSetting', {
                    Id: 'Home'
                });
            } else {
                $scope.PriceFileImportModel.selectedcashSaleChevronIndex = $scope.PriceFileImportModel.selectedcashSaleChevronIndex - 1;
            }
        }
        $scope.PriceFileImportModel.validateFieldsMappedOnSubmit = function() {
            var isUnMapped = false;
            for (var i = 0; i < $scope.PriceFileImportModel.PartRecordResultJson.length; i++) {
                if ($scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'Enviro Fee' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'Vendor' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'Mfg Part #' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'SKU #' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'PACKAGE QTY' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'ALL PRICES ARE PER ITEM' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'ALL COSTS ARE PER ITEM' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'REPLACED BY PART#' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'REPLACES PART#' && $scope.PriceFileImportModel.PartRecordResultJson[i].Key != 'Category' && ($scope.PriceFileImportModel.PartRecordResultJson[i].Value == '' || $scope.PriceFileImportModel.PartRecordResultJson[i].Value == 'Calculation not defined')) {
                    isUnMapped = true;
                    $scope.PriceFileImportModel.enableSubmitBtn = false;
                }
            }
            if (!isUnMapped) {
                $scope.PriceFileImportModel.enableSubmitBtn = true;
            }
        }
        $scope.PriceFileImportModel.hideGrid = function() {
            $scope.PriceFileImportModel.isDisabled = false;
            $scope.PriceFileImportModel.TableObject.TableData = [];
            $scope.PriceFileImportModel.TableObject.TableHeader = [];
            if (!$scope.$$phase) {
                $scope.$apply(); // TODO
            }
        }
        $scope.PriceFileImportModel.TableObject = {};
        $scope.PriceFileImportModel.TableObject.TableData = [];
        $scope.PriceFileImportModel.TableHeader = [];
        $scope.PriceFileImportModel.FirstRecord = 0;
        $scope.PriceFileImportModel.FileLength = 0;
        $scope.PriceFileImportModel.rows = [];
        $scope.PriceFileImportModel.cells = [];
        $scope.PriceFileImportModel.ReadData = function() {
            $scope.PriceFileImportModel.tableData = [];
            var arr = [];
            var rows = $scope.PriceFileImportModel.rows;
            var tableRecord = 0;
            var cells = rows[$scope.PriceFileImportModel.FirstRecord - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
            $scope.PriceFileImportModel.FileLength = $scope.PriceFileImportModel.rows.length;
            for (i = 0; i < cells.length; i++) {
            	  arr[i] = [];
                arr[i].push({
                    ['Record' + $scope.PriceFileImportModel.FirstRecord]: cells[i]
                });
            }
            $scope.PriceFileImportModel.TableHeader[tableRecord] = 'Record ' + $scope.PriceFileImportModel.FirstRecord
            tableRecord++;
            for (var k = $scope.PriceFileImportModel.FirstRecord + 1; k <= $scope.PriceFileImportModel.LastRecord; k++) {
                $scope.PriceFileImportModel.TableHeader[tableRecord] = 'Record ' + k;
                var cells = rows[k - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                for (i = 0; i < cells.length; i++) {
                    arr[i].push({
                        ['Record' + k]: cells[i]
                    });
                }
                tableRecord++;
                if ($scope.PriceFileImportModel.LastRecord == k) {
                    break;
                }
            }
            $scope.PriceFileImportModel.PriceFileTabledata = arr;
            $timeout(function() {
                $scope.PriceFileImportModel.calculateTbodyWidth();
            }, 5);
        }
        $scope.PriceFileImportModel.NextRecords = function() {
            if ($scope.PriceFileImportModel.LastRecord == $scope.PriceFileImportModel.FileLength) {} else {
                $scope.PriceFileImportModel.FirstRecord = $scope.PriceFileImportModel.FirstRecord + 1;
                $scope.PriceFileImportModel.LastRecord = $scope.PriceFileImportModel.LastRecord + 1;
                $scope.PriceFileImportModel.ReadData();
            }
        }
        $scope.PriceFileImportModel.PreviousRecords = function() {
            if ($scope.PriceFileImportModel.FirstRecord <= 1) {} else {
                $scope.PriceFileImportModel.FirstRecord = $scope.PriceFileImportModel.FirstRecord - 1;
                $scope.PriceFileImportModel.LastRecord = $scope.PriceFileImportModel.LastRecord - 1;
                $scope.PriceFileImportModel.ReadData();
            }
        }
        $scope.PriceFileImportModel.checkHeaderInclude = function() {
            $scope.PriceFileImportModel.IsInstall = !$scope.PriceFileImportModel.IsInstall
        }
        $scope.PriceFileImportModel.changeFieldLable = function(event, currentNumber) {
            var currentNumber = parseInt(currentNumber);
            if (currentNumber == 0) {
                Notification.error($translate.instant('Zero_not_allowed'));
                return;
            }
            var totalNumber = currentNumber - $scope.PriceFileImportModel.FirstRecord;
            if ((totalNumber + $scope.PriceFileImportModel.LastRecord) <= $scope.PriceFileImportModel.FileLength) {
                $scope.PriceFileImportModel.FirstRecord += totalNumber;
                $scope.PriceFileImportModel.LastRecord += totalNumber;
                $scope.PriceFileImportModel.ReadData();
            } else if ((totalNumber + $scope.PriceFileImportModel.LastRecord) <= $scope.PriceFileImportModel.FileLength + 1) {
                $scope.PriceFileImportModel.FirstRecord = $scope.PriceFileImportModel.FileLength - 2;
                $scope.PriceFileImportModel.LastRecord = $scope.PriceFileImportModel.FileLength;
                $scope.PriceFileImportModel.ReadData();
            } else {
                Notification.error($translate.instant('Cannot_set_records_to_field_label'));
                $scope.PriceFileImportModel.fieldNumber = 1
                $scope.PriceFileImportModel.changeFieldLable(event, $scope.PriceFileImportModel.fieldNumber);
            }
        }
        $scope.PriceFileImportModel.validateCSV = function(fileUpload) {
            $scope.PriceFileImportModel.isDisabledButton = false;
            $scope.PriceFileImportModel.isDisabled = false;
            $scope.PriceFileImportModel.FirstRecord = 1;
            $scope.PriceFileImportModel.LastRecord = 3;
            $scope.PriceFileImportModel.tableData = [];
            var regex = /^([a-zA-Z0-9\s_\\.\-:()])+(.csv|.txt)$/;
            if (regex.test(fileUpload.name.toLowerCase())) {
                if (typeof(FileReader) != "undefined") {
                    $scope.PriceFileImportModel.isDisabled = true;
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        $scope.PriceFileImportModel.rows = e.target.result.split("\r\n");
                        for (var i = 0; i < $scope.PriceFileImportModel.rows.length; i++) {
                            if (!$scope.PriceFileImportModel.rows[i]) {
                                $scope.PriceFileImportModel.rows.splice(i, 1);
                                i = i - 1;
                            }
                        }
                        if ($scope.PriceFileImportModel.rows[0].indexOf(',') > -1) {
                            $scope.PriceFileImportModel.delimiter = ',';
                        } else if ($scope.PriceFileImportModel.rows[0].indexOf('\r\t') > -1) {
                            $scope.PriceFileImportModel.delimiter = '\r\t';
                        }
                        var header = $scope.PriceFileImportModel.rows[0].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                        for (var i = 0; i < $scope.PriceFileImportModel.rows.length - 1; i++) {
                            var row = {};
                            var cells = $scope.PriceFileImportModel.rows[i].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                        }
                        $scope.PriceFileImportModel.ReadData();
                        if (!$scope.$$phase) {
                            $scope.$apply(); //TODO
                        }
                    }
                    reader.readAsText(fileUpload);
                    $scope.FileUpload.uploadFile(fileUpload);
                    $scope.FileUpload.firsttime = false;
                } else {
                    Notification.error($translate.instant('MasterDataUpload_Browser_Support'));
                }
            } else {
                Notification.error($translate.instant('MasterDataUpload_Please_upload_a_valid_CSV_file'));
                $('#fileUpload').attr('title', 'No file chosen');
            }
        }
        $scope.PriceFileImportModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        setTimeout(function() {
            $scope.PriceFileImportModel.loadPriceFileImport();
        }, 100);
    }])
});