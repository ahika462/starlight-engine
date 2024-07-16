package editors.character;

import play.Character;
import flixel.addons.ui.FlxUI;

class EditProperties extends FlxUI {
	var character:Character;

	public function new(character:Character) {
		super();
		name = 'Properties';
	}
}