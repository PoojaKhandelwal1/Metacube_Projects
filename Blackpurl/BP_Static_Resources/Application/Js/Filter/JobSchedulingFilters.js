define(['Routing_AppJs_PK'], function (Routing_AppJs_PK) {
    Routing_AppJs_PK.filter('spliceTime', function () {
        return function (value) {
            if (!value) return '';
            if (value.toString().split(':')[1] && value.toString().split(':')[1].indexOf('00') != -1) {
                value = value.toString().split(':')[0];
                if (value.toString().split(':')[0].length == 1) {
                    value = value;
                }
            }
            return value;
        };
    });
});