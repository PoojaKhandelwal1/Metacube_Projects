/*!
 * angular-translate - v2.16.0 - 2017-11-01
 * 
 * Copyright (c) 2017 The angular-translate team, Pascal Precht; Licensed MIT
 */
!function(t,e){"function"==typeof define&&define.amd?define([],function(){return e()}):"object"==typeof module&&module.exports?module.exports=e():e()}(0,function(){function t(t){"use strict";var e=t.storageKey(),n=t.storage(),a=function(){var a=t.preferredLanguage();angular.isString(a)?t.use(a):n.put(e,t.use())};a.displayName="fallbackFromIncorrectStorageValue",n?n.get(e)?t.use(n.get(e)).catch(a):a():angular.isString(t.preferredLanguage())&&t.use(t.preferredLanguage())}function e(t,e,n,a){"use strict";var r,i,s,o,u,l,c,f,g,p,h,d,v,m,$,y,b={},S=[],L=t,j=[],w="translate-cloak",N=!1,C=!1,O=".",E=!1,P=!1,k=0,A=!0,z="default",T={default:function(t){return(t||"").split("-").join("_")},java:function(t){var e=(t||"").split("-").join("_"),n=e.split("_");return n.length>1?n[0].toLowerCase()+"_"+n[1].toUpperCase():e},bcp47:function(t){var e=(t||"").split("_").join("-"),n=e.split("-");return n.length>1?n[0].toLowerCase()+"-"+n[1].toUpperCase():e},"iso639-1":function(t){return(t||"").split("_").join("-").split("-")[0].toLowerCase()}},x=function(){if(angular.isFunction(a.getLocale))return a.getLocale();var t,n,r=e.$get().navigator,i=["language","browserLanguage","systemLanguage","userLanguage"];if(angular.isArray(r.languages))for(t=0;t<r.languages.length;t++)if((n=r.languages[t])&&n.length)return n;for(t=0;t<i.length;t++)if((n=r[i[t]])&&n.length)return n;return null};x.displayName="angular-translate/service: getFirstBrowserLanguage";var F=function(){var t=x()||"";return T[z]&&(t=T[z](t)),t};F.displayName="angular-translate/service: getLocale";var I=function(t,e){for(var n=0,a=t.length;n<a;n++)if(t[n]===e)return n;return-1},_=function(){return this.toString().replace(/^\s+|\s+$/g,"")},V=function(t){return angular.isString(t)?t.toLowerCase():t},R=function(t){if(t){for(var e=[],n=V(t),a=0,r=S.length;a<r;a++)e.push(V(S[a]));if((a=I(e,n))>-1)return S[a];if(i){var s;for(var o in i)if(i.hasOwnProperty(o)){var u=!1,l=Object.prototype.hasOwnProperty.call(i,o)&&V(o)===V(t);if("*"===o.slice(-1)&&(u=V(o.slice(0,-1))===V(t.slice(0,o.length-1))),(l||u)&&(s=i[o],I(e,V(s))>-1))return s}}var c=t.split("_");return c.length>1&&I(e,V(c[0]))>-1?c[0]:void 0}},D=function(t,e){if(!t&&!e)return b;if(t&&!e){if(angular.isString(t))return b[t]}else angular.isObject(b[t])||(b[t]={}),angular.extend(b[t],K(e));return this};this.translations=D,this.cloakClassName=function(t){return t?(w=t,this):w},this.nestedObjectDelimeter=function(t){return t?(O=t,this):O};var K=function(t,e,n,a){var r,i,s;e||(e=[]),n||(n={});for(r in t)Object.prototype.hasOwnProperty.call(t,r)&&(s=t[r],angular.isObject(s)?K(s,e.concat(r),n,r):(i=e.length?""+e.join(O)+O+r:r,e.length&&r===a&&(n[""+e.join(O)]="@:"+i),n[i]=s));return n};K.displayName="flatObject",this.addInterpolation=function(t){return j.push(t),this},this.useMessageFormatInterpolation=function(){return this.useInterpolation("$translateMessageFormatInterpolation")},this.useInterpolation=function(t){return p=t,this},this.useSanitizeValueStrategy=function(t){return n.useStrategy(t),this},this.preferredLanguage=function(t){return t?(M(t),this):r};var M=function(t){return t&&(r=t),r};this.translationNotFoundIndicator=function(t){return this.translationNotFoundIndicatorLeft(t),this.translationNotFoundIndicatorRight(t),this},this.translationNotFoundIndicatorLeft=function(t){return t?(v=t,this):v},this.translationNotFoundIndicatorRight=function(t){return t?(m=t,this):m},this.fallbackLanguage=function(t){return U(t),this};var U=function(t){return t?(angular.isString(t)?(o=!0,s=[t]):angular.isArray(t)&&(o=!1,s=t),angular.isString(r)&&I(s,r)<0&&s.push(r),this):o?s[0]:s};this.use=function(t){if(t){if(!b[t]&&!h)throw new Error("$translateProvider couldn't find translationTable for langKey: '"+t+"'");return u=t,this}return u},this.resolveClientLocale=function(){return F()};var H=function(t){return t?(L=t,this):f?f+L:L};this.storageKey=H,this.useUrlLoader=function(t,e){return this.useLoader("$translateUrlLoader",angular.extend({url:t},e))},this.useStaticFilesLoader=function(t){return this.useLoader("$translateStaticFilesLoader",t)},this.useLoader=function(t,e){return h=t,d=e||{},this},this.useLocalStorage=function(){return this.useStorage("$translateLocalStorage")},this.useCookieStorage=function(){return this.useStorage("$translateCookieStorage")},this.useStorage=function(t){return c=t,this},this.storagePrefix=function(t){return t?(f=t,this):t},this.useMissingTranslationHandlerLog=function(){return this.useMissingTranslationHandler("$translateMissingTranslationHandlerLog")},this.useMissingTranslationHandler=function(t){return g=t,this},this.usePostCompiling=function(t){return N=!!t,this},this.forceAsyncReload=function(t){return C=!!t,this},this.uniformLanguageTag=function(t){return t?angular.isString(t)&&(t={standard:t}):t={},z=t.standard,this},this.determinePreferredLanguage=function(t){var e=t&&angular.isFunction(t)?t():F();return r=S.length?R(e)||e:e,this},this.registerAvailableLanguageKeys=function(t,e){return t?(S=t,e&&(i=e),this):S},this.useLoaderCache=function(t){return!1===t?$=void 0:!0===t?$=!0:void 0===t?$="$translationCache":t&&($=t),this},this.directivePriority=function(t){return void 0===t?k:(k=t,this)},this.statefulFilter=function(t){return void 0===t?A:(A=t,this)},this.postProcess=function(t){return y=t||void 0,this},this.keepContent=function(t){return P=!!t,this},this.$get=["$log","$injector","$rootScope","$q",function(t,e,n,a){var i,f,z,T=e.get(p||"$translateDefaultInterpolation"),x=!1,V={},G={},q=function(t,e,n,o,l,g){!u&&r&&(u=r);var p=l&&l!==u?R(l)||l:u;if(l&&lt(l),angular.isArray(t)){return function(t){for(var r={},i=[],s=0,u=t.length;s<u;s++)i.push(function(t){var i=a.defer(),s=function(e){r[t]=e,i.resolve([t,e])};return q(t,e,n,o,l,g).then(s,s),i.promise}(t[s]));return a.all(i).then(function(){return r})}(t)}var h=a.defer();t&&(t=_.apply(t));var d=function(){var t=G[p]||G[r];if(f=0,c&&!t){var e=i.get(L);if(t=G[e],s&&s.length){var n=I(s,e);f=0===n?1:0,I(s,r)<0&&s.push(r)}}return t}();if(d){var v=function(){l||(p=u),it(t,e,n,o,p,g).then(h.resolve,h.reject)};v.displayName="promiseResolved",d.finally(v).catch(angular.noop)}else it(t,e,n,o,p,g).then(h.resolve,h.reject);return h.promise},Y=function(t){return v&&(t=[v,t].join(" ")),m&&(t=[t,m].join(" ")),t},B=function(t){u=t,c&&i.put(q.storageKey(),u),n.$emit("$translateChangeSuccess",{language:t}),T.setLocale(u);var e=function(t,e){V[e].setLocale(u)};e.displayName="eachInterpolatorLocaleSetter",angular.forEach(V,e),n.$emit("$translateChangeEnd",{language:t})},J=function(t){if(!t)throw"No language key specified for loading.";var r=a.defer();n.$emit("$translateLoadingStart",{language:t}),x=!0;var i=$;"string"==typeof i&&(i=e.get(i));var s=angular.extend({},d,{key:t,$http:angular.extend({},{cache:i},d.$http)}),o=function(e){var a={};n.$emit("$translateLoadingSuccess",{language:t}),angular.isArray(e)?angular.forEach(e,function(t){angular.extend(a,K(t))}):angular.extend(a,K(e)),x=!1,r.resolve({key:t,table:a}),n.$emit("$translateLoadingEnd",{language:t})};o.displayName="onLoaderSuccess";var u=function(t){n.$emit("$translateLoadingError",{language:t}),r.reject(t),n.$emit("$translateLoadingEnd",{language:t})};return u.displayName="onLoaderError",e.get(h)(s).then(o,u),r.promise};if(c&&(!(i=e.get(c)).get||!i.put))throw new Error("Couldn't use storage '"+c+"', missing get() or put() method!");if(j.length){var Q=function(t){var n=e.get(t);n.setLocale(r||u),V[n.getInterpolationIdentifier()]=n};Q.displayName="interpolationFactoryAdder",angular.forEach(j,Q)}var W=function(t){var e=a.defer();if(Object.prototype.hasOwnProperty.call(b,t))e.resolve(b[t]);else if(G[t]){var n=function(t){D(t.key,t.table),e.resolve(t.table)};n.displayName="translationTableResolver",G[t].then(n,e.reject)}else e.reject();return e.promise},X=function(t,e,n,r,i){var s=a.defer(),o=function(a){if(Object.prototype.hasOwnProperty.call(a,e)&&null!==a[e]){r.setLocale(t);var o=a[e];if("@:"===o.substr(0,2))X(t,o.substr(2),n,r,i).then(s.resolve,s.reject);else{var l=r.interpolate(a[e],n,"service",i,e);l=ut(e,a[e],l,n,t),s.resolve(l)}r.setLocale(u)}else s.reject()};return o.displayName="fallbackTranslationResolver",W(t).then(o,s.reject),s.promise},Z=function(t,e,n,a,r){var i,s=b[t];if(s&&Object.prototype.hasOwnProperty.call(s,e)&&null!==s[e]){if(a.setLocale(t),i=a.interpolate(s[e],n,"filter",r,e),i=ut(e,s[e],i,n,t,r),!angular.isString(i)&&angular.isFunction(i.$$unwrapTrustedValue)){var o=i.$$unwrapTrustedValue();if("@:"===o.substr(0,2))return Z(t,o.substr(2),n,a,r)}else if("@:"===i.substr(0,2))return Z(t,i.substr(2),n,a,r);a.setLocale(u)}return i},tt=function(t,n,a,r){return g?e.get(g)(t,u,n,a,r):t},et=function(t,e,n,r,i,o){var u=a.defer();if(t<s.length){var l=s[t];X(l,e,n,r,o).then(function(t){u.resolve(t)},function(){return et(t+1,e,n,r,i,o).then(u.resolve,u.reject)})}else if(i)u.resolve(i);else{var c=tt(e,n,i);g&&c?u.resolve(c):u.reject(Y(e))}return u.promise},nt=function(t,e,n,a,r){var i;if(t<s.length){var o=s[t];(i=Z(o,e,n,a,r))||""===i||(i=nt(t+1,e,n,a))}return i},at=function(t,e,n,a,r){return et(z>0?z:f,t,e,n,a,r)},rt=function(t,e,n,a){return nt(z>0?z:f,t,e,n,a)},it=function(t,e,n,r,i,o){var u=a.defer(),l=i?b[i]:b,c=n?V[n]:T;if(l&&Object.prototype.hasOwnProperty.call(l,t)&&null!==l[t]){var f=l[t];if("@:"===f.substr(0,2))q(f.substr(2),e,n,r,i,o).then(u.resolve,u.reject);else{var p=c.interpolate(f,e,"service",o,t);p=ut(t,f,p,e,i),u.resolve(p)}}else{var h;g&&!x&&(h=tt(t,e,r)),i&&s&&s.length?at(t,e,c,r,o).then(function(t){u.resolve(t)},function(t){u.reject(Y(t))}):g&&!x&&h?r?u.resolve(r):u.resolve(h):r?u.resolve(r):u.reject(Y(t))}return u.promise},st=function(t,e,n,a,r){var i,o=a?b[a]:b,u=T;if(V&&Object.prototype.hasOwnProperty.call(V,n)&&(u=V[n]),o&&Object.prototype.hasOwnProperty.call(o,t)&&null!==o[t]){var l=o[t];"@:"===l.substr(0,2)?i=st(l.substr(2),e,n,a,r):(i=u.interpolate(l,e,"filter",r,t),i=ut(t,l,i,e,a,r))}else{var c;g&&!x&&(c=tt(t,e,r)),a&&s&&s.length?(f=0,i=rt(t,e,u,r)):i=g&&!x&&c?c:Y(t)}return i},ot=function(t){l===t&&(l=void 0),G[t]=void 0},ut=function(t,n,a,r,i,s){var o=y;return o&&("string"==typeof o&&(o=e.get(o)),o)?o(t,n,a,r,i,s):a},lt=function(t){b[t]||!h||G[t]||(G[t]=J(t).then(function(t){return D(t.key,t.table),t}))};q.preferredLanguage=function(t){return t&&M(t),r},q.cloakClassName=function(){return w},q.nestedObjectDelimeter=function(){return O},q.fallbackLanguage=function(t){if(void 0!==t&&null!==t){if(U(t),h&&s&&s.length)for(var e=0,n=s.length;e<n;e++)G[s[e]]||(G[s[e]]=J(s[e]));q.use(q.use())}return o?s[0]:s},q.useFallbackLanguage=function(t){if(void 0!==t&&null!==t)if(t){var e=I(s,t);e>-1&&(z=e)}else z=0},q.proposedLanguage=function(){return l},q.storage=function(){return i},q.negotiateLocale=R,q.use=function(t){if(!t)return u;var e=a.defer();e.promise.then(null,angular.noop),n.$emit("$translateChangeStart",{language:t});var r=R(t);return S.length>0&&!r?a.reject(t):(r&&(t=r),l=t,!C&&b[t]||!h||G[t]?G[t]?G[t].then(function(t){return l===t.key&&B(t.key),e.resolve(t.key),t},function(t){return!u&&s&&s.length>0&&s[0]!==t?q.use(s[0]).then(e.resolve,e.reject):e.reject(t)}):(e.resolve(t),B(t)):(G[t]=J(t).then(function(n){return D(n.key,n.table),e.resolve(n.key),l===t&&B(n.key),n},function(t){return n.$emit("$translateChangeError",{language:t}),e.reject(t),n.$emit("$translateChangeEnd",{language:t}),a.reject(t)}),G[t].finally(function(){ot(t)}).catch(angular.noop)),e.promise)},q.resolveClientLocale=function(){return F()},q.storageKey=function(){return H()},q.isPostCompilingEnabled=function(){return N},q.isForceAsyncReloadEnabled=function(){return C},q.isKeepContent=function(){return P},q.refresh=function(t){function e(t){var e=J(t);return G[t]=e,e.then(function(e){b[t]={},D(t,e.table),i[t]=!0},angular.noop),e}if(!h)throw new Error("Couldn't refresh translation table, no loader registered!");n.$emit("$translateRefreshStart",{language:t});var r=a.defer(),i={};if(r.promise.then(function(){for(var t in b)b.hasOwnProperty(t)&&(t in i||delete b[t]);u&&B(u)},angular.noop).finally(function(){n.$emit("$translateRefreshEnd",{language:t})}),t)b[t]?e(t).then(r.resolve,r.reject):r.reject();else{var o=s&&s.slice()||[];u&&-1===o.indexOf(u)&&o.push(u),a.all(o.map(e)).then(r.resolve,r.reject)}return r.promise},q.instant=function(t,e,n,a,i){var o=a&&a!==u?R(a)||a:u;if(null===t||angular.isUndefined(t))return t;if(a&&lt(a),angular.isArray(t)){for(var l={},c=0,f=t.length;c<f;c++)l[t[c]]=q.instant(t[c],e,n,a,i);return l}if(angular.isString(t)&&t.length<1)return t;t&&(t=_.apply(t));var p,h=[];r&&h.push(r),o&&h.push(o),s&&s.length&&(h=h.concat(s));for(var d=0,$=h.length;d<$;d++){var y=h[d];if(b[y]&&void 0!==b[y][t]&&(p=st(t,e,n,o,i)),void 0!==p)break}if(!p&&""!==p)if(v||m)p=Y(t);else{p=T.interpolate(t,e,"filter",i);var S;g&&!x&&(S=tt(t,e,i)),g&&!x&&S&&(p=S)}return p},q.versionInfo=function(){return"2.16.0"},q.loaderCache=function(){return $},q.directivePriority=function(){return k},q.statefulFilter=function(){return A},q.isReady=function(){return E};var ct=a.defer();ct.promise.then(function(){E=!0}),q.onReady=function(t){var e=a.defer();return angular.isFunction(t)&&e.promise.then(t),E?e.resolve():ct.promise.then(e.resolve),e.promise},q.getAvailableLanguageKeys=function(){return S.length>0?S:null},q.getTranslationTable=function(t){return(t=t||q.use())&&b[t]?angular.copy(b[t]):null};var ft=n.$on("$translateReady",function(){ct.resolve(),ft(),ft=null}),gt=n.$on("$translateChangeEnd",function(){ct.resolve(),gt(),gt=null});if(h){if(angular.equals(b,{})&&q.use()&&q.use(q.use()),s&&s.length)for(var pt=0,ht=s.length;pt<ht;pt++){var dt=s[pt];!C&&b[dt]||(G[dt]=J(dt).then(function(t){return D(t.key,t.table),n.$emit("$translateChangeEnd",{language:t.key}),t}))}}else n.$emit("$translateReady",{language:q.use()});return q}]}function n(t,e){"use strict";var n,a={};return a.setLocale=function(t){n=t},a.getInterpolationIdentifier=function(){return"default"},a.useSanitizeValueStrategy=function(t){return e.useStrategy(t),this},a.interpolate=function(n,a,r,i,s){a=a||{},a=e.sanitize(a,"params",i,r);var o;return angular.isNumber(n)?o=""+n:angular.isString(n)?(o=t(n)(a),o=e.sanitize(o,"text",i,r)):o="",o},a}function a(t,e,n,a,i){"use strict";var s=function(){return this.toString().replace(/^\s+|\s+$/g,"")},o=function(t){return angular.isString(t)?t.toLowerCase():t};return{restrict:"AE",scope:!0,priority:t.directivePriority(),compile:function(u,l){var c=l.translateValues?l.translateValues:void 0,f=l.translateInterpolation?l.translateInterpolation:void 0,g=l.translateSanitizeStrategy?l.translateSanitizeStrategy:void 0,p=u[0].outerHTML.match(/translate-value-+/i),h="^(.*)("+e.startSymbol()+".*"+e.endSymbol()+")(.*)",d="^(.*)"+e.startSymbol()+"(.*)"+e.endSymbol()+"(.*)";return function(u,v,m){u.interpolateParams={},u.preText="",u.postText="",u.translateNamespace=r(u);var $={},y=function(t){if(angular.isFunction(y._unwatchOld)&&(y._unwatchOld(),y._unwatchOld=void 0),angular.equals(t,"")||!angular.isDefined(t)){var n=s.apply(v.text()),a=n.match(h);if(angular.isArray(a)){u.preText=a[1],u.postText=a[3],$.translate=e(a[2])(u.$parent);var r=n.match(d);angular.isArray(r)&&r[2]&&r[2].length&&(y._unwatchOld=u.$watch(r[2],function(t){$.translate=t,j()}))}else $.translate=n||void 0}else $.translate=t;j()};!function(t,e,n){if(e.translateValues&&angular.extend(t,a(e.translateValues)(u.$parent)),p)for(var r in n)Object.prototype.hasOwnProperty.call(e,r)&&"translateValue"===r.substr(0,14)&&"translateValues"!==r&&(t[o(r.substr(14,1))+r.substr(15)]=n[r])}(u.interpolateParams,m,l);var b=!0;m.$observe("translate",function(t){void 0===t?y(""):""===t&&b||($.translate=t,j()),b=!1});for(var S in m)m.hasOwnProperty(S)&&"translateAttr"===S.substr(0,13)&&S.length>13&&function(t){m.$observe(t,function(e){$[t]=e,j()})}(S);if(m.$observe("translateDefault",function(t){u.defaultText=t,j()}),g&&m.$observe("translateSanitizeStrategy",function(t){u.sanitizeStrategy=a(t)(u.$parent),j()}),c&&m.$observe("translateValues",function(t){t&&u.$parent.$watch(function(){angular.extend(u.interpolateParams,a(t)(u.$parent))})}),p){for(var L in m)Object.prototype.hasOwnProperty.call(m,L)&&"translateValue"===L.substr(0,14)&&"translateValues"!==L&&function(t){m.$observe(t,function(e){var n=o(t.substr(14,1))+t.substr(15);u.interpolateParams[n]=e})}(L)}var j=function(){for(var t in $)$.hasOwnProperty(t)&&void 0!==$[t]&&w(t,$[t],u,u.interpolateParams,u.defaultText,u.translateNamespace)},w=function(e,n,a,r,i,s){n?(s&&"."===n.charAt(0)&&(n=s+n),t(n,r,f,i,a.translateLanguage,a.sanitizeStrategy).then(function(t){N(t,a,!0,e)},function(t){N(t,a,!1,e)})):N(n,a,!1,e)},N=function(e,a,r,i){if(r||void 0!==a.defaultText&&(e=a.defaultText),"translate"===i){(r||!r&&!t.isKeepContent()&&void 0===m.translateKeepContent)&&v.empty().append(a.preText+e+a.postText);var s=t.isPostCompilingEnabled(),o=void 0!==l.translateCompile,u=o&&"false"!==l.translateCompile;(s&&!o||u)&&n(v.contents())(a)}else{var c=m.$attr[i];"data-"===c.substr(0,5)&&(c=c.substr(5)),c=c.substr(15),v.attr(c,e)}};(c||p||m.translateDefault)&&u.$watch("interpolateParams",j,!0),u.$on("translateLanguageChanged",j);var C=i.$on("$translateChangeSuccess",j);v.text().length?y(m.translate?m.translate:""):m.translate&&y(m.translate),j(),u.$on("$destroy",C)}}}}function r(t){"use strict";return t.translateNamespace?t.translateNamespace:t.$parent?r(t.$parent):void 0}function i(t,e){"use strict";return{restrict:"A",priority:t.directivePriority(),link:function(n,a,r){var i,o,u,l={},c=function(){angular.forEach(i,function(e,i){e&&(l[i]=!0,n.translateNamespace&&"."===e.charAt(0)&&(e=n.translateNamespace+e),t(e,o,r.translateInterpolation,void 0,n.translateLanguage,u).then(function(t){a.attr(i,t)},function(t){a.attr(i,t)}))}),angular.forEach(l,function(t,e){i[e]||(a.removeAttr(e),delete l[e])})};s(n,r.translateAttr,function(t){i=t},c),s(n,r.translateValues,function(t){o=t},c),s(n,r.translateSanitizeStrategy,function(t){u=t},c),r.translateValues&&n.$watch(r.translateValues,c,!0),n.$on("translateLanguageChanged",c);var f=e.$on("$translateChangeSuccess",c);c(),n.$on("$destroy",f)}}}function s(t,e,n,a){"use strict";e&&("::"===e.substr(0,2)?e=e.substr(2):t.$watch(e,function(t){n(t),a()},!0),n(t.$eval(e)))}function o(t,e){"use strict";return{compile:function(n){var a=function(e){e.addClass(t.cloakClassName())},r=function(e){e.removeClass(t.cloakClassName())};return a(n),function(n,i,s){var o=r.bind(this,i),u=a.bind(this,i);s.translateCloak&&s.translateCloak.length?(s.$observe("translateCloak",function(e){t(e).then(o,u)}),e.$on("$translateChangeSuccess",function(){t(s.translateCloak).then(o,u)})):t.onReady(o)}}}}function u(){"use strict";return{restrict:"A",scope:!0,compile:function(){return{pre:function(t,e,n){t.translateNamespace=r(t),t.translateNamespace&&"."===n.translateNamespace.charAt(0)?t.translateNamespace+=n.translateNamespace:t.translateNamespace=n.translateNamespace}}}}}function r(t){"use strict";return t.translateNamespace?t.translateNamespace:t.$parent?r(t.$parent):void 0}function l(){"use strict";return{restrict:"A",scope:!0,compile:function(){return function(t,e,n){n.$observe("translateLanguage",function(e){t.translateLanguage=e}),t.$watch("translateLanguage",function(){t.$broadcast("translateLanguageChanged")})}}}}function c(t,e){"use strict";var n=function(n,a,r,i){if(!angular.isObject(a)){var s=this||{__SCOPE_IS_NOT_AVAILABLE:"More info at https://github.com/angular/angular.js/commit/8863b9d04c722b278fa93c5d66ad1e578ad6eb1f"};a=t(a)(s)}return e.instant(n,a,r,i)};return e.statefulFilter()&&(n.$stateful=!0),n}function f(t){"use strict";return t("translations")}return t.$inject=["$translate"],e.$inject=["$STORAGE_KEY","$windowProvider","$translateSanitizationProvider","pascalprechtTranslateOverrider"],n.$inject=["$interpolate","$translateSanitization"],a.$inject=["$translate","$interpolate","$compile","$parse","$rootScope"],i.$inject=["$translate","$rootScope"],o.$inject=["$translate","$rootScope"],c.$inject=["$parse","$translate"],f.$inject=["$cacheFactory"],angular.module("pascalprecht.translate",["ng"]).run(t),t.displayName="runTranslate",angular.module("pascalprecht.translate").provider("$translateSanitization",function(){"use strict";var t,e,n,a=null,r=!1,i=!1;(n={sanitize:function(t,e){return"text"===e&&(t=o(t)),t},escape:function(t,e){return"text"===e&&(t=s(t)),t},sanitizeParameters:function(t,e){return"params"===e&&(t=l(t,o)),t},escapeParameters:function(t,e){return"params"===e&&(t=l(t,s)),t},sce:function(t,e,n){return"text"===e?t=u(t):"params"===e&&"filter"!==n&&(t=l(t,s)),t},sceParameters:function(t,e){return"params"===e&&(t=l(t,u)),t}}).escaped=n.escapeParameters,this.addStrategy=function(t,e){return n[t]=e,this},this.removeStrategy=function(t){return delete n[t],this},this.useStrategy=function(t){return r=!0,a=t,this},this.$get=["$injector","$log",function(s,o){var u={},l=function(t,e,a,r){return angular.forEach(r,function(r){if(angular.isFunction(r))t=r(t,e,a);else if(angular.isFunction(n[r]))t=n[r](t,e,a);else{if(!angular.isString(n[r]))throw new Error("pascalprecht.translate.$translateSanitization: Unknown sanitization strategy: '"+r+"'");if(!u[n[r]])try{u[n[r]]=s.get(n[r])}catch(t){throw u[n[r]]=function(){},new Error("pascalprecht.translate.$translateSanitization: Unknown sanitization strategy: '"+r+"'")}t=u[n[r]](t,e,a)}}),t},c=function(){r||i||(o.warn("pascalprecht.translate.$translateSanitization: No sanitization strategy has been configured. This can have serious security implications. See http://angular-translate.github.io/docs/#/guide/19_security for details."),i=!0)};return s.has("$sanitize")&&(t=s.get("$sanitize")),s.has("$sce")&&(e=s.get("$sce")),{useStrategy:function(t){return function(e){t.useStrategy(e)}}(this),sanitize:function(t,e,n,r){if(a||c(),n||null===n||(n=a),!n)return t;r||(r="service");var i=angular.isArray(n)?n:[n];return l(t,e,r,i)}}}];var s=function(t){var e=angular.element("<div></div>");return e.text(t),e.html()},o=function(e){if(!t)throw new Error("pascalprecht.translate.$translateSanitization: Error cannot find $sanitize service. Either include the ngSanitize module (https://docs.angularjs.org/api/ngSanitize) or use a sanitization strategy which does not depend on $sanitize, such as 'escape'.");return t(e)},u=function(t){if(!e)throw new Error("pascalprecht.translate.$translateSanitization: Error cannot find $sce service.");return e.trustAsHtml(t)},l=function(t,e,n){if(angular.isDate(t))return t;if(angular.isObject(t)){var a=angular.isArray(t)?[]:{};if(n){if(n.indexOf(t)>-1)throw new Error("pascalprecht.translate.$translateSanitization: Error cannot interpolate parameter due recursive object")}else n=[];return n.push(t),angular.forEach(t,function(t,r){angular.isFunction(t)||(a[r]=l(t,e,n))}),n.splice(-1,1),a}return angular.isNumber(t)?t:!0===t||!1===t?t:angular.isUndefined(t)||null===t?t:e(t)}}),angular.module("pascalprecht.translate").constant("pascalprechtTranslateOverrider",{}).provider("$translate",e),e.displayName="displayName",angular.module("pascalprecht.translate").factory("$translateDefaultInterpolation",n),n.displayName="$translateDefaultInterpolation",angular.module("pascalprecht.translate").constant("$STORAGE_KEY","NG_TRANSLATE_LANG_KEY"),angular.module("pascalprecht.translate").directive("translate",a),a.displayName="translateDirective",angular.module("pascalprecht.translate").directive("translateAttr",i),i.displayName="translateAttrDirective",angular.module("pascalprecht.translate").directive("translateCloak",o),o.displayName="translateCloakDirective",angular.module("pascalprecht.translate").directive("translateNamespace",u),u.displayName="translateNamespaceDirective",angular.module("pascalprecht.translate").directive("translateLanguage",l),l.displayName="translateLanguageDirective",angular.module("pascalprecht.translate").filter("translate",c),c.displayName="translateFilterFactory",angular.module("pascalprecht.translate").factory("$translationCache",f),f.displayName="$translationCache","pascalprecht.translate"});