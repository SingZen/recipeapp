import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class RecipeDatabase {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'recipes.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recipes (
            id INTEGER PRIMARY KEY,
            name TEXT,
            ingredients TEXT,
            instructions TEXT,
            prepTimeMinutes INTEGER,
            cookTimeMinutes INTEGER,
            servings INTEGER,
            difficulty TEXT,
            cuisine TEXT,
            caloriesPerServing INTEGER,
            tags TEXT,
            userId INTEGER,
            image TEXT,
            rating REAL,
            reviewCount INTEGER,
            mealType TEXT
          )
        ''');
      },
    );

    return _db!;
  }
}
