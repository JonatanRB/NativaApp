import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/plant.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'plantas.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE plants(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            scientificName TEXT NOT NULL,
            description TEXT NOT NULL,
            imagePath TEXT NOT NULL,
            detectedLabel TEXT NOT NULL,
            confidence REAL NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insertar planta
  Future<int> insertPlant(Plant plant) async {
    final db = await database;
    return await db.insert('plants', plant.toMap());
  }

  // Obtener todas las plantas
  Future<List<Plant>> getAllPlants() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }

  // Obtener planta por ID
  Future<Plant?> getPlant(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Plant.fromMap(maps.first);
  }

  // Actualizar planta
  Future<int> updatePlant(Plant plant) async {
    final db = await database;
    return await db.update(
      'plants',
      plant.toMap(),
      where: 'id = ?',
      whereArgs: [plant.id],
    );
  }

  // Eliminar planta
  Future<int> deletePlant(int id) async {
    final db = await database;
    return await db.delete(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Buscar plantas por etiqueta
  Future<List<Plant>> searchByLabel(String label) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plants',
      where: 'detectedLabel LIKE ?',
      whereArgs: ['%$label%'],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Plant.fromMap(maps[i]));
  }
}