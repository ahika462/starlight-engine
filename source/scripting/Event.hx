package scripting;

import play.PlayState;

class Event {
	public var stopped(default, null) = false;
	public var game:PlayState;

	public function new() {}

	public function stop() {
		stopped = true;
	}

	public function resume() {
		stopped = false;
	}
}