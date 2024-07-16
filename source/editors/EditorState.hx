package editors;

import flixel.FlxCamera;
import editors.ContextMenu.ContextMenuItem;
import flixel.addons.ui.FlxUIGroup;
import flixel.FlxG;
import flixel.addons.ui.FlxUISprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIList;
import base.MusicBeatState;

typedef HeaderItem = {
	var label:String;
	var context:Array<ContextMenuItem>;
}

class EditorState extends MusicBeatState {
	var headerItems:Array<HeaderItem>;

	var header:FlxUIGroup;
	var headerBackground:FlxUISprite;
	var headerList:FlxUIList;

	var contextMenu:ContextMenu;

	var cameraView:FlxCamera;
	var cameraEditor:FlxCamera;

	public function new(headerItems:Array<HeaderItem>) {
		super();
		this.headerItems = headerItems;
	}

	override function create() {
		cameraView = new FlxCamera();
		FlxG.cameras.reset(cameraView);

		cameraEditor = new FlxCamera();
		cameraEditor.bgColor = 0x00000000;
		FlxG.cameras.add(cameraEditor, false);

		var buttons = [for (headerItem in headerItems) new FlxUIButton(0.0, 0.0, headerItem.label)];
		for (i in 0...buttons.length) {
			buttons[i].onUp.callback = () -> showContextMenu(buttons[i], headerItems[i].context);
			buttons[i].resize(40, 20);
		}

		header = new FlxUIGroup();
		header.cameras = [cameraEditor];
		add(header);

		headerBackground = new FlxUISprite(FlxG.bitmap.create(FlxG.width, 20, 0xFF707070));
		header.add(headerBackground);
		headerList = new FlxUIList(0.0, 0.0, cast buttons, FlxG.width, 20.0, FlxUIList.STACK_HORIZONTAL);
		header.add(headerList);
		
		super.create();
	}

	function showContextMenu(parent:FlxUIButton, items:Array<ContextMenuItem>) {
		if (contextMenu != null) {
			remove(contextMenu);
			contextMenu.destroy();
		}

		contextMenu = new ContextMenu(parent.x, parent.y + parent.height, items);
		contextMenu.cameras = [cameraEditor];
		add(contextMenu);
	}
}