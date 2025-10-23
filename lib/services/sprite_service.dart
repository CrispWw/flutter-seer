import 'dart:convert' as convert; // 添加别名
import '../Model/SeerSkills.dart';
import '../Model/Sprite.dart';
import '../databases/db_helper.dart';


class SpriteService {
  /// 获取所有精灵列表（反向排序）
  Future<List<Sprite>> getAllSpritesReversed() async {
    try {
      final db = await DBHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('sprites');

      final List<Sprite> sprites = maps.map((spriteData) => Sprite.fromJson(spriteData)).toList();

      // 反转列表顺序
      return sprites.reversed.toList();
    } catch (e) {
      print('获取所有精灵失败: $e');
      return [];
    }
  }

  /// 根据ID查询精灵详细信息
  Future<Sprite?> getSpriteById(int id) async {
    try {
      final db = await DBHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'sprites',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Sprite.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('查询精灵详情失败: $e');
      return null;
    }
  }

  /// 根据名称模糊搜索精灵
  Future<List<Sprite>> searchSpritesByName(String keyword) async {
    try {
      final db = await DBHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
          'SELECT id, name, image_url, attribute FROM sprites WHERE name LIKE ? ORDER BY id DESC',
          ['%$keyword%']
      );

      final List<Sprite> sprites = [];

      for (final spriteData in maps) {
        final sprite = Sprite.fromJson(spriteData);

        // 处理图片URL：如果为空，使用默认路径
        if (sprite.imageUrl == null || sprite.imageUrl!.isEmpty) {
          sprite.imageUrl = 'images/sprites/${sprite.id}.webp';
        }

        sprites.add(sprite);
      }

      print('搜索 "$keyword" 找到 ${sprites.length} 个精灵');
      return sprites;
    } catch (e) {
      print('搜索精灵失败: $e');
      return [];
    }
  }

  /// 根据属性名称从本地数据库获取属性图标路径
  /// 数据库存储格式如: "images/properties/草系.png"
  Future<String> getAttributeIconPath(String attributeName) async {
    try {
      final db = await DBHelper.database;

      // 查询properties表
      final List<Map<String, dynamic>> results = await db.query(
        'properties',
        where: 'name = ?',
        whereArgs: [attributeName],
      );

      if (results.isNotEmpty) {
        final String? dbImagePath = results.first['image_path'] as String?;

        if (dbImagePath != null && dbImagePath.isNotEmpty) {
          // 将数据库路径转换为资源路径
          final String assetPath = _convertToAssetPath(dbImagePath);
          print('属性图标路径转换: 数据库="$dbImagePath" -> 资源="$assetPath"');
          return assetPath;
        } else {
          print('属性 $attributeName 的 image_path 为空');
          return _getDefaultIconPath();
        }
      } else {
        print('未找到属性: $attributeName');
        return _getDefaultIconPath();
      }
    } catch (e) {
      print('获取属性图标路径异常: $e');
      return _getDefaultIconPath();
    }
  }

  /// 将数据库路径转换为资源路径
  String _convertToAssetPath(String dbPath) {
    // 数据库存储格式: "images/properties/草系.png"
    // 资源路径格式: "assets/images/properties/草系.png"

    // 如果路径已经是 assets 开头，直接返回
    if (dbPath.startsWith('assets/')) {
      return dbPath;
    }

    // 如果路径是 "images/..."，添加 "assets/" 前缀
    if (dbPath.startsWith('images/')) {
      return 'assets/$dbPath';
    }

    // 如果路径只是文件名，假设它在 properties 文件夹中
    if (!dbPath.contains('/')) {
      return 'assets/images/properties/$dbPath';
    }

    // 其他情况，添加 assets 前缀
    return 'assets/$dbPath';
  }

  /// 获取默认图标路径
  String _getDefaultIconPath() {
    return 'assets/images/properties/default.png';
  }

  /// 根据精灵ID查询魂印描述
  /// 根据精灵ID查询魂印描述
  Future<String?> getSoulDescriptionById(int spriteId) async {
    try {
      final db = await DBHelper.database;

      // 直接查询魂印表，使用固定的字段名
      final List<Map<String, dynamic>> results = await db.query(
        'spiritsoul',
        where: 'petid = ?',
        whereArgs: [spriteId],
      );

      if (results.isNotEmpty) {
        // 直接使用固定的字段名获取魂印描述
        final String? soulDescription = results.first['spirit_soul'] as String?;

        if (soulDescription != null && soulDescription.isNotEmpty) {
          print('找到精灵 $spriteId 的魂印描述');
          return soulDescription;
        } else {
          print('精灵 $spriteId 的魂印描述为空');
          return "无魂印";
        }
      } else {
        print('未找到精灵 $spriteId 的魂印记录');
        return "无魂印";
      }
    } catch (e) {
      print('查询魂印描述失败: $e');
      throw Exception('魂印加载失败: $e');
    }
  }


  /// 根据精灵ID查询技能数据
  Future<List<SeerSkills>?> querySkillsById(int spriteId) async {
    try {
      final db = await DBHelper.database;

      // 查询技能表
      final List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT spirit_name, skills FROM seerskills WHERE id = ?',
        [spriteId.toString()],
      );

      if (results.isNotEmpty) {
        final String spiritName = results.first['spirit_name'] as String? ?? '';
        final String skillsJson = results.first['skills'] as String? ?? '';

        print('找到技能数据，精灵名称: $spiritName');
        print('技能JSON长度: ${skillsJson.length}');

        // 检查JSON是否为空
        if (skillsJson.isEmpty) {
          print('技能JSON为空');
          return [];
        }

        // 使用完整的导入前缀解析JSON数据
        final List<dynamic> skillsArray = convert.json.decode(skillsJson);
        print('解析出 ${skillsArray.length} 个技能');

        final List<SeerSkills> skillsList = [];

        for (int i = 0; i < skillsArray.length; i++) {
          try {
            final skillObj = skillsArray[i] as Map<String, dynamic>;

            final skill = SeerSkills(
              spiritName: spiritName,
              name: skillObj['名称']?.toString() ?? '',
              power: skillObj['威力']?.toString() ?? '',
              pp: skillObj['PP']?.toString() ?? '',
              accuracy: skillObj['命中']?.toString() ?? '',
              priority: skillObj['先制']?.toString() ?? '',
              type: skillObj['攻击类型']?.toString() ?? '',
              strong: skillObj['暴击']?.toString() ?? '',
              effect: skillObj['效果']?.toString() ?? '',
            );

            skillsList.add(skill);
            print('添加技能 ${i + 1}: ${skill.name}');
          } catch (e) {
            print('解析第 ${i + 1} 个技能时出错: $e');
          }
        }

        // 反转技能列表
        final reversedList = skillsList.reversed.toList();
        print('反转后技能数量: ${reversedList.length}');

        return reversedList;
      } else {
        print('未在数据库中找到ID为 $spriteId 的技能记录');
        return null;
      }
    } catch (e) {
      print('查询技能时出错: $e');
      return null;
    }
  }
}