package base;

import flixel.math.FlxPoint;
import flixel.FlxSprite;

class OffsetSprite extends FlxSprite {
	var animationOffsets:Map<String, FlxPoint> = [];

	public function addOffset(name:String, x = 0.0, y = 0.0) {
		animationOffsets[name] = FlxPoint.get(x, y);
	}

	public function playAnimation(name:String, force = false, reversed = false, frame = 0) {
		animation.play(name, force, reversed, frame);
		if (!animationOffsets.exists(name)) offset.set();
		else {
			offset.copyFrom(animationOffsets[name]);
			offset.scalePoint(scale);
		}
	}

	override function updateHitbox() {
		super.updateHitbox();

		if (!animationOffsets.exists(animation.name)) offset.set();
		else {
			offset.copyFrom(animationOffsets[animation.name]);
			offset.scalePoint(scale);
		}
	}
}