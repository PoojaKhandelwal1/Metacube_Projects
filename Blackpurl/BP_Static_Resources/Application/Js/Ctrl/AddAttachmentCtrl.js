define(['Routing_AppJs_PK', 'CustomerOrderServices_V2'], function(Routing_AppJs_PK, CustomerOrderServices_V2) {
    var injector1 = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('AddAttachmentCtrl', ['$scope', '$timeout', '$q', '$rootScope', '$state', '$stateParams', 'AttachmentService', function($scope, $timeout, $q, $rootScope, $state, $stateParams, AttachmentService) {
        var Notification = injector1.get("Notification");
        if ($scope.AddAttachment == undefined) {
            $scope.AddAttachment = {};
        }
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
        $scope.AddAttachment.index = 0;
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
        $scope.$on('$dropletReady', function whenDropletReady() {
            try {
                $scope.FileUpload.interface.allowedExtensions(['png', 'jpg', 'bmp', 'gif', 'txt', 'pdf', 'svg', 'torrent']);
                $scope.FileUpload.interface.defineHTTPSuccess([/2.{2}/]);
                $scope.FileUpload.interface.useArray(false);
                $scope.FileUpload.interface.setMaximumValidFiles(1);
            } catch (ex) {}
        });
        // Listen for when the files have been successfully uploaded.
        $scope.$on('$dropletSuccess', function onDropletSuccess(event, response, files) {
            $scope.FileUpload.uploadCount = files.length;
            $scope.FileUpload.success = true;
            $timeout(function timeout() {
                $scope.FileUpload.success = false;
            }, 100);
        });
        // Listen for when the files have failed to upload.
        $scope.$on('$dropletError', function onDropletError(event, response) {
            $scope.FileUpload.error = true;
            $timeout(function timeout() {
                $scope.FileUpload.error = false;
            }, 100);
        });
        $scope.$on('$dropletFileAdded', function onDropletFileAdded(event, singlefile) {
            $scope.FileUpload.fileToBeUploaded = singlefile.file;
            $scope.FileUpload.fileExtension = singlefile.extension;
            if (!$scope.AddAttachment.fromNewUI) {
                $scope.$parent.CustomerOrderModel.SelectedSection.index += 1;
            }
            $scope.AddAttachment.uploadAttachmentFile();
        });
        angular.element(document).on("click", "#ServiceJobAddAttachmentPopup .modal-backdrop", function() {
            if ($scope.AddAttachment.fromNewUI) {
                $scope.FileUpload.fileToBeUploaded = '';
                angular.element('#ServiceJobAddAttachmentPopup').modal('hide');
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }
        });
        $scope.AddAttachment.hideServiceJobAddAttachmentPopup = function() {
            if ($scope.AddAttachment.fromNewUI) {
                $scope.FileUpload.fileToBeUploaded = '';
                angular.element('#ServiceJobAddAttachmentPopup').modal('hide');
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }
        }
        $scope.AddAttachment.hideRelatedPartPopup = function() {
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.AddAttachment.removeAttachmentFile = function() {
            $scope.FileUpload.fileToBeUploaded = '';
        }
        $scope.AddAttachment.uploadAttachmentFile = function() {
            $scope.FileUpload.uploadFile($scope.FileUpload.fileToBeUploaded);
            $scope.FileUpload.firsttime = false;
        }
        $scope.FileUpload.uploadFile = function(file) {
            $scope.FileUpload.isloading = true;
            if (file != undefined) {
                if (file.size <= $scope.FileUpload.maxFileSize) {
                    $scope.FileUpload.attachmentName = file.name;
                    var fileReader = new FileReader();
                    fileReader.onloadend = function(e) {
                    	var fileFormat = $scope.FileUpload.fileExtension ? $scope.FileUpload.fileExtension : file.type;
                		if(!file.type || file.type == "") {
                			fileFormat = (($scope.FileUpload.attachmentName.toLowerCase()).includes("csv")) ? 'text/csv' : 
                					((($scope.FileUpload.attachmentName.toLowerCase()).includes("plain")) ? 'text/plain' : fileFormat);
                		}
                    	if($scope.AddAttachment.IsFromVendorOrder && $scope.AddAttachment.isImportingPartSmart) {
                    		$scope.$parent.VendorOrderModel.showPartSmartImportedContent(this.result, fileFormat);
                    		$scope.AddAttachment.hideServiceJobAddAttachmentPopup();
                    		return;
                    	} else if($scope.AddAttachment.isImportingPartSmart) {
                    		$scope.$parent.F_CO.showPartSmartImportedContent(this.result, fileFormat);
                    		$scope.AddAttachment.hideServiceJobAddAttachmentPopup();
                    		return;
                    	} else {
	                        $scope.FileUpload.attachment = window.btoa(this.result); //Base 64 encode the file before sending it
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
                    }
                    fileReader.onerror = function(e) {}
                    fileReader.onabort = function(e) {
                        $scope.FileUpload.isloading = false
                        $scope.FileUpload.uploadAttachment();
                    }
                    fileReader.readAsBinaryString(file); //Read the body of the file
                } else {
                    $scope.FileUpload.isloading = false;
                }
            } else {
                $scope.FileUpload.isloading = false;
                $scope.FileUpload.uploadAttachment();
            }
        }
        $scope.FileUpload.uploadAttachment = function() {
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
        }
        $scope.$on('AddAttachmentEvent', function(event, args) {
            $scope.AddAttachment.index = args.soHeaderIndex;
            setTimeout(function() {
                $scope.AddAttachment.openAddAttachmentPopup();
            }, 100);
        });
        $scope.AddAttachment.openAddAttachmentPopup = function() {
            angular.element('.controls').hide();
            if ($scope.AddAttachment.fromNewUI) {
                setTimeout(function() {
                    angular.element('#ServiceJobAddAttachmentPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 100);
            } else {
                setTimeout(function() {
                    angular.element('#AddAttachmentPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 100);
            }
        }
        $scope.AddAttachment.cancelAddAttachmentPopup = function() {
            $scope.FileUpload.fileToBeUploaded = '';
            angular.element('#AddAttachmentPopup').modal('hide');
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        $scope.AddAttachment.openAddAttachmentPopupWithRouting = function() {
            $scope.AddAttachment.index = $stateParams.AddAttachmentParams.soHeaderIndex;
            $scope.AddAttachment.fromNewUI = $stateParams.AddAttachmentParams.IsFfromNewUI;
            $scope.AddAttachment.isImportingPartSmart = $stateParams.AddAttachmentParams.IsImportingPartSmart;
            $scope.AddAttachment.IsFromVendorOrder = $stateParams.AddAttachmentParams.IsFromVendorOrder;
            $scope.AddAttachment.openAddAttachmentPopup();
        }
        $scope.AddAttachment.openAddAttachmentPopupWithRouting();
    }])
});