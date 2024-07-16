package editors.character;

import flixel.addons.ui.interfaces.IFlxUIWidget;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIList;
import play.Character;
import flixel.addons.ui.FlxUI;

class AnimationDebug extends FlxUI {
	var character:Character;

	var animationList:FlxUIList;

	static inline var MAX_ANIMS = 4;

	public function new(character:Character) {
		super();
		name = 'Animation';

		this.character = character;

		refreshAnimations();
	}

	function refreshAnimations() {
		var oldAnimationList = animationList;
		if (oldAnimationList != null) oldAnimationList.destroy();

		var buttons = [for (name in character.animation.getNameList()) new FlxUIButton(0.0, 0.0, name, () -> character.playAnimation(name, true))];

		animationList = new FlxUIList((cast buttons : Array<IFlxUIWidget>), 0.0, MAX_ANIMS * 20.0);
		animationList.setPosition(10.0, 30.0);
		if (oldAnimationList == null) add(animationList);
		else insert(members.indexOf(oldAnimationList), animationList);
	}
}