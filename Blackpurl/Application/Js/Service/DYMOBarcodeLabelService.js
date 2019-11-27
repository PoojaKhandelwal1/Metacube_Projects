/**
 * @name DYMOBarcodeLabelService
 * @author Yash Sharma <yash.sharma@metacube.com>
 * @since 07/05/2018
 * @description Angular Service interacting with DYMO LabelWriter JavaScript SDK (deployed as a local web-service) for label and bar code printing
 */
define(['Routing_AppJs_PK', 'DYMOLabelSDK', 'BarcodePrintService'], function (Routing_AppJs_PK, DYMOLabelSDK, BarcodePrintService) {
	var injector = angular.injector(['ui-notification', 'ng']);
	Routing_AppJs_PK.service('DYMOBarcodeLabelService', ['$q', '$translate', '$filter', '$http', 'BarcodePrintService', function ($q, $translate, $filter, $http, BarcodePrintService) {
		
		var Notification = injector.get("Notification");
		var labelPrinterName; // Label Printer Name
		
		// private methods
		// init framework
		function init() {
			if(dymo.label.framework.init) { // DYMO framework NOT initialized.
				dymo.label.framework.trace = true; // TRACE MODE ON 
				dymo.label.framework.init(function(success) {
					console.log("DYMO framework VERSION : " + dymo.label.framework.VERSION + " init success");
					// Check environment compatibility
					var envStatus = dymo.label.framework.checkEnvironment();
					if(!envStatus.isBrowserSupported) {
						Notification.error($translate.instant('DYMO_framework_browser_not_supported_error'));
					} else if(!envStatus.isFrameworkInstalled) {
						Notification.error($translate.instant('DYMO_framework_not_installed_error'));
					} else if(!envStatus.isWebServicePresent) {
						Notification.error($translate.instant('DYMO_framework_webservice_not_present_error'));
					} else {
						// Check printer availability and assign name
						getPrinterName("LabelWriterPrinter").then(function(printerName) {
							labelPrinterName = printerName;
						}, function(error) {
							Notification.error($translate.instant('No_Label_Printer_found'));
						});
					}
				});
			}
		}
		
		// Get DYMO printer name
		function getPrinterName(type) {
	        var defer = $q.defer();
	        var printerName;
	        dymo.label.framework.getPrintersAsync().then(function(printers) {
                if (!printers || printers.length == 0) {
                	defer.reject();
                }
                for (var i = 0; i < printers.length; ++i) {
                    if (printers[i].printerType == type) {
                        printerName = printers[i].name;
                        break;
                    }
                }
                defer.resolve(printerName);
			}, function(error) {
				defer.reject();
			});
	        return defer.promise;
		}
		
		// Load Label object of template XML file from relative path (might update it with Object fetch over RemoteAction)
		function loadLabelObject(relativePath) {
			var defer = $q.defer();
			// Load label template from BusinessProfile object field - Part_Label_Template__c
			BarcodePrintService.getBarcodeLabelTemplate(null).then(function(response) {
				if(response && response.labelTemplateXml) {
					var label = dymo.label.framework.openLabelXml(response.labelTemplateXml);
					defer.resolve(label);
				} else {
					$http.get($Global.AssetsPath + relativePath).then(function (response) {
						// Save template to Business Profile - Part_Label_Template__c
						BarcodePrintService.saveBarcodeLabelTemplate(response.data); // save async
						var label = dymo.label.framework.openLabelXml(response.data);
						defer.resolve(label);
					}, function(error) {
						defer.reject(error);
						Notification.error($translate.instant('Error_loading_label_template'));
					});
				}
			}, function(error) {
				defer.reject(error);
				Notification.error($translate.instant('Error_loading_label_template'));
			});
			return defer.promise;
		}
		
		// Generate Set of labels
		function generateLabelSetXML(partInfo, qty) {
		    var labelSet = new dymo.label.framework.LabelSetBuilder();
		    qty = qty || 1;
		    for (var i=1; i <= qty; i++) {
		        var record = labelSet.addRecord();
		        record.setText("STORENAME", partInfo.CompanyInfo.CompanyName);
		        record.setText("DESCRIPTION", wrapText(partInfo.Description));
		        record.setText("PRICE", $filter('currency')(partInfo.RetailPrice));
				record.setText("BARCODE", partInfo.PartId);
		    }
		    return labelSet;
		}
		
		// Print label(s) over DYMO - using DYMO web-service SDK
		function printLabel(printerName, printParamsXml, label, labelSetXml) {
			try {
				label.print(printerName, printParamsXml, labelSetXml);
	        } catch(error) {
	        	Notification.error($translate.instant('Error_printing_label'));
	        }
		}
		
		// Break string in 2 lines
		function wrapText(str) {
			try {
				if(str.length > 25) {
					var breakPoint = Math.round(str.length / 2);
					var cutHere = str.substring(0, breakPoint).lastIndexOf(" ")
					return (str.substring(0, cutHere) + "\n" + str.substring(cutHere+1));
				} else {
					return str;
				}
			} catch(err) {
				return str; // fail safe
			}
		}
		
		// public methods
		// Initialize DYMO framework
		this.dymoFrameworkInitHelper = function() {
			try {
				init();
			} catch(error) {
				Notification.error(error.message || error);
			}
		}
		
		this.checkEnvironment = function() {
			var envStatus = dymo.label.framework.checkEnvironment();
			if(!envStatus.isBrowserSupported) {
				return false;
			} else if(!envStatus.isFrameworkInstalled) {
				return false;
			} else if(!envStatus.isWebServicePresent) {
				return false;
			}
			return true;
		}
		
		// facade for part label preview
		this.generatePartLabelPreview = function(labelTemplatePath, partInfo) {
			var defer = $q.defer();
			loadLabelObject(labelTemplatePath).then(function(partLabel) { // Step 1: Load template
				partLabel.setObjectText("STORENAME", partInfo.CompanyInfo.CompanyName);
				partLabel.setObjectText("DESCRIPTION", wrapText(partInfo.Description));
				partLabel.setObjectText("PRICE", $filter('currency')(partInfo.RetailPrice));
				partLabel.setObjectText("BARCODE", partInfo.PartId);
				try {
					var pngData = dymo.label.framework.renderLabel(partLabel.getLabelXml(), "", labelPrinterName); // Step 2: render label
					defer.resolve("data:image/png;base64," + pngData);
				} catch(error) {
					defer.reject(error);
				}
			}, function(error) {
				defer.reject(error);
			});
			return defer.promise;
		}
		
		// facade for part label printing
		this.printPartLabels = function(labelTemplatePath, partInfo, qty) {
			loadLabelObject(labelTemplatePath).then(function(partLabel) { // Step 1: Load template
				var labelSetXml = generateLabelSetXML(partInfo, qty); // Step 2: Iterate parts and create labelset
				printLabel(labelPrinterName, "", partLabel, labelSetXml); // Step 3: Print
			});
		}
		
		// facade for part label printing from Vendor receiving
		this.printVendorReceivingPartLabels = function(labelTemplatePath, partsList) {
			loadLabelObject(labelTemplatePath).then(function(partLabel) { // Step 1: Load template
				// Step 2: Iterate parts and create labelset
				var labelSet = new dymo.label.framework.LabelSetBuilder();
				for(var i=0; i<partsList.length; i++) {
	                if(partsList[i].CustomerDetailList.length == 0 || partsList[i].NoOfStockLabels != 0) { // Vendor Receiving for Stock Parts
	                    for(var j=0;j<partsList[i].NoOfStockLabels;j++) {
	                    	var record1 = labelSet.addRecord();
	                    	record1.setText("STORENAME", partsList[i].BusinessName);
	                    	var description = partsList[i].PartDesc + (partsList[i].PartLocation ? (" / " + partsList[i].PartLocation) : "");
	                    	record1.setText("DESCRIPTION", wrapText(description));
	                    	record1.setText("PRICE", $filter('currency')(partsList[i].RetailPrice));
	                    	record1.setText("BARCODE", partsList[i].PartId);
	                    	record1.setText("CUSTOMERORDER", "");
                        	record1.setText("CUSTOMERINFO", "");
	                    }
	                } 
	                if(partsList[i].CustomerDetailList.length != 0) { // Vendor receiving for Special Order Parts
	                    for(var cust=0; cust<partsList[i].CustomerDetailList.length; cust++) {
	                        for(var label=0; label<partsList[i].CustomerDetailList[cust].NoOfLabels;label++) {
	                        	var record2 = labelSet.addRecord();
	                        	record2.setText("STORENAME", partsList[i].BusinessName);
	                        	record2.setText("CUSTOMERORDER", partsList[i].CustomerDetailList[cust].CONumber);
	                        	record2.setText("CUSTOMERINFO", (partsList[i].CustomerDetailList[cust].CustomerName + (partsList[i].CustomerDetailList[cust].PhoneNumber ? ("\n" + partsList[i].CustomerDetailList[cust].PhoneNumber) : "")));
	                        	record2.setText("BARCODE", partsList[i].PartId);
	                        	record2.setText("DESCRIPTION", "");
	                        	record2.setText("PRICE", "");

	                        }
	                    }
	                }
				}
				printLabel(labelPrinterName, "", partLabel, labelSet); // Step 3: Print
			});
		}
	}]);
});

			
		
