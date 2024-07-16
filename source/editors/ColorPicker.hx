package editors;

import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.addons.display.shapes.FlxShapeCircle;
import system.Paths;
import flixel.FlxG;
import flixel.util.FlxGradient;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIGroup;

class ColorPicker extends FlxUIGroup {
	var colorGradient:FlxUISprite;
	var colorGradientSelector:FlxUISprite;
	var colorPalette:FlxUISprite;
	var colorWheel:FlxUISprite;
	var colorWheelSelector:FlxShapeCircle;

	public var value(default, null):FlxColor;

	public function new(x = 0.0, y = 0.0, color = 0xFFFFFFFF) {
		super();
		value = color;

		colorGradient = new FlxUISprite(FlxGradient.createGradientBitmapData(60, 360, [0xFFFFFFFF, 0xFF000000]));
		add(colorGradient);

		colorGradientSelector = new FlxUISprite(-10.0, 0.0, FlxG.bitmap.create(80, 10, 0xFFFFFFFF));
		colorGradientSelector.offset.y = 5.0;
		add(colorGradientSelector);

		colorPalette = new FlxUISprite(40.0, 380.0, Paths.image('editors/palette'));
		colorPalette.setGraphicSize(colorPalette.width * 20.0);
		colorPalette.updateHitbox();
		add(colorPalette);

		colorWheel = new FlxUISprite(80.0, 0.0, Paths.image('editors/colorWheel'));
		colorWheel.setGraphicSize(360, 360);
		colorWheel.updateHitbox();
		add(colorWheel);

		colorWheelSelector = new FlxShapeCircle(0.0, 0.0, 8.0, {thickness: 0.0}, 0xFFFFFFFF);
		colorWheelSelector.offset.set(8.0, 8.0);
		colorWheelSelector.alpha = 0.6;
		add(colorWheelSelector);

		updateSelectors();
	}

	var holdingObject:FlxSprite;
	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(colorGradient, camera))   holdingObject = colorGradient;
			else if (FlxG.mouse.overlaps(colorWheel, camera)) holdingObject = colorWheel;
			else if (FlxG.mouse.overlaps(colorPalette)) {
				var pixelPosition = {
					x: Math.floor((FlxG.mouse.screenX - colorPalette.x) / colorPalette.scale.x),
					y: Math.floor((FlxG.mouse.screenY - colorPalette.y) / colorPalette.scale.y)
				};
				value = colorPalette.pixels.getPixel32(pixelPosition.x, pixelPosition.y);
				updateSelectors();
			}
		}

		if (FlxG.mouse.justReleased) holdingObject = null;

		var oldValue = new FlxColor(value);

		if (FlxG.mouse.pressed && holdingObject != null) {
			if (holdingObject == colorGradient) {
				var newBrightness = 1.0 - FlxMath.bound((FlxG.mouse.screenY - colorGradient.y) / colorGradient.height, 0.0, 1.0);
				value.alpha = 1;
				if (value.brightness == 0) value = FlxColor.fromRGBFloat(newBrightness, newBrightness, newBrightness);
				else value = FlxColor.fromHSB(value.hue, value.saturation, newBrightness);
			} else if (holdingObject == colorWheel) {
				var center = colorWheel.getMidpoint();
				var mouse = FlxG.mouse.getScreenPosition();
				var hue:Float = FlxMath.wrap(FlxMath.wrap(Math.floor(mouse.degreesTo(center)), 0, 360) - 90, 0, 360);
				var sat = FlxMath.bound(mouse.dist(center) / colorWheel.width * 2.0, 0.0, 1.0);
				if (sat != 0) value = FlxColor.fromHSB(hue, sat, value.brightness);
				else value = FlxColor.fromRGBFloat(value.brightness, value.brightness, value.brightness);
			}
		}

		if (value != oldValue) updateSelectors();
	}

	public function updateSelectors() {
		colorGradientSelector.y = colorGradient.y + colorGradient.height * (1.0 - value.brightness);
		
		colorWheel.color = FlxColor.fromHSB(0.0, 0.0, value.brightness);
		var hueWrap = value.hue * FlxAngle.TO_RAD;
		colorWheelSelector.setPosition(colorWheel.x + colorWheel.width * 0.5, colorWheel.y + colorWheel.height * 0.5);
		colorWheelSelector.x += Math.sin(hueWrap) * colorWheel.width * 0.5 * value.saturation;
		colorWheelSelector.y -= Math.cos(hueWrap) * colorWheel.height * 0.5 * value.saturation;

		colorGradient.color = value;
	}
}