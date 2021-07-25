import 'dart:convert';
import 'dart:io';

import 'package:notes_flutter_app/models/note.dart';
import 'package:notes_flutter_app/view_models/base_viewmodel.dart';
import 'package:notes_flutter_app/view_models/notes/note_viewmodel.dart';
import 'package:path_provider/path_provider.dart';

enum NotesView {
  List,
  Block,
}

class NotesViewModel extends BaseViewModel {
  NotesViewModel() {
    _sortNotesByDate();
    readNotesJson();
  }

  // List<NoteViewModel> _notes = [
  //   NoteViewModel(
  //     note: Note(
  //         title: 'Notes Application',
  //         text: 'Made by Vladyslav Monastyrskyi',
  //         createdAt: DateTime.parse('2021-06-27 20:00')),
  //   ),
  //   NoteViewModel(
  //     note: Note(
  //         title: 'Features',
  //         text: '+ Нелинейные анимации;\n'
  //             '+ Возможность переключить тему;\n'
  //             '+ Заметки в виде блоков и списка;\n'
  //             '+ Редактирование и сохранение изменний;\n'
  //             '+ Функционал создания новой заметки;\n'
  //             '- Нет сохранения при выходе.',
  //         createdAt: DateTime.parse('2021-06-25 19:00'),
  //         showDate: false),
  //   ),
  //   NoteViewModel(
  //     note: Note(
  //         title: 'Repository',
  //         text: 'https://github.com/monastyrskyi?tab=repositories',
  //         createdAt: DateTime.parse('2021-06-23 18:00')),
  //   ),
  // ];

  List<NoteViewModel> _notes = [];

  NotesView _notesView = NotesView.Block;

  List<NoteViewModel> get notes => _notes;

  NotesView get notesView => _notesView;

  void addNote(Note note) {
    _notes.add(NoteViewModel(note: note));
    _sortNotesByDate();
    writeData(_localNotesFile, _notes);
    notifyListeners();
  }

  void deleteNote(NoteViewModel noteViewModel) {
    if (_notes.contains(noteViewModel)) {
      _notes.remove(noteViewModel);
      writeData(_localNotesFile, _notes);
      notifyListeners();
    }
  }

  void undoNoteDeletion(NoteViewModel noteViewModel) {
    _notes.add(noteViewModel);
    _sortNotesByDate();
    writeData(_localNotesFile, _notes);
    notifyListeners();
  }

  void changeNotesView() {
    _notesView =
        _notesView == NotesView.Block ? NotesView.List : NotesView.Block;
    notifyListeners();
  }

  void _sortNotesByDate() {
    _notes.sort((a, b) {
      return b.createdAt.millisecondsSinceEpoch
          .compareTo(a.createdAt.millisecondsSinceEpoch);
    });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localNotesFile async {
    final path = await _localPath;
    return File('$path/notes.json').create();
  }

  Future<File> writeData(Future<File> localFile, List encodeString) async {
    final file = await localFile;
    var result = [
      for (var v in _notes)
        {
          "title".toString(): v.title.toString(),
          "text".toString(): v.text.toString(),
          "createdAt".toString(): v.createdAt.toString(),
          "showDate".toString(): v.showDate.toString(),
        }
    ];
    var jsonTags = JsonEncoder().convert(result);
    return file.writeAsString(jsonTags);
  }

  Future<List<NoteViewModel>> readNotesJson() async {
    final file = await _localNotesFile;
    final contents = await file.readAsString();
    if (contents.isNotEmpty) {
      Iterable data = await json.decode(contents);
      List<NoteViewModel> notes =
          data.map((model) => NoteViewModel.fromObject(model)).toList();
      return _notes = notes;
    }

    return _notes;
  }
}
