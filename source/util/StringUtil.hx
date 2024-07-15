package util;

using StringTools;

class StringUtil {
	public static function formatToSongPath(string:String):String {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(string.replace(' ', '-')).join('-');
		return hideChars.split(path).join('').toLowerCase();
	}

	public static function capitalize(string:String):String {
		return string.charAt(0).toUpperCase() + string.substr(1).toLowerCase();
	}
}