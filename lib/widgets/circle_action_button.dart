import 'package:flutter/material.dart';
///图鉴页的按钮组件

// 修改 CircleActionButton 组件支持图片和图标
class CircleActionButton extends StatelessWidget {
  final IconData? icon;
  final String? imageAsset;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CircleActionButton({
    super.key,
    this.icon,
    this.imageAsset,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.size = 30,
  }) : assert(icon != null || imageAsset != null, '必须提供图标或图片');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: imageAsset != null
            ? Image.asset(
          imageAsset!,
          width: size * 0.5,
          height: size * 0.5,
          color: iconColor,
        )
            : Icon(icon, size: size * 0.5),
        color: iconColor,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}