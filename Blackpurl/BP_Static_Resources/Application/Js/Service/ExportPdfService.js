/**
 * @name ExportPdfService
 * @author Yash Sharma <yash.sharma@metacube.com>
 * @since 03/08/2018
 * @description Angular Service for generating export PDF file 
 */
define(['Routing_AppJs_PK', 'jsPDF'], function (Routing_AppJs_PK, jsPDF) {
	var injector = angular.injector(['ui-notification', 'ng']);
	Routing_AppJs_PK.service('ExportPdfService', ['$q', '$translate', '$http', function ($q, $translate, $http) {
		
		var Notification = injector.get("Notification");
		
		var generatePdfFile = function(imageBodyList, modalObj, configObj, exportFileName) {
			try {
				if(configObj && configObj.length) {
					var config = {
							 orientation: 'p',
							 unit: 'mm',
							 format: 'a4'
							}
					var pdfExportDoc = new jsPDF(config);
					pdfExportDoc.setFontSize(10);
					pdfExportDoc.setTextColor(92, 76, 76);
					
					for(var page=0; page < imageBodyList.length; page++) {
						if(page < imageBodyList.length - 1) {
							pdfExportDoc.addPage();
						}
						setPageDataCallback(pdfExportDoc, page+1, "data:image/jpeg;base64," + imageBodyList[page], modalObj, configObj[page]);
					}
					pdfExportDoc.save("EXPORT_" + exportFileName + ".pdf");
				}
			} catch(error) {
				Notification.error($translate.instant('GENERIC_ERROR'));
			}
		};
		
		var setPageDataCallback = function setPageDataCallback(pdfExportDoc, page, pdfImgData, modalObj, configObj) {
			pdfExportDoc.setPage(page);
			
			pdfExportDoc.addImage(pdfImgData, 'JPEG', 0, 0, 210, 297); // last 2 arguments ??
			try {
				angular.forEach(configObj, function(item, key) {
					if(item.font && parseInt(item.font)) {
						pdfExportDoc.setFontSize(parseInt(item.font));
					} else {
						pdfExportDoc.setFontSize(10);
					}
					modalObj[key] = modalObj[key] || "";
					if (item.isArray) {
						modalObj[key] = modalObj[key].toUpperCase();
						var strArr = modalObj[key].substring("");
						var repeat = (item.charLimit && item.charLimit <= strArr.length) ? item.charLimit : strArr.length;
						for(var i=0, x=item.x; i<repeat;i++,x+=item.xFactor) {
							pdfExportDoc.text(x, item.y, strArr[i]);
						}
					} else if(item.charLimit && modalObj[key].length > item.charLimit) {
						pdfExportDoc.text(item.x, item.y, modalObj[key].substring(item.charLimit) || "");
					} else {
						pdfExportDoc.text(item.x, item.y, (modalObj[key] || "").toString());
					}
				});
			} catch (error) {
				Notification.error($translate.instant('GENERIC_ERROR'));
			}
		}

		// public methods
		/**
		 * Generate PDF from provided Image body, modal object and coordinates configuration
		 */
		this.generatePdf = function(imageBodyList, modalObj, configObj, exportFileName) {
			generatePdfFile(imageBodyList, modalObj, configObj, exportFileName);
		};
		
		/* ----------------------------------------------------------- Start - Dummy Data for Test purpose ---------------------------------------------------------- */

		/**
		 * Generate by reading Image files from StaticResources
		 * generatePdfOld($Global.AssetsPath + "/labels/", ['1.jpg', '2.jpg', '3.jpg', '4.jpg'], dummyModalObj, dummyConfigObj);
		 */
		this.generatePdfOld = function(pdfRelativePath, pdfImages, modalObj, configOb) {
			try {
				if(configObj && configObj.length) {
					var config = {
							 orientation: 'p',
							 unit: 'mm',
							 format: 'a4'
							}
					var pdfExportDoc = new jsPDF(config);
					pdfExportDoc.setFontSize(10);
					pdfExportDoc.setTextColor(92, 76, 76);
					
					var promises = [];
					for(var page=0; page < pdfImages.length; page++) {
						promises.push(loadImageFromUrl(pdfRelativePath + pdfImages[page]));
					}
					$q.all(promises).then(function(pdfImgDataList) {
						for(var page=0; page < pdfImages.length; page++) {
							if(page < pdfImages.length - 1) {
								pdfExportDoc.addPage();
							}
							setPageDataCallback(pdfExportDoc, page+1, pdfImgDataList[page], modalObj, configObj[page]);
						}
						pdfExportDoc.save("CO_EXPORT_" + modalObj["CustomerOrderNumber"].toString() + ".pdf");
					});
				}
			} catch(error) {
				Notification.error($translate.instant('GENERIC_ERROR'));
			}
		};
		
		function loadImageFromUrl(url) {
			var defer = $q.defer();
			var xhr = new XMLHttpRequest();
			xhr.onload = function() {
				var reader = new FileReader();
				reader.onloadend = function() {
					defer.resolve(reader.result);
				}
				reader.readAsDataURL(xhr.response);
			};
			xhr.open('GET', url, true);
			xhr.responseType = 'blob';
			xhr.send();
			return defer.promise;
		}

		// Dummy Data - array of configuration object - per page
		var dummyModalObj = {
				"DealerDetails1" : "Grahame BROOKE",
				"DealerDetails2" : "Rocky Harley-Davidson",
				"DealerDetails3" : "ABN 38 122 550 047 ACN 122 550 047",
				"AccountAddressLine1": "125 William Street Rockhampton QLD 4700",
				"TelephoneFax": "Telephone: (07) 4924-9200 Fax: (07) 4924-9299",
				"OtherDetails": "Licence: 3203708    Expiry Date: 14/Sep/2016",
				"COID" : "12219",
				"StockNo": "10946#129",
				"SalesPerson": "James Mylne",
				"CustomerName": "Grahame BROOKE",
				"CustomerAddress1": "17 CONWAY COURT",
				"CustomerAddressLine2": "GRACEMERE, QLD",
				"CustomerMobile": "(0427)166-042",
				"CustomerPin": "4702",
				"CustomerEmail": "waterhog49@hotmail.com",
				"UnitMake": "Harley-Davidson",
				"UnitModel": "Softail FXLR 107",
				"UnitRegistration": "827QC",
				"UnitColor": "Wicked Red",
				"UnitEngineNumber": "YNJJ063891",
				"UnitModelType": "Softail",
				"UnitBodyType": "CYCLE",
				"UnitOdometer": "9316",
				"UnitOdometerInWords": "Nine thousand three hundred sixteen",
				"UnitEngineSize": "1690",
				"UnitDueDate": "02/08/2018",
				"VIN": "5HD1YNJG4JC063891",
				"UnitPriceIncTax": "20687.01",
				"MerchandisePrice": "655.74",
				"SubTotal1": "21342.75",
				"LessAllowances": "N/A",
				"SubTotal2": "21342.75",
				"StampDuty": "642.00",
				"Total": "22500.00",
				"TotalInWords": "Twenty Two Thousand Five Hundred",
				"DeclaredAt": "Rockhampton, QLD",
				"DeclaredDay": "01",
				"DeclaredMonth": "08",
				"DeclaredYear": "2018"
			};
		
		// Dummy configuration
		var dummyConfigObj = [{ /* page no. 1*/
				"DealerDetails1" : {
					"x": 60,
					"y": 32,
					"charLimit": "15"
				},
				"DealerDetails2" : {
					"x": 60,
					"y": 36
				},
				"DealerDetails3" : {
					"x": 60,
					"y": 40,
					"charLimit": 25
				},
				"AccountAddressLine1": {
					"x": 60,
					"y": 44
				},
				"TelephoneFax": {
					"text": "Telephone: (07) 4924-9200 Fax: (07) 4924-9299",
					"x": 60,
					"y": 51
				},
				"OtherDetails": {
					"x": 60,
					"y": 55
				},
				"COID" : {
					"x": 165,
					"y": 34
				},
				"StockNo": {
					"x": 165,
					"y": 52
				},
				"SalesPerson": {
					"x": 13,
					"y": 52
				},
				"CustomerName": {
					"x": 45,
					"y": 63
				},
				"CustomerAddress1": {
					"x": 27,
					"y": 68.5
				},
				"CustomerAddressLine2": {
					"x": 15,
					"y": 74
				},
				"CustomerMobile": {
					"x": 75,
					"y": 79
				},
				"CustomerPin": {
					"x": 128,
					"y": 74
				},
				"CustomerEmail": {
					"x": 22,
					"y": 90
				},
				"UnitMake": {
					"x": 20,
					"y": 110
				},
				"UnitModel": {
					"x": 56,
					"y": 110
				},
				"UnitRegistration": {
					"x": 180,
					"y": 110
				},
				"UnitColor": {
					"x": 26,
					"y": 128
				},
				"UnitEngineNumber": {
					"x": 132,
					"y": 128
				},
				"UnitDueDate": {
					"x": 182.5,
					"y": 116
				},
				"VIN": {
					"x": 72,
					"y": 116,
					"isArray" : true,
					"xFactor": 6,
					"yFactor": 0
				},
				"UnitPriceIncTax": {
					"x": 85,
					"y": 146.5
				},
				"MerchandisePrice": {
					"x": 85,
					"y": 151.5
				},
				"SubTotal1": {
					"x": 85,
					"y": 196.5
				},
				"LessAllowances": {
					"x": 85,
					"y": 201.5
				},
				"SubTotal2": {
					"x": 85,
					"y": 206.5
				},
				"StampDuty": {
					"x": 85,
					"y": 226.5
				},
				"Total": {
					"x": 184,
					"y": 286
				}
			}, {  /* page no. 2*/ 
				"StockNo": {
					"x": 181,
					"y": 15
				},
				"UnitMake": {
					"x": 20,
					"y": 27
				},
				"UnitModelType": {
					"x": 55,
					"y": 27
				},
				"UnitBodyType": {
					"x": 105,
					"y": 27
				},
				"UnitRegistration": {
					"x": 180,
					"y": 27
				},
				"VIN": {
					"x": 71,
					"y": 33,
					"isArray" : true,
					"xFactor": 6,
					"yFactor": 0
				},
				"UnitOdometer": {
					"x": 60,
					"y": 39
				},
				"UnitOdometerInWords": {
					"x": 103,
					"y": 40
				},
				"UnitColor": {
					"x": 27,
					"y": 46
				},
				"UnitEngineNumber": {
					"x": 132,
					"y": 45
				},
				"UnitEngineSize": {
					"x": 185,
					"y": 45
				},
				"Total": {
					"x": 52,
					"y": 61
				},
				"TotalInWords": {
					"x": 75,
					"y": 61
				},
				"DeclaredAt": {
					"x": 32,
					"y": 202
				},
				"DeclaredDay": {
					"x": 116,
					"y": 202
				},
				"DeclaredMonth": {
					"x": 156,
					"y": 202
				},
				"DeclaredYear": {
					"x": 190,
					"y": 202
				}
			}, { /* page no. 3*/ }, { /* page no. 4*/ }];
		
		/* ----------------------------------------------------------- End - Dummy Data for Test purpose ---------------------------------------------------------- */
	}]);
});
