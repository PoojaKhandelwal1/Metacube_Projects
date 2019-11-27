var SKIP_API_REQUEST = 'Skip_API_Request';
function loadState(state, stateName, attr) {
    if (attr != undefined && attr != null && attr != '') {
        state.go(stateName, attr);
    } else {
        state.go(stateName);
    }
}

function encodeString(inputString) {
    if (inputString == null) {
        return inputString;
    }
    var outputString = window.btoa(unescape(encodeURIComponent(inputString)));
    return outputString;
}

function showToolTip(Value) {
    angular.element(".controls").hide();
    angular.element("#" + Value).show();
}
function debug(value) {
    console.log(value);
}
function hideModelWindow() {
    angular.element('body').removeClass('modal-open');
    angular.element('body').addClass('paddingBody');
}

function decodeString(inputString) {
    if (inputString == null) {
        return inputString;
    }
    try {
        var res = inputString.match('^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{4}|[A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)$');
    } catch (ex) {}

    if (res == null) {
        return inputString;
    }
    var outputString = decodeURIComponent(escape(window.atob(inputString)));
    return outputString;
}

function isElementDefined(element) {
    if (angular.element(element) != undefined && angular.element(element).position() != undefined) {
        return true;
    } else {
        return false;
    }
}
function isBlankValue(val) {
    if (val != undefined && val != null && val != '') {
        return false;
    } else {
        return true;
    }
}
var setOfSkippableMethods = ['GlobalSearchCtrl.getGlobalSearchResult', 'CustomerOrderCtrl.getSearchResult'];
var activeRequest;
function RemoteActionService(){
	var deferred = Array.prototype.splice.apply(arguments, [0,1]);
	deferred = deferred[0].defer();
	if(arguments && arguments.length > 0 && setOfSkippableMethods.indexOf(arguments[0]) > -1 ) {
    	var requestId = encodeString(JSON.stringify(arguments) + (new Date()).toUTCString());
        activeRequest = requestId;
    }
	//starting from i=1 as first param is method name
	for(var i = 1; i < arguments.length; i++) {
		arguments[i] = (typeof arguments[i] == 'boolean' || typeof arguments[i] == 'number') ? arguments[i] : encodeString(arguments[i]);
	}
	Visualforce.remoting.Manager.invokeAction(...arguments,
        function (result, event) {
            if (event.type == 'exception') {
                handleExceptions(event);
                deferred.reject(event.message);
            } else {
            	if(arguments && arguments.length > 0 && setOfSkippableMethods.indexOf(arguments[0])) {
            		if(activeRequest == requestId){
                        activeRequest = undefined;
                        deferred.resolve(parseJSON(result));
                    } else {
                    	deferred.resolve(SKIP_API_REQUEST);
                    }
                } else {
                	deferred.resolve(parseJSON(result));
                }
            }
        }, {
            escape: true,
            buffer:false
        });
    return deferred.promise;
}

function handleExceptions(event) {
    var landingUrl = 'https://blackpurl.cloudforce.com';
    if (event.message != undefined) {
        var eventMessage = event.message.toString();
        var sessionErrorMessage = 'Logged in?';
        if (eventMessage.indexOf(sessionErrorMessage) !== -1) {
            redirectToLogin(landingUrl);
        }
    }
    return event;
}

function redirectToLogin(landingUrl) {
    window.location.href = landingUrl;
}

function checkRequireJS() {
    return validateSessionForRequireScript();

}

function parseJSON(result) {
    var resultData = decodeString(result);
    if (resultData != null && resultData != undefined && resultData != '' && typeof (resultData) == 'string') {
        var find = '\'';
        var re = new RegExp(find, 'g');
        if (resultData != null) {
            resultData = resultData.replace(re, '');
            if (/^[\],:{}\s]*$/.test(resultData.replace(/\\["\\\/bfnrtu]/g, '@').replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']').replace(/(?:^|:|,)(?:\s*\[)+/g, ''))) {
                resultData = JSON.parse(resultData);
            }
        }
    }
    return resultData;
}

function formatTel(tel) {
    if (!tel) {
        return '';
    }
    var value = tel.toString().trim().replace(/^\+/, '');

    if (value.match(/[^0-9]/)) {
        return tel;
    }

    var country, city, number;
    switch (value.length) {
        case 10: // +1PPP####### -> C (PPP) ###-####
            country = 1;
            city = value.slice(0, 3);
            number = value.slice(3);
            break;

        case 11: // +CPPP####### -> CCC (PP) ###-####
            country = value[0];
            city = value.slice(1, 4);
            number = value.slice(4);
            break;

        case 12: // +CCCPP####### -> CCC (PP) ###-####
            country = value.slice(0, 3);
            city = value.slice(3, 5);
            number = value.slice(5);
            break;

        default:
            return tel;
    }

    if (country == 1) {
        country = "";
    }

    number = number.slice(0, 3) + '-' + number.slice(3);
    return (country + " (" + city + ") " + number).trim();
}

function checkForDevice(deviceName) {
	var flag = false;
	switch (deviceName) {
    	case 'iPad':
        	flag = (navigator.userAgent.match(/iPad/i) != null);
            break;
        default:
        	flag = false;
            break;
	}
	return flag;
}

/**
 * expand collapse animation
 * @param expandableElement
 * @param expandableElementHeightToBeApplied
 * @param transitionDelay
 * @returns
 */
function expandElement(expandableElement, expandableElementHeightToBeApplied, transitionDelay) {
    if (expandableElement != undefined && expandableElement != null && expandableElement != '') {
        if (transitionDelay != undefined && transitionDelay != null && transitionDelay != '') {
            expandableElement.css('transition-delay', transitionDelay);
        }
        
        if(checkForDevice('iPad') && expandableElement.hasClass("bp-expand-div-transition")) { 
        	expandableElement.css('transition', 'none');
		}
        expandableElement.css('height', expandableElementHeightToBeApplied);
        expandableElement.addClass('bp-expand-div-transition');
    }
}

function collapseElement(collapsableElement) {
    if (collapsableElement != undefined && collapsableElement != null && collapsableElement != '') {
        collapsableElement.removeAttr('style');
        collapsableElement.removeClass('bp-expand-div-transition');
    }
}

function expandElementToLeft(expandableElement, expandableElementWidthToBeApplied, transitionDelay) {
    if (expandableElement != undefined && expandableElement != null && expandableElement != '') {
        if (transitionDelay != undefined && transitionDelay != null && transitionDelay != '') {
            expandableElement.css('transition-delay', transitionDelay);
        }
        // Ipad check
        expandableElement.css('width', expandableElementWidthToBeApplied);
        expandableElement.addClass('expand-div-width-transition');
    }
}

function collapseElementToRight(collapsableElement) {
    if (collapsableElement != undefined && collapsableElement != null && collapsableElement != '') {
        collapsableElement.removeAttr('style');
        collapsableElement.removeClass('expand-div-width-transition');
    }
}

/**
 * VIN Code validator
 * @param vin
 * @returns
 */
function validateVin(vin) {
    var no_ioq = '[a-hj-npr-z0-9]'; /* Don't allow characters I,O or Q */
    var matcher = new RegExp("^" + no_ioq + "{8}[0-9xX]" + no_ioq + "{8}$", 'i'); /* Case insensitive */

    if (vin && vin.trim().length != 17) {
        return true;
    } else if (!vin || !vin.match(matcher)) {
        return false;
    } else {
        return checkDigitCalculation(vin);
    }
};

function checkDigitCalculation(vin) {
    var upperCaseVin = vin.toUpperCase();
    var letterMap = {
        A: 1,
        B: 2,
        C: 3,
        D: 4,
        E: 5,
        F: 6,
        G: 7,
        H: 8,
        J: 1,
        K: 2,
        L: 3,
        M: 4,
        N: 5,
        P: 7,
        R: 9,
        S: 2,
        T: 3,
        U: 4,
        V: 5,
        W: 6,
        X: 7,
        Y: 8,
        Z: 9,
        1: 1,
        2: 2,
        3: 3,
        4: 4,
        5: 5,
        6: 6,
        7: 7,
        8: 8,
        9: 9,
        0: 0
    };
    var weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2];
    var products = 0;
    for (var i = 0; i < upperCaseVin.length; i++) {
        products += letterMap[upperCaseVin[i]] * weights[i];
    }
    var checkDigitShouldBe = products % 11;
    if (checkDigitShouldBe == 10) {
        checkDigitShouldBe = 'X';
    }
    return (checkDigitShouldBe == upperCaseVin[8]);
}

function roundDecimal(value, decimals) {
	return Number(Math.round(value + 'e' + decimals) + 'e-' + decimals);
}

function getExtension(file) {
    var str, separator;
    if(typeof file.name !== 'undefined') {
        str = file.name;
        separator = '.';
    } else {
        str = file.type;
        separator = '/';
    }

    if (str.indexOf(separator) === -1) {
        // Filename doesn't actually have an extension.
        return '';
    }

    return str.split(separator).pop().trim().toLowerCase();

}
function getDateStringWithFormat(date, format) {
	format = format.split('/');
	dateList = ['', '', ''];
	console.log(date);
	dateList[_.indexOf(format,'mm')] = date.getMonth() + 1;
	dateList[_.indexOf(format,'dd')] = date.getDate();
	dateList[_.indexOf(format,'yy')] = date.getFullYear();
	return dateList.join('/');
}
function partsmartCSVToJson(partsmartContentStr, fileKeyToObjKeyMap, pageName, sectionName) {
    var lines = partsmartContentStr.split("\n");
    var partsToAdd = [];
    if(lines && lines.length > 1) {
    	var header = decodeURIComponent(escape(lines[0].trim())).split('",');
    	for(var i = 1; i < lines.length; i++) {
	    	lines[i] = lines[i].trim();
	    	if(lines[i].length) {
	    		var obj = {};
    	        var currentline = lines[i].split('",');
    	        for (var j = 0; j < header.length; j++) {
    	        	var headerValue = (j == 0)? 'Catalog' : (header[j].split('"').join(''));
    	        	console.log(headerValue + '  ' + fileKeyToObjKeyMap[headerValue] + ' ' +fileKeyToObjKeyMap['Catalog']);
	    	        if(fileKeyToObjKeyMap[headerValue]) {
	    	        	obj[fileKeyToObjKeyMap[headerValue]] = currentline[j].replace(new RegExp('"', 'g'), '');
    	        	}
    	        }
    	        if(pageName == 'Vendor Order' && obj && obj["PartNumber"] && obj["Qty"]) {
	        		partsToAdd.push(obj);
    	        } else if(pageName == 'Customer Order' && obj && obj["Manufacturer"] && obj["PartNumber"] && obj["Qty"]) {
    	        	obj["DealId"] = (sectionName && (sectionName == 'Deal Merchandise' || sectionName == 'Deal')) ? $scope.M_CO.Deal.DealInfo.Id : null;
    	        	partsToAdd.push(obj);
    	        }
    		}
    	}
    }
    return partsToAdd;
}