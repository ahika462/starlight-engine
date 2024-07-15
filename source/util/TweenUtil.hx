package util;

import flixel.tweens.FlxEase;

class TweenUtil {
	public static function resolveEasing(name:String):EaseFunction {
		return switch(name.toLowerCase()) {
			case 'quadin': FlxEase.quadIn;
			case 'quadout': FlxEase.quadOut;
			case 'quadinout' | 'quad': FlxEase.quadInOut;

			case 'cubein': FlxEase.cubeIn;
			case 'cubeout': FlxEase.cubeOut;
			case 'cubeinout' | 'cube': FlxEase.cubeInOut;
			
			case 'quartin': FlxEase.quartIn;
			case 'quartout': FlxEase.quartOut;
			case 'quartinout' | 'quart': FlxEase.quartInOut;
			
			case 'quintin': FlxEase.quintIn;
			case 'quintout': FlxEase.quintOut;
			case 'qiuntinout' | 'quint': FlxEase.quintInOut;

			case 'smoothstepin': FlxEase.smoothStepIn;
			case 'smoothstepout': FlxEase.smoothStepOut;
			case 'smoothstepinout' | 'smooothstep': FlxEase.smoothStepInOut;

			case 'smootherstepin': FlxEase.smootherStepIn;
			case 'smootherstepout': FlxEase.smoothStepOut;
			case 'smootherstepinout' | 'smootherstep': FlxEase.smoothStepInOut;
			
			case 'sinein': FlxEase.sineIn;
			case 'sineout': FlxEase.sineOut;
			case 'sineinout' | 'sine': FlxEase.sineInOut;

			case 'bouncein': FlxEase.bounceIn;
			case 'bounceout': FlxEase.bounceOut;
			case 'bounceinout' | 'bounce': FlxEase.bounceInOut;

			case 'circin': FlxEase.circIn;
			case 'circout': FlxEase.circOut;
			case 'circinout' | 'circ': FlxEase.circInOut;

			case 'expoin': FlxEase.expoIn;
			case 'expoout': FlxEase.expoOut;
			case 'expoinout' | 'expo': FlxEase.expoInOut;

			case 'backin': FlxEase.backIn;
			case 'backout': FlxEase.backOut;
			case 'backinout' | 'back': FlxEase.backInOut;

			case 'elasticin': FlxEase.elasticIn;
			case 'elasticout': FlxEase.elasticOut;
			case 'elasticinout' | 'elastic': FlxEase.elasticInOut;

			default: FlxEase.linear;
		}
	}
}