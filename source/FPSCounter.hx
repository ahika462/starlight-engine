import lime.app.Application;
import flixel.util.FlxStringUtil;
import openfl.system.System;
import openfl.Lib;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

class FPSCounter extends Sprite {
	var textField:TextField;

	var updates:Array<Float> = [];

	public function new(x = 0.0, y = 0.0, color = 0xFF000000) {
		super();

		textField = new TextField();
		textField.defaultTextFormat = new TextFormat('_sans', 12, color);
		textField.selectable = false;
		textField.mouseEnabled = false;
		textField.mouseWheelEnabled = false;
		addChild(textField);

		textField.text = 'FPS: \nRAM: ${FlxStringUtil.formatBytes(System.totalMemory)}\nVersion: ${Application.current.meta.get('version')}\nBuild date: ${Main.instance.buildDateString}';
		textField.width = textField.textWidth + 10.0;
		textField.height = textField.textHeight + 10.0;

		graphics.beginFill(0xFF000000, 0.6);
		graphics.drawRect(0, 0, textField.width, textField.height);
		graphics.endFill();
	}

	override function __enterFrame(deltaTime:Int) {
		var currentTime = Lib.getTimer();
		updates.push(currentTime);

		while (updates[0] < currentTime - 1000) updates.shift();

		textField.text = 'FPS: ${updates.length}\nRAM: ${FlxStringUtil.formatBytes(System.totalMemory)}\nVersion: ${Application.current.meta.get('version')}\nBuild date: ${Main.instance.buildDateString}';

		super.__enterFrame(deltaTime);
	}
}