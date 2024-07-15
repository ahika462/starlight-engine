import system.macros.BuildDate;
import system.CrashHandler;
import flixel.FlxState;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var instance:Main;

	final gameWidth:Int = 1280;
	final gameHeight:Int = 720;
	public var initialState:Class<FlxState> = play.PlayState;
	final framerate:Int = #if web 60 #else 144 #end;
	final skipSplash = true;
	final startFullscreen = false;

	public var fpsCounter:FPSCounter;
	public final buildDateString = BuildDate.get();

	public function new() {
		super();
		instance = this;

		#if FEATURE_CRASH_HANDLER
		CrashHandler.initialize();
		#end

		#if DEBUG_CHARACTER_EDITOR
		initialState = editors.character.CharacterEditorState;
		#end

		var game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen);
		addChild(game);

		fpsCounter = new FPSCounter(10, 3, 0xFFFFFFFF);
		addChild(fpsCounter);
	}
}