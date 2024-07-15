package system.macros;

import util.JsonUtil;
import haxe.io.Path;
import sys.io.Process;
import haxe.macro.Expr.ExprOf;
import haxe.xml.Access;
import sys.io.File;

class HaxelibVersions {
	public static macro function buildForCrash():ExprOf<String> {
		var result = '';

		var projectSource = File.getContent('project.xml');
		var project = new Access(Xml.parse(projectSource).firstElement());

		for (haxelib in project.nodes.haxelib) {
			var name = haxelib.att.name;
			var version = haxelib.has.version ? haxelib.att.version : getHaxelibVersion(name);

			result += ' - $name ($version)\n';
		}

		return macro $v{result};
	}

	#if macro
	static function getHaxelibVersion(name:String):String {
		try {
			var subProcess = new Process('haxelib', ['libpath', name]);
			var path = subProcess.stdout.readAll().toString();
	
			var isGit       = Path.withoutDirectory(path) == 'git';
			var isMercurial = Path.withoutDirectory(path) == 'mercurial';
			
			var haxelibSource = File.getContent(Path.join([path, 'haxelib.json']));
			var haxelib = JsonUtil.fromString(haxelibSource);
	
			if (isGit || isMercurial) return haxelib.url ?? haxelib.version ?? 'N/A';
			else return haxelib.version ?? 'N/A';
		} catch(_)
			return 'N/A';
	}
	#end
}