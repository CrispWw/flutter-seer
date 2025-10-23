import 'package:flutter/material.dart';
import 'package:seer_flutter/pages/sprite_detail_page.dart';
import '../Model/Sprite.dart';
import '../widgets/circle_action_button.dart';
import '../widgets/sprite_grid_item.dart';
import '../widgets/sprite_search_bar.dart';
import '../services/sprite_service.dart';
import '../models/sprite_model.dart';

class SpriteGalleryPage extends StatefulWidget {
  const SpriteGalleryPage({super.key});

  @override
  State<SpriteGalleryPage> createState() => _SpriteGalleryPageState();
}

class _SpriteGalleryPageState extends State<SpriteGalleryPage> {
  final TextEditingController _searchController = TextEditingController();
  final SpriteService _spriteService = SpriteService();
  final ScrollController _scrollController = ScrollController();

  List<Sprite> _sprites = [];
  List<Sprite> _filteredSprites = [];
  bool _isLoading = true;
  bool _showClearButton = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSprites();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final keyword = _searchController.text;
    setState(() {
      _showClearButton = keyword.isNotEmpty;
    });
    _performSearch(keyword);
  }

  void _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredSprites = List.from(_sprites);
      });
    } else {
      setState(() {
        _isSearching = true;
        _isLoading = true;
      });

      try {
        final searchResults = await _spriteService.searchSpritesByName(keyword);
        setState(() {
          _filteredSprites = searchResults;
          _isLoading = false;
        });
        // 搜索时滚动到顶部
        _scrollToTop();
      } catch (e) {
        print('搜索失败: $e');
        setState(() {
          _filteredSprites = [];
          _isLoading = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _filteredSprites = List.from(_sprites);
    });
    _scrollToTop();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  void _loadSprites() async {
    try {
      final sprites = await _spriteService.getAllSpritesReversed();
      setState(() {
        _sprites = sprites;
        _filteredSprites = List.from(sprites);
        _isLoading = false;
      });
    } catch (e) {
      print('加载精灵失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 简化的导航方法
  void _navigateToDetail(int spriteId) async {
    // 保存当前滚动位置
    final currentOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpriteDetailPage(spriteId: spriteId),
      ),
    );

    // 返回后恢复位置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(currentOffset);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
///ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSearchBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF000000),
            width: 2,
          ),
        ),
      ),
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            // 返回按钮保持在原位置
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                splashRadius: 20,
              ),
            ),
            // 标题靠左对齐，但不与返回按钮重叠
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 56), // 调整这个值来设置标题位置
                child: const Text(
                  '精灵图鉴',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
// 右侧三个圆形按钮
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleActionButton(
                      imageAsset: 'assets/icons/属性icon.png', // 使用自定义图片
                      onPressed: () {
                        print('收藏按钮点击');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SpriteSearchBar(
      controller: _searchController,
      onSearchChanged: (value) {
        // 搜索逻辑已经在监听器中处理
      },
      onClearSearch: _clearSearch,
      showClearButton: _showClearButton,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return _buildSpriteGrid();
  }

  Widget _buildSpriteGrid() {
    final displaySprites = _isSearching ? _filteredSprites : _sprites;

    // 搜索状态下没有匹配结果时，显示空白
    if (_isSearching && displaySprites.isEmpty) {
      return Container(); // 或者返回您想要的任何空白组件
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: displaySprites.length, // 不再有占位符
      itemBuilder: (context, index) {
        final sprite = displaySprites[index];
        return SpriteGridItem(
          imageUrl: sprite.imageUrl,
          name: sprite.name ?? '未知精灵',
          id: sprite.id ?? 0,
          properties: sprite.attribute ?? '未知属性',
          onTap: () {
            _onSpriteTap(sprite, index);
          },
        );
      },
    );
  }

  void _onSpriteTap(Sprite sprite, int position) {
    // 直接跳转，不需要保存复杂的位置信息
    _navigateToDetail(sprite.id!);
  }
}