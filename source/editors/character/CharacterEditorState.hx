package editors.character;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUITabMenu;
import data.CharacterData;
import play.PlayState;
import flixel.FlxObject;
import play.Character;
import flixel.FlxG;

class CharacterEditorState extends EditorState {
	var cameraFollowPoint = new FlxObject(FlxG.width * 0.5, FlxG.height * 0.5);

	var animationTest = false;

	var animationTestIndicator:FlxUIText;

	var character:Character;
	var characterData:CharacterData;

	var animationDebug:FlxUITabMenu;
	var editProperties:FlxUITabMenu;

	public function new() {
		super([
			{label: 'File', context: [
				{label: 'New', callback: () -> FlxG.resetState()},
				{label: 'Save', callback: () -> {}},
				{label: 'Save as', callback: () -> {}},
				{label: 'Open', callback: () -> {}},
				{label: 'Export', callback: () -> {}},
				{label: 'Import', callback: () -> {}},
				{label: 'Exit', callback: () -> FlxG.switchState(() -> new PlayState())}
			]},
			{label: 'Edit', context: [
				{label: 'Toggle animation test', callback: () -> {
					animationTest = !animationTest;
					animationTestIndicator.text = 'Animation test: ${animationTest ? 'Enabled' : 'Disabled'}';
				}}
			]},
			{label: 'View', context: [
				{label: 'Animation', callback: () -> {
					if (!members.contains(animationDebug)) add(animationDebug);
					else remove(animationDebug);
				}},
				{label: 'Properties', callback: () -> {}}
			]},
			{label: 'Help', context: [
				{label: 'Bindings', callback: () -> {}}
			]}
		]);
	}

	override function create() {
		super.create();

		cameraView.follow(cameraFollowPoint);

		character = new Character('bf', true);
		characterData = character.data;
		add(character);

		animationDebug = new FlxUITabMenu([
			{name: 'Animation', label: 'Animation'}
		]);
		animationDebug.resize(FlxG.width * 0.8, (FlxG.height - header.height) * 0.3);
		animationDebug.setPosition(0.0, FlxG.height - animationDebug.height);
		animationDebug.cameras = [cameraEditor];
		add(animationDebug);

		animationDebug.addGroup(new AnimationDebug(character));

		editProperties = new FlxUITabMenu([
			{name: 'Properties', label: 'Properties'}
		]);
		editProperties.resize(FlxG.width * 0.2, FlxG.height - header.height);
		editProperties.setPosition(FlxG.width - editProperties.width, header.height);
		editProperties.cameras = [cameraEditor];
		add(editProperties);

		editProperties.addGroup(new EditProperties(character));

		animationTestIndicator = new FlxUIText(10.0, animationDebug.y - 10.0 - 16.0, FlxG.width, 'Animation test: ${animationTest ? 'Enabled' : 'Disabled'}', 16);
		animationTestIndicator.setBorderStyle(OUTLINE, 0xFF000000, 2.0, 2.0);
		animationTestIndicator.cameras = [cameraEditor];
		add(animationTestIndicator);

		memberAdded.add((member) -> {
			if (member == animationDebug) animationTestIndicator.y = animationDebug.y - 10.0 - 16.0;
		});
		memberRemoved.add((member) -> {
			if (member == animationDebug) animationTestIndicator.y = FlxG.height - 10.0 - 16.0;
		});
	}

	override function update(elapsed:Float) {
		if (animationTest) {
			if (FlxG.keys.justPressed.LEFT)  character.playAnimation(Character.SING_ANIMATIONS[0], true);
			if (FlxG.keys.justPressed.DOWN)  character.playAnimation(Character.SING_ANIMATIONS[1], true);
			if (FlxG.keys.justPressed.UP)    character.playAnimation(Character.SING_ANIMATIONS[2], true);
			if (FlxG.keys.justPressed.RIGHT) character.playAnimation(Character.SING_ANIMATIONS[3], true);

			if (FlxG.keys.justPressed.SPACE) character.dance();
		}

		if (FlxG.mouse.wheel != 0) {
			if (FlxG.keys.pressed.CONTROL)    cameraView.zoom *= 1.0 + FlxG.mouse.wheel * 0.1;
			else if (FlxG.keys.pressed.SHIFT) cameraFollowPoint.x -= FlxG.mouse.wheel * 50.0 / cameraView.zoom;
			else                              cameraFollowPoint.y -= FlxG.mouse.wheel * 50.0 / cameraView.zoom;
		}

		if (FlxG.mouse.pressedRight) {
			cameraFollowPoint.x -= FlxG.mouse.deltaScreenX;
			cameraFollowPoint.y -= FlxG.mouse.deltaScreenY;
		}

		if (FlxG.keys.justPressed.ESCAPE) FlxG.switchState(() -> new PlayState());

		super.update(elapsed);
	}
}