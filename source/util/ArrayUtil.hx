package util;

class ArrayUtil {
	public static function isEmpty<T>(array:Array<T>):Bool {
		return array == null || array.length == 0;
	}
}