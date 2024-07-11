import 'package:flutter/material.dart';
import 'package:untitled1/model/notes_model.dart';
import 'package:untitled1/screens/add_note.dart';
import 'package:untitled1/screens/custom_dialog.dart';
import 'package:untitled1/screens/edit_screen.dart';

import 'database_helper/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DBHelper? dbHelper;
  late Future<List<NotesModel>>? notesList;

  @override
  void initState() {
    dbHelper = DBHelper();
    loadList();
    super.initState();
  }

  loadList() async {
    setState(() {
      notesList = dbHelper!.getNotesList();
    });
  }

  void deleteNote(int id) async {
    await dbHelper!.deleteNote(id);
    loadList(); // Reload the list after deleting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted')),
    );
  }

  void updateNote(NotesModel note) async {
    final updatedNote = await Navigator.push<NotesModel>(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note: note),
      ),
    );

    if (updatedNote != null) {
      await dbHelper!.updateNote(updatedNote);
      loadList(); // Reload the list after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sqflite tutorial'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Expanded(
              child: FutureBuilder<List<NotesModel>>(
                future: notesList,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No notes available'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        NotesModel note = snapshot.data![index];
                        return Card(
                          child: ListTile(
                              onTap: () => updateNote(note),
                              onLongPress: () {},
                              leading: Text(note.age.toString()),
                              title: Text(note.title),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(note.description),
                                  Text(note.email),
                                ],
                              ),
                              trailing: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ShowCustomDialog(
                                        title: 'Delete Note',
                                        content:
                                            'Are you sure you want to delete this note?',
                                        onConfirm: () {
                                          deleteNote(note.id!);
                                        },
                                      );
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              )),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          if (result == true) {
            loadList();
          }
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
