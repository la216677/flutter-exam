import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<Database> db() async {
    return openDatabase(
      'mydb.db',
      version: 1,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String? descrption) async {
    final db = await SQLHelper.db();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String title, String? descrption) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };

    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<int> deleteItem(int id) async {
    final db = await SQLHelper.db();
    final result = await db.delete('items', where: "id = ?", whereArgs: [id]);
    return result;
  }

}