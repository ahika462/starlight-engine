package data;

typedef CharacterData = {
	var assetPath:String;
	var scale:Float;
	var antialiasing:Bool;
	var animations:Array<AnimationData>;

	var health:{
		var icon:String;
		/** Health HEX color **/
		var color:String;
	};

	var offsets:{
		/** Character relative position **/
		var self:Array<Float>;
		/** Camera relative position **/
		var camera:Array<Float>;
	};

	/** Sing animation length in seconds **/
	var singDuration:Float;
	var flipX:Bool;
}