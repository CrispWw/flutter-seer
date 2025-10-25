// services/dynamic_island_service.dart
import 'package:flutter/services.dart';

class DynamicIslandService {
  static const _channel = MethodChannel('dynamic_island');

  /// 设置当前查看的精灵（在进入详情页时调用）
  static Future<void> setCurrentSprite({
    required int id,
    required String name,
  }) async {
    try {
      await _channel.invokeMethod('setCurrentSprite', {
        'id': id,
        'name': name,
      });
      print('✅ 设置当前精灵: $name (ID: $id)');
    } on PlatformException catch (e) {
      print('❌ 设置精灵失败: ${e.message}');
    }
  }

  /// 手动触发后台显示（测试用）
  static Future<void> showInBackground() async {
    try {
      await _channel.invokeMethod('showInBackground');
      print('✅ 触发后台显示');
    } on PlatformException catch (e) {
      print('❌ 后台显示失败: ${e.message}');
    }
  }

  static Future<void> hide() async {
    try {
      await _channel.invokeMethod('hideDynamicIsland');
      print('✅ 灵动岛隐藏成功');
    } on PlatformException catch (e) {
      print('❌ 灵动岛隐藏失败: ${e.message}');
    }
  }
}