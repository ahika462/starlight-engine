package editors;

import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import flixel.addons.ui.FlxUIList;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIGroup;

typedef ContextMenuItem = {
	var label:String;
	var callback:()->Void;
}

class ContextMenu extends FlxUIGroup {
	var background:FlxUISprite;
	var list:FlxUIList;

	public function new(x = 0.0, y = 0.0, width:Int = 150, items:Array<ContextMenuItem>) {
		super(x, y);

		background = new FlxUISprite(FlxG.bitmap.create(width, items.length * 20, 0xFF707070));
		add(background);

		var buttons = [for (item in items) new FlxUIButton(0.0, 0.0, item.label, item.callback)];
		for (button in buttons) {
			button.resize(width, 20.0);
			button.label.alignment = LEFT;
			button.label.offset.x -= 6.0;
		}

		list = new FlxUIList(0.0, 0.0, cast buttons, background.width, background.height);
		add(list);
	}

	override function update(elapsed:Float) {
		if ((FlxG.mouse.justPressed || FlxG.mouse.justPressedRight || FlxG.mouse.justPressedMiddle) && !FlxG.mouse.overlaps(this, camera)) destroy();

		if (exists) super.update(elapsed);
	}
}