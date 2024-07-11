import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/notes_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDataBase();
    return _db;
  }

  initDataBase() async {
    try {
      io.Directory documentDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentDirectory.path, 'notes.db');
      print('Database path: $path');
      var db = await openDatabase(
        path,
        onCreate: _onCreate,
        version: 1,
      );
      print('Database initialized successfully');
      return db;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing database: $e');
      }
      return null;
    }
  }

  _onCreate(Database db, int version) async {
    try {
      await db.execute(
        "CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, age INTEGER NOT NULL, description TEXT NOT NULL, email TEXT)",
      );
      print('Table created successfully');
    } catch (e) {
      print('Error creating table: $e');
    }
  }

  Future<NotesModel?> insert(NotesModel notesModel) async {
    var dbClient = await db;
    if (dbClient != null) {
      await dbClient.insert('notes', notesModel.toMap());
      return notesModel;
    }
    return null;
  }

  Future<List<NotesModel>> getNotesList() async {
    var dbClient = await db;
    final List<Map<String, Object?>> queryResult =
        await dbClient!.query('notes');
    return queryResult.map((e) => NotesModel.fromMap(e)).toList();
  }

  Future<int> deleteNote(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(NotesModel note) async {
    var dbClient = await db;
    return await dbClient!.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }
}
