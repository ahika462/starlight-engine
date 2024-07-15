package base;

import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.util.FlxColor;
import system.Paths;
import flixel.ui.FlxBar;

class WideBorderBar extends FlxBar {
	override function createColoredEmptyBar(empty:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar {
		if (FlxG.renderTile) {
			var emptyKey = 'empty: ${barWidth}x$barHeight:${empty.toHexString()}';
			if (showBorder) emptyKey += ',border: ${border.toHexString()}';

			if (!FlxG.bitmap.checkCache(emptyKey)) {
				var emptyBar:BitmapData = null;

				if (showBorder) {
					emptyBar = new BitmapData(barWidth, barHeight, true, border);
					emptyBar.fillRect(new Rectangle(4, 4, barWidth - 8, barHeight - 8), empty);
				} else
					emptyBar = new BitmapData(barWidth, barHeight, true, empty);

				FlxG.bitmap.add(emptyBar, false, emptyKey);
			}

			frames = FlxG.bitmap.get(emptyKey).imageFrame;
		} else {
			if (showBorder) {
				_emptyBar = new BitmapData(barWidth, barHeight, true, border);
				_emptyBar.fillRect(new Rectangle(4, 4, barWidth - 8, barHeight - 8), empty);
			} else
				_emptyBar = new BitmapData(barWidth, barHeight, true, empty);

			_emptyBarRect.setTo(0, 0, barWidth, barHeight);
			updateEmptyBar();
		}

		return this;
	}

	override function createColoredFilledBar(fill:FlxColor, showBorder:Bool = false, border:FlxColor = FlxColor.WHITE):FlxBar {
		if (FlxG.renderTile) {
			var filledKey = 'filled: ${barWidth}x$barHeight:${fill.toHexString()}';
			if (showBorder) filledKey += ',border: ${border.toHexString()}';

			if (!FlxG.bitmap.checkCache(filledKey)) {
				var filledBar:BitmapData = null;

				if (showBorder) {
					filledBar = new BitmapData(barWidth, barHeight, true, border);
					filledBar.fillRect(new Rectangle(4, 4, barWidth - 8, barHeight - 8), fill);
				}
				else
					filledBar = new BitmapData(barWidth, barHeight, true, fill);

				FlxG.bitmap.add(filledBar, false, filledKey);
			}

			frontFrames = FlxG.bitmap.get(filledKey).imageFrame;
		} else {
			if (showBorder) {
				_filledBar = new BitmapData(barWidth, barHeight, true, border);
				_filledBar.fillRect(new Rectangle(4, 4, barWidth - 8, barHeight - 8), fill);
			}
			else
				_filledBar = new BitmapData(barWidth, barHeight, true, fill);

			_filledBarRect.setTo(0, 0, barWidth, barHeight);
			updateFilledBar();
		}
		return this;
	}
}