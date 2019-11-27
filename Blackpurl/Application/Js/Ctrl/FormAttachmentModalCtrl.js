define(['Routing_AppJs_PK', 'FormRepositoryServices'], function(Routing_AppJs_PK, FormRepositoryServices) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('FormAttachmentModalCtrl', ['$scope', '$timeout', '$rootScope', '$state', '$stateParams', '$translate', 'FormRepositoryService', function($scope, $timeout, $rootScope, $state, $stateParams, $translate, FormRepositoryService) {
        var Notification = injector1.get("Notification");
        $scope.AddAttachment = $scope.AddAttachment || {};
        
        //Constants
        var allowedExtensions = [];
        var allowedFileTypesType;
        var maxStringSize;
        var maxFileSize;
        var chunkSize;
        var isBrowseFile = false;
        
        //Uploaded file instance
        $scope.FileUpload = {};
        $scope.FileUpload.attachment = '';
        $scope.FileUpload.attachmentName = '';
        $scope.FileUpload.fileSize = 0;
        $scope.FileUpload.positionIndex = 0;
        //$scope.AddAttachment.index = 0;
        
        //This is the code for ng-droplet
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
        
        // Listen for when the interface has been configured.
        /*$scope.$on('$dropletReady', function whenDropletReady() {
            try {
                $scope.FileUpload.interface.allowedExtensions(['png', 'jpg', 'bmp', 'gif', 'txt', 'pdf', 'svg', 'torrent']);
                $scope.FileUpload.interface.defineHTTPSuccess([/2.{2}/]);
                $scope.FileUpload.interface.useArray(false);
                $scope.FileUpload.interface.setMaximumValidFiles(1);
            } catch (ex) {}
        });*/
        $scope.$on('$dropletReady', function whenDropletReady() {
            try {
                var el = angular.element("droplet input[type=file]");
                el.attr('accept', 'pdf/*');
            } catch (ex) {}
        });
        
       // Listen for when the files have been successfully uploaded.
        /*$scope.$on('$dropletSuccess', function onDropletSuccess(event, response, files) {
            $scope.FileUpload.uploadCount = files.length;
            $scope.FileUpload.success = true;
            $timeout(function timeout() {
                $scope.FileUpload.success = false;
            }, 100);
        });*/
        // Listen for when the files have failed to upload.
        /*$scope.$on('$dropletError', function onDropletError(event, response) {
            $scope.FileUpload.error = true;
            $timeout(function timeout() {
                $scope.FileUpload.error = false;
            }, 100);
        });*/
        
        
        /*$scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
            $scope.FileUpload.fileToBeUploaded = singlefile.file;
            if (!$scope.AddAttachment.fromNewUI) {
                $scope.$parent.CustomerOrderModel.SelectedSection.index += 1;
            }
            $scope.AddAttachment.uploadAttachmentFile();
        });*/
        $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
        	$scope.FileUpload.fileToBeUploaded = singlefile.file;
            var fileExtension = getExtension($scope.FileUpload.fileToBeUploaded);
            var fileType = $scope.FileUpload.fileToBeUploaded.type;
            if(allowedExtensions.indexOf(fileExtension) != -1 && allowedFileTypesType.test(fileType)) {
            	$scope.FileUpload.isLoading = true;
            	uploadAttachmentFile();
            } else {
            	Notification.error($translate.instant('You_must_select_a_PDF_to_upload'));//change based on const value
            }
        });
        
        function uploadAttachmentFile() {
            uploadFile($scope.FileUpload.fileToBeUploaded);
        }
        
        function uploadFile(file) {
            if (file != undefined) {
                if (file.size <= maxFileSize) {
                    $scope.FileUpload.attachmentName = file.name;
                    var fileReader = new FileReader();
                    fileReader.onload = function (e) {};
                    fileReader.onloadend = function(e) {
                        $scope.FileUpload.attachment = window.btoa(this.result); //Base 64 encode the file before sending it
                        $scope.FileUpload.positionIndex = 0;
                        $scope.FileUpload.fileSize = $scope.FileUpload.attachment.length;
                        $scope.FileUpload.doneUploading = false;
                        if ($scope.FileUpload.fileSize < maxStringSize) {
                            $scope.FileUpload.tempattachmentbody = $scope.FileUpload.attachment;
                            afterUploadAction();
                        } else {
                        	$scope.FileUpload.isLoading = false;
                        }
                    }
                    fileReader.onerror = function(e) {
                    	$scope.FileUpload.isLoading = false;
                    }
                    fileReader.onabort = function(e) {
                    	afterUploadAction();
                    }
                    fileReader.readAsBinaryString(file); //Read the body of the file
                } else {
                	$scope.FileUpload.isLoading = false;
                	Notification.error($translate.instant('File_size_should_be_less_than_750_kB'));//change it with const value
                }
            } else {
            	afterUploadAction();
            }
        }
        
        function afterUploadAction() {
        	var FileUploadObj = angular.copy($scope.FileUpload);
        	if($rootScope.currentStateName.indexOf('FormRepository') > -1) {
        		$scope.F_FormRepository.uploadAttachmentCallback(FileUploadObj);
        		$scope.AddAttachment.hideServiceJobAddAttachmentPopup();
        	} else {
        		uploadAttachment();
        	}
        	
        }
        
        /*$scope.FileUpload.uploadAttachment = function() {
            var index = $scope.AddAttachment.index;
            var source = 'Manual Upload';
            var parentId = '';
            if ($scope.AddAttachment.fromNewUI) {
                parentId = $scope.$parent.M_CO.SOHeaderList[index].SOInfo.Id;
            } else {
                source = $scope.CustomerOrderModel.isWizardMode ? 'Claim Submission' : 'Manual Upload';
                parentId = $scope.$parent.CustomerOrderModel.serviceOrderList[index].Id;
            }
            $scope.FileUpload.isloading = true;
            AttachmentService.uploadAttachment($scope.FileUpload.attachmentName, $scope.FileUpload.tempattachmentbody, parentId, source).then(function(successfulResult) {
                $scope.FileUpload.isloading = false;
                if ($scope.AddAttachment.fromNewUI) {
                    $scope.M_CO.SOHeaderList[index].AttachmentList = successfulResult;
                    $scope.FileUpload.fileToBeUploaded = '';
                    angular.element('#ServiceJobAddAttachmentPopup').modal('hide');
                    setTimeout(function() {
                        $scope.F_CO.expandInnerSection('ServiceJob' + index + '_AttachmentSectionId', 'ServiceJob' + index + '_Attachment')
                    });
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                } else {
                    $scope.CustomerOrderModel.SOHeaderList[index].AttachmentList = successfulResult;
                    $scope.CustomerOrderModel.createAttachmentGridEditItem(null);
                    Notification.success($Label.AddAttachment_Attachment_uploaded);
                    angular.element('#AddAttachmentPopup').modal('hide');
                    loadState($state, $rootScope.$previousState.name, {
                        Id: $rootScope.$previousStateParams.Id
                    });
                    $scope.CustomerOrderModel.attachmentCallback(index);
                }
                $scope.FileUpload.fileToBeUploaded = '';
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            })
        }*/
        function uploadAttachment() {
        	$scope.FileUpload.isLoading = false;
        	//alert('uploadAttachment');
            /*viewUnitService.uploadImage($scope.FileUpload.attachmentName, $scope.FileUpload.tempattachmentbody, $scope.unitId).then(function(successfulResult) {
            	if(successfulResult.responseStatus && successfulResult.responseStatus == 'error') {
            		Notification.error(successfulResult.response);
            	} else {
                    $scope.unitDetailData.ImageList = successfulResult;
                    setPrimaryImageData();
                    closeAttachmentPopup();
            	}
            	$scope.isLoading = false;
            	$scope.FileUpload.fileToBeUploaded = '';
            }, function(errorSearchResult) {
            	$scope.isLoading = false;
                responseData = errorSearchResult;
            })*/
        }
        
        function setAttachmentModalInitialData() {
        	//$scope.AddAttachment.index = $stateParams.AddAttachmentParams.soHeaderIndex;
        	allowedExtensions = $stateParams.AddAttachmentParams.allowedExtensions;
        	allowedFileTypesType = $stateParams.AddAttachmentParams.allowedFileTypesType;
    		maxStringSize = $stateParams.AddAttachmentParams.maxStringSize;
    		maxFileSize = $stateParams.AddAttachmentParams.maxFileSize;
    		chunkSize = $stateParams.AddAttachmentParams.chunkSize;
        }
        
        function openAddAttachmentModal() {
        	setAttachmentModalInitialData();
            setTimeout(function() {
                angular.element('#ServiceJobAddAttachmentPopup').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }
        
        angular.element(document).on("click", "#ServiceJobAddAttachmentPopup .modal-backdrop", function() {
        	$scope.AddAttachment.hideServiceJobAddAttachmentPopup();
        });
        
        $scope.AddAttachment.hideServiceJobAddAttachmentPopup = function() {
        	$scope.FileUpload.fileToBeUploaded = '';
        	$scope.FileUpload.isLoading = false;
            angular.element('#ServiceJobAddAttachmentPopup').modal('hide');
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        
        openAddAttachmentModal();
    }])
});