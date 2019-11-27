define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
	Routing_AppJs_PK.filter('highlight', function () {
        return function (text, search, caseSensitive) {
            if (text && (search || angular.isNumber(search))) {
                text = text.toString();
                search = search.toString();
                if (caseSensitive) {
                    return text.split(search).join('<span class="highlighted-text">' + search + '</span>');
                } else {
                    return text.replace(new RegExp(search, 'gi'), '<span class="highlighted-text">$&</span>');
                }
            } else {
                return text;
            }
        };
    });
});