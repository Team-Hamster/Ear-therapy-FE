import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ear_database.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL CHECK (gender IN ('M', 'F')),
        photo TEXT,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        symptom_id INTEGER NOT NULL,
        date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        memo TEXT,
        photo TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (symptom_id) REFERENCES symptoms(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_results_user_id ON results(user_id)');
    await db.execute('CREATE INDEX idx_results_symptom_id ON results(symptom_id)');
  }

    Future<void> insertInitialData() async {
    final db = await database;

    // 기본 증상 목록 삽입
    const symptoms = ['감기', '스트레스', '열', '어지럼증', '두통', '집중력', '코피', '생리통', '빈뇨'];
    for (final symptom in symptoms) {
      await db.insert(
        'symptoms',
        {'name': symptom},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<int> insertUser({
    required String name,
    required int age,
    required String gender,
  }) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'name': name,
        'age': age,
        'gender': gender,
        'photo': null,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 결과 삽입
  Future<int> insertResult({
    required int userId,
    required String symptomName,
    required String date,
    String? memo,
    String? photo,
  }) async {
    final db = await database;

    // 증상 ID 가져오기
    final List<Map<String, dynamic>> symptomMaps = await db.query(
      'symptoms',
      where: 'name = ?',
      whereArgs: [symptomName],
    );

    int symptomId;
    if (symptomMaps.isEmpty) {
      // 증상 추가
      symptomId = await db.insert(
        'symptoms',
        {'name': symptomName},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      symptomId = symptomMaps.first['id'];
    }

    // 결과 삽입
    return await db.insert(
      'results',
      {
        'user_id': userId,
        'symptom_id': symptomId,
        'memo': memo,
        'photo': photo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 사용자 목록 가져오기
  Future<Map<String, dynamic>?> getLastUser() async {
    final db = await database;
    final result = await db.query(
      'users',
      orderBy: 'id DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 특정 사용자의 결과 가져오기
  Future<List<Map<String, dynamic>>> getUserResults(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        r.*, 
        s.name as symptom_name
      FROM results r
      JOIN symptoms s ON r.symptom_id = s.id
      WHERE r.user_id = ?
      ORDER BY r.date DESC
    ''', [userId]);
  }

  // 결과 메모 업데이트
  Future<void> updateResultMemo(int resultId, String memo) async {
    final db = await database;
    await db.update(
      'results',
      {'memo': memo},
      where: 'id = ?',
      whereArgs: [resultId],
    );
  }
  // 결과 삭제
  Future<void> deleteResult(int resultId) async {
    final db = await database;

    // 특정 결과 삭제
    await db.delete(
      'results',
      where: 'id = ?',
      whereArgs: [resultId],
    );
  }

  // 결과 상세 정보 가져오기
  Future<Map<String, dynamic>?> getResultDetail(int resultId) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT 
        r.*, 
        s.name as symptom_name,
        u.name as user_name
      FROM results r
      JOIN symptoms s ON r.symptom_id = s.id
      JOIN users u ON r.user_id = u.id
      WHERE r.id = ?
    ''', [resultId]);

    return results.isNotEmpty ? results.first : null;
  }

  // 데이터베이스 리셋
  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('users');
    await db.delete('symptoms');
    await db.delete('results');
  }

  // 데이터베이스 닫기
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}