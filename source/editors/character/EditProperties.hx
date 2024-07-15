package editors.character;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUICheckBox;
import play.Character;
import flixel.addons.text.ui.FlxUINumericStepper;
import flixel.addons.text.ui.FlxUITextInput;
import flixel.addons.ui.FlxUI;

class EditProperties extends FlxUI {
	public var parent:Character;

	public var assetPathInput:FlxUITextInput;
	public var antialiasingCheck:FlxUICheckBox;
	public var scaleStepper:FlxUINumericStepper;

	public var healthIconInput:FlxUITextInput;

	public var singDurationStepper:FlxUINumericStepper;
	
	public function new(parent:Character) {
		super();
		name = 'Edit Properties';

		this.parent = parent;

		var assetPathHeader = new FlxUIText(10.0, 10.0, 'Asset path:');
		add(assetPathHeader);

		assetPathInput = new FlxUITextInput(assetPathHeader.x, assetPathHeader.y + assetPathHeader.height);
		assetPathInput.text = parent.data.assetPath;
		add(assetPathInput);

		antialiasingCheck = new FlxUICheckBox(assetPathInput.x, assetPathInput.y + assetPathInput.height + 10.0, null, null, 'Smoothing');
		antialiasingCheck.checked = parent.data.antialiasing;
		add(antialiasingCheck);

		var scaleHeader = new FlxUIText(antialiasingCheck.x, antialiasingCheck.y + antialiasingCheck.height + 10.0, 'Scale:');
		add(scaleHeader);

		scaleStepper = new FlxUINumericStepper(scaleHeader.x, scaleHeader.y + scaleHeader.height, 0.1, parent.data.scale, 0.1, 99.0, 1);
		add(scaleStepper);

		var healthIconHeader = new FlxUIText(scaleStepper.x, scaleStepper.y + scaleStepper.height + 10.0, 'Health icon:');
		add(healthIconHeader);

		healthIconInput = new FlxUITextInput(healthIconHeader.x, healthIconHeader.y + healthIconHeader.height, parent.data.health.icon);
		add(healthIconInput);

		var singDurationHeader = new FlxUIText(healthIconInput.x, healthIconInput.y + healthIconInput.height + 10.0, 'Sing animation duration:');
		add(singDurationHeader);

		singDurationStepper = new FlxUINumericStepper(singDurationHeader.x, singDurationHeader.y + singDurationHeader.height, 0.1, parent.data.singDuration, 0.1, 99.0, 1);
		add(singDurationStepper);
	}

	override function update(elapsed:Float) {
		if (parent.antialiasing != antialiasingCheck.checked) {
			parent.antialiasing = antialiasingCheck.checked;

			parent.data.antialiasing = antialiasingCheck.checked;
		}

		if (parent.data.scale != scaleStepper.value) {
			parent.scale.set(scaleStepper.value, scaleStepper.value);
			parent.updateHitbox();

			parent.data.scale = scaleStepper.value;
		}

		if (parent.data.health.icon != healthIconInput.text) {
			parent.data.health.icon = healthIconInput.text;
		}

		if (parent.data.singDuration != singDurationStepper.value) {
			parent.data.singDuration = singDurationStepper.value;
		}

		super.update(elapsed);
	}
}