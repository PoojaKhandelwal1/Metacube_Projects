if (!Object.values) {
	Object.values = function(obj) {
		var res = [];
		for (var i in obj) {
			if (obj.hasOwnProperty(i)) {
				res.push(obj[i]);
			}
		}
		return res;
	};
}
if (!String.prototype.startsWith) {
	String.prototype.startsWith = function(searchString, position) {
		position = position || 0;
		return this.substr(position, searchString.length) === searchString;
	};
}