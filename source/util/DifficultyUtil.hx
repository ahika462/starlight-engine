package util;

import haxe.ds.ReadOnlyArray;

class DifficultyUtil {
	public static final defaultList:ReadOnlyArray<String> = [
		'easy',
		'normal',
		'hard'
	];

	public static final currentList = defaultList.copy();

	public static function getPostfix(difficultyId:Int):String {
		var difficultyName = currentList[difficultyId].toLowerCase();

		if (difficultyName == null) {
			trace('Difficulty with ID $difficultyId not found');
			return null;
		}

		if (difficultyName == 'normal') return '';
		else return StringUtil.formatToSongPath('-$difficultyName');
	}
}