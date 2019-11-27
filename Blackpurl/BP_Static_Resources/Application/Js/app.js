define(['angularAMD'], function (angularAMD) {
    var app = angular.module("routerApp", ['ui.router', 'ngMap', 'ui.sortable', 'ct.ui.router.extras', 'BPGlobalHeader', 'ngDroplet', 'routerApp.ViewVendorChildApp', 'ngDialog', 'searchToAddModule', 'routerApp.AddUnitPriceAndCostApp', 'angucomplete', 'ngSanitize', 'routerApp.TaxExemptionApp', 'ui.date', 'routerApp.UnitApp', 'routerApp.COChildApp', 'routerApp.ViewCustomerChildApp', 'routerApp.AddEditCustomerApp', 'routerApp.ViewPartChildApp', 'routerApp.CashSaleCOChildApp', 'FocusElement', 'pascalprecht.translate','WeekScheduleGrid','ngCookies']);
    app.run(['$rootScope', '$sce', '$state', function ($rootScope, $sce, $state) {
        $rootScope.trustSrc = function (src) {
            return $sce.trustAsResourceUrl(src);
        }
        var localbViewStateList = [
            'ViewLabour.EditLabour',
            'ViewKit.EditKit',
            'AccountingIntegrationSettings.AddEditCategory',
            'AddEditCustomer',
            'SelectCustomer',
            'ActiveOrdersForCustomer',
            'AddEditVendor',
            'AddEditPart',
            'AddEditKit',
            'AddEditLabour',
            'AddEditUnit',
            'ViewUnit.AddEditUnit',
            'CustomerOrder_V2.AddEditUnit',
            'AddEditFee',
            'ViewFee.AddEditFee',
            'ViewVendor.AddEditPOType',
            'ViewVendor.AddEditVendorContact',
            'ViewVendor.AddEditProduct',
            'ViewVendor.EditVendor',
            'CashSaleCO.SelectCustomer',
            'CashSaleCO.CustomerMessagingPopUp',
            'ViewUnit.AddUnitPriceAndCost',
            'ViewCustomer.TaxExemption',
            'ViewVendor.TaxExemption',
            'ViewCustomer.COU',
            'CustomerOrder.AddEditUnit',
            'CustomerOrder.HourlogPopup',
            'CustomerOrder.AddAttachment',
            'CustomerOrder.PrintServiceWorksheetPopUp',
            'CustomerOrder.SelectUnit',
            'CustomerOrder.COActionModel',
            'CustomerOrder.DealUnit',
            'CustomerOrder.CustomerMessagingPopUp',
            'ViewPart.EditPart',
            'ViewPart.PartAdjustmentInStock',
            'ViewPart.ModifyCostSummary',
            'ViewPart.ModifyCostSource',
            'ViewPart.ResolveOversold',
            'ViewPart.PrintBarCode',
            'ViewCustomer.AddEditCustomerContact',
            'ViewCustomer.CustomerMessagingPopUp',
            'ViewCustomer.EditCustomer',
            'CustomerOrder.EditCustomer',
            'CashSaleCO.AddCustomer',
            'UnitOrdering.UnitOrderingVendorList.SelectCustomer',
            'UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog',
            'CustomerOrder_V2.serviceJobAddAttachment',
            'CustomerOrder_V2.CustomerMessagingPopUp',
            'CustomerOrder_V2.AddEditLogTechnicianTime',
            'CustomerOrder_V2.AddEditCustomerV2',
            'CustomerOrder_V2.ServiceJobClaim',
            'CustomerOrder_V2.ServiceJobClaimResponse',
            'CustomerOrder_V2.AddEditTempUnit',
            'CustomerOrder_V2.EditPricing',
            'CustomerOrder_V2.InvoiceToDeal',
            'ViewCustomer.AddEditCustomerV2',
            'User.AddEditTechnicianSchedule',
            'TechScheduler.JobScheduler.AddEditTechnicianSchedule',
            'VendorOrder.CustomerMessagingPopUp',
            'VendorOrder.AddAttachment'
        ];
        var childViewsStateList = [
            'AddEditCustomerV2', 
            'CustomerOrder_V2.AddEditCustomerV2', 
            'ViewCustomer.EditCustomerV2', 
            'AddEditCustomer',
            'ViewCustomer.EditCustomer',
            'CustomerOrder.EditCustomer',
            'CashSaleCO.AddCustomer',
            'CustomerOrder_V2.AddEditLogTechnicianTime',
            'CustomerOrder_V2.AddEditTempUnit',
             'User.AddEditTechnicianSchedule',
             'TechScheduler.JobScheduler.AddEditTechnicianSchedule',
            'AddEditUnitV2',
            'CustomerOrder_V2.EditPricing', 
            'CustomerOrder_V2.InvoiceToDeal', 
            'CustomerOrder_V2.serviceJobAddAttachment',
            'CashSaleCO.CustomerMessagingPopUp', 
            'CustomerOrder.CustomerMessagingPopUp', 
            'CustomerOrder_V2.CustomerMessagingPopUp',
            'VendorOrder.CustomerMessagingPopUp',
            'ViewCustomer.CustomerMessagingPopUp', 
            'CustomerOrder_V2.ServiceJobClaim', 
            'CustomerOrder_V2.ServiceJobClaimResponse',
            'SelectCustomer',
            'CashSaleCO.SelectCustomer',
            'UnitOrdering.UnitOrderingVendorList.SelectCustomer',
            'UnitOrdering.AddeditUnitOrder.UnitReceivingDialog',
            'UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog',
            'JobClocking',
            'PayrollClocking',
            'AddEditVendor',
            'ViewVendor.EditVendor',
            'ViewVendor.AddEditPOType',
            'ViewVendor.AddEditVendorContact',
            'ViewVendor.AddEditProduct',
            'ViewCustomer.TaxExemption',
            'ViewVendor.TaxExemption',
            'AddEditUnit',
            'ViewUnit.AddEditUnit',
            'CustomerOrder_V2.AddEditUnit',
            'ViewCustomer.COU',
            'CustomerOrder.AddEditUnit',
            'ViewCustomer.AddEditCustomerContact',
            'AddEditPart',
            'ViewPart.EditPart',
            'ViewPart.PartAdjustmentInStock',
            'ViewPart.ModifyCostSummary',
            'ViewPart.ModifyCostSource',
            'ViewPart.ResolveOversold',
            'ViewPart.PrintBarCode',
            'ViewLabour.EditLabour',
            'AddEditLabour',
            'ViewKit.EditKit',
            'AddEditKit',
            'AddEditFee',
            'ViewFee.AddEditFee',
            'ViewUnit.AddUnitPriceAndCost',
            'CustomerOrder.HourlogPopup',
            'CustomerOrder.AddAttachment',
            'CustomerOrder.PrintServiceWorksheetPopUp',
            'CustomerOrder.SelectUnit',
            'CustomerOrder.DealUnit',
            'CustomerOrder.COActionModel',
            'AccountingIntegrationSettings.AddEditCategory',
             'ActiveOrdersForCustomer',
            'AddEditAppointment',
            'AddEditAppointment.AddEditCustomerV2',
            'AddEditAppointment.AddEditUnitV2',
            'VendorOrder.AddAttachment'
            ];  
        
        $rootScope.$on('$stateChangeSuccess', function (event, to, toParams, from, fromParams) {
            $rootScope.$previousState = from;
            $rootScope.$previousStateParams = fromParams;
            $rootScope.currentStateName = to.name;

            setCurrentStateParamsByStateName($rootScope.currentStateName, toParams);
            valiDatePermission($rootScope.currentStateName);
            setActivieState($rootScope.currentStateName);
            cssConfig($rootScope.currentStateName, $rootScope.$previousState.name);
            if (to.title != '' && to.title != undefined && to.title != null) {
                $rootScope.pageTitle = to.title;
            } else if (to.title == undefined && from.title != undefined) {
                $rootScope.pageTitle = from.title;
            } else {
                $rootScope.pageTitle = 'Blackpurl';
            }
        });
        
        $rootScope.getCssFilesBasedOnCurrentState = function() {
            var cssFileNames = [];
             angular.forEach($rootScope.stateNameToCssFileNamesMap, function(cssList, pageName) {
                 angular.forEach(cssList, function(cssFile) {
                     cssFileNames.push(cssFile);
                 });
             });
             return cssFileNames;
        }
        
        $rootScope.loadHtmlViewBasedOnCurrentState = function() {
            if($rootScope.currentStateName === 'VendorOrder' || $rootScope.currentStateName === 'ViewVendor' || $rootScope.currentStateName === 'ViewVendor' || $rootScope.currentStateName === 'ViewUnit' || $rootScope.currentStateName === 'ViewPart' 
                || $rootScope.currentStateName === 'ViewLabour' || $rootScope.currentStateName === 'ViewKit' || $rootScope.currentStateName === 'ViewFee' || $rootScope.currentStateName === 'ViewCustomer' || $rootScope.currentStateName === 'VendorOrderReceiving'  || $rootScope.currentStateName === 'VendorOrderInvoicing'  
                || $rootScope.currentStateName === 'ReturnVO' || $rootScope.currentStateName === 'Homesearch' || $rootScope.currentStateName === 'CustomerOrder'  || $rootScope.currentStateName === 'AddEditCustomer' || $rootScope.currentStateName === 'AddEditUnitV2'
                || $rootScope.currentStateName === 'SelectCustomer' || $rootScope.currentStateName === 'AddEditVendor' || $rootScope.currentStateName === 'AddEditUnit' || $rootScope.currentStateName === 'AddEditPart' || $rootScope.currentStateName === 'AddEditLabour' || $rootScope.currentStateName === 'AddEditKit'
                || $rootScope.currentStateName === 'AddEditFee' || $rootScope.currentStateName === 'TechScheduler.JobScheduler') {
                
                return true;
            } else {
                return false;
            }
        }
        
        function cssConfig(currentStateName, previousStateName) {
            if(childViewsStateList.indexOf(currentStateName) != -1) {
                switch (currentStateName) {
                    case 'AddEditCustomerV2':
                    case 'CustomerOrder_V2.AddEditCustomerV2':
                    case 'ViewCustomer.EditCustomerV2':
                    case 'AddEditAppointment.AddEditCustomerV2':
                          $rootScope.stateNameToCssFileNamesMap['AddEditCustomerV2'] = ['AddEditCustomer_V2.css','WeekScheduleGrid.css','AutoCompleteComponent.css','MiniCalendar.css'];
                          break;
                    case 'AddEditCustomer':
                    case 'ViewCustomer.EditCustomer':
                    case 'CustomerOrder.EditCustomer':
                    case 'CashSaleCO.AddCustomer':
                        $rootScope.stateNameToCssFileNamesMap['AddEditCustomer'] = ['AddEditCustomer.css'];
                        break;
                    case 'CustomerOrder_V2.AddEditLogTechnicianTime':
                        $rootScope.stateNameToCssFileNamesMap['AddEditLogTechnicianTime'] = ['AddEditLogTechnicianTime_V2.css', 'MiniCalendar.css'];
                        break;
                    case 'CustomerOrder_V2.AddEditTempUnit':
                    case 'AddEditUnitV2':
                    case 'AddEditAppointment.AddEditUnitV2':
                        $rootScope.stateNameToCssFileNamesMap['AddEditTempUnitV2'] = ['AddEditTempUnit_V2.css','JobScheduling.css', 'AutoCompleteComponent.css','MiniCalendar.css'];
                        break;
                    case 'User.AddEditTechnicianSchedule':
                    case 'TechScheduler.JobScheduler.AddEditTechnicianSchedule':
                        $rootScope.stateNameToCssFileNamesMap['AddEditTechnicianSchedule'] = ['AddEditTechnicianScheduling.css', 'MiniCalendar.css'];
                        break;
                    case 'CustomerOrder_V2.EditPricing':
                        $rootScope.stateNameToCssFileNamesMap['EditPricingV2'] = ['EditPricing_V2.css'];
                        break;
                    case 'CustomerOrder_V2.InvoiceToDeal':
                        $rootScope.stateNameToCssFileNamesMap['InvoiceToDealV2'] = ['InvoiceToDeal.css'];
                        break;
                    case 'CustomerOrder_V2.serviceJobAddAttachment':
                    case 'VendorOrder.AddAttachment':
                        $rootScope.stateNameToCssFileNamesMap['serviceJobAddAttachment'] = ['newUI.css', 'ServiceJobAttachment.css'];
                        break;
                    case 'CashSaleCO.CustomerMessagingPopUp':
                    case 'CustomerOrder.CustomerMessagingPopUp':
                    case 'CustomerOrder_V2.CustomerMessagingPopUp':
                    case 'ViewCustomer.CustomerMessagingPopUp':
                    case 'VendorOrder.CustomerMessagingPopUp':
                        $rootScope.stateNameToCssFileNamesMap['CustomerMessagingPopUp'] = ['CustomerMessagingPopup.css'];
                        break;
                    case 'CustomerOrder_V2.ServiceJobClaim':
                        $rootScope.stateNameToCssFileNamesMap['ServiceJobClaimV2'] = ['ServiceJobClaim_V2.css'];
                        break;
                    case 'CustomerOrder_V2.ServiceJobClaimResponse':
                        $rootScope.stateNameToCssFileNamesMap['ServiceJobClaimResponseV2'] = ['CustomerMessagingPopup.css' , 'ServiceJobClaimResponse_V2.css' , 'MiniCalendar.css']; //Why CustomerMessagingPopup.css is there
                        break;
                    case 'SelectCustomer':
                    case 'CashSaleCO.SelectCustomer':
                    case 'UnitOrdering.UnitOrderingVendorList.SelectCustomer':
                        $rootScope.stateNameToCssFileNamesMap['SelectCustomer'] = ['SelectCustomer.css'];
                        break;
                    case 'UnitOrdering.AddeditUnitOrder.UnitReceivingDialog':
                    case 'UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog':
                        $rootScope.stateNameToCssFileNamesMap['UnitReceivingDialog'] = ['UnitOrdering.css', 'MiniCalendar.css']; //Need review - why this css is required on this child view, it i already on parent view
                        break;
                    case 'JobClocking':
                        $rootScope.stateNameToCssFileNamesMap['JobClocking'] = ['newUI.css', 'JobClocking.css', 'MiniCalendar.css'];
                        break;
                    case 'PayrollClocking':
                        $rootScope.stateNameToCssFileNamesMap['PayrollClocking'] = ['newUI.css', 'JobClocking.css', 'PayrollClocking.css', 'MiniCalendar.css'];
                        break;
                    case 'AddEditVendor':
                    case 'ViewVendor.EditVendor':
                        $rootScope.stateNameToCssFileNamesMap['AddEditVendor'] = ['AddEditVendor.css'];
                        break;
                    case 'ViewVendor.AddEditPOType':
                        $rootScope.stateNameToCssFileNamesMap['AddEditPOType'] = ['AddEditPOType.css']; //Need review - one Ui-view is also added on page, which is not added in app.js
                        break;
                    case 'ViewVendor.AddEditVendorContact':
                        $rootScope.stateNameToCssFileNamesMap['AddEditVendorContact'] = ['AddEditVendorContact.css']; 
                        break;
                    case 'ViewVendor.AddEditProduct':
                        $rootScope.stateNameToCssFileNamesMap['AddEditProduct'] = ['AddEditProduct.css']; 
                        break;
                    case 'ViewCustomer.TaxExemption':
                    case 'ViewVendor.TaxExemption':
                        $rootScope.stateNameToCssFileNamesMap['TaxExemption'] = ['AddEditTaxExemption.css']; 
                        break;
                    case 'AddEditUnit':
                    case 'ViewUnit.AddEditUnit':
                    case 'ViewCustomer.COU':
                    case 'CustomerOrder_V2.AddEditUnit':
                    case 'CustomerOrder.AddEditUnit':
                        $rootScope.stateNameToCssFileNamesMap['AddEditUnit'] = ['BPComponents.css', 'AddEditUnit.css']; 
                        break;
                    case 'ViewCustomer.AddEditCustomerContact':
                        $rootScope.stateNameToCssFileNamesMap['AddEditCustomerContact'] = ['AddEditCustomerContact.css']; 
                        break;
                    case 'AddEditPart':
                    case 'ViewPart.EditPart':
                        $rootScope.stateNameToCssFileNamesMap['AddEditPart'] = ['AddEditParts.css']; 
                        break;
                    case 'ViewPart.PartAdjustmentInStock':
                        $rootScope.stateNameToCssFileNamesMap['PartAdjustmentInStock'] = ['PartAdjustmentInStock.css']; 
                        break;
                    case 'ViewPart.ModifyCostSummary':
                        $rootScope.stateNameToCssFileNamesMap['ModifyCostSummary'] = ['ModifyCostSummary.css']; 
                        break;
                    case 'ViewPart.ModifyCostSource':
                        $rootScope.stateNameToCssFileNamesMap['ModifyCostSource'] = ['ModifyCostSource.css']; 
                        break;
                    case 'ViewPart.ResolveOversold':
                        $rootScope.stateNameToCssFileNamesMap['ResolveOversold'] = ['ResolveOversold.css']; 
                        break;
                    case 'ViewPart.PrintBarCode':
                        $rootScope.stateNameToCssFileNamesMap['PrintBarCode'] = ['PrintBarCode.css']; 
                        break;
                    case 'ViewLabour.EditLabour':
                    case 'AddEditLabour':
                        $rootScope.stateNameToCssFileNamesMap['AddEditLabour'] = ['AddEditLabour.css']; 
                        break;
                    case 'ViewKit.EditKit':
                    case 'AddEditKit':
                        $rootScope.stateNameToCssFileNamesMap['AddEditKit'] = ['AddEditKit.css']; 
                        break;
                    case 'AddEditFee':
                    case 'ViewFee.AddEditFee':
                        $rootScope.stateNameToCssFileNamesMap['AddEditFee'] = ['AddEditFee.css']; 
                        break;
                    case 'ViewUnit.AddUnitPriceAndCost':
                        $rootScope.stateNameToCssFileNamesMap['AddUnitPriceAndCost'] = ['AddUnitPriceAndCost.css']; 
                        break;
                    case 'CustomerOrder.HourlogPopup':
                        $rootScope.stateNameToCssFileNamesMap['LogServiceWorkPopWizard'] = ['LogServiceWorkPopWizard.css']; 
                        break;
                    case 'CustomerOrder.AddAttachment':
                        $rootScope.stateNameToCssFileNamesMap['AddAttachment'] = ['AddAttachment.css']; 
                        break;
                    case 'CustomerOrder.PrintServiceWorksheetPopUp':
                        $rootScope.stateNameToCssFileNamesMap['PrintServiceWorksheetPopUp'] = ['PrintServiceWorkSheetPopUp.css']; 
                        break;
                    case 'CustomerOrder.SelectUnit':
                        $rootScope.stateNameToCssFileNamesMap['SelectUnit'] = ['SelectUnit.css']; 
                        break;
                    case 'CustomerOrder.DealUnit':
                        $rootScope.stateNameToCssFileNamesMap['DealUnit'] = ['DealUnit.css']; 
                        break;
                    case 'CustomerOrder.COActionModel':
                        $rootScope.stateNameToCssFileNamesMap['COActionModel'] = ['COActionModel.css']; 
                        break;
                    case 'AccountingIntegrationSettings.AddEditCategory':
                        $rootScope.stateNameToCssFileNamesMap['AddEditCategory'] = ['AddEditCategory.css']; 
                        break;
                    case 'ActiveOrdersForCustomer':
                        $rootScope.stateNameToCssFileNamesMap['ActiveOrdersForCustomer'] = ['ActiveOrdersForCustomer.css']; 
                        break;
                   case 'AddEditAppointment':
                        $rootScope.stateNameToCssFileNamesMap['AddEditAppointment'] = ['AutoCompleteComponent.css', 'bootstrap4.css','AddEditTextTag.css','AddEditAppointment.css','TechScheduler.css','WeekScheduleGrid.css','MiniCalendar.css']; 
                        break;
                }
            } else {
                switch (currentStateName) {
                    case 'CustomerOrder_V2':
                        $rootScope.stateNameToCssFileNamesMap = {'CustomerOrder_V2' : ['CustomerOrder_V2.css', 'AutoCompleteComponent.css', 'BPComponents.css', 'MiniCalendar.css', 'ViewRelatedPart.css', 'RemoveDealUnitPopup.css',  'AddDeposit_V2.css', 'DuplicatePartModalWindow_V2.css', 'COUInfoPopUp.css', 'bootstrap4.css','BpModalDialog.css']};
                        break;
                    case 'FusionMapping' :
                        $rootScope.stateNameToCssFileNamesMap = {'FusionMapping' : ['newUI.css','TechScheduler.css','AutoCompleteComponent.css','FusionMapping.css']};
                        break;
                    case 'DealerLookup':
                        $rootScope.stateNameToCssFileNamesMap = {'DealerLookup' : ['BPNewUI.css','DealerLookUp.css']};
                    break;
                    case 'FusionBenchmarking' :
                        $rootScope.stateNameToCssFileNamesMap = {'FusionBenchmarking' : ['newUI.css','TechScheduler.css','AutoCompleteComponent.css','FusionBenchmarking.css']};
                        break;
                    case 'FormRepository' :
                        $rootScope.stateNameToCssFileNamesMap = {'FormRepository' : ['newUI.css','TechScheduler.css','AutoCompleteComponent.css','FormRepository.css']};
                        break;
                    case 'CashDrawer' :
                        $rootScope.stateNameToCssFileNamesMap = {'CashDrawer' : ['newUI.css','CashDrawers.css','BPNewUI.css']};
                        break;
                    case 'CustomerOrder':
                        $rootScope.stateNameToCssFileNamesMap = {'CustomerOrder' : ['CustomerOrder.css', 'PartPopUpOnVendorOrder.css', 'COUInfoPopUp.css', 'DealFinancing.css', 'ServiceOrderWizard.css']};
                        break;
                    case 'VendorOrder':
                        $rootScope.stateNameToCssFileNamesMap = {'VendorOrder' : ['VendorOrder.css', 'VendorOrderPopUp.css', 'VenderOrderLineItemPartDetail.css', 'COPopup.css', 'PartPopUpOnVendorOrder.css', 'VendorInfo.css', 'BPComponents.css']};
                        break;
                    case 'VendorOrderReceiving':
                        $rootScope.stateNameToCssFileNamesMap = {'VendorOrderReceiving' : ['VendorOrderReceiving.css', 'VendorInfo.css', 'COPopup.css', 'PartPopUpOnVendorOrder.css']};
                        break;
                    case 'ReturnVO':
                        $rootScope.stateNameToCssFileNamesMap = {'ReturnVO' : ['VendorOrder.css', 'VendorReturn.css', 'VendorOrderPopUp.css', 'VenderOrderLineItemPartDetail.css', 'COPopup.css', 'PartPopUpOnVendorOrder.css', 'VendorInfo.css']};
                        break;
                    case 'VendorOrderInvoicing':
                        $rootScope.stateNameToCssFileNamesMap = {'VendorOrderInvoicing' : ['VendorOrderInvoicing.css', 'InvoiceHistoryMiniPagelayout.css', 'VendorInfo.css', 'PartPopUpOnVendorOrder.css']};
                        break;
                    case 'UnitOrdering':
                    case 'UnitOrdering.UnitOrderingVendorList':
                        $rootScope.stateNameToCssFileNamesMap = {'UnitOrdering' : ['newUI.css', 'UnitOrdering.css', 'MiniCalendar.css']};
                        break;
                    case 'UnitOrdering.ViewVendorOrderUnits':  
                        $rootScope.stateNameToCssFileNamesMap = {'UnitOrdering' : ['newUI.css', 'UnitOrdering.css', 'MiniCalendar.css', 'ViewVendorOrderUnits.css']};
                        break;
                    case 'UnitOrdering.AddeditUnitOrder':  
                        $rootScope.stateNameToCssFileNamesMap = {'UnitOrdering' : ['newUI.css', 'UnitOrdering.css', 'MiniCalendar.css', 'AddEditUnitOrder.css']};
                        break;
                    case 'JobScheduling':  
                        $rootScope.stateNameToCssFileNamesMap = {'JobScheduling' : ['JobScheduling.css', 'newUI.css']};
                        break;
                    case 'ViewCustomer':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewCustomer' : ['ViewCustomer.css', 'COUInfoPopUp.css']};
                        break;
                    case 'ViewVendor':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewVendor' : ['ViewVendor.css', 'ViewVendorRelatedList.css']};
                        break;
                    case 'ViewPart':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewPart' : ['ViewPart.css', 'PartPopUpOnVendorOrder.css', 'ViewPartInformation.css','BPComponents.css']};
                        break;
                    case 'ViewLabour':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewLabour' : ['ViewLabour.css']};
                        break;
                    case 'ViewKit':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewKit' : ['ViewKit.css', 'PartPopUpOnVendorOrder.css']};
                        break;
                    case 'ViewFee':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewFee' : ['ViewFee.css']};
                        break;
                    case 'ViewUnit':  
                        $rootScope.stateNameToCssFileNamesMap = {'ViewUnit' : ['ViewUnit.css', 'AttachmentPopup.css', 'BPComponents.css']};
                        break;
                    case 'HomeSearch':
                        $rootScope.stateNameToCssFileNamesMap = {'HomeSearch' : ['homesearch.css']};
                        break;
                    case 'UserSetting':
                        $rootScope.stateNameToCssFileNamesMap = {'UserSetting' : ['UserSettings.css', 'bootstrap4.css', 'AccountSettings.css', 'UserPermissionsHeader.css', 'newUI.css','AutoCompleteComponent.css']};
                        break;
                    case 'User':
                        $rootScope.stateNameToCssFileNamesMap = {'User' : ['UserPermissionsHeader.css', 'UserSettings.css']};
                        break;  
                    case 'GroupSummary':
                        $rootScope.stateNameToCssFileNamesMap = {'GroupSummary' : ['GroupSummary.css', 'UserPermissionsHeader.css', 'newUI.css']}; // Dinesh - Why not added bootstrap4.css
                        break;      
                    case 'EditGroupPermissions':
                        $rootScope.stateNameToCssFileNamesMap = {'EditGroupPermissions' : ['EditGroupPermissions.css', 'UserPermissionsHeader.css', 'newUI.css']};
                        break;
                    case 'LinkedFee':
                        $rootScope.stateNameToCssFileNamesMap = {'LinkedFee' : ['bootstrap4.css', 'UserPermissionsHeader.css','GroupSummary.css', 'LinkedFee.css', 'newUI.css']};
                        break;  
                    case 'AccountingIntegrationSettings':
                        $rootScope.stateNameToCssFileNamesMap = {'AccountingIntegrationSettings' : ['AutoCompleteComponent.css','AddEditCategory.css','AccountingIntegrationSettings.css']};
                        break;  
                    case 'TagManagement':
                        $rootScope.stateNameToCssFileNamesMap = {'TagManagement' : ['bootstrap4.css', 'GroupSummary.css', 'TagManagement.css', 'newUI.css']};
                        break;
                    case 'PriceFileImport':
                        $rootScope.stateNameToCssFileNamesMap = {'PriceFileImport' : ['PriceFileImport.css','CashSaleSTA.css']};
                        break;
                    case 'AccountingExport':
                        $rootScope.stateNameToCssFileNamesMap = {'AccountingExport' : ['AccountingExport.css']};
                        break;
                    case 'CashSaleCO':
                        $rootScope.stateNameToCssFileNamesMap = {'CashSaleCO' : ['CashSaleCo.css', 'CashSaleSTA.css']};
                        break;
                    case 'COAImport':
                        $rootScope.stateNameToCssFileNamesMap = {'COAImport' : ['COAImport.css']};
                        break;  
                    case 'CashReconciliation':
                        $rootScope.stateNameToCssFileNamesMap = {'CashReconciliation' : ['newUI.css', 'MiniCalendar.css', 'TechScheduler.css', 'CashReconciliation.css']};
                        break;
                    case 'homePage':
                        $rootScope.stateNameToCssFileNamesMap = {'homepage' : ['homepage.css']};
                        break;
                    case 'TechScheduler':
                        $rootScope.stateNameToCssFileNamesMap = {'TechScheduler' : ['BPComponents.css', 'GroupSummary.css', 'UserPermissionsHeader.css','TechScheduler.css','WeekScheduleGrid.css','MiniCalendar.css']};
                        break;
                    case 'LinkedForm':
                        $rootScope.stateNameToCssFileNamesMap = {'LinkedForm' : ['newUI.css','TechScheduler.css', 'AutoCompleteComponent.css', 'LinkedForm.css']};
                        break;
                    case 'TechScheduler.JobScheduler':
                        $rootScope.stateNameToCssFileNamesMap = {'TechScheduler' : ['BPComponents.css', 'GroupSummary.css', 'UserPermissionsHeader.css','TechScheduler.css','MiniCalendar.css','WeekScheduleGrid.css', 'JobScheduler.css']};
                        break;
                    default:
                        $rootScope.stateNameToCssFileNamesMap = {'homepage' : ['homepage.css']};
                        break;
                }
            }
        }
        
        function setCurrentStateParamsByStateName(currentStateName, currentStateParams) { //Store state params to get them when user changes state and again move to this state and url params are missing          
            if (currentStateName === 'UnitOrdering.ViewVendorOrderUnits' && currentStateParams.vendorId) {
                $rootScope.ViewVendorOrderUnitsParams = {
                    'vendorId': currentStateParams.vendorId
                }
            } else if (currentStateName === 'UnitOrdering.AddeditUnitOrder' && currentStateParams.vendorId) {
                $rootScope.AddEditUnitOrderParams = {
                    'vendorId': currentStateParams.vendorId,
                    'unitId': currentStateParams.unitId
                }
            }  else if (currentStateName === 'CustomerOrder_V2' && currentStateParams.AppointmentId) {
                $rootScope.CustomerOrder_V2Parms = {
                    'AppointmentId': currentStateParams.AppointmentId
                }
           }
        }

        function setActivieState(stateName) {
            if (localbViewStateList.indexOf(stateName) == -1) {
                if (stateName == 'CustomerOrder' || stateName == 'CashSaleCO') {
                    $rootScope.activeStateName = 'sell';
                } else if (stateName == 'VendorOrder' || stateName == 'VendorOrderReceiving' || stateName == 'VendorOrderInvoicing' ||
                    stateName == 'ReturnVO' || stateName == 'UnitOrdering' || stateName == 'UnitOrdering.UnitOrderingVendorList' ||
                    stateName == 'UnitOrdering.ViewVendorOrderUnits' || stateName == 'UnitOrdering.AddeditUnitOrder') {
                    $rootScope.activeStateName = 'order';
                } else if (stateName == 'JobScheduling' || stateName == 'TechScheduler' || stateName == 'TechScheduler.JobScheduler') {
                    $rootScope.activeStateName = 'schedule';
                } else if (stateName == 'UserSetting' || stateName == 'PriceFileImport' || stateName == 'CashReconciliation' || stateName == 'GroupSummary' || stateName == 'User' || stateName == 'GroupSummary' || stateName == 'TagManagement' || stateName == 'LinkedFee' || stateName == 'AccountingIntegrationSettings') {
                    $rootScope.activeStateName = 'setting';
                } else if (stateName == 'JobClocking' || stateName == 'PayrollClocking') {
                    $rootScope.activeStateName = 'Clocking';
                } else {
                    $rootScope.activeStateName = stateName;
                }
            }
        }

        function valiDatePermission(StateName) {
            if (StateName == 'UserSetting' && !$rootScope.GroupOnlyPermissions['System Settings']['enabled']) {
                $state.go('homePage');
            } else if ((StateName == 'CustomerOrder' || StateName == 'CustomerOrder_V2') && !$rootScope.GroupOnlyPermissions['Merchandise']['view'] && !$rootScope.GroupOnlyPermissions['Service job']['view'] && !$rootScope.GroupOnlyPermissions['Deal']['view'] && !$rootScope.GroupOnlyPermissions['Internal Service']['view']) {
                $state.go('homePage');
            } else if ((StateName == 'VendorOrder' || StateName == 'ReturnVO') && !$rootScope.GroupOnlyPermissions['Vendor order']['view']) {
                $state.go('homePage');
            } else if (StateName == 'VendorOrderInvoicing' && !$rootScope.GroupOnlyPermissions['Vendor invoicing']['view']) {
                $state.go('homePage');
            } else if (StateName == 'EditGroupPermissions' && !$rootScope.GroupOnlyPermissions['System Settings']['enabled']) {
                $state.go('homePage');
            } else if (StateName == 'GroupSummary' && !$rootScope.GroupOnlyPermissions['System Settings']['enabled']) {
                $state.go('homePage');
            }
        }
    }]);
    
    app.directive('routeLoadingIndicator', ['$rootScope', function ($rootScope) {
        return {
            restrict: 'E',
            template: '<div class="alert text-center pageloadDiv" ng-show="isRouteLoading"><div class="loadingIcon">Loading...</div></div>', // '<h1 ng-if="isRouteLoading">Loading...</h1>',
            link: function (scope, elem, attrs) {
                scope.isRouteLoading = false;
                $rootScope.$on('$stateChangeStart', function () {
                    scope.isRouteLoading = false;
                });
                $rootScope.$on('$stateChangeSuccess', function () {
                    scope.isRouteLoading = false;
                });
            }
        };
    }]);
    
    app.directive('hrefDir', function () {
        return {
            restrict: 'A',
            link: function (scope, elem, attrs) {
                var target = attrs.hrefDir;
                elem.bind('click', function () {
                    var isElementHidden = angular.element('#' + target).hasClass('ng-hide');
                    if (!isElementHidden) {
                        angular.element('html, body').stop().animate({
                            scrollTop: angular.element('#' + target).offset().top - 105
                        }, 500);
                    }
                });
            }
        };
    });
    
    app.config(['$stateProvider', '$controllerProvider', '$compileProvider', '$filterProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', '$translateProvider', '$translateStaticFilesLoaderProvider', function ($stateProvider, $controllerProvider, $compileProvider, $filterProvider, $urlRouterProvider, $provide, $stickyStateProvider, $translateProvider, $translateStaticFilesLoaderProvider) {

        $translateProvider.useStaticFilesLoader({
            prefix: window.$Global.LocalePath + '/locale-',
            suffix: '.json'
        });
        $translateProvider.preferredLanguage('en_US');
        $translateProvider.fallbackLanguage('en_US');

        if (window.$Global.UserLanguage) {
            $translateProvider.preferredLanguage(window.$Global.UserLanguage);
        }

        app.register = {
            controller: $controllerProvider.register,
            directive: $compileProvider.directive,
            filter: $filterProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        $urlRouterProvider.otherwise('/homePage');
        var url = window.location.origin;
        var homePageURl = url + '/apex/HomePage';
        var addEditCustomerUrl = url + '/apex/AddEditCustomer';
        var addEditCustomerV2Url = url + '/apex/AddEditCustomer_V2';
        var addEditVendorUrl = url + '/apex/AddEditVendor';
        var AddEditPartsUrl = url + '/apex/AddEditParts';
        var addEditKitUrl = url + '/apex/AddEditKit';
        var addEditFeeUrl = url + '/apex/AddEditFee';
        var addEditUnitUrl = url + '/apex/AddEditUnit';
        var AddEditUnitV2Url = url + '/apex/AddEditTempUnit_V2';
        var addEditLabourUrl = url + '/apex/AddEditLabour';
        var SelectCustomerUrl = url + '/apex/SelectCustomer';
        var ActiveOrdersForCustomerUrl = url + '/apex/ActiveOrdersForCustomer';
        var ViewCustomerUrl = url + '/apex/ViewCustomer';
        var viewVendorUrl = url + '/apex/ViewVendor';
        var ViewPartUrl = url + '/apex/ViewPart';
        var viewLabourUrl = url + '/apex/ViewLabour';
        var viewKitUrl = url + '/apex/ViewKit';
        var viewFeeUrl = url + '/apex/ViewFee';
        var viewUnitUrl = url + '/apex/ViewUnit';
        var cashSaleCOUrl = url + '/apex/CashSaleCO';
        var VendorOrderUrl = url + '/apex/VendorOrder';
        var VendorOrderInvoicingUrl = url + '/apex/VendorOrderInvoicing';
        var vendorOrderReceivingUrl = url + '/apex/VendorOrderReceiving';
        var CustomerOrderURl = url + '/apex/CustomerOrder';
        var HomeSearchURl = url + '/apex/HomeSearchGrid';
        var AccountingIntegrationSettingsUrl = url + '/apex/AccountingIntegrationSettings';
        var AccountingExportUrl = url + '/apex/AccountingExport';
        var UserSettingUrl = url + '/apex/UserSettings';
        var GroupSummaryUrl = url + '/apex/GroupSummary';
        var EditGroupPermissionsUrl = url + '/apex/EditGroupPermissions';
        var PriceFileImportUrl = url + '/apex/PriceFileImport';
        var COAImportUrl = url + '/apex/COAImport';
        var AddEditCategoryUrl = url + '/apex/AddEditCategory';
        var JobSchedulingUrl = url + '/apex/JobScheduling';
        var LinkedFeeUrl = url + '/apex/LinkedFee';
        var LinkedFormUrl = url + '/apex/LinkedForm';
        var TagManagementUrl = url + '/apex/TagManagement';
        var ReturnVOUrl = url + '/apex/ReturnVO';
        var CashReconciliationUrl = url + '/apex/CashReconciliation';
        var JobClockingUrl = url + '/apex/JobClocking';
        var PayrollClockingUrl = url + '/apex/PayrollClocking';
        var UserUrl = url + '/apex/User';
        var CustomerOrder_V2Url = url + '/apex/CustomerOrder_V2';
        var UnitOrderingUrl = url + '/apex/UnitOrdering';
        var AddEditAppointmentUrl = url + '/apex/AddEditAppointment'; 
        var TechSchedulerUrl = url + '/apex/TechScheduler';
        var JobSchedulerUrl = url + '/apex/JobScheduler';
        var AddEditTechnicianScheduling_V2Url = url + '/apex/AddEditTechnicianScheduling';
        var FormRepositoryUrl = url + '/apex/FormRepository'; 
        var FusionMappingUrl = url + '/apex/FusionMapping';
        var DealerLookupUrl = url + '/apex/DealerLookup';
        var FusionBenchmarkingUrl = url + '/apex/FusionBenchmarking';
        var FormAttachmentModalUrl = url + '/apex/ServiceJobAttachment'; 
        var CashDrawerUrl = url + '/apex/CashDrawer';
        
        function resolveController(names) {
            return {
                load: ['$q', '$rootScope', function ($q, $rootScope) {
                    var defer = $q.defer();
                    require(names, function () {
                        defer.resolve();
                        $rootScope.$apply();
                    });
                    return defer.promise;
                }]
            }
        }
        $stateProvider.state('homePage', {
            url: '/homePage',
            title: 'Blackpurl',
            views: {
                a: angularAMD.route({
                    templateUrl: homePageURl,
                    controller: 'HomePageCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder_V2', {
            url: '/CustomerOrder_V2?Id:AppointmentId',
            title: 'CustomerOrder',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: CustomerOrder_V2Url,
                    controller: 'CustomerOrderCtrl_V2'
                })
            },
            sticky: true
        }).state('FusionMapping', {
            url: '/FusionMapping',
            title: 'Fusion Mapping',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: FusionMappingUrl,
                    controller: 'FusionMappingCtrl'
                })
            },
            sticky: true
        }).state('DealerLookup', {
            url: '/DealerLookup',
            title: 'Dealer Lookup',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: DealerLookupUrl,
                    controller: 'DealerLookupCtrl'
                })
            },
            sticky: true
        }).state('FusionBenchmarking', {
            url: '/FusionBenchmarking',
            title: 'Fusion Benchmarking',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: FusionBenchmarkingUrl,
                    controller: 'FusionBenchmarkingCtrl'
                })
            },
            sticky: true
        }).state('FormRepository', {
            url: '/FormRepository',
            title: 'Form Repository',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: FormRepositoryUrl,
                    controller: 'FormRepositoryCtrl'
                })
            },
            sticky: true
        }).state('CashDrawer', {
            url: '/CashDrawer',
            title: 'Cash Drawer',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: CashDrawerUrl,
                    controller: 'CashDrawerCtrl'
                })
            },
            sticky: true
        }).state('UserSetting', {
            url: '/UserSetting?Id',
            title: 'System Settings',
            views: {
                a: angularAMD.route({
                    templateUrl: UserSettingUrl,
                    controller: 'userSettingController'
                })
            },
            sticky: true
        }).state('User', {
            url: '/User?Id',
            title: 'User',
            views: {
                a: angularAMD.route({
                    templateUrl: UserUrl,
                    controller: 'UserCtrl'
                })
            },
            sticky: true
        }).state('GroupSummary', {
            url: '/GroupSummary',
            title: 'User Permissions',
            views: {
                a: angularAMD.route({
                    templateUrl: GroupSummaryUrl,
                    controller: 'GroupSummaryCtrl'
                })
            },
            sticky: true
        }).state('EditGroupPermissions', {
            url: '/EditGroupPermissions?Id',
            title: 'User Permissions',
            views: {
                a: angularAMD.route({
                    templateUrl: EditGroupPermissionsUrl,
                    controller: 'EditGroupPermissionsCtrl'
                })
            },
            sticky: true
        }).state('ViewCustomer', {
            url: '/ViewCustomer?Id',
            title: 'Customer',
            views: {
                a: angularAMD.route({
                    templateUrl: ViewCustomerUrl,
                    controller: 'ViewCustomerCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder', {
            url: '/CustomerOrder?Id',
            title: 'Customer Order',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: CustomerOrderURl,
                    controller: 'CustomerOrderCtrl'
                })
            },
            sticky: true
        }).state('ViewVendor', {
            url: '/ViewVendor?Id',
            title: 'Vendor',
            views: {
                a: angularAMD.route({
                    templateUrl: viewVendorUrl,
                    controller: 'ViewVendorCtrl'
                }),
            },
            sticky: true
        }).state('JobScheduling', {
            url: '/JobScheduling',
            title: 'Schedule',
            views: {
                a: angularAMD.route({
                    templateUrl: JobSchedulingUrl,
                    controller: 'JobSchedulingCtrl'
                })
            },
            sticky: true
        }).state('ViewPart', {
            url: '/ViewPart?Id',
            title: 'Part',
            views: {
                a: angularAMD.route({
                    templateUrl: ViewPartUrl,
                    controller: 'ViewPartCtrl'
                })
            },
            sticky: true
        }).state('ViewLabour', {
            title: 'Labor Code',
            url: '/ViewLabour?Id',
            template: viewLabourUrl,
            controller: 'ViewLabourCtrl',
            views: {
                a: angularAMD.route({
                    templateUrl: viewLabourUrl,
                    controller: 'ViewLabourCtrl'
                }),
            },
            sticky: true
        }).state('ViewLabour.EditLabour', {
            url: '',
            title: 'Labor Code',
            params: {
                EditLabourParams: {},
            },
            views: {
                EditLabour: angularAMD.route({
                    templateUrl: addEditLabourUrl,
                    controller: 'AddEditLabourCtrl'
                })
            }
        }).state('ViewKit', {
            title: 'Kit',
            url: '/ViewKit?Id',
            views: {
                a: angularAMD.route({
                    templateUrl: viewKitUrl,
                    controller: 'ViewKitCtrl'
                }),
            },
            sticky: true
        }).state('ViewKit.EditKit', {
            url: '',
            title: 'Kit',
            params: {
                EditKitParams: {},
            },
            views: {
                EditKit: angularAMD.route({
                    templateUrl: addEditKitUrl,
                    controller: 'AddEditKitCtrl'
                })
            }
        }).state('ViewFee', {
            url: '/ViewFee?Id',
            title: 'Fee',
            views: {
                a: angularAMD.route({
                    templateUrl: viewFeeUrl,
                    controller: 'ViewFeeCtrl'
                })
            },
            sticky: true
        }).state('ViewUnit', {
            url: '/ViewUnit?Id',
            title: 'Unit',
            views: {
                a: angularAMD.route({
                    templateUrl: viewUnitUrl,
                    controller: 'ViewUnitCtrl'
                })
            },
            sticky: true
        }).state('CashSaleCO', {
            url: '/CashSaleCO?Id',
            title: 'Blackpurl',
            views: {
                a: angularAMD.route({
                    templateUrl: cashSaleCOUrl,
                    controller: 'CashSaleCOCtrl'
                })
            },
            sticky: true
        }).state('HomeSearch', {
            url: '/HomeSearch?:q:type',
            params: {
                filterparam: undefined,
                additionalFieldParam: undefined,
            },
            title: 'Advanced Search',
            views: {
                a: angularAMD.route({
                    templateUrl: HomeSearchURl,
                    controller: 'HomeSearchCtrl'
                })
            },
            sticky: true
        }).state('AccountingIntegrationSettings', {
            url: '/AccountingIntegrationSettings',
            title: 'Accounting Setup',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: AccountingIntegrationSettingsUrl,
                    controller: 'AccountingIntegrationSettingsCtrl'
                })
            },
            sticky: true
        }).state('AccountingIntegrationSettings.AddEditCategory', {
            url: '',
            title: 'Blackpurl',
            params: {
                AddEditCategoryParams: {},
            },
            views: {
                AddEditCategory: angularAMD.route({
                    templateUrl: AddEditCategoryUrl,
                    controller: 'AddEditCategoryCtrl'
                })
            },
            sticky: true
        }).state('AccountingExport', {
            url: '/AccountingExport',
            title: 'Blackpurl',
            views: {
                a: angularAMD.route({
                    templateUrl: AccountingExportUrl,
                    controller: 'AccountingExportCtrl'
                })
            },
            sticky: true
        }).state('PriceFileImport', {
            url: '/PriceFileImport',
            title: 'Price File Import',
            views: {
                a: angularAMD.route({
                    templateUrl: PriceFileImportUrl,
                    controller: 'PriceFileImportCtrl'
                })
            },
            sticky: true
        }).state('COAImport', {
            url: '/COAImport',
            title: 'Blackpurl',
            views: {
                a: angularAMD.route({
                    templateUrl: COAImportUrl,
                    controller: 'COAImportCtrl'
                })
            },
            sticky: true
        }).state('VendorOrder', {
            url: '/VendorOrder?Id',
            title: 'Vendor Order',
            views: {
                a: angularAMD.route({
                    templateUrl: VendorOrderUrl,
                    controller: 'VendorOrderCtrl'
                })
            },
            sticky: true
        }).state('ReturnVO', {
            url: '/ReturnVO?Id',
            title: 'Return VO',
            views: {
                a: angularAMD.route({
                    templateUrl: ReturnVOUrl,
                    controller: 'ReturnVOCtrl'
                })
            },
            sticky: true
        }).state('UnitOrdering', {
            url: '/UnitOrdering',
            title: 'Unit Ordering',
            views: {
                a: angularAMD.route({
                    templateUrl: UnitOrderingUrl,
                    controller: 'UnitOrderingCtrl'

                })
            },
            sticky: true
        }).state('VendorOrderInvoicing', {
            url: '/VendorOrderInvoicing?Id',
            title: 'Vendor Invoicing',
            views: {
                a: angularAMD.route({
                    templateUrl: VendorOrderInvoicingUrl,
                    controller: 'VendorOrderInvoicingCtrl'
                })
            },
            sticky: true
        }).state('LinkedFee', {
            url: '/LinkedFee',
            title: 'Linked Fee',
            views: {
                a: angularAMD.route({
                    templateUrl: LinkedFeeUrl,
                    controller: 'LinkedFeeCtrl'
                })
            },
            sticky: true
        }).state('LinkedForm', {
            url: '/LinkedFormManagement',
            title: 'Linked Form Management',
            views: {
                a: angularAMD.route({
                    templateUrl: LinkedFormUrl,
                    controller: 'LinkedFormCtrl'
                })
            },
            sticky: true
        }).state('TagManagement', {
            url: '/TagManagement',
            title: 'Tag Management',
            views: {
                a: angularAMD.route({
                    templateUrl: TagManagementUrl,
                    controller: 'TagManagementCtrl'
                })
            },
            sticky: true
        }).state('VendorOrderReceiving', {
            url: '/VendorOrderReceiving?Id',
            title: 'Vendor Receiving',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: vendorOrderReceivingUrl,
                    controller: 'VendorOrderReceivingCtrl'
                })
            },
            sticky: true
        }).state('CashReconciliation', {
            url: '/CashReconciliation',
            title: 'Cash Reconciliation',
            views: {
                a: angularAMD.route({
                    templateUrl: CashReconciliationUrl,
                    controller: 'CashReconciliationCtrl'
                })
            },
            sticky: true
        }).state('TechScheduler', {
            url: '/Scheduler',
            title: 'Scheduler',
            params: {
                myParams: undefined,
            },
            views: {
                a: angularAMD.route({
                    templateUrl: TechSchedulerUrl,
                    controller: 'TechSchedulerCtrl'
                })
            },
            sticky: true
        }).state('TechScheduler.JobScheduler', {
            url: '',
            title: 'Scheduler',
            views: {
                techSchedularView: angularAMD.route({
                    templateUrl: JobSchedulerUrl,
                    controller: 'JobSchedulerCtrl'
                })
            },
            sticky: true
        });
        
        $stateProvider.state('AddEditCustomer', {
            params: {
                myParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: addEditCustomerUrl,
                    controller: 'AddEditCustomerCtrl'
                })
            }
        }).state('AddEditCustomerV2', {
            params: {
                myParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: addEditCustomerV2Url,
                    controller: 'AddEditCustomerCtrl_V2'
                })
            }
        }).state('JobClocking', {
            views: {
                b: angularAMD.route({
                    templateUrl: JobClockingUrl,
                    controller: 'JobClockingCtrl'
                })
            }
        }).state('PayrollClocking', {
            views: {
                b: angularAMD.route({
                    templateUrl: PayrollClockingUrl,
                    controller: 'PayrollClockingCtrl'
                })
            }
        }).state('SelectCustomer', {
            params: {
                myParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: SelectCustomerUrl,
                    controller: 'SelectCustomerCtrl'
                })
            }
        }).state('ActiveOrdersForCustomer', {
            params: {
                myParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: ActiveOrdersForCustomerUrl,
                    controller: 'ActiveOrdersForCustomerCtrl'
                })
            }
        }).state('AddEditVendor', {
            params: {
                myParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: addEditVendorUrl,
                    controller: 'AddEditVendorCtrl'
                })
            }
        }).state('AddEditPart', {
            views: {
                b: angularAMD.route({
                    templateUrl: AddEditPartsUrl,
                    controller: 'AddEditPartsCtrl'
                })
            }
        }).state('AddEditKit', {
            views: {
                b: angularAMD.route({
                    templateUrl: addEditKitUrl,
                    controller: 'AddEditKitCtrl'
                })
            }
        }).state('AddEditLabour', {
            views: {
                b: angularAMD.route({
                    templateUrl: addEditLabourUrl,
                    controller: 'AddEditLabourCtrl'
                })
            }
        }).state('AddEditUnit', {
            params: {
                AddEditUnitParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: addEditUnitUrl,
                    controller: 'AddEditUnitCtrl'
                })
            }
        }).state('AddEditUnitV2', {
            params: {
                AddEditTempUnitParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: AddEditUnitV2Url,
                    controller: 'AddEditTempUnitCtrl_V2'
                })
            }
        }).state('AddEditAppointment.AddEditUnitV2', {
            params: {
                AddEditTempUnitParams: {},
            },
            views: {
                AddEditTempUnit: angularAMD.route({
                    templateUrl: AddEditUnitV2Url,
                    controller: 'AddEditTempUnitCtrl_V2'
                })
            }
        }).state('ViewUnit.AddEditUnit', {
            url: '',
            title: 'Unit',
            params: {
                AddEditUnitParams: {},
            },
            views: {
                EditUnit: angularAMD.route({
                    templateUrl: addEditUnitUrl,
                    controller: 'AddEditUnitCtrl'
                })
            }
        }).state('CustomerOrder_V2.AddEditUnit', {
            url: '',
            title: 'Unit',
            params: {
                AddEditUnitParams: {},
            },
            views: {
                EditUnit: angularAMD.route({
                    templateUrl: addEditUnitUrl,
                    controller: 'AddEditUnitCtrl'
                })
            }
        }).state('AddEditFee', {
            views: {
                b: angularAMD.route({
                    templateUrl: addEditFeeUrl,
                    controller: 'AddEditFeeCtrl'
                })
            }
        }).state('ViewFee.AddEditFee', {
            url: '',
            title: 'Fee',
            params: {
                feeParams: {},
            },
            views: {
                EditFee: angularAMD.route({
                    templateUrl: addEditFeeUrl,
                    controller: 'AddEditFeeCtrl'
                })
            }
        }).state('AddEditAppointment', {
            params: {
                AddEditAppointmentParams: {},
            },
            views: {
                b: angularAMD.route({
                    templateUrl: AddEditAppointmentUrl,
                    controller: 'AddEditAppointmentCtrl'
                })
            }
        }).state('AddEditAppointment.AddEditCustomerV2', {
            params: {
                AddEditCustomerParams: {},
            },
            views: {
                AddEditCustomer: angularAMD.route({
                    templateUrl: addEditCustomerV2Url,
                    controller: 'AddEditCustomerCtrl_V2'
                })
            }
        }).state('User.AddEditTechnicianSchedule', {
            url: '',
            title: 'Technician Scheduling',
            params: {
                AddEditTechnicianScheduleParams: {},
            },
            views: {
                AddEditTechnicianSchedule: angularAMD.route({
                    templateUrl: AddEditTechnicianScheduling_V2Url,
                    controller: 'AddEditTechnicianScheduleCtrl'
                })
            }
        }).state('TechScheduler.JobScheduler.AddEditTechnicianSchedule', {
            url: '',
            title: 'Technician Scheduling',
            params: {
                AddEditTechnicianScheduleParams: {},
            },
            views: {
                AddEditTechnicianSchedule: angularAMD.route({
                    templateUrl: AddEditTechnicianScheduling_V2Url,
                    controller: 'AddEditTechnicianScheduleCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var ViewVendorChildApp = angular.module('routerApp.ViewVendorChildApp', ['ui.router']);
    ViewVendorChildApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        ViewVendorChildApp.register = {
            controller: $controllerProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        var url = window.location.origin;
        var addEditPOTypeURl = url + '/apex/AddEditPOType';
        var addEditVendorContactURl = url + '/apex/AddEditVendorContact';
        var addEditProductURl = url + '/apex/AddEditProduct';
        var AddEditVendorUrl = url + '/apex/AddEditVendor';
        $stateProvider.state('ViewVendor.AddEditPOType', {
            url: '',
            title: 'Vendor',
            params: {
                AddEditPOTypeParams: {},
            },
            views: {
                VendorPOType: angularAMD.route({
                    templateUrl: addEditPOTypeURl,
                    controller: 'AddEditPOTypeCtrl'
                })
            },
            sticky: true
        }).state('ViewVendor.AddEditVendorContact', {
            url: '',
            title: 'Vendor',
            params: {
                AddEditVendorContactParams: {},
            },
            views: {
                VendorContact: angularAMD.route({
                    templateUrl: addEditVendorContactURl,
                    controller: 'AddEditVendorContactCtrl'
                })
            },
            sticky: true
        }).state('ViewVendor.AddEditProduct', {
            url: '',
            title: 'Vendor',
            params: {
                AddEditProductParams: {},
            },
            views: {
                VendorProduct: angularAMD.route({
                    templateUrl: addEditProductURl,
                    controller: 'AddEditProductCtrl'
                })
            },
            sticky: true
        }).state('ViewVendor.EditVendor', {
            url: '',
            title: 'Vendor',
            params: {
                EditVendorParams: {},
            },
            views: {
                EditVendor: angularAMD.route({
                    templateUrl: AddEditVendorUrl,
                    controller: 'AddEditVendorCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var CashSaleCOChildApp = angular.module('routerApp.CashSaleCOChildApp', ['ui.router']);
    CashSaleCOChildApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        var url = window.location.origin;
        var SelectCustomerUrl = url + '/apex/SelectCustomer';
        var CustomerMessagingPopupUrl = url + '/apex/CustomerMessagingPopup';
        $stateProvider.state('CashSaleCO.SelectCustomer', {
            url: '',
            title: 'Blackpurl',
            params: {
                myParams: {},
            },
            views: {
                CashSaleCOChildView: angularAMD.route({
                    templateUrl: SelectCustomerUrl,
                    controller: 'SelectCustomerCtrl'
                })
            }
        }).state('CashSaleCO.CustomerMessagingPopUp', {
            url: '',
            title: 'Blackpurl',
            params: {
                messagingInfoParams: {},
            },
            views: {
                CashSaleCOChildView: angularAMD.route({
                    templateUrl: CustomerMessagingPopupUrl,
                    controller: 'CustomerMessagingCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);

    var UnitOrderingChildApp = angular.module('routerApp.UnitOrderingChildApp', ['ui.router']);
    CashSaleCOChildApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        var url = window.location.origin;
        var SelectCustomerUrl = url + '/apex/SelectCustomer';
        var UnitOrderingVendorListUrl = url + '/apex/UnitOrderingVendorList';
        var ViewVendorOrderUnitsUrl = url + '/apex/ViewVendorOrderUnits';
        var AddeditUnitOrderUrl = url + '/apex/AddEditUnitOrder';
        var UnitReceivingUrl = url + '/apex/UnitReceivingDialog';

        $stateProvider.state('UnitOrdering.UnitOrderingVendorList.SelectCustomer', {
            url: '',
            title: 'Unit Ordering',
            params: {
                myParams: {},
            },
            views: {
                UnitOrderingChildView: angularAMD.route({
                    templateUrl: SelectCustomerUrl,
                    controller: 'SelectCustomerCtrl'
                })
            }
        }).state('UnitOrdering.UnitOrderingVendorList', {
            url: '/vendors',
            title: 'Unit Ordering',
            views: {
                UnitOrder: angularAMD.route({
                    templateUrl: UnitOrderingVendorListUrl,
                    controller: 'UnitOrderingVendorListCtrl'
                })
            },
            sticky: true
        }).state('UnitOrdering.ViewVendorOrderUnits', {
            url: '/UnitList?vendorId',
            title: 'Unit Ordering',
            params: {
                ViewVendorOrderUnitsParams: {},
            },
            views: {
                UnitOrder: angularAMD.route({
                    templateUrl: ViewVendorOrderUnitsUrl,
                    controller: 'ViewVendorOrderUnitsCtrl'
                })
            },
            sticky: true
        }).state('UnitOrdering.AddeditUnitOrder', {
            url: '/AddEditUnitOrder?vendorId:unitId',
            title: 'Unit Ordering',
            params: {
                AddEditUnitOrderParams: {},
            },
            views: {
                UnitOrder: angularAMD.route({
                    templateUrl: AddeditUnitOrderUrl,
                    controller: 'AddEditUnitOrderCtrl'
                })
            },
            sticky: true
        }).state('UnitOrdering.AddeditUnitOrder.UnitReceivingDialog', {
            url: '',
            title: 'Unit Receiving',
            params: {},
            views: {
                UnitReceiving: angularAMD.route({
                    templateUrl: UnitReceivingUrl,
                    controller: 'UnitReceivingCtrl'
                })
            }
        }).state('UnitOrdering.ViewVendorOrderUnits.UnitReceivingDialog', {
            url: '',
            title: 'Unit Receiving',
            params: {},
            views: {
                UnitReceiving: angularAMD.route({
                    templateUrl: UnitReceivingUrl,
                    controller: 'UnitReceivingCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);

    var AddUnitPriceAndCostApp = angular.module('routerApp.AddUnitPriceAndCostApp', ['ui.router']);
    AddUnitPriceAndCostApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        AddUnitPriceAndCostApp.register = {
            controller: $controllerProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        var url = window.location.origin;
        var addUnitPriceAndCostUrl = url + '/apex/AddUnitPriceAndCost';
        $stateProvider.state('ViewUnit.AddUnitPriceAndCost', {
            url: '',
            title: 'Unit',
            params: {
                myParams: {},
            },
            views: {
                AddUnitPriceAndCostView: angularAMD.route({
                    templateUrl: addUnitPriceAndCostUrl,
                    controller: 'AddUnitPriceAndCostCtrl'
                })
            },
            sticky: true
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var TaxExemptionApp = angular.module('routerApp.TaxExemptionApp', ['ui.router']);
    TaxExemptionApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        TaxExemptionApp.register = {
            controller: $controllerProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        var url = window.location.origin;
        var taxExemptionURl = url + '/apex/AddEditTaxExemption';
        $stateProvider.state('ViewCustomer.TaxExemption', {
            url: '',
            title: 'Customer',
            params: {
                TaxExemptionParams: {},
            },
            views: {
                TaxExemption: angularAMD.route({
                    templateUrl: taxExemptionURl,
                    controller: 'AddEditTaxExemptionCtrl'
                })
            },
            sticky: true
        }).state('ViewVendor.TaxExemption', {
            url: '',
            title: 'Vendor',
            params: {
                TaxExemptionParams: {},
            },
            views: {
                TaxExemption: angularAMD.route({
                    templateUrl: taxExemptionURl,
                    controller: 'AddEditTaxExemptionCtrl'
                })
            },
            sticky: true
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var UnitApp = angular.module('routerApp.UnitApp', ['ui.router']);
    UnitApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        UnitApp.register = {
            controller: $controllerProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        var url = window.location.origin;
        var UnitUrl = url + '/apex/AddEditUnit';
        $stateProvider.state('ViewCustomer.COU', {
            url: '',
            title: 'Customer',
            params: {
                AddEditUnitParams: {},
            },
            views: {
                COU: angularAMD.route({
                    templateUrl: UnitUrl,
                    controller: 'AddEditUnitCtrl'
                })
            }
        }).state('CustomerOrder.AddEditUnit', {
            url: '',
            title: 'Customer Order',
            params: {
                AddEditUnitParams: {},
            },
            views: {
                COU: angularAMD.route({
                    templateUrl: UnitUrl,
                    controller: 'AddEditUnitCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var COChildApp = angular.module('routerApp.COChildApp', ['ui.router']);
    COChildApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        var url = window.location.origin;
        var HoursLogPopuUrl = url + '/apex/LogServiceWorkPopWizard';
        var AddAttachmentUrl = url + '/apex/AddAttachment';
        var ServiceJobAddAttachmentUrl = url + '/apex/ServiceJobAttachment';
        var PrintServiceWorkSheetPopUpUrl = url + '/apex/PrintServiceWorksheetPopUp';
        var SelectUnitUrl = url + '/apex/SelectUnit';
        var COActionModelUrl = url + '/apex/COActionModel';
        var DealUnitUrl = url + '/apex/DealUnit';
        var CustomerMessagingPopupUrl = url + '/apex/CustomerMessagingPopup';
        var AddEditLogTechnicianTimeV2Url = url + '/apex/AddEditLogTechnicianTime_V2';
        var AddEditCustomerV2Url = url + '/apex/AddEditCustomer_V2';
        var ServiceJobClaimV2Url = url + '/apex/ServiceJobClaim_V2';
        var ServiceJobClaimResponseV2Url = url + '/apex/ServiceJobClaimResponse_V2';
        var EditPricingV2Url = url + '/apex/EditPricing_V2';
        var InvoiceToDealV2Url = url + '/apex/InvoiceToDeal_V2';

        var AddEditTempUnitV2Url = url + '/apex/AddEditTempUnit_V2';
        $stateProvider.state('CustomerOrder.HourlogPopup', {
            url: '',
            title: 'Customer Order',
            params: {
                HourlogParams: {},
            },
            views: {
                LogServiceWorkPopWizard: angularAMD.route({
                    templateUrl: HoursLogPopuUrl,
                    controller: 'LogServiceWorkPopWizardCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.AddAttachment', {
            url: '',
            title: 'Customer Order',
            params: {
                AddAttachmentParams: {},
            },
            views: {
                AddAttachment: angularAMD.route({
                    templateUrl: AddAttachmentUrl,
                    controller: 'AddAttachmentCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder_V2.serviceJobAddAttachment', {
            url: '',
            title: 'Customer Order',
            params: {
                AddAttachmentParams: {},
            },
            views: {
                AddAttachment: angularAMD.route({
                    templateUrl: ServiceJobAddAttachmentUrl,
                    controller: 'AddAttachmentCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.PrintServiceWorksheetPopUp', {
            url: '',
            title: 'Customer Order',
            params: {
                PrintServiceWorksheetParams: {},
            },
            views: {
                PrintServiceWorksheetPopUp: angularAMD.route({
                    templateUrl: PrintServiceWorkSheetPopUpUrl,
                    controller: 'PrintServiceWorkSheetPopUpCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.SelectUnit', {
            url: '',
            title: 'Customer Order',
            params: {
                SelectUnitParams: {},
            },
            views: {
                SelectUnit: angularAMD.route({
                    templateUrl: SelectUnitUrl,
                    controller: 'SelectUnitCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.COActionModel', {
            url: '',
            title: 'Customer Order',
            params: {
                COActionModelParams: {},
            },
            views: {
                COActionModel: angularAMD.route({
                    templateUrl: COActionModelUrl,
                    controller: 'COActionModelCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.DealUnit', {
            url: '',
            title: 'Customer Order',
            params: {
                DealUnitParams: {},
            },
            views: {
                DealUnit: angularAMD.route({
                    templateUrl: DealUnitUrl,
                    controller: 'DealUnitCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder.CustomerMessagingPopUp', {
            url: '',
            title: 'Customer Order',
            params: {
                messagingInfoParams: {},
            },
            views: {
                CustomerMessaging: angularAMD.route({
                    templateUrl: CustomerMessagingPopupUrl,
                    controller: 'CustomerMessagingCtrl'
                })
            },
            sticky: true
        }).state('CustomerOrder_V2.AddEditCustomerV2', {
            url: '',
            title: 'Customer Order',
            params: {
                AddEditCustomerParams: {},
            },
            views: {
                AddEditCustomerV2: angularAMD.route({
                    templateUrl: AddEditCustomerV2Url,
                    controller: 'AddEditCustomerCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.CustomerMessagingPopUp', {
            url: '',
            title: 'Customer Order',
            params: {
                messagingInfoParams: {},
            },
            views: {
                CustomerMessaging: angularAMD.route({
                    templateUrl: CustomerMessagingPopupUrl,
                    controller: 'CustomerMessagingCtrl'
                })
            }
        }).state('CustomerOrder_V2.ServiceJobClaim', {
            url: '',
            title: 'Customer Order',
            params: {
                ServiceJobClaimParams: {},
            },
            views: {
                ServiceJobClaimV2: angularAMD.route({
                    templateUrl: ServiceJobClaimV2Url,
                    controller: 'ServiceJobClaimCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.AddEditLogTechnicianTime', {
            url: '',
            title: 'Customer Order',
            params: {
                AddEditLogTechnicianTimeParams: {},
            },
            views: {
                AddEditLogTechnicianTime: angularAMD.route({
                    templateUrl: AddEditLogTechnicianTimeV2Url,
                    controller: 'AddEditLogTechnicianTimeCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.ServiceJobClaimResponse', {
            url: '',
            title: 'Customer Order',
            params: {
                ServiceJobClaimResponseParams: {},
            },
            views: {
                ServiceJobClaimResponse: angularAMD.route({
                    templateUrl: ServiceJobClaimResponseV2Url,
                    controller: 'ServiceJobClaimResponseCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.EditPricing', {
            url: '',
            title: 'Customer Order',
            params: {
                EditPricingParams: {},
            },
            views: {
                EditPricing: angularAMD.route({
                    templateUrl: EditPricingV2Url,
                    controller: 'EditPricingCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.InvoiceToDeal', {
            url: '',
            title: 'Customer Order',
            params: {
                InvoiceToDealParams: {},
            },
            views: {
                InvoiceToDeal: angularAMD.route({
                    templateUrl: InvoiceToDealV2Url,
                    controller: 'InvoiceToDealCtrl_V2'
                })
            }
        }).state('CustomerOrder_V2.AddEditTempUnit', {
            url: '',
            title: 'Customer Order',
            params: {
                AddEditTempUnitParams: {},
            },
            views: {
                AddEditTempUnit: angularAMD.route({
                    templateUrl: AddEditTempUnitV2Url,
                    controller: 'AddEditTempUnitCtrl_V2'
                })
            }
        }).state('VendorOrder.CustomerMessagingPopUp', {
            url: '',
            title: 'Vendor Order',
            params: {
                messagingInfoParams: {},
            },
            views: {
                CustomerMessaging: angularAMD.route({
                    templateUrl: CustomerMessagingPopupUrl,
                    controller: 'CustomerMessagingCtrl'
                })
            }
        }).state('VendorOrder.AddAttachment', {
            url: '',
            title: 'Vendor Order',
            params: {
                AddAttachmentParams: {},
            },
            views: {
                AddAttachment: angularAMD.route({
                    templateUrl: ServiceJobAddAttachmentUrl,
                    controller: 'AddAttachmentCtrl'
                })
            },
            sticky: true
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var ViewPartChildApp = angular.module('routerApp.ViewPartChildApp', ['ui.router']);
    ViewPartChildApp.config(['$stateProvider', '$controllerProvider', '$urlRouterProvider', '$provide', '$stickyStateProvider', function ($stateProvider, $controllerProvider, $urlRouterProvider, $provide, $stickyStateProvider) {
        ViewPartChildApp.register = {
            controller: $controllerProvider.register,
            factory: $provide.factory,
            service: $provide.service
        };
        var url = window.location.origin;
        var EditPartURl = url + '/apex/AddEditParts';
        var PartAdjustmentInStockURl = url + '/apex/PartAdjustmentInStock';
        var ModifyCostSummaryURl = url + '/apex/ModifyCostSummary';
        var ModifyCostSourceURl = url + '/apex/ModifyCostSource';
        var ResolveOversoldURl = url + '/apex/ResolveOversold';
        var PrintBarCodeURl = url + '/apex/PrintBarCode';
        $stateProvider.state('ViewPart.EditPart', {
            url: '',
            title: 'Part',
            params: {
                EditPartParams: {},
            },
            views: {
                EditPart: angularAMD.route({
                    templateUrl: EditPartURl,
                    controller: 'AddEditPartsCtrl'
                })
            }
        }).state('ViewPart.PartAdjustmentInStock', {
            url: '',
            title: 'Part',
            params: {
                PartAdjustmentInStockParams: {},
            },
            views: {
                PartAdjustmentInStock: angularAMD.route({
                    templateUrl: PartAdjustmentInStockURl,
                    controller: 'PartAdjustmentInStockCtrl'
                })
            },
            sticky: true
        }).state('ViewPart.ModifyCostSummary', {
            url: '',
            title: 'Part',
            params: {
                ModifyCostSummaryParams: {},
            },
            views: {
                ModifyCostSummary: angularAMD.route({
                    templateUrl: ModifyCostSummaryURl,
                    controller: 'ModifyCostSummaryCtrl'
                })
            },
            sticky: true
        }).state('ViewPart.ModifyCostSource', {
            url: '',
            title: 'Part',
            params: {
                ModifyCostSourceParams: {},
            },
            views: {
                ModifyCostSource: angularAMD.route({
                    templateUrl: ModifyCostSourceURl,
                    controller: 'ModifyCostSourceCtrl',
                    reload: true
                })
            },
            sticky: true
        }).state('ViewPart.ResolveOversold', {
            url: '',
            title: 'Part',
            params: {
                ResolveOversoldParams: {},
            },
            views: {
                ResolveOversold: angularAMD.route({
                    templateUrl: ResolveOversoldURl,
                    controller: 'ResolveOversoldCtrl'
                })
            },
            sticky: true
        }).state('ViewPart.PrintBarCode', {
            url: '',
            title: 'Part',
            params: {
                PrintBarCodeParams: {},
            },
            views: {
                PrintBarCode: angularAMD.route({
                    templateUrl: PrintBarCodeURl,
                    controller: 'PrintBarCodeCtrl'
                })
            },
            sticky: true
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var ViewCustomerChildApp = angular.module('routerApp.ViewCustomerChildApp', ['ui.router']);
    ViewCustomerChildApp.config(['$stateProvider', '$urlRouterProvider', '$stickyStateProvider', function ($stateProvider, $urlRouterProvider, $stickyStateProvider) {
        var url = window.location.origin;
        var AddEditCustomerContactUrl = url + '/apex/AddEditCustomerContact';
        var CustomerMessagingPopupUrl = url + '/apex/CustomerMessagingPopup';
        $stateProvider.state('ViewCustomer.AddEditCustomerContact', {
            url: '',
            title: 'Customer',
            params: {
                AddEditCustomerContactParams: {},
            },
            views: {
                AddEditCustomerContact: angularAMD.route({
                    templateUrl: AddEditCustomerContactUrl,
                    controller: 'AddEditCustomerContactCtrl'
                })
            },
            sticky: true
        }).state('ViewCustomer.CustomerMessagingPopUp', {
            url: '',
            title: 'Customer',
            params: {
                messagingInfoParams: {},
            },
            views: {
                CustomerMessaging: angularAMD.route({
                    templateUrl: CustomerMessagingPopupUrl,
                    controller: 'CustomerMessagingCtrl'
                })
            },
            sticky: true
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    
    var AddEditCustomerApp = angular.module('routerApp.AddEditCustomerApp', ['ui.router']);
    AddEditCustomerApp.config(['$stateProvider', '$urlRouterProvider', '$stickyStateProvider', function ($stateProvider, $urlRouterProvider, $stickyStateProvider) {
        var url = window.location.origin;
        var AddEditCustomerUrl = url + '/apex/AddEditCustomer';
        var addEditCustomerV2Url = url + '/apex/AddEditCustomer_V2';
        $stateProvider.state('ViewCustomer.EditCustomer', {
            url: '',
            title: 'Customer',
            params: {
                EditCustomerParams: {},
            },
            views: {
                EditCustomer: angularAMD.route({
                    templateUrl: AddEditCustomerUrl,
                    controller: 'AddEditCustomerCtrl'
                })
            }
        }).state('ViewCustomer.EditCustomerV2', {
            url: '',
            title: 'Customer',
            params: {
                AddEditCustomerParams: {},
            },
            views: {
                EditCustomer: angularAMD.route({
                    templateUrl: addEditCustomerV2Url,
                    controller: 'AddEditCustomerCtrl_V2'
                })
            }
        }).state('CustomerOrder.EditCustomer', {
            url: '',
            title: 'Customer Order',
            params: {
                EditCustomerParams: {},
            },
            views: {
                EditCustomer: angularAMD.route({
                    templateUrl: AddEditCustomerUrl,
                    controller: 'AddEditCustomerCtrl'
                })
            }
        }).state('CashSaleCO.AddCustomer', {
            url: '',
            title: 'Blackpurl',
            params: {
                myParams: {},
            },
            views: {
                CashSaleCOChildView: angularAMD.route({
                    templateUrl: AddEditCustomerUrl,
                    controller: 'AddEditCustomerCtrl'
                })
            }
        });
        $stickyStateProvider.enableDebug(true);
    }]);
    return angularAMD.bootstrap(app);
});