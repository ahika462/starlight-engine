import play.Character;
import play.notes.Note;
import scripting.Script;

class AdditionalNoteStyles extends Script {
	override function hitNote(note:Note) {
		switch(note.kindName) {
			case 'Hey!':
				var singCharacter = note.player ? game.player : game.opponent;
				singCharacter.playAnimation('hey', true);

			case 'Alt Animation':
				var singCharacter = note.player ? game.player : game.opponent;
				singCharacter.playAnimation(Character.SING_ANIMATIONS[note.data % 4] + singCharacter.singPostfix + '-alt', true);
		}
	}
}