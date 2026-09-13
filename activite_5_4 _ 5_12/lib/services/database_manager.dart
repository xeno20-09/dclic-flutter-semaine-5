import 'package:sqflite/sqflite.dart';

import '../modele/redacteur.dart';

class DatabaseManager {
  Database? _database;

  Future<Database> get database async {
    if (_database == null) {
      await initialisation();
    }

    return _database!;
  }

  Future<void> initialisation() async {
    _database = await openDatabase(
      'redacteurs.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE redacteurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL,
            prenom TEXT NOT NULL,
            email TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertRedacteur(Redacteur redacteur) async {
    final db = await database;

    await db.insert(
      'redacteurs',
      redacteur.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;

    final maps = await db.query('redacteurs');

    return maps.map((map) {
      return Redacteur(
        id: map['id'] as int,
        nom: map['nom'] as String,
        prenom: map['prenom'] as String,
        email: map['email'] as String,
      );
    }).toList();
  }

  Future<void> updateRedacteur(Redacteur redacteur) async {
    final db = await database;

    await db.update(
      'redacteurs',
      redacteur.toMap(),
      where: 'id = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<void> deleteRedacteur(int id) async {
    final db = await database;

    await db.delete('redacteurs', where: 'id = ?', whereArgs: [id]);
  }
}
