import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:localstorage/localstorage.dart';

// ignore: library_prefixes
import 'package:flutter/services.dart' as rootBundle;

List<Note> notes = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NotesList notes = NotesList();
  final LocalStorage store = LocalStorage('notes_app');
  bool initialized = false;

  _addNotes(String title, String notedata) {
    setState(() {
      final item = Note(title: title, notedata: notedata);
      notes.notes.add(item);
      _saveToStorage();
    });
  }

  _saveToStorage() {
    store.setItem('notes', notes.toJsonEncodable());
  }

  Widget _buildPopupDialog(BuildContext context) {
    var title;
    var notes;
    return AlertDialog(
      title: const Text('Add Notes'),
      content: Form(
          child: Column(
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(labelText: 'Subject *'),
            onChanged: (value) {
              title = value;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Notes *'),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 5,
            onChanged: (value) {
              notes = value;
            },
          ),
        ],
      )),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            _addNotes(title, notes);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
            future: store.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: Text("No Notes Found"));
              }

              if (!initialized) {
                var notes = store.getItem('notes');

                if (notes != null) {
                  notes.items = List<Note>.from(
                    (notes as List).map(
                      (e) => Note(title: e['title'], notedata: e['notedata']),
                    ),
                  );
                }
                initialized = true;
              }

              List<Widget> widgets = notes.notes.map((item) {
                return Card(
                  elevation: 5,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: ListTile(
                        title: Text(item.title.toString()),
                        subtitle: Text(item.notedata.toString())),
                  ),
                );
              }).toList();

              return Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: widgets,
                    ),
                  )
                ],
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => _buildPopupDialog(context),
            );
          },
          child: const Icon(Icons.add),
        ));
  }
}
