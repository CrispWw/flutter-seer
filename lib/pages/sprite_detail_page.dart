import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../Model/SeerSkills.dart';
import '../Model/Sprite.dart';
import '../services/dynamic_island_service.dart';
import '../services/sprite_service.dart';
import '../models/sprite_model.dart';

class SpriteDetailPage extends StatefulWidget {
  final int spriteId;

  const SpriteDetailPage({
    Key? key,
    required this.spriteId,
  }) : super(key: key);

  @override
  State<SpriteDetailPage> createState() => _SpriteDetailPageState();
}

class _SpriteDetailPageState extends State<SpriteDetailPage> {
  final SpriteService _spriteService = SpriteService();
  Sprite? _sprite;
  bool _isLoading = true;
  String? _soulMarkDescription;
  String? _skillsDescription;
  bool _isLoadingSoul = true;//魂印状态
  List<SeerSkills>? _skillsList;
  bool _isLoadingSkills = true;//技能状态
  bool _showFullscreenImage = false;
  String? _attributeIconPath; // 新增：属性图标路径

  @override
  void initState() {
    super.initState();
    _setCurrentSprite();
    _loadSpriteData();
    _loadSoulMarkData();
    _loadSkillsData();
  }
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果精灵数据更新，重新设置
    _setCurrentSprite();
  }
  @override
  void dispose() {
    DynamicIslandService.hide();
    super.dispose();
  }

  void _loadSpriteData() async {
    try {
      final sprite = await _spriteService.getSpriteById(widget.spriteId);
      setState(() {
        _sprite = sprite;
        _isLoading = false;
      });

      // 加载属性图标
      if (sprite?.attribute != null) {
        _loadAttributeIcon(sprite!.attribute!);
      }
      _loadSoulMarkData(); ///加载魂印
      _loadSkillsData();///加载技能
    } catch (e) {
      print('加载精灵详情失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  // 显示到灵动岛
  void _setCurrentSprite() {
    if (_sprite != null) {
      DynamicIslandService.setCurrentSprite(
        id: _sprite!.id!,
        name: _sprite!.name ?? '未知精灵',
      );
    }
  }

  /// 加载属性图标
  void _loadAttributeIcon(String attributeName) async {
    try {
      final iconPath = await _spriteService.getAttributeIconPath(attributeName);
      setState(() {
        _attributeIconPath = iconPath;
      });
    } catch (e) {
      print('加载属性图标失败: $e');
      setState(() {
        _attributeIconPath = 'assets/images/properties/default.png';
      });
    }
  }
  /// 加载魂印描述
  void _loadSoulMarkData() async {
    try {
      if (_sprite?.id != null) {
        final soulDescription = await _spriteService.getSoulDescriptionById(_sprite!.id!);
        setState(() {
          _isLoadingSoul = false;
        });
        _displaySoulResult(soulDescription);
      } else {
        setState(() {
          _isLoadingSoul = false;
          _soulMarkDescription = '暂无魂印数据';
        });
      }
    } catch (e) {
      print('加载魂印数据失败: $e');
      setState(() {
        _isLoadingSoul = false;
        _soulMarkDescription = '魂印加载失败: $e';
      });
    }
  }
  /// 显示魂印结果
  void _displaySoulResult(String? soulDescription) {
    setState(() {
      if (soulDescription != null && soulDescription != "无魂印") {
        // 格式化魂印描述，使其更易读
        final formattedDescription = _formatSoulDescription(soulDescription);
        _soulMarkDescription = formattedDescription;
        print('成功加载魂印描述，长度: ${soulDescription.length}');
      } else {
        _soulMarkDescription = null; // 设置为null，在UI中显示"暂无魂印数据"
        print('该精灵无魂印信息');
      }
    });
  }
  /// 格式化魂印描述，添加换行和缩进
  String _formatSoulDescription(String description) {
    if (description.isEmpty) return description;

    // 替换常见的分隔符为换行
    String formatted = description
        .replaceAll("；", "；\n")
        .replaceAll("。", "。\n")
        .replaceAll("；\n ", "；\n")
        .replaceAll("。\n ", "。\n");

    // 添加缩进
    formatted = formatted.replaceAll("\n", "\n　　");

    // 确保开头有缩进
    if (!formatted.startsWith("　　")) {
      formatted = "　　" + formatted;
    }

    return formatted;
  }
  /// 加载技能数据
  void _loadSkillsData() async {
    try {
      if (_sprite?.id != null) {
        final skills = await _spriteService.querySkillsById(_sprite!.id!);

        setState(() {
          _isLoadingSkills = false;
        });

        _displaySkillsResult(skills);
      } else {
        setState(() {
          _isLoadingSkills = false;
          _skillsList = null;
        });
      }
    } catch (e) {
      print('加载技能数据失败: $e');
      setState(() {
        _isLoadingSkills = false;
        _skillsList = null;
      });
    }
  }

  /// 显示技能结果
  void _displaySkillsResult(List<SeerSkills>? skills) {
    setState(() {
      if (skills != null && skills.isNotEmpty) {
        _skillsList = skills;
        print('成功查询到 ${skills.length} 个技能');
      } else {
        _skillsList = null;
        print('未找到ID为 ${_sprite?.id} 的精灵技能');
      }
    });
  }

 /* /// 格式化技能显示文本
  String _formatSkillsText(List<SeerSkills> skills) {
    final buffer = StringBuffer();

    // 添加精灵名称标题
    final pokemonName = skills.first.spiritName;
    if (pokemonName != null && pokemonName.isNotEmpty) {
      buffer.write('【$pokemonName】的技能组\n\n');
    } else {
      buffer.write('精灵技能组\n\n');
    }

    // 构建技能详情
    for (int i = 0; i < skills.length; i++) {
      final skill = skills[i];

      buffer.write('技能${i + 1}: ${skill.name}\n');
      buffer.write('威力: ${skill.power}\n');
      buffer.write('PP: ${skill.pp}\n');
      buffer.write('命中: ${skill.accuracy}\n');
      buffer.write('先制: ${skill.priority}\n');
      buffer.write('类型: ${skill.type}\n');
      buffer.write('暴击: ${skill.strong}\n');
      buffer.write('效果: ${skill.effect}\n\n');
    }

    return buffer.toString();
  }*/
  // 打开全屏图片
  void _openFullscreenImage() {
    if (_sprite?.id == null) return;
    setState(() {
      _showFullscreenImage = true;
    });
  }

  // 关闭全屏图片
  void _closeFullscreenImage() {
    setState(() {
      _showFullscreenImage = false;
    });
  }
///下面开始ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5),
      body: Stack(
        children: [
          // 原来的内容
          CustomScrollView(
            slivers: [
              // 自定义的 SliverAppBar
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 4,
                pinned: true,
                expandedHeight: 0, // 设置为0，不使用扩展高度
                toolbarHeight: 56,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  _sprite?.name ?? '精灵详情',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                centerTitle: true,
                // 在底部添加分割线
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1), // 线条高度
                  child: Container(
                    height: 1, // 线条粗细
                    width: double.infinity, // 通长
                    color: Colors.black, // 线条颜色
                  ),
                ),
              ),

              // 内容区域
              SliverList(
                delegate: SliverChildListDelegate([
                  if (_isLoading)
                    _buildLoadingIndicator()
                  else
                    ..._buildContent(),
                ]),
              ),
            ],
          ),

          // 全屏图片覆盖层
          if (_showFullscreenImage)
            Container(
              color: Colors.black.withOpacity(0.65),
              child: Stack(
                children: [
                  // 可缩放的全屏图片
                  Positioned.fill(
                    child: PhotoView(
                      imageProvider: AssetImage(
                        'assets/images/sprites/${_sprite!.id}.webp',
                      ),
                      backgroundDecoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3.0,
                      initialScale: PhotoViewComputedScale.contained,
                      heroAttributes: PhotoViewHeroAttributes(
                        tag: 'sprite_image_${_sprite!.id}',
                      ),
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),

                  // 关闭按钮
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _closeFullscreenImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // 点击任意区域关闭（覆盖整个屏幕）
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _closeFullscreenImage,
                      behavior: HitTestBehavior.translucent,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      height: 200,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  List<Widget> _buildContent() {
    return [
      _buildSpriteImageSection(),
      _buildInfoSection(),
      _buildSoulMarkSection(),
      _buildSkillsSection(),
      const SizedBox(height: 16),
    ];
  }

  // 精灵图片区域
  Widget _buildSpriteImageSection() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _openFullscreenImage,
        child: _buildImageWithAutoHeight(),
      ),
    );
  }

  Widget _buildImageWithAutoHeight() {
    if (_sprite?.id == null) {
      return _buildPlaceholderWithAutoHeight();
    }

    final spriteImagePath = 'assets/images/sprites/${_sprite!.id}.webp';

    // 使用 LayoutBuilder 获取可用宽度
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Hero(
          tag: 'sprite_image_${_sprite!.id}',
          child: Image.asset(
            spriteImagePath,
            width: maxWidth,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholderWithAutoHeight();
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderWithAutoHeight() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Container(
          width: maxWidth,
          height: maxWidth * 0.75, // 设置一个合适的比例
          child: Image.asset(
            'assets/images/placeholders/zhanweifu.jpg',
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  // 信息内容区域
  Widget _buildInfoSection() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 名称和ID - 使用数据库查询到的数据
          Row(
            children: [
              Expanded(
                child: Text(
                  _sprite?.name ?? '未知精灵',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ID: ${_sprite?.id ?? 0}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 属性标题
          const Text(
            '属性',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // 属性图标和名称 - 使用数据库查询到的属性
          Row(
            children: [
              // 属性图标区域 - 无边框，与文字对齐
              Container(
                width: 24, // 调整为与文字高度匹配
                height: 24,
                alignment: Alignment.centerLeft, // 左对齐
                child: _buildAttributeIcon(20),
              ),
              const SizedBox(width: 8), // 减少间距
              Expanded(
                child: Text(
                  _sprite?.attribute ?? '未知属性',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 分隔线
          Divider(color: Colors.grey[500], height: 1),
          const SizedBox(height: 16),

          // 种族值总和 - 使用数据库查询到的种族值
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '种族值: ${_sprite?.totalAbility ?? 0}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 基础属性标题
          const Text(
            '基础属性',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 3),

          // 属性网格 - 使用数据库查询到的各项能力值
          _buildStatsGrid(),
        ],
      ),
    );
  }

  // 构建属性图标
  // 构建属性图标
  Widget _buildAttributeIcon(double size) {
    // 使用从服务层获取的图标路径
    final iconPath = _attributeIconPath ?? 'assets/images/properties/default.png';

    try {
      return Image.asset(
        iconPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          print('属性图标加载失败: $iconPath');
          return _buildDefaultAttributeIcon(size);
        },
      );
    } catch (e) {
      print('属性图标加载异常: $e');
      return _buildDefaultAttributeIcon(size);
    }
  }

// 构建默认属性图标
  Widget _buildDefaultAttributeIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.category,
        size: size * 0.7, // 调整图标大小为容器的70%
        color: Colors.white,
      ),
    );
  }

  // 属性网格
  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8), // ← 网格上方的内边距
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        final label = _getStatLabel(index);
        final value = _getStatValue(index);

        return Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  /*fontWeight: FontWeight.bold,*/
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatLabel(int index) {
    switch (index) {
      case 0: return '攻击';
      case 1: return '防御';
      case 2: return '特攻';
      case 3: return '特防';
      case 4: return '体力';
      case 5: return '速度';
      default: return '';
    }
  }

  int _getStatValue(int index) {
    switch (index) {
      case 0: return _sprite?.attack ?? 0;
      case 1: return _sprite?.defense ?? 0;
      case 2: return _sprite?.specialAttack ?? 0;
      case 3: return _sprite?.specialDefense ?? 0;
      case 4: return _sprite?.hp ?? 0;
      case 5: return _sprite?.speed ?? 0;
      default: return 0;
    }
  }

// 魂印显示区域
  Widget _buildSoulMarkSection() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '魂印效果',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingSoul)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_soulMarkDescription != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _soulMarkDescription!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6, // 增加行高，使文本更易读
                  color: Colors.black87,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '暂无魂印数据',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

// 技能显示区域
  Widget _buildSkillsSection() {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '技能组',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          if (_isLoadingSkills)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_skillsList != null && _skillsList!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: _buildFormattedSkillsText(_skillsList!),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '暂无技能数据',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建格式化的技能文本（使用 RichText 支持多种样式）
  Widget _buildFormattedSkillsText(List<SeerSkills> skills) {
    final textSpans = <TextSpan>[];

    // 添加精灵名称标题
    final pokemonName = skills.first.spiritName;
    if (pokemonName != null && pokemonName.isNotEmpty) {
      textSpans.add(
        TextSpan(
          text: '【$pokemonName】的技能组\n\n',
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black, // 标题颜色
            height: 1.6,
          ),
        ),
      );
    } else {
      textSpans.add(
        TextSpan(
          text: '精灵技能组\n\n',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black, // 标题颜色
            height: 1.6,
          ),
        ),
      );
    }

    // 构建技能详情
    for (int i = 0; i < skills.length; i++) {
      final skill = skills[i];

      // 技能名称（加粗显示）
      textSpans.add(
        TextSpan(
          text: '技能${i + 1}: ',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // 技能序号颜色
            height: 1.4,
          ),
        ),
      );
      textSpans.add(
        TextSpan(
          text: '${skill.name}\n',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // 技能名称颜色
            height: 1.2,
          ),
        ),
      );// 添加间距



      // 技能属性（普通样式）
      final skillProperties = [
        '威力: ${skill.power}',
        'PP: ${skill.pp}',
        '命中: ${skill.accuracy}',
        '先制: ${skill.priority}',
        '类型: ${skill.type}',
        '暴击: ${skill.strong}',
        '效果: ${skill.effect}',
      ];

      for (final property in skillProperties) {
        textSpans.add(
          TextSpan(
            text: '$property\n',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87, // 属性文字颜色
              height: 2.5,
            ),
          ),
        );
      }

      // 技能之间的间距
      textSpans.add(const TextSpan(text: '\n'));
    }

    return RichText(
      text: TextSpan(
        children: textSpans,
        style: const TextStyle(
          fontFamily: 'Monospace', // 使用等宽字体对齐更好
        ),
      ),
    );
  }
}