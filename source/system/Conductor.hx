package system;

import data.SongData.SongMetadata;
import flixel.FlxG;
import flixel.util.FlxSignal;

typedef BpmChange = {
	var bpm:Float;
	/** Song time **/
	var t:Float;
	/** Step time **/
	var s:Float;
}

class Conductor {
	public static final stepHit    = new FlxSignal();
	public static final beatHit    = new FlxSignal();
	public static final measureHit = new FlxSignal();

	/** Floored song step **/
	public static var currentStep(default, null)    = 0;
	/** Floored song beat **/
	public static var currentBeat(default, null)    = 0;
	/** Floored song measure **/
	public static var currentMeasure(default, null) = 0;

	/** Current song step **/
	public static var currentStepTime(default, null)    = 0.0;
	/** Current song beat **/
	public static var currentBeatTime(default, null)    = 0.0;
	/** Current song measure **/
	public static var currentMeasureTime(default, null) = 0.0;

	public static var currentTime(default, null) = 0.0;

	public static var overrideBpm:Null<Float> = null;
	public static var startingBpm(get, never):Null<Float>;
	public static var currentBpm(get, never):Null<Float>;

	/** Time interval between beats in milliseconds **/
	public static var beatLengthMs(get, never):Float;
	/** Time interval between steps in milliseconds **/
	public static var stepLengthMs(get, never):Float;

	public static inline var noteSafeZoneMs = 10 / 60 * 1000;

	public static inline var beatsPerMeasure = 4.0;
	public static inline var stepsPerBeat    = 4.0;

	static var bpmChanges:Array<BpmChange> = [];

	public static var startingBpmChange(get, never):BpmChange;
	public static var currentBpmChange(get, never):BpmChange;

	static function get_startingBpm() {
		return overrideBpm ?? startingBpmChange?.bpm;
	}

	static function get_currentBpm() {
		return overrideBpm ?? currentBpmChange?.bpm;
	}

	static function get_beatLengthMs() {
		return 60 / currentBpm * 1000;
	}

	static function get_stepLengthMs() {
		return beatLengthMs / stepsPerBeat;
	}

	static function get_startingBpmChange() {
		return bpmChanges[0];
	}

	static function get_currentBpmChange() {
		var i = bpmChanges.length - 1;

		while (i >= 0) {
			if (bpmChanges[i].t <= currentTime) return bpmChanges[i];
			i--;
		}

		return startingBpmChange;
	}

	public static function setup(metadata:SongMetadata) {
		currentTime = 0.0;

		bpmChanges = [
			{
				bpm: metadata.bpm,
				t: 0.0,
				s: 0.0
			}
		];
		
		var bpm = metadata.bpm;
		var t = 0.0;
		var s = 0.0;

		for (event in metadata.events) {
			if (event.k != 'Change BPM') continue;
			if (event.v.bpm == null || !Math.isNaN(event.v.bpm)) continue;

			var steps = (event.t - t) / (60 / bpm * 1000 / stepsPerBeat);
			s += steps;
			t = event.t;
			bpm = event.v.bpm;

			bpmChanges.push({
				bpm: bpm,
				t: t,
				s: t
			});
		}
	}

	public static function update(?time:Float) {
		if (time == null) time = FlxG.sound.music?.time;
		if (time == null) {
			trace('Could not found any music');
			return;
		}

		currentTime = time;
		
		if (currentBpm == null) {
			trace('Any BPM not found');
			return;
		}

		currentStepTime = currentBpmChange.s + (currentTime - currentBpmChange.t) / stepLengthMs;
		currentBeatTime = currentStepTime / stepsPerBeat;
		currentMeasureTime = currentBeatTime / beatsPerMeasure;

		var oldStep = currentStep;
		var oldBeat = currentBeat;
		var oldMeasure = currentMeasure;

		currentStep = Math.floor(currentStepTime);
		currentBeat = Math.floor(currentBeatTime);
		currentMeasure = Math.floor(currentMeasureTime);

		if (currentStep != oldStep)
			for (i in oldStep...currentStep) stepHit.dispatch();

		if (currentBeat != oldBeat)
			for (i in oldBeat...currentBeat) beatHit.dispatch();

		if (currentMeasure != oldMeasure)
			for (i in oldMeasure...currentMeasure) measureHit.dispatch();
	}
}