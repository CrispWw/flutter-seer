import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../Model/Sprite.dart';
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
  bool _isLoadingSoul = true;
  bool _isLoadingSkills = true;
  bool _showFullscreenImage = false;

  @override
  void initState() {
    super.initState();
    _loadSpriteData();
    _loadSoulMarkData();
    _loadSkillsData();
  }

  void _loadSpriteData() async {
    try {
      final sprite = await _spriteService.getSpriteById(widget.spriteId);
      setState(() {
        _sprite = sprite;
        _isLoading = false;
      });
    } catch (e) {
      print('加载精灵详情失败: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadSoulMarkData() async {
    // 加载魂印数据...
    setState(() {
      _isLoadingSoul = false;
      _soulMarkDescription = '暂无魂印数据'; // 临时占位
    });
  }

  void _loadSkillsData() async {
    // 加载技能数据...
    setState(() {
      _isLoadingSkills = false;
      _skillsDescription = '暂无技能数据'; // 临时占位
    });
  }

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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),

          // 属性图标和名称 - 使用数据库查询到的属性
          Row(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: _getAttributeColor(_sprite?.attribute),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(
                _sprite?.attribute ?? '未知属性',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
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
          const SizedBox(height: 12),

          // 属性网格 - 使用数据库查询到的各项能力值
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Color _getAttributeColor(String? attribute) {
    // 根据属性返回不同的颜色
    switch (attribute) {
      case '火':
        return Colors.red;
      case '水':
        return Colors.blue;
      case '草':
        return Colors.green;
      case '电':
        return Colors.yellow;
      case '冰':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  // 属性网格
  Widget _buildStatsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
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
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _soulMarkDescription ?? '暂无魂印数据',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
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
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _skillsDescription ?? '暂无技能数据',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}