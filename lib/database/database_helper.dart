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
    // users 테이블 생성
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

    // symptoms 테이블 생성
    await db.execute('''
      CREATE TABLE symptoms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // results 테이블 생성
    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        symptom_id INTEGER NOT NULL,
        date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        title TEXT,
        memo TEXT,
        photo TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (symptom_id) REFERENCES symptoms(id) ON DELETE CASCADE
      )
    ''');

    // 인덱스 생성
    await db.execute(
      'CREATE INDEX idx_results_user_id ON results(user_id)'
    );
    await db.execute(
      'CREATE INDEX idx_results_symptom_id ON results(symptom_id)'
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete('users'); // 모든 사용자 데이터 삭제
    await db.delete('symptoms'); // 모든 증상 데이터 삭제
    await db.delete('results'); // 모든 결과 데이터 삭제
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
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertResult({
    required String symptomName,
    required String date,
    String? memo,
    String? photo,
  }) async {
    final db = await database;

    // 1. symptom_id 조회
    final List<Map<String, dynamic>> symptomMaps = await db.query(
      'symptoms',
      where: 'name = ?',
      whereArgs: [symptomName],
    );

    if (symptomMaps.isEmpty) {
      throw Exception('Symptom not found: $symptomName');
    }

    final int symptomId = symptomMaps.first['id'];

    // 2. results 테이블에 데이터 삽입
    final resultId = await db.insert(
      'results',
      {
        'user_id': 1,  // 현재는 고정값 사용
        'symptom_id': symptomId,
        'date': date,
        'memo': memo,
        'photo': photo,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return resultId;
  }

  Future<void> updateUserIdInResults(int userId) async {
    final db = await database;
    await db.update(
      'results',
      {'user_id': userId},
      where: 'user_id = ?',
      whereArgs: [1], // 기존 사용자 ID를 1로 가정
    );
  }

  Future<Map<String, dynamic>?> getLastUser() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      orderBy: 'id DESC', // ID 기준으로 내림차순 정렬
      limit: 1, // 가장 최근 사용자 1명만 가져오기
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> printAllData() async {
    final db = await database;
    
    print('\n=== Users ===');
    final users = await db.query('users');
    print(users);
    
    print('\n=== Symptoms ===');
    final symptoms = await db.query('symptoms');
    print(symptoms);
    
    print('\n=== Results ===');
    final results = await db.query('results');
    print(results);
  }

  Future<void> deleteResult(int id) async {
    final db = await database;
    await db.delete(
      'results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getUserResults(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(''' 
      SELECT 
        r.*,
        s.name as symptom_name
      FROM results r
      JOIN symptoms s ON r.symptom_id = s.id
      WHERE r.user_id = ?
      ORDER BY r.date DESC
    ''', [userId]);
    
    return results;
  }

  Future<Map<String, dynamic>?> getResultDetail(int resultId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(''' 
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

  Future<void> insertInitialData() async {
    final db = await database;

    // 1. symptoms 데이터 삽입
    final List<String> symptoms = [
      '감기', '스트레스', '열', '어지럼증', '두통', 
      '집중력', '생리통', '빈뇨'
    ];

    for (String symptom in symptoms) {
      await db.insert(
        'symptoms',
        {'name': symptom},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    // 2. user 데이터 삽입
    await db.insert(
      'users',
      {
        'name': '김이혈', // 기존 데이터 삭제
        'age': 22,
        'gender': 'F',
        'photo': null,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // 3. result 데이터 삽입
    final List<Map<String, dynamic>> symptomMaps = await db.query(
      'symptoms',
      where: 'name = ?',
      whereArgs: ['감기'],
    );
    
    if (symptomMaps.isNotEmpty) {
      final int symptomId = symptomMaps.first['id'];
      await db.insert(
        'results',
        {
          'user_id': 1, // 고정된 사용자 ID
          'symptom_id': symptomId,
          'date': DateTime(2024, 11, 19).toIso8601String(), // 고정된 날짜
          'title': '이침 후 첫 기록',
          'memo': '어제 저녁 혈자리에 패치를 붙이고 잤더니 감기 증상이 호전되었다.',
          'photo': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}