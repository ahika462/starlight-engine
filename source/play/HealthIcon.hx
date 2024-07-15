package play;

import save.Preferences;
import system.Paths;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite {
	public var defaultScale = 1.0;
	public var bopEasing = FlxEase.sineOut;
	public var bopDuration = 0.3;
	var bopTween:FlxTween;

	public var character(default, set):String;
	public final player:Bool;

	public function new(character:String, player = false) {
		super();
		this.player = player;
		this.character = character;
	}

	function set_character(v) {
		if (character == v) return v;

		var bitmap = Paths.image('icons/$v');
		if (bitmap == null) {
			trace('Health icon "$v" not found. Loading default health icon...');
			return set_character('default');
		}
		loadGraphic(bitmap, true, Math.floor(bitmap.width * 0.5), bitmap.height);
		animation.add(v, [0, 1], 0, false, player);
		animation.play(v);
		updateHitbox();

		antialiasing = Preferences.antialiasing && !v.endsWith('-pixel');

		return character = v;
	}

	public function bop(intensity = 0.2) {
		if (bopTween != null) bopTween.cancel();
		scale.add(0.2, 0.2);
		bopTween = FlxTween.tween(scale, {x: defaultScale, y: defaultScale}, bopDuration, {
			ease: bopEasing,
			onComplete: (_) -> {
				bopTween.destroy();
				bopTween = null;
			}
		});
	}

	public function changeExpression(expression:HealthIconExpression) {
		if (animation.curAnim != null) {
			switch(expression) {
				case Idle:
					animation.curAnim.curFrame = 0;
				case Lose:
					animation.curAnim.curFrame = 1;
			}
		}
	}
}

enum HealthIconExpression {
	Idle;
	Lose;
}