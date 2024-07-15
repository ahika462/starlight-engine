package data;

import data.AnimationData;

typedef StageData = {
	/** Assets library **/
	var library:String;
	var defaultZoom:Float;

	/** Stage objects **/
	var props:Array<StagePropData>;
}

typedef StagePropData = {
	/** Prop unique identifier **/
	var id:String;
	var type:StagePropType;
	var ?assetPath:String;
	var ?animations:Array<AnimationData>;
	/** Prop layer **/
	var zIndex:Int;
	var fields:Dynamic;
}

enum abstract StagePropType(String) from String to String {
	var Sprite;
	var AnimatedSprite;
	var CharacterSprite;
}