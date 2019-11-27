define(['Routing_AppJs_PK', 'PrintBarCode_NumberOnlyInput', 'JsBarCode', 'DYMOBarcodeLabelService', 'BarcodePrintService'], function(Routing_AppJs_PK, PrintBarCode_NumberOnlyInput, JsBarCode, DYMOBarcodeLabelService, BarcodePrintService) {
    var injector = angular.injector(['ui-notification', 'ng']);
    Routing_AppJs_PK.controller('PrintBarCodeCtrl', ['$scope', '$rootScope', '$stateParams', '$state', '$q', '$translate', 'BarcodePrintService', 'DYMOBarcodeLabelService', function($scope, $rootScope, $stateParams, $state, $q, $translate, BarcodePrintService, DYMOBarcodeLabelService) {
        var Notification = injector.get("Notification");
        var origin = window.location.origin;
        var url = origin + '/apex/';
        if ($scope.printBarCodeModel == undefined) {
            $scope.printBarCodeModel = {};
        }
        $scope.isDymoFrameworkLoaded = true;
		window.onload = DYMOBarcodeLabelService.dymoFrameworkInitHelper(); // Load DYMO init async
		
        $scope.printBarCodeModel.qty = 1;
        $scope.$on('printBarCodeEvent', function(event, args) {
            $scope.printBarCodeModel.partJSON = args;
            $scope.printBarCodeModel.openprintBarCodeModelPopup();
        });
        
        $scope.printBarCodeModel.openprintBarCodeModelPopup = function() {
            $scope.printBarCodeModel.openPopup();
        }
        
        $scope.printBarCodeModel.openPopup = function() {
        	angular.element('.controls').hide();
            $scope.printBarCodeModel.qty = 1;
            setTimeout(function() {
                angular.element('#printBarCodeWrapper').modal({
                    backdrop: 'static',
                    keyboard: false
                });
            }, 500);
            $scope.printBarCodeModel.printCheckbarCode = true;
            JsBarcode("#barcode", '' + $scope.printBarCodeModel.partJSON.PartId + '');
            setTimeout(function() {
                angular.element('#print_qty_Edit').focus();
                angular.element('#print_qty_Edit').select();
            }, 500);
            
        	BarcodePrintService.getBarcodeInfo($scope.printBarCodeModel.partJSON.Id).then(function(partInfo) { // Load part info
        		$scope.printBarCodeModel.partInfo = partInfo;
        		DYMOBarcodeLabelService.generatePartLabelPreview("/labels/PartLabelTemplate.label", partInfo).then(function(partBarcodePng) {
        			$scope.printBarCodeModel.barcodePng = partBarcodePng;
        			$scope.isDymoFrameworkLoaded = true;
        		}, function(error) {
        			$scope.isDymoFrameworkLoaded = false;
        		});
        	}, function (error) {
        		$scope.isDymoFrameworkLoaded = false;
            });
        }
        
        $scope.printBarCodeModel.closePopup = function() {
            angular.element('#printBarCodeWrapper').modal('hide');
            hideModelWindow();
            loadState($state, $rootScope.$previousState.name, {
                Id: $rootScope.$previousStateParams.Id
            });
        }
        
        $scope.printBarCodeModel.printCheckbarCodeCheck = function() {
            $scope.printBarCodeModel.printCheckbarCode = !$scope.printBarCodeModel.printCheckbarCode
        }
        
        $scope.printBarCodeModel.printLabels = function() {
    		DYMOBarcodeLabelService.printPartLabels("/labels/PartLabelTemplate.label", $scope.printBarCodeModel.partInfo, $scope.printBarCodeModel.qty);
            $scope.printBarCodeModel.closePopup();
        }
        
        $scope.printBarCodeModel.printbarcodePage = function(barcodeString) {
        	window.open(url + "BarcodePrint?id=" + barcodeString + '&PageName=' + 'isFromPart' + '&qty=' + $scope.printBarCodeModel.qty + '&Id=' + $scope.printBarCodeModel.partJSON.Id, "", "width=1200, height=600");
            $scope.printBarCodeModel.closePopup();
        }
        
        $scope.printBarCodeModel.openprintBarCodePopupFromRouting = function() {
            $scope.printBarCodeModel.partJSON = $stateParams.PrintBarCodeParams.partJSON;
            $scope.printBarCodeModel.openprintBarCodeModelPopup();
        }
        
        $scope.printBarCodeModel.openprintBarCodePopupFromRouting();
    }]);
});