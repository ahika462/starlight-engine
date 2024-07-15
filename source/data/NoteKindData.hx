package data;

typedef NoteKindData = {
	var ?assetPath:String;
	var ?scale:Float;
	var ?antialiasing:Bool;
	/** Splashes atlas path **/
	var ?splashes:String;
	/** Sustain covers atlas prefix **/
	var ?coverPrefix:String;

	/** Health gain on hit **/
	var ?healthGain:Float;
	/** Health loss on miss **/
	var ?healthLoss:Float;

	var ?hitCausesMiss:Bool;
	var ?noSingAnimation:Bool;
	var ?noMissAnimation:Bool;
}