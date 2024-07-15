package play;

import util.StructUtil;
import save.Preferences;
import system.Paths;
import data.StageData.StagePropData;
import data.StageData.StagePropType;
import flixel.FlxSprite;

class StageProp extends FlxSprite {
	public final id:String;
	public final type:StagePropType;

	public function new(propData:StagePropData) {
		super();

		switch(propData.type) {
			case Sprite:
				loadGraphic(Paths.image(propData.assetPath));
				active = false;

			case AnimatedSprite:
				frames = Paths.getSparrowAtlas(propData.assetPath);

			default:
		}

		id = propData.id;
		type = propData.type;

		if (propData.fields != null) StructUtil.merge(this, propData.fields);
		antialiasing = (propData.fields?.antialiasing ?? false) && Preferences.antialiasing;
		updateHitbox();
	}
}