import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
      version: 2,
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
        dueño TEXT NOT NULL,
        imagen TEXT
      )
    ''');
  }

  Future<int> insertMascota(Mascota mascota) async {
    final db = await instance.database;
    return await db.insert('mascotas', mascota.toMap());
  }

  Future<List<Mascota>> getMascotas({String? filtro}) async {
    final db = await instance.database;
    final result = filtro == null || filtro.isEmpty
        ? await db.query('mascotas')
        : await db.query(
            'mascotas',
            where: 'nombre LIKE ?',
            whereArgs: ['%$filtro%'],
          );

    return result.map((map) => Mascota.fromMap(map)).toList();
  }

  Future<int> updateMascota(Mascota mascota) async {
    final db = await instance.database;
    return await db.update(
      'mascotas',
      mascota.toMap(),
      where: 'id = ?',
      whereArgs: [mascota.id],
    );
  }

  Future<int> deleteMascota(int id) async {
    final db = await instance.database;
    return await db.delete(
      'mascotas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
