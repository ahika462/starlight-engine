package util;

#if hscript_improved
import hscript.Interp;
import hscript.Parser;
import hscript.CustomClassHandler;
#end
import haxe.io.Path;
using StringTools;

class ScriptUtil {
	public static function resolveCustomClass(name:String, path:String): #if hscript_improved CustomClassHandler #else Dynamic #end {
		name = name.replace('/', '.');

		var array = name.split('.');
		
		var i = 0;
		while (array[i].charAt(0) != array[i].charAt(0).toUpperCase()) i++;

		var path = Path.join([path, [for (j in 0...i + 1) array[j]].join('/')]) + '.hx';

		#if hscript_improved
		var parser = new Parser();
		parser.allowJSON = true;
		parser.allowMetadata = true;
		parser.allowTypes = true;
		
		var interp = new Interp();
		interp.allowPublicVariables = true;
		interp.allowStaticVariables = true;

		#if FEATURE_MODDING
		var expr = parser.parseString(sys.io.File.getContent(path), path);
		#else
		var expr = parser.parseString(openfl.Assets.getText(path), path);
		#end
		interp.execute(expr);

		for (customClass in interp.customClasses)
			if (customClass.name == array[array.length - 1]) return customClass;
		#end

		return null;
	}
}