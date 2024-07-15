package scripting;

import util.ScriptUtil;
import play.PlayState;
import play.notes.Note;
import data.SongData.SongEvent;
import system.Paths;

#if hscript_improved
@:build(hscript.macros.ClassExtendMacro.build())
#end
class Script {
	public static function fromFile(path:String):Array<Script> {
		var results:Array<Script> = [];

		#if FEATURE_MODDING
		var fileSource = sys.io.File.getContent(path);
		#else
		var fileSource = openfl.Assets.getText(path);
		#end
		if (fileSource == null) return [];

		#if hscript_improved
		var parser = new hscript.Parser();
		parser.allowJSON = true;
		parser.allowMetadata = true;
		parser.allowTypes = true;
		
		var interp = new hscript.Interp();
		interp.allowPublicVariables = true;
		interp.allowStaticVariables = true;
		/*interp.importFailedCallback = (splitClassName) -> {
			var customClass = ScriptUtil.resolveCustomClass(splitClassName.join('.'), 'assets/scripts');
			if (customClass != null) {
				interp.variables.set(splitClassName[splitClassName.length - 1], customClass);
				return true;
			}
			return false;
		}*/

		var expr = parser.parseString(fileSource, path);
		interp.execute(expr);

		for (customClass in interp.customClasses) {
			var customClassConstructor = Std.downcast(customClass, hscript.CustomClassHandler);
			if (customClassConstructor == null) continue;

			if (customClassConstructor.extend != 'scripting.Script') continue;

			var customClassInstance:Script = customClassConstructor.hnew([]);
			if (customClassInstance == null) continue;

			results.push(customClassInstance);
		}
		#end

		return results;
	}

	/** Current backend event. Can be stopped **/
	public var e = new Event();

	public final game = PlayState.instance;

	public function new() {}

	public function create() {}

	public function preUpdate(elapsed:Float) {}
	public function postUpdate(elapsed:Float) {}

	public function stepHit() {}
	public function beatHit() {}
	public function measureHit() {}

	/** Triggers on SONG event **/
	public function onEvent(event:SongEvent) {}

	public function hitNote(note:Note) {}
	public function missNote(note:Note) {}
	public function ghostTap(data:Int) {}

	public function destroy() {}

	public function toString():String {
		return 'Script';
	}
}