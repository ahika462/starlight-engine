package system.macros;

import haxe.macro.Expr.ExprOf;

class BuildDate {
	public static macro function get():ExprOf<String> {
		return macro $v{Date.now().toString()};
	}
}