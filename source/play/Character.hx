package play;

import base.OffsetSprite;
import system.Conductor;
import haxe.ds.ReadOnlyArray;
import save.Preferences;
import util.ArrayUtil;
import util.JsonUtil;
import system.Paths;
import data.CharacterData;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

using StringTools;

class Character extends OffsetSprite {
	public static final SING_ANIMATIONS:ReadOnlyArray<String> = [
		'singLEFT',
		'singDOWN',
		'singUP',
		'singRIGHT'
	];

	public var name(default, set):String;
	public var data(default, null):CharacterData;
	public final player:Bool;

	public var dancePostfix = '';
	public var danceType:DanceType = Idle;
	public var danceEvery = 2;

	public var singPostfix = '';

	public var singTimer = 0.0;

	public function new(x = 0.0, y = 0.0, name:String, player = false) {
		super(x, y);

		this.player = player;
		this.name = name;
	}

	function set_name(v) {
		if (name == v) return v;

		var dataSource = Paths.character(v);
		if (dataSource == null) {
			trace('Character "$v" not found. Loading default character...');
			return set_name('bf');
		}

		data = JsonUtil.fromString(dataSource);

		frames = Paths.getSparrowAtlas(data.assetPath);
		for (animationData in data.animations) {
			if (ArrayUtil.isEmpty(animationData.indices))
				animation.addByPrefix(animationData.name, animationData.prefix, animationData.frameRate, animationData.looped, animationData.flipX, animationData.flipY);
			else
				animation.addByIndices(animationData.name, animationData.prefix, animationData.indices, '', animationData.frameRate, animationData.looped, animationData.flipX, animationData.flipY);
		
			addOffset(animationData.name, animationData.offset[0], animationData.offset[1]);
		}

		antialiasing = data.antialiasing && Preferences.antialiasing;
		setGraphicSize(width * data.scale);

		flipX = data.flipX;
		if (player) flipX = !flipX;

		updateDance();
		dance();

		return name = v;
	}

	public function updateDance() {
		danceType = (animation.exists('danceLeft$dancePostfix') && animation.exists('danceRight$dancePostfix')) ? LeftRight : Idle;
		danceEvery = switch(danceType) {
			case Idle: 2;
			case LeftRight: 1;
		}
	}

	var danced = false;
	public function dance() {
		switch(danceType) {
			case Idle:
				playAnimation('idle$dancePostfix');

			case LeftRight:
				danced = !danced;

				playAnimation((danced ? 'danceRight' : 'danceLeft') + dancePostfix);
		}
	}

	public function applyOffset() {
		x += data.offsets.self[0];
		y += data.offsets.self[1];
	}

	override function update(elapsed:Float) {
		if (!player) {
			if (animation.name?.startsWith('sing') || animation.name?.startsWith('hey')) singTimer += elapsed;

			if (singTimer >= Conductor.stepLengthMs * 0.0011 * data.singDuration) {
				dance();
				singTimer = 0.0;
			}
		}

		if (animation.finished) {
			var loopAnimation = '${animation.name}-loop';
			if (animation.exists(loopAnimation)) playAnimation(loopAnimation);
		}

		super.update(elapsed);
	}
}

enum DanceType {
	Idle;
	LeftRight;
}