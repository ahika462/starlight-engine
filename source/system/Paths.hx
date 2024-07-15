package system;

import flixel.graphics.frames.FlxAtlasFrames;
import util.StringUtil;
import openfl.media.Sound;
import openfl.display.BitmapData;
import openfl.utils.AssetType;

class Paths {
	public static inline var SOUND_EXTENSION = #if web 'mp3' #else 'ogg' #end;

	public static var currentLibrary:String = null;

	public static function getPath(file:String, type:AssetType, ?library:String):String {
		if (library != null) return 'assets/$library/$file';

		if (currentLibrary != null) {
			var libraryPath = 'assets/$currentLibrary/$file';
			#if (FEATURE_MODDING)
			if (sys.FileSystem.exists(libraryPath)) return libraryPath;
			#else
			if (openfl.Assets.exists(libraryPath)) return libraryPath;
			#end
		}

		return 'assets/shared/$file';
	}

	public static function inst(key:String):Sound {
		var path = getPath('$key/Inst.$SOUND_EXTENSION', SOUND, 'songs');
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return Sound.fromFile(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getSound(path);
		#end
		
		return null;
	}

	public static function voices(key:String, postfix = ''):Sound {
		var path = getPath('$key/Voices$postfix.$SOUND_EXTENSION', SOUND, 'songs');
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return Sound.fromFile(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getSound(path);
		#end

		return null;
	}

	public static function metadata(key:String, ?library:String):String {
		var path = getPath('data/songs/${StringUtil.formatToSongPath(key)}/${StringUtil.formatToSongPath(key)}-metadata.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function chart(key:String, postfix = '', ?library:String):String {
		var path = getPath('data/songs/${StringUtil.formatToSongPath(key)}/${StringUtil.formatToSongPath(key)}-chart$postfix.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function image(key:String, ?library:String):BitmapData {
		var path = getPath('images/$key.png', IMAGE, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) {
			if (openfl.Assets.cache.hasBitmapData(path)) return openfl.Assets.cache.getBitmapData(path);
			var bitmapData = BitmapData.fromFile(path);
			openfl.Assets.cache.setBitmapData(path, bitmapData);
			return bitmapData;
		}
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getBitmapData(path);
		#end

		return null;
	}

	public static function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames {
		#if (FEATURE_MODDING)
		var xmlPath = getPath('images/$key.xml', TEXT, library);
		var xmlData = sys.FileSystem.exists(xmlPath) ? sys.io.File.getContent(xmlPath) : xmlPath;
		return FlxAtlasFrames.fromSparrow(image(key, library), xmlData);
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), getPath('images/$key.xml', TEXT, library));
		#end
	}

	public static function noteStyle(key:String, ?library:String):String {
		var path = getPath('data/noteStyles/$key.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function character(key:String, ?library:String):String {
		var path = getPath('data/characters/$key.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function stage(key:String, ?library:String):String {
		var path = getPath('data/stages/$key.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function noteKind(key:String, ?library:String):String {
		var path = getPath('data/noteKinds/$key.json', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}

	public static function sound(key:String, ?library:String):Sound {
		var path = getPath('sounds/$key.$SOUND_EXTENSION', SOUND, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) {
			if (openfl.Assets.cache.hasSound(path)) return openfl.Assets.cache.getSound(path);
			var sound = Sound.fromFile(path);
			openfl.Assets.cache.setSound(path, sound);
			return sound;
		}
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getSound(path);
		#end

		return null;
	}

	public static function xml(key:String, ?library:String):String {
		var path = getPath('data/$key.xml', TEXT, library);
		#if (FEATURE_MODDING)
		if (sys.FileSystem.exists(path)) return sys.io.File.getContent(path);
		#else
		if (openfl.Assets.exists(path)) return openfl.Assets.getText(path);
		#end

		return null;
	}
}