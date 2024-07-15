package data;

typedef NoteStyleData = {
	var assetPath:String;
	var scale:Float;
	var antialiasing:Bool;
	/** Splashes atlas path **/
	var splashes:String;
	/** Sustain covers atlas prefix **/
	var ?coverPrefix:String;
}