import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import play.PlayState;
import flixel.FlxG;
import flixel.FlxState;

class InitState extends FlxState {
	override function create() {
		var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		// NOTE: tileData is ignored if TransitionData.type is FADE instead of TILES.
		var tileData = {asset: diamond, width: 32, height: 32};

		var region = FlxRect.get(-200.0, -200.0, FlxG.width * 1.4, FlxG.height * 1.4);

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1.0, FlxPoint.get(0.0, -1.0), tileData, region);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, FlxPoint.get(0.0, 1.0), tileData, region);
		// Don't play transition in when entering the title state.
		FlxTransitionableState.skipNextTransIn = true;

		FlxG.switchState(() -> Type.createInstance(Main.instance.initialState, []));
	}
}