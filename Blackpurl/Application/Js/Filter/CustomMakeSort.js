define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {

    Routing_AppJs_PK.filter('CustomMakeSort', [function () {
        function getPriority(item, SearchItem, filterType) {
            if (SearchItem != undefined) {
                SearchItem = angular.lowercase(SearchItem).trim();
            }
            var itemval = '';
            if (filterType == 'make') {
                itemval = item.UnitMakeName;
            } else if (filterType == 'model') {
                itemval = item.UnitModelName;
            } else if (filterType == 'submodel') {
                itemval = item.SubModelName;
            }
            if (angular.lowercase(itemval.toString()).trim() == SearchItem) {
                return 4;
            }
            if (angular.lowercase(itemval.toString()).indexOf(SearchItem) == 0) {
                return 3;
            } else if (angular.lowercase(itemval.toString()).indexOf(SearchItem) > 0) {
                return 2;
            } else {
                return 1;
            }
        }

        return function (items, SearchItem, filterType) {
            if (SearchItem != undefined) {
                SearchItem = angular.lowercase(SearchItem).trim();
            }
            var filtered = [];
            var itemval = '';
            if (SearchItem == '' || SearchItem == undefined) {
                return items;
            }
            angular.forEach(items, function (item) {
                if (filterType == 'make') {
                    itemval = item.UnitMakeName;
                } else if (filterType == 'model') {
                    itemval = item.UnitModelName;
                } else if (filterType == 'submodel') {
                    itemval = item.SubModelName;
                }
                if (itemval != undefined) {
                    if (angular.lowercase(itemval.toString()).indexOf(SearchItem) != -1) {
                        filtered.push(item);
                    }
                }
            });
            var first = 0;
            var second = 0;
            var counter = 0;
            filtered.sort(function (a, b) {
                if (SearchItem != '') {
                    first = getPriority(a, SearchItem, filterType);
                    second = getPriority(b, SearchItem, filterType);
                    if (first > second) {
                        return -1;
                    } else if (first < second) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
            });
            return filtered;
        };
    }]);
});