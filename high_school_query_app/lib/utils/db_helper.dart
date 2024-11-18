import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;

  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    sqfliteFfiInit(); // 初始化 sqflite_common_ffi
    databaseFactory = databaseFactoryFfi; // 使用 FFI

    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'students.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            nativePlace TEXT,
            examYear INTEGER,
            admittedUniversity TEXT,
            highSchool TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertSampleData() async {
    final db = await database;

    // 检查数据库是否已有数据，避免重复插入
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM students'));
    if (count! > 0) return; // 如果已有数据，则不插入

    // 插入一些测试数据
    await db.insert('students', {
      'name': '张三',
      'nativePlace': '广东省',
      'examYear': 2020,
      'admittedUniversity': '清华大学',
      'highSchool': '深圳中学'
    });

    await db.insert('students', {
      'name': '李四',
      'nativePlace': '北京市',
      'examYear': 2019,
      'admittedUniversity': '北京大学',
      'highSchool': '北京四中'
    });

    await db.insert('students', {
      'name': '王五',
      'nativePlace': '上海市',
      'examYear': 2021,
      'admittedUniversity': '复旦大学',
      'highSchool': '上海中学'
    });
  }

  Future<List<Map<String, dynamic>>> queryStudents() async {
    final db = await database;
    return await db.query('students');
  }

  // 添加根据关键字搜索学生的方法
  Future<List<Map<String, dynamic>>> searchStudentsByConditions({
    String? keyword,
    String? year,
    String? university,
    String? highSchool,
  }) async {
    final db = await database;
    String query = 'SELECT * FROM students WHERE 1=1';
    List<dynamic> args = [];

    if (keyword != null && keyword.isNotEmpty) {
      query += ' AND (name LIKE ? OR nativePlace LIKE ?)';
      args.add('%$keyword%');
      args.add('%$keyword%');
    }
    if (year != null && year.isNotEmpty) {
      query += ' AND examYear = ?';
      args.add(int.parse(year));
    }
    if (university != null && university.isNotEmpty) {
      query += ' AND admittedUniversity LIKE ?';
      args.add('%$university%');
    }
    if (highSchool != null && highSchool.isNotEmpty) {
      query += ' AND highSchool LIKE ?';
      args.add('%$highSchool%');
    }

    return await db.rawQuery(query, args);
  }

  Future<List<Map<String, dynamic>>> searchStudentsByKeywords(List<String> keywords) async {
  final db = await database;
  String query = 'SELECT * FROM students WHERE 1=1';
  List<dynamic> args = [];

  for (var keyword in keywords) {
    if (keyword.isNotEmpty) {
      // 使用 OR 条件链接多个查询条件
      query += ' AND (name LIKE ? OR nativePlace LIKE ? OR examYear LIKE ? OR admittedUniversity LIKE ? OR highSchool LIKE ?)';
      args.add('%$keyword%');
      args.add('%$keyword%');
      args.add('%$keyword%');
      args.add('%$keyword%');
      args.add('%$keyword%');
    }
  }

  return await db.rawQuery(query, args);
}
}
