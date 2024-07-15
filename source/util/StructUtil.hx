package util;

class StructUtil {
	public static function merge(mainStruct:Dynamic, subStruct:Dynamic, checkExists = true):Dynamic {
		for (field in Reflect.fields(subStruct)) {
			var value = Reflect.field(subStruct, field);
			if (checkExists && !Reflect.hasField(mainStruct, field)) continue;

			if (Std.isOfType(value, Float) || Std.isOfType(value, Int) || Std.isOfType(value, String) || Std.isOfType(value, Bool))
				Reflect.setField(mainStruct, field, value);
			else merge(Reflect.field(mainStruct, field), value, checkExists);
		}

		return mainStruct;
	}
}