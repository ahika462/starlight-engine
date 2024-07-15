package data;

typedef EventData = {
	var description:String;
	var values:Array<EventValue>;
}

typedef EventValue = {
	var name:String;
	var id:String;
	var ?options:Array<String>;
}