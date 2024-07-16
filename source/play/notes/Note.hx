package play.notes;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import data.NoteKindData;
import save.Preferences;
import flixel.math.FlxMath;
import system.Conductor;
import haxe.ds.ReadOnlyArray;
import util.JsonUtil;
import system.Paths;
import data.NoteStyleData;
import flixel.FlxSprite;

using StringTools;

typedef NoteParams = {
	/** Strum time **/
	var t:Float;
	/** Note data **/
	var d:Int;
	/** Kind **/
	var k:String;
	/** Sustain trail length **/
	var l:Float;

	var sustain:Bool;
	var ?previous:Note;
}

class Note extends FlxSprite {
	public static final NOTE_COLORS:ReadOnlyArray<String> = ['purple', 'blue', 'green', 'red'];
	public static inline var SUSTAIN_HEIGHT:Int = 44;

	public final strumTime:Float;
	public final data:Int;
	public var player(get, never):Bool;
	public final sustain:Bool;
	public final length:Float;
	public var previous:Note;

	public var hasBeenHit = false;
	public var canBeHit(default, null) = false;
	public var willMiss(default, null) = false;
	var distance = 0.0;

	public var styleName(default, set):String;
	public var style(default, null):NoteStyleData;

	public var kindName(default, set):String;
	public var kind(default, null):NoteKindData;

	public var lateHitMultiplier = 1.0;
	public var earlyHitMultiplier = 1.0;

	public var relative = new FlxPoint();

	public function new(params:NoteParams, style = 'default') {
		super();

		strumTime = params.t;
		data = params.d;
		sustain = params.sustain;
		length = params.l;
		previous = params.previous ?? this;

		styleName = style;

		if (params.k.trim() == '') params.k = 'default';
		kindName = params.k;
	}

	function set_styleName(v) {
		var styleSource = Paths.noteStyle(v);
		if (styleSource == null) {
			trace('Note stytle "$v not found. Loading default style...');
			return set_styleName('default');
		}

		style = JsonUtil.fromString(styleSource);

		frames = Paths.getSparrowAtlas(kind?.assetPath ?? style.assetPath);
		animation.addByPrefix(NOTE_COLORS[data % 4] + 'Scroll', NOTE_COLORS[data % 4] + '0');

		if (sustain) {
			animation.addByPrefix('purpleholdend', 'pruple end hold');
			animation.addByPrefix(NOTE_COLORS[data % 4] + 'holdend', NOTE_COLORS[data % 4] + ' hold end');
			animation.addByPrefix(NOTE_COLORS[data % 4] + 'hold', NOTE_COLORS[data % 4] + ' hold piece');
		}

		antialiasing = style.antialiasing && (kind?.antialiasing ?? true) && Preferences.antialiasing;
		setGraphicSize(width * style.scale * (kind?.scale ?? 1.0));

		animation.play(NOTE_COLORS[data % 4] + 'Scroll');
		if (previous.sustain) previous.animation.play(NOTE_COLORS[previous.data % 4] + 'hold');
		if (sustain) animation.play(NOTE_COLORS[data % 4] + 'holdend');

		updateHitbox();

		if (sustain) {
			var lastAnimation = animation.name;
			animation.play(NOTE_COLORS[data % 4] + 'Scroll');
			relative.x += frameWidth * scale.x * 0.5;
			relative.y -= frameHeight * scale.y * 0.5 * (Preferences.downscroll ? 1 : -1);
			animation.play(lastAnimation);
			relative.x -= frameWidth * scale.x * 0.5;
		}

		return styleName = v;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (player) {
			var earlyBound = Conductor.currentTime - Conductor.noteSafeZoneMs * earlyHitMultiplier;
			var lateBound = Conductor.currentTime + Conductor.noteSafeZoneMs * lateHitMultiplier;
			canBeHit = FlxMath.inBounds(strumTime, earlyBound, lateBound);

			willMiss = (strumTime < Conductor.currentTime - Conductor.noteSafeZoneMs * lateHitMultiplier && !hasBeenHit);
		} else {
			if (strumTime < Conductor.currentTime + Conductor.noteSafeZoneMs * earlyHitMultiplier) {
				if ((sustain && previous.hasBeenHit) || strumTime <= Conductor.currentTime)
					canBeHit = true;
			}
		}

		if (willMiss) alpha = Math.min(alpha, 0.3);
	}

	public function followStrumlineNote(note:StrumlineNote, scrollSpeed:Float) {
		distance = 0.45 * (Conductor.currentTime - strumTime) * scrollSpeed;

		x = note.x + relative.x;
		y = note.y + relative.y + distance * (Preferences.downscroll ? 1 : -1);

		if (sustain) alpha = 0.6;
	}

	public function clipToStrumlineNote(note:StrumlineNote) {
		var center = note.y + StrumlineNote.STRUM_WIDTH * 0.5;
		if (sustain && (!player || (hasBeenHit || (previous.hasBeenHit && !canBeHit)))) {
			if (Preferences.downscroll) {
				if (y - offset.y * scale.y + height >= center) {
					var newClipRect = clipRect?.set(0, 0, frameWidth, frameHeight) ?? FlxRect.get(0, 0, frameWidth, frameHeight);
					newClipRect.height = (center - y) / scale.y;
					newClipRect.y = frameHeight - newClipRect.height;

					clipRect = newClipRect;
				}
			} else {
				if (y + offset.y * scale.y <= center) {
					var newClipRect = clipRect?.set(0, 0, frameWidth, frameHeight) ?? FlxRect.get(0, 0, frameWidth, frameHeight);
					newClipRect.y = (center - y) / scale.y;
					newClipRect.height -= newClipRect.y;

					clipRect = newClipRect;
				}
			}
		}
	}

	function get_player() {
		return data > 3;
	}

	function set_kindName(v) {
		if (v.trim() == '') v = 'default';
		if (kindName == v) return v;

		var kindSource = Paths.noteKind(v);
		if (kindSource == null) {
			trace('Note kind "$v" not found. Loading default kind...');
			return set_kindName('default');
		}

		kind = JsonUtil.fromString(kindSource);

		if (kind.assetPath != null && kind.assetPath != style.assetPath) {
			frames = Paths.getSparrowAtlas(kind.assetPath);
			animation.addByPrefix(NOTE_COLORS[data % 4] + 'Scroll', NOTE_COLORS[data % 4] + '0');

			if (sustain) {
				animation.addByPrefix('purpleholdend', 'pruple end hold');
				animation.addByPrefix(NOTE_COLORS[data % 4] + 'holdend', NOTE_COLORS[data % 4] + ' hold end');
				animation.addByPrefix(NOTE_COLORS[data % 4] + 'hold', NOTE_COLORS[data % 4] + ' hold piece');
			}

			antialiasing = style.antialiasing && kind.antialiasing && Preferences.antialiasing;
			setGraphicSize(frameWidth * style.scale * kind.scale);

			animation.play(NOTE_COLORS[data % 4] + 'Scroll');
			if (previous.sustain) previous.animation.play(NOTE_COLORS[previous.data % 4] + 'hold');
			if (sustain) animation.play(NOTE_COLORS[data % 4] + 'holdend');

			updateHitbox();

			if (sustain) {
				var lastAnimation = animation.name;
				animation.play(NOTE_COLORS[data % 4] + 'Scroll');
				relative.x += frameWidth * scale.x * 0.5;
				relative.y += frameHeight * scale.y * 0.5;
				animation.play(lastAnimation);
				relative.x -= frameWidth * scale.x * 0.5;
			}
		}

		return kindName = v;
	}
}