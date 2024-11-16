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

  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final userCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users')
    );
    return userCount == 0;
  }

  Future<void> insertInitialData() async {
    // 데이터베이스가 비어있을 때만 초기 데이터 삽입
    if (!await isDatabaseEmpty()) {
      return;
    }

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
        'id': 1,
        'name': '김이혈',
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
          'user_id': 1,
          'symptom_id': symptomId,
          'date': DateTime(2023, 11, 16).toIso8601String(),
          'title': '이침 후 첫 기록',
          'memo': '어제 저녁 혈자리에 패치를 붙이고 잤더니 감기 증상이 호전되었다.',
          'photo': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 데이터베이스 초기화를 위한 메서드
  Future<void> initializeDatabase() async {
    final db = await database;
    await insertInitialData();
  }

  // 모든 증상 조회
  Future<List<Map<String, dynamic>>> getAllSymptoms() async {
    final db = await database;
    return await db.query('symptoms', orderBy: 'name');
  }

  // 특정 사용자 조회
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // 특정 사용자의 모든 진단 결과 조회 (증상 이름 포함)
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

  // 특정 진단 결과 상세 조회
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

  // 데이터베이스의 모든 테이블 데이터 조회 (디버깅용)
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

  // 새로운 진단 결과 추가 메서드
  Future<void> insertNewResult() async {
    final db = await database;

    // '열' 증상의 id 조회
    final List<Map<String, dynamic>> symptomMaps = await db.query(
      'symptoms',
      where: 'name = ?',
      whereArgs: ['열'],
    );
    
    if (symptomMaps.isNotEmpty) {
      final int symptomId = symptomMaps.first['id'];
      await db.insert(
        'results',
        {
          'user_id': 1,
          'symptom_id': symptomId,
          'date': DateTime(2023, 11, 17).toIso8601String(),
          'title': '발열증상',
          'memo': '감기때문인지 열이 올라와서 패치를 15시경 패치를 붙였더니 열이 좀 내려갔다.',
          'photo': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 데이터베이스 삭제
  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ear_database.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;  // 데이터베이스 인스턴스 초기화
  }

  // 데이터베이스 초기화 (삭제 후 재생성)
  Future<void> resetDatabase() async {
    await deleteDatabase();
    await database;  // 새로운 데이터베이스 생성
    await insertInitialData();  // 초기 데이터 한 번만 삽입
  }
} 