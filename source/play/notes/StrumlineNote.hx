package play.notes;

import flixel.FlxG;
import data.NoteStyleData;
import util.JsonUtil;
import save.Preferences;
import system.Paths;
import flixel.FlxSprite;

class StrumlineNote extends FlxSprite {
	public static inline var STRUM_WIDTH = 160 * 0.7;

	public final data:Int;
	public final player:Bool;

	public var style(default, null):NoteStyleData;

	public var resetTimer = 0.0;
	
	public function new(data:Int, player:Bool, style = 'default') {
		super();

		this.data = data;
		this.player = player;

		setStyle(style);
	}

	public function setStyle(name:String) {
		var styleSource = Paths.noteStyle(name);
		if (styleSource == null) {
			trace('Note style "$name" not found. Loading default style...');
			setStyle('default');
			return;
		}

		style = JsonUtil.fromString(styleSource);

		var lastAnimation = animation.name;
		var lastFrame = animation.curAnim?.curFrame;

		frames = Paths.getSparrowAtlas(style.assetPath);
		animation.addByPrefix('green',  'arrowUP');
		animation.addByPrefix('blue',   'arrowDOWN');
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('red',    'arrowRIGHT');

		antialiasing = style.antialiasing && Preferences.antialiasing;
		setGraphicSize(width * style.scale);

		switch(data) {
			case 0:
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
		
			case 1:
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);

			case 2:
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);

			case 3:
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
		}
		updateHitbox();

		if (lastAnimation != null && lastFrame != null) playAnimation(lastAnimation, true, lastFrame);
	}

	public function postAddedToGroup() {
		playAnimation('static');
		x += STRUM_WIDTH * data;
		x += FlxG.width * 0.5 * (player ? 1 : 0);
	}

	override function update(elapsed:Float) {
		if (resetTimer > 0.0) {
			resetTimer -= elapsed;
			if (resetTimer <= 0.0) {
				playAnimation('static');
				resetTimer = 0.0;
			}
		}

		if (animation.name == 'confirm') centerOrigin();
		
		super.update(elapsed);
	}

	public function playAnimation(name:String, force = false, reversed = false, frame = 0) {
		animation.play(name, force, reversed, frame);
		centerOffsets();
		centerOrigin();
	}
}