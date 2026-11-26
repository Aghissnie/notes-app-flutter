import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

class NotesRepository {
  static const String boxName = 'notes_box';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<List<Note>> getNotes() async {
    final box = await _getBox();
    final notes = box.values
        .map((item) => Note.fromMap(Map<dynamic, dynamic>.from(item)))
        .toList();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  Future<void> saveNote(Note note) async {
    final box = await _getBox();
    await box.put(note.id, note.toMap());
  }

  Future<void> deleteNote(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}
