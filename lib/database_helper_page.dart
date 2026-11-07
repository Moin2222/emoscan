import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'user.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            email TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  // ✅ Insert User
  Future<int> insertUser(String username, String email, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'username': username, 'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ✅ Fetch User by Email & Password
  Future<User?> getUserByEmailAndPassword(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  // ✅ Fetch user by Username & Email for Forget Password
  Future<User?> getUserByUsernameAndEmail(String username, String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND email = ?',
      whereArgs: [username, email],
    );

    return result.isNotEmpty ? User.fromMap(result.first) : null;
  }

  // ✅ Fix: Update Password for Reset Password Page
  Future<int> updateUserPassword(int userId, String newPassword) async {
    final db = await database;
    return await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',  // 🔹 Fix: Use 'id' instead of 'user_id'
      whereArgs: [userId],
    );
  }
}
