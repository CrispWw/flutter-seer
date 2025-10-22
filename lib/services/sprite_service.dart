import '../Model/Sprite.dart';
import '../databases/db_helper.dart';
import '../models/sprite_model.dart';


class SpriteService {
  /**
   * 获取所有精灵列表（反向排序）
   */
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

  /**
   * 根据ID查询精灵详细信息
   */
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
  /**
   * 根据名称模糊搜索精灵
   */
  Future<List<Sprite>> searchSpritesByName(String keyword) async {
    try {
      final db = await DBHelper.database;

      final List<Map<String, dynamic>> maps = await db.rawQuery(
          'SELECT id, name, image_url FROM sprites WHERE name LIKE ? ORDER BY id DESC',
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
}