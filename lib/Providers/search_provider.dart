import 'package:flutter/foundation.dart';
import '../Model/Sprite.dart';
import '../models/sprite_model.dart';
import '../services/sprite_service.dart';
//搜索管理类，用来记录搜索时列表状态
class SearchProvider with ChangeNotifier {
  final SpriteService _spriteService = SpriteService();

  List<Sprite> _allSprites = [];
  List<Sprite> _filteredSprites = [];
  bool _isLoading = false;
  String _searchKeyword = '';
  bool _isSearching = false;

  List<Sprite> get allSprites => _allSprites;
  List<Sprite> get filteredSprites => _filteredSprites;
  bool get isLoading => _isLoading;
  String get searchKeyword => _searchKeyword;
  bool get isSearching => _isSearching;

  /**
   * 加载所有精灵
   */
  Future<void> loadAllSprites() async {
    _setLoading(true);
    try {
      _allSprites = await _spriteService.getAllSpritesReversed();
      _filteredSprites = List.from(_allSprites);
      notifyListeners();
    } catch (e) {
      print('加载精灵列表失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /**
   * 搜索精灵
   */
  Future<void> searchSprites(String keyword) async {
    _searchKeyword = keyword;

    if (keyword.isEmpty) {
      // 关键字为空，显示所有精灵
      _isSearching = false;
      _filteredSprites = List.from(_allSprites);
    } else {
      // 执行搜索
      _isSearching = true;
      _setLoading(true);
      try {
        _filteredSprites = await _spriteService.searchSpritesByName(keyword);
      } catch (e) {
        print('搜索精灵失败: $e');
        _filteredSprites = [];
      } finally {
        _setLoading(false);
      }
    }
    notifyListeners();
  }

  /**
   * 清除搜索
   */
  void clearSearch() {
    _searchKeyword = '';
    _isSearching = false;
    _filteredSprites = List.from(_allSprites);
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}