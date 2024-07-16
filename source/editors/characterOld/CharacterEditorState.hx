package editors.character;

import play.PlayState;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import play.Character;
import base.MusicBeatState;

class CharacterEditorState extends MusicBeatState {
	var animationDebug:FlxUITabMenu;
	var editProperties:FlxUITabMenu;

	var character:Character;

	var cameraCharacter:FlxCamera;
	var cameraEditor:FlxCamera;

	var cameraFollowPoint = new FlxObject(FlxG.width * 0.5, FlxG.height * 0.5);

	override function create() {
		cameraCharacter = new FlxCamera();
		FlxG.cameras.reset(cameraCharacter);

		cameraCharacter.follow(cameraFollowPoint);

		cameraEditor = new FlxCamera();
		cameraEditor.bgColor = 0x00000000;
		FlxG.cameras.add(cameraEditor);

		FlxG.cameras.setDefaultDrawTarget(cameraCharacter, false);

		character = new Character('bf', true);
		character.cameras = [cameraCharacter];
		add(character);

		animationDebug = new FlxUITabMenu([
			{name: 'Animation Debug', label: 'Animation Debug'}
		]);
		animationDebug.resize(FlxG.width * 0.8, FlxG.height * 0.3);
		animationDebug.setPosition(0.0, FlxG.height - animationDebug.height);
		add(animationDebug);
		animationDebug.addGroup(new AnimationDebug(character));

		editProperties = new FlxUITabMenu([
			{name: 'Edit Properties', label: 'Edit Properties'}
		]);
		editProperties.resize(FlxG.width * 0.2, FlxG.height);
		editProperties.setPosition(FlxG.width * 0.8, 0.0);
		add(editProperties);
		editProperties.addGroup(new EditProperties(character));

		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.mouse.wheel != 0) {
			if (FlxG.keys.pressed.CONTROL) cameraCharacter.zoom *= 1.0 + FlxG.mouse.wheel * 0.1;
			else if (FlxG.keys.pressed.SHIFT) cameraFollowPoint.x -= FlxG.mouse.wheel * 50.0 / cameraCharacter.zoom;
			else cameraFollowPoint.y -= FlxG.mouse.wheel * 50.0 / cameraCharacter.zoom;
		}

		if (FlxG.mouse.pressedRight) {
			cameraFollowPoint.x -= FlxG.mouse.deltaScreenX;
			cameraFollowPoint.y -= FlxG.mouse.deltaScreenY;
		}

		if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(() -> new PlayState());

		super.update(elapsed);
	}
}