import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../models/mascota.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mascotas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mascotas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        especie TEXT NOT NULL,
        edad INTEGER NOT NULL,
        dueno TEXT NOT NULL
      )
    ''');
  }

  // Insertar
  Future<int> insertMascota(Mascota mascota) async {
    final db = await instance.database;
    return await db.insert('mascotas', mascota.toMap());
  }

  // Obtener todas
  Future<List<Mascota>> getMascotas() async {
    final db = await instance.database;
    final result = await db.query('mascotas');
    return result.map((e) => Mascota.fromMap(e)).toList();
  }

  // Actualizar
  Future<int> updateMascota(Mascota mascota) async {
    final db = await instance.database;
    return await db.update(
      'mascotas',
      mascota.toMap(),
      where: 'id = ?',
      whereArgs: [mascota.id],
    );
  }

  // Eliminar
  Future<int> deleteMascota(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mascotas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
