define(['Routing_AppJs_PK', 'COAImportServices', 'NumberOnlyInputBlur_COAImport', 'PriceFileImport_Select'], function(Routing_AppJs_PK, COAImportServices, NumberOnlyInputBlur_COAImport, PriceFileImport_Select) { 
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('COAImportCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$sce', '$stateParams', '$state', 'COAImportService', function($scope, $timeout, $q, $rootScope, $sce, $stateParams, $state, COAImportService) {
        var Notification = injector1.get("Notification");
        if ($scope.COAImportModel == undefined) {
            $scope.COAImportModel = {};
        }
        $scope.COAImportModel.selectedcashSaleChevronIndex = '1';
        $scope.COAImportModel.fieldNumber = 1;
        $scope.COAImportModel.displaySection = 'Import Settings';
        $scope.COAImportModel.COAChevronList = [{
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
        
        $scope.maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
        $scope.maxFileSize = 4350000; //After Base64 Encoding, this is the max file size
        $scope.chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
        $scope.attachment = '';
        $scope.attachmentName = '';
        $scope.fileSize = 0;
        $scope.positionIndex = 0;
        $scope.isBrowseFile = false;
        $scope.FileUpload = {};
        $scope.FileUpload.maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
        $scope.FileUpload.maxFileSize = 4350000; //After Base64 Encoding, this is the max file size
        $scope.FileUpload.chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
        $scope.FileUpload.attachment = '';
        $scope.FileUpload.attachmentName = '';
        $scope.FileUpload.fileSize = 0;
        $scope.FileUpload.positionIndex = 0;
        $scope.FileUpload.isBrowseFile = false;
        $scope.COAImportModel.isProcessingFile = false;
        $scope.COAImportModel.COATabledata = [];
        $scope.COAImportModel.delimiter = ',';
        $scope.COAImportModel.IsInstall = false;
        $scope.COAImportModel.ConstantTableHeight = 290;
        $scope.COAImportModel.isScrollInTable = false;
        $scope.COAImportModel.enableSubmitBtn = false;
        $scope.COAImportModel.FieldsMapped = []
        $scope.COAImportModel.calculatedFieldsMapped = [];
        $scope.COAImportModel.SuccessResultCount = 0;
        $scope.COAImportModel.ErrorResultCount = 0;
        $scope.COAImportModel.InsertedCount = 0;
        $scope.COAImportModel.UpdatedCount = 0;
        $scope.COAImportModel.fieldMappingJSON = [];
        $scope.COAImportModel.partRecordFields = [{
            Key: "Account Number",
            isPrimary: true
        }, {
            Key: "Account Description",
            isPrimary: true
        }, {
            Key: "Account Type",
            isPrimary: true
        }];
        $scope.COAImportModel.PartRecordResultJson = [];
        for (var i = 0; i < $scope.COAImportModel.partRecordFields.length; i++) {
            if ($scope.COAImportModel.partRecordFields[i].isPrimary == true) {
                $scope.COAImportModel.PartRecordResultJson.push({
                    Key: $scope.COAImportModel.partRecordFields[i].Key,
                    Value: '',
                    MappedField: '',
                    ActualValue: '',
                    isNumericValue: false
                });
            }
        }
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
            $scope.COAImportModel.hideGrid();
            $scope.COAImportModel.validateCSV(singlefile.file);
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
        $scope.COAImportModel.calculateJsonForFields = function() {
            $scope.COAImportModel.enableSubmitBtn = false; 
            $scope.COAImportModel.fieldMappingJSON = [];
            $scope.COAImportModel.PriceFieldMappingStatusJSON = [];
            $scope.COAImportModel.FieldsMapped = []
            $scope.COAImportModel.calculatedFieldsMapped = [];
            $scope.COAImportModel.fieldMappingJSON = [];
            $scope.COAImportModel.partRecordFields = [{
                Key: "Account Number",
                isPrimary: true
            }, {
                Key: "Account Description",
                isPrimary: true
            }, {
                Key: "Account Type",
                isPrimary: true
            }];
            $scope.COAImportModel.PartRecordResultJson = [];
            for (var i = 0; i < $scope.COAImportModel.partRecordFields.length; i++) {
                if ($scope.COAImportModel.partRecordFields[i].isPrimary == true) {
                    $scope.COAImportModel.PartRecordResultJson.push({
                        Key: $scope.COAImportModel.partRecordFields[i].Key,
                        Value: '',
                        MappedField: '',
                        ActualValue: ''
                    });
                }
            }
            var fieldLabel = '';
            if (!$scope.COAImportModel.IsInstall) {
                var setRecord = $scope.COAImportModel.fieldNumber - 1;
                var arr = $scope.COAImportModel.rows[setRecord].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                for (i = 0; i < arr.length; i++) {
                    fieldLabel = arr[i].toUpperCase()
                    $scope.COAImportModel.fieldMappingJSON.push({
                        id: i,
                        label: fieldLabel
                    });
                }
                if ($scope.COAImportModel.fieldNumber != $scope.COAImportModel.FileLength) {
                    var arrNext = $scope.COAImportModel.rows[setRecord + 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                    for (i = 0; i < arr.length; i++) {
                        fieldLabel = arr[i].toUpperCase()
                        $scope.COAImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: fieldLabel,
                            value: arrNext[i],
                            status: ''
                        });
                    }
                } else {
                    var arrPrev = $scope.COAImportModel.rows[setRecord - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                    for (i = 0; i < arr.length; i++) {
                        fieldLabel = arr[i].toUpperCase()
                        $scope.COAImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: fieldLabel,
                            value: arrPrev[i],
                            status: ''
                        });
                    }
                }
                return;
            } else {
                var rows = $scope.COAImportModel.rows;
                var tableRecord = 0;
                var cells = rows[0].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                for (var i = 0; i < $scope.COAImportModel.COATabledata.length; i++) {
                    $scope.COAImportModel.fieldMappingJSON.push({
                        id: i,
                        label: 'COLUMN ' + String.fromCharCode(65 + i)
                    });
                    if ($scope.COAImportModel.fieldNumber != $scope.COAImportModel.FileLength) {
                        var arrNext = cells
                        $scope.COAImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: 'COLUMN ' + String.fromCharCode(65 + i),
                            value: arrNext[i],
                            status: ''
                        });
                    } else {
                        var arrPrev = cells
                        $scope.COAImportModel.PriceFieldMappingStatusJSON.push({
                            fieldLabel: 'COLUMN ' + String.fromCharCode(65 + i),
                            value: arrPrev[i],
                            status: ''
                        });
                    }
                }
            }
        }
        $scope.COAImportModel.closeComfirmationPopup = function(cancel) {
            if (cancel == true) {
                angular.element('#ProcessFileConfirmationPopup').modal('hide');
                return;
            }
            $scope.COAImportModel.mergeMappedFields()
        }
        $scope.COAImportModel.openComfirmationPopup = function() {
            angular.element('#ProcessFileConfirmationPopup').modal('show');
        }
        $scope.COAImportModel.mergeMappedFields = function() {
            $scope.COAImportModel.SuccessResultCount = 0;
            $scope.COAImportModel.ErrorResultCount = 0;
            $scope.COAImportModel.InsertedCount = 0;
            $scope.COAImportModel.UpdatedCount = 0; 
            angular.element('#ProcessFileConfirmationPopup').modal('hide');
            $scope.COAImportModel.isProcessingFile = true;
            var ImportJsonMap = {
                'ACCOUNT NUMBER': {
                    key: 'AccountNumber',
                    valueIndex: '',
                    formula: []
                },
                'ACCOUNT DESCRIPTION': {
                    key: 'AccountDescription',
                    valueIndex: '',
                    formula: []
                },
                'ACCOUNT TYPE': {
                    key: 'AccountType',
                    valueIndex: '',
                    formula: []
                }
            }
            var resultIndex = 0;
            for (resultIndex = 0; resultIndex < $scope.COAImportModel.PartRecordResultJson.length; resultIndex++) {
                for (i = 0; i < $scope.COAImportModel.PriceFieldMappingStatusJSON.length; i++) {
                    if ($scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel.toLowerCase() == $scope.COAImportModel.PartRecordResultJson[resultIndex].MappedField.toLowerCase() && ImportJsonMap[$scope.COAImportModel.PartRecordResultJson[resultIndex].Key.toUpperCase()] != undefined) { 
                        ImportJsonMap[$scope.COAImportModel.PartRecordResultJson[resultIndex].Key.toUpperCase()].valueIndex = i;
                    }
                }
            };
            $scope.COAImportModel.importstart($scope.COAImportModel.fieldNumber, ImportJsonMap, false);
        }
        $scope.COAImportModel.importstart = function(fileIndexstart, ImportJsonMap, isRepeat) {
            var ImportJsonMap = ImportJsonMap;
            var importCOAJson = [];
            var counter = 0;
            var mappedvalue = 0;
            var mappedkey = '';
            fileIndexstart = ($scope.COAImportModel.IsInstall == true && isRepeat == false) ? 0 : fileIndexstart;
            for (fileIndex = fileIndexstart; fileIndex < $scope.COAImportModel.rows.length; fileIndex++) {
                var cells = $scope.COAImportModel.rows[fileIndex].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
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
                if ((cells[ImportJsonMap['ACCOUNT NUMBER'].valueIndex])) {
                    importCOAJson.push(element);
                }
                if (fileIndex == ($scope.COAImportModel.rows.length - 1) || counter == 600) {
                    COAImportService.InserCOARecords(angular.toJson(importCOAJson)).then(function(successfulSearchResult) {
                        if (parseFloat(successfulSearchResult.SucessCount) != 'NAN') {
                            $scope.COAImportModel.SuccessResultCount += parseFloat(successfulSearchResult.SucessCount);
                            $scope.COAImportModel.InsertedCount += parseFloat(successfulSearchResult.NewRecords);
                            $scope.COAImportModel.UpdatedCount += parseFloat(successfulSearchResult.SucessCount) - parseFloat(successfulSearchResult.NewRecords);
                            $scope.COAImportModel.SuccessResultCount += parseFloat(successfulSearchResult.ErrorCount);
                            $scope.COAImportModel.ErrorResultCount += parseFloat(successfulSearchResult.ErrorCount);
                        }
                        if (fileIndex == ($scope.COAImportModel.rows.length - 1)) {
                            $scope.COAImportModel.isProcessingFile = false;
                        } else {
                            $scope.COAImportModel.importstart((fileIndex + 1), ImportJsonMap, true);
                        }
                    }, function(errorSearchResult) {
                        responseData = errorSearchResult;
                        angular.element('#ProcessFileConfirmationPopup').modal('hide');
                    });
                    break;
                }
                counter++
            }
        }
        $scope.COAImportModel.updateStatusOfMappedFields = function(index) {
            var PriceFieldMappingStatusJSON;
            if ($scope.COAImportModel.FieldsMapped[index] == undefined) {
                return;
            }
            for (var i = 0; i < $scope.COAImportModel.PriceFieldMappingStatusJSON.length; i++) {
                if (($scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel).toUpperCase() == ($scope.COAImportModel.FieldsMapped[index]).toUpperCase()) {
                    PriceFieldMappingStatusJSON = $scope.COAImportModel.PriceFieldMappingStatusJSON[i];
                    break;
                }
            }
            for (var j = 0; j < $scope.COAImportModel.PartRecordResultJson.length; j++) {
                if ($scope.COAImportModel.partRecordFields[index].Key == $scope.COAImportModel.PartRecordResultJson[j].Key) {
                    if (!$scope.COAImportModel.partRecordFields[index].isPrimary) {
                        $scope.COAImportModel.PartRecordResultJson[j].Value = PriceFieldMappingStatusJSON.value;
                        $scope.COAImportModel.PartRecordResultJson[j].MappedField = PriceFieldMappingStatusJSON.fieldLabel;
                        $scope.COAImportModel.PartRecordResultJson[j].ActualValue = PriceFieldMappingStatusJSON.fieldLabel;
                    } else {
                        $scope.COAImportModel.PartRecordResultJson[j].Value = PriceFieldMappingStatusJSON.value;
                        $scope.COAImportModel.PartRecordResultJson[j].ActualValue = PriceFieldMappingStatusJSON.fieldLabel
                        $scope.COAImportModel.PartRecordResultJson[j].MappedField = PriceFieldMappingStatusJSON.fieldLabel;
                    }
                    var fieldName = $scope.COAImportModel.PartRecordResultJson[j].Key;
                    break;
                }
            }
            for (var i = 0; i < $scope.COAImportModel.PriceFieldMappingStatusJSON.length; i++) {
                if ($scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != '' && $scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != null && $scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel != undefined) { 
                    for (var j = 0; j < $scope.COAImportModel.PartRecordResultJson.length; j++) {
                        if (($scope.COAImportModel.PriceFieldMappingStatusJSON[i].fieldLabel).toUpperCase() == ($scope.COAImportModel.PartRecordResultJson[j].MappedField).toUpperCase()) {
                            $scope.COAImportModel.PriceFieldMappingStatusJSON[i].status = 'Mapped';
                            break;
                        } else {
                            $scope.COAImportModel.PriceFieldMappingStatusJSON[i].status = '';
                        }
                    }
                }
            }
            $scope.COAImportModel.validateFieldsMappedOnSubmit();
        }
        $scope.FileUpload.uploadAttachment = function() {
            $scope.FileUpload.isloading = true;
        }
        $scope.COAImportModel.loadCOAImport = function() {
            setTimeout(function() {
                $scope.COAImportModel.calculateGridContainerHeight();
            }, 10);
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip();
            }, 1000);
        }
        $scope.COAImportModel.calculateTbodyWidth = function() {
            if (angular.element(".grid_COAData tbody").height() < $scope.COAImportModel.ConstantTableHeight) {
                $scope.COAImportModel.isScrollInTable = true;
            } else {
                $scope.COAImportModel.isScrollInTable = false;
            }
        }
        $scope.$on('COAImportSTACallback', function(name, args) {
            $scope.COAImportModel.recentlyAddedVendor = args;
        });
        $scope.COAImportModel.disableChevronWhenNoLI = function() {
            return true;
        }
        $scope.COAImportModel.reCalculateHeightForSections = function() {
            setTimeout(function() {
                if ($scope.COAImportModel.selectedcashSaleChevronIndex == '2') {
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("position", "absolute");
                    angular.element(".cashSaleContent").css("height", (angular.element(".COAImporterFileToImport").height() + 160));
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("height", (angular.element(".COAImporterFileToImport").height() + 140));
                    angular.element(".cashSaleDetailsSection").css("height", (angular.element(".COAImporterFileToImport").height() + 160));
                } else if ($scope.COAImportModel.selectedcashSaleChevronIndex == '1') {
                    $scope.COAImportModel.calculateGridContainerHeight();
                    angular.element(".print_barcodeScanner_And_STA_Wrapper").css("position", "fixed");
                }
            }, 100);
        }
        $scope.COAImportModel.calculateGridContainerHeight = function() {
            var GridContainerHeight = screen.height - (angular.element(".headerNav").height() + angular.element(".cashSaleCrumbs_UL").height() + angular.element(".cashSaleCopyright").height() + 105);
            angular.element(".cashSaleGridWrpper").css("height", GridContainerHeight);
            var CashSaleContentContainerHeight = GridContainerHeight;
            angular.element(".cashSaleContent").css("height", CashSaleContentContainerHeight);
            angular.element(".COAResult").css("height", CashSaleContentContainerHeight);
            angular.element(".cashSaleDetailsSection").css("height", CashSaleContentContainerHeight);
            var COAImporterSectionHeight = CashSaleContentContainerHeight - 94;
            var COAImporterContentSectionHeight = COAImporterSectionHeight - 52;
            angular.element(".COAImporterContentSection").css("height", COAImporterContentSectionHeight);
            var dragAndDropHeaderMarginLeft = (angular.element(".dragAndDropHeaderSection").width() - 358) / 2;
            angular.element(".dragAndDropHeaderSection h2").css("margin-left", dragAndDropHeaderMarginLeft);
            angular.element(".dragAndDropHeaderSection span.orSectionmargin").css("margin-left", dragAndDropHeaderMarginLeft);
            var browseActionBtnMarginLeft = (angular.element(".COAImporterContentSection").width() - 195) / 2;
            var scrollableDivHeight = angular.element(".cashSale_header_OrdNumber_status").height() + GridContainerHeight;
            angular.element(".cashSaleHeader_and_cashSaleGridWrpper").css("height", scrollableDivHeight);
            var GridContainerMB = angular.element("#mainContainerDueSection").height() + angular.element(".cashSaleCopyright").height();
            setTimeout(function() {
                if (angular.element('.cashSaleGridWrpper').length > 0) {
                    angular.element('.cashSaleGridWrpper')[0].scrollIntoView(true);
                }
            }, 10);
        }
        $scope.COAImportModel.removeFile = function() {
            $scope.COAImportModel.COATabledata = [];
            $scope.COAImportModel.fieldNumber = 1;
            $scope.COAImportModel.delimiter = ',';
            $scope.COAImportModel.IsInstall = false;
            $('#fileUpload').attr('title', 'No file chosen'); 
            setTimeout(function() {
                $scope.COAImportModel.calculateGridContainerHeight();
            }, 10);
            $scope.COAImportModel.recentlyAddedVendor = null; 
            $scope.$broadcast("clearSearchTermBeforeImportNewFile", '');
        }
        $scope.COAImportModel.NextAction = function(index) {
            $scope.COAImportModel.selectedcashSaleChevronIndex = index;
            $scope.COAImportModel.displaySection = $scope.COAImportModel.COAChevronList[index].Name;
        }
        $scope.COAImportModel.backAction = function() {
            if ($scope.COAImportModel.selectedcashSaleChevronIndex == 1) {
                loadState($state, 'AccountingIntegrationSettings');
            } else {
                $scope.COAImportModel.selectedcashSaleChevronIndex = $scope.COAImportModel.selectedcashSaleChevronIndex - 1;
            }
        }
        $scope.COAImportModel.validateFieldsMappedOnSubmit = function() {
            var isUnMapped = false;
            for (var i = 0; i < $scope.COAImportModel.PartRecordResultJson.length; i++) {
                if ($scope.COAImportModel.PartRecordResultJson[i].Value == '') {
                    isUnMapped = true;
                    $scope.COAImportModel.enableSubmitBtn = false;
                }
            }
            if (!isUnMapped) {
                $scope.COAImportModel.enableSubmitBtn = true;
            }
        }
        $scope.COAImportModel.hideGrid = function() {
            $scope.COAImportModel.isDisabled = false;
            $scope.COAImportModel.TableObject.TableData = [];
            $scope.COAImportModel.TableObject.TableHeader = [];
            if (!$scope.$$phase) {
                $scope.$apply(); //TODO
            }
        }
        $scope.COAImportModel.TableObject = {};
        $scope.COAImportModel.TableObject.TableData = [];
        $scope.COAImportModel.TableHeader = [];
        $scope.COAImportModel.FirstRecord = 0;
        $scope.COAImportModel.FileLength = 0;
        $scope.COAImportModel.rows = [];
        $scope.COAImportModel.cells = [];
        $scope.COAImportModel.ReadData = function() {
            $scope.COAImportModel.tableData = [];
            var arr = [];
            var rows = $scope.COAImportModel.rows;
            var tableRecord = 0;
            var cells = rows[$scope.COAImportModel.FirstRecord - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/); 
            $scope.COAImportModel.FileLength = $scope.COAImportModel.rows.length;
            for (i = 0; i < cells.length; i++) {
                arr[i] = [];
             arr[i].push({
                    ['Record' + $scope.COAImportModel.FirstRecord]: cells[i]
                });
            }
            $scope.COAImportModel.TableHeader[tableRecord] = 'Record ' + $scope.COAImportModel.FirstRecord
            tableRecord++;
            for (var k = $scope.COAImportModel.FirstRecord + 1; k <= $scope.COAImportModel.LastRecord; k++) {
                $scope.COAImportModel.TableHeader[tableRecord] = 'Record ' + k;
                var cells = rows[k - 1].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/); 
                for (i = 0; i < cells.length; i++) {
                     arr[i].push({
                        ['Record' + k]: cells[i]
                    });
                }
                tableRecord++;
                if ($scope.COAImportModel.LastRecord == k) {
                    break;
                }
            }
            $scope.COAImportModel.COATabledata = arr;
            $timeout(function() {
                $scope.COAImportModel.calculateTbodyWidth();
            }, 5);
        }
        $scope.COAImportModel.NextRecords = function() {
            if ($scope.COAImportModel.LastRecord == $scope.COAImportModel.FileLength) {
            } else {
                $scope.COAImportModel.FirstRecord = $scope.COAImportModel.FirstRecord + 1;
                $scope.COAImportModel.LastRecord = $scope.COAImportModel.LastRecord + 1;
                $scope.COAImportModel.ReadData();
            }
        }
        $scope.COAImportModel.PreviousRecords = function() {
            if ($scope.COAImportModel.FirstRecord <= 1) {
            } else {
                $scope.COAImportModel.FirstRecord = $scope.COAImportModel.FirstRecord - 1;
                $scope.COAImportModel.LastRecord = $scope.COAImportModel.LastRecord - 1;
                $scope.COAImportModel.ReadData();
            }
        }
        $scope.COAImportModel.checkHeaderInclude = function() {
            $scope.COAImportModel.IsInstall = !$scope.COAImportModel.IsInstall
        }
        $scope.COAImportModel.changeFieldLable = function(event, currentNumber) {
            var currentNumber = parseInt(currentNumber);
            if (currentNumber == 0) {
                Notification.error('Zero not allowed ');
                return;
            }
            var totalNumber = currentNumber - $scope.COAImportModel.FirstRecord;
            if ((totalNumber + $scope.COAImportModel.LastRecord) <= $scope.COAImportModel.FileLength) {
                $scope.COAImportModel.FirstRecord += totalNumber;
                $scope.COAImportModel.LastRecord += totalNumber;
                $scope.COAImportModel.ReadData();
            } else if ((totalNumber + $scope.COAImportModel.LastRecord) <= $scope.COAImportModel.FileLength + 1) {
                $scope.COAImportModel.FirstRecord = $scope.COAImportModel.FileLength - 2;
                $scope.COAImportModel.LastRecord = $scope.COAImportModel.FileLength;
                $scope.COAImportModel.ReadData();
            } else {
                Notification.error('Cannot Set Records To Field Label');
                $scope.COAImportModel.fieldNumber = 1
                $scope.COAImportModel.changeFieldLable(event, $scope.COAImportModel.fieldNumber);
            }
        }
        $scope.COAImportModel.validateCSV = function(fileUpload) {
            $scope.COAImportModel.isDisabledButton = false;
            $scope.COAImportModel.isDisabled = false;
            $scope.COAImportModel.FirstRecord = 1;
            $scope.COAImportModel.LastRecord = 3;
            $scope.COAImportModel.tableData = [];
            var regex = /^([a-zA-Z0-9\s_\\.\-:()])+(.csv|.txt)$/;
            if (regex.test(fileUpload.name.toLowerCase())) {
                if (typeof(FileReader) != "undefined") {
                    $scope.COAImportModel.isDisabled = true;
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        $scope.COAImportModel.rows = e.target.result.split("\r\n");
                        for (var i = 0; i < $scope.COAImportModel.rows.length; i++) {
                            if (!$scope.COAImportModel.rows[i]) {
                                $scope.COAImportModel.rows.splice(i, 1);
                                i = i - 1;
                            }
                        }
                        if ($scope.COAImportModel.rows[0].indexOf(',') > -1) {
                            $scope.COAImportModel.delimiter = ',';
                        } else if ($scope.COAImportModel.rows[0].indexOf('\r\t') > -1) {
                            $scope.COAImportModel.delimiter = '\r\t';
                        }
                        var header = $scope.COAImportModel.rows[0].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                        for (var i = 0; i < $scope.COAImportModel.rows.length - 1; i++) {
                            var row = {};
                            var cells = $scope.COAImportModel.rows[i].split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/);
                        } 
                        $scope.COAImportModel.ReadData();
                        if (!$scope.$$phase) {
                            $scope.$apply(); //TODO
                        }
                    }
                    reader.readAsText(fileUpload);
                    $scope.FileUpload.uploadFile(fileUpload);
                    $scope.FileUpload.firsttime = false;
                } else {
                    Notification.error("This browser does not support HTML5.");
                }
            } else {
                Notification.error("Please upload a valid CSV file.");
                $('#fileUpload').attr('title', 'No file chosen'); 
            }
        }
        $scope.COAImportModel.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.COAImportModel.loadCOAImport();
    }])
});