import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // 版本号从 1 升级到 2
      onCreate: _createDB,
      onUpgrade: _onUpgrade, // 添加升级处理函数
    );
  }

  // 创建表结构
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT,
        music TEXT,
        time TEXT,
        weather TEXT,
        location TEXT,
        imagePath TEXT -- 全新安装时直接创建含图片路径的表
      )
    ''');
  }

  // 处理老用户升级，动态增加 imagePath 字段
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE diary ADD COLUMN imagePath TEXT');
      print("数据库已升级至版本 2，加入了 imagePath 字段");
    }
  }

  // 修改插入方法，接收 imagePath
  Future<void> insertDiary({
    required String content,
    required String music,
    required String weather,
    required String location,
    String? imagePath, // 新增
  }) async {
    final db = await database;
    await db.insert('diary', {
      'content': content,
      'music': music,
      'time': DateTime.now().toString(),
      'weather': weather,
      'location': location,
      'imagePath': imagePath, // 新增
    });
  }

  Future<List<Map<String, dynamic>>> getDiaries() async {
    final db = await database;
    return await db.query('diary', orderBy: 'time DESC');
  }

  // 修改更新方法，接收 imagePath
  Future<void> updateDiary({
    required int id,
    required String content,
    required String music,
    required String weather,
    required String location,
    String? imagePath, // 新增
  }) async {
    final db = await database;
    await db.update(
        'diary',
        {'content': content, 'music': music, 'weather': weather, 'location': location, 'imagePath': imagePath},
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  Future<void> deleteDiary(int id) async {
    final db = await database;
    await db.delete('diary', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllDiaries() async {
    final db = await database;
    await db.delete('diary');
  }
}