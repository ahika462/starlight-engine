package data;

typedef SongMetadata = {
	var name:String;
	var artist:String;
	var charter:String;

	var bpm:Float;

	var vocals:{
		/** Use vocals files **/
		var enabled:Bool;
		/** Use separated vocals files instead of single file **/
		var separated:Bool;
	};

	var characters:{
		/** Boyfriend name **/
		var player:String;
		/** Dad name **/
		var opponent:String;
		/** Girlfriend name **/
		var ?spectator:String;
	}
	var stage:String;

	var events:Array<SongEvent>;
}

typedef SongChart = {
	var scrollSpeed:Float;
	var notes:Array<SongNote>;
}

typedef SongNote = {
	/** Strum time **/
	var t:Float;
	/** Strum ID **/
	var d:Int;
	/** Kind **/
	var k:String;
	/** Sustain trail length **/
	var l:Float;
}

typedef SongEvent = {
	/** Strum time **/
	var t:Float;
	/** Kind **/
	var k:String;
	/** Values **/
	var v:Dynamic;
}