import sys.io.File;

function main() {
	var content = File.getContent('input.json');
	var input = haxe.Json.parse(content).song;

	var output_metadata = {
		name: input.song,
		artist: 'Unknown',
		charter: 'Unknown',

		bpm: input.bpm,

		vocals: {
			enabled: input.needsVoices,
			separated: false
		},

		characters: {
			player: input.player1,
			opponent: input.player2,
			spectator: input.gfVersion
		},
		stage: input.stage,

		events: ([] : Array<Dynamic>)
	}

	var bpm = input.bpm;
	var pos = 0.0;
	var player:Null<Bool> = true;

	for (i in 0...input.notes.length) {
		if (input.notes[i].changeBPM) {
			bpm = input.notes[i].bpm;
			output_metadata.events.push({
				t: pos,
				k: 'Change BPM',
				v: {
					bpm: bpm
				}
			});
		}
		if (player == null || input.notes[i].mustHitSection != player) {
			player = input.notes[i].mustHitSection;
			output_metadata.events.push({
				t: pos,
				k: 'Move Camera To Character',
				v: {
					target: player ? 'Player' : 'Opponent'
				}
			});
		}
		pos += (60 / bpm * 1000 * 0.25) * 16;
	}

	var output_chart = {
		scrollSpeed: input.speed,
		notes: []
	}

	for (i in 0...input.notes.length) {
		for (noteData in (input.notes[i].sectionNotes : Array<Dynamic>)) {
			if (input.notes[i].mustHitSection) {
				if (noteData[1] > 3)
					output_chart.notes.push({
						t: noteData[0],
						d: noteData[1] - 4,
						l: noteData[2],
						k: noteData[3] ?? ''
					});
				else
					output_chart.notes.push({
						t: noteData[0],
						d: noteData[1] + 4,
						l: noteData[2],
						k: noteData[3] ?? ''
					});
			} else
				output_chart.notes.push({
					t: noteData[0],
					d: noteData[1],
					l: noteData[2],
					k: noteData[3] ?? ''
				});
		}
	}

	File.saveContent('output-metadata.json', haxe.Json.stringify(output_metadata, '\t'));
	File.saveContent('output-chart.json', haxe.Json.stringify(output_chart, '\t'));

	Sys.println('Success!');

	while (true) {}
}