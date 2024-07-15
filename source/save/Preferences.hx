package save;

import flixel.input.keyboard.FlxKey;
import input.Controls.Control;

class Preferences {
	public static var keyboardBinds:Map<Control, Array<FlxKey>> = [
		UI_UP      => [W, UP],
		UI_DOWN    => [S, DOWN],
		UI_LEFT    => [A, LEFT],
		UI_RIGHT   => [D, RIGHT],

		ACCEPT     => [SPACE, ENTER],
		BACK       => [ESCAPE, BACKSPACE],

		NOTE_UP    => [W, UP],
		NOTE_DOWN  => [S, DOWN],
		NOTE_LEFT  => [A, LEFT],
		NOTE_RIGHT => [D, RIGHT],

		RESET      => [R]
	];

	public static var antialiasing = true;

	public static var ghostTapping = true;
	public static var downscroll = false;
}