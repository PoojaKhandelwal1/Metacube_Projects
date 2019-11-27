define(['Routing_AppJs_PK', 'CustomerMessagingServices', 'EmailInvoiceServices','CustomerMessageAndEmailServices','VendorOrderServices'], function(Routing_AppJs_PK, CustomerMessagingServices, EmailInvoiceServices,CustomerMessageAndEmailServices, VendorOrderServices) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CustomerMessagingCtrl', ['$q', '$scope', '$rootScope', '$timeout', '$stateParams', '$state', 'CustomerMessagingServices', 'EmailInvoiceServices','$translate','CustomerMessageAndEmailServices','vendorOrderService',
        function($q, $scope, $rootScope, $timeout, $stateParams, $state, CustomerMessagingServices, EmailInvoiceServices,$translate,CustomerMessageAndEmailServices,vendorOrderService) {
            var Notification = injector.get("Notification");
            $scope.showLoading = true;
            $scope.MessagePreviewModel = {};
            $scope.MessagePreviewModel.disableSendTextButton = false;
            $scope.MessagePreviewModel.Activity = $stateParams.messagingInfoParams.Activity;
            $scope.MessagePreviewModel.CustomerInfo = {};
            $scope.MessagePreviewModel.CustomerEmailAddress = '';
            $scope.MessagePreviewModel.emailSearchObj = {
                Title: '',
                sentTo: ''
            };
            $scope.MessagePreviewModel.COType = $stateParams.messagingInfoParams.COType;
            $scope.MessagePreviewModel.CoInvoiceHeaderId = $stateParams.messagingInfoParams.COInvoiceHeaderId;
            $scope.MessagePreviewModel.DealId = $stateParams.messagingInfoParams.dealId;
            $scope.MessagePreviewModel.CoHeaderID = '';
            $scope.MessagePreviewModel.customerApprovalId = '' ;
            $scope.MessagePreviewModel.VendorOrderId = $stateParams.messagingInfoParams.VendorOrderId;
            $scope.MessagePreviewModel.VendorId = $stateParams.messagingInfoParams.VendorId;
            $scope.MessagePreviewModel.VendorOrderNumber = $stateParams.messagingInfoParams.VendorOrderNumber;
            $scope.MessagePreviewModel.EmailAddressList = [];
            $scope.MessagePreviewModel.isValidForm = true;
            $scope.MessagePreviewModel.CustomerName;
            $scope.MessagePreviewModel.IsemailListdisabled = false;
            $scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = false;
            $scope.MessagePreviewModel.IsUpdateEmailToggleSectionEnabled = false;
            $scope.MessagePreviewModel.IsPrimaryEmail = false;
            $scope.MessagePreviewModel.IsAlternateEmail = false;
            $(document).on("click", "#SendInvoiceModal .modal-backdrop", function() {
                angular.element("#SendInvoiceModal").removeClass("in");
                angular.element("body").removeClass("modal-open");
                angular.element("#SendInvoiceModal").hide();
                angular.element("#SendInvoiceModal").find('.modal-backdrop').remove();
                $scope.MessagePreviewModel.closePopUp();
            });
            $scope.MessagePreviewModel.IsEmailFromVendorOrder = $stateParams.messagingInfoParams.IsEmailFromVendorOrder;
            $scope.MessagePreviewModel.VendorName = $stateParams.messagingInfoParams.VendorName;
            $scope.MessagePreviewModel.showSentBtn = false;
            $scope.MessagePreviewModel.SMSMessagePageSortAttrsJSON = {
                ChangesCount: 0,
                CurrentPage: 1,
                PageSize: 10,
                Sorting: [{
                    FieldName: "ItemDesc",
                    SortDirection: "ASC"
                }]
            };
            try {
                $scope.MessagePreviewModel.SMSMessagePageSortAttrsJSON.PageSize = $Global.Related_List_Page_Size;
            } catch (ex) {}
            $scope.MessagePreviewModel.closePopUp = function() {
                loadState($state, $rootScope.$previousState.name, {
                    Id: $rootScope.$previousStateParams.Id
                });
            }
            $scope.MessagePreviewModel.disableSendEmailButton = function() {
                if (($scope.MessagePreviewModel.CustomerEmailAddress != undefined && $scope.MessagePreviewModel.CustomerEmailAddress != null && $scope.MessagePreviewModel.CustomerEmailAddress != '') || ($scope.MessagePreviewModel.emailSearchObj.sentTo != '' && $scope.MessagePreviewModel.emailSearchObj.sentTo != null && $scope.MessagePreviewModel.emailSearchObj.sentTo != undefined)) {
                    return false;
                }
                return true;
            }
            $scope.MessagePreviewModel.DisableListOnFocus = function() {
                $scope.MessagePreviewModel.IsemailListdisabled = true;
            }
            $scope.MessagePreviewModel.toggleEmailSelect = function(attr) {
                if(attr == 'PrimaryEmail') {
                    $scope.MessagePreviewModel.IsAlternateEmail = false;
                } else if(attr == 'AlternateEmail') {
                    $scope.MessagePreviewModel.IsPrimaryEmail = false;  
                }
            }
            $scope.MessagePreviewModel.validateEmailAddress = function(event) {
                var EmailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                var IsVAlidEmail = EmailRegEx.test($scope.MessagePreviewModel.CustomerEmailAddress);
                if ($scope.MessagePreviewModel.CustomerEmailAddress.length > 0) {
                    $scope.MessagePreviewModel.IsemailListdisabled = true;
                } else {
                    if ($scope.MessagePreviewModel.emailSearchObj.sentTo != '' && $scope.MessagePreviewModel.emailSearchObj.sentTo != null && $scope.MessagePreviewModel.emailSearchObj.sentTo != undefined) {
                        $scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = false;
                        $scope.MessagePreviewModel.IsemailListdisabled = false;
                        return;
                    }
                    $scope.MessagePreviewModel.IsemailListdisabled = false;
                    $scope.MessagePreviewModel.IsUpdateEmailToggleSectionEnabled = false;
                }
                if (IsVAlidEmail == true) {
                    $scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = false;
                    $scope.MessagePreviewModel.IsUpdateEmailToggleSectionEnabled = true;
                } else {
                    $scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = true;
                    $scope.MessagePreviewModel.IsUpdateEmailToggleSectionEnabled = false;
                }
            }
            $scope.MessagePreviewModel.openPopup = function() {
                if ($stateParams.messagingInfoParams.Activity == 'Email') {
                    if ($scope.MessagePreviewModel.CustomerEmailAddress == '' && $scope.MessagePreviewModel.CustomerName == undefined) {
                        $scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = true;
                    }
                    if ($scope.MessagePreviewModel.CustomerInfo != undefined && $scope.MessagePreviewModel.CustomerInfo != null) {
                        $scope.MessagePreviewModel.getEmailAddressList();
                    }
                } else if ($stateParams.messagingInfoParams.Activity == 'Text Message') {
                    $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMSPhone = $scope.MessagePreviewModel.getPrefferedSMSPhone();
                    $scope.MessagePreviewModel.MessageRec = {
                        'Text': '',
                        'SentTo': '',
                        'SentToId': $scope.MessagePreviewModel.CustomerInfo.Cust_Id,
                        'Activity': 'Text Message'
                    };
                    $scope.MessagePreviewModel.getSMSNumberList();
                }
                $scope.MessagePreviewModel.showSentBtn = false;
                $scope.MessagePreviewModel.setFocus('#TextBox');
                $scope.MessagePreviewModel.disableSendTextBtn = false;
                setTimeout(function() {
                    angular.element('#SendInvoiceModal').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                }, 1000);
                $scope.MessagePreviewModel.setEmailType();
            }
            $scope.MessagePreviewModel.setFocus = function(element) {
                setTimeout(function() {
                    angular.element(element).focus();
                }, 500);
            }
            $scope.MessagePreviewModel.setFocusOnInput = function() {
                $scope.MessagePreviewModel.isFocused = true;
            }
            $scope.MessagePreviewModel.setBlurOnInput = function() {
                $scope.MessagePreviewModel.isFocused = false;
            }
            $scope.MessagePreviewModel.selectEmail = function(emailobj) {
                $scope.MessagePreviewModel.isFocused = false;
                $scope.MessagePreviewModel.emailSearchObj.Title = emailobj.Title;
                $scope.MessagePreviewModel.emailSearchObj.sentTo = emailobj.sentTo;
                $scope.MessagePreviewModel.setEmailType();
            }
            $scope.MessagePreviewModel.selectNumber = function(NumberObj) {
                $scope.MessagePreviewModel.MessageRec.SentTo = NumberObj.Number;
                $scope.MessagePreviewModel.MessageRec.Title = NumberObj.Title;
            }
            $scope.MessagePreviewModel.disableSendTextButton = function() {
                if (($scope.MessagePreviewModel.MessageRec != undefined && $scope.MessagePreviewModel.MessageRec.Text != null && $scope.MessagePreviewModel.MessageRec.Text != '')) {
                    return false;
                }
                return true;
            }
            $scope.MessagePreviewModel.getSMSNumberList = function() {
                $scope.MessagePreviewModel.SMSNumberList = [];
                if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == 'Individual' && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber != "") {
                    var numberTitle = 'Home Phone: ' + $scope.MessagePreviewModel.CustomerInfo.Cust_FormattedHomeNumber;
                    if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMSPhone == $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber) {
                        $scope.MessagePreviewModel.MessageRec.SentTo = $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber;
                        $scope.MessagePreviewModel.MessageRec.Title = numberTitle;
                    }
                    $scope.MessagePreviewModel.SMSNumberList.push({
                        Title: numberTitle,
                        Number: $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber
                    });
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == 'Business' && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber != "") {
                    var numberTitle = 'Work Phone: ' + $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber;
                    if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMSPhone == $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber) {
                        $scope.MessagePreviewModel.MessageRec.SentTo = $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber;
                        $scope.MessagePreviewModel.MessageRec.Title = numberTitle;
                    }
                    $scope.MessagePreviewModel.SMSNumberList.push({
                        Title: numberTitle,
                        Number: $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber
                    });
                }
                if ($scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber != "") {
                    var numberTitle = 'Other Phone: ' + $scope.MessagePreviewModel.CustomerInfo.Cust_FormattedOtherPhone;
                    if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMSPhone == $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber) {
                        $scope.MessagePreviewModel.MessageRec.SentTo = $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber;
                        $scope.MessagePreviewModel.MessageRec.Title = numberTitle;
                    }
                    $scope.MessagePreviewModel.SMSNumberList.push({
                        Title: numberTitle,
                        Number: $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber
                    });
                }
            }
            $scope.MessagePreviewModel.getEmailAddressList = function() {
                var EmailRegEx = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
                if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredEmail) {
                    var IsVAlidEmail = EmailRegEx.test($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredEmail);
                    if (IsVAlidEmail) {
                        $scope.MessagePreviewModel.EmailAddressList.push({
                            Title: 'Email Default: ' + $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredEmail,
                            sentTo: $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredEmail
                        });
                    }
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == 'Individual' && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail != '' && EmailRegEx.test($scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail)) {
                    $scope.MessagePreviewModel.EmailAddressList.push({
                        Title: '' + $scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail,
                        sentTo: $scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail
                    });
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == 'Business' && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail != '' && EmailRegEx.test($scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail)) {
                    $scope.MessagePreviewModel.EmailAddressList.push({
                        Title: '' + $scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail,
                        sentTo: $scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail
                    });
                }
                if ($scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail != '' && EmailRegEx.test($scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail)) {
                    $scope.MessagePreviewModel.EmailAddressList.push({
                        Title: '' + $scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail,
                        sentTo: $scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail
                    });
                }
                if ($scope.MessagePreviewModel.EmailAddressList.length > 0) {
                    $scope.MessagePreviewModel.emailSearchObj.Title = $scope.MessagePreviewModel.EmailAddressList[0].Title;
                    $scope.MessagePreviewModel.emailSearchObj.sentTo = $scope.MessagePreviewModel.EmailAddressList[0].sentTo;
                	$scope.MessagePreviewModel.IsEmailInvoiceBtnEnabled = false;
                }
            }
            $scope.MessagePreviewModel.setEmailAddressLength = function() {
                var emailCharLength = $scope.MessagePreviewModel.emailSearchObj.Title.length;
                if(emailCharLength <= 15 ) {
                    emailCharLength = 2.6 * emailCharLength; 
                    setTimeout(function(){
                        angular.element(".display-email-type-text").css('left', emailCharLength + '%');
                    },10);
                } else if(emailCharLength > 15 && emailCharLength <= 25 ) {
                    emailCharLength = 2.3 * emailCharLength; 
                    setTimeout(function(){
                        angular.element(".display-email-type-text").css('left', emailCharLength + '%');
                    },10);
                } else if(emailCharLength > 25 && emailCharLength <= 36 ) {
                    emailCharLength = 2 * emailCharLength; 
                    setTimeout(function(){
                        angular.element(".display-email-type-text").css('left', emailCharLength + '%');
                    },10);
                } else if(emailCharLength > 37){
                    //emailCharLength = 76.5; //After 41 charas we fixed the width and tansform the text to ellipses 
                    setTimeout(function(){
                        angular.element(".display-email-type-text").css('display','none');
                    },10);
                }
            }
            $scope.MessagePreviewModel.setEmailType = function(){
                var modifiedEmail;
                $scope.MessagePreviewModel.checkEmailType = '';
                if($scope.MessagePreviewModel.emailSearchObj.Title != '' ){
                    
                    if($scope.MessagePreviewModel.emailSearchObj.Title.indexOf(":") !=-1){
                        var splitEmail = $scope.MessagePreviewModel.emailSearchObj.Title.split(': ');
                        modifiedEmail = splitEmail[1];    
                        if(modifiedEmail == ($scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail || $scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail)){
                            $scope.MessagePreviewModel.checkEmailType = 'Primary';
                        }
                        else if(modifiedEmail == $scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail){
                            $scope.MessagePreviewModel.checkEmailType =  'Alternate';
                        }
                    } 
                    else{
                        modifiedEmail  = $scope.MessagePreviewModel.emailSearchObj.Title;
                        if(modifiedEmail == ($scope.MessagePreviewModel.CustomerInfo.Cust_HomeEmail || $scope.MessagePreviewModel.CustomerInfo.Cust_WorkEmail)){
                            $scope.MessagePreviewModel.checkEmailType =  'Primary';
                        }
                        else if(modifiedEmail == $scope.MessagePreviewModel.CustomerInfo.Cust_OtherEmail){
                            $scope.MessagePreviewModel.checkEmailType =  'Alternate';
                        }
                    }
                    $scope.MessagePreviewModel.setEmailAddressLength(); 
                }    
            }    
            $scope.MessagePreviewModel.getPrefferedSMSPhone = function() {
                if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMS != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMS != null && $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMS != "") {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredSMS;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_MobileNumberSMS != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_MobileNumberSMS != null && $scope.MessagePreviewModel.CustomerInfo.Cust_MobileNumberSMS) {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == "Individual" && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumberSMS != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumberSMS != null && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumberSMS) {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == "Business" && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumberSMS != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumberSMS != null && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumberSMS) {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_PreferredPhone != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredPhone != null && $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredPhone != "") {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_PreferredPhone;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber != null && $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber != "") {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_OtherNumber;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == "Individual" && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber != null && $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber != "") {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_HomeNumber;
                } else if ($scope.MessagePreviewModel.CustomerInfo.Cust_Type == "Business" && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber != undefined && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber != null && $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber != "") {
                    return $scope.MessagePreviewModel.CustomerInfo.Cust_WorkNumber;
                } else {
                    return "";
                }
            }
            $scope.MessagePreviewModel.sendMessage = function() {
                if ($scope.MessagePreviewModel.MessageRec.SentTo == undefined || $scope.MessagePreviewModel.MessageRec.SentTo == null || $scope.MessagePreviewModel.MessageRec.SentTo == '') {
                    Notification.error($translate.instant('Select_number_to_send_message'));
                    $scope.MessagePreviewModel.disableSendTextBtn = false;
                    return;
                }
                CustomerMessagingServices.sendMessage($scope.MessagePreviewModel.MessageRec, angular.toJson($scope.MessagePreviewModel.SMSMessagePageSortAttrsJSON)).then(function(successResult) {
                    $scope.MessagePreviewModel.showSentBtn = true;
                    $("#text-now-btn").text('Sent');
                    if ($state.current.name === 'ViewCustomer.CustomerMessagingPopUp') {
                        $scope.$parent.ViewCustomer.SMSMessageList = successResult.MessageHistoryList;
                        $scope.$parent.ViewCustomer.TotalMessageRecords = successResult.TotalMessageRecords;
                    }
                }, function(errorMessage) {
                    $scope.MessagePreviewModel.disableSendTextBtn = false;
                    Notification.error(errorMessage);
                });
            }
            function handleEmailResponse(successResult) {
            	if (successResult == 'success') {
                    Notification.success(successResult);
                    $("#mail-now-btn").text('Sent');
                    $scope.MessagePreviewModel.showSentBtn = true;
                } else {
                    Notification.error(successResult);
                    $scope.MessagePreviewModel.showSentBtn = false;
                    $scope.MessagePreviewModel.disableSendTextBtn = false;
                }
            }
            
            $scope.MessagePreviewModel.emailAction = function(emailToUpdate){
                var accountToUpdate = {};
                accountToUpdate.Id = ($scope.MessagePreviewModel.IsEmailFromVendorOrder) ? $scope.MessagePreviewModel.VendorId : $scope.MessagePreviewModel.CustomerInfo.Cust_Id;
                accountToUpdate.Type = ($scope.MessagePreviewModel.IsEmailFromVendorOrder) ? 'Business' : $scope.MessagePreviewModel.CustomerInfo.Cust_Type;
                if($scope.MessagePreviewModel.IsPrimaryEmail) { 
                    accountToUpdate.PrimaryEmail = emailToUpdate.trim();
                    updateEmailAddress(accountToUpdate);
                } else if($scope.MessagePreviewModel.IsAlternateEmail) {
                    accountToUpdate.AlternateEmail = emailToUpdate.trim();
                    updateEmailAddress(accountToUpdate);
                }else {
                    $scope.MessagePreviewModel.sendEmail();
                }
            }

            function updateEmailAddress(accountToUpdate) {
                CustomerMessageAndEmailServices.updateEmail(angular.toJson(accountToUpdate)).then(function(successResult) {
                    $scope.MessagePreviewModel.sendEmail();
                }, function(errorMessage) {
                    Notification.error(errorMessage);
                });
            }

            $scope.MessagePreviewModel.sendEmail = function() {
                var emailAddress = '';
                var coHeaderId = null;
                var coInvoiceHeaderId = null;
                var dealId = null;
                var vendorOrderId = null;
                if ($scope.MessagePreviewModel.CustomerEmailAddress == '' || $scope.MessagePreviewModel.CustomerEmailAddress == undefined || $scope.MessagePreviewModel.CustomerEmailAddress == null) {
                    emailAddress = $scope.MessagePreviewModel.emailSearchObj.sentTo;
                } else {
                    emailAddress = $scope.MessagePreviewModel.CustomerEmailAddress;
                }
                if ($scope.MessagePreviewModel.CoInvoiceHeaderId != undefined) {
                    coInvoiceHeaderId = $scope.MessagePreviewModel.CoInvoiceHeaderId;
                }
                if ($scope.MessagePreviewModel.coHeaderId != undefined) {
                    coHeaderId = $scope.MessagePreviewModel.coHeaderId;
                }
                if ($scope.MessagePreviewModel.DealId != undefined) {
                    dealId = $scope.MessagePreviewModel.DealId;
                }
                if ($scope.MessagePreviewModel.VendorOrderId != undefined) {
                	vendorOrderId = $scope.MessagePreviewModel.VendorOrderId;
                }
                var documentList = [];
                if ($scope.MessagePreviewModel.SelectedDocuments != undefined) {
                    for (var i = 0; i < $scope.MessagePreviewModel.SelectedDocuments.length; i++) {
                    	if($scope.MessagePreviewModel.SelectedDocuments[i].includes('Attachment_Object')){
                    		var splitArr = $scope.MessagePreviewModel.SelectedDocuments[i].split('-');
                    		var documentObj = {
                    			DocumentName: 'AttachmentFile',
                    			AttachmentId: (splitArr.length > 0)? splitArr[1].trim() : ''
                    		} 
                    		documentList.push(documentObj);
                    	} else {
	                        var documentObj = {
	                            DocumentName: $scope.MessagePreviewModel.SelectedDocuments[i],
	                            COHeaderId: coHeaderId,
	                            COInvoiceId: coInvoiceHeaderId,
	                            DealId: dealId,
	                            VendorOrderId: vendorOrderId
	                        }
	                        documentList.push(documentObj);
                    	}
                    }
                }
                if (documentList.length > 0) {
                    if($scope.MessagePreviewModel.IsEmailFromVendorOrder) {
                		var subject = "Vendor Order - " + $scope.MessagePreviewModel.VendorOrderNumber;
                		vendorOrderService.emailSelectedDocument(angular.toJson(documentList), emailAddress, subject).then(function(successResult) {
                        	handleEmailResponse(successResult);
                        }, function(errorMessage) {
                            $scope.MessagePreviewModel.disableSendTextBtn = false;
                            Notification.error(errorMessage);
                        });
                	} else {
                		EmailInvoiceServices.emailSelectedDocument(angular.toJson(documentList), emailAddress).then(function(successResult) {
                        	handleEmailResponse(successResult);
                        }, function(errorMessage) {
                            $scope.MessagePreviewModel.disableSendTextBtn = false;
                            Notification.error(errorMessage);
                        });
                	}
                } else {
                	if($scope.MessagePreviewModel.customerApprovalId) {
                		CustomerMessageAndEmailServices.emailCustomerApproval($scope.MessagePreviewModel.customerApprovalId, emailAddress).then(function(successResult) {
                            handleEmailResponse(successResult);
                        }, function(errorMessage) {
                            $scope.MessagePreviewModel.disableSendTextBtn = false;
                            Notification.error(errorMessage);
                        });
                	} else {
                		EmailInvoiceServices.sendEmail(coInvoiceHeaderId, emailAddress).then(function(successResult) {
                			handleEmailResponse(successResult);
                        }, function(errorMessage) {
                            $scope.MessagePreviewModel.disableSendTextBtn = false;
                            Notification.error(errorMessage);
                        });
                	}
                }
            }
            if ($stateParams.messagingInfoParams != undefined && $stateParams.messagingInfoParams != '' && $stateParams.messagingInfoParams != null) {
                $scope.MessagePreviewModel.CustomerInfo = $stateParams.messagingInfoParams.CustomerInfo;
                $scope.MessagePreviewModel.CustomerName = $stateParams.messagingInfoParams.CustomerName;
                if ($stateParams.messagingInfoParams.customerInfo) {
                    $scope.MessagePreviewModel.CustomerInfo = $stateParams.messagingInfoParams.customerInfo;
                }
                if ($stateParams.messagingInfoParams.coHeaderId) {
                    $scope.MessagePreviewModel.coHeaderId = $stateParams.messagingInfoParams.coHeaderId;
                }
                if ($stateParams.messagingInfoParams.customerApprovalId) {
                	$scope.MessagePreviewModel.customerApprovalId = $stateParams.messagingInfoParams.customerApprovalId;
                }
                $scope.MessagePreviewModel.SelectedDocuments = $stateParams.messagingInfoParams.SelectedDocuments;
            }
            $scope.MessagePreviewModel.openPopup();
        }
    ]);
});