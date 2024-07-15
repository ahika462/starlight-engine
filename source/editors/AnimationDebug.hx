package editors;

import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxUISprite;
import flixel.group.FlxSpriteGroup;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import flixel.addons.ui.FlxUIList;
import base.OffsetSprite;
import flixel.addons.ui.FlxUI;

class AnimationDebug extends FlxUI {
	public static inline var MAX_ANIMATIONS = 4;
	var parent:OffsetSprite;

	var animationNames:FlxUIList;
	var animationFrames:FlxUIList;

	var playButton:FlxUIButton;
	var pauseButton:FlxUIButton;
	var stopButton:FlxUIButton;
	var restartButton:FlxUIButton;

	var animationIndicator:FlxUIText;
	var frameIndicator:FlxUISprite;

	public function new(parent:OffsetSprite) {
		super();
		name = 'Animation Debug';

		this.parent = parent;

		animationIndicator = new FlxUIText(10.0, 10.0, 100.0, 'Animation: ${parent.animation.name}', 11);
		animationIndicator.color = 0xFF333333;
		add(animationIndicator);

		animationNames = new FlxUIList(animationIndicator.x, animationIndicator.y + animationIndicator.height + 30.0, [
			for (anim in parent.animation.getNameList()) new FlxUIButton(0.0, 0.0, anim, () -> parent.playAnimation(anim, true))
		], 100.0, MAX_ANIMATIONS * 20.0);
		add(animationNames);

		playButton = new FlxUIButton(animationNames.x + animationNames.width + 40.0, 10.0, 'Play', () -> {
			if (!parent.animation.finished) parent.animation.resume();
			else parent.animation.curAnim.play(true);
		});
		add(playButton);

		pauseButton = new FlxUIButton(playButton.x + playButton.width + 5.0, playButton.y, 'Pause', () -> parent.animation.pause());
		add(pauseButton);

		stopButton = new FlxUIButton(pauseButton.x + pauseButton.width + 5.0, pauseButton.y, 'Stop', () -> {
			parent.animation.pause();
			parent.animation.curAnim.curFrame = 0;
		});
		add(stopButton);

		restartButton = new FlxUIButton(stopButton.x + stopButton.width + 5.0, stopButton.y, 'Restart', () -> parent.animation.curAnim.play(true));
		add(restartButton);

		var widgets = [for (i in 0...parent.animation.curAnim.numFrames) new FlxUIButton(0.0, 0.0, '$i', () -> parent.animation.curAnim.curFrame = i)];
		for (widget in widgets) widget.resize(20.0, 20.0);

		animationFrames = new FlxUIList(playButton.x, animationNames.y + 20.0, cast widgets, FlxG.width * 0.6, 20.0, FlxUIList.STACK_HORIZONTAL);
		add(animationFrames);

		frameIndicator = new FlxUISprite(animationFrames.x, animationFrames.y + 20.0);
		frameIndicator.loadGraphic(FlxUIAssets.IMG_TOOLTIP_ARROW, true, 15, 15);
		frameIndicator.animation.add('up', [3], 0, false);
		frameIndicator.animation.play('up');
		frameIndicator.offset.x -= 2.0;
		add(frameIndicator);
	}

	override function update(elapsed:Float) {
		animationIndicator.text = 'Animation: ${parent.animation.name}';

		var animationFramesLength = animationFrames.length;
		if (animationFrames.amountPrevious > 0) animationFramesLength--;
		if (animationFrames.amountNext > 0) animationFramesLength--;

		if (animationFramesLength != parent.animation.curAnim.numFrames) {
			var oldAnimationFrames = animationFrames;

			var widgets = [for (i in 0...parent.animation.curAnim.numFrames) new FlxUIButton(0.0, 0.0, '$i', () -> parent.animation.curAnim.curFrame = i)];
			for (widget in widgets) widget.resize(20.0, 20.0);

			animationFrames = new FlxUIList(oldAnimationFrames.x - x, oldAnimationFrames.y - y, cast widgets, FlxG.width * 0.6, 20.0, FlxUIList.STACK_HORIZONTAL);
			insert(members.indexOf(oldAnimationFrames), animationFrames);

			remove(oldAnimationFrames);
			oldAnimationFrames.destroy();
		}

		frameIndicator.x = animationFrames.members[parent.animation.curAnim.curFrame].x;

		if (FlxG.keys.justPressed.SPACE) {
			if (parent.animation.finished) parent.animation.curAnim.play(true);
			else if (parent.animation.paused) parent.animation.resume();
			else parent.animation.pause();
		}

		super.update(elapsed);
	}
}