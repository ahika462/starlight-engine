package system;

import flixel.FlxG;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;
import openfl.Lib;

using StringTools;

class CrashHandler {
	static var haxelibVersions = system.macros.HaxelibVersions.buildForCrash();

	public static function initialize() {
		#if hl
		hl.Api.setErrorHandler(handleError);
		#elseif cpp
		untyped __global__.__hxcpp_set_critical_error_handler(handleError);
		#else
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e) -> handleError(e.error));
		#end
	}

	static function handleError(v:Dynamic) {
		var report = 'Uncaught exception: $v';
		report += CallStack.toString(CallStack.exceptionStack(true)) + '\n';

		FlxG.stage.window.alert(report, 'Game was crashed');

		#if sys
		report += '\n';
		report += '\n';
		report += 'Haxelib versions:\n';
		report += haxelibVersions;

		var date = Date.now().toString().replace(' ', '_').replace(':', '\'');
		
		if (!sys.FileSystem.exists('crash')) sys.FileSystem.createDirectory('crash');
		sys.io.File.saveContent('crash/StarEngine_$date.txt', report);

		Sys.exit(1);
		#end
	}
}