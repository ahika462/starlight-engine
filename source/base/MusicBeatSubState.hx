package base;

import system.Conductor;
import input.Controls;
import flixel.FlxSubState;

class MusicBeatSubState extends FlxSubState {
	var controls = Controls.instance;

	override function create() {
		super.create();

		Conductor.stepHit.add(stepHit);
		Conductor.beatHit.add(beatHit);
		Conductor.measureHit.add(measureHit);
	}

	function stepHit() {}
	function beatHit() {}
	function measureHit() {}

	override function destroy() {
		Conductor.stepHit.remove(stepHit);
		Conductor.beatHit.remove(beatHit);
		Conductor.measureHit.remove(measureHit);
		
		super.destroy();
	}
}