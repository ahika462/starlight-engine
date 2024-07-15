package util;

class JsonUtil {
	public static function fromString<T>(string:String):T {
		#if tjson
		return tjson.TJSON.parse(string);
		#else
		return haxe.Json.parse(string);
		#end
	}

	public static function fromFile<T>(file:String):T {
		return fromString(openfl.Assets.getText(file));
	}

	public static function toString<T>(object:T):String {
		#if tjson
		return tjson.TJSON.encode(object, 'fancy');
		#else
		return haxe.Json.stringify(object, '\t');
		#end
	}

	public static function toFile<T>(object:T, path:String):String {
		var string = toString(object);
		#if !sys
		trace('File writing not implemented for this target');
		#else
		sys.io.File.saveContent(path, string);
		#end
		return string;
	}
}