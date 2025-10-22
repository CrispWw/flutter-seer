import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpriteGridItem extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final int id;
  final String properties;
  final VoidCallback? onTap;
  final bool isEmpty;

  SpriteGridItem({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.id,
    required this.properties,
    required this.onTap,
  }) : isEmpty = false;

  SpriteGridItem.empty({
    super.key,
  })  : imageUrl = null,
        name = '',
        id = 0,
        properties = '',
        onTap = null,
        isEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 使用 Expanded 让图片区域自适应
              Expanded(
                child: _buildImageSection(),
              ),
              // 只有非空状态才显示信息区域
              if (!isEmpty) ...[
                const SizedBox(height: 8),
                _buildInfoSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isEmpty ? Colors.grey[200] : Colors.white,
      ),
      child: isEmpty ? _buildPlaceholderImage() : _buildActualImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/placeholders/zhanweifu.jpg',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackPlaceholder();
        },
      ),
    );
  }

  Widget _buildFallbackPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.photo,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildActualImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholderImage();
    }

    // 转换图片路径：从 "images/sprites/1.webp" 到 "assets/images/sprites/1.webp"
    final String assetPath = _convertToAssetPath(imageUrl!);
    print('加载图片: 数据库路径="$imageUrl" -> 资源路径="$assetPath"'); // 调试日志

    // 网络图片（如果以 http 开头）
    if (imageUrl!.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.contain,
            ),
          ),
        ),
        placeholder: (context, url) => _buildPlaceholderImage(),
        errorWidget: (context, url, error) => _buildPlaceholderImage(),
      );
    }
    // 本地图片
    else {
      try {
        return Image.asset(
          assetPath, // 使用转换后的路径
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            print('图片加载失败: 路径="$assetPath", 错误: $error');
            return _buildPlaceholderImage();
          },
        );
      } catch (e) {
        print('图片加载异常: 路径="$assetPath", 异常: $e');
        return _buildPlaceholderImage();
      }
    }
  }

  /// 转换图片路径到 assets 路径
  String _convertToAssetPath(String originalPath) {
    print('原始路径: $originalPath'); // 调试日志

    // 如果路径已经是 assets 开头，直接返回
    if (originalPath.startsWith('assets/')) {
      return originalPath;
    }

    // 如果路径是 "images/sprites/..."，添加 "assets/" 前缀
    if (originalPath.startsWith('images/sprites/')) {
      return 'assets/$originalPath';
    }

    // 如果路径只是文件名（如 "1.webp"），假设它在 sprites 文件夹中
    if (!originalPath.contains('/')) {
      return 'assets/images/sprites/$originalPath';
    }

    // 其他情况，假设是相对于 assets 的路径
    return 'assets/$originalPath';
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildName(),
        const SizedBox(height: 4),
        _buildIdAndProperties(),
      ],
    );
  }

  Widget _buildName() {
    return Text(
      name,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildIdAndProperties() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ID: ${id.toString().padLeft(4, '0')}',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          properties,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF757575),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}