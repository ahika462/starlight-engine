package play;

import editors.character.CharacterEditorState;
import util.StructUtil;
import haxe.io.Path;
import scripting.Event;
import scripting.Script;
import flixel.ui.FlxBar;
import flixel.addons.transition.FlxTransitionableState;
import input.Controls.Control;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import play.notes.Note;
import flixel.util.FlxSort;
import flixel.tweens.FlxEase;
import util.TweenUtil;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import save.Preferences;
import flixel.util.FlxColor;
import base.WideBorderBar;
import data.StageData;
import flixel.group.FlxGroup;
import base.BoppingCamera;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import play.notes.StrumlineNote;
import system.Conductor;
import flixel.sound.FlxSound;
import util.JsonUtil;
import system.Paths;
import flixel.FlxG;
import data.SongData;
import base.MusicBeatState;

using StringTools;

@:structInit
class PlayStateParams {
	public var songName = 'test';
	public var difficulty = 1;
}

class PlayState extends MusicBeatState {
	public static var instance:PlayState;

	/** Playing params **/
	public var params:PlayStateParams;

	public var songMetadata:SongMetadata;
	public var songChart:SongChart;

	public var inst:FlxSound;
	public var vocals:Array<FlxSound> = [];

	public var events:Array<SongEvent>;

	public var cameraStage:BoppingCamera;
	public var cameraHud:BoppingCamera;

	public var cameraBopping = true;
	public var cameraBoppingIntensity = 1.0;
	public var cameraBoppingRate = 1;

	public var cameraFollowPoint = new FlxObject(FlxG.width * 0.5, FlxG.height * 0.5);
	var cameraFollowTween:FlxTween;

	/** Current stage data **/
	public var stage:StageData;

	/** All stage objects, includes charaters **/
	public var stageObjects:FlxGroup;
	public var characters:FlxTypedGroup<Character>;
	/** Girlfriend **/
	public var spectator:Character;
	/** Dad **/
	public var opponent:Character;
	/** Boyfriend **/
	public var player:Character;

	public var strumlineNotes:FlxTypedSpriteGroup<StrumlineNote>;
	public var notes:FlxTypedGroup<Note>;

	public var healthBar:FlxBar;
	public var healthIcons:FlxTypedSpriteGroup<HealthIcon>;

	/** Current player health. 0.0 ~ 2.0 **/
	public var health = 1.0;

	var scripts:Array<Script> = [];

	public function new(?params:PlayStateParams) {
		this.params = params ?? {};
		super();
	}

	override function create() {
		instance = this;

		persistentUpdate = true;

		cameraStage = new BoppingCamera();
		cameraStage.defaultZoom = 0.9;
		cameraStage.zoom = 0.9;
		FlxG.cameras.reset(cameraStage);

		cameraStage.follow(cameraFollowPoint);

		cameraHud = new BoppingCamera();
		cameraHud.bgColor = 0x00000000;
		FlxG.cameras.add(cameraHud, false);

		if (!loadSong()) {
			trace('Could not load song');
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(() -> new flixel.FlxState());
			return;
		}

		createStage();
		createHud();

		startSong();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP,   handleKeyUp);

		super.create();

		#if (FEATURE_MODDING && FEATURE_SCRIPTING)
		var scriptsDirectory = 'assets/scripts';

		if (sys.FileSystem.exists(scriptsDirectory)) {
			var pushedPaths:Array<String> = [];
			for (file in sys.FileSystem.readDirectory(scriptsDirectory)) {
				var path = Path.join([scriptsDirectory, file]);

				if (pushedPaths.contains(path)) continue;
				
				if (file.endsWith('.hx')) {
					scripts = scripts.concat(Script.fromFile(path));
					pushedPaths.push(path);
				}
			}
		}
		#end

		for (script in scripts) script.create();
	}

	override function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP,   handleKeyUp);
		
		for (script in scripts) script.destroy();

		super.destroy();
	}

	function loadSong():Bool {
		var songMetadataSource = Paths.metadata(params.songName);
		if (songMetadataSource == null) {
			trace('"${params.songName}"  metadata not found');
			return false;
		}

		var songChartSource = Paths.chart(params.songName);
		if (songChartSource == null) {
			trace('"${params.songName}" with difficulty ID ${params.difficulty} chart not found');
			return false;
		}

		songMetadata = JsonUtil.fromString(songMetadataSource);
		songChart = JsonUtil.fromString(songChartSource);

		events = songMetadata.events.copy();
		events.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.t, b.t));

		inst = FlxG.sound.load(Paths.inst(params.songName));
		@:privateAccess
		if (inst?._sound == null) {
			trace('"${params.songName}" instrumental not found');
			return false;
		}
		add(inst);

		if (songMetadata.vocals.enabled) {
			if (songMetadata.vocals.separated) {
				for (postfix in ['-Opponent', '-Player']) {
					var vocal = FlxG.sound.load(Paths.voices(params.songName, postfix));
					@:privateAccess
					if (vocal?._sound == null) {
						trace('"${params.songName}" voices with postfix "$postfix" not found');
						return false;
					}
					vocals.push(vocal);
					add(vocal);
				}
			} else {
				var vocal = FlxG.sound.load(Paths.voices(params.songName));
				@:privateAccess
				if (vocal?._sound == null) {
					trace('"${params.songName}" voices not found');
					return false;
				}
				vocals.push(vocal);
				add(vocal);
			}
		}

		Conductor.setup(songMetadata);

		return true;
	}

	function startSong() {
		inst.play();
		for (vocal in vocals) vocal.play();
	}

	function createStage() {
		var stageSource = Paths.stage(songMetadata.stage);
		if (stageSource == null) {
			trace('Stage "${songMetadata.stage}" not found. Loading default stage...');
			stageSource = Paths.stage('stage');
		}

		stage = JsonUtil.fromString(stageSource);

		stageObjects = new FlxGroup();
		add(stageObjects);

		characters = new FlxTypedGroup();

		for (propData in stage.props) {
			switch(propData.type) {
				case CharacterSprite:
					switch(propData.id) {
						case 'spectator':
							if (propData.fields?.character != null || songMetadata.characters.spectator != null) {
								spectator = new Character(propData.fields?.character ?? songMetadata.characters.spectator);
								if (propData.fields != null) StructUtil.merge(spectator, propData.fields);
								spectator.applyOffset();
								characters.add(spectator);
								stageObjects.insert(propData.zIndex, spectator);
							}

						case 'opponent':
							opponent = new Character(propData.fields?.character ?? songMetadata.characters.opponent);
							if (propData.fields != null) StructUtil.merge(opponent, propData.fields);
							opponent.applyOffset();
							characters.add(opponent);
							stageObjects.add(opponent);

						case 'player':
							player = new Character(propData.fields?.character ?? songMetadata.characters.player, true);
							if (propData.fields != null) StructUtil.merge(player, propData.fields);
							player.applyOffset();
							characters.add(player);
							stageObjects.add(player);
					}

				default:
					var prop = new StageProp(propData);
					stageObjects.insert(propData.zIndex, prop);
			}
		}
	}

	function createHud() {
		healthBar = new WideBorderBar(0, FlxG.height * 0.89, RIGHT_TO_LEFT, 601, 19, this, 'health', 0.0, 2.0, true);
		healthBar.screenCenter(X);
		healthBar.cameras = [cameraHud];
		healthBar.antialiasing = Preferences.antialiasing;
		add(healthBar);

		updateHealthBar();

		healthIcons = new FlxTypedSpriteGroup(healthBar.x + 4, healthBar.y + 4);
		healthIcons.cameras = [cameraHud];
		add(healthIcons);

		var playerHealthIcon = new HealthIcon(player.data.health.icon, true);
		playerHealthIcon.x = -playerHealthIcon.width * 0.1;
		healthIcons.add(playerHealthIcon);

		var opponentHealthIcon = new HealthIcon(opponent.data.health.icon);
		opponentHealthIcon.x = -opponentHealthIcon.width + opponentHealthIcon.width * 0.1;
		healthIcons.add(opponentHealthIcon);

		healthIcons.y = healthBar.getMidpoint().y - healthIcons.height * 0.5;

		strumlineNotes = new FlxTypedSpriteGroup(0, 50);
		strumlineNotes.cameras = [cameraHud];
		add(strumlineNotes);
		
		for (player in [false, true]) {
			for (data in 0...4) {
				var note = new StrumlineNote(data, player);
				strumlineNotes.add(note);
				note.postAddedToGroup();
			}
		}
		strumlineNotes.screenCenter(X);

		notes = new FlxTypedGroup();
		notes.cameras = [cameraHud];
		add(notes);

		for (noteData in songChart.notes) {
			var note = new Note({
				t: noteData.t,
				d: noteData.d,
				k: noteData.k,
				l: noteData.l,

				sustain: false
			});
			note.kill();
			notes.insert(0, note);

			var floorLength = Math.floor(noteData.l / Conductor.stepLengthMs);
			var previousNote:Note = notes.members[0];
			if (floorLength > 0) {
				for (i in 0...floorLength + 1) {
					var sustainNote = new Note({
						t: noteData.t + Conductor.stepLengthMs * i,
						d: noteData.d,
						k: noteData.k,
						l: noteData.l,

						sustain: true,
						previous: previousNote
					});
					sustainNote.kill();
					notes.insert(0, sustainNote);

					if (previousNote.sustain) {
						previousNote.scale.y *= Note.SUSTAIN_HEIGHT / previousNote.frameHeight;
						previousNote.scale.y *= (60 / 100 * 1000 / Conductor.stepsPerBeat) / Conductor.stepLengthMs; // kill me pls
						previousNote.scale.y *= songChart.scrollSpeed;
						previousNote.updateHitbox();
					}

					previousNote = sustainNote;
				}
			}
		}
	}

	override function update(elapsed:Float) {
		for (script in scripts) script.preUpdate(elapsed);

		healthIcons.x = healthBar.x + (healthBar.width - 8) - (healthBar.width - 8) * healthBar.percent * 0.01;

		notes.forEach((note) -> {
			if (Math.abs(Conductor.currentTime - note.strumTime) < 2000.0 && !note.hasBeenHit) note.revive();
		});

		notes.forEachAlive((note) -> {
			note.followStrumlineNote(strumlineNotes.members[note.data], songChart.scrollSpeed);
			note.clipToStrumlineNote(strumlineNotes.members[note.data]);
		
			if (note.canBeHit && !note.hasBeenHit && !note.player) hitNote(note);
			if (note.willMiss && note.player) missNote(note);

			if (note.sustain && note.clipRect?.height != null && note.clipRect?.height <= 0.0) note.kill();
		});

		if (FlxG.keys.pressed.ANY) {
			for (key in FlxKey.fromStringMap)
				if (FlxG.keys.checkStatus(key, PRESSED)) onKeyPressed(key);
		}

		if (player.singTimer > Conductor.stepLengthMs * 0.0011 * player.data.singDuration && player.animation.name?.startsWith('sing') && !player.animation.name?.endsWith('miss'))
			player.dance();

		if (FlxG.keys.justPressed.EIGHT) FlxG.switchState(() -> new CharacterEditorState());

		super.update(elapsed);

		updatePlayer();

		if (inst?.time != null) Conductor.update(inst?.time);

		if (events.length > 0 && events[0].t <= Conductor.currentTime) {
			triggerEvent(events[0]);
			events.shift();
		}

		for (script in scripts) script.postUpdate(elapsed);
	}

	override function stepHit() {
		for (script in scripts) script.stepHit();
	}

	override function beatHit() {
		if (Conductor.currentBeat % (Conductor.beatsPerMeasure / cameraBoppingRate) == 0 && cameraBopping && cameraStage.zoom < 1.35) {
			cameraStage.bop(0.015 * cameraBoppingIntensity);
			cameraHud.bop(0.03 * cameraBoppingIntensity);
		}

		characters.forEachAlive((character) -> {
			if (Conductor.currentBeat % character.danceEvery == 0)
				if (!character.animation.name?.startsWith('sing')) character.dance();
		});

		healthIcons.forEachAlive((healthIcon) -> {
			healthIcon.bop();
		});
		
		for (script in scripts) script.beatHit();
	}

	override function measureHit() {
		for (script in scripts) script.measureHit();
	}

	function updateHealthBar() {
		healthBar.createFilledBar(FlxColor.fromString(opponent.data.health.color), FlxColor.fromString(player.data.health.color), true, 0xFF000000);
	}

	public function triggerEvent(event:SongEvent) {
		switch(event.k) {
			case 'Move Camera To Character':
				var duration = event.v.duration != null ? Std.parseFloat(event.v.duration) : 1.5;
				var easing = event.v.easing != null ? TweenUtil.resolveEasing(event.v.easing) : FlxEase.expoOut;

				switch(event.v.target) {
					case 'Player':
						var midpoint = player.getMidpoint();
						if (cameraFollowTween != null) cameraFollowTween.cancel();
						cameraFollowTween = FlxTween.tween(cameraFollowPoint, {
							x: midpoint.x - 100 - player.data.offsets.camera[0],
							y: midpoint.y - 100 + player.data.offsets.camera[1]
						}, duration, {
							ease: easing
						});

					case 'Opponent':
						var midpoint = opponent.getMidpoint();
						if (cameraFollowTween != null) cameraFollowTween.cancel();
						cameraFollowTween = FlxTween.tween(cameraFollowPoint, {
							x: midpoint.x + 150 + opponent.data.offsets.camera[0],
							y: midpoint.y + 100 + opponent.data.offsets.camera[1]
						}, duration, {
							ease: easing
						});

					case 'Spectator':
						var midpoint = spectator.getMidpoint();
						if (cameraFollowTween != null) cameraFollowTween.cancel();
						cameraFollowTween = FlxTween.tween(cameraFollowPoint, {
							x: midpoint.x + spectator.data.offsets.camera[0],
							y: midpoint.y + spectator.data.offsets.camera[1]
						}, duration, {
							ease: easing
						});
				}
		}

		for (script in scripts) script.onEvent(event);
	}

	function onKeyJustPressed(key:FlxKey) {
		var pressedDatas:Array<Int> = [];
		var controlArray = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];
		for (i in 0...controlArray.length)
			if (controls.keyboardBinds[controlArray[i]].contains(key)) pressedDatas.push(i);

		var canMiss = false;

		var pressNotes:Array<Note> = [];
		var notesStopped = false;

		var sortedNotes:Array<Note> = [];
		notes.forEachAlive((note) -> {
			if (note.canBeHit && note.player && !note.willMiss && !note.hasBeenHit && !note.sustain) {
				if (pressedDatas.contains(note.data % 4)) sortedNotes.push(note);
				canMiss = true;
			}
		});
		sortedNotes.sort((a, b) -> FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime));

		if (sortedNotes.length > 0) {
			for (note in sortedNotes) {
				for (doubleNote in pressNotes) {
					if (Math.abs(doubleNote.strumTime - note.strumTime) < 1.0)
						doubleNote.kill();
					else
						notesStopped = true;
				}

				if (!notesStopped) {
					hitNote(note);
					pressNotes.push(note);
				}
			}
		}

		for (data in pressedDatas) {
			if (strumlineNotes.members[4 + data].animation.name != 'confirm') {
				strumlineNotes.members[4 + data].playAnimation('pressed', true);
				ghostTap(data);
			}
		}
	}

	function onKeyPressed(key:FlxKey) {
		var pressedDatas:Array<Int> = [];
		var controlArray = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];
		for (i in 0...controlArray.length)
			if (controls.keyboardBinds[controlArray[i]].contains(key)) pressedDatas.push(i);
	
		notes.forEachAlive((note) -> {
			if (pressedDatas.contains(note.data % 4) && note.sustain && note.canBeHit && note.player && !note.willMiss && !note.hasBeenHit)
				hitNote(note);
		});
	}

	function onKeyJustReleased(key:FlxKey) {
		var pressedDatas:Array<Int> = [];
		var controlArray = [Control.NOTE_LEFT, Control.NOTE_DOWN, Control.NOTE_UP, Control.NOTE_RIGHT];
		for (i in 0...controlArray.length)
			if (controls.keyboardBinds[controlArray[i]].contains(key)) pressedDatas.push(i);

		for (data in pressedDatas) strumlineNotes.members[4 + data].playAnimation('static');
	}

	function hitNote(note:Note) {
		var strumlineNote = strumlineNotes.members[note.data];
		strumlineNote.playAnimation('confirm', true);
		if (!note.player) strumlineNote.resetTimer = Conductor.stepLengthMs * 1.25 * 0.001;

		if (note.player && note.kind.hitCausesMiss) {
			missNote(note);
			return;
		}

		if (!note.kind.noSingAnimation) {
			var singCharacter = note.player ? player : opponent;
			var singAnimation = Character.SING_ANIMATIONS[note.data % 4] + singCharacter.singPostfix;
			singCharacter.singTimer = 0.0;

			if (!note.sustain || singCharacter.animation.name != singAnimation) singCharacter.playAnimation(singAnimation, true);
		}
		
		if (note.player) {
			health += note.kind.healthGain;
		}

		note.hasBeenHit = true;
		if (!note.sustain) note.kill();

		for (script in scripts) script.hitNote(note);
	}

	function missNote(note:Note) {
		if (!note.player) return;

		if (!note.kind.noMissAnimation) {
			if (!note.sustain || player.animation.name != Character.SING_ANIMATIONS[note.data % 4] + '-miss')
				player.playAnimation(Character.SING_ANIMATIONS[note.data % 4] + 'miss', true);
		}

		health -= note.kind.healthLoss;

		note.kill();

		for (script in scripts) script.missNote(note);
	}

	function ghostTap(data:Int) {
		if (Preferences.ghostTapping) return;

		var missAnimation = Character.SING_ANIMATIONS[data % 4] + player.singPostfix + '-miss';
		player.playAnimation(missAnimation, true);

		FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));
	
		for (script in scripts) script.ghostTap(data);
	}

	function handleKeyDown(e:KeyboardEvent) {
		var key:FlxKey = e.keyCode;
		if (FlxG.keys.checkStatus(key, JUST_PRESSED)) onKeyJustPressed(key);
	}

	function handleKeyUp(e:KeyboardEvent) {
		var key:FlxKey = e.keyCode;
		if (FlxG.keys.checkStatus(key, JUST_RELEASED)) onKeyJustReleased(key);
	}

	function updatePlayer() {
		if (player.animation.name?.startsWith('sing') || player.animation.name?.startsWith('hey')) player.singTimer += FlxG.elapsed;
		else player.singTimer = 0.0;

		if (player.animation.name?.endsWith('miss') && player.animation.finished) player.dance();
	}
}