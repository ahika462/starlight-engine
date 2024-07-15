package input;

import flixel.input.gamepad.FlxGamepadInputID;
import save.Preferences;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

enum Control {
	UI_UP;
	UI_DOWN;
	UI_LEFT;
	UI_RIGHT;

	ACCEPT;
	BACK;

	NOTE_UP;
	NOTE_DOWN;
	NOTE_LEFT;
	NOTE_RIGHT;

	RESET;
}

class Controls {
	public static var instance(get, null):Controls;

	static function get_instance() {
		if (instance == null) initialize();
		return instance;
	}

	public var keyboardBinds:Map<Control, Array<FlxKey>> = [];
	public var gamepadBinds:Map<Control, Array<FlxGamepadInputID>> = [];

	public var UI_UP_P(get, never):Bool;
	public var UI_DOWN_P(get, never):Bool;
	public var UI_LEFT_P(get, never):Bool;
	public var UI_RIGHT_P(get, never):Bool;

	function get_UI_UP_P() {
		return justPressed(Control.UI_UP);
	}

	function get_UI_DOWN_P() {
		return justPressed(Control.UI_DOWN);
	}

	function get_UI_LEFT_P() {
		return justPressed(Control.UI_LEFT);
	}

	function get_UI_RIGHT_P() {
		return justPressed(Control.UI_RIGHT);
	}

	public var UI_UP(get, never):Bool;
	public var UI_DOWN(get, never):Bool;
	public var UI_LEFT(get, never):Bool;
	public var UI_RIGHT(get, never):Bool;

	function get_UI_UP() {
		return pressed(Control.UI_UP);
	}

	function get_UI_DOWN() {
		return pressed(Control.UI_DOWN);
	}

	function get_UI_LEFT() {
		return pressed(Control.UI_LEFT);
	}

	function get_UI_RIGHT() {
		return pressed(Control.UI_RIGHT);
	}

	public var UI_UP_R(get, never):Bool;
	public var UI_DOWN_R(get, never):Bool;
	public var UI_LEFT_R(get, never):Bool;
	public var UI_RIGHT_R(get, never):Bool;

	function get_UI_UP_R() {
		return justReleased(Control.UI_UP);
	}

	function get_UI_DOWN_R() {
		return justReleased(Control.UI_DOWN);
	}

	function get_UI_LEFT_R() {
		return justReleased(Control.UI_LEFT);
	}

	function get_UI_RIGHT_R() {
		return justReleased(Control.UI_RIGHT);
	}

	public var ACCEPT(get, never):Bool;
	public var BACK(get, never):Bool;

	function get_ACCEPT() {
		return justPressed(Control.ACCEPT);
	}

	function get_BACK() {
		return justPressed(Control.BACK);
	}

	public var NOTE_UP_P(get, never):Bool;
	public var NOTE_DOWN_P(get, never):Bool;
	public var NOTE_LEFT_P(get, never):Bool;
	public var NOTE_RIGHT_P(get, never):Bool;

	function get_NOTE_UP_P() {
		return justPressed(Control.NOTE_UP);
	}

	function get_NOTE_DOWN_P() {
		return justPressed(Control.NOTE_DOWN);
	}

	function get_NOTE_LEFT_P() {
		return justPressed(Control.NOTE_LEFT);
	}

	function get_NOTE_RIGHT_P() {
		return justPressed(Control.NOTE_RIGHT);
	}

	public var NOTE_UP(get, never):Bool;
	public var NOTE_DOWN(get, never):Bool;
	public var NOTE_LEFT(get, never):Bool;
	public var NOTE_RIGHT(get, never):Bool;

	function get_NOTE_UP() {
		return pressed(Control.NOTE_UP);
	}

	function get_NOTE_DOWN() {
		return pressed(Control.NOTE_DOWN);
	}

	function get_NOTE_LEFT() {
		return pressed(Control.NOTE_LEFT);
	}

	function get_NOTE_RIGHT() {
		return pressed(Control.NOTE_RIGHT);
	}

	public var NOTE_UP_R(get, never):Bool;
	public var NOTE_DOWN_R(get, never):Bool;
	public var NOTE_LEFT_R(get, never):Bool;
	public var NOTE_RIGHT_R(get, never):Bool;

	function get_NOTE_UP_R() {
		return justReleased(Control.NOTE_UP);
	}

	function get_NOTE_DOWN_R() {
		return justReleased(Control.NOTE_DOWN);
	}

	function get_NOTE_LEFT_R() {
		return justReleased(Control.NOTE_LEFT);
	}

	function get_NOTE_RIGHT_R() {
		return justReleased(Control.NOTE_RIGHT);
	}

	public var RESET(get, never):Bool;

	function get_RESET() {
		return justPressed(Control.RESET);
	}

	public static function initialize() {
		instance = new Controls();
		instance.keyboardBinds = Preferences.keyboardBinds.copy();
	}

	function new() {}

	function justPressed(control:Control):Bool {
		var keys = keyboardBinds.get(control);
		var buttons = gamepadBinds.get(control);
		return (keys != null && FlxG.keys.anyJustPressed(keys)) || (buttons != null && FlxG.gamepads.firstActive.anyJustPressed(buttons));
	}

	function pressed(control:Control):Bool {
		var keys = keyboardBinds.get(control);
		var buttons = gamepadBinds.get(control);
		return (keys != null && FlxG.keys.anyPressed(keys)) || (buttons != null && FlxG.gamepads.firstActive.anyPressed(buttons));
	}

	function justReleased(control:Control):Bool {
		var keys = keyboardBinds.get(control);
		var buttons = gamepadBinds.get(control);
		return (keys != null && FlxG.keys.anyJustReleased(keys)) || (buttons != null && FlxG.gamepads.firstActive.anyJustReleased(buttons));
	}
}