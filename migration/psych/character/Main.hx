import sys.io.File;

using StringTools;

function main() {
	var content = File.getContent('input.json');
	var input = haxe.Json.parse(content);

	var output = {
		assetPath: input.image,
		scale: input.scale,
		antialiasing: !input.no_antialiasing,
		animations: [],

		health: {
			icon: input.healthicon,
			color: '#A1A1A1'
		},

		offsets: {
			self: input.position,
			camera: input.camera_position
		},
		
		singDuration: input.sing_duration,
		flipX: input.flip_x
	};

	for (animation in (input.animations : Array<Dynamic>)) {
		output.animations.push({
			name: animation.anim,
			prefix: animation.name,
			indices: animation.indices,
			frameRate: animation.fps,
			looped: animation.loop,
			flipX: false,
			flipY: false,
			offset: animation.offsets
		});
	}

	trace('color convertion not implemented yet');
	File.saveContent('output.json', haxe.Json.stringify(output, '\t'));
}