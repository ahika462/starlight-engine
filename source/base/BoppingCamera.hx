package base;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;

class BoppingCamera extends FlxCamera {
	public var defaultZoom = 1.0;
	public var bopEasing = FlxEase.sineOut;
	public var bopDuration = 1.0;
	var bopTween:FlxTween;

	public function bop(intensity = 0.015) {
		if (bopTween != null) bopTween.cancel();
		zoom += intensity;
		bopTween = FlxTween.tween(this, {zoom: defaultZoom}, bopDuration, {
			ease: bopEasing,
			onComplete: (_) -> {
				bopTween.destroy();
				bopTween = null;
			}
		});
	}
}