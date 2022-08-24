class Note {
  String title;
  String notedata;
  Note({required this.title, required this.notedata});
  toJsonEncodable() {
    Map<String, dynamic> n = new Map();
    n['title'] = title;
    n['notedata'] = notedata;
    return n;
  }
}

class NotesList {
  List<Note> notes = [];
  toJsonEncodable() {
    return notes.map((note) {
      return note.toJsonEncodable();
    }).toList();
  }
}
