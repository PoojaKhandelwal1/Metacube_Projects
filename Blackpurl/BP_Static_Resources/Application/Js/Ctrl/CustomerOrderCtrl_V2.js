'use strict';
define(['Routing_AppJs_PK', 'AutoComplete_V2', 'CustomerOrderServices_V2', 'JqueryUI', 'NumberOnlyInput_New', 'underscore_min', 'COUInfoPopUpCtrl', 'AddDepositService', 'ModalDialog','StatusConfig', 'InfoCardComponent', 'FullPageModal', 'BPCarousel','CODocumentSection', 'ExportPdfService','CurrencyFilter', 'PartLocator', 'moment'], function(Routing_AppJs_PK, AutoComplete_V2, CustomerOrderServices_V2, JqueryUI, NumberOnlyInput_New, underscore_min, COUInfoPopUpCtrl, AddDepositService, ModalDialog, StatusConfig, InfoCardComponent, FullPageModal, BPCarousel, CODocumentSection, ExportPdfService,CurrencyFilter, PartLocator,moment) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('CustomerOrderCtrl_V2', ['$scope', '$q', '$rootScope', '$state', '$stateParams', 'SOHeaderService', 'CustomerService', 'CheckoutServices', 'AttachmentService', 'merchandiseService', '$compile', 'CustomerApprovalService', 'DealService', 'AddDepositService', 'SpecialOrderService', 'focusElement', 'UserService', '$translate', '$filter', 'UnitImagesService', 'documentService', 'internalCommentService', 'ExportPdfService', 'coAppointmentService', 'coCommonService','$cookies','$cookieStore','cashDrawerService', '$sce','BRPService', function($scope, $q, $rootScope, $state, $stateParams, SOHeaderService, CustomerService, CheckoutServices, AttachmentService, merchandiseService, $compile, CustomerApprovalService, DealService, AddDepositService, SpecialOrderService, focusElement, UserService, $translate, $filter, UnitImagesService, documentService, internalCommentService, ExportPdfService, coAppointmentService, coCommonService, $cookies, $cookieStore,cashDrawerService, $sce, BRPService) {
        var Notification = injector.get("Notification");
        $scope.M_CO = $scope.M_CO || {};
        $scope.F_CO = $scope.F_CO || {};
        $scope.M_CO.isShowDFSearchSection = false;
        $scope.M_CO.IsARIPartSmartEnabled = $Global.IsARIPartSmartEnabled;
        $scope.M_CO.expandedSectionName = '';
        $scope.M_CO.expandedDivFlag = false;
        $scope.M_CO.expandedDivId = '';
        $scope.M_CO.SOHeaderList = [];
        $scope.M_CO.editLineItem = '';
        $scope.M_CO.coHeaderRec = [];
        $scope.M_CO.coHeaderRec.MerchandiseTotal = 0;
        
        $scope.M_CO.isBlur = true;
        $scope.M_CO.COKHList = [];
        $scope.M_CO.expandedInnerSectionName = '';
        $scope.M_CO.expandedInnerDivFlag = false;
        $scope.M_CO.isAllInvoiceItemsSelected = false;
        $scope.M_CO.expandedInnerDivId = '';
        $scope.M_CO.IsLoadFinancingSection = false;
        $scope.CheckoutInfoModel = {};
        $scope.CheckoutInfoModel.invoiceItemList = [];
        $scope.CheckoutInfoModel.invoicePaymentList = [];
        $scope.CheckoutInfoModel.paymentReceived = 0.00;
        $scope.CheckoutInfoModel.activeInvHeaderId;
        $scope.M_CO.isCheckOutPartialSelect = false;
        $scope.M_CO.showCheckouttable = false;
        $scope.M_CO.IsShowMerchandiseSection = false;
        $scope.M_CO.showCheckOutLineItem = -1;
        $scope.M_CO.CashPaymentRoundingCentValue = $Global.Cash_Paymenmt_Rounding_Factor;
        $scope.M_CO.sellingGroup = 'Part Sale';
        var isPreventMerchSectionCreation = true;
        $scope.M_CO.dealTotalIncludingSalesTaxInDF = 0;
        $scope.M_CO.DummyAccordion = '';
        $scope.M_CO.Deal = {};
        $scope.F_CO.Deal = {};
        $scope.M_CO.DealFinance = {};
        $scope.M_CO.DealFinance.selectedCmpnyName = '';
        $scope.M_CO.DealFinance.FinanceCompanyList = [];
        $scope.M_CO.DealFinance.FIProductList = [];
        $scope.F_CO.DealFinance = {};
        $scope.M_CO.DealFinance.Status = '';
        $scope.M_CO.setBotrderOnSpan = '';
        $scope.M_CO.prevOpenedInvItemId = null;
        $scope.M_CO.TradeIn = $scope.M_CO.TradeIn || {};
        $scope.F_CO.TradeIn = $scope.F_CO.TradeIn || {};
        $scope.M_CO.TradeIn.showCOUList = false;
        $scope.M_CO.TradeIn.selectedUnitName = '';
        $scope.M_CO.TradeIn.IsCOUSelected = false;
        $scope.M_CO.TradeIn.AppraisalMethodList = ['Visual', 'Service'];
        $scope.M_CO.TradeIn.AppraisalStatusList = ['Pending appraisal', 'Appraisal complete'];
        $scope.M_CO.TradeIn.showAppraisalMethodList = false;
        $scope.M_CO.TradeIn.showAppraisalStatusList = false;
        $scope.M_CO.TradeIn.ApprovedList = [];
        $scope.M_CO.TradeIn.showApprovedList = false;
        $scope.M_CO.unreslovedList = $scope.M_CO.unreslovedList || {};
        $scope.M_CO.TradeIn.isUnitSelected = true;
        $scope.M_CO.expandedInner2SectionName = '';
        $scope.M_CO.expandedInner2DivFlag = false;
        $scope.M_CO.expandedInner2DivId = '';
        $scope.M_CO.TradeIn.removeIndex = -1;
        $scope.M_CO.TradeIn.removeItem = '';
        $scope.M_CO.ServiceJobAction = ['Log technician time', 'Add notes to customer', 'Finalize Job','Get customer approval','Submit claim','Claim response','View claim']; //'Add attachment',
        $scope.M_CO.ShowServiceJob = true;
        $scope.M_CO.serviceJobIndex = -1;
        $scope.M_CO.totalDeductibleAmount = 0;
        $scope.M_CO.isPrintInvoice = false;
        $scope.M_CO.isEmailInvoice = false;
        $scope.M_CO.dateFormat = $Global.DateFormat;
        $scope.M_CO.Deposit = {};
        $scope.F_CO.Deposit = {};
        $scope.M_CO.Deposit.TotalDepositAmout = 0;
        $scope.M_CO.hideCommitAndInstallBtn = false;
        $scope.M_CO.isSupressTrue = false;
        $scope.M_CO.FinalizeType = '';
        $scope.M_CO.ConfirmationModel = {};
        $scope.M_CO.toDisplayInput = [];
        $scope.M_CO.COUList = [];
        $scope.M_CO.showQuote = ($scope.M_CO.coHeaderRec.OrderStatus && $scope.M_CO.coHeaderRec.OrderStatus === 'Quote') ? true : false;
        $scope.M_CO.ActiveOrders = [];
        $scope.M_CO.isTabKeyPressed = false;
        $scope.M_CO.DealAction = ['Add_trade_in', 'Add_another_unit', 'Add_deal_financing', 'Commit_and_install_options'];
        $scope.M_CO.DealFinance.TermTypeArray = ['Years','Months'];
        $scope.M_CO.DealFinance.showTermTypeArray  = false;
        $scope.M_CO.DealFinance.PaymentFrequencyArray = ['Monthly','Semi-Monthly','Bi-Weekly','Weekly'];
        $scope.M_CO.DealFinance.showPaymentFrequencyArray  = false;
        $scope.M_CO.CustomerApproval = {};
        $scope.M_CO.CustomerApproval.isNoUnitSelectedForApproval = false;
        $scope.M_CO.CustomerApproval.UnitList = [];
        $scope.M_CO.CustomerApproval.soIdToCustomerApprovalListMap = {};
        $scope.M_CO.CustomerApproval.saveSoHeaderIndex ;
        $scope.M_CO.showSalesPersonList = false;
        $scope.M_CO.salesPersonList = [];
        $scope.M_CO.SalesPerson ={};
        $scope.M_CO.SalesPerson.TechnicianName = '';
        $scope.M_CO.isInternalCommentError = false;
        $scope.M_CO.BussinessProfileData = {};
        $scope.M_CO.showChangeModalWindow = false;
        $scope.M_CO.isTechSchedulingEnable =  $Global.IsLoadTechScheduling;
        $scope.M_CO.soAppointments = {};
        $scope.M_CO.PartLocator = {};
        $scope.M_CO.oldDescriptionValue = '';
        $scope.M_CO.isShowSaveBtnForIpad = false;
        var kitHeaderIndexForIpad = -1;
        var lineItemIndexForIpad = -1;
        var sectionTypeForIpad = '';
        var kitHeaderIndexForIpad = -1;
        var headerIndexForIpad = -1;
        $scope.M_CO.createNewCustomerOrderFromSkipButton = false;
        var PartNotFoundList = [];
        var isTimeOurForTheFirstTime = true;
        var duplicateListJson = {};
    $scope.TranslationModel = {
          'Label_Total': $translate.instant('Label_Total'),
          'DEPOSIT': $translate.instant('DEPOSIT'),
          'Reference_number': $translate.instant('Reference_number'),
          'Label_Date': $translate.instant('Label_Date'),
          'Payment_method': $translate.instant('Payment_method'),
          'Label_Amount': $translate.instant('Label_Amount'),
          'Deposit_on_a_deal': $translate.instant('Deposit_on_a_deal'),
          'refund': $translate.instant('refund'),
          'Add_Another': $translate.instant('Add_Another'),
          'Label_Invoice_History': $translate.instant('Label_Invoice_History'),
          'Invoice_Number': $translate.instant('Invoice_Number'),
          'Items': $translate.instant('Items'),
          'subtotal': $translate.instant('subtotal'),
          'Vendor_Invoicing_Taxes': $translate.instant('Vendor_Invoicing_Taxes'),
          'INVOICE_TOTAL': $translate.instant('INVOICE_TOTAL'),
          'TAXES_INCLUDED': $translate.instant('TAXES_INCLUDED')
        };
    $scope.M_CO.documents = {
            'forms': {
              'dealFinance': {},
                'deal': {},
                'so': {}
            },
            'attachments': {
              'dealFinance': {},
                'deal': {},
                'so': {}
            },
            'sectionIdWhereToAddDoc': '',
            'sectionNameWhereToAddDoc': '',
            'activeFormList': [],
            'attachmentJson': {},
            'sectionNameToActiveFormCountMap': {},
            'activeForms': {
              'dealFinance': {},
                'deal': {},
                'so': {}
            }
        }
      $scope.F_CO.showChangeCashDrawerModalWindow = function(isReversePayment) {
         if(isReversePayment) {
           $scope.M_CO.showReverseChangeModalWindow = true;
           angular.element(".delete-confirm-container").addClass("reverse-animation")
         } else {
           $scope.M_CO.showChangeModalWindow = true;
         }
        
          $scope.M_CO.cashDrawerName = $cookieStore.get($scope.M_CO.uuid);
           var index = _.findIndex($scope.M_CO.cashDrawerList, {
                "CashDrawerName": $scope.M_CO.cashDrawerName
            });
           $scope.M_CO.cashDrawerId = $scope.M_CO.cashDrawerList[index].Id;
      }
      $scope.M_CO.internalCommentList = [];
      $scope.M_CO.internalComment = {};
      $scope.M_CO.currentUserId = $Global.currentUserId;
      $scope.M_CO.applicableSalesTaxList = [];
      $scope.M_CO.currentDropDownIndex = -1;
      $scope.M_CO.showSalesTaxListDropdown = false;
      $scope.M_CO.showFinanceCompanyDropdown = false;
      $scope.M_CO.showTimeOutModalWindow = false;
      
        $scope.M_CO.transactionSelectedIndex = 0;
        $scope.M_CO.selectedTransactionTypeIndex = 0;
        $scope.M_CO.transactionType = [{
            label:'Commit and order',
            value : 'Parts will be committed as they are added and special orders will be automatically generated.'
        },
        {
            label:'Commit only',
            value : 'Parts will be committed without automatically generating special orders.'
        },
        {
            label:'Uncommitted',
            value : 'Parts won’t be commited and no special order will be automatically generated.'
        }
        ]
        $scope.M_CO.transactionTypelabel = [{
            label : "Part sale"
        }
        ]
        if($Global.CompanyLocale == 'Australia') {
            var obj = {}
            obj.label = "Layby"
            $scope.M_CO.transactionTypelabel.push(obj)
        } else {
            var obj = {}
            obj.label = "Layaway"
            $scope.M_CO.transactionTypelabel.push(obj)
        }
      
        /*Start: Attachment upload*/
        //Constants
       var allowedExtensions = [];
       var allowedFileTypesType;
       var maxStringSize;
       var maxFileSize;
       var maxFileSizeText;
       var chunkSize;
       var isBrowseFile = false;

       //Uploaded file instance
       $scope.FileUpload = {};
       $scope.FileUpload.attachment = '';
       $scope.FileUpload.attachmentName = '';
       $scope.FileUpload.fileSize = 0;
       $scope.FileUpload.positionIndex = 0;

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
        	$scope.M_CO.isLoading = true;
        	uploadAttachmentFile();
        } else {
        	Notification.error($translate.instant('Please_select_a_valid_file'));
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
                  var fileFormat = $scope.FileUpload.fileExtension ? $scope.FileUpload.fileExtension : file.type;
                  if(!file.type || file.type == "") {
                    fileFormat = (($scope.FileUpload.attachmentName.toLowerCase()).includes("csv")) ? 'text/csv' : 
                        ((($scope.FileUpload.attachmentName.toLowerCase()).includes("plain")) ? 'text/plain' : fileFormat);
                  }
                  if($scope.M_CO.isImportingPartSmart) {
                    $scope.F_CO.addItemsWithPartSmart($scope.M_CO.documents.sectionIdWhereToAddDoc, $scope.M_CO.documents.sectionNameWhereToAddDoc);
                    $scope.M_CO.isLoading = false;
                    $scope.F_CO.showPartSmartImportedContent(this.result, fileFormat);
                    return;
                  } else {
                    $scope.FileUpload.attachment = window.btoa(this.result); //Base 64 encode the file before sending it
                        $scope.FileUpload.positionIndex = 0;
                        $scope.FileUpload.fileSize = $scope.FileUpload.attachment.length;
                        $scope.FileUpload.doneUploading = false;
                        if ($scope.FileUpload.fileSize < maxStringSize) {
                            $scope.FileUpload.tempattachmentbody = $scope.FileUpload.attachment;
                            afterUploadAction();
                        } else {
                          $scope.M_CO.isLoading = false;
                        }
                  }
                   }
                   fileReader.onerror = function(e) {
                     $scope.M_CO.isLoading = false;
                   }
                   fileReader.onabort = function(e) {
                    afterUploadAction();
                   }
                   fileReader.readAsBinaryString(file); //Read the body of the file
               } else {
                 $scope.M_CO.isLoading = false;
                 $translate('File_size_should_be_less_than_parameterized_size',{ maxFileSize : maxFileSizeText}).then(function(success) {
                   Notification.error(success);
                 }, function(error) {
                   Notification.error($translate.instant('File_size_should_be_less_than_max_size'));
                 });
               }
           } else {
            afterUploadAction();
           }
       }
       
       $scope.F_CO.checkDatePickerVisible = function() {
           if(angular.element("#ui-datepicker-div").css("display") == 'block') {
               return true;
           } else {
               return false;
           }
       }
       function handleErrorAndExecption(error) {
         console.log(error + 'status' + error.status);
         if(error && isTimeOurForTheFirstTime && (error.includes('Unable to connect to the server') || error.includes('failure') || error.includes('timeout') || error.status == 400 || error.status == 404 || error.status == 500 
             || error.status == 503 || error.status == 504 || error.status == 502 || error.status == 403 ) ) {
           $scope.M_CO.showTimeOutModalWindow = true;
           isTimeOurForTheFirstTime = false;
         }
         $scope.M_CO.isLoading = false;
       }
       
       function afterUploadAction() {
          $scope.M_CO.isLoading = false;
          uploadAttachmentCallback();
       }

       function uploadAttachmentCallback() {
         $scope.M_CO.documents.attachmentJson.Name = $scope.FileUpload.attachmentName;
         $scope.M_CO.documents.attachmentJson.Description = '';
         $scope.M_CO.isLoading = false;
         openDocumentAttachmentModal();
         if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
               $scope.$apply();
           }
       }

       function openDocumentAttachmentModal() {
         setDefaultValidationModel();
         setTimeout(function() {
               angular.element('#attachment-modal-window').modal({
                   backdrop: 'static',
                   keyboard: false
               });
           }, 100);
       }

       angular.element(document).on("click", "#attachment-modal-window .modal-backdrop", function() {
         hideDocumentAttachmentModal();
       });

       function hideDocumentAttachmentModal() {
           angular.element('#attachment-modal-window').modal('hide');
           $scope.M_CO.documents.sectionIdWhereToAddDoc = '';
           $scope.M_CO.documents.sectionNameWhereToAddDoc = '';
           resetAttachmentModalData();
       }

       function resetAttachmentModalData() {
          allowedExtensions = [];
      maxStringSize = null; //Maximum String size is 6,000,000 characters
      maxFileSize = null; //After Base64 Encoding, this is the max file size (750 KB max)
      maxFileSizeText = '';
      chunkSize = null; //Maximum Javascript Remoting message size is 1,000,000 characters
      allowedFileTypesType = null;
      $scope.M_CO.documents.attachmentJson = {};
       }

       function setDefaultValidationModel() {
           $scope.M_CO.attachmentValidationModal = {
           Name: {
                   isError: false,
                   ErrorMessage: '',
                   Type: 'Required'
               },
               Description: {
                   isError: false,
                   ErrorMessage: '',
                   Type: 'Required',
                   Maxlength: 50
               }
          };
       }

       $scope.F_CO.validateAttachmentModalData = function() {
         angular.forEach($scope.M_CO.attachmentValidationModal, function(value, key) {
           validateFieldWithKey(key);
           });
         /*if(!$scope.M_CO.documents.attachmentJson.Name || !$scope.M_CO.documents.attachmentJson.Description) {
           return false;
         }
         return true;*/
       }

        $scope.F_CO.openModalWindow = function() {
           $scope.M_CO.isLoading = true;
          getprofitabilitydata();
      }
      function getprofitabilitydata() {
        documentService.getCOProfitability($scope.M_CO.COHeaderId).then(function(result) {
                $scope.M_CO.profitabilityListWrapper = result;

                $scope.M_CO.profitabilityList = result.SectionProfitabilityList;
                openprofitabilityModalWindow();

                   $scope.M_CO.isLoading = false;
            }, function(error) {
                handleErrorAndExecption(error);
            });
      }

       function openprofitabilityModalWindow() {
         setDefaultValidationModel();
           setTimeout(function() {
               angular.element('#profitability-modal-window').modal({
                   backdrop: 'static',
                   keyboard: false
               });
      $(".table-container").scrollTop(0);
           }, 100);

       }

       function validateFieldWithKey(modelKey) {
           var fieldValue = $scope.M_CO.documents.attachmentJson[modelKey];
           var validateType = $scope.M_CO.attachmentValidationModal[modelKey].Type;
           var isError = false;
           var ErrorMessage = '';
           if (validateType.indexOf('Required') > -1) {
               if (fieldValue == undefined || fieldValue == null || fieldValue == '') {
                   isError = true;
                   ErrorMessage = $translate.instant('Field_Is_Required');
               }
           }
           $scope.M_CO.attachmentValidationModal[modelKey].isError = isError;
           $scope.M_CO.attachmentValidationModal[modelKey].ErrorMessage = ErrorMessage;
           if ($scope.M_CO.attachmentValidationModal[modelKey].isError == true) {
               $scope.M_CO.isValidForm = false;
           }
       }

       $scope.F_CO.addAttachmentToSection = function() {
         $scope.M_CO.isValidForm = true;
         $scope.F_CO.validateAttachmentModalData();
         if(!$scope.M_CO.isValidForm) {
           return;
         }
         $scope.M_CO.documents.attachmentJson.ParentId = $scope.M_CO.documents.sectionIdWhereToAddDoc;
          $scope.M_CO.isLoading = true;
          documentService.addAttachment(angular.toJson($scope.M_CO.documents.attachmentJson), $scope.FileUpload.tempattachmentbody).then(function() {
            getCOAttachmentsBySectionId($scope.M_CO.documents.sectionIdWhereToAddDoc).then(function(attachmentList) {
              bindAttachmentsAfterAddAction($scope.M_CO.documents.sectionIdWhereToAddDoc, $scope.M_CO.documents.sectionNameWhereToAddDoc, attachmentList);
              hideDocumentAttachmentModal();
              $scope.M_CO.isLoading = false;
                }, function(error) {
                  handleErrorAndExecption(error);
                });
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
            });
       }

       function bindAttachmentsAfterAddAction(sectionId, sectionName, attachmentList) {
          $scope.M_CO.documents.attachments[sectionName][sectionId] = attachmentList[sectionId];
          showTooltip('body');
       }

       $scope.F_CO.setAttachmentData = function(sectionId, sectionName) {
    	   allowedExtensions = ['png', 'jpg', 'bmp', 'gif', 'txt', 'pdf', 'svg', 'torrent', 'jpeg'];
      maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
      maxFileSize = 750000; //After Base64 Encoding, this is the max file size (750 KB max)
      maxFileSizeText = $translate.instant('750_KB');
      chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
      allowedFileTypesType = /^(?:image\/jpeg|image\/jpg|image\/png|image\/gif|image\/svg|image\/bmp|application\/pdf|text\/plain)$/i;
      $scope.M_CO.documents.sectionIdWhereToAddDoc = sectionId;
          $scope.M_CO.documents.sectionNameWhereToAddDoc = sectionName;
          $scope.PartSmart.IsPartSmartActive = false;
          $scope.M_CO.isImportingPartSmart = false;
       }
       /*End: Attachment upload*/

        $scope.F_CO.setPartSmartFileReadData = function(sectionId, sectionName) {
          allowedExtensions = ['txt', 'csv'];
          maxStringSize = 6000000; //Maximum String size is 6,000,000 characters
          maxFileSize = 750000; //After Base64 Encoding, this is the max file size (750 KB max)
          maxFileSizeText = $translate.instant('750_KB');
          chunkSize = 950000; //Maximum Javascript Remoting message size is 1,000,000 characters
          $scope.M_CO.documents.sectionIdWhereToAddDoc = sectionId;
            $scope.M_CO.documents.sectionNameWhereToAddDoc = sectionName;
            $scope.M_CO.isImportingPartSmart = true;
        }
       
        $scope.M_CO.dealOptionsAndFeesStatusMap = {'Required' : ['Options have not been committed to the deal.',' Commit and install options'],
            'Pending' : ['Options have been committed and ordered.','Await fulfillment'],
            'Fulfilled' : ['All Options have been fulfilled for the deal.','Ready to deliver/invoice']};

        $scope.M_CO.Deposit.PaymentMethod = [{
            'MethodName': 'Cash'
        }, {
            'MethodName': 'Debit'
        }, {
            'MethodName': 'Visa'
        }, {
            'MethodName': 'MasterCard'
        }, {
            'MethodName': 'Amex'
        }, {
            'MethodName': 'Cheque'
        }, {
            'MethodName': 'Gift Card'
        }, {
            'MethodName': 'Direct Deposit'
        }];
        $scope.M_CO.Deposit.deposit_Amount;
        $scope.M_CO.Deposit.paymentMethod;
        $scope.M_CO.Deposit.selectPaymentMethodName;
        $scope.M_CO.Deposit.reverse_Link = '';
        $scope.M_CO.Deposit.refundFlag = false;
        
        setPaymentDates();
        $scope.M_CO.todayDate;
        function setPaymentDates() {
        	$scope.M_CO.todayDate = getDateStringWithFormat(new Date(), $scope.M_CO.dateFormat);
        	$scope.CheckoutInfoModel.tempPaymentDate = $scope.CheckoutInfoModel.paymentDate = 
        			$scope.M_CO.tempInvoicePaymentDate = $scope.CheckoutInfoModel.invoicePaymentDate = 
        				$scope.M_CO.Deposit.tempPaymentDate = $scope.M_CO.Deposit.paymentDate = $scope.M_CO.todayDate;
        	
        }

        $scope.PartSmart = {};

        function addPartsSmartItems() {
          $scope.M_CO.isLoading = true;
          if(!$scope.M_CO.coHeaderRec.CustomerId && $scope.PartSmart.SectionName === 'Merchandise') {
            $scope.PartSmart.SectionName = 'Cash Sale';
          }
          $scope.PartSmart.SectionId = ($scope.PartSmart.SectionId ? $scope.PartSmart.SectionId : ($scope.M_CO.COHeaderId ? $scope.M_CO.COHeaderId : null));
          merchandiseService.addPartsSmartItems(angular.toJson($scope.PartSmart.PartsToAdd), $scope.PartSmart.SectionName, $scope.PartSmart.SectionId).then(function(response) {
            $scope.PartSmart.PartsToAdd = [];
            if(response) {
              PartNotFoundList = (response['Parts not found']) ? response['Parts not found'] : [];
              $scope.PartSmart.OutOfStockParts = (response['Out of stock parts']) ? response['Out of stock parts'] : [];
              $scope.PartSmart.InStockPartList = (response['In stock parts']) ? response['In stock parts'] : [];
            }
            if($scope.PartSmart.SectionName === 'Cash Sale') {
              handleCashSaleScenariosForPartsmart();
            } else if($scope.PartSmart.SectionName === 'Service Job' || $scope.PartSmart.SectionName === 'Deal Service Job') {
              $scope.F_CO.callGetSOHeaderDetails({'isDealCallback' : (($scope.PartSmart.SectionName === 'Deal Service Job') ? true : false)});
            } else if($scope.PartSmart.SectionName === 'Deal' || $scope.PartSmart.SectionName === 'Deal Merchandise') {
              getUnitDealDetails({'gridName': null});
            } else {
              getCOHeaderDetails();
            }
            $scope.PartSmart.SectionName = null;
            $scope.PartSmart.SectionId = null;
            }, function(error) {
              handleErrorAndExecption(error);
              Notification.error($translate.instant('GENERIC_ERROR'));
            });
        };

        var handleCashSaleScenariosForPartsmart = function() {
          if($scope.PartSmart.OutOfStockParts.length) {
            if(!$scope.M_CO.coHeaderRec.CustomerId) {
              $scope.M_CO.recentlyAddedLineItem = [];
              for(var i = 0; i < $scope.PartSmart.OutOfStockParts.length; i++) {
                $scope.M_CO.recentlyAddedLineItem.push({
                  Qty: $scope.PartSmart.OutOfStockParts[i].Qty,
                          PartId: $scope.PartSmart.OutOfStockParts[i].PartId,
                          Price: $scope.PartSmart.OutOfStockParts[i].Price,
                          AvailableQty: $scope.PartSmart.OutOfStockParts[i].AvailableParts,
                          Item: $scope.PartSmart.OutOfStockParts[i].Item,
                });
              }
              $scope.PartSmart.IsAddingFromPartSmart = true;
                $scope.M_CO.IsNewLineItemInserted = true;
                $scope.M_CO.isOutOfStockPart = true;
                $scope.F_CO.showOversoldPopup();
                return;
              }
          } else if($scope.PartSmart.InStockPartList.length) {
            var itemList = [];
            for(var i = 0; i < $scope.PartSmart.InStockPartList.length; i++) {
              itemList.push({
              Qty: $scope.PartSmart.InStockPartList[i].Qty,
                      PartId: $scope.PartSmart.InStockPartList[i].PartId,
                      Price: $scope.PartSmart.InStockPartList[i].Price,
                      QtyCommitted: $scope.PartSmart.InStockPartList[i].Qty,
            });
          }
            $scope.PartSmart.IsAddingFromPartSmart = true;
            addPartSmartItemsInCashSale(itemList);
          } else if(PartNotFoundList) {
            showPartsSmartItemsNotInserted();
          }
        }

        function addPartSmartItemsInCashSale(itemList) {
          var successJson = {
                'type': 'addCOLineItem',
                'isAddMode': true
            };
        if(!$scope.M_CO.COHeaderId) {
          $scope.M_CO.COHeaderId = null
        }
        merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(itemList), null).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.addItemsWithPartSmart = function(sectionName, sectionId) {
          $scope.PartSmart = {"PartsToAdd" : [], "IsPartSmartActive" : true ,"IsAddingFromPartSmart" : false, "SectionName" : sectionName, "SectionId" : sectionId, "PartNotFoundList" : [], "OutOfStockParts" : [], "InStockPartList" : []};
        }

       function showPartsSmartItemsNotInserted () {
          if(PartNotFoundList && PartNotFoundList.length) {
            $scope.M_CO.isLoading = false;
            $scope.F_CO.openConfirmationDialog('PartSmart', false, false, false, false, PartNotFoundList);
            PartNotFoundList = [];
          }
        }

       function textToJson(partsmartContentStr) {
            var contentArray = partsmartContentStr.split("\n");
          var partObj;
          for(var i = 0; i < contentArray.length; i++) {
            var x = contentArray[i];
              if(x.length > 0) {
                var arr = x.split(' ');
                arr[0] = x.substring(0, 2).trim();
                  arr[1] = x.substring(2, x.length).trim();
                  if(arr[0] === "hS" && arr[1] !== "S") {
                    $scope.PartSmart.PartsToAdd = [];
                    $scope.M_CO.isLoading = false;
                    return;
                  } else {
                    if(arr[0] === "DH") {
                      if(partObj && partObj["Manufacturer"] && partObj["PartNumber"] && partObj["Qty"]) {
                        partObj["DealId"] = ($scope.PartSmart.SectionName == 'Deal Merchandise' || $scope.PartSmart.SectionName == 'Deal' ?
                            $scope.M_CO.Deal.DealInfo.Id : null);
                        $scope.PartSmart.PartsToAdd.push(partObj);
                      }
                      partObj = {};
                    } else {
                      if(arr[0] === "dM") {
                        partObj["Manufacturer"] = arr[1];
                        } else if(arr[0] === "dP") {
                          partObj["PartNumber"] = arr[1];
                        } else if(arr[0] === "dQ") {
                          partObj["Qty"] = (arr[1] ? parseFloat(arr[1]) : 0);
                        }
                    }
                  }
              }
          }
            if(partObj && partObj["Manufacturer"] && partObj["PartNumber"] && partObj["Qty"]) {
          partObj["DealId"] = ($scope.PartSmart.SectionName == 'Deal Merchandise' || $scope.PartSmart.SectionName == 'Deal' ?
            $scope.M_CO.Deal.DealInfo.Id : null);
          $scope.PartSmart.PartsToAdd.push(partObj);
            }
       }

       $scope.F_CO.showPartSmartImportedContent = function(partsmartContentStr, fileType) {
          $scope.M_CO.isLoading = true;
          if(fileType && (fileType.toLowerCase()).includes("csv")) {
            var fileKeyToObjKeyMap = {"Catalog" : "Manufacturer", "Part Number" : "PartNumber", "Quantity" : "Qty"};
            $scope.PartSmart.PartsToAdd = partsmartCSVToJson(partsmartContentStr, fileKeyToObjKeyMap, 'Vendor Order');
          } else if(fileType && ((fileType.toLowerCase()).includes('txt') || (fileType.toLowerCase()).includes('text/plain'))) {
            textToJson(partsmartContentStr);
          } else {    //fileType && fileType == 'text/xml'
            Notification.error($translate.instant('This_file_format_is_not_supported'));
            $scope.M_CO.isLoading = false;
            return;
          }
            $scope.PartSmart.IsPartSmartActive = false;
            if($scope.PartSmart.PartsToAdd.length) {
              addPartsSmartItems();
            } else {
              $scope.M_CO.isLoading = false;
              Notification.error($translate.instant('Invalid_part_file_format_error_message'));
            }
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') { // to apply loading variable change
              $scope.$apply();
          }
        }

        $scope.F_CO.refundDepositAmount = function() {
        
            $scope.M_CO.Deposit.refundFlag = true;
            $scope.M_CO.Deposit.isReverseDeposit = true;
            if ($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id && $scope.M_CO.Deposit.TotalDealDepositAmount > 0) {
                $scope.M_CO.Deposit.depositType = 'Deal';
                $scope.M_CO.Deposit.deposit_Amount = $scope.M_CO.Deposit.TotalDealDepositAmount;
            } else if ($scope.M_CO.Deposit.TotalCustomerDepositAmount > 0) {
                $scope.M_CO.Deposit.depositType = 'Customer';
                $scope.M_CO.Deposit.deposit_Amount = $scope.M_CO.Deposit.TotalCustomerDepositAmount;
            }
            var Storeindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
             'MethodName': 'Store Credit',
         });
       	if(Storeindex > -1) {
    		$scope.M_CO.Deposit.PaymentMethod.splice(Storeindex,1);
    	 }
       	var Storeindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
            'MethodName': 'Store Credit',
        });
       	if( Storeindex == -1 && ($scope.M_CO.Deposit.refundFlag || !$scope.M_CO.Deposit.refundFlag && $scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.CustomerStoreCredit > 0)) {
        	var obj = {}
        	obj.MethodName = 'Store Credit'
    		$scope.M_CO.Deposit.PaymentMethod.push(obj);
        }
    	 var Financedindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
             'MethodName': 'Financed',
         });
    	 
    	 if(Financedindex > -1) {
     		$scope.M_CO.Deposit.PaymentMethod.splice(Financedindex,1);
     	 }
    	 
    	 var Financedindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
             'MethodName': 'Financed',
         });
    	 if(Financedindex == -1 && $scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType == 'Financed' && $scope.M_CO.Deposit.depositType == 'Deal') {
        	var obj = {}
        	obj.MethodName = 'Financed'
        	$scope.M_CO.Deposit.PaymentMethod.push(obj);
        }
            angular.element('#AddDepositPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#AddDepositPopup').show();
            setTimeout(function() {
                angular.element("#depositAmount").select();
            }, 500);
        }
        $scope.M_CO.deliveryDate = {
            minDate: new Date,
            dateFormat: $scope.M_CO.dateFormat,
            showOtherMonths: true,
            selectOtherMonths: true,
            dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
        };
        
        $scope.M_CO.paymentDateErroMsg;
        $scope.M_CO.ishowPaymentDatePicker = false;
        $scope.M_CO.ishowInvoiceDatePicker = false;
        $scope.M_CO.ishowDepositDatePicker = false;
        $scope.F_CO.animateFunction = function(event, id) {
    		if(id == 'invoiceDatePicker') {
            	$("#checkout-modal").animate({scrollTop: 400}, "slow");
        	}
        	if(id == 'depositDatepickerDiv') {
            	$("#AddDepositPopup").animate({scrollTop: 400}, "slow");
        	}
        }
        $scope.M_CO.paymentDate = {
                dateFormat: $scope.M_CO.dateFormat.replace('/', '-').replace('/', '-'),
                showOtherMonths: true,
                inline: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S'] ,
                onSelect: function() {
                	$('#paymentDate').data('datepicker').inline = true;
                	$scope.M_CO.paymentDateErroMsg = '';
                	$.datepicker._defaults.paymentDatePickerDivClicked = false;
                	angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                },
                onClose: function() {
                	$scope.CheckoutInfoModel.tempPaymentDate = $scope.CheckoutInfoModel.paymentDate;
                	$scope.M_CO.paymentDateErroMsg = '';
                	$('#paymentDate').data('datepicker').inline = false;
                	$scope.M_CO.ishowPaymentDatePicker = false;
                	$.datepicker._defaults.paymentDatePickerDivClicked = false;
                	angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                }
            };
            
            $scope.M_CO.invoicepaymentDate = {
                dateFormat: $scope.M_CO.dateFormat.replace('/', '-').replace('/', '-'),
                showOtherMonths: true,
                inline: true,
                selectOtherMonths: true,
                dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S'] ,
                onSelect: function() {
                	$('#invoicepaymentDate').data('datepicker').inline = true;
                	$scope.M_CO.paymentDateErroMsg = '';
                	$.datepicker._defaults.paymentDatePickerDivClicked = false;
                	angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                },
                onClose: function() {
                	$('#invoicepaymentDate').data('datepicker').inline = false;
                	$scope.M_CO.tempInvoicePaymentDate = $scope.CheckoutInfoModel.invoicePaymentDate;
                	$scope.M_CO.paymentDateErroMsg = '';
                	$scope.M_CO.ishowInvoiceDatePicker = false;
                	$.datepicker._defaults.paymentDatePickerDivClicked = false;
                	angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
            	}
            };
            
            $scope.M_CO.depositPaymentDate = {
                    dateFormat: $scope.M_CO.dateFormat.replace('/', '-').replace('/', '-'),
                    showOtherMonths: true,
                    inline: true,
                    selectOtherMonths: true,
                    dayNamesMin: ['S', 'M', 'T', 'W', 'T', 'F', 'S'] ,
                    onSelect: function() {
                        $('#depositPaymentDate').data('datepicker').inline = true;
                        $scope.M_CO.paymentDateErroMsg = '';
                        $.datepicker._defaults.paymentDatePickerDivClicked = false;
                        angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                    },
                    onClose: function() {
                        $('#depositPaymentDate').data('datepicker').inline = false;
                        $scope.M_CO.Deposit.tempPaymentDate = $scope.M_CO.Deposit.paymentDate;
                        $scope.M_CO.paymentDateErroMsg = '';
                        $scope.M_CO.ishowDepositDatePicker = false;
                        angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                    }
                };
        
        $scope.F_CO.stopHideDatePicker = function() {
        	$.datepicker._defaults.paymentDatePickerDivClicked = true;
        }
        $scope.F_CO.showDatePickerActionBut = function(appendElementTo, containerIdOfButtonSection, datePickerId, animateClass, event) {
        	angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
        	$("#BtnMsgcontainer").remove();    
        	$("#calHeader").remove();
        	var footerTemplate ='<footer id="BtnMsgcontainer">' +
        				  		'<div id="' + containerIdOfButtonSection + '" class="payment-date-but-container section-container"> ' +
				                    '<button class="link-subtle H300" ng-click="F_CO.cancelBackDatingAction(\'' + datePickerId + '\')">Cancel</button>' + 
				                    '<button class="secondary medium" ng-click="F_CO.confirmBackDatingAction(\'' + datePickerId + '\')">Confirm</button>' +
				                '</div>' + 
			                '</footer>';
        		footerTemplate = $compile(angular.element(footerTemplate))($scope);
                var element = angular.element("#ui-datepicker-div").append(footerTemplate);
                element.css("left","auto");
                element.css("top","auto");
                $("#" + appendElementTo).append(element);
                if($scope.M_CO.paymentDateErroMsg && $scope.M_CO.paymentDateErroMsg.length) {
                	handleErrorMsgForPayment($scope.M_CO.paymentDateErroMsg);
                	angular.element(".ui-state-default.ui-state-active").addClass("is-error");
                }
                if(appendElementTo == 'paymentDateContainer') {
                    $("#checkout-modal").animate({scrollTop: 300}, "slow");
                }
                if(appendElementTo == 'invoicePaymentDateContainer') {
                	$("#checkout-modal").animate({scrollTop: 750}, "slow");
                }
                if(appendElementTo == 'depositPaymentDateContainer') {
                	$("#AddDepositPopup").animate({scrollTop: 550}, "slow");
                }
        }
        
        $scope.F_CO.confirmBackDatingAction = function(elementId) {
        	$scope.M_CO.isLoading = true;
        	$("#erroMsg").remove();    
        	switch(elementId) {
	            case 'paymentDate':
	            	confirmPaymentBackdatingAction(elementId);
	                break;
	            case 'depositPaymentDate':
	            	confirmPaymentBackdatingAction(elementId);
	                break;
	            case 'invoicepaymentDate':
	            	confirmInvoiceBackdatingAction(elementId);
	                break;
	        }
        }
        function validateFutureDate(selectedDate) {
        	if(moment(selectedDate, $Global.SchedulingDateFormat) > moment($scope.M_CO.todayDate, $Global.SchedulingDateFormat)) {
        		var errorMsg = 'Cannot select a date in the future.';
        		handleErrorMsgForPayment(errorMsg);
                angular.element(".ui-state-default.ui-state-active").addClass("is-error");
                $scope.M_CO.isLoading = false;
        		return true;
        	} 
        	return false;
        }
        function confirmPaymentBackdatingAction(elementId) {
        	var paymentDt;
        	if(elementId == 'paymentDate') {
        		paymentDt = $scope.CheckoutInfoModel.tempPaymentDate;
			} else if(elementId == 'depositPaymentDate') {
				paymentDt = $scope.M_CO.Deposit.tempPaymentDate;
			}
        	if(validateFutureDate(paymentDt)) {
        		return;
        	}
        	CheckoutServices.validatePaymentDate(paymentDt).then(function(response) {
        		if(response.responseCode == 200) {
        			if(elementId == 'paymentDate') {
        				$scope.CheckoutInfoModel.paymentDate = $scope.CheckoutInfoModel.tempPaymentDate;
        				$scope.M_CO.ishowPaymentDatePicker = false;
        			} else if(elementId == 'depositPaymentDate') {
        				$scope.M_CO.Deposit.paymentDate = $scope.M_CO.Deposit.tempPaymentDate;
        				$scope.M_CO.ishowDepositDatePicker = false;
        			}
                    $scope.M_CO.paymentDateErroMsg = '';
                    $('#' + elementId).datepicker("hide");
        		} else {
	                handleErrorMsgForPayment(response.response);
	                angular.element(".ui-state-default.ui-state-active").addClass("is-error");
        		}
        		$scope.M_CO.isLoading = false;
            }).catch(function(error) {
              handleErrorAndExecption(error);
            });
        }
        
        function confirmInvoiceBackdatingAction(elementId) {
        	if(validateFutureDate($scope.M_CO.tempInvoicePaymentDate)) {
        		return;
        	}
        	var selectedJson = [];
        	for(var i=0; i< $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
        		if($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive) {
        			selectedJson.push($scope.CheckoutInfoModel.InvoiceItemList[i].COInvoiceItemId);
        		}
        	}
        	var requestParmJson = {
        			"InvoiceId" : $scope.M_CO.coHeaderRec.ActiveInvoiceId,
        			"COHeaderId" : $scope.M_CO.coHeaderRec.COHeaderId,
        			"SelectedInvoiceDate" : $scope.M_CO.tempInvoicePaymentDate,
        			"SelectInvoiceItemList" : selectedJson
        	};
        	CheckoutServices.validateInvoiceDateOnCheckout(JSON.stringify(requestParmJson)).then(function(response) {
        		if(response.responseCode == 200) {
        			$scope.CheckoutInfoModel.invoicePaymentDate = $scope.M_CO.tempInvoicePaymentDate;
        			$scope.M_CO.paymentDateErroMsg = '';
        			$scope.M_CO.ishowInvoiceDatePicker = false;
        			$('#' + elementId).datepicker("hide");
        		} else {
	                handleErrorMsgForPayment(response.response);
	                angular.element(".ui-state-default.ui-state-active").addClass("is-error");
        		}
        		$scope.M_CO.isLoading = false;
            }).catch(function(error) {
              handleErrorAndExecption(error);
            });
        }
        
        function handleErrorMsgForPayment(errorMsg) {
        	$scope.M_CO.paymentDateErroMsg = errorMsg;
        	var template = $compile(angular.element(getTemplateForErrorMsg($scope.M_CO.paymentDateErroMsg)))($scope);
            $("#BtnMsgcontainer").prepend(template);
        }
        
        function getTemplateForErrorMsg(ErrorMsg) {
        	var template = '<div id="erroMsg" class="payment-date-but-container section-container"> ' +
        						'<span class="bp-red-font text-left">' + ErrorMsg +'</span>' + 
					        '</div>';
        	return template;
        }
        
        $scope.F_CO.cancelBackDatingAction = function(elementId) {
        	$scope.M_CO.paymentDateErroMsg = '';
        	switch(elementId) {
	        	case 'depositPaymentDate':
	                $scope.M_CO.ishowDepositDatePicker = false;
	        		$scope.M_CO.Deposit.tempPaymentDate = $scope.M_CO.Deposit.paymentDate;
	                break;
        		case 'paymentDate':
        			$scope.M_CO.ishowPaymentDatePicker = false;
	            	$scope.CheckoutInfoModel.tempPaymentDate = $scope.CheckoutInfoModel.paymentDate;
	                break;
	            case 'invoicepaymentDate':
	            	$scope.M_CO.ishowInvoiceDatePicker = false;
	            	$scope.M_CO.tempInvoicePaymentDate = $scope.CheckoutInfoModel.invoicePaymentDate;
	                break;
        	}
        	$('#' + elementId).datepicker("hide");
        }
        
        angular.element(document).on("click", "#checkout-modal", function(event) {
        	if(($(event.target).closest("div").attr("Id") != "datepickerDiv" && $(event.target).closest("div").attr("Id") != "paymentDateContainer" && $(event.target).closest("div").attr("Id") != "confirmPayemntDateButtonContainer") 
    				&& ($(event.target).closest("div").attr("Id") != "invoiceDatePicker" && $(event.target).closest("div").attr("Id") != "invoicePaymentDateContainer" && $(event.target).closest("div").attr("Id") != "invoicePayemntDateButtonContainer")
    				&& ($(event.target).closest("div").attr("Id") != "depositDatepickerDiv" && $(event.target).closest("div").attr("Id") != "depositPaymentDateContainer"  && $(event.target).closest("div").attr("Id") != "depositPaymentDateButtonContainer")
    				&& $(event.target).closest("div").attr("Id") != "erroMsg" 
					&& $(event.target).closest("div").attr("Id") != "ui-datepicker-div" 
					&& $(event.target).closest("span").attr("class") != "ui-datepicker-month" 
					&& $(event.target).closest("div").attr("class") != 'ui-datepicker-title'
					&& !($(event.target).closest("div").attr("class") && $(event.target).closest("div").attr("class").includes('ui-datepicker-header'))) {
        		$.datepicker._defaults.paymentDatePickerDivClicked = false;
        		$scope.M_CO.ishowPaymentDatePicker = false;
                $scope.M_CO.ishowInvoiceDatePicker = false;
                $scope.M_CO.ishowDepositDatePicker = false;
                $('#paymentDate').datepicker("hide");
                $('#depositPaymentDate').datepicker("hide");
                $('#invoicepaymentDate').datepicker("hide");
                angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
                return;
        	}
        	if($(event.target).closest("div").attr("Id") == "invoicePaymentDateContainer") {
        		$scope.M_CO.ishowPaymentDatePicker = false;
    			$('#paymentDate').datepicker("hide");
        	}
        	
        	if($(event.target).closest("div").attr("Id") == "paymentDateContainer") {
        		$scope.M_CO.ishowInvoiceDatePicker = false;
        		$('#invoicepaymentDate').datepicker("hide");
        	}
        	
        });
        
        angular.element(document).on("click", "#AddDepositPopup", function(event) {
        	if(($(event.target).closest("div").attr("Id") != "depositDatepickerDiv" && $(event.target).closest("div").attr("Id") != "depositPaymentDateContainer"  && $(event.target).closest("div").attr("Id") != "depositPaymentDateButtonContainer")
    				&& $(event.target).closest("div").attr("Id") != "erroMsg" && $(event.target).closest("div").attr("Id") != "ui-datepicker-div" && $(event.target).closest("span").attr("class") != "ui-datepicker-month") {
        		$.datepicker._defaults.paymentDatePickerDivClicked = false;
                $scope.M_CO.ishowDepositDatePicker = false;
                $('#depositPaymentDate').datepicker("hide");
                angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
        	}
        });
       /* if($rootScope.GroupOnlyPermissions['Backdating']['enabled']) {
        	$scope.M_CO.paymentDate.showOn =  "button";
        	$scope.M_CO.paymentDate.buttonText = "Select Date";
        }*/
        
       /* $("#ui-datepicker-div").on("click", function(){
        	$('#ui-datepicker-div').prepend('<p class="date-picker-header-text">Change invoice date</p>');
        });*/
        $scope.M_CO.AccordionBGColorMap = {
            'Service Job': 'bp-cyan',
            'Unit Deal': 'bp-purple'
        };
        $scope.M_CO.ChevronContainerBGColorMap = {
            'Service Job': 'bp-cyan-dark',
            'Unit Deal': 'bp-purple-dark'
        };
        $scope.M_CO.showCalander = function(elementId) {
            angular.element("#" + elementId).focus();
        };

        $scope.M_CO.DealUnitStatusMap = {};
        $scope.M_CO.DealUnitStatusMap['Temporary'] = 'Cannot commit, contains temporary units';
        $scope.M_CO.DealUnitStatusMap['Uncommitted'] = 'Units have not been committed to this deal';
        $scope.M_CO.DealUnitStatusMap['Committed'] = 'Inventory units have been reserved for this deal';
        $scope.M_CO.DealUnitStatusMap['Delivered'] = 'Units have been delivered to the customer';
        $scope.M_CO.DealUnresolvedFulfillmentMap = {};
        $scope.M_CO.DealUnresolvedFulfillmentMap['Added'] = 'Item was added';
        $scope.M_CO.DealUnresolvedFulfillmentMap['Updated'] = 'Qty was changed';
        $scope.M_CO.DealUnresolvedFulfillmentMap['Removed'] = 'Item was removed';
        var maxPayment = 999999.99;
        $scope.CheckoutInfoModel.amountPaying = null;
        $scope.M_CO.isLoading = true;
        $scope.M_CO.isCompleteLoad = false;
        $scope.M_CO.selectedSOHeaderIndex;
        $scope.M_CO.changeStatusList = ["New", "Ready", "In Progress", "On Hold", "Complete"];
        $scope.M_CO.changeStatusCssConfig = {
            "New": "newStatus bp-purple-light",
            "Ready": "readyStatus bp-cyan-light",
            "Complete": "completeStatus bp-yellow-light",
            "On Hold": "onholdStatus bp-on-hold",
            "In Progress": "bp-orange-light bp-orange-dark-font",
            "Invoiced": "invoicedStatus bp-green-light",
            "Re-open for work": "reOpenStatus bp-red-font",
            "Estimate": "bp-purple-light newStatus"
        };
        $scope.M_CO.changeDFStatusList = ["Quotation", "Submitted", "Approved"];
        $scope.M_CO.changeDFStatusCssConfig = {
            "Quotation": "newStatus bp-purple-light",
            "Submitted": "completeStatus bp-yellow-light",
            "Approved": "readyStatus bp-cyan-light",
            "Paid": "invoicedStatus bp-green-light",
        };
        $scope.M_CO.changeClaimStatusCssConfig = {
            "Unsubmitted": "bp-coral-light-bg bp-red-font",
            "Submitted": "bp-orange-light bp-orange-dark-font",
            "Approved": "bp-green-light bp-green-font",
        };
        $scope.M_CO.changeDealStatusList = ["Quotation", "In Progress", "Approved"];
        $scope.M_CO.changeDealStatusCssConfig = {
            "Quotation": "bp-purple-light newStatus",
            "In Progress": "bp-orange-light bp-orange-dark-font",
            "Approved": "bp-yellow-light completeStatus",
            "Invoiced": "bp-green-light invoicedStatus"
        };
        $scope.M_CO.dealOptionsStatusCssConfig = {
            "None": "newStatus bp-purple-light",
            "Required": "onholdStatus bp-on-hold",
            "Pending": "bp-orange-light bp-orange-dark-font",
            "Fulfilled": "invoicedStatus bp-green-light"
        };
        $scope.M_CO.SpecialOrderList = [];
        $scope.showAlternatePartDialog = false;
        $scope.M_CO.editModeIndexMultiSelect = {
            'Concern': -1,
            'Cause': -1,
            'Correction': -1
        };

        // Load Service Job Internal Expense Categories
        SOHeaderService.getServiceJobCategories('Internal Expense').then(function(response) {
          $scope.M_CO.CategoryList = response.CategoryList || [];
        }, function(error) {
          handleErrorAndExecption(error);
        });

        var clicky;
        angular.element(document).bind('mousedown', function(e) {
              switch (e.which) {
                  case 1:
                      //left mouse button
                      clicky = e.target;
                      break;
                  case 2:
                     //middle button click
                     //do nothing;
                     clicky = null;
                      break;
                  case 3:
                      //right button click
                      //do nothing #4500;
                      clicky = null;
                      break;
              }

        });
        var success = function() {
            var self = this;
            this.arguments = arguments[0];
            this.type = arguments[0].type,
                this.callback = arguments[0].callback,
                this.callbackParam = arguments[0].callbackParam,
                this.handler = function(successResult) {
                    switch (self.type) {
                        case 'getSOHeaderDetails':
                            handleGetSOHeaderDetailsResponse(successResult, self.arguments.stopLoadingIcon);
                            break;
                        case 'removeServiceOrderItem':
                            handleRemoveServiceOrderItemResponse(successResult, self.arguments.isDeleteFromMoveLIModal, self.arguments.stopLoadingIcon);
                            break;
                        case 'removeDealSOItem':
                            handleRemoveDealSOItemResponse(successResult);
                            break;
                        case 'deleteCOLineItem':
                            handleDeleteCOLineItemResponse(successResult, self.arguments.isDeleteFromMoveLIModal, self.arguments.stopLoadingIcon);
                            break;
                        case 'deleteDealCOLineItem':
                            handleDeleteDealCOLIResponse(successResult, self.arguments.stopLoadingIcon);
                            break;
                        case 'removeHoursLoggedItem':
                            handleRemoveHoursLoggedItemResponse(successResult);
                            break;
                        case 'updateSOLineItem':
                            handleUpdateSOLineItemResponse(successResult);
                            break;
                        case 'updateDealSOLineItem':
                            handleUpdateDealSOLineItemResponse(successResult);
                            break;
                        case 'getCOCheckoutInfo':
                            handleGetCOCheckoutInfoResponse(successResult);
                            break;
                        case 'getCOHeaderDetailsByGridName':
                            handleGetCOHeaderDetailsByGridNameResponse(successResult);
                            break;
                        case 'saveDealInfo':
                            handleSaveDealInfoResponse(successResult);
                            break;
                        case 'getListOfFinanceCompany':
                            handleGetListOfFinanceCompanyResponse(successResult);
                            break;
                        case 'createSOHeader':
                            handleCreateSOHeaderResponse(successResult);
                            break;
                        case 'addCustomer':
                            handleAddCustomerResponse(successResult);
                            break;
                        case 'addCustomerCoBuyer':
                            handleAddCustomerCoBuyerResponse(successResult);
                            break;
                        case 'createCO':
                            handleCreateCOResponse(successResult);
                            break;
                        case 'addSOLineItem':
                            handleAddSOLineItemResponse(successResult);
                            break;
                        case 'addCOLineItem':
                            handleAddCOLineItemResponse(successResult);
                            break;
                        case 'refreshSOHeaderInfo':
                            handleRefreshSOHeaderInfoResponse(successResult);
                            break;
                        case 'getSOMasterData':
                            handleGetSOMasterDataResponse(successResult);
                            break;
                        case 'getAttachmentList':
                            handleGetAttachmentListDataResponse(successResult);
                            break;
                        case 'getServiceWorksheetPrintDetail':
                            handleGetServiceWorksheetPrintDetail(successResult);
                            break;
                        case 'addDeductibleAmount':
                            handleAddDeductibleAmountResponse(successResult);
                            break;
                        case 'createMerchandiseSection':
                            handleCreateMerchandiseSectionResponse(successResult);
                            break;
                        case 'saveFinancingInfo':
                            handleSaveFinancingInfoResponse(successResult, self.arguments.isCreateFinancingSection);
                            break;
                        case 'getDealDetails':
                            handleGetDealDetailsResponse(successResult);
                            break;
                        case 'getDealTotalInfo':
                            handleGetDealTotalInfoResponse(successResult);
                            break;
                        case 'createUnitDeal':
                            handleCreateUnitDealResponse(successResult);
                            break;
                        case 'saveOptionFeesLineItem':
                            handleSaveOptionFeesLineItem(successResult);
                            break;
                        case 'recalculationOfDealKHLineItems':
                            handleRecalculationOfDealKHLineItems(successResult);
                            break;
                        case 'removeOptionFee':
                            handleRemoveOptionFeeResponse(successResult);
                            break;
                        case 'saveTemporaryUnit':
                            handleSaveTemporaryUnitResponse(successResult);
                            break;
                        case 'addStockUnit':
                            handleAddStockUnitResponse(successResult);
                            break;
                        case 'saveDealFAndIProduct':
                            handleSaveDealFAndIProductResponse(successResult);
                            break;
                        case 'removeUnitFromDeal':
                            handleRemoveUnitFromDealResponse(successResult, self.arguments.unitListLength, self.arguments.UnitId);
                            break;
                        case 'addDealCOLineItem':
                            handleAddDealCOLineItemResponse(successResult);
                            break;
                        case 'commitUnitToDeal':
                            handleCommitUnitToDealResponse(successResult);
                            break;
                        case 'commitAndInstallDeal':
                            handleCommitAndInstallDealResponse(successResult);
                            break;
                        case 'updateTradeIn':
                            handleUpdateTradeInResponse(successResult, self.arguments.tradeInIndex);
                            break;
                        case 'removeTradeItem':
                            handleRemoveTradeItemResponse(successResult);
                            break;
                        case 'stockInCOU':
                          handleStockInCOUResponse(successResult);
                            break;
                        case 'resolveFulfillment':
                            handleResolveFulfillmentResponse(successResult);
                            break;
                        case 'updateDealFinancingStatus':
                            handleUpdateDealFinancingStatusResponse(successResult);
                            break;
                        case 'removeFAndIProductLineItem':
                            handleremoveFAndIProductLineItemResponse(successResult);
                            break;
                        case 'removeDealFinancing':
                            handleRemoveDealFinancingResponse(successResult);
                            break;
                        case 'getListOfFIproducts':
                            handleGetListOfFIproductsResponse(successResult);
                            break;
                        case 'finalizeInvoice':
                            handlefinalizeInvoiceResponse(successResult);
                            break;
                        case 'AddDepositAmount':
                            handleAddDepositAmountResponse(successResult);
                            break;
                        case 'getSalesTaxDetailsForDeal':
                            handleGetSalesTaxDetailsForDealResponse(successResult);
                            break;
                        case 'getPrimaryUnitImage':
                          handleGetPrimaryUnitImageResponse(successResult);
                          break;
                        case 'getUnitImagesByUnitId':
                          handleGetUnitImagesByUnitId(successResult);
                          break;
                        default:
                            break;
                    }
                    if (typeof self.callback === 'function') {
                        self.callback(self.callbackParam);
                    }
                }

            function handleGetSOMasterDataResponse(masterData) {
                $scope.M_CO.COUList = masterData.COUList;
                getDataForTradeInsCouList();
                getCustomerApprovalData();
                if ($scope.M_CO.TradeIn.COUList.length == 1) {
                    $scope.F_CO.TradeIn.selectedUnit($scope.M_CO.TradeIn.COUList[0]);
                } else {
                    $scope.M_CO.TradeIn.selectedUnitName = '';
                }
                $scope.M_CO.TTList = masterData.TTList;
                /**
                 * If Job type is 'Internal Expense' and CO type is 'Internal Service' then it will only be added to TTOptionListWithDeal & TTOptionsListWithQuote
                 * If Job type is 'Deal' then it will only be added to TTOptionListWithDeal
                 * If Job type is 'Quote' then it will only be added to TTOptionsListWithQuote
                 * All other Job type will be added to TTOptionsList
                 */
                $scope.M_CO.TTOptionListWithDeal = [];
                $scope.M_CO.TTOptionsList = [];
                $scope.M_CO.TTOptionsListWithQuote = [];

              if($scope.M_CO.coHeaderRec.COType === 'Internal Service') {
                angular.forEach($scope.M_CO.TTList, function(JobType) {
                    if (JobType.Type == 'Stock Unit' ||  JobType.Type == 'Third-Party') {
                            $scope.M_CO.TTOptionsList.push(JobType);
                        }
                });
                } else {
                  angular.forEach($scope.M_CO.TTList, function(JobType) {
                    if(JobType.Type != 'Stock Unit') {
                      if(JobType.Type === 'Deal Service') {
                        $scope.M_CO.TTOptionListWithDeal.push(JobType);
                      } else {
                        $scope.M_CO.TTOptionsListWithQuote.push(JobType);
                              if (JobType.Type != 'Quote' ) {
                              $scope.M_CO.TTOptionsList.push(JobType);
                              }
                      }
                    }
                    });
                }
                $scope.M_CO.ProviderList = masterData.ProviderList;
            }

            function handleAddDepositAmountResponse(DepositList) {
                $scope.M_CO.DepositList = DepositList;
                $scope.F_CO.Deposit.closeAddDepositPopup();
                $scope.F_CO.closeReversePaymentConfirmationPopup()
                $scope.F_CO.Deposit.calculateDepositAmount(true);
                $scope.M_CO.Deposit.refundFlag = false;
                $scope.M_CO.isLoading = false;
                $scope.M_CO.Deposit.tempPaymentDate = $scope.M_CO.Deposit.paymentDate = getDateStringWithFormat(new Date(), $scope.M_CO.dateFormat);
                showTooltip('body');
                setTimeout(function() {
                    $scope.F_CO.expandedSection('DepositSectionId', 'Deposit', '', $rootScope.GroupOnlyPermissions['Customer invoicing']['view']);
                }, 100)
            }

            function handleGetCOCheckoutInfoResponse(result) {
            	$scope.CheckoutInfoModel.paymentMethod = null;
                $scope.CheckoutInfoModel.selectedOptionForCheckout = null;
                $scope.CheckoutInfoModel.BalanceDue = 0;
                $scope.CheckoutInfoModel.Total = 0;
                $scope.M_CO.isCheckOutPartialSelect = false;
                $scope.M_CO.showCheckOutLineItem = -1;
                $scope.CheckoutInfoModel.IsPartReturn = false;
                $scope.CheckoutInfoModel.InvoiceItemList = [];
                $scope.CheckoutInfoModel.InvoicePaymentList = [];
                $scope.M_CO.totalDeductibleAmount = 0;
                var isDealItemActive = false;
                if(result) {
                  if(result.InvoiceItemList != undefined) {
                      $scope.CheckoutInfoModel.InvoiceItemList = [];
                      for (var i = 0; i < result.InvoiceItemList.length; i++) {
                          if (result.InvoiceItemList[i].CheckoutType == 'Customer') {
                              if (!$scope.F_CO.disableCheckOutItemSelection(result.InvoiceItemList[i]) && result.InvoiceItemList[i].IsActive && result.InvoiceItemList[i].IsInvoiceable) {
                                  if(result.InvoiceItemList[i].CheckoutItemType === 'Deal') {
                                    isDealItemActive = true;
                                    $scope.CheckoutInfoModel.Total = result.InvoiceItemList[i].Total;
                                      $scope.M_CO.totalDeductibleAmount = 0;
                                  } else if(!isDealItemActive){
                                  $scope.CheckoutInfoModel.Total += result.InvoiceItemList[i].Total;
                                    if (result.InvoiceItemList[i].CheckoutItemType == 'SO Deductible') {
                                        $scope.M_CO.totalDeductibleAmount += result.InvoiceItemList[i].Total;
                                    }
                                  }
                              } else {
                                  result.InvoiceItemList[i].IsActive = false;
                              }
                              $scope.CheckoutInfoModel.InvoiceItemList.push(result.InvoiceItemList[i]);
                          } else {
                              result.InvoiceItemList[i].IsActive = false;
                          }
                      }
                  }
                  if (result.DepositList) {
                      $scope.M_CO.DepositList = result.DepositList;
                      $scope.F_CO.Deposit.calculateDepositAmount();
                  }
                  if (result.InvoicePaymentList) {
                      $scope.CheckoutInfoModel.InvoicePaymentList = result.InvoicePaymentList;
                  }
                  $scope.CheckoutInfoModel.activeInvHeaderId = result.ActiveInvoiceHeaderId;
                  $scope.CheckoutInfoModel.PaymentReceived = result.PaymentReceived;
                }

                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive) {
                        $scope.M_CO.isCheckOutPartialSelect = true;
                        break;
                    }
                }
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive) {
                        $scope.M_CO.isAllInvoiceItemsSelected = true;
                    } else {
                        $scope.M_CO.isAllInvoiceItemsSelected = false;
                        break;
                    }
                }
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive && $scope.CheckoutInfoModel.InvoiceItemList[i].Total < 0) {
                        $scope.CheckoutInfoModel.IsPartReturn = true;
                    }
                }
                if ($scope.M_CO.isAllInvoiceItemsSelected) {
                    $scope.M_CO.isCheckOutPartialSelect = false;
                }
                if ($scope.CheckoutInfoModel.InvoiceItemList.length == 0) {
                    $scope.M_CO.isCheckOutPartialSelect = false;
                }

                if(result) {
                  $scope.CheckoutInfoModel.TaxDetails = result.TaxDetails;
                  if (!isDealItemActive && !$scope.M_CO.coHeaderRec.IsTaxIncludedPricing && ($scope.M_CO.isCheckOutPartialSelect || $scope.M_CO.isAllInvoiceItemsSelected)) {
                      for (var i = 0; i < result.TaxDetails.length; i++) {
                          $scope.CheckoutInfoModel.Total += result.TaxDetails[i].TaxAmount;
                      }
                  }
                  $scope.CheckoutInfoModel.TotalFee = result.TotalFee;
                  $scope.CheckoutInfoModel.TotalSublet = result.TotalSublet;
                  $scope.CheckoutInfoModel.TotalLabor = result.TotalLabor;
                  $scope.CheckoutInfoModel.TotalShopSupplies = result.TotalShopSupplies;
                  $scope.CheckoutInfoModel.TotalPart = result.TotalPart;
                  $scope.CheckoutInfoModel.CustomerStoreCredit = result.CustomerStoreCredit;
                }

                $scope.F_CO.calculateTotalPayment();
                $scope.CheckoutInfoModel.Total = $scope.CheckoutInfoModel.Total.toFixed(2);
                $scope.CheckoutInfoModel.BalanceDue = parseFloat(($scope.CheckoutInfoModel.Total - $scope.M_CO.coHeaderRec.TotalPayments.toFixed(2)));
                if ($scope.CheckoutInfoModel.selectedOptionForCheckout == 'Cash') {
                    $scope.CheckoutInfoModel.BalanceDue = $scope.F_CO.CalculateCashPaymentRoundingAmount($scope.CheckoutInfoModel.BalanceDue);
                }
                $scope.CheckoutInfoModel.BalanceDueCopy = angular.copy($scope.CheckoutInfoModel.BalanceDue);
                if(isDealItemActive){
                  for(var i=0; i<$scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive && $scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType != 'Deal') {
                      $scope.CheckoutInfoModel.InvoiceItemList[i].IsActive = false;
                    }
                  }
                }
        $scope.F_CO.validateCheckoutLineItem();
        setTimeout(function(){
                  angular.element('#checkout-modal').scrollTop(0);
                },100);
                $scope.CheckoutInfoModel.PaymentReverseLink = null;
                $scope.CheckoutInfoModel.isReversePayment = false;
                $scope.CheckoutInfoModel.RoundedBalanceDue = 0;
                showTooltip('#checkout-modal');
                $scope.F_CO.hideDeleteConfirmationPopup();
                $scope.M_CO.editLineItem = '';
                $scope.M_CO.deletedItemName = '';
                $scope.M_CO.deletedItemGridName = '';
                $scope.M_CO.deletableInvPaymentRec = {};
                $scope.M_CO.isLoading = false;
                $scope.M_CO.showCheckoutModalWindow = true;
            }

            function handleAddCustomerResponse(customerData) {
                if ($scope.M_CO.COHeaderId) {
                  if(self.arguments.addCOLIAndCreateSpecialOrder) { // Handling For Cash Sale Oversold Functionality
                    createSpecialOrderAction().then(function(MerchandiseList) {
                      // Bind Merchandise Data
                      $scope.F_CO.getSpecialOrdersData();
                      $scope.M_CO.COKHList = MerchandiseList.COKHList;
                      $scope.M_CO.coHeaderRec.MerchandiseTotal = MerchandiseList.coHeaderRec.MerchandiseTotal;
                      $scope.M_CO.isTabKeyPressed = false;

                      //Bind Customer Data
                      customerData.coHeaderRec = MerchandiseList.coHeaderRec;
                      bindAddCustomerResponseData(customerData);
                        });
                  } else {
                    bindAddCustomerResponseData(customerData);
                  }
                } else {
                    $scope.M_CO.COHeaderId = customerData.coHeaderRec.COHeaderId;
                    $scope.M_CO.isLoading = true;
                    populateCOHeaderIdInUrl();
                }
            }

            function handleAddCustomerCoBuyerResponse(customerData) {
                $scope.M_CO.CustomerCOBuyerCardInfo = customerData.CardInfo;
            }

            function handleCreateCOResponse(customerData) {
              if($stateParams.Id) {
                $scope.M_CO.CustomerCardInfo = customerData.CardInfo;
                    $scope.M_CO.COHeaderId = customerData.coHeaderRec.COHeaderId;
                    $scope.M_CO.coHeaderRec = customerData.coHeaderRec;
                    $scope.M_CO.isReload = false;
              }
              getCustomerApprovalData();
                if (!$scope.M_CO.coHeaderRec.CustomerId && $scope.M_CO.isOpenSelectCustomerSectionForCashSaleSpecialOrder) { // Handling For Cash Sale Oversold Functionality
                	createSpecialOrderAction(customerData.coHeaderRec.COHeaderId).then(function(MerchandiseList) {
	                	$scope.M_CO.isCompleteLoad = true;
	                    populateCOHeaderIdInUrl(customerData.coHeaderRec.COHeaderId);
                    });
                } else {
                  $scope.M_CO.isCompleteLoad = true;
                    populateCOHeaderIdInUrl(customerData.coHeaderRec.COHeaderId);
                }
            }

            function handleUpdateDealFinancingStatusResponse(result) {
                //TODO why this is left empty ?
            }

            function handleAddSOLineItemResponse(serviceOrderHeader) {
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex] = serviceOrderHeader[0];
                var lastIndex = $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOGridItems.length - 1;
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOGridItems[lastIndex] = serviceOrderHeader[0].SOGridItems[lastIndex];
                $scope.M_CO.editLineItemIndex = -1;
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Total = serviceOrderHeader[0].SOInfo.Total;

                $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeader[0].OrderTotal;
                $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeader[0].InvoicedAmount;
                $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeader[0].UninvoicedAmount;
                $scope.M_CO.coHeaderRec.TotalPayments = serviceOrderHeader[0].TotalPayments;
                setTimeout(function() {
                    if ($scope.M_CO.SOHeaderList.length > 0) {
                        $scope.M_CO.expandedInnerDivFlag = false;
                        $scope.M_CO.expandedDivFlag = false;
                        $scope.F_CO.expandInnerSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItemsSectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItems');
                        $scope.F_CO.expandedSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_SectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex));
                    }
                }, 100);
                if (self.arguments.isAddMode) {
                    var SOKHList = angular.copy($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOGridItems);
                    if (SOKHList && (SOKHList.length > 0) && SOKHList[(SOKHList.length - 1)].Id) {
                        var SoHeaderIndex = self.arguments.SOHeaderIndex;
                        var SoKitHeaderIndex = SOKHList.length - 1;
                        if ($scope.F_CO.displayEditBtnOnLineItem('SO', 'KHItem', SoHeaderIndex, SoKitHeaderIndex)) {
                            $scope.F_CO.editSOKHItem('ServiceJob', SoHeaderIndex, SoKitHeaderIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }
                    } else if (SOKHList && (SOKHList.length > 0) && SOKHList[(SOKHList.length - 1)].SOLIList && SOKHList[(SOKHList.length - 1)].SOLIList.length > 0) {
                        var SoHeaderIndex = self.arguments.SOHeaderIndex;
                        var SoKitHeaderIndex = SOKHList.length - 1;
                        var SoLIIndex = SOKHList[(SOKHList.length - 1)].SOLIList.length - 1;
                        if (SOKHList[SoKitHeaderIndex].SOLIList[SoLIIndex].IsEnvFee) {
                            SoKitHeaderIndex -= 1;
                            SoLIIndex = SOKHList[SoKitHeaderIndex].SOLIList.length - 1;
                        }
                        if ($scope.F_CO.displayEditBtnOnLineItem('SO', 'NonKitLI', SoHeaderIndex, SoKitHeaderIndex, SoLIIndex)) {
                            $scope.F_CO.editSOLineItem('ServiceJob', SoHeaderIndex, SoKitHeaderIndex, SoLIIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }
                        // Get CO Forms if Vedor Product is added
                        if(SOKHList[SoKitHeaderIndex].SOLIList[SoLIIndex].IsSublet) {
                          getCOFormsBySectionId($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id).then(function(sectionIdToFormList) {
                          $scope.M_CO.documents.forms.so[$scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id] = sectionIdToFormList[$scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id];
                          $scope.M_CO.documents.activeForms.so[$scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id] = _.filter($scope.M_CO.documents.forms.so[$scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id], function(rec){ return rec.IsActive; });
                          showTooltip('body');
                            }, function(error) {
                              handleErrorAndExecption(error);
                            });
                        }
                    }
                }
                getCustomerApprovalData();
                $scope.M_CO.isLoading = false;
                $scope.M_CO.isSupressTrue = false;
            }
            $scope.F_CO.updateDealFinanceStatus = function() {
                if (!isBlankValue($scope.M_CO.DealFinance.Status)) {
                  $scope.M_CO.Deal.DealFinanceObj.Status = $scope.M_CO.DealFinance.Status;
                    var successJson = {};
                    DealService.updateDealFinanceStatus($scope.M_CO.COHeaderId, $scope.M_CO.Deal.DealInfo.Id, angular.toJson($scope.M_CO.Deal.DealFinanceObj), $scope.M_CO.Deal.DealFinanceObj.Status).then(new success(successJson).handler, new error().handler);
                }
            }

            function handleSaveOptionFeesLineItem(result) {
                var unitIndex = self.arguments.UnitIndex;
                if (result.DealInfo != undefined && ($scope.M_CO.Deal.DealInfo.DealStatus == 'In Progress' || $scope.M_CO.Deal.DealInfo.DealStatus == 'Approved') && $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.OptionAndFeeStatus == 'Committed') {
                    $scope.M_CO.Deal = result;
                } else {
                    $scope.M_CO.Deal.UnitList[self.arguments.UnitIndex] = result;
                }
                setTimeout(function() {
                    if ($scope.M_CO.Deal.UnitList.length > 0) {
                        $scope.M_CO.expandedInner2DivFlag = false;
                        $scope.M_CO.expandedInnerDivFlag = false;
                        $scope.M_CO.expandedDivFlag = false;
                        $scope.F_CO.expandInner2Section('Deal_DU' + (self.arguments.UnitIndex) + '_UISectionId', 'Deal_DU' + (self.arguments.UnitIndex) + '_UI');
                        $scope.F_CO.expandInnerSection('Deal_DU' + (self.arguments.UnitIndex) + '_SectionId', 'Deal_DU' + (self.arguments.UnitIndex));
                        $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                    }
                }, 100);
                if (self.arguments.isAddMode) {
                    var DKHList = angular.copy($scope.M_CO.Deal.UnitList[self.arguments.UnitIndex].DealKitHeaderList);
                    if (DKHList && (DKHList.length > 0) && DKHList[(DKHList.length - 1)].Id) {
                        var UnitIndex = self.arguments.UnitIndex;
                        var DealKitHeaderIndex = DKHList.length - 1;
                        if ($scope.F_CO.displayEditBtnOnLineItem('OptionFee', 'KHItem', UnitIndex, DealKitHeaderIndex)) {
                            $scope.F_CO.editDealKHItem('deal', UnitIndex, DealKitHeaderIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }
                    } else if (DKHList && (DKHList.length > 0) && DKHList[(DKHList.length - 1)].OptionAndFeeList && DKHList[(DKHList.length - 1)].OptionAndFeeList.length > 0) {
                        var UnitIndex = self.arguments.UnitIndex;
                        var DealKitHeaderIndex = DKHList.length - 1;
                        var optionFeeLIIndex = DKHList[(DKHList.length - 1)].OptionAndFeeList.length - 1;
                        if (DKHList[DealKitHeaderIndex].OptionAndFeeList[optionFeeLIIndex].IsEnvFee) {
                            DealKitHeaderIndex -= 1;
                            optionFeeLIIndex = DKHList[DealKitHeaderIndex].OptionAndFeeList.length - 1;
                        }
                        if ($scope.F_CO.displayEditBtnOnLineItem('OptionFee', 'NonKitLI', UnitIndex, DealKitHeaderIndex, optionFeeLIIndex)) {
                            $scope.F_CO.editOptionFee('deal', UnitIndex, DealKitHeaderIndex, optionFeeLIIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }

                        // Get CO Forms if Vedor Product is added
                        if(DKHList[DealKitHeaderIndex].OptionAndFeeList[optionFeeLIIndex].ProductType === 'Warranty Plan'
                          || DKHList[DealKitHeaderIndex].OptionAndFeeList[optionFeeLIIndex].ProductType === 'Financing Product'
                          || DKHList[DealKitHeaderIndex].OptionAndFeeList[optionFeeLIIndex].ProductType === 'Deal Product'
                          || DKHList[DealKitHeaderIndex].OptionAndFeeList[optionFeeLIIndex].ProductType === 'Sublet') {
                          getCOFormsBySectionId($scope.M_CO.Deal.DealInfo.Id).then(function(sectionIdToFormList) {
                          $scope.M_CO.documents.forms.deal[$scope.M_CO.Deal.DealInfo.Id] = sectionIdToFormList[$scope.M_CO.Deal.DealInfo.Id];
                          $scope.M_CO.documents.activeForms.deal[$scope.M_CO.Deal.DealInfo.Id] = _.filter($scope.M_CO.documents.forms.deal[$scope.M_CO.Deal.DealInfo.Id], function(rec){ return rec.IsActive; });
                          showTooltip('body');
                            }, function(error) {
                              handleErrorAndExecption(error);
                            });
                        }
                    }
                } else {
                    $scope.M_CO.editLineItem = '';
                }
                showTooltip('body');
                $scope.M_CO.isSupressTrue = false;

                if($scope.M_CO.isTabKeyPressed) {
                  setTimeout(function() {
                    angular.element("#autocompleteDealUnit" + self.arguments.UnitIndex).focus();
                      $scope.M_CO.isTabKeyPressed = false;
                  },700);
                }
                $scope.M_CO.isLoading = false;
            }

            function handleRecalculationOfDealKHLineItems(result) {
                if (result.DealFulfillmentSectionObj != undefined) {
                    $scope.M_CO.DealMerchandiseList = result.DealFulfillmentSectionObj.DealMerchandiseList;
                }
                if (result.UnitList != undefined) {
                    var unitIndex = self.arguments.UnitIndex;
                    $scope.M_CO.Deal.UnitList[unitIndex].OptionAndFeeList = result.UnitList.OptionAndFeeList;
                }
                if (($scope.M_CO.Deal.DealInfo.DealStatus == 'In Progress' || $scope.M_CO.Deal.DealInfo.DealStatus == 'Approved') && $scope.M_CO.Deal.UnitList[self.arguments.UnitIndex].DealItemObj.OptionAndFeeStatus == 'Committed') {
                  $scope.F_CO.callGetSOHeaderDetails({'isDealCallback' : true});
                } else {
                  $scope.M_CO.isLoading = false;
                }
            }

            function handleResolveFulfillmentResponse(result) {
                $scope.M_CO.Deal = result;
                $scope.F_CO.hideUnresolvedFullfilmentPopUp();
                $scope.M_CO.isLoading = false;
            }

            function handleGetSalesTaxDetailsForDealResponse(result) {
                $scope.M_CO.dealTotalIncludingSalesTaxInDF = parseFloat(result.SalesTax) + parseFloat($scope.M_CO.Deal.DealInfo.Total);
            }

            function handleremoveFAndIProductLineItemResponse(result) {
              $scope.F_CO.updateDealSummaryTotals();
              $scope.F_CO.saveFinancingInfo();
                $scope.F_CO.DealFinance.getFIProductTotal();
                $scope.F_CO.hideDeleteConfirmationPopup();
                $scope.M_CO.editLineItem = '';
                setTimeout(function() {
                    var deletedElement = angular.element('#' + $scope.M_CO.deletableDFFI_FIProductElementID);
                    if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                        deletedElement.addClass('bp-collapse-deleted-div-transition');
                    }
                }, 100);
                setTimeout(function() {
                    $scope.M_CO.Deal.DealFinanceObj = result;
                    if($scope.M_CO.Deal.DealFinanceObj){
                        $scope.M_CO.Deal.DealFinanceObj.InterestRate = $scope.M_CO.Deal.DealFinanceObj.InterestRate ? $scope.M_CO.Deal.DealFinanceObj.InterestRate.toFixed(2) : 0.00;
                        $scope.M_CO.Deal.DealFinanceObj.DownPayment = $scope.M_CO.Deal.DealFinanceObj.DownPayment ? $scope.M_CO.Deal.DealFinanceObj.DownPayment.toFixed(2) : null ;
                        $scope.M_CO.Deal.DealFinanceObj.FinanceCommission = $scope.M_CO.Deal.DealFinanceObj.FinanceCommission ? $scope.M_CO.Deal.DealFinanceObj.FinanceCommission.toFixed(2) : null ;

                    }

                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply();
                    }
                    $scope.M_CO.deletableDFFI_Id = '';
                    $scope.M_CO.deletableDFFI_FIProductId = '';
                    $scope.M_CO.deletableDFFI_FIProductIndex = '';
                }, 600);
            }

            function handlefinalizeInvoiceResponse() {
            	SOHeaderService.getCOHeaderDetailsByGridName($stateParams.Id, null).then(function(result) {
            		$scope.M_CO.COKHList = result.COKHList;
	                $scope.M_CO.coHeaderRec.MerchandiseTotal = result.coHeaderRec.MerchandiseTotal;
	                $scope.M_CO.coHeaderRec = result.coHeaderRec;
	                $scope.M_CO.COInvoiceHistoryList = result.COInvoiceHistoryList;
	                if ($scope.M_CO.COInvoiceHistoryList.length > 0) {
	                    $scope.F_CO.invoicePrintPreview($scope.M_CO.COInvoiceHistoryList[0].COInvoiceHeaderId);
	                }
	                var param = {
	                    'isDealCallback': true,
	                    'expandSJInvoiceSection': true
	                };
	                getSOHeaderDetails(param);
	                $scope.M_CO.isLoading = false;
	                getCustomerApprovalData();
                }, function(error) {
	                  $scope.M_CO.isLoading = false;
	                  handleErrorAndExecption(error);
                });
            }

            function handleRemoveDealFinancingResponse(result) {
                $scope.M_CO.Deal.DealInfo = result;
                $scope.M_CO.Deal.DealFinanceObj = {};
                $scope.M_CO.documents.forms.dealFinance = {};
                $scope.M_CO.documents.activeForms.dealFinance = {};
                $scope.M_CO.isLoading = false;
            }

            function handleCommitUnitToDealResponse(result) {
                $scope.M_CO.Deal.DealInfo = result;
                if ($scope.M_CO.Deal.DealInfo.DealStatus == 'In Progress' || $scope.M_CO.Deal.DealInfo.DealStatus == 'Approved') {
                    for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                      if($scope.M_CO.Deal.UnitList[i].DealItemObj.Status !== 'On Order') {
                        $scope.M_CO.Deal.UnitList[i].DealItemObj.Status = 'Reserved';
                      }
                    }
                    if($scope.M_CO.Deal.DealInfo.DealStatus === 'Approved' && !$scope.M_CO.coHeaderRec.ActiveInvoiceId) {
                      getActiveInvHeaderId();
                    }
                } else if ($scope.M_CO.Deal.DealInfo.DealStatus == 'Quotation') {
                    for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                      if($scope.M_CO.Deal.UnitList[i].DealItemObj.Status !== 'On Order') {
                        $scope.M_CO.Deal.UnitList[i].DealItemObj.Status = 'Available';
                      }
                    }
                }
        angular.element('body').removeClass('modal-open');
                $scope.M_CO.isLoading = false;
            }

            function handleCommitAndInstallDealResponse(result) {
                $scope.M_CO.hideCommitAndInstallBtn = true;
                $scope.M_CO.Deal.DealFulfillmentSectionObj = result;

                var isKit = false;
                for(var i = 0; i < $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length; i++) {
                  if($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i].Id) {
                isKit = true;
                  }
                }
                if(isKit) {
                  recalculateKitForDealMerchSection();
                }
                if(!$scope.M_CO.coHeaderRec.ActiveInvoiceId) {
                  getActiveInvHeaderId();
                }
            }

            function handleAddDealCOLineItemResponse(result) {
                  $scope.M_CO.isLoading = false;
                  $scope.M_CO.Deal.DealFulfillmentSectionObj.MerchandiseTotal = result.DealFulfillmentSectionObj.MerchandiseTotal;
                  $scope.M_CO.SpecialOrderList = result.DealFulfillmentSectionObj.DealSpecialOrderList;
                if (self.arguments.isAddMode) {
                    var DealMerchandiseList = JSON.parse(JSON.stringify(result.DealFulfillmentSectionObj.DealMerchandiseList)); 
                    $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length] = DealMerchandiseList[DealMerchandiseList.length-1];
                    $scope.M_CO.Deal.DealUnresolvedFulfillmentList[$scope.M_CO.Deal.DealUnresolvedFulfillmentList.length] = result.DealUnresolvedFulfillmentList[result.DealUnresolvedFulfillmentList.length-1];
                    if (DealMerchandiseList && (DealMerchandiseList.length > 0) && DealMerchandiseList[(DealMerchandiseList.length - 1)].Id) {
                        var CoKitHeaderIndex = DealMerchandiseList.length - 1;
                        if ($scope.F_CO.displayEditBtnOnLineItem('DealMerch', 'KHItem', '', CoKitHeaderIndex)) {
                          editCOKHItem('DealMerch_Section_COKitHeader', CoKitHeaderIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }
                         
                    } else if (DealMerchandiseList && (DealMerchandiseList.length > 0) && DealMerchandiseList[(DealMerchandiseList.length - 1)].COLIList && DealMerchandiseList[(DealMerchandiseList.length - 1)].COLIList.length) {
                        var CoKitHeaderIndex = DealMerchandiseList.length - 1;
                        var CoLIIndex = DealMerchandiseList[(DealMerchandiseList.length - 1)].COLIList.length - 1;
                        if ($scope.F_CO.displayEditBtnOnLineItem('DealMerch', 'NonKitLI', '', CoKitHeaderIndex, CoLIIndex)) {
                            $scope.F_CO.editCOLineItem('DealMerch_Section_COKitHeader', CoKitHeaderIndex, CoLIIndex);
                        } else {
                            $scope.M_CO.editLineItem = '';
                        }
                    }
                } else {
                    $scope.M_CO.editLineItem = '';
                    if(self.arguments.COKitHeaderIndex || self.arguments.COKitHeaderIndex == 0) {
                      $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[self.arguments.COKitHeaderIndex] = result.DealFulfillmentSectionObj.DealMerchandiseList[self.arguments.COKitHeaderIndex];
                      $scope.M_CO.Deal.DealUnresolvedFulfillmentList = result.DealUnresolvedFulfillmentList;
                    }
                }
                $scope.M_CO.isLoading = false;
                $scope.M_CO.isSupressTrue = false;
                if($scope.M_CO.isTabKeyPressed) {
                  angular.element("#autocompleteDealMerchSectionWrapperId").focus();
                  $scope.M_CO.isTabKeyPressed = false;
                }
            }

            function handleAddCOLineItemResponse(MerchandiseList) {
              /*Start: Cash Sale Oversold Functionality*/
              if(!$scope.M_CO.coHeaderRec.CustomerId && $scope.M_CO.isOutOfStockPart) {
                $scope.F_CO.closeOversoldPopup();
              }
              /*End: Cash Sale Oversold Functionality*/

                $scope.F_CO.getSpecialOrdersData();
                if ($scope.M_CO.COHeaderId == null || $scope.M_CO.COHeaderId == undefined) {
                  if($stateParams.Id) {
                    $scope.M_CO.COHeaderId = MerchandiseList.coHeaderRec.COHeaderId;
                    $scope.M_CO.isReload = false;
                  }
                    populateCOHeaderIdInUrl(MerchandiseList.coHeaderRec.COHeaderId);
                } else {
                    $scope.M_CO.isLoading = false;
                    if($scope.PartSmart.IsAddingFromPartSmart) {
                      $scope.M_CO.COKHList = MerchandiseList.COKHList;
                        $scope.M_CO.coHeaderRec = MerchandiseList.coHeaderRec
                        showPartsSmartItemsNotInserted();
                      $scope.PartSmart.IsAddingFromPartSmart = false;
                      return;
                    }
                }
                getCustomerApprovalData();
                if($stateParams.Id) {
                    $scope.M_CO.coHeaderRec = MerchandiseList.coHeaderRec;
                    if (self.arguments.isAddMode) {
                      
                        var COKHList = JSON.parse(JSON.stringify(MerchandiseList.COKHList)); 
                        if (COKHList && (COKHList.length > 0) && COKHList[(COKHList.length - 1)].Id) {
                           $scope.M_CO.COKHList[$scope.M_CO.COKHList.length] = COKHList[COKHList.length-1];
                            var CoKitHeaderIndex = COKHList.length - 1;
                            if ($scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'KHItem', '', CoKitHeaderIndex)) {
                              editCOKHItem('Merchandise_Section_COKitHeader', CoKitHeaderIndex);
                            } else {
                                $scope.M_CO.editLineItem = '';
                            }
                            
                        } else if (COKHList && (COKHList.length > 0) && COKHList[(COKHList.length - 1)].COLIList && COKHList[(COKHList.length - 1)].COLIList.length > 0) {
                            var CoKitHeaderIndex = COKHList.length - 1;
                            var CoLIIndex = COKHList[(COKHList.length - 1)].COLIList.length - 1;
                            if (COKHList[CoKitHeaderIndex].COLIList[CoLIIndex].EntityType === 'Env Fee') {
                                CoKitHeaderIndex -= 1;
                                CoLIIndex = COKHList[CoKitHeaderIndex].COLIList.length - 1;
                                $scope.M_CO.COKHList[$scope.M_CO.COKHList.length] = COKHList[COKHList.length-2];
                                $scope.M_CO.COKHList[$scope.M_CO.COKHList.length] = COKHList[COKHList.length-1];
                            } else {
                              $scope.M_CO.COKHList[$scope.M_CO.COKHList.length] = COKHList[COKHList.length-1];
                            }
                            if ($scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'NonKitLI', '', CoKitHeaderIndex, CoLIIndex)) {
                                $scope.F_CO.editCOLineItem('Merchandise_Section_COKitHeader', CoKitHeaderIndex, CoLIIndex);
                            } else {
                                $scope.M_CO.editLineItem = '';
                            }
                        }
                    } else {
                        $scope.M_CO.editLineItem = '';
                        if(self.arguments.COKitHeaderIndex || self.arguments.COKitHeaderIndex == 0) {
                          $scope.M_CO.COKHList[self.arguments.COKitHeaderIndex] = MerchandiseList.COKHList[self.arguments.COKitHeaderIndex];
                        }
                    }
                    //showTooltip('body');
                    $scope.M_CO.isSupressTrue = false;

                    if($scope.M_CO.isTabKeyPressed) {
                      angular.element('#autocompleteMerchandiseSectionWrapperId').focus();
                      $scope.M_CO.isTabKeyPressed = false;
                    }
                }

            }

            function handleRefreshSOHeaderInfoResponse(serviceOrderHeaderInfo) {
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo = serviceOrderHeaderInfo;
                $scope.M_CO.isLoading = false;
                if(self.arguments.isGetUnitImageData && $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.UnitId) {
                  getPrimaryUnitImage($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.UnitId, 'New SO unit', self.arguments.SOHeaderIndex);
                }

                if(self.arguments.isUpdateRelatedAppointmentRec && $scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length) {
                  updateAppointmentsOnCustomerOrSOFieldsChange($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Id);
                }
            }

            function handleAddDeductibleAmountResponse(DeductibleItem) {
                if ($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].DeductibleItem == undefined) {
                    $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].DeductibleItem = {};
                }
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].DeductibleItem.DeductibleId = DeductibleItem.Id;
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].DeductibleItem.DeductibleStatus = DeductibleItem.DeductibleStatus;
                $scope.M_CO.isLoading = false;
            }

            function handleSaveFinancingInfoResponse(result, isCreateFinancingSection) {
                $scope.M_CO.Deal.DealFinanceObj = result;
                
                if(self.arguments.changeFinanceCompany && $scope.F_CO.dirRefreshFnOnParamChange) {
                  $scope.F_CO.dirRefreshFnOnParamChange('financeVendorId'); // Refresh directive(Autocompete_v2 - STA) on slected financeVendor Id change
                }
                
                if($scope.M_CO.Deal.DealFinanceObj){
                    $scope.M_CO.Deal.DealFinanceObj.InterestRate = $scope.M_CO.Deal.DealFinanceObj.InterestRate ? $scope.M_CO.Deal.DealFinanceObj.InterestRate.toFixed(2) : 0.00;
                    $scope.M_CO.Deal.DealFinanceObj.DownPayment = $scope.M_CO.Deal.DealFinanceObj.DownPayment ? $scope.M_CO.Deal.DealFinanceObj.DownPayment.toFixed(2) : null ;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCommission = $scope.M_CO.Deal.DealFinanceObj.FinanceCommission ? $scope.M_CO.Deal.DealFinanceObj.FinanceCommission.toFixed(2) : null ;
                }

                $scope.F_CO.DealFinance.getFIProductTotal();

                if(isCreateFinancingSection && $scope.M_CO.Deal.DealFinanceObj && $scope.M_CO.Deal.DealFinanceObj.Id) {
                  insertDefaultCOFormsToSpecificSection($scope.M_CO.COHeaderId, $scope.M_CO.Deal.DealFinanceObj.Id).then(function() {
                    getCOFormsBySectionId($scope.M_CO.Deal.DealFinanceObj.Id).then(function(sectionIdToFormList) {
                      $scope.M_CO.documents.forms.dealFinance = sectionIdToFormList;
                      $scope.M_CO.documents.activeForms.dealFinance = _.filter($scope.M_CO.documents.forms.dealFinance, function(rec){ return rec.IsActive; });
                        showTooltip('body');
                        }, function(error) {
                          handleErrorAndExecption(error);
                        });
                    }, function(error) {
                      handleErrorAndExecption(error);
                    });
                }

                $scope.M_CO.isLoading = false;
                if (isCreateFinancingSection) {
                    setTimeout(function() {
                        $scope.F_CO.expandedSection('DFSectionId', 'DFSection');
                        $scope.F_CO.expandInnerSection('DF_SummarySectionId', 'DF_SummarySection');
                    }, 100);
                }
            }

            function handleCreateMerchandiseSectionResponse(successResult) {
                if (successResult) {
                    $scope.M_CO.COKHList = successResult.COKHList;
                    $scope.M_CO.coHeaderRec.MerchandiseTotal = successResult.coHeaderRec.MerchandiseTotal;
                    $scope.M_CO.coHeaderRec.OrderTotal = successResult.coHeaderRec.OrderTotal;
                    $scope.M_CO.coHeaderRec.InvoicedAmount = successResult.coHeaderRec.OrderTotal;
                    $scope.M_CO.coHeaderRec.UninvoicedAmount = successResult.coHeaderRec.OrderTotal;
                }
                defaultActionAfterCreateMerchandise();
            }

            function handleGetAttachmentListDataResponse(attachmentList) {
                var deletedElement = angular.element('#' + self.arguments.elementId);
                if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                    deletedElement.addClass('bp-collapse-deleted-div-transition');
                }
                setTimeout(function() {
                    $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].AttachmentList = attachmentList;
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                }, 500);
                $scope.M_CO.deletableAttachment_SOHeader_Index = '';
                $scope.M_CO.deletableAttachment_SOHeader_Id = '';
                $scope.M_CO.deletableAttachment_Index = '';
                $scope.M_CO.deletableAttachment_Id = '';
            }

            function handleGetSOHeaderDetailsResponse(serviceOrderHeaderList, stopLoadingIcon) {
                var isDealKitExists = false;
              if(isDealServiceKitExistsForRecalculation) {
                isDealServiceKitExistsForRecalculation = false;
                recalculateKitForDealServiceSection(serviceOrderHeaderList);
                } else {
                    $scope.M_CO.SOHeaderList = serviceOrderHeaderList;
                    if (serviceOrderHeaderList.length > 0) {
                        $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeaderList[0].OrderTotal;
                        $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeaderList[0].InvoicedAmount;
                        $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeaderList[0].UninvoicedAmount;
                        $scope.M_CO.coHeaderRec.TotalPayments = serviceOrderHeaderList[0].TotalPayments;
                    }

                    showTooltip('body');
                    if (!isBlankValue(stopLoadingIcon) && stopLoadingIcon) {
                        $scope.M_CO.isLoading = false;
                        $scope.M_CO.isCompleteLoad = true;
                        showPartsSmartItemsNotInserted();
                        getRelatedCODataAsynchronously();
                    }
                    if ($scope.M_CO.DummyAccordion == 'Service Job') {
                        expandAccordion('Service Job');
                        $scope.M_CO.DummyAccordion = '';
                    } else if ($scope.M_CO.isReload && $scope.M_CO.coHeaderRec.COType === 'Internal Service') {
                        setTimeout(function() {
                            $scope.M_CO.DummyAccordion = '';
                            expandAccordion('Service Job');
                        }, 100);
                    }
                    if (changePayingIndex) {
                        $scope.F_CO.selectJobType(changePayingIndex, changePayingSoHeaderIndex, 'TTOptionsListWithQuote');
                        changePayingIndex = null;
                        changePayingSoHeaderIndex = null;
                    }
                }
              getCustomerApprovalData(true);
      }

            function handleCreateSOHeaderResponse(serviceOrderHeaderList) {
                showTooltip('body');
              $scope.M_CO.SOHeaderList.push(serviceOrderHeaderList[$scope.M_CO.SOHeaderList.length]);
                getCustomerApprovalData();
                if (serviceOrderHeaderList.length > 0) {
                    $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeaderList[0].OrderTotal;
                    $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeaderList[0].InvoicedAmount;
                    $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeaderList[0].UninvoicedAmount;
                    $scope.M_CO.coHeaderRec.TotalPayments = serviceOrderHeaderList[0].TotalPayments;

                    var soId = $scope.M_CO.SOHeaderList[$scope.M_CO.SOHeaderList.length - 1].SOInfo.Id;
                    insertDefaultCOFormsToSpecificSection($scope.M_CO.COHeaderId, soId).then(function() {
                    getCOFormsBySectionId(soId).then(function(sectionIdToFormList) {
                      $scope.M_CO.documents.forms.so[soId] = sectionIdToFormList[soId];
                      $scope.M_CO.documents.activeForms.so[soId] = _.filter($scope.M_CO.documents.forms.so[soId], function(rec){ return rec.IsActive; });
                      showTooltip('body');
                        }, function(error) {
                          handleErrorAndExecption(error);
                        });
                    }, function(error) {
                      handleErrorAndExecption(error);
                    });
                }
                setTimeout(function() {
                    if ($scope.M_CO.SOHeaderList.length > 0) {
                        var soIndex = $scope.M_CO.SOHeaderList.length - 1;
                        $scope.F_CO.expandedSection('ServiceJob' + soIndex + '_SectionId', 'ServiceJob' + soIndex, soIndex, ($scope.F_CO.getSOPermissionType()['view']));
                    }
                }, 100);
                $scope.M_CO.isLoading = false;
            }

            function handleUpdateSOLineItemResponse(serviceOrderHeaderList) {
                $scope.F_CO.getSpecialOrdersData();
                if($scope.M_CO.editLineItemIndex == -1) {
                  $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOGridItems = serviceOrderHeaderList[0].SOGridItems;
                } else {
                  $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOGridItems[$scope.M_CO.editLineItemIndex] = serviceOrderHeaderList[0].SOGridItems[$scope.M_CO.editLineItemIndex];
                }
                $scope.M_CO.editLineItemIndex = -1;
                $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].SOInfo.Total = serviceOrderHeaderList[0].SOInfo.Total;
                $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeaderList[0].OrderTotal;
                $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeaderList[0].InvoicedAmount;
                $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeaderList[0].UninvoicedAmount;
                setTimeout(function() {
                    if ($scope.M_CO.SOHeaderList.length > 0) {
                        $scope.M_CO.expandedInnerDivFlag = false;
                        $scope.M_CO.expandedDivFlag = false;
                        if(self.arguments.innerSectionId && self.arguments.innerSectionName) {
                          $scope.F_CO.expandInnerSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_' + self.arguments.innerSectionId , 'ServiceJob' + (self.arguments.SOHeaderIndex) + '_'+ self.arguments.innerSectionName);
                        } else {
                          $scope.F_CO.expandInnerSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItemsSectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItems');
                        }
                         $scope.F_CO.expandedSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_SectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex), '', false,self.arguments.isAvoidSetFocusOnCOU);
                        
                    }
                }, 100);
                getCustomerApprovalData();
                if($scope.M_CO.isTabKeyPressed) {
                  setTimeout(function() {
                    angular.element("#autocompleteServiceJob" + self.arguments.SOHeaderIndex).focus();
                    $scope.M_CO.isTabKeyPressed = false;
                  }, 700);
                }

                $scope.M_CO.editLineItem = '';
                $scope.M_CO.isLoading = false;
                showTooltip('body');
            }

            function handleUpdateDealSOLineItemResponse(result) {
                handleUpdateSOLineItemResponse(result);
            }

            function handleRemoveDealSOItemResponse(result) {
                handleRemoveServiceOrderItemResponse(result);
            }

            function handleRemoveServiceOrderItemResponse(serviceOrderHeaderList, isDeleteFromMoveLIModal, stopLoadingIcon) {
                $scope.F_CO.getSpecialOrdersData();
                if (isDeleteFromMoveLIModal) {
                    $scope.F_CO.hideMoveLineItemModalWindowAction();
                } else {
                    $scope.F_CO.hideDeleteConfirmationPopup();
                }
                $scope.M_CO.editLineItem = '';
                setTimeout(function() {
                    var deletedElement = angular.element('#' + self.arguments.elementId);
                    if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                        deletedElement.addClass('bp-collapse-deleted-div-transition');
                    }
                }, 100);
                setTimeout(function() {
                    if(!serviceOrderHeaderList.length) {
                    $scope.M_CO.SOHeaderList.splice(self.arguments.SOHeaderIndex, 1);
                  } else {
                    $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex] = serviceOrderHeaderList[0];
                        $scope.M_CO.coHeaderRec.OrderTotal = serviceOrderHeaderList[0].OrderTotal;
                        $scope.M_CO.coHeaderRec.InvoicedAmount = serviceOrderHeaderList[0].InvoicedAmount;
                        $scope.M_CO.coHeaderRec.UninvoicedAmount = serviceOrderHeaderList[0].UninvoicedAmount;
                        $scope.M_CO.coHeaderRec.TotalPayments = serviceOrderHeaderList[0].TotalPayments;
                        setTimeout(function() {
                            if ($scope.M_CO.SOHeaderList.length > 0) {
                                $scope.M_CO.expandedInnerDivFlag = false;
                                $scope.M_CO.expandedDivFlag = false;
                                $scope.F_CO.expandInnerSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItemsSectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex) + '_JobItems');
                                $scope.F_CO.expandedSection('ServiceJob' + (self.arguments.SOHeaderIndex) + '_SectionId', 'ServiceJob' + (self.arguments.SOHeaderIndex));
                            }
                        }, 100);
                  }
                    getCustomerApprovalData();
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                    $scope.M_CO.deletableSOLI_SOHeader_Index = '';
                    $scope.M_CO.deletableSOLI_SOHeader_Id = '';
                    $scope.M_CO.deletableSOLI_SoKitHeader_Index = '';
                    $scope.M_CO.deletableSOLI_SoKitHeader_Id = '';
                    $scope.M_CO.deletableSOLI_Index = '';
                    $scope.M_CO.deletableSOLI_Id = '';
                }, 600);
                $scope.M_CO.isDeleteDisabled = false;
                if (stopLoadingIcon) {
                    $scope.M_CO.isLoading = false;
                }
            }

            function handleGetPrimaryUnitImageResponse(result) {
              if(self.arguments.gridName == 'New tradeIn') {
                var keysArray = Object.keys(result);
                if(keysArray.length > 0) {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[keysArray[0]] = result[keysArray[0]];
                }
                createTradeInUnitCardInfoPayload(self.arguments.index);
              } else if(self.arguments.gridName == 'New unit') {
                var keysArray = Object.keys(result);
                if(keysArray.length > 0) {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[keysArray[0]] = result[keysArray[0]];
                }
                createUnitCardInfoPayload(self.arguments.index);
              } else if(self.arguments.gridName == 'New SO unit') {
                var keysArray = Object.keys(result);
                if(keysArray.length > 0) {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[keysArray[0]] = result[keysArray[0]];
                }
                createInternalServiceUnitCardInfoPayload(self.arguments.index);
              } else {
                $scope.M_CO.unitIdToUnitImagesJsonMap = result;
                createUnitCardInfoPayload();
                createTradeInUnitCardInfoPayload();
                createInternalServiceUnitCardInfoPayload();
              }
            }

            function handleGetUnitImagesByUnitId(result) {
              var imageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[self.arguments.UnitId]['unitCardInfoPayload'].unitImage;
              var docId = $scope.M_CO.unitIdToUnitImagesJsonMap[self.arguments.UnitId]['DocId'];
              $scope.M_CO.currentViewingImgURL = imageURL;
              $scope.M_CO.currentViewingImgDocId = docId;
              $scope.M_CO.currentViewingUnitImageList = result;
              showTooltip('#carousel-modal-co');
              $scope.M_CO.isUnitImagesLoaded = true;
            }

            var notAllowedMove_SOStatus = 'Complete,Reviewed,Invoiced,Signed Out';

            function populateExistingSection(isMerchOptionNotAvailable) {
                $scope.M_CO.ExistingSections = [];
                if ($rootScope.GroupOnlyPermissions['Merchandise']['create/modify'] && !isMerchOptionNotAvailable) {
                    $scope.M_CO.ExistingSections.push({
                        'Name': 'Parts & accessories',
                        'Id': 'Merchandise'
                    });
                }
                if ($scope.F_CO.getSOPermissionType()['create/modify']) {
                    for (var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                        var soHeader = $scope.M_CO.SOHeaderList[i];
                        if (notAllowedMove_SOStatus.indexOf(soHeader.SOInfo.WorkStatus) === -1 && !soHeader.SOInfo.DealId) {
                            $scope.M_CO.ExistingSections.push({
                                'Name': soHeader.SOInfo.Name,
                                'Id': soHeader.SOInfo.Id
                            });
                        }
                    }
                }
            }
            $scope.F_CO.disabledApplyButtonOnMoveLineItem = function(sectionId) {
                if ($scope.M_CO.ExistingSections) {
                    for (var i = 0; i < $scope.M_CO.ExistingSections.length; i++) {
                        if ($scope.M_CO.ExistingSections.length == 1 && $scope.M_CO.ExistingSections[i].Id == sectionId) {
                            return true;
                        }
                    }
                }
            }
            $scope.M_CO.saveCoHeaderInfo = function() {
                $scope.M_CO.isLoading = true;
                var tempTransactionJSON = {};
                tempTransactionJSON.MerchandiseTransactionType = $scope.M_CO.transactionTypelabel[$scope.M_CO.selectedTransactionTypeIndex].label;
                tempTransactionJSON.MerchandiseCommitOrdercontrols = $scope.M_CO.transactionType[$scope.M_CO.transactionSelectedIndex].label
                tempTransactionJSON.COHeaderId = $scope.M_CO.COHeaderId;
                merchandiseService.saveCoHeaderInfo(angular.toJson(tempTransactionJSON)).then(function(response) {
                    $scope.M_CO.coHeaderRec.MerchandiseCommitOrdercontrols = $scope.M_CO.transactionType[$scope.M_CO.transactionSelectedIndex].label
                    $scope.M_CO.coHeaderRec.MerchandiseTransactionType = $scope.M_CO.transactionTypelabel[$scope.M_CO.selectedTransactionTypeIndex].label
                    SOHeaderService.getCOHeaderDetailsByGridName($scope.M_CO.COHeaderId, null).then(function(response) {
                        $scope.M_CO.COKHList = response.COKHList;
                        $scope.F_CO.getSpecialOrdersData();
                    }, function(error) {
                        handleErrorAndExecption(error);
                            defer.reject($translate.instant('GENERIC_ERROR'));
                        });
                    $scope.F_CO.hideChangeTransactionType();
                }, function(error) {
                    handleErrorAndExecption(error);
                        defer.reject($translate.instant('GENERIC_ERROR'));
                    });
            }

            $scope.F_CO.moveoptionListBlur = function() {
                $scope.M_CO.isMoveingOptionList = false;
                angular.element('#moveLineItem .searchResultOverlay').scrollTop(0);
            }
            $scope.F_CO.setTargetSectionId = function(section) {
                $scope.M_CO.isMoveingOptionList = false;
                $scope.M_CO.targetSectionNameForMoveAction = section.Name;
                $scope.M_CO.targetSectionIdForMoveAction = section.Id;
            }
            $scope.F_CO.openMoveLineItemModalWindowAction = function(sectionFromId, idToMove, isMerchOptionNotAvailable, event) {
                $scope.M_CO.targetSectionNameForMoveAction = '';
                $scope.M_CO.isDeleteDisabled = false;
                populateExistingSection(isMerchOptionNotAvailable);
                $scope.M_CO.sourceSectionIdForMoveAction = sectionFromId;
                $scope.M_CO.idToMove = idToMove;
                if(event) event.stopPropagation();
            }
            $scope.F_CO.hideMoveLineItemModalWindowAction = function() {
                $scope.M_CO.showMoveLineItem = false;
                angular.element("body").find('.bp-modal-backdrop').remove();
                $scope.M_CO.deletedItemGridName = '';
            }
            $scope.F_CO.moveLineItems = function() {
                $scope.M_CO.isLoading = true;
                //Check if moving labor item
                var calculateShopSupplies = false;
                var isKit = false;
                if($scope.M_CO.sourceSectionIdForMoveAction !== 'Merchandise' && $scope.M_CO.targetSectionIdForMoveAction !== 'Merchandise') {
                  for(var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                      if($scope.M_CO.SOHeaderList[i].SOInfo.Id === $scope.M_CO.sourceSectionIdForMoveAction) {
                        for(var j = 0; j < $scope.M_CO.SOHeaderList[i].SOGridItems.length; j++) {
                          var index = _.findIndex($scope.M_CO.SOHeaderList[i].SOGridItems[j].SOLIList, {
                                  'Id': $scope.M_CO.idToMove,
                                  'IsLabour': true
                              });
                        if (index > -1) {
                          calculateShopSupplies = true;
                          break;
                        } else if($scope.M_CO.SOHeaderList[i].SOGridItems[j].Id) {
                          isKit = true;
                                  calculateShopSupplies = true;
                                  break;
                              }
                        }
                      }
                      if(calculateShopSupplies) {
                        break;
                      }
                  }
                }
                SOHeaderService.moveLineItem($scope.M_CO.sourceSectionIdForMoveAction, $scope.M_CO.targetSectionIdForMoveAction, $scope.M_CO.idToMove, $scope.M_CO.COHeaderId).then(function(successfulSearchResult) {
                    if(calculateShopSupplies) {
                      if(isKit) {
                        $scope.F_CO.calculateShopSupplies($scope.M_CO.sourceSectionIdForMoveAction, $scope.M_CO.targetSectionIdForMoveAction);
                      } else {
                        $scope.F_CO.calculateShopSupplies($scope.M_CO.sourceSectionIdForMoveAction, $scope.M_CO.targetSectionIdForMoveAction);
                      }
                      var successJson = {
                                'type': 'getCOHeaderDetailsByGridName',
                            };
                    } else {
                      var successJson = {
                            'type': 'getCOHeaderDetailsByGridName',
                            'callback': getSOHeaderDetails,
                            'callbackParam': {
                                'isDealCallback': false
                            }
                        };
                    }
                    SOHeaderService.getCOHeaderDetailsByGridName($scope.M_CO.COHeaderId, null).then(new success(successJson).handler, new error().handler);
                    $scope.F_CO.hideMoveLineItemModalWindowAction();
                });
            }

            $scope.F_CO.calculateShopSupplies = function(srcSOId, targetId) {
              SOHeaderService.calculateShopSupplies(srcSOId).then(function(response) {
                if(targetId) {
                  SOHeaderService.calculateShopSupplies(targetId).then(function(response) {
                      $scope.F_CO.callGetSOHeaderDetails(false);
                      }, function(error) {
                        handleErrorAndExecption(error);
                            defer.reject($translate.instant('GENERIC_ERROR'));
                        });
                } else {
                  $scope.F_CO.callGetSOHeaderDetails(false);
                }
              }, function(error) {
                handleErrorAndExecption(error);
                    defer.reject($translate.instant('GENERIC_ERROR'));
                });
            }

            function handleDeleteDealCOLIResponse(result, stopLoadingIcon) {
                $scope.F_CO.getSpecialOrdersData();
                var deletedElement = angular.element('#' + self.arguments.elementId);
                if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                    deletedElement.addClass('bp-collapse-deleted-div-transition');
                }
                getCustomerApprovalData();
                setTimeout(function() {
                    $scope.M_CO.Deal.DealFulfillmentSectionObj = result.DealFulfillmentSectionObj;
                    $scope.M_CO.Deal.DealUnresolvedFulfillmentList = result.DealUnresolvedFulfillmentList;
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                }, 500);
               
                resetDeleteOrMoveLIModalVars();
                $scope.F_CO.hideDeleteConfirmationPopup();
                $scope.M_CO.editLineItem = '';
                showTooltip('body');
                if (stopLoadingIcon) {
                    $scope.M_CO.isLoading = false;
                }
            }

            function handleDeleteCOLineItemResponse(CoHeaderList, isDeleteFromMoveLIModal, stopLoadingIcon) {
                $scope.F_CO.getSpecialOrdersData();
                var deletedElement = angular.element('#' + self.arguments.elementId);
                if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                    deletedElement.addClass('bp-collapse-deleted-div-transition');
                }
                setTimeout(function() {
                    $scope.M_CO.COKHList = CoHeaderList.COKHList;
                    $scope.M_CO.coHeaderRec = CoHeaderList.coHeaderRec;
                    $scope.M_CO.coHeaderRec.MerchandiseTotal = CoHeaderList.coHeaderRec.MerchandiseTotal;
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                }, 500);
                getCustomerApprovalData();
              resetDeleteOrMoveLIModalVars();
                
                if (isDeleteFromMoveLIModal) {
                    $scope.F_CO.hideMoveLineItemModalWindowAction();
                } else {
                    $scope.F_CO.hideDeleteConfirmationPopup();
                }
                $scope.M_CO.editLineItem = '';
                $scope.M_CO.isDeleteDisabled = false;
                if (stopLoadingIcon) {
                    $scope.M_CO.isLoading = false;
                }
            }

            function handleRemoveOptionFeeResponse(result) {
                $scope.F_CO.hideDeleteConfirmationPopup();
                $scope.M_CO.editLineItem = '';
                setTimeout(function() {
                    var deletedElement = angular.element('#' + self.arguments.elementId);
                    if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                        deletedElement.addClass('bp-collapse-deleted-div-transition');
                    }
                }, 100);
                setTimeout(function() {
                    $scope.M_CO.Deal.UnitList[self.arguments.dealItemIndex] = result;
                    setTimeout(function() {
                        if ($scope.M_CO.Deal.UnitList.length > 0) {
                            $scope.M_CO.expandedInner2DivFlag = false;
                            $scope.M_CO.expandedInnerDivFlag = false;
                            $scope.M_CO.expandedDivFlag = false;
                            $scope.F_CO.expandInner2Section('Deal_DU' + (self.arguments.dealItemIndex) + '_UISectionId', 'Deal_DU' + (self.arguments.dealItemIndex) + '_UI');
                            $scope.F_CO.expandInnerSection('Deal_DU' + (self.arguments.dealItemIndex) + '_SectionId', 'Deal_DU' + (self.arguments.dealItemIndex));
                            $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                        }
                    }, 100);
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                    $scope.M_CO.deletedItemName = '';
                    $scope.M_CO.deletedItemGridName = '';
                    $scope.M_CO.deletableOptionFee_KitId = '';
                    $scope.M_CO.deletableOptionFee_Id = '';
                    $scope.M_CO.deletableOptionFee_DealItemIndex = '';
                    $scope.M_CO.deletableOptionFee_DealItemId = '';
                    $scope.M_CO.deletableElementId = '';
                }, 600);
            }

            function handleRemoveHoursLoggedItemResponse(hourLogList) {
                $scope.F_CO.hideDeleteConfirmationPopup();
                $scope.M_CO.editLineItem = '';
                setTimeout(function() {
                    var deletedElement = angular.element('#' + self.arguments.elementId);
                    if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                        deletedElement.addClass('bp-collapse-deleted-div-transition');
                    }
                }, 100);
                setTimeout(function() {
                    $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].HoursLoggedList = hourLogList;
                    $scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].HoursLoggedListCopy = angular.copy($scope.M_CO.SOHeaderList[self.arguments.SOHeaderIndex].HoursLoggedList);
                    showTooltip('body');
                    if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                        $scope.$apply(); //TODO
                    }
                    $scope.M_CO.deletedItemName = '';
                    $scope.M_CO.deletedItemGridName = '';
                    $scope.M_CO.deletableHoursLogged_SOHeader_Index = '';
                    $scope.M_CO.deletableHoursLogged_SOHeader_Id = '';
                    $scope.M_CO.deletableHoursLogged_Index = '';
                    $scope.M_CO.deletableHoursLogged_Id = '';
                }, 600);
            }

            function handleSaveDealInfoResponse(result, stopLoadingIcon) {
                $scope.M_CO.Deal.DealInfo = result;
                showTooltip('body');
                if (stopLoadingIcon) {
                    $scope.M_CO.isLoading = false;
                }
            }

            function handleGetListOfFinanceCompanyResponse(result) {
                $scope.M_CO.DealFinance.FinanceCompanyList = result;
                if ($scope.M_CO.Deal.DealInfo != undefined && $scope.M_CO.Deal.DealInfo.DealType == 'Financed' && $scope.M_CO.DealFinance.FinanceCompanyList.length == 1) {
                    $scope.M_CO.Deal.DealFinanceObj.DealId = $scope.M_CO.Deal.DealInfo.Id;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyName = result[0].Name;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyPhone = result[0].Phone;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyEmail = result[0].Email;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyAccountNumber = result[0].AccountNumber;
                    $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyId = result[0].Id;
                    $scope.F_CO.saveFinancingInfo();
                } else {
                    $scope.M_CO.isLoading = false;
                }
            }

            function handleGetListOfFIproductsResponse(result) {
                $scope.M_CO.isLoading = false;
                $scope.M_CO.DealFinance.FIProductList = result;
                setTimeout(function() {
                    $scope.F_CO.setFocusOnInput('DealFinance');
                }, 100);
            }
            function handleGetCOHeaderDetailsByGridNameResponse(coHeaderResult) {
                showTooltip('body');
                $scope.M_CO.CustomerCardInfo = coHeaderResult.CardInfo;
                $scope.M_CO.coHeaderRec = coHeaderResult.coHeaderRec;
                $scope.M_CO.IsShowMerchandiseSection = !coHeaderResult.coHeaderRec.HideMerchandiseSection;
                $scope.M_CO.StampDutyRate = coHeaderResult.StampDutyRate;
                $scope.M_CO.IsTaxIncludingPricing = coHeaderResult.IsTaxIncludingPricing;
                $scope.M_CO.IsLoadFinancingSection = coHeaderResult.IsLoadFinancingSection;
                $scope.M_CO.COHeaderId = coHeaderResult.coHeaderRec.COHeaderId;
                $scope.M_CO.COInvoiceHistoryList = coHeaderResult.COInvoiceHistoryList;
                $scope.M_CO.COKHList = coHeaderResult.COKHList;
                checkTransactionTypeDefaultValue();
                if($scope.M_CO.AppointmentId) {
                  var addServiceJobForJobSchedulingJson = {
                      COHeaderId: $scope.M_CO.COHeaderId,
                      Id : $scope.M_CO.AppointmentId
                    }
                  SOHeaderService.addServiceJobForJobScheduling(angular.toJson(addServiceJobForJobSchedulingJson)).then(function () {
                    $scope.M_CO.AppointmentId = '';
                    $rootScope.CustomerOrder_V2Parms = {};

                  }, new error().handler);
                }
                $scope.F_CO.getSpecialOrdersData();
                if (coHeaderResult.DepositList) {
                    $scope.M_CO.DepositList = coHeaderResult.DepositList;
                    $scope.F_CO.Deposit.calculateDepositAmount();
                } else {
                    $scope.M_CO.DepositList = [];
                }
                $scope.CheckoutInfoModel.InvoicePaymentList = coHeaderResult.InvoicePaymentList;
                if ($scope.M_CO.CashPaymentRoundingCentValue == null || $scope.M_CO.CashPaymentRoundingCentValue == "" || $scope.M_CO.CashPaymentRoundingCentValue == undefined) {
                    $scope.M_CO.CashPaymentRoundingCentValue = 1;
                }
                $scope.M_CO.CashPaymentRoundingCentValue = parseInt($scope.M_CO.CashPaymentRoundingCentValue);
                $scope.M_CO.sellingGroup = $scope.M_CO.coHeaderRec.SellingGroup;
                if ($scope.M_CO.coHeaderRec.COType === 'Internal Service' || $scope.M_CO.coHeaderRec.OrderStatus === 'Quote') {
                    changePrintDialogTabView('Receipts','onlyInvoicePreview');
                }
                $scope.F_CO.closeCheckOutPopup();
                $scope.M_CO.showChangeModalWindow = false;
                setTimeout(function() {
                    if (self.arguments.calleeMethodName === 'doCheckout' && $scope.M_CO.COInvoiceHistoryList.length > 0) {
                        if (coHeaderResult.COInvoiceHistoryList != null && coHeaderResult.COInvoiceHistoryList.length > 0 && !isBlankValue($scope.CheckoutInfoModel.activeInvHeaderId)) {
                            if ($scope.M_CO.isPrintInvoice) {
                              $scope.M_CO.showInvoicePreviewPopup = true;
                                $scope.F_CO.showPrintpopUpModalWindow($scope.CheckoutInfoModel.activeInvHeaderId);
                            }
                            if ($scope.M_CO.isEmailInvoice) {
                                $scope.F_CO.openEmailPopUp($scope.CheckoutInfoModel.activeInvHeaderId);
                            }
                        }
                        $scope.F_CO.expandedSection('InvoiceHistoryId', 'InvoiceHistory', '', $rootScope.GroupOnlyPermissions['Customer invoicing']['view']);
                        $scope.M_CO.isLoading = false;
                    }
                }, 100);
                showTooltip('body');
            }

            function handleGetDealDetailsResponse(result) {
                $scope.M_CO.dealStockIdValueJson = [];
                $scope.M_CO.dealStockIdValue = [];
                if (self.arguments.gridName == 'dealUnresolvedFulfillmentSection') {
                    $scope.M_CO.Deal.DealUnresolvedFulfillmentList = result;
                } else {
                    $scope.M_CO.Deal = result;
                    if($scope.M_CO.Deal.DealInfo) {
                      handleGetDealTotalInfoResponse($scope.M_CO.Deal.DealInfo);
                      $scope.F_CO.getBussinessProfileData();
                    }

                    $scope.M_CO.isLoading = false;
                    $scope.M_CO.isCompleteLoad = true;

                    if($scope.M_CO.Deal.DealFinanceObj){
                        $scope.M_CO.Deal.DealFinanceObj.InterestRate = $scope.M_CO.Deal.DealFinanceObj.InterestRate ? $scope.M_CO.Deal.DealFinanceObj.InterestRate.toFixed(2) : 0.00;
                        $scope.M_CO.Deal.DealFinanceObj.DownPayment = $scope.M_CO.Deal.DealFinanceObj.DownPayment ? $scope.M_CO.Deal.DealFinanceObj.DownPayment.toFixed(2) : null ;
                        $scope.M_CO.Deal.DealFinanceObj.FinanceCommission = $scope.M_CO.Deal.DealFinanceObj.FinanceCommission ? $scope.M_CO.Deal.DealFinanceObj.FinanceCommission.toFixed(2) : null ;
                      if($scope.M_CO.Deal.DealFinanceObj.CoBuyerId) {
                        getCoBuyerDetails($scope.M_CO.Deal.DealFinanceObj.CoBuyerId);
                        $scope.M_CO.Deal.showSearchCoBuyerDiv = true;
                      }
                    }

                    // Get Applicable Sales Tax List
                    getApplicableTaxList().then(function() {
                    }, function(error) {
                      handleErrorAndExecption(error);
                    });

                    getRelatedCODataAsynchronously();

                    if ($scope.M_CO.DummyAccordion == 'Unit Deal') {
                        //$scope.F_CO.addUnitToDeal();
                        $scope.M_CO.DummyAccordion = '';
                        expandAccordion('Unit Deal');
                    } else if (self.arguments.expandSJInvoiceSection || (self.arguments.expandInvoiceSection && !$scope.F_CO.isDealMerchandiseContainInvoicableItem())) {
                        $scope.F_CO.expandedSection('InvoiceHistoryId', 'InvoiceHistory', '', $rootScope.GroupOnlyPermissions['Customer invoicing']['view']);
                    }
                    $scope.F_CO.StockUnitMap();
                    getDataForTradeInsCouList();
                    getSalesPersonList();
                    getPrimaryUnitImage($scope.M_CO.COHeaderId);
                    showPartsSmartItemsNotInserted();
                }
                showTooltip('body');
            }

            function handleGetDealTotalInfoResponse(dealInfo) {
                $scope.M_CO.Deal.DealInfo.UnitsTotal = dealInfo.UnitsTotal;
                $scope.M_CO.Deal.DealInfo.PartsAndLabourTotals = dealInfo.PartsAndLabourTotals;
                $scope.M_CO.Deal.DealInfo.FeesTotal = dealInfo.FeesTotal;
                $scope.M_CO.Deal.DealInfo.OtherProductsTotal = dealInfo.OtherProductsTotal;
                $scope.M_CO.Deal.DealInfo.StampDutyTotal = dealInfo.StampDutyTotal;
                $scope.M_CO.Deal.DealInfo.SubTotal = dealInfo.SubTotal;
                $scope.M_CO.Deal.DealInfo.Total = dealInfo.Total;
                $scope.M_CO.Deal.DealInfo.SalesTaxesTotal = dealInfo.SalesTaxesTotal;
                $scope.M_CO.Deal.DealInfo.TradeInsTotal = dealInfo.TradeInsTotal;
                $scope.M_CO.Deal.DealInfo.LienPayoutTotal = dealInfo.LienPayoutTotal;
                $scope.M_CO.Deal.DealInfo.FIProductTaxTotal = dealInfo.FIProductTaxTotal;
                $scope.M_CO.Deal.DealInfo.FIProductTotal = dealInfo.FIProductTotal;
                $scope.M_CO.coHeaderRec.OrderTotal = dealInfo.OrderTotal;
                $scope.M_CO.coHeaderRec.InvoicedAmount = dealInfo.InvoicedAmount;
                $scope.M_CO.coHeaderRec.UninvoicedAmount = dealInfo.UninvoicedAmount;
                $scope.M_CO.SalesPerson.TechnicianName = dealInfo.Salesperson;
            }

            function handleCreateUnitDealResponse(Deal) {
                showTooltip('body');
                $scope.M_CO.Deal = Deal;
                if($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id) {
                  $scope.M_CO.SalesPerson.TechnicianName = $scope.M_CO.Deal.DealInfo.Salesperson;
                  insertDefaultCOFormsToSpecificSection($scope.M_CO.COHeaderId, $scope.M_CO.Deal.DealInfo.Id).then(function() {
                    getCOFormsBySectionId($scope.M_CO.Deal.DealInfo.Id).then(function(sectionIdToFormList) {
                      $scope.M_CO.documents.forms.deal = sectionIdToFormList;
                      $scope.M_CO.documents.activeForms.deal = _.filter($scope.M_CO.documents.forms.deal, function(rec){ return rec.IsActive; });
                      showTooltip('body');
                        }, function(error) {
                          handleErrorAndExecption(error);
                        });
                    }, function(error) {
                      handleErrorAndExecption(error);
                    });
                }
                //$scope.F_CO.addUnitToDeal();
                getCustomerApprovalData();
                getSalesPersonList();
                $scope.M_CO.isLoading = false;
            }

            function handleSaveTemporaryUnitResponse(Deal) {
                $scope.M_CO.Deal = Deal;
                var recentlyAddedUnitIndex = $scope.M_CO.Deal.UnitList.length - 1;
                if (recentlyAddedUnitIndex != -1) {
                    setTimeout(function() {
                        if (self.arguments.actionName === 'replaceUnit') {
                            $scope.M_CO.expandedInnerDivFlag = false;
                            $scope.M_CO.expandedInner2DivFlag = false;
                        }
                        $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                        $scope.F_CO.expandInnerSection('Deal_DU' + recentlyAddedUnitIndex + '_SectionId', 'Deal_DU' + recentlyAddedUnitIndex);
                        $scope.F_CO.expandInner2Section('Deal_DU' + recentlyAddedUnitIndex + '_InfoSectionId', 'Deal_DU' + recentlyAddedUnitIndex + '_Info');
                    }, 100);
                }
                $scope.M_CO.isLoading = false;
            }

            function handleAddStockUnitResponse(Deal) {
                $scope.M_CO.Deal = Deal;
                if (self.arguments.unitIndex != undefined) {
                  if(self.arguments.isGetUnitImageData && Deal.UnitList[self.arguments.unitIndex].DealItemObj.UnitId) {
                    getPrimaryUnitImage(Deal.UnitList[self.arguments.unitIndex].DealItemObj.UnitId, 'New unit', self.arguments.unitIndex);
                  }
                    setTimeout(function() {
                        $scope.M_CO.expandedDivFlag = false;
                        $scope.M_CO.expandedInnerDivFlag = false;
                        $scope.M_CO.expandedInner2DivFlag = false;
                        $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                        $scope.F_CO.expandInnerSection('Deal_DU' + self.arguments.unitIndex + '_SectionId', 'Deal_DU' + self.arguments.unitIndex);
                        $scope.F_CO.expandInner2Section('Deal_DU' + self.arguments.unitIndex + '_InfoSectionId', 'Deal_DU' + self.arguments.unitIndex + '_Info');
                    }, 100);
                }
                $scope.M_CO.isReplaceUnit = false;
                $scope.M_CO.isLoading = false;
            }

            function handleSaveDealFAndIProductResponse(result) {
                if (self.arguments.isAddMode) {
                    $scope.M_CO.Deal.DealFinanceObj.FIProductList.push(result);
                    var IndexVal = $scope.M_CO.Deal.DealFinanceObj.FIProductList.length - 1;
                    $scope.M_CO.editLineItem = 'f_i_product_' + IndexVal;
                    setTimeout(function() {
                        angular.element('#f_i_product_' + IndexVal + '_Price').focus();
                    }, 100);

                    // Get CO Forms if Vedor Product is added
                  getCOFormsBySectionId($scope.M_CO.Deal.DealFinanceObj.Id).then(function(sectionIdToFormList) {
                  $scope.M_CO.documents.forms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id] = sectionIdToFormList[$scope.M_CO.Deal.DealFinanceObj.Id];
                  $scope.M_CO.documents.activeForms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id] = _.filter($scope.M_CO.documents.forms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id], function(rec){ return rec.IsActive; });
                  showTooltip('body');
                    }, function(error) {
                      handleErrorAndExecption(error);
                    });
                } else if (!isNaN(self.arguments.IndexVal)) {
                    $scope.M_CO.editLineItem = '';
                    $scope.M_CO.Deal.DealFinanceObj.FIProductList[self.arguments.IndexVal] = result;
                }
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_CO.saveFinancingInfo();
                $scope.F_CO.DealFinance.getFIProductTotal();
                $scope.M_CO.isLoading = false;
                showTooltip('body');
            }

            function handleRemoveUnitFromDealResponse(Deal, unitListLength, UnitId) {
                if (unitListLength == 1 && UnitId == null) { // if only 1 temporary unit, remove deal also
                    $scope.M_CO.Deal = Deal;
                    $scope.M_CO.isLoading = false;
                    if ($scope.M_CO.Deal && $scope.M_CO.Deal.TradeInsList && $scope.M_CO.Deal.TradeInsList.length > 0) { // only deletes the unit from deal
                        $scope.F_CO.collapseInnerSection(); //Collapse complete Unit section and reset all flags and ids for Unit section transition
                    } else { // delete complete deal
                        $scope.F_CO.collapseSection(); //Collapse complete deal section and reset all flags and ids for deal section transition
                    }
                } else if (unitListLength == 1 && UnitId != null) { // if if one data item , of stock type, replace it with empty teporary unit card
                    $scope.F_CO.addUnitToDeal('replaceUnit');
                } else { // remove stock unit/temp unit and repopulate model for ng repeat
                    $scope.M_CO.Deal = Deal;
                    $scope.M_CO.isLoading = false;
                    $scope.F_CO.collapseInnerSection(); //Collapse complete Unit section and reset all flags and ids for Unit section traisition
                }
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_CO.closeRemoveUnitFromDealModal();
            }

            function handleUpdateTradeInResponse(TradeIn, tradeInIndex) {
              if (tradeInIndex != undefined) {
                  if(!self.arguments.isStopDataBind) {
                    $scope.M_CO.Deal.TradeInsList[tradeInIndex] = TradeIn;
                  }
                    if(self.arguments.isGetUnitImageData && $scope.M_CO.TradeIn.selectedUnitId) {
                      getPrimaryUnitImage($scope.M_CO.Deal.TradeInsList[tradeInIndex].UnitId, 'New tradeIn', tradeInIndex);
                    }
                } else {
                  if(!self.arguments.isStopDataBind) {
                    $scope.M_CO.Deal.TradeInsList[$scope.M_CO.Deal.TradeInsList.length] = TradeIn;
                  }
                    setTimeout(function() {
                        $scope.F_CO.expandInnerSection('Deal_TradeInSectionId' + ($scope.M_CO.Deal.TradeInsList.length - 1), 'Deal_TradeIn' + ($scope.M_CO.Deal.TradeInsList.length - 1));
                        $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                    }, 100);
                }
                getDataForTradeInsCouList();
                if ($scope.M_CO.TradeIn.COUList.length == 1) {
                    $scope.F_CO.TradeIn.selectedUnit($scope.M_CO.TradeIn.COUList[0]);
                } else {
                    $scope.M_CO.TradeIn.selectedUnitName = '';
                }
                $scope.F_CO.updateDealSummaryTotals();
                $scope.M_CO.isLoading = false;
            }

            function handleRemoveTradeItemResponse(successResult) {
                $scope.M_CO.Deal = successResult;
                $scope.M_CO.isLoading = false;
                getDataForTradeInsCouList();
                if ($scope.M_CO.TradeIn.COUList.length == 1) {
                    $scope.F_CO.TradeIn.selectedUnit($scope.M_CO.TradeIn.COUList[0]);
                } else {
                    $scope.M_CO.TradeIn.selectedUnitName = '';
                }
                $scope.F_CO.updateDealSummaryTotals();
                $scope.F_CO.collapseInnerSection(); //Collapse complete Trade in section and reset all flags and ids for Trade in section traisition
            }

            function handleStockInCOUResponse(successResult) {
              $scope.M_CO.isLoading = true;
              if($scope.M_CO.coHeaderRec.CustomerId) {
                getActiveCOUList();
              }
            }

            $scope.F_CO.openAddEditTempUnitPopup = function(sectionId, sectionIndex, sectionName, unitType) {
                var AddEditTempUnitParams = {
                    SectionId: sectionId,
                    SectionIndex: sectionIndex,
                    SectionName: sectionName,
                    UnitType: unitType
                };
                loadState($state, 'CustomerOrder_V2.AddEditTempUnit', {
                    AddEditTempUnitParams: AddEditTempUnitParams
                });
            }
            $scope.M_CO.ServiceWorksheetPrintDetail;
            $scope.M_CO.ServiceTypeWorksheet;
            $scope.M_CO.ServiceTypeJobReview;

            function handleGetServiceWorksheetPrintDetail(result) {
                $scope.M_CO.printDocumentTypeList[1].PrintItems = [];
                $scope.M_CO.ServiceWorksheetPrintDetail = result;
                $scope.M_CO.ServiceTypeWorksheet = (angular.copy(result));
                $scope.M_CO.ServiceTypeJobReview = (angular.copy(result));
                angular.forEach($scope.M_CO.ServiceWorksheetPrintDetail, function(value, key) {
                    angular.forEach(value.SOInfoWrapperList, function(value, key) {
                        var obj = {
                            Label: value.Name,
                            IsSelected: false,
                            Id: value.SOHeaderId
                        };
                        $scope.M_CO.printDocumentTypeList[1].PrintItems.push(obj);
                    });
                });
                $scope.F_CO.setCurrentActiveTab($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name);
            }
        }

        function getRelatedCODataAsynchronously() {
          // Get section name to Active form count
            getActiveFormsCount().then(function(result) {
              $scope.M_CO.documents.sectionNameToActiveFormCountMap = result;
            }, function(error) {
              handleErrorAndExecption(error);
            });

            // Get CO Forms
            getCOFormsBySectionId($scope.M_CO.COHeaderId).then(function(sectionIdToFormList) {
              if($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id) {
                $scope.M_CO.documents.forms.deal[$scope.M_CO.Deal.DealInfo.Id] = sectionIdToFormList[$scope.M_CO.Deal.DealInfo.Id];
                $scope.M_CO.documents.activeForms.deal[$scope.M_CO.Deal.DealInfo.Id] = _.filter($scope.M_CO.documents.forms.deal[$scope.M_CO.Deal.DealInfo.Id], function(rec){ return rec.IsActive; });
              }

              if($scope.M_CO.Deal && $scope.M_CO.Deal.DealFinanceObj && $scope.M_CO.Deal.DealFinanceObj.Id) {
                $scope.M_CO.documents.forms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id] = sectionIdToFormList[$scope.M_CO.Deal.DealFinanceObj.Id];
                $scope.M_CO.documents.activeForms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id] = _.filter($scope.M_CO.documents.forms.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id], function(rec){ return rec.IsActive; });
              }

              if($scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length) {
                angular.forEach($scope.M_CO.SOHeaderList, function(soHeader) {
                  $scope.M_CO.documents.forms.so[soHeader.SOInfo.Id] = sectionIdToFormList[soHeader.SOInfo.Id];
                  $scope.M_CO.documents.activeForms.so[soHeader.SOInfo.Id] = _.filter($scope.M_CO.documents.forms.so[soHeader.SOInfo.Id], function(rec){ return rec.IsActive; });
                    });
              }
            showTooltip('body');
            }, function(error) {
              handleErrorAndExecption(error);
            });


            // Get CO Attachment Files
            getCOAttachmentsBySectionId($scope.M_CO.COHeaderId).then(function(attachmentList) {
              if($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id) {
                $scope.M_CO.documents.attachments.deal[$scope.M_CO.Deal.DealInfo.Id] = attachmentList[$scope.M_CO.Deal.DealInfo.Id];
              }

              if($scope.M_CO.Deal && $scope.M_CO.Deal.DealFinanceObj && $scope.M_CO.Deal.DealFinanceObj.Id) {
                $scope.M_CO.documents.attachments.dealFinance[$scope.M_CO.Deal.DealFinanceObj.Id] = attachmentList[$scope.M_CO.Deal.DealFinanceObj.Id];
              }

              if($scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length) {
                angular.forEach($scope.M_CO.SOHeaderList, function(soHeader) {
                  $scope.M_CO.documents.attachments.so[soHeader.SOInfo.Id] = attachmentList[soHeader.SOInfo.Id];
                    });
              }
            showTooltip('body');
            }, function(error) {
              handleErrorAndExecption(error);
            });

      // Get CO Internal Comments
            getInternalCommentList($scope.M_CO.COHeaderId).then(function() {
              showTooltip('body');
            }, function(error) {
              handleErrorAndExecption(error);
            });

            // Get CO Events/Appointments
            getAppointmentsBySectionId($scope.M_CO.COHeaderId).then(function(sectionIdToAppointmentList) {
              if($scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length) {
                angular.forEach($scope.M_CO.SOHeaderList, function(soHeader) {
                  $scope.M_CO.soAppointments[soHeader.SOInfo.Id] = sectionIdToAppointmentList[soHeader.SOInfo.Id];
                    });
              }
              showTooltip('body');
            }, function(error) {
              handleErrorAndExecption(error);
            });
        }

        $scope.F_CO.showDeleteIconOnLineItem = function() {
          if (( $scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index] && $scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOGridItems[$scope.M_CO.deletableSOLI_SoKitHeader_Index]
               && $scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOGridItems[$scope.M_CO.deletableSOLI_SoKitHeader_Index].SOLIList[$scope.M_CO.deletableSOLI_Index]
               && $scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOGridItems[$scope.M_CO.deletableSOLI_SoKitHeader_Index].SOLIList[$scope.M_CO.deletableSOLI_Index].IsSublet)
            && ($scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOGridItems[$scope.M_CO.deletableSOLI_SoKitHeader_Index].SOLIList[$scope.M_CO.deletableSOLI_Index].POStatus == 'Received'
            || $scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOGridItems[$scope.M_CO.deletableSOLI_SoKitHeader_Index].SOLIList[$scope.M_CO.deletableSOLI_Index].POStatus == 'On Order')) {
              $scope.M_CO.isDeleteDisabled = true;
          } else {
            $scope.M_CO.isDeleteDisabled = false;
          }
        }

        $scope.M_CO.isWorksheetSelected = false;
        $scope.M_CO.isJobReviewSelected = false;
        $scope.F_CO.deselectValue = function() {
            if ($scope.M_CO.isJobReviewSelected) {
                angular.forEach($scope.M_CO.ServiceTypeWorksheet, function(value, key) {
                    angular.forEach(value.SOInfoWrapperList, function(value, key) {
                        value.IsSOHeaderSelected = false;
                    });
                });
            } else if ($scope.M_CO.isWorksheetSelected) {
                angular.forEach($scope.M_CO.ServiceTypeJobReview, function(value, key) {
                    angular.forEach(value.SOInfoWrapperList, function(value, key) {
                        value.IsSOHeaderSelected = false;
                    });
                });
            }
        }
        $scope.F_CO.setFlagOnTabForBlurHandling = function(event) {
          if(event.type == "keydown" && ((event.shiftKey && event.keyCode == 9) || (event.keyCode == 9))) {
            $scope.M_CO.isTabKeyPressed = true;
          }
        }

        function bindAddCustomerResponseData(customerData) {
          $scope.M_CO.CustomerCardInfo = customerData.CardInfo;
            $scope.M_CO.coHeaderRec = customerData.coHeaderRec;
            $scope.M_CO.isChangeCustomer = false;
            getSOMasterData();
            if (selectedCustomerWithCOU) {
                loadState($state, 'CustomerOrder_V2', {
                    Id: $scope.M_CO.COHeaderId
                });
                selectedCustomerWithCOU = false;
            }
            $scope.M_CO.isReload = false;

            // Update All CO Appointments on change customer
            if(Object.getOwnPropertyNames($scope.M_CO.soAppointments).length > 0) {
              updateAppointmentsOnCustomerOrSOFieldsChange($scope.M_CO.COHeaderId, 'All_SO');
            }
        }
        
      $scope.F_CO.selectCashDrawer = function(cashDrawerRec) {
          $scope.M_CO.cashDrawerName = cashDrawerRec.CashDrawerName;  
          $scope.M_CO.cashDrawerId = cashDrawerRec.Id;
          $scope.M_CO.showCashDrawerList = false;
          $scope.F_CO.hideDropdown();
        }

        $scope.F_CO.hideChangeCashDrowerModalWindow = function() {
          $scope.M_CO.showChangeModalWindow  = false;
          $scope.F_CO.hidereverseCancelModalWindow();
           $scope.M_CO.selectedcashDrawer = $cookieStore.get($scope.M_CO.uuid);
           $scope.M_CO.cashDrawerName = $cookieStore.get($scope.M_CO.uuid);  
         
           var index = _.findIndex($scope.M_CO.cashDrawerList, {
                "CashDrawerName": $scope.M_CO.selectedcashDrawer
            });
           if(index != -1) {
            $scope.M_CO.selectedcashDrawerId = $scope.M_CO.cashDrawerList[index].Id;
            $scope.M_CO.cashDrawerId = $scope.M_CO.cashDrawerList[index].Id;
           }
            
        }
        function loadAllCashDrawer() {
           cashDrawerService.getActiveCashDrawerList().then(function(result) {
            $scope.M_CO.cashDrawerList = result;
            
            var storeCashDrawerName = $cookieStore.get(new DeviceUUID().get());
            var index = _.findIndex($scope.M_CO.cashDrawerList, {
                "CashDrawerName": storeCashDrawerName
            });
            if(index == -1 && $scope.M_CO.cashDrawerList.length > 1) {
              $scope.M_CO.selectedcashDrawer = '';
              $scope.M_CO.selectedcashDrawerId = '';
              
              if(storeCashDrawerName) {
                $scope.M_CO.cashDrawerHeaderText = true;
              } else {
                $scope.M_CO.cashDrawerHeaderText = false;
              }
             // $cookieStore.put(new DeviceUUID().get(), '');

            } else if ($scope.M_CO.cashDrawerList.length == 1) {
               $cookieStore.put($scope.M_CO.uuid, $scope.M_CO.cashDrawerList[0].CashDrawerName);
                $scope.M_CO.cashDrawerId = $scope.M_CO.cashDrawerList[0].Id;
                $scope.M_CO.selectedcashDrawer =  $scope.M_CO.cashDrawerList[0].CashDrawerName;
                $scope.M_CO.showAssignCashDrawerModalWindow = false;
                $scope.M_CO.selectedcashDrawerId = $scope.M_CO.cashDrawerId; 
                 var loggedInDeviceJson = {
                  UUID : $scope.M_CO.uuid,
                  CashDrawerId : $scope.M_CO.cashDrawerId
                 }  
                 if(!loggedInDeviceJson.CashDrawerId) {
                    $scope.M_CO.isErrorCashDrawer = true;
                  return;
                 }
                  cashDrawerService.saveDeviceInfo(angular.toJson(loggedInDeviceJson)).then(function(result) {
                   }, function(error) {
                    $scope.M_CO.isLoading = false;
                    Notification.error($translate.instant('GENERIC_ERROR'));
                });
            }
             else {
              $scope.M_CO.cashDrawerHeaderText = false;
            }
            getDeviceIdOnLoad();
            }, function(error) {
              $scope.M_CO.isLoading = false;
              Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }

        $scope.F_CO.setFocusOnInput = function(elementId) {
            angular.element("#" + elementId).focus();
        }
        $scope.F_CO.setBooleansForService = function(isWorksheet, isJobReview) {
            $scope.M_CO.isWorksheetSelected = isWorksheet;
            $scope.M_CO.isJobReviewSelected = isJobReview;
        }
        $scope.F_CO.worksheetIsSelected = function(index, soHeaderId) {
            $scope.F_CO.setBooleansForService(true, false);
            $scope.F_CO.deselectValue();
            for (var i = 0; i < $scope.M_CO.ServiceTypeWorksheet.length; i++) {
                for (var k = 0; k < $scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList.length; k++) {
                    if ($scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList[k].SOHeaderId == soHeaderId) {
                        $scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList[k].IsSOHeaderSelected = !($scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList[k].IsSOHeaderSelected);
                        for (var j = 0; j < $scope.M_CO.printDocumentTypeList[1].PrintItems.length; j++) {
                            if ($scope.M_CO.printDocumentTypeList[1].PrintItems[j].Id == soHeaderId) {
                                $scope.M_CO.printDocumentTypeList[1].PrintItems[j].IsSelected = $scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList[k].IsSOHeaderSelected;
                            }
                        }
                    }
                }
            }
        }
        $scope.M_CO.InvoicingOptionList = [{
            label: 'Invoice'
        }, {
            label: 'Do Not Invoice'
        }]
        
        $scope.F_CO.hideErrorCashDrawer = function () {
          angular.element('#ErrorCashDrawerModalWindow').modal('hide');
          $scope.M_CO.isComingFromAddDeposit = false;
        $scope.M_CO.isComingFromReverseDeposit = false;
        }

        $scope.F_CO.hideChangeCashDrawerpopup = function () {

          $scope.M_CO.showAssignCashDrawerModalWindow = false;
        }
        
    $scope.F_CO.saveDeviceInfo = function() {
           $cookieStore.put($scope.M_CO.uuid, $scope.M_CO.selectedcashDrawer);
           var loggedInDeviceJson = {
            UUID : $scope.M_CO.uuid,
            CashDrawerId : $scope.M_CO.cashDrawerId
           }  
           if(!loggedInDeviceJson.CashDrawerId) {
              $scope.M_CO.isErrorCashDrawer = true;
            return;
           }
            cashDrawerService.saveDeviceInfo(angular.toJson(loggedInDeviceJson)).then(function(result) {
               $cookieStore.put($scope.M_CO.uuid, $scope.M_CO.cashDrawerName);
               $scope.M_CO.selectedcashDrawer =  $scope.M_CO.cashDrawerName;   
              $scope.M_CO.selectedcashDrawerId =  $scope.M_CO.cashDrawerId; 
              angular.element('#setCashDrawerModalWindow').modal('hide');
                $scope.F_CO.hideChangeCashDrowerModalWindow();
                 //$scope.F_CO.hideChangeCashDrawerpopup();
                
                if($scope.M_CO.showAssignCashDrawerModalWindow && !$scope.M_CO.isComingFromAddDeposit && !$scope.M_CO.isComingFromReverseDeposit) {
                  $scope.F_CO.getCOCheckoutInfo();
                  $scope.M_CO.showAssignCashDrawerModalWindow = false;
                }  else if($scope.M_CO.showAssignCashDrawerModalWindow && $scope.M_CO.isComingFromReverseDeposit) {
                  angular.element('#ReversePaymentPopup').modal({
                        backdrop: 'static',
                        keyboard: false
                  });
                  $scope.M_CO.showAssignCashDrawerModalWindow = false;
                } else if($scope.M_CO.showAssignCashDrawerModalWindow && $scope.M_CO.isComingFromAddDeposit) {
                 $scope.F_CO.Deposit.openAddDepositPopup();
                 $scope.M_CO.showAssignCashDrawerModalWindow = false;
                }
             }, function(error) {
              $scope.M_CO.isLoading = false;
              Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
        

       function getDeviceIdOnLoad() {
        var uuid = new DeviceUUID().get();
        $scope.M_CO.uuid = uuid;
        var index = _.findIndex($scope.M_CO.cashDrawerList, {
                  "CashDrawerName": $cookieStore.get(uuid)
              });
        if($cookieStore.get(uuid) && index != -1 && $scope.M_CO.cashDrawerList){
              $scope.M_CO.selectedcashDrawer = $cookieStore.get(uuid)
              $scope.M_CO.selectedcashDrawerId = $scope.M_CO.cashDrawerList[index].Id;
        } else {
          cashDrawerService.getDeviceInfoByDeviceUUID(uuid).then(function(result) {
            if(result) {
              $cookieStore.put($scope.M_CO.uuid, result.CashDrawerName);
              $scope.M_CO.selectedcashDrawerId = result.Id;
              $scope.M_CO.selectedcashDrawer = result.CashDrawerName;
            } else {
              $scope.M_CO.showAssignCashDrawerModalWindow = true;

            }
            }, function(error) {
              $scope.M_CO.isLoading = false;
              Notification.error($translate.instant('GENERIC_ERROR'));
            });
        }
       }
       

        $scope.F_CO.calculateDueFromCustomer = function() {
        return ($scope.F_CO.getDealTotal() - $scope.F_CO.DealFinance.getAmountFinanced() - $scope.M_CO.Deposit.TotalDepositAmout);
        }

        $scope.F_CO.calculateDueFromFinance = function() {
          var dealTotalDeposit = 0;
          for(var i=0; i<$scope.M_CO.DepositList.length; i++) {
            if($scope.M_CO.DepositList[i].Deal && $scope.M_CO.DepositList[i].PaymentMethod === 'Financed') {
              dealTotalDeposit +=$scope.M_CO.DepositList[i].Amount;
            }
          }
          return $scope.F_CO.DealFinance.getAmountFinanced() - dealTotalDeposit;
        }

        $scope.F_CO.selectResolveUnit = function(dealStockIdValueJson) {
            $scope.M_CO.dealStockIdValue[0] = dealStockIdValueJson;
        }
        $scope.F_CO.selectchargedMethod = function(chargedMethod) {
            $scope.M_CO.Deal.resolvedFulFillment.ChargeMethod = chargedMethod.label;
        }
        $scope.F_CO.StockUnitMap = function() {
            $scope.M_CO.dealStockIdValueJson = [];
            if ($scope.M_CO.Deal.UnitList != undefined) {
                for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                    if ($scope.M_CO.Deal.UnitList[i].DealItemObj.StockNumber != undefined && $scope.M_CO.Deal.UnitList[i].DealItemObj.StockNumber != undefined) {
                        var obj = {
                            Id: $scope.M_CO.Deal.UnitList[i].DealItemObj.UnitId,
                            Value: $scope.M_CO.Deal.UnitList[i].DealItemObj.StockNumber
                        };
                        $scope.M_CO.dealStockIdValueJson.push(obj);
                    }
                }
                for (var i = 0; i < $scope.M_CO.Deal.DealUnresolvedFulfillmentList.length; i++) {
                    $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].ChargeMethod = 'Invoice';
                    if ($scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].DealServiceLineItemId != null && $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].DealServiceLineItemId != undefined) {
                        for (var j = 0; j < $scope.M_CO.dealStockIdValueJson.length; j++) {
                            if ($scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].StockId == $scope.M_CO.dealStockIdValueJson[j].Value) {
                                $scope.M_CO.dealStockIdValue[i] = $scope.M_CO.dealStockIdValueJson[j];
                            }
                        }
                    } else {
                        $scope.M_CO.dealStockIdValue[i] = $scope.M_CO.dealStockIdValueJson[0];
                    }
                }
            }
        }
        $scope.F_CO.jobReviewIsSelected = function(index, soHeaderId) {
            $scope.F_CO.setBooleansForService(false, true);
            $scope.F_CO.deselectValue();
            for (var i = 0; i < $scope.M_CO.ServiceTypeJobReview.length; i++) {
                for (var k = 0; k < $scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList.length; k++) {
                    if ($scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList[k].SOHeaderId == soHeaderId) {
                        $scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList[k].IsSOHeaderSelected = !($scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList[k].IsSOHeaderSelected);
                        for (var j = 0; j < $scope.M_CO.printDocumentTypeList[1].PrintItems.length; j++) {
                            if ($scope.M_CO.printDocumentTypeList[1].PrintItems[j].Id == soHeaderId) {
                                $scope.M_CO.printDocumentTypeList[1].PrintItems[j].IsSelected = $scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList[k].IsSOHeaderSelected;
                            }
                        }
                    }
                }
            }
        }
        $scope.F_CO.selectAllServiceType = function(serviceType) {
            if (serviceType == 'Worksheet') {
                $scope.F_CO.setBooleansForService(true, false);
                var index = 0;
                angular.forEach($scope.M_CO.ServiceTypeWorksheet, function(value, key) {
                    angular.forEach(value.SOInfoWrapperList, function(value, key) {
                        value.IsSOHeaderSelected = true;
                        $scope.M_CO.printDocumentTypeList[1].PrintItems[index].IsSelected = value.IsSOHeaderSelected;
                        index++;
                    });
                });
                $scope.F_CO.deselectValue();
            } else if (serviceType == 'Job') {
                $scope.F_CO.setBooleansForService(false, true);
                var index = 0;
                angular.forEach($scope.M_CO.ServiceTypeJobReview, function(value, key) {
                    angular.forEach(value.SOInfoWrapperList, function(value, key) {
                        value.IsSOHeaderSelected = true;
                        $scope.M_CO.printDocumentTypeList[1].PrintItems[index].IsSelected = value.IsSOHeaderSelected;
                        index++;
                    });
                });
                $scope.F_CO.deselectValue();
            }
        }
        $scope.F_CO.togglePrintItemCheckbox = function(index) {
            $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[index].IsSelected = !($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[index].IsSelected);
        }
        //TODO
        var error = function(errorMessage) {
            this.handler = function(error) {
                $scope.M_CO.isLoading = false;
                $scope.M_CO.isDeleteDisabled = false;
                console.log(error);
              handleErrorAndExecption(error);
              return;
            }
        }
        $scope.F_CO.refreshPage = function() {
          location.reload();
        }
        function populateCOHeaderIdInUrl(CoHeaderId) {
            $scope.M_CO.isLoading = true;
            var CO_Json = {
                DummyAccordion: $scope.M_CO.DummyAccordion,
                IsShowMerchandiseSection: $scope.M_CO.IsShowMerchandiseSection,
                isCompleteLoad: $scope.M_CO.isCompleteLoad,
                AppointmentId: $scope.M_CO.AppointmentId
            };
            if(PartNotFoundList && PartNotFoundList.length) {
              CO_Json['PartsmartItemsNotFound'] = PartNotFoundList;
              CO_Json['IsFromPartSmart'] = true;
            }

            $state.go('CustomerOrder_V2', {
                Id: CoHeaderId,
                AppointmentId: '',
                myParams: CO_Json
            }, {
                notify: true
            });
        }

        function checkValidationBeforeChangingCustomer() {
            if ($scope.M_CO.COInvoiceHistoryList.length > 0) {
                Notification.error($translate.instant('Changing_Customer_After_Invoicing_Error_Message'));
                $scope.M_CO.isLoading = false;
                return false;
            }
            return true;
        }
        var selectedCustomerWithCOU = false;
        $scope.$on('selectedCustomerWithCOUCallback', function(event, args) {
            if(!args.addCustomerCoBuyer) {
              $scope.M_CO.sellingGroup = args.SellingGroup ? args.SellingGroup : 'Part Sale';
              $scope.M_CO.isLoading = true;
              selectedCustomerWithCOU = true;
              $scope.F_CO.CustomerSaveCallback(args.CustomerId);
            }else {
              $scope.M_CO.Deal.DealFinanceObj.CoBuyerId = args.CustomerId;
              $scope.F_CO.saveFinancingInfo('',true, false);
            }

        });
          function openDuplicatePartModal(lineItemType, lineitemJson, isFromDealMerchandiseSection, soHeaderId, soheaderIndex, unitIndex, dealId, dealItemId) {
            $scope.M_CO.isLoading = false;
            var itemJson = [];
            if (lineItemType == 'Service' || lineItemType == 'Deal') {
                itemJson.push(lineitemJson);
            } else {
                itemJson = lineitemJson;
            }
            $scope.M_CO.lineItemType = lineItemType;
            duplicateListJson.DuplicatesoHeaderId = soHeaderId;
            duplicateListJson.duplicateSoHeaderIndex = soheaderIndex;
            duplicateListJson.duplicateUnitIndex = unitIndex;
            duplicateListJson.duplicateDealId = dealId;
            duplicateListJson.duplicateDealItemId = dealItemId;
            $scope.M_CO.DuplicatePartList = itemJson;
            $scope.M_CO.isSupressTrue = false;
            var partId = $scope.M_CO.DuplicatePartList[0].PartId;
            showMoreDuplicateParts(partId);
            angular.element('#DuplicatePartWarningModal').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#DuplicatePartWarningModal').show();
        }
        angular.element(document).on("click", "#DuplicatePartWarningModal .modal-backdrop", function() {
            $scope.F_CO.DuplicatePartclosePopup();
        });

         angular.element(document).on("click", "#profitability-modal-window .modal-backdrop", function() {
            $scope.F_CO.hideprofitabilityModalWindow();
        });

        $scope.F_CO.hideprofitabilityModalWindow = function(){
          angular.element('#profitability-modal-window').modal('hide');
        }

        $scope.F_CO.DuplicatePartclosePopup = function() {
            $scope.M_CO.isSupressTrue = false;
            angular.element('#DuplicatePartWarningModal').modal('hide');
            angular.element("body").removeClass("modal-open");
        }

        function showMoreDuplicateParts(partId) {
            $scope.M_CO.showMorePartsDetails = true;
            CustomerService.showHistoryOnSuppressPopup(partId, $scope.M_CO.COHeaderId).then(function(successfulSearchResult) {
                $scope.M_CO.DuplicateSectionList = successfulSearchResult;
            }, function(errorSearchResult) {
                responseData = errorSearchResult;
            });
        }
        $scope.F_CO.AddDuplicatePart = function() {
            $scope.M_CO.isLoading = true;
            var partLineItemList = $scope.M_CO.DuplicatePartList;
            if ($scope.M_CO.lineItemType === 'Deal') {
                successJson = {
                    'type': 'saveOptionFeesLineItem',
                    'UnitIndex': duplicateListJson.duplicateUnitIndex,
                    'isAddMode': true,
                    'callback': $scope.F_CO.updateDealSummaryTotals
                };
                DealService.insertOptionAndFeeLineItems(partLineItemList[0].PartId, $scope.M_CO.COHeaderId, duplicateListJson.duplicateDealId, duplicateListJson.duplicateDealItemId, angular.toJson(partLineItemList[0]), $scope.M_CO.isSupressTrue, false).then(new success(successJson).handler, new error().handler);
            } else {
                var isFromDealMerchandiseSection = $scope.M_CO.lineItemType == 'DealMerchandise' ? 'DealMerchandise' : undefined;
                var customerId = $scope.M_CO.coHeaderRec.CustomerId;
                if (!$scope.M_CO.coHeaderRec.CustomerId) {
                    customerId = null;
                }
                var soHeaderId = null;
                var soheaderIndex = null;
                if (duplicateListJson.DuplicatesoHeaderId) {
                    soHeaderId = duplicateListJson.DuplicatesoHeaderId;
                    soheaderIndex = duplicateListJson.duplicateSoHeaderIndex;
                }
                var successJson;
                if ($scope.M_CO.lineItemType == 'Service') {
                    successJson = {
                        'type': 'addSOLineItem',
                        'SOHeaderIndex': soheaderIndex,
                        'isAddMode': true
                    };
                    if (!isBlankValue($scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.DealId)) {
                        successJson = {
                            'type': 'addSOLineItem',
                            'SOHeaderIndex': soheaderIndex,
                            'isAddMode': true,
                            'callback': getUnitDealDetails,
                            'callbackParam': {
                                'gridName': 'dealUnresolvedFulfillmentSection'
                            }
                        };
                    }
                } else if ($scope.M_CO.lineItemType === 'Merchandise') {
                    successJson = {
                        'type': 'addCOLineItem',
                        'isAddMode': true
                    };
                } else if ($scope.M_CO.lineItemType === 'DealMerchandise') {
                    successJson = {
                        'type': 'addDealCOLineItem',
                        'isAddMode': true
                    };
                }
                if (!$scope.M_CO.coHeaderRec.CustomerId) {
                    $scope.M_CO.coHeaderRec.CustomerId = null;
                }
                UserService.checkDuplicateParts(partLineItemList[0].PartId, $scope.M_CO.COHeaderId, angular.toJson(partLineItemList), $scope.M_CO.isSupressTrue, false, soHeaderId, $scope.M_CO.coHeaderRec.CustomerId).then(new success(successJson).handler, new error().handler);
            }
            $scope.F_CO.DuplicatePartclosePopup();
        }
        function getOutOfStockPartsInKit(kitHeaderId) {
          var defer = $q.defer();
          merchandiseService.getOutOfStockPartsInKit(kitHeaderId).then(function(result) {
            defer.resolve(result);
          }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function insertKit(kitHeaderId, isOversold) {
          $scope.M_CO.COHeaderId = ($scope.M_CO.COHeaderId) ? $scope.M_CO.COHeaderId : null;
          if(isOversold) {
            merchandiseService.insertKitHeaderInMerchGrid(kitHeaderId, $scope.M_CO.COHeaderId).then(function(result) {
              for(var i = 0; i < result.COKHList[result.COKHList.length - 1].COLIList.length; i++) {
                var khliRec = result.COKHList[result.COKHList.length - 1].COLIList[i];
                if(khliRec.PartId && khliRec.Qty != khliRec.QtyCommitted) {
                  khliRec.QtyCommitted = khliRec.Qty;
                }
              }
              var successJson = {
                  'type': 'addCOLineItem',
                      'isAddMode': true
                  };
                  merchandiseService.oversoldKit(result.coHeaderRec.COHeaderId, angular.toJson(result.COKHList[result.COKHList.length - 1])).then(new success(successJson).handler, new error().handler);
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
          } else {
            var successJson = {
              'type': 'addCOLineItem',
                  'isAddMode': true
              };
          merchandiseService.insertKitHeaderInMerchGrid(kitHeaderId, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }
      }

        var selectedId;
        var isSwitchingFromCashSale = false;
        $scope.$on('AutoCompleteCallbackHandler', function(event, args) {
            selectedId = args.selectedId;
            var soheaderIndex = args.soheaderIndex;
            var unitIndex = args.UnitIndex;
            $scope.M_CO.isLoading = true;
            var successJson = {};
            var selectedJSON = [];
            var lineItemType;
            var partLineItemList = [];
            if (args.type == 'addCustomer') {
                if (!$scope.M_CO.COHeaderId) {
                    $scope.M_CO.COHeaderId = null;
                    if (selectedId && !isSwitchingFromCashSale) {
                      isSwitchingFromCashSale = false;
                        CustomerService.getActiveCustomerOrdersById(selectedId).then(function(successfulResult) {
                            $scope.M_CO.ActiveOrders = successfulResult.searchRecords;
                            if ($scope.M_CO.ActiveOrders.length) {
                                $scope.M_CO.isLoading = false;
                                angular.element('#ActiveOrder').modal({
                                    backdrop: 'static',
                                    keyboard: false
                                });
                                angular.element('#ActiveOrder').show();
                                angular.element("body").addClass("modal-open");
                            } else {
                                successJson = {
                                    'type': 'createCO'
                                };
                                createCOServerCall(selectedId, successJson);
                            }
                        }, function(errorSearchResult) {
                            Notification.error(errorSearchResult);
                        });
                    } else {
                        successJson = {
                            'type': 'createCO'
                        };
                        createCOServerCall(selectedId, successJson);
                    }
                } else {
                    if (checkValidationBeforeChangingCustomer()) {
                        successJson = {
                            'type': 'addCustomer',
                            'callback': $scope.F_CO.getCOHeaderDetailsByGridName
                        };

                        if (!$scope.M_CO.coHeaderRec.CustomerId && $scope.M_CO.isOpenSelectCustomerSectionForCashSaleSpecialOrder) { // Handling For Cash Sale Oversold Functionality
                          successJson['addCOLIAndCreateSpecialOrder'] = true;
                        }
                        CustomerService.addCustomer($scope.M_CO.COHeaderId, selectedId).then(new success(successJson).handler, new error().handler);
                    }
                }
            } else if (args.type == 'addCustomerCoBuyer') {
               $scope.M_CO.Deal.DealFinanceObj.CoBuyerId = args.selectedId;
               $scope.F_CO.saveFinancingInfo('',true, false);

            }else if (args.type == 'addSOLineItem') {
                successJson = {
                    'type': 'addSOLineItem',
                    'SOHeaderIndex': soheaderIndex,
                    'isAddMode': true
                };
                if (!isBlankValue($scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.DealId)) {
                    successJson = {
                        'type': 'addSOLineItem',
                        'SOHeaderIndex': soheaderIndex,
                        'isAddMode': true,
                        'callback': getUnitDealDetails,
                        'callbackParam': {
                            'gridName': 'dealUnresolvedFulfillmentSection'
                        }
                    };
                }
                if (args.selectedJSON && args.selectedJSON.PartId) {
                    lineItemType = 'Service';
                    if (!$scope.M_CO.coHeaderRec.CustomerId) {
                        $scope.M_CO.coHeaderRec.CustomerId = null;
                    }
                    UserService.checkDuplicateParts(args.selectedJSON.PartId, $scope.M_CO.COHeaderId, args.selectedJSON, false, true, $scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.Id, $scope.M_CO.coHeaderRec.CustomerId).then(function(successResult) {
                        if (successResult.DuplicatePart) {
                            openDuplicatePartModal(lineItemType, args.selectedJSON, false, $scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.Id, soheaderIndex);
                        } else {
                            return new success(successJson).handler(successResult);
                        }
                    }, new error().handler);
                } else {
                    SOHeaderService.addSOLineItem(selectedId, $scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.Id).then(new success(successJson).handler, new error().handler);
                }
            } else if (args.type == 'addOptionFee') {
                var unitIndex = args.unitIndex;
                var selectedJSON = args.selectedJSON;
                successJson = {
                    'type': 'saveOptionFeesLineItem',
                    'UnitIndex': unitIndex,
                    'isAddMode': true,
                    'callback': $scope.F_CO.updateDealSummaryTotals
                };
                var dealId = $scope.M_CO.Deal.DealInfo.Id;
                var dealItemId = $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.Id;
                var optionFeeJSON = createOptionFeeJSON(dealId, dealItemId, selectedId, selectedJSON);
                if (optionFeeJSON && JSON.parse(optionFeeJSON).PartId) {
                    lineItemType = 'Deal';
                    DealService.insertOptionAndFeeLineItems(JSON.parse(optionFeeJSON).PartId, $scope.M_CO.COHeaderId, dealId, dealItemId, optionFeeJSON, $scope.M_CO.isSupressTrue, true).then(function(successResult) {
                        if (successResult.DuplicatePart) {
                            openDuplicatePartModal(lineItemType, JSON.parse(optionFeeJSON), '', '', '', unitIndex, dealId, dealItemId);
                        } else {
                            return new success(successJson).handler(successResult);
                        }
                    }, new error().handler);
                } else {
                    DealService.saveOptionFeesLineItem(dealId, dealItemId, optionFeeJSON).then(new success(successJson).handler, new error().handler);
                }
            } else if (args.type == 'addCOLineItem') {
              /*Start: Cash Sale Oversold Functionality*/
              if(!$scope.M_CO.coHeaderRec.CustomerId && args.isOutOfStockPart) {
                $scope.M_CO.IsNewLineItemInserted = true;
                $scope.M_CO.isOutOfStockPart = true;
                $scope.M_CO.recentlyAddedLineItem = [];
                $scope.M_CO.recentlyAddedLineItem.push(args.selectedJSON);
                $scope.F_CO.showOversoldPopup();
                return;
              }
              /*End: Cash Sale Oversold Functionality*/

                if ($scope.M_CO.COHeaderId == undefined) {
                    $scope.M_CO.COHeaderId = null;
                }
                successJson = {
                    'type': 'addCOLineItem',
                    'isAddMode': true
                };
                if (args.selectedJSON != undefined) { // for part
                    selectedJSON.push(args.selectedJSON);
                    if (selectedJSON[0].PartId && $scope.M_CO.COHeaderId) { // not cash sale condition for Ticket #5126  $scope.M_CO.coHeaderRec.COType !== 'Cash Sale'
                        partLineItemList = JSON.stringify(selectedJSON, function(key, val) {
                            if (key == '$$hashKey') {
                                return undefined;
                            }
                            return val;
                        });
                        lineItemType = 'Merchandise';
                        if (!$scope.M_CO.coHeaderRec.CustomerId) {
                            $scope.M_CO.coHeaderRec.CustomerId = null;
                        }
                        UserService.checkDuplicateParts(JSON.parse(partLineItemList)[0].PartId, $scope.M_CO.COHeaderId, partLineItemList, $scope.M_CO.isSupressTrue, true, null, $scope.M_CO.coHeaderRec.CustomerId).then(function(successResult) {
                            if (successResult.DuplicatePart) {
                                openDuplicatePartModal(lineItemType, JSON.parse(partLineItemList));
                            } else {
                                return new success(successJson).handler(successResult);
                            }
                        }, new error().handler);
                    } else { // cash sale
                        merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(selectedJSON), null).then(new success(successJson).handler, new error().handler);
                    }
                } else if (args.FeeId) { // for fee
                    merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, null, args.FeeId).then(new success(successJson).handler, new error().handler);
                } else { // for kit
                  merchandiseService.insertKitHeaderInMerchGrid(selectedId, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
                }
            } else if (args.type == 'addDealCOLineItem') {
                successJson = {
                    'type': 'addDealCOLineItem',
                    'isAddMode': true
                };
                if (args.selectedJSON != undefined) {
                    args.selectedJSON.DealId = $scope.M_CO.Deal.DealInfo.Id;
                    selectedJSON.push(args.selectedJSON);
                    if (args.selectedJSON.PartId) {
                        partLineItemList = JSON.stringify(selectedJSON, function(key, val) {
                            if (key == '$$hashKey') {
                                return undefined;
                            }
                            return val;
                        });
                        lineItemType = 'DealMerchandise';
                        UserService.checkDuplicateParts(JSON.parse(partLineItemList)[0].PartId, $scope.M_CO.COHeaderId, partLineItemList, $scope.M_CO.isSupressTrue, true, null, $scope.M_CO.coHeaderRec.CustomerId).then(function(successResult) {
                            if (successResult.DuplicatePart) {
                                openDuplicatePartModal(lineItemType, JSON.parse(partLineItemList));
                            } else {
                                return new success(successJson).handler(successResult);
                            }
                        }, new error().handler);
                    } else {
                        merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(selectedJSON), null).then(new success(successJson).handler, new error().handler);
                    }
                } else if (args.FeeId) {
                    merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, null, args.FeeId).then(new success(successJson).handler, new error().handler);
                } else if(args.kitId) {
                  merchandiseService.insertKitHeaderInDealMerchGrid(args.kitId, $scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
                }
            } else if (args.type == 'saveDealFAndIProduct') {
                var fIProductJson = {
                    ProductId: args.selectedId,
                    DealFinanceId: $scope.M_CO.Deal.DealFinanceObj.Id,
                    DealId: $scope.M_CO.Deal.DealInfo.Id
                };
                successJson = {
                    'type': 'saveDealFAndIProduct',
                    'isAddMode': true
                };
                DealService.saveDealFAndIProduct($scope.M_CO.Deal.DealInfo.Id, JSON.stringify(fIProductJson)).then(new success(successJson).handler, new error().handler);
            } else if (args.type == 'addStockUnit') {
              var isGetUnitImageData = true;
                if (unitIndex != undefined) {
                    if (!$scope.F_CO.isDealActionEnable()) {
                        Notification.error($translate.instant('CustomerOrder_Js_After_commit_and_install'));
                        $scope.M_CO.isLoading = false;
                        return;
                    }
                    for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                        if ($scope.M_CO.Deal.UnitList[i].DealItemObj.UnitId == selectedId) {
                            Notification.error($translate.instant('angucomplete_Unit_Already_Exist'));
                            $scope.M_CO.isLoading = false;
                            return;
                        }
                    }
                    successJson = {
                        'type': 'addStockUnit',
                        'unitIndex': unitIndex,
                        'callback': $scope.F_CO.updateDealSummaryTotals,
                        'isGetUnitImageData': isGetUnitImageData
                    };
                    DealService.addUnitToDeal($scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.Id, selectedId, $scope.M_CO.Deal.DealInfo.Id).then(new success(successJson).handler, new error().handler);
                } else if (soheaderIndex != undefined) {
                    $scope.M_CO.SOHeaderList[soheaderIndex].SOInfo.UnitId = selectedId;
                    $scope.M_CO.isReplaceUnit = false;
                    $scope.F_CO.saveServiceJobInfo(soheaderIndex, false, isGetUnitImageData);
                }
            } else if(args.type == 'addKitInCashSale') {
              getOutOfStockPartsInKit(selectedId).then(function(result) {
                if(result && result.length) {
                  $scope.M_CO.IsNewLineItemInserted = true;
                    $scope.M_CO.isOutOfStockPart = true;
                    $scope.M_CO.cashSaleOutOfStockKitId = args.selectedId;
                    $scope.M_CO.recentlyAddedLineItem = [];
                    if(result.length == 1) {
                      var lineItem = {'Item' : result[0].Item, 'AvailableQty' : result[0].AvailableParts, 'Price' : result[0].ReatilPrice};
                      $scope.M_CO.recentlyAddedLineItem.push(lineItem);
                    }
                    $scope.F_CO.showOversoldPopup();
                    return;
                } else {
                  insertKit(selectedId);
                }
              }, function(error) {
                handleErrorAndExecption(error);
                    defer.reject($translate.instant('GENERIC_ERROR'));
                });
            }
        });

        function createCOServerCall(customerId, successJson) {
          if($scope.M_CO.IsShowMerchandiseSection && $scope.M_CO.sellingGroup === 'Part Sale') {
              isPreventMerchSectionCreation = false;
            }
            CustomerService.createCO(customerId, $scope.M_CO.sellingGroup, isPreventMerchSectionCreation).then(new success(successJson).handler, new error().handler);
        }

        function createOptionFeeJSON(dealId, dealItemId, selectedId, selectedJSON) {
            var optionFeeJSON = {};
            var optionFeeJSON = {
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
            if (selectedJSON.Info == 'Merchandise' || selectedJSON.Info == 'Part') {
                optionFeeJSON.PartId = selectedJSON.Id;
                optionFeeJSON.Price = selectedJSON.AdditionalInfoObj.Price;
                optionFeeJSON.Item = selectedJSON.AdditionalInfoObj.Item;
                optionFeeJSON.IsInstall = true;
            } else if (selectedJSON.Info == 'Labor') {
                optionFeeJSON.LabourId = selectedJSON.Id;
                optionFeeJSON.IsInstall = true;
            } else if (selectedJSON.Info == 'Fee') {
                optionFeeJSON.FeeId = selectedJSON.Id;
            } else if (selectedJSON.Info == 'Product') {
                optionFeeJSON.ProductId = selectedJSON.Id;
                if (selectedJSON.AdditionalInfoObj.ProductType == 'Sublet') {
                    optionFeeJSON.IsInstall = true;
                }
            } else if (selectedJSON.Info == 'Kit') {
                optionFeeJSON.KitHeaderId = selectedJSON.Id;
            }
            optionFeeJSON.DealId = dealId;
            optionFeeJSON.DealItemId = dealItemId;
            return angular.toJson(optionFeeJSON);
        }
        $scope.F_CO.removeCustomer = function() {
          $scope.M_CO.isLoading = true;
          var successJson = {
                'type': 'addCustomer',
                'callback': $scope.F_CO.getCOHeaderDetailsByGridName
            };
            CustomerService.addCustomer($scope.M_CO.COHeaderId, null).then(new success(successJson).handler, new error().handler);
        }
        /**
         * Description: Method to add a customer on 'Cash Sale type' CO or change extsting customer on other types of CO (TODO)
         */
        $scope.F_CO.changeCustomer = function() {
            $scope.M_CO.isChangeCustomer = true;
        }
        /**
         * Description: Method to check if Add Customer action is available for 'Cash Sale' type CO
         */
        $scope.F_CO.isAddCustomerActionForCashSaleAvailable = function() {
            if ($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType === 'Cash Sale' && ($scope.M_CO.coHeaderRec.TotalPayments || ($scope.M_CO.COInvoiceHistoryList && $scope.M_CO.COInvoiceHistoryList.length))) {
                return false;
            }
            return true;
        }
        $scope.F_CO.closeActiveOrderPopup = function() {
            $scope.M_CO.currentDealUnitRemoveIndex = undefined;
            angular.element('#ActiveOrder').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            $scope.M_CO.createNewCustomerOrderFromSkipButton = false;
            
        }
        angular.element(document).on("click", "#ActiveOrder .modal-backdrop", function() {
            $scope.F_CO.closeActiveOrderPopup();
        });
        $scope.F_CO.openAddEditCustomerPopup = function() {
            var AddEditCustomerParams = {
                SellingGroup: $scope.M_CO.sellingGroup
            };
            loadState($state, 'CustomerOrder_V2.AddEditCustomerV2', {
                AddEditCustomerParams: AddEditCustomerParams
            });
        }
        $scope.F_CO.openEditPricingPopup = function(unitIndex) {
            var EditPricingParams = {};
            EditPricingParams.unitIndex = unitIndex;
            loadState($state, 'CustomerOrder_V2.EditPricing', {
                EditPricingParams: EditPricingParams
            });
        }
        $scope.F_CO.openInvoiceToDealPopup = function(data) {
            var InvoiceToDealParams = {};
            loadState($state, 'CustomerOrder_V2.InvoiceToDeal', {
                InvoiceToDealParams: InvoiceToDealParams
            });
        }
       
        $scope.F_CO.showActiveCustomerOrderpopup = function() {
            if($scope.M_CO.coHeaderRec.CustomerId) {
                $scope.M_CO.isLoading = true;
                CustomerService.getActiveCustomerOrdersById($scope.M_CO.coHeaderRec.CustomerId).then(function(successfulResult) {
                    $scope.M_CO.ActiveOrders = successfulResult.searchRecords;
                    if ($scope.M_CO.ActiveOrders.length) {
                        $scope.M_CO.createNewCustomerOrderFromSkipButton = true;
                        angular.element('#ActiveOrder').modal({
                            backdrop: 'static',
                            keyboard: false
                        });
                        angular.element('#ActiveOrder').show();
                        angular.element("body").addClass("modal-open");
                    } 
                    $scope.M_CO.isLoading = false;
                    if($scope.M_CO.ActiveOrders.length == 0) {
                        Notification.error("No active order for this customer");
                    }
                }, function(errorSearchResult) {
                    Notification.error(errorSearchResult);
                });
            }
            
        }
        $scope.F_CO.isDealMerchandiseContainInvoicableItem = function() {
          if($scope.F_CO.isAllDealMerchandiseInvoicedCompletely()) {
            return false;
          }
            if ($scope.M_CO.Deal.DealFulfillmentSectionObj && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList) {
                for (var i = 0; i < $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length; i++) {
                  var dealMerchObj = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i];
                  if(!dealMerchObj.Id) {
                    if (dealMerchObj.COLIList[0] && relatedUnresolvedFulfillmentNotExist(dealMerchObj.COLIList[0].CoLineItemId) && dealMerchObj.COLIList[0].Status != 'Invoiced' && ((dealMerchObj.COLIList[0].IsFee) || (dealMerchObj.COLIList[0].IsPart && (dealMerchObj.COLIList[0].Status == 'In Stock'|| dealMerchObj.COLIList[0].Status == 'Oversold')))) {
                            return true;
                        }
                  } else if(dealMerchObj.COLIList && relatedUnresolvedFulfillmentNotExist(dealMerchObj.Id)) {
                    for(var j = 0; j < dealMerchObj.COLIList.length; j++) {
                      if (dealMerchObj.COLIList[j].Status != 'Invoiced' && (dealMerchObj.COLIList[j].IsFee) || (dealMerchObj.COLIList[j].IsPart && (dealMerchObj.COLIList[j].Status == 'In Stock'|| dealMerchObj.COLIList[j].Status == 'Oversold'))) {
                                return true;
                            }
                      }
                  }
                }
            }
            return false;
        }

        var relatedUnresolvedFulfillmentNotExist = function(itemId) {
          for (var i = 0; i < $scope.M_CO.Deal.DealUnresolvedFulfillmentList.length; i++) {
            if (itemId === $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].DealMerchandiseLineItemId || itemId === $scope.M_CO.Deal.DealUnresolvedFulfillmentList[i].COKitHeaderId) {
                    return false;
                }
          }
          return true;
        }

        $scope.F_CO.isAllDealMerchandiseInvoicedCompletely = function() {
            if ($scope.M_CO.Deal.DealFulfillmentSectionObj && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList) {
                for (var i = 0; i < $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length; i++) {
                    if ($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i] && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i].COLIList[0] && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i].COLIList[0].Status != 'Invoiced') {
                        return false;
                    }
                }
            }
            return true;
        }

        function resetAnimationFlags() {
          $scope.M_CO.expandedSectionName = '';
      $scope.M_CO.expandedDivFlag = false;
            $scope.M_CO.expandedDivId = '';
      $scope.M_CO.expandedInnerSectionName = '';
      $scope.M_CO.expandedInnerDivFlag = false;
      $scope.M_CO.expandedInnerDivId = '';
      $scope.M_CO.expandedInner2SectionName = '';
          $scope.M_CO.expandedInner2DivFlag = false;
          $scope.M_CO.expandedInner2DivId = '';
        }

        function resetDeleteOrMoveLIModalVars() {
          $scope.M_CO.deletedItemName = '';
          $scope.M_CO.deletedItemGridName = '';
          $scope.M_CO.deletableLI_SectionHeader_Index = '';
          $scope.M_CO.deletableLI_SectionHeader_Id = '';
          $scope.M_CO.deletableLI_KitHeader_Index = '';
          $scope.M_CO.deletableLI_KitHeader_Id = '';
          $scope.M_CO.deletableLI_Index = '';
          $scope.M_CO.deletableLI_Id = '';
        }

        //For Outer Accordian
        $scope.F_CO.expandOrCollapseSection = function(sectionId, sectionName, selectedIndex, havePermission,event) {
           if($scope.M_CO.expandedDivFlag && $scope.M_CO.expandedDivId == sectionId && $scope.M_CO.expandedSectionName == sectionName) {
              if(event && event.target && ( (angular.element(event.target).closest('.event-prevent-default').length)  || (angular.element(event.target).closest('div.badge-container').length) || (angular.element(event.target).closest('input').length) ) ) {
                return;
              }
              $scope.F_CO.collapseSection();
            } else if(sectionName == 'ServiceJob' + selectedIndex) {
            	$scope.F_CO.expandedSection(sectionId, sectionName, selectedIndex, havePermission,true);
            } else {
              $scope.F_CO.expandedSection(sectionId, sectionName, selectedIndex, havePermission);
            }
            $scope.M_CO.isShowSaveBtnForIpad = false;

        }

        $scope.F_CO.expandedSection = function(sectionId, sectionName, selectedIndex, havePermission,isAvoidSetFocusOnCOU) {
            if (havePermission === false) {
                return;
            }

            var expandableDiv;
            var expandableDivChildDivHeight;
            var transitionDelay;
            $scope.M_CO.selectedSOHeaderIndex = isNaN(selectedIndex) ? null : selectedIndex;
            if ($scope.M_CO.expandedDivFlag && $scope.M_CO.expandedDivId == sectionId) {
                return;
            }
            if ($scope.M_CO.expandedDivFlag) {
                transitionDelay = '0.3s';
                $scope.F_CO.collapseSection();
            }
            if (sectionName === 'DFSection' && $scope.M_CO.Deal.DealInfo.Id) {
                getSalesTaxDetailsForDeal($scope.M_CO.Deal.DealInfo.Id);
            }
            expandableDiv = angular.element('#' + sectionId);
            expandableDivChildDivHeight = angular.element(angular.element('#' + sectionId + ' > div')[0]).outerHeight();
            expandElement(expandableDiv, expandableDivChildDivHeight, transitionDelay);
            $scope.M_CO.expandedDivFlag = true;
            $scope.M_CO.expandedDivId = sectionId;
            $scope.M_CO.expandedSectionName = sectionName;
            //TODO Update this and test - use $evalAsync
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                $scope.$apply(); //TODO
            }
            var TimeoutVal = 500;
            if (transitionDelay) {
                TimeoutVal = 800;
            }
            setTimeout(function() {
            if(checkForDevice('iPad')) {
              expandableDiv.css('transition', 'none');
            }
                expandableDiv.css('height', 'auto');
                expandableDiv.css('overflow', 'visible');
                $scope.M_CO.expandedSectionName = sectionName;
            }, TimeoutVal);
            //Focus of first input after expanding #4157 point 2
            if(!isAvoidSetFocusOnCOU) {
              angular.element(expandableDiv).find("input:visible:first:not('.datepicker')").focus();
            }
            if(sectionId === 'ServiceJob0_SectionId' && selectedIndex === 0) {
              setTimeout(function() {
                $scope.F_CO.expandInnerSection('ServiceJob0_DetailsSectionId','ServiceJob0_Details');
                }, (TimeoutVal * 2));
            }
        }
        //For Outer Accordian
        $scope.F_CO.collapseSection = function() {
            $scope.M_CO.editLineItem = '';
            $scope.M_CO.isReplaceUnit = false;
            $scope.M_CO.TradeIn.IsCOUSelected = false;
            if ($scope.M_CO.expandedDivId) {
                var collapsableDiv = angular.element('#' + $scope.M_CO.expandedDivId);
                var expandableDivChildDivHeight = angular.element(angular.element('#' + $scope.M_CO.expandedDivId + ' > div')[0]).outerHeight();
                collapsableDiv.css('height', expandableDivChildDivHeight);
                collapsableDiv.css('overflow', 'hidden');
                setTimeout(function() {
                    collapseElement(collapsableDiv);
                }, 20)
                $scope.M_CO.expandedDivFlag = false;
                $scope.M_CO.expandedDivId = '';
                $scope.M_CO.expandedSectionName = '';
                if ($scope.M_CO.expandedInnerDivFlag) {
                    $scope.F_CO.collapseInnerSection();
                }
            }
        }
        //For Inner level-1 Accordian
      $scope.F_CO.expandOrCollapseInnerSection = function(sectionId, sectionName, selectedIndex, havePermission,event) {
            if(event && event.target && (angular.element(event.target).closest('.event-prevent-default').length)  ) {
                return;
              }
            if($scope.M_CO.expandedInnerDivFlag && $scope.M_CO.expandedInnerDivId == sectionId && $scope.M_CO.expandedInnerSectionName == sectionName) {
              $scope.F_CO.collapseInnerSection();
            } else {
              $scope.F_CO.expandInnerSection(sectionId, sectionName);
            }
        }

        $scope.F_CO.expandInnerSection = function(sectionId, sectionName) {
            var transitionDelay;
            if ($scope.M_CO.expandedInnerDivFlag && $scope.M_CO.expandedInnerDivId == sectionId) {
                return;
            }
            if ($scope.M_CO.expandedInnerDivFlag && $scope.M_CO.expandedInnerDivId != sectionId) {
                transitionDelay = '0.3s';
                $scope.F_CO.collapseInnerSection();
            }
            var expandableDiv = angular.element('#' + sectionId);
            var expandableDivChildDivHeight = angular.element(angular.element('#' + sectionId + ' > div')[0]).outerHeight();
            $scope.M_CO.expandedInnerDivFlag = true;
            $scope.M_CO.expandedInnerDivId = sectionId;
            $scope.M_CO.expandedInnerSectionName = sectionName;
            expandElement(expandableDiv, expandableDivChildDivHeight, transitionDelay);
            var TimeoutVal = 500;
            if (transitionDelay) {
                TimeoutVal = 800;
            }
            setTimeout(function() {
              if(checkForDevice('iPad')) {
            expandableDiv.css('transition', 'none');
          }
                expandableDiv.css('height', 'auto');
                expandableDiv.css('overflow', 'visible');
                $scope.M_CO.expandedInnerSectionName = sectionName;
            }, TimeoutVal);
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                $scope.$apply(); //TODO
            }
          /*  Refrence for Ticket no #5168 */
        if(sectionId === 'ServiceJob0_DetailsSectionId') {
            angular.element(expandableDiv).find('input:visible:first').blur();
        }
        }
        //For Inner level-1 Accordian
        $scope.F_CO.collapseInnerSection = function() {
            $scope.M_CO.editLineItem = '';
            $scope.M_CO.isReplaceUnit = false;
            $scope.M_CO.TradeIn.IsCOUSelected = false;
            if ($scope.M_CO.expandedInnerDivId) {
                var collapsableDiv = angular.element('#' + $scope.M_CO.expandedInnerDivId)
                var expandableDivChildDivHeight = angular.element(angular.element('#' + $scope.M_CO.expandedInnerDivId + ' > div')[0]).outerHeight();
                collapsableDiv.css('height', expandableDivChildDivHeight);
                collapsableDiv.css('overflow', 'hidden');
                setTimeout(function() {
                    collapseElement(collapsableDiv);
                }, 20)
                $scope.M_CO.expandedInnerDivFlag = false;
                $scope.M_CO.expandedInnerDivId = '';
                $scope.M_CO.expandedInnerSectionName = '';
                if ($scope.M_CO.expandedInner2DivFlag) {
                    $scope.F_CO.collapseInner2Section();
                }
            }
        }
        //For Inner level-2 Accordian
        $scope.F_CO.expandOrCollapseInner2Section = function(sectionId, sectionName, selectedIndex, havePermission, event) {
            if($scope.M_CO.expandedInner2DivFlag && $scope.M_CO.expandedInner2DivId == sectionId && $scope.M_CO.expandedInner2SectionName == sectionName) {
              $scope.F_CO.collapseInner2Section();
            } else {
              $scope.F_CO.expandInner2Section(sectionId, sectionName);
            }
        }

        $scope.F_CO.expandInner2Section = function(sectionId, sectionName) {
            var transitionDelay;
            if ($scope.M_CO.expandedInner2DivFlag && $scope.M_CO.expandedInner2DivId == sectionId) {
                return;
            }
            if ($scope.M_CO.expandedInner2DivFlag && $scope.M_CO.expandedInner2DivId != sectionId) {
                transitionDelay = '0.3s';
                $scope.F_CO.collapseInner2Section();
            }
            var expandableDiv = angular.element('#' + sectionId);
            var expandableDivChildDivHeight = angular.element(angular.element('#' + sectionId + ' > div')[0]).outerHeight();
            $scope.M_CO.expandedInner2DivFlag = true;
            $scope.M_CO.expandedInner2DivId = sectionId;
            $scope.M_CO.expandedInner2SectionName = sectionName;
            expandElement(expandableDiv, expandableDivChildDivHeight, transitionDelay);
            var TimeoutVal = 500;
            if (transitionDelay) {
                TimeoutVal = 800;
            }
            setTimeout(function() {
              if(checkForDevice('iPad')) {
            expandableDiv.css('transition', 'none');
          }
                expandableDiv.css('height', 'auto');
                expandableDiv.css('overflow', 'visible');
                $scope.M_CO.expandedInner2SectionName = sectionName;
            }, TimeoutVal);
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                $scope.$apply(); //TODO
            }
        }
        //For Inner level-2 Accordian
        $scope.F_CO.collapseInner2Section = function() {
            $scope.M_CO.editLineItem = '';
            $scope.M_CO.isReplaceUnit = false;
            $scope.M_CO.TradeIn.IsCOUSelected = false;
            if ($scope.M_CO.expandedInner2DivId) {
                var collapsableDiv = angular.element('#' + $scope.M_CO.expandedInner2DivId)
                var expandableDivChildDivHeight = angular.element(angular.element('#' + $scope.M_CO.expandedInner2DivId + ' > div')[0]).outerHeight();
                collapsableDiv.css('height', expandableDivChildDivHeight);
                collapsableDiv.css('overflow', 'hidden');
                setTimeout(function() {
                    collapseElement(collapsableDiv);
                }, 20)
                $scope.M_CO.expandedInner2DivFlag = false;
                $scope.M_CO.expandedInner2DivId = '';
                $scope.M_CO.expandedInner2SectionName = '';
            }
        }
        /*$scope.F_CO.serviceJobopenAttachment = function(soHeaderIndex) {
            loadState($state, 'CustomerOrder_V2.serviceJobAddAttachment', {
                AddAttachmentParams: {
                    soHeaderIndex: soHeaderIndex,
                    'IsFfromNewUI': true
                }
            });
        }*/
        $scope.M_CO.splitFileNameByExtension = '';
        $scope.F_CO.viewAttachment = function(url,fileName) {
            $scope.M_CO.atchmntImgURL = url;
          if( $scope.F_CO.getFileExtension(fileName) ){
                angular.element('#ViewImage').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#ViewImage').show();
                angular.element("body").addClass("modal-open");
          } else {
            window.open(url, '_blank');
          }
        }
        $scope.F_CO.openDealFinanceStatusPopup = function(){
          angular.element('#dealFinancingStatusChange').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#dealFinancingStatusChange').show();
        }
        angular.element(document).on("click", "#dealFinancingStatusChange .modal-backdrop", function() {
          $scope.F_CO.DealFinance.closeChangeDFStatusDialog();
        });
        $scope.F_CO.getFileExtension = function(fileName){
          fileName = fileName.split(".");
          $scope.M_CO.splitFileNameByExtension = fileName[ fileName.length - 1 ];
          if($scope.M_CO.splitFileNameByExtension == 'png' || $scope.M_CO.splitFileNameByExtension == 'jpg' || $scope.M_CO.splitFileNameByExtension == 'bmp' || $scope.M_CO.splitFileNameByExtension == 'gif' || $scope.M_CO.splitFileNameByExtension == 'svg') {
            return true;
          }else {
            return false;
          }
        }
        angular.element(document).on("click", "#ViewImage .modal-backdrop", function() {
            $scope.F_CO.closeImage();
        });
        $scope.F_CO.closeImage = function() {
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            angular.element('#ViewImage').hide();
        }
        $scope.F_CO.resolveDealUnresolvedFulFillment = function(dealUnrslFlflmntObj) {
            if (!$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                return;
            }
            $scope.M_CO.Deal.resolvedFulFillment = dealUnrslFlflmntObj;
            angular.element('#unresolvedFulfillmentPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#unresolvedFulfillmentPopup').show();
            angular.element("body").addClass("modal-open");
            $scope.F_CO.StockUnitMap();
        }
        $scope.F_CO.openCOUpopup = function(event, COUId, soHeaderIndex, index) {
          $scope.M_CO.showCouPop = true;
          var indexCOU = 0;
          for (var i = 0; i < $scope.M_CO.COUList.length; i++) {
                if ($scope.M_CO.COUList[i].Id === COUId ) {
                  indexCOU = i;
                }
            }
          var unitRelated_Json = {
                    couId: COUId,
                    soHeaderIndex: soHeaderIndex,
                    index: indexCOU
                };
            setTimeout(function() {
                $scope.$broadcast('COUPopUpEvent', unitRelated_Json);
                applyCssOnPartPopUp(event, '.COUInfoPopup');
            }, 1000);
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
        $scope.F_CO.openDeleteConfirmationPopupForAttachment = function(SOHeaderIndex, SOHeaderId, AttachmentIndex, AttachmentId) {
            $scope.M_CO.deletableAttachment_SOHeader_Index = SOHeaderIndex;
            $scope.M_CO.deletableAttachment_SOHeader_Id = SOHeaderId;
            $scope.M_CO.deletableAttachment_Index = AttachmentIndex;
            $scope.M_CO.deletableAttachment_Id = AttachmentId;
            $scope.F_CO.removeAttachment();
        }
        $scope.F_CO.removeAttachment = function() {
            var elementId = 'SOHeader' + $scope.M_CO.deletableAttachment_SOHeader_Index + '_Attachment' + $scope.M_CO.deletableAttachment_Index;
            var successJson = {
                'type': 'getAttachmentList',
                'SOHeaderIndex': $scope.M_CO.deletableAttachment_SOHeader_Index,
                'elementId': elementId
            };
            AttachmentService.removeAttachment($scope.M_CO.deletableAttachment_Id, $scope.M_CO.deletableAttachment_SOHeader_Id).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.MoveToState = function(stateName, attr) {
            if (attr != undefined && attr != null && attr != '') {
                loadState($state, stateName, attr);
            } else {
                loadState($state, stateName);
            }
        }
        $scope.F_CO.openAddAttachmentPopup = function(index) {
            loadState($state, 'CustomerOrder_V2.ServiceJobAttachment', {
                AddAttachmentParams: {
                    soHeaderIndex: index,
                    IsFfromNewUI: true
                }
            });
        }
        var expandAccordion = function(sectionName) {
            if (sectionName == 'Service Job') {
                setTimeout(function() {
                    $scope.F_CO.expandedSection('ServiceJob0_SectionId', 'ServiceJob0', 0, ($scope.F_CO.getSOPermissionType()['view']));
                }, 100);
            } else if (sectionName == 'Unit Deal') {
                setTimeout(function() {
                    $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                }, 100);
            }
        }
        var getUnitDealDetails = function(param) {
            var successJson = {
                'type': 'getDealDetails',
                'gridName': param['gridName'],
                'expandInvoiceSection': param['expandInvoiceSection'],
                'expandSJInvoiceSection': param['expandSJInvoiceSection'],
                'callback': $scope.F_CO.getListOfFinanceCompany
            };
            DealService.getDealDetails($scope.M_CO.COHeaderId, param['gridName']).then(new success(successJson).handler, new error().handler);
            $scope.F_CO.getSpecialOrdersData();
        }
        var getSOHeaderDetails = function(param) {
            var successJson = {
                'type': 'getSOHeaderDetails',
                'callback': getUnitDealDetails,
                'callbackParam': {
                    'gridName': null,
                    'expandInvoiceSection': param['expandInvoiceSection'],
                    'expandSJInvoiceSection': param['expandSJInvoiceSection']
                }
            };
            if (!param['isDealCallback']) {
                successJson = {
                    'type': 'getSOHeaderDetails',
                    'stopLoadingIcon': true
                };
            }
            SOHeaderService.getSOHeaderDetails($scope.M_CO.COHeaderId, null).then(new success(successJson).handler, new error().handler);
        }
        var getSOMasterData = function() {
            var successJson = {
                'type': 'getSOMasterData',
                'callback': getSOHeaderDetails,
                'callbackParam': {
                    'isDealCallback': true
                }
            };
            SOHeaderService.getSOMasterData($scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
            if ($scope.M_CO.isReload) {
                if ($scope.M_CO.coHeaderRec.CustomerId && !$scope.M_CO.sellingGroup && !$scope.M_CO.DummyAccordion) {
                    setTimeout(function() {
                        $scope.F_CO.expandedSection('customerSectionId', 'customer');
                    }, 100);
                } else if ($scope.M_CO.IsShowMerchandiseSection || $scope.M_CO.COKHList.length > 0) {
                    setTimeout(function() {
                        $scope.F_CO.expandedSection('MerchandiseSectionId', 'MerchandiseSection', '', $rootScope.GroupOnlyPermissions['Merchandise']['view']);
                        if(!$scope.PartSmart.IsAddingFromPartSmart) {
                          var COKHList = angular.copy($scope.M_CO.COKHList);
                          if (COKHList && (COKHList.length > 0) && COKHList[(COKHList.length - 1)].Id) {
                              var CoKitHeaderIndex = COKHList.length - 1;
                              if ($scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'KHItem', '', CoKitHeaderIndex)) {
                                editCOKHItem('Merchandise_Section_COKitHeader', CoKitHeaderIndex);
                              } else {
                                  $scope.M_CO.editLineItem = '';
                              }
                          } else if (COKHList && (COKHList.length > 0) && COKHList[(COKHList.length - 1)].COLIList && COKHList[(COKHList.length - 1)].COLIList.length > 0) {
                              var CoKitHeaderIndex = COKHList.length - 1;
                              var CoLIIndex = COKHList[(COKHList.length - 1)].COLIList.length - 1;
                              if (COKHList[CoKitHeaderIndex].COLIList[CoLIIndex].EntityType === 'Env Fee') {
                                  CoKitHeaderIndex -= 1;
                                  CoLIIndex = COKHList[CoKitHeaderIndex].COLIList.length - 1;
                              }
                              if ($scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'NonKitLI', '', CoKitHeaderIndex, CoLIIndex)) {
                                  $scope.F_CO.editCOLineItem('Merchandise_Section_COKitHeader', CoKitHeaderIndex, CoLIIndex);
                              } else {
                                  $scope.M_CO.editLineItem = '';
                              }
                          }
                        }
                    }, 100);
                }
            }
        }

        function getSalesTaxDetailsForDeal(dealId) {
            var successJson = {
                'type': 'getSalesTaxDetailsForDeal'
            };
            DealService.getSalesTaxDetailsForDeal(dealId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.getCOCheckoutInfo = function() {
        getDeviceIdOnLoad();
        if(!$scope.M_CO.coHeaderRec.ActiveInvoiceId) {
            getActiveInvHeaderId();
        }
           if(!$scope.M_CO.showAssignCashDrawerModalWindow) {
              angular.element('#checkout-modal').modal({
                  backdrop: 'static',
                  keyboard: false
              });
            } else if($rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
              angular.element('#setCashDrawerModalWindow').modal({
                backdrop: 'static',
                keyboard: false
            });
              return;
            } else if(!$rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
                angular.element('#ErrorCashDrawerModalWindow').modal({
                backdrop: 'static',
                keyboard: false
            });
              return;
            }
           

         $scope.M_CO.showChangeModalWindow = false;
            if ($scope.M_CO.coHeaderRec.OrderStatus != 'Quote') {
        $scope.M_CO.isLoading = true;
        $scope.M_CO.showCheckoutModalWindow = false;
        $scope.CheckoutInfoModel.InvoiceItemList = [];

                $scope.CheckoutInfoModel.amountPaying = null;
                $scope.M_CO.isPrintInvoice = true;
                $scope.M_CO.isEmailInvoice = false;
                var successJson = {
                    'type': 'getCOCheckoutInfo'
                };
                CheckoutServices.getCOCheckoutInfo($scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
                $scope.CheckoutInfoModel.paymentMethod = null;
                $scope.M_CO.isCheckOutPartialSelect = false;
            }
            $scope.CheckoutInfoModel.tempPaymentDate = $scope.CheckoutInfoModel.paymentDate = getDateStringWithFormat(new Date(), $scope.M_CO.dateFormat);
            $scope.M_CO.tempInvoicePaymentDate = $scope.CheckoutInfoModel.invoicePaymentDate = getDateStringWithFormat(new Date(), $scope.M_CO.dateFormat);
            angular.element(".ui-state-default.ui-state-active").removeClass("is-error");
            $scope.M_CO.ishowPaymentDatePicker = false;
            $scope.M_CO.ishowInvoiceDatePicker = false;
            $('#paymentDate').datepicker("hide");
            $('#invoicepaymentDate').datepicker("hide");
        }
        
        $scope.F_CO.getCOHeaderDetailsByGridName = function() {
            loadAllCashDrawer();
            var successJson = {
                'type': 'getCOHeaderDetailsByGridName',
                'callback': getSOMasterData
            };
            SOHeaderService.getCOHeaderDetailsByGridName($stateParams.Id, null).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.callGetSOHeaderDetails = function(param) {
            getSOHeaderDetails(param);
        }
        $scope.F_CO.createSOHeader = function() {
            if (!($scope.F_CO.getSOPermissionType()['create/modify']) || $scope.F_CO.disableCreateServiceJobAction()) {
                return;
            }
            if ($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType == 'Cash Sale') {
                Notification.error($translate.instant('Please_select_a_customer_before_adding_to_this_order'));
                return;
            }
            if($scope.M_CO.isCreateSOActionIsInProgress) {
            	return;
            }
            if ($scope.M_CO.coHeaderRec.CustomerId != null && $scope.M_CO.coHeaderRec.CustomerId != undefined && $scope.M_CO.coHeaderRec.CustomerId != '') {
                $scope.M_CO.isLoading = true;
                $scope.M_CO.isCreateSOActionIsInProgress = true;
                var successJson = {
                    'type': 'createSOHeader'
                };
                
                SOHeaderService.createSOHeader($scope.M_CO.COHeaderId).then(function(successResult) {
                	$scope.M_CO.isCreateSOActionIsInProgress = false;
                	new success(successJson).handler(successResult);
		        }, function(errorResult) {
		        	$scope.M_CO.isCreateSOActionIsInProgress = false;
                    new error(successJson).handler(errorResult);
		        });
            } else {
                $scope.F_CO.expandedSection('customerSectionId', 'customer');
                $scope.M_CO.sellingGroup = 'Service Order';
                $scope.M_CO.DummyAccordion = 'Service Job';
                $scope.M_CO.IsShowMerchandiseSection = false;
            }
        }
        $scope.F_CO.createUnitDeal = function() {
          if ($scope.F_CO.disableCreateDealAction()) {
                return;
            }
            if ($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType == 'Cash Sale') {
                 Notification.error($translate.instant('Please_select_a_customer_before_adding_to_this_order'));
                return;
            }
            if ($scope.M_CO.coHeaderRec.CustomerId != null && $scope.M_CO.coHeaderRec.CustomerId != undefined && $scope.M_CO.coHeaderRec.CustomerId != '') {
                $scope.M_CO.isLoading = true;
                var successJson = {
                    'type': 'createUnitDeal'
                };
                DealService.createDeal($scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
            } else {
                $scope.F_CO.expandedSection('customerSectionId', 'customer');
                $scope.M_CO.sellingGroup = 'Unit Deal';
                $scope.M_CO.DummyAccordion = 'Unit Deal';
                $scope.M_CO.IsShowMerchandiseSection = false;
            }
            showTooltip('body');
        }
        $scope.F_CO.focusDFSummaryLoanTermType = function() {
            setTimeout(function() {
                $scope.F_CO.setFocusOnInput('dfSummaryLoanTermTypeInput');
            }, 100);
        }
        $scope.F_CO.focusDFSummaryPayFreq = function() {
            setTimeout(function() {
                $scope.F_CO.setFocusOnInput('dfSummaryPayFreqInput');
            }, 100);
        }
        $scope.F_CO.saveFinancingInfo = function(param, avoidRefresh,valueType) {
            if (isBlankValue($scope.M_CO.Deal.DealFinanceObj.Id)) {
                var successJson = {
                    'type': 'saveFinancingInfo',
                    'callback': $scope.F_CO.getListOfFinanceCompany,
                    'isCreateFinancingSection': param ? param.isCreateFinancingSection : false
                };
                $scope.M_CO.Deal.DealFinanceObj = {
                    'Status': 'Quotation'
                };
            } else {
                var successJson = {
                    'type': 'saveFinancingInfo',
                    'changeFinanceCompany': param ? param.changeFinanceCompany : false
                };
            }
            if(avoidRefresh){
               successJson.type = 'NONE';
            }
            var localDealFinanceObj = angular.copy($scope.M_CO.Deal.DealFinanceObj);
            if(valueType && valueType === 'Interest_Rate'){
              localDealFinanceObj.InterestRate = parseFloat(localDealFinanceObj.InterestRate);
            } else if(valueType &&  valueType === 'Down_Payment'){
              localDealFinanceObj.DownPayment  = parseFloat(localDealFinanceObj.DownPayment);
            } else if(valueType &&  valueType === 'Finance_Commission'){
              localDealFinanceObj.FinanceCommission  = parseFloat(localDealFinanceObj.FinanceCommission);
            }
            localDealFinanceObj.EstimatedPayment = $scope.F_CO.DealFinance.getEstimatedPayment();
            DealService.updateDealFinanceDetails($scope.M_CO.Deal.DealInfo.Id, angular.toJson(localDealFinanceObj)).then(function(successResult) {
                     new success(successJson).handler(successResult);
                    if(successResult.CoBuyerId) {
                       getCoBuyerDetails(successResult.CoBuyerId);
                    }




            }, new error().handler);

        }

         $scope.F_CO.removeCustomerCoBuyer = function() {
            $scope.M_CO.CustomerCOBuyerCardInfo = '';
            $scope.M_CO.Deal.showSearchCoBuyerDiv = false;
            $scope.M_CO.Deal.DealFinanceObj.CoBuyerId = null;
            $scope.F_CO.saveFinancingInfo('',true, false);
             setTimeout(function(){
              angular.element("#autocompleteCustomerCoBuyer").focus();
            },100);
        }

        $scope.F_CO.getPhoneNumber = function(entityJSON){
          var PhoneNumber;
          if (entityJSON.PreferredPhone) {
            if(entityJSON.PreferredPhone === 'HomeNumber') {
              PhoneNumber = entityJSON.FormattedHomeNumber;
            } else if(entityJSON.PreferredPhone === 'OtherPhone') {
              PhoneNumber = entityJSON.FormattedOtherPhone;
            } else if(entityJSON.PreferredPhone === 'WorkNumber') {
              PhoneNumber = entityJSON.FormattedWorkNumber;
            }
          } else {
            if(entityJSON.HomeNumber) {
              PhoneNumber = entityJSON.FormattedHomeNumber;
            } else if(entityJSON.WorkNumber) {
              PhoneNumber = entityJSON.FormattedWorkNumber;
            } else if((!entityJSON.WorkNumber && entityJSON.OtherPhone && entityJSON.CustomerType == 'Business')
                  || (!entityJSON.HomeNumber && entityJSON.OtherPhone && entityJSON.CustomerType == 'Individual')){
              PhoneNumber = entityJSON.FormattedOtherPhone;
            }
          }
          return PhoneNumber;
        }

        function getCoBuyerDetails (CoBuyerId) {
           DealService.getCoBuyer(CoBuyerId).then(function(successfulResult) {
                         $scope.M_CO.CustomerCOBuyerCardInfo = successfulResult
                         $scope.M_CO.isLoading = false;
                        }, function(errorSearchResult) {
                            Notification.error(errorSearchResult);
                });
        }
        $scope.F_CO.updateDealFinanceStatus = function() {
            if (!isBlankValue($scope.M_CO.DealFinance.Status)) {
                var successJson = {
                    'type': 'updateDealFinancingStatus'
                };
                DealService.updateDealFinanceStatus($scope.M_CO.COHeaderId, $scope.M_CO.Deal.DealInfo.Id, angular.toJson($scope.M_CO.Deal.DealFinanceObj), $scope.M_CO.Deal.DealFinanceObj.Status).then(new success(successJson).handler, new error().handler);
            }
        }
        var isMerchandiseSectionCreated = false;
        $scope.F_CO.createMerchandiseSection = function() {
        	
            if ($scope.F_CO.disableCreateMerchandiseAction() || isMerchandiseSectionCreated) {
                return;
            }
            if ($scope.M_CO.COHeaderId) {
                var successJson = {
                    'type': 'createMerchandiseSection'
                };
                merchandiseService.createMerchSection($scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
                isMerchandiseSectionCreated = true;
            } else {
              $scope.M_CO.sellingGroup = 'Part Sale';
                defaultActionAfterCreateMerchandise();
            }
        }

        function defaultActionAfterCreateMerchandise() {
            $scope.M_CO.DummyAccordion = '';
            $scope.M_CO.IsShowMerchandiseSection = true;
            showTooltip('body');
            setTimeout(function() {
                $scope.F_CO.expandedSection('MerchandiseSectionId', 'MerchandiseSection', '', $rootScope.GroupOnlyPermissions['Merchandise']['view']);
            }, 100);
        }
        $scope.F_CO.splitSOKHItem = function(SoHeaderIndex, soHeaderId, SOKHitemId) {
            var successJson = {
                'type': 'updateSOLineItem',
                'SOHeaderIndex': SoHeaderIndex
            };
            $scope.M_CO.isLoading = true;
            SOHeaderService.splitSOKHItem(SOKHitemId, soHeaderId).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.splitCOKHItem = function(COKHitemId) {
          $scope.M_CO.isLoading = true;
            var successJson = {
                'type': 'addCOLineItem'
            };
            merchandiseService.splitCOKHItem(COKHitemId, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }

        /**
         * method added for updating line items
         **/
        $scope.F_CO.updateLineItem = function(lineItem, sectionName, indexLevel1, indexLevel2, indexLevel3, confirmStatus, event) {
            if (sectionName === 'f_i_product') {
                $scope.F_CO.updateDealFinancingFandILineItem(lineItem, sectionName, indexLevel1, event);
            }
        }
        $scope.F_CO.SaveIpadLineItem = function() {
            $scope.M_CO.isShowSaveBtnForIpad = false;
            if(sectionTypeForIpad == 'Merchandise_Section_COKitHeader' && lineItemIndexForIpad >= 0){
                $scope.F_CO.UpdateCOLineItem (kitHeaderIndexForIpad,lineItemIndexForIpad,event);
            } 
            else if(sectionTypeForIpad == 'Merchandise_Section_COKitHeader' && lineItemIndexForIpad == -1) {
                $scope.F_CO.updateCOKHItem('Merchandise', kitHeaderIndexForIpad, event);
            }
            else if(sectionTypeForIpad == 'ServiceJob' && lineItemIndexForIpad >= 0) {
                $scope.F_CO.updateSOLineItem('ServiceJob', headerIndexForIpad, kitHeaderIndexForIpad, lineItemIndexForIpad, event)
            }
            else if(sectionTypeForIpad == 'ServiceJob' && lineItemIndexForIpad == -1) {
                $scope.F_CO.updateSOKHItem('ServiceJob', headerIndexForIpad, kitHeaderIndexForIpad, event);
            }
            else if(sectionTypeForIpad == 'deal' && lineItemIndexForIpad >= 0) {
                $scope.F_CO.updateOFLineItem('deal', headerIndexForIpad, kitHeaderIndexForIpad, lineItemIndexForIpad, event);
            }
            else if(sectionTypeForIpad == 'deal' && lineItemIndexForIpad == -1) {
                $scope.F_CO.updateOFKHItem('deal', headerIndexForIpad,kitHeaderIndexForIpad, event);
            }
            else if(sectionTypeForIpad == 'DealMerch_Section_COKitHeader' && lineItemIndexForIpad >= 0) {
                $scope.F_CO.UpdateDealCOLineItem(kitHeaderIndexForIpad, lineItemIndexForIpad, event);
            } 
            else if(sectionTypeForIpad == 'DealMerch_Section_COKitHeader' && lineItemIndexForIpad == -1) {
                $scope.F_CO.updateCOKHItem('DealMerch', kitHeaderIndexForIpad, event);
            }
            /* else if(sectionTypeForIpad == 'f_i_product' && (kitHeaderIndexForIpad || kitHeaderIndexForIpad == 0 )) {
                $scope.F_CO.updateLineItem(lineItemValue, 'f_i_product', kitHeaderIndexForIpad, '' , '', '', event);
            }  */
        }
        $scope.F_CO.editLineItem = function(lineItem, sectionName, indexLevel1, indexLevel2, indexLevel3, confirmStatus, isPart) {
            if ("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            if ((!confirmStatus && lineItem.Status === 'Ordered' && !lineItem.IsNonInventoryPart && (lineItem.EntityType == 'Part' || lineItem.IsPart) && lineItem.POStatus) || (!confirmStatus && lineItem.POStatus === 'Open'  && lineItem.IsSublet))  {
                var payload = {
                    "lineItem": lineItem,
                    "sectionName": sectionName,
                    "indexLevel1": indexLevel1,
                    "indexLevel2": indexLevel2,
                    "indexLevel3": indexLevel3,
                    "POStatus": lineItem.POStatus,
                    "VONumber": lineItem.VONumber
                };
                createLineItemModalDialogPayload(lineItem, payload, $Label.Your_changes_will_modify_the_existing_vendor_order);
                $scope.showLineItemEditConfirmationModal = true;
                return;
            }
            if (sectionName === 'ServiceJob') {
                if($scope.M_CO.SOHeaderList[indexLevel1].SOInfo.DealId && $scope.F_CO.isDealInvoiced()) {
            		return;
            	}
                if (!isNaN(indexLevel3)) {
                    $scope.F_CO.editSOLineItem(sectionName, indexLevel1, indexLevel2, indexLevel3, isPart);
                } else {
                    $scope.F_CO.editSOKHItem(sectionName, indexLevel1, indexLevel2);
                }
            } else if (sectionName === 'Merchandise_Section_COKitHeader') {
              if (!isNaN(indexLevel3)) {
                $scope.F_CO.editCOLineItem(sectionName, indexLevel1, indexLevel2, isPart);
                } else {
                    editCOKHItem(sectionName, indexLevel1);
                }
            } else if (sectionName === 'f_i_product') {
                $scope.F_CO.editDealFinancingFandILineItem(sectionName, indexLevel1);
            } else if (sectionName === 'DealMerch_Section_COKitHeader') {
                if(!$scope.F_CO.isDealInvoiced()) {
                	if (!isNaN(indexLevel3)) {
                    $scope.F_CO.editCOLineItem(sectionName, indexLevel1, indexLevel2, isPart);
                    } else {
                        editCOKHItem(sectionName, indexLevel1);
                    }
                }
            }
        }
        $scope.F_CO.updateDealFinancingFandILineItem = function(lineItem, sectionName, indexLevel1, event) {
            if ($scope.M_CO.isLoading) {
                return;
            }
            if (event) {
                if (event.type != "blur") {
                    UpdateDFFandILI(lineItem, indexLevel1);
                } else if (event.type == "blur" && !$scope.M_CO.isBlur) {
                    event.preventDefault();
                    $scope.M_CO.isBlur = true;
                    return;
                } else if (event.type == "blur" && $scope.M_CO.isBlur) {
                    UpdateDFFandILI(lineItem, indexLevel1);
                }
            }
        }

        function UpdateDFFandILI(lineItem, indexLevel1) {
            $scope.M_CO.isLoading = true;
            var successJson = {
                'type': 'saveDealFAndIProduct',
                'isAddMode': false,
                'IndexVal': indexLevel1
            };
            DealService.saveDealFAndIProduct($scope.M_CO.Deal.DealInfo.Id, JSON.stringify(lineItem)).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.editDealFinancingFandILineItem = function(sectionName, indexLevel1) {
            $scope.M_CO.editLineItem = sectionName + '_' + indexLevel1;
            showTooltip('body');
            setTimeout(function() {
                angular.element('#' + sectionName + '_' + indexLevel1 + '_Price').focus();
            }, 100);
        }
        $scope.F_CO.editSOLineItem = function(sectionName, SOHeaderIndex, SOKitHeaderIndex, SOLineItemIndex, isPart) {
            if("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            headerIndexForIpad = SOHeaderIndex;
            kitHeaderIndexForIpad = SOKitHeaderIndex;
            lineItemIndexForIpad = SOLineItemIndex;
            if ($scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].Id && !$scope.F_CO.displayEditBtnOnLineItem('SO', 'KitLI', SOHeaderIndex, SOKitHeaderIndex, SOLineItemIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex)) {
                clicky = null;
                return;
            } else if (!$scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].Id && !$scope.F_CO.displayEditBtnOnLineItem('SO', 'NonKitLI', SOHeaderIndex, SOKitHeaderIndex, SOLineItemIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex)) {
                clicky = null;
                return;
            } else if ($scope.M_CO.editLineItem === (sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex) || (isPart && $(clicky).closest('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_itemDesc').length) || $(clicky).closest('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_deleteBtn').length || $(clicky).closest('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_moreOptions').length) {
                clicky = null;
                return;
            }
            $scope.M_CO.editLineItem = sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex;
            showTooltip('body');
            setTimeout(function() {
                var SOLI = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].SOLIList[SOLineItemIndex];
                $scope.M_CO.oldDescriptionValue = SOLI.ItemDescription;
                if (!SOLI.IsPart) { // If Fee, sublet & Labour - then set focus on desc field
                    angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_itemDesc').focus();
                } else if (!$scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].Id && (SOLI.QtyNeeded >= 0 || (!(SOLI.QtyNeeded >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // If Qty filed is editable then set focus on it(For Not KitLI)
                    angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_QtyNeeded').focus();
                } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                    angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_Price').focus();
                }
            }, 100);
            clicky = null;
        }
        $scope.F_CO.editSOKHItem = function(sectionName, SOHeaderIndex, SOKitHeaderIndex) {
            if("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            headerIndexForIpad = SOHeaderIndex;
            kitHeaderIndexForIpad = SOKitHeaderIndex;
            if (!$scope.F_CO.displayEditBtnOnLineItem('SO', 'KHItem', SOHeaderIndex, SOKitHeaderIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex)) {
                clicky = null;
                return;
            } else if ($scope.M_CO.editLineItem === (sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex) || $(clicky).closest('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_deleteBtn').length) {
                clicky = null;
                return;
            }
            $scope.M_CO.editLineItem = sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex;
            showTooltip('body');
            setTimeout(function() {
                if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                    angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_Price').focus();
                }
            }, 100);
            clicky = null;
        }

        function editCOKHItem(sectionName, COKitHeaderIndex) {
            if("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            kitHeaderIndexForIpad = COKitHeaderIndex;
          if (sectionName === 'Merchandise_Section_COKitHeader' && !$scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'KHItem', '', COKitHeaderIndex) && $scope.M_CO.editLineItem !== (sectionName + COKitHeaderIndex)) {
                clicky = null;
                return;
            } else if (sectionName === 'DealMerch_Section_COKitHeader' && !$scope.F_CO.displayEditBtnOnLineItem('DealMerch', 'KHItem', '', COKitHeaderIndex) && $scope.M_CO.editLineItem !== (sectionName + COKitHeaderIndex)) {
                clicky = null;
                return;
            } else if ($scope.M_CO.editLineItem === (sectionName + COKitHeaderIndex) || $(clicky).closest('#' + sectionName + COKitHeaderIndex + '_deleteBtn').length) { // For both Merch & Deal Merch
                clicky = null;
                return;
            }
            $scope.M_CO.editLineItem = sectionName + COKitHeaderIndex;
            showTooltip('body');
            setTimeout(function() {
                if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it(This is for both Merch & Deal Merch)
                    angular.element('#' + sectionName + COKitHeaderIndex + '_Price').focus();
                }
            }, 100);
            clicky = null;
        }

        $scope.F_CO.editCOLineItem = function(sectionName, COKitHeaderIndex, COLineItemIndex, isPart) {
            if("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            kitHeaderIndexForIpad = COKitHeaderIndex;
            lineItemIndexForIpad = COLineItemIndex;
            if (sectionName === 'Merchandise_Section_COKitHeader' && $scope.M_CO.COKHList[COKitHeaderIndex].Id
              && !$scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'KitLI', '', COKitHeaderIndex, COLineItemIndex)
              && $scope.M_CO.editLineItem !== sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex) {
                clicky = null;
                return;
            } else if (sectionName === 'DealMerch_Section_COKitHeader' && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].Id
                && !$scope.F_CO.displayEditBtnOnLineItem('DealMerch', 'KitLI', '', COKitHeaderIndex, COLineItemIndex)
                && $scope.M_CO.editLineItem !== sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex) {
                clicky = null;
                return;
            } else if (sectionName === 'Merchandise_Section_COKitHeader' && !$scope.M_CO.COKHList[COKitHeaderIndex].Id
                && !$scope.F_CO.displayEditBtnOnLineItem('Merchandise', 'NonKitLI', '', COKitHeaderIndex, COLineItemIndex)
                && $scope.M_CO.editLineItem !== sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex) {
                clicky = null;
                return;
            } else if (sectionName === 'DealMerch_Section_COKitHeader' && !$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].Id
                && !$scope.F_CO.displayEditBtnOnLineItem('DealMerch', 'NonKitLI', '', COKitHeaderIndex, COLineItemIndex)
                && $scope.M_CO.editLineItem !== sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex) {
                clicky = null;
                return;
            } else if ($scope.M_CO.editLineItem === (sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex) || (isPart && $(clicky).closest('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_itemDesc').length) || $(clicky).closest('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_deleteBtn').length || $(clicky).closest('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_moreOptions').length) {
                clicky = null;
                return;
            }
            $scope.$evalAsync(function() {
                $scope.M_CO.editLineItem = sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex;
            });
            showTooltip('body');
            setTimeout(function() {
                var COLI = {};
                if (sectionName === 'Merchandise_Section_COKitHeader') {
                    COLI = $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex];
                    if (COLI.EntityType !== 'Part') { // If Fee, sublet & Labour - then set focus on desc field
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_itemDesc').focus();
                    } else if (!$scope.M_CO.COKHList[COKitHeaderIndex].Id && (COLI.Qty >= 0 || (!(COLI.Qty >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // If Qty filed is editable then set focus on it(For Not KitLI)
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Qty').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Price').focus();
                    }
                } else if (sectionName === 'DealMerch_Section_COKitHeader') {
                    COLI = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].COLIList[COLineItemIndex];
                    if (COLI.EntityType !== 'Part' && !COLI.IsPart) { // If Fee, sublet & Labour - then set focus on desc field
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_itemDesc').focus();
                    } else if (!$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].Id) { // If Qty filed is editable then set focus on it(For Not KitLI)(Currently Qty field always be editable (b/c still we don't have Returns functionality in Deal Merch section))
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Qty').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                      angular.element('#' + sectionName + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Price').focus();
                    }
                }
                $scope.M_CO.oldDescriptionValue = COLI.ItemDescription;
            }, 100);
            clicky = null;
        }
        $scope.F_CO.Deposit.selectPaymentMethod = function(paymentMethodName) {
            $scope.M_CO.Deposit.paymentMethod = paymentMethodName;
            $scope.M_CO.Deposit.selectPaymentMethodName = paymentMethodName;
            if($scope.M_CO.Deposit.selectPaymentMethodName == 'Store Credit' && $scope.M_CO.coHeaderRec.CustomerStoreCredit > 0 && !$scope.M_CO.Deposit.refundFlag) {
              $scope.M_CO.Deposit.deposit_Amount =  $scope.M_CO.coHeaderRec.CustomerStoreCredit.toFixed(2);
            } else if(!$scope.M_CO.Deposit.refundFlag) {
              $scope.M_CO.Deposit.deposit_Amount = '';
            }

            setTimeout(function() {
                angular.element("#depositAmount").focus();
            }, 100);
        }
        $scope.F_CO.closeReversePaymentConfirmationPopup = function() {
           angular.element('#ReversePaymentPopup').modal('hide');
           $scope.M_CO.isComingFromReverseDeposit = false;
        }
        $scope.F_CO.Deposit.ReversePaymentPopup = function(depositeJson) {
            $scope.F_CO.Deposit.DepositRec = depositeJson;
            $scope.M_CO.isComingFromReverseDeposit = true;
            getDeviceIdOnLoad();
          
          if(!$scope.M_CO.showAssignCashDrawerModalWindow) {
            angular.element('#ReversePaymentPopup').modal({
                  backdrop: 'static',
                  keyboard: false
            });
            } else if($rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
              angular.element('#setCashDrawerModalWindow').modal({
                 backdrop: 'static',
                 keyboard: false
              });
                return;
            } else if(!$rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
                angular.element('#ErrorCashDrawerModalWindow').modal({
                  backdrop: 'static',
                  keyboard: false
                });
                return;
            }
        }
        
        $scope.F_CO.Deposit.openAddDepositPopup = function() {
            $scope.M_CO.Deposit.deposit_Amount = ''
            $scope.M_CO.Deposit.paymentMethod = ''
            $scope.M_CO.Deposit.selectPaymentMethodName = ''
            $scope.M_CO.Deposit.refundFlag = false;
            $scope.M_CO.Deposit.isReverseDeposit = false;
            if ($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id && $scope.M_CO.Deal.DealInfo.DealStatus !== 'Invoiced') {
                $scope.M_CO.Deposit.depositType = 'Deal';
            } else {
                $scope.M_CO.Deposit.depositType = 'Customer';
            }
            $scope.M_CO.isComingFromAddDeposit = true;
            getDeviceIdOnLoad();
			 var Storeindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
                'MethodName': 'Store Credit',
            });
            if(Storeindex > -1) {
           		$scope.M_CO.Deposit.PaymentMethod.splice(Storeindex,1);
           	 }
            var Storeindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
                'MethodName': 'Store Credit',
            });
            if(Storeindex == -1 && ($scope.M_CO.Deposit.refundFlag || !$scope.M_CO.Deposit.refundFlag && $scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.CustomerStoreCredit > 0)) {
           		var obj = {}
            	obj.MethodName = 'Store Credit'
           		$scope.M_CO.Deposit.PaymentMethod.push(obj);
               }
       	 var Financedindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
                'MethodName': 'Financed',
            });
       	
       	 if(Financedindex > -1) {
        		$scope.M_CO.Deposit.PaymentMethod.splice(Financedindex,1);
        	 }
       	
    	 var Financedindex = _.findIndex($scope.M_CO.Deposit.PaymentMethod, {
             'MethodName': 'Financed',
         });
       	
       	if(Financedindex == -1 && $scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType == 'Financed' && $scope.M_CO.Deposit.depositType == 'Deal') {
        	   var obj = {}
           		obj.MethodName = 'Financed'
          		$scope.M_CO.Deposit.PaymentMethod.push(obj);
           }
           if(!$scope.M_CO.showAssignCashDrawerModalWindow) {
            angular.element('#AddDepositPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#AddDepositPopup').show();
            } else if($rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
              angular.element('#setCashDrawerModalWindow').modal({
                backdrop: 'static',
                keyboard: false
            });
              return;
            } else if(!$rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
                angular.element('#ErrorCashDrawerModalWindow').modal({
                backdrop: 'static',
                keyboard: false
            });
              return;
        }

           //$scope.M_CO.isComingFromAddDeposit = true;
           $scope.M_CO.showChangeModalWindow = false;
           $scope.M_CO.Deposit.tempPaymentDate = $scope.M_CO.todayDate;
           $scope.M_CO.Deposit.paymentDate = $scope.M_CO.todayDate;
        }

        $scope.F_CO.isDealSelectedForCheckout = function() {
          var invoiceItemsList = $scope.CheckoutInfoModel.InvoiceItemList ? $scope.CheckoutInfoModel.InvoiceItemList : [];
            for(var i = 0; i < invoiceItemsList.length; i++) {
              if(invoiceItemsList[i].CheckoutItemType === 'Deal' && invoiceItemsList[i].IsActive && invoiceItemsList[i].IsInvoiceable) {
                return true;
              }
            }
            return false;
        }

        $scope.F_CO.Deposit.isReverseDepositAvailable = function(depositRec) {
            var depositAmoutToBeUsed = depositRec.Deal ? $scope.M_CO.Deposit.TotalDealDepositAmount : $scope.M_CO.Deposit.TotalCustomerDepositAmount;
            if ($rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify'] && (!depositRec.ReverseLink && depositRec.Amount > 0)) {
                return true;
            }
            return false;
        }

        $scope.F_CO.Deposit.calculateDepositAmount = function(checkForCOClosure) {
            $scope.M_CO.Deposit.TotalDepositAmout = 0;
            $scope.M_CO.Deposit.TotalDealDepositAmount = 0;
            $scope.M_CO.Deposit.TotalCustomerDepositAmount = 0;
            for (var i = 0; i < $scope.M_CO.DepositList.length; i++) {
                var totalDeposit = roundDecimal($scope.M_CO.DepositList[i].Amount, 2);
                $scope.M_CO.Deposit.TotalDepositAmout = roundDecimal(($scope.M_CO.Deposit.TotalDepositAmout + totalDeposit), 2) ;
                if ($scope.M_CO.DepositList[i].Deal) {
                    $scope.M_CO.Deposit.TotalDealDepositAmount = roundDecimal(($scope.M_CO.Deposit.TotalDealDepositAmount + totalDeposit), 2);
                } else {
                   $scope.M_CO.Deposit.TotalCustomerDepositAmount = roundDecimal(($scope.M_CO.Deposit.TotalCustomerDepositAmount + totalDeposit), 2);
                }
            }
            if(checkForCOClosure && $scope.F_CO.isCustomerOrderClosable()) {
              CheckoutServices.closeCustomerOrder($scope.M_CO.COHeaderId).then(function(response) {
                $scope.M_CO.coHeaderRec.OrderStatus = 'Closed';
            }).catch(function(error) {
              handleErrorAndExecption(error);
          });
          }
        }

        $scope.F_CO.Deposit.setDepositAmount = function() {
            if ($scope.M_CO.Deposit.refundFlag) {
                if ($scope.M_CO.Deposit.depositType === 'Deal') {
                    $scope.M_CO.Deposit.deposit_Amount = $scope.M_CO.Deposit.TotalDealDepositAmount;
                } else {
                    $scope.M_CO.Deposit.deposit_Amount = $scope.M_CO.Deposit.TotalCustomerDepositAmount;
                }
            }
        }
        $scope.F_CO.Deposit.closeAddDepositPopup = function() {
            $scope.M_CO.Deposit.deposit_Amount = ''
            $scope.M_CO.Deposit.paymentMethod = ''
            $scope.M_CO.Deposit.selectPaymentMethodName = ''
            angular.element('#AddDepositPopup').modal('hide');
            //angular.element("body").removeClass("modal-open");
            //angular.element("body").css("padding", "0px");
            $scope.M_CO.Deposit.refundFlag = false;
            $scope.M_CO.isComingFromAddDeposit = false;
            $scope.M_CO.showChangeModalWindow = false;
        }

        $scope.F_CO.closeCheckOutPopup = function () {
          angular.element('#checkout-modal').modal('hide');
          angular.element("#checkout-modal").removeClass("in");
          angular.element("#checkout-modal").find('.modal-backdrop').remove();
          angular.element("body").removeClass("modal-open");
          $scope.M_CO.ishowPaymentDatePicker = false;
          $scope.M_CO.ishowInvoiceDatePicker = false;
          $scope.M_CO.ishowDepositDatePicker = false;
       }
        angular.element(document).on("click", "#AddDepositPopup .modal-backdrop", function() {
            $scope.F_CO.Deposit.closeAddDepositPopup();
        });
        angular.element(document).on("click", "#checkout-modal .modal-backdrop", function() {
            $scope.F_CO.closeCheckOutPopup();
        });
        angular.element(document).on("click", "#setCashDrawerModalWindow .modal-backdrop", function() {
             $scope.F_CO.closeSetCashDrawerModalWindow();
        });
         angular.element(document).on("click", "#ErrorCashDrawerModalWindow .modal-backdrop", function() {
             $scope.F_CO.hideErrorCashDrawer();
        });
         
        angular.element(document).on("click", "#ReversePaymentPopup .modal-backdrop", function() {
           $scope.F_CO.closeReversePaymentConfirmationPopup();
        });
         

         $scope.F_CO.closeSetCashDrawerModalWindow = function() {
           angular.element('#setCashDrawerModalWindow').modal('hide');
           $scope.M_CO.isComingFromAddDeposit = false;
           $scope.M_CO.isComingFromReverseDeposit = false;
           $scope.M_CO.cashDrawerId = '';
           $scope.M_CO.isErrorCashDrawer = false;
         }
        
        $scope.F_CO.Deposit.calculateLeftPanelDeposits = function() {
            var deposits = 0;
            for (var i = 0; i < $scope.M_CO.DepositList.length; i++) {
                if (!($scope.M_CO.DepositList[i].PaymentMethod == 'Invoice' && ($scope.M_CO.DepositList[i].COInvoiceNumber == '' || $scope.M_CO.DepositList[i].COInvoiceNumber == null))) {
                    deposits += $scope.M_CO.DepositList[i].Amount;
                }
            }
            deposits = deposits.toFixed(2);
            deposits = deposits - $scope.F_CO.Deposit.calculateDepositUsed();
            return deposits;
        }
        $scope.F_CO.Deposit.calculateDepositUsed = function() {
            var PaymentList = $scope.CheckoutInfoModel.InvoicePaymentList;
            var depositUsed = 0;
            for (var i = 0; i < PaymentList.length; i++) {
                if (PaymentList[i].PaymentMethod == 'Use Deposit' || PaymentList[i].PaymentMethod == 'Use Deal Deposit') {
                    depositUsed += PaymentList[i].Amount;
                }
            }
            return parseFloat(depositUsed.toFixed(2));
        }
        $scope.F_CO.calculateTotalPaymentsandDeposits = function() {
            return $scope.M_CO.Deposit.TotalDepositAmout + $scope.M_CO.coHeaderRec.TotalPayments;
        }
        $scope.F_CO.Deposit.ReverseDeposit = function(deposit) {
          $scope.M_CO.isLoading = true;
            $scope.M_CO.Deposit.isReverseDeposit = true;
            $scope.M_CO.Deposit.paymentMethod = deposit.PaymentMethod;
            $scope.M_CO.Deposit.deposit_Amount = -(deposit.Amount);
            $scope.M_CO.Deposit.reverse_Link = deposit.CODepositId;
            $scope.M_CO.Deposit.Deal = deposit.Deal;
            $scope.F_CO.Deposit.addDeposit();
        }

        function restReverseDepositData() {
          $scope.M_CO.isLoading = false;
            $scope.M_CO.Deposit.isReverseDeposit = false;
            $scope.M_CO.Deposit.paymentMethod = "";
            $scope.M_CO.Deposit.deposit_Amount = "";
            $scope.M_CO.Deposit.reverse_Link = "";
            $scope.M_CO.Deposit.Deal = null;
        }

        $scope.F_CO.Deposit.refundDepositBtnClick = function() {
            if ($scope.M_CO.Deposit.deposit_Amount > 0) {
                var deposit = {};
                deposit.PaymentMethod = $scope.M_CO.Deposit.PaymentMethod;
                deposit.Amount = $scope.M_CO.Deposit.deposit_Amount;
                deposit.CODepositId = null;
                deposit.Deal = null;
                $scope.F_CO.Deposit.ReverseDeposit(deposit);
                $scope.F_CO.Deposit.addDeposit();
            }
        }

        $scope.F_CO.checkToAddDealFinanceDepositTotal = function(){
          var totalFinanceDeposit = 0;
          for (var i = 0; i < $scope.M_CO.DepositList.length; i++) {
                 if ($scope.M_CO.DepositList[i].Deal && $scope.M_CO.DepositList[i].PaymentMethod === 'Financed') {
                   totalFinanceDeposit += $scope.M_CO.DepositList[i].Amount;
                 }
             }
          if($scope.F_CO.DealFinance.getAmountFinanced()  < $scope.M_CO.Deposit.deposit_Amount){
            return false;
          }else if( $scope.F_CO.DealFinance.getAmountFinanced() - (totalFinanceDeposit + parseFloat($scope.M_CO.Deposit.deposit_Amount)) < 0){
            return false;
          }
          return true;
        }

        $scope.F_CO.Deposit.addDeposit = function() {
            var deposits = [];
            var depositModel = {};
            var maxDeposit = 999999.99;
            depositModel.PaymentMethod = $scope.M_CO.Deposit.paymentMethod;
            if (!$scope.M_CO.Deposit.refundFlag) {
                depositModel.Amount = $scope.M_CO.Deposit.deposit_Amount;
            } else {
                depositModel.Amount = -($scope.M_CO.Deposit.deposit_Amount);
            }
            if ($scope.M_CO.Deposit.paymentMethod == 'Store Credit' && !$scope.M_CO.Deposit.refundFlag && $scope.M_CO.Deposit.deposit_Amount > $scope.M_CO.coHeaderRec.CustomerStoreCredit) {
                Notification.error($translate.instant('Deposit cannot be greater than store credit amount'));
                return;
            }

            if ($scope.M_CO.Deposit.paymentMethod == 'Financed' && ( !$scope.F_CO.checkToAddDealFinanceDepositTotal())) {
                Notification.error($translate.instant('Deposit_cannot_be_greater_than_amount_financed'));
                return;
            }
            depositModel.COHeaderId = $scope.M_CO.COHeaderId;
            depositModel.ReverseLink = $scope.M_CO.Deposit.reverse_Link;
            depositModel.PaymentDate = $scope.M_CO.Deposit.paymentDate;
            var depositAmoutToBeUsed = 0;
            if($scope.M_CO.Deposit.isReverseDeposit && !$scope.M_CO.Deposit.refundFlag) {
                depositModel.Deal = $scope.M_CO.Deposit.Deal;
            } else {
                if ($scope.M_CO.Deposit.depositType === 'Deal') {
                    depositModel.Deal = $scope.M_CO.Deal.DealInfo != undefined ? $scope.M_CO.Deal.DealInfo.Id : null;
                } else {
                    depositModel.Deal = null;
                }
            }
            if (depositModel.Deal) {
                depositAmoutToBeUsed = $scope.M_CO.Deposit.TotalDealDepositAmount;
            } else {
                depositAmoutToBeUsed = $scope.M_CO.Deposit.TotalCustomerDepositAmount; // TotalDepositAmout
            }

            if ((parseFloat(depositAmoutToBeUsed) < (parseFloat(depositModel.Amount) * -1)) && $scope.M_CO.Deposit.isReverseDeposit && depositModel.ReverseLink != undefined && depositModel.ReverseLink != '' && depositModel.ReverseLink != null) { //for reverse
                $scope.M_CO.Deposit.deposit_Amount = (-1 * $scope.M_CO.Deposit.deposit_Amount).toFixed(2);
                restReverseDepositData();
                $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('CustomerOrder_Js_Total_deposit_received'));
                return;
            }
            if (depositModel.Amount == "") {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Please_enter_amount'));
                return;
            } else if ((+(parseFloat(depositModel.Amount))).toFixed(2) == 0) {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Amount_Can_t_be_zero'));
                return;
            } else if (isNaN(depositModel.Amount)) {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Amount_should_be_numeric'));
                return;
            } else if (parseFloat(depositModel.Amount) < 0 && $scope.M_CO.Deposit.isReverseDeposit && (depositModel.ReverseLink == undefined || depositModel.ReverseLink == '' || depositModel.ReverseLink == null)) {
                if (parseFloat(depositModel.Amount) * -1 > depositAmoutToBeUsed) {
                  $scope.M_CO.isLoading = false;
                  $scope.F_CO.closeReversePaymentConfirmationPopup();
                    Notification.error($translate.instant('Amount_can_t_be_greater_than_total_deposit_received'));
                    $scope.M_CO.Deposit.isReverseDeposit = false;
                    $scope.M_CO.Deposit.deposit_Amount = (-1 * $scope.M_CO.Deposit.deposit_Amount).toFixed(2);
                    return;
                }
            } else if (parseFloat(depositModel.Amount) < 0 && !$scope.M_CO.Deposit.isReverseDeposit) {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Amount_should_be_positive'));
                return;
            } else if (parseFloat(depositModel.Amount) < -1 * depositAmoutToBeUsed) {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Total_can_t_be_negative'));
                return;
            } else if (parseFloat(depositModel.Amount) > maxDeposit) {
              $scope.M_CO.isLoading = false;
              $scope.F_CO.closeReversePaymentConfirmationPopup();
                Notification.error($translate.instant('Amount_cannot_exceed_six_digits'));
                return;
            }

            depositModel.Amount = (+(depositModel.Amount)).toFixed(2);

            if($scope.M_CO.Deposit.paymentMethod == 'Store Credit') {
                if(!$scope.M_CO.Deposit.refundFlag) {
                  $scope.M_CO.coHeaderRec.CustomerStoreCredit = $scope.M_CO.coHeaderRec.CustomerStoreCredit - $scope.M_CO.Deposit.deposit_Amount;
                } else {
                   $scope.M_CO.coHeaderRec.CustomerStoreCredit = $scope.M_CO.coHeaderRec.CustomerStoreCredit - depositModel.Amount;
                }
            }
            depositModel.CashDrawerId  = $scope.M_CO.selectedcashDrawerId;
            deposits.push(depositModel);
            var successJson = {
                'type': 'AddDepositAmount'
            };
            AddDepositService.AddDeposit(JSON.stringify(deposits)).then(new success(successJson).handler, new error().handler);
            $scope.M_CO.Deposit.isReverseDeposit = false;
            $scope.M_CO.Deposit.deposit_Amount = "";
            $scope.M_CO.Deposit.paymentMethod = "Cash";
            $scope.M_CO.Deposit.reverse_Link = "";
        }
        $scope.F_CO.editOptionFee = function(sectionName, unitIndex, kitHeaderIndex, optionFeeIndex, isPart) {
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            headerIndexForIpad = unitIndex;
            kitHeaderIndexForIpad = kitHeaderIndex;
            lineItemIndexForIpad = optionFeeIndex;
            if("ontouchstart" in document.documentElement) { 
                $scope.M_CO.isShowSaveBtnForIpad = true;
            }
            if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id && !$scope.F_CO.displayEditBtnOnLineItem('OptionFee', 'KitLI', unitIndex, kitHeaderIndex, optionFeeIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex)) {
                clicky = null;
                return;
            } else if (!$scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id && !$scope.F_CO.displayEditBtnOnLineItem('OptionFee', 'NonKitLI', unitIndex, kitHeaderIndex, optionFeeIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex)) {
                clicky = null;
                return;
            } else if (($scope.M_CO.editLineItem === (sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex)) || (isPart && $(clicky).closest('#' + sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex + '_itemDesc').length) || $(clicky).closest('#' + sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex + '_deleteBtn').length || $(clicky).closest('#' + sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex + '_IsInstallFlag').length) {
                clicky = null;
                return;
            }
            $scope.M_CO.editLineItem = sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_of' + optionFeeIndex;
            showTooltip('body');
            setTimeout(function() {
                var OFLI = $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[optionFeeIndex]
                $scope.M_CO.oldDescriptionValue = OFLI.ItemDescription;
                setFocusOnLIsFirstEditableField('OptionFee', unitIndex, kitHeaderIndex, optionFeeIndex, ($scope.M_CO.editLineItem), true, OFLI);
            }, 100);
            clicky = null;
        }
        $scope.F_CO.editDealKHItem = function(sectionName, unitIndex, kitHeaderIndex) {
            if("ontouchstart" in document.documentElement) {
                $scope.M_CO.isShowSaveBtnForIpad = true;
            } 
            kitHeaderIndexForIpad = -1;
            lineItemIndexForIpad = -1;
            sectionTypeForIpad = '';
            headerIndexForIpad = -1;

            sectionTypeForIpad = sectionName;
            headerIndexForIpad = unitIndex;
            kitHeaderIndexForIpad = kitHeaderIndex;
            if (!$scope.F_CO.displayEditBtnOnLineItem('OptionFee', 'KHItem', unitIndex, kitHeaderIndex) && $scope.M_CO.editLineItem !== (sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex)) {
                clicky = null;
                return;
            } else if ($scope.M_CO.editLineItem === (sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex) || $(clicky).closest('#' + sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_deleteBtn').length || $(clicky).closest('#' + sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex + '_IsInstallFlag').length) {
                clicky = null;
                return;
            }
            $scope.M_CO.editLineItem = sectionName + '_' + 'unit' + unitIndex + '_kit' + kitHeaderIndex;
            showTooltip('body');

            setFocusOnLIsFirstEditableField('OptionFee', unitIndex, kitHeaderIndex, '', ($scope.M_CO.editLineItem), false, '', true);
            clicky = null;
        }

        function setFocus(lineItemId) {
            setTimeout(function() {
                angular.element('#' + lineItemId).focus();
            }, 100);
        }
        $scope.F_CO.updateSOLineItem = function(sectionName, SOHeaderIndex, SOKitHeaderIndex, SOLineItemIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            var SOLineItemJson = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].SOLIList[SOLineItemIndex];
            $scope.M_CO.editLineItemIndex = SOKitHeaderIndex;
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if (focusedElement && focusedElement.id && ((focusedElement.id.indexOf(sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex) !== -1) || ($scope.M_CO.deletedItemGridName === 'Service Job' && focusedElement.id.indexOf('MoveLineItemId') !== -1))) {
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (clicky && (clicky.id === 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex || $(clicky).closest('tr#SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex).length || $(clicky).closest('tr#SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_StockCommitted').length || $(clicky).closest('tr#SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_QtyOrder').length || $(clicky).closest('tr#SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_AvailableInventory').length || ($scope.M_CO.deletedItemGridName === 'Service Job' && $scope.M_CO.deletableSOLI_Id))) {
                    var SOLI = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].SOLIList[SOLineItemIndex]
                    if (!SOLI.IsPart) { // If Fee, sublet & Labour - then set focus on desc field
                        angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_itemDesc').focus();
                    } else if (!$scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex].Id && (SOLI.QtyNeeded >= 0 || (!(SOLI.QtyNeeded >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // If Qty filed is editable then set focus on it(For Not KitLI)
                        angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_QtyNeeded').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                        angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_SOLI' + SOLineItemIndex + '_Price').focus();
                    }
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    if(isBlankValue(SOLineItemJson.ItemDescription)) {
                        if(!isBlankValue($scope.M_CO.oldDescriptionValue)) {
                            SOLineItemJson.ItemDescription = $scope.M_CO.oldDescriptionValue;
                        } else {
                            return;
                        }
                    }
                    clicky = null;
                    if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                      angular.element("#autocompleteServiceJob" + SOHeaderIndex).focus();
                    }
                    createLineItemModalDialogPayload(SOLineItemJson);
                    if (isBlankValue(SOLineItemJson.DealItemId) && isBlankValue(SOLineItemJson.DealId)) {
                        updateServiceOrderLineItem(SOLineItemJson, 'updateSOLineItem', SOHeaderIndex);
                    } else {
                        updateServiceOrderLineItem(SOLineItemJson, 'updateDealSOLineItem', SOHeaderIndex);
                    }
                }
            }
        }
        $scope.F_CO.updateSOKHItem = function(sectionName, SOHeaderIndex, SOKitHeaderIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            $scope.M_CO.editLineItemIndex = SOKitHeaderIndex;
            var SOKHItemJson = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOGridItems[SOKitHeaderIndex];
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if (focusedElement && focusedElement.id && ($scope.M_CO.deletedItemGridName === 'Service Job' && $scope.M_CO.deletableSOLI_SoKitHeader_Id && focusedElement.id.indexOf('MoveLineItemId') !== -1)) {
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (clicky && (clicky.id === 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex || $(clicky).closest('tr#SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex).length || ($scope.M_CO.deletedItemGridName === 'Service Job' && $scope.M_CO.deletableSOLI_SoKitHeader_Id))) {
                    if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                        angular.element('#' + sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_SOKitHeader' + SOKitHeaderIndex + '_Price').focus();
                    }
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    clicky = null;
                    if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                      angular.element("#autocompleteServiceJob" + SOHeaderIndex).focus();
                    }
                    createLineItemModalDialogPayload(SOKHItemJson);
                      updateServiceOrderKitHeaderItem(SOKHItemJson, 'updateSOLineItem', SOHeaderIndex);
                }
            }
        }

        function updateServiceOrderKitHeaderItem(SOKHItemJson, functionType, SOHeaderIndex) {
            $scope.M_CO.isLoading = true;
            var SOHeaderId = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOInfo.Id;
            var successJson = {
                'type': functionType,
                'SOHeaderIndex': SOHeaderIndex
            };
            SOHeaderService.updateSOKHItem(angular.toJson(SOKHItemJson), SOHeaderId).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.openMoveOrDeleteConfirmationPopup = function(headerIndex, headerId, kitHeaderIndex, kitHeaderId, lineItemIndex, lineItemId, gridName, isOpenMoveLIModal) {
          $scope.M_CO.deletedItemName = 'this item';
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableLI_SectionHeader_Index = headerIndex;
            $scope.M_CO.deletableLI_SectionHeader_Id = headerId;
            $scope.M_CO.deletableLI_KitHeader_Index = kitHeaderIndex;
            $scope.M_CO.deletableLI_KitHeader_Id = kitHeaderId;
            $scope.M_CO.deletableLI_Index = lineItemIndex;
            $scope.M_CO.deletableLI_Id = lineItemId;

            var deletableElementId = '';
            if(gridName === 'Merchandise' || gridName === 'DealMerch') {
              deletableElementId = gridName + '_Section_COKitHeader' + kitHeaderIndex;
              if (!kitHeaderId) {
                    deletableElementId += '_COLI' + lineItemIndex;
                }
            }

            if (!isOpenMoveLIModal) {
                openDeleteConfirmationModalWindow(deletableElementId);
            } else {
                openMoveLineItemConfirmationModalWindow(deletableElementId);
            }
        }

        $scope.F_CO.updateCOKHItem = function(sectionName, COKitHeaderIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if(sectionName === 'Merchandise') {
                  var COKHItemJson = $scope.M_CO.COKHList[COKitHeaderIndex];
                  if (focusedElement && focusedElement.id && ($scope.M_CO.deletedItemGridName === 'Merchandise' && $scope.M_CO.deletableLI_KitHeader_Id && focusedElement.id.indexOf('MoveLineItemId') !== -1)) {
                        clicky = null;
                        $scope.M_CO.isTabKeyPressed = false;
                        return;
                    } else if (clicky && (clicky.id === 'Merchandise_Section_COKitHeader' + COKitHeaderIndex || $(clicky).closest('tr#Merchandise_Section_COKitHeader' + COKitHeaderIndex).length || ($scope.M_CO.deletedItemGridName === 'Merchandise' && $scope.M_CO.deletableLI_KitHeader_Id))) {
                        if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                            angular.element('#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_Price').focus();
                        }
                        clicky = null;
                        $scope.M_CO.isTabKeyPressed = false;
                        return;
                    } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                        clicky = null;
                        if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                          angular.element("#autocompleteMerchandiseSectionWrapperId").focus();
                        }
                        //createLineItemModalDialogPayload(COKHItemJson);
                        $scope.M_CO.isLoading = true;
                        var successJson = {};
                        successJson = {
                            'type': 'addCOLineItem',
                            "COKitHeaderIndex": COKitHeaderIndex
                        };
                         merchandiseService.updateCOKHLineItemsRecalculation(angular.toJson(COKHItemJson), $scope.M_CO.COHeaderId, 'null').then(new success(successJson).handler, new error().handler);
                    }
                } else if(sectionName === 'DealMerch') {
                  var COKHItemJson = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex];
                  if (focusedElement && focusedElement.id && ($scope.M_CO.deletedItemGridName === 'DealMerch' && $scope.M_CO.deletableLI_KitHeader_Id && focusedElement.id.indexOf('MoveLineItemId') !== -1)) {
                        clicky = null;
                        $scope.M_CO.isTabKeyPressed = false;
                        return;
                    } else if (clicky && (clicky.id === 'DealMerch_Section_COKitHeader' + COKitHeaderIndex || $(clicky).closest('tr#DealMerch_Section_COKitHeader' + COKitHeaderIndex).length || ($scope.M_CO.deletedItemGridName === 'DealMerch' && $scope.M_CO.deletableLI_KitHeader_Id))) {
                        if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                            angular.element('#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_Price').focus();
                        }
                        clicky = null;
                        $scope.M_CO.isTabKeyPressed = false;
                        return;
                    } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                        clicky = null;
                        if($scope.M_CO.isTabKeyPressed  && ("ontouchstart" in document.documentElement == false)) {
                          angular.element("#autocompleteDealMerchSectionWrapperId").focus();
                        }
                        //createLineItemModalDialogPayload(COKHItemJson);
                        $scope.M_CO.isLoading = true;
                        var successJson = {};
                        successJson = {
                            'type': 'addDealCOLineItem',
                            "COKitHeaderIndex": COKitHeaderIndex
                        };
                        merchandiseService.updateCOKHLineItemsRecalculation(angular.toJson(COKHItemJson), $scope.M_CO.COHeaderId, 'null').then(new success(successJson).handler, new error().handler);
                    }
                }
            }
        }
        
        
        $scope.F_CO.UpdateCOLineItem = function(COKitHeaderIndex, COLineItemIndex, event) {
            /*Start: Cash Sale Oversold Functionality*/
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
          if (!$scope.M_CO.coHeaderRec.CustomerId && $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].EntityType == 'Part'
              && !$scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].IsNonInventoryPart
              && $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].Qty > ($scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].AvaliablePartsQty + $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].QtyCpy)) {
            $scope.M_CO.IsNewLineItemInserted = false;
            $scope.M_CO.isOutOfStockPart = true;
            $scope.M_CO.recentlyUpdatedLineItem = $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex];
            $scope.F_CO.showOversoldPopup();
            return;
          }
          /*End: Cash Sale Oversold Functionality*/
            var COLineItemJson = [];
            COLineItemJson.push($scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex]);
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if (focusedElement && focusedElement.id && ((focusedElement.id.indexOf('Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex) !== -1) || ($scope.M_CO.deletedItemGridName === 'Merchandise' && focusedElement.id.indexOf('MoveLineItemId') !== -1))) {
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (clicky && (clicky.id === 'Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex || $(clicky).closest('tr#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex).length || $(clicky).closest('tr#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_StockCommittedSection').length || $(clicky).closest('tr#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_QtyOrder').length || $(clicky).closest('tr#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_AvailableInventory').length || $scope.M_CO.deletedItemGridName === 'Merchandise' && $scope.M_CO.deletableLI_Id)) {
                    var COLI = $scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex];
                    if (COLI.EntityType !== 'Part') { // If Fee, sublet & Labour - then set focus on desc field
                        angular.element('#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_itemDesc').focus();
                    } else if (!$scope.M_CO.COKHList[COKitHeaderIndex].Id && (COLI.Qty >= 0 || (!(COLI.Qty >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // If Qty filed is editable then set focus on it(For Not KitLI)
                        angular.element('#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Qty').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                        angular.element('#Merchandise_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Price').focus();
                    }
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    if(isBlankValue($scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].ItemDescription)) {
                		if(!isBlankValue($scope.M_CO.oldDescriptionValue)) {
                			$scope.M_CO.COKHList[COKitHeaderIndex].COLIList[COLineItemIndex].ItemDescription = $scope.M_CO.oldDescriptionValue;
                		} else {
                			return;
                		}
                	}
                    clicky = null;
                    $scope.M_CO.isLoading = true;
                    createLineItemModalDialogPayload(COLineItemJson[0]);
                    if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                      angular.element('#autocompleteMerchandiseSectionWrapperId').focus();
                    }
                    var successJson = {};
                    successJson = {
                        'type': 'addCOLineItem',
                        'COKitHeaderIndex' : COKitHeaderIndex
                    };
                   if($scope.M_CO.COKHList[COKitHeaderIndex].Id) { // For Kit LI
                      merchandiseService.updateCOKHLineItemsRecalculation(angular.toJson($scope.M_CO.COKHList[COKitHeaderIndex]), $scope.M_CO.COHeaderId, angular.toJson(COLineItemJson[0])).then(new success(successJson).handler, new error().handler);
                    } else {// For Non Kit LI
                      merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(COLineItemJson), null).then(new success(successJson).handler, new error().handler);
                    }
                }
            }
        }

        $scope.F_CO.UpdateDealCOLineItem = function(COKitHeaderIndex, COLineItemIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            var COLineItemJson = [];
            COLineItemJson.push($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].COLIList[COLineItemIndex]);
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if (focusedElement && focusedElement.id && (focusedElement.id.indexOf('DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex) !== -1)) {
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (clicky && (clicky.id === 'DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex || $(clicky).closest('tr#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex).length || $(clicky).closest('tr#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_StockCommittedSection').length || $(clicky).closest('tr#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_QtyOrder').length || $(clicky).closest('tr#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_AvailableInventory').length || $scope.M_CO.deletedItemGridName === 'Deal Merch')) {
                    var COLI = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].COLIList[COLineItemIndex];
                    if (COLI.EntityType !== 'Part' && !COLI.IsPart) { // If Fee, sublet & Labour - then set focus on desc field
                      angular.element('#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_itemDesc').focus();
                    } else if (!$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].Id) { // If Qty filed is editable then set focus on it(For Not KitLI)(Currently Qty field always be editable (b/c still we don't have Returns functionality in Deal Merch section))
                      angular.element('#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Qty').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                      angular.element('#DealMerch_Section_COKitHeader' + COKitHeaderIndex + '_COLI' + COLineItemIndex + '_Price').focus();
                    }
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    if(isBlankValue($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].COLIList[COLineItemIndex].ItemDescription)) {
                		if(!isBlankValue($scope.M_CO.oldDescriptionValue)) {
                			$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].COLIList[COLineItemIndex].ItemDescription = $scope.M_CO.oldDescriptionValue;
                		} else {
                			return;
                		}
                	}
                    clicky = null;
                    $scope.M_CO.isLoading = true;
                    createLineItemModalDialogPayload(COLineItemJson[0]);
                    if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                      angular.element("#autocompleteDealMerchSectionWrapperId").focus();
                    }
                    var successJson = {};
                    successJson = {
                        'type': 'addDealCOLineItem',
                        'COKitHeaderIndex' : COKitHeaderIndex
                    };

                   if($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex].Id) { // For Kit LI
                      merchandiseService.updateCOKHLineItemsRecalculation(angular.toJson($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[COKitHeaderIndex]), $scope.M_CO.COHeaderId, angular.toJson(COLineItemJson[0])).then(new success(successJson).handler, new error().handler);
                    } else {// For Non Kit LI
                      merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(COLineItemJson), null).then(new success(successJson).handler, new error().handler);
                    }
                }
            }
        }
        $scope.F_CO.updateOFLineItem = function(sectionName, UnitIndex, OFKitHeaderIndex, OFLineItemIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            if ($scope.M_CO.isLoading) {
                return;
            }
            var OFLineItemJson = $scope.M_CO.Deal.UnitList[UnitIndex].DealKitHeaderList[OFKitHeaderIndex].OptionAndFeeList[OFLineItemIndex];
            var kitHeaderJSON = $scope.M_CO.Deal.UnitList[UnitIndex].DealKitHeaderList[OFKitHeaderIndex];
            var focusedElement;
            if (event) {
                focusedElement = event.relatedTarget;
                if (focusedElement && focusedElement.id && (focusedElement.id.indexOf(sectionName + '_' + 'unit' + UnitIndex + '_kit' + OFKitHeaderIndex + '_of' + OFLineItemIndex) !== -1)) {
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (clicky && (clicky.id === sectionName + '_' + 'unit' + UnitIndex + '_kit' + OFKitHeaderIndex + '_of' + OFLineItemIndex || $(clicky).closest('tr#' + sectionName + '_' + 'unit' + UnitIndex + '_kit' + OFKitHeaderIndex + '_of' + OFLineItemIndex).length || ($scope.M_CO.deletedItemGridName === 'deal' && $scope.M_CO.deletableOptionFee_Id))) {
                    var OFLI = $scope.M_CO.Deal.UnitList[UnitIndex].DealKitHeaderList[OFKitHeaderIndex].OptionAndFeeList[OFLineItemIndex]
                    setFocusOnLIsFirstEditableField('OptionFee', UnitIndex, OFKitHeaderIndex, OFLineItemIndex, ('deal_unit' + UnitIndex + '_kit' + OFKitHeaderIndex + '_of' + OFLineItemIndex), true, OFLI);
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    if(isBlankValue(OFLineItemJson.ItemDescription)) {
                		if(!isBlankValue($scope.M_CO.oldDescriptionValue)) {
                			OFLineItemJson.ItemDescription = $scope.M_CO.oldDescriptionValue;
                		} else {
                			return;
                		}
                	}
                    clicky = null;
                    if($scope.M_CO.isTabKeyPressed  && ("ontouchstart" in document.documentElement == false)) {
                      angular.element("#autocompleteDealUnit" + UnitIndex).focus();
                    }
                    /*if (!($scope.F_CO.isCommitAndInstallActionDone() || $scope.M_CO.hideCommitAndInstallBtn)) {
                        angular.element("#autocompleteDealoptionFee").focus();
                    } else if ($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length) {
                        angular.element("#autocompleteDealMerchSectionWrapperId").focus();
                    } else if ($scope.M_CO.SOHeaderList.length) {
                        angular.element("#autocompleteServiceJob0").focus();
                    }*/
                   updateOptionAndFeeLineItem(OFLineItemJson, 'saveOptionFeesLineItem', UnitIndex, kitHeaderJSON);
                }
            }
        }
        
        $scope.F_CO.updateOFKHItem = function(sectionName, UnitIndex, OFKitHeaderIndex, event) {
            if("ontouchstart" in document.documentElement && $scope.M_CO.isShowSaveBtnForIpad) {
                return;
            }
            if ($scope.M_CO.isLoading) {
                return;
            }
            var OFKHItemJson = $scope.M_CO.Deal.UnitList[UnitIndex].DealKitHeaderList[OFKitHeaderIndex];
            if (event) {
                if (clicky && (clicky.id === 'deal_unit' + UnitIndex + '_kit' + OFKitHeaderIndex || $(clicky).closest('tr#deal_unit' + UnitIndex + '_kit' + OFKitHeaderIndex).length || ($scope.M_CO.deletedItemGridName === 'deal' && $scope.M_CO.deletableOptionFee_KitId))) {
                    setFocusOnLIsFirstEditableField('OptionFee', UnitIndex, OFKitHeaderIndex, '', ('deal_unit' + UnitIndex + '_kit' + OFKitHeaderIndex), false, '', true);
                    clicky = null;
                    $scope.M_CO.isTabKeyPressed = false;
                    return;
                } else if (event.type == "blur" || "ontouchstart" in document.documentElement) {
                    clicky = null;
                    if($scope.M_CO.isTabKeyPressed && ("ontouchstart" in document.documentElement == false)) {
                      angular.element("#autocompleteDealUnit" + UnitIndex).focus();
                    }
                    /*if (!($scope.F_CO.isCommitAndInstallActionDone() || $scope.M_CO.hideCommitAndInstallBtn)) {
                        angular.element("#autocompleteDealoptionFee").focus();
                    } else if ($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length) {
                        angular.element("#autocompleteDealMerchSectionWrapperId").focus();
                    } else if ($scope.M_CO.SOHeaderList.length) {
                        angular.element("#autocompleteServiceJob0").focus();
                    }*/
                      updateOptionAndFeeKitHeaderItem(OFKHItemJson, 'saveOptionFeesLineItem', UnitIndex);
                }
            }
        }
 
        function setFocusOnLIsFirstEditableField(sectionName, sectionHeaderIndex, kitHeaderIndex, lineitemIndex, editLIId, isLI, LIJson, isKitHeader, KHItemJson) {
          if(isLI) {
            if(sectionName === 'OptionFee') {
              if((!$scope.F_CO.isCommitAndInstallActionDone() && (LIJson.FeeId || LIJson.LabourId || (LIJson.ProductId && LIJson.ProductType === 'Sublet'))) ||
                        ($scope.F_CO.isCommitAndInstallActionDone() && (LIJson.FeeId && !$scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].Id))) { // If Fee, sublet & Labour - then desc always editable for Kit & Non Kit LI(for labour and product with product type sublet; only before commit and install), but for Kit Li desc is non editable for after commit and install
                    angular.element('#' + editLIId + '_itemDesc').focus();
                    } else if (!$scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].Id && (!$scope.F_CO.isCommitAndInstallActionDone() || (!LIJson.PartId && !LIJson.LabourId && (!LIJson.ProductId || LIJson.ProductType !== 'Sublet')))) { // If Qty field is editable be then set focus on it(For Non KitLI it is always be editable (for part, labour and product with product type sublet; only before commit and install) since here return is not handled yet)
                        angular.element('#' + editLIId + '_Qty').focus();
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                        angular.element('#' + editLIId + '_Price').focus();
                    }
            }
          } else if(isKitHeader) {
            if(sectionName === 'OptionFee') {
              if ($rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price filed is editable then set focus on it
                        setFocus(editLIId + '_Price');
                    }
            }
          }
        }

        function updateOptionAndFeeLineItem(OFLineItemJson, functionType, UnitIndex, kitHeaderJSON) {
            $scope.M_CO.isLoading = true;
            var dealItemId = $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.Id;
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            if (kitHeaderJSON.Id) {
                var successJson = {
                    'type': functionType,
                    'UnitIndex': UnitIndex
                };
                DealService.recalculationOfDealKHLineItems(angular.toJson(kitHeaderJSON), angular.toJson(OFLineItemJson)).then(new success(successJson).handler, new error().handler);
            } else {
                var successJson = {
                    'type': functionType,
                    'UnitIndex': UnitIndex,
                    'callback': $scope.F_CO.updateDealSummaryTotals
                };
                DealService.saveOptionFeesLineItem(dealId, dealItemId, angular.toJson(OFLineItemJson)).then(new success(successJson).handler, new error().handler);
            }
        }

        function updateOptionAndFeeKitHeaderItem(OFKHItemJson, functionType, UnitIndex) {
            $scope.M_CO.isLoading = true;
            var optionFeeItemJSON = null;
            var dealItemId = $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.Id;
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            var successJson = {
                'type': functionType,
                'UnitIndex': UnitIndex,
                'callback': $scope.F_CO.updateDealSummaryTotals
            };
            DealService.recalculationOfDealKHLineItems(angular.toJson(OFKHItemJson), angular.toJson(optionFeeItemJSON)).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.getCOCheckoutLineItemList = function(CheckoutItemType, soHeaderId, checkoutIndex, itemId) {
            $scope.M_CO.checkOutLineItem = [];
            if (itemId == $scope.M_CO.prevOpenedInvItemId) {
                $scope.M_CO.prevOpenedInvItemId = null;
            } else {
                $scope.M_CO.prevOpenedInvItemId = itemId;
            }
            if (CheckoutItemType == 'Service Job') {
                $scope.M_CO.showCheckOutLineItem = checkoutIndex;
                for (var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                    if (soHeaderId == $scope.M_CO.SOHeaderList[i].SOInfo.Id) {
                        for (var j = 0; j < $scope.M_CO.SOHeaderList[i].SOGridItems.length; j++) {
                            $scope.M_CO.checkOutLineItem.push($scope.M_CO.SOHeaderList[i].SOGridItems[j]);
                        }
                        if ($scope.M_CO.SOHeaderList[i].SOInfo.TotalShopSupplies && $scope.M_CO.SOHeaderList[i].SOInfo.TotalShopSupplies != 0) {
                            var shopSuppliesTotalObject = {
                                'TotalShopSupplies': $scope.M_CO.SOHeaderList[i].SOInfo.TotalShopSupplies
                            };
                            $scope.M_CO.checkOutLineItem.push(shopSuppliesTotalObject);
                        }
                    }
                }
            } else if (CheckoutItemType == 'Deal') {
                var dealInvoiceList = {};
                dealInvoiceList.UnitList = [];
                dealInvoiceList.TradeInsList = [];
                dealInvoiceList.DealFinanceObj = {};
                $scope.M_CO.showCheckOutLineItem = checkoutIndex;
                for (var j = 0; j < $scope.M_CO.Deal.UnitList.length; j++) {
                    dealInvoiceList.UnitList.push($scope.M_CO.Deal.UnitList[j]);
                }
                for (var k = 0; k < $scope.M_CO.Deal.TradeInsList.length; k++) {
                    dealInvoiceList.TradeInsList.push($scope.M_CO.Deal.TradeInsList[k]);
                }
                dealInvoiceList.DealFinanceObj = ($scope.M_CO.Deal.DealFinanceObj.FIProductList);
                $scope.M_CO.checkOutLineItem.push(dealInvoiceList);
            }
        }

        function updateServiceOrderLineItem(SOLineItem, functionType, SOHeaderIndex) {
            $scope.M_CO.isLoading = true;
            var SOHeaderId = $scope.M_CO.SOHeaderList[SOHeaderIndex].SOInfo.Id;
            var successJson = {
                'type': functionType,
                'SOHeaderIndex': SOHeaderIndex
            };
            if (functionType == 'updateDealSOLineItem') {
                successJson = {
                    'type': functionType,
                    'SOHeaderIndex': SOHeaderIndex,
                    'callback': getUnitDealDetails,
                    'callbackParam': {
                        'gridName': 'dealUnresolvedFulfillmentSection'
                    }
                };
            }
            SOHeaderService.updateSOLineItem(angular.toJson(SOLineItem), SOHeaderId).then(new success(successJson).handler, function(errorMessage) {
            	if(errorMessage.toLowerCase().indexOf("haserror") === -1) {
            	    new error().handler(errorMessage);
            	} else {
            		var errorJson = JSON.parse(errorMessage); 
            		Notification.error(errorJson["ErrorMsg"]);
            		var successJson = {
                        'type': 'updateSOLineItem',
                        'SOHeaderIndex': SOHeaderIndex,
                    };

                    $scope.M_CO.editLineItemIndex = -1;
                    SOHeaderService.getSOHeaderDetails(SOHeaderId, null).then(new success(successJson).handler, new error().handler);
            	}
        	});
        }
        $scope.F_CO.openDeleteConfirmationPopupForOptionFeeLineItem = function(unitIndex, kitHeaderIndex, optionFeeIndex, dealItemId, kitHeaderId, optionFeeId, gridName, unitType) {
            $scope.M_CO.deletedItemName = 'this item';
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableOptionFee_KitId = kitHeaderId;
            $scope.M_CO.deletableOptionFee_Id = optionFeeId;
            $scope.M_CO.deletableOptionFee_DealItemIndex = unitIndex;
            $scope.M_CO.deletableOptionFee_DealItemId = dealItemId;
            $scope.M_CO.deletableElementId = 'deal_unit' + unitIndex + '_kit' + kitHeaderIndex;
            if (!$scope.M_CO.deletableOptionFee_KitId) {
                $scope.M_CO.deletableElementId += '_of' + optionFeeIndex;
            }
            openDeleteConfirmationModalWindow($scope.M_CO.deletableElementId);
        }
        $scope.F_CO.openDeleteConfirmationPopupForDFFandILineItem = function(lineItemIndex, dealItemId, fIProductId, gridName) {
            $scope.M_CO.deletedItemName = 'this item';
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableDFFI_Id = dealItemId;
            $scope.M_CO.deletableDFFI_FIProductId = fIProductId;
            $scope.M_CO.deletableDFFI_FIProductElementID = 'FandIRow_' + lineItemIndex;
            openDeleteConfirmationModalWindow($scope.M_CO.deletableDFFI_FIProductElementID);
        }
        $scope.F_CO.openDeleteConfirmationPopupForSOLineItem = function(SOHeaderIndex, SOHeaderId, SoKitHeaderIndex, SOkitHeaderId, SOLIIndex, SoliId, gridName, isOpenMoveLIModal,event) {
            event.stopPropagation();
            $scope.M_CO.deletedItemName = 'this item';
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableSOLI_SOHeader_Index = SOHeaderIndex;
            $scope.M_CO.deletableSOLI_SOHeader_Id = SOHeaderId;
            $scope.M_CO.deletableSOLI_SoKitHeader_Index = SoKitHeaderIndex;
            $scope.M_CO.deletableSOLI_SoKitHeader_Id = SOkitHeaderId;
            $scope.M_CO.deletableSOLI_Index = SOLIIndex;
            $scope.M_CO.deletableSOLI_Id = SoliId;
            var deletableElementId = 'SOHeader' + $scope.M_CO.deletableSOLI_SOHeader_Index + '_SOKitHeader' + $scope.M_CO.deletableSOLI_SoKitHeader_Index;
            if (!$scope.M_CO.deletableSOLI_SoKitHeader_Id) {
                deletableElementId += '_SOLI' + $scope.M_CO.deletableSOLI_Index;
            }
            $scope.F_CO.showDeleteIconOnLineItem();
            if (!isOpenMoveLIModal) {
                openDeleteConfirmationModalWindow(deletableElementId);
            } else {
                openMoveLineItemConfirmationModalWindow(deletableElementId);
            }
        }
        $scope.F_CO.openDeleteConfirmationPopupforCOLineItem = function(CoKitHeaderIndex, COKHitemId, CoLIIndex, COLIId, gridName, isOpenMoveLIModal) {
            $scope.M_CO.deletedItemName = 'this item'
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableCOLI_CoKitHeader_Index = CoKitHeaderIndex;
            $scope.M_CO.deletableCOLI_CoKitHeader_Id = COKHitemId;
            $scope.M_CO.deletableCOLI_Index = CoLIIndex;
            $scope.M_CO.deletableCOLI_Id = COLIId;
            var deletableElementId = 'Merchandise_Section_COKitHeader' + $scope.M_CO.deletableCOLI_CoKitHeader_Index + '_COLI' + $scope.M_CO.deletableCOLI_Index;
            if (!isOpenMoveLIModal) {
                openDeleteConfirmationModalWindow(deletableElementId);
            } else {
                openMoveLineItemConfirmationModalWindow(deletableElementId);
            }
        }
        $scope.F_CO.openDeleteConfirmationPopupforDealCOLI = function(CoKitHeaderIndex, COKHitemId, CoLIIndex, COLIId, gridName) {
            $scope.M_CO.deletedItemName = 'this item'
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableCOLI_CoKitHeader_Index = CoKitHeaderIndex;
            $scope.M_CO.deletableCOLI_CoKitHeader_Id = COKHitemId;
            $scope.M_CO.deletableCOLI_Index = CoLIIndex;
            $scope.M_CO.deletableCOLI_Id = COLIId;
            addDeletePopupBackdrop();
            var deletableElementId = 'DealMerch_Section_COKitHeader' + $scope.M_CO.deletableCOLI_CoKitHeader_Index + '_COLI' + $scope.M_CO.deletableCOLI_Index;
            var toppopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().top) + 20;
            var leftpopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().left) + 5;
            angular.element(".deleteConfiramtionPopup").css("left", leftpopupposition + 'px');
            angular.element(".deleteConfiramtionPopup").css("top", toppopupposition + 'px');
            setTimeout(function() {
                angular.element(".deleteConfiramtionPopup").css("visibility", 'visible');
                angular.element(".deleteConfiramtionPopup").css("opacity", 1);
            }, 100);
        }

        var isDealServiceKitExistsForRecalculation = false;
        $scope.F_CO.commitAndInstallDeal = function() {
            if ($scope.M_CO.Deal.DealInfo.DealStatus === 'In Progress' || $scope.M_CO.Deal.DealInfo.DealStatus === 'Approved') {
                if ($scope.F_CO.isTemporaryUnitExistInDeal()) {
                    Notification.error($translate.instant('CustomerOrder_Js_convert_Temporary_Unit_to_Stock'));
                    return;
                }

                for(var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                  for(var j = 0; j < $scope.M_CO.Deal.UnitList[i].DealKitHeaderList.length; j++) {
                    if($scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].Id && $scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].IsInstall) {
                      isDealServiceKitExistsForRecalculation = true;
                    }
                  }
                }

                $scope.M_CO.isLoading = true;
                
               createDealMerchSection().then(function() {
                  getSOHeaderDetails({'isDealCallback' : true});
                }, function(errorSearchResult) {
                    $scope.M_CO.isLoading = false;
                });
            }
            return;
        }
        
        var createDealMerchSection = function() {
          var defer = $q.defer();
          var successJson = {
                'type': 'commitAndInstallDeal'
            };
          DealService.createDealMerchSection($scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.Deal.DealInfo.CoHeaderId).then(function(successResult) {
        	  var result = successResult;
        	  DealService.createDealServiceSection($scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.Deal.DealInfo.CoHeaderId).then(function(successResult) {
                  DealService.setStatusForCommitAndInstallAction($scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.Deal.DealInfo.CoHeaderId).then(function(successResult) {
                	  new success(successJson).handler(result);
                	  defer.resolve();
                  }, function(errorSearchResult) {
                      defer.reject($translate.instant('GENERIC_ERROR'));
                  });
                }, function(errorSearchResult) {
                    defer.reject($translate.instant('GENERIC_ERROR'));
                });
            }, function(errorSearchResult) {
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
            return defer.promise;
        }

        var recalculateMerchKit = function(coKitId) {
          merchandiseService.recalculateMerchKit(coKitId, $scope.M_CO.COHeaderId).then(function(response) {
          }, function(error) {
            handleErrorAndExecption(error);
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
        }


        function recalculateKitForDealMerchSection() {
          var viewsPromises = [];
      for(var i = 0; i < $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList.length; i++) {
              if($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i].Id) {
              viewsPromises.push(recalculateMerchKit($scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[i].Id));
              }
            }

          return $q.all(viewsPromises).then(function(){
          getUnitDealDetails({'gridName': 'dealMerchandise'});
          });
        }

        var recalculateServiceKit = function(soKitId, soHeaderId) {
          SOHeaderService.recalculateServiceKit($scope.M_CO.coHeaderRec.CustomerId, $scope.M_CO.COHeaderId, soKitId, soHeaderId).then(function(response) {
          }, function(error) {
            handleErrorAndExecption(error);
                defer.reject($translate.instant('GENERIC_ERROR'));
            });
        }

        function recalculateKitForDealServiceSection(serviceOrderHeaderList) {
          var viewsPromises = [];
      for(var i = 0; i < serviceOrderHeaderList.length; i++) {
              if(serviceOrderHeaderList[i].SOInfo.DealId) {
                for(var j = 0; j < serviceOrderHeaderList[i].SOGridItems.length; j++) {
                  if(serviceOrderHeaderList[i].SOGridItems[j].Id) {
                    viewsPromises.push(recalculateServiceKit(serviceOrderHeaderList[i].SOGridItems[j].Id, serviceOrderHeaderList[i].SOInfo.Id));
                  }
                }
              }
            }
          if(viewsPromises.length > 0) {
            $q.all(viewsPromises).then(function() {
              getSOHeaderDetails(false);
              });
          }
        }

        $scope.F_CO.isCommitUnitDisable = function() {
            if ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) {
                if ($scope.M_CO.Deal.UnitList.length === 1) {
                    if (!$scope.M_CO.Deal.UnitList[0].DealItemObj.UnitId) {
                        return true;
                    }
                } else {
                    var isStockUnitExist = false;
                    var isTempUnitExist = false;
                    for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                        if ($scope.M_CO.Deal.UnitList[i].DealItemObj.UnitId) {
                            isStockUnitExist = true;
                        } else if ($scope.M_CO.Deal.UnitList[i].DealItemObj.Make) {
                            isTempUnitExist = true;
                        }
                    }
                    if (isTempUnitExist || !isStockUnitExist) {
                        return true;
                    }
                }
                return false;
            }
            return true;
        }

        $scope.F_CO.isTemporaryUnitExistInDeal = function() {
            if ($scope.M_CO.Deal.UnitList) {
                for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                    if (!$scope.M_CO.Deal.UnitList[i].DealItemObj.UnitId) {
                        return true;
                    }
                }
            }
            return false;
        }

        $scope.F_CO.isOrderedUnitExistsInDeal = function() {
            if ($scope.M_CO.Deal.UnitList) {
                for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                    if ($scope.M_CO.Deal.UnitList[i].DealItemObj.Status === 'On Order') {
                        return true;
                    }
                }
            }
            return false;
        }

        $scope.F_CO.updateDealStatus = function() {
            $scope.M_CO.StatusConfig.showDialog = false;
            if($scope.M_CO.StatusConfig.newWorkStatus != $scope.M_CO.Deal.DealInfo.DealStatus) {
            $scope.M_CO.isLoading = true;
            
                        if($scope.M_CO.StatusConfig.newWorkStatus === 'Approved') {
            	DealService.getDealItemInternalServiceStatus($scope.M_CO.Deal.DealInfo.Id).then(function(result) {
            		if(result.length > 0) {
            			$scope.M_CO.coHeaderSuccessResult = result;
            			$scope.F_CO.openConfirmationDialog('DealItemInternalServiceStatusDialog', true);
            			$scope.M_CO.isLoading = false;
            		} else {
            			updateDealStatus();
            		}
            	});
            } else {
            	updateDealStatus();
            }
                if ($scope.M_CO.coHeaderRec.OrderStatus === 'Quote' && $scope.M_CO.showQuote) {
                    changePayingIndex = null;
                    changePayingSoHeaderIndex = null;
                    $scope.F_CO.activateQuoteCO();
                }
          }
        }
        $scope.F_CO.deleteItem = function(isDeleteFromMoveLIModal) {
            $scope.M_CO.isDeleteDisabled = true;
            if ($scope.M_CO.deletedItemGridName === 'Merchandise') {
                deleteCoLineItem(isDeleteFromMoveLIModal);
            } else if ($scope.M_CO.deletedItemGridName === 'LogTechnicianTimeGrid') {
                removeHoursLoggedItem();
            } else if ($scope.M_CO.deletedItemGridName === 'ChekoutReversePaymentGrid') {
                $scope.F_CO.paymentGoAction($scope.M_CO.deletableInvPaymentRec);
                $scope.F_CO.addPayment();
            } else if ($scope.M_CO.deletedItemGridName === 'Service Job') {
                removeServiceOrderItem(isDeleteFromMoveLIModal);
            } else if ($scope.M_CO.deletedItemGridName === 'deal') {
                removeOptionFeeItem();
            } else if ($scope.M_CO.deletedItemGridName === 'DealMerch') {
                deleteDealCOLI();
            } else if ($scope.M_CO.deletedItemGridName === 'DFFandIProduct') {
                removeFIProductLineItem($scope.M_CO.deletableDFFI_Id, $scope.M_CO.deletableDFFI_FIProductId);
            }
        }

        function deleteCoLineItem(isDeleteFromMoveLIModal) {
          var elementId = 'Merchandise_Section_COKitHeader' + $scope.M_CO.deletableLI_KitHeader_Index;
          var id;
            if ($scope.M_CO.deletableLI_KitHeader_Id) {
              id = $scope.M_CO.deletableLI_KitHeader_Id;
            } else {
              elementId += '_COLI' + $scope.M_CO.deletableLI_Index;
              id = $scope.M_CO.deletableLI_Id;
            }
            var successJson = {
                'type': 'deleteCOLineItem',
                'elementId': elementId,
                'isDeleteFromMoveLIModal': isDeleteFromMoveLIModal
            };
            merchandiseService.deleteCOLineItem(id, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function deleteDealCOLI() {
          var elementId = 'DealMerch_Section_COKitHeader' + $scope.M_CO.deletableLI_KitHeader_Index;
          var id;
            if ($scope.M_CO.deletableLI_KitHeader_Id) {
              id = $scope.M_CO.deletableLI_KitHeader_Id;
            } else {
              elementId += '_COLI' + $scope.M_CO.deletableLI_Index;
              id = $scope.M_CO.deletableLI_Id;
            }
            var successJson = {
                'type': 'deleteDealCOLineItem',
                'elementId': elementId,
            };
            merchandiseService.deleteCOLineItem(id, $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }

        function addDeletePopupBackdrop() {
           //$scope.M_CO.isDeleteDisabled = false;
            // $scope.F_CO.showDeleteIconOnLineItem();

             if($scope.M_CO.deletedItemGridName === 'Service Job') {
                 $scope.F_CO.showDeleteIconOnLineItem();
             } else {
                $scope.M_CO.isDeleteDisabled = false;
             }
            setTimeout(function() {
                var template = '<div class = "bp-modal-backdrop" ng-click = "F_CO.hideDeleteConfirmationPopup()"></div>';
                template = $compile(angular.element(template))($scope);
                if ($scope.M_CO.deletedItemGridName === 'ChekoutReversePaymentGrid') {
                    angular.element("#checkout-modal").prepend(template);
                } else {
                    angular.element("#customerorder_V2").prepend(template);
                }
            }, 500);
        }

       $scope.F_CO.hidereverseCancelModalWindow = function() {
          $scope.M_CO.showReverseChangeModalWindow = false;
          angular.element(".delete-confirm-container").removeClass("reverse-animation");
       }
       
        $scope.F_CO.hideDeleteConfirmationPopup = function() {
      //$scope.M_CO.isDeleteDisabled = false;
      //$scope.F_CO.showDeleteIconOnLineItem();
          if($scope.M_CO.deletedItemGridName === 'Service Job') {
                 $scope.F_CO.showDeleteIconOnLineItem();
             } else {
                $scope.M_CO.isDeleteDisabled = false;
             }

             angular.element(".delete-confirm-container").removeClass("reverse-animation");
            angular.element(".deleteConfiramtionPopup").css("visibility", 'hidden');
            angular.element(".deleteConfiramtionPopup").css("opacity", 0);
            angular.element("#customerorder_V2").find('.bp-modal-backdrop').remove();
            if ($scope.M_CO.deletedItemGridName === 'ChekoutReversePaymentGrid') {
                angular.element(".bp-popup-delete-backdrop-hide").css("display", 'none');
                angular.element(".deleteConfiramtionPopupforCheckOut").css("visibility", 'hidden');
                angular.element(".deleteConfiramtionPopupforCheckOut").css("opacity", 0);
        $scope.F_CO.hidereverseCancelModalWindow();
            }
            setTimeout(function(){
               $scope.M_CO.deletedItemGridName = '';
            },100);
        }

        function removeServiceOrderItem(isDeleteFromMoveLIModal) {
            if ($scope.M_CO.deletableSOLI_SoKitHeader_Id) {
                var elementId = 'SOHeader' + $scope.M_CO.deletableSOLI_SOHeader_Index + '_SOKitHeader' + $scope.M_CO.deletableSOLI_SoKitHeader_Index;
                var successJson = {
                    'type': 'removeServiceOrderItem',
                    'SOHeaderIndex': $scope.M_CO.deletableSOLI_SOHeader_Index,
                    'elementId': elementId,
                    'isDeleteFromMoveLIModal': isDeleteFromMoveLIModal
                };
                if (!isBlankValue($scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOInfo.DealItemId) || !isBlankValue($scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOInfo.DealId)) {
                    var successJson = {
                        'type': 'removeDealSOItem',
                        'SOHeaderIndex': $scope.M_CO.deletableSOLI_SOHeader_Index,
                        'elementId': elementId,
                        'callback': getUnitDealDetails,
                        'callbackParam': {
                            'gridName': 'dealUnresolvedFulfillmentSection'
                        }
                    };
                }
                SOHeaderService.removeServiceOrderItem($scope.M_CO.deletableSOLI_SOHeader_Id, $scope.M_CO.deletableSOLI_SoKitHeader_Id).then(new success(successJson).handler, new error().handler);
            } else {
                var elementId = 'SOHeader' + $scope.M_CO.deletableSOLI_SOHeader_Index + '_SOKitHeader' + $scope.M_CO.deletableSOLI_SoKitHeader_Index + '_SOLI' + $scope.M_CO.deletableSOLI_Index;
                var successJson = {
                    'type': 'removeServiceOrderItem',
                    'SOHeaderIndex': $scope.M_CO.deletableSOLI_SOHeader_Index,
                    'elementId': elementId,
                    'isDeleteFromMoveLIModal': isDeleteFromMoveLIModal
                };
                if (!isBlankValue($scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOInfo.DealItemId) || !isBlankValue($scope.M_CO.SOHeaderList[$scope.M_CO.deletableSOLI_SOHeader_Index].SOInfo.DealId)) {
                    var successJson = {
                        'type': 'removeDealSOItem',
                        'SOHeaderIndex': $scope.M_CO.deletableSOLI_SOHeader_Index,
                        'elementId': elementId,
                        'callback': getUnitDealDetails,
                        'callbackParam': {
                            'gridName': 'dealUnresolvedFulfillmentSection'
                        }
                    };
                }
                SOHeaderService.removeServiceOrderItem($scope.M_CO.deletableSOLI_SOHeader_Id, $scope.M_CO.deletableSOLI_Id).then(new success(successJson).handler, function(errorMessage) {
                	if(errorMessage.toLowerCase().indexOf("haserror") === -1) {
                	    new error().handler(errorMessage);
                	} else {
                		var errorJson = JSON.parse(errorMessage);
                		Notification.error(errorJson["ErrorMsg"]);
                		var successJson = {
                            'type': 'updateSOLineItem',
                            'SOHeaderIndex': $scope.M_CO.deletableSOLI_SOHeader_Index,
                            'isDeleteFromMoveLIModal': isDeleteFromMoveLIModal
                        };

                        $scope.M_CO.editLineItemIndex = -1;
                        SOHeaderService.getSOHeaderDetails($scope.M_CO.deletableSOLI_SOHeader_Id, null).then(new success(successJson).handler, new error().handler);
                	}
            	});
            }
        }

        function removeOptionFeeItem() {
            var successJson = {
                'type': 'removeOptionFee',
                'dealItemIndex': $scope.M_CO.deletableOptionFee_DealItemIndex,
                'elementId': $scope.M_CO.deletableElementId,
                'callback': $scope.F_CO.updateDealSummaryTotals
            };
            if ($scope.M_CO.deletableOptionFee_KitId) {
                DealService.removeOptionFeesLineItem($scope.M_CO.deletableOptionFee_DealItemId, $scope.M_CO.deletableOptionFee_KitId).then(new success(successJson).handler, new error().handler);
            } else {
                DealService.removeOptionFeesLineItem($scope.M_CO.deletableOptionFee_DealItemId, $scope.M_CO.deletableOptionFee_Id).then(new success(successJson).handler, new error().handler);
            }
        }
        $scope.F_CO.updateDealSummaryTotals = function() {
            if ($scope.M_CO.Deal.DealInfo) {
                var successJson = {
                    'type': 'getDealTotalInfo'
                }
                DealService.getDealDetails($scope.M_CO.Deal.DealInfo.Id, 'dealInfo').then(new success(successJson).handler, new error().handler);
            }
        }
        $scope.F_CO.validateOptionFee = function(unitIndex, kitHeaderIndex, optionFeeIndex) {
            if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                return false;
            }
            if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id == null && $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList != undefined) {
                var optionFee = $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[optionFeeIndex];
                if ((optionFee.LabourId != null && optionFee.LabourId != '') || optionFee.Status == 'Invoiced' || optionFee.Status == 'Fulfilled' || (optionFee.ProductId != null && optionFee.ProductId != '' && optionFee.ProductType == 'Sublet')) {
                    return false;
                }
            } else if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id != null) {
                if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].IsServiceKit) {
                    return false;
                }
            }
            return true;
        }
        $scope.$on('createCustomerAutoCompleteCallback', function(event, args) {
          var AddEditCustomerParams = {
                addCustomerCoBuyer: true
            };
          loadState($state, 'CustomerOrder_V2.AddEditCustomerV2', {
                AddEditCustomerParams: AddEditCustomerParams
            });

           //loadState($state, 'CustomerOrder_V2.AddEditCustomerV2');
        });
        $scope.F_CO.installOptionFeeAction = function(unitIndex, kitHeaderIndex, optionFeeIndex) {
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            var dealItemId = $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.Id;
            var optionFeeJSON = null;
            if (!$scope.F_CO.validateOptionFee(unitIndex, kitHeaderIndex, optionFeeIndex)) {
                return;
            }
            if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id == null && $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList != undefined) {
                optionFeeJSON = $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[optionFeeIndex];
                $scope.M_CO.isLoading = true;
                var successJson = {
                    'type': 'saveOptionFeesLineItem',
                    'UnitIndex': unitIndex,
                    'callback': $scope.F_CO.updateDealSummaryTotals
                };
                if (($scope.M_CO.Deal.DealInfo.DealStatus == 'In Progress' || $scope.M_CO.Deal.DealInfo.DealStatus == 'Approved') && $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.OptionAndFeeStatus == 'Committed') {
                    successJson = {
                        'type': 'saveOptionFeesLineItem',
                        'UnitIndex': unitIndex,
                        'callback': getSOHeaderDetails,
                        'callbackParam': {
                            'isDealCallback': false
                        }
                    };
                }
                DealService.saveOptionFeesLineItem(dealId, dealItemId, angular.toJson(optionFeeJSON)).then(new success(successJson).handler, new error().handler);
            } else if ($scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex].Id != null) {
                $scope.M_CO.isLoading = true;
                var optionFeeKitHeaderJSON = $scope.M_CO.Deal.UnitList[unitIndex].DealKitHeaderList[kitHeaderIndex];
                var successJson = {
                    'type': 'recalculationOfDealKHLineItems',
                    'UnitIndex': unitIndex
                };
                DealService.recalculationOfDealKHLineItems(angular.toJson(optionFeeKitHeaderJSON), angular.toJson(optionFeeJSON)).then(new success(successJson).handler, new error().handler);
            }
        }
        $scope.M_CO.reOpenStatus = {};
        $scope.M_CO.reOpenStatus.btnLabel = "Save";
        $scope.F_CO.updateSOHeader = function(index) {

            if (!$scope.M_CO.SOHeaderList[index].SOInfo.Name || $scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus == 'Invoiced' ) {
                return;
            }
            if ($scope.M_CO.SOHeaderList[index].SOInfo.newWorkStatus === 'Re-open for work') {
                $scope.M_CO.SOHeaderList[index].SOInfo.newWorkStatus = "In Progress";
                $scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus = "In Progress";
            }
            if ($scope.M_CO.COHeaderId != null && $scope.M_CO.COHeaderId != undefined && $scope.M_CO.COHeaderId != '') {
                var isUpdateRelatedAppointmentRec = false;
                if(($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[index].SOInfo.Id)) {
                  isUpdateRelatedAppointmentRec = true;
                }
                var successJson = {
                    'type': 'refreshSOHeaderInfo',
                    'SOHeaderIndex': index,
                    'isUpdateRelatedAppointmentRec': isUpdateRelatedAppointmentRec
                };
                SOHeaderService.updateSOHeader($scope.M_CO.COHeaderId, JSON.stringify($scope.M_CO.SOHeaderList[index].SOInfo)).then(new success(successJson).handler, new error().handler);
            } else {
                Notification.error($translate.instant('Please_add_customer_first'));
            }
        }
        $scope.M_CO.checkoutPaymentByEnter = function(event, type) {
            //Will not work for refund as input is in disabled mode so no key will work
            if (event.keyCode == 13) {
                if (type === 'Checkout' && $scope.CheckoutInfoModel.amountPaying && $scope.CheckoutInfoModel.paymentMethod) {
                    $scope.F_CO.addPayment();
                } else if (type === 'Deposit' && $scope.M_CO.Deposit.deposit_Amount && $scope.M_CO.Deposit.paymentMethod) {
                    $scope.F_CO.Deposit.addDeposit();
                }
            }
        }
        $scope.M_CO.printDocumentTypeList = [{
            Name: 'Merchandise',
            IsActive: false,
            PrintItems: [{
                Label: 'Packing Slip',
                IsSelected: true
            }]
        }, {
            Name: 'Service',
            IsActive: false,
            UnitName: '',
            PrintItems: []
        }, {
            Name: 'Deal',
            IsActive: false,
            PrintItems: [{
                Label: 'Offer to purchase',
                IsSelected: false
            }, {
                Label: 'Bill of sale',
                IsSelected: false
            }, {
                Label: 'Print deposit receipt',
                IsSelected: false
            }]
        }, {
            Name: 'Documents',
            IsActive: false,
            PrintItems: []
        },{
            Name: 'Receipts',
            IsActive: true,
            PrintItems: [{
                Label: 'Deposit receipt',
                IsSelected: false,
                IsVisible: true
            }, {
                Label: 'Invoice preview',
                IsSelected: false,
                IsVisible: true
            }]
        }];
        $scope.M_CO.CurrentActiveTabIndex = 0;
        $scope.F_CO.setCurrentActiveTab = function(filterName) {
            if ($scope.F_CO.isTabVisible(filterName)) {
                for (var i = 0; i < $scope.M_CO.printDocumentTypeList.length; i++) {
                    $scope.M_CO.printDocumentTypeList[i].IsActive = (filterName == $scope.M_CO.printDocumentTypeList[i].Name);
                    $scope.M_CO.CurrentActiveTabIndex = (filterName == $scope.M_CO.printDocumentTypeList[i].Name) ? i : $scope.M_CO.CurrentActiveTabIndex;
                }
            }
            if (filterName == 'Service' && $scope.M_CO.ServiceWorksheetPrintDetail && $scope.M_CO.ServiceWorksheetPrintDetail.length > 0) {
                $scope.F_CO.selectAllServiceType('Worksheet');
                setTimeout(function() {
                    angular.element("#service-print")[0].scrollTop = 0;
                }, 500);
            }
        }
        $scope.F_CO.isPrintActionAvailable = function() {
           if ($scope.F_CO.isTabVisible('Merchandise') || $scope.F_CO.isTabVisible('Service')
                || $scope.F_CO.isTabVisible('Deal') || $scope.F_CO.isTabVisible('Receipts')
                || $scope.F_CO.isTabVisible('Documents') ) {
                return true;
            }
            return false;
        }
        function isActiveInvoiceHeaderIdExists() {
          if($scope.M_CO.COHeaderId && ($scope.CheckoutInfoModel.activeInvHeaderId || $scope.M_CO.coHeaderRec.ActiveInvoiceId )) {
            return true;
          }
          return false;
        }

        $scope.F_CO.isTabVisible = function(tabName) {
            if (($rootScope.GroupOnlyPermissions['Merchandise']['view'] && tabName == 'Merchandise' && ($scope.M_CO.IsShowMerchandiseSection || $scope.M_CO.COKHList.length > 0))
                || ($rootScope.GroupOnlyPermissions['Service job']['view'] && tabName == 'Service' && $scope.M_CO.SOHeaderList.length > 0 && $scope.F_CO.SOHeaderListContainsUnit())
                || ($rootScope.GroupOnlyPermissions['Customer invoicing']['view'] && tabName == 'Receipts' && isActiveInvoiceHeaderIdExists() && $scope.M_CO.coHeaderRec.OrderStatus != 'Closed')
                || ($rootScope.GroupOnlyPermissions['Deal']['view'] && tabName == 'Deal' && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id)
                ||  tabName === 'Documents' && isTabHavePrintitems('Documents')) {
                return true;
            } else {
                return false;
            }
        }

        function isTabHavePrintitems(tabName) {
          var index = _.findIndex($scope.M_CO.printDocumentTypeList, {
                'Name': tabName
            });
            if (index > -1 && $scope.M_CO.printDocumentTypeList[index].PrintItems.length) {
                return true;
            }
            return false;
        }

        $scope.F_CO.isDisabledCheckoutBtn = function() {
            if ($scope.CheckoutInfoModel.InvoiceItemList != undefined && $scope.CheckoutInfoModel.InvoiceItemList != null) {
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsActive && $scope.CheckoutInfoModel.InvoiceItemList[i].IsInvoiceable) {
                        if ($scope.CheckoutInfoModel.BalanceDue == 0) {
                            return false;
                        }
                        return true;
                    }
                }
            }
            return true;
        }
        $scope.F_CO.SOHeaderListContainsUnit = function() {
            for (var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                if ($scope.M_CO.SOHeaderList[i].SOInfo) {
                    if ($scope.M_CO.SOHeaderList[i].SOInfo.UnitId) {
                        return true;
                    }
                }
            }
            return false;
        }
        $scope.F_CO.isCurrentTabActive = function(tabName) {
            if ($scope.F_CO.isTabVisible(tabName)) {
                var index = _.findIndex($scope.M_CO.printDocumentTypeList, {
                    'Name': tabName
                });
                if (index > -1) {
                    if ($scope.M_CO.printDocumentTypeList[index].Name && $scope.M_CO.printDocumentTypeList[index].IsActive) {
                        return $scope.M_CO.printDocumentTypeList[index].IsActive;
                    }
                }
            }
            return false;
        }
        $scope.F_CO.togglePrintItemCheckbox = function(index) {
            $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[index].IsSelected = !($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[index].IsSelected);
        }
        function getActiveInvHeaderId() {
          CheckoutServices.getActiveInvHeaderId($scope.M_CO.COHeaderId).then(function(result) {
            $scope.M_CO.coHeaderRec.ActiveInvoiceId = result;
            return result;
            }, function(errorSearchResult) {
        handleErrorAndExecption(error);
      });
        }

        $scope.M_CO.printPageNameToPageURLMap = {
            'Packing Slip': '/apex/PrintMerchandise?id=',
            'Service Worksheet': '/apex/ServiceWorkSheet?id=',
            'Offer to purchase': '/apex/PrintMerchandise?id=',
            'Bill of sale': '/apex/PrintMerchandise?id=',
            'Deposit receipt': '/apex/PrintCODeposits?id=',
            'Invoice preview': '/apex/PrintCustomerOrderInvoice?id=',
            'Offer to purchase': '/apex/DealDocumentPrint?id=',
            'Bill of sale': '/apex/DealDocumentPrint?id=',
            'Print deposit receipt': '/apex/PrintCODeposits?id=',
            'Attachment Object Url': '/servlet/servlet.FileDownload?file='
        };
        $scope.F_CO.getSelectedDocument = function() {
            if(!$scope.M_CO.showInvoicePreviewPopup) {
              for (var k = 0; k < $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems.length; k++) {
                  if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].IsSelected) {
                      if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name == 'Service') {
                          if ($scope.M_CO.isWorksheetSelected) {
                              $scope.F_CO.printServiceWorksheet($scope.M_CO.COHeaderId, false, true);
                          } else if ($scope.M_CO.isJobReviewSelected) {
                              $scope.F_CO.printServiceWorksheet($scope.M_CO.COHeaderId, true, true);
                          }
                          break;
                      } else if($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name == 'Documents') {
                        var pageName = $scope.M_CO.printPageNameToPageURLMap['Attachment Object Url'];
                        window.open(pageName + $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].AttachmentId, '_blank');
                      } else {
                          var pageName = $scope.M_CO.printPageNameToPageURLMap[$scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label];
                          if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label == 'Invoice preview') {
                              var activeInvId;
                              if ($scope.CheckoutInfoModel.activeInvHeaderId) {
                                  activeInvId = $scope.CheckoutInfoModel.activeInvHeaderId;
                              } else {
                                  activeInvId = $scope.M_CO.coHeaderRec.ActiveInvoiceId;
                              }
                              window.open(pageName + activeInvId + '&isFinalized=false', '_blank');
                          } else if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label == 'Bill of sale' || $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label == 'Offer to purchase') {
                              window.open(pageName + $scope.M_CO.Deal.DealInfo.Id+'&documentType='+$scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label, '_blank');
                          } else {
                              window.open(pageName + $scope.M_CO.COHeaderId, '_blank');
                          }
                      }
                  }
              }
        } else {
            for(var i=0;i<$scope.M_CO.printReceiptInvoiceList.length;i++){
              if($scope.M_CO.printReceiptInvoiceList[i].isSelected && $scope.M_CO.printReceiptInvoiceList[i].Name == 'Invoice'){
                $scope.F_CO.invoicePrintPreview($scope.M_CO.PrintCOInvoiceHeaderId)
              }
              if($scope.M_CO.printReceiptInvoiceList[i].isSelected && $scope.M_CO.printReceiptInvoiceList[i].Name == 'Print receipt') {
                var myWindow = window.open(url + "COSalesReceipt?id=" + $scope.M_CO.PrintCOInvoiceHeaderId, "", "width=1200, height=600");
              }
            }
          }
        }
        $scope.F_CO.isAnyCheckBoxSelected = function() {
            if (!$scope.M_CO.showInvoicePreviewPopup && $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex] != undefined) {
                for (var i = 0; i < $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems.length; i++) {
                    if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[i].IsSelected) {
                        return true;
                    }
                }
            }else if($scope.M_CO.showInvoicePreviewPopup) {
              for(var i=0; i< $scope.M_CO.printReceiptInvoiceList.length; i++) {
                if($scope.M_CO.printReceiptInvoiceList[i].isSelected){
                  return true;
                }
              }
            }
            return false;
        }
        $scope.F_CO.printServiceWorksheet = function(COHeaderId, isPrintPreview, isFromPrint) {
            var isUnitSelected;
            for (var i = 0; i < $scope.M_CO.ServiceWorksheetPrintDetail.length; i++) {
                isUnitSelected = false;
                $scope.M_CO.ServiceWorksheetPrintDetail[i].IsPrintPreview = isPrintPreview;
                for (var k = 0; k < $scope.M_CO.ServiceWorksheetPrintDetail[i].SOInfoWrapperList.length; k++) {
                    if ($scope.M_CO.isWorksheetSelected) {
                        $scope.M_CO.ServiceWorksheetPrintDetail[i].SOInfoWrapperList[k].IsSOHeaderSelected = $scope.M_CO.ServiceTypeWorksheet[i].SOInfoWrapperList[k].IsSOHeaderSelected;
                    } else if ($scope.M_CO.isJobReviewSelected) {
                        $scope.M_CO.ServiceWorksheetPrintDetail[i].SOInfoWrapperList[k].IsSOHeaderSelected = $scope.M_CO.ServiceTypeJobReview[i].SOInfoWrapperList[k].IsSOHeaderSelected;
                    }
                    if ($scope.M_CO.ServiceWorksheetPrintDetail[i].SOInfoWrapperList[k].IsSOHeaderSelected) {
                        isUnitSelected = true;
                    }
                }
                $scope.M_CO.ServiceWorksheetPrintDetail[i].IsUnitSelected = isUnitSelected;
            }
            var saveWorkseetSelectionJson = JSON.stringify($scope.M_CO.ServiceWorksheetPrintDetail);
            SOHeaderService.saveWorkseetSelectionJson($scope.M_CO.COHeaderId, saveWorkseetSelectionJson).then(function(result) {
                if (isFromPrint) {
                    var pageName = $scope.M_CO.printPageNameToPageURLMap['Service Worksheet'];
                    window.open(pageName + $scope.M_CO.COHeaderId, '_blank');
                }
            }, function(errorSearchResult) {});
        }
        $scope.F_CO.emailServiceWorksheet = function() {
            if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name == 'Service') {
                if ($scope.M_CO.isWorksheetSelected) {
                    $scope.F_CO.printServiceWorksheet($scope.M_CO.COHeaderId, false, false);
                } else if ($scope.M_CO.isJobReviewSelected) {
                    $scope.F_CO.printServiceWorksheet($scope.M_CO.COHeaderId, true, false);
                }
            }
        }
        $scope.F_CO.setFocusOnCustomerUnit = function(perfix, index) {
            $scope.M_CO.DropDownFocusId = perfix + '' + index;
        }
        $scope.F_CO.setBlurOnCustomerUnit = function(index) {
            $scope.M_CO.DropDownFocusId = '';
        }
        $scope.F_CO.selectCustomerUnit = function(index, soHeaderIndex) {
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.UnitName = $scope.M_CO.COUList[index].FormattedName;
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.UnitId = $scope.M_CO.COUList[index].Id;

            var isUpdateRelatedAppointmentRec = false;
            if(($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.Id)) {
              isUpdateRelatedAppointmentRec = true;
            }
            $scope.F_CO.saveServiceJobInfo(soHeaderIndex, false, false, isUpdateRelatedAppointmentRec);
        }
        var changePayingIndex;
        var changePayingSoHeaderIndex;
        $scope.F_CO.selectPayingType = function(index, SoHeaderIndex) {
            if ($scope.M_CO.coHeaderRec.OrderStatus === 'Quote') {
                if ($scope.M_CO.TTOptionsListWithQuote[index].Type != 'Quote') {
                    changePayingIndex = index;
                    changePayingSoHeaderIndex = SoHeaderIndex;
                    $scope.F_CO.openConfirmationDialog('QuoteConfirmationDialog', false);
                }
            } else if ($scope.M_CO.TTOptionsListWithQuote[index].Type === 'Quote') {
                $scope.F_CO.setCOStatusAsQuote();
            } else {
                $scope.F_CO.selectJobType(index, SoHeaderIndex, 'TTOptionsListWithQuote');
            }
        }
        $scope.F_CO.selectJobType = function(index, soHeaderIndex, listName) {
            if (listName === 'TTOptionsList') {
                var TTList = angular.copy($scope.M_CO.TTOptionsList);
            } else if (listName === 'TTOptionListWithDeal') {
                var TTList = angular.copy($scope.M_CO.TTOptionListWithDeal);
            } else if (listName === 'TTOptionsListWithQuote') {
                var TTList = angular.copy($scope.M_CO.TTOptionsListWithQuote);
            }
            if($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionTypeLabel !== TTList[index].CodeLabel){
               $scope.M_CO.SOHeaderList[soHeaderIndex].DeductibleItem = {'DeductibleAmount' : 0};
            }
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionTypeLabel = TTList[index].CodeLabel;
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionTypeId = TTList[index].Id;

            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType = TTList[index].Type;
            if ($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType === 'Third-Party') {
                $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ClaimStatus = 'Unsubmitted';
              $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ProviderName = TTList[index].ProviderName;
                $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ProviderId = TTList[index].ProviderId;
            } else {
                $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ClaimStatus = null;
            }

            if ($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType === 'Internal'
              || $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType === 'Stock Unit') {
              $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryId = TTList[index].InternalCategoryId;
              $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryName = TTList[index].InternalCategoryName;
            }

            // Select default Internal Expense category type
            if (($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType === 'Internal'
                || $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType === 'Stock Unit')
              && !$scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryId) {
              var defaultCategory = $scope.M_CO.CategoryList.filter(function isDefault(category) {
                    return (category.IsDefault);
                });
              if(defaultCategory && defaultCategory.length) {
                $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryId = defaultCategory[0].Id;
                  $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryName = defaultCategory[0].Name;
              }
            }

            var isUpdateRelatedAppointmentRec = false;
            if(($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.Id)) {
              isUpdateRelatedAppointmentRec = true;
            }
            $scope.F_CO.saveServiceJobInfo(soHeaderIndex, false, false, isUpdateRelatedAppointmentRec,true);
        }
        $scope.F_CO.selectProvider = function(index, soHeaderIndex) {
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ProviderName = $scope.M_CO.ProviderList[index].Name;
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ProviderId = $scope.M_CO.ProviderList[index].Id;
            $scope.F_CO.saveServiceJobInfo(soHeaderIndex, true, false,false, true);
        }

        $scope.F_CO.selectCategory = function(index, soHeaderIndex) {
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryName = $scope.M_CO.CategoryList[index].Name;
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.CategoryId = $scope.M_CO.CategoryList[index].Id;
            $scope.F_CO.saveServiceJobInfo(soHeaderIndex, true);
        }

        $scope.F_CO.addAndRemoveFromMultiSelect = function(event, index, modelName, modelKey, fieldLabel) {
            var isUpdateRelatedAppointmentRec = false;
          var isAlreadyExist = false;
            var fieldValue = $scope.M_CO.SOHeaderList[index].SOInfo[modelName];
            if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur') && fieldValue != '' && fieldValue != undefined) {
                for (var i = 0; i < $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].length; i++) {
                    if ($scope.M_CO.SOHeaderList[index].SOInfo[modelKey][i].toLowerCase() === $scope.M_CO.SOHeaderList[index].SOInfo[modelName].toLowerCase()) {
                        isAlreadyExist = true;
                        //Notification.error('Same ' + fieldLabel.toLowerCase() + ' already exist');
                        Notification.error($translate.instant('Same_fieldLabel_already_exist', {fieldLabel: fieldLabel.toLowerCase() }));
                        focusElement(fieldLabel + index);
                    }
                }
                if (!isAlreadyExist) {
                    $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].push($scope.M_CO.SOHeaderList[index].SOInfo[modelName]);
                    if(modelKey === 'ManualConcern' && (($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[index].SOInfo.Id))) {
                      isUpdateRelatedAppointmentRec = true;
                    }
                    $scope.F_CO.saveServiceJobInfo(index, true, false, isUpdateRelatedAppointmentRec);
                    $scope.M_CO.toDisplayInput[index] = '';
                }
                if(event.keyCode == 13 ) {
                    $scope.F_CO.displayInput(event, index, modelName, modelKey, fieldLabel);
                }
                $scope.M_CO.SOHeaderList[index].SOInfo[modelName] = '';
            } else if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur') && (fieldValue == '' || fieldValue == undefined)) {
                $scope.M_CO.toDisplayInput[index] = '';
            }
            /*remove using backspace */
            var length = $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].length;
            if (event.keyCode === 8 && (fieldValue == undefined || fieldValue == '')) {
                $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].splice(length - 1, 1);
                if(modelKey === 'ManualConcern' && (($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[index].SOInfo.Id))) {
                  isUpdateRelatedAppointmentRec = true;
                }
                $scope.F_CO.saveServiceJobInfo(index, true, false, isUpdateRelatedAppointmentRec);
            }
        }
        $scope.F_CO.updateMultiSelect = function(event, index, editedFieldIndex, modelKey, fieldLabel) {
            var isUpdateRelatedAppointmentRec = false;
          var isAlreadyExist = false;
            var fieldValue = $scope.M_CO.SOHeaderList[index].SOInfo[modelKey][editedFieldIndex];
            if ((event.keyCode == 13 || event.keyCode == 9 || event.type === 'blur')) {
                if (fieldValue != '' && fieldValue != undefined) {
                    for (var i = 0; i < $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].length; i++) {
                        if (i != editedFieldIndex && $scope.M_CO.SOHeaderList[index].SOInfo[modelKey][i].toLowerCase() === $scope.M_CO.SOHeaderList[index].SOInfo[modelKey][editedFieldIndex].toLowerCase()) {
                            isAlreadyExist = true;
                            $scope.M_CO.isDuplicateTagError = true;
                            //Notification.error('Same ' + fieldLabel.toLowerCase() + ' already exist');
                            Notification.error($translate.instant('Same_fieldLabel_already_exist', {fieldLabel: fieldLabel.toLowerCase() }));
                            $scope.M_CO.SOHeaderList[index].SOInfo[modelKey][editedFieldIndex] = $scope.M_CO.currentTagValue;
                            focusElement(fieldLabel + index + 'Tag' + editedFieldIndex);
                        }
                    }
                    if (!isAlreadyExist) {
                        $scope.M_CO.editModeIndexMultiSelect[fieldLabel] = -1;
                        if(modelKey === 'ManualConcern' && (($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[index].SOInfo.Id))) {
                          isUpdateRelatedAppointmentRec = true;
                        }
                        $scope.F_CO.saveServiceJobInfo(index, false, false, isUpdateRelatedAppointmentRec);
                        $scope.M_CO.toDisplayInput[index] = '';
                    }
                } else {
                    $scope.F_CO.removeFromMultiSelect(editedFieldIndex, index, modelKey, fieldLabel, event);
                    $scope.M_CO.toDisplayInput[index] = '';
                    $scope.M_CO.editModeIndexMultiSelect[fieldLabel] = -1;
                }
            }
            event.stopPropagation();
        }
        var isClickedOnMultiSelectSpan = false;
        $scope.F_CO.displayInput = function(event, index, modelName, modelKey, fieldLabel) {
            if ((fieldLabel != 'Concern' && fieldLabel != 'Cause' && fieldLabel != 'Correction') || (!$scope.M_CO.isServiceJobDisabled(index))) {
                if (!$scope.F_CO.getSOPermissionType()['create/modify'] || $scope.M_CO.isDuplicateTagError) {
                    $scope.M_CO.isDuplicateTagError = false;
                    event.stopPropagation();
                    return;
                }
                if (!isClickedOnMultiSelectSpan) {
                    var length = $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].length;
                    $scope.M_CO.toDisplayInput[index] = modelKey;
                    focusElement(fieldLabel + index);
                }
                isClickedOnMultiSelectSpan = false;
            }
        }
        $scope.M_CO.currentTagValue = '';
        $scope.F_CO.editMultiselectTag = function(event, modelKey, fieldLabel, soHeaderIndex, multiselectTagIndex) {
            if (!$scope.F_CO.getSOPermissionType()['create/modify'] || $scope.M_CO.isDuplicateTagError) {
                $scope.M_CO.isDuplicateTagError = false;
                event.stopPropagation();
                return;
            }
            $scope.M_CO.currentTagValue = angular.copy($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo[modelKey][multiselectTagIndex]);
            $scope.M_CO.editModeIndexMultiSelect[fieldLabel] = multiselectTagIndex;
            focusElement(fieldLabel + soHeaderIndex + 'Tag' + multiselectTagIndex);
            event.stopPropagation();
        }
        $scope.F_CO.removeFromMultiSelect = function(index, parentIndex, ModelKey, fieldLabel, event) {
            if ($scope.M_CO.SOHeaderList[parentIndex].SOInfo.WorkStatus != 'Complete') {
                $scope.M_CO.SOHeaderList[parentIndex].SOInfo[ModelKey].splice(index, 1);
                $scope.M_CO.editModeIndexMultiSelect[fieldLabel] = -1;
                var isUpdateRelatedAppointmentRec = false;
                if(ModelKey === 'ManualConcern' && (($scope.M_CO.soAppointments).hasOwnProperty($scope.M_CO.SOHeaderList[parentIndex].SOInfo.Id))) {
                  isUpdateRelatedAppointmentRec = true;
                }
                $scope.F_CO.saveServiceJobInfo(parentIndex, true, false, isUpdateRelatedAppointmentRec);
            }
            isClickedOnMultiSelectSpan = true;
            event.stopPropagation();
        }
        $scope.displayCauseConcernCorrectionInput = function(index, modelKey) {
            var length = 0;
            if ($scope.M_CO.SOHeaderList) {
                length = $scope.M_CO.SOHeaderList[index].SOInfo[modelKey].length;
            }
            if (length) {
                return false;
            } else {
                return true;
            }
        }
        $scope.F_CO.saveOdometerValue = function(index, type) {
            var fieldValue = $scope.M_CO.SOHeaderList[index].SOInfo[type];
            if (fieldValue != '' && fieldValue != undefined && fieldValue != null && fieldValue != 0) {
                if (type == 'OdometerIn') {
                    if ($scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'] != '' && $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'] != undefined && $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'] != 0 && fieldValue > $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut']) {
                        $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'] = fieldValue;
                    }
                } else if (type == 'OdometerOut') {
                    if ($scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] == '' || $scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] == undefined || $scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] == 0) {
                        Notification.error($translate.instant('Please_fill_odometer_arrival_first'));
                        return;
                    } else if ($scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] != '' && $scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] != undefined && $scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn'] != 0 && fieldValue < $scope.M_CO.SOHeaderList[index].SOInfo['OdometerIn']) {
                      if($scope.M_CO.odometerOutOldValue){
                        $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'] = $scope.M_CO.odometerOutOldValue;
                      }
                      Notification.error($translate.instant('Odometer_departure_can_not_be_less_than_odometer_arrival'));
                        return;
                    }
                }
                $scope.F_CO.saveServiceJobInfo(index, true);
            }
        }

        $scope.F_CO.saveServiceJobOdometerOutValue = function(index) {
          if($scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut']){
            $scope.M_CO.odometerOutOldValue = $scope.M_CO.SOHeaderList[index].SOInfo['OdometerOut'];
          }

        }
        $scope.F_CO.DealFinance.changeProviderAction = function() {
            $scope.M_CO.isShowDFSearchSection = true;
            $scope.M_CO.isShowCancelButtonInDFSearchSection = true;
            $scope.M_CO.DealFinance.selectedCmpnyName = '';
            $scope.M_CO.isLoading = true;
            $scope.F_CO.getListOfFIproducts();
        }
        $scope.F_CO.DealFinance.RemoveDealFinancing = function() {
            var successJson = {
                'type': 'removeDealFinancing'
            };

            $scope.M_CO.isLoading = true;
            DealService.removeDealFinancing($scope.M_CO.Deal.DealFinanceObj.DealId, $scope.M_CO.Deal.DealFinanceObj.Id).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.DealFinance.getEstimatedPayment = function() {
            var intRate =  parseFloat($scope.M_CO.Deal.DealFinanceObj.InterestRate);
            var numOfPayments = $scope.F_CO.DealFinance.getLoanTerm();
            var loanAmount = $scope.F_CO.DealFinance.getAmountFinanced();
            var estimatedPayments;

            if (intRate == 0) {
                estimatedPayments = parseFloat(loanAmount / numOfPayments);
            } else {
                if (parseFloat($scope.M_CO.Deal.DealFinanceObj.InterestRate)) {
                    if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Monthly') {
                        intRate = intRate / 12;
                    } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Semi-Monthly') {
                        intRate = intRate / 24;
                    } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Weekly') {
                        intRate = intRate / 52;
                    } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Bi-Weekly') {
                        intRate = intRate / 26;
                    }
                }
                estimatedPayments = $scope.F_CO.DealFinance.getPMT(intRate, numOfPayments, loanAmount, 0, 0);
            }

            estimatedPayments = isNaN(estimatedPayments) ? 0.00 : estimatedPayments;
            $scope.M_CO.Deal.DealFinanceObj.EstimatedPayment = estimatedPayments;
            return parseFloat($scope.M_CO.Deal.DealFinanceObj.EstimatedPayment);
        }
        $scope.F_CO.DealFinance.getPMT = function(interestRate, numOfPayments, presentValue, futureValue, type) {
            futureValue || (futureValue = 0);
            type || (type = 0);
            var pmt_value = 0;
            if (interestRate === 0) {
                pmt_value = (presentValue + futureValue) / numOfPayments;
            } else {
                interestRate = (interestRate / 100);
                var pvif = Math.pow(1 + interestRate, numOfPayments);
                pmt_value = -interestRate * presentValue * (pvif + futureValue) / (pvif - 1);
                if (type === 1) {
                    pmt_value /= (1 + interestRate);
                }
            }
            pmt_value = (-1 * pmt_value.toFixed(2));
            return parseFloat(pmt_value);
        }
        $scope.F_CO.IsServiceJobStatusDisabled = function(status) {
            if ($scope.M_CO.selectedSOHeaderIndex != undefined && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex] != undefined) {
                for (var i = 0; i < $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems.length; i++) {
                    for (var j = 0; j < $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList.length; j++) {
                        if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsPart && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsNonInventoryPart && ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Required' || $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Ordered')) {
                            return true;
                        } else if($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsSublet
                            && ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Required'
                              || $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Ordered')) {
                          return true;
                        }
                    }
                }
                if (status == 'Complete' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.DealId == null && (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.UnitName || (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ManualConcern.length && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.KitHeaderConcern.length) || ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.TransactionType == 'Third-Party' && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ProviderName))) {
                    return true;
                } else if (status == 'Complete' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.DealId != null && (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.UnitName || ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.TransactionType == 'Third-Party' && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ProviderName))) {
                    return true;
                }
            }
            return false;
        }
        $scope.F_CO.DealFinance.getLoanTerm = function() {
            if ($scope.M_CO.Deal.DealFinanceObj.TermType == 'Months') {
                if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Monthly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 1);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Semi-Monthly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 2);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Weekly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 4.33);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Bi-Weekly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 2.16);
                }
            } else if ($scope.M_CO.Deal.DealFinanceObj.TermType == 'Years') {
                if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Monthly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 12);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Semi-Monthly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 24);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Weekly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 52);
                } else if ($scope.M_CO.Deal.DealFinanceObj.PaymentFrequency == 'Bi-Weekly') {
                    return ($scope.M_CO.Deal.DealFinanceObj.LoanTerm * 26);
                }
            }
        }
        $scope.F_CO.DealFinance.getFIProductTotal = function() {
          return ($scope.M_CO.Deal.DealInfo.FIProductTotal + $scope.M_CO.Deal.DealInfo.FIProductTaxTotal);
        }

        $scope.F_CO.getDealTotal = function() {
          return ($scope.M_CO.Deal.DealInfo.Total + $scope.F_CO.DealFinance.getFIProductTotal());
        }

        $scope.F_CO.DealFinance.getAmountFinanced = function() {
            var amountFinanced = $scope.M_CO.Deal.DealInfo.Total + $scope.F_CO.DealFinance.getFIProductTotal() - ($scope.M_CO.Deal.DealFinanceObj.DownPayment ? parseFloat($scope.M_CO.Deal.DealFinanceObj.DownPayment) : 0);
            amountFinanced = (amountFinanced != null) ? amountFinanced.toFixed(2) : 0;
            return parseFloat(amountFinanced);
        }

        $scope.F_CO.saveServiceJobInfo = function(index, avoidRefresh, isGetUnitImageData, isUpdateRelatedAppointmentRec,isRefreshSOPricingAndTax) {
            setDefaultValuesBeforeServiceJobSaving(index);
            var successJson = {
                'type': 'refreshSOHeaderInfo',
                'SOHeaderIndex': index,
                'isGetUnitImageData': isGetUnitImageData,
                'isUpdateRelatedAppointmentRec': isUpdateRelatedAppointmentRec
            };
            if(avoidRefresh) {
                successJson.type = 'NONE'
            }
            SOHeaderService.updateSOHeader($scope.M_CO.COHeaderId, JSON.stringify($scope.M_CO.SOHeaderList[index].SOInfo)).then(function(successResult) {
                if(isRefreshSOPricingAndTax && $scope.M_CO.SOHeaderList[index].SOGridItems.length > 0) {
                    $scope.M_CO.isLoading = true;
                   SOHeaderService.refreshSOLIPricingAndTax($scope.M_CO.COHeaderId,$scope.M_CO.SOHeaderList[index].SOInfo.Id).then(function(successResult) {
                    var successJson = {
                        'type': 'updateSOLineItem',
                        'SOHeaderIndex': index,
                        'innerSectionId':'DetailsSectionId',
                        'innerSectionName':'Details',
                        'isAvoidSetFocusOnCOU': true
                    };

                    $scope.M_CO.editLineItemIndex = -1;
                    SOHeaderService.getSOHeaderDetails($scope.M_CO.SOHeaderList[index].SOInfo.Id, null).then(new success(successJson).handler, new error().handler);

                  }, new error().handler);
                }
                if (successJson.type === 'NONE' && isUpdateRelatedAppointmentRec && $scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length) {
                  updateAppointmentsOnCustomerOrSOFieldsChange($scope.M_CO.SOHeaderList[index].SOInfo.Id);
                } else {
                    return new success(successJson).handler(successResult);
                }
            }, new error().handler);
        }

        function setDefaultValuesBeforeServiceJobSaving(index) {
            if ($scope.M_CO.SOHeaderList[index].SOInfo.TransactionType != 'Third-Party') {
                $scope.M_CO.SOHeaderList[index].SOInfo.ProviderId = null;
            }
            if ($scope.M_CO.SOHeaderList[index].SOInfo.TransactionType != 'Internal' && $scope.M_CO.SOHeaderList[index].SOInfo.TransactionType != 'Stock Unit') {
                $scope.M_CO.SOHeaderList[index].SOInfo.CategoryNameStr = '';
                $scope.M_CO.SOHeaderList[index].SOInfo.CategoryId = null;
                $scope.M_CO.SOHeaderList[index].SOInfo.CategoryName = '';
            }
        }

        $scope.F_CO.addDeductibleAmount = function(index) {
            $scope.M_CO.SOHeaderList[index].DeductibleItem.DeductibleStatus = null;
            if (!$scope.M_CO.SOHeaderList[index].DeductibleItem.DeductibleId) {
              if(!parseFloat($scope.M_CO.SOHeaderList[index].DeductibleItem.DeductibleAmount)) {
                    return;
                }
                $scope.M_CO.SOHeaderList[index].DeductibleItem.DeductibleId = '';
                $scope.M_CO.isLoading = true;
            }
            $scope.M_CO.SOHeaderList[index].DeductibleItem.SoHeaderId = $scope.M_CO.SOHeaderList[index].SOInfo.Id;
            $scope.M_CO.SOHeaderList[index].DeductibleItem.CoHeaderId = $scope.M_CO.COHeaderId;
            var successJson = {
                'type': 'addDeductibleAmount',
                'SOHeaderIndex': index
            };
            SOHeaderService.addDeductibleAmount(JSON.stringify($scope.M_CO.SOHeaderList[index].DeductibleItem)).then(new success(successJson).handler, new error().handler);
        }

        function calculateShopSuppliesForAllServiceJobs() {
          var viewsPromises = [];
      if($scope.M_CO.SOHeaderList) {
            for(var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
              if(!$scope.M_CO.SOHeaderList[i].SOInfo.DealId
                  && $scope.M_CO.SOHeaderList[i].SOInfo.TransactionType != 'Internal'
                  && $scope.M_CO.SOHeaderList[i].SOInfo.TransactionType != 'Stock Unit'
                  && $scope.M_CO.SOHeaderList[i].SOInfo.TransactionType != 'Deal Service') {
                var calculateShopSupplies = false;
                      for(var j = 0; j < $scope.M_CO.SOHeaderList[i].SOGridItems.length; j++) {
                        var index = _.findIndex($scope.M_CO.SOHeaderList[i].SOGridItems[j].SOLIList, {
                                'IsLabour': true
                            });
                      if (index > -1 || ($scope.M_CO.SOHeaderList[i].SOGridItems[j].Id && $scope.M_CO.SOHeaderList[i].SOGridItems[j].IsServiceKit)) {
                              calculateShopSupplies = true;
                              break;
                            }
                      }
                    if(calculateShopSupplies) {
                      viewsPromises.push($scope.F_CO.calculateShopSupplies($scope.M_CO.SOHeaderList[i].SOInfo.Id));
                        }
              }
                }
          }

          return $q.all(viewsPromises).then(function(){
                $scope.F_CO.getCOHeaderDetailsByGridName();
          });
        }

        var refreshCOPricingAndTaxOnKit = function() {
            $scope.M_CO.isLoading = true;
            var successJson = {
                'callback': calculateShopSuppliesForAllServiceJobs
            };
            CustomerService.refreshCOPricingAndTaxOnKit($scope.M_CO.COHeaderId, $scope.M_CO.coHeaderRec.CustomerId).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.refreshCOPricingAndTax = function() {
            $scope.M_CO.isLoading = true;
            var viewsPromises = [];
      if($scope.M_CO.SOHeaderList) {
            for(var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
              if($scope.M_CO.SOHeaderList[i].SOInfo.TransactionType !== 'Customer') {
                viewsPromises.push($scope.F_CO.refreshSOPricingAndTax($scope.M_CO.SOHeaderList[i].SOInfo.Id));
              }
                }
          }
          return $q.all(viewsPromises).then(function() {
                var successJson = {
                    'callback': refreshCOPricingAndTaxOnKit
                };
                CustomerService.refreshCOPricingAndTax($scope.M_CO.COHeaderId, $scope.M_CO.coHeaderRec.CustomerId).then(new success(successJson).handler, new error().handler);
          });
        }

        $scope.F_CO.refreshSOPricingAndTax = function(soHeaderId) {
          SOHeaderService.refreshSOPricingAndTax(soHeaderId).then(function(result) {
            return;
            }, function(error) {
              handleErrorAndExecption(error);
            });
        }

        $scope.F_CO.CalculateCashPaymentRoundingAmount = function(BalanceDue) {
            var CashPaymentRoundingDollarValue = $scope.M_CO.CashPaymentRoundingCentValue / 100;
            var roundedBalanceDue = (Math.round(BalanceDue / CashPaymentRoundingDollarValue) * CashPaymentRoundingDollarValue).toFixed(2);
            roundedBalanceDue = parseFloat(roundedBalanceDue);
            $scope.CheckoutInfoModel.RoundedBalanceDue = roundedBalanceDue;
            return roundedBalanceDue;
        }
        function determineBalanceDue() {
          var amountPaying;
          if($scope.CheckoutInfoModel.paymentMethod === 'Use Deposit') {
            amountPaying = ($scope.CheckoutInfoModel.BalanceDue > $scope.M_CO.Deposit.TotalCustomerDepositAmount) && $scope.M_CO.Deposit.TotalCustomerDepositAmount ? $scope.M_CO.Deposit.TotalCustomerDepositAmount.toFixed(2) : $scope.CheckoutInfoModel.BalanceDue;
          } else if($scope.CheckoutInfoModel.paymentMethod === 'Use Deal Deposit') {
            amountPaying = ($scope.CheckoutInfoModel.BalanceDue > $scope.M_CO.Deposit.TotalDepositAmout) && $scope.M_CO.Deposit.TotalDepositAmout ? $scope.M_CO.Deposit.TotalDepositAmout.toFixed(2) : $scope.CheckoutInfoModel.BalanceDue;
          } else if($scope.CheckoutInfoModel.paymentMethod === 'Store Credit') {
            amountPaying = ($scope.CheckoutInfoModel.BalanceDue > $scope.CheckoutInfoModel.CustomerStoreCredit) && $scope.CheckoutInfoModel.CustomerStoreCredit ? $scope.CheckoutInfoModel.CustomerStoreCredit.toFixed(2) : $scope.CheckoutInfoModel.BalanceDue;
          } else {
            amountPaying = $scope.CheckoutInfoModel.BalanceDue;
          }
          $scope.CheckoutInfoModel.amountPaying = amountPaying;
        }
        $scope.F_CO.selectPaymentMethod = function(paymentMethod) {
            if ($scope.M_CO.Deal.DealInfo != undefined && $scope.M_CO.Deal.DealInfo.DealType != 'Financed' && paymentMethod == "Financing") {
                return;
            } else if ($scope.M_CO.Deposit.TotalDepositAmout <= 0 && paymentMethod == 'Use Deposit') {
                return;
            } else if (!($scope.CheckoutInfoModel.CustomerStoreCredit > 0 || $scope.CheckoutInfoModel.BalanceDue < 0) && paymentMethod == 'Store Credit') {
                return;
            } else if (paymentMethod == 'Cash') {
                $scope.CheckoutInfoModel.BalanceDue = $scope.F_CO.CalculateCashPaymentRoundingAmount($scope.CheckoutInfoModel.BalanceDue);
                $scope.CheckoutInfoModel.paymentMethod = 'Cash';
                $scope.CheckoutInfoModel.selectedOptionForCheckout = 'Cash';
                $scope.CheckoutInfoModel.amountPaying = $scope.CheckoutInfoModel.BalanceDue;
                setTimeout(function() {
                    angular.element('#' + 'CheckoutAmount').focus();
                }, 100);
            } else {
                $scope.CheckoutInfoModel.BalanceDue = $scope.CheckoutInfoModel.BalanceDueCopy.toFixed(2);
                $scope.CheckoutInfoModel.paymentMethod = paymentMethod;
                $scope.CheckoutInfoModel.selectedOptionForCheckout = paymentMethod;
                determineBalanceDue();
                setTimeout(function() {
                    angular.element('#' + 'CheckoutAmount').focus();
                }, 100);
            }
            if ($scope.CheckoutInfoModel.BalanceDue < 0) {
                setTimeout(function() {
                    angular.element('#refundBtn').focus();
                }, 100);
            }
        }
        $scope.F_CO.addPayment = function() {
            $scope.CheckoutInfoModel.amountPaying = parseFloat($scope.CheckoutInfoModel.amountPaying);
            $scope.CheckoutInfoModel.BalanceDue = parseFloat($scope.CheckoutInfoModel.BalanceDue);
            $scope.CheckoutInfoModel.ChangeDue = ($scope.CheckoutInfoModel.selectedOptionForCheckout == 'Cash') ? ($scope.CheckoutInfoModel.amountPaying - $scope.CheckoutInfoModel.RoundedBalanceDue) : 0;
            $scope.CheckoutInfoModel.CustomerStoreCredit = parseFloat($scope.CheckoutInfoModel.CustomerStoreCredit);
            if ($scope.CheckoutInfoModel.paymentMethod != 'Cash' && !$scope.CheckoutInfoModel.isReversePayment) {
                if ($scope.CheckoutInfoModel.amountPaying > $scope.CheckoutInfoModel.BalanceDue) {
                    Notification.error($translate.instant('Payment_amount_should_not_be_greater_than_balance_due'));
                    return;
                }
            }
            if ($scope.CheckoutInfoModel.paymentMethod == 'Store Credit' && $scope.CheckoutInfoModel.CustomerStoreCredit < $scope.CheckoutInfoModel.amountPaying) {
                Notification.error($translate.instant('Payment_amount_entered_cannot_exceed_the_available_store_credit_balance'));
                return;
            }
            var Payment = [];
            var PaymentModel = {};
            var maxPayment = 999999.99;
            PaymentModel.ReverseLink = $scope.CheckoutInfoModel.PaymentReverseLink;
            PaymentModel.PaymentMethod = $scope.CheckoutInfoModel.paymentMethod;
            PaymentModel.PaymentDate = $scope.CheckoutInfoModel.paymentDate;
            if ($scope.CheckoutInfoModel.selectedOptionForCheckout == 'Cash' && $scope.CheckoutInfoModel.amountPaying >= $scope.CheckoutInfoModel.RoundedBalanceDue) {
                PaymentModel.Amount = $scope.CheckoutInfoModel.RoundedBalanceDue;
                var RoundedPaymentModel = {};
                $scope.CheckoutInfoModel.RoundedBalanceDue = parseFloat($scope.CheckoutInfoModel.RoundedBalanceDue);
                RoundedPaymentModel.Amount = ($scope.CheckoutInfoModel.BalanceDueCopy - $scope.CheckoutInfoModel.RoundedBalanceDue).toFixed(2);
                RoundedPaymentModel.PaymentMethod = 'Cash Rounding';
                RoundedPaymentModel.ReverseLink = $scope.CheckoutInfoModel.PaymentReverseLink;
                RoundedPaymentModel.COInvoiceHeaderId = $scope.CheckoutInfoModel.activeInvHeaderId;
                RoundedPaymentModel.IsReverse = $scope.CheckoutInfoModel.isReversePayment;
                RoundedPaymentModel.PaymentDate = $scope.CheckoutInfoModel.paymentDate;
                Payment.push(RoundedPaymentModel);
            } else {
                PaymentModel.Amount = $scope.CheckoutInfoModel.amountPaying;
            }
            PaymentModel.COInvoiceHeaderId = $scope.CheckoutInfoModel.activeInvHeaderId;
            PaymentModel.IsReverse = $scope.CheckoutInfoModel.isReversePayment;
            var invoiceItemsList = $scope.CheckoutInfoModel.InvoiceItemList ? $scope.CheckoutInfoModel.InvoiceItemList : [];
            if($scope.F_CO.isDealSelectedForCheckout) {
              for(var i = 0; i < invoiceItemsList.length; i++) {
                  if(invoiceItemsList[i].CheckoutItemType === 'Deal' && invoiceItemsList[i].IsActive) {
                    PaymentModel.DealId = invoiceItemsList[i].ItemId;
                  }
                }
            }

            if ((parseFloat($scope.F_CO.calculateTotalPayment()) < (parseFloat(PaymentModel.Amount) * -1)) && $scope.CheckoutInfoModel.isReversePayment && PaymentModel.ReverseLink != undefined && PaymentModel.ReverseLink != '' && PaymentModel.ReverseLink != null) { // for reverse
                $scope.CheckoutInfoModel.amountPaying = (-1 * $scope.CheckoutInfoModel.amountPaying).toFixed(2);
                Notification.error($translate.instant('Amount_should_be_less_than_or_equal_to_total_payment_received'));
                return;
            }
            if (PaymentModel.Amount == "") { // TODO - Remove this
                Notification.error($translate.instant('Please_enter_amount'));
                return;
            } else if ((+(PaymentModel.Amount)).toFixed(2) == 0) { // TODO - Remove this
                Notification.error($translate.instant('Amount_Can_t_be_zero'));
                return;
            } else if (isNaN(PaymentModel.Amount)) { // TODO - Remove this
                Notification.error($translate.instant('Amount_should_be_numeric'));
                return;
            } else if (PaymentModel.Amount < 0 && !$scope.CheckoutInfoModel.isReversePayment && !$scope.CheckoutInfoModel.IsPartReturn) { // TODO - Remove this
                Notification.error($translate.instant('Amount_should_be_positive'));
                return;
            } /*else if (PaymentModel.PaymentMethod == 'Use Deposit' && PaymentModel.Amount > $scope.M_CO.Deposit.TotalDepositAmout) { // TODO - Remove this
                Notification.error("Deposit Not Available");
                return;
            }*/ else if ((PaymentModel.PaymentMethod == 'Use Deposit' && PaymentModel.Amount > $scope.M_CO.Deposit.TotalCustomerDepositAmount) || (PaymentModel.PaymentMethod == 'Use Deal Deposit' && PaymentModel.Amount > $scope.M_CO.Deposit.TotalDepositAmout)) { // TODO - Remove this
                Notification.error($translate.instant('Deposit_not_available'));
                return;
            } else if (PaymentModel.Amount > maxPayment) {
                Notification.error($translate.instant('Amount_cannot_exceed_six_digits'));
                return;
            } else if (!$scope.CheckoutInfoModel.IsPartReturn && (PaymentModel.Amount < -1 * $scope.M_CO.coHeaderRec.TotalPayments)) { // TODO - Remove this
                Notification.error($translate.instant('Total_can_t_be_negative'));
                return;
            }
            PaymentModel.Amount = (+(PaymentModel.Amount)).toFixed(2);
            PaymentModel.CashDrawerId  = $scope.M_CO.selectedcashDrawerId;
            Payment.push(PaymentModel);
            var successJson = {
                'type': 'getCOCheckoutInfo'
            };
            CheckoutServices.addPayment(angular.toJson(Payment), $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
            $scope.CheckoutInfoModel.amountPaying = null;
            $scope.CheckoutInfoModel.RoundedBalanceDue = 0;
        }

        $scope.F_CO.RefundPayment = function() {
            $scope.CheckoutInfoModel.isReversePayment = true;
            $scope.CheckoutInfoModel.PaymentReverseLink = null;
            $scope.F_CO.addPayment();
        }

        $scope.F_CO.paymentGoAction = function(paymentObj) {
            $scope.CheckoutInfoModel.selectedOptionForCheckout = null;
            $scope.CheckoutInfoModel.isReversePayment = true;
            $scope.CheckoutInfoModel.PaymentReverseLink = paymentObj.COInvoicePaymentId;
            $scope.CheckoutInfoModel.paymentMethod = paymentObj.PaymentMethod;
            $scope.CheckoutInfoModel.amountPaying = -(paymentObj.Amount).toFixed(2);
        }

        $scope.F_CO.updateCOInvoiceItem = function(index) {
            var checkoutItem = $scope.CheckoutInfoModel.InvoiceItemList[index];
            if ($scope.F_CO.disableCheckOutItemSelection(checkoutItem)) {
                return;
            }
            if ($scope.F_CO.isSelectedable(checkoutItem)) {
                checkoutItem.IsActive = !checkoutItem.IsActive;
                //added for deal so that we do not need to make deal details call if change is made on checkout modal 
                if(checkoutItem.CheckoutItemType === 'Deal' && $scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo) {
                	$scope.M_CO.Deal.DealInfo.IsInvoiceItemActive = checkoutItem.IsActive; 
                }
                var invItemList = [checkoutItem];
                var successJson = {
                    'type': 'getCOCheckoutInfo'
                };
                CheckoutServices.updateCOInvoiceItem(angular.toJson(invItemList), $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
            }
        }
        $scope.F_CO.disableSelectAllCOInvoiceItemBtn = function() {
            var isCheckoutItemNotAvailable = true;
            if (!isBlankValue($scope.CheckoutInfoModel.InvoiceItemList)) {
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsInvoiceable) {
                        isCheckoutItemNotAvailable = false;
                        break;
                    }
                }
            }
            return isCheckoutItemNotAvailable;
        }
        $scope.F_CO.disableSelectAllCOInvoiceItemBtnWithPermission = function() {
            var isSelectAllBtnDisabled = false;
            if (!isBlankValue($scope.CheckoutInfoModel.InvoiceItemList)) {
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                 if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType === 'Deal') {
                	 	isSelectAllBtnDisabled = $scope.CheckoutInfoModel.InvoiceItemList.length === 1  && $scope.M_CO.Deal.DealInfo.DealStatus === 'Approved' ? false : true;
                	 	break;
                    }
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsInvoiceable && $scope.F_CO.disableCheckOutItemSelection($scope.CheckoutInfoModel.InvoiceItemList[i])) {
                        isSelectAllBtnDisabled = true;
                        break;
                    }
                }
            }
            return isSelectAllBtnDisabled;
        }

        $scope.F_CO.isCommitAndInstallActionDone = function() {
            if ($scope.M_CO.Deal.DealInfo.IsDealFulfilled || $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced' || ($scope.M_CO.Deal.DealInfo.UnitStatus === 'Committed' && ($scope.M_CO.Deal.UnitList[0].DealItemObj.OptionAndFeeStatus && $scope.M_CO.Deal.UnitList[0].DealItemObj.OptionAndFeeStatus !== 'Uncommitted'))) {
                return true;
            }
            return false;
        }

        $scope.F_CO.selectAllCOInvoiceItem = function() {
            if ($scope.F_CO.disableSelectAllCOInvoiceItemBtn() || $scope.F_CO.disableSelectAllCOInvoiceItemBtnWithPermission()) {
                return;
            }
            var checkoutItemList = $scope.CheckoutInfoModel.InvoiceItemList;
            $scope.M_CO.isAllInvoiceItemsSelected = !$scope.M_CO.isAllInvoiceItemsSelected;
            for (var i = 0; i < checkoutItemList.length; i++) {
                if ($scope.F_CO.isSelectedable(checkoutItemList[i])) {
                    $scope.CheckoutInfoModel.InvoiceItemList[i].IsActive = $scope.M_CO.isAllInvoiceItemsSelected;
                }
            }
            var successJson = {
                'type': 'getCOCheckoutInfo'
            };
            CheckoutServices.updateCOInvoiceItem(angular.toJson($scope.CheckoutInfoModel.InvoiceItemList), $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }
        $scope.M_CO.isServiceJobDisabled = function(index) {
            if ($scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus == 'Complete' || $scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus == 'Invoiced' || !($scope.F_CO.getSOPermissionType()['create/modify'])) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_CO.isSOTransactionTypeChangeable = function(index) {
          if($scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus == 'Invoiced' || $scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus == 'Complete') {
             return false;
          } else {
        	  if($scope.M_CO.SOHeaderList[index].SOInfo.TransactionType == 'Third-Party' && $scope.M_CO.SOHeaderList[index].SOInfo.ClaimStatus != 'Unsubmitted') {
                  return false;
                } else if ($scope.M_CO.SOHeaderList[index].SOInfo.TransactionType == 'Third-Party' && $scope.M_CO.SOHeaderList[index].DeductibleItem.DeductibleStatus == 'Paid') {
                  return false;
                } else {
                 return true;
                }
          }
        }
        $scope.F_CO.showAutoComplete = function(WorkStatus,ClaimStatus) {
          if($scope.M_CO.coHeaderRec.OrderStatus === 'Closed') {
            return false;
          } else if(WorkStatus &&  (WorkStatus === 'Invoiced' || (ClaimStatus && ClaimStatus === 'Approved'))) {
            return false;
          } else {
            return true;
          }
        }
        $scope.F_CO.getCustomerPhoneNumber = function(){
          var customerPhoneNumber;
          if ($scope.M_CO.CustomerCardInfo.CustomerPreferredPhone) {
            if($scope.M_CO.CustomerCardInfo.CustomerPreferredPhone === 'HomeNumber') {
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber;
            } else if($scope.M_CO.CustomerCardInfo.CustomerPreferredPhone === 'OtherPhone') {
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone;
            } else if($scope.M_CO.CustomerCardInfo.CustomerPreferredPhone === 'WorkNumber') {
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber;
            }
          } else {
            if($scope.M_CO.CustomerCardInfo.CustomerHomeNumber) {
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber;
            } else if($scope.M_CO.CustomerCardInfo.CustomerWorkNumber) {
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber;
            } else if((!$scope.M_CO.CustomerCardInfo.CustomerWorkNumber && $scope.M_CO.CustomerCardInfo.CustomerOtherPhone && $scope.M_CO.CustomerCardInfo.CustomerType == 'Business')
                  || (!$scope.M_CO.CustomerCardInfo.CustomerHomeNumber && $scope.M_CO.CustomerCardInfo.CustomerOtherPhone && $scope.M_CO.CustomerCardInfo.CustomerType == 'Individual')){
              customerPhoneNumber = $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone;
            }
          }
          return customerPhoneNumber;
        }
        $scope.M_CO.isSOItemDisabled = function() {
            if (!$scope.F_CO.getSOPermissionType()['create/modify']) {
                return true;
            } else {
                return false;
            }
        }
        $scope.F_CO.isSelectedable = function(checkoutItem) {
            if (checkoutItem.IsInvoiceable) {
                return true;
            } else {
                return false;
            }
        }
        $scope.F_CO.isActiveChechout = function() { //FIXME spelling mistake

            var isEnable = true;
            if ($scope.M_CO.SOHeaderList.length == 0 && $scope.M_CO.COKHList.length == 0) {
                isEnable = false;
            } else if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed') {
                isEnable = false;
            } else {
                for (var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                    if ($scope.M_CO.SOHeaderList[i].SOInfo.WorkStatus == 'Complete') {
                        isEnable = true;
                        break;
                    } else {
                        isEnable = false;
                    }
                }
                for (var i = 0; i < $scope.M_CO.COKHList.length; i++) {
                    if ($scope.M_CO.COKHList[i].COLIList != undefined) {
                        for (var j = 0; j < $scope.M_CO.COKHList[i].COLIList.length; j++) {
                            if ($scope.M_CO.COKHList[i].COLIList[j].Status != 'Required') {
                                isEnable = true;
                                break;
                            } else {
                                isEnable = false;
                            }
                        }
                    }
                }
            }
            return isEnable;
        }
        $scope.F_CO.calculateTotalPayment = function() {
            var total = 0;
            var paymentList = $scope.CheckoutInfoModel.InvoicePaymentList;
            if (paymentList != undefined) {
                for (var i = 0; i < paymentList.length; i++) {
                    if (!($scope.CheckoutInfoModel.isReversePayment && paymentList[i].PaymentMethod == 'Cash Rounding')) {
                        total += paymentList[i].Amount;
                    }
                }
            }
            $scope.M_CO.coHeaderRec.TotalPayments = total;
            return $scope.M_CO.coHeaderRec.TotalPayments;
        }

        $scope.F_CO.doCheckout = function() {
            $scope.M_CO.isLoading = true;
            var isDealInvoiced = false;
            if (!isBlankValue($scope.CheckoutInfoModel.InvoiceItemList)) {
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType === 'Deal') {
                    isDealInvoiced = true;
                  }
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsInvoiceable && $scope.CheckoutInfoModel.InvoiceItemList[i].IsActive) {
                        $scope.CheckoutInfoModel.InvoiceItemList[i].IsDisplayDiscountAmount = $scope.M_CO.isShowDiscount;
                    }
                }
            }
            for(var j=0; j < $scope.CheckoutInfoModel.InvoiceItemList.length; j++) {
                $scope.CheckoutInfoModel.InvoiceItemList[j].InvoiceDate = $scope.CheckoutInfoModel.invoicePaymentDate;
            }
            var invItemList = $scope.CheckoutInfoModel.InvoiceItemList;
            var successJson = {
                'type': 'getCOHeaderDetailsByGridName',
                calleeMethodName: 'doCheckout',
                'callback': getSOHeaderDetails,
                'callbackParam': {
                    'isDealCallback': true
                }
            };

            CheckoutServices.closedInvoiceAction(angular.toJson(invItemList), $scope.M_CO.COHeaderId, 'Customer').then(function(successResult) {
              new success(successJson).handler(successResult);
              if($scope.M_CO.coHeaderRec.CustomerId && isDealInvoiced) {
                getActiveCOUList();
              }
            }, new error().handler);
        }
        $scope.F_CO.closeChangeStatusDialog = function(index) {
            angular.element('#serviceJobStatusChange').modal('hide');
        }
        angular.element(document).on("click", "#serviceJobStatusChange .modal-backdrop", function() {
          $scope.F_CO.closeChangeStatusDialog();
        });

        $scope.F_CO.DealFinance.closeChangeDFStatusDialog = function(index) {
          angular.element('#dealFinancingStatusChange').modal('hide');
        }

        function setResetPositionSaveIpadButton() {
            if ("ontouchstart" in document.documentElement && window.innerWidth < 1024) {
                angular.element(".save-on-ipad").css("bottom", angular.element(document.querySelector(".bp-checkout-box"))[0].offsetHeight);
            }
        }
        $(window).resize(function(){
            setResetPositionSaveIpadButton();
        });
        $scope.F_CO.showDropDownCheckOutValue = function() {
            angular.element(".bp-checkout-box.open").css("height", "220px");
            if (window.innerWidth <= 767) {
                angular.element(".bp-checkout-box.open").css("height", "270px");
            }
            $scope.M_CO.showCheckouttable = true;
            setResetPositionSaveIpadButton();
        }

        $scope.F_CO.hideDropDownCheckOutValue = function() {
            angular.element(".bp-checkout-box.open").css("height", "auto");
            $scope.M_CO.showCheckouttable = false;
            setResetPositionSaveIpadButton();
        }

        $scope.F_CO.addDealFinancing = function() {
            $scope.M_CO.Deal.DealInfo.DealType = 'Financed';
            $scope.M_CO.DealFinance.selectedCmpnyName = '';
            $scope.M_CO.DealFinance.showProviderList = false;
            $scope.M_CO.isLoading = true;
            $scope.F_CO.saveDealInfo($scope.M_CO.Deal.DealInfo, true);
        }

        $scope.F_CO.saveDealInfo = function(dealInfoObj, isCallbackFinanceCompanyList) {
            var successJson = {
                'type': 'saveDealInfo',
                'stopLoadingIcon': true
            };
            if (isCallbackFinanceCompanyList) {
                successJson = {
                    'type': 'saveDealInfo',
                    'stopLoadingIcon': false,
                    'callback': $scope.F_CO.saveFinancingInfo,
                    'callbackParam': {
                        'isCreateFinancingSection': true
                    }
                };
            }
             DealService.saveDealInfoDetails($scope.M_CO.COHeaderId, $scope.M_CO.Deal.DealInfo.Id, angular.toJson(dealInfoObj)).then(function(successResult) {
                     new success(successJson).handler(successResult);

            }, new error().handler);


        }

        $scope.F_CO.getListOfFinanceCompany = function() {
            var successJson = {
                'type': 'getListOfFinanceCompany'
            };
            DealService.getDealFinanceMasterData().then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.getListOfFIproducts = function() {
            var successJson = {
                'type': 'getListOfFIproducts'
            };
            DealService.getDealFinanceMasterData().then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.openJobStausPopUp = function(index,event) {
        	event.preventDefault();
          if( ($scope.F_CO.getSOPermissionType()['create/modify']) ){
            $scope.M_CO.reOpenStatus.btnLabel = "Save";
                if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.WorkStatus === 'Complete') {
                    $scope.M_CO.reOpenStatus.title = "Re-open this order for work";
                    $scope.M_CO.reOpenStatus.status = "Re-open for work";
                } else if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.WorkStatus === 'Invoiced') {
                    $scope.M_CO.reOpenStatus.title = "This job has been invoiced and cannot be modified";
                    $scope.M_CO.reOpenStatus.status = "Invoiced";
                    $scope.M_CO.reOpenStatus.btnLabel = "Close";
                }
                angular.element('#serviceJobStatusChange').modal({
                    backdrop: 'static',
                    keyboard: false
                });
                angular.element('#serviceJobStatusChange').show();
          }
        }

        $scope.F_CO.disableServiceJobStatusChkbox = function(status) {
            if (($scope.M_CO.selectedSOHeaderIndex || $scope.M_CO.selectedSOHeaderIndex == 0) && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex]) {
              if(status === 'Complete' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.UnitStatus === 'On Order' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.TransactionType === 'Deal Service') {
                return true;
              }

              if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.WorkStatus == 'In Progress') {
                    if (status == 'New' || status == 'Ready') {
                        return true;
                    }
                } else if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.WorkStatus == 'Complete') {
                    if (status == 'New' || status == 'Ready' || status == 'In Progress' || status == 'On Hold') {
                        return true;
                    }
                } else if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.newWorkStatus == 'Re-open for work' || $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.newWorkStatus == 'Invoiced') {
                    return true;
                }
            }
        }

        $scope.F_CO.changeServiceJobStatus = function(status) {
            if ($scope.F_CO.disableServiceJobStatusChkbox(status)) {
                return;
            }
            if (status == 'Complete' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.DealId == null && (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.UnitName || (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ManualConcern.length && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.KitHeaderConcern.length) || ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.TransactionType == 'Third-Party' && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ProviderName))) {
                return;
            } else if (status == 'Complete' && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.DealId != null && (!$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.UnitName || ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.TransactionType == 'Third-Party' && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.ProviderName))) {
                return;
            } else {
                for (var i = 0; i < $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems.length; i++) {
                    for (var j = 0; j < $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList.length; j++) {
                        if ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsPart && !$scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsNonInventoryPart && $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Required' || $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Ordered') {
                            return;
                        } else if($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].IsSublet
                            && ($scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Required'
                              || $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOGridItems[i].SOLIList[j].Status == 'Ordered')) {
                          return;
                        }
                    }
                }
            }
            $scope.M_CO.SOHeaderList[$scope.M_CO.selectedSOHeaderIndex].SOInfo.newWorkStatus = status;
        }

        $scope.F_CO.reOpenServiceJob = function(index, status) {
            if (status === 'Re-open for work') {
                $scope.M_CO.SOHeaderList[index].SOInfo.newWorkStatus = 'Re-open for work';
            } else if (status === 'Invoiced') {
                $scope.M_CO.SOHeaderList[index].SOInfo.newWorkStatus = 'Invoiced';
                $scope.M_CO.SOHeaderList[index].SOInfo.WorkStatus = 'Invoiced';
            }
        }

        $scope.F_CO.disableSendTextButtton = function() {
            if ($scope.M_CO.CustomerCardInfo.CustomerHomeNumber || $scope.M_CO.CustomerCardInfo.CustomerWorkNumber || $scope.M_CO.CustomerCardInfo.CustomerOtherPhone) {
                return false;
            } else {
                return true;
            }
        }
        $scope.F_CO.openAddLogTechnicianTimePopUp = function(soHeaderId, soHeaderIndex) {
            var AddEditLogTechnicianTimeParams = {
                soHeaderId: soHeaderId,
                coHeaderId: $scope.M_CO.COHeaderId,
                soHeaderIndex: soHeaderIndex
            };
            loadState($state, 'CustomerOrder_V2.AddEditLogTechnicianTime', {
                AddEditLogTechnicianTimeParams: AddEditLogTechnicianTimeParams
            });
        }
        $scope.F_CO.openEditLogTechnicianTimePopUp = function(soHeaderId, soHeaderIndex, hoursLoggedIndex) {
            var AddEditLogTechnicianTimeParams = {
                isEditMode: true,
                HourLogRec: angular.copy($scope.M_CO.SOHeaderList[soHeaderIndex].HoursLoggedList[hoursLoggedIndex]),
                soHeaderId: soHeaderId,
                coHeaderId: $scope.M_CO.COHeaderId,
                soHeaderIndex: soHeaderIndex
            };
            loadState($state, 'CustomerOrder_V2.AddEditLogTechnicianTime', {
                AddEditLogTechnicianTimeParams: AddEditLogTechnicianTimeParams
            });
        }
        $scope.F_CO.logHourRecordSaveCallback = function(hourLogList, soHeaderIndex) {
            $scope.M_CO.SOHeaderList[soHeaderIndex].HoursLoggedList = hourLogList;
            $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.WorkStatus = hourLogList[0].SOHeaderStatus;
            $scope.M_CO.SOHeaderList[soHeaderIndex].HoursLoggedListCopy = angular.copy($scope.M_CO.SOHeaderList[soHeaderIndex].HoursLoggedList);
            $scope.M_CO.editLineItem = '';
            showTooltip('body');
            setTimeout(function() {
                $scope.F_CO.expandInnerSection('ServiceJob' + soHeaderIndex + '_LogTechnicianTimeSectionId', 'ServiceJob' + soHeaderIndex + '_LogTechnicianTime')
            }, 100);
        }
        $scope.F_CO.CustomerSaveCallback = function(customerId,addCustomerCoBuyer) {
            if (!$scope.M_CO.COHeaderId || $scope.M_CO.createNewCustomerOrderFromSkipButton) {
                $scope.M_CO.COHeaderId = null;
                if($scope.M_CO.createNewCustomerOrderFromSkipButton) {
                    customerId = $scope.M_CO.coHeaderRec.CustomerId;
                    $scope.M_CO.IsShowMerchandiseSection = false;
                    $scope.M_CO.sellingGroup = 'Part Sale';
                } else if (!customerId && selectedId) {
                    customerId = selectedId;
                } 
                var successJson = {
                    'type': 'createCO'
                };
                createCOServerCall(customerId, successJson);
            } else {
                if(!addCustomerCoBuyer) {
                  var successJson = {
                    'type': 'addCustomer',
                    'callback': $scope.F_CO.getCOHeaderDetailsByGridName
                  };

                  if (!$scope.M_CO.coHeaderRec.CustomerId && $scope.M_CO.isOpenSelectCustomerSectionForCashSaleSpecialOrder) { // Handling For Cash Sale Oversold Functionality
                    successJson['addCOLIAndCreateSpecialOrder'] = true;
                  }
                  CustomerService.addCustomer($scope.M_CO.COHeaderId, customerId).then(new success(successJson).handler, new error().handler);
                } else {
                   $scope.M_CO.Deal.DealFinanceObj.CoBuyerId = customerId;
                    $scope.F_CO.saveFinancingInfo('',true, false);
                }

            }
        }
        $scope.F_CO.editHourLogged = function(sectionName, SOHeaderIndex, SOHeaderId, HoursLoggedIndex) {
            $scope.M_CO.editLineItem = sectionName + '_' + 'SOHeader' + SOHeaderIndex + '_HoursLogged' + HoursLoggedIndex;
            showTooltip('body');
            $scope.F_CO.openEditLogTechnicianTimePopUp(SOHeaderId, SOHeaderIndex, HoursLoggedIndex);
        }
        $scope.F_CO.showSearchCoBuyer = function() {
          $scope.M_CO.Deal.showSearchCoBuyerDiv = true;
          setTimeout(function(){
            angular.element("#autocompleteCustomerCoBuyer").focus();
          },100);

        }
        $scope.F_CO.loadDataForServiceWorkSheet = function() {
            if ($scope.M_CO.expandedSectionName.includes('Job') && $scope.F_CO.isTabVisible('Service')) {
                $scope.M_CO.CurrentActiveTabIndex = 1;
            } else if ($scope.M_CO.expandedSectionName.includes('Merchandise') && $scope.F_CO.isTabVisible('Merchandise')) {
                $scope.M_CO.CurrentActiveTabIndex = 0;
            } else if ($scope.M_CO.expandedSectionName.includes('Deal') && $scope.F_CO.isTabVisible('Deal')) {
                $scope.M_CO.CurrentActiveTabIndex = 2;
            } else if ($rootScope.GroupOnlyPermissions['Customer invoicing']['view']) {
                $scope.M_CO.CurrentActiveTabIndex = $scope.M_CO.printDocumentTypeList.length - 1;
            } else {
                if ($scope.F_CO.isTabVisible('Merchandise')) {
                    $scope.M_CO.CurrentActiveTabIndex = 0;
                } else if ($scope.F_CO.isTabVisible('Service')) {
                    $scope.M_CO.CurrentActiveTabIndex = 1;
                } else if ($scope.F_CO.isTabVisible('Deal')) {
                    $scope.M_CO.CurrentActiveTabIndex = 2;
                }
            }
            if ($scope.F_CO.isTabVisible($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name)) {
                $scope.F_CO.setCurrentActiveTab($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name);
            } else {
                $scope.F_CO.setCurrentActiveTab(getFirstVisibleTabNameForPrint());
            }
            loadDataForDocumentsTab();
            if ($rootScope.GroupOnlyPermissions['Service job']['view'] && $scope.M_CO.SOHeaderList.length > 0 && $scope.F_CO.SOHeaderListContainsUnit()) {
                var successJson = {
                    'type': 'getServiceWorksheetPrintDetail'
                };
                SOHeaderService.getServiceWorksheetPrintDetail($scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
            }
        }

        function getFirstVisibleTabNameForPrint() {
            for(var j=0 ; j < $scope.M_CO.printDocumentTypeList.length; j++) {
                if($scope.F_CO.isTabVisible($scope.M_CO.printDocumentTypeList[j].Name)) {
                    return $scope.M_CO.printDocumentTypeList[j].Name;
                }
            }
            return 'Receipts';
        }

        function loadDataForDocumentsTab() {
          var tabIndex = 3;
          var printItem;
          $scope.M_CO.printDocumentTypeList[tabIndex].PrintItems = [];
          var sectionToPermissionObjectMap = {deal: 'Deal', dealFinance: 'Deal', so: 'Service job'};
          Object.keys($scope.M_CO.documents.forms).forEach(function(section) {
            if($scope.M_CO.documents.forms[section]) {
              Object.keys($scope.M_CO.documents.forms[section]).forEach(function(key) {

                for(var i=0; $scope.M_CO.documents.forms[section][key] && i < $scope.M_CO.documents.forms[section][key].length; i++) {
                  printItem = {
                            Label: $scope.M_CO.documents.forms[section][key][i].FormName,
                            IsSelected: false,
                            IsVisible: $rootScope.GroupOnlyPermissions[sectionToPermissionObjectMap[section]]['view'],
                            AttachmentId: $scope.M_CO.documents.forms[section][key][i].AttachmentId
                        };
                  if(printItem.AttachmentId && printItem.IsVisible){
                    $scope.M_CO.printDocumentTypeList[tabIndex].PrintItems.push(printItem);
                  }
                }
              });
            }
          });
        }

        $scope.F_CO.openDeleteConfirmationPopupForHoursLogged = function(SOHeaderIndex, SOHeaderId, HoursLoggedIndex, HoursLoggedId, gridName) {
            $scope.M_CO.deletedItemName = 'this item';
            $scope.M_CO.deletedItemGridName = gridName;
            $scope.M_CO.deletableHoursLogged_SOHeader_Index = SOHeaderIndex;
            $scope.M_CO.deletableHoursLogged_SOHeader_Id = SOHeaderId;
            $scope.M_CO.deletableHoursLogged_Index = HoursLoggedIndex;
            $scope.M_CO.deletableHoursLogged_Id = HoursLoggedId;
            var deletableElementId = 'SOHeader' + $scope.M_CO.deletableHoursLogged_SOHeader_Index + '_HoursLogged' + $scope.M_CO.deletableHoursLogged_Index;
            openDeleteConfirmationModalWindow(deletableElementId);
        }

        $scope.F_CO.openDeleteConfirmationPopupForReversePayment = function(invPayment, gridName, index) {
              $scope.M_CO.deletedItemName = 'this payment';
                $scope.M_CO.deletedItemGridName = gridName;
                $scope.M_CO.deletableInvPaymentRec = invPayment;
                var deletableElementId = 'checkout-modal #LIDeleteBtn_' + index;
                openDeleteConfirmationModalWindowforCheckOut(deletableElementId,index);
        }
        function openDeleteConfirmationModalWindowforCheckOut(deletableElementId,index) {
           angular.element(".bp-popup-delete-backdrop-hide" ).css("display", 'none');
             angular.element("#backDrop_Id_" + index).css("display", 'block');
           angular.element(".deleteConfiramtionPopupforCheckOut" ).css("visibility", 'hidden');
             angular.element(".deleteConfiramtionPopupforCheckOut").css("opacity", 0);
             angular.element("#deleteConfiramtionPopupforCheckOut_" + index).css("visibility", 'visible');
             angular.element("#deleteConfiramtionPopupforCheckOut_"+ index).css("opacity", 1);
        }

        function openDeleteConfirmationModalWindow(deletableElementId) {
            addDeletePopupBackdrop();
            var toppopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().top) + 20;
            var leftpopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().left) + 5;
            angular.element(".deleteConfiramtionPopup").css("left", leftpopupposition + 'px');
            angular.element(".deleteConfiramtionPopup").css("top", toppopupposition + 'px');
            setTimeout(function() {
                angular.element(".deleteConfiramtionPopup").css("visibility", 'visible');
                angular.element(".deleteConfiramtionPopup").css("opacity", 1);
            }, 100);
        }

        function openMoveLineItemConfirmationModalWindow(deletableElementId) {
            $scope.M_CO.showMoveLineItem = true;
            setTimeout(function() {
                var template = '<div class = "bp-modal-backdrop" ng-click = "F_CO.hideMoveLineItemModalWindowAction()"></div>';
                template = $compile(angular.element(template))($scope);
                angular.element("body").prepend(template);
            }, 100);
            var toppopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().top) + 20;
            var leftpopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().left) + 5;
            if (angular.element("body").width() < 993) {
                leftpopupposition = (angular.element("#" + deletableElementId + " .LIDeleteBtn ").offset().left) - 70;
            }
            angular.element(".moveLineItem-wrapper").css("left", leftpopupposition + 'px');
            angular.element(".moveLineItem-wrapper").css("top", toppopupposition + 'px');
        }

        function removeHoursLoggedItem() {
            var elementId = 'SOHeader' + $scope.M_CO.deletableHoursLogged_SOHeader_Index + '_HoursLogged' + $scope.M_CO.deletableHoursLogged_Index;
            var successJson = {
                'type': 'removeHoursLoggedItem',
                'SOHeaderIndex': $scope.M_CO.deletableHoursLogged_SOHeader_Index,
                'elementId': elementId
            };
            SOHeaderService.removeHoursLoggedItem($scope.M_CO.deletableHoursLogged_SOHeader_Id, $scope.M_CO.deletableHoursLogged_Id).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.openEmailPopUpForCustomerApproval = function(customerApprovalId,customerApprovalDetailJson) {
           var messageParams = {
                     Activity: 'Email',
                     CustomerName: $scope.M_CO.CustomerCardInfo.CustomerName,
                     Cust_Id: $scope.M_CO.coHeaderRec.CustomerId,
                     customerInfo: {
                         'Cust_Id': $scope.M_CO.coHeaderRec.CustomerId,
                         'Cust_Name': $scope.M_CO.CustomerCardInfo.CustomerName,
                         'Cust_Type': $scope.M_CO.CustomerCardInfo.CustomerType,
                         'Cust_HomeEmail': $scope.M_CO.CustomerCardInfo.CustomerEmail,
                         'Cust_PreferredEmail': $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail,
                         'Cust_WorkEmail': $scope.M_CO.CustomerCardInfo.CustomerWorkEmail,
                         'Cust_OtherEmail': $scope.M_CO.CustomerCardInfo.CustomerOtherEmail
                     },
                     customerApprovalId: customerApprovalId,
                     coHeaderId: $scope.M_CO.COHeaderId
                 };
                 loadState($state, 'CustomerOrder_V2.CustomerMessagingPopUp', {
                     messagingInfoParams: messageParams
                 });
        }
        $scope.F_CO.openEmailPopUp = function(activeInvId) {
            var messageParams = {
                Activity: 'Email',
                CustomerName: $scope.M_CO.CustomerCardInfo.CustomerName,
                Cust_Id: $scope.M_CO.coHeaderRec.CustomerId,
                customerInfo: {
                    'Cust_Id': $scope.M_CO.coHeaderRec.CustomerId,
                    'Cust_Name': $scope.M_CO.CustomerCardInfo.CustomerName,
                    'Cust_Type': $scope.M_CO.CustomerCardInfo.CustomerType,
                    'Cust_HomeEmail': $scope.M_CO.CustomerCardInfo.CustomerEmail,
                    'Cust_PreferredEmail': $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail,
                    'Cust_WorkEmail': $scope.M_CO.CustomerCardInfo.CustomerWorkEmail,
                    'Cust_OtherEmail': $scope.M_CO.CustomerCardInfo.CustomerOtherEmail
                },
                COInvoiceHeaderId: activeInvId,
                coHeaderId: $scope.M_CO.COHeaderId,
                COType: $scope.M_CO.coHeaderRec.COType,
            };
            loadState($state, 'CustomerOrder_V2.CustomerMessagingPopUp', {
                messagingInfoParams: messageParams
            });
        }
        $scope.F_CO.openMessagePopUp = function(activity, isFromPopup) {
            if (activity === 'sendEmail') {
                $scope.F_CO.emailServiceWorksheet();
                if ($scope.M_CO.CustomerCardInfo.CustomerPreferredEmail == '') {
                    if ($scope.M_CO.CustomerCardInfo.CustomerEmail != '') {
                        $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail = $scope.M_CO.CustomerCardInfo.CustomerEmail;
                    } else if ($scope.M_CO.CustomerCardInfo.CustomerWorkEmail != '') {
                        $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail = $scope.M_CO.CustomerCardInfo.CustomerWorkEmail;
                    } else if ($scope.M_CO.CustomerCardInfo.CustomerOtherEmail != '') {
                        $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail = $scope.M_CO.CustomerCardInfo.CustomerOtherEmail;
                    }
                }
                var activeInvId;
                if ($scope.CheckoutInfoModel.activeInvHeaderId) {
                    activeInvId = $scope.CheckoutInfoModel.activeInvHeaderId;
                } else {
                    activeInvId = $scope.M_CO.coHeaderRec.ActiveInvoiceId;
                }
                var messageParams = {
                    Activity: 'Email',
                    CustomerName: $scope.M_CO.CustomerCardInfo.CustomerName,
                    Cust_Id: $scope.M_CO.coHeaderRec.CustomerId,
                    customerInfo: {
                        'Cust_Id': $scope.M_CO.coHeaderRec.CustomerId,
                        'Cust_Name': $scope.M_CO.CustomerCardInfo.CustomerName,
                        'Cust_Type': $scope.M_CO.CustomerCardInfo.CustomerType,
                        'Cust_HomeEmail': $scope.M_CO.CustomerCardInfo.CustomerEmail,
                        'Cust_PreferredEmail': $scope.M_CO.CustomerCardInfo.CustomerPreferredEmail,
                        'Cust_WorkEmail': $scope.M_CO.CustomerCardInfo.CustomerWorkEmail,
                        'Cust_OtherEmail': $scope.M_CO.CustomerCardInfo.CustomerOtherEmail
                    },
                    COInvoiceHeaderId: activeInvId,
                    coHeaderId: $scope.M_CO.COHeaderId,
                    dealId: ($scope.M_CO.Deal.DealInfo ? $scope.M_CO.Deal.DealInfo.Id : null),
                    CustomerName: $scope.M_CO.CustomerCardInfo.CustomerName,
                    COType: $scope.M_CO.coHeaderRec.COType
                };
                var SelectedDocumentList = [];
                if (isFromPopup) {
                    for (var k = 0; k < $scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems.length; k++) {
                        if ($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].IsSelected) {
                            if ($scope.M_CO.CurrentActiveTabIndex == 1) {
                                SelectedDocumentList.push('Service Worksheet');
                                break;
                            } else if($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].Name === 'Documents') {
                              SelectedDocumentList.push('Attachment_Object-'+$scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].AttachmentId);
                            } else {
                                SelectedDocumentList.push($scope.M_CO.printDocumentTypeList[$scope.M_CO.CurrentActiveTabIndex].PrintItems[k].Label);
                            }
                        }
                    }
                }
                messageParams.SelectedDocuments = SelectedDocumentList;
                loadState($state, 'CustomerOrder_V2.CustomerMessagingPopUp', {
                    messagingInfoParams: messageParams
                });
            } else if (activity === 'sendText') {
                var messageParams = {
                    Activity: 'Text Message',
                    CustomerInfo: {
                        'Cust_Id': $scope.M_CO.coHeaderRec.CustomerId,
                        'Cust_Name': $scope.M_CO.CustomerCardInfo.CustomerName,
                        'Cust_Type': $scope.M_CO.CustomerCardInfo.CustomerType,
                        'Cust_PreferredPhone': $scope.M_CO.CustomerCardInfo.CustomerPreferredPhone,
                        'Cust_PreferredSMS': $scope.M_CO.CustomerCardInfo.CustomerPreferredSMS,
                        'Cust_HomeNumber': $scope.M_CO.CustomerCardInfo.CustomerHomeNumber,
                        'Cust_HomeNumberSMS': $scope.M_CO.CustomerCardInfo.CustomerHomeNumberSMS,
                        'Cust_FormattedHomeNumber': $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber,
                        'Cust_WorkNumber': $scope.M_CO.CustomerCardInfo.CustomerWorkNumber,
                        'Cust_WorkNumberSMS': $scope.M_CO.CustomerCardInfo.CustomerWorkNumberSMS,
                        'Cust_FormattedWorkNumber': $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber,
                        'Cust_OtherNumber': $scope.M_CO.CustomerCardInfo.CustomerOtherPhone,
                        'Cust_MobileNumberSMS': $scope.M_CO.CustomerCardInfo.CustomerMobileNumberSMS,
                        'Cust_FormattedOtherPhone': $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone
                    }
                };
            }
            loadState($state, 'CustomerOrder_V2.CustomerMessagingPopUp', {
                messagingInfoParams: messageParams
            });
        }
        $scope.F_CO.openClaimPopup = function(soHeaderIndex) {
          if($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ClaimStatus == 'Submitted' || $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ClaimStatus == 'Approved') {
            $scope.F_CO.openClaimResponsePopup(soHeaderIndex);
          } else {
            if (isBlankValue($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ProviderName)) {
                    Notification.error($translate.instant('Please_select_provider_first'));
                } else if ($scope.M_CO.SOHeaderList[soHeaderIndex].SOGridItems.length == 0) {
                    Notification.error($translate.instant('Please_add_line_items'));
                } else {
                    var ServiceJobClaimParams = {
                        soHeaderIndex: soHeaderIndex,
                        coType: $scope.M_CO.coHeaderRec.COType
                    };
                    loadState($state, 'CustomerOrder_V2.ServiceJobClaim', {
                        ServiceJobClaimParams: ServiceJobClaimParams
                    });
                }
          }

        }
        $scope.F_CO.openClaimResponsePopup = function(soHeaderIndex) {
            var ServiceJobClaimResponseParams = {
                soHeaderIndex: soHeaderIndex,
                soHeaderId: $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.Id,
                coType: $scope.M_CO.coHeaderRec.COType,
                soStatus: $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.WorkStatus
            };
            loadState($state, 'CustomerOrder_V2.ServiceJobClaimResponse', {
                ServiceJobClaimResponseParams: ServiceJobClaimResponseParams
            });
        }
        $scope.F_CO.addCustomerApprovalSection = function(sectionId, sectionName, soHeaderIndex) {
            $scope.M_CO.SOHeaderList[soHeaderIndex].addCustomerApproval = true;
            $scope.M_CO.SOHeaderList[soHeaderIndex].addNewCustomerApproval = true;

            $scope.F_CO.expandInnerSection(sectionId, sectionName);
        }
        $scope.F_CO.showHideItemInfo = function(SoHeaderIndex, SoKitHeaderIndex,event) {
            event.stopPropagation();
            $scope.M_CO.SOHeaderList[SoHeaderIndex].SOGridItems[SoKitHeaderIndex].ShowItemInfo = !$scope.M_CO.SOHeaderList[SoHeaderIndex].SOGridItems[SoKitHeaderIndex].ShowItemInfo;
        }
        $scope.F_CO.showHideKitItemInfo = function(SoHeaderIndex, SoKitHeaderIndex, SoLIIndex) {
            $scope.M_CO.SOHeaderList[SoHeaderIndex].SOGridItems[SoKitHeaderIndex].SOLIList[SoLIIndex].ShowItemInfo = !$scope.M_CO.SOHeaderList[SoHeaderIndex].SOGridItems[SoKitHeaderIndex].SOLIList[SoLIIndex].ShowItemInfo;
        }
        $scope.F_CO.showHideMerchandiseItemInfo = function(CoKitHeaderIndex, CoLIIndex) {
            $scope.M_CO.COKHList[CoKitHeaderIndex].COLIList[CoLIIndex].ShowItemInfo = !$scope.M_CO.COKHList[CoKitHeaderIndex].COLIList[CoLIIndex].ShowItemInfo;
        }
        $scope.F_CO.showHideDealMerchandiseItemInfo = function(CoKitHeaderIndex, CoLIIndex) {
            $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[CoKitHeaderIndex].COLIList[CoLIIndex].ShowItemInfo = !$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[CoKitHeaderIndex].COLIList[CoLIIndex].ShowItemInfo;
        }
        $scope.F_CO.calculateSpecialOrderValue = function(section, element, headerIndex, gridItemIndex, liIndex, isInventoryPart) {
            if (!isInventoryPart) {
                return;
            }
            var availablePart, actualAvailableParts, qtyNeeded, stockCommited, qtyOrder;
            if (section == 'ServiceJob' || section == 'ServiceJobKit') {
                availablePart = $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].AvailablePart;
                qtyNeeded = $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].QtyNeeded || 1;
                stockCommited = $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].StockCommited;
                qtyOrder = $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].QtyOrder;
                actualAvailableParts = $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].ActualAvailableParts;
            } else if (section == 'Merchandise') {
                availablePart = $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].AvaliablePartsQty;
                qtyNeeded = $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].Qty || 1;
                stockCommited = $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].QtyCommitted;
                qtyOrder = $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].QtyOrder;
                actualAvailableParts = $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].ActualAvailableParts;
            } else if (section == 'DealMerchandise') {
                availablePart = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].AvaliablePartsQty;
                qtyNeeded = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].Qty || 1;
                stockCommited = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].QtyCommitted;
                qtyOrder = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].QtyOrder;
                actualAvailableParts = $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].ActualAvailableParts;
            }
            if (element == 'QtyNeeded' && (isNaN(qtyNeeded) || qtyNeeded < 0)) { // If Qty Need value is -ve then set stockCommited & qtyOrder to 0 for inventry part
                stockCommited = 0;
                qtyOrder = 0;
            } else if (element == 'QtyNeeded') {
                if (qtyNeeded <= actualAvailableParts || (($scope.M_CO.coHeaderRec.COType === 'Cash Sale' || !$scope.M_CO.coHeaderRec.CustomerId) && $scope.M_CO.coHeaderRec.COType !== 'Internal Service')) { //Handling for Cash Sale Oversold Functionality in Or condition
                    stockCommited = qtyNeeded;
                    qtyOrder = 0;
                } else {
                    stockCommited = actualAvailableParts;
                    qtyOrder = qtyNeeded - actualAvailableParts;
                }
            } else if (element == 'StockCommited') {
                qtyOrder = qtyNeeded - stockCommited;
            }
            if (section == 'ServiceJob' || section == 'ServiceJobKit') {
                // In case of -ve qty we are not showing chevron and special order row, but if user again enters +ve qty then it should always be in collapsed mode
                setShowItemInfoFlag(section, element, headerIndex, gridItemIndex, liIndex, isInventoryPart, qtyNeeded);
                $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].StockCommited = stockCommited;
                $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].SOLIList[liIndex].QtyOrder = qtyOrder;
            } else if (section == 'Merchandise') {
                // In case of -ve qty we are not showing chevron and special order row, but if user again enters +ve qty then it should always be in collapsed mode
                setShowItemInfoFlag(section, element, headerIndex, gridItemIndex, liIndex, isInventoryPart, qtyNeeded);
                $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].QtyCommitted = stockCommited;
                $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].QtyOrder = qtyOrder;
            } else if (section == 'DealMerchandise') {
                $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].QtyCommitted = stockCommited;
                $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[headerIndex].COLIList[liIndex].QtyOrder = qtyOrder;
            }
        }
        /**
         * In case of -ve qty we are not showing chevron and special order row, but if user again enters +ve qty then it should always be in collapsed mode
         */
        function setShowItemInfoFlag(section, element, headerIndex, gridItemIndex, liIndex, isInventoryPart, qtyNeeded) {
            if (isNaN(qtyNeeded) || qtyNeeded < 0) {
                if (section == 'ServiceJob' || section == 'ServiceJobKit') {
                    if (!$scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].Id && $scope.M_CO.SOHeaderList[headerIndex].SOGridItems[gridItemIndex].ShowItemInfo) {
                        $scope.F_CO.showHideItemInfo(headerIndex, gridItemIndex)
                    }
                } else if (section == 'Merchandise') {
                    if (!$scope.M_CO.COKHList[headerIndex].Id && $scope.M_CO.COKHList[headerIndex].COLIList[liIndex].ShowItemInfo) {
                        $scope.F_CO.showHideMerchandiseItemInfo(headerIndex, liIndex)
                    }
                }
            }
        }
        $scope.F_CO.addUnitToDeal = function(actionName) {
            if ($scope.M_CO.Deal.UnitList == undefined) {
                $scope.M_CO.Deal.UnitList = [];
            }
            if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed') {
                return;
            }
            $scope.M_CO.isLoading = true;
            $scope.M_CO.DealItemObjJson = {
                Deal: null,
                ExteriorColour: null,
                Id: null,
                MakeModelDescription: null,
                MakeName: null,
                ModelName: null,
                SubModelName: null,
                Year: null
            }
            var successJson = {
                'type': 'saveTemporaryUnit'
            };
            if (actionName) {
                successJson.actionName = actionName;
            }
            DealService.saveTemporaryUnit($scope.M_CO.Deal.DealInfo.Id, angular.toJson($scope.M_CO.DealItemObjJson)).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.saveCustomerApproval = function(soHeaderIndex) {
            if (!$scope.M_CO.SOHeaderList[soHeaderIndex].customerApprovalType) {
                Notification.error($translate('Please_select_approval_method_errorMessage', {errorMessageForApproval : error}));
                return;
            }
            $scope.M_CO.SOHeaderList[soHeaderIndex].disableSave = true;
            var newCustomerApprovalData = {
                ApprovalType: $scope.M_CO.SOHeaderList[soHeaderIndex].customerApprovalType,
                IsApprovalObtained: true
            };
            CustomerApprovalService.saveCustomerApproval($scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.Id, JSON.stringify([newCustomerApprovalData])).then(function(response) {
                $scope.M_CO.SOHeaderList[soHeaderIndex].CustomerApprovalList.push.apply($scope.M_CO.SOHeaderList[soHeaderIndex].CustomerApprovalList, response)
                $scope.M_CO.SOHeaderList[soHeaderIndex].addNewCustomerApproval = false;
                $scope.M_CO.SOHeaderList[soHeaderIndex].disableSave = false;
                $scope.M_CO.SOHeaderList[soHeaderIndex].customerApprovalType = '';
            }, function(error) {
                $scope.M_CO.SOHeaderList[soHeaderIndex].disableSave = false;
                Notification.error($translate('Error_in_saving_customer_approval_data_errorMessage', {errorMessageForSavingApproval : error}));
            });
        }
        $scope.F_CO.DealFinance.getProviderList = function() {
            $scope.M_CO.DealFinance.showProviderList = true;
            document.getElementById('DealFinanceDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.DealFinance.hideProviderList = function() {
            $scope.M_CO.DealFinance.showProviderList = false;
        }
        $scope.F_CO.DealFinance.getFIProductList = function() {
            $scope.M_CO.DealFinance.showFIProductList = true;
            document.getElementById('FIDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.DealFinance.hideFIProductList = function() {
            $scope.M_CO.DealFinance.showFIProductListList = false;
        }
        $scope.F_CO.DealFinance.selectedCmpny = function(cmpny) {
            $scope.M_CO.Deal.DealFinanceObj.DealId = $scope.M_CO.Deal.DealInfo.Id;
            $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyName = cmpny.Name;
            $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyPhone = cmpny.Phone;
            $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyEmail = cmpny.Email;
            $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyAccountNumber = cmpny.AccountNumber;
            $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyId = cmpny.Id;
            $scope.M_CO.isShowDFSearchSection = false;
            $scope.F_CO.saveFinancingInfo({'changeFinanceCompany' : true});
        }

        function removeFIProductLineItem(dealItemId, fIProductId) {
            var successJson = {
                'type': 'removeFAndIProductLineItem'
            };
            DealService.removeFAndIProductLineItem(dealItemId, fIProductId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.replaceUnitFromUnitCard = function(index) {
            $scope.M_CO.isReplaceUnit = true;
            setTimeout(function() {
                $scope.F_CO.setFocusOnInput('autocompleteDealUnit' + index);
            }, 100);
        }

        $scope.M_CO.TradeIn.COUList = [];

        function getDataForTradeInsCouList() {
            $scope.M_CO.TradeIn.COUList = [];
            var isSelectedCou = false;
            if ($scope.M_CO.Deal.TradeInsList) {
                for (var i = 0; i < $scope.M_CO.COUList.length; i++) {
                    isSelectedCou = false;
                    for (var j = 0; j < $scope.M_CO.Deal.TradeInsList.length; j++) {
                        if ($scope.M_CO.COUList[i].Id === $scope.M_CO.Deal.TradeInsList[j].UnitId) {
                            isSelectedCou = true;
                            break;
                        }
                    }
                    if (!isSelectedCou) {
                        $scope.M_CO.TradeIn.COUList.push($scope.M_CO.COUList[i]);
                    }
                }
            }
        }
        $scope.F_CO.TradeIn.getCOUList = function(index) {
            $scope.M_CO.TradeIn.showCOUList = true;
            getDataForTradeInsCouList();
            document.getElementById('TradeInDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.TradeIn.hideCOUList = function() {
            $scope.M_CO.TradeIn.showCOUList = false;
        }
        $scope.F_CO.TradeIn.getAppraisalMethodList = function() {
            $scope.M_CO.TradeIn.showAppraisalMethodList = true;
            document.getElementById('appraisalMethodDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.TradeIn.hideAppraisalMethodList = function() {
            $scope.M_CO.TradeIn.showAppraisalMethodList = false;
        }
        $scope.F_CO.TradeIn.getAppraisalStatusList = function() {
            $scope.M_CO.TradeIn.showAppraisalStatusList = true;
            document.getElementById('appraisalStatusDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.TradeIn.hideAppraisalStatusList = function() {
            $scope.M_CO.TradeIn.showAppraisalStatusList = false;
        }
        $scope.F_CO.saveTradeInUnit = function(tradeInIndex) {
            var tradeInObj = {
                'Type': 'Trade In',
                'UnitId': $scope.M_CO.TradeIn.selectedUnitId,
                'Id': $scope.M_CO.Deal.TradeInsList[tradeInIndex].Id
            };
            var isGetUnitImageData = true;
            $scope.F_CO.updateTradeIn(tradeInObj, tradeInIndex, isGetUnitImageData);
            $scope.M_CO.TradeIn.IsCOUSelected = false;
            $scope.M_CO.isLoading = true;
            $scope.M_CO.TradeIn.isUnitSelected = true;
        }
        $scope.F_CO.updateTradeIn = function(tradeInObj, tradeInIndex, isGetUnitImageData, isStopDataBind) {
            var successJson = {
                'type': 'updateTradeIn',
                'tradeInIndex': tradeInIndex,
                'isGetUnitImageData': isGetUnitImageData,
                'isStopDataBind': isStopDataBind
            };
            DealService.updateTradeIn($scope.M_CO.Deal.DealInfo.Id, angular.toJson(tradeInObj)).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.addTradeInToDeal = function() {
            var tradeInObj = {
                'Type': 'Trade In'
            };
            $scope.F_CO.updateTradeIn(tradeInObj);
            $scope.M_CO.isLoading = true;
        }
        $scope.F_CO.TradeIn.selectedUnit = function(selectedUnit) {
            $scope.M_CO.TradeIn.selectedUnitId = selectedUnit.Id
            $scope.M_CO.TradeIn.selectedUnitName = selectedUnit.FormattedName;
            $scope.M_CO.TradeIn.isUnitSelected = false;
        }
        $scope.F_CO.TradeIn.replaceTradeInUnit = function(index) {
            $scope.M_CO.TradeIn.IsCOUSelected = true;
            setTimeout(function() {
                angular.element('#' + 'TradeIn' + index).focus();
            }, 100);
        }
        $scope.F_CO.TradeIn.setAppraisalMethod = function(index, tradeIn_Index) {
            $scope.M_CO.Deal.TradeInsList[tradeIn_Index].AppraisalMethod = $scope.M_CO.TradeIn.AppraisalMethodList[index];
            saveTradeInfo(tradeIn_Index);
        }
        $scope.F_CO.TradeIn.setAppraisalStatus = function(index, tradeIn_Index) {
            $scope.M_CO.Deal.TradeInsList[tradeIn_Index].AppraisalStatus = $scope.M_CO.TradeIn.AppraisalStatusList[index];
            saveTradeInfo(tradeIn_Index);
        }
        $scope.F_CO.TradeIn.setAppraisalNotes = function(value, tradeIn_Index) {
            $scope.M_CO.Deal.TradeInsList[tradeIn_Index].AppraisalNotes = value;
            saveTradeInfo(tradeIn_Index);
        }
        $scope.F_CO.TradeIn.setApprovedBy = function(index, tradeIn_Index) {
            $scope.M_CO.Deal.TradeInsList[tradeIn_Index].ApprovedBy = $scope.M_CO.TradeIn.ApprovedList[index].id;
            saveTradeInfo(tradeIn_Index);
        }
        $scope.F_CO.TradeIn.setAgreedValue = function(value, tradeIn_Index) {
            $scope.M_CO.Deal.TradeInsList[tradeIn_Index].AgreedValue = value;
          if($scope.M_CO.TradeIn.AgreedValueCopy != value && !$scope.M_CO.Deal.TradeInsList[tradeIn_Index].IsSctockedIn) {
            if($scope.M_CO.coHeaderRec.IsTaxIncludedPricing) {
              $scope.M_CO.Deal.TradeInsList[tradeIn_Index].ActualCashValue = parseFloat((value / (1 + ($scope.M_CO.Deal.TradeInsList[tradeIn_Index].SalesTaxPercentage / 100))).toFixed(2));
            } else {
              $scope.M_CO.Deal.TradeInsList[tradeIn_Index].ActualCashValue = value;
            }
            $scope.M_CO.TradeIn.AgreedValueCopy = 0;
          }
            saveTradeInfo(tradeIn_Index, true);
        }
        $scope.F_CO.TradeIn.copyCurrentAgreedValue = function(tradeIn_Index) {
          $scope.M_CO.TradeIn.AgreedValueCopy = $scope.M_CO.Deal.TradeInsList[tradeIn_Index].AgreedValue;
        }
        $scope.F_CO.TradeIn.setActualCashValue = function(value, tradeIn_Index) {
          $scope.M_CO.Deal.TradeInsList[tradeIn_Index].ActualCashValue = value;
            saveTradeInfo(tradeIn_Index, true);
        }
$scope.F_CO.TradeIn.openStockInCOUConfirmationPopup = function(tradeIn_Index, event) {
            $scope.M_CO.TradeIn.stockInCOUTradeInIndex = tradeIn_Index;
            $scope.F_CO.openConfirmationDialog('StockInCOU', false);
            if(event) {
              event.stopPropagation();
            }
        }
        $scope.F_CO.TradeIn.stockInCOU = function() {
          var successJson = {
                    'type': 'stockInCOU',
                    'callback': getUnitDealDetails,
                    'callbackParam': {
                        'gridName': null
                    }
                };
                $scope.M_CO.isLoading = true;
                DealService.stockInCOU($scope.M_CO.Deal.TradeInsList[$scope.M_CO.TradeIn.stockInCOUTradeInIndex].Id, $scope.M_CO.Deal.TradeInsList[$scope.M_CO.TradeIn.stockInCOUTradeInIndex].UnitId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.TradeIn.isAnyCOUStocked = function() {
          var index = _.findIndex($scope.M_CO.Deal.TradeInsList, {
                'IsSctockedIn': true
            });
            if (index > -1) {
              return true;
            }
            return false;
        }
        $scope.F_CO.isSingleSKUPresent = function() {
            if ($scope.M_CO.Deal.UnitList != undefined) {
              var skuList = _.filter($scope.M_CO.Deal.UnitList, function(item) {
                    return item.DealItemObj.UnitId !== null;
                });
                if(skuList.length == 1) {
                  return true;
                }
            }
            return false;
        }
        $scope.F_CO.TradeIn.getApprovedList = function() {
            $scope.M_CO.TradeIn.ApprovedList = [];
            $scope.M_CO.TradeIn.ApprovedList.length = 0;
            $scope.M_CO.TradeIn.ApprovedList = $scope.M_CO.Deal.UserList;
            var obj = {
                name: 'Pending approval',
                id: null
            }
            var found = false;
            for (var i = 0; i < $scope.M_CO.TradeIn.ApprovedList.length; i++) {
                if ($scope.M_CO.TradeIn.ApprovedList[i].id == null) {
                    found = true;
                    break;
                }
            }
            if (!(found)) {
                $scope.M_CO.TradeIn.ApprovedList.push(obj);
            }
            $scope.M_CO.TradeIn.showApprovedList = true;
            document.getElementById('approvedByDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.TradeIn.hideApprovedList = function() {
            $scope.M_CO.TradeIn.showApprovedList = false;
        }

        function saveTradeInfo(index, isStopDataBind) {
            if ($scope.M_CO.Deal.TradeInsList[index].AgreedValue == undefined || $scope.M_CO.Deal.TradeInsList[index].AgreedValue == null || $scope.M_CO.Deal.TradeInsList[index].AgreedValue == '') {
                $scope.M_CO.Deal.TradeInsList[index].AgreedValue = 0.00;
            }
            if ($scope.M_CO.Deal.TradeInsList[index].ActualCashValue == undefined || $scope.M_CO.Deal.TradeInsList[index].ActualCashValue == null || $scope.M_CO.Deal.TradeInsList[index].ActualCashValue == '') {
                $scope.M_CO.Deal.TradeInsList[index].ActualCashValue = 0.00;
            }
            $scope.F_CO.updateTradeIn($scope.M_CO.Deal.TradeInsList[index], index, undefined, isStopDataBind);
        }
        $scope.M_CO.TradeIn.keyBoardavigation = function(event, dataList, dropDownName, tradeIn_Index) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_CO.TradeIn[indexName] == undefined || isNaN($scope.M_CO.TradeIn[indexName])) {
                $scope.M_CO.TradeIn[indexName] = -1;
            }
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_CO.TradeIn[indexName]) {
                    $scope.M_CO.TradeIn[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.TradeIn[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_CO.TradeIn[indexName] > 0) {
                    $scope.M_CO.TradeIn[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.TradeIn[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13) {
                if (dropDownName == 'appraisalMethod') {
                    $scope.F_CO.TradeIn.setAppraisalMethod($scope.M_CO.TradeIn[indexName], tradeIn_Index);
                    $scope.F_CO.TradeIn.hideAppraisalMethodList();
                } else if (dropDownName == 'appraisalStatus') {
                    $scope.F_CO.TradeIn.setAppraisalStatus($scope.M_CO.TradeIn[indexName], tradeIn_Index);
                    $scope.F_CO.TradeIn.hideAppraisalStatusList();
                } else if (dropDownName == 'approvedBy') {
                    $scope.F_CO.TradeIn.setApprovedBy($scope.M_CO.TradeIn[indexName], tradeIn_Index);
                    $scope.F_CO.TradeIn.hideApprovedList();
                } else if (dropDownName == 'TradeIn') {
                    $scope.F_CO.TradeIn.selectedUnit(dataList[$scope.M_CO.TradeIn[indexName]]);
                    $scope.F_CO.TradeIn.hideCOUList();
                }
                $scope.M_CO.TradeIn[indexName] = -1;
            }
        }
        $scope.M_CO.DealFinance.keyBoardavigation = function(event, dataList, dropDownName, df_Index) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_CO.DealFinance.FinanceCompanyList[indexName] == undefined || isNaN($scope.M_CO.DealFinance.FinanceCompanyList[indexName])) {
                $scope.M_CO.DealFinance.FinanceCompanyList[indexName] = -1;
            }
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_CO.DealFinance.FinanceCompanyList[indexName]) {
                    $scope.M_CO.DealFinance.FinanceCompanyList[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.DealFinance.FinanceCompanyList[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_CO.DealFinance.FinanceCompanyList[indexName] > 0) {
                    $scope.M_CO.DealFinance.FinanceCompanyList[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.DealFinance.FinanceCompanyList[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13) {
                if (dropDownName == 'DealFinance') {
                    $scope.F_CO.TradeIn.selectedUnit(dataList[$scope.M_CO.DealFinance.FinanceCompanyList[indexName]]);
                    $scope.F_CO.TradeIn.hideCOUList();
                } else if (dropDownName == 'FIProduct') {}
                $scope.M_CO.DealFinance.FinanceCompanyList[indexName] = -1;
            }
        }
        $scope.F_CO.TradeIn.removeTradeItem = function() {
            var successJson = {
                'type': 'removeTradeItem'
            };
            $scope.M_CO.isLoading = true;
            DealService.removeUnitFromDeal($scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.Deal.TradeInsList[$scope.M_CO.TradeIn.removeIndex].Id).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.isMultipleUnitsAddedOnDeal = function() {
            if ($scope.M_CO.Deal.UnitList != undefined) {
                if ($scope.M_CO.Deal.UnitList.length > 1) {
                    return true;
                }
            }
            return false;
        }
        $scope.F_CO.isSingleStockUnitAddedOnDeal = function() {
            if ($scope.M_CO.Deal.UnitList != undefined && $scope.M_CO.currentDealUnitRemoveIndex != undefined) {
                if ($scope.M_CO.Deal.UnitList.length == 1 && $scope.M_CO.Deal.UnitList[$scope.M_CO.currentDealUnitRemoveIndex].DealItemObj.UnitId != null) {
                    return true;
                }
            }
            return false;
        }
        $scope.F_CO.isSingleTempUnitAddedOnDeal = function() {
            if ($scope.M_CO.Deal.UnitList && $scope.M_CO.currentDealUnitRemoveIndex != undefined) {
                if ($scope.M_CO.Deal.UnitList.length == 1 && !$scope.M_CO.Deal.UnitList[$scope.M_CO.currentDealUnitRemoveIndex].DealItemObj.UnitId) {
                    return true;
                }
            }
            return false;
        }
        $scope.F_CO.replaceUnitFromPopup = function() {
            var index = $scope.M_CO.currentDealUnitRemoveIndex;
            $scope.F_CO.closeRemoveUnitFromDealModal();
            $scope.M_CO.isReplaceUnit = true;
            setTimeout(function() {
                $scope.F_CO.expandInner2Section('Deal_DU' + index + '_InfoSectionId', 'Deal_DU' + index + '_Info');
                $scope.F_CO.expandInnerSection('Deal_DU' + index + '_SectionId', 'Deal_DU' + index);
                $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                $scope.F_CO.setFocusOnInput('autocompleteDealUnit' + index);
            }, 100);
        }
        $scope.F_CO.openRemoveUnitModalFromDeal = function(index,event) {
            if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed') {
                return;
            }
            $scope.M_CO.currentDealUnitRemoveIndex = index;
            angular.element('#RemoveDealUnitPopup').modal({
                backdrop: 'static',
                keyboard: false
            });
            angular.element('#RemoveDealUnitPopup').show();
            angular.element("body").addClass("modal-open");
            if(event) {
              event.stopPropagation();
            }
        }
        $scope.F_CO.closeRemoveUnitFromDealModal = function() {
            $scope.M_CO.currentDealUnitRemoveIndex = undefined;
            angular.element('#RemoveDealUnitPopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
        }
        angular.element(document).on("click", "#RemoveDealUnitPopup .modal-backdrop", function() {
            $scope.F_CO.closeRemoveUnitFromDealModal();
        });
        $scope.F_CO.removeUnitFromDeal = function() {
            var dealId = $scope.M_CO.Deal.DealInfo.Id;
            var dealItemId = $scope.M_CO.Deal.UnitList[$scope.M_CO.currentDealUnitRemoveIndex].DealItemObj.Id;
            var UnitId = $scope.M_CO.Deal.UnitList[$scope.M_CO.currentDealUnitRemoveIndex].DealItemObj.UnitId;
            var unitListLength = $scope.M_CO.Deal.UnitList.length;
            $scope.M_CO.isLoading = true;
            if (unitListLength === 1 && !UnitId) {
                $scope.F_CO.closeRemoveUnitFromDealModal();
                $scope.M_CO.isLoading = false;
                return;
            }
            var successJson = {
                'type': 'removeUnitFromDeal',
                'unitListLength': unitListLength,
                'UnitId': UnitId
            };
            DealService.removeUnitFromDeal(dealId, dealItemId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.openTradeInConfirmationPopup = function(tradeIn_Index, event) {
            $scope.M_CO.TradeIn.removeIndex = tradeIn_Index;
            $scope.M_CO.TradeIn.removeItem = $scope.M_CO.Deal.TradeInsList[tradeIn_Index].UnitNumber;
            $scope.F_CO.openConfirmationDialog('TradeInConfirmationDialog', false);
            if(event) {
              event.stopPropagation();
            }
        }

        function showTooltip(containerName) {
            angular.element('[role ="tooltip"]').hide();
            setTimeout(function() {
                angular.element('[data-toggle="tooltip"]').tooltip({
                    placement: 'top',
                    container: containerName
                });
            }, 500);
        }
        $scope.F_CO.resolveFulfillmentData = function(resolvedFulFillment, UnitSelected) {
            $scope.M_CO.Deal.resolvedFulFillment.ChargeMethod = resolvedFulFillment.ChargeMethod;
            if (UnitSelected != undefined) {
                resolvedFulFillment.UnitId = UnitSelected.Id;
            }
            $scope.M_CO.Deal.resolvedFulFillment.UnitId = resolvedFulFillment.UnitId;
            var successJson = {
                'type': 'resolveFulfillment',
                'callback': $scope.F_CO.updateDealSummaryTotals
            };
            $scope.M_CO.isLoading = true;
            DealService.resolveFulfillment(resolvedFulFillment.DealId, angular.toJson(resolvedFulFillment), $scope.M_CO.Deal.resolvedFulFillment.ChargeMethod, $scope.M_CO.Deal.resolvedFulFillment.UnitId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.hideUnresolvedFullfilmentPopUp = function() {
            angular.element('#unresolvedFulfillmentPopup').modal('hide');
            angular.element("body").removeClass("modal-open");
            angular.element("body").css("padding", "0px");
            $scope.M_CO.isLoading = false;
        }
        angular.element(document).on("click", "#unresolvedFulfillmentPopup .modal-backdrop", function() {
            $scope.F_CO.hideUnresolvedFullfilmentPopUp();
        });
        $scope.F_CO.keyBoardavigation = function(event, dataList, dropDownName) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName;
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_CO.unreslovedList[indexName] == undefined || isNaN($scope.M_CO.unreslovedList[indexName])) {
                $scope.M_CO.unreslovedList[indexName] = -1;
            }
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_CO.unreslovedList[indexName]) {
                    $scope.M_CO.unreslovedList[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.unreslovedList[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_CO.unreslovedList[indexName] > 0) {
                    $scope.M_CO.unreslovedList[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.unreslovedList[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13) {
                if (dropDownName == 'autocompleteScrollDivSkuList') {
                    $scope.F_CO.selectResolveUnit(dataList[$scope.M_CO.unreslovedList[indexName]]);
                    $scope.F_CO.hideresolveFulfillmentDropdown();
                } else if (dropDownName == 'autocompleteScrollDivInvoiceList') {
                    $scope.F_CO.selectchargedMethod(dataList[$scope.M_CO.unreslovedList[indexName]]);
                    $scope.F_CO.hideresolveFulfillmentDropdown();
                }
                $scope.M_CO.unreslovedList[indexName] = -1;
            }
        }
        $scope.F_CO.showresolveFulfillmentDropdown = function(showVal) {
            $scope.M_CO.setBotrderOnSpan = showVal;
        }
        $scope.F_CO.DealFinance.isStatusDisabled = function(status) {
            if (!isBlankValue($scope.M_CO.Deal.DealInfo)) {
                if (status == 'Submitted' && $scope.M_CO.Deal.DealInfo.DealStatus != 'Quotation' && $scope.M_CO.Deal.DealFinanceObj.Id != null && $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyId != null && ($scope.M_CO.Deal.DealFinanceObj.Status == 'Quotation' || $scope.M_CO.Deal.DealFinanceObj.Status == 'Submitted')) {
                    return false;
                } else if (status == 'Approved' && $scope.M_CO.Deal.DealInfo.DealStatus != 'Quotation' && $scope.M_CO.Deal.DealFinanceObj.Id != null
                    && $scope.M_CO.Deal.DealFinanceObj.FinanceCompanyId != null && $scope.M_CO.Deal.DealFinanceObj.Status == 'Submitted'
                   && !$scope.F_CO.isOrderedUnitExistsInDeal() && !$scope.M_CO.isTradeInFinanceCompanyNotSelected()) {
                    return false;
                } else if (status == 'Quotation' && $scope.M_CO.Deal.DealFinanceObj.Status == 'Quotation') {
                    return false;
                }
            }
            return true;
        }
        $scope.F_CO.DealFinance.ChangeDFStatus = function(status) {
            if (!$scope.F_CO.DealFinance.isStatusDisabled(status)) {
                $scope.M_CO.DealFinance.Status = status;
            }
        }
        $scope.F_CO.displayServiceJobAction = function(action, soHeader, SoHeaderIndex) {
            if (action == 'Log technician time' && !soHeader.HoursLoggedList.length) {
                return true;
            } else if (action == 'Add notes to customer' && !soHeader.SOInfo.ShowNotesForCustomer && !soHeader.SOInfo.NotesForCustomer) {
                return true;
            } else if (action == 'Add internal notes') {
                return true;
            } else if (action == 'Get customer approval' && !(soHeader.CustomerApprovalList.length || soHeader.addCustomerApproval) && soHeader.SOInfo.TransactionType === 'Customer') {
                return true;
            } else if (action == 'Add attachment' && !soHeader.AttachmentList.length) {
                return true;
            } else if(action == 'Submit claim' && soHeader.SOInfo.TransactionType == 'Third-Party' && soHeader.SOInfo.ClaimStatus == 'Unsubmitted') {
              return true;
            } else if(action == 'Claim response' && soHeader.SOInfo.TransactionType == 'Third-Party' && soHeader.SOInfo.ClaimStatus == 'Submitted') {
              return true;
            } else if(action == 'View claim' && soHeader.SOInfo.TransactionType == 'Third-Party' && soHeader.SOInfo.ClaimStatus == 'Approved') {
              return true;
            }
            /**
             * Checkout related permissions to display finalize job on Deal service & Internal Service;
             * Source sections related permissions are already applied on Complete sub section
             */
            else if (action == 'Finalize Job' && $rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify']) {
                if (soHeader.SOInfo.TransactionType == 'Third-Party' && soHeader.SOInfo.WorkStatus == 'Complete' && soHeader.SOInfo.ClaimStatus == 'Approved' && (!soHeader.DeductibleItem.DeductibleId || (soHeader.DeductibleItem.DeductibleStatus && soHeader.DeductibleItem.DeductibleStatus === 'Paid'))) {
                    return true;
                } else if (($scope.M_CO.coHeaderRec.COType == 'Internal Service' || (soHeader.SOInfo.TransactionType == 'Internal') || (soHeader.SOInfo.DealId != null)) && soHeader.SOInfo.WorkStatus == 'Complete') {
                    return true;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        $scope.F_CO.isSelectUnitTextVisible = function(soHeaderIndexVal) {
            if (soHeaderIndexVal != undefined) {
                if ((!$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.UnitName && $scope.M_CO.expandedInnerSectionName != 'ServiceJob' + soHeaderIndexVal + '_Details') && $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.DealId != null) {
                    return true;
                } else if (((!$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.UnitName && $scope.M_CO.expandedInnerSectionName != 'ServiceJob' + soHeaderIndexVal + '_Details') || (!$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.ManualConcern.length && !$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.KitHeaderConcern.length)) && $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.DealId == null) {
                    return true;
                }
                return;
            }
        }
        $scope.F_CO.isServiceJobRequired = function(soHeaderIndexVal){
          if (soHeaderIndexVal != undefined) {
                if ($scope.M_CO.expandedSectionName != 'ServiceJob' + soHeaderIndexVal && $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.DealId != null && $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.WorkStatus == 'Complete') {
                    return true;
                } else if (((!$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.UnitName  ) || (!$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.ManualConcern.length && !$scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.KitHeaderConcern.length) || $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOGridItems.length == 0) && $scope.M_CO.SOHeaderList[soHeaderIndexVal].SOInfo.DealId == null && $scope.M_CO.expandedSectionName != 'ServiceJob' + soHeaderIndexVal ) {
                    return true;
                }
                return;
            }
        }
        $scope.F_CO.serviceJobActionToBePerformed = function(action, soHeader, SoHeaderIndex) {
            if (action == 'Log technician time' && soHeader.HoursLoggedList.length == 0) {
                $scope.F_CO.openAddLogTechnicianTimePopUp(soHeader.SOInfo.Id, SoHeaderIndex);
            } else if (action == 'Add notes to customer' && !soHeader.SOInfo.ShowNotesForCustomer && !soHeader.SOInfo.NotesForCustomer) {
                soHeader.SOInfo.ShowNotesForCustomer = true;
                $scope.F_CO.expandInnerSection('ServiceJob' + SoHeaderIndex + '_NotesForCustomerSectionId', 'ServiceJob' + SoHeaderIndex + '_NotesForCustomer');
            } else if (action == 'Add internal notes') {
                return true;
            } else if (action == 'Get customer approval' && !(soHeader.CustomerApprovalList.length || soHeader.addCustomerApproval)) {
                $scope.F_CO.openCustomerApprovalModal(SoHeaderIndex);
            } else if (action == 'Add attachment' && soHeader.AttachmentList.length == 0) {
                $scope.F_CO.serviceJobopenAttachment(SoHeaderIndex);
            } else if (action == 'Finalize Job') {
                if (soHeader.SOInfo.TransactionType == 'Third-Party' && soHeader.SOInfo.WorkStatus == 'Complete' && soHeader.SOInfo.ClaimStatus == 'Approved') {
                    $scope.M_CO.FinalizeType = 'Third Party Claim';
                } else if (($scope.M_CO.coHeaderRec.COType == 'Internal Service' || (soHeader.SOInfo.TransactionType == 'Internal') || (soHeader.SOInfo.DealId != null)) && soHeader.SOInfo.WorkStatus == 'Complete') {
                    $scope.M_CO.FinalizeType = 'Internal Job';
                }
                $scope.F_CO.finalizeJobPopUp(SoHeaderIndex);
            }
            else if (action == 'Submit claim' || action == 'Claim response'  || action == 'View claim' ) {
                $scope.F_CO.openClaimPopup(SoHeaderIndex);
            }
        }

        $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap = [];
        function getServiceJobNameToSOHeaderIndexMap() {
          $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap = [];
          for(var i=0 ; i < $scope.M_CO.SOHeaderList.length ; i++) {
        var obj = {
            index: i,
            name: $scope.M_CO.SOHeaderList[i].SOInfo.Name,
            soHeaderId:$scope.M_CO.SOHeaderList[i].SOInfo.Id,
            isSelected:false
        }
        $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap.push(obj);
          }
        }

        $scope.F_CO.openCustomerApprovalModal = function(SoHeaderIndex) {
            $scope.M_CO.CustomerApproval.saveSoHeaderIndex = SoHeaderIndex;
            getServiceJobNameToSOHeaderIndexMap();
          var defer = $q.defer();
          SOHeaderService.getServiceWorksheetPrintDetail($scope.M_CO.COHeaderId).then(function(result) {
            $scope.M_CO.CustomerApproval.UnitList = result;
            for (var i = 0; i < $scope.M_CO.CustomerApproval.UnitList.length; i++) {
                  $scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList = _.filter($scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList, function(SOInfo){
                      return (SOInfo.TransactionType == 'Customer' && SOInfo.WorkStatus != 'Invoiced');
                  });
                }
            var noOfServiceJobsForCustomerApproval = 0;
            $scope.M_CO.CustomerApproval.isNoUnitSelectedForApproval = false;
            for (var i = 0; i < $scope.M_CO.CustomerApproval.UnitList.length; i++) {
              if($scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList.length) {
                noOfServiceJobsForCustomerApproval += $scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList.length;
              }
                }
            if(noOfServiceJobsForCustomerApproval == 1) {
              $scope.F_CO.getCustomerApprovalForSelectedDocument();
            } else {
              if(noOfServiceJobsForCustomerApproval == 0) {
                  $scope.M_CO.CustomerApproval.isNoUnitSelectedForApproval = true;
                }
              angular.element("#approvalmodal")[0].scrollTop = 0;
              angular.element('#approvalmodal').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                    angular.element('#approvalmodal').show();
            }
            defer.resolve();
              }, function(error) {
                  handleErrorAndExecption(error);
                  defer.reject($translate.instant('GENERIC_ERROR'));
              });
        }

        function getCustomerApprovalData(refreshDta,isFromServiceWorksheet) {
          if(refreshDta) {
            SOHeaderService.getCustomerApprovalData($scope.M_CO.COHeaderId).then(function(result) {
              $scope.M_CO.CustomerApproval.soIdToCustomerApprovalListMap = result;
              setCustomerApprovalList(result, isFromServiceWorksheet);
          }, function(errorSearchResult) {});
          } else {
            setCustomerApprovalList($scope.M_CO.CustomerApproval.soIdToCustomerApprovalListMap);
          }


        }
        function setCustomerApprovalList(soIdToCustomerApprovalListMap, isFromServiceWorksheet) {
          if(soIdToCustomerApprovalListMap) {
            for(var i=0 ; i < $scope.M_CO.SOHeaderList.length ; i++) {
              Object.keys(soIdToCustomerApprovalListMap).forEach(function(key) {
                if($scope.M_CO.SOHeaderList[i].SOInfo.Id == key) {
                  $scope.M_CO.SOHeaderList[i].CustomerApprovalList = soIdToCustomerApprovalListMap[key];
                  }
              });
            }
          }
          if(isFromServiceWorksheet) {
            $scope.M_CO.isLoading = false;
                var  isUnitSelectedForCustomerApproval = false;
                for(var i = 0; i < $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap.length; i++) {
                  if($scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].isSelected && $scope.M_CO.CustomerApproval.saveSoHeaderIndex == $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].index) {
                    isUnitSelectedForCustomerApproval = true;
                    break;
                  }
                }
                if(isUnitSelectedForCustomerApproval) {
                  $scope.F_CO.expandInnerSection('ServiceJob'+ $scope.M_CO.CustomerApproval.saveSoHeaderIndex +'_CustomerApprovalSectionId', 'ServiceJob'+ $scope.M_CO.CustomerApproval.saveSoHeaderIndex +'_CustomerApprovalSection');
                    $scope.M_CO.CustomerApproval.highlightLastAddedCAIndex = $scope.M_CO.SOHeaderList[$scope.M_CO.CustomerApproval.saveSoHeaderIndex].CustomerApprovalList.length - 1;
                    setTimeout(function() {
                      $scope.$evalAsync(function() {
                    $scope.M_CO.CustomerApproval.highlightLastAddedCAIndex = -1;
                        });
                    },1500);
                } else {
                  $scope.F_CO.collapseSection();
                  var firstSelectedIndex = 0;
                  for(var i = 0; i < $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap.length; i++) {
                      if($scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].isSelected ) {
                        firstSelectedIndex = $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].index;
                        break;
                      }
                    }

                  setTimeout(function() {
                    $scope.F_CO.expandedSection('ServiceJob' + firstSelectedIndex + '_SectionId', 'ServiceJob' + firstSelectedIndex);
                      $scope.F_CO.expandInnerSection('ServiceJob'+ firstSelectedIndex +'_CustomerApprovalSectionId', 'ServiceJob'+ firstSelectedIndex +'_CustomerApprovalSection');
                      setTimeout(function() {
                        $scope.$evalAsync(function() {
                          $scope.M_CO.CustomerApproval.highlightLastAddedCAIndex = $scope.M_CO.SOHeaderList[firstSelectedIndex].CustomerApprovalList.length - 1;
                            });
                        setTimeout(function() {
                          $scope.$evalAsync(function() {
                            $scope.M_CO.CustomerApproval.highlightLastAddedCAIndex = -1;
                                });
                            },3000);
                      },1500);
                  },500);
                }
          }
        }
        $(window).bind('storage', function (e) {
          if(localStorage.getItem("approval") === 'Approved') {
            $scope.M_CO.isLoading = true;
            getCustomerApprovalData(true,true);
          }
        });

        $scope.F_CO.getCustomerApprovalForSelectedDocument = function() {
           var isUnitSelected;
             for (var i = 0; i < $scope.M_CO.CustomerApproval.UnitList.length; i++) {
                 isUnitSelected = false;
                 for (var k = 0; k < $scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList.length; k++) {
                     if ($scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList[k].IsSOHeaderSelected) {
                         isUnitSelected = true;
                     }
                 }
                 $scope.M_CO.CustomerApproval.UnitList[i].IsUnitSelected = isUnitSelected;
             }
            localStorage.setItem("approval", "Pending");
            setCustomerApprovalServiceOrderNameToIndex($scope.M_CO.CustomerApproval.UnitList);
          var saveWorkseetSelectionJson = JSON.stringify($scope.M_CO.CustomerApproval.UnitList);
            SOHeaderService.saveWorkseetSelectionJson($scope.M_CO.COHeaderId, saveWorkseetSelectionJson).then(function(result) {
              var pageName = $scope.M_CO.printPageNameToPageURLMap['Service Worksheet'];
              pageName = pageName + $scope.M_CO.COHeaderId + '&isForCustomerApproval=true';
              //location.replace(pageName);
              window.open(pageName, '_blank');
              $scope.F_CO.CloseCustomerApprovalPopup();
            }, function(errorSearchResult) {});
        }
        function setCustomerApprovalServiceOrderNameToIndex(customerApprovalUnitList) {
          for(var i = 0; i < $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap.length; i++) {
            for (var j = 0; j < $scope.M_CO.CustomerApproval.UnitList.length; j++) {
              for (var k = 0; k < $scope.M_CO.CustomerApproval.UnitList[j].SOInfoWrapperList.length; k++) {
                        if ($scope.M_CO.CustomerApproval.UnitList[j].SOInfoWrapperList[k].IsSOHeaderSelected && $scope.M_CO.CustomerApproval.UnitList[j].SOInfoWrapperList[k].SOHeaderId === $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].soHeaderId) {
                          $scope.M_CO.CustomerApproval.serviceJobNameToSOHeaderIndexMap[i].isSelected = true;
                        }
                    }
            }
          }
        }

        $scope.F_CO.getCustomerApprovalHistoryForSelectedSO = function(customerApprovalId) {
          var pageName = $scope.M_CO.printPageNameToPageURLMap['Service Worksheet'];
            pageName = pageName + $scope.M_CO.COHeaderId + '&customerApprovalId=' + customerApprovalId+'&isForCustomerApproval=true';
            window.open(pageName, '_blank');
        }

        angular.element(document).on("click", "#approvalmodal .modal-backdrop", function() {
            $scope.F_CO.CloseCustomerApprovalPopup();
        })
        $scope.F_CO.CloseCustomerApprovalPopup = function(){
          angular.element('#approvalmodal').modal('hide');
        }
        $scope.F_CO.toggleSelectedServiceJobForCustomerApproval = function ($index,soHeaderId) {
          for (var i = 0; i < $scope.M_CO.CustomerApproval.UnitList.length; i++) {
                for (var k = 0; k < $scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList.length; k++) {
                    if ($scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList[k].SOHeaderId == soHeaderId) {
                      $scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList[k].IsSOHeaderSelected = !($scope.M_CO.CustomerApproval.UnitList[i].SOInfoWrapperList[k].IsSOHeaderSelected);
                    }
                }
            }
        }
        $scope.F_CO.openConfirmationDialog = function(id, isAlert, sectionName, sectionId, event, partNotInSystemList) {
            $scope.M_CO.ConfirmationModel = {
                id: id,
                isAlert: isAlert || false,
                payload: {}
            };
            switch (id) {
              case 'PartSmart':
                    $scope.M_CO.ConfirmationModel.headingText = $translate.instant('Part_not_found_label');
                  $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Part_not_found_description') + ":";
                  $scope.M_CO.ConfirmationModel.modalCss = "part-smart-confirmation";
                  $scope.M_CO.ConfirmationModel.isAlert = true;
                  $scope.M_CO.ConfirmationModel.okBtnLabel = $translate.instant('Okay_label');
                  $scope.M_CO.ConfirmationModel.hideCloseIcon = true;
                  $scope.M_CO.ConfirmationModel.helperText = '<div class="text-left list-wrapper"><ul class="disk-type-list">';
                      for(var i = 0; i < partNotInSystemList.length; i++) {
                    $scope.M_CO.ConfirmationModel.helperText += '<li>' + partNotInSystemList[i].PartNumber + '</li>';
                      }
                  $scope.M_CO.ConfirmationModel.helperText += '</ul></div>';
                  break;
                case 'FinalizeServiceJobConfirmationDialog':
                    if ($scope.M_CO.FinalizeType == 'Third Party Claim') {
                        $scope.M_CO.ConfirmationModel.headingText = $Label.Finalize_Third_Party_Claim;
                        $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Close_Claim_Warning');
                        $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Confirmation_To_Close_Claim');
                    } else if ($scope.M_CO.FinalizeType == 'Internal Job') {
                        $scope.M_CO.ConfirmationModel.headingText = $Label.Finalize_Internal_Job;
                        $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Close_Job_Warning');
                        $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Confirmation_To_Close_Job');
                    }
                    $scope.M_CO.ConfirmationModel.helperText = $Label.Print_Invoice_Message;
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.finalizeServiceJob;
                    break;
                case 'DealFinanceSectionConfirmationDialog':
                    $scope.M_CO.ConfirmationModel.headingText = $Label.Action_Required;
                    $scope.M_CO.ConfirmationModel.messageText = $Label.Remove_Deal_Financing_Warning;
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.DealFinance.RemoveDealFinancing;
                    if(event) {
                      event.stopPropagation();
                    }
                    break;
                case 'TradeInConfirmationDialog':
                    $scope.M_CO.ConfirmationModel.headingText = $Label.Action_Required;
                    $scope.M_CO.ConfirmationModel.messageText = $Label.Text_Remove_TradeIn_From_Deal_Popup_Confirm;
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.TradeIn.removeTradeItem;
                    break;
                case 'QuoteConfirmationDialog':
                    $scope.M_CO.ConfirmationModel.headingText = 'Activate Quote';
                    $scope.M_CO.ConfirmationModel.messageText = 'This action will activate all sections on this order.';
                    $scope.M_CO.ConfirmationModel.warningText = 'Do you want to continue?';
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.activateQuoteCO;
                    break;
                case 'CommitUnitToDealConfirmationDialog':
                    $scope.M_CO.ConfirmationModel.headingText = $Label.Commit_units_to_deal;
                    $scope.M_CO.ConfirmationModel.okBtnLabel = $Label.Yes_Commit;
                    $scope.M_CO.ConfirmationModel.cancelBtnLabel = $Label.Cancel_Label;
                    $scope.M_CO.ConfirmationModel.messageText = 'Commiting units to deal will activate all sections on this order and you will no longer be able to set this order as Quote.';
                    $scope.M_CO.ConfirmationModel.warningText = 'Are you sure, you want to continue?';
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.updateDealStatus;
                    break;
                case 'RemoveSection':
                    $scope.M_CO.ConfirmationModel.okBtnLabel = $Label.Delete_Confirmation_Label;
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.deleteConfirmationDialogCallback;
                    if (sectionName === 'ServiceJob') {
                        $scope.M_CO.ConfirmationModel.headingText = $Label.Delete_service_job;
                        $scope.M_CO.ConfirmationModel.messageText = $Label.Service_Job_Delete_Confirmation;
                        $scope.M_CO.ConfirmationModel.payload = {
                            coHeaderId: $scope.M_CO.COHeaderId,
                            id: sectionId,
                            callback: $scope.F_CO.deleteServiceJob
                        };
                    } else if (sectionName === 'Merchandise') {
                        $scope.M_CO.ConfirmationModel.headingText = $Label.Delete_merchandise;
                        $scope.M_CO.ConfirmationModel.messageText = $Label.Merchandise_Delete_Confirmation;
                        $scope.M_CO.ConfirmationModel.payload = {
                            coHeaderId: $scope.M_CO.COHeaderId,
                            callback: $scope.F_CO.deleteMerchandise
                        };
                    } else if (sectionName === 'Deal') {
                        $scope.M_CO.ConfirmationModel.headingText = $Label.Delete_deal;
                        $scope.M_CO.ConfirmationModel.messageText = $Label.Deal_Delete_Confirmation;
                        $scope.M_CO.ConfirmationModel.payload = {
                            id: $scope.M_CO.Deal.DealInfo.Id,
                            callback: $scope.F_CO.deleteDeal
                        };
                    }
                    break;
                case 'DealOptionStatus':
                    $scope.M_CO.ConfirmationModel.headingText = $translate.instant('Option_status_Label');
                    $scope.M_CO.ConfirmationModel.messageText = '<div class="option-status bp-badge-style ' + $scope.M_CO.dealOptionsStatusCssConfig[$scope.M_CO.Deal.OptionStatus] + '">' + 'Options: <span class="text-uppercase">' + $scope.M_CO.Deal.OptionStatus + '<span></div>';
                    if ($scope.M_CO.Deal.OptionStatus === 'None') {
                        $scope.M_CO.ConfirmationModel.helperText = $translate.instant('Deal_options_status_helper_msg_1');
                        $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Deal_options_status_warning_msg_1');
                    } else if ($scope.M_CO.Deal.OptionStatus === 'Required' && $scope.M_CO.Deal.DealInfo.DealStatus === 'Quotation') {
                        $scope.M_CO.ConfirmationModel.helperText = $translate.instant('Deal_options_status_helper_msg_2');
                    } else if ($scope.M_CO.Deal.OptionStatus === 'Required' && $scope.M_CO.Deal.DealInfo.DealStatus !== 'Quotation') {
                        $scope.M_CO.ConfirmationModel.helperText = $translate.instant('Deal_options_status_helper_msg_3');
                        $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Deal_options_status_warning_msg_3');
                        $scope.M_CO.ConfirmationModel.okBtnLabel = $translate.instant('Commit_options_to_the_deal_label');
                        $scope.M_CO.ConfirmationModel.okBtnCss = "bp-btn-extra-large";
                        $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.commitAndInstallDeal;
                        $scope.M_CO.ConfirmationModel.isAlert = false;
                    } else if ($scope.M_CO.Deal.OptionStatus === 'Pending') {
                        $scope.M_CO.ConfirmationModel.helperText = $translate.instant('Deal_options_status_helper_msg_4');
                        $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Deal_options_status_warning_msg_4');
                    } else if ($scope.M_CO.Deal.OptionStatus === 'Fulfilled') {
                        $scope.M_CO.ConfirmationModel.helperText = $translate.instant('Deal_options_status_helper_msg_5');
                    }
                    break;
                case 'DeleteCO':
                  $scope.M_CO.ConfirmationModel.headingText = $translate.instant('Delete_customer_order');
                    if ($scope.F_CO.validateCODeleteAction()) {
                      $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Delete_customer_order_confirmation_msg_4');
                      $scope.M_CO.ConfirmationModel.okBtnLabel = $translate.instant('Delete_Confirmation_Label');
                        $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.deleteCustomerOrder;
                        $scope.M_CO.ConfirmationModel.isAlert = false;
                    }
                  break;
                case 'StockInCOU':
                    $scope.M_CO.ConfirmationModel.headingText = $translate.instant('Label_Stock_in_customer_unit');
                    $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Stock_in_cou_message') + ':';
                    $scope.M_CO.ConfirmationModel.modalCss = "trade-in-active-stock-unit";
                    $scope.M_CO.ConfirmationModel.isAlert = false;
                    $scope.M_CO.ConfirmationModel.helperText = '<div class="text-left list-wrapper"><ul class="disk-type-list">';
                    $scope.M_CO.ConfirmationModel.helperText += '<li class="bp-coral-font H300"> The ACV of the trade cannot be changed</li>';
                    $scope.M_CO.ConfirmationModel.helperText += '<li class="bp-coral-font H300"> The trade cannot be taken back out of stock</li>';
                    $scope.M_CO.ConfirmationModel.helperText += '<li class="bp-coral-font H300"> The trade cannot be removed fom the deal</li>';
                    $scope.M_CO.ConfirmationModel.helperText += '<li class="bp-coral-font H300"> The deal cannot be removed from the customer order</li>';
                    $scope.M_CO.ConfirmationModel.helperText += '<li class="bp-coral-font H300"> The customer order cannot be deleted</li>';
                    $scope.M_CO.ConfirmationModel.helperText += '</ul></div>';
                    $scope.M_CO.ConfirmationModel.warningText = $translate.instant('Stock_in_cou_confirmation_message');
                    $scope.M_CO.ConfirmationModel.okBtnLabel = $translate.instant('Confirm');
                    $scope.M_CO.ConfirmationModel.okBtnFunc = $scope.F_CO.TradeIn.stockInCOU;
                  break;
                case 'DealItemInternalServiceStatusDialog' : 
               	 	$scope.M_CO.ConfirmationModel.headingText = 'cannot approve this deal';
               	 	var origin = window.location.origin;
               	 	var COList = '';
               	 	for (var i = 0; i < $scope.M_CO.coHeaderSuccessResult.length; i++) {
               	 		var url = '\'' + origin + '/apex/Blackpurl#/CustomerOrder_V2?Id=' + $scope.M_CO.coHeaderSuccessResult[i].COHeaderId + '\'';
               	 		COList += '<a onclick ="window.open(' + url + ')">'+ $scope.M_CO.coHeaderSuccessResult[i].OrderName +' </a>';
               	 		COList += ', ';
                    }
               	 	COList = COList.substring(0, COList.length-2);
                    $scope.M_CO.ConfirmationModel.messageText = $sce.trustAsHtml($translate.instant('Active_internal_service_msg1')+ COList + $translate.instant('Active_internal_service_msg2'));
               	 	$scope.M_CO.ConfirmationModel.modalCss = "active-internal-service-on-unit-deal";
                    $scope.M_CO.ConfirmationModel.okBtnLabel = $translate.instant('Okay_label');
                break; 
            }
            $scope.M_CO.ConfirmationModel.showDialog = true;
        }
        $scope.F_CO.finalizeJobPopUp = function(SoHeaderIndex) {
            $scope.M_CO.serviceJobIndex = SoHeaderIndex;
            $scope.F_CO.openConfirmationDialog('FinalizeServiceJobConfirmationDialog', false);
        }
        $scope.F_CO.finalizeServiceJob = function() {
            var recordIdList = [];
            recordIdList.push($scope.M_CO.SOHeaderList[$scope.M_CO.serviceJobIndex].SOInfo.Id);
            finalizeInvoiceJob(recordIdList);
        }

        function finalizeInvoiceJob(recordIdList) {
            var successJson = {
                'type': 'finalizeInvoice'
            };
            $scope.M_CO.isLoading = true;
            CheckoutServices.finalizeInvoice(angular.toJson(recordIdList), $scope.M_CO.COHeaderId).then(new success(successJson).handler, new error().handler);
        }
        $scope.F_CO.hideresolveFulfillmentDropdown = function() {
            $scope.M_CO.setBotrderOnSpan = '';
        }

        $scope.F_CO.createInternalService = function() {
            $scope.M_CO.sellingGroup = 'Internal Service';
            $scope.M_CO.isLoading = true;
            $scope.M_CO.DummyAccordion = '';
            var selectedCustomerId = null;
            var successJson = {
                'type': 'createCO'
            };
            createCOServerCall(selectedCustomerId, successJson);
        }

        $scope.F_CO.openCustomerOrder = function(COHeaderId) {
            $scope.M_CO.isLoading = true;
            $rootScope.CustomerOrder_V2Parms = {};
            loadState($state, 'CustomerOrder_V2', {
                Id: COHeaderId,
                AppointmentId: ''
            });
            $scope.F_CO.closeActiveOrderPopup();
        }
        $scope.F_CO.replaceUnitFromInternalService = function(index) {
            $scope.M_CO.isReplaceUnit = true;
            setTimeout(function() {
                $scope.F_CO.setFocusOnInput('autocompleteServiceJob' + index);
            }, 100);
        }
        $scope.F_CO.isCOWithoutCustomer = function() {
            if ($scope.M_CO.coHeaderRec.COType == 'Internal Service' || $scope.M_CO.coHeaderRec.COType == 'Cash Sale') {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_CO.syncDealWithDP360 = function() {
          $scope.M_CO.isLoading = true;

          DealService.syncDealWithDP360($scope.M_CO.Deal.DealInfo.Id).then(function(result) {
            $scope.M_CO.isLoading = false;
            if(!result.Id) {
              Notification.error(result);
            } else {
              if($scope.M_CO.Deal.DealInfo.DP360LeadId) {
                Notification.success('Deal updated successfully with lead Id : ' + $scope.M_CO.Deal.DealInfo.DP360LeadId);
              } else {
                if(result.DP360LeadId) {
                  Notification.success('Deal created successfully with lead Id : ' + result.DP360LeadId);
                } else {
                  Notification.error('Error synching deal');
                }

                $scope.M_CO.Deal.DealInfo = result;
              }
            }

            }, function(error) {
                $scope.M_CO.isLoading = false;
                Notification.error('Error synching deal');
            });
        }

        $scope.F_CO.goToDP360 = function() {
          $scope.M_CO.isLoading = true;
          DealService.getLeadUrlByLeadId($scope.M_CO.Deal.DealInfo.DP360LeadId).then(function(result) {
            $scope.M_CO.isLoading = false;
            if(result) {
              var myWindow = window.open(result, "width=1200, height=600");
            } else {
              Notification.error('First sync this deal with dp360');
            }
            }, function(error) {
                $scope.M_CO.isLoading = false;
                //Notification.error($translate.instant('Error_in_deleting_deal'));
            });
        }

        $scope.CheckoutInfoModel.TotalDiscount = function() {
            var discountAmount = 0;
            if (!isBlankValue($scope.CheckoutInfoModel.InvoiceItemList)) {
                for (var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
                    if ($scope.CheckoutInfoModel.InvoiceItemList[i].IsInvoiceable && $scope.CheckoutInfoModel.InvoiceItemList[i].IsActive) {
                        discountAmount += $scope.CheckoutInfoModel.InvoiceItemList[i].DiscountAmount;
                    }
                }
            }
            return discountAmount;
        }
        $scope.F_CO.invoiceChkboxClicked = function(invoiceType) {
            if (!($scope.F_CO.isDisabledCheckoutBtn())) {
                if (invoiceType == 'Print') {
                    $scope.M_CO.isPrintInvoice = !($scope.M_CO.isPrintInvoice);
                } else if (invoiceType == 'Email') {
                    $scope.M_CO.isEmailInvoice = !($scope.M_CO.isEmailInvoice);
                }
            }
        }
        $scope.F_CO.invoicePrintPreview = function(customerInvoiceId) {
            var myWindow = window.open(url + "PrintCustomerOrderInvoice?id=" + customerInvoiceId + "&isFinalized=" + true, "", "width=1200, height=600");
        }

        $scope.F_CO.disableSTA = function(sectionName) {
            var STA_disableFlag = false;
            switch (sectionName) {
                case 'Merchandise':
                    if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                        STA_disableFlag = true;
                    }
                    break;
                case 'DealMerchandise':
                    if ($scope.M_CO.coHeaderRec.OrderStatus == 'Closed' || !$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                        STA_disableFlag = true;
                    }
                    break;
            }
            return STA_disableFlag;
        }

        $scope.F_CO.showAddToOrderSection = function() {
            var addToOrderSection_displayFlag = false;
            // Conditions taken from complete Add to order section and other conditions related to permission from individual anchor tag
            if (($scope.M_CO.SOHeaderList.length > 0 || $scope.M_CO.COKHList.length > 0 || $scope.M_CO.IsShowMerchandiseSection || $scope.M_CO.DummyAccordion != '' || $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.Id) && $scope.M_CO.coHeaderRec.COType != 'Internal Service' && $scope.M_CO.coHeaderRec.OrderStatus != 'Closed' && ((!$scope.F_CO.disableCreateMerchandiseAction() && !$scope.M_CO.IsShowMerchandiseSection && $scope.M_CO.COKHList.length == 0) || $rootScope.GroupOnlyPermissions['Service job']['create/modify'] || ($rootScope.GroupOnlyPermissions['Deal']['create/modify'] && (!$scope.M_CO.Deal.DealInfo || $scope.M_CO.Deal.DealInfo.Id == undefined))) && $scope.F_CO.isAddCustomerActionForCashSaleAvailable()) {
                addToOrderSection_displayFlag = true;
            }
            return addToOrderSection_displayFlag;
        }

        $scope.F_CO.showClaimLinks = function(actionName, soHeader) {
            var showClaimLinks = true;
            if (actionName === 'SubmitClaim') {
                if (soHeader.SOInfo.ClaimStatus == 'Unsubmitted' && soHeader.SOInfo.WorkStatus != 'Signed Out' && ($scope.F_CO.getSOPermissionType()['create/modify'])) {
                    showClaimLinks = true;
                } else {
                    showClaimLinks = false;
                }
            } else if (actionName === 'ClaimResponse') {
                if (soHeader.SOInfo.ClaimStatus == 'Submitted' && soHeader.SOInfo.WorkStatus != 'Invoiced' && ($scope.F_CO.getSOPermissionType()['create/modify'])) {
                    showClaimLinks = true;
                } else {
                    showClaimLinks = false;
                }
            }
            return showClaimLinks;
        }

        $scope.F_CO.showActionSubSection = function(sectionName, headerRecord) {
            var actionSubSection_displayFlag = false;
            if (sectionName === 'Service job') {
                if (($scope.M_CO.coHeaderRec.OrderStatus !== 'Quote' && headerRecord.SOInfo.WorkStatus != 'Invoiced' && ($scope.F_CO.getSOPermissionType()['create/modify']) || $scope.M_CO.coHeaderRec.OrderStatus === 'Quote' && ($rootScope.GroupOnlyPermissions['Service job']['create/modify'] && (!headerRecord.SOGridItems.length && headerRecord.SOInfo.WorkStatus != 'Complete' && headerRecord.SOInfo.WorkStatus != 'Reviewed' && headerRecord.SOInfo.WorkStatus != 'Invoiced' && headerRecord.SOInfo.WorkStatus != 'Signed Out' && headerRecord.HoursLoggedList.length == 0)))) {
                    actionSubSection_displayFlag = true;
                }
            } else if (sectionName === 'Deal Merchandise') {
                if ($scope.F_CO.isDealMerchandiseContainInvoicableItem() && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify'] && $rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify']) {
                    actionSubSection_displayFlag = true;
                }
           } else if (sectionName === 'Deal') {
                if($rootScope.GroupOnlyPermissions['Deal']['create/modify'] && ($scope.F_CO.displayDealAction('Add_trade_in') || $scope.F_CO.displayDealAction('Add_another_unit') || $scope.F_CO.displayDealAction('Add_deal_financing') || $scope.F_CO.displayDealAction('Commit_and_install_options') ) ) {
                    actionSubSection_displayFlag = true;
                }
            }
            return actionSubSection_displayFlag;
        }
        $scope.M_CO.printReceiptInvoiceList = [{
          Name:'Invoice',
          isSelected : true
        },{
          Name:'Print receipt',
          isSelected : false
        }]
        $scope.F_CO.showPrintpopUpModalWindow = function(CoInvoiceHeaderId){
          for(var i= 0 ; i<$scope.M_CO.printReceiptInvoiceList.length;i++){
            if($scope.M_CO.printReceiptInvoiceList[i].Name == 'Invoice') {
              $scope.M_CO.printReceiptInvoiceList[i].isSelected = true;
            }else{
              $scope.M_CO.printReceiptInvoiceList[i].isSelected = false;
            }
          }
          angular.element('#print-modal').modal({
                 backdrop: 'static',
                 keyboard: false
             });
             angular.element('#print-modal').show();
             $scope.M_CO.PrintCOInvoiceHeaderId = CoInvoiceHeaderId;
        }

        $scope.F_CO.openPrintpopUpModalWindow = function() {
            CheckoutServices.getActiveInvHeaderId($scope.M_CO.COHeaderId).then(function(result) {
                $scope.M_CO.coHeaderRec.ActiveInvoiceId = result;
                if(!result) {
                    Notification.error("No line item to invoice");
                } else {
                    angular.element('#print-modal').modal({
                        backdrop: 'static',
                        keyboard: false
                    });
                    angular.element('#print-modal').show();
                }
            }, function(errorSearchResult) {
            handleErrorAndExecption(error);
          });
    }
        
        $scope.F_CO.togglePrintReceiptItemCheckbox = function(index){
          $scope.M_CO.printReceiptInvoiceList[index].isSelected = !$scope.M_CO.printReceiptInvoiceList[index].isSelected;
        }
        angular.element(document).on("click", "#print-modal .modal-backdrop", function() {
            $scope.F_CO.hidePrintpopUpModalWindow();
        });
        $scope.F_CO.hidePrintpopUpModalWindow = function() {
           angular.element('#print-modal').modal('hide');
           if($scope.M_CO.showInvoicePreviewPopup) {
             $scope.M_CO.showInvoicePreviewPopup = '';
             $scope.M_CO.PrintCOInvoiceHeaderId = '';
           }
        }
        /**
         * To handle Internal service and Normal service job based on permissions
         */
        $scope.F_CO.getSOPermissionType = function() {
            if ($scope.M_CO.coHeaderRec.COType == 'Internal Service') {
                return $rootScope.GroupOnlyPermissions['Internal Service'];
            } else {
                return $rootScope.GroupOnlyPermissions['Service job'];
            }
        }

        $scope.F_CO.getStatusForSpecialOrder = function() {
            var isPartAddedVO = false;
            for(var i=0;i<$scope.M_CO.SpecialOrderList.length;i++) {
                if($scope.M_CO.SpecialOrderList[i].Status != 'Required') {
                    isPartAddedVO = true;
                    break;
                }
            }
            return isPartAddedVO;
        }

        $scope.F_CO.getSpecialOrdersData = function() {
            if ($scope.M_CO.ConfirmationModel && $scope.M_CO.ConfirmationModel.showDialog) {
                $scope.showLineItemEditConfirmationModal = true;
            }
            SpecialOrderService.getSpecialOrders($scope.M_CO.COHeaderId).then(function(response) {
                $scope.M_CO.SpecialOrderList = response;
                $scope.M_CO.isLoading = false;
            }).catch(function(error) {
                Notification.error("Error in loading Special orders data", error);
            });
        }
        $scope.F_CO.confirmEditLineItem = function(payload) {
            if (payload) {
                $scope.F_CO.editLineItem(payload.lineItem, payload.sectionName, payload.indexLevel1, payload.indexLevel2, payload.indexLevel3, true)
            }
        }
        $scope.F_CO.closeLineItemConfirmation = function() {
            $scope.M_CO.ConfirmationModel = null;
            $scope.showLineItemEditConfirmationModal = false;
            angular.element("body").removeClass("modal-open");
        }
        /**
         * Description: Generate confirmation message for Special order when Part Line item is edited.
         */
        var getSpecialOrderEditConfirmationMsg = function(lineItem) {
            var message = '',
                spOrder = 0,
                vOrderOpen = 0,
                vOrderOnOrder = 0;
            var lineItemId = lineItem.CoLineItemId || lineItem.CoLineItem;
            for (var i = 0; i < $scope.M_CO.SpecialOrderList.length; i++) {
                if (lineItemId == $scope.M_CO.SpecialOrderList[i].COLineItemId) {
                    if ($scope.M_CO.SpecialOrderList[i].POStatus) {
                        if ($scope.M_CO.SpecialOrderList[i].POStatus === 'Open') {
                            vOrderOpen += $scope.M_CO.SpecialOrderList[i].QtyNeeded;
                        } else {
                            vOrderOnOrder += $scope.M_CO.SpecialOrderList[i].QtyNeeded;
                        }
                    } else {
                        spOrder += $scope.M_CO.SpecialOrderList[i].QtyNeeded;
                    }
                }
            }
            if (lineItem.QtyOrder >= (spOrder + vOrderOpen + vOrderOnOrder)) {
                if (spOrder == 0) {
                    if (vOrderOpen > 0) {
                        message = $Label.Your_changes_modified_the_existing_vendor_order;
                    } else {
                        message = $Label.Your_changes_NOT_modified_the_existing_vendor_order + '. ' + $Label.The_addition_items_needed_will_have_to_be_ordered_separately;
                    }
                }
            } else if ((spOrder + vOrderOpen + vOrderOnOrder - lineItem.QtyOrder) > spOrder) {
                if (lineItem.QtyOrder < vOrderOnOrder) {
                    message = $Label.Your_changes_modified_the_existing_vendor_order_to_allocate_the_ordered_items_as;
                } else if (lineItem.QtyOrder < (spOrder + vOrderOpen)) {
                    message = $Label.Your_changes_modified_the_existing_vendor_order;
                }
            }
            return message;
        }
        /**
         * Description: Create a modal dialog payload for Line item edit confirmation
         */
        var createLineItemModalDialogPayload = function(lineItem, payload, msg) {
             if ((!lineItem.IsNonInventoryPart && (lineItem.EntityType == 'Part' || lineItem.IsPart) && lineItem.POStatus) || (lineItem.POStatus === 'Open' && lineItem.IsSublet)) {
                var message = msg || (getSpecialOrderEditConfirmationMsg(lineItem));
                if (message) {
                    $scope.M_CO.ConfirmationModel = {
                        "showDialog": true,
                        "headingText": (lineItem.POStatus === 'On Order') ? $Label.Item_already_ordered : $Label.Item_already_on_order,
                        "messageText": $Label.Line_item_edit_confirmation_msg1 + " <span class='bp-bold-font bp-blue-font'>" + lineItem.VONumber + "</span>",
                        "helperText": $Label.Line_item_edit_confirmation_msg2 + " <span class='bp-bold-font bp-green-dark-font'>" + lineItem.POStatus + "</span>",
                        "warningText": message,
                        "isAlert": payload ? false : true,
                        "payload": payload
                    };
                }
            }
        }

        /**
         * handle Oversold Qty max value based on oversell inventory permission
         */
        $scope.F_CO.getMaxCommitedValue = function(lineItem) {
            var qtyNeeded = lineItem.QtyNeeded || lineItem.Qty; // If SO then QtyNeeded else if Merch then Qty
            if ($rootScope.GroupOnlyPermissions['Oversell inventory']['enabled']) {
                return qtyNeeded;
            } else {
                if (lineItem.StockCommitedCpy > lineItem.ActualAvailableParts) { // If Qty is already oversold before taking permission from user
                    return lineItem.StockCommitedCpy;
                } else { // Qty should not be oversold(should not be greater than available inventory) and should not be greater than qty needed too
                    return Math.min(qtyNeeded, lineItem.ActualAvailableParts);
                }
            }
        }

        /**
         * get min attribute value for Number only input model
         */
       $scope.F_CO.getMinAttributeValueBasedOnReturnFlag = function(sectionName, sectionIndex, soli, isFee) {
            if ($scope.F_CO.allowReturn(sectionName, sectionIndex,soli, isFee)) { // In case of -ve allowed value we don't have min value
                return '';
            } else {
                return 0.01;
            }
        }

        /**
         * get include negative attribute value for Number only input model
         */
         $scope.F_CO.allowReturn = function(sectionName, sectionIndex, soli, isFee) {
            if (!$rootScope.GroupOnlyPermissions['Returns']['enabled'] ||
                ($scope.M_CO.showQuote &&
                    ((soli && !soli.IsFee && !soli.IsEnvFee) || (!soli && !isFee)))) {
                return false;
            } else if (sectionName === 'SO' && $scope.M_CO.SOHeaderList[sectionIndex].SOInfo.DealId) { // In case of deal service
                return false;
            } else if (soli && soli.IsSublet) {
                return false;
            } else {
                return true;
            }
        }
        $scope.F_CO.showCheckoutBtn = function() {
            if ($scope.M_CO.coHeaderRec.COType != 'Internal Service' && $scope.M_CO.coHeaderRec.OrderStatus != 'Closed' && $rootScope.GroupOnlyPermissions['Customer invoicing']['create/modify']) {
                return true;
            } else {
                return false;
            }
        }

        /**
         * To handle Checkout related permissions to select line items based on Source section permissions
         */
        $scope.F_CO.disableCheckOutItemSelection = function(checkOutItem) {
           if(($scope.F_CO.isDealSelectedForCheckout() && checkOutItem.CheckoutItemType === 'Deal' && $scope.M_CO.isCheckOutPartialSelect) ) {
            return false;
        }
            else if(($scope.F_CO.isDealSelectedForCheckout() && checkOutItem.CheckoutItemType !== 'Deal') ||  (!$scope.F_CO.isDealSelectedForCheckout() && checkOutItem.CheckoutItemType === 'Deal' && $scope.M_CO.isCheckOutPartialSelect)) {
            return true;
          }
           else if (checkOutItem.CheckoutType === 'Customer' && (checkOutItem.CheckoutItemType == 'Part' || checkOutItem.CheckoutItemType == 'Fee' || checkOutItem.CheckoutItemType == 'Kit') && $rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) { // Source Section: Merchandise && Merchandise>create/modify true
                return false;
            } else if (checkOutItem.CheckoutType === 'Customer' && (checkOutItem.CheckoutItemType == 'Service Job' || checkOutItem.CheckoutItemType == 'SO Deductible') && $rootScope.GroupOnlyPermissions['Service job']['create/modify']) { // Source Section: Service job && Service job>create/modify true
                return false;
            } else if (checkOutItem.CheckoutType === 'Customer' && (checkOutItem.CheckoutItemType == 'Deal') && $rootScope.GroupOnlyPermissions['Deal']['create/modify']) { // Source Section: Deal && Deal>create/modify true
                return false;
            } else {
                return true;
            }
        }

        $scope.F_CO.disableCreateMerchandiseAction = function() {
            if (($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType == 'Internal Service')
                || ($scope.M_CO.coHeaderRec.CustomerId && !$rootScope.GroupOnlyPermissions['Merchandise']['create/modify'])
            || (!$scope.M_CO.coHeaderRec.CustomerId && !$rootScope.GroupOnlyPermissions['Quick sale']['enabled'])) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_CO.disableCreateDealAction = function() {
            if (($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType == 'Internal Service')
                || !$rootScope.GroupOnlyPermissions['Deal']['create/modify']) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_CO.disableCreateServiceJobAction = function() {
            if (($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.COType == 'Internal Service')
                || !$rootScope.GroupOnlyPermissions['Service job']['create/modify']) {
                return true;
            } else {
                return false;
            }
        }
        /**
         * Don't display Edit button on Line item if nothing is editable for that line item
         */
        $scope.F_CO.displayEditBtnOnLineItem = function(sectionName, itemType, sectionHeaderIndex, kitHeaderIndex, lineitemIndex) {
            if (sectionName === 'SO') { // Handling for Service Job Section
                if ($scope.M_CO.isServiceJobDisabled(sectionHeaderIndex)) {
                    return false;
                } else if (itemType === 'KHItem') { // If SO Kit Header
                    if ($scope.M_CO.editLineItem !== 'ServiceJob_SOHeader' + sectionHeaderIndex + '_SOKitHeader' + kitHeaderIndex && !$scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].IsFixedPrice && $rootScope.GroupOnlyPermissions['Override price'].enabled) { // If Price is editable then return true
                        return true;
                    }
                } else if (itemType === 'KitLI' || itemType === 'NonKitLI') { // If SO Kit Line Item Or Non Kit Line Item
                    if ($scope.M_CO.editLineItem === 'ServiceJob_SOHeader' + sectionHeaderIndex + '_SOKitHeader' + kitHeaderIndex + '_SOLI' + lineitemIndex) { // If Line item is already in edit Mode
                        return false;
                    } else if (!$scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].IsPart) { // Fee, sublet & Labour desc - always editable - so returning true
                        return true;
                    } else if ($scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].IsPart && !$scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].IsNonInventoryPart && (($scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].QtyNeeded >= 0) || (!($scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].QtyNeeded >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // For Inventory part LI committed and order qty are always editable, but if qty is -ve & user don't have Return permission enabled then these fields will not be editable, (for Kit line item qty is not editable so can't be -ve)
                        return true;
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled && ((itemType === 'NonKitLI') || (itemType === 'KitLI' && !$scope.M_CO.SOHeaderList[sectionHeaderIndex].SOGridItems[kitHeaderIndex].SOLIList[lineitemIndex].IsFixedPrice))) { // If Price is editable then return true
                        return true;
                    }
                }
                return false;
            } else if (sectionName === 'Merchandise') { // Handling for Merchnadise Section
                if (!$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                    return false;
                } else if (itemType === 'KHItem') { // If CO Kit Header
                    if ($scope.M_CO.editLineItem !== 'Merchandise_Section_COKitHeader' + kitHeaderIndex && !$scope.M_CO.COKHList[kitHeaderIndex].IsFixedPrice && $rootScope.GroupOnlyPermissions['Override price'].enabled && $scope.M_CO.COKHList[kitHeaderIndex].COLIList[0].Status !== 'Invoiced') { // If Price is editable then return true
                        return true;
                    }
                } else if (itemType === 'KitLI' || itemType === 'NonKitLI') { // If CO Kit Line Item Or Non Kit Line Item
                    if ($scope.M_CO.editLineItem === 'Merchandise_Section_COKitHeader' + kitHeaderIndex + '_COLI' + lineitemIndex || $scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].Status === 'Invoiced') { // If Line item is already in edit Mode or its status is invoiced
                        return false;
                    } else if ($scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].EntityType !== 'Part') { // Fee, sublet & Labour desc - always editable - so returning true
                        return true;
                    } else if ($scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].EntityType === 'Part' && !$scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].IsNonInventoryPart && (($scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].Qty >= 0) || (!($scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].Qty >= 0) && $rootScope.GroupOnlyPermissions['Returns']['enabled']))) { // For Inventory part LI committed and order qty are always editable, but if qty is -ve & user don't have Return permission enabled then these fields will not be editable, (for Kit line item qty is not editable so can't be -ve)
                        return true;
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled && ((itemType === 'NonKitLI') || (itemType === 'KitLI' && !$scope.M_CO.COKHList[kitHeaderIndex].COLIList[lineitemIndex].IsFixedPrice))) { // If Price is editable then return true
                        return true;
                    }
                }
                return false;
            } else if (sectionName === 'DealMerch') { // Handling for Deal Merchnadise Section
                if (!$rootScope.GroupOnlyPermissions['Merchandise']['create/modify']) {
                    return false;
                } else if (itemType === 'KHItem') { // If CO Kit Header
                    if ($scope.M_CO.editLineItem !== 'DealMerch_Section_COKitHeader' + kitHeaderIndex && !$scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[kitHeaderIndex].IsFixedPrice && $rootScope.GroupOnlyPermissions['Override price'].enabled && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[kitHeaderIndex].COLIList.length > 0 && $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[kitHeaderIndex].COLIList[0].Status !== 'Invoiced') { // If Price is editable then return true
                        return true;
                    }
                } else if (itemType === 'KitLI' || itemType === 'NonKitLI') { // If CO Kit Line Item Or Non Kit Line Item
                    if ($scope.M_CO.editLineItem === 'DealMerch_Section_COKitHeader' + kitHeaderIndex + '_COLI' + lineitemIndex || $scope.M_CO.Deal.DealFulfillmentSectionObj.DealMerchandiseList[kitHeaderIndex].COLIList[lineitemIndex].Status === 'Invoiced') { // If Line item is already in edit Mode or its status is invoiced
                        return false;
                    } else { // Currently Qty field always be editable (b/c still we don't have Returns & kit functionality in Deal Merch section) - SO returning true
                        return true;
                    }
                }
                return false;
            } else if (sectionName === 'OptionFee') { // Handling for Deal Option & Fee Grid Section
                if (!$rootScope.GroupOnlyPermissions['Deal']['create/modify'] || $scope.M_CO.Deal.DealInfo.DealStatus === 'Approved' || $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced') {
                    return false;
                } else if (itemType === 'KHItem') { // If OF Kit Header
                    if ($scope.M_CO.editLineItem !== 'deal_unit' + sectionHeaderIndex + '_kit' + kitHeaderIndex && !$scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].IsFixedPrice && $rootScope.GroupOnlyPermissions['Override price'].enabled && (!$scope.F_CO.isCommitAndInstallActionDone() || $scope.M_CO.Deal.DealInfo.DealStatus === 'In Progress')) { // If Price is editable then return true
                        return true;
                    }
                } else if (itemType === 'KitLI' || itemType === 'NonKitLI') { // If OF Kit Line Item Or Non Kit Line Item
                  if(($scope.F_CO.isCommitAndInstallActionDone() && ($scope.M_CO.Deal.DealInfo.DealStatus !== 'In Progress' || ($scope.M_CO.Deal.DealInfo.DealStatus === 'In Progress' && (!$rootScope.GroupOnlyPermissions['Override price'].enabled || $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].IsFixedPrice)))) && (itemType === 'KitLI' || ($scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].PartId || $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].LabourId || ($scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].ProductId && $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].ProductType === 'Sublet')))) {
                    return false;
                  } else if ($scope.M_CO.editLineItem === 'deal_unit' + sectionHeaderIndex + '_kit' + kitHeaderIndex + '_of' + lineitemIndex
                        || ($scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].PartId
                          && ($scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].Status === 'Fulfilled'
                            && ($scope.M_CO.Deal.DealInfo.DealStatus !== 'In Progress' || (!$rootScope.GroupOnlyPermissions['Override price'].enabled
                              || $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].IsFixedPrice))))) { // If Line item is already in edit Mode, or deal status is inoviced or if it is part then if its status is Fulfilled
                        return false;
                    } else if (!$scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].PartId && (itemType === 'KitLI' || (itemType === 'NonKitLI' && $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].ProductType !== 'Warranty Plan' && $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].ProductType !== 'Financing Product' && $scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].ProductType !== 'Deal Product'))) { // Fee, sublet & Labour desc - always editable for Kit LI, but for Non Kit Li it depends on Product type
                        return true;
                    } else if (itemType === 'NonKitLI') { // Currently for Non Kit LI Qty field always be editable (b/c still we don't have Retruns functionality in Deal Option & Fee section) - SO returning true
                        return true;
                    } else if ($rootScope.GroupOnlyPermissions['Override price'].enabled && ((itemType === 'NonKitLI') || (itemType === 'KitLI' && !$scope.M_CO.Deal.UnitList[sectionHeaderIndex].DealKitHeaderList[kitHeaderIndex].OptionAndFeeList[lineitemIndex].IsFixedPrice))) { // If Price is editable then return true
                        return true;
                    }
                }
                return false;
            }
        }

        /**
         * callback method of OK action on Confirmation dialog for deleting section
         */
        $scope.F_CO.deleteConfirmationDialogCallback = function(cbData) {
            if (cbData && cbData.payload && cbData.payload.callback && typeof cbData.payload.callback === 'function') {
                cbData.payload.callback.apply(null, [cbData.payload.coHeaderId, cbData.payload.id]);
            }
        }

        $scope.F_CO.deleteServiceJob = function(coHeaderId, soHeaderId) {
            $scope.M_CO.isLoading = true;
            SOHeaderService.deleteServiceOrder(coHeaderId, soHeaderId).then(function(success) {
                if (success.responseStatus && success.responseStatus == 'error') {
                    Notification.error(success.response);
                } else {
                  $scope.M_CO.documents.forms.so[soHeaderId] = {};
                  $scope.M_CO.documents.activeForms.so[soHeaderId] = {};
                    getSOHeaderDetails({});
                    $scope.M_CO.coHeaderRec.OrderStatus = success;
                }
                $scope.M_CO.isLoading = false;
                resetAnimationFlags();
            }, function(error) {
                $scope.M_CO.isLoading = false;
                Notification.error($translate.instant('Error_in_deleting_service_job'));
            });
        }
        $scope.F_CO.deleteMerchandise = function(coHeaderId) {
            $scope.M_CO.isLoading = true;
            SOHeaderService.removeMerchandiseSection(coHeaderId, true).then(function(reponse) {
                $scope.M_CO.IsShowMerchandiseSection = false;
                $scope.M_CO.isLoading = false;
                resetAnimationFlags();
            }, function(error) {
                $scope.M_CO.isLoading = false;
                Notification.error($translate.instant('Error_in_deleting_merchandise'));
            });
        }
        $scope.F_CO.deleteDeal = function(coHeaderId, dealId) {
            $scope.M_CO.isLoading = true;
            DealService.removeDeal(dealId).then(function(data) {
                if (data.responseStatus === 'success') {
                    $scope.M_CO.Deal = {};
                    $scope.M_CO.documents.forms.dealFinance = {};
                    $scope.M_CO.documents.forms.deal = {};
                    $scope.M_CO.documents.activeForms.dealFinance = {};
                    $scope.M_CO.documents.activeForms.deal = {};
                    $scope.M_CO.coHeaderRec.OrderStatus = data.response;
                    resetAnimationFlags();
                } else if (data.responseStatus === 'error') {
                    Notification.error(data.response);
                }
                $scope.M_CO.isLoading = false;
            }, function(error) {
                $scope.M_CO.isLoading = false;
                Notification.error($translate.instant('Error_in_deleting_deal'));
            });
        }
        $scope.F_CO.moveToState = function(stateName, attr, isLoadState) {
            if (isLoadState && attr && attr.Id) {
                var url = $state.href(stateName, attr);
                window.open(url, '_blank');
            }
        }
        $scope.F_CO.getAlternateParts = function(lineItem, headerId, sectionType, soHeaderIndex) {
            $scope.M_CO.showRelatedPartsClicked = true;
            $scope.M_CO.alternatePartsList = [];
            $scope.M_CO.alternatePartsData = {
                "lineItem": createLineItem(lineItem, sectionType),
                "HeaderId": headerId,
                "DealId": lineItem.DealId,
                "SectionType": sectionType,
                "SoHeaderIndex": soHeaderIndex
            };
            $scope.M_CO.isLoading = true;
            SOHeaderService.getAlternatePartsList(lineItem.PartId || lineItem.partId).then(function(response) {
                $scope.M_CO.alternatePartsList = response;
                $scope.M_CO.alternatePartsData.lineItem = lineItem;
                $scope.M_CO.isLoading = false;
            }, function(error) {
                Notification.error(error);
                $scope.M_CO.isLoading = false;
            });
        }
        //TODO - review - Copied code from Old CO - patch work due to Modal naming inconsistency
        function createLineItem(originalLineItem, SectionType) {
            var lineItem = {};
            lineItem.QtyOrder = originalLineItem.QtyOrder;
            lineItem.VONumber = originalLineItem.VONumber;
            if (SectionType == 'ServiceOrder') {
                lineItem.Id = originalLineItem.Id;
                lineItem.Qty = originalLineItem.QtyNeeded;
                lineItem.PartId = originalLineItem.PartId;
            } else if (SectionType == 'Merchandise' || SectionType == 'Deal Merchandise') {
                lineItem.Id = originalLineItem.CoLineItemId;
                lineItem.Qty = originalLineItem.Qty;
                lineItem.PartId = originalLineItem.partId;
            }
            return lineItem;
        }
        //TODO REVIEW
        $scope.F_CO.selectAlternatePart = function(index) {
            var item = $scope.M_CO.alternatePartsList[index];
            if (item.RelationShip == 'Active Part' && item.PartId == $scope.M_CO.alternatePartsData.lineItem.PartId && $scope.M_CO.alternatePartsData.lineItem.VONumber != null) {
                return;
            }
            item.IsSelected = !item.IsSelected;
        }
        //TODO review
        $scope.F_CO.disableAlternatePartButton = function() {
            var flag = true;
            if ($scope.M_CO.alternatePartsList) {
                for (var i = 0; i < $scope.M_CO.alternatePartsList.length; i++) {
                    if ($scope.M_CO.alternatePartsList[i].IsSelected) {
                        flag = false;
                        break;
                    }
                }
            }
            return flag;
        }
        $scope.F_CO.addAlternateParts = function() {
            $scope.M_CO.alternatePartsData.showRelatedPartsClicked = false;
            $scope.M_CO.isLoading = true;
            if ($scope.M_CO.alternatePartsData.SectionType == 'ServiceOrder') {
                var elementId = 'SOHeader' + $scope.M_CO.alternatePartsData.SoHeaderIndex + '_SOKitHeader' + $scope.M_CO.deletableSOLI_SoKitHeader_Index + '_SOLI' + $scope.M_CO.alternatePartsData.lineItem.Id;
                var successJson = {
                    'type': 'removeServiceOrderItem',
                    'callback': getUnitDealDetails,
                    'callbackParam': {
                        'gridName': 'dealUnresolvedFulfillmentSection'
                    },
                    'SOHeaderIndex': $scope.M_CO.alternatePartsData.SoHeaderIndex,
                    'elementId': elementId,
                    'isDeleteFromMoveLIModal': false,
                    'stopLoadingIcon': true
                };
                addMultipleServiceOrderLineItems().then(new success(successJson).handler, function(error) {
                    $scope.M_CO.isLoading = false;
                    Notification.error(error);
                });
            } else if ($scope.M_CO.alternatePartsData.SectionType == 'Merchandise' || $scope.M_CO.alternatePartsData.SectionType == 'Deal Merchandise') {
                var successJson = {
                    'type': 'deleteCOLineItem',
                    'stopLoadingIcon': true
                };
                if ($scope.M_CO.alternatePartsData.SectionType == 'Deal Merchandise') {
                    successJson = {
                        'type': 'deleteDealCOLineItem',
                        'stopLoadingIcon': true
                    };
                }
                addMultipleCOLineItems().then(new success(successJson).handler, function(error) {
                    $scope.M_CO.isLoading = false;
                    Notification.error(error);
                });
            }
        }
        $scope.F_CO.isShowCOAsQuote = function() {
            $scope.M_CO.showQuote = ($scope.M_CO.coHeaderRec.OrderStatus && $scope.M_CO.coHeaderRec.OrderStatus === 'Quote') ? true : false;
            /* #5352
             * The CO is not an Internal Service(Unit Inventory)
             * There are no entries in the Deposits section
             * There are no entries in the Invoice History section
             * There are no payments listed in Checkout
             * Any existing Merchandise section does not contain special order items that do not have a “Required” status
             * Any existing service job sections
             *         Must have a Job Type of Customer Pay
             *         Must have a status of New
             *         Does not contain special order items that do not have a “Required” status
             *         Does not contain any technician time entries
             * Any existing Deal section
             *         Must have a Deal Status of Quotation
             *         Does not contain any Deposits & Payments entries
             * */
            if (!$scope.M_CO.showQuote) {
                if ($scope.M_CO.coHeaderRec.OrderStatus != 'Open'
                    || $scope.M_CO.coHeaderRec.COType != 'Customer'
                    || $scope.M_CO.coHeaderRec.COType == 'Internal Service'
                    || ($scope.M_CO.COInvoiceHistoryList && $scope.M_CO.COInvoiceHistoryList.length > 0)
                    || ($scope.M_CO.DepositList && $scope.M_CO.DepositList.length > 0)
                    || ($scope.CheckoutInfoModel.InvoicePaymentList && $scope.CheckoutInfoModel.InvoicePaymentList.length)) {
                    return false;
                } else if ($scope.M_CO.Deal.DealInfo != undefined && ($scope.M_CO.Deal.DealInfo.DealStatus != 'Quotation' || $scope.M_CO.Deal.DealDepositList.length)) {
                    return false;
                }
                // Service Jobs check
                for (var i = 0; i < $scope.M_CO.SOHeaderList.length; i++) {
                    if (($scope.M_CO.SOHeaderList[i].SOInfo.TransactionType && $scope.M_CO.SOHeaderList[i].SOInfo.TransactionType != 'Customer' && $scope.M_CO.SOHeaderList[i].SOInfo.TransactionType != 'Quote') || $scope.M_CO.SOHeaderList[i].SOInfo.WorkStatus != 'New') {
                        return false;
                    } else if($scope.M_CO.SOHeaderList[i].HoursLoggedList && $scope.M_CO.SOHeaderList[i].HoursLoggedList.length) { // Service Jobs Technician Time Check
                        return false;
                    }
                }
                // Special Order check
                for (var i = 0; i < $scope.M_CO.SpecialOrderList.length; i++) {
                    if ($scope.M_CO.SpecialOrderList[i].Status != 'Required') {
                        return false;
                    }
                }
            }
            return true;
        };
        $scope.F_CO.setAsQuote = function() {
            if ($scope.F_CO.isShowCOAsQuote()) {
                $scope.M_CO.showQuote = !$scope.M_CO.showQuote;
                if ($scope.M_CO.showQuote) {
                    $scope.F_CO.setCOStatusAsQuote();
                } else {
                    changePayingIndex = null;
                    changePayingSoHeaderIndex = null;
                    $scope.F_CO.openConfirmationDialog('QuoteConfirmationDialog', false);
                }
            }
        }
        $scope.F_CO.setCOStatusAsQuote = function() {
            CustomerService.setCOStatusAsQuote($scope.M_CO.COHeaderId).then(function(successfulResult) {
                $scope.M_CO.showQuote = true;
            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
            });
            $scope.M_CO.isLoading = true;
            $scope.F_CO.getCOHeaderDetailsByGridName();
        }

        $scope.F_CO.activateQuoteCO = function() {
            CustomerService.activateQuoteCO($scope.M_CO.COHeaderId).then(function(successfulResult) {
                if (changePayingIndex) {
                    $scope.M_CO.isLoading = true;
                }
                $scope.M_CO.showQuote = false;
                $scope.F_CO.getCOHeaderDetailsByGridName();
                changePrintDialogTabView('Receipts','resetToDefault');

            }, function(errorSearchResult) {
                Notification.error(errorSearchResult);
            });
            $scope.M_CO.isLoading = true;
        }

        function changePrintDialogTabView(tabName, action) {
          var index = _.findIndex($scope.M_CO.printDocumentTypeList, {
                'Name': tabName
            });
            if (index > -1) {
                var PrintItems = $scope.M_CO.printDocumentTypeList[index].PrintItems;
                var i = _.findIndex(PrintItems, {
                    'Label': 'Deposit receipt'
                });
                var j = _.findIndex(PrintItems, {
                    'Label': 'Invoice preview'
                });
                if(action === 'resetToDefault') {
                  $scope.M_CO.printDocumentTypeList[index].PrintItems[i].IsVisible = true;
                    $scope.M_CO.printDocumentTypeList[index].PrintItems[j].IsSelected = false;
                } else if(action === 'onlyInvoicePreview'){
                  $scope.M_CO.printDocumentTypeList[index].PrintItems[i].IsVisible = false;
                  $scope.M_CO.printDocumentTypeList[index].PrintItems[j].IsSelected = true;
                }

            }
        }

        $scope.F_CO.isPrintPopupContainExcessTab = function() {
          var count = 0;
            for(var i=0 ; i < $scope.M_CO.printDocumentTypeList.length ; i++) {
              count += $scope.F_CO.isTabVisible($scope.M_CO.printDocumentTypeList[i].Name) ? 1 : 0;
            }
          if(count && count > 4) {
            return true;
          }else {
            return false;
          }
        }

        function addMultipleServiceOrderLineItems() {
            var defer = $q.defer();
            var alterList = $scope.M_CO.alternatePartsList;
            var PartIdsList = [];
            for (var i = 0; i < alterList.length; i++) {
                if (alterList[i].RelationShip != 'Active Part' && alterList[i].IsSelected == true) {
                    PartIdsList.push(alterList[i].PartId);
                }
            }
            SOHeaderService.addServiceOrderLineItems(JSON.stringify(PartIdsList), $scope.M_CO.alternatePartsData.HeaderId).then(function(successfulResult) {
                var activePart = alterList.filter(function isActivePart(part) {
                    return (part.RelationShip == 'Active Part' && !part.IsSelected);
                });
                if (activePart && activePart.length == 1) {
                    SOHeaderService.removeServiceOrderItem($scope.M_CO.SOHeaderList[$scope.M_CO.alternatePartsData.SoHeaderIndex].SOInfo.Id, $scope.M_CO.alternatePartsData.lineItem.Id).then(function(successResults) {
                        defer.resolve(successResults);
                    }, function(error) {
                        Notification.error(error);
                        defer.reject($translate.instant('Error_in_adding_related_parts'));
                    });
                } else {
                    defer.resolve(successfulResult);
                }
            }, function(error) {
                Notification.error(error);
                defer.reject($translate.instant('Error_in_adding_related_parts'));
            });
            return defer.promise;
        }

        function addMultipleCOLineItems() {
            var defer = $q.defer();
            var alterList = $scope.M_CO.alternatePartsList;
            var COLIList = [];
            for (var i = 0; i < alterList.length; i++) {
                if (alterList[i].RelationShip != 'Active Part' && alterList[i].IsSelected == true) {
                    COLIList.push({
                        "Qty": 1,
                        "Price": alterList[i].Price,
                        "PartId": alterList[i].PartId,
                        "DealId": $scope.M_CO.alternatePartsData.DealId
                    });
                }
            }
            var activePart = alterList.filter(function isActivePart(part) {
                return (part.RelationShip == 'Active Part' && !part.IsSelected);
            });
            merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(COLIList), null).then(function(response) {
                if (activePart && activePart.length == 1) {
                    merchandiseService.deleteCOLineItem($scope.M_CO.alternatePartsData.lineItem.CoLineItemId, $scope.M_CO.COHeaderId).then(function(successfulResults) {
                        defer.resolve(successfulResults);
                    }, function(error) {
                        Notification.error(error);
                        defer.reject($translate.instant('Error_in_adding_related_parts'));
                    });
                } else {
                    defer.resolve(response);
                }
            }, function(error) {
                Notification.error(error);
                defer.reject($translate.instant('Error_in_adding_related_parts'));
            });
            return defer.promise;
        }

        $scope.M_CO.StatusConfig = {};
        $scope.M_CO.StatusConfig.reOpen = {};
        $scope.M_CO.StatusConfig.canSaveWorkStatus = false;
        $scope.M_CO.StatusConfig.modalStatus;
        $scope.F_CO.openChangeDealStatusConfig = function() {
          if( ($scope.F_CO.getSOPermissionType()['create/modify']) ){
            $scope.M_CO.StatusConfig.showDialog = true;
                $scope.M_CO.StatusConfig.jobStatusTitle = 'Change Deal Status';
                $scope.M_CO.StatusConfig.statusList = $scope.M_CO.changeDealStatusList;
                $scope.M_CO.StatusConfig.changeDealStatusCssConfig = $scope.M_CO.changeDealStatusCssConfig;
                if ($scope.M_CO.Deal.DealInfo.DealStatus === 'Fulfilled') {
                    $scope.M_CO.StatusConfig.WorkStatus = 'Approved';
                    $scope.M_CO.StatusConfig.newWorkStatus = 'Approved';
                } else {
                    $scope.M_CO.StatusConfig.WorkStatus = $scope.M_CO.Deal.DealInfo.DealStatus;
                    $scope.M_CO.StatusConfig.newWorkStatus = $scope.M_CO.Deal.DealInfo.DealStatus;
                }
                if ($scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced') {
                    $scope.M_CO.StatusConfig.reOpen.status = $scope.M_CO.Deal.DealInfo.DealStatus;
                    $scope.M_CO.StatusConfig.reOpen.title = "This deal has been invoiced and cannot be modified";
                    $scope.M_CO.StatusConfig.okBtnLabel = 'CLOSE';
                }
                $scope.M_CO.StatusConfig.saveWorkStatus = $scope.F_CO.saveJobStatusForDeal;
                $scope.M_CO.StatusConfig.changeJobStatus = $scope.F_CO.changeDealStatus;
          }
        }
        $scope.F_CO.changeDealStatus = function(status) {
            if (!$scope.disableJobStatus(status)) {
                if (status == 'Approved' && ($scope.F_CO.isTemporaryUnitExistInDeal() || $scope.F_CO.isOrderedUnitExistsInDeal())) {
                    if($scope.F_CO.isTemporaryUnitExistInDeal()) {
                      Notification.error($translate.instant('CustomerOrder_Js_convert_Temporary_Unit_to_Stock'));
                    } else if($scope.F_CO.isOrderedUnitExistsInDeal()) {
                      Notification.error($translate.instant('Cannot set to approve when deal contains ordered unit'));
                    }
                } else {
                    $scope.M_CO.StatusConfig.newWorkStatus = status;
                }
            }
        }
        $scope.F_CO.saveJobStatusForDeal = function() {
          if($scope.M_CO.coHeaderRec.OrderStatus === 'Quote' && $scope.M_CO.StatusConfig.newWorkStatus !== 'Quotation'){
            $scope.M_CO.StatusConfig.showDialog = false;
            $scope.F_CO.openConfirmationDialog('CommitUnitToDealConfirmationDialog', false);
          } else {
            $scope.F_CO.updateDealStatus();
          }
          angular.element('body').removeClass('modal-open');
        }

        $scope.F_CO.isDealActionEnable = function() {
            if ($scope.M_CO.Deal.DealInfo.DealStatus == 'Quotation' || $scope.M_CO.Deal.DealInfo.DealStatus == 'In Progress') {
                return true;
            }
            return false;
        }
        $scope.disableJobStatus = function(status) {
            if ($scope.M_CO.Deal.DealInfo.DealStatus !== status) {
                if (status == 'In Progress' && ($scope.M_CO.Deal.DealInfo.DealStatus == 'Invoiced' || $scope.M_CO.coHeaderRec.OrderStatus == 'Closed' || !$scope.M_CO.Deal.UnitList.length || ($scope.F_CO.isCommitUnitDisable()))) {
                    return true;
                } else if (status == 'Approved' && ($scope.M_CO.Deal.DealInfo.DealStatus == 'Invoiced' || $scope.M_CO.coHeaderRec.OrderStatus == 'Closed'
                  || !$scope.M_CO.Deal.UnitList.length || ($scope.F_CO.isCommitUnitDisable() || $scope.F_CO.isOrderedUnitExistsInDeal())
                      || $scope.M_CO.isTradeInFinanceCompanyNotSelected())) {
                    return true;
                } else if (status == 'Invoiced') {
                    return true;
                } else if (status == 'Quotation' && ($scope.F_CO.isCommitAndInstallActionDone() || $scope.F_CO.TradeIn.isAnyCOUStocked())) {
                    return true;
                }
            }
            return false;
        }

        $scope.F_CO.isCommitOptionAvailable = function() {
          if($scope.M_CO.Deal.UnitList) {
            for (var i = 0; i < $scope.M_CO.Deal.UnitList.length; i++) {
                    for (var j = 0; j < $scope.M_CO.Deal.UnitList[i].DealKitHeaderList.length; j++) {
                        if ($scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].Id || ($scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].OptionAndFeeList[0].PartId ||
                        $scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].OptionAndFeeList[0].LabourId ||
                        ($scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].OptionAndFeeList[0].ProductId && $scope.M_CO.Deal.UnitList[i].DealKitHeaderList[j].OptionAndFeeList[0].ProductType === 'Sublet'))) {
                            return true;
                        }
                    }
                }
          }
            return false;
        }

        $scope.F_CO.getDealOptionStatus = function(dealObj) {
            if (dealObj.UnitList && dealObj.UnitList.length) {
                if (!$scope.F_CO.isCommitOptionAvailable()) {
                    $scope.M_CO.Deal.OptionStatus = 'None';
                } else {
                    var unitsWithCommittedOptions = dealObj.UnitList.filter(function(unit) {
                        return (unit.DealItemObj && (unit.DealItemObj.OptionAndFeeStatus === 'Committed' || unit.DealItemObj.OptionAndFeeStatus === 'Fulfilled'));
                    });
                    if (unitsWithCommittedOptions && unitsWithCommittedOptions.length) {
                        $scope.M_CO.Deal.OptionStatus = 'Pending';
                    } else {
                        $scope.M_CO.Deal.OptionStatus = 'Required';
                    }
                    if (dealObj.DealInfo.IsDealFulfilled) {
                        $scope.M_CO.Deal.OptionStatus = 'Fulfilled';
                    }
                }
            } else {
                $scope.M_CO.Deal.OptionStatus = 'None';
            }
            return $scope.M_CO.Deal.OptionStatus; //TODO Translation
        }

        $scope.F_CO.validateCODeleteAction = function() {
            if ($scope.M_CO.SpecialOrderList && $scope.M_CO.SpecialOrderList.length) {
              $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Delete_customer_order_confirmation_msg_1');
              return false;
            } else if (($scope.M_CO.DepositList && $scope.M_CO.DepositList.length && $scope.M_CO.Deposit.TotalDepositAmout)
                || ($scope.CheckoutInfoModel.InvoicePaymentList && $scope.CheckoutInfoModel.InvoicePaymentList.length)) {
              $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Delete_customer_order_confirmation_msg_5');
              return false;
            } else if($scope.M_CO.Deal.DealInfo
                || ($scope.M_CO.COKHList && $scope.M_CO.COKHList.length)
                || ($scope.M_CO.SOHeaderList && $scope.M_CO.SOHeaderList.length)) {
              $scope.M_CO.ConfirmationModel.messageText = $translate.instant('Delete_customer_order_confirmation_msg_3');
              return false;
            } else {
              return true;
            }
        }
        
        $scope.F_CO.DealFinance.keyBoardavigation = function(event, dataList, dropDownName) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_CO.DealFinance[indexName] == undefined || isNaN($scope.M_CO.DealFinance[indexName])) {
                $scope.M_CO.DealFinance[indexName] = -1;
            }
            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_CO.DealFinance[indexName]) {
                    $scope.M_CO.DealFinance[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.DealFinance[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_CO.DealFinance[indexName] > 0) {
                    $scope.M_CO.DealFinance[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.DealFinance[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13) {
                if (dropDownName == 'TermType') {
                  $scope.F_CO.DealFinance.setTermType($scope.M_CO.DealFinance[indexName]);
                  $scope.M_CO.DealFinance.showTermTypeArray  = false;
                } else if(dropDownName == 'PaymentFrequency') {
                  $scope.F_CO.DealFinance.setPaymentFrequency($scope.M_CO.DealFinance[indexName]);
                  $scope.M_CO.DealFinance.showPaymentFrequencyArray  = false;
        }else if (dropDownName == 'DealFinance') {
          var filteredKeyword = $filter("filter")(dataList, $scope.M_CO.DealFinance.selectedCmpnyName);
          $scope.F_CO.DealFinance.selectedCmpny(filteredKeyword[$scope.M_CO.DealFinance[indexName]]);
                    $scope.F_CO.DealFinance.hideProviderList();
                }
                $scope.M_CO.DealFinance[indexName] = -1;
            }
        }
        $scope.F_CO.DealFinance.getTermType = function() {
            $scope.M_CO.DealFinance.showTermTypeArray = true;
            document.getElementById('TermTypeDropDownDiv').scrollTop = 0;
        }
        $scope.F_CO.DealFinance.getPaymentFrequency = function() {
          $scope.M_CO.DealFinance.showPaymentFrequencyArray = true;
            document.getElementById('PaymentFrequencyDropDownDiv').scrollTop = 0;
        }
    $scope.F_CO.DealFinance.setTermType = function(index) {
            $scope.M_CO.Deal.DealFinanceObj.TermType = $scope.M_CO.DealFinance.TermTypeArray[index];
            $scope.F_CO.saveFinancingInfo('',true);
        }
    $scope.F_CO.DealFinance.setPaymentFrequency = function(index) {
            $scope.M_CO.Deal.DealFinanceObj.PaymentFrequency = $scope.M_CO.DealFinance.PaymentFrequencyArray[index];
            $scope.F_CO.saveFinancingInfo('',true);
        }
        $scope.F_CO.showDeleteCustomerOrderLink = function() {
            if ($scope.M_CO.coHeaderRec && $scope.M_CO.coHeaderRec.OrderStatus == 'Open'
              && (!$scope.M_CO.COInvoiceHistoryList || !$scope.M_CO.COInvoiceHistoryList.length)) {
                return true;
            } else {
                return false;
            }
        }

        $scope.F_CO.isShowCOProfitability = function() {
            if ($rootScope.GroupOnlyPermissions['Costs']['modify']) {
                return true;
            }
            return false;
        }

         $scope.F_CO.dealActionToBePerformed = function(action) {
          if(action == 'Add_trade_in') {
            $scope.F_CO.addTradeInToDeal();
          } else if(action == 'Add_another_unit') {
            $scope.F_CO.addUnitToDeal();
          } else if(action == 'Add_deal_financing') {
            $scope.F_CO.addDealFinancing();
          } else if(action == 'Commit_and_install_options') {
            $scope.F_CO.commitAndInstallDeal();
          }
        }
        $scope.F_CO.displayDealAction = function(action) {
          if(action == 'Add_trade_in' && $scope.F_CO.isDealActionEnable()) {
            return true;
          } else if(action == 'Add_another_unit' && ($scope.F_CO.isDealActionEnable() && !$scope.F_CO.isCommitAndInstallActionDone())) {
            return true;
          } else if(action == 'Add_deal_financing' && ($scope.M_CO.coHeaderRec.OrderStatus != 'Closed' && ($scope.M_CO.IsLoadFinancingSection && $scope.M_CO.Deal.DealFinanceObj.Id == null))) {
            return true;
          } else if(action == 'Commit_and_install_options' && ($scope.M_CO.Deal.OptionStatus === 'Required' && $scope.M_CO.Deal.DealInfo.DealStatus != 'Quotation')) {
            return true;
          } else {
            return false;
          }
        }
        $scope.F_CO.disabledDealAction = function(action) {
          if(action == 'Commit_and_install_options' && $scope.M_CO.Deal.DealInfo.DealStatus == 'Quotation') {
            return true;
          } else {
            false;
          }
        }

        $scope.F_CO.validateCheckoutLineItem = function() {
        	for(var i = 0; i < $scope.CheckoutInfoModel.InvoiceItemList.length; i++) {
        		if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType === 'Service Job') {
    				var index1 = _.findIndex($scope.M_CO.SOHeaderList, function(soitem) {
    					return soitem.SOInfo.Id === $scope.CheckoutInfoModel.InvoiceItemList[i].ItemId;
    				});
	    			if(index1 > -1 && $scope.M_CO.SOHeaderList[index1].SOInfo.WorkStatus !== 'Complete') {
	    				$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_service_job_line_item_error');
	    			}
        		
        		} else if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType === 'Deal') {
        			if($scope.M_CO.Deal.DealInfo.DealType === 'Cash Deal') {
        				if($scope.M_CO.Deal.DealInfo.DealStatus !== 'Approved') {
        					$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_deal_line_item_error_status');
        				} else if($scope.M_CO.Deal.DealInfo.DealStatus === 'Approved' && $scope.M_CO.Deal.OptionStatus === 'Required') {
        					$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_deal_line_item_error_options');
        				} else if($scope.M_CO.Deal.DealInfo.DealStatus === 'Approved' && $scope.F_CO.isCommitOptionAvailable() && !$scope.M_CO.Deal.DealInfo.IsDealFulfilled) {
        					$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutWarning = $translate.instant('CO_checkout_deal_options_unfulfilled_error_status');
        				}
        			} else if($scope.M_CO.Deal.DealInfo.DealType === 'Financed' && $scope.M_CO.Deal.DealFinanceObj.Status !== 'Approved') {
        				$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_deal_line_item_error_deal_finance');
        			}
        		
        		} else if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType == 'Part') {
        			var index2 = _.findIndex($scope.M_CO.COKHList, function(coitem) {
        				return ( coitem.COLIList[0].CoLineItemId === $scope.CheckoutInfoModel.InvoiceItemList[i].ItemId && !coitem.Id
        						&& coitem.COLIList[0].Status != 'In Stock' && coitem.COLIList[0].Status != 'Oversold' && coitem.COLIList[0].Qty > 0
        						&& !(coitem.COLIList[0].QtyCommitted > 0 && coitem.COLIList[0].QtyOrder > 0) );
    				});
        			if(index2 > -1){
        				$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_part_error');
        			}
        		
        		} else if($scope.CheckoutInfoModel.InvoiceItemList[i].CheckoutItemType === 'Kit') {
        			var index3 = _.findIndex($scope.M_CO.COKHList, function(coitem) {
        				return ( coitem.Id && coitem.Id === $scope.CheckoutInfoModel.InvoiceItemList[i].ItemId
        						&& (_.findIndex(coitem.COLIList, {'Status': 'Required'}) > -1) );
    				});
        			if(index3 > -1){
        				$scope.CheckoutInfoModel.InvoiceItemList[i].cannotCheckoutError = $translate.instant('CO_checkout_kit_error');
        			}
        		}
        	}
        }

        $scope.F_CO.deleteCustomerOrder = function() {
            CustomerService.deleteCustomerOrder($scope.M_CO.COHeaderId).then(function(response) {
                if (response === 'Success') {
                    Notification.success($translate.instant('Customer_order_delete_success_msg'));
                    loadState($state, 'homePage');
                } else {
                    Notification.error($translate.instant('Customer_order_delete_error_msg'));
                }
            }, function(error) {
                handleErrorAndExecption(error);
            });
        };

        $scope.F_CO.isCustomerOrderClosable = function () {
          // if TotalDepositAmout is Zero, check status of all sections is invoiced
          if(!$scope.M_CO.Deposit.TotalDepositAmout) {
              for(var i=0; i < $scope.M_CO.COKHList.length; i++) {
                for(var j=0; j < $scope.M_CO.COKHList[i].COLIList.length; j++) {
                    if($scope.M_CO.COKHList[i].COLIList[j].Status && $scope.M_CO.COKHList[i].COLIList[j].Status !== "Invoiced") {
                      return false;
                    }
                  }
              }
              for(var i=0; i < $scope.M_CO.SOHeaderList.length; i++) {
                $scope.M_CO.SOHeaderList[i].SOInfo.WorkStatus
                if($scope.M_CO.SOHeaderList[i].SOInfo.WorkStatus && $scope.M_CO.SOHeaderList[i].SOInfo.WorkStatus !== "Invoiced") {
                  return false;
                  }
              }
              if($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealStatus !== "Invoiced") {
                return false;
              }
              return true;
          }
          return false;
        }

        /*Start: Cash Sale Oversold Functionality*/
        $scope.F_CO.showOversoldPopup = function() {
            setTimeout(function() {
                angular.element('#createSpecialOrderActionBtn').focus();
            }, 200);
            angular.element('#OversoldPopUp').modal({
                backdrop: 'static',
                keyboard: false
            });
            $scope.M_CO.isLoading = false;
        }

        $scope.F_CO.closeOversoldPopup = function(isCancelAction) {
            $scope.M_CO.IsNewLineItemInserted = false;
            $scope.M_CO.recentlyAddedLineItem = [];
            $scope.M_CO.isOutOfStockPart = false;
            $scope.M_CO.recentlyUpdatedLineItem  = {};
            $scope.M_CO.cashSaleOutOfStockKitId = null;
            $scope.M_CO.isOpenSelectCustomerSectionForCashSaleSpecialOrder = false;
            angular.element('#OversoldPopUp').modal('hide');
        }

        $scope.F_CO.forceOversoldAction = function() {
            var LineItemList = [];
            if ($scope.M_CO.recentlyUpdatedLineItem && $scope.M_CO.recentlyUpdatedLineItem.Qty) {
              $scope.M_CO.recentlyUpdatedLineItem.QtyCommitted = $scope.M_CO.recentlyUpdatedLineItem.Qty;
                LineItemList.push($scope.M_CO.recentlyUpdatedLineItem);
                var successJson = {
                    'type': 'addCOLineItem'
                };
                $scope.M_CO.isLoading = true;

                // For Non Kit LI
                merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(LineItemList), null).then(new success(successJson).handler, new error().handler);
            } else if ($scope.M_CO.IsNewLineItemInserted) {
              if($scope.M_CO.cashSaleOutOfStockKitId) {
                insertKit($scope.M_CO.cashSaleOutOfStockKitId, true);
                return;
              }
            if($scope.PartSmart.IsAddingFromPartSmart) {
              for(var i = 0; i < $scope.PartSmart.InStockPartList.length; i++) {
                LineItemList.push({
                  Qty: $scope.PartSmart.InStockPartList[i].Qty,
                          PartId: $scope.PartSmart.InStockPartList[i].PartId,
                          Price: $scope.PartSmart.InStockPartList[i].Price,
                          QtyCommitted: $scope.PartSmart.InStockPartList[i].Qty,
                });
              }
            }
            LineItemList.push.apply(LineItemList, $scope.M_CO.recentlyAddedLineItem);
                if ($scope.M_CO.COHeaderId == undefined) {
                    $scope.M_CO.COHeaderId = null;
                }
                var successJson = {
                    'type': 'addCOLineItem',
                    'isAddMode': true
                };
                $scope.M_CO.isLoading = true;
                // For Non Kit LI
                merchandiseService.saveCOLineItem($scope.M_CO.COHeaderId, JSON.stringify(LineItemList), null).then(function(MerchandiseList) {
                  var LineItemListToUpdate = [];
                  if($scope.PartSmart.IsAddingFromPartSmart) {
                    var counter = (MerchandiseList.COKHList.length - LineItemList.length);
                    for(var i = (MerchandiseList.COKHList.length - 1); i >= counter; i--) {
                      if(MerchandiseList.COKHList[i].Id || MerchandiseList.COKHList[i].COLIList[0].EntityType === 'Env Fee') {
                        counter--;
                      } else {
                        for(var j = 0; j < MerchandiseList.COKHList[i].COLIList.length; j++) {
                          if(MerchandiseList.COKHList[i].COLIList[j].PartId && MerchandiseList.COKHList[i].COLIList[j].QtyCommitted < MerchandiseList.COKHList[i].COLIList[j].Qty) {
                            MerchandiseList.COKHList[i].COLIList[j].QtyCommitted = MerchandiseList.COKHList[i].COLIList[j].Qty;
                              LineItemListToUpdate.push(MerchandiseList.COKHList[i].COLIList[j]);
                          }
                          }
                      }
                    }
                  } else {
                      var COKHLength = MerchandiseList.COKHList.length - 1;
                        if(MerchandiseList.COKHList[COKHLength].COLIList[0].EntityType === 'Env Fee') {
                            COKHLength -= 1;
                        }
                        MerchandiseList.COKHList[COKHLength].COLIList[0].QtyCommitted = 1;
                        LineItemListToUpdate.push(MerchandiseList.COKHList[COKHLength].COLIList[0]);
                    }
                    merchandiseService.saveCOLineItem(MerchandiseList.coHeaderRec.COHeaderId, JSON.stringify(LineItemListToUpdate), null).then(new success(successJson).handler, new error().handler);
                }, new error().handler);
            }
        }

        $scope.F_CO.openSelectCustomerSectionForSpecialOrder = function() {
            if (!$scope.M_CO.coHeaderRec.CustomerId) {
              if(!$scope.F_CO.isAddCustomerActionForCashSaleAvailable()) {
                $scope.F_CO.closeOversoldPopup();
                Notification.error($translate.instant('Changing_Customer_After_Invoicing_Error_Message'));
              } else {
                isSwitchingFromCashSale = true;
                $scope.M_CO.isOpenSelectCustomerSectionForCashSaleSpecialOrder = true;
                  angular.element('#OversoldPopUp').modal('hide');
                    openSelectCustomerSection();
              }
            } else {
                createSpecialOrderAction();
            }
        }

        function openSelectCustomerSection() {
          $scope.F_CO.expandedSection('customerSectionId', 'customer');
            $scope.M_CO.sellingGroup = 'Part Sale';
            setTimeout(function() {
              angular.element("#autocompleteCustomer").focus();
            }, 500);
        }

        function insertDefaultCOFormsToSpecificSection(coHeaderId, sectionId) {
          var defer = $q.defer();
          documentService.insertDefaultCOForms(coHeaderId, sectionId).then(function() {
            defer.resolve();
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function getCOFormsBySectionId(sectionId) {
          var defer = $q.defer();
          documentService.getCOFormsBySectionId(sectionId).then(function(sectionIdToFormList) {
            defer.resolve(sectionIdToFormList);
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function getCOAttachmentsBySectionId(sectionId) {
          var defer = $q.defer();
          documentService.getCOAttachmentsBySectionId(sectionId).then(function(sectionIdToAttachmentList) {
            defer.resolve(sectionIdToAttachmentList);
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function getActiveFormsCount() {
          var defer = $q.defer();
          documentService.getActiveFormsCount().then(function(result) {
            defer.resolve(result);
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        $scope.F_CO.addFormsToSection = function(sectionId, sectionName) {
          $scope.M_CO.documents.activeFormList = [];
          $scope.M_CO.documents.sectionIdWhereToAddDoc = sectionId;
          $scope.M_CO.documents.sectionNameWhereToAddDoc = sectionName;
          $scope.M_CO.isLoading = true;
          getActiveFormsBySectionId(sectionId).then(function(activeFormList) {
            $scope.M_CO.isLoading = false;
            if(activeFormList.length) {
              $scope.M_CO.documents.activeFormList = activeFormList;
              openDocumentFormModalWindow();
            } else {
              Notification.error($translate.instant('No_active_form_availabe_for_this_section'));
            }
            }, function(error) {
              $scope.M_LinkedForm.isLoading = false;
                handleErrorAndExecption(error);
            });
        }

        function resetDocumentFormModalWindowData() {
          $scope.M_CO.documents.sectionIdWhereToAddDoc = '';
          $scope.M_CO.documents.sectionNameWhereToAddDoc = ''
          $scope.M_CO.documents.activeFormList = [];
        }
        function getActiveFormsBySectionId(sectionId) {
          var defer = $q.defer();
          documentService.getActiveFormsBySectionId(sectionId).then(function(activeFormList) {
            defer.resolve(activeFormList);
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function openDocumentFormModalWindow() {
          setTimeout(function() {
                angular.element('#documentFormModalWindow').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 100);
        }

        angular.element(document).on("click", "#documentFormModalWindow .modal-backdrop", function() {
          $scope.F_CO.hideDocumentFormModalWindow();
        });

        $scope.F_CO.hideDocumentFormModalWindow = function() {
            angular.element('#documentFormModalWindow').modal('hide');
            resetDocumentFormModalWindowData();
        }

        $scope.F_CO.addSelectedFormsToSpecificSection = function(sectionId, sectionName) {
          $scope.M_CO.isLoading = true;
          var selectedFormList = getSelectedFormsFromDocumentFormModal();
          documentService.addFormsToSection($scope.M_CO.COHeaderId, sectionId, JSON.stringify(selectedFormList)).then(function() {
            getCOFormsBySectionId(sectionId).then(function(formList) {
              bindFormAfterAddAction(sectionId, sectionName, formList);
              $scope.F_CO.hideDocumentFormModalWindow();
              $scope.M_CO.isLoading = false;
                }, function(error) {
                  $scope.M_CO.isLoading = false;
                    handleErrorAndExecption(error);
                });
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
            });
        }

        function bindFormAfterAddAction(sectionId, sectionName, formList) {
          $scope.M_CO.documents.forms[sectionName][sectionId] = formList[sectionId];
          $scope.M_CO.documents.activeForms[sectionName][sectionId] = _.filter($scope.M_CO.documents.forms[sectionName][sectionId], function(rec){ return rec.IsActive; });
          showTooltip('body');
        }

        function getSelectedFormsFromDocumentFormModal() {
          var selectedFormList = [];
          selectedFormList = angular.copy(_.filter($scope.M_CO.documents.activeFormList, function(activeForm){
                 return (activeForm.isSelected === true);
            }));
          return selectedFormList;
        }

        $scope.F_CO.deleteFormsFromSection = function(formId, sectionId, sectionName) {
          $scope.M_CO.isLoading = true;
          documentService.deleteCOForm(formId).then(function() {
            $scope.M_CO.isLoading = false;
            removeFormFromListAfterDeleteAction(formId, sectionId, sectionName);
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
            });
        }

        $scope.F_CO.deleteAttachmentFromSection = function(attachmentId, sectionId, sectionName) {
          $scope.M_CO.isLoading = true;
          documentService.deleteAttachment(attachmentId).then(function() {
            $scope.M_CO.isLoading = false;
            removeAttachmentFromListAfterDeleteAction(attachmentId, sectionId, sectionName);
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
            });
        }

        function removeFormFromListAfterDeleteAction(formId, sectionId, sectionName) {
        var deletedElement = angular.element('#form' + formId + 'Id');
        var formIndex = _.findIndex($scope.M_CO.documents.forms[sectionName][sectionId], {'Id': formId});
          setTimeout(function() {
                if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                    deletedElement.addClass('bp-collapse-deleted-div-transition');
                }
            }, 100);

          setTimeout(function() {
            $scope.M_CO.documents.forms[sectionName][sectionId].splice(formIndex, 1);
            var activeFormIndex = _.findIndex($scope.M_CO.documents.activeForms[sectionName][sectionId], {'Id': formId});
            if(activeFormIndex != -1) {
              $scope.M_CO.documents.activeForms[sectionName][sectionId].splice(activeFormIndex, 1);
            }
                showTooltip('body');
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply(); //TODO
                }
            }, 600);
        }

        function removeAttachmentFromListAfterDeleteAction(attachmentId, sectionId, sectionName) {
        var deletedElement = angular.element('#attachment' + attachmentId + 'Id');
        var attachmentIndex = _.findIndex($scope.M_CO.documents.attachments[sectionName][sectionId], {'Id': attachmentId});
          setTimeout(function() {
                if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
                    deletedElement.addClass('bp-collapse-deleted-div-transition');
                }
            }, 100);

          setTimeout(function() {
            $scope.M_CO.documents.attachments[sectionName][sectionId].splice(attachmentIndex, 1);
                showTooltip('body');
                if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                    $scope.$apply(); //TODO
                }
            }, 600);
        }

        $scope.F_CO.printDocument = function(docUrl, coFormId, isEditable, formEditConfig, editModalName) {
          if(!docUrl) {
            return;
          }
          // Generate Editable PDF Form
          if(isEditable && coFormId && formEditConfig && editModalName) {
            var dataModalJson ={};
            if(editModalName === "NEW DEAL UNIT") {
              getDealNewUnitDataJson().then(function(dataModalJson) {
                $scope.F_CO.exportCOFormToPdf(coFormId, JSON.parse(formEditConfig), dataModalJson, dataModalJson["CustomerOrderNumber"] || "");
              });
            } else if(editModalName === "USED DEAL UNIT") {
              getDealUsedUnitDataJson().then(function(dataModalJson) {
                $scope.F_CO.exportCOFormToPdf(coFormId, JSON.parse(formEditConfig), dataModalJson, dataModalJson["CustomerOrderNumber"] || "");
              });
            }
          } else {
            var origin = window.location.origin;
            var url = origin + docUrl;
            window.open(url, '_blank');
          }
        }

        /*Start: Internal Comment*/
        function getInternalCommentList(coHeaderId) {
          var defer = $q.defer();
          internalCommentService.getInternalCommentList(coHeaderId).then(function(internalCommentList) {
            $scope.M_CO.internalCommentList = internalCommentList;
            for(var i=0;i<$scope.M_CO.internalCommentList.length;i++) {
              $scope.M_CO.internalCommentList[i].isEditMode = false;
            }
            defer.resolve();
          }, function(error) {
            defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        $scope.F_CO.isCreateInternalCommentActionAvailable = function() {
          if($scope.M_CO.COHeaderId && $scope.M_CO.coHeaderRec.OrderStatus !== 'Closed' && $scope.M_CO.internalCommentList.length == 0 && !$scope.M_CO.showInternalCommentsSection) {
            return true;
          }
          return false;
        }

        $scope.F_CO.createInternalCommentsSection = function() {
          $scope.M_CO.showInternalCommentsSection = true;
          $scope.F_CO.createAddNewCommentSection();
            setTimeout(function() {
            $scope.F_CO.expandOrCollapseSection('InternalCommentsSectionId','InternalComments');
          }, 10);
          setTimeout(function() {
            $(".comment-section textarea").focus();
            }, 100);
        }

        function removeInternalCommentsSection() {
          $scope.M_CO.showInternalCommentsSection = false;
          $scope.F_CO.removeAddNewCommentSection();
          $scope.F_CO.cancelEditInternalCommentAction();

          $scope.F_CO.expandOrCollapseSection('InternalCommentsSectionId','InternalComments');
        }
        $scope.F_CO.createAddNewCommentSection = function() {
          for(var i=0;i<$scope.M_CO.internalCommentList.length;i++) {
            $scope.M_CO.internalCommentList[i].isEditMode = false;
          }
          $scope.M_CO.addNewComment = true;
          $scope.M_CO.internalComment = {};
          $scope.M_CO.isInternalCommentError = false;
          $scope.M_CO.addNewInternalCommentDisable = true;
          setTimeout(function(){
              angular.element("#addnewInternalComment").focus();
          },10);

        }

        $scope.F_CO.removeAddNewCommentSection = function() {
          $scope.M_CO.addNewComment = false;
          $scope.M_CO.internalComment = {};
          $scope.M_CO.isInternalCommentError = false;
          $scope.M_CO.addNewInternalCommentDisable = false;
        }

      $scope.F_CO.editInternalComment = function(index) {
          if($scope.M_CO.addNewComment) {
            $scope.F_CO.removeAddNewCommentSection();
          }
          var internalCommentIndex = _.findIndex($scope.M_CO.internalCommentList, {'isEditMode': true});
          if(internalCommentIndex == -1 || internalCommentIndex != index) {
            for(var i=0;i<$scope.M_CO.internalCommentList.length;i++) {
               $scope.M_CO.internalCommentList[i].isEditMode = false;

            }
              $scope.M_CO.internalComment = angular.copy($scope.M_CO.internalCommentList[index]);
              $scope.M_CO.internalCommentList[index].isEditMode = true;
              $scope.M_CO.isInternalCommentError = false;
              $scope.M_CO.addNewInternalCommentDisable = true;
              setTimeout(function(){
                   angular.element("#commentTextArea_"+index).focus();
              },10);

          }
        }

        $scope.F_CO.cancelEditInternalCommentAction = function() {
          for(var i=0;i<$scope.M_CO.internalCommentList.length;i++) {
            $scope.M_CO.internalCommentList[i].isEditMode = false;
          }

          $scope.M_CO.internalComment = {};
          $scope.M_CO.isInternalCommentError = false;
          $scope.M_CO.addNewInternalCommentDisable = false;
        }

        $scope.F_CO.saveInternalComment = function(internalCommentJson,index,event) {
          if($(clicky).closest('#cancelInternalComment').length || $(clicky).closest('#cancelInternalComment_' + index).length
              || $(clicky).closest('#deleteInternalComment_' + index).length) {
            clicky = null;
            return;
          }

          internalCommentJson.CoHeaderId = $scope.M_CO.COHeaderId;
          if(!internalCommentJson.Comment) {
            $scope.M_CO.isInternalCommentError = true;
            if(!$(clicky).closest('#deleteInternalComment_' + index).length && !$(clicky).closest('#saveInternalComment_' + index).length &&
              !$(clicky).closest('#postInternalComment').length &&  !$(clicky).closest('#editInternalComment_'+ index).length ) {
                $scope.F_CO.removeAddNewCommentSection();
               $scope.F_CO.cancelEditInternalCommentAction();
              clicky = null;

            }
            return;
          }

          $scope.M_CO.isLoading = true;
          internalCommentService.saveInternalComment(angular.toJson(internalCommentJson)).then(function() {
            // Get CO Internal Comments
                getInternalCommentList($scope.M_CO.COHeaderId).then(function() {
                  showTooltip('body');
                  $scope.M_CO.isLoading = false;
                  $scope.F_CO.removeAddNewCommentSection();
                  $scope.F_CO.cancelEditInternalCommentAction();
                }, function(error) {
                  $scope.M_CO.isLoading = false;
                    handleErrorAndExecption(error);
                });
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
            });
        }
		
		$scope.F_CO.openCloseDetailSectionAndAddItemSection = function(index,event) {
			$scope.F_CO.expandOrCollapseInnerSection('ServiceJob'+index+'_DetailsSectionId', 'ServiceJob'+index+'_Details','','',event);
			$scope.F_CO.expandOrCollapseInnerSection('ServiceJob'+index+'_JobItemsSectionId', 'ServiceJob'+index+'_JobItems')
		}

        $scope.F_CO.deleteInternalComment = function(internalCommentId) {
            $scope.M_CO.isLoading = true;
            internalCommentService.deleteInternalComment(internalCommentId).then(function() {
              $scope.M_CO.isLoading = false;
              $scope.M_CO.isInternalCommentError = false;
                removeInternalCommentFromListAfterDeleteAction(internalCommentId);
                showTooltip('body');
            }, function(error) {
                $scope.M_CO.isLoading = false;
                handleErrorAndExecption(error);
            });
      }

        function removeInternalCommentFromListAfterDeleteAction(internalCommentId) {
          var deletedElement = angular.element('#comment' + internalCommentId + 'Id');
          var internalCommentIndex = _.findIndex($scope.M_CO.internalCommentList, {'Id': internalCommentId});
          setTimeout(function() {
            if (deletedElement != undefined && deletedElement != null && deletedElement != '') {
              deletedElement.addClass('bp-collapse-deleted-div-transition');
            }
          }, 100);

          setTimeout(function() {
            if(internalCommentIndex > -1){
              $scope.M_CO.internalCommentList.splice(internalCommentIndex, 1);
              if(!$scope.M_CO.internalCommentList.length) {
                removeInternalCommentsSection();
              }
            }
            showTooltip('body');
            if ($scope.$root.$$phase != '$apply' && $scope.$root.$$phase != '$digest') {
                  $scope.$apply(); //TODO
            }
          }, 600);
           $scope.M_CO.addNewInternalCommentDisable = false;
        }
        /*End: Internal Comment*/

        /*Start: Appointments*/
        function getAppointmentsBySectionId(sectionId) {
          var defer = $q.defer();
          coAppointmentService.getAppointmentsBySectionId(sectionId).then(function(sectionIdToAppointmentList) {
            defer.resolve(sectionIdToAppointmentList);
          }, function(error) {
            defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

        function updateAppointmentsOnCustomerOrSOFieldsChange(sectionId, sectionName) {
          updateAppointmentsBySectionId(sectionId).then(function() {
              getAppointmentsBySectionId(sectionId).then(function(sectionIdToAppointmentList) {
                  if(sectionName === 'All_SO') {
                    angular.forEach($scope.M_CO.SOHeaderList, function(soHeader) {
                      $scope.M_CO.soAppointments[soHeader.SOInfo.Id] = sectionIdToAppointmentList[soHeader.SOInfo.Id];
                        });
                  } else {
                    $scope.M_CO.soAppointments[sectionId] = sectionIdToAppointmentList[sectionId];
                  }
                  showTooltip('body');
                }, function(error) {
                    handleErrorAndExecption(error);
                });
            }, function(error) {
                handleErrorAndExecption(error);
            });
        }

        function updateAppointmentsBySectionId(sectionId) {
          var defer = $q.defer();
          coAppointmentService.updateAppointmentsBySectionId(sectionId).then(function() {
            defer.resolve();
          }, function(error) {
            defer.reject($translate.instant('GENERIC_ERROR'));
            });
          return defer.promise;
        }

         $scope.$on('reloadAppontmentOnCustomerOrder', function(event,args) {
            // Get CO Events/Appointments
            var soIndex = 0;
            getAppointmentsBySectionId(args.SOHeaderId).then(function(sectionIdToAppointmentList) {
                 $scope.M_CO.soAppointments[args.SOHeaderId] = sectionIdToAppointmentList[args.SOHeaderId];
                 for(var i=0; i<$scope.M_CO.SOHeaderList.length;i++) {
                  if(args.SOHeaderId == $scope.M_CO.SOHeaderList[i].SOInfo.Id) {
                      soIndex = i;
                      break;
                  }
                 }
                 $scope.M_CO.SOHeaderList[soIndex].SOInfo.ManualConcern = args.ManualConcern;
                 $scope.M_CO.SOHeaderList[soIndex].SOInfo.Name = sectionIdToAppointmentList[args.SOHeaderId].Title;
         $scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitName = args.Unitname;
                 $scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitId = args.UnitId;
                 showTooltip('body');
            }, function(error) {
                handleErrorAndExecption(error);
            });
        });


          $scope.F_CO.openAddEditAppointment = function(AppointmentStatr, SOId, soInfo, soHeaderIndex, eventJson) {
          var appointmentSoInfoJson = {
              "selectedJobTypeLabel" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionTypeLabel,
              "selectedJobTypeId" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionTypeId,
              "selectedTransactionType" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.TransactionType,
              "Title" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.Name,
              "Concern" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.ManualConcern,
              "CONumber": $scope.M_CO.coHeaderRec.OrderName,
               "serviceJobIndex" : soHeaderIndex,
              "KitHeaderConcern" : $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.KitHeaderConcern
          }
          var AddEditAppointmentParams;
          if(eventJson) {
            AddEditAppointmentParams = {
                    'SoInfo':angular.copy(appointmentSoInfoJson),
                    'eventJson' : angular.copy(eventJson)
            }
          } else {
            appointmentSoInfoJson.SOHeaderId = SOId;
            appointmentSoInfoJson.COId = $scope.M_CO.COHeaderId;
            appointmentSoInfoJson.COUId = $scope.M_CO.SOHeaderList[soHeaderIndex].SOInfo.UnitId;
            appointmentSoInfoJson.CusotmerId = $scope.M_CO.coHeaderRec.CustomerId;
            appointmentSoInfoJson.estimatedHours = 1;
            AddEditAppointmentParams = {'SoInfo': angular.copy(appointmentSoInfoJson)};
            }
            loadState($state, AppointmentStatr, {AddEditAppointmentParams: AddEditAppointmentParams})
      }
       /*End: Appointments*/

          /*Start: Get Applicable Tax*/
          function getApplicableTaxList() {
            var defer = $q.defer();
            coCommonService.getApplicableTaxList().then(function(applicableSalesTaxList) {
              $scope.M_CO.applicableSalesTaxList = applicableSalesTaxList ? applicableSalesTaxList.SalesTaxList : [];
              defer.resolve($scope.M_CO.applicableSalesTaxList);
            }, function(error) {
              defer.reject($translate.instant('GENERIC_ERROR'));
              });
            return defer.promise;
          }
          /*End: Get Applicable Tax*/

          $scope.F_CO.keyPressNavigationOnDropdownElements = function(event, dropdownDivId, templateName, dropdownList) {
              var keyCode = event.which ? event.which : event.keyCode;
              var tempList = angular.copy(dropdownList);
              var dropDownDivId = '#' + dropdownDivId;
              var idSubStr = '';
              var totalRecordsToTraverse = 0;
              if (tempList) {
                  totalRecordsToTraverse += tempList.length;
              }

              if (keyCode == 40 && totalRecordsToTraverse > 0) {
                  if (totalRecordsToTraverse - 1 > $scope.M_CO.currentDropDownIndex) {
                      $scope.M_CO.currentDropDownIndex++;
                      if (templateName == 'tradeInSalesTaxRec') {
                          idSubStr = '#tradeInSalesTaxRec_';
                      } else if (templateName == 'dealUnitSalesTaxRec') {
                          idSubStr = '#dealUnitSalesTaxRec_';
                      } else if (templateName == 'tradeInFinanceCompany') {
                          idSubStr = '#tradeInFinanceCompany_';
                       } else if(templateName == 'cashDrawer') {
                          idSubStr = '#cashDrawer_';
                      }
                      angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_CO.currentDropDownIndex)[0].offsetTop - 100;
                  }
              } else if (keyCode === 38) {
                  if ($scope.M_CO.currentDropDownIndex > 0) {
                      $scope.M_CO.currentDropDownIndex--;
                      if (templateName == 'tradeInSalesTaxRec') {
                          idSubStr = '#tradeInSalesTaxRec_';
                      } else if (templateName == 'dealUnitSalesTaxRec') {
                          idSubStr = '#dealUnitSalesTaxRec_';
                      } else if (templateName == 'tradeInFinanceCompany') {
                          idSubStr = '#tradeInFinanceCompany_';
                      } else if(templateName == 'cashDrawer') {
                          idSubStr = '#cashDrawer_';
                      }
                      angular.element(dropDownDivId)[0].scrollTop = angular.element(idSubStr + $scope.M_CO.currentDropDownIndex)[0].offsetTop - 100;
                  }
              } else if (keyCode == 13 && $scope.M_CO.currentDropDownIndex !== -1) {
                  if(templateName == 'tradeInSalesTaxRec' || templateName == 'dealUnitSalesTaxRec') {
                    $scope.F_CO.selcectDealItemSalesTax(tempList[$scope.M_CO.currentDropDownIndex]);
                  } else if(templateName == 'tradeInFinanceCompany') {
                    $scope.F_CO.TradeIn.selectDealItemFinanceCompany(tempList[$scope.M_CO.currentDropDownIndex]);
                  } else if(templateName == 'cashDrawer') {
                    $scope.F_CO.selectCashDrawer($scope.M_CO.cashDrawerList[$scope.M_CO.currentDropDownIndex]);
                  }
                  $scope.M_CO.currentDropDownIndex = -1;
              }
          }

          $scope.F_CO.setDealApplicableTaxDefaultDataOnFocus = function(dealItemId, dealItemIndex, dealItemSectionName, IsTaxable) {
            $scope.M_CO.dealApplicableTaxDefaultData = {};
            $scope.M_CO.dealApplicableTaxDefaultData.dealItemId = dealItemId;
            $scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex = dealItemIndex;
            $scope.M_CO.dealApplicableTaxDefaultData.dealItemSectionName = dealItemSectionName;
            $scope.M_CO.dealApplicableTaxDefaultData.IsTaxable = IsTaxable;
         }

          $scope.F_CO.hideDropdown = function() {
            $scope.M_CO.currentDropDownIndex = -1;
         }

         $scope.F_CO.selcectDealItemSalesTax = function(salesTaxRec) {
           if( $scope.M_CO.dealApplicableTaxDefaultData.dealItemSectionName === 'unit') {
              $scope.M_CO.Deal.UnitList[$scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex].DealItemObj.ApplicableTaxName = salesTaxRec.Name;
              $scope.M_CO.Deal.UnitList[$scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex].DealItemObj.ApplicableTaxId = salesTaxRec.Id;
           } else if( $scope.M_CO.dealApplicableTaxDefaultData.dealItemSectionName === 'tradeIn') {
             $scope.M_CO.Deal.TradeInsList[$scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex].ApplicableTaxName = salesTaxRec.Name;
             $scope.M_CO.Deal.TradeInsList[$scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex].ApplicableTaxId = salesTaxRec.Id;
           }
           $scope.F_CO.saveDealItemTaxInfo($scope.M_CO.dealApplicableTaxDefaultData.IsTaxable, salesTaxRec.Id, $scope.M_CO.dealApplicableTaxDefaultData.dealItemId,
               $scope.M_CO.dealApplicableTaxDefaultData.dealItemIndex, $scope.M_CO.dealApplicableTaxDefaultData.dealItemSectionName);
           $scope.F_CO.hideDropdown();
         }

         $scope.F_CO.saveDealItemTaxInfo = function(IsTaxable, ApplicableTaxId, dealItemId, dealItemIndex, dealItemType) {
           var dealItemTaxInfoJson = {
               'IsTaxable': IsTaxable,
               'ApplicableTaxId': ApplicableTaxId,
               'Id': dealItemId
           }
           $scope.M_CO.isLoading = true;
           DealService.saveDealItemTaxInfo(angular.toJson(dealItemTaxInfoJson)).then(function() {
             if ($scope.M_CO.Deal.DealInfo) {
               $scope.F_CO.getAndUpdateDealAndDealItemTotals(dealItemIndex, dealItemType, dealItemId);
                 } else {
                   $scope.M_CO.isLoading = false;
                 }
           }, function(error) {
             $scope.M_CO.isLoading = false;
             handleErrorAndExecption(error);
            });
         }


         $scope.F_CO.getAndUpdateDealAndDealItemTotals = function(dealItemIndex, dealItemType, dealItemId) {
           var defer = $q.defer();
             $scope.M_CO.isLoading = true;
           $q.all([getAndUpdateDealTotals(),
               getDealItemDetails(dealItemIndex, dealItemType, dealItemId)]).then(function() {
                 $scope.M_CO.isLoading = false;
                     defer.resolve();
             }, function(error) {
               $scope.M_CO.isLoading = false;
               defer.reject($translate.instant('GENERIC_ERROR'));
             });
           return defer.promise;
         }

         function getAndUpdateDealTotals() {
           var defer = $q.defer();
           DealService.getDealDetails($scope.M_CO.Deal.DealInfo.Id, 'dealInfo').then(function(successResult) {
               var successJson = {
                         'type': 'getDealTotalInfo'
                 }
               new success(successJson).handler(successResult);
               defer.resolve();
             }, function(error) {
               handleErrorAndExecption(error);
               defer.reject($translate.instant('GENERIC_ERROR'));
             });
           return defer.promise;
         }

         function getDealItemDetails(dealItemIndex, dealItemType, dealItemId) {
           var defer = $q.defer();
           DealService.getDealItemDetails(dealItemId).then(function(successResult) {
             handleGetDealItemDetailsRespose(dealItemIndex, dealItemType, successResult);
               defer.resolve();
             }, function(error) {
               handleErrorAndExecption(error);
               defer.reject($translate.instant('GENERIC_ERROR'));
             });
           return defer.promise;
         }

         function handleGetDealItemDetailsRespose(dealItemIndex, dealItemType, dealItemRec) {
           if(dealItemType === 'unit') {
           $scope.M_CO.Deal.UnitList[dealItemIndex] = dealItemRec;
             setTimeout(function() {
                     if ($scope.M_CO.Deal.UnitList.length > 0) {
                         $scope.M_CO.expandedInner2DivFlag = false;
                         $scope.M_CO.expandedInnerDivFlag = false;
                         $scope.M_CO.expandedDivFlag = false;
                         $scope.F_CO.expandInner2Section('Deal_DU' + (dealItemIndex) + '_InfoSectionId', 'Deal_DU' + (dealItemIndex) + '_Info');
                         $scope.F_CO.expandInnerSection('Deal_DU' + (dealItemIndex) + '_SectionId', 'Deal_DU' + (dealItemIndex));
                         $scope.F_CO.expandedSection('Deal_SectionId', 'Deal');
                     }
                 }, 100);
         } else if(dealItemType === 'tradeIn') {
           $scope.M_CO.Deal.TradeInsList[dealItemIndex] = dealItemRec;
         }
         showTooltip('body');
         }

         function getActiveCOUList() {
           SOHeaderService.getActiveCOUList($scope.M_CO.coHeaderRec.CustomerId).then(function(couList) {
             $scope.M_CO.COUList = couList;
           }, function(error) {
                Notification.error(error);
           });
         }

         $scope.F_CO.TradeIn.saveLienPayout = function(lienPayout, tradeInIndex) {
           if(!lienPayout || lienPayout == 0) {
             $scope.M_CO.Deal.TradeInsList[tradeInIndex].FinanceCompanyId = null;
             $scope.M_CO.Deal.TradeInsList[tradeInIndex].FinanceCompanyName = null;
           }
           saveTradeInfo(tradeInIndex, true);
         }

         $scope.F_CO.selectDealItemFinanceCompany = function(financeCompany, delaItemType, dealItemIndex) {
           if(delaItemType === 'tradeIn') {
             $scope.M_CO.Deal.TradeInsList[dealItemIndex].FinanceCompanyName = financeCompany.Name;
             $scope.M_CO.Deal.TradeInsList[dealItemIndex].FinanceCompanyId = financeCompany.Id;
             saveTradeInfo(dealItemIndex, true);
           }
         }

         $scope.M_CO.isTradeInFinanceCompanyNotSelected = function() {
           var isTradeInFinanceCompanyNotSelected = false;
           for(var i=0; i<$scope.M_CO.Deal.TradeInsList.length; i++) {
            if(($scope.M_CO.Deal.TradeInsList[i].LienPayout && $scope.M_CO.Deal.TradeInsList[i].LienPayout > 0)
                && !$scope.M_CO.Deal.TradeInsList[i].FinanceCompanyId) {
              isTradeInFinanceCompanyNotSelected = true;
              break;
            }
          }
           return isTradeInFinanceCompanyNotSelected;
         }

         $scope.M_CO.disableDealItemEdit = function() {
           if(!$rootScope.GroupOnlyPermissions['Deal']['create/modify'] || $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced'
              || $scope.M_CO.Deal.DealInfo.DealStatus === 'Approved') {
             return true;
           } else {
             return false;
           }
         }

        function createSpecialOrderAction(coHeaderId) {
          var defer = $q.defer();
          var COHeaderId = coHeaderId ? coHeaderId : ($scope.M_CO.COHeaderId ? $scope.M_CO.COHeaderId : null);
          if($scope.M_CO.cashSaleOutOfStockKitId) {
          merchandiseService.insertKitHeaderInMerchGrid($scope.M_CO.cashSaleOutOfStockKitId, COHeaderId).then(function(result) {
            $scope.F_CO.closeOversoldPopup();
            defer.resolve(result);
          }, function(error) {
                  Notification.error(error);
                  defer.reject($translate.instant('Error in adding kit'));
              });
          return defer.promise;
          }
            var LineItemList = [];
            if ($scope.M_CO.recentlyUpdatedLineItem && $scope.M_CO.recentlyUpdatedLineItem.Qty) {
              $scope.M_CO.recentlyUpdatedLineItem.QtyCommitted = $scope.M_CO.recentlyUpdatedLineItem.ActualAvailableParts;
              LineItemList.push($scope.M_CO.recentlyUpdatedLineItem);
            } else {
              if($scope.PartSmart.IsAddingFromPartSmart) {
              for(var i = 0; i < $scope.PartSmart.InStockPartList.length; i++) {
                LineItemList.push({
                  Qty: $scope.PartSmart.InStockPartList[i].Qty,
                          PartId: $scope.PartSmart.InStockPartList[i].PartId,
                          Price: $scope.PartSmart.InStockPartList[i].Price,
                          QtyCommitted: $scope.PartSmart.InStockPartList[i].Qty,
                });
              }
            } else {
                $scope.M_CO.recentlyAddedLineItem[0].Qty = 1;
                }
            LineItemList.push.apply(LineItemList, $scope.M_CO.recentlyAddedLineItem);
            }

            merchandiseService.saveCOLineItem(COHeaderId, JSON.stringify(LineItemList), null).then(function(MerchandiseList) {
              $scope.F_CO.closeOversoldPopup();
              defer.resolve(MerchandiseList);
            }, function(error) {
                Notification.error(error);
                defer.reject($translate.instant('Error in creating Special Order'));
            });
            return defer.promise;
        }
        /*End: Cash Sale Oversold Functionality*/

        if ($stateParams.Id) {
            if ($rootScope.$previousState && ($rootScope.$previousState.name === 'CustomerOrder_V2' && !$rootScope.$previousStateParams.Id) || $rootScope.$previousState.name === 'AddEditUnitV2') {
                $scope.M_CO.isReload = true;
            }
            if ($stateParams.myParams != undefined && $stateParams.myParams.DummyAccordion != undefined) {
                $scope.M_CO.DummyAccordion = $stateParams.myParams.DummyAccordion;
            } else {
                $scope.M_CO.DummyAccordion = '';
            }
            if ($stateParams.myParams != undefined && $stateParams.myParams.IsShowMerchandiseSection != undefined) {
              $scope.M_CO.IsShowMerchandiseSection = $stateParams.myParams.IsShowMerchandiseSection;
            }

            if ($stateParams.myParams != undefined && $stateParams.myParams.isCompleteLoad != undefined) {
              $scope.M_CO.isCompleteLoad = $stateParams.myParams.isCompleteLoad;
            }
            if ($stateParams.myParams != undefined && $stateParams.myParams.PartsmartItemsNotFound != undefined) {
                PartNotFoundList = $stateParams.myParams.PartsmartItemsNotFound;
            }
            if ($stateParams.myParams != undefined && $stateParams.myParams.IsFromPartSmart != undefined) {
              $scope.PartSmart.IsAddingFromPartSmart = $stateParams.myParams.IsFromPartSmart;
            }
            if ($stateParams.myParams != undefined && $stateParams.myParams.AppointmentId != undefined) {
              $scope.M_CO.AppointmentId = $stateParams.myParams.AppointmentId;
            }

            $scope.F_CO.getCOHeaderDetailsByGridName();
        } else if ($stateParams.AppointmentId){
          setCOAppointmentData($stateParams.AppointmentId);
        } else if($rootScope.CustomerOrder_V2Parms && $rootScope.CustomerOrder_V2Parms.AppointmentId) {
           loadState($state, 'CustomerOrder_V2', {
              AppointmentId: $rootScope.CustomerOrder_V2Parms.AppointmentId
             });
        }else {
          $scope.M_CO.isCompleteLoad = true;
            $scope.M_CO.isLoading = false;
        }

        function setCOAppointmentData(AppointmentId) {
          $scope.F_CO.expandedSection('customerSectionId', 'customer');
            $scope.M_CO.sellingGroup = 'Service Order';
            $scope.M_CO.DummyAccordion = 'Service Job';
            $scope.M_CO.IsShowMerchandiseSection = false;
            $scope.M_CO.AppointmentId = AppointmentId;
            $scope.M_CO.isCompleteLoad = true;
            $scope.M_CO.isLoading = false;
        }
        function createUnitCardInfoPayload(unitIndex) {
          $scope.M_CO.isLoading = false;
          if($scope.M_CO.Deal && $scope.M_CO.Deal.UnitList) {
            if(typeof unitIndex !== 'undefined') {
              var primaryImageURL = '';
              var obj = {};
              if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitId]) {
                  primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitId].AttchmentURL;
                } else {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitId] = {};
                }
              }
              if($scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.Status == 'On Order') {
                    $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitId]['unitCardInfoPayload'] = {
                                headerText: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.FormattedName,
                                hyperlinkActionVisible: $scope.GroupOnlyPermissions['Deal']['create/modify'] && $scope.F_CO.isDealActionEnable() && !$scope.F_CO.isCommitAndInstallActionDone(),
                                unitImage: primaryImageURL,
                                carouselId: "#carousel-modal-co",
                                hyperlinktext: $translate.instant('Replace_unit'),
                                primaryFields: [{
                                    Label: $translate.instant('Label_VIN'),
                                    Value: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.VIN
                                }, {
                                    Label: $translate.instant('Order Number'),
                                    Value: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitNumber
                                }]
                            }
                  }else {
                       $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.UnitId]['unitCardInfoPayload'] = {
                          headerText: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.FormattedName,
                          hyperlinkActionVisible: $scope.GroupOnlyPermissions['Deal']['create/modify'] && $scope.F_CO.isDealActionEnable() && !$scope.F_CO.isCommitAndInstallActionDone(),
                          unitImage: primaryImageURL,
                          carouselId: "#carousel-modal-co",
                          hyperlinktext: $translate.instant('Replace_unit'),
                          primaryFields: [{
                              Label: $translate.instant('Label_VIN'),
                              Value: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.VIN
                          }, {
                              Label: $translate.instant('Stock_number'),
                              Value: $scope.M_CO.Deal.UnitList[unitIndex].DealItemObj.StockNumber
                           }]
                      }
                  }


            } else {
              for(var UnitIndex=0; UnitIndex < $scope.M_CO.Deal.UnitList.length; UnitIndex++) {
                  var primaryImageURL = '';
                  var obj = {};
                  if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                    if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitId]) {
                      primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitId].AttchmentURL;
                    } else {
                      $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitId] = {};
                    }
                  }
                  if($scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.Status == 'On Order') {
                    $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitId]['unitCardInfoPayload'] = {
                                headerText: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.FormattedName,
                                hyperlinkActionVisible: $scope.GroupOnlyPermissions['Deal']['create/modify'] && $scope.F_CO.isDealActionEnable() && !$scope.F_CO.isCommitAndInstallActionDone(),
                                unitImage: primaryImageURL,
                                carouselId: "#carousel-modal-co",
                                hyperlinktext: $translate.instant('Replace_unit'),
                                primaryFields: [{
                                    Label: $translate.instant('Label_VIN'),
                                    Value: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.VIN
                                }, {
                                    Label: $translate.instant('Order Number'),
                                    Value: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitNumber
                                }]
                            }
                  } else {
                    $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.UnitId]['unitCardInfoPayload'] = {
                                headerText: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.FormattedName,
                                hyperlinkActionVisible: $scope.GroupOnlyPermissions['Deal']['create/modify'] && $scope.F_CO.isDealActionEnable() && !$scope.F_CO.isCommitAndInstallActionDone(),
                                unitImage: primaryImageURL,
                                carouselId: "#carousel-modal-co",
                                hyperlinktext: $translate.instant('Replace_unit'),
                                primaryFields: [{
                                    Label: $translate.instant('Label_VIN'),
                                    Value: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.VIN
                                }, {
                                    Label: $translate.instant('Stock_number'),
                                    Value: $scope.M_CO.Deal.UnitList[UnitIndex].DealItemObj.StockNumber
                                }]
                            }
                  }
                }
            }
          }
        }

        function createTradeInUnitCardInfoPayload(unitIndex) {
          $scope.M_CO.isLoading = false;
          if($scope.M_CO.Deal && $scope.M_CO.Deal.TradeInsList && $scope.M_CO.Deal.TradeInsList.length > 0) {
            if(typeof unitIndex !== 'undefined') {
              var primaryImageURL;
              var obj = {};
              if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[unitIndex].UnitId]) {
                  primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[unitIndex].UnitId].AttchmentURL;
                } else {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[unitIndex].UnitId] = {};
                }
              }
              $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[unitIndex].UnitId]['unitCardInfoPayload'] = {
                      unitStatus: $scope.M_CO.Deal.TradeInsList[unitIndex].IsSctockedIn ? $translate.instant('Label_Stocked_In') : '',
                      headerText: $scope.M_CO.Deal.TradeInsList[unitIndex].FormattedName,
                      unitImage: primaryImageURL,
                      carouselId: "#carousel-modal-co",
                      hyperlinktext: $translate.instant('Replace_unit'),
                      hyperlinkActionVisible: !$scope.M_CO.disableDealItemEdit() && $scope.F_CO.isDealActionEnable() && !$scope.M_CO.Deal.TradeInsList[unitIndex].IsSctockedIn,
                      primaryFields: [{
                          Label: $translate.instant('Label_VIN'),
                          Value: $scope.M_CO.Deal.TradeInsList[unitIndex].VIN
                      }, {
                          Label: $translate.instant('Unit_ID'),
                          Value: $scope.M_CO.Deal.TradeInsList[unitIndex].UnitNumber
                      }]
              }
            } else {
              for(var UnitIndex=0; UnitIndex < $scope.M_CO.Deal.TradeInsList.length; UnitIndex++) {
                var primaryImageURL = '';
                var obj = {};
                if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                  if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[UnitIndex].UnitId]) {
                    primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[UnitIndex].UnitId].AttchmentURL;
                  } else {
                    $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[UnitIndex].UnitId] = {};
                  }
                }

                $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.Deal.TradeInsList[UnitIndex].UnitId]['unitCardInfoPayload'] = {
                  unitStatus: $scope.M_CO.Deal.TradeInsList[UnitIndex].IsSctockedIn ? $translate.instant('Label_stocked_in') : '',
                      headerText: $scope.M_CO.Deal.TradeInsList[UnitIndex].FormattedName,
                      unitImage: primaryImageURL,
                      carouselId: "#carousel-modal-co",
                      hyperlinktext: $translate.instant('Replace_unit'),
                      hyperlinkActionVisible: !$scope.M_CO.disableDealItemEdit() && $scope.F_CO.isDealActionEnable() && !$scope.M_CO.Deal.TradeInsList[UnitIndex].IsSctockedIn,
                      primaryFields: [{
                          Label: $translate.instant('Label_VIN'),
                          Value: $scope.M_CO.Deal.TradeInsList[UnitIndex].VIN
                      }, {
                          Label: $translate.instant('Unit_ID'),
                          Value: $scope.M_CO.Deal.TradeInsList[UnitIndex].UnitNumber
                      }]
                  }
              }
            }
          }
        }

        function createInternalServiceUnitCardInfoPayload(soIndex) {
          $scope.M_CO.isLoading = false;
          if($scope.M_CO.coHeaderRec.COType !== 'Internal Service') {
            return;
          }
          if($scope.M_CO.SOHeaderList &&  $scope.M_CO.SOHeaderList.length > 0) {
            if(typeof soIndex !== 'undefined') {
              var primaryImageURL = '';
              var obj = {};
              if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitId]) {
                  primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitId].AttchmentURL;
                } else {
                  $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitId] = {};
                }
              }
              $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitId]['unitCardInfoPayload'] = {
                  headerText: $scope.M_CO.SOHeaderList[soIndex].SOInfo.UnitName,
                      unitImage: primaryImageURL,
                      hyperlinkActionVisible: !$scope.M_CO.isServiceJobDisabled(soIndex) && !$scope.M_CO.SOHeaderList[soIndex].SOInfo.DealId,
                      hyperlinktext: $translate.instant('Replace_unit'),
                      carouselId: "#carousel-modal-co",
                      primaryFields: [{
                          Label: $translate.instant('Label_VIN'),
                          Value: $scope.M_CO.SOHeaderList[soIndex].SOInfo.VIN
                      }, {
                          Label: $translate.instant('Stock_number'),
                          Value: $scope.M_CO.SOHeaderList[soIndex].SOInfo.StockId
                      }]
              }
            } else {
              for(var SOIndex=0; SOIndex < $scope.M_CO.SOHeaderList.length; SOIndex++) {
                if($scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitId || $scope.M_CO.SOHeaderList[SOIndex].SOInfo.DealId) {
                  var primaryImageURL = '';
                    var obj = {};
                    if($scope.M_CO.unitIdToUnitImagesJsonMap) {
                      if($scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitId]) {
                        primaryImageURL = $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitId].AttchmentURL;
                      } else {
                        $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitId] = {};
                      }
                    }
                    $scope.M_CO.unitIdToUnitImagesJsonMap[$scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitId]['unitCardInfoPayload'] = {
                        headerText: $scope.M_CO.SOHeaderList[SOIndex].SOInfo.UnitName,
                        unitImage: primaryImageURL,
                        hyperlinkActionVisible: !$scope.M_CO.isServiceJobDisabled(SOIndex) && !$scope.M_CO.SOHeaderList[SOIndex].SOInfo.DealId,
                        hyperlinktext: $translate.instant('Replace_unit'),
                        carouselId: "#carousel-modal-co",
                        primaryFields: [{
                            Label: $translate.instant('Label_VIN'),
                            Value: $scope.M_CO.SOHeaderList[SOIndex].SOInfo.VIN
                        }, {
                            Label: $translate.instant('Stock_number'),
                            Value: $scope.M_CO.SOHeaderList[SOIndex].SOInfo.StockId
                        }]
                    }
                }
              }
            }
          }
        }

        $scope.F_CO.Deal.getSalesPersonList = function() {
          $scope.M_CO.showSalesPersonList = true;
          $scope.M_CO.unreslovedList.DealSalesPersonCurrentIndex = -1;
        }
        function getSalesPersonList() {
            DealService.getSalesPersonList().then(function (successResult) {
            $scope.M_CO.salesPersonList = successResult;
          }, function (errorMessage) {
                Notification.error(errorMessage);
            });
        }
        $scope.F_CO.Deal.selectSalesPerson = function(salesperson) {
          $scope.M_CO.SalesPerson = salesperson;
          $scope.M_CO.Deal.DealInfo.Salesperson = salesperson.TechnicianName;
          $scope.M_CO.Deal.DealInfo.SalespersonId = salesperson.Id;
          $scope.M_CO.showSalesPersonList = false;
          $scope.F_CO.Deal.saveDealInfo();
        }
        $scope.F_CO.Deal.saveDealCommissionInfo = function() {
          if(!$scope.M_CO.Deal.DealInfo.DealCommission && $scope.M_CO.Deal.DealInfo.DealCommission == '') {
            $scope.M_CO.Deal.DealInfo.DealCommission = 0;
          }
          $scope.F_CO.Deal.saveDealInfo();
        }
        $scope.F_CO.Deal.saveDealInfo = function() {
            if ($scope.M_CO.Deal.DealInfo.Id) {
              DealService.saveDealInfoDetails($scope.M_CO.COHeaderId,$scope.M_CO.Deal.DealInfo.Id, angular.toJson($scope.M_CO.Deal.DealInfo)).then(function(result) {
              }, function(error) {
                    handleErrorAndExecption(error);
                });
            }
        }
        $scope.F_CO.Deal.keyBoardNavigation = function (event, dataList, dropDownName,searchString) {
            var keyCode = event.which ? event.which : event.keyCode;
            var dropDownDivId = '#' + dropDownName + 'DropDownDiv';
            var indexName = dropDownName + 'CurrentIndex';
            if ($scope.M_CO.Deal[indexName] == undefined || isNaN($scope.M_CO.Deal[indexName])) {
              $scope.M_CO.Deal[indexName] = -1;
            }

            if (keyCode == 40 && dataList != undefined && dataList != '') {
                if (dataList.length - 1 > $scope.M_CO.Deal[indexName]) {
                  $scope.M_CO.Deal[indexName]++;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.Deal[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode === 38 && dataList != undefined && dataList != '') {
                if ($scope.M_CO.Deal[indexName] > 0) {
                  $scope.M_CO.Deal[indexName]--;
                    angular.element(dropDownDivId)[0].scrollTop = angular.element('#' + dropDownName + $scope.M_CO.Deal[indexName])[0].offsetTop - 100;
                }
            } else if (keyCode == 13 && $scope.M_CO.Deal[indexName] !== -1) {
                if (dropDownName === 'DealSalesPerson') {
                  $scope.F_CO.Deal.selectSalesPerson(dataList[$scope.M_CO.Deal[indexName]]);
                }
                $scope.M_CO.Deal[indexName] = -1;
            }
        }

        /* Modal window Open*/
        $scope.F_CO.openAllModalWindow = function(ModalId) {
           angular.element('#'+ ModalId).modal({
                backdrop: 'static',
                keyboard: false
            });
        }

        angular.element(document).on("click", "#changeTransactionType .modal-backdrop", function() {
            $scope.F_CO.hideChangeTransactionType();
        });
        function checkTransactionTypeDefaultValue() {
            var MerchandiseTransactionTypeIndex = _.findIndex($scope.M_CO.transactionTypelabel, {
                "label": $scope.M_CO.coHeaderRec.MerchandiseTransactionType
            });
            if(MerchandiseTransactionTypeIndex != -1) {
                $scope.M_CO.selectedTransactionTypeIndex = MerchandiseTransactionTypeIndex;
            }
            var MerchandiseCommitOrdercontrolsIndex = _.findIndex($scope.M_CO.transactionType, {
                "label": $scope.M_CO.coHeaderRec.MerchandiseCommitOrdercontrols
            });
            if(MerchandiseCommitOrdercontrolsIndex != -1) {
                $scope.M_CO.transactionSelectedIndex = MerchandiseCommitOrdercontrolsIndex;
            }
        }
        $scope.F_CO.hideChangeTransactionType = function() {
            angular.element('#changeTransactionType').modal('hide');
            angular.element("body").removeClass(' modal-open ').css('padding', '0px');
            checkTransactionTypeDefaultValue();
        }
        /* Modal window End**/

        /**
         * Generate modal data for Deal data for New Unit
         */
        function getDealNewUnitDataJson() {
          var defer = $q.defer();

          var AmountFinanced = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType === 'Financed') ? $scope.F_CO.DealFinance.getAmountFinanced() : 0 ;
          var TotalPriceOfGoods = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ? (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit + $scope.M_CO.Deal.UnitList[0].TotalStampDuty).toFixed(2)) : "0";

          var dealNewUnitJson = {
              "SalesPerson":($scope.M_CO.SalesPerson && $scope.M_CO.SalesPerson.TechnicianName ) ? $scope.M_CO.SalesPerson.TechnicianName : "",
          "CustomerOrderNumber":($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealStatus) ? $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced' ? $scope.M_CO.Deal.DealInfo.InvoiceNumber : $scope.M_CO.coHeaderRec.OrderName: "",
          "StockNumber":"",
          "FixedTextValue1":"REFER TO ATTACHED SCHEDULE",
          "SubTotal1": "", /*UnitTotalPrice*/
          "LessOtherAllowance": "N/A",
          "SubTotal2": "", /*UnitTotalPrice*/
          "DeliveryFees": "N/A",
          "LuxuryCarTax": "N/A",
          "Registration": "N/A",
          "ThirdPartyInsurance": "N/A",
          "SubTotal3": "", /*TotalPriceOfGoods*/
          "StampDuty2": "N/A",
          "TotalOtherTaxableSupplies": "N/A",
          "TotalPriceOfGoods": ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ?  TotalPriceOfGoods : "0",
            };

          if($scope.M_CO.BussinessProfileData) {
            dealNewUnitJson["BussinessInformation_Line1"] = ($scope.M_CO.BussinessProfileData.CompanyName)? $scope.M_CO.BussinessProfileData.CompanyName : "";
        dealNewUnitJson["BussinessInformation_Line2"] = ($scope.M_CO.BussinessProfileData.TaxId) ? "ABN" + $scope.M_CO.BussinessProfileData.TaxId : "";
        dealNewUnitJson["BussinessInformation_Line3"] = ($scope.M_CO.BussinessProfileData.Address1) ? $scope.M_CO.BussinessProfileData.Address1 + ", " + ($scope.M_CO.BussinessProfileData.Address2 || ""): "";
        dealNewUnitJson["BussinessInformation_Line4"] = ($scope.M_CO.BussinessProfileData.City) ? $scope.M_CO.BussinessProfileData.City + ", " +  $scope.M_CO.BussinessProfileData.State + "," + $scope.M_CO.BussinessProfileData.PostalCode : "";
        dealNewUnitJson["BussinessInformation_Line5"] = ($scope.M_CO.BussinessProfileData.FormattedBusinessPhone) ? "Telephone: " + $scope.M_CO.BussinessProfileData.FormattedBusinessPhone : "";
          }

          if($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length && $scope.M_CO.Deal.UnitList[0].DealItemObj) {
            dealNewUnitJson["StockNumber"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.StockNumber) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.StockNumber : "";
            dealNewUnitJson["UnitMake"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName: "";
        dealNewUnitJson["UnitModel"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.ModelName) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.ModelName: "";
        dealNewUnitJson["UnitBodyType"] = "CYCLE";
        dealNewUnitJson["UnitREGO"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.REGO) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.REGO: "";
        dealNewUnitJson["UnitVIN"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.VIN) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.VIN: "";
        dealNewUnitJson["UnitRegExpiryDate"] = ( $scope.M_CO.Deal.UnitList[0].DealItemObj.RegExpiryDate) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.RegExpiryDate: "";
        dealNewUnitJson["UnitColor"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length &&  $scope.M_CO.Deal.UnitList[0].DealItemObj.ExteriorColour) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.ExteriorColour: "";
        dealNewUnitJson["UnitEngineNumber"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber: "";
        dealNewUnitJson["UnitEngineSize"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.EngineSize) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.EngineSize.toString() : "";
          }

          if($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) {
            dealNewUnitJson["VehicleRetailPrice"] =  (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption +$scope.M_CO.Deal.UnitList[0].TotalFactoryOption).toFixed(2)).toString();
            dealNewUnitJson["OptionAndFees"] = (($scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit).toFixed(2)).toString();
            dealNewUnitJson["UnitTotalPrice"] = (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit).toFixed(2)).toString();
            dealNewUnitJson["StampDuty"] = ($scope.M_CO.Deal.UnitList[0].TotalStampDuty) ? (($scope.M_CO.Deal.UnitList[0].TotalStampDuty).toFixed(2)).toString(): "0";
          }
          dealNewUnitJson["SubTotal1"] = dealNewUnitJson["SubTotal2"] = dealNewUnitJson["UnitTotalPrice"];
          dealNewUnitJson["SubTotal3"] = dealNewUnitJson["TotalPriceOfGoods"];

          if($scope.M_CO.CustomerCardInfo) {
            dealNewUnitJson["CustomerName"] = ($scope.M_CO.CustomerCardInfo.CustomerName) ? $scope.M_CO.CustomerCardInfo.CustomerName: "";
          dealNewUnitJson["CustomerAddress_Line1"] = (($scope.M_CO.CustomerCardInfo && $scope.M_CO.CustomerCardInfo.CustomerAddress) ? $scope.M_CO.CustomerCardInfo.CustomerAddress + ($scope.M_CO.CustomerCardInfo.CustomerAddress2 ? ', ' + $scope.M_CO.CustomerCardInfo.CustomerAddress2 : "") : "").replace("\r", "");

          var CustomerAddress_Line2 = $scope.M_CO.CustomerCardInfo.CustomerCityProv || "";
          CustomerAddress_Line2 +=  (CustomerAddress_Line2.length ? (", ") : "") + ($scope.M_CO.CustomerCardInfo.CustomerState || "");
          CustomerAddress_Line2 +=  (CustomerAddress_Line2.length ? (", ") : "") + ($scope.M_CO.CustomerCardInfo.CustomerPostal || "");
          dealNewUnitJson["CustomerAddress_Line2"] = CustomerAddress_Line2;
        dealNewUnitJson["CustomerPostal"] = ($scope.M_CO.CustomerCardInfo.CustomerPostal || "");
          dealNewUnitJson["CustomerMobileNumber"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone) ? $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone: "";
          dealNewUnitJson["CustomerHomeNumber"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber) ? ($scope.M_CO.CustomerCardInfo.CustomerType == 'Individual' ? $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber : $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber ) : "";
          dealNewUnitJson["CustomerEmailAddress"] = ($scope.M_CO.CustomerCardInfo.CustomerEmail) ? $scope.M_CO.CustomerCardInfo.CustomerEmail: "";
          }

          if($scope.M_CO.Deal.TradeInsList && $scope.M_CO.Deal.TradeInsList.length) {
            dealNewUnitJson["TradeInStockNumber"] =($scope.M_CO.Deal.TradeInsList[0].TradeInUnitStockNumber && $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced') ? $scope.M_CO.Deal.TradeInsList[0].TradeInUnitStockNumber: "";
          dealNewUnitJson["TradeInMake"] = ($scope.M_CO.Deal.TradeInsList[0].MakeName) ? $scope.M_CO.Deal.TradeInsList[0].MakeName : "";
          dealNewUnitJson["TradeInModel"] = ($scope.M_CO.Deal.TradeInsList[0].ModelName) ? $scope.M_CO.Deal.TradeInsList[0].ModelName : "";
          dealNewUnitJson["TradeInBodyType"] = "CYCLE";
          dealNewUnitJson["TradeInREGO"] = ($scope.M_CO.Deal.TradeInsList[0].REGO) ? $scope.M_CO.Deal.TradeInsList[0].REGO : "";
          dealNewUnitJson["TradeInVIN"] = ($scope.M_CO.Deal.TradeInsList[0].VIN) ? $scope.M_CO.Deal.TradeInsList[0].VIN : "";
          dealNewUnitJson["TradeInRegExpiryDate"] = ($scope.M_CO.Deal.TradeInsList[0].RegExpiryDate) ? $scope.M_CO.Deal.TradeInsList[0].RegExpiryDate : "";
          dealNewUnitJson["TradeInOdometer"] = ($scope.M_CO.Deal.TradeInsList[0].TradeInMileageValue) ? $scope.M_CO.Deal.TradeInsList[0].TradeInMileageValue : "";
          dealNewUnitJson["TradeInColor"] = ($scope.M_CO.Deal.TradeInsList[0].ExteriorColour) ? $scope.M_CO.Deal.TradeInsList[0].ExteriorColour : "";
          dealNewUnitJson["TradeInEngineNo"] = ($scope.M_CO.Deal.TradeInsList[0].EngineNumber) ? $scope.M_CO.Deal.TradeInsList[0].EngineNumber : "";
          dealNewUnitJson["TradeInEngineSize"] = ($scope.M_CO.Deal.TradeInsList[0].EngineSize) ? $scope.M_CO.Deal.TradeInsList[0].EngineSize.toString() : "";
          }

          // Trade-in Unit price details
          dealNewUnitJson["TradeInValue1"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.TradeInsTotal) ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal < 0  ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal * -1).toFixed(2) : $scope.M_CO.Deal.DealInfo.TradeInsTotal.toFixed(2)) : "0",
      dealNewUnitJson["TradeInValue2"] = dealNewUnitJson["TradeInValue1"];
      dealNewUnitJson["AmountFinanced"] = AmountFinanced;
      //TradeInValue3 is net trade equity
      dealNewUnitJson["LessPayoutTo"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.LienPayoutTotal) ? $scope.M_CO.Deal.DealInfo.LienPayoutTotal.toFixed(2) : "0";
      var netTrade = dealNewUnitJson["TradeInValue1"] - dealNewUnitJson["LessPayoutTo"];
      dealNewUnitJson["TradeInValue3"] = netTrade ? netTrade.toFixed(2) : 0.0;
      dealNewUnitJson["TradeInValue4"] = dealNewUnitJson["TradeInValue3"];
      
      if($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType === "Cash Deal") {
            dealNewUnitJson["FinancedByCustomer"] = "X";
          } else {
            dealNewUnitJson["FinancedByDealer"] = "X";
          }
          calculateTotalPaymentForDeal().then(function(dealTotalObj) {
            dealNewUnitJson["DepositsAndPayments"] = (dealTotalObj.DepositsAndPayments).toFixed(2);
          dealNewUnitJson["InvoicePayments"] = (dealTotalObj.InvoicePayments).toFixed(2);
          dealNewUnitJson["TotalSettlements"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ? ($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit + $scope.M_CO.Deal.UnitList[0].TotalStampDuty - (dealTotalObj.DepositsAndPayments + ($scope.M_CO.Deal.DealInfo.TradeInsTotal < 0  ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal * -1) : $scope.M_CO.Deal.DealInfo.TradeInsTotal) + AmountFinanced + dealTotalObj.InvoicePayments)).toFixed(2) : "0";
          
          dealNewUnitJson["DepositsAndPayments1"] = (dealTotalObj.DepositsAndPayments1).toFixed(2);
          var invoicePayments1 = ((+dealNewUnitJson["TotalPriceOfGoods"]) -
        		  ((+AmountFinanced) + (+dealNewUnitJson["DepositsAndPayments1"]) + (+dealNewUnitJson["TradeInValue3"])));
          dealNewUnitJson["InvoicePayments1"] = (invoicePayments1).toFixed(2);
        //InvoicePayments is BalanceOfPayment
          
          //TradeInValue3 is net trade equity  
        var totalSettlements1 = (+AmountFinanced + (+dealNewUnitJson["InvoicePayments1"]) + (+dealNewUnitJson["DepositsAndPayments1"]) +
            (+dealNewUnitJson["TradeInValue3"]));
        dealNewUnitJson["TotalSettlements1"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ?  (totalSettlements1).toFixed(2) : "0";
          defer.resolve(dealNewUnitJson);
          }, function(error) {
            dealNewUnitJson["DepositsAndPayments"] = 0;
            dealNewUnitJson["InvoicePayments"] = 0;
            dealNewUnitJson["TotalSettlements"] = 0;
            dealNewUnitJson["DepositsAndPayments1"] = 0;
            dealNewUnitJson["InvoicePayments1"] = 0;
            dealNewUnitJson["TotalSettlements1"] = 0;
            defer.resolve(dealNewUnitJson);
          });
          return defer.promise;
        }

        /**
         * Generate modal data for Deal data for Used Unit
         */
        function getDealUsedUnitDataJson() {
          var defer = $q.defer();
          var dealUsedUnitJson = {};

          // Selling Agent details
          dealUsedUnitJson["SellingAgent1"] = dealUsedUnitJson["SellingAgent2"] = "";
          dealUsedUnitJson["SellingAgent3"] = "X";
          dealUsedUnitJson["SalesPerson"] = ($scope.M_CO.SalesPerson && $scope.M_CO.SalesPerson.TechnicianName) ? $scope.M_CO.SalesPerson.TechnicianName : "";
          dealUsedUnitJson["CustomerOrderNumber"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealStatus) ? $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced' ? $scope.M_CO.Deal.DealInfo.InvoiceNumber : $scope.M_CO.coHeaderRec.OrderName : "";
          dealUsedUnitJson["StockNumber"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length && $scope.M_CO.Deal.UnitList[0].DealItemObj && $scope.M_CO.Deal.UnitList[0].DealItemObj.StockNumber) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.StockNumber : "";

          // BusinessProfile details
          if ($scope.M_CO.BussinessProfileData) {
            // Business Profile Details
        dealUsedUnitJson["BussinessInformation_Line1"] = ($scope.M_CO.BussinessProfileData.CompanyName) ? $scope.M_CO.BussinessProfileData.CompanyName : "";
        dealUsedUnitJson["BussinessInformation_Line2"] = ($scope.M_CO.BussinessProfileData.TaxId) ? "ABN" + $scope.M_CO.BussinessProfileData.TaxId : "";
        dealUsedUnitJson["BussinessInformation_Line3"] = ($scope.M_CO.BussinessProfileData.Address1) ? $scope.M_CO.BussinessProfileData.Address1 + ", " + ($scope.M_CO.BussinessProfileData.Address2 || ""): "";
        dealUsedUnitJson["BussinessInformation_Line4"] = ($scope.M_CO.BussinessProfileData.City) ? $scope.M_CO.BussinessProfileData.City + ', ' + $scope.M_CO.BussinessProfileData.State + ', ' + $scope.M_CO.BussinessProfileData.PostalCode: "";
        dealUsedUnitJson["BussinessInformation_Line5"] = ($scope.M_CO.BussinessProfileData.FormattedBusinessPhone) ? "Telephone: " + $scope.M_CO.BussinessProfileData.FormattedBusinessPhone : "";
        dealUsedUnitJson["MotorDealer"] = ($scope.M_CO.BussinessProfileData.CompanyName) ? $scope.M_CO.BussinessProfileData.CompanyName : "";
            dealUsedUnitJson["BussinessAddress"] = ($scope.M_CO.BussinessProfileData.Address1) ? $scope.M_CO.BussinessProfileData.Address1 + $scope.M_CO.BussinessProfileData.Address2 : "";
          dealUsedUnitJson["BussinessCity"] = ($scope.M_CO.BussinessProfileData.City) ? $scope.M_CO.BussinessProfileData.City : "";
          dealUsedUnitJson["BussinessState"] = ($scope.M_CO.BussinessProfileData.State) ? $scope.M_CO.BussinessProfileData.State : "";
        dealUsedUnitJson["BussinessPostalCode"] = ($scope.M_CO.BussinessProfileData.PostalCode) ? $scope.M_CO.BussinessProfileData.PostalCode : "";
        dealUsedUnitJson["BussinessPhone"] = ($scope.M_CO.BussinessProfileData.FormattedBusinessPhone) ? $scope.M_CO.BussinessProfileData.FormattedBusinessPhone : "";
        dealUsedUnitJson["BussinessEmail"] = ($scope.M_CO.BussinessProfileData.BusinessEmail) ? $scope.M_CO.BussinessProfileData.BusinessEmail : "";
          // Warranter Details
        dealUsedUnitJson["Warranter"] = ($scope.M_CO.BussinessProfileData.CompanyName) ? $scope.M_CO.BussinessProfileData.CompanyName : "";
        dealUsedUnitJson["WarranterAddress"] = ($scope.M_CO.BussinessProfileData.Address1) ? $scope.M_CO.BussinessProfileData.Address1 + $scope.M_CO.BussinessProfileData.Address2 : "";
        dealUsedUnitJson["WarranterSuburb"] = ($scope.M_CO.BussinessProfileData.City) ? $scope.M_CO.BussinessProfileData.City : "";
        dealUsedUnitJson["WarranterState"] = ($scope.M_CO.BussinessProfileData.State) ? $scope.M_CO.BussinessProfileData.State : "";
        dealUsedUnitJson["WarranterPostalCode"] = ($scope.M_CO.BussinessProfileData.PostalCode) ? $scope.M_CO.BussinessProfileData.PostalCode : "";
        dealUsedUnitJson["WarranterPhone"] = ($scope.M_CO.BussinessProfileData.FormattedBusinessPhone) ? $scope.M_CO.BussinessProfileData.FormattedBusinessPhone : "";
        dealUsedUnitJson["WarranterEmail"] = ($scope.M_CO.BussinessProfileData.BusinessEmail) ? $scope.M_CO.BussinessProfileData.BusinessEmail : "";

          }
          // Customer Details
          if ($scope.M_CO.CustomerCardInfo) {
            dealUsedUnitJson["CustomerFullName"] = ($scope.M_CO.CustomerCardInfo.CustomerName) ? $scope.M_CO.CustomerCardInfo.CustomerName : "";
            dealUsedUnitJson["CustomerAddress"] = (($scope.M_CO.CustomerCardInfo && $scope.M_CO.CustomerCardInfo.CustomerAddress) ? $scope.M_CO.CustomerCardInfo.CustomerAddress + ($scope.M_CO.CustomerCardInfo.CustomerAddress2 ? ', ' + $scope.M_CO.CustomerCardInfo.CustomerAddress2 : "") : "").replace("\r", "");
            dealUsedUnitJson["CustomerCity"] = ($scope.M_CO.CustomerCardInfo.CustomerCityProv) ? $scope.M_CO.CustomerCardInfo.CustomerCityProv : "";
            dealUsedUnitJson["CustomerState"] = ($scope.M_CO.CustomerCardInfo.CustomerState) ? $scope.M_CO.CustomerCardInfo.CustomerState : "";
            dealUsedUnitJson["CustomerPostal"] = ($scope.M_CO.CustomerCardInfo.CustomerPostal) ? $scope.M_CO.CustomerCardInfo.CustomerPostal : "";
            dealUsedUnitJson["CustomerMobileNumber"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone) ? $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone : "";
            dealUsedUnitJson["CustomerPhone"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber) ? ($scope.M_CO.CustomerCardInfo.CustomerType == 'Individual' ? $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber : $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber) : "";
            dealUsedUnitJson["CustomerEmailAddress"] = ($scope.M_CO.CustomerCardInfo.CustomerEmail) ? $scope.M_CO.CustomerCardInfo.CustomerEmail : "";
            dealUsedUnitJson["CustomerPostal"] = ($scope.M_CO.CustomerCardInfo.CustomerPostal) ? $scope.M_CO.CustomerCardInfo.CustomerPostal : "";
            dealUsedUnitJson["Buyer"] = ($scope.M_CO.CustomerCardInfo.CustomerName) ? $scope.M_CO.CustomerCardInfo.CustomerName : "";
            dealUsedUnitJson["CustomerAddress_Line1"] = dealUsedUnitJson["CustomerAddress"];

            var CustomerAddress_Line2 = $scope.M_CO.CustomerCardInfo.CustomerCityProv || "";
            CustomerAddress_Line2 +=  (CustomerAddress_Line2.length ? (", ") : "") + ($scope.M_CO.CustomerCardInfo.CustomerState || "");
          CustomerAddress_Line2 +=  (CustomerAddress_Line2.length ? (", ") : "") + ($scope.M_CO.CustomerCardInfo.CustomerPostal || "");
          dealUsedUnitJson["CustomerAddress_Line2"] = CustomerAddress_Line2;
            dealUsedUnitJson["CustomerMobileNumber"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone) ? $scope.M_CO.CustomerCardInfo.CustomerFormattedOtherPhone : "";
            dealUsedUnitJson["CustomerHomeNumber"] = ($scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber) ? ($scope.M_CO.CustomerCardInfo.CustomerType == 'Individual' ? $scope.M_CO.CustomerCardInfo.CustomerFormattedHomeNumber : $scope.M_CO.CustomerCardInfo.CustomerFormattedWorkNumber) : "";
            dealUsedUnitJson["CustomerEmailAddress"] = ($scope.M_CO.CustomerCardInfo.CustomerEmail) ? $scope.M_CO.CustomerCardInfo.CustomerEmail : "";
          }
          // Unit Details
          if ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length && $scope.M_CO.Deal.UnitList[0].DealItemObj) {
            dealUsedUnitJson["UnitMakeModel"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName + ' ' + $scope.M_CO.Deal.UnitList[0].DealItemObj.ModelName + ' ' + $scope.M_CO.Deal.UnitList[0].DealItemObj.SubModelName : "";
            dealUsedUnitJson["UnitVIN"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.VIN) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.VIN : "";
            dealUsedUnitJson["UnitEngineNumber"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber : "";
            dealUsedUnitJson["UnitRegistrationNumber"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.REGO) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.REGO : "";
            dealUsedUnitJson['UnitType'] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.Type) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.Type : "";
            dealUsedUnitJson["UnitColor"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.ExteriorColour) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.ExteriorColour: "";
            dealUsedUnitJson["UnitMake"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.MakeName : "";
            dealUsedUnitJson["UnitModel"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.ModelName) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.ModelName : "";
            dealUsedUnitJson["UnitBodyType"] = "CYCLE";
            dealUsedUnitJson["UnitREGO"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.REGO) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.REGO : "";
            dealUsedUnitJson["UnitVIN"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.VIN) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.VIN : "";
            dealUsedUnitJson["UnitRegExpiryDate"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.RegExpiryDate) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.RegExpiryDate : "";
            dealUsedUnitJson["UnitEngineNumber"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.EngineNumber : "";
            dealUsedUnitJson["UnitEngineSize"] = ($scope.M_CO.Deal.UnitList[0].DealItemObj.EngineSize) ? $scope.M_CO.Deal.UnitList[0].DealItemObj.EngineSize : "";

            //NOTE - To match with the provided form - Probably should be moved to configuration json, which would require pdf genration code changes.
              var UnitOdometer = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length && $scope.M_CO.Deal.UnitList.length && $scope.M_CO.Deal.UnitList[0].DealItemObj && $scope.M_CO.Deal.UnitList[0].DealItemObj.Mileage) ? ($scope.M_CO.Deal.UnitList[0].DealItemObj.Mileage).toString() : "";
              if (UnitOdometer.length > 3) {
                dealUsedUnitJson["UnitOdometer1"] = UnitOdometer.substring(0, 3);
                dealUsedUnitJson["UnitOdometer2"] = UnitOdometer.substring(3);
              } else {
                dealUsedUnitJson["UnitOdometer1"] = UnitOdometer;
                dealUsedUnitJson["UnitOdometer2"] = "";
              }
          }
          // Unit price details
          if($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) {
            dealUsedUnitJson["CashPrice"] = (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption +$scope.M_CO.Deal.UnitList[0].TotalFactoryOption).toFixed(2)).toString();
            dealUsedUnitJson["TotalOptionsAndFee"] = (($scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit).toFixed(2)).toString();
            dealUsedUnitJson["FixedTextValue1"] = "REFER TO ATTACHED SCHEDULE";
            dealUsedUnitJson["UnitTotalPrice"] = (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit).toFixed(2)).toString();
            dealUsedUnitJson["PriceIncludingGST"] = dealUsedUnitJson["UnitTotalPrice"];
            dealUsedUnitJson["StampDuty"] = ($scope.M_CO.Deal.UnitList[0].TotalStampDuty) ? (($scope.M_CO.Deal.UnitList[0].TotalStampDuty).toFixed(2)).toString(): "0";
            dealUsedUnitJson["TotalPriceOfGoods"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ? (($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit + $scope.M_CO.Deal.UnitList[0].TotalStampDuty).toFixed(2)) : "0";
            dealUsedUnitJson["SubTotal1"] = dealUsedUnitJson["TotalPriceOfGoods"];
            dealUsedUnitJson["LessOtherAllowance"] = dealUsedUnitJson["Registration"] = dealUsedUnitJson["TransferFee"] = dealUsedUnitJson["ThirdPartyInsurance"] = "N/A";
          }
          // Trade-in Unit details
          if ($scope.M_CO.Deal.TradeInsList && $scope.M_CO.Deal.TradeInsList.length) {
            dealUsedUnitJson["TradeInStockNumber"] = ( $scope.M_CO.Deal.TradeInsList[0].TradeInUnitStockNumber && $scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced') ? $scope.M_CO.Deal.TradeInsList[0].TradeInUnitStockNumber : "";
        dealUsedUnitJson["TradeInMake"] = ( $scope.M_CO.Deal.TradeInsList[0].MakeName) ? $scope.M_CO.Deal.TradeInsList[0].MakeName : "";
        dealUsedUnitJson["TradeInModel"] = ( $scope.M_CO.Deal.TradeInsList[0].ModelName) ? $scope.M_CO.Deal.TradeInsList[0].ModelName : "";
        dealUsedUnitJson["TradeInBodyType"] = "CYCLE";
        dealUsedUnitJson["TradeInREGO"] = ( $scope.M_CO.Deal.TradeInsList[0].REGO) ? $scope.M_CO.Deal.TradeInsList[0].REGO : "";
        dealUsedUnitJson["TradeInVIN"] = ( $scope.M_CO.Deal.TradeInsList[0].VIN) ? $scope.M_CO.Deal.TradeInsList[0].VIN : "";
        dealUsedUnitJson["TradeInRegExpiryDate"] = ( $scope.M_CO.Deal.TradeInsList[0].RegExpiryDate) ? $scope.M_CO.Deal.TradeInsList[0].RegExpiryDate : "";
        dealUsedUnitJson["TradeInOdometer"] = ($scope.M_CO.Deal.TradeInsList[0].TradeInMileageValue) ? $scope.M_CO.Deal.TradeInsList[0].TradeInMileageValue : "";
        dealUsedUnitJson["TradeInColor"] = ( $scope.M_CO.Deal.TradeInsList[0].ExteriorColour) ? $scope.M_CO.Deal.TradeInsList[0].ExteriorColour : "";
        dealUsedUnitJson["TradeInEngineNo"] = ( $scope.M_CO.Deal.TradeInsList[0].EngineNumber) ? $scope.M_CO.Deal.TradeInsList[0].EngineNumber : "";
        dealUsedUnitJson["TradeInEngineSize"] = ( $scope.M_CO.Deal.TradeInsList[0].EngineSize) ? $scope.M_CO.Deal.TradeInsList[0].EngineSize : ""
          }

          // Trade-in Unit price details
        dealUsedUnitJson["TradeInAllowance"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.TradeInsTotal) ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal < 0  ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal * -1).toFixed(2) : $scope.M_CO.Deal.DealInfo.TradeInsTotal.toFixed(2)) : "0";
        //dealUsedUnitJson["NetTrade"] =
        dealUsedUnitJson["LessPayoutTo"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.LienPayoutTotal) ? $scope.M_CO.Deal.DealInfo.LienPayoutTotal.toFixed(2) : "0";
        //net trade equity
        dealUsedUnitJson["NetTrade"] = dealUsedUnitJson["TradeInAllowance"] - dealUsedUnitJson["LessPayoutTo"];
        dealUsedUnitJson["TradeAmount"] = dealUsedUnitJson["NetTrade"];
        var AmountFinanced = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType === 'Financed') ? $scope.F_CO.DealFinance.getAmountFinanced() : 0;
        dealUsedUnitJson["AmountFinanced"] = AmountFinanced;
      dealUsedUnitJson["FinancedByDealer"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType !== "Cash Deal") ? "X" : "";
      dealUsedUnitJson["FinancedByCustomer"] = ($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType === "Cash Deal") ? "X" : "";
      calculateTotalPaymentForDeal().then(function(dealTotalObj) {
            dealUsedUnitJson["DepositsAndPayments"] = (dealTotalObj.DepositsAndPayments).toFixed(2);
            dealUsedUnitJson["InvoicePayments"] = (dealTotalObj.InvoicePayments).toFixed(2);
            dealUsedUnitJson["TotalSettlements"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ? ($scope.M_CO.Deal.UnitList[0].TotalBasePrice + $scope.M_CO.Deal.UnitList[0].TotalDealerInstalledOption + $scope.M_CO.Deal.UnitList[0].TotalFactoryOption + $scope.M_CO.Deal.UnitList[0].TotalOptionAndFeeWithKit + $scope.M_CO.Deal.UnitList[0].TotalStampDuty - (dealTotalObj.DepositsAndPayments + ($scope.M_CO.Deal.DealInfo.TradeInsTotal < 0  ? ($scope.M_CO.Deal.DealInfo.TradeInsTotal * -1) : $scope.M_CO.Deal.DealInfo.TradeInsTotal) + AmountFinanced + dealTotalObj.InvoicePayments)).toFixed(2) : "0";
            //InvoicePayments is BoP(BalanceOfPayment)
            
            dealUsedUnitJson["DepositsAndPayments1"] = (dealTotalObj.DepositsAndPayments1).toFixed(2);
            var invoicePayments1 = ((+dealUsedUnitJson["TotalPriceOfGoods"]) -
                ((+AmountFinanced) + (+dealUsedUnitJson["DepositsAndPayments1"]) + (+dealUsedUnitJson["NetTrade"])));
            dealUsedUnitJson["InvoicePayments1"] = (invoicePayments1).toFixed(2);
            /*var invPay = 0.0;
            if($scope.M_CO.Deal.DealInfo && $scope.M_CO.Deal.DealInfo.DealType === 'Financed') {
            	invPay = $scope.M_CO.Deal.DealFinanceObj.DownPayment -  (dealTotalObj.DepositsAndPayments1).toFixed(2);
            } else {
            	invPay = dealUsedUnitJson["TotalPriceOfGoods"] - (dealTotalObj.DepositsAndPayments1).toFixed(2) - dealUsedUnitJson["NetTrade"];
            }
            dealUsedUnitJson["InvoicePayments1"] = invPay.toFixed(2);*/
            
            
            var totalSettlements1 = ((+AmountFinanced) + (+dealUsedUnitJson["InvoicePayments1"]) + (+dealUsedUnitJson["DepositsAndPayments1"]) +
                (+dealUsedUnitJson["NetTrade"]));

            dealUsedUnitJson["TotalSettlements1"] = ($scope.M_CO.Deal.UnitList && $scope.M_CO.Deal.UnitList.length) ?  (totalSettlements1).toFixed(2) : "0";
            defer.resolve(dealUsedUnitJson);
          }, function(error) {
            dealUsedUnitJson["DepositsAndPayments"] = 0;
            dealUsedUnitJson["InvoicePayments"] = 0;
            dealUsedUnitJson["TotalSettlements"] = 0;
            dealUsedUnitJson["DepositsAndPayments1"] = 0;
            dealUsedUnitJson["InvoicePayments1"] = 0;
            dealUsedUnitJson["TotalSettlements1"] = 0;
            defer.resolve(dealUsedUnitJson);
          });
          return defer.promise;
        }

        function calculateTotalPaymentForDeal() {
          var defer = $q.defer();
          var resultObj = {
              "InvoicePayments": 0,
              "DepositsAndPayments" : 0,
              "InvoicePayments1": 0,
              "DepositsAndPayments1" : 0
                };
          var invId = ($scope.M_CO.Deal.DealInfo.InvoiceId ? $scope.M_CO.Deal.DealInfo.InvoiceId : ($scope.F_CO.isDealSelectedForCheckout() ?
                (isActiveInvoiceHeaderIdExists() ? $scope.M_CO.coHeaderRec.ActiveInvoiceId : null) : null));
          if(!invId) {
            $scope.M_CO.Deposit.TotalDealDepositAmount = ($scope.M_CO.Deposit.TotalDealDepositAmount ? $scope.M_CO.Deposit.TotalDealDepositAmount : 0);
                resultObj["DepositsAndPayments1"] += $scope.M_CO.Deposit.TotalDealDepositAmount;
                defer.resolve(resultObj);
            return defer.promise;
          }
          DealService.getCOInvoicePaymentsByCOInvoiceHedaerId(invId).then(function(result) {
                if($scope.M_CO.Deal.DealInfo.DealStatus === 'Invoiced' && result) {
                    for (var i = 0; i < result.length; i++) {
                        if ((result[i].PaymentMethod != 'Charge Account' && result[i].PaymentMethod != 'Use Deal Deposit' )) {
                          resultObj["InvoicePayments"] += result[i].Amount;
                        } else  if(result[i].PaymentMethod == 'Use Deal Deposit') {
                          resultObj["DepositsAndPayments"] += result[i].Amount;
                        }
                    }
                }
                if(result) {
                  var totalDepositUsed = 0;
                    for(var i = 0; i < result.length; i++) {
                      if(result[i].PaymentMethod == 'Use Deal Deposit') {
                        totalDepositUsed += result[i].Amount;
                      }
                        if(result[i].PaymentMethod != 'Charge Account' && result[i].PaymentMethod != 'Use Deal Deposit') {
                          resultObj["DepositsAndPayments1"] += result[i].Amount;
                        }
                    }
                }
                $scope.M_CO.Deposit.TotalDealDepositAmount = ($scope.M_CO.Deposit.TotalDealDepositAmount ? $scope.M_CO.Deposit.TotalDealDepositAmount : 0);
                resultObj["DepositsAndPayments1"] += (totalDepositUsed > $scope.M_CO.Deposit.TotalDealDepositAmount  ? totalDepositUsed : $scope.M_CO.Deposit.TotalDealDepositAmount);
                defer.resolve(resultObj);
          }, function(error) {
                handleErrorAndExecption(error);
                defer.reject();
            });

          return defer.promise;
        }
        	

        $scope.F_CO.getBussinessProfileData = function() {
          CustomerService.getBussinessProfileData().then(function(result){
            $scope.M_CO.BussinessProfileData = result;
          });
        }
        function getCOHeaderDetails() {
          var defer = $q.defer();
          SOHeaderService.getCOHeaderDetailsByGridName($stateParams.Id, null).then(function(coHeaderResult) {
            $scope.M_CO.coHeaderRec = coHeaderResult.coHeaderRec;
                $scope.M_CO.COKHList = coHeaderResult.COKHList;
                $scope.F_CO.getSpecialOrdersData();
                $scope.M_CO.isLoading = false;
                showPartsSmartItemsNotInserted();
                 showTooltip('body');
            defer.resolve(coHeaderResult);
            }, function(error) {
              $scope.M_CO.isLoading = false;
              handleErrorAndExecption(error);
              defer.reject($translate.instant('Error_in_adding_related_parts'));
            });
          return defer.promise;
        }

        $scope.F_CO.checkCashDrawerPermission = function() {
         if($scope.M_CO.cashDrawerList && $scope.M_CO.cashDrawerList.length == 1) {
            return false;
         } else if(!$rootScope.GroupOnlyPermissions['Set cash drawer']['enabled']) {
          return false;
         } else {
            return true;
         }
          //
        }
        function getPrimaryUnitImage(recordId, gridName, index) {
          $scope.M_CO.isLoading = true;
          var successJson = {
            'type': 'getPrimaryUnitImage',
            'gridName': gridName,
            'index': index
            };
          UnitImagesService.getPrimaryUnitImage(recordId).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.openImageCarousel = function(unitId) {
          $scope.M_CO.isUnitImagesLoaded = false;
          var successJson = {
                      'type': 'getUnitImagesByUnitId',
                      'UnitId': unitId
                  };
          UnitImagesService.getUnitImagesByUnitId(unitId).then(new success(successJson).handler, new error().handler);
        }

        $scope.F_CO.closeCarouselModal = function() {
          angular.element('#carousel-modal-co').modal('hide');
          angular.element("body").removeClass(' modal-open ').css('padding', '0px');
        }

    $scope.F_CO.exportCOFormToPdf = function(coFormId, formEditConfig, dataModalJson, fileName) {
      $scope.M_CO.isLoading = true;
      var promises = [];
      for(var page=1; page <= formEditConfig.length; page++) {
        promises.push(documentService.getAttachmentBodyByParentIdAndName(coFormId, page + ".jpg"));
      }
      $q.all(promises).then(function(imageBodyList) {
        ExportPdfService.generatePdf(imageBodyList, dataModalJson, formEditConfig, fileName);
        $scope.M_CO.isLoading = false;
      }).catch(function(error) {
        $scope.M_CO.isLoading = false;
        handleErrorAndExecption(error);
      });
    }
	
	$scope.F_CO.printCOProfitabilityData = function() {
        window.open('/apex/PrintCustomerOrderProfitability?' + ($scope.M_CO.COHeaderId ? ('Id=' + $scope.M_CO.COHeaderId) : ''), '_blank');
    }
	$scope.F_CO.openPartLocatorWindow = function(part) {
			var isNearDealerResultRecieved = false;
        	var isAllDealerResultRecieved = false;
        	var isSupplierResultRecieved = false;
        	$scope.M_CO.PartLocator = {};
        	$scope.M_CO.isLoading = true;
        	BRPService.getPartsLocator(part.PartId,1,"Dealer Radius").then(function(response) {
        		console.log("DealerRadius", response);
        		isNearDealerResultRecieved = true;
            	$scope.M_CO.PartLocator.headingText = 'BRP Availability';
            	if(response.DealerNearList && response.DealerNearList.length) {
                	$scope.M_CO.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                }
                $scope.M_CO.PartLocator.availabiltyText = 'Available from Manufacturer';
                $scope.M_CO.PartLocator.modalCss = 'part-locator';
                $scope.M_CO.PartLocator.nearDealerList = response.DealerNearList;
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);
    			}
    		}).catch(function(error) {
    	        $scope.M_CO.isLoading = false;
    	      });
        	BRPService.getPartsLocator(part.PartId,1,"Dealer").then(function(response) {
        		console.log("Dealer",response);
                isAllDealerResultRecieved = true;
                
                $scope.M_CO.PartLocator.allDealerList = response.AllDealerList;
                if(response.AllDealerList && response.AllDealerList.length) {
                	$scope.M_CO.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
                }
                
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);
    			}
    		}).catch(function(error) {
    	        $scope.M_CO.isLoading = false;
    	      });
        	BRPService.getPartsLocator(part.PartId,1,"Supplier").then(function(response) {
        		console.log("Supplier",response);
        		isSupplierResultRecieved = true;
        		
        		$scope.M_CO.PartLocator.availabiltyNumber = response.ManufacturerAvailableQty;
                $scope.M_CO.PartLocator.phoneNumber = response.ManufacturerPhoneNumber;
                
    			if(isAllDealerResultRecieved && isNearDealerResultRecieved && isSupplierResultRecieved) {
    				setCommonFieldForPartLocator(response);
    			}
    		}).catch(function(error) {
    	        $scope.M_CO.isLoading = false;
    	      });
	}
	
	function setCommonFieldForPartLocator(response) {
    	$scope.M_CO.PartLocator.showDialog=true;
        $scope.M_CO.isLoading = false;
        if(!$scope.M_CO.PartLocator.partDescription) {
        	$scope.M_CO.PartLocator.partDescription = response.PartNumber + ' - ' + response.PartDescription;
        }
    }
	
    function updateDealStatus() {
    	var successJson = {
            'type': 'commitUnitToDeal'
        };

        DealService.updateDealStatus($scope.M_CO.Deal.DealInfo.Id, $scope.M_CO.StatusConfig.newWorkStatus).then(function(dealInfo) {
        $scope.M_CO.Deal.DealInfo = dealInfo;
        new success(successJson).handler(dealInfo);
        createTradeInUnitCardInfoPayload();
        }, new error().handler);
    }
    
    $scope.F_CO.isDealInvoiced = function() {
    	if($scope.M_CO.Deal && $scope.M_CO.Deal.DealInfo 
    		&& (($scope.M_CO.Deal.DealInfo.DealStatus 
    		&& $scope.M_CO.Deal.DealInfo.DealStatus == 'Invoiced')
    		|| $scope.M_CO.Deal.DealInfo.IsInvoiceItemActive)){
    		return true;
    	} else {
    		return false;
    	}
    }
    /** It will set the refresh method of directive(Autocompete_v2 - STA) which would be 
     * called whenever there is any change in directive parameters 
     * and directive needs to be refreshed
    */
    $scope.setDirRefreshFnForParamChange = function(directiveFn) {
        $scope.F_CO.dirRefreshFnOnParamChange = directiveFn;
    };
    }])
});
