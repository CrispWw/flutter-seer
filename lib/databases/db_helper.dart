import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static const String currentDbName = "1.2.6seer.db";
  static const int currentDbVersion = 6;
  static const String prefsName = 'db_prefs';
  static const String keyCurrentDb = 'current_db_name';
  static const String keyDbVersion = 'db_version';

  static Database? _database;

  // 获取数据库实例
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // 初始化数据库
  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, currentDbName);

    final prefs = await SharedPreferences.getInstance();
    final String lastUsedDb = prefs.getString(keyCurrentDb) ?? '';
    final int lastDbVersion = prefs.getInt(keyDbVersion) ?? 0;

    // 检查条件：数据库名变更 或 版本号变更 或 数据库文件不存在
    final bool dbNameChanged = currentDbName != lastUsedDb;
    final bool dbVersionUpgraded = currentDbVersion > lastDbVersion;
    final bool dbNotExists = !await File(path).exists();

    if (dbNameChanged || dbVersionUpgraded || dbNotExists) {
      print('需要复制数据库 - '
          '名称变更: $dbNameChanged ($lastUsedDb -> $currentDbName), '
          '版本升级: $dbVersionUpgraded ($lastDbVersion -> $currentDbVersion), '
          '文件不存在: $dbNotExists');

      await _copyDatabaseFromAssets(path);
      await _setCurrentDatabaseInfo();
    } else {
      print('使用现有数据库: $currentDbName, 版本: $lastDbVersion');
    }

    // 打开数据库
    return await openDatabase(
      path,
      version: currentDbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // 从 assets 复制数据库
  static Future<void> _copyDatabaseFromAssets(String path) async {
    try {
      final File dbFile = File(path);
      final dbDir = dbFile.parent;

      if (!await dbDir.exists()) {
        await dbDir.create(recursive: true);
      }

      // 如果文件已存在，先删除旧数据库
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('删除旧数据库成功');
      }

      print('复制新数据库: $currentDbName (版本: $currentDbVersion)');

      // 从 assets 读取数据库文件
      final ByteData data = await rootBundle.load('assets/databases/$currentDbName');
      final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // 写入到应用目录
      await File(path).writeAsBytes(bytes, flush: true);

      final file = File(path);
      print('数据库复制完成，大小: ${(await file.length())} bytes');

    } catch (e) {
      print('复制数据库失败: $e');
      throw Exception('数据库初始化失败: $e');
    }
  }

  // 记录当前数据库信息
  static Future<void> _setCurrentDatabaseInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyCurrentDb, currentDbName);
    await prefs.setInt(keyDbVersion, currentDbVersion);
    print('记录数据库信息 - 名称: $currentDbName, 版本: $currentDbVersion');
  }

  // 创建数据库（空实现）
  static Future<void> _onCreate(Database db, int version) async {
    // 空实现 - 数据库从 assets 复制，不需要在这里创建
  }

  // 数据库升级
  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('数据库版本升级: $oldVersion -> $newVersion');
    // 空实现 - 数据库升级通过复制新版本数据库文件处理
  }

  // 关闭数据库
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  // 检查数据库是否存在
  static Future<bool> isDatabaseExists() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, currentDbName);
    return await File(path).exists();
  }

  // 获取数据库路径
  static Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, currentDbName);
  }
}
