import 'package:flutter/material.dart';
import 'package:seer_flutter/pages/sprite_detail_page.dart';
import '../Model/PropertiesType.dart';
import '../Model/Sprite.dart';
import '../widgets/circle_action_button.dart';
import '../widgets/properties_panel.dart';
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
  ///属性
  bool _showPropertiesPanel = false;
  List<PropertiesType> propertiesList = []; // 需要导入你的Properties类
  ///按属性筛选
  String? _selectedProperty; // 当前选中的属性
  bool _isFilteringByProperty = false; // 是否正在按属性筛选
  String? _selectedPropertyName; // 当前选中的属性名称

  @override
  void initState() {
    super.initState();
    _loadSprites();
    _searchController.addListener(_onSearchChanged);
    _loadProperties(); // 初始化时加载属性数据
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
  // 添加加载属性数据的方法
  void _loadProperties() async {
    try {
      print('开始加载属性数据...');
      final properties = await _spriteService.getAllProperties();

      print('获取到 ${properties.length} 个属性');
      for (var prop in properties) {
        print('属性: id=${prop.id}, name=${prop.name}, imagePath=${prop.imagePath}');
      }

      setState(() {
        propertiesList = properties;
      });
      print('成功加载 ${propertiesList.length} 个属性');
    } catch (e) {
      print('加载属性失败: $e');
      // 如果数据库中没有属性表，可以临时使用硬编码数据

    }
  }
  // 修改属性选择回调
  void _handlePropertySelected(PropertiesType property) {
    print('选择了属性: ${property.name}');

    setState(() {
      // 如果点击的是已选中的属性，则取消筛选
      if (_selectedPropertyName == property.name) {
        _selectedPropertyName = null;
        _clearPropertyFilter();
      } else {
        // 否则应用新的筛选
        _selectedPropertyName = property.name;
        _filterByProperty(property.name!);
      }
      _showPropertiesPanel = false;
    });
  }
  void _filterByProperty(String propertyName) async {
    setState(() {
      _isLoading = true;
      _isSearching = true; // 使用搜索状态来显示筛选结果
    });

    try {
      // 调用服务层方法获取该属性的精灵
      final filteredSprites = await _spriteService.getSpritesByProperty(propertyName);
      setState(() {
        _filteredSprites = filteredSprites;
        _isLoading = false;
      });

      print('成功加载 ${filteredSprites.length} 个${propertyName}精灵');

      // 滚动到顶部
      _scrollToTop();
    } catch (e) {
      print('按属性筛选失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  // 应用属性筛选
  void _applyPropertyFilter(String propertyName) async {
    setState(() {
      _isLoading = true;
      _isFilteringByProperty = true;
      _selectedProperty = propertyName;
    });

    try {
      final filteredSprites = await _spriteService.getSpritesByProperty(propertyName);
      setState(() {
        _filteredSprites = filteredSprites;
        _isLoading = false;
      });

      // 滚动到顶部
      _scrollToTop();

      print('成功加载 ${filteredSprites.length} 个${propertyName}精灵');
    } catch (e) {
      print('按属性筛选失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 修改清除筛选方法
  void _clearPropertyFilter() {
    setState(() {
      _isSearching = false;
      _isFilteringByProperty = false;
      _selectedPropertyName = null;
      _filteredSprites = List.from(_sprites);
    });
    print('已清除属性筛选，显示全部精灵');
  }



///ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack( // 使用Stack包裹整个页面内容
          children: [
            Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),

            // 修改属性面板的使用
            if (_showPropertiesPanel)
              PropertiesPanel(
                propertiesList: propertiesList,
                selectedPropertyName: _selectedPropertyName, // 传递选中状态
                onClose: () {
                  setState(() {
                    _showPropertiesPanel = false;
                  });
                },
                onPropertySelected: _handlePropertySelected,
              ),

          ],
        ),
      ),
    );
  }

  // 修改按钮的onPressed方法
  Widget _buildAppBar() {
    return Container(
      // ... 其他代码不变
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            // 返回按钮
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
            // 标题
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 56),
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
            // 右侧三个圆形按钮 - 修改属性按钮的onPressed
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleActionButton(
                      imageAsset: 'assets/icons/属性icon.png',
                      onPressed: () {
                        print('属性按钮点击');
                        setState(() {
                          _showPropertiesPanel = true;
                        });
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
    return Column(
      children: [
        // 属性筛选提示
        if (_selectedPropertyName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Text(
                  '当前筛选: $_selectedPropertyName',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _clearPropertyFilter,
                  child: const Text(
                    '清除',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // 原来的搜索栏
        SpriteSearchBar(
          controller: _searchController,
          onSearchChanged: (value) {
            // 搜索逻辑已经在监听器中处理
          },
          onClearSearch: _clearSearch,
          showClearButton: _showClearButton,
        ),
        Container(
          height: 1, // 线条粗细
          color: Colors.black, // 线条颜色
          margin: const EdgeInsets.symmetric(horizontal: 0), // 左右边距
        ),
      ],
    );
  }

  // 修改构建内容方法，显示筛选状态
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 显示空状态
    final displaySprites = _isSearching || _isFilteringByProperty
        ? _filteredSprites
        : _sprites;

    if (displaySprites.isEmpty) {
      return _buildEmptyState();
    }

    return _buildSpriteGrid();
  }
  // 空状态组件
  Widget _buildEmptyState() {
    String message = '暂无数据';

    if (_isSearching) {
      message = '没有找到相关的精灵';
    } else if (_isFilteringByProperty) {
      message = '没有找到$_selectedProperty属性的精灵';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (_isFilteringByProperty || _isSearching)
            TextButton(
              onPressed: () {
                if (_isFilteringByProperty) {
                  _clearPropertyFilter();
                } else if (_isSearching) {
                  _clearSearch();
                }
              },
              child: const Text('清除筛选'),
            ),
        ],
      ),
    );
  }
  ///精灵搜索
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